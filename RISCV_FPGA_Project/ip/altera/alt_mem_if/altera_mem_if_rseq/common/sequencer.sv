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
// File name: sequencer.sv
// The sequencer is responsible for intercepting the AFI interface during the initialization and calibration stages
// During initialization stage, the sequencer executes a sequence according to the memory device spec
// There are 2 steps in the calibration stage:
// 1. Calibrates for read data valid in the returned memory clock domain (read valid prediction)
// 2. Calibrates for read data valid in the afi_clk domain (read latency calibration)
// After successful calibration, the sequencer will pass full control back to the AFI interface
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

module sequencer(
	pll_afi_clk,
	reset_n,
	seq_mux_address,
`ifdef RLDRAMII
	seq_mux_bank,
	seq_mux_cas_n,
	seq_mux_cs_n,
	seq_mux_we_n,
`endif
`ifdef QDRII
	seq_mux_wps_n,
	seq_mux_rps_n,
	seq_mux_doff_n,
`endif
`ifdef DDRII_SRAM
	seq_mux_ld_n,
	seq_mux_rw_n,
	seq_mux_doff_n,
`endif
`ifdef DDRX
	seq_mux_bank,
	seq_mux_cs_n,
	seq_mux_cke,
	seq_mux_odt,
	seq_mux_ras_n,
	seq_mux_cas_n,
	seq_mux_we_n,
`ifdef DDR3
 	seq_mux_reset_n,
`endif
`endif
	seq_mux_wdata,
	seq_mux_wdata_valid,
`ifdef DDRX
	seq_mux_dqs_en,
	seq_mux_vfifo_rd_en_override,
`endif
	seq_mux_dm,
	seq_mux_rdata_en,
	mux_seq_rdata,
	mux_seq_read_fifo_q,
	mux_seq_rdata_valid,
	mux_sel,
	seq_read_latency_counter,
	seq_read_increment_vfifo_fr,
	seq_read_increment_vfifo_hr,
	seq_read_increment_vfifo_qr,
`ifdef DDRX
	afi_rlat,
	afi_wlat,
`endif
	afi_cal_success,
	afi_cal_fail,
	seq_reset_mem_stable,
	seq_read_fifo_reset,
	seq_calib_init
);

// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver 


// PHY-Memory Interface
// Memory device specific parameters, they are set according to the memory spec
parameter MEM_ADDRESS_WIDTH     = ""; 
`ifdef RLDRAMII
parameter MEM_BANK_WIDTH        = ""; 
`endif
`ifdef DDRX
parameter MEM_BANK_WIDTH        = ""; 
parameter MEM_CLK_EN_WIDTH 		= ""; 
parameter MEM_ODT_WIDTH			= ""; 
`endif
parameter MEM_CHIP_SELECT_WIDTH = ""; 
parameter MEM_CONTROL_WIDTH     = ""; 
parameter MEM_DM_WIDTH          = ""; 
parameter MEM_DQ_WIDTH          = ""; 
parameter MEM_READ_DQS_WIDTH    = ""; 


// PHY-Controller (AFI) Interface
// The AFI interface widths are derived from the memory interface widths based on full/half rate operations
// The calculations are done on higher level wrapper
parameter AFI_ADDRESS_WIDTH         = ""; 
`ifdef RLDRAMII
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
`endif
`ifdef DDRX
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
parameter AFI_CLK_EN_WIDTH 			= ""; 
parameter AFI_ODT_WIDTH				= ""; 
parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH	= "";
parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH	= "";
`endif
parameter AFI_DATA_MASK_WIDTH       = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 
parameter AFI_DATA_WIDTH            = ""; 
parameter AFI_DQS_WIDTH				= "";
parameter AFI_R_RATIO		    ="";

// Read Datapath
parameter MAX_LATENCY_COUNT_WIDTH       = "";	// calibration finds the best latency by reducing the maximum latency  
parameter MAX_READ_LATENCY              = ""; 
parameter READ_FIFO_READ_ADDR_WIDTH     = ""; 
parameter READ_FIFO_WRITE_ADDR_WIDTH    = ""; 
parameter READ_VALID_TIMEOUT_WIDTH		= ""; 

// Write Datapath
// The sequencer uses this value to control write latency during calibration
parameter MAX_WRITE_LATENCY_COUNT_WIDTH = "";

// Initialization Sequence
parameter INIT_COUNT_WIDTH		= "";
`ifdef DDR2
parameter INIT_NOP_COUNT_WIDTH	= 8;
parameter RP_COUNT_WIDTH		= 3;
parameter MRD_COUNT_WIDTH		= 2;
parameter RFC_COUNT_WIDTH		= 8;
parameter OIT_COUNT_WIDTH 		= 3;
parameter MR0_BL				= "";
parameter MR0_BT				= "";
parameter MR0_CAS_LATENCY		= "";
parameter MR0_WR				= "";
parameter MR0_PD				= "";
parameter MR1_DLL				= "";
parameter MR1_ODS				= "";
parameter MR1_RTT				= "";
parameter MR1_AL				= "";
parameter MR1_DQS				= "";
parameter MR1_RDQS				= "";
parameter MR1_QOFF				= "";
parameter MR2_SRF				= "";
`endif
`ifdef DDR3
parameter RESET_COUNT_WIDTH 	= 18;
parameter CLK_DIS_COUNT_WIDTH 	= 3;
parameter INIT_NOP_COUNT_WIDTH	= 8;
parameter MRD_COUNT_WIDTH		= 2;
parameter MOD_COUNT_WIDTH		= 4;
parameter ZQINIT_COUNT_WIDTH 	= 9;
parameter MR0_BL				= "";
parameter MR0_BT				= "";
parameter MR0_CAS_LATENCY		= "";
parameter MR0_DLL				= "";
parameter MR0_WR				= "";
parameter MR0_PD				= "";
parameter MR1_DLL				= "";
parameter MR1_ODS				= "";
parameter MR1_RTT				= "";
parameter MR1_AL				= "";
parameter MR1_WL				= "";
parameter MR1_TDQS				= "";
parameter MR1_QOFF				= "";
parameter MR2_CWL				= "";
parameter MR2_ASR				= "";
parameter MR2_SRT				= "";
parameter MR2_RTT_WR			= "";
parameter MR3_MPR_RF			= "";
parameter MR3_MPR				= "";
`endif
`ifdef RLDRAMII
parameter MRSC_COUNT_WIDTH 		= ""; 
parameter INIT_NOP_COUNT_WIDTH	= ""; 
parameter MRS_CONFIGURATION		= ""; 
parameter MRS_BURST_LENGTH 		= ""; 
parameter MRS_ADDRESS_MODE 		= ""; 
parameter MRS_DLL_RESET 		= ""; 
parameter MRS_IMP_MATCHING		= ""; 
parameter MRS_ODT_EN 			= ""; 
`endif
parameter MEM_BURST_LENGTH      = "";
parameter MEM_T_WL              = "";
parameter MEM_T_RL              = "";

// The sequencer issues back-to-back reads during calibration, NOPs may need to be inserted depending on the burst length
parameter SEQ_BURST_COUNT_WIDTH = "";

// Width of the counter used to determine the number of cycles required
// to calculate if the rddata pattern is all 0 or all 1.
parameter VCALIB_COUNT_WIDTH    = "";

// Width of the calibration status register used to control calibration skipping.
parameter CALIB_REG_WIDTH		= "";

// local parameters
localparam AFI_DQ_GROUP_DATA_WIDTH = AFI_DATA_WIDTH / MEM_READ_DQS_WIDTH;
localparam MEM_DQ_GROUP_DATA_WIDTH = MEM_DQ_WIDTH / MEM_READ_DQS_WIDTH;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION

input	pll_afi_clk;
input	reset_n;


// sequencer version of the AFI interface
output	[AFI_ADDRESS_WIDTH-1:0] seq_mux_address;
`ifdef RLDRAMII
output  [AFI_BANK_WIDTH-1:0]    seq_mux_bank;
output  [AFI_CONTROL_WIDTH-1:0] seq_mux_cas_n;
output  [AFI_CHIP_SELECT_WIDTH-1:0] seq_mux_cs_n;
output  [AFI_CONTROL_WIDTH-1:0] seq_mux_we_n;
`endif
`ifdef QDRII
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_wps_n;
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_rps_n;
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_doff_n;
`endif
`ifdef DDRII_SRAM 
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_ld_n;
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_rw_n;
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_doff_n;
`endif
`ifdef DDRX
output	[AFI_BANK_WIDTH-1:0]    seq_mux_bank;
output	[AFI_CHIP_SELECT_WIDTH-1:0] seq_mux_cs_n;
output	[AFI_CLK_EN_WIDTH-1:0] seq_mux_cke;
output	[AFI_ODT_WIDTH-1:0] seq_mux_odt;
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_ras_n;
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_cas_n;
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_we_n;
`ifdef DDR3
output	[AFI_CONTROL_WIDTH-1:0] seq_mux_reset_n;
`endif
`endif

output  [AFI_DATA_WIDTH-1:0]    seq_mux_wdata;
output  [AFI_DQS_WIDTH-1:0]	seq_mux_wdata_valid;
`ifdef DDRX
output	[AFI_DQS_WIDTH-1:0]	seq_mux_dqs_en;
output	[MEM_READ_DQS_WIDTH-1:0] seq_mux_vfifo_rd_en_override;
`endif
output  [AFI_DATA_MASK_WIDTH-1:0]   seq_mux_dm;

output  [AFI_R_RATIO-1:0]	seq_mux_rdata_en;

// signals between the sequencer and the read datapath
input	[AFI_DATA_WIDTH-1:0]    mux_seq_rdata;	// read data from read datapath, thru sequencer, back to AFI
input	mux_seq_rdata_valid; // read data valid from read datapath, thru sequencer, back to AFI

// read data (no reordering) for indepedently FIFO calibrations (multiple FIFOs for multiple DQS groups)
input	[AFI_DATA_WIDTH-1:0]	mux_seq_read_fifo_q; 

output	mux_sel;

// sequencer outputs to controller AFI interface
`ifdef DDRX
output  [AFI_MAX_WRITE_LATENCY_COUNT_WIDTH-1:0] afi_wlat;
output  [AFI_MAX_READ_LATENCY_COUNT_WIDTH-1:0]  afi_rlat;
`endif
output	afi_cal_success;
output	afi_cal_fail;


// hold reset in the read capture clock domain until memory is stable
output	seq_reset_mem_stable;

// reset the read and write pointers of the data resynchronization FIFO in the read datapath 
output	[MEM_READ_DQS_WIDTH-1:0] seq_read_fifo_reset;

// read latency counter value from sequencer to inform read datapath when valid data should be read
output	[MAX_LATENCY_COUNT_WIDTH-1:0] seq_read_latency_counter;

// controls from sequencer to read datapath to calibration the valid prediction FIFO pointer offsets
output	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_fr; // increment valid prediction FIFO write pointer by an extra full rate cycle	
output	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_hr; // increment valid prediction FIFO write pointer by an extra half rate cycle
															  // in full rate core, both will mean an extra full rate cycle
output	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_qr;															  

input	[CALIB_REG_WIDTH-1:0] seq_calib_init;

reg	seq_reset_mem_stable;
reg	[MAX_LATENCY_COUNT_WIDTH-1:0] seq_read_latency_counter;

wire	[MEM_ADDRESS_WIDTH-1:0] seq_address;
`ifdef RLDRAMII
wire	[MEM_ADDRESS_WIDTH-1:0] mrs_address_dll_reset;
wire	[MEM_ADDRESS_WIDTH-1:0] mrs_address_dll_enable;
wire	[MEM_BANK_WIDTH-1:0]    seq_bank;
wire	[MEM_CONTROL_WIDTH-1:0] seq_cas_n;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] seq_cs_n;
wire	[MEM_CONTROL_WIDTH-1:0] seq_we_n;
`endif
`ifdef QDRII
wire	[MEM_CONTROL_WIDTH-1:0] seq_wps_n;
wire	[MEM_CONTROL_WIDTH-1:0] seq_rps_n;
reg 	[AFI_CONTROL_WIDTH-1:0] seq_mux_doff_n;
`endif
`ifdef DDRII_SRAM 
wire	[MEM_CONTROL_WIDTH-1:0] seq_ld_n;
wire	[MEM_CONTROL_WIDTH-1:0] seq_rw_n;
reg 	[AFI_CONTROL_WIDTH-1:0] seq_mux_doff_n;
`endif
`ifdef DDRX
wire	[MEM_BANK_WIDTH-1:0]    seq_bank;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] seq_cs_n;
wire	[MEM_CLK_EN_WIDTH-1:0] seq_cke;
wire	[MEM_ODT_WIDTH-1:0] seq_odt;
wire	[MEM_CONTROL_WIDTH-1:0] seq_ras_n;
wire	[MEM_CONTROL_WIDTH-1:0] seq_cas_n;
wire	[MEM_CONTROL_WIDTH-1:0] seq_we_n;
`ifdef DDR3
wire	seq_reset_n;
`endif
`endif
reg	[MEM_READ_DQS_WIDTH-1:0] seq_read_fifo_reset;

`ifdef HALF_RATE
wire  [MEM_ADDRESS_WIDTH-1:0] seq_address_l;
`ifdef RLDRAMII
wire  [MEM_CONTROL_WIDTH-1:0] seq_cas_n_l;
wire  [MEM_CHIP_SELECT_WIDTH-1:0] seq_cs_n_l;
wire  [MEM_CONTROL_WIDTH-1:0] seq_we_n_l;
wire  [MEM_BANK_WIDTH-1:0]    seq_bank_l;
`endif
`ifdef QDRII
wire  [MEM_CONTROL_WIDTH-1:0] seq_wps_n_l;
wire  [MEM_CONTROL_WIDTH-1:0] seq_rps_n_l;
`endif
`ifdef DDRII_SRAM 
wire  [MEM_CONTROL_WIDTH-1:0] seq_ld_n_l;
wire  [MEM_CONTROL_WIDTH-1:0] seq_rw_n_l;
`endif
`ifdef DDRX
wire	[MEM_BANK_WIDTH-1:0]    seq_bank_l;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] seq_cs_n_l;
wire	[MEM_CLK_EN_WIDTH-1:0] seq_cke_l;
wire	[MEM_ODT_WIDTH-1:0] seq_odt_l;
wire	[MEM_CONTROL_WIDTH-1:0] seq_ras_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] seq_cas_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] seq_we_n_l;
`ifdef DDR3
wire	seq_reset_n_l;
`endif
`endif
`endif

