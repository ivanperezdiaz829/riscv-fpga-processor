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
// Copyright 2010 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

// baeckler - 06-10-2010

module alt_e40_avalon_tb_packet_gen_sanity_check #(
	parameter WORDS = 2,
	parameter WIDTH = 64	
)(
	input clk,
	input clr_cntrs,
			
	input [WORDS-1:0] sop,
	input [WORDS*8-1:0] eop,
	input [WORDS*WIDTH-1:0] din,
	input din_valid,
	
	output [31:0] bad_term_cnt,
	output [31:0] bad_serial_cnt,
	output [31:0] bad_dest_cnt,
	
	output reg [WORDS*16-1:0] sernum
);

initial sernum = 0;

wire [WORDS*6*8-1:0] mac_dest = {
	48'h0007ed_ff1234,
	48'hffffff_ffffff,
	48'h0007ed_ff0000,
	48'h123456_ff1234,
	48'h00215a_bdde43	
};

// check for fixed string in EOP words
// check for one of the known dest addresses
// check the serial number associated with that dest

reg [WORDS-1:0] sop_rr = 0, sop_r = 0;
reg [WORDS*8-1:0] eop_r = 0;
reg [WORDS*WIDTH-1:0] din_r = 0;

always @(posedge clk) begin
	din_r <= din;
	eop_r <= din_valid ? eop : {(WORDS*8){1'b0}};
	sop_r <= din_valid ? sop : {WORDS{1'b0}};
	sop_rr <= sop_r;
end

wire [WIDTH-1:0] expect_term = "caboose.";
reg [WORDS-1:0] bad_term = 0;
reg [WORDS-1:0] bad_dest = 0;
reg [WORDS-1:0] bad_serial = 0;
wire [WORDS*WORDS-1:0] ser_inc;
wire [WORDS-1:0] merged_inc;
		
genvar i,k;
generate
	for (i=0; i<WORDS; i=i+1) begin : mt
		wire [WIDTH-1:0] tmp_din_word = din_r[(i+1)*WIDTH-1:i*WIDTH];
		reg [WORDS-1:0] dst_match = 0;
		reg [WORDS-1:0] serial_match = 0;
		
		for (k=0; k<WORDS; k=k+1) begin : tm
			always @(posedge clk) begin
				dst_match[k] <= sop_r[i] && (tmp_din_word[WIDTH-1:16] ==
					mac_dest[(k+1)*48-1:k*48]);	
				serial_match[k] <= (tmp_din_word[15:0] == sernum [(k+1)*16-1:k*16]);				
			end			
		end
		assign ser_inc[(i+1)*WORDS-1:i*WORDS] = dst_match & serial_match;
				
		wire [7:0] term_byte_match;
		wire [7:0] term_match_required;
		wire [7:0] tmp_eop = eop_r[(i+1)*8-1:i*8];
		
		for (k=0; k<8; k=k+1) begin : et
			assign term_byte_match[k] = tmp_din_word[(k+1)*8-1:k*8] == 
				expect_term[(k+1)*8-1:k*8];
			
			// cheezy way to detect padded packets
			assign term_match_required[k] = !tmp_eop[4] & (|tmp_eop[k:0]);
		end							
		
		always @(posedge clk) begin
			bad_term[i] <= |(~term_byte_match & term_match_required);
			bad_dest[i] <= sop_rr[i] & ~|dst_match;			
			bad_serial[i] <= |(dst_match & ~serial_match);
		end		

		wire [WORDS-1:0] tmp_inc;
		for (k=0; k<WORDS; k=k+1) begin : mi
			assign tmp_inc[k] = ser_inc[WORDS*k+i];
		end
		assign merged_inc[i] = |tmp_inc;
				
		always @(posedge clk) begin
			if (merged_inc[i]) sernum [(i+1)*16-1:i*16] <=
				sernum [(i+1)*16-1:i*16] + 1'b1;
		end
	end
endgenerate

////////////////////////////////////////////////
// error counters


alt_e40_stat_cntr_1port sc0 (
	.clk(clk), 
	.ena(1'b1),
	.sclr(clr_cntrs),
	.inc(|bad_term),
	.cntr(bad_term_cnt)
);

alt_e40_stat_cntr_1port sc1 (
	.clk(clk), 
	.ena(1'b1),
	.sclr(clr_cntrs),
	.inc(|bad_serial),
	.cntr(bad_serial_cnt)
);

alt_e40_stat_cntr_1port sc2 (
	.clk(clk), 
	.ena(1'b1),
	.sclr(clr_cntrs),
	.inc(|bad_dest),
	.cntr(bad_dest_cnt)
);


endmodule