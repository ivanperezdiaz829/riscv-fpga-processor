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


`timescale 100 fs / 100 fs
`define tdisplay(MYSTRING) $display("%t:%s \n", $time,  MYSTRING)

module tb_tx_clkout_check
(
    tx_clkout,
    tx_status,
    tx_clkout_match
);

    //--------------------------------------------------------------------------
    // parameter declaration
    //--------------------------------------------------------------------------
    parameter VIDEO_STANDARD = "tr";
	
    localparam THREEG_PERIOD_MIN = 67300;
    localparam THREEG_PERIOD_MAX = 67500;
    localparam HD_PERIOD_MIN = 134650;
    localparam HD_PERIOD_MAX = 134750;

    input tx_clkout;
    input tx_status;
    output reg tx_clkout_match;

    integer     current_time_pll_0 = 0;
    integer     previous_time_pll_0 = 0;
    integer     one_period_pll_0 = 0;

    always @ (posedge tx_clkout)
    begin
       if(tx_status) begin
          current_time_pll_0 = $time;
          one_period_pll_0 = current_time_pll_0 - previous_time_pll_0;   
          previous_time_pll_0 = current_time_pll_0;
       end
       else begin
          one_period_pll_0 = 0;
       end
       end

    always @ (posedge tx_clkout)
    begin
       if (tx_status) begin
          if (((VIDEO_STANDARD != "hd") | (VIDEO_STANDARD != "dl")) && (one_period_pll_0 < THREEG_PERIOD_MAX && one_period_pll_0 > THREEG_PERIOD_MIN)) tx_clkout_match = 1'b1;
          else if (((VIDEO_STANDARD == "hd") | (VIDEO_STANDARD == "dl")) && (one_period_pll_0 < HD_PERIOD_MAX && one_period_pll_0 > HD_PERIOD_MIN)) tx_clkout_match = 1'b1;
          else tx_clkout_match = 1'b0;
       end
       else tx_clkout_match = 1'b0;
    end

endmodule
