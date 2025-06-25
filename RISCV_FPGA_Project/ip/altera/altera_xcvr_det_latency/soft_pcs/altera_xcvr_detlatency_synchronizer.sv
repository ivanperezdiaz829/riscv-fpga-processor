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

module altera_xcvr_detlatency_synchronizer #(
	parameter width = 16,
	parameter stages = 3, // should not be less than 2
  parameter reset_val = 0  // Reset value
)
(
	input clk, rst,
	
	input [width-1:0] dat_in,
	output [width-1:0] dat_out	
);

  localparam sync_stages   = 2;
  localparam sync_stages_str  = "2";  // number of sync stages specified as string (for timing constraints)
  localparam SYNC_REGS_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_registers -nowarn *altera_xcvr_detlatency_synchronizer*sync_regs[",sync_stages_str,"]*]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
  localparam SDC_CONSTRAINTS = {SYNC_REGS_CONSTRAINT};

  // Apply false path timing constraints
  (* altera_attribute = SDC_CONSTRAINTS *)
	reg [width-1:0] sync_regs [sync_stages:1] /* synthesis preserve */;

  wire                   reset_value;

  assign reset_value = (reset_val == 1) ? 1'b1 : 1'b0;  // To eliminate truncating warning
  
  integer stage;
  always @(posedge clk or posedge rst) begin
  	if (rst) 
			sync_regs[1] <= {width*(sync_stages-1){reset_value}};  	
		else
	    for (stage=2; stage <= sync_stages; stage = stage + 1) begin
	      sync_regs[stage-1] <= sync_regs[stage];
	    end
  end

  always @(posedge clk) begin
    sync_regs[sync_stages] <= dat_in;
  end

	assign dat_out = sync_regs[1];

endmodule