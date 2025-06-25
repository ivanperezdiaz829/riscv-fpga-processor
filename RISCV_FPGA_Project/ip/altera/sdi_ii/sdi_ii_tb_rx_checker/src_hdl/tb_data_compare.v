// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps
`define tdisplay(MYSTRING) $display("%t:%s \n", $time,  MYSTRING)

module tb_data_compare (
    // port list
    tx_clk,
    rx_clk,
    rst,
    rx_locked,
    txdata,
    txdata_valid,
    rxdata,
    rxdata_valid,
    enable,
    video_std,
    data_error
);

    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------
    input        tx_clk;
    input        rx_clk;
    input        rst;
    input        rx_locked;
    input [19:0] txdata;
    input        txdata_valid;
    input [19:0] rxdata;
    input        rxdata_valid;
    input        enable;
    input [1:0]  video_std;
    output       data_error;

    parameter    EN_SD_20BITS = 1'b0;

    //--------------------------------------------------------------------------------------------------
    // Detect active picture (Tx)
    //--------------------------------------------------------------------------------------------------
    reg [119:0] txdata_reg;
    reg         tx_trs_detect;
    reg         tx_ap;
    reg         start_data_store;
 
    always @ (posedge tx_clk or posedge rst)
    begin
       if (rst) begin
          tx_trs_detect <= 1'b0;
          tx_ap <= 1'b0;
          txdata_reg <= 60'd0;
          start_data_store <= 1'b0;
       end else if (txdata_valid) begin
          // Store txdata into a register
          if (rx_locked && enable) begin
             txdata_reg <= {txdata_reg[99:0], txdata};
          end

          // Assert trs_detect signal when trs is detected in transmitted data
          if (video_std == 2'b10) begin
             if (txdata_reg == {{2{20'hfffff}}, {2{40'd0}}}) begin
                tx_trs_detect <= 1'b1;
             end else begin
                tx_trs_detect <= 1'b0;
             end
          end else if (EN_SD_20BITS & video_std == 2'b00) begin
             if (txdata_reg[39:20] == {10'h000, 10'h3ff} & txdata_reg[9:0] == 10'h000) begin
                tx_trs_detect <= 1'b1;
             end else begin
                tx_trs_detect <= 1'b0;
             end
          end else begin
             if (txdata_reg[59:0] == {20'hfffff, 40'd0}) begin
                tx_trs_detect <= 1'b1;
             end else begin
                tx_trs_detect <= 1'b0;
             end
          end

          // Determine whether current data is in active picture region
          if (tx_trs_detect) begin
             if (EN_SD_20BITS & video_std == 2'b00) begin
                if (~txdata_reg[37] & ~txdata_reg[36]) begin
                   tx_ap <= 1'b1;
                   start_data_store <= 1'b1;
                end else begin
                   tx_ap <= 1'b0;
                end
             end else if (~EN_SD_20BITS & video_std == 2'b00) begin
                if (~txdata_reg[7] & ~txdata_reg[6]) begin
                   tx_ap <= 1'b1;
                   start_data_store <= 1'b1;
                end else begin
                   tx_ap <= 1'b0;
                end
             end else begin
                if (~txdata_reg[17] & ~txdata_reg[16]) begin
                   tx_ap <= 1'b1;
                   start_data_store <= 1'b1;
                end else begin
                   tx_ap <= 1'b0;
                end
             end
          end
       end
    end

    //--------------------------------------------------------------------------------------------------
    // Detect active picture (Rx)
    //--------------------------------------------------------------------------------------------------
    reg [119:0] rxdata_reg;
    reg         rx_trs_detect;
    reg         read_fifo;

    always @ (posedge rx_clk or posedge rst)
    begin
       if (rst) begin
          rx_trs_detect <= 1'b0;
          read_fifo <= 1'b0;
          rxdata_reg <= 60'd0;
       end else if (rxdata_valid) begin
          // Store rxdata into a register
          if (rx_locked && enable) begin
             rxdata_reg <= {rxdata_reg[99:0], rxdata};
          end

          // Assert trs_detect signal when trs is detected
          if (video_std == 2'b10) begin
             if (rxdata_reg == {{2{20'hfffff}}, {2{40'd0}}}) begin
                rx_trs_detect <= 1'b1;
             end else begin
                rx_trs_detect <= 1'b0;
             end
          end else if (EN_SD_20BITS & video_std == 2'b00) begin
             if (rxdata_reg[39:20] == {10'h000, 10'h3ff} & rxdata_reg[9:0] == 10'h000) begin
                rx_trs_detect <= 1'b1;
             end else begin
                rx_trs_detect <= 1'b0;
             end
          end else begin
             if (rxdata_reg[59:0] == {20'hfffff, 40'd0}) begin
                rx_trs_detect <= 1'b1;
             end else begin
                rx_trs_detect <= 1'b0;
             end
          end

          // Start reading fifo when rxdata is in active picture region
          if (rx_trs_detect & start_data_store) begin
             if (EN_SD_20BITS & video_std == 2'b00) begin
                if (~rxdata_reg[37] & ~rxdata_reg[36]) begin
                   read_fifo <= 1'b1;
                end else begin
                   read_fifo <= 1'b0;
                end
             end else if (~EN_SD_20BITS & video_std == 2'b00) begin
                if (~rxdata_reg[7] & ~rxdata_reg[6]) begin
                   read_fifo <= 1'b1;
                end else begin
                   read_fifo <= 1'b0;
                end
             end else begin
                if (~rxdata_reg[17] & ~rxdata_reg[16]) begin
                   read_fifo <= 1'b1;
                end else begin
                   read_fifo <= 1'b0;
                end
             end
          end
       end
    end

    //--------------------------------------------------------------------------------------------------
    // Fifo to store txdata
    //-------------------------------------------------------------------------------------------------- 
    wire [19:0] test_fifo_out;

    tb_fifo_line_test u_fifo
    (
     .aclr             (rst),
     .data             (txdata_reg[19:0]),
     .rdclk            (rx_clk),
     .rdreq            (read_fifo & rxdata_valid),
     .wrclk            (tx_clk),
     .wrreq            (tx_ap & txdata_valid),
     .q                (test_fifo_out),
     .rdusedw          ()
    );

    //--------------------------------------------------------------------------------------------------
    // Compare rxdata with dataout from fifo
    //--------------------------------------------------------------------------------------------------
    reg [19:0]  rxdata_dly_2;
    reg         read_fifo_dly;
    reg         data_error ;
    reg         data_error_seen;

    always @ (posedge rx_clk or posedge rst)
    begin
       if (rst) begin
          data_error <= 1'b1;
          data_error_seen <= 1'b0;
       end else if (rxdata_valid) begin
          rxdata_dly_2 <= rxdata_reg[19:0];
          read_fifo_dly <= read_fifo;

          if (read_fifo_dly) begin
             if (~EN_SD_20BITS & video_std == 2'b00) begin
                //SD mode - lower 10 bits
                if (rxdata_dly_2[9:0] == test_fifo_out[9:0] && ~data_error_seen) begin
                   data_error <= 1'b0;
                end else begin
                   data_error <= 1'b1;
                   data_error_seen <= 1'b1;
                end
             end else begin
                // All 20 bits
                if (rxdata_dly_2 == test_fifo_out && ~data_error_seen) begin
                   data_error <= 1'b0;
                end else begin
                   data_error <= 1'b1;
                   data_error_seen <= 1'b1;
                end
             end
          end
       end
    end

    //--------------------------------------------------------------------------
    // [END] comment
    //--------------------------------------------------------------------------

 endmodule
