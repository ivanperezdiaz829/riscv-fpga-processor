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



// streaming source with advanced (ppm absorbtion) user clocking


`timescale 1 ps / 1 ps 

module seriallite_iii_streaming_source #
(
   parameter                     lanes                      = 4,
   parameter                     adaptation_fifo_depth      = 32,
   parameter                     pll_ref_freq               = "103.125 MHz",
   parameter                     data_rate                  = "10312.5 Mbps",
   parameter                     meta_frame_length          = 8191,
   parameter                     pll_type                   = "CMU",
   parameter                     ecc_enable                 = 0
)
(
   // Clocks and reset
   input                         core_reset,
   input                         user_clock_reset,
   input                         user_clock,
   output                        interface_clock_reset,

   // Source User Interface
   input       [(lanes*64)-1:0]  data,
   input       [3:0]             sync,
   input                         valid,
   input                         start_of_burst,
   input                         end_of_burst,
   output                        link_up,
   output      [3:0]             error,
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
	
	
);


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
	
	
   wire       [(lanes*64)-1:0]	adpt_data;
   wire       [3:0]		adpt_sync;
   wire 			adpt_valid;
   wire 			adpt_start_of_burst;
   wire 			adpt_end_of_burst;
   wire                         si_read_en;
   wire                         user_interface_clock;
   wire                         user_interface_clock_reset;
   wire  [1:0]                err;
   wire  [1:0]                uncor;

   
   assign   error [3:2] = {|err, |uncor} ;
   

   assign user_interface_clock                 = tx_clkout[0];	
   assign tx_coreclkin                         = tx_clkout[0] ;
   assign user_interface_clock_reset           = ~xcvr_pll_locked;
   assign interface_clock_reset                = user_interface_clock_reset;
   
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
      .lanes                      (lanes),
      .pll_ref_freq               (pll_ref_freq),
      .data_rate                  (data_rate),
      .meta_frame_length          (meta_frame_length),
      .pll_type(pll_type)
   )
   interlaken_phy_ip_tx
   (
      .phy_mgmt_address           (phy_mgmt_address),
      .phy_mgmt_clk               (phy_mgmt_clk),
      .phy_mgmt_clk_reset         (phy_mgmt_clk_reset),
      .phy_mgmt_read              (phy_mgmt_read),
      .phy_mgmt_readdata          (phy_mgmt_readdata),
      .phy_mgmt_waitrequest       (phy_mgmt_waitrequest),
      .phy_mgmt_write             (phy_mgmt_write),
      .phy_mgmt_writedata         (phy_mgmt_writedata),
      .pll_locked                 (xcvr_pll_locked),
      .pll_ref_clk                (xcvr_pll_ref_clk),
      .reconfig_from_xcvr         (reconfig_from_xcvr),
      .reconfig_to_xcvr           (reconfig_to_xcvr),
      .tx_clkout                  (tx_clkout),
      .tx_coreclkin               (tx_coreclkin),
      .tx_datain_bp               (tx_datain_bp),
      .tx_datavalid               (tx_datavalid),
      .tx_ctrlin                  (tx_ctrlin),
      .tx_crcerr                  ({lanes{crc_error_inject}}),
      .tx_parallel_data           (tx_parallel_data),
      .tx_ready                   (tx_ready),
      .tx_serial_data             (tx_serial_data),
      .tx_sync_done               (tx_sync_done)
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
      .core_reset                  (core_reset),
      .fi_ctrl                     (fi_ctrl),
      .fi_data                     (fi_data),
      .fi_ready                    (fi_ready),
      .fi_up                       (fi_up),
      .fi_valid                    (fi_valid),
      .adaptation_fifo_overflow    (error[0]),
      .tx_coreclkin                (tx_coreclkin),
      .tx_datain_bp                (tx_datain_bp),
      .tx_datavalid                (tx_datavalid),
      .tx_ctrlin                   (tx_ctrlin),
      .tx_parallel_data            (tx_parallel_data),
      .tx_ready                    (tx_ready),
      .tx_sync_done                (tx_sync_done),
      .user_clock                  (user_interface_clock),
      .user_clock_reset            (user_interface_clock_reset),
      .ecc_status ({err[0],uncor[0]})
   );


   source_application #
   (
      .lanes(lanes)
   )
   source_application
   (
      .fi_ctrl                      (fi_ctrl),
      .fi_data                      (fi_data),
      .fi_ready                     (fi_ready),
      .fi_up                        (fi_up),
      .fi_valid                     (fi_valid),
      .si_data                      (adpt_data),
      .si_end_of_burst              (adpt_end_of_burst),
      .si_start_of_burst            (adpt_start_of_burst),
      .si_sync                      (adpt_sync),
      .si_valid                     (adpt_valid),
      .si_up                        (link_up),
      .si_read_en                   (si_read_en),
      .user_clock                   (user_interface_clock),
      .user_clock_reset             (user_interface_clock_reset)
   );

   // source ppm absorption module instantiation
   source_absorber #
   (
	.lanes						       (lanes),
        .ecc_enable                                            (ecc_enable)
   )
   source_ppm_absorption
   (
	// Clocks and reset
	.user_clock		    (user_clock),
	.user_clock_reset           (user_clock_reset),
	.interface_clock            (user_interface_clock),
	.interface_reset            (user_interface_clock_reset),
		
	// Streaming data interface
	.si_data                    (data),
	.si_sync                    (sync),	
	.si_valid                   (valid),
	.si_start_of_burst          (start_of_burst),
	.si_end_of_burst            (end_of_burst),
	.read_en                    (si_read_en),
		
	// Adaptation Interface
	.adpt_data                  (adpt_data),
	.adpt_sync                  (adpt_sync),
	.adpt_valid                 (adpt_valid),
	.adpt_start_of_burst        (adpt_start_of_burst),
	.adpt_end_of_burst          (adpt_end_of_burst),
			
	// status signals
	.absorber_fifo_overflow     (error[1]),
        .ecc_status                 ({err[1],uncor[1]})
   
   );
	 

endmodule  // seriallite_iii_streaming_source
