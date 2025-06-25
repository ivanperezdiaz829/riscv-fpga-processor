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


module cyclonev_hps_interface_clocks_resets #(
	parameter h2f_user0_clk_freq = 100,
	parameter h2f_user1_clk_freq = 100,
	parameter h2f_user2_clk_freq = 100
)(
	output wire  h2f_rst_n,
	output wire  h2f_cold_rst_n,
	output wire  h2f_user0_clk,
	output wire  h2f_user1_clk,
	output wire  h2f_user2_clk,
	output wire  h2f_pending_rst_req_n,
	input  wire  f2h_pending_rst_ack,
	input  wire  f2h_cold_rst_req_n,
	input  wire  f2h_dbg_rst_req_n,
	input  wire  f2h_warm_rst_req_n,
	input  wire  f2h_sdram_ref_clk,
	input  wire  f2h_periph_ref_clk,
   input  wire  ptp_ref_clk
);

	altera_avalon_reset_source #(
		.ASSERT_HIGH_RESET(0),
		.INITIAL_RESET_CYCLES(0)
	) h2f_reset (
		.clk(1'b0),
		.reset(h2f_rst_n)
	);
	
	altera_avalon_reset_source #(
		.ASSERT_HIGH_RESET(0),
		.INITIAL_RESET_CYCLES(0)
	) h2f_cold_reset (
		.clk(1'b0),
		.reset(h2f_cold_rst_n)
	);
	
	altera_avalon_clock_source #(
		.CLOCK_RATE(h2f_user0_clk_freq),
		.CLOCK_UNIT(1000000)
	) h2f_user0_clock (
		.clk(h2f_user0_clk)
	);
	
	altera_avalon_clock_source #(
		.CLOCK_RATE(h2f_user1_clk_freq),
		.CLOCK_UNIT(1000000)
	) h2f_user1_clock (
		.clk(h2f_user1_clk)
	);
	
	altera_avalon_clock_source #(
		.CLOCK_RATE(h2f_user2_clk_freq),
		.CLOCK_UNIT(1000000)
	) h2f_user2_clock (
		.clk(h2f_user2_clk)
	);
	
	h2f_warm_reset_handshake_bfm h2f_warm_reset_handshake (
		.sig_h2f_pending_rst_req_n(h2f_pending_rst_req_n),
		.sig_f2h_pending_rst_ack(f2h_pending_rst_ack)
	);
	
	f2h_cold_reset_req_bfm f2h_cold_reset_req (
		.sig_f2h_cold_rst_req_n(f2h_cold_rst_req_n)
	);
	
	f2h_debug_reset_req_bfm f2h_debug_reset_req (
		.sig_f2h_dbg_rst_req_n(f2h_dbg_rst_req_n)
	);
	
	f2h_warm_reset_req_bfm f2h_warm_reset_req (
		.sig_f2h_warm_rst_req_n(f2h_warm_rst_req_n)
	);
	
endmodule 

module arriav_hps_interface_clocks_resets #(
	parameter h2f_user0_clk_freq = 100,
	parameter h2f_user1_clk_freq = 100,
	parameter h2f_user2_clk_freq = 100
)(
	output wire  h2f_rst_n,
	output wire  h2f_cold_rst_n,
	output wire  h2f_user0_clk,
	output wire  h2f_user1_clk,
	output wire  h2f_user2_clk,
	output wire  h2f_pending_rst_req_n,
	input  wire  f2h_pending_rst_ack,
	input  wire  f2h_cold_rst_req_n,
	input  wire  f2h_dbg_rst_req_n,
	input  wire  f2h_warm_rst_req_n,
	input  wire  f2h_sdram_ref_clk,
	input  wire  f2h_periph_ref_clk,
   input  wire  ptp_ref_clk
);

	altera_avalon_reset_source #(
		.ASSERT_HIGH_RESET(0),
		.INITIAL_RESET_CYCLES(0)
	) h2f_reset (
		.clk(1'b0),
		.reset(h2f_rst_n)
	);
	
	altera_avalon_reset_source #(
		.ASSERT_HIGH_RESET(0),
		.INITIAL_RESET_CYCLES(0)
	) h2f_cold_reset (
		.clk(1'b0),
		.reset(h2f_cold_rst_n)
	);
	
	altera_avalon_clock_source #(
		.CLOCK_RATE(h2f_user0_clk_freq),
		.CLOCK_UNIT(1000000)
	) h2f_user0_clock (
		.clk(h2f_user0_clk)
	);
	
	altera_avalon_clock_source #(
		.CLOCK_RATE(h2f_user1_clk_freq),
		.CLOCK_UNIT(1000000)
	) h2f_user1_clock (
		.clk(h2f_user1_clk)
	);
	
	altera_avalon_clock_source #(
		.CLOCK_RATE(h2f_user2_clk_freq),
		.CLOCK_UNIT(1000000)
	) h2f_user2_clock (
		.clk(h2f_user2_clk)
	);
	
	h2f_warm_reset_handshake_bfm h2f_warm_reset_handshake (
		.sig_h2f_pending_rst_req_n(h2f_pending_rst_req_n),
		.sig_f2h_pending_rst_ack(f2h_pending_rst_ack)
	);
	
	f2h_cold_reset_req_bfm f2h_cold_reset_req (
		.sig_f2h_cold_rst_req_n(f2h_cold_rst_req_n)
	);
	
	f2h_debug_reset_req_bfm f2h_debug_reset_req (
		.sig_f2h_dbg_rst_req_n(f2h_dbg_rst_req_n)
	);
	
	f2h_warm_reset_req_bfm f2h_warm_reset_req (
		.sig_f2h_warm_rst_req_n(f2h_warm_rst_req_n)
	);
	
endmodule 