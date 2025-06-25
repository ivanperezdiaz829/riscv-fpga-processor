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


module	freq_check(
	region0,
	region1,
	region2,
	refclk,
	tx_xcvr_clkout,
	rx_xcvr_clkout,
	reset
		);
input region0;
input region1;
input region2;
input refclk;
input tx_xcvr_clkout;
input rx_xcvr_clkout;
input reset;

tx_freq_check tx_freq_check_0(
        .region (region0),
        .refclk (refclk),
        .xcvr_clk (tx_xcvr_clkout),
        .rst(reset)
        );

rx_freq_check rx_freq_check_0(
        .region (region0),
        .refclk (refclk),
        .xcvr_clk (rx_xcvr_clkout),
        .rst(reset)
        );

tx_freq_check tx_freq_check_1(
        .region (region1),
        .refclk (refclk),
        .xcvr_clk (tx_xcvr_clkout),
        .rst(reset)
        );

rx_freq_check rx_freq_check_1(
        .region (region1),
        .refclk (refclk),
        .xcvr_clk (rx_xcvr_clkout),
        .rst(reset)
        );

tx_freq_check tx_freq_check_2(
        .region (region2),
        .refclk (refclk),
        .xcvr_clk (tx_xcvr_clkout),
        .rst(reset)
        );

rx_freq_check rx_freq_check_2(
        .region (region2),
        .refclk (refclk),
        .xcvr_clk (rx_xcvr_clkout),
        .rst(reset)
        );

endmodule
