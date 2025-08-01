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


// $Id: //acds/rel/13.1/ip/sld/mm/altera_connection_identification_rom_wrapper/altera_connection_identification_rom_wrapper.v#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
`default_nettype none
`timescale 1 ns / 1 ns
module altera_connection_identification_rom_wrapper (
    input wire clk,
    input wire reset,
    input wire [1 : 0] address,
    input wire write,
    input wire read,
    input wire [31: 0] writedata,
    output reg [31:0] readdata
  );

  parameter LATENCY = 3;

  reg [1:0] d1_address;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      d1_address <= 2'b0;
    end
    else begin
      d1_address <= address;
    end
  end

  wire [31:0] p1_readdata;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      readdata <= 32'b0;
    end
    else begin
      readdata <= p1_readdata;
    end
  end

//
// synthesis read_comments_as_HDL on
//  altera_connection_identification_rom #(.WIDTH (32), .LATENCY (LATENCY - 2)) 
//  the_rom (
//    .clk (clk),
//    .address (d1_address),
//    .readdata (p1_readdata),
//    .writedata (writedata[3:0])
//  );
// synthesis read_comments_as_HDL off

// synthesis translate_off
  wire [31:0] memdata = 
   ({32 {(d1_address == 2'h0)}} & 32'h01234567) |
   ({32 {(d1_address == 2'h1)}} & 32'hABCDEF10) |
   ({32 {(d1_address == 2'h2)}} & 32'h20304050) |
   ({32 {(d1_address == 2'h3)}} & 32'h60708090);
  reg [31:0] d1_memdata;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      d1_memdata <= 32'b0;
    end
    else begin
      d1_memdata <= memdata;
    end
  end

  generate begin
    if (LATENCY == 2)
      assign p1_readdata = memdata;
    else
      assign p1_readdata = d1_memdata;
  end endgenerate
// synthesis translate_on

endmodule

`default_nettype wire
