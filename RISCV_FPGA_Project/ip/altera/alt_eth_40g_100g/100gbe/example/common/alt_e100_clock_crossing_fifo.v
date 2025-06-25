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


`timescale 1 ps / 1 ps

// baeckler - 03-23-2009
// simple clock crossing with ready / valid signals

module alt_e100_clock_crossing_fifo #(
	parameter DAT_WIDTH = 16,
	parameter WORDS = 32
)
(
	input wrclk,
	input wdata_valid,
	input [DAT_WIDTH-1:0] wdata,
	output wdata_ready,
	
	input rdclk,
	input rdata_ready,
	output [DAT_WIDTH-1:0] rdata,
	output reg rdata_valid	
);

`include "alt_e100_log2.iv"

wire wrreq, rdreq, rdempty, wrfull;

assign wdata_ready = !wrfull;
assign wrreq = wdata_valid & wdata_ready;
assign rdreq = !rdempty & (!rdata_valid | rdata_ready);

/////////////////////////
// dev_clr sync-reset
/////////////////////////
alt_e100_user_mode_det dev_clr(
    .ref_clk(rdclk),
    .user_mode_sync(user_mode_sync)
);

initial rdata_valid = 1'b0;
//always @(posedge rdclk) begin
always @(posedge rdclk or negedge user_mode_sync) begin
   if (!user_mode_sync) rdata_valid <= 0;
   else begin
	if (rdata_ready) rdata_valid <= 1'b0;
	if (rdreq) rdata_valid <= 1'b1;
   end
end

dcfifo    dcfifo_component (
            .wrclk (wrclk),
            .rdreq (rdreq),
            .rdclk (rdclk),
            .wrreq (wrreq),
            .data (wdata),
            .rdempty (rdempty),
            .wrfull (wrfull),
            .q (rdata),
            .aclr (1'b0),
            .rdfull (),
            .rdusedw (),
            .wrempty (),
            .wrusedw ()            
);
defparam
    dcfifo_component.intended_device_family = "Stratix II",
    dcfifo_component.lpm_numwords = WORDS,
    dcfifo_component.lpm_showahead = "OFF",
    dcfifo_component.lpm_type = "dcfifo",
    dcfifo_component.lpm_width = DAT_WIDTH,
    dcfifo_component.lpm_widthu = alt_e100_log2(WORDS-1),
    dcfifo_component.overflow_checking = "ON",
    dcfifo_component.rdsync_delaypipe = 4,
    dcfifo_component.underflow_checking = "ON",
    dcfifo_component.use_eab = "ON",
    dcfifo_component.wrsync_delaypipe = 4;

endmodule
