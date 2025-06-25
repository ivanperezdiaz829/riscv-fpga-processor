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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
// synthesis verilog_input_version verilog_2001
// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030
//-----------------------------------------------------------------------------
// Title         : PCI Express Reference Design Example Application
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcierd_cdma_ecrc_check_128.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This module performs the PCIE ECRC check on the 128-bit Avalon-ST RX data stream.
//-----------------------------------------------------------------------------
// Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
module altpcierd_cdma_ecrc_check (
   input clk_in, 
   input srst,

   input[139:0]      rxdata,
   input[15:0]       rxdata_be,
   input             rx_stream_valid0,
   output            rx_stream_ready0_ecrc,

   output  [139:0]    rxdata_ecrc, 
   output  [15:0]     rxdata_be_ecrc,
   output             rx_stream_valid0_ecrc,
   input             rx_stream_ready0,
   output         rx_ecrc_check_valid,
   output  [15:0] ecrc_bad_cnt

   );
   
   parameter AVALON_ST_128 = 1'b0;

   generate begin:  rx_ecrc_check
      if (AVALON_ST_128==1) begin: rx_ecrc_128
         altpcierd_cdma_ecrc_check_128  altpcierd_cdma_ecrc_check_128 (
            // Input Avalon-ST prior to check ECRC 
            .rxdata({rxdata[139:128], rxdata[31:0], rxdata[63:32], rxdata[95:64], rxdata[127:96]}),  // H0H1H2H3
            .rxdata_be({rxdata_be[15:12], rxdata_be[11:8], rxdata_be[3:0], rxdata_be[7:4]}),
            .rx_stream_ready0(rx_stream_ready0),
            .rx_stream_valid0(rx_stream_valid0),     
            
            // Output Avalon-ST after checking ECRC 
            .rxdata_ecrc({rxdata_ecrc[139:128], rxdata_ecrc[31:0], rxdata_ecrc[63:32], rxdata_ecrc[95:64], rxdata_ecrc[127:96]}),  // H0H1H2H3
            .rxdata_be_ecrc({rxdata_be_ecrc[3:0], rxdata_be_ecrc[7:4], rxdata_be_ecrc[11:8], rxdata_be_ecrc[15:12]}),
            .rx_stream_ready0_ecrc(rx_stream_ready0_ecrc),
            .rx_stream_valid0_ecrc(rx_stream_valid0_ecrc),     
            
            .rx_ecrc_check_valid(rx_ecrc_check_valid), 
            .ecrc_bad_cnt(ecrc_bad_cnt), 
            .clk_in(clk_in),
            .srst(srst)
           );    
      end 
      else begin:  rx_ecrc_64
         altpcierd_cdma_ecrc_check_64  altpcierd_cdma_ecrc_check_64 (
            // Input Avalon-ST prior to check ecrc 
            .rxdata({rxdata[139], rxdata[136], rxdata[137], rxdata[138], rxdata[135:128], rxdata[31:0], rxdata[63:32], rxdata[95:64], rxdata[127:96]}),
            .rxdata_be({rxdata_be[15:12], rxdata_be[11:8], rxdata_be[3:0], rxdata_be[7:4]}),
            .rx_stream_ready0(rx_stream_ready0),
            .rx_stream_valid0(rx_stream_valid0),     
            
            // Output Avalon-ST afetr checkeing ECRC 
            .rxdata_ecrc({rxdata_ecrc[139], rxdata_ecrc[136], rxdata_ecrc[137], rxdata_ecrc[138], rxdata_ecrc[135:128], rxdata_ecrc[31:0], rxdata_ecrc[63:32], rxdata_ecrc[95:64], rxdata_ecrc[127:96]}),
            .rxdata_be_ecrc({rxdata_be_ecrc[3:0], rxdata_be_ecrc[7:4], rxdata_be_ecrc[11:8], rxdata_be_ecrc[15:12]}),
            .rx_stream_ready0_ecrc(rx_stream_ready0_ecrc),
            .rx_stream_valid0_ecrc(rx_stream_valid0_ecrc),     
            
            .rx_ecrc_check_valid(rx_ecrc_check_valid), 
            .ecrc_bad_cnt(ecrc_bad_cnt), 
            .clk_in(clk_in),
            .srst(srst)
           ); 
      end
   end
   endgenerate
   
 
endmodule
