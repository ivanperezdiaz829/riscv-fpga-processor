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


//-----------------------------------------------------------------------------
//
// Description: Custom management interface address decoder for Altera
// transciever PHY. Addresses common case of 3 modules to be stitched together:
//	- CSR, Alt_PMA controller, Alt_PMA_Channel controller
//
// Authors:     dunnikri    19-Aug-2010
//
//              Copyright (c) Altera Corporation 1997 - 2010
//              All rights reserved.
//
//
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module alt_xcvr_mgmt2dec_xaui ( 

	// user-visible external management interface
	input  wire        mgmt_clk_reset,
	input  wire        mgmt_clk,
	
	input  wire [7:0]  mgmt_address,
	input  wire        mgmt_read,
	output reg  [31:0] mgmt_readdata = ~32'd0,
	output reg         mgmt_waitrequest = 0,
	input  wire        mgmt_write,

	// internal interface to xaui pma channel controller 
	output wire [5:0]  sc_pma_ch_controller_address,
	output wire        sc_pma_ch_controller_read,
	input  wire [31:0] sc_pma_ch_controller_readdata,
	input  wire        sc_pma_ch_controller_waitrequest,
	output wire        sc_pma_ch_controller_write,

	// internal interface to pma controller block
	output wire [1:0]  sc_pma_controller_address,
	output wire        sc_pma_controller_read,
	input  wire [31:0] sc_pma_controller_readdata,
	input  wire        sc_pma_controller_waitrequest,
	output wire        sc_pma_controller_write,

	// internal interface to hxaui csr block
	output wire [4:0]  sc_csr_address,
	output wire        sc_csr_read,
	input  wire [31:0] sc_csr_readdata,
	input  wire        sc_csr_waitrequest,
	output wire        sc_csr_write
);
	localparam width_swa = 7;	// word address width of interface to slaves (2 for phy and 1 for reconfig)
	localparam dec_count = 3;	// count of the total number of sub-components that can act
					// as slaves to the mgmt interface

	localparam dec_pma_control    = 0;      
	localparam dec_csr 	      = 1;	
	localparam dec_pma_ch_control = 2;	

	//--------------------------------------------------------------------
	//Block 			| Word Address  |	Byte Address |
 	//-------------------------------------------------------------------
	//PHY Common			| 0x0		|	0x0	     |	
	//PMA Controller		| 0x20		|	0x80	     |
	//Reset Controller		| 0x40		|	0x100 	     |
	//PMA Channel Controller	| 0x60		|	0x180	     |
	//PCS				| 0x80		|	0x200	     |
	//XCVR Reconfig			| 0x100		|	0x400	     |
	//-------------------------------------------------------------------
	
	
	///////////////////////////////////////////////////////////////////////
	// Decoder for multiple slaves of reconfig_mgmt interface
	///////////////////////////////////////////////////////////////////////
	wire [dec_count-1:0] r_decode;  //1-hot encoding
	
	//PMA Controller     - 0x20 (0010 0000)
	//Reset Controller   - 0x40 (0100 0000)
	//Channel Controller - 0x60 (0110 0000)
	//PCS                - 0x80 (1000 0000)
	//Consider first 3 MSBs for decoding
	/*assign r_decode = 
		    (mgmt_address[7:5] == 3'd1)  ? (({dec_count-dec_pma_control{1'b0}} | 1'b1) << dec_pma_control)
  		  : (mgmt_address[7:5] == 3'd4)  ? (({dec_count-dec_csr{1'b0}} | 1'b1) << dec_csr)
		  : (mgmt_address[7:5] == 3'd3)  ? (({dec_count-dec_pma_ch_control{1'b0}} | 1'b1) << dec_pma_ch_control)
		  : {dec_count{1'b0}};*/
		  
	assign r_decode[0] = (!mgmt_address[7]) & (!mgmt_address[6]) & (mgmt_address[5]);
	assign r_decode[1] = (mgmt_address[7]) & (!mgmt_address[6]) & (!mgmt_address[5]);
	assign r_decode[2] = (!mgmt_address[7]) & (mgmt_address[6]);
		  

	always @(*) begin
		if (r_decode[dec_pma_ch_control] == 1'b1) begin
			mgmt_readdata = sc_pma_ch_controller_readdata;
			mgmt_waitrequest = sc_pma_ch_controller_waitrequest;
		end else if (r_decode[dec_pma_control] == 1'b1) begin
			mgmt_readdata = sc_pma_controller_readdata;
			mgmt_waitrequest = sc_pma_controller_waitrequest;
		end else if (r_decode[dec_csr] == 1'b1) begin
			mgmt_readdata = sc_csr_readdata;
			mgmt_waitrequest = sc_csr_waitrequest;
		end else begin
			mgmt_readdata = -1;
			mgmt_waitrequest = 1'b0;
		end
	end

	// internal interface to alt_pma_ch_control block
	assign sc_pma_ch_controller_address = mgmt_address[5:0];  //6 bit address
	assign sc_pma_ch_controller_read    = mgmt_read  & r_decode[dec_pma_ch_control];
	assign sc_pma_ch_controller_write   = mgmt_write & r_decode[dec_pma_ch_control];

	// internal interface to pma_control block
	assign sc_pma_controller_address  = mgmt_address[1:0];  // 2 bit address
	assign sc_pma_controller_read 	  = mgmt_read  & r_decode[dec_pma_control];
	assign sc_pma_controller_write 	  = mgmt_write & r_decode[dec_pma_control];

	// internal interface to csr block
	assign sc_csr_address 		 = mgmt_address[4:0];	// 5 bit address
	assign sc_csr_read 		 = mgmt_read  & r_decode[dec_csr];
	assign sc_csr_write 		 = mgmt_write & r_decode[dec_csr];
endmodule
