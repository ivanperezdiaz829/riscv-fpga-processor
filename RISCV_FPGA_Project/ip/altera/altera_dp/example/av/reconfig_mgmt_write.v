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
// reconfig_mgmt_write.v
// 
// Description
// 
// This module is responsible for generating the control signals to perform
// a single reconfiguration write operation on the AV-MM interface to
// the XCVR reconfiguration controller. 
//
// This is done with a simple state machine that steps through the low-leve
// commands to write to the reconfiguration controller. 
//
// *********************************************************************

// synthesis translate_off
`timescale 1ns / 1ns
// synthesis translate_on
`default_nettype none

module reconfig_mgmt_write (

	input wire clk,								// This should be the same 100MHz clock driving the reconfig controller
	input wire reset,							// This should be the same reset driving the reconfig controller

	input wire start_reconfig,					// high pulse starts reconfig with the values defined below
	input wire [6:0] logical_ch_address,		// specifies address for the logical channel
	input wire [3:0] logical_ch_num,			// specifies which logical channel number
	input wire [6:0] feature_offset_address,	// specifies address for the feature offset
	input wire [5:0] feature_offset_val,		// specifies the offset feature value
	input wire [6:0] data_address,				// specifies address for the data offset
	input wire [31:0] data_val,					// specifies the offset data value
	input wire [6:0] cs_address,				// specifies address of control and status register
	input wire       mif_mode_1,				//specifies if Mode=1 of the MIF streamer IP is used		
	output reg [6:0] mgmt_address,				// connect to reconfig_mgmt_address of reconfig controller
	output reg [31:0] mgmt_writedata,			// connect to reconfig_mgmt_writedata of reconfig controller
	output reg mgmt_write,						// connect to reconfig_mgmt_write of reconfig controller
	input wire mgmt_waitrequest,				// connect to reconfig_mgmt_waitrequest of reconfig controller
	input wire reconfig_busy					// connect to reconfig_busy of reconfig controller
	
);

	// State variables
	localparam	IDLE					= 0,
				WRITE_CH				= 1,
				WRITE_MIF_MODE_1		= 2,
				WRITE_FEATURE_OFFSET	= 3,
				WRITE_DATA_VALUE		= 4,
				WRITE_DATA				= 5,
				END_RECONFIG			= 6;
				
	// Write value
	localparam MIF_MODE_1_VAL = 32'b0000_0000_0000_0100;
				
	reg [2:0] state;

	always @ (posedge clk or posedge reset) begin : STATE_REG
		if (reset) begin
			
			state <= IDLE;
			
			// Initialize the outputs to 0
			mgmt_address	<= 7'h0;
			mgmt_write	    <= 1'h0;
			mgmt_writedata  <= 32'h0;
		end
		else
			case (state)
			IDLE:
				begin
					mgmt_write	<= 1'b0;	
					if (start_reconfig && !reconfig_busy) state <= WRITE_CH;
				end
			
			WRITE_CH: 
				if (!mgmt_waitrequest) begin
					mgmt_address	<= logical_ch_address;
					mgmt_writedata	<= logical_ch_num;	
					mgmt_write		<= 1'b1;	
					
					if (mif_mode_1 == 1'b1)
						state		<= WRITE_MIF_MODE_1;
					else
						state		<= WRITE_FEATURE_OFFSET;
				end

			WRITE_MIF_MODE_1: 
				if (!mgmt_waitrequest) begin
					mgmt_address	<= cs_address;
					mgmt_writedata	<= MIF_MODE_1_VAL;	
					mgmt_write		<= 1'b1;	
					state			<= WRITE_FEATURE_OFFSET;
				end

			WRITE_FEATURE_OFFSET:
				if (!mgmt_waitrequest) begin
					mgmt_address	<= feature_offset_address;
					mgmt_writedata	<= feature_offset_val;	
					mgmt_write		<= 1'b1;	
					state			<= WRITE_DATA_VALUE;
				end
		
			WRITE_DATA_VALUE:
				if (!mgmt_waitrequest) begin
					mgmt_address	<= data_address;
					mgmt_writedata	<= data_val;	
					mgmt_write		<= 1'b1;	
					state			<= WRITE_DATA;
				end
		
			WRITE_DATA:
				if (!mgmt_waitrequest ) begin
					mgmt_address	<= cs_address;
					mgmt_writedata	<= (mif_mode_1 == 1'b1) ? (MIF_MODE_1_VAL | 32'h1) : 32'h1;	
					mgmt_write		<= 1'b1;	
					state			<= END_RECONFIG;
				end
		
			END_RECONFIG:
				begin
					mgmt_write		<= 1'b0;	
					state			<= IDLE;
				end
			endcase
	end
endmodule


`default_nettype wire
