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


// (C) 2001-2011 Altera Corporation. All rights reserved.
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


///////////////////////////////////////////////////////////////////////////////
//
//
// Description: Hard xaui control and status registers header file
//
// Authors:     ishimony    12-Jun-2009
//
//              Copyright (c) Altera Corporation 1997 - 2009
//              All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps

package  hxaui_csr_h;


// address map
localparam [11:0]ALT_PMA_CONTROLLER_ADDR    =12'h080;
localparam [11:0]ALT_PMA_CH_CONTROLLER_ADDR =12'h180;
//localparam ALT_PMA_ADDR               12'h080     
localparam [11:0]ALT_RECONFIG_ANALOG_ADDR   =12'h400;
localparam [11:0]ALT_RECONFIG_OC_ADDR       =12'h408;
localparam [11:0]HXAUI_CSR_ADDR             =12'h200;


// registers address -------------------------------------------------------
// preserve 7'h00 for indirection register (future implementation)
localparam [6:0]HXAUI_CSR_RESET_ADDR            =7'h04;
localparam [6:0]HXAUI_CSR_RX_CNTRL_ADDR         =7'h08;
localparam [6:0]HXAUI_CSR_TX_CNTRL_ADDR         =7'h0C;
localparam [6:0]HXAUI_CSR_RX_STATUS_0_ADDR      =7'h10;
localparam [6:0]HXAUI_CSR_RX_STATUS_1_ADDR      =7'h14;
localparam [6:0]HXAUI_CSR_RX_STATUS_2_ADDR      =7'h18;
localparam [6:0]HXAUI_CSR_RX_STATUS_3_ADDR      =7'h1C;
localparam [6:0]HXAUI_CSR_RX_STATUS_4_ADDR      =7'h20;
localparam [6:0]HXAUI_CSR_TX_STATUS_0_ADDR      =7'h24;
localparam [6:0]HXAUI_CSR_SIMULATION_FLAG_ADDR  =7'h28;

// register bitmap ---------------------------------------------------------
localparam [32:0]HXAUI_CSR_RESET_RX_DIGITAL            =32'h0000_0001;
localparam [32:0]HXAUI_CSR_RESET_TX_DIGITAL            =32'h0000_0002;

localparam [32:0]HXAUI_CSR_RX_CNTRL_INVPOLARITY_0      =32'h0000_0001;
localparam [32:0]HXAUI_CSR_RX_CNTRL_INVPOLARITY_1      =32'h0000_0002;
localparam [32:0]HXAUI_CSR_RX_CNTRL_INVPOLARITY_2      =32'h0000_0004;
localparam [32:0]HXAUI_CSR_RX_CNTRL_INVPOLARITY_3      =32'h0000_0008;

localparam [32:0]HXAUI_CSR_TX_CNTRL_INVPOLARITY_0      =32'h0000_0001;
localparam [32:0]HXAUI_CSR_TX_CNTRL_INVPOLARITY_1      =32'h0000_0002;
localparam [32:0]HXAUI_CSR_TX_CNTRL_INVPOLARITY_2      =32'h0000_0004;
localparam [32:0]HXAUI_CSR_TX_CNTRL_INVPOLARITY_3      =32'h0000_0008;

localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_0          =32'h0000_0001;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_1          =32'h0000_0002;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_2          =32'h0000_0004;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_3          =32'h0000_0008;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_4          =32'h0000_0010;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_5          =32'h0000_0020;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_6          =32'h0000_0040;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_PATTERNDETECT_7          =32'h0000_0080;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_0             =32'h0000_0100;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_1             =32'h0000_0200;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_2             =32'h0000_0400;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_3             =32'h0000_0800;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_4             =32'h0000_1000;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_5             =32'h0000_2000;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_6             =32'h0000_4000;
localparam [32:0]HXAUI_CSR_RX_STATUS_0_SYNCSTATUS_7             =32'h0000_8000;

localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_0              =32'h0000_0001;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_1              =32'h0000_0002;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_2              =32'h0000_0004;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_3              =32'h0000_0008;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_4              =32'h0000_0010;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_5              =32'h0000_0020;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_6              =32'h0000_0040;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_ERRDETECT_7              =32'h0000_0080;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_0                =32'h0000_0100;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_1                =32'h0000_0200;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_2                =32'h0000_0400;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_3                =32'h0000_0800;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_4                =32'h0000_1000;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_5                =32'h0000_2000;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_6                =32'h0000_4000;
localparam [32:0]HXAUI_CSR_RX_STATUS_1_DISPERR_7                =32'h0000_8000;

localparam [32:0]HXAUI_CSR_RX_STATUS_2_RLV_0                    =32'h0000_0001;
localparam [32:0]HXAUI_CSR_RX_STATUS_2_RLV_1                    =32'h0000_0002;
localparam [32:0]HXAUI_CSR_RX_STATUS_2_RLV_2                    =32'h0000_0004;
localparam [32:0]HXAUI_CSR_RX_STATUS_2_RLV_3                    =32'h0000_0008;
localparam [32:0]HXAUI_CSR_RX_STATUS_2_PHASE_COMP_FIFO_ERROR_0  =32'h0000_0010;
localparam [32:0]HXAUI_CSR_RX_STATUS_2_PHASE_COMP_FIFO_ERROR_1  =32'h0000_0020;
localparam [32:0]HXAUI_CSR_RX_STATUS_2_PHASE_COMP_FIFO_ERROR_2  =32'h0000_0040;
localparam [32:0]HXAUI_CSR_RX_STATUS_2_PHASE_COMP_FIFO_ERROR_3  =32'h0000_0080;

localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_0      =32'h0000_0001;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_1      =32'h0000_0002;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_2      =32'h0000_0004;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_3      =32'h0000_0008;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_4      =32'h0000_0010;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_5      =32'h0000_0020;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_6      =32'h0000_0040;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATADELETED_7      =32'h0000_0080;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_0     =32'h0000_0100;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_1     =32'h0000_0200;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_2     =32'h0000_0400;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_3     =32'h0000_0800;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_4     =32'h0000_1000;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_5     =32'h0000_2000;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_6     =32'h0000_4000;
localparam [32:0]HXAUI_CSR_RX_STATUS_3_RMFIFODATAINSERTED_7     =32'h0000_8000;

localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOFULL_0             =32'h0000_0001;
localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOFULL_1             =32'h0000_0002;
localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOFULL_2             =32'h0000_0004;
localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOFULL_3             =32'h0000_0008;
localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOEMPTY_0            =32'h0000_0010;
localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOEMPTY_1            =32'h0000_0020;
localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOEMPTY_2            =32'h0000_0040;
localparam [32:0]HXAUI_CSR_RX_STATUS_4_RMFIFOEMPTY_3            =32'h0000_0080;

localparam [32:0]HXAUI_CSR_TX_STATUS_0_PHASE_COMP_FIFO_ERROR_0  =32'h0000_0001;
localparam [32:0]HXAUI_CSR_TX_STATUS_0_PHASE_COMP_FIFO_ERROR_1  =32'h0000_0002;
localparam [32:0]HXAUI_CSR_TX_STATUS_0_PHASE_COMP_FIFO_ERROR_2  =32'h0000_0004;
localparam [32:0]HXAUI_CSR_TX_STATUS_0_PHASE_COMP_FIFO_ERROR_3  =32'h0000_0008;

localparam [32:0]HXAUI_CSR_SIMULATION_FLAG                      =32'h0000_0001;

endpackage
