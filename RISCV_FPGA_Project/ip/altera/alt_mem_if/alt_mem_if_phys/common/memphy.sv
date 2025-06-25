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


// ******************************************************************************************************************************** 
// File name: memphy.v
// This file instantiates all the main components of the PHY. 
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

module memphy(
	global_reset_n,
	soft_reset_n,
	ctl_reset_n,
	ctl_reset_export_n,
	pll_locked,
`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
	pll_scanclk,
	reset_n_pll_scanclk,
`endif
`ifdef ARRIAIIGX
	oct_ctl_value,
`else
	oct_ctl_rs_value,
	oct_ctl_rt_value,
`endif
	afi_addr,
`ifdef RLDRAMX
	afi_ba,
	afi_cas_n,
	afi_cs_n,
	afi_we_n,
 `ifdef RLDRAM3
	afi_rst_n,
 `endif
`endif
`ifdef  QDRII
	afi_wps_n,
	afi_rps_n,
	afi_doff_n,
`endif
`ifdef DDRII_SRAM
	afi_ld_n,
	afi_rw_n,
	afi_doff_n,
`endif
`ifdef DDRX_LPDDRX
	afi_cke,
	afi_cs_n,
`ifdef DDRX
	afi_ba,
	afi_cas_n,
`ifndef LPDDR1
	afi_odt,
`endif
	afi_ras_n,
	afi_we_n,
`endif
`ifdef DDR3
	afi_rst_n,
`endif
	afi_mem_clk_disable,
	afi_dqs_burst,
	afi_wlat,
	afi_rlat,
`endif
	afi_wdata,
	afi_wdata_valid,
	afi_dm,
	afi_rdata,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
`ifdef NIOS_SEQUENCER
	afi_cal_debug_info,
`endif
	afi_cal_success,
	afi_cal_fail,
`ifdef USE_SHADOW_REGS
	afi_wrank,
	afi_rrank,
`endif
`ifdef PINGPONGPHY_EN
	afi_rdata_en_1t,
	afi_rdata_en_full_1t,
	afi_rdata_valid_1t,
	mux_sel,
`endif
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
`ifdef RLDRAMX
	mem_a,
	mem_ba,
	mem_cs_n,
`ifdef MEM_IF_DM_PINS_EN	
	mem_dm,
`endif	
	mem_we_n,
	mem_ref_n,
	mem_ck,
	mem_ck_n,
	mem_dk,
	mem_dk_n,
	mem_qk,
	mem_qk_n,
	mem_dq,
 `ifdef RLDRAM3
	mem_reset_n,
 `endif 
`endif
`ifdef QDRII
	mem_d,
	mem_wps_n,
	mem_bws_n,
	mem_a,
	mem_q,
	mem_rps_n,
	mem_k,
	mem_k_n,
	mem_cq,
	mem_cq_n,
	mem_doff_n,
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
	dll_offsetdelay_in,
	`endif
  `endif
`endif
`endif
`ifdef DDRII_SRAM
	mem_k,
	mem_k_n,
	mem_cq,
	mem_cq_n,
	mem_c,
	mem_c_n,
	mem_bws_n,
	mem_ld_n,
	mem_rw_n,
	mem_a,
	mem_dq,
	mem_zq,
	mem_doff_n,
`endif
`ifdef DDRX
	mem_a,
	mem_ba,
	mem_ck,
	mem_ck_n,
	mem_cke,
	mem_cs_n,
`ifdef MEM_IF_DM_PINS_EN
	mem_dm,
`endif
`ifndef LPDDR1
	mem_odt,
`endif
	mem_ras_n,
	mem_cas_n,
	mem_we_n,
`ifdef AC_PARITY
	mem_ac_parity,
	mem_err_out_n,
	parity_error_n,
`endif
`ifdef DDR3
	mem_reset_n,
`endif
	mem_dq,
	mem_dqs,
`ifdef MEM_IF_DQSN_EN
	mem_dqs_n,
`endif
`endif
`ifdef LPDDR2
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
`endif
`ifdef NIOS_SEQUENCER
	reset_n_scc_clk,
	reset_n_avl_clk,
	scc_data,
	scc_dqs_ena,
	scc_dqs_io_ena,
	scc_dq_ena,
	scc_dm_ena,
	scc_upd,
	scc_sr_dqsenable_delayctrl,
	scc_sr_dqsdisablen_delayctrl,
	scc_sr_multirank_delayctrl,
	capture_strobe_tracking,
`endif
	phy_clk,
	phy_reset_n,
	phy_read_latency_counter,
`ifdef DDRX_LPDDRX
	phy_afi_wlat,
	phy_afi_rlat,
`endif
	phy_num_write_fr_cycle_shifts,
	phy_read_increment_vfifo_fr,
	phy_read_increment_vfifo_hr,
	phy_read_increment_vfifo_qr,
	phy_reset_mem_stable,
`ifdef NIOS_SEQUENCER
	phy_cal_debug_info,
`endif
	phy_read_fifo_reset,
	phy_vfifo_rd_en_override,
	phy_read_fifo_q,
	calib_skip_steps,
	pll_afi_clk,
	pll_afi_half_clk,
	pll_addr_cmd_clk,
	pll_mem_clk,
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	pll_mem_phy_clk,
	pll_afi_phy_clk,
`endif
	pll_write_clk,
	pll_write_clk_pre_phy_clk,
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
`ifdef DDRX_LPDDRX
	pll_dqs_ena_clk,
`endif
	seq_clk,
`ifdef NIOS_SEQUENCER
	pll_avl_clk,
	pll_config_clk,
`endif
`ifdef HCX_COMPAT_MODE
	hc_dll_config_dll_offset_ctrl_offsetctrlout,
	hc_dll_config_dll_offset_ctrl_b_offsetctrlout,
`endif
	dll_clk,
    dll_pll_locked,
	dll_phy_delayctrl
);

// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver 
parameter DEVICE_FAMILY = "";

// On-chip termination
`ifdef ARRIAIIGX
parameter OCT_TERM_CONTROL_WIDTH = ""; 
`else
parameter OCT_SERIES_TERM_CONTROL_WIDTH   = ""; 
parameter OCT_PARALLEL_TERM_CONTROL_WIDTH = ""; 
`endif

// PHY-Memory Interface
// Memory device specific parameters, they are set according to the memory spec
parameter MEM_ADDRESS_WIDTH     = ""; 
`ifdef RLDRAMX
parameter MEM_BANK_WIDTH        = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter MEM_BANK_WIDTH        = "";
parameter MEM_CLK_EN_WIDTH 	    = ""; 
parameter MEM_CK_WIDTH 	    	= ""; 
parameter MEM_ODT_WIDTH 		= ""; 
parameter MEM_DQS_WIDTH         = "";
`endif
parameter MEM_CHIP_SELECT_WIDTH = ""; 
parameter MEM_CONTROL_WIDTH     = ""; 
parameter MEM_DM_WIDTH          = ""; 
parameter MEM_DQ_WIDTH          = ""; 
parameter MEM_READ_DQS_WIDTH    = ""; 
parameter MEM_WRITE_DQS_WIDTH   = "";
parameter MEM_IF_NUMBER_OF_RANKS	= "";

// PHY-Controller (AFI) Interface
// The AFI interface widths are derived from the memory interface widths based on full/half rate operations
// The calculations are done on higher level wrapper
parameter AFI_ADDRESS_WIDTH         = ""; 
`ifdef RLDRAMX
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
`endif
parameter AFI_DEBUG_INFO_WIDTH = "";
`ifdef DDRX_LPDDRX
parameter AFI_BANK_WIDTH            = "";
parameter AFI_CHIP_SELECT_WIDTH     = "";
parameter AFI_CLK_EN_WIDTH     		= "";
parameter AFI_ODT_WIDTH     		= "";
parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH = "";
parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH = "";
`endif
parameter AFI_DATA_MASK_WIDTH       = "";
parameter AFI_CONTROL_WIDTH         = "";
parameter AFI_DATA_WIDTH            = "";
parameter AFI_DQS_WIDTH             = "";
parameter AFI_RATE_RATIO            = "";
parameter AFI_RRANK_WIDTH	    = "";
parameter AFI_WRANK_WIDTH	    = "";

// DLL Interface
// The DLL delay output control is always 6 bits for current existing devices
parameter DLL_DELAY_CTRL_WIDTH  = "";

parameter SCC_DATA_WIDTH = "";

// Read Datapath parameters for timing purposes
parameter NUM_SUBGROUP_PER_READ_DQS        = "";
parameter QVLD_EXTRA_FLOP_STAGES		   = "";
parameter QVLD_WR_ADDRESS_OFFSET		   = "";

// Read Datapath parameters, the values should not be changed unless the intention is to change the architecture
parameter READ_VALID_FIFO_SIZE             = "";
parameter READ_FIFO_SIZE                   = "";

// Latency calibration parameters
parameter MAX_LATENCY_COUNT_WIDTH          = "";
parameter MAX_READ_LATENCY                 = "";

// Write Datapath
// The sequencer uses this value to control write latency during calibration
parameter MAX_WRITE_LATENCY_COUNT_WIDTH = "";
parameter NUM_WRITE_PATH_FLOP_STAGES	= "";
parameter NUM_WRITE_FR_CYCLE_SHIFTS		= "";

// Add register stage between core and periphery for C2P transfers
parameter REGISTER_C2P = "";

// MemCK clock phase select setting
parameter LDC_MEM_CK_CPS_PHASE = "";

// Address/Command Datapath
parameter NUM_AC_FR_CYCLE_SHIFTS = "";

parameter MEM_T_RL              = "";

`ifdef DDR2
parameter MR1_ODS				= "";
parameter MR1_RTT				= "";
`endif
`ifdef DDR3
parameter MR1_ODS               = "";
parameter MR1_RTT               = "";
parameter MR2_RTT_WR            = ""; 
`endif
`ifdef LPDDR1
parameter MR1_DS				= "";
`endif

`ifdef DDRX_LPDDRX
parameter ALTDQDQS_INPUT_FREQ = "";
parameter ALTDQDQS_DELAY_CHAIN_BUFFER_MODE = "";
parameter ALTDQDQS_DQS_PHASE_SETTING = "";
parameter ALTDQDQS_DQS_PHASE_SHIFT = "";
parameter ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING = "";
`endif

`ifdef PHY_CSR_ENABLED
// CSR Port parameters
parameter       CSR_ADDR_WIDTH                 = "";
parameter       CSR_DATA_WIDTH                 = "";
parameter       CSR_BE_WIDTH                   = "";
`endif

parameter EXTRA_VFIFO_SHIFT = 0;

parameter TB_PROTOCOL        = "";
parameter TB_MEM_CLK_FREQ    = "";
parameter TB_RATE            = "";
parameter TB_MEM_DQ_WIDTH    = "";
parameter TB_MEM_DQS_WIDTH   = "";
parameter TB_PLL_DLL_MASTER  = "";

parameter FAST_SIM_MODEL = "";
parameter FAST_SIM_CALIBRATION = "";
 
// Local parameters
localparam DOUBLE_MEM_DQ_WIDTH = MEM_DQ_WIDTH * 2;
localparam HALF_AFI_DATA_WIDTH = AFI_DATA_WIDTH / 2;

// Width of the calibration status register used to control calibration skipping.
parameter CALIB_REG_WIDTH = "";

// The number of AFI Resets to generate
localparam NUM_AFI_RESET = 4;

// Read valid predication parameters
`ifdef FULL_RATE
localparam READ_VALID_FIFO_WRITE_MEM_DEPTH	= READ_VALID_FIFO_SIZE; // write operates on full rate clock
`endif
`ifdef HALF_RATE
localparam READ_VALID_FIFO_WRITE_MEM_DEPTH	= READ_VALID_FIFO_SIZE / 2; // write operates on half rate clock
`endif
`ifdef QUARTER_RATE
localparam READ_VALID_FIFO_WRITE_MEM_DEPTH	= READ_VALID_FIFO_SIZE / 4; // write operates on quarter rate clock
`endif
`ifdef VFIFO_FULL_RATE
localparam READ_VALID_FIFO_READ_MEM_DEPTH	= READ_VALID_FIFO_SIZE; // valid-read-prediction operates on full rate clock
localparam READ_VALID_FIFO_PER_DQS_WIDTH	= 1; // valid fifo output is a full-rate signal
`endif
`ifdef VFIFO_HALF_RATE
localparam READ_VALID_FIFO_READ_MEM_DEPTH	= READ_VALID_FIFO_SIZE / 2; // valid-read-prediction operates on half rate clock
localparam READ_VALID_FIFO_PER_DQS_WIDTH	= 2; // valid fifo output is a half-rate signal
`endif
`ifdef VFIFO_QUARTER_RATE
localparam READ_VALID_FIFO_READ_MEM_DEPTH	= READ_VALID_FIFO_SIZE / 4; // valid-read-prediction operates on quarter rate clock
localparam READ_VALID_FIFO_PER_DQS_WIDTH	= 2; // valid fifo output is a half-rate signal (converted from a quarter-rate signal)
`endif
localparam READ_VALID_FIFO_WIDTH		= READ_VALID_FIFO_PER_DQS_WIDTH * MEM_READ_DQS_WIDTH;
localparam READ_VALID_FIFO_WRITE_ADDR_WIDTH	= ceil_log2(READ_VALID_FIFO_WRITE_MEM_DEPTH);
localparam READ_VALID_FIFO_READ_ADDR_WIDTH	= ceil_log2(READ_VALID_FIFO_READ_MEM_DEPTH);

// Data resynchronization FIFO
`ifdef READ_FIFO_HALF_RATE
localparam READ_FIFO_WRITE_MEM_DEPTH		= READ_FIFO_SIZE / 2; // data is written on half rate clock
`else
localparam READ_FIFO_WRITE_MEM_DEPTH		= READ_FIFO_SIZE; // data is written on full rate clock
`endif
`ifdef FULL_RATE
localparam READ_FIFO_READ_MEM_DEPTH			= READ_FIFO_SIZE; // data is read out on full rate clock
`else
localparam READ_FIFO_READ_MEM_DEPTH			= READ_FIFO_SIZE / 2; // data is read out on half rate clock
`endif
localparam READ_FIFO_WRITE_ADDR_WIDTH		= ceil_log2(READ_FIFO_WRITE_MEM_DEPTH);
localparam READ_FIFO_READ_ADDR_WIDTH		= ceil_log2(READ_FIFO_READ_MEM_DEPTH);

// Sequencer parameters
localparam SEQ_ADDRESS_WIDTH		= AFI_ADDRESS_WIDTH;
`ifdef RLDRAMX
localparam SEQ_BANK_WIDTH			= AFI_BANK_WIDTH;
localparam SEQ_CHIP_SELECT_WIDTH	= AFI_CHIP_SELECT_WIDTH;
`endif
`ifdef DDRX_LPDDRX
localparam SEQ_BANK_WIDTH			= AFI_BANK_WIDTH;
localparam SEQ_CHIP_SELECT_WIDTH	= AFI_CHIP_SELECT_WIDTH;
localparam SEQ_CLK_EN_WIDTH			= AFI_CLK_EN_WIDTH;
localparam SEQ_ODT_WIDTH			= AFI_ODT_WIDTH;
`endif
localparam SEQ_DATA_MASK_WIDTH		= AFI_DATA_MASK_WIDTH;
localparam SEQ_CONTROL_WIDTH		= AFI_CONTROL_WIDTH;
localparam SEQ_DATA_WIDTH			= AFI_DATA_WIDTH;
localparam SEQ_DQS_WIDTH			= AFI_DQS_WIDTH;

localparam MAX_LATENCY_COUNT_WIDTH_SAFE    = (MAX_LATENCY_COUNT_WIDTH < 5)? 5 :  MAX_LATENCY_COUNT_WIDTH;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 



// ******************************************************************************************************************************** 
// BEGIN PORT SECTION

//  Reset Interface
input	global_reset_n;		// Resets (active-low) the whole system (all PHY logic + PLL)
input	soft_reset_n;		// Resets (active-low) PHY logic only, PLL is NOT reset
input	pll_locked;			// Indicates that PLL is locked
output	ctl_reset_export_n;	// Asynchronously asserted and synchronously de-asserted on afi_clk domain
output	ctl_reset_n;		// Asynchronously asserted and synchronously de-asserted on afi_clk domain

`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
output	pll_scanclk;
output	reset_n_pll_scanclk;
`endif

`ifdef ARRIAIIGX
input   [OCT_TERM_CONTROL_WIDTH-1:0] oct_ctl_value;
`else
input   [OCT_SERIES_TERM_CONTROL_WIDTH-1:0] oct_ctl_rs_value;
input   [OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] oct_ctl_rt_value;
`endif

// PHY-Controller Interface, AFI 2.0
// Control Interface
input   [AFI_ADDRESS_WIDTH-1:0] afi_addr;       // address

`ifdef RLDRAMX
input   [AFI_BANK_WIDTH-1:0]    afi_ba;         // bank
input   [AFI_CONTROL_WIDTH-1:0] afi_cas_n;      // cas_n, cs_n, we_n together determines the type of command
input   [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n;   // refer to RLDRAMx spec for details
input   [AFI_CONTROL_WIDTH-1:0] afi_we_n;
 `ifdef RLDRAM3
input   [AFI_CONTROL_WIDTH-1:0] afi_rst_n; 
 `endif
`endif

`ifdef QDRII
input   [AFI_CONTROL_WIDTH-1:0] afi_wps_n;      // write command
input   [AFI_CONTROL_WIDTH-1:0] afi_rps_n;      // read command
input   [AFI_CONTROL_WIDTH-1:0] afi_doff_n;      // 
`endif

`ifdef DDRII_SRAM
input   [AFI_CONTROL_WIDTH-1:0] afi_ld_n;       // load command
input   [AFI_CONTROL_WIDTH-1:0] afi_rw_n;       // read/write command
input   [AFI_CONTROL_WIDTH-1:0] afi_doff_n;      // 
`endif

`ifdef DDRX_LPDDRX
input   [AFI_CLK_EN_WIDTH-1:0] afi_cke;
input   [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n;
`ifdef DDRX
input   [AFI_BANK_WIDTH-1:0]    afi_ba;
input   [AFI_CONTROL_WIDTH-1:0] afi_cas_n;
`ifndef LPDDR1
input   [AFI_ODT_WIDTH-1:0] afi_odt;
`endif
input   [AFI_CONTROL_WIDTH-1:0] afi_ras_n;
input   [AFI_CONTROL_WIDTH-1:0] afi_we_n;
`endif
`ifdef DDR3
input   [AFI_CONTROL_WIDTH-1:0] afi_rst_n;
`endif
input   [MEM_CK_WIDTH-1:0] afi_mem_clk_disable;
input   [AFI_DQS_WIDTH-1:0]	afi_dqs_burst;	
output  [AFI_MAX_WRITE_LATENCY_COUNT_WIDTH-1:0] afi_wlat;
output  [AFI_MAX_READ_LATENCY_COUNT_WIDTH-1:0]  afi_rlat;
`endif

// Write data interface
input   [AFI_DATA_WIDTH-1:0]    afi_wdata;              // write data
input   [AFI_DQS_WIDTH-1:0]		afi_wdata_valid;    	// write data valid, used to maintain write latency required by protocol spec
input   [AFI_DATA_MASK_WIDTH-1:0]   afi_dm;             // write data mask

// Read data interface
output  [AFI_DATA_WIDTH-1:0]    afi_rdata;              // read data                
input   [AFI_RATE_RATIO-1:0]    afi_rdata_en;           // read enable, used to maintain the read latency calibrated by PHY
input   [AFI_RATE_RATIO-1:0]    afi_rdata_en_full;      // read enable full burst, used to create DQS enable
output  [AFI_RATE_RATIO-1:0]    afi_rdata_valid;        // read data valid

// Status interface
input  afi_cal_success;    // calibration success
input  afi_cal_fail;       // calibration failure
`ifdef NIOS_SEQUENCER
output [AFI_DEBUG_INFO_WIDTH - 1:0] afi_cal_debug_info;
`endif

// PHY-Memory Interface
`ifdef RLDRAMX
// Ports names are according to RLDRAMx spec, refer to spec for details
output  [MEM_ADDRESS_WIDTH-1:0] mem_a;          // address
output  [MEM_BANK_WIDTH-1:0]    mem_ba;         // bank
output  [MEM_CHIP_SELECT_WIDTH-1:0] mem_cs_n;   // cs_n, we_n, ref_n together determines the type of command
output  [MEM_CONTROL_WIDTH-1:0] mem_we_n;
output  [MEM_CONTROL_WIDTH-1:0] mem_ref_n;
 `ifdef RLDRAM3
output  [MEM_CONTROL_WIDTH-1:0] mem_reset_n; 
 `endif
 `ifdef MEM_IF_DM_PINS_EN 
output  [MEM_DM_WIDTH-1:0]  mem_dm;             // data mask
 `endif
output  mem_ck;                                 // differential address and command clock
output  mem_ck_n;
output  [MEM_WRITE_DQS_WIDTH-1:0] mem_dk;       // differential write clock
output  [MEM_WRITE_DQS_WIDTH-1:0] mem_dk_n;

input   [MEM_READ_DQS_WIDTH-1:0] mem_qk;        // differential read clock 
input   [MEM_READ_DQS_WIDTH-1:0] mem_qk_n;

inout   [MEM_DQ_WIDTH-1:0]  mem_dq;             // bidirectional data bus
`endif

`ifdef QDRII
// Port names are according to QDRII spec, refer to spec for details
output  [MEM_DQ_WIDTH-1:0] mem_d;               // write data
output  [MEM_CONTROL_WIDTH-1:0] mem_wps_n;      // write command
output  [MEM_DM_WIDTH-1:0] mem_bws_n;           // byte enable
output  [MEM_ADDRESS_WIDTH-1:0] mem_a;          // address
output  [MEM_CONTROL_WIDTH-1:0] mem_rps_n;      // read command
output  [MEM_CONTROL_WIDTH-1:0] mem_doff_n;     // 0=QDRI mode, 1=QDRII mode, tied to 1 since only QDRII support is required 
output  [MEM_WRITE_DQS_WIDTH-1:0] mem_k;        // complementary input clock to memory device
output  [MEM_WRITE_DQS_WIDTH-1:0] mem_k_n;
input   [MEM_READ_DQS_WIDTH-1:0] mem_cq;        // complementary output clock to memory device
input   [MEM_READ_DQS_WIDTH-1:0] mem_cq_n;
input   [MEM_DQ_WIDTH-1:0] mem_q;               // read data

`ifdef RTL_CALIB
`ifdef STRATIXV
`ifndef NIOS_SEQUENCER
input	mem_config_clk; 
input	mem_config_datain; 
input   mem_config_update; 

input	[MEM_READ_DQS_WIDTH-1:0] mem_config_cqdqs_ena; 
input	[MEM_READ_DQS_WIDTH-1:0] mem_config_cq_io_ena; 
input	[MEM_DQ_WIDTH-1:0] mem_config_rio_ena; 

input	[MEM_WRITE_DQS_WIDTH-1:0] mem_config_kdqs_ena; 
input	[MEM_WRITE_DQS_WIDTH-1:0] mem_config_k_io_ena; 
input	[MEM_DQ_WIDTH-1:0] mem_config_wio_ena; 
input	[MEM_DM_WIDTH-1:0] mem_config_dm_ena; 
input   [DLL_DELAY_CTRL_WIDTH-1:0]  dll_offsetdelay_in;
`endif
`endif
`endif

`endif

`ifdef DDRII_SRAM
// Port names are according to DDRII SRAM spec, refer to spec for details
output  [MEM_WRITE_DQS_WIDTH-1:0] mem_k;      // complementary clocks used to caputre inputs to the memory device
output  [MEM_WRITE_DQS_WIDTH-1:0] mem_k_n;
input   [MEM_READ_DQS_WIDTH-1:0]  mem_cq;     // complementary output clocks from memory device
input   [MEM_READ_DQS_WIDTH-1:0]  mem_cq_n;
output  [MEM_READ_DQS_WIDTH-1:0] mem_c;       // complementary clocks to clock out read data from memory device
output  [MEM_READ_DQS_WIDTH-1:0] mem_c_n;
output  [MEM_DM_WIDTH-1:0]    mem_bws_n;      // byte enable
output  [MEM_CONTROL_WIDTH-1:0]   mem_ld_n;   // low when a bus cycle sequence is defined
output  [MEM_CONTROL_WIDTH-1:0]   mem_rw_n;   // read/write command
output  [MEM_ADDRESS_WIDTH-1:0]  mem_a;          // address
inout   [MEM_DQ_WIDTH-1:0]    mem_dq;         // bidirectional data bus
output  [MEM_CONTROL_WIDTH-1:0]   mem_zq;     // tied to 1 for minimum impedance mode
output  [MEM_CONTROL_WIDTH-1:0]   mem_doff_n; // tied to 1 to always enable the DLL in the memory device
`endif

`ifdef DDRX
output  [MEM_ADDRESS_WIDTH-1:0] mem_a;
output  [MEM_BANK_WIDTH-1:0]    mem_ba;
output  [MEM_CK_WIDTH-1:0]	mem_ck;
output  [MEM_CK_WIDTH-1:0]	mem_ck_n;
output  [MEM_CLK_EN_WIDTH-1:0] mem_cke;
output  [MEM_CHIP_SELECT_WIDTH-1:0] mem_cs_n;
`ifdef MEM_IF_DM_PINS_EN
output  [MEM_DM_WIDTH-1:0]  mem_dm;
`endif
`ifndef LPDDR1
output  [MEM_ODT_WIDTH-1:0] mem_odt;
`endif
output  [MEM_CONTROL_WIDTH-1:0] mem_ras_n;
output  [MEM_CONTROL_WIDTH-1:0] mem_cas_n;
output  [MEM_CONTROL_WIDTH-1:0] mem_we_n;
`ifdef AC_PARITY
output  [MEM_CONTROL_WIDTH-1:0] mem_ac_parity;
input   [MEM_CONTROL_WIDTH-1:0] mem_err_out_n;
output	parity_error_n;
`endif
`ifdef DDR3
output  mem_reset_n;
`endif
inout   [MEM_DQ_WIDTH-1:0]  mem_dq;
inout   [MEM_DQS_WIDTH-1:0] mem_dqs;
`ifdef MEM_IF_DQSN_EN
inout   [MEM_DQS_WIDTH-1:0] mem_dqs_n;
`endif
`endif

`ifdef LPDDR2
output  [MEM_ADDRESS_WIDTH-1:0] mem_ca;
output  [MEM_CK_WIDTH-1:0]	mem_ck;
output  [MEM_CK_WIDTH-1:0]	mem_ck_n;
output  [MEM_CLK_EN_WIDTH-1:0] mem_cke;
output  [MEM_CHIP_SELECT_WIDTH-1:0] mem_cs_n;
`ifdef MEM_IF_DM_PINS_EN
output  [MEM_DM_WIDTH-1:0]  mem_dm;
`endif
inout   [MEM_DQ_WIDTH-1:0]  mem_dq;
inout   [MEM_DQS_WIDTH-1:0] mem_dqs;
inout   [MEM_DQS_WIDTH-1:0] mem_dqs_n;
`endif


`ifdef NIOS_SEQUENCER
output	reset_n_scc_clk;
output	reset_n_avl_clk;
input        [SCC_DATA_WIDTH-1:0]  scc_data;
input    [MEM_READ_DQS_WIDTH-1:0]  scc_dqs_ena;
input    [MEM_READ_DQS_WIDTH-1:0]  scc_dqs_io_ena;
input          [MEM_DQ_WIDTH-1:0]  scc_dq_ena;
input          [MEM_DM_WIDTH-1:0]  scc_dm_ena;
`ifdef USE_SHADOW_REGS
input    [MEM_READ_DQS_WIDTH-1:0]  scc_upd;
`else
input    [0:0]                     scc_upd;
`endif
input    [7:0]                     scc_sr_dqsenable_delayctrl;
input    [7:0]                     scc_sr_dqsdisablen_delayctrl;
input    [7:0]                     scc_sr_multirank_delayctrl;
output   [MEM_READ_DQS_WIDTH-1:0]  capture_strobe_tracking;
`endif

output  phy_clk;
output  phy_reset_n;

input  [MAX_LATENCY_COUNT_WIDTH-1:0]  phy_read_latency_counter;
`ifdef DDRX_LPDDRX
input  [AFI_MAX_WRITE_LATENCY_COUNT_WIDTH-1:0]  phy_afi_wlat;
input  [AFI_MAX_READ_LATENCY_COUNT_WIDTH-1:0]  phy_afi_rlat;
`endif
input  [MEM_WRITE_DQS_WIDTH*2-1:0]  phy_num_write_fr_cycle_shifts;
input  [MEM_READ_DQS_WIDTH-1:0]     phy_read_increment_vfifo_fr;
input  [MEM_READ_DQS_WIDTH-1:0]     phy_read_increment_vfifo_hr;
input  [MEM_READ_DQS_WIDTH-1:0]     phy_read_increment_vfifo_qr;
input                               phy_reset_mem_stable;
`ifdef NIOS_SEQUENCER
input   [AFI_DEBUG_INFO_WIDTH - 1:0]  phy_cal_debug_info;
`endif
input       [MEM_READ_DQS_WIDTH-1:0]  phy_read_fifo_reset;
input       [MEM_READ_DQS_WIDTH-1:0]  phy_vfifo_rd_en_override;
output          [AFI_DATA_WIDTH-1:0]  phy_read_fifo_q;

output         [CALIB_REG_WIDTH-1:0]  calib_skip_steps;


// PLL Interface
input	pll_afi_clk;		// clocks AFI interface logic
input	pll_afi_half_clk;	// 
input	pll_addr_cmd_clk;	// clocks address/command DDIO
input	pll_mem_clk;		// output clock to memory
input	pll_write_clk;		// clocks write data DDIO
input	pll_write_clk_pre_phy_clk;
`ifdef QUARTER_RATE
input	pll_hr_clk;			// clocks the half-rate domain
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
input	pll_p2c_read_clk;	// clocks the read-side of the read-fifo in I/O periphery
input	pll_c2p_write_clk;	// clocks the half-rate register in I/O periphery, in HR or QR mode
`endif
`ifdef USE_DR_CLK
input	pll_dr_clk;		// clocks 2X FF in I/O periphery
input	pll_dr_clk_pre_phy_clk;
`endif
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
input pll_mem_phy_clk;
input pll_afi_phy_clk;
`endif
`ifdef DDRX_LPDDRX
input	pll_dqs_ena_clk;
`endif
input	seq_clk;
`ifdef NIOS_SEQUENCER
input	pll_avl_clk;
input	pll_config_clk;
`endif


// DLL Interface
output  dll_clk;
output  dll_pll_locked;
input   [DLL_DELAY_CTRL_WIDTH-1:0]  dll_phy_delayctrl;   // dll output used to control the input DQS phase shift
`ifdef HCX_COMPAT_MODE
input   [DLL_DELAY_CTRL_WIDTH-1:0]  hc_dll_config_dll_offset_ctrl_offsetctrlout;
input   [DLL_DELAY_CTRL_WIDTH-1:0]  hc_dll_config_dll_offset_ctrl_b_offsetctrlout;
`endif

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

`ifdef USE_SHADOW_REGS
input 	[AFI_WRANK_WIDTH-1:0]	    afi_wrank;
input   [AFI_RRANK_WIDTH-1:0]       afi_rrank;
`endif

`ifdef PINGPONGPHY_EN
input	[AFI_RATE_RATIO-1:0]		afi_rdata_en_1t; 
input	[AFI_RATE_RATIO-1:0]		afi_rdata_en_full_1t;
input								mux_sel;
output	[AFI_RATE_RATIO-1:0]    	afi_rdata_valid_1t;
`endif

// END PARAMETER SECTION
// ******************************************************************************************************************************** 

wire	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;
`ifdef RLDRAMX
wire	[AFI_BANK_WIDTH-1:0]	phy_ddio_bank;
wire	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
wire	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_we_n;
wire	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_ref_n;
 `ifdef RLDRAM3
wire	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_reset_n; 
 `endif
`endif
`ifdef QDRII
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n; 
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n; 
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n; 
`endif
`ifdef DDRII_SRAM
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ld_n; 
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rw_n;
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;
`endif
`ifdef DDRX
wire	[AFI_BANK_WIDTH-1:0]    phy_ddio_bank;
wire	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
wire	[AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;
`ifndef LPDDR1
wire	[AFI_ODT_WIDTH-1:0] phy_ddio_odt;
`endif
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ras_n;
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_cas_n;
wire	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_we_n;
	`ifdef AC_PARITY
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ac_par;
wire	phy_parity_error_n;
	`endif
	`ifdef DDR3
wire	[AFI_CONTROL_WIDTH-1:0] phy_ddio_reset_n;
	`endif
`endif
`ifdef LPDDR2
wire	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
wire	[AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;
`endif
wire	[AFI_DATA_WIDTH-1:0]  phy_ddio_dq;
`ifdef DDRX_LPDDRX
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_dqs_en;
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_oct_ena;
`endif
`ifdef USE_SHADOW_REGS
wire  [MEM_READ_DQS_WIDTH-1:0]  phy_ddio_read_rank;	 
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_write_rank;
`endif
`ifdef RLDRAMX
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_oct_ena;
`endif
wire	[AFI_DQS_WIDTH-1:0]  phy_ddio_wrdata_en;
wire	[AFI_DATA_MASK_WIDTH-1:0] phy_ddio_wrdata_mask;
`ifdef MAKE_FIFOS_IN_ALTDQDQS
`ifdef QUARTER_RATE
localparam DDIO_PHY_DQ_WIDTH = AFI_DATA_WIDTH/2;
`else
localparam DDIO_PHY_DQ_WIDTH = AFI_DATA_WIDTH;
`endif
`else
localparam DDIO_PHY_DQ_WIDTH = DOUBLE_MEM_DQ_WIDTH;
`endif
wire	[DDIO_PHY_DQ_WIDTH-1:0] ddio_phy_dq;
wire	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk;


wire	[AFI_DATA_WIDTH-1:0]    afi_rdata;
wire  	[AFI_RATE_RATIO-1:0]    afi_rdata_valid;

`ifdef PINGPONGPHY_EN
wire  	[AFI_RATE_RATIO-1:0]    afi_rdata_valid_1t;
`endif

wire	[SEQ_ADDRESS_WIDTH-1:0] seq_mux_address;
`ifdef RLDRAMX
wire	[SEQ_BANK_WIDTH-1:0]    seq_mux_bank;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_cas_n;
wire	[SEQ_CHIP_SELECT_WIDTH-1:0] seq_mux_cs_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_we_n;
 `ifdef RLDRAM3
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_rst_n; 
 `endif
`endif 
`ifdef QDRII
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_wps_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_rps_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_doff_n;
`endif 
`ifdef DDRII_SRAM 
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_ld_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_rw_n;
`endif
`ifdef DDRX
wire	[SEQ_BANK_WIDTH-1:0]    seq_mux_bank;
wire	[SEQ_CHIP_SELECT_WIDTH-1:0] seq_mux_cs_n;
wire	[SEQ_CLK_EN_WIDTH-1:0] seq_mux_cke;
`ifndef LPDDR1
wire	[SEQ_ODT_WIDTH-1:0] seq_mux_odt;
`endif
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_ras_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_cas_n;
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_we_n;
`ifdef DDR3
wire	[SEQ_CONTROL_WIDTH-1:0] seq_mux_reset_n;
`endif
wire	[SEQ_DQS_WIDTH-1:0]	seq_mux_dqs_en;
`endif 
`ifdef LPDDR2
wire	[SEQ_CHIP_SELECT_WIDTH-1:0] seq_mux_cs_n;
wire	[SEQ_CLK_EN_WIDTH-1:0] seq_mux_cke;
wire	[SEQ_DQS_WIDTH-1:0]	seq_mux_dqs_en;
`endif 
wire	[SEQ_DATA_WIDTH-1:0]    seq_mux_wdata;
wire	[SEQ_DQS_WIDTH-1:0]	seq_mux_wdata_valid;
wire	[SEQ_DATA_MASK_WIDTH-1:0]   seq_mux_dm;
wire	seq_mux_rdata_en;
wire	[SEQ_DATA_WIDTH-1:0]    mux_seq_rdata;
wire	mux_seq_rdata_valid;    
wire	mux_sel;

wire	[NUM_AFI_RESET-1:0] reset_n_afi_clk;
wire	reset_n_addr_cmd_clk;
wire	reset_n_seq_clk;
`ifdef QUARTER_RATE
wire	reset_n_hr_clk;
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
wire	reset_n_p2c_read_clk;
`endif
`ifdef DDRX_LPDDRX
wire	reset_n_resync_clk;
wire	[READ_VALID_FIFO_WIDTH-1:0] dqs_enable_ctrl;
`else
wire	[MEM_READ_DQS_WIDTH-1:0] reset_n_read_capture_clk;
`endif

`ifdef DDRX_LPDDRX
wire	[AFI_DQS_WIDTH-1:0] force_oct_off;
`endif

`ifdef NIOS_SEQUENCER
wire	reset_n_scc_clk;
wire	reset_n_avl_clk;
`endif


`ifdef DDRX_LPDDRX
wire [MEM_CK_WIDTH-1:0] afi_mem_clk_disable;
`else
wire afi_mem_clk_disable;
assign afi_mem_clk_disable = 0;
`endif

localparam SKIP_CALIBRATION_STEPS = 7'b1111111;

`ifdef CALIBRATION_MODE_FULL
localparam CALIBRATION_STEPS = (FAST_SIM_MODEL && (FAST_SIM_CALIBRATION != "true") ? SKIP_CALIBRATION_STEPS : 7'b1000000);
`endif
`ifdef CALIBRATION_MODE_QUICK
localparam CALIBRATION_STEPS = (FAST_SIM_MODEL && (FAST_SIM_CALIBRATION != "true") ? SKIP_CALIBRATION_STEPS : 7'b1100011);
`endif
`ifdef CALIBRATION_MODE_SKIP
localparam CALIBRATION_STEPS = SKIP_CALIBRATION_STEPS;
`endif

`ifdef SKIP_MEM_INIT
localparam SKIP_MEM_INIT = 1'b1;
`else
localparam SKIP_MEM_INIT = (FAST_SIM_MODEL ? 1'b1 : 1'b0);
`endif

localparam SEQ_CALIB_INIT = {CALIBRATION_STEPS, SKIP_MEM_INIT};

reg [CALIB_REG_WIDTH-1:0] seq_calib_init_reg /* synthesis syn_noprune syn_preserve = 1 */;

// Initialization of the sequencer status register. This register
// is preserved in the netlist so that it can be forced during simulation
always @(posedge pll_afi_clk)
	`ifndef SYNTH_FOR_SIM
	//synthesis translate_off
	`endif
	seq_calib_init_reg <= SEQ_CALIB_INIT;
	`ifndef SYNTH_FOR_SIM
	//synthesis translate_on
	//synthesis read_comments_as_HDL on
	`endif
	// seq_calib_init_reg <= {CALIB_REG_WIDTH{1'b0}};
	`ifndef SYNTH_FOR_SIM
	// synthesis read_comments_as_HDL off
	`endif

// ******************************************************************************************************************************** 
// The reset scheme used in the UNIPHY is asynchronous assert and synchronous de-assert
// The reset block has 2 main functionalities:
// 1. Keep all the PHY logic in reset state until after the PLL is locked
// 2. Synchronize the reset to each clock domain 
// ******************************************************************************************************************************** 

`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
		assign pll_scanclk = pll_config_clk;
		assign reset_n_pll_scanclk = reset_n_scc_clk;
`endif

	reset	ureset(
		.pll_afi_clk				(pll_afi_clk),
		.pll_addr_cmd_clk			(pll_addr_cmd_clk),
	`ifdef QUARTER_RATE
		.pll_hr_clk					(pll_hr_clk),
	`endif		
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
		.pll_p2c_read_clk			(pll_p2c_read_clk),
	`endif
	`ifdef DDRX_LPDDRX
		.pll_dqs_ena_clk			(pll_dqs_ena_clk),
	`endif
		.seq_clk					(seq_clk),
	`ifdef NIOS_SEQUENCER
		.pll_avl_clk				(pll_avl_clk),
		.scc_clk					(pll_config_clk),
		.reset_n_scc_clk			(reset_n_scc_clk),
		.reset_n_avl_clk			(reset_n_avl_clk),
	`endif
		.read_capture_clk			(read_capture_clk),
		.pll_locked					(pll_locked),
		.global_reset_n				(global_reset_n),
		.soft_reset_n				(soft_reset_n),
		.ctl_reset_export_n			(ctl_reset_export_n),
		.ctl_reset_n				(ctl_reset_n),
		.reset_n_afi_clk			(reset_n_afi_clk),
		.reset_n_addr_cmd_clk		(reset_n_addr_cmd_clk),
		.reset_n_seq_clk			(reset_n_seq_clk),
	`ifdef QUARTER_RATE
		.reset_n_hr_clk				(reset_n_hr_clk),
	`endif		
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
		.reset_n_p2c_read_clk		(reset_n_p2c_read_clk),
	`endif
	`ifdef DDRX_LPDDRX
		.reset_n_resync_clk			(reset_n_resync_clk),
		.seq_reset_mem_stable       (),
		.reset_n_read_capture_clk	()
	`else
		.seq_reset_mem_stable       (phy_reset_mem_stable),
		.reset_n_read_capture_clk	(reset_n_read_capture_clk)
	`endif
	);

	defparam ureset.MEM_READ_DQS_WIDTH = MEM_READ_DQS_WIDTH;
	defparam ureset.NUM_AFI_RESET = NUM_AFI_RESET;

`ifndef NIOS_SEQUENCER
	wire [SCC_DATA_WIDTH - 1:0] scc_data = {SCC_DATA_WIDTH{1'b0}};
	wire [MEM_READ_DQS_WIDTH - 1:0] scc_dqs_ena = {MEM_READ_DQS_WIDTH{1'b0}};
	wire [MEM_READ_DQS_WIDTH - 1:0] scc_dqs_io_ena = {MEM_READ_DQS_WIDTH{1'b0}};
	wire [MEM_DQ_WIDTH - 1:0] scc_dq_ena = {MEM_DQ_WIDTH{1'b0}};
	wire [MEM_DM_WIDTH - 1:0] scc_dm_ena = {MEM_DM_WIDTH{1'b0}};
	wire scc_upd = '0;
	wire [7:0] scc_sr_dqsenable_delayctrl = 8'b00000000;
	wire [7:0] scc_sr_dqsdisablen_delayctrl = 8'b00000000;
	wire [7:0] scc_sr_multirank_delayctrl = 8'b00000000;
	wire pll_config_clk = 1'b0;
	wire [MEM_READ_DQS_WIDTH - 1:0] capture_strobe_tracking;
`endif



assign calib_skip_steps = seq_calib_init_reg;
`ifdef NIOS_SEQUENCER
assign afi_cal_debug_info = phy_cal_debug_info;
`endif

assign phy_clk = seq_clk;
assign phy_reset_n = reset_n_seq_clk;


`ifdef USE_DR_CLK
assign dll_clk = pll_dr_clk_pre_phy_clk;
`else
assign dll_clk = pll_write_clk_pre_phy_clk;
`endif

assign dll_pll_locked = pll_locked;


`ifdef DDRX
	assign afi_wlat = phy_afi_wlat;
	assign afi_rlat = phy_afi_rlat;
`endif
`ifdef LPDDR2
	assign afi_wlat = phy_afi_wlat;
	assign afi_rlat = phy_afi_rlat;
`endif



// ******************************************************************************************************************************** 
// The address and command datapath is responsible for adding any flop stages/extra logic that may be required between the AFI
// interface and the output DDIOs.
// ******************************************************************************************************************************** 

    addr_cmd_datapath	uaddr_cmd_datapath(
`ifdef EARLY_ADDR_CMD_CLK_TRANSFER
		.clk		(pll_addr_cmd_clk),
`else
		.clk		(pll_afi_clk), 
`endif
		.reset_n	    		(reset_n_afi_clk[1]), 
`ifdef QUARTER_RATE
		.pll_hr_clk				(pll_hr_clk),
		.reset_n_hr_clk			(reset_n_hr_clk),
`endif
		.afi_address	    	(afi_addr),
`ifdef RLDRAMX
		.afi_bank	    		(afi_ba),
		.afi_cas_n	    		(afi_cas_n),
		.afi_cs_n	    		(afi_cs_n),
		.afi_we_n	    		(afi_we_n),
 `ifdef RLDRAM3
		.afi_rst_n	    		(afi_rst_n),
 `endif
`endif
`ifdef QDRII
		.afi_wps_n				(afi_wps_n),
		.afi_rps_n				(afi_rps_n),
		.afi_doff_n				(afi_doff_n),
`endif
`ifdef DDRII_SRAM 
		.afi_ld_n				(afi_ld_n),
		.afi_rw_n				(afi_rw_n),
		.afi_doff_n				(afi_doff_n),
`endif
`ifdef DDRX
        .afi_bank               (afi_ba),
        .afi_cs_n               (afi_cs_n),
        .afi_cke                (afi_cke),
`ifndef LPDDR1
        .afi_odt                (afi_odt),
`endif
        .afi_ras_n              (afi_ras_n),
        .afi_cas_n              (afi_cas_n),
        .afi_we_n               (afi_we_n),
`ifdef DDR3
        .afi_rst_n            	(afi_rst_n),
`endif
`endif
`ifdef LPDDR2
        .afi_cs_n               (afi_cs_n),
        .afi_cke                (afi_cke),
`endif
		.phy_ddio_address		(phy_ddio_address),
`ifdef RLDRAMX
 `ifdef RLDRAM3
		.phy_ddio_reset_n    	(phy_ddio_reset_n),
 `endif 
		.phy_ddio_bank	    	(phy_ddio_bank),
		.phy_ddio_cs_n	    	(phy_ddio_cs_n),
		.phy_ddio_we_n 		   	(phy_ddio_we_n),
		.phy_ddio_ref_n   		(phy_ddio_ref_n)
`endif
`ifdef QDRII
		.phy_ddio_wps_n			(phy_ddio_wps_n),
		.phy_ddio_rps_n			(phy_ddio_rps_n),
		.phy_ddio_doff_n			(phy_ddio_doff_n)
`endif
`ifdef DDRII_SRAM 
		.phy_ddio_ld_n			(phy_ddio_ld_n),
		.phy_ddio_rw_n			(phy_ddio_rw_n),
		.phy_ddio_doff_n			(phy_ddio_doff_n)
`endif
`ifdef DDRX
	`ifdef AC_PARITY
		.phy_ddio_ac_par		(phy_ddio_ac_par),
	`endif
	`ifdef DDR3
		.phy_ddio_reset_n   	(phy_ddio_reset_n),
	`endif
	`ifndef LPDDR1
	    .phy_ddio_odt    			(phy_ddio_odt),
	`endif
		.phy_ddio_bank 		   	(phy_ddio_bank),
		.phy_ddio_cs_n    		(phy_ddio_cs_n),
		.phy_ddio_cke    		(phy_ddio_cke),
		.phy_ddio_we_n    		(phy_ddio_we_n),
		.phy_ddio_ras_n   		(phy_ddio_ras_n),
		.phy_ddio_cas_n   		(phy_ddio_cas_n)
`endif
`ifdef LPDDR2
		.phy_ddio_cs_n	    	(phy_ddio_cs_n),
		.phy_ddio_cke    		(phy_ddio_cke)
`endif
    );
        defparam uaddr_cmd_datapath.MEM_ADDRESS_WIDTH                  = MEM_ADDRESS_WIDTH;
`ifdef RLDRAMX
        defparam uaddr_cmd_datapath.MEM_BANK_WIDTH                     = MEM_BANK_WIDTH;
        defparam uaddr_cmd_datapath.MEM_CHIP_SELECT_WIDTH              = MEM_CHIP_SELECT_WIDTH;
`endif
`ifdef DDRX_LPDDRX
        defparam uaddr_cmd_datapath.MEM_BANK_WIDTH                     = MEM_BANK_WIDTH;
        defparam uaddr_cmd_datapath.MEM_CHIP_SELECT_WIDTH              = MEM_CHIP_SELECT_WIDTH;
        defparam uaddr_cmd_datapath.MEM_CLK_EN_WIDTH              	   = MEM_CLK_EN_WIDTH;
        defparam uaddr_cmd_datapath.MEM_ODT_WIDTH              		   = MEM_ODT_WIDTH;
`endif
        defparam uaddr_cmd_datapath.MEM_DM_WIDTH                       = MEM_DM_WIDTH;
        defparam uaddr_cmd_datapath.MEM_CONTROL_WIDTH                  = MEM_CONTROL_WIDTH;
        defparam uaddr_cmd_datapath.MEM_DQ_WIDTH                       = MEM_DQ_WIDTH;
        defparam uaddr_cmd_datapath.MEM_READ_DQS_WIDTH                 = MEM_READ_DQS_WIDTH;
        defparam uaddr_cmd_datapath.MEM_WRITE_DQS_WIDTH                = MEM_WRITE_DQS_WIDTH;
        defparam uaddr_cmd_datapath.AFI_ADDRESS_WIDTH                  = AFI_ADDRESS_WIDTH;
`ifdef RLDRAMX
        defparam uaddr_cmd_datapath.AFI_BANK_WIDTH                     = AFI_BANK_WIDTH;
        defparam uaddr_cmd_datapath.AFI_CHIP_SELECT_WIDTH              = AFI_CHIP_SELECT_WIDTH;
`endif
`ifdef DDRX_LPDDRX
        defparam uaddr_cmd_datapath.AFI_BANK_WIDTH                     = AFI_BANK_WIDTH;
        defparam uaddr_cmd_datapath.AFI_CHIP_SELECT_WIDTH              = AFI_CHIP_SELECT_WIDTH;
        defparam uaddr_cmd_datapath.AFI_CLK_EN_WIDTH              	   = AFI_CLK_EN_WIDTH;
        defparam uaddr_cmd_datapath.AFI_ODT_WIDTH              		   = AFI_ODT_WIDTH;
`endif
        defparam uaddr_cmd_datapath.AFI_DATA_MASK_WIDTH                = AFI_DATA_MASK_WIDTH;
        defparam uaddr_cmd_datapath.AFI_CONTROL_WIDTH                  = AFI_CONTROL_WIDTH;
        defparam uaddr_cmd_datapath.AFI_DATA_WIDTH                     = AFI_DATA_WIDTH;
        defparam uaddr_cmd_datapath.NUM_AC_FR_CYCLE_SHIFTS             = NUM_AC_FR_CYCLE_SHIFTS;    


`ifdef USE_SHADOW_REGS
// Map rank specified by the afi_*rank signals to shadow register
wire [MEM_READ_DQS_WIDTH*AFI_RATE_RATIO-1:0] afi_rrank_decoded;
wire [MEM_READ_DQS_WIDTH*AFI_RATE_RATIO-1:0] afi_wrank_decoded;
generate
begin
genvar iter;
	for (iter=0; iter<AFI_RATE_RATIO*MEM_READ_DQS_WIDTH; iter=iter+1)
	begin: rank_to_shadow_reg
	
		
		assign afi_rrank_decoded[iter] = | afi_rrank[
			iter * MEM_IF_NUMBER_OF_RANKS + (MEM_IF_NUMBER_OF_RANKS - 1) : 
			iter * MEM_IF_NUMBER_OF_RANKS + (MEM_IF_NUMBER_OF_RANKS / 2)];

		assign afi_wrank_decoded[iter] = | afi_wrank[
			iter * MEM_IF_NUMBER_OF_RANKS + (MEM_IF_NUMBER_OF_RANKS - 1) : 
			iter * MEM_IF_NUMBER_OF_RANKS + (MEM_IF_NUMBER_OF_RANKS / 2)];
	end
end
endgenerate
`endif

// ******************************************************************************************************************************** 
// The write datapath is responsible for adding any flop stages/extra logic that may be required between the AFI interface 
// and the output DDIOs.
// ******************************************************************************************************************************** 

    write_datapath	uwrite_datapath(
		.pll_afi_clk                   (pll_afi_clk),
		.reset_n                       (reset_n_afi_clk[2]),
	`ifdef DDRX_LPDDRX
		.force_oct_off                 (force_oct_off),
		.phy_ddio_oct_ena              (phy_ddio_oct_ena),
		.afi_dqs_en                    (afi_dqs_burst),
	`endif
	`ifdef RLDRAMX
		.phy_ddio_oct_ena              (phy_ddio_oct_ena),
	`endif
		.afi_wdata                     (afi_wdata),
		.afi_wdata_valid               (afi_wdata_valid),
		.afi_dm                        (afi_dm),
		.phy_ddio_dq                   (phy_ddio_dq),
	`ifdef DDRX_LPDDRX
		.phy_ddio_dqs_en               (phy_ddio_dqs_en),
	`endif
	`ifdef USE_SHADOW_REGS
		.afi_write_rank                 (afi_wrank_decoded),
		.phy_ddio_write_rank            (phy_ddio_write_rank),
	`endif
		.phy_ddio_wrdata_en            (phy_ddio_wrdata_en),
		.phy_ddio_wrdata_mask          (phy_ddio_wrdata_mask),
		.seq_num_write_fr_cycle_shifts (phy_num_write_fr_cycle_shifts)
    );
        defparam uwrite_datapath.MEM_ADDRESS_WIDTH                  = MEM_ADDRESS_WIDTH;
        defparam uwrite_datapath.MEM_DM_WIDTH                       = MEM_DM_WIDTH;
        defparam uwrite_datapath.MEM_CONTROL_WIDTH                  = MEM_CONTROL_WIDTH;
        defparam uwrite_datapath.MEM_DQ_WIDTH                       = MEM_DQ_WIDTH;
        defparam uwrite_datapath.MEM_READ_DQS_WIDTH                 = MEM_READ_DQS_WIDTH;
        defparam uwrite_datapath.MEM_WRITE_DQS_WIDTH                = MEM_WRITE_DQS_WIDTH;
        defparam uwrite_datapath.AFI_ADDRESS_WIDTH                  = AFI_ADDRESS_WIDTH;
        defparam uwrite_datapath.AFI_DATA_MASK_WIDTH                = AFI_DATA_MASK_WIDTH;
        defparam uwrite_datapath.AFI_CONTROL_WIDTH                  = AFI_CONTROL_WIDTH;
        defparam uwrite_datapath.AFI_DATA_WIDTH                     = AFI_DATA_WIDTH;
        defparam uwrite_datapath.AFI_DQS_WIDTH                      = AFI_DQS_WIDTH;
        defparam uwrite_datapath.NUM_WRITE_PATH_FLOP_STAGES         = NUM_WRITE_PATH_FLOP_STAGES;
        defparam uwrite_datapath.NUM_WRITE_FR_CYCLE_SHIFTS          = NUM_WRITE_FR_CYCLE_SHIFTS;

	 `ifdef USE_SHADOW_REGS
	 /* synthesis translate_off */
	 assert property (@(posedge pll_afi_clk) (afi_wrank_decoded != ({AFI_DQS_WIDTH{1'b0}}) |-> (~afi_dqs_burst & afi_wrank_decoded) == {AFI_DQS_WIDTH{1'b0}} || afi_cal_success == 1'b0)) else $fatal(1, "afi_write_rank is 1 when afi_dqs_en is 0");
/* synthesis translate_on */
	 `endif
	 
// ******************************************************************************************************************************** 
// The read datapath is responsible for read data resynchronization from the memory clock domain to the AFI clock domain.
// It contains 1 FIFO per DQS group for read valid prediction and 1 FIFO per DQS group for read data synchronization.
// ******************************************************************************************************************************** 
	
	read_datapath	uread_datapath(
		.reset_n_afi_clk				(reset_n_afi_clk[3]),
    `ifdef DDRX_LPDDRX
        .reset_n_resync_clk         	(reset_n_resync_clk),
	`else
		.reset_n_read_capture_clk		(reset_n_read_capture_clk),
		.seq_reset_mem_stable			(phy_reset_mem_stable),
    `endif
		.seq_read_fifo_reset			(phy_read_fifo_reset),
		.pll_afi_clk					(pll_afi_clk),
	`ifdef QUARTER_RATE
		.pll_hr_clk						(pll_hr_clk),
		.reset_n_hr_clk					(reset_n_hr_clk),
	`endif
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
		.pll_p2c_read_clk				(pll_p2c_read_clk),
		.reset_n_p2c_read_clk			(reset_n_p2c_read_clk),
	`endif
	`ifdef DDRX_LPDDRX
		.pll_dqs_ena_clk				(pll_dqs_ena_clk),
	`endif
		.read_capture_clk				(read_capture_clk),
		.ddio_phy_dq					(ddio_phy_dq),
	`ifdef MAKE_FIFOS_IN_ALTDQDQS
		.seq_read_latency_counter		({{(MAX_LATENCY_COUNT_WIDTH_SAFE - 5){1'b0}}, phy_read_latency_counter[4:0]}),
	`else
		.seq_read_latency_counter		(phy_read_latency_counter),
	`endif
		.seq_read_increment_vfifo_fr	(phy_read_increment_vfifo_fr),
		.seq_read_increment_vfifo_hr	(phy_read_increment_vfifo_hr),
		.seq_read_increment_vfifo_qr	(phy_read_increment_vfifo_qr),
	`ifdef DDRX_LPDDRX
		.force_oct_off					(force_oct_off),
		.dqs_enable_ctrl				(dqs_enable_ctrl),
	`endif
	`ifdef USE_SHADOW_REGS
		.afi_rrank_decoded				(afi_rrank_decoded),
		.rrank_select_out				(phy_ddio_read_rank),
	`endif
	`ifdef PINGPONGPHY_EN
		.afi_rdata_en_1t				(afi_rdata_en_1t),
		.afi_rdata_en_full_1t			(afi_rdata_en_full_1t),
		.mux_sel						(mux_sel),
	`endif
		.afi_rdata_en					(afi_rdata_en),
		.afi_rdata_en_full				(afi_rdata_en_full),
		.afi_rdata						(afi_rdata),
		.phy_mux_read_fifo_q            (phy_read_fifo_q),
	`ifdef PINGPONGPHY_EN
		.afi_rdata_valid_1t				(afi_rdata_valid_1t),
	`endif
		.afi_rdata_valid				(afi_rdata_valid),
		.seq_calib_init					(seq_calib_init_reg)
	);
	defparam uread_datapath.DEVICE_FAMILY                      	= DEVICE_FAMILY;
	defparam uread_datapath.MEM_ADDRESS_WIDTH                  	= MEM_ADDRESS_WIDTH; 
	defparam uread_datapath.MEM_DM_WIDTH                       	= MEM_DM_WIDTH; 
	defparam uread_datapath.MEM_CONTROL_WIDTH                  	= MEM_CONTROL_WIDTH; 
	defparam uread_datapath.MEM_DQ_WIDTH                       	= MEM_DQ_WIDTH; 
	defparam uread_datapath.MEM_READ_DQS_WIDTH                 	= MEM_READ_DQS_WIDTH; 
	defparam uread_datapath.MEM_WRITE_DQS_WIDTH                	= MEM_WRITE_DQS_WIDTH; 
	defparam uread_datapath.AFI_ADDRESS_WIDTH                  	= AFI_ADDRESS_WIDTH; 
	defparam uread_datapath.AFI_DATA_MASK_WIDTH                	= AFI_DATA_MASK_WIDTH; 
	defparam uread_datapath.AFI_CONTROL_WIDTH                  	= AFI_CONTROL_WIDTH; 
	defparam uread_datapath.AFI_DATA_WIDTH                     	= AFI_DATA_WIDTH; 
	defparam uread_datapath.AFI_DQS_WIDTH                     	= AFI_DQS_WIDTH;
	defparam uread_datapath.AFI_RATE_RATIO                     	= AFI_RATE_RATIO;
	defparam uread_datapath.MAX_LATENCY_COUNT_WIDTH            	= MAX_LATENCY_COUNT_WIDTH;
	defparam uread_datapath.MAX_READ_LATENCY					= MAX_READ_LATENCY;
	defparam uread_datapath.READ_FIFO_READ_MEM_DEPTH			= READ_FIFO_READ_MEM_DEPTH;
	defparam uread_datapath.READ_FIFO_READ_ADDR_WIDTH			= READ_FIFO_READ_ADDR_WIDTH;
	defparam uread_datapath.READ_FIFO_WRITE_MEM_DEPTH			= READ_FIFO_WRITE_MEM_DEPTH;
	defparam uread_datapath.READ_FIFO_WRITE_ADDR_WIDTH			= READ_FIFO_WRITE_ADDR_WIDTH;
	defparam uread_datapath.READ_VALID_FIFO_SIZE                = READ_VALID_FIFO_SIZE;
	defparam uread_datapath.READ_VALID_FIFO_READ_MEM_DEPTH		= READ_VALID_FIFO_READ_MEM_DEPTH;
	defparam uread_datapath.READ_VALID_FIFO_READ_ADDR_WIDTH		= READ_VALID_FIFO_READ_ADDR_WIDTH;
	defparam uread_datapath.READ_VALID_FIFO_WRITE_MEM_DEPTH		= READ_VALID_FIFO_WRITE_MEM_DEPTH;
	defparam uread_datapath.READ_VALID_FIFO_WRITE_ADDR_WIDTH	= READ_VALID_FIFO_WRITE_ADDR_WIDTH;    	
	defparam uread_datapath.READ_VALID_FIFO_PER_DQS_WIDTH		= READ_VALID_FIFO_PER_DQS_WIDTH;
	defparam uread_datapath.NUM_SUBGROUP_PER_READ_DQS			= NUM_SUBGROUP_PER_READ_DQS;  
	defparam uread_datapath.MEM_T_RL					        = MEM_T_RL;  
	defparam uread_datapath.CALIB_REG_WIDTH				        = CALIB_REG_WIDTH;
	defparam uread_datapath.QVLD_EXTRA_FLOP_STAGES				= QVLD_EXTRA_FLOP_STAGES;
	defparam uread_datapath.QVLD_WR_ADDRESS_OFFSET				= QVLD_WR_ADDRESS_OFFSET;
	defparam uread_datapath.REGISTER_C2P						= REGISTER_C2P;
	defparam uread_datapath.FAST_SIM_MODEL						= FAST_SIM_MODEL;
`ifdef MAKE_FIFOS_IN_ALTDQDQS
	defparam uread_datapath.EXTRA_VFIFO_SHIFT                   = EXTRA_VFIFO_SHIFT;
`endif


// ******************************************************************************************************************************** 
// The I/O block is responsible for instantiating all the built-in I/O logic in the FPGA
// ******************************************************************************************************************************** 
	new_io_pads uio_pads (
`ifdef LPDDR2
		.reset_n_addr_cmd_clk	(reset_n_afi_clk[1]),
`else
                .reset_n_addr_cmd_clk   (reset_n_addr_cmd_clk),
`endif
		.reset_n_afi_clk		(reset_n_afi_clk[1]),
		.phy_reset_mem_stable   (phy_reset_mem_stable),
`ifdef QUARTER_RATE
		.reset_n_hr_clk			(reset_n_hr_clk),
`endif

`ifdef ARRIAIIGX
		.oct_ctl_value       	(oct_ctl_value),
`else
        .oct_ctl_rs_value       (oct_ctl_rs_value),
        .oct_ctl_rt_value       (oct_ctl_rt_value),
`endif

		// Address and Command
		.phy_ddio_addr_cmd_clk	(pll_addr_cmd_clk),

		.phy_ddio_address 		(phy_ddio_address),
`ifdef RLDRAMX
		.phy_ddio_bank	    	(phy_ddio_bank),
		.phy_ddio_cs_n    		(phy_ddio_cs_n),
		.phy_ddio_we_n    		(phy_ddio_we_n),
		.phy_ddio_ref_n		   	(phy_ddio_ref_n),
 `ifdef RLDRAM3		
		.phy_ddio_reset_n		(phy_ddio_reset_n),
 `endif
 
		.phy_mem_address    	(mem_a),
		.phy_mem_bank	    	(mem_ba),
		.phy_mem_cs_n	    	(mem_cs_n),
		.phy_mem_we_n	    	(mem_we_n),
		.phy_mem_ref_n	    	(mem_ref_n),
 `ifdef RLDRAM3		
		.phy_mem_reset_n		(mem_reset_n),
 `endif
`endif
`ifdef QDRII
		.phy_ddio_wps_n			(phy_ddio_wps_n),
		.phy_ddio_rps_n			(phy_ddio_rps_n),
		.phy_ddio_doff_n			(phy_ddio_doff_n),

		.phy_mem_address		(mem_a),
		.phy_mem_wps_n			(mem_wps_n),
		.phy_mem_rps_n			(mem_rps_n),
		.phy_mem_doff_n			(mem_doff_n),	
`endif
`ifdef DDRII_SRAM 
		.phy_ddio_ld_n			(phy_ddio_ld_n),
		.phy_ddio_rw_n			(phy_ddio_rw_n),
		.phy_ddio_doff_n			(phy_ddio_doff_n),

		.phy_mem_address		(mem_a),
		.phy_mem_ld_n			(mem_ld_n),
		.phy_mem_rw_n			(mem_rw_n),
		.phy_mem_zq				(mem_zq),
		.phy_mem_doff_n			(mem_doff_n),	
`endif
`ifdef DDRX
		.phy_ddio_bank   	 	(phy_ddio_bank),
		.phy_ddio_cs_n    		(phy_ddio_cs_n),
		.phy_ddio_cke    		(phy_ddio_cke),
`ifndef LPDDR1
		.phy_ddio_odt    		(phy_ddio_odt),
`endif
		.phy_ddio_we_n    		(phy_ddio_we_n),
		.phy_ddio_ras_n   		(phy_ddio_ras_n),
		.phy_ddio_cas_n   		(phy_ddio_cas_n),
`ifdef AC_PARITY
		.phy_ddio_ac_par		(phy_ddio_ac_par),
`endif
`ifdef DDR3
		.phy_ddio_reset_n   	(phy_ddio_reset_n),
`endif

		.phy_mem_address    	(mem_a),
		.phy_mem_bank	    	(mem_ba),
		.phy_mem_cs_n	    	(mem_cs_n),
		.phy_mem_cke	    	(mem_cke),
`ifndef LPDDR1
		.phy_mem_odt	    	(mem_odt),
`endif
		.phy_mem_we_n	    	(mem_we_n),
		.phy_mem_ras_n	    	(mem_ras_n),
		.phy_mem_cas_n	    	(mem_cas_n),
`ifdef AC_PARITY
		.phy_ac_parity			(mem_ac_parity),
		.phy_err_out_n			(mem_err_out_n),
		.phy_parity_error_n			(phy_parity_error_n),
`endif
`ifdef DDR3
		.phy_mem_reset_n	    (mem_reset_n),
`endif
`endif
`ifdef LPDDR2
		.phy_ddio_cs_n    		(phy_ddio_cs_n),
		.phy_ddio_cke    		(phy_ddio_cke),

		.phy_mem_address    	(mem_ca),
		.phy_mem_cs_n	    	(mem_cs_n),
		.phy_mem_cke	    	(mem_cke),
`endif

		// Write
		.pll_afi_clk	    	(pll_afi_clk),
`ifdef QUARTER_RATE
		.pll_hr_clk				(pll_hr_clk),
`endif
		.pll_mem_clk	    	(pll_mem_clk),
		.pll_write_clk	    	(pll_write_clk),
`ifdef CORE_PERIPHERY_DUAL_CLOCK
		.pll_c2p_write_clk		(pll_c2p_write_clk),
`endif
`ifdef USE_DR_CLK
		.pll_dr_clk					(pll_dr_clk),
`endif
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
		.pll_mem_phy_clk		(pll_mem_phy_clk),
		.pll_afi_phy_clk		(pll_afi_phy_clk),
`endif
`ifdef DDRX_LPDDRX
		.pll_dqs_ena_clk		(pll_dqs_ena_clk),
`endif
		.phy_ddio_dq	    	(phy_ddio_dq),
`ifdef DDRX_LPDDRX
		.phy_ddio_dqs_en		(phy_ddio_dqs_en),
		.phy_ddio_oct_ena		(phy_ddio_oct_ena),
		.dqs_enable_ctrl		(dqs_enable_ctrl),
`endif
`ifdef USE_SHADOW_REGS
		.scc_reset_n			(reset_n_scc_clk),
		.phy_ddio_read_rank		(phy_ddio_read_rank),
		.phy_ddio_write_rank	(phy_ddio_write_rank),
`endif
`ifdef RLDRAMX
		.phy_ddio_oct_ena		(phy_ddio_oct_ena),
`endif		
        .phy_ddio_wrdata_en 	(phy_ddio_wrdata_en),
        .phy_ddio_wrdata_mask   (phy_ddio_wrdata_mask),

`ifdef RLDRAMX
		.phy_mem_dq	    		(mem_dq),
`ifdef MEM_IF_DM_PINS_EN		
		.phy_mem_dm	    		(mem_dm),
`endif		
		.phy_mem_dk	    		(mem_dk),
		.phy_mem_dk_n	    	(mem_dk_n),
		.phy_mem_ck	    		(mem_ck),
		.phy_mem_ck_n	    	(mem_ck_n),
`endif
`ifdef QDRII
		.phy_mem_d				(mem_d),
		.phy_mem_bws_n			(mem_bws_n),
		.phy_mem_k				(mem_k),
		.phy_mem_k_n			(mem_k_n),
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
		.dll_offsetdelay_in (dll_offsetdelay_in),
`endif
`endif
`endif
`endif
`ifdef DDRII_SRAM 
		.phy_mem_dq				(mem_dq),
		.phy_mem_bws_n			(mem_bws_n),
		.phy_mem_k				(mem_k),
		.phy_mem_k_n			(mem_k_n),
		.phy_mem_c				(mem_c),
		.phy_mem_c_n			(mem_c_n),
`endif

`ifdef DDRX_LPDDRX
        .phy_mem_dq             (mem_dq),
`ifdef MEM_IF_DM_PINS_EN
        .phy_mem_dm             (mem_dm),
`endif
        .phy_mem_ck             (mem_ck),
        .phy_mem_ck_n           (mem_ck_n),
		.mem_dqs				(mem_dqs),
`ifdef MEM_IF_DQSN_EN
		.mem_dqs_n				(mem_dqs_n),
`endif
`endif

		// Read
		.dll_phy_delayctrl		(dll_phy_delayctrl),
`ifdef HCX_COMPAT_MODE
		.hc_dll_config_dll_offset_ctrl_offsetctrlout(hc_dll_config_dll_offset_ctrl_offsetctrlout),
		.hc_dll_config_dll_offset_ctrl_b_offsetctrlout(hc_dll_config_dll_offset_ctrl_b_offsetctrlout),
`endif		
`ifdef RLDRAMX
		.mem_phy_qk				(mem_qk),
		.mem_phy_qk_n			(mem_qk_n),
`endif
`ifdef QDRII
		.mem_phy_cq				(mem_cq),
		.mem_phy_cq_n			(mem_cq_n),
		.mem_phy_q				(mem_q),
`endif
`ifdef DDRII_SRAM 
		.mem_phy_cq				(mem_cq),
		.mem_phy_cq_n			(mem_cq_n),
`endif
		.ddio_phy_dq			(ddio_phy_dq),
		.read_capture_clk       (read_capture_clk)
        ,
		
		.scc_clk				(pll_config_clk),       
		.scc_data               (scc_data),
		.scc_dqs_ena            (scc_dqs_ena),
		.scc_dqs_io_ena         (scc_dqs_io_ena),
		.scc_dq_ena             (scc_dq_ena),
`ifdef MEM_IF_DM_PINS_EN
		.scc_dm_ena             (scc_dm_ena),
`endif
		.scc_upd                (scc_upd),
		.scc_sr_dqsenable_delayctrl (scc_sr_dqsenable_delayctrl),
		.scc_sr_dqsdisablen_delayctrl (scc_sr_dqsdisablen_delayctrl),
		.scc_sr_multirank_delayctrl (scc_sr_multirank_delayctrl),
`ifdef MAKE_FIFOS_IN_ALTDQDQS
		.afi_rdata_en					(afi_rdata_en),
		.afi_rdata_en_full				(afi_rdata_en_full),
		.seq_read_latency_counter		(phy_read_latency_counter),
		.seq_read_fifo_reset			(phy_read_fifo_reset),
		.seq_read_increment_vfifo_fr	(phy_read_increment_vfifo_fr),
		.seq_read_increment_vfifo_hr	(phy_read_increment_vfifo_hr),
`endif
		.enable_mem_clk                (~afi_mem_clk_disable),
		.capture_strobe_tracking	(capture_strobe_tracking)
    );

        defparam uio_pads.DEVICE_FAMILY                      = DEVICE_FAMILY;
`ifdef ARRIAIIGX
        defparam uio_pads.OCT_TERM_CONTROL_WIDTH             = OCT_TERM_CONTROL_WIDTH;
`else
        defparam uio_pads.OCT_SERIES_TERM_CONTROL_WIDTH      = OCT_SERIES_TERM_CONTROL_WIDTH;
        defparam uio_pads.OCT_PARALLEL_TERM_CONTROL_WIDTH    = OCT_PARALLEL_TERM_CONTROL_WIDTH;
`endif
        defparam uio_pads.MEM_ADDRESS_WIDTH                  = MEM_ADDRESS_WIDTH;
`ifdef RLDRAMX
        defparam uio_pads.MEM_BANK_WIDTH                     = MEM_BANK_WIDTH;
        defparam uio_pads.MEM_CHIP_SELECT_WIDTH              = MEM_CHIP_SELECT_WIDTH;
`endif
`ifdef DDRX_LPDDRX
        defparam uio_pads.MEM_BANK_WIDTH                     = MEM_BANK_WIDTH;
        defparam uio_pads.MEM_CHIP_SELECT_WIDTH              = MEM_CHIP_SELECT_WIDTH;
        defparam uio_pads.MEM_CLK_EN_WIDTH                   = MEM_CLK_EN_WIDTH;
        defparam uio_pads.MEM_CK_WIDTH                       = MEM_CK_WIDTH;
        defparam uio_pads.MEM_ODT_WIDTH                      = MEM_ODT_WIDTH;
        defparam uio_pads.MEM_DQS_WIDTH                      = MEM_DQS_WIDTH;
`endif
        defparam uio_pads.MEM_DM_WIDTH                       = MEM_DM_WIDTH;
        defparam uio_pads.MEM_CONTROL_WIDTH                  = MEM_CONTROL_WIDTH;
        defparam uio_pads.MEM_DQ_WIDTH                       = MEM_DQ_WIDTH;
        defparam uio_pads.MEM_READ_DQS_WIDTH                 = MEM_READ_DQS_WIDTH;
        defparam uio_pads.MEM_WRITE_DQS_WIDTH                = MEM_WRITE_DQS_WIDTH;
        defparam uio_pads.AFI_ADDRESS_WIDTH                  = AFI_ADDRESS_WIDTH;
`ifdef RLDRAMX
        defparam uio_pads.AFI_BANK_WIDTH                     = AFI_BANK_WIDTH;
        defparam uio_pads.AFI_CHIP_SELECT_WIDTH              = AFI_CHIP_SELECT_WIDTH;
`endif
`ifdef DDRX_LPDDRX
        defparam uio_pads.AFI_BANK_WIDTH                     = AFI_BANK_WIDTH;
        defparam uio_pads.AFI_CHIP_SELECT_WIDTH              = AFI_CHIP_SELECT_WIDTH;
        defparam uio_pads.AFI_CLK_EN_WIDTH                   = AFI_CLK_EN_WIDTH;
        defparam uio_pads.AFI_ODT_WIDTH                      = AFI_ODT_WIDTH;
`endif
        defparam uio_pads.AFI_DATA_MASK_WIDTH                = AFI_DATA_MASK_WIDTH;
        defparam uio_pads.AFI_CONTROL_WIDTH                  = AFI_CONTROL_WIDTH;
        defparam uio_pads.AFI_DATA_WIDTH                     = AFI_DATA_WIDTH;
        defparam uio_pads.AFI_DQS_WIDTH                      = AFI_DQS_WIDTH;
        defparam uio_pads.AFI_RATE_RATIO                     = AFI_RATE_RATIO;
        defparam uio_pads.DLL_DELAY_CTRL_WIDTH               = DLL_DELAY_CTRL_WIDTH;
        defparam uio_pads.SCC_DATA_WIDTH                     = SCC_DATA_WIDTH;
        defparam uio_pads.REGISTER_C2P                       = REGISTER_C2P;
        defparam uio_pads.LDC_MEM_CK_CPS_PHASE               = LDC_MEM_CK_CPS_PHASE;
`ifdef DDRX_LPDDRX
        defparam uio_pads.DQS_ENABLE_CTRL_WIDTH              = READ_VALID_FIFO_WIDTH;
        defparam uio_pads.ALTDQDQS_INPUT_FREQ                = ALTDQDQS_INPUT_FREQ;
        defparam uio_pads.ALTDQDQS_DELAY_CHAIN_BUFFER_MODE   = ALTDQDQS_DELAY_CHAIN_BUFFER_MODE;
        defparam uio_pads.ALTDQDQS_DQS_PHASE_SETTING         = ALTDQDQS_DQS_PHASE_SETTING;
        defparam uio_pads.ALTDQDQS_DQS_PHASE_SHIFT           = ALTDQDQS_DQS_PHASE_SHIFT;
        defparam uio_pads.ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING = ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING;
`endif
`ifdef MAKE_FIFOS_IN_ALTDQDQS
        defparam uio_pads.EXTRA_VFIFO_SHIFT                  = EXTRA_VFIFO_SHIFT;
`endif
        defparam uio_pads.FAST_SIM_MODEL                     = FAST_SIM_MODEL;
        defparam uio_pads.IS_HHP_HPS                         = "false"; 

`ifdef AC_PARITY
		assign parity_error_n = phy_parity_error_n;
`endif

`ifdef PHY_CSR_ENABLED
// ******************************************************************************************************************************** 
// The CSR port of the PHY allow reading the status and configuration of the PHY
// ******************************************************************************************************************************** 

		wire csr_pll_locked;
		wire csr_afi_cal_success;
		wire csr_afi_cal_fail;
		wire [7:0] csr_seq_fom_in;
		wire [7:0] csr_seq_fom_out;
		wire [7:0] csr_cal_init_failing_stage;
		wire [7:0] csr_cal_init_failing_substage;
		wire [7:0] csr_cal_init_failing_group;

		assign csr_pll_locked = pll_locked;
		assign csr_afi_cal_success = afi_cal_success;
		assign csr_afi_cal_fail = afi_cal_fail;

		assign csr_seq_fom_in = afi_cal_debug_info[7:0];
		assign csr_seq_fom_out = afi_cal_debug_info[15:8];

		assign csr_cal_init_failing_stage = afi_cal_debug_info[7:0];
		assign csr_cal_init_failing_substage = afi_cal_debug_info[15:8];
		assign csr_cal_init_failing_group = afi_cal_debug_info[23:16];
		
			
		phy_csr #(
			.CSR_ADDR_WIDTH(CSR_ADDR_WIDTH),
			.CSR_DATA_WIDTH(CSR_DATA_WIDTH),
			.CSR_BE_WIDTH(CSR_BE_WIDTH),
`ifdef DDR2
			.MR1_RTT(MR1_RTT),
`endif
`ifdef DDR3
			.MR1_RTT(MR1_RTT),
			.MR1_ODS(MR1_ODS),
			.MR2_RTT_WR(MR2_RTT_WR),
`endif
`ifdef LPDDR1
			.MR1_DS(MR1_DS),
`endif
			.MEM_READ_DQS_WIDTH(MEM_READ_DQS_WIDTH)

		) phy_csr_inst (
			.clk(pll_afi_clk),
			.reset_n(reset_n_avl_clk),

			.csr_addr(csr_addr),
			.csr_be(csr_be),
			.csr_write_req(csr_write_req),
			.csr_wdata(csr_wdata),
			.csr_read_req(csr_read_req),
			.csr_rdata(csr_rdata),
			.csr_rdata_valid(csr_rdata_valid),
			.csr_waitrequest(csr_waitrequest),

			.pll_locked(csr_pll_locked),
			.afi_cal_success(csr_afi_cal_success),
			.afi_cal_fail(csr_afi_cal_fail),
			.seq_fom_in(csr_seq_fom_in),
			.seq_fom_out(csr_seq_fom_out),
			.cal_init_failing_stage(csr_cal_init_failing_stage),
			.cal_init_failing_substage(csr_cal_init_failing_substage),
			.cal_init_failing_group(csr_cal_init_failing_group)
	
		);
`endif


`ifdef EXPORT_AFI_HALF_CLK
	reg afi_half_clk_reg /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
	always @(posedge pll_afi_half_clk)
		afi_half_clk_reg <= ~afi_half_clk_reg;
`endif
	 
`ifdef DDRX_LPDDRX
	`ifdef LPDDR2
	reg avl_clk_reg /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
	always @(posedge pll_avl_clk)
		avl_clk_reg <= ~avl_clk_reg;
	reg config_clk_reg /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
	always @(posedge pll_config_clk)
		config_clk_reg <= ~config_clk_reg;
	`endif
`endif




`ifdef ENABLE_ISS_PROBES
iss_probe #(
	.WIDTH(1)
) afi_cal_success_probe (
	.probe_input(afi_cal_success)
);

iss_probe #(
	.WIDTH(1)
) afi_cal_fail_probe (
	.probe_input(afi_cal_fail)
);

`ifdef NIOS_SEQUENCER
iss_probe #(
    .WIDTH(AFI_DEBUG_INFO_WIDTH)
) afi_cal_debug_info_probe (
    .probe_input(afi_cal_debug_info)
);

reg [AFI_DEBUG_INFO_WIDTH - 1:0] scc_upd_after_cal_success;

always @(posedge pll_config_clk, negedge reset_n_scc_clk)
    begin
        if (!reset_n_scc_clk)
            begin
                scc_upd_after_cal_success[7:0]  <=  0;
            end
        else if (afi_cal_success && |scc_upd)
            begin
                if (&scc_upd_after_cal_success[7:0])
                    scc_upd_after_cal_success[7:0]  <=  0;
                else
                    scc_upd_after_cal_success[7:0]  <=  scc_upd_after_cal_success[7:0] + 1'b1;
            end
    end

iss_probe #(
	.WIDTH(AFI_DEBUG_INFO_WIDTH)
) scc_upd_after_cal_success_probe (
	.probe_input(scc_upd_after_cal_success)
);
`endif

`endif


// Calculate the ceiling of log_2 of the input value
function integer ceil_log2;
	input integer value;
	begin
		value = value - 1;
		for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
			value = value >> 1;
	end
endfunction

endmodule
