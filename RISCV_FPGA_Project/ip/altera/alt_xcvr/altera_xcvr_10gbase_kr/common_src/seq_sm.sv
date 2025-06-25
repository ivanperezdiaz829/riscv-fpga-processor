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




//============================================================================
// This confidential and proprietary software may be used only as authorized
// by a licensing agreement from ALTERA 
// copyright notice must be reproduced on all authorized copies.
//============================================================================
//

//
//****************************************************************************
// KR Sequencer state machine.
// It controls the link-up progress:
//       reset -> Auto-Neg -> Link Training -> Data Mode.
// Performs some of the functions shown in IEEE 802.3 clause 73 Figure 73-11
// Specifically, the PARALLEL_DETECTION_FAULT, LINK_STATUS_CHECK and the 
// AN_GOOD_CHECK states that couldn't be implemented in the an_arb_sm as these
// functions/states need to have the PHY operate in different modes
//****************************************************************************

`timescale 1 ps / 1 ps

module seq_sm
  #(
  parameter LFT_R_MSB    = 6'd63,        // Link Fail Timer MSB for BASE-R PCS
  parameter LFT_R_LSB    = 10'd0,        // Link Fail Timer lsb for BASE-R PCS
  parameter LFT_X_MSB    = 6'd6,         // Link Fail Timer MSB for BASE-X PCS
  parameter LFT_X_LSB    = 10'd0         // Link Fail Timer lsb for BASE-X PCS
  )(
  input wire             rstn,           // Active low Reset
  input wire             clk,            // mgmt clock = 100 Mhz to 125 Mhz
  input wire             restart,        // Re-start the Link-start-up process
  input wire             an_enable,      // Enable Auto-Negotiation
  input wire             lt_enable,      // Enable Link Training
  input wire [2:0]       frce_mode,      // Force the Hard PHY into a mode
                                         // 000 = no force,  001 = GigE mode
                                         // 010 = XAUI mode, 100 = 10G-R mode
                                         // 101 = kr, 40G, 100G
  input wire             dis_max_wait_tmr,// disable the LT max_wait_timer
  input wire             dis_lf_timer,   // disable the link_fail_inhibit_timer
  input wire             dis_an_timer,   // disable AN timeout. can get stuck
                                   // stuck in ABILITY_DETECT - if rmt not AN
                                   // stuck in ACKNOWLEDGE_DETECT - if loopback
  input wire             en_usr_np,      // Enable user next pages
  input wire             pcs_link_sts,   // PCS link status from Hard PHY
  input wire             ber_zero,       // last LT measurement was zero
  input wire             fail_lt_if_ber, // if last LT measurement is non-zero, treat as a failed run
  output reg             link_ready,     // link is ready
  output reg             seq_an_timeout, // AN timed-out in Sequencer SM
  output reg             seq_lt_timeout, // LT timed-out in Sequencer SM
  output reg             enable_fec,     // Enable FEC for the channel
  output reg [1:0]       data_mux_sel,   // select data input to hard PHY
                                         // 00 = AN, 01 = LT, 10 = xgmii
     // to/from Auto-Negotiation
  input wire [5:0]       lcl_tech,       // Local Device Technology ability
                                         // same definition as lp_tech
  input wire [1:0]       lcl_fec,        // Local Device FEC ability
  input wire             link_good,      // AN completed
  input wire             in_ability_det, // ARB SM in the ABILITY_DETECT state
  input wire             an_rx_idle,     // RX SM in idle state - from RX_CLK
  input wire [5:0]       lp_tech,        // Link Partner Tech ability = D45:21
                                         // bit 0 = GigE = 1000BASE-KX
                                         // bit 1 = XAUI = 10GBASE-KX4
                                         // bit 2 = 10G  = 10GBASE-KR
                                         // bit 3 = 40G BP = 10GBASE-KR4
                                         // bit 4 = 40G-CR4, bit 5 = 100G-CR10
  input wire [1:0]       lp_fec,         // Link Partner FEC ability = D47:46
                                         // bit 0 = ability, bit 1 = requested
  input wire             load_pdet,      // load parallel guess - from RX_CLK
  input wire [2:0]       par_det,        // Parallel Detect Guess from AN Decode
                                         // bit2 =10GR, bit1 =XAUI, bit0 = 1G
  output reg             restart_an,     // restart Auto-Negotiation
     // to/from Link Training
  input wire             training,       // Link Training in progress
  output reg             restart_lt,     // restart Link Training
     // to/from reconfig
  input wire             rc_busy,        // re-configuration is busy
  output reg             start_rc,       // start the PCS reconfig
  output reg [5:0]       pcs_mode_rc     // PCS mode for reconfig - 1 hot
                                         // bit 0 = AN mode = low_lat, PLL LTR
                                         // bit 1 = LT mode = low_lat, PLL LTD
                                         // bit 2 = 10G data mode = 10GBASE-R
                                         // bit 3 = GigE data mode = 8G PCS
                                         // bit 4 = XAUI data mode = future?
                                         // bit 5 = 10G-FEC = 40G/100G=future?
  );

//****************************************************************************
// Define Parameters 
//****************************************************************************
`ifdef ALTERA_RESERVED_QIS
  // Enable full-length timers for synthesis.
  // Usually have short timers for sim performance
  `define ALTERA_RESERVED_XCVR_FULL_KR_TIMERS
`endif // QIS 

