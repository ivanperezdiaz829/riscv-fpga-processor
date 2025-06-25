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

module pempty_gen_a10 #(
    parameter           NUM_LANES = 8,
    parameter           PEMPTY    = 8
)(
    output reg [NUM_LANES-1 :0]            pempty_np,          // to ilk_tx_aligner, to control tx_fifo write

    input [4*NUM_LANES-1:0]             fifo_cnt_np,        // from native phy, tx_fifo level indicator
    input [NUM_LANES-1:0]               tx_digitalreset,    // from altera_xcvr_reset_control 
    input [NUM_LANES-1:0]               tx_clkout          // from native phy, 
);

wire reset;
assign reset = |tx_digitalreset;
genvar i;
generate
    for( i = 0; i < NUM_LANES; i = i + 1 ) begin : pempty_flg
        always @( posedge tx_clkout[i] or posedge reset )begin
            if( reset ) begin
                pempty_np[i] <= 0;
            end else begin
                pempty_np[i] <= (fifo_cnt_np[4*(i+1)-1] == 1'b0);     //fifo level is less than 3
            end
        end
    end
endgenerate

endmodule

