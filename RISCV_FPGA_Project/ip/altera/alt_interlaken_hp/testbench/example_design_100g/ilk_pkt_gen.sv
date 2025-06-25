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



// Interlaken Packets Generator

`timescale 1ps/1ps

module ilk_pkt_gen #(
   parameter INTERNAL_WORDS = 8,
   parameter CALENDAR_PAGES = 4,
   parameter TX_PKTMOD_ONLY = 0,
   parameter TX_DUAL_SEG    = 1,
   parameter PKT_SIZE       = 14'd65,
   parameter BURST_SIZE     = 14'd128,
   parameter DUAL_SEG_SIZE  = 14'd65
)(
   input                              clk,
   input                              rx_lanes_aligned,
   input                              itx_ready,
   input                              send_data,
   input                              rx_usr_srst,
   input                              tx_usr_srst,
   input                              srst_rx_common,
   input                              srst_tx_common,

   output reg [64*INTERNAL_WORDS-1:0] itx_din_words,
   output                       [7:0] itx_num_valid, //bit 7:4 is aligned with top. 3:0 is aligned with mid.  
   output reg                   [7:0] itx_chan,
   output reg                   [1:0] itx_sop,      //bit 1 is aligned with top bit 0 is aligned with mid
   output reg                   [1:0] itx_sob,
   output reg                         itx_eob,
   output reg                   [3:0] itx_eopbits,

   output reg                  [31:0] tx_sop_cnt,
   output reg                  [31:0] tx_eop_cnt
);


   localparam INIT    = 3'h0,
              START   = 3'h1,
              SHORT   = 3'h2,
              SOP     = 3'h3,
              PLD     = 3'h4,
              EOP     = 3'h5,
              GAP     = 3'h6,
              EOP_SOP = 3'h7;

   localparam [7:0] MAX_GAP_LEN   = 0;
   localparam [9:0] MAX_CNT_SHORT = 0;
   localparam [13:0] LFSR_INIT    = 65;
   localparam [3:0] EOP_NUM_VALID = 1;
   localparam       RANDOM_SIZE   = 0;

   reg [2:0] tx_state = INIT;
   reg [2:0] tx_state_r;
   reg [7:0] pkt_cnt = 8'h0;
   reg [3:0] offset;
   reg [3:0] itx_num_valid_mid;
   reg [3:0] itx_num_valid_top;

   localparam [8*INTERNAL_WORDS-1:0] WORD8 = 64'h 7776757473727170;
   localparam [8*INTERNAL_WORDS-1:0] WORD7 = 64'h 6766656463626160;
   localparam [8*INTERNAL_WORDS-1:0] WORD6 = 64'h 5756555453525150;
   localparam [8*INTERNAL_WORDS-1:0] WORD5 = 64'h 4746454443424140;
   localparam [8*INTERNAL_WORDS-1:0] WORD4 = 64'h 3736353433323130;
   localparam [8*INTERNAL_WORDS-1:0] WORD3 = 64'h 2726252423222120;
   localparam [8*INTERNAL_WORDS-1:0] WORD2 = 64'h 1716151413121110;
   localparam [8*INTERNAL_WORDS-1:0] WORD1 = 64'h 0706050403020100;

// reg [INTERNAL_WORDS-1:0] [8*INTERNAL_WORDS-1:0] word;

   reg [13:0] pkt_size;
   wire        lfsr_fb;

   wire         init_gen_pre;
   wire         init_gen;
   reg   [7:0]  gap_ind       = 8'h0;
   reg   [7:0]  gap_len       = MAX_GAP_LEN;
   reg   [9:0]  short_pkt_cnt = MAX_CNT_SHORT;
   reg   [3:0]  eop_num_valid = EOP_NUM_VALID;
   reg   [3:0]  eopbits;
   reg   [7:0]  pld_cnt;
   reg   [7:0]  pld_cnt_minus32;
   reg   [7:0]  max_pld_cnt;
   reg   [7:0]  max_pld_cnt_minus32;
   reg   [3:0]  eop_num_valid_minus32;
   reg   [3:0]  eopbits_minus32;
   reg          mid_sop_on;

   assign itx_num_valid = {itx_num_valid_top, itx_num_valid_mid};
   assign init_gen_pre = !(rx_lanes_aligned && send_data) || rx_usr_srst || tx_usr_srst || srst_rx_common ||srst_tx_common;

   ilk_status_sync #(.WIDTH (1)) init_gen_sync (.clk(clk),.din(init_gen_pre),.dout(init_gen));

   generate
     if (TX_PKTMOD_ONLY) begin
        assign itx_sob = 2'b00;
        assign itx_eob = 1'b0;
     end else begin
        assign itx_sob = itx_sop;
        assign itx_eob = |itx_eopbits;
     end
   endgenerate

   // Pseudo-random packet sizes generator
   always @(posedge clk or posedge tx_usr_srst) begin
      if (tx_usr_srst == 1'b1) begin
         pkt_size   <= LFSR_INIT;
         tx_state_r <= 3'h0;
      end
      else begin
         tx_state_r <= tx_state;
         if (|itx_eopbits && |itx_num_valid && tx_state_r != SHORT && itx_ready == 1'b1) begin
            if (TX_PKTMOD_ONLY) begin
                if (TX_DUAL_SEG)
                     pkt_size <= DUAL_SEG_SIZE;           //If dual segment selected, automatically generate packet size like 65 byte.
                else if (RANDOM_SIZE)              
                     pkt_size <= {pkt_size[6:0], lfsr_fb};  //Random Packet size.
                else pkt_size <= PKT_SIZE;                //Other packet size user selected.
            end
            else begin                                    //Burst interleave mode
                if (TX_DUAL_SEG)
                     pkt_size <= DUAL_SEG_SIZE;          //If dual segment selected, automatically generate burst size like 65 byte.
                else pkt_size <= BURST_SIZE;             //Other burst size.
            end
         end
      end
   end

   wire [13:0] pkt_size_minus32 = pkt_size - 6'd32;
   always @* begin
      if (~|pkt_size[5:0])
          eop_num_valid = 4'h8;
      else
          eop_num_valid = |pkt_size[2:0] + pkt_size[5:3];
      eopbits = ({1'b1, pkt_size[2:0]});
      if (pkt_size > 14'd128) begin
        max_pld_cnt = (|pkt_size[5:0]) ? (pkt_size[13:6] - 1'b1) : (pkt_size[13:6] - 2'b10); 
      end else begin 
        max_pld_cnt = 8'h0;
      end

      if (~|pkt_size_minus32[5:0])
         eop_num_valid_minus32 = 4'h8;
      else
         eop_num_valid_minus32 = |pkt_size_minus32[2:0] + pkt_size_minus32[5:3];
      eopbits_minus32 = ({1'b1, pkt_size_minus32[2:0]});
      if (pkt_size_minus32 > 14'd64) begin
        max_pld_cnt_minus32 = (|pkt_size_minus32[5:0]) ? (pkt_size_minus32[13:6]) : (pkt_size_minus32[13:6] - 1'b1);
      end else begin
        max_pld_cnt_minus32 = 8'h0;
      end
   end

   assign lfsr_fb = (pkt_size[7] ~^ pkt_size[5] ~^ pkt_size[4] ~^ pkt_size[3]);

   // Packet Generator
   always @(posedge clk or posedge tx_usr_srst) begin

      if (tx_usr_srst) begin
         tx_state      <= INIT;
         itx_chan      <= 8'h0;
         pkt_cnt       <= 8'h0;
         itx_sop       <= 2'b00;
         itx_eopbits   <= 4'h0;
         offset        <= 4'h0;
         itx_din_words <= {64*INTERNAL_WORDS{1'b0}};
         itx_num_valid_top <= 4'h0;
         itx_num_valid_mid <= 4'h0;
         short_pkt_cnt <= MAX_CNT_SHORT;
         gap_len       <= MAX_GAP_LEN;
         gap_ind       <= 8'h0;
         mid_sop_on    <= 1'b0;
         pld_cnt       <= 8'h0;

      end
      else begin
         itx_sop           <= 2'b0;
         itx_eopbits       <= 4'h0;
         itx_num_valid_top <= 4'h0;
         itx_num_valid_mid <= 4'h0;
         pld_cnt           <= 8'h0;
         case (tx_state)
            // 0; Wait until generator initialization is finished and/or core is ready to accept the traffic
            INIT    : begin
                         offset           <= 4'h0;
                         mid_sop_on       <= 1'b0;
                         if (init_gen || !itx_ready) begin
                            tx_state      <= INIT;
                            itx_sop       <= 2'b0;
                            itx_eopbits   <= 4'h0;
                            itx_din_words <= {64*INTERNAL_WORDS{1'b0}};
                            itx_num_valid_top <= 4'h0;
                            gap_len       <= MAX_GAP_LEN;
                            gap_ind       <= 8'h0;
                            itx_chan      <= itx_chan;
                         end
                         else begin
                            tx_state <= START;
                            itx_chan <= itx_chan;
                         end
                      end
            // 1; Select the mode of operation;
            START   : begin
                         mid_sop_on       <= 1'b0;
                         itx_num_valid_top <= 4'h8;
                         itx_eopbits   <= 4'h0;
                         tx_state      <= EOP;
                         offset        <= offset + 2'b10;
            //           itx_din_words <= {WORD8, WORD7, WORD6, WORD5, WORD4, WORD3, WORD2, WORD1[8*INTERNAL_WORDS-1:8], pkt_cnt};
                         itx_din_words <= pkt_data(offset);
                         itx_sop       <= 2'b10;
                      end
            // 2; Generate packet of one block (64 or less bytes)
            SHORT   : begin
                         mid_sop_on       <= 1'b0;
                         if (itx_ready) begin
                            offset        <= 4'h0;
             //             itx_din_words <= {WORD8, WORD7, WORD6, WORD5, WORD4, WORD3, WORD2, WORD1[8*INTERNAL_WORDS-1:8], pkt_cnt};
                            itx_din_words <= pkt_data(offset);
                            itx_num_valid_top <= 4'h8;
                            itx_eopbits   <= 4'hc;
                            itx_sop       <= 2'b10;
                            pkt_cnt       <= pkt_cnt + 1'b1;
                            itx_chan      <= itx_chan + 1'b1;

                            itx_chan      <= itx_chan + 1'b1;
                            if (!gap_len) begin
                               gap_len  <= MAX_GAP_LEN;
                               tx_state <= SOP;
                            end
                            else begin
                               tx_state <= GAP;
                            end

                            short_pkt_cnt <= short_pkt_cnt - 1'b1;
                         end
                         else begin
                            itx_num_valid_top <= 4'h0;
                         end
                      end
            // 3
            SOP     : begin
                         itx_num_valid_mid <= 4'h0;
                         mid_sop_on       <= 1'b0;
                         if (itx_ready) begin
                            offset        <= offset + 2'b10;
                            itx_din_words <= pkt_data(offset);
                            itx_sop       <= 2'b10;
                            itx_chan <= itx_chan + 1'b1;
                            itx_num_valid_top <= 4'h8;
                            itx_eopbits   <= 4'h0;

                            if (max_pld_cnt == 8'h0) begin
                                if (TX_DUAL_SEG & (eop_num_valid <4'h5)) begin
                                   tx_state <= EOP_SOP;
                                end else tx_state <= EOP;
                            end
                            else begin
                               tx_state <= PLD;
                               pld_cnt  <= max_pld_cnt - 1'b1;
                            end
                         end
                         else begin
                             itx_num_valid_top <= 4'h0;
                         end
                      end
            // 4
            PLD     : begin
                         tx_state <= PLD;
                         if (itx_ready) begin
                            itx_sop       <= 2'b0;
                            itx_num_valid_top <= 4'h8;
                            offset        <= offset + 2'b10;
                            itx_din_words <= pkt_data(offset);
                            if (pld_cnt == 8'h0) begin
                               if (mid_sop_on) 
                                   tx_state <= (eop_num_valid_minus32 < 4'h5) ? EOP_SOP :EOP;
                               else
                                   tx_state <= (eop_num_valid < 4'h5) ? EOP_SOP :EOP;
                            end
                            else begin
                               pld_cnt <= pld_cnt - 1'b1;
                            end
                         end
                         else begin
                            itx_num_valid_top <= 4'h0;
                            pld_cnt <= pld_cnt;
                         end
                      end
            // 5
            EOP     : begin
                         mid_sop_on <= 1'b0;
                         itx_sop <= 2'b00;
                         itx_num_valid_mid <= 4'h0;
                         if (itx_ready) begin
                            offset  <= 4'h0;
                            itx_din_words <= pkt_data(offset);
                            if (mid_sop_on) begin
                              itx_num_valid_top <= eop_num_valid_minus32;
                              itx_eopbits   <= eopbits_minus32;
                            end
                            else begin
                              itx_num_valid_top <= eop_num_valid;
                              itx_eopbits   <= eopbits;
                            end

                            pkt_cnt <= pkt_cnt + 1'b1;

                            if (init_gen) begin
                               itx_chan <= itx_chan + 1'b1;
                               tx_state <= INIT;
                            end
                            else if (!gap_len) begin
                               gap_len <= MAX_GAP_LEN;
                               if (!short_pkt_cnt) begin
                                  short_pkt_cnt <= MAX_CNT_SHORT;
                                  tx_state      <= SHORT;
                               end
                               else begin
                                  short_pkt_cnt <= short_pkt_cnt - 1'b1;
                                  tx_state      <= SOP;
                               end
                            end
                            else begin
                               tx_state <= GAP;
                            end
                         end
                         else begin
                            itx_num_valid_top <= 4'h0;
                         end
                      end
            // 6
            GAP     : begin
                         itx_sop       <= 2'b0;
                         itx_eopbits   <= 4'h0;
                         itx_num_valid_top <= 4'h0;
                         if (itx_ready) begin
                            if (gap_ind < gap_len)
                               gap_ind <= gap_ind + 1'b1;
                            else begin
                               gap_len <= gap_len - 1'b1;
                               gap_ind <= 8'h0;
                               if (!short_pkt_cnt) begin
                                  short_pkt_cnt <= MAX_CNT_SHORT;
                                  tx_state      <= SHORT;
                               end
                               else begin
                                  short_pkt_cnt <= short_pkt_cnt - 1'b1;
                                  tx_state      <= SOP;
                               end
                            end
                         end
                      end
            EOP_SOP  : begin
                         mid_sop_on <= 1'b1;
                         if (max_pld_cnt_minus32 == 8'h0) tx_state <= EOP;
                         else  begin                            
                             tx_state   <= PLD;
                             pld_cnt    <= max_pld_cnt_minus32 - 1'b1;
                         end
                         if (mid_sop_on) begin
                           itx_num_valid_top <= eop_num_valid_minus32;
                           itx_eopbits       <= eopbits_minus32; 
                         end else begin
                           itx_num_valid_top <= eop_num_valid;
                           itx_eopbits       <= eopbits;
                         end
                         offset         <= 4'h1;
                         itx_num_valid_mid <= 4'h4;
                         itx_din_words[511:256] <=  pkt_data(offset) >> 256;
                         itx_din_words[255:0] <= {WORD8, WORD7, WORD6, WORD5};
                         itx_sop[1:0]  <= 2'b01;
                         itx_chan <= itx_chan + 1'b1;
                       end
            default : tx_state <= INIT;
         endcase
      end
   end

   // Counters
   always @(posedge clk or posedge tx_usr_srst) begin
      if (tx_usr_srst) begin
         tx_sop_cnt <= 32'h0;
         tx_eop_cnt <= 32'h0;
      end
      else begin
        if (|itx_sop && |itx_num_valid) begin
            tx_sop_cnt <= tx_sop_cnt + 1'b1;
         end

         if (itx_eopbits[3] && itx_num_valid_top) begin
            tx_eop_cnt <= tx_eop_cnt + 1'b1;
         end
      end
   end

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

endmodule
