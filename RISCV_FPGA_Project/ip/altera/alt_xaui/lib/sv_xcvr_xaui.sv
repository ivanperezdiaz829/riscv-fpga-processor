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
// Description: hxaui static verilog for Stratix IV
//
// Authors:     bauyeung    7-Sep-2010
//
//              Copyright (c) Altera Corporation 1997 - 2010
//              All rights reserved.
//
//-----------------------------------------------------------------------------
`timescale 1ps/1ps
module sv_xcvr_xaui #(
  parameter device_family                = "Stratix V",
  parameter starting_channel_number      = 0,
  parameter interface_type               = "Hard XAUI",
  parameter number_of_interfaces         = 1,
  parameter reconfig_interfaces          = 1,
  parameter sys_clk_in_mhz               = 50,
  parameter data_rate                    = "3125 Mbps", 
  parameter xaui_pll_type                = "CMU",
  parameter BASE_DATA_RATE               = "3125 Mbps",
  parameter en_synce_support             = 0,   //expose CDR ref-clk in this mode
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
  parameter bonded_group_size            = 1 ,
  parameter bonded_mode                  = "xN"
) (
  input  wire        pll_ref_clk,           //   refclk.clk
  input  wire        cdr_ref_clk,           // used only in SyncE mode
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
  output wire [3:0]  rx_recovered_clk,      //   rx recovered clock from cdr
// optional control and status ports
  input  wire        rx_digitalreset,
  input  wire        tx_digitalreset,
  output wire        rx_channelaligned,
  output wire [7:0]  rx_disperr,
  output wire [7:0]  rx_errdetect,
  output wire [7:0]  rx_syncstatus,
  output tri0 [altera_xcvr_functions::get_reconfig_from_width(device_family,reconfig_interfaces)-1:0] reconfig_from_xcvr,
  input  tri0 [altera_xcvr_functions::get_reconfig_to_width(device_family,reconfig_interfaces)  -1:0] reconfig_to_xcvr

);

import altera_xcvr_functions::*;

  wire         alt_pma_controller_0_cal_blk_pdn_data;
  wire         alt_pma_controller_0_pll_pdn0_data;
  wire         pll_locked_data;
  wire  [7:0]  rx_disperr_data;
  wire  [7:0] rx_errdetect_data;
  wire  [7:0] rx_syncstatus_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_analog_rst_data;
  wire  [3:0] alt_pma_ch_controller_0_tx_digital_rst_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_digital_rst_data;
  wire        hxaui_csr_r_rx_digitalreset_data;
  wire        hxaui_csr_r_tx_digitalreset_data;
  wire        hxaui_csr_simulation_flag_data;
  wire        alt_pma_controller_0_pll_pdn;
  wire  [3:0] alt_pma_0_tx_out_clk_clk;
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
  assign rx_disperr               = rx_disperr_data;
  assign rx_errdetect             = rx_errdetect_data; 
  assign rx_syncstatus            = rx_syncstatus_data;
  assign rx_recovered_clk         = alt_pma_0_rx_recovered_clk_clk;
  assign alt_pma_0_tx_out_clk_clk     = {4 {alt_pma_0_tx_out_clk}};
  // assign output wires for external pma_ctrl - whether or not they are used will be decided by the top level

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
 (* ALTERA_ATTRIBUTE = {"-name SDC_STATEMENT \"set_false_path -from [get_registers {*sv_xcvr_xaui*hxaui_csr*hxaui_csr_reset0q[1]}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*pll_inreset*]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sv_xcvr_xaui*hxaui_csr*hxaui_csr_reset0q[1]}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*tx_reset*]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sxaui_0*alt_soft_xaui_pcs*xaui_rx*disp_err_delay[*]}] -to  [get_registers *xaui_phy*hxaui_csr*rx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sxaui_0*alt_soft_xaui_pcs*xaui_rx*pcs_rx_syncstatus[*]}] -to  [get_registers *xaui_phy*hxaui_csr*rx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sxaui_0*alt_soft_xaui_pcs*xaui_rx*channel_align_synchclk[*]}] -to  [get_registers *xaui_phy*hxaui_csr*rx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sv_xcvr_xaui*hxaui_csr*hxaui_csr_reset0q[1]}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*rx_reset*]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*sv_xcvr_xaui*hxaui_csr*hxaui_csr_simulation_flag0q}] -to  [get_registers *sxaui_0*alt_soft_xaui_pcs*pcs_reset*simulation_flag_f]\""} *)
      sv_xcvr_low_latency_phy_nr #(
        .device_family                (device_family),
        .intended_device_variant      ("ANY"),
        .lanes           (4),
        .operation_mode               ("DUPLEX"),
        .phase_comp_fifo_mode         ("NONE"),
        .serialization_factor         (20),
        .pma_width                    (20),
        .data_rate                    (data_rate),
	.pll_type                     (xaui_pll_type),
        .base_data_rate               (BASE_DATA_RATE),
	.en_synce_support             (en_synce_support), //expose CDR ref-clk in this mode
        .pll_refclk_freq              ("156.25 MHz"),
        .sys_clk_in_mhz               (sys_clk_in_mhz),
        .plls                         (1),
        .pll_refclk_cnt               (1),
        .starting_channel_number      (0), // does not apply for SV
        .bonded_group_size             (bonded_group_size),
        .tx_use_coreclk                (1),
        .rx_use_coreclk                (0),
        .rx_bitslip_en                 (0),
        .tx_bitslip_en                 (0),
        .select_10g_pcs                (0),
        .use_double_data_mode          ("false"),
        .bonded_mode                   (bonded_mode)
       /* .number_of_reconfig_interface (4),
        .pll_type                     ("CMU"), // CMU only for SV for now
        .gx_analog_power              ("AUTO"),
        .pll_lock_speed               ("AUTO"),
        .tx_analog_power              ("AUTO"),
        .tx_slew_rate                 ("OFF"),
        .tx_termination               ("OCT_100_OHMS"),
        .tx_common_mode               ("0.65V"),
        .rx_pll_lock_speed            ("AUTO"),
        .rx_common_mode               ("0.82V"),
        .rx_signal_detect_threshold   (2),
        .rx_ppmselect                 (32),
        .rx_termination               ("OCT_100_OHMS"),
        .tx_preemp_pretap             (0),
        .tx_preemp_pretap_inv         (0),
        .tx_preemp_tap_1              (5),
        .tx_preemp_tap_2              (0),
        .tx_preemp_tap_2_inv          (0),
        .tx_vod_selection             (1),
        .rx_eq_dc_gain                (0),
        .rx_eq_ctrl                   (14),
        .loopback_mode                ("SLB")*/
      ) alt_pma_0 (
        .clk                         (phy_mgmt_clk),
        .rst                         (phy_mgmt_clk_reset),
        .ch_mgmt_address             (8'h40 | sc_pma_ch_controller_address),
        .ch_mgmt_read                (sc_pma_ch_controller_read),
        .ch_mgmt_readdata            (sc_pma_ch_controller_readdata),
        .ch_mgmt_write               (sc_pma_ch_controller_write),
        .ch_mgmt_writedata           (phy_mgmt_writedata),
        .ch_mgmt_waitrequest         (sc_pma_ch_controller_waitrequest),

        .gx_pdn                      (),
        .rx_rst_digital              (rx_digitalreset), //optional user triggered rx_digitalreset
        .tx_rst_digital              (tx_digitalreset),  //optional user triggered tx_digitalreset
        .rx_pma_ready                (rx_ready),
        .tx_pma_ready                (tx_ready),

        .pll_pdn                     (alt_pma_controller_0_pll_pdn0_data),
        .pll_locked                  (pll_locked_data),
        //.cal_blk_clk                 (phy_mgmt_clk),
        //.cal_blk_pdn                 (alt_pma_controller_0_cal_blk_pdn_data),
        .pll_ref_clk                 (pll_ref_clk),
	.cdr_ref_clk                 (cdr_ref_clk), // used only in SyncE mode
        .tx_coreclk                  ({4{xgmii_tx_clk}}),
        .rx_coreclk                  (4'b0),
        .tx_parallel_data            (sxaui_0_tx_parallel_data_data),
        .tx_serial_data              (xaui_tx_serial_data),
        .tx_clkout                  (alt_pma_0_tx_out_clk),
        .tx_bitslip                  (28'b0),
        .rx_serial_data              (xaui_rx_serial_data),
        .rx_parallel_data            (alt_pma_0_rx_parallel_data_data),
        //.rx_recovered_clk            (alt_pma_0_rx_recovered_clk_clk),
        .rx_clkout                   (alt_pma_0_rx_recovered_clk_clk),
        .rx_bitslip                  (4'b0),
        .rx_parallel_data_read       (4'b0),

        .rx_is_lockedtodata          (alt_pma_0_rx_is_lockedtodata_data),
        .rx_is_lockedtoref           (),

        .reconfig_to_xcvr             (reconfig_to_xcvr),
        .reconfig_from_xcvr           (reconfig_from_xcvr),

        .tx_digital_rst      (alt_pma_ch_controller_0_tx_digital_rst_data),
        .rx_digital_rst      (alt_pma_ch_controller_0_rx_digital_rst_data)
        /*
        .rx_cdr_ref_clk              (),
        .reconfig_clk                (phy_mgmt_clk),
        .aeq_to_gxb                  (96'b0),
        .aeq_from_gxb                ()*/
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
    .rx_syncstatus            (rx_syncstatus_data),
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
// SV currently only supports soft XAUI (as of 10.1)
  generate
    if (interface_type == "Soft XAUI") begin
      sxaui #(
        .starting_channel_number      (0),
        .xaui_pll_type                (xaui_pll_type),
        .use_control_and_status_ports (use_control_and_status_ports)
      ) sxaui_0 (
        .xgmii_tx_clk       (xgmii_tx_clk),                      // xgmii_tx_clk.clk
        .xgmii_tx_dc        (xgmii_tx_dc),                       // xgmii_tx_dc.data
        .xgmii_rx_clk       (xgmii_rx_clk),                      // xgmii_rx_clk.clk
        .xgmii_rx_dc        (xgmii_rx_dc),                       // xgmii_rx_dc.data
        .refclk             (pll_ref_clk),                       // refclk.clk
        .mgmt_clk           (phy_mgmt_clk),                      // mgmt_clk.clk
        .tx_out_clk         (alt_pma_0_tx_out_clk_clk),          // tx_out_clk.clk
        .rx_recovered_clk   (alt_pma_0_rx_recovered_clk_clk),    // rx_recovered_clk.clk
        .tx_parallel_data   (sxaui_0_tx_parallel_data_data),     // tx_parallel_data.data
        .rx_parallel_data   (alt_pma_0_rx_parallel_data_data),   // rx_parallel_data.data
        .rx_is_lockedtodata (alt_pma_0_rx_is_lockedtodata_data), // rx_is_lockedtodata.data
        .rx_digitalreset    (alt_pma_ch_controller_0_rx_digital_rst_data[0] ),                   // rx_digitalreset.from alt_pma
        .tx_digitalreset    (alt_pma_ch_controller_0_tx_digital_rst_data[0] ),                   // tx_digitalreset.from alt_pma
        .pll_locked         (pll_locked_data),                   // pll_locked.data
        .rx_syncstatus      (rx_syncstatus_data),                // rx_syncstatus.data
        .rx_channelaligned  (rx_channelaligned),                 // rx_channelaligned.data
        .rx_disperr         (rx_disperr_data),                   // rx_disperr.data
        .rx_errdetect       (rx_errdetect_data),                 // rx_errdetect.data
        .r_rx_digitalreset  (hxaui_csr_r_rx_digitalreset_data),  // r_rx_digitalreset.data
        .r_tx_digitalreset  (hxaui_csr_r_tx_digitalreset_data),  // r_tx_digitalreset.data
        .pma_stat_rst_done  (sxaui_rst_done),                    // soft reset done
        .simulation_flag    (hxaui_csr_simulation_flag_data)     // simulation_flag.data
      );
    end
    // don't instantiate anything if the interface type is invalid
  endgenerate

endmodule
