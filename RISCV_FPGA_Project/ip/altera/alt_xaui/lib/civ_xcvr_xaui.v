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
// Description: hxaui static verilog for Cyclone IV GX
//
// Authors:     bauyeung    7-Sep-2010
//
//              Copyright (c) Altera Corporation 1997 - 2010
//              All rights reserved.
//
//-----------------------------------------------------------------------------

module civ_xcvr_xaui #(
  parameter device_family                = "Cyclone IV GX",
  parameter starting_channel_number      = 0,
  parameter interface_type               = "Hard XAUI",
  parameter number_of_interfaces         = 1,
  parameter sys_clk_in_mhz               = 50,
  parameter xaui_pll_type                = "CMU",
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
  parameter rx_eq_ctrl                   = 14
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
  output wire [16:0] reconfig_from_xcvr,      //   reconfig_from_xcvr_data
  input  wire [3:0]  reconfig_to_xcvr,        //   reconfig_to_xcvr_data
  output wire [3:0]  rx_recovered_clk,      //   rx recovered clock from cdr
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

  wire        alt_pma_controller_0_cal_blk_pdn_data;
  wire        alt_pma_controller_0_pll_pdn0_data;
  wire        alt_pma_controller_0_gx_pdn_data;
  wire        pll_locked_data;
  wire  [7:0] rx_disperr_data;
  wire  [7:0] rx_errdetect_data;
  wire  [7:0] rx_patterndetect_data;
  wire  [3:0] rx_phase_comp_fifo_error_data;
  wire  [3:0] rx_rlv_data;
  wire  [7:0] rx_rmfifodatadeleted_data;
  wire  [7:0] rx_rmfifodatainserted_data;
  wire  [3:0] rx_rmfifoempty_data;
  wire  [3:0] rx_rmfifofull_data;
  wire  [7:0] rx_runningdisp_data;
  wire  [7:0] rx_syncstatus_data;
  wire  [3:0] tx_phase_comp_fifo_error_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_set_locktodata_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_set_locktoref_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_seriallpbken_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_analog_rst_data;
  wire  [3:0] rx_is_lockedtodata_data;
  wire  [3:0] rx_is_lockedtoref_data;
  wire  [3:0] alt_pma_ch_controller_0_tx_digital_rst_data;
  wire  [3:0] alt_pma_ch_controller_0_rx_digital_rst_data;
  wire        hxaui_csr_r_rx_digitalreset_data;
  wire  [3:0] hxaui_csr_r_rx_invpolarity_data;
  wire        hxaui_csr_r_tx_digitalreset_data;
  wire  [3:0] hxaui_csr_r_tx_invpolarity_data;
  wire        alt_pma_controller_0_pll_pdn;
  wire  [3:0] alt_pma_0_tx_out_clk_clk;
  wire  [3:0] alt_pma_0_rx_recovered_clk_clk;
  wire [79:0] sxaui_0_tx_parallel_data_data;
  wire [79:0] alt_pma_0_rx_parallel_data_data;
  wire  [3:0] alt_pma_0_rx_is_lockedtodata_data;


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
  assign rx_is_lockedtodata       = rx_is_lockedtodata_data;
  assign rx_phase_comp_fifo_error = rx_phase_comp_fifo_error_data;
  assign rx_is_lockedtoref        = rx_is_lockedtoref_data;
  assign rx_rlv                   = rx_rlv_data;
  assign rx_rmfifoempty           = rx_rmfifoempty_data;
  assign rx_rmfifofull            = rx_rmfifofull_data;
  assign tx_phase_comp_fifo_error = tx_phase_comp_fifo_error_data;
  assign rx_disperr               = rx_disperr_data;
  assign rx_errdetect             = rx_errdetect_data; 
  assign rx_patterndetect         = rx_patterndetect_data;
  assign rx_rmfifodatadeleted     = rx_rmfifodatadeleted_data;
  assign rx_rmfifodatainserted    = rx_rmfifodatainserted_data;
  assign rx_runningdisp           = rx_runningdisp_data;
  assign rx_syncstatus            = rx_syncstatus_data;
  assign rx_recovered_clk         = alt_pma_0_rx_recovered_clk_clk;

  // assign output wires for external pma_ctrl - whether or not they are used will be decided by the top level
  assign pll_locked = pll_locked_data;

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
  // PMA Channel Controller - only for HXAUI
  ///////////////////////////////////////////////////////////////////////
