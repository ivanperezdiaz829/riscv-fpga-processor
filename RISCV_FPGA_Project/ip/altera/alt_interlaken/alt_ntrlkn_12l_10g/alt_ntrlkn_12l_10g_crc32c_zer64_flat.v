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


`timescale 1 ps / 1 ps

module alt_ntrlkn_12l_10g_crc32c_zer64_flat (c,crc_out);
input[31:0] c;
output[31:0] crc_out;
wire[31:0] crc_out;

assign crc_out[0] =
    c[3] ^ c[4] ^ c[5] ^ c[10] ^ c[11] ^ c[13] ^
    c[14] ^ c[15] ^ c[16] ^ c[19] ^ c[21] ^ c[22] ^ c[27] ^
    c[30];

assign crc_out[1] =
    c[0] ^ c[4] ^ c[5] ^ c[6] ^ c[11] ^ c[12] ^
    c[14] ^ c[15] ^ c[16] ^ c[17] ^ c[20] ^ c[22] ^ c[23] ^
    c[28] ^ c[31];

assign crc_out[2] =
    c[0] ^ c[1] ^ c[5] ^ c[6] ^ c[7] ^ c[12] ^
    c[13] ^ c[15] ^ c[16] ^ c[17] ^ c[18] ^ c[21] ^ c[23] ^
    c[24] ^ c[29];

assign crc_out[3] =
    c[1] ^ c[2] ^ c[6] ^ c[7] ^ c[8] ^ c[13] ^
    c[14] ^ c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[22] ^ c[24] ^
    c[25] ^ c[30];

assign crc_out[4] =
    c[0] ^ c[2] ^ c[3] ^ c[7] ^ c[8] ^ c[9] ^
    c[14] ^ c[15] ^ c[17] ^ c[18] ^ c[19] ^ c[20] ^ c[23] ^
    c[25] ^ c[26] ^ c[31];

assign crc_out[5] =
    c[0] ^ c[1] ^ c[3] ^ c[4] ^ c[8] ^ c[9] ^
    c[10] ^ c[15] ^ c[16] ^ c[18] ^ c[19] ^ c[20] ^ c[21] ^
    c[24] ^ c[26] ^ c[27];

assign crc_out[6] =
    c[0] ^ c[1] ^ c[2] ^ c[3] ^ c[9] ^ c[13] ^
    c[14] ^ c[15] ^ c[17] ^ c[20] ^ c[25] ^ c[28] ^ c[30];

assign crc_out[7] =
    c[1] ^ c[2] ^ c[3] ^ c[4] ^ c[10] ^ c[14] ^
    c[15] ^ c[16] ^ c[18] ^ c[21] ^ c[26] ^ c[29] ^ c[31];

assign crc_out[8] =
    c[0] ^ c[2] ^ c[10] ^ c[13] ^ c[14] ^ c[17] ^
    c[21];

assign crc_out[9] =
    c[1] ^ c[4] ^ c[5] ^ c[10] ^ c[13] ^ c[16] ^
    c[18] ^ c[19] ^ c[21] ^ c[27] ^ c[30];

assign crc_out[10] =
    c[0] ^ c[2] ^ c[3] ^ c[4] ^ c[6] ^ c[10] ^
    c[13] ^ c[15] ^ c[16] ^ c[17] ^ c[20] ^ c[21] ^ c[27] ^
    c[28] ^ c[30] ^ c[31];

assign crc_out[11] =
    c[1] ^ c[7] ^ c[10] ^ c[13] ^ c[15] ^ c[17] ^
    c[18] ^ c[19] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];

assign crc_out[12] =
    c[2] ^ c[8] ^ c[11] ^ c[14] ^ c[16] ^ c[18] ^
    c[19] ^ c[20] ^ c[28] ^ c[29] ^ c[30] ^ c[31];

assign crc_out[13] =
    c[4] ^ c[5] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^
    c[13] ^ c[14] ^ c[16] ^ c[17] ^ c[20] ^ c[22] ^ c[27] ^
    c[29] ^ c[31];

assign crc_out[14] =
    c[0] ^ c[3] ^ c[4] ^ c[6] ^ c[12] ^ c[16] ^
    c[17] ^ c[18] ^ c[19] ^ c[22] ^ c[23] ^ c[27] ^ c[28];

assign crc_out[15] =
    c[1] ^ c[4] ^ c[5] ^ c[7] ^ c[13] ^ c[17] ^
    c[18] ^ c[19] ^ c[20] ^ c[23] ^ c[24] ^ c[28] ^ c[29];

assign crc_out[16] =
    c[0] ^ c[2] ^ c[5] ^ c[6] ^ c[8] ^ c[14] ^
    c[18] ^ c[19] ^ c[20] ^ c[21] ^ c[24] ^ c[25] ^ c[29] ^
    c[30];

assign crc_out[17] =
    c[0] ^ c[1] ^ c[3] ^ c[6] ^ c[7] ^ c[9] ^
    c[15] ^ c[19] ^ c[20] ^ c[21] ^ c[22] ^ c[25] ^ c[26] ^
    c[30] ^ c[31];

assign crc_out[18] =
    c[1] ^ c[2] ^ c[3] ^ c[5] ^ c[7] ^ c[8] ^
    c[11] ^ c[13] ^ c[14] ^ c[15] ^ c[19] ^ c[20] ^ c[23] ^
    c[26] ^ c[30] ^ c[31];

assign crc_out[19] =
    c[0] ^ c[2] ^ c[5] ^ c[6] ^ c[8] ^ c[9] ^
    c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[19] ^ c[20] ^ c[22] ^
    c[24] ^ c[30] ^ c[31];

assign crc_out[20] =
    c[1] ^ c[4] ^ c[5] ^ c[6] ^ c[7] ^ c[9] ^
    c[12] ^ c[15] ^ c[16] ^ c[19] ^ c[20] ^ c[22] ^ c[23] ^
    c[25] ^ c[27] ^ c[30] ^ c[31];

assign crc_out[21] =
    c[0] ^ c[2] ^ c[5] ^ c[6] ^ c[7] ^ c[8] ^
    c[10] ^ c[13] ^ c[16] ^ c[17] ^ c[20] ^ c[21] ^ c[23] ^
    c[24] ^ c[26] ^ c[28] ^ c[31];

assign crc_out[22] =
    c[1] ^ c[4] ^ c[5] ^ c[6] ^ c[7] ^ c[8] ^
    c[9] ^ c[10] ^ c[13] ^ c[15] ^ c[16] ^ c[17] ^ c[18] ^
    c[19] ^ c[24] ^ c[25] ^ c[29] ^ c[30];

assign crc_out[23] =
    c[0] ^ c[2] ^ c[3] ^ c[4] ^ c[6] ^ c[7] ^
    c[8] ^ c[9] ^ c[13] ^ c[15] ^ c[17] ^ c[18] ^ c[20] ^
    c[21] ^ c[22] ^ c[25] ^ c[26] ^ c[27] ^ c[31];

assign crc_out[24] =
    c[1] ^ c[3] ^ c[4] ^ c[5] ^ c[7] ^ c[8] ^
    c[9] ^ c[10] ^ c[14] ^ c[16] ^ c[18] ^ c[19] ^ c[21] ^
    c[22] ^ c[23] ^ c[26] ^ c[27] ^ c[28];

assign crc_out[25] =
    c[0] ^ c[2] ^ c[3] ^ c[6] ^ c[8] ^ c[9] ^
    c[13] ^ c[14] ^ c[16] ^ c[17] ^ c[20] ^ c[21] ^ c[23] ^
    c[24] ^ c[28] ^ c[29] ^ c[30];

assign crc_out[26] =
    c[1] ^ c[5] ^ c[7] ^ c[9] ^ c[11] ^ c[13] ^
    c[16] ^ c[17] ^ c[18] ^ c[19] ^ c[24] ^ c[25] ^ c[27] ^
    c[29] ^ c[31];

assign crc_out[27] =
    c[0] ^ c[2] ^ c[3] ^ c[4] ^ c[5] ^ c[6] ^
    c[8] ^ c[11] ^ c[12] ^ c[13] ^ c[15] ^ c[16] ^ c[17] ^
    c[18] ^ c[20] ^ c[21] ^ c[22] ^ c[25] ^ c[26] ^ c[27] ^
    c[28];

assign crc_out[28] =
    c[0] ^ c[1] ^ c[6] ^ c[7] ^ c[9] ^ c[10] ^
    c[11] ^ c[12] ^ c[15] ^ c[17] ^ c[18] ^ c[23] ^ c[26] ^
    c[28] ^ c[29] ^ c[30];

assign crc_out[29] =
    c[0] ^ c[1] ^ c[2] ^ c[7] ^ c[8] ^ c[10] ^
    c[11] ^ c[12] ^ c[13] ^ c[16] ^ c[18] ^ c[19] ^ c[24] ^
    c[27] ^ c[29] ^ c[30] ^ c[31];

assign crc_out[30] =
    c[1] ^ c[2] ^ c[3] ^ c[8] ^ c[9] ^ c[11] ^
    c[12] ^ c[13] ^ c[14] ^ c[17] ^ c[19] ^ c[20] ^ c[25] ^
    c[28] ^ c[30] ^ c[31];

assign crc_out[31] =
    c[2] ^ c[3] ^ c[4] ^ c[9] ^ c[10] ^ c[12] ^
    c[13] ^ c[14] ^ c[15] ^ c[18] ^ c[20] ^ c[21] ^ c[26] ^
    c[29] ^ c[31];

endmodule
