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

//****************************************************************************
// Top for kr_10gphy IP
// Contains the Sequencer, AN, LT, Avalon Registers, etc.
// Includes the sv_xcvr_native
//****************************************************************************
`define CTL_BFL 9 
`define TOTAL_XGMII_LANE 8
`define TOTAL_DATA_PER_LANE 8
`define TOTAL_CONTROL_PER_LANE 1
`define TOTAL_SIGNAL_PER_LANE (`TOTAL_DATA_PER_LANE+`TOTAL_CONTROL_PER_LANE)

`define TCLK                     6400  // for FEC test, remove once integration is done


`timescale 1 ps / 1 ps

import altera_xcvr_functions::*;

module altera_xcvr_10gbase_kr
  #(
  parameter DEVICE_FAMILY = "Stratix V",  // select native PHY device family
  parameter SYNTH_AN      = 1,            // Synthesize/include the AN logic
  parameter SYNTH_LT      = 1,            // Synthesize/include the LT logic
  parameter SYNTH_SEQ     = 1,            // Synthesize/include Sequencer logic
  parameter SYNTH_GIGE    = 0,            // Synthesize/include the GIGE logic
  parameter SYNTH_GMII    = 0,            // Synthesize/include the GMII PCS
  parameter SYNTH_FEC     = 0,            // Synthesize/include the FEC logic
  parameter PHY_IDENTIFIER = 32'h 00000000, // PHY Identifier 
  parameter DEV_VERSION    = 16'h 0001 ,  //  Customer Phy's Core Version
  parameter SYNTH_SGMII    = 1,           // Enable SGMII logic for synthesis
  parameter SYNTH_CL37ANEG = 0,           // Synth GIGE AN logic (Clause 37)
  parameter SYNTH_1588_1G  = 0,            // Synthesize/include 1588 1G logic
  parameter SYNTH_1588_10G = 0,           // Synthesize/include 1588 10G logic
  parameter HIGH_PRECISION_LATADJ = 1,    // Determine latency_adj port width
  parameter LATADJ_WIDTH_10G = (HIGH_PRECISION_LATADJ) ? 16 : 12,    // Determine latency_adj port width
  parameter LATADJ_WIDTH_1G  = (HIGH_PRECISION_LATADJ) ? 22 : 18,    // Determine latency_adj port width
  // Sequencer parameters not used in the AN block
  parameter LFT_R_MSB     = 6'd63,        // Link Fail Timer MSB for BASE-R PCS
  parameter LFT_R_LSB     = 10'd0,        // Link Fail Timer lsb for BASE-R PCS
  parameter LFT_X_MSB     = 6'd6,         // Link Fail Timer MSB for BASE-X PCS
  parameter LFT_X_LSB     = 10'd0,        // Link Fail Timer lsb for BASE-X PCS
  // LT parameters
  parameter OPTIONAL_RXEQ = 0,            //  Enable RX Equalization through link training
  parameter BERWIDTH      = 12,           // Width (4-8) of the Bit Error counter
  parameter TRNWTWIDTH    = 7,            // Width (7,8) of Training Wait counter
  parameter MAINTAPWIDTH  = 6,            // Width of the Main Tap control
  parameter POSTTAPWIDTH  = 5,            // Width of the Post Tap control
  parameter PRETAPWIDTH   = 4,            // Width of the Pre Tap control
  parameter VMAXRULE      = 6'd60,        // VOD+Post+Pre <= Device Vmax 1200mv
  parameter VMINRULE      = 6'd9,         // VOD-Post-Pre >= Device VMin 165mv
  parameter VODMINRULE    = 6'd24,        // VOD >= IEEE VOD Vmin of 440mV
  parameter VPOSTRULE     = 5'd31,        // Post_tap <= VPOST
  parameter VPRERULE      = 4'd15,        // Pre_tap <= VPRE
  parameter PREMAINVAL    = 6'd60,        // Preset Main tap value
  parameter PREPOSTVAL    = 5'd0,         // Preset Post tap value
  parameter PREPREVAL     = 4'd0,         // Preset Pre tap value
  parameter INITMAINVAL   = 6'd52,        // Initialize Main tap value
  parameter INITPOSTVAL   = 5'd30,        // Initialize Post tap value
  parameter INITPREVAL    = 4'd5,         // Initialize Pre tap value
  // AN parameters
  parameter AN_PAUSE      = 3'b000,       // Pause ability, depends upon MAC  
  parameter AN_TECH       = 6'b00_0101,   // Tech ability, only 10G and GIGE valid
                                         // bit-0 = GigE, bit-1 = XAUI
                                         // bit-2 = 10G , bit-3 = 40G BP
                                         // bit 4 = 40G-CR4, bit 5 = 100G-CR10
//  parameter AN_FEC         = 2'b00,        // FEC, bit1=request, bit0=ability
  parameter AN_SELECTOR    = 5'b0_0001,    // AN selector field 802.3 = 5'd1
  parameter PLL_CNT        = 2,    // This is needed as XCVR- to and from size will change with param
  parameter CAPABLE_FEC    = 0,    // FEC ability on power on
  parameter ENABLE_FEC     = 0,    // FEC request on power on
  parameter ERR_INDICATION = 0,    // Turn error indication on/off
  parameter GOOD_PARITY    = 4,    // good parity threshold  
  parameter INVALD_PARITY  = 8,    // invalid parity threshold 
  parameter USE_M20K       = 1,    // Use M20K for FEC buffer
  // PHY parameters
  parameter REF_CLK_FREQ_1G   = "125.0 Mhz",
  parameter REF_CLK_FREQ_10G  = "322.265625 Mhz",
  parameter PLL_TYPE_10G      = "ATX",
  parameter PLL_TYPE_1G       = "CMU",
  parameter EN_SYNC_E         = 0
  )(
     // clocks
  input  wire     pll_ref_clk_10g,      // pll_ref_clk.clk
  input  wire     pll_ref_clk_1g,      // pll_ref_clk.clk
  input  wire     cdr_ref_clk_10g,      // pll_ref_clk.clk
  input  wire     cdr_ref_clk_1g,      // pll_ref_clk.clk
  input  wire     xgmii_tx_clk,         // user XGMII tx_clk input
  output wire     rx_recovered_clk,     // user recovered clk output
  input  wire     xgmii_rx_clk,         // user XGMII rx_clk output
  input  wire     calc_clk_1g,
  input wire                   tx_coreclkin_1g,   // 8G PCS PLD Tx parallel clock input
  input wire                   rx_coreclkin_1g,   // 8G PCS PLD Tx parallel clock input
  output wire                  tx_clkout_1g,      // TX Parallel clock output
  output wire                  rx_clkout_1g,      // RX parallel clock output
     // Reset inputs 
  input   wire         pll_powerdown_10g, 
  input   wire         pll_powerdown_1g, 
  input   wire         tx_analogreset,
  input   wire         tx_digitalreset,
  input   wire         rx_analogreset,
  input   wire         rx_digitalreset,
  input   wire         usr_an_lt_reset,
  input   wire         usr_seq_reset,
  input   wire         usr_fec_reset,             
  input   wire         usr_soft_10g_pcs_reset,    
     // Avalon I/F
  input  wire         mgmt_clk,         //       phy_mgmt_clk.clk
  input  wire         mgmt_clk_reset,   // phy_mgmt_clk_reset.reset
  input  wire [7:0]   mgmt_address,     //           phy_mgmt.address/data/opatki/12.0sp1/p4/regtest/quartus/c5/5cgxfc7d6f31_atso/cust_bitslip_wa_3g_32bit_1ch/reg_test_atso/
  input  wire         mgmt_read,        //                   .read
  output wire [31:0]  mgmt_readdata,    //                   .readdata
  output wire         mgmt_waitrequest, //                   .waitrequest
  input  wire         mgmt_write,       //                   .write
  input  wire [31:0]  mgmt_writedata,   //                   .writedata
     // reconfig PHY
  output wire [altera_xcvr_functions::get_custom_reconfig_from_width (DEVICE_FAMILY,"duplex",1,PLL_CNT,1)-1:0] reconfig_from_xcvr,
  input  wire [altera_xcvr_functions::get_custom_reconfig_to_width   (DEVICE_FAMILY,"duplex",1,PLL_CNT,1)-1:0] reconfig_to_xcvr,
    // GMII interface
  input  wire [7:0]           gmii_tx_d,
  output wire [7:0]           gmii_rx_d,
  input  wire                 gmii_tx_en,
  input  wire                 gmii_tx_err,
  output wire                 gmii_rx_err,
  output wire                 gmii_rx_dv,
    // GMII Status
  output wire                 led_an,
  output wire                 led_char_err,
  output wire                 led_disp_err,
  output wire                 led_link,
  output wire                 tx_pcfifo_error_1g,  //Phase comp. FIFO full/empty   
  output wire                 rx_pcfifo_error_1g,  //Phase comp. FIFO full/empty   
  output wire                 rx_rlv,    
  output wire                 rx_syncstatus,
  input  wire                 rx_clkslip,
  input  wire                 mode_1g_10gbar ,
    // MII interface
  output wire                 mii_tx_clkena,
  output wire                 mii_tx_clkena_half_rate,
  input  wire[3:0]            mii_tx_d,
  input  wire                 mii_tx_en,
  input  wire                 mii_tx_err,

  output wire                 mii_rx_clkena,
  output wire                 mii_rx_clkena_half_rate,
  output wire[3:0]            mii_rx_d,
  output wire                 mii_rx_dv,
  output wire                 mii_rx_err,
    
  output reg [1:0]            mii_speed_sel,
    // XGMII interface     
  input wire  [71:0]      xgmii_tx_dc,       // XGMII data to PMA.
  output wire [71:0]      xgmii_rx_dc,       // XGMII data from PMA.
  output wire         pll_locked,           //         pll_locked.export
  output wire         rx_is_lockedtodata,   // rx_is_lockedtodata.export
  output wire         tx_cal_busy,
  output wire         rx_cal_busy,
  output wire         rx_data_ready,
  output wire         rx_block_lock,
  output wire         rx_hi_ber,
  output wire         tx_serial_data,       //     tx_serial_data.export
  input  wire         rx_serial_data,       //     rx_serial_data.export
    // IEEE-1588 status
  output wire [LATADJ_WIDTH_10G-1 : 0]  rx_latency_adj_10g,
  output wire [LATADJ_WIDTH_10G-1 : 0]  tx_latency_adj_10g,
  output wire [LATADJ_WIDTH_1G-1  : 0]  rx_latency_adj_1g,
  output wire [LATADJ_WIDTH_1G-1  : 0]  tx_latency_adj_1g,
  
    // may go away and/or change at some point
  input wire             lcl_rf,            // local device Remote Fault = D13
  input wire [3:0]       tm_in_trigger,     // Start the test mode
  output reg [3:0]       tm_out_trigger,    // test mode has started
  
     // for the reconfig Interface
  input wire              rc_busy,       // reconfig is busy
  output reg              lt_start_rc,   // start the TX EQ reconfig
  output reg [MAINTAPWIDTH-1:0] main_rc, // main tap value for reconfig
  output reg [POSTTAPWIDTH-1:0] post_rc, // post tap value for reconfig
  output reg [PRETAPWIDTH-1:0]  pre_rc,  // pre tap value for reconfig
  output reg [2:0]       tap_to_upd,     // specific TX EQ tap to update
                                         // bit-2 = main, bit-1 = post, ...
  output wire            en_lcl_rxeq,    // Enable local RX Equalization
  input  wire            rxeq_done,      // Local RX Equalization is finished
  output reg             seq_start_rc,   // start the PCS reconfig
  output wire            dfe_start_rc,   // start DFE reconfig
  output wire [1:0]      dfe_mode,       // DFE mode 00=disabled, 01=triggered, 10=continuous
  output wire            ctle_start_rc,  // start CTLE reconfig
  output wire [3:0]      ctle_rc,        // CTLE manual setting
  output wire [1:0]      ctle_mode,      // CTLE mode 00=manual, 01=one-time, 10=continuous
  output reg [5:0]       pcs_mode_rc,    // PCS mode for reconfig - 1 hot
                                         // bit 0 = AN mode = low_lat, PLL LTR
                                         // bit 1 = LT mode = low_lat, PLL LTD
                                         // bit 2 = 10G data mode = 10GBASE-R
                                         // bit 3 = GigE data mode = 8G PCS
                                         // bit 4 = XAUI data mode = future?
                                         // bit 5 = 10G-FEC = future?
       // Daisy Chain Mode input for local TX update/status
  input wire          dmi_mode_en,        // Enable Daisy Chain mode
  input wire          dmi_frame_lock,     // SM has lock to training frames
  input wire          dmi_rmt_rx_ready,   // remote RX ready = status[15]
  input wire [5:0]    dmi_lcl_coefl,      // local update low bits[5:0]
  input wire [13:12]  dmi_lcl_coefh,      // local update high bits[13:12]
  input wire          dmi_lcl_upd_new,    // local update has changed
  input wire          dmi_rx_trained,     // SM is finished local training
       // Daisy Chain Mode outputs of remote update/status
  output reg          dmo_frame_lock,     // SM has lock to training frames
  output reg          dmo_rmt_rx_ready,   // remote RX ready = status[15]
  output reg [5:0]    dmo_lcl_coefl,      // local update low bits[5:0]
  output reg [13:12]  dmo_lcl_coefh,      // local update high bits[13:12]
  output reg          dmo_lcl_upd_new,    // local update has changed
  output reg          dmo_rx_trained,     // SM is finished local training
      // uP Mode inputs for remote EQ Optimization
  input wire             upi_mode_en,    // Enable uP mode
  input wire [1:0]       upi_adj,        // select the active tap
  input wire             upi_inc,        // send the increment command 
  input wire             upi_dec,        // send the decrement command 
  input wire             upi_pre,        // send the preset command 
  input wire             upi_init,       // send the initialize command
  input wire             upi_st_bert,    // start the BER timer
  input wire             upi_train_err,  // Training Error indication
  input wire             upi_lock_err,   // Training frame lock Error
  input wire             upi_rx_trained, // local RX is Trained
      // uP Mode outputs for remote EQ Optimization
  output reg             upo_enable,     // Enable uP = ~re_start & en
  output reg             upo_frame_lock, // Receiver has Training frame lock
  output reg             upo_cm_done,    // Master SM done with handshake 
  output reg             upo_bert_done,  // BER Timer at max count 
  output reg [BERWIDTH-1:0] upo_ber_cnt, // BER counter value 
  output reg             upo_ber_max,    // BER counter roll-over
  output reg             upo_coef_max    // Remote Coefficients at max/min
  );

import altera_xcvr_functions::*;

//****************************************************************************
// Define Parameters 
//****************************************************************************
  localparam AN_FEC = (SYNTH_FEC)? {ENABLE_FEC[0],CAPABLE_FEC[0]} : 2'b00 ; // FEC, bit1=request, bit0=ability- only when FEC

  // Apply embedded false path timing constraints
  // (* altera_attribute  = "-name SDC_STATEMENT \"set_false_path -from [get_registers {*|rx_lnk_cdwd[*]}] -to [get_registers {*an_arb_sm:ARB|*}]\"" *)
  localparam  SYNC_AN_CONSTRAINT   = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*AUTO_NEG|an_rx_sm:RX_SM|rx_lnk_cdwd[*]}] -to [get_registers {*AUTO_NEG|an_arb_sm:ARB|*}]\""};
  localparam  SYNC_LTRX_CONSTRAINT = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*LINK_TRAIN|lt_rx_data:RX_DATAPATH|lcl_coef*}] -to [get_registers {*LINK_TRAIN|lt_lcl_coef:LCL_COEF|*}]\""};
  localparam  SYNC_LTTX_CONSTRAINT = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*LINK_TRAIN|lt_rmt_txeq:RMT_TX_EQ|rmt_cmd*}]   -to [get_registers {*LINK_TRAIN|lt_tx_data:TX_DATAPATH|*}]\""};
  localparam  SYNC_LT_CONSTRAINT   = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*LINK_TRAIN|lt_rmt_txeq:RMT_TX_EQ|lt_coef_mstr:COEFF_MASTER|cf_mstr_sm.CMSTR_HOLD}] -to [get_registers {*LINK_TRAIN|lt_tx_data:TX_DATAPATH|*}]\""};

  localparam  SDC_LT_CONSTRAINTS = {SYNC_LTRX_CONSTRAINT,";",SYNC_LTTX_CONSTRAINT,";",SYNC_LT_CONSTRAINT};
  // need to apply before real line of code
  // (* altera_attribute = SDC_CONSTRAINTS *)

  localparam SDC_GIGE_TO_10G = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*kr_gige_pcs_top:GIGE_ENABLE.GMII_PCS_ENABLED.kr_gige_pcs_top*}] -to  [get_registers {*SV_NATIVE.altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_10g_tx_pcs_rbc:inst_sv_hssi_10g_tx_pcs*}]\""};
  localparam SDC_10G_TO_GIGE = {"-name SDC_STATEMENT \"set_false_path -from  [get_registers {*SV_NATIVE.altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_10g_rx_pcs_rbc:inst_sv_hssi_10g_rx_pcs*}] -to  [get_registers {*kr_gige_pcs_top:GIGE_ENABLE.GMII_PCS_ENABLED.kr_gige_pcs_top*}]\""};
  localparam SDC_8G_TO_AN    = {"-name SDC_STATEMENT \"set_false_path -from  [get_registers {*SV_NATIVE.altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_8g_rx_pcs_rbc:inst_sv_hssi_8g_rx_pcs*}] -to  [get_registers -nowarn {*AN_GEN.an_top*}]\""};
  localparam SDC_8G_TO_LT    = {"-name SDC_STATEMENT \"set_false_path -from  [get_registers {*SV_NATIVE.altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_8g_rx_pcs_rbc:inst_sv_hssi_8g_rx_pcs*}] -to  [get_registers -nowarn {*LT_GEN.lt_top*}]\""};
  localparam SDC_AN_TO_8G    = {"-name SDC_STATEMENT \"set_false_path -from  [get_registers -nowarn {*AN_GEN.an_top*}] -to  [get_registers {*SV_NATIVE.altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_8g_rx_pcs_rbc:inst_sv_hssi_8g_rx_pcs*}]\""};
  localparam SDC_LT_TO_8G    = {"-name SDC_STATEMENT \"set_false_path -from  [get_registers -nowarn {*LT_GEN.lt_top*}] -to  [get_registers {*SV_NATIVE.altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_8g_rx_pcs_rbc:inst_sv_hssi_8g_rx_pcs*}]\""};
  localparam SDC_GIGE_PCS    = {SDC_GIGE_TO_10G,";",SDC_10G_TO_GIGE,";",SDC_8G_TO_AN,";",SDC_8G_TO_LT,";",SDC_AN_TO_8G,";",SDC_LT_TO_8G};

  localparam  SOFTFIFO_TX_WR_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *soft10Gfifos.tx_wr_rstn*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam  SOFTFIFO_TX_RD_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *soft10Gfifos.tx_rd_rstn*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam  SOFTFIFO_RX_WR_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *soft10Gfifos.rx_wr_rstn*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam  SOFTFIFO_RX_RD_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *soft10Gfifos.rx_rd_rstn*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam  DCFIFO_TX_WR_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set from_regs [get_registers -nowarn *soft10Gfifos.tx_wr_rstn*]; set to_regs [get_registers -nowarn *soft10Gfifos*dcfifo_componenet*]; if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {set_false_path -from $from_regs -to $to_regs}\""};
  localparam  DCFIFO_TX_RD_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set from_regs [get_registers -nowarn *soft10Gfifos.tx_rd_rstn*]; set to_regs [get_registers -nowarn *soft10Gfifos*dffpipe*wraclr*]; if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {set_false_path -from $from_regs -to $to_regs}\""};
  localparam  DCFIFO_RX_WR_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set from_regs [get_registers -nowarn *soft10Gfifos.rx_wr_rstn*]; set to_regs [get_registers -nowarn *soft10Gfifos*dcfifo_componenet*]; if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {set_false_path -from $from_regs -to $to_regs}\""};
  localparam  DCFIFO_RX_RD_RSTN_CONSTRAINT    = {"-name SDC_STATEMENT \"set from_regs [get_registers -nowarn *soft10Gfifos.rx_rd_rstn*]; set to_regs [get_registers -nowarn *soft10Gfifos*dffpipe*wraclr*]; if {[llength [query_collection -report -all $from_regs]] > 0 && [llength [query_collection -report -all $to_regs]] > 0} {set_false_path -from $from_regs -to $to_regs}\""};
  localparam  SDC_1588_CONSTRAINTS = {SOFTFIFO_TX_WR_RSTN_CONSTRAINT,";",SOFTFIFO_TX_RD_RSTN_CONSTRAINT,";",DCFIFO_TX_WR_RSTN_CONSTRAINT,";",DCFIFO_TX_RD_RSTN_CONSTRAINT,";",SOFTFIFO_RX_WR_RSTN_CONSTRAINT,";",SOFTFIFO_RX_RD_RSTN_CONSTRAINT,";",DCFIFO_RX_WR_RSTN_CONSTRAINT,";",DCFIFO_RX_RD_RSTN_CONSTRAINT};

  localparam SDC_8G_TO_FEC   = {"-name SDC_STATEMENT \"set_false_path -from  [get_registers {*SV_NATIVE.altera_xcvr_native_sv_inst|sv_xcvr_native:gen_native_inst.xcvr_native_insts[0].gen_bonded_group_native.xcvr_native_inst|sv_pcs:inst_sv_pcs|sv_pcs_ch:ch[0].inst_sv_pcs_ch|sv_hssi_8g_rx_pcs_rbc:inst_sv_hssi_8g_rx_pcs*}] -to  [get_registers -nowarn {*FEC_SOFT10G.hd_krfec*}]\""};
  // split xcvr_to and xcvr_from into 2 or 3
  localparam reconfig_to_xcvr_ch      = altera_xcvr_functions::get_custom_reconfig_to_width(DEVICE_FAMILY,"duplex",1,0,1) ; 
  localparam reconfig_to_xcvr_pll_10g = altera_xcvr_functions::get_custom_reconfig_to_width(DEVICE_FAMILY,"duplex",1,1,1) ; 
  localparam reconfig_to_xcvr_pll_1g  = altera_xcvr_functions::get_custom_reconfig_to_width(DEVICE_FAMILY,"duplex",1,2,1) ; 

  localparam reconfig_from_xcvr_ch      = altera_xcvr_functions::get_custom_reconfig_from_width(DEVICE_FAMILY,"duplex",1,0,1) ; 
  localparam reconfig_from_xcvr_pll_10g = altera_xcvr_functions::get_custom_reconfig_from_width(DEVICE_FAMILY,"duplex",1,1,1) ; 
  localparam reconfig_from_xcvr_pll_1g  = altera_xcvr_functions::get_custom_reconfig_from_width(DEVICE_FAMILY,"duplex",1,2,1) ; 

  localparam DEV_FAM = (DEVICE_FAMILY == "Stratix V")? "STRATIXV" : 
      (DEVICE_FAMILY == "Arria V GZ")? "ARRIAVGZ" : DEVICE_FAMILY ;

//****************************************************************************
// Define Wires and Variables
//****************************************************************************
  // for SEQ
  wire         seq_restart_an;        // sequencer reset of the AN
  wire         seq_restart_lt;        // sequencer reset of the LT
  wire [65:0]  an_data, lt_data;      // raw data from AN, LT.  bit-0 first
  wire [65:0]  rx_an_lt_data;         // raw data to AN, LT. bit-0 first
  wire         rx_bitslip;            // sig the PMA to slip the datastream
  wire [2:0]   par_det;
  wire         load_pdet;
  wire [1:0]   data_mux_sel;          // select data input to hard PHY
                                      // 00 = AN, 01 = LT, 10 = xgmii
  wire         fec_enable;
  wire         fec_request;
  wire         csr_seq_restart;   // re-start the sequencer
  wire [2:0]   force_mode;        // Force the Hard PHY into a mode
                                  // 000 = no force,  001 = GigE mode
                                  // 010 = XAUI mode, 100 = 10G-R mode
                                  // 101 = kr, 40G, 100G
  wire         dis_lf_timer;      // disable the link_fail_inhibit_timer
  wire         dis_an_timer;      // disable AN timeout.  can get stuck
                                  // stuck in ABILITY_DETECT - if rmt not AN
                                  // stuck in ACKNOWLEDGE_DETECT - if loopback
  wire         dis_max_wait_tmr;  // disable the LT max_wait_timer
  wire         training;          // Link Training in progress
  wire         link_ready;         // link is ready
  wire         seq_an_timeout;     // AN timed-out in Sequencer SM
  wire         seq_lt_timeout;     // LT timed-out in Sequencer SM
  wire         lt_enable ;         // Enable LT
  wire         en_usr_np;          // Enable user next pages
  wire         pcs_link_sts;       // PCS link status from Hard PHY
  // for PHY
  wire         tx_clkout, rx_clkout, tx_10g_clkout,tx_10g_coreclkin;
  wire         tx_anlt_reset, rx_anlt_reset, seq_reset;
  wire         rx_soft_10g_pcs_reset, tx_soft_10g_pcs_reset; // for FEC
  wire [63:0]  tx_parallel_data;
  wire [7:0]   tx_parallel_ctrl;
  wire [71:0]  xgmii_rx_dc_hard;
  wire         ber_zero; // LT reports ber_zero from last measurement
  wire         fail_lt_if_ber; // if last LT measurement is non-zero, treat as a failed run

  // for AN
  wire         link_good;          // AN completed
  wire         an_rx_idle;         // RX SM in idle state - from RX_CLK
  wire         enable_fec;         // Enable FEC for the channel
  wire         in_ability_det;     // ARB SM in the ABILITY_DETECT state
  wire         an_enable;          // enable AN
  wire [24:0]  lp_tech;            // LP Technology ability = D45:21
  wire [1:0]   lp_fec;             // LP FEC ability = D47:46  output reg
  wire [31:0]  an_mgmt_readdata;   // read data from the AN CSR module
  wire [31:0]  lt_mgmt_readdata;   // read data from the LT CSR module
  wire [31:0]  fec_mgmt_readdata;      // read data from the SEQ/TOP CSR
  wire [5:0]   fnl_an_tech;        // final AN_TECH parameter
  wire [1:0]   fnl_an_fec;         // final the AN_FEC parameter
  wire [2:0]   fnl_an_pause;       // final the AN_PAUSE parameter

  // for 1G10G
  wire rx_datak ;                   //
  wire [PLL_CNT-1:0]  pll_powerdown ;
  wire [PLL_CNT-1:0]  pll_locked_bus;
  wire [PLL_CNT-1:0]  ext_pll_clk;

  wire    [ 64-1:0 ] tx_parallel_data_10g;  
  wire    [ 64-1:0 ] tx_parallel_data_native;  
  wire    [  8-1:0 ] tx_parallel_data_1g;  
  wire    [  8-1:0 ] rx_parallel_data_1g;  
  wire    [ 64-1:0 ] rx_parallel_data_native;
  wire    [  8-1:0 ] tx_10g_control;   
  wire    [ 64-1:0 ] rx_dataout;  
  wire    [ 10-1:0 ]  rx_10g_control;  

  wire               tx_std_pcfifo_full;
  wire               rx_std_pcfifo_full;
  wire               tx_std_pcfifo_empty;
  wire               rx_std_pcfifo_empty;

  // for IEEE-1588 10G
  wire [16-1:0]    tx_latency_adj_10g_int;
  wire [16-1:0]    rx_latency_adj_10g_int;
  wire [64-1:0]    tx_parallel_data_1588;
  wire [64-1:0]    rx_parallel_data_1588;
  wire             tx_10g_data_valid;
  wire             tx_10g_fifo_full;
  wire             tx_10g_full;
  wire             tx_10g_fifo_full_inter;
  wire [8-1:0]     tx_10g_control_inter;
  wire [10-1:0]    rx_10g_control_inter;
  wire             rx_10g_fifo_full; 
  wire             rx_10g_full; 
  wire             rx_10g_fifo_full_inter; 
  wire             rx_10g_data_valid;
  wire [ 5-1 : 0]  rx_std_bitslipboundarysel; // 1588 status
  wire             waitrequest;  
  wire             gige_pcs_waitreq;
  wire             gige_pcs_read;

  // for FEC
  wire 	           fec2pcs_block_lock;
  wire 	           fec2pcs_data_valid;
  wire [63:0]	   fec2pcs_data_out;
  wire [9:0]	   fec2pcs_ctrl_out;
  wire 	           fec2pcs_signal_ok;
  wire 	           pcs2fec_data_valid;
  wire [65:0] 	   pcs2fec_data_out;
  wire [63:0] 	   fec2phy_data_out;
  wire [63:0] 	   phy2fec_data_in;

  wire [1:0]       cdr_ref_clk;
  wire             fec_err_ind;
   
// PRBS ports 
 wire            rx_std_prbs_err    ; 
 wire            rx_std_prbs_done   ; 
 wire            rx_10g_prbs_err    ; 
 wire            rx_10g_prbs_done   ; 
 wire            rx_10g_prbs_err_clr;
  assign rx_10g_prbs_err_clr = 1'b0 ;
//****************************************************************************
// Instantiate the Sequencer module
//****************************************************************************
generate
  if (SYNTH_SEQ) begin: SEQ_GEN
    seq_sm  #(
      .LFT_R_MSB    (LFT_R_MSB),
      .LFT_R_LSB    (LFT_R_LSB),
      .LFT_X_MSB    (LFT_X_MSB),
      .LFT_X_LSB    (LFT_X_LSB)
    ) SEQUENCER (
      .rstn       (~seq_reset),
      .clk        (mgmt_clk),
      .restart    (csr_seq_restart),
      .an_enable  (an_enable),
      .lt_enable  (lt_enable),
      .frce_mode  (force_mode),
      .dis_max_wait_tmr (dis_max_wait_tmr),
      .dis_lf_timer  (dis_lf_timer),
      .dis_an_timer  (dis_an_timer),
      .en_usr_np     (en_usr_np), 
      .pcs_link_sts  (pcs_link_sts),
      .ber_zero      (ber_zero),
      .fail_lt_if_ber(fail_lt_if_ber),
      .link_ready    (link_ready),
      .seq_an_timeout(seq_an_timeout),
      .seq_lt_timeout(seq_lt_timeout),
      .enable_fec    (enable_fec),
      .data_mux_sel  (data_mux_sel),
     // to/from Auto-Negotiation
      .lcl_tech       (fnl_an_tech),
      .lcl_fec        ({fnl_an_fec[1],fnl_an_fec[0]}),
      .link_good      (link_good),
      .in_ability_det (in_ability_det),
      .an_rx_idle     (an_rx_idle),
      .lp_tech     (lp_tech[5:0]),
      .lp_fec      (lp_fec),
      .load_pdet   (load_pdet),
      .par_det     (par_det),
      .restart_an  (seq_restart_an),
     // to/from Link Training
      .training    (training),
      .restart_lt  (seq_restart_lt),
     // to/from reconfig
      .rc_busy     (rc_busy),
      .start_rc    (seq_start_rc),
      .pcs_mode_rc (pcs_mode_rc)
   );
  end  // if synth_seq
  else begin: NO_SEQ_GEN  // need to drive outputs if no SEQ module
    assign pcs_mode_rc   = {2'b0, mode_1g_10gbar, ~mode_1g_10gbar, 2'b0};
    assign seq_start_rc  = 1'b0;
    assign seq_restart_lt = 1'b0;
    assign seq_restart_an = 1'b0;
    assign data_mux_sel   = 2'b10;  // xgmii only, may need to add logic if have AN/LT and no SEQ
    assign enable_fec     = fnl_an_fec[1] & fnl_an_fec[0];  // not qualified with link partner's fec ability and fec request
    assign seq_an_timeout = 1'b0;
    assign seq_lt_timeout = 1'b0;
    assign link_ready     = (mode_1g_10gbar & rx_syncstatus) | 
                           (~mode_1g_10gbar & rx_data_ready);
  end  // else synth_seq
endgenerate

//****************************************************************************
// Instantiate the AN module
// also have the AN CSRs and test logic
//****************************************************************************
generate
  if (SYNTH_AN) begin: AN_GEN
    // signals between AN and CSRs
    wire         an_restart;         // re-start the AN process
    wire         restart_txsm;       // re-start the TXSM/ARB only
    wire         csr_lcl_rf;         // local device Remote Fault = D13
    wire         lcl_rf_sent;        // local device sent RF
    wire         en_usr_bp;          // Enable user base pages
    wire [48:16] usr_base_pgh;       // User base page hi bits
    wire [14:1]  usr_base_pgl;       // User base page low bits
    wire [48:16] usr_next_pgh;       // User next page hi bits
    wire [14:1]  usr_next_pgl;       // User next page low bits
    wire         lp_an_able;         // link partner is able to AN
    wire         an_pg_received;     // ARB SM has rcvd 3 codewords w/ ACK
    wire [48:1]  lp_base_pg;         // Link Partner base page data
    wire [48:1]  lp_next_pg;         // Link Partner next page data
    wire [2:0]   lp_pause;           // LP pause capability = D12:10
    wire         lp_rf;              // link partner Remote Fault = D13
    wire         usr_new_np;  // New next page, hand shake with usr_np_sent
    wire         usr_np_sent; // next page sent, hand shake with usr_new_np
    wire         csr_hold_nonce;     // Mode for UNH testing to hold TX_nonce
    wire         an_tm_enable;       // AN test mode enable
    wire [3:0]   an_inj_err;        // inject errors into the AN TX data
    wire [3:0]   an_tm_err_mode;
    wire [3:0]   an_tm_err_trig;
    wire [7:0]   an_tm_err_time;
    wire [7:0]   an_tm_err_cnt;
    wire         en_an_param_ovrd;   // Enable AN parameter override
    wire [5:0]   ovrd_an_tech;       // override the AN_TECH parameter
    wire [1:0]   ovrd_an_fec;        // override the AN_FEC parameter
    wire [2:0]   ovrd_an_pause;      // override the AN_PAUSE parameter

  // Apply embedded false path timing constraints for AN
  (* altera_attribute = SYNC_AN_CONSTRAINT *)
    an_top #(
      .PCNTWIDTH    (4),
      .AN_SELECTOR  (AN_SELECTOR)
    ) AUTO_NEG (
      .AN_PAUSE     (fnl_an_pause),
      .AN_TECH      (fnl_an_tech),
      .AN_FEC       (fnl_an_fec),
      .tx_rstn      (~tx_anlt_reset), 
      .tx_clk       (tx_clkout), 
      .rx_rstn      (~rx_anlt_reset), 
      .rx_clk       (rx_clkout), 
      .an_enable    (an_enable), 
      .an_restart   (an_restart | seq_restart_an),
      .restart_txsm (restart_txsm),
      .lcl_rf       (lcl_rf | csr_lcl_rf),
      .en_usr_bp    (en_usr_bp), 
      .en_usr_np    (en_usr_np), 
      .usr_base_pgh (usr_base_pgh), 
      .usr_base_pgl (usr_base_pgl), 
      .usr_next_pgh (usr_next_pgh), 
      .usr_next_pgl (usr_next_pgl), 
      .usr_new_np   (usr_new_np),
      .hold_nonce   (csr_hold_nonce),
         // outputs
      .lp_an_able      (lp_an_able), 
      .link_good       (link_good), 
      .in_ability_det  (in_ability_det), 
      .an_rx_idle      (an_rx_idle), 
      .lcl_rf_sent     (lcl_rf_sent),
      .lp_pause        (lp_pause),
      .lp_rf           (lp_rf),
      .lp_tech         (lp_tech),
      .lp_fec          (lp_fec),
      .an_pg_received  (an_pg_received),
      .lp_base_pg      (lp_base_pg),
      .lp_next_pg      (lp_next_pg),
      .usr_np_sent     (usr_np_sent),
      .load_pdet       (load_pdet), 
      .par_det         (par_det),
         // data
      .dme_in       (rx_an_lt_data),
      .inj_err      (an_inj_err), 
      .dme_out      (an_data)
    );

    // instantiate the AN registers at address 0xC0 - 0xCF
    csr_kran  csr_kran_inst (
      .clk        (mgmt_clk          ),
      .reset      (mgmt_clk_reset    ),
      .address    (mgmt_address      ),
      .read       (mgmt_read         ),
      .readdata   (an_mgmt_readdata  ),
      .write      (mgmt_write        ),
      .writedata  (mgmt_writedata    ),
    //status inputs to this CSR
      .an_pg_received   (an_pg_received),
      .an_completed     (link_good),
      .lcl_dvce_rf_sent (lcl_rf_sent),
      .an_rx_idle       (an_rx_idle),
      .an_ability       (1'b1),       // if have AN, then should read 1
      .an_status        (link_good),  // latch low version
      .lp_an_able       (lp_an_able),
      .lp_fec_neg       (enable_fec),
      .an_failure       (seq_an_timeout),
      .an_link_ready
             ({3'd0,(pcs_mode_rc[2]|pcs_mode_rc[5])&link_ready,1'b0,pcs_mode_rc[3]&link_ready}),
      .lp_base_pg   (lp_base_pg),
      .lp_next_pg   (lp_next_pg),
      .lp_tech      (lp_tech),
      .lp_fec       (lp_fec),
      .lp_rf        (lp_rf),
      .lp_pause     (lp_pause),
    // read/write control outputs
      .csr_an_enable    (an_enable),
      .usr_base_page_en (en_usr_bp),
      .usr_nxt_page_en  (en_usr_np),
      .usr_lcl_dvce_rf  (csr_lcl_rf),
      .csr_reset_an     (an_restart),
      .csr_restart_txsm (restart_txsm),
      .new_np_ready     (usr_new_np),
      .usr_base_pg_lo   (usr_base_pgl),
      .usr_base_pg_hi   (usr_base_pgh),
      .usr_next_pg_lo   (usr_next_pgl),
      .usr_next_pg_hi   (usr_next_pgh),
      .csr_hold_nonce   (csr_hold_nonce),
      .en_an_param_ovrd (en_an_param_ovrd),
      .ovrd_an_tech     (ovrd_an_tech),
      .ovrd_an_fec      (ovrd_an_fec),
      .ovrd_an_pause    (ovrd_an_pause),
      .an_tm_enable     (an_tm_enable),
      .an_tm_err_mode   (an_tm_err_mode),
      .an_tm_err_trig   (an_tm_err_trig),
      .an_tm_err_time   (an_tm_err_time),
      .an_tm_err_cnt    (an_tm_err_cnt)
    );

       // Override the AN Parameters
    assign fnl_an_tech  = en_an_param_ovrd ? ovrd_an_tech  : AN_TECH[5:0];
    assign fnl_an_fec   = en_an_param_ovrd ? ovrd_an_fec   : {fec_request,fec_enable} ;  
    assign fnl_an_pause = en_an_param_ovrd ? ovrd_an_pause : AN_PAUSE[2:0];

       // instantiate the AN Test mode logic here
    assign tm_out_trigger[3:2] = 2'd0;
    assign an_inj_err          = 4'd0;


  end  // if synth_an
  else begin: NO_AN_GEN  // need to drive outputs if no AN module
    assign link_good      = 1'b0;
    assign in_ability_det = 1'b0;
    assign an_rx_idle     = 1'b1;
    assign an_enable      = 1'b0;
    assign en_usr_np      = 1'b0;
    assign load_pdet      = 1'b0;
    assign tm_out_trigger[3:2] = 2'd0;
    assign par_det = 3'd0;
    assign lp_tech = 25'd0;
    assign lp_fec  = 2'd0;
    assign an_data = 66'd0;
    assign an_mgmt_readdata = 32'd0;
    assign fnl_an_tech  = AN_TECH[5:0];
    assign fnl_an_fec   = {fec_request, fec_enable};
    assign fnl_an_pause = AN_PAUSE[2:0];
  end  // else synth_an
endgenerate

//****************************************************************************
// Instantiate the LT module
// also have the LT CSRs and test logic
//****************************************************************************
generate
  if (SYNTH_LT) begin: LT_GEN
       // signals between LT and CSRs
    wire         lt_restart;        // re-start the LT process
    wire [9:0]   sim_ber_t;         // Time(frames) to cnt when ber_time=0
    wire [9:0]   ber_time;          // Time(K-frames) to count BER Errors
    wire [9:0]   ber_ext;           // Extend(M-frames) Time to count BER
    wire         quick_mode;        // Only look at init & preset EQ state
    wire         pass_one;          // look beyond first min in BER count
    wire [3:0]   main_step_cnt;     // Number of EQ steps per main update
    wire [3:0]   prpo_step_cnt;     // EQ steps for pre/post tap update
    wire [2:0]   equal_cnt;         // Number to make BER counts Equal
    wire         training_fail;     // Training timed-out
    wire         training_error;    // Training Error (ber_max)
    wire         train_lock_err;    // Training Frame Lock Error
    wire         rx_trained_sts;    // rx_trained status to CSR
    wire [7:0]   lcl_txi_update;    // Local coef update bits to TX
    wire         lcl_tx_upd_new;    // Local coef update new
    wire [6:0]   lcl_txi_status;    // Local status bits to transmit
    wire         lcl_tx_stat_new;   // Local coef status new
    wire [7:0]   lp_rxi_update;     // Override coef update bits to CSR
    wire         lp_rx_upd_new;     // Remote coef update new
    wire [6:0]   lp_rxi_status;     // Remote/LP status bits to CSR
    wire         ovrd_lp_coef;      // Override LP TX update enable
    wire [7:0]   lp_txo_update;     // Override LP TX update bits  
    wire         lp_tx_upd_new;     // Override LP TX update new   
    wire         ovrd_coef_rx;      // Override lcl coef update enable
    wire [7:0]   lcl_rxo_update;    // Override lcl coef update bits from CSR
    wire         ovrd_rx_new;       // Override lcl coef update new
    wire [2*MAINTAPWIDTH+POSTTAPWIDTH+PRETAPWIDTH+3:0]  param_ovrd;
    wire         dis_init_pma;      // disable initialize PMA on timeout
    wire         lt_tm_enable;      // LT test mode enable
    wire [3:0]   lt_inj_err;        // inject errors into the LT TX data
    wire [3:0]   lt_tm_err_mode;
    wire [3:0]   lt_tm_err_trig;
    wire [7:0]   lt_tm_err_time;
    wire [7:0]   lt_tm_err_cnt;
    wire [2:0]   rx_ctle_mode;
    wire [2:0]   rx_dfe_mode;
    wire         max_mode;
    wire         fixed_mode;
    wire [2:0]   max_post_step;
    wire [1:0]   ctle_depth;
    wire [1:0]   dfe_extra;
    wire         only_inc_main;
    wire [2:0]   ctle_bias;
    wire         dec_post;
    wire         dec_post_more;
    wire         ctle_pass_ber;
    wire         use_full_time;
    wire         nolock_rxeq;
    wire         fail_ctle;
    wire [1:0]   last_dfe_mode;
    wire [3:0]   last_ctle_rc;
    wire [1:0]   last_ctle_mode;

  // Apply embedded false path timing constraints for LT
  (* altera_attribute = SDC_LT_CONSTRAINTS *)
    lt_top #(
      .BERWIDTH   (BERWIDTH),
      .TRNWTWIDTH (TRNWTWIDTH),
      .MAINTAPWIDTH (MAINTAPWIDTH),
      .POSTTAPWIDTH (POSTTAPWIDTH),
      .PRETAPWIDTH  (PRETAPWIDTH),
      .VMAXRULE (VMAXRULE),
      .VMINRULE (VMINRULE),
      .VODMINRULE (VODMINRULE),
      .VPOSTRULE  (VPOSTRULE),
      .VPRERULE   (VPRERULE),
      .PREMAINVAL (PREMAINVAL),
      .PREPOSTVAL (PREPOSTVAL),
      .PREPREVAL  (PREPREVAL),
      .INITMAINVAL (INITMAINVAL),
      .INITPOSTVAL (INITPOSTVAL),
      .INITPREVAL  (INITPREVAL),
      .OPTIONAL_RXEQ (OPTIONAL_RXEQ)
    ) LINK_TRAIN (
      .tx_rstn      (~tx_anlt_reset),
      .tx_clk       (tx_clkout),
      .rx_rstn      (~rx_anlt_reset),
      .rx_clk       (rx_clkout),
      .lt_enable    (lt_enable & (data_mux_sel == 2'b01)),
      .lt_restart   (lt_restart | seq_restart_lt),
      // data ports
      .rx_data_in  (rx_an_lt_data),
      .tx_data_out (lt_data),
      .rx_bitslip  (rx_bitslip),
      // outputs to CSR for status
      .training        (training),
      .training_fail   (training_fail),
      .training_error  (training_error),
      .train_lock_err  (train_lock_err),
      .rx_trained_sts  (rx_trained_sts),
      .lcl_txi_update  (lcl_txi_update),
      .lcl_tx_upd_new  (lcl_tx_upd_new),
      .lcl_txi_status  (lcl_txi_status),
      .lcl_tx_stat_new (lcl_tx_stat_new),
      .lp_rxi_update   (lp_rxi_update),
      .lp_rx_upd_new   (lp_rx_upd_new),
      .lp_rxi_status   (lp_rxi_status),
      .nolock_rxeq     (nolock_rxeq),
      .fail_ctle       (fail_ctle),
      .last_dfe_mode   (last_dfe_mode),
      .last_ctle_rc    (last_ctle_rc),
      .last_ctle_mode  (last_ctle_mode),
      .ber_zero        (ber_zero),
       // register bits for setting of operating mode
      .sim_ber_t      (sim_ber_t),
      .ber_time       (ber_time),
      .ber_ext        (ber_ext),
      .dis_max_wait_tmr (dis_max_wait_tmr),
      .dis_init_pma   (dis_init_pma),
      .quick_mode     (quick_mode),
      .pass_one       (pass_one),
      .main_step_cnt  (main_step_cnt),
      .prpo_step_cnt  (prpo_step_cnt),
      .equal_cnt      (equal_cnt),
      .ovrd_coef_rx   (ovrd_coef_rx),
      .param_ovrd     (param_ovrd),
      .lcl_rxo_update (lcl_rxo_update),
      .ovrd_rx_new    (ovrd_rx_new),
      .ovrd_lp_coef   (ovrd_lp_coef),
      .lp_txo_update  (lp_txo_update),
      .lp_tx_upd_new  (lp_tx_upd_new),
      .inj_err        (lt_inj_err),
      .rx_ctle_mode   (rx_ctle_mode),
      .rx_dfe_mode    (rx_dfe_mode),
      .max_mode       (max_mode),
      .fixed_mode     (fixed_mode),
      .max_post_step  (max_post_step),
      .ctle_depth     (ctle_depth),
      .dfe_extra      (dfe_extra),
      .only_inc_main  (only_inc_main),
      .ctle_bias      (ctle_bias),
      .dec_post       (dec_post),
      .dec_post_more  (dec_post_more),
      .ctle_pass_ber  (ctle_pass_ber),
      .use_full_time  (use_full_time),
       // for the reconfig Interface
      .rc_busy     (rc_busy),
      .start_rc    (lt_start_rc),
      .dfe_start_rc(dfe_start_rc),
      .dfe_mode    (dfe_mode),
      .ctle_start_rc(ctle_start_rc),
      .ctle_rc     (ctle_rc),
      .ctle_mode   (ctle_mode),
      .main_rc     (main_rc),
      .post_rc     (post_rc),
      .pre_rc      (pre_rc),
      .tap_to_upd  (tap_to_upd),
      .rxeq_done   (rxeq_done),
      // Daisy Chain Mode input for local TX update/status
      .dmi_mode_en      (dmi_mode_en),
      .dmi_frame_lock   (dmi_frame_lock),
      .dmi_rmt_rx_ready (dmi_rmt_rx_ready),
      .dmi_lcl_coefl    (dmi_lcl_coefl),
      .dmi_lcl_coefh    (dmi_lcl_coefh),
      .dmi_lcl_upd_new  (dmi_lcl_upd_new),
      .dmi_rx_trained   (dmi_rx_trained),
       // Daisy Chain Mode outputs of remote update/status
      .dmo_frame_lock   (dmo_frame_lock),
      .dmo_rmt_rx_ready (dmo_rmt_rx_ready),
      .dmo_lcl_coefl    (dmo_lcl_coefl),
      .dmo_lcl_coefh    (dmo_lcl_coefh),
      .dmo_lcl_upd_new  (dmo_lcl_upd_new),
      .dmo_rx_trained   (dmo_rx_trained),
      // uP Mode inputs for remote EQ Optimization
      .upi_mode_en     (upi_mode_en),
      .upi_adj         (upi_adj),
      .upi_inc         (upi_inc),
      .upi_dec         (upi_dec),
      .upi_pre         (upi_pre),
      .upi_init        (upi_init),
      .upi_st_bert     (upi_st_bert),
      .upi_train_err   (upi_train_err),
      .upi_lock_err    (upi_lock_err), 
      .upi_rx_trained  (upi_rx_trained),
      // uP Mode outputs for remote EQ Optimization
      .upo_enable     (upo_enable),
      .upo_frame_lock (upo_frame_lock),
      .upo_cm_done    (upo_cm_done),
      .upo_bert_done  (upo_bert_done),
      .upo_ber_cnt    (upo_ber_cnt),
      .upo_ber_max    (upo_ber_max),
      .upo_coef_max   (upo_coef_max)
   );

    // instantiate the LT registers at address 0xD0 - 0xDF
    csr_krlt #(
      .MAINTAPWIDTH (MAINTAPWIDTH),
      .POSTTAPWIDTH (POSTTAPWIDTH),
      .PRETAPWIDTH  (PRETAPWIDTH)
      ) csr_krlt_inst (
      .clk        (mgmt_clk          ),
      .reset      (mgmt_clk_reset    ),
      .address    (mgmt_address      ),
      .read       (mgmt_read         ),
      .readdata   (lt_mgmt_readdata  ),
      .write      (mgmt_write        ),
      .writedata  (mgmt_writedata    ),
    //status inputs to this CSR
      .rx_trained    (rx_trained_sts),
      .lt_frame_lock (dmo_frame_lock),
      .training      (training), 
      .training_fail (training_fail), 
      .training_error(training_error),
      .train_lock_err  (train_lock_err),
      .lcl_txi_update  (lcl_txi_update),
      .lcl_tx_upd_new  (lcl_tx_upd_new),
      .lcl_txi_status  (lcl_txi_status),
      .lcl_tx_stat_new (lcl_tx_stat_new),
      .lp_rxi_update   (lp_rxi_update),
      .lp_rx_upd_new   (lp_rx_upd_new),
      .lp_rxi_status   (lp_rxi_status),
      .lp_rx_stat_new  (dmo_lcl_upd_new),
      .nolock_rxeq     (nolock_rxeq),
      .fail_ctle       (fail_ctle),
      .last_dfe_mode   (last_dfe_mode),
      .last_ctle_rc    (last_ctle_rc),
      .last_ctle_mode  (last_ctle_mode),
      .main_rc     (main_rc),
      .post_rc     (post_rc),
      .pre_rc      (pre_rc),
    // read/write control outputs
      .csr_lt_enable    (lt_enable),
      .dis_max_wait_tmr (dis_max_wait_tmr),
      .dis_init_pma     (dis_init_pma),
      .quick_mode       (quick_mode),
      .pass_one         (pass_one),      
      .main_step_cnt    (main_step_cnt),  
      .prpo_step_cnt    (prpo_step_cnt),  
      .equal_cnt        (equal_cnt),
      .ovrd_lp_coef (ovrd_lp_coef),
      .ovrd_coef_rx (ovrd_coef_rx),
      .rx_ctle_mode  (rx_ctle_mode),
      .rx_dfe_mode   (rx_dfe_mode),
      .max_mode      (max_mode),
      .fixed_mode    (fixed_mode),
      .max_post_step (max_post_step),
      .ctle_depth    (ctle_depth),
      .dfe_extra     (dfe_extra),
      .only_inc_main (only_inc_main),
      .ctle_bias     (ctle_bias),
      .dec_post      (dec_post),
      .dec_post_more (dec_post_more),
      .ctle_pass_ber (ctle_pass_ber),
      .use_full_time (use_full_time),
      .csr_reset_lt (lt_restart),
      .ber_time     (sim_ber_t), 
      .ber_k_time   (ber_time), 
      .ber_m_time   (ber_ext), 
      .lcl_txo_update (lp_txo_update),
      .lp_tx_upd_new  (lp_tx_upd_new),
      .lcl_rxo_update (lcl_rxo_update),
      .ovrd_rx_new    (ovrd_rx_new),
      .param_ovrd     (param_ovrd),
      .lt_tm_enable   (lt_tm_enable),
      .lt_tm_err_mode (lt_tm_err_mode),
      .lt_tm_err_trig (lt_tm_err_trig),
      .lt_tm_err_time (lt_tm_err_time),
      .lt_tm_err_cnt  (lt_tm_err_cnt)
    );

       // Drive the status output
    assign en_lcl_rxeq = rx_trained_sts;

       // instantiate the LT Test mode logic here
    assign tm_out_trigger[1:0] = 2'd0;
    assign lt_inj_err          = 4'd0;


  end  // if synth_lt
  else begin: NO_LT_GEN   // need to drive outputs if no LT module
    assign lt_enable        = 1'b0;
    assign dis_max_wait_tmr = 1'b0;
    assign rx_bitslip       = 1'b0;
    assign lt_start_rc      = 1'b0;
    assign training         = 1'b0;
    assign tap_to_upd       = 3'd0;
    assign en_lcl_rxeq      = 1'b0;
    assign main_rc          = 'd0;
    assign post_rc          = 'd0;
    assign pre_rc           = 'd0;
    assign tm_out_trigger[1:0] = 2'd0;
    assign lt_data          = 66'd0;
    assign lt_mgmt_readdata = 32'd0;
    assign dmo_frame_lock   = 1'b0;
    assign dmo_rmt_rx_ready = 1'b0;
    assign dmo_lcl_coefl    = 6'b0;
    assign dmo_lcl_coefh    = 2'b0;
    assign dmo_lcl_upd_new  = 1'b0;
    assign dmo_rx_trained   = 1'b0;
    assign upo_enable     = 1'b0;
    assign upo_frame_lock = 1'b0;
    assign upo_cm_done    = 1'b0;
    assign upo_bert_done  = 1'b0;
    assign upo_ber_cnt    = 'd0;
    assign upo_ber_max    = 1'b0;
    assign upo_coef_max   = 1'b0;
    assign dfe_start_rc   = 1'b0;
    assign dfe_mode       = 2'b0;
    assign ctle_start_rc  = 1'b0;
    assign ctle_rc        = 4'b0;
    assign ctle_mode      = 2'b0;
    assign ber_zero       = 1'b1;
  end  // else synth_lt
endgenerate


//****************************************************************************
// Muxes/logic for the AN/LT data and status
// Selection is made by the Sequencer
// 00 = AN, 01 = LT, 1x = xgmii
//****************************************************************************
  wire rx_deskew_status = 1'b0;
  wire rx_fec_status    ;
  wire csr_rx_set_locktoref;      // to xcvr instance from csr
  wire csr_rx_set_locktodata;     // to xcvr instance from csr
  wire fnl_set_locktoref;         // override lock_to_ref for AN mode
  wire fnl_set_locktodata;        // override lock_to_data for LT mode
  wire rx_10g_coreclkin;

  assign tx_parallel_ctrl = (data_mux_sel[1] & (pcs_mode_rc[5])) ? 8'b0 :
                            (data_mux_sel[1] & (~pcs_mode_rc[5]))? tx_10g_control_inter :
                            data_mux_sel[0]                 ? {6'd0,lt_data[0],lt_data[1]} : 
                            {6'd0,an_data[0],an_data[1]} ;

  assign tx_parallel_data = (data_mux_sel[1] & (pcs_mode_rc[5]))  ? fec2phy_data_out:
                            (data_mux_sel[1] & (~pcs_mode_rc[5])) ? tx_parallel_data_native :
                            data_mux_sel[0]                 ? lt_data[65:2] : 
									 an_data[65:2];
  // the AN and LT data is raw bits
  assign rx_an_lt_data = {rx_parallel_data_native,
                          rx_10g_control_inter[0],
                          rx_10g_control_inter[1]};
   
  // Mux the link status depending upon which datapath is active
  assign pcs_link_sts = pcs_mode_rc[2] ? rx_data_ready    : // 10G status
                        pcs_mode_rc[3] ? rx_syncstatus    : // 1G status
                        pcs_mode_rc[4] ? rx_deskew_status : // XAUI status
                        pcs_mode_rc[5] ? rx_fec_status    : // FEC PCS stat
                        1'b0;

  // override lock_to signals depending uppn datapath mode
  assign fnl_set_locktoref = pcs_mode_rc[0] ? 1'b1 : // AN mode - force LTR
                             pcs_mode_rc[1] ? 1'b0 : // LT mode - Auto LTD
                             csr_rx_set_locktoref;
  assign fnl_set_locktodata = pcs_mode_rc[0] ? 1'b0 : // AN mode - force LTR
                              pcs_mode_rc[1] ? 1'b0 : // LT mode - Auto LTD
                              csr_rx_set_locktodata;

  // tx_clkout is wrong frequency for AN/LT, need to use a div33 clock
  // xgmii_rx_clock is looped-back to xgmii_tx_clock in test harness.
  // use xgmii_tx_clk for timings to TX FIFO to be the same
  assign tx_clkout =  xgmii_tx_clk;

  // need to mux the input clock on native: in_pld_10g_rx_pld_clk
  // for AN/LT it needs recovered div33 clock
  wire xgmii_rx_clk_mux;

//****************************************************************************
// Instantiate rx clock mux -- 
// 2:1 MUX when AN||LT but NO FEC 
// 3:1 MUX when both AN||LT and FEC is present
// NO MUX when none is present - 1G/10G mode
// In FEC mode 10G TX coreclkin=161 while in 10G/AN/LT mode coreclkin=156
//****************************************************************************
generate 
  if ((SYNTH_AN || SYNTH_LT) && (SYNTH_FEC==0) ) begin : CLOCK_MUX_AN_LT 	   
  // use glitch-free clock_mux with 1-hot enabling as LUTs may glitch
  gf_clock_mux  gf_rx_clk_mux_inst (
       .clk         ({rx_10g_coreclkin, rx_clkout}), // use 10g-coreclkin from 1588 if-generate
       .clk_select  ({data_mux_sel[1], ~data_mux_sel[1]}),
       .clk_out     (xgmii_rx_clk_mux)
  );
  end
  else if ((SYNTH_AN || SYNTH_LT) && SYNTH_FEC ) begin : CLOCK_MUX_AN_LT_FEC
  gf_clock_mux #(
       .num_clocks  (3) 
  ) gf_rx_clk_mux_inst (
//                       161 MHz - LL-->FEC            156 MHz- AN--> NO FEC       	DIV33- AN/LT  
       .clk         ({rx_recovered_clk               ,rx_10g_coreclkin                , rx_clkout}), // use 10g-coreclkin from 1588 if-generate
       .clk_select  ({data_mux_sel[1] & (pcs_mode_rc[5]),data_mux_sel[1] & ~(pcs_mode_rc[5]), ~data_mux_sel[1]}),
       .clk_out     (xgmii_rx_clk_mux)
  );
  end
  else begin : NO_CLOCK_MUX
  assign xgmii_rx_clk_mux = rx_10g_coreclkin ; // no clk mux required when NO AN/NO LT -fPLL clk
  end

endgenerate


//****************************************************************************
// Instantiate Native PHY
//****************************************************************************
  wire tx_clkout_1g_int,rx_clkout_1g_int,rx_recovered_clk_int,tx_10g_clkout_int;
  wire out_pma_rx_clk_out;
  wire out_pma_tx_clk_out;
  wire rx_block_lock_hard ;
  wire rx_hi_ber_hard ;
  wire rx_data_ready_hard;
  wire csr_phy_loopback_serial;     // to xcvr instance from csr
  wire rx_is_lockedtoref;
  wire rx_sync_head_error;
  wire rx_scrambler_error;  
  wire clr_errblk_cnt;
  wire clr_ber_cnt;
  wire rx_std_bitrev_ena;
  wire rx_std_byteorder_ena;
  wire tx_std_elecidle;
  wire tx_std_polinv;
  wire rx_std_polinv;
  // Final reset signals
  wire tx_analogreset_fnl;
  wire tx_digitalreset_fnl;
  wire rx_analogreset_fnl;
  wire rx_digitalreset_fnl;

localparam pll_data_rate = SYNTH_GIGE ? "1250 Mbps, 10312.5 Mbps" : "10312.5 Mbps" ;
localparam enable_std = SYNTH_GIGE ? 1'b1 : 1'b0 ;
localparam pll_select =  SYNTH_GIGE ? 1 : 0  ;

// use port cdr-refclk if Sync-E is enabled - else use pll_refclk
generate 
if (EN_SYNC_E)  begin : SYNCE_CLK
assign cdr_ref_clk = {cdr_ref_clk_1g, cdr_ref_clk_10g};	
end
else begin : NO_SYNCE
assign cdr_ref_clk = {pll_ref_clk_1g, pll_ref_clk_10g}  ;
end
endgenerate 

generate 
  if ( DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria V GZ" )
        begin : SV_NATIVE
  altera_xcvr_native_sv  #(
    //---------------------
    // Common parameters
    //---------------------
    .rx_enable (1'b1),                  // 0,1  
    .tx_enable (1'b1),                  // 0,1
    .data_path_select("10G"),      // legal values "8G" "10G" "pma_direct"
    // TX PMA
    .pma_width (40),                    
    .enable_std(enable_std),            // legal values 0, 1
    .enable_teng(1'b1),                 // legal values 0,1
    .std_protocol_hint("gige"),         // basic|cpri|gige|srio_2p1|interlaken|teng_baser|teng_sdi
    .teng_protocol_hint(SYNTH_1588_10G?"teng_1588_mode":"teng_baser"),  // basic|interlaken|teng_baser|teng_sdi|teng_1588_mode, basic for FEC
    .channels(1'b1),                    // legal values 1+
    .std_pcs_pma_width(10),             // 8G - 8|10|16|20 
    .teng_pcs_pma_width(40),            // 8G - 8|10|16|20
    .teng_pld_pcs_width(66),            // 8G - 8|10|16|20
    .data_rate ("10312.50 Mbps"),       // user entered data rate always in Mbps
    .pll_data_rate (pll_data_rate),     // PLL Rate - data_rate * 1,2,4,or 8 in mbps
    // PLL specific parameters
    .plls (PLL_CNT),                    // no of plls, 1+   
    .pll_select (0),                    // Selects the initial PLL
    .cdr_reconfig_enable(1),            // (0,1) 0-Disable CDR reconfig, 1-Enable CDR reconfig
    .cdr_refclk_cnt (PLL_CNT),
    .cdr_refclk_select (0),       // Selects the initial reference clock for all RX CDR PLLs
    .cdr_refclk_freq (REF_CLK_FREQ_10G),
    .pll_reconfig_enable (1),              // (0,1) 0-Disable PLL reconfig, 1-Enable PLL reconfig
    .pll_external_enable (1),
//// 8g PCS PARAMS ARE SET TO MET FITTER REQUIREMENT. PARAMETER SETTING FOR
//GIGE MODE WILL BE TAKEN CARE BY RC STREAMING
    //-----------------------------
    // Standard (8G) PCS parameters
    //-----------------------------
    .std_tx_8b10b_enable (1),        // 0,1 
    .std_rx_8b10b_enable (1),        // 0,1
    //Word aligner/Bit slip
    .std_rx_word_aligner_mode ("sync_sm"),     //bit_slip|sync_sm|auto_align_pld_ctrl|deterministic_latency
    .std_rx_word_aligner_pattern ("0000000000") ,
    .std_rx_word_aligner_pattern_len (7),      //7,8,10,16,20,32
    //Run length detector
    .std_rx_run_length_val ("000000") ,       
    //Rate match FIFO
    .std_tx_pcfifo_mode (SYNTH_1588_1G?"register_fifo":"low_latency"),   //low_latency|register_fifo|normal_latency
    .std_rx_pcfifo_mode (SYNTH_1588_1G?"register_fifo":"low_latency"),   //low_latency|register_fifo|normal_latency
    .std_rx_rmfifo_enable (0) ,
    .std_rx_rmfifo_pattern_p ("000000000000000000000") , 
    .std_rx_rmfifo_pattern_n ("000000000000000000000") , 
    // Bit reversal/Polarity inversion
    .std_tx_bitrev_enable (0) ,
    .std_rx_bitrev_enable (0) ,
    .std_tx_polinv_enable (0) ,
    .std_rx_polinv_enable (0) ,
    //----------------------
    // 10G PCS parameters
    //----------------------
    // Tx FIFO
	    //Phase compensation FIFOs
    .teng_txfifo_mode (SYNTH_1588_10G?"register":"phase_comp") , // phase_comp|register|clk_comp|generic|interlaken
    .teng_txfifo_full   (31) ,      // FIFO full threshold 0-31d (b)
    .teng_txfifo_empty  (0 ) ,      // FIFO empty threshold 00000-11111 (b)
    .teng_txfifo_pfull  (23) ,      // FIFO partially full threshold 00000-11111 (b)
    .teng_txfifo_pempty (2 ) ,      // FIFO partially empty threshold 00000-11111 (b)
    // Rx FIFO
    .teng_rxfifo_mode  (SYNTH_1588_10G?"register":"clk_comp"), // phase_comp|register|clk_comp|generic|interlaken
    .teng_rxfifo_full  (31),         // FIFO full threshold 00000-11111 (b)
    .teng_rxfifo_empty (0 ),         // FIFO empty threshold 00000-11111 (b)
    .teng_rxfifo_pfull (23),         // FIFO partially full threshold 00000-11111 (b)
    .teng_rxfifo_pempty(SYNTH_1588_10G?2:7 ), // FIFO partially empty threshold 0-31 (b)
    // Scrambler
    .teng_tx_scram_enable (1),            // 0,1        
    .teng_rx_descram_enable (1),            // 0,1
    .teng_tx_scram_user_seed (58'h3FFFFFFFFFFFFFF) ,  //hex
    // 64B/66B
    .teng_tx_64b66b_enable (1) ,            // 0,1
    .teng_rx_64b66b_enable (1) ,            // 0,1
    // Bit Slip
    .teng_tx_bitslip_enable (0) ,            // 0,1
    .teng_rx_bitslip_enable (0) ,            // 0,1
    .teng_tx_polinv_enable (0) ,
    .teng_rx_polinv_enable (0) ,
    // Block Sync
    .teng_rx_blksync_enable (1)              // 0,1

	) altera_xcvr_native_sv_inst ( 
     // expose pma_clk ports from native PHY and use in 1588 mode
    .rx_pma_pclk(out_pma_rx_clk_out),
    .tx_pma_pclk(out_pma_tx_clk_out),
    //------------------------
    // Common Ports
    //------------------------
    // Resets - PLL, RX and TX
    .tx_analogreset  (tx_analogreset_fnl), // for tx pma
    .pll_powerdown   (pll_powerdown),
    .tx_digitalreset (tx_digitalreset_fnl), // for TX PCS
    .rx_analogreset  (rx_analogreset_fnl), // for rx pma
    .rx_digitalreset (rx_digitalreset_fnl), //for rx pcs
    // Reconfig interface ports
    .reconfig_to_xcvr  (reconfig_to_xcvr[reconfig_to_xcvr_ch-1:0]),
    .reconfig_from_xcvr(reconfig_from_xcvr[reconfig_from_xcvr_ch-1:0]), 
    .tx_cal_busy(tx_cal_busy),  
    .rx_cal_busy(rx_cal_busy),
    //clk signals
    .rx_cdr_refclk(cdr_ref_clk),
    .ext_pll_clk  (ext_pll_clk),
    // TX and RX serial ports
    .rx_serial_data(rx_serial_data),
    .tx_serial_data(tx_serial_data),
    // control ports
    .rx_seriallpbken  (csr_phy_loopback_serial),
    .rx_set_locktodata(fnl_set_locktodata),
    .rx_set_locktoref (fnl_set_locktoref),
    //status
    .rx_is_lockedtoref(rx_is_lockedtoref),
    .rx_is_lockedtodata(rx_is_lockedtodata),
    //parallel data ports
    .tx_parallel_data(tx_parallel_data),
    .rx_parallel_data(rx_parallel_data_native),
    //---------------------
    // PMA specific ports
    //---------------------
    .tx_pma_clkout(),   // TX Parallel clock output from PMA  /// remove .. do not need 
    .rx_pma_clkout(),   // RX Parallel clock output from PMA  /// remove .. do not need
    .tx_pma_parallel_data (80'b0),
    .rx_clkslip(rx_clkslip),
    //PPM detector clocks
    .rx_clklow(),    // RX Low freq recovered clock, PPM detecror specific
    .rx_fref(),                      // RX PFD reference clock, PPM detecror specific
    //-------------------------
    // Standard PCS ports
    //------------------------- 
    // clock ports
    .tx_std_coreclkin(tx_coreclkin_1g),   // 8G PCS PLD Tx parallel clock input
    .rx_std_coreclkin(rx_coreclkin_1g),   // 8G PCS PLD Tx parallel clock input
    .tx_std_clkout   (tx_clkout_1g_int),      // TX Parallel clock output
    .rx_std_clkout   (rx_clkout_1g_int),      // RX parallel clock output
    //electrical idle
    .tx_std_elecidle(tx_std_elecidle),
    //Phase compensation FIFOs
    .tx_std_pcfifo_full (tx_std_pcfifo_full ),  //Phase comp. FIFO full   
    .tx_std_pcfifo_empty(tx_std_pcfifo_empty), //Phase comp. FIFO empty
    .rx_std_pcfifo_full (rx_std_pcfifo_full ),  //Phase comp. FIFO full
    .rx_std_pcfifo_empty(rx_std_pcfifo_empty), //Phase comp. FIFO empty
    // Byte Ordering
    .rx_std_byteorder_ena (rx_std_byteorder_ena),
    .rx_std_byteorder_flag(),
    // Bit reversal
    .rx_std_bitrev_ena(rx_std_bitrev_ena),
    // Byte (de)serializer 
    .rx_std_byterev_ena(1'b0),
    // Polarity inversion
    .tx_std_polinv(tx_std_polinv),
    .rx_std_polinv(rx_std_polinv),
    // Bit slip
    .tx_std_bitslipboundarysel(5'b0),
    .rx_std_bitslipboundarysel(rx_std_bitslipboundarysel),
    .rx_std_bitslip(1'b0),
    //Word align/Deterministic SM
    .rx_std_wa_a1a2size(1'b0),
    .rx_std_wa_patternalign(1'b0),
    //Rate Match FIFO
    .rx_std_rmfifo_full (),   //Rate Match FIFO full
    .rx_std_rmfifo_empty(),   //Rate Match FIFO empty
    // Run length detector
    .rx_std_runlength_err (rx_rlv),    
    //signal detect
    .rx_std_signaldetect(),    
    //-------------------------
    // 10G PCS ports
    //-------------------------
    //clock ports
    .tx_10g_coreclkin(tx_10g_coreclkin),   // 10G PCS PLD Tx parallel clock input
    .rx_10g_coreclkin(xgmii_rx_clk_mux),   // 10G PCS PLD Tx parallel clock input
    .tx_10g_clkout   (tx_10g_clkout_int),      // TX Parallel clock output
    .rx_10g_clkout   (rx_recovered_clk_int),   // RX parallel clock output
    .rx_10g_clk33out (rx_clkout),          // RX parallel /33 clock output
    // data path/control
    .tx_10g_control({1'b0,tx_parallel_ctrl}),
    .rx_10g_control(rx_10g_control_inter),
    // TxFIFO/RxFIFO
    .tx_10g_frame_diag_status (2'b00),
    .tx_10g_data_valid(tx_10g_data_valid),
    .tx_10g_frame_burst_en(1'b1),
    .tx_10g_fifo_full  (tx_10g_fifo_full_inter),
    .tx_10g_fifo_pfull (),
    .tx_10g_fifo_empty (),
    .tx_10g_fifo_pempty(),
    .rx_10g_fifo_rd_en (1'b0), 
    .rx_10g_data_valid (rx_10g_data_valid),
    .rx_10g_fifo_full  (rx_10g_fifo_full_inter),
    .rx_10g_fifo_pfull (),
    .rx_10g_fifo_empty (),
    .rx_10g_fifo_pempty(),
    .rx_10g_fifo_align_clr (1'b0), 
    .rx_10g_fifo_align_en (1'b0), 
    // Bit slip
    .tx_10g_bitslip(7'b0),
    .rx_10g_bitslip(rx_bitslip),
    // Block sync
    .rx_10g_blk_lock    (rx_block_lock_hard),
    .rx_10g_blk_sh_err  (rx_sync_head_error),
    // Scrambler/de-scrambler
    .rx_10g_descram_err (rx_scrambler_error),
    // Frame generator/sync
    .tx_10g_frame         (),
    .rx_10g_frame         (),
    .rx_10g_frame_lock    (),
    .rx_10g_frame_mfrm_err(),
    .rx_10g_frame_sync_err(),
    .rx_10g_frame_skip_ins(),
    .rx_10g_frame_skip_err(),
    // BER
    .rx_10g_highber(rx_hi_ber_hard),
    .rx_10g_highber_clr_cnt (clr_ber_cnt),
    .rx_10g_clr_errblk_count(clr_errblk_cnt),
    // PRBS status ports
     .rx_std_prbs_err     (rx_std_prbs_err    ),  
     .rx_std_prbs_done    (rx_std_prbs_done   ),  

     .rx_10g_prbs_err     (rx_10g_prbs_err    ),  
     .rx_10g_prbs_done    (rx_10g_prbs_done   ),  
     .rx_10g_prbs_err_clr (rx_10g_prbs_err_clr), 
    // Tie some unused input ports to gnd here
    .rx_pma_qpipulldn  (1'b0), 
    .tx_pma_qpipulldn  (1'b0), 
    .tx_pma_qpipullup  (1'b0), 
    .tx_pma_txdetectrx (1'b0)     
    ) ;  
// use pma clk out only in 1588 mode
  if (SYNTH_1588_1G==1) begin
   assign tx_clkout_1g   = out_pma_tx_clk_out ;
   assign rx_clkout_1g   = out_pma_rx_clk_out ;
  end 
  else begin
   assign tx_clkout_1g   = tx_clkout_1g_int ;
   assign rx_clkout_1g   = rx_clkout_1g_int ;
  end	  

  if (SYNTH_1588_10G==1) begin
   assign rx_recovered_clk = out_pma_rx_clk_out ;
   assign tx_10g_clkout    = out_pma_tx_clk_out ;
 end 
 else begin 
   assign rx_recovered_clk = rx_recovered_clk_int ;
   assign tx_10g_clkout    = tx_10g_clkout_int ;
  end	  
	 
///// Instantiate SV_XCVR_PLL for 10G /// Start here
	sv_xcvr_plls #(
		.plls                                 (1),
		.pll_type                             (PLL_TYPE_10G),
		.pll_reconfig                         (0),
		.refclks                              (1),
//		.pll_network_select                   (PLL_NETWORK_SEL),
		.reference_clock_frequency            (REF_CLK_FREQ_10G),
		.reference_clock_select               ("0"),
		.output_clock_datarate                ("10312.5 Mbps"),
		.output_clock_frequency               ("0 ps"),
		.feedback_clk                         ("internal"),
		.sim_additional_refclk_cycles_to_lock (0),
		.duty_cycle                           (50),
		.phase_shift                          ("0 ps"),
		.enable_hclk                          ("0"),
		.enable_avmm                          (1),
		.use_generic_pll                      (0),
		.att_mode                             (0),
		.enable_mux                           (1)
	) tx_pll_10g (
		.rst                ({pll_powerdown_10g}),    //      pll_powerdown.pll_powerdown
		.refclk             ({pll_ref_clk_10g}),       //         pll_refclk.pll_refclk
		.fbclk              (/*internal_fb*/),        //          pll_fbclk.pll_fbclk
		.outclk             (ext_pll_clk[0]),     //         pll_clkout.pll_clkout
		.locked             (pll_locked_bus[0]),     //         pll_locked.pll_locked
		.reconfig_to_xcvr   (reconfig_to_xcvr[reconfig_to_xcvr_pll_10g-1:reconfig_to_xcvr_ch]),   //   reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr (reconfig_from_xcvr[reconfig_from_xcvr_pll_10g-1:reconfig_from_xcvr_ch]), // reconfig_from_xcvr.reconfig_from_xcvr
		.pll_fb_sw          (1'b0),               //        (terminated)
		.fboutclk           (),                   //        (terminated)
		.hclk               ()                    //        (terminated)
	);

  
///// Instantiate SV_XCVR_PLL for 10G /// End here
  end // DEVICE_FAMILY == "Stratix V"  || DEVICE_FAMILY == "Arria V GZ" 
endgenerate

//****************************************************************************
// Instantiate tx clock mux -- only when SYNTH_FEC==1
// In FEC mode 10G TX coreclkin=161 while in 10G/AN/LT mode coreclkin=156
//****************************************************************************
generate 
  if (SYNTH_FEC ) 
  begin : TX_CLK_MUX 
  wire fec_mode ;
  assign fec_mode = data_mux_sel[1] & (pcs_mode_rc[5]) ;
gf_clock_mux gf_tx_clk_mux_inst (
       .clk         ({tx_10g_clkout,  xgmii_tx_clk}), // use 10g-coreclkin from 1588 if-generate
       .clk_select  ({fec_mode     , ~fec_mode}),
       .clk_out     (tx_10g_coreclkin)
  );
 end 
 else begin : NO_CLK_MUX
  assign tx_10g_coreclkin = xgmii_tx_clk ;
 end  
endgenerate
 
//****************************************************************************
// FEC and Soft 10G PCS instantiation starts here 
// Instantiate 10G-KR FEC -- only when SYNTH_FEC==1
//****************************************************************************
generate 
  if (SYNTH_FEC ) 
  begin : FEC_SOFT10G

  wire        fec_tx_trans_err;
  wire        fec_tx_burst_err;
  wire [3:0]  fec_tx_burst_err_len;
  wire        fec_tx_enc_query;
  wire        fec_rx_signok_en;
  wire        fec_rx_fast_search_en;
  wire        fec_rx_blksync_cor_en;
  wire        fec_rx_dv_start;
  wire        fec_tx_err_ins;
  wire        clear_counters;
  wire [31:0] fec_corr_blks;
  wire [31:0] fec_uncr_blks;
  wire        clr_corr_blks;
  wire        clr_uncr_blks;
  wire [9:0]  write_en, write_en_ack; 
  
  wire [71:0]  xgmii_rx_dc_soft;
  wire 	       rx_block_lock_soft;
  wire 	       rx_data_ready_soft;
  wire 	       rx_hi_ber_soft;
  wire [5:0]   bercount_soft;        
  wire [7:0]   errorblockcount_soft; 
  wire 	       pcsstatus_soft;       
  wire 	       txfifofull_soft;      
  wire 	       rxfifofull_soft;      

//********************** FEC CSR
  csr_krfec  csr_krfec_inst (
  // user data (avalon-MM formatted) 
  .clk                   (mgmt_clk              ),      
  .reset                 (mgmt_clk_reset        ),
  .address               (mgmt_address          ),  
  .read                  (mgmt_read             ),     
  .readdata              (fec_mgmt_readdata     ),
  .write                 (mgmt_write            ),    
  .writedata             (mgmt_writedata        ),
  // FEC status sync
  .write_en(write_en),
  .write_en_ack(write_en_ack),
  // FEC input/outputs
  .fec_tx_trans_err      (fec_tx_trans_err      ),
  .fec_tx_burst_err      (fec_tx_burst_err      ),
  .fec_tx_burst_err_len  (fec_tx_burst_err_len  ),
  .fec_tx_enc_query      (fec_tx_enc_query      ),
  .fec_tx_err_ins        (fec_tx_err_ins        ),
  .fec_rx_signok_en      (fec_rx_signok_en      ),
  .fec_rx_fast_search_en (fec_rx_fast_search_en ),
  .fec_rx_blksync_cor_en (fec_rx_blksync_cor_en ),
  .fec_rx_dv_start       (fec_rx_dv_start       ),
  .fec_corr_blks         (fec_corr_blks         ),
  .fec_uncr_blks         (fec_uncr_blks         ),
  // read/write control outputs
  .clear_counters        (clear_counters        ),
  .clr_corr_blks         (clr_corr_blks         ),
  .clr_uncr_blks         (clr_uncr_blks         )
);
//********************** FEC CSR
assign phy2fec_data_in = rx_parallel_data_1588;
// Apply embedded false path timing constraints for FEC
  (* altera_attribute = SDC_8G_TO_FEC *)
  hd_krfec_top_wrapper  #(
   .GOOD_PARITY    (GOOD_PARITY),	  
   .INVALD_PARITY  (INVALD_PARITY),
   .USE_M20K       (USE_M20K)
  ) hd_krfec_inst0 (
   // Resets 
    .usr_fec_reset          (usr_fec_reset  ),
    .rx_digitalreset        (rx_digitalreset),
    .tx_digitalreset        (tx_digitalreset),
    // PLD IF ports
    .clear_counters         (clear_counters),
    .rx_block_lock          (fec2pcs_block_lock), // output
    // PMA IF ports
    .rx_signal_ok_in        (rx_is_lockedtodata),// from the 10G LL Hard PHY
    //   TX
    .tx_krfec_clk           (tx_10g_clkout),     // 161.1MHz clock			   
    .tx_data_valid_in       (pcs2fec_data_valid),     // input from soft 10G PCS
    .tx_data_in             (pcs2fec_data_out[65:2]), // input from soft 10G PCS
    .tx_control_in          (pcs2fec_data_out[1:0] ), // input from soft 10G PCS
    .tx_data_out            (fec2phy_data_out),  // output to 10G LL Hard PHY
    //   RX
    .rx_krfec_clk           (rx_recovered_clk),  // 161.1MHz clock
    .rx_data_in             (phy2fec_data_in),   // input from 10G LL Hard PHY
    .rx_data_valid_out      (fec2pcs_data_valid),     // output to soft 10G PCS
    .rx_data_out            (fec2pcs_data_out),       // output to soft 10G PCS
    .rx_control_out         (fec2pcs_ctrl_out),       // output to soft 10G PCS
    .rx_signal_ok_out       (fec2pcs_signal_ok),      // output to soft 10G PCS
     
    // DPRIO ports
    .fec_rx_signok_en       (fec_rx_signok_en     ),
    .fec_err_ind            (fec_err_ind          ),
    .fec_rx_fast_search_en  (fec_rx_fast_search_en),  
    .fec_rx_blksync_cor_en  (fec_rx_blksync_cor_en),  
    .fec_rx_dv_start        (fec_rx_dv_start      ),  
    .clr_uncr_blks          (clr_uncr_blks        ),    
    .clr_corr_blks          (clr_corr_blks        ),   
    .fec_tx_burst_err_len   (fec_tx_burst_err_len ),    
    .fec_tx_burst_err       (fec_tx_burst_err     ), 
    .fec_tx_trans_err       (fec_tx_trans_err     ),    
    .fec_tx_enc_query       (fec_tx_enc_query     ),   
    .fec_tx_err_ins         (fec_tx_err_ins       ),   
    //   STATUS
    .fec_corr_blks          (fec_corr_blks        ),  
    .fec_uncr_blks          (fec_uncr_blks        ),  
    .write_en               (write_en),
    .write_en_ack           (write_en_ack)
    );
	   
//****************************************************************************
// Instantiate soft 10GBASE-R PCS
//****************************************************************************	   
    alt_10gbaser_pcs #(
        .SYNTH_FEC (1),
        .pma_data_width(66),
        .pma_external_data_width(66),  
        .operation_mode("duplex")
        ) sv_10gbaser_soft_pcs_inst(
            .tx_ready            (/*unused*/),
            .rx_ready            (/*unused*/),
            .tx_pma_ready        (/*unused*/),
            .rx_pma_ready        (/*unused*/),
            
            // AvalonMM signals
	    .mgmt_clk            (mgmt_clk),                 // AvalonMM clock
	    .mgmt_rstn           (~mgmt_clk_reset),          // AvalonMM active low reset
            .pcs_mgmt_address    (3'b000),    // AvalonMM address
            .pcs_mgmt_read       (1'b0),      // AvalonMM read
            .pcs_mgmt_write      (1'b0),      // AvalonMM write
            .pcs_mgmt_writedata  (16'h00),    // AvalonMM write data
    
            .tx_usr_clk          (xgmii_tx_clk),             // xgmii_tx_clk.clk - 156.25MHz
            .xgmii_rx_clk        (),                         
            .xgmii_tx_dc         (xgmii_tx_dc),              // xgmii_tx_dc_0.data
            .xgmii_rx_dc         (xgmii_rx_dc_soft),         // xgmii_rx_dc_0.data
            .rx_usr_clk          (xgmii_tx_clk),             // 156.25MHz - driven by xgmii_tx_clk for test,
				                             // would normally be connected outside KR PHY
            
            // XGMII inputs from MAC
            .rx_pma_clk          (rx_recovered_clk),         // RX PMA Clock - 161.1MHz
            .pma_data_in         ({fec2pcs_data_out, fec2pcs_ctrl_out[1:0]}),  // Data In from FEC
            .fec_data_in_valid   (fec2pcs_data_valid),       // Data Valid in from fec
            .fec_rx_block_lock_in(fec2pcs_block_lock),       // Block lock in from fec 
    
            // Outputs to PMA
            .tx_pma_clk          (tx_10g_clkout),            // TX PMA Clock - 161.1MHz
            .pma_data_out        (pcs2fec_data_out),         // Data Out to FEC
	    .fec_data_out_valid  (pcs2fec_data_valid),       // Data Valid out to FEC
    
            // Control Signals
            .signal_ok           (fec2pcs_signal_ok),        
            .clr_errblk_cnt      (clr_errblk_cnt),                     
            .clr_ber_count       (clr_ber_cnt),                     
	    .tx_rst_only         (tx_soft_10g_pcs_reset),    
	    .rx_rst_only         (rx_soft_10g_pcs_reset),   

            // Status signals
            .block_lock          (rx_block_lock_soft),  
            .rx_data_ready       (rx_data_ready_soft),  
            .hi_ber              (rx_hi_ber_soft),  
	    .ber_count           (bercount_soft),            // Indicates BER Count
            .errored_block_count (errorblockcount_soft),     // Errored Block Count
            .pcs_status          (pcsstatus_soft),           // PCS status
            .tx_fifo_full        (txfifofull_soft),          // TX Clock Comp FIFO full
            .rx_fifo_full        (rxfifofull_soft),          // RX Clock Comp FIFO full
            .tx_latency_adj      (/*unused*/),  // since this FEC and 1588 are not enabled at same time this is unused 
            .rx_latency_adj      (/*unused*/)   // since this FEC and 1588 are not enabled at same time this is unused 
            );

//****************************************************************************
// In FEC mode rx_dc is from soft PCS else from hard PCS
// MUX CSR between soft and Hard PCS when AN results to FEC - only when 
// SYNTH_FEC is 1
//****************************************************************************
  assign rx_block_lock = (data_mux_sel[1] & (pcs_mode_rc[5])) ? rx_block_lock_soft : rx_block_lock_hard ;
  assign rx_hi_ber     = (data_mux_sel[1] & (pcs_mode_rc[5])) ? rx_hi_ber_soft     : rx_hi_ber_hard ;
  assign rx_data_ready = (data_mux_sel[1] & (pcs_mode_rc[5])) ? rx_data_ready_soft : rx_data_ready_hard;
  assign tx_10g_full   = (data_mux_sel[1] & (pcs_mode_rc[5])) ? txfifofull_soft    : tx_10g_fifo_full;
  assign rx_10g_full   = (data_mux_sel[1] & (pcs_mode_rc[5])) ? rxfifofull_soft    : rx_10g_fifo_full;
  assign rx_fec_status = fec2pcs_block_lock   &  rx_block_lock_soft ; 
  assign xgmii_rx_dc = (data_mux_sel[1] & (pcs_mode_rc[5])) ? xgmii_rx_dc_soft : xgmii_rx_dc_hard ;

  end // SYNTH_FEC
  
  else begin : NO_SYNTH_FEC
  assign fec_mgmt_readdata    = 32'b0 ;
  assign fec2phy_data_out     = 64'b0 ;
  assign rx_block_lock =  rx_block_lock_hard ;
  assign rx_hi_ber     =  rx_hi_ber_hard ;
  assign rx_data_ready =  rx_data_ready_hard ;
  assign tx_10g_full   =  tx_10g_fifo_full;
  assign rx_10g_full   =  rx_10g_fifo_full;
  assign rx_fec_status =  1'b0; 
  assign xgmii_rx_dc  = xgmii_rx_dc_hard ;
  end // NO_SYNTH_FEC 
endgenerate

//****************************************************************************
// FEC and Soft 10G PCS instantiion ends here 
//****************************************************************************

//****************************************************************************
// DATA ADAPTER FOR 1G
// also Registers and the GIGE PCS module
//****************************************************************************
  wire  [31:0] gige_pma_readdata;      // read data from the Gige PMA CSR
  wire  [15:0] gige_pcs_readdata;      // read data from the Gige PCS CSR

generate 
 if (SYNTH_GIGE) begin : GIGE_ENABLE
 wire [8:0 ] tx_parallel_data_DA;
 wire rx_runningdisp;
 wire rx_datak;
 wire rx_disperr;
 wire rx_patterndetect;
 wire rx_rmfifodatainserted;
 wire rx_rmfifodatadeleted;
 wire tx_datak;
 wire rx_errdetect;

   sv_xcvr_data_adapter #(
    .lanes             (1           ),  //Number of lanes chosen by user. legal value: 1+
    .channel_interface (0), //legal value: (0,1) 1-Enable channel reconfiguration
    .ser_base_factor   (8               ),  // (8,10)
    .ser_words         (1               ),  // (1,2,4)
    .skip_word         (1               )   // (1,2)
  ) sv_xcvr_data_adapter_inst( 
    .tx_parallel_data     (tx_parallel_data_1g   ),
    .tx_datak             (tx_datak             ),
    .tx_forcedisp         (         ),
    .tx_dispval           (           ),
    .tx_datain_from_pld   (tx_parallel_data_DA),
    // outputs
    .rx_dataout_to_pld    (rx_parallel_data_native),
    .rx_parallel_data     (rx_parallel_data_1g  ),
    .rx_datak             (rx_datak             ),
    .rx_errdetect         (rx_errdetect         ),
    .rx_syncstatus        (rx_syncstatus        ),
    .rx_disperr           (rx_disperr           ),
    .rx_patterndetect     (rx_patterndetect     ),
    .rx_rmfifodatainserted(rx_rmfifodatainserted),
    .rx_rmfifodatadeleted (rx_rmfifodatadeleted ),
    .rx_runningdisp       (rx_runningdisp       ),
    .rx_a1a2sizeout       (       )
  );


  csr_krgige  csr_krgige_inst (
    .clk        (mgmt_clk          ),
    .reset      (mgmt_clk_reset    ),
    .address    (mgmt_address      ),
    .read       (mgmt_read         ),
    .readdata   (gige_pma_readdata),
    .write      (mgmt_write        ),
    .writedata  (mgmt_writedata    ),
    //status inputs to this CSR
    .rx_sync_status     (rx_syncstatus),
    .rx_pattern_det     (rx_patterndetect),
    .rx_rlv             (rx_rlv),
    .rx_rmfifo_inserted (rx_rmfifodatainserted),
    .rx_rmfifo_deleted  (rx_rmfifodatadeleted),
    .rx_disperr         (rx_disperr),
    .rx_errdetect       (rx_errdetect),
    // read/write control outputs
    .tx_invpolarity  (tx_std_polinv),
    .rx_invpolarity  (rx_std_polinv),
    .rx_bitreversal  (rx_std_bitrev_ena),
    .rx_bytereversal (rx_std_byteorder_ena),
    .force_elec_idle (tx_std_elecidle)
  );

  // mux or combine if have Gige mode
  assign tx_parallel_data_native[63:9] = tx_parallel_data_1588[63:9];
  assign tx_parallel_data_native[8:0]  = pcs_mode_rc[3] ? tx_parallel_data_DA: 
                                                          tx_parallel_data_1588[8:0];
  assign pll_locked  = pcs_mode_rc[3] ? pll_locked_bus[1] : 
                                        pll_locked_bus[0] ;
  assign pll_powerdown =  {pll_powerdown_10g, pll_powerdown_1g} ;
  assign tx_pcfifo_error_1g =  tx_std_pcfifo_full | tx_std_pcfifo_empty ; 
  assign rx_pcfifo_error_1g =  rx_std_pcfifo_full | rx_std_pcfifo_empty ; 

//// instantiate GMII = GIGE PCS and related/internal CSRs here 
   if (SYNTH_GMII) begin : GMII_PCS_ENABLED
       
       wire gige_pcs_write;
       wire set_10,set_100,set_1000;
     
    // only enable gige_pcs for address in range = 0x90 to 0xA7
       assign gige_pcs_write = (mgmt_address >= 8'h90) &&
                               (mgmt_address <= 8'hA7) & mgmt_write;
       assign gige_pcs_read =  (mgmt_address >= 8'h90) &&
                               (mgmt_address <= 8'hA7) & mgmt_read;
       
       wire [21:0] tx_latency_adj_1g_w;
       wire [21:0] rx_latency_adj_1g_w;
      
       assign tx_latency_adj_1g = (HIGH_PRECISION_LATADJ) ? tx_latency_adj_1g_w : tx_latency_adj_1g_w[21:4];
       assign rx_latency_adj_1g = (HIGH_PRECISION_LATADJ) ? rx_latency_adj_1g_w : rx_latency_adj_1g_w[21:4];
       
  // Apply embedded false path timing constraints
  (* altera_attribute = SDC_GIGE_PCS *)
      kr_gige_pcs_top # (  
         .PHY_IDENTIFIER   (PHY_IDENTIFIER),  // PHY Identifier 
         .DEV_VERSION      (DEV_VERSION   ),  // Customer Phy's Core Version
         .ENABLE_SGMII     (SYNTH_SGMII  ),   // Enable SGMII logic synthesis
         .DEVICE_FAMILY    (DEV_FAM       ),  // device family for the core 
         .SYNTH_CL37ANEG   (SYNTH_CL37ANEG),  // Enable GIGE AN (Clause 37)
         .ENABLE_PHASE_CALC(SYNTH_1588_1G)    // Enable 1588 Phase Calculation
          )  kr_gige_pcs_top (
         .tx_pcs_clk            (tx_clkout_1g),   // TX clock from PHYIP
         .rx_pcs_clk            (rx_clkout_1g),   // RX clock from PHYIP
         .reset_reg_clk         (mgmt_clk_reset),
         .reset_tx_clk          (tx_digitalreset_fnl),
         .reset_rx_clk          (rx_digitalreset_fnl),
         .tx_clk                (),       // TX clock to MAC--open as only for SMGII
         .rx_clk                (),       // RX clock to MAC--open as only for SMGII   
         .tx_clkena             (mii_tx_clkena),  
         .tx_clkena_half_rate   (mii_tx_clkena_half_rate),
         .rx_clkena             (mii_rx_clkena),  
         .rx_clkena_half_rate   (mii_rx_clkena_half_rate),
         .led_an                (led_an                ),
         .led_char_err          (led_char_err          ),
         .led_col               (                      ),  // NA for this mode
         .led_crs               (                      ),
         .led_disp_err          (led_disp_err          ),
         .led_link              (led_link              ),
         .set_10                (set_10  ),  
         .set_100               (set_100 ), 
         .set_1000              (set_1000), 
         .hd_ena                (), /// open 
         .gmii_rx_d             (gmii_rx_d             ),
         .gmii_rx_dv            (gmii_rx_dv            ),
         .gmii_rx_err           (gmii_rx_err           ),
         .gmii_tx_d             (gmii_tx_d             ),
         .gmii_tx_en            (gmii_tx_en            ),
         .gmii_tx_err           (gmii_tx_err           ),
         .mii_tx_d              (mii_tx_d  ),   
         .mii_tx_en             (mii_tx_en ),  
         .mii_tx_err            (mii_tx_err),  
         .mii_rx_d              (mii_rx_d  ),  
         .mii_rx_dv             (mii_rx_dv ),   
         .mii_rx_err            (mii_rx_err),  
         .mii_col               (),  //MII SIGNALS OPEN
         .mii_crs               (),  //MII SIGNALS OPEN
         .reg_clk               (mgmt_clk        ),
         .calc_clk              (calc_clk_1g),
         .reg_address           ({~mgmt_address[4],mgmt_address[3:0]} ),  // this is equivalent of mgmt_address-8'h90 .. as long as we are looking at 5 LSBs of mgmt_address
         .reg_read              (gige_pcs_read       ),
         .reg_readdata          (gige_pcs_readdata),
         .reg_waitrequest       (gige_pcs_waitreq),
         .reg_write             (gige_pcs_write),
         .reg_writedata         (mgmt_writedata[15:0]),
         .tx_frame              (tx_parallel_data_1g   ),
         .tx_kchar              (tx_datak            ),
         .rx_frame              (rx_parallel_data_1g   ),
         .rx_kchar              (rx_datak            ),
         .rx_syncstatus         (rx_syncstatus),
         .rx_disp_err           (rx_disperr),
         .rx_char_err           (rx_errdetect),
         .rx_runlengthviolation (rx_rlv),
         .rx_patterndetect      (rx_patterndetect),
         .rx_runningdisp        (rx_runningdisp),
         .rx_rmfifodatadeleted  (rx_rmfifodatadeleted),
         .rx_rmfifodatainserted (rx_rmfifodatainserted),
         .rx_latency_adj        (rx_latency_adj_1g_w),
         .tx_latency_adj        (tx_latency_adj_1g_w),
         .wa_boundary           (rx_std_bitslipboundarysel)		 
      );

      if (SYNTH_SEQ) begin : SPEED_SEL_SEQ
        always @ (*) begin
         case({pcs_mode_rc[3],set_10,set_100,set_1000})
           4'b1100 : mii_speed_sel = 2'b11;	       
           4'b1010 : mii_speed_sel = 2'b10;	       
           4'b1001 : mii_speed_sel = 2'b01;
           default : mii_speed_sel = 2'b00;
         endcase
        end	      
      end
      else begin : SPEED_SEL_NO_SEQ
        always @ (*) begin
         case({mode_1g_10gbar,set_10,set_100,set_1000})
           4'b1100 : mii_speed_sel = 2'b11;	       
           4'b1010 : mii_speed_sel = 2'b10;	       
           4'b1001 : mii_speed_sel = 2'b01;
           default : mii_speed_sel = 2'b00;
         endcase
        end	      
      end 	      
    end  // SYNTH GMII
      else begin  :  GMII_PCS_DISABLED
      assign gmii_rx_err = 0 ;
      assign gmii_rx_dv  = rx_datak ;
      assign gmii_rx_d = rx_parallel_data_1g ;
      assign tx_parallel_data_1g = gmii_tx_d ;
      assign tx_datak  = gmii_tx_en ;
      assign gige_pcs_readdata = 16'd0;
      assign led_an = 1'b0;
      assign led_char_err = 1'b0;
      assign led_disp_err = 1'b0;
      assign led_link = 1'b0;
      assign gige_pcs_waitreq= 1'b0;
      assign gige_pcs_read = 1'b0 ;
      assign rx_latency_adj_1g = {LATADJ_WIDTH_1G{1'b0}};
      assign tx_latency_adj_1g = {LATADJ_WIDTH_1G{1'b0}};
      assign mii_tx_clkena = 1'b0;
      assign mii_rx_clkena = 1'b0;
      assign mii_rx_d      = 4'b0;
      assign mii_rx_dv     = 1'b0;
      assign mii_rx_err    = 1'b0;
      assign mii_speed_sel = 2'b0;
      end

  if ( DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria V GZ" ) 
        begin : PLL_1G
///// Instantiate SV_XCVR_PLL for 1G /// Start here
        localparam PLL_DATA_RATE_1G =  (PLL_TYPE_1G=="ATX") ? "10000 Mbps" : "1250 Mbps" ;
	localparam USE_FPLL = (PLL_TYPE_1G=="fPLL") ? 1 : 0 ;
	localparam AVMM_EN  = (PLL_TYPE_1G=="fPLL") ? 0 : 1 ;
	
	sv_xcvr_plls #(
		.plls                                 (1),
		.pll_type                             (PLL_TYPE_1G),
		.pll_reconfig                         (0),
//              .pll_network_select                   (PLL_NETWORK_SEL),
		.refclks                              (1),
		.reference_clock_frequency            (REF_CLK_FREQ_1G),
		.reference_clock_select               ("0"),
		.output_clock_datarate                (PLL_DATA_RATE_1G),
		.output_clock_frequency               ("0 ps"),
		.feedback_clk                         ("internal"),
		.sim_additional_refclk_cycles_to_lock (0),
		.duty_cycle                           (50),
		.phase_shift                          ("0 ps"),
		.enable_hclk                          ("0"),
		.enable_avmm                          (AVMM_EN),
		.use_generic_pll                      (USE_FPLL),
		.att_mode                             (0),
		.enable_mux                           (1)
	) tx_pll_1g (
		.rst                ({pll_powerdown_1g}),    //      pll_powerdown.pll_powerdown
		.refclk             ({pll_ref_clk_1g}),       //         pll_refclk.pll_refclk
		.fbclk              (/*internal_fb*/),        //          pll_fbclk.pll_fbclk
		.outclk             (ext_pll_clk[1]),     //         pll_clkout.pll_clkout
		.locked             (pll_locked_bus[1]),     //         pll_locked.pll_locked
		.reconfig_to_xcvr   (reconfig_to_xcvr[reconfig_to_xcvr_pll_1g-1:reconfig_to_xcvr_pll_10g]),   //   reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr (reconfig_from_xcvr[reconfig_from_xcvr_pll_1g-1:reconfig_from_xcvr_pll_10g]), // reconfig_from_xcvr.reconfig_from_xcvr
		.pll_fb_sw          (1'b0),               //        (terminated)
		.fboutclk           (),                   //        (terminated)
		.hclk               ()                    //        (terminated)
	);
    end  //  PLL_1G
  end  // SYNTH GIGE
    else begin : GIGE_DISABLED
	assign tx_parallel_data_native = tx_parallel_data_1588;
    assign pll_locked  = pll_locked_bus ;
    assign pll_powerdown =  pll_powerdown_10g ;
    assign tx_pcfifo_error_1g =  1'b0 ; 
    assign rx_pcfifo_error_1g =  1'b0 ; 
    assign gige_pcs_readdata = 16'd0;
    assign gige_pma_readdata = 32'd0;
    assign rx_syncstatus = 1'b0;
    assign gige_pcs_waitreq= 1'b0;
    assign gige_pcs_read = 1'b0 ;
    assign gmii_rx_d = 8'b0 ;
    assign gmii_rx_dv = 1'b0 ;
    assign gmii_rx_err = 1'b0 ;
    assign led_an = 1'b0;
    assign led_char_err = 1'b0;
    assign led_disp_err = 1'b0;
    assign led_link = 1'b0;
    assign rx_latency_adj_1g = {LATADJ_WIDTH_1G{1'b0}};
    assign tx_latency_adj_1g = {LATADJ_WIDTH_1G{1'b0}};
    end
endgenerate 


//****************************************************************************
// DATA ADAPTER FOR 10G
//****************************************************************************
generate
  genvar i;
  for (i=0; i<`TOTAL_XGMII_LANE; i=i+1) 
  begin: bus_assign
    //tx input
    assign tx_parallel_data_10g[`TOTAL_DATA_PER_LANE*i+:`TOTAL_DATA_PER_LANE]      = xgmii_tx_dc[`TOTAL_SIGNAL_PER_LANE*i+:`TOTAL_DATA_PER_LANE];
    assign tx_10g_control[i]                                                = xgmii_tx_dc[(`TOTAL_SIGNAL_PER_LANE*i+`TOTAL_DATA_PER_LANE)+:`TOTAL_CONTROL_PER_LANE];
    //rx output
    assign xgmii_rx_dc_hard[`TOTAL_SIGNAL_PER_LANE*i+:`TOTAL_SIGNAL_PER_LANE]= {rx_10g_control[i], rx_parallel_data_1588[`TOTAL_DATA_PER_LANE*i+:`TOTAL_DATA_PER_LANE]};
  end 
  endgenerate

//****************************************************************************
// IEEE-1588 logic for the 10G data mode
//****************************************************************************
  localparam FAWIDTH  = 6;
  localparam TSWIDTH  = 16;
  
    generate
    if (SYNTH_1588_10G) begin : soft10Gfifos

    (* altera_attribute = SDC_1588_CONSTRAINTS *)
     // Adding the following register because their seems to be a inversion on 3 of every 8 bits of this bus.
     // This inversion is due to the default XGMII word being the reset state of the FIFO.
     // The inversion makes it difficult to meet timing on this bus, because it induces 600ps of difference
     // on the bits.

	 // tx fifos below
     reg               tx_rd_rstn,tx_rd_rstn_m1;
     reg               tx_wr_rstn,tx_wr_rstn_m1;
	 
	      // Synchronize the reset of the FIFO
     always @(posedge tx_10g_clkout or posedge tx_digitalreset_fnl) begin
       if (tx_digitalreset_fnl == 1) begin
        tx_rd_rstn <= 0;
        tx_rd_rstn_m1 <= 0;
       end else begin
        tx_rd_rstn <= tx_rd_rstn_m1;
        tx_rd_rstn_m1 <= 1;
       end	
     end
	 
	 always @(posedge xgmii_tx_clk or posedge tx_digitalreset_fnl) begin
       if (tx_digitalreset_fnl == 1) begin
        tx_wr_rstn <= 0;
        tx_wr_rstn_m1 <= 0;
       end else begin
        tx_wr_rstn <= tx_wr_rstn_m1;
        tx_wr_rstn_m1 <= 1;
       end
     end
	 
	 wire [ 64-1:0 ]   tx_datain_l;
     wire [  8-1:0 ]   tx_control_l;
     wire              tx_data_valid_l;
	 
     reg [ 64-1:0 ]    tx_datain_r;  
     reg [  8-1:0 ]    tx_control_r;
     reg [  8-1:0 ]    tx_data_valid_r;
     
	 assign tx_parallel_data_1588 = tx_datain_r;
     
     assign tx_10g_control_inter = tx_control_r;
     assign tx_10g_data_valid = tx_data_valid_r;

     always @(posedge tx_10g_clkout or negedge tx_rd_rstn) begin
	   if (tx_rd_rstn == 0) begin
        tx_datain_r <= 64'b0;
        tx_control_r <= 8'b0;
        tx_data_valid_r <= 8'b0;
       end else begin
        tx_datain_r <= tx_datain_l;
        tx_control_r <= tx_control_l;
        tx_data_valid_r <= tx_data_valid_l;
	   end	
     end
     
     wire [15:0] tx_latency_adj_10g_w;
     wire [15:0] rx_latency_adj_10g_w;
     
     assign tx_latency_adj_10g = (HIGH_PRECISION_LATADJ) ? tx_latency_adj_10g_w : tx_latency_adj_10g_w[15:4];
     assign rx_latency_adj_10g = (HIGH_PRECISION_LATADJ) ? rx_latency_adj_10g_w : rx_latency_adj_10g_w[15:4];
     
     altera_10gbaser_phy_clockcomp
       #(
         .FDWIDTH            (72),   // FIFO Data input width  
         .FAWIDTH            (5),
         .CC_TX              (1),                    // FIFO used in TX path 1, else 0 
         .IDWIDTH            (40),            // RX Gearbox Input Data Width 
         .ISWIDTH            (7),                    // RX Gearbox Selector width
         .ODWIDTH            (66),          // RX Gearbox Output Data Width
         .TSWIDTH            (TSWIDTH)
         )
     tx_clockcomp
       (
        // Outputs
        .data_out                   ({tx_control_l,tx_datain_l}),
        .data_out_valid             (tx_data_valid_l),
        .fifo_full                  (tx_10g_fifo_full),
        .latency_adj                (tx_latency_adj_10g_w),
        // Inputs
        .bypass_cc                  (1'b0),
        .wr_rstn                    (tx_wr_rstn),
        .wr_clk                     (xgmii_tx_clk),
        .data_in                    ({tx_10g_control,tx_parallel_data_10g[63:0]}),
        .data_in_valid              (1'b1),
        .rd_rstn                    (tx_rd_rstn),
        .rd_clk                     (tx_10g_clkout)
        );
		
    // RX fifos below
     reg [71:0] fifo_datain;
     reg        fifo_dvalid;
	 reg rx_wr_rstn, rx_wr_rstn_m1;
	 reg rx_rd_rstn, rx_rd_rstn_m1;
	 

     // Synchronize the reset of the FIFO

     always @(posedge rx_recovered_clk or posedge rx_digitalreset_fnl)
       if (rx_digitalreset_fnl == 1) begin
          rx_wr_rstn <= 1'b0;
          rx_wr_rstn_m1 <= 1'b0;
       end else begin
          rx_wr_rstn <= rx_wr_rstn_m1;
          rx_wr_rstn_m1 <= 1'b1;
       end

	 always @(posedge xgmii_rx_clk or posedge rx_digitalreset_fnl)
     if (rx_digitalreset_fnl == 1) begin
         rx_rd_rstn <= 1'b0;
         rx_rd_rstn_m1 <= 1'b0;
     end else begin
         rx_rd_rstn <= rx_rd_rstn_m1;
         rx_rd_rstn_m1 <= 1'b1;
     end
	 
	 always @(posedge rx_recovered_clk or negedge rx_wr_rstn)
       if (rx_wr_rstn == 0) begin
          fifo_datain <= 72'b0;
          fifo_dvalid <= 1'b0;
       end else begin
          fifo_datain <= {rx_10g_control_inter[7:0],rx_parallel_data_native};
          fifo_dvalid <= rx_10g_data_valid;
       end

     altera_10gbaser_phy_rx_fifo_wrap 
       #(
         .FDWIDTH            (72),   // FIFO Data input width  
         .FAWIDTH            (FAWIDTH),                    // FIFO Depth (address width) 
		 .FSYNCSTAGE         (4),
         .CC_TX              (0),                    // FIFO used in TX path 1, else 0 
         .IDWIDTH            (40),            // RX Gearbox Input Data Width 
         .ISWIDTH            (7),                    // RX Gearbox Selector width
         .ODWIDTH            (66),          // RX Gearbox Output Data Width
         .TSWIDTH            (TSWIDTH)
         )
     rx_clockcomp
       (
        .bypass_cc       (1'b0),                 // Bypass clock compensation
        .wr_rstn         (rx_wr_rstn),      // Write Domain Active low Reset
        .wr_clk          (rx_recovered_clk),     // Write Domain Clock
        .data_in         (fifo_datain),
        .data_in_valid   (fifo_dvalid),
        .rd_rstn         (rx_rd_rstn),      // Read Domain Active low Reset
        .rd_clk          (xgmii_rx_clk),         // Read Domain Clock
        .data_out        ({rx_10g_control[7:0],rx_parallel_data_1588}),  // Read Data Out (Contains CTRL+DATA)
        .data_out_valid  (),    // Read Data Out Valid
        .fifo_full       (rx_10g_fifo_full),           // FIFO Became FULL, Error Condition
        .latency_adj     (rx_latency_adj_10g_w)
        );
       assign rx_data_ready_hard = rx_10g_control_inter[`CTL_BFL];
	   assign rx_10g_coreclkin = rx_recovered_clk;
       assign rx_10g_control[9:8] = 2'b00;
    end else begin : hard10gfifos
	   assign tx_parallel_data_1588 = tx_parallel_data_10g;
       assign tx_10g_control_inter = tx_10g_control;
       assign tx_10g_data_valid = 1'b1;
       assign tx_latency_adj_10g = {LATADJ_WIDTH_10G{1'b0}};
       assign tx_10g_fifo_full = tx_10g_fifo_full_inter;
	   assign rx_data_ready_hard = rx_10g_control[`CTL_BFL];
       assign rx_10g_control = rx_10g_control_inter;
       assign rx_parallel_data_1588 = rx_parallel_data_native;
       assign rx_latency_adj_10g = {LATADJ_WIDTH_10G{1'b0}}; 
       assign rx_10g_fifo_full = rx_10g_fifo_full_inter;
	   assign rx_10g_coreclkin = xgmii_rx_clk;
	end
  endgenerate


//****************************************************************************
// Instantiate the CSR modules and the memory map logic
// no syncronizer on reset input
//****************************************************************************
  wire  csr_reset_tx_digital;	// to reset controller from csr
  wire  csr_reset_rx_digital;	// to reset controller from csr
  wire  csr_reset_all;		    // to reset controller from csr
  wire  csr_pll_powerdown;
  wire  csr_tx_digitalreset;		   // to xcvr instance from csr
  wire  csr_rx_analogreset;		       // to xcvr instance from csr
  wire  csr_rx_digitalreset;		   // to xcvr instance from csr
  wire  [31:0] pcs_mgmt_readdata;      // read data from the BaseR CSR 
  wire  [31:0] common_mgmt_readdata;   // read data from the common CSR 
  wire  [31:0] top_mgmt_readdata;      // read data from the SEQ/TOP CSR

  // Common PMA registers 0x00 - 0x7F
  alt_xcvr_csr_common #(
    .lanes  (1),
    .plls   (1)
    ) csr_com (
    .clk                              (mgmt_clk),
    .reset                            (mgmt_clk_reset),
    .address                          (mgmt_address),
    .read                             (mgmt_read),
    .readdata                         (common_mgmt_readdata),
    .write                            (mgmt_write),
    .writedata                        (mgmt_writedata),
    // Transceiver status inputs to CSR
    .pll_locked                       (pll_locked),
    .rx_is_lockedtoref                (rx_is_lockedtoref),
    .rx_is_lockedtodata               (rx_is_lockedtodata),
    .rx_signaldetect                  (1'b0),
    // from reset controller  - not used now that no reset controller inside
    .reset_controller_tx_ready        (1'b0),
    .reset_controller_rx_ready        (1'b0),
    .reset_controller_pll_powerdown   (1'b0),
    .reset_controller_tx_digitalreset (1'b0),
    .reset_controller_rx_analogreset  (1'b0),
    .reset_controller_rx_digitalreset (1'b0),
    // Read/write control registers
    .csr_reset_tx_digital             (csr_reset_tx_digital),
    .csr_reset_rx_digital             (csr_reset_rx_digital),
    .csr_reset_all                    (csr_reset_all),
    .csr_pll_powerdown                (csr_pll_powerdown),
    .csr_tx_digitalreset              (csr_tx_digitalreset),
    .csr_rx_analogreset               (csr_rx_analogreset),
    .csr_rx_digitalreset              (csr_rx_digitalreset),
    .csr_phy_loopback_serial          (csr_phy_loopback_serial),
    .csr_rx_set_locktoref             (csr_rx_set_locktoref),
    .csr_rx_set_locktodata            (csr_rx_set_locktodata)
  );

  // Legacy 10GbaseR registers 0x80 - 0x8F
  csr_pcs10gbaser #(
    .lanes              (1)
  ) csr_10gpcs (
    .clk                (mgmt_clk          ),
    .reset              (mgmt_clk_reset    ),
    .address            (mgmt_address      ),
    .read               (mgmt_read         ),
    .readdata           (pcs_mgmt_readdata ),
    .write              (mgmt_write        ),
    .writedata          (mgmt_writedata    ),
    .rx_clk             (xgmii_rx_clk      ),  // to synchronize rx control outputs
    .tx_clk             (xgmii_tx_clk      ),  // to synchronize tx control outputs
    .rx_pma_clk         (rx_clkout         ),  // to synchronize tx control outputs
    //transceiver status inputs to this CSR
    .pcs_status         (1'b0),              // not used with hard 10Gbase-R PHY??
    .hi_ber             (rx_hi_ber         ),
    .block_lock         (rx_block_lock     ),
    .rx_data_ready      (rx_data_ready     ),
    .tx_fifo_full       (tx_10g_full  ),
    .rx_fifo_full       (rx_10g_full  ),
    .rx_sync_head_error (rx_sync_head_error),
    .rx_scrambler_error (rx_scrambler_error),
    .ber_cnt            (6'd0),              // not in hard 10G PHY. Use DPRIO to access.
    .errored_block_cnt  (8'd0),              // not in hard 10G PHY. Use DPRIO to access.
    // read/write control outputs
    // PCS controls
    .csr_rclr_errblk_cnt(clr_errblk_cnt    ),
    .csr_rclr_ber_cnt   (clr_ber_cnt       )
  );


  // KR SEQ and top-level registers 0xB0 - 0xBF
  csr_krtop  # (
    .SYNTH_FEC  (SYNTH_FEC),
    .AN_FEC     (AN_FEC   ),
    .ERR_INDICATION (ERR_INDICATION)
    )    csr_krtop_inst (
    .clk        (mgmt_clk          ),
    .reset      (mgmt_clk_reset    ),
    .address    (mgmt_address      ),
    .read       (mgmt_read         ),
    .readdata   (top_mgmt_readdata ),
    .write      (mgmt_write        ),
    .writedata  (mgmt_writedata    ),
  //status inputs to this CSR
    .seq_link_rdy    (link_ready),
    .seq_an_timeout  (seq_an_timeout),
    .seq_lt_timeout  (seq_lt_timeout),
    .pcs_mode_rc     (pcs_mode_rc),
  // read/write control outputs
    .csr_reset_seq  (csr_seq_restart),
    .dis_an_timer   (dis_an_timer),
    .dis_lf_timer   (dis_lf_timer),
    .force_mode     (force_mode),
    .fec_enable     (fec_enable),
    .fec_request    (fec_request),
    .fec_err_ind    (fec_err_ind),
    .fail_lt_if_ber (fail_lt_if_ber)
  );

  // mux the register output (read) data for the different register blocks
  //
  assign mgmt_readdata = 
      (mgmt_address >= 8'h80) && (mgmt_address <= 8'h8F) ? pcs_mgmt_readdata :
      (mgmt_address >= 8'h90) && (mgmt_address <= 8'hA7) ? {16'b0,gige_pcs_readdata}:
      (mgmt_address >= 8'hA8) && (mgmt_address <= 8'hAF) ? gige_pma_readdata :
      (mgmt_address >= 8'hB0) && (mgmt_address <= 8'hB1) ? top_mgmt_readdata :
      (mgmt_address >= 8'hB2) && (mgmt_address <= 8'hBF) ? fec_mgmt_readdata :
      (mgmt_address >= 8'hC0) && (mgmt_address <= 8'hCF) ? an_mgmt_readdata  :
      (mgmt_address >= 8'hD0) && (mgmt_address <= 8'hDF) ? lt_mgmt_readdata  :
                                                         common_mgmt_readdata;

  // generate waitrequest
  altera_wait_generate wait_gen (
    .rst            (mgmt_clk_reset),
    .clk            (mgmt_clk),
    .launch_signal  (mgmt_read &~gige_pcs_read ),
    .wait_req       (waitrequest)
  );
  assign mgmt_waitrequest = (mgmt_address >= 8'h90) && (mgmt_address <= 8'hA7) ? gige_pcs_waitreq : waitrequest ;
//****************************************************************************
// Not integrating the PHY reset controller
// Have inputs for external controller
// Instantiate the transceiver sync module for AN and LT reset signals
//  \p4\ip\altera_xcvr_generic\ctrl\alt_xcvr_resync.sv
//****************************************************************************
  alt_xcvr_resync #(
      .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1)
  ) tx_resync_reset (
    .clk    (tx_clkout),
    .reset  (usr_an_lt_reset | csr_reset_all),
    .d      (1'b0),
    .q      (tx_anlt_reset)
  );

  alt_xcvr_resync #(
      .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1)
  ) rx_resync_reset (
    .clk    (rx_clkout),
    .reset  (usr_an_lt_reset | csr_reset_all),
    .d      (1'b0),
    .q      (rx_anlt_reset)
  );

  alt_xcvr_resync #(
      .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1)
  ) mgmt_resync_reset (
    .clk    (mgmt_clk),
    .reset  (usr_seq_reset | csr_reset_all),
    .d      (1'b0),
    .q      (seq_reset)
  );

   
 //****************************************************************************
// 10G-KR FEC Reset Synchronization - only when SYNTH_FEC==1
//****************************************************************************
generate 
  if (SYNTH_FEC ) 
  begin : SOFT10G_RESETS  

  // Synchronizing usr_soft_10g_pcs_reset to rx_recovered_clk - for FEC 
  alt_xcvr_resync #(
      .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1)
  ) rx_soft_10g_pcs_resync_reset (
    .clk    (rx_recovered_clk),
    .reset  (usr_soft_10g_pcs_reset | csr_reset_all | rx_digitalreset),
    .d      (1'b0),
    .q      (rx_soft_10g_pcs_reset)
  );

  // Synchronizing usr_soft_10g_pcs_reset to tx_10g_clkout - for FEC 
  alt_xcvr_resync #(
      .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1)
  ) tx_soft_10g_pcs_resync_reset (
    .clk    (tx_10g_clkout),
    .reset  (usr_soft_10g_pcs_reset | csr_reset_all | tx_digitalreset),
    .d      (1'b0),
    .q      (tx_soft_10g_pcs_reset)
  );
  end   
endgenerate

  assign  tx_analogreset_fnl  =  
                      tx_analogreset   | csr_pll_powerdown  | csr_reset_all;
  assign  tx_digitalreset_fnl = 
                      tx_digitalreset  | csr_tx_digitalreset| csr_reset_all;
  assign  rx_analogreset_fnl  = 
                      rx_analogreset   | csr_rx_analogreset | csr_reset_all;
  assign  rx_digitalreset_fnl = 
                      rx_digitalreset  | csr_rx_digitalreset| csr_reset_all;

endmodule  //altera_xcvr_10gbase_kr


//****************************************************************************
//****************************************************************************
// Glitch-Free Clock Mux module
// from Chapter 11 of Recommended HDL Coding Styles document
//  http://www.altera.com/literature/hb/qts/qts_qii51007.pdf
// See Figure 11-3 for circuit diagram
// code taken directly from Example 11-48
//****************************************************************************
module gf_clock_mux (clk, clk_select, clk_out);
  parameter num_clocks = 2;

  input [num_clocks-1:0] clk;
  input [num_clocks-1:0] clk_select; // one hot
  output clk_out;

  genvar i;
  reg  [num_clocks-1:0] ena_r0;
  reg  [num_clocks-1:0] ena_r1;
  reg  [num_clocks-1:0] ena_r2;
  wire [num_clocks-1:0] qualified_sel;

  // A look-up-table (LUT) can glitch when multiple inputs
  // change simultaneously. Use the keep attribute to
  // insert a hard logic cell buffer and prevent
  // the unrelated clocks from appearing on the same LUT.

  wire [num_clocks-1:0] gated_clks /* synthesis keep */;

  // Apply embedded false path timing constraint to first flop
  (* altera_attribute  = "-name SDC_STATEMENT \"set_false_path -to [get_registers {*gf_clock_mux*ena_r0*}]\"" *)
initial begin
  ena_r0 = 0;
  ena_r1 = 0;
  ena_r2 = 0;
end

  generate
    for (i=0; i<num_clocks; i=i+1) begin : lp0
      wire [num_clocks-1:0] tmp_mask;

      //assign tmp_mask = {num_clocks{1'b1}} ^ (1 << i);
      assign tmp_mask = {num_clocks{1'b1}} ^ ({{(num_clocks-1){1'b0}},1'b1} << i);
      assign qualified_sel[i] = clk_select[i] & (~|(ena_r2 & tmp_mask));

      always @(posedge clk[i]) begin
        ena_r0[i] <= qualified_sel[i];
        ena_r1[i] <= ena_r0[i];
      end // always

      always @(negedge clk[i]) ena_r2[i] <= ena_r1[i];

      assign gated_clks[i] = clk[i] & ena_r2[i];
    end // for i=
  endgenerate

// These will not exhibit simultaneous toggle by construction
  assign clk_out = |gated_clks;
endmodule  // gf_clock_mux
