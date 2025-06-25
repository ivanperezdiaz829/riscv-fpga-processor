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


// Verilog RBC parameter resolution wrapper for arriav_hssi_pma_aux
//

`timescale 1 ns / 1 ps

module arriav_hssi_pma_aux_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter cal_clk_sel = "pm_aux_iqclk_cal_clk_sel_cal_clk",	// pm_aux_iqclk_cal_clk_sel_cal_clk, pm_aux_iqclk_cal_clk_sel_iqclk0, pm_aux_iqclk_cal_clk_sel_iqclk1, pm_aux_iqclk_cal_clk_sel_iqclk2, pm_aux_iqclk_cal_clk_sel_iqclk3, pm_aux_iqclk_cal_clk_sel_iqclk4, pm_aux_iqclk_cal_clk_sel_iqclk5
	parameter cal_result_status = "pm_aux_result_status_tx",	// pm_aux_result_status_rx, pm_aux_result_status_tx
	parameter continuous_calibration = "false",	// false, true
	parameter pm_aux_cal_clk_test_sel = "false",	// false, true
	parameter rx_cal_override_value = 0,	// 0..31
	parameter rx_cal_override_value_enable = "false",	// false, true
	parameter rx_imp = "cal_imp_48_ohm",	// cal_imp_46_ohm, cal_imp_48_ohm, cal_imp_50_ohm, cal_imp_52_ohm
	parameter test_counter_enable = "false",	// false, true
	parameter tx_cal_override_value = 0,	// 0..31
	parameter tx_cal_override_value_enable = "false",	// false, true
	parameter tx_imp = "cal_imp_48_ohm"	// cal_imp_46_ohm, cal_imp_48_ohm, cal_imp_50_ohm, cal_imp_52_ohm

	// constrained parameters
) (
	// ports
	input  wire         	calclk,
	input  wire         	calpdb,
	output wire         	nonusertoio,
	input  wire    [5:0]	refiqclk,
	input  wire         	testcntl,
	output wire    [4:0]	zrxtx50
);
	import altera_xcvr_functions::*;

	// cal_clk_sel external parameter (no RBC)
	localparam rbc_all_cal_clk_sel = "(pm_aux_iqclk_cal_clk_sel_cal_clk,pm_aux_iqclk_cal_clk_sel_iqclk0,pm_aux_iqclk_cal_clk_sel_iqclk1,pm_aux_iqclk_cal_clk_sel_iqclk2,pm_aux_iqclk_cal_clk_sel_iqclk3,pm_aux_iqclk_cal_clk_sel_iqclk4,pm_aux_iqclk_cal_clk_sel_iqclk5)";
	localparam rbc_any_cal_clk_sel = "pm_aux_iqclk_cal_clk_sel_cal_clk";
	localparam fnl_cal_clk_sel = (cal_clk_sel == "<auto_any>" || cal_clk_sel == "<auto_single>") ? rbc_any_cal_clk_sel : cal_clk_sel;

	// cal_result_status external parameter (no RBC)
	localparam rbc_all_cal_result_status = "(pm_aux_result_status_rx,pm_aux_result_status_tx)";
	localparam rbc_any_cal_result_status = "pm_aux_result_status_tx";
	localparam fnl_cal_result_status = (cal_result_status == "<auto_any>" || cal_result_status == "<auto_single>") ? rbc_any_cal_result_status : cal_result_status;

	// continuous_calibration external parameter (no RBC)
	localparam rbc_all_continuous_calibration = "(false,true)";
	localparam rbc_any_continuous_calibration = "false";
	localparam fnl_continuous_calibration = (continuous_calibration == "<auto_any>" || continuous_calibration == "<auto_single>") ? rbc_any_continuous_calibration : continuous_calibration;

	// pm_aux_cal_clk_test_sel external parameter (no RBC)
	localparam rbc_all_pm_aux_cal_clk_test_sel = "(false,true)";
	localparam rbc_any_pm_aux_cal_clk_test_sel = "false";
	localparam fnl_pm_aux_cal_clk_test_sel = (pm_aux_cal_clk_test_sel == "<auto_any>" || pm_aux_cal_clk_test_sel == "<auto_single>") ? rbc_any_pm_aux_cal_clk_test_sel : pm_aux_cal_clk_test_sel;

	// rx_cal_override_value_enable external parameter (no RBC)
	localparam rbc_all_rx_cal_override_value_enable = "(false,true)";
	localparam rbc_any_rx_cal_override_value_enable = "false";
	localparam fnl_rx_cal_override_value_enable = (rx_cal_override_value_enable == "<auto_any>" || rx_cal_override_value_enable == "<auto_single>") ? rbc_any_rx_cal_override_value_enable : rx_cal_override_value_enable;

	// rx_imp external parameter (no RBC)
	localparam rbc_all_rx_imp = "(cal_imp_46_ohm,cal_imp_48_ohm,cal_imp_50_ohm,cal_imp_52_ohm)";
	localparam rbc_any_rx_imp = "cal_imp_48_ohm";
	localparam fnl_rx_imp = (rx_imp == "<auto_any>" || rx_imp == "<auto_single>") ? rbc_any_rx_imp : rx_imp;

	// test_counter_enable external parameter (no RBC)
	localparam rbc_all_test_counter_enable = "(false,true)";
	localparam rbc_any_test_counter_enable = "false";
	localparam fnl_test_counter_enable = (test_counter_enable == "<auto_any>" || test_counter_enable == "<auto_single>") ? rbc_any_test_counter_enable : test_counter_enable;

	// tx_cal_override_value_enable external parameter (no RBC)
	localparam rbc_all_tx_cal_override_value_enable = "(false,true)";
	localparam rbc_any_tx_cal_override_value_enable = "false";
	localparam fnl_tx_cal_override_value_enable = (tx_cal_override_value_enable == "<auto_any>" || tx_cal_override_value_enable == "<auto_single>") ? rbc_any_tx_cal_override_value_enable : tx_cal_override_value_enable;

	// tx_imp external parameter (no RBC)
	localparam rbc_all_tx_imp = "(cal_imp_46_ohm,cal_imp_48_ohm,cal_imp_50_ohm,cal_imp_52_ohm)";
	localparam rbc_any_tx_imp = "cal_imp_48_ohm";
	localparam fnl_tx_imp = (tx_imp == "<auto_any>" || tx_imp == "<auto_single>") ? rbc_any_tx_imp : tx_imp;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("cal_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", cal_clk_sel, rbc_any_cal_clk_sel, rbc_all_cal_clk_sel, fnl_cal_clk_sel);
		if (!is_in_legal_set(cal_clk_sel, rbc_all_cal_clk_sel)) begin
			$display("Critical Warning: parameter 'cal_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cal_clk_sel, rbc_all_cal_clk_sel, fnl_cal_clk_sel);
		end
		//$display("cal_result_status = orig: '%s', any:'%s', all:'%s', final: '%s'", cal_result_status, rbc_any_cal_result_status, rbc_all_cal_result_status, fnl_cal_result_status);
		if (!is_in_legal_set(cal_result_status, rbc_all_cal_result_status)) begin
			$display("Critical Warning: parameter 'cal_result_status' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cal_result_status, rbc_all_cal_result_status, fnl_cal_result_status);
		end
		//$display("continuous_calibration = orig: '%s', any:'%s', all:'%s', final: '%s'", continuous_calibration, rbc_any_continuous_calibration, rbc_all_continuous_calibration, fnl_continuous_calibration);
		if (!is_in_legal_set(continuous_calibration, rbc_all_continuous_calibration)) begin
			$display("Critical Warning: parameter 'continuous_calibration' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", continuous_calibration, rbc_all_continuous_calibration, fnl_continuous_calibration);
		end
		//$display("pm_aux_cal_clk_test_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", pm_aux_cal_clk_test_sel, rbc_any_pm_aux_cal_clk_test_sel, rbc_all_pm_aux_cal_clk_test_sel, fnl_pm_aux_cal_clk_test_sel);
		if (!is_in_legal_set(pm_aux_cal_clk_test_sel, rbc_all_pm_aux_cal_clk_test_sel)) begin
			$display("Critical Warning: parameter 'pm_aux_cal_clk_test_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pm_aux_cal_clk_test_sel, rbc_all_pm_aux_cal_clk_test_sel, fnl_pm_aux_cal_clk_test_sel);
		end
		//$display("rx_cal_override_value_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_cal_override_value_enable, rbc_any_rx_cal_override_value_enable, rbc_all_rx_cal_override_value_enable, fnl_rx_cal_override_value_enable);
		if (!is_in_legal_set(rx_cal_override_value_enable, rbc_all_rx_cal_override_value_enable)) begin
			$display("Critical Warning: parameter 'rx_cal_override_value_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_cal_override_value_enable, rbc_all_rx_cal_override_value_enable, fnl_rx_cal_override_value_enable);
		end
		//$display("rx_imp = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_imp, rbc_any_rx_imp, rbc_all_rx_imp, fnl_rx_imp);
		if (!is_in_legal_set(rx_imp, rbc_all_rx_imp)) begin
			$display("Critical Warning: parameter 'rx_imp' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_imp, rbc_all_rx_imp, fnl_rx_imp);
		end
		//$display("test_counter_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", test_counter_enable, rbc_any_test_counter_enable, rbc_all_test_counter_enable, fnl_test_counter_enable);
		if (!is_in_legal_set(test_counter_enable, rbc_all_test_counter_enable)) begin
			$display("Critical Warning: parameter 'test_counter_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", test_counter_enable, rbc_all_test_counter_enable, fnl_test_counter_enable);
		end
		//$display("tx_cal_override_value_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_cal_override_value_enable, rbc_any_tx_cal_override_value_enable, rbc_all_tx_cal_override_value_enable, fnl_tx_cal_override_value_enable);
		if (!is_in_legal_set(tx_cal_override_value_enable, rbc_all_tx_cal_override_value_enable)) begin
			$display("Critical Warning: parameter 'tx_cal_override_value_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_cal_override_value_enable, rbc_all_tx_cal_override_value_enable, fnl_tx_cal_override_value_enable);
		end
		//$display("tx_imp = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_imp, rbc_any_tx_imp, rbc_all_tx_imp, fnl_tx_imp);
		if (!is_in_legal_set(tx_imp, rbc_all_tx_imp)) begin
			$display("Critical Warning: parameter 'tx_imp' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_imp, rbc_all_tx_imp, fnl_tx_imp);
		end
	end

	arriav_hssi_pma_aux #(
		.cal_clk_sel(fnl_cal_clk_sel),
		.cal_result_status(fnl_cal_result_status),
		.continuous_calibration(fnl_continuous_calibration),
		.pm_aux_cal_clk_test_sel(fnl_pm_aux_cal_clk_test_sel),
		.rx_cal_override_value(rx_cal_override_value),
		.rx_cal_override_value_enable(fnl_rx_cal_override_value_enable),
		.rx_imp(fnl_rx_imp),
		.test_counter_enable(fnl_test_counter_enable),
		.tx_cal_override_value(tx_cal_override_value),
		.tx_cal_override_value_enable(fnl_tx_cal_override_value_enable),
		.tx_imp(fnl_tx_imp)
	) wys (
		// ports
		.calclk(calclk),
		.calpdb(calpdb),
		.nonusertoio(nonusertoio),
		.refiqclk(refiqclk),
		.testcntl(testcntl),
		.zrxtx50(zrxtx50)
	);
endmodule
