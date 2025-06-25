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

// enum for VHDL procedure
typedef enum int {
   // procedure for transaction
   MM_MONITOR_SET_TRANSACTION_FIFO_MAX                                  = 32'd0,
   MM_MONITOR_GET_TRANSACTION_FIFO_MAX                                  = 32'd1,
   MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD                            = 32'd2,
   MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD                            = 32'd3,
   MM_MONITOR_SET_COMMAND_TRANSACTION_MODE                              = 32'd4,
   MM_MONITOR_POP_COMMAND                                               = 32'd5,
   MM_MONITOR_GET_COMMAND_QUEUE_SIZE                                    = 32'd6,
   MM_MONITOR_GET_COMMAND_REQUEST                                       = 32'd7,
   MM_MONITOR_GET_COMMAND_ADDRESS                                       = 32'd8,
   MM_MONITOR_GET_COMMAND_BURST_COUNT                                   = 32'd9,
   MM_MONITOR_GET_COMMAND_DATA                                          = 32'd10,
   MM_MONITOR_GET_COMMAND_BYTE_ENABLE                                   = 32'd11,
   MM_MONITOR_GET_COMMAND_BURST_CYCLE                                   = 32'd12,
   MM_MONITOR_GET_COMMAND_ARBITERLOCK                                   = 32'd13,
   MM_MONITOR_GET_COMMAND_LOCK                                          = 32'd14,
   MM_MONITOR_GET_COMMAND_DEBUGACCESS                                   = 32'd15,
   MM_MONITOR_GET_COMMAND_TRANSACTION_ID                                = 32'd16,
   MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST                        = 32'd17,
   MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE                             = 32'd18,
   MM_MONITOR_GET_RESPONSE_ADDRESS                                      = 32'd19,
   MM_MONITOR_GET_RESPONSE_BYTE_ENABLE                                  = 32'd20,
   MM_MONITOR_GET_RESPONSE_BURST_SIZE                                   = 32'd21,
   MM_MONITOR_GET_RESPONSE_DATA                                         = 32'd22,
   MM_MONITOR_GET_RESPONSE_LATENCY                                      = 32'd23,
   MM_MONITOR_GET_RESPONSE_REQUEST                                      = 32'd24,
   MM_MONITOR_GET_RESPONSE_QUEUE_SIZE                                   = 32'd25,
   MM_MONITOR_GET_RESPONSE_WAIT_TIME                                    = 32'd26,
   MM_MONITOR_POP_RESPONSE                                              = 32'd27,
   MM_MONITOR_GET_READ_RESPONSE_STATUS                                  = 32'd28,
   MM_MONITOR_GET_RESPONSE_READ_ID                                      = 32'd29,
   MM_MONITOR_GET_WRITE_RESPONSE_STATUS                                 = 32'd30,
   MM_MONITOR_GET_RESPONSE_WRITE_ID                                     = 32'd31,
   MM_MONITOR_GET_CLKEN                                                 = 32'd32,
   MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE                             = 32'd33,
   MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE                              = 32'd34,
   MM_MONITOR_INIT                                                      = 32'd35
} mm_monitor_vhdl_api_e;

typedef enum int {
   MM_MONITOR_EVENT_TRANSACTION_FIFO_THRESHOLD     = 32'd0,
   MM_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW      = 32'd1,
   MM_MONITOR_EVENT_COMMAND_RECEIVED               = 32'd2,
   MM_MONITOR_EVENT_READ_RESPONSE_COMPLETE         = 32'd3,
   MM_MONITOR_EVENT_WRITE_RESPONSE_COMPLETE        = 32'd4,
   MM_MONITOR_EVENT_RESPONSE_COMPLETE              = 32'd5
} mm_mstr_vhdl_event_e;

