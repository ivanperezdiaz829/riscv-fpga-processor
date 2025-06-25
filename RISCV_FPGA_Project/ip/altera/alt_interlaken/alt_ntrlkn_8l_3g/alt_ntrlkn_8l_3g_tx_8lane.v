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


// baeckler - 10-17-2008
// 2 word protocol datapath feeding 8 lane TX units

module alt_ntrlkn_8l_3g_tx_8lane #(
	parameter ENHANCED_SCHED_ENABLE = 0, // for 8-word case, 1 = allow IP to occasionally violate BurstMax to avoid Idles.
	parameter CALENDAR_PAGES = 16, // 16 bits per page; Legal settings 16,8, and 1.
	parameter LOG_CALENDAR_PAGES = 4, // 4 for 16 page, 256 bit; 3 for 8 pgs, 128bits; 1 for 1pg, 16 bits
	parameter META_FRAME_LEN = 2048
	)
	(
	input clk,arst,
	input lane_clk,lane_arst,

        input [3:0] burst_max_in, // dynamic burst max input
	input [64*2-1:0] din_words, // fill most significant word first
	input [2-1:0] num_valid_din_words, // e.g. 1=ms word only
	input [7:0] chan,       // logical channel number
	input sop,		// SOP and EOP both refer to the current data in
	input [3:0] eopbits,    // 1000 = eop, 8 bytes valid in last word.  1010 = eop 2 bytes valid
	input [16*CALENDAR_PAGES-1:0] calendar,
	input [3:0] burst_short_in,    // dynamic burst short, value times 32 bytes (4 words).  Legal setting 1, 2
	output ack,
	output hungry,    // warning to send max vaild din words, or idle to recover
	output overflow,  // this should never occur
	output underflow, // this may occur briefly at startup
	
	// 20 bit continuous stream to SERDES pins
    // logical lane 0 is toward the more significant end
    // msbit to be sent first
	output [20*8-1:0] tx_data
);


localparam NUM_LANES = 8;
localparam INTERNAL_WORDS = 2;

// break into words for simulation visiblity
// synthesis translate off
wire [63:0] din_0,din_1;
assign {din_0,din_1} = din_words;
// synthesis translate on

wire [65*NUM_LANES-1:0] lanewords;
wire [65*NUM_LANES-1:0] ltx_din;
wire [NUM_LANES-1:0] ltx_din_ack;
    
alt_ntrlkn_8l_3g_tx_datapath_8lane tdp (
	.clk(clk),
	.arst(arst),
	.lane_clk(lane_clk),
	.lane_arst(lane_arst),
	.burst_max_in(burst_max_in),
	.din_words(din_words),
	.num_valid_din_words(num_valid_din_words),		
	.chan(chan),
	.sop(sop),				// SOP and EOP both refer to the current data in
	.eopbits(eopbits),
	.calendar(calendar),
	.ack(ack),	
	.lanewords(lanewords),
    .lanewords_ack(ltx_din_ack),
    .hungry(hungry),
	.burst_short_in(burst_short_in),
    .overflow(overflow),
    .underflow(underflow)
);

defparam	tdp.CALENDAR_PAGES = CALENDAR_PAGES; // 16 bits per page
defparam	tdp.LOG_CALENDAR_PAGES = LOG_CALENDAR_PAGES; // 4 for 16 page, 256 bit.
defparam	tdp.ENHANCED_SCHED_ENABLE = ENHANCED_SCHED_ENABLE; // 1 = allow IP to occasionally violate BurstMax to avoid Idles

assign ltx_din = lanewords;

genvar i;
generate 
	for (i=0; i<NUM_LANES; i=i+1)
	begin : llp
		alt_ntrlkn_8l_3g_lane_tx ltx (
			.clk(lane_clk),
			.arst(lane_arst),
			.din(ltx_din[65*(i+1)-1:65*i]),	// bit [64] = 1 indicates control word
			.din_ack(ltx_din_ack[i]),
			.dout(tx_data[20*(i+1)-1:20*i])
		);
		// reset the scramblers to different states for each TX lane
		// to improve signal properties
		defparam ltx .SCRAMBLER_RESET = 58'h1234567_89abcdef + (24'hf2da4f * i);
		defparam ltx .META_FRAME_LEN = META_FRAME_LEN;
	end
endgenerate

endmodule
