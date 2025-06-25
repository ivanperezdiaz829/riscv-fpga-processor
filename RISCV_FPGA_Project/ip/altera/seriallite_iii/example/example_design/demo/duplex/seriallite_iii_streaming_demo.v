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
   parameter                  adaptation_fifo_depth      = 32,  
   parameter                  pll_ref_freq               = "644.53125 MHz",
   parameter                  data_rate                  = "10312.5 Mbps",
   parameter                  meta_frame_length          = 200,
   parameter                  reference_clock_frequency  = "257.8125 MHz",
   parameter                  coreclkin_frequency        = "205.078125 MHz",
   parameter                 ecc_enable                 = 0,
   `ifdef ADVANCED_CLOCKING
   parameter                 mgmt_clock_frequency       = "100 MHz",
   parameter                 src_user_clock_frequency   = "145.984375 MHz"
   `else
   parameter                 user_clock_frequency       = "146.484375 MHz"
   `endif
   
)
(
   // System clocks and reset
   input                      mgmt_clk,
   input                      mgmt_reset_n,		

   input                      pll_ref_clk,

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


   //Enable when using CFP module	
   // CFP Status and Control 
  /*
   output         cfp_tx_dis,         //2.5V
   //output [4:0]   cfp_t_prtadr,       //2.5V  //1.2V tie to DIPSW on board instead
   inout          cfp_t_mdio,         //2.5V  //1.2V on module needs translater
   output         cfp_t_mdc,          //2.5V  //1.2V on module needs translater
   input          cfp_rx_los,         //2.5V
   output [3:1]   cfp_prg_cntl,       //2.5V
   input  [3:1]   cfp_prg_alrm,       //2.5V
   output         cfp_mod_rst,        //2.5V
   output         cfp_mod_lopwr,      //2.5V
   input          cfp_mod_abs,        //2.5V
   input          cfp_glb_alrm,      //2.5V
	
   // activity indicator
   output         cfp_rx_los_n,
  */   
   inout    [7:0]             lcd_data

);
   
   wire                       src_core_reset;
   wire                       src_user_clock;
   wire                       src_user_clock_reset;
   wire                       src_link_up;
   wire   [(lanes*64)-1:0]    src_data;
   wire   [3:0]               src_sync;
   `ifdef ADVANCED_CLOCKING
   wire   [3:0]               src_error;
   `else
   wire   [1:0]               src_error;
   `endif
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
   wire                       mgmt_clk_reset;
   
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
	
  `ifdef ADVANCED_CLOCKING
  wire    src_interface_clock_reset;
  wire    src_userclk_fpll_locked;
  
    // source user clock reset
   assign src_user_clock_reset = src_interface_clock_reset & src_userclk_fpll_locked;
	
  `endif

  //Enable if using CFP module	
  /*assign cfp_mod_rst   = 1'b1;
  assign cfp_tx_dis    = 1'b0;
  assign cfp_mod_lopwr = 1'b0;
  assign cfp_prg_cntl  = 3'b111;	

  assign cfp_rx_los_n = ~cfp_rx_los;
  */

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
      .link_up(src_link_up),

      // Test control ports
      .tg_enable(tg_enable),
      .tg_test_mode(tg_test_mode),
      .tg_enable_stalls(tg_enable_stalls),

      // Status interface
      .tg_burst_count(tg_burst_count),
      .tg_words_transferred(tg_words_transferred)
   );

   seriallite_iii_streaming #
   (
   .lanes                      (lanes), 
   .adaptation_fifo_depth      (adaptation_fifo_depth),
   .pll_ref_freq               (pll_ref_freq),
   .data_rate                  (data_rate),
   .meta_frame_length          (meta_frame_length),
  `ifndef ADVANCED_CLOCKING
   .reference_clock_frequency  (reference_clock_frequency),
   .coreclkin_frequency        (coreclkin_frequency),
   .user_clock_frequency       (user_clock_frequency),
   `endif
   .pll_type                   (pll_type),
   .ecc_enable                 (ecc_enable)
   )
	seriallite_iii_streaming
  (
   // Clocks and reset
   .core_reset                (mgmt_clk_reset),
   .user_clock_reset_tx       (src_user_clock_reset),
   .user_clock_tx             (src_user_clock),
   `ifdef ADVANCED_CLOCKING	   
   .interface_clock_reset_tx  (src_interface_clock_reset),
   .interface_clock_reset_rx  (snk_user_clock_reset),
   .interface_clock_rx        (snk_user_clock),
   `else
   .user_clock_reset_rx       (snk_user_clock_reset),
   .user_clock_rx             (snk_user_clock),
   `endif

   // Source User Interface
   .data_tx                   (src_data),
   .sync_tx                   (src_sync),
   .valid_tx                  (src_valid),
   .start_of_burst_tx         (src_start_of_burst),
   .end_of_burst_tx           (src_end_of_burst),
   .link_up_tx                (src_link_up),
   `ifdef ADVANCED_CLOCKING
   .error_tx                  (src_error),
   `else
   .error_tx                  (src_error),
   `endif
   .crc_error_inject          ({lanes{crc_error_inject}}),

   // Sink User Interface
   .data_rx                   (snk_data),
   .sync_rx                   (snk_sync),
   .valid_rx                  (snk_valid),
   .start_of_burst_rx         (snk_start_of_burst),
   .end_of_burst_rx           (snk_end_of_burst),
   .link_up_rx                (snk_link_up),
   .error_rx                  (snk_error),


   // Interlaken PHY IP management interface
   .phy_mgmt_clk              (mgmt_clk),
   .phy_mgmt_clk_reset        (mgmt_clk_reset),   // externally synchronized phy_mgmt_clk_reset
   .phy_mgmt_address          (src_phy_mgmt_address),
   .phy_mgmt_read             (src_phy_mgmt_read),
   .phy_mgmt_readdata         (src_phy_mgmt_readdata),
   .phy_mgmt_write            (src_phy_mgmt_write),
   .phy_mgmt_writedata        (src_phy_mgmt_writedata),
   .phy_mgmt_waitrequest      (src_phy_mgmt_waitrequest),

   // Transceiver clock and data
   .xcvr_pll_ref_clk          (pll_ref_clk),
   .tx_serial_data            (tx),
   .rx_serial_data            (rx),

   // Transceiver reconfiguration interface
   .reconfig_busy             (src_reconfig_busy),
   .reconfig_to_xcvr          (src_reconfig_to_xcvr),
   .reconfig_from_xcvr        (src_reconfig_from_xcvr)
	
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
      .tc_enable(tc_enable),
      .tc_test_mode(tg_test_mode),
      .tc_enable_stalls(tg_enable_stalls),

      // Status ports
      .tc_burst_count(tc_burst_count),
      .tc_words_received(tc_words_transferred),
      .tc_lane_swap_error(tc_lane_swap_error),
      .tc_lane_sequence_error(tc_lane_sequence_error),
      .tc_lane_alignment_error(tc_lane_alignment_error)
   );


   demo_control #
   (
      .lanes(lanes)
   )
   demo_control
   (
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
      .sync_reset_reset (mgmt_clk_reset)
   );
   
   `ifdef ADVANCED_CLOCKING
   // Source user clock generator
   altera_pll #
   (
      .fractional_vco_multiplier("true"),
      .reference_clock_frequency(mgmt_clock_frequency),
      .operation_mode("normal"),
      .number_of_clocks(1),
      .output_clock_frequency0(src_user_clock_frequency),
      .phase_shift0("0 ps"),
      .duty_cycle0(50),
      .pll_type("General"),
      .pll_subtype("General")
   )
   src_user_clock_pll
   (
      .outclk(src_user_clock),
      .locked(src_userclk_fpll_locked),
      .fboutclk( ),
      .fbclk(1'b0),
      .rst(mgmt_clk_reset),
      .refclk(mgmt_clk)
   );
   `endif
   

endmodule  // seriallite_iii_streaming_demo
