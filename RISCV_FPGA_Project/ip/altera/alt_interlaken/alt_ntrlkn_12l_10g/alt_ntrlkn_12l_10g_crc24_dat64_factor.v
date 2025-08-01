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

module alt_ntrlkn_12l_10g_crc24_dat64_factor (c,d,crc_out);
input[23:0] c;
input[63:0] d;
output[23:0] crc_out;
wire[23:0] crc_out;

wire[114:0] h ;

alt_ntrlkn_12l_10g_xor6 cx_0 (crc_out[0],    h[51] , h[60] , h[66] , h[73] , h[80] , h[93]);
alt_ntrlkn_12l_10g_xor6 cx_1 (crc_out[1],    h[16] , h[37] , h[44] , h[61] , h[104] , h[114]);
alt_ntrlkn_12l_10g_xor6 cx_2 (crc_out[2],    h[35] , h[36] , h[44] , h[57] , h[112] , h[113]);
alt_ntrlkn_12l_10g_xor6 cx_3 (crc_out[3],    h[32] , h[35] , h[37] , h[40] , h[41] , h[111]);
alt_ntrlkn_12l_10g_xor6 cx_4 (crc_out[4],    h[44] , h[46] , h[59] , h[65] , h[109] , h[110]);
alt_ntrlkn_12l_10g_xor6 cx_5 (crc_out[5],    h[45] , h[46] , h[63] , h[64] , h[107] , h[108]);
alt_ntrlkn_12l_10g_xor6 cx_6 (crc_out[6],    h[24] , h[34] , h[65] , h[67] , h[105] , h[106]);
alt_ntrlkn_12l_10g_xor6 cx_7 (crc_out[7],    h[40] , h[49] , h[58] , h[67] , h[102] , h[103]);
alt_ntrlkn_12l_10g_xor6 cx_8 (crc_out[8],    h[35] , h[39] , h[63] , h[66] , h[100] , h[101]);
alt_ntrlkn_12l_10g_xor6 cx_9 (crc_out[9],    h[27] , h[45] , h[61] , h[66] , h[98] , h[99]);
alt_ntrlkn_12l_10g_xor6 cx_10 (crc_out[10],    h[33] , h[44] , h[48] , h[95] , h[96] , h[97]);
alt_ntrlkn_12l_10g_xor6 cx_11 (crc_out[11],    h[22] , h[33] , h[36] , h[49] , h[59] , h[94]);
alt_ntrlkn_12l_10g_xor6 cx_12 (crc_out[12],    h[12] , h[44] , h[62] , h[90] , h[91] , h[92]);
alt_ntrlkn_12l_10g_xor6 cx_13 (crc_out[13],    h[35] , h[38] , h[50] , h[64] , h[88] , h[89]);
alt_ntrlkn_12l_10g_xor6 cx_14 (crc_out[14],    h[34] , h[50] , h[56] , h[62] , h[86] , h[87]);
alt_ntrlkn_12l_10g_xor6 cx_15 (crc_out[15],    h[19] , h[38] , h[48] , h[55] , h[84] , h[85]);
alt_ntrlkn_12l_10g_xor6 cx_16 (crc_out[16],    h[30] , h[38] , h[42] , h[54] , h[62] , h[83]);
alt_ntrlkn_12l_10g_xor6 cx_17 (crc_out[17],    h[25] , h[31] , h[54] , h[66] , h[81] , h[82]);
alt_ntrlkn_12l_10g_xor6 cx_18 (crc_out[18],    h[41] , h[55] , h[60] , h[63] , h[78] , h[79]);
alt_ntrlkn_12l_10g_xor6 cx_19 (crc_out[19],    h[21] , h[28] , h[74] , h[75] , h[76] , h[77]);
alt_ntrlkn_12l_10g_xor6 cx_20 (crc_out[20],    h[42] , h[45] , h[51] , h[57] , h[71] , h[72]);
alt_ntrlkn_12l_10g_xor6 cx_21 (crc_out[21],    h[29] , h[56] , h[67] , h[68] , h[69] , h[70]);
alt_ntrlkn_12l_10g_xor6 cx_22 (crc_out[22],    h[31] , h[37] , h[39] , h[52] , h[53] , h[58]);
alt_ntrlkn_12l_10g_xor6 cx_23 (crc_out[23],    h[19] , h[23] , h[43] , h[47] , h[63] , h[73]);
alt_ntrlkn_12l_10g_xor6 hx_0 (h[0],    c[19] , c[23] , d[63] , d[59] , d[36] , d[13]);   // used by 8
alt_ntrlkn_12l_10g_xor6 hx_1 (h[1],    c[16] , c[20] , d[60] , d[56] , d[36] , d[12]);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_2 (h[2],    c[17] , c[21] , d[61] , d[57] , d[35] , d[5]);   // used by 8
alt_ntrlkn_12l_10g_xor6 hx_3 (h[3],    c[9] , c[17] , d[57] , d[49] , d[37] , d[4]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_4 (h[4],    c[9] , c[10] , d[50] , d[49] , d[11] , d[7]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_5 (h[5],    c[5] , c[10] , c[11] , d[51] , d[50] , d[45]);   // used by 8
alt_ntrlkn_12l_10g_xor6 hx_6 (h[6],    c[0] , c[7] , d[47] , d[40] , d[34] , d[10]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_7 (h[7],    c[6] , d[46] , d[39] , d[34] , d[8] , d[4]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_8 (h[8],    c[18] , c[22] , d[62] , d[58] , d[16] , d[2]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_9 (h[9],    c[0] , d[40] , d[29] , d[25] , d[22] , d[9]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_10 (h[10],    c[12] , c[13] , d[53] , d[52] , d[29] , d[11]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_11 (h[11],    c[1] , c[16] , c[22] , d[62] , d[56] , d[41]);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_12 (h[12],    c[15] , c[20] , d[60] , d[55] , d[39] , d[20]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_13 (h[13],    c[8] , c[14] , d[54] , d[48] , d[23] , d[3]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_14 (h[14],    c[2] , c[14] , d[54] , d[42] , d[38] , d[19]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_15 (h[15],    c[4] , c[9] , d[49] , d[44] , d[21] , d[6]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_16 (h[16],    c[6] , c[12] , d[52] , d[46] , d[24] , d[12]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_17 (h[17],    c[1] , c[13] , d[53] , d[41] , d[30] , d[18]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_18 (h[18],    c[18] , d[58] , d[37] , d[31] , d[30] , d[3]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_19 (h[19],    c[8] , c[11] , c[12] , d[52] , d[51] , d[48]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_20 (h[20],    c[16] , d[56] , d[33] , d[28] , d[8] , d[0]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_21 (h[21],    c[3] , d[43] , d[38] , d[26] , d[18] , d[8]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_22 (h[22],    c[23] , d[63] , d[32] , d[30] , d[23] , d[14]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_23 (h[23],    c[7] , c[22] , d[62] , d[47] , d[29] , d[2]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_24 (h[24],    c[19] , c[23] , d[63] , d[59] , d[35] , d[16]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_25 (h[25],    c[3] , d[43] , d[34] , d[24] , d[11] , d[10]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_26 (h[26],    d[38] , d[17] , d[9] , d[1] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_27 (h[27],    c[6] , c[19] , d[59] , d[46] , d[39] , d[17]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_28 (h[28],    c[21] , d[61] , d[21] , d[15] , d[10] , d[6]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_29 (h[29],    c[3] , d[43] , d[31] , d[26] , d[3] , d[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_30 (h[30],    c[14] , d[54] , d[28] , d[23] , d[21] , d[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_31 (h[31],    c[4] , d[44] , d[37] , d[27] , d[9] , d[6]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_32 (h[32],    c[3] , c[4] , d[44] , d[43] , d[26] , d[17]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_33 (h[33],    c[6] , c[20] , d[60] , d[46] , d[39] , d[27]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_34 (h[34],    c[2] , d[42] , d[38] , d[24] , d[22] , d[21]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_35 (h[35],    c[8] , d[48] , d[25] , d[18] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_36 (h[36],    c[15] , d[55] , d[35] , d[18] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_37 (h[37],    c[18] , d[58] , d[14] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_38 (h[38],    c[2] , c[4] , d[44] , d[42] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_39 (h[39],    c[10] , d[50] , d[32] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_40 (h[40],    c[12] , d[52] , d[2] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_41 (h[41],    d[37] , d[8] , d[3] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_42 (h[42],    c[17] , d[57] , d[13] , d[4] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_43 (h[43],    d[15] , d[9] , h[0] , h[2] , h[18] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_44 (h[44],    d[17] , d[15] , d[6] , d[1] , 1'b0 , 1'b0);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_45 (h[45],    d[31] , d[27] , d[5] , d[0] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_46 (h[46],    d[32] , d[19] , d[9] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_47 (h[47],    c[5] , c[15] , d[55] , d[45] , d[38] , d[33]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_48 (h[48],    d[28] , d[20] , d[12] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_49 (h[49],    d[24] , d[21] , d[13] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_50 (h[50],    c[1] , d[41] , d[26] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_51 (h[51],    c[9] , d[49] , d[32] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_52 (h[52],    h[1] , h[2] , h[7] , h[23] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_53 (h[53],    c[23] , d[63] , d[30] , d[28] , d[21] , d[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_54 (h[54],    c[9] , d[49] , d[12] , d[8] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_55 (h[55],    c[16] , d[56] , d[25] , d[10] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_56 (h[56],    c[5] , c[22] , d[62] , d[45] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_57 (h[57],    c[7] , c[11] , d[51] , d[47] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_58 (h[58],    c[11] , c[14] , d[54] , d[51] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_59 (h[59],    c[19] , c[21] , d[61] , d[59] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_60 (h[60],    d[32] , d[30] , h[22] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_61 (h[61],    d[33] , d[9] , d[0] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_62 (h[62],    c[3] , d[43] , d[19] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_63 (h[63],    c[0] , d[40] , d[28] , d[7] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_64 (h[64],    d[34] , d[29] , d[20] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_65 (h[65],    c[13] , d[53] , d[36] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_66 (h[66],    d[38] , d[22] , d[16] , d[0] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_67 (h[67],    c[15] , d[55] , d[20] , d[1] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_68 (h[68],    h[0] , h[2] , h[4] , h[20] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_69 (h[69],    d[38] , d[34] , d[29] , d[27] , d[4] , d[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_70 (h[70],    c[13] , d[53] , d[39] , d[27] , h[33] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_71 (h[71],    h[9] , h[14] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_72 (h[72],    c[4] , d[44] , d[34] , d[26] , d[15] , h[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_73 (h[73],    d[22] , d[10] , d[6] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_74 (h[74],    h[9] , h[11] , h[16] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_75 (h[75],    d[11] , d[7] , d[5] , d[4] , d[2] , h[5]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_76 (h[76],    c[18] , d[58] , d[39] , d[36] , d[14] , d[13]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_77 (h[77],    c[7] , c[13] , c[17] , d[57] , d[53] , d[47]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_78 (h[78],    c[2] , d[42] , h[15] , h[16] , h[26] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_79 (h[79],    d[13] , d[11] , d[4] , h[2] , h[5] , h[12]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_80 (h[80],    c[8] , c[19] , c[20] , d[60] , d[59] , d[48]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_81 (h[81],    h[5] , h[11] , h[12] , h[13] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_82 (h[82],    d[19] , d[7] , d[5] , d[4] , d[2] , h[0]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_83 (h[83],    d[31] , d[30] , d[26] , d[18] , h[5] , h[10]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_84 (h[84],    d[3] , d[0] , h[4] , h[17] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_85 (h[85],    c[3] , d[43] , d[29] , d[27] , d[22] , d[17]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_86 (h[86],    h[2] , h[4] , h[18] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_87 (h[87],    d[33] , d[27] , d[17] , d[16] , d[15] , h[0]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_88 (h[88],    h[22] , h[28] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_89 (h[89],    c[0] , d[40] , d[35] , h[1] , h[3] , h[8]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_90 (h[90],    d[3] , h[0] , h[2] , h[9] , h[11] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_91 (h[91],    d[31] , d[28] , d[24] , d[14] , d[11] , d[6]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_92 (h[92],    c[7] , c[8] , d[48] , d[47] , d[34] , d[33]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_93 (h[93],    d[36] , d[7] , h[7] , h[10] , h[11] , h[18]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_94 (h[94],    d[12] , d[4] , h[6] , h[8] , h[14] , h[20]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_95 (h[95],    h[17] , h[19] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_96 (h[96],    d[23] , d[15] , d[11] , d[5] , d[2] , h[6]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_97 (h[97],    c[14] , d[54] , d[36] , d[35] , d[32] , d[26]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_98 (h[98],    h[5] , h[6] , h[10] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_99 (h[99],    d[35] , d[26] , d[25] , d[19] , d[4] , d[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_100 (h[100],    d[24] , h[0] , h[2] , h[7] , h[15] , h[23]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_101 (h[101],    c[15] , d[55] , d[38] , d[31] , d[28] , d[26]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_102 (h[102],    h[3] , h[9] , h[27] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_103 (h[103],    d[24] , d[23] , d[11] , h[1] , h[25] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_104 (h[104],    c[2] , c[10] , d[50] , d[42] , d[36] , d[29]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_105 (h[105],    d[9] , h[5] , h[13] , h[20] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_106 (h[106],    c[18] , d[58] , d[39] , d[19] , d[12] , d[11]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_107 (h[107],    h[0] , h[5] , h[13] , h[15] , h[17] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_108 (h[108],    c[21] , d[61] , d[33] , d[11] , d[8] , d[7]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_109 (h[109],    d[1] , h[3] , h[5] , h[12] , h[21] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_110 (h[110],    c[4] , d[44] , d[27] , d[13] , d[12] , d[3]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_111 (h[111],    d[31] , d[5] , h[1] , h[4] , h[14] , h[24]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_112 (h[112],    h[17] , h[25] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_113 (h[113],    c[2] , d[42] , d[7] , h[0] , h[3] , h[8]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_114 (h[114],    d[16] , h[2] , h[6] , h[11] , h[13] , 1'b0);   // used by 1
endmodule
