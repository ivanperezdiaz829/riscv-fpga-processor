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

module tb_txpll_recon_test (
    //port list
    enable,
    clk,
    trs_locked,
    tx_reconfig_done,
    tx_start_reconfig,
    rx_start_reconfig,
    rxdata,
    proceed,
    proceed_pos,
    complete,
    error
);

    localparam timeout = 100000;
    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------

    input         enable;
    input         clk;
    input         trs_locked;
    input         tx_reconfig_done;
    input         tx_start_reconfig;
    input         rx_start_reconfig;
    input  [19:0] rxdata;
    output        proceed;
    output        proceed_pos;
    output        complete;
    output        error;

    //--------------------------------------------------------------------------
    // port type declaration
    //--------------------------------------------------------------------------
    reg      proceed;
    reg      proceed_pos;
    reg      complete;
    reg      error;
    reg      trs_detect;
    reg      start_trs_sequence_high;
    reg      start_rx_then_tx_recon;
    reg      start_rx_same_tx_recon;
    reg      start_tx_then_rx_recon;
    integer  timeout_count;

    always @ (posedge clk)
    begin
      if (proceed == 1'b1) timeout_count = 0;
      if (timeout_count == timeout) begin
        $display ("TX PLL Reconfig test timeout!");
        $stop(0);
      end
      proceed <= 1'b0;
      proceed_pos <= 1'b0;
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
    reg start_countup = 1'b0;
    integer counter = 0;
	
    always @ (posedge clk)
    begin
        if (start_countup) begin
           counter <= counter + 1;
        end else begin
           counter <= 0;
        end
     end

    always @ (posedge clk)
    begin
        if (start_countdown) begin
           count <= count - 10'd1;
        end else begin
           count <= 20'h07FFF;
        end
     end
	 
    //---------------------------------------------------------------------------
    // Sequence for trs_locked assertion checking and reconfig assertion scenarios checking.
    //----------------------------------------------------------------------------

    sequence trs_h;
      @(posedge clk) 
      start_trs_sequence_high;
    endsequence

    property check_trs_lock_high; 
      @(posedge clk)
      trs_h |=> trs_locked==1;
    endproperty

    sequence rx_then_tx;
      @(posedge clk) 
      start_rx_then_tx_recon;
    endsequence

    property check_rx_then_tx; 
      @(posedge clk)
      rx_then_tx |-> (rx_start_reconfig ##11 tx_start_reconfig);
    endproperty
	
    sequence rx_same_tx;
      @(posedge clk) 
      start_rx_same_tx_recon;
    endsequence

    property check_rx_same_tx; 
      @(posedge clk)
      rx_same_tx |-> (rx_start_reconfig ##0 tx_start_reconfig);
    endproperty
	
    sequence tx_then_rx;
      @(posedge clk) 
      start_tx_then_rx_recon;
    endsequence

    property check_tx_then_rx; 
      @(posedge clk)
      tx_then_rx |-> (tx_start_reconfig ##10 rx_start_reconfig);
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
	
    req_rx_then_tx_assert : assert property (check_rx_then_tx)
    else begin
      error <= 1'b1;
      $display ("Control of scenarios of rx_start_reconfig follow by tx_start_reconfig_fail", $time);
      $stop(0);
    end
	
    req_rx_same_tx_assert : assert property (check_rx_same_tx)
    else begin
      error <= 1'b1;
      $display ("Control of scenarios of rx_start_reconfig assert at same time with tx_start_reconfig_fail", $time);
      $stop(0);
    end
	
    req_tx_then_rx_assert : assert property (check_tx_then_rx)
    else begin
      error <= 1'b1;
      $display ("Control of scenarios of tx_start_reconfig follow by rx_start_reconfig_fail", $time);
      $stop(0);
    end
	
    always @ (posedge enable)
    begin
      complete <= 1'b0;	  
    //---------------------------------------------------------------------------------------------------------------------
    // State 1: Switch from TX_PLL_SEL 0 To TX_PLL_SEL 1 and Test tx_start_reconfig assert after rx_start_reconfig (3G=>HD)
    //---------------------------------------------------------------------------------------------------------------------
      repeat (1000) @(posedge clk);
      proceed <= 1'b1;
      @(posedge rx_start_reconfig);
      start_rx_then_tx_recon = 1'b1;
      repeat (10)@(posedge clk);
      proceed_pos <= 1'b1;
      repeat (25)@(posedge clk);
      start_rx_then_tx_recon = 1'b0;
      @(posedge tx_reconfig_done);
      proceed_pos <= 1'b1;
      @(posedge trs_locked);
      start_trs_sequence_high <= 1'b1;
      start_countdown <= 1'b1;
      @(count == 20'h06000);
      start_trs_sequence_high <= 1'b0;
      start_countdown <= 1'b0;
      proceed <= 1'b1;
    //---------------------------------------------------------------------------------------------------------------------
    // State 2: Switch from TX_PLL_SEL 1 To TX_PLL_SEL 0 and Test tx_start_reconfig assert at the same time as rx_start_reconfig (HD=>3G)
    //---------------------------------------------------------------------------------------------------------------------
      repeat (1000) @(posedge clk);
      proceed <= 1'b1;
      @(posedge rx_start_reconfig);
      start_rx_same_tx_recon = 1'b1;
      proceed_pos <= 1'b1;	  
      repeat (10)@(posedge clk);
      start_rx_same_tx_recon = 1'b0;
      @(posedge tx_reconfig_done);
      proceed_pos <= 1'b1;
      @(posedge trs_locked);
      start_trs_sequence_high <= 1'b1;
      start_countdown <= 1'b1;
      @(count == 20'h06000);
      start_trs_sequence_high <= 1'b0;
      start_countdown <= 1'b0;
      proceed <= 1'b1;
    //---------------------------------------------------------------------------------------------------------------------
    // State 3: Switch from TX_PLL_SEL 0 To TX_PLL_SEL 1 and Test tx_start_reconfig assert before rx_start_reconfig (3G=>HD)
    //---------------------------------------------------------------------------------------------------------------------	  
      repeat (1000) @(posedge clk);
      proceed <= 1'b1;
      start_countup <= 1'b1;
      @(counter == 2182);
      start_tx_then_rx_recon = 1'b1;
      proceed_pos <= 1'b1;
      repeat (25)@(posedge clk);
      start_tx_then_rx_recon = 1'b0;
      @(posedge tx_reconfig_done);
      proceed_pos <= 1'b1;
      start_countup <= 1'b0;
      @(posedge trs_locked);
      start_trs_sequence_high <= 1'b1;
      start_countdown <= 1'b1;
      @(count == 20'h06000);
      start_trs_sequence_high <= 1'b0;
      start_countdown <= 1'b0;
      proceed <= 1'b1;
    //--------------------------------
    // Reset Back to PLL 0 and 3G STD
    //--------------------------------
      repeat (1000) @(posedge clk);
      proceed <= 1'b1;
      @(posedge tx_reconfig_done);
      proceed_pos <= 1'b1;
      @(posedge trs_locked);
      start_trs_sequence_high <= 1'b1;
      start_countdown <= 1'b1;
      @(count == 20'h06000);
      start_trs_sequence_high <= 1'b0;
      start_countdown <= 1'b0;
      proceed <= 1'b1;	  
      $display ("TX PLL Reconfig test done!");
      complete <= 1'b1;
    end 

endmodule
