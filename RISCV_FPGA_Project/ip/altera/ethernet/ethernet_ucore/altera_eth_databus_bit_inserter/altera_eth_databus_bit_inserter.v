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


`timescale 1ns/1ps 

module altera_eth_databus_bit_inserter(
    clk,
    reset,
    
    stat_sink_valid,
    stat_sink_data,
    stat_sink_error,
    
    stat_source_valid,
    stat_source_data,
    stat_source_error


);

localparam STATUS_WIDTH = 39;
localparam ERROR_WIDTH  = 7;

input clk;
input reset;
input stat_sink_valid;
input [(STATUS_WIDTH-1):0]stat_sink_data;
input [(ERROR_WIDTH-1):0]stat_sink_error;

output wire stat_source_valid;
output wire [(ERROR_WIDTH-1):0] stat_source_error;
output wire [STATUS_WIDTH:0] stat_source_data;

assign stat_source_error = stat_sink_error;
assign stat_source_valid = stat_sink_valid;
//This is because of VHDL compilation warning: eth_rx_Statistic collector is using bit 39, whereelse 2.5G is not supporting PFC
assign stat_source_data =  {1'b0,stat_sink_data};

endmodule
