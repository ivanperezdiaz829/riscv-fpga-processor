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



`define _NOP 16'h0000 
`define _EXIT 16'hFFFF 
`define _WRITE 4'h1 
`define _W_DQS 1'b0 
`define _W_SIDE 1'b1 
`define _W_SEQ 2'b00
`define _W_RAND 2'b01
`define _READ 4'h2 
`define _R_CMP_SKIP 1'b1 
`define _R_CMP_DO 1'b0 
`define _R_DQS 1'b0 
`define _R_SIDE 1'b1 
`define _ZERO 1'b1 
`define _CALIB 4'h3 

localparam CALIB_VALUE = (USE_BIDIR_STROBE == "true") ? 
                            ((HALF_RATE_CIRCUITRY == "true") ? 4'h2 : 4'h4) :
                            ((HALF_RATE_CIRCUITRY == "true") ? 4'h5 : 4'h7);
														
localparam _PC_WIDTH = 5;
localparam _MICROCODE_DEPTH = 2 ** _PC_WIDTH;
reg [15:0] microcode [0 : _MICROCODE_DEPTH - 1] = '{
	`_NOP,
	{ CALIB_VALUE , {8{`_ZERO}} , `_CALIB }, 
	`_NOP,
	{ 4'h5 , {5{`_ZERO}} , `_W_DQS , `_W_RAND , `_WRITE }, 
	`_NOP,
	`_NOP,
	{ 4'h5 , {5{`_ZERO}} , `_R_SIDE , `_R_CMP_DO , `_ZERO , `_READ }, 
	`_NOP,
	{ 4'h6 , {5{`_ZERO}} , `_W_SIDE , `_W_RAND , `_WRITE }, 
	`_NOP,
	`_NOP,
	{ 4'h6 , {5{`_ZERO}} , `_R_DQS , `_R_CMP_DO , `_ZERO , `_READ }, 
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_NOP,
	`_EXIT
};

