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


// $File: $
// $Revision: $
// $Date: $
// $Author: $
//------------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_interrupt_source_vhdl_wrapper
// =head1 SYNOPSIS
// Avalon Interrupt Source Bus Functional Model (BFM)
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is an Avalon Interrupt Source Bus Functional Model (BFM)
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_interrupt_source_vhdl_wrapper #(
   parameter ASSERT_HIGH_IRQ           = 1,
   parameter ASYNCHRONOUS_INTERRUPT    = 0,
   parameter AV_IRQ_W                  = 1
)(
   input  wire                 clk,
   input  wire                 reset,
   output wire [AV_IRQ_W-1:0]  irq,
   
   // VHDL request interface
   input  bit [1:0]           req,
   output bit [1:0]           ack,
   input  int                 data_in
);
   
   // synthesis translate_off
   altera_avalon_interrupt_source #(
      .ASSERT_HIGH_IRQ(ASSERT_HIGH_IRQ),
      .ASYNCHRONOUS_INTERRUPT(ASYNCHRONOUS_INTERRUPT),
      .AV_IRQ_W(AV_IRQ_W)
   ) irq_source (
      .clk(clk),
      .reset(reset),
      .irq(irq)
   );
   
   typedef enum int {
      IRQ_SRC_SET_IRQ               = 32'd0,
      IRQ_SRC_CLEAR_IRQ             = 32'd1
   } vhdl_api_e;
   
   // control block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[IRQ_SRC_SET_IRQ]);
      ack[IRQ_SRC_SET_IRQ] = 1;
      irq_source.set_irq(data_in);
      ack[IRQ_SRC_SET_IRQ] <= 0;
   end
   
   initial forever begin
      @(posedge req[IRQ_SRC_CLEAR_IRQ]);
      ack[IRQ_SRC_CLEAR_IRQ] = 1;
      irq_source.clear_irq(data_in);
      ack[IRQ_SRC_CLEAR_IRQ] <= 0;
   end

// synthesis translate_on
endmodule 