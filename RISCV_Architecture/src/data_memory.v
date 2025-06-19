module data_memory (
    input clk,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255];

    initial begin
        $readmemh("data.mem", memory);  // Carga la memoria con data.mem
    end

    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[9:2]] <= write_data;  // Escritura en memoria por palabra
        end
    end

    always @(*) begin
        if (mem_read) begin
            read_data = memory[addr[9:2]];    // Lectura por palabra
        end else begin
            read_data = 32'b0;
        end
    end

    // Tarea para imprimir el contenido de la memoria (primeros 64 bytes)
    task print_memory;
        integer i;
        begin
            $display("Contenido memoria de datos:");
            for (i = 0; i < 16; i = i + 1) begin
                $display("mem[%0d] = %0d", i*4, memory[i]);
            end
        end
    endtask

endmodule
