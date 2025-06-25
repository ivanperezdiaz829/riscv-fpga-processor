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


module noise_lfsr (
	clk,
	rbit,
	reset_n
);

parameter SEED		= 16'h1234;
parameter WIDTH		= 16;

input clk;
input reset_n;
output rbit;

wire rbit;

reg [WIDTH - 1:0] lfsr;
wire [WIDTH - 1:0] lfsr_curr;

	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n)
			lfsr <= 0;
		else
			lfsr <= {lfsr_curr[0], lfsr_curr[WIDTH - 1] ^ lfsr_curr[0], lfsr_curr[WIDTH - 2:1]};
	end

	assign lfsr_curr = lfsr ^ SEED;
	assign rbit = lfsr_curr[0];
	
endmodule