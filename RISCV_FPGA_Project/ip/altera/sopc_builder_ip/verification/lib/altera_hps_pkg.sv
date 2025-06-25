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


// $Id: //acds/main/ip/sopc/components/verification/lib/avalon_mm_pkg.sv#8 $
// $Revision: #8 $
// $Date: 2010/05/18 $
//-----------------------------------------------------------------------------
// =head1 NAME
// avalon_mm_pkg
// =head1 SYNOPSIS
// Package for shared Avalon MM component types.
//-----------------------------------------------------------------------------
// =head1 COPYRIGHT
// Copyright (c) 2008 Altera Corporation. All Rights Reserved.
// The information contained in this file is the property of Altera
// Corporation. Except as specifically authorized in writing by Altera 
// Corporation, the holder of this file shall keep all information 
// contained herein confidential and shall protect same in whole or in part 
// from disclosure and dissemination to all third parties. Use of this 
// program confirms your agreement with the terms of this license.
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This package contains shared non-parameterized type definitions.
// =cut

`ifndef _AXI_HPS_PKG_
`define _AXI_HPS_PKG_

package altera_hps_pkg;
   import verbosity_pkg::*;
   
   localparam MAX_BURST_SIZE     = 16;
   
   event signal_fatal_error;
   
   // Transaction request types
   typedef enum bit {
                     AXI_READ = 0,
                     AXI_WRITE = 1
                     } AxiTransactionType_t;
                     
   
   typedef enum bit [1:0] {
                     CMD_WADDRESS = 0,
                     CMD_WDATA = 1,
                     CMD_RADDRESS = 2,
                     CMD_WCOMPLETE = 3
                     } AxiCommandType_t;
                     
   typedef enum bit [1:0] {
                     NORMAL = 0,
                     EXCLUSIVE = 1,
                     LOCKED = 2,
                     LOCK_RESERVED = 3
                     } AxiLockType_t;
                     
   typedef enum bit [1:0] {
                     FIXED = 0,
                     INCR = 1,
                     WRAP = 2,
                     RESERVED = 3
                     } AxiBurstType_t;
                     
   typedef enum bit [3:0] {
                     NO_CACHE_NO_BUFFER = 0,
                     BUFFER = 1,
                     CACHE_BUFFER = 2,
                     CACHE_BUFFER_NO_ALLOCATE = 3,
                     CACHE_RESERVED_0 = 4,
                     CACHE_RESERVED_1 = 5,
                     CACHE_WRITE_THROUGH_READ_ALLOCATE = 6,
                     CACHE_WRITE_BACK_READ_ALLOCATE = 7,
                     CACHE_RESERVED_2 = 8,
                     CACHE_RESERVED_3 = 9,
                     CACHE_WRITE_THROUGH_WRITE_ALLOCATE = 10,
                     CACHE_WRITE_BACK_WRITE_ALLOCATE = 11,
                     CACHE_RESERVED_4 = 12,
                     CACHE_RESERVED_5 = 13,
                     CACHE_WRITE_THROUGH_BOTH_ALLOCATE = 14,
                     CACHE_WRITE_BACK_BOTH_ALLOCATE = 15
                     } AxiCacheType_t;
                     
   typedef enum bit [2:0] {
                     DATA_SECURE_NORMAL = 0,
                     DATA_SECURE_PRIV = 1,
                     DATA_NON_SECURE_NORMAL = 2,
                     DATA_NON_SECURE_PRIV = 3,
                     INST_SECURE_NORMAL = 4,
                     INST_SECURE_PRIV = 5,
                     INST_NON_SECURE_NORMAL = 6,
                     INST_NON_SECURE_PRIV = 7
                     } AxiProtectionType_t;
                     
   typedef enum bit [1:0] {
                     OKAY = 0,
                     EXOKAY = 1,
                     SLVERR = 2,
                     DECERR = 3
                     } AxiResponseType_t;
                     
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction  
                     
   function automatic void __abort_simulation();
      string message;
      $sformat(message, "%m: Abort the simulation due to fatal error."); 
      print(VERBOSITY_FAILURE, message);
      $stop;
   endfunction
   
   function automatic int __check_transaction_index(int index);
      if (index > MAX_BURST_SIZE-1) begin
         $sformat(message,"%m: Cycle index %0d exceeds MAX_BURST_SIZE-1 %0d",
                  index, MAX_BURST_SIZE-1);
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
         return 0;
      end else begin
         return 1;
      end
   endfunction
   
endpackage

`endif
   
