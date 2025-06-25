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


module altera_rldram3_board_delay_model_bridge_top_no_ifdef_params 
    # (parameter MEM_IF_CLK_EN_WIDTH = 1,
	MEM_IF_WRITE_DQS_WIDTH = 1,
	MEM_IF_DM_WIDTH = 1,
	MEM_IF_DQ_WIDTH = 18,
	MEM_IF_READ_DQS_WIDTH = 2,
	MEM_IF_BANKADDR_WIDTH = 3,
	MEM_IF_ADDR_WIDTH = 20,
	MEM_IF_CS_WIDTH = 1
	)                    
	(

	memory_in_mem_a,
	memory_in_mem_ba,
	memory_in_mem_ck,
	memory_in_mem_ck_n,
	memory_in_mem_cs_n,
	memory_in_mem_dk,
	memory_in_mem_dk_n,
	memory_in_mem_we_n,
	memory_in_mem_reset_n,
	memory_in_mem_dm,
	memory_in_mem_dq,
	memory_in_mem_ref_n,
	memory_out_mem_qk,
	memory_out_mem_qk_n,

	memory_0_mem_a,
	memory_0_mem_ba,
	memory_0_mem_ck,
	memory_0_mem_ck_n,
	memory_0_mem_cs_n,
	memory_0_mem_dk,
	memory_0_mem_dk_n,
	memory_0_mem_we_n,
	memory_0_mem_reset_n,
	memory_0_mem_dm,
	memory_0_mem_dq,
	memory_0_mem_qk,
	memory_0_mem_qk_n,
	memory_0_mem_ref_n,

	memory_1_mem_a,
	memory_1_mem_ba,
	memory_1_mem_ck,
	memory_1_mem_ck_n,
	memory_1_mem_cs_n,
	memory_1_mem_dk,
	memory_1_mem_dk_n,
	memory_1_mem_we_n,
	memory_1_mem_reset_n,
	memory_1_mem_dm,
	memory_1_mem_dq,
	memory_1_mem_qk,
	memory_1_mem_qk_n,
	memory_1_mem_ref_n,

	memory_2_mem_a,
	memory_2_mem_ba,
	memory_2_mem_ck,
	memory_2_mem_ck_n,
	memory_2_mem_cs_n,
	memory_2_mem_dk,
	memory_2_mem_dk_n,
	memory_2_mem_we_n,
	memory_2_mem_reset_n,
	memory_2_mem_dm,
	memory_2_mem_dq,
	memory_2_mem_qk,
	memory_2_mem_qk_n,
	memory_2_mem_ref_n,

	memory_3_mem_a,
	memory_3_mem_ba,
	memory_3_mem_ck,
	memory_3_mem_ck_n,
	memory_3_mem_cs_n,
	memory_3_mem_dk,
	memory_3_mem_dk_n,
	memory_3_mem_we_n,
	memory_3_mem_reset_n,
	memory_3_mem_dm,
	memory_3_mem_dq,
	memory_3_mem_qk,
	memory_3_mem_qk_n,
	memory_3_mem_ref_n,

	memory_4_mem_a,
	memory_4_mem_ba,
	memory_4_mem_ck,
	memory_4_mem_ck_n,
	memory_4_mem_cs_n,
	memory_4_mem_dk,
	memory_4_mem_dk_n,
	memory_4_mem_we_n,
	memory_4_mem_reset_n,
	memory_4_mem_dm,
	memory_4_mem_dq,
	memory_4_mem_qk,
	memory_4_mem_qk_n,
	memory_4_mem_ref_n,
	
	memory_5_mem_a,
	memory_5_mem_ba,
	memory_5_mem_ck,
	memory_5_mem_ck_n,
	memory_5_mem_cs_n,
	memory_5_mem_dk,
	memory_5_mem_dk_n,
	memory_5_mem_we_n,
	memory_5_mem_reset_n,
	memory_5_mem_dm,
	memory_5_mem_dq,
	memory_5_mem_qk,
	memory_5_mem_qk_n,
	memory_5_mem_ref_n,
	
	memory_6_mem_a,
	memory_6_mem_ba,
	memory_6_mem_ck,
	memory_6_mem_ck_n,
	memory_6_mem_cs_n,
	memory_6_mem_dk,
	memory_6_mem_dk_n,
	memory_6_mem_we_n,
	memory_6_mem_reset_n,
	memory_6_mem_dm,
	memory_6_mem_dq,
	memory_6_mem_qk,
	memory_6_mem_qk_n,
	memory_6_mem_ref_n,

	memory_7_mem_a,
	memory_7_mem_ba,
	memory_7_mem_ck,
	memory_7_mem_ck_n,
	memory_7_mem_cs_n,
	memory_7_mem_dk,
	memory_7_mem_dk_n,
	memory_7_mem_we_n,
	memory_7_mem_reset_n,
	memory_7_mem_dm,
	memory_7_mem_dq,
	memory_7_mem_qk,
	memory_7_mem_qk_n,
	memory_7_mem_ref_n,

);

