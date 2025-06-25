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

module tb_txpll_test (
    //port list
    enable,
    clk,
    trs_locked,
    tx_reconfig_done,
    rxdata,
    proceed,
    complete,
    error
);

    //--------------------------------------------------------------------------
    // parameter declaration
    //--------------------------------------------------------------------------
    parameter direction = "du";

    localparam timeout = 100000;
    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------

    input         enable;
    input         clk;
    input         trs_locked;
    input         tx_reconfig_done;
    input  [19:0] rxdata;
    output        proceed;
    output        complete;
    output        error;

    //--------------------------------------------------------------------------
    // port type declaration
    //--------------------------------------------------------------------------
    reg      proceed;
    reg      complete;
    reg      error;
    reg      trs_detect;
    reg      start_trs_sequence_high;
    integer  timeout_count;

    //---------------------------------------------------------------------------
    // Rx Format detect test
    //---------------------------------------------------------------------------	
    always @ (posedge clk)
    begin
      if (proceed == 1'b1) timeout_count = 0;
      if (timeout_count == timeout) begin
        $display ("TX PLL test timeout!");
        $stop(0);
      end
      proceed <= 1'b0;
      error <= 1'b0;
    end

    always @ (posedge clk)
    begin
      if (~complete) begin
         timeout_count = timeout_count + 1;
      end
    end

    wire rxdata_trs = (rxdata[9:0] == 10'h3ff);
    reg rx_no_trs;	
    reg start_countdown = 1'b0;
    reg [100:0] count = 20'h07FFF;

    always @ (posedge clk)
    begin
        if (start_countdown) begin
           count <= count - 10'd1;
        end else begin
           count <= 20'h07FFF;
        end
     end

    //---------------------------------------------------------------------------
    // Sequence for assertion checking.
    // sequence trs_h : check for trs_locked is equals to high as long as start_trs_sequence_high=1'b1, else flag error.
    //----------------------------------------------------------------------------

    sequence trs_h;
       @(posedge clk) 
       start_trs_sequence_high;
    endsequence

    property check_trs_lock_high; 
       @(posedge clk)
       trs_h |=> trs_locked==1;
    endproperty

   //=================================================
   // Assertion Directive Layer
   //=================================================

    req_trs_assert : assert property (check_trs_lock_high)
       else begin
          error <= 1'b1;
          $display ("\n Error occured. Trs_locked is deasserted during TX PLL switching.", $time);
          $stop(0);
       end

    always @ (posedge enable)
    begin
      complete = 1'b0;	  
      repeat (1000) @(posedge clk);
      //--------------------------------------------------
      // State 1: Switch from TX_PLL_SEL 0 To TX_PLL_SEL 1
      //--------------------------------------------------
      proceed = 1'b1;
      @(posedge tx_reconfig_done);
      proceed = 1'b1;
      @(posedge trs_locked);
      start_countdown = 1'b1;
      start_trs_sequence_high = 1'b1;
      @(count == 20'h06000);
      start_trs_sequence_high = 1'b0;
      start_countdown = 1'b0;
      proceed = 1'b1;
      repeat (1000) @(posedge clk);
      //--------------------------------------------------
      // State 2: Switch from TX_PLL_SEL 1 To TX_PLL_SEL 0
      //--------------------------------------------------
      proceed = 1'b1;
      @(posedge tx_reconfig_done);
      proceed = 1'b1;
      @(posedge trs_locked);
      start_countdown = 1'b1;
      start_trs_sequence_high = 1'b1;
      @(count == 20'h06000);
      start_trs_sequence_high = 1'b0;
      start_countdown = 1'b0;
      proceed = 1'b1;
      @(posedge trs_locked);
      $display ("TX PLL SEL test done!");
      complete = 1'b1;
      start_countdown = 1'b0;
    end

endmodule
