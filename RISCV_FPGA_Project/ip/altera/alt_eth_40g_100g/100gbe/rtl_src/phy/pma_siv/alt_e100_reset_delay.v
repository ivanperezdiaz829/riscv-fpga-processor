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


// Copyright 2010 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
// baeckler - 12-17-2009

// when not ready_in - immediately not ready_out
// when ready_in - wait for counter, then ready out synchronously

module alt_e100_reset_delay #(
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