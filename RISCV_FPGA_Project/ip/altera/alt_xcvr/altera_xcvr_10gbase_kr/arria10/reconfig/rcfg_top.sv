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

//============================================================================
// Reconfig Top
// Contains the reconfiguration logic for PCS and PMA reconfiguration
// for a single channel via an Avalon-MM interface
//============================================================================

`timescale 1 ps / 1 ps

module rcfg_top
    #(
  parameter SYNTH_LT         = 1,       // Synthesize/include the LT module
  parameter SYNTH_AN_LT      = 1,       // Synthesize/include the AN or LT
  parameter SYNTH_GIGE       = 1,       // Synthesize/include the GIGE logic
  parameter SYNTH_FEC        = 1,       // Synthesize/include the FEC logic
  parameter SYNTH_1588       = 1,       // Synthesize/include the 1588 mode
  parameter REF_CLK_644      = 1        // CDR Reference clock = 644, else 322
    ) (
  input  wire           mgmt_clk,       // managemnt/reconfig clock
  input  wire           mgmt_clk_reset, // managemnt/reconfig reset
     // PCS reconfig requests
  input  wire           seq_start_rc,   // start the PCS reconfig
  input  wire [5:0]     pcs_mode_rc,    // PCS mode for reconfig - 1 hot
                                        // bit 0 = AN mode = low_lat, PLL LTR
                                        // bit 1 = LT mode = low_lat, PLL LTD
                                        // bit 2 = 10G data mode = 10GBASE-R
                                        // bit 3 = GigE data mode = 8G PCS
                                        // bit 4 = XAUI data mode = future?
                                        // bit 5 = 10G-FEC
  output reg            rc_busy,        // reconfig is busy
  input  wire           skip_cal,       // skip the calibration
     // PMA reconfig requests
  input  wire            lt_start_rc,   // start the TX EQ reconfig
  input  wire [5:0]      main_rc,       // main tap value for reconfig
  input  wire [5:0]      post_rc,       // post tap value for reconfig
  input  wire [4:0]      pre_rc,        // pre tap value for reconfig
  input  wire [2:0]      tap_to_upd,    // specific TX EQ tap to update
                                        // bit-2 = main, bit-1 = post, ...
  input  wire            dfe_start_rc,  // start the RX DFE EQ reconfig
  input  wire [1:0]      dfe_mode,      // DFE mode for reconfig
  input  wire            ctle_start_rc, // start the RX DFE EQ reconfig
  input  wire [1:0]      ctle_mode,     // CTLE mode for reconfig
  input  wire [3:0]      ctle_rc,       // CTLE manual reconfig value
     // HSSI control
  input  wire       calibration_busy,  // HSSI cal busy
  output reg        analog_reset,      // HSSI reset
  output reg        digital_reset,     // HSSI rest
     // HSSI Reconfig master
  output wire            xcvr_rcfg_write,   // AVMM write
  output wire            xcvr_rcfg_read,    // AVMM read
  output wire [9:0]      xcvr_rcfg_address, // AVMM address
  output wire [7:0]      xcvr_rcfg_wrdata,  // AVMM write data
  input  wire [7:0]      xcvr_rcfg_rddata,  // AVMM read data
  input  wire            xcvr_rcfg_wtrqst   // AVMM wait request
  );


//===========================================================================
// Define Wires and Variables
//===========================================================================

     //  PCS Controllers
  wire [9:0]      pcs_addr;
  wire [7:0]      pcs_writedata;
  wire            pcs_write;
  wire            refclk_req;
  wire            cgb_req;
  wire            refclk_sel;
  wire            cgb_sel;
  wire            pcs_rc_busy;
     //  Reconfig data
  wire            last_data;
  wire [5:0]      pcs_data_addr;
  wire            en_next;
     //  PMA Controller
  wire            pma_rc_busy;
  wire            pma_write;
  wire [9:0]      pma_addr;
  wire [7:0]      pma_writedata;
     //  AVMM signals 
  wire [9:0]      ctrl_addr;
  wire [7:0]      ctrl_writedata;
  wire [7:0]      ctrl_datamask;
  wire            ctrl_write;
  wire            ctrl_rmw;

//===========================================================================
// Combine the signals
//===========================================================================
  assign rc_busy    = pcs_rc_busy | pma_rc_busy;
  assign ctrl_write = pcs_write   | pma_write;
  assign ctrl_addr  = pcs_addr    | pma_addr;
  assign ctrl_writedata  = pcs_writedata    | pma_writedata;

//===========================================================================
// Instantiate the PMA TX controllers
//===========================================================================
generate
  if (SYNTH_LT) begin: PMA_RC
    wire       lt_rc_busy, dfe_rc_busy, ctle_rc_busy;
    wire       txeq_write, dfe_write,   ctle_write;
    wire [9:0] txeq_addr,  dfe_addr,    ctle_addr;
    wire [7:0] txeq_writedata, dfe_writedata, ctle_writedata;

    // TX Equalization
    rcfg_txeq_ctrl  rcfg_txeq_ctrl_inst (
      .clk            (mgmt_clk),
      .reset          (mgmt_clk_reset),
        // PCS reconfig requests
      .lt_start_rc   (lt_start_rc),
      .main_rc       (main_rc),
      .post_rc       (post_rc),
      .pre_rc        (pre_rc),
      .tap_to_upd    (tap_to_upd),
      .rc_busy       (lt_rc_busy),
        // HSSI
      .rcfg_wtrqst    (xcvr_rcfg_wtrqst),
        // AVMM master
      .ctrl_addr      (txeq_addr),
      .ctrl_writedata (txeq_writedata),
      .ctrl_write     (txeq_write),
      .ctrl_busy      (ctrl_busy)
    );

    // RX DFE
    rcfg_dfe_ctrl  rcfg_dfe_ctrl_inst (
      .clk            (mgmt_clk),
      .reset          (mgmt_clk_reset),
        // PCS reconfig requests
      .dfe_start_rc   (dfe_start_rc),
      .dfe_mode       (dfe_mode),
      .rc_busy        (dfe_rc_busy),
        // HSSI
      .rcfg_wtrqst    (xcvr_rcfg_wtrqst),
        // AVMM master
      .ctrl_addr      (dfe_addr),
      .ctrl_writedata (dfe_writedata),
      .ctrl_write     (dfe_write),
      .ctrl_busy      (ctrl_busy)
    );

    // RX CTLE
    rcfg_ctle_ctrl  rcfg_ctle_ctrl_inst (
      .clk            (mgmt_clk),
      .reset          (mgmt_clk_reset),
        // PCS reconfig requests
      .ctle_start_rc  (ctle_start_rc),
      .ctle_mode      (ctle_mode),
      .ctle_rc        (ctle_rc),
      .rc_busy        (ctle_rc_busy),
        // HSSI
      .rcfg_wtrqst    (xcvr_rcfg_wtrqst),
        // AVMM master
      .ctrl_addr      (ctle_addr),
      .ctrl_writedata (ctle_writedata),
      .ctrl_write     (ctle_write),
      .ctrl_busy      (ctrl_busy)
    );

    assign pma_rc_busy = lt_rc_busy | dfe_rc_busy | ctle_rc_busy;
    assign pma_addr    = txeq_addr  | dfe_addr    | ctle_addr;
    assign pma_write   = txeq_write | dfe_write   | ctle_write;
    assign pma_writedata = txeq_writedata | dfe_writedata | ctle_writedata;
  end // PMA_RC
  else begin: NO_PMA
    assign pma_rc_busy = 1'b0;
    assign pma_addr    = 10'b0;
    assign pma_write   = 1'b0;
    assign pma_writedata  = 8'b0;
  end
endgenerate

//===========================================================================
// Instantiate the PCS controller
//===========================================================================
rcfg_pcs_ctrl  rcfg_pcs_ctrl_inst (
  .clk            (mgmt_clk),
  .reset          (mgmt_clk_reset),
    // PCS reconfig requests
  .seq_start_rc   (seq_start_rc),
  .pcs_mode_rc    (pcs_mode_rc[4:3]),
  .rc_busy        (pcs_rc_busy),
  .skip_cal       (skip_cal),
    // to the AVMM master
  .ctrl_busy      (ctrl_busy),
  .refclk_req     (refclk_req),
  .cgb_req        (cgb_req),
  .cal_req        (cal_req),
  .refclk_sel     (refclk_sel),
  .cgb_sel        (cgb_sel),
  .cal_sel        (cal_sel),
  .rcfg_wtrqst    (xcvr_rcfg_wtrqst),
    // HSSI control
  .calibration_busy  (calibration_busy),
  .analog_reset      (analog_reset),
  .digital_reset     (digital_reset),
    // Reconfig Data
  .last_data      (last_data),
  .pcs_data_addr  (pcs_data_addr),
  .en_next        (en_next)
);

//===========================================================================
// Instantiate the Reconfig data
// have 8 different images depending upon the modes
// Some images have 3 sets of data, some have 4 depending upon FEC
// Images may have 2 copies of the data sets, one with AN/LT and one without
//===========================================================================
`define ALTERA_XCVR_KR_RCFG_DATA_PORTS                       \
        (                                                    \
       .pcs_data_addr    (pcs_data_addr),                    \
       .pcs_mode_rc      (pcs_mode_rc),                      \
       .rcfg_addr        (pcs_addr),                         \
       .rcfg_data        (pcs_writedata),                    \
       .rcfg_mask        (ctrl_datamask)                     \
        );

