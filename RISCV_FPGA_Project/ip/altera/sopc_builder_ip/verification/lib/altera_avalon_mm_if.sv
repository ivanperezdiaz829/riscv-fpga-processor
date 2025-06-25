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


// $File: //acds/main/ip/sopc/components/verification/lib/avalon_mm_if.sv#1 $
// $Revision: #1 $
// $Date: 2008/11/24 $
// $Author: $
//-----------------------------------------------------------------------------
// Avalon Memory Mapped Protocol Interface
//-----------------------------------------------------------------------------
`timescale 1ns / 1ns

import verbosity_pkg::*;
import avalon_mm_pkg::*;

 
interface altera_avalon_mm_if
  #(
     parameter AV_ADDRESS_W              = 32,
     parameter AV_SYMBOL_W               = 8,
     parameter AV_NUMSYMBOLS             = 4,
     parameter AV_BURSTCOUNT_W           = 3,  
     parameter AV_READRESPONSE_W         = 8,
     parameter AV_WRITERESPONSE_W        = 8,

     parameter USE_READ                  = 1,  
     parameter USE_WRITE                 = 1,  
     parameter USE_ADDRESS               = 1,  
     parameter USE_BYTE_ENABLE           = 1,   
     parameter USE_BURSTCOUNT            = 1,  
     parameter USE_READ_DATA             = 1,  
     parameter USE_READ_DATA_VALID       = 1,  
     parameter USE_WRITE_DATA            = 1,  
     parameter USE_BEGIN_TRANSFER        = 0,  
     parameter USE_BEGIN_BURST_TRANSFER  = 0,  
     parameter USE_WAIT_REQUEST          = 1,
     parameter USE_ARBITERLOCK           = 0,
     parameter USE_LOCK                  = 0,
     parameter USE_DEBUGACCESS           = 0,
     parameter USE_TRANSACTIONID         = 0,
     parameter USE_WRITERESPONSE         = 0,
     parameter USE_READRESPONSE          = 0,
     parameter USE_CLKEN                 = 0
   )
   (
     input bit clk,
     input bit reset
   );

   localparam AV_TRANSACTIONID_W = 8;
   localparam AV_DATA_W          = AV_SYMBOL_W * AV_NUMSYMBOLS;

   
   logic                           waitrequest;
   logic                           chipselect;
   logic                           write;
   logic                           read;
   logic [AV_ADDRESS_W-1:       0] address;
   logic [AV_NUMSYMBOLS-1:      0] byteenable;
   logic                           begintransfer;   
   logic [AV_BURSTCOUNT_W-1:    0] burstcount;
   logic                           beginbursttransfer;
   logic [AV_DATA_W-1:          0] writedata;
   logic [AV_DATA_W-1:          0] readdata;
   logic                           readdatavalid;
   logic                           arbiterlock;
   logic                           lock;
   logic                           debugaccess;   
   logic [AV_TRANSACTIONID_W-1: 0] transactionid;
   logic [AV_TRANSACTIONID_W-1: 0] readid;
   logic [AV_TRANSACTIONID_W-1: 0] writeid;
   logic [AV_READRESPONSE_W-1:  0] readresponse;
   logic [AV_WRITERESPONSE_W-1: 0] writeresponse;
   logic [1:0]                     response;
   logic                           writeresponserequest;
   logic                           writeresponsevalid;      
   logic                           clken;

   
   modport monitor (
                   input waitrequest,
                   input write,
                   input read,
                   input address,
                   input byteenable,
                   input writedata,
                   input burstcount,
                   input begintransfer,
                   input beginbursttransfer,
                   input readdata,
                   input readdatavalid,
                   input arbiterlock,
                   input lock,
                   input debugaccess,
                   input transactionid,
                   input readresponse,
                   input readid,
                   input writeresponserequest,
                   input writeresponsevalid,      
                   input writeresponse,
                   input response,
                   input writeid,
                   input clken
                   );

   modport general_slave (
                   output waitrequest,
                   input  write,
                   input  read,
                   input  address,
                   input  byteenable,
                   input  writedata,
                   input  burstcount,
                   input  beginbursttransfer,
                   input  begintransfer, 
                   output readdata,
                   output readdatavalid,
                   input  arbiterlock,
                   input  lock,
                   input  debugaccess,
                   input  transactionid,
                   output readresponse,
                   output readid,
                   input  writeresponserequest,
                   output writeresponsevalid,      
                   output writeresponse,
                   output writeid,
                   output response,
                   input clken
                   );

   modport general_master (
                   input waitrequest,
                   output write,
                   output read,
                   output address,
                   output byteenable,
                   output writedata,
                   output burstcount,
                   output beginbursttransfer,
                   output begintransfer,     
                   input  readdata,
                   input  readdatavalid,
                   output arbiterlock,
                   output lock,
                   output debugaccess,
                   output transactionid,
                   input  readresponse,
                   input  readid,
                   output writeresponserequest,
                   input  writeresponsevalid,      
                   input  writeresponse,
                   input  writeid,
                   input  response,
                   output clken
                   );
   
   modport component_burst_master(
                   input  waitrequest,
                   output write,
                   output read,
                   output address,
                   output byteenable,
                   output writedata,
                   output burstcount,
                   output beginbursttransfer,
                   input  readdata,
                   input  readdatavalid,
                   output clken
                   );
   
   modport fabric_burst_master (
                   input waitrequest,
                   output write,
                   output read,
                   output address,
                   output byteenable,
                   output writedata,
                   output burstcount,
                   output beginbursttransfer,
                   output begintransfer,     
                   input  readdata,
                   input  readdatavalid,
                   output clken
                   );

   modport component_master (
                   input  waitrequest,
                   output write,
                   output read,
                   output address,
                   output byteenable,
                   output writedata,
                   input  readdata,
                   input  readdatavalid,
                   output arbiterlock,
                   output lock,
                   output debugaccess,
                   output clken
                   );

   modport fabric_master (
                   input  waitrequest,
                   output write,
                   output read,
                   output address,
                   output byteenable,
                   output writedata,
                   output begintransfer,
                   input  readdata,
                   input  readdatavalid,
                   output clken
                   );
   
   modport component_burst_slave (
                   output waitrequest,
                   input  write,
                   input  read,
                   input  address,
                   input  byteenable,
                   input  writedata,
                   input  burstcount,
                   input  beginbursttransfer,
                   input  begintransfer, 
                   output readdata,
                   output readdatavalid,
                   input  clken
                   );

   modport component_slave (
                   output waitrequest,
                   input  write,
                   input  read,
                   input  begintransfer,
                   input  address,
                   input  byteenable,
                   input  writedata,
                   output readdata,
                   output readdatavalid,
                   input  clken
                   );
endinterface 
