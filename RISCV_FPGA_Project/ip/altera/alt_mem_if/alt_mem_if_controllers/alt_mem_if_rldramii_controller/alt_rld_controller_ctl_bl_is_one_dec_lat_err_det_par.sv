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


//////////////////////////////////////////////////////////////////////////////
// This is the top level module of the RLDRAM II Memory Controller.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_rld_controller_ctl_bl_is_one_dec_lat_err_det_par (
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
	local_init_done
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
parameter AFI_WRITE_DQS_WIDTH					= 0;
parameter AFI_RATE_RATIO						= 0;

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
// BEGIN LOCALPARAM SECTION

// Avalon address mapping
localparam CTL_BEATADDR_INDEX					= 0;
localparam CTL_BANKADDR_INDEX					= CTL_BEATADDR_INDEX + CTL_BEATADDR_WIDTH;
localparam CTL_ADDR_INDEX						= CTL_BANKADDR_INDEX + CTL_BANKADDR_WIDTH;
localparam CTL_CHIPADDR_INDEX					= CTL_ADDR_INDEX + CTL_ADDR_WIDTH;

// The number of banks that can be individually accessible by the controller
localparam CHIP_BANK_ID_WIDTH					= CTL_CHIPADDR_WIDTH + CTL_BANKADDR_WIDTH;
localparam NUM_BANKS							= 2 ** CHIP_BANK_ID_WIDTH;
localparam NUM_BANKS_PER_CHIP					= 2 ** CTL_BANKADDR_WIDTH;

// Timing properties in controller cycles
localparam CTL_T_WL_HR = (HR_DDIO_OUT_HAS_THREE_REGS == 1) ? ((MEM_T_WL / 2) - 1) : (((MEM_T_WL + 1) / 2) - 1);
localparam CTL_T_WL_FR = (DEVICE_FAMILY != "Stratix V" && DEVICE_FAMILY != "Arria V GZ") ? MEM_T_WL : (MEM_T_WL - 1);
localparam CTL_T_WL = (AFI_RATE_RATIO == 2) ? CTL_T_WL_HR : CTL_T_WL_FR;
localparam CTL_T_RC = (AFI_RATE_RATIO == 2) ? ((MEM_T_RC + 1) / 2) : MEM_T_RC;

// Overall latency in the controller, used to determine write data FIFO size
localparam CTL_LATENCY							= 1;

// Maximum write latency in controller cycles
localparam CTL_MAX_WRITE_LATENCY				= CTL_T_WL;

// Maximum read latency in controller cycles including PHY and memory latencies
//This is a pessimistic estimate.  In simulation, the actual read latency is 14 cycles.
localparam CTL_MAX_READ_LATENCY					= 18;

// Configure FIFO operation mode for speed and efficiency.
// WDATA_FIFO_SHOW_AHEAD and REGISTER_WDATA_VALID_FIFO_OUT affects
// efficiency by means of the maximum allowed delay of the arrival
// of the second command to be able to merge into the first command.
// In most cases, accesses to consecutive addresses are issued by
// the master on consecutive cycles, therefore it is recommended to
// target for speed with a shorter maximum allowed delay.
// The following parameters can be modified conditionally:
// WDATA_FIFO_SHOW_AHEAD must be set to ON when CTL_T_WL is 1,
// otherwise, set to ON for efficiency and OFF for speed.
// REGISTER_WDATA_VALID_FIFO_OUT must be set to ON when AFI_WDATA_REQ_DELAY
// is 1, otherwise, set to OFF for efficiency and ON for speed.
// AFI_WDATA_REQ_DELAY should NOT be modified.
localparam WDATA_FIFO_ENABLE_PIPELINE			= (CTL_T_WL > 1) ? "ON" : "OFF";
localparam WDATA_FIFO_SHOW_AHEAD				= (CTL_T_WL > 2) ? "OFF" : "ON";
localparam AFI_WDATA_REQ_DELAY					= (WDATA_FIFO_SHOW_AHEAD == "ON") ? CTL_T_WL : (CTL_T_WL - 1);
localparam REGISTER_WDATA_VALID_FIFO_OUT		= (AFI_WDATA_REQ_DELAY > 1) ? "ON" : "OFF";

// Write data FIFO latency
localparam WDATA_FIFO_LATENCY = ((WDATA_FIFO_SHOW_AHEAD == "OFF") ? 1 : 0) +
								((REGISTER_WDATA_VALID_FIFO_OUT == "ON") ? 1 : 0);

