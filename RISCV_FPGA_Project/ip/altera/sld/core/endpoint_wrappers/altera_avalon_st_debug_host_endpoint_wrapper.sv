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


// altera_avalon_st_debug_host_endpoint.sv

`timescale 1 ns / 1 ns

module altera_avalon_st_debug_host_endpoint_wrapper #(
    parameter DATA_WIDTH           = 8,
    parameter CHANNEL_WIDTH        = 8,
    parameter NAME                 = "",
    parameter HOST_PRIORITY        = 100,
    parameter CLOCK_RATE_CLK       = 0
) (
    input         clk,
    input         reset,
    output        h2t_ready,
    input         h2t_valid,
    input  [DATA_WIDTH-1:0] h2t_data,
    input         h2t_startofpacket,
    input         h2t_endofpacket,
    input  [nonzero($clog2(DATA_WIDTH) - 3)-1:0] h2t_empty,
    input  [CHANNEL_WIDTH-1:0] h2t_channel,
    input         t2h_ready,
    output        t2h_valid,
    output [DATA_WIDTH-1:0] t2h_data,
    output        t2h_startofpacket,
    output        t2h_endofpacket,
    output [nonzero($clog2(DATA_WIDTH) - 3)-1:0] t2h_empty,
    output [CHANNEL_WIDTH-1:0] t2h_channel,
    input         mgmt_valid,
    input         mgmt_data,
    input  [CHANNEL_WIDTH-1:0] mgmt_channel
);

function integer nonzero;
input value;
begin
	nonzero = (value > 0) ? value : 1;
end
endfunction

	altera_avalon_st_debug_host_endpoint #(
        .DATA_WIDTH           (DATA_WIDTH),
        .CHANNEL_WIDTH        (CHANNEL_WIDTH),
        .NAME                 (NAME),
        .HOST_PRIORITY        (HOST_PRIORITY),
        .CLOCK_RATE_CLK       (CLOCK_RATE_CLK)
) inst (
        .clk                  (clk),
        .reset                (reset),
        .h2t_ready            (h2t_ready),
        .h2t_valid            (h2t_valid),
        .h2t_data             (h2t_data),
        .h2t_startofpacket    (h2t_startofpacket),
        .h2t_endofpacket      (h2t_endofpacket),
        .h2t_empty            (h2t_empty),
        .h2t_channel          (h2t_channel),
        .t2h_ready            (t2h_ready),
        .t2h_valid            (t2h_valid),
        .t2h_data             (t2h_data),
        .t2h_startofpacket    (t2h_startofpacket),
        .t2h_endofpacket      (t2h_endofpacket),
        .t2h_empty            (t2h_empty),
        .t2h_channel          (t2h_channel),
        .mgmt_valid           (mgmt_valid),
        .mgmt_data            (mgmt_data),
        .mgmt_channel         (mgmt_channel)
	
	);

endmodule
