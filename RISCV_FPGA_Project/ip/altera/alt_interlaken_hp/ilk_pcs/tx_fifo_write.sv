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


// Copyright 2012 Altera Corporation. All rights reserved.
// Altera products are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an
// accommodation and therefore all warranties, representations or guarantees of
// any kind (whether express, implied or statutory) including, without
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module tx_fifo_write(
    output reg           tx_fifo_write,

    input                tx_cadence,
    input                tx_lanes_aligned,
    input                tx_valid,
    input                clk_tx_common,
    input                srst_tx_common
);

// fake write triggered by initial tx_lanes_aligned signal
   reg tx_lanes_aligned_r;
   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
        tx_lanes_aligned_r <= 1'b0;
      end else begin
        tx_lanes_aligned_r <= tx_lanes_aligned;
      end
   end
  
   wire tx_lanes_aligned_detect = ~tx_lanes_aligned_r & tx_lanes_aligned;

// write state is between tx_aligned and first tx_valid
   reg write_state;
   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
         write_state      <= 1'b0;
      end
      else if (tx_lanes_aligned_detect)begin
         write_state      <= 1'b1;
      end
      else if (write_state & tx_valid) begin
         write_state      <= 1'b0;
      end
   end

assign tx_fifo_write = tx_cadence & write_state;
/*
// During write state, generate fake write to tx fifo 
   reg last_tx_fifo_write;
   always @(posedge clk_tx_common) begin
      if (srst_tx_common) begin
         tx_fifo_write         <= 1'b0;
         last_tx_fifo_write    <= 1'b0;
      end
      else begin
         last_tx_fifo_write    <= tx_fifo_write;
         tx_fifo_write         <= write_state && (!last_tx_fifo_write || !tx_fifo_write);
      end
   end
*/

endmodule

