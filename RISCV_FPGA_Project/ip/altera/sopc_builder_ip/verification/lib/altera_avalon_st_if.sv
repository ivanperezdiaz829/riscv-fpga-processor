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


// $Id: //acds/rel/13.1/ip/sopc/components/verification/lib/altera_avalon_st_if.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
//-----------------------------------------------------------------------------
// Avalon Streaming Protocol Interface
//-----------------------------------------------------------------------------
`timescale 1ns / 1ns

interface altera_avalon_st_if
#(
  parameter ST_SYMBOL_W    = 8,
  parameter ST_NUMSYMBOLS  = 4,
  parameter ST_CHANNEL_W   = 0,
  parameter ST_ERROR_W     = 0,
  parameter ST_EMPTY_W     = 0,
  
  parameter USE_PACKET     = 0,   
  parameter USE_CHANNEL    = 0,   
  parameter USE_ERROR      = 0,   
  parameter USE_READY      = 1,   
  parameter USE_VALID      = 1,       
  parameter USE_EMPTY      = 0
)
(
    input bit clk,
    input bit reset
);

   localparam ST_DATA_W        = ST_SYMBOL_W * ST_NUMSYMBOLS;
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction   

   logic                             ready;
   logic                             valid;
   logic                             startofpacket;
   logic                             endofpacket;
   logic [lindex(ST_DATA_W)    : 0]  data;
   logic [lindex(ST_CHANNEL_W) : 0]  channel;
   logic [lindex(ST_ERROR_W)   : 0]  error;
   logic [lindex(ST_EMPTY_W)   : 0]  empty;       
 
   modport source (
    	   input  ready,
    	   output valid,
    	   output startofpacket,
    	   output endofpacket,
   	   output empty,
   	   output data,
   	   output channel,
   	   output error
   	   );
 
   modport sink (
          output ready,
          input  valid,
          input  startofpacket,
          input  endofpacket,
          input  empty,
          input  data,
          input  channel,
          input  error
   		   );
   
endinterface 
