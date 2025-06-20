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
    // Campos de la instrucción (formato R/I/S/B/J)
    wire [6:0] opcode = ifid_instr[6:0];
    wire [4:0] rs1 = ifid_instr[19:15];
    wire [4:0] rs2 = ifid_instr[24:20];
    wire [4:0] rd  = ifid_instr[11:7];
    wire [2:0] funct3 = ifid_instr[14:12];
    wire [6:0] funct7 = ifid_instr[31:25];

    // Salida del banco de registros
    wire [31:0] reg_data1, reg_data2;

    // Banco de registros: lectura de rs1 y rs2, escritura en rd
    reg_file rf (
        .clk(clk),
        .rs1(rs1),                      // Registro fuente 1
        .rs2(rs2),                      // Registro fuente 2       
        .rd(memwb_rd),                  // Registro destino
        .rd_data(memwb_result),         // Dato a escribir en rd (dedse WB)
        .reg_write(memwb_reg_write),    // Habilita la escritura
        .data1(reg_data1),              // Salida de rs1
        .data2(reg_data2)               // Salida de rs2
    );

    // Lógica de salto
    wire is_branch = (opcode == 7'b1100011); // beq
    wire is_jump   = (opcode == 7'b1101111); // jal
    wire branch_taken = (is_branch && reg_data1 == reg_data2);
    wire insert_bubble = (branch_taken || is_jump);

    // Registro de IF/ID con burbuja en saltos
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            ifid_pc <= 0;
            ifid_instr <= 32'b0;
        end else begin
            // Actualiza el PC según el tipo de instrucción
            if (branch_taken) begin
                pc <= pc + branch_offset;
                ifid_pc <= 0;
                ifid_instr <= 32'b0;    // NOP (burbuja por salto)
            end else if (is_jump) begin
                pc <= pc + jump_offset;
                ifid_pc <= 0;
                ifid_instr <= 32'b0;    // NOP (burbuja por salto)
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

    // Offsets para salto y ramas (simple: ambos usan el mismo inmediato)
    wire [31:0] branch_offset = imm;
    wire [31:0] jump_offset = imm;

    // Unidad de control: genera señales de control a partir de la instrucción
    wire alu_src, mem_read, mem_write, reg_write, mem_to_reg;
    wire [3:0] alu_ctrl;

    control_unit ctrl (
        .opcode(opcode),            // Código de operación
        .funct3(funct3),            // Función 3bits
        .funct7(funct7),            // Función 7bits
        .alu_src(alu_src),          // Selecctión de entrada B de la ALU
        .mem_read(mem_read),        // Señal de lectura de memoria
        .mem_write(mem_write),      // Señal de escritura de memoria
        .reg_write(reg_write),      // Señal de escritura en registros
        .mem_to_reg(mem_to_reg),    // Selección para WB
        .alu_ctrl(alu_ctrl)         // Operación de la ALU
    );

    // ID/EX registros de pipeline (entre ID y EX)
    reg [31:0] idex_pc, idex_reg_data1, idex_reg_data2, idex_imm;
    reg [3:0]  idex_alu_ctrl;
    reg        idex_alu_src, idex_mem_read, idex_mem_write, idex_reg_write, idex_mem_to_reg;
    reg [4:0]  idex_rd;

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
    end

    // ============================================================
    // EX (Execute) stage
    // ============================================================
    // Selección del segundo operando de la ALU (reg o inm)
    wire [31:0] alu_in2 = idex_alu_src ? idex_imm : idex_reg_data2;
    
    // Resultado de la ALU
    wire [31:0] alu_result;

    // Instancia de la ALU
    alu alu_inst (
        .a(idex_reg_data1),
        .b(alu_in2),
        .alu_ctrl(idex_alu_ctrl),
        .result(alu_result)
    );

    // EX/MEM registro de pipeline (entre EX y MEM)
    reg [31:0] exmem_result, exmem_reg_data2;
    reg        exmem_mem_read, exmem_mem_write, exmem_reg_write, exmem_mem_to_reg;
    reg [4:0]  exmem_rd;

    always @(posedge clk) begin
        exmem_result     <= alu_result;
        exmem_reg_data2  <= idex_reg_data2;
        exmem_mem_read   <= idex_mem_read;
        exmem_mem_write  <= idex_mem_write;
        exmem_reg_write  <= idex_reg_write;
        exmem_mem_to_reg <= idex_mem_to_reg;
        exmem_rd         <= idex_rd;
    end

    // ============================================================
    // MEM (Memory Access) stage y WB (Write Back) stage
    // ============================================================
    wire [31:0] mem_data_out;

    // Acceso a la memoria de datos
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
    reg        memwb_reg_write;
    reg [4:0]  memwb_rd;

    always @(posedge clk) begin
        // Selección del dato a escribir en el registro destino
        memwb_result    <= exmem_mem_to_reg ? mem_data_out : exmem_result;
        memwb_reg_write <= exmem_reg_write;
        memwb_rd        <= exmem_rd;
    end
endmodule
