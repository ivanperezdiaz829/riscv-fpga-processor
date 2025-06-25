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



// baeckler - 6-15-2011
// Juzhang  - 6-01-2012

`timescale 1 ps / 1 ps

import altera_xcvr_functions::*;

module ilk_core #(
   // Default PCS settings (12L10G)
   // Can be "Stratix V" , "Arria V GZ"; or "Arria 10";
   parameter FAMILY              = "Stratix V",   
   parameter USE_ATX             = 1,
   parameter DATA_RATE           = "12500.0 Mbps",
   parameter PLL_OUT_FREQ        = "6250.0 MHz",           // CAREFUL!! : this is MHz, not MBPS, typically 1/2 data rate
   parameter PLL_REFCLK_FREQ     = "312.5 MHz",
   parameter INT_TX_CLK_DIV      = 1,                       // CGB TX clock divider, typically 1
   parameter LANE_PROFILE        = 24'b000000_000000_111111_111111,
   parameter NUM_LANES           = 12,                      // !!!no override without other edits
   parameter NUM_SIXPACKS        = 2,
   parameter RX_PKTMOD_ONLY      = 0,                       // If set to 1, receiver expect traffic from transmit is packet based with burstmin/burstshort 32 byte up.
                                                            // If set to 0, receiver expect traffic from transmit is interleaved or packet mode with burstmin nx64.
   parameter TX_PKTMOD_ONLY      = 1,                       // If set to 1, itx_sob/itx_eob will be ignored and use internal enhance scheduling for insert control word.
                                                            // If set to 0, user is responsible to provide itx_sob/itx_eob for instructing Interlaken core where to insert control word.
   parameter TX_ONLY_MODE        = 1'b0,                    // If set to 1, don't wait for RX lanes to align before enabling TX path
   parameter RX_DUAL_SEG         = 1,
   parameter ECC_ENABLE          = 1,  
   parameter TX_DUAL_SEG         = 1,
   parameter RXFIFO_ADDR_WIDTH   = 12,                      // 12 is 32K byte deep FIFO
   parameter CNTR_BITS           = 20,                      // regulate reset delay, 6 for sim, 20 for hardware
   parameter CALENDAR_PAGES      = 16,
   parameter LOG_CALENDAR_PAGES  = 4,
   parameter INCLUDE_TEMP_SENSE  = 1'b0,
   parameter METALEN             = 64,                      // Set low for fast simulation time. 2048 for hardware test.
   parameter SCRAM_CONST         = 58'hdeadbeef123,         // if user instantiate more than one interlaken, this number need to be different to reduce cross talk.
   parameter INTERNAL_WORDS      = 8,
   parameter RT_BUFFER_SIZE      = 15000,                   // Byte counts of Retransmission buffer size.
   // Reconfiguration bundles
   parameter W_BUNDLE_TO_XCVR    = 70,
   parameter W_BUNDLE_FROM_XCVR  = 46,
   parameter MM_CLK_KHZ          = 20'd100000,              // management clock range is restricted to 100 to 125 MHz by hard logic
   parameter MM_CLK_MHZ          = 28'd100000000,           // If mm_clk set to 125, both value need to change
   parameter ERR_HANDLER_ON      = 1,                       //Turn on Error handler block.
   parameter INBAND_FLW_ON       = 1,
   parameter DIAG_ON             = 0,
   parameter NUM_PLLS            = NUM_SIXPACKS
)(
   input                               tx_usr_clk,          // 300Mhz user clock
   input                               rx_usr_clk,          // 300Mhz user clock.
   input                               reset_n,
   input                               pll_ref_clk,         // Check with release document for proper value
   input               [NUM_LANES-1:0] rx_pin,
   output              [NUM_LANES-1:0] tx_pin,
   output              [NUM_LANES-1:0] sync_locked,         // Generated with rx_usr_clk
   output              [NUM_LANES-1:0] word_locked,         // Generated with rx_usr_clk
   output                              rx_lanes_aligned,    // Generated with rx_usr_clk.
   output                              tx_lanes_aligned,    // Generated with tx_usr_clk.
   input       [64*INTERNAL_WORDS-1:0] itx_din_words,       // The following signals sync with tx_usr_clk
   input                         [7:0] itx_num_valid,       // [7:4] aligned with MSB. [3:0] aligned with middle.
   input                         [7:0] itx_chan,            // Channel number. Only need to be valid during SOP/SOB cycle.
   input                         [1:0] itx_sop,             // itx_sop[1] Start of the packet. MSB aligned. itx_sop[0] for dual segment.
   input                         [3:0] itx_eopbits,         // Number of valid byte in the last word. 4'b1000 is 8 byte,1001,1010 one/two byte
   input                         [1:0] itx_sob,             // itx_sob[0] is for dual segment.
   input                               itx_eob,
   input       [CALENDAR_PAGES*16-1:0] itx_calendar,        // Tie to all 1. zero is XOFF, 1 is XON
                                                            // If you want to disable this feature, tie all high!!!!!
   input                         [3:0] burst_max_in,        // Static input. In multiple of 64 byte. 2: 128 byte, 4: 256 byte.
   input                         [3:0] burst_short_in,      // Static input. In multiple of 32 byte. 1: 32  byte, 2: 64 byte.
   input                         [3:0] burst_min_in,        // Static input. In multiple of 32 byte. 1: 32  byte, 2: 64 byte.
   output reg                          itx_ready,           // Sync with tx_usr_clk up to 4 cycle grace period.
   output                              itx_hungry,          // Sync with tx_usr_clk
   output                              itx_overflow,        // Sync with tx_usr_clk
   output                              itx_underflow,       // Sync with tx_usr_clk
   output                              itx_ifc_err,         // Sync with tx_usr_clk    illegal traffic pattern at tx interface.
   output wire                         crc24_err,           // Generated with rx_usr_clk
   output wire         [NUM_LANES-1:0] crc32_err,           // Generated with rx_usr_clk
   output wire                         clk_tx_common,       // Tx lane clock.
   output wire                         srst_tx_common,      // When this is low, it indicates tx PCS is out of reset.
   output wire                         clk_rx_common,       // Rx lane clock. 257.8 Mhz. It clocked tx pcs/mac.
   output wire                         srst_rx_common,      // When this is low, it indicates RX PCS logic is out of reset.
   output                              tx_mac_srst,         // When this is low, it indicates TX Mac logic is out of reset.
   output                              rx_mac_srst,         // When this is low, it indicates RX Mac logic is out of reset.
   output                              tx_usr_srst,         // When this is low, it indicates TX user logic is out of reset.
   output                              rx_usr_srst,         // When this is low, it indicates RX user logic is out of reset.

   output      [64*INTERNAL_WORDS-1:0] irx_dout_words,      // The following is generated with rx_usr_clock
   output                        [7:0] irx_num_valid,       // [7:4] aligned with MSB. [3:0] aligned with middle
   output                        [1:0] irx_sop,             // irx_sop[0] is for Dual SOB mode
   output                        [1:0] irx_sob,             // irx_sob[0] is for Dual SOB mode. Start of the burst.
   output                              irx_eob,             // end of the burst
   output                        [7:0] irx_chan,            // Channel number. Only valid during SOP or SOB cycles.
   output                        [3:0] irx_eopbits,         // Number of the valid bytes.
   output                              irx_err,             // error inidication from the interlaken core

   output      [CALENDAR_PAGES*16-1:0] irx_calendar,        // Calendar bits passed from transmit side. high is XON, low is XOFF.
   output                              irx_overflow,        // Receiver cross domain buffer overflow.
   output                              rdc_overflow,        // Smooth domain fifo overflow
   output                              rg_overflow,         // Receiver buffer overflow.
   output      [RXFIFO_ADDR_WIDTH-1:0] rxfifo_fill_level,   // The fill level of receiver buffer in word.

   // Signals to do PCS control/status
   input                               mm_clk,              // 100 ~125 MHz
   input                               mm_clk_locked,       // loss of lock restarts GX / CPU reset sequence
   input                               mm_read,
   input                               mm_write,
   input                        [15:0] mm_addr,
   output reg                   [31:0] mm_rdata,
   output reg                          mm_rdata_valid,
   input                        [31:0] mm_wdata,

   // Signals to increment debug counters, indicate errors
   output reg                          sop_cntr_inc,
   output reg                          eop_cntr_inc,
   input    [W_BUNDLE_TO_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_to_xcvr,
   output [W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_from_xcvr,
     // For Arria 10
  output      [NUM_PLLS-1:0]           tx_pll_powerdown,
  input       [NUM_PLLS-1:0]           tx_pll_locked,
  input       [NUM_LANES-1:0]          tx_serial_clk,
  output                               mm_waitrequest
);

   //For Arria 10
   wire mm_waitrequest_a10;
   wire [NUM_PLLS-1:0] tx_pll_powerdown_a10;
   wire [W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS)-1:0] reconfig_from_xcvr_tmp;
   generate
     if (FAMILY == "Arria 10") begin
         assign mm_waitrequest = mm_waitrequest_a10;
         assign tx_pll_powerdown = tx_pll_powerdown_a10;
         assign reconfig_from_xcvr =  {W_BUNDLE_FROM_XCVR*(NUM_LANES+NUM_SIXPACKS){1'b0}};
     end
     else  begin
       assign mm_waitrequest = 1'b0;
       assign tx_pll_powerdown = {NUM_PLLS{1'b0}};
       assign reconfig_from_xcvr = reconfig_from_xcvr_tmp;
     end
   endgenerate 

   localparam RETRANS_ON     = 0;
   localparam CRC24_ALIGN_ON = ERR_HANDLER_ON;
   localparam SWAP_TX_LANES  = 1;
   localparam SWAP_RX_LANES  = 1;

   genvar i;

   wire tx_mac_clk;
   wire rx_mac_clk;
   wire tx_valid;
   wire tx_valid_notbf;
   wire tx_cadence;
   localparam BYPASS_LOOSEFIFO = (DATA_RATE == "6250.0 Mbps") ? 0 : 1;
   //TARGET_CHIP 2: S5, 3:A5, 4:A10
   localparam TARGET_CHIP = (FAMILY == "Stratix V") ? 2 : (FAMILY == "Arria 10") ? 4 : 3;

   generate
     if (BYPASS_LOOSEFIFO == 0) begin
         reg  tx_cadence_r;
         always @(posedge clk_tx_common) begin
            if (srst_tx_common) begin
               tx_cadence_r <= 1'b0;
            end
            else begin
               tx_cadence_r <= tx_cadence;
            end
         end
         assign tx_valid = tx_cadence_r;
     end
     else begin
        assign tx_valid = tx_valid_notbf;
     end
   endgenerate

   generate
     if (DATA_RATE == "6250.0 Mbps" || NUM_LANES == 16) begin
         assign tx_mac_clk = tx_usr_clk;
         assign rx_mac_clk = rx_usr_clk;
     end else begin
         assign tx_mac_clk = clk_tx_common;
         assign rx_mac_clk = clk_rx_common;
     end
   endgenerate

   // bypass is 0 in 24x6g mode,since tx_mac_clk  = tx_usr_clk and rx_mac_clk  = rx_usr_clk
   localparam BYPASS_RDC = (DATA_RATE == "6250.0 Mbps") ? 0:1;    //If mac clock and lane clock are from same source, this is not needed.

   //// for 12x10g and 12x12g the LANE_RATE for striper is 10, for 24x6g LANE_RATE for striper is 6

   localparam BYPASS_RBF = (DATA_RATE == "6250.0 Mbps") ? 0:1;

    wire      [64*NUM_LANES-1:0] lane_rxd;
    reg       [64*NUM_LANES-1:0] lane_txd=0; //Don't remove this initial statement. Juzhang
    wire         [NUM_LANES-1:0] rx_valid;
    wire         [NUM_LANES-1:0] rx_control;
    reg          [NUM_LANES-1:0] tx_control=0; //Don't remove this initial statement. Juzhang.

    wire         [NUM_LANES-1:0] sync_locked_pcsclk;
    wire         [NUM_LANES-1:0] word_locked_pcsclk;
    wire                         rx_lanes_aligned_pcsclk;
    wire                         tx_lanes_aligned_pcsclk;
    wire                         tx_lanes_aligned_macclk;

    wire                         itx_hungry_macclk;
    wire                         itx_underflow_macclk;
    wire                         tx_rt_event_on_macclk;
    wire                         tx_force_crc24_err_macclk;
    wire                         crc24_err_macclk;
    wire         [NUM_LANES-1:0] crc32_err_pcsclk;
    wire [CALENDAR_PAGES*16-1:0] irx_calendar_macclk;
    wire                         irx_overflow_macclk;
    wire                         rdc_overflow_macclk;
    wire                         rx_rt_event_on_macclk;
    wire                  [15:0] cfg_ignore_errtimer_macclk;
    wire                  [15:0] cfg_err_timeout_macclk;
    wire                   [4:0] cfg_max_reterr_macclk;
    wire                         rx_rt_enable_macclk;
    wire                         rx_rt_reset_macclk;
    wire                         rx_force_crc24_err_macclk;
    wire                         rx_rt_maxout_option_macclk;
    wire                         rx_rt_req_macclk;
    wire                         tx_rtreply_inc_macclk;
    wire                         rx_rt_reqnest_macclk;
    wire                         rx_rt_interrupt_macclk;
    wire                         rx_rt_interrupt;
    wire                   [1:0] rx_rt_int_cause_macclk;
    wire         [NUM_LANES-1:0] rx_sh_err;
   /******************************************************************************************
   Retransmission interface handling:
   1) Tie rx_rt_req to tx_rt_req.
   2) All the interface signals connect from register instead of I/O port.
   ******************************************************************************************/
    wire                         rx_rt_req;
    wire                         tx_rt_req = rx_rt_req;
    wire                         tx_rt_enable;
    wire                         rx_rt_enable;
    wire                         tx_force_crc24_err;
    wire                         rx_force_crc24_err;
    wire                  [15:0] cfg_ignore_errtimer;
    wire                  [15:0] cfg_err_timeout;
    wire                   [4:0] cfg_max_reterr;
    wire                         rx_rt_reset;
    wire                         rx_rt_maxout_option;
    wire                         tx_rt_req_macclk;
    wire                         tx_rt_enable_macclk;
    wire                         tx_pcsfifo_pempty;
    wire                         tx_pcsfifo_pfull;
    wire                         rx_fifo_full_macclk;

   /******************************************************************************************
   Error handling signasl
   ******************************************************************************************/
    wire       [64*INTERNAL_WORDS-1:0] core_irx_dout_words;    // The following is generated with rx_usr_clock
    wire                         [7:0] core_irx_num_valid;     // [7:4] aligned with MSB. [3:0] aligned with middle
    wire                         [1:0] core_irx_sop;           // irx_sop[0] is for Dual SOB mode
    wire                         [1:0] core_irx_sob;           // irx_sob[0] is for Dual SOB mode. Start of the burst.
    wire                               core_irx_eob;           // end of the burst
    wire                         [7:0] core_irx_chan;          // Channel number. Only valid during SOP or SOB cycles.
    wire                         [3:0] core_irx_eopbits;       // Number of the valid bytes.
    wire                               core_irx_crc24_err;     // Crc error aligned with end of the packet. It indicates that crc24
                                                               // happens before or within current packet.

   /****************************************************************************************
   Sync all the status signal from the tx side to tx_usr_clk.
   Sync all the status signal from the rx side to rx_usr_clk.
   Note: Some signals are using double flopped sync with ilk_status_sync logic.
   Other signals using pulse stretch.For fast toggling signals, in case user use slow user
   clock than mac clock, the pulse might be lost, the pulse stretch logic is used.
   The pulse stretch logic will work both from slow clock to fast clock or the other way as
   long as the two clock frequency is not too much different.
   ****************************************************************************************/

   ilk_pulse_stretch_sync ss_crc24_err ( .aclr_fast_clk(1'b0), .fast_clk(rx_mac_clk), .aclr_slow_clk(1'b0), .slow_clk(rx_usr_clk),
                                         .din(crc24_err_macclk), .dout(crc24_err));
   defparam  ss_crc24_err.WIDTH = 1;
   ilk_pulse_stretch_sync ss_crc32_err ( .aclr_fast_clk(1'b0), .fast_clk(rx_mac_clk), .aclr_slow_clk(1'b0), .slow_clk(rx_usr_clk),
                                         .din(crc32_err_pcsclk), .dout(crc32_err));
   defparam ss_crc32_err .WIDTH = NUM_LANES;
   ilk_pulse_stretch_sync ss_rx_rt_req ( .aclr_fast_clk(1'b0), .fast_clk(rx_mac_clk), .aclr_slow_clk(1'b0), .slow_clk(rx_usr_clk),
                                         .din(rx_rt_req_macclk), .dout(rx_rt_req));
   defparam ss_rx_rt_req.WIDTH = 1;
   //Since tx_rt_req is a direct connect from rx_rt_req, use rx_usr_clk instead.
   ilk_pulse_stretch_sync ss_tx_rt_req ( .aclr_fast_clk(1'b0), .fast_clk(rx_usr_clk), .aclr_slow_clk(1'b0), .slow_clk(tx_mac_clk),
                                         .din(tx_rt_req), .dout(tx_rt_req_macclk));
   defparam ss_tx_rt_req.WIDTH = 1;
   ilk_pulse_stretch_sync ss_rx_force_crc24_err ( .aclr_fast_clk(1'b0), .fast_clk(mm_clk), .aclr_slow_clk(1'b0), .slow_clk(rx_mac_clk),
                                                  .din(rx_force_crc24_err), .dout(rx_force_crc24_err_macclk));
   defparam ss_rx_force_crc24_err.WIDTH = 1;
   ilk_pulse_stretch_sync ss_tx_force_crc24_err ( .aclr_fast_clk(1'b0), .fast_clk(mm_clk), .aclr_slow_clk(1'b0), .slow_clk(tx_mac_clk),
                                                  .din(tx_force_crc24_err), .dout(tx_force_crc24_err_macclk));
   defparam ss_tx_force_crc24_err.WIDTH = 1;
   ilk_pulse_stretch_sync ss_rx_rt_reset ( .aclr_fast_clk(1'b0), .fast_clk(mm_clk), .aclr_slow_clk(1'b0), .slow_clk(rx_mac_clk),
                                           .din(rx_rt_reset), .dout(rx_rt_reset_macclk));
   defparam ss_rx_rt_reset.WIDTH = 1;
   ilk_pulse_stretch_sync ss_rx_rt_interrupt ( .aclr_fast_clk(1'b0), .fast_clk(rx_mac_clk), .aclr_slow_clk(1'b0), .slow_clk(rx_usr_clk),
                                               .din(rx_rt_interrupt_macclk), .dout(rx_rt_interrupt));
   defparam  ss_rx_rt_interrupt.WIDTH = 1;

   ilk_status_sync ss_sync_locked (.clk(rx_usr_clk),.din(sync_locked_pcsclk),.dout(sync_locked));
   defparam ss_sync_locked .WIDTH = NUM_LANES;

   ilk_status_sync ss_word_locked (.clk(rx_usr_clk),.din(word_locked_pcsclk),.dout(word_locked));
   defparam ss_word_locked .WIDTH = NUM_LANES;

   ilk_status_sync ss_rx_all_locked (.clk(rx_usr_clk),.din(rx_lanes_aligned_pcsclk),.dout(rx_lanes_aligned));
   defparam ss_rx_all_locked .WIDTH = 1;

   ilk_status_sync ss_irx_calendar (.clk(rx_usr_clk),.din(irx_calendar_macclk),.dout(irx_calendar));
   defparam ss_irx_calendar .WIDTH = CALENDAR_PAGES*16;

   ilk_status_sync ss_irx_overflow (.clk(rx_usr_clk),.din(irx_overflow_macclk),.dout(irx_overflow));
   defparam ss_irx_overflow .WIDTH = 1;

   ilk_status_sync ss_rdc_overflow (.clk(rx_usr_clk),.din(rdc_overflow_macclk),.dout(rdc_overflow));
   defparam ss_rdc_overflow .WIDTH = 1;

   ilk_status_sync ss_rx_rt_enable (.clk(rx_mac_clk),.din(rx_rt_enable),.dout(rx_rt_enable_macclk));
   defparam ss_rx_rt_enable .WIDTH = 1;

   ilk_status_sync ss_cfg_ignore_errtimer (.clk(rx_mac_clk),.din(cfg_ignore_errtimer),.dout(cfg_ignore_errtimer_macclk));
   defparam ss_cfg_ignore_errtimer .WIDTH = 16;

   ilk_status_sync ss_cfg_err_timeout (.clk(rx_mac_clk),.din(cfg_err_timeout),.dout(cfg_err_timeout_macclk));
   defparam ss_cfg_err_timeout .WIDTH = 16;

   ilk_status_sync ss_cfg_max_reterr (.clk(rx_mac_clk),.din(cfg_max_reterr),.dout(cfg_max_reterr_macclk));
   defparam ss_cfg_max_reterr .WIDTH = 5;

   ilk_status_sync ss_rx_rt_maxout_option (.clk(rx_mac_clk),.din(rx_rt_maxout_option),.dout(rx_rt_maxout_option_macclk));
   defparam ss_rx_rt_maxout_option .WIDTH = 1;

   ilk_status_sync ss_tx_all_locked (.clk(tx_usr_clk),.din(tx_lanes_aligned_pcsclk),.dout(tx_lanes_aligned));
   defparam ss_tx_all_locked .WIDTH = 1;

   ilk_status_sync ss_tx_all_locked_mac (.clk(tx_mac_clk),.din(tx_lanes_aligned_pcsclk),.dout(tx_lanes_aligned_macclk));
   defparam ss_tx_all_locked_mac .WIDTH = 1;

   ilk_status_sync ss_itx_hungry (.clk(tx_usr_clk),.din(itx_hungry_macclk),.dout(itx_hungry));
   defparam ss_itx_hungry .WIDTH = 1;

   ilk_status_sync ss_itx_underflow (.clk(tx_usr_clk),.din(itx_underflow_macclk),.dout(itx_underflow));
   defparam ss_itx_underflow .WIDTH = 1;

   ilk_status_sync ss_tx_rt_enable (.clk(tx_mac_clk),.din(tx_rt_enable),.dout(tx_rt_enable_macclk));
   defparam ss_tx_rt_enable .WIDTH = 1;

// ECC counter signals for tx_regroup
wire clean_cnt_err_tx_regroup; 
wire clean_cnt_err_tx_regroup_macclk;
wire [7:0] cnt_err_tx_regroup;        
wire [7:0] cnt_err_tx_regroup_mmclk;
wire clean_cnt_uncor_tx_regroup; 
wire clean_cnt_uncor_tx_regroup_macclk;
wire [7:0] cnt_uncor_tx_regroup;        
wire [7:0] cnt_uncor_tx_regroup_mmclk;
// ECC counter signals for rx_regroup 
wire clean_cnt_err_rx_regroup; 
wire clean_cnt_err_rx_regroup_usrclk;
wire [7:0] cnt_err_rx_regroup;        
wire [7:0] cnt_err_rx_regroup_mmclk;
wire clean_cnt_uncor_rx_regroup; 
wire clean_cnt_uncor_rx_regroup_usrclk;
wire [7:0] cnt_uncor_rx_regroup;        
wire [7:0] cnt_uncor_rx_regroup_mmclk;
// ECC counter signals for retrans ptr fifo rtptr
wire clean_cnt_err_rtptr; 
wire clean_cnt_err_rtptr_macclk;
wire [7:0] cnt_err_rtptr;        
wire [7:0] cnt_err_rtptr_mmclk;
wire clean_cnt_uncor_rtptr; 
wire clean_cnt_uncor_rtptr_macclk;
wire [7:0] cnt_uncor_rtptr;        
wire [7:0] cnt_uncor_rtptr_mmclk;
// ECC counter for retrans ptr fifo 
wire clean_cnt_err_txctl; 
wire clean_cnt_err_txctl_macclk;
wire [7:0] cnt_err_txctl;        
wire [7:0] cnt_err_txctl_mmclk;
wire clean_cnt_uncor_txctl; 
wire clean_cnt_uncor_txctl_macclk;
wire [7:0] cnt_uncor_txctl;        
wire [7:0] cnt_uncor_txctl_mmclk;
//generate // generate synchronizers if ECC is enable
//if (ECC_ENABLE) begin : ecc_signal_sync
////tx_regroup
    ilk_status_sync ss_clean_cnt_err_tx_regroup (.clk(tx_mac_clk),.din(clean_cnt_err_tx_regroup),.dout(clean_cnt_err_tx_regroup_macclk));
   defparam ss_clean_cnt_err_tx_regroup.WIDTH = 1;     
    ilk_status_sync ss_cnt_err_tx_regroup  (.clk(mm_clk),.din(cnt_err_tx_regroup),.dout(cnt_err_tx_regroup_mmclk));
   defparam ss_cnt_err_tx_regroup .WIDTH = 8;  
    ilk_status_sync ss_clean_cnt_uncor_tx_regroup (.clk(tx_mac_clk),.din(clean_cnt_uncor_tx_regroup),.dout(clean_cnt_uncor_tx_regroup_macclk));
   defparam ss_clean_cnt_uncor_tx_regroup.WIDTH = 1; 
    ilk_status_sync ss_cnt_uncor_tx_regroup  (.clk(mm_clk),.din(cnt_uncor_tx_regroup),.dout(cnt_uncor_tx_regroup_mmclk));
   defparam ss_cnt_uncor_tx_regroup .WIDTH = 8; 
////rx_regroup
    ilk_status_sync ss_clean_cnt_err_rx_regroup (.clk(rx_usr_clk),.din(clean_cnt_err_rx_regroup),.dout(clean_cnt_err_rx_regroup_usrclk));
   defparam ss_clean_cnt_err_rx_regroup.WIDTH = 1;     
    ilk_status_sync ss_cnt_err_rx_regroup  (.clk(mm_clk),.din(cnt_err_rx_regroup),.dout(cnt_err_rx_regroup_mmclk));
   defparam ss_cnt_err_rx_regroup .WIDTH = 8;  
    ilk_status_sync ss_clean_cnt_uncor_rx_regroup (.clk(rx_usr_clk),.din(clean_cnt_uncor_rx_regroup),.dout(clean_cnt_uncor_rx_regroup_usrclk));
   defparam ss_clean_cnt_uncor_rx_regroup.WIDTH = 1; 
    ilk_status_sync ss_cnt_uncor_rx_regroup  (.clk(mm_clk),.din(cnt_uncor_rx_regroup),.dout(cnt_uncor_rx_regroup_mmclk));
   defparam ss_cnt_uncor_rx_regroup .WIDTH = 8;  
////rtptr
    ilk_status_sync ss_clean_cnt_err_rtptr (.clk(tx_mac_clk),.din(clean_cnt_err_rtptr),.dout(clean_cnt_err_rtptr_macclk));
   defparam ss_clean_cnt_err_rtptr.WIDTH = 1;     
    ilk_status_sync ss_cnt_err_rtptr  (.clk(mm_clk),.din(cnt_err_rtptr),.dout(cnt_err_rtptr_mmclk));
   defparam ss_cnt_err_rtptr .WIDTH = 8;  
    ilk_status_sync ss_clean_cnt_uncor_rtptr (.clk(tx_mac_clk),.din(clean_cnt_uncor_rtptr),.dout(clean_cnt_uncor_rtptr_macclk));
   defparam ss_clean_cnt_uncor_rtptr.WIDTH = 1; 
    ilk_status_sync ss_cnt_uncor_rtptr  (.clk(mm_clk),.din(cnt_uncor_rtptr),.dout(cnt_uncor_rtptr_mmclk));
   defparam ss_cnt_uncor_rtptr .WIDTH = 8;  
////txctl
    ilk_status_sync ss_clean_cnt_err_txctl (.clk(tx_mac_clk),.din(clean_cnt_err_txctl),.dout(clean_cnt_err_txctl_macclk));
   defparam ss_clean_cnt_err_txctl.WIDTH = 1;     
    ilk_status_sync ss_cnt_err_txctl  (.clk(mm_clk),.din(cnt_err_txctl),.dout(cnt_err_txctl_mmclk));
   defparam ss_cnt_err_txctl .WIDTH = 8;  
    ilk_status_sync ss_clean_cnt_uncor_txctl (.clk(tx_mac_clk),.din(clean_cnt_uncor_txctl),.dout(clean_cnt_uncor_txctl_macclk));
   defparam ss_clean_cnt_uncor_txctl.WIDTH = 1; 
    ilk_status_sync ss_cnt_uncor_txctl  (.clk(mm_clk),.din(cnt_uncor_txctl),.dout(cnt_uncor_txctl_mmclk));
   defparam ss_cnt_uncor_txctl .WIDTH = 8;  
//end else begin 
    // ECC counter signals for tx_regroup
/*
    assign clean_cnt_err_tx_regroup_macclk      = 1'b0;
    assign cnt_err_tx_regroup_mmclk             = 8'b0;
    assign clean_cnt_uncor_tx_regroup_macclk    = 1'b0;
    assign cnt_uncor_tx_regroup_mmclk           = 9'b0;
    // ECC counter signals for rx_regroup 
    assign clean_cnt_err_rx_regroup_macclk    = 1'b0;
    assign cnt_err_rx_regroup_mmclk           = 9'b0;
    assign clean_cnt_uncor_rx_regroup_macclk    = 1'b0;
    assign cnt_uncor_rx_regroup_mmclk           = 9'b0;
    // ECC counter signals for retrans ptr fifo rtptr
    assign clean_cnt_err_rtptr_macclk    = 1'b0;
    assign cnt_err_rtptr_mmclk           = 9'b0;
    assign clean_cnt_uncor_rtptr_macclk    = 1'b0;
    assign cnt_uncor_rtptr_mmclk           = 9'b0;
    // ECC counter for retrans ptr fifo 
    assign clean_cnt_err_txctl_macclk    = 1'b0;
    assign cnt_err_txctl_mmclk           = 9'b0;
    assign clean_cnt_uncor_txctl_macclk    = 1'b0;
    assign cnt_uncor_txctl_mmclk           = 9'b0;
end 
endgenerate // end generate ECC signal synchronizers 
*/
   //////////////////////////////////////////////
   // merge the MM ports
   // mm_*_mac is the connection to the mac mm access
   // mm_*_pcs goes to the pcs mm access
   //////////////////////////////////////////////
   wire [15:0] rt2ack_lat_macclk;
   wire        rt2ack_lat_valid_macclk;

   wire [31:0] mm_rdata_mac, mm_rdata_pcs;
   wire        mm_rdata_valid_pcs;
   wire        mm_rdata_valid_mac;

   wire mm_read_mac  =  mm_addr[8] & mm_read;
   wire mm_read_pcs  = !mm_addr[8] & mm_read;
   wire mm_write_mac =  mm_addr[8] & mm_write;
   wire mm_write_pcs = !mm_addr[8] & mm_write;

   reg read_sel = 1'b0;

   always @(posedge mm_clk) begin
      if (mm_read_mac) read_sel <= 1'b0;
      if (mm_read_pcs) read_sel <= 1'b1;
   end

   always @(posedge mm_clk) begin
      if (read_sel) begin
         mm_rdata       <= mm_rdata_pcs;
         mm_rdata_valid <= mm_rdata_valid_pcs;
      end
      else begin
         mm_rdata       <= mm_rdata_mac;
         mm_rdata_valid <= mm_rdata_valid_mac;
      end
   end

   ilk_iw8_mac_ctl_status #(
      .CNTR_BITS  (CNTR_BITS),
      .RETRANS_ON (RETRANS_ON),
      .ECC_ENABLE (ECC_ENABLE),
      .DIAG_ON    (DIAG_ON)
   ) mcs (
        .rx_mac_srst         (rx_mac_srst),
        .mm_clk              (mm_clk),
        .mm_read             (mm_read_mac),
        .mm_write            (mm_write_mac),
        .mm_addr             (mm_addr),
        .mm_rdata            (mm_rdata_mac),
        .mm_rdata_valid      (mm_rdata_valid_mac),
        .mm_wdata            (mm_wdata),
        .tx_mac_clk          (tx_mac_clk),
        .tx_rtreply_inc      (tx_rtreply_inc_macclk),
        .rx_mac_clk          (rx_mac_clk),
        .rx_rt_req           (rx_rt_req_macclk),
        .rx_rt_reqnest       (rx_rt_reqnest_macclk),
        .rt2ack_lat          (rt2ack_lat_macclk),
        .rt2ack_lat_valid    (rt2ack_lat_valid_macclk),
        .rx_rt_interrupt     (rx_rt_interrupt_macclk),
        .rx_rt_int_cause     (rx_rt_int_cause_macclk),
         //Output from Mac address space are mm_clk domain
        .tx_rt_enable        (tx_rt_enable),
        .rx_rt_enable        (rx_rt_enable),
        .tx_force_crc24_err  (tx_force_crc24_err),
        .rx_force_crc24_err  (rx_force_crc24_err),
            .clean_cnt_err_tx_regroup       (clean_cnt_err_tx_regroup),
            .cnt_err_tx_regroup  (cnt_err_tx_regroup_mmclk),
            .clean_cnt_uncor_tx_regroup       (clean_cnt_uncor_tx_regroup),
            .cnt_uncor_tx_regroup  (cnt_uncor_tx_regroup_mmclk),                
            .clean_cnt_err_rx_regroup       (clean_cnt_err_rx_regroup),
            .cnt_err_rx_regroup  (cnt_err_rx_regroup_mmclk),
            .clean_cnt_uncor_rx_regroup       (clean_cnt_uncor_rx_regroup),
            .cnt_uncor_rx_regroup  (cnt_uncor_rx_regroup_mmclk),
            .clean_cnt_err_rtptr(clean_cnt_err_rtptr),
            .cnt_err_rtptr(cnt_err_rtptr_mmclk),
            .clean_cnt_uncor_rtptr(clean_cnt_uncor_rtptr),
            .cnt_uncor_rtptr(cnt_uncor_rtptr_mmclk),
            .clean_cnt_err_txctl(clean_cnt_err_txctl),
            .cnt_err_txctl(cnt_err_txctl_mmclk),
            .clean_cnt_uncor_txctl(clean_cnt_uncor_txctl),
            .cnt_uncor_txctl(cnt_uncor_txctl_mmclk),
        .cfg_ignore_errtimer (cfg_ignore_errtimer),
        .cfg_err_timeout     (cfg_err_timeout),
        .cfg_max_reterr      (cfg_max_reterr),
        .rx_rt_reset         (rx_rt_reset),
        .rx_rt_maxout_option (rx_rt_maxout_option)
   );

//////////////////////////////////////////////////////////////////
// PCS instanciation
//////////////////////////////////////////////////////////////////
generate
   if ( FAMILY == "Arria 10" ) begin : pcs_assembly_a10_gen
    ilk_hard_pcs_assembly_a10 #(
    //.USE_ATX            (USE_ATX),
      .DATA_RATE          (DATA_RATE),
    //.PLL_OUT_FREQ       (PLL_OUT_FREQ),
      .PLL_REFCLK_FREQ    (PLL_REFCLK_FREQ),
    //.INT_TX_CLK_DIV     (INT_TX_CLK_DIV),
    //.LANE_PROFILE       (LANE_PROFILE),
      .NUM_LANES          (NUM_LANES),
    //.NUM_SIXPACKS       (NUM_SIXPACKS),
    //.CNTR_BITS          (CNTR_BITS),
      .METALEN            (METALEN),
      .BYPASS_LOOSEFIFO (BYPASS_LOOSEFIFO),
      .SCRAM_CONST        (SCRAM_CONST),
      .INCLUDE_TEMP_SENSE (INCLUDE_TEMP_SENSE),
      .W_BUNDLE_TO_XCVR   (W_BUNDLE_TO_XCVR),
      .W_BUNDLE_FROM_XCVR (W_BUNDLE_FROM_XCVR),
      .MM_CLK_KHZ         (MM_CLK_KHZ),
      .MM_CLK_MHZ         (MM_CLK_MHZ)
   ) hah (
      .pll_ref_clk        (pll_ref_clk),
      // config and status port
      .mm_clk             (mm_clk),
      .mm_clk_locked      (reset_n & mm_clk_locked),   // fires whole analog reset sequence + CPU
      .mm_read            (mm_read_pcs),
      .mm_write           (mm_write_pcs),
      .mm_addr            (mm_addr),
      .mm_rdata           (mm_rdata_pcs),
      .mm_rdata_valid     (mm_rdata_valid_pcs),
      .mm_wdata           (mm_wdata),
      // chip HSIO pins
      .rx_pin             (rx_pin),
      .tx_pin             (tx_pin),
      // data streams, msb first on the wire
      .clk_tx_common      (clk_tx_common),
      .srst_tx_common     (srst_tx_common),
      .tx_control         (tx_control),
      .tx_din             (lane_txd),
      .tx_valid           (tx_valid),
      .tx_cadence         (tx_cadence),
      .clk_rx_common      (clk_rx_common),
      .srst_rx_common     (srst_rx_common),
      .tx_pcsfifo_pempty  (tx_pcsfifo_pempty),
      .tx_pcsfifo_pfull   (tx_pcsfifo_pfull),
      .tx_lanes_aligned   (tx_lanes_aligned_pcsclk),
      .rx_lanes_aligned   (rx_lanes_aligned_pcsclk),
      .rx_dout            (lane_rxd),
      .rx_control         (rx_control),
      .rx_wordlock        (word_locked_pcsclk),
      .rx_metalock        (sync_locked_pcsclk),
      .rx_crc32err        (crc32_err_pcsclk),
      .rx_valid           (rx_valid),  // expected to be the same   across lanes
      // for Arria 10
      .tx_pll_locked      (tx_pll_locked),
      .tx_serial_clk      (tx_serial_clk),
      .pll_powerdown      (tx_pll_powerdown_a10),
      .mm_waitrequest     (mm_waitrequest_a10)
    // Transceiver reconfiguration
    //.reconfig_to_xcvr   (reconfig_to_xcvr),
    //.reconfig_from_xcvr (reconfig_from_xcvr)
    );
   end else if ( ( FAMILY == "Stratix V" ) || ( FAMILY == "Arria V GZ" ) ) begin  : pcs_assembly_legacy_gen
   ilk_pcs_assembly #(
      .USE_ATX            (USE_ATX),
      .DATA_RATE          (DATA_RATE),
      .PLL_OUT_FREQ       (PLL_OUT_FREQ),
      .PLL_REFCLK_FREQ    (PLL_REFCLK_FREQ),
      .INT_TX_CLK_DIV     (INT_TX_CLK_DIV),
      .LANE_PROFILE       (LANE_PROFILE),
      .NUM_LANES          (NUM_LANES),
      .NUM_SIXPACKS       (NUM_SIXPACKS),
      .CNTR_BITS          (CNTR_BITS),
      .METALEN            (METALEN),
      .SCRAM_CONST        (SCRAM_CONST),
      .INCLUDE_TEMP_SENSE (INCLUDE_TEMP_SENSE),
      .W_BUNDLE_TO_XCVR   (W_BUNDLE_TO_XCVR),
      .W_BUNDLE_FROM_XCVR (W_BUNDLE_FROM_XCVR),
      .DIAG_ON            (DIAG_ON)
   ) hah (
      .pll_ref_clk        (pll_ref_clk),

      // config and status port
      .mm_clk             (mm_clk),
      .mm_clk_locked      (reset_n & mm_clk_locked),   // fires whole analog reset sequence + CPU
      .mm_read            (mm_read_pcs),
      .mm_write           (mm_write_pcs),
      .mm_addr            (mm_addr),
      .mm_rdata           (mm_rdata_pcs),
      .mm_rdata_valid     (mm_rdata_valid_pcs),
      .mm_wdata           (mm_wdata),

      // chip HSIO pins
      .rx_pin             (rx_pin),
      .tx_pin             (tx_pin),

      // data streams, msb first on the wire
      .clk_tx_common      (clk_tx_common),
      .srst_tx_common     (srst_tx_common),
      .tx_control         (tx_control),
      .tx_din             (lane_txd),
      .tx_valid           (tx_valid),
      .tx_cadence         (tx_cadence),

      .clk_rx_common      (clk_rx_common),
      .srst_rx_common     (srst_rx_common),
      .tx_pcsfifo_pempty  (tx_pcsfifo_pempty),
      .tx_lanes_aligned   (tx_lanes_aligned_pcsclk),
      .rx_lanes_aligned   (rx_lanes_aligned_pcsclk),
      .rx_dout            (lane_rxd),
      .rx_control         (rx_control),
      .rx_wordlock        (word_locked_pcsclk),
      .rx_metalock        (sync_locked_pcsclk),
      .rx_crc32err        (crc32_err_pcsclk),
      .rx_sh_err          (rx_sh_err),
      .rx_valid           (rx_valid),  // expected to be the same   across lanes
      // Transceiver reconfiguration
      .reconfig_to_xcvr   (reconfig_to_xcvr),
      .reconfig_from_xcvr (reconfig_from_xcvr_tmp)
   );
   defparam hah .MM_CLK_KHZ = MM_CLK_KHZ;
   defparam hah .MM_CLK_MHZ = MM_CLK_MHZ;
  end
endgenerate


      //////////////////////////////////////////////
      // Ilk TX MAC
      //////////////////////////////////////////////

   wire [65*NUM_LANES-1:0] itx_lanewords;

   ilk_rst_ctrl #(
      .CNTR_BITS (CNTR_BITS)
   ) rst_ctrl (
      .srst_tx_common (srst_tx_common),
      .srst_rx_common (srst_rx_common),
      .tx_mac_clk     (tx_mac_clk),
      .rx_mac_clk     (rx_mac_clk),
      .reset_n        (reset_n),
      .tx_usr_clk     (tx_usr_clk),
      .rx_usr_clk     (rx_usr_clk),
      .tx_mac_srst    (tx_mac_srst),
      .rx_mac_srst    (rx_mac_srst),
      .tx_usr_srst    (tx_usr_srst),
      .rx_usr_srst    (rx_usr_srst)
   );

   wire itx_ack;
   wire rx_lanes_aligned_tx_usr_clk;
   wire [16*CALENDAR_PAGES-1:0] itx_calendar_macclk;

   ilk_status_sync ss_itx_calendar (.clk(tx_mac_clk),.din(itx_calendar),.dout(itx_calendar_macclk));
   defparam ss_itx_calendar .WIDTH = CALENDAR_PAGES*16;

   ilk_status_sync ss0 (.clk(tx_usr_clk),.din(rx_lanes_aligned_pcsclk|TX_ONLY_MODE),.dout(rx_lanes_aligned_tx_usr_clk));
   defparam ss0 .WIDTH = 1;

   always @(posedge tx_usr_clk or posedge tx_usr_srst)
      if (tx_usr_srst) begin
        itx_ready <= 0;
      end
      else begin
       itx_ready <= rx_lanes_aligned_tx_usr_clk & itx_ack & tx_lanes_aligned;
      end

   wire [64*INTERNAL_WORDS-1:0] itx_din_words_buf;
   wire [7:0]                   itx_num_valid_buf;
   wire [7:0]                   itx_chan_buf;
   wire [1:0]                   itx_sop_buf;
   wire [1:0]                   itx_sob_buf;
   wire                         itx_eob_buf;
   wire [3:0]                   itx_eopbits_buf;
   wire [7:0]                   i_itx_num_valid;
   wire [1:0]                   i_itx_sop;
   wire [1:0]                   i_itx_sob;

   generate
     if (TX_DUAL_SEG) begin
         assign i_itx_num_valid = itx_num_valid;
         assign i_itx_sop       = itx_sop;
         assign i_itx_sob       = itx_sob;
     end else begin
         assign i_itx_num_valid = {itx_num_valid[7:4], 4'h0};
         assign i_itx_sop       = {itx_sop[1], itx_sop[0]};
         assign i_itx_sob       = {itx_sob[1], itx_sob[0]};
     end
   endgenerate

   ilk_iw8_enhance_scheduler #(
      .TX_PKTMOD_ONLY (TX_PKTMOD_ONLY)
   ) esr (
      .clk               (tx_usr_clk),
      .aclr              (tx_usr_srst),
      .itx_din_words     (itx_din_words),
      .itx_num_valid     (i_itx_num_valid),
      .itx_chan          (itx_chan),
      .itx_sop           (i_itx_sop[1:0]),
      .itx_sob           (i_itx_sob[1:0]),
      .itx_eob           (itx_eob),
      .itx_eopbits       (itx_eopbits),
      .itx_ifc_err       (itx_ifc_err),
      .burst_max_in      (burst_max_in),
      .burst_min_in      (burst_min_in),
      .itx_din_words_buf (itx_din_words_buf),
      .itx_num_valid_buf (itx_num_valid_buf),
      .itx_chan_buf      (itx_chan_buf),
      .itx_sop_buf       (itx_sop_buf),
      .itx_eopbits_buf   (itx_eopbits_buf),
      .itx_sob_buf       (itx_sob_buf),
      .itx_eob_buf       (itx_eob_buf)
   );

   wire [65*INTERNAL_WORDS-1:0] tx_stripe_din;        //Data words pull out for the purpose of UVM testing.
   wire                         tx_stripe_din_valid;  //Data valid pull out for the purpose of UVM testing.


   ilk_iw8_tx_datapath #(
      .CALENDAR_PAGES     (CALENDAR_PAGES),
      .LOG_CALENDAR_PAGES (LOG_CALENDAR_PAGES),
      .NUM_LANES          (NUM_LANES),
      .INTERNAL_WORDS     (INTERNAL_WORDS),
      .LOG_INTERNAL_WORDS (4),
      .ECC_ENABLE         (ECC_ENABLE),
      .RT_BUFFER_SIZE     (RT_BUFFER_SIZE),
      .BYPASS_LOOSEFIFO   (BYPASS_LOOSEFIFO),
      .RETRANS_ON         (RETRANS_ON),
      .INBAND_FLW_ON      (INBAND_FLW_ON),
      .DIAG_ON            (DIAG_ON),
      .TARGET_CHIP        (TARGET_CHIP)
   ) tdp (
      .clk                 (tx_mac_clk),
      .arst                (tx_mac_srst),
      .tx_usr_clk          (tx_usr_clk),
      .tx_usr_arst         (tx_usr_srst),
      .lane_clk            (clk_tx_common),
      .lane_arst           (srst_tx_common),
      .tx_rt_enable        (tx_rt_enable_macclk),
      .tx_force_crc24_err  (tx_force_crc24_err_macclk),
      .tx_rt_req           (tx_rt_req_macclk),
      .tx_rt_event_on      (tx_rt_event_on_macclk),
      .tx_rtreply_inc      (tx_rtreply_inc_macclk),
      .tx_lanes_aligned    (tx_lanes_aligned_macclk),
      .tx_pcsfifo_pempty   (tx_pcsfifo_pempty),
      .din_words           (itx_din_words_buf),
      .num_valid_din_words (itx_num_valid_buf),
      .chan                (itx_chan_buf),
      .sop                 (itx_sop_buf[1:0]),
      .sob                 (itx_sob_buf[1:0]),
      .eob                 (itx_eob_buf),
      .eopbits             (itx_eopbits_buf),
      .calendar            (itx_calendar_macclk), // bit 0 ~ chan 0
      .burst_max_in        (burst_max_in),
      .burst_short_in      (burst_short_in),
      .burst_min_in        (burst_min_in),
      .clean_cnt_err_tx_regroup       (clean_cnt_err_tx_regroup_macclk),
      .cnt_err_tx_regroup  (cnt_err_tx_regroup),
      .clean_cnt_uncor_tx_regroup       (clean_cnt_uncor_tx_regroup_macclk),
      .cnt_uncor_tx_regroup  (cnt_uncor_tx_regroup),
      .clean_cnt_err_rtptr(clean_cnt_err_rtptr_macclk),
      .cnt_err_rtptr(cnt_err_rtptr),
      .clean_cnt_uncor_rtptr(clean_cnt_uncor_rtptr_macclk),
      .cnt_uncor_rtptr(cnt_uncor_rtptr),
      .clean_cnt_err_txctl(clean_cnt_err_txctl_macclk),
      .cnt_err_txctl(cnt_err_txctl),
      .clean_cnt_uncor_txctl(clean_cnt_uncor_txctl_macclk),
      .cnt_uncor_txctl(cnt_uncor_txctl),
      .ack                 (itx_ack),
      .lanewords           (itx_lanewords),
      .lanewords_valid     (tx_valid_notbf),
      .lanewords_ack       ({NUM_LANES{tx_valid}}),
      .stripe_din          (tx_stripe_din),
      .stripe_din_valid    (tx_stripe_din_valid),
      .hungry              (itx_hungry_macclk),
      .underflow           (itx_underflow_macclk),
      .overflow            (itx_overflow)
   );

   // MAC -> PCS
   generate
      for (i=0; i<NUM_LANES; i=i+1) begin : ltl
         always @(posedge clk_tx_common) begin
            if (srst_tx_common) begin
               lane_txd [(i+1)*64-1:i*64] <= 64'h0;
               tx_control [i] <= 1'b0;
            end
            else begin
               if (tx_valid) begin
                  if (SWAP_TX_LANES)
                     {tx_control[i], lane_txd[(i+1)*64-1:i*64]} <= itx_lanewords [(NUM_LANES-1-i+1)*65-1:(NUM_LANES-1-i)*65];
                  else
                     {tx_control[i], lane_txd[(i+1)*64-1:i*64]} <= itx_lanewords [(i+1)*65-1:i*65];
               end
            end
         end
      end
   endgenerate

   //////////////////////////////////////////////
   // Ilk RX MAC
   //////////////////////////////////////////////

   reg       [65*NUM_LANES-1:0] irx_lanewords;
   wire [65*INTERNAL_WORDS-1:0] irx_outwords;
   wire                         irx_outwords_valid;
   wire      [65*NUM_LANES-1:0] lanewords_buf;
   wire                         lanewords_buf_valid;
   wire         [NUM_LANES-1:0] rx_framing_tmp;
   // PCS -> MAC

   // synthesis translate_off
   wire [64:0] lane_word0,  lane_word1,  lane_word2,  lane_word3,  lane_word4,  lane_word5,  lane_word6,  lane_word7;
   wire [64:0] lane_word8,  lane_word9,  lane_word10, lane_word11, lane_word12, lane_word13, lane_word14, lane_word15;
   wire [64:0] lane_word16, lane_word17, lane_word18, lane_word19, lane_word20, lane_word21, lane_word22, lane_word23;

   assign {lane_word0,  lane_word1,  lane_word2,  lane_word3,  lane_word4,  lane_word5,  lane_word6,  lane_word7,
           lane_word8,  lane_word9,  lane_word10, lane_word11} = lane_rxd;

   // synthesis translate_on
   generate
      for (i=0; i<NUM_LANES; i=i+1) begin : lrl

         assign rx_framing_tmp [i] = rx_control[i] && !lane_rxd[i*64+63];

         always @(posedge clk_rx_common) begin
            if (srst_rx_common) begin
                irx_lanewords [(i+1)*65-1:i*65] <= 65'h0;
            end
            else begin
               if (rx_valid[i]) begin
                  if (SWAP_RX_LANES)
                     irx_lanewords [(i+1)*65-1:i*65] <= {rx_control[NUM_LANES-1-i], lane_rxd [(NUM_LANES-i)*64-1:(NUM_LANES-1-i)*64]};
                  else
                     irx_lanewords [(i+1)*65-1:i*65] <= {rx_control[i], lane_rxd [(i+1)*64-1:i*64]};
               end
            end
         end
      end
   endgenerate

   // call 2 out of 3 lanes showing framing a drop
   wire rx_framing_decision = (rx_framing_tmp[0] & rx_framing_tmp[1]) |
                              (rx_framing_tmp[0] & rx_framing_tmp[2]) |
                              (rx_framing_tmp[1] & rx_framing_tmp[2]);

   reg irx_lanewords_valid;
   always @(posedge clk_rx_common) begin
      if (srst_rx_common) irx_lanewords_valid <= 1'b0;
      else irx_lanewords_valid <= rx_valid[0] && !rx_framing_decision;
   end

   // switch from PCS clock domain to system domain
   generate
     if (BYPASS_RDC) begin
        assign lanewords_buf       = irx_lanewords;
        assign lanewords_buf_valid = irx_lanewords_valid;
        assign rdc_overflow_macclk = 1'b0;
     end
     else begin
        ilk_smoothed_domain_change rdc (
           .wrclk       (clk_rx_common),
           .arst        (srst_rx_common),
           .wdata       (irx_lanewords),
           .wdata_valid (irx_lanewords_valid),
           .overflow    (rdc_overflow_macclk),

           .rdclk       (rx_mac_clk),
           .rdata       (lanewords_buf),
           .rdata_valid (lanewords_buf_valid)
        );
        defparam rdc .WIDTH = 65*NUM_LANES;
     end
   endgenerate

   // synthesis translate_off
   wire [64:0] lane_word_buf0,  lane_word_buf1,  lane_word_buf2,  lane_word_buf3;
   wire [64:0] lane_word_buf4,  lane_word_buf5,  lane_word_buf6,  lane_word_buf7;
   wire [64:0] lane_word_buf8,  lane_word_buf9,  lane_word_buf10, lane_word_buf11;

   assign {lane_word_buf0,  lane_word_buf1,  lane_word_buf2,  lane_word_buf3,
           lane_word_buf4,  lane_word_buf5,  lane_word_buf6,  lane_word_buf7,
           lane_word_buf8,  lane_word_buf9,  lane_word_buf10, lane_word_buf11} = lanewords_buf;

   // synthesis translate_on

   // Ilk rx mac guts
   wire [INTERNAL_WORDS-1:0]    crc24_word_err;   //This will be aligned with eopbits and sent to user receiver side.
   wire [65*INTERNAL_WORDS-1:0] rx_stripe_dout;        //Data words pull out for the purpose of UVM testing.
   wire                         rx_stripe_dout_valid;   //Data valid pull out for the purpose of UVM testing.

   ilk_iw8_rx_datapath #(
      .NUM_LANES          (NUM_LANES),
      .INTERNAL_WORDS     (INTERNAL_WORDS),
      .BYPASS_RBF         (BYPASS_RBF),
      .CALENDAR_PAGES     (CALENDAR_PAGES),
      .LOG_CALENDAR_PAGES (LOG_CALENDAR_PAGES),
      .RETRANS_ON         (RETRANS_ON),
      .INBAND_FLW_ON      (INBAND_FLW_ON),
      .CRC24_ALIGN_ON     (CRC24_ALIGN_ON),
      .TARGET_CHIP        (TARGET_CHIP)
   ) rdp (
      .clk                 (rx_mac_clk),
      .arst                (rx_mac_srst),
      .lanewords           (lanewords_buf),
      .lanewords_valid     (lanewords_buf_valid),
      .outwords            (irx_outwords),
      .outwords_valid      (irx_outwords_valid),
      .crc24_word_err      (crc24_word_err),
      .crc24_err           (crc24_err_macclk),
      .overflow            (irx_overflow_macclk),
      .calendar            (irx_calendar_macclk),
      .rx_fifo_full        (rx_fifo_full_macclk),
      .stripe_dout         (rx_stripe_dout),
      .stripe_dout_valid   (rx_stripe_dout_valid),
      .cfg_ignore_errtimer (cfg_ignore_errtimer_macclk),
      .cfg_err_timeout     (cfg_err_timeout_macclk),
      .cfg_max_reterr      (cfg_max_reterr_macclk),
      .rx_rt_enable        (rx_rt_enable_macclk),
      .rx_rt_reset         (rx_rt_reset_macclk),
      .rx_force_crc24_err  (rx_force_crc24_err_macclk),
      .rx_rt_maxout_option (rx_rt_maxout_option_macclk),
      .rx_rt_req           (rx_rt_req_macclk),
      .rx_rt_reqnest       (rx_rt_reqnest_macclk),
      .rt2ack_lat          (rt2ack_lat_macclk),
      .rt2ack_lat_valid    (rt2ack_lat_valid_macclk),
      .rx_rt_interrupt     (rx_rt_interrupt_macclk),
      .rx_rt_int_cause     (rx_rt_int_cause_macclk),
      .rx_rt_event_on      (rx_rt_event_on_macclk)
   );

   // Create increment signals for the debug counters
   always@ (posedge rx_usr_clk) begin
      sop_cntr_inc <= |irx_sop;
      eop_cntr_inc <= |irx_eopbits;
   end

   // The packet_regoup_8 logic assume the traffic is packet based channelization. The channel number
   // is valid during sop cycle.

   ilk_packet_regroup_8 #(
      .RXFIFO_ADDR_WIDTH (RXFIFO_ADDR_WIDTH),
      .PACKET_MOD_ONLY   (RX_PKTMOD_ONLY),
      .RX_DUAL_SEG(RX_DUAL_SEG),
      .ECC_ENABLE(ECC_ENABLE)
   ) rg0 (
      //inputs
      .clk                      (rx_mac_clk),
      .arst                     (rx_mac_srst),
      .rx_usr_clk               (rx_usr_clk),
      .rx_usr_arst              (rx_usr_srst),
      .rx_rt_enable             (rx_rt_enable_macclk),
      .datwords                 (irx_outwords),
      .datwords_valid           (irx_outwords_valid),
      .crc24_word_err           (crc24_word_err),
      //outputs
      .dout                     (core_irx_dout_words),
      .num_dout_words_valid     (core_irx_num_valid[7:4]),
      .num_dout_words_valid_mid (core_irx_num_valid[3:0]),
      .dout_sop                 (core_irx_sop[1]),
      .dout_sop_mid             (core_irx_sop[0]),
      .dout_sob                 (core_irx_sob[1]),
      .dout_sob_mid             (core_irx_sob[0]),
      .dout_eob                 (core_irx_eob),
      .dout_eopbits             (core_irx_eopbits),
      .dout_channel             (core_irx_chan),
      .dout_crc24_err           (core_irx_crc24_err),
      .holding                  (rxfifo_fill_level),
      .clean_cnt_err_rx_regroup (clean_cnt_err_rx_regroup_usrclk),
      .cnt_err_rx_regroup       (cnt_err_rx_regroup),
      .clean_cnt_uncor_rx_regroup (clean_cnt_uncor_rx_regroup_usrclk),
      .cnt_uncor_rx_regroup     (cnt_uncor_rx_regroup),
      .overflow                 (rg_overflow)
   );

  generate
    if (ERR_HANDLER_ON) begin
     ilk_err_handler #(
        .INTERNAL_WORDS (INTERNAL_WORDS)
     ) eh0 (
        .rx_usr_clk          (rx_usr_clk),
        .rx_usr_srst         (rx_usr_srst),

        .irx_dout_words      (irx_dout_words),
        .irx_num_valid       (irx_num_valid),
        .irx_sop             (irx_sop),
        .irx_sob             (irx_sob),
        .irx_eob             (irx_eob),
        .irx_chan            (irx_chan),
        .irx_eopbits         (irx_eopbits),
        .irx_err             (irx_err),

        .core_irx_dout_words (core_irx_dout_words),
        .core_irx_num_valid  (core_irx_num_valid),
        .core_irx_sop        (core_irx_sop),
        .core_irx_sob        (core_irx_sob),
        .core_irx_eob        (core_irx_eob),
        .core_irx_chan       (core_irx_chan),
        .core_irx_eopbits    (core_irx_eopbits),
        .core_irx_crc24_err  (core_irx_crc24_err)
     );
    end else begin
        assign irx_dout_words = core_irx_dout_words;
        assign irx_num_valid  = core_irx_num_valid;
        assign irx_sop        = core_irx_sop;
        assign irx_sob        = core_irx_sob;
        assign irx_eob        = core_irx_eob;
        assign irx_chan       = core_irx_chan;
        assign irx_eopbits    = core_irx_eopbits;
        assign irx_err        = core_irx_crc24_err;
    end
  endgenerate

endmodule
