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
   parameter INTERNAL_WORDS = 8,
   parameter NUM_LANES      = 24,
   parameter RX_DUAL_SEG    = 1
)(
   input                         clk,

   input                         tx_usr_srst,
   input                         rx_usr_srst,

   input                         rx_lanes_aligned,
   input [64*INTERNAL_WORDS-1:0] irx_dout_words,
   input                   [7:0] irx_num_valid,
   input                   [1:0] irx_sop,
   input                   [7:0] irx_chan,
   input                   [3:0] irx_eopbits,

   input wire                    err_read,
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
   output reg              [3:0] checker_errors,
   output reg             [31:0] err_cnt,
   output reg                    itx_overflow_sticky,
   output reg                    itx_underflow_sticky,
   output reg                    irx_overflow_sticky,
   output reg                    rdc_overflow_sticky
);

   genvar i;

   localparam [8*INTERNAL_WORDS-1:0] WORD8 = 64'h 7776757473727170;
   localparam [8*INTERNAL_WORDS-1:0] WORD7 = 64'h 6766656463626160;
   localparam [8*INTERNAL_WORDS-1:0] WORD6 = 64'h 5756555453525150;
   localparam [8*INTERNAL_WORDS-1:0] WORD5 = 64'h 4746454443424140;
   localparam [8*INTERNAL_WORDS-1:0] WORD4 = 64'h 3736353433323130;
   localparam [8*INTERNAL_WORDS-1:0] WORD3 = 64'h 2726252423222120;
   localparam [8*INTERNAL_WORDS-1:0] WORD2 = 64'h 1716151413121110;
   localparam [8*INTERNAL_WORDS-1:0] WORD1 = 64'h 0706050403020100;

   function [511:0] pkt_data;
      input [3:0] offset;
      reg   [63:0] seed8, seed7, seed6, seed5, seed4, seed3, seed2, seed1;
   begin
      if (!offset[0]) begin
          seed8 = WORD8 ^ {16{offset}};
          seed7 = WORD7 ^ {16{offset}};
          seed6 = WORD6 ^ {16{offset}};
          seed5 = WORD5 ^ {16{offset}};
          seed4 = WORD4 ^ {16{offset + 1'b1}};
          seed3 = WORD3 ^ {16{offset + 1'b1}};
          seed2 = WORD2 ^ {16{offset + 1'b1}};
          seed1 = WORD1 ^ {16{offset + 1'b1}};
      end else begin
          seed8 = WORD4 ^ {16{offset}};
          seed7 = WORD3 ^ {16{offset}};
          seed6 = WORD2 ^ {16{offset}};
          seed5 = WORD1 ^ {16{offset}};
          seed4 = WORD8 ^ {16{offset + 1'b1}};
          seed3 = WORD7 ^ {16{offset + 1'b1}};
          seed2 = WORD6 ^ {16{offset + 1'b1}};
          seed1 = WORD5 ^ {16{offset + 1'b1}};
      end
      pkt_data = {seed8, seed7, seed6, seed5, seed4, seed3, seed2, seed1};
   end
   endfunction
   reg                         rcv_pkt_valid   = 1'b0;
   reg [3:0]                   rcv_num_valid_top   = 4'h0;
   reg [3:0]                   rcv_num_valid_mid   = 4'h0;
   reg [1:0]                   rcv_pkt_sop     = 2'b00;
   // Packet Checker
   reg                         rcv_pkt_pld     = 1'b0;
   reg [64*INTERNAL_WORDS-1:0] rcv_pkt_data    = {64*INTERNAL_WORDS{1'b0}};
   reg [7:0]                   rcv_pkt_ch_num  = 8'h0;
   reg [7:0]                   exp_pkt_ch_num;
   reg [3:0]                   rcv_pkt_eopbits = 4'h0;
   reg [7:0]                   exp_pkt_cnt     = 8'h0;
   reg [3:0]                   offset;

   wire [64*INTERNAL_WORDS-1:0] exp_sop_data;
   wire [64*INTERNAL_WORDS-1:0] exp_eop_data;
   reg [INTERNAL_WORDS-1:0] [8*INTERNAL_WORDS-1:0] exp_pld_data;
   reg  [64*INTERNAL_WORDS-1:0] exp_data;

   reg sop_data_error = 1'b0;
   reg eop_data_error = 1'b0;
   reg pld_data_error = 1'b0;
   reg ch_num_error   = 1'b0;
   reg        data_error     = 1'b0;

   wire [64-1:0] word1, word2, word3, word4, word5, word6, word7, word8;
   
   assign exp_sop_data = {word8, word7, word6, word5, word4, word3, word2, word1[8*INTERNAL_WORDS-1:8], exp_pkt_cnt};
   assign exp_eop_data = {word1, word2, word3, word4, word5, word6, word7, word8};

   wire [INTERNAL_WORDS-1:0] match;
   wire                      match_dual_mid;
   reg                       data_match;
   generate 
     for (i= 0; i< INTERNAL_WORDS; i=i+1) begin :eq
       assign match[i] =  (rcv_pkt_data[64*(i+1)-1 : i*64] == exp_data[64*(i+1)-1 : i*64]);
      end
   endgenerate
   assign match_dual_mid = (rcv_pkt_data[255:0]== {WORD8, WORD7, WORD6, WORD5}) & rcv_pkt_sop[0]; 
   always @(*) begin
      data_match = 1'b0;   
      case (rcv_num_valid_top[3:0])
         4'h1: data_match = (match[7]   == 1'b1)  && (!rcv_pkt_sop[0]|match_dual_mid); 
         4'h2: data_match = (match[7:6] == 2'b11) && (!rcv_pkt_sop[0]|match_dual_mid); 
         4'h3: data_match = (match[7:5] == 3'h7)  && (!rcv_pkt_sop[0]|match_dual_mid); 
         4'h4: data_match = (match[7:4] == 4'hf)  && (!rcv_pkt_sop[0]|match_dual_mid); 
         4'h5: data_match = (match[7:3] == 5'h1f);
         4'h6: data_match = (match[7:2] == 6'h3f);
         4'h7: data_match = (match[7:1] == 7'h7f);
         4'h8: data_match = (match[7:0] == 8'hff);
      endcase
   end

   always @(posedge clk) begin
      rcv_pkt_valid   <= |irx_num_valid;
      rcv_num_valid_top   <= irx_num_valid[7:4];
      rcv_num_valid_mid   <= irx_num_valid[3:0];
      rcv_pkt_sop     <= irx_sop;
      rcv_pkt_data    <= irx_dout_words;
      rcv_pkt_ch_num  <= irx_chan;
      rcv_pkt_eopbits <= irx_eopbits;
   end

   always @(posedge clk or posedge tx_usr_srst) begin
      if (tx_usr_srst) begin
         exp_pkt_cnt    <= 8'h0;
         exp_pkt_ch_num <= 8'h0;
         offset         <= 4'h0;
         exp_data       <= pkt_data(4'h0);
         rcv_pkt_pld    <= 1'b0;
         sop_data_error <= 1'b0;
         ch_num_error   <= 1'b0;
         sop_data_error <= 1'b0;
         pld_data_error <= 1'b0;
         eop_data_error <= 1'b0;
         data_error     <= 1'b0;
         err_cnt        <= 32'h0;
         checker_errors <= 4'h0;
      end
      else begin

         exp_data       <= pkt_data(offset);


         if (|irx_num_valid[7:4] & |irx_eopbits)
            if (irx_sop[0]) offset      <= 4'h1;
            else            offset      <= 4'h0;
         else if (~|irx_eopbits & |irx_num_valid[7:0]) begin
            if (irx_num_valid[7:0] == 8'h40)
               offset      <= offset + 1'b1;
            else if (irx_num_valid[7:0] == 8'h80 || irx_num_valid[7:0] == 8'h44)
               offset      <= offset + 2'b10;
            end
         if (|rcv_pkt_sop && rcv_pkt_valid) begin
            exp_pkt_ch_num <= exp_pkt_ch_num + 1'b1;
         end

         if (rx_lanes_aligned && rcv_pkt_valid && |rcv_pkt_sop) begin
            if (!(rcv_pkt_ch_num == exp_pkt_ch_num)) begin
               ch_num_error <= 1'b1;
               // synthesis translate_off
               $display(" ERROR: Received Ch # %3d", rcv_pkt_ch_num);
               $display("        Expected Ch # %3d", exp_pkt_ch_num);
               // synthesis translate_on
            end
            else begin
               ch_num_error <= 1'b0;
            end
         end



         if (rx_lanes_aligned && rcv_pkt_valid && |rcv_pkt_sop) begin
            exp_pkt_cnt <= exp_pkt_cnt + 1'b1;
         end

         if (rx_lanes_aligned && rcv_pkt_valid) begin
           if (!data_match) begin

               data_error <= 1'b1;
               // synthesis translate_off
               $display(" ERROR: PKT # %3d; Received  data %x", exp_pkt_cnt, rcv_pkt_data);
               $display("                   Expected  data %x", exp_data);
               // synthesis translate_on
            end
            else begin
               data_error <= 1'b0;
            end
         end

         if (ch_num_error || data_error) begin
            err_cnt <= err_cnt + 1'b1;
            // synthesis translate_off
            $display("TEST FAILED!");
            #1000
            $finish;
            // synthesis translate_on
         end
         if (err_read) begin
            checker_errors <= 4'h0;
         end
         else if (sop_data_error || ch_num_error || pld_data_error || eop_data_error || data_error) begin
         checker_errors <= {sop_data_error, ch_num_error, pld_data_error, eop_data_error};
         end
      end
   end

   // cursory check for sop, eop
   reg [31:0] sop_cntr_r;
   reg [31:0] eop_cntr_r;

   always @(posedge clk) begin
      if (tx_usr_srst) begin
         sop_cntr_r <= 32'h0;
         eop_cntr_r <= 32'h0;
      end
      else begin
         if (!(rx_lanes_aligned)) begin
            sop_cntr_r <= 32'h0;
            eop_cntr_r <= 32'h0;
         end
         else begin
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
         always @(posedge clk) begin
            if (tx_usr_srst) begin
               crc32_err_cnt[(i+1)*8-1:i*8] <= 8'h0;
            end
            else if (crc32_err[i]) begin
               crc32_err_cnt[(i+1)*8-1:i*8] <= crc32_err_cnt[(i+1)*8-1:i*8] + 1'b1;
            end
         end
      end
   endgenerate

   // count CRC 24 errors
   always @(posedge clk) begin
      if (rx_usr_srst) begin
         crc24_err_cnt <= 16'h0;
      end
      else begin
         crc24_err_cnt <= crc24_err_cnt + crc24_err;
      end
   end

   // sticky flag FIFO errors
   always @(posedge clk) begin
      if (tx_usr_srst) begin
         itx_overflow_sticky <= 1'b0;
      end
      else begin
         itx_overflow_sticky <= itx_overflow_sticky | itx_overflow;
      end
   end

   // sticky flag FIFO errors
   always @(posedge clk) begin
      if (tx_usr_srst) begin
         itx_underflow_sticky <= 1'b0;
      end
      else begin
         itx_underflow_sticky <= itx_underflow_sticky | itx_underflow;
      end
   end

   // sticky flag FIFO errors
   always @(posedge clk) begin
      if (rx_usr_srst)
         irx_overflow_sticky <= 1'b0;
      else
         irx_overflow_sticky <= irx_overflow_sticky | irx_overflow;
   end

   // sticky flag FIFO errors
   always @(posedge clk) begin
      if (rx_usr_srst) begin
         rdc_overflow_sticky <= 1'b0;
      end
      else begin
         rdc_overflow_sticky <= rdc_overflow_sticky | rdc_overflow;
      end
   end

endmodule
