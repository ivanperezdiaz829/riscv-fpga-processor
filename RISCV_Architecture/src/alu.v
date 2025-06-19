module alu {
    input [31:0] a,             // Operando A
    input [31:0] b,             // Operando B
    input [3:0] alu_ctrl,       // Control para determinar la operacion
    output reg [31:0] result    // Resultado
};

    always @(*) begin
        case (alu_ctrl)
            4'b0010: result = a + b;    // ADD
            4'b0110: result = a - b;    // SUB
            default: result = 0;        // Por defecto = 0
        endcase
    end
endmodule
