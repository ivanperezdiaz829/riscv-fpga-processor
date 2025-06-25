// uart.v  — simple memory-mapped UART (TX+RX) for 50 MHz and 115 200 Bd
module uart #(
    parameter CLOCK_HZ = 50_000_000,
    parameter BAUD     = 115_200
) (
    input  wire        clk,
    input  wire        reset,

    // memory-map
    input  wire        we,           // Habilitación de escritura
    input  wire        re,           // Habilitación de lectura
    input  wire [7:0]  wdata,
    output reg  [7:0]  rdata,
    output wire        ready,        // 1 = TX room / RX dato actual

    // Pines físicos
    output wire        tx,
    input  wire        rx
);

    localparam DIV = CLOCK_HZ / BAUD;   // = 434

    /* ----------  TX  ---------- */
    reg [9:0]  tx_shift = 10'h3FF;      // idle = 1
    reg [15:0] tx_cnt   = 0;

    assign tx   = tx_shift[0];
    wire   tx_busy = !(tx_shift == 10'h3FF);

    always @(posedge clk) begin
        if (reset) begin
            tx_shift <= 10'h3FF;
            tx_cnt   <= 0;
        end else if (we && !tx_busy) begin        // Escribe byte en el UART
            tx_shift <= {1'b1, wdata, 1'b0};      // stop,data,start
            tx_cnt   <= DIV-1;
        end else if (tx_busy) begin
            if (tx_cnt == 0) begin
                tx_shift <= {1'b1, tx_shift[9:1]};
                tx_cnt   <= DIV-1;
            end else
                tx_cnt <= tx_cnt-1;
        end
    end

    /* ----------  RX  ---------- */
    reg [3:0]  rx_bits = 0;
    reg [15:0] rx_cnt  = 0;
    reg [7:0]  rx_byte = 0;
    reg        rx_valid = 0;

    always @(posedge clk) begin
        if (reset) begin
            rx_bits  <= 0; rx_cnt <= 0; rx_valid <= 0;
        end else begin
            rx_valid <= 0;
            if (!rx_bits && !rx) begin            // Empieza la detección del bit
                rx_bits <= 1;
                rx_cnt  <= DIV + DIV/2;           // Muestra el medio
            end else if (rx_bits) begin
                if (rx_cnt == 0) begin
                    rx_cnt <= DIV-1;
                    if (rx_bits == 9) begin       // Bit de parada
                        rx_bits <= 0;
                        rx_valid <= 1;
                    end else begin
                        rx_byte <= {rx, rx_byte[7:1]};
                        rx_bits <= rx_bits + 1;
                    end
                end else
                    rx_cnt <= rx_cnt-1;
            end
        end
    end

    /* ----------  Memory-mapped interface ---------- */
    assign ready = (!tx_busy) | rx_valid;          // Combinación simple de Flag

    always @(posedge clk)
        if (re)
            rdata <= rx_valid ? rx_byte : 8'h00;   // Retorna 0
endmodule
