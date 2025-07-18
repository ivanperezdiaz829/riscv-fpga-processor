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
// baeckler - 07-27-2010
// ishimony - 10-27-2010
// counter with 4 increment ports

module alt_e40_wide_stat_cntr_4port # (
	parameter WIDTH = 32
)(
	input clk, 
	input ena,
	input sclr,
	input [3:0] inc,
	output reg [WIDTH-1:0] cntr
);

/////////////////////////
// dev_clr sync-reset
/////////////////////////
alt_e40_user_mode_det dev_clr(
    .ref_clk(clk),
    .user_mode_sync(user_mode_sync)
);

initial cntr = 0;
//always @(posedge clk) begin
always @(posedge clk or negedge user_mode_sync) begin
   if (!user_mode_sync) cntr <= 0;
   else
	if (ena) begin
		if (sclr) begin
			cntr <= 0;
		end
		else begin
			cntr <= cntr + inc[0] + inc[1] + inc[2] + inc[3];
		end 
	end	
end

endmodule
