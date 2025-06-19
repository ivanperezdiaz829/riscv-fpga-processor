module instruction_memory {
    input [31:0] addr,              // Dirección de la isntrucción (PC)
    output reg [31:0] instruction   // Salida: Instrucción de 32 bits
};

    // Memoria simple de 32 palabras de 32 bits (espacio para 32 instr)
    reg [31:0] memory[0:31];

    initial begin
        // Carga de instr RISCV tipo R: add x3, x1, x2
        // funct7 = 0000000, rs2 = x2, rs1 = x1, funct3 = 000, rd = x3, opcode = 0110011
        memory[0] = 32'b0000000_00010_00001_000_00011_0110011;
    end

    // Lectura de instrucción (selecciona por la dirección / 4)
    always @(*) begin 
        instruction = memory[addr[6:2]];    // se usa [6:2] porque está en bytes
    end
endmodule