input	[MEM_IF_ADDR_WIDTH - 1:0]	memory_in_mem_a;
input	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_in_mem_ba;
input	 	memory_in_mem_ck;
input	 	memory_in_mem_ck_n;
input	[MEM_IF_CS_WIDTH - 1:0] 	memory_in_mem_cs_n;
input	 	memory_in_mem_we_n;
input					memory_in_mem_reset_n;
input					memory_in_mem_ref_n;
input	[MEM_IF_DM_WIDTH - 1:0] 	memory_in_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_in_mem_dq;
input	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_in_mem_dk;
input	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_in_mem_dk_n;
output   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_out_mem_qk;
output   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_out_mem_qk_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_0_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_0_mem_ba;
output	 	memory_0_mem_ck;
output	 	memory_0_mem_ck_n;
output	 	memory_0_mem_cs_n;
output	 	memory_0_mem_we_n;
output					memory_0_mem_reset_n;
output					memory_0_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_0_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_0_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_0_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_0_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_0_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_0_mem_qk_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_1_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_1_mem_ba;
output	 	memory_1_mem_ck;
output	 	memory_1_mem_ck_n;
output	 	memory_1_mem_cs_n;
output	 	memory_1_mem_we_n;
output					memory_1_mem_reset_n;
output					memory_1_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_1_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_1_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_1_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_1_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_1_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_1_mem_qk_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_2_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_2_mem_ba;
output	 	memory_2_mem_ck;
output	 	memory_2_mem_ck_n;
output	 	memory_2_mem_cs_n;
output	 	memory_2_mem_we_n;
output					memory_2_mem_reset_n;
output					memory_2_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_2_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_2_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_2_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_2_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_2_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_2_mem_qk_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_3_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_3_mem_ba;
output	 	memory_3_mem_ck;
output	 	memory_3_mem_ck_n;
output	 	memory_3_mem_cs_n;
output	 	memory_3_mem_we_n;
output					memory_3_mem_reset_n;
output					memory_3_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_3_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_3_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_3_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_3_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_3_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_3_mem_qk_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_4_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_4_mem_ba;
output	 	memory_4_mem_ck;
output	 	memory_4_mem_ck_n;
output	 	memory_4_mem_cs_n;
output	 	memory_4_mem_we_n;
output					memory_4_mem_reset_n;
output					memory_4_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_4_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_4_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_4_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_4_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_4_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_4_mem_qk_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_5_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_5_mem_ba;
output	 	memory_5_mem_ck;
output	 	memory_5_mem_ck_n;
output	 	memory_5_mem_cs_n;
output	 	memory_5_mem_we_n;
output					memory_5_mem_reset_n;
output					memory_5_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_5_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_5_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_5_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_5_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_5_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_5_mem_qk_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_6_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_6_mem_ba;
output	 	memory_6_mem_ck;
output	 	memory_6_mem_ck_n;
output	 	memory_6_mem_cs_n;
output	 	memory_6_mem_we_n;
output					memory_6_mem_reset_n;
output					memory_6_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_6_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_6_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_6_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_6_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_6_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_6_mem_qk_n;

