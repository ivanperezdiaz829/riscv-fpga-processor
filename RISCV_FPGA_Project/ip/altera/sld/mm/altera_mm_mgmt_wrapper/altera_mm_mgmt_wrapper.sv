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


// altera_mm_mgmt_wrapper.sv

`timescale 1 ns / 1 ns

module altera_mm_mgmt_wrapper #(
    parameter CHANNEL_WIDTH = 8
) (
    input         clk,
    input         reset,
    input         csr_write,
    input  [31:0] csr_writedata,
    output reg    mgmt_valid,
    output reg    mgmt_data,
    output reg [CHANNEL_WIDTH-1:0] mgmt_channel
);

always @(posedge clk or posedge reset) begin
	if (reset) begin
		mgmt_valid   <= 1'b0;
		mgmt_data    <= 1'b0;
		mgmt_channel <= {CHANNEL_WIDTH{1'b0}};
	end else begin
		mgmt_valid   <= csr_write;
		mgmt_data    <= csr_writedata[0];
		mgmt_channel <= csr_writedata[CHANNEL_WIDTH+7:8];
	end
end

endmodule
