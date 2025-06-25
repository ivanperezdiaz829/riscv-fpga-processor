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

module memphy_fake(
	global_reset_n,
	soft_reset_n,
	ctl_reset_n,
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
 `ifdef RLDRAM3
	mem_reset_n,
 `endif
	mem_ck,
	mem_ck_n,
	mem_dk,
	mem_dk_n,
	mem_qk,
	mem_qk_n,
	mem_dq,
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

// The number of AFI clock cycles after reset before success
// will go high
parameter AFI_CAL_SUCCESS_DELAY_STAGE = 16;

// The number of AFI clock cycles to delay afi_rdata_en before
// feeding back to afi_rdata_valid
parameter AFI_READ_VALID_DELAY = 12;


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
parameter AFI_DQS_WIDTH				= "";
parameter AFI_RATE_RATIO			= "";

// DLL Interface
// The DLL delay output control is always 6 bits for current existing devices
parameter DLL_DELAY_CTRL_WIDTH  = "";

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
`ifdef SEQUENCER_BRIDGE_DDR
localparam SEQ_ADDRESS_WIDTH		= 2 * AFI_ADDRESS_WIDTH;
`ifdef RLDRAMX
localparam SEQ_BANK_WIDTH			= 2 * AFI_BANK_WIDTH;
localparam SEQ_CHIP_SELECT_WIDTH	= 2 * AFI_CHIP_SELECT_WIDTH;
`endif
`ifdef DDRX_LPDDRX
localparam SEQ_BANK_WIDTH			= 2 * AFI_BANK_WIDTH;
localparam SEQ_CHIP_SELECT_WIDTH	= 2 * AFI_CHIP_SELECT_WIDTH;
localparam SEQ_CLK_EN_WIDTH			= 2 * AFI_CLK_EN_WIDTH;
localparam SEQ_ODT_WIDTH			= 2 * AFI_ODT_WIDTH;
`endif
localparam SEQ_DATA_MASK_WIDTH		= 2 * AFI_DATA_MASK_WIDTH;
localparam SEQ_CONTROL_WIDTH		= 2 * AFI_CONTROL_WIDTH;
localparam SEQ_DATA_WIDTH			= 2 * AFI_DATA_WIDTH;
localparam SEQ_DQS_WIDTH			= 2 * AFI_DQS_WIDTH;
`else
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
`endif

localparam MAX_LATENCY_COUNT_WIDTH_SAFE    = (MAX_LATENCY_COUNT_WIDTH < 5)? 5 :  MAX_LATENCY_COUNT_WIDTH;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 



// ******************************************************************************************************************************** 
// BEGIN PORT SECTION

//  Reset Interface
input	global_reset_n;		// Resets (active-low) the whole system (all PHY logic + PLL)
input	soft_reset_n;		// Resets (active-low) PHY logic only, PLL is NOT reset
input	pll_locked;			// Indicates that PLL is locked
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
output  afi_cal_success;    // calibration success
output  afi_cal_fail;       // calibration failure
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
input                              scc_data;
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
output	dll_pll_locked;
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


reg [AFI_CAL_SUCCESS_DELAY_STAGE-1 : 0] afi_cal_success_delay;
reg [AFI_READ_VALID_DELAY-1 : 0] afi_rdata_en_delay;

// ******************************************************************************************************************************** 
// The reset scheme used in the UNIPHY is asynchronous assert and synchronous de-assert
// The reset block has 2 main functionalities:
// 1. Keep all the PHY logic in reset state until after the PLL is locked
// 2. Synchronize the reset to each clock domain 
// ******************************************************************************************************************************** 

	reset	ureset(
		.pll_afi_clk				(pll_afi_clk),
		.pll_addr_cmd_clk			(pll_addr_cmd_clk),
	`ifdef QUARTER_RATE
		.pll_hr_clk					(pll_hr_clk),
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
		.csr_soft_reset_req         (csr_soft_reset_req),
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
		.reset_n_resync_clk			(reset_n_resync_clk)
	`else
        .seq_reset_mem_stable       (phy_reset_mem_stable),
		.reset_n_read_capture_clk	(reset_n_read_capture_clk)
	`endif
	);

	defparam ureset.MEM_READ_DQS_WIDTH = MEM_READ_DQS_WIDTH;
	defparam ureset.NUM_AFI_RESET = NUM_AFI_RESET;


