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

module alt_ntrlkn_12l_10g_crc32c_d64x2_factor (d,crc_out);
input[63:0] d;
output[31:0] crc_out;
wire[31:0] crc_out;

wire[116:0] h ;

alt_ntrlkn_12l_10g_xor6 cx_0 (crc_out[0],    h[48] , h[50] , h[90] , h[105] , h[106] , h[116]);
alt_ntrlkn_12l_10g_xor6 cx_1 (crc_out[1],    h[21] , h[35] , h[39] , h[103] , h[104] , h[111]);
alt_ntrlkn_12l_10g_xor6 cx_2 (crc_out[2],    h[12] , h[48] , h[49] , h[101] , h[102] , h[107]);
alt_ntrlkn_12l_10g_xor6 cx_3 (crc_out[3],    h[37] , h[43] , h[46] , h[51] , h[100] , h[115]);
alt_ntrlkn_12l_10g_xor6 cx_4 (crc_out[4],    h[29] , h[38] , h[48] , h[98] , h[99] , h[109]);
alt_ntrlkn_12l_10g_xor6 cx_5 (crc_out[5],    h[42] , h[49] , h[96] , h[97] , h[115] , h[116]);
alt_ntrlkn_12l_10g_xor6 cx_6 (crc_out[6],    h[30] , h[38] , h[40] , h[51] , h[94] , h[95]);
alt_ntrlkn_12l_10g_xor6 cx_7 (crc_out[7],    h[43] , h[49] , h[50] , h[92] , h[93] , h[109]);
alt_ntrlkn_12l_10g_xor6 cx_8 (crc_out[8],    h[26] , h[39] , h[41] , h[47] , h[91] , 1'b0);
alt_ntrlkn_12l_10g_xor6 cx_9 (crc_out[9],    h[0] , h[28] , h[29] , h[36] , h[88] , h[89]);
alt_ntrlkn_12l_10g_xor6 cx_10 (crc_out[10],    h[20] , h[33] , h[43] , h[46] , h[86] , h[113]);
alt_ntrlkn_12l_10g_xor6 cx_11 (crc_out[11],    h[36] , h[83] , h[84] , h[85] , h[87] , h[90]);
alt_ntrlkn_12l_10g_xor6 cx_12 (crc_out[12],    h[5] , h[25] , h[35] , h[82] , h[87] , h[116]);
alt_ntrlkn_12l_10g_xor6 cx_13 (crc_out[13],    h[40] , h[42] , h[49] , h[80] , h[108] , h[114]);
alt_ntrlkn_12l_10g_xor6 cx_14 (crc_out[14],    h[29] , h[30] , h[33] , h[49] , h[78] , h[79]);
alt_ntrlkn_12l_10g_xor6 cx_15 (crc_out[15],    h[30] , h[39] , h[43] , h[76] , h[77] , h[113]);
alt_ntrlkn_12l_10g_xor6 cx_16 (crc_out[16],    h[42] , h[50] , h[74] , h[75] , h[110] , h[111]);
alt_ntrlkn_12l_10g_xor6 cx_17 (crc_out[17],    h[14] , h[29] , h[72] , h[73] , h[81] , h[90]);
alt_ntrlkn_12l_10g_xor6 cx_18 (crc_out[18],    h[24] , h[33] , h[48] , h[70] , h[71] , h[110]);
alt_ntrlkn_12l_10g_xor6 cx_19 (crc_out[19],    h[28] , h[37] , h[40] , h[46] , h[68] , h[69]);
alt_ntrlkn_12l_10g_xor6 cx_20 (crc_out[20],    h[38] , h[41] , h[42] , h[46] , h[66] , h[67]);
alt_ntrlkn_12l_10g_xor6 cx_21 (crc_out[21],    h[30] , h[41] , h[43] , h[65] , h[111] , h[114]);
alt_ntrlkn_12l_10g_xor6 cx_22 (crc_out[22],    h[2] , h[42] , h[47] , h[63] , h[64] , h[110]);
alt_ntrlkn_12l_10g_xor6 cx_23 (crc_out[23],    h[30] , h[32] , h[49] , h[50] , h[62] , h[112]);
alt_ntrlkn_12l_10g_xor6 cx_24 (crc_out[24],    h[37] , h[39] , h[48] , h[50] , h[60] , h[61]);
alt_ntrlkn_12l_10g_xor6 cx_25 (crc_out[25],    h[30] , h[39] , h[46] , h[58] , h[59] , h[107]);
alt_ntrlkn_12l_10g_xor6 cx_26 (crc_out[26],    h[24] , h[43] , h[51] , h[57] , h[110] , h[115]);
alt_ntrlkn_12l_10g_xor6 cx_27 (crc_out[27],    h[32] , h[47] , h[55] , h[56] , h[87] , h[112]);
alt_ntrlkn_12l_10g_xor6 cx_28 (crc_out[28],    h[39] , h[43] , h[53] , h[54] , h[87] , h[108]);
alt_ntrlkn_12l_10g_xor6 cx_29 (crc_out[29],    h[35] , h[44] , h[45] , h[47] , h[48] , h[52]);
alt_ntrlkn_12l_10g_xor6 cx_30 (crc_out[30],    h[16] , h[30] , h[34] , h[47] , h[51] , h[81]);
alt_ntrlkn_12l_10g_xor6 cx_31 (crc_out[31],    h[31] , h[32] , h[35] , h[36] , h[51] , h[109]);
alt_ntrlkn_12l_10g_xor6 hx_0 (h[0],    d[62] , d[49] , d[36] , d[23] , d[15] , d[13]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_1 (h[1],    d[53] , d[41] , d[21] , d[15] , d[8] , d[2]);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_2 (h[2],    d[49] , d[40] , d[11] , d[10] , d[7] , d[5]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_3 (h[3],    d[27] , d[22] , d[9] , d[5] , d[4] , d[3]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_4 (h[4],    d[56] , d[49] , d[42] , d[23] , d[11] , d[7]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_5 (h[5],    d[55] , d[54] , d[43] , d[37] , d[12] , d[8]);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_6 (h[6],    d[55] , d[28] , d[22] , d[19] , d[10] , d[6]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_7 (h[7],    d[52] , d[39] , d[26] , d[4] , d[3] , d[1]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_8 (h[8],    d[63] , d[44] , d[36] , d[20] , d[13] , d[0]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_9 (h[9],    d[53] , d[50] , d[45] , d[19] , d[6] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_10 (h[10],    d[61] , d[58] , d[20] , d[16] , d[0] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_11 (h[11],    d[62] , d[51] , d[38] , d[25] , d[20] , d[17]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_12 (h[12],    d[52] , d[48] , d[42] , d[30] , d[26] , d[16]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_13 (h[13],    d[49] , d[19] , d[11] , d[10] , d[6] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_14 (h[14],    d[51] , d[47] , d[29] , d[25] , d[10] , d[6]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_15 (h[15],    d[40] , d[33] , d[32] , d[19] , d[9] , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_16 (h[16],    d[61] , d[59] , d[48] , d[34] , d[18] , d[16]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_17 (h[17],    d[60] , d[54] , d[53] , d[50] , d[18] , d[6]);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_18 (h[18],    d[62] , d[45] , d[33] , d[19] , d[12] , d[1]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_19 (h[19],    d[39] , d[30] , d[12] , d[1] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_20 (h[20],    d[44] , d[36] , d[30] , d[28] , d[23] , d[17]);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_21 (h[21],    d[57] , d[45] , d[21] , d[19] , d[16] , d[5]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_22 (h[22],    d[46] , d[30] , d[25] , d[17] , d[12] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_23 (h[23],    d[57] , d[53] , d[32] , d[31] , d[17] , d[12]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_24 (h[24],    d[60] , d[51] , d[45] , d[39] , d[30] , d[26]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_25 (h[25],    d[58] , d[50] , d[34] , d[33] , d[20] , d[13]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_26 (h[26],    d[57] , d[53] , d[45] , d[40] , d[32] , d[17]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_27 (h[27],    d[41] , d[33] , d[28] , d[23] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_28 (h[28],    d[58] , d[42] , d[41] , d[33] , d[31] , d[29]);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_29 (h[29],    d[44] , d[28] , d[24] , d[5] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_30 (h[30],    d[47] , d[40] , d[35] , d[2] , 1'b0 , 1'b0);   // used by 7
alt_ntrlkn_12l_10g_xor6 hx_31 (h[31],    d[61] , d[59] , d[48] , d[17] , h[0] , h[6]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_32 (h[32],    d[60] , d[52] , d[43] , d[17] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_33 (h[33],    d[59] , d[34] , d[20] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_34 (h[34],    d[54] , d[42] , d[26] , d[21] , d[5] , h[3]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_35 (h[35],    d[63] , d[41] , d[17] , d[3] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_36 (h[36],    d[53] , d[45] , d[39] , d[4] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_37 (h[37],    d[47] , d[23] , d[21] , d[9] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_38 (h[38],    d[35] , d[22] , d[15] , d[10] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_39 (h[39],    d[38] , d[29] , d[25] , d[10] , 1'b0 , 1'b0);   // used by 6
alt_ntrlkn_12l_10g_xor6 hx_40 (h[40],    d[47] , d[36] , d[35] , d[13] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_41 (h[41],    d[62] , d[55] , d[49] , d[19] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_42 (h[42],    d[61] , d[54] , d[46] , d[34] , 1'b0 , 1'b0);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_43 (h[43],    d[56] , d[49] , d[31] , d[11] , 1'b0 , 1'b0);   // used by 7
alt_ntrlkn_12l_10g_xor6 hx_44 (h[44],    d[2] , h[1] , h[25] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_45 (h[45],    d[41] , d[39] , d[37] , d[26] , d[25] , d[11]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_46 (h[46],    d[43] , d[27] , d[18] , d[7] , 1'b0 , 1'b0);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_47 (h[47],    d[60] , d[51] , d[44] , d[12] , 1'b0 , 1'b0);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_48 (h[48],    d[46] , d[4] , d[2] , d[1] , 1'b0 , 1'b0);   // used by 6
alt_ntrlkn_12l_10g_xor6 hx_49 (h[49],    d[55] , d[22] , d[9] , d[3] , 1'b0 , 1'b0);   // used by 6
alt_ntrlkn_12l_10g_xor6 hx_50 (h[50],    d[41] , d[37] , d[24] , d[14] , 1'b0 , 1'b0);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_51 (h[51],    d[63] , d[14] , d[5] , d[0] , 1'b0 , 1'b0);   // used by 5
alt_ntrlkn_12l_10g_xor6 hx_52 (h[52],    d[62] , d[59] , d[57] , d[47] , d[44] , d[43]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_53 (h[53],    d[63] , d[3] , d[2] , h[10] , h[18] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_54 (h[54],    d[52] , d[46] , d[42] , d[31] , d[14] , d[7]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_55 (h[55],    d[18] , d[14] , d[12] , d[11] , d[2] , h[3]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_56 (h[56],    d[63] , d[59] , d[53] , d[40] , d[37] , d[31]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_57 (h[57],    d[58] , d[57] , d[50] , d[16] , d[6] , h[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_58 (h[58],    d[57] , d[2] , d[0] , h[9] , h[20] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_59 (h[59],    d[61] , d[27] , d[22] , d[21] , d[20] , d[3]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_60 (h[60],    d[25] , d[15] , d[3] , h[8] , h[16] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_61 (h[61],    d[57] , d[56] , d[53] , d[47] , d[45] , d[42]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_62 (h[62],    d[23] , d[15] , d[8] , h[8] , h[18] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_63 (h[63],    d[17] , d[16] , d[6] , d[4] , d[3] , h[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_64 (h[64],    d[57] , d[52] , d[45] , d[32] , d[23] , d[18]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_65 (h[65],    d[50] , d[49] , d[28] , d[23] , d[9] , h[8]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_66 (h[66],    d[60] , d[59] , d[6] , h[19] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_67 (h[67],    d[63] , d[50] , d[48] , d[32] , d[8] , d[7]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_68 (h[68],    h[6] , h[7] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_69 (h[69],    d[54] , d[47] , d[38] , d[34] , d[15] , d[11]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_70 (h[70],    d[57] , h[0] , h[5] , h[15] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_71 (h[71],    d[52] , d[38] , d[28] , d[25] , d[21] , d[18]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_72 (h[72],    h[4] , h[5] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_73 (h[73],    d[50] , d[33] , d[32] , d[31] , d[27] , d[18]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_74 (h[74],    d[50] , d[23] , h[3] , h[13] , h[23] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_75 (h[75],    d[55] , d[43] , d[36] , d[34] , d[30] , d[26]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_76 (h[76],    h[12] , h[17] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_77 (h[77],    d[41] , d[36] , d[23] , d[21] , d[8] , h[3]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_78 (h[78],    d[51] , d[2] , h[1] , h[7] , h[22] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_79 (h[79],    d[49] , d[48] , d[29] , d[10] , d[7] , d[3]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_80 (h[80],    d[63] , d[58] , d[3] , h[1] , h[2] , h[11]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_81 (h[81],    d[58] , d[52] , d[38] , d[13] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_82 (h[82],    d[27] , d[24] , d[22] , d[21] , d[9] , d[7]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_83 (h[83],    d[2] , h[4] , 1'b0 , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_84 (h[84],    d[19] , d[16] , d[12] , d[8] , d[6] , d[4]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_85 (h[85],    d[54] , d[35] , d[33] , d[31] , d[26] , d[21]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_86 (h[86],    d[62] , d[60] , d[32] , d[25] , d[4] , d[0]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_87 (h[87],    d[57] , d[40] , d[36] , d[32] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_88 (h[88],    d[14] , d[12] , d[1] , d[0] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_89 (h[89],    d[60] , d[48] , d[42] , d[37] , h[12] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_90 (h[90],    d[62] , d[20] , d[15] , d[4] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_91 (h[91],    d[39] , d[30] , d[11] , d[6] , d[5] , d[1]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_92 (h[92],    d[17] , d[16] , h[0] , h[17] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_93 (h[93],    d[49] , d[45] , d[44] , d[38] , d[29] , d[19]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_94 (h[94],    h[5] , h[16] , h[20] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_95 (h[95],    d[53] , d[52] , d[49] , d[36] , d[26] , d[21]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_96 (h[96],    d[58] , d[42] , h[14] , h[27] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_97 (h[97],    d[49] , d[45] , d[21] , d[20] , d[12] , d[7]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_98 (h[98],    d[57] , h[15] , h[17] , 1'b0 , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_99 (h[99],    d[58] , d[48] , d[41] , d[20] , d[11] , d[8]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_100 (h[100],    d[22] , d[10] , d[8] , d[0] , h[7] , h[26]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_101 (h[101],    d[6] , d[1] , d[0] , h[11] , 1'b0 , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_102 (h[102],    d[44] , d[31] , d[18] , d[13] , d[8] , d[7]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_103 (h[103],    d[10] , d[6] , d[2] , d[1] , h[5] , 1'b0);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_104 (h[104],    d[62] , d[50] , d[47] , d[30] , d[24] , d[15]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_105 (h[105],    d[36] , d[29] , d[28] , d[4] , h[4] , h[17]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_106 (h[106],    d[63] , d[61] , d[46] , d[44] , d[41] , d[40]);   // used by 1
alt_ntrlkn_12l_10g_xor6 hx_107 (h[107],    d[63] , d[58] , d[56] , d[39] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_108 (h[108],    d[59] , d[50] , d[29] , d[24] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_109 (h[109],    d[35] , d[27] , d[1] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_110 (h[110],    d[61] , d[48] , d[42] , d[28] , 1'b0 , 1'b0);   // used by 4
alt_ntrlkn_12l_10g_xor6 hx_111 (h[111],    d[61] , d[51] , d[7] , 1'b0 , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_112 (h[112],    d[58] , d[56] , d[28] , d[24] , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_113 (h[113],    d[45] , d[38] , d[13] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_114 (h[114],    d[60] , d[33] , d[16] , 1'b0 , 1'b0 , 1'b0);   // used by 2
alt_ntrlkn_12l_10g_xor6 hx_115 (h[115],    d[59] , d[22] , d[19] , d[11] , 1'b0 , 1'b0);   // used by 3
alt_ntrlkn_12l_10g_xor6 hx_116 (h[116],    d[46] , d[16] , d[5] , d[0] , 1'b0 , 1'b0);   // used by 3
endmodule
