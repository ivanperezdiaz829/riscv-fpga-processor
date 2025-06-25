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
// Description: soft xaui pcs
//
// Authors:     ishimony    14-Jan-2009
//              hhleong		11-Jan-2013
//
//              Copyright (c) Altera Corporation 1997 - 2009
//              All rights reserved.
//
//
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module sxaui #(

 // module sxaui

// parameters --------------------------------------------------------------
parameter     starting_channel_number        = 0,
parameter     xaui_pll_type                  = "CMU",  // values: CMU/LCTANK
parameter     use_control_and_status_ports   = "true",
parameter     soft_pcs_legacy_new_n = 1
// ports -------------------------------------------------------------------
)(
// xgmii
input   wire       xgmii_tx_clk,
input   wire[71:0] xgmii_tx_dc,
output  wire       xgmii_rx_clk,
output  wire[71:0] xgmii_rx_dc,

// pma
input   wire        refclk,
input   wire        mgmt_clk,
input   wire [3:0]  tx_out_clk,
input   wire [3:0]  rx_recovered_clk,
output  wire [79:0] tx_parallel_data,
input   wire [79:0] rx_parallel_data,
input   wire [3:0]  rx_is_lockedtodata,

// ctrl_stat: control and status
input   wire       rx_digitalreset,
input   wire       tx_digitalreset,     //nc in sxaui
input   wire       pll_locked,
output  wire [7:0]  rx_syncstatus,
input   wire [7:0]  hard_pcs_rx_syncstatus,
output  wire       rx_channelaligned,
output  wire [7:0] rx_disperr,
output  wire [7:0] rx_errdetect,

// register file version
input   wire       r_rx_digitalreset,
input   wire       r_tx_digitalreset,
output  wire       pma_stat_rst_done,

input   wire       simulation_flag     // '1' shortens reset and loss_timer length

);


// locals ------------------------------------------------------------------
wire        [7:0] xgmii_tx_c;
wire       [63:0] xgmii_tx_d;
wire        [7:0] xgmii_rx_c;
wire       [63:0] xgmii_rx_d;

// local version
wire              l_rx_digitalreset;


// soft xaui signals -------------------------------------------------------
wire      [63:0] xgmii_tx_datain;            // input
wire       [7:0] xgmii_tx_ctrlin;            // input
wire      [63:0] xgmii_rx_dataout;           // output
wire       [7:0] xgmii_rx_ctrlout;           // output
wire             reset_n;                    // input
wire       [3:0] pma_tx_dataout;             // output
//wire           pma_gxb_powerdown;          // input
wire             phy_mgmt_clk;              // input
wire             pma_reconfig_clk;           // input
wire       [3:0] pma_reconfig_togxb;         // input
wire      [16:0] pma_reconfig_fromgxb;       // output
wire             pma_pll_locked;             // output
wire      [3:0]  pma_rx_clkout;              // output   nc: ///
wire      [3:0]  pma_tx_clkout;              // output   nc: ///
wire             pma_rx_analogreset;
wire      [79:0] pma_pcs_tx_data; //Data from TX soft PCS to PMA
wire      [79:0] pma_pcs_rx_data; //Data from PMA to RX soft PCS
wire       [3:0] pma_rx_is_lockedtodata;

// output: this is high per lane if the synchronization has been met. As we
// only have 4 lanes, we will double their value
//wire       [7:0] pcs_rx_syncstatus;
// output: this is high if the channel aligner (resynch) has aligned all
// the lanes and the correct number of align characters have been received
wire             pcs_rx_channelaligned;
// output: this is high if a disparity error has occured
wire       [7:0] pcs_rx_disperr;
// output: this is high if an invalid character has been detected.
wire       [7:0] pcs_rx_errdetect;

// body --------------------------------------------------------------------

// Convert to/from Avalon Streaming Interface single bus to data + control
genvar         g;
generate
    for (g = 0; g < 8; g = g + 1) begin : st_to_dc_b
        assign xgmii_tx_d [g*8 +: 8] = xgmii_tx_dc[g*9 +: 8];
        assign xgmii_tx_c [g]        = xgmii_tx_dc[g*9 + 8];
        assign xgmii_rx_dc[g*9 +: 8] = xgmii_rx_d [g*8 +: 8];
        assign xgmii_rx_dc[g*9 + 8]  = xgmii_rx_c [g];
    end
endgenerate

// Default values in case ports are not and without control/status registers
generate
    if (use_control_and_status_ports == "true") begin: use_cs_ports_true
        assign l_rx_digitalreset   = rx_digitalreset   | r_rx_digitalreset;
    end else begin: use_cs_ports_false
        assign l_rx_digitalreset   = r_rx_digitalreset;
    end
endgenerate

// soft xaui ---------------------------------------------------------------

 // translate signal names
assign xgmii_tx_datain              = xgmii_tx_d;
assign xgmii_tx_ctrlin              = xgmii_tx_c;
assign xgmii_rx_d                   = xgmii_rx_dataout;
assign xgmii_rx_c                   = xgmii_rx_ctrlout;

assign tx_parallel_data             = pma_pcs_tx_data;
assign pma_pcs_rx_data              = rx_parallel_data;
assign pma_tx_clkout                = tx_out_clk;
assign pma_rx_clkout                = rx_recovered_clk;
assign pma_rx_is_lockedtodata       = rx_is_lockedtodata;

assign reset_n                      = ~l_rx_digitalreset;
assign pma_pll_locked               = pll_locked;

