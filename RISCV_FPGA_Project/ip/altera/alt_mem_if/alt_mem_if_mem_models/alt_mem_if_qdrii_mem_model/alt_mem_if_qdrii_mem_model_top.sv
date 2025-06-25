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

module alt_mem_if_qdrii_mem_model_top #(
	parameter DEVICE_DEPTH = 1,
	DEVICE_WIDTH = 1,

	MEM_IF_READ_DQS_WIDTH = 1,
	MEM_IF_DM_WIDTH = 4,
	MEM_IF_DQ_WIDTH = 36,
	MEM_IF_WRITE_DQS_WIDTH = 1,
	MEM_IF_ADDR_WIDTH = 19,
	MEM_IF_CS_WIDTH = 1,
	MEM_IF_CONTROL_WIDTH = 1,

	MEM_EMULATED_READ_GROUPS = 0,

	MEM_BURST_LENGTH = 4,
	MEM_T_RL = "2.0",
	MEM_T_WL = 1,
	
	MEM_USE_DENALI_MODEL = 0,
	QDRII_PLUS_MODE = 1,
	MEM_DENALI_SOMA_FILE = "qdrii.soma",
	MEM_VERBOSE = 1,

	MEM_GUARANTEED_WRITE_INIT = 0,
	MEM_SUPPRESS_CMD_TIMING_ERROR = 0
)(
	mem_a,
	mem_bws_n,
	mem_cq,
	mem_cqn,
	mem_d,
	mem_k,
	mem_k_n,
	mem_q,
	mem_rps_n,
	mem_wps_n,
	mem_doff_n
);

input	[MEM_IF_ADDR_WIDTH-1:0]	mem_a; 
input	[MEM_IF_DM_WIDTH-1:0]	mem_bws_n;
output   [MEM_IF_READ_DQS_WIDTH-1:0] mem_cq;
output   [MEM_IF_READ_DQS_WIDTH-1:0] mem_cqn;
input   [MEM_IF_DQ_WIDTH-1:0] mem_d;
input   [MEM_IF_WRITE_DQS_WIDTH-1:0] mem_k;
input   [MEM_IF_WRITE_DQS_WIDTH-1:0] mem_k_n;
output   [MEM_IF_DQ_WIDTH-1:0] mem_q;
input [MEM_IF_CS_WIDTH-1:0] mem_rps_n;
input [MEM_IF_CS_WIDTH-1:0] mem_wps_n;
input [MEM_IF_CONTROL_WIDTH-1:0] mem_doff_n;


wire	[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS-1:0]	mem_cq_device;
wire	[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS-1:0]	mem_cqn_device;