// The number of resynchronized resets to create at this level
localparam NUM_CONTROLLER_RESET = 7;

// END LOCALPARAM SECTION
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
output	[AFI_RATE_RATIO-1:0]							afi_rdata_en;
output	[AFI_RATE_RATIO-1:0]							afi_rdata_en_full;
input	[AFI_DQ_WIDTH-1:0]			afi_rdata;
input	[AFI_RATE_RATIO-1:0]							afi_rdata_valid;
input								afi_cal_success;
input								afi_cal_fail;
output								local_init_done;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Resynchronized reset signal
wire	[NUM_CONTROLLER_RESET-1:0]	resync_afi_reset_n;

// User interface module signals
wire								cmd0_write_req;
wire								cmd0_read_req;
wire	[AVL_ADDR_WIDTH-1:0]		cmd0_avl_addr;
wire								cmd0_addr_can_merge;
wire								cmd1_write_req;
wire								cmd1_read_req;
wire	[AVL_ADDR_WIDTH-1:0]		cmd1_avl_addr;
wire								cmd1_addr_can_merge;
wire								data_if_wdata_valid;
wire	[AVL_DATA_WIDTH-1:0]			data_if_wdata;
wire								data_if_rdata_valid;
wire	[AVL_DATA_WIDTH-1:0]			data_if_rdata;
wire	[AFI_DQ_WIDTH-1:0]			data_logic_wdata_in;
wire	[AFI_DQ_WIDTH-1:0]			data_logic_rdata_out;

// PHY interface module signals
wire								wdata_req;
wire	[AFI_DQ_WIDTH-1:0]			wdata;
wire								wdata_valid;
wire								rdata_valid;
wire	[AFI_DQ_WIDTH-1:0]			rdata;

// Refresh module signals
wire								aref_req;
wire	[CTL_BANKADDR_WIDTH-1:0]	aref_req_bank_addr;

// State machine command outputs
wire								do_write;
wire								do_read;
wire								do_aref;
wire								merge_write;
wire								merge_read;
wire	[CTL_BANKADDR_WIDTH-1:0]	aref_bank_addr;

// Timer outputs
wire	[NUM_BANKS-1:0]				can_access;
wire	[NUM_BANKS_PER_CHIP-1:0]	can_aref;

// The chip and beat addresses are one-hot encoded.  They identify which
// chip and which beat of the burst is addressed by the Avalon address.
logic	[CTL_CS_WIDTH-1:0]			cmd0_chip_addr;
logic	[CTL_BURST_LENGTH-1:0]		cmd0_beat_addr;
wire	[CTL_BANKADDR_WIDTH-1:0] 	cmd0_bank_addr;
wire	[CTL_ADDR_WIDTH-1:0]		cmd0_addr;

// Chip-bank ID identifies which chip and which bank is addressed by the Avalon address
logic	[CHIP_BANK_ID_WIDTH-1:0]	cmd0_chip_bank_id;
logic	[CHIP_BANK_ID_WIDTH-1:0]	cmd1_chip_bank_id;

// Create a synchronized version of the reset against the controller clock
memctl_reset_sync	ureset_afi_clk(
	.reset_n		(afi_reset_n),
	.clk			(afi_clk),
	.reset_n_sync	(resync_afi_reset_n)
);
defparam ureset_afi_clk.NUM_RESET_OUTPUT = NUM_CONTROLLER_RESET;

// Map Avalon address into memory address and bank address
assign cmd0_addr = cmd0_avl_addr[CTL_ADDR_INDEX +: CTL_ADDR_WIDTH];
assign cmd0_bank_addr = cmd0_avl_addr[CTL_BANKADDR_INDEX +: CTL_BANKADDR_WIDTH];

// Map Avalon address into one-hot beat address
always_comb
begin
	cmd0_beat_addr <= 1'b1;
end

// Map Avalon address into one-hot chip address
// Chip-bank ID is concatenated chip and bank addresses
generate
if (MEM_IF_CS_WIDTH == 1) begin
	always_comb
	begin
	cmd0_chip_addr <= 1'b1;
	cmd0_chip_bank_id <= cmd0_avl_addr[CTL_BANKADDR_INDEX +: CTL_BANKADDR_WIDTH];
	cmd1_chip_bank_id <= cmd1_avl_addr[CTL_BANKADDR_INDEX +: CTL_BANKADDR_WIDTH];
	end
