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


// Verilog RBC parameter resolution wrapper for cyclonev_hssi_pma_tx_cgb
//

`timescale 1 ns / 1 ps

module cyclonev_hssi_pma_tx_cgb_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter auto_negotiation = "false",	// false, true
	parameter cgb_iqclk_sel = "cgb_x1_n_div",	// cgb_x1_n_div, rx_output
	parameter cgb_sync = "normal",	// normal, sync_rst
	parameter channel_number = 0,	// 0..255
	parameter clk_mute = "disable_clockmute",	// disable_clockmute, enable_clock_mute, enable_clock_mute_master_channel
	parameter data_rate = "",
	parameter ht_delay_enable = "false",	// false, true
	parameter mode = 8,	// 10, 16, 20, 8, 80
	parameter reset_scheme = "counter_reset_disable",	// counter_reset_disable, counter_reset_enable
	parameter rx_iqclk_sel = "cgb_x1_n_div",	// cgb_x1_n_div, rx_output, tristate
	parameter tx_mux_power_down = "normal",	// normal, power_down
	parameter x1_clock_source_sel = "x1_clk_unused",	// ch1_txpll_b, ch1_txpll_t, down_segmented, ffpll, hfclk_ch1_x6_dn, hfclk_ch1_x6_up, hfclk_xn_dn, hfclk_xn_up, same_ch_txpll, up_segmented
	parameter x1_div_m_sel = 1,	// 1, 2, 4, 8
	parameter xn_clock_source_sel = "cgb_xn_unused"	// cgb_x1_m_div, cgb_xn_unused, ch1_x6_dn, ch1_x6_up, xn_dn, xn_up

	// constrained parameters
) (
	// ports
	input  wire         	clkbcdr1b,
	input  wire         	clkbcdr1t,
	input  wire         	clkbcdrloc,
	input  wire         	clkbdnseg,
	input  wire         	clkbffpll,
	input  wire         	clkbupseg,
	input  wire         	clkcdr1b,
	input  wire         	clkcdr1t,
	input  wire         	clkcdrloc,
	input  wire         	clkdnseg,
	input  wire         	clkffpll,
	input  wire         	clkupseg,
	output wire         	cpulse,
	output wire         	cpulseout,
	input  wire         	cpulsex6dn,
	input  wire         	cpulsex6up,
	input  wire         	cpulsexndn,
	input  wire         	cpulsexnup,
	output wire         	hfclkn,
	output wire         	hfclknout,
	input  wire         	hfclknx6dn,
	input  wire         	hfclknx6up,
	input  wire         	hfclknxndn,
	input  wire         	hfclknxnup,
	output wire         	hfclkp,
	output wire         	hfclkpout,
	input  wire         	hfclkpx6dn,
	input  wire         	hfclkpx6up,
	input  wire         	hfclkpxndn,
	input  wire         	hfclkpxnup,
	output wire         	lfclkn,
	output wire         	lfclknout,
	input  wire         	lfclknx6dn,
	input  wire         	lfclknx6up,
	input  wire         	lfclknxndn,
	input  wire         	lfclknxnup,
	output wire         	lfclkp,
	output wire         	lfclkpout,
	input  wire         	lfclkpx6dn,
	input  wire         	lfclkpx6up,
	input  wire         	lfclkpxndn,
	input  wire         	lfclkpxnup,
	input  wire         	pciesw,
	output wire         	pcieswdone,
	output wire         	pciesyncp,
	output wire    [2:0]	pclk,
	output wire         	pclk0,
	output wire         	pclk0out,
	input  wire         	pclk0x6adj,
	input  wire         	pclk0x6loc,
	input  wire         	pclk0xndn,
	input  wire         	pclk0xnup,
	output wire         	pclk1,
	output wire         	pclk1out,
	input  wire         	pclk1x6adj,
	input  wire         	pclk1x6loc,
	input  wire         	pclk1xndn,
	input  wire         	pclk1xnup,
	output wire         	pclkout,
	input  wire         	pclkx6dn,
	input  wire         	pclkx6up,
	input  wire         	pclkxndn,
	input  wire         	pclkxnup,
	input  wire         	rxclk,
	output wire         	rxiqclk,
	input  wire         	txpmarstb
);
	import altera_xcvr_functions::*;

	// auto_negotiation external parameter (no RBC)
	localparam rbc_all_auto_negotiation = "(false,true)";
	localparam rbc_any_auto_negotiation = "false";
	localparam fnl_auto_negotiation = (auto_negotiation == "<auto_any>" || auto_negotiation == "<auto_single>") ? rbc_any_auto_negotiation : auto_negotiation;

	// cgb_iqclk_sel external parameter (no RBC)
	localparam rbc_all_cgb_iqclk_sel = "(cgb_x1_n_div,rx_output)";
	localparam rbc_any_cgb_iqclk_sel = "cgb_x1_n_div";
	localparam fnl_cgb_iqclk_sel = (cgb_iqclk_sel == "<auto_any>" || cgb_iqclk_sel == "<auto_single>") ? rbc_any_cgb_iqclk_sel : cgb_iqclk_sel;

	// cgb_sync external parameter (no RBC)
	localparam rbc_all_cgb_sync = "(normal,sync_rst)";
	localparam rbc_any_cgb_sync = "normal";
	localparam fnl_cgb_sync = (cgb_sync == "<auto_any>" || cgb_sync == "<auto_single>") ? rbc_any_cgb_sync : cgb_sync;

	// clk_mute external parameter (no RBC)
	localparam rbc_all_clk_mute = "(disable_clockmute,enable_clock_mute,enable_clock_mute_master_channel)";
	localparam rbc_any_clk_mute = "disable_clockmute";
	localparam fnl_clk_mute = (clk_mute == "<auto_any>" || clk_mute == "<auto_single>") ? rbc_any_clk_mute : clk_mute;

	// ht_delay_enable external parameter (no RBC)
	localparam rbc_all_ht_delay_enable = "(false,true)";
	localparam rbc_any_ht_delay_enable = "false";
	localparam fnl_ht_delay_enable = (ht_delay_enable == "<auto_any>" || ht_delay_enable == "<auto_single>") ? rbc_any_ht_delay_enable : ht_delay_enable;

	// reset_scheme external parameter (no RBC)
	localparam rbc_all_reset_scheme = "(counter_reset_disable,counter_reset_enable)";
	localparam rbc_any_reset_scheme = "counter_reset_disable";
	localparam fnl_reset_scheme = (reset_scheme == "<auto_any>" || reset_scheme == "<auto_single>") ? rbc_any_reset_scheme : reset_scheme;

	// rx_iqclk_sel external parameter (no RBC)
	localparam rbc_all_rx_iqclk_sel = "(cgb_x1_n_div,rx_output,tristate)";
	localparam rbc_any_rx_iqclk_sel = "cgb_x1_n_div";
	localparam fnl_rx_iqclk_sel = (rx_iqclk_sel == "<auto_any>" || rx_iqclk_sel == "<auto_single>") ? rbc_any_rx_iqclk_sel : rx_iqclk_sel;

	// tx_mux_power_down external parameter (no RBC)
	localparam rbc_all_tx_mux_power_down = "(normal,power_down)";
	localparam rbc_any_tx_mux_power_down = "normal";
	localparam fnl_tx_mux_power_down = (tx_mux_power_down == "<auto_any>" || tx_mux_power_down == "<auto_single>") ? rbc_any_tx_mux_power_down : tx_mux_power_down;

	// x1_clock_source_sel external parameter (no RBC)
	localparam rbc_all_x1_clock_source_sel = "(ch1_txpll_b,ch1_txpll_t,down_segmented,ffpll,hfclk_ch1_x6_dn,hfclk_ch1_x6_up,hfclk_xn_dn,hfclk_xn_up,same_ch_txpll,up_segmented,x1_clk_unused)";
	localparam rbc_any_x1_clock_source_sel = "x1_clk_unused";
	localparam fnl_x1_clock_source_sel = (x1_clock_source_sel == "<auto_any>" || x1_clock_source_sel == "<auto_single>") ? rbc_any_x1_clock_source_sel : x1_clock_source_sel;

	// xn_clock_source_sel external parameter (no RBC)
	localparam rbc_all_xn_clock_source_sel = "(cgb_x1_m_div,cgb_xn_unused,ch1_x6_dn,ch1_x6_up,xn_dn,xn_up)";
	localparam rbc_any_xn_clock_source_sel = "cgb_xn_unused";
	localparam fnl_xn_clock_source_sel = (xn_clock_source_sel == "<auto_any>" || xn_clock_source_sel == "<auto_single>") ? rbc_any_xn_clock_source_sel : xn_clock_source_sel;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("auto_negotiation = orig: '%s', any:'%s', all:'%s', final: '%s'", auto_negotiation, rbc_any_auto_negotiation, rbc_all_auto_negotiation, fnl_auto_negotiation);
		if (!is_in_legal_set(auto_negotiation, rbc_all_auto_negotiation)) begin
			$display("Critical Warning: parameter 'auto_negotiation' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", auto_negotiation, rbc_all_auto_negotiation, fnl_auto_negotiation);
		end
		//$display("cgb_iqclk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", cgb_iqclk_sel, rbc_any_cgb_iqclk_sel, rbc_all_cgb_iqclk_sel, fnl_cgb_iqclk_sel);
		if (!is_in_legal_set(cgb_iqclk_sel, rbc_all_cgb_iqclk_sel)) begin
			$display("Critical Warning: parameter 'cgb_iqclk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cgb_iqclk_sel, rbc_all_cgb_iqclk_sel, fnl_cgb_iqclk_sel);
		end
		//$display("cgb_sync = orig: '%s', any:'%s', all:'%s', final: '%s'", cgb_sync, rbc_any_cgb_sync, rbc_all_cgb_sync, fnl_cgb_sync);
		if (!is_in_legal_set(cgb_sync, rbc_all_cgb_sync)) begin
			$display("Critical Warning: parameter 'cgb_sync' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cgb_sync, rbc_all_cgb_sync, fnl_cgb_sync);
		end
		//$display("clk_mute = orig: '%s', any:'%s', all:'%s', final: '%s'", clk_mute, rbc_any_clk_mute, rbc_all_clk_mute, fnl_clk_mute);
		if (!is_in_legal_set(clk_mute, rbc_all_clk_mute)) begin
			$display("Critical Warning: parameter 'clk_mute' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", clk_mute, rbc_all_clk_mute, fnl_clk_mute);
		end
		//$display("ht_delay_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", ht_delay_enable, rbc_any_ht_delay_enable, rbc_all_ht_delay_enable, fnl_ht_delay_enable);
		if (!is_in_legal_set(ht_delay_enable, rbc_all_ht_delay_enable)) begin
			$display("Critical Warning: parameter 'ht_delay_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ht_delay_enable, rbc_all_ht_delay_enable, fnl_ht_delay_enable);
		end
		//$display("reset_scheme = orig: '%s', any:'%s', all:'%s', final: '%s'", reset_scheme, rbc_any_reset_scheme, rbc_all_reset_scheme, fnl_reset_scheme);
		if (!is_in_legal_set(reset_scheme, rbc_all_reset_scheme)) begin
			$display("Critical Warning: parameter 'reset_scheme' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", reset_scheme, rbc_all_reset_scheme, fnl_reset_scheme);
		end
		//$display("rx_iqclk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_iqclk_sel, rbc_any_rx_iqclk_sel, rbc_all_rx_iqclk_sel, fnl_rx_iqclk_sel);
		if (!is_in_legal_set(rx_iqclk_sel, rbc_all_rx_iqclk_sel)) begin
			$display("Critical Warning: parameter 'rx_iqclk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_iqclk_sel, rbc_all_rx_iqclk_sel, fnl_rx_iqclk_sel);
		end
		//$display("tx_mux_power_down = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_mux_power_down, rbc_any_tx_mux_power_down, rbc_all_tx_mux_power_down, fnl_tx_mux_power_down);
		if (!is_in_legal_set(tx_mux_power_down, rbc_all_tx_mux_power_down)) begin
			$display("Critical Warning: parameter 'tx_mux_power_down' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_mux_power_down, rbc_all_tx_mux_power_down, fnl_tx_mux_power_down);
		end
		//$display("x1_clock_source_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", x1_clock_source_sel, rbc_any_x1_clock_source_sel, rbc_all_x1_clock_source_sel, fnl_x1_clock_source_sel);
		if (!is_in_legal_set(x1_clock_source_sel, rbc_all_x1_clock_source_sel)) begin
			$display("Critical Warning: parameter 'x1_clock_source_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", x1_clock_source_sel, rbc_all_x1_clock_source_sel, fnl_x1_clock_source_sel);
		end
		//$display("xn_clock_source_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", xn_clock_source_sel, rbc_any_xn_clock_source_sel, rbc_all_xn_clock_source_sel, fnl_xn_clock_source_sel);
		if (!is_in_legal_set(xn_clock_source_sel, rbc_all_xn_clock_source_sel)) begin
			$display("Critical Warning: parameter 'xn_clock_source_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", xn_clock_source_sel, rbc_all_xn_clock_source_sel, fnl_xn_clock_source_sel);
		end
	end

	cyclonev_hssi_pma_tx_cgb #(
		.auto_negotiation(fnl_auto_negotiation),
		.cgb_iqclk_sel(fnl_cgb_iqclk_sel),
		.cgb_sync(fnl_cgb_sync),
		.channel_number(channel_number),
		.clk_mute(fnl_clk_mute),
		.data_rate(data_rate),
		.ht_delay_enable(fnl_ht_delay_enable),
		.mode(mode),
		.reset_scheme(fnl_reset_scheme),
		.rx_iqclk_sel(fnl_rx_iqclk_sel),
		.tx_mux_power_down(fnl_tx_mux_power_down),
		.x1_clock_source_sel(fnl_x1_clock_source_sel),
		.x1_div_m_sel(x1_div_m_sel),
		.xn_clock_source_sel(fnl_xn_clock_source_sel)
	) wys (
		// ports
		.clkbcdr1b(clkbcdr1b),
		.clkbcdr1t(clkbcdr1t),
		.clkbcdrloc(clkbcdrloc),
		.clkbdnseg(clkbdnseg),
		.clkbffpll(clkbffpll),
		.clkbupseg(clkbupseg),
		.clkcdr1b(clkcdr1b),
		.clkcdr1t(clkcdr1t),
		.clkcdrloc(clkcdrloc),
		.clkdnseg(clkdnseg),
		.clkffpll(clkffpll),
		.clkupseg(clkupseg),
		.cpulse(cpulse),
		.cpulseout(cpulseout),
		.cpulsex6dn(cpulsex6dn),
		.cpulsex6up(cpulsex6up),
		.cpulsexndn(cpulsexndn),
		.cpulsexnup(cpulsexnup),
		.hfclkn(hfclkn),
		.hfclknout(hfclknout),
		.hfclknx6dn(hfclknx6dn),
		.hfclknx6up(hfclknx6up),
		.hfclknxndn(hfclknxndn),
		.hfclknxnup(hfclknxnup),
		.hfclkp(hfclkp),
		.hfclkpout(hfclkpout),
		.hfclkpx6dn(hfclkpx6dn),
		.hfclkpx6up(hfclkpx6up),
		.hfclkpxndn(hfclkpxndn),
		.hfclkpxnup(hfclkpxnup),
		.lfclkn(lfclkn),
		.lfclknout(lfclknout),
		.lfclknx6dn(lfclknx6dn),
		.lfclknx6up(lfclknx6up),
		.lfclknxndn(lfclknxndn),
		.lfclknxnup(lfclknxnup),
		.lfclkp(lfclkp),
		.lfclkpout(lfclkpout),
		.lfclkpx6dn(lfclkpx6dn),
		.lfclkpx6up(lfclkpx6up),
		.lfclkpxndn(lfclkpxndn),
		.lfclkpxnup(lfclkpxnup),
		.pciesw(pciesw),
		.pcieswdone(pcieswdone),
		.pciesyncp(pciesyncp),
		.pclk(pclk),
		.pclk0(pclk0),
		.pclk0out(pclk0out),
		.pclk0x6adj(pclk0x6adj),
		.pclk0x6loc(pclk0x6loc),
		.pclk0xndn(pclk0xndn),
		.pclk0xnup(pclk0xnup),
		.pclk1(pclk1),
		.pclk1out(pclk1out),
		.pclk1x6adj(pclk1x6adj),
		.pclk1x6loc(pclk1x6loc),
		.pclk1xndn(pclk1xndn),
		.pclk1xnup(pclk1xnup),
		.pclkout(pclkout),
		.pclkx6dn(pclkx6dn),
		.pclkx6up(pclkx6up),
		.pclkxndn(pclkxndn),
		.pclkxnup(pclkxnup),
		.rxclk(rxclk),
		.rxiqclk(rxiqclk),
		.txpmarstb(txpmarstb)
	);
endmodule
