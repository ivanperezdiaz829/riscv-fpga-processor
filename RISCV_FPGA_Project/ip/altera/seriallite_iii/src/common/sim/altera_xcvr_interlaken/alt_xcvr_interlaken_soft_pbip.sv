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


//###########################################################################
// alt_xcvr_interlaken_soft_pbip module 
// Soft PCS Bonding IP
// Here how we are implementing soft solution to solve the PCS bonding problem
// 1) Frame generator has a burst_en i/p  and txframe o/p, 
// 2) TX FIFO read is controlled by Frame generator tx_burst_en signal, 
// Burst_en is async input of the frame generator, When burst_en low 
// frame generator inserts SKIP and continously sends payload full of SKIP characters, 
// When busrt_en low frame generator will not read the data from TXFIFO, 
// The reading of the data from the TX FIFO is triggered by the user asserting the TX_BURST_EN control signal
// 3) Tx_frame  - async o/p goes 1 when beginning of a new metaframe (when sees sync word)
// Here we are making use of burst_en, txframe, FIFO flags of TX FIFO
// Implementation Details:
//1) Burst_en (for all lanes) 0 initially
//2) Wait for TX_FIFO FULL signal
//3) Look for tx_frame o/p from Frame generator after all lanes FIFOs PFULL is 1
//4) Wait for 5-10 clock cycles and then assert burst_en for all lanes and also
// assert tx_sync_done for MAC to indicate that tx PCS sync is done!
// Also there is a recovery mechanism 
// The Scheme will work only for larger Metaframes


// $Header$
//###########################################################################

`timescale 1 ns / 1 ps

module alt_xcvr_interlaken_soft_pbip
  #(
    parameter LINKWIDTH = 1
    ) (
    input clk,
    input reset,  // synchronized tx digital reset with clk_tx_commom
    input [LINKWIDTH-1:0] tx_fifo_full,
    input [LINKWIDTH-1:0] tx_fifo_empty,
    input [LINKWIDTH-1:0] tx_frame,  // this is syncronized with tx_coreclkin as soft IP operates on tx_coreclkin
       
    output wire [LINKWIDTH-1:0] tx_burst_en, // For all PCS Frame generator
    output wire tx_sync_done, // This is a signal for MAC to indicate that MAC can start sending payload
    output reg tx_force_fill = 1'b0
       
       );
   
   /////////////////////////////////////////////////
	// TX aligner
   /////////////////////////////////////////////////
   
   reg 			       all_tx_full = 1'b0;
   reg 			       any_tx_empty = 1'b0;
   reg 			       any_tx_frame = 1'b0;
   reg 			       any_tx_full = 1'b0;
   wire 		       clk_tx_common;
   wire 		       srst_tx_common;
   reg 			       tx_aligned = 1'b0;
   reg [3:0] 		       tx_frame_countdown = 4'h0;
   reg 			       tx_from_fifo = 1'b0 /* synthesis preserve dont_replicate */;

   
   
   assign clk_tx_common = clk;
   assign srst_tx_common = reset;
   assign tx_burst_en = {LINKWIDTH{tx_from_fifo}};
   assign tx_sync_done = tx_aligned;
   
   
   
   always @(posedge clk_tx_common) 
     begin
	all_tx_full <= &tx_fifo_full;
	any_tx_full <= |tx_fifo_full;
	any_tx_empty <= |tx_fifo_empty;
	any_tx_frame <= |tx_frame;
     end
   
   
   reg [2:0] txa_sm = 3'h0 /* synthesis preserve dont_replicate */;
   localparam TXA_INIT = 3'h0;
   localparam TXA_FILL = 3'h1;
   localparam TXA_PREFRAME_WAIT = 3'h2;
   localparam TXA_POSTFRAME_WAIT = 3'h3;
   localparam TXA_ENABLE = 3'h4;
   localparam TXA_ALIGNED = 3'h5;
   localparam TXA_ERROR0 = 3'h6;
   localparam TXA_ERROR1 = 3'h7;
   
   
   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
	 txa_sm <= TXA_INIT;
	 tx_from_fifo <= 1'b1;
	 tx_aligned <= 1'b0;
	 tx_force_fill <= 1'b0;
	 tx_frame_countdown <= 4'hf;
      end
      else begin
	 
	 // defaults
	 tx_aligned <= 1'b0;
	 tx_force_fill <= 1'b0;
	 
	 case (txa_sm) 
	   TXA_INIT : begin
	      txa_sm <= TXA_FILL;
	      tx_from_fifo <= 1'b1;
	   end
	   TXA_FILL :	begin
	      tx_from_fifo <= 1'b0;
	      tx_force_fill <= 1'b1;
	      if (all_tx_full) txa_sm <= TXA_PREFRAME_WAIT;
	   end
	   TXA_PREFRAME_WAIT : begin
	      tx_frame_countdown <= 4'hf;
	      if (any_tx_frame) txa_sm <= TXA_POSTFRAME_WAIT;				
	   end
	   TXA_POSTFRAME_WAIT : begin
	      // wait for ~16 tcks after any tx framing activity
//	      if (any_tx_frame) txa_sm <= TXA_PREFRAME_WAIT;				
//	      tx_frame_countdown <= tx_frame_countdown - 1'b1;
              if (any_tx_frame) tx_frame_countdown <= 4'hf;
              else tx_frame_countdown <= tx_frame_countdown - 1'b1;
	      if (~|tx_frame_countdown) txa_sm <= TXA_ENABLE;
	      if (!all_tx_full) txa_sm <= TXA_ERROR0; // this would be an error - start over
	   end
	   TXA_ENABLE :  begin
	      tx_from_fifo <= 1'b1;
	      if (!any_tx_full) txa_sm <= TXA_ALIGNED;
	   end
	   TXA_ALIGNED : begin
	      tx_aligned <= 1'b1;
	      if (any_tx_empty || any_tx_full) txa_sm <= TXA_ERROR0; // this would be an error - start over 
	   end		
	   TXA_ERROR0 : txa_sm <= TXA_ERROR1;
	   TXA_ERROR1 : txa_sm <= TXA_INIT;
	   
	   default : txa_sm <= TXA_ERROR0;
	 endcase // case (txa_sm)
      end // else: !if(srst_tx_common)
   end // always @ (posedge clk_tx_common)
   
   
  

   
endmodule // alt_xcvr_interlaken_soft_pbip



       
   
    
