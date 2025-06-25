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

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_rldramii_controller; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
module alt_rld_controller_top_ctl_bl_is_one_dec_lat_err_det_par_urfsh (
	afi_clk,
	afi_reset_n,
	avl_ready,
	avl_write_req,
	avl_read_req,
	avl_addr,
	avl_size,
	avl_wdata,
	avl_rdata_valid,
	avl_rdata,
	ref_req,
	ref_ba,
	ref_ack,
	parity_error,
	afi_addr,
	afi_ba,
	afi_cs_n,
	afi_we_n,
	afi_ref_n,
	afi_wdata_valid,
	afi_wdata,
	afi_dm,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	afi_rdata_valid,
	afi_cal_success,
	afi_cal_fail,
	local_init_done,
	local_cal_success,
	local_cal_fail
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY							= "";

parameter MEM_IF_CS_WIDTH						= 0;
// MEMORY TIMING PARAMETERS
// Bank cycle time in memory cycles
parameter MEM_T_RC								= 0;
// Write latency in memory cycles
parameter MEM_T_WL								= 0;
// Refresh interval in memory cycles
parameter MEM_T_REFI							= 0;
// Refresh interval in controller cycles
parameter CTL_T_REFI							= 0;
// DQ bus turnaround time in memory cycles
// In half rate (AFI_RATE_RATIO=2), these values are rounded up to the next odd number
parameter MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR	= 0;
parameter MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD	= 0;

// The memory burst length
parameter MEM_BURST_LENGTH						= 0;

// AFI 2.0 INTERFACE PARAMETERS
parameter AFI_ADDR_WIDTH						= 0;
parameter AFI_BANKADDR_WIDTH					= 0;
parameter AFI_CONTROL_WIDTH						= 0;
parameter AFI_CS_WIDTH							= 0;
parameter AFI_DM_WIDTH							= 0;
parameter AFI_DQ_WIDTH							= 0;
parameter AFI_WRITE_DQS_WIDTH 					= 0;
parameter AFI_RATE_RATIO    					= 0;

// CONTROLLER PARAMETERS
// For a half rate controller (AFI_RATE_RATIO=2), the burst length in the controller - equals memory burst length / 4
// For a full rate controller (AFI_RATE_RATIO=1), the burst length in the controller - equals memory burst length / 2
parameter CTL_BURST_LENGTH						= 0;
parameter CTL_ADDR_WIDTH						= 0;
parameter CTL_CHIPADDR_WIDTH					= 0;
parameter CTL_BANKADDR_WIDTH					= 0;
parameter CTL_BEATADDR_WIDTH					= 0;
parameter CTL_CONTROL_WIDTH						= 0;
parameter CTL_CS_WIDTH							= 0;

// AVALON INTERFACE PARAMETERS
parameter AVL_ADDR_WIDTH						= 0;
parameter AVL_SIZE_WIDTH						= 0;
parameter AVL_DATA_WIDTH						= 0;
parameter AVL_NUM_SYMBOLS						= 0;

parameter HR_DDIO_OUT_HAS_THREE_REGS			= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input								afi_clk;
input								afi_reset_n;

// Avalon data slave interface
output								avl_ready;
input								avl_write_req;
input								avl_read_req;
input	[AVL_ADDR_WIDTH-1:0]		avl_addr;
input	[AVL_SIZE_WIDTH-1:0]		avl_size;
input	[AVL_DATA_WIDTH-1:0]			avl_wdata;
output								avl_rdata_valid;
output	[AVL_DATA_WIDTH-1:0]			avl_rdata;

// User-controlled refresh interface
input								ref_req;
input	[CTL_BANKADDR_WIDTH-1:0]	ref_ba;
output								ref_ack;

// Parity error detection
output	[AVL_NUM_SYMBOLS-1:0]			parity_error;

// AFI 2.0 interface
output	[AFI_ADDR_WIDTH-1:0]		afi_addr;
output	[AFI_BANKADDR_WIDTH-1:0]	afi_ba;
output	[AFI_CS_WIDTH-1:0]			afi_cs_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_we_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_ref_n;
output	[AFI_WRITE_DQS_WIDTH-1:0]	afi_wdata_valid;
output	[AFI_DQ_WIDTH-1:0]			afi_wdata;
output	[AFI_DM_WIDTH-1:0]			afi_dm;

output	[AFI_RATE_RATIO-1:0]		afi_rdata_en;
output	[AFI_RATE_RATIO-1:0]		afi_rdata_en_full;

input	[AFI_DQ_WIDTH-1:0]			afi_rdata;
input	[AFI_RATE_RATIO-1:0]		afi_rdata_valid;
input								afi_cal_success;
input								afi_cal_fail;
output								local_init_done;
output								local_cal_success;
output								local_cal_fail;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

alt_rld_controller_ctl_bl_is_one_dec_lat_err_det_par_urfsh # (
	.DEVICE_FAMILY(DEVICE_FAMILY),
	.HR_DDIO_OUT_HAS_THREE_REGS(HR_DDIO_OUT_HAS_THREE_REGS),
	.MEM_IF_CS_WIDTH(MEM_IF_CS_WIDTH),
	.MEM_T_RC(MEM_T_RC),
	.MEM_T_WL(MEM_T_WL),
	.MEM_T_REFI(MEM_T_REFI),
	.CTL_T_REFI(CTL_T_REFI),
	.MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR(MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR),
	.MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD(MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD),
	.MEM_BURST_LENGTH(MEM_BURST_LENGTH),
	.AFI_ADDR_WIDTH(AFI_ADDR_WIDTH),
	.AFI_BANKADDR_WIDTH(AFI_BANKADDR_WIDTH),
	.AFI_CONTROL_WIDTH(AFI_CONTROL_WIDTH),
	.AFI_CS_WIDTH(AFI_CS_WIDTH),
	.AFI_DM_WIDTH(AFI_DM_WIDTH),
	.AFI_DQ_WIDTH(AFI_DQ_WIDTH),
	.AFI_WRITE_DQS_WIDTH(AFI_WRITE_DQS_WIDTH),
	.AFI_RATE_RATIO(AFI_RATE_RATIO),
	.CTL_BURST_LENGTH(CTL_BURST_LENGTH),
	.CTL_ADDR_WIDTH(CTL_ADDR_WIDTH),
	.CTL_CHIPADDR_WIDTH(CTL_CHIPADDR_WIDTH),
	.CTL_BANKADDR_WIDTH(CTL_BANKADDR_WIDTH),
	.CTL_BEATADDR_WIDTH(CTL_BEATADDR_WIDTH),
	.CTL_CONTROL_WIDTH(CTL_CONTROL_WIDTH),
	.CTL_CS_WIDTH(CTL_CS_WIDTH),
	.AVL_ADDR_WIDTH(AVL_ADDR_WIDTH),
	.AVL_SIZE_WIDTH(AVL_SIZE_WIDTH),
	.AVL_DATA_WIDTH(AVL_DATA_WIDTH),
	.AVL_NUM_SYMBOLS(AVL_NUM_SYMBOLS)
) controller_inst (
	.afi_clk(afi_clk),
	.afi_reset_n(afi_reset_n),
	.avl_ready(avl_ready),
	.avl_write_req(avl_write_req),
	.avl_read_req(avl_read_req),
	.avl_addr(avl_addr),
	.avl_size(avl_size),
	.avl_wdata(avl_wdata),
	.avl_rdata_valid(avl_rdata_valid),
	.avl_rdata(avl_rdata),
	.ref_req(ref_req),
	.ref_ba(ref_ba),
	.ref_ack(ref_ack),
	.parity_error(parity_error),
	.afi_addr(afi_addr),
	.afi_ba(afi_ba),
	.afi_cs_n(afi_cs_n),
	.afi_we_n(afi_we_n),
	.afi_ref_n(afi_ref_n),
	.afi_wdata_valid(afi_wdata_valid),
	.afi_wdata(afi_wdata),
	.afi_dm(afi_dm),
	.afi_rdata_en(afi_rdata_en),
	.afi_rdata_en_full(afi_rdata_en_full),
	.afi_rdata(afi_rdata),
	.afi_rdata_valid(afi_rdata_valid),
	.afi_cal_success(afi_cal_success),
	.afi_cal_fail(afi_cal_fail),
	.local_init_done(local_init_done)
);


assign local_cal_success = afi_cal_success;
assign local_cal_fail = afi_cal_fail;


endmodule

