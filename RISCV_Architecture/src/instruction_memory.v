module instruction_memory (
    input  [31:0] addr,         // Dirección de la instrucción
    output [31:0] instruction   // instrucción leída
);
    reg [31:0] memory [0:255];  // Memoria de inst. de 256 palabras

    initial begin
        `ifdef TEST
            $readmemh("test/test.mem", memory);
        `else
            $readmemh("test/program.mem", memory);
        `endif
    end

    task print_test; 
        begin
            $display("\n==== INSTRUCCIONES CARGADAS ====");
            $display("0: %h", memory[0], " -> aadi a5, x0, 60");
            $display("1: %h", memory[1], " -> lui a3, 0x20000");
            $display("2: %h", memory[2], " -> lbu a4, 0(a5)");
            $display("3: %h", memory[3], " -> bne a4, x0, +24");
            $display("4: %h", memory[4], " -> addi a5, x0, 100");
            $display("5: %h", memory[5], " -> lui a3, 0x20000");
            $display("6: %h", memory[6], " -> lbu a4, 0(a5)");
            $display("7: %h", memory[7], " -> bne a0, x0, +20");
            $display("8: %h", memory[8], " -> jal x0, 0");
            $display("9: %h", memory[9], " -> addi a5, a5, 1");
            $display("10: %h", memory[10], " -> sb a4, 0(a3)");
            $display("11: %h", memory[11], " -> jal x0, -36");
            $display("12: %h", memory[12], " -> addi a5, a5, 1");
            $display("13: %h", memory[13], " -> sb a4, 0(a3)");
            $display("14: %h", memory[14], " -> jal x0, -32");
            $display("15..27 -> Bytes de texto");
        end
    endtask

    task print_program;
        begin
            $display("\n==== INSTRUCCIONES CARGADAS ====");
            $display("0: %h", memory[0], " -> addi x1, x0, 10");
            $display("1: %h", memory[1], " -> addi x2, x0, 20");
            $display("2: %h", memory[2], " -> add x3, x1, x2");
            $display("3: %h", memory[3], " -> sw x3, 0(x2)");
            $display("4: %h", memory[4], " -> lw x3, 0(x2)");
            $display("5: %h", memory[5], " -> jal x0, 0");
            $display("6: %h", memory[6], " -> nop");
        end
    endtask

    assign instruction = memory[addr[9:2]]; // Alineado a 4 bytes
endmodule
