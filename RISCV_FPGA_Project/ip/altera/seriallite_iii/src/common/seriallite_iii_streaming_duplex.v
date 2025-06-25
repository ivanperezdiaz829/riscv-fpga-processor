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

module seriallite_iii_streaming #
(
   parameter                     lanes                      = 4,
   parameter                     adaptation_fifo_depth      = 32,
   parameter                     pll_ref_freq               = "103.125 MHz",
   parameter                     data_rate                  = "10312.5 Mbps",
   parameter                     meta_frame_length          = 8191,
  `ifndef ADVANCED_CLOCKING
   parameter                     reference_clock_frequency  = "257.8125 MHz",
   parameter                     coreclkin_frequency        = "153.918 MHz",
   parameter                     user_clock_frequency       = "138.526 MHz",
   `endif
   parameter                     pll_type                   = "CMU",
   parameter                     ecc_enable                 = 0
)
(
   // Clocks and reset
   input                         core_reset /* synthesis altera_attribute="disable_da_rule=r102" */,
   `ifdef ADVANCED_CLOCKING
   input                         user_clock_reset_tx,
   input                         user_clock_tx,	
   output                        interface_clock_reset_tx,
   output                        interface_clock_reset_rx,
   output                        interface_clock_rx,
   `else
   output                        user_clock_reset_tx,
   output                        user_clock_tx,
   output                        user_clock_reset_rx,
   output                        user_clock_rx,
   `endif

   // Source User Interface
   input       [(lanes*64)-1:0]  data_tx,
   input       [3:0]             sync_tx,
   input                         valid_tx,
   input                         start_of_burst_tx,
   input                         end_of_burst_tx,
   output                        link_up_tx,
   `ifdef ADVANCED_CLOCKING
   output      [3:0]             error_tx,
   `else
   output      [2:0]             error_tx,
   `endif
   input                         crc_error_inject,


   // Sink User Interface
   output   [(lanes*64)-1:0]  data_rx,
   output   [3:0]             sync_rx,
   output                     valid_rx,
   output                     start_of_burst_rx,
   output                     end_of_burst_rx,
   output                     link_up_rx,
   output   [(lanes+5)-1:0]   error_rx,


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
   input    [lanes-1:0]          rx_serial_data,

   // Transceiver reconfiguration interface
   input                         reconfig_busy,
   input       [(lanes*140)-1:0] reconfig_to_xcvr,
   output      [(lanes*92)-1:0]  reconfig_from_xcvr
	
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

   wire                          fi_valid_tx;
   wire                          fi_ready_tx;
   wire        [lanes-1:0]       fi_ctrl_tx;
   wire        [(lanes*64)-1:0]  fi_data_tx;
   wire                          fi_up_tx;



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
   wire                       rx_aligned;

   wire   [(lanes*64)-1:0]    fi_data_rx;
   wire   [lanes-1:0]         fi_ctrl_rx;
   wire                       fi_valid_rx;
   wire                       fi_ready_rx;
   wire                       fi_up_rx;


   wire                       user_interface_clock;
   wire                       user_interface_clock_reset_tx;
   wire                       user_interface_clock_reset_rx;
   `ifdef ADVANCED_CLOCKING
   wire   [(lanes*64)-1:0]    app_data;
   wire   [3:0]               app_sync;
   wire                       app_valid;
   wire 		      app_start_of_burst;
   wire 		      app_end_of_burst;
   wire                       app_read_en;
   wire  [1:0]                err;
   wire  [1:0]                uncor;
   `else
   wire                       rx_clkout_buf;
   wire  [0:0]                err;
   wire  [0:0]                uncor;
   `endif

   
   `ifdef ADVANCED_CLOCKING
   assign   error_tx [3:2] = {|err, |uncor} ;
   `else
   assign   error_tx [2:1] = {|err, |uncor} ;
   `endif


   //
   // Clocking and reset assignments
   //
   wire                      user_interface_clock_tx;
   wire                      user_interface_clock_rx;
	
   `ifdef ADVANCED_CLOCKING
    
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
      .clk(user_interface_clock_rx),
      .sync_ctrl(2'd2),
      .d(1'b0),
      .o(interface_clock_reset_rx)
    );
 
    assign interface_clock_rx                  = rx_clkout[0];
    assign interface_clock_reset_tx            = ~xcvr_pll_locked;
    assign user_interface_clock_tx              = tx_clkout[0];	
    assign user_interface_clock_rx              = rx_clkout[0];
    assign tx_coreclkin                         = tx_clkout[0] ;
    assign rx_coreclkin                         = rx_clkout[0] ;	
    assign user_interface_clock_reset_tx        = ~xcvr_pll_locked;
    assign user_interface_clock_reset_rx        = interface_clock_reset_rx ; 
 
    `else

    assign user_clock_tx                          = user_interface_clock_tx;
    assign user_clock_reset_tx                    = user_interface_clock_reset_tx;
    assign user_clock_rx                          = user_interface_clock_rx;
    assign user_clock_reset_rx                    = user_interface_clock_reset_rx;

   `endif
 

	
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



   interlaken_phy_ip_duplex #
   (
      .lanes(lanes),
      .pll_ref_freq(pll_ref_freq),
      .data_rate(data_rate),
      .meta_frame_length(meta_frame_length),
      .pll_type(pll_type)
   )
   interlaken_phy_ip_duplex
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
      .tx_sync_done(tx_sync_done),
     
      .rx_clkout(rx_clkout),
      .rx_coreclkin(rx_coreclkin),
      .rx_dataout_bp(rx_dataout_bp),
      .rx_fifo_clr(rx_fifo_clr),
      .rx_datavalid(rx_datavalid),
      .rx_crc32err(rx_crc32err), 
      .rx_frame_lock(rx_frame_lock),
      .rx_align_val(rx_align_val),
      .rx_ctrlout(rx_ctrlout),
      .rx_fifofull(rx_fifofull),
      .rx_fifopfull(rx_fifopfull),
      .rx_fifopempty(rx_fifopempty),
      .rx_block_frame_lock(rx_block_frame_lock),
      .rx_parallel_data(rx_parallel_data),
      .rx_ready(rx_ready),
      .rx_serial_data(rx_serial_data)

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
      .fi_ctrl(fi_ctrl_tx),
      .fi_data(fi_data_tx),
      .fi_ready(fi_ready_tx),
      .fi_up(fi_up_tx),
      .fi_valid(fi_valid_tx),
   `ifdef ADVANCED_CLOCKING
      .adaptation_fifo_overflow(error_tx[0]),
   `else
      .adaptation_fifo_overflow(error_tx),
   `endif
      .tx_coreclkin(tx_coreclkin),
      .tx_datain_bp(tx_datain_bp),
      .tx_datavalid(tx_datavalid),
      .tx_ctrlin(tx_ctrlin),
      .tx_parallel_data(tx_parallel_data),
      .tx_ready(tx_ready),
      .tx_sync_done(tx_sync_done),
      .user_clock(user_interface_clock_tx),
      .user_clock_reset(user_interface_clock_reset_tx),
      .ecc_status ({err[0],uncor[0]})
   );


  
  `ifdef ADVANCED_CLOCKING
   
   source_application #
   (
      .lanes(lanes)
   )
   source_application
   (
      .fi_ctrl            (fi_ctrl_tx),
      .fi_data            (fi_data_tx),
      .fi_ready           (fi_ready_tx),
      .fi_up              (fi_up_tx),
      .fi_valid           (fi_valid_tx),
      .si_data            (app_data),
      .si_end_of_burst    (app_end_of_burst),
      .si_start_of_burst  (app_start_of_burst),
      .si_sync            (app_sync),
      .si_valid           (app_valid),
      .si_up              (link_up_tx),
      .si_read_en         (app_read_en),
      .user_clock         (user_interface_clock_tx),
      .user_clock_reset   (user_interface_clock_reset_tx)
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
	.user_clock						(user_clock_tx),
	.user_clock_reset					(user_clock_reset_tx),
	.interface_clock					(user_interface_clock_tx),
	.interface_reset					(user_interface_clock_reset),
		
	// Streaming data interface
	.si_data						(data_tx),
	.si_sync						(sync_tx),	
	.si_valid						(valid_tx),
	.si_start_of_burst					(start_of_burst_tx),
	.si_end_of_burst					(end_of_burst_tx),
		
	// Application Interface
	.read_en						(app_read_en),
	.adpt_data						(app_data),
	.adpt_sync						(app_sync),
	.adpt_valid						(app_valid),
	.adpt_start_of_burst					(app_start_of_burst),
	.adpt_end_of_burst					(app_end_of_burst),
			
	// status signals
	.absorber_fifo_overflow				        (error_tx[1]),
        .ecc_status                                             ({err[1],uncor[1]})
   
   );
  `else
  
   source_application #
   (
      .lanes(lanes)
   )
   source_application
   (
      .fi_ctrl(fi_ctrl_tx),
      .fi_data(fi_data_tx),
      .fi_ready(fi_ready_tx),
      .fi_up(fi_up_tx),
      .fi_valid(fi_valid_tx),
      .si_data(data_tx),
      .si_end_of_burst(end_of_burst_tx),
      .si_start_of_burst(start_of_burst_tx),
      .si_sync(sync_tx),
      .si_valid(valid_tx),
      .si_up(link_up_tx),
      .user_clock(user_interface_clock_tx),
      .user_clock_reset(user_interface_clock_reset_tx)
   );

  `endif

`ifndef ADVANCED_CLOCKING
   //
   // Clock and reset generator for source
   //
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

      .user_clock(user_interface_clock_tx),
      .user_clock_reset(user_interface_clock_reset_tx)

   );

   //
   // Clock and reset generator for sink
   //
   sink_clock_gen #
   (
      .lanes(lanes),
      .reference_clock_frequency(reference_clock_frequency),
      .rx_coreclkin_frequency(coreclkin_frequency),
      .user_clock_frequency(user_clock_frequency)
   )
   sink_clock_gen
   (
      .xcvr_pll_locked(rx_ready),
      .reconfig_clk(phy_mgmt_clk),
      .reconfig_clk_reset(reconfig_clk_reset),
      .reconfig_busy(reconfig_busy),
      .rx_clkout(rx_clkout_buf),
      .rx_coreclkin(rx_coreclkin),
      .user_clock(user_interface_clock_rx),
      .user_clock_reset(user_interface_clock_reset_rx)
   );

 
  clkctrl clkctrl_inst
  (
  .inclk 		(rx_clkout),
  .outclk 		(rx_clkout_buf)  
  );

