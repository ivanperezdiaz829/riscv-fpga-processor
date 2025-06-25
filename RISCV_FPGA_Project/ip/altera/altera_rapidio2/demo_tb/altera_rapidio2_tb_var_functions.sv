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


// Package Declartion
package altera_rapidio2_tb_var_functions;
parameter DEVICE_FAMILY    ="Stratix V";
parameter SUPPORTED_MODES    ="4x,2x,1x";
parameter SUPPORT_4X    = 1'b1;
parameter SUPPORT_2X    = 1'b1;
parameter SUPPORT_1X    = 1'b1;
parameter LSIZE    =4;
parameter MAX_BAUD_RATE    =6250;
parameter REF_CLK_FREQ    ="156.25";
parameter ENABLE_TRANSPORT_LAYER    = 1'b1;
parameter TRANSPORT_LARGE    =1'b0 ;
parameter PASS_THROUGH    = 1'b1;
parameter PROMISCUOUS    =1'b0 ;
parameter MAINTENANCE_GUI    = 1'b1;
parameter MAINTENANCE_ADDRESS_WIDTH    =26;
parameter PORT_WRITE_TX_GUI    =1'b0 ;
parameter PORT_WRITE_RX_GUI    =1'b0 ;
parameter DOORBELL_GUI    = 1'b1;
parameter IO_SLAVE_DOORBELL_WRITES_ORDER_PRESERVATION    =1'b0 ;
parameter IO_MASTER_GUI    = 1'b1;
parameter IO_MASTER_WINDOWS    =1;
parameter IO_MASTER_ADDRESS_WIDTH    =32;
parameter IO_SLAVE_GUI    = 1'b1;
parameter IO_SLAVE_WINDOWS    =1;
parameter IO_SLAVE_ADDRESS_WIDTH    =32;
parameter ERROR_MANAGEMENT_EXTENSION    = 1'b1;
parameter XCVR_RESET_CTRL    =1'b0 ;
parameter SYS_CLK_FREQ    ="156.25";
parameter SYS_CLK_PERIOD    =6400;
parameter REF_CLK_PERIOD    =6400;
parameter MAINTENANCE    = 1'b1;
parameter MAINTENANCE_MASTER    = 1'b1;
parameter MAINTENANCE_SLAVE    = 1'b1;
parameter PORT_WRITE_TX    =1'b0 ;
parameter PORT_WRITE_RX    =1'b0 ;
parameter DOORBELL    = 1'b1;
parameter DOORBELL_TX_ENABLE    = 1'b1;
parameter DOORBELL_RX_ENABLE    = 1'b1;
parameter IO_MASTER    = 1'b1;
parameter IO_SLAVE    = 1'b1;
parameter REF_CLK_FREQ_WITH_UNIT    ="156.25 MHz";
parameter MAX_BAUD_RATE_WITH_UNIT    ="6250 Mbps";
endpackage
