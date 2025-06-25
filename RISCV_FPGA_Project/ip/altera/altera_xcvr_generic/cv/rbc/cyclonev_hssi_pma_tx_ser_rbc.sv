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


// Verilog RBC parameter resolution wrapper for cyclonev_hssi_pma_tx_ser
//

`timescale 1 ns / 1 ps

module cyclonev_hssi_pma_tx_ser_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter auto_negotiation = "false",	// false, true
	parameter channel_number = 0,	// 0..65
	parameter clk_divtx_deskew = "deskew_delay0",	// deskew_delay0, deskew_delay1, deskew_delay10, deskew_delay11, deskew_delay12, deskew_delay13, deskew_delay14, deskew_delay15, deskew_delay2, deskew_delay3, deskew_delay4, deskew_delay5, deskew_delay6, deskew_delay7, deskew_delay8, deskew_delay9
	parameter clk_forward_only_mode = "false",	// false, true
	parameter mode = 8,	// clk_forward_only_false, clk_forward_only_true, 10, 16, 20, 8, 80
	parameter post_tap_1_en = "false",	// false, true
	parameter ser_loopback = "false"	// false, true

	// constrained parameters
) (
	// ports
	output wire         	clkdivtx,
	input  wire         	cpulse,
	input  wire   [79:0]	datain,
	output wire         	dataout,
	input  wire         	hfclk,
	input  wire         	hfclkn,
	output wire         	lbvop,
	input  wire         	lfclk,
	input  wire         	lfclkn,
	input  wire    [2:0]	pclk,
	input  wire         	pclk0,
	input  wire         	pclk1,
	input  wire         	pclk2,
	output wire         	preenout,
	input  wire         	rstn,
	input  wire         	slpbk
);
	import altera_xcvr_functions::*;

	// auto_negotiation external parameter (no RBC)
	localparam rbc_all_auto_negotiation = "(false,true)";
	localparam rbc_any_auto_negotiation = "false";
	localparam fnl_auto_negotiation = (auto_negotiation == "<auto_any>" || auto_negotiation == "<auto_single>") ? rbc_any_auto_negotiation : auto_negotiation;

	// clk_divtx_deskew external parameter (no RBC)
	localparam rbc_all_clk_divtx_deskew = "(deskew_delay0,deskew_delay1,deskew_delay10,deskew_delay11,deskew_delay12,deskew_delay13,deskew_delay14,deskew_delay15,deskew_delay2,deskew_delay3,deskew_delay4,deskew_delay5,deskew_delay6,deskew_delay7,deskew_delay8,deskew_delay9)";
	localparam rbc_any_clk_divtx_deskew = "deskew_delay0";
	localparam fnl_clk_divtx_deskew = (clk_divtx_deskew == "<auto_any>" || clk_divtx_deskew == "<auto_single>") ? rbc_any_clk_divtx_deskew : clk_divtx_deskew;

	// clk_forward_only_mode external parameter (no RBC)
	localparam rbc_all_clk_forward_only_mode = "(false,true)";
	localparam rbc_any_clk_forward_only_mode = "false";
	localparam fnl_clk_forward_only_mode = (clk_forward_only_mode == "<auto_any>" || clk_forward_only_mode == "<auto_single>") ? rbc_any_clk_forward_only_mode : clk_forward_only_mode;

	// post_tap_1_en external parameter (no RBC)
	localparam rbc_all_post_tap_1_en = "(false,true)";
	localparam rbc_any_post_tap_1_en = "false";
	localparam fnl_post_tap_1_en = (post_tap_1_en == "<auto_any>" || post_tap_1_en == "<auto_single>") ? rbc_any_post_tap_1_en : post_tap_1_en;

	// ser_loopback external parameter (no RBC)
	localparam rbc_all_ser_loopback = "(false,true)";
	localparam rbc_any_ser_loopback = "false";
	localparam fnl_ser_loopback = (ser_loopback == "<auto_any>" || ser_loopback == "<auto_single>") ? rbc_any_ser_loopback : ser_loopback;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("auto_negotiation = orig: '%s', any:'%s', all:'%s', final: '%s'", auto_negotiation, rbc_any_auto_negotiation, rbc_all_auto_negotiation, fnl_auto_negotiation);
		if (!is_in_legal_set(auto_negotiation, rbc_all_auto_negotiation)) begin
			$display("Critical Warning: parameter 'auto_negotiation' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", auto_negotiation, rbc_all_auto_negotiation, fnl_auto_negotiation);
		end
		//$display("clk_divtx_deskew = orig: '%s', any:'%s', all:'%s', final: '%s'", clk_divtx_deskew, rbc_any_clk_divtx_deskew, rbc_all_clk_divtx_deskew, fnl_clk_divtx_deskew);
		if (!is_in_legal_set(clk_divtx_deskew, rbc_all_clk_divtx_deskew)) begin
			$display("Critical Warning: parameter 'clk_divtx_deskew' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", clk_divtx_deskew, rbc_all_clk_divtx_deskew, fnl_clk_divtx_deskew);
		end
		//$display("clk_forward_only_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", clk_forward_only_mode, rbc_any_clk_forward_only_mode, rbc_all_clk_forward_only_mode, fnl_clk_forward_only_mode);
		if (!is_in_legal_set(clk_forward_only_mode, rbc_all_clk_forward_only_mode)) begin
			$display("Critical Warning: parameter 'clk_forward_only_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", clk_forward_only_mode, rbc_all_clk_forward_only_mode, fnl_clk_forward_only_mode);
		end
		//$display("post_tap_1_en = orig: '%s', any:'%s', all:'%s', final: '%s'", post_tap_1_en, rbc_any_post_tap_1_en, rbc_all_post_tap_1_en, fnl_post_tap_1_en);
		if (!is_in_legal_set(post_tap_1_en, rbc_all_post_tap_1_en)) begin
			$display("Critical Warning: parameter 'post_tap_1_en' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", post_tap_1_en, rbc_all_post_tap_1_en, fnl_post_tap_1_en);
		end
		//$display("ser_loopback = orig: '%s', any:'%s', all:'%s', final: '%s'", ser_loopback, rbc_any_ser_loopback, rbc_all_ser_loopback, fnl_ser_loopback);
		if (!is_in_legal_set(ser_loopback, rbc_all_ser_loopback)) begin
			$display("Critical Warning: parameter 'ser_loopback' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ser_loopback, rbc_all_ser_loopback, fnl_ser_loopback);
		end
	end

	cyclonev_hssi_pma_tx_ser #(
		.auto_negotiation(fnl_auto_negotiation),
		.channel_number(channel_number),
		.clk_divtx_deskew(fnl_clk_divtx_deskew),
		.clk_forward_only_mode(fnl_clk_forward_only_mode),
		.mode(mode),
		.post_tap_1_en(fnl_post_tap_1_en),
		.ser_loopback(fnl_ser_loopback)
	) wys (
		// ports
		.clkdivtx(clkdivtx),
		.cpulse(cpulse),
		.datain(datain),
		.dataout(dataout),
		.hfclk(hfclk),
		.hfclkn(hfclkn),
		.lbvop(lbvop),
		.lfclk(lfclk),
		.lfclkn(lfclkn),
		.pclk(pclk),
		.pclk0(pclk0),
		.pclk1(pclk1),
		.pclk2(pclk2),
		.preenout(preenout),
		.rstn(rstn),
		.slpbk(slpbk)
	);
endmodule
