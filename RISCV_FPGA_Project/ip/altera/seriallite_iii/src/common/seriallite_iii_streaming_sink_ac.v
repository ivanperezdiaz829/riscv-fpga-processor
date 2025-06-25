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

module seriallite_iii_streaming_sink #
(
   parameter                  lanes                      = 4,
   parameter                  adaptation_fifo_depth      = 32,
   parameter                  pll_ref_freq               = "103.125 MHz",
   parameter                  data_rate                  = "10312.5 Mbps",
   parameter                  meta_frame_length          = 8191,
   parameter                     pll_type                   = "CMU",
   parameter                     ecc_enable                 = 0
)
(
   // Clocks and reset
   input                      core_reset/* synthesis altera_attribute="disable_da_rule=r102" */,
   output                     interface_clock,
   output                     interface_clock_reset,

   // Sink User Interface
   output   [(lanes*64)-1:0]  data,
   output   [3:0]             sync,
   output                     valid,
   output                     start_of_burst,
   output                     end_of_burst,
   output                     link_up,
   output   [(lanes+5)-1:0]   error,

   // Interlaken PHY IP management interface
   input                      phy_mgmt_clk,
   input                      phy_mgmt_clk_reset,		// externally synchronized phy_mgmt_clk_reset
   input    [8:0]             phy_mgmt_address,
   input                      phy_mgmt_read,
   output   [31:0]            phy_mgmt_readdata,
   input                      phy_mgmt_write,
   input    [31:0]            phy_mgmt_writedata,
   output                     phy_mgmt_waitrequest,

   // Transceiver clock and data
   input                      xcvr_pll_ref_clk,
   input    [lanes-1:0]       rx_serial_data,

   // Transceiver reconfiguration interface
   input                      reconfig_busy,
   input    [(lanes*70)-1:0]  reconfig_to_xcvr,
   output   [(lanes*46)-1:0]  reconfig_from_xcvr
	
);

  

   wire   [lanes-1:0]         rx_datavalid;
   wire   [lanes-1:0]         rx_crc32err; 
   wire   [lanes-1:0]         rx_frame_lock;
   wire   [lanes-1:0]         rx_align_val;
   wire   [lanes-1:0]         rx_ctrlout;
   wire   [lanes-1:0]         rx_fifofull;
   wire   [lanes-1:0]         rx_fifopfull;
   wire   [lanes-1:0]         rx_fifopempty;
   wire   [lanes-1:0]         rx_block_frame_lock;
   wire   [(lanes*64)-1:0]    rx_parallel_data;
   wire   [lanes-1:0]         rx_dataout_bp;
   wire   [lanes-1:0]         rx_fifo_clr;
   wire   [lanes-1:0]         rx_clkout;
   wire                       rx_coreclkin;
   wire                       rx_ready;

   wire   [(lanes*64)-1:0]    fi_data;
   wire   [lanes-1:0]         fi_ctrl;
   wire                       fi_valid;
   wire                       fi_ready;
   wire                       fi_up;

   wire                       user_interface_clock;
   wire                       user_interface_clock_reset;


   // Interface Reset Synchronizer
    dp_sync #
    (
      .dp_width(1),
      .dp_reset(1'b1)
    )
    interface_clk_reset_sync
    (
      .async_reset_n(rx_ready),
      .sync_reset_n(1'b1),
      .clk(user_interface_clock),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(interface_clock_reset)
    );

   
   assign user_interface_clock_reset           = interface_clock_reset ;
   assign user_interface_clock                 = rx_clkout[0];
   assign rx_coreclkin                         = rx_clkout[0] ;	
   assign interface_clock                      = user_interface_clock;
   
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
   
   //
   // Interlaken PHY IP
   //
   interlaken_phy_ip_rx #
   (
      .lanes                (lanes),
      .pll_ref_freq         (pll_ref_freq),
      .data_rate            (data_rate),
      .meta_frame_length    (meta_frame_length),
      .pll_type             (pll_type)
   )
   interlaken_phy_ip_rx
   (
      .phy_mgmt_address     (phy_mgmt_address),
      .phy_mgmt_clk         (phy_mgmt_clk),      
      .phy_mgmt_clk_reset   (phy_mgmt_clk_reset),
      .phy_mgmt_read        (phy_mgmt_read),
      .phy_mgmt_readdata    (phy_mgmt_readdata),
      .phy_mgmt_waitrequest (phy_mgmt_waitrequest),
      .phy_mgmt_write       (phy_mgmt_write),
      .phy_mgmt_writedata   (phy_mgmt_writedata),
      .pll_ref_clk          (xcvr_pll_ref_clk),
      .reconfig_from_xcvr   (reconfig_from_xcvr),
      .reconfig_to_xcvr     (reconfig_to_xcvr),
      .rx_clkout            (rx_clkout),
      .rx_coreclkin         (rx_coreclkin),
      .rx_dataout_bp        (rx_dataout_bp),
      .rx_fifo_clr          (rx_fifo_clr),
      .rx_datavalid         (rx_datavalid),
      .rx_crc32err          (rx_crc32err), 
      .rx_frame_lock        (rx_frame_lock),
      .rx_align_val         (rx_align_val),
      .rx_ctrlout           (rx_ctrlout),
      .rx_fifofull          (rx_fifofull),
      .rx_fifopfull         (rx_fifopfull),
      .rx_fifopempty        (rx_fifopempty),
      .rx_block_frame_lock  (rx_block_frame_lock),
      .rx_parallel_data     (rx_parallel_data),
      .rx_ready             (rx_ready),
      .rx_serial_data       (rx_serial_data)
   );

   //
   // Alignmnet Module
   //
   sink_alignment #
   (
      .lanes(lanes)
   )
   sink_alignment
   (
      .clock               (rx_coreclkin),
      .reset               (core_reset),

      .rx_read             (rx_dataout_bp),
      .rx_fifo_clr         (rx_fifo_clr),
      .rx_aligned          (rx_aligned),

      .rx_datavalid        (rx_datavalid),
      .rx_crc32err         (rx_crc32err), 
      .rx_frame_lock       (rx_frame_lock),
      .rx_align_val        (rx_align_val),
      .rx_ctrlout          (rx_ctrlout),
      .rx_fifofull         (rx_fifofull),
      .rx_fifopfull        (rx_fifopfull),
      .rx_fifopempty       (rx_fifopempty),
      .rx_block_frame_lock (rx_block_frame_lock),
      .rx_parallel_data    (rx_parallel_data),
      .rx_ready            (rx_ready)
   );



   //
   // Adaptation Module
   //
   sink_adaptation #
   (
      .lanes                 (lanes),
      .adaptation_fifo_depth(adaptation_fifo_depth),
      .ecc_enable   (ecc_enable)
   )
   sink_adaptation
   (
      .error(error[(lanes+3)-1:0]),
      .fi_ctrl               (fi_ctrl),
      .fi_data               (fi_data),
      .fi_ready              (fi_ready),
      .fi_up                 (fi_up),
      .fi_valid              (fi_valid),
      .core_reset            (core_reset),
      .rx_coreclkin          (rx_coreclkin),
      .rx_datavalid          (rx_datavalid),
      .rx_crc32err           (rx_crc32err), 
      .rx_ctrlout            (rx_ctrlout),
      .rx_parallel_data      (rx_parallel_data),
      .rx_aligned            (rx_aligned),
      .user_clock            (user_interface_clock),
      .user_clock_reset      (user_interface_clock_reset),
      .ecc_status (error[(lanes+5)-1:lanes+3])
   );


   //
   // Application Module
   //
   sink_application #
   (
      .lanes(lanes)
   )
   sink_application
   (
      .fi_ctrl               (fi_ctrl),
      .fi_data               (fi_data),
      .fi_ready              (fi_ready),
      .fi_up                 (fi_up),
      .fi_valid              (fi_valid),
      .data                  (data),
      .end_of_burst          (end_of_burst),
      .start_of_burst        (start_of_burst),
      .sync                  (sync),
      .valid                 (valid),
      .link_up               (link_up),
      .user_clock            (user_interface_clock),
      .user_clock_reset      (user_interface_clock_reset)
   );


endmodule  // seriallite_iii_streaming_sink
