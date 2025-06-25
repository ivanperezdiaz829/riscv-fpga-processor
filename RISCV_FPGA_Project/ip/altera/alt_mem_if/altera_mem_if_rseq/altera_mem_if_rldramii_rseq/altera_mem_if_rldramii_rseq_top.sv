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

module IPTCL_VARIANT_OUTPUT_NAME (
	afi_clk,
	afi_reset_n,
	afi_addr,
	afi_ba,
	afi_ref_n,
	afi_cs_n,
	afi_we_n,
	afi_wdata,
	afi_wdata_valid,
	afi_dm,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	afi_rdata_valid,
	phy_mux_sel,
	phy_read_latency_counter,
	phy_read_increment_vfifo_fr,
	phy_read_increment_vfifo_hr,
	phy_read_increment_vfifo_qr,
	phy_cal_success,
	phy_cal_fail,
	phy_reset_mem_stable,
	phy_read_fifo_reset,
	phy_vfifo_rd_en_override,
	phy_read_fifo_q,
	phy_afi_wlat,
	phy_afi_rlat,
	phy_write_fr_cycle_shifts,
	calib_skip_steps
);

// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver 


// PHY-Memory Interface
// Memory device specific parameters, they are set according to the memory spec
parameter MEM_IF_ADDR_WIDTH        = IPTCL_MEM_IF_ADDR_WIDTH; 
parameter MEM_IF_BANKADDR_WIDTH    = IPTCL_MEM_IF_BANKADDR_WIDTH; 
parameter MEM_IF_CS_WIDTH          = IPTCL_MEM_IF_CS_WIDTH; 
parameter MEM_IF_CONTROL_WIDTH     = IPTCL_MEM_IF_CONTROL_WIDTH; 
parameter MEM_IF_DM_WIDTH          = IPTCL_MEM_IF_DM_WIDTH; 
parameter MEM_IF_DQ_WIDTH          = IPTCL_MEM_IF_DQ_WIDTH; 
parameter MEM_IF_READ_DQS_WIDTH    = IPTCL_MEM_IF_READ_DQS_WIDTH; 
parameter MEM_IF_WRITE_DQS_WIDTH   = IPTCL_MEM_IF_WRITE_DQS_WIDTH;


// PHY-Controller (AFI) Interface
// The AFI interface widths are derived from the memory interface widths based on full/half rate operations
// The calculations are done on higher level wrapper
parameter AFI_ADDR_WIDTH            = IPTCL_AFI_ADDR_WIDTH; 
parameter AFI_BANKADDR_WIDTH        = IPTCL_AFI_BANKADDR_WIDTH; 
parameter AFI_CS_WIDTH              = IPTCL_AFI_CS_WIDTH; 
parameter AFI_DM_WIDTH              = IPTCL_AFI_DM_WIDTH; 
parameter AFI_CONTROL_WIDTH         = IPTCL_AFI_CONTROL_WIDTH; 
parameter AFI_DQ_WIDTH              = IPTCL_AFI_DQ_WIDTH; 
parameter AFI_WRITE_DQS_WIDTH		= IPTCL_AFI_WRITE_DQS_WIDTH;
parameter AFI_RATE_RATIO			= IPTCL_AFI_RATE_RATIO;

// Read Datapath
parameter MAX_LATENCY_COUNT_WIDTH       = IPTCL_MAX_LATENCY_COUNT_WIDTH;	// calibration finds the best latency by reducing the maximum latency  

parameter READ_FIFO_WRITE_ADDR_WIDTH	= IPTCL_READ_FIFO_WRITE_ADDR_WIDTH;
parameter READ_FIFO_READ_ADDR_WIDTH		= IPTCL_READ_FIFO_READ_ADDR_WIDTH;


// Write Datapath
// The sequencer uses this value to control write latency during calibration
parameter MAX_WRITE_LATENCY_COUNT_WIDTH = IPTCL_MAX_WRITE_LATENCY_COUNT_WIDTH;

// Mode Register Settings
parameter MRSC_COUNT_WIDTH      = 3;  // always the same for all RLDRAMII chips
parameter INIT_NOP_COUNT_WIDTH  = 13; // 8192 cycles are required by various RLDRAMII vendors
parameter MRS_CONFIGURATION		= IPTCL_MRS_CONFIGURATION; 
parameter MRS_BURST_LENGTH 		= IPTCL_MRS_BURST_LENGTH; 
parameter MRS_ADDRESS_MODE 		= IPTCL_MRS_ADDRESS_MUX; 
parameter MRS_DLL_RESET 		= IPTCL_MRS_DLL_RESET; 
parameter MRS_IMP_MATCHING		= IPTCL_MRS_IMPEDANCE_MATCHING; 
parameter MRS_ODT_EN 			= IPTCL_MRS_ODT; 

