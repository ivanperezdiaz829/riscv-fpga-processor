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

// baeckler - 10-31-2008
// modified 2-12-2009

// Pull a specific channel out of the raw Interlaken data stream.
// For a datapath delivering 2 words per cycle
//
// PROBLEM - this pipeline is kind of silly for only 2 words.  Reduce it.

module alt_ntrlkn_4l_6g_rx_channel_filter_2 (
	input clk, arst,

	input datwords_valid,
	input [65*2-1:0] datwords,

	output reg [1:0] num_chanwords_valid,
	output reg [65*2-1:0] chanwords
);

parameter CHAN_NUM = 8'h1;
localparam WORDS = 2;

//////////////////////////////
// input registers
//////////////////////////////
reg [65*WORDS-1:0] datwords_r;
reg datwords_valid_r;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		datwords_r <= {(65*WORDS){1'b0}};
		datwords_valid_r <= 1'b0;
	end
	else begin
		datwords_r <= datwords;
		datwords_valid_r <= datwords_valid;
	end
end

///////////////////////////////
// mark where channels start and end
///////////////////////////////
// only burst control words have valid channel / SOP info
// burst control or idle words have valid EOP info, referring to previous data
wire [WORDS-1:0] chan_match, valid_chan_info, valid_eop_info;
genvar i;
generate
   for (i=0; i<WORDS; i=i+1)
      begin : cc
         assign chan_match[i] = (datwords_r[i*65+39:i*65+32] == CHAN_NUM) ? 1'b1 : 1'b0;
         assign valid_chan_info[i] = datwords_r[i*65+64] & datwords_r[i*65+63] & datwords_r[i*65+62];
         assign valid_eop_info[i] = datwords_r[i*65+64] & datwords_r[i*65+63];
      end
endgenerate

// the same burst control word could be both a start and stop point
// don't count an immediate continue on the same channel as a stop
reg [WORDS-1:0] start_mine, stop_mine;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		start_mine <= {WORDS{1'b0}};
		stop_mine <= {WORDS{1'b0}};
	end
	else begin
		start_mine <= chan_match & valid_chan_info;
		stop_mine <= valid_eop_info & ~(chan_match & valid_chan_info);
	end
end

// stall the data stream
reg [65*WORDS-1:0] datwords_rr;
reg datwords_valid_rr;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		datwords_rr <= {(65*WORDS){1'b0}};
		datwords_valid_rr <= 1'b0;
	end
	else begin
		datwords_rr <= datwords_r;
		datwords_valid_rr <= datwords_valid_r;
	end
end

/////////////////////////////////////
// mark words between start and end
/////////////////////////////////////
reg last_mine, prev_last_mine;
wire mine_w1 = last_mine | start_mine[1];
wire mine_w0 = (mine_w1 & !stop_mine[1]) | start_mine[0];
wire mine_wlast = mine_w0 & !stop_mine[0];

// leftmost MS word is 1st arrival
reg [WORDS-1:0] mine;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		mine <= {WORDS{1'b0}};
		last_mine <= 1'b0;
		prev_last_mine <= 1'b0;
	end
	else begin
           // reverse to get mine[0] referring to most significant word
           mine <= {mine_w0,mine_w1} & {WORDS{datwords_valid_rr}};
           last_mine <= datwords_valid_rr ? mine_wlast : last_mine;
           prev_last_mine <= datwords_valid_rr ? last_mine : prev_last_mine;
	end
end

// On "stops" the SOP field is not referring to data for
// this channel so mask it out.
wire [65*WORDS-1:0] sop_info_mask;
generate
    for (i=0; i<WORDS; i=i+1) begin : smsk
        assign sop_info_mask[(i+1)*65-1:i*65] =
            stop_mine[i] ?
                {{3{1'b1}},1'b0,{61{1'b1}}} :
                {65{1'b1}};
    end
endgenerate

/////////////////////////
// sanity check
/////////////////////////
// synthesis translate off
generate
    for (i=0; i<WORDS; i=i+1) begin : scheck
        always @(posedge clk) begin
            if (stop_mine[i] & !datwords_rr[i*65+64]) begin
                $display ("Warning: Burst stop on a non-control word?");
            end
        end
    end
endgenerate
// synthesis translate on

// stall the data stream
reg [65*WORDS-1:0] datwords_rrr;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		datwords_rrr <= {(65*WORDS){1'b0}};
	end
	else begin
		datwords_rrr <= sop_info_mask & datwords_rr;
	end
end

/////////////////////////////////////
// Recode mine flags into indices
/////////////////////////////////////
reg [1:0] num_mine;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		num_mine <= 2'h0;
	end
	else begin
		num_mine[1] <= mine[1] & mine[0];
		num_mine[0] <= mine[1] ^ mine[0];
	end
end

// figure out which din word if any drives output page
reg mines_before1;		  // 0..1

always @(posedge clk or posedge arst) begin
	if (arst) begin
		mines_before1 <= 1'b0;
	end
	else begin
		mines_before1 <= mine[0];
	end
end

// Words which start off a burst belonging to this
// channel do not have relevant EOP info.
wire [65*WORDS-1:0] eop_info_mask;
assign eop_info_mask = {
    ((mine[0] & !prev_last_mine) ? {{4{1'b1}},4'b0,{57{1'b1}}} : {65{1'b1}}) ,
    ((mine[1] & !mine[0]) ? {{4{1'b1}},4'b0,{57{1'b1}}} : {65{1'b1}})
};

/////////////////////////
// sanity check
/////////////////////////

// synthesis translate off
wire [65*WORDS-1:0] start_mask;
always @(posedge clk) begin
    if (mine[0] & !prev_last_mine & !datwords_rrr[1*65+64]) begin
        $display ("Warning: Burst start on a non-control word 0?");
    end
    if (mine[1] & !mine[0] & !datwords_rrr[0*65+64]) begin
        $display ("Warning: Burst start on a non-control word 1?");
    end
end
// synthesis translate on

// stall the data stream
reg [65*WORDS-1:0] datwords_rrrr;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		datwords_rrrr <= {(65*WORDS){1'b0}};
	end
	else begin
		datwords_rrrr <= eop_info_mask & datwords_rrr;
	end
end

/////////////////////////////////////
// group together words for target chan
/////////////////////////////////////
wire [64:0] datword0,datword1;

assign {datword0,datword1} = datwords_rrrr;

reg [64:0] chanword0,chanword1;

reg [1:0] last_num_mine;
reg [1:0] chanword_mask;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		chanword0 <= 65'h0;
		chanword1 <= 65'h0;
		last_num_mine <= 2'h0;
		chanword_mask <= 2'h0;
	end
	else begin
		last_num_mine <= num_mine;
		chanword0 <= (mines_before1 == 1'b0) ? datword1 : datword0;
		chanword1 <= datword1;

		case (num_mine)
			4'h0 : chanword_mask <= 2'b00;
			4'h1 : chanword_mask <= 2'b10;
			default: chanword_mask <= 2'b11;
		endcase
	end
end

// zero out the unused words, for some sanity
wire [65*WORDS-1:0] exp_chanword_mask;
generate
	for (i=0; i<WORDS; i=i+1) begin : msk
           assign exp_chanword_mask[(i+1)*65-1:i*65] = {65{chanword_mask[i]}};
	end
endgenerate

/////////////////////////////////////
// output registers
/////////////////////////////////////
always @(posedge clk or posedge arst) begin
	if (arst) begin
		chanwords <= {(65*2){1'b0}};
		num_chanwords_valid <= 2'h0;
	end
	else begin
		chanwords <= {chanword0,chanword1} &
					exp_chanword_mask;
		num_chanwords_valid <= last_num_mine;
	end
end

endmodule
