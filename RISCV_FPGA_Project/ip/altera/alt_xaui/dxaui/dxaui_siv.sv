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
// Description: dxaui static verilog for Stratix IV
//
// Authors:     bauyeung    7-Sep-2010
// Modified:    ishimony   13-Dec-2010
//
//              Copyright (c) Altera Corporation 1997 - 2010
//              All rights reserved.
//
//-----------------------------------------------------------------------------

module dxaui_siv #(
  parameter device_family                = "Stratix IV",
  parameter starting_channel_number      = 0,
  parameter interface_type               = "DDR XAUI",
  parameter number_of_interfaces         = 1,
  parameter sys_clk_in_mhz               = 50,
  parameter xaui_pll_type                = "CMU",
  parameter reconfig_interfaces         = 4,
  parameter use_control_and_status_ports = 0,
  parameter external_pma_ctrl_reconf     = 0,
  parameter tx_termination               = "OCT_150_OHMS",
  parameter tx_vod_selection             = 1,
  parameter tx_preemp_pretap             = 0,
  parameter tx_preemp_pretap_inv         = 0,
  parameter tx_preemp_tap_1              = 5,
  parameter tx_preemp_tap_2              = 0,
  parameter tx_preemp_tap_2_inv          = 0,
  parameter rx_common_mode               = "0.82v",
  parameter rx_termination               = "OCT_150_OHMS",
  parameter rx_eq_dc_gain                = 0,
  parameter rx_eq_ctrl                   = 14,
  parameter use_rx_rate_match            = 0
) (
  input  wire        pll_ref_clk,           //   refclk.clk
  input  wire        xgmii_tx_clk,          //   xgmii_tx_clk.clk
  output wire        xgmii_rx_clk,          //   xgmii_rx_clk.clk
  input  wire        phy_mgmt_clk,          //   mgmt_clk.clk
  input  wire        phy_mgmt_clk_reset,    //   mgmt_clk_rst.reset_n
  input  wire  [7:0] phy_mgmt_address,      //   phy_mgmt.address
  output wire        phy_mgmt_waitrequest,  //   .waitrequest
  input  wire        phy_mgmt_read,         //   .read
  output wire [31:0] phy_mgmt_readdata,     //   .readdata
  input  wire        phy_mgmt_write,        //   .write
  input  wire [31:0] phy_mgmt_writedata,    //   .writedata
  input  wire [71:0] xgmii_tx_dc,           //   xgmii_tx_dc.data
  output wire [71:0] xgmii_rx_dc,           //   xgmii_rx_dc.data
  output wire [3:0]  xaui_tx_serial_data,   //   xaui_tx_serial.export
  input  wire [3:0]  xaui_rx_serial_data,   //   xaui_rx_serial.export
  output wire        rx_ready,              //   rx_pma_ready.data
  output wire        tx_ready,              //   tx_pma_ready.data
  output tri0 [altera_xcvr_functions::get_reconfig_from_width(device_family,reconfig_interfaces)-1:0] reconfig_from_xcvr,
  input  tri0 [altera_xcvr_functions::get_reconfig_to_width(device_family,reconfig_interfaces)  -1:0] reconfig_to_xcvr,

  output wire [3:0]  rx_recovered_clk,      //   rx recovered clock from cdr
  output wire        tx_clk312_5,     //   dxaui: pma tx out clock, 312.5Mhz
// optional control and status ports
  input  wire        rx_analogreset,
  input  wire        rx_digitalreset,
  input  wire        tx_digitalreset,
  output wire        rx_channelaligned,
  input  wire [3:0]  rx_invpolarity,
  input  wire [3:0]  rx_set_locktodata,
  input  wire [3:0]  rx_set_locktoref,
  input  wire [3:0]  rx_seriallpbken,
  input  wire [3:0]  tx_invpolarity,
  output wire [3:0]  rx_is_lockedtodata,
  output wire [3:0]  rx_phase_comp_fifo_error,
  output wire [3:0]  rx_is_lockedtoref,
  output wire [3:0]  rx_rlv,
  output wire [3:0]  rx_rmfifoempty,
  output wire [3:0]  rx_rmfifofull,
  output wire [3:0]  tx_phase_comp_fifo_error,
  output wire [7:0]  rx_disperr,
  output wire [7:0]  rx_errdetect,
  output wire [7:0]  rx_patterndetect,
  output wire [7:0]  rx_rmfifodatadeleted,
  output wire [7:0]  rx_rmfifodatainserted,
  output wire [7:0]  rx_runningdisp,
  output wire [7:0]  rx_syncstatus,

// external_pma_ctrl_reconf
  output wire        pll_locked,
  input  wire        cal_blk_powerdown,
  input  wire        gxb_powerdown,
  input  wire        pll_powerdown
);

