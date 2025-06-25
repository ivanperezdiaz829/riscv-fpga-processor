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

module alt_mem_if_rldramii_mem_model_top #(
	parameter DEVICE_DEPTH = 1,
	DEVICE_WIDTH = 1,

	MEM_IF_WRITE_DQS_WIDTH = 1,
	MEM_IF_DM_WIDTH = 1,
	MEM_IF_DQ_WIDTH = 18,
	MEM_IF_READ_DQS_WIDTH = 2,
	MEM_IF_BANKADDR_WIDTH = 3,
	MEM_IF_ADDR_WIDTH = 20,
	MEM_IF_CS_WIDTH = 1,

	MEM_BURST_LENGTH = 4,
	MEM_VERBOSE = 1,

	MEM_USE_DENALI_MODEL = 0,
	MEM_DEVICE_MAX_ADDR_WIDTH = 21,
	MEM_DENALI_SOMA_FILE = "rldramii.soma",
	MEM_DENALI_ERR_INJECT_SWITCH = "",
	MEM_DENALI_ERR_INJECT_SEED = "",
	MEM_DENALI_ERR_INJECT_READS_PER_ERR = "",
	MEM_DENALI_ERR_INJECT_BITS = "",
	MEM_DENALI_ERR_INJECT_OCCURRENCES = "",

        MEM_DQS_TO_CLK_CAPTURE_DELAY = 0,
        MEM_CLK_TO_DQS_CAPTURE_DELAY = 0,
        MEM_GUARANTEED_WRITE_INIT = 0
)(
	mem_a,
	mem_ba,
	mem_ck,
	mem_ck_n,
	mem_cs_n,
	mem_dk,
	mem_dk_n,
	mem_dm,
	mem_dq,
	mem_qk,
	mem_qk_n,
	mem_ref_n,
	mem_we_n
);

input	[MEM_IF_ADDR_WIDTH-1:0]	mem_a; 
input	[MEM_IF_BANKADDR_WIDTH-1:0]	mem_ba;
input	mem_ck; 
input	mem_ck_n;
input	[MEM_IF_CS_WIDTH-1:0] mem_cs_n; 
input	[MEM_IF_WRITE_DQS_WIDTH-1:0]	mem_dk; 
input	[MEM_IF_WRITE_DQS_WIDTH-1:0]	mem_dk_n; 
input	[MEM_IF_DM_WIDTH-1:0]	mem_dm; 
inout   [MEM_IF_DQ_WIDTH-1:0]	mem_dq; 
output logic [MEM_IF_READ_DQS_WIDTH-1:0]	mem_qk; 
output logic [MEM_IF_READ_DQS_WIDTH-1:0]	mem_qk_n; 
input	mem_ref_n; 
input	mem_we_n;


generate
genvar depth;
genvar width;
for (depth = 0; depth < DEVICE_DEPTH; depth = depth + 1)
begin : depth_gen
	for (width = 0; width < DEVICE_WIDTH; width = width + 1)
	begin : width_gen
		
		if (MEM_USE_DENALI_MODEL == 1)
			begin : denali_model
				wire [MEM_DEVICE_MAX_ADDR_WIDTH-1:0] denali_mem_a;
				assign denali_mem_a[MEM_IF_ADDR_WIDTH-1:0] = mem_a;
		
				denali_rldramii_mem_model mem (
					.a			(denali_mem_a),
					.ba			(mem_ba),
					.ck			(mem_ck),
					.ckbar		(mem_ck_n),
					.csbar		(mem_cs_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
					.dk			(mem_dk[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
					.dkbar		(mem_dk_n[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
					.dm			(mem_dm[MEM_IF_DM_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DM_WIDTH/DEVICE_WIDTH*width]),
					.dq			(mem_dq[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
					.qk			(mem_qk[MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*width]),
					.qkbar		(mem_qk_n[MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*width]),
					.refbar		(mem_ref_n),
					.webar		(mem_we_n),
					.qvld		(),
					.tck		(1'b0),
					.tms		(1'b0),
					.tdi		(1'b0),
					.tdo		(),
					.ZQ			()
				);
				defparam mem.MEM_BANKADDR_WIDTH		= MEM_IF_BANKADDR_WIDTH;
				defparam mem.MEM_ADDR_WIDTH			= MEM_DEVICE_MAX_ADDR_WIDTH;
				defparam mem.MEM_DM_WIDTH			= MEM_IF_DM_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_READ_DQS_WIDTH		= MEM_IF_READ_DQS_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_WRITE_DQS_WIDTH		= MEM_IF_WRITE_DQS_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_DQ_WIDTH				= MEM_IF_DQ_WIDTH / DEVICE_WIDTH;

				defparam mem.memory_spec				= MEM_DENALI_SOMA_FILE;
				defparam mem.MEM_BURST_LENGTH			= MEM_BURST_LENGTH;
				defparam mem.ERR_INJECT					= MEM_DENALI_ERR_INJECT_SWITCH;
				defparam mem.ERR_INJECT_SEED			= MEM_DENALI_ERR_INJECT_SEED;
				defparam mem.ERR_INJECT_READS_PER_ERR	= MEM_DENALI_ERR_INJECT_READS_PER_ERR;
				defparam mem.ERR_INJECT_BITS			= MEM_DENALI_ERR_INJECT_BITS;
				defparam mem.ERR_INJECT_OCCURRENCES		= MEM_DENALI_ERR_INJECT_OCCURRENCES;
			end
		else
			begin : generic_model
				alt_mem_if_common_rldram_mem_model_rldramii mem (
					.mem_a		(mem_a),
					.mem_ba		(mem_ba),
					.mem_ck		(mem_ck),
					.mem_ck_n	(mem_ck_n),
					.mem_cs_n	(mem_cs_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
					.mem_dk		(mem_dk[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
					.mem_dk_n	(mem_dk_n[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
					.mem_dm		(mem_dm[MEM_IF_DM_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DM_WIDTH/DEVICE_WIDTH*width]),
					.mem_dq		(mem_dq[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
					.mem_qk		(mem_qk[MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*width]),
					.mem_qk_n	(mem_qk_n[MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/DEVICE_WIDTH*width]),
					.mem_ref_n	(mem_ref_n),
					.mem_we_n	(mem_we_n)
				);
				defparam mem.MEM_BANKADDR_WIDTH	= MEM_IF_BANKADDR_WIDTH;
				defparam mem.MEM_ADDR_WIDTH		= MEM_IF_ADDR_WIDTH;
				defparam mem.MEM_DM_WIDTH		= MEM_IF_DM_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_READ_DQS_WIDTH	= MEM_IF_READ_DQS_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_WRITE_DQS_WIDTH	= MEM_IF_WRITE_DQS_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_DQ_WIDTH			= MEM_IF_DQ_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_VERBOSE			= MEM_VERBOSE;


				defparam mem.MEM_DQS_TO_CLK_CAPTURE_DELAY	= MEM_DQS_TO_CLK_CAPTURE_DELAY;
				defparam mem.MEM_CLK_TO_DQS_CAPTURE_DELAY	= MEM_CLK_TO_DQS_CAPTURE_DELAY;
				defparam mem.MEM_GUARANTEED_WRITE_INIT		= MEM_GUARANTEED_WRITE_INIT;
				defparam mem.MEM_DEPTH_IDX 			= depth;
				defparam mem.MEM_WIDTH_IDX 			= width;
			end
	end
end
endgenerate

endmodule