// Initialization Sequence
parameter MEM_BURST_LENGTH      = IPTCL_MEM_BURST_LENGTH;
parameter MEM_T_WL              = IPTCL_MEM_T_WL;
parameter MEM_T_RL              = IPTCL_MEM_T_RL;

// The sequencer issues back-to-back reads during calibration, NOPs may need to be inserted depending on the burst length
parameter SEQ_BURST_COUNT_WIDTH = IPTCL_SEQ_BURST_COUNT_WIDTH;

// Width of the counter used to determine the number of cycles required
// to calculate if the rddata pattern is all 0 or all 1.
parameter VCALIB_COUNT_WIDTH    = IPTCL_VCALIB_COUNT_WIDTH;

// Width of the calibration status register used to control calibration skipping.
parameter CALIB_REG_WIDTH		= IPTCL_CALIB_REG_WIDTH;

parameter AFI_RLAT_WIDTH			= IPTCL_AFI_RLAT_WIDTH;
parameter AFI_WLAT_WIDTH			= IPTCL_AFI_WLAT_WIDTH;


// local parameters
localparam AFI_DQ_GROUP_DATA_WIDTH = AFI_DQ_WIDTH / MEM_IF_READ_DQS_WIDTH;


localparam MAX_READ_LATENCY				   = 2**MAX_LATENCY_COUNT_WIDTH;

// Read valid prediction parameters
//This should really be log2(READ_VALID_FIFO_SIZE)
localparam READ_VALID_TIMEOUT_WIDTH		   = 8; // calibration fails when the timeout counter expires 


// Initialization Sequence
// The init counter is used to maintain the stable condition wait time required by the memory protocol
localparam INIT_COUNT_WIDTH      = 18; // RLDRAMII spec requires min 200us wait time before initialization starts

localparam  WRITE_FR_CYCLE_SHIFT_WIDTH = 2*MEM_IF_WRITE_DQS_WIDTH;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION

input	afi_clk;
input	afi_reset_n;


// sequencer version of the AFI interface
output	     [AFI_ADDR_WIDTH-1:0]  afi_addr;
output	 [AFI_BANKADDR_WIDTH-1:0]  afi_ba;
output	  [AFI_CONTROL_WIDTH-1:0]  afi_ref_n;
output	       [AFI_CS_WIDTH-1:0]  afi_cs_n;
output	  [AFI_CONTROL_WIDTH-1:0]  afi_we_n;

output         [AFI_DQ_WIDTH-1:0]  afi_wdata;
output  [AFI_WRITE_DQS_WIDTH-1:0]  afi_wdata_valid;
output         [AFI_DM_WIDTH-1:0]  afi_dm;

output       [AFI_RATE_RATIO-1:0]  afi_rdata_en;
output       [AFI_RATE_RATIO-1:0]  afi_rdata_en_full;

// signals between the sequencer and the read datapath
input	[AFI_DQ_WIDTH-1:0]    afi_rdata;	// read data from read datapath, thru sequencer, back to AFI
input	[AFI_RATE_RATIO-1:0]  afi_rdata_valid; // read data valid from read datapath, thru sequencer, back to AFI

// read data (no reordering) for indepedently FIFO calibrations (multiple FIFOs for multiple DQS groups)
input	[AFI_DQ_WIDTH-1:0]	phy_read_fifo_q; 

output	phy_mux_sel;

// sequencer outputs to controller AFI interface
output	phy_cal_success;
output	phy_cal_fail;


// hold reset in the read capture clock domain until memory is stable
output	phy_reset_mem_stable;

// reset the read and write pointers of the data resynchronization FIFO in the read datapath 
output	[MEM_IF_READ_DQS_WIDTH-1:0] phy_read_fifo_reset;

output	[MEM_IF_READ_DQS_WIDTH-1:0] phy_vfifo_rd_en_override;

// read latency counter value from sequencer to inform read datapath when valid data should be read
output	[MAX_LATENCY_COUNT_WIDTH-1:0] phy_read_latency_counter;

// controls from sequencer to read datapath to calibration the valid prediction FIFO pointer offsets
output	[MEM_IF_READ_DQS_WIDTH-1:0] phy_read_increment_vfifo_fr; // increment valid prediction FIFO write pointer by an extra full rate cycle	
output	[MEM_IF_READ_DQS_WIDTH-1:0] phy_read_increment_vfifo_hr; // increment valid prediction FIFO write pointer by an extra half rate cycle
															  // in full rate core, both will mean an extra full rate cycle
output	[MEM_IF_READ_DQS_WIDTH-1:0] phy_read_increment_vfifo_qr;															  

output           [AFI_WLAT_WIDTH-1:0]  phy_afi_wlat;
output           [AFI_RLAT_WIDTH-1:0]  phy_afi_rlat;

output           [WRITE_FR_CYCLE_SHIFT_WIDTH-1:0] phy_write_fr_cycle_shifts;


input	[CALIB_REG_WIDTH-1:0] calib_skip_steps;