import altera_xcvr_functions::*;
  wire        alt_pma_controller_0_cal_blk_pdn;
  wire        alt_pma_controller_0_pll_pdn0;
  wire        alt_pma_controller_0_gx_pdn;
  wire  [3:0] alt_pma_ch_controller_0_rx_set_locktodata;
  wire  [3:0] alt_pma_ch_controller_0_rx_set_locktoref;
  wire  [3:0] alt_pma_ch_controller_0_rx_seriallpbken;
  wire  [3:0] alt_pma_ch_controller_0_rx_analog_rst;
  wire  [3:0] alt_pma_ch_controller_0_tx_digital_rst;
  wire  [3:0] alt_pma_ch_controller_0_rx_digital_rst;
  wire        r_rx_digitalreset;
  wire  [3:0] r_rx_invpolarity;
  wire        r_tx_digitalreset;
  wire  [3:0] r_tx_invpolarity;
  wire        simulation_flag;
  wire        alt_pma_controller_0_pll_pdn;
  wire  [3:0] tx_out_clk;
  wire  [3:0] alt_pma_rx_recovered_clk;
  wire [79:0] tx_parallel_data;
  wire [79:0] rx_parallel_data;
  wire        rx_pma_ready;
  wire        pma_stat_rst_done;

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

// assign output wires for external pma_ctrl
  assign rx_ready = rx_pma_ready & pma_stat_rst_done; // PMA and PCS ready

// resolve bus-wire warnings
wire  [0:0] pll_locked_bus;
assign      pll_locked = pll_locked_bus[0];
assign      tx_clk312_5 = tx_out_clk[0];     //   dxaui: pma tx out clock, 312.5Mhz

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
    .sc_pma_ch_controller_address     (sc_pma_ch_controller_address),  //6 bit
    .sc_pma_ch_controller_read        (sc_pma_ch_controller_read),
    .sc_pma_ch_controller_write       (sc_pma_ch_controller_write),

    // internal interface to 'top' pma controller block
    .sc_pma_controller_readdata       (sc_pma_controller_readdata),
    .sc_pma_controller_waitrequest    (sc_pma_controller_waitrequest),
    .sc_pma_controller_address        (sc_pma_controller_address),    //2 bit
    .sc_pma_controller_read           (sc_pma_controller_read),
    .sc_pma_controller_write          (sc_pma_controller_write),
  
    // internal interface to 'top' hxaui csr block
    .sc_csr_readdata                  (sc_csr_readdata),
    .sc_csr_waitrequest               (1'b0),           // PCS CSR always ready
    .sc_csr_address                   (sc_csr_address), //5 bit wide
    .sc_csr_read                      (sc_csr_read),
    .sc_csr_write                     (sc_csr_write)
  );

  ///////////////////////////////////////////////////////////////////////
  // PMA Channel Controller
  ///////////////////////////////////////////////////////////////////////
      siv_xcvr_low_latency_phy_nr #(
    .device_family                  (device_family),
    .number_of_channels             (4),
    .number_of_reconfig_interface   (reconfig_interfaces),
    .intended_device_variant        ("ANY"),
    .operation_mode                 ("DUPLEX"),
    .phase_comp_fifo_mode           ("NONE"),
    .serialization_factor           (20),
    .data_rate                      ("6250 Mbps"),
    .pll_input_frequency            ("156.25 MHz"),
    .number_pll_inclks              (1),
    .pll_inclk_select               (0),
    .pll_type                       (xaui_pll_type),
    .rx_use_cruclk                  ("FALSE"),
    .starting_channel_number        (starting_channel_number),
    .bonded_mode                    ("TRUE"),
    .sys_clk_in_mhz                 (sys_clk_in_mhz),
    .gx_analog_power                ("AUTO"),
    .pll_lock_speed                 ("AUTO"),
    .tx_analog_power                ("AUTO"),
    .tx_slew_rate                   ("OFF"),
    .tx_termination                 (tx_termination),
    .tx_common_mode                 ("0.65V"),
    .rx_pll_lock_speed              ("AUTO"),
    .rx_common_mode                 (rx_common_mode),
    .rx_signal_detect_threshold     (2),
    .rx_ppmselect                   (32),
    .rx_termination                 (rx_termination),
    .tx_preemp_pretap               (tx_preemp_pretap),
        .tx_preemp_pretap_inv         ((tx_preemp_pretap_inv==1)? "TRUE" : "FALSE"),
    .tx_preemp_tap_1                (tx_preemp_tap_1),
    .tx_preemp_tap_2                (tx_preemp_tap_2),
        .tx_preemp_tap_2_inv          ((tx_preemp_tap_2_inv==1)? "TRUE" : "FALSE"),
    .tx_vod_selection               (tx_vod_selection),
    .rx_eq_dc_gain                  (rx_eq_dc_gain),
    .rx_eq_ctrl                     (rx_eq_ctrl),
    .loopback_mode                  ("SLB")
) alt_pma (
    .clk                            (phy_mgmt_clk),
    .rst                            (phy_mgmt_clk_reset),
    .gx_pdn                         (alt_pma_controller_0_gx_pdn),
    .ch_mgmt_address                (sc_pma_ch_controller_address),
    .ch_mgmt_read                   (sc_pma_ch_controller_read),
    .ch_mgmt_readdata               (sc_pma_ch_controller_readdata),
    .ch_mgmt_write                  (sc_pma_ch_controller_write),
    .ch_mgmt_writedata              (phy_mgmt_writedata),
    .ch_mgmt_waitrequest            (sc_pma_ch_controller_waitrequest),
    .cal_blk_clk                    (phy_mgmt_clk),
    .cal_blk_pdn                    (alt_pma_controller_0_cal_blk_pdn),
    .pll_ref_clk                    (pll_ref_clk),
    .tx_out_clk                     (tx_out_clk),
    .tx_parallel_data               (tx_parallel_data),
    .tx_serial_data                 (xaui_tx_serial_data),
    .tx_pma_ready                   (tx_ready),
    .pll_pdn                        (alt_pma_controller_0_pll_pdn0),
    .pll_locked                     (pll_locked_bus),
    .rx_is_lockedtodata             (rx_is_lockedtodata),
    .rx_is_lockedtoref              (rx_is_lockedtoref),
    .rx_recovered_clk               (alt_pma_rx_recovered_clk),
    .rx_serial_data                 (xaui_rx_serial_data),
    .rx_parallel_data               (rx_parallel_data),
    .rx_cdr_ref_clk                 (),
    .rx_pma_ready                   (rx_pma_ready),
    .reconfig_clk                   (phy_mgmt_clk),
        .reconfig_to_gxb             (reconfig_to_xcvr),
        .reconfig_from_gxb           (reconfig_from_xcvr),
    .rx_rst_digital                (rx_digitalreset), //optional user triggered
    .tx_rst_digital                (tx_digitalreset)  //optional user triggered
);