`ifdef USE_DR_CLK
assign dll_clk = pll_dr_clk_pre_phy_clk;
`else
assign dll_clk = pll_write_clk_pre_phy_clk;
`endif

assign dll_pll_locked = pll_locked;

	always @ (posedge pll_afi_clk or negedge reset_n_afi_clk) begin
		if (~reset_n_afi_clk) begin
			afi_cal_success_delay <= 0;
			afi_rdata_en_delay <= 0;
		end
		else begin
			afi_rdata_en_delay <= {afi_rdata_en_delay[AFI_READ_VALID_DELAY-2 : 0], afi_rdata_en};
			
			if (~(&afi_cal_success_delay))
				afi_cal_success_delay <= {afi_cal_success_delay[AFI_CAL_SUCCESS_DELAY_STAGE-2 : 0],1'b1};
		end
	end


	assign afi_rdata_valid = afi_rdata_en_delay[AFI_READ_VALID_DELAY-1];

	assign afi_cal_success = afi_cal_success_delay[AFI_CAL_SUCCESS_DELAY_STAGE-1];
	assign afi_cal_fail = 0;


	// Create registers to preserve ports


reg [AFI_ADDRESS_WIDTH-1:0] afi_addr_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`ifdef RLDRAMX
reg [AFI_BANK_WIDTH-1:0]    afi_ba_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CONTROL_WIDTH-1:0] afi_cas_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CONTROL_WIDTH-1:0] afi_we_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`ifdef RLDRAM3
reg [AFI_CONTROL_WIDTH-1:0] afi_rst_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`endif
`endif
`ifdef QDRII
reg [AFI_CONTROL_WIDTH-1:0] afi_wps_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CONTROL_WIDTH-1:0] afi_rps_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`endif
`ifdef DDRII_SRAM
reg [AFI_CONTROL_WIDTH-1:0] afi_ld_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CONTROL_WIDTH-1:0] afi_rw_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`endif
`ifdef DDRX_LPDDRX
reg [AFI_CLK_EN_WIDTH-1:0] afi_cke_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`ifdef DDRX
reg [AFI_BANK_WIDTH-1:0]    afi_ba_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CONTROL_WIDTH-1:0] afi_cas_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_ODT_WIDTH-1:0] afi_odt_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CONTROL_WIDTH-1:0] afi_ras_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_CONTROL_WIDTH-1:0] afi_we_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`endif
`ifdef DDR3
reg [AFI_CONTROL_WIDTH-1:0] afi_rst_n_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`endif
reg afi_mem_clk_disable_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_DQS_WIDTH-1:0]	afi_dqs_burst_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
`endif
reg [AFI_DATA_WIDTH-1:0]    afi_wdata_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_DQS_WIDTH-1:0]		afi_wdata_valid_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg [AFI_DATA_MASK_WIDTH-1:0]   afi_dm_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg afi_rdata_en_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;
reg afi_rdata_en_full_reg /* synthesis dont_merge no_prune syn_preserve = 1 */;

always @ (posedge pll_afi_clk) begin
	afi_addr_reg <= afi_addr;
	`ifdef RLDRAMX
	afi_ba_reg <= afi_ba;
	afi_cas_n_reg <= afi_cas_n;
	afi_cs_n_reg <= afi_cs_n;
	afi_we_n_reg <= afi_we_n;
	 `ifdef RLDRAM3
	afi_rst_n_reg <= afi_rst_n;
	 `endif
	`endif
	`ifdef QDRII
	afi_wps_n_reg <= afi_wps_n;
	afi_rps_n_reg <= afi_rps_n;
	`endif
	`ifdef DDRII_SRAM
	afi_ld_n_reg <= afi_ld_n;
	afi_rw_n_reg <= afi_rw_n;
	`endif
	`ifdef DDRX_LPDDRX
	afi_cke_reg <= afi_cke;
	afi_cs_n_reg <= afi_cs_n;
	`ifdef DDRX
	afi_ba_reg <= afi_ba;
	afi_cas_n_reg <= afi_cas_n;
	afi_odt_reg <= afi_odt;
	afi_ras_n_reg <= afi_ras_n;
	afi_we_n_reg <= afi_we_n;
	`endif
	`ifdef DDR3
	afi_rst_n_reg <= afi_rst_n;
	`endif
	afi_mem_clk_disable_reg <= afi_mem_clk_disable;
	afi_dqs_burst_reg <= afi_dqs_burst;
	`endif
	afi_wdata_reg <= afi_wdata;
	afi_wdata_valid_reg <= afi_wdata_valid;
	afi_dm_reg <= afi_dm;
	afi_rdata_en_reg <= afi_rdata_en;
	afi_rdata_en_full_reg <= afi_rdata_en_full;
end

`ifdef DDRX_LPDDRX
`ifdef DDRX
`endif
`ifdef DDR3
`endif
reg [AFI_MAX_WRITE_LATENCY_COUNT_WIDTH-1:0] afi_wlat_reg /* synthesis dont_merge syn_preserve = 1 */;
reg [AFI_MAX_READ_LATENCY_COUNT_WIDTH-1:0]  afi_rlat_reg /* synthesis dont_merge syn_preserve = 1 */;
`endif
reg [AFI_DATA_WIDTH-1:0]    afi_rdata_reg /* synthesis dont_merge syn_preserve = 1 */;

always @ (posedge pll_afi_clk) begin
	`ifdef DDRX_LPDDRX
	`ifdef DDRX
	`endif
	`ifdef DDR3
	`endif
	afi_wlat_reg <= 0;
	afi_rlat_reg <= 0;
	`endif
	afi_rdata_reg <= 0;
end

`ifdef DDRX_LPDDRX
`ifdef DDRX
`endif
`ifdef DDR3
`endif
assign afi_wlat =  afi_wlat_reg;
assign afi_rlat = afi_wlat_reg;
`endif
assign afi_rdata = afi_rdata_reg;


// Status interface
`ifdef NIOS_SEQUENCER

reg [AFI_DEBUG_INFO_WIDTH - 1:0] afi_cal_debug_info_reg /* synthesis dont_merge syn_preserve = 1 */;

always @ (posedge pll_afi_clk) begin
	afi_cal_debug_info_reg <= 0;
end

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
