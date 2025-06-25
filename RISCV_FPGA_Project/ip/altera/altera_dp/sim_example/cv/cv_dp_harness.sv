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


// *********************************************************************
//
// DisplayPort IP Simulation Example -- Test Harness
// 
// Description
//
// This is the test harness for the DisplayPort simulation example. 
// It instantiates the simulation example design as the DUT.
// The DUT is driven video from a VGA driver. The DisplayPort
// Source(TX) is looped around to connect to the Sink (RX)
//
// The DisplayPort core is uses the default parameterization TX/RX
// 8 BPC plus CTS testautomation. This calculates a CRC on the video 
// sent and received. The test harness compares these value to
// confirm that correct the video has been properly encoded and decoded. 
//
// This test is parameterized to send 1 frame of 256x8, 8 BPC video
// after configuring the link to run at the HBR (2.7G) rate
//
// *********************************************************************


`timescale 1ns / 1ns
`default_nettype none


// console messaging level
`define AV_ADDRESS_W 16
`define AV_SYMBOL_W 8
`define AV_NUMSYMBOLS 4
`define AV_DATA_W (`AV_SYMBOL_W * `AV_NUMSYMBOLS)

module cv_dp_harness();
parameter RX_MAX_LANE_COUNT = 4;
parameter TX_MAX_LANE_COUNT = 4;

// GPU registers
localparam DPTX_TX_CONTROL  = 20'h00;
localparam DPTX0_MSA_COLOUR = 20'h2e;
localparam DPTX0_CRC_R      = 20'h30;
localparam DPTX0_CRC_G      = 20'h31;
localparam DPTX0_CRC_B      = 20'h32;

// Generate all the clocks for the test harness
wire clk270, clk162, clk16, clk100, tx_vid_clk, rx_vid_clk;
wire refclk;
clk_gen clk_gen(.clk270(clk270), .clk162(clk162), .clk16(clk16), .refclk(refclk),
	.clk100(clk100), .clk_tx_vid(tx_vid_clk), .clk_rx_vid(rx_vid_clk));

// Generate the test reset signal
reg reset;
reg tx_mgmt_read, tx_mgmt_write;

initial
begin
  reset = 1;
  #100 reset = 0;
  tx_mgmt_write = 0;
  tx_mgmt_read = 0;
end

// Instantiate the VGA video driver 
// to generate Video input stimulus
wire [15:0] tp_x, tp_y; 
wire vid_h, vid_v, vid_de;
wire [15:0] vid_r, vid_g, vid_b;
reg [15:0] h_resolution = 256;

wire [15:0] r_in = {tp_x[7:0], tp_x[7:0]};
wire [15:0] g_in = {tp_x[7:0], tp_x[7:0]};
wire [15:0] b_in = {tp_x[7:0], tp_x[7:0]};