// add generate for hxaui/sxaui - only use ch_controller for hxaui
  generate
    if (interface_type == "Hard XAUI") begin
      alt_pma_ch_controller_tgx #(
        .number_of_channels  (4),
        .sync_depth          (2),
        .sys_clk_in_mhz      (sys_clk_in_mhz)
      ) alt_pma_ch_controller_0 (
        .clk                 (phy_mgmt_clk),
        .rst                 (phy_mgmt_clk_reset),
        .ch_mgmt_address     (sc_pma_ch_controller_address),
        .ch_mgmt_read        (sc_pma_ch_controller_read),
        .ch_mgmt_readdata    (sc_pma_ch_controller_readdata),
        .ch_mgmt_write       (sc_pma_ch_controller_write),
        .ch_mgmt_writedata   (phy_mgmt_writedata),
        .ch_mgmt_waitrequest (sc_pma_ch_controller_waitrequest),
        .rx_pma_ready        (rx_ready),
        .tx_pma_ready        (tx_ready),
        .rx_is_lockedtodata  (rx_is_lockedtodata_data),
        .rx_is_lockedtoref   (rx_is_lockedtoref_data),
        .rx_set_locktodata   (alt_pma_ch_controller_0_rx_set_locktodata_data),
        .rx_set_locktoref    (alt_pma_ch_controller_0_rx_set_locktoref_data),
        .rx_seriallpbken     (alt_pma_ch_controller_0_rx_seriallpbken_data),
        .rx_analog_rst       (alt_pma_ch_controller_0_rx_analog_rst_data),
        .tx_digital_rst      (alt_pma_ch_controller_0_tx_digital_rst_data),
        .rx_digital_rst      (alt_pma_ch_controller_0_rx_digital_rst_data),
        .rx_rst_digital      (rx_digitalreset), // optional user triggered rx_digitalreset
        .tx_rst_digital      (tx_digitalreset), // optional user triggered tx_digitalreset
        //reconfig_to_xcvr bit configuration
        //Bit    |  Value
        //-------------------------------------------
        //3    |  offset_cancellation_is_busy  |
        //2   |  dprio_load         |
        //1   |  dprio_disable         |
        //0   |  dprio_in         |
        //-------------------------------------------
        //.rx_oc_busy          (reconfig_to_xcvr[3]), //     rx_oc_busy.data
        .rx_cal_busy         (reconfig_to_xcvr[3]),
        .tx_cal_busy         (1'b0),
        .pll_locked          (pll_locked_data)           
      );
    end
    // don't instantiate anything if the interface type is invalid
  endgenerate

  ///////////////////////////////////////////////////////////////////////
  // PMA Controller
  ///////////////////////////////////////////////////////////////////////
  generate 
    if (external_pma_ctrl_reconf == 0) begin
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
        .gx_pdn               (alt_pma_controller_0_gx_pdn_data),     
        .pll_pdn              (alt_pma_controller_0_pll_pdn0_data),
        .pll_locked           (pll_locked_data)                  
      );
    end else begin
      assign alt_pma_controller_0_cal_blk_pdn_data = cal_blk_powerdown;
      assign alt_pma_controller_0_gx_pdn_data      = gxb_powerdown;
      assign alt_pma_controller_0_pll_pdn0_data    = pll_powerdown;
    end
  endgenerate


  ///////////////////////////////////////////////////////////////////////
  // HXAUI CSR
  ///////////////////////////////////////////////////////////////////////
