module data_memory (
    input clk,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    output reg [31:0] read_data
);
    // Memoria de 256 palabras de 32 bits (1 KB total)
    reg [31:0] memory [0:255];

    // Carga inicial desde archivo hexadecimal
    initial begin
        $readmemh("test/data.mem", memory);
    end

    // Escritura en flanco de subida si mem_write está activo
    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[9:2]] <= write_data;  // Dirección alineada por palabra
        end
    end

    // Lectura combinacional si mem_read está activo
    always @(*) begin
        if (mem_read) begin
            read_data = memory[addr[9:2]];
        end else begin
            read_data = 32'b0;
        end
    end

    // Tarea para imprimir los primeros 16 valores (64 bytes)
    task print_memory;
        integer i;
        begin
            $display("==== Contenido de la memoria de datos ====");
            for (i = 0; i < 16; i = i + 1) begin
                $display("mem[0x%0h] = %0d (0x%08x)", i * 4, memory[i], memory[i]);
            end
        end
    endtask
endmodule
