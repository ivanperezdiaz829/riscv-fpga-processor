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
// reconfig_mgmt_hw_ctrl.v
// 
// Description
// This module is responsible for generating the control signals to 
// reconfigure the following:
// XCVR TX channel - VOD, Pre-emphasis, select the PLL reference clock, 
//                   reprogram the Tx PLL counters, CGB divider,TX output
//                   slew rate, and VCM driver output
// XCVR RX channel - Select the PLL reference clock, reprogram the 
//                   CDR counters to change the datarate, and the 
//                   eye monitor settings
// 
// XCVR channels attached. 
//
// It uses a high-level FSM to loop over all the channels and settings
// It uses a low-level reconfig_mgmt_write module to generate the actual
// commands
//
// This will start a reconfig when the start_reconfig input is pulsed or
// if any of the data inputs change.
// 
// *********************************************************************

// synthesis translate_off
`timescale 1ns / 1ns
// synthesis translate_on
`default_nettype none

module reconfig_mgmt_hw_ctrl #(
	parameter	DEVICE_FAMILY = "Stratix V",
	parameter	RX_LANES = 4,
	parameter	TX_LANES = 4,
	parameter	TX_PLLS = 4
)(
	input wire clk,								// This should be the same 100MHz clock driving the reconfig controller
	input wire reset,							// This should be the same reset driving the reconfig controller

	input wire rx_reconfig_req,					// high pulse starts reconfig with the values defined below
	input wire [1:0] rx_link_rate,
	output reg rx_reconfig_ack,					// Acknowledge the reconfig request to clear flag
	output reg rx_reconfig_busy,				// hold high while reconfig taking plance

	input wire tx_reconfig_req,					// high pulse starts reconfig with the values defined below
	input wire [1:0] tx_link_rate,
	output reg tx_reconfig_ack,					// Acknowledge the reconfig request to clear flag
	output reg tx_reconfig_busy,				// hold high while reconfig taking plance

	input wire tx_analog_reconfig_req,			// high pulse starts reconfig with the values defined below
	input wire [(TX_LANES*2)-1:0] vod,			// Each lane can have it's own 6-bit VOD, using DP encoding & translating
	input wire [(TX_LANES*2)-1:0] emp,			// Each lane can have it's own 5-bit pre-emphasis, using DP encoding & translating
	output reg tx_analog_reconfig_ack,			// Acknowledge the reconfig request to clear flag
	output reg tx_analog_reconfig_busy,			// hold high while reconfig taking plance

	output wire [6:0] mgmt_address,				// connect to reconfig_mgmt_address of reconfig controller
	output wire [31:0] mgmt_writedata,			// connect to reconfig_mgmt_writedata of reconfig controller
	output wire mgmt_write,						// connect to reconfig_mgmt_write of reconfig controller
	input wire mgmt_waitrequest,				// connect to reconfig_mgmt_waitrequest of reconfig controller
	input wire reconfig_busy					// connect to reconfig_busy of reconfig controller
);

	wire [(TX_LANES*6)-1:0] vod_mapped;		// These are the mapped values of vod & emp
	wire [(TX_LANES*5)-1:0] emp_mapped;		

	// Save the settings in local registers to avoid changing mid-configuration
	reg [1:0] rx_link_rate_reg;				
	reg [1:0] tx_link_rate_reg;				
	reg [(TX_LANES*6)-1:0] vod_reg;		
	reg [(TX_LANES*5)-1:0] emp_reg;

	reg start_single_reconfig;			// high pulse starts reconfig with the values defined below
	reg [6:0]	logical_ch_address;		// specifies address for the logical channel
	reg [3:0]	logical_ch_num;			// specifies which logical channel number
	reg [6:0]	feature_offset_address;	// specifies address for the feature offset
	reg [5:0]	feature_offset_val;		// specifies the offset feature value
	reg [6:0]	data_address;			// specifies address for the data offset
	reg [31:0]	data_val;				// specifies the offset data value
	reg [6:0]	cs_address;				// specifies address of control and status register
	reg			mif_mode_1;				//specifies if Mode 1 of the MIF streamer IP is used 
	reg			rx_reconfig;
	reg			tx_reconfig;
	reg			tx_analog_reconfig;

	// Instantiate the low-level module that generates the actual writes
	reconfig_mgmt_write reconfig_mgmt_write_inst(
		.clk(clk),								// Just connect to top-level port
		.reset(reset),							// Just connect to top-level port

		.start_reconfig(start_single_reconfig),		// These signals are setup by the high-level FSM
		.logical_ch_address(logical_ch_address),
		.logical_ch_num(logical_ch_num),
		.feature_offset_address(feature_offset_address),
		.feature_offset_val(feature_offset_val),
		.data_address(data_address),
		.data_val(data_val),
		.cs_address(cs_address),
		.mif_mode_1(mif_mode_1),

		.mgmt_address(mgmt_address),			// Just connect to top-level port
		.mgmt_writedata(mgmt_writedata),		// Just connect to top-level port
		.mgmt_write(mgmt_write),				// Just connect to top-level port
		.mgmt_waitrequest(mgmt_waitrequest),	// Just connect to top-level port
		.reconfig_busy(reconfig_busy)			// Just connect to top-level port
	);

	// MIF types
	localparam	DUPLEX	= 3'b000,
				CMU		= 3'b001,
				RX		= 3'b010,
				TX		= 3'b011,
				ATX		= 3'b100; 

	//Link rates
	localparam	RBR		= 2'b00,
				HBR		= 2'b01,
				HBR2	= 2'b10; 

	// State variables
	localparam 	IDLE					= 0,
				START_RECONFIG			= 1,
				WAIT_FOR_BUSY_HIGH		= 2,
				WAIT_FOR_BUSY_LOW		= 3,
				INCREMENT				= 4,
				END_RECONFIG			= 5;
								
	// Feature index
	localparam	RX_REFCLK				= 0,
				RX_MIF				 	= 1,
				VOD						= 2,
				EMP						= 3,
				TX_MIF					= 4,
				TX_REFCLK				= 5,
				TX_PLL_MIF				= 6,
				MAX_FEATURE				= 7;

	// Constants for the addresses and values for better reading
	localparam	PMA_CHANNEL_ADDR		= 7'h08,
				PMA_CS_ADDR				= 7'h0A,
				PMA_FEATURE_ADDR		= 7'h0B,
				PMA_DATA_ADDR			= 7'h0C,
				VOD_FEATURE_VAL			= 5'h0,
				EMP_FEATURE_VAL			= 5'h2,
				PLL_CHANNEL_ADDR		= 7'h40,
				PLL_CS_ADDR				= 7'h42,
				PLL_FEATURE_ADDR		= 7'h43,
				PLL_DATA_ADDR			= 7'h44,
				REFCLK_FEATURE_VAL		= 6'h0,
				MIF_CHANNEL_ADDR	    = 7'h38,
				MIF_CS_ADDR				= 7'h3A,
				MIF_FEATURE_ADDR	    = 7'h3B,
				MIF_DATA_ADDR			= 7'h3C,
				REFCLK_VALUE_RBR        = 32'h0000_0000,
				REFCLK_VALUE_HBR        = 32'h0000_0001,
				REFCLK_VALUE_HBR2       = 32'h0000_0001;

	reg [2:0] state;
	reg [3:0] feature;

	// Generate analog mapping tables for each lane
	generate begin			
		genvar tx_lane;
		for (tx_lane=0; tx_lane < TX_LANES; tx_lane = tx_lane + 1) begin:lane
			dp_analog_mappings #(.DEVICE_FAMILY(DEVICE_FAMILY)) dp_analog_mappings_i(
				.in_vod		(vod[(tx_lane*2) +: 2]), 
				.in_emp		(emp[(tx_lane*2) +: 2]),
				.out_vod	(vod_mapped[(tx_lane*6) +: 6]), 
				.out_emp	(emp_mapped[(tx_lane*5) +: 5])
			);
		end // for
	end // generate
	endgenerate

	// Instantiate MIF mapping table 
	reg  [2:0]	mif_type;
	reg  [3:0]	mif_index;
	wire [5:0]	mif_offset;
	wire [15:0]	mif_value;
	wire		mif_done;

	dp_mif_mappings #(.DEVICE_FAMILY(DEVICE_FAMILY)) dp_mif_mappings_i(
		.mif_type(mif_type),
		.rx_link_rate(rx_link_rate_reg),  
		.tx_link_rate(tx_link_rate_reg), 
		.index(mif_index),
		.offset(mif_offset), 
		.value(mif_value),
		.done(mif_done)
	);	

	always @ (posedge clk or posedge reset) begin : STATE_REG
		if (reset) begin
			state <= IDLE;

			// Reset the input registers
			rx_link_rate_reg <= 2'b00; 
			tx_link_rate_reg <= 2'b00;
			vod_reg <= 0;
			emp_reg <= 0;

			// Reset the feature & write counters
			feature					<= RX_REFCLK;
			rx_reconfig				<= 1'b0;
			tx_reconfig				<= 1'b0;
			tx_analog_reconfig		<= 1'b0;

			// Reset the MIF type, index & done registers
			mif_type				<= RX;
			mif_index				<= 4'd0;

			// Reset all the registers feeding the low-level FSM
			start_single_reconfig	<= 1'h0;
			logical_ch_address 		<= 7'h0;
			logical_ch_num	 		<= 4'h0;
			feature_offset_address 	<= 7'h0;
			feature_offset_val	  	<= 6'h0;
			data_address			<= 7'h0;
			data_val 				<= 7'h0;
			cs_address				<= 7'h0;
			mif_mode_1		        <= 1'b0;

			// Reset the ack and busy signals
			rx_reconfig_ack			<= 1'b0;
			rx_reconfig_busy		<= 1'b0;
			tx_reconfig_ack			<= 1'b0;
			tx_reconfig_busy		<= 1'b0;
			tx_analog_reconfig_ack	<= 1'b0;
			tx_analog_reconfig_busy	<= 1'b0;
		end
		else
			case (state)
				IDLE:	
				begin
					// Reset the channel and feature counters and the start reconfig flag
					start_single_reconfig	<= 1'h0;
					logical_ch_num	 		<= 4'h0;
					feature					<= RX_REFCLK;
					rx_reconfig				<= 1'b0;
					tx_reconfig				<= 1'b0;
					tx_analog_reconfig		<= 1'b0;

					// Reset the MIF type, index & done registers
					mif_type				<= RX;
					mif_index				<= 4'd0;
					
					// Reset the ack and busy signals
					rx_reconfig_ack			<= 1'b0;
					rx_reconfig_busy		<= 1'b0;
					tx_reconfig_ack			<= 1'b0;
					tx_reconfig_busy		<= 1'b0;
					tx_analog_reconfig_ack	<= 1'b0;
					tx_analog_reconfig_busy	<= 1'b0;

					// Start a reconfig if requested, but only
					// support one reconfig at a time. The priority
					// is RX, TX and finally TX analog
					if (rx_reconfig_req) begin
						// Save all the input settings into local registers
						rx_link_rate_reg	<= rx_link_rate;

						// set the ack and busy flags
						rx_reconfig_ack		<= 1'b1;
						rx_reconfig_busy	<= 1'b1;

						// Set the logical channel and feature to do
						// the RX reconfigurations
						// RX channels are the first ones
						rx_reconfig			<= 1'b1;
						logical_ch_num 		<= 4'h0;
						feature				<= RX_REFCLK;
						state				<= START_RECONFIG;
					end
					else if (tx_reconfig_req) begin
						// Save all the input settings into local registers
						tx_link_rate_reg	<= tx_link_rate;

						// set the ack and busy flags
						tx_reconfig_ack		<= 1'b1;
						tx_reconfig_busy	<= 1'b1;

						// Set the logical channel and feature to do
						// the TX reconfigurations
						// TX channel is after RX
						tx_reconfig			<= 1'b1;
						logical_ch_num 		<= RX_LANES;
						feature				<= TX_MIF;
						mif_type			<= TX;
						state				<= START_RECONFIG;
					end
					else if (tx_analog_reconfig_req) begin
						// Save all the input settings into local registers
						vod_reg <= vod_mapped;
						emp_reg <= emp_mapped;

						// set the ack and busy flags
						tx_analog_reconfig_ack	<= 1'b1;
						tx_analog_reconfig_busy	<= 1'b1;

						// Set the logical channel and feature to do
						// the TX analog reconfigurations
						// TX channels start after RX channels
						tx_analog_reconfig	<= 1'b1;
						logical_ch_num 		<= RX_LANES;
						feature				<= VOD;
						state				<= START_RECONFIG;
					end
					else state				<= IDLE;
				end
			
				START_RECONFIG:
				begin
					// Reset the ack flags and set start_single_reconfig
					rx_reconfig_ack			<= 1'h0;
					tx_reconfig_ack			<= 1'h0;
					tx_analog_reconfig_ack	<= 1'h0;
					start_single_reconfig	<= 1'h1;

					// Setup the registers feeding the low-level FSM based on the channel and feature
					// The order is RX channels, TX channels, TX PLLs
					case (feature)
						RX_REFCLK:
						begin
							mif_mode_1				<= 1'b0;		
							logical_ch_address 		<= PLL_CHANNEL_ADDR;
							feature_offset_address 	<= PLL_FEATURE_ADDR;
							feature_offset_val	  	<= REFCLK_FEATURE_VAL;
							data_address			<= PLL_DATA_ADDR;
							cs_address				<= PLL_CS_ADDR;		

							//The write data (refclk index) depends on the current link rate
							if (rx_link_rate_reg == HBR2)
								data_val			<= REFCLK_VALUE_HBR2;
							else if (rx_link_rate_reg == HBR)
								data_val			<= REFCLK_VALUE_HBR;
							else //RBR 
								data_val			<= REFCLK_VALUE_RBR;
						end

						RX_MIF:
						begin
							mif_mode_1	    		<= 1'b1;		
							logical_ch_address 		<= MIF_CHANNEL_ADDR;
							cs_address				<= MIF_CS_ADDR;		
							feature_offset_address 	<= MIF_FEATURE_ADDR;
							feature_offset_val	  	<= mif_offset;
							data_address		    <= MIF_DATA_ADDR;
							data_val				<= mif_value;
						end

						TX_MIF:
						begin
							mif_mode_1	    		<= 1'b1;		
							logical_ch_address 		<= MIF_CHANNEL_ADDR;
							cs_address				<= MIF_CS_ADDR;		
							feature_offset_address 	<= MIF_FEATURE_ADDR;
							feature_offset_val	  	<= mif_offset;
							data_address		    <= MIF_DATA_ADDR;
							data_val				<= mif_value;
						end

						TX_REFCLK:
						begin
							mif_mode_1				<= 1'b0;		
							logical_ch_address 		<= PLL_CHANNEL_ADDR;
							feature_offset_address 	<= PLL_FEATURE_ADDR;
							feature_offset_val	  	<= REFCLK_FEATURE_VAL;
							data_address			<= PLL_DATA_ADDR;
							cs_address				<= PLL_CS_ADDR;		

							//The write data (refclk index) depends on the current link rate
							if (tx_link_rate_reg == HBR2)
								data_val 			<= REFCLK_VALUE_HBR2;
							else if (tx_link_rate_reg == HBR)
								data_val 			<= REFCLK_VALUE_HBR;
							else //RBR 
								data_val			<= REFCLK_VALUE_RBR;
						end

						TX_PLL_MIF:
						begin
							mif_mode_1	    		<= 1'b1;		
							logical_ch_address 		<= MIF_CHANNEL_ADDR;
							cs_address				<= MIF_CS_ADDR;		
							feature_offset_address 	<= MIF_FEATURE_ADDR;
							feature_offset_val	  	<= mif_offset;
							data_address		    <= MIF_DATA_ADDR;
							data_val				<= mif_value;
						end

						VOD:
						begin
							mif_mode_1				<= 1'b0;		
							logical_ch_address 		<= PMA_CHANNEL_ADDR;
							feature_offset_address 	<= PMA_FEATURE_ADDR;
							feature_offset_val	  	<= VOD_FEATURE_VAL;
							data_address			<= PMA_DATA_ADDR;
							data_val 				<= vod_reg[6*(logical_ch_num-RX_LANES) +: 6];
							cs_address				<= PMA_CS_ADDR;		
						end

						EMP:
						begin
							mif_mode_1				<= 1'b0;		
							logical_ch_address 		<= PMA_CHANNEL_ADDR;
							feature_offset_address 	<= PMA_FEATURE_ADDR;
							feature_offset_val	  	<= EMP_FEATURE_VAL;
							data_address			<= PMA_DATA_ADDR;
							data_val 				<= emp_reg[5*(logical_ch_num-RX_LANES) +: 5];
							cs_address				<= PMA_CS_ADDR;		
						end
					endcase

					state <= WAIT_FOR_BUSY_HIGH;
				end

				WAIT_FOR_BUSY_HIGH:
				begin
					// Clear the reconfig request
					start_single_reconfig	<= 1'h0;

					if (reconfig_busy) state <= WAIT_FOR_BUSY_LOW;
				end
		
				WAIT_FOR_BUSY_LOW:
					if (!reconfig_busy) state <= INCREMENT;
		
				INCREMENT:
					begin
						// Go to start another reconfig unless we
						// later decide this is the last write
						state <= START_RECONFIG;

						// Increment the channel and feature counters
						if (rx_reconfig) 
						begin 
							// For each logical RX channel, set
							// refclk & MIF values one after another
							case (feature)
								RX_REFCLK:
								begin
									// Starting feature was
									// RX_REFCLK. Next set the RX MIF
									// values. Reset mif_index
									feature		<= RX_MIF;
									mif_type	<= RX;
									mif_index	<= 4'd0;
								end
								
								RX_MIF:
								begin
									// Check if this is the last mif value
									if (~mif_done)
									begin
										// Write the next MIF value
										mif_index	<= mif_index + 4'd1;
										feature		<= RX_MIF;
									end
									else
									begin
										mif_index	<= 4'd0;
										feature		<= RX_REFCLK;

										// Check if this is the last
										// RX write
										if (logical_ch_num == (RX_LANES-1))
											state		<= END_RECONFIG;

										//Increment the logical_ch_num
										logical_ch_num <= logical_ch_num + 4'h1;
									end
								end
							endcase
						end // rx_reconfig
						else if (tx_reconfig)
						begin
							//Set TX MIF, TX ref clock and CMU MIF
							case (feature)
								TX_MIF:
								begin
									// Check if this is the last mif value
									if (~mif_done)
									begin
										// Write the next MIF value
										mif_index	<= mif_index + 4'd1;
										feature		<= TX_MIF;
									end
									else
									begin
										mif_index	<= 4'd0;

										// Last Tx channel write need to switch to TX refclk
										if (logical_ch_num == (RX_LANES + TX_LANES - 1))
											feature	<= TX_REFCLK;
										else
											feature	<= TX_MIF;

										logical_ch_num	<= logical_ch_num + 4'h1;
									end
								end

								TX_REFCLK:
								begin
									feature		<= TX_PLL_MIF;
									mif_type	<= CMU;
								end

								TX_PLL_MIF:
								begin
									// Check if this is the last mif value
									if (~mif_done)
									begin
										// Write the next MIF value
										mif_index	<= mif_index + 4'd1;
										feature		<= TX_PLL_MIF;
									end
									else
									begin
										mif_index	<= 4'd0;
										feature		<= TX_REFCLK;
   
										// See if this is the last channel
										if (logical_ch_num == (RX_LANES + TX_LANES + TX_PLLS -1))
											state		<= END_RECONFIG;

										logical_ch_num <= logical_ch_num + 4'h1;
									end
								end
							endcase
						end //tx_reconfig
						else
						begin
							case (feature)
								// After VOD write EMP
								VOD:
									feature			<= EMP;
									
								// After EMP write VOD or quit
								EMP:
								begin
									feature			<= VOD;

									// See if this is the last TX channel
									if (logical_ch_num == (RX_LANES + TX_LANES - 1))
										state		<= END_RECONFIG;

									logical_ch_num	<= logical_ch_num + 4'h1;
								end
							endcase
						end // tx_analog_reconfig
					end //INCREMENT

				END_RECONFIG:
					begin
						// clear the busy flags & go to the IDLE state
						rx_reconfig_busy <= 1'b0;
						tx_reconfig_busy <= 1'b0;
						tx_analog_reconfig_busy <= 1'b0;

						state <= IDLE;
					end
				endcase
			end