vga_driver #(
	.V_FRONT(4), .V_SYNC(2), .V_BACK(4), .V_ACT(64),
	.H_FRONT(32), .H_SYNC(32), .H_BACK(32), .H_ACT(256)
) tst_pattern (
	.r(r_in), .g(g_in), .b(b_in),
	.current_x(tp_x), .current_y(tp_y),
	.request(vid_de),
	.vga_r(vid_r), .vga_g(vid_g), .vga_b(vid_b),
	.vga_hs(vid_h), .vga_vs(vid_v),
	.vga_blank(), .vga_clock (),
	.clk27(tx_vid_clk), .rst27 (reset),
	.v_front(16'd4), .v_sync(16'd2), .v_back(16'd4), .v_act(16'd64),
	.h_front(16'd32), .h_sync(16'd32), .h_back(16'd32), .h_act(h_resolution)
);

//
// Instantiate the DUT
//

// Wires to connect TX Video Input to the VGA driver
wire		tx_vid_v_sync	= ~vid_v; 
wire		tx_vid_h_sync	= ~vid_h; 
wire		tx_vid_f		= 1'b0; 
wire		tx_vid_de		= vid_de; 
wire [23:0]	tx_vid_data		= {vid_r[7:0], vid_g[7:0], vid_b[7:0]};

// Map the XCVR ref clocks
wire [1:0]	xcvr_refclk		= {clk270, clk162};

// AV-MM interface for controlling the Source
wire		tx_mgmt_chipselect = tx_mgmt_read | tx_mgmt_write ;
reg  [31:0]	tx_mgmt_writedata;
reg  [8:0]  tx_mgmt_address; 
wire [31:0] tx_mgmt_readdata;
wire        tx_mgmt_waitrequest;
wire        tx_mgmt_irq;

// XCVR outputs to connect back to the inputs
wire [3:0]  tx_serial_data;

// Wires from the RX Video Output 
wire        rx_cvi_datavalid;
wire        rx_cvi_f; 
wire        rx_cvi_h_sync;
wire        rx_cvi_v_sync;
wire        rx_cvi_locked;
wire        rx_cvi_de;
wire [23:0] rx_cvi_data; 

// AUX interface signals
wire        tx_aux_out;
wire        tx_aux_oe;
wire        rx_aux_out;
wire        rx_aux_oe;
wire        rx_hpd;  
wire        tx_hpd = rx_hpd;

reg freq_measure0=0, freq_measure1=0, freq_measure2=0;
reg freq_measure3=0, freq_measure4=0, freq_measure5=0;
     
wire tx_xcvr_clkout = dut.u0.cv_dp_inst.bitec_dp_inst.dp_tx_clk;
wire rx_xcvr_clkout = dut.u0.cv_dp_inst.bitec_dp_inst.dp_rx_clk[0];
freq_check freq_check(
        .region0        (freq_measure0 & ~freq_measure1),
        .region1        (freq_measure2 & ~freq_measure3),
        .region2        (freq_measure4 & ~freq_measure5),
        .refclk (refclk),
        .tx_xcvr_clkout (tx_xcvr_clkout),
        .rx_xcvr_clkout (rx_xcvr_clkout),
        .reset(reset)
        );


cv_dp_example #(
	.LANES (RX_MAX_LANE_COUNT)
) dut (
	.clk(clk100),
	.reset(reset),

	// AV-MM interface to control the source
	.tx_mgmt_address(tx_mgmt_address),
	.tx_mgmt_chipselect(tx_mgmt_chipselect),
	.tx_mgmt_read(tx_mgmt_read),
	.tx_mgmt_write(tx_mgmt_write),
	.tx_mgmt_writedata(tx_mgmt_writedata),
	.tx_mgmt_readdata(tx_mgmt_readdata),
	.tx_mgmt_waitrequest(tx_mgmt_waitrequest),
	.tx_mgmt_irq(tx_mgmt_irq),

	// XCVR interfaces
	.xcvr_mgmt_clk(clk100),
	.xcvr_refclk(xcvr_refclk),
	.tx_serial_data(tx_serial_data ),	// Loop TX to RX
	.rx_serial_data(tx_serial_data ),

	// TX Video Input from VGA driver
	.tx_vid_clk(tx_vid_clk),
	.tx_vid_v_sync(tx_vid_v_sync),
	.tx_vid_h_sync(tx_vid_h_sync),
	.tx_vid_f(tx_vid_f),
	.tx_vid_de(tx_vid_de),
	.tx_vid_data(tx_vid_data),

	// RX Video Output
	.rx_vid_clk(rx_vid_clk),
	.rx_cvi_datavalid(rx_cvi_datavalid),
	.rx_cvi_f(rx_cvi_f),
	.rx_cvi_locked(rx_cvi_locked),
	.rx_cvi_de(rx_cvi_de),
	.rx_cvi_h_sync(rx_cvi_h_sync),
	.rx_cvi_v_sync(rx_cvi_v_sync),
	.rx_cvi_data(rx_cvi_data),

	//.tx_xcvr_clkout(tx_xcvr_clkout), //need to enable secondary stream
	//.rx_xcvr_clkout(rx_xcvr_clkout), //need to enable secondary stream

	// AUX Interfaces RX & TX connected to each other
	.aux_clk(clk16),
	.aux_reset(reset),
	.tx_aux_in(rx_aux_out),
	.tx_aux_out(tx_aux_out),
	.tx_aux_oe(tx_aux_oe),
	.tx_hpd(tx_hpd),
	.rx_aux_in(tx_aux_out),
	.rx_aux_out(rx_aux_out),
	.rx_aux_oe(rx_aux_oe),
	.rx_hpd(rx_hpd)
);

