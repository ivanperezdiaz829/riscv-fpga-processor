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



// lanny - 12-05-2011 Adapter seperation

`timescale 1ps / 1ps

module alt_e100_adapter_rx #(

    parameter DEVICE_FAMILY = "Stratix V"
)(
    input   mac_rx_arst_sync_core,
    input   clk_rxmac,    // MAC + PCS clock - at least 312.5Mhz
    
    output  [511:0] l8_rx_data,
    output  [5  :0] l8_rx_empty,
    output  l8_rx_startofpacket,
    output  l8_rx_endofpacket,
    output  l8_rx_error,
    output  l8_rx_fcs_valid,
    output  l8_rx_fcs_error,
    output  l8_rx_valid,

    
    input   [5*64-1:0] rx5l_d,        // 5 lane payload to send
    input   [5   -1:0] rx5l_sop,      // 5 lane start position
    input   [5*8 -1:0] rx5l_eop_bm,   // 5 lane end position, any byte
    input              rx5l_valid,    // payload is accepted
    input   [5   -1:0] rx5l_runt_last_data,
    input   [5   -1:0] rx5l_payload,
    input              rx5l_fcs_valid,
    input              rx5l_fcs_error
);

// local ---------------------------------------------------------------------
wire     [8*64-1:0] rx8l_d;        // 8 lane payload data
wire                rx8l_sop;
wire                rx8l_eop;
wire          [5:0] rx8l_empty;
wire                rx8l_error;
wire                rx8l_wrfull;
wire                rx8l_wrreq;
wire                rx8l_fcs_valid;
wire                rx8l_fcs_error;

// 5 lanes to 8 conversion ---------------------------------------------------
alt_e100_wide_l8if_rx528 alt_e100_wide_l8if_rx528(
    .arst           (mac_rx_arst_sync_core), //i
    .clk_rxmac      (clk_rxmac),      // i
    .rx8l_d         (rx8l_d),         // o
    .rx8l_sop       (rx8l_sop),       // o
    .rx8l_eop       (rx8l_eop),       // o
    .rx8l_empty     (rx8l_empty),     // o
    .rx8l_error     (rx8l_error),     // o
    .rx8l_fcs_valid (rx8l_fcs_valid), // o
    .rx8l_fcs_error (rx8l_fcs_error), // o
    .rx8l_wrfull    (1'b0),           // i
    .rx8l_wrreq     (rx8l_wrreq),     // o
    .rx5l_d         (rx5l_d),         // i
    .rx5l_sop       (rx5l_sop),       // i
    .rx5l_eop_bm    (rx5l_eop_bm),    // i
    .rx5l_valid     (rx5l_valid & (|rx5l_payload)),     // i
    .rx5l_fcs_valid (rx5l_fcs_valid), // i
    .rx5l_fcs_error (rx5l_fcs_error), // i
    .rx5l_error     ((|rx5l_runt_last_data) | (rx5l_fcs_valid & rx5l_fcs_error ))      // i
); // module l8if_825
    defparam alt_e100_wide_l8if_rx528 .DEVICE_FAMILY = DEVICE_FAMILY;


assign l8_rx_fcs_valid     = rx8l_fcs_valid;
assign l8_rx_fcs_error     = rx8l_fcs_error;
assign l8_rx_error         = rx8l_error;
assign l8_rx_startofpacket = rx8l_sop;
assign l8_rx_endofpacket   = rx8l_eop;
assign l8_rx_empty         = rx8l_empty & {6{rx8l_eop}};
assign l8_rx_data          = rx8l_d;

// WAS rx fifo -------------------------------------------------------------------
assign l8_rx_valid = rx8l_wrreq;

endmodule
