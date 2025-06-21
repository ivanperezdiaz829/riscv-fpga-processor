module control_unit (
    input [6:0] opcode,         // Código de operación
    input [2:0] funct3,         // función de 3 bits
    input [6:0] funct7,         // función de 7 bits
    output reg alu_src,         // Selección de entrada B de la ALU
    output reg mem_read,        // Señal de lectura de memoria
    output reg mem_write,       // Señal de escritura de memoria
    output reg reg_write,       // Señal de escritura en registros
    output reg mem_to_reg,      // Selección para escribir en registro (WB)
    output reg [3:0] alu_ctrl   // Control de la operación de la ALU
);
    always @(*) begin
        alu_src = 0;
        mem_read = 0;
        mem_write = 0;
        reg_write = 0;
        mem_to_reg = 0;
        alu_ctrl = 4'b0000;

        case (opcode)
            7'b0110011: begin       // Tipo R
                alu_src = 0;
                reg_write = 1;
                mem_to_reg = 0;
                case ({funct7, funct3})
                    10'b0000000000: alu_ctrl = 4'b0000; // add
                    10'b0100000000: alu_ctrl = 4'b0001; // sub
                    10'b0000000111: alu_ctrl = 4'b0010; // and
                    10'b0000000110: alu_ctrl = 4'b0011; // or
                    10'b0000000100: alu_ctrl = 4'b0100; // xor
                    10'b0000000001: alu_ctrl = 4'b0101; // sll
                    10'b0000000101: alu_ctrl = 4'b0110; // srl
                    default:        alu_ctrl = 4'b1111;
                endcase
            end
            7'b0010011: begin       // addi
                alu_src = 1;
                reg_write = 1;
                alu_ctrl = 4'b0000; // add
            end
            7'b0000011: begin       // lw
                alu_src = 1;
                mem_read = 1;
                reg_write = 1;
                mem_to_reg = 1;
                alu_ctrl = 4'b0000;
            end
            7'b0100011: begin       // sw
                alu_src = 1;
                mem_write = 1;
                alu_ctrl = 4'b0000;
            end
            7'b1100011: begin       // beq
                alu_src = 0;
                alu_ctrl = 4'b0001; // sub
            end
            7'b1101111: begin       // jal
                alu_src = 0;
                reg_write = 1;
                mem_to_reg = 0;
                alu_ctrl = 4'b0000; // opcional
            end
            default: ;
        endcase
    end
endmodule