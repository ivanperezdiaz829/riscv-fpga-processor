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


`timescale 1ns /  1ns

// synthesis translate_off
// enum for VHDL procedure
typedef enum int {
   MM_MSTR_SET_RESPONSE_TIMEOUT                 = 32'd0,
   MM_MSTR_SET_COMMAND_TIMEOUT                  = 32'd1,
   MM_MSTR_ALL_TRANSACTIONS_COMPLETE            = 32'd2,
   MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE        = 32'd3,
   MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE       = 32'd4,
   MM_MSTR_GET_RESPONSE_ADDRESS                 = 32'd5,
   MM_MSTR_GET_RESPONSE_BYTE_ENABLE             = 32'd6,
   MM_MSTR_GET_RESPONSE_BURST_SIZE              = 32'd7,
   MM_MSTR_GET_RESPONSE_DATA                    = 32'd8,
   MM_MSTR_GET_RESPONSE_LATENCY                 = 32'd9,
   MM_MSTR_GET_RESPONSE_REQUEST                 = 32'd10,
   MM_MSTR_GET_RESPONSE_QUEUE_SIZE              = 32'd11,
   MM_MSTR_GET_RESPONSE_WAIT_TIME               = 32'd12,
   MM_MSTR_POP_RESPONSE                         = 32'd13,
   MM_MSTR_PUSH_COMMAND                         = 32'd14,
   MM_MSTR_SET_COMMAND_ADDRESS                  = 32'd15,
   MM_MSTR_SET_COMMAND_BYTE_ENABLE              = 32'd16,
   MM_MSTR_SET_COMMAND_BURST_COUNT              = 32'd17,
   MM_MSTR_SET_COMMAND_BURST_SIZE               = 32'd18,
   MM_MSTR_SET_COMMAND_DATA                     = 32'd19,
   MM_MSTR_SET_COMMAND_IDLE                     = 32'd20,
   MM_MSTR_SET_COMMAND_INIT_LATENCY             = 32'd21,
   MM_MSTR_SET_COMMAND_REQUEST                  = 32'd22,
   MM_MSTR_SET_COMMAND_ARBITERLOCK              = 32'd23,
   MM_MSTR_SET_COMMAND_LOCK                     = 32'd24,
   MM_MSTR_SET_COMMAND_DEBUGACCESS              = 32'd25,
   MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE           = 32'd26,
   MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE           = 32'd27,
   MM_MSTR_SET_COMMAND_TRANSACTION_ID           = 32'd28,
   MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST   = 32'd29,
   MM_MSTR_GET_READ_RESPONSE_STATUS             = 32'd30,
   MM_MSTR_GET_RESPONSE_READ_ID                 = 32'd31,
   MM_MSTR_GET_WRITE_RESPONSE_STATUS            = 32'd32,
   MM_MSTR_GET_RESPONSE_WRITE_ID                = 32'd33,
   MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE        = 32'd34,
   MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE         = 32'd35,
   MM_MSTR_SET_CLKEN                            = 32'd36,
   MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION  = 32'd37,
   MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION  = 32'd38,
   MM_MSTR_INIT                                 = 32'd39
} mm_mstr_vhdl_api_e;

typedef enum int {
   MM_MSTR_EVENT_READ_RESPONSE_COMPLETE         = 32'd0,
   MM_MSTR_EVENT_WRITE_RESPONSE_COMPLETE        = 32'd1,
   MM_MSTR_EVENT_RESPONSE_COMPLETE              = 32'd2,
   MM_MSTR_EVENT_COMMAND_ISSUED                 = 32'd3,
   MM_MSTR_EVENT_ALL_TRANSACTIONS_COMPLETE      = 32'd4,
   MM_MSTR_EVENT_MAX_COMMAND_QUEUE_SIZE         = 32'd5,
   MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE         = 32'd6
} mm_mstr_vhdl_event_e;

// synthesis translate_on
module altera_avalon_mm_master_bfm_vhdl_wrapper #(
   parameter AV_ADDRESS_W               = 32,
             AV_SYMBOL_W                = 8,
             AV_NUMSYMBOLS              = 4,
             AV_BURSTCOUNT_W            = 3,
             USE_READ                   = 1,
             USE_WRITE                  = 1,
             USE_ADDRESS                = 1,
             USE_BYTE_ENABLE            = 1,
             USE_BURSTCOUNT             = 1,
             USE_READ_DATA              = 1,
             USE_READ_DATA_VALID        = 1,
             USE_WRITE_DATA             = 1,
             USE_BEGIN_TRANSFER         = 1,
             USE_BEGIN_BURST_TRANSFER   = 1,
             USE_WAIT_REQUEST           = 1,
             USE_ARBITERLOCK            = 0,
             USE_LOCK                   = 0,
             USE_DEBUGACCESS            = 0,
             USE_TRANSACTIONID          = 0,
             USE_WRITERESPONSE          = 0,
             USE_READRESPONSE           = 0,
             USE_CLKEN                  = 0,
             AV_REGISTERINCOMINGSIGNALS = 0,
             AV_FIX_READ_LATENCY        = 0,
             AV_MAX_PENDING_READS       = 1,
             AV_MAX_PENDING_WRITES      = 0,
             AV_BURST_LINEWRAP          = 0,
             AV_BURST_BNDR_ONLY         = 0,
             AV_CONSTANT_BURST_BEHAVIOR = 1,
             AV_READ_WAIT_TIME          = 0,
             AV_WRITE_WAIT_TIME         = 0,
             REGISTER_WAITREQUEST       = 0,
             MM_MAX_BIT_W               = 1024
)(
   input                                              clk,
   input                                              reset,
   input                                              avm_waitrequest,
   input                                              avm_readdatavalid,
   input  [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]     avm_readdata,
   output                                             avm_write,
   output                                             avm_read,
   output [lindex(AV_ADDRESS_W):0]                    avm_address,
   output [lindex(AV_NUMSYMBOLS):0]                   avm_byteenable,
   output [lindex(AV_BURSTCOUNT_W):0]                 avm_burstcount,
   output                                             avm_beginbursttransfer,
   output                                             avm_begintransfer,
   output [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]     avm_writedata,
   output                                             avm_arbiterlock,
   output                                             avm_lock,
   output                                             avm_debugaccess,
   output [7:0]                                       avm_transactionid,
   input  [7:0]                                       avm_readid,
   input  [7:0]                                       avm_writeid,
   input  [1:0]                                       avm_response,
   output                                             avm_writeresponserequest,
   input                                              avm_writeresponsevalid,
   output                                             avm_clken,
   
   // VHDL API request interface
   input  bit [MM_MSTR_INIT:0]                        req,
   output bit [MM_MSTR_INIT:0]                        ack,
   input  int                                         data_in0,
   input  int                                         data_in1,
   input  bit [lindex(MM_MAX_BIT_W): 0]               data_in2,
   output int                                         data_out0,
   output int                                         data_out1,
   output bit [lindex(MM_MAX_BIT_W): 0]               data_out2,
   output bit [MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE:0]events
);
   
   // synthesis translate_off
   import avalon_mm_pkg::*;
   import avalon_utilities_pkg::*;
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction
   
   altera_avalon_mm_master_bfm #(
      .AV_ADDRESS_W(AV_ADDRESS_W),
      .AV_SYMBOL_W(AV_SYMBOL_W),
      .AV_NUMSYMBOLS(AV_NUMSYMBOLS),
      .AV_BURSTCOUNT_W(AV_BURSTCOUNT_W),
      .USE_READ(USE_READ),
      .USE_WRITE(USE_WRITE),
      .USE_ADDRESS(USE_ADDRESS),
      .USE_BYTE_ENABLE(USE_BYTE_ENABLE),
      .USE_BURSTCOUNT(USE_BURSTCOUNT),
      .USE_READ_DATA(USE_READ_DATA),
      .USE_READ_DATA_VALID(USE_READ_DATA_VALID),
      .USE_WRITE_DATA(USE_WRITE_DATA),
      .USE_BEGIN_TRANSFER(USE_BEGIN_TRANSFER),
      .USE_BEGIN_BURST_TRANSFER(USE_BEGIN_BURST_TRANSFER),
      .USE_WAIT_REQUEST(USE_WAIT_REQUEST),
      .USE_ARBITERLOCK(USE_ARBITERLOCK),
      .USE_LOCK(USE_LOCK),
      .USE_DEBUGACCESS(USE_DEBUGACCESS),
      .USE_TRANSACTIONID(USE_TRANSACTIONID),
      .USE_WRITERESPONSE(USE_WRITERESPONSE),
      .USE_READRESPONSE(USE_READRESPONSE),
      .USE_CLKEN(USE_CLKEN),
      .AV_REGISTERINCOMINGSIGNALS(AV_REGISTERINCOMINGSIGNALS),
      .AV_FIX_READ_LATENCY(AV_FIX_READ_LATENCY),
      .AV_MAX_PENDING_READS(AV_MAX_PENDING_READS),
      .AV_MAX_PENDING_WRITES(AV_MAX_PENDING_WRITES),
      .AV_BURST_LINEWRAP(AV_BURST_LINEWRAP),
      .AV_BURST_BNDR_ONLY(AV_BURST_BNDR_ONLY),
      .AV_CONSTANT_BURST_BEHAVIOR(AV_CONSTANT_BURST_BEHAVIOR),
      .AV_READ_WAIT_TIME(AV_READ_WAIT_TIME),
      .AV_WRITE_WAIT_TIME(AV_WRITE_WAIT_TIME),
      .REGISTER_WAITREQUEST(REGISTER_WAITREQUEST)
   ) mm_master (
      .clk(clk),
      .reset(reset),
      .avm_waitrequest(avm_waitrequest),
      .avm_readdatavalid(avm_readdatavalid),
      .avm_readdata(avm_readdata),
      .avm_write(avm_write),
      .avm_read(avm_read),
      .avm_address(avm_address),
      .avm_byteenable(avm_byteenable),
      .avm_burstcount(avm_burstcount),
      .avm_beginbursttransfer(avm_beginbursttransfer),
      .avm_begintransfer(avm_begintransfer),
      .avm_writedata(avm_writedata),
      .avm_arbiterlock(avm_arbiterlock),
      .avm_lock(avm_lock),
      .avm_debugaccess(avm_debugaccess),
      .avm_transactionid(avm_transactionid),
      .avm_readid(avm_readid),
      .avm_writeid(avm_writeid),
      .avm_response(avm_response),
      .avm_readresponse('0),
      .avm_writeresponse('0),
      .avm_writeresponserequest(avm_writeresponserequest),
      .avm_writeresponsevalid(avm_writeresponsevalid),
      .avm_clken(avm_clken)
   );

   // logic block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[MM_MSTR_SET_RESPONSE_TIMEOUT]);
      ack[MM_MSTR_SET_RESPONSE_TIMEOUT] = 1;
      mm_master.set_response_timeout(data_in0);
      ack[MM_MSTR_SET_RESPONSE_TIMEOUT] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_TIMEOUT]);
      ack[MM_MSTR_SET_COMMAND_TIMEOUT] = 1;
      mm_master.set_command_timeout(data_in0);
      ack[MM_MSTR_SET_COMMAND_TIMEOUT] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_ALL_TRANSACTIONS_COMPLETE]);
      ack[MM_MSTR_ALL_TRANSACTIONS_COMPLETE] = 1;
      data_out0 = mm_master.all_transactions_complete();
      ack[MM_MSTR_ALL_TRANSACTIONS_COMPLETE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE]);
      ack[MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE] = 1;
      data_out0 = mm_master.get_command_issued_queue_size();
      ack[MM_MSTR_GET_COMMAND_ISSUED_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE]);
      ack[MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE] = 1;
      data_out0 = mm_master.get_command_pending_queue_size();
      ack[MM_MSTR_GET_COMMAND_PENDING_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_ADDRESS]);
      ack[MM_MSTR_GET_RESPONSE_ADDRESS] = 1;
      data_out2 = mm_master.get_response_address();
      ack[MM_MSTR_GET_RESPONSE_ADDRESS] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_BYTE_ENABLE]);
      ack[MM_MSTR_GET_RESPONSE_BYTE_ENABLE] = 1;
      data_out2 = mm_master.get_response_byte_enable(data_in1);
      ack[MM_MSTR_GET_RESPONSE_BYTE_ENABLE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_BURST_SIZE]);
      ack[MM_MSTR_GET_RESPONSE_BURST_SIZE] = 1;
      data_out0 = mm_master.get_response_burst_size();
      ack[MM_MSTR_GET_RESPONSE_BURST_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_DATA]);
      ack[MM_MSTR_GET_RESPONSE_DATA] = 1;
      data_out2 = mm_master.get_response_data(data_in1);
      ack[MM_MSTR_GET_RESPONSE_DATA] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_LATENCY]);
      ack[MM_MSTR_GET_RESPONSE_LATENCY] = 1;
      data_out0 = mm_master.get_response_latency(data_in1);
      ack[MM_MSTR_GET_RESPONSE_LATENCY] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_REQUEST]);
      ack[MM_MSTR_GET_RESPONSE_REQUEST] = 1;
      data_out0 = mm_master.get_response_request();
      ack[MM_MSTR_GET_RESPONSE_REQUEST] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_QUEUE_SIZE]);
      ack[MM_MSTR_GET_RESPONSE_QUEUE_SIZE] = 1;
      data_out0 = mm_master.get_response_queue_size();
      ack[MM_MSTR_GET_RESPONSE_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_WAIT_TIME]);
      ack[MM_MSTR_GET_RESPONSE_WAIT_TIME] = 1;
      data_out0 = mm_master.get_response_wait_time(data_in1);
      ack[MM_MSTR_GET_RESPONSE_WAIT_TIME] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MSTR_POP_RESPONSE]);
      ack[MM_MSTR_POP_RESPONSE] = 1;
      mm_master.pop_response();
      ack[MM_MSTR_POP_RESPONSE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_PUSH_COMMAND]);
      ack[MM_MSTR_PUSH_COMMAND] = 1;
      mm_master.push_command();
      ack[MM_MSTR_PUSH_COMMAND] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_ADDRESS]);
      ack[MM_MSTR_SET_COMMAND_ADDRESS] = 1;
      mm_master.set_command_address(data_in2);
      ack[MM_MSTR_SET_COMMAND_ADDRESS] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_BYTE_ENABLE]);
      ack[MM_MSTR_SET_COMMAND_BYTE_ENABLE] = 1;
      mm_master.set_command_byte_enable(data_in2, data_in1);
      ack[MM_MSTR_SET_COMMAND_BYTE_ENABLE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_BURST_COUNT]);
      ack[MM_MSTR_SET_COMMAND_BURST_COUNT] = 1;
      mm_master.set_command_burst_count(data_in0);
      ack[MM_MSTR_SET_COMMAND_BURST_COUNT] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_BURST_SIZE]);
      ack[MM_MSTR_SET_COMMAND_BURST_SIZE] = 1;
      mm_master.set_command_burst_size(data_in0);
      ack[MM_MSTR_SET_COMMAND_BURST_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_DATA]);
      ack[MM_MSTR_SET_COMMAND_DATA] = 1;
      mm_master.set_command_data(data_in2, data_in1);
      ack[MM_MSTR_SET_COMMAND_DATA] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_IDLE]);
      ack[MM_MSTR_SET_COMMAND_IDLE] = 1;
      mm_master.set_command_idle(data_in0, data_in1);
      ack[MM_MSTR_SET_COMMAND_IDLE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_INIT_LATENCY]);
      ack[MM_MSTR_SET_COMMAND_INIT_LATENCY] = 1;
      mm_master.set_command_init_latency(data_in0);
      ack[MM_MSTR_SET_COMMAND_INIT_LATENCY] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_REQUEST]);
      ack[MM_MSTR_SET_COMMAND_REQUEST] = 1;
      mm_master.set_command_request(Request_t'(data_in0));
      ack[MM_MSTR_SET_COMMAND_REQUEST] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_ARBITERLOCK]);
      ack[MM_MSTR_SET_COMMAND_ARBITERLOCK] = 1;
      mm_master.set_command_arbiterlock(data_in0);
      ack[MM_MSTR_SET_COMMAND_ARBITERLOCK] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_LOCK]);
      ack[MM_MSTR_SET_COMMAND_LOCK] = 1;
      mm_master.set_command_lock(data_in0);
      ack[MM_MSTR_SET_COMMAND_LOCK] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_DEBUGACCESS]);
      ack[MM_MSTR_SET_COMMAND_DEBUGACCESS] = 1;
      mm_master.set_command_debugaccess(data_in0);
      ack[MM_MSTR_SET_COMMAND_DEBUGACCESS] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE]);
      ack[MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE] = 1;
      mm_master.set_max_command_queue_size(data_in0);
      ack[MM_MSTR_SET_MAX_COMMAND_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE]);
      ack[MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE] = 1;
      mm_master.set_min_command_queue_size(data_in0);
      ack[MM_MSTR_SET_MIN_COMMAND_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_TRANSACTION_ID]);
      ack[MM_MSTR_SET_COMMAND_TRANSACTION_ID] = 1;
      mm_master.set_command_transaction_id(data_in0);
      ack[MM_MSTR_SET_COMMAND_TRANSACTION_ID] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST]);
      ack[MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST] = 1;
      mm_master.set_command_write_response_request(data_in0);
      ack[MM_MSTR_SET_COMMAND_WRITE_RESPONSE_REQUEST] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_READ_RESPONSE_STATUS]);
      ack[MM_MSTR_GET_READ_RESPONSE_STATUS] = 1;
      data_out0 = mm_master.get_read_response_status(data_in1);
      ack[MM_MSTR_GET_READ_RESPONSE_STATUS] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_READ_ID]);
      ack[MM_MSTR_GET_RESPONSE_READ_ID] = 1;
      data_out0 = mm_master.get_response_read_id();
      ack[MM_MSTR_GET_RESPONSE_READ_ID] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_WRITE_RESPONSE_STATUS]);
      ack[MM_MSTR_GET_WRITE_RESPONSE_STATUS] = 1;
      data_out0 = mm_master.get_write_response_status();
      ack[MM_MSTR_GET_WRITE_RESPONSE_STATUS] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_RESPONSE_WRITE_ID]);
      ack[MM_MSTR_GET_RESPONSE_WRITE_ID] = 1;
      data_out0 = mm_master.get_response_write_id();
      ack[MM_MSTR_GET_RESPONSE_WRITE_ID] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE]);
      ack[MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE] = 1;
      data_out0 = mm_master.get_write_response_queue_size();
      ack[MM_MSTR_GET_WRITE_RESPONSE_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE]);
      ack[MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE] = 1;
      data_out0 = mm_master.get_read_response_queue_size();
      ack[MM_MSTR_GET_READ_RESPONSE_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_CLKEN]);
      ack[MM_MSTR_SET_CLKEN] = 1;
      mm_master.set_clken(data_in0);
      ack[MM_MSTR_SET_CLKEN] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      mm_master.set_idle_state_output_configuration(IdleOutputValue_t'(data_in0));
      ack[MM_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      data_out0 = mm_master.get_idle_state_output_configuration();
      ack[MM_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MSTR_INIT]);
      ack[MM_MSTR_INIT] = 1;
      mm_master.init();
      ack[MM_MSTR_INIT] <= 0;
   end
   
   // logic blocks to handle event trigger
   always @(mm_master.signal_read_response_complete) begin
      events[MM_MSTR_EVENT_READ_RESPONSE_COMPLETE] = 1;
      events[MM_MSTR_EVENT_READ_RESPONSE_COMPLETE] <= 0;
   end
   
   always @(mm_master.signal_write_response_complete) begin
      events[MM_MSTR_EVENT_WRITE_RESPONSE_COMPLETE] = 1;
      events[MM_MSTR_EVENT_WRITE_RESPONSE_COMPLETE] <= 0;
   end
   
   always @(mm_master.signal_response_complete) begin
      events[MM_MSTR_EVENT_RESPONSE_COMPLETE] = 1;
      events[MM_MSTR_EVENT_RESPONSE_COMPLETE] <= 0;
   end
   
   always @(mm_master.signal_command_issued) begin
      events[MM_MSTR_EVENT_COMMAND_ISSUED] = 1;
      events[MM_MSTR_EVENT_COMMAND_ISSUED] <= 0;
   end
   
   always @(mm_master.signal_all_transactions_complete) begin
      events[MM_MSTR_EVENT_ALL_TRANSACTIONS_COMPLETE] = 1;
      events[MM_MSTR_EVENT_ALL_TRANSACTIONS_COMPLETE] <= 0;
   end
   
   always @(mm_master.signal_max_command_queue_size) begin
      events[MM_MSTR_EVENT_MAX_COMMAND_QUEUE_SIZE] = 1;
      events[MM_MSTR_EVENT_MAX_COMMAND_QUEUE_SIZE] <= 0;
   end
   
   always @(mm_master.signal_min_command_queue_size) begin
      events[MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE] = 1;
      events[MM_MSTR_EVENT_MIN_COMMAND_QUEUE_SIZE] <= 0;
   end

// synthesis translate_on
endmodule 
