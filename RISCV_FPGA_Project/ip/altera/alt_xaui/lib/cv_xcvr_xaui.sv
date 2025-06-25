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


//-----------------------------------------------------------------------------
//
// Description: xaui verilog for Arria V
//
// Authors:     hhleong    08-May-2012
//
//              Copyright (c) Altera Corporation 1997 - 2012
//              All rights reserved.
//
//-----------------------------------------------------------------------------
module cv_xcvr_xaui #(
  // initially found in sv_xcvr_custom_phy
  parameter device_family = "Cyclone V",
  parameter protocol_hint = "basic",  // (basic, gige)
  parameter operation_mode = "Duplex",  //legal value: TX,RX,Duplex
  parameter interface_type               = "Soft XAUI",
  parameter soft_pcs_legacy_new_n = 0,
  parameter xaui_pll_type                = "CMU",
  parameter use_control_and_status_ports = 0,
  parameter lanes = 4,  //legal value: 1+
  parameter bonded_group_size = 4,  //legal value: integer from 1 .. lanes
  parameter bonded_mode = "xN", // (xN, fb_compensation)
  parameter pma_bonding_mode = "xN", // ("x1", "xN")
  parameter pcs_pma_width = 10, //legal value: 8, 10, 16, 20
  parameter ser_base_factor = 10,  //legal value: 8,10
  parameter ser_words = 2,  //legal value 1,2,4
  parameter data_rate = "3125 Mbps",  //remove this later
  parameter base_data_rate = "3125 Mbps", // (PLL data rate)
  parameter reconfig_interfaces          = 1,
  
  // tx bitslip
  parameter tx_bitslip_enable = "false",
  
  //optional coreclks
  parameter tx_use_coreclk = "false",
  parameter rx_use_coreclk = "true",
  parameter en_synce_support  = 0,   //expose CDR ref-clk in this mode
  
  // 8B10B
  parameter use_8b10b = "false",  //legal value: "false", "true"
  parameter use_8b10b_manual_control = "false",
  
  //Word Aligner
  parameter word_aligner_mode = "sync_state_machine", //legal value: bitslip, sync_state_machine, manual
  parameter word_aligner_state_machine_datacnt = 1, //legal value: 0-256
  parameter word_aligner_state_machine_errcnt = 1,  //legal value: 0-256
  parameter word_aligner_state_machine_patterncnt = 10,  //legal value: 0-256
  parameter word_aligner_pattern_length = 10,
  parameter word_align_pattern = "0101111100",
  parameter run_length_violation_checking = 40, //legal value: 0,1+
  
  //RM FIFO
  parameter use_rate_match_fifo = 0,  //legal value: 0,1
  parameter rate_match_pattern1 = "11010000111010000011",
  parameter rate_match_pattern2 = "00101111000101111100",
  
  //Byte Ordering Block
  parameter byte_order_mode = "none", //legal value: None, sync_state_machine, PLD control
  parameter byte_order_pattern = "000000000",
  parameter byte_order_pad_pattern = "111111011",
  
  //Hidden parameter to enable 0ppm legality bypass
  parameter coreclk_0ppm_enable = "false",
  
  //PLL
  parameter pll_refclk_cnt    = 1,          // Number of reference clocks
  parameter pll_refclk_freq   = "156.25 MHz",  // Frequency of each reference clock
  parameter pll_refclk_select = "0",        // Selects the initial reference clock for each TX PLL
  parameter cdr_refclk_select = 0,          // Selects the initial reference clock for all RX CDR PLLs
  parameter plls              = 1,          // (1+)
  parameter pll_type          = "CMU",     // PLL type for each PLL
  parameter pll_select        = 0,          // Selects the initial PLL
  parameter pll_reconfig      = 0,          // (0,1) 0-Disable PLL reconfig, 1-Enable PLL reconfig
  parameter pll_external_enable = 0,        // (0,1) 0-Disable external TX PLL, 1-Enable external TX PLL
  
  // initially found in siv_xcvr_custom_phy
  // Analog Parameters
  parameter gxb_analog_power = "AUTO",  //legal value: AUTO,2.5V,3.0V,3.3V,3.9V
  parameter pll_lock_speed = "AUTO",
  parameter tx_analog_power = "AUTO", //legal value: AUTO,1.4V,1.5V
  parameter tx_slew_rate = "OFF",
  parameter tx_termination = "OCT_100_OHMS",  //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
  parameter tx_use_external_termination = "false", //legal value: true, false
  parameter tx_preemp_pretap = 0,
  parameter tx_preemp_pretap_inv = "FALSE",
  parameter tx_preemp_tap_1 = 0,
  parameter tx_preemp_tap_2 = 0,
  parameter tx_preemp_tap_2_inv = "FALSE",
  parameter tx_vod_selection = 2,
  parameter tx_common_mode = "0.65V", //legal value: 0.65V
  parameter rx_pll_lock_speed = "AUTO",
  parameter rx_common_mode = "0.82V", //legal value: "0.65V"
  parameter rx_termination = "OCT_100_OHMS",  //legal value: OCT_85_OHMS,OCT_100_OHMS,OCT_120_OHMS,OCT_150_OHMS
  parameter rx_use_external_termination = "false", //legal value: true, false
  parameter rx_eq_dc_gain = 1,
  parameter rx_eq_ctrl = 16,
    
  //Param siv_xcvr_custom_phy.mgmt_clk_in_mhz has default '50', but module-level default is '150'
  parameter mgmt_clk_in_mhz = 250,  //needed for reset controller timed delays
  parameter embedded_reset = 1,  // (0,1) 1-Enable embedded reset controller
  parameter channel_interface = 0, //legal value: (0,1) 1-Enable channel reconfiguration
  parameter starting_channel_number = 0,  //legal value: 0+em
  parameter rx_ppmselect = 32,
  parameter rx_signal_detect_threshold = 2,
  parameter rx_use_cruclk = "FALSE"
  
) (
  input  wire         pll_ref_clk,           //   refclk.clk
  input  wire         cdr_ref_clk,           // used only in SyncE mode
  input  wire         xgmii_tx_clk,          //   xgmii_tx_clk.clk
  output wire         xgmii_rx_clk,          //   xgmii_rx_clk.clk
  input  wire         phy_mgmt_clk,          //   mgmt_clk.clk
  input  wire         phy_mgmt_clk_reset,    //   mgmt_clk_rst.reset_n
  input  wire  [7:0]  phy_mgmt_address,      //   phy_mgmt.address
  output wire         phy_mgmt_waitrequest,  //   .waitrequest
  input  wire         phy_mgmt_read,         //   .read
  output wire [31:0]  phy_mgmt_readdata,     //   .readdata
  input  wire         phy_mgmt_write,        //   .write
  input  wire [31:0]  phy_mgmt_writedata,    //   .writedata
  input  wire [71:0]  xgmii_tx_dc,           //   xgmii_tx_dc.data
  output wire [71:0]  xgmii_rx_dc,           //   xgmii_rx_dc.data
  output wire [3:0]   xaui_tx_serial_data,   //   xaui_tx_serial.export
  input  wire [3:0]   xaui_rx_serial_data,   //   xaui_rx_serial.export
  output wire         rx_ready,              //   rx_pma_ready.data
  output wire         tx_ready,              //   tx_pma_ready.data
  output wire [3:0]   rx_recovered_clk,      //   rx recovered clock from cdr
// optional control and status ports
  input  wire         rx_digitalreset,
  input  wire         tx_digitalreset,
  output wire         rx_channelaligned,
  output wire [7:0]   rx_disperr,
  output wire [7:0]   rx_errdetect,
  output wire [7:0]   rx_syncstatus,
  output wire [229:0] reconfig_from_xcvr,
  input  wire [349:0] reconfig_to_xcvr

);