wire  [MEM_DQ_WIDTH-1:0]    seq_wrdata;
wire  [MEM_DQ_WIDTH-1:0]    seq_wrdata_all_ones_pattern;
wire  [MEM_DQ_WIDTH-1:0]    seq_wrdata_all_zeros_pattern;
`ifdef QDRII
wire  [AFI_DQS_WIDTH-1:0] seq_wrdata_en;
`else
reg  [AFI_DQS_WIDTH-1:0] seq_wrdata_en /* synthesis dont_merge */;
`endif

`ifdef DDRX
wire  seq_dqs_en;
`endif
wire  [AFI_DATA_MASK_WIDTH-1:0]   seq_wrdata_mask;


`ifdef NO_BURST_COUNT 
`else
reg	[SEQ_BURST_COUNT_WIDTH-1:0]	burst_count;
`endif

reg	[MAX_WRITE_LATENCY_COUNT_WIDTH-1:0] write_latency_count;
reg	[READ_FIFO_READ_ADDR_WIDTH-1:0] read_flush_count;

`ifdef DDR2
reg [INIT_NOP_COUNT_WIDTH-1:0] nop_count;
reg [RP_COUNT_WIDTH-1:0] rp_count;
reg [MRD_COUNT_WIDTH-1:0] mrd_count;
reg [RFC_COUNT_WIDTH-1:0] rfc_count;
reg [OIT_COUNT_WIDTH-1:0] oit_count;
`endif
`ifdef DDR3
reg [RESET_COUNT_WIDTH-1:0] mem_reset_count;
reg [CLK_DIS_COUNT_WIDTH-1:0] mem_clk_disable_count;
reg [INIT_NOP_COUNT_WIDTH-1:0] nop_count;
reg [MRD_COUNT_WIDTH-1:0] mrd_count;
reg [MOD_COUNT_WIDTH-1:0] mod_count;
reg [ZQINIT_COUNT_WIDTH-1:0] zqinit_count;	
`endif

reg	[INIT_COUNT_WIDTH-1:0] mem_stable_count;


`ifdef RLDRAMII
reg [MRSC_COUNT_WIDTH-1:0] mrsc_count; 
reg [MEM_BANK_WIDTH-1:0] bank_count;
reg [INIT_NOP_COUNT_WIDTH-1:0] nop0_count;
reg [INIT_NOP_COUNT_WIDTH-1:0] nop1_count;
`endif

reg	[1:0] write_states /* synthesis dont_merge */;
reg	[1:0] read_states /* synthesis dont_merge */;
`ifdef QDRII_CALIB_CONT_READ
wire	rps_only_states; 
`endif
wire	seq_rddata_en;

`ifdef RLDRAMII
wire	mrs_states;
wire	refresh_states;
wire 	[2:0] mem_configuration;
wire	[1:0] mem_burst_length;
wire	mem_address_mode;
wire	mem_dll_reset;
wire	mem_imp_matching;
wire	mem_odt_en; 
`endif

`ifdef DDR2
wire	mrs_states;
wire	precharge_states;
wire	refresh_states;
wire	[2:0] mem_MR0_BL;
wire	mem_MR0_BT;
wire	[2:0] mem_MR0_CAS_LATENCY;
wire	[2:0] mem_MR0_WR;
wire	mem_MR0_PD;
wire	mem_MR1_DLL;
wire	mem_MR1_ODS;
wire	[1:0] mem_MR1_RTT;
wire	[2:0] mem_MR1_AL;
wire	mem_MR1_DQS;
wire	mem_MR1_RDQS;
wire	mem_MR1_QOFF;
wire	mem_MR2_SRF;
wire	[16:0] mr0;
wire	[16:0] mr1;
wire	[16:0] mr2;
wire	[16:0] mr3;
wire	[16:0] mr0_dll_reset;
wire	[16:0] mr1_dll_enable;
wire	[16:0] mr1_ocd_cal_default;
wire	[16:0] mr1_ocd_cal_exit;
wire	[13:0] wr_addr0;
wire	[13:0] wr_addr1;
`endif

`ifdef DDR3
wire	mrs_states;
wire	[1:0] mem_MR0_BL;
wire	mem_MR0_BT;
wire	[2:0] mem_MR0_CAS_LATENCY;
wire	mem_MR0_DLL;
wire	[2:0] mem_MR0_WR;
wire	mem_MR0_PD;
wire	mem_MR1_DLL;
wire	[1:0] mem_MR1_ODS;
wire	[2:0] mem_MR1_RTT;
wire	[1:0] mem_MR1_AL;
wire	mem_MR1_WL;
wire	mem_MR1_TDQS;
wire	mem_MR1_QOFF;
wire	[2:0] mem_MR2_CWL;
wire	mem_MR2_ASR;
wire	mem_MR2_SRT;
wire	[1:0] mem_MR2_RTT_WR;
wire	[1:0] mem_MR3_MPR_RF;
wire	mem_MR3_MPR;
wire	[16:0] mr0;
wire	[16:0] mr1;
wire	[16:0] mr2;
wire	[16:0] mr3;
wire	[13:0] zqcl;
wire	[13:0] wr_addr0;
wire	[13:0] wr_addr1;
`endif

typedef enum int unsigned {
	STATE_RESET,
	STATE_LOAD_INIT,
	STATE_RESET_VCALIB_RDDATA_BURST,
	STATE_RESET_PHY_SEQ_RDDATA_BURST,
	STATE_RESET_READ_FIFO_RESET,
	STATE_RESET_READ_FIFO_RESET2,
`ifdef DDR3
	STATE_MEM_RESET,
	STATE_MEM_CLK_DISABLE,
	STATE_MEM_RESET_RELEASE,
`endif
	STATE_STABLE,
`ifdef DDR2
	STATE_NOP,
	STATE_PRECHARGE_ALL0,
	STATE_TRP0,
	STATE_EMR2,
	STATE_TMRD0,
	STATE_EMR3,
	STATE_TMRD1,
	STATE_EMR1_DLL_ENABLE,
	STATE_TMRD2,
	STATE_MRS_DLL_RESET,
	STATE_TMRD3,
	STATE_PRECHARGE_ALL1,
	STATE_TRP1,
	STATE_AUTO_REFRESH0,
	STATE_TRFC0,
	STATE_AUTO_REFRESH1,
	STATE_TRFC1,
	STATE_MRS,
	STATE_TMRD4,
	STATE_EMR1_OCD_CAL_DEFAULT,
	STATE_TMRD5,
	STATE_EMR1_OCD_CAL_EXIT,
	STATE_TOIT,
	STATE_BANK_ACTIVATE,
	STATE_ASSERT_ODT,
`endif
`ifdef DDR3
	STATE_NOP,
	STATE_MR2,
	STATE_TMRD0,
	STATE_MR3,
	STATE_TMRD1,
	STATE_MR1,
	STATE_TMRD2,
	STATE_MR0,
	STATE_TMOD,
	STATE_ZQCL,
	STATE_TZQINIT,
	STATE_BANK_ACTIVATE,
	STATE_ASSERT_ODT,
`endif
`ifdef RLDRAMII
	STATE_DUMMY_MRS0,
	STATE_DUMMY_MRS1,
	STATE_MRS_DLL_RESET,
	STATE_MRSC,
	STATE_MRS_DLL_ENABLE,
	STATE_REFRESH,
	STATE_NOP0,
	STATE_NOP1,
`endif
	STATE_WRITE_ZERO,
	STATE_WAIT_WRITE_ZERO,
	STATE_WRITE_ONE,
	STATE_WAIT_WRITE_ONE,
	STATE_WAIT_WRITE_TO_READ,
	STATE_V_READ_ZERO,
`ifdef HALF_RATE
	`ifdef BURST8
	STATE_V_READ_NOP,
	`endif
`else
	`ifdef BURST4
	STATE_V_READ_NOP,
	`endif
	`ifdef BURST8
	STATE_V_READ_NOP0,
	STATE_V_READ_NOP1,
	STATE_V_READ_NOP2,
	`endif
`endif
	STATE_V_READ_ONE,
	STATE_V_WAIT_READ,
	STATE_V_COMPARE_READ_ZERO_READ_ONE,
	STATE_V_CHECK_READ_FAIL,
    STATE_V_ADD_FULL_RATE,
	STATE_V_ADD_HALF_RATE,
	STATE_V_READ_FIFO_RESET,
	STATE_V_READ_FIFO_RESET2,
	STATE_V_READ_FIFO_RESET_SYNC,
	STATE_V_READ_FIFO_RESET_SYNC2,
	STATE_V_READ_FIFO_RESET_SYNC3,
	STATE_V_READ_FIFO_RESET_SYNC4,
	STATE_V_READ_FIFO_RESET_SYNC5,
	STATE_V_CALIB_DONE,
	STATE_L_READ_ONE,
	STATE_L_WAIT_READ,
	STATE_L_COMPARE_READ_ONE,
	STATE_L_REDUCE_LATENCY,
	STATE_L_READ_FLUSH,
	STATE_L_WAIT_READ_FLUSH,
	STATE_L_ADD_MARGIN,
`ifdef DDRX
	STATE_BANK_PRECHARGE,
`endif
	STATE_CALIB_DONE,
	STATE_CALIB_FAIL
} state_t;

state_t state;

reg	lfifo_cal_has_passing_reads;
reg	add_fr_cycle_to_valid;
reg	[READ_VALID_TIMEOUT_WIDTH-1:0] read_valid_timeout_count;
reg	[MEM_READ_DQS_WIDTH-1:0] vcalib_count;

wire	[AFI_DATA_WIDTH-1:0] vcalib_rddata;

`ifdef NO_BURST_COUNT
reg		[1:0] [AFI_DATA_WIDTH-1:0] vcalib_rddata_burst;
reg	    [0:0] vcalib_rddata_burst_count;
`else
reg		[2**(SEQ_BURST_COUNT_WIDTH+1)-1:0] [AFI_DATA_WIDTH-1:0] vcalib_rddata_burst;
reg	    [(SEQ_BURST_COUNT_WIDTH+1)-1:0]	vcalib_rddata_burst_count;

wire [2**SEQ_BURST_COUNT_WIDTH-1:0] vcalib_rddata_all_zero_by_burst;
wire [2**SEQ_BURST_COUNT_WIDTH-1:0] vcalib_rddata_all_one_by_burst;
`endif

wire [AFI_DATA_WIDTH-1:0] vcalib_rddata_all_ones_pattern;
wire [AFI_DATA_WIDTH-1:0] vcalib_rddata_all_zeros_pattern;
wire vcalib_rddata_all_zero;
wire vcalib_rddata_all_one;

reg [VCALIB_COUNT_WIDTH-1:0] vcalib_rddata_delay_counter;

wire mux_seq_rdata_all_one;
`ifdef NO_BURST_COUNT
reg		[AFI_DATA_WIDTH-1:0] mux_seq_rdata_burst;
`else
reg		[2**(SEQ_BURST_COUNT_WIDTH)-1:0] [AFI_DATA_WIDTH-1:0] mux_seq_rdata_burst;

wire [2**SEQ_BURST_COUNT_WIDTH-1:0] mux_seq_rdata_all_one_by_burst;
`endif

wire [AFI_DATA_WIDTH-1:0]    mux_seq_rdata_noxz;
wire [AFI_DATA_WIDTH-1:0]    mux_seq_read_fifo_q_noxz;

`ifdef SIMGEN
	sim_filter_xz #(.width(AFI_DATA_WIDTH)) sim_filter_xz_rdata(
		.i(mux_seq_rdata),
		.o(mux_seq_rdata_noxz));

	sim_filter_xz #(.width(AFI_DATA_WIDTH)) sim_filter_xz_read_fifo_q(
		.i(mux_seq_read_fifo_q),
		.o(mux_seq_read_fifo_q_noxz));
`else
	assign mux_seq_rdata_noxz = mux_seq_rdata;
	assign mux_seq_read_fifo_q_noxz = mux_seq_read_fifo_q;
`endif


	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n) begin
			state <= STATE_RESET;
			read_states <= 2'b00;
			write_states <= 2'b00;