// Registers for the main test program
reg [31:0]	readdata		= 0;
reg [31:0]	response		= 0;
reg		message_acked		= 0;
reg		ready_to_tx		= 0;
reg [3:0]	crc_count		= 0;
reg [15:0]	src_crc			= 0;
reg [7:0]	sink_crc		= 0;
reg [15:0]	sink_crc_r		= 0;
reg [15:0]	sink_crc_g		= 0;
reg [15:0]	sink_crc_b		= 0;
reg [15:0]  src_crc_r		= 0;
reg [15:0]  src_crc_g		= 0;
reg [15:0]  src_crc_b		= 0;

// SRC Control register fields
reg [2:0]	bpc				= 1;
reg [4:0]	lane_count		= 5'b00100;

// Event to start the test
reg start_main_link=0;
event start_test_main_link;
initial
begin
  wait(reset == 0);
	#4000
	-> start_test_main_link;
	start_main_link = 1;
    $display("start_main_link");
end


// This is the main loop of the test program. 
initial
begin
  @ start_test_main_link;
    $display("start_test_main_link");

  // This loop can be configured to adjust the horizontal active area
  // Currently set to a fixed 256
  for (h_resolution = 256; h_resolution < 257 ; h_resolution = h_resolution + 1)
  begin
    $display("Testing active line = %d", h_resolution);

	// This loop can be configured to test 1, 2 or 4 lanes.
	// Currently set to a fixed 4 lanes
	for (lane_count = 4; lane_count < 5 ; lane_count = lane_count*2)
	begin
		$display("Testing lane count = %d", lane_count);

//Link Rate Change Start 0	    
		$display("Testing Link HBR Rate (RX reconfig)" );
		// wait for TX ready 
		ready_to_tx = 0; 
		while(~ready_to_tx)
		begin
		  avalon_read(20'h100, readdata);
		  ready_to_tx = readdata[30];
		end

		// set lane count and data rate in sink
		avalon_write (20'h101, 8'h80);
		avalon_write (20'h102, 8'h01);
		avalon_write (20'h103, 8'h00); // Addr
		avalon_write (20'h104, 8'h01); // Length
		avalon_write (20'h105, 8'h0a); // BW SET HBR2=14h, HBR=0ah, RBR=06h
		avalon_write (20'h106, {3'h0, lane_count}); // LANE COUNT
		avalon_write (20'h100, 8'h06); //

		// Wait for acknowledgement
		message_acked = 0;
		while(~message_acked)
		begin
			avalon_read(20'h100, readdata);
			message_acked = readdata[31];
		end
		avalon_read(20'h101, readdata); //ACK the reply

		ready_to_tx = 0;
		while(~ready_to_tx)
		begin
		  avalon_read(20'h100, readdata);
		  ready_to_tx = readdata[30];
		end

        avalon_write (20'h101, 8'h90);
        avalon_write (20'h102, 8'h01); // Addr
        avalon_write (20'h103, 8'h01); // Addr
        avalon_write (20'h104, 8'h00); // Length
        avalon_write (20'h100, 8'h04); //
        message_acked = 0;
        while(~message_acked)
        begin
          avalon_read(20'h100, readdata);
          message_acked = readdata[31];
        end
        avalon_read(20'h101, readdata); // ACK the reply

		// Set TX link rate to reconfigure the XCVR
		$display("Testing Link HBR Rate (TX reconfig)" );
		avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd0 } | (1<< 17) | (1<<19) ); //bit[18:17]=00 RBR, =01 HBR, =10 HBR2

		$display("Testing maximum Vod and minimum pre-emphasis (TX analog reconfig)");
		// Change Vod and pre-emphasis to max vod and min emp
		avalon_write (20'h10, 32'h03 ); //Set Lane 0 EMP{3:2] and VOD[1:0]
		avalon_write (20'h11, 32'h03 ); //Set Lane 1 EMP{3:2] and VOD[1:0]
		avalon_write (20'h12, 32'h03 ); //Set Lane 2 EMP{3:2] and VOD[1:0]
		avalon_write (20'h13, 32'h03 ); //Set Lane 3 EMP{3:2] and VOD[1:0]
		avalon_write (20'h14, 32'h03 ); //Do reconfig=2'b11 for RECONFIG_LINKRATE and RECONFIG_ANALOG
		avalon_write (20'h14, 32'h00 ); //Do reconfig=0

		// Send Test pattern 1
		$display("Testing Link HBR Rate Training Pattern 1" );
		avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd1 } | (1<< 17) | (1<<19) ); //bit[18:17]=00 RBR, =01 HBR, =10 HBR2

		// Wait for Sink CR lock on lane 0
		response = 0;
		while (response[0] == 0)
		begin
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h02); // Addr
			avalon_write (20'h104, 8'h03); // Length
			avalon_write (20'h100, 8'h04); // 

			// Wait for acknowledgment
			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply

			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			response = readdata;
		end

