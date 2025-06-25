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


////////////////////////////////////////////////
////// file name:  channel_sel.sv
//
//     fileset: 5/29/2013
//     version 0.5
//
////// purpose  :  this modules calculates the logical channel address and selects the active AN/LT ports based	
////// this connects to the arbiter
//////

`timescale 1ps/1ps


module channel_sel #(
   parameter CHANNELS   = 12,				// total number of channels used in the design
   parameter PLLs       = 6,				// total number of PLL used in the design
   parameter MAP_PLLS   = 1,				// setting of 1 = takes pll address into account for logical channel calculation, 0 = PLL address not used in LC addr calculation.
   parameter WIDTH_CH   = altera_xcvr_functions::clogb2(CHANNELS-1)
	
) (

   input                         clk,              // added just in case we need to pipeline
   input                         reset,            // added just in case we need to pipeline


		
   input       [CHANNELS*6-1:0]  seq_pcs_mode,
   input       [CHANNELS*6-1:0]  seq_pma_vod,
   input       [CHANNELS*5-1:0]  seq_pma_posttap1,
   input       [CHANNELS*4-1:0]  seq_pma_pretap,

   input       [CHANNELS*3-1:0]  tap_to_upd,

   input       [WIDTH_CH-1:0]    rcfg_chan_select,
	
   output reg  [5:0]             pma_vod_out,
   output reg  [4:0]             pma_post_out,
   output reg  [3:0]             pma_pre_out,
   output reg  [5:0]             seq_pcs_mode_out,
   output reg  [2:0]             tap_to_upd_out,
	
   output reg  [31:0]            lc_address_out,    // size of AVMM write data port

// for DFE reconfig support
   input [CHANNELS*2-1:0]     	dfe_mode,   
   output reg  [1:0]            dfe_mode_out,
   
   
// for CTLE reconfig support
   input [CHANNELS*4-1:0]       ctle_rc,
   input [CHANNELS*2-1:0]       ctle_mode,
   output reg [3:0]             ctle_rc_out,
   output reg [1:0]             ctle_mode_out
   
);



// The following calculates the logical channel address based on the channel selected and depends on the amount of PLLs selected
// The logical channel address output (lc_address_out will be used to write the logical channel address to the reconfig controller 
// example of the logical channel number assignment with 2 PLLs per channel instance:
//	ch1 PLL2		- lc5
// ch1 PLL1		- lc4
//	ch1 channel - lc3
// ch0 PLL2		- lc2
// ch0 PLL1		- lc1
// ch0 channel - lc0

   assign lc_address_out = MAP_PLLS ? rcfg_chan_select *(PLLs+1) : rcfg_chan_select;



////////////////////////// mux select /////////////////////
//  The following selection selects the value of the channel that is active (based on rcfg_chan_select)

   assign seq_pcs_mode_out =  seq_pcs_mode[rcfg_chan_select*6+:6];
   assign tap_to_upd_out   =  tap_to_upd[rcfg_chan_select*3+:3];

   assign pma_vod_out      =  seq_pma_vod[rcfg_chan_select*6+:6];
   assign pma_post_out     =  seq_pma_posttap1[rcfg_chan_select*5+:5];
   assign pma_pre_out      =  seq_pma_pretap[rcfg_chan_select*4+:4];

   assign dfe_mode_out     =  dfe_mode[rcfg_chan_select*2+:2];

   assign ctle_rc_out      =  ctle_rc[rcfg_chan_select*4+:4];
   assign ctle_mode_out    =  ctle_mode[rcfg_chan_select*2+:2];

endmodule
