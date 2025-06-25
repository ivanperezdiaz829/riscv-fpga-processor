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

module tb_serial_descrambler
(
    // port list
    ref_clk,
    sdi_serial,
    tx_std,
    tx_status,
    tx_sclk,
    descrambled,
    trs_spotted
);

    //--------------------------------------------------------------------------
    // port declaration
    //--------------------------------------------------------------------------

    input    ref_clk;
    input    sdi_serial;
    input [1:0]    tx_std;
    input    tx_status;
    output   tx_sclk;
    output   descrambled;
    output   trs_spotted;
    //--------------------------------------------------------------------------
    // [START] comment
    //--------------------------------------------------------------------------
    reg [119:0]  trs;
    integer     current_time = 0;
    integer     previous_time = 0;
    integer     one_period = 0;
    integer     sample_period = 0;
    integer     upper_sample_period = 0;
    integer     lower_sample_period = 0;

    always @ (posedge ref_clk)
    begin
      current_time = $time;
      one_period = current_time - previous_time;

      //SD
      if (tx_std == 2'b00) begin
        sample_period = one_period/10;
        trs = {10'h3FF, 10'h000, 10'h000};
      end
      //HD & 3G
      else begin
        sample_period = one_period/20;
        if (tx_std == 2'b10) //3GB
          trs = {10'h3FF, 10'h3FF, 10'h3FF, 10'h3FF, 10'h000, 10'h000, 10'h000, 10'h000, 10'h000, 10'h000, 10'h000, 10'h000};
        else 
          trs = {10'h3FF, 10'h3FF, 10'h000, 10'h000, 10'h000, 10'h000};
      end

      if (sample_period%2 == 1'b0) begin
        upper_sample_period = sample_period/2;
        lower_sample_period = sample_period/2;
      end
      else begin
        upper_sample_period = sample_period/2;
        lower_sample_period = (sample_period/2 + 1);
      end
      previous_time = current_time;
    end

    //--------------------------------------------------------------------------------------------------
    // Sample the serial tx data
    //--------------------------------------------------------------------------------------------------
    reg sample;
    reg tx_sclk;
    reg pll_locked;

    always @ (tx_status or tx_std)
    begin
      pll_locked = 1'b0;

      if (tx_status) begin

        // Wait a few clocks to skip the spurious output from the transceiver at startup
        repeat (3) @(posedge ref_clk);
        // Wait for start of first bit
        @(posedge sdi_serial);
        // Wait half a bit period to align with centre of data
        #(sample_period);
        pll_locked = 1'b1;
      end
    end

    initial begin
      tx_sclk = 1'b0;
      forever begin
        if (pll_locked) begin
          #(upper_sample_period) tx_sclk = ~tx_sclk;
          #(lower_sample_period) tx_sclk = ~tx_sclk;
        end else 
          #(1) tx_sclk = 1'b0;
      end
    end

    //--------------------------------------------------------------------------------------------------
    // Descramble serial tx data
    //--------------------------------------------------------------------------------------------------
    reg [8:0] tx_lfsr = 9'b0;
    reg tx_nrzi;
    reg last_sample = 1'b0;
    reg descrambled;
    always @ (tx_sclk)
    begin
      if (tx_sclk) begin
        sample = sdi_serial;
        tx_nrzi = last_sample ^ sample;
        last_sample = sample;
        descrambled = tx_nrzi ^ tx_lfsr[4] ^ tx_lfsr[8];
        tx_lfsr[8:0] = {tx_lfsr[7:0], tx_nrzi};
      end
    end

    //--------------------------------------------------------------------------------------------------
    // Reconstruct parallel tx data
    //--------------------------------------------------------------------------------------------------
    reg [119:0] shiftreg;
    reg         trs_spotted;

    always @ (tx_sclk)
    begin
      if (tx_sclk) begin
        trs_spotted = 1'b0;

        shiftreg = {shiftreg[118:0], descrambled};

        if (tx_std == 2'b00) begin
          if (shiftreg [29:0] == trs) trs_spotted = 1'b1;
        end 
        else if (tx_std == 2'b10) begin
          if (shiftreg [119:0] == trs) trs_spotted = 1'b1;
        end 
        else
          if (shiftreg [59:0] == trs) trs_spotted = 1'b1;
      end
    end

    //--------------------------------------------------------------------------
    // [END] comment
    //--------------------------------------------------------------------------
endmodule
 
