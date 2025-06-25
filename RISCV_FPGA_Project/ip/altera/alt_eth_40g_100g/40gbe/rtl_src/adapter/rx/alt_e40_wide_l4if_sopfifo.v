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



///////////////////////////////////////////////////////////////////////////////
//
// Description: fast 5 bit x 4 fifo
//
// Authors:     ishimony
//
///////////////////////////////////////////////////////////////////////////////

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

// timing optimizations:
// 36: remove read underflow protection, seperate ptr logic

module alt_e40_wide_l4if_sopfifo(
    reset, clock, data, rdreq, wrreq, q, usedw
); // module alt_e40_wide_l4if_sopfifo
parameter WIDTH     = 3;
parameter DEPTH     = 4;
parameter LOG2DEPTH = 2;

input                   reset;
input                   clock;
input   [WIDTH-1:0]     data;
input                   rdreq;
input                   wrreq;
output  [WIDTH-1:0]     q;
output  [LOG2DEPTH-1:0] usedw;

//--- port types
wire                    clock;
wire    [WIDTH-1:0]     data;
wire                    rdreq;
wire                    wrreq;
wire    [WIDTH-1:0]     q;
reg     [LOG2DEPTH-1:0] usedw = 0;

//--- local
reg     [LOG2DEPTH-1:0] wptr  = 0;
reg     [LOG2DEPTH-1:0] rptr  = 0;
//1 reg [WIDTH-1:0]     array [DEPTH-1:0];
reg   [WIDTH*DEPTH-1:0] array = 0;

//--- main
always @(posedge clock) begin
    if (wrreq & (usedw < DEPTH)) begin
//1     array[wptr] <= data;
        array[wptr*WIDTH +: WIDTH] <= data;
    end
end
always @(posedge clock or posedge reset) begin
    if (reset) wptr <= 0;
    else if (wrreq & (usedw < DEPTH)) begin
        wptr        <= wptr + 1'b1;
    end
end
always @(posedge clock or posedge reset) begin
    if (reset) rptr <= 0;
    else if (rdreq) begin
        rptr <= rptr + 1'b1;
    end
end
always @(posedge clock or posedge reset) begin
    if (reset) usedw <= 0;
    else if (wrreq & !rdreq & (usedw < DEPTH)) begin
        usedw <= usedw + 1'b1; 
    end else if (!wrreq & rdreq) begin
        usedw <= usedw - 1'b1; 
    end
end

//1 assign q = array[rptr];
assign q = array[rptr*WIDTH +: WIDTH];

endmodule // alt_e40_wide_l4if_sopfifo

