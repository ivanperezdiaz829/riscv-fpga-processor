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


`timescale 1 ps / 1 ps

// `include "pll_avalon_h.v"

module pll_avalon
(
   // user data (avalon-MM formatted) 
	input	wire		clk,
	input	wire [0:0]	address,
	input	wire		read,
	output	reg [7:0]	readdata,

	input	wire 		locked
);

parameter PLL_LOCKED_ADDR = 0;
	initial
	begin
		readdata <= 0;
	end

	always @(posedge clk) begin
	    case (address)
	    // status registers
	    PLL_LOCKED_ADDR: if (read) readdata <= (8'd0 | locked);
	    endcase
	end
	 
endmodule