generate
genvar depth;
genvar width;
for (depth = 0; depth < DEVICE_DEPTH; depth = depth + 1)
begin : depth_gen
	for (width = 0; width < DEVICE_WIDTH; width = width + 1)
	begin : width_gen

		if (MEM_USE_DENALI_MODEL == 1)
			if (QDRII_PLUS_MODE == 1)

				begin : denali_qdriiplus_model
					denali_qdriiplus_mem_model mem (
						.a			(mem_a),
						.bwsbar		(mem_bws_n[MEM_IF_DM_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DM_WIDTH/DEVICE_WIDTH*width]),
						.cq			(mem_cq_device[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*width]),
						.cqbar		(mem_cqn_device[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*width]),
						.d			(mem_d[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
						.k			(mem_k[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
						.kbar		(mem_k_n[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
						.q			(mem_q[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
						.rpsbar		(mem_rps_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
						.wpsbar		(mem_wps_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
						.qvld		(),
						.doffbar	(mem_doff_n)
					);
					defparam mem.MEM_CONTROL_WIDTH		= MEM_IF_CONTROL_WIDTH;
					defparam mem.MEM_ADDR_WIDTH		= MEM_IF_ADDR_WIDTH;
					defparam mem.MEM_DM_WIDTH		= MEM_IF_DM_WIDTH / DEVICE_WIDTH;
					defparam mem.MEM_READ_DQS_WIDTH	= MEM_IF_READ_DQS_WIDTH / MEM_EMULATED_READ_GROUPS / DEVICE_WIDTH;
					defparam mem.MEM_WRITE_DQS_WIDTH	= MEM_IF_WRITE_DQS_WIDTH / DEVICE_WIDTH;
					defparam mem.MEM_DQ_WIDTH			= MEM_IF_DQ_WIDTH / DEVICE_WIDTH;
					defparam mem.memory_spec			= MEM_DENALI_SOMA_FILE;
					defparam mem.MEM_BURST_LENGTH		= MEM_BURST_LENGTH;
				end
				
			else
			
				begin : denali_qdrii_model
					denali_qdrii_mem_model mem (
						.a			(mem_a),
						.bwsbar		(mem_bws_n[MEM_IF_DM_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DM_WIDTH/DEVICE_WIDTH*width]),
						.cq			(mem_cq_device[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*width]),
						.cqbar		(mem_cqn_device[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*width]),
						.d			(mem_d[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
						.k			(mem_k[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
						.kbar		(mem_k_n[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
						.q			(mem_q[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
						.rpsbar		(mem_rps_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
						.wpsbar		(mem_wps_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
						.c			({(MEM_IF_READ_DQS_WIDTH / DEVICE_WIDTH){1'b1}}),
						.cbar		({(MEM_IF_READ_DQS_WIDTH / DEVICE_WIDTH){1'b1}}),
						.doffbar	(mem_doff_n)
					);
					defparam mem.MEM_CONTROL_WIDTH		= MEM_IF_CONTROL_WIDTH;
					defparam mem.MEM_ADDR_WIDTH		= MEM_IF_ADDR_WIDTH;
					defparam mem.MEM_DM_WIDTH		= MEM_IF_DM_WIDTH / DEVICE_WIDTH;
					defparam mem.MEM_READ_DQS_WIDTH	= MEM_IF_READ_DQS_WIDTH / MEM_EMULATED_READ_GROUPS / DEVICE_WIDTH;
					defparam mem.MEM_WRITE_DQS_WIDTH	= MEM_IF_WRITE_DQS_WIDTH / DEVICE_WIDTH;
					defparam mem.MEM_DQ_WIDTH			= MEM_IF_DQ_WIDTH / DEVICE_WIDTH;
					defparam mem.memory_spec			= MEM_DENALI_SOMA_FILE;
					defparam mem.MEM_BURST_LENGTH		= MEM_BURST_LENGTH;
				end
				
		else
			begin : generic_model
				alt_mem_if_qdrii_mem_model mem (
					.mem_a		(mem_a),
					.mem_bws_n	(mem_bws_n[MEM_IF_DM_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DM_WIDTH/DEVICE_WIDTH*width]),
					.mem_cq		(mem_cq_device[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*width]),
					.mem_cqn	(mem_cqn_device[MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*(width+1)-1:MEM_IF_READ_DQS_WIDTH/MEM_EMULATED_READ_GROUPS/DEVICE_WIDTH*width]),
					.mem_d		(mem_d[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
					.mem_k		(mem_k[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
					.mem_k_n	(mem_k_n[MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_WRITE_DQS_WIDTH/DEVICE_WIDTH*width]),
					.mem_q		(mem_q[MEM_IF_DQ_WIDTH/DEVICE_WIDTH*(width+1)-1:MEM_IF_DQ_WIDTH/DEVICE_WIDTH*width]),
					.mem_rps_n	(mem_rps_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
					.mem_wps_n	(mem_wps_n[MEM_IF_CS_WIDTH/DEVICE_DEPTH*(depth+1)-1:MEM_IF_CS_WIDTH/DEVICE_DEPTH*depth]),
					.mem_doff_n	(mem_doff_n)
				);
				defparam mem.MEM_ADDR_WIDTH		= MEM_IF_ADDR_WIDTH;
				defparam mem.MEM_DM_WIDTH		= MEM_IF_DM_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_READ_DQS_WIDTH	= MEM_IF_READ_DQS_WIDTH / MEM_EMULATED_READ_GROUPS / DEVICE_WIDTH;
				defparam mem.MEM_WRITE_DQS_WIDTH	= MEM_IF_WRITE_DQS_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_DQ_WIDTH			= MEM_IF_DQ_WIDTH / DEVICE_WIDTH;
				defparam mem.MEM_T_RL				= MEM_T_RL;
				defparam mem.MEM_T_WL				= MEM_T_WL;
				defparam mem.MEM_BURST_LENGTH		= MEM_BURST_LENGTH;
				defparam mem.MEM_VERBOSE		= MEM_VERBOSE;

				defparam mem.MEM_GUARANTEED_WRITE_INIT		= MEM_GUARANTEED_WRITE_INIT;
				defparam mem.MEM_DEPTH_IDX 			= depth;
				defparam mem.MEM_WIDTH_IDX 			= width;
				defparam mem.MEM_SUPPRESS_CMD_TIMING_ERROR = MEM_SUPPRESS_CMD_TIMING_ERROR;
			end
	end
end
endgenerate




generate
genvar read_group;
	if (MEM_EMULATED_READ_GROUPS > 1) begin
		for (read_group = 0; read_group < MEM_IF_READ_DQS_WIDTH; read_group = read_group + 1)
		begin : read_emulation_gen
			assign mem_cq[read_group] = mem_cq_device[read_group/MEM_EMULATED_READ_GROUPS];
			assign mem_cqn[read_group] = mem_cqn_device[read_group/MEM_EMULATED_READ_GROUPS];
		end
	end
	else begin
		assign mem_cq = mem_cq_device;
		assign mem_cqn = mem_cqn_device;
	end
endgenerate

endmodule
