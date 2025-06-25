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


`define SMALL 2'b00
`define LARGE 2'b01

`timescale 1ns/1ns
module  avalon_st_src_bfm_wrp (
                              clk,
                              rst_n,
                              src_data,
                              src_valid,
                              src_startofpacket,
                              src_endofpacket,
                              src_error,
                              src_empty,                              
                              src_ready
                              );

  parameter ST_SYMBOL_W     = 16;
  parameter ST_NUMSYMBOLS   = 8 ;
  parameter ST_EMPTY_W      = 3 ;
  parameter ST_USE_PACKET   = 1 ;
  parameter ST_USE_EMPTY    = 1 ;
  parameter ST_USE_ERROR    = 1 ;

  input   logic  clk   ;
  input   logic  rst_n ;
  output  logic [(ST_SYMBOL_W * ST_NUMSYMBOLS) - 1 : 0] src_data ;
  output  logic  src_valid;
  output  logic  src_startofpacket;
  output  logic  src_endofpacket;
  output  logic  src_error;
  output  logic  [ST_EMPTY_W -1 : 0] src_empty;
  input   logic  src_ready;

  import hutil_pkg::*;

  altera_avalon_st_source_bfm# 
    (.ST_SYMBOL_W       (ST_SYMBOL_W),  // Data symbol width in bits
     .ST_NUMSYMBOLS     (ST_NUMSYMBOLS),   // Number of symbols per word
     .ST_EMPTY_W        (ST_EMPTY_W),   // Empty width in bits                     
     .ST_MAX_CHANNELS   (0),   // Maximum number of channels  
     .USE_PACKET        (ST_USE_PACKET),   // Use packet pins on interface        
     .USE_EMPTY         (ST_USE_EMPTY),
     .USE_ERROR         (ST_USE_ERROR))    // Use empty pin on interface) 
  
  U_avalon_st_src_bfm (
     .clk                   (clk),                     
     .reset                 (!rst_n),    
     .src_data              (src_data), 
     .src_channel           (src_channel),
     .src_valid             (src_valid),
     .src_startofpacket     (src_startofpacket),
     .src_endofpacket       (src_endofpacket),
     .src_error             (src_error),
     .src_empty             (src_empty),
     .src_ready             (src_ready) );      
    
    
  //Currently this sends only NWRITE and NWRITE_R kind of packets
function int calc_pkt_size (reg[1:0] tt,int payload_size);  
  int packet_size;

  if (payload_size < 8)
    payload_size = 8;
  packet_size = (tt == 2'b00) ? (10 + payload_size) : (12 + payload_size);
  return packet_size;
endfunction
  
task send_packet_avalon_st;
   
  input reg  [1: 0] tt;
  input reg  [3: 0] ftype;
  input reg  [3: 0] ttype;
  input int         payload_size;
  input reg  [15:0] dest_id;
  output int num_clk_cycle_delay;

  reg  [1   : 0  ] prio;
  reg  [3   : 0  ] empty;
  reg        wdptr;
  reg [1:0]  xamsbs;
  
  reg [7:0] payload [16];
  int header_size;  
  bit [79:0] small_header;
  bit [95:0] large_header;
  bit [3:0] wrsize;
  bit [127:0] packet [];
  int packet_size;
  bit startofpkt;
  bit endofpkt;
  int pld_part_first;
  int rem_payload;
  bit [28:0] address;
  int i,j;
 

  begin
    //Fixing priority field to 2'b10
    prio         = 2'b10;
    xamsbs = 01;
   
    //Assume payload size is minimum of 8
    case (payload_size) 
      1 : begin
            wrsize = 'b0011;
            wdptr = 1'b0;
          end
      2:  begin
            wrsize = 'b0110;
            wdptr = 1'b1;
          end
      4:  begin
            wrsize = 'b1000;
            wdptr = 1'b0;
          end
      8 : begin 
            wrsize = 'b1011;
            wdptr = 0;
          end
     16 : begin 
            wrsize = 'b1011;
            wdptr = 1;
          end
     32 : begin 
            wrsize = 'b1100;
            wdptr = 0;
          end
     64 : begin 
            wrsize = 'b1100;
            wdptr = 1;
          end
    128 : begin 
            wrsize = 'b1101;
            wdptr = 1;
          end
    256 : begin 
            wrsize = 'b1111;
            wdptr = 1;
          end
    default :  begin 
                 wrsize = 'b1011;
                 wdptr = 0;
               end
   endcase
    
   address = 29'b1_1110_1010_1101_1011_1110_1110_1111; //'h1EADBEEF

   //Form the Header for the packet
   small_header = {8'b0,prio,tt,ftype,dest_id[7:0],8'b1010_1011,ttype,wrsize,8'b00,address,wdptr,2'b01};
   large_header = {8'b0,prio,tt,ftype,dest_id,16'b1010_1011_1010_1011,ttype,wrsize,8'b00,address,wdptr,2'b01};
   $display("%m %t Small Header is %x",$stime, small_header);
   $display("%m %t Large Header is %x",$stime, large_header);
   if (tt == `SMALL) 
     header_size = 80;
   else
     header_size = 96;
   
   if (header_size == 80) 
     pld_part_first = 6;
   else
     pld_part_first = 4;

   if (payload_size < 8)
     payload_size = 8;
   rem_payload = payload_size - pld_part_first;
   
   packet_size = header_size + (payload_size * 8);
   if (packet_size % 128)
     packet_size = (packet_size / 128) + 1;
   else
     packet_size = (packet_size / 128);
   packet = new[packet_size];
   if (header_size == 80)
     packet[0] = {small_header,48'b0000_0001_0000_0010_0000_0011_0000_0100_0000_0101_0000_0110};
   else 
     packet[0] = {large_header,32'b0000_0001_0000_0010_0000_0011_0000_0100};
   for (i=0;i < rem_payload; i = i + 16) begin
     j = (i/16);
     payload[0] = i;
     payload[1] = (i+1) >= rem_payload ? 'h00 : (i+1);
     payload[2] = (i+2) >= rem_payload ? 'h00 : (i+2);
     payload[3] = (i+3) >= rem_payload ? 'h00 : (i+3);
     payload[4] = (i+4) >= rem_payload ? 'h00 : (i+4);
     payload[5] = (i+5) >= rem_payload ? 'h00 : (i+5);
     payload[6] = (i+6) >= rem_payload ? 'h00 : (i+6);
     payload[7] = (i+7) >= rem_payload ? 'h00 : (i+7);
     payload[8] = (i+8) >= rem_payload ? 'h00 : (i+8);
     payload[9]  = (i+9) >= rem_payload ? 'h00 : (i+9);
     payload[10] = (i+10) >= rem_payload ? 'h00 : (i+10);
     payload[11] = (i+11) >= rem_payload ? 'h00 : (i+11);
     payload[12] = (i+12) >= rem_payload ? 'h00 : (i+12);
     payload[13] = (i+13) >= rem_payload ? 'h00 : (i+13);
     payload[14] = (i+14) >= rem_payload ? 'h00 : (i+14);
     payload[15] = (i+15) >= rem_payload ? 'h00 : (i+15);
     packet[j+1] = {payload[0],payload[1],payload[2],payload[3],payload[4],payload[5],payload[6],payload[7],payload[8],payload[9],payload[10],payload[11],payload[12],payload[13],payload[14],payload[15]};
   end

   empty = 16 - (rem_payload%16);
   //Now send the fully formed packet on the 
   foreach (packet[j]) begin
     if (j == 0) 
       U_avalon_st_src_bfm.set_transaction_sop(1'b1);
     else
       U_avalon_st_src_bfm.set_transaction_sop(1'b0);
     if (j == (packet_size - 1)) begin
       U_avalon_st_src_bfm.set_transaction_eop(1'b1);
       U_avalon_st_src_bfm.set_transaction_empty(empty);
     end 
     else begin
        U_avalon_st_src_bfm.set_transaction_eop(1'b0);
        U_avalon_st_src_bfm.set_transaction_empty(0);
     end
     U_avalon_st_src_bfm.set_transaction_data(packet[j]);
     $display("%m %t Sending PT TX data ... %x",$stime,packet[j]);
     U_avalon_st_src_bfm.push_transaction();
   end
   
   if (payload_size >= 64) begin
     num_clk_cycle_delay = 4;
   end else  begin
     num_clk_cycle_delay = 3;
   end
  end

endtask


endmodule

