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


`timescale 1 ps / 1 ps

module test_env #
(
  `ifdef ADVANCED_CLOCKING
	 parameter                  user_clock_frequency   = 145.98375e6,
   `else
         parameter                  user_clock_frequency   = "146.484375 MHz",
   `endif

   parameter                  lanes                      = 2,
   parameter                  total_samples_to_transfer  = 2000,
   parameter                  mode                       = "continuous",
   parameter                  skew_insertion_enable      = 1,
   parameter                  adaptation_fifo_depth_src  = 32,
   parameter                  adaptation_fifo_depth_snk  = 32,
   parameter                  pll_ref_freq               = "644.53125 MHz",
   parameter                  pll_ref_var                = 644.53125e6,
   parameter                  data_rate                  = "10312.5 Mbps",
   parameter                  meta_frame_length          = 200,
   parameter                  reference_clock_frequency  = "257.8125 MHz",
   parameter                  coreclkin_frequency        = "205.078125 MHz",
   parameter                  ecc_enable                 = 0
 
);

   wire                       src_link_up;
   wire   [(lanes*64)-1:0]    src_data;
   wire   [3:0]               src_sync;
  `ifdef ADVANCED_CLOCKING
   wire   [3:0]               src_error;
   `else
   wire   [2:0]                   src_error;
   `endif
   wire                       src_start_of_burst;
   wire                       src_end_of_burst;
   wire                       src_user_clock_reset;
   wire                       src_xcvr_pll_ref_clk;
   wire                       src_valid;
   wire                       src_user_clock;
   wire                       src_core_reset;

   wire                       snk_link_up;
   wire   [(lanes*64)-1:0]    snk_data;
   wire   [3:0]               snk_sync;
   wire   [(lanes+5)-1:0]     snk_error;
   wire                       snk_start_of_burst;
   wire                       snk_end_of_burst;
   wire                       snk_user_clock_reset;
   wire                       snk_xcvr_pll_ref_clk;
   wire                       snk_valid;
   wire                       snk_user_clock, src_user_clock_int;
   wire                       snk_core_reset;

   wire   [63:0]              burst_descr;
   wire                       burst_descr_ready;
   wire                       burst_descr_read;

   wire   [lanes-1:0]         pre_skew_serial_data;
   wire   [lanes-1:0]         post_skew_serial_data;

   wire                       reconfig_clk;

   wire                       src_reconfig_busy;
   wire   [(lanes*140)-1:0]   src_reconfig_to_xcvr;
   wire   [(lanes*92)-1:0]    src_reconfig_from_xcvr;

   wire                       src_phy_mgmt_clk;
   wire                       src_phy_mgmt_clk_reset;
   wire   [31:0]              src_phy_mgmt_readdata;
   wire   [31:0]              src_phy_mgmt_writedata;
   wire   [8:0]               src_phy_mgmt_address;
   wire                       src_phy_mgmt_read;
   wire                       src_phy_mgmt_write;
   wire                       src_phy_mgmt_waitrequest;

   wire                       snk_reconfig_busy;
   wire   [(lanes*70)-1:0]    snk_reconfig_to_xcvr;
   wire   [(lanes*46)-1:0]    snk_reconfig_from_xcvr;

   wire                       snk_phy_mgmt_clk;
   wire                       snk_phy_mgmt_clk_reset;
   wire   [31:0]              snk_phy_mgmt_readdata;
   wire   [31:0]              snk_phy_mgmt_writedata;
   wire   [8:0]               snk_phy_mgmt_address;
   wire                       snk_phy_mgmt_read;
   wire                       snk_phy_mgmt_write;
   wire                       snk_phy_mgmt_waitrequest;

   wire                       tg_enable;
   wire                       tg_test_mode;
   wire                       tg_enable_stalls;

   wire   [15:0]              tg_burst_count;
   wire   [63:0]              tg_words_transferred;

   wire                       tc_enable;
   wire   [15:0]              tc_burst_count;
   wire   [63:0]              tc_words_transferred;
   wire   [lanes-1:0]         tc_lane_swap_error;
   wire   [lanes-1:0]         tc_lane_sequence_error;
   wire   [lanes-1:0]         tc_lane_alignment_error;


   //
   // Source traffic generator
   //
   traffic_gen #
   (
      .lanes(lanes),
      .total_samples_to_transfer(total_samples_to_transfer)
   )
   traffic_gen
   (
      // Clocks and reset
      .user_clock(src_user_clock),
      .user_clock_reset(src_user_clock_reset),

      // Traffic checker ports
      .burst_descr(burst_descr),
      .burst_descr_read(burst_descr_read),
      .burst_descr_read_clk(snk_user_clock),
      .burst_descr_ready(burst_descr_ready),

      // Streaming data interface
      .data(src_data),
      .sync(src_sync),
      .valid(src_valid),
      .start_of_burst(src_start_of_burst),
      .end_of_burst(src_end_of_burst),
      .link_up(src_link_up),

      // Test control ports
      .tg_enable(tg_enable),
      .tg_test_mode(tg_test_mode),
      .tg_enable_stalls(tg_enable_stalls),

      // Status interface
      .tg_burst_count(tg_burst_count),
      .tg_words_transferred(tg_words_transferred)
   );
   
   //
   // Source Interlaken PHY IP management interface tie-offs
   //
   assign src_phy_mgmt_clk        = reconfig_clk;
   assign src_phy_mgmt_clk_reset  = src_core_reset;
   assign src_phy_mgmt_address    = 9'd0;
   assign src_phy_mgmt_read       = 1'b0;
   assign src_phy_mgmt_write      = 1'b0;
   assign src_phy_mgmt_writedata  = 32'd0;


   //
   // Source Interlaken PHY IP reconfiguration controller
   //
   source_reconfig #
   (
      .lanes(lanes)
   )
   source_reconfig_inst
   (
      .reconfig_busy(src_reconfig_busy),
      .mgmt_clk_clk(reconfig_clk),
      .mgmt_rst_reset(src_core_reset),
      .reconfig_mgmt_address(7'd0),
      .reconfig_mgmt_read(1'b0),
      .reconfig_mgmt_readdata(),
      .reconfig_mgmt_waitrequest(),
      .reconfig_mgmt_write(1'b0),
      .reconfig_mgmt_writedata(32'd0),
      .reconfig_to_xcvr(src_reconfig_to_xcvr),
      .reconfig_from_xcvr(src_reconfig_from_xcvr)
   );


   //
   // Link Skew Insertion
   //
   //parameter real   data_rate_real  =  data_rate_real_val;
                                      //(data_rate == "10312.5 Mbps") ? 10312.5e6 :
                                      //(data_rate == "3125 Mbps")    ?    3125e6 : 0e0;

   skew_insertion #
   (
      .lanes(lanes),
      .enable(skew_insertion_enable),
     // .data_rate(data_rate_real),
      .max_skew(107)
   )
   skew_insertion_inst
   (
      .rx_serial_data(pre_skew_serial_data),
      .tx_serial_data(post_skew_serial_data)
   );

   `ifdef DUPLEX_MODE
   //
   // Duplex Core
   //
   seriallite_iii_streaming #
   (
      .lanes(lanes),
      .adaptation_fifo_depth(adaptation_fifo_depth_src),
      .pll_ref_freq(pll_ref_freq),
      .data_rate(data_rate),
    `ifndef ADVANCED_CLOCKING
      .reference_clock_frequency(reference_clock_frequency),
      .coreclkin_frequency(coreclkin_frequency),
      .user_clock_frequency(user_clock_frequency),
    `endif
      .meta_frame_length(meta_frame_length),
      .ecc_enable (ecc_enable)

   )
   duplex_inst
   (
	 
      // Clocks and reset
      .core_reset(src_core_reset),
       `ifdef ADVANCED_CLOCKING
      .user_clock_tx(src_user_clock),
      .user_clock_reset_tx(src_user_clock_reset),
      .interface_clock_rx(snk_user_clock),
      .interface_clock_reset_rx(snk_user_clock_reset),
      `else
      .user_clock_tx(src_user_clock),
      .user_clock_reset_tx(src_user_clock_reset),
      .user_clock_rx(snk_user_clock),
      .user_clock_reset_rx(snk_user_clock_reset),
      `endif

      // Source User Interface
      .data_tx(src_data),
      .sync_tx(src_sync),
      .valid_tx(src_valid),
      .start_of_burst_tx(src_start_of_burst),
      .end_of_burst_tx(src_end_of_burst),
      .link_up_tx(src_link_up),
      .error_tx(src_error),
      
      // Sink User Interface
      .data_rx(snk_data),
      .sync_rx(snk_sync),
      .valid_rx(snk_valid),
      .start_of_burst_rx(snk_start_of_burst),
      .end_of_burst_rx(snk_end_of_burst),
      .link_up_rx(snk_link_up),
      .error_rx(snk_error),

      // Interlaken PHY IP management interface
      .phy_mgmt_clk(src_phy_mgmt_clk),
      .phy_mgmt_clk_reset(src_phy_mgmt_clk_reset),
      .phy_mgmt_address(src_phy_mgmt_address),
      .phy_mgmt_read(src_phy_mgmt_read),
      .phy_mgmt_readdata(src_phy_mgmt_readdata),
      .phy_mgmt_write(src_phy_mgmt_write),
      .phy_mgmt_writedata(src_phy_mgmt_writedata),
      .phy_mgmt_waitrequest(src_phy_mgmt_waitrequest),

      // Transceiver clock and data
      .xcvr_pll_ref_clk(src_xcvr_pll_ref_clk),
      .tx_serial_data(pre_skew_serial_data),
      .rx_serial_data(post_skew_serial_data),

      // Transceiver reconfiguration interface
      //.reconfig_clk(reconfig_clk),
      .reconfig_busy(src_reconfig_busy),
      .reconfig_to_xcvr(src_reconfig_to_xcvr),
      .reconfig_from_xcvr(src_reconfig_from_xcvr)
   );
   
   
   
   `else
   //
   // Source core
   //
   seriallite_iii_streaming_source #
   (
      .lanes(lanes),
      .adaptation_fifo_depth(adaptation_fifo_depth_src),
      .pll_ref_freq(pll_ref_freq),
      .data_rate(data_rate),
    `ifndef ADVANCED_CLOCKING
      .reference_clock_frequency(reference_clock_frequency),
      .coreclkin_frequency(coreclkin_frequency),
      .user_clock_frequency(user_clock_frequency),
    `endif
     .meta_frame_length(meta_frame_length),
     .ecc_enable (ecc_enable)

   )
   source_inst
   (
	 
      // Clocks and reset
      .core_reset(src_core_reset),
      .user_clock(src_user_clock),
      .user_clock_reset(src_user_clock_reset),

      // Source User Interface
      .data(src_data),
      .sync(src_sync),
      .valid(src_valid),
      .start_of_burst(src_start_of_burst),
      .end_of_burst(src_end_of_burst),
      .link_up(src_link_up),
      .error(src_error),

      // Interlaken PHY IP management interface
      .phy_mgmt_clk(src_phy_mgmt_clk),
      .phy_mgmt_clk_reset(src_phy_mgmt_clk_reset),
      .phy_mgmt_address(src_phy_mgmt_address),
      .phy_mgmt_read(src_phy_mgmt_read),
      .phy_mgmt_readdata(src_phy_mgmt_readdata),
      .phy_mgmt_write(src_phy_mgmt_write),
      .phy_mgmt_writedata(src_phy_mgmt_writedata),
      .phy_mgmt_waitrequest(src_phy_mgmt_waitrequest),

      // Transceiver clock and data
      .xcvr_pll_ref_clk(src_xcvr_pll_ref_clk),
      .tx_serial_data(pre_skew_serial_data),

      // Transceiver reconfiguration interface
      //.reconfig_clk(reconfig_clk),
      .reconfig_busy(src_reconfig_busy),
      .reconfig_to_xcvr(src_reconfig_to_xcvr),
      .reconfig_from_xcvr(src_reconfig_from_xcvr)
   );

   //
   // Sink Core
   //
   seriallite_iii_streaming_sink #
   (
      .lanes(lanes),
      .adaptation_fifo_depth(adaptation_fifo_depth_snk),
      .pll_ref_freq(pll_ref_freq),
      .data_rate(data_rate),
   `ifndef ADVANCED_CLOCKING
      .reference_clock_frequency(reference_clock_frequency),
      .coreclkin_frequency(coreclkin_frequency),
      .user_clock_frequency(user_clock_frequency),
    `endif
      .meta_frame_length(meta_frame_length),
      .ecc_enable (ecc_enable)
   )
   sink_inst
   (
      // Clocks and reset
      .core_reset(snk_core_reset),
      `ifdef ADVANCED_CLOCKING
      .interface_clock(snk_user_clock),
      .interface_clock_reset(snk_user_clock_reset),
      `else
      .user_clock(snk_user_clock),
      .user_clock_reset(snk_user_clock_reset),
      `endif

      // Sink User Interface
      .data(snk_data),
      .sync(snk_sync),
      .valid(snk_valid),
      .start_of_burst(snk_start_of_burst),
      .end_of_burst(snk_end_of_burst),
      .link_up(snk_link_up),
      .error(snk_error),

      // Interlaken PHY IP management interface
      .phy_mgmt_clk(snk_phy_mgmt_clk),
      .phy_mgmt_clk_reset(snk_phy_mgmt_clk_reset),
      .phy_mgmt_address(snk_phy_mgmt_address),
      .phy_mgmt_read(snk_phy_mgmt_read),
      .phy_mgmt_readdata(snk_phy_mgmt_readdata),
      .phy_mgmt_write(snk_phy_mgmt_write),
      .phy_mgmt_writedata(snk_phy_mgmt_writedata),
      .phy_mgmt_waitrequest(snk_phy_mgmt_waitrequest),

      // Transceiver clock and data
      .xcvr_pll_ref_clk(snk_xcvr_pll_ref_clk),
      .rx_serial_data(post_skew_serial_data),

      // Transceiver reconfiguration interface
      //.reconfig_clk(reconfig_clk),
      .reconfig_busy(snk_reconfig_busy),
      .reconfig_to_xcvr(snk_reconfig_to_xcvr),
      .reconfig_from_xcvr(snk_reconfig_from_xcvr)
   );


   //
   // Sink Interlaken PHY IP management interface tie-offs
   //
   assign snk_phy_mgmt_clk        = reconfig_clk;
   assign snk_phy_mgmt_clk_reset  = snk_core_reset;
   assign snk_phy_mgmt_address    = 9'd0;
   assign snk_phy_mgmt_read       = 1'b0;
   assign snk_phy_mgmt_write      = 1'b0;
   assign snk_phy_mgmt_writedata  = 32'd0;


   //
   // Interlaken PHY IP reconfiguration controller
   //
   sink_reconfig #
   (
      .lanes(lanes)
   )
   sink_reconfig_inst
   (
      .reconfig_busy(snk_reconfig_busy),
      .mgmt_clk_clk(reconfig_clk),
      .mgmt_rst_reset(snk_core_reset),
      .reconfig_mgmt_address(7'd0),
      .reconfig_mgmt_read(1'b0),
      .reconfig_mgmt_readdata(),
      .reconfig_mgmt_waitrequest(),
      .reconfig_mgmt_write(1'b0),
      .reconfig_mgmt_writedata(32'd0),
      .reconfig_to_xcvr(snk_reconfig_to_xcvr),
      .reconfig_from_xcvr(snk_reconfig_from_xcvr)
   );
   
   `endif

   //
   // Sink Traffic Checker
   traffic_check #
   (
      .lanes(lanes)
   )
   traffic_check
   (
      // Clocks and reset
      .user_clock(snk_user_clock),
      .user_clock_reset(snk_user_clock_reset),

      // Traffic checker ports
      .burst_descr(burst_descr),
      .burst_descr_read(burst_descr_read),
      .burst_descr_ready(burst_descr_ready),

      // Streaming data interface
      .data(snk_data),
      .sync(snk_sync),
      .valid(snk_valid),
      .start_of_burst(snk_start_of_burst),
      .end_of_burst(snk_end_of_burst),

      // Test control ports
      .tc_enable(tc_enable),
      .tc_test_mode(tg_test_mode),
      .tc_enable_stalls(tg_enable_stalls),

      // Status ports
      .tc_burst_count(tc_burst_count),
      .tc_words_received(tc_words_transferred),

      // Status interface
      .tc_lane_swap_error(tc_lane_swap_error),
      .tc_lane_sequence_error(tc_lane_sequence_error),
      .tc_lane_alignment_error(tc_lane_alignment_error)
   );


   testbench #
   (
      `ifdef ADVANCED_CLOCKING
      .user_clock_frequency(user_clock_frequency),
      `endif
      .lanes(lanes),
      .total_samples_to_transfer(total_samples_to_transfer),
      .pll_ref_freq(pll_ref_freq),
      .pll_ref_var(pll_ref_var)
   )
   testbench
   (
      .reconfig_clk(reconfig_clk),
      `ifdef ADVANCED_CLOCKING
      .source_user_clock(src_user_clock),
      .source_user_clock_reset(src_user_clock_reset),
      `endif
      .sink_pll_ref_clk(snk_xcvr_pll_ref_clk),
      .sink_test_reset(snk_core_reset),
      .source_pll_ref_clk(src_xcvr_pll_ref_clk),
      .source_test_reset(src_core_reset),
      .tc_enable(tc_enable),
      .tg_enable(tg_enable),
      .tg_test_mode(tg_test_mode),
			.tg_enable_stalls(tg_enable_stalls)
   );

endmodule  // test_env