end else begin
	always_comb
	begin
	cmd0_chip_addr <= '0;
	cmd0_chip_addr[cmd0_avl_addr[CTL_CHIPADDR_INDEX +: CTL_CHIPADDR_WIDTH]] <= 1'b1;
	cmd0_chip_bank_id <= {cmd0_avl_addr[CTL_CHIPADDR_INDEX +: CTL_CHIPADDR_WIDTH],
	                      cmd0_avl_addr[CTL_BANKADDR_INDEX +: CTL_BANKADDR_WIDTH]};
	cmd1_chip_bank_id <= {cmd1_avl_addr[CTL_CHIPADDR_INDEX +: CTL_CHIPADDR_WIDTH],
	                      cmd1_avl_addr[CTL_BANKADDR_INDEX +: CTL_BANKADDR_WIDTH]};
	end
end
endgenerate


// Avalon interface module
memctl_data_if_ctl_bl_is_one_dec_lat_rldramii data_if (
	.clk					(afi_clk),
	.reset_n				(resync_afi_reset_n[0]),
	.init_complete			(afi_cal_success),
	.init_fail				(afi_cal_fail),
    .local_init_done        (local_init_done),
	.avl_ready				(avl_ready),
	.avl_write_req			(avl_write_req),
	.avl_read_req			(avl_read_req),
	.avl_addr				(avl_addr),
	.avl_size				(avl_size),
	.avl_wdata				(avl_wdata),
	.avl_rdata_valid		(avl_rdata_valid),
	.avl_rdata				(avl_rdata),
	.cmd0_write_req			(cmd0_write_req),
	.cmd0_read_req			(cmd0_read_req),
	.cmd0_addr				(cmd0_avl_addr),
	.cmd0_addr_can_merge	(cmd0_addr_can_merge),
	.cmd1_write_req			(cmd1_write_req),
	.cmd1_read_req			(cmd1_read_req),
	.cmd1_addr				(cmd1_avl_addr),
	.cmd1_addr_can_merge	(cmd1_addr_can_merge),
	.wdata_valid			(data_if_wdata_valid),
	.wdata					(data_if_wdata),
	.rdata_valid			(data_if_rdata_valid),
	.rdata					(data_if_rdata),
	.pop_req				(do_write|do_read|merge_write|merge_read));
defparam data_if.AVL_ADDR_WIDTH		= AVL_ADDR_WIDTH;
defparam data_if.AVL_SIZE_WIDTH		= AVL_SIZE_WIDTH;
defparam data_if.AVL_DWIDTH			= AVL_DATA_WIDTH;
defparam data_if.BEATADDR_WIDTH		= CTL_BEATADDR_WIDTH;


// Parity error detection
memctl_parity memctl_parity_inst (
	.wdata_in		(data_if_wdata),
	.wdata_out		(data_logic_wdata_in),
	.rdata_valid	(data_if_rdata_valid),
	.rdata_in		(data_logic_rdata_out),
	.rdata_out		(data_if_rdata),
	.parity_error	(parity_error));
defparam memctl_parity_inst.NUM_BYTES		= AVL_NUM_SYMBOLS;
defparam memctl_parity_inst.DECODED_DWIDTH	= AVL_DATA_WIDTH;
defparam memctl_parity_inst.ENCODED_DWIDTH	= AFI_DQ_WIDTH;


// Write and read data path and valid signals generation
memctl_wdata_rdata_logic memctl_wdata_rdata_logic_inst (
	.clk				(afi_clk),
	.reset_n			(resync_afi_reset_n[1]),
	.do_write			(do_write),
	.do_read			(do_read),
	.merge_write		(merge_write),
	.merge_read			(merge_read),
	.beat_addr			(cmd0_beat_addr),
	.wdata_in_valid		(data_if_wdata_valid),
	.wdata_in			(data_logic_wdata_in),
	.wdata_req			(wdata_req),
	.wdata_out			(wdata),
	.wdata_valid_out	(wdata_valid),
	.rdata_in			(rdata),
	.rdata_valid		(rdata_valid),
	.rdata_out			(data_logic_rdata_out),
	.rdata_valid_out	(data_if_rdata_valid));
