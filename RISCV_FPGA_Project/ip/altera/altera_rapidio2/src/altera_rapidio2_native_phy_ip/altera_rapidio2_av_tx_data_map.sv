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


//---------------------------------------------------------------------
// Module: TX data mapping for Arria V Native PHY IP
// Feature:
// To map RapidIO II TX data and TX datak to Transceiver Native PHY's tx_parallel_data
//---------------------------------------------------------------------
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module altera_rapidio2_av_tx_data_map
#(
   parameter logic SUPPORT_2X = 1'd1,
   parameter logic SUPPORT_4X = 1'd1,
   parameter       LSIZE      = ( SUPPORT_4X ) ? 4 : (( SUPPORT_2X )? 2 : 1 )
)
(
   input logic [3:0]  tx_datak0,
   input logic [31:0] tx_parallel_data0,
   input logic [3:0]  tx_datak1,
   input logic [31:0] tx_parallel_data1,
   input logic [3:0]  tx_datak2,
   input logic [31:0] tx_parallel_data2,
   input logic [3:0]  tx_datak3,
   input logic [31:0] tx_parallel_data3,
   output logic [(LSIZE*44)-1:0] tx_parallel_data_native_phy // data ordering: {lane 3, lane 2, lane 1, lane 0}
);

  //---------------------------------------------------------------------
  // Byte re-ordering for each lanes
  //---------------------------------------------------------------------
   logic [3:0] tx_datak0_tmp;
   logic [3:0] tx_datak1_tmp;
   logic [3:0] tx_datak2_tmp;
   logic [3:0] tx_datak3_tmp;
   logic [31:0]tx_parallel_data0_tmp;
   logic [31:0]tx_parallel_data1_tmp;
   logic [31:0]tx_parallel_data2_tmp;
   logic [31:0]tx_parallel_data3_tmp;

   assign tx_datak0_tmp = {tx_datak0[0],tx_datak0[1],tx_datak0[2],tx_datak0[3]};
   assign tx_datak1_tmp = {tx_datak1[0],tx_datak1[1],tx_datak1[2],tx_datak1[3]};
   assign tx_datak2_tmp = {tx_datak2[0],tx_datak2[1],tx_datak2[2],tx_datak2[3]};
   assign tx_datak3_tmp = {tx_datak3[0],tx_datak3[1],tx_datak3[2],tx_datak3[3]};

   assign tx_parallel_data0_tmp = {tx_parallel_data0[7:0],tx_parallel_data0[15:8],
                                   tx_parallel_data0[23:16],tx_parallel_data0[31:24]};
   assign tx_parallel_data1_tmp = {tx_parallel_data1[7:0],tx_parallel_data1[15:8],
                                   tx_parallel_data1[23:16],tx_parallel_data1[31:24]};
   assign tx_parallel_data2_tmp = {tx_parallel_data2[7:0],tx_parallel_data2[15:8],
                                   tx_parallel_data2[23:16],tx_parallel_data2[31:24]};
   assign tx_parallel_data3_tmp = {tx_parallel_data3[7:0],tx_parallel_data3[15:8],
                                   tx_parallel_data3[23:16],tx_parallel_data3[31:24]};
  //---------------------------------------------------------------------
  // Four lanes
  //---------------------------------------------------------------------
   logic [127:0] tx_parallel_data_tmp;
   logic [15:0] tx_datak_tmp;

   assign tx_parallel_data_tmp = {tx_parallel_data3_tmp, tx_parallel_data2_tmp, tx_parallel_data1_tmp, tx_parallel_data0_tmp};
   assign tx_datak_tmp         = {tx_datak3_tmp, tx_datak2_tmp, tx_datak1_tmp, tx_datak0_tmp};

  //---------------------------------------------------------------------
  // Data mapping
  //---------------------------------------------------------------------
  // Arria V Native PHY IP
  // In each 11-bit TX data: Bit[7:0] TX data bus
  //                         Bit[8]   TX data control character
  //                         Bit[9]   Force disparity
  //                         Bit[10]  Disparity field (0=positive, 1=negative)
  //---------------------------------------------------------------------
genvar i;
genvar j;
generate
   for (i=0; i<LSIZE; i=i+1) begin :rawdata//44*lanes TX raw data
      for (j=0; j<4; j=j+1)  begin :perlane//Four characters per lane.464-bit raw data per lane.
         //Mapping of TX data control character and TX data bus
         assign tx_parallel_data_native_phy[(44*i)+(11*j)+10:(44*i)+(11*j)] = 
            ({2'b00, //set force disparity and disparity field to zero.
              tx_datak_tmp         [j+(4*i)],                      //tx data control character for four lanes.
              tx_parallel_data_tmp [7+(8*j)+(32*i):0+(8*j)+(32*i)] //32-bit per lane tx data for four lanes.
             });
      end
   end
endgenerate


endmodule
