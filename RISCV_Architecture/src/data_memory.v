// data_memory_uart.v — data RAM (1 KiB) + simple memory-mapped UART (TX+RX)
// Base design: your original data_memory (256×32). Added:
//   • UART mapped at addresses 0x2000_0000 – 0x2000_0003
//   • Writes to that region send a byte over TX.
//   • Reads return received byte (LSB) and 0 otherwise.
//   • Ready flag not exposed to CPU yet (polling via read; non-zero => data ready).
// Connect tx to DE0-Nano GPIO_1[1] (D13), rx to GPIO_1[0] (F13).

module data_memory #(
    parameter CLK_HZ      = 50_000_000,   // DE0-Nano on-board osc.
    parameter BAUD        = 115_200,
    parameter UART_ADDR   = 32'h2000_0000 // base address for UART (word-aligned)
) (
    input  wire        clk,
    input  wire        reset,

    // CPU data-bus side
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    input  wire        mem_read,
    input  wire        mem_write,
    output reg  [31:0] read_data,

    // physical pins for serial console
    output wire        tx,
    input  wire        rx
);
    // ------------------------------------------------------------
    // 1 KiB RAM   (256 × 32-bit) mapped at 0x0000_0000 .. 0x0000_03FF
    // ------------------------------------------------------------
    reg [31:0] memory [0:255];

    // Optional initial contents
    initial begin
        $readmemh("test/data.mem", memory);
    end

    // ------------------------------------------------------------
    // UART
    // ------------------------------------------------------------
    wire        we_uart  = mem_write && (addr[31:2] == UART_ADDR[31:2]);
    wire        re_uart  = mem_read  && (addr[31:2] == UART_ADDR[31:2]);
    wire [7:0]  uart_rdata;
    wire        uart_ready;

    uart #(
        .CLOCK_HZ (CLK_HZ),
        .BAUD     (BAUD)
    ) uart0 (
        .clk    (clk),
        .reset  (reset),
        .we     (we_uart),
        .re     (re_uart),
        .wdata  (write_data[7:0]),
        .rdata  (uart_rdata),
        .ready  (uart_ready),
        .tx     (tx),
        .rx     (rx)
    );

    // ------------------------------------------------------------
    // RAM write (only when address not in UART region)
    // ------------------------------------------------------------
    wire ram_access = (addr[31:10] == 22'b0); // 0x0000_0000-0x0000_03FF
    wire [7:0] ram_index = addr[9:2];         // word-address

    always @(posedge clk) begin
        if (mem_write && ram_access) begin
            memory[ram_index] <= write_data;
        end
    end

    // ------------------------------------------------------------
    // Read path (combinational)
    // ------------------------------------------------------------
    always @(*) begin
        if (mem_read) begin
            if (ram_access)
                read_data = memory[ram_index];
            else if (addr[31:2] == UART_ADDR[31:2])
                read_data = {24'd0, uart_rdata};
            else
                read_data = 32'hDEAD_BEEF; // unmapped access
        end else begin
            read_data = 32'd0;
        end
    end

    // ------------------------------------------------------------
    // Optional task to print first 16 words of RAM to console
    // ------------------------------------------------------------
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
