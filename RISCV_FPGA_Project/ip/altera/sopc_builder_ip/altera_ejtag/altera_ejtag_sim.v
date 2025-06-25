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


//Legal Notice: (C)2008 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module altera_ejtag (
  input  wire clk,
  input  wire reset_n,
  input  wire ejtag_probe_reset_n,

  // jtag signals
  input  wire             jtag_tck,
  input  wire             jtag_tms,
  input  wire             jtag_tdi,
  output wire             jtag_tdo,

  // CPU signals
  output wire             debug_intr,
  output wire             debug_probe_trap,
  output wire             debug_dcr_int_e,
  output wire             debug_boot,
  input  wire             debug_mode,
  input  wire  [29:0]     debug_dpc,
  input  wire             debug_een,
  input  wire             debug_evalid,
  output wire             debug_hwbp,


  // SOPC Avalon Slave
  input  wire             s1_read,
  input  wire             s1_write,
  input  wire   [18:0]    s1_address, // word address
  input  wire   [31:0]    s1_writedata,
  input  wire   [3:0]     s1_byteenable,
  output wire   [31:0]    s1_readdata,
  output wire             s1_resetrequest,
  output wire             s1_waitrequest
);

  parameter   USE_VJI = 0;      // if set to 1 then the Virtual JTAG Interface 
                                // is used and the dedicated JTAG I/O's removed.
  parameter   big_endian = 0;

  assign jtag_tdo           = 1'b0;
  assign debug_intr         = 1'b0;
  assign debug_probe_trap   = 1'b0;
  assign debug_dcr_int_e    = 1'b0;
  assign debug_boot         = 1'b0;
  assign s1_readdata        = 32'b0;
  assign s1_resetrequest    = 1'b0;
  assign s1_waitrequest     = 1'b1;
endmodule
