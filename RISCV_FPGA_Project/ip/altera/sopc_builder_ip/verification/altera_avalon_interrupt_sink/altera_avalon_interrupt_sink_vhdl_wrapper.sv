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


`timescale 1ns /  1ns

// synthesis translate_off
// enum for VHDL procedure
typedef enum int {
   IRQ_SINK_GET_IRQ        = 32'd0,
   IRQ_SINK_CLEAR_IRQ      = 32'd1
} irq_sink_vhdl_api_e;

// synthesis translate_on
module altera_avalon_interrupt_sink_vhdl_wrapper #(
   parameter ASSERT_HIGH_IRQ           = 1,
             AV_IRQ_W                  = 1,
             ASYNCHRONOUS_INTERRUPT    = 0
)(
   input                clk,
   input                reset,
   input [AV_IRQ_W-1:0] irq,
   
   // VHDL API request interface
   input  bit [IRQ_SINK_CLEAR_IRQ:0]                  req,
   output bit [IRQ_SINK_CLEAR_IRQ:0]                  ack,
   output int                                         data_out0
);

   // synthesis translate_off
   altera_avalon_interrupt_sink #(
      .ASSERT_HIGH_IRQ(ASSERT_HIGH_IRQ),
      .AV_IRQ_W(AV_IRQ_W),
      .ASYNCHRONOUS_INTERRUPT(ASYNCHRONOUS_INTERRUPT)
   ) irq_sink (
      .clk(clk),
      .reset(reset),
      .irq(irq)
   );
   
   // logic block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[IRQ_SINK_GET_IRQ]);
      ack[IRQ_SINK_GET_IRQ] = 1;
      data_out0 = irq_sink.get_irq();
      ack[IRQ_SINK_GET_IRQ] <= 0;
   end
   
   initial forever begin
      @(posedge req[IRQ_SINK_CLEAR_IRQ]);
      ack[IRQ_SINK_CLEAR_IRQ] = 1;
      irq_sink.clear_irq();
      ack[IRQ_SINK_CLEAR_IRQ] <= 0;
   end

// synthesis translate_on
endmodule 