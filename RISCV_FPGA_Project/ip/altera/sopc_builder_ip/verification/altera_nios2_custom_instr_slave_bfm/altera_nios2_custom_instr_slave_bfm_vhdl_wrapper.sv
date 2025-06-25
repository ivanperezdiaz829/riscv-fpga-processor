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
   CI_SLV_GET_CI_CLK_EN                         = 32'd0,
   CI_SLV_RETRIEVE_INSTRUCTION                  = 32'd1,
   CI_SLV_INSERT_RESULT                         = 32'd2,
   CI_SLV_GET_INSTRUCTION_DATAA                 = 32'd3,
   CI_SLV_GET_INSTRUCTION_DATAB                 = 32'd4,
   CI_SLV_GET_INSTRUCTION_N                     = 32'd5,
   CI_SLV_GET_INSTRUCTION_A                     = 32'd6,
   CI_SLV_GET_INSTRUCTION_B                     = 32'd7,
   CI_SLV_GET_INSTRUCTION_C                     = 32'd8,
   CI_SLV_GET_INSTRUCTION_READRA                = 32'd9,
   CI_SLV_GET_INSTRUCTION_READRB                = 32'd10,
   CI_SLV_GET_INSTRUCTION_WRITERC               = 32'd11,
   CI_SLV_GET_INSTRUCTION_IDLE                  = 32'd12,
   CI_SLV_SET_RESULT_VALUE                      = 32'd13,
   CI_SLV_SET_RESULT_DELAY                      = 32'd14,
   CI_SLV_SET_RESULT_ERR_INJECT                 = 32'd15,
   CI_SLV_SET_INSTRUCTION_TIMEOUT               = 32'd16,
   CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION   = 32'd17,
   CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION   = 32'd18,
   CI_SLV_SET_CLOCK_ENABLE_TIMEOUT              = 32'd19
} ci_slv_vhdl_api_e;

typedef enum int {
   CI_SLV_EVENT_KNOWN_INSTRUCTION_RECEIVED      = 32'd0,
   CI_SLV_EVENT_UNKNOWN_INSTRUCTION_RECEIVED    = 32'd1,
   CI_SLV_EVENT_INSTRUCTION_INCONSISTENT        = 32'd2,
   CI_SLV_EVENT_RESULT_DRIVEN                   = 32'd3,
   CI_SLV_EVENT_RESULT_DONE                     = 32'd4,
   CI_SLV_EVENT_INSTRUCTION_UNCHANGED           = 32'd5
} ci_slv_vhdl_event_e;

