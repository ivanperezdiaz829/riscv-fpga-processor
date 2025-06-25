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

//Receiver and trasmitter transceiver reset for interlaken protocol
//All the output syncd to 50 Mhz slow clock.
//This logic can be used for each Quard of transceivers.
//7/07/11
module alt_ntrlkn_gxb_reset #(
       parameter CNTR_BITS = 16
        )
       (
       //Hard reset or softreset
       input  reset_n,
       //50 Mhz clock that the reset controller run on
       input  cal_blk_clk,
       //reconfiguration busy. from reconfig. block.
       input  reco_busy,
       //Receiver CDR locked, from GXB
       input  rx_freqlocked,

       //ATX or CMU locked signals
       input  pll_locked,

       //ATX or CMU pll power down. Can be used for gxb_powerdown as well
       output pll_powerdown,

       output tx_digitalreset,

       //Reset receiver CDR. Connect to GXB.
       output rx_analogreset,
       //Reset PCS logic
       output rx_digitalreset
       );

wire clk50 = cal_blk_clk;
//Added reset_n so that it will be sensitive to reset_n.
//The original ways was wait until cal_blk_clk gets stable.

// start with PLL powerdown
wire rd0_ready;
alt_ntrlkn_reset_delay rd0 (
        .clk(clk50),
        .ready_in(reset_n),
        .ready_out(rd0_ready)
);
defparam rd0 .CNTR_BITS = CNTR_BITS;
assign pll_powerdown = {rd0_ready ^ 1'b1};

// Waitfor pll_locked
wire rd1_ready;
alt_ntrlkn_reset_delay rd1 (
        .clk(clk50),
        .ready_in(rd0_ready & (&pll_locked)),
        .ready_out(rd1_ready)
);
defparam rd1 .CNTR_BITS = CNTR_BITS;

// release TX digital reset
wire rd2_ready;
alt_ntrlkn_reset_delay rd2 (
    .clk(clk50),
    .ready_in(rd1_ready),
    .ready_out(rd2_ready)
);
defparam rd2 .CNTR_BITS = CNTR_BITS;
assign tx_digitalreset = rd2_ready ^ 1'b1;

//  waitfor RX calibration not busy - release RX analog reset
wire rd3_ready;
alt_ntrlkn_reset_delay rd3 (
        .clk(clk50),
        .ready_in(rd2_ready & !reco_busy),
        .ready_out(rd3_ready)
);
defparam rd3 .CNTR_BITS = CNTR_BITS;
assign rx_analogreset = rd3_ready ^ 1'b1;

// waitfor RX freq locks - release RX digital reset
wire rd4_ready;
alt_ntrlkn_reset_delay rd4 (
        .clk(clk50),
        .ready_in(rd3_ready & rx_freqlocked),
        .ready_out(rd4_ready)
);
defparam rd4 .CNTR_BITS = CNTR_BITS;
assign rx_digitalreset = rd4_ready ^ 1'b1;

endmodule



