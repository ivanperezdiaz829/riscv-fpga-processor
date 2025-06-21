module cpu (
    input clk,      // Señal de reloj
    input reset     // Señal de reinicio
);

    // ============================================================
    // IF (Instruction Fetch) stage
    // ============================================================
    reg [31:0] pc;          // Contador de programa
    wire [31:0] instr;      // instrucción obtenida de memoria

    // Instancia de la memoria de instrucciones
    instruction_memory imem (
        .addr(pc),              // Dirección de la instrucción = PC
        .instruction(instr)     // Instrucción leída
    );

    // IF/ID registro de pipeline (entre IF e ID)
    reg [31:0] ifid_pc, ifid_instr;

    // ============================================================
    // ID (Instruction Decode) stage
    // ============================================================
    wire [6:0] opcode = ifid_instr[6:0];
    wire [4:0] rs1 = ifid_instr[19:15];
    wire [4:0] rs2 = ifid_instr[24:20];
    wire [4:0] rd = ifid_instr[11:7];
    wire [2:0] funct3 = ifid_instr[14:12];
    wire [6:0] funct7 = ifid_instr[31:25];

    wire [31:0] reg_data1, reg_data2;

    reg_file rf (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),       
        .rd(memwb_rd),
        .rd_data(memwb_result),
        .reg_write(memwb_reg_write),
        .data1(reg_data1),
        .data2(reg_data2)
    );

    // Lógica de saltos
    wire is_branch = (opcode == 7'b1100011);
    wire is_jump   = (opcode == 7'b1101111);
    wire branch_taken = (is_branch && reg_data1 == reg_data2);
    wire insert_bubble = (branch_taken || is_jump);

    // Registro de IF/ID con burbujas de salto
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            ifid_pc <= 0;
            ifid_instr <= 32'b0;
        end else begin
            if (branch_taken) begin
                pc <= pc + branch_offset;
                ifid_pc <= 0;
                ifid_instr <= 32'b0;
            end else if (is_jump) begin
                pc <= pc + jump_offset;
                ifid_pc <= 0;
                ifid_instr <= 32'b0;
            end else begin
                pc <= pc + 4;
                ifid_pc <= pc;
                ifid_instr <= instr;
            end
        end
    end

    // Inmediato decodificado
    wire [31:0] imm;
    immediate_generator imm_gen (
        .instr(ifid_instr),
        .imm(imm)
    );

    // Offsets para salto y ramas (ambos usan el mismo)
    wire [31:0] branch_offset = imm;
    wire [31:0] jump_offset = imm;

    // Unidad de control: genera señales de control a partir de la instrucción
    wire alu_src, mem_read, mem_write, reg_write, mem_to_reg;
    wire [3:0] alu_ctrl;

    control_unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .alu_ctrl(alu_ctrl)
    );

    // ID/EX registros de pipeline (entre ID y EX)
    reg [31:0] idex_pc, idex_reg_data1, idex_reg_data2, idex_imm;
    reg [3:0]  idex_alu_ctrl;
    reg idex_alu_src, idex_mem_read, idex_mem_write, idex_reg_write, idex_mem_to_reg;
    reg [4:0]  idex_rd, idex_rs1, idex_rs2;

    always @(posedge clk) begin
        idex_pc         <= ifid_pc;
        idex_reg_data1  <= reg_data1;
        idex_reg_data2  <= reg_data2;
        idex_imm        <= imm;
        idex_alu_ctrl   <= alu_ctrl;
        idex_alu_src    <= alu_src;
        idex_mem_read   <= mem_read;
        idex_mem_write  <= mem_write;
        idex_reg_write  <= reg_write;
        idex_mem_to_reg <= mem_to_reg;
        idex_rd         <= rd;
        idex_rs1        <= rs1;
        idex_rs2        <= rs2;
    end

    // ============================================================
    // EX (Execute) stage con FORWARDING
    // ============================================================
    wire forward_a_exmem = (exmem_reg_write && exmem_rd != 0 && exmem_rd == idex_rs1);
    wire forward_b_exmem = (exmem_reg_write && exmem_rd != 0 && exmem_rd == idex_rs2);

    wire forward_a_memwb = (memwb_reg_write && memwb_rd != 0 && memwb_rd == idex_rs1);
    wire forward_b_memwb = (memwb_reg_write && memwb_rd != 0 && memwb_rd == idex_rs2);

    wire [31:0] forward_a = forward_a_exmem ? exmem_result :
                            forward_a_memwb ? memwb_result :
                            idex_reg_data1;

    wire [31:0] forward_b_reg = forward_b_exmem ? exmem_result :
                                forward_b_memwb ? memwb_result :
                                idex_reg_data2;

    wire [31:0] alu_in2 = idex_alu_src ? idex_imm : forward_b_reg;

    wire [31:0] alu_result;

    alu alu_inst (
        .a(forward_a),
        .b(alu_in2),
        .alu_ctrl(idex_alu_ctrl),
        .result(alu_result)
    );

    reg [31:0] exmem_result, exmem_reg_data2;
    reg        exmem_mem_read, exmem_mem_write, exmem_reg_write, exmem_mem_to_reg;
    reg [4:0]  exmem_rd;

    always @(posedge clk) begin
        exmem_result     <= alu_result;
        exmem_reg_data2  <= forward_b_reg; // ya aplicado forwarding
        exmem_mem_read   <= idex_mem_read;
        exmem_mem_write  <= idex_mem_write;
        exmem_reg_write  <= idex_reg_write;
        exmem_mem_to_reg <= idex_mem_to_reg;
        exmem_rd         <= idex_rd;
    end

    // ============================================================
    // MEM y WB
    // ============================================================
    wire [31:0] mem_data_out;

    // Obtener señales de la memoria de datos
    data_memory dmem (
        .clk(clk),
        .addr(exmem_result),            // Dirección calculada por la ALU
        .write_data(exmem_reg_data2),   // Dato a escribir en caso de SW
        .mem_read(exmem_mem_read),      // Señal de lectura
        .mem_write(exmem_mem_write),    // Señal de escritura
        .read_data(mem_data_out)        // Salida de memoria
    );

    // MEM/WB registro de pipeline (entre MEM y WB)
    reg [31:0] memwb_result;
    reg memwb_reg_write;
    reg [4:0]  memwb_rd;

    always @(posedge clk) begin
        // Selección del dato a escribir en el registro destino
        memwb_result    <= exmem_mem_to_reg ? mem_data_out : exmem_result;
        memwb_reg_write <= exmem_reg_write;
        memwb_rd        <= exmem_rd;
    end
endmodule