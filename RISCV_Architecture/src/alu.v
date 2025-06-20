module alu (
    input [31:0] a,             // Operando A
    input [31:0] b,             // Operando B
    input [3:0] alu_ctrl,       // Control para operacion
    output reg [31:0] result    // Resultado
);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;        // add
            4'b0001: result = a - b;        // sub
            4'b0010: result = a & b;        // and
            4'b0011: result = a | b;        // or
            4'b0100: result = a ^ b;        // xor
            4'b0101: result = a << b[4:0];  // sll
            4'b0110: result = a >> b[4:0];  // srl
            default: result = 0;
        endcase
    end
endmodule
