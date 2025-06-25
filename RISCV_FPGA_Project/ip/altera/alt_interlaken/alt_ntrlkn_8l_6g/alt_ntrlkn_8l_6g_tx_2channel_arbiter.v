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

// baeckler - 10-03-2008

module alt_ntrlkn_8l_6g_tx_2channel_arbiter # (
	parameter NUM_DAT_WORDS = 8,
	parameter LOG_DAT_WORDS = 4, // enough bits to represent 0..#dat inclusive
	parameter CHANID0 = 8'd0,
	parameter CHANID1 = 8'd1
)
(
	input clk, arst,
	
	input [1:0] channel_enables,
	
	// input ports
	input [64*NUM_DAT_WORDS-1:0] tx_ch0_avl_data,
	input tx_ch0_avl_sop,
	input tx_ch0_avl_eop,
	input tx_ch0_avl_valid,
        input [5-1:0] tx_ch0_avl_empty,
        input tx_ch0_avl_error,
        output tx_ch0_avl_ready,
	
	input [64*NUM_DAT_WORDS-1:0] tx_ch1_avl_data,
	input tx_ch1_avl_sop,
	input tx_ch1_avl_eop,
	input tx_ch1_avl_valid,
        input [5-1:0] tx_ch1_avl_empty,
        input tx_ch1_avl_error,
        output tx_ch1_avl_ready,
	
	// output port	
	output reg [LOG_DAT_WORDS-1:0] num_datwords_valid,
	output reg [64*NUM_DAT_WORDS-1:0] datwords,
	output reg [7:0] chan,
	output reg sop,
	output reg [3:0] eopbits,
	input ready,
	output valid		
);

localparam ARB_CHANS = 2;

wire [LOG_DAT_WORDS-1:0] num_chan0words_valid;
wire [64*NUM_DAT_WORDS-1:0] chan0words;
wire chan0sop;
wire [3:0] chan0eopbits;
wire chan0ready;
wire chan0valid;

wire [LOG_DAT_WORDS-1:0] num_chan1words_valid;
wire [64*NUM_DAT_WORDS-1:0] chan1words;
wire chan1sop;
wire [3:0] chan1eopbits;
wire chan1ready;
wire chan1valid;

alt_ntrlkn_8l_6g_avalon_to_ilk_adapter_4 atx0 ( 
     .avl_data(tx_ch0_avl_data),
     .avl_sop(tx_ch0_avl_sop),
     .avl_eop(tx_ch0_avl_eop),
     .avl_valid(tx_ch0_avl_valid),
     .avl_empty(tx_ch0_avl_empty),
     .avl_error(tx_ch0_avl_error),
     .avl_ready(tx_ch0_avl_ready),
     .ilk_data(chan0words),
     .ilk_num_valid(num_chan0words_valid),
     .ilk_sop(chan0sop),
     .ilk_eopbits(chan0eopbits),
     .ilk_valid(chan0valid),
     .ilk_ready(chan0ready)
);

alt_ntrlkn_8l_6g_avalon_to_ilk_adapter_4 atx1 ( 
     .avl_data(tx_ch1_avl_data),
     .avl_sop(tx_ch1_avl_sop),
     .avl_eop(tx_ch1_avl_eop),
     .avl_valid(tx_ch1_avl_valid),
     .avl_empty(tx_ch1_avl_empty),
     .avl_error(tx_ch1_avl_error),
     .avl_ready(tx_ch1_avl_ready),
     .ilk_data(chan1words),
     .ilk_num_valid(num_chan1words_valid),
     .ilk_sop(chan1sop),
     .ilk_eopbits(chan1eopbits),
     .ilk_valid(chan1valid),
     .ilk_ready(chan1ready)
);

reg [ARB_CHANS-1:0] qualified_req;
always @(posedge clk or posedge arst) begin
	if (arst) begin
		qualified_req <= 0;
	end
	else begin
		qualified_req[0] <= channel_enables[0] & chan0valid & (|num_chan0words_valid);
		qualified_req[1] <= channel_enables[1] & chan1valid & (|num_chan1words_valid);
	end
end

/////////////////////////////////////
// arbiter with rotating fairness

reg [ARB_CHANS-1:0] base,grant;
wire [ARB_CHANS-1:0] grant_w;
reg [0:0] enc_grant;

always @(posedge clk or posedge arst) begin
	if (arst) begin
		base <= 1;
		grant <= 0;
		enc_grant <= 0;
	end
	else begin
		if (ready) begin
			base <= {base[ARB_CHANS-2:0],base[ARB_CHANS-1]};
			grant <= grant_w;
			enc_grant[0] <= grant_w[1];
		end
	end
end

alt_ntrlkn_8l_6g_arbiter arb (
	.req(qualified_req),
	.grant(grant_w),
	.base(base)
);
defparam arb .WIDTH = ARB_CHANS;

/////////////////////////////////////
// ready the winner if any

always @(posedge clk or posedge arst) begin
	if (arst) begin
		num_datwords_valid <= {LOG_DAT_WORDS{1'b0}};
		datwords <= {64*NUM_DAT_WORDS{1'b0}};
		chan <= 8'b0;
		sop <= 1'b0;
		eopbits <= 4'b0;
	end
	else begin
		if (ready) begin
			if (enc_grant == 1'd0) begin
				num_datwords_valid <= num_chan0words_valid & {LOG_DAT_WORDS{chan0valid}};
				datwords <= chan0words;
				sop <= chan0sop;
				eopbits <= chan0eopbits;
				chan <= CHANID0;
			end
			else begin
				num_datwords_valid <= num_chan1words_valid & {LOG_DAT_WORDS{chan1valid}};
				datwords <= chan1words;
				sop <= chan1sop;
				eopbits <= chan1eopbits;
				chan <= CHANID1;
			end
			
			if (~|grant) num_datwords_valid <= 0;	
		end
	end
end

assign chan0ready = grant[0] & ready;
assign chan1ready = grant[1] & ready;
assign valid = |num_datwords_valid;

endmodule
