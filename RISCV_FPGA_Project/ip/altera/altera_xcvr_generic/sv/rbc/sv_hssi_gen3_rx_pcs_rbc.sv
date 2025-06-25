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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_gen3_rx_pcs
//

`timescale 1 ns / 1 ps

module sv_hssi_gen3_rx_pcs_rbc #(
	// unconstrained parameters
	parameter sup_mode = "<auto_single>",	// engr_mode, user_mode

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter rmfifo_empty = "rmfifo_empty",	// rmfifo_empty
	parameter rmfifo_empty_data = 5'b1,	// 5
	parameter rmfifo_full = "rmfifo_full",	// rmfifo_full
	parameter rmfifo_full_data = 5'b11111,	// 5
	parameter rmfifo_pempty = "rmfifo_pempty",	// rmfifo_pempty
	parameter rmfifo_pempty_data = 5'b1000,	// 5
	parameter rmfifo_pfull = "rmfifo_pfull",	// rmfifo_pfull
	parameter rmfifo_pfull_data = 5'b10111,	// 5
	parameter rx_num_fixed_pat = "num_fixed_pat",	// num_fixed_pat
	parameter rx_num_fixed_pat_data = 4'b100,	// 4
	parameter silicon_rev = "reve",	// es, reve
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047

	// constrained parameters
	parameter mode = "<auto_single>",	// disable_pcs, gen3_func, par_lpbk, sup_engr_mode, sup_user_mode
	parameter rx_clk_sel = "<auto_single>",	// dig_clk1_8g, disable_clk, rcvd_clk
	parameter tx_clk_sel = "<auto_single>",	// dig_clk2_8g, disable_clk, tx_pma_clk
	parameter decoder = "<auto_single>",	// bypass_decoder, enable_decoder
	parameter descrambler = "<auto_single>",	// bypass_descrambler, enable_descrambler
	parameter block_sync_sm = "<auto_single>",	// disable_blk_sync_sm, enable_blk_sync_sm
	parameter block_sync = "<auto_single>",	// bypass_block_sync, enable_block_sync
	parameter rate_match_fifo = "<auto_single>",	// bypass_rm_fifo, enable_rm_fifo, enable_rm_fifo_0ppm
	parameter rate_match_fifo_latency = "<auto_single>",	// low_latency, regular_latency
	parameter parallel_lpbk = "<auto_single>",	// par_lpbk_dis, par_lpbk_en
	parameter lpbk_force = "<auto_single>",	// lpbk_frce_dis, lpbk_frce_en
	parameter descrambler_lfsr_check = "<auto_single>",	// lfsr_chk_dis, lfsr_chk_en
	parameter reverse_lpbk = "<auto_single>",	// rev_lpbk_dis, rev_lpbk_en
	parameter rx_pol_compl = "<auto_single>",	// rx_pol_compl_dis, rx_pol_compl_en
	parameter rx_force_balign = "<auto_single>",	// dis_force_balign, en_force_balign
	parameter rx_lane_num = "<auto_single>",	// lane_0, lane_1, lane_2, lane_3, lane_4, lane_5, lane_6, lane_7, not_used
	parameter rx_test_out_sel = "<auto_single>",	// rx_test_out0, rx_test_out1
	parameter rx_g3_dcbal = "<auto_single>",	// g3_dcbal_dis, g3_dcbal_en
	parameter rx_b4gb_par_lpbk = "<auto_single>",	// b4gb_par_lpbk_dis, b4gb_par_lpbk_en
	parameter rx_ins_del_one_skip = "<auto_single>"	// ins_del_one_skip_dis, ins_del_one_skip_en
) (
	// ports
	input  wire   [10:0]	avmmaddress,
	input  wire    [1:0]	avmmbyteen,
	input  wire         	avmmclk,
	input  wire         	avmmread,
	output wire   [15:0]	avmmreaddata,
	input  wire         	avmmrstn,
	input  wire         	avmmwrite,
	input  wire   [15:0]	avmmwritedata,
	output wire         	blkalgndint,
	output wire         	blklockdint,
	output wire         	blkstart,
	output wire         	blockselect,
	output wire         	clkcompdeleteint,
	output wire         	clkcompinsertint,
	output wire         	clkcompoverflint,
	output wire         	clkcompundflint,
	input  wire   [31:0]	datain,
	output wire   [31:0]	dataout,
	output wire         	datavalid,
	output wire         	eidetint,
	output wire         	eipartialdetint,
	output wire         	errdecodeint,
	input  wire         	gen3clksel,
	input  wire         	hardresetn,
	output wire         	idetint,
	input  wire         	inferredrxvalid,
	output wire         	lpbkblkstart,
	output wire   [33:0]	lpbkdata,
	output wire         	lpbkdatavalid,
	input  wire         	lpbken,
	input  wire   [35:0]	parlpbkb4gbin,
	input  wire   [31:0]	parlpbkin,
	input  wire         	pcsrst,
	input  wire         	pldclk28gpcs,
	input  wire         	rcvdclk,
	output wire         	rcvlfsrchkint,
	input  wire         	rxpolarity,
	input  wire         	rxrstn,
	output wire   [19:0]	rxtestout,
	input  wire         	scanmoden,
	input  wire         	shutdownclk,
	output wire         	skpdetint,
	output wire    [1:0]	synchdr,
	input  wire         	syncsmen,
	input  wire    [3:0]	txdatakin,
	input  wire         	txelecidle,
	input  wire         	txpmaclk,
	input  wire         	txpth
);
	import altera_xcvr_functions::*;

	// sup_mode external parameter (no RBC)
	localparam rbc_all_sup_mode = "(engr_mode,user_mode)";
	localparam rbc_any_sup_mode = "user_mode";
	localparam fnl_sup_mode = (sup_mode == "<auto_any>" || sup_mode == "<auto_single>") ? rbc_any_sup_mode : sup_mode;

	// silicon_rev external parameter (no RBC)
	localparam rbc_all_silicon_rev = "(es,reve)";
	localparam rbc_any_silicon_rev = "reve";
	localparam fnl_silicon_rev = (silicon_rev == "<auto_any>" || silicon_rev == "<auto_single>") ? rbc_any_silicon_rev : silicon_rev;

	// use_default_base_address external parameter (no RBC)
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// mode, RBC-validated
	localparam rbc_all_mode = "(gen3_func,par_lpbk,disable_pcs)";
	localparam rbc_any_mode = "gen3_func";
	localparam fnl_mode = (mode == "<auto_any>" || mode == "<auto_single>") ? rbc_any_mode : mode;

	// rx_clk_sel, RBC-validated
	localparam rbc_all_rx_clk_sel = "(disable_clk,dig_clk1_8g,rcvd_clk)";
	localparam rbc_any_rx_clk_sel = "rcvd_clk";
	localparam fnl_rx_clk_sel = (rx_clk_sel == "<auto_any>" || rx_clk_sel == "<auto_single>") ? rbc_any_rx_clk_sel : rx_clk_sel;

	// tx_clk_sel, RBC-validated
	localparam rbc_all_tx_clk_sel = "(disable_clk,dig_clk2_8g,tx_pma_clk)";
	localparam rbc_any_tx_clk_sel = "tx_pma_clk";
	localparam fnl_tx_clk_sel = (tx_clk_sel == "<auto_any>" || tx_clk_sel == "<auto_single>") ? rbc_any_tx_clk_sel : tx_clk_sel;

	// decoder, RBC-validated
	localparam rbc_all_decoder = "(bypass_decoder,enable_decoder)";
	localparam rbc_any_decoder = "enable_decoder";
	localparam fnl_decoder = (decoder == "<auto_any>" || decoder == "<auto_single>") ? rbc_any_decoder : decoder;

	// descrambler, RBC-validated
	localparam rbc_all_descrambler = "(bypass_descrambler,enable_descrambler)";
	localparam rbc_any_descrambler = "enable_descrambler";
	localparam fnl_descrambler = (descrambler == "<auto_any>" || descrambler == "<auto_single>") ? rbc_any_descrambler : descrambler;

	// block_sync_sm, RBC-validated
	localparam rbc_all_block_sync_sm = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_blk_sync_sm")
			 : (fnl_mode == "par_lpbk") ? ("enable_blk_sync_sm")
				 : (fnl_mode == "disable_pcs") ? ("disable_blk_sync_sm") : "(disable_blk_sync_sm,enable_blk_sync_sm)"
		) : "(disable_blk_sync_sm,enable_blk_sync_sm)";
	localparam rbc_any_block_sync_sm = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_blk_sync_sm")
			 : (fnl_mode == "par_lpbk") ? ("enable_blk_sync_sm")
				 : (fnl_mode == "disable_pcs") ? ("disable_blk_sync_sm") : "enable_blk_sync_sm"
		) : "enable_blk_sync_sm";
	localparam fnl_block_sync_sm = (block_sync_sm == "<auto_any>" || block_sync_sm == "<auto_single>") ? rbc_any_block_sync_sm : block_sync_sm;

	// block_sync, RBC-validated
	localparam rbc_all_block_sync = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_block_sync")
			 : (fnl_mode == "par_lpbk") ? ("enable_block_sync")
				 : (fnl_mode == "disable_pcs") ? ("bypass_block_sync") : "(bypass_block_sync,enable_block_sync)"
		) : "(bypass_block_sync,enable_block_sync)";
	localparam rbc_any_block_sync = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_block_sync")
			 : (fnl_mode == "par_lpbk") ? ("enable_block_sync")
				 : (fnl_mode == "disable_pcs") ? ("bypass_block_sync") : "enable_block_sync"
		) : "enable_block_sync";
	localparam fnl_block_sync = (block_sync == "<auto_any>" || block_sync == "<auto_single>") ? rbc_any_block_sync : block_sync;

	// rate_match_fifo, RBC-validated
	localparam rbc_all_rate_match_fifo = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("(enable_rm_fifo,enable_rm_fifo_0ppm)")
			 : (fnl_mode == "par_lpbk") ? ("(enable_rm_fifo,enable_rm_fifo_0ppm)")
				 : (fnl_mode == "disable_pcs") ? ("bypass_rm_fifo") : "(bypass_rm_fifo,enable_rm_fifo)"
		) : "(bypass_rm_fifo,enable_rm_fifo,enable_rm_fifo_0ppm)";
	localparam rbc_any_rate_match_fifo = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_rm_fifo")
			 : (fnl_mode == "par_lpbk") ? ("enable_rm_fifo")
				 : (fnl_mode == "disable_pcs") ? ("bypass_rm_fifo") : "enable_rm_fifo"
		) : "enable_rm_fifo";
	localparam fnl_rate_match_fifo = (rate_match_fifo == "<auto_any>" || rate_match_fifo == "<auto_single>") ? rbc_any_rate_match_fifo : rate_match_fifo;

	// rate_match_fifo_latency, RBC-validated
	localparam rbc_all_rate_match_fifo_latency = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("regular_latency")
			 : (fnl_mode == "par_lpbk") ? ("regular_latency")
				 : (fnl_mode == "disable_pcs") ? ("low_latency") : "(regular_latency,low_latency)"
		) : "(regular_latency,low_latency)";
	localparam rbc_any_rate_match_fifo_latency = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("regular_latency")
			 : (fnl_mode == "par_lpbk") ? ("regular_latency")
				 : (fnl_mode == "disable_pcs") ? ("low_latency") : "regular_latency"
		) : "regular_latency";
	localparam fnl_rate_match_fifo_latency = (rate_match_fifo_latency == "<auto_any>" || rate_match_fifo_latency == "<auto_single>") ? rbc_any_rate_match_fifo_latency : rate_match_fifo_latency;

	// parallel_lpbk, RBC-validated
	localparam rbc_all_parallel_lpbk = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("par_lpbk_dis")
			 : (fnl_mode == "par_lpbk") ? ("par_lpbk_en")
				 : (fnl_mode == "disable_pcs") ? ("par_lpbk_dis") : "(par_lpbk_dis,par_lpbk_en)"
		) : "(par_lpbk_dis,par_lpbk_en)";
	localparam rbc_any_parallel_lpbk = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("par_lpbk_dis")
			 : (fnl_mode == "par_lpbk") ? ("par_lpbk_en")
				 : (fnl_mode == "disable_pcs") ? ("par_lpbk_dis") : "par_lpbk_dis"
		) : "par_lpbk_dis";
	localparam fnl_parallel_lpbk = (parallel_lpbk == "<auto_any>" || parallel_lpbk == "<auto_single>") ? rbc_any_parallel_lpbk : parallel_lpbk;

	// lpbk_force, RBC-validated
	localparam rbc_all_lpbk_force = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("lpbk_frce_en")
			 : (fnl_mode == "par_lpbk") ? ("lpbk_frce_en")
				 : (fnl_mode == "disable_pcs") ? ("lpbk_frce_dis") : "(lpbk_frce_dis,lpbk_frce_en)"
		) : "(lpbk_frce_dis,lpbk_frce_en)";
	localparam rbc_any_lpbk_force = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("lpbk_frce_en")
			 : (fnl_mode == "par_lpbk") ? ("lpbk_frce_en")
				 : (fnl_mode == "disable_pcs") ? ("lpbk_frce_dis") : "lpbk_frce_dis"
		) : "lpbk_frce_dis";
	localparam fnl_lpbk_force = (lpbk_force == "<auto_any>" || lpbk_force == "<auto_single>") ? rbc_any_lpbk_force : lpbk_force;

	// descrambler_lfsr_check, RBC-validated
	localparam rbc_all_descrambler_lfsr_check = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func" || fnl_mode == "par_lpbk") ? ("(lfsr_chk_dis,lfsr_chk_en)")
			 : (fnl_mode == "disable_pcs") ? ("lfsr_chk_dis") : "(lfsr_chk_dis,lfsr_chk_en)"
		) : "(lfsr_chk_dis,lfsr_chk_en)";
	localparam rbc_any_descrambler_lfsr_check = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func" || fnl_mode == "par_lpbk") ? ("lfsr_chk_dis")
			 : (fnl_mode == "disable_pcs") ? ("lfsr_chk_dis") : "lfsr_chk_dis"
		) : "lfsr_chk_dis";
	localparam fnl_descrambler_lfsr_check = (descrambler_lfsr_check == "<auto_any>" || descrambler_lfsr_check == "<auto_single>") ? rbc_any_descrambler_lfsr_check : descrambler_lfsr_check;

	// reverse_lpbk, RBC-validated
	localparam rbc_all_reverse_lpbk = (fnl_mode == "gen3_func") ? ("rev_lpbk_en")
		 : (fnl_mode == "par_lpbk") ? ("rev_lpbk_en")
			 : (fnl_mode == "disable_pcs") ? ("rev_lpbk_dis") : "(rev_lpbk_dis,rev_lpbk_en)";
	localparam rbc_any_reverse_lpbk = (fnl_mode == "gen3_func") ? ("rev_lpbk_en")
		 : (fnl_mode == "par_lpbk") ? ("rev_lpbk_en")
			 : (fnl_mode == "disable_pcs") ? ("rev_lpbk_dis") : "rev_lpbk_en";
	localparam fnl_reverse_lpbk = (reverse_lpbk == "<auto_any>" || reverse_lpbk == "<auto_single>") ? rbc_any_reverse_lpbk : reverse_lpbk;

	// rx_pol_compl, RBC-validated
	localparam rbc_all_rx_pol_compl = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("rx_pol_compl_dis")
			 : (fnl_mode == "par_lpbk") ? ("rx_pol_compl_dis")
				 : (fnl_mode == "disable_pcs") ? ("rx_pol_compl_dis") : "(rx_pol_compl_en,rx_pol_compl_dis)"
		) : "(rx_pol_compl_en,rx_pol_compl_dis)";
	localparam rbc_any_rx_pol_compl = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("rx_pol_compl_dis")
			 : (fnl_mode == "par_lpbk") ? ("rx_pol_compl_dis")
				 : (fnl_mode == "disable_pcs") ? ("rx_pol_compl_dis") : "rx_pol_compl_dis"
		) : "rx_pol_compl_dis";
	localparam fnl_rx_pol_compl = (rx_pol_compl == "<auto_any>" || rx_pol_compl == "<auto_single>") ? rbc_any_rx_pol_compl : rx_pol_compl;

	// rx_force_balign, RBC-validated
	localparam rbc_all_rx_force_balign = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("en_force_balign")
			 : (fnl_mode == "par_lpbk") ? ("dis_force_balign")
				 : (fnl_mode == "disable_pcs") ? ("dis_force_balign") : "(en_force_balign,dis_force_balign)"
		) : "(en_force_balign,dis_force_balign)";
	localparam rbc_any_rx_force_balign = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("en_force_balign")
			 : (fnl_mode == "par_lpbk") ? ("dis_force_balign")
				 : (fnl_mode == "disable_pcs") ? ("dis_force_balign") : "en_force_balign"
		) : "en_force_balign";
	localparam fnl_rx_force_balign = (rx_force_balign == "<auto_any>" || rx_force_balign == "<auto_single>") ? rbc_any_rx_force_balign : rx_force_balign;

	// rx_lane_num, RBC-validated
	localparam rbc_all_rx_lane_num = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "disable_pcs") ? ("lane_0") : "(lane_0,lane_1,lane_2,lane_3,lane_4,lane_5,lane_6,lane_7,not_used)"
		) : "(lane_0,lane_1,lane_2,lane_3,lane_4,lane_5,lane_6,lane_7,not_used)";
	localparam rbc_any_rx_lane_num = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "disable_pcs") ? ("lane_0") : "lane_0"
		) : "lane_0";
	localparam fnl_rx_lane_num = (rx_lane_num == "<auto_any>" || rx_lane_num == "<auto_single>") ? rbc_any_rx_lane_num : rx_lane_num;

	// rx_test_out_sel, RBC-validated
	localparam rbc_all_rx_test_out_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("rx_test_out0")
			 : (fnl_mode == "par_lpbk") ? ("rx_test_out0")
				 : (fnl_mode == "disable_pcs") ? ("rx_test_out0") : "(rx_test_out0,rx_test_out1)"
		) : "(rx_test_out0,rx_test_out1)";
	localparam rbc_any_rx_test_out_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("rx_test_out0")
			 : (fnl_mode == "par_lpbk") ? ("rx_test_out0")
				 : (fnl_mode == "disable_pcs") ? ("rx_test_out0") : "rx_test_out0"
		) : "rx_test_out0";
	localparam fnl_rx_test_out_sel = (rx_test_out_sel == "<auto_any>" || rx_test_out_sel == "<auto_single>") ? rbc_any_rx_test_out_sel : rx_test_out_sel;

	// rx_g3_dcbal, RBC-validated
	localparam rbc_all_rx_g3_dcbal = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("g3_dcbal_en")
			 : (fnl_mode == "par_lpbk") ? ("g3_dcbal_dis")
				 : (fnl_mode == "disable_pcs") ? ("g3_dcbal_dis") : "(g3_dcbal_dis,g3_dcbal_en)"
		) : "(g3_dcbal_dis,g3_dcbal_en)";
	localparam rbc_any_rx_g3_dcbal = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("g3_dcbal_en")
			 : (fnl_mode == "par_lpbk") ? ("g3_dcbal_dis")
				 : (fnl_mode == "disable_pcs") ? ("g3_dcbal_dis") : "g3_dcbal_en"
		) : "g3_dcbal_en";
	localparam fnl_rx_g3_dcbal = (rx_g3_dcbal == "<auto_any>" || rx_g3_dcbal == "<auto_single>") ? rbc_any_rx_g3_dcbal : rx_g3_dcbal;

	// rx_b4gb_par_lpbk, RBC-validated
	localparam rbc_all_rx_b4gb_par_lpbk = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("b4gb_par_lpbk_dis")
			 : (fnl_mode == "par_lpbk") ? ("(b4gb_par_lpbk_dis,b4gb_par_lpbk_en)")
				 : (fnl_mode == "disable_pcs") ? ("b4gb_par_lpbk_dis") : "(b4gb_par_lpbk_dis,b4gb_par_lpbk_en)"
		) : "(b4gb_par_lpbk_dis,b4gb_par_lpbk_en)";
	localparam rbc_any_rx_b4gb_par_lpbk = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("b4gb_par_lpbk_dis")
			 : (fnl_mode == "par_lpbk") ? ("b4gb_par_lpbk_dis")
				 : (fnl_mode == "disable_pcs") ? ("b4gb_par_lpbk_dis") : "b4gb_par_lpbk_dis"
		) : "b4gb_par_lpbk_dis";
	localparam fnl_rx_b4gb_par_lpbk = (rx_b4gb_par_lpbk == "<auto_any>" || rx_b4gb_par_lpbk == "<auto_single>") ? rbc_any_rx_b4gb_par_lpbk : rx_b4gb_par_lpbk;

	// rx_ins_del_one_skip, RBC-validated
	localparam rbc_all_rx_ins_del_one_skip = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("(ins_del_one_skip_dis,ins_del_one_skip_en)")
			 : (fnl_mode == "par_lpbk") ? ("ins_del_one_skip_dis") : "ins_del_one_skip_dis"
		) : "(ins_del_one_skip_dis,ins_del_one_skip_en)";
	localparam rbc_any_rx_ins_del_one_skip = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("ins_del_one_skip_dis")
			 : (fnl_mode == "par_lpbk") ? ("ins_del_one_skip_dis") : "ins_del_one_skip_dis"
		) : "ins_del_one_skip_en";
	localparam fnl_rx_ins_del_one_skip = (rx_ins_del_one_skip == "<auto_any>" || rx_ins_del_one_skip == "<auto_single>") ? rbc_any_rx_ins_del_one_skip : rx_ins_del_one_skip;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("sup_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", sup_mode, rbc_any_sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		if (!is_in_legal_set(sup_mode, rbc_all_sup_mode)) begin
			$display("Critical Warning: parameter 'sup_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		end
		//$display("silicon_rev = orig: '%s', any:'%s', all:'%s', final: '%s'", silicon_rev, rbc_any_silicon_rev, rbc_all_silicon_rev, fnl_silicon_rev);
		if (!is_in_legal_set(silicon_rev, rbc_all_silicon_rev)) begin
			$display("Critical Warning: parameter 'silicon_rev' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", silicon_rev, rbc_all_silicon_rev, fnl_silicon_rev);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
		//$display("mode = orig: '%s', any:'%s', all:'%s', final: '%s'", mode, rbc_any_mode, rbc_all_mode, fnl_mode);
		if (!is_in_legal_set(mode, rbc_all_mode)) begin
			$display("Critical Warning: parameter 'mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", mode, rbc_all_mode, fnl_mode);
		end
		//$display("rx_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_clk_sel, rbc_any_rx_clk_sel, rbc_all_rx_clk_sel, fnl_rx_clk_sel);
		if (!is_in_legal_set(rx_clk_sel, rbc_all_rx_clk_sel)) begin
			$display("Critical Warning: parameter 'rx_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_clk_sel, rbc_all_rx_clk_sel, fnl_rx_clk_sel);
		end
		//$display("tx_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_clk_sel, rbc_any_tx_clk_sel, rbc_all_tx_clk_sel, fnl_tx_clk_sel);
		if (!is_in_legal_set(tx_clk_sel, rbc_all_tx_clk_sel)) begin
			$display("Critical Warning: parameter 'tx_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_clk_sel, rbc_all_tx_clk_sel, fnl_tx_clk_sel);
		end
		//$display("decoder = orig: '%s', any:'%s', all:'%s', final: '%s'", decoder, rbc_any_decoder, rbc_all_decoder, fnl_decoder);
		if (!is_in_legal_set(decoder, rbc_all_decoder)) begin
			$display("Critical Warning: parameter 'decoder' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", decoder, rbc_all_decoder, fnl_decoder);
		end
		//$display("descrambler = orig: '%s', any:'%s', all:'%s', final: '%s'", descrambler, rbc_any_descrambler, rbc_all_descrambler, fnl_descrambler);
		if (!is_in_legal_set(descrambler, rbc_all_descrambler)) begin
			$display("Critical Warning: parameter 'descrambler' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", descrambler, rbc_all_descrambler, fnl_descrambler);
		end
		//$display("block_sync_sm = orig: '%s', any:'%s', all:'%s', final: '%s'", block_sync_sm, rbc_any_block_sync_sm, rbc_all_block_sync_sm, fnl_block_sync_sm);
		if (!is_in_legal_set(block_sync_sm, rbc_all_block_sync_sm)) begin
			$display("Critical Warning: parameter 'block_sync_sm' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", block_sync_sm, rbc_all_block_sync_sm, fnl_block_sync_sm);
		end
		//$display("block_sync = orig: '%s', any:'%s', all:'%s', final: '%s'", block_sync, rbc_any_block_sync, rbc_all_block_sync, fnl_block_sync);
		if (!is_in_legal_set(block_sync, rbc_all_block_sync)) begin
			$display("Critical Warning: parameter 'block_sync' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", block_sync, rbc_all_block_sync, fnl_block_sync);
		end
		//$display("rate_match_fifo = orig: '%s', any:'%s', all:'%s', final: '%s'", rate_match_fifo, rbc_any_rate_match_fifo, rbc_all_rate_match_fifo, fnl_rate_match_fifo);
		if (!is_in_legal_set(rate_match_fifo, rbc_all_rate_match_fifo)) begin
			$display("Critical Warning: parameter 'rate_match_fifo' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rate_match_fifo, rbc_all_rate_match_fifo, fnl_rate_match_fifo);
		end
		//$display("rate_match_fifo_latency = orig: '%s', any:'%s', all:'%s', final: '%s'", rate_match_fifo_latency, rbc_any_rate_match_fifo_latency, rbc_all_rate_match_fifo_latency, fnl_rate_match_fifo_latency);
		if (!is_in_legal_set(rate_match_fifo_latency, rbc_all_rate_match_fifo_latency)) begin
			$display("Critical Warning: parameter 'rate_match_fifo_latency' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rate_match_fifo_latency, rbc_all_rate_match_fifo_latency, fnl_rate_match_fifo_latency);
		end
		//$display("parallel_lpbk = orig: '%s', any:'%s', all:'%s', final: '%s'", parallel_lpbk, rbc_any_parallel_lpbk, rbc_all_parallel_lpbk, fnl_parallel_lpbk);
		if (!is_in_legal_set(parallel_lpbk, rbc_all_parallel_lpbk)) begin
			$display("Critical Warning: parameter 'parallel_lpbk' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", parallel_lpbk, rbc_all_parallel_lpbk, fnl_parallel_lpbk);
		end
		//$display("lpbk_force = orig: '%s', any:'%s', all:'%s', final: '%s'", lpbk_force, rbc_any_lpbk_force, rbc_all_lpbk_force, fnl_lpbk_force);
		if (!is_in_legal_set(lpbk_force, rbc_all_lpbk_force)) begin
			$display("Critical Warning: parameter 'lpbk_force' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", lpbk_force, rbc_all_lpbk_force, fnl_lpbk_force);
		end
		//$display("descrambler_lfsr_check = orig: '%s', any:'%s', all:'%s', final: '%s'", descrambler_lfsr_check, rbc_any_descrambler_lfsr_check, rbc_all_descrambler_lfsr_check, fnl_descrambler_lfsr_check);
		if (!is_in_legal_set(descrambler_lfsr_check, rbc_all_descrambler_lfsr_check)) begin
			$display("Critical Warning: parameter 'descrambler_lfsr_check' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", descrambler_lfsr_check, rbc_all_descrambler_lfsr_check, fnl_descrambler_lfsr_check);
		end
		//$display("reverse_lpbk = orig: '%s', any:'%s', all:'%s', final: '%s'", reverse_lpbk, rbc_any_reverse_lpbk, rbc_all_reverse_lpbk, fnl_reverse_lpbk);
		if (!is_in_legal_set(reverse_lpbk, rbc_all_reverse_lpbk)) begin
			$display("Critical Warning: parameter 'reverse_lpbk' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", reverse_lpbk, rbc_all_reverse_lpbk, fnl_reverse_lpbk);
		end
		//$display("rx_pol_compl = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_pol_compl, rbc_any_rx_pol_compl, rbc_all_rx_pol_compl, fnl_rx_pol_compl);
		if (!is_in_legal_set(rx_pol_compl, rbc_all_rx_pol_compl)) begin
			$display("Critical Warning: parameter 'rx_pol_compl' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_pol_compl, rbc_all_rx_pol_compl, fnl_rx_pol_compl);
		end
		//$display("rx_force_balign = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_force_balign, rbc_any_rx_force_balign, rbc_all_rx_force_balign, fnl_rx_force_balign);
		if (!is_in_legal_set(rx_force_balign, rbc_all_rx_force_balign)) begin
			$display("Critical Warning: parameter 'rx_force_balign' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_force_balign, rbc_all_rx_force_balign, fnl_rx_force_balign);
		end
		//$display("rx_lane_num = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_lane_num, rbc_any_rx_lane_num, rbc_all_rx_lane_num, fnl_rx_lane_num);
		if (!is_in_legal_set(rx_lane_num, rbc_all_rx_lane_num)) begin
			$display("Critical Warning: parameter 'rx_lane_num' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_lane_num, rbc_all_rx_lane_num, fnl_rx_lane_num);
		end
		//$display("rx_test_out_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_test_out_sel, rbc_any_rx_test_out_sel, rbc_all_rx_test_out_sel, fnl_rx_test_out_sel);
		if (!is_in_legal_set(rx_test_out_sel, rbc_all_rx_test_out_sel)) begin
			$display("Critical Warning: parameter 'rx_test_out_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_test_out_sel, rbc_all_rx_test_out_sel, fnl_rx_test_out_sel);
		end
		//$display("rx_g3_dcbal = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_g3_dcbal, rbc_any_rx_g3_dcbal, rbc_all_rx_g3_dcbal, fnl_rx_g3_dcbal);
		if (!is_in_legal_set(rx_g3_dcbal, rbc_all_rx_g3_dcbal)) begin
			$display("Critical Warning: parameter 'rx_g3_dcbal' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_g3_dcbal, rbc_all_rx_g3_dcbal, fnl_rx_g3_dcbal);
		end
		//$display("rx_b4gb_par_lpbk = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_b4gb_par_lpbk, rbc_any_rx_b4gb_par_lpbk, rbc_all_rx_b4gb_par_lpbk, fnl_rx_b4gb_par_lpbk);
		if (!is_in_legal_set(rx_b4gb_par_lpbk, rbc_all_rx_b4gb_par_lpbk)) begin
			$display("Critical Warning: parameter 'rx_b4gb_par_lpbk' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_b4gb_par_lpbk, rbc_all_rx_b4gb_par_lpbk, fnl_rx_b4gb_par_lpbk);
		end
		//$display("rx_ins_del_one_skip = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_ins_del_one_skip, rbc_any_rx_ins_del_one_skip, rbc_all_rx_ins_del_one_skip, fnl_rx_ins_del_one_skip);
		if (!is_in_legal_set(rx_ins_del_one_skip, rbc_all_rx_ins_del_one_skip)) begin
			$display("Critical Warning: parameter 'rx_ins_del_one_skip' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_ins_del_one_skip, rbc_all_rx_ins_del_one_skip, fnl_rx_ins_del_one_skip);
		end
	end

	stratixv_hssi_gen3_rx_pcs #(
		.sup_mode(fnl_sup_mode),
		.avmm_group_channel_index(avmm_group_channel_index),
		.rmfifo_empty(rmfifo_empty),
		.rmfifo_empty_data(rmfifo_empty_data),
		.rmfifo_full(rmfifo_full),
		.rmfifo_full_data(rmfifo_full_data),
		.rmfifo_pempty(rmfifo_pempty),
		.rmfifo_pempty_data(rmfifo_pempty_data),
		.rmfifo_pfull(rmfifo_pfull),
		.rmfifo_pfull_data(rmfifo_pfull_data),
		.rx_num_fixed_pat(rx_num_fixed_pat),
		.rx_num_fixed_pat_data(rx_num_fixed_pat_data),
		.silicon_rev(fnl_silicon_rev),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.mode(fnl_mode),
		.rx_clk_sel(fnl_rx_clk_sel),
		.tx_clk_sel(fnl_tx_clk_sel),
		.decoder(fnl_decoder),
		.descrambler(fnl_descrambler),
		.block_sync_sm(fnl_block_sync_sm),
		.block_sync(fnl_block_sync),
		.rate_match_fifo(fnl_rate_match_fifo),
		.rate_match_fifo_latency(fnl_rate_match_fifo_latency),
		.parallel_lpbk(fnl_parallel_lpbk),
		.lpbk_force(fnl_lpbk_force),
		.descrambler_lfsr_check(fnl_descrambler_lfsr_check),
		.reverse_lpbk(fnl_reverse_lpbk),
		.rx_pol_compl(fnl_rx_pol_compl),
		.rx_force_balign(fnl_rx_force_balign),
		.rx_lane_num(fnl_rx_lane_num),
		.rx_test_out_sel(fnl_rx_test_out_sel),
		.rx_g3_dcbal(fnl_rx_g3_dcbal),
		.rx_b4gb_par_lpbk(fnl_rx_b4gb_par_lpbk),
		.rx_ins_del_one_skip(fnl_rx_ins_del_one_skip)
	) wys (
		// ports
		.avmmaddress(avmmaddress),
		.avmmbyteen(avmmbyteen),
		.avmmclk(avmmclk),
		.avmmread(avmmread),
		.avmmreaddata(avmmreaddata),
		.avmmrstn(avmmrstn),
		.avmmwrite(avmmwrite),
		.avmmwritedata(avmmwritedata),
		.blkalgndint(blkalgndint),
		.blklockdint(blklockdint),
		.blkstart(blkstart),
		.blockselect(blockselect),
		.clkcompdeleteint(clkcompdeleteint),
		.clkcompinsertint(clkcompinsertint),
		.clkcompoverflint(clkcompoverflint),
		.clkcompundflint(clkcompundflint),
		.datain(datain),
		.dataout(dataout),
		.datavalid(datavalid),
		.eidetint(eidetint),
		.eipartialdetint(eipartialdetint),
		.errdecodeint(errdecodeint),
		.gen3clksel(gen3clksel),
		.hardresetn(hardresetn),
		.idetint(idetint),
		.inferredrxvalid(inferredrxvalid),
		.lpbkblkstart(lpbkblkstart),
		.lpbkdata(lpbkdata),
		.lpbkdatavalid(lpbkdatavalid),
		.lpbken(lpbken),
		.parlpbkb4gbin(parlpbkb4gbin),
		.parlpbkin(parlpbkin),
		.pcsrst(pcsrst),
		.pldclk28gpcs(pldclk28gpcs),
		.rcvdclk(rcvdclk),
		.rcvlfsrchkint(rcvlfsrchkint),
		.rxpolarity(rxpolarity),
		.rxrstn(rxrstn),
		.rxtestout(rxtestout),
		.scanmoden(scanmoden),
		.shutdownclk(shutdownclk),
		.skpdetint(skpdetint),
		.synchdr(synchdr),
		.syncsmen(syncsmen),
		.txdatakin(txdatakin),
		.txelecidle(txelecidle),
		.txpmaclk(txpmaclk),
		.txpth(txpth)
	);
endmodule