generate
   if          (!SYNTH_FEC &&  SYNTH_1588 &&  REF_CLK_644) begin : data_1588_644
     rcfg_data_1588_644 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_1588_644_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else if (!SYNTH_FEC &&  SYNTH_1588 && !REF_CLK_644) begin : data_1588_322
     rcfg_data_1588_322 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_1588_322_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else if (!SYNTH_FEC && !SYNTH_1588 &&  REF_CLK_644) begin : data_644
     rcfg_data_644 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_644_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else if (!SYNTH_FEC && !SYNTH_1588 && !REF_CLK_644) begin : data_322
     rcfg_data_322 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_322_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else if ( SYNTH_FEC && !SYNTH_1588 &&  REF_CLK_644) begin : data_fec_644
     rcfg_data_fec_644 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_fec_644_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else if ( SYNTH_FEC && !SYNTH_1588 && !REF_CLK_644) begin : data_fec_322
     rcfg_data_fec_322 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_fec_322_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else if ( SYNTH_FEC &&  SYNTH_1588 &&  REF_CLK_644) begin : data_fec1588_644
     rcfg_data_fec1588_644 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_fec1588_644_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else if ( SYNTH_FEC &&  SYNTH_1588 && !REF_CLK_644) begin : data_fec1588_322
     rcfg_data_fec1588_322 #(.SYNTH_AN_LT (SYNTH_AN_LT)) rcfg_data_fec1588_322_inst
     `ALTERA_XCVR_KR_RCFG_DATA_PORTS
   end else begin
     assign pcs_addr  = 10'h3ff;
     assign pcs_writedata  = 8'b0;
     assign ctrl_datamask  = 8'b0;
   end
endgenerate

  // need to condition the controls to the AVMM master
  assign last_data  = (pcs_addr == 10'h3ff);
  assign pcs_write  = en_next & ~last_data && (ctrl_datamask == 8'hFF);
  assign ctrl_rmw   = en_next & ~last_data && (ctrl_datamask != 8'hFF);

//===========================================================================
// Instantiate the AVMM master State Machine
//===========================================================================
rcfg_avmm_mstr  rcfg_avmm_mstr_inst (
  .clk            (mgmt_clk),
  .reset          (mgmt_clk_reset),
    //  from the Controllers
  .ctrl_addr      (ctrl_addr),
  .ctrl_writedata (ctrl_writedata),
  .ctrl_datamask  (ctrl_datamask),
  .ctrl_write     (ctrl_write),
  .ctrl_rmw       (ctrl_rmw),
  .ctrl_busy      (ctrl_busy),
  .refclk_req     (refclk_req),
  .cgb_req        (cgb_req),
  .cal_req        (cal_req),
  .refclk_sel     (refclk_sel),
  .cgb_sel        (cgb_sel),
  .cal_sel        (cal_sel),
    // HSSI Reconfig master
  .xcvr_rcfg_write    (xcvr_rcfg_write),
  .xcvr_rcfg_read     (xcvr_rcfg_read),
  .xcvr_rcfg_address  (xcvr_rcfg_address),
  .xcvr_rcfg_wrdata   (xcvr_rcfg_wrdata),
  .xcvr_rcfg_rddata   (xcvr_rcfg_rddata),
  .xcvr_rcfg_wtrqst   (xcvr_rcfg_wtrqst)
);

endmodule // rcfg_top
