// (C) 2001-2011 Altera Corporation. All rights reserved.
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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_common_pcs_pma_interface
//

`timescale 1 ns / 1 ps

module stratixv_hssi_common_pcs_pma_interface_rbc #(
	// unconstrained parameters
	parameter func_mode = "<auto_single>",	// disable, eightg_and_g3, eightg_only_emsip, eightg_only_pld, eightgrx_and_tengtx, eightgtx_and_tengrx, hrdrstctrl_cmu, pma_direct, teng_only
	parameter prot_mode = "<auto_single>",	// disabled_prot_mode, other_protocols, pipe_g1, pipe_g2, pipe_g3
	parameter sup_mode = "<auto_single>",	// engineering_mode, stretch_mode, user_mode

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter pcie_gen3_cap = "non_pcie_gen3_cap",	// non_pcie_gen3_cap, pcie_gen3_cap
	parameter pma_if_dft_en = "dft_dis",	// dft_dis
	parameter pma_if_dft_val = "dft_0",	// dft_0
	parameter refclk_dig_sel = "refclk_dig_dis",	// refclk_dig_dis, refclk_dig_en
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047

	// constrained parameters
	parameter pipe_if_g3pcs = "<auto_single>",	// pipe_if_8gpcs, pipe_if_g3pcs
	parameter selectpcs = "<auto_single>",	// eight_g_pcs, pcie_gen3
	parameter force_freqdet = "<auto_single>",	// force0_freqdet_en, force1_freqdet_en, force_freqdet_dis
	parameter ppmsel = "<auto_single>",	// ppm_other, ppmsel_100, ppmsel_1000, ppmsel_125, ppmsel_200, ppmsel_250, ppmsel_300, ppmsel_500, ppmsel_62p5, ppmsel_default
	parameter auto_speed_ena = "<auto_single>",	// dis_auto_speed_ena, en_auto_speed_ena
	parameter ppm_cnt_rst = "<auto_single>",	// ppm_cnt_rst_dis, ppm_cnt_rst_en
	parameter ppm_gen1_2_cnt = "<auto_single>",	// cnt_32k, cnt_64k
	parameter ppm_post_eidle_delay = "<auto_single>",	// cnt_200_cycles, cnt_400_cycles
	parameter ppm_deassert_early = "<auto_single>"	// deassert_early_dis, deassert_early_en
) (
	// ports
	output wire    [1:0]	aggaligndetsync,
	input  wire         	aggalignstatus,
	output wire         	aggalignstatussync,
	input  wire         	aggalignstatussync0,
	input  wire         	aggalignstatussync0toporbot,
	input  wire         	aggalignstatustoporbot,
	input  wire         	aggcgcomprddall,
	input  wire         	aggcgcomprddalltoporbot,
	output wire    [1:0]	aggcgcomprddout,
	input  wire         	aggcgcompwrall,
	input  wire         	aggcgcompwralltoporbot,
	output wire    [1:0]	aggcgcompwrout,
	output wire         	aggdecctl,
	output wire    [7:0]	aggdecdata,
	output wire         	aggdecdatavalid,
	input  wire         	aggdelcondmet0,
	input  wire         	aggdelcondmet0toporbot,
	output wire         	aggdelcondmetout,
	input  wire         	aggendskwqd,
	input  wire         	aggendskwqdtoporbot,
	input  wire         	aggendskwrdptrs,
	input  wire         	aggendskwrdptrstoporbot,
	input  wire         	aggfifoovr0,
	input  wire         	aggfifoovr0toporbot,
	output wire         	aggfifoovrout,
	input  wire         	aggfifordincomp0,
	input  wire         	aggfifordincomp0toporbot,
	output wire         	aggfifordoutcomp,
	input  wire         	aggfiforstrdqd,
	input  wire         	aggfiforstrdqdtoporbot,
	input  wire         	agginsertincomplete0,
	input  wire         	agginsertincomplete0toporbot,
	output wire         	agginsertincompleteout,
	input  wire         	agglatencycomp0,
	input  wire         	agglatencycomp0toporbot,
	output wire         	agglatencycompout,
	input  wire         	aggrcvdclkagg,
	input  wire         	aggrcvdclkaggtoporbot,
	output wire    [1:0]	aggrdalign,
	output wire         	aggrdenablesync,
	output wire         	aggrefclkdig,
	output wire    [1:0]	aggrunningdisp,
	input  wire         	aggrxcontrolrs,
	input  wire         	aggrxcontrolrstoporbot,
	input  wire    [7:0]	aggrxdatars,
	input  wire    [7:0]	aggrxdatarstoporbot,
	output wire         	aggrxpcsrst,
	output wire         	aggscanmoden,
	output wire         	aggscanshiftn,
	output wire         	aggsyncstatus,
	input  wire   [15:0]	aggtestbus,
	input  wire         	aggtestsotopldin,
	output wire         	aggtestsotopldout,
	output wire         	aggtxctltc,
	input  wire         	aggtxctlts,
	input  wire         	aggtxctltstoporbot,
	output wire    [7:0]	aggtxdatatc,
	input  wire    [7:0]	aggtxdatats,
	input  wire    [7:0]	aggtxdatatstoporbot,
	output wire         	aggtxpcsrst,
	output wire         	asynchdatain,
	input  wire   [10:0]	avmmaddress,
	input  wire    [1:0]	avmmbyteen,
	input  wire         	avmmclk,
	input  wire         	avmmread,
	output wire   [15:0]	avmmreaddata,
	input  wire         	avmmrstn,
	input  wire         	avmmwrite,
	input  wire   [15:0]	avmmwritedata,
	output wire         	blockselect,
	input  wire         	clklow,
	input  wire         	fref,
	output wire         	freqlock,
	input  wire         	hardreset,
	input  wire         	pcs8gearlyeios,
	input  wire         	pcs8geidleexit,
	output wire         	pcs8ggen2ngen1,
	input  wire         	pcs8gltrpma,
	input  wire         	pcs8gpcieswitch,
	input  wire   [17:0]	pcs8gpmacurrentcoeff,
	output wire         	pcs8gpmarxfound,
	output wire         	pcs8gpowerstatetransitiondone,
	output wire         	pcs8grxdetectvalid,
	input  wire         	pcs8gtxdetectrx,
	input  wire         	pcs8gtxelecidle,
	input  wire    [1:0]	pcsaggaligndetsync,
	output wire         	pcsaggalignstatus,
	input  wire         	pcsaggalignstatussync,
	output wire         	pcsaggalignstatussync0,
	output wire         	pcsaggalignstatussync0toporbot,
	output wire         	pcsaggalignstatustoporbot,
	output wire         	pcsaggcgcomprddall,
	output wire         	pcsaggcgcomprddalltoporbot,
	input  wire    [1:0]	pcsaggcgcomprddout,
	output wire         	pcsaggcgcompwrall,
	output wire         	pcsaggcgcompwralltoporbot,
	input  wire    [1:0]	pcsaggcgcompwrout,
	input  wire         	pcsaggdecctl,
	input  wire    [7:0]	pcsaggdecdata,
	input  wire         	pcsaggdecdatavalid,
	output wire         	pcsaggdelcondmet0,
	output wire         	pcsaggdelcondmet0toporbot,
	input  wire         	pcsaggdelcondmetout,
	output wire         	pcsaggendskwqd,
	output wire         	pcsaggendskwqdtoporbot,
	output wire         	pcsaggendskwrdptrs,
	output wire         	pcsaggendskwrdptrstoporbot,
	output wire         	pcsaggfifoovr0,
	output wire         	pcsaggfifoovr0toporbot,
	input  wire         	pcsaggfifoovrout,
	output wire         	pcsaggfifordincomp0,
	output wire         	pcsaggfifordincomp0toporbot,
	input  wire         	pcsaggfifordoutcomp,
	output wire         	pcsaggfiforstrdqd,
	output wire         	pcsaggfiforstrdqdtoporbot,
	output wire         	pcsagginsertincomplete0,
	output wire         	pcsagginsertincomplete0toporbot,
	input  wire         	pcsagginsertincompleteout,
	output wire         	pcsagglatencycomp0,
	output wire         	pcsagglatencycomp0toporbot,
	input  wire         	pcsagglatencycompout,
	output wire         	pcsaggrcvdclkagg,
	output wire         	pcsaggrcvdclkaggtoporbot,
	input  wire    [1:0]	pcsaggrdalign,
	input  wire         	pcsaggrdenablesync,
	input  wire         	pcsaggrefclkdig,
	input  wire    [1:0]	pcsaggrunningdisp,
	output wire         	pcsaggrxcontrolrs,
	output wire         	pcsaggrxcontrolrstoporbot,
	output wire    [7:0]	pcsaggrxdatars,
	output wire    [7:0]	pcsaggrxdatarstoporbot,
	input  wire         	pcsaggrxpcsrst,
	input  wire         	pcsaggscanmoden,
	input  wire         	pcsaggscanshiftn,
	input  wire         	pcsaggsyncstatus,
	output wire   [15:0]	pcsaggtestbus,
	input  wire         	pcsaggtxctltc,
	output wire         	pcsaggtxctlts,
	output wire         	pcsaggtxctltstoporbot,
	input  wire    [7:0]	pcsaggtxdatatc,
	output wire    [7:0]	pcsaggtxdatats,
	output wire    [7:0]	pcsaggtxdatatstoporbot,
	input  wire         	pcsaggtxpcsrst,
	input  wire         	pcsgen3gen3datasel,
	output wire         	pcsgen3pllfixedclk,
	input  wire   [17:0]	pcsgen3pmacurrentcoeff,
	input  wire    [2:0]	pcsgen3pmacurrentrxpreset,
	input  wire         	pcsgen3pmaearlyeios,
	input  wire         	pcsgen3pmaltr,
	output wire    [1:0]	pcsgen3pmapcieswdone,
	input  wire    [1:0]	pcsgen3pmapcieswitch,
	output wire         	pcsgen3pmarxdetectvalid,
	output wire         	pcsgen3pmarxfound,
	input  wire         	pcsgen3pmatxdetectrx,
	input  wire         	pcsgen3pmatxelecidle,
	input  wire         	pcsgen3ppmeidleexit,
	input  wire         	pcsrefclkdig,
	input  wire         	pcsscanmoden,
	input  wire         	pcsscanshiftn,
	output wire         	pldhclkout,
	input  wire         	pldlccmurstb,
	input  wire         	pldnfrzdrv,
	input  wire         	pldpartialreconfig,
	input  wire         	pldtestsitoaggin,
	output wire         	pldtestsitoaggout,
	output wire         	pmaclklowout,
	output wire   [17:0]	pmacurrentcoeff,
	output wire    [2:0]	pmacurrentrxpreset,
	output wire         	pmaearlyeios,
	output wire         	pmafrefout,
	input  wire         	pmahclk,
	output wire    [9:0]	pmaiftestbus,
	output wire         	pmalccmurstb,
	output wire         	pmaltr,
	output wire         	pmanfrzdrv,
	output wire         	pmaoffcaldone,
	input  wire         	pmaoffcalenin,
	output wire         	pmapartialreconfig,
	input  wire    [1:0]	pmapcieswdone,
	output wire    [1:0]	pmapcieswitch,
	input  wire         	pmarxdetectvalid,
	input  wire         	pmarxfound,
	input  wire         	pmarxpmarstb,
	output wire         	pmatxdetectrx,
	output wire         	pmatxelecidle,
	input  wire         	resetppmcntrs
);
	import altera_xcvr_functions::*;

	// func_mode external parameter (no RBC)
	localparam rbc_all_func_mode = "(disable,eightg_and_g3,eightg_only_emsip,eightg_only_pld,eightgrx_and_tengtx,eightgtx_and_tengrx,hrdrstctrl_cmu,pma_direct,teng_only)";
	localparam rbc_any_func_mode = "disable";
	localparam fnl_func_mode = (func_mode == "<auto_any>" || func_mode == "<auto_single>") ? rbc_any_func_mode : func_mode;

	// prot_mode external parameter (no RBC)
	localparam rbc_all_prot_mode = "(disabled_prot_mode,other_protocols,pipe_g1,pipe_g2,pipe_g3)";
	localparam rbc_any_prot_mode = "disabled_prot_mode";
	localparam fnl_prot_mode = (prot_mode == "<auto_any>" || prot_mode == "<auto_single>") ? rbc_any_prot_mode : prot_mode;

	// sup_mode external parameter (no RBC)
	localparam rbc_all_sup_mode = "(engineering_mode,stretch_mode,user_mode)";
	localparam rbc_any_sup_mode = "user_mode";
	localparam fnl_sup_mode = (sup_mode == "<auto_any>" || sup_mode == "<auto_single>") ? rbc_any_sup_mode : sup_mode;

	// pcie_gen3_cap external parameter (no RBC)
	localparam rbc_all_pcie_gen3_cap = "(non_pcie_gen3_cap,pcie_gen3_cap)";
	localparam rbc_any_pcie_gen3_cap = "non_pcie_gen3_cap";
	localparam fnl_pcie_gen3_cap = (pcie_gen3_cap == "<auto_any>" || pcie_gen3_cap == "<auto_single>") ? rbc_any_pcie_gen3_cap : pcie_gen3_cap;

	// refclk_dig_sel external parameter (no RBC)
	localparam rbc_all_refclk_dig_sel = "(refclk_dig_dis,refclk_dig_en)";
	localparam rbc_any_refclk_dig_sel = "refclk_dig_dis";
	localparam fnl_refclk_dig_sel = (refclk_dig_sel == "<auto_any>" || refclk_dig_sel == "<auto_single>") ? rbc_any_refclk_dig_sel : refclk_dig_sel;

	// use_default_base_address external parameter (no RBC)
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// pipe_if_g3pcs, RBC-validated
	localparam rbc_all_pipe_if_g3pcs = (fnl_func_mode == "eightg_and_g3" || fnl_func_mode == "eightg_only_emsip") ? ("pipe_if_g3pcs") : "pipe_if_8gpcs";
	localparam rbc_any_pipe_if_g3pcs = (fnl_func_mode == "eightg_and_g3" || fnl_func_mode == "eightg_only_emsip") ? ("pipe_if_g3pcs") : "pipe_if_8gpcs";
	localparam fnl_pipe_if_g3pcs = (pipe_if_g3pcs == "<auto_any>" || pipe_if_g3pcs == "<auto_single>") ? rbc_any_pipe_if_g3pcs : pipe_if_g3pcs;

	// selectpcs, RBC-validated
	localparam rbc_all_selectpcs = (fnl_prot_mode == "pipe_g3") ? ("pcie_gen3") : "eight_g_pcs";
	localparam rbc_any_selectpcs = (fnl_prot_mode == "pipe_g3") ? ("pcie_gen3") : "eight_g_pcs";
	localparam fnl_selectpcs = (selectpcs == "<auto_any>" || selectpcs == "<auto_single>") ? rbc_any_selectpcs : selectpcs;

	// force_freqdet, RBC-validated
	localparam rbc_all_force_freqdet = ( (fnl_prot_mode == "disabled_prot_mode") ||  (fnl_prot_mode == "pipe_g1") || (fnl_prot_mode == "pipe_g2") || (fnl_prot_mode == "pipe_g3") || (fnl_func_mode == "hrdrstctrl_cmu")) ? ("force_freqdet_dis") : "(force_freqdet_dis,force1_freqdet_en,force0_freqdet_en)";
	localparam rbc_any_force_freqdet = ( (fnl_prot_mode == "disabled_prot_mode") ||  (fnl_prot_mode == "pipe_g1") || (fnl_prot_mode == "pipe_g2") || (fnl_prot_mode == "pipe_g3") || (fnl_func_mode == "hrdrstctrl_cmu")) ? ("force_freqdet_dis") : "force_freqdet_dis";
	localparam fnl_force_freqdet = (force_freqdet == "<auto_any>" || force_freqdet == "<auto_single>") ? rbc_any_force_freqdet : force_freqdet;

	// ppmsel, RBC-validated
	localparam rbc_all_ppmsel = ( (fnl_force_freqdet != "force_freqdet_dis") || (fnl_prot_mode == "disabled_prot_mode") || (fnl_func_mode == "hrdrstctrl_cmu")) ? ("ppmsel_default") : "(ppmsel_default,ppmsel_1000,ppmsel_500,ppmsel_300,ppmsel_250,ppmsel_200,ppmsel_125,ppmsel_100,ppmsel_62p5,ppm_other)";
	localparam rbc_any_ppmsel = ( (fnl_force_freqdet != "force_freqdet_dis") || (fnl_prot_mode == "disabled_prot_mode") || (fnl_func_mode == "hrdrstctrl_cmu")) ? ("ppmsel_default") : "ppmsel_default";
	localparam fnl_ppmsel = (ppmsel == "<auto_any>" || ppmsel == "<auto_single>") ? rbc_any_ppmsel : ppmsel;

	// auto_speed_ena, RBC-validated
	localparam rbc_all_auto_speed_ena = (fnl_prot_mode == "pipe_g2" || fnl_prot_mode == "pipe_g3") ? ("en_auto_speed_ena") : "dis_auto_speed_ena";
	localparam rbc_any_auto_speed_ena = (fnl_prot_mode == "pipe_g2" || fnl_prot_mode == "pipe_g3") ? ("en_auto_speed_ena") : "dis_auto_speed_ena";
	localparam fnl_auto_speed_ena = (auto_speed_ena == "<auto_any>" || auto_speed_ena == "<auto_single>") ? rbc_any_auto_speed_ena : auto_speed_ena;

	// ppm_cnt_rst, RBC-validated
	localparam rbc_all_ppm_cnt_rst = "ppm_cnt_rst_dis";
	localparam rbc_any_ppm_cnt_rst = "ppm_cnt_rst_dis";
	localparam fnl_ppm_cnt_rst = (ppm_cnt_rst == "<auto_any>" || ppm_cnt_rst == "<auto_single>") ? rbc_any_ppm_cnt_rst : ppm_cnt_rst;

	// ppm_gen1_2_cnt, RBC-validated
	localparam rbc_all_ppm_gen1_2_cnt = ((fnl_sup_mode == "engineering_mode") && ((fnl_prot_mode == "pipe_g2") || (fnl_prot_mode == "pipe_g1"))) ? ("(cnt_32k,cnt_64k)") : "cnt_32k";
	localparam rbc_any_ppm_gen1_2_cnt = ((fnl_sup_mode == "engineering_mode") && ((fnl_prot_mode == "pipe_g2") || (fnl_prot_mode == "pipe_g1"))) ? ("cnt_32k") : "cnt_32k";
	localparam fnl_ppm_gen1_2_cnt = (ppm_gen1_2_cnt == "<auto_any>" || ppm_gen1_2_cnt == "<auto_single>") ? rbc_any_ppm_gen1_2_cnt : ppm_gen1_2_cnt;

	// ppm_post_eidle_delay, RBC-validated
	localparam rbc_all_ppm_post_eidle_delay = (fnl_prot_mode == "pipe_g1" || fnl_prot_mode == "pipe_g2" || fnl_prot_mode == "pipe_g3") ? ("(cnt_200_cycles,cnt_400_cycles)") : "cnt_200_cycles";
	localparam rbc_any_ppm_post_eidle_delay = (fnl_prot_mode == "pipe_g1" || fnl_prot_mode == "pipe_g2" || fnl_prot_mode == "pipe_g3") ? ("cnt_200_cycles") : "cnt_200_cycles";
	localparam fnl_ppm_post_eidle_delay = (ppm_post_eidle_delay == "<auto_any>" || ppm_post_eidle_delay == "<auto_single>") ? rbc_any_ppm_post_eidle_delay : ppm_post_eidle_delay;

	// ppm_deassert_early, RBC-validated
	localparam rbc_all_ppm_deassert_early = (fnl_prot_mode == "pipe_g3") ? ("deassert_early_en") : "deassert_early_dis";
	localparam rbc_any_ppm_deassert_early = (fnl_prot_mode == "pipe_g3") ? ("deassert_early_en") : "deassert_early_dis";
	localparam fnl_ppm_deassert_early = (ppm_deassert_early == "<auto_any>" || ppm_deassert_early == "<auto_single>") ? rbc_any_ppm_deassert_early : ppm_deassert_early;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("func_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", func_mode, rbc_any_func_mode, rbc_all_func_mode, fnl_func_mode);
		if (!is_in_legal_set(func_mode, rbc_all_func_mode)) begin
			$display("Critical Warning: parameter 'func_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", func_mode, rbc_all_func_mode, fnl_func_mode);
		end
		//$display("prot_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", prot_mode, rbc_any_prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		if (!is_in_legal_set(prot_mode, rbc_all_prot_mode)) begin
			$display("Critical Warning: parameter 'prot_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		end
		//$display("sup_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", sup_mode, rbc_any_sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		if (!is_in_legal_set(sup_mode, rbc_all_sup_mode)) begin
			$display("Critical Warning: parameter 'sup_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		end
		//$display("pcie_gen3_cap = orig: '%s', any:'%s', all:'%s', final: '%s'", pcie_gen3_cap, rbc_any_pcie_gen3_cap, rbc_all_pcie_gen3_cap, fnl_pcie_gen3_cap);
		if (!is_in_legal_set(pcie_gen3_cap, rbc_all_pcie_gen3_cap)) begin
			$display("Critical Warning: parameter 'pcie_gen3_cap' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pcie_gen3_cap, rbc_all_pcie_gen3_cap, fnl_pcie_gen3_cap);
		end
		//$display("refclk_dig_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", refclk_dig_sel, rbc_any_refclk_dig_sel, rbc_all_refclk_dig_sel, fnl_refclk_dig_sel);
		if (!is_in_legal_set(refclk_dig_sel, rbc_all_refclk_dig_sel)) begin
			$display("Critical Warning: parameter 'refclk_dig_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", refclk_dig_sel, rbc_all_refclk_dig_sel, fnl_refclk_dig_sel);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
		//$display("pipe_if_g3pcs = orig: '%s', any:'%s', all:'%s', final: '%s'", pipe_if_g3pcs, rbc_any_pipe_if_g3pcs, rbc_all_pipe_if_g3pcs, fnl_pipe_if_g3pcs);
		if (!is_in_legal_set(pipe_if_g3pcs, rbc_all_pipe_if_g3pcs)) begin
			$display("Critical Warning: parameter 'pipe_if_g3pcs' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pipe_if_g3pcs, rbc_all_pipe_if_g3pcs, fnl_pipe_if_g3pcs);
		end
		//$display("selectpcs = orig: '%s', any:'%s', all:'%s', final: '%s'", selectpcs, rbc_any_selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		if (!is_in_legal_set(selectpcs, rbc_all_selectpcs)) begin
			$display("Critical Warning: parameter 'selectpcs' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		end
		//$display("force_freqdet = orig: '%s', any:'%s', all:'%s', final: '%s'", force_freqdet, rbc_any_force_freqdet, rbc_all_force_freqdet, fnl_force_freqdet);
		if (!is_in_legal_set(force_freqdet, rbc_all_force_freqdet)) begin
			$display("Critical Warning: parameter 'force_freqdet' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", force_freqdet, rbc_all_force_freqdet, fnl_force_freqdet);
		end
		//$display("ppmsel = orig: '%s', any:'%s', all:'%s', final: '%s'", ppmsel, rbc_any_ppmsel, rbc_all_ppmsel, fnl_ppmsel);
		if (!is_in_legal_set(ppmsel, rbc_all_ppmsel)) begin
			$display("Critical Warning: parameter 'ppmsel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ppmsel, rbc_all_ppmsel, fnl_ppmsel);
		end
		//$display("auto_speed_ena = orig: '%s', any:'%s', all:'%s', final: '%s'", auto_speed_ena, rbc_any_auto_speed_ena, rbc_all_auto_speed_ena, fnl_auto_speed_ena);
		if (!is_in_legal_set(auto_speed_ena, rbc_all_auto_speed_ena)) begin
			$display("Critical Warning: parameter 'auto_speed_ena' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", auto_speed_ena, rbc_all_auto_speed_ena, fnl_auto_speed_ena);
		end
		//$display("ppm_cnt_rst = orig: '%s', any:'%s', all:'%s', final: '%s'", ppm_cnt_rst, rbc_any_ppm_cnt_rst, rbc_all_ppm_cnt_rst, fnl_ppm_cnt_rst);
		if (!is_in_legal_set(ppm_cnt_rst, rbc_all_ppm_cnt_rst)) begin
			$display("Critical Warning: parameter 'ppm_cnt_rst' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ppm_cnt_rst, rbc_all_ppm_cnt_rst, fnl_ppm_cnt_rst);
		end
		//$display("ppm_gen1_2_cnt = orig: '%s', any:'%s', all:'%s', final: '%s'", ppm_gen1_2_cnt, rbc_any_ppm_gen1_2_cnt, rbc_all_ppm_gen1_2_cnt, fnl_ppm_gen1_2_cnt);
		if (!is_in_legal_set(ppm_gen1_2_cnt, rbc_all_ppm_gen1_2_cnt)) begin
			$display("Critical Warning: parameter 'ppm_gen1_2_cnt' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ppm_gen1_2_cnt, rbc_all_ppm_gen1_2_cnt, fnl_ppm_gen1_2_cnt);
		end
		//$display("ppm_post_eidle_delay = orig: '%s', any:'%s', all:'%s', final: '%s'", ppm_post_eidle_delay, rbc_any_ppm_post_eidle_delay, rbc_all_ppm_post_eidle_delay, fnl_ppm_post_eidle_delay);
		if (!is_in_legal_set(ppm_post_eidle_delay, rbc_all_ppm_post_eidle_delay)) begin
			$display("Critical Warning: parameter 'ppm_post_eidle_delay' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ppm_post_eidle_delay, rbc_all_ppm_post_eidle_delay, fnl_ppm_post_eidle_delay);
		end
		//$display("ppm_deassert_early = orig: '%s', any:'%s', all:'%s', final: '%s'", ppm_deassert_early, rbc_any_ppm_deassert_early, rbc_all_ppm_deassert_early, fnl_ppm_deassert_early);
		if (!is_in_legal_set(ppm_deassert_early, rbc_all_ppm_deassert_early)) begin
			$display("Critical Warning: parameter 'ppm_deassert_early' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ppm_deassert_early, rbc_all_ppm_deassert_early, fnl_ppm_deassert_early);
		end
	end

	stratixv_hssi_common_pcs_pma_interface #(
		.func_mode(fnl_func_mode),
		.prot_mode(fnl_prot_mode),
		.sup_mode(fnl_sup_mode),
		.avmm_group_channel_index(avmm_group_channel_index),
		.pcie_gen3_cap(fnl_pcie_gen3_cap),
		.pma_if_dft_en(pma_if_dft_en),
		.pma_if_dft_val(pma_if_dft_val),
		.refclk_dig_sel(fnl_refclk_dig_sel),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.pipe_if_g3pcs(fnl_pipe_if_g3pcs),
		.selectpcs(fnl_selectpcs),
		.force_freqdet(fnl_force_freqdet),
		.ppmsel(fnl_ppmsel),
		.auto_speed_ena(fnl_auto_speed_ena),
		.ppm_cnt_rst(fnl_ppm_cnt_rst),
		.ppm_gen1_2_cnt(fnl_ppm_gen1_2_cnt),
		.ppm_post_eidle_delay(fnl_ppm_post_eidle_delay),
		.ppm_deassert_early(fnl_ppm_deassert_early)
	) wys (
		// ports
		.aggaligndetsync(aggaligndetsync),
		.aggalignstatus(aggalignstatus),
		.aggalignstatussync(aggalignstatussync),
		.aggalignstatussync0(aggalignstatussync0),
		.aggalignstatussync0toporbot(aggalignstatussync0toporbot),
		.aggalignstatustoporbot(aggalignstatustoporbot),
		.aggcgcomprddall(aggcgcomprddall),
		.aggcgcomprddalltoporbot(aggcgcomprddalltoporbot),
		.aggcgcomprddout(aggcgcomprddout),
		.aggcgcompwrall(aggcgcompwrall),
		.aggcgcompwralltoporbot(aggcgcompwralltoporbot),
		.aggcgcompwrout(aggcgcompwrout),
		.aggdecctl(aggdecctl),
		.aggdecdata(aggdecdata),
		.aggdecdatavalid(aggdecdatavalid),
		.aggdelcondmet0(aggdelcondmet0),
		.aggdelcondmet0toporbot(aggdelcondmet0toporbot),
		.aggdelcondmetout(aggdelcondmetout),
		.aggendskwqd(aggendskwqd),
		.aggendskwqdtoporbot(aggendskwqdtoporbot),
		.aggendskwrdptrs(aggendskwrdptrs),
		.aggendskwrdptrstoporbot(aggendskwrdptrstoporbot),
		.aggfifoovr0(aggfifoovr0),
		.aggfifoovr0toporbot(aggfifoovr0toporbot),
		.aggfifoovrout(aggfifoovrout),
		.aggfifordincomp0(aggfifordincomp0),
		.aggfifordincomp0toporbot(aggfifordincomp0toporbot),
		.aggfifordoutcomp(aggfifordoutcomp),
		.aggfiforstrdqd(aggfiforstrdqd),
		.aggfiforstrdqdtoporbot(aggfiforstrdqdtoporbot),
		.agginsertincomplete0(agginsertincomplete0),
		.agginsertincomplete0toporbot(agginsertincomplete0toporbot),
		.agginsertincompleteout(agginsertincompleteout),
		.agglatencycomp0(agglatencycomp0),
		.agglatencycomp0toporbot(agglatencycomp0toporbot),
		.agglatencycompout(agglatencycompout),
		.aggrcvdclkagg(aggrcvdclkagg),
		.aggrcvdclkaggtoporbot(aggrcvdclkaggtoporbot),
		.aggrdalign(aggrdalign),
		.aggrdenablesync(aggrdenablesync),
		.aggrefclkdig(aggrefclkdig),
		.aggrunningdisp(aggrunningdisp),
		.aggrxcontrolrs(aggrxcontrolrs),
		.aggrxcontrolrstoporbot(aggrxcontrolrstoporbot),
		.aggrxdatars(aggrxdatars),
		.aggrxdatarstoporbot(aggrxdatarstoporbot),
		.aggrxpcsrst(aggrxpcsrst),
		.aggscanmoden(aggscanmoden),
		.aggscanshiftn(aggscanshiftn),
		.aggsyncstatus(aggsyncstatus),
		.aggtestbus(aggtestbus),
		.aggtestsotopldin(aggtestsotopldin),
		.aggtestsotopldout(aggtestsotopldout),
		.aggtxctltc(aggtxctltc),
		.aggtxctlts(aggtxctlts),
		.aggtxctltstoporbot(aggtxctltstoporbot),
		.aggtxdatatc(aggtxdatatc),
		.aggtxdatats(aggtxdatats),
		.aggtxdatatstoporbot(aggtxdatatstoporbot),
		.aggtxpcsrst(aggtxpcsrst),
		.asynchdatain(asynchdatain),
		.avmmaddress(avmmaddress),
		.avmmbyteen(avmmbyteen),
		.avmmclk(avmmclk),
		.avmmread(avmmread),
		.avmmreaddata(avmmreaddata),
		.avmmrstn(avmmrstn),
		.avmmwrite(avmmwrite),
		.avmmwritedata(avmmwritedata),
		.blockselect(blockselect),
		.clklow(clklow),
		.fref(fref),
		.freqlock(freqlock),
		.hardreset(hardreset),
		.pcs8gearlyeios(pcs8gearlyeios),
		.pcs8geidleexit(pcs8geidleexit),
		.pcs8ggen2ngen1(pcs8ggen2ngen1),
		.pcs8gltrpma(pcs8gltrpma),
		.pcs8gpcieswitch(pcs8gpcieswitch),
		.pcs8gpmacurrentcoeff(pcs8gpmacurrentcoeff),
		.pcs8gpmarxfound(pcs8gpmarxfound),
		.pcs8gpowerstatetransitiondone(pcs8gpowerstatetransitiondone),
		.pcs8grxdetectvalid(pcs8grxdetectvalid),
		.pcs8gtxdetectrx(pcs8gtxdetectrx),
		.pcs8gtxelecidle(pcs8gtxelecidle),
		.pcsaggaligndetsync(pcsaggaligndetsync),
		.pcsaggalignstatus(pcsaggalignstatus),
		.pcsaggalignstatussync(pcsaggalignstatussync),
		.pcsaggalignstatussync0(pcsaggalignstatussync0),
		.pcsaggalignstatussync0toporbot(pcsaggalignstatussync0toporbot),
		.pcsaggalignstatustoporbot(pcsaggalignstatustoporbot),
		.pcsaggcgcomprddall(pcsaggcgcomprddall),
		.pcsaggcgcomprddalltoporbot(pcsaggcgcomprddalltoporbot),
		.pcsaggcgcomprddout(pcsaggcgcomprddout),
		.pcsaggcgcompwrall(pcsaggcgcompwrall),
		.pcsaggcgcompwralltoporbot(pcsaggcgcompwralltoporbot),
		.pcsaggcgcompwrout(pcsaggcgcompwrout),
		.pcsaggdecctl(pcsaggdecctl),
		.pcsaggdecdata(pcsaggdecdata),
		.pcsaggdecdatavalid(pcsaggdecdatavalid),
		.pcsaggdelcondmet0(pcsaggdelcondmet0),
		.pcsaggdelcondmet0toporbot(pcsaggdelcondmet0toporbot),
		.pcsaggdelcondmetout(pcsaggdelcondmetout),
		.pcsaggendskwqd(pcsaggendskwqd),
		.pcsaggendskwqdtoporbot(pcsaggendskwqdtoporbot),
		.pcsaggendskwrdptrs(pcsaggendskwrdptrs),
		.pcsaggendskwrdptrstoporbot(pcsaggendskwrdptrstoporbot),
		.pcsaggfifoovr0(pcsaggfifoovr0),
		.pcsaggfifoovr0toporbot(pcsaggfifoovr0toporbot),
		.pcsaggfifoovrout(pcsaggfifoovrout),
		.pcsaggfifordincomp0(pcsaggfifordincomp0),
		.pcsaggfifordincomp0toporbot(pcsaggfifordincomp0toporbot),
		.pcsaggfifordoutcomp(pcsaggfifordoutcomp),
		.pcsaggfiforstrdqd(pcsaggfiforstrdqd),
		.pcsaggfiforstrdqdtoporbot(pcsaggfiforstrdqdtoporbot),
		.pcsagginsertincomplete0(pcsagginsertincomplete0),
		.pcsagginsertincomplete0toporbot(pcsagginsertincomplete0toporbot),
		.pcsagginsertincompleteout(pcsagginsertincompleteout),
		.pcsagglatencycomp0(pcsagglatencycomp0),
		.pcsagglatencycomp0toporbot(pcsagglatencycomp0toporbot),
		.pcsagglatencycompout(pcsagglatencycompout),
		.pcsaggrcvdclkagg(pcsaggrcvdclkagg),
		.pcsaggrcvdclkaggtoporbot(pcsaggrcvdclkaggtoporbot),
		.pcsaggrdalign(pcsaggrdalign),
		.pcsaggrdenablesync(pcsaggrdenablesync),
		.pcsaggrefclkdig(pcsaggrefclkdig),
		.pcsaggrunningdisp(pcsaggrunningdisp),
		.pcsaggrxcontrolrs(pcsaggrxcontrolrs),
		.pcsaggrxcontrolrstoporbot(pcsaggrxcontrolrstoporbot),
		.pcsaggrxdatars(pcsaggrxdatars),
		.pcsaggrxdatarstoporbot(pcsaggrxdatarstoporbot),
		.pcsaggrxpcsrst(pcsaggrxpcsrst),
		.pcsaggscanmoden(pcsaggscanmoden),
		.pcsaggscanshiftn(pcsaggscanshiftn),
		.pcsaggsyncstatus(pcsaggsyncstatus),
		.pcsaggtestbus(pcsaggtestbus),
		.pcsaggtxctltc(pcsaggtxctltc),
		.pcsaggtxctlts(pcsaggtxctlts),
		.pcsaggtxctltstoporbot(pcsaggtxctltstoporbot),
		.pcsaggtxdatatc(pcsaggtxdatatc),
		.pcsaggtxdatats(pcsaggtxdatats),
		.pcsaggtxdatatstoporbot(pcsaggtxdatatstoporbot),
		.pcsaggtxpcsrst(pcsaggtxpcsrst),
		.pcsgen3gen3datasel(pcsgen3gen3datasel),
		.pcsgen3pllfixedclk(pcsgen3pllfixedclk),
		.pcsgen3pmacurrentcoeff(pcsgen3pmacurrentcoeff),
		.pcsgen3pmacurrentrxpreset(pcsgen3pmacurrentrxpreset),
		.pcsgen3pmaearlyeios(pcsgen3pmaearlyeios),
		.pcsgen3pmaltr(pcsgen3pmaltr),
		.pcsgen3pmapcieswdone(pcsgen3pmapcieswdone),
		.pcsgen3pmapcieswitch(pcsgen3pmapcieswitch),
		.pcsgen3pmarxdetectvalid(pcsgen3pmarxdetectvalid),
		.pcsgen3pmarxfound(pcsgen3pmarxfound),
		.pcsgen3pmatxdetectrx(pcsgen3pmatxdetectrx),
		.pcsgen3pmatxelecidle(pcsgen3pmatxelecidle),
		.pcsgen3ppmeidleexit(pcsgen3ppmeidleexit),
		.pcsrefclkdig(pcsrefclkdig),
		.pcsscanmoden(pcsscanmoden),
		.pcsscanshiftn(pcsscanshiftn),
		.pldhclkout(pldhclkout),
		.pldlccmurstb(pldlccmurstb),
		.pldnfrzdrv(pldnfrzdrv),
		.pldpartialreconfig(pldpartialreconfig),
		.pldtestsitoaggin(pldtestsitoaggin),
		.pldtestsitoaggout(pldtestsitoaggout),
		.pmaclklowout(pmaclklowout),
		.pmacurrentcoeff(pmacurrentcoeff),
		.pmacurrentrxpreset(pmacurrentrxpreset),
		.pmaearlyeios(pmaearlyeios),
		.pmafrefout(pmafrefout),
		.pmahclk(pmahclk),
		.pmaiftestbus(pmaiftestbus),
		.pmalccmurstb(pmalccmurstb),
		.pmaltr(pmaltr),
		.pmanfrzdrv(pmanfrzdrv),
		.pmaoffcaldone(pmaoffcaldone),
		.pmaoffcalenin(pmaoffcalenin),
		.pmapartialreconfig(pmapartialreconfig),
		.pmapcieswdone(pmapcieswdone),
		.pmapcieswitch(pmapcieswitch),
		.pmarxdetectvalid(pmarxdetectvalid),
		.pmarxfound(pmarxfound),
		.pmarxpmarstb(pmarxpmarstb),
		.pmatxdetectrx(pmatxdetectrx),
		.pmatxelecidle(pmatxelecidle),
		.resetppmcntrs(resetppmcntrs)
	);
endmodule
