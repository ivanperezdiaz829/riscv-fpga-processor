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


// baeckler - 05-04-2009
// pull valid words, bit masked in any postion, together
// toward the more significant end with a count.

`timescale 1 ps / 1 ps

module alt_e100_wide_compact_words_8 #(
	parameter WORDS = 8,
	parameter WORD_LEN = 64	
)
(
	input clk, arst,

	input [WORDS-1:0] din_valid_mask, // MSbit = MS word is used
	input [WORDS*WORD_LEN-1:0] din_words,
	
	// packed toward more significant end
	output [WORDS*WORD_LEN-1:0] dout_words,
	output [3:0] num_dout_words_valid	
);

reg [WORDS*WORD_LEN-1:0] din_words_r;

// word numbering {0..7}, msb to lsb
wire [WORDS-1:0] din_word_valid;
genvar i;
generate
	for (i=0; i<WORDS; i=i+1) begin : vm
		assign din_word_valid[i] = din_valid_mask [WORDS-1-i];
	end	
endgenerate

reg [3:0] num_valid;
wire [2:0] valids_before6_w, valids_before4_w;
alt_e100_wide_six_three_comp sc0 (.data(din_word_valid[5:0]),.sum(valids_before6_w));
alt_e100_wide_six_three_comp sc1 (.data({2'b00,din_word_valid[3:0]}),.sum(valids_before4_w));

always @(posedge clk or posedge arst) begin
	if (arst) begin
		num_valid <= 0;
		din_words_r <= 0;
	end
	else begin
		num_valid <= valids_before6_w + 
				((din_word_valid[7] & din_word_valid[6]) ? 3'd2 :
				(din_word_valid[7] | din_word_valid[6]) ? 3'd1 : 3'd0);
		din_words_r <= din_words;
	end	
end

// figure out which din word if any drives output page
reg valids_before1;		  // 0..1
reg [1:0] valids_before2; // 0..2
reg [1:0] valids_before3; // 0..3
reg [2:0] valids_before4; // 0..4
reg [2:0] valids_before5; // 0..5
reg [2:0] valids_before6; // 0..6
reg [2:0] valids_before7; // 0..7
//reg valid_7;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		valids_before1 <= 0;
		valids_before2 <= 0;
		valids_before3 <= 0;
		valids_before4 <= 0;
		valids_before5 <= 0;
		valids_before6 <= 0;
		valids_before7 <= 0;
		//valid_7 <= 0;		
	end
	else begin
		valids_before1 <= din_word_valid[0];
		valids_before2 <= {din_word_valid[1] & din_word_valid[0], din_word_valid[1] ^ din_word_valid[0]};
		valids_before3 <= valids_before4_w[1:0] - (din_word_valid[3] ? 1'b1 : 1'b0); // originally 3 -> 2 bits
		valids_before4 <= valids_before4_w;
		valids_before5 <= valids_before6_w - (din_word_valid[5] ? 1'b1 : 1'b0);
		valids_before6 <= valids_before6_w;
		valids_before7 <= valids_before6_w + (din_word_valid[6] ? 1'b1 : 1'b0);				
		//valid_7 <= din_word_valid[7];
	end	
end

///////////////////////////////////////
// layer 2 - mux valid words into an adjacent group
///////////////////////////////////////

wire [WORD_LEN-1:0] din_r_0, din_r_1, din_r_2, din_r_3, din_r_4,
			din_r_5, din_r_6, din_r_7;
			
assign {din_r_0, din_r_1, din_r_2, din_r_3, din_r_4,
			din_r_5, din_r_6, din_r_7} = din_words_r;
			
reg [WORD_LEN-1:0] outword0, outword1, outword2, outword3, 
				outword4, outword5, outword6, outword7;

reg [3:0] last_num_valid;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		outword0 <= 0;
		outword1 <= 0;
		outword2 <= 0;
		outword3 <= 0;
		outword4 <= 0;
		outword5 <= 0;
		outword6 <= 0;
		outword7 <= 0;		
		last_num_valid <= 0;
	end
	else begin
		last_num_valid <= num_valid;
		outword0 <= (valids_before7 == 3'b000) ? din_r_7 :
					(valids_before6 == 3'b000) ? din_r_6 :
					(valids_before5 == 3'b000) ? din_r_5 :
					(valids_before4 == 3'b000) ? din_r_4 :
					(valids_before3 == 2'b00) ? din_r_3 :
					(valids_before2 == 2'b00) ? din_r_2 :
					(valids_before1 == 1'b0) ? din_r_1 : din_r_0;
		outword1 <= (valids_before7 == 3'b001) ? din_r_7 :
					(valids_before6 == 3'b001) ? din_r_6 :
					(valids_before5 == 3'b001) ? din_r_5 :
					(valids_before4 == 3'b001) ? din_r_4 :
					(valids_before3 == 2'b01) ? din_r_3 :
					(valids_before2 == 2'b01) ? din_r_2 : din_r_1;
		outword2 <= (valids_before7 == 3'b010) ? din_r_7 :
					(valids_before6 == 3'b010) ? din_r_6 :
					(valids_before5 == 3'b010) ? din_r_5 :
					(valids_before4 == 3'b010) ? din_r_4 :
					(valids_before3 == 2'b10) ? din_r_3 : din_r_2;
		outword3 <= (valids_before7 == 3'b011) ? din_r_7 :
					(valids_before6 == 3'b011) ? din_r_6 :
					(valids_before5 == 3'b011) ? din_r_5 :
					(valids_before4 == 3'b011) ? din_r_4 : din_r_3;
		outword4 <= (valids_before7 == 3'b100) ? din_r_7 :
					(valids_before6 == 3'b100) ? din_r_6 :
					(valids_before5 == 3'b100) ? din_r_5 : din_r_4;
		outword5 <= (valids_before7 == 3'b101) ? din_r_7 :
					(valids_before6 == 3'b101) ? din_r_6 : din_r_5;
		outword6 <= (valids_before7 == 3'b110) ? din_r_7 : din_r_6;
		outword7 <= din_r_7;					
	end
end

assign dout_words = {outword0, outword1, outword2, outword3, 
				outword4, outword5, outword6, outword7};

assign num_dout_words_valid = last_num_valid;

endmodule