defparam memctl_wdata_rdata_logic_inst.DEVICE_FAMILY				= DEVICE_FAMILY;
defparam memctl_wdata_rdata_logic_inst.AFI_DWIDTH					= AFI_DQ_WIDTH;
defparam memctl_wdata_rdata_logic_inst.AFI_RATE_RATIO				= AFI_RATE_RATIO;
defparam memctl_wdata_rdata_logic_inst.CTL_MAX_WRITE_LATENCY		= CTL_MAX_WRITE_LATENCY;
defparam memctl_wdata_rdata_logic_inst.CTL_MAX_READ_LATENCY			= CTL_MAX_READ_LATENCY;
defparam memctl_wdata_rdata_logic_inst.CTL_LATENCY					= CTL_LATENCY;
defparam memctl_wdata_rdata_logic_inst.CTL_BURST_LENGTH				= CTL_BURST_LENGTH;
defparam memctl_wdata_rdata_logic_inst.WDATA_FIFO_ENABLE_PIPELINE	= WDATA_FIFO_ENABLE_PIPELINE;
defparam memctl_wdata_rdata_logic_inst.WDATA_FIFO_SHOW_AHEAD		= WDATA_FIFO_SHOW_AHEAD;
defparam memctl_wdata_rdata_logic_inst.REGISTER_WDATA_VALID_FIFO_OUT = REGISTER_WDATA_VALID_FIFO_OUT;


// Main state machine
alt_rld_fsm_ctl_bl_is_one fsm (
	.clk					(afi_clk),
	.reset_n				(resync_afi_reset_n[2]),
	.init_complete			(afi_cal_success),
	.init_fail				(afi_cal_fail),
	.cmd0_write_req			(cmd0_write_req),
	.cmd0_read_req			(cmd0_read_req),
	.cmd0_avl_addr			(cmd0_avl_addr),
	.cmd0_addr_can_merge	(cmd0_addr_can_merge),
	.cmd0_chip_bank_id		(cmd0_chip_bank_id),
	.cmd1_write_req			(cmd1_write_req),
	.cmd1_read_req			(cmd1_read_req),
	.cmd1_avl_addr			(cmd1_avl_addr),
	.cmd1_addr_can_merge	(cmd1_addr_can_merge),
	.cmd1_chip_bank_id		(cmd1_chip_bank_id),
	.aref_req				(aref_req),
	.aref_req_bank_addr		(aref_req_bank_addr),
	.bank_can_access		(can_access),
	.bank_can_aref			(can_aref),
	.do_write				(do_write),
	.do_read				(do_read),
	.do_aref				(do_aref),
	.merge_write			(merge_write),
	.merge_read				(merge_read),
	.aref_bank_addr	(aref_bank_addr));
defparam fsm.CTL_BURST_LENGTH					= CTL_BURST_LENGTH;
defparam fsm.CTL_BANKADDR_WIDTH					= CTL_BANKADDR_WIDTH;
defparam fsm.CHIP_BANK_ID_WIDTH					= CHIP_BANK_ID_WIDTH;
defparam fsm.NUM_BANKS							= NUM_BANKS;
defparam fsm.NUM_BANKS_PER_CHIP					= NUM_BANKS_PER_CHIP;
defparam fsm.MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR	= MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR;
defparam fsm.MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD	= MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD;
defparam fsm.ADDR_WIDTH							= AVL_ADDR_WIDTH;
defparam fsm.BEATADDR_WIDTH						= CTL_BEATADDR_WIDTH;
defparam fsm.MAX_WRITE_LATENCY					= CTL_MAX_WRITE_LATENCY;
defparam fsm.CTL_CS_WIDTH						= CTL_CS_WIDTH;
defparam fsm.CTL_T_WL							= CTL_T_WL;
defparam fsm.WDATA_FIFO_LATENCY					= WDATA_FIFO_LATENCY;
defparam fsm.AFI_RATE_RATIO						= AFI_RATE_RATIO;


// DQ bus and bank timers
alt_rld_timers timers (
	.clk			(afi_clk),
	.reset_n		(resync_afi_reset_n[3]),
 	.do_access		(do_write | do_read),
	.do_aref		(do_aref),
	.chip_bank_id	(cmd0_chip_bank_id),
	.aref_bank_addr	(aref_bank_addr),
	.can_access		(can_access),
	.can_aref		(can_aref));