output	[MEM_IF_ADDR_WIDTH - 1:0]	memory_7_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]	memory_7_mem_ba;
output	 	memory_7_mem_ck;
output	 	memory_7_mem_ck_n;
output	 	memory_7_mem_cs_n;
output	 	memory_7_mem_we_n;
output					memory_7_mem_reset_n;
output					memory_7_mem_ref_n;
output	[MEM_IF_DM_WIDTH - 1:0] 	memory_7_mem_dm;
inout   [MEM_IF_DQ_WIDTH - 1:0]		memory_7_mem_dq;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_7_mem_dk;
output	[MEM_IF_WRITE_DQS_WIDTH-1:0]	memory_7_mem_dk_n;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_7_mem_qk;
input   [MEM_IF_READ_DQS_WIDTH-1:0]	memory_7_mem_qk_n;

alias memory_in_mem_a = memory_0_mem_a = memory_1_mem_a = memory_2_mem_a = memory_3_mem_a = memory_4_mem_a = memory_5_mem_a = memory_6_mem_a = memory_7_mem_a;
alias memory_in_mem_ba = memory_0_mem_ba = memory_1_mem_ba = memory_2_mem_ba = memory_3_mem_ba = memory_4_mem_ba = memory_5_mem_ba = memory_6_mem_ba = memory_7_mem_ba;
alias memory_in_mem_ck = memory_0_mem_ck = memory_1_mem_ck = memory_2_mem_ck = memory_3_mem_ck = memory_4_mem_ck = memory_5_mem_ck = memory_6_mem_ck = memory_7_mem_ck;
alias memory_in_mem_ck_n = memory_0_mem_ck_n = memory_1_mem_ck_n = memory_2_mem_ck_n = memory_3_mem_ck_n = memory_4_mem_ck_n = memory_5_mem_ck_n = memory_6_mem_ck_n = memory_7_mem_ck_n;
alias memory_in_mem_we_n = memory_0_mem_we_n = memory_1_mem_we_n = memory_2_mem_we_n = memory_3_mem_we_n = memory_4_mem_we_n = memory_5_mem_we_n = memory_6_mem_we_n = memory_7_mem_we_n;
alias memory_in_mem_reset_n = memory_0_mem_reset_n = memory_1_mem_reset_n = memory_2_mem_reset_n = memory_3_mem_reset_n = memory_4_mem_reset_n = memory_5_mem_reset_n = memory_6_mem_reset_n = memory_7_mem_reset_n;
alias memory_in_mem_dm = memory_0_mem_dm = memory_1_mem_dm = memory_2_mem_dm = memory_3_mem_dm = memory_4_mem_dm = memory_5_mem_dm = memory_6_mem_dm = memory_7_mem_dm;
alias memory_in_mem_dq = memory_0_mem_dq = memory_1_mem_dq = memory_2_mem_dq = memory_3_mem_dq = memory_4_mem_dq = memory_5_mem_dq = memory_6_mem_dq = memory_7_mem_dq;
alias memory_in_mem_dk_n = memory_0_mem_dk_n = memory_1_mem_dk_n = memory_2_mem_dk_n = memory_3_mem_dk_n = memory_4_mem_dk_n = memory_5_mem_dk_n = memory_6_mem_dk_n = memory_7_mem_dk_n;
alias memory_in_mem_dk = memory_0_mem_dk = memory_1_mem_dk = memory_2_mem_dk = memory_3_mem_dk = memory_4_mem_dk = memory_5_mem_dk = memory_6_mem_dk = memory_7_mem_dk;
alias memory_in_mem_ref_n = memory_0_mem_ref_n = memory_1_mem_ref_n = memory_2_mem_ref_n = memory_3_mem_ref_n = memory_4_mem_ref_n = memory_5_mem_ref_n = memory_6_mem_ref_n = memory_7_mem_ref_n;

assign memory_out_mem_qk_n = memory_0_mem_qk_n;
assign memory_out_mem_qk = memory_0_mem_qk;
assign memory_0_mem_cs_n = memory_in_mem_cs_n;
assign memory_1_mem_cs_n = memory_in_mem_cs_n >> 1;
assign memory_2_mem_cs_n = memory_in_mem_cs_n >> 2;
assign memory_3_mem_cs_n = memory_in_mem_cs_n >> 3;
assign memory_4_mem_cs_n = memory_in_mem_cs_n >> 4;
assign memory_5_mem_cs_n = memory_in_mem_cs_n >> 5;
assign memory_6_mem_cs_n = memory_in_mem_cs_n >> 6;
assign memory_7_mem_cs_n = memory_in_mem_cs_n >> 7;

endmodule

