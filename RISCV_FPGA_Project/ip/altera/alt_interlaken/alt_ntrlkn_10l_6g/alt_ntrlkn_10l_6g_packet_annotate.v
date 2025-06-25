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
// baeckler - 04-14-2009

module alt_ntrlkn_10l_6g_packet_annotate #(
	parameter WORDS = 4,
	parameter LOG_WORDS = 4
)
(
	input clk,arst,

	input [WORDS * 65 - 1:0] din,  // valid words toward MS end
        // bit 64=1 for control
	input [LOG_WORDS-1:0] num_din_valid,

	output reg [WORDS*64-1:0] dout,
	output reg [WORDS-1:0] dout_words_valid,
	output reg [WORDS-1:0] dout_sop,
	output reg [WORDS*4-1:0] dout_eopbits
);

//////////////////////////////////////////
// input registers
//////////////////////////////////////////

reg [WORDS * 65-1:0] datwords_r;
reg [LOG_WORDS-1:0] datwords_valid_r;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		datwords_r <= {WORDS*65{1'b0}};
		datwords_valid_r <= {LOG_WORDS{1'b0}};
	end
	else begin
		datwords_r <= din;
		datwords_valid_r <= num_din_valid;
	end
end

//////////////////////////////////////////
// identify payload and packet delimiter words
//////////////////////////////////////////

// only burst control words have valid channel / SOP info
// burst control or idle words have valid EOP info, referring to previous data
wire [WORDS-1:0] rx_sop,valid_chan_info,valid_eop_info;
wire [WORDS*4-1:0] rx_eop;
wire [WORDS-1:0] payload, is_rightmost_data;
genvar i,j;
generate
	for (i=0; i<WORDS; i=i+1)
	begin : cc
		assign valid_chan_info[i] = datwords_r[i*65+64] & datwords_r[i*65+63] & datwords_r[i*65+62];
		assign valid_eop_info[i] = datwords_r[i*65+64] & datwords_r[i*65+63];
		assign rx_sop[i] = valid_chan_info[i] & datwords_r[i*65+61];
		assign rx_eop[4*(i+1)-1:4*i] = valid_eop_info[i] ? datwords_r[i*65+60:i*65+57] : 4'h0;
		assign payload[i] = !datwords_r[i*65+64] &
						(datwords_valid_r >= (WORDS-i));

		assign is_rightmost_data[i] = !datwords_r[i*65+64] &&
						(datwords_valid_r == (WORDS-i));
	end
endgenerate

wire [3:0] next_eop = rx_eop[WORDS*4-1:(WORDS-1)*4];

//////////////////////////////////////////
// mid registers
//////////////////////////////////////////

reg [WORDS * 65-1:0] datwords_rr;
reg [LOG_WORDS-1:0] datwords_valid_rr;
reg [WORDS-1:0] rx_sop_rr;
reg [WORDS*4-1:0] rx_eop_rr;
reg [WORDS-1:0] payload_rr;
reg valid_rr, rightmost_word_is_data_rr;
wire update;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		datwords_rr <= {WORDS*65{1'b0}};
		datwords_valid_rr <= {LOG_WORDS{1'b0}};
		rx_sop_rr <= {WORDS{1'b0}};
		rx_eop_rr <= {WORDS*4{1'b0}};
		payload_rr <= {WORDS{1'b0}};
		valid_rr <= 1'b0;
		rightmost_word_is_data_rr <= 1'b0;
	end
	else begin
		if (update) valid_rr <= 1'b0;
		if (|datwords_valid_r) begin
			datwords_rr <= datwords_r;
			datwords_valid_rr <= datwords_valid_r;
			rx_sop_rr <= rx_sop;
			rx_eop_rr <= rx_eop;
			payload_rr <= payload;
			valid_rr <= 1'b1;
			rightmost_word_is_data_rr <= |is_rightmost_data;
		end
	end
end

//////////////////////////////////////////
// last registers
//////////////////////////////////////////

wire [WORDS-1:0] last_word_mask;
generate
	for (i = 0; i<WORDS; i=i+1) begin : ms
		assign last_word_mask [i] =
			((WORDS - datwords_valid_rr) == i);
	end
endgenerate

reg last_sop;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		last_sop <= 1'b0;
	end
	else begin
		if (|datwords_valid_r) begin
			// pull SOP from the rightmost valid word of the mid registers
			last_sop <= |(rx_sop_rr & last_word_mask);
		end
	end
end

//////////////////////////////////////////
// gather up output
//////////////////////////////////////////

wire [WORDS*64-1:0] dout_i;
wire [WORDS-1:0] dout_words_valid_i;
wire [WORDS-1:0] dout_sop_i;
wire [WORDS*4-1:0] dout_eopbits_i;

wire [WORDS-1:0] rightmost_payload;
assign rightmost_payload[0] = payload_rr[0];
generate
	for (i=1;i<WORDS;i=i+1) begin : rt
		assign rightmost_payload[i] = payload_rr[i]	& (~|payload_rr[i-1:0]);
	end
endgenerate

wire future_eop_needed = rightmost_word_is_data_rr;

assign  update = valid_rr & (!future_eop_needed | (|datwords_valid_r));

wire [4*WORDS-1:0] eop_mask, last_eop_mask;
generate
	for (i=0;i<WORDS;i=i+1) begin : sel
		// drop the control bits from data words
		assign dout_i[(i+1)*64-1:i*64] = datwords_rr[(i+1)*65-2:i*65];

		// blank out EOP associated with unused words
		assign eop_mask[(i+1)*4-1:i*4] = dout_words_valid_i[i] ? 4'hf : 4'h0;

		//
		assign last_eop_mask[(i+1)*4-1:i*4] = rightmost_payload[i] ? 4'hf : 4'h0;
	end
endgenerate

assign dout_words_valid_i = payload_rr & {WORDS{update}};
assign dout_sop_i = {last_sop,rx_sop_rr[WORDS-1:1]} & dout_words_valid_i;
assign dout_eopbits_i = (({WORDS{next_eop}}&last_eop_mask) |
						{rx_eop_rr[(WORDS-1)*4-1:0],4'h0})
						& eop_mask;

//////////////////////////////////////////
// output registers
//////////////////////////////////////////

always @(posedge clk or posedge arst) begin
	if (arst) begin
		dout <= {WORDS*64{1'b0}};
		dout_words_valid <= {WORDS{1'b0}};
		dout_sop <= {WORDS{1'b0}};
		dout_eopbits <= {WORDS*4{1'b0}};
	end
	else begin
		dout <= dout_i;
		dout_words_valid <= dout_words_valid_i;
		dout_sop <= dout_sop_i;
		dout_eopbits <= dout_eopbits_i;
	end
end

endmodule
