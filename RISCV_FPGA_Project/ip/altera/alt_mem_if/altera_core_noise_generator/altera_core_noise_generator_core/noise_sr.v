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


module noise_sr (
	clk,
	reset_n,
	ibit,
	obit
);

parameter WIDTH = 1000;

input clk;
input reset_n;
input ibit;
output obit;

wire obit;

reg [WIDTH - 1:0] sreg /* synthesis syn_noprune syn_preserve = 1 */;

	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n)
			sreg <= 0;
		else 
			sreg <= {sreg[WIDTH - 2:0], ibit};
	end
	
	assign obit = sreg[WIDTH-1];
endmodule