freq_measure0=1;
        // Send Test pattern 2
		$display("Testing Link HBR Rate Training Pattern 2" );
		 avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd2 } | (1<< 17) | (1<<19) ); //bit[18:17]=00 RBR, =01 HBR, =10 HBR2
	    
		// Wait for Sink Symbol lock on lane 0
		response = 0;
		while(response[2] == 0) //Check Symbol Lock Lane 0
		begin
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h02); // Addr
			avalon_write (20'h104, 8'h03); // Length
			avalon_write (20'h100, 8'h04); // 

			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply
					  
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			response = readdata;
		end 
freq_measure1=1;
//Link Rate Change End 0	    
		$display("End Testing Link HBR Rate" );

//Link Rate Change Start 1	    
		$display("Testing Link RBR Rate (RX reconfig)" );
		ready_to_tx = 0;
		while(~ready_to_tx)
		begin
		  avalon_read(20'h100, readdata);
		  ready_to_tx = readdata[30];
		end

		// set lane count and data rate in sink
		avalon_write (20'h101, 8'h80);
		avalon_write (20'h102, 8'h01);
		avalon_write (20'h103, 8'h00); // Addr
		avalon_write (20'h104, 8'h01); // Length
		avalon_write (20'h105, 8'h06); // BW SET HBR2=14h, HBR=0ah, RBR=06h
		avalon_write (20'h106, {3'h0, lane_count}); // LANE COUNT
		avalon_write (20'h100, 8'h06); //

		// Wait for acknowledgement
		message_acked = 0;
		while(~message_acked)
		begin
			avalon_read(20'h100, readdata);
			message_acked = readdata[31];
		end
		avalon_read(20'h101, readdata); //??? ACK the reply

		ready_to_tx = 0;
		while(~ready_to_tx)
		begin
		  avalon_read(20'h100, readdata);
		  ready_to_tx = readdata[30];
		end

		avalon_write (20'h101, 8'h90);
		avalon_write (20'h102, 8'h01); // Addr
		avalon_write (20'h103, 8'h01); // Addr
		avalon_write (20'h104, 8'h00); // Length
		avalon_write (20'h100, 8'h04); //
		message_acked = 0;
		while(~message_acked)
		begin
		  avalon_read(20'h100, readdata);
		  message_acked = readdata[31];
		end
		avalon_read(20'h101, readdata); // ACK the reply

		// Set TX link rate to reconfigure the XCVR
		$display("Testing Link RBR Rate (TX reconfig)" );
		avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd0 } | (0<< 17) | (1<<19) ); //bit[18:17]=00     RBR, =01 HBR, =10 HBR2

		$display("Testing minimum Vod and pre-emphasis (TX analog reconfig)");
		// Change Vod and pre-emphasis to minimum/default settings
		avalon_write (20'h10, 32'h0c ); //Set Lane 0 EMP{3:2] and VOD[1:0]
		avalon_write (20'h11, 32'h0c ); //Set Lane 1 EMP{3:2] and VOD[1:0]
		avalon_write (20'h12, 32'h0c ); //Set Lane 2 EMP{3:2] and VOD[1:0]
		avalon_write (20'h13, 32'h0c ); //Set Lane 3 EMP{3:2] and VOD[1:0]
		avalon_write (20'h14, 32'h03 ); //Do reconfig=2'b11 for RECONFIG_LINKRATE and RECONFIG_ANALOG
		avalon_write (20'h14, 32'h00 ); //Do reconfig=0

		// Send Test pattern 1
		$display("Testing Link RBR Rate Training Pattern 1" );
	avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd1 } | (0<< 17) | (1<<19) ); //bit[18:17]=00     RBR, =01 HBR, =10 HBR2

		// Wait for Sink CR lock on lane 0
		response = 0;
		while (response[0] == 0) //Check CR_DONE Lane 0
		begin
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h02); // Addr
			avalon_write (20'h104, 8'h03); // Length
			avalon_write (20'h100, 8'h04); // 

			// Wait for acknowledgment
			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply

			/* Read Lane 0 CR Done Status */
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			response = readdata;
		end

