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

module alt_e40_sync_arst (
	input clk,
	input arst /* synthesis altera_attribute="disable_da_rule=r101" */,
	output sync_arst
);
parameter SYNC_STAGES = 3;

(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name SDC_STATEMENT \"set_false_path -from [get_fanins -async *alt_e40_sync_arst*alt_e40_arst_filter\[*\]] -to [get_keepers *alt_e40_sync_arst*alt_e40_arst_filter\[*\]]\" "}*) 
reg [SYNC_STAGES-1:0] alt_e40_arst_filter = 0 /* synthesis preserve dont_replicate*/;
always @(posedge clk or posedge arst) begin
    if (arst) alt_e40_arst_filter <= {SYNC_STAGES{1'b0}};
    else alt_e40_arst_filter <= {alt_e40_arst_filter[SYNC_STAGES-2:0],1'b1};
end
assign sync_arst = ~alt_e40_arst_filter[SYNC_STAGES-1];

endmodule