`ifdef QDRII
`else
			seq_wrdata_en <= {AFI_DQS_WIDTH{1'b0}};
`endif			
		end else begin
			read_states <= 2'b00;
			write_states <= 2'b00;
`ifdef QDRII
`else
			seq_wrdata_en <= {AFI_DQS_WIDTH{1'b0}};
`endif			
			
			case (state)

			// *******************************************************************************************************************
			// INITIALIZATION

				// wait until reset is de-asserted
				STATE_RESET:
					state <= STATE_LOAD_INIT; 

				// load any initialization valus
				STATE_LOAD_INIT:
					state <= STATE_RESET_READ_FIFO_RESET;

				// reset the read group FIFO
				STATE_RESET_READ_FIFO_RESET:
					state <= STATE_RESET_READ_FIFO_RESET2;
				
				STATE_RESET_READ_FIFO_RESET2:
					state <= STATE_RESET_VCALIB_RDDATA_BURST;
				
				// reset the vcalib_rddata_burst vector
				STATE_RESET_VCALIB_RDDATA_BURST:
					state <= STATE_RESET_PHY_SEQ_RDDATA_BURST;

				// reset the mux_seq_rdata_burst vector
				STATE_RESET_PHY_SEQ_RDDATA_BURST:
				`ifdef DDR3
					state <= STATE_MEM_RESET;
				`else
					state <= STATE_STABLE; 
				`endif

				`ifdef DDR3
				// reset to memory (mem_reset_n) must be asserted for at least 200us
				STATE_MEM_RESET:				
				begin
					if (&mem_reset_count)
						state <= STATE_MEM_CLK_DISABLE;
					else
						state <= STATE_MEM_RESET;
				end

				// mem_reset_n=0 and mem_cke=0 must overlap for at least 10ns 	
				STATE_MEM_CLK_DISABLE:
				begin
					if (&mem_clk_disable_count)
						state <= STATE_MEM_RESET_RELEASE;
					else
						state <= STATE_MEM_CLK_DISABLE;
				end

				STATE_MEM_RESET_RELEASE:
					state <= STATE_STABLE; 			

				`endif

				// wait until memory is stable
				STATE_STABLE:
 				begin
					if (&mem_stable_count) begin // wait until maximum count is reached
					`ifdef RLDRAMII
					    // RLDRAMII spec requires min 200us wait time before initialization starts
						// mem_stable_count is a counter of width 18, 2^18 cycles @533MHz is equivalent to 491us
						// An initialization sequence then needs to be executed 	
						state <= STATE_DUMMY_MRS0;
					`endif
					`ifdef QDRII
						// QDRII spec requires min 20us power up wait time, the memory is in operation mode after that
						// mem_stable_count is a counter of width 15, 2^15 cycles @550MHz is equivalent to 60us
						state <= STATE_WRITE_ZERO;
						write_states <= 2'b11;
					`endif
					`ifdef DDRII_SRAM 
						// DDRII_SRAM spec requires 1024 cycles of power up wait time, the memory is in operation mode after that
						// mem_stable_count is a counter of width 10, i.e. 1024 cycles
						state <= STATE_WRITE_ZERO;
						write_states <= 2'b11;
					`endif
					`ifdef DDR2
						state <= STATE_NOP; 
					`endif
					`ifdef DDR3
						state <= STATE_NOP; 
					`endif
					end else
						state <= STATE_STABLE;
				end

			`ifdef DDR2
				STATE_NOP:
				begin
					if (&nop_count)
						state <= STATE_PRECHARGE_ALL0; 
					else
						state <= STATE_NOP;
				end
				STATE_PRECHARGE_ALL0:
					state <= STATE_TRP0;
				STATE_TRP0:
				begin
					if (&rp_count)
						state <= STATE_EMR2;
					else
						state <= STATE_TRP0;
				end
				STATE_EMR2:
					state <= STATE_TMRD0;
				STATE_TMRD0:
                begin
                    if (&mrd_count)
                        state <= STATE_EMR3;
                    else
                        state <= STATE_TMRD0;
                end
				STATE_EMR3:
					state <= STATE_TMRD1;
				STATE_TMRD1:
                begin
                    if (&mrd_count)
                        state <= STATE_EMR1_DLL_ENABLE;
                    else
                        state <= STATE_TMRD1;
                end
				STATE_EMR1_DLL_ENABLE:
					state <= STATE_TMRD2;
				STATE_TMRD2:
                begin
                    if (&mrd_count)
                        state <= STATE_MRS_DLL_RESET;
                    else
                        state <= STATE_TMRD2;
                end
				STATE_MRS_DLL_RESET:
					state <= STATE_TMRD3;
				STATE_TMRD3:
                begin
                    if (&mrd_count)
                        state <= STATE_PRECHARGE_ALL1;
                    else
                        state <= STATE_TMRD3;
                end
				STATE_PRECHARGE_ALL1:
					state <= STATE_TRP1;
				STATE_TRP1:
				begin
					if (&rp_count)
						state <= STATE_AUTO_REFRESH0; 
					else
						state <= STATE_TRP1;
				end
				STATE_AUTO_REFRESH0:
					state <= STATE_TRFC0;
				STATE_TRFC0:
				begin
					if (&rfc_count)
						state <= STATE_AUTO_REFRESH1; 
					else
						state <= STATE_TRFC0;
				end
				STATE_AUTO_REFRESH1:
					state <= STATE_TRFC1;
				STATE_TRFC1:
				begin
					if (&rfc_count)
						state <= STATE_MRS;
					else
						state <= STATE_TRFC1;
				end
				STATE_MRS:
					state <= STATE_TMRD4;
				STATE_TMRD4:
                begin
                    if (&mrd_count)
                        state <= STATE_EMR1_OCD_CAL_DEFAULT;
                    else
                        state <= STATE_TMRD4;
                end
				STATE_EMR1_OCD_CAL_DEFAULT:
					state <= STATE_TMRD5;
				STATE_TMRD5:
                begin
                    if (&mrd_count)
						state <= STATE_EMR1_OCD_CAL_EXIT;
                    else
                        state <= STATE_TMRD5;
                end
				STATE_EMR1_OCD_CAL_EXIT:
					state <= STATE_TOIT;
				STATE_TOIT:
                begin
                    if (&oit_count)
                        state <= STATE_BANK_ACTIVATE;
                    else
                        state <= STATE_TOIT;
                end
				STATE_BANK_ACTIVATE:
					state <= STATE_ASSERT_ODT;
				STATE_ASSERT_ODT:
				begin
					state <= STATE_WRITE_ZERO; 	
					write_states <= 2'b11;
				end
			`endif

			`ifdef DDR3
				STATE_NOP:
				begin
					if (&nop_count)
						state <= STATE_MR2; 
					else
						state <= STATE_NOP;
				end
				STATE_MR2:
					state <= STATE_TMRD0;
				STATE_TMRD0:
				begin
					if (&mrd_count)
						state <= STATE_MR3;
					else
						state <= STATE_TMRD0;
				end
				STATE_MR3:
					state <= STATE_TMRD1;
				STATE_TMRD1:
                begin
                    if (&mrd_count)
                        state <= STATE_MR1;
                    else
                        state <= STATE_TMRD1;
                end
				STATE_MR1:
					state <= STATE_TMRD2;
				STATE_TMRD2:
                begin
                    if (&mrd_count)
                        state <= STATE_MR0;
                    else
                        state <= STATE_TMRD2;
                end
				STATE_MR0:
					state <= STATE_TMOD;
				STATE_TMOD:
				begin
					if (&mod_count)
						state <= STATE_ZQCL; 
					else
						state <= STATE_TMOD;
				end
				STATE_ZQCL:
					state <= STATE_TZQINIT;
				STATE_TZQINIT:
				begin
					if (&zqinit_count)
						state <= STATE_BANK_ACTIVATE;
					else
						state <= STATE_TZQINIT;
				end
				STATE_BANK_ACTIVATE:
					state <= STATE_ASSERT_ODT;
				STATE_ASSERT_ODT:
				begin
					state <= STATE_WRITE_ZERO; 	
					write_states <= 2'b11;
				end
			`endif

			`ifdef RLDRAMII
				// RLDRAMII Initialization Sequence, refer to RLDRAMII spec
				
				// 1st dummy MRS command (address pins held low)
				STATE_DUMMY_MRS0:
					state <= STATE_DUMMY_MRS1;
				// 2nd dummy MRS command (address pins held low)
				STATE_DUMMY_MRS1:
					state <= STATE_MRS_DLL_RESET;
				// Valid MRS command with DLL reset (address pins set according to mode register)
				STATE_MRS_DLL_RESET:
					state <= STATE_MRSC;
				// Wait for at least tMRSC (6 cycles) 	
				STATE_MRSC:
				begin
					if (&mrsc_count) // wait unitl maximum count is reached (default to 8)
						state <= STATE_MRS_DLL_ENABLE;
					else
						state <= STATE_MRSC;
				end
				// Valid MRS command with DLL enable (address pins set according to mode register)
				STATE_MRS_DLL_ENABLE:
					state <= STATE_NOP0;
				// Wait at least 1024 cycles for the DLL to reset
				STATE_NOP0:
				begin
					if (&nop0_count) begin
						state <= STATE_REFRESH;
					end else
						state <= STATE_NOP0;
				end
				// issue refresh command to all banks
				STATE_REFRESH:
				begin
					if (&bank_count) // repeat until all banks are refreshed
						state <= STATE_NOP1;
					else
						state <= STATE_REFRESH;
				end
				// at least 1024 NOP commands must be issued prior to normal operation
				STATE_NOP1:
				begin
					if (&nop1_count) begin
						state <= STATE_WRITE_ZERO;
						write_states <= 2'b11;
					end else
						state <= STATE_NOP1;
				end
			`endif
			// *******************************************************************************************************************


	
			// *******************************************************************************************************************
			// WRITE CALIBRATION PATTERNS

				// Write States, 2 patterns: all 0's and all 1's

				// issue write command to address 0, bank 0 (bank address is N/A in QDRII)
				STATE_WRITE_ZERO: 
				begin
					state <= STATE_WAIT_WRITE_ZERO;
`ifdef QDRII
`else
					seq_wrdata_en <= {AFI_DQS_WIDTH{1'b1}};
`endif
				end

				// write data pattern all 0's	
				STATE_WAIT_WRITE_ZERO: 
				begin
					if (&write_latency_count)  begin // count is long enough (16 cycles) to accomodate for worst case write latency
						state <= STATE_WRITE_ONE;
						write_states <= 2'b11;
					end else begin
						state <= STATE_WAIT_WRITE_ZERO;
`ifdef QDRII
`else
						seq_wrdata_en <= {AFI_DQS_WIDTH{1'b1}};
`endif
					end
				end

				// issue write command to address 1, bank 1 (bank address is N/A in QDRII)
				STATE_WRITE_ONE: 
				begin
					state <= STATE_WAIT_WRITE_ONE;
`ifdef QDRII
`else
					seq_wrdata_en <= {AFI_DQS_WIDTH{1'b1}};
`endif
				end

				// write data pattern all 1's
				STATE_WAIT_WRITE_ONE: 
				begin
					if (&write_latency_count)  // count is long enough (16 cycles) to accomodate for worst case write latency
						state <= STATE_WAIT_WRITE_TO_READ;
					else begin
						state <= STATE_WAIT_WRITE_ONE;
`ifdef QDRII
`else
						seq_wrdata_en <= {AFI_DQS_WIDTH{1'b1}};
`endif
					end
				end
				
				// insert a nop cycle between write and read to make sure read data doesn't coincide with OCT postamble for bidir bus protocols
				STATE_WAIT_WRITE_TO_READ:
				begin
					state <= STATE_V_READ_FIFO_RESET;
				end
				
			// *******************************************************************************************************************


			// *******************************************************************************************************************
			// VALID CALIBRATION

			// Issue 2 back-to-back reads
			// 1st read to address 0, expected pattern is all 0's
			// 2nd read to address 1, expected pattern is all 1's
			// so that there will be a transition from 0 to 1 on all the data lines
			// Depending on the burst length, NOP commands need to be inserted between the 2 read commands
			// in order to avoid collision on the data bus
		
			`ifdef HALF_RATE

				// issue read command to address 0, bank 0 (bank address is N/A in QDRII)
				STATE_V_READ_ZERO:
				begin
				`ifdef BURST4
					 // 1 NOP between commands is required in BL=4 mode
					 // In half rate mode, read commands are issued on the high channel
					 // the low channel is unused, which results in a full rate cycle of NOP
					 state <= STATE_V_READ_ONE;
					 read_states <= 2'b11;
				`endif
				`ifdef BURST8
					// 3 NOPs between commands are required in BL=8 mode
					// In half rate mode, read commands are issued on the high channel
					// the low channel is unused, which results in a full rate cycle of NOP
					// An extra half rate cycle (STATE_V_READ_NOP) will mean 2 more full rate NOPs 
					state <= STATE_V_READ_NOP;
				`endif
				end

				`ifdef BURST8
				STATE_V_READ_NOP:
				begin
					state <= STATE_V_READ_ONE;
					read_states <= 2'b11;
				end
				`endif

			`else 
				// issue read command to address 0, bank 0 (bank address is N/A in QDRII)
				STATE_V_READ_ZERO:
				begin
				`ifdef BURST2
					// In BL=2 mode, back to back commands can be issued, no NOP is required in between
					state <= STATE_V_READ_ONE;	
					read_states <= 2'b11;
				`endif

				`ifdef BURST4
					// In BL=4 mode, 1 NOP is required between 2 read commands
					state <= STATE_V_READ_NOP;
				`endif
				
				`ifdef BURST8
					// In BL=8 mode, 3 NOPs are required between 2 read commands
					state <= STATE_V_READ_NOP0;
				`endif
				end
								
				`ifdef BURST4
				STATE_V_READ_NOP:
				begin
					state <= STATE_V_READ_ONE;
					read_states <= 2'b11;
				end
				`endif

				`ifdef BURST8
				STATE_V_READ_NOP0:
					state <= STATE_V_READ_NOP1;
				STATE_V_READ_NOP1:
					state <= STATE_V_READ_NOP2;
				STATE_V_READ_NOP2:
				begin
					state <= STATE_V_READ_ONE;
					read_states <= 2'b11;
				end
				`endif
			`endif

				// issue read command to address 1, bank 1 (bank address is N/A in QDRII)
				STATE_V_READ_ONE:
					state <= STATE_V_WAIT_READ;

				// wait for valid read data, read data is 2 back to back reads
				STATE_V_WAIT_READ:
                begin
                	if (mux_seq_rdata_valid)
						// In full rate, BL=2, 1 read --> 1 AFI cycle of valid data
						// In full rate, BL=4, 1 read --> 2 AFI cycles of valid data
						// In full rate, BL=8, 1 read --> 4 AFI cycles of valid data
						// In half rate, BL=2, not supported
						// In half rate, BL=4, 1 read --> 1 AFI cycle of valid data
						// In half rate, BL=8, 1 read --> 2 AFI cycles of valid data							
                		if (&vcalib_rddata_burst_count)
							state <= STATE_V_COMPARE_READ_ZERO_READ_ONE;
	                	else
							state <= STATE_V_WAIT_READ;
                	else
						state <= STATE_V_WAIT_READ;
				end

				// parameterizable number of cycles to wait before
				// making the compariosn of rddata to 0.
				// if data is not the valid FIFO pointer needs to be adjusted
				STATE_V_COMPARE_READ_ZERO_READ_ONE:
				begin
					if (&vcalib_rddata_delay_counter)
						if ((vcalib_rddata_all_zero) & (vcalib_rddata_all_one))
							state <= STATE_V_CALIB_DONE;
						else
							state <= STATE_V_CHECK_READ_FAIL;
					else
						state <= STATE_V_COMPARE_READ_ZERO_READ_ONE;
					
				end

				// when a read fails, the write pointer (in AFI clock domain) of the valid FIFO is incremented
				// the read pointer of the valid FIFO is in the memory returned clock domain
				// the gap between the read and write pointers is effectively the latency between 
				// the time when the PHY receives the read command and the time valid data is returned to the PHY
				// see read_datapath.v for detailed implementation	
				STATE_V_CHECK_READ_FAIL: 
				begin
					if (&read_valid_timeout_count)	// calibration fails when timeout reaches maximum
						state <= STATE_CALIB_FAIL;
					else
						if (add_fr_cycle_to_valid)	
							state <= STATE_V_ADD_FULL_RATE; 
						else
							state <= STATE_V_ADD_HALF_RATE;
				end

				// advance read valid fifo write pointer by an extra full rate cycle
				STATE_V_ADD_FULL_RATE: 
					state <= STATE_V_READ_FIFO_RESET;

				// advance read valid fifo write pointer by an extra half rate cycle (i.e. 2 full rate cycle)
				// in full rate core, this will just add another full rate cycle
				STATE_V_ADD_HALF_RATE: 
					state <= STATE_V_READ_FIFO_RESET;

				// reset the read and write pointers of the read data synchronization FIFO
				// read valid FIFO read output controls the write pointer of the read data synchronization FIFO
				// in the proper case, write pointer of data synchronization FIFO should only be incremented when read command is issued
				// Examples of failing cases:
				// 1. During warm reset, there are left over read commands in the valid FIFO, valid FIFO outputs a 1, write pointer of 
				//    synchronization FIFO is incremented but read pointer of synchronization FIFO is not because there is no real read command
				//    issued after the warm reset, write and read pointers are now out of sync.
				// 2. Read and write pointers of the valid FIFO can be pointing to the same location (e.g. right after reset), writing and 
				//    reading at the same time can result in unknown output, this can cause a false increment on the write pointer of the data
				//    synchronization FIFO. 
				// The READ_FIFO_RESET state ensures that both the write and read pointers of the synchronization FIFO are restarting at 0.
				//
				STATE_V_READ_FIFO_RESET:
					state <= STATE_V_READ_FIFO_RESET2;

				STATE_V_READ_FIFO_RESET2:
					state <= STATE_V_READ_FIFO_RESET_SYNC;
				
				// The reset signal is registered both by the sequencer and in the read datapath before 
				// reaching the read fifo. The reset-sync states are to take into account the additional
				// clock cycles so that the reset signal never clashes with a subsequent wren signal to
				// the read FIFO.
				STATE_V_READ_FIFO_RESET_SYNC:
					state <= STATE_V_READ_FIFO_RESET_SYNC2;
					
				STATE_V_READ_FIFO_RESET_SYNC2:
					state <= STATE_V_READ_FIFO_RESET_SYNC3;
				
				STATE_V_READ_FIFO_RESET_SYNC3:
					state <= STATE_V_READ_FIFO_RESET_SYNC4;
					
				STATE_V_READ_FIFO_RESET_SYNC4:
					state <= STATE_V_READ_FIFO_RESET_SYNC5;
					
				STATE_V_READ_FIFO_RESET_SYNC5:
				begin
					state <= STATE_V_READ_ZERO;
					read_states <= 2'b11;
				end
				
				// repeat valid calibration for each DQS group (1 pair of valid FIFO and data resynchronization per DQS group)
				// when all DQS groups are done, move on to latency calibration
				STATE_V_CALIB_DONE:
				begin
					read_states <= 2'b11;
					if (vcalib_count == (MEM_READ_DQS_WIDTH-1))
						state <= STATE_L_READ_ONE;
					else
						state <= STATE_V_READ_ZERO;
				end

			// *******************************************************************************************************************



			// *******************************************************************************************************************
			// LATENCY CALIBRATION
		
				// the purpose of latency calibration is to find the optimal latency
				// keep reading back the all 1's pattern by reducing the latency cycle by cycle until the read fails
	

				// issue read command to address 1, bank 1 (bank address is N/A in QDRII)
				STATE_L_READ_ONE:
					state <= STATE_L_WAIT_READ;

				// Wait until the burst has been received.
				STATE_L_WAIT_READ:
				begin
                    if (mux_seq_rdata_valid)
						`ifdef NO_BURST_COUNT 
                            state <= STATE_L_COMPARE_READ_ONE;
						`else
							begin
								if (&burst_count)
									state <= STATE_L_COMPARE_READ_ONE;
								else
									state <= STATE_L_WAIT_READ;
							end
						`endif
                    else
                        state <= STATE_L_WAIT_READ;
                end

	
				// wait for valid read data, expected data is all 1's
				// if data is correct, reduce the read latency and try again
				// if data is incorrect, that means the optimal read latency has been found, add margin for run time uncertainties 				
				STATE_L_COMPARE_READ_ONE:
				begin
					if (&vcalib_rddata_delay_counter)
						if (mux_seq_rdata_all_one)
							state <= STATE_L_REDUCE_LATENCY;
						else if (lfifo_cal_has_passing_reads)
							state <= STATE_L_ADD_MARGIN;
						else
							state <= STATE_CALIB_FAIL;
					else
						state <= STATE_L_COMPARE_READ_ONE;
					
				end

				// reduce the ready latency by one AFI cycle
				STATE_L_REDUCE_LATENCY:
				begin
					state <= STATE_L_READ_FLUSH;
					read_states <= 2'b11;
				end

				// flush the data synchronization FIFO with all 0's to make sure that correct data was not from the previous run with 
				// a higher read latency
				STATE_L_READ_FLUSH:
					state <= STATE_L_WAIT_READ_FLUSH;

				// wait for valid data (all 0's) to come back and repeat until every entry of the data FIFO is flushed
				STATE_L_WAIT_READ_FLUSH:
                begin
                    if (mux_seq_rdata_valid & (read_flush_count == 0)) begin
			`ifdef NO_BURST_COUNT
						state <= STATE_L_READ_ONE;
						read_states <= 2'b11;
			`else
						if (&burst_count) begin
							state <= STATE_L_READ_ONE;
							read_states <= 2'b11;
						end else	
							state <= STATE_L_WAIT_READ_FLUSH; 
					`endif
                    end else if (mux_seq_rdata_valid) begin
					`ifdef NO_BURST_COUNT
						state <= STATE_L_READ_FLUSH;
						read_states <= 2'b11;
					`else
						if (&burst_count) begin
							state <= STATE_L_READ_FLUSH;
							read_states <= 2'b11;
						end else
							state <= STATE_L_WAIT_READ_FLUSH;
					`endif
					end else
                        state <= STATE_L_WAIT_READ_FLUSH;
                end

				// This state is reached from a read failure, add 1 AFI cycle for a correct read (minimum latency)
				// add 2 more AFI cycles to account for run time uncertainties
				STATE_L_ADD_MARGIN:
				`ifdef DDRX
					state <= STATE_BANK_PRECHARGE;
				`else
					state <= STATE_CALIB_DONE;
				`endif

				`ifdef DDRX
				STATE_BANK_PRECHARGE:
					state <= STATE_CALIB_DONE;
				`endif			
	
				STATE_CALIB_DONE:
					state <= STATE_CALIB_DONE;

				STATE_CALIB_FAIL:
					state <= STATE_CALIB_FAIL;

			// *******************************************************************************************************************
			endcase
		end
	end

	// Generate the status bits indicating that the entire valid read was
	// all one or all zeros.
`ifdef NO_BURST_COUNT
	assign vcalib_rddata_all_zero = (vcalib_rddata_burst[0] == vcalib_rddata_all_zeros_pattern);
	assign vcalib_rddata_all_one = (vcalib_rddata_burst[1] == vcalib_rddata_all_ones_pattern);
`else
	generate
	genvar burstnum;
		for (burstnum=0; burstnum<2**SEQ_BURST_COUNT_WIDTH; burstnum=burstnum+1)
		begin: vcalib_rddata_calc
			assign vcalib_rddata_all_zero_by_burst[burstnum] = (vcalib_rddata_burst[burstnum] == vcalib_rddata_all_zeros_pattern);
			assign vcalib_rddata_all_one_by_burst[burstnum] = (vcalib_rddata_burst[2**SEQ_BURST_COUNT_WIDTH+burstnum] == vcalib_rddata_all_ones_pattern);
		end
	endgenerate
	assign vcalib_rddata_all_zero = &vcalib_rddata_all_zero_by_burst;
	assign vcalib_rddata_all_one = &vcalib_rddata_all_one_by_burst;
`endif


	// Generate the status bits indicating that the entire latency read was
	// all one
	wire  [AFI_DATA_WIDTH-1:0] mux_seq_rdata_all_ones_pattern;
	generate
		if (MEM_DQ_WIDTH % 2 == 0)
			assign mux_seq_rdata_all_ones_pattern  = {(AFI_DATA_WIDTH / MEM_DQ_WIDTH){{MEM_DQ_WIDTH/2{ 2'b10 }}}};
		else
			assign mux_seq_rdata_all_ones_pattern  = {(AFI_DATA_WIDTH / MEM_DQ_WIDTH){{1'b0, {(MEM_DQ_WIDTH-1)/2{ 2'b10 }}}}};
	endgenerate
	
`ifdef NO_BURST_COUNT
	assign mux_seq_rdata_all_one = (mux_seq_rdata_burst == mux_seq_rdata_all_ones_pattern);
`else
	generate
	genvar lcalib_burstnum;
		for (lcalib_burstnum=0; lcalib_burstnum<2**SEQ_BURST_COUNT_WIDTH; lcalib_burstnum=lcalib_burstnum+1)
		begin: lcalib_mux_seq_calc
			assign mux_seq_rdata_all_one_by_burst[lcalib_burstnum] = (mux_seq_rdata_burst[lcalib_burstnum] == mux_seq_rdata_all_ones_pattern);
		end
	endgenerate
	assign mux_seq_rdata_all_one = &mux_seq_rdata_all_one_by_burst;
`endif


	// generate the delay counter used to delay rddata comparison
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			vcalib_rddata_delay_counter <= {VCALIB_COUNT_WIDTH{1'b0}};
		else
			if ((state == STATE_V_COMPARE_READ_ZERO_READ_ONE) || (state == STATE_L_COMPARE_READ_ONE))
				vcalib_rddata_delay_counter <= vcalib_rddata_delay_counter + 1'b1;
			else
				vcalib_rddata_delay_counter <= {VCALIB_COUNT_WIDTH{1'b0}};
	end


	// Create the vcalib_rddata_burst block and counter
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n) begin

`ifdef NO_BURST_COUNT
			vcalib_rddata_burst_count <= 1'b0;
`else
			vcalib_rddata_burst_count <= {(SEQ_BURST_COUNT_WIDTH+1){1'b0}};
`endif
		end
		else
			if (mux_seq_rdata_valid) begin
				vcalib_rddata_burst_count <= vcalib_rddata_burst_count + 1'b1;
			end
			else begin
`ifdef NO_BURST_COUNT
				vcalib_rddata_burst_count <= 1'b0;
`else
				vcalib_rddata_burst_count <= {(SEQ_BURST_COUNT_WIDTH+1){1'b0}};
`endif
			end
	end

	// Capture the vcalib_rddata based on its burst index
	always_ff @(posedge pll_afi_clk)
	begin
		if (state == STATE_RESET_VCALIB_RDDATA_BURST) begin
			// The first read is expected to be all 0, and
			// the second all ones. As a result reset to be opposite
			// to avoid false match on first comparison.
			// Perform the reset as a stage in the sequencer algorithm
			// to reduce recovery failures in HardCopy.
`ifdef NO_BURST_COUNT
			vcalib_rddata_burst[0] <= {AFI_DATA_WIDTH{1'b1}};
			vcalib_rddata_burst[1] <= {AFI_DATA_WIDTH{1'b0}};
`else
			for (int i = 0; i < 2**SEQ_BURST_COUNT_WIDTH; i++)
				vcalib_rddata_burst[i] <= {AFI_DATA_WIDTH{1'b1}};
			for (int i = 0; i < 2**SEQ_BURST_COUNT_WIDTH; i++)
				vcalib_rddata_burst[i+ 2**(SEQ_BURST_COUNT_WIDTH)] <= {AFI_DATA_WIDTH{1'b0}};
`endif
		end
		else
			if (mux_seq_rdata_valid)
				vcalib_rddata_burst[vcalib_rddata_burst_count] <= vcalib_rddata;
	end

	// Capture the mux_seq_rdata based on its burst index
	always_ff @(posedge pll_afi_clk)
	begin
		if (state == STATE_RESET_PHY_SEQ_RDDATA_BURST) 
			// mux_seq_rdata_burst is tested against all 1 so reset to 0
			// Perform the reset as a stage in the sequencer algorithm
			// to reduce recovery failures in HardCopy.
`ifdef NO_BURST_COUNT
			mux_seq_rdata_burst <= {AFI_DATA_WIDTH{1'b0}};
`else
			for (int i = 0; i < 2**SEQ_BURST_COUNT_WIDTH; i++)
				mux_seq_rdata_burst[i] <= {AFI_DATA_WIDTH{1'b0}};
`endif
		else
			if (mux_seq_rdata_valid)
`ifdef NO_BURST_COUNT
				mux_seq_rdata_burst <= mux_seq_rdata_noxz;
`else
				mux_seq_rdata_burst[burst_count] <= mux_seq_rdata_noxz;
`endif
	end

`ifdef DDR2
	// refer to STATE_NOP
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
			nop_count <= {INIT_NOP_COUNT_WIDTH{1'b0}};
		else if (state == STATE_NOP)
			nop_count <= nop_count + 1'b1;
	end

    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
            rp_count <= {RP_COUNT_WIDTH{1'b0}};
        else if (state == STATE_TRP0 || state == STATE_TRP1)
            rp_count <= rp_count + 1'b1;
    end

	// refer to STATE_TMRD0, STATE_TMRD1, STATE_TMRD2
	wire mrd_state;
	assign mrd_state = (state == STATE_TMRD0) || (state == STATE_TMRD1) || (state == STATE_TMRD2) || (state == STATE_TMRD3) || (state == STATE_TMRD4) || (state == STATE_TMRD5);
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
			mrd_count <= {MRD_COUNT_WIDTH{1'b0}};
		else if (mrd_state)
			mrd_count <= mrd_count + 1'b1;
	end

    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
            rfc_count <= {RFC_COUNT_WIDTH{1'b0}};
        else if (state == STATE_TRFC0 || state == STATE_TRFC1)
            rfc_count <= rfc_count + 1'b1;
    end

    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
			oit_count <= {OIT_COUNT_WIDTH{1'b0}};
		else if (state == STATE_TOIT)
			oit_count <= oit_count + 1'b1;
	end
`endif

`ifdef DDR3
	// refer to STATE_MEM_RESET
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			mem_reset_count <= {RESET_COUNT_WIDTH{1'b0}}; 
		else
            if (state == STATE_LOAD_INIT) begin
                // the mem_reset_count can be overwritten by the user during
                // timing simulation so that fast timing simulation can be enabled.
                if (seq_calib_init[0]) begin
                    //synthesis translate_off
                    $display("Disabling memory reset delay of calibration");
                    //synthesis translate_on
                    mem_reset_count <= {{(RESET_COUNT_WIDTH-1){1'b1}},1'b0};
                end
                else
                    mem_reset_count <= {RESET_COUNT_WIDTH{1'b0}};
            end
            else if (state == STATE_MEM_RESET)
                mem_reset_count <= mem_reset_count + 1'b1;
    end 

	// refer to STATE_MEM_CLK_DISABLE
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
		if (~reset_n)
			mem_clk_disable_count <= {CLK_DIS_COUNT_WIDTH{1'b0}};
		else if (state == STATE_MEM_CLK_DISABLE)
			mem_clk_disable_count <= mem_clk_disable_count + 1'b1;
	end

	// refer to STATE_NOP
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
			nop_count <= {INIT_NOP_COUNT_WIDTH{1'b0}};
		else if (state == STATE_NOP)
			nop_count <= nop_count + 1'b1;
	end

	// refer to STATE_TMRD0, STATE_TMRD1, STATE_TMRD2
	wire mrd_state;

	assign mrd_state = (state == STATE_TMRD0) || (state == STATE_TMRD1) || (state == STATE_TMRD2);

    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
			mrd_count <= {MRD_COUNT_WIDTH{1'b0}};
		else if (mrd_state)
			mrd_count <= mrd_count + 1'b1;
	end

    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
            mod_count <= {MOD_COUNT_WIDTH{1'b0}};
        else if (state == STATE_TMOD)
            mod_count <= mod_count + 1'b1;
    end

    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
			zqinit_count <= {ZQINIT_COUNT_WIDTH{1'b0}};
		else if (state == STATE_TZQINIT)
			zqinit_count <= zqinit_count + 1'b1;
	end
`endif

	// refer to STATE_STABLE 
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			mem_stable_count <= {INIT_COUNT_WIDTH{1'b0}};
		else
			if (state == STATE_LOAD_INIT) begin
				// the mem_stable_count can be overwritten by the user during
				// timing simulation so that fast timing simulation can be enabled.
				if (seq_calib_init[0]) begin
					//synthesis translate_off
					$display("Disabling memory stable delay of calibration");
					//synthesis translate_on
					mem_stable_count <= {{(INIT_COUNT_WIDTH-1){1'b1}},1'b0};
				end
				else
					mem_stable_count <= {INIT_COUNT_WIDTH{1'b0}};
            end
			else if (state == STATE_STABLE)
				mem_stable_count <= mem_stable_count + 1'b1;
	end

	// hold reset in the read capture clock domain until memory is stable to ensure the clock returned from memory is clean 
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			seq_reset_mem_stable <= 1'b0;
		else if (state == STATE_WRITE_ZERO)
			seq_reset_mem_stable <= 1'b1;	
	end

`ifdef QDRII
	// hold mem_doff_n LOW after reset. When state reaches STATE_STABLE,
	// at which point the PLL on the FPGA has locked and the clock is stable,
	// we drive mem_doff_n HIGH and wait at least 20us for the DLL on
	// the memory device to lock.
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			seq_mux_doff_n <= {AFI_CONTROL_WIDTH{1'b0}};
		else if (state == STATE_STABLE)
			seq_mux_doff_n <= {AFI_CONTROL_WIDTH{1'b1}};
	end
`endif

`ifdef DDRII_SRAM
	// hold mem_doff_n LOW after reset. When state reaches STATE_STABLE,
	// at which point the PLL on the FPGA has locked and the clock is stable,
	// we drive mem_doff_n HIGH and wait at least 20us for the DLL on
	// the memory device to lock.
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			seq_mux_doff_n <= {AFI_CONTROL_WIDTH{1'b0}};
		else if (state == STATE_STABLE)
			seq_mux_doff_n <= {AFI_CONTROL_WIDTH{1'b1}};
	end
`endif

`ifdef RLDRAMII
	// refer to STATE_MRSC
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
            mrsc_count <= {MRSC_COUNT_WIDTH{1'b0}};
        else if (state == STATE_MRSC)
        	mrsc_count <= mrsc_count + 1'b1;
    end

	// refer to STATE_REFRESH
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
            bank_count <= {MEM_BANK_WIDTH{1'b0}};
        else if (state == STATE_REFRESH)
            bank_count <= bank_count + 1'b1;
    end

	// refer to STATE_NOP
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n) begin
            nop0_count <= {INIT_NOP_COUNT_WIDTH{1'b0}};
            nop1_count <= {INIT_NOP_COUNT_WIDTH{1'b0}};			
        end else begin
            if (state == STATE_LOAD_INIT) begin
                // the nop_count can be overwritten by the user during
                // timing simulation so that fast timing simulation can be enabled.
                if (seq_calib_init[0]) begin
                    //synthesis translate_off
                    $display("Disabling memory NOP delay of calibration");
                    //synthesis translate_on
                    nop0_count <= {{(INIT_NOP_COUNT_WIDTH-1){1'b1}},1'b0};
                    nop1_count <= {{(INIT_NOP_COUNT_WIDTH-1){1'b1}},1'b0};					
                end else begin
                    nop0_count <= {INIT_NOP_COUNT_WIDTH{1'b0}};
                    nop1_count <= {INIT_NOP_COUNT_WIDTH{1'b0}};					
                end
            end	else begin
               if (state == STATE_NOP0)
	               nop0_count <= nop0_count + 1'b1;
               if (state == STATE_NOP1)
	               nop1_count <= nop1_count + 1'b1;
            end
        end
    end
`endif

`ifdef NO_BURST_COUNT // only 1 cycle of valid data 
`else
	// the burst_count is used to keep track of the number of cycles that valid data should be expected
	// In full rate, BL=2, 1 read --> 1 AFI cycle of valid data
	// In full rate, BL=4, 1 read --> 2 AFI cycles of valid data
	// In full rate, BL=8, 1 read --> 3 AFI cycles of valid data
	// In half rate, BL=2, not supported
	// In half rate, BL=4, 1 read --> 1 AFI cycle of valid data
	// In half rate, BL=8, 1 read --> 2 AFI cycles of valid data
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			burst_count <= {SEQ_BURST_COUNT_WIDTH{1'b0}};
		else if (mux_seq_rdata_valid)
			burst_count <= burst_count + 1'b1;
		else 
			burst_count <= {SEQ_BURST_COUNT_WIDTH{1'b0}};
	end 
`endif

	// adjust the valid FIFO pointer offset during valid calibration, i.e. increment the write pointer by 1 full rate cycle every run
	// in a half rate core, it is implemented as alternating between adding 1 full rate cycle and adding 1 half rate cycle
	// refer to read_datapath.v for implementation details
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			add_fr_cycle_to_valid <= 1'b0;
		else
			add_fr_cycle_to_valid <= (state == STATE_V_ADD_HALF_RATE) ? 1'b1 : ((state == STATE_V_ADD_FULL_RATE) ? 1'b0 : add_fr_cycle_to_valid);
	end

	// 1 set of valid calibration signals per DQS group
generate
genvar dqsgroup;

	for (dqsgroup=0; dqsgroup<MEM_READ_DQS_WIDTH; dqsgroup=dqsgroup+1)
	begin: v_calib_control
		// controls for valid FIFO write pointer increment, vcalib_count keeps track of the DQS group
`ifdef MAKE_FIFOS_IN_ALTDQDQS
		assign seq_read_increment_vfifo_fr[dqsgroup] = ((state == STATE_V_ADD_FULL_RATE) || (state == STATE_V_ADD_HALF_RATE)) & (vcalib_count == dqsgroup);
`else
		assign seq_read_increment_vfifo_fr[dqsgroup] = (state == STATE_V_ADD_FULL_RATE) & (vcalib_count == dqsgroup);
`endif
		assign seq_read_increment_vfifo_hr[dqsgroup] = (state == STATE_V_ADD_HALF_RATE) & (vcalib_count == dqsgroup);

		// mux_seq_read_fifo_q is the combined read data from all the read data FIFOs without any reordering
		// the read data of concern is only the one from the FIFO pair (1 per DQS group) currently under calibration
		// mask out the read data (set to 0) from all other groups
		assign vcalib_rddata[(AFI_DQ_GROUP_DATA_WIDTH*(dqsgroup+1)-1) : (AFI_DQ_GROUP_DATA_WIDTH*dqsgroup)] = 
		       mux_seq_read_fifo_q_noxz[(AFI_DQ_GROUP_DATA_WIDTH*(dqsgroup+1)-1) : (AFI_DQ_GROUP_DATA_WIDTH*dqsgroup)] & ({AFI_DQ_GROUP_DATA_WIDTH{(vcalib_count == dqsgroup)}});

		wire  [MEM_DQ_WIDTH-1:0] vcalib_rddata_all_ones_pattern_all_groups;
		wire  [MEM_DQ_WIDTH-1:0] vcalib_rddata_all_zeros_pattern_all_groups;

		if (MEM_DQ_WIDTH % 2 == 0) begin
			assign vcalib_rddata_all_ones_pattern_all_groups  = {MEM_DQ_WIDTH/2{ {(vcalib_count == dqsgroup),1'b0} }};
			assign vcalib_rddata_all_zeros_pattern_all_groups = {MEM_DQ_WIDTH/2{ {1'b0,(vcalib_count == dqsgroup)} }};
		end else begin
			assign vcalib_rddata_all_ones_pattern_all_groups  = {1'b0, {(MEM_DQ_WIDTH-1)/2{ {(vcalib_count == dqsgroup),1'b0} }}};
			assign vcalib_rddata_all_zeros_pattern_all_groups = {1'b1, {(MEM_DQ_WIDTH-1)/2{ {1'b0,(vcalib_count == dqsgroup)} }}};
		end
		
		wire  [MEM_DQ_GROUP_DATA_WIDTH-1:0] vcalib_rddata_all_ones_pattern_one_group;
		wire  [MEM_DQ_GROUP_DATA_WIDTH-1:0] vcalib_rddata_all_zeros_pattern_one_group;
		
		assign vcalib_rddata_all_ones_pattern_one_group  = vcalib_rddata_all_ones_pattern_all_groups [MEM_DQ_GROUP_DATA_WIDTH*(dqsgroup+1)-1 : MEM_DQ_GROUP_DATA_WIDTH*dqsgroup];
		assign vcalib_rddata_all_zeros_pattern_one_group = vcalib_rddata_all_zeros_pattern_all_groups[MEM_DQ_GROUP_DATA_WIDTH*(dqsgroup+1)-1 : MEM_DQ_GROUP_DATA_WIDTH*dqsgroup];

		// set expected data for the group currently under calibration
		assign vcalib_rddata_all_ones_pattern[(AFI_DQ_GROUP_DATA_WIDTH*(dqsgroup+1)-1) : (AFI_DQ_GROUP_DATA_WIDTH*dqsgroup)] = 
			{(AFI_DATA_WIDTH / MEM_DQ_WIDTH){vcalib_rddata_all_ones_pattern_one_group}};

		assign vcalib_rddata_all_zeros_pattern[(AFI_DQ_GROUP_DATA_WIDTH*(dqsgroup+1)-1) : (AFI_DQ_GROUP_DATA_WIDTH*dqsgroup)] = 
			{(AFI_DATA_WIDTH / MEM_DQ_WIDTH){vcalib_rddata_all_zeros_pattern_one_group}};
			
		`ifdef DDRX
		always_ff @(posedge pll_afi_clk or negedge reset_n)
		begin
			if (~reset_n)
				seq_read_fifo_reset[dqsgroup] <= 1'b0;
			else
				seq_read_fifo_reset[dqsgroup] <= (state == STATE_V_READ_FIFO_RESET || state == STATE_V_READ_FIFO_RESET2) & (vcalib_count == dqsgroup);
		end
		`else
		// reset the read and write pointers of the read data synchronization FIFO
		always_ff @(posedge pll_afi_clk or negedge reset_n)
		begin
			if (~reset_n)
				seq_read_fifo_reset[dqsgroup] <= 1'b0;
			else
				seq_read_fifo_reset[dqsgroup] <= ((state == STATE_V_READ_FIFO_RESET || state == STATE_V_READ_FIFO_RESET2) & (vcalib_count == dqsgroup)) || (state == STATE_RESET_READ_FIFO_RESET || state == STATE_RESET_READ_FIFO_RESET2);
		end		
		`endif
	end
endgenerate


	// valid calibration fails when timeout reaches maximum
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			read_valid_timeout_count <= {READ_VALID_TIMEOUT_WIDTH{1'b0}};
		else if (state == STATE_V_CALIB_DONE)
			read_valid_timeout_count <= {READ_VALID_TIMEOUT_WIDTH{1'b0}};
		else if (state == STATE_V_CHECK_READ_FAIL)
			read_valid_timeout_count <= read_valid_timeout_count + 1'b1;
	end


	// counter used to keep track of the number of DQS groups
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			vcalib_count <= {MEM_READ_DQS_WIDTH{1'b0}};
		else if (state == STATE_V_CALIB_DONE)
			vcalib_count <= vcalib_count + 1'b1;
	end




	// Latency Calibration Controls
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
`ifdef HALF_RATE
			seq_read_latency_counter <= {MAX_LATENCY_COUNT_WIDTH{1'b1}} >> 1;
`else
			seq_read_latency_counter <= {MAX_LATENCY_COUNT_WIDTH{1'b1}};
`endif
		else if (state == STATE_L_REDUCE_LATENCY)
			// reduce latency by 1 cycle whenever read is correct
			seq_read_latency_counter <= seq_read_latency_counter - 2'd1; 
		else if (state == STATE_L_ADD_MARGIN)
`ifdef HALF_RATE
			// add 1 AFI cycle for correct data (min latency)
			// add 1 more AFI cycle (i.e. 2 memory clock cycles) for run time uncertainties
			seq_read_latency_counter <= seq_read_latency_counter + 2'd2;	
`else
			// add 1 cycle for correct data (min latency)
			// add 2 more cycles for run time uncertainties
			seq_read_latency_counter <= seq_read_latency_counter + 2'd3;
`endif
	end
	
	
	// Record whether there's at least one passing read test 
	// during LFIFO calibration.
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)	
			lfifo_cal_has_passing_reads <= 1'b0;
		else if (state == STATE_L_REDUCE_LATENCY)
			lfifo_cal_has_passing_reads <= 1'b1;
	end

	// refer to STATE_L_READ_FLUSH, flush every entry of the data FIFO
	always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
		if (~reset_n)
			read_flush_count <= {READ_FIFO_READ_ADDR_WIDTH{1'b0}};
		else if (state == STATE_L_READ_FLUSH)
			read_flush_count <= read_flush_count + 1'b1;
	end


    // write_latency_count is used to control the write latency, refer to the WRITE states 
    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
            write_latency_count <= {MAX_WRITE_LATENCY_COUNT_WIDTH{1'b0}};
        else if ((state == STATE_WAIT_WRITE_ONE) | (state == STATE_WAIT_WRITE_ZERO))
            write_latency_count <= write_latency_count + 1'b1;
    end

`ifdef QDRII_CALIB_CONT_READ
	assign rps_only_states = (state == STATE_WAIT_WRITE_ONE) | (state == STATE_V_WAIT_READ) |
				(state == STATE_V_COMPARE_READ_ZERO_READ_ONE) | (state == STATE_V_CHECK_READ_FAIL) |
				(state == STATE_V_ADD_FULL_RATE) | (state == STATE_V_ADD_HALF_RATE) |
				(state == STATE_V_READ_FIFO_RESET) |
				(state == STATE_V_READ_FIFO_RESET2) |
				(state == STATE_V_CALIB_DONE);
`endif


`ifdef RLDRAMII
	assign mrs_states = (state == STATE_DUMMY_MRS0) | (state == STATE_DUMMY_MRS1) | (state == STATE_MRS_DLL_RESET) | (state == STATE_MRS_DLL_ENABLE);
	assign refresh_states = (state == STATE_REFRESH);

	// -------------------------------------------------------------------------
	// -- Generate MRS configuration bus:
	// --
	// --  Bit             Signal
	// -------------------------------------------------------------------------
	// --   9               ODT
	// --   8               Impdance Matching
	// --   7               DLL Reset
	// --   6               Not used
	// --   5			    Address MUX
	// --  4:3              Burst Length
	// --  2:0              Configuration
	// -------------------------------------------------------------------------    

	// assign the parameter to an integer type before using it to avoid width mismatch warnings
	integer mem_configuration_int = MRS_CONFIGURATION;
	integer mem_burst_length_int = MRS_BURST_LENGTH;
	integer mem_address_mode_int = MRS_ADDRESS_MODE;
	integer mem_dll_reset_int = MRS_DLL_RESET;
	integer mem_imp_matching_int = MRS_IMP_MATCHING;
	integer mem_odt_en_int = MRS_ODT_EN;

	assign mem_configuration = mem_configuration_int[2:0];
	assign mem_burst_length = mem_burst_length_int[1:0];
	assign mem_address_mode = mem_address_mode_int[0];
	assign mem_dll_reset = mem_dll_reset_int[0];
	assign mem_imp_matching = mem_imp_matching_int[0];
	assign mem_odt_en = mem_odt_en_int[0];

	assign mrs_address_dll_reset = {{(MEM_ADDRESS_WIDTH-10){1'b0}}, mem_odt_en, mem_imp_matching, 1'b0, 1'b0, mem_address_mode, mem_burst_length, mem_configuration};
	assign mrs_address_dll_enable = {{(MEM_ADDRESS_WIDTH-10){1'b0}}, mem_odt_en, mem_imp_matching, mem_dll_reset, 1'b0, mem_address_mode, mem_burst_length, mem_configuration};

	// whenever the all 1's pattern needs to be accessed, the address is set to 1
	// when MRS command is issued, the address is set to the mrs_address_xxx according to the table above
	// in all other cases, address is set to 0
	assign seq_address = ((state == STATE_WRITE_ONE) | (state == STATE_L_READ_ONE) | (state == STATE_V_READ_ONE)) ? {{(MEM_ADDRESS_WIDTH-1){1'b0}}, 1'b1} :
						 ((state == STATE_MRS_DLL_RESET) ? mrs_address_dll_reset : 
						 ((state == STATE_MRS_DLL_ENABLE) ? mrs_address_dll_enable : {MEM_ADDRESS_WIDTH{1'b0}})); 

	// whenever the all 1's pattern needs to be accessed, the bank address is set to 1
	// in all other cases, bank address is set to 0
    assign seq_bank = refresh_states ? bank_count : (((state == STATE_WRITE_ONE) | (state == STATE_L_READ_ONE) | (state == STATE_V_READ_ONE)) ? 
					  {{(MEM_BANK_WIDTH-1){1'b0}}, 1'b1} : {MEM_BANK_WIDTH{1'b0}});

	// COMMAND: cs_n, we_n, cas_n
	// WRITE:   0,    0,    1
	// READ:    0,    1,    1
	// MRS:	    0, 	  0,    0
	// REFRESH: 0,    1,    0
	assign seq_cs_n = (write_states[1] | read_states[1] | mrs_states | refresh_states) ? {MEM_CHIP_SELECT_WIDTH{1'b0}} : {MEM_CHIP_SELECT_WIDTH{1'b1}};  
	assign seq_we_n = (write_states[0] | mrs_states) ? {MEM_CONTROL_WIDTH{1'b0}} : {MEM_CONTROL_WIDTH{1'b1}};
	assign seq_cas_n = (mrs_states | refresh_states) ? {MEM_CONTROL_WIDTH{1'b0}}: {MEM_CONTROL_WIDTH{1'b1}};

	`ifdef HALF_RATE
	// back-to-back commands can only be issued in BL=2 mode
	// 1 NOP between commands is required in BL=4 mode
	// 3 NOPs between commands are required in BL=8 mode
	// BL=2 is not supported in half rate; therefore, all commands will be issued on the high channel, the low channel is tied off
	// the only exception is MRS commands, where back-to-back MRS's are required in the initialization sequence
	assign seq_cs_n_l = ((state == STATE_DUMMY_MRS0) | (state == STATE_DUMMY_MRS1) | (state == STATE_MRS_DLL_RESET)) ? {MEM_CHIP_SELECT_WIDTH{1'b0}} : {MEM_CHIP_SELECT_WIDTH{1'b1}};
	assign seq_we_n_l = ((state == STATE_DUMMY_MRS0) | (state == STATE_DUMMY_MRS1) | (state == STATE_MRS_DLL_RESET)) ? {MEM_CONTROL_WIDTH{1'b0}} : {MEM_CONTROL_WIDTH{1'b1}};
	assign seq_cas_n_l = ((state == STATE_DUMMY_MRS0) | (state == STATE_DUMMY_MRS1) | (state == STATE_MRS_DLL_RESET)) ? {MEM_CONTROL_WIDTH{1'b0}} : {MEM_CONTROL_WIDTH{1'b1}};
	assign seq_address_l = {MEM_ADDRESS_WIDTH{1'b0}};
	assign seq_bank_l = {MEM_BANK_WIDTH{1'b0}};
	`endif

`endif

`ifdef QDRII
	`ifdef HALF_RATE
	// in QDRII, the read and write data buses are independent
	// on AFI interface, there are dedicated read (rps_n) and write (wps_n) command channels
	// the controller can issue read and write commands at the same time
	// the PHY issues write commands on the high channel and read commands on the low channel

	// write address/commands on low channel
	// address is set to 1 for writing all 1's pattern, otherwise address is set to 0 
    assign seq_address_l = (state == STATE_WRITE_ONE) ? {{(MEM_ADDRESS_WIDTH-1){1'b0}}, 1'b1} : {MEM_ADDRESS_WIDTH{1'b0}};
	assign seq_wps_n_l = write_states[1] ? 1'b0 : 1'b1;
	assign seq_rps_n_l = 1'b1; // read command is always inactive

	// read address/commands on high channel
	// address is set to 1 when all 1's pattern needs to be read, otherwise address is set to 0
	assign seq_address = ((state == STATE_L_READ_ONE) | (state == STATE_V_READ_ONE)) ? {{(MEM_ADDRESS_WIDTH-1){1'b0}}, 1'b1} : {MEM_ADDRESS_WIDTH{1'b0}}; 
	assign seq_wps_n = 1'b1; // write command is always inactive
`ifdef QDRII_CALIB_CONT_READ
	assign seq_rps_n = (read_states[1] | rps_only_states) ? 1'b0 : 1'b1;  
`else
	assign seq_rps_n = read_states[1] ? 1'b0 : 1'b1;	
`endif

	`else
	// in QDRII, the read and write data buses are independent
	// on AFI interface, there are dedicated read (rps_n) and write (wps_n) command channels
	// the controller is responsible for arbitrating between the read and write command
	// the PHY simply sends the command out

	// set the addres to 1 whenever all 1's pattern needs to be accessed, otherwise address is set to 0
	assign seq_address = ((state == STATE_WRITE_ONE) | (state == STATE_L_READ_ONE) | (state == STATE_V_READ_ONE)) ? {{(MEM_ADDRESS_WIDTH-1){1'b0}}, 1'b1} : {MEM_ADDRESS_WIDTH{1'b0}};
    assign seq_wps_n = write_states[1] ? 1'b0 : 1'b1; 
`ifdef QDRII_CALIB_CONT_READ
	assign seq_rps_n = (read_states[1] | rps_only_states) ? 1'b0 : 1'b1;  
`else
    assign seq_rps_n = read_states[1] ? 1'b0 : 1'b1;  
`endif
	`endif
`endif


`ifdef DDRII_SRAM 
	`ifdef HALF_RATE

	// set the address to 2 whenever all 1's pattern needs to be accessed, otherwise address is set to 0
	assign seq_address_l = ((state == STATE_WRITE_ONE) | (state == STATE_L_READ_ONE) | (state == STATE_V_READ_ONE)) ? {{(MEM_ADDRESS_WIDTH-2){1'b0}}, 2'b10} : {MEM_ADDRESS_WIDTH{1'b0}};
	
	// 1 = read command, 0 = write_command
	assign seq_rw_n_l = write_states[0] ? 1'b0 : 1'b1;

	// set to 0 to load a command
	assign seq_ld_n_l = (write_states[1] | read_states[1]) ? 1'b0 : 1'b1;
	
	assign seq_address = 'b1;
	assign seq_rw_n = 'b1;
	assign seq_ld_n = 'b1;
	
	`else

	// set the address to 2 whenever all 1's pattern needs to be accessed, otherwise address is set to 0
	assign seq_address = ((state == STATE_WRITE_ONE) | (state == STATE_L_READ_ONE) | (state == STATE_V_READ_ONE)) ? {{(MEM_ADDRESS_WIDTH-2){1'b0}}, 2'b10} : {MEM_ADDRESS_WIDTH{1'b0}};
	
	// 1 = read command, 0 = write_command
	assign seq_rw_n = write_states[0] ? 1'b0 : 1'b1;

	// set to 0 to load a command
	assign seq_ld_n = (write_states[1] | read_states[1]) ? 1'b0 : 1'b1;

	`endif
`endif

`ifdef DDR2
	// assign the parameter to an integer type before using it to avoid width mismatch warnings
	integer mem_MR0_BL_int                = MR0_BL;
	integer mem_MR0_BT_int                = MR0_BT;
	integer mem_MR0_CAS_LATENCY_int       = MR0_CAS_LATENCY;
	integer mem_MR0_WR_int                = MR0_WR;
	integer mem_MR0_PD_int                = MR0_PD;
	integer mem_MR1_DLL_int               = MR1_DLL;
	integer mem_MR1_ODS_int               = MR1_ODS;
	integer mem_MR1_RTT_int               = MR1_RTT;
	integer mem_MR1_AL_int                = MR1_AL;
	integer mem_MR1_DQS_int               = MR1_DQS;
	integer mem_MR1_RDQS_int              = MR1_RDQS;
	integer mem_MR1_QOFF_int              = MR1_QOFF;
	integer mem_MR2_SRF_int               = MR2_SRF;
	
	assign mem_MR0_BL = mem_MR0_BL_int[2:0];
	assign mem_MR0_BT = mem_MR0_BT_int[0];
	assign mem_MR0_CAS_LATENCY = mem_MR0_CAS_LATENCY_int[2:0];
	assign mem_MR0_WR = mem_MR0_WR_int[2:0];
	assign mem_MR0_PD = mem_MR0_PD_int[0];
	assign mem_MR1_DLL = mem_MR1_DLL_int[0];
	assign mem_MR1_ODS = mem_MR1_ODS_int[0];
	assign mem_MR1_RTT = mem_MR1_RTT_int[1:0];
	assign mem_MR1_AL = mem_MR1_AL_int[1:0];
	assign mem_MR1_DQS = mem_MR1_DQS_int[0];
	assign mem_MR1_RDQS = mem_MR1_RDQS_int[0];
	assign mem_MR1_QOFF = mem_MR1_QOFF_int[0];
	assign mem_MR2_SRF = mem_MR2_SRF_int[0];

	// Mode Register 0
	assign mr0[2:0] = mem_MR0_BL;
	assign mr0[3] = mem_MR0_BT;
	assign mr0[6:4] = mem_MR0_CAS_LATENCY;
	assign mr0[7] = 1'b0;
	assign mr0[8] = 1'b0;
	assign mr0[11:9] = mem_MR0_WR;
	assign mr0[12] = mem_MR0_PD;
	assign mr0[13] = 1'b0;
	assign mr0[15:14] = 2'b00;
	assign mr0[16] = 1'b0;
	assign mr0_dll_reset = mr0 | 16'b0000000100000000;

	// Mode Register 1
	assign mr1[0] = mem_MR1_DLL;
	assign mr1[1] = mem_MR1_ODS;
	assign mr1[2] = mem_MR1_RTT[0];
	assign mr1[5:3] = mem_MR1_AL;
	assign mr1[6] = mem_MR1_RTT[1];
	assign mr1[9:7] = 3'b0;
	assign mr1[10] = mem_MR1_DQS;
	assign mr1[11] = mem_MR1_RDQS;
	assign mr1[12] = mem_MR1_QOFF;
	assign mr1[13] = 1'b0;
	assign mr1[15:14] = 2'b01;
	assign mr1[16] = 1'b0;
	assign mr1_dll_enable = mr1 & 16'b1111110001111110;
	assign mr1_ocd_cal_default = mr1 | 16'b0000001110000000;
	assign mr1_ocd_cal_exit = mr1 & 16'b1111110001111111;

	// Mode Register 2
	assign mr2[2:0] = 3'b0;
	assign mr2[3] = 1'b0;
	assign mr2[6:4] = 3'b0;
	assign mr2[7] = mem_MR2_SRF;
	assign mr2[13:8] = 6'b0;
	assign mr2[15:14] = 2'b10;
	assign mr2[16] = 1'b0;

	// Mode Register 3
	assign mr3[13:0] = 14'b0;
	assign mr3[15:14] = 2'b11;
	assign mr3[16] = 1'b0;

	assign wr_addr0[11:0] = 12'b0;
	assign wr_addr0[13:12] = 2'b1; 

	assign wr_addr1[11:0] = 12'b1000;
	assign wr_addr1[13:12] = 2'b1;

	assign mrs_states = (state == STATE_EMR2) || (state == STATE_EMR3) || (state == STATE_EMR1_DLL_ENABLE) || (state == STATE_MRS_DLL_RESET) ||
						(state == STATE_MRS) || (state == STATE_EMR1_OCD_CAL_DEFAULT) || (state == STATE_EMR1_OCD_CAL_EXIT);
	assign precharge_states = (state == STATE_PRECHARGE_ALL0) || (state == STATE_PRECHARGE_ALL1) || (state == STATE_BANK_PRECHARGE);
	assign refresh_states = (state == STATE_AUTO_REFRESH0) || (state == STATE_AUTO_REFRESH1);


	assign seq_cke = ~(state == STATE_STABLE);
	assign seq_odt = (state == STATE_ASSERT_ODT) ? 1'b1 : 1'b0;

	assign seq_cs_n  = mrs_states ? 1'b0 : precharge_states ? 1'b0 : refresh_states ? 1'b0 : (state == STATE_BANK_ACTIVATE) ? 1'b0 : write_states[1] ? 1'b0 : read_states[1] ? 1'b0 : 1'b1;
	assign seq_ras_n = mrs_states ? 1'b0 : precharge_states ? 1'b0 : refresh_states ? 1'b0 : (state == STATE_BANK_ACTIVATE) ? 1'b0 : write_states[1] ? 1'b1 : read_states[1] ? 1'b1 : 1'b1;
	assign seq_cas_n = mrs_states ? 1'b0 : precharge_states ? 1'b1 : refresh_states ? 1'b0 : (state == STATE_BANK_ACTIVATE) ? 1'b1 : write_states[1] ? 1'b0 : read_states[1] ? 1'b0 : 1'b1;
	assign seq_we_n  = mrs_states ? 1'b0 : precharge_states ? 1'b0 : refresh_states ? 1'b1 : (state == STATE_BANK_ACTIVATE) ? 1'b1 : write_states[1] ? 1'b0 : read_states[1] ? 1'b1 : 1'b1;

	assign seq_address = (state == STATE_EMR2) ? mr2[13:0] : (state == STATE_EMR3) ? mr3[13:0] : (state == STATE_EMR1_DLL_ENABLE) ? mr1_dll_enable[13:0] :
						 (state == STATE_MRS_DLL_RESET) ? mr0_dll_reset[13:0] : (state == STATE_MRS) ? mr0[13:0] :
						 (state == STATE_EMR1_OCD_CAL_DEFAULT) ? mr1_ocd_cal_default[13:0] : (state == STATE_EMR1_OCD_CAL_EXIT) ? mr1_ocd_cal_exit[13:0] :
						 (state == STATE_WRITE_ZERO || state == STATE_V_READ_ZERO || state == STATE_L_READ_FLUSH) ? wr_addr0 :
						 (state == STATE_WRITE_ONE || state == STATE_V_READ_ONE || state == STATE_L_READ_ONE) ? wr_addr1 :
					 	 (state == STATE_PRECHARGE_ALL0 || state == STATE_PRECHARGE_ALL1) ? {MEM_ADDRESS_WIDTH{1'b1}} : {MEM_ADDRESS_WIDTH{1'b0}};
	assign seq_bank = (state == STATE_EMR2) ? mr2[16:14] : (state == STATE_EMR3) ? mr3[16:14] : (state == STATE_EMR1_DLL_ENABLE) ? mr1_dll_enable[16:14] :
					  (state == STATE_MRS_DLL_RESET) ? mr0_dll_reset[16:14] : (state == STATE_MRS) ? mr0[16:14] :
					  (state == STATE_EMR1_OCD_CAL_DEFAULT) ? mr1_ocd_cal_default[16:14] : (state == STATE_EMR1_OCD_CAL_EXIT) ? mr1_ocd_cal_exit[16:14] :
					  {MEM_BANK_WIDTH{1'b0}};


	wire [MEM_READ_DQS_WIDTH-1:0] seq_vfifo_rd_en_override;	
	assign seq_vfifo_rd_en_override = {MEM_READ_DQS_WIDTH{1'b0}};	

	`ifdef HALF_RATE
	assign seq_cke_l = seq_cke;
	assign seq_cs_n_l = 1'b1;
	assign seq_ras_n_l = 1'b1;
	assign seq_cas_n_l = 1'b1;
	assign seq_we_n_l = 1'b1;
	assign seq_odt_l = 1'b0; 

	assign seq_address_l =  {MEM_ADDRESS_WIDTH{1'b0}};
	assign seq_bank_l = {MEM_BANK_WIDTH{1'b0}};
	`endif
`endif

`ifdef DDR3
	// assign the parameter to an integer type before using it to avoid width mismatch warnings
	integer mem_MR0_BL_int                = MR0_BL;
	integer mem_MR0_BT_int                = MR0_BT;
	integer mem_MR0_CAS_LATENCY_int       = MR0_CAS_LATENCY;
	integer mem_MR0_DLL_int               = MR0_DLL;
	integer mem_MR0_WR_int                = MR0_WR;
	integer mem_MR0_PD_int                = MR0_PD;
	integer mem_MR1_DLL_int               = MR1_DLL;
	integer mem_MR1_ODS_int               = MR1_ODS;
	integer mem_MR1_RTT_int               = MR1_RTT;
	integer mem_MR1_AL_int                = MR1_AL;
	integer mem_MR1_WL_int                = MR1_WL;
	integer mem_MR1_TDQS_int              = MR1_TDQS;
	integer mem_MR1_QOFF_int              = MR1_QOFF;
	integer mem_MR2_CWL_int               = MR2_CWL;
	integer mem_MR2_ASR_int               = MR2_ASR;
	integer mem_MR2_SRT_int               = MR2_SRT;
	integer mem_MR2_RTT_WR_int            = MR2_RTT_WR;
	integer mem_MR3_MPR_RF_int            = MR3_MPR_RF;
	integer mem_MR3_MPR_int               = MR3_MPR;
	
	assign mem_MR0_BL = mem_MR0_BL_int[1:0];
	assign mem_MR0_BT = mem_MR0_BT_int[0];
	assign mem_MR0_CAS_LATENCY = mem_MR0_CAS_LATENCY_int[2:0];
	assign mem_MR0_DLL = mem_MR0_DLL_int[0];
	assign mem_MR0_WR = mem_MR0_WR_int[2:0];
	assign mem_MR0_PD = mem_MR0_PD_int[0];
	assign mem_MR1_DLL = mem_MR1_DLL_int[0];
	assign mem_MR1_ODS = mem_MR1_ODS_int[1:0];
	assign mem_MR1_RTT = mem_MR1_RTT_int[2:0];
	assign mem_MR1_AL = mem_MR1_AL_int[1:0];
	assign mem_MR1_WL = mem_MR1_WL_int[0];
	assign mem_MR1_TDQS = mem_MR1_TDQS_int[0];
	assign mem_MR1_QOFF = mem_MR1_QOFF_int[0];
	assign mem_MR2_CWL = mem_MR2_CWL_int[2:0];
	assign mem_MR2_ASR = mem_MR2_ASR_int[0];
	assign mem_MR2_SRT = mem_MR2_SRT_int[0];
	assign mem_MR2_RTT_WR = mem_MR2_RTT_WR_int[1:0];
	assign mem_MR3_MPR_RF = mem_MR3_MPR_RF_int[1:0];
	assign mem_MR3_MPR = mem_MR3_MPR_int[0];


	// Mode Register 0
	assign mr0[1:0] = mem_MR0_BL;
	assign mr0[2] = 1'b0;
	assign mr0[3] = mem_MR0_BT;
	assign mr0[6:4] = mem_MR0_CAS_LATENCY;
	assign mr0[7] = 1'b0;
	assign mr0[8] = mem_MR0_DLL;
	assign mr0[11:9] = mem_MR0_WR;
	assign mr0[12] = mem_MR0_PD;
	assign mr0[13] = 1'b0;
	assign mr0[15:14] = 2'b00;
	assign mr0[16] = 1'b0; 

	// Mode Register 1
	assign mr1[0] = mem_MR1_DLL;
	assign mr1[1] = mem_MR1_ODS[0];
	assign mr1[2] = mem_MR1_RTT[0];
	assign mr1[4:3] = mem_MR1_AL;
	assign mr1[5] = mem_MR1_ODS[1];
	assign mr1[6] = mem_MR1_RTT[1];
	assign mr1[7] = mem_MR1_WL;
	assign mr1[8] = 1'b0;
	assign mr1[9] = mem_MR1_RTT[2];
	assign mr1[10] = 1'b0;
	assign mr1[11] = mem_MR1_TDQS;
	assign mr1[12] = mem_MR1_QOFF;
	assign mr1[13] = 1'b0;
	assign mr1[15:14] = 2'b01;
	assign mr1[16] = 1'b0;

	// Mode Register 2
	assign mr2[0] = 1'b0;
	assign mr2[1] = 1'b0;
	assign mr2[2] = 1'b0;
	assign mr2[5:3] = mem_MR2_CWL; 
	assign mr2[6] = mem_MR2_ASR;
	assign mr2[7] = mem_MR2_SRT;
	assign mr2[8] = 1'b0;
	assign mr2[10:9] = mem_MR2_RTT_WR;
	assign mr2[11] = 1'b0;
	assign mr2[12] = 1'b0;
	assign mr2[13] = 1'b0;
	assign mr2[15:14] = 2'b10;
	assign mr2[16] = 1'b0;

	// Mode Register 3
	assign mr3[1:0] = mem_MR3_MPR_RF;
	assign mr3[2] = mem_MR3_MPR;
	assign mr3[13:3] = 11'b0;
	assign mr3[15:14] = 2'b11;
	assign mr3[16] = 1'b0;

	assign zqcl[9:0] = 10'b0;
	assign zqcl[10] = 1'b1;
	assign zqcl[13:11] = 3'b0;

	assign wr_addr0[11:0] = 12'b0;
	assign wr_addr0[13:12] = 2'b1; 

	assign wr_addr1[11:0] = 12'b1000;
	assign wr_addr1[13:12] = 2'b1;

	assign mrs_states = (state == STATE_MR0) || (state == STATE_MR1) || (state == STATE_MR2) || (state == STATE_MR3);

	assign seq_reset_n = ~(state == STATE_MEM_RESET || state == STATE_MEM_CLK_DISABLE);
	assign seq_cke = ~(state == STATE_MEM_CLK_DISABLE || state == STATE_MEM_RESET_RELEASE || state == STATE_STABLE);
	assign seq_odt = (state == STATE_ASSERT_ODT) ? 1'b1 : 1'b0;

	assign seq_cs_n  = mrs_states ? 1'b0 : (state == STATE_ZQCL) ? 1'b0 : (state == STATE_BANK_ACTIVATE) ? 1'b0 : write_states[1] ? 1'b0 : read_states[1] ? 1'b0 : (state == STATE_BANK_PRECHARGE) ? 1'b0 : 1'b1;
	assign seq_ras_n = mrs_states ? 1'b0 : (state == STATE_ZQCL) ? 1'b1 : (state == STATE_BANK_ACTIVATE) ? 1'b0 : write_states[1] ? 1'b1 : read_states[1] ? 1'b1 : (state == STATE_BANK_PRECHARGE) ? 1'b0 : 1'b1;
	assign seq_cas_n = mrs_states ? 1'b0 : (state == STATE_ZQCL) ? 1'b1 : (state == STATE_BANK_ACTIVATE) ? 1'b1 : write_states[1] ? 1'b0 : read_states[1] ? 1'b0 : (state == STATE_BANK_PRECHARGE) ? 1'b1 : 1'b1;
	assign seq_we_n  = mrs_states ? 1'b0 : (state == STATE_ZQCL) ? 1'b0 : (state == STATE_BANK_ACTIVATE) ? 1'b1 : write_states[1] ? 1'b0 : read_states[1] ? 1'b1 : (state == STATE_BANK_PRECHARGE) ? 1'b0 : 1'b1;

	assign seq_address = (state == STATE_MR0) ? mr0[13:0] : (state == STATE_MR1) ? mr1[13:0] : (state == STATE_MR2) ? mr2[13:0] : 
						 (state == STATE_MR3) ? mr3[13:0] : (state == STATE_ZQCL) ? zqcl : 
						 (state == STATE_WRITE_ZERO || state == STATE_V_READ_ZERO || state == STATE_L_READ_FLUSH) ? wr_addr0 :
						 (state == STATE_WRITE_ONE || state == STATE_V_READ_ONE || state == STATE_L_READ_ONE) ? wr_addr1 : {MEM_ADDRESS_WIDTH{1'b0}};
	assign seq_bank = (state == STATE_MR0) ? mr0[16:14] : (state == STATE_MR1) ? mr1[16:14] : (state == STATE_MR2) ? mr2[16:14] :
					  (state == STATE_MR3) ? mr3[16:14] : {MEM_BANK_WIDTH{1'b0}};


	wire [MEM_READ_DQS_WIDTH-1:0] seq_vfifo_rd_en_override;	
	assign seq_vfifo_rd_en_override = {MEM_READ_DQS_WIDTH{1'b0}};	

	`ifdef HALF_RATE
	assign seq_reset_n_l = seq_reset_n;
	assign seq_cke_l = seq_cke;
	assign seq_cs_n_l = 1'b1;
	assign seq_ras_n_l = 1'b1;
	assign seq_cas_n_l = 1'b1;
	assign seq_we_n_l = 1'b1;
	assign seq_odt_l = 1'b0; 

	assign seq_address_l =  {MEM_ADDRESS_WIDTH{1'b0}};
	assign seq_bank_l = {MEM_BANK_WIDTH{1'b0}};
	`endif
`endif

	// Generate the write data patterns
	generate
		if (MEM_DQ_WIDTH % 2 == 0) begin
			assign seq_wrdata_all_ones_pattern = {MEM_DQ_WIDTH/2{2'b10}};
			assign seq_wrdata_all_zeros_pattern = {MEM_DQ_WIDTH/2{2'b01}};
		end else begin
			assign seq_wrdata_all_ones_pattern = {1'b0, {(MEM_DQ_WIDTH-1)/2{2'b10}}};
			assign seq_wrdata_all_zeros_pattern = {1'b1, {(MEM_DQ_WIDTH-1)/2{2'b01}}};
		end
	endgenerate

`ifdef RLDRAMII 
	// set the write data 1 cycle after the write command is issued (write latency is always more than 2 cycles)
	assign seq_wrdata = (state == STATE_WAIT_WRITE_ZERO) ? seq_wrdata_all_zeros_pattern : seq_wrdata_all_ones_pattern;
`endif
`ifdef QDRII
	// the write latency is always just 1 cycle
	// set the write data in the same cycle as the command issue and keep the write data until the write state is completed
	// to ensure that the memory can capture the full burst of data
	assign seq_wrdata = ((state == STATE_WRITE_ZERO) || (state == STATE_WAIT_WRITE_ZERO)) ? seq_wrdata_all_zeros_pattern : seq_wrdata_all_ones_pattern;

	// QDRII is unidirectional, output buffer is always enabled during calibration
	assign seq_wrdata_en = {AFI_DQS_WIDTH{1'b1}};
`endif
`ifdef DDRII_SRAM 
	// the write latency is always just 1 cycle
	// set the write data in the same cycle as the command issue and keep the write data until the write state is completed
	// to ensure that the memory can capture the full burst of data
	assign seq_wrdata = ((state == STATE_WRITE_ZERO) || (state == STATE_WAIT_WRITE_ZERO)) ? seq_wrdata_all_zeros_pattern : seq_wrdata_all_ones_pattern;
`endif
`ifdef DDRX
	// set the write data 1 cycle after the write command is issued (write latency is always more than 2 cycles)
	assign seq_wrdata = (state == STATE_WAIT_WRITE_ZERO) ? seq_wrdata_all_zeros_pattern : seq_wrdata_all_ones_pattern;

	// start running DQS right after write command is issued (exact preamble is not neccessary for calibration writes)
	assign seq_dqs_en = (state == STATE_WRITE_ZERO) || (state == STATE_WAIT_WRITE_ZERO) ||
						(state == STATE_WRITE_ONE)  || (state == STATE_WAIT_WRITE_ONE);
`endif

	// data mask is not used during calibration
	assign seq_wrdata_mask = {AFI_DATA_MASK_WIDTH{1'b0}};

	// this signal is used in the read datapath to start the read latency counter
	// refer to latency shifter in read_datapath.v
	// seq_rddata_en needs to be high for x cycles, where x is the number of cycles that valid data is expected
	// In full rate, BL=2, 1 read --> 1 AFI cycle of valid data
	// In full rate, BL=4, 1 read --> 2 AFI cycles of valid data
	// In full rate, BL=8, 1 read --> 4 AFI cycles of valid data
	// In half rate, BL=2, not supported
	// In half rate, BL=4, 1 read --> 1 AFI cycle of valid data
	// In half rate, BL=8, 1 read --> 2 AFI cycles of valid data             

`ifdef NO_BURST_COUNT	// only 1 cycle of valid data 
	assign seq_rddata_en = read_states[0] ? 1'b1 : 1'b0;

`else
// assert the seq_rddata_en when in a read state
reg	rddata_en_r;
wire rddata_en;

	assign rddata_en = read_states[0] ? 1'b1 : 1'b0; 

	// this flop stage extends seq_rddata_en for 1 more cycle
    always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			rddata_en_r <= 1'b0;
		else
			rddata_en_r <= rddata_en;
	end		


`ifdef FULL_RATE
	`ifdef BURST8
	// this pipeline extends seq_rddata_en for another 2 cycles, for a total of 4 cycles for full rate, BL=8
	reg [SEQ_BURST_COUNT_WIDTH-1:0] rddata_en_pipe;

    always_ff @(posedge pll_afi_clk or negedge reset_n)
    begin
        if (~reset_n)
            rddata_en_pipe <= {SEQ_BURST_COUNT_WIDTH{1'b0}};
        else
            rddata_en_pipe <= {rddata_en_pipe[SEQ_BURST_COUNT_WIDTH-2:0], rddata_en_r};
    end

	// "OR" all the flop outputs together with rddata_en to generate the exteneded seq_rddata_en signal
	assign seq_rddata_en = (|rddata_en_pipe) | rddata_en_r | rddata_en;
	`else	
	// "OR" the flop output together with rddata_en to generate the exteneded seq_rddata_en signal
	assign seq_rddata_en = rddata_en_r | rddata_en;
	`endif 
`else 
	// "OR" the flop output together with rddata_en to generate the exteneded seq_rddata_en signal
	assign seq_rddata_en = rddata_en_r | rddata_en;
`endif

`endif	


	// a set of muxes between the sequencer AFI signals and the controller AFI signals
	// during calibration, mux_sel = 1, sequencer AFI signals are selected
	// after calibration is successful, mux_sel = 0, controller AFI signals are selected 


	reg mux_sel /* synthesis dont_merge */;
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			mux_sel <= 1'b1;
		else
			mux_sel <= ~(state == STATE_CALIB_DONE); 
	end


`ifdef HALF_RATE
	// in half rate, the width of AFI interface is double the width of memory interface
	assign seq_mux_address = {seq_address, seq_address_l};
	`ifdef RLDRAMII
	assign seq_mux_bank = {seq_bank, seq_bank_l};
	assign seq_mux_cas_n = {seq_cas_n, seq_cas_n_l};
	assign seq_mux_cs_n = {seq_cs_n, seq_cs_n_l};
	assign seq_mux_we_n = {seq_we_n, seq_we_n_l};
	`endif
	`ifdef QDRII
	assign seq_mux_wps_n = {seq_wps_n, seq_wps_n_l}; 
	assign seq_mux_rps_n = {seq_rps_n, seq_rps_n_l}; 
	`endif
	`ifdef DDRII_SRAM
	assign seq_mux_ld_n = {seq_ld_n, seq_ld_n_l}; 
	assign seq_mux_rw_n = {seq_rw_n, seq_rw_n_l}; 
	`endif
	`ifdef DDRX
    assign seq_mux_bank = {seq_bank, seq_bank_l};
    assign seq_mux_cs_n = {seq_cs_n, seq_cs_n_l};
    assign seq_mux_cke = {seq_cke, seq_cke_l};
    assign seq_mux_odt = {seq_odt, seq_odt_l};
    assign seq_mux_ras_n = {seq_ras_n, seq_ras_n_l};
    assign seq_mux_cas_n = {seq_cas_n, seq_cas_n_l};
    assign seq_mux_we_n = {seq_we_n, seq_we_n_l};
    `ifdef DDR3
    assign seq_mux_reset_n = {seq_reset_n, seq_reset_n_l};
	`endif
	`endif

	assign seq_mux_wdata = {seq_wrdata, seq_wrdata, seq_wrdata, seq_wrdata}; // AFI data is 4x wide
	assign seq_mux_wdata_valid = seq_wrdata_en;
	`ifdef DDRX
	assign seq_mux_dqs_en = {AFI_DQS_WIDTH{seq_dqs_en}};
	`endif
`else
	// in full rate, the width of AFI interface is the same as the width of memory interface
	`ifdef RLDRAMII
    assign seq_mux_address = seq_address;
	assign seq_mux_bank = seq_bank;
	assign seq_mux_cas_n = seq_cas_n;
	assign seq_mux_cs_n = seq_cs_n;
	assign seq_mux_we_n = seq_we_n;
	`endif
	`ifdef QDRII
	`ifdef BURST2
	// In QDRII, burst of 2, address is double data rate
	// commands are single data rate, read and write commands are issued at the same time on a per 1 full cycle basis	
    assign seq_mux_address = {seq_address, seq_address};
	assign seq_mux_wps_n = {1'b1, seq_wps_n}; 
	assign seq_mux_rps_n = {1'b1, seq_rps_n}; 
	`else
    assign seq_mux_address = seq_address;
	assign seq_mux_wps_n = seq_wps_n; 
	assign seq_mux_rps_n = seq_rps_n; 
	`endif
	`endif
	`ifdef DDRII_SRAM
	assign seq_mux_address = seq_address;
	assign seq_mux_ld_n = seq_ld_n;
	assign seq_mux_rw_n = seq_rw_n;
	`endif	
	`ifdef DDRX
    assign seq_mux_bank = seq_bank;
    assign seq_mux_cs_n = seq_cs_n;
    assign seq_mux_cke = seq_cke;
    assign seq_mux_odt = seq_odt;
    assign seq_mux_ras_n = seq_ras_n;
    assign seq_mux_cas_n = seq_cas_n;
    assign seq_mux_we_n = seq_we_n;
	`ifdef DDR3
    assign seq_mux_reset_n = seq_reset_n;
    `endif
	`endif


	assign seq_mux_wdata = {seq_wrdata, seq_wrdata}; // AFI data is 2x wide
	assign seq_mux_wdata_valid = seq_wrdata_en;
	`ifdef DDRX
	assign seq_mux_dqs_en = {AFI_DQS_WIDTH{seq_dqs_en}};
	`endif
`endif

	assign seq_mux_dm = seq_wrdata_mask;

	`ifdef DDRX
	assign seq_mux_vfifo_rd_en_override = seq_vfifo_rd_en_override;
	`endif
	assign seq_mux_rdata_en = {AFI_R_RATIO{seq_rddata_en}};

	reg [3:0] afi_cal_success_pipe;
	always_ff @(posedge pll_afi_clk or negedge reset_n)
	begin
		if (~reset_n)
			afi_cal_success_pipe <= 4'b0;
		else
			afi_cal_success_pipe <= {(state == STATE_CALIB_DONE), afi_cal_success_pipe[3:1]};
	end

	assign afi_cal_success = afi_cal_success_pipe[0];
	assign afi_cal_fail = (state == STATE_CALIB_FAIL);
	
	assign seq_read_increment_vfifo_qr = {MEM_READ_DQS_WIDTH{1'b0}};

endmodule
