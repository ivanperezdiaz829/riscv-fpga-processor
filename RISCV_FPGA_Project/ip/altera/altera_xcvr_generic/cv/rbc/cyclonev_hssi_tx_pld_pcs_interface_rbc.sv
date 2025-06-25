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


// Verilog RBC parameter resolution wrapper for cyclonev_hssi_tx_pld_pcs_interface
//

`timescale 1 ns / 1 ps

module cyclonev_hssi_tx_pld_pcs_interface_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter is_8g_0ppm = "false",	// false, true
	parameter pld_side_data_source = "pld"	// hip, pld

	// constrained parameters
) (
	// ports
	output wire         	asynchdatain,
	input  wire         	clockinfrom8gpcs,
	input  wire   [43:0]	datainfrompld,
	output wire   [43:0]	dataoutto8gpcs,
	input  wire         	emsipenablediocsrrdydly,
	output wire    [2:0]	emsippcstxclkout,	
	input  wire  [103:0]	emsiptxin,
	input  wire   [12:0]	emsiptxspecialin,
	output wire   [15:0]	emsiptxspecialout,
	input  wire         	pcs8gemptytx,
	input  wire         	pcs8gfulltx,
	output wire         	pcs8gphfifoursttx,
	output wire         	pcs8gpldtxclk,
	output wire         	pcs8gpolinvtx,
	output wire         	pcs8grddisabletx,
	output wire         	pcs8grevloopbk,
	output wire    [4:0]	pcs8gtxboundarysel,
	output wire    [3:0]	pcs8gtxdatavalid,
	output wire         	pcs8gtxurstpcs,
	output wire         	pcs8gwrenabletx,
	output wire         	pld8gemptytx,
	output wire         	pld8gfulltx,
	input  wire         	pld8gphfifoursttxn,
	input  wire         	pld8gpldtxclk,
	input  wire         	pld8gpolinvtx,
	input  wire         	pld8grddisabletx,
	input  wire         	pld8grevloopbk,
	input  wire    [4:0]	pld8gtxboundarysel,
	output wire         	pld8gtxclkout,
	input  wire    [3:0]	pld8gtxdatavalid,
	input  wire         	pld8gtxurstpcsn,
	input  wire         	pld8gwrenabletx,
	input  wire         	pmatxcmuplllock,
	output wire         	reset,
	input  wire         	rstsel,
	input  wire         	usrrstsel
);
	import altera_xcvr_functions::*;

	// is_8g_0ppm external parameter (no RBC)
	localparam rbc_all_is_8g_0ppm = "(false,true)";
	localparam rbc_any_is_8g_0ppm = "false";
	localparam fnl_is_8g_0ppm = (is_8g_0ppm == "<auto_any>" || is_8g_0ppm == "<auto_single>") ? rbc_any_is_8g_0ppm : is_8g_0ppm;

	// pld_side_data_source external parameter (no RBC)
	localparam rbc_all_pld_side_data_source = "(hip,pld)";
	localparam rbc_any_pld_side_data_source = "pld";
	localparam fnl_pld_side_data_source = (pld_side_data_source == "<auto_any>" || pld_side_data_source == "<auto_single>") ? rbc_any_pld_side_data_source : pld_side_data_source;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("is_8g_0ppm = orig: '%s', any:'%s', all:'%s', final: '%s'", is_8g_0ppm, rbc_any_is_8g_0ppm, rbc_all_is_8g_0ppm, fnl_is_8g_0ppm);
		if (!is_in_legal_set(is_8g_0ppm, rbc_all_is_8g_0ppm)) begin
			$display("Critical Warning: parameter 'is_8g_0ppm' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", is_8g_0ppm, rbc_all_is_8g_0ppm, fnl_is_8g_0ppm);
		end
		//$display("pld_side_data_source = orig: '%s', any:'%s', all:'%s', final: '%s'", pld_side_data_source, rbc_any_pld_side_data_source, rbc_all_pld_side_data_source, fnl_pld_side_data_source);
		if (!is_in_legal_set(pld_side_data_source, rbc_all_pld_side_data_source)) begin
			$display("Critical Warning: parameter 'pld_side_data_source' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pld_side_data_source, rbc_all_pld_side_data_source, fnl_pld_side_data_source);
		end
	end

	cyclonev_hssi_tx_pld_pcs_interface #(
		.is_8g_0ppm(fnl_is_8g_0ppm),
		.pld_side_data_source(fnl_pld_side_data_source)
	) wys (
		// ports
		.asynchdatain(asynchdatain),
		.clockinfrom8gpcs(clockinfrom8gpcs),
		.datainfrompld(datainfrompld),
		.dataoutto8gpcs(dataoutto8gpcs),
		.emsipenablediocsrrdydly(emsipenablediocsrrdydly),
		.emsippcstxclkout(emsippcstxclkout),	
		.emsiptxin(emsiptxin),
		.emsiptxspecialin(emsiptxspecialin),
		.emsiptxspecialout(emsiptxspecialout),
		.pcs8gemptytx(pcs8gemptytx),
		.pcs8gfulltx(pcs8gfulltx),
		.pcs8gphfifoursttx(pcs8gphfifoursttx),
		.pcs8gpldtxclk(pcs8gpldtxclk),
		.pcs8gpolinvtx(pcs8gpolinvtx),
		.pcs8grddisabletx(pcs8grddisabletx),
		.pcs8grevloopbk(pcs8grevloopbk),
		.pcs8gtxboundarysel(pcs8gtxboundarysel),
		.pcs8gtxdatavalid(pcs8gtxdatavalid),
		.pcs8gtxurstpcs(pcs8gtxurstpcs),
		.pcs8gwrenabletx(pcs8gwrenabletx),
		.pld8gemptytx(pld8gemptytx),
		.pld8gfulltx(pld8gfulltx),
		.pld8gphfifoursttxn(pld8gphfifoursttxn),
		.pld8gpldtxclk(pld8gpldtxclk),
		.pld8gpolinvtx(pld8gpolinvtx),
		.pld8grddisabletx(pld8grddisabletx),
		.pld8grevloopbk(pld8grevloopbk),
		.pld8gtxboundarysel(pld8gtxboundarysel),
		.pld8gtxclkout(pld8gtxclkout),
		.pld8gtxdatavalid(pld8gtxdatavalid),
		.pld8gtxurstpcsn(pld8gtxurstpcsn),
		.pld8gwrenabletx(pld8gwrenabletx),
		.pmatxcmuplllock(pmatxcmuplllock),
		.reset(reset),
		.rstsel(rstsel),
		.usrrstsel(usrrstsel)
	);
endmodule
