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


`ifndef TESTBENCH_DEFS_INC

`define TESTBENCH_DEFS_INC

// Assorted defines
`define  NULL                             0

// Burst descriptor type field enumeration
`define  BURST_DESCR_START_END            8'd0
`define  BURST_DESCR_START                8'd1
`define  BURST_DESCR_END                  8'd2
`define  BURST_DESCR_STALL                8'd3

`endif   // TESTBENCH_DEFS_INC
