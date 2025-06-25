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


`timescale 1ns / 1ns

// synthesis translate_off
// enum for VHDL procedure
typedef enum int {
   CI_MSTR_SET_CI_CLK_EN                        = 32'd0,
   CI_MSTR_INSERT_INSTRUCTION                   = 32'd1,
   CI_MSTR_RETRIVE_RESULT                       = 32'd2,
   CI_MSTR_SET_INSTRUCTION_DATAA                = 32'd3,
   CI_MSTR_SET_INSTRUCTION_DATAB                = 32'd4,
   CI_MSTR_SET_INSTRUCTION_N                    = 32'd5,
   CI_MSTR_SET_INSTRUCTION_A                    = 32'd6,
   CI_MSTR_SET_INSTRUCTION_B                    = 32'd7,
   CI_MSTR_SET_INSTRUCTION_C                    = 32'd8,
   CI_MSTR_SET_INSTRUCTION_READRA               = 32'd9,
   CI_MSTR_SET_INSTRUCTION_READRB               = 32'd10,
   CI_MSTR_SET_INSTRUCTION_WRITERC              = 32'd11,
   CI_MSTR_SET_INSTRUCTION_IDLE                 = 32'd12,
   CI_MSTR_SET_INSTRUCTION_ERR_INJECT           = 32'd13,
   CI_MSTR_GET_RESULT_VALUE                     = 32'd14,
   CI_MSTR_GET_RESULT_DELAY                     = 32'd15,
   CI_MSTR_PUSH_INSTRUCTION                     = 32'd16,
   CI_MSTR_POP_RESULT                           = 32'd17,
   CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE       = 32'd18,
   CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE       = 32'd19,
   CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE            = 32'd20,
   CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE            = 32'd21,
   CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE           = 32'd22,
   CI_MSTR_GET_RESULT_QUEUE_SIZE                = 32'd23,
   CI_MSTR_SET_INSTRUCTION_TIMEOUT              = 32'd24,
   CI_MSTR_SET_RESULT_TIMEOUT                   = 32'd25,
   CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION  = 32'd26,
   CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION  = 32'd27,
   CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT             = 32'd28
} ci_mstr_vhdl_api_e;

// enum for VHDL event
typedef enum int {
   CI_MSTR_EVENT_INSTRUCTION_START              = 32'd0,
   CI_MSTR_EVENT_RESULT_RECEIVED                = 32'd1,
   CI_MSTR_EVENT_UNEXPECTED_RESULT_RECEIVED     = 32'd2,
   CI_MSTR_EVENT_INSTRUCTIONS_COMPLETED         = 32'd3,
   CI_MSTR_EVENT_MAX_INSTRUCTION_QUEUE_SIZE     = 32'd4,
   CI_MSTR_EVENT_MIN_INSTRUCTION_QUEUE_SIZE     = 32'd5,
   CI_MSTR_EVENT_MAX_RESULT_QUEUE_SIZE          = 32'd6,
   CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE          = 32'd7
} ci_mstr_vhdl_event_e;

// synthesis translate_on
module altera_nios2_custom_instr_master_bfm_vhdl_wrapper #(
   parameter NUM_OPERANDS     = 2,
             USE_RESULT       = 1,
             USE_MULTI_CYCLE  = 0,
             FIXED_LENGTH     = 2,
             USE_START        = 1,
             USE_DONE         = 0,
             USE_EXTENSION    = 0,
             EXT_WIDTH        = 8,
             USE_READRA       = 0,
             USE_READRB       = 0,
             USE_WRITERC      = 0,
             CI_MAX_BIT_W     = 352
)(
   input                            clk,
   input                            reset,
   output                           ci_clk,
   output                           ci_reset,
   output                           ci_clk_en,
   output [31: 0]                   ci_dataa,
   output [31: 0]                   ci_datab,
   input  [31: 0]                   ci_result,
   output                           ci_start,
   input                            ci_done,
   output [EXT_WIDTH-1: 0]          ci_n,
   output [4: 0]                    ci_a,
   output [4: 0]                    ci_b,
   output [4: 0]                    ci_c,
   output                           ci_readra,
   output                           ci_readrb,
   output                           ci_writerc,
   
   // VHDL API request interface
   input  bit [CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT:0]       req,
   output bit [CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT:0]       ack,
   input  int                                            data_in0,
   input  bit [lindex(CI_MAX_BIT_W): 0]                  data_in1,
   output int                                            data_out0,
   output bit [lindex(CI_MAX_BIT_W): 0]                  data_out1,
   output bit [CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE:0]    events
);
   
   // synthesis translate_off
   import avalon_utilities_pkg::*;
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction
   
   altera_nios2_custom_instr_master_bfm #(
      .NUM_OPERANDS(NUM_OPERANDS),
      .USE_RESULT(USE_RESULT),
      .USE_MULTI_CYCLE(USE_MULTI_CYCLE),
      .FIXED_LENGTH(FIXED_LENGTH),
      .USE_START(USE_START),
      .USE_DONE(USE_DONE),
      .USE_EXTENSION(USE_EXTENSION),
      .EXT_WIDTH(EXT_WIDTH),
      .USE_READRA(USE_READRA),
      .USE_READRB(USE_READRB),
      .USE_WRITERC(USE_WRITERC)
   ) ci_master (
      .clk(clk),
      .reset(reset),
      .ci_clk(ci_clk),
      .ci_reset(ci_reset),
      .ci_clk_en(ci_clk_en),
      .ci_dataa(ci_dataa),
      .ci_datab(ci_datab),
      .ci_result(ci_result),
      .ci_start(ci_start),
      .ci_done(ci_done),
      .ci_n(ci_n),
      .ci_a(ci_a),
      .ci_b(ci_b),
      .ci_c(ci_c),
      .ci_readra(ci_readra),
      .ci_readrb(ci_readrb),
      .ci_writerc(ci_writerc)
   );
   
   // logic block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[CI_MSTR_SET_CI_CLK_EN]);
      ack[CI_MSTR_SET_CI_CLK_EN] = 1;
      ci_master.set_ci_clk_en(data_in0);
      ack[CI_MSTR_SET_CI_CLK_EN] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_INSERT_INSTRUCTION]);
      ack[CI_MSTR_INSERT_INSTRUCTION] = 1;
      ci_master.insert_instruction(
         data_in1[351:320],
         data_in1[319:288],
         data_in1[287:256],
         data_in1[255:224],
         data_in1[223:192],
         data_in1[191:160],
         data_in1[159:128],
         data_in1[127:96],
         data_in1[95:64],
         data_in1[63:32],
         data_in1[31:0]
      );
      ack[CI_MSTR_INSERT_INSTRUCTION] <= 0;
   end
   
   initial forever begin
      @(posedge req[CI_MSTR_RETRIVE_RESULT]);
      ack[CI_MSTR_RETRIVE_RESULT] = 1;
      ci_master.retrive_result(
         data_out1[63:32],
         data_out1[31:0]
      );
      ack[CI_MSTR_RETRIVE_RESULT] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_DATAA]);
      ack[CI_MSTR_SET_INSTRUCTION_DATAA] = 1;
      ci_master.set_instruction_dataa(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_DATAA] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_DATAB]);
      ack[CI_MSTR_SET_INSTRUCTION_DATAB] = 1;
      ci_master.set_instruction_datab(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_DATAB] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_N]);
      ack[CI_MSTR_SET_INSTRUCTION_N] = 1;
      ci_master.set_instruction_n(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_N] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_A]);
      ack[CI_MSTR_SET_INSTRUCTION_A] = 1;
      ci_master.set_instruction_a(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_A] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_B]);
      ack[CI_MSTR_SET_INSTRUCTION_B] = 1;
      ci_master.set_instruction_b(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_B] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_C]);
      ack[CI_MSTR_SET_INSTRUCTION_C] = 1;
      ci_master.set_instruction_c(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_C] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_READRA]);
      ack[CI_MSTR_SET_INSTRUCTION_READRA] = 1;
      ci_master.set_instruction_readra(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_READRA] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_READRB]);
      ack[CI_MSTR_SET_INSTRUCTION_READRB] = 1;
      ci_master.set_instruction_readrb(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_READRB] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_WRITERC]);
      ack[CI_MSTR_SET_INSTRUCTION_WRITERC] = 1;
      ci_master.set_instruction_writerc(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_WRITERC] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_IDLE]);
      ack[CI_MSTR_SET_INSTRUCTION_IDLE] = 1;
      ci_master.set_instruction_idle(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_IDLE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_ERR_INJECT]);
      ack[CI_MSTR_SET_INSTRUCTION_ERR_INJECT] = 1;
      ci_master.set_instruction_err_inject(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_ERR_INJECT] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_GET_RESULT_VALUE]);
      ack[CI_MSTR_GET_RESULT_VALUE] = 1;
      data_out0 = ci_master.get_result_value();
      ack[CI_MSTR_GET_RESULT_VALUE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_GET_RESULT_DELAY]);
      ack[CI_MSTR_GET_RESULT_DELAY] = 1;
      data_out0 = ci_master.get_result_delay();
      ack[CI_MSTR_GET_RESULT_DELAY] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_PUSH_INSTRUCTION]);
      ack[CI_MSTR_PUSH_INSTRUCTION] = 1;
      ci_master.push_instruction();
      ack[CI_MSTR_PUSH_INSTRUCTION] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_POP_RESULT]);
      ack[CI_MSTR_POP_RESULT] = 1;
      ci_master.pop_result();
      ack[CI_MSTR_POP_RESULT] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE]);
      ack[CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE] = 1;
      ci_master.set_max_instruction_queue_size(data_in0);
      ack[CI_MSTR_SET_MAX_INSTRUCTION_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE]);
      ack[CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE] = 1;
      ci_master.set_min_instruction_queue_size(data_in0);
      ack[CI_MSTR_SET_MIN_INSTRUCTION_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE]);
      ack[CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE] = 1;
      ci_master.set_max_result_queue_size(data_in0);
      ack[CI_MSTR_SET_MAX_RESULT_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE]);
      ack[CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE] = 1;
      ci_master.set_min_result_queue_size(data_in0);
      ack[CI_MSTR_SET_MIN_RESULT_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE]);
      ack[CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE] = 1;
      data_out0 = ci_master.get_instruction_queue_size();
      ack[CI_MSTR_GET_INSTRUCTION_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_GET_RESULT_QUEUE_SIZE]);
      ack[CI_MSTR_GET_RESULT_QUEUE_SIZE] = 1;
      data_out0 = ci_master.get_result_queue_size();
      ack[CI_MSTR_GET_RESULT_QUEUE_SIZE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_INSTRUCTION_TIMEOUT]);
      ack[CI_MSTR_SET_INSTRUCTION_TIMEOUT] = 1;
      ci_master.set_instruction_timeout(data_in0);
      ack[CI_MSTR_SET_INSTRUCTION_TIMEOUT] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_RESULT_TIMEOUT]);
      ack[CI_MSTR_SET_RESULT_TIMEOUT] = 1;
      ci_master.set_result_timeout(data_in0);
      ack[CI_MSTR_SET_RESULT_TIMEOUT] <= 0;
   end
   
   initial forever begin
      @(posedge req[CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      ci_master.set_idle_state_output_configuration(IdleOutputValue_t'(data_in0));
      ack[CI_MSTR_SET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end
   
   initial forever begin
      @(posedge req[CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      data_out0 = ci_master.get_idle_state_output_configuration();
      ack[CI_MSTR_GET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end

   initial forever begin
      @(posedge req[CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT]);
      ack[CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT] = 1;
      ci_master.set_clock_enable_timeout(data_in0);
      ack[CI_MSTR_SET_CLOCK_ENABLE_TIMEOUT] <= 0;
   end
   
   // logic blocks to handle event trigger
   always @(ci_master.signal_instruction_start) begin
      events[CI_MSTR_EVENT_INSTRUCTION_START] = 1;
      events[CI_MSTR_EVENT_INSTRUCTION_START] <= 0;
   end

   always @(ci_master.signal_result_received) begin
      events[CI_MSTR_EVENT_RESULT_RECEIVED] = 1;
      events[CI_MSTR_EVENT_RESULT_RECEIVED] <= 0;
   end

   always @(ci_master.signal_unexpected_result_received) begin
      events[CI_MSTR_EVENT_UNEXPECTED_RESULT_RECEIVED] = 1;
      events[CI_MSTR_EVENT_UNEXPECTED_RESULT_RECEIVED] <= 0;
   end

   always @(ci_master.signal_instructions_completed) begin
      events[CI_MSTR_EVENT_INSTRUCTIONS_COMPLETED] = 1;
      events[CI_MSTR_EVENT_INSTRUCTIONS_COMPLETED] <= 0;
   end

   always @(ci_master.signal_max_instruction_queue_size) begin
      events[CI_MSTR_EVENT_MAX_INSTRUCTION_QUEUE_SIZE] = 1;
      events[CI_MSTR_EVENT_MAX_INSTRUCTION_QUEUE_SIZE] <= 0;
   end

   always @(ci_master.signal_min_instruction_queue_size) begin
      events[CI_MSTR_EVENT_MIN_INSTRUCTION_QUEUE_SIZE] = 1;
      events[CI_MSTR_EVENT_MIN_INSTRUCTION_QUEUE_SIZE] <= 0;
   end

   always @(ci_master.signal_max_result_queue_size) begin
      events[CI_MSTR_EVENT_MAX_RESULT_QUEUE_SIZE] = 1;
      events[CI_MSTR_EVENT_MAX_RESULT_QUEUE_SIZE] <= 0;
   end

   always @(ci_master.signal_min_result_queue_size) begin
      events[CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE] = 1;
      events[CI_MSTR_EVENT_MIN_RESULT_QUEUE_SIZE] <= 0;
   end
   
// synthesis translate_on
endmodule 