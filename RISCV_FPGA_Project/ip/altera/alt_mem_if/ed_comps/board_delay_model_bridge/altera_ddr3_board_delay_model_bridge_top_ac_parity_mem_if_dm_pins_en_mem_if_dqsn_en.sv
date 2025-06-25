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


module altera_ddr3_board_delay_model_bridge_top_ac_parity_mem_if_dm_pins_en_mem_if_dqsn_en 
    # (parameter MEM_IF_CLK_EN_WIDTH = 1,
		MEM_IF_CK_WIDTH = 1,
		MEM_IF_BANKADDR_WIDTH = 3,
		MEM_IF_ADDR_WIDTH = 15,
		MEM_IF_ROW_ADDR_WIDTH = 15,
		MEM_IF_COL_ADDR_WIDTH = 10,
		MEM_IF_CS_WIDTH = 1,
		MEM_IF_CONTROL_WIDTH = 1,
		MEM_IF_ODT_WIDTH = 1,
		MEM_IF_DQS_WIDTH = 1,
		MEM_IF_DQ_WIDTH = 8,
       		MEM_IF_BOARD_BASE_DELAY = 10,
       		USE_DQS_TRACKING = 0,
		MEM_IF_CS_PER_RANK = 1
	)                    
	(

	memory_in_mem_a,
	memory_in_mem_ba,
	memory_in_mem_ck,
	memory_in_mem_ck_n,
	memory_in_mem_cke,
	memory_in_mem_cs_n,
	memory_in_mem_ras_n,
	memory_in_mem_cas_n,
	memory_in_mem_we_n,
	memory_in_mem_reset_n,
	memory_in_mem_dm,
	memory_in_mem_dq,
	memory_in_mem_dqs,
	memory_in_mem_dqs_n,
	memory_in_mem_odt,
        memory_in_mem_ac_parity,
        memory_in_mem_err_out_n,
        memory_in_mem_parity_error_n,

	memory_0_mem_a,
	memory_0_mem_ba,
	memory_0_mem_ck,
	memory_0_mem_ck_n,
	memory_0_mem_cke,
	memory_0_mem_cs_n,
	memory_0_mem_ras_n,
	memory_0_mem_cas_n,
	memory_0_mem_we_n,
	memory_0_mem_reset_n,
	memory_0_mem_dm,
	memory_0_mem_dq,
	memory_0_mem_dqs,
	memory_0_mem_dqs_n,
	memory_0_mem_odt,
	memory_0_mem_ac_parity,
	memory_0_mem_err_out_n,
	memory_0_mem_parity_error_n,

	memory_1_mem_a,
	memory_1_mem_ba,
	memory_1_mem_ck,
	memory_1_mem_ck_n,
	memory_1_mem_cke,
	memory_1_mem_cs_n,
	memory_1_mem_ras_n,
	memory_1_mem_cas_n,
	memory_1_mem_we_n,
	memory_1_mem_reset_n,
	memory_1_mem_dm,
	memory_1_mem_dq,
	memory_1_mem_dqs,
	memory_1_mem_dqs_n,
	memory_1_mem_odt,
	memory_1_mem_ac_parity,
	memory_1_mem_err_out_n,
	memory_1_mem_parity_error_n,

	memory_2_mem_a,
	memory_2_mem_ba,
	memory_2_mem_ck,
	memory_2_mem_ck_n,
	memory_2_mem_cke,
	memory_2_mem_cs_n,
	memory_2_mem_ras_n,
	memory_2_mem_cas_n,
	memory_2_mem_we_n,
	memory_2_mem_reset_n,
	memory_2_mem_dm,
	memory_2_mem_dq,
	memory_2_mem_dqs,
	memory_2_mem_dqs_n,
	memory_2_mem_odt,
	memory_2_mem_ac_parity,
	memory_2_mem_err_out_n,
	memory_2_mem_parity_error_n,

	memory_3_mem_a,
	memory_3_mem_ba,
	memory_3_mem_ck,
	memory_3_mem_ck_n,
	memory_3_mem_cke,
	memory_3_mem_cs_n,
	memory_3_mem_ras_n,
	memory_3_mem_cas_n,
	memory_3_mem_we_n,
	memory_3_mem_reset_n,
	memory_3_mem_dm,
	memory_3_mem_dq,
	memory_3_mem_dqs,
	memory_3_mem_dqs_n,
	memory_3_mem_odt,
	memory_3_mem_ac_parity,
	memory_3_mem_err_out_n,
	memory_3_mem_parity_error_n,

	memory_4_mem_a,
	memory_4_mem_ba,
	memory_4_mem_ck,
	memory_4_mem_ck_n,
	memory_4_mem_cke,
	memory_4_mem_cs_n,
	memory_4_mem_ras_n,
	memory_4_mem_cas_n,
	memory_4_mem_we_n,
	memory_4_mem_reset_n,
	memory_4_mem_dm,
	memory_4_mem_dq,
	memory_4_mem_dqs,
	memory_4_mem_dqs_n,
	memory_4_mem_odt,
	memory_4_mem_ac_parity,
	memory_4_mem_err_out_n,
	memory_4_mem_parity_error_n,
	
	memory_5_mem_a,
	memory_5_mem_ba,
	memory_5_mem_ck,
	memory_5_mem_ck_n,
	memory_5_mem_cke,
	memory_5_mem_cs_n,
	memory_5_mem_ras_n,
	memory_5_mem_cas_n,
	memory_5_mem_we_n,
	memory_5_mem_reset_n,
	memory_5_mem_dm,
	memory_5_mem_dq,
	memory_5_mem_dqs,
	memory_5_mem_dqs_n,
	memory_5_mem_odt,
	memory_5_mem_ac_parity,
	memory_5_mem_err_out_n,
	memory_5_mem_parity_error_n,
	
	memory_6_mem_a,
	memory_6_mem_ba,
	memory_6_mem_ck,
	memory_6_mem_ck_n,
	memory_6_mem_cke,
	memory_6_mem_cs_n,
	memory_6_mem_ras_n,
	memory_6_mem_cas_n,
	memory_6_mem_we_n,
	memory_6_mem_reset_n,
	memory_6_mem_dm,
	memory_6_mem_dq,
	memory_6_mem_dqs,
	memory_6_mem_dqs_n,
	memory_6_mem_odt,
	memory_6_mem_ac_parity,
	memory_6_mem_err_out_n,
	memory_6_mem_parity_error_n,
	
	memory_7_mem_a,
	memory_7_mem_ba,
	memory_7_mem_ck,
	memory_7_mem_ck_n,
	memory_7_mem_cke,
	memory_7_mem_cs_n,
	memory_7_mem_ras_n,
	memory_7_mem_cas_n,
	memory_7_mem_we_n,
	memory_7_mem_reset_n,
	memory_7_mem_dm,
	memory_7_mem_dq,
	memory_7_mem_dqs,
	memory_7_mem_dqs_n,
	memory_7_mem_odt,
	memory_7_mem_ac_parity,
	memory_7_mem_err_out_n,
	memory_7_mem_parity_error_n
);

