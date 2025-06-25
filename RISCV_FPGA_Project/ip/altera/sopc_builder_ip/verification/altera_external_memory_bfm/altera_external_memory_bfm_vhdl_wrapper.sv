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
   EXT_MEM_WRITE                                = 32'd0,
   EXT_MEM_READ                                 = 32'd1,
   EXT_MEM_FILL                                 = 32'd2
} ext_mem_vhdl_api_e;

typedef enum int {
   EXT_MEM_EVENT_API_CALL                       = 32'd0
} ext_mem_vhdl_event_e;

module altera_external_memory_bfm_vhdl_wrapper #(
   parameter CDT_ADDRESS_W             = 8,
             CDT_NUMSYMBOLS            = 4,
             CDT_SYMBOL_W              = 8,
             CDT_READ_LATENCY          = 0,
             INIT_FILE                 = "altera_external_memory_bfm.hex",
             USE_CHIPSELECT            = 1,
             USE_READ                  = 1,
             USE_WRITE                 = 1,
             USE_OUTPUTENABLE          = 1,
             USE_BEGINTRANSFER         = 1,
             ACTIVE_LOW_CHIPSELECT     = 0,
             ACTIVE_LOW_READ           = 0,
             ACTIVE_LOW_WRITE          = 0,
             ACTIVE_LOW_BYTEENABLE     = 0,
             ACTIVE_LOW_OUTPUTENABLE   = 0,
             ACTIVE_LOW_BEGINTRANSFER  = 0,
             ACTIVE_LOW_RESET          = 0,
             EXT_MAX_BIT_W             = 1024,
             DATA_W                    = CDT_SYMBOL_W * CDT_NUMSYMBOLS
)(
   input                        clk,
   input  [CDT_ADDRESS_W-1:0]   cdt_address,
   inout  [DATA_W-1:0]          cdt_data_io,
   input                        cdt_write,
   input  [CDT_NUMSYMBOLS-1:0]  cdt_byteenable,
   input                        cdt_chipselect,
   input                        cdt_read,
   input                        cdt_outputenable,
   input                        cdt_begintransfer,
   input                        cdt_reset,
   
   //  VHDL API request interface
   input  bit [EXT_MEM_FILL:0]                        req,
   output bit [EXT_MEM_FILL:0]                        ack,
   input  int                                         data_in0,   
   input  bit [lindex(EXT_MAX_BIT_W): 0]              data_in1,
   input  bit [lindex(EXT_MAX_BIT_W): 0]              data_in2,
   input  bit [lindex(EXT_MAX_BIT_W): 0]              data_in3,
   output int                                         data_out0,
   output bit [lindex(EXT_MAX_BIT_W): 0]              data_out1,
   output bit [lindex(EXT_MAX_BIT_W): 0]              data_out2,
   output bit [lindex(EXT_MAX_BIT_W): 0]              data_out3,
   output bit [EXT_MEM_EVENT_API_CALL: 0]             events
);

   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction
   
   
   altera_external_memory_bfm #(
      .CDT_ADDRESS_W(CDT_ADDRESS_W),
      .CDT_NUMSYMBOLS(CDT_NUMSYMBOLS),
      .CDT_SYMBOL_W(CDT_SYMBOL_W),
      .CDT_READ_LATENCY(CDT_READ_LATENCY),
      .INIT_FILE(INIT_FILE),
      .USE_CHIPSELECT(USE_CHIPSELECT),
      .USE_READ(USE_READ),
      .USE_WRITE(USE_WRITE),
      .USE_OUTPUTENABLE(USE_OUTPUTENABLE),
      .USE_BEGINTRANSFER(USE_BEGINTRANSFER),
      .ACTIVE_LOW_CHIPSELECT(ACTIVE_LOW_CHIPSELECT),
      .ACTIVE_LOW_READ(ACTIVE_LOW_READ),
      .ACTIVE_LOW_WRITE(ACTIVE_LOW_WRITE),
      .ACTIVE_LOW_BYTEENABLE(ACTIVE_LOW_BYTEENABLE),
      .ACTIVE_LOW_OUTPUTENABLE(ACTIVE_LOW_OUTPUTENABLE ),
      .ACTIVE_LOW_BEGINTRANSFER(ACTIVE_LOW_BEGINTRANSFER),
      .ACTIVE_LOW_RESET(ACTIVE_LOW_RESET)
 ) ext_memory (
      .clk(clk),
      .cdt_address(cdt_address),
      .cdt_data_io(cdt_data_io),
      .cdt_write(cdt_write),
      .cdt_byteenable(cdt_byteenable),
      .cdt_chipselect(cdt_chipselect),
      .cdt_read(cdt_read),
      .cdt_outputenable(cdt_outputenable),
      .cdt_begintransfer(cdt_begintransfer),
      .cdt_reset(cdt_reset)
);

   // logic block to handle API calls from VHDL request interface
   initial forever begin
      @(posedge req[EXT_MEM_WRITE]);
      ack[EXT_MEM_WRITE] = 1;
      ext_memory.write(data_in1, data_in3);
      ack[EXT_MEM_WRITE] <= 0;
   end

   initial forever begin
      @(posedge req[EXT_MEM_READ]);
      ack[EXT_MEM_READ] = 1;
      data_out3 = ext_memory.read(data_in1);
      ack[EXT_MEM_READ] <= 0;
   end

   initial forever begin
      @(posedge req[EXT_MEM_FILL]);
      ack[EXT_MEM_FILL] = 1;
      ext_memory.fill(data_in3, data_in0, data_in1, data_in2);
      ack[EXT_MEM_FILL] <= 0;
   end
   
   // logic blocks to handle event trigger
   always @(ext_memory.signal_api_call) begin
      events[EXT_MEM_EVENT_API_CALL] = 1;
      events[EXT_MEM_EVENT_API_CALL] <= 0;
   end
   
endmodule 