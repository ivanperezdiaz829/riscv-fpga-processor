module cpu {
    input clk,      // Señal de relog
    input reset     // Señal de reset
};

    // PC: Contador de programa (registro que guarda la dirección
    // de la instrucción actual)
    reg [31:0] pc;

    // Señal que contiene la instrucción leída desde la memoria
    wire [31:0] instr;

    // Instancia de la memoria de instrucciones
    instruction_memory imem {
        .addr(pc),              // Dirección de la instrucción
        .instruction(instr)     // Instrucción extraída
    };

    // Campos de la instrucción tipo R (RISC-V)
    wire [6:0] opcode = instr[6:0];     // Código de operación
    wire [4:0] rs1 = instr[19:15];      // Registro fuente 1
    wire [4:0] rs2 = instr[24:20];      // Registro fuente 2
    wire [4:0] rsd = instr[11:7];       // Registro destino

    // Resultado de la ALU
    wire [31:0] result;

    // Banco de registros (32 registros de 32 bits)
    reg [31:0] registers[0:31];

    // Operandos leídos de los registros
    wire [31:0] op1 = registers[rs1];
    wire [31:0] op2 = registers[rs2];

    // Instancia de la ALU
    alu my_alu {
        .a(op1),                // Operando A
        .b(op2),                // Operando B
        .alu_ctrl(4'b0010),     // OP control: 0010 = SUMA
        .result(result)         // salida = resultado
    };

    // Lógica Secuencial
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;        // Si hay reset, ponemos el PC en 0
        end else begin
            pc <= pc + 4;   // Avanza al siguiente PC (instr de 4 bytes)
        
            // Si la instrucción es de tipo R con OPcode 0110011 (add)
            if (opcode == 7'b0110011) begin
                registers[rd] <= result;    // Escribe el resultado en el destino
            end
        end
    end
endmodule
