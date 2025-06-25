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


`timescale 1ns/1ns


module dp_sync #
(
   parameter   dp_width = 1,
   parameter   dp_reset = {(dp_width){1'b0}}
)
(
   input                         async_reset_n,
   input                         sync_reset_n,
   input                         clk,
   input       [1:0]             sync_ctrl,
   input       [dp_width-1:0]    d,
   
   output reg  [dp_width-1:0]    o

)/* synthesis syn_noprune=1 */;

   wire        [dp_width-1:0]    dp_sync_stage_1_dout;
   wire        [dp_width-1:0]    dp_sync_stage_2_dout;

   
   // Synchronizer registers - long, unique names are used here used to
   // simplify the creation of constraints to ignore timing checks up to
   // the stage 1 register, and find these flops when special metastability
   // hardened flops are to be used.

   // The first stage synchronization register
   dp_sync_regstage #
   (
      .dp_width(dp_width),
      .dp_init(dp_reset)
   )
   dp_sync_stage_1
   (
      .clk(clk),
      .async_reset_n(async_reset_n),
      .sync_reset_n(sync_reset_n),
      .clke_n(1'b0),
      .d(d),
      .o(dp_sync_stage_1_dout)
   );


   // The second stage synchronization register
   dp_sync_regstage #
   (
      .dp_width(dp_width),
      .dp_init(dp_reset)
   )
   dp_sync_stage_2
   (
      .clk(clk),
      .async_reset_n(async_reset_n),
      .sync_reset_n(sync_reset_n),
      .clke_n(1'b0),
      .d(dp_sync_stage_1_dout),
      .o(dp_sync_stage_2_dout)
   );


   // The bypass mux
   always @* begin
           
      case (sync_ctrl)
              
         2'b00:   o = d;                              // No synchronization 
         2'b01:   o = dp_sync_stage_1_dout;   // One stage of synchronization
         2'b10:   o = dp_sync_stage_2_dout;   // Two stages of synchronization
         default: o = d;                              // No synchronization

      endcase

   end
   
endmodule


module dp_sync_regstage #
(
   parameter                     dp_width = 32,
   parameter                     dp_init  = 32'd0
)
(
   input                         async_reset_n,
   input                         sync_reset_n,
   input                         clk,
   input                         clke_n,
   input       [dp_width-1:0]    d,
   
   output reg  [dp_width-1:0]    o /* synthesis syn_keep=1 */
)/* synthesis syn_noprune=1 */;


   always @(posedge clk or negedge async_reset_n) begin

      if (async_reset_n == 1'b0)

         o <= dp_init;
         
      else if (sync_reset_n == 0)

         o <= dp_init;

      else if (clke_n == 0)

         o <= d;

   end
   
endmodule
