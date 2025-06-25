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


// $File: $
// $Revision: $
// $Date: $
// $Author: $

`timescale 1ns / 1ns

// synthesis translate_off
// enum for VHDL procedure
typedef enum int {
      ST_SRC_GET_SRC_TRANSACTION_COMPLETE          = 32'd0,
      ST_SRC_GET_SRC_READY                         = 32'd1,
      ST_SRC_SET_RESPONSE_TIMEOUT                  = 32'd2,
      ST_SRC_PUSH_TRANSACTION                      = 32'd3,
      ST_SRC_GET_TRANSACTION_QUEUE_SIZE            = 32'd4,
      ST_SRC_GET_RESPONSE_QUEUE_SIZE               = 32'd5,
      ST_SRC_SET_TRANSACTION_DATA                  = 32'd6,
      ST_SRC_SET_TRANSACTION_CHANNEL               = 32'd7,
      ST_SRC_SET_TRANSACTION_IDLES                 = 32'd8,
      ST_SRC_SET_TRANSACTION_SOP                   = 32'd9,
      ST_SRC_SET_TRANSACTION_EOP                   = 32'd10,
      ST_SRC_SET_TRANSACTION_ERROR                 = 32'd11,
      ST_SRC_SET_TRANSACTION_EMPTY                 = 32'd12,
      ST_SRC_POP_RESPONSE                          = 32'd13,
      ST_SRC_GET_RESPONSE_LATENCY                  = 32'd14,
      ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE        = 32'd15,
      ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE        = 32'd16,
      ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION   = 32'd17,
      ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION   = 32'd18,
      ST_SRC_INIT                                  = 32'd19
} st_src_vhdl_api_e;

// enum for VHDL event
typedef enum int {
      ST_SRC_EVENT_RESPONSE_DONE                = 32'd0,
      ST_SRC_EVENT_MAX_TRANSACTION_QUEUE_SIZE   = 32'd1,
      ST_SRC_EVENT_MIN_TRANSACTION_QUEUE_SIZE   = 32'd2,
      ST_SRC_EVENT_SRC_TRANSACTION_COMPLETE     = 32'd3,
      ST_SRC_EVENT_SRC_DRIVING_TRANSACTION      = 32'd4,
      ST_SRC_EVENT_SRC_READY                    = 32'd5,
      ST_SRC_EVENT_SRC_NOT_READY                = 32'd6
} st_src_vhdl_event_e;

// synthesis translate_on
module altera_avalon_st_source_bfm_vhdl_wrapper #(
   parameter ST_SYMBOL_W       = 8,
             ST_NUMSYMBOLS     = 4,
             ST_CHANNEL_W      = 1,
             ST_ERROR_W        = 1,
             ST_EMPTY_W        = 1,
             ST_READY_LATENCY  = 0,
             ST_MAX_CHANNELS   = 1,
             USE_PACKET        = 0,
             USE_CHANNEL       = 0,
             USE_ERROR         = 0,
             USE_READY         = 1,
             USE_VALID         = 1,
             USE_EMPTY         = 0,
             ST_BEATSPERCYCLE  = 1,
             ST_DATA_W         = ST_SYMBOL_W * ST_NUMSYMBOLS,
             ST_MDATA_W        = ST_BEATSPERCYCLE * ST_DATA_W,
             ST_MCHANNEL_W     = ST_BEATSPERCYCLE * ST_CHANNEL_W,
             ST_MERROR_W       = ST_BEATSPERCYCLE * ST_ERROR_W,
             ST_MEMPTY_W       = ST_BEATSPERCYCLE * ST_EMPTY_W,
             ST_MAX_BIT_W      = 4096
)(
   input                                     clk,
   input                                     reset,
   output [lindex(ST_MDATA_W): 0]            src_data,
   output [lindex(ST_MCHANNEL_W): 0]         src_channel,
   output [ST_BEATSPERCYCLE-1: 0]            src_valid,
   output [ST_BEATSPERCYCLE-1: 0]            src_startofpacket,
   output [ST_BEATSPERCYCLE-1: 0]            src_endofpacket,
   output [lindex(ST_MERROR_W): 0]           src_error,
   output [lindex(ST_MEMPTY_W): 0]           src_empty,    
   input                                     src_ready,
   
   // VHDL API request interface
   input  bit [ST_SRC_INIT:0]                req,
   output bit [ST_SRC_INIT:0]                ack,
   input  int                                data_in0,
   input  bit [lindex(ST_MAX_BIT_W): 0]      data_in1,
   output int                                data_out0,
   output bit [lindex(ST_MAX_BIT_W): 0]      data_out1,
   output bit [ST_SRC_EVENT_SRC_NOT_READY:0] events
);

   import avalon_utilities_pkg::*;
   
   // synthesis translate_off
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction
   
   altera_avalon_st_source_bfm #(
      .ST_SYMBOL_W(ST_SYMBOL_W),
      .ST_NUMSYMBOLS(ST_NUMSYMBOLS),
      .ST_CHANNEL_W(ST_CHANNEL_W),
      .ST_ERROR_W(ST_ERROR_W),
      .ST_EMPTY_W(ST_EMPTY_W),
      .ST_READY_LATENCY(ST_READY_LATENCY),
      .ST_MAX_CHANNELS(ST_MAX_CHANNELS),
      .USE_PACKET(USE_PACKET),
      .USE_CHANNEL(USE_CHANNEL),
      .USE_ERROR(USE_ERROR),
      .USE_READY(USE_READY),
      .USE_VALID(USE_VALID),
      .USE_EMPTY(USE_EMPTY)
   ) st_source (
      .clk(clk),
      .reset(reset),
      .src_data(src_data),	     
      .src_channel(src_channel),      
      .src_valid(src_valid), 	     
      .src_startofpacket(src_startofpacket),
      .src_endofpacket(src_endofpacket),  
      .src_error(src_error),    	     
      .src_empty(src_empty),	     
      .src_ready(src_ready)
   );
   
   // logic block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[ST_SRC_GET_SRC_TRANSACTION_COMPLETE]);
      ack[ST_SRC_GET_SRC_TRANSACTION_COMPLETE] = 1;
      data_out0 = st_source.get_src_transaction_complete();
      ack[ST_SRC_GET_SRC_TRANSACTION_COMPLETE] <= 0;
   end

   initial forever begin
      @(posedge req[ST_SRC_GET_SRC_READY]);
      ack[ST_SRC_GET_SRC_READY] = 1;
      data_out0 = st_source.get_src_ready();
      ack[ST_SRC_GET_SRC_READY] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_RESPONSE_TIMEOUT]);
      ack[ST_SRC_SET_RESPONSE_TIMEOUT] = 1;
      st_source.set_response_timeout(data_in0);
      ack[ST_SRC_SET_RESPONSE_TIMEOUT] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_PUSH_TRANSACTION]);
      ack[ST_SRC_PUSH_TRANSACTION] = 1;
      st_source.push_transaction();
      ack[ST_SRC_PUSH_TRANSACTION] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_GET_TRANSACTION_QUEUE_SIZE]);
      ack[ST_SRC_GET_TRANSACTION_QUEUE_SIZE] = 1;
      data_out0 = st_source.get_transaction_queue_size();
      ack[ST_SRC_GET_TRANSACTION_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_GET_RESPONSE_QUEUE_SIZE]);
      ack[ST_SRC_GET_RESPONSE_QUEUE_SIZE] = 1;
      data_out0 = st_source.get_response_queue_size();
      ack[ST_SRC_GET_RESPONSE_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_TRANSACTION_DATA]);
      ack[ST_SRC_SET_TRANSACTION_DATA] = 1;
      st_source.set_transaction_data(data_in1);
      ack[ST_SRC_SET_TRANSACTION_DATA] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_TRANSACTION_CHANNEL]);
      ack[ST_SRC_SET_TRANSACTION_CHANNEL] = 1;
      st_source.set_transaction_channel(data_in1);
      ack[ST_SRC_SET_TRANSACTION_CHANNEL] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_TRANSACTION_IDLES]);
      ack[ST_SRC_SET_TRANSACTION_IDLES] = 1;
      st_source.set_transaction_idles(data_in0);
      ack[ST_SRC_SET_TRANSACTION_IDLES] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_TRANSACTION_SOP]);
      ack[ST_SRC_SET_TRANSACTION_SOP] = 1;
      st_source.set_transaction_sop(data_in0);
      ack[ST_SRC_SET_TRANSACTION_SOP] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_TRANSACTION_EOP]);
      ack[ST_SRC_SET_TRANSACTION_EOP] = 1;
      st_source.set_transaction_eop(data_in0);
      ack[ST_SRC_SET_TRANSACTION_EOP] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_TRANSACTION_ERROR]);
      ack[ST_SRC_SET_TRANSACTION_ERROR] = 1;
      st_source.set_transaction_error(data_in1);
      ack[ST_SRC_SET_TRANSACTION_ERROR] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_TRANSACTION_EMPTY]);
      ack[ST_SRC_SET_TRANSACTION_EMPTY] = 1;
      st_source.set_transaction_empty(data_in0);
      ack[ST_SRC_SET_TRANSACTION_EMPTY] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_POP_RESPONSE]);
      ack[ST_SRC_POP_RESPONSE] = 1;
      st_source.pop_response();
      ack[ST_SRC_POP_RESPONSE] <= 0;
   end

   initial forever begin
      @(posedge req[ST_SRC_GET_RESPONSE_LATENCY]);
      ack[ST_SRC_GET_RESPONSE_LATENCY] = 1;
      data_out0 = st_source.get_response_latency();
      ack[ST_SRC_GET_RESPONSE_LATENCY] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE]);
      ack[ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE] = 1;
      st_source.set_max_transaction_queue_size(data_in0);
      ack[ST_SRC_SET_MAX_TRANSACTION_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE]);
      ack[ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE] = 1;
      st_source.set_min_transaction_queue_size(data_in0);
      ack[ST_SRC_SET_MIN_TRANSACTION_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      st_source.set_idle_state_output_configuration(IdleOutputValue_t'(data_in0));
      ack[ST_SRC_SET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      data_out0 = st_source.get_idle_state_output_configuration();
      ack[ST_SRC_GET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SRC_INIT]);
      ack[ST_SRC_INIT] = 1;
      st_source.init();
      ack[ST_SRC_INIT] <= 0;
   end
   
   // logic blocks to handle event trigger
   always @(st_source.signal_response_done) begin
      events[ST_SRC_EVENT_RESPONSE_DONE] = 1;
      events[ST_SRC_EVENT_RESPONSE_DONE] <= 0;
   end
   
   always @(st_source.signal_max_transaction_queue_size) begin
      events[ST_SRC_EVENT_MAX_TRANSACTION_QUEUE_SIZE] = 1;
      events[ST_SRC_EVENT_MAX_TRANSACTION_QUEUE_SIZE] <= 0;
   end
   
   always @(st_source.signal_min_transaction_queue_size) begin
      events[ST_SRC_EVENT_MIN_TRANSACTION_QUEUE_SIZE] = 1;
      events[ST_SRC_EVENT_MIN_TRANSACTION_QUEUE_SIZE] <= 0;
   end
   
   always @(st_source.signal_src_transaction_complete) begin
      events[ST_SRC_EVENT_SRC_TRANSACTION_COMPLETE] = 1;
      events[ST_SRC_EVENT_SRC_TRANSACTION_COMPLETE] <= 0;
   end
   
   always @(st_source.signal_src_driving_transaction) begin
      events[ST_SRC_EVENT_SRC_DRIVING_TRANSACTION] = 1;
      events[ST_SRC_EVENT_SRC_DRIVING_TRANSACTION] <= 0;
   end
   
   always @(st_source.signal_src_ready) begin
      events[ST_SRC_EVENT_SRC_READY] = 1;
      events[ST_SRC_EVENT_SRC_READY] <= 0;
   end
   
   always @(st_source.signal_src_not_ready) begin
      events[ST_SRC_EVENT_SRC_NOT_READY] = 1;
      events[ST_SRC_EVENT_SRC_NOT_READY] <= 0;
   end

// synthesis translate_on   
endmodule 