import altera_xcvr_functions::*;

  wire        alt_pma_controller_0_cal_blk_pdn_data;
  wire        alt_pma_controller_0_pll_pdn0_data;
  wire        pll_locked_data;
  wire  [7:0] rx_disperr_data;
  wire  [7:0] rx_errdetect_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_analog_rst_data;
  wire  [3:0] alt_pma_ch_controller_0_tx_digital_rst_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_digital_rst_data;
  wire        hxaui_csr_r_rx_digitalreset_data;
  wire        hxaui_csr_r_tx_digitalreset_data;
  wire        hxaui_csr_simulation_flag_data;
  wire        alt_pma_controller_0_pll_pdn;
  wire        alt_pma_0_tx_out_clk_clk;
  wire        alt_pma_0_tx_out_clk;
  wire  [3:0] alt_pma_0_rx_recovered_clk_clk;
  wire [79:0] sxaui_0_tx_parallel_data_data;
  wire [79:0] alt_pma_0_rx_parallel_data_data;
  wire  [3:0] alt_pma_0_rx_is_lockedtodata_data;
  wire        rx_pma_ready;
  wire        sxaui_rst_done;

  wire [5:0]  sc_pma_ch_controller_address;
  wire        sc_pma_ch_controller_read;
  wire [31:0] sc_pma_ch_controller_readdata;
  wire        sc_pma_ch_controller_waitrequest;
  wire        sc_pma_ch_controller_write;


  wire [1:0]  sc_pma_controller_address;
  wire        sc_pma_controller_read;
  wire [31:0] sc_pma_controller_readdata;
  wire        sc_pma_controller_waitrequest;
  wire        sc_pma_controller_write;

  wire [4:0]  sc_csr_address;
  wire        sc_csr_read;
  wire [31:0] sc_csr_readdata;
  wire        sc_csr_write;

