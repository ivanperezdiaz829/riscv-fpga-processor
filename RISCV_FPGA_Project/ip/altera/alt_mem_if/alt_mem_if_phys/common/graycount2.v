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

module graycount2(
	reset_n,
	clk,
	enable,
	count	
);

input	reset_n;
input	clk;
input	enable;
output	[1:0] count;

reg	[1:0] count;
reg	[1:0] next_count;

	always @(count)
	case (count)
		2'b00: next_count = 2'b01;
		2'b01: next_count = 2'b11;
		2'b11: next_count = 2'b10;
		2'b10: next_count = 2'b00;
		default: next_count = 2'bx;
	endcase


	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n)
			count <= 2'b00;
		else
		begin
			if (enable)
				count <= next_count;
		end
	end

endmodule