// synthesis translate_on
module altera_nios2_custom_instr_slave_bfm_vhdl_wrapper #(
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
   input                            ci_clk,
   input                            ci_reset,
   input                            ci_clk_en,
   input  [31: 0]                   ci_dataa,
   input  [31: 0]                   ci_datab,
   output [31: 0]                   ci_result,
   input                            ci_start,
   output                           ci_done,
   input  [EXT_WIDTH-1: 0]          ci_n,
   input  [4: 0]                    ci_a,
   input  [4: 0]                    ci_b,
   input  [4: 0]                    ci_c,
   input                            ci_readra,
   input                            ci_readrb,
   input                            ci_writerc,
   
   // VHDL API request interface
   input  bit [CI_SLV_SET_CLOCK_ENABLE_TIMEOUT:0]        req,
   output bit [CI_SLV_SET_CLOCK_ENABLE_TIMEOUT:0]        ack,
   input  int                                            data_in0,
   input  bit [lindex(CI_MAX_BIT_W): 0]                  data_in1,
   output int                                            data_out0,
   output bit [lindex(CI_MAX_BIT_W): 0]                  data_out1,
   output bit [CI_SLV_EVENT_INSTRUCTION_UNCHANGED:0]     events
);
   
   // synthesis translate_off
   import avalon_utilities_pkg::*;
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction
   
   altera_nios2_custom_instr_slave_bfm #(
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
   ) ci_slave (      
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
      @(posedge req[CI_SLV_GET_CI_CLK_EN]);
      ack[CI_SLV_GET_CI_CLK_EN] = 1;
      data_out0 = ci_slave.get_ci_clk_en();
      ack[CI_SLV_GET_CI_CLK_EN] <= 0;
   end
   
   initial forever begin
      @(posedge req[CI_SLV_RETRIEVE_INSTRUCTION]);
      ack[CI_SLV_RETRIEVE_INSTRUCTION] = 1;
      ci_slave.retrieve_instruction(
         data_out1[319:288],
         data_out1[287:256],
         data_out1[255:224],
         data_out1[223:192],
         data_out1[191:160],
         data_out1[159:128],
         data_out1[127:96],
         data_out1[95:64],
         data_out1[63:32],
         data_out1[31:0]
      );
      ack[CI_SLV_RETRIEVE_INSTRUCTION] <= 0;
   end
   
   initial forever begin
      @(posedge req[CI_SLV_INSERT_RESULT]);
      ack[CI_SLV_INSERT_RESULT] = 1;
      ci_slave.insert_result(
         data_in1[95:64],
         data_in1[63:32],
         data_in1[31:0]
      );
      ack[CI_SLV_INSERT_RESULT] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_DATAA]);
      ack[CI_SLV_GET_INSTRUCTION_DATAA] = 1;
      data_out0 = ci_slave.get_instruction_dataa();
      ack[CI_SLV_GET_INSTRUCTION_DATAA] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_DATAB]);
      ack[CI_SLV_GET_INSTRUCTION_DATAB] = 1;
      data_out0 = ci_slave.get_instruction_datab();
      ack[CI_SLV_GET_INSTRUCTION_DATAB] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_N]);
      ack[CI_SLV_GET_INSTRUCTION_N] = 1;
      data_out0 = ci_slave.get_instruction_n();
      ack[CI_SLV_GET_INSTRUCTION_N] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_A]);
      ack[CI_SLV_GET_INSTRUCTION_A] = 1;
      data_out0 = ci_slave.get_instruction_a();
      ack[CI_SLV_GET_INSTRUCTION_A] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_B]);
      ack[CI_SLV_GET_INSTRUCTION_B] = 1;
      data_out0 = ci_slave.get_instruction_b();
      ack[CI_SLV_GET_INSTRUCTION_B] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_C]);
      ack[CI_SLV_GET_INSTRUCTION_C] = 1;
      data_out0 = ci_slave.get_instruction_c();
      ack[CI_SLV_GET_INSTRUCTION_C] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_READRA]);
      ack[CI_SLV_GET_INSTRUCTION_READRA] = 1;
      data_out0 = ci_slave.get_instruction_readra();
      ack[CI_SLV_GET_INSTRUCTION_READRA] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_READRB]);
      ack[CI_SLV_GET_INSTRUCTION_READRB] = 1;
      data_out0 = ci_slave.get_instruction_readrb();
      ack[CI_SLV_GET_INSTRUCTION_READRB] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_WRITERC]);
      ack[CI_SLV_GET_INSTRUCTION_WRITERC] = 1;
      data_out0 = ci_slave.get_instruction_writerc();
      ack[CI_SLV_GET_INSTRUCTION_WRITERC] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_GET_INSTRUCTION_IDLE]);
      ack[CI_SLV_GET_INSTRUCTION_IDLE] = 1;
      data_out0 = ci_slave.get_instruction_idle();
      ack[CI_SLV_GET_INSTRUCTION_IDLE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_SET_RESULT_VALUE]);
      ack[CI_SLV_SET_RESULT_VALUE] = 1;
      ci_slave.set_result_value(data_in0);
      ack[CI_SLV_SET_RESULT_VALUE] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_SET_RESULT_DELAY]);
      ack[CI_SLV_SET_RESULT_DELAY] = 1;
      ci_slave.set_result_delay(data_in0);
      ack[CI_SLV_SET_RESULT_DELAY] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_SET_RESULT_ERR_INJECT]);
      ack[CI_SLV_SET_RESULT_ERR_INJECT] = 1;
      ci_slave.set_result_err_inject(data_in0);
      ack[CI_SLV_SET_RESULT_ERR_INJECT] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_SET_INSTRUCTION_TIMEOUT]);
      ack[CI_SLV_SET_INSTRUCTION_TIMEOUT] = 1;
      ci_slave.set_instruction_timeout(data_in0);
      ack[CI_SLV_SET_INSTRUCTION_TIMEOUT] <= 0;
   end
   
   initial forever begin
      @(posedge req[CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      ci_slave.set_idle_state_output_configuration(IdleOutputValue_t'(data_in0));
      ack[CI_SLV_SET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end
   
   initial forever begin
      @(posedge req[CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION]);
      ack[CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION] = 1;
      data_out0 = ci_slave.get_idle_state_output_configuration();
      ack[CI_SLV_GET_IDLE_STATE_OUTPUT_CONFIGURATION] <= 0;
   end

   initial forever begin
      @(posedge req[CI_SLV_SET_CLOCK_ENABLE_TIMEOUT]);
      ack[CI_SLV_SET_CLOCK_ENABLE_TIMEOUT] = 1;
      ci_slave.set_clock_enable_timeout(data_in0);
      ack[CI_SLV_SET_CLOCK_ENABLE_TIMEOUT] <= 0;
   end

   // logic blocks to handle event trigger
   always @(ci_slave.signal_known_instruction_received) begin
      events[CI_SLV_EVENT_KNOWN_INSTRUCTION_RECEIVED] = 1;
      events[CI_SLV_EVENT_KNOWN_INSTRUCTION_RECEIVED] <= 0;
   end

   always @(ci_slave.signal_unknown_instruction_received) begin
      events[CI_SLV_EVENT_UNKNOWN_INSTRUCTION_RECEIVED] = 1;
      events[CI_SLV_EVENT_UNKNOWN_INSTRUCTION_RECEIVED] <= 0;
   end

   always @(ci_slave.signal_instruction_inconsistent) begin
      events[CI_SLV_EVENT_INSTRUCTION_INCONSISTENT] = 1;
      events[CI_SLV_EVENT_INSTRUCTION_INCONSISTENT] <= 0;
   end

   always @(ci_slave.signal_result_driven) begin
      events[CI_SLV_EVENT_RESULT_DRIVEN] = 1;
      events[CI_SLV_EVENT_RESULT_DRIVEN] <= 0;
   end

   always @(ci_slave.signal_result_done) begin
      events[CI_SLV_EVENT_RESULT_DONE] = 1;
      events[CI_SLV_EVENT_RESULT_DONE] <= 0;
   end

   always @(ci_slave.signal_instruction_unchanged) begin
      events[CI_SLV_EVENT_INSTRUCTION_UNCHANGED] = 1;
      events[CI_SLV_EVENT_INSTRUCTION_UNCHANGED] <= 0;
   end

// synthesis translate_on
endmodule 