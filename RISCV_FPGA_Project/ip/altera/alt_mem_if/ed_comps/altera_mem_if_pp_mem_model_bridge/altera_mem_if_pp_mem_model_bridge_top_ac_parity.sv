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


module altera_mem_if_pp_mem_model_bridge_top_ac_parity (
	mem_in_mem_a,
	mem_in_mem_ba,
	mem_in_mem_ck,
	mem_in_mem_ck_n,
	mem_in_mem_cke,
	mem_in_mem_cs_n,
	mem_in_mem_ras_n,
	mem_in_mem_cas_n,
	mem_in_mem_we_n,
	mem_in_mem_reset_n,
	mem_in_mem_dq,
	mem_in_mem_dqs,
	mem_in_mem_dqs_n,
	mem_in_mem_odt,
	mem_in_mem_ac_parity,
	mem_in_mem_err_out_n,
	mem_in_mem_parity_error_n,

	mem_lhs_mem_a,
	mem_lhs_mem_ba,
	mem_lhs_mem_ck,
	mem_lhs_mem_ck_n,
	mem_lhs_mem_cke,
	mem_lhs_mem_cs_n,
	mem_lhs_mem_ras_n,
	mem_lhs_mem_cas_n,
	mem_lhs_mem_we_n,
	mem_lhs_mem_reset_n,
	mem_lhs_mem_dq,
	mem_lhs_mem_dqs,
	mem_lhs_mem_dqs_n,
	mem_lhs_mem_odt,
	mem_lhs_mem_ac_parity,
	mem_lhs_mem_err_out_n,
	mem_lhs_mem_parity_error_n,

	mem_rhs_mem_a,
	mem_rhs_mem_ba,
	mem_rhs_mem_ck,
	mem_rhs_mem_ck_n,
	mem_rhs_mem_cke,
	mem_rhs_mem_cs_n,
	mem_rhs_mem_ras_n,
	mem_rhs_mem_cas_n,
	mem_rhs_mem_we_n,
	mem_rhs_mem_reset_n,
	mem_rhs_mem_ac_parity,
	mem_rhs_mem_err_out_n,
	mem_rhs_mem_parity_error_n,
	mem_rhs_mem_dq,
	mem_rhs_mem_dqs,
	mem_rhs_mem_dqs_n,
	mem_rhs_mem_odt
);

parameter MEM_IF_CLK_EN_WIDTH = 0;
parameter MEM_IF_CK_WIDTH = 0;
parameter MEM_IF_BANKADDR_WIDTH = 0;
parameter MEM_IF_ADDR_WIDTH = 0;
parameter MEM_IF_CS_WIDTH = 0;
parameter MEM_IF_DM_WIDTH = 0;
parameter MEM_IF_CONTROL_WIDTH = 0;
parameter MEM_IF_ODT_WIDTH = 0;
parameter MEM_IF_DQS_WIDTH = 0;
parameter MEM_IF_DQ_WIDTH = 0;
parameter USE_DQS_TRACKING = 0;



input	[MEM_IF_ADDR_WIDTH - 1:0]			mem_in_mem_a;
input	[MEM_IF_BANKADDR_WIDTH - 1:0]		mem_in_mem_ba;
input	[MEM_IF_CK_WIDTH - 1:0]				mem_in_mem_ck;
input	[MEM_IF_CK_WIDTH - 1:0]				mem_in_mem_ck_n;
input	[MEM_IF_CLK_EN_WIDTH - 1:0]			mem_in_mem_cke;
input	[MEM_IF_CS_WIDTH - 1:0]				mem_in_mem_cs_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_in_mem_ras_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_in_mem_cas_n;
input	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_in_mem_we_n;
input										mem_in_mem_reset_n;
inout	[MEM_IF_DQ_WIDTH - 1:0]				mem_in_mem_dq;
inout	[MEM_IF_DQS_WIDTH - 1:0]			mem_in_mem_dqs;
inout	[MEM_IF_DQS_WIDTH - 1:0]			mem_in_mem_dqs_n;
input	[MEM_IF_ODT_WIDTH - 1:0]			mem_in_mem_odt;
input										mem_in_mem_ac_parity;
output										mem_in_mem_err_out_n;
input										mem_in_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]			mem_lhs_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]		mem_lhs_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0]				mem_lhs_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0]				mem_lhs_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH/2 - 1:0]		mem_lhs_mem_cke;
output	[MEM_IF_CS_WIDTH/2 - 1:0]			mem_lhs_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_lhs_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_lhs_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_lhs_mem_we_n;
output										mem_lhs_mem_reset_n;
inout   [MEM_IF_DQ_WIDTH/2 - 1:0]			mem_lhs_mem_dq;
inout   [MEM_IF_DQS_WIDTH/2 - 1:0]			mem_lhs_mem_dqs;
inout   [MEM_IF_DQS_WIDTH/2 - 1:0]			mem_lhs_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH/2 - 1:0] 			mem_lhs_mem_odt;
output										mem_lhs_mem_ac_parity;
input										mem_lhs_mem_err_out_n;
output										mem_lhs_mem_parity_error_n;