`endif

  //
   // Alignmnet Module
   //
   sink_alignment #
   (
      .lanes(lanes)
   )
   sink_alignment
   (
      .clock(rx_coreclkin),
      .reset(core_reset),

      .rx_read(rx_dataout_bp),
      .rx_fifo_clr(rx_fifo_clr),
      .rx_aligned(rx_aligned),

      .rx_datavalid(rx_datavalid),
      .rx_crc32err(rx_crc32err), 
      .rx_frame_lock(rx_frame_lock),
      .rx_align_val(rx_align_val),
      .rx_ctrlout(rx_ctrlout),
      .rx_fifofull(rx_fifofull),
      .rx_fifopfull(rx_fifopfull),
      .rx_fifopempty(rx_fifopempty),
      .rx_block_frame_lock(rx_block_frame_lock),
      .rx_parallel_data(rx_parallel_data),
      .rx_ready(rx_ready)
   );



   //
   // Adaptation Module
   //
   sink_adaptation #
   (
      .lanes(lanes),
      .adaptation_fifo_depth(adaptation_fifo_depth),
      .ecc_enable   (ecc_enable)
   )
   sink_adaptation
   (
      .error(error_rx[(lanes+3)-1:0]),
      .fi_ctrl(fi_ctrl_rx),
      .fi_data(fi_data_rx),
      .fi_ready(fi_ready_rx),
      .fi_up(fi_up_rx),
      .fi_valid(fi_valid_rx),
      .core_reset(core_reset),
      .rx_coreclkin(rx_coreclkin),
      .rx_datavalid(rx_datavalid),
      .rx_crc32err(rx_crc32err), 
      .rx_ctrlout(rx_ctrlout),
      .rx_parallel_data(rx_parallel_data),
      .rx_aligned(rx_aligned),
      .user_clock(user_interface_clock_rx),
      .user_clock_reset(user_interface_clock_reset_rx),
      .ecc_status (error_rx[(lanes+5)-1:lanes+3])
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
      .fi_ctrl(fi_ctrl_rx),
      .fi_data(fi_data_rx),
      .fi_ready(fi_ready_rx),
      .fi_up(fi_up_rx),
      .fi_valid(fi_valid_rx),
      .data(data_rx),
      .end_of_burst(end_of_burst_rx),
      .start_of_burst(start_of_burst_rx),
      .sync(sync_rx),
      .valid(valid_rx),
      .link_up(link_up_rx),
      .user_clock(user_interface_clock_rx),
      .user_clock_reset(user_interface_clock_reset_rx)
   );



 

endmodule  // seriallite_iii_streaming_source