// assign output wires for status ports - whether or not they are used will be decided by the top level
  assign rx_disperr                = rx_disperr_data;
  assign rx_errdetect              = rx_errdetect_data; 
  assign rx_recovered_clk          = alt_pma_0_rx_recovered_clk_clk;
  assign alt_pma_0_tx_out_clk_clk  = alt_pma_0_tx_out_clk;

  ///////////////////////////////////////////////////////////////////////
  // Decoder for multiple slaves of pma_ch_control,pma_control,hxaui i/f
  ///////////////////////////////////////////////////////////////////////
  alt_xcvr_mgmt2dec_xaui mgmtdec_xaui (
    .mgmt_clk_reset                   (phy_mgmt_clk_reset),
    .mgmt_clk                         (phy_mgmt_clk),
    .mgmt_address                     (phy_mgmt_address),
    .mgmt_read                        (phy_mgmt_read),
    .mgmt_write                       (phy_mgmt_write),
    .mgmt_readdata                    (phy_mgmt_readdata),
    .mgmt_waitrequest                 (phy_mgmt_waitrequest),

    // internal interface to 'top' pma ch controller block
    .sc_pma_ch_controller_readdata    (sc_pma_ch_controller_readdata),
    .sc_pma_ch_controller_waitrequest (sc_pma_ch_controller_waitrequest),
    .sc_pma_ch_controller_address     (sc_pma_ch_controller_address),  //6 bit wide
    .sc_pma_ch_controller_read        (sc_pma_ch_controller_read),
    .sc_pma_ch_controller_write       (sc_pma_ch_controller_write),

    // internal interface to 'top' pma controller block
    .sc_pma_controller_readdata       (sc_pma_controller_readdata),
    .sc_pma_controller_waitrequest    (sc_pma_controller_waitrequest),
    .sc_pma_controller_address        (sc_pma_controller_address), //2 bit wide
    .sc_pma_controller_read           (sc_pma_controller_read),
    .sc_pma_controller_write          (sc_pma_controller_write),
  
    // internal interface to 'top' hxaui csr block
    .sc_csr_readdata                  (sc_csr_readdata),
    .sc_csr_waitrequest               (1'b0), // PCS CSR is always ready
    .sc_csr_address                   (sc_csr_address),    //5 bit wide
    .sc_csr_read                      (sc_csr_read),
    .sc_csr_write                     (sc_csr_write)
  );

  ///////////////////////////////////////////////////////////////////////
  // ALT_PMA 
  ///////////////////////////////////////////////////////////////////////
  generate
    if (interface_type == "Soft XAUI") begin
 (* ALTERA_ATTRIBUTE = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*av_xcvr_xaui*hxaui_csr*hxaui_csr_reset0q[1]}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*pll_inreset*]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*av_xcvr_xaui*hxaui_csr*hxaui_csr_reset0q[1]}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*tx_reset*]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sxaui_0*alt_soft_xaui_pcs*xaui_rx*disp_err_delay[*]}] -to  [get_registers *xaui_phy*hxaui_csr*rx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sxaui_0*alt_soft_xaui_pcs*xaui_rx*pcs_rx_syncstatus[*]}] -to  [get_registers *xaui_phy*hxaui_csr*rx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sxaui_0*alt_soft_xaui_pcs*xaui_rx*channel_align_synchclk[*]}] -to  [get_registers *xaui_phy*hxaui_csr*rx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*av_xcvr_xaui*hxaui_csr*hxaui_csr_reset0q[1]}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*rx_reset*]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*av_xcvr_xaui*hxaui_csr*hxaui_csr_simulation_flag0q}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*pcs_reset*simulation_flag_f]\""} *)
     av_xcvr_low_latency_phy_nr #(
	    .device_family(device_family),
		.protocol_hint(protocol_hint),
		.lanes(lanes),
		.pma_bonding_mode(pma_bonding_mode),
		.pcs_pma_width(pcs_pma_width),
		.ser_base_factor(ser_base_factor),
		.ser_words(ser_words),
		.mgmt_clk_in_mhz(mgmt_clk_in_mhz),
		.data_rate(data_rate),
		.base_data_rate(base_data_rate),
	        .en_synce_support(en_synce_support), //expose CDR ref-clk in this mode
		.plls(plls),
		.pll_type(pll_type),
		.pll_select(pll_select),
		.pll_reconfig(pll_reconfig),
		.pll_refclk_cnt(pll_refclk_cnt),
		.pll_refclk_freq(pll_refclk_freq),
		.pll_refclk_select(pll_refclk_select),
		.cdr_refclk_select(cdr_refclk_select),
		.operation_mode(operation_mode),
		.starting_channel_number(starting_channel_number),
		.bonded_group_size(bonded_group_size),
		.embedded_reset(embedded_reset),
		.channel_interface(channel_interface),
		.use_8b10b(use_8b10b),
		.use_8b10b_manual_control(use_8b10b_manual_control),
		.tx_use_coreclk(tx_use_coreclk),
		.rx_use_coreclk(rx_use_coreclk),
		.tx_bitslip_enable(tx_bitslip_enable),
		.word_aligner_mode(word_aligner_mode),
		.word_aligner_state_machine_datacnt(word_aligner_state_machine_datacnt),
		.word_aligner_state_machine_errcnt(word_aligner_state_machine_errcnt),
		.word_aligner_state_machine_patterncnt(word_aligner_state_machine_patterncnt),
		.run_length_violation_checking(run_length_violation_checking),
		.word_align_pattern(word_align_pattern),
		.word_aligner_pattern_length(word_aligner_pattern_length),
		.use_rate_match_fifo(use_rate_match_fifo),
		.rate_match_pattern1(rate_match_pattern1),
		.rate_match_pattern2(rate_match_pattern2),
		.byte_order_mode(byte_order_mode),
		.byte_order_pattern(byte_order_pattern),
		.byte_order_pad_pattern(byte_order_pad_pattern),
		.coreclk_0ppm_enable(coreclk_0ppm_enable)
      ) alt_pma_0 (
        .mgmt_clk                 (phy_mgmt_clk),
        .mgmt_clk_reset           (phy_mgmt_clk_reset),
        .mgmt_address             (8'h40 | sc_pma_ch_controller_address),
        .mgmt_read                (sc_pma_ch_controller_read),
        .mgmt_readdata            (sc_pma_ch_controller_readdata),
        .mgmt_write               (sc_pma_ch_controller_write),
        .mgmt_writedata           (phy_mgmt_writedata),
        .mgmt_waitrequest         (sc_pma_ch_controller_waitrequest),
        .rx_ready                 (rx_ready),
        .tx_ready                 (tx_ready),
        .pll_locked               (pll_locked_data),
        .rx_coreclk               ({4{alt_pma_0_rx_recovered_clk_clk[2]}}),
        .pll_ref_clk              (pll_ref_clk),
	.cdr_ref_clk                 (cdr_ref_clk), // used only in SyncE mode
        .tx_coreclk               (4'b0),
        //.rx_coreclk               (), //edit here
        .tx_parallel_data         (sxaui_0_tx_parallel_data_data),
        .tx_serial_data           (xaui_tx_serial_data),
        .tx_clkout                (alt_pma_0_tx_out_clk),
        .tx_bitslip               (28'b0),
        .rx_serial_data           (xaui_rx_serial_data),
        .rx_parallel_data         (alt_pma_0_rx_parallel_data_data),
        .rx_clkout                (alt_pma_0_rx_recovered_clk_clk),
        .rx_bitslip               (4'b0),
		.rx_syncstatus            (rx_syncstatus), 
        .rx_is_lockedtodata       (alt_pma_0_rx_is_lockedtodata_data),
        .rx_is_lockedtoref        (),
        .reconfig_to_xcvr         (reconfig_to_xcvr),
        .reconfig_from_xcvr       (reconfig_from_xcvr),
        .tx_digital_rst           (alt_pma_ch_controller_0_tx_digital_rst_data),
        .rx_digital_rst           (alt_pma_ch_controller_0_rx_digital_rst_data)
      );
      

    end else begin
      assign rx_pma_ready = 1'b0;
      assign tx_ready = 1'b0;
      assign sxaui_rst_done = 1'b0; // no hard xaui support
    end
  endgenerate

  ///////////////////////////////////////////////////////////////////////
  // PMA Controller
  ///////////////////////////////////////////////////////////////////////
    alt_pma_controller_tgx #(
      .number_of_plls         (1),
      .sync_depth             (2),
      .tx_pll_reset_hold_time (20)
    ) alt_pma_controller_0 (
      .clk                  (phy_mgmt_clk),                          
      .rst                  (phy_mgmt_clk_reset),                        
      .pma_mgmt_address     (sc_pma_controller_address),   
      .pma_mgmt_read        (sc_pma_controller_read),   
      .pma_mgmt_readdata    (sc_pma_controller_readdata),   
      .pma_mgmt_write       (sc_pma_controller_write),   
      .pma_mgmt_writedata   (phy_mgmt_writedata),     
      .pma_mgmt_waitrequest (sc_pma_controller_waitrequest),   
      .cal_blk_clk          (phy_mgmt_clk),                    
      .cal_blk_pdn          (alt_pma_controller_0_cal_blk_pdn_data),
      .tx_pll_ready         (),                                     
      .gx_pdn               (),     
      .pll_pdn              (alt_pma_controller_0_pll_pdn0_data),
      .pll_locked           (pll_locked_data)                  
    );

  ///////////////////////////////////////////////////////////////////////
  // HXAUI CSR
  ///////////////////////////////////////////////////////////////////////
  hxaui_csr hxaui_csr (
    .clk                      (phy_mgmt_clk),
    .reset                    (phy_mgmt_clk_reset),
    .address                  (sc_csr_address),
    .byteenable               (4'b1111),   // .byteenable (Tie byteenable to all 1s)
    .read                     (sc_csr_read),
    .readdata                 (sc_csr_readdata),
    .write                    (sc_csr_write),
    .writedata                (phy_mgmt_writedata),
    .rx_patterndetect         (8'b0), // not supported by soft PCS
    .rx_syncstatus            (rx_syncstatus),
    .rx_runningdisp           (8'b0), // not supported by soft PCS
    .rx_errdetect             (rx_errdetect_data),
    .rx_disperr               (rx_disperr_data),
    .rx_phase_comp_fifo_error (4'b0), // not supported by soft PCS
    .rx_rlv                   (4'b0), // not supported by soft PCS
    .rx_rmfifodatadeleted     (8'b0), // not supported by soft PCS
    .rx_rmfifodatainserted    (8'b0), // not supported by soft PCS
    .rx_rmfifoempty           (4'b0), // not supported by soft PCS
    .rx_rmfifofull            (4'b0), // not supported by soft PCS
    .tx_phase_comp_fifo_error (4'b0), // not supported by soft PCS
    .r_rx_invpolarity         (),     // not supported by soft PCS
    .r_tx_invpolarity         (),     // not supported by soft PCS
    .r_rx_digitalreset        (hxaui_csr_r_rx_digitalreset_data),
    .r_tx_digitalreset        (hxaui_csr_r_tx_digitalreset_data),
    .simulation_flag          (hxaui_csr_simulation_flag_data) // only for soft_xaui
  );


  ///////////////////////////////////////////////////////////////////////
  // SXAUI - Interface to soft PCS 
  ///////////////////////////////////////////////////////////////////////

  generate
    if (interface_type == "Soft XAUI" && soft_pcs_legacy_new_n) begin
      sxaui #(
        .starting_channel_number      (0),
        .xaui_pll_type                (xaui_pll_type),
        .use_control_and_status_ports (use_control_and_status_ports),
		.soft_pcs_legacy_new_n (soft_pcs_legacy_new_n)
      ) sxaui_0 (
        .xgmii_tx_clk       (xgmii_tx_clk),                      // xgmii_tx_clk.clk
        .xgmii_tx_dc        (xgmii_tx_dc),                       // xgmii_tx_dc.data
        .xgmii_rx_clk       (xgmii_rx_clk),                      // xgmii_rx_clk.clk
        .xgmii_rx_dc        (xgmii_rx_dc),                       // xgmii_rx_dc.data
        .refclk             (pll_ref_clk),                       // refclk.clk
        .mgmt_clk           (phy_mgmt_clk),                      // mgmt_clk.clk
        .tx_out_clk         (alt_pma_0_tx_out_clk_clk),          // tx_out_clk.clk
        .rx_recovered_clk   (alt_pma_0_rx_recovered_clk_clk[2]),    // rx_recovered_clk.clk
        .tx_parallel_data   (sxaui_0_tx_parallel_data_data),     // tx_parallel_data.data
        .rx_parallel_data   (alt_pma_0_rx_parallel_data_data),   // rx_parallel_data.data
        .rx_is_lockedtodata (alt_pma_0_rx_is_lockedtodata_data), // rx_is_lockedtodata.data
        .rx_digitalreset    (alt_pma_ch_controller_0_rx_digital_rst_data[0] ),                   // rx_digitalreset.from alt_pma
        .tx_digitalreset    (alt_pma_ch_controller_0_tx_digital_rst_data[0] ),                   // tx_digitalreset.from alt_pma
        .pll_locked         (pll_locked_data),                   // pll_locked.data
        .rx_syncstatus      (rx_syncstatus),                // rx_syncstatus.data
        .rx_channelaligned  (rx_channelaligned),                 // rx_channelaligned.data
        .rx_disperr         (rx_disperr_data),                   // rx_disperr.data
        .rx_errdetect       (rx_errdetect_data),                 // rx_errdetect.data
        .r_rx_digitalreset  (hxaui_csr_r_rx_digitalreset_data),  // r_rx_digitalreset.data
        .r_tx_digitalreset  (hxaui_csr_r_tx_digitalreset_data),  // r_tx_digitalreset.data
        .pma_stat_rst_done  (sxaui_rst_done),                    // soft reset done
        .simulation_flag    (hxaui_csr_simulation_flag_data)     // simulation_flag.data
      );
    end
    else if (interface_type == "Soft XAUI" && !soft_pcs_legacy_new_n ) begin
      sxaui #(
        .starting_channel_number      (0),
        .xaui_pll_type                (xaui_pll_type),
        .use_control_and_status_ports (use_control_and_status_ports),
		.soft_pcs_legacy_new_n (soft_pcs_legacy_new_n)
      ) sxaui_0 (
        .xgmii_tx_clk       (xgmii_tx_clk),                      // xgmii_tx_clk.clk
        .xgmii_tx_dc        (xgmii_tx_dc),                       // xgmii_tx_dc.data
        .xgmii_rx_clk       (xgmii_rx_clk),                      // xgmii_rx_clk.clk
        .xgmii_rx_dc        (xgmii_rx_dc),                       // xgmii_rx_dc.data
        .refclk             (pll_ref_clk),                       // refclk.clk
        .mgmt_clk           (phy_mgmt_clk),                      // mgmt_clk.clk
        .tx_out_clk         (alt_pma_0_tx_out_clk_clk),          // tx_out_clk.clk
        .rx_recovered_clk   (alt_pma_0_rx_recovered_clk_clk[2]),    // rx_recovered_clk.clk
        .tx_parallel_data   (sxaui_0_tx_parallel_data_data),     // tx_parallel_data.data
        .rx_parallel_data   (alt_pma_0_rx_parallel_data_data),   // rx_parallel_data.data
        .rx_is_lockedtodata (alt_pma_0_rx_is_lockedtodata_data), // rx_is_lockedtodata.data
        .rx_digitalreset    (alt_pma_ch_controller_0_rx_digital_rst_data[0] ),                   // rx_digitalreset.from alt_pma
        .tx_digitalreset    (alt_pma_ch_controller_0_tx_digital_rst_data[0] ),                   // tx_digitalreset.from alt_pma
        .pll_locked         (pll_locked_data),                   // pll_locked.data
        .hard_pcs_rx_syncstatus (rx_syncstatus),                // rx_syncstatus.data
        .rx_channelaligned  (rx_channelaligned),                 // rx_channelaligned.data
        .rx_disperr         (rx_disperr_data),                   // rx_disperr.data
        .rx_errdetect       (rx_errdetect_data),                 // rx_errdetect.data
        .r_rx_digitalreset  (hxaui_csr_r_rx_digitalreset_data),  // r_rx_digitalreset.data
        .r_tx_digitalreset  (hxaui_csr_r_tx_digitalreset_data),  // r_tx_digitalreset.data
        .pma_stat_rst_done  (sxaui_rst_done),                    // soft reset done
        .simulation_flag    (hxaui_csr_simulation_flag_data)     // simulation_flag.data
      );
    end
  endgenerate

endmodule
