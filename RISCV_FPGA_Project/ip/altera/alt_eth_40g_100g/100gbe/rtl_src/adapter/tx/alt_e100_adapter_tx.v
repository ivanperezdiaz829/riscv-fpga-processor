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



// lanny - 12-05-2011 Adapter seperation

`timescale 1ps / 1ps

module alt_e100_adapter_tx #(
    parameter DEVICE_FAMILY = "Stratix V"
)(
    input  mac_tx_arst_sync_core,
    input  clk_txmac,    // MAC + PCS clock - at least 312.5Mhz

    input  [511:0] l8_tx_data,
    input  [5  :0] l8_tx_empty,
    input  l8_tx_startofpacket,
    input  l8_tx_endofpacket,
    output l8_tx_ready,
    input  l8_tx_valid,
    
    output [5*64-1:0] tx5l_d,        // 5 lane payload to send
    output [5   -1:0] tx5l_sop,      // 5 lane start position
    output [5*8 -1:0] tx5l_eop_bm,   // 5 lane end position, any byte
    input  tx5l_ack                 // payload is accepted
     
    
    );

function [511:0] alt_e100_wide_little_endian2avalon_512;
input [511:0] a;

begin
    alt_e100_wide_little_endian2avalon_512 
                         = {a[  7: 0],  a[ 15:  8], a[ 23: 16], a[ 31: 24],
                            a[ 39: 32], a[ 47: 40], a[ 55: 48], a[ 63: 56],
                            a[ 71: 64], a[ 79: 72], a[ 87: 80], a[ 95: 88],
                            a[103: 96], a[111:104], a[119:112], a[127:120],
                            a[135:128], a[143:136], a[151:144], a[159:152],
                            a[167:160], a[175:168], a[183:176], a[191:184],
                            a[199:192], a[207:200], a[215:208], a[223:216],
                            a[231:224], a[239:232], a[247:240], a[255:248],
                            a[263:256], a[271:264], a[279:272], a[287:280],
                            a[295:288], a[303:296], a[311:304], a[319:312],
                            a[327:320], a[335:328], a[343:336], a[351:344],
                            a[359:352], a[367:360], a[375:368], a[383:376],
                            a[391:384], a[399:392], a[407:400], a[415:408],
                            a[423:416], a[431:424], a[439:432], a[447:440],
                            a[455:448], a[463:456], a[471:464], a[479:472],
                            a[487:480], a[495:488], a[503:496], a[511:504]};
end
endfunction

// local ---------------------------------------------------------------------
wire          [5:0] l8_tx_eop_pos;

wire     [8*64-1:0] tx8l_d;        // 8 lane payload data
wire                tx8l_sop;
wire                tx8l_eop;
wire          [5:0] tx8l_eop_pos;  // end of packet position <= 63-avalon_empty
wire                tx8l_rdempty;
wire                tx8l_rdreq;

// little/big endian conversion
wire [511:0] l8_tx_data_local;
//assign l8_tx_data_local = alt_e100_wide_little_endian2avalon_512(l8_tx_data);
assign l8_tx_data_local = l8_tx_data;

// WAS tx fifo -------------------------------------------------------------------
//assign l8_tx_eop_pos = 63 - l8_tx_empty;
assign l8_tx_eop_pos = l8_tx_empty;

assign tx8l_sop      = l8_tx_startofpacket;
assign tx8l_eop      = l8_tx_endofpacket;
assign tx8l_eop_pos  = l8_tx_eop_pos;
assign tx8l_d        = l8_tx_data_local;

assign l8_tx_ready   = tx8l_rdreq;
assign tx8l_rdempty  = ~l8_tx_valid;

// 8 lanes to 5 lans conversion ----------------------------------------------
alt_e100_wide_l8if_tx825 alt_e100_wide_l8if_tx825(
    .arst               (mac_tx_arst_sync_core), // i
    .clk_txmac          (clk_txmac),          // i
    .tx8l_d             (tx8l_d),             // i
    .tx8l_sop           (tx8l_sop),           // i
    .tx8l_eop           (tx8l_eop),           // i
    .tx8l_eop_pos       (tx8l_eop_pos),       // i
    .tx8l_rdempty       (tx8l_rdempty),       // i
    .tx8l_rdreq         (tx8l_rdreq),         // o
    .tx5l_d             (tx5l_d),             // o
    .tx5l_sop           (tx5l_sop),           // o
    .tx5l_eop_bm        (tx5l_eop_bm),        // o
    .tx5l_ack           (tx5l_ack)            // i
); // module l8if_825

endmodule

