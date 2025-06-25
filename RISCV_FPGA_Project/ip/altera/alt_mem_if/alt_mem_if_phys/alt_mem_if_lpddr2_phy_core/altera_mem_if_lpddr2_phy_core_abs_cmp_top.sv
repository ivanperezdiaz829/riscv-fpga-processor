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

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_lpddr2_phy_core; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
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
	afi_cke,
	afi_cs_n,
	afi_dqs_burst,
	afi_wdata,
	afi_wdata_valid,
	afi_dm,
	afi_rdata,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
	afi_cal_success,
	afi_cal_fail,
	afi_wlat,
	afi_rlat,
	afi_mem_clk_disable,
`ifdef PHY_CSR_ENABLED
    csr_addr,
    csr_be,
    csr_rdata,
    csr_read_req,
    csr_wdata,
    csr_write_req,
    csr_rdata_valid,
    csr_waitrequest,
`endif
	mem_ca,
	mem_ck,
	mem_ck_n,
	mem_cke,
	mem_cs_n,
`ifdef MEM_IF_DM_PINS_EN
	mem_dm,
`endif
	mem_dq,
	mem_dqs,
	mem_dqs_n,
	addr_cmd_clk,
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
parameter MEM_IF_ADDR_WIDTH			= IPTCL_MEM_IF_ADDR_WIDTH;
parameter MEM_IF_BANKADDR_WIDTH     = IPTCL_MEM_IF_BANKADDR_WIDTH;
parameter MEM_IF_CK_WIDTH			= IPTCL_MEM_IF_CK_WIDTH;
parameter MEM_IF_CLK_EN_WIDTH		= IPTCL_MEM_IF_CLK_EN_WIDTH;
parameter MEM_IF_CS_WIDTH			= IPTCL_MEM_IF_CS_WIDTH;
parameter MEM_IF_DM_WIDTH         	= IPTCL_MEM_IF_DM_WIDTH;
parameter MEM_IF_CONTROL_WIDTH    	= IPTCL_MEM_IF_CONTROL_WIDTH; 
parameter MEM_IF_DQ_WIDTH         	= IPTCL_MEM_IF_DQ_WIDTH;
parameter MEM_IF_DQS_WIDTH         	= IPTCL_MEM_IF_DQS_WIDTH;
parameter MEM_IF_READ_DQS_WIDTH    	= IPTCL_MEM_IF_READ_DQS_WIDTH;
parameter MEM_IF_WRITE_DQS_WIDTH   	= IPTCL_MEM_IF_WRITE_DQS_WIDTH;
parameter MEM_IF_ODT_WIDTH         	= IPTCL_MEM_IF_ODT_WIDTH;

// PHY-Controller (AFI) Interface
// The AFI interface widths are derived from the memory interface widths based on full/half rate operations.
// The calculations are done on higher level wrapper.
parameter AFI_ADDR_WIDTH 	        = IPTCL_AFI_ADDR_WIDTH; 
parameter AFI_DM_WIDTH 	        	= IPTCL_AFI_DM_WIDTH; 
parameter AFI_BANKADDR_WIDTH        = IPTCL_AFI_BANKADDR_WIDTH; 
parameter AFI_CS_WIDTH				= IPTCL_AFI_CS_WIDTH;
parameter AFI_CONTROL_WIDTH         = IPTCL_AFI_CONTROL_WIDTH; 
parameter AFI_ODT_WIDTH             = IPTCL_AFI_ODT_WIDTH; 
parameter AFI_DQ_WIDTH				= IPTCL_AFI_DQ_WIDTH; 
parameter AFI_WRITE_DQS_WIDTH		= IPTCL_AFI_WRITE_DQS_WIDTH;
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

parameter MEM_CLK_FREQ = IPTCL_MEM_CLK_FREQ;
parameter DELAY_BUFFER_MODE = "IPTCL_DELAY_BUFFER_MODE";
parameter DQS_DELAY_CHAIN_PHASE_SETTING = IPTCL_DQS_DELAY_CHAIN_PHASE_SETTING;
parameter DQS_PHASE_SHIFT = IPTCL_DQS_PHASE_SHIFT;
parameter DELAYED_CLOCK_PHASE_SETTING = IPTCL_DELAYED_CLOCK_PHASE_SETTING;
parameter AFI_DEBUG_INFO_WIDTH = IPTCL_AFI_DEBUG_INFO_WIDTH;