//****************************************************************************
// Instantiate the transceiver sync module for the signals crossing clocks
//  \p4\ip\altera_xcvr_generic\ctrl\alt_xcvr_resync.sv
//****************************************************************************
  wire restart_sync;           // synced restart
  wire link_sts_sync;          // synced pcs_link_sts
  wire link_good_sync;         // synced link_good
  wire abil_det_sync;          // synced in_ability_det
  wire rx_idle_sync;           // synced an_rx_idle
  wire ld_pdet_sync;           // synced load_pdet
  wire rc_busy_sync;           // synced rc_busy
  wire training_sync;          // synced training
  wire ber_zero_sync;          // synced ber_zero

  alt_xcvr_resync #( 
      .WIDTH   (9) ) 
    TX_TRAIN_SYNC (
      .clk   (clk), 
      .reset (~rstn), 
      .d     ({restart,      pcs_link_sts,  link_good,      in_ability_det,
               an_rx_idle,   load_pdet,     rc_busy,        training,       ber_zero}), 
      .q     ({restart_sync, link_sts_sync, link_good_sync, abil_det_sync,
               rx_idle_sync, ld_pdet_sync,  rc_busy_sync,   training_sync,  ber_zero_sync })
   );

  // finished with reconfig when not busy - falling/trailing edge detect
  // finished with Auto-Neg when rising edge of link_good
  // finished with TX Disable when rising edge of in_ability_det
  // finished with Link Training when not training - falling edge detect
  reg  dly_rc_busy;                     // delay for reconfig done
  wire rc_done;                         // edge detect of the reconfig done
  reg  dly_link_good;                   // for edge detect of link_good done
  wire an_done;                         // edge detect of the link_good done
  reg  dly_ability;                     // for edge detect of in_ability_det
  wire in_ability;                      // edge detect of the in_ability_det
  reg  dly_training;                    // for edge detect Link training done
  wire train_done;                      // edge detect of  Link Training done
  reg [2:0] pdet;                       // parallel detect data

  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0) begin
      dly_rc_busy  <= 1'b0;
      dly_link_good <= 1'b0;
      dly_ability   <= 1'b0;
      dly_training  <= 1'b0;
      pdet  <= 'd0;
      end // if
    else begin
      dly_rc_busy  <= rc_busy_sync;
      dly_link_good <= link_good_sync;
      dly_ability   <= abil_det_sync;
      dly_training  <= training_sync;
      if (ld_pdet_sync) pdet <= par_det;
      end //else
  end //always

  assign rc_done    = ~rc_busy_sync   &  dly_rc_busy;
  assign an_done    =  link_good_sync & ~dly_link_good;
  assign in_ability =  abil_det_sync  & ~dly_ability;
  assign train_done = ~training_sync  &  dly_training;

