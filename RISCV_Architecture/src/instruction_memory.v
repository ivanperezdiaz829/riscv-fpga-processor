module instruction_memory (
    input  [31:0] addr,         // Dirección de la instrucción
    output [31:0] instruction   // instrucción leída
);
    reg [31:0] memory [0:255];  // Memoria de inst. de 256 palabras

    initial begin
        $readmemh("test/program.mem", memory);
        $display("\n==== INSTRUCCIONES CARGADAS ====");
        $display("0: %h", memory[0], " -> addi x1, x0, 10");
        $display("1: %h", memory[1], " -> addi x2, x0, 20");
        $display("2: %h", memory[2], " -> add x3, x1, x2");
        $display("3: %h", memory[3], " -> sw x3, 0(x2)");
        $display("4: %h", memory[4], " -> lw x3, 0(x2)");
        $display("5: %h", memory[5], " -> jal x0, 0");
        $display("6: %h", memory[6], " -> nop");
    end

    assign instruction = memory[addr[9:2]]; // Alineado a 4 bytes
endmodule
