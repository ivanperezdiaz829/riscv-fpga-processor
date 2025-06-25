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


// Verilog RBC parameter resolution wrapper for cyclonev_hssi_pma_rx_buf
//

`timescale 1 ns / 1 ps

module cyclonev_hssi_pma_rx_buf_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter cdrclk_to_cgb = "cdrclk_2cgb_dis",	// cdrclk_2cgb_dis, cdrclk_2cgb_en
	parameter channel_number = 0,	// 0..65
	parameter diagnostic_loopback = "diag_lpbk_off",	// diag_lpbk_off, diag_lpbk_on
	parameter pdb_sd = "false",	// false, true
	parameter rx_dc_gain = "dc_gain_0db",	// dc_gain_0db, dc_gain_3db
	parameter sd_off = "clk_divrx_2",	// clk_divrx_1, clk_divrx_10, clk_divrx_11, clk_divrx_12, clk_divrx_13, clk_divrx_14, clk_divrx_2, clk_divrx_3, clk_divrx_4, clk_divrx_5, clk_divrx_6, clk_divrx_7, clk_divrx_8, clk_divrx_9, force_sd_off_when_remote_tx_off_10clkdivrx, force_sd_off_when_remote_tx_off_11clkdivrx, force_sd_off_when_remote_tx_off_12clkdivrx, force_sd_off_when_remote_tx_off_13clkdivrx, force_sd_off_when_remote_tx_off_14clkdivrx, force_sd_off_when_remote_tx_off_1clkdivrx, force_sd_off_when_remote_tx_off_2clkdivrx, force_sd_off_when_remote_tx_off_3clkdivrx, force_sd_off_when_remote_tx_off_4clkdivrx, force_sd_off_when_remote_tx_off_5clkdivrx, force_sd_off_when_remote_tx_off_6clkdivrx, force_sd_off_when_remote_tx_off_7clkdivrx, force_sd_off_when_remote_tx_off_8clkdivrx, force_sd_off_when_remote_tx_off_9clkdivrx, reserved_sd_off1, reserved_sd_off2
	parameter sd_on = "data_pulse_6",	// data_pulse_10, data_pulse_12, data_pulse_14, data_pulse_16, data_pulse_18, data_pulse_20, data_pulse_22, data_pulse_24, data_pulse_26, data_pulse_28, data_pulse_30, data_pulse_4, data_pulse_6, data_pulse_8, force_sd_on, reserved_sd_on1, reserved_sd_on2
	parameter sd_threshold = "sdlv_30mv",	// sdlv_15mv, sdlv_20mv, sdlv_25mv, sdlv_30mv, sdlv_35mv, sdlv_40mv, sdlv_45mv, sdlv_50mv
	parameter term_sel = "r_100ohm",	// ext_res, r_100ohm, r_120ohm, r_150ohm, r_85ohm
	parameter vcm_current_add = "vcm_current_default",	// vcm_current_1, vcm_current_2, vcm_current_3, vcm_current_default
	parameter vcm_sel = "vtt_0p70v"	// tristate1, tristate2, tristate3, tristate4, vtt_0p35v, vtt_0p50v, vtt_0p55v, vtt_0p60v, vtt_0p65v, vtt_0p70v, vtt_0p75v, vtt_0p80v, vtt_pdn_strong, vtt_pdn_weak, vtt_pup_strong, vtt_pup_weak

	// constrained parameters
) (
	// ports
	input  wire         	ck0sigdet,
	input  wire         	datain,
	output wire         	dataout,
	input  wire         	lpbkp,
	output wire         	nonuserfrompmaux,
	output wire         	rdlpbkp,
	input  wire         	rstn,
	output wire         	sd,
	input  wire         	slpbk
);
	import altera_xcvr_functions::*;

	// cdrclk_to_cgb external parameter (no RBC)
	localparam rbc_all_cdrclk_to_cgb = "(cdrclk_2cgb_dis,cdrclk_2cgb_en)";
	localparam rbc_any_cdrclk_to_cgb = "cdrclk_2cgb_dis";
	localparam fnl_cdrclk_to_cgb = (cdrclk_to_cgb == "<auto_any>" || cdrclk_to_cgb == "<auto_single>") ? rbc_any_cdrclk_to_cgb : cdrclk_to_cgb;

	// diagnostic_loopback external parameter (no RBC)
	localparam rbc_all_diagnostic_loopback = "(diag_lpbk_off,diag_lpbk_on)";
	localparam rbc_any_diagnostic_loopback = "diag_lpbk_off";
	localparam fnl_diagnostic_loopback = (diagnostic_loopback == "<auto_any>" || diagnostic_loopback == "<auto_single>") ? rbc_any_diagnostic_loopback : diagnostic_loopback;

	// pdb_sd external parameter (no RBC)
	localparam rbc_all_pdb_sd = "(false,true)";
	localparam rbc_any_pdb_sd = "false";
	localparam fnl_pdb_sd = (pdb_sd == "<auto_any>" || pdb_sd == "<auto_single>") ? rbc_any_pdb_sd : pdb_sd;

	// rx_dc_gain external parameter (no RBC)
	localparam rbc_all_rx_dc_gain = "(dc_gain_0db,dc_gain_3db)";
	localparam rbc_any_rx_dc_gain = "dc_gain_0db";
	localparam fnl_rx_dc_gain = (rx_dc_gain == "<auto_any>" || rx_dc_gain == "<auto_single>") ? rbc_any_rx_dc_gain : rx_dc_gain;

	// sd_off external parameter (no RBC)
	localparam rbc_all_sd_off = "(clk_divrx_1,clk_divrx_10,clk_divrx_11,clk_divrx_12,clk_divrx_13,clk_divrx_14,clk_divrx_2,clk_divrx_3,clk_divrx_4,clk_divrx_5,clk_divrx_6,clk_divrx_7,clk_divrx_8,clk_divrx_9,force_sd_off_when_remote_tx_off_10clkdivrx,force_sd_off_when_remote_tx_off_11clkdivrx,force_sd_off_when_remote_tx_off_12clkdivrx,force_sd_off_when_remote_tx_off_13clkdivrx,force_sd_off_when_remote_tx_off_14clkdivrx,force_sd_off_when_remote_tx_off_1clkdivrx,force_sd_off_when_remote_tx_off_2clkdivrx,force_sd_off_when_remote_tx_off_3clkdivrx,force_sd_off_when_remote_tx_off_4clkdivrx,force_sd_off_when_remote_tx_off_5clkdivrx,force_sd_off_when_remote_tx_off_6clkdivrx,force_sd_off_when_remote_tx_off_7clkdivrx,force_sd_off_when_remote_tx_off_8clkdivrx,force_sd_off_when_remote_tx_off_9clkdivrx,reserved_sd_off1,reserved_sd_off2)";
	localparam rbc_any_sd_off = "clk_divrx_2";
	localparam fnl_sd_off = (sd_off == "<auto_any>" || sd_off == "<auto_single>") ? rbc_any_sd_off : sd_off;

	// sd_on external parameter (no RBC)
	localparam rbc_all_sd_on = "(data_pulse_10,data_pulse_12,data_pulse_14,data_pulse_16,data_pulse_18,data_pulse_20,data_pulse_22,data_pulse_24,data_pulse_26,data_pulse_28,data_pulse_30,data_pulse_4,data_pulse_6,data_pulse_8,force_sd_on,reserved_sd_on1,reserved_sd_on2)";
	localparam rbc_any_sd_on = "data_pulse_6";
	localparam fnl_sd_on = (sd_on == "<auto_any>" || sd_on == "<auto_single>") ? rbc_any_sd_on : sd_on;

	// sd_threshold external parameter (no RBC)
	localparam rbc_all_sd_threshold = "(sdlv_15mv,sdlv_20mv,sdlv_25mv,sdlv_30mv,sdlv_35mv,sdlv_40mv,sdlv_45mv,sdlv_50mv)";
	localparam rbc_any_sd_threshold = "sdlv_30mv";
	localparam fnl_sd_threshold = (sd_threshold == "<auto_any>" || sd_threshold == "<auto_single>") ? rbc_any_sd_threshold : sd_threshold;

	// term_sel external parameter (no RBC)
	localparam rbc_all_term_sel = "(ext_res,r_100ohm,r_120ohm,r_150ohm,r_85ohm)";
	localparam rbc_any_term_sel = "r_100ohm";
	localparam fnl_term_sel = (term_sel == "<auto_any>" || term_sel == "<auto_single>") ? rbc_any_term_sel : term_sel;

	// vcm_current_add external parameter (no RBC)
	localparam rbc_all_vcm_current_add = "(vcm_current_1,vcm_current_2,vcm_current_3,vcm_current_default)";
	localparam rbc_any_vcm_current_add = "vcm_current_default";
	localparam fnl_vcm_current_add = (vcm_current_add == "<auto_any>" || vcm_current_add == "<auto_single>") ? rbc_any_vcm_current_add : vcm_current_add;

	// vcm_sel external parameter (no RBC)
	localparam rbc_all_vcm_sel = "(tristate1,tristate2,tristate3,tristate4,vtt_0p35v,vtt_0p50v,vtt_0p55v,vtt_0p60v,vtt_0p65v,vtt_0p70v,vtt_0p75v,vtt_0p80v,vtt_pdn_strong,vtt_pdn_weak,vtt_pup_strong,vtt_pup_weak)";
	localparam rbc_any_vcm_sel = "vtt_0p70v";
	localparam fnl_vcm_sel = (vcm_sel == "<auto_any>" || vcm_sel == "<auto_single>") ? rbc_any_vcm_sel : vcm_sel;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("cdrclk_to_cgb = orig: '%s', any:'%s', all:'%s', final: '%s'", cdrclk_to_cgb, rbc_any_cdrclk_to_cgb, rbc_all_cdrclk_to_cgb, fnl_cdrclk_to_cgb);
		if (!is_in_legal_set(cdrclk_to_cgb, rbc_all_cdrclk_to_cgb)) begin
			$display("Critical Warning: parameter 'cdrclk_to_cgb' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cdrclk_to_cgb, rbc_all_cdrclk_to_cgb, fnl_cdrclk_to_cgb);
		end
		//$display("diagnostic_loopback = orig: '%s', any:'%s', all:'%s', final: '%s'", diagnostic_loopback, rbc_any_diagnostic_loopback, rbc_all_diagnostic_loopback, fnl_diagnostic_loopback);
		if (!is_in_legal_set(diagnostic_loopback, rbc_all_diagnostic_loopback)) begin
			$display("Critical Warning: parameter 'diagnostic_loopback' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", diagnostic_loopback, rbc_all_diagnostic_loopback, fnl_diagnostic_loopback);
		end
		//$display("pdb_sd = orig: '%s', any:'%s', all:'%s', final: '%s'", pdb_sd, rbc_any_pdb_sd, rbc_all_pdb_sd, fnl_pdb_sd);
		if (!is_in_legal_set(pdb_sd, rbc_all_pdb_sd)) begin
			$display("Critical Warning: parameter 'pdb_sd' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pdb_sd, rbc_all_pdb_sd, fnl_pdb_sd);
		end
		//$display("rx_dc_gain = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_dc_gain, rbc_any_rx_dc_gain, rbc_all_rx_dc_gain, fnl_rx_dc_gain);
		if (!is_in_legal_set(rx_dc_gain, rbc_all_rx_dc_gain)) begin
			$display("Critical Warning: parameter 'rx_dc_gain' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_dc_gain, rbc_all_rx_dc_gain, fnl_rx_dc_gain);
		end
		//$display("sd_off = orig: '%s', any:'%s', all:'%s', final: '%s'", sd_off, rbc_any_sd_off, rbc_all_sd_off, fnl_sd_off);
		if (!is_in_legal_set(sd_off, rbc_all_sd_off)) begin
			$display("Critical Warning: parameter 'sd_off' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sd_off, rbc_all_sd_off, fnl_sd_off);
		end
		//$display("sd_on = orig: '%s', any:'%s', all:'%s', final: '%s'", sd_on, rbc_any_sd_on, rbc_all_sd_on, fnl_sd_on);
		if (!is_in_legal_set(sd_on, rbc_all_sd_on)) begin
			$display("Critical Warning: parameter 'sd_on' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sd_on, rbc_all_sd_on, fnl_sd_on);
		end
		//$display("sd_threshold = orig: '%s', any:'%s', all:'%s', final: '%s'", sd_threshold, rbc_any_sd_threshold, rbc_all_sd_threshold, fnl_sd_threshold);
		if (!is_in_legal_set(sd_threshold, rbc_all_sd_threshold)) begin
			$display("Critical Warning: parameter 'sd_threshold' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sd_threshold, rbc_all_sd_threshold, fnl_sd_threshold);
		end
		//$display("term_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", term_sel, rbc_any_term_sel, rbc_all_term_sel, fnl_term_sel);
		if (!is_in_legal_set(term_sel, rbc_all_term_sel)) begin
			$display("Critical Warning: parameter 'term_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", term_sel, rbc_all_term_sel, fnl_term_sel);
		end
		//$display("vcm_current_add = orig: '%s', any:'%s', all:'%s', final: '%s'", vcm_current_add, rbc_any_vcm_current_add, rbc_all_vcm_current_add, fnl_vcm_current_add);
		if (!is_in_legal_set(vcm_current_add, rbc_all_vcm_current_add)) begin
			$display("Critical Warning: parameter 'vcm_current_add' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", vcm_current_add, rbc_all_vcm_current_add, fnl_vcm_current_add);
		end
		//$display("vcm_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", vcm_sel, rbc_any_vcm_sel, rbc_all_vcm_sel, fnl_vcm_sel);
		if (!is_in_legal_set(vcm_sel, rbc_all_vcm_sel)) begin
			$display("Critical Warning: parameter 'vcm_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", vcm_sel, rbc_all_vcm_sel, fnl_vcm_sel);
		end
	end

	cyclonev_hssi_pma_rx_buf #(
		.cdrclk_to_cgb(fnl_cdrclk_to_cgb),
		.channel_number(channel_number),
		.diagnostic_loopback(fnl_diagnostic_loopback),
		.pdb_sd(fnl_pdb_sd),
		.rx_dc_gain(fnl_rx_dc_gain),
		.sd_off(fnl_sd_off),
		.sd_on(fnl_sd_on),
		.sd_threshold(fnl_sd_threshold),
		.term_sel(fnl_term_sel),
		.vcm_current_add(fnl_vcm_current_add),
		.vcm_sel(fnl_vcm_sel)
	) wys (
		// ports
		.ck0sigdet(ck0sigdet),
		.datain(datain),
		.dataout(dataout),
		.lpbkp(lpbkp),
		.nonuserfrompmaux(nonuserfrompmaux),
		.rdlpbkp(rdlpbkp),
		.rstn(rstn),
		.sd(sd),
		.slpbk(slpbk)
	);
endmodule