input	[MEM_IF_ADDR_WIDTH - 1:0]	memory_in_mem_a;
input	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_in_mem_ba;
input	[MEM_IF_CK_WIDTH - 1:0] 	memory_in_mem_ck;
input	[MEM_IF_CK_WIDTH - 1:0] 	memory_in_mem_ck_n;
input	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_in_mem_cke;
input	[MEM_IF_CS_WIDTH - 1:0] 	memory_in_mem_cs_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_in_mem_ras_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_in_mem_cas_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_in_mem_we_n;
input					memory_in_mem_reset_n;
input	[MEM_IF_DQS_WIDTH - 1:0] 	memory_in_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_in_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_in_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_in_mem_dqs_n;
input 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_in_mem_odt;
input					memory_in_mem_ac_parity;
output					memory_in_mem_err_out_n;
input					memory_in_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_0_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_0_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_0_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_0_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_0_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_0_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_0_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_0_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_0_mem_we_n;
output					memory_0_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_0_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_0_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_0_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_0_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_0_mem_odt;
output                                  memory_0_mem_ac_parity;
input                                   memory_0_mem_err_out_n;
output                                  memory_0_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_1_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_1_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_1_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_1_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_1_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_1_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_1_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_1_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_1_mem_we_n;
output					memory_1_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_1_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_1_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_1_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_1_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_1_mem_odt;
output                                  memory_1_mem_ac_parity;
input                                   memory_1_mem_err_out_n;
output                                  memory_1_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_2_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_2_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_2_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_2_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_2_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_2_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_2_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_2_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_2_mem_we_n;
output					memory_2_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_2_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_2_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_2_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_2_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_2_mem_odt;
output                                  memory_2_mem_ac_parity;
input                                   memory_2_mem_err_out_n;
output                                  memory_2_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_3_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_3_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_3_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_3_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_3_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_3_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_3_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_3_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_3_mem_we_n;
output					memory_3_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_3_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_3_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_3_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_3_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_3_mem_odt;
output                                  memory_3_mem_ac_parity;
input                                   memory_3_mem_err_out_n;
output                                  memory_3_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_4_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_4_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_4_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_4_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_4_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_4_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_4_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_4_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_4_mem_we_n;
output					memory_4_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_4_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_4_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_4_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_4_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_4_mem_odt;
output                                  memory_4_mem_ac_parity;
input                                   memory_4_mem_err_out_n;
output                                  memory_4_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_5_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_5_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_5_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_5_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_5_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_5_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_5_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_5_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_5_mem_we_n;
output					memory_5_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_5_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_5_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_5_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_5_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_5_mem_odt;
output                                  memory_5_mem_ac_parity;
input                                   memory_5_mem_err_out_n;
output                                  memory_5_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_6_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_6_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_6_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_6_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_6_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_6_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_6_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_6_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_6_mem_we_n;
output					memory_6_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_6_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_6_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_6_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_6_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_6_mem_odt;
output                                  memory_6_mem_ac_parity;
input                                   memory_6_mem_err_out_n;
output                                  memory_6_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_7_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_7_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_7_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0] 	memory_7_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH - 1:0] 	memory_7_mem_cke;
output	[MEM_IF_CS_PER_RANK - 1:0] 	memory_7_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_7_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_7_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0] 	memory_7_mem_we_n;
output					memory_7_mem_reset_n;
output	[MEM_IF_DQS_WIDTH - 1:0] 	memory_7_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_7_mem_dq;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_7_mem_dqs;
inout   [MEM_IF_DQS_WIDTH - 1:0]	memory_7_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH - 1:0] 	memory_7_mem_odt;
output                                  memory_7_mem_ac_parity;
input                                   memory_7_mem_err_out_n;
output                                  memory_7_mem_parity_error_n;