output	[MEM_IF_ADDR_WIDTH - 1:0]			mem_rhs_mem_a;
output	[MEM_IF_BANKADDR_WIDTH - 1:0]		mem_rhs_mem_ba;
output	[MEM_IF_CK_WIDTH - 1:0]				mem_rhs_mem_ck;
output	[MEM_IF_CK_WIDTH - 1:0]				mem_rhs_mem_ck_n;
output	[MEM_IF_CLK_EN_WIDTH/2 - 1:0]		mem_rhs_mem_cke;
output	[MEM_IF_CS_WIDTH/2 - 1:0]			mem_rhs_mem_cs_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_rhs_mem_ras_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_rhs_mem_cas_n;
output	[MEM_IF_CONTROL_WIDTH - 1:0]		mem_rhs_mem_we_n;
output										mem_rhs_mem_reset_n;
inout   [MEM_IF_DQ_WIDTH/2 - 1:0]			mem_rhs_mem_dq;
inout   [MEM_IF_DQS_WIDTH/2 - 1:0]			mem_rhs_mem_dqs;
inout   [MEM_IF_DQS_WIDTH/2 - 1:0]			mem_rhs_mem_dqs_n;
output 	[MEM_IF_ODT_WIDTH/2 - 1:0] 			mem_rhs_mem_odt;
output										mem_rhs_mem_ac_parity;
input										mem_rhs_mem_err_out_n;
output										mem_rhs_mem_parity_error_n;

genvar g;

assign mem_lhs_mem_a        = mem_in_mem_a;
assign mem_lhs_mem_ba       = mem_in_mem_ba;
assign mem_lhs_mem_ck       = mem_in_mem_ck;
assign mem_lhs_mem_ck_n     = mem_in_mem_ck_n;
assign mem_lhs_mem_ras_n    = mem_in_mem_ras_n;
assign mem_lhs_mem_cas_n    = mem_in_mem_cas_n;
assign mem_lhs_mem_we_n     = mem_in_mem_we_n;
assign mem_lhs_mem_reset_n  = mem_in_mem_reset_n;

assign mem_rhs_mem_a        = mem_in_mem_a;
assign mem_rhs_mem_ba       = mem_in_mem_ba;
assign mem_rhs_mem_ck       = mem_in_mem_ck;
assign mem_rhs_mem_ck_n     = mem_in_mem_ck_n;
assign mem_rhs_mem_ras_n    = mem_in_mem_ras_n;
assign mem_rhs_mem_cas_n    = mem_in_mem_cas_n;
assign mem_rhs_mem_we_n     = mem_in_mem_we_n;
assign mem_rhs_mem_reset_n  = mem_in_mem_reset_n;




assign mem_lhs_mem_cke = mem_in_mem_cke [MEM_IF_CLK_EN_WIDTH/2 -1 : 0];
assign mem_lhs_mem_cs_n = mem_in_mem_cs_n [MEM_IF_CS_WIDTH/2 -1 : 0];

    generate
        for (g = 0; g < MEM_IF_DQ_WIDTH/2; g = g + 1)
        begin : gen_lhs_dq
            tran inst_tran_lhs_dq(mem_lhs_mem_dq[g], mem_in_mem_dq[g]);
        end
    endgenerate

    generate
        for (g = 0; g < MEM_IF_DQS_WIDTH/2; g = g + 1)
        begin : gen_lhs_dqs
            tran inst_tran_lhs_dqs(mem_lhs_mem_dqs[g], mem_in_mem_dqs[g]);
            tran inst_tran_lhs_dqs_n(mem_lhs_mem_dqs_n[g], mem_in_mem_dqs_n[g]);
        end
    endgenerate


assign mem_lhs_mem_odt = mem_in_mem_odt [MEM_IF_ODT_WIDTH/2 - 1 : 0];

assign mem_rhs_mem_cke = mem_in_mem_cke [MEM_IF_CLK_EN_WIDTH -1 : MEM_IF_CLK_EN_WIDTH/2];
assign mem_rhs_mem_cs_n = mem_in_mem_cs_n [MEM_IF_CS_WIDTH -1 : MEM_IF_CS_WIDTH/2];
assign mem_rhs_mem_odt = mem_in_mem_odt [MEM_IF_ODT_WIDTH - 1 : MEM_IF_ODT_WIDTH/2];

    generate
        for (g = 0; g < MEM_IF_DQ_WIDTH/2; g = g + 1)
        begin : gen_rhs_dq
            tran inst_tran_rhs_dq(mem_rhs_mem_dq[g], mem_in_mem_dq[g + (MEM_IF_DQ_WIDTH/2)]);
        end
    endgenerate

    generate
        for (g = 0; g < MEM_IF_DQS_WIDTH/2; g = g + 1)
        begin : gen_rhs_dqs
            tran inst_tran_rhs_dqs(mem_rhs_mem_dqs[g], mem_in_mem_dqs[g + (MEM_IF_DQS_WIDTH/2)]);
            tran inst_tran_rhs_dqs_n(mem_rhs_mem_dqs_n[g], mem_in_mem_dqs_n[g + (MEM_IF_DQS_WIDTH/2)]);
        end
    endgenerate


	assign mem_lhs_mem_ac_parity = mem_in_mem_ac_parity;
	assign mem_rhs_mem_ac_parity = mem_in_mem_ac_parity;
	assign mem_lhs_mem_parity_error_n = mem_in_mem_parity_error_n;
	assign mem_rhs_mem_parity_error_n = mem_in_mem_parity_error_n;

	assign mem_in_mem_err_out_n = mem_lhs_mem_err_out_n & mem_rhs_mem_err_out_n;




endmodule

