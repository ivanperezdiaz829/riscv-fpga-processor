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


// Verilog RBC parameter resolution wrapper for arriav_hssi_pma_rx_deser
//

`timescale 1 ns / 1 ps

module arriav_hssi_pma_rx_deser_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter auto_negotiation = "false",	// false, true
	parameter bit_slip_bypass = "false",	// false, true
	parameter channel_number = 0,	// 0..65
	parameter clk_forward_only_mode = "false",	// false, true
	parameter mode = 8,	// clk_forward_only_false, clk_forward_only_true, 10, 16, 20, 8, 80
	parameter sdclk_enable = "false"	// false, true

	// constrained parameters
) (
	// ports
	input  wire         	bslip,
	input  wire         	clk270b,
	input  wire         	clk90b,
	output wire         	clkdivrx,
	output wire         	clkdivrxrx,
	input  wire         	deven,
	input  wire         	dodd,
	output wire   [79:0]	dout,
	output wire         	pciel,
	input  wire         	pciesw,
	input  wire         	rstn
);
	import altera_xcvr_functions::*;

	// auto_negotiation external parameter (no RBC)
	localparam rbc_all_auto_negotiation = "(false,true)";
	localparam rbc_any_auto_negotiation = "false";
	localparam fnl_auto_negotiation = (auto_negotiation == "<auto_any>" || auto_negotiation == "<auto_single>") ? rbc_any_auto_negotiation : auto_negotiation;

	// bit_slip_bypass external parameter (no RBC)
	localparam rbc_all_bit_slip_bypass = "(false,true)";
	localparam rbc_any_bit_slip_bypass = "false";
	localparam fnl_bit_slip_bypass = (bit_slip_bypass == "<auto_any>" || bit_slip_bypass == "<auto_single>") ? rbc_any_bit_slip_bypass : bit_slip_bypass;

	// clk_forward_only_mode external parameter (no RBC)
	localparam rbc_all_clk_forward_only_mode = "(false,true)";
	localparam rbc_any_clk_forward_only_mode = "false";
	localparam fnl_clk_forward_only_mode = (clk_forward_only_mode == "<auto_any>" || clk_forward_only_mode == "<auto_single>") ? rbc_any_clk_forward_only_mode : clk_forward_only_mode;

	// sdclk_enable external parameter (no RBC)
	localparam rbc_all_sdclk_enable = "(false,true)";
	localparam rbc_any_sdclk_enable = "false";
	localparam fnl_sdclk_enable = (sdclk_enable == "<auto_any>" || sdclk_enable == "<auto_single>") ? rbc_any_sdclk_enable : sdclk_enable;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("auto_negotiation = orig: '%s', any:'%s', all:'%s', final: '%s'", auto_negotiation, rbc_any_auto_negotiation, rbc_all_auto_negotiation, fnl_auto_negotiation);
		if (!is_in_legal_set(auto_negotiation, rbc_all_auto_negotiation)) begin
			$display("Critical Warning: parameter 'auto_negotiation' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", auto_negotiation, rbc_all_auto_negotiation, fnl_auto_negotiation);
		end
		//$display("bit_slip_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", bit_slip_bypass, rbc_any_bit_slip_bypass, rbc_all_bit_slip_bypass, fnl_bit_slip_bypass);
		if (!is_in_legal_set(bit_slip_bypass, rbc_all_bit_slip_bypass)) begin
			$display("Critical Warning: parameter 'bit_slip_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bit_slip_bypass, rbc_all_bit_slip_bypass, fnl_bit_slip_bypass);
		end
		//$display("clk_forward_only_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", clk_forward_only_mode, rbc_any_clk_forward_only_mode, rbc_all_clk_forward_only_mode, fnl_clk_forward_only_mode);
		if (!is_in_legal_set(clk_forward_only_mode, rbc_all_clk_forward_only_mode)) begin
			$display("Critical Warning: parameter 'clk_forward_only_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", clk_forward_only_mode, rbc_all_clk_forward_only_mode, fnl_clk_forward_only_mode);
		end
		//$display("sdclk_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", sdclk_enable, rbc_any_sdclk_enable, rbc_all_sdclk_enable, fnl_sdclk_enable);
		if (!is_in_legal_set(sdclk_enable, rbc_all_sdclk_enable)) begin
			$display("Critical Warning: parameter 'sdclk_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sdclk_enable, rbc_all_sdclk_enable, fnl_sdclk_enable);
		end
	end

	arriav_hssi_pma_rx_deser #(
		.auto_negotiation(fnl_auto_negotiation),
		.bit_slip_bypass(fnl_bit_slip_bypass),
		.channel_number(channel_number),
		.clk_forward_only_mode(fnl_clk_forward_only_mode),
		.mode(mode),
		.sdclk_enable(fnl_sdclk_enable)
	) wys (
		// ports
		.bslip(bslip),
		.clk270b(clk270b),
		.clk90b(clk90b),
		.clkdivrx(clkdivrx),
		.clkdivrxrx(clkdivrxrx),
		.deven(deven),
		.dodd(dodd),
		.dout(dout),
		.pciel(pciel),
		.pciesw(pciesw),
		.rstn(rstn)
	);
endmodule