// should be consistent across all device families and interface types
// -might need a generate statement for some of the connections that don't exist between hxaui/sxaui
  hxaui_csr hxaui_csr (
    .clk                      (phy_mgmt_clk),
    .reset                    (phy_mgmt_clk_reset),
    .address                  (sc_csr_address),
    .byteenable               (4'b1111),   // .byteenable (Tie byteenable to all 1s)
    .read                     (sc_csr_read),
    .readdata                 (sc_csr_readdata),
    .write                    (sc_csr_write),
    .writedata                (phy_mgmt_writedata),
    .rx_patterndetect         (rx_patterndetect_data),
    .rx_syncstatus            (rx_syncstatus_data),
    .rx_runningdisp           (rx_runningdisp_data),
    .rx_errdetect             (rx_errdetect_data),
    .rx_disperr               (rx_disperr_data),
    .rx_phase_comp_fifo_error (rx_phase_comp_fifo_error_data),
    .rx_rlv                   (rx_rlv_data),
    .rx_rmfifodatadeleted     (rx_rmfifodatadeleted_data),
    .rx_rmfifodatainserted    (rx_rmfifodatainserted_data),
    .rx_rmfifoempty           (rx_rmfifoempty_data),
    .rx_rmfifofull            (rx_rmfifofull_data),
    .tx_phase_comp_fifo_error (tx_phase_comp_fifo_error_data),
    .r_rx_invpolarity         (hxaui_csr_r_rx_invpolarity_data),
    .r_tx_invpolarity         (hxaui_csr_r_tx_invpolarity_data),
    .r_rx_digitalreset        (hxaui_csr_r_rx_digitalreset_data),
    .r_tx_digitalreset        (hxaui_csr_r_tx_digitalreset_data),
    .simulation_flag          () // only for soft_xaui
  );


  ///////////////////////////////////////////////////////////////////////
  // HXAUI - Interface to alt4gxb megafunction block
  ///////////////////////////////////////////////////////////////////////
// need to add generate to pick between sxaui and hxaui
  generate
    if (interface_type == "Hard XAUI") begin
      (* ALTERA_ATTRIBUTE = {"-name SDC_STATEMENT \"set_false_path -from [get_registers *hxaui_0*hxaui_alt_c3gxb*hxaui_alt_c3gxb_alt_c3gxb_component*] -to [get_registers *xaui_phy*hxaui_csr*rx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers *hxaui_0*hxaui_alt_c3gxb*hxaui_alt_c3gxb_alt_c3gxb_component*] -to [get_registers *xaui_phy*hxaui_csr*tx*_c[*]]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*xaui_phy*hxaui_csr*hxaui_csr_reset0q[*]}] -to  [get_registers {*xaui_phy*hxaui_0*hxaui_alt_c3gxb*hxaui_alt_c3gxb_alt_c3gxb_component|*pcs*}]\" ;-name SDC_STATEMENT \"set_false_path -from [get_registers {*xaui_phy*alt_pma_ch_controller_0*rc*}] -to  [get_registers {*xaui_phy*hxaui_0*hxaui_alt_c3gxb*hxaui_alt_c3gxb_alt_c3gxb_component|*pcs*}]\""} *)
      hxaui #(
        .device_family                (device_family),
        .starting_channel_number      (starting_channel_number),
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
      ) hxaui_0 (
        .xgmii_tx_clk                 (xgmii_tx_clk),
        .xgmii_tx_dc                  (xgmii_tx_dc),
        .xgmii_rx_clk                 (xgmii_rx_clk),
        .xgmii_rx_dc                  (xgmii_rx_dc),
        .refclk                       (pll_ref_clk),
        .xaui_tx_serial               (xaui_tx_serial_data),
        .xaui_rx_serial               (xaui_rx_serial_data),
        .rx_analogreset               (rx_analogreset),                // use_cs_ports, input
        .rx_digitalreset              (alt_pma_ch_controller_0_rx_digital_rst_data),
        .tx_digitalreset              (alt_pma_ch_controller_0_tx_digital_rst_data),
        .rx_channelaligned            (rx_channelaligned),             // use_cs_ports, output
        .rx_invpolarity               (rx_invpolarity),                // use_cs_ports, input
        .rx_set_locktodata            (rx_set_locktodata),             // use_cs_ports, input
        .rx_set_locktoref             (rx_set_locktoref),              // use_cs_ports, input
        .rx_seriallpbken              (rx_seriallpbken),               // use_cs_ports, input
        .tx_invpolarity               (tx_invpolarity),                // use_cs_ports, input
        .rx_is_lockedtodata           (rx_is_lockedtodata_data),       // use_cs_ports, output  
        .rx_phase_comp_fifo_error     (rx_phase_comp_fifo_error_data), // use_cs_ports, output
        .rx_is_lockedtoref            (rx_is_lockedtoref_data),        // use_cs_ports, output
        .rx_rlv                       (rx_rlv_data),                   // use_cs_ports, output
        .rx_rmfifoempty               (rx_rmfifoempty_data),           // use_cs_ports, output
        .rx_rmfifofull                (rx_rmfifofull_data),            // use_cs_ports, output
        .tx_phase_comp_fifo_error     (tx_phase_comp_fifo_error_data), // use_cs_ports, output
        .rx_disperr                   (rx_disperr_data),               // use_cs_ports, output
        .rx_errdetect                 (rx_errdetect_data),             // use_cs_ports, output
        .rx_patterndetect             (rx_patterndetect_data),         // use_cs_ports, output
        .rx_rmfifodatadeleted         (rx_rmfifodatadeleted_data),     // use_cs_ports, output
        .rx_rmfifodatainserted        (rx_rmfifodatainserted_data),    // use_cs_ports, output
        .rx_runningdisp               (rx_runningdisp_data),           // use_cs_ports, output
        .rx_syncstatus                (rx_syncstatus_data),            // use_cs_ports, output
        .reconfig_clk                 (phy_mgmt_clk),
        .reconfig_togxb               (reconfig_to_xcvr),  // external_pma_ctrl_reconf
        .reconfig_fromgxb             (reconfig_from_xcvr), // external_pma_ctrl_reconf
        .cal_blk_clk                  (phy_mgmt_clk),
        .cal_blk_powerdown            (1'b0), // not used, should remove
        .gxb_powerdown                (1'b0), // not used, should remove
        .pll_powerdown                (1'b0), // not used, should remove
        .pll_locked                   (pll_locked_data),
        .r_cal_blk_powerdown          (alt_pma_controller_0_cal_blk_pdn_data),
        .r_gxb_powerdown              (alt_pma_controller_0_gx_pdn_data),
        .r_pll_powerdown              (alt_pma_controller_0_pll_pdn0_data),
        .r_rx_set_locktodata          (alt_pma_ch_controller_0_rx_set_locktodata_data),
        .r_rx_set_locktoref           (alt_pma_ch_controller_0_rx_set_locktoref_data),
        .r_rx_seriallpbken            (alt_pma_ch_controller_0_rx_seriallpbken_data),
        .r_rx_analogreset             (alt_pma_ch_controller_0_rx_analog_rst_data),
        .r_rx_digitalreset            (hxaui_csr_r_rx_digitalreset_data), 
        .r_tx_digitalreset            (hxaui_csr_r_tx_digitalreset_data),
        .r_rx_invpolarity             (hxaui_csr_r_rx_invpolarity_data),
        .r_tx_invpolarity             (hxaui_csr_r_tx_invpolarity_data)
      );
    end
    // don't instantiate anything if the interface type is invalid
  endgenerate

endmodule