freq_measure2=1;
        // Send Test pattern 2
		$display("Testing Link RBR Rate Training Pattern 2" );
        avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd2 } | (0<< 17) | (1<<19) ); //bit[18:17]=00     RBR, =01 HBR, =10 HBR2
	    
		// Wait for Sink Symbol lock on lane 0
		response = 0;
		while(response[2] == 0) //Check Symbol Lock Lane 0
		begin
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h02); // Addr
			avalon_write (20'h104, 8'h03); // Length
			avalon_write (20'h100, 8'h04); // 

			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply
					  
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			response = readdata;
		end 
freq_measure3=1;
//Link Rate Change End 1	    
		$display("End Testing Link RBR Rate" );


//Link Rate Change Start 2	    
		$display("Testing Link HBR Rate (RX reconfig)" );
		ready_to_tx = 0;
		while(~ready_to_tx)
		begin
		  avalon_read(20'h100, readdata);
		  ready_to_tx = readdata[30];
		end

		// set lane count and data rate in sink
		avalon_write (20'h101, 8'h80);
		avalon_write (20'h102, 8'h01);
		avalon_write (20'h103, 8'h00); // Addr
		avalon_write (20'h104, 8'h01); // Length
		avalon_write (20'h105, 8'h0a); // BW SET HBR2=14h, HBR=0ah, RBR=06h
		avalon_write (20'h106, {3'h0, lane_count}); // LANE COUNT
		avalon_write (20'h100, 8'h06); //

		// Wait for acknowledgement
		message_acked = 0;
		while(~message_acked)
		begin
			avalon_read(20'h100, readdata);
			message_acked = readdata[31];
		end
		avalon_read(20'h101, readdata); //??? ACK the reply

		ready_to_tx = 0;
		while(~ready_to_tx)
		begin
		  avalon_read(20'h100, readdata);
		  ready_to_tx = readdata[30];
		end

		avalon_write (20'h101, 8'h90);
		avalon_write (20'h102, 8'h01); // Addr
		avalon_write (20'h103, 8'h01); // Addr
		avalon_write (20'h104, 8'h00); // Length
		avalon_write (20'h100, 8'h04); //
		message_acked = 0;
		while(~message_acked)
		begin
		  avalon_read(20'h100, readdata);
		  message_acked = readdata[31];
		end
		avalon_read(20'h101, readdata); // ACK the reply

		// Set TX link rate to reconfigure the XCVR
		$display("Testing Link HBR Rate (TX reconfig)" );
		avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd0 } | (1<< 17) | (1<<19) ); //bit[18:17]=00 RBR, =01 HBR, =10 HBR2

		$display("Testing minimum Vod and pre-emphasis (TX analog reconfig)");
		// Change Vod and pre-emphasis to minimum/default settings
		avalon_write (20'h10, 32'h00 ); //Set Lane 0 EMP{3:2] and VOD[1:0]
		avalon_write (20'h11, 32'h00 ); //Set Lane 1 EMP{3:2] and VOD[1:0]
		avalon_write (20'h12, 32'h00 ); //Set Lane 2 EMP{3:2] and VOD[1:0]
		avalon_write (20'h13, 32'h00 ); //Set Lane 3 EMP{3:2] and VOD[1:0]
		avalon_write (20'h14, 32'h03 ); //Do reconfig=2'b11 for RECONFIG_LINKRATE and RECONFIG_ANALOG
		avalon_write (20'h14, 32'h00 ); //Do reconfig=0

		// Send Test pattern 1
		$display("Testing Link HBR Rate Training Pattern 1" );
	avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd1 } | (1<< 17) | (1<<19) );
								//bit[18:17]=00 RBR, =01 HBR, =10 HBR2


		// Wait for Sink CR lock on lane 0
		response = 0;
		while (response[0] == 0) //Check CR_DONE Lane 0
		begin
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h02); // Addr
			avalon_write (20'h104, 8'h03); // Length
			avalon_write (20'h100, 8'h04); // 

			// Wait for acknowledgment
			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply

			/* Read Lane 0 CR Done Status */
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			response = readdata;
		end

