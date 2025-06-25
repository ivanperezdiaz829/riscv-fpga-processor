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
  parameter TX_PKTMOD_ONLY = 1,
  parameter INTERNAL_WORDS = 8,
  parameter LOG_INTE_WORDS = 4,
  parameter CALENDAR_PAGES = 4
)(
  input                              clk,
  input                              rx_lanes_aligned,
  input                              itx_ready,
  input                              send_data,
  input                              reconfig_done,
  input                              rx_usr_srst,
  input                              tx_usr_srst,
  input                              srst_rx_common,
  input                              srst_tx_common,

  input                              start_ch_wr,
  input                        [7:0] start_channel,
  input                        [7:0] num_channels,

  input                              gaps_en,
  input                       [13:0] cpu_pkt_size_min,
  input                       [13:0] cpu_pkt_size_step,
  input                       [13:0] cpu_pkt_size_max,
  input                        [1:0] cpu_run_mode,
  input                       [15:0] cpu_pkts_to_run,
  input                        [9:0] cpu_int_burst_size,

  output reg [64*INTERNAL_WORDS-1:0] itx_din_words,
  output reg    [LOG_INTE_WORDS-1:0] itx_num_valid,
  output reg                   [7:0] itx_chan,
  output reg                         itx_sop,
  output reg                         itx_sob,
  output reg                         itx_eob,
  output reg                   [3:0] itx_eopbits,

  output reg                  [31:0] tx_sop_cnt,
  output reg                  [31:0] tx_eop_cnt,

  input                              get_latency,
  output reg                         start_latency_cnt,
  output reg                   [7:0] latency_cnt_id
);

  localparam NUM_VALID = (INTERNAL_WORDS == 8) ? 4'h8 : 3'h4;

  localparam START = 3'h0,
             SHORT = 3'h1,
             SOP   = 3'h2,
             PLD   = 3'h3,
             EOP   = 3'h4,
             GAP   = 3'h5;

  localparam UP = 1'b0, DN = 1'b1;

  localparam [9:0] MAX_CNT_SHORT = 3;
  localparam [7:0] LFSR_INIT0    = 153;
  localparam [7:0] LFSR_INIT1    = 79;
  localparam [7:0] LFSR_INIT2    = 13;
  localparam [7:0] LFSR_INIT3    = 111;

  function reg [7:0] get_ch_id;
    input reg [7:0] this_ch, start_ch, num_ch;
    begin
      get_ch_id = (start_ch != num_ch) ? ((this_ch < (start_ch + num_ch)) ? this_ch + 1'b1 : start_ch) : start_ch;
    end
  endfunction

  reg [2:0] tx_state = START;
  reg [2:0] tx_state_r;
  reg [7:0] pkt_cnt = 8'h0;

  wire [8*INTERNAL_WORDS-1:0] word8 = (INTERNAL_WORDS == 8) ? 64'h 7776757473727170 : 32'h73727170;
  wire [8*INTERNAL_WORDS-1:0] word7 = (INTERNAL_WORDS == 8) ? 64'h 6766656463626160 : 32'h63626160;
  wire [8*INTERNAL_WORDS-1:0] word6 = (INTERNAL_WORDS == 8) ? 64'h 5756555453525150 : 32'h53525150;
  wire [8*INTERNAL_WORDS-1:0] word5 = (INTERNAL_WORDS == 8) ? 64'h 4746454443424140 : 32'h43424140;
  wire [8*INTERNAL_WORDS-1:0] word4 = (INTERNAL_WORDS == 8) ? 64'h 3736353433323130 : 32'h33323130;
  wire [8*INTERNAL_WORDS-1:0] word3 = (INTERNAL_WORDS == 8) ? 64'h 2726252423222120 : 32'h23222120;
  wire [8*INTERNAL_WORDS-1:0] word2 = (INTERNAL_WORDS == 8) ? 64'h 1716151413121110 : 32'h13121110;
  wire [8*INTERNAL_WORDS-1:0] word1 = (INTERNAL_WORDS == 8) ? 64'h 0706050403020100 : 32'h03020100;

  reg [64*INTERNAL_WORDS-1:0] word;

  reg [13:0] pkt_size, pkt_size_d;

  reg  [7:0] pkt_size_rnd       = LFSR_INIT0;
  reg  [7:0] inter_pkt_gap_size = LFSR_INIT1;
  reg  [7:0] in_pkt_gap_size    = LFSR_INIT2;
  reg  [7:0] in_pkt_data_size   = LFSR_INIT3;

  reg        gen_pkt_size;
  wire       lfsr_fb0, lfsr_fb1, lfsr_fb2, lfsr_fb3;

  wire       init_gen;
  wire       init_gen_s;

  reg                 [8:0] gap_ind        = 9'h0;
  reg                 [8:0] word_ind       = 9'h0;
  reg                 [8:0] word_ind_pre   = 9'h0;
  reg                 [9:0] short_pkt_cnt  = MAX_CNT_SHORT;
  reg                 [3:0] short_pkt_sent = 4'b0;
  reg  [LOG_INTE_WORDS-1:0] eop_num_valid  = INTERNAL_WORDS;
  reg                 [8:0] burst_cnt;
  reg                       hold_cnt;
  reg                       set_new_ch;
  reg                       got_new_ch;
  reg                 [7:0] start_ch;

  assign init_gen = !(rx_lanes_aligned && send_data && reconfig_done) ||
                                                          rx_usr_srst ||
                                                          tx_usr_srst ||
                                                       srst_rx_common ||
                                                       srst_tx_common;

  ilk_status_sync #(.WIDTH (1)) ss0 (.clk (clk), .din (init_gen), .dout (init_gen_s));

  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      set_new_ch <= 1'b0;
      start_ch   <= {8{1'b0}}; //start_channel;
    end else begin
      if (start_ch_wr) begin
        start_ch <= start_channel;
      end
      if (start_ch_wr) begin
        set_new_ch <= 1'b1;
      end else if (got_new_ch) begin
        set_new_ch <= 1'b0;
      end
    end
  end

  // Packet size generator
  localparam PSG_INIT = 1'b0,
             PSG_SIZE = 1'b1;

  localparam PKT_INIT   = (INTERNAL_WORDS == 8) ? 'd64 : 'd32;
  localparam PKT_INIT_1 = (INTERNAL_WORDS == 8) ? 'd63 : 'd31;
  localparam PKT_INIT_2 = (INTERNAL_WORDS == 8) ? 'd6  : 'd5;

  reg                       direction = UP;
  reg                [13:0] pkt_size_min, pkt_size_max;
  reg  [LOG_INTE_WORDS+1:0] last_block_min, last_block_max;
  reg  [LOG_INTE_WORDS+1:0] eop_bytes, eop_bytes_d, eop_bytes_d2, eop_word_max;
  reg                 [3:0] pkt_size_step;
  reg                 [1:0] run_mode;
  reg                [15:0] pkts_to_run;
  reg                       pkt_size_sm;
  reg                [15:0] num_pkts_to_run = 16'h0;
  reg                 [9:0] int_burst_size;

  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      direction      <= UP;
      int_burst_size <= 10'h4;
      gen_pkt_size   <= 1'b0;
      pkt_size_sm    <= PSG_INIT;
    end else begin
      tx_state_r <= tx_state;

      pkt_size_min   <= cpu_pkt_size_min >> PKT_INIT_2;// packet size in terms of blocks
      last_block_min <= cpu_pkt_size_min % PKT_INIT;   // size of the last block of data in terms of bytes
      pkt_size_step  <= cpu_pkt_size_step;             // bytes
      pkt_size_max   <= cpu_pkt_size_max >> PKT_INIT_2;
      last_block_max <= cpu_pkt_size_max % PKT_INIT;
      run_mode       <= cpu_run_mode;
      pkts_to_run    <= cpu_pkts_to_run - 1'b1;
      int_burst_size <= cpu_int_burst_size >> PKT_INIT_2; // burst size comes in bytes,
                                                          // but used in terms of 64 byte words

      eop_bytes_d    <= eop_bytes;

      if (init_gen_s) begin
        pkt_size_d   <= pkt_size;
        eop_bytes_d2 <= eop_bytes;
      end else if (itx_eopbits[3]) begin
        pkt_size_d   <= pkt_size;
        eop_bytes_d2 <= eop_bytes;
      end

      // Generate packets with random paket size
      eop_bytes    <= {LOG_INTE_WORDS+1{1'b0}};
      gen_pkt_size <= 1'b0;
      if (init_gen_s) begin
        pkt_size     <= (TX_PKTMOD_ONLY == 1) ? LFSR_INIT0 : cpu_pkt_size_max;
        gen_pkt_size <= 1'b0;
      end else if (itx_sop == 1'b1 && tx_state_r != SHORT && itx_ready == 1'b1) begin
        pkt_size     <= (TX_PKTMOD_ONLY == 1) ? ((pkt_size_rnd < int_burst_size) ? int_burst_size : {6'h0, pkt_size_rnd})
                                              : cpu_pkt_size_max;
        gen_pkt_size <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if (gen_pkt_size == 1'b1) begin
      pkt_size_rnd <= (!pkt_size_rnd) ? LFSR_INIT0 : {pkt_size_rnd[6:0], lfsr_fb0};
    end
  end

  always @(posedge clk) begin
    if (itx_sop == 1'b1 && tx_state_r != SHORT && itx_ready == 1'b1) begin
      inter_pkt_gap_size <= (gaps_en == 1'b1) ? {inter_pkt_gap_size[6:0], lfsr_fb1} : {8{1'b0}};
    end
  end

  // LFSR feedback bits
  assign lfsr_fb0 = (pkt_size[7] ~^ pkt_size[5] ~^ pkt_size[4] ~^ pkt_size[3]);
  assign lfsr_fb1 = (inter_pkt_gap_size[7] ~^ inter_pkt_gap_size[5] ~^ inter_pkt_gap_size[4] ~^ inter_pkt_gap_size[3]);
  assign lfsr_fb2 = (in_pkt_gap_size[7] ~^ in_pkt_gap_size[5] ~^ in_pkt_gap_size[4] ~^ in_pkt_gap_size[3]);
  assign lfsr_fb3 = (in_pkt_data_size[7] ~^ in_pkt_data_size[5] ~^ in_pkt_data_size[4] ~^ in_pkt_data_size[3]);

  localparam GEN_DATA = 1'b0,
             GEN_GAP  = 1'b1;

  reg [1:0] in_pkt_gap_state;
  reg       itx_data_valid;
  reg [8:0] in_pkt_gap_cnt;

  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      in_pkt_gap_state <= GEN_DATA;
      itx_data_valid   <= 1'b0;
      in_pkt_gap_cnt   <= 8'h0;
      in_pkt_gap_size  <= LFSR_INIT2;
      in_pkt_data_size <= LFSR_INIT3;
    end else begin
      if (gaps_en == 1'b1) begin
        if (itx_ready) begin
          if (tx_state == SOP || tx_state == PLD) begin
            case (in_pkt_gap_state)
              GEN_DATA : begin
                if (!in_pkt_gap_cnt) begin
                  itx_data_valid   <= 1'b1;
                  in_pkt_gap_cnt   <= in_pkt_gap_size;
                  in_pkt_gap_size  <= {in_pkt_gap_size[6:0],  lfsr_fb2};
                  in_pkt_gap_state <= GEN_GAP;
                end else begin
                  in_pkt_gap_cnt <= in_pkt_gap_cnt - 1'b1;
                end
              end
              GEN_GAP  : begin
                if (!in_pkt_gap_cnt) begin
                  itx_data_valid   <= 1'b0;
                  in_pkt_gap_cnt   <= in_pkt_data_size;
                  in_pkt_data_size <= {in_pkt_data_size[6:0], lfsr_fb3};
                  in_pkt_gap_state <= GEN_DATA;
                end else begin
                  in_pkt_gap_cnt <= in_pkt_gap_cnt - 1'b1;
                end
              end
            endcase
          end
        end
      end else begin
        in_pkt_gap_state <= GEN_DATA;
        itx_data_valid   <= 1'b1;
        in_pkt_gap_cnt   <= 8'h0;
        in_pkt_gap_size  <= {8{1'b0}};
        in_pkt_data_size <= {8{1'b0}};
      end
    end
  end

  // Packet Generator
  initial begin
    itx_chan      = {8{1'b0}};
    pkt_cnt       = {8{1'b0}};

    tx_state      = START;
    itx_sop       = 1'b0;
    itx_eopbits   = 4'h0;
    itx_din_words = {64*INTERNAL_WORDS{1'b0}};
    itx_num_valid = {LOG_INTE_WORDS{1'b0}};
    word_ind      = {9{1'b0}};
    word_ind_pre  = {9{1'b0}};
    gap_ind       = {9{1'b0}};
    word          = {word8, word7, word6, word5, word4, word3, word2, word1};

    tx_sop_cnt    = {32{1'b0}};
    tx_eop_cnt    = {32{1'b0}};
  end
 
  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      tx_state       <= START;

      itx_chan       <= {8{1'b0}}; //start_ch;
      short_pkt_sent <= 4'd0;
      short_pkt_cnt  <= MAX_CNT_SHORT;
      itx_sop        <= 1'b0;
      pkt_cnt        <= {8{1'b0}};
      itx_eopbits    <= 4'h0;
      itx_din_words  <= {64*INTERNAL_WORDS{1'b0}};
      itx_num_valid  <= {LOG_INTE_WORDS{1'b0}};
      eop_num_valid  <= INTERNAL_WORDS;
      gap_ind        <= 9'h0;
      word_ind       <= 9'h0;
      word_ind_pre   <= 9'h0;
      word           <= {word8, word7, word6, word5, word4, word3, word2, word1};

      itx_sob        <= 1'b0;
      itx_eob        <= 1'b0;
      burst_cnt      <= 9'h0;
      hold_cnt       <= 1'b0;
    end else begin
      case (tx_state)
        // 0; Wait until generator initialization is finished and/or core is ready to accept the traffic
        START   : begin
          if (set_new_ch) begin
            got_new_ch <= 1'b1;
            itx_chan   <= start_ch;
          end else begin
            got_new_ch <= 1'b0;
            if (((!int_burst_size && itx_sop && itx_eopbits[3]) || (int_burst_size && itx_sob && itx_eob)) && !hold_cnt) begin
              itx_chan <= get_ch_id(itx_chan, start_ch, num_channels);
            end
          end

          hold_cnt <= 1'b0;
          if (init_gen_s || !itx_ready) begin
            tx_state          <= START;
            itx_sop           <= 1'b0;
            itx_eopbits       <= 4'h0;
            itx_din_words     <= {64*INTERNAL_WORDS{1'b0}};
            itx_num_valid     <= {LOG_INTE_WORDS{1'b0}};
            short_pkt_cnt     <= (init_gen_s) ? MAX_CNT_SHORT : short_pkt_cnt;
            gap_ind           <= 9'h0;
            word_ind          <= 9'h0;
            word_ind_pre      <= 9'h0;
            word              <= {word8, word7, word6, word5, word4, word3, word2, word1};
            itx_sob           <= 1'b0;
            itx_eob           <= 1'b0;
          end else begin
              itx_num_valid <= NUM_VALID;
              itx_eopbits   <= 4'h0;
              if (int_burst_size <= 1) begin
                tx_state <= EOP;
              end else begin
                tx_state <= PLD;
              end

            itx_din_words <= {word8, word7, word6, word5, word4, word3, word2, word1[8*INTERNAL_WORDS-1:8], pkt_cnt};
            word          <= {word7, word6, word5, word4, word3, word2, word1, word8};
            itx_sop       <= 1'b1;
            pkt_cnt       <= pkt_cnt + 1'b1;
            if (!int_burst_size) begin
              itx_sob   <= 1'b0;
              itx_eob   <= 1'b0;
              burst_cnt <= 9'h0;
            end else begin
              itx_sob   <= (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
              itx_eob   <= (int_burst_size == 1 || !pkt_size || (pkt_size == 8'h1 && eop_bytes == 4'h0)) & (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
              burst_cnt <= int_burst_size - 1'b1;
            end
          end
        end
        // 1; Generate packet of one block (64 or less bytes)
        SHORT   : begin
          if (itx_ready) begin
            word_ind      <= 9'h0;
            word_ind_pre  <= 9'h0;
            itx_din_words <= {word8, word7, word6, word5, word4, word3, word2, word1[8*INTERNAL_WORDS-1:8], pkt_cnt};
            itx_sop       <= 1'b1;
            pkt_cnt       <= pkt_cnt + 1'b1;
            itx_chan      <= get_ch_id(itx_chan, start_ch, num_channels);
            if (!int_burst_size) begin // Packet mode (burst size is set to zero)
              itx_sob   <= 1'b0;
              itx_eob   <= 1'b0;
              burst_cnt <= 9'h0;
            end else if (short_pkt_sent == 4'd10) begin // Interleaving mode with short packets
              itx_sob   <= (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0; // send burst of short packets
              burst_cnt <= 9'h0; // reset burst size counter
            end else begin // Interleaving mode with long packets (bigger than burst size)
              itx_sob   <= (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0; // assert sob only when terminal count reached
              itx_eob   <= !burst_cnt & (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
              burst_cnt <= int_burst_size - 1'b1;
            end

              itx_num_valid <= NUM_VALID;
              itx_eopbits   <= 4'hC;
              if (short_pkt_sent == 4'd10) begin                            // Send back-to-back short packets (one or less data block in size)
                if (!short_pkt_cnt) begin                                   // All packets sent
                  short_pkt_sent <= 4'd0;
                  short_pkt_cnt  <= MAX_CNT_SHORT;
                  if (!inter_pkt_gap_size) begin
                    tx_state <= SOP;
                  end else begin
                    tx_state <= GAP;
                  end
                end else begin
                  short_pkt_cnt <= short_pkt_cnt - 1'b1;
                  tx_state      <= SHORT;
                end
              end else begin
                if (short_pkt_sent == 4'd9) begin
                  short_pkt_sent <= 4'd10;
                  short_pkt_cnt  <= 10'd1000;
                  tx_state       <= SHORT;
                end else begin
                  short_pkt_sent <= short_pkt_sent + 1'b1;
                  short_pkt_cnt  <= short_pkt_cnt - 1'b1;
                  if (!inter_pkt_gap_size) begin
                    tx_state <= SOP;
                  end else begin
                    tx_state <= GAP;
                  end
                end
              end

            if (init_gen_s) begin
               tx_state <= START;
            end
          end else begin
            itx_num_valid <= {LOG_INTE_WORDS{1'b0}};
          end
        end
        // 2
        SOP     : begin
          hold_cnt <= 1'b0;
          if (itx_ready) begin
            word_ind      <= ((TX_PKTMOD_ONLY == 0) & (itx_chan != num_channels)) ? word_ind_pre :9'h0;
            word_ind_pre  <= (itx_chan == num_channels) ? 9'h0 : word_ind_pre;
            itx_din_words <= {word8, word7, word6, word5, word4, word3, word2, word1[8*INTERNAL_WORDS-1:8], pkt_cnt};
            word          <= {word7, word6, word5, word4, word3, word2, word1, word8};
            itx_num_valid <= NUM_VALID;
            itx_sop       <= (TX_PKTMOD_ONLY == 0) ? (pkt_size_d < int_burst_size) | (itx_chan == num_channels) : 1'b1;
            pkt_cnt       <= pkt_cnt + ((TX_PKTMOD_ONLY == 0) ? ((pkt_size_d < int_burst_size) | (itx_chan == num_channels)) : 1'b1);

            if (direction == DN && pkt_size == 8'h1 && !pkt_size_min && eop_bytes == 'd1) begin
              itx_eopbits <= 4'h8;
            end else begin
              itx_eopbits <= 4'h0;
            end

            itx_chan  <= get_ch_id(itx_chan, start_ch, num_channels);
            itx_sob   <= (!int_burst_size) ? 1'b0 : (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
            burst_cnt <= (!int_burst_size) ? 9'h0 : int_burst_size-1'b1;

            if (direction == DN && pkt_size == 8'h1 && !pkt_size_min && eop_bytes == 'd1) begin
              itx_eob  <= (!int_burst_size) ? 1'b0 : (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
              tx_state <= SHORT;
            end else if (pkt_size == 8'h0) begin
              itx_eob  <= 1'b0;
              tx_state <= EOP;
            end else begin
              itx_eob  <= 1'b0;
              tx_state <= PLD;
            end
          end else begin
            itx_num_valid <= {LOG_INTE_WORDS{1'b0}};
          end
        end
        // 3
        PLD     : begin
          if (itx_ready) begin
            itx_sop  <= 1'b0;
            hold_cnt <= 1'b0;
            if (itx_data_valid) begin
            //itx_chan <= (!burst_cnt && !hold_cnt && int_burst_size) ? get_ch_id(itx_chan, start_ch, num_channels) : itx_chan;
              itx_chan <= (!burst_cnt && !hold_cnt && (TX_PKTMOD_ONLY == 0)) ? get_ch_id(itx_chan, start_ch, num_channels) : itx_chan;

              if (pkt_size == 8'h0) begin

                itx_sob          <= (!int_burst_size) ? 1'b0 : (!burst_cnt & (TX_PKTMOD_ONLY == 0)) ? 1'b1 : 1'b0;
                itx_eob          <= (!int_burst_size) ? 1'b0 : (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;

                burst_cnt        <= 9'h0;
                itx_num_valid    <= (direction==UP) ? ((eop_bytes_d-1'b1) >> 3) + 1'b1 : ((eop_bytes-1'b1) >> 3) + 1'b1;
                itx_eopbits[3]   <= 1'b1;
                itx_eopbits[2:0] <= eop_bytes % 8;
                word_ind         <= 9'h0;
                word_ind_pre     <= 9'h0;
                itx_din_words    <= {word1, word2, word3, word4, word5, word6, word7, word8};
                word             <= {word7, word6, word5, word4, word3, word2, word1, word8};
                tx_state         <= SOP;
              end else begin
                if (!int_burst_size) begin
                  itx_sob   <= 1'b0;
                  itx_eob   <= 1'b0;
                  burst_cnt <= 9'h0;
                end else begin
                  itx_sop   <= ((TX_PKTMOD_ONLY == 0) & !word_ind_pre & (itx_chan != num_channels)) ? (!burst_cnt) : 1'b0;
                  itx_sob   <= (!burst_cnt & (TX_PKTMOD_ONLY == 0)) ? 1'b1 : 1'b0;
                  itx_eob   <= (burst_cnt == 9'h1) & (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
                  burst_cnt <= (!burst_cnt) ? int_burst_size - 1'b1 : burst_cnt - 1'b1;
                  pkt_cnt   <= pkt_cnt + ((TX_PKTMOD_ONLY == 0) & !word_ind_pre & (itx_chan != num_channels) & !burst_cnt);
                end

                itx_num_valid <= NUM_VALID;
                
                if ((TX_PKTMOD_ONLY == 0) & !word_ind_pre & (itx_chan != num_channels) & !burst_cnt) begin
                  itx_din_words <= {word8, word7, word6, word5, word4, word3, word2, word1[8*INTERNAL_WORDS-1:8], pkt_cnt};
                  word          <= {word7, word6, word5, word4, word3, word2, word1, word8};
                end else begin
                  itx_din_words <= word;
                  word          <= {word[6], word[5], word[4], word[3], word[2], word[1], word[0], word[7]};
                end

                if (((word_ind+2) >= pkt_size_d) ||
                    ((word_ind+3) >= pkt_size_d && !eop_bytes_d2)) begin  // PLD less SOP and EOP words
                  word_ind <= 9'h0;
                  word_ind_pre <= word_ind_pre;
                  tx_state <= EOP;
                end else begin
                  word_ind <= ((TX_PKTMOD_ONLY == 0) & (itx_chan != num_channels) & (burst_cnt == 9'h0)) ? word_ind_pre : word_ind + 1'b1;
                  word_ind_pre <= ((itx_chan == num_channels) & (burst_cnt == 9'h0)) ? word_ind + 1'b1 : word_ind_pre;
                end
              end
            end else begin
              itx_num_valid <= {LOG_INTE_WORDS{1'b0}};
            end
          end else begin
            itx_sob       <= 1'b0; // new
            itx_num_valid <= {LOG_INTE_WORDS{1'b0}};
          end
        end
        // 4
        EOP     : begin
          itx_sop <= 1'b0;
          if (itx_ready) begin
            word_ind      <= 9'h0;
            word_ind_pre  <= word_ind_pre;
            itx_din_words <= {word1, word2, word3, word4, word5, word6, word7, word8};
            word          <= {word7, word6, word5, word4, word3, word2, word1, word8};

              itx_num_valid <= eop_num_valid;
              itx_eopbits   <= 4'hC;
              if (eop_num_valid == 1)
                eop_num_valid <= INTERNAL_WORDS;
              else
                eop_num_valid <= eop_num_valid - 1'b1;

            if (!int_burst_size) begin
              itx_sob   <= 1'b0;
              itx_eob   <= 1'b0;
              burst_cnt <= 9'h0;
            end else begin
              itx_sob   <= (!burst_cnt && !hold_cnt) & (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
              itx_eob   <= (TX_PKTMOD_ONLY == 0) ? 1'b1 : 1'b0;
              burst_cnt <= 9'h0;
            //itx_chan  <= (!burst_cnt && !hold_cnt && int_burst_size) ? get_ch_id(itx_chan, start_ch, num_channels) : itx_chan;
            end

            // Used only in directed tests
         // if (pkt_size == 8'h0 || (pkt_size == 8'h1 && eop_bytes == 6'h0)) begin
         //   short_pkt_cnt <= MAX_CNT_SHORT;
         // end else begin
         //   short_pkt_cnt <= short_pkt_cnt - 1'b1;
         // end

            if (init_gen_s) begin
              itx_chan <= get_ch_id(itx_chan, start_ch, num_channels);
              tx_state <= START;
            end else if (!inter_pkt_gap_size) begin
              if (!short_pkt_cnt) begin
                tx_state <= SHORT;
              end else begin
                tx_state <= SOP;
              end
            end else begin
              tx_state <= GAP;
            end
          end else begin
            word_ind_pre  <= word_ind_pre;
            itx_num_valid <= {LOG_INTE_WORDS{1'b0}};
          end
        end
        // 5
        GAP     : begin
          itx_sop       <= 1'b0;
          itx_eopbits   <= 4'h0;
          itx_num_valid <= {LOG_INTE_WORDS{1'b0}};
          itx_sob       <= 1'b0;
          itx_eob       <= 1'b0;
          burst_cnt     <= burst_cnt;
          if (itx_ready) begin
            if (gap_ind < inter_pkt_gap_size)
              gap_ind <= gap_ind + 1'b1;
            else begin
              gap_ind <= 9'h0;
              if (!short_pkt_cnt) begin
                short_pkt_cnt <= MAX_CNT_SHORT;
                tx_state      <= SHORT;
              end else begin
                short_pkt_cnt <= short_pkt_cnt - 1'b1;
                tx_state      <= SOP;
              end
            end
          end
        end
        default : tx_state <= START;
      endcase
    end
  end

  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      start_latency_cnt <= 1'b0;
    end else begin
      if (get_latency) begin
        if (itx_sop && !start_latency_cnt) begin
          start_latency_cnt <= 1'b1;
          latency_cnt_id    <= pkt_cnt;
        end
      end else begin
        start_latency_cnt <= 1'b0;
        latency_cnt_id    <= 8'h0;
      end
    end
  end

  // Counters
  always @(posedge clk or posedge tx_usr_srst) begin
    if (tx_usr_srst) begin
      tx_sop_cnt <= 32'h0;
      tx_eop_cnt <= 32'h0;
    end else begin
      if (itx_sop && itx_num_valid == NUM_VALID) begin
        tx_sop_cnt <= tx_sop_cnt + 1'b1;
      end

      if (itx_eopbits[3] && itx_ready) begin
        tx_eop_cnt <= tx_eop_cnt + 1'b1;
      end
    end
  end

endmodule
