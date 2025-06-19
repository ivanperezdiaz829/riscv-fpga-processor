module reg_file (
    input clk,              // Reloj del sistema
    input [4:0] rs1,        // Registro fuente 1
    input [4:0] rs2,        // Registro fuente 2
    input [4:0] rd,         // Registro destino
    input [31:0] rd_data,   // Dato a escribir en el registro destino
    input reg_write,        // Habilita la escritura en el registro destino
    output [31:0] data1,    // Salida del registro fuente 1
    output [31:0] data2     // Salida del registro fuente 2
);
    reg [31:0] regs[0:31];  // Banco de registros de 32 registros de 32 bits

    assign data1 = regs[rs1];
    assign data2 = regs[rs2];

    always @(posedge clk) begin
        if (reg_write && rd != 0) begin
            regs[rd] <= rd_data;
        end
    end
endmodule