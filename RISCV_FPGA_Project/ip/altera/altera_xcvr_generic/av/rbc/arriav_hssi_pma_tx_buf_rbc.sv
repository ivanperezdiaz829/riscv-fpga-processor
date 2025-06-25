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


// Verilog RBC parameter resolution wrapper for arriav_hssi_pma_tx_buf
//

`timescale 1 ns / 1 ps

module arriav_hssi_pma_tx_buf_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter channel_number = 0,	// 0..65
	parameter common_mode_driver_sel = "volt_0p65v",	// grounded, pull_dn, pull_up, pull_up_to_vccela, tristated1, tristated2, tristated3, tristated4, volt_0p35v, volt_0p50v, volt_0p55v, volt_0p60v, volt_0p65v, volt_0p70v, volt_0p75v, volt_0p80v
	parameter driver_resolution_ctrl = "disabled",	// conbination1, disabled, offset_main, offset_po1
	parameter local_ib_ctl = "ib_29ohm",	// ib_22ohm, ib_29ohm, ib_42ohm, ib_49ohm
	parameter pre_emp_switching_ctrl_1st_post_tap = "fir_1pt_disabled",	// fir_1pt_1p0ma, fir_1pt_1p2ma, fir_1pt_1p4ma, fir_1pt_1p6ma, fir_1pt_1p8ma, fir_1pt_2p0ma, fir_1pt_2p2ma, fir_1pt_2p4ma, fir_1pt_2p6ma, fir_1pt_2p8ma, fir_1pt_3p0ma, fir_1pt_3p2ma, fir_1pt_3p4ma, fir_1pt_3p6ma, fir_1pt_3p8ma, fir_1pt_4p0ma, fir_1pt_4p2ma, fir_1pt_4p4ma, fir_1pt_4p6ma, fir_1pt_4p8ma, fir_1pt_5p0ma, fir_1pt_5p2ma, fir_1pt_5p4ma, fir_1pt_5p6ma, fir_1pt_5p8ma, fir_1pt_6p0ma, fir_1pt_6p2ma, fir_1pt_disabled, fir_1pt_p2ma, fir_1pt_p4ma, fir_1pt_p6ma, fir_1pt_p8ma
	parameter rx_det = "mode_0",	// mode_0, mode_1, mode_10, mode_11, mode_12, mode_13, mode_14, mode_15, mode_2, mode_3, mode_4, mode_5, mode_6, mode_7, mode_8, mode_9
	parameter rx_det_pdb = "false",	// false_true
	parameter slew_rate_ctrl = "slew_30ps",	// slew_15ps, slew_160ps, slew_30ps, slew_50ps, slew_90ps
	parameter swing_boost = "not_boost",	// boost, not_boost
	parameter term_sel = "r_100ohm",	// ext_res, r_100ohm, r_120ohm, r_150ohm, r_85ohm
	parameter vcm_current_addl = "vcm_current_default",	// vcm_current_1, vcm_current_2, vcm_current_3, vcm_current_default
	parameter vod_boost = "not_boost",	// boost, not_boost
	parameter vod_switching_ctrl_main_tap = "fir_main_2p0ma"	// fir_main_10p0ma, fir_main_10p2ma, fir_main_10p4ma, fir_main_10p6ma, fir_main_10p8ma, fir_main_11p0ma, fir_main_11p2ma, fir_main_11p4ma, fir_main_11p6ma, fir_main_11p8ma, fir_main_12p0ma, fir_main_12p2ma, fir_main_12p4ma, fir_main_12p6ma, fir_main_1p0ma, fir_main_1p2ma, fir_main_1p4ma, fir_main_1p6ma, fir_main_1p8ma, fir_main_2p0ma, fir_main_2p2ma, fir_main_2p4ma, fir_main_2p6ma, fir_main_2p8ma, fir_main_3p0ma, fir_main_3p2ma, fir_main_3p4ma, fir_main_3p6ma, fir_main_3p8ma, fir_main_4p0ma, fir_main_4p2ma, fir_main_4p4ma, fir_main_4p6ma, fir_main_4p8ma, fir_main_5p0ma, fir_main_5p2ma, fir_main_5p4ma, fir_main_5p6ma, fir_main_5p8ma, fir_main_6p0ma, fir_main_6p2ma, fir_main_6p4ma, fir_main_6p6ma, fir_main_6p8ma, fir_main_7p0ma, fir_main_7p2ma, fir_main_7p4ma, fir_main_7p6ma, fir_main_7p8ma, fir_main_8p0ma, fir_main_8p2ma, fir_main_8p4ma, fir_main_8p6ma, fir_main_8p8ma, fir_main_9p0ma, fir_main_9p2ma, fir_main_9p4ma, fir_main_9p6ma, fir_main_9p8ma, fir_main_disabled, fir_main_p2ma, fir_main_p4ma, fir_main_p6ma, fir_main_p8ma

	// constrained parameters
) (
	// ports
	output wire         	compass,
	input  wire         	datain,
	output wire         	dataout,
	output wire    [1:0]	detecton,
	output wire         	fixedclkout,
	input  wire   [11:0]	icoeff,
	output wire         	nonuserfrompmaux,
	output wire         	probepass,
	input  wire         	rxdetclk,
	output wire         	rxdetectvalid,
	output wire         	rxfound,
	input  wire         	txdetrx,
	input  wire         	txelecidl,
	input  wire         	vrlpbkn,
	input  wire         	vrlpbkn1t,
	input  wire         	vrlpbkp,
	input  wire         	vrlpbkp1t
);
	import altera_xcvr_functions::*;

	// common_mode_driver_sel external parameter (no RBC)
	localparam rbc_all_common_mode_driver_sel = "(grounded,pull_dn,pull_up,pull_up_to_vccela,tristated1,tristated2,tristated3,tristated4,volt_0p35v,volt_0p50v,volt_0p55v,volt_0p60v,volt_0p65v,volt_0p70v,volt_0p75v,volt_0p80v)";
	localparam rbc_any_common_mode_driver_sel = "volt_0p65v";
	localparam fnl_common_mode_driver_sel = (common_mode_driver_sel == "<auto_any>" || common_mode_driver_sel == "<auto_single>") ? rbc_any_common_mode_driver_sel : common_mode_driver_sel;

	// driver_resolution_ctrl external parameter (no RBC)
	localparam rbc_all_driver_resolution_ctrl = "(conbination1,disabled,offset_main,offset_po1)";
	localparam rbc_any_driver_resolution_ctrl = "disabled";
	localparam fnl_driver_resolution_ctrl = (driver_resolution_ctrl == "<auto_any>" || driver_resolution_ctrl == "<auto_single>") ? rbc_any_driver_resolution_ctrl : driver_resolution_ctrl;

	// local_ib_ctl external parameter (no RBC)
	localparam rbc_all_local_ib_ctl = "(ib_22ohm,ib_29ohm,ib_42ohm,ib_49ohm)";
	localparam rbc_any_local_ib_ctl = "ib_29ohm";
	localparam fnl_local_ib_ctl = (local_ib_ctl == "<auto_any>" || local_ib_ctl == "<auto_single>") ? rbc_any_local_ib_ctl : local_ib_ctl;

	// pre_emp_switching_ctrl_1st_post_tap external parameter (no RBC)
	localparam rbc_all_pre_emp_switching_ctrl_1st_post_tap = "(fir_1pt_1p0ma,fir_1pt_1p2ma,fir_1pt_1p4ma,fir_1pt_1p6ma,fir_1pt_1p8ma,fir_1pt_2p0ma,fir_1pt_2p2ma,fir_1pt_2p4ma,fir_1pt_2p6ma,fir_1pt_2p8ma,fir_1pt_3p0ma,fir_1pt_3p2ma,fir_1pt_3p4ma,fir_1pt_3p6ma,fir_1pt_3p8ma,fir_1pt_4p0ma,fir_1pt_4p2ma,fir_1pt_4p4ma,fir_1pt_4p6ma,fir_1pt_4p8ma,fir_1pt_5p0ma,fir_1pt_5p2ma,fir_1pt_5p4ma,fir_1pt_5p6ma,fir_1pt_5p8ma,fir_1pt_6p0ma,fir_1pt_6p2ma,fir_1pt_disabled,fir_1pt_p2ma,fir_1pt_p4ma,fir_1pt_p6ma,fir_1pt_p8ma)";
	localparam rbc_any_pre_emp_switching_ctrl_1st_post_tap = "fir_1pt_disabled";
	localparam fnl_pre_emp_switching_ctrl_1st_post_tap = (pre_emp_switching_ctrl_1st_post_tap == "<auto_any>" || pre_emp_switching_ctrl_1st_post_tap == "<auto_single>") ? rbc_any_pre_emp_switching_ctrl_1st_post_tap : pre_emp_switching_ctrl_1st_post_tap;

	// rx_det external parameter (no RBC)
	localparam rbc_all_rx_det = "(mode_0,mode_1,mode_10,mode_11,mode_12,mode_13,mode_14,mode_15,mode_2,mode_3,mode_4,mode_5,mode_6,mode_7,mode_8,mode_9)";
	localparam rbc_any_rx_det = "mode_0";
	localparam fnl_rx_det = (rx_det == "<auto_any>" || rx_det == "<auto_single>") ? rbc_any_rx_det : rx_det;

	// slew_rate_ctrl external parameter (no RBC)
	localparam rbc_all_slew_rate_ctrl = "(slew_15ps,slew_160ps,slew_30ps,slew_50ps,slew_90ps)";
	localparam rbc_any_slew_rate_ctrl = "slew_30ps";
	localparam fnl_slew_rate_ctrl = (slew_rate_ctrl == "<auto_any>" || slew_rate_ctrl == "<auto_single>") ? rbc_any_slew_rate_ctrl : slew_rate_ctrl;

	// swing_boost external parameter (no RBC)
	localparam rbc_all_swing_boost = "(boost,not_boost)";
	localparam rbc_any_swing_boost = "not_boost";
	localparam fnl_swing_boost = (swing_boost == "<auto_any>" || swing_boost == "<auto_single>") ? rbc_any_swing_boost : swing_boost;

	// term_sel external parameter (no RBC)
	localparam rbc_all_term_sel = "(ext_res,r_100ohm,r_120ohm,r_150ohm,r_85ohm)";
	localparam rbc_any_term_sel = "r_100ohm";
	localparam fnl_term_sel = (term_sel == "<auto_any>" || term_sel == "<auto_single>") ? rbc_any_term_sel : term_sel;

	// vcm_current_addl external parameter (no RBC)
	localparam rbc_all_vcm_current_addl = "(vcm_current_1,vcm_current_2,vcm_current_3,vcm_current_default)";
	localparam rbc_any_vcm_current_addl = "vcm_current_default";
	localparam fnl_vcm_current_addl = (vcm_current_addl == "<auto_any>" || vcm_current_addl == "<auto_single>") ? rbc_any_vcm_current_addl : vcm_current_addl;

	// vod_boost external parameter (no RBC)
	localparam rbc_all_vod_boost = "(boost,not_boost)";
	localparam rbc_any_vod_boost = "not_boost";
	localparam fnl_vod_boost = (vod_boost == "<auto_any>" || vod_boost == "<auto_single>") ? rbc_any_vod_boost : vod_boost;

	// vod_switching_ctrl_main_tap external parameter (no RBC)
	localparam rbc_all_vod_switching_ctrl_main_tap = "(fir_main_10p0ma,fir_main_10p2ma,fir_main_10p4ma,fir_main_10p6ma,fir_main_10p8ma,fir_main_11p0ma,fir_main_11p2ma,fir_main_11p4ma,fir_main_11p6ma,fir_main_11p8ma,fir_main_12p0ma,fir_main_12p2ma,fir_main_12p4ma,fir_main_12p6ma,fir_main_1p0ma,fir_main_1p2ma,fir_main_1p4ma,fir_main_1p6ma,fir_main_1p8ma,fir_main_2p0ma,fir_main_2p2ma,fir_main_2p4ma,fir_main_2p6ma,fir_main_2p8ma,fir_main_3p0ma,fir_main_3p2ma,fir_main_3p4ma,fir_main_3p6ma,fir_main_3p8ma,fir_main_4p0ma,fir_main_4p2ma,fir_main_4p4ma,fir_main_4p6ma,fir_main_4p8ma,fir_main_5p0ma,fir_main_5p2ma,fir_main_5p4ma,fir_main_5p6ma,fir_main_5p8ma,fir_main_6p0ma,fir_main_6p2ma,fir_main_6p4ma,fir_main_6p6ma,fir_main_6p8ma,fir_main_7p0ma,fir_main_7p2ma,fir_main_7p4ma,fir_main_7p6ma,fir_main_7p8ma,fir_main_8p0ma,fir_main_8p2ma,fir_main_8p4ma,fir_main_8p6ma,fir_main_8p8ma,fir_main_9p0ma,fir_main_9p2ma,fir_main_9p4ma,fir_main_9p6ma,fir_main_9p8ma,fir_main_disabled,fir_main_p2ma,fir_main_p4ma,fir_main_p6ma,fir_main_p8ma)";
	localparam rbc_any_vod_switching_ctrl_main_tap = "fir_main_2p0ma";
	localparam fnl_vod_switching_ctrl_main_tap = (vod_switching_ctrl_main_tap == "<auto_any>" || vod_switching_ctrl_main_tap == "<auto_single>") ? rbc_any_vod_switching_ctrl_main_tap : vod_switching_ctrl_main_tap;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("common_mode_driver_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", common_mode_driver_sel, rbc_any_common_mode_driver_sel, rbc_all_common_mode_driver_sel, fnl_common_mode_driver_sel);
		if (!is_in_legal_set(common_mode_driver_sel, rbc_all_common_mode_driver_sel)) begin
			$display("Critical Warning: parameter 'common_mode_driver_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", common_mode_driver_sel, rbc_all_common_mode_driver_sel, fnl_common_mode_driver_sel);
		end
		//$display("driver_resolution_ctrl = orig: '%s', any:'%s', all:'%s', final: '%s'", driver_resolution_ctrl, rbc_any_driver_resolution_ctrl, rbc_all_driver_resolution_ctrl, fnl_driver_resolution_ctrl);
		if (!is_in_legal_set(driver_resolution_ctrl, rbc_all_driver_resolution_ctrl)) begin
			$display("Critical Warning: parameter 'driver_resolution_ctrl' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", driver_resolution_ctrl, rbc_all_driver_resolution_ctrl, fnl_driver_resolution_ctrl);
		end
		//$display("local_ib_ctl = orig: '%s', any:'%s', all:'%s', final: '%s'", local_ib_ctl, rbc_any_local_ib_ctl, rbc_all_local_ib_ctl, fnl_local_ib_ctl);
		if (!is_in_legal_set(local_ib_ctl, rbc_all_local_ib_ctl)) begin
			$display("Critical Warning: parameter 'local_ib_ctl' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", local_ib_ctl, rbc_all_local_ib_ctl, fnl_local_ib_ctl);
		end
		//$display("pre_emp_switching_ctrl_1st_post_tap = orig: '%s', any:'%s', all:'%s', final: '%s'", pre_emp_switching_ctrl_1st_post_tap, rbc_any_pre_emp_switching_ctrl_1st_post_tap, rbc_all_pre_emp_switching_ctrl_1st_post_tap, fnl_pre_emp_switching_ctrl_1st_post_tap);
		if (!is_in_legal_set(pre_emp_switching_ctrl_1st_post_tap, rbc_all_pre_emp_switching_ctrl_1st_post_tap)) begin
			$display("Critical Warning: parameter 'pre_emp_switching_ctrl_1st_post_tap' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pre_emp_switching_ctrl_1st_post_tap, rbc_all_pre_emp_switching_ctrl_1st_post_tap, fnl_pre_emp_switching_ctrl_1st_post_tap);
		end
		//$display("rx_det = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_det, rbc_any_rx_det, rbc_all_rx_det, fnl_rx_det);
		if (!is_in_legal_set(rx_det, rbc_all_rx_det)) begin
			$display("Critical Warning: parameter 'rx_det' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_det, rbc_all_rx_det, fnl_rx_det);
		end
		//$display("slew_rate_ctrl = orig: '%s', any:'%s', all:'%s', final: '%s'", slew_rate_ctrl, rbc_any_slew_rate_ctrl, rbc_all_slew_rate_ctrl, fnl_slew_rate_ctrl);
		if (!is_in_legal_set(slew_rate_ctrl, rbc_all_slew_rate_ctrl)) begin
			$display("Critical Warning: parameter 'slew_rate_ctrl' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", slew_rate_ctrl, rbc_all_slew_rate_ctrl, fnl_slew_rate_ctrl);
		end
		//$display("swing_boost = orig: '%s', any:'%s', all:'%s', final: '%s'", swing_boost, rbc_any_swing_boost, rbc_all_swing_boost, fnl_swing_boost);
		if (!is_in_legal_set(swing_boost, rbc_all_swing_boost)) begin
			$display("Critical Warning: parameter 'swing_boost' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", swing_boost, rbc_all_swing_boost, fnl_swing_boost);
		end
		//$display("term_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", term_sel, rbc_any_term_sel, rbc_all_term_sel, fnl_term_sel);
		if (!is_in_legal_set(term_sel, rbc_all_term_sel)) begin
			$display("Critical Warning: parameter 'term_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", term_sel, rbc_all_term_sel, fnl_term_sel);
		end
		//$display("vcm_current_addl = orig: '%s', any:'%s', all:'%s', final: '%s'", vcm_current_addl, rbc_any_vcm_current_addl, rbc_all_vcm_current_addl, fnl_vcm_current_addl);
		if (!is_in_legal_set(vcm_current_addl, rbc_all_vcm_current_addl)) begin
			$display("Critical Warning: parameter 'vcm_current_addl' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", vcm_current_addl, rbc_all_vcm_current_addl, fnl_vcm_current_addl);
		end
		//$display("vod_boost = orig: '%s', any:'%s', all:'%s', final: '%s'", vod_boost, rbc_any_vod_boost, rbc_all_vod_boost, fnl_vod_boost);
		if (!is_in_legal_set(vod_boost, rbc_all_vod_boost)) begin
			$display("Critical Warning: parameter 'vod_boost' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", vod_boost, rbc_all_vod_boost, fnl_vod_boost);
		end
		//$display("vod_switching_ctrl_main_tap = orig: '%s', any:'%s', all:'%s', final: '%s'", vod_switching_ctrl_main_tap, rbc_any_vod_switching_ctrl_main_tap, rbc_all_vod_switching_ctrl_main_tap, fnl_vod_switching_ctrl_main_tap);
		if (!is_in_legal_set(vod_switching_ctrl_main_tap, rbc_all_vod_switching_ctrl_main_tap)) begin
			$display("Critical Warning: parameter 'vod_switching_ctrl_main_tap' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", vod_switching_ctrl_main_tap, rbc_all_vod_switching_ctrl_main_tap, fnl_vod_switching_ctrl_main_tap);
		end
	end

	arriav_hssi_pma_tx_buf #(
		.channel_number(channel_number),
		.common_mode_driver_sel(fnl_common_mode_driver_sel),
		.driver_resolution_ctrl(fnl_driver_resolution_ctrl),
		.local_ib_ctl(fnl_local_ib_ctl),
		.pre_emp_switching_ctrl_1st_post_tap(fnl_pre_emp_switching_ctrl_1st_post_tap),
		.rx_det(fnl_rx_det),
		.rx_det_pdb(rx_det_pdb),
		.slew_rate_ctrl(fnl_slew_rate_ctrl),
		.swing_boost(fnl_swing_boost),
		.term_sel(fnl_term_sel),
		.vcm_current_addl(fnl_vcm_current_addl),
		.vod_boost(fnl_vod_boost),
		.vod_switching_ctrl_main_tap(fnl_vod_switching_ctrl_main_tap)
	) wys (
		// ports
		.compass(compass),
		.datain(datain),
		.dataout(dataout),
		.detecton(detecton),
		.fixedclkout(fixedclkout),
		.icoeff(icoeff),
		.nonuserfrompmaux(nonuserfrompmaux),
		.probepass(probepass),
		.rxdetclk(rxdetclk),
		.rxdetectvalid(rxdetectvalid),
		.rxfound(rxfound),
		.txdetrx(txdetrx),
		.txelecidl(txelecidl),
		.vrlpbkn(vrlpbkn),
		.vrlpbkn1t(vrlpbkn1t),
		.vrlpbkp(vrlpbkp),
		.vrlpbkp1t(vrlpbkp1t)
	);
endmodule
