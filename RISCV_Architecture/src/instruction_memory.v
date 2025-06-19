module instruction_memory (
    input  [31:0] addr,         // Dirección de la instrucción
    output [31:0] instruction   // instrucción leída
);
    reg [31:0] memory [0:255];  // Memoria de inst. de 256 palabras

    initial begin
        // Cargar instrucciones desde archivo
        $readmemh("program.hex", memory);
    end

    assign instruction = memory[addr[9:2]]; // Alineado a 4 bytes
endmodule
