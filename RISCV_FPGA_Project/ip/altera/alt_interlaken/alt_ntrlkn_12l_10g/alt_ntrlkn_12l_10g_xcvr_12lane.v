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

// baeckler - 11-04-2008
// 12 Lane Interlaken TX RX pair with channel interface
//
module alt_ntrlkn_12l_10g_xcvr_12lane #(
	parameter META_FRAME_LEN = 2048,
	parameter AUTO_UNDERFLOW_PREVENTION = 1'b1,
	parameter DISABLE_HSIO = 1'b1, 
	parameter INTERNAL_WORDS = 8, 
	parameter CALENDAR_PAGES = 16, // 16 bits per page; Legal settings 16,8, and 1.
	parameter LOG_CALENDAR_PAGES = 4 // 4 for 16 page, 256 bit; 3 for 8 pgs, 128bits; 1 for 1pg, 16 bits
	)
	(
	input tx_mac_clk,tx_mac_arst,
	input rx_mac_clk,rx_mac_arst,
	input tx_lane_clk,tx_lane_arst,

	// 40 bit continuous stream to SERDES pins
	//   lane 0 on the ms end, send msbit first
        input [3:0] burst_max_in,
	output [40*12-1:0] tx_data,

	// 40 bit continuous stream from SERDES pins
	//   with per-lane recovered clocks
	input [40*12-1:0] rx_data,
	input [12-1:0] rx_lane_clk,
        output common_rx_coreclk, 

    // TX arbiter port - channel 0
    input [INTERNAL_WORDS*64-1:0] tx_ch0_avl_data,
    input tx_ch0_avl_sop,
    input tx_ch0_avl_eop,
    input tx_ch0_avl_valid,
    input [6-1:0] tx_ch0_avl_empty,
    input tx_ch0_avl_error,
    output tx_ch0_avl_ready,

    // TX arbiter port - channel 1
    input [INTERNAL_WORDS*64-1:0] tx_ch1_avl_data,
    input tx_ch1_avl_sop,
    input tx_ch1_avl_eop,
    input tx_ch1_avl_valid,
    input [6-1:0] tx_ch1_avl_empty,
    input tx_ch1_avl_error,
    output tx_ch1_avl_ready,

    // regrouped RX output stream - channel 0
    output [64*8-1:0] rx_ch0_avl_data,
    output rx_ch0_avl_sop,
    output rx_ch0_avl_eop,
    output [6-1:0] rx_ch0_avl_empty,
    output rx_ch0_avl_error,
    output rx_ch0_avl_valid,

    // regrouped RX output stream - channel 1
    output [64*8-1:0] rx_ch1_avl_data,
    output rx_ch1_avl_sop,
    output rx_ch1_avl_eop,
    output [6-1:0] rx_ch1_avl_empty,
    output rx_ch1_avl_error,
    output rx_ch1_avl_valid,

    // status
    output [12-1:0] rx_per_lane_word_lock,
    output [12-1:0] rx_per_lane_sync_lock,
    output rx_all_word_locked,
    output rx_all_sync_locked,
    output reg rx_fully_locked,   // all locked, and lanes aligned
    output tx_hungry,tx_underflow,tx_overflow,rx_overflow,
    output reg [15:0] rx_locked_time,  // seconds since lock acquired
    output reg [15:0] rx_error_count,  // CRC24 errors since lock acquired
    output [12*8-1:0] rx_per_lane_crc32_errs,
    output [16*CALENDAR_PAGES-1:0] rx_calendar,
    input [16*CALENDAR_PAGES-1:0] tx_calendar,

    // pseudo-dynamic burst control
	input [3:0] burst_short_in,    // dynamic burst short, value times 32 bytes (4 words).  Legal setting 1, 2
    // calendar flow control overrides
    input tx_force_transmit,
    input [2-1:0] tx_channel_enable
);


localparam NUM_LANES = 12;
localparam NUM_CHANS = 2;
localparam LOG_INTERNAL_WORDS = 4;

