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
// baeckler - 12-17-2009

// when not ready_in - immediately not ready_out
// when ready_in - wait for counter, then ready out synchronously

module altera_dp_reset_delay #(
	parameter CNTR_BITS = 16
)
(
	input clk,
	input ready_in,
	output ready_out
);

reg [1:0] rs = 2'b0 /* synthesis preserve */;
always @(posedge clk or negedge ready_in) begin
	if (!ready_in) rs <= 2'b00;
	else rs <= {rs[0],1'b1};
end
wire ready_sync = rs[1];

reg [CNTR_BITS-1:0] cntr = {CNTR_BITS{1'b0}} /* synthesis preserve */;
assign ready_out = cntr[CNTR_BITS-1];
always @(posedge clk or negedge ready_sync) begin
	if (!ready_sync) cntr <= {CNTR_BITS{1'b0}};
	else if (!ready_out) cntr <= cntr + 1'b1;
end

endmodule
