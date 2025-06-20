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

    reg [31:0] registers[0:31];

    assign data1 = registers[rs1];
    assign data2 = registers[rs2];

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 0;
        end
    end

    always @(posedge clk) begin
        if (reg_write && rd != 0)
            registers[rd] <= rd_data;
    end

    // Task para imprimir los registros en la simulación
    task print_registers;
        integer j;
        begin
            $display("==== Banco de registros ====");
            for (j = 0; j < 32; j = j + 1) begin
                $display("x%0d = %0d", j, registers[j]);
            end
        end
    endtask
endmodule