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
// transciever PHY. Addresses common case of 2 modules to be stitched together:
//	- 'top' PHY channel blocks (includes reset control, CSR, ...)
//	- dynamic reconfiguration block
//
// Authors:     dunnikri    19-Aug-2010
//
//              Copyright (c) Altera Corporation 1997 - 2010
//              All rights reserved.
//
//
//-----------------------------------------------------------------------------

`timescale 1 ns / 1 ns

module alt_xcvr_mgmt2dec_phyreconfig ( 

	// user-visible external management interface
	input  wire        mgmt_clk_reset,
	input  wire        mgmt_clk,
	
	input  wire [8:0]  mgmt_address,
	input  wire        mgmt_read,
	output reg  [31:0] mgmt_readdata = ~32'd0,
	output reg         mgmt_waitrequest = 0,
	input  wire        mgmt_write,

	// internal interface to xaui phy block
	output wire [7:0]  sc_phy_address,
	output wire        sc_phy_read,
	input  wire [31:0] sc_phy_readdata,
	input  wire        sc_phy_waitrequest,
	output wire        sc_phy_write,

	// internal interface to reconfig block
	output wire [6:0]  sc_reconf_address,
	output wire        sc_reconf_read,
	input  wire [31:0] sc_reconf_readdata,
	input  wire        sc_reconf_waitrequest,
	output wire        sc_reconf_write	
);
	localparam width_swa = 7;	// word address width of interface to slaves (2 for phy and 1 for reconfig)
	localparam dec_count = 2;	// count of the total number of sub-components that can act
					// as slaves to the mgmt interface
	localparam dec_sc_phy = 0;	// 
	localparam dec_reconf = 1;	// 

	///////////////////////////////////////////////////////////////////////
	// Decoder for multiple slaves of reconfig_mgmt interface
	///////////////////////////////////////////////////////////////////////
	wire [dec_count-1:0] r_decode;  //1-hot encoding

	//-----------------------Memory Map Reference-------------------------	
	//--------------------------------------------------------------------
	//Block 			| Word Address  |	Byte Address |
 	//-------------------------------------------------------------------
	//PHY Common			| 0x0		|	0x0	     |	
	//PMA Controller		| 0x20		|	0x80	     |
	//Reset Controller		| 0x40		|	0x100 	     |
	//PMA Channel Controller	| 0x60		|	0x180	     |
	//PCS				| 0x80		|	0x200	     |
	//XCVR Reconfig			| 0x100		|	0x400	     |
	//--------------------------------------------------------------------
	
	//Decoding is based on memory map word address	
	assign r_decode = 
		  (mgmt_address[8:width_swa+1] == dec_sc_phy) ? (({dec_count-dec_sc_phy{1'b0}} | 1'b1) << dec_sc_phy)
		: (mgmt_address[8:width_swa] == 2'd2) ? (({dec_count-dec_reconf{1'b0}} | 1'b1) << dec_reconf)
		: {dec_count{1'b0}};

	// reconfig_mgmt output generation is muxing of decoded slave output
	always @(*) begin
		if (r_decode[dec_sc_phy] == 1'b1) begin
			mgmt_readdata = sc_phy_readdata;
			mgmt_waitrequest = sc_phy_waitrequest;
		end else if (r_decode[dec_reconf] == 1'b1) begin
			mgmt_readdata = sc_reconf_readdata;
			mgmt_waitrequest = sc_reconf_waitrequest;
		end else begin
			mgmt_readdata = -1;
			mgmt_waitrequest = 1'b0;
		end
	end

	// internal interface to 'top' phy block
	assign sc_phy_address = mgmt_address[width_swa:0];	
	assign sc_phy_read    = mgmt_read  & r_decode[dec_sc_phy];
	assign sc_phy_write   = mgmt_write & r_decode[dec_sc_phy];

	// internal interface to 'top' reconfig block
	assign sc_reconf_address = mgmt_address[width_swa-1:0];	
	assign sc_reconf_read    = mgmt_read  & r_decode[dec_reconf];
	assign sc_reconf_write   = mgmt_write & r_decode[dec_reconf];

endmodule