module altera_avalon_mm_monitor_vhdl_wrapper #(
   parameter AV_ADDRESS_W                    = 32,
             AV_SYMBOL_W                     = 8,
             AV_NUMSYMBOLS                   = 4,
             AV_BURSTCOUNT_W                 = 3,
             AV_CONSTANT_BURST_BEHAVIOR      = 1,
             AV_BURST_LINEWRAP               = 0,
             AV_BURST_BNDR_ONLY              = 0,
             REGISTER_WAITREQUEST            = 0,
             AV_MAX_PENDING_READS            = 0,
             AV_MAX_PENDING_WRITES           = 0,
             AV_FIX_READ_LATENCY             = 0,
             USE_READ                        = 1,
             USE_WRITE                       = 1,
             USE_ADDRESS                     = 1,
             USE_BYTE_ENABLE                 = 1,
             USE_BURSTCOUNT                  = 0,
             USE_READ_DATA                   = 1,
             USE_READ_DATA_VALID             = 1,
             USE_WRITE_DATA                  = 1,
             USE_BEGIN_TRANSFER              = 0,
             USE_BEGIN_BURST_TRANSFER        = 0,
             USE_WAIT_REQUEST                = 1,
             USE_ARBITERLOCK                 = 0,
             USE_LOCK                        = 0,
             USE_DEBUGACCESS                 = 0,
             USE_TRANSACTIONID               = 0,
             USE_WRITERESPONSE               = 0,
             USE_READRESPONSE                = 0,
             USE_CLKEN                       = 0,
             AV_READ_TIMEOUT                 = 100,
             AV_WRITE_TIMEOUT                = 100,
             AV_WAITREQUEST_TIMEOUT          = 1024,
             AV_MAX_READ_LATENCY             = 100,
             AV_MAX_WAITREQUESTED_READ       = 100,
             AV_MAX_WAITREQUESTED_WRITE      = 100,
             AV_MAX_CONTINUOUS_READ          = 5,
             AV_MAX_CONTINUOUS_WRITE         = 5,
             AV_MAX_CONTINUOUS_WAITREQUEST   = 5,
             AV_MAX_CONTINUOUS_READDATAVALID = 5,
             SLAVE_ADDRESS_TYPE              = "SYMBOLS",
             MASTER_ADDRESS_TYPE             = "SYMBOLS",
             AV_READ_WAIT_TIME               = 0,
             AV_WRITE_WAIT_TIME              = 0,
             AV_REGISTERINCOMINGSIGNALS      = 0,
             MM_MAX_BIT_W                    = 1024,
             AV_SLAVE_ADDRESS_W = (SLAVE_ADDRESS_TYPE != MASTER_ADDRESS_TYPE)? (AV_ADDRESS_W - log2(AV_NUMSYMBOLS)):AV_ADDRESS_W
)(
   input  logic                                                clk,
   input  logic                                                reset,
   output logic                                                avm_clken,
   input  logic                                                avs_clken,
   input  logic                                                avm_waitrequest,
   input  logic                                                avm_readdatavalid,
   input  logic [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]        avm_readdata,
   output logic                                                avm_write,
   output logic                                                avm_read,
   output logic [lindex(AV_ADDRESS_W):0]                       avm_address,
   output logic [lindex(AV_NUMSYMBOLS):0]                      avm_byteenable,
   output logic [lindex(AV_BURSTCOUNT_W):0]                    avm_burstcount,
   output logic                                                avm_beginbursttransfer,
   output logic                                                avm_begintransfer,
   output logic [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]        avm_writedata,
   output logic                                                avm_arbiterlock,
   output logic                                                avm_lock,
   output logic                                                avm_debugaccess,
   output logic [7:0]                                          avm_transactionid,
   input  logic [7:0]                                          avm_readid,
   output logic                                                avm_writeresponserequest,
   input  logic                                                avm_writeresponsevalid,
   input  logic [1:0]                                          avm_response,
   input  logic [7:0]                                          avm_writeid,
   output logic                                                avs_waitrequest,
   output logic                                                avs_readdatavalid,
   output logic [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]        avs_readdata,
   input  logic                                                avs_write,
   input  logic                                                avs_read,
   input  logic [lindex(AV_SLAVE_ADDRESS_W):0]                 avs_address,
   input  logic [lindex(AV_NUMSYMBOLS):0]                      avs_byteenable,
   input  logic [lindex(AV_BURSTCOUNT_W):0]                    avs_burstcount,
   input  logic                                                avs_beginbursttransfer,
   input  logic                                                avs_begintransfer,
   input  logic [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]        avs_writedata,
   input  logic                                                avs_arbiterlock,
   input  logic                                                avs_lock,
   input  logic                                                avs_debugaccess,   
   input  logic [7:0]                                          avs_transactionid,
   output logic [7:0]                                          avs_readid,
   input  logic                                                avs_writeresponserequest,
   output logic                                                avs_writeresponsevalid,
   output logic [1:0]                                          avs_response,
   output logic [7:0]                                          avs_writeid,
   
   // VHDL API request interface
   input  bit [MM_MONITOR_INIT:0]                              req,
   output bit [MM_MONITOR_INIT:0]                              ack,
   input  int                                                  data_in0,
   input  int                                                  data_in1,
   input  bit [lindex(MM_MAX_BIT_W): 0]                        data_in2,
   output int                                                  data_out0,
   output int                                                  data_out1,
   output bit [lindex(MM_MAX_BIT_W): 0]                        data_out2,
   output bit [MM_MONITOR_EVENT_RESPONSE_COMPLETE:0]           events
);

   import avalon_mm_pkg::*;
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex =(width > 0) ?(width-1) : 0;
   endfunction
   
   // Get the width of the signal
   function integer log2(
      input int value
   );
      value = value-1;
      for (log2=0; value>0; log2=log2+1) begin
         value = value>>1;
      end
   endfunction: log2
   
   // Shift the slave interface address back as master interface address
   function logic [AV_ADDRESS_W-1:0] address_shift(
      input logic [AV_ADDRESS_W-1:0] value
   );
      if (value >= 0)
         address_shift = value << log2(AV_NUMSYMBOLS);
      else
         address_shift = 'x;
   endfunction: address_shift
   
   localparam AV_DATA_W = AV_SYMBOL_W * AV_NUMSYMBOLS;
   localparam AV_MAX_BURST = USE_BURSTCOUNT ? 2**(AV_BURSTCOUNT_W-1) : 1;
   localparam AV_TRANSACTIONID_W = 8;
   localparam TAP_W = 1 +                                                  // clken
                      1 +                                                  // arbiterlock
                      1 +                                                  // lock
                      1 +                                                  // debugaccess
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // transactionid
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // readid
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // avm_writeid
                      1 +                                                  // writeresponserequest
                      1 +                                                  // writeresponsevalid
                      2 +                                                  // response
                      1 +                                                  // waitrequest
                      1 +                                                  // readdatavalid
                      ((AV_DATA_W == 0)? 1:AV_DATA_W) +                    // readdata
                      1 +                                                  // write
                      1 +                                                  // read
                      ((AV_ADDRESS_W == 0)? 1:AV_ADDRESS_W) +              // address
                      ((AV_NUMSYMBOLS == 0)? 1:AV_NUMSYMBOLS) +            // byteenable
                      ((AV_BURSTCOUNT_W == 0)? 1:AV_BURSTCOUNT_W) +        // burstcount
                      1 +                                                  // beginbursttransfer
                      1 +                                                  // begintransfer
                      ((AV_DATA_W == 0)? 1:AV_DATA_W);                     // writedata
   
   
   logic [31:0]               read_wait_time          = 0;
   logic [31:0]               write_wait_time         = 0;
   logic                      local_avs_waitrequest;
   logic                      local_waitrequest;
   logic [lindex(TAP_W):0]    tap;
   
   always @(posedge clk) begin
      if (USE_WAIT_REQUEST == 0) begin
         if (reset) begin
            local_avs_waitrequest = 0;
            read_wait_time = 0;
            write_wait_time = 0;
         end else begin
            local_avs_waitrequest = 0;
            if (AV_READ_WAIT_TIME > 0) begin
               #1;
               if (avs_read) begin
                  if (read_wait_time < AV_READ_WAIT_TIME) begin
                     local_avs_waitrequest = 1;
                     read_wait_time++;
                  end else begin
                     local_avs_waitrequest = 0;
                     read_wait_time = 0;
                  end
               end
            end
            
            if (AV_WRITE_WAIT_TIME > 0) begin
               #1;
               if (avs_write) begin
                  if (write_wait_time < AV_WRITE_WAIT_TIME) begin
                     local_avs_waitrequest = 1;
                     write_wait_time++;
                  end else begin
                     local_avs_waitrequest = 0;
                     write_wait_time = 0;
                  end
               end
            end
         end
      end else begin
         local_avs_waitrequest = avm_waitrequest;
      end
   end
   
   assign avm_clken                 = avs_clken;
   assign avs_waitrequest           = (USE_WAIT_REQUEST == 0)? local_avs_waitrequest : avm_waitrequest;
   assign avs_readdatavalid         = avm_readdatavalid;
   assign avs_readdata              = avm_readdata;
   assign avm_write                 = avs_write;
   assign avm_read                  = avs_read;
   assign avm_address               = (SLAVE_ADDRESS_TYPE != MASTER_ADDRESS_TYPE)? address_shift(avs_address) : avs_address;
   assign avm_byteenable            = avs_byteenable;
   assign avm_burstcount            = avs_burstcount;
   assign avm_beginbursttransfer    = avs_beginbursttransfer;
   assign avm_begintransfer         = avs_begintransfer;
   assign avm_writedata             = avs_writedata;
   assign avm_arbiterlock           = avs_arbiterlock;
   assign avm_lock                  = avs_lock;
   assign avm_debugaccess           = avs_debugaccess;
   assign avm_transactionid         = avs_transactionid;
   assign avs_readid                = avm_readid;
   assign avm_writeresponserequest  = avs_writeresponserequest;
   assign avs_writeresponsevalid    = avm_writeresponsevalid;
   assign avs_response              = avm_response;
   assign avs_writeid               = avm_writeid;
   assign local_waitrequest         = (USE_WAIT_REQUEST == 0)? local_avs_waitrequest:avm_waitrequest;
      
   // snoop bus for assertion and coverage checking
   assign tap = {avs_clken,
                 avs_arbiterlock,
                 avs_lock,
                 avs_debugaccess,
                 avs_transactionid,
                 avm_readid,
                 avm_writeid,                 
                 avm_response,
                 avs_writeresponserequest,
                 avm_writeresponsevalid,
                 local_waitrequest,
                 avm_readdatavalid,
                 avm_readdata,
                 avs_write,
                 avs_read,
                 avm_address,
                 avs_byteenable,
                 avs_burstcount,
                 avs_beginbursttransfer,
                 avs_begintransfer,
                 avs_writedata 
                 };
   
   altera_avalon_mm_monitor_transactions #(
      .AV_ADDRESS_W(AV_ADDRESS_W),
      .AV_SYMBOL_W(AV_SYMBOL_W),
      .AV_NUMSYMBOLS(AV_NUMSYMBOLS),
      .AV_BURSTCOUNT_W(AV_BURSTCOUNT_W),
      .AV_CONSTANT_BURST_BEHAVIOR(AV_CONSTANT_BURST_BEHAVIOR),
      .AV_BURST_LINEWRAP(AV_BURST_LINEWRAP),
      .AV_BURST_BNDR_ONLY(AV_BURST_BNDR_ONLY),
      .REGISTER_WAITREQUEST(REGISTER_WAITREQUEST),
      .AV_MAX_PENDING_READS(AV_MAX_PENDING_READS),
      .AV_MAX_PENDING_WRITES(AV_MAX_PENDING_WRITES),
      .AV_FIX_READ_LATENCY(AV_FIX_READ_LATENCY),
      .USE_READ(USE_READ),
      .USE_WRITE(USE_WRITE),
      .USE_ADDRESS(USE_ADDRESS),
      .USE_BYTE_ENABLE(USE_BYTE_ENABLE),
      .USE_BURSTCOUNT(USE_BURSTCOUNT),
      .USE_READ_DATA(USE_READ_DATA),
      .USE_READ_DATA_VALID(USE_READ_DATA_VALID),
      .USE_WRITE_DATA(USE_WRITE_DATA),
      .USE_BEGIN_TRANSFER(USE_BEGIN_TRANSFER),
      .USE_BEGIN_BURST_TRANSFER (USE_BEGIN_BURST_TRANSFER),
      .USE_WAIT_REQUEST(USE_WAIT_REQUEST),
      .USE_ARBITERLOCK(USE_ARBITERLOCK),
      .USE_LOCK(USE_LOCK),
      .USE_DEBUGACCESS(USE_DEBUGACCESS),
      .USE_TRANSACTIONID(USE_TRANSACTIONID),
      .USE_WRITERESPONSE(USE_WRITERESPONSE),
      .USE_READRESPONSE(USE_READRESPONSE),
      .USE_CLKEN(USE_CLKEN),
      .AV_READ_WAIT_TIME(AV_READ_WAIT_TIME),
      .AV_WRITE_WAIT_TIME(AV_WRITE_WAIT_TIME)
   ) mm_monitor_trans(
      .clk(clk),
      .reset(reset),
      .tap(tap)
   );