defparam timers.CTL_CS_WIDTH		= CTL_CS_WIDTH;
defparam timers.CTL_BANKADDR_WIDTH	= CTL_BANKADDR_WIDTH;
defparam timers.CHIP_BANK_ID_WIDTH	= CHIP_BANK_ID_WIDTH;
defparam timers.NUM_BANKS			= NUM_BANKS;
defparam timers.NUM_BANKS_PER_CHIP	= NUM_BANKS_PER_CHIP;
defparam timers.CTL_T_RC			= CTL_T_RC;


// Periodic refresh module
alt_rld_refresh refresh (
	.clk				(afi_clk),
	.reset_n			(resync_afi_reset_n[4]),
	.do_aref			(do_aref),
	.aref_req			(aref_req),
	.aref_req_bank_addr	(aref_req_bank_addr));
defparam refresh.CTL_BANKADDR_WIDTH	= CTL_BANKADDR_WIDTH;
defparam refresh.CTL_T_REFI			= CTL_T_REFI;
defparam refresh.CTL_T_RC			= CTL_T_RC;


// AFI 2.0 interface module
alt_rld_afi_ctl_bl_is_one afi (
	.clk				(afi_clk),
	.reset_n			(resync_afi_reset_n[5]),
	.do_write			(do_write),
	.do_read			(do_read),
	.do_aref			(do_aref),
	.addr				(cmd0_addr),
	.chip_addr			(cmd0_chip_addr),
	.bank_addr			(cmd0_bank_addr),
	.wdata				(wdata),
	.wdata_valid		(wdata_valid),
	.rdata				(rdata),
	.rdata_valid		(rdata_valid),
	.aref_bank_addr		(aref_bank_addr),
	.wdata_req			(wdata_req),
	.afi_addr			(afi_addr),
	.afi_ba				(afi_ba),
	.afi_cs_n			(afi_cs_n),
	.afi_we_n			(afi_we_n),
	.afi_ref_n			(afi_ref_n),
	.afi_wdata_valid	(afi_wdata_valid),
	.afi_wdata			(afi_wdata),
	.afi_dm				(afi_dm),
	.afi_rdata_en		(afi_rdata_en),
	.afi_rdata_en_full	(afi_rdata_en_full),
	.afi_rdata			(afi_rdata),
	.afi_rdata_valid	(afi_rdata_valid));
defparam afi.CTL_MAX_WRITE_LATENCY	= CTL_MAX_WRITE_LATENCY;
defparam afi.CTL_BURST_LENGTH		= CTL_BURST_LENGTH;
defparam afi.CTL_ADDR_WIDTH			= CTL_ADDR_WIDTH;
defparam afi.CTL_BANKADDR_WIDTH		= CTL_BANKADDR_WIDTH;
defparam afi.CTL_CONTROL_WIDTH		= CTL_CONTROL_WIDTH;
defparam afi.CTL_CS_WIDTH			= CTL_CS_WIDTH;
defparam afi.CTL_T_WL				= CTL_T_WL;
defparam afi.AFI_ADDR_WIDTH			= AFI_ADDR_WIDTH;
defparam afi.AFI_BANKADDR_WIDTH		= AFI_BANKADDR_WIDTH;
defparam afi.AFI_CONTROL_WIDTH		= AFI_CONTROL_WIDTH;
defparam afi.AFI_CS_WIDTH			= AFI_CS_WIDTH;
defparam afi.AFI_DM_WIDTH			= AFI_DM_WIDTH;
defparam afi.AFI_DWIDTH				= AFI_DQ_WIDTH;
defparam afi.AFI_WRITE_DQS_WIDTH	= AFI_WRITE_DQS_WIDTH;
defparam afi.AFI_WDATA_REQ_DELAY	= AFI_WDATA_REQ_DELAY;
defparam afi.AFI_RATE_RATIO			= AFI_RATE_RATIO;


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (CTL_ADDR_WIDTH + CTL_CHIPADDR_WIDTH + CTL_BANKADDR_WIDTH + CTL_BEATADDR_WIDTH == AVL_ADDR_WIDTH)
		else $error ("Invalid address width");
	assert (CTL_T_RC > 0) else $error ("Invalid tRC");
	assert (CTL_T_WL <= CTL_MAX_WRITE_LATENCY) else $error ("Invalid tWL");
	assert (AVL_DATA_WIDTH*9 == AFI_DQ_WIDTH*8) else $error ("Avalon and AFI data width mismatch");
end
// synthesis translate_on




endmodule

