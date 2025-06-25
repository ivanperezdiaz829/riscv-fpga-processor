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

module seriallite_iii_streaming_source #
(
   parameter                     lanes                      = 4,
   parameter                     adaptation_fifo_depth      = 32,
   parameter                     pll_ref_freq               = "103.125 MHz",
   parameter                     data_rate                  = "10312.5 Mbps",
   parameter                     meta_frame_length          = 8191,
   parameter                     reference_clock_frequency  = "257.8125 MHz",
   parameter                     coreclkin_frequency        = "153.918 MHz",
   parameter                     user_clock_frequency       = "138.526 MHz",
   parameter                     pll_type                   = "CMU",
   parameter                     ecc_enable                 = 0
)
(
   // Clocks and reset
   input                         core_reset,
   output                        user_clock_reset,
   output                        user_clock,

   // Source User Interface
   input       [(lanes*64)-1:0]  data,
   input       [3:0]             sync,
   input                         valid,
   input                         start_of_burst,
   input                         end_of_burst,
   output                        link_up,
   output      [2:0]             error,
   input                         crc_error_inject,

   // Interlaken PHY IP management interface
   input                         phy_mgmt_clk,
   input                         phy_mgmt_clk_reset,   // externally synchronized phy_mgmt_clk_reset
   input       [8:0]             phy_mgmt_address,
   input                         phy_mgmt_read,
   output      [31:0]            phy_mgmt_readdata,
   input                         phy_mgmt_write,
   input       [31:0]            phy_mgmt_writedata,
   output                        phy_mgmt_waitrequest,

   // Transceiver clock and data
   input                         xcvr_pll_ref_clk,
   output      [lanes-1:0]       tx_serial_data,

   // Transceiver reconfiguration interface
   input                         reconfig_busy,
   input       [(lanes*140)-1:0] reconfig_to_xcvr,
   output      [(lanes*92)-1:0]  reconfig_from_xcvr
	
	// debug
//	output  [7:0]						debug_bus
);


   wire                          sync_phy_mgmt_clk_reset;

   wire                          reconfig_clk_reset;

   wire                          xcvr_pll_locked;
   wire        [lanes-1:0]       tx_datain_bp;
   wire        [lanes-1:0]       tx_clkout;
   wire                          tx_coreclkin;
   wire                          tx_ready;
   wire                          tx_sync_done;

   wire        [lanes-1:0]       tx_datavalid;
   wire        [lanes-1:0]       tx_ctrlin;
   wire        [(lanes*64)-1:0]  tx_parallel_data;

   wire                          fi_valid;
   wire                          fi_ready;
   wire        [lanes-1:0]       fi_ctrl;
   wire        [(lanes*64)-1:0]  fi_data;
   wire                          fi_up;
   wire  [0:0]                err;
   wire  [0:0]                uncor;

  /*assign debug_bus[0] = tx_clkout[0];
   assign debug_bus[1] = tx_clkout[1];
   assign debug_bus[2] = tx_coreclkin;
   */
   assign   error [2:1] = {|err, |uncor} ;
   //
   // Management reset synchronizer
   // Enable and employ synch_phy_mgmt_clk_reset
	// if phy_mgmt_clk_reset is not externally synchronized
   /*  
	wire                       sync_phy_mgmt_clk_reset;
	dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   phy_mgmt_clk_reset_sync
   (
      .async_reset_n(~phy_mgmt_clk_reset),
      .sync_reset_n(1'b1),
      .clk(phy_mgmt_clk),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(sync_phy_mgmt_clk_reset)
   );*/

	//
   // Reconfig reset synchronizer
   //
   dp_sync #
   (
      .dp_width(1),
      .dp_reset(1'b1)
   )
   reconfig_clk_reset_sync
   (
      .async_reset_n(~core_reset),
      .sync_reset_n(1'b1),
      .clk(phy_mgmt_clk),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(reconfig_clk_reset)
   );



   interlaken_phy_ip_tx #
   (
      .lanes(lanes),
      .pll_ref_freq(pll_ref_freq),
      .data_rate(data_rate),
      .meta_frame_length(meta_frame_length),
      .pll_type(pll_type)
   )
   interlaken_phy_ip_tx
   (
      .phy_mgmt_address(phy_mgmt_address),
      .phy_mgmt_clk(phy_mgmt_clk),
      .phy_mgmt_clk_reset(phy_mgmt_clk_reset),
      .phy_mgmt_read(phy_mgmt_read),
      .phy_mgmt_readdata(phy_mgmt_readdata),
      .phy_mgmt_waitrequest(phy_mgmt_waitrequest),
      .phy_mgmt_write(phy_mgmt_write),
      .phy_mgmt_writedata(phy_mgmt_writedata),
      .pll_locked(xcvr_pll_locked),
      .pll_ref_clk(xcvr_pll_ref_clk),
      .reconfig_from_xcvr(reconfig_from_xcvr),
      .reconfig_to_xcvr(reconfig_to_xcvr),
      .tx_clkout(tx_clkout),
      .tx_coreclkin(tx_coreclkin),
      .tx_datain_bp(tx_datain_bp),
      .tx_datavalid(tx_datavalid),
      .tx_ctrlin(tx_ctrlin),
      .tx_crcerr({lanes{crc_error_inject}}),
      .tx_parallel_data(tx_parallel_data),
      .tx_ready(tx_ready),
      .tx_serial_data(tx_serial_data),
      .tx_sync_done(tx_sync_done)
   );


   source_adaptation #
   (
      .lanes(lanes),
      .adaptation_fifo_depth(adaptation_fifo_depth),
      .ecc_enable(ecc_enable),
      .meta_frame_length(meta_frame_length)      
   )
   source_adaptation
   (
      .core_reset(core_reset),
      .fi_ctrl(fi_ctrl),
      .fi_data(fi_data),
      .fi_ready(fi_ready),
      .fi_up(fi_up),
      .fi_valid(fi_valid),
      .adaptation_fifo_overflow(error[0]),
      .tx_coreclkin(tx_coreclkin),
      .tx_datain_bp(tx_datain_bp),
      .tx_datavalid(tx_datavalid),
      .tx_ctrlin(tx_ctrlin),
      .tx_parallel_data(tx_parallel_data),
      .tx_ready(tx_ready),
      .tx_sync_done(tx_sync_done),
      .user_clock(user_clock),
      .user_clock_reset(user_clock_reset),
      .ecc_status ({err[0],uncor[0]})
   );


   source_application #
   (
      .lanes(lanes)
   )
   source_application
   (
      .fi_ctrl(fi_ctrl),
      .fi_data(fi_data),
      .fi_ready(fi_ready),
      .fi_up(fi_up),
      .fi_valid(fi_valid),
      .si_data(data),
      .si_end_of_burst(end_of_burst),
      .si_start_of_burst(start_of_burst),
      .si_sync(sync),
      .si_valid(valid),
      .si_up(link_up),
      .user_clock(user_clock),
      .user_clock_reset(user_clock_reset)
   );


   source_clock_gen #
   (
      .lanes(lanes),
      .reference_clock_frequency(reference_clock_frequency),
      .tx_coreclkin_frequency(coreclkin_frequency),
      .user_clock_frequency(user_clock_frequency)
   )
   source_clock_gen
   (
      .xcvr_pll_locked(xcvr_pll_locked),
      .reconfig_clk(phy_mgmt_clk),
      .reconfig_clk_reset(reconfig_clk_reset),  
      .reconfig_busy(reconfig_busy),
      .tx_clkout(tx_clkout),
      .tx_coreclkin(tx_coreclkin),
      .user_clock(user_clock),
      .user_clock_reset(user_clock_reset)
   );


endmodule  // seriallite_iii_streaming_source
