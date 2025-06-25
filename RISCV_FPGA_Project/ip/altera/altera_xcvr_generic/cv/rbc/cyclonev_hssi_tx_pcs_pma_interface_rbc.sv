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


// Verilog RBC parameter resolution wrapper for cyclonev_hssi_tx_pcs_pma_interface
//

`timescale 1 ns / 1 ps

module cyclonev_hssi_tx_pcs_pma_interface_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter selectpcs = "eight_g_pcs"	// default, eight_g_pcs

	// constrained parameters
) (
	// ports
	output wire         	asynchdatain,
	input  wire         	clockinfrompma,
	output wire         	clockoutto8gpcs,
	input  wire   [19:0]	datainfrom8gpcs,
	output wire   [79:0]	dataouttopma,
	input  wire         	pcs8gtxclkiqout,
	input  wire         	pmarxfreqtxcmuplllockin,
	output wire         	pmarxfreqtxcmuplllockout,
	output wire         	pmatxclkout,
	output wire         	reset
);
	import altera_xcvr_functions::*;

	// selectpcs external parameter (no RBC)
	localparam rbc_all_selectpcs = "(default,eight_g_pcs)";
	localparam rbc_any_selectpcs = "eight_g_pcs";
	localparam fnl_selectpcs = (selectpcs == "<auto_any>" || selectpcs == "<auto_single>") ? rbc_any_selectpcs : selectpcs;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("selectpcs = orig: '%s', any:'%s', all:'%s', final: '%s'", selectpcs, rbc_any_selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		if (!is_in_legal_set(selectpcs, rbc_all_selectpcs)) begin
			$display("Critical Warning: parameter 'selectpcs' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		end
	end

	cyclonev_hssi_tx_pcs_pma_interface #(
		.selectpcs(fnl_selectpcs)
	) wys (
		// ports
		.asynchdatain(asynchdatain),
		.clockinfrompma(clockinfrompma),
		.clockoutto8gpcs(clockoutto8gpcs),
		.datainfrom8gpcs(datainfrom8gpcs),
		.dataouttopma(dataouttopma),
		.pcs8gtxclkiqout(pcs8gtxclkiqout),
		.pmarxfreqtxcmuplllockin(pmarxfreqtxcmuplllockin),
		.pmarxfreqtxcmuplllockout(pmarxfreqtxcmuplllockout),
		.pmatxclkout(pmatxclkout),
		.reset(reset)
	);
endmodule
