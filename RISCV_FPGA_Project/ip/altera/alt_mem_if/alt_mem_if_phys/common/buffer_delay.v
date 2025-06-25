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

(* altera_attribute = "-name AUTO_GLOBAL_CLOCK OFF" *)
module buffer_delay (
	buff_in,
	buff_out,
);

input	buff_in;
output	buff_out;

parameter NUM_LCELLBUF_STAGES = 4;



generate
genvar bufcount;

	wire [NUM_LCELLBUF_STAGES:0] lcell_buff_connect;

	for (bufcount=0; bufcount<NUM_LCELLBUF_STAGES; bufcount=bufcount+1)
	begin: buf_group
		LCELL lcell_signal_buf (.in(lcell_buff_connect[bufcount]), .out(lcell_buff_connect[bufcount+1]));
	end
	
	assign lcell_buff_connect[0] = buff_in;
	assign buff_out = lcell_buff_connect[NUM_LCELLBUF_STAGES];

endgenerate

endmodule
