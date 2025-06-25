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

module alt_ntrlkn_4l_3g_crc32c_dat64_factor (c,d,crc_out);
input[31:0] c;
input[63:0] d;
output[31:0] crc_out;
wire[31:0] crc_out;

wire[149:0] h ;

alt_ntrlkn_4l_3g_xor6 cx_0 (crc_out[0],    h[28] , h[49] , h[63] , h[64] , h[67] , h[96]);
alt_ntrlkn_4l_3g_xor6 cx_1 (crc_out[1],    h[60] , h[67] , h[79] , h[90] , h[99] , h[108]);
alt_ntrlkn_4l_3g_xor6 cx_2 (crc_out[2],    h[58] , h[70] , h[93] , h[111] , h[118] , h[123]);
alt_ntrlkn_4l_3g_xor6 cx_3 (crc_out[3],    h[43] , h[53] , h[57] , h[63] , h[129] , h[134]);
alt_ntrlkn_4l_3g_xor6 cx_4 (crc_out[4],    h[10] , h[14] , h[139] , h[147] , h[148] , h[149]);
alt_ntrlkn_4l_3g_xor6 cx_5 (crc_out[5],    h[54] , h[62] , h[71] , h[74] , h[145] , h[146]);
alt_ntrlkn_4l_3g_xor6 cx_6 (crc_out[6],    h[29] , h[48] , h[74] , h[142] , h[143] , h[144]);
alt_ntrlkn_4l_3g_xor6 cx_7 (crc_out[7],    h[12] , h[37] , h[50] , h[128] , h[140] , h[141]);
alt_ntrlkn_4l_3g_xor6 cx_8 (crc_out[8],    h[61] , h[67] , h[69] , h[78] , h[137] , h[138]);
alt_ntrlkn_4l_3g_xor6 cx_9 (crc_out[9],    h[24] , h[28] , h[48] , h[51] , h[135] , h[136]);
alt_ntrlkn_4l_3g_xor6 cx_10 (crc_out[10],    h[15] , h[41] , h[130] , h[131] , h[132] , h[133]);
alt_ntrlkn_4l_3g_xor6 cx_11 (crc_out[11],    h[48] , h[49] , h[62] , h[75] , h[126] , h[127]);
alt_ntrlkn_4l_3g_xor6 cx_12 (crc_out[12],    h[8] , h[21] , h[48] , h[72] , h[124] , h[125]);
alt_ntrlkn_4l_3g_xor6 cx_13 (crc_out[13],    h[65] , h[85] , h[88] , h[90] , h[122] , h[128]);
alt_ntrlkn_4l_3g_xor6 cx_14 (crc_out[14],    h[66] , h[71] , h[72] , h[119] , h[120] , h[121]);
alt_ntrlkn_4l_3g_xor6 cx_15 (crc_out[15],    h[41] , h[51] , h[79] , h[80] , h[117] , h[118]);
alt_ntrlkn_4l_3g_xor6 cx_16 (crc_out[16],    h[46] , h[48] , h[55] , h[114] , h[115] , h[116]);
alt_ntrlkn_4l_3g_xor6 cx_17 (crc_out[17],    h[23] , h[44] , h[70] , h[75] , h[112] , h[113]);
alt_ntrlkn_4l_3g_xor6 cx_18 (crc_out[18],    h[37] , h[47] , h[60] , h[77] , h[109] , h[110]);
alt_ntrlkn_4l_3g_xor6 cx_19 (crc_out[19],    h[39] , h[54] , h[58] , h[63] , h[106] , h[107]);
alt_ntrlkn_4l_3g_xor6 cx_20 (crc_out[20],    h[48] , h[68] , h[70] , h[79] , h[104] , h[105]);
alt_ntrlkn_4l_3g_xor6 cx_21 (crc_out[21],    h[43] , h[53] , h[66] , h[80] , h[102] , h[103]);
alt_ntrlkn_4l_3g_xor6 cx_22 (crc_out[22],    h[38] , h[45] , h[57] , h[68] , h[100] , h[101]);
alt_ntrlkn_4l_3g_xor6 cx_23 (crc_out[23],    h[31] , h[42] , h[56] , h[93] , h[97] , h[98]);
alt_ntrlkn_4l_3g_xor6 cx_24 (crc_out[24],    h[39] , h[44] , h[80] , h[85] , h[94] , h[95]);
alt_ntrlkn_4l_3g_xor6 cx_25 (crc_out[25],    h[35] , h[40] , h[64] , h[69] , h[91] , h[92]);
alt_ntrlkn_4l_3g_xor6 cx_26 (crc_out[26],    h[17] , h[18] , h[75] , h[79] , h[88] , h[89]);
alt_ntrlkn_4l_3g_xor6 cx_27 (crc_out[27],    h[33] , h[46] , h[62] , h[71] , h[86] , h[87]);
alt_ntrlkn_4l_3g_xor6 cx_28 (crc_out[28],    h[45] , h[50] , h[66] , h[77] , h[83] , h[84]);
alt_ntrlkn_4l_3g_xor6 cx_29 (crc_out[29],    h[32] , h[55] , h[74] , h[78] , h[81] , h[82]);
alt_ntrlkn_4l_3g_xor6 cx_30 (crc_out[30],    h[26] , h[47] , h[58] , h[70] , h[73] , h[76]);
alt_ntrlkn_4l_3g_xor6 cx_31 (crc_out[31],    h[36] , h[52] , h[56] , h[59] , h[61] , h[65]);
alt_ntrlkn_4l_3g_xor6 hx_0 (h[0],    c[13] , c[17] , d[49] , d[45] , d[8] , d[0]);   // used by 6
alt_ntrlkn_4l_3g_xor6 hx_1 (h[1],    c[2] , c[8] , c[20] , d[52] , d[40] , d[34]);   // used by 10
alt_ntrlkn_4l_3g_xor6 hx_2 (h[2],    c[1] , c[18] , c[19] , d[51] , d[50] , d[33]);   // used by 9
alt_ntrlkn_4l_3g_xor6 hx_3 (h[3],    c[4] , c[16] , d[48] , d[36] , d[31] , d[30]);   // used by 6
alt_ntrlkn_4l_3g_xor6 hx_4 (h[4],    c[3] , c[15] , d[47] , d[35] , d[25] , d[16]);   // used by 8
alt_ntrlkn_4l_3g_xor6 hx_5 (h[5],    c[0] , c[6] , d[38] , d[32] , d[29] , d[19]);   // used by 6
alt_ntrlkn_4l_3g_xor6 hx_6 (h[6],    c[30] , d[62] , d[23] , d[5] , d[4] , d[3]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_7 (h[7],    c[10] , d[42] , d[27] , d[26] , d[22] , d[17]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_8 (h[8],    c[28] , d[60] , d[13] , d[6] , d[2] , d[1]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_9 (h[9],    c[7] , c[23] , d[55] , d[39] , d[20] , d[8]);   // used by 5
alt_ntrlkn_4l_3g_xor6 hx_10 (h[10],    c[9] , c[25] , c[31] , d[63] , d[57] , d[41]);   // used by 7
alt_ntrlkn_4l_3g_xor6 hx_11 (h[11],    c[5] , c[11] , d[43] , d[37] , d[27] , d[18]);   // used by 6
alt_ntrlkn_4l_3g_xor6 hx_12 (h[12],    c[21] , c[26] , d[58] , d[53] , d[12] , d[5]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_13 (h[13],    c[17] , d[49] , d[45] , d[9] , d[7] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_14 (h[14],    c[14] , d[46] , d[21] , d[11] , d[10] , d[9]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_15 (h[15],    c[13] , c[31] , d[63] , d[45] , d[6] , d[1]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_16 (h[16],    c[17] , c[28] , d[60] , d[49] , d[21] , d[2]);   // used by 5
alt_ntrlkn_4l_3g_xor6 hx_17 (h[17],    c[24] , c[29] , d[61] , d[56] , d[23] , d[14]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_18 (h[18],    c[16] , c[27] , d[59] , d[48] , d[25] , d[15]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_19 (h[19],    d[62] , d[28] , d[12] , d[7] , d[3] , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_20 (h[20],    c[4] , c[12] , c[22] , d[54] , d[44] , d[36]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_21 (h[21],    c[14] , c[29] , c[31] , d[63] , d[61] , d[46]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_22 (h[22],    c[19] , c[30] , d[62] , d[51] , d[28] , d[4]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_23 (h[23],    c[0] , c[6] , d[38] , d[32] , d[24] , d[19]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_24 (h[24],    c[5] , c[21] , d[53] , d[37] , d[18] , d[3]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_25 (h[25],    c[10] , c[24] , d[56] , d[42] , d[20] , d[9]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_26 (h[26],    c[3] , c[14] , d[46] , d[35] , d[29] , d[28]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_27 (h[27],    c[20] , d[52] , d[22] , d[17] , d[13] , 1'b0);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_28 (h[28],    c[13] , c[27] , d[59] , d[45] , d[21] , d[0]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_29 (h[29],    c[2] , d[34] , d[30] , d[29] , d[24] , d[15]);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_30 (h[30],    c[30] , d[62] , d[51] , d[5] , d[0] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_31 (h[31],    c[17] , d[49] , d[30] , d[24] , d[10] , d[7]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_32 (h[32],    c[11] , c[12] , d[44] , d[43] , d[14] , d[13]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_33 (h[33],    c[6] , c[25] , d[57] , d[38] , d[31] , d[23]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_34 (h[34],    d[58] , d[53] , d[25] , d[3] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_35 (h[35],    c[9] , d[41] , d[25] , d[16] , d[4] , d[2]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_36 (h[36],    c[18] , d[50] , d[8] , d[7] , d[6] , d[5]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_37 (h[37],    c[1] , d[33] , d[14] , d[11] , d[10] , d[6]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_38 (h[38],    c[5] , c[15] , d[47] , d[37] , d[18] , d[2]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_39 (h[39],    c[9] , c[10] , d[42] , d[41] , d[14] , d[11]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_40 (h[40],    c[16] , c[23] , c[28] , d[60] , d[55] , d[48]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_41 (h[41],    c[4] , c[20] , c[28] , d[60] , d[52] , d[36]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_42 (h[42],    c[22] , d[54] , d[28] , d[18] , d[11] , d[3]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_43 (h[43],    c[6] , c[7] , c[13] , d[45] , d[39] , d[38]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_44 (h[44],    c[21] , c[22] , c[26] , d[58] , d[54] , d[53]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_45 (h[45],    c[7] , c[9] , c[29] , d[61] , d[41] , d[39]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_46 (h[46],    c[0] , c[18] , d[50] , d[32] , d[24] , d[15]);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_47 (h[47],    c[13] , c[19] , d[51] , d[45] , d[19] , d[16]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_48 (h[48],    c[30] , d[62] , d[7] , d[4] , 1'b0 , 1'b0);   // used by 6
alt_ntrlkn_4l_3g_xor6 hx_49 (h[49],    c[10] , d[42] , d[9] , d[7] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_50 (h[50],    c[18] , d[50] , d[8] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_51 (h[51],    d[22] , d[17] , d[11] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_52 (h[52],    h[21] , h[29] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_53 (h[53],    c[16] , d[48] , d[19] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_54 (h[54],    c[24] , d[56] , d[23] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_55 (h[55],    c[29] , d[61] , d[27] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_56 (h[56],    c[4] , c[13] , d[45] , d[36] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_57 (h[57],    c[8] , c[25] , d[57] , d[40] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_58 (h[58],    c[12] , d[44] , d[25] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_59 (h[59],    c[26] , d[58] , d[20] , d[3] , h[4] , h[7]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_60 (h[60],    c[15] , c[31] , d[63] , d[47] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_61 (h[61],    c[21] , d[53] , d[11] , d[4] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_62 (h[62],    c[15] , c[27] , d[59] , d[47] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_63 (h[63],    c[22] , d[54] , d[26] , d[8] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_64 (h[64],    c[21] , d[53] , d[17] , d[6] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_65 (h[65],    c[9] , c[12] , c[20] , d[52] , d[44] , d[41]);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_66 (h[66],    c[23] , d[55] , d[1] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_67 (h[67],    c[14] , d[46] , d[5] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_68 (h[68],    c[6] , d[38] , d[10] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_69 (h[69],    c[0] , d[32] , d[13] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_70 (h[70],    d[14] , d[11] , h[37] , 1'b0 , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_71 (h[71],    c[3] , d[35] , d[21] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_72 (h[72],    c[19] , d[51] , d[22] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_73 (h[73],    d[7] , h[1] , h[6] , h[10] , h[16] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_74 (h[74],    c[0] , d[32] , d[28] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_75 (h[75],    c[7] , d[39] , d[12] , d[3] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_76 (h[76],    c[11] , d[43] , d[26] , d[24] , d[15] , d[14]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_77 (h[77],    c[26] , d[58] , d[31] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_78 (h[78],    c[2] , d[34] , d[24] , d[2] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_79 (h[79],    d[31] , d[24] , d[6] , d[1] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_4l_3g_xor6 hx_80 (h[80],    c[5] , d[37] , d[26] , d[16] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_4l_3g_xor6 hx_81 (h[81],    h[2] , h[6] , h[15] , h[18] , h[25] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_82 (h[82],    c[7] , c[8] , d[40] , d[39] , d[22] , d[18]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_83 (h[83],    h[6] , h[7] , h[16] , h[23] , h[32] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_84 (h[84],    c[1] , c[15] , d[47] , d[33] , d[12] , d[0]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_85 (h[85],    d[25] , d[16] , d[12] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_86 (h[86],    h[8] , h[11] , h[12] , h[20] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_87 (h[87],    c[16] , d[48] , d[29] , d[17] , h[0] , h[1]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_88 (h[88],    d[27] , d[18] , h[11] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_89 (h[89],    d[29] , d[28] , d[27] , h[0] , h[2] , h[10]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_90 (h[90],    c[17] , d[49] , d[9] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_91 (h[91],    d[3] , h[0] , h[1] , h[17] , h[26] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_92 (h[92],    c[6] , c[30] , d[62] , d[38] , d[20] , d[15]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_93 (h[93],    c[18] , d[50] , d[27] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_94 (h[94],    d[4] , h[2] , h[3] , h[8] , h[9] , h[26]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_95 (h[95],    c[8] , c[27] , d[59] , d[40] , d[19] , d[17]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_96 (h[96],    d[23] , d[12] , h[3] , h[4] , h[11] , h[22]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_97 (h[97],    d[0] , h[1] , h[4] , h[5] , h[10] , h[12]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_98 (h[98],    c[7] , c[27] , d[59] , d[39] , d[13] , d[1]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_99 (h[99],    d[28] , d[10] , d[8] , d[7] , h[5] , h[11]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_100 (h[100],    c[30] , h[2] , h[3] , h[19] , h[25] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_101 (h[101],    d[25] , d[23] , d[22] , d[16] , d[5] , h[0]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_102 (h[102],    c[21] , c[26] , h[16] , h[25] , h[34] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_103 (h[103],    c[0] , c[31] , d[63] , d[32] , d[5] , h[1]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_104 (h[104],    d[0] , h[9] , h[10] , h[18] , h[20] , h[38]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_105 (h[105],    c[19] , c[20] , d[52] , d[51] , d[19] , d[7]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_106 (h[106],    c[19] , h[5] , h[11] , h[15] , h[30] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_107 (h[107],    d[22] , d[20] , d[16] , d[15] , d[4] , h[1]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_108 (h[108],    d[26] , h[20] , h[27] , h[40] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_109 (h[109],    h[1] , h[9] , h[11] , h[26] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_110 (h[110],    c[30] , d[62] , d[30] , d[21] , d[13] , d[0]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_111 (h[111],    c[16] , c[21] , d[53] , d[48] , d[30] , d[28]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_112 (h[112],    d[9] , d[8] , h[4] , h[10] , h[22] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_113 (h[113],    d[18] , d[17] , d[11] , h[27] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_114 (h[114],    h[24] , h[33] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_115 (h[115],    d[8] , d[5] , d[4] , d[2] , h[1] , h[14]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_116 (h[116],    c[19] , c[24] , d[56] , d[51] , d[17] , d[12]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_117 (h[117],    d[30] , d[24] , d[10] , d[4] , d[2] , h[2]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_118 (h[118],    c[13] , h[9] , h[13] , h[17] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_119 (h[119],    h[18] , h[20] , h[36] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_120 (h[120],    d[13] , d[10] , d[9] , d[3] , d[0] , h[5]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_121 (h[121],    d[30] , d[21] , d[16] , d[2] , h[16] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_122 (h[122],    d[14] , d[2] , h[28] , h[42] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_123 (h[123],    d[11] , h[5] , h[38] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_124 (h[124],    d[21] , d[10] , d[5] , d[3] , h[1] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_125 (h[125],    c[11] , c[16] , c[18] , d[50] , d[48] , d[43]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_126 (h[126],    h[15] , h[16] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_127 (h[127],    c[29] , d[61] , d[20] , d[5] , d[0] , h[2]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_128 (h[128],    h[3] , h[7] , h[21] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_4l_3g_xor6 hx_129 (h[129],    c[17] , c[24] , d[56] , d[49] , d[31] , d[20]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_130 (h[130],    h[4] , h[5] , h[7] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_131 (h[131],    d[30] , d[24] , d[15] , d[7] , d[2] , d[0]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_132 (h[132],    c[21] , c[27] , c[30] , d[62] , d[59] , d[53]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_133 (h[133],    c[2] , c[16] , c[17] , d[49] , d[48] , d[34]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_134 (h[134],    c[30] , h[2] , h[14] , h[19] , h[29] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_135 (h[135],    d[14] , d[8] , d[1] , h[2] , h[3] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_136 (h[136],    c[10] , d[42] , d[28] , d[27] , d[23] , d[20]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_137 (h[137],    d[10] , h[0] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_138 (h[138],    c[10] , d[42] , d[25] , d[21] , d[19] , d[15]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_139 (h[139],    c[17] , d[49] , d[24] , d[15] , h[46] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_140 (h[140],    d[9] , d[1] , h[4] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_141 (h[141],    d[30] , d[24] , d[23] , d[18] , h[29] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_142 (h[142],    d[26] , h[14] , h[27] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_143 (h[143],    c[28] , d[60] , d[14] , d[5] , h[0] , h[4]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_144 (h[144],    c[1] , c[31] , d[63] , d[33] , h[10] , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_145 (h[145],    d[26] , h[12] , h[27] , h[39] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_146 (h[146],    c[8] , d[40] , d[10] , d[9] , h[2] , h[3]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_147 (h[147],    c[19] , c[26] , d[58] , d[51] , d[31] , d[30]);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_148 (h[148],    h[1] , h[4] , h[9] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_4l_3g_xor6 hx_149 (h[149],    d[29] , d[27] , d[22] , d[13] , d[12] , d[4]);   // used by 1

endmodule
