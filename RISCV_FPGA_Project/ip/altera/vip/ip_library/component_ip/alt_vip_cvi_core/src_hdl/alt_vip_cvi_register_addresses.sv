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


package alt_vip_cvi_register_addresses;

localparam REGISTER_GO_ADDR = 0;
localparam REGISTER_STATUS_ADDR = 1;
localparam REGISTER_INTERRUPT_ADDR = 2;
localparam REGISTER_USEDW_ADDR = 3;
localparam REGISTER_ACTIVE_SAMPLES_ADDR = 4;
localparam REGISTER_ACTIVE_LINES_F0_ADDR = 5;
localparam REGISTER_ACTIVE_LINES_F1_ADDR = 6;
localparam REGISTER_TOTAL_SAMPLES_ADDR = 7;
localparam REGISTER_TOTAL_LINES_F0_ADDR = 8;
localparam REGISTER_TOTAL_LINES_F1_ADDR = 9;
localparam REGISTER_STANDARD_ADDR = 10;
localparam REGISTER_COLOUR_PATTERN_ADDR = 14;
localparam REGISTER_ANC_BASE_ADDR = 15;

localparam STATUS_BIT_INTERLACED = 7;
localparam STATUS_BIT_STABLE = 8;
localparam STATUS_BIT_RES_VALID = 10;

endpackage
