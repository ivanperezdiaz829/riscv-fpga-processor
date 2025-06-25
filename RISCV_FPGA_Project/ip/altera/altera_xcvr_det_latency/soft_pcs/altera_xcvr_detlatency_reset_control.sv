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



//baeckler - 12-05-2007
//
// Combines (num_external_resets) external asynchronous active low resets.
//   Any active reset will reset the entire system immediately (even
//   if the clocks are not operating).
//
// Generate (num_domains) rstn signals, with guaranteed removal
//   timing with respect to the corresponding clock domains.
//
// The sequential_release parameter requires that rstn[0] is released
// before rstn[1] and so on.   For bringing up complex multi domain
// logic in the proper order.
//
`timescale 1 ps / 1 ps

module altera_xcvr_detlatency_reset_control #(
	parameter num_external_resets = 1,
	parameter num_domains = 1,
	parameter sequential_release = 1'b1
) (
	external_rstn,
	clk,
	rstn	
);

input [num_external_resets-1:0] external_rstn;
input [num_domains-1:0] clk;
output [num_domains-1:0] rstn;

genvar i;

//////////////////////////////////
// filter the resets to ensure 
// min pulse width, and synch
// removal, with respect to clock 0
//////////////////////////////////
wire [num_external_resets-1:0] filtered_rstn;
generate
for (i=0; i<num_external_resets; i=i+1)
begin : lp0
  altera_xcvr_detlatency_reset_filter rf_extern (
    .enable(1'b1),
	.rstn_raw(external_rstn[i]),
	.clk(clk[0]),
	.rstn_filtered(filtered_rstn[i]));
end
endgenerate

//////////////////////////////////////////////
// combine the various external reset sources
// to form a single system reset with respect 
// to clock 0
//////////////////////////////////////////////
wire sys_rstn = &filtered_rstn;

altera_xcvr_detlatency_reset_filter rf_sys (
    .enable(1'b1),
	.rstn_raw(sys_rstn),
	.clk(clk[0]),
	.rstn_filtered(rstn[0]));

//////////////////////////////////////////////
// release remaining resets either as convenient
// or sequentially, according to parameter
//////////////////////////////////////////////
generate 
for (i=1;i<num_domains;i=i+1)
begin : lp1
    altera_xcvr_detlatency_reset_filter rf_out (
	    .enable(sequential_release ? rstn[i-1] : 1'b1),
	    .rstn_raw(sys_rstn),
	    .clk(clk[i]),
	    .rstn_filtered(rstn[i])
	);
end
endgenerate

endmodule