///////////////////////////////////////////////////////////////////////
// PMA Controller
///////////////////////////////////////////////////////////////////////
  generate 
    if (external_pma_ctrl_reconf == 0) begin
      alt_pma_controller_tgx #(
        .number_of_plls         (1),
        .sync_depth             (2),
        .tx_pll_reset_hold_time (20)
      ) alt_pma_controller_tgx (
        .clk                    (phy_mgmt_clk),                          
        .rst                    (phy_mgmt_clk_reset),                        
        .pma_mgmt_address       (sc_pma_controller_address),   
        .pma_mgmt_read          (sc_pma_controller_read),   
        .pma_mgmt_readdata      (sc_pma_controller_readdata),   
        .pma_mgmt_write         (sc_pma_controller_write),   
        .pma_mgmt_writedata     (phy_mgmt_writedata),     
        .pma_mgmt_waitrequest   (sc_pma_controller_waitrequest),   
        .cal_blk_clk            (phy_mgmt_clk),                    
        .cal_blk_pdn            (alt_pma_controller_0_cal_blk_pdn),
        .tx_pll_ready           (),                                     
        .gx_pdn                 (alt_pma_controller_0_gx_pdn),     
        .pll_pdn                (alt_pma_controller_0_pll_pdn0),
        .pll_locked             (pll_locked_bus)                  
      );
    end else begin
      assign alt_pma_controller_0_cal_blk_pdn = cal_blk_powerdown;
      assign alt_pma_controller_0_gx_pdn      = gxb_powerdown;
      assign alt_pma_controller_0_pll_pdn0    = pll_powerdown;
    end
  endgenerate


