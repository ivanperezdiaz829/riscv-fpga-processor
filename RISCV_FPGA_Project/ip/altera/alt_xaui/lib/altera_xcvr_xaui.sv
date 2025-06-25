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
// Description: alt_xaui static verilog top level 
//
// Authors:     bauyeung 7-Sep-2010
// Modified:    ishimony 13-Dec-2010
// Modified:    hhleong 11-May-2012
//
//              Copyright (c) Altera Corporation 1997 - 2012
//              All rights reserved.
//
// 
//-----------------------------------------------------------------------------

// have separate generate statements for each component

`timescale 1 ps / 1 ps
import altera_xcvr_functions::*;

module altera_xcvr_xaui #(
  parameter device_family                = "Stratix IV", // default Stratix IV
  parameter starting_channel_number      = 0, // only applies to SIV
  parameter interface_type               = "Hard XAUI",
  parameter data_rate                    = "3125 Mbps", 
  parameter xaui_pll_type                = "CMU",
  parameter BASE_DATA_RATE               = "3125 Mbps",
  parameter en_synce_support             = 0,   //expose CDR ref-clk in this mode
  parameter use_control_and_status_ports = 0,
  parameter external_pma_ctrl_reconf     = 0,
  parameter recovered_clk_out            = 0,
  parameter number_of_interfaces         = 1,
  parameter reconfig_interfaces         = 1,
  parameter use_rx_rate_match            = 0,
  parameter tx_termination               = "OCT_150_OHMS",
  parameter tx_vod_selection             = 2,
  parameter tx_preemp_pretap             = 0,
  parameter tx_preemp_pretap_inv         = "false",
  parameter tx_preemp_tap_1              = 0,
  parameter tx_preemp_tap_2              = 0,
  parameter tx_preemp_tap_2_inv          = "false",
  parameter rx_common_mode               = "0.82v",
  parameter rx_termination               = "OCT_150_OHMS",
  parameter rx_eq_dc_gain                = 1,
  parameter rx_eq_ctrl                   = 16,
  parameter mgmt_clk_in_mhz              = 250
) (
  input  wire        pll_ref_clk,
  input  wire        cdr_ref_clk,           // used only in SyncE mode
  input  wire        xgmii_tx_clk,
  output wire        xgmii_rx_clk,
  output wire        tx_clk312_5,     //   dxaui: pma tx out clock, 312.5Mhz
  input  wire        phy_mgmt_clk,
  input  wire        phy_mgmt_clk_reset,
  input  wire  [8:0] phy_mgmt_address,
  output wire        phy_mgmt_waitrequest,
  input  wire        phy_mgmt_read,
  output wire [31:0] phy_mgmt_readdata,
  input  wire        phy_mgmt_write,
  input  wire [31:0] phy_mgmt_writedata,
  input  wire [71:0] xgmii_tx_dc,
  output wire [71:0] xgmii_rx_dc,
  output wire [3:0]  xaui_tx_serial_data,
  input  wire [3:0]  xaui_rx_serial_data,
  output wire        rx_ready,
  output wire        tx_ready,
  output wire [3:0]  rx_recovered_clk,      //   rx recovered clock from cdr

// only used if use_control_and_status_ports is set
  input  tri0        rx_analogreset,
  input  tri0        rx_digitalreset,
  input  tri0        tx_digitalreset,
  output tri0        rx_channelaligned,
  input  tri0 [3:0]  rx_invpolarity,
  input  tri0 [3:0]  rx_set_locktodata,
  input  tri0 [3:0]  rx_set_locktoref,
  input  tri0 [3:0]  rx_seriallpbken,
  input  tri0 [3:0]  tx_invpolarity,
  output tri0 [3:0]  rx_is_lockedtodata,
  output tri0 [3:0]  rx_phase_comp_fifo_error,
  output tri0 [3:0]  rx_is_lockedtoref,
  output tri0 [3:0]  rx_rlv,
  output tri0 [3:0]  rx_rmfifoempty,
  output tri0 [3:0]  rx_rmfifofull,
  output tri0 [3:0]  tx_phase_comp_fifo_error,
  output tri0 [7:0]  rx_disperr,
  output tri0 [7:0]  rx_errdetect,
  output tri0 [7:0]  rx_patterndetect,
  output tri0 [7:0]  rx_rmfifodatadeleted,
  output tri0 [7:0]  rx_rmfifodatainserted,
  output tri0 [7:0]  rx_runningdisp,
  output tri0 [7:0]  rx_syncstatus,


// only used if external_pma_ctrl_reconf is set
  output tri0 [altera_xcvr_functions::get_reconfig_from_width(device_family,reconfig_interfaces)-1:0] reconfig_from_xcvr,
  input  tri0 [altera_xcvr_functions::get_reconfig_to_width(device_family,reconfig_interfaces)  -1:0] reconfig_to_xcvr,
  output tri0        pll_locked,
  input  tri0        cal_blk_powerdown,
  input  tri0        gxb_powerdown,
  input  tri0        pll_powerdown
// need to add all possible port/param combinations
// these should be set to tri0/1 where possible, so unused ports don't need to be terminated by the user
);

import altera_xcvr_functions::*;

localparam reconfig_out_width = altera_xcvr_functions::get_reconfig_from_width(device_family,reconfig_interfaces);
localparam reconfig_in_width = altera_xcvr_functions::get_reconfig_to_width(device_family,reconfig_interfaces);

  wire [reconfig_out_width -1:0]  l_reconfig_from_xcvr; // local reconfig_from_xcvr
  wire [reconfig_in_width  -1:0]   l_reconfig_to_xcvr;   // local reconfig_to_xcvr
  
  wire  [7:0]  sc_phy_address;      //   mgmt.address
  wire         sc_phy_waitrequest;  //   .waitrequest
  wire         sc_phy_read;         //   .read
  wire [31:0]  sc_phy_readdata;     //   .readdata
  wire         sc_phy_write;        //   .write
 
  wire  [6:0]  sc_reconf_address;      //   mgmt.address
  wire         sc_reconf_waitrequest;  //   .waitrequest
  wire         sc_reconf_read;         //   .read
  wire [31:0]  sc_reconf_readdata;     //   .readdata
  wire         sc_reconf_write;        //   .write
  
///////////////////////////////////////////////////////////////////////
// Custom decoder for multiple slaves of phy-reconfig interface
///////////////////////////////////////////////////////////////////////
// should be consistent across all device families
  alt_xcvr_mgmt2dec_phyreconfig mgmtdec_phyreconfig (
    .mgmt_clk_reset         (phy_mgmt_clk_reset),
    .mgmt_clk               (phy_mgmt_clk),
    
    .mgmt_address           (phy_mgmt_address),
    .mgmt_read              (phy_mgmt_read),
    .mgmt_write             (phy_mgmt_write),
    .mgmt_readdata          (phy_mgmt_readdata),
    .mgmt_waitrequest       (phy_mgmt_waitrequest),
    
    // internal interface to 'top' phy block
    .sc_phy_readdata        (sc_phy_readdata),
    .sc_phy_waitrequest     (sc_phy_waitrequest),
    .sc_phy_address         (sc_phy_address),
    .sc_phy_read            (sc_phy_read),
    .sc_phy_write           (sc_phy_write),
    
    // internal interface to 'top' reconfig block
    .sc_reconf_readdata     (sc_reconf_readdata),
    .sc_reconf_waitrequest  (sc_reconf_waitrequest),
    .sc_reconf_address      (sc_reconf_address),
    .sc_reconf_read         (sc_reconf_read),
    .sc_reconf_write        (sc_reconf_write)
  );


///////////////////////////////////////////////////////////////////////
// alt_xcvr_reconfig
///////////////////////////////////////////////////////////////////////
// add generate statement for this
// need to account for external pma reconfig 
  generate
    if (external_pma_ctrl_reconf == 1) begin
      assign l_reconfig_to_xcvr     = reconfig_to_xcvr; 
      assign reconfig_from_xcvr     = l_reconfig_from_xcvr; 
      assign sc_reconf_readdata     = 32'd0;
      assign sc_reconf_waitrequest  = 1'b0;
    end else if ((interface_type == "Hard XAUI") &&  ((device_family == "Stratix IV") || (device_family == "HardCopy IV") || (device_family == "Arria II GX") || (device_family == "Arria II GX") || (device_family == "Arria II GZ"))) begin
        alt_xcvr_reconfig_siv #(
          .number_of_reconfig_interfaces (1)
        ) alt_xcvr_reconfig_0 (
          .mgmt_clk_clk              (phy_mgmt_clk),                    
          .mgmt_rst_reset            (phy_mgmt_clk_reset),
          .reconfig_mgmt_address     (sc_reconf_address),
          .reconfig_mgmt_waitrequest (sc_reconf_waitrequest),
          .reconfig_mgmt_read        (sc_reconf_read),
          .reconfig_mgmt_readdata    (sc_reconf_readdata),
          .reconfig_mgmt_write       (sc_reconf_write),
          .reconfig_mgmt_writedata   (phy_mgmt_writedata),
          .reconfig_togxb            (l_reconfig_to_xcvr),
          .reconfig_fromgxb          (l_reconfig_from_xcvr[16:0])
        );
    end else if ((interface_type == "Soft XAUI") &&  ((device_family == "Stratix IV") || (device_family == "HardCopy IV"))) begin // Arria II GX/GZ don't support soft xaui
        alt_xcvr_reconfig_siv #(
          .number_of_reconfig_interfaces (4)
        ) alt_xcvr_reconfig_0 (
          .mgmt_clk_clk              (phy_mgmt_clk),
          .mgmt_rst_reset            (phy_mgmt_clk_reset),
          .reconfig_mgmt_address     (sc_reconf_address),
          .reconfig_mgmt_waitrequest (sc_reconf_waitrequest),
          .reconfig_mgmt_read        (sc_reconf_read),
          .reconfig_mgmt_readdata    (sc_reconf_readdata),
          .reconfig_mgmt_write       (sc_reconf_write),
          .reconfig_mgmt_writedata   (phy_mgmt_writedata),
          .reconfig_togxb            (l_reconfig_to_xcvr),
          .reconfig_fromgxb          (l_reconfig_from_xcvr)
        );
    end else if ((interface_type == "DDR XAUI") &&  (device_family == "Stratix IV")) begin
    // stub for now - nothing here
    end else if ((device_family == "Stratix V") || (device_family == "Arria V GZ")) begin
    // stub for now - nothing here
      assign l_reconfig_to_xcvr = reconfig_to_xcvr; 
      assign reconfig_from_xcvr = l_reconfig_from_xcvr; 
      assign sc_reconf_readdata     = 32'd0;
      assign sc_reconf_waitrequest  = 1'b0;
    end else if (device_family == "Cyclone IV GX") begin
      alt_xcvr_reconfig_civ #(
        .number_of_reconfig_interfaces (1)
      ) alt_xcvr_reconfig_0 (
        .reconfig_mgmt_clk_clk     (phy_mgmt_clk),                    
        .reconfig_mgmt_rst_reset   (phy_mgmt_clk_reset),
        .reconfig_mgmt_address     (sc_reconf_address),
        .reconfig_mgmt_waitrequest (sc_reconf_waitrequest),
        .reconfig_mgmt_read        (sc_reconf_read),
        .reconfig_mgmt_readdata    (sc_reconf_readdata),
        .reconfig_mgmt_write       (sc_reconf_write),
        .reconfig_mgmt_writedata   (phy_mgmt_writedata),
        .reconfig_togxb            (l_reconfig_to_xcvr),
        .reconfig_fromgxb          (l_reconfig_from_xcvr[16:0])
      );
    end
  endgenerate

///////////////////////////////////////////////////////////////////////
// alt_xaui_phy - Integrates hxaui (i/f to hxaui_alt_c3gxb), csr, pma
// controller and pma channel controller
///////////////////////////////////////////////////////////////////////
  generate
    if ((device_family == "Stratix V") || (device_family == "Arria V GZ")) begin
      sv_xcvr_xaui #(
       .device_family                (device_family),
        .starting_channel_number      (starting_channel_number),
        .interface_type               (interface_type),
        .reconfig_interfaces          (reconfig_interfaces),
        .sys_clk_in_mhz               (mgmt_clk_in_mhz),
	.data_rate                    (data_rate),
        .xaui_pll_type                (xaui_pll_type),
	.BASE_DATA_RATE               (BASE_DATA_RATE),
	.en_synce_support             (en_synce_support), //expose CDR ref-clk in this mode
        .use_control_and_status_ports (use_control_and_status_ports),
        .tx_termination               (tx_termination),
        .rx_termination               (rx_termination),
        .tx_preemp_pretap             (tx_preemp_pretap),
        .tx_preemp_pretap_inv         (tx_preemp_pretap_inv),
        .tx_preemp_tap_1              (tx_preemp_tap_1),
        .tx_preemp_tap_2              (tx_preemp_tap_2),
        .tx_preemp_tap_2_inv          (tx_preemp_tap_2_inv),
        .tx_vod_selection             (tx_vod_selection),
        .rx_eq_dc_gain                (rx_eq_dc_gain),
        .rx_eq_ctrl                   (rx_eq_ctrl),
        .rx_common_mode               (rx_common_mode),
        .bonded_group_size            (4), /// allowed values 1=> non-bonded 4=> bonded
        .bonded_mode                  ("xN")  /// allowed values "xN" and "fb_compensation"
      ) alt_xaui_phy (
        .pll_ref_clk                  (pll_ref_clk),          //  refclk.clk
	.cdr_ref_clk                 (cdr_ref_clk), // used only in SyncE mode
        .xgmii_tx_clk                 (xgmii_tx_clk),         //  xgmii_tx_clk.clk
        .xgmii_rx_clk                 (xgmii_rx_clk),         //  xgmii_rx_clk.clk
        .phy_mgmt_clk                 (phy_mgmt_clk),         //  mgmt_clk.clk
        .phy_mgmt_clk_reset           (phy_mgmt_clk_reset),   //  mgmt_clk_rst.reset_n
        .phy_mgmt_address             (sc_phy_address),     //  phy_mgmt.address
        .phy_mgmt_waitrequest         (sc_phy_waitrequest), //  .waitrequest
        .phy_mgmt_read                (sc_phy_read),        //  .read
        .phy_mgmt_readdata            (sc_phy_readdata),    //  .readdata
        .phy_mgmt_write               (sc_phy_write),       //  .write
        .phy_mgmt_writedata           (phy_mgmt_writedata),   //  .writedata
        .xgmii_tx_dc                  (xgmii_tx_dc),          //  xgmii_tx_dc.data
        .xgmii_rx_dc                  (xgmii_rx_dc),          //  xgmii_rx_dc.data
        .xaui_tx_serial_data          (xaui_tx_serial_data),  //  xaui_tx_serial.export
        .xaui_rx_serial_data          (xaui_rx_serial_data),  //  xaui_rx_serial.export
        .rx_digitalreset              (rx_digitalreset),      //  rx_digitalreset.data
        .tx_digitalreset              (tx_digitalreset),      //  tx_digitalreset.data
        .rx_channelaligned            (rx_channelaligned),    //  rx_channelaligned.data
        .rx_syncstatus                (rx_syncstatus),        //  rx_syncstatus.data
        .rx_disperr                   (rx_disperr),           //  rx_disperr.data
        .rx_errdetect                 (rx_errdetect),         //  rx_errdetect.data
        .rx_ready                     (rx_ready),             //  rx_pma_ready.data
        .tx_ready                     (tx_ready),             //  tx_pma_ready.data
        .reconfig_to_xcvr               (l_reconfig_to_xcvr),
        .reconfig_from_xcvr             (l_reconfig_from_xcvr),
        .rx_recovered_clk             (rx_recovered_clk)
      );
    assign tx_clk312_5 = 1'b0 ;
    end else if (device_family == "Arria V") begin
      av_xcvr_xaui #(
        .device_family                (device_family),
        .starting_channel_number      (starting_channel_number),
        .interface_type               (interface_type),
        .reconfig_interfaces          (reconfig_interfaces),
        .mgmt_clk_in_mhz              (mgmt_clk_in_mhz),
	.data_rate                    (data_rate),
        .xaui_pll_type                (xaui_pll_type),
      //.base_data_rate               ("3125 Mbps"),
	.en_synce_support             (en_synce_support), //expose CDR ref-clk in this mode
        .use_control_and_status_ports (use_control_and_status_ports),
        .tx_termination               (tx_termination),
        .rx_termination               (rx_termination),
        .tx_preemp_pretap             (tx_preemp_pretap),
        .tx_preemp_pretap_inv         (tx_preemp_pretap_inv),
        .tx_preemp_tap_1              (tx_preemp_tap_1),
        .tx_preemp_tap_2              (tx_preemp_tap_2),
        .tx_preemp_tap_2_inv          (tx_preemp_tap_2_inv),
        .tx_vod_selection             (tx_vod_selection),
        .rx_eq_dc_gain                (rx_eq_dc_gain),
        .rx_eq_ctrl                   (rx_eq_ctrl),
        .rx_common_mode               (rx_common_mode),
        .bonded_group_size            (4), /// allowed values 1=> non-bonded 4=> bonded
        .bonded_mode                  ("xN")  /// allowed values "xN" and "fb_compensation"
      ) alt_xaui_phy (
        .pll_ref_clk                  (pll_ref_clk),          //  refclk.clk
	.cdr_ref_clk                 (cdr_ref_clk), // used only in SyncE mode
        .xgmii_tx_clk                 (xgmii_tx_clk),         //  xgmii_tx_clk.clk
        .xgmii_rx_clk                 (xgmii_rx_clk),         //  xgmii_rx_clk.clk
        .phy_mgmt_clk                 (phy_mgmt_clk),         //  mgmt_clk.clk
        .phy_mgmt_clk_reset           (phy_mgmt_clk_reset),   //  mgmt_clk_rst.reset_n
        .phy_mgmt_address             (sc_phy_address),     //  phy_mgmt.address
        .phy_mgmt_waitrequest         (sc_phy_waitrequest), //  .waitrequest
        .phy_mgmt_read                (sc_phy_read),        //  .read
        .phy_mgmt_readdata            (sc_phy_readdata),    //  .readdata
        .phy_mgmt_write               (sc_phy_write),       //  .write
        .phy_mgmt_writedata           (phy_mgmt_writedata),   //  .writedata
        .xgmii_tx_dc                  (xgmii_tx_dc),          //  xgmii_tx_dc.data
        .xgmii_rx_dc                  (xgmii_rx_dc),          //  xgmii_rx_dc.data
        .xaui_tx_serial_data          (xaui_tx_serial_data),  //  xaui_tx_serial.export
        .xaui_rx_serial_data          (xaui_rx_serial_data),  //  xaui_rx_serial.export
        .rx_digitalreset              (rx_digitalreset),      //  rx_digitalreset.data
        .tx_digitalreset              (tx_digitalreset),      //  tx_digitalreset.data
        .rx_channelaligned            (rx_channelaligned),    //  rx_channelaligned.data
        .rx_syncstatus                (rx_syncstatus),        //  rx_syncstatus.data
        .rx_disperr                   (rx_disperr),           //  rx_disperr.data
        .rx_errdetect                 (rx_errdetect),         //  rx_errdetect.data
        .rx_ready                     (rx_ready),             //  rx_pma_ready.data
        .tx_ready                     (tx_ready),             //  tx_pma_ready.data
        .reconfig_to_xcvr             (reconfig_to_xcvr),
        .reconfig_from_xcvr           (reconfig_from_xcvr),
        .rx_recovered_clk             (rx_recovered_clk)
      );
    assign tx_clk312_5 = 1'b0 ;
	end else if (device_family == "Cyclone V") begin
      cv_xcvr_xaui #(
        .device_family                (device_family),
        .starting_channel_number      (starting_channel_number),
        .interface_type               (interface_type),
        .reconfig_interfaces          (reconfig_interfaces),
        .mgmt_clk_in_mhz              (mgmt_clk_in_mhz),
	.data_rate                    (data_rate),
        .xaui_pll_type                (xaui_pll_type),
      //.base_data_rate               ("3125 Mbps"),
	.en_synce_support             (en_synce_support), //expose CDR ref-clk in this mode
        .use_control_and_status_ports (use_control_and_status_ports),
        .tx_termination               (tx_termination),
        .rx_termination               (rx_termination),
        .tx_preemp_pretap             (tx_preemp_pretap),
        .tx_preemp_pretap_inv         (tx_preemp_pretap_inv),
        .tx_preemp_tap_1              (tx_preemp_tap_1),
        .tx_preemp_tap_2              (tx_preemp_tap_2),
        .tx_preemp_tap_2_inv          (tx_preemp_tap_2_inv),
        .tx_vod_selection             (tx_vod_selection),
        .rx_eq_dc_gain                (rx_eq_dc_gain),
        .rx_eq_ctrl                   (rx_eq_ctrl),
        .rx_common_mode               (rx_common_mode),
        .bonded_group_size            (4), /// allowed values 1=> non-bonded 4=> bonded
        .bonded_mode                  ("xN")  /// allowed values "xN" and "fb_compensation"
      ) alt_xaui_phy (
        .pll_ref_clk                  (pll_ref_clk),          //  refclk.clk
	.cdr_ref_clk                  (cdr_ref_clk), // used only in SyncE mode
        .xgmii_tx_clk                 (xgmii_tx_clk),         //  xgmii_tx_clk.clk
        .xgmii_rx_clk                 (xgmii_rx_clk),         //  xgmii_rx_clk.clk
        .phy_mgmt_clk                 (phy_mgmt_clk),         //  mgmt_clk.clk
        .phy_mgmt_clk_reset           (phy_mgmt_clk_reset),   //  mgmt_clk_rst.reset_n
        .phy_mgmt_address             (sc_phy_address),     //  phy_mgmt.address
        .phy_mgmt_waitrequest         (sc_phy_waitrequest), //  .waitrequest
        .phy_mgmt_read                (sc_phy_read),        //  .read
        .phy_mgmt_readdata            (sc_phy_readdata),    //  .readdata
        .phy_mgmt_write               (sc_phy_write),       //  .write
        .phy_mgmt_writedata           (phy_mgmt_writedata),   //  .writedata
        .xgmii_tx_dc                  (xgmii_tx_dc),          //  xgmii_tx_dc.data
        .xgmii_rx_dc                  (xgmii_rx_dc),          //  xgmii_rx_dc.data
        .xaui_tx_serial_data          (xaui_tx_serial_data),  //  xaui_tx_serial.export
        .xaui_rx_serial_data          (xaui_rx_serial_data),  //  xaui_rx_serial.export
        .rx_digitalreset              (rx_digitalreset),      //  rx_digitalreset.data
        .tx_digitalreset              (tx_digitalreset),      //  tx_digitalreset.data
        .rx_channelaligned            (rx_channelaligned),    //  rx_channelaligned.data
        .rx_syncstatus                (rx_syncstatus),        //  rx_syncstatus.data
        .rx_disperr                   (rx_disperr),           //  rx_disperr.data
        .rx_errdetect                 (rx_errdetect),         //  rx_errdetect.data
        .rx_ready                     (rx_ready),             //  rx_pma_ready.data
        .tx_ready                     (tx_ready),             //  tx_pma_ready.data
        .reconfig_to_xcvr             (reconfig_to_xcvr),
        .reconfig_from_xcvr           (reconfig_from_xcvr),
        .rx_recovered_clk             (rx_recovered_clk)
      );
    assign tx_clk312_5 = 1'b0 ;
    end else if ((interface_type == "DDR XAUI") &&  (device_family == "Stratix IV")) begin
 dxaui_siv #(
    .device_family                (device_family),
    .starting_channel_number      (starting_channel_number),
    .interface_type               (interface_type),
    .number_of_interfaces         (1),
    .reconfig_interfaces          (reconfig_interfaces),
    .sys_clk_in_mhz               (mgmt_clk_in_mhz),
    .xaui_pll_type                (xaui_pll_type),
    .use_control_and_status_ports (use_control_and_status_ports),
    .external_pma_ctrl_reconf     (external_pma_ctrl_reconf),
    .tx_termination               (tx_termination),
    .tx_vod_selection             (tx_vod_selection),
    .tx_preemp_pretap             (tx_preemp_pretap),
    .tx_preemp_pretap_inv         (tx_preemp_pretap_inv),
    .tx_preemp_tap_1              (tx_preemp_tap_1),
    .tx_preemp_tap_2              (tx_preemp_tap_2),
    .tx_preemp_tap_2_inv          (tx_preemp_tap_2_inv),
    .rx_common_mode               (rx_common_mode),
    .rx_termination               (rx_termination),
    .rx_eq_dc_gain                (rx_eq_dc_gain),
    .rx_eq_ctrl                   (rx_eq_ctrl),
    .use_rx_rate_match            (use_rx_rate_match)
) dxaui_siv (
    .pll_ref_clk                  (pll_ref_clk),                // i
    .xgmii_tx_clk                 (xgmii_tx_clk),               // i
    .xgmii_rx_clk                 (xgmii_rx_clk),               // o
    .tx_clk312_5                  (tx_clk312_5),                // o
    .phy_mgmt_clk                 (phy_mgmt_clk),               // i
    .phy_mgmt_clk_reset           (phy_mgmt_clk_reset),         // i
    .phy_mgmt_address             (sc_phy_address),            // i
    .phy_mgmt_waitrequest         (sc_phy_waitrequest),        // o
    .phy_mgmt_read                (sc_phy_read),               // i
    .phy_mgmt_readdata            (sc_phy_readdata),           // o
    .phy_mgmt_write               (sc_phy_write),              // i
    .phy_mgmt_writedata           (phy_mgmt_writedata),         // i
    .xgmii_tx_dc                  (xgmii_tx_dc),                // i
    .xgmii_rx_dc                  (xgmii_rx_dc),                // o
    .xaui_tx_serial_data          (xaui_tx_serial_data),        // o
    .xaui_rx_serial_data          (xaui_rx_serial_data),        // i
    .rx_ready                     (rx_ready),                   // o
    .tx_ready                     (tx_ready),                   // o
    .rx_recovered_clk             (rx_recovered_clk),           // o
    .reconfig_from_xcvr             (l_reconfig_from_xcvr),         // o
    .reconfig_to_xcvr               (l_reconfig_to_xcvr),           // i
    .rx_analogreset               (rx_analogreset),             // i
    .rx_digitalreset              (rx_digitalreset),            // i
    .tx_digitalreset              (tx_digitalreset),            // i
    .rx_channelaligned            (rx_channelaligned),          // o
    .rx_invpolarity               (rx_invpolarity),             // i
    .rx_set_locktodata            (rx_set_locktodata),          // i
    .rx_set_locktoref             (rx_set_locktoref),           // i
    .rx_seriallpbken              (rx_seriallpbken),            // i
    .tx_invpolarity               (tx_invpolarity),             // i
    .rx_is_lockedtodata           (rx_is_lockedtodata),         // o
    .rx_phase_comp_fifo_error     (rx_phase_comp_fifo_error),   // o
    .rx_is_lockedtoref            (rx_is_lockedtoref),          // o
    .rx_rlv                       (rx_rlv),                     // o
    .rx_rmfifoempty               (rx_rmfifoempty),             // o
    .rx_rmfifofull                (rx_rmfifofull),              // o
    .tx_phase_comp_fifo_error     (tx_phase_comp_fifo_error),   // o
    .rx_disperr                   (rx_disperr),                 // o
    .rx_errdetect                 (rx_errdetect),               // o
    .rx_patterndetect             (rx_patterndetect),           // o
    .rx_rmfifodatadeleted         (rx_rmfifodatadeleted),       // o
    .rx_rmfifodatainserted        (rx_rmfifodatainserted),      // o
    .rx_runningdisp               (rx_runningdisp),             // o
    .rx_syncstatus                (rx_syncstatus),              // o
    .pll_locked                   (pll_locked),                 // o
    .cal_blk_powerdown            (cal_blk_powerdown),          // i
    .gxb_powerdown                (gxb_powerdown),              // i
    .pll_powerdown                (pll_powerdown)               // i
); // module dxaui_siv
    end else if ((device_family == "Stratix IV") || (device_family == "HardCopy IV") ||(device_family == "Arria II GX") || (device_family == "Arria II GZ")) begin
      siv_xcvr_xaui #(
        .device_family                (device_family),
        .starting_channel_number      (starting_channel_number),
        .interface_type               (interface_type),
        .number_of_interfaces         (1),
        .reconfig_interfaces          (reconfig_interfaces),
        .sys_clk_in_mhz               (mgmt_clk_in_mhz),
        .xaui_pll_type                (xaui_pll_type),
        .use_control_and_status_ports (use_control_and_status_ports),
        .external_pma_ctrl_reconf     (external_pma_ctrl_reconf),
        .tx_termination               (tx_termination),
        .rx_termination               (rx_termination),
        .tx_preemp_pretap             (tx_preemp_pretap),
        .tx_preemp_pretap_inv         (tx_preemp_pretap_inv),
        .tx_preemp_tap_1              (tx_preemp_tap_1),
        .tx_preemp_tap_2              (tx_preemp_tap_2),
        .tx_preemp_tap_2_inv          (tx_preemp_tap_2_inv),
        .tx_vod_selection             (tx_vod_selection),
        .rx_eq_dc_gain                (rx_eq_dc_gain),
        .rx_eq_ctrl                   (rx_eq_ctrl),
        .rx_common_mode               (rx_common_mode)
      ) xaui_phy (
        .pll_ref_clk                  (pll_ref_clk),
        .xgmii_rx_clk                 (xgmii_rx_clk),
        .xgmii_tx_clk                 (xgmii_tx_clk),
        .phy_mgmt_clk                 (phy_mgmt_clk),
        .phy_mgmt_clk_reset           (phy_mgmt_clk_reset),
        .phy_mgmt_address             (sc_phy_address),
        .phy_mgmt_read                (sc_phy_read),
        .phy_mgmt_readdata            (sc_phy_readdata),
        .phy_mgmt_waitrequest         (sc_phy_waitrequest),
        .phy_mgmt_write               (sc_phy_write),
        .phy_mgmt_writedata           (phy_mgmt_writedata),
        .xaui_rx_serial_data          (xaui_rx_serial_data),
        .xaui_tx_serial_data          (xaui_tx_serial_data),
        .xgmii_rx_dc                  (xgmii_rx_dc),
        .xgmii_tx_dc                  (xgmii_tx_dc),
        .rx_ready                     (rx_ready),
        .tx_ready                     (tx_ready),
        .rx_recovered_clk             (rx_recovered_clk),           //o
        .reconfig_from_xcvr           (l_reconfig_from_xcvr),
        .reconfig_to_xcvr               (l_reconfig_to_xcvr),
        
// optional control and status ports - will be terminated by tri0 if unconnected
        .rx_analogreset               (rx_analogreset),           // input  wire      
        .rx_digitalreset              (rx_digitalreset),          // input  wire [3:0]
        .tx_digitalreset              (tx_digitalreset),          // input  wire [3:0]
        .rx_channelaligned            (rx_channelaligned),        // output wire      
        .rx_invpolarity               (rx_invpolarity),           // input  wire [3:0]
        .rx_set_locktodata            (rx_set_locktodata),        // input  wire [3:0]
        .rx_set_locktoref             (rx_set_locktoref),         // input  wire [3:0]
        .rx_seriallpbken              (rx_seriallpbken),          // input  wire [3:0]
        .tx_invpolarity               (tx_invpolarity),           // input  wire [3:0]
        .rx_is_lockedtodata           (rx_is_lockedtodata),       // output wire [3:0]
        .rx_phase_comp_fifo_error     (rx_phase_comp_fifo_error), // output wire [3:0]
        .rx_is_lockedtoref            (rx_is_lockedtoref),        // output wire [3:0]
        .rx_rlv                       (rx_rlv),                   // output wire [3:0]
        .rx_rmfifoempty               (rx_rmfifoempty),           // output wire [3:0]
        .rx_rmfifofull                (rx_rmfifofull),            // output wire [3:0]
        .tx_phase_comp_fifo_error     (tx_phase_comp_fifo_error), // output wire [3:0]
        .rx_disperr                   (rx_disperr),               // output wire [7:0]
        .rx_errdetect                 (rx_errdetect),             // output wire [7:0]
        .rx_patterndetect             (rx_patterndetect),         // output wire [7:0]
        .rx_rmfifodatadeleted         (rx_rmfifodatadeleted),     // output wire [7:0]
        .rx_rmfifodatainserted        (rx_rmfifodatainserted),    // output wire [7:0]
        .rx_runningdisp               (rx_runningdisp),           // output wire [7:0]
        .rx_syncstatus                (rx_syncstatus),            // output wire [7:0]

// external_pma_ctrl_reconf
        .pll_locked                   (pll_locked),        //  output wire      
        .cal_blk_powerdown            (cal_blk_powerdown), //  input  wire      
        .gxb_powerdown                (gxb_powerdown),     //  input  wire      
        .pll_powerdown                (pll_powerdown)      //  input  wire      
      );
    assign tx_clk312_5 = 1'b0 ;
    end else if (device_family == "Cyclone IV GX") begin
// need to add the extra optional ports for c&s and ext_pma
      civ_xcvr_xaui #(
        .device_family                (device_family),
        .starting_channel_number      (starting_channel_number),
        .interface_type               (interface_type),
        .number_of_interfaces         (1),
        .sys_clk_in_mhz               (mgmt_clk_in_mhz),
        .xaui_pll_type                (xaui_pll_type),
        .use_control_and_status_ports (use_control_and_status_ports),
        .tx_termination               (tx_termination),
        .rx_termination               (rx_termination),
        .tx_preemp_pretap             (tx_preemp_pretap),
        .tx_preemp_pretap_inv         (tx_preemp_pretap_inv),
        .tx_preemp_tap_1              (tx_preemp_tap_1),
        .tx_preemp_tap_2              (tx_preemp_tap_2),
        .tx_preemp_tap_2_inv          (tx_preemp_tap_2_inv),
        .tx_vod_selection             (tx_vod_selection),
        .rx_eq_dc_gain                (rx_eq_dc_gain),
        .rx_eq_ctrl                   (rx_eq_ctrl),
        .rx_common_mode               (rx_common_mode)
      ) xaui_phy (
        .pll_ref_clk                  (pll_ref_clk),
        .xgmii_rx_clk                 (xgmii_rx_clk),
        .xgmii_tx_clk                 (xgmii_tx_clk),
        .phy_mgmt_clk                 (phy_mgmt_clk),
        .phy_mgmt_clk_reset           (phy_mgmt_clk_reset),
        .phy_mgmt_address             (sc_phy_address),
        .phy_mgmt_read                (sc_phy_read),
        .phy_mgmt_readdata            (sc_phy_readdata),
        .phy_mgmt_waitrequest         (sc_phy_waitrequest),
        .phy_mgmt_write               (sc_phy_write),
        .phy_mgmt_writedata           (phy_mgmt_writedata),
        .xaui_rx_serial_data          (xaui_rx_serial_data),
        .xaui_tx_serial_data          (xaui_tx_serial_data),
        .xgmii_rx_dc                  (xgmii_rx_dc),
        .xgmii_tx_dc                  (xgmii_tx_dc),
        .rx_ready                     (rx_ready),
        .tx_ready                     (tx_ready),
        .rx_recovered_clk             (rx_recovered_clk),           //o
        .reconfig_from_xcvr             (l_reconfig_from_xcvr[16:0]),
        .reconfig_to_xcvr               (l_reconfig_to_xcvr),

// optional control and status ports - will be terminated by tri0 if unconnected
        .rx_analogreset               (rx_analogreset),           // input  wire
        .rx_digitalreset              (rx_digitalreset),          // input  wire [3:0]
        .tx_digitalreset              (tx_digitalreset),          // input  wire [3:0]
        .rx_channelaligned            (rx_channelaligned),        // output wire
        .rx_invpolarity               (rx_invpolarity),           // input  wire [3:0]
        .rx_set_locktodata            (rx_set_locktodata),        // input  wire [3:0]
        .rx_set_locktoref             (rx_set_locktoref),         // input  wire [3:0]
        .rx_seriallpbken              (rx_seriallpbken),          // input  wire [3:0]
        .tx_invpolarity               (tx_invpolarity),           // input  wire [3:0]
        .rx_is_lockedtodata           (rx_is_lockedtodata),       // output wire [3:0]
        .rx_phase_comp_fifo_error     (rx_phase_comp_fifo_error), // output wire [3:0]
        .rx_is_lockedtoref            (rx_is_lockedtoref),        // output wire [3:0]
        .rx_rlv                       (rx_rlv),                   // output wire [3:0]
        .rx_rmfifoempty               (rx_rmfifoempty),           // output wire [3:0]
        .rx_rmfifofull                (rx_rmfifofull),            // output wire [3:0]
        .tx_phase_comp_fifo_error     (tx_phase_comp_fifo_error), // output wire [3:0]
        .rx_disperr                   (rx_disperr),               // output wire [7:0]
        .rx_errdetect                 (rx_errdetect),             // output wire [7:0]
        .rx_patterndetect             (rx_patterndetect),         // output wire [7:0]
        .rx_rmfifodatadeleted         (rx_rmfifodatadeleted),     // output wire [7:0]
        .rx_rmfifodatainserted        (rx_rmfifodatainserted),    // output wire [7:0]
        .rx_runningdisp               (rx_runningdisp),           // output wire [7:0]
        .rx_syncstatus                (rx_syncstatus),            // output wire [7:0]

// external_pma_ctrl_reconf
        .pll_locked                   (pll_locked),        //  output wire
        .cal_blk_powerdown            (cal_blk_powerdown), //  input  wire
        .gxb_powerdown                (gxb_powerdown),     //  input  wire
        .pll_powerdown                (pll_powerdown)      //  input  wire
      );
    assign tx_clk312_5 = 1'b0 ;
    end
  endgenerate

endmodule