parameter CALIB_REG_WIDTH = IPTCL_CALIB_REG_WIDTH;


parameter TB_PROTOCOL       = "IPTCL_TB_PROTOCOL";
parameter TB_MEM_CLK_FREQ   = "IPTCL_TB_MEM_CLK_FREQ";
parameter TB_RATE           = "IPTCL_TB_RATE";
parameter TB_MEM_DQ_WIDTH   = "IPTCL_TB_MEM_IF_DQ_WIDTH";
parameter TB_MEM_DQS_WIDTH  = "IPTCL_TB_MEM_IF_READ_DQS_WIDTH";
parameter TB_PLL_DLL_MASTER = "IPTCL_TB_PLL_DLL_MASTER";

parameter FAST_SIM_CALIBRATION = "IPTCL_FAST_SIM_CALIBRATION";

`ifdef PHY_CSR_ENABLED
// CSR Port parameters
parameter       CSR_ADDR_WIDTH                 = IPTCL_CSR_ADDR_WIDTH;
parameter       CSR_DATA_WIDTH                 = IPTCL_CSR_DATA_WIDTH;
parameter       CSR_BE_WIDTH                   = IPTCL_CSR_BE_WIDTH;
`endif

parameter EXTRA_VFIFO_SHIFT = IPTCL_EXTRA_VFIFO_SHIFT;

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
input   [AFI_ADDR_WIDTH-1:0]        afi_addr;		// address
input   [AFI_CS_WIDTH-1:0]          afi_cke;		// clock enable
input   [AFI_CS_WIDTH-1:0]          afi_cs_n;		// chip select


// Write data interface
input   [AFI_WRITE_DQS_WIDTH-1:0]   afi_dqs_burst;
input   [AFI_DQ_WIDTH-1:0]          afi_wdata;			// write data
input	[AFI_WRITE_DQS_WIDTH-1:0]	afi_wdata_valid;	// write data valid, used to maintain write latency required by protocol spec
input   [AFI_DM_WIDTH-1:0]          afi_dm;				// write data mask

// Read data interface
output  [AFI_DQ_WIDTH-1:0]    afi_rdata;           // read data				
input   [AFI_RATE_RATIO-1:0]  afi_rdata_en;        // read enable, used to maintain the read latency calibrated by PHY
input   [AFI_RATE_RATIO-1:0]  afi_rdata_en_full;   // read enable full burst, used to create DQS enable
output  [AFI_RATE_RATIO-1:0]  afi_rdata_valid;     // read data valid

// Status interface
output  afi_cal_success;	// calibration success
output  afi_cal_fail;		// calibration failure

output [AFI_WLAT_WIDTH-1:0]			afi_wlat;
output [AFI_RLAT_WIDTH-1:0]			afi_rlat;
input  [MEM_IF_CK_WIDTH-1:0] afi_mem_clk_disable;

// PHY-Memory Interface

output  [MEM_IF_ADDR_WIDTH-1:0]       mem_ca;        // address
output  [MEM_IF_CK_WIDTH-1:0]         mem_ck;       // differential address and command clock
output  [MEM_IF_CK_WIDTH-1:0]         mem_ck_n;
output  [MEM_IF_CLK_EN_WIDTH-1:0]     mem_cke;      // clock enable
output  [MEM_IF_CS_WIDTH-1:0]         mem_cs_n;     // chip select
`ifdef MEM_IF_DM_PINS_EN
output  [MEM_IF_DM_WIDTH-1:0]         mem_dm;       // data mask
`endif
inout	[MEM_IF_DQ_WIDTH-1:0]         mem_dq;       // bidirectional data bus
inout	[MEM_IF_DQS_WIDTH-1:0]        mem_dqs;      // bidirectional data strobe
inout	[MEM_IF_DQS_WIDTH-1:0]        mem_dqs_n;    // differential bidirectional data strobe


// PLL Interface
input	afi_clk;
input	afi_half_clk;

wire	pll_dqs_ena_clk;

`ifdef PHY_CSR_ENABLED              
// CSR Port input/output
input    [CSR_ADDR_WIDTH - 1: 0]    csr_addr;
input    [CSR_BE_WIDTH - 1: 0]      csr_be;
input                               csr_read_req;
input    [CSR_DATA_WIDTH - 1: 0]    csr_wdata;
input                               csr_write_req;
output   [CSR_DATA_WIDTH - 1: 0]    csr_rdata;
output                              csr_rdata_valid;
output                              csr_waitrequest;
`endif


output  addr_cmd_clk;
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


// END PORT SECTION


// START Abstract-specific versions of phy output and inout ports to be checked

wire  [AFI_DQ_WIDTH-1:0]	    afi_rdata_abst;
wire  [AFI_RATE_RATIO-1:0]	    afi_rdata_valid_abst;
wire  				    afi_cal_success_abst;
wire  				    afi_cal_fail_abst;

wire  [MEM_IF_ADDR_WIDTH-1:0]       mem_ca_abst;
wire  [MEM_IF_CK_WIDTH-1:0]         mem_ck_abst;
wire  [MEM_IF_CLK_EN_WIDTH-1:0]     mem_cke_abst;
wire  [MEM_IF_CS_WIDTH-1:0]         mem_cs_n_abst;
`ifdef MEM_IF_DM_PINS_EN
wire  [MEM_IF_DM_WIDTH-1:0]         mem_dm_abst;
`endif

wire  [MEM_IF_DQ_WIDTH-1:0]         mem_dq_real;
wire  [MEM_IF_DQS_WIDTH-1:0]        mem_dqs_real;
wire  [MEM_IF_DQS_WIDTH-1:0]        mem_dqs_n_real;

wire  [MEM_IF_DQ_WIDTH-1:0]         mem_dq_abst;
wire  [MEM_IF_DQS_WIDTH-1:0]        mem_dqs_abst;
wire  [MEM_IF_DQS_WIDTH-1:0]        mem_dqs_n_abst;

// END Abstract-specific versions of phy output and inout ports to be checked

initial $display("Using %0s core emif simulation models", FAST_SIM_MODEL ? "Fast" : "Regular");


assign afi_cal_success = phy_cal_success;
assign afi_cal_fail = phy_cal_fail;


assign addr_cmd_clk = pll_addr_cmd_clk;
`ifdef NIOS_SEQUENCER
assign avl_clk = pll_avl_clk;
assign scc_clk = pll_config_clk;
`endif


`ifdef QUARTER_RATE
integer MEM_T_WL_int = ((MEM_T_WL+6)/4);
`endif
`ifdef HALF_RATE
integer MEM_T_WL_int = (MEM_T_WL/2);
`endif
`ifdef FULL_RATE
integer MEM_T_WL_int = MEM_T_WL-1;
`endif
assign afi_wlat = MEM_T_WL_int[AFI_WLAT_WIDTH-1:0];


// Exporting read latency is currently not supported
assign afi_rlat = 0;


assign pll_dqs_ena_clk = pll_write_clk;


// ****************************************************
// Real version
// ****************************************************

memphy #(
	.DEVICE_FAMILY(DEVICE_FAMILY),
`ifdef ARRIAIIGX
	.OCT_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
`else
	.OCT_SERIES_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
	.OCT_PARALLEL_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
`endif
	.MEM_ADDRESS_WIDTH(MEM_IF_ADDR_WIDTH),
	.MEM_BANK_WIDTH(MEM_IF_BANKADDR_WIDTH),
	.MEM_CLK_EN_WIDTH(MEM_IF_CLK_EN_WIDTH),
	.MEM_CK_WIDTH(MEM_IF_CK_WIDTH),
	.MEM_ODT_WIDTH(MEM_IF_ODT_WIDTH),
	.MEM_DQS_WIDTH(MEM_IF_DQS_WIDTH),
	.MEM_CHIP_SELECT_WIDTH(MEM_IF_CS_WIDTH),
	.MEM_DM_WIDTH(MEM_IF_DM_WIDTH),
	.MEM_CONTROL_WIDTH(MEM_IF_CONTROL_WIDTH),
	.MEM_DQ_WIDTH(MEM_IF_DQ_WIDTH),
	.MEM_READ_DQS_WIDTH(MEM_IF_READ_DQS_WIDTH),
	.MEM_WRITE_DQS_WIDTH(MEM_IF_WRITE_DQS_WIDTH),
	.AFI_ADDRESS_WIDTH(AFI_ADDR_WIDTH),
	.AFI_BANK_WIDTH(AFI_BANKADDR_WIDTH),
	.AFI_CHIP_SELECT_WIDTH(AFI_CS_WIDTH),
	.AFI_CLK_EN_WIDTH(AFI_CS_WIDTH),
	.AFI_ODT_WIDTH(AFI_ODT_WIDTH),
	.AFI_MAX_WRITE_LATENCY_COUNT_WIDTH(AFI_WLAT_WIDTH),
	.AFI_MAX_READ_LATENCY_COUNT_WIDTH(AFI_RLAT_WIDTH),
	.AFI_DATA_MASK_WIDTH(AFI_DM_WIDTH),
	.AFI_DQS_WIDTH(AFI_WRITE_DQS_WIDTH),
	.AFI_CONTROL_WIDTH(AFI_CONTROL_WIDTH),
	.AFI_DATA_WIDTH(AFI_DQ_WIDTH),
	.AFI_RATE_RATIO(AFI_RATE_RATIO),
	.DLL_DELAY_CTRL_WIDTH(DLL_DELAY_CTRL_WIDTH),
	.MEM_T_RL(MEM_T_RL),
`ifdef PHY_CSR_ENABLED
	.CSR_ADDR_WIDTH(CSR_ADDR_WIDTH),
	.CSR_DATA_WIDTH(CSR_DATA_WIDTH),
	.CSR_BE_WIDTH(CSR_BE_WIDTH),
`endif
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
	.ALTDQDQS_INPUT_FREQ(MEM_CLK_FREQ),
	.ALTDQDQS_DELAY_CHAIN_BUFFER_MODE(DELAY_BUFFER_MODE),
	.ALTDQDQS_DQS_PHASE_SETTING(DQS_DELAY_CHAIN_PHASE_SETTING),
	.ALTDQDQS_DQS_PHASE_SHIFT(DQS_PHASE_SHIFT),
	.ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING(DELAYED_CLOCK_PHASE_SETTING),
	.CALIB_REG_WIDTH(CALIB_REG_WIDTH),
	.AFI_DEBUG_INFO_WIDTH(AFI_DEBUG_INFO_WIDTH),
	.TB_PROTOCOL(TB_PROTOCOL),
	.TB_MEM_CLK_FREQ(TB_MEM_CLK_FREQ),
	.TB_RATE(TB_RATE),
	.TB_MEM_DQ_WIDTH(TB_MEM_DQ_WIDTH),
	.TB_MEM_DQS_WIDTH(TB_MEM_DQS_WIDTH),
	.TB_PLL_DLL_MASTER(TB_PLL_DLL_MASTER),
	.EXTRA_VFIFO_SHIFT(EXTRA_VFIFO_SHIFT),
	.FAST_SIM_MODEL(0),	// Make this the real version
	.FAST_SIM_CALIBRATION(FAST_SIM_CALIBRATION),
	.SCC_DATA_WIDTH(SCC_DATA_WIDTH)
) umemphy_real (
	.global_reset_n(global_reset_n),
	.soft_reset_n(soft_reset_n & ~csr_soft_reset_req),
	.ctl_reset_n(afi_reset_n),
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
	.afi_cke(afi_cke),
	.afi_cs_n(afi_cs_n),
	.afi_dqs_burst(afi_dqs_burst),
	.afi_wdata(afi_wdata),
	.afi_wdata_valid(afi_wdata_valid),
	.afi_dm(afi_dm),
	.afi_rdata(afi_rdata),
	.afi_rdata_en(afi_rdata_en),
	.afi_rdata_en_full(afi_rdata_en_full),
	.afi_rdata_valid(afi_rdata_valid),
	.afi_mem_clk_disable(afi_mem_clk_disable),
	.afi_cal_success(afi_cal_success),
	.afi_cal_fail(afi_cal_fail),
	.mem_ca(mem_ca),
	.mem_ck(mem_ck),
	.mem_ck_n(mem_ck_n),
	.mem_cke(mem_cke),
	.mem_cs_n(mem_cs_n),
`ifdef MEM_IF_DM_PINS_EN
	.mem_dm(mem_dm),
`endif
	.mem_dq(mem_dq_real),
	.mem_dqs(mem_dqs_real),
	.mem_dqs_n(mem_dqs_n_real),
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
	.pll_dqs_ena_clk(pll_dqs_ena_clk),
	.seq_clk(afi_clk), 
`ifdef PHY_CSR_ENABLED
	.csr_write_req                  ( csr_write_req            ),
	.csr_read_req                   ( csr_read_req             ),
	.csr_addr                       ( csr_addr                 ),
	.csr_be                         ( csr_be                   ),
	.csr_wdata                      ( csr_wdata                ),
	.csr_waitrequest                ( csr_waitrequest          ),
	.csr_rdata                      ( csr_rdata                ),
	.csr_rdata_valid                ( csr_rdata_valid          ),
`endif
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
	.phy_afi_wlat(phy_afi_wlat),
	.phy_afi_rlat(phy_afi_rlat),
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
	.dll_clk(dll_clk),
	.dll_pll_locked(dll_pll_locked),
	.dll_phy_delayctrl(dll_delayctrl)
);


// ****************************************************
// Abstract version
// ****************************************************

memphy #(
	.DEVICE_FAMILY(DEVICE_FAMILY),
`ifdef ARRIAIIGX
	.OCT_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
`else
	.OCT_SERIES_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
	.OCT_PARALLEL_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
`endif
	.MEM_ADDRESS_WIDTH(MEM_IF_ADDR_WIDTH),
	.MEM_BANK_WIDTH(MEM_IF_BANKADDR_WIDTH),
	.MEM_CLK_EN_WIDTH(MEM_IF_CLK_EN_WIDTH),
	.MEM_CK_WIDTH(MEM_IF_CK_WIDTH),
	.MEM_ODT_WIDTH(MEM_IF_ODT_WIDTH),
	.MEM_DQS_WIDTH(MEM_IF_DQS_WIDTH),
	.MEM_CHIP_SELECT_WIDTH(MEM_IF_CS_WIDTH),
	.MEM_DM_WIDTH(MEM_IF_DM_WIDTH),
	.MEM_CONTROL_WIDTH(MEM_IF_CONTROL_WIDTH),
	.MEM_DQ_WIDTH(MEM_IF_DQ_WIDTH),
	.MEM_READ_DQS_WIDTH(MEM_IF_READ_DQS_WIDTH),
	.MEM_WRITE_DQS_WIDTH(MEM_IF_WRITE_DQS_WIDTH),
	.AFI_ADDRESS_WIDTH(AFI_ADDR_WIDTH),
	.AFI_BANK_WIDTH(AFI_BANKADDR_WIDTH),
	.AFI_CHIP_SELECT_WIDTH(AFI_CS_WIDTH),
	.AFI_CLK_EN_WIDTH(AFI_CS_WIDTH),
	.AFI_ODT_WIDTH(AFI_ODT_WIDTH),
	.AFI_MAX_WRITE_LATENCY_COUNT_WIDTH(AFI_WLAT_WIDTH),
	.AFI_MAX_READ_LATENCY_COUNT_WIDTH(AFI_RLAT_WIDTH),
	.AFI_DATA_MASK_WIDTH(AFI_DM_WIDTH),
	.AFI_DQS_WIDTH(AFI_WRITE_DQS_WIDTH),
	.AFI_CONTROL_WIDTH(AFI_CONTROL_WIDTH),
	.AFI_DATA_WIDTH(AFI_DQ_WIDTH),
	.AFI_RATE_RATIO(AFI_RATE_RATIO),
	.DLL_DELAY_CTRL_WIDTH(DLL_DELAY_CTRL_WIDTH),
	.MEM_T_RL(MEM_T_RL),
`ifdef PHY_CSR_ENABLED
	.CSR_ADDR_WIDTH(CSR_ADDR_WIDTH),
	.CSR_DATA_WIDTH(CSR_DATA_WIDTH),
	.CSR_BE_WIDTH(CSR_BE_WIDTH),
`endif
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
	.ALTDQDQS_INPUT_FREQ(MEM_CLK_FREQ),
	.ALTDQDQS_DELAY_CHAIN_BUFFER_MODE(DELAY_BUFFER_MODE),
	.ALTDQDQS_DQS_PHASE_SETTING(DQS_DELAY_CHAIN_PHASE_SETTING),
	.ALTDQDQS_DQS_PHASE_SHIFT(DQS_PHASE_SHIFT),
	.ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING(DELAYED_CLOCK_PHASE_SETTING),
	.CALIB_REG_WIDTH(CALIB_REG_WIDTH),
	.AFI_DEBUG_INFO_WIDTH(AFI_DEBUG_INFO_WIDTH),
	.TB_PROTOCOL(TB_PROTOCOL),
	.TB_MEM_CLK_FREQ(TB_MEM_CLK_FREQ),
	.TB_RATE(TB_RATE),
	.TB_MEM_DQ_WIDTH(TB_MEM_DQ_WIDTH),
	.TB_MEM_DQS_WIDTH(TB_MEM_DQS_WIDTH),
	.TB_PLL_DLL_MASTER(TB_PLL_DLL_MASTER),
	.EXTRA_VFIFO_SHIFT(EXTRA_VFIFO_SHIFT),
	.FAST_SIM_MODEL(1),	// Make this the abstract version
	.FAST_SIM_CALIBRATION(FAST_SIM_CALIBRATION),
	.SCC_DATA_WIDTH(SCC_DATA_WIDTH)
) umemphy_real (
	.global_reset_n(global_reset_n),
	.soft_reset_n(soft_reset_n & ~csr_soft_reset_req),
	.ctl_reset_n(),
	.pll_locked(pll_locked),
`ifdef DEBUG_PLL_DYN_PHASE_SHIFT 
	.pll_scanclk(),
	.reset_n_pll_scanclk(),
`endif
`ifdef ARRIAIIGX
	.oct_ctl_value(terminationcontrol),
`else
	.oct_ctl_rt_value(parallelterminationcontrol),
	.oct_ctl_rs_value(seriesterminationcontrol),
`endif
	.afi_addr(afi_addr),
	.afi_cke(afi_cke),
	.afi_cs_n(afi_cs_n),
	.afi_dqs_burst(afi_dqs_burst),
	.afi_wdata(afi_wdata),
	.afi_wdata_valid(afi_wdata_valid),
	.afi_dm(afi_dm),
	.afi_rdata(afi_rdata),
	.afi_rdata_en(afi_rdata_en),
	.afi_rdata_en_full(afi_rdata_en_full),
	.afi_rdata_valid(afi_rdata_valid_abst),
	.afi_mem_clk_disable(afi_mem_clk_disable),
	.afi_cal_success(afi_cal_success_abst),
	.afi_cal_fail(afi_cal_fail_abst),
	.mem_ca(mem_ca_abst),
	.mem_ck(mem_ck_abst),
	.mem_ck_n(),
	.mem_cke(mem_cke_abst),
	.mem_cs_n(mem_cs_n_abst),
`ifdef MEM_IF_DM_PINS_EN
	.mem_dm(mem_dm_abst),
`endif
	.mem_dq(mem_dq_abst),
	.mem_dqs(mem_dqs_abst),
	.mem_dqs_n(mem_dqs_n_abst),
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
	.pll_dqs_ena_clk(pll_dqs_ena_clk),
	.seq_clk(afi_clk), 
`ifdef PHY_CSR_ENABLED
	.csr_write_req                  ( csr_write_req            ),
	.csr_read_req                   ( csr_read_req             ),
	.csr_addr                       ( csr_addr                 ),
	.csr_be                         ( csr_be                   ),
	.csr_wdata                      ( csr_wdata                ),
	.csr_waitrequest                (                          ),
	.csr_rdata                      (                          ),
	.csr_rdata_valid                (                          ),
`endif
`ifdef NIOS_SEQUENCER
	.reset_n_avl_clk(),
	.reset_n_scc_clk(),
	.scc_data(scc_data),
	.scc_dqs_ena(scc_dqs_ena),
	.scc_dqs_io_ena(scc_dqs_io_ena),
	.scc_dq_ena(scc_dq_ena),
	.scc_dm_ena(scc_dm_ena),
	.scc_upd(scc_upd),
	.capture_strobe_tracking(),
`endif
	.phy_clk(),
	.phy_reset_n(),
	.phy_read_latency_counter(phy_read_latency_counter),
	.phy_afi_wlat(phy_afi_wlat),
	.phy_afi_rlat(phy_afi_rlat),
	.phy_read_increment_vfifo_fr(phy_read_increment_vfifo_fr),
	.phy_read_increment_vfifo_hr(phy_read_increment_vfifo_hr),
	.phy_read_increment_vfifo_qr(phy_read_increment_vfifo_qr),
	.phy_reset_mem_stable(phy_reset_mem_stable),
`ifdef NIOS_SEQUENCER
	.phy_cal_debug_info(phy_cal_debug_info),
`endif
	.phy_read_fifo_reset(phy_read_fifo_reset),
	.phy_vfifo_rd_en_override(phy_vfifo_rd_en_override),
	.phy_read_fifo_q(),
	.calib_skip_steps(),
`ifdef HCX_COMPAT_MODE
	.hc_dll_config_dll_offset_ctrl_offsetctrlout(hc_dll_config_dll_offset_ctrl_offsetctrlout),
	.hc_dll_config_dll_offset_ctrl_b_offsetctrlout(hc_dll_config_dll_offset_ctrl_b_offsetctrlout),
`endif
`ifdef NIOS_SEQUENCER
	.pll_avl_clk(pll_avl_clk),
	.pll_config_clk(pll_config_clk),
`endif
	.dll_clk(dll_clk),
	.dll_pll_locked(dll_pll_locked),
	.dll_phy_delayctrl(dll_delayctrl)
);




// ****************************************************
// Comparison section
// ****************************************************


tri_bus_threeway #(.WIDTH(MEM_IF_DQ_WIDTH))  tri_inst_dq  (.mem(mem_dq), .phy_real(mem_dq_real), .phy_abst(mem_dq_abst));
tri_bus_threeway #(.WIDTH(MEM_IF_DQS_WIDTH)) tri_inst_dqs (.mem(mem_dqs), .phy_real(mem_dqs_real), .phy_abst(mem_dqs_abst));
tri_bus_threeway #(.WIDTH(MEM_IF_DQS_WIDTH)) tri_inst_dqs_n (.mem(mem_dqs_n), .phy_real(mem_dqs_n_real), .phy_abst(mem_dqs_n_abst));

reg [MEM_IF_DQ_WIDTH-1:0] dq_capture_real;
reg [MEM_IF_DQ_WIDTH-1:0] dq_capture_abst;
reg [MEM_IF_DQ_WIDTH-1:0] dm_capture_real;
reg [MEM_IF_DQ_WIDTH-1:0] dm_capture_abst;


always @(posedge mem_dqs_real[0] or negedge mem_dqs_real[0])
begin
	dq_capture_real <= mem_dq_real;
`ifdef MEM_IF_DM_PINS_EN
	dm_capture_real <= mem_dm;
`endif
end

always @(posedge mem_dqs_abst[0] or negedge mem_dqs_abst[0])
begin
	dq_capture_abst <= mem_dq_abst;
`ifdef MEM_IF_DM_PINS_EN
	dm_capture_abst <= mem_dm_abst;
`endif
end


wire mem_dqs_cmp;
wire mem_dqs_n_cmp;
wire mem_ck_cmp;
wire mem_cs_n_cmp;
wire afi_cal_success_cmp;
wire afi_rdata_valid_cmp;

function filter_xz_to_zero;
	input in;
	filter_xz_to_zero = (in === 1'b1) ? 1'b1 : 1'b0;
endfunction

function filter_xz_to_one;
	input in;
	filter_xz_to_one = (in === 1'b0) ? 1'b0 : 1'b1;
endfunction

assign mem_dqs_cmp = filter_xz_to_zero(mem_dqs_real[0]) & filter_xz_to_zero(mem_dqs_abst[0]);
assign mem_dqs_n_cmp = ~filter_xz_to_one(mem_dqs_real[0]) & ~filter_xz_to_one(mem_dqs_abst[0]); 
assign mem_ck_cmp = mem_ck & mem_ck_abst;
assign mem_cs_n_cmp = & (~(~mem_cs_n & ~mem_cs_n_abst));
assign afi_cal_success_cmp = afi_cal_success & afi_cal_success_abst;
assign afi_rdata_valid_cmp = afi_rdata_valid[0] & afi_rdata_valid_abst[0];

cmp_signals #(.NAME("CA_HI"), .WIDTH(MEM_IF_ADDR_WIDTH)) cmp_ca_hi (
	 .clk(mem_ck_cmp),
	 .valid(~mem_cs_n_cmp),
	 .a(mem_ca),
	 .b(mem_ca_abst)
);

cmp_signals #(.NAME("CA_LO"), .WIDTH(MEM_IF_ADDR_WIDTH)) cmp_ca_lo (
	 .clk(mem_ck_n_cmp),
	 .valid(~mem_cs_n_cmp),
	 .a(mem_ca),
	 .b(mem_ca_abst)
);

cmp_signals #(.NAME("DQ_HI"), .WIDTH(MEM_IF_DQ_WIDTH)) cmp_dq_hi (
	.clk(mem_dqs_cmp),
	.valid(afi_cal_success_cmp),
	.a(dq_capture_real),
	.b(dq_capture_abst)
	);

cmp_signals #(.NAME("DQ_LO"), .WIDTH(MEM_IF_DQ_WIDTH)) cmp_dq_lo (
	.clk(mem_dqs_n_cmp),
	.valid(afi_cal_success_cmp),
	.a(dq_capture_real),
	.b(dq_capture_abst)
	);

`ifdef MEM_IF_DM_PINS_EN
cmp_signals #(.NAME("DM_HI"), .WIDTH(MEM_IF_DM_WIDTH)) cmp_dm_hi (
	.clk(mem_dqs_cmp),
	.valid(afi_cal_success_cmp),
	.a(dm_capture_real),
	.b(dm_capture_abst)
	);

cmp_signals #(.NAME("DM_LO"), .WIDTH(MEM_IF_DM_WIDTH)) cmp_dm_lo (
	.clk(mem_dqs_n_cmp),
	.valid(afi_cal_success_cmp),
	.a(dm_capture_real),
	.b(dm_capture_abst)
	);
`endif


cmp_signals #(.NAME("RDATA_VALID"), .WIDTH(1)) cmp_rdata_valid (
	.clk(afi_clk),
	.valid(1'b1),
	.a(afi_rdata_valid[0]),
	.b(afi_rdata_valid_abst[0])
	);
cmp_signals #(.NAME("RDATA"), .WIDTH(AFI_DQ_WIDTH)) cmp_rdata (
	.clk(afi_clk),
	.valid(afi_rdata_valid_cmp),
	.a(afi_rdata),
	.b(afi_rdata_abst)
	);
	   
endmodule




module tri_bus_threeway
	#(parameter DELAY = 10, 
	  parameter WIDTH = 1)
	(inout wire [WIDTH-1:0] mem, 
	inout wire [WIDTH-1:0] phy_real,
	inout wire [WIDTH-1:0] phy_abst);

generate
genvar i;
for (i = 0; i < WIDTH; i = i + 1)
begin
	reg mem_dly = 1'bz;
	reg phy_real_dly = 1'bz;
	reg phy_abst_dly = 1'bz;

	always @(mem[i])
	begin
		if (phy_real_dly === 1'bz || mem[i] === 1'bz)
		begin
			mem_dly <= #(DELAY) mem[i];
		end
	end

	always @(phy_real[i])
	begin
		if (mem_dly === 1'bz || phy_real[i] === 1'bz)
		begin
			phy_real_dly <= #(DELAY) phy_real[i];
		end
	end

	always @(phy_abst[i])
	begin
		if (mem_dly === 1'bz || phy_abst[i] === 1'bz)
		begin
			phy_abst_dly <= #(DELAY) phy_abst[i];
		end
	end

	assign mem[i] = phy_real_dly;
	assign phy_real[i] = mem_dly;
	assign phy_abst[i] = mem_dly;
end
endgenerate

endmodule



module cmp_signals
#(
	parameter NAME = "",
	parameter WIDTH = 1,
	parameter DELAY = 10
)
(
	input clk,
	input valid,
 	input [WIDTH-1:0] a,
 	input [WIDTH-1:0] b
 );

always @(posedge clk)
begin
	#(DELAY); 
	if (valid)
	begin
		if (a == a && a !== b)
		begin
			$display("%0t:      --- %s CHECK FAILED --- %h !== %h", 
				 $time, NAME, a, b);
			@clk;
			@clk;
			@clk;
			$finish;
		end
	end
end

endmodule