///////////////////////////////////////////////////////////////////////
// HXAUI CSR
///////////////////////////////////////////////////////////////////////
// should be consistent across all device families and interface types
  hxaui_csr hxaui_csr (
    .clk                      (phy_mgmt_clk),
    .reset                    (phy_mgmt_clk_reset),
    .address                  (sc_csr_address),
    .byteenable               (4'b1111), // .byteenable
    .read                     (sc_csr_read),
    .readdata                 (sc_csr_readdata),
    .write                    (sc_csr_write),
    .writedata                (phy_mgmt_writedata),
    .rx_patterndetect         (rx_patterndetect),
    .rx_syncstatus            (rx_syncstatus),
    .rx_runningdisp           (rx_runningdisp),
    .rx_errdetect             (rx_errdetect),
    .rx_disperr               (rx_disperr),
    .rx_phase_comp_fifo_error (rx_phase_comp_fifo_error),
    .rx_rlv                   (rx_rlv),
    .rx_rmfifodatadeleted     (rx_rmfifodatadeleted),
    .rx_rmfifodatainserted    (rx_rmfifodatainserted),
    .rx_rmfifoempty           (rx_rmfifoempty),
    .rx_rmfifofull            (rx_rmfifofull),
    .tx_phase_comp_fifo_error (tx_phase_comp_fifo_error),
    .r_rx_invpolarity         (r_rx_invpolarity),
    .r_tx_invpolarity         (r_tx_invpolarity),
    .r_rx_digitalreset        (r_rx_digitalreset),
    .r_tx_digitalreset        (r_tx_digitalreset),
    .simulation_flag          (simulation_flag)
  );


///////////////////////////////////////////////////////////////////////
// DXAUI_PCS
///////////////////////////////////////////////////////////////////////
wire   refclk;
assign refclk = pll_ref_clk;

wire   mgmt_clk;
assign mgmt_clk = phy_mgmt_clk;

wire   pma_gxb_powerdown;
assign pma_gxb_powerdown = phy_mgmt_clk_reset;
//@@@ wire   pma_rx_digitalreset;
//@@@ assign pma_rx_digitalreset = phy_mgmt_clk_reset;
//@@@ wire   pma_tx_digitalreset;
//@@@ assign pma_tx_digitalreset = phy_mgmt_clk_reset;
wire [3:0]  pma_rx_freqlocked;
assign pma_rx_freqlocked =  rx_is_lockedtoref;
assign rx_recovered_clk = alt_pma_rx_recovered_clk;

dxaui_pcs dxaui_pcs(
    .xgmii_tx_clk                   (xgmii_tx_clk),        // i
    .xgmii_tx_dc                    (xgmii_tx_dc),         // i
    .xgmii_rx_clk                   (xgmii_rx_clk),        // o
    .xgmii_rx_dc                    (xgmii_rx_dc),         // o
    .refclk                         (refclk),              // i
    .mgmt_clk                       (mgmt_clk),            // i
    .tx_out_clk                     (tx_out_clk),          // i
    .rx_recovered_clk               (alt_pma_rx_recovered_clk),    // i
    .tx_parallel_data               (tx_parallel_data),    // o
    .rx_parallel_data               (rx_parallel_data),    // i
    .rx_is_lockedtodata             (rx_is_lockedtodata),  // i
    .rx_digitalreset                (rx_digitalreset),     // i
    .tx_digitalreset                (tx_digitalreset),     // i
    .pll_locked                     (pll_locked),          // i
    .rx_syncstatus                  (rx_syncstatus),       // o
    .rx_channelaligned              (rx_channelaligned),   // o
    .rx_disperr                     (rx_disperr),          // o
    .rx_errdetect                   (rx_errdetect),        // o
    .r_rx_digitalreset              (r_rx_digitalreset),   // i
    .r_tx_digitalreset              (r_tx_digitalreset),   // i
    .pma_stat_rst_done              (pma_stat_rst_done),   // o
    .simulation_flag                (simulation_flag),     // i
    .pma_gxb_powerdown              (pma_gxb_powerdown),   // i
//@@@    .pma_rx_digitalreset            (pma_rx_digitalreset), // i
//@@@    .pma_tx_digitalreset            (pma_tx_digitalreset), // i
    .pma_rx_freqlocked              (pma_rx_freqlocked)    // i
); // module dxaui_pcs
defparam dxaui_pcs .use_rx_rate_match = use_rx_rate_match;

// not supported by soft PCS
      assign rx_patterndetect           = 8'b0;
      assign rx_runningdisp             = 8'b0;
      assign rx_phase_comp_fifo_error   = 4'b0;
      assign rx_rlv                     = 4'b0;
      assign rx_rmfifodatadeleted       = 8'b0;
      assign rx_rmfifodatainserted      = 8'b0;
      assign rx_rmfifoempty             = 4'b0;
      assign rx_rmfifofull              = 4'b0;
      assign tx_phase_comp_fifo_error   = 4'b0;
      assign r_rx_invpolarity = 4'b0;
      assign r_tx_invpolarity = 4'b0;

endmodule