assign afi_rdata_en_full = afi_rdata_en;

assign phy_afi_wlat = '0;
assign phy_afi_rlat = '0;
assign phy_write_fr_cycle_shifts = '0;

assign phy_vfifo_rd_en_override = '0;


sequencer #(
	.MEM_ADDRESS_WIDTH(MEM_IF_ADDR_WIDTH),
	.MEM_BANK_WIDTH(MEM_IF_BANKADDR_WIDTH),
	.MEM_CHIP_SELECT_WIDTH(MEM_IF_CS_WIDTH),
	.MEM_CONTROL_WIDTH(MEM_IF_CONTROL_WIDTH),
	.MEM_DM_WIDTH(MEM_IF_DM_WIDTH),
	.MEM_DQ_WIDTH(MEM_IF_DQ_WIDTH),
	.MEM_READ_DQS_WIDTH(MEM_IF_READ_DQS_WIDTH),
	.AFI_ADDRESS_WIDTH(AFI_ADDR_WIDTH),
	.AFI_BANK_WIDTH(AFI_BANKADDR_WIDTH),
	.AFI_CHIP_SELECT_WIDTH(AFI_CS_WIDTH),
	.AFI_DATA_MASK_WIDTH(AFI_DM_WIDTH),
	.AFI_CONTROL_WIDTH(AFI_CONTROL_WIDTH),
	.AFI_DATA_WIDTH(AFI_DQ_WIDTH),
	.AFI_DQS_WIDTH(AFI_WRITE_DQS_WIDTH),
	.AFI_R_RATIO(AFI_RATE_RATIO),
	.MAX_LATENCY_COUNT_WIDTH(MAX_LATENCY_COUNT_WIDTH),
	.MAX_READ_LATENCY(MAX_READ_LATENCY),
	.READ_FIFO_READ_ADDR_WIDTH(READ_FIFO_READ_ADDR_WIDTH),
	.READ_FIFO_WRITE_ADDR_WIDTH(READ_FIFO_WRITE_ADDR_WIDTH),
	.READ_VALID_TIMEOUT_WIDTH(READ_VALID_TIMEOUT_WIDTH),
	.MAX_WRITE_LATENCY_COUNT_WIDTH(MAX_WRITE_LATENCY_COUNT_WIDTH),
	.INIT_COUNT_WIDTH(INIT_COUNT_WIDTH),
	.MRSC_COUNT_WIDTH(MRSC_COUNT_WIDTH),
	.INIT_NOP_COUNT_WIDTH(INIT_NOP_COUNT_WIDTH),
	.MRS_CONFIGURATION(MRS_CONFIGURATION),
	.MRS_BURST_LENGTH(MRS_BURST_LENGTH),
	.MRS_ADDRESS_MODE(MRS_ADDRESS_MODE),
	.MRS_DLL_RESET(MRS_DLL_RESET),
	.MRS_IMP_MATCHING(MRS_IMP_MATCHING),
	.MRS_ODT_EN(MRS_ODT_EN),
	.MEM_BURST_LENGTH(MEM_BURST_LENGTH),
	.MEM_T_WL(MEM_T_WL),
	.MEM_T_RL(MEM_T_RL),
	.SEQ_BURST_COUNT_WIDTH(SEQ_BURST_COUNT_WIDTH),
	.VCALIB_COUNT_WIDTH(VCALIB_COUNT_WIDTH),
	.CALIB_REG_WIDTH(CALIB_REG_WIDTH)
) sequencer_inst (
	.pll_afi_clk(afi_clk),
	.reset_n(afi_reset_n),
	.seq_mux_address(afi_addr),
	.seq_mux_bank(afi_ba),
	.seq_mux_cas_n(afi_ref_n),
	.seq_mux_cs_n(afi_cs_n),
	.seq_mux_we_n(afi_we_n),
	.seq_mux_wdata(afi_wdata),
	.seq_mux_wdata_valid(afi_wdata_valid),
	.seq_mux_dm(afi_dm),
	.seq_mux_rdata_en(afi_rdata_en),
	.mux_seq_rdata(afi_rdata),
	.mux_seq_read_fifo_q(phy_read_fifo_q),
	.mux_seq_rdata_valid(afi_rdata_valid),
	.mux_sel(phy_mux_sel),
	.seq_read_latency_counter(phy_read_latency_counter),
	.seq_read_increment_vfifo_fr(phy_read_increment_vfifo_fr),
	.seq_read_increment_vfifo_hr(phy_read_increment_vfifo_hr),
	.seq_read_increment_vfifo_qr(phy_read_increment_vfifo_qr),
	.afi_cal_success(phy_cal_success),
	.afi_cal_fail(phy_cal_fail),
	.seq_reset_mem_stable(phy_reset_mem_stable),
	.seq_read_fifo_reset(phy_read_fifo_reset),
	.seq_calib_init(calib_skip_steps)
);


endmodule
