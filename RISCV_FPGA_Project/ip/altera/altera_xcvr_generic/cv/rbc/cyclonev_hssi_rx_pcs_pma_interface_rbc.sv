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


// Verilog RBC parameter resolution wrapper for cyclonev_hssi_rx_pcs_pma_interface
//

`timescale 1 ns / 1 ps

module cyclonev_hssi_rx_pcs_pma_interface_rbc #(
	// unconstrained parameters
	parameter prot_mode = "<auto_single>",	// cpri_8g, other_protocols

	// extra unconstrained parameters found in atom map
	parameter selectpcs = "eight_g_pcs",	// default, eight_g_pcs

	// constrained parameters
	parameter clkslip_sel = "<auto_single>"	// pld, slip_eight_g_pcs
) (
	// ports
	output wire         	asynchdatain,
	input  wire         	clockinfrompma,
	output wire         	clockoutto8gpcs,
	input  wire   [79:0]	datainfrompma,
	output wire   [19:0]	dataoutto8gpcs,
	input  wire         	pcs8grxclkiqout,
	input  wire         	pcs8grxclkslip,
	output wire         	pcs8gsigdetni,
	input  wire         	pldrxclkslip,
	input  wire         	pldrxpmarstb,
	input  wire    [4:0]	pmareservedin,
	output wire    [4:0]	pmareservedout,
	output wire         	pmarxclkout,
	output wire         	pmarxclkslip,
	input  wire         	pmarxpllphaselockin,
	output wire         	pmarxpllphaselockout,
	output wire         	pmarxpmarstb,
	input  wire         	pmasigdet,
	output wire         	reset
);
	import altera_xcvr_functions::*;

	// prot_mode external parameter (no RBC)
	localparam rbc_all_prot_mode = "(cpri_8g,other_protocols)";
	localparam rbc_any_prot_mode = "other_protocols";
	localparam fnl_prot_mode = (prot_mode == "<auto_any>" || prot_mode == "<auto_single>") ? rbc_any_prot_mode : prot_mode;

	// selectpcs external parameter (no RBC)
	localparam rbc_all_selectpcs = "(default,eight_g_pcs)";
	localparam rbc_any_selectpcs = "eight_g_pcs";
	localparam fnl_selectpcs = (selectpcs == "<auto_any>" || selectpcs == "<auto_single>") ? rbc_any_selectpcs : selectpcs;

	// clkslip_sel, RBC-validated
	localparam rbc_all_clkslip_sel = (fnl_prot_mode == "cpri_8g") ? ("(slip_eight_g_pcs,pld)") : "pld";
	localparam rbc_any_clkslip_sel = (fnl_prot_mode == "cpri_8g") ? ("pld") : "pld";
	localparam fnl_clkslip_sel = (clkslip_sel == "<auto_any>" || clkslip_sel == "<auto_single>") ? rbc_any_clkslip_sel : clkslip_sel;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("prot_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", prot_mode, rbc_any_prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		if (!is_in_legal_set(prot_mode, rbc_all_prot_mode)) begin
			$display("Critical Warning: parameter 'prot_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		end
		//$display("selectpcs = orig: '%s', any:'%s', all:'%s', final: '%s'", selectpcs, rbc_any_selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		if (!is_in_legal_set(selectpcs, rbc_all_selectpcs)) begin
			$display("Critical Warning: parameter 'selectpcs' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		end
		//$display("clkslip_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", clkslip_sel, rbc_any_clkslip_sel, rbc_all_clkslip_sel, fnl_clkslip_sel);
		if (!is_in_legal_set(clkslip_sel, rbc_all_clkslip_sel)) begin
			$display("Critical Warning: parameter 'clkslip_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", clkslip_sel, rbc_all_clkslip_sel, fnl_clkslip_sel);
		end
	end

	cyclonev_hssi_rx_pcs_pma_interface #(
		.prot_mode(fnl_prot_mode),
		.selectpcs(fnl_selectpcs),
		.clkslip_sel(fnl_clkslip_sel)
	) wys (
		// ports
		.asynchdatain(asynchdatain),
		.clockinfrompma(clockinfrompma),
		.clockoutto8gpcs(clockoutto8gpcs),
		.datainfrompma(datainfrompma),
		.dataoutto8gpcs(dataoutto8gpcs),
		.pcs8grxclkiqout(pcs8grxclkiqout),
		.pcs8grxclkslip(pcs8grxclkslip),
		.pcs8gsigdetni(pcs8gsigdetni),
		.pldrxclkslip(pldrxclkslip),
		.pldrxpmarstb(pldrxpmarstb),
		.pmareservedin(pmareservedin),
		.pmareservedout(pmareservedout),
		.pmarxclkout(pmarxclkout),
		.pmarxclkslip(pmarxclkslip),
		.pmarxpllphaselockin(pmarxpllphaselockin),
		.pmarxpllphaselockout(pmarxpllphaselockout),
		.pmarxpmarstb(pmarxpmarstb),
		.pmasigdet(pmasigdet),
		.reset(reset)
	);
endmodule
