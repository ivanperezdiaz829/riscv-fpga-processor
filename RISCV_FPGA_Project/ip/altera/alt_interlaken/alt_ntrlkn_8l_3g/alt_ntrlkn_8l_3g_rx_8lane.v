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

module alt_ntrlkn_8l_3g_rx_8lane #(
	parameter CALENDAR_PAGES = 16, // 16 bits per page; Legal settings 16,8, and 1.
	parameter LOG_CALENDAR_PAGES = 4, // 4 for 16 page, 256 bit; 3 for 8 pgs, 128bits; 1 for 1pg, 16 bits
	parameter META_FRAME_LEN = 2048,  // Nominal 2K to 8K
	parameter SKIP_RX_CRC32 = 1'b0
	)
	(
	// 20 bit continuous stream from SERDES pins
	input [20*8-1:0] rx_data,
	input [8-1:0] lane_clk,
	input [8-1:0] lane_arst,
		
	input common_clk, common_arst,
	output locked,
	
	output [65*2-1:0] outwords,
    output outwords_valid,
    output crc24_err,
    output overflow,
    output [16*CALENDAR_PAGES-1:0] calendar,
    
    // NOTE : these are still on the respective lane clock domains
	output [8-1:0] word_locked,
	output [8-1:0] sync_locked,
	output [8-1:0] framing_error,
	output [8-1:0] crc32_error,
	output [8-1:0] scrambler_mismatch,
	output [8-1:0] missing_sync
	
);


localparam NUM_LANES = 8;
localparam INTERNAL_WORDS = 2;
localparam LANE_DAT_WIDTH = 66; // {sync, control, 64 data bits}

//////////////////////////////////////////
// Take data from SERDES, align to words 
// and descramble, CRC32 check

wire [LANE_DAT_WIDTH*NUM_LANES-1:0] unaligned_dat;
wire [NUM_LANES-1:0] unaligned_dat_valid;
genvar i;
generate 
	for (i=0; i<NUM_LANES; i=i+1)
	begin : lrl
		alt_ntrlkn_8l_3g_lane_rx lrx (
			.clk(lane_clk[i]),
			.arst(lane_arst[i]),
			.din(rx_data[20*(i+1)-1:20*i]),
			.dout(unaligned_dat[LANE_DAT_WIDTH*(i+1)-1:LANE_DAT_WIDTH*i]),  
					// [65]=1 indicates sync [64]=1 indicates control words
			.dout_valid(unaligned_dat_valid[i]),
			.word_locked(word_locked[i]),
			.sync_locked(sync_locked[i]),
			.framing_error(framing_error[i]),
			.crc32_error(crc32_error[i]),
			.scrambler_mismatch(scrambler_mismatch[i]),
			.missing_sync(missing_sync[i])		
		);	
		defparam lrx .META_FRAME_LEN = META_FRAME_LEN;
		defparam lrx .SKIP_RX_CRC32 = SKIP_RX_CRC32;
	end
endgenerate

//////////////////////////////////////////
// use sync words to align the lanes - they may be a few words off
// the lane RX provides an extra sync bit to recognize where
// sync words occur, to save duplicating a comparator array.
//
wire [LANE_DAT_WIDTH*NUM_LANES-1:0] lanewords;
wire lanewords_valid;

wire [NUM_LANES-1:0] lanewords_valid_tmp;
assign lanewords_valid = lanewords_valid_tmp[0];
alt_ntrlkn_8l_3g_alignment_pipe #(
	.NUM_LANES(NUM_LANES),
	.LANE_DAT_WIDTH(LANE_DAT_WIDTH) // {sync, control, 64 data bits}
)
lal
(
	.lane_clk(lane_clk),
	.lane_arst(lane_arst),
	.lane_din(unaligned_dat),
	.lane_din_valid(unaligned_dat_valid),
	
	.common_clk(common_clk),
	.common_arst(common_arst),
	.locked(locked),
	.dout(lanewords),
	.dout_valid(lanewords_valid_tmp)
);

// strip the sync marker bits out of the aligned data 
wire [65*NUM_LANES-1:0] aligned_words;
wire aligned_words_valid;
generate
	for (i=0; i<NUM_LANES; i=i+1) begin : aw
		assign aligned_words[(i+1)*65-1:i*65] = lanewords[(i+1)*66-2:i*66];		
	end
endgenerate

// invalidate framing layer control words - done with them
// when the lanes are aligned they will be 1) all framing words 
// or 2) all not framing words
assign aligned_words_valid = lanewords_valid & !(lanewords[64] & !lanewords[63]);

//////////////////////////////////////////
// Extract burst data and check CRC24s    
alt_ntrlkn_8l_3g_rx_datapath_8lane rdp (
    .clk(common_clk),
    .arst(common_arst),
    .lanewords(aligned_words),
    .lanewords_valid(aligned_words_valid),
    .outwords(outwords),
    .outwords_valid(outwords_valid),
    .crc24_err(crc24_err),
    .overflow(overflow),
    .calendar(calendar)
);
defparam	rdp.CALENDAR_PAGES = CALENDAR_PAGES; // 16 bits per page
defparam	rdp.LOG_CALENDAR_PAGES = LOG_CALENDAR_PAGES; // 4 for 16 page, 256 bit.

endmodule
