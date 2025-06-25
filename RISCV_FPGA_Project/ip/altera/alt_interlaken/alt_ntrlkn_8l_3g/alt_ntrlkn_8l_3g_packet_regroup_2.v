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


// Allin - 08-11-2010

`timescale 1 ps / 1 ps

module alt_ntrlkn_8l_3g_packet_regroup_2 #(
	parameter WORDS = 2, // do not overwrite!
	parameter WORD_LEN = 64,
	parameter LOG_WORDS = 2  
)
(
	input clk,arst,
	input [WORDS * 65 - 1:0] din,  // valid words toward MS end
									// bit 64=1 for control
	input [LOG_WORDS-1:0] num_din_valid, // 0..2
	 
 	output [WORDS*WORD_LEN-1:0] avl_dout,
	output avl_dout_sop,
 	output avl_dout_eop,
	output [3:0] avl_empty,
        output avl_valid,
        output avl_error,
	output overflow	
);

// NOTE: this is not a rigorous mathematical definition of LOG2(v).
// This function computes the number of bits required to represent "v".
// So log2(256) will be  9 rather than 8 (256 = 9'b1_0000_0000).

function integer log2;
  input integer val;
  begin
	 log2 = 0;
	 while (val > 0) begin
	    val = val >> 1;
		log2 = log2 + 1;
	 end
  end
endfunction

////////////////////////////////////////////
// annotate SOP and EOP onto valid data words
////////////////////////////////////////////

wire [WORDS*WORD_LEN-1:0] annot_words;
wire [WORDS-1:0] annot_words_valid;
wire [WORDS-1:0] annot_sop;
wire [WORDS*4-1:0] annot_eopbits;

alt_ntrlkn_8l_3g_packet_annotate pa 
(
	.clk(clk),
	.arst(arst),
	.din(din),				// valid words toward MS end
						// bit 64=1 for control
	.num_din_valid (num_din_valid),
	 
	.dout(annot_words),
	.dout_words_valid(annot_words_valid),
	.dout_sop(annot_sop),
	.dout_eopbits(annot_eopbits)
);
defparam pa .WORDS = WORDS;
defparam pa .LOG_WORDS = LOG_WORDS;

////////////////////////////////////////////
// expand to words to { SOP, EOP[3:0], data }
////////////////////////////////////////////

localparam EXP_WORD_LEN = WORD_LEN + 1 + 4;
wire [EXP_WORD_LEN*WORDS-1:0] exp_annot;

genvar i;
generate
	for (i=0; i<WORDS; i= i+1) begin : ann
		assign exp_annot [(i+1)*EXP_WORD_LEN-1:i*EXP_WORD_LEN] =
			{annot_sop[i],
			annot_eopbits[(i+1)*4-1:i*4],
			annot_words[(i+1)*WORD_LEN-1:i*WORD_LEN]};
	end
endgenerate

////////////////////////////////////////////
// compact used words together on the bus
// e.g. 10001 to 11000
////////////////////////////////////////////

reg [WORDS*EXP_WORD_LEN-1:0] compact_words;
reg [LOG_WORDS-1:0] num_compact_words_valid;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		compact_words <= {(WORDS*EXP_WORD_LEN){1'b0}};
		num_compact_words_valid <= {(LOG_WORDS){1'b0}};
	end
	else begin
		if (annot_words_valid == 2'b01) begin
			compact_words <= {exp_annot[EXP_WORD_LEN-1:0], {(EXP_WORD_LEN){1'b0}}};
			num_compact_words_valid <= 2'b01;
		end
		else if (annot_words_valid == 2'b10) begin
			compact_words <= exp_annot;
			num_compact_words_valid <= 2'b01;
		end
		else if (annot_words_valid == 2'b11) begin
			compact_words <= exp_annot;
			num_compact_words_valid <= 2'b10;
		end
		else begin
			compact_words <= 2'b0;
			num_compact_words_valid <= 2'b0;
		end
	end
end

////////////////////////////////////////////
// split back up 
////////////////////////////////////////////

wire [WORDS-1:0] compact_sop;
wire [4*WORDS-1:0] compact_eopbits;
wire [WORD_LEN*WORDS-1:0] compact_dat;

generate
	for (i=0; i<WORDS; i= i+1) begin : spl
		assign {compact_sop[i],
				compact_eopbits[(i+1)*4-1:i*4],
				compact_dat[(i+1)*WORD_LEN-1:i*WORD_LEN]} =
				   compact_words [(i+1)*EXP_WORD_LEN-1:i*EXP_WORD_LEN];			  
	end
endgenerate

////////////////////////////////////////////
// realign to SOP boundaries
////////////////////////////////////////////

alt_ntrlkn_8l_3g_regroup_2 rg (	
	.clk(clk),
	.arst(arst),
	.din_num_valid(num_compact_words_valid),  
		// 0..2 valid, grouped toward left
	.din_sop(compact_sop),			// per input word
	.din_eopbits(compact_eopbits), // per input word	
	.din(compact_dat), 
		
	.avl_dout(avl_dout),
	.avl_dout_sop(avl_dout_sop),
 	.avl_dout_eop(avl_dout_eop),
	.avl_empty(avl_empty),
        .avl_valid(avl_valid),
        .avl_error(avl_error),

	.overflow(overflow)	
);
defparam rg .WORD_WIDTH = WORD_LEN;

endmodule
