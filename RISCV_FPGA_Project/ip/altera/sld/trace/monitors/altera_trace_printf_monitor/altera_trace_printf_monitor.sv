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


// $Id: //acds/rel/13.1/ip/sld/trace/monitors/altera_trace_printf_monitor/altera_trace_printf_monitor.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
`default_nettype none
`timescale 1 ns / 1 ns
module altera_trace_printf_monitor #(
    parameter CAPTURE_DATAWIDTH = 128,
              DATA_ADDRESS_WIDTH = 5,
              FULL_TS_LENGTH    =  40
  ) (

  // capture
  output reg [CAPTURE_DATAWIDTH - 1 : 0] capture_data,
  output reg capture_valid,
  input wire capture_ready,
  output reg capture_startofpacket,
  output reg capture_endofpacket,

  // control
  input wire control_address,
  input wire control_read,
  input wire [(CAPTURE_DATAWIDTH / 8) - 1 : 0] control_byteenable,
  output wire [CAPTURE_DATAWIDTH - 1 : 0] control_readdata,
  
  // data
  input wire [CAPTURE_DATAWIDTH - 1 : 0] data_writedata,
  input wire [(CAPTURE_DATAWIDTH / 8) - 1 : 0] data_byteenable,
  input wire data_write,
  input wire [DATA_ADDRESS_WIDTH - 1 : 0] data_address,

  // clock
  input wire clk,

  // reset
  input wire reset
);

  localparam 
            SHORT_TS_LENGTH   = 0,
            VERSION = 4'h0,
            TYPE_NAME = 16'h0107,
            ALTERA = 11'h6E;

  localparam
    USER1_BASE     = 0,
    USER1_W        = 32,
    USER0_BASE     = 32,
    USER0_W        = 32,
    ID_BASE        = 64,
    ID_W           = 16,
    TIMESTAMP_BASE = 80,
    TIMESTAMP_W    = FULL_TS_LENGTH,
    TYPE_BASE      = 126,
    TYPE_W         = 2,
    TPOI_FIELD     = 123,
    CORR_FIELD     = 121,
    DROP_FIELD     = 120 
  ;

  int i;
  reg d1_data_write;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      d1_data_write <= 0;
    end
    else begin
      d1_data_write <= ~d1_data_write & data_write;
      // could do address decoding here.
    end
  end

  // capture valid, startofpacket, endofpacket:
  //   assert when either alias of the ID register is written.
  reg id_register_write;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      id_register_write <= '0;
    end
    else begin
      id_register_write <= |data_byteenable[3:0];
    end
  end

  wire p1_capture_valid = ~capture_valid & d1_data_write & id_register_write;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      capture_valid <= '0;
      capture_startofpacket <= '0;
      capture_endofpacket <= '0;
    end
    else begin
      capture_startofpacket <= p1_capture_valid;
      capture_endofpacket   <= p1_capture_valid;
      capture_valid         <= p1_capture_valid;
    end
  end

  reg drop_flag;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      drop_flag <= '0;
    end
    else begin
      // If a beat is attempted on the capture interface, but
      // ready is not asserted, set a flag to remember that the DROP
      // header bit must be set in a future beat.  Only clear that flag
      // when a beat has successfully been sent (ready is asserted).
      if (capture_valid)
        drop_flag = ~capture_ready;
    end
  end

  reg tpoi;
  reg [31:0] user1, user0;
  reg[15:0] printf_id;
  reg write_user1, write_user0, write_id;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      tpoi <= '0;
    end
    else begin
       if (d1_data_write)
         tpoi <= data_address[DATA_ADDRESS_WIDTH - 1];
    end
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      write_user1 <= '0;
      write_user0 <= '0;
      write_id <= '0;
    end
    else begin
      write_user1 <= ~write_user1 & data_write & |data_byteenable[11:8];
      write_user0 <= ~write_user0 & data_write & |data_byteenable[7:4];
      write_id <= ~write_id & data_write & |data_byteenable[1:0];
    end
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      user1 <= '0;
      user0 <= '0;
      printf_id <= '0;
    end
    else begin
      if (write_user1) begin
        for (i = 0; i < 4; i++) begin
          if (data_byteenable[i + 8])
            user1[i * 8 +: 8] <= data_writedata[i * 8 + 64 +: 8];
        end
      end
      if (write_user0) begin
        for (i = 0; i < 4; i++) begin
          if (data_byteenable[i + 4])
            user0[i * 8 +: 8] <= data_writedata[i * 8 + 32 +: 8];
        end
      end
      if (write_id) begin
        for (i = 0; i < 2; i++) begin
          if (data_byteenable[i])
            printf_id[i * 8 +: 8] <= data_writedata[i * 8 +: 8];
        end
      end
    end
  end

  reg [FULL_TS_LENGTH - 1 : 0] timestamp;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      timestamp <= '0;
    end
    else begin
      timestamp <= timestamp + 1'b1;
    end
  end

  always @* begin
    capture_data = '0;
    capture_data[TPOI_FIELD] = tpoi;
    capture_data[USER1_BASE +: USER1_W] = user1;
    capture_data[USER0_BASE +: USER0_W] = user0;
    capture_data[ID_BASE +: ID_W] = printf_id;
    capture_data[TIMESTAMP_BASE +: TIMESTAMP_W] = timestamp;
    capture_data[TYPE_BASE +: TYPE_W] = 2'b10; // full timestamp
    capture_data[CORR_FIELD] = '0;
    capture_data[DROP_FIELD] = drop_flag;
  end

  // control value
  assign control_readdata = {
    16'b0,            // reserved
    SHORT_TS_LENGTH,
    FULL_TS_LENGTH,
    VERSION,
    TYPE_NAME,
    1'b0,             // reserved
    ALTERA
  };

endmodule

`default_nettype wire

