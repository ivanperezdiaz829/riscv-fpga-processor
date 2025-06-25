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


`timescale 1 ps / 1 ps
//-----------------------------------------------------------------------------
// Title         : PCI Express PIPE PHY connector
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcietb_pipe_phy.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This function interconnects two PIPE MAC interfaces for a single lane.
// For now this uses a common PCLK for both interfaces, an enhancement woudl be
// to support separate PCLK's for each interface with the requisite elastic
// buffer.
//-----------------------------------------------------------------------------
// Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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
module altpcietb_rst_clk # ( parameter REFCLK_HALF_PERIOD = 5000) (
   output reg ref_clk_out,
   output reg pcie_rstn,
   output reg rp_rstn
);

  always
    #REFCLK_HALF_PERIOD  ref_clk_out <= ~ref_clk_out;

  initial
    begin
      pcie_rstn         = 1'b1;
      rp_rstn           = 1'b0;
      ref_clk_out       = 1'b0;
      #1000
      pcie_rstn         = 1'b0;
      rp_rstn           = 1'b1;
      #1000
      rp_rstn           = 1'b0;
      #1000
      rp_rstn           = 1'b1;
      #1000
      rp_rstn           = 1'b0;
      #200000 pcie_rstn = 1'b1;
      #100000 rp_rstn   = 1'b1;
    end

endmodule

