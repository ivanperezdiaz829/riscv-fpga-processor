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


`ifndef DEFAULT_TEST_PARAMS_PKT__SV
`define DEFAULT_TEST_PARAMS_PKT__SV

// Package defines Avalon-MM and Avalon-ST interface parameters for BFM
package default_test_params_pkt;
    
    // Length/Type
	parameter LENGTH_TYPE_PTP		= 16'h88F7;
	parameter LENGTH_TYPE_IPV4		= 16'h0800;
	parameter LENGTH_TYPE_IPV6		= 16'h86DD;
	parameter LENGTH_TYPE_VLAN      = 16'h8100;                 // VLAN Length/Type field

	//vlan info
	parameter NO_VLAN  = 0;
	parameter VLAN  = 1;
	parameter STACK_VLAN  = 2;
	
    // Parameter definition for MAC configuration
    parameter INVALID_ADDR          = 48'h00_00_00_00_00_00;    
    parameter MAC_ADDR              = 48'hEE_CC_88_CC_AA_EE;
    
    parameter INSERT_PAD            = 1;
    parameter NO_INSERT_PAD         = 0;
    parameter INSERT_CRC            = 1;	
    parameter NO_INSERT_CRC         = 0;		
	
    // IP Protocol
    parameter PROTOCOL_UDP         = 8'h11;                    // UDP Protocol field
	
    // UDP Port
    parameter UDP_PORT_PTP_EVENT   = 16'd319;                  // UDP Port for PTP event messages
	parameter UDP_PORT_PTP_MISC    = 16'd320;                  // UDP Port for PTP non-event messages	
    
    // Message Type
    parameter MSG_SYNC = 4'h0;
    parameter MSG_DELAY_REQ = 4'h1;
    parameter MSG_PDELAY_REQ = 4'h2;
    parameter MSG_PDELAY_RESP = 4'h3;
    parameter MSG_MISC = 4'h4;

	//clock operation mode
    parameter ORDINARY_CLOCK				= 2'h0;
    parameter BOUNDARY_CLOCK				= 2'h1;
    parameter E2E_TRANSPARENT_CLOCK			= 2'h2;
    parameter P2P_TRANSPARENT_CLOCK			= 2'h3;	
	
	parameter SEQUENCE_ID_W			= 16;						//2 octet
	parameter CORRECTION_FIELD_W	= 64;						//8 octet

	parameter PERIOD_NSECOND	= 16'h6;
	parameter PERIOD_FNSECOND	= 16'h6666;
	parameter ADJUST_NSECOND	= 16'h0;
	parameter ADJUST_FNSECOND	= 16'h0;
	parameter PHY_DELAY_CYCLE	= 12'b0;            // CYCLE (6bits) + FCYCLE (6bits)
	
    parameter PTP_ONE_STEP      = 1'b0;
    parameter PTP_TWO_STEP      = 1'b1;
    
    parameter PTP_TIMESTAMP_FORMAT_96B  = 1'b0;
    parameter PTP_TIMESTAMP_FORMAT_64B  = 1'b1;
	


endpackage

`endif
