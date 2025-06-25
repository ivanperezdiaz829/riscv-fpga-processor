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


// $Id: //acds/rel/13.1/ip/merlin/altera_merlin_traffic_limiter/alternate_limiter_impl.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $

// -----------------------------------------------------
// Merlin Traffic Limiter
//
// Alternate implementation, using a FIFO. Consumes more resources,
// but is faster.
// -----------------------------------------------------

`timescale 1 ns / 1 ns

module altera_merlin_traffic_limiter
#(
    parameter PKT_TRANS_POSTED          = 1,
              PKT_DEST_ID_H             = 0,
              PKT_DEST_ID_L             = 0,
              ST_DATA_W                 = 71,
              ST_CHANNEL_W              = 32,
              MAX_OUTSTANDING_RESPONSES = 1
)
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command
    // -------------------
    input                           cmd_sink_valid,
    input  [ST_DATA_W-1 : 0]        cmd_sink_data,
    input  [ST_CHANNEL_W-1 : 0]     cmd_sink_channel,
    input                           cmd_sink_startofpacket,
    input                           cmd_sink_endofpacket,
    output reg                      cmd_sink_ready,

    output reg                      cmd_src_valid,
    output reg [ST_DATA_W-1    : 0] cmd_src_data,
    output reg [ST_CHANNEL_W-1 : 0] cmd_src_channel,
    output reg                      cmd_src_startofpacket,
    output reg                      cmd_src_endofpacket,
    input                           cmd_src_ready,

    // -------------------
    // Response
    // -------------------
    input                           rsp_sink_valid,
    input  [ST_DATA_W-1 : 0]        rsp_sink_data,
    input  [ST_CHANNEL_W-1 : 0]     rsp_sink_channel,
    input                           rsp_sink_startofpacket,
    input                           rsp_sink_endofpacket,
    output reg                      rsp_sink_ready,

    output reg                      rsp_src_valid,
    output reg [ST_DATA_W-1    : 0] rsp_src_data,
    output reg [ST_CHANNEL_W-1 : 0] rsp_src_channel,
    output reg                      rsp_src_startofpacket,
    output reg                      rsp_src_endofpacket,
    input                           rsp_src_ready
);

    // -------------------------------------
    // Signals
    // -------------------------------------
    localparam DEST_ID_W = PKT_DEST_ID_H - PKT_DEST_ID_L + 1;

    wire                    is_read;
    wire                    dest_changed;
    wire                    has_pending_reads;
    wire [DEST_ID_W-1 : 0]  dest_id;
    reg  [DEST_ID_W-1 : 0]  last_dest_id;
    wire                    read_cmd_valid;
    wire                    read_cmd_accepted;
    wire                    read_rsp_accepted;

    assign dest_id = cmd_sink_data[PKT_DEST_ID_H:PKT_DEST_ID_L];
    assign is_read = (cmd_sink_data[PKT_TRANS_POSTED] == 0);

    assign read_cmd_valid    = is_read && cmd_src_valid;
    assign read_cmd_accepted = is_read && cmd_src_valid && cmd_src_ready && cmd_src_endofpacket;
    assign read_rsp_accepted = rsp_src_valid && rsp_src_ready && rsp_src_endofpacket;

    altera_avalon_sc_fifo
    #(
        .SYMBOLS_PER_BEAT  (1),
        .BITS_PER_SYMBOL   (1),
		.FIFO_DEPTH        (MAX_OUTSTANDING_RESPONSES),
		.CHANNEL_WIDTH     (0),
		.ERROR_WIDTH       (0),
		.USE_PACKETS       (0),
		.USE_FILL_LEVEL    (0),
		.EMPTY_LATENCY     (1),
		.USE_MEMORY_BLOCKS (0)
    )
    pending_response_fifo
    (
		.clk               (clk),
		.reset             (reset),
		.in_data           (1'b0),
		.in_valid          (read_cmd_accepted),
		.in_ready          (),
		.out_data          (),
		.out_valid         (has_pending_reads),
		.out_ready         (read_rsp_accepted)
    );

    // -------------------------------------
    // Pass-through command and response
    // -------------------------------------
    always @* begin
        cmd_src_data          = cmd_sink_data;
        cmd_src_channel       = cmd_sink_channel;
        cmd_src_startofpacket = cmd_sink_startofpacket;
        cmd_src_endofpacket   = cmd_sink_endofpacket;

        rsp_src_valid         = rsp_sink_valid;
        rsp_src_data          = rsp_sink_data;
        rsp_src_channel       = rsp_sink_channel;
        rsp_src_startofpacket = rsp_sink_startofpacket;
        rsp_src_endofpacket   = rsp_sink_endofpacket;
        rsp_sink_ready        = rsp_src_ready;
    end

    // -------------------------------------
    // Backpressure & Suppression
    //
    // First, stupid, slow implementation: a counter.
    // Improve when profiling tells me it is needed.
    //
    // TODO: should this backpressure to prevent overflow?
    // Ye olde fabric never did.
    // -------------------------------------
    always @(posedge clk, posedge reset) begin
        if (reset)
            last_dest_id <= 0;
        else if (read_cmd_valid)
            last_dest_id <= dest_id;
    end

    assign dest_changed = (last_dest_id != dest_id);

    always @* begin
        cmd_sink_ready = cmd_src_ready;
        cmd_src_valid  = cmd_sink_valid;

        if (is_read && has_pending_reads && dest_changed) begin
            cmd_sink_ready = 0;
            cmd_src_valid = 0;
        end
    end

    // --------------------------------------------------
    // Calculates the log2ceil of the input value.
    //
    // This function occurs a lot... please refactor.
    // --------------------------------------------------
    function integer log2ceil;
        input integer val;
        integer i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule
