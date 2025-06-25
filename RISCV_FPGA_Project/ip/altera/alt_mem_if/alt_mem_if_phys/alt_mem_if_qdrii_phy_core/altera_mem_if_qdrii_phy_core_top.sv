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

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_qdrii_phy_core; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
module IPTCL_VARIANT_OUTPUT_NAME (
    global_reset_n,
    soft_reset_n,
	csr_soft_reset_req,
`ifdef ARRIAIIGX
    terminationcontrol,
`else
    parallelterminationcontrol,
    seriesterminationcontrol,
`endif	
	pll_mem_clk,
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	pll_mem_phy_clk,
	afi_phy_clk,
	pll_avl_phy_clk,
`endif
	pll_write_clk,
	pll_write_clk_pre_phy_clk,
	pll_addr_cmd_clk,
`ifdef QUARTER_RATE
	pll_hr_clk,
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
	pll_p2c_read_clk,
	pll_c2p_write_clk,
`endif
`ifdef USE_DR_CLK
	pll_dr_clk,
	pll_dr_clk_pre_phy_clk,
`endif	
`ifdef NIOS_SEQUENCER
	pll_avl_clk,
	pll_config_clk,
`endif
`ifdef DEBUG_PLL_DYN_PHASE_SHIFT 
	pll_scanclk,
	reset_n_pll_scanclk,
`endif
	pll_locked,
	dll_pll_locked,
	dll_delayctrl,
	dll_clk,
`ifdef HCX_COMPAT_MODE
	hc_dll_config_dll_offset_ctrl_offsetctrlout,
	hc_dll_config_dll_offset_ctrl_b_offsetctrlout,
`endif
	afi_reset_n,
	afi_reset_export_n,
	afi_clk,
	afi_half_clk,
	afi_addr,
	afi_wps_n,
	afi_rps_n,
	afi_wdata,
	afi_wdata_valid,
	afi_bws_n,
	afi_doff_n,
	afi_rdata,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
	afi_cal_success,
	afi_cal_fail,
	mem_d,
	mem_wps_n,
	mem_bws_n,
	mem_a,
	mem_q,
	mem_rps_n,
	mem_k,
	mem_k_n,
`ifdef NO_COMPLIMENTARY_STROBE
	`ifdef RL2
	mem_cq_n,
	`else
	mem_cq,
	`endif
`else
	mem_cq,
	mem_cq_n,
`endif
	mem_doff_n,
`ifdef NIOS_SEQUENCER
	avl_clk,
	scc_clk,
	avl_reset_n,
	scc_reset_n,
	scc_data,
	scc_dqs_ena,
	scc_dqs_io_ena,
	scc_dq_ena,
	scc_dm_ena,
	scc_upd,
	capture_strobe_tracking,
`endif
	phy_clk,
	phy_reset_n,
	phy_read_latency_counter,
	phy_afi_wlat,
	phy_afi_rlat,
	phy_read_increment_vfifo_fr,
	phy_read_increment_vfifo_hr,
	phy_read_increment_vfifo_qr,
	phy_reset_mem_stable,
`ifdef NIOS_SEQUENCER
	phy_cal_debug_info,
`endif
	phy_read_fifo_reset,
	phy_vfifo_rd_en_override,
	phy_cal_success,
	phy_cal_fail,
	phy_read_fifo_q,
`ifdef RTL_CALIB
`ifdef STRATIXV
`ifndef NIOS_SEQUENCER
	mem_config_clk, 
	mem_config_datain, 
	mem_config_update, 
		
	mem_config_cqdqs_ena,
	mem_config_cq_io_ena,
	mem_config_rio_ena,
		
	mem_config_kdqs_ena,
	mem_config_k_io_ena,
	mem_config_wio_ena,
	mem_config_dm_ena, 
	dll_offsetctrlout,
`endif
`endif
`endif
	calib_skip_steps
);


// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver. 
parameter DEVICE_FAMILY = "IPTCL_DEVICE_FAMILY";

// choose between abstract (fast) and regular model
`ifndef ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL
  `define ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL IPTCL_FAST_SIM_MODEL_DEFAULT
`endif

parameter ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL = `ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;

localparam FAST_SIM_MODEL = ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;


// On-chip termination
parameter OCT_TERM_CONTROL_WIDTH   = IPTCL_OCT_TERM_CONTROL_WIDTH;

// PHY-Memory Interface
// Memory device specific parameters, they are set according to the memory spec.
parameter MEM_IF_ADDR_WIDTH		    = IPTCL_MEM_IF_ADDR_WIDTH;
parameter MEM_IF_DM_WIDTH         	= IPTCL_MEM_IF_DM_WIDTH;
parameter MEM_IF_CONTROL_WIDTH    	= IPTCL_MEM_IF_CONTROL_WIDTH; 
parameter MEM_IF_DQ_WIDTH         	= IPTCL_MEM_IF_DQ_WIDTH;
parameter MEM_IF_READ_DQS_WIDTH   	= IPTCL_MEM_IF_READ_DQS_WIDTH; 
parameter MEM_IF_WRITE_DQS_WIDTH  	= IPTCL_MEM_IF_WRITE_DQS_WIDTH;
parameter MEM_IF_CS_WIDTH 	        = -1; 

// PHY-Controller (AFI) Interface
// The AFI interface widths are derived from the memory interface widths based on full/half rate operations.
// The calculations are done on higher level wrapper.
parameter AFI_ADDR_WIDTH         = IPTCL_AFI_ADDR_WIDTH; 
parameter AFI_DM_WIDTH       = IPTCL_AFI_DM_WIDTH; 
parameter AFI_CONTROL_WIDTH         = IPTCL_AFI_CONTROL_WIDTH; 
parameter AFI_DQ_WIDTH            = IPTCL_AFI_DQ_WIDTH;
parameter AFI_WRITE_DQS_WIDTH       = IPTCL_AFI_WRITE_DQS_WIDTH;
parameter AFI_RATE_RATIO			= IPTCL_AFI_RATE_RATIO;
parameter AFI_WLAT_WIDTH			= IPTCL_AFI_WLAT_WIDTH;
parameter AFI_RLAT_WIDTH			= IPTCL_AFI_RLAT_WIDTH;

// DLL Interface
parameter DLL_DELAY_CTRL_WIDTH	= IPTCL_DLL_DELAY_CTRL_WIDTH;

parameter SCC_DATA_WIDTH            = IPTCL_SCC_DATA_WIDTH;

parameter NUM_SUBGROUP_PER_READ_DQS        = IPTCL_NUM_SUBGROUP_PER_READ_DQS;
parameter QVLD_EXTRA_FLOP_STAGES		   = IPTCL_QVLD_EXTRA_FLOP_STAGES;
parameter QVLD_WR_ADDRESS_OFFSET		   = IPTCL_QVLD_WR_ADDRESS_OFFSET;
	
// Read Datapath parameters, the values should not be changed unless the intention is to change the architecture.
// Read valid prediction FIFO
parameter READ_VALID_FIFO_SIZE             = IPTCL_READ_VALID_FIFO_SIZE;

// Data resynchronization FIFO
parameter READ_FIFO_SIZE                   = IPTCL_READ_FIFO_SIZE;

// Latency calibration parameters
parameter MAX_LATENCY_COUNT_WIDTH		   = IPTCL_MAX_LATENCY_COUNT_WIDTH; // calibration finds the best latency by reducing the maximum latency
localparam MAX_READ_LATENCY				   = 2**MAX_LATENCY_COUNT_WIDTH; 

// Write Datapath
// The sequencer uses this value to control write latency during calibration
parameter MAX_WRITE_LATENCY_COUNT_WIDTH = IPTCL_MAX_WRITE_LATENCY_COUNT_WIDTH;
parameter NUM_WRITE_PATH_FLOP_STAGES    = IPTCL_NUM_WRITE_PATH_FLOP_STAGES;
parameter NUM_WRITE_FR_CYCLE_SHIFTS = IPTCL_NUM_WRITE_FR_CYCLE_SHIFTS;

// Add additional FF stage between core and periphery
parameter REGISTER_C2P = "IPTCL_REGISTER_C2P";

// Address/Command Datapath
parameter NUM_AC_FR_CYCLE_SHIFTS = IPTCL_NUM_AC_FR_CYCLE_SHIFTS;

parameter MEM_T_WL								= IPTCL_MEM_T_WL;

localparam MEM_T_RL								= IPTCL_MEM_T_RL;

// The sequencer issues back-to-back reads during calibration, NOPs may need to be inserted depending on the burst length
parameter SEQ_BURST_COUNT_WIDTH = IPTCL_SEQ_BURST_COUNT_WIDTH;

// The DLL offset control width
parameter DLL_OFFSET_CTRL_WIDTH = IPTCL_DLL_OFFSET_CTRL_WIDTH;

parameter AFI_DEBUG_INFO_WIDTH = IPTCL_AFI_DEBUG_INFO_WIDTH;

parameter CALIB_REG_WIDTH = IPTCL_CALIB_REG_WIDTH;


parameter TB_PROTOCOL       = "IPTCL_TB_PROTOCOL";
parameter TB_MEM_CLK_FREQ   = "IPTCL_TB_MEM_CLK_FREQ";
parameter TB_RATE           = "IPTCL_TB_RATE";
parameter TB_MEM_DQ_WIDTH   = "IPTCL_TB_MEM_IF_DQ_WIDTH";
parameter TB_MEM_DQS_WIDTH  = "IPTCL_TB_MEM_IF_READ_DQS_WIDTH";
parameter TB_PLL_DLL_MASTER = "IPTCL_TB_PLL_DLL_MASTER";

parameter FAST_SIM_CALIBRATION = "IPTCL_FAST_SIM_CALIBRATION";


localparam SIM_FILESET = ("IPTCL_SIM_FILESET" == "true");


// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION


// When the PHY is selected to be a PLL/DLL SLAVE, the PLL and DLL are instantied at the top level of the example design
input	pll_mem_clk;	
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
input pll_mem_phy_clk;
input afi_phy_clk;
input pll_avl_phy_clk;
`endif
input	pll_write_clk;
input	pll_write_clk_pre_phy_clk;
input	pll_addr_cmd_clk;
`ifdef QUARTER_RATE
input	pll_hr_clk;
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
input	pll_p2c_read_clk;
input	pll_c2p_write_clk;
`endif
`ifdef USE_DR_CLK
input 	pll_dr_clk;
input 	pll_dr_clk_pre_phy_clk;
`endif
`ifdef NIOS_SEQUENCER
input	pll_avl_clk;
input	pll_config_clk;
`endif
input	pll_locked;


`ifdef HCX_COMPAT_MODE
input [DLL_OFFSET_CTRL_WIDTH-1:0] hc_dll_config_dll_offset_ctrl_offsetctrlout;
input [DLL_OFFSET_CTRL_WIDTH-1:0] hc_dll_config_dll_offset_ctrl_b_offsetctrlout;
`endif


input	[DLL_DELAY_CTRL_WIDTH-1:0]  dll_delayctrl;
output  dll_pll_locked;
output  dll_clk;


`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
output	pll_scanclk;
output	reset_n_pll_scanclk;
`endif

// Reset Interface, AFI 2.0
input   global_reset_n;		// Resets (active-low) the whole system (all PHY logic + PLL)
input	soft_reset_n;		// Resets (active-low) PHY logic only, PLL is NOT reset
output	afi_reset_n;		// Asynchronously asserted and synchronously de-asserted on afi_clk domain
output	afi_reset_export_n;		// Asynchronously asserted and synchronously de-asserted on afi_clk domain
							// should be used to reset system level afi_clk domain logic
input csr_soft_reset_req;  // Reset request (active_high) being driven by external debug master

// OCT termination control signals
`ifdef ARRIAIIGX
input [OCT_TERM_CONTROL_WIDTH-1:0] terminationcontrol;
`else
input [OCT_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol;
input [OCT_TERM_CONTROL_WIDTH-1:0] seriesterminationcontrol;
`endif

// PHY-Controller Interface, AFI 2.0
// Control Interface
input   [AFI_ADDR_WIDTH-1:0] afi_addr;		// address

input	[AFI_CONTROL_WIDTH-1:0] afi_wps_n;		// write command
input   [AFI_CONTROL_WIDTH-1:0] afi_rps_n;		// read command



// Write data interface
input   [AFI_DQ_WIDTH-1:0]    afi_wdata;				// write data
input	[AFI_WRITE_DQS_WIDTH-1:0]	afi_wdata_valid;			// write data valid, used to maintain write latency required by protocol spec
input   [AFI_DM_WIDTH-1:0]   afi_bws_n;				// write data mask
input   [AFI_CONTROL_WIDTH-1:0]   afi_doff_n;				// 

// Read data interface
output  [AFI_DQ_WIDTH-1:0]    afi_rdata;           // read data				
input   [AFI_RATE_RATIO-1:0]  afi_rdata_en;        // read enable, used to maintain the read latency calibrated by PHY
input   [AFI_RATE_RATIO-1:0]  afi_rdata_en_full;   // read enable full burst, used to create DQS enable
output  [AFI_RATE_RATIO-1:0]  afi_rdata_valid;     // read data valid

// Status interface
output  afi_cal_success;	// calibration success
output  afi_cal_fail;		// calibration failure



// PHY-Memory Interface

// Port names are according to QDRII spec, refer to spec for details
output	[MEM_IF_DQ_WIDTH-1:0] mem_d;				// write data
output	[MEM_IF_CONTROL_WIDTH-1:0] mem_wps_n;		// write command
output	[MEM_IF_DM_WIDTH-1:0] mem_bws_n;			// byte enable
output	[MEM_IF_ADDR_WIDTH-1:0] mem_a;			// address
output	[MEM_IF_CONTROL_WIDTH-1:0] mem_rps_n;		// read command
output	[MEM_IF_CONTROL_WIDTH-1:0] mem_doff_n;		// 0=QDRI mode, 1=QDRII mode, tied to 1 since only QDRII support is required 
output	[MEM_IF_WRITE_DQS_WIDTH-1:0] mem_k;		// complementary input clocks to memory device
output	[MEM_IF_WRITE_DQS_WIDTH-1:0] mem_k_n;		
`ifdef NO_COMPLIMENTARY_STROBE
	`ifdef RL2
input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_cq_n;
	`else
input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_cq;		// complementary output clocks from memory device
	`endif
`else
input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_cq;		// complementary output clocks from memory device
input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_cq_n;
`endif
input	[MEM_IF_DQ_WIDTH-1:0] mem_q;				// read data


// PLL Interface
input	afi_clk;
input	afi_half_clk;


`ifdef NIOS_SEQUENCER
output  avl_clk;
output  scc_clk;
output  avl_reset_n;
output  scc_reset_n;

input           [SCC_DATA_WIDTH-1:0]  scc_data;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  scc_dqs_ena;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  scc_dqs_io_ena;
input          [MEM_IF_DQ_WIDTH-1:0]  scc_dq_ena;
input          [MEM_IF_DM_WIDTH-1:0]  scc_dm_ena;
input                          [0:0]  scc_upd;
output   [MEM_IF_READ_DQS_WIDTH-1:0]  capture_strobe_tracking;
`endif

output  phy_clk;
output  phy_reset_n;

input  [MAX_LATENCY_COUNT_WIDTH-1:0]  phy_read_latency_counter;
input           [AFI_WLAT_WIDTH-1:0]  phy_afi_wlat; 
input           [AFI_RLAT_WIDTH-1:0]  phy_afi_rlat; 
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_increment_vfifo_fr;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_increment_vfifo_hr;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_increment_vfifo_qr;
input                                 phy_reset_mem_stable;
`ifdef NIOS_SEQUENCER
input   [AFI_DEBUG_INFO_WIDTH - 1:0]  phy_cal_debug_info;
`endif
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_fifo_reset;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_vfifo_rd_en_override;
input                                 phy_cal_success;	// calibration success
input                                 phy_cal_fail;		// calibration failure
output            [AFI_DQ_WIDTH-1:0]  phy_read_fifo_q; 

output         [CALIB_REG_WIDTH-1:0]  calib_skip_steps;

`ifdef RTL_CALIB
`ifdef STRATIXV
`ifndef NIOS_SEQUENCER
input	mem_config_clk; 
input	mem_config_datain; 
input   mem_config_update; 

input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_config_cqdqs_ena; 
input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_config_cq_io_ena; 
input	[MEM_IF_DQ_WIDTH-1:0] mem_config_rio_ena; 

input	[MEM_IF_WRITE_DQS_WIDTH-1:0] mem_config_kdqs_ena; 
input	[MEM_IF_WRITE_DQS_WIDTH-1:0] mem_config_k_io_ena; 
input	[MEM_IF_DQ_WIDTH-1:0] mem_config_wio_ena; 
input	[MEM_IF_DM_WIDTH-1:0] mem_config_dm_ena; 
input	[DLL_DELAY_CTRL_WIDTH-1:0]  dll_offsetctrlout;
`endif
`endif
`endif


// END PORT SECTION


initial $display("Using %0s core emif simulation models", FAST_SIM_MODEL ? "Fast" : "Regular");


assign afi_cal_success = phy_cal_success;
assign afi_cal_fail = phy_cal_fail;


`ifdef NIOS_SEQUENCER
assign avl_clk = pll_avl_clk;
assign scc_clk = pll_config_clk;
`endif




memphy #(
	.DEVICE_FAMILY(DEVICE_FAMILY),
`ifdef ARRIAIIGX
	.OCT_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
`else
	.OCT_SERIES_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
	.OCT_PARALLEL_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
`endif
	.MEM_ADDRESS_WIDTH(MEM_IF_ADDR_WIDTH),
	.MEM_CHIP_SELECT_WIDTH(MEM_IF_CS_WIDTH),
	.MEM_DM_WIDTH(MEM_IF_DM_WIDTH),
	.MEM_CONTROL_WIDTH(MEM_IF_CONTROL_WIDTH),
	.MEM_DQ_WIDTH(MEM_IF_DQ_WIDTH),
	.MEM_READ_DQS_WIDTH(MEM_IF_READ_DQS_WIDTH),
	.MEM_WRITE_DQS_WIDTH(MEM_IF_WRITE_DQS_WIDTH),
	.AFI_ADDRESS_WIDTH(AFI_ADDR_WIDTH),
	.AFI_DATA_MASK_WIDTH(AFI_DM_WIDTH),
	.AFI_DQS_WIDTH(AFI_WRITE_DQS_WIDTH),
	.AFI_CONTROL_WIDTH(AFI_CONTROL_WIDTH),
	.AFI_DATA_WIDTH(AFI_DQ_WIDTH),
	.AFI_RATE_RATIO(AFI_RATE_RATIO),
	.DLL_DELAY_CTRL_WIDTH(DLL_DELAY_CTRL_WIDTH),
	.MEM_T_RL(MEM_T_RL),
	.MAX_LATENCY_COUNT_WIDTH(MAX_LATENCY_COUNT_WIDTH),
	.MAX_READ_LATENCY(MAX_READ_LATENCY),
	.READ_VALID_FIFO_SIZE(READ_VALID_FIFO_SIZE),
	.READ_FIFO_SIZE(READ_FIFO_SIZE),
	.MAX_WRITE_LATENCY_COUNT_WIDTH(MAX_WRITE_LATENCY_COUNT_WIDTH),
	.NUM_WRITE_PATH_FLOP_STAGES(NUM_WRITE_PATH_FLOP_STAGES),
	.NUM_WRITE_FR_CYCLE_SHIFTS(NUM_WRITE_FR_CYCLE_SHIFTS),
	.REGISTER_C2P(REGISTER_C2P),	
	.NUM_SUBGROUP_PER_READ_DQS(NUM_SUBGROUP_PER_READ_DQS),
	.QVLD_EXTRA_FLOP_STAGES(QVLD_EXTRA_FLOP_STAGES),
	.QVLD_WR_ADDRESS_OFFSET(QVLD_WR_ADDRESS_OFFSET),
	.NUM_AC_FR_CYCLE_SHIFTS(NUM_AC_FR_CYCLE_SHIFTS),
	.CALIB_REG_WIDTH(CALIB_REG_WIDTH),
	.AFI_DEBUG_INFO_WIDTH(AFI_DEBUG_INFO_WIDTH),
	.TB_PROTOCOL(TB_PROTOCOL),
	.TB_MEM_CLK_FREQ(TB_MEM_CLK_FREQ),
	.TB_RATE(TB_RATE),
	.TB_MEM_DQ_WIDTH(TB_MEM_DQ_WIDTH),
	.TB_MEM_DQS_WIDTH(TB_MEM_DQS_WIDTH),
	.TB_PLL_DLL_MASTER(TB_PLL_DLL_MASTER),
	.FAST_SIM_MODEL(FAST_SIM_MODEL),
	.FAST_SIM_CALIBRATION(FAST_SIM_CALIBRATION),
	.SCC_DATA_WIDTH(SCC_DATA_WIDTH)
) umemphy (
	.global_reset_n(global_reset_n),
	.soft_reset_n(soft_reset_n & ~csr_soft_reset_req),
	.ctl_reset_n(afi_reset_n),
	.ctl_reset_export_n(afi_reset_export_n),
	.pll_locked(pll_locked),
`ifdef DEBUG_PLL_DYN_PHASE_SHIFT 
	.pll_scanclk(pll_scanclk),
	.reset_n_pll_scanclk(reset_n_pll_scanclk),
`endif
`ifdef ARRIAIIGX
	.oct_ctl_value(terminationcontrol),
`else
	.oct_ctl_rt_value(parallelterminationcontrol),
	.oct_ctl_rs_value(seriesterminationcontrol),
`endif
	.afi_addr(afi_addr),
	.afi_wps_n(afi_wps_n),
	.afi_rps_n(afi_rps_n),
	.afi_doff_n(afi_doff_n),
	.afi_wdata(afi_wdata),
	.afi_wdata_valid(afi_wdata_valid),
	.afi_dm(afi_bws_n),
	.afi_rdata(afi_rdata),
	.afi_rdata_en(afi_rdata_en),
	.afi_rdata_en_full(afi_rdata_en_full),
	.afi_rdata_valid(afi_rdata_valid),
	.afi_cal_success(afi_cal_success),
	.afi_cal_fail(afi_cal_fail),
	.mem_d(mem_d),
	.mem_wps_n(mem_wps_n),
	.mem_bws_n(mem_bws_n),
	.mem_a(mem_a),
	.mem_rps_n(mem_rps_n),
	.mem_doff_n(mem_doff_n),
	.mem_k(mem_k),
	.mem_k_n(mem_k_n),
`ifdef NO_COMPLIMENTARY_STROBE
	`ifdef RL2
	.mem_cq_n(mem_cq_n),
	`else
	.mem_cq(mem_cq),
	`endif
`else
	.mem_cq(mem_cq),
	.mem_cq_n(mem_cq_n),
`endif
	.mem_q(mem_q),
	.pll_afi_clk(afi_clk),
	.pll_mem_clk(pll_mem_clk),
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	.pll_mem_phy_clk(pll_mem_phy_clk),
	.pll_afi_phy_clk(afi_phy_clk),
`endif
	.pll_write_clk(pll_write_clk),
	.pll_write_clk_pre_phy_clk(pll_write_clk_pre_phy_clk),
	.pll_addr_cmd_clk(pll_addr_cmd_clk),
	.pll_afi_half_clk(afi_half_clk),
`ifdef QUARTER_RATE
	.pll_hr_clk(pll_hr_clk),
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
	.pll_p2c_read_clk(pll_p2c_read_clk),
	.pll_c2p_write_clk(pll_c2p_write_clk),
`endif
`ifdef USE_DR_CLK
	.pll_dr_clk(pll_dr_clk),
	.pll_dr_clk_pre_phy_clk(pll_dr_clk_pre_phy_clk),
`endif
	.seq_clk(afi_clk), 
`ifdef NIOS_SEQUENCER
	.reset_n_avl_clk(avl_reset_n),
	.reset_n_scc_clk(scc_reset_n),
	.scc_data(scc_data),
	.scc_dqs_ena(scc_dqs_ena),
	.scc_dqs_io_ena(scc_dqs_io_ena),
	.scc_dq_ena(scc_dq_ena),
	.scc_dm_ena(scc_dm_ena),
	.scc_upd(scc_upd),
	.capture_strobe_tracking(capture_strobe_tracking),
`endif
	.phy_clk(phy_clk),
	.phy_reset_n(phy_reset_n),
	.phy_read_latency_counter(phy_read_latency_counter),
	.phy_read_increment_vfifo_fr(phy_read_increment_vfifo_fr),
	.phy_read_increment_vfifo_hr(phy_read_increment_vfifo_hr),
	.phy_read_increment_vfifo_qr(phy_read_increment_vfifo_qr),
	.phy_reset_mem_stable(phy_reset_mem_stable),
`ifdef NIOS_SEQUENCER
	.phy_cal_debug_info(phy_cal_debug_info),
`endif
	.phy_read_fifo_reset(phy_read_fifo_reset),
	.phy_vfifo_rd_en_override(phy_vfifo_rd_en_override),
	.phy_read_fifo_q(phy_read_fifo_q),
	.calib_skip_steps(calib_skip_steps),
`ifdef HCX_COMPAT_MODE
	.hc_dll_config_dll_offset_ctrl_offsetctrlout(hc_dll_config_dll_offset_ctrl_offsetctrlout),
	.hc_dll_config_dll_offset_ctrl_b_offsetctrlout(hc_dll_config_dll_offset_ctrl_b_offsetctrlout),
`endif
`ifdef NIOS_SEQUENCER
	.pll_avl_clk(pll_avl_clk),
	.pll_config_clk(pll_config_clk),
`endif

`ifdef RTL_CALIB
`ifdef STRATIXV
`ifndef NIOS_SEQUENCER
	.mem_config_clk 	(mem_config_clk), 
	.mem_config_datain	(mem_config_datain),
	.mem_config_update	(mem_config_update),
		
	.mem_config_cqdqs_ena	(mem_config_cqdqs_ena),
	.mem_config_cq_io_ena	(mem_config_cq_io_ena),
	.mem_config_rio_ena	(mem_config_rio_ena),
		
	.mem_config_kdqs_ena	(mem_config_kdqs_ena),
	.mem_config_k_io_ena	(mem_config_k_io_ena),
	.mem_config_wio_ena	(mem_config_wio_ena),
	.mem_config_dm_ena	(mem_config_dm_ena),
	.dll_offsetdelay_in     (dll_offsetctrlout),
`endif
`endif
`endif
	.dll_clk(dll_clk),
	.dll_pll_locked(dll_pll_locked),
	.dll_phy_delayctrl(dll_delayctrl)
);


endmodule

