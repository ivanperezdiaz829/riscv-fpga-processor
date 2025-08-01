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
   ST_SINK_SET_READY                     = 32'd0,
   ST_SINK_POP_TRANSACTION               = 32'd1,
   ST_SINK_GET_TRANSACTION_IDLES         = 32'd2,
   ST_SINK_GET_TRANSACTION_DATA          = 32'd3,
   ST_SINK_GET_TRANSACTION_CHANNEL       = 32'd4,
   ST_SINK_GET_TRANSACTION_SOP           = 32'd5,
   ST_SINK_GET_TRANSACTION_EOP           = 32'd6,
   ST_SINK_GET_TRANSACTION_ERROR         = 32'd7,
   ST_SINK_GET_TRANSACTION_EMPTY         = 32'd8,
   ST_SINK_GET_TRANSACTION_QUEUE_SIZE    = 32'd9,
   ST_SINK_INIT                          = 32'd10      
} st_sink_vhdl_api_e;

// enum for VHDL event
typedef enum int {
   ST_SINK_EVENT_TRANSACTION_RECEIVED    = 32'd0,
   ST_SINK_EVENT_SINK_READY_ASSERT       = 32'd1,
   ST_SINK_EVENT_SINK_READY_DEASSERT     = 32'd2
} st_sink_vhdl_event_e;

// synthesis translate_on
module altera_avalon_st_sink_bfm_vhdl_wrapper #(
   parameter ST_SYMBOL_W       = 8,
             ST_NUMSYMBOLS     = 4,
             ST_CHANNEL_W      = 0,
             ST_ERROR_W        = 0,
             ST_EMPTY_W        = 0,
             ST_READY_LATENCY  = 0,
             ST_MAX_CHANNELS   = 1,
             USE_PACKET        = 0,
             USE_CHANNEL       = 0,
             USE_ERROR         = 0,
             USE_READY         = 1,
             USE_VALID         = 1,
             USE_EMPTY         = 0,
             ST_BEATSPERCYCLE  = 1,
             ST_DATA_W        = ST_SYMBOL_W * ST_NUMSYMBOLS,
             ST_MDATA_W       = ST_BEATSPERCYCLE * ST_DATA_W,
             ST_MCHANNEL_W    = ST_BEATSPERCYCLE * ST_CHANNEL_W,
             ST_MERROR_W      = ST_BEATSPERCYCLE * ST_ERROR_W,
             ST_MEMPTY_W      = ST_BEATSPERCYCLE * ST_EMPTY_W,
             ST_MAX_BIT_W     = 4096
)(
   input                                     clk,
   input                                     reset,
   input [lindex(ST_MDATA_W): 0]             sink_data,
   input [lindex(ST_MCHANNEL_W): 0]          sink_channel,
   input [ST_BEATSPERCYCLE-1: 0]             sink_valid,
   input [ST_BEATSPERCYCLE-1: 0]             sink_startofpacket,
   input [ST_BEATSPERCYCLE-1: 0]             sink_endofpacket,
   input [lindex(ST_MERROR_W): 0]            sink_error,
   input [lindex(ST_MEMPTY_W): 0]            sink_empty,    
   output                                    sink_ready,
   
   // VHDL API request interface
   input  bit [ST_SINK_INIT:0]                        req,
   output bit [ST_SINK_INIT:0]                        ack,
   input  int                                         data_in0,
   input  bit [lindex(ST_MAX_BIT_W): 0]               data_in1,
   output int                                         data_out0,
   output bit [lindex(ST_MAX_BIT_W): 0]               data_out1,
   output bit [ST_SINK_EVENT_SINK_READY_DEASSERT:0]   events
);

   // synthesis translate_off
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction
   
   altera_avalon_st_sink_bfm #(
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
   ) st_sink (
      .clk(clk),
      .reset(reset),
      .sink_data(sink_data),	     
      .sink_channel(sink_channel),      
      .sink_valid(sink_valid), 	     
      .sink_startofpacket(sink_startofpacket),
      .sink_endofpacket(sink_endofpacket),  
      .sink_error(sink_error),    	     
      .sink_empty(sink_empty),	     
      .sink_ready(sink_ready)
   );
	
   // // logic block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[ST_SINK_SET_READY]);
      ack[ST_SINK_SET_READY] = 1;
      st_sink.set_ready(data_in0);
      ack[ST_SINK_SET_READY] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_POP_TRANSACTION]);
      ack[ST_SINK_POP_TRANSACTION] = 1;
      st_sink.pop_transaction();
      ack[ST_SINK_POP_TRANSACTION] <= 0;
   end

   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_IDLES]);
      ack[ST_SINK_GET_TRANSACTION_IDLES] = 1;
      data_out0 = st_sink.get_transaction_idles();
      ack[ST_SINK_GET_TRANSACTION_IDLES] <= 0;
   end
      
   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_DATA]);
      ack[ST_SINK_GET_TRANSACTION_DATA] = 1;
      data_out1 = st_sink.get_transaction_data();
      ack[ST_SINK_GET_TRANSACTION_DATA] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_CHANNEL]);
      ack[ST_SINK_GET_TRANSACTION_CHANNEL] = 1;
      data_out1 = st_sink.get_transaction_channel();
      ack[ST_SINK_GET_TRANSACTION_CHANNEL] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_SOP]);
      ack[ST_SINK_GET_TRANSACTION_SOP] = 1;
      data_out0 = st_sink.get_transaction_sop();
      ack[ST_SINK_GET_TRANSACTION_SOP] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_EOP]);
      ack[ST_SINK_GET_TRANSACTION_EOP] = 1;
      data_out0 = st_sink.get_transaction_eop();
      ack[ST_SINK_GET_TRANSACTION_EOP] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_ERROR]);
      ack[ST_SINK_GET_TRANSACTION_ERROR] = 1;
      data_out1 = st_sink.get_transaction_error();
      ack[ST_SINK_GET_TRANSACTION_ERROR] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_EMPTY]);
      ack[ST_SINK_GET_TRANSACTION_EMPTY] = 1;
      data_out0 = st_sink.get_transaction_empty();
      ack[ST_SINK_GET_TRANSACTION_EMPTY] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_GET_TRANSACTION_QUEUE_SIZE]);
      ack[ST_SINK_GET_TRANSACTION_QUEUE_SIZE] = 1;
      data_out0 = st_sink.get_transaction_queue_size();
      ack[ST_SINK_GET_TRANSACTION_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[ST_SINK_INIT]);
      ack[ST_SINK_INIT] = 1;
      st_sink.init();
      ack[ST_SINK_INIT] <= 0;
   end
   
   // logic blocks to handle event trigger  
   always @(st_sink.signal_transaction_received) begin
      events[ST_SINK_EVENT_TRANSACTION_RECEIVED] = 1;
      events[ST_SINK_EVENT_TRANSACTION_RECEIVED] <= 0;
   end
   
   always @(st_sink.signal_sink_ready_assert) begin
      events[ST_SINK_EVENT_SINK_READY_ASSERT] = 1;
      events[ST_SINK_EVENT_SINK_READY_ASSERT] <= 0;
   end
   
   always @(st_sink.signal_sink_ready_deassert) begin
      events[ST_SINK_EVENT_SINK_READY_DEASSERT] = 1;
      events[ST_SINK_EVENT_SINK_READY_DEASSERT] <= 0;
   end
   
// synthesis translate_on
endmodule 