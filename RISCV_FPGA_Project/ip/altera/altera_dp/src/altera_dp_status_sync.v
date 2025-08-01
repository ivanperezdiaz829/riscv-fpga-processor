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
// baeckler - 01-20-2010
// weak meta hardening intended for low toggle rate / low priority status signals

module altera_dp_status_sync #(
	parameter WIDTH = 32
)(
	input clk,
	input [WIDTH-1:0] din,
	output [WIDTH-1:0] dout
);

(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name SDC_STATEMENT \"set_false_path -to [get_keepers *altera_dp_status_sync*sync_0\[*\]]\" "}*) 
reg [WIDTH-1:0] sync_0 = 0 /* synthesis preserve */;
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"}*) 
reg [WIDTH-1:0] sync_1 = 0 /* synthesis preserve */;

always @(posedge clk) begin
	sync_0 <= din;
	sync_1 <= sync_0;
end
assign dout = sync_1;

endmodule
