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


// Interlaken Packet Checker

`timescale 1ps/1ps

module ilk_pkt_checker #(
  parameter SIM_FAKE_JTAG  = 1'b0,
  parameter INTERNAL_WORDS = 8,
  parameter LOG_INTE_WORDS = 4,
  parameter TX_PKTMOD_ONLY = 0,
  parameter NUM_LANES      = 24
)(
  input                         clk,
  input                         clk_rx_common,
  input                         clk_tx_common,

  input                         srst_rx_common,
  input                         srst_tx_common,
  input                         tx_usr_srst,
  input                         rx_usr_srst,

  input                         rx_lanes_aligned,
  input [64*INTERNAL_WORDS-1:0] irx_dout_words,
  input    [LOG_INTE_WORDS-1:0] irx_num_valid,
  input                         irx_sop,
  input                         irx_sob,
  input                   [7:0] irx_chan,
  input                   [3:0] irx_eopbits,

  input         [NUM_LANES-1:0] crc32_err,
  input                         crc24_err,

  input                         sop_cntr_inc,
  input                         eop_cntr_inc,

  input                         itx_overflow,
  input                         itx_underflow,
  input                         irx_overflow,
  input                         rdc_overflow,

  output reg             [31:0] sop_cntr,
  output reg             [31:0] eop_cntr,
  output reg  [NUM_LANES*8-1:0] crc32_err_cnt,
  output reg             [15:0] crc24_err_cnt,
  output reg             [19:0] checker_errors,
  output reg             [31:0] err_cnt,
  output reg                    itx_overflow_sticky,
  output reg                    itx_underflow_sticky,
  output reg                    irx_overflow_sticky,
  output reg                    rdc_overflow_sticky,

  input                         run_directed_test,
  input                         start_ch_wr,
  input                   [7:0] start_channel,
  input                   [7:0] num_channels,
  input  reg              [7:0] ch_cnt_id,
  output reg             [31:0] ch_cnt,
  input wire                    err_read,
  input                   [9:0] cpu_int_burst_size,
  input                         start_latency_cnt,
  input                   [7:0] latency_cnt_id,
  output wire                   latency_ready,
  output reg             [31:0] latency_cnt,
  output reg                    perf_meas_ready,
  input                         perf_meas_rdone,
  output wire             [1:0] pm_state,
  output reg             [31:0] perf_pkt_cnt,
  output reg             [31:0] perf_byte_cnt
);

  genvar i;

  wire [8*INTERNAL_WORDS-1:0] word8 = (INTERNAL_WORDS == 8) ? 64'h 7776757473727170 : 32'h73727170;
  wire [8*INTERNAL_WORDS-1:0] word7 = (INTERNAL_WORDS == 8) ? 64'h 6766656463626160 : 32'h63626160;
  wire [8*INTERNAL_WORDS-1:0] word6 = (INTERNAL_WORDS == 8) ? 64'h 5756555453525150 : 32'h53525150;
  wire [8*INTERNAL_WORDS-1:0] word5 = (INTERNAL_WORDS == 8) ? 64'h 4746454443424140 : 32'h43424140;
  wire [8*INTERNAL_WORDS-1:0] word4 = (INTERNAL_WORDS == 8) ? 64'h 3736353433323130 : 32'h33323130;
  wire [8*INTERNAL_WORDS-1:0] word3 = (INTERNAL_WORDS == 8) ? 64'h 2726252423222120 : 32'h23222120;
  wire [8*INTERNAL_WORDS-1:0] word2 = (INTERNAL_WORDS == 8) ? 64'h 1716151413121110 : 32'h13121110;
  wire [8*INTERNAL_WORDS-1:0] word1 = (INTERNAL_WORDS == 8) ? 64'h 0706050403020100 : 32'h03020100;

  reg                      rcv_pkt_valid = 1'b0;
  reg [LOG_INTE_WORDS-1:0] rcv_num_valid = {LOG_INTE_WORDS{1'b0}};
  reg                      rcv_pkt_sop   = 1'b0;
  reg                      rcv_pkt_sob   = 1'b0;
  wire                     ch_id_check;
  reg                [7:0] ch_cnt_id_d;

  reg stop_latency_cnt = 1'b0;

  // Packet Checker
  reg                         rcv_pkt_pld     = 1'b0;
  reg [64*INTERNAL_WORDS-1:0] rcv_pkt_data    = {64*INTERNAL_WORDS{1'b0}};
  reg [7:0]                   rcv_pkt_ch_num  = 8'h0;
  reg [7:0]                   exp_pkt_ch_num;
  reg [3:0]                   rcv_pkt_eopbits = 4'h0;
  reg [7:0]                   exp_pkt_cnt     = 8'h0;
  reg [9:0]                   int_burst_size;

  reg [7:0]                   rcv_ch_num;
  reg [7:0]                   exp_ch_num;

  wire [64*INTERNAL_WORDS-1:0] exp_sop_data;
  wire [64*INTERNAL_WORDS-1:0] exp_eop_data;
  reg  [64*INTERNAL_WORDS-1:0] exp_pld_data;

  reg sop_data_error = 1'b0;
  reg eop_data_error = 1'b0;
  reg pld_data_error = 1'b0;
  reg ch_num_error   = 1'b0;

  assign exp_sop_data = {word8, word7, word6, word5, word4, word3, word2, word1[8*INTERNAL_WORDS-1:8], exp_pkt_cnt};
  assign exp_eop_data = {word1, word2, word3, word4, word5, word6, word7, word8};
  assign ch_id_check  = (!int_burst_size) ? rcv_pkt_sop : rcv_pkt_sob;

  always @(posedge clk) begin
    int_burst_size <= cpu_int_burst_size >> 6;  // burst size comes in bytes, but used in terms of 64 byte words
  end

  always @(posedge clk) begin
    rcv_pkt_valid   <= |irx_num_valid;
    rcv_num_valid   <= irx_num_valid;
    rcv_pkt_sop     <= irx_sop;
    rcv_pkt_sob     <= irx_sob;
    rcv_pkt_data    <= irx_dout_words;
    rcv_pkt_ch_num  <= irx_chan;
    rcv_pkt_eopbits <= irx_eopbits;
  end

  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      exp_pkt_ch_num <= 8'h0;
    end else begin
      if (start_ch_wr) begin
        exp_pkt_ch_num <= start_channel;
      end else if (ch_id_check) begin
        exp_pkt_ch_num <= (exp_pkt_ch_num < (start_channel + num_channels)) ? exp_pkt_ch_num + 1'b1 : start_channel;
      end
    end
  end

  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      exp_pkt_cnt    <= 8'h0;
      exp_pld_data   <= {word7, word6, word5, word4, word3, word2, word1, word8};
      rcv_pkt_pld    <= 1'b0;
      sop_data_error <= 1'b0;
      ch_num_error   <= 1'b0;
      sop_data_error <= 1'b0;
      pld_data_error <= 1'b0;
      eop_data_error <= 1'b0;
      err_cnt        <= 32'h0;
      checker_errors <= 20'h0;
      ch_cnt         <= 32'h0;
      rcv_ch_num     <= 8'h0;
      exp_ch_num     <= 8'h0;
    end else begin
      if (rx_lanes_aligned && rcv_pkt_valid && rcv_pkt_sop) begin
        if (!(rcv_pkt_data == exp_sop_data)) begin
          sop_data_error <= 1'b1;
          // synthesis translate_off
          $display(" ERROR: Received SOP data %x", rcv_pkt_data);
          $display("        Expected SOP data %x", exp_sop_data);
          // synthesis translate_on
        end else begin
          sop_data_error <= 1'b0;
        end
      end

      if (rx_lanes_aligned && rcv_pkt_valid && ch_id_check) begin
        if (!(rcv_pkt_ch_num == exp_pkt_ch_num)) begin
          ch_num_error <= 1'b1;
          rcv_ch_num   <= rcv_pkt_ch_num;
          exp_ch_num   <= exp_pkt_ch_num;
          // synthesis translate_off
          $display(" ERROR: Received Ch # %3d", rcv_pkt_ch_num);
          $display("        Expected Ch # %3d", exp_pkt_ch_num);
          // synthesis translate_on
        end else begin
          ch_num_error <= 1'b0;
        end
      end

      ch_cnt_id_d <= ch_cnt_id;

      if (ch_cnt_id_d != ch_cnt_id) begin
        ch_cnt <= 32'h0;
      end else if (rx_lanes_aligned && rcv_pkt_valid && ch_id_check) begin
        ch_cnt <= (rcv_pkt_ch_num == ch_cnt_id) ? ch_cnt + 1'b1 : ch_cnt;
      end

      if (rx_lanes_aligned && rcv_pkt_valid) begin
        if (rcv_pkt_sop) begin
          exp_pld_data <= {word7, word6, word5, word4, word3, word2, word1, word8};
          rcv_pkt_pld  <= 1'b1;
        end else if (rcv_pkt_pld && !rcv_pkt_sop && !(rcv_pkt_eopbits[3] == 1'b1)) begin
          exp_pld_data <= {exp_pld_data[6], exp_pld_data[5], exp_pld_data[4], exp_pld_data[3], exp_pld_data[2], exp_pld_data[1], exp_pld_data[0], exp_pld_data[7]};
        end else if (rcv_pkt_eopbits[3] == 1'b1) begin
          rcv_pkt_pld <= 1'b0;
        end
      end

      if (rx_lanes_aligned && rcv_pkt_valid && rcv_pkt_sop) begin
        exp_pkt_cnt <= exp_pkt_cnt + 1'b1;
      end

      if (rx_lanes_aligned && rcv_pkt_valid && rcv_pkt_pld && !rcv_pkt_sop && !(rcv_pkt_eopbits[3] == 1'b1)) begin
        if (!(rcv_pkt_data == exp_pld_data)) begin
          pld_data_error <= 1'b1;
          // synthesis translate_off
          $display(" ERROR: PKT %3d; Received PLD data %x", exp_pkt_cnt, rcv_pkt_data);
          $display("                 Expected PLD data %x", exp_pld_data);
          // synthesis translate_on
        end else begin
          pld_data_error <= 1'b0;
        end
      end

      if (rx_lanes_aligned && rcv_pkt_valid && (rcv_pkt_eopbits[3] == 1'b1) && !rcv_pkt_sop) begin
        if (INTERNAL_WORDS == 8) begin
          if ((rcv_num_valid == 4'h8 && !(rcv_pkt_data == exp_eop_data)) ||
              (rcv_num_valid == 4'h7 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 1*8*INTERNAL_WORDS] == exp_eop_data[64*INTERNAL_WORDS-1 : 1*8*INTERNAL_WORDS])) ||
              (rcv_num_valid == 4'h6 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 2*8*INTERNAL_WORDS] == exp_eop_data[64*INTERNAL_WORDS-1 : 2*8*INTERNAL_WORDS])) ||
              (rcv_num_valid == 4'h5 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 3*8*INTERNAL_WORDS] == exp_eop_data[64*INTERNAL_WORDS-1 : 3*8*INTERNAL_WORDS])) ||
              (rcv_num_valid == 4'h4 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 4*8*INTERNAL_WORDS] == exp_eop_data[64*INTERNAL_WORDS-1 : 4*8*INTERNAL_WORDS])) ||
              (rcv_num_valid == 4'h3 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 5*8*INTERNAL_WORDS] == exp_eop_data[64*INTERNAL_WORDS-1 : 5*8*INTERNAL_WORDS])) ||
              (rcv_num_valid == 4'h2 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 6*8*INTERNAL_WORDS] == exp_eop_data[64*INTERNAL_WORDS-1 : 6*8*INTERNAL_WORDS])) ||
              (rcv_num_valid == 4'h1 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 7*8*INTERNAL_WORDS] == exp_eop_data[64*INTERNAL_WORDS-1 : 7*8*INTERNAL_WORDS]))) begin
            eop_data_error <= 1'b1;
            // synthesis translate_off
            $display(" ERROR: PKT # %3d; Received EOP data %x", exp_pkt_cnt, rcv_pkt_data);
            $display("                   Expected EOP data %x", exp_eop_data);
            // synthesis translate_on
          end else begin
            eop_data_error <= 1'b0;
          end
        end else begin
          if ((rcv_num_valid == 4'h4 && !(rcv_pkt_data == exp_eop_data)) ||
              (rcv_num_valid == 4'h3 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 1*64] == exp_eop_data[64*INTERNAL_WORDS-1 : 1*64])) ||
              (rcv_num_valid == 4'h2 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 2*64] == exp_eop_data[64*INTERNAL_WORDS-1 : 2*64])) ||
              (rcv_num_valid == 4'h1 && !(rcv_pkt_data[64*INTERNAL_WORDS-1 : 3*64] == exp_eop_data[64*INTERNAL_WORDS-1 : 3*64]))) begin
            eop_data_error <= 1'b1;
            // synthesis translate_off
            $display(" ERROR: PKT # %3d; Received EOP data %x", exp_pkt_cnt, rcv_pkt_data);
            $display("                   Expected EOP data %x", exp_eop_data);
            // synthesis translate_on
          end else begin
            eop_data_error <= 1'b0;
          end
        end
      end

      if (sop_data_error || ch_num_error || pld_data_error || eop_data_error) begin
        err_cnt <= err_cnt + 1'b1;
        // synthesis translate_off
        $display("TEST FAILED!");
        #100000
        $finish;
        // synthesis translate_on
      end

      if (err_read) begin
        checker_errors <= 20'h0;
      end else if (sop_data_error || ch_num_error || pld_data_error || eop_data_error) begin
        checker_errors <= {rcv_ch_num, exp_ch_num, sop_data_error, ch_num_error, pld_data_error, eop_data_error};
      end
    end
  end

  // cursory check for sop, eop
  reg [31:0] sop_cntr_r;
  reg [31:0] eop_cntr_r;

  always @(posedge clk) begin
    if (srst_rx_common) begin
      sop_cntr_r <= 32'h0;
      eop_cntr_r <= 32'h0;
    end else begin
      if (!(rx_lanes_aligned)) begin
        sop_cntr_r <= 32'h0;
        eop_cntr_r <= 32'h0;
      end else begin
        if (rx_lanes_aligned) begin
          sop_cntr_r <= sop_cntr_r + sop_cntr_inc;
          eop_cntr_r <= eop_cntr_r + eop_cntr_inc;
        end
      end
    end
  end

  always @(posedge clk) begin
    sop_cntr <= sop_cntr_r;
    eop_cntr <= eop_cntr_r;
  end

  // count CRC 32 errors to make them easier to watch
  generate
    for (i=0; i<NUM_LANES; i=i+1) begin : lrc
      always @(posedge clk_rx_common) begin
        if (srst_rx_common) begin
          crc32_err_cnt[(i+1)*8-1:i*8] <= 8'h0;
        end else if (crc32_err[i]) begin
          crc32_err_cnt[(i+1)*8-1:i*8] <= crc32_err_cnt[(i+1)*8-1:i*8] + 1'b1;
        end
      end
    end
  endgenerate

  // count CRC 24 errors
  always @(posedge clk_rx_common) begin
    if (srst_rx_common) begin
      crc24_err_cnt <= 16'h0;
    end else begin
      crc24_err_cnt <= crc24_err_cnt + crc24_err;
    end
  end

  // sticky flag FIFO errors
  always @(posedge clk) begin
    if (tx_usr_srst) begin
      itx_overflow_sticky <= 1'b0;
    end else begin
      itx_overflow_sticky <= itx_overflow_sticky | itx_overflow;
    end
  end

  // sticky flag FIFO errors
  always @(posedge clk_tx_common) begin
    if (srst_tx_common) begin
      itx_underflow_sticky <= 1'b0;
    end else begin
      itx_underflow_sticky <= itx_underflow_sticky | itx_underflow;
    end
  end

  // sticky flag FIFO errors
  always @(posedge clk_rx_common) begin
    if (srst_rx_common)
      irx_overflow_sticky <= 1'b0;
    else
      irx_overflow_sticky <= irx_overflow_sticky | irx_overflow;
  end

  // sticky flag FIFO errors
  always @(posedge clk_rx_common) begin
    if (srst_rx_common) begin
      rdc_overflow_sticky <= 1'b0;
    end else begin
      rdc_overflow_sticky <= rdc_overflow_sticky | rdc_overflow;
    end
  end

  //Latency measurement
  initial latency_cnt = 32'h0;

  always @(posedge clk or posedge rx_usr_srst) begin
    if (rx_usr_srst) begin
      stop_latency_cnt <= 1'b0;
    end else begin
      if (start_latency_cnt) begin
        if (rcv_pkt_sop && latency_cnt_id == rcv_pkt_data[7:0]) begin
          stop_latency_cnt <= 1'b1;
        end
      end else begin
        stop_latency_cnt <= 1'b0;
      end

      if (stop_latency_cnt) begin
        latency_cnt <= latency_cnt;
      end else if (start_latency_cnt) begin
        latency_cnt <= latency_cnt + 1'b1;
      end else begin
        latency_cnt <= 0;
      end
    end
  end

  assign latency_ready = stop_latency_cnt;

  // Perfomance measurements
  localparam TERMINAL_COUNT = (SIM_FAKE_JTAG) ? 32'd7000 : 32'd300000000;
  localparam PM_IDLE    = 2'b00,
             PM_ACTIVE  = 2'b01,
             PM_WT_READ = 2'b10;

  reg  [1:0] perf_meas_state = PM_IDLE;
  reg [31:0] perf_clock_cnt  = 32'h0;

  always @(posedge clk or posedge rx_usr_srst) begin
    if (rx_usr_srst) begin
      perf_meas_state <= PM_IDLE;
      perf_meas_ready <= 1'b0;
      perf_clock_cnt  <= {32{1'b0}};
      perf_pkt_cnt    <= {32{1'b0}};
      perf_byte_cnt   <= {32{1'b0}};
    end else begin
      case (perf_meas_state)
        PM_IDLE    : begin
          perf_meas_ready <= 1'b0;
          perf_clock_cnt  <= {32{1'b0}};
          perf_pkt_cnt    <= {32{1'b0}};
          perf_byte_cnt   <= {32{1'b0}};
          if (rx_lanes_aligned && rcv_pkt_sop) begin
            perf_meas_state <= PM_ACTIVE;
          end else begin
            perf_meas_state <= PM_IDLE;
          end
        end

        PM_ACTIVE  : begin
          if (perf_clock_cnt == TERMINAL_COUNT) begin
            perf_meas_ready <= 1'b1;
            perf_clock_cnt  <= perf_clock_cnt;
            perf_meas_state <= PM_WT_READ;
          end else begin
            perf_clock_cnt  <= perf_clock_cnt + 1'b1;
            perf_meas_state <= PM_ACTIVE;
          end

          if (rcv_pkt_sop == 1'b1) begin
            perf_pkt_cnt <= perf_pkt_cnt + 1'b1;
          end

          if (rcv_pkt_valid == 1'b1) begin
            perf_byte_cnt <= perf_byte_cnt + rcv_num_valid;
          end
        end

        PM_WT_READ : begin
          if (perf_meas_rdone == 1'b1) begin
            perf_meas_ready <= 1'b0;
            perf_clock_cnt  <= {32{1'b0}};
            perf_pkt_cnt    <= {32{1'b0}};
            perf_byte_cnt   <= {32{1'b0}};
            perf_meas_state <= PM_IDLE;
          end else begin
            perf_meas_ready <= 1'b1;
            perf_clock_cnt  <= perf_clock_cnt;
            perf_pkt_cnt    <= perf_pkt_cnt;
            perf_byte_cnt   <= perf_byte_cnt;
            perf_meas_state <= PM_WT_READ;
          end
        end

        default    : perf_meas_state <= PM_IDLE;
      endcase
    end
  end

  assign pm_state = perf_meas_state;

endmodule
