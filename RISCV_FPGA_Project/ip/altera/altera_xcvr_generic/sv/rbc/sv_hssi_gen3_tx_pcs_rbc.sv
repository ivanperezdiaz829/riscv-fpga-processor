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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_gen3_tx_pcs
//

`timescale 1 ns / 1 ps

module sv_hssi_gen3_tx_pcs_rbc #(
	// unconstrained parameters
	parameter sup_mode = "<auto_single>",	// engr_mode, user_mode

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter tx_bitslip = "tx_bitslip_val",	// tx_bitslip_val
	parameter tx_bitslip_data = 5'b0,	// 5
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047

	// constrained parameters
	parameter mode = "<auto_single>",	// disable_pcs, gen3_func, par_lpbk, prbs, sup_engr_mode, sup_user_mode
	parameter tx_clk_sel = "<auto_single>",	// dig_clk1_8g, disable_clk, tx_pma_clk
	parameter encoder = "<auto_single>",	// bypass_encoder, enable_encoder
	parameter scrambler = "<auto_single>",	// bypass_scrambler, enable_scrambler
	parameter reverse_lpbk = "<auto_single>",	// rev_lpbk_dis, rev_lpbk_en
	parameter prbs_generator = "<auto_single>",	// prbs_gen_dis, prbs_gen_en
	parameter tx_pol_compl = "<auto_single>",	// tx_pol_compl_dis, tx_pol_compl_en
	parameter tx_lane_num = "<auto_single>",	// lane_0, lane_1, lane_2, lane_3, lane_4, lane_5, lane_6, lane_7, not_used
	parameter tx_g3_dcbal = "<auto_single>",	// tx_g3_dcbal_dis, tx_g3_dcbal_en
	parameter tx_gbox_byp = "<auto_single>"	// bypass_gbox, enable_gbox
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
	input  wire         	blkstartin,
	output wire         	blockselect,
	input  wire   [31:0]	datain,
	output wire   [31:0]	dataout,
	input  wire         	datavalid,
	output wire         	errencode,
	input  wire         	gen3clksel,
	input  wire         	hardresetn,
	input  wire         	lpbkblkstart,
	input  wire   [33:0]	lpbkdatain,
	input  wire         	lpbkdatavalid,
	input  wire         	lpbken,
	output wire   [35:0]	parlpbkb4gbout,
	output wire   [31:0]	parlpbkout,
	input  wire         	pcsrst,
	input  wire         	scanmoden,
	input  wire         	shutdownclk,
	input  wire    [1:0]	syncin,
	input  wire         	txelecidle,
	input  wire         	txpmaclk,
	input  wire         	txpth,
	input  wire         	txrstn,
	output wire   [19:0]	txtestout
);
	import altera_xcvr_functions::*;

	// sup_mode external parameter (no RBC)
	localparam rbc_all_sup_mode = "(engr_mode,user_mode)";
	localparam rbc_any_sup_mode = "user_mode";
	localparam fnl_sup_mode = (sup_mode == "<auto_any>" || sup_mode == "<auto_single>") ? rbc_any_sup_mode : sup_mode;

	// use_default_base_address external parameter (no RBC)
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// mode, RBC-validated
	localparam rbc_all_mode = "(gen3_func,prbs,par_lpbk,disable_pcs)";
	localparam rbc_any_mode = "gen3_func";
	localparam fnl_mode = (mode == "<auto_any>" || mode == "<auto_single>") ? rbc_any_mode : mode;

	// tx_clk_sel, RBC-validated
	localparam rbc_all_tx_clk_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("tx_pma_clk")
			 : (fnl_mode == "prbs" ) ? ("tx_pma_clk")
				 : (fnl_mode == "par_lpbk") ? ("dig_clk1_8g")
					 : (fnl_mode == "disable_pcs") ? ("disable_clk") : "(disable_clk,tx_pma_clk,dig_clk1_8g)"
		) : "(disable_clk,tx_pma_clk,dig_clk1_8g)";
	localparam rbc_any_tx_clk_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("tx_pma_clk")
			 : (fnl_mode == "prbs" ) ? ("tx_pma_clk")
				 : (fnl_mode == "par_lpbk") ? ("dig_clk1_8g")
					 : (fnl_mode == "disable_pcs") ? ("disable_clk") : "tx_pma_clk"
		) : "tx_pma_clk";
	localparam fnl_tx_clk_sel = (tx_clk_sel == "<auto_any>" || tx_clk_sel == "<auto_single>") ? rbc_any_tx_clk_sel : tx_clk_sel;

	// encoder, RBC-validated
	localparam rbc_all_encoder = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_encoder")
			 : (fnl_mode == "par_lpbk") ? ("enable_encoder")
				 : (fnl_mode == "prbs" ) ? ("bypass_encoder")
					 : (fnl_mode == "disable_pcs") ? ("bypass_encoder") : "(bypass_encoder,enable_encoder)"
		) : "(bypass_encoder,enable_encoder)";
	localparam rbc_any_encoder = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_encoder")
			 : (fnl_mode == "par_lpbk") ? ("enable_encoder")
				 : (fnl_mode == "prbs" ) ? ("bypass_encoder")
					 : (fnl_mode == "disable_pcs") ? ("bypass_encoder") : "enable_encoder"
		) : "enable_encoder";
	localparam fnl_encoder = (encoder == "<auto_any>" || encoder == "<auto_single>") ? rbc_any_encoder : encoder;

	// scrambler, RBC-validated
	localparam rbc_all_scrambler = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("(bypass_scrambler,enable_scrambler)")
			 : (fnl_mode == "prbs" || fnl_mode == "par_lpbk") ? ("enable_scrambler")
				 : (fnl_mode == "prbs" ) ? ("bypass_scrambler")
					 : (fnl_mode == "disable_pcs") ? ("bypass_scrambler") : "(bypass_scrambler,enable_scrambler)"
		) : "(bypass_scrambler,enable_scrambler)";
	localparam rbc_any_scrambler = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_scrambler")
			 : (fnl_mode == "prbs" || fnl_mode == "par_lpbk") ? ("enable_scrambler")
				 : (fnl_mode == "prbs" ) ? ("bypass_scrambler")
					 : (fnl_mode == "disable_pcs") ? ("bypass_scrambler") : "enable_scrambler"
		) : "enable_scrambler";
	localparam fnl_scrambler = (scrambler == "<auto_any>" || scrambler == "<auto_single>") ? rbc_any_scrambler : scrambler;

	// reverse_lpbk, RBC-validated
	localparam rbc_all_reverse_lpbk = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("rev_lpbk_en")
			 : (fnl_mode == "par_lpbk") ? ("rev_lpbk_en")
				 : (fnl_mode == "prbs" ) ? ("rev_lpbk_dis")
					 : (fnl_mode == "disable_pcs") ? ("rev_lpbk_dis") : "(rev_lpbk_dis,rev_lpbk_en)"
		) : "(rev_lpbk_dis,rev_lpbk_en)";
	localparam rbc_any_reverse_lpbk = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("rev_lpbk_en")
			 : (fnl_mode == "par_lpbk") ? ("rev_lpbk_en")
				 : (fnl_mode == "prbs" ) ? ("rev_lpbk_dis")
					 : (fnl_mode == "disable_pcs") ? ("rev_lpbk_dis") : "rev_lpbk_en"
		) : "rev_lpbk_en";
	localparam fnl_reverse_lpbk = (reverse_lpbk == "<auto_any>" || reverse_lpbk == "<auto_single>") ? rbc_any_reverse_lpbk : reverse_lpbk;

	// prbs_generator, RBC-validated
	localparam rbc_all_prbs_generator = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("prbs_gen_dis")
			 : (fnl_mode == "prbs") ? ("prbs_gen_en")
				 : (fnl_mode == "par_lpbk") ? ("prbs_gen_dis")
					 : (fnl_mode == "disable_pcs") ? ("prbs_gen_dis") : "(prbs_gen_dis,prbs_gen_en)"
		) : "(prbs_gen_dis,prbs_gen_en)";
	localparam rbc_any_prbs_generator = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("prbs_gen_dis")
			 : (fnl_mode == "prbs") ? ("prbs_gen_en")
				 : (fnl_mode == "par_lpbk") ? ("prbs_gen_dis")
					 : (fnl_mode == "disable_pcs") ? ("prbs_gen_dis") : "prbs_gen_dis"
		) : "prbs_gen_dis";
	localparam fnl_prbs_generator = (prbs_generator == "<auto_any>" || prbs_generator == "<auto_single>") ? rbc_any_prbs_generator : prbs_generator;

	// tx_pol_compl, RBC-validated
	localparam rbc_all_tx_pol_compl = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("tx_pol_compl_dis")
			 : (fnl_mode == "par_lpbk") ? ("tx_pol_compl_dis")
				 : (fnl_mode == "prbs") ? ("tx_pol_compl_dis")
					 : (fnl_mode == "disable_pcs") ? ("tx_pol_compl_dis") : "(tx_pol_compl_en,tx_pol_compl_dis)"
		) : "(tx_pol_compl_en,tx_pol_compl_dis)";
	localparam rbc_any_tx_pol_compl = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("tx_pol_compl_dis")
			 : (fnl_mode == "par_lpbk") ? ("tx_pol_compl_dis")
				 : (fnl_mode == "prbs") ? ("tx_pol_compl_dis")
					 : (fnl_mode == "disable_pcs") ? ("tx_pol_compl_dis") : "tx_pol_compl_dis"
		) : "tx_pol_compl_dis";
	localparam fnl_tx_pol_compl = (tx_pol_compl == "<auto_any>" || tx_pol_compl == "<auto_single>") ? rbc_any_tx_pol_compl : tx_pol_compl;

	// tx_lane_num, RBC-validated
	localparam rbc_all_tx_lane_num = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "disable_pcs") ? ("lane_0") : "(lane_0,lane_1,lane_2,lane_3,lane_4,lane_5,lane_6,lane_7,not_used)"
		) : "(lane_0,lane_1,lane_2,lane_3,lane_4,lane_5,lane_6,lane_7,not_used)";
	localparam rbc_any_tx_lane_num = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "disable_pcs") ? ("lane_0") : "lane_0"
		) : "lane_0";
	localparam fnl_tx_lane_num = (tx_lane_num == "<auto_any>" || tx_lane_num == "<auto_single>") ? rbc_any_tx_lane_num : tx_lane_num;

	// tx_g3_dcbal, RBC-validated
	localparam rbc_all_tx_g3_dcbal = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("tx_g3_dcbal_en")
			 : (fnl_mode == "par_lpbk") ? ("tx_g3_dcbal_dis")
				 : (fnl_mode == "disable_pcs") ? ("tx_g3_dcbal_dis") : "(tx_g3_dcbal_dis,tx_g3_dcbal_en)"
		) : "(tx_g3_dcbal_dis,tx_g3_dcbal_en)";
	localparam rbc_any_tx_g3_dcbal = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("tx_g3_dcbal_en")
			 : (fnl_mode == "par_lpbk") ? ("tx_g3_dcbal_dis")
				 : (fnl_mode == "disable_pcs") ? ("tx_g3_dcbal_dis") : "tx_g3_dcbal_en"
		) : "tx_g3_dcbal_en";
	localparam fnl_tx_g3_dcbal = (tx_g3_dcbal == "<auto_any>" || tx_g3_dcbal == "<auto_single>") ? rbc_any_tx_g3_dcbal : tx_g3_dcbal;

	// tx_gbox_byp, RBC-validated
	localparam rbc_all_tx_gbox_byp = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_gbox")
			 : (fnl_mode == "par_lpbk") ? ("enable_gbox")
				 : (fnl_mode == "disable_pcs") ? ("bypass_gbox") : "(bypass_gbox,enable_gbox)"
		) : "(bypass_gbox,enable_gbox)";
	localparam rbc_any_tx_gbox_byp = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "gen3_func") ? ("enable_gbox")
			 : (fnl_mode == "par_lpbk") ? ("enable_gbox")
				 : (fnl_mode == "disable_pcs") ? ("bypass_gbox") : "bypass_gbox"
		) : "bypass_gbox";
	localparam fnl_tx_gbox_byp = (tx_gbox_byp == "<auto_any>" || tx_gbox_byp == "<auto_single>") ? rbc_any_tx_gbox_byp : tx_gbox_byp;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("sup_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", sup_mode, rbc_any_sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		if (!is_in_legal_set(sup_mode, rbc_all_sup_mode)) begin
			$display("Critical Warning: parameter 'sup_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
		//$display("mode = orig: '%s', any:'%s', all:'%s', final: '%s'", mode, rbc_any_mode, rbc_all_mode, fnl_mode);
		if (!is_in_legal_set(mode, rbc_all_mode)) begin
			$display("Critical Warning: parameter 'mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", mode, rbc_all_mode, fnl_mode);
		end
		//$display("tx_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_clk_sel, rbc_any_tx_clk_sel, rbc_all_tx_clk_sel, fnl_tx_clk_sel);
		if (!is_in_legal_set(tx_clk_sel, rbc_all_tx_clk_sel)) begin
			$display("Critical Warning: parameter 'tx_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_clk_sel, rbc_all_tx_clk_sel, fnl_tx_clk_sel);
		end
		//$display("encoder = orig: '%s', any:'%s', all:'%s', final: '%s'", encoder, rbc_any_encoder, rbc_all_encoder, fnl_encoder);
		if (!is_in_legal_set(encoder, rbc_all_encoder)) begin
			$display("Critical Warning: parameter 'encoder' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", encoder, rbc_all_encoder, fnl_encoder);
		end
		//$display("scrambler = orig: '%s', any:'%s', all:'%s', final: '%s'", scrambler, rbc_any_scrambler, rbc_all_scrambler, fnl_scrambler);
		if (!is_in_legal_set(scrambler, rbc_all_scrambler)) begin
			$display("Critical Warning: parameter 'scrambler' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", scrambler, rbc_all_scrambler, fnl_scrambler);
		end
		//$display("reverse_lpbk = orig: '%s', any:'%s', all:'%s', final: '%s'", reverse_lpbk, rbc_any_reverse_lpbk, rbc_all_reverse_lpbk, fnl_reverse_lpbk);
		if (!is_in_legal_set(reverse_lpbk, rbc_all_reverse_lpbk)) begin
			$display("Critical Warning: parameter 'reverse_lpbk' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", reverse_lpbk, rbc_all_reverse_lpbk, fnl_reverse_lpbk);
		end
		//$display("prbs_generator = orig: '%s', any:'%s', all:'%s', final: '%s'", prbs_generator, rbc_any_prbs_generator, rbc_all_prbs_generator, fnl_prbs_generator);
		if (!is_in_legal_set(prbs_generator, rbc_all_prbs_generator)) begin
			$display("Critical Warning: parameter 'prbs_generator' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prbs_generator, rbc_all_prbs_generator, fnl_prbs_generator);
		end
		//$display("tx_pol_compl = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_pol_compl, rbc_any_tx_pol_compl, rbc_all_tx_pol_compl, fnl_tx_pol_compl);
		if (!is_in_legal_set(tx_pol_compl, rbc_all_tx_pol_compl)) begin
			$display("Critical Warning: parameter 'tx_pol_compl' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_pol_compl, rbc_all_tx_pol_compl, fnl_tx_pol_compl);
		end
		//$display("tx_lane_num = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_lane_num, rbc_any_tx_lane_num, rbc_all_tx_lane_num, fnl_tx_lane_num);
		if (!is_in_legal_set(tx_lane_num, rbc_all_tx_lane_num)) begin
			$display("Critical Warning: parameter 'tx_lane_num' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_lane_num, rbc_all_tx_lane_num, fnl_tx_lane_num);
		end
		//$display("tx_g3_dcbal = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_g3_dcbal, rbc_any_tx_g3_dcbal, rbc_all_tx_g3_dcbal, fnl_tx_g3_dcbal);
		if (!is_in_legal_set(tx_g3_dcbal, rbc_all_tx_g3_dcbal)) begin
			$display("Critical Warning: parameter 'tx_g3_dcbal' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_g3_dcbal, rbc_all_tx_g3_dcbal, fnl_tx_g3_dcbal);
		end
		//$display("tx_gbox_byp = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_gbox_byp, rbc_any_tx_gbox_byp, rbc_all_tx_gbox_byp, fnl_tx_gbox_byp);
		if (!is_in_legal_set(tx_gbox_byp, rbc_all_tx_gbox_byp)) begin
			$display("Critical Warning: parameter 'tx_gbox_byp' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_gbox_byp, rbc_all_tx_gbox_byp, fnl_tx_gbox_byp);
		end
	end

	stratixv_hssi_gen3_tx_pcs #(
		.sup_mode(fnl_sup_mode),
		.avmm_group_channel_index(avmm_group_channel_index),
		.tx_bitslip(tx_bitslip),
		.tx_bitslip_data(tx_bitslip_data),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.mode(fnl_mode),
		.tx_clk_sel(fnl_tx_clk_sel),
		.encoder(fnl_encoder),
		.scrambler(fnl_scrambler),
		.reverse_lpbk(fnl_reverse_lpbk),
		.prbs_generator(fnl_prbs_generator),
		.tx_pol_compl(fnl_tx_pol_compl),
		.tx_lane_num(fnl_tx_lane_num),
		.tx_g3_dcbal(fnl_tx_g3_dcbal),
		.tx_gbox_byp(fnl_tx_gbox_byp)
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
		.blkstartin(blkstartin),
		.blockselect(blockselect),
		.datain(datain),
		.dataout(dataout),
		.datavalid(datavalid),
		.errencode(errencode),
		.gen3clksel(gen3clksel),
		.hardresetn(hardresetn),
		.lpbkblkstart(lpbkblkstart),
		.lpbkdatain(lpbkdatain),
		.lpbkdatavalid(lpbkdatavalid),
		.lpbken(lpbken),
		.parlpbkb4gbout(parlpbkb4gbout),
		.parlpbkout(parlpbkout),
		.pcsrst(pcsrst),
		.scanmoden(scanmoden),
		.shutdownclk(shutdownclk),
		.syncin(syncin),
		.txelecidle(txelecidle),
		.txpmaclk(txpmaclk),
		.txpth(txpth),
		.txrstn(txrstn),
		.txtestout(txtestout)
	);
endmodule
