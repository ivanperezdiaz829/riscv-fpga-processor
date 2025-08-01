// (C) 2001-2011 Altera Corporation. All rights reserved.
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
module  altera_wait_generate
//#(
//This code only works when wait_cycle =1, if need other case, you need to modify this code.
//please set wait_cycle default value as 1 to keep old design works.
//   parameter wait_cycle =1
//   ) 
(   
   input   wire         rst,
   input   wire         clk,
   input   wire		launch_signal,
   output   wire	wait_req
   );
reg launch_reg = 0;
reg wait_reg = 0;
always @ (posedge clk, posedge rst) begin
	if(rst) launch_reg <= 1'b0;
	else 	launch_reg <= launch_signal;
end
always @ (posedge clk, posedge rst) begin
	if(rst) wait_reg <= 1'b0;
	else 	wait_reg <= launch_signal & launch_reg & (! wait_reg & !wait_req);
end
assign wait_req = (launch_signal & ~launch_reg) | (wait_reg & launch_signal ) ; 
endmodule
