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


// altera_trace_controller_endpoint.sv

`timescale 1 ns / 1 ns

module altera_trace_controller_endpoint_wrapper #(
    parameter ADDR_WIDTH                     = 10,
    parameter DATA_WIDTH                     = 32,
    parameter MEMSIZE                        = 32768,
    parameter EXTMEM_BASE                    = 0,
    parameter EXTMEM_SIZE                    = 1048576,
    parameter TRACEID                        = "",
    parameter TRACEID_PRIORITY               = 100,
    parameter PREFER_HOST                    = "",
    parameter CLOCK_RATE_CLK                 = 0
) (
    input         clk,
    output        reset,
    output        master_write,
    output        master_read,
    output [ADDR_WIDTH-1:0] master_address,
    output [DATA_WIDTH-1:0] master_writedata,
    input         master_waitrequest,
    input         master_readdatavalid,
    input  [DATA_WIDTH-1:0] master_readdata
);

function integer nonzero;
input value;
begin
	nonzero = (value > 0) ? value : 1;
end
endfunction

	altera_trace_controller_endpoint #(
        .ADDR_WIDTH                     (ADDR_WIDTH),
        .DATA_WIDTH                     (DATA_WIDTH),
        .MEMSIZE                        (MEMSIZE),
        .EXTMEM_BASE                    (EXTMEM_BASE),
        .EXTMEM_SIZE                    (EXTMEM_SIZE),
        .TRACEID                        (TRACEID),
        .TRACEID_PRIORITY               (TRACEID_PRIORITY),
        .PREFER_HOST                    (PREFER_HOST),
        .CLOCK_RATE_CLK                 (CLOCK_RATE_CLK)
) inst (
        .clk                            (clk),
        .reset                          (reset),
        .master_write                   (master_write),
        .master_read                    (master_read),
        .master_address                 (master_address),
        .master_writedata               (master_writedata),
        .master_waitrequest             (master_waitrequest),
        .master_readdatavalid           (master_readdatavalid),
        .master_readdata                (master_readdata)
	
	);

endmodule
