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


module	rx_freq_check(
	region,
	refclk,
	xcvr_clk,
	rst
		);
input region;
input refclk;
input xcvr_clk;
input rst;

reg refclk_1d, refclk_2d;
reg region_1d, region_2d;
reg measure_period_1d, measure_period_2d;
wire refclk_1p = refclk_1d & ~refclk_2d;
wire measure_period = region_1d & ~ region_2d;
wire measure_period_1p = ~measure_period_1d & measure_period_2d;

always @(posedge xcvr_clk or posedge rst)
	if(rst) begin
		refclk_1d <= 1'b0;	
		refclk_2d <= 1'b0;	
		measure_period_1d <= 1'b0;	
		measure_period_2d <= 1'b0;	
        end
	else begin
		refclk_1d <= refclk;	
		refclk_2d <= refclk_1d;	
		measure_period_1d <= measure_period;	
		measure_period_2d <= measure_period_1d;	
        end

always @(posedge xcvr_clk or posedge rst)
	if(rst) begin
		region_1d <= 1'b0;	
		region_2d <= 1'b0;	
        end
	else if (refclk_1p) begin
		region_1d <= region;	
		region_2d <= region_1d;	
        end

reg [15:0] freq_cnt;
always @(posedge xcvr_clk or posedge rst)
        if(rst) begin
                                freq_cnt <= 16'h3;
        end
	else if(measure_period)       begin
                                freq_cnt <= freq_cnt + 1;
        end

wire unsigned [15:0]  freq_out = freq_cnt/100;

always @ (posedge measure_period_1p)
begin
 $display("RX Frequency Change Detected, Measured Frequency = %d MHz", freq_out);
end

endmodule