//****************************************************************************
// Link Fail Inhibit Timer and Autoneg Wait timer
// Defined in IEEE 802.3-2008 clause 73.10.2 as 500mS to 510ms for BASE-R PCS
// clock period is 8 nS, so need to count about 63 million clocks = 504mS
// if clock is 9ns, then need to count 56 million clocks = 505mS
// if clock is 10ns, then need to count 50.5 million clocks = 505mS
// for the KX or KX4 (GigE or XAUI) PCS it is defined as 40mS to 50mS
// for a 8ns clock, need a count of 6 million = 48mS,
// for a 9ns clock, need count of 5 million = 45ms,
// for a 10ns clock, need count of 4.5 million = 45 ms
// simulation by default is shortened to count 60,000 which gives about 480uS
// and 6,000 to give about 50us and 4,000 to give about 33us.
// Autoneg Wait Timer also defined in 73.10.2 as 25mS to 50mS
// need a count of 4 million = 32mS, 4,000 for sim to give 32uS for sim
// need a count of 4 million = 36mS for 9ns clock and 40mS for 10ns clock
// Based on counter stage architecture from "advanced Synthesis Cookbook"
// Taken from the cookbook seconds_counter example design
//****************************************************************************
  reg [9:0] stage_one;  // stage one, count 1000 clocks
  reg  stage_one_max;   // stage one at max count
  reg  clr_lf_tmr;      // clear the counter
  wire  baser_mode;      // link fail max is for 10GBASE-R PCS
  wire  aneg_mode;       // Autoneg Wait timer mode

  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0) begin
      stage_one     <= 10'd0;
      stage_one_max <= 1'b0;
      end // if
    else begin
      stage_one_max <= (stage_one == 10'd999);
      if (stage_one_max | clr_lf_tmr) stage_one <= 10'd0;
      else                            stage_one <= stage_one + 1'b1;
    end // else
  end //always

`ifdef ALTERA_RESERVED_XCVR_FULL_KR_TIMERS
  // second stage, count 1000 first stage max pulses
  reg [9:0] stage_two; // stage two, count 1000
  reg stage_two_max;   // stage two at max count
  
  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0) begin
      stage_two     <= 10'd0;
      stage_two_max <= 1'b0;
      end // if
    else begin
      stage_two_max <= (stage_two == 10'd999);
      if ((stage_one_max & stage_two_max) | clr_lf_tmr) stage_two <= 10'd0;
      else if (stage_one_max)              stage_two <= stage_two + 1'b1;
    end // else
  end //always

  // third stage, count MSB.LSB "first and second" stage max pulses
  // or count 4 million for Autoneg Wait Timer
  reg [5:0] stage_trey; // stage three, count to 63
  reg stage_trey_max;   // stage three at max count
  
  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0) begin
      stage_trey     <= 'd0;
      stage_trey_max <= 1'b0;
      end // if
    else begin
      stage_trey_max <= ~clr_lf_tmr &
                       (( baser_mode & ~aneg_mode && 
                          (stage_trey == LFT_R_MSB)&&(stage_two == LFT_R_LSB))|
                        (~baser_mode & ~aneg_mode && 
                          (stage_trey == LFT_X_MSB)&&(stage_two == LFT_X_LSB))|
                        (               aneg_mode && (stage_trey == 6'd4)));
      if (clr_lf_tmr)          stage_trey <= 'd0;
      else if (stage_trey_max) stage_trey <= stage_trey;
      else if (stage_one_max & stage_two_max) stage_trey <= stage_trey + 1'b1;
    end // else
  end //always

  // set the max_wait timer done
  wire   lf_tmr_done, an_tmr_done;
  assign lf_tmr_done = stage_trey_max;
  assign an_tmr_done = stage_trey_max & ~en_usr_np & ~dis_an_timer;
  
`else // not FULL_KR_TIMERS
  // second stage, count 60,000 first stage max pulses for simulation baser PCS
  // or count 6,000 for simulation mode for Gige or XAUI mode
  // or count 4,000 for Autoneg Wait Timer simulation mode
  reg [5:0] stage_two; // stage two, only count to 56
  reg stage_two_max;   // stage two at max count
  
  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0) begin
      stage_two     <= 'd0;
      stage_two_max <= 1'b0;
      end // if
    else begin
      stage_two_max <= ~clr_lf_tmr &
                      (( baser_mode & ~aneg_mode && (stage_two == 6'd60)) |
                       (~baser_mode & ~aneg_mode && (stage_two == 6'd6))  |
                       (               aneg_mode && (stage_two == 6'd4)));
      if (clr_lf_tmr)         stage_two <= 'd0;
      else if (stage_two_max) stage_two <= stage_two;
      else if (stage_one_max) stage_two <= stage_two + 1'b1;
    end // else
  end //always

  // set the max_wait timer done
  wire   lf_tmr_done, an_tmr_done;  
  assign lf_tmr_done = stage_two_max;
  assign an_tmr_done = stage_two_max & ~en_usr_np & ~dis_an_timer;
`endif // FULL_KR_TIMERS
   
//****************************************************************************
// Miscellaneous SM resources
// parallel detect direction from the AN_receive_SM
// Priority Resolution as seen in IEEE 802.3ba-2010 Table 73-5
// A single lane only knows about Gige, XAUI, or 10G.  40G & 100G same as 10G
// No timer defined for not being stuck in Ability Detect???
//   The long link_fail_timer seems too long, but need longer than short 
//   link_fail_timer due to Break_Link_Timer length
//   Don't want a timer when user/sw next pages, so disable timer for usr_np.
//   Use flag to count for 2nd short link_fail_timer and reset if AN started 
// Count number of reconfig tries for legacy links before re-start AN.
//****************************************************************************
  wire pdet_10g, pdet_xaui, pdet_gige;  // conditioned parallel detect for SM
  wire sngl_link_rdy;                   // single link ready
  wire hcd_40g, hcd_kr, hcd_xaui, hcd_gige; // priority resolution function
  wire fec_cap;                         // FEC capability
  reg  lf_flag;                         // count 2nd link_fail timeout
  reg  set_lf_flag;                     // set the count 2nd link_fail timeout
  reg  clr_lf_flag;                     // clear count 2nd link_fail timeout
  reg [1:0] rc_try_cnt;                 // RC count for legacy links
  wire      clr_rc_try;                 // clear the RC count
  reg       inc_rc_try;                 // increment the RC count

  assign pdet_10g  = lcl_tech[2] & pdet[2];
  assign pdet_xaui = lcl_tech[1] & pdet[1];
  assign pdet_gige = lcl_tech[0] & pdet[0];

  assign sngl_link_rdy = link_sts_sync & rx_idle_sync;
  
  assign hcd_40g  = (lcl_tech[5] & lp_tech[5]) |
                    (lcl_tech[4] & lp_tech[4]) |
                    (lcl_tech[3] & lp_tech[3]);
  assign hcd_kr   =  lcl_tech[2] & lp_tech[2] & ~hcd_40g;
  assign hcd_xaui =  lcl_tech[1] & lp_tech[1] & ~hcd_kr & ~hcd_40g;
  assign hcd_gige =  lcl_tech[0] & lp_tech[0] & ~hcd_xaui & ~hcd_kr & ~hcd_40g;

  // FEC capability if BASE-R PCS, both sides have ability, one requests
  // see updated definition in IEEE 802.3ba-2010 clause 73.6.5
  assign fec_cap  = (hcd_40g | hcd_kr) & lcl_fec[0] & lp_fec[0] &
                    (lcl_fec[1] | lp_fec[1]);

  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0) lf_flag <= 1'b0;
    else              lf_flag <= (lf_flag & ~clr_lf_flag) | set_lf_flag;
  end //always

  // depending upon when us or the LP is reset may need to re-try AN again
  // count the number of reconfigs for the legacy links before re-trying AN
  // also used as mini-timer/de-glitcher for detecting the LP sending AN pages
  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0)    rc_try_cnt <= 'd0;
    else if (clr_rc_try) rc_try_cnt <= 'd0;
    else if (inc_rc_try) rc_try_cnt <= rc_try_cnt + 1'b1;
  end //always

//****************************************************************************
// Sequence State Machine
// Performs some of the functions shown in IEEE 802.3 clause 73 Figure 73-11
// Also keeps track of the PCS modes and handshaking of the PCS reconfig
// Will re-start if get link_status down for break-link timer
//****************************************************************************
  reg [3:0] seq_sm;           // Sequencer state machine state
  reg [3:0] nxt_seq_sm;
  wire      set_lnk_rdy;      // set the link_ready output
  reg       set_an_to;        // set the seq_an_timeout output
  reg       set_lt_to;        // set the seq_lt_timeout output
  reg       set_st_rc;        // set the start_rc output
  reg       set_rst_an;       // set the restart_an output
  wire      set_rst_lt;       // set the restart_lt output
  reg       ld_sel;           // load the pcs_mode and data_mux holding regs
  reg [1:0] data_mux;         // data to hard PHY, 00 = AN, 01 = LT, 10 = xgmii
  reg [5:0] pcs_mode;         // PCS mode for reconfig - 1 hot
                              /// 0=AN, 1=LT, 2=10G, 3=Gige, 4=XAUI, 5=10G-FEC

  localparam SSM_ENABLE  = 4'b0000;     // check for enable/mode
  localparam SSM_RC_AN   = 4'b0001;     // reconfig into Auto-Neg mode
  localparam SSM_AN_ABL  = 4'b0010;     // wait for AN start
  localparam SSM_AN_CHK  = 4'b0011;     // check for AN done
  localparam SSM_RC_LT   = 4'b0100;     // reconfig into Link Training mode
  localparam SSM_LT_CHK  = 4'b0101;     // check for LT done
  localparam SSM_RC_10G  = 4'b0110;     // reconfig into 10G mode
  localparam SSM_10G_CHK = 4'b0111;     // check for link-up
  localparam SSM_RC_GE   = 4'b1000;     // reconfig into GigE mode
  localparam SSM_GE_CHK  = 4'b1001;     // check for link-up
  localparam SSM_GE_PDF  = 4'b1010;     // GiGE Parallel Fault, wait link ready
  localparam SSM_RC_XAU  = 4'b1011;     // reconfig for XAUI mode
  localparam SSM_XAU_CHK = 4'b1100;     // check for link-up
  localparam SSM_XAU_PDF = 4'b1101;     // XAUI Parallel Fault, wait link ready
  localparam SSM_LNK_RDY = 4'b1110;     // Link ready
  localparam SSM_LR_WAIT = 4'b1111;     // wait for link ready

  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0)      seq_sm <= SSM_ENABLE;
    else if (restart_sync) seq_sm <= SSM_ENABLE;
    else                   seq_sm <= nxt_seq_sm;
  end //always

  // long timer when waiting for LT to finish and 10G link-up
  // short timer for AN_wait, Gige, XAUI to finish PDF check and Break-link
  // link_ready when status==good and not timed out when status==bad
  // hold restart of AN/LT when performing the reconfig
  assign baser_mode  = (seq_sm == SSM_LT_CHK)  || (seq_sm == SSM_RC_10G) ||
                       (seq_sm == SSM_10G_CHK);
  assign aneg_mode   = (seq_sm == SSM_GE_CHK)  || (seq_sm == SSM_GE_PDF) ||
                       (seq_sm == SSM_XAU_CHK) || (seq_sm == SSM_XAU_PDF);
  assign set_lnk_rdy = (seq_sm == SSM_LNK_RDY) || (seq_sm == SSM_LR_WAIT);
  assign set_rst_an  = (seq_sm == SSM_RC_AN);
  assign set_rst_lt  = (seq_sm == SSM_ENABLE) || (seq_sm == SSM_RC_AN) ||
                       (seq_sm == SSM_AN_ABL) || (seq_sm == SSM_AN_CHK) ||
                       (seq_sm == SSM_RC_LT);
  assign clr_rc_try  = (seq_sm == SSM_ENABLE) || (seq_sm == SSM_LNK_RDY);

  always_comb
    begin
      set_st_rc  = 1'b0;
      set_an_to  = 1'b0;
      set_lt_to  = 1'b0;
      clr_lf_tmr = 1'b0;
      clr_lf_flag = 1'b0;
      set_lf_flag = 1'b0;
      inc_rc_try  = 1'b0;
      ld_sel   = 1'b0;
      data_mux = 2'b0;
      pcs_mode = 6'd0;
      case (seq_sm)
        SSM_ENABLE : begin
          if (((frce_mode == 3'd0) & an_enable) |
              ((frce_mode == 3'd5) & an_enable)) begin
            nxt_seq_sm = SSM_RC_AN;
            ld_sel    = 1'b1;
            pcs_mode  = 6'd1;
            set_st_rc = 1'b1;
            end // if
          else if (((frce_mode == 3'd0) & lt_enable) |
                   ((frce_mode == 3'd5) & lt_enable)) begin
            nxt_seq_sm = SSM_RC_LT;
            ld_sel    = 1'b1;
            data_mux  = 2'b01;
            pcs_mode  = 6'd2;
            set_st_rc = 1'b1;
            end // else if
          else if ((frce_mode == 3'd4) |
                  ((frce_mode == 3'd0) & ~an_enable & ~lt_enable & lcl_tech[2])|
                  ((frce_mode == 3'd5) & ~an_enable & ~lt_enable & lcl_tech[2]))
            begin
            nxt_seq_sm = SSM_RC_10G;
            clr_lf_tmr = 1'b1;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = {fec_cap,2'd0,~fec_cap,2'd0};
            set_st_rc = 1'b1;
            end // else if
          else if ((frce_mode == 3'd1) |
                  ((frce_mode == 3'd0) & ~an_enable & ~lt_enable & lcl_tech[0])|
                  ((frce_mode == 3'd5) & ~an_enable & ~lt_enable & lcl_tech[0]))
            begin
            nxt_seq_sm = SSM_RC_GE;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd8;
            set_st_rc = 1'b1;
            end // else if
          else if ((frce_mode == 3'd2) |
                  ((frce_mode == 3'd0) & ~an_enable & ~lt_enable & lcl_tech[1]))
            begin
            nxt_seq_sm = SSM_RC_XAU;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd16;
            set_st_rc = 1'b1;
            end // else if
          else nxt_seq_sm = SSM_ENABLE;
          end // enable
        SSM_RC_AN : begin
          if (rc_done) nxt_seq_sm = SSM_AN_ABL;
          else         nxt_seq_sm = SSM_RC_AN;
          end // AN reconfig
        SSM_AN_ABL : begin
          if (in_ability) begin
            nxt_seq_sm = SSM_AN_CHK;
            clr_lf_tmr  = 1'b1;
            clr_lf_flag = 1'b1;
            end // if
          else nxt_seq_sm = SSM_AN_ABL;
          end // AN ability
        SSM_AN_CHK : begin
          if ((an_done & lt_enable & (hcd_40g | hcd_kr)) |
              (an_tmr_done & lf_flag & lt_enable)) begin
            nxt_seq_sm = SSM_LT_CHK;
            clr_lf_tmr = 1'b1;
            ld_sel    = 1'b1;
            data_mux  = 2'b01;
            pcs_mode  = 6'd2;
            set_an_to = an_tmr_done;
            end // if
          else if ((an_done & hcd_xaui) | 
                   (an_tmr_done & lf_flag & pdet_xaui)) begin
            nxt_seq_sm = SSM_RC_XAU;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd16;
            set_st_rc = 1'b1;
            set_an_to = an_tmr_done;
            end // else if
          else if ((an_done & hcd_gige) | (an_tmr_done & lf_flag & pdet_gige) |
                   (an_tmr_done & lf_flag & ~pdet_10g)) begin
            nxt_seq_sm = SSM_RC_GE;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd8;
            set_st_rc = 1'b1;
            set_an_to = an_tmr_done;
            end // else if
          else if (an_done | (an_tmr_done & lf_flag)) begin
            nxt_seq_sm = SSM_RC_10G;
            clr_lf_tmr = 1'b1;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = {fec_cap,2'd0,~fec_cap,2'd0};
            set_st_rc = 1'b1;
            set_an_to = an_tmr_done;
            end // else if
          else if (an_tmr_done & ~lf_flag) begin
            nxt_seq_sm = SSM_AN_CHK;
            clr_lf_tmr  = 1'b1;
            set_lf_flag = 1'b1;
            end // else if
          else nxt_seq_sm = SSM_AN_CHK;
          end // AN check
        SSM_RC_LT : begin
          if (rc_done) begin
            nxt_seq_sm = SSM_LT_CHK;
            clr_lf_tmr = 1'b1;
            end // if
          else nxt_seq_sm = SSM_RC_LT;
          end // LT reconfig
        SSM_LT_CHK : begin
          if (train_done & fail_lt_if_ber & ~ber_zero_sync)
            nxt_seq_sm = SSM_ENABLE;
          else if (train_done | (lf_tmr_done & ~dis_max_wait_tmr)) begin
            nxt_seq_sm = SSM_RC_10G;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = {fec_cap,2'd0,~fec_cap,2'd0};
            set_st_rc = 1'b1;
            set_lt_to = lf_tmr_done & ~dis_max_wait_tmr;
            end // if
          else nxt_seq_sm = SSM_LT_CHK;
          end // LT check
        SSM_RC_10G : begin
          if (rc_done) begin
            nxt_seq_sm = SSM_10G_CHK;
//            clr_lf_tmr = 1'b1;
            end // if
          else nxt_seq_sm = SSM_RC_10G;
          end // 10G reconfig
        SSM_10G_CHK : begin
          if (link_sts_sync) nxt_seq_sm = SSM_LNK_RDY;
          else if (lf_tmr_done & ~dis_lf_timer & lcl_tech[1] &
                   ~&rc_try_cnt & rx_idle_sync &&
                   ~((frce_mode == 3'd4)||(frce_mode == 3'd5))) begin
            nxt_seq_sm = SSM_RC_XAU;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd16;
            set_st_rc = 1'b1;
            inc_rc_try= 1'b1;
            end // else if
          else if (lf_tmr_done & ~dis_lf_timer & lcl_tech[0] &
                   ~&rc_try_cnt & rx_idle_sync &&
                   ~((frce_mode == 3'd4)||(frce_mode == 3'd5))) begin
            nxt_seq_sm = SSM_RC_GE;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd8;
            set_st_rc = 1'b1;
            inc_rc_try= 1'b1;
            end // else if
          else if (lf_tmr_done & ~dis_lf_timer & (&rc_try_cnt | ~rx_idle_sync | ~|lcl_tech[1:0]))
            nxt_seq_sm = SSM_ENABLE;
          else nxt_seq_sm = SSM_10G_CHK;
          end // 10G check
        SSM_RC_GE : begin
          if (rc_done) begin
            nxt_seq_sm = SSM_GE_CHK;
            clr_lf_tmr = 1'b1;
            end // if
          else nxt_seq_sm = SSM_RC_GE;
          end // Gige reconfig
        SSM_GE_CHK : begin
          if (sngl_link_rdy) begin
            nxt_seq_sm = SSM_GE_PDF;
            clr_lf_tmr = 1'b1;
            end // if
          else if (lf_tmr_done & lcl_tech[2] & ~&rc_try_cnt & rx_idle_sync && 
                   (frce_mode != 3'd1)) begin
            nxt_seq_sm = SSM_RC_10G;
            clr_lf_tmr = 1'b1;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = {fec_cap,2'd0,~fec_cap,2'd0};
            set_st_rc = 1'b1;
            inc_rc_try= 1'b1;
            end // else if
          else if (lf_tmr_done & lcl_tech[1] & ~&rc_try_cnt & rx_idle_sync && 
                   (frce_mode != 3'd1)) begin
            nxt_seq_sm = SSM_RC_XAU;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd16;
            set_st_rc = 1'b1;
            inc_rc_try= 1'b1;
            end // else if
          else if (lf_tmr_done & (&rc_try_cnt | ~rx_idle_sync | ~|lcl_tech[2:1]))
               nxt_seq_sm = SSM_ENABLE;
          else nxt_seq_sm = SSM_GE_CHK;
          end // GigE check
        SSM_GE_PDF : begin
          if (~sngl_link_rdy)   nxt_seq_sm = SSM_GE_CHK;
          else if (lf_tmr_done) nxt_seq_sm = SSM_LNK_RDY;
          else                  nxt_seq_sm = SSM_GE_PDF;
          end // XAUI Parallel Fault
        SSM_RC_XAU : begin
          if (rc_done) begin
            nxt_seq_sm = SSM_XAU_CHK;
            clr_lf_tmr = 1'b1;
            end // if
          else nxt_seq_sm = SSM_RC_XAU;
          end // XAUI reconfig
        SSM_XAU_CHK : begin
          if (sngl_link_rdy) begin
            nxt_seq_sm = SSM_XAU_PDF;
            clr_lf_tmr = 1'b1;
            end // if
          else if (lf_tmr_done & lcl_tech[0] & ~&rc_try_cnt & rx_idle_sync &&
                   (frce_mode != 3'd2)) begin
            nxt_seq_sm = SSM_RC_GE;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = 6'd8;
            set_st_rc = 1'b1;
            inc_rc_try= 1'b1;
            end // else if
          else if (lf_tmr_done & lcl_tech[2] & ~&rc_try_cnt & rx_idle_sync &&
                   (frce_mode != 3'd2)) begin
            nxt_seq_sm = SSM_RC_10G;
            clr_lf_tmr = 1'b1;
            ld_sel    = 1'b1;
            data_mux  = 2'b10;
            pcs_mode  = {fec_cap,2'd0,~fec_cap,2'd0};
            set_st_rc = 1'b1;
            inc_rc_try= 1'b1;
            end // else if
          else if (lf_tmr_done & (&rc_try_cnt | ~rx_idle_sync | ~(lcl_tech[2]|lcl_tech[0])))
               nxt_seq_sm = SSM_ENABLE;
          else nxt_seq_sm = SSM_XAU_CHK;
          end // XAUI check
        SSM_XAU_PDF : begin
          if (~sngl_link_rdy)   nxt_seq_sm = SSM_XAU_CHK;
          else if (lf_tmr_done) nxt_seq_sm = SSM_LNK_RDY;
          else                  nxt_seq_sm = SSM_XAU_PDF;
          end // XAUI Parallel Fault
        SSM_LNK_RDY : begin
          if (~sngl_link_rdy) begin
            nxt_seq_sm = SSM_LR_WAIT;
            clr_lf_tmr = 1'b1;
            end // if
          else nxt_seq_sm = SSM_LNK_RDY;
          end // Link Ready
        SSM_LR_WAIT : begin
          inc_rc_try= 1'b1;   // add a mini-timer to the rx_idle_sync
          if (sngl_link_rdy) nxt_seq_sm = SSM_LNK_RDY;
          else if ((lf_tmr_done & ~dis_lf_timer) | (&rc_try_cnt & ~rx_idle_sync))
               nxt_seq_sm = SSM_ENABLE;
          else nxt_seq_sm = SSM_LR_WAIT;
          end // Wait for Link Ready
        default: nxt_seq_sm = seq_sm;
      endcase
  end //always

//****************************************************************************
// Output registers
//****************************************************************************
  reg lt_rst_delay;   // hold the restart_lt active for two clocks

  always_ff @(negedge rstn or posedge clk) begin
    if (rstn == 1'b0) begin
      link_ready <= 1'b0;
      seq_an_timeout <= 1'b0;
      seq_lt_timeout <= 1'b0;
      restart_an   <= 1'b0;
      lt_rst_delay <= 1'b0;
      restart_lt   <= 1'b0;
      enable_fec <= 1'b0;
      start_rc   <= 1'b0;
      data_mux_sel <= 'd0;
      pcs_mode_rc  <= 'd0;
      end // if
    else if (restart_sync) begin
      link_ready <= 1'b0;
      seq_an_timeout <= 1'b0;
      seq_lt_timeout <= 1'b0;
      restart_an   <= 1'b0;
      lt_rst_delay <= 1'b0;
      restart_lt   <= 1'b0;
      enable_fec <= 1'b0;
      start_rc   <= 1'b0;
      data_mux_sel <= 'd0;
      pcs_mode_rc  <= 'd0;
      end // else if
    else  begin
      link_ready <= set_lnk_rdy;
      seq_an_timeout <= set_an_to | (seq_an_timeout & ~set_rst_an);
      seq_lt_timeout <= set_lt_to | (seq_lt_timeout & ~set_rst_lt);
      restart_an   <= set_rst_an;
      lt_rst_delay <= set_rst_lt;
      restart_lt   <= set_rst_lt | lt_rst_delay;
      if (ld_sel) enable_fec <= fec_cap;
      start_rc   <= set_st_rc | (start_rc & ~rc_busy_sync);
      if (ld_sel) data_mux_sel <= data_mux;
      if (ld_sel) pcs_mode_rc  <= pcs_mode;
      end // else
  end //always
  
endmodule  //seq_sm
