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

module seriallite_iii_streaming_demo #
(
   parameter                  lanes                      = 2,
   parameter   [63:0]         total_samples_to_transfer  = 64'hFFFFFFFFFFFFFFFF,
   parameter                  pll_type                   = "CMU",
   parameter                  lane_fifo_depth            = 32,  // sink adaptation fifo depth
   parameter                  adaptation_fifo_depth      = 32,  // source adaptation fifo depth
   parameter                  pll_ref_freq               = "644.53125 MHz",  		// transceiver ref clock
   parameter                  data_rate                  = "10312.5 Mbps",
   parameter                  meta_frame_length          = 200,
   parameter                  ecc_enable                 = 0,
   parameter                  reference_clock_frequency  = "257.8125 MHz",			// fpll reference clock
   parameter                  coreclkin_frequency        = "205.078125 MHz",
   parameter                  user_clock_frequency       = "146.484375 MHz"
)
(
   // System clocks and reset
   input                      mgmt_clk,
   input                      mgmt_reset_n,		

   input                      src_pll_ref_clk,
   input                      snk_pll_ref_clk,

   // Transceiver serial data
   output   [lanes-1:0]       tx,
   input    [lanes-1:0]       rx,

   // Tx/Rx activity indicators
   output                     tx_activity_n,
   output                     rx_activity_n,

   // Source/Sink link up indicators
   output                     src_link_up_n,
   output                     snk_link_up_n,

   // Source/Sink reset indicators
   output                     src_core_reset_n,
   output                     snk_core_reset_n,

   // Two Line LCD Display
   output                     lcd_csn,
   output                     lcd_d_cn,
   output                     lcd_wen,
   inout    [7:0]             lcd_data
	
		
);
   
   wire                       src_core_reset;
   wire                       src_user_clock;
   wire                       src_user_clock_reset;
   wire                       src_link_up;
   wire   [(lanes*64)-1:0]    src_data;
   wire   [3:0]               src_sync;

   wire   [1:0]               src_error;
   wire                       src_start_of_burst;
   wire                       src_end_of_burst;
   wire                       src_valid;

   wire                       snk_core_reset;
   wire                       snk_user_clock;
   wire                       snk_user_clock_reset;
   wire                       snk_link_up;
   wire   [(lanes*64)-1:0]    snk_data;
   wire   [3:0]               snk_sync;
   wire   [(lanes+5)-1:0]     snk_error;
   wire                       snk_start_of_burst;
   wire                       snk_end_of_burst;
   wire                       snk_valid;

   wire                       src_reconfig_busy;
   wire   [(lanes*140)-1:0]   src_reconfig_to_xcvr;
   wire   [(lanes*92)-1:0]    src_reconfig_from_xcvr;

   wire   [31:0]              src_phy_mgmt_readdata;
   wire   [31:0]              src_phy_mgmt_writedata;
   wire   [8:0]               src_phy_mgmt_address;
   wire                       src_phy_mgmt_read;
   wire                       src_phy_mgmt_write;
   wire                       src_phy_mgmt_waitrequest;

   wire                       snk_reconfig_busy;
   wire   [(lanes*70)-1:0]    snk_reconfig_to_xcvr;
   wire   [(lanes*46)-1:0]    snk_reconfig_from_xcvr;

   wire   [8:0]               snk_phy_mgmt_address;
   wire                       snk_phy_mgmt_write;
   wire                       snk_phy_mgmt_read;
   wire   [31:0]              snk_phy_mgmt_readdata;
   wire   [31:0]              snk_phy_mgmt_writedata;
   wire                       snk_phy_mgmt_waitrequest;

   wire                       tg_enable;
   wire                       tg_test_mode;
   wire                       tg_enable_stalls;
   wire                       crc_error_inject;

   wire   [15:0]              tg_burst_count;
   wire   [63:0]              tg_words_transferred;

   wire                       tc_enable = 1'b1;
   wire   [15:0]              tc_burst_count;
   wire   [63:0]              tc_words_transferred;

   wire   [lanes-1:0]         tc_lane_swap_error;
   wire   [lanes-1:0]         tc_lane_sequence_error;
   wire   [lanes-1:0]         tc_lane_alignment_error;

   wire   [8:0]               demo_mgmt_address;
   wire                       demo_mgmt_write;
   wire                       demo_mgmt_read;
   wire   [31:0]              demo_mgmt_readdata;
   wire   [31:0]              demo_mgmt_writedata;
   wire                       demo_mgmt_waitrequest;
	wire								mgmt_clk_reset;


   //
   // Drive the, active-low, user leds
   //
   assign src_core_reset_n = ~src_core_reset;
   assign snk_core_reset_n = ~snk_core_reset;
	
   // Activity indicators
   assign tx_activity_n    = ~src_valid;
   assign rx_activity_n    = ~snk_valid;

   // Link Status indicators
   assign src_link_up_n    = ~src_link_up;
   assign snk_link_up_n    = ~snk_link_up;
	

	
  demo_mgmt #
   (
      .lanes(lanes)
   )
   demo_mgmt
   (
      // Traffic generator control
      .tg_enable(tg_enable),
      .tg_test_mode(tg_test_mode),
      .tg_enable_stalls(tg_enable_stalls),
      .crc_err_inject(crc_error_inject),

      // Traffic generator status
      .tg_burst_count(tg_burst_count),
      .tg_words_transferred(tg_words_transferred),

      // Source core interface
      .source_reset(src_core_reset),  // output
      .source_user_clock(src_user_clock),  
      .source_user_clock_reset(src_user_clock_reset), // input
      .source_error(|src_error[1:0]),  // ECC not logged

      // Sink core interface
      .sink_reset(snk_core_reset),  // output
      .sink_user_clock(snk_user_clock),
      .sink_user_clock_reset(snk_user_clock_reset),  //input
      .sink_error(snk_error[(lanes+3)-1:0]),  // ECC not logged

      // Traffic checker status
      .tc_burst_count(tc_burst_count),
      .tc_words_received(tc_words_transferred),
      .tc_lane_swap_error(tc_lane_swap_error),
      .tc_lane_sequence_error(tc_lane_sequence_error),
      .tc_lane_alignment_error(tc_lane_alignment_error),

      // Demo management interface
      .demo_mgmt_clk(mgmt_clk),     
      .demo_mgmt_clk_reset(mgmt_clk_reset),
      .demo_mgmt_address(demo_mgmt_address),
      .demo_mgmt_write(demo_mgmt_write),
      .demo_mgmt_read(demo_mgmt_read),
      .demo_mgmt_readdata(demo_mgmt_readdata),
      .demo_mgmt_writedata(demo_mgmt_writedata),
      .demo_mgmt_waitrequest(demo_mgmt_waitrequest)
   );


   traffic_gen #
   (
      .lanes(lanes),
      .total_samples_to_transfer(total_samples_to_transfer)
   )
   traffic_gen
   (
      // Clocks and reset
      .user_clock(src_user_clock),
      .user_clock_reset(src_user_clock_reset | src_core_reset),

      // Streaming data interface
      .data(src_data),
      .sync(src_sync),
      .valid(src_valid),
      .start_of_burst(src_start_of_burst),
      .end_of_burst(src_end_of_burst),
      .link_up(src_link_up & snk_link_up),   

      // Test control ports
      .tg_enable(tg_enable),
      .tg_test_mode(tg_test_mode),
      .tg_enable_stalls(tg_enable_stalls),

      // Status interface
      .tg_burst_count(tg_burst_count),
      .tg_words_transferred(tg_words_transferred)
   );


   seriallite_iii_streaming_source #
   (
      .lanes(lanes),
      .adaptation_fifo_depth(adaptation_fifo_depth),
      .pll_ref_freq(pll_ref_freq),
      .data_rate(data_rate),
      .meta_frame_length(meta_frame_length),
      .reference_clock_frequency(reference_clock_frequency),
      .coreclkin_frequency(coreclkin_frequency),
      .user_clock_frequency(user_clock_frequency),
      .pll_type (pll_type),
      .ecc_enable (ecc_enable)
   )
   source
   (
      .core_reset(mgmt_clk_reset),
      .data(src_data),
      .end_of_burst(src_end_of_burst),
      .error(src_error),
      .xcvr_pll_ref_clk(src_pll_ref_clk),
      .start_of_burst(src_start_of_burst),
      .sync(src_sync),
      .link_up(src_link_up),
      .tx_serial_data(tx),
      .user_clock(src_user_clock),
      .user_clock_reset(src_user_clock_reset),
      .valid(src_valid),
      .crc_error_inject({lanes{crc_error_inject}}),
      .phy_mgmt_clk(mgmt_clk),
      .phy_mgmt_clk_reset(mgmt_clk_reset),
      .phy_mgmt_address(src_phy_mgmt_address),
      .phy_mgmt_read(src_phy_mgmt_read),
      .phy_mgmt_readdata(src_phy_mgmt_readdata),
      .phy_mgmt_write(src_phy_mgmt_write),
      .phy_mgmt_writedata(src_phy_mgmt_writedata),
      .phy_mgmt_waitrequest(src_phy_mgmt_waitrequest),
      //.reconfig_clk(mgmt_clk),
      .reconfig_busy(src_reconfig_busy),
      .reconfig_to_xcvr(src_reconfig_to_xcvr),
      .reconfig_from_xcvr(src_reconfig_from_xcvr)
   
     
   );


   seriallite_iii_streaming_sink #
   (
      .lanes(lanes),
      .adaptation_fifo_depth(lane_fifo_depth),
      .pll_ref_freq(pll_ref_freq),
      .data_rate(data_rate),
      .meta_frame_length(meta_frame_length),
      .reference_clock_frequency(reference_clock_frequency),
      .coreclkin_frequency(coreclkin_frequency),
      .user_clock_frequency(user_clock_frequency),
      .pll_type (pll_type),
      .ecc_enable (ecc_enable)
   )
   sink
   (
      .core_reset(mgmt_clk_reset),
      .data(snk_data),
      .end_of_burst(snk_end_of_burst),
      .error(snk_error),
      .xcvr_pll_ref_clk(snk_pll_ref_clk),
      .rx_serial_data(rx),
      .link_up(snk_link_up),
      .start_of_burst(snk_start_of_burst),
      .sync(snk_sync),
      .user_clock(snk_user_clock),
      .user_clock_reset(snk_user_clock_reset),
      .valid(snk_valid),
      .phy_mgmt_clk(mgmt_clk),
      .phy_mgmt_clk_reset(mgmt_clk_reset),
      .phy_mgmt_address(snk_phy_mgmt_address),
      .phy_mgmt_read(snk_phy_mgmt_read),
      .phy_mgmt_readdata(snk_phy_mgmt_readdata),
      .phy_mgmt_write(snk_phy_mgmt_write),
      .phy_mgmt_writedata(snk_phy_mgmt_writedata),
      .phy_mgmt_waitrequest(snk_phy_mgmt_waitrequest),
      .reconfig_busy(snk_reconfig_busy),
      .reconfig_to_xcvr(snk_reconfig_to_xcvr),
      .reconfig_from_xcvr(snk_reconfig_from_xcvr)
    );


   traffic_check #
   (
      .lanes(lanes)
   )
   traffic_check
   (
      // Clocks and reset
      .user_clock(snk_user_clock),
      .user_clock_reset(snk_user_clock_reset | snk_core_reset),

      // Streaming data interface
      .data(snk_data),
      .sync(snk_sync),
      .valid(snk_valid),
      .start_of_burst(snk_start_of_burst),
      .end_of_burst(snk_end_of_burst),

      // Test control ports
      .tc_enable(tg_enable),
      .tc_test_mode(tg_test_mode),
      .tc_enable_stalls(tg_enable_stalls),

      // Status ports
      .tc_burst_count(tc_burst_count),
      .tc_words_received(tc_words_transferred),
      .tc_lane_swap_error(tc_lane_swap_error),
      .tc_lane_sequence_error(tc_lane_sequence_error),
      .tc_lane_alignment_error(tc_lane_alignment_error)
   );


   demo_control  #(
      .lanes(lanes)
    )
 demo_control (
      // Clocks and reset
      .clk_clk(mgmt_clk),
      .reset_reset_n(mgmt_reset_n),

      // LCD Interface
      .lcd_data(lcd_data),
      .lcd_E(lcd_csn),
      .lcd_RS(lcd_d_cn),
      .lcd_RW(lcd_wen),

      // Source core Interlaken management interface
      .source_mgmt_address(src_phy_mgmt_address),
      .source_mgmt_write(src_phy_mgmt_write),
      .source_mgmt_read(src_phy_mgmt_read),
      .source_mgmt_readdata(src_phy_mgmt_readdata),
      .source_mgmt_writedata(src_phy_mgmt_writedata),
      .source_mgmt_waitrequest(src_phy_mgmt_waitrequest),

      // Source core transceiver reconfiguration interface
      .source_reconfig_to_xcvr_reconfig_to_xcvr(src_reconfig_to_xcvr),
      .source_reconfig_from_xcvr_reconfig_from_xcvr(src_reconfig_from_xcvr),
      .source_reconfig_busy_reconfig_busy(src_reconfig_busy),

      // Sink core Interlaken management interface
      .sink_mgmt_address(snk_phy_mgmt_address),
      .sink_mgmt_write(snk_phy_mgmt_write),
      .sink_mgmt_read(snk_phy_mgmt_read),
      .sink_mgmt_readdata(snk_phy_mgmt_readdata),
      .sink_mgmt_writedata(snk_phy_mgmt_writedata),
      .sink_mgmt_waitrequest(snk_phy_mgmt_waitrequest),

      // Sink core transceiver reconfiguration interface
      .sink_reconfig_busy_reconfig_busy(snk_reconfig_busy),
      .sink_reconfig_to_xcvr_reconfig_to_xcvr(snk_reconfig_to_xcvr),
      .sink_reconfig_from_xcvr_reconfig_from_xcvr(snk_reconfig_from_xcvr),

      // Demo management interface
      .demo_mgmt_address(demo_mgmt_address),
      .demo_mgmt_write(demo_mgmt_write),
      .demo_mgmt_read(demo_mgmt_read),
      .demo_mgmt_readdata(demo_mgmt_readdata),
      .demo_mgmt_writedata(demo_mgmt_writedata),
      .demo_mgmt_waitrequest(demo_mgmt_waitrequest),
		
      // synchronized reset to mgmt_clk
      .sync_reset_reset(mgmt_clk_reset)

    );

endmodule  // seriallite_iii_streaming_demo
