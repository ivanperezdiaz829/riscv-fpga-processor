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



// 
// Asynchronous reset filter
// Important properties :
//
//	1) The reset_n propagates immediately to output,
//    even if the clock is not operating.
//
//  2) The reset pulse will last for at least (PULSE_HOLD - 1)
//    clock ticks. 
//
//  3) The removal (de-assertion) of the reset will occur 
//    synchronously
//
//  4) circuit powers up in the reset asserted state
//
//  5) circuit can only leave the reset state if clock is 
//    operating, and enable = 1

`timescale 1 ps / 1 ps

module altera_xcvr_detlatency_reset_filter (
	enable,
	rstn_raw,
	clk,
	rstn_filtered
);

//
// "2" is the most common number for this parameter
// (enforces at least 1 cycle of reset)
//
parameter PULSE_HOLD = 2;  

input enable;
input rstn_raw;
input clk;
output rstn_filtered;

localparam SYNC_RSTN_REG_CONSTRAINT = {"-name SDC_STATEMENT \"set regs [get_pins -compatibility_mode -nowarn *top_pcs_ch_inst*rf_extern|rstn_reg[*]|clrn]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\""};
localparam SDC_CONSTRAINTS = {SYNC_RSTN_REG_CONSTRAINT};

// Apply false path timing constraints to synchronization registers.
(* altera_attribute = SDC_CONSTRAINTS *)
reg [PULSE_HOLD-1:0] rstn_reg /* synthesis preserve */;
initial rstn_reg = {PULSE_HOLD{1'b0}};

always @(posedge clk or negedge rstn_raw) begin
  if (!rstn_raw) begin
    rstn_reg <= {PULSE_HOLD{1'b0}};
  end
  else begin
	rstn_reg <= {enable,rstn_reg[PULSE_HOLD-1:1]};
  end
end

assign rstn_filtered = rstn_reg[0];

endmodule
