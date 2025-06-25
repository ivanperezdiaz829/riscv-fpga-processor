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


module counter_gen (
	clk,
	reset_n,
	data_out,
	enable
);

parameter DATA_WIDTH = 32;

input clk;
input reset_n;
output [DATA_WIDTH-1:0] data_out;
input enable;


reg [DATA_WIDTH-1:0] data_counter;

always_ff @ (posedge clk or negedge reset_n) begin
	if (~reset_n) begin
		data_counter <= 0;
	end
	else begin
		if (enable)
			data_counter <= data_counter + 1'b1;
	end
end

assign data_out = data_counter;

endmodule