freq_measure4=1;
        // Send Test pattern 2
		$display("Testing Link HBR Rate Training Pattern 2" );
        avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd2 } | (1<< 17) | (1<<19) ); //bit[18:17]=00 RBR, =01 HBR, =10 HBR2
	    
		// Wait for Sink Symbol lock on lane 0
		response = 0;
		while(response[2] == 0) //Check Symbol Lock Lane 0
		begin
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h02); // Addr
			avalon_write (20'h104, 8'h03); // Length
			avalon_write (20'h100, 8'h04); // 

			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply
					  
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			response = readdata;
		end 

freq_measure5=1;
//Link Rate Change End 2	    
		$display("End Testing Link HBR Rate" );

		// Send active video
		//
		//
		
		// This loop can be configured to test different BPC values
		// It is current fixed at 8 BPC
		for (bpc = 1; bpc < 2 ; bpc++) //Loop Test 0:6bpc, 1:8bpc, 2:10bpc, 3:12bpc 4:16bpc
		begin
			$display("Testing bpc = %d", bpc);
		avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd3 } | (1<<17) | (1<<19) ); // Send Idle Pattern
		avalon_write (DPTX0_MSA_COLOUR, {29'd0, bpc});
		avalon_write (DPTX_TX_CONTROL, {22'd0, lane_count, 1'b0, 4'd0 } | (1<<17) | (1<<19) ); // Turn on video


			// activate CRC calculatiom
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h80);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h70); // Addr
			avalon_write (20'h104, 8'h00); // Length
			avalon_write (20'h105, 8'h01); // TEST_SINK_START
			avalon_write (20'h100, 8'h05); // 
			
			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply
			
			crc_count = 0;
			
			// Check 2 frames (frame 0 and 1) 
			while(crc_count < 2)
			begin
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h46); // Addr
			avalon_write (20'h104, 8'h00); // Length
			avalon_write (20'h100, 8'h04); // 

			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply
				
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			crc_count = readdata[3:0];
			end    
			  
			// Read CRC from sink
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h90);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h40); // Addr
			avalon_write (20'h104, 8'h05); // Length
			avalon_write (20'h100, 8'h04); // 
			avalon_write (20'h100, 8'h04); // 
			  
			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply
				      
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			avalon_read(20'h102, readdata);
			sink_crc_r[7:0] = readdata[7:0];
			
			avalon_read(20'h103, readdata);
			avalon_read(20'h103, readdata);
			avalon_read(20'h103, readdata);
			sink_crc_r[15:8] = readdata[7:0];
			
			avalon_read(20'h104, readdata);
			avalon_read(20'h104, readdata);
			avalon_read(20'h104, readdata);
			sink_crc_g[7:0] = readdata[7:0];
			
			avalon_read(20'h105, readdata);
			avalon_read(20'h105, readdata);
			avalon_read(20'h105, readdata);
			sink_crc_g[15:8] = readdata[7:0];
			
			avalon_read(20'h106, readdata);
			avalon_read(20'h106, readdata);
			avalon_read(20'h106, readdata);
			sink_crc_b[7:0] = readdata[7:0];
			
			avalon_read(20'h107, readdata);
			avalon_read(20'h107, readdata);
			avalon_read(20'h107, readdata);
			sink_crc_b[15:8] = readdata[7:0];
			  
			$display("SINK CRC_R = %X, CRC_G = %X, CRC_B = %X, ", sink_crc_r, sink_crc_g, sink_crc_b);
			      
			// Read CRC from Source
			avalon_read(DPTX0_CRC_R, readdata);
			avalon_read(DPTX0_CRC_R, readdata);
			avalon_read(DPTX0_CRC_R, readdata);
			src_crc_r[15:0] = readdata[15:0];
			
			avalon_read(DPTX0_CRC_G, readdata);
			avalon_read(DPTX0_CRC_G, readdata);
			avalon_read(DPTX0_CRC_G, readdata);
			src_crc_g[15:0] = readdata[15:0];
			
			avalon_read(DPTX0_CRC_B, readdata);
			avalon_read(DPTX0_CRC_B, readdata);
			avalon_read(DPTX0_CRC_B, readdata);
			src_crc_b[15:0] = readdata[15:0];

			$display("SOURCE CRC_R = %X, CRC_G = %X, CRC_B = %X, ", src_crc_r, src_crc_g, src_crc_b);
			
			// Check video is correct
			if((sink_crc_r != src_crc_r) || (sink_crc_b != src_crc_b) || (sink_crc_b != src_crc_b))
			begin
				$display("Video pixel data error");
				$stop();
			end
			    
			// deactivate CRC calculatiom
			ready_to_tx = 0;
			while(~ready_to_tx)
			begin
			  avalon_read(20'h100, readdata);
			  ready_to_tx = readdata[30];
			end

			avalon_write (20'h101, 8'h80);
			avalon_write (20'h102, 8'h02); // Addr
			avalon_write (20'h103, 8'h70); // Addr
			avalon_write (20'h104, 8'h00); // Length
			avalon_write (20'h105, 8'h00); // TEST_SINK_START
			avalon_write (20'h100, 8'h05); // 
		  
			message_acked = 0;
			while(~message_acked)
			begin
				avalon_read(20'h100, readdata);
				message_acked = readdata[31];
			end
			avalon_read(20'h101, readdata); // ACK the reply
		end
	end
end

#100
$display("Pass: Test Completed");
$stop();

end

//
// Avalon-MM single-transaction read and write procedures.
//
// ------------------------------------------------------------
task avalon_write (
// ------------------------------------------------------------
input [`AV_ADDRESS_W-1:0] addr,
input [`AV_DATA_W-1:0] data
);
	@(posedge clk100)
	begin
		{tx_mgmt_read, tx_mgmt_address, tx_mgmt_writedata, tx_mgmt_write} = {1'b0, addr, data, 1'b1};
	end
endtask

// ------------------------------------------------------------
task avalon_read (
// ------------------------------------------------------------
input [`AV_ADDRESS_W-1:0] addr,
output [`AV_DATA_W-1:0] readdata
);
	@(posedge clk100)
	begin
		{tx_mgmt_write, tx_mgmt_address, readdata, tx_mgmt_read} = {1'b0, addr, tx_mgmt_readdata[31:0], 1'b1};
	end
endtask

endmodule

`default_nettype wire
