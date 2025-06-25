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
// DisplayPort IP HW Demo
// 
// Description
//
// This is a simple HW demo which instantiates the altera_dp core and
// appropriate assisting IP including:
//   * Video PLL (altera_pll)
//   * XCVR PLL (altera_pll)
//   * XCVR reconfiguration IP
//   * Nios Link Master controlelr
// 
// *********************************************************************


// synthesis translate_off
`timescale 1ps / 1ps
// synthesis translate_on
`default_nettype none

module av_dp_demo # (
	parameter LANES = 4
)(
	// top-level clocks & reset
	input wire clk,
	input wire xcvr_pll_refclk,
	input wire resetn,
	input wire ddr_clk,

	// XCVR pins
	input  wire [LANES-1:0]   rx_serial_data, 
	output wire [LANES-1:0]   tx_serial_data, 

	// AUX pins
	inout wire AUX_TX_NC,
	inout wire AUX_TX_PC,
	input wire TX_HPD,
	inout wire AUX_RX_NC,
	inout wire AUX_RX_PC,
	output wire RX_HPD,

	// Extra outputs driving GND for Bitec daughter card components
	output wire AUX_TX_DRV_OUT, AUX_TX_DRV_OE, AUX_RX_DRV_OUT, AUX_RX_DRV_OE,

	// I2C interface
	inout wire SCL_CTL, SDA_CTL,	// Real connections to re-driver I2C
	output wire RX_CAD, RX_ENA, TX_ENA,		// forced high or low

	// Push-button inputs
	input wire [1:0] user_pb,

	// LED outputs
	output wire [7:0] user_led,
	
	// DDR Memory interface
	output wire	[12:0]	mem_a,
	output wire	[2:0]	mem_ba,
	output wire			mem_ck,
	output wire			mem_ck_n,
	output wire			mem_cke, 
	output wire			mem_cs_n,
	output wire	[3:0]	mem_dm,  
	output wire			mem_ras_n,
	output wire			mem_cas_n,
	output wire			mem_we_n, 
	output wire			mem_reset_n,
	inout wire	[31:0]	mem_dq,     
	inout wire	[3:0]	mem_dqs,    
	inout wire	[3:0]	mem_dqs_n,  
	output wire			mem_odt,    
	input wire			oct_rzqin
);

	wire reset, system_resetn;
	reg [15:0] video_pll_locked_counter;

	// Aux pin connections
	wire tx_aux_in;
	wire tx_aux_out;
	wire tx_aux_oe;
	wire rx_aux_in;
	wire rx_aux_out;
	wire rx_aux_oe;	

	// Extra grounded outputs. 
	assign AUX_TX_DRV_OUT = 1'b0;
	assign AUX_TX_DRV_OE  = 1'b0;
	assign AUX_RX_DRV_OUT = 1'b0;
	assign AUX_RX_DRV_OE  = 1'b0;

	// The I2C RX/TX control outputs are hard-wired
	assign RX_CAD = 1'b0;
	assign RX_ENA = 1'b1;
	assign TX_ENA = 1'b1;
	
	// outputs from the Video & XCVR PLLs
	wire aux_clk;
	wire video_clk;
	wire video_pll_locked;
	wire clk162, clk270;
	wire [1:0] xcvr_refclk;
	wire xcvr_pll_locked;
	reg stable_pll_lock;

	assign xcvr_refclk[0] = clk162;
	assign xcvr_refclk[1] = clk270;

	// Connections from DP core to the reconfig management FSM
	wire [1:0] rx_link_rate;
	wire rx_reconfig_req;
	wire rx_reconfig_ack;
	wire rx_reconfig_busy;
	wire [1:0] tx_link_rate;
	wire tx_reconfig_req;
	wire tx_reconfig_ack;
	wire tx_reconfig_busy;

	// Connections from the reconfig management FSM to the XCVR reconfig IP
	wire mgmt_waitrequest;
	wire [6:0] mgmt_address;
	wire [31:0] mgmt_writedata;
	wire mgmt_write;
	wire reconfig_busy;

	// Connections from DP to the reconfig IP
	wire [839:0] reconfig_to_xcvr;
	wire [551:0] reconfig_from_xcvr;

	// Connections from the CVO to the DP TX
	wire tx_vid_v_sync;
	wire tx_vid_h_sync;
	wire tx_vid_datavalid;
	wire [23:0] tx_vid_data;

	// Connections from the DP RX to the CVI
	wire rx_vid_eol;
	wire rx_vid_eof;
	wire rx_vid_locked;
	wire rx_vid_de;
	wire [23:0] rx_vid_data;
	reg rx_vid_v_sync;
	reg rx_vid_h_sync;

	// CVI v sync, h sync and datavalid are derived from 
	// delayed versions of eol and eof signals
	always @ (posedge video_clk)
	begin
		rx_vid_h_sync <= rx_vid_eol;
		rx_vid_v_sync <= rx_vid_eof;
	end

	// Report locked video to user
	assign user_led[0] = ~rx_vid_locked;

	// report lane count to user
	wire [4:0] rx_lane_count;
	assign user_led[5:1] = ~rx_lane_count;

	// Positive edge reset for the PLLs
	assign reset = !resetn;

	// Wait for 32K locks before releasing reset on the control system
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
			// Reset the locked counter on reset
			video_pll_locked_counter <= 16'h0000;
		else if (!video_pll_locked || !xcvr_pll_locked)
			// Reset the locked counter if we lost lock
			video_pll_locked_counter <= 16'h0000;
		else if (video_pll_locked_counter < 16'hffff)
			// Increment counter if not at maximum
			video_pll_locked_counter <= video_pll_locked_counter + 16'h0001;
	end
	
	// Clear reset when we've seen 32K good locks
	assign system_resetn = video_pll_locked_counter[15];

	// Check if we lose lock on either PLL after we release system reset
	always @ (posedge clk or negedge system_resetn)
	begin
		if (!system_resetn)
			// Reset the stable_pll_lock signal
			stable_pll_lock <= 1'b1;
		else if (!video_pll_locked || !xcvr_pll_locked)
			// If either PLL goes out of lock once the system reset is released, flag it
			stable_pll_lock <= 1'b0;
	end
	

	assign user_led[7] = system_resetn;
	assign user_led[6] = ~stable_pll_lock;

	// Instantiate the Nios system containing the VIP datapath, DP source/sink and the TX link master
    av_control u0 (
        .resetn_reset_n(system_resetn),
        .clk_clk(clk),
        .clk_vip_clk(video_clk),

		// User I/O
		.msa_dump_export(!user_pb[0]),
        .dp_rx_params_export(rx_lane_count),

		// AUX interfaces
        .clk_aux_clk(aux_clk),
        .dp_rx_aux_aux_in(~rx_aux_in),
        .dp_rx_aux_aux_out(rx_aux_out),
        .dp_rx_aux_aux_oe(rx_aux_oe),
        .dp_rx_aux_hpd(RX_HPD),
        .dp_tx_aux_aux_in(~tx_aux_in),
        .dp_tx_aux_aux_out(tx_aux_out),
        .dp_tx_aux_aux_oe(tx_aux_oe),
        .dp_tx_aux_hpd(TX_HPD),
		.oc_i2c_master_0_conduit_start_scl_pad_io(SCL_CTL),
		.oc_i2c_master_0_conduit_start_sda_pad_io(SDA_CTL),

		// XCVR data / refclk
        .dp_xcvr_refclk_export(xcvr_refclk),
        .dp_tx_serial_data_export(tx_serial_data),
        .dp_rx_serial_data_export(rx_serial_data),

		// XCVR reconfiguration interfaces
        .dp_xcvr_mgmt_clk_clk(clk),
        .dp_rx_reconfig_link_rate(rx_link_rate),
		.dp_rx_reconfig_reconfig_req(rx_reconfig_req),
		.dp_rx_reconfig_reconfig_ack(rx_reconfig_ack),
		.dp_rx_reconfig_reconfig_busy(rx_reconfig_busy),
        .dp_tx_reconfig_link_rate(tx_link_rate),
		.dp_tx_reconfig_reconfig_req(tx_reconfig_req),
		.dp_tx_reconfig_reconfig_ack(tx_reconfig_ack),
		.dp_tx_reconfig_reconfig_busy(tx_reconfig_busy),
        .dp_xcvr_reconfig_to_xcvr(reconfig_to_xcvr),
        .dp_xcvr_reconfig_from_xcvr(reconfig_from_xcvr),

		// Video in from RX Sink to CVI
		.dp_rx_vid_clk_clk(video_clk),
		.dp_rx_video_out_valid(rx_vid_de),
		.dp_rx_video_out_sol(),						// Unused
		.dp_rx_video_out_eol(rx_vid_eol),
		.dp_rx_video_out_sof(),						// Unused
		.dp_rx_video_out_eof(rx_vid_eof),
		.dp_rx_video_out_locked(rx_vid_locked),
		.dp_rx_video_out_data(rx_vid_data),
		.cvi_clocked_video_vid_clk(video_clk),
		.cvi_clocked_video_vid_data(rx_vid_data),
		.cvi_clocked_video_overflow(),				// Unused
		.cvi_clocked_video_vid_datavalid(1'b1),			// Data is not oversampled
		.cvi_clocked_video_vid_locked(rx_vid_locked),
		.cvi_clocked_video_vid_v_sync(rx_vid_v_sync),
		.cvi_clocked_video_vid_h_sync(rx_vid_h_sync),
		.cvi_clocked_video_vid_f(1'b0),					// Video is progressive
		.cvi_clocked_video_vid_de(rx_vid_de),

		// DDR memory
		.clk_ddr_clk(ddr_clk),
		.memory_mem_a(mem_a),
		.memory_mem_ba(mem_ba),
		.memory_mem_ck(mem_ck),
		.memory_mem_ck_n(mem_ck_n),
		.memory_mem_cke(mem_cke),      
		.memory_mem_cs_n(mem_cs_n), 
		.memory_mem_dm(mem_dm),   
		.memory_mem_ras_n(mem_ras_n),
		.memory_mem_cas_n(mem_cas_n),
		.memory_mem_we_n(mem_we_n), 
		.memory_mem_reset_n(mem_reset_n),
		.memory_mem_dq(mem_dq),     
		.memory_mem_dqs(mem_dqs),        
		.memory_mem_dqs_n(mem_dqs_n),  
		.memory_mem_odt(mem_odt),        
		.oct_rzqin(oct_rzqin),

		// Video out from CVO to TX source
		.cvo_clocked_video_vid_clk(video_clk),
		.cvo_clocked_video_vid_data(tx_vid_data),
		.cvo_clocked_video_underflow(),				// Unused
		.cvo_clocked_video_vid_datavalid(tx_vid_datavalid),
		.cvo_clocked_video_vid_v_sync(tx_vid_v_sync),
		.cvo_clocked_video_vid_h_sync(tx_vid_h_sync),
		.cvo_clocked_video_vid_f(),					// Unused
		.cvo_clocked_video_vid_h(),					// Unused
		.cvo_clocked_video_vid_v(),					// Unused
        .dp_tx_vid_clk_clk(video_clk),
        .dp_tx_video_in_v_sync(tx_vid_v_sync),
        .dp_tx_video_in_h_sync(tx_vid_h_sync),
        .dp_tx_video_in_de(tx_vid_datavalid),
        .dp_tx_video_in_f(1'b0),					// Progressive Video
        .dp_tx_video_in_data(tx_vid_data)
    );

	// Instantiate the PLLs
	av_video_pll video_pll_inst (
		.refclk(clk),
		.rst(reset),    
		.outclk_0(video_clk),
		.outclk_1(aux_clk),
		.locked(video_pll_locked)
	);

	av_xcvr_pll xcvr_pll_inst (
		.refclk(xcvr_pll_refclk),
		.rst(reset),    
		.outclk_0(clk162),
		.outclk_1(clk270),
		.locked(xcvr_pll_locked)
	);

	// Instantiate the reconfig management FSM
	reconfig_mgmt_hw_ctrl #(
		.DEVICE_FAMILY("Arria V"),
		.RX_LANES(LANES),
		.TX_LANES(LANES),
		.TX_PLLS(LANES)
	) mgmt (
		.clk(clk),
		.reset(!system_resetn),

		.rx_reconfig_req(rx_reconfig_req),
		.rx_link_rate(rx_link_rate),
		.rx_reconfig_ack(rx_reconfig_ack),
		.rx_reconfig_busy(rx_reconfig_busy),

		.tx_reconfig_req(tx_reconfig_req),
		.tx_link_rate(tx_link_rate),
		.tx_reconfig_ack(tx_reconfig_ack),
		.tx_reconfig_busy(tx_reconfig_busy),

// Disable vod & emp for Bitec Rev 4+ daughter cards with re-drivers
		.tx_analog_reconfig_req(1'b0),
		.vod(8'b00000000),
		.emp(8'b00000000),	
		.tx_analog_reconfig_ack(), // unused
		.tx_analog_reconfig_busy(), // unused

		.mgmt_address(mgmt_address),		
		.mgmt_writedata(mgmt_writedata),	
		.mgmt_write(mgmt_write),				
		.mgmt_waitrequest(mgmt_waitrequest),		
		.reconfig_busy(reconfig_busy)			
	);

	// Instantiate the XCVR reconfig IP
	av_xcvr_reconfig reconfig (
		.reconfig_busy(reconfig_busy),            
		.mgmt_clk_clk(clk),              
		.mgmt_rst_reset(!system_resetn),           
		.reconfig_mgmt_address(mgmt_address),
		.reconfig_mgmt_read(),  
		.reconfig_mgmt_readdata(),
		.reconfig_mgmt_waitrequest(mgmt_waitrequest),
		.reconfig_mgmt_write(mgmt_write),     
		.reconfig_mgmt_writedata(mgmt_writedata),  
		.reconfig_to_xcvr(reconfig_to_xcvr),         
		.reconfig_from_xcvr(reconfig_from_xcvr)        
	);

	// Instantiate the AUX buffers
	// Daughter card has AUX P&N signals swapped, so invert AUX datain and out
	av_aux_buffer aux_buffer_tx (
		.datain(~tx_aux_out),
		.oe(tx_aux_oe),
		.dataio(AUX_TX_PC),
		.dataio_b(AUX_TX_NC),
		.dataout(tx_aux_in)
	);

	av_aux_buffer aux_buffer_rx (
		.datain(~rx_aux_out),
		.oe(rx_aux_oe),
		.dataio(AUX_RX_PC),
		.dataio_b(AUX_RX_NC),
		.dataout(rx_aux_in)
	);



endmodule

`default_nettype wire