//assign rx_syncstatus                = soft_pcs_rx_syncstatus;
assign rx_channelaligned            = pcs_rx_channelaligned;
assign rx_disperr                   = pcs_rx_disperr;
assign rx_errdetect                 = pcs_rx_errdetect;

//assign pma_gxb_powerdown           = 1'b0;

// soft pcs
generate
  if (soft_pcs_legacy_new_n) begin: leg_soft_pcs

     assign phy_mgmt_clk                 = refclk;

     alt_soft_xaui_pcs #(
       .soft_pcs_legacy_new_n (soft_pcs_legacy_new_n)
      ) alt_soft_xaui_pcs (
         .xgmii_tx_datain        (xgmii_tx_datain),                 // i
         .xgmii_tx_ctrlin        (xgmii_tx_ctrlin),                 // i
         .xgmii_rx_dataout       (xgmii_rx_dataout),                 // o
         .xgmii_rx_ctrlout       (xgmii_rx_ctrlout),                 // o
         .xgmii_tx_clk           (xgmii_tx_clk),                     // i - must be tied to xgmii_rx_clk at top level, only for interface consistency does this exist
         .sysclk                 (xgmii_rx_clk),                     // o
         .reset_n                (reset_n),                          // i
//  .pma_rx_datain          (pma_rx_datain),                    // i
     //  .pma_tx_dataout         (pma_tx_dataout),                   // o
     //  .pma_cal_blk_clk        (pma_cal_blk_clk),                  // i
     //  .pma_gxb_powerdown      (pma_gxb_powerdown),                // i
         .pma_pll_inclk          (phy_mgmt_clk),                    // i 
     //  .pma_reconfig_clk       (pma_reconfig_clk),                 // i
     //  .pma_reconfig_togxb     (pma_reconfig_togxb),               // i
     //  .pma_reconfig_fromgxb   (pma_reconfig_fromgxb),             // o
         .pma_pll_locked         (pma_pll_locked),                   // i
     //  .pma_rx_pll_locked      (pma_rx_is_lockedtoref),            // i
         .pma_rx_freqlocked      (pma_rx_is_lockedtodata),           // i
         .pma_stat_rst_done      (pma_stat_rst_done),                // o
         .pma_rx_clkout          (pma_rx_clkout),                    // i
         .pma_tx_clkout          (pma_tx_clkout),                    // i 
         .soft_pcs_rx_syncstatus      (rx_syncstatus),                // o
         .pcs_rx_channelaligned  (pcs_rx_channelaligned),            // o
         .pcs_rx_disperr         (pcs_rx_disperr),                   // o
         .pcs_rx_errdetect       (pcs_rx_errdetect),                 // o
         .pma_rx_analogreset     (pma_rx_analogreset),               // o
         .pma_pcs_tx_data        (pma_pcs_tx_data),                  // o
         .pma_pcs_rx_data        (pma_pcs_rx_data),                  // i
         .simulation_flag        (simulation_flag)                   // i
     ); // module alt_soft_xaui_pcs

end  // if leg_soft_pcs
  else begin: imp_soft_pcs  //

     assign phy_mgmt_clk                 = mgmt_clk;
     
     alt_soft_xaui_pcs #(
       .soft_pcs_legacy_new_n (soft_pcs_legacy_new_n)
      ) alt_soft_xaui_pcs(
         .xgmii_tx_datain        (xgmii_tx_datain),                 // i
         .xgmii_tx_ctrlin        (xgmii_tx_ctrlin),                 // i
         .xgmii_rx_dataout       (xgmii_rx_dataout),                 // o
         .xgmii_rx_ctrlout       (xgmii_rx_ctrlout),                 // o
         .xgmii_tx_clk           (xgmii_tx_clk),                     // i - must be tied to xgmii_rx_clk at top level, only for interface consistency does this exist
         .sysclk                 (xgmii_rx_clk),                     // o
         .reset_n                (reset_n),                          // i
//  .pma_rx_datain          (pma_rx_datain),                    // i
     //  .pma_tx_dataout         (pma_tx_dataout),                   // o
     //  .pma_cal_blk_clk        (pma_cal_blk_clk),                  // i
     //  .pma_gxb_powerdown      (pma_gxb_powerdown),                // i
         .pma_pll_inclk          (phy_mgmt_clk),                    // i 
     //  .pma_reconfig_clk       (pma_reconfig_clk),                 // i
     //  .pma_reconfig_togxb     (pma_reconfig_togxb),               // i
     //  .pma_reconfig_fromgxb   (pma_reconfig_fromgxb),             // o
         .pma_pll_locked         (pma_pll_locked),                   // i
     //  .pma_rx_pll_locked      (pma_rx_is_lockedtoref),            // i
         .pma_rx_freqlocked      (pma_rx_is_lockedtodata),           // i
         .pma_stat_rst_done      (pma_stat_rst_done),                // o
         .pma_rx_clkout          (pma_rx_clkout),                    // i
         .pma_tx_clkout          (pma_tx_clkout),                    // i 
         .hard_pcs_rx_syncstatus      (hard_pcs_rx_syncstatus),                // o
         .pcs_rx_channelaligned  (pcs_rx_channelaligned),            // o
         .pcs_rx_disperr         (pcs_rx_disperr),                   // o
         .pcs_rx_errdetect       (pcs_rx_errdetect),                 // o
         .pma_rx_analogreset     (pma_rx_analogreset),               // o
         .pma_pcs_tx_data        (pma_pcs_tx_data),                  // o
         .pma_pcs_rx_data        (pma_pcs_rx_data),                  // i
         .simulation_flag        (simulation_flag)                   // i
     ); // module alt_soft_xaui_pcs

end 
endgenerate

endmodule

