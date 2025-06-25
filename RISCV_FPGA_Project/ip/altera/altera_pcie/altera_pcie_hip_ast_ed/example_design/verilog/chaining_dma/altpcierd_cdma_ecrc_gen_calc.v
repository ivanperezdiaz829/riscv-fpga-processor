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


// /**
//  * This Verilog HDL file is used for simulation and synthesis in
//  * the chaining DMA design example. It could be used by the software
//  * application (Root Port) to retrieve the DMA Performance counter values
//  * and performs single DWORD read and write to the Endpoint memory by
//  * bypassing the DMA engines.
//  */
// synthesis translate_off

`timescale 1ns / 1ps
// synthesis translate_on
// synthesis verilog_input_version verilog_2001
// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030
//

module altpcierd_cdma_ecrc_gen_calc #( parameter AVALON_ST_128 = 0) (clk, rstn,  crc_data, crc_valid, crc_empty, crc_eop, crc_sop,
                ecrc,   crc_ack);

   input        clk;
   input        rstn;
   input[127:0]  crc_data;
   input        crc_valid;
   input[3:0]   crc_empty;
   input        crc_eop;
   input        crc_sop;
   output[31:0] ecrc;
   input        crc_ack;

   wire[31:0]   crc_int;
   wire         crc_valid_int;
   wire         open_empty;
   wire         open_full;


   generate  begin
      if (AVALON_ST_128==1)  begin
         altpcierd_tx_ecrc_128 tx_ecrc_128 (
               .clk(clk), .reset_n(rstn), .data(crc_data), .datavalid(crc_valid),
               .empty(crc_empty), .endofpacket(crc_eop), .startofpacket(crc_sop),
               .checksum(crc_int), .crcvalid(crc_valid_int)
         );
       end
    end
   endgenerate

   generate  begin
      if (AVALON_ST_128==0)  begin
         altpcierd_tx_ecrc_64 tx_ecrc_64 (
               .clk(clk), .reset_n(rstn), .data(crc_data[127:64]), .datavalid(crc_valid),
               .empty(crc_empty[2:0]), .endofpacket(crc_eop), .startofpacket(crc_sop),
               .checksum(crc_int), .crcvalid(crc_valid_int)
         );
       end
    end
   endgenerate

   altpcierd_tx_ecrc_fifo tx_ecrc_fifo (
    .aclr   (~rstn),
    .clock  (clk),
    .data   (crc_int),
    .rdreq  (crc_ack),
    .wrreq  (crc_valid_int),
    .empty  (open_empty),
    .full   (open_full),
    .q      (ecrc)
   );

endmodule