endmodule
/*
// synthesis translate_off
module reconfig_mgmt_hw_ctrl_tb #(parameter	DEVICE_FAMILY = "Stratix V")();

	parameter	TX_LANES = 4, RX_LANES = 4, TX_PLLS = 4;
  localparam RX_WRITES_PER_LANE = 19; //Refclk=4, CDR Cntrs=5*2(MIF mode 1),Eye Mon=5(MIF mode 1)
  localparam TOTAL_RX_WRITES    = RX_LANES * RX_WRITES_PER_LANE; 
  localparam TX_WRITES_PER_LANE = 37; //VOD=4,EMP=4,CGB div=5(MIF mode 1),Tx slew=5(MIF mode 1),Tx VCM=5(MIF mode 1),Tx Refclk=4,TX PLL cntr=5*2(MIF mode 1)
  localparam TOTAL_TX_WRITES    = TX_LANES * TX_WRITES_PER_LANE; 
  localparam  TOTAL_WRITES = TOTAL_RX_WRITES + TOTAL_TX_WRITES;
	localparam	GET_DATA = 0, CALC_RESULTS = 1, START_RECONFIG = 2, WAIT_FOR_ACK = 3, WAIT_FOR_BUSY_LOW = 4;	// Test states

	// Clocks and reset
	reg clk;
	reg reset;

	// RX reconfig interface
	reg rx_reconfig_req, rx_suppress_req;
	reg [1:0] rx_link_rate;
	reg [1:0] rx_link_rate_tmp;
	wire rx_reconfig_ack;
	wire rx_reconfig_busy;

	// TX reconfig interface
	reg tx_reconfig_req, tx_suppress_req;
	reg [1:0] tx_link_rate;
	reg [1:0] tx_link_rate_tmp;
	reg [(TX_LANES*2)-1:0] vod;
	reg [(TX_LANES*2)-1:0] emp;
	wire tx_reconfig_ack;
	wire tx_reconfig_busy;

	// XCVR reconfig MF interface
	wire [6:0] mgmt_address;
	wire [31:0] mgmt_writedata;
	wire mgmt_write;
	wire mgmt_waitrequest;
	wire reconfig_busy;

	// Test variables
	reg fail;
	integer n, write_index, writes, reconfigs;
	reg [6:0] mgmt_address_expected[TOTAL_WRITES-1:0] ;
	reg [31:0] mgmt_writedata_expected[TOTAL_WRITES-1:0] ;
	reg [2:0] test_state;
	wire [(TX_LANES*6)-1:0] vod_mapped;
	wire [(TX_LANES*5)-1:0] emp_mapped;
  
	// Instantiate DUT
	reconfig_mgmt_hw_ctrl #(
		.DEVICE_FAMILY(DEVICE_FAMILY),
		.TX_LANES(TX_LANES),
		.RX_LANES(RX_LANES)
	) dut (
		.clk(clk),
		.reset(reset),

		.rx_reconfig_req(rx_reconfig_req),
		.rx_link_rate(rx_link_rate),
		.rx_reconfig_ack(rx_reconfig_ack),
		.rx_reconfig_busy(rx_reconfig_busy),

		.tx_reconfig_req(tx_reconfig_req),
		.tx_link_rate(tx_link_rate),
		.vod(vod),
		.emp(emp),	
		.tx_reconfig_ack(tx_reconfig_ack),
		.tx_reconfig_busy(tx_reconfig_busy),

		.mgmt_address(mgmt_address),		
		.mgmt_writedata(mgmt_writedata),	
		.mgmt_write(mgmt_write),				
		.mgmt_waitrequest(mgmt_waitrequest),		
		.reconfig_busy(reconfig_busy)			
	);

	// Instantiate model of reconfig controller
	reconfig_model m (
		.clk(clk),
		.reset(reset),
		.mgmt_address(mgmt_address),		
		.mgmt_writedata(mgmt_writedata),	
		.mgmt_write(mgmt_write),				
		.mgmt_waitrequest(mgmt_waitrequest),		
		.reconfig_busy(reconfig_busy)
	);

	// Instantiate mapping table for the VOD & EMP settings
	// Generate mapping tables for each lane
	generate begin			
		genvar tx_lane;
		for (tx_lane=0; tx_lane < TX_LANES; tx_lane = tx_lane + 1) begin:lane
			dp_analog_mappings #(.DEVICE_FAMILY(DEVICE_FAMILY)) dp_analog_mappings_i(
				.in_vod		(vod[(tx_lane*2) +: 2]), 
				.in_emp		(emp[(tx_lane*2) +: 2]),
				.out_vod	(vod_mapped[(tx_lane*6) +: 6]), 
				.out_emp	(emp_mapped[(tx_lane*5) +: 5])
			);
		end // for
	end // generate
	endgenerate

	always begin
		#50 clk = ~clk;
	end

	always @ (posedge clk) begin
		case (test_state)
			GET_DATA:
			begin
				// Randomly assign data values 0,1,2
				tx_link_rate <= ($random % 3);
				rx_link_rate <= ($random % 3);

				// Randomly choose analog settings
				vod <= $random;
				emp <= $random;

				// Randomly decide who to reconfig
				do_tx_reconfig <= $random;
				do_tx_analog_reconfig <= $random;
				do_rx_reconfig <= $random;

				// Reset the writes counter
				writes <= 0;

				test_state <= CALC_RESULTS;
			end

			CALC_RESULTS:
			begin
				// If any reconfigs calculate the results
				if (do_tx_reconfig || do_tx_analog_reconfig || do_rx_reconfig)
				begin
					// Calculate all the expected addresses and write data
					calculate_expected_data();

					test_state <= START_RECONFIG;
				end
				else test_state <= GET_DATA;
			end

			START_RECONFIG:
			begin
				if (do_tx_reconfig) tx_reconfig_req <= 1;
				if (do_tx_analog_reconfig) tx_analog_reconfig_req <= 1;
				if (do_rx_reconfig) rx_reconfig_req <= 1;

				test_state <= WAIT_FOR_ACK;
			end

			WAIT_FOR_ACK:
			begin
				if (rx_reconfig_ack || tx_reconfig_ack || tx_analog_reconfig_ack) 
				begin
					rx_reconfig_req <= 0;
					tx_reconfig_req <= 0;
					tx_analog_reconfig_req <=0;

					test_state <= WAIT_FOR_BUSY_LOW;
				end
			end

			WAIT_FOR_BUSY_LOW:
			begin
				if (~rx_reconfig_busy && ~tx_reconfig_busy && ~tx_analog_reconfig_busy) begin
					reconfigs <= reconfigs + 1;
					test_state <= GET_DATA;
				end
			end

		endcase
	end

	always @ (negedge clk) begin
		// Check the current address and writedata vs the expected
		if (mgmt_write) begin
			if (mgmt_address != mgmt_address_expected[writes]) begin
				$display ("Unexpected address %h:%h at time %d", mgmt_address, mgmt_address_expected[writes], $time);
				fail <= 1;
			end

			if (mgmt_writedata != mgmt_writedata_expected[writes]) begin
				$display ("Unexpected write data %h:%h at time %d", mgmt_writedata, mgmt_writedata_expected[writes], $time);
				fail <= 1;
			end

			writes <= writes + 1;
		end	
	end

	initial begin
		clk = 0;
		fail = 0;
		writes = 0;
		reconfigs = 0;
		rx_reconfig_req =0;
		tx_reconfig_req =0;
		tx_analog_reconfig_req =0;
		test_state = WAIT_FOR_BUSY_LOW;

		for (n=0; n < TOTAL_WRITES; n=n+1) begin
			mgmt_address_expected[n] = 7'h00;
			mgmt_writedata_expected[n] = 0;
		end
			

		// Pulse reset at start up
		reset = 1;
		#100
		reset = 0;

		test_state = GET_DATA;

		// Run for a while and see what we got
		#1000000 if (!fail) $display ("PASS: Completed %d reconfigurations", reconfigs);
		$stop();
	end

	// *********************************************************************
	//
	// This task calculates the expected write data that should come from the 
	// reconfig FSM
	//
	// *********************************************************************
	task calculate_expected_data;
	begin
		write_index = 0;

		// First calculate RX values
		if (~rx_suppress_req) begin
			for (n=0; n < RX_LANES; n=n+1)
			begin
        //***************************************************
				// PLL reconfig IP for Rx Refclk switch
        //***************************************************
			  // logical channel
       	mgmt_address_expected[write_index] = 7'h40;
				mgmt_writedata_expected[write_index] = n;
				write_index = write_index + 1;
			
				// CDR REFCLK feature
				mgmt_address_expected[write_index] = 7'h43;
				mgmt_writedata_expected[write_index] = 32'h0000_0000; 
				write_index = write_index + 1;
			
				// CDR REFCLK data
				mgmt_address_expected[write_index] = 7'h44;
        if (rx_link_rate == 2'b10) //HBR2
				  mgmt_writedata_expected[write_index] = 32'h0000_0001; //Refclk index = 1
        else if (rx_link_rate == 2'b01) //HBR
				  mgmt_writedata_expected[write_index] = 32'h0000_0001; //Refclk index = 1
        else //RBR
				  mgmt_writedata_expected[write_index] = 32'h0000_0000; //Refclk index = 0
				write_index = write_index + 1;
			
				// CDR CS write
				mgmt_address_expected[write_index] = 7'h42;
				mgmt_writedata_expected[write_index] = 32'h0000_0001;
				write_index = write_index + 1;

        //*******************************************************
				// MIF streamer IP (mode 1) for CDR counter values (M,L)
        //*******************************************************
        // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // CDR counter offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_000C;
				write_index = write_index + 1;
			
				// CDR counter value - direct write
				mgmt_address_expected[write_index] = 7'h3C;
        if (rx_link_rate == 2'b10) //HBR2
  				mgmt_writedata_expected[write_index] = 32'h0000_5500; 
        else if (rx_link_rate == 2'b01) //HBR
  				mgmt_writedata_expected[write_index] = 32'h0000_5600; 
        else //RBR
  				mgmt_writedata_expected[write_index] = 32'h0000_5600; 
				write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;

        //*******************************************************
				// MIF streamer IP (mode 1) for CDR counter values (N)
        //*******************************************************
        // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // CDR counter offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_000E;
				write_index = write_index + 1;
			
				// CDR counter value - direct write
				mgmt_address_expected[write_index] = 7'h3C;
  			mgmt_writedata_expected[write_index] = 32'h0000_0D60; 
				write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;

        //***************************************************
				// MIF streamer IP (mode 1) for Eye monitor values
        //***************************************************
        // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // Eye monitor offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_0016;
				write_index = write_index + 1;
    
        // Eye Monitor value - direct write
				mgmt_address_expected[write_index] = 7'h3C;
        if (rx_link_rate == 2'b10) //HBR2
  				mgmt_writedata_expected[write_index] = 32'h0000_0496; 
       else if (rx_link_rate == 2'b01) //HBR
  				mgmt_writedata_expected[write_index] = 32'h0000_0496; 
        else //RBR
  				mgmt_writedata_expected[write_index] = 32'h0000_0296; 
				write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;

			end
		end

		// The calculate TX values
		if (~tx_suppress_req) begin
			// This instantiation puts the TX channels before the TX PLLs
			n=0;
			while (n < TX_LANES)
			begin
        //***************************************************
        //Analog reconfig IP for VOD 
        //***************************************************
        // logical channel
				mgmt_address_expected[write_index] = 7'h08;
				mgmt_writedata_expected[write_index] = n + RX_LANES;
				write_index = write_index + 1;
			
				// VOD feature
				mgmt_address_expected[write_index] = 7'h0B;
				mgmt_writedata_expected[write_index] = 0;
				write_index = write_index + 1;
			
				// VOD data
				mgmt_address_expected[write_index] = 7'h0C;
				mgmt_writedata_expected[write_index] = vod_mapped[6*n +: 6];
				write_index = write_index + 1;
			
				// VOD CSR write
				mgmt_address_expected[write_index] = 7'h0A;
				mgmt_writedata_expected[write_index] = 32'h0000_0001;
				write_index = write_index + 1;

        //***************************************************
        // Analog reconfig IP for EMP 
        //***************************************************
        // logical channel
				mgmt_address_expected[write_index] = 7'h08;
				mgmt_writedata_expected[write_index] = n + RX_LANES;
				write_index = write_index + 1;
			
				// EMP feature
				mgmt_address_expected[write_index] = 7'h0B;
				mgmt_writedata_expected[write_index] = 2;
				write_index = write_index + 1;
			
				// EMP data
				mgmt_address_expected[write_index] = 7'h0C;
				mgmt_writedata_expected[write_index] = emp_mapped[5*n +: 5];
				write_index = write_index + 1;
			
				// EMP CSR write
				mgmt_address_expected[write_index] = 7'h0A;
				mgmt_writedata_expected[write_index] = 32'h0000_0001;
				write_index = write_index + 1;
        
        //***************************************************
        // MIF mode 1 for Tx CGB divider value - direct write
        //***************************************************
			  // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n + RX_LANES;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // CGB divider offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_0000;
				write_index = write_index + 1;

        // CGB divider value - direct write
        mgmt_address_expected[write_index] = 7'h3C;
        if (tx_link_rate == 2'b10) //HBR2
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_2838; 
        else if (tx_link_rate == 2'b01) //HBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_2A38; 
        else //RBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_2838; 
			 	write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;
 
        //***************************************************
        // MIF mode 1 for Tx slew values  - direct write
        //***************************************************
			  // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n + RX_LANES;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // Tx slew offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_0002;
				write_index = write_index + 1;

        // Tx slew value - direct write
        mgmt_address_expected[write_index] = 7'h3C;
        if (tx_link_rate == 2'b10) //HBR2
  		  	mgmt_writedata_expected[write_index] = 32'h0000_80D4; 
        else if (tx_link_rate == 2'b01) //HBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_8094; 
        else //RBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_8094; 
				write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;

        //***************************************************
        // MIF mode 1 for Tx VCM values  - direct write
        //***************************************************
			  // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n + RX_LANES;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // Tx VCM offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // Tx vcm value - direct write
        mgmt_address_expected[write_index] = 7'h3C;
        if (tx_link_rate == 2'b10) //HBR2
  		  	mgmt_writedata_expected[write_index] = 32'h0000_03C0; 
        else if (tx_link_rate == 2'b01) //HBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_03C0; 
        else //RBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_06C0; 
				write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;

				// Increment for next loop
				n = n+1;
			end

			// The TX PLL values
			n=0;
			while (n < TX_LANES)
			begin
        //***************************************************
        // PLL reconfig IP for refclk switching of the Tx PLL
        //***************************************************
				// logical channel
				mgmt_address_expected[write_index] = 7'h40;
				mgmt_writedata_expected[write_index] = n + RX_LANES + TX_LANES;
				write_index = write_index + 1;
			
				// REFCLK feature
				mgmt_address_expected[write_index] = 7'h43;
				mgmt_writedata_expected[write_index] = 32'h0000_0000;
				write_index = write_index + 1;
			
				// REFCLK data
				mgmt_address_expected[write_index] = 7'h44;
				if (tx_link_rate == 2'b10) //HBR2
				  mgmt_writedata_expected[write_index] = 32'h0000_0001; //Refclk index = 1
        else if (tx_link_rate == 2'b01) //HBR
				  mgmt_writedata_expected[write_index] = 32'h0000_0001; //Refclk index = 1
        else //RBR
				  mgmt_writedata_expected[write_index] = 32'h0000_0000; //Refclk index = 0
        write_index = write_index + 1;
			
				// PLL CSR write
				mgmt_address_expected[write_index] = 7'h42;
				mgmt_writedata_expected[write_index] = 32'h0000_0001;
				write_index = write_index + 1;

        //****************************************************************
        // MIF mode 1 for Tx CMU PLL counter values (M,L)  - direct write
        //****************************************************************
			  // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n + RX_LANES + TX_LANES;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // Tx CMU PLL counter offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_000C;
				write_index = write_index + 1;

        // Tx CMU PLL counter value - direct write
        mgmt_address_expected[write_index] = 7'h3C;
        if (tx_link_rate == 2'b10) //HBR2
  		  	mgmt_writedata_expected[write_index] = 32'h0000_5401; 
        else if (tx_link_rate == 2'b01) //HBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_5401; 
        else //RBR
  		 	  mgmt_writedata_expected[write_index] = 32'h0000_3801; 
				write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;

        //***********************************************************
				// MIF streamer IP (mode 1) for TX CMU PLL counter values (N)
        //***********************************************************
        // logical channel
				mgmt_address_expected[write_index] = 7'h38;
				mgmt_writedata_expected[write_index] = n + RX_LANES + TX_LANES;
				write_index = write_index + 1;
			
				// Enable Mode 1
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0004;
				write_index = write_index + 1;

        // CDR counter offset - direct write
				mgmt_address_expected[write_index] = 7'h3B;
				mgmt_writedata_expected[write_index] = 32'h0000_000E;
				write_index = write_index + 1;
			
				// CDR counter value - direct write
				mgmt_address_expected[write_index] = 7'h3C;
  			mgmt_writedata_expected[write_index] = 32'h0000_0D60; 
				write_index = write_index + 1;
			
				// Mif Mode 1 - write operation that would propagate the direct writes through to the XCVR
				mgmt_address_expected[write_index] = 7'h3A;
				mgmt_writedata_expected[write_index] = 32'h0000_0005;
				write_index = write_index + 1;

				// Increment for next loop
				n = n+1;
			end
		end
	end
	endtask

endmodule

// *********************************************************************
//
// reconfig_model.v
// 
// Description
// 
// This is a simple behavioral model of the reconfig controller used 
// for simulation testing.
//
// *********************************************************************
module reconfig_model (

	input wire clk,
	input wire reset,

	input wire [6:0] mgmt_address,
	input wire [31:0] mgmt_writedata,
	input wire mgmt_write,				
	output reg mgmt_waitrequest,		
	output reg reconfig_busy
	
);

	// State variables
	localparam	IDLE = 0, WRITE = 1, START_BUSY = 2, END_BUSY = 3;
								
	reg [1:0] state;
	integer writes;

	always @ (posedge clk or posedge reset) begin : STATE_REG
		if (reset) begin
			
			state <= IDLE;
			
			// Initialize the outputs to 0
			mgmt_waitrequest	<= 1'b0;
			reconfig_busy	    <= 1'b0;
			writes				<= 0;
		end
		else
			case (state)
			IDLE:
				begin
					mgmt_waitrequest	<= 1'b0;
					reconfig_busy	    <= 1'b0;
					writes				<= 0;

					// When we see a write increment the write counter and move to WRITE state
					if (mgmt_write)
					begin
						writes			<= writes + 1;
						state			<= WRITE;
					end
				end
			
			WRITE: 
				// Wait for 4 writes and then set the busy flag
				if (mgmt_write)
				begin
					if (writes < 3) writes <= writes + 1;
					else			state  <= START_BUSY;
				end
				
		
			START_BUSY:
				begin
					reconfig_busy	<= 1'b1;	
					state			<= END_BUSY;
				end
		
			END_BUSY:
				begin
					reconfig_busy	<= 1'b0;	
					state			<= IDLE;
				end
			endcase
	end
endmodule
*/
// synthesis translate_on

`default_nettype wire
