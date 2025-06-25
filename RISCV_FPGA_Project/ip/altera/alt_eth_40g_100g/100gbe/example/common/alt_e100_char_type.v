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
module alt_e100_char_type (
	input [7:0] char_in,
	output is_hex,
	output is_alnum,
	output [3:0] nybble	
);

//reg [5:0] out;	// LEDA
reg [5:0] char_out;
assign {is_alnum,is_hex,nybble} = char_out;

always @(char_in) begin
	case (char_in)
	
		// numbers
		"0" : char_out = {1'b1,1'b1,4'h0};
		"1" : char_out = {1'b1,1'b1,4'h1};
		"2" : char_out = {1'b1,1'b1,4'h2};
		"3" : char_out = {1'b1,1'b1,4'h3};
		"4" : char_out = {1'b1,1'b1,4'h4};
		"5" : char_out = {1'b1,1'b1,4'h5};
		"6" : char_out = {1'b1,1'b1,4'h6};
		"7" : char_out = {1'b1,1'b1,4'h7};
		"8" : char_out = {1'b1,1'b1,4'h8};
		"9" : char_out = {1'b1,1'b1,4'h9};
		
		// hex letters
		"A", "a" : char_out = {1'b1,1'b1,4'ha};
		"B", "b" : char_out = {1'b1,1'b1,4'hb};
		"C", "c" : char_out = {1'b1,1'b1,4'hc};
		"D", "d" : char_out = {1'b1,1'b1,4'hd};
		"E", "e" : char_out = {1'b1,1'b1,4'he};
		"F", "f" : char_out = {1'b1,1'b1,4'hf};
		
		// non hex letters
		"G", "g" : char_out = {1'b1,1'b0,4'h0};
		"H", "h" : char_out = {1'b1,1'b0,4'h0};
		"I", "i" : char_out = {1'b1,1'b0,4'h0};
		"J", "j" : char_out = {1'b1,1'b0,4'h0};
		"K", "k" : char_out = {1'b1,1'b0,4'h0};
		"L", "l" : char_out = {1'b1,1'b0,4'h0};
		"M", "m" : char_out = {1'b1,1'b0,4'h0};
		"N", "n" : char_out = {1'b1,1'b0,4'h0};
		"O", "o" : char_out = {1'b1,1'b0,4'h0};
		"P", "p" : char_out = {1'b1,1'b0,4'h0};
		"Q", "q" : char_out = {1'b1,1'b0,4'h0};
		"R", "r" : char_out = {1'b1,1'b0,4'h0};
		"S", "s" : char_out = {1'b1,1'b0,4'h0};
		"T", "t" : char_out = {1'b1,1'b0,4'h0};
		"U", "u" : char_out = {1'b1,1'b0,4'h0};
		"V", "v" : char_out = {1'b1,1'b0,4'h0};
		"W", "w" : char_out = {1'b1,1'b0,4'h0};
		"X", "x" : char_out = {1'b1,1'b0,4'h0};
		"Y", "y" : char_out = {1'b1,1'b0,4'h0};
		"Z", "z" : char_out = {1'b1,1'b0,4'h0};
		
		default : char_out = {1'b0,1'b0,4'b0};
	endcase
end
endmodule