// logic block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[MM_MONITOR_SET_TRANSACTION_FIFO_MAX]);
      ack[MM_MONITOR_SET_TRANSACTION_FIFO_MAX] = 1;
      mm_monitor_trans.set_transaction_fifo_max(data_in0);
      ack[MM_MONITOR_SET_TRANSACTION_FIFO_MAX] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_GET_TRANSACTION_FIFO_MAX]);
      ack[MM_MONITOR_GET_TRANSACTION_FIFO_MAX] = 1;
      data_out0 = mm_monitor_trans.get_transaction_fifo_max();
      ack[MM_MONITOR_GET_TRANSACTION_FIFO_MAX] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD]);
      ack[MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD] = 1;
      mm_monitor_trans.set_transaction_fifo_threshold(data_in0);
      ack[MM_MONITOR_SET_TRANSACTION_FIFO_THRESHOLD] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD]);
      ack[MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD] = 1;
      data_out0 = mm_monitor_trans.get_transaction_fifo_threshold();
      ack[MM_MONITOR_GET_TRANSACTION_FIFO_THRESHOLD] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_SET_COMMAND_TRANSACTION_MODE]);
      ack[MM_MONITOR_SET_COMMAND_TRANSACTION_MODE] = 1;
      mm_monitor_trans.set_command_transaction_mode(data_in0);
      ack[MM_MONITOR_SET_COMMAND_TRANSACTION_MODE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_POP_COMMAND]);
      ack[MM_MONITOR_POP_COMMAND] = 1;
      mm_monitor_trans.pop_command();
      ack[MM_MONITOR_POP_COMMAND] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_QUEUE_SIZE]);
      ack[MM_MONITOR_GET_COMMAND_QUEUE_SIZE] = 1;
      data_out0 = mm_monitor_trans.get_command_queue_size();
      ack[MM_MONITOR_GET_COMMAND_QUEUE_SIZE] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_REQUEST]);
      ack[MM_MONITOR_GET_COMMAND_REQUEST] = 1;
      data_out0 = mm_monitor_trans.get_command_request();
      ack[MM_MONITOR_GET_COMMAND_REQUEST] <= 0;
   end
   
   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_ADDRESS]);
      ack[MM_MONITOR_GET_COMMAND_ADDRESS] = 1;
      data_out2 = mm_monitor_trans.get_command_address();
      ack[MM_MONITOR_GET_COMMAND_ADDRESS] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_BURST_COUNT]);
      ack[MM_MONITOR_GET_COMMAND_BURST_COUNT] = 1;
      data_out0 = mm_monitor_trans.get_command_burst_count();
      ack[MM_MONITOR_GET_COMMAND_BURST_COUNT] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_DATA]);
      ack[MM_MONITOR_GET_COMMAND_DATA] = 1;
      data_out2 = mm_monitor_trans.get_command_data(data_in1);
      ack[MM_MONITOR_GET_COMMAND_DATA] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_BYTE_ENABLE]);
      ack[MM_MONITOR_GET_COMMAND_BYTE_ENABLE] = 1;
      data_out2 = mm_monitor_trans.get_command_byte_enable(data_in1);
      ack[MM_MONITOR_GET_COMMAND_BYTE_ENABLE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_BURST_CYCLE]);
      ack[MM_MONITOR_GET_COMMAND_BURST_CYCLE] = 1;
      data_out0 = mm_monitor_trans.get_command_burst_cycle();
      ack[MM_MONITOR_GET_COMMAND_BURST_CYCLE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_ARBITERLOCK]);
      ack[MM_MONITOR_GET_COMMAND_ARBITERLOCK] = 1;
      data_out0 = mm_monitor_trans.get_command_arbiterlock();
      ack[MM_MONITOR_GET_COMMAND_ARBITERLOCK] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_LOCK]);
      ack[MM_MONITOR_GET_COMMAND_LOCK] = 1;
      data_out0 = mm_monitor_trans.get_command_lock();
      ack[MM_MONITOR_GET_COMMAND_LOCK] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_DEBUGACCESS]);
      ack[MM_MONITOR_GET_COMMAND_DEBUGACCESS] = 1;
      data_out0 = mm_monitor_trans.get_command_debugaccess();
      ack[MM_MONITOR_GET_COMMAND_DEBUGACCESS] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_TRANSACTION_ID]);
      ack[MM_MONITOR_GET_COMMAND_TRANSACTION_ID] = 1;
      data_out0 = mm_monitor_trans.get_command_transaction_id();
      ack[MM_MONITOR_GET_COMMAND_TRANSACTION_ID] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST]);
      ack[MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST] = 1;
      data_out0 = mm_monitor_trans.get_command_write_response_request();
      ack[MM_MONITOR_GET_COMMAND_WRITE_RESPONSE_REQUEST] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE]);
      ack[MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE] = 1;
      data_out0 = mm_monitor_trans.get_command_issued_queue_size();
      ack[MM_MONITOR_GET_COMMAND_ISSUED_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_ADDRESS]);
      ack[MM_MONITOR_GET_RESPONSE_ADDRESS] = 1;
      data_out2 = mm_monitor_trans.get_response_address();
      ack[MM_MONITOR_GET_RESPONSE_ADDRESS] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_BYTE_ENABLE]);
      ack[MM_MONITOR_GET_RESPONSE_BYTE_ENABLE] = 1;
      data_out2 = mm_monitor_trans.get_response_byte_enable(data_in1);
      ack[MM_MONITOR_GET_RESPONSE_BYTE_ENABLE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_BURST_SIZE]);
      ack[MM_MONITOR_GET_RESPONSE_BURST_SIZE] = 1;
      data_out0 = mm_monitor_trans.get_response_burst_size();
      ack[MM_MONITOR_GET_RESPONSE_BURST_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_DATA]);
      ack[MM_MONITOR_GET_RESPONSE_DATA] = 1;
      data_out2 = mm_monitor_trans.get_response_data(data_in1);
      ack[MM_MONITOR_GET_RESPONSE_DATA] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_LATENCY]);
      ack[MM_MONITOR_GET_RESPONSE_LATENCY] = 1;
      data_out0 = mm_monitor_trans.get_response_latency(data_in1);
      ack[MM_MONITOR_GET_RESPONSE_LATENCY] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_REQUEST]);
      ack[MM_MONITOR_GET_RESPONSE_REQUEST] = 1;
      data_out0 = mm_monitor_trans.get_response_request();
      ack[MM_MONITOR_GET_RESPONSE_REQUEST] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_QUEUE_SIZE]);
      ack[MM_MONITOR_GET_RESPONSE_QUEUE_SIZE] = 1;
      data_out0 = mm_monitor_trans.get_response_queue_size();
      ack[MM_MONITOR_GET_RESPONSE_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_WAIT_TIME]);
      ack[MM_MONITOR_GET_RESPONSE_WAIT_TIME] = 1;
      data_out0 = mm_monitor_trans.get_response_wait_time(data_in1);
      ack[MM_MONITOR_GET_RESPONSE_WAIT_TIME] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_POP_RESPONSE]);
      ack[MM_MONITOR_POP_RESPONSE] = 1;
      mm_monitor_trans.pop_response();
      ack[MM_MONITOR_POP_RESPONSE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_READ_RESPONSE_STATUS]);
      ack[MM_MONITOR_GET_READ_RESPONSE_STATUS] = 1;
      data_out0 = mm_monitor_trans.get_read_response_status(data_in1);
      ack[MM_MONITOR_GET_READ_RESPONSE_STATUS] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_READ_ID]);
      ack[MM_MONITOR_GET_RESPONSE_READ_ID] = 1;
      data_out0 = mm_monitor_trans.get_response_read_id();
      ack[MM_MONITOR_GET_RESPONSE_READ_ID] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_WRITE_RESPONSE_STATUS]);
      ack[MM_MONITOR_GET_WRITE_RESPONSE_STATUS] = 1;
      data_out0 = mm_monitor_trans.get_write_response_status();
      ack[MM_MONITOR_GET_WRITE_RESPONSE_STATUS] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_RESPONSE_WRITE_ID]);
      ack[MM_MONITOR_GET_RESPONSE_WRITE_ID] = 1;
      data_out0 = mm_monitor_trans.get_response_write_id();
      ack[MM_MONITOR_GET_RESPONSE_WRITE_ID] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_CLKEN]);
      ack[MM_MONITOR_GET_CLKEN] = 1;
      data_out0 = mm_monitor_trans.get_clken();
      ack[MM_MONITOR_GET_CLKEN] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE]);
      ack[MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE] = 1;
      data_out0 = mm_monitor_trans.get_write_response_queue_size();
      ack[MM_MONITOR_GET_WRITE_RESPONSE_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE]);
      ack[MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE] = 1;
      data_out0 = mm_monitor_trans.get_read_response_queue_size();
      ack[MM_MONITOR_GET_READ_RESPONSE_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[MM_MONITOR_INIT]);
      ack[MM_MONITOR_INIT] = 1;
      mm_monitor_trans.init();
      ack[MM_MONITOR_INIT] <= 0;
   end

   // logic blocks to handle monitor transaction event trigger
   always @(mm_monitor_trans.signal_transaction_fifo_threshold) begin
      events[MM_MONITOR_EVENT_TRANSACTION_FIFO_THRESHOLD] = 1;
      events[MM_MONITOR_EVENT_TRANSACTION_FIFO_THRESHOLD] <= 0;
   end
   
   always @(mm_monitor_trans.signal_transaction_fifo_overflow) begin
      events[MM_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW] = 1;
      events[MM_MONITOR_EVENT_TRANSACTION_FIFO_OVERFLOW] <= 0;
   end
   
   always @(mm_monitor_trans.signal_command_received) begin
      events[MM_MONITOR_EVENT_COMMAND_RECEIVED] = 1;
      events[MM_MONITOR_EVENT_COMMAND_RECEIVED] <= 0;
   end
   
   always @(mm_monitor_trans.signal_read_response_complete) begin
      events[MM_MONITOR_EVENT_READ_RESPONSE_COMPLETE] = 1;
      events[MM_MONITOR_EVENT_READ_RESPONSE_COMPLETE] <= 0;
   end
   
   always @(mm_monitor_trans.signal_write_response_complete) begin
      events[MM_MONITOR_EVENT_WRITE_RESPONSE_COMPLETE] = 1;
      events[MM_MONITOR_EVENT_WRITE_RESPONSE_COMPLETE] <= 0;
   end
   
   always @(mm_monitor_trans.signal_response_complete) begin
      events[MM_MONITOR_EVENT_RESPONSE_COMPLETE] = 1;
      events[MM_MONITOR_EVENT_RESPONSE_COMPLETE] <= 0;
   end
   
endmodule 