alias memory_in_mem_a = memory_0_mem_a = memory_1_mem_a = memory_2_mem_a = memory_3_mem_a = memory_4_mem_a = memory_5_mem_a = memory_6_mem_a = memory_7_mem_a;
alias memory_in_mem_ba = memory_0_mem_ba = memory_1_mem_ba = memory_2_mem_ba = memory_3_mem_ba = memory_4_mem_ba = memory_5_mem_ba = memory_6_mem_ba = memory_7_mem_ba;
alias memory_in_mem_ck = memory_0_mem_ck = memory_1_mem_ck = memory_2_mem_ck = memory_3_mem_ck = memory_4_mem_ck = memory_5_mem_ck = memory_6_mem_ck = memory_7_mem_ck;
alias memory_in_mem_ck_n = memory_0_mem_ck_n = memory_1_mem_ck_n = memory_2_mem_ck_n = memory_3_mem_ck_n = memory_4_mem_ck_n = memory_5_mem_ck_n = memory_6_mem_ck_n = memory_7_mem_ck_n;
alias memory_in_mem_cke = memory_0_mem_cke = memory_1_mem_cke = memory_2_mem_cke = memory_3_mem_cke = memory_4_mem_cke = memory_5_mem_cke = memory_6_mem_cke = memory_7_mem_cke;
alias memory_in_mem_ras_n = memory_0_mem_ras_n = memory_1_mem_ras_n = memory_2_mem_ras_n = memory_3_mem_ras_n = memory_4_mem_ras_n = memory_5_mem_ras_n = memory_6_mem_ras_n = memory_7_mem_ras_n;
alias memory_in_mem_cas_n = memory_0_mem_cas_n = memory_1_mem_cas_n = memory_2_mem_cas_n = memory_3_mem_cas_n = memory_4_mem_cas_n = memory_5_mem_cas_n = memory_6_mem_cas_n = memory_7_mem_cas_n;
alias memory_in_mem_we_n = memory_0_mem_we_n = memory_1_mem_we_n = memory_2_mem_we_n = memory_3_mem_we_n = memory_4_mem_we_n = memory_5_mem_we_n = memory_6_mem_we_n = memory_7_mem_we_n;
alias memory_in_mem_reset_n = memory_0_mem_reset_n = memory_1_mem_reset_n = memory_2_mem_reset_n = memory_3_mem_reset_n = memory_4_mem_reset_n = memory_5_mem_reset_n = memory_6_mem_reset_n = memory_7_mem_reset_n;
alias memory_in_mem_dm = memory_0_mem_dm = memory_1_mem_dm = memory_2_mem_dm = memory_3_mem_dm = memory_4_mem_dm = memory_5_mem_dm = memory_6_mem_dm = memory_7_mem_dm;
alias memory_in_mem_dq = memory_0_mem_dq = memory_1_mem_dq = memory_2_mem_dq = memory_3_mem_dq = memory_4_mem_dq = memory_5_mem_dq = memory_6_mem_dq = memory_7_mem_dq;
alias memory_in_mem_dqs = memory_0_mem_dqs = memory_1_mem_dqs = memory_2_mem_dqs = memory_3_mem_dqs = memory_4_mem_dqs = memory_5_mem_dqs = memory_6_mem_dqs = memory_7_mem_dqs;
alias memory_in_mem_dqs_n = memory_0_mem_dqs_n = memory_1_mem_dqs_n = memory_2_mem_dqs_n = memory_3_mem_dqs_n = memory_4_mem_dqs_n = memory_5_mem_dqs_n = memory_6_mem_dqs_n = memory_7_mem_dqs_n;
alias memory_in_mem_odt = memory_0_mem_odt = memory_1_mem_odt = memory_2_mem_odt = memory_3_mem_odt = memory_4_mem_odt = memory_5_mem_odt = memory_6_mem_odt = memory_7_mem_odt;
alias memory_in_mem_ac_parity = memory_0_mem_ac_parity = memory_1_mem_ac_parity = memory_2_mem_ac_parity = memory_3_mem_ac_parity = memory_4_mem_ac_parity = memory_5_mem_ac_parity = memory_6_mem_ac_parity = memory_7_mem_ac_parity;
alias memory_in_mem_err_out_n = memory_0_mem_err_out_n = memory_1_mem_err_out_n = memory_2_mem_err_out_n = memory_3_mem_err_out_n = memory_4_mem_err_out_n = memory_5_mem_err_out_n = memory_6_mem_err_out_n = memory_7_mem_err_out_n;
alias memory_in_mem_parity_error_n = memory_0_mem_parity_error_n = memory_1_mem_parity_error_n = memory_2_mem_parity_error_n = memory_3_mem_parity_error_n = memory_4_mem_parity_error_n = memory_5_mem_parity_error_n = memory_6_mem_parity_error_n = memory_7_mem_parity_error_n;

assign memory_0_mem_cs_n = memory_in_mem_cs_n;
assign memory_1_mem_cs_n = memory_in_mem_cs_n >> MEM_IF_CS_PER_RANK;
assign memory_2_mem_cs_n = memory_in_mem_cs_n >> 2 * MEM_IF_CS_PER_RANK;
assign memory_3_mem_cs_n = memory_in_mem_cs_n >> 3 * MEM_IF_CS_PER_RANK;
assign memory_4_mem_cs_n = memory_in_mem_cs_n >> 4 * MEM_IF_CS_PER_RANK;
assign memory_5_mem_cs_n = memory_in_mem_cs_n >> 5 * MEM_IF_CS_PER_RANK;
assign memory_6_mem_cs_n = memory_in_mem_cs_n >> 6 * MEM_IF_CS_PER_RANK;
assign memory_7_mem_cs_n = memory_in_mem_cs_n >> 7 * MEM_IF_CS_PER_RANK;

endmodule

