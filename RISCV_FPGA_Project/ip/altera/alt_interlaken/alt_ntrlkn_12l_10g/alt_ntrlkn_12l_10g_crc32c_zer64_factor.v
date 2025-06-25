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

module alt_ntrlkn_12l_10g_crc32c_zer64_factor (c,crc_out);
input[31:0] c;
output[31:0] crc_out;
wire[31:0] crc_out;

wire[47:0] h ;

alt_ntrlkn_12l_10g_xor6 cx_0 (crc_out[0],    h[2] , h[8] , h[10] , h[13] , h[46] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_1 (crc_out[1],    h[6] , h[13] , h[14] , h[28] , h[45] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_2 (crc_out[2],    c[21] , c[23] , h[0] , h[5] , h[14] , h[34]);
alt_ntrlkn_12l_10g_xor6 cx_3 (crc_out[3],    c[24] , h[0] , h[1] , h[4] , h[44] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_4 (crc_out[4],    h[8] , h[42] , h[43] , h[47] , 1'b0 , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_5 (crc_out[5],    h[0] , h[7] , h[9] , h[13] , h[40] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_6 (crc_out[6],    h[1] , h[4] , h[12] , h[14] , h[39] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_7 (crc_out[7],    h[2] , h[7] , h[11] , h[38] , 1'b0 , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_8 (crc_out[8],    c[0] , c[14] , h[3] , h[47] , 1'b0 , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_9 (crc_out[9],    c[7] , c[30] , c[31] , h[0] , h[3] , h[13]);
alt_ntrlkn_12l_10g_xor6 cx_10 (crc_out[10],    h[1] , h[3] , h[13] , h[14] , h[36] , h[41]);
alt_ntrlkn_12l_10g_xor6 cx_11 (crc_out[11],    c[30] , h[0] , h[2] , h[35] , 1'b0 , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_12 (crc_out[12],    c[13] , c[14] , c[18] , h[1] , h[10] , h[37]);
alt_ntrlkn_12l_10g_xor6 cx_13 (crc_out[13],    c[3] , h[2] , h[12] , h[13] , h[28] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_14 (crc_out[14],    h[13] , h[14] , h[15] , h[27] , h[32] , h[41]);
alt_ntrlkn_12l_10g_xor6 cx_15 (crc_out[15],    c[4] , h[0] , h[5] , h[6] , 1'b0 , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_16 (crc_out[16],    c[14] , c[21] , h[1] , h[4] , h[5] , h[43]);
alt_ntrlkn_12l_10g_xor6 cx_17 (crc_out[17],    h[0] , h[4] , h[7] , h[14] , h[22] , h[31]);
alt_ntrlkn_12l_10g_xor6 cx_18 (crc_out[18],    h[0] , h[1] , h[8] , h[10] , h[30] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_19 (crc_out[19],    c[24] , h[1] , h[10] , h[15] , h[29] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_20 (crc_out[20],    c[31] , h[0] , h[4] , h[13] , h[15] , h[27]);
alt_ntrlkn_12l_10g_xor6 cx_21 (crc_out[21],    h[1] , h[2] , h[5] , h[14] , h[26] , h[27]);
alt_ntrlkn_12l_10g_xor6 cx_22 (crc_out[22],    h[0] , h[4] , h[5] , h[25] , h[33] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_23 (crc_out[23],    h[1] , h[7] , h[14] , h[22] , h[24] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_24 (crc_out[24],    c[28] , h[0] , h[7] , h[13] , h[23] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_25 (crc_out[25],    h[1] , h[7] , h[8] , h[14] , h[21] , h[37]);
alt_ntrlkn_12l_10g_xor6 cx_26 (crc_out[26],    h[0] , h[2] , h[13] , h[20] , h[33] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_27 (crc_out[27],    h[1] , h[7] , h[13] , h[14] , h[15] , h[19]);
alt_ntrlkn_12l_10g_xor6 cx_28 (crc_out[28],    c[28] , h[0] , h[2] , h[10] , h[14] , h[18]);
alt_ntrlkn_12l_10g_xor6 cx_29 (crc_out[29],    h[0] , h[1] , h[9] , h[10] , h[17] , h[34]);
alt_ntrlkn_12l_10g_xor6 cx_30 (crc_out[30],    h[1] , h[6] , h[10] , h[12] , h[16] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_31 (crc_out[31],    c[8] , c[12] , h[1] , h[2] , h[7] , h[11]);
alt_ntrlkn_12l_10g_xor6 hx_0 (h[0],    c[1] , c[7] , c[18] , c[19] , 1'b0 , 1'b0);   // used by 14
alt_ntrlkn_12l_10g_xor6 hx_1 (h[1],    c[2] , c[8] , c[13] , c[20] , 1'b0 , 1'b0);   // used by 14
alt_ntrlkn_12l_10g_xor6 hx_2 (h[2],    c[10] , c[13] , c[29] , c[31] , 1'b0 , 1'b0);   // used by 8
alt_ntrlkn_12l_10g_xor6 hx_3 (h[3],    c[10] , c[13] , c[21] , c[31] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_4 (h[4],    c[6] , c[20] , c[25] , c[30] , 1'b0 , 1'b0);   // used by 6
alt_ntrlkn_12l_10g_xor6 hx_5 (h[5],    c[5] , c[13] , c[24] , c[29] , 1'b0 , 1'b0);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_6 (h[6],    c[17] , c[20] , c[23] , c[28] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_7 (h[7],    c[3] , c[9] , c[21] , c[26] , 1'b0 , 1'b0);   // used by 8
alt_ntrlkn_12l_10g_xor6 hx_8 (h[8],    c[3] , c[14] , c[15] , c[26] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_9 (h[9],    c[0] , c[8] , c[20] , c[24] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_10 (h[10],    c[11] , c[19] , c[30] , c[31] , 1'b0 , 1'b0);   // used by 7
alt_ntrlkn_12l_10g_xor6 hx_11 (h[11],    c[4] , c[13] , c[14] , c[15] , c[18] , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_12 (h[12],    c[3] , c[9] , c[14] , c[20] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_13 (h[13],    c[4] , c[5] , c[16] , c[27] , 1'b0 , 1'b0);   // used by 11
alt_ntrlkn_12l_10g_xor6 hx_14 (h[14],    c[0] , c[6] , c[15] , c[17] , 1'b0 , 1'b0);   // used by 11
alt_ntrlkn_12l_10g_xor6 hx_15 (h[15],    c[9] , c[12] , c[18] , c[22] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_16 (h[16],    c[1] , c[12] , c[23] , c[25] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_17 (h[17],    c[8] , c[10] , c[27] , c[29] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_18 (h[18],    c[9] , c[12] , c[13] , c[23] , c[26] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_19 (h[19],    c[11] , c[25] , c[28] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_20 (h[20],    c[11] , c[24] , c[25] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_21 (h[21],    c[3] , c[23] , c[24] , c[30] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_22 (h[22],    c[18] , c[22] , c[31] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_23 (h[23],    c[8] , c[10] , c[14] , c[22] , c[23] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_24 (h[24],    c[4] , c[7] , c[25] , c[27] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_25 (h[25],    c[8] , c[15] , c[16] , c[20] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_26 (h[26],    c[7] , c[16] , c[21] , c[26] , c[28] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_27 (h[27],    c[15] , c[23] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_28 (h[28],    c[11] , c[12] , c[17] , c[22] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_29 (h[29],    c[0] , c[5] , c[6] , c[10] , c[18] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_30 (h[30],    c[5] , c[18] , c[19] , c[23] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_31 (h[31],    c[6] , c[17] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_32 (h[32],    c[9] , c[19] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_33 (h[33],    c[4] , c[9] , c[10] , c[17] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_34 (h[34],    c[12] , c[16] , c[19] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_35 (h[35],    c[15] , c[17] , c[27] , c[28] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_36 (h[36],    c[8] , c[13] , c[30] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_37 (h[37],    c[16] , c[28] , c[29] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_38 (h[38],    c[1] , c[2] , c[9] , c[16] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_39 (h[39],    c[1] , c[8] , c[28] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_40 (h[40],    c[5] , c[7] , c[10] , c[15] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_41 (h[41],    c[3] , c[5] , c[28] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_42 (h[42],    c[7] , c[8] , c[9] , c[23] , c[25] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_43 (h[43],    c[0] , c[18] , c[19] , c[20] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_44 (h[44],    c[14] , c[16] , c[17] , c[22] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_45 (h[45],    c[14] , c[27] , c[31] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_46 (h[46],    c[21] , c[22] , c[26] , c[29] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_47 (h[47],    c[2] , c[17] , c[31] , 1'b0 , 1'b0 , 1'b0);   // used by 2
endmodule