/////////////////////////////////////////
// generating rx_lane_clk (rx_lane_clk_derived) based on the existence of GX block              
/////////////////////////////////////////
wire [NUM_LANES-1:0] rx_lane_clk_derived; 
assign rx_lane_clk_derived = (DISABLE_HSIO)?rx_lane_clk:{NUM_LANES{rx_lane_clk[6]}};
assign common_rx_coreclk = (DISABLE_HSIO)? 1'b0:rx_lane_clk[6];
/////////////////////////////////////////
// Synchronize arst to RX lane domains
/////////////////////////////////////////
wire [NUM_LANES-1:0] rx_arst;
genvar i;
generate
for (i=0; i<NUM_LANES; i=i+1)
begin : ln
	// RX reset generator, on the RX recovered clock
	reg [2:0] rfilter_rx /* synthesis preserve */;
	always @(posedge rx_lane_clk_derived[i] or posedge rx_mac_arst) begin
		if (rx_mac_arst) rfilter_rx <= 3'b000;
		else rfilter_rx <= {rfilter_rx[1:0],1'b1};
	end
	assign rx_arst[i] = !rfilter_rx[2];
end
endgenerate

//////////////////////////////
// TX arbiter
//////////////////////////////

// If the transmit data pipeline is low the hungry signal will activate
// when hungry it is important to either send no data, which will cause
// idle insertion, or to send valid data faster than the lane bandwidth
// in order to catch up.  AUTO mode will force idles
wire underflow_alarm = tx_hungry & AUTO_UNDERFLOW_PREVENTION;

reg [NUM_CHANS*2-1:0] rx_calendar_s;
wire [LOG_INTERNAL_WORDS-1:0] tx_num_datwords_valid,tx_num_datwords_valid_a;
wire [64*INTERNAL_WORDS-1:0] tx_datwords,tx_datwords_a;
wire [7:0] tx_chan,tx_chan_a;
wire tx_sop,tx_sop_a;
wire [3:0] tx_eopbits,tx_eopbits_a;
wire tx_ready,tx_ready_a,tx_valid,tx_valid_a;
wire [1:0] arb_enables = tx_channel_enable & (rx_calendar_s[NUM_CHANS*2-1:NUM_CHANS] | {2{tx_force_transmit}});

///////////////////////////////////////
// Meta-harden the rx_calendar signal
///////////////////////////////////////
always @(posedge tx_mac_clk or posedge tx_mac_arst) begin
   if (tx_mac_arst) begin
      rx_calendar_s <= {(NUM_CHANS*2){1'b0}};
   end
   else begin
      rx_calendar_s <= {rx_calendar_s[NUM_CHANS-1:0],rx_calendar[NUM_CHANS-1:0]};
   end
end

alt_ntrlkn_12l_10g_tx_2channel_arbiter txarb (
    .clk(tx_mac_clk),
    .arst(tx_mac_arst),
    .channel_enables (arb_enables),

    // input port for channel 0
    .tx_ch0_avl_data(tx_ch0_avl_data),
    .tx_ch0_avl_sop(tx_ch0_avl_sop),
    .tx_ch0_avl_eop(tx_ch0_avl_eop),
    .tx_ch0_avl_valid(tx_ch0_avl_valid),
    .tx_ch0_avl_empty(tx_ch0_avl_empty),
    .tx_ch0_avl_error(tx_ch0_avl_error),
    .tx_ch0_avl_ready(tx_ch0_avl_ready),

    // input port for channel 1
    .tx_ch1_avl_data(tx_ch1_avl_data),
    .tx_ch1_avl_sop(tx_ch1_avl_sop),
    .tx_ch1_avl_eop(tx_ch1_avl_eop),
    .tx_ch1_avl_valid(tx_ch1_avl_valid),
    .tx_ch1_avl_empty(tx_ch1_avl_empty),
    .tx_ch1_avl_error(tx_ch1_avl_error),
    .tx_ch1_avl_ready(tx_ch1_avl_ready),

    // output port to TX unit
    .num_datwords_valid(tx_num_datwords_valid_a),
    .datwords(tx_datwords_a),
    .chan(tx_chan_a),
    .sop(tx_sop_a),
    .eopbits(tx_eopbits_a),
    .valid(tx_valid_a),
    .ready(tx_ready_a) // & !underflow_alarm)
);
defparam txarb .NUM_DAT_WORDS = INTERNAL_WORDS;
defparam txarb .LOG_DAT_WORDS = LOG_INTERNAL_WORDS;

localparam ARBITER_SKID = 1'b1;
generate
    if (ARBITER_SKID) begin
        // register the data and flow control between arb and TX
        alt_ntrlkn_12l_10g_ready_skid askd (
            .clk(tx_mac_clk),
            .arst(tx_mac_arst),
            .valid_i(tx_valid_a),
            .dat_i({tx_num_datwords_valid_a,tx_datwords_a,tx_chan_a,tx_sop_a,tx_eopbits_a}),
            .ready_i(tx_ready_a),
            .valid_o(tx_valid),
            .dat_o({tx_num_datwords_valid,tx_datwords,tx_chan,tx_sop,tx_eopbits}),
            .ready_o(tx_ready & !underflow_alarm)
        );
        defparam askd .WIDTH = LOG_INTERNAL_WORDS + 64*INTERNAL_WORDS + 1+4+8;
    end
    else begin
        // direct connection
        assign tx_num_datwords_valid = tx_num_datwords_valid_a;
        assign tx_datwords = tx_datwords_a;
        assign tx_valid = tx_valid_a;
        assign tx_chan = tx_chan_a;
        assign tx_sop = tx_sop_a;
        assign tx_eopbits = tx_eopbits_a;
        assign tx_ready_a = tx_ready & !underflow_alarm;
    end
endgenerate

//////////////////////////////
// TX unit
//////////////////////////////

reg [16*CALENDAR_PAGES-1:0] tx_calendar_reg;
reg [2:0] lock_sync /* synthesis preserve */;
// once we are locked, drive the TX Calendar bits according to the user application's inputs.

always @(posedge tx_mac_clk or posedge tx_mac_arst) begin
    if (tx_mac_arst) begin
        tx_calendar_reg <= {(16*CALENDAR_PAGES){1'b0}};
        lock_sync <= 3'h0;
    end
    else begin
        lock_sync <= {lock_sync [1:0],rx_fully_locked};
        if (!lock_sync[2]) tx_calendar_reg <= {(16*CALENDAR_PAGES){1'b0}};
        else tx_calendar_reg <= tx_calendar;
    end
end

alt_ntrlkn_12l_10g_tx_12lane itx (
	.clk(tx_mac_clk),
	.arst(tx_mac_arst),
	.lane_clk(tx_lane_clk),
	.lane_arst(tx_lane_arst),
        .burst_max_in(burst_max_in),
	.din_words(tx_datwords),
	.num_valid_din_words((tx_valid & !underflow_alarm) ? tx_num_datwords_valid : 4'h0),
	.chan(tx_chan),
	.sop((tx_valid & !underflow_alarm)? tx_sop : 1'b0),				// SOP and EOP both refer to the current data in
	.eopbits((tx_valid & !underflow_alarm) ? tx_eopbits : 4'b0),
	.calendar(tx_calendar_reg),
	.burst_short_in(burst_short_in),
	.ack(tx_ready),
	.hungry(tx_hungry),
	.underflow(tx_underflow),	// this may occur briefly at startup
	.overflow(tx_overflow),	// this should never occur
	
	// 40 bit continuous stream to SERDES pins
	.tx_data(tx_data)
);
defparam itx .META_FRAME_LEN = META_FRAME_LEN;
defparam itx.CALENDAR_PAGES = CALENDAR_PAGES; // 16 bits per page
defparam itx.LOG_CALENDAR_PAGES = LOG_CALENDAR_PAGES; // 4 for 16 page, 256 bit.

//////////////////////////////
// RX unit
//////////////////////////////

wire [NUM_LANES-1:0] word_locked,sync_locked,framing_error,crc32_error,scrambler_mismatch,missing_sync;
wire rx_datwords_valid;
wire [65*INTERNAL_WORDS-1:0] rx_datwords;
wire crc24_err, lane_locked, rx_core_overflow;

alt_ntrlkn_12l_10g_rx_12lane irx (	
	// 40 bit continuous stream from SERDES pins
	.rx_data(rx_data),
	.lane_clk(rx_lane_clk_derived),
	.lane_arst(rx_arst),

	.common_clk(rx_mac_clk),
	.common_arst(rx_mac_arst),
	.locked(lane_locked),	// meaning lane alignment locked

	.outwords(rx_datwords),
	.outwords_valid(rx_datwords_valid),
	.crc24_err(crc24_err),
	.overflow(rx_core_overflow),
	.calendar(rx_calendar),

	// NOTE : these are still on the respective lane clock domains
	.word_locked(word_locked),
	.sync_locked(sync_locked),
	.framing_error(framing_error),
	.crc32_error(crc32_error),
	.scrambler_mismatch(scrambler_mismatch),
	.missing_sync(missing_sync)	
);
defparam irx .META_FRAME_LEN = META_FRAME_LEN;
defparam irx.CALENDAR_PAGES = CALENDAR_PAGES; // 16 bits per page
defparam irx.LOG_CALENDAR_PAGES = LOG_CALENDAR_PAGES; // 4 for 16 page, 256 bit.

// break up words for simulation visibility
// synthesis translate off
wire [64:0] rx_datwords0,rx_datwords1,rx_datwords2,
    rx_datwords3,rx_datwords4,rx_datwords5,rx_datwords6,
    rx_datwords7;
assign {rx_datwords0,rx_datwords1,rx_datwords2,
    rx_datwords3,rx_datwords4,rx_datwords5,rx_datwords6,
    rx_datwords7} = rx_datwords;
// synthesis translate on

//////////////////////////////////////
// synchronize the RX lane status bits
//////////////////////////////////////

alt_ntrlkn_12l_10g_lane_status_monitor #(
	.WIDTH(NUM_LANES)
)
lsm
(
	.common_clk(rx_mac_clk),
	.common_arst(rx_mac_arst),
	.lane_clk(rx_lane_clk_derived),
	.lane_arst(rx_arst),
	
	// these are on the lane clock domains
	.word_locked(word_locked), 
	.sync_locked(sync_locked), 
	.framing_error(framing_error),
	.crc32_error(crc32_error),
	.scrambler_mismatch(scrambler_mismatch),
	.missing_sync(missing_sync),
	
	// raw signals on the common clock domain
	.s_word_locked(rx_per_lane_word_lock), 
	.s_sync_locked(rx_per_lane_sync_lock), 
	.s_framing_error(),
	.s_crc32_error(),
	.s_scrambler_mismatch(),
	.s_missing_sync(),

	.all_word_locked(rx_all_word_locked),
	.all_sync_locked(rx_all_sync_locked),
	.crc32_err_cntrs(rx_per_lane_crc32_errs)
);
// Combine to form a RX completely ready bit
always @(posedge rx_mac_clk or posedge rx_mac_arst) begin
    if (rx_mac_arst) rx_fully_locked <= 1'b0;
    else rx_fully_locked <= rx_all_word_locked & rx_all_sync_locked & lane_locked;
end

//////////////////////////////////////
// Break RX datastream into channels
//////////////////////////////////////
// RX stream from filters to regroup - channel 0
wire [4-1:0] rx_num_chan0words_valid_i;
wire [65*8-1:0] rx_chan0words_i;

// RX stream from filters to regroup - channel 1
wire [4-1:0] rx_num_chan1words_valid_i;
wire [65*8-1:0] rx_chan1words_i;

alt_ntrlkn_12l_10g_rx_channel_filter_8 rcf0 (
    .clk(rx_mac_clk),
    .arst(rx_mac_arst),
    .datwords_valid(rx_datwords_valid),
    .datwords(rx_datwords),
    .num_chanwords_valid(rx_num_chan0words_valid_i),
    .chanwords(rx_chan0words_i)
);
defparam rcf0 .CHAN_NUM = 8'h00;

alt_ntrlkn_12l_10g_rx_channel_filter_8 rcf1 (
    .clk(rx_mac_clk),
    .arst(rx_mac_arst),
    .datwords_valid(rx_datwords_valid),
    .datwords(rx_datwords),
    .num_chanwords_valid(rx_num_chan1words_valid_i),
    .chanwords(rx_chan1words_i)
);
defparam rcf1 .CHAN_NUM = 8'h01;

/////////////////////////////////////////
// Regroup RX datastream into TX format
/////////////////////////////////////////
wire [2-1:0] regroup_overflow;
alt_ntrlkn_12l_10g_packet_regroup_8 rg0 (
    .clk(rx_mac_clk),
    .arst(rx_mac_arst),
    .num_din_valid(rx_num_chan0words_valid_i),
    .din(rx_chan0words_i),
    .avl_dout(rx_ch0_avl_data),
    .avl_dout_sop(rx_ch0_avl_sop),
    .avl_dout_eop(rx_ch0_avl_eop),
    .avl_empty(rx_ch0_avl_empty),
    .avl_error(rx_ch0_avl_error),
    .avl_valid(rx_ch0_avl_valid),
    .overflow(regroup_overflow[0])
);

alt_ntrlkn_12l_10g_packet_regroup_8 rg1 (
    .clk(rx_mac_clk),
    .arst(rx_mac_arst),
    .num_din_valid(rx_num_chan1words_valid_i),
    .din(rx_chan1words_i),
    .avl_dout(rx_ch1_avl_data),
    .avl_dout_sop(rx_ch1_avl_sop),
    .avl_dout_eop(rx_ch1_avl_eop),
    .avl_empty(rx_ch1_avl_empty),
    .avl_error(rx_ch1_avl_error),
    .avl_valid(rx_ch1_avl_valid),
    .overflow(regroup_overflow[1])
);

assign rx_overflow = (|regroup_overflow) | rx_core_overflow;

//////////////////////////////////////
// Status counters
//////////////////////////////////////

reg [8:0] usec_cntr;
reg usec_max;
always @(posedge rx_mac_clk or posedge rx_mac_arst) begin
    if (rx_mac_arst) begin
        usec_max <= 1'b0;
        usec_cntr <= 9'h0;
    end else begin
        usec_max <= (usec_cntr == 9'd316);
        if (usec_max || !rx_fully_locked) usec_cntr <= 0;
        else usec_cntr <= usec_cntr + 1'b1;
    end
end

reg [9:0] msec_cntr;
reg msec_max;
always @(posedge rx_mac_clk or posedge rx_mac_arst) begin
    if (rx_mac_arst) begin
        msec_max <= 1'b0;
        msec_cntr <= 10'h0;
    end else begin
        msec_max <= (msec_cntr == 10'd998);
        if ((usec_max && msec_max) || !rx_fully_locked) msec_cntr <= 0;
        else if (usec_max) msec_cntr <= msec_cntr + 1'b1;
    end
end

reg [9:0] sec_cntr;
reg sec_max;
always @(posedge rx_mac_clk or posedge rx_mac_arst) begin
    if (rx_mac_arst) begin
        sec_max <= 1'b0;
        sec_cntr <= 10'h0;
    end else begin
        sec_max <= (sec_cntr == 10'd998);
        if ((sec_max && msec_max && usec_max) || !rx_fully_locked) sec_cntr <= 0;
        else if (usec_max && msec_max) sec_cntr <= sec_cntr + 1'b1;
    end
end

// monitor locked time in seconds
always @(posedge rx_mac_clk or posedge rx_mac_arst) begin
    if (rx_mac_arst) begin
        rx_locked_time <= 16'h0;
    end else begin
        if (!rx_fully_locked) rx_locked_time <= 16'h0;
        else if (sec_max && msec_max && usec_max) rx_locked_time <= rx_locked_time + 1'b1;
    end
end

// monitor CRC24 error rate - reset on loss of lock
always @(posedge rx_mac_clk or posedge rx_mac_arst) begin
    if (rx_mac_arst) begin
        rx_error_count <= 16'h0;
    end else begin
        if (!rx_fully_locked) rx_error_count <= 16'h0;
        else if (crc24_err) rx_error_count <= rx_error_count + 1'b1;
    end
end

endmodule

