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


module reg_delay (
	clk,
	reset_n,
	data_in,
	data_out
);

parameter DATA_WIDTH = 32;
parameter CYCLE_DELAY = 1;

input clk;
input reset_n;
input [DATA_WIDTH-1 : 0] data_in;
output [DATA_WIDTH-1 : 0] data_out;

generate
	if (CYCLE_DELAY > 0) begin : CYCLE_DELAY_N
		
		reg [DATA_WIDTH-1 : 0] delay_pipe [CYCLE_DELAY-1 : 0];
		int i;
		
		always_ff @ (posedge clk or negedge reset_n) begin
			if (~reset_n) begin
				for (i = 0; i < CYCLE_DELAY-1; i++)
					delay_pipe[i] <= 0;
			end
			else begin
				delay_pipe[0] <= data_in;
				for (i = 1; i < CYCLE_DELAY-1; i++)
					delay_pipe[i] <= delay_pipe[i-1];
			end
		end
		
		assign data_out = delay_pipe[CYCLE_DELAY-1];

	end
	else begin : CYCLE_DELAY_0
		assign data_out = data_in;
	end
endgenerate

endmodule