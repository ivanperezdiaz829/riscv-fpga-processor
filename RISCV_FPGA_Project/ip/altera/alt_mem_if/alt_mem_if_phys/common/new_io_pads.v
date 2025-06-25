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

// altera message_off 10036
module new_io_pads(
	reset_n_addr_cmd_clk,
	reset_n_afi_clk,
	phy_reset_mem_stable,
`ifdef QUARTER_RATE	
	reset_n_hr_clk,
`endif
`ifdef ARRIAIIGX
	oct_ctl_value,
`else	
	oct_ctl_rs_value,
	oct_ctl_rt_value,
`endif
	phy_ddio_addr_cmd_clk,
	phy_ddio_address,
`ifdef RLDRAMX
	phy_ddio_bank,
	phy_ddio_cs_n,
	phy_ddio_we_n,
	phy_ddio_ref_n,
 `ifdef RLDRAM3
	phy_ddio_reset_n,
 `endif
	phy_mem_address,
	phy_mem_bank,
	phy_mem_cs_n,
	phy_mem_we_n,
	phy_mem_ref_n,
 `ifdef RLDRAM3
	phy_mem_reset_n,
 `endif
`endif
`ifdef QDRII
	phy_ddio_wps_n,
	phy_ddio_rps_n,
	phy_ddio_doff_n,
	phy_mem_address,
	phy_mem_wps_n,
	phy_mem_rps_n,
	phy_mem_doff_n,

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
	phy_ddio_ld_n,
	phy_ddio_rw_n,
	phy_ddio_doff_n,
	phy_mem_address,
	phy_mem_ld_n,
	phy_mem_rw_n,
	phy_mem_zq,
	phy_mem_doff_n,
`endif
`ifdef DDRX
	phy_ddio_bank,
	phy_ddio_cs_n,
	phy_ddio_cke,
`ifndef LPDDR1
	phy_ddio_odt,
`endif
	phy_ddio_we_n,
	phy_ddio_ras_n,
	phy_ddio_cas_n,
`ifdef AC_PARITY
	phy_ddio_ac_par,
`endif
`ifdef DDR3
	phy_ddio_reset_n,
`endif
	phy_mem_address,
	phy_mem_bank,
	phy_mem_cs_n,
	phy_mem_cke,
	phy_mem_odt,
	phy_mem_we_n,
	phy_mem_ras_n,
	phy_mem_cas_n,
`ifdef AC_PARITY
	phy_ac_parity,
	phy_err_out_n,
	phy_parity_error_n,
`endif
`ifdef DDR3
	phy_mem_reset_n,
`endif
`endif
`ifdef LPDDR2
	phy_ddio_cs_n,
	phy_ddio_cke,
	phy_mem_address,
	phy_mem_cs_n,
	phy_mem_cke,
`endif
	pll_afi_clk,
`ifdef QUARTER_RATE
	pll_hr_clk,
`endif
	pll_mem_clk,
	pll_write_clk,
`ifdef CORE_PERIPHERY_DUAL_CLOCK
	pll_c2p_write_clk,
`endif
`ifdef USE_DR_CLK
	pll_dr_clk,
`endif
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	pll_mem_phy_clk,
	pll_afi_phy_clk,
`endif
`ifdef DDRX_LPDDRX
	pll_dqs_ena_clk,
`endif
	phy_ddio_dq,
`ifdef DDRX_LPDDRX
	phy_ddio_dqs_en,
	phy_ddio_oct_ena,
	dqs_enable_ctrl,
`endif
`ifdef RLDRAMX
	phy_ddio_oct_ena,
`endif
	phy_ddio_wrdata_en,
	phy_ddio_wrdata_mask,
`ifdef RLDRAMX
	phy_mem_dq,
 `ifdef MEM_IF_DM_PINS_EN	
	phy_mem_dm,
 `endif
	phy_mem_dk,
	phy_mem_dk_n,
	phy_mem_ck,
	phy_mem_ck_n,
`endif
`ifdef QDRII
	phy_mem_d,
	phy_mem_bws_n,
	phy_mem_k,
	phy_mem_k_n,
`endif
`ifdef DDRII_SRAM
	phy_mem_dq,
	phy_mem_bws_n,
	phy_mem_k,
	phy_mem_k_n,
	phy_mem_c,
	phy_mem_c_n,
`endif
`ifdef DDRX_LPDDRX
	phy_mem_dq,
`ifdef MEM_IF_DM_PINS_EN
	phy_mem_dm,
`endif
	phy_mem_ck,
	phy_mem_ck_n,
	mem_dqs,
`ifdef MEM_IF_DQSN_EN
	mem_dqs_n,
`endif
`endif
	dll_phy_delayctrl,
`ifdef HCX_COMPAT_MODE
	hc_dll_config_dll_offset_ctrl_offsetctrlout,
	hc_dll_config_dll_offset_ctrl_b_offsetctrlout,
`endif		
`ifdef RLDRAMX
	mem_phy_qk,
	mem_phy_qk_n,
`endif
`ifdef QDRII
	mem_phy_cq,
	mem_phy_cq_n,
	mem_phy_q,
`endif
`ifdef DDRII_SRAM
	mem_phy_cq,
	mem_phy_cq_n,
`endif
	ddio_phy_dq,
	read_capture_clk, 
	scc_clk,
	scc_data,
	scc_dqs_ena,
	scc_dqs_io_ena,
	scc_dq_ena,
`ifdef MEM_IF_DM_PINS_EN
	scc_dm_ena,
`endif
	scc_sr_dqsenable_delayctrl,
	scc_sr_dqsdisablen_delayctrl,
	scc_sr_multirank_delayctrl,
	scc_upd,
`ifdef MAKE_FIFOS_IN_ALTDQDQS
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
	seq_read_latency_counter,
	seq_read_increment_vfifo_fr,
	seq_read_increment_vfifo_hr,
	seq_read_fifo_reset,
`endif
`ifdef USE_SHADOW_REGS
	phy_ddio_read_rank,
	phy_ddio_write_rank,
	scc_reset_n,
`endif
    enable_mem_clk,
	capture_strobe_tracking
);


parameter DEVICE_FAMILY = "";
parameter REGISTER_C2P = "";
parameter LDC_MEM_CK_CPS_PHASE = "";

`ifdef ARRIAIIGX
parameter OCT_TERM_CONTROL_WIDTH = ""; 
`else
parameter OCT_SERIES_TERM_CONTROL_WIDTH = "";  
parameter OCT_PARALLEL_TERM_CONTROL_WIDTH = ""; 
`endif
parameter MEM_ADDRESS_WIDTH     = ""; 
`ifdef RLDRAMX
parameter MEM_BANK_WIDTH        = ""; 
parameter MEM_CHIP_SELECT_WIDTH = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter MEM_BANK_WIDTH        = ""; 
parameter MEM_CHIP_SELECT_WIDTH = ""; 
parameter MEM_CLK_EN_WIDTH 		= ""; 
parameter MEM_CK_WIDTH 			= ""; 
parameter MEM_ODT_WIDTH 		= ""; 
parameter MEM_DQS_WIDTH			= "";
`else
localparam MEM_CK_WIDTH 			= 1; 
`endif
parameter MEM_DM_WIDTH          = ""; 
parameter MEM_CONTROL_WIDTH     = ""; 
parameter MEM_DQ_WIDTH          = ""; 
parameter MEM_READ_DQS_WIDTH    = ""; 
parameter MEM_WRITE_DQS_WIDTH   = ""; 

parameter AFI_ADDRESS_WIDTH         = ""; 
`ifdef RLDRAMX
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
parameter AFI_CLK_EN_WIDTH 			= ""; 
parameter AFI_ODT_WIDTH 			= ""; 
`endif
parameter AFI_DATA_MASK_WIDTH       = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 
parameter AFI_DATA_WIDTH            = ""; 
parameter AFI_DQS_WIDTH             = ""; 
parameter AFI_RATE_RATIO            = ""; 

parameter DLL_DELAY_CTRL_WIDTH  = "";

parameter SCC_DATA_WIDTH        = "";

`ifdef DDRX_LPDDRX
parameter DQS_ENABLE_CTRL_WIDTH = "";
parameter ALTDQDQS_INPUT_FREQ = "";
parameter ALTDQDQS_DELAY_CHAIN_BUFFER_MODE = "";
parameter ALTDQDQS_DQS_PHASE_SETTING = "";
parameter ALTDQDQS_DQS_PHASE_SHIFT = "";
parameter ALTDQDQS_DELAYED_CLOCK_PHASE_SETTING = "";
`endif

parameter FAST_SIM_MODEL            = "";

`ifdef MAKE_FIFOS_IN_ALTDQDQS
parameter EXTRA_VFIFO_SHIFT = 0;
`endif

parameter IS_HHP_HPS = "";

localparam DOUBLE_MEM_DQ_WIDTH = MEM_DQ_WIDTH * 2;
localparam HALF_AFI_DATA_WIDTH = AFI_DATA_WIDTH / 2;
localparam HALF_AFI_DQS_WIDTH = AFI_DQS_WIDTH / 2;



input	reset_n_afi_clk;
input	reset_n_addr_cmd_clk;
input   phy_reset_mem_stable;

`ifdef ARRIAIIGX
input   [OCT_TERM_CONTROL_WIDTH-1:0] oct_ctl_value;
`else
input   [OCT_SERIES_TERM_CONTROL_WIDTH-1:0] oct_ctl_rs_value;
input   [OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] oct_ctl_rt_value;
`endif

input	phy_ddio_addr_cmd_clk;
input	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;
`ifdef RLDRAMX
input	[AFI_BANK_WIDTH-1:0]	phy_ddio_bank;
input	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_we_n;
input	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_ref_n;
 `ifdef RLDRAM3
input	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_reset_n;
 `endif

output	[MEM_ADDRESS_WIDTH-1:0]	phy_mem_address;
output	[MEM_BANK_WIDTH-1:0]	phy_mem_bank;
output	[MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output	[MEM_CONTROL_WIDTH-1:0]	phy_mem_we_n;
output	[MEM_CONTROL_WIDTH-1:0]	phy_mem_ref_n;
 `ifdef RLDRAM3
output	[MEM_CONTROL_WIDTH-1:0]	phy_mem_reset_n; 
 `endif
`endif
`ifdef QDRII
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_wps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_rps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_doff_n;

`ifdef RTL_CALIB
`ifdef STRATIXV
`ifndef NIOS_SEQUENCER
input	mem_config_clk; 
input	mem_config_datain; 
input [0:0] mem_config_update; 

input	[MEM_READ_DQS_WIDTH - 1:0] mem_config_cqdqs_ena; 
input	[MEM_READ_DQS_WIDTH - 1:0] mem_config_cq_io_ena; 
input	[MEM_DQ_WIDTH - 1:0] mem_config_rio_ena; 

input	[MEM_WRITE_DQS_WIDTH - 1:0] mem_config_kdqs_ena; 
input	[MEM_WRITE_DQS_WIDTH - 1:0] mem_config_k_io_ena; 
input	[MEM_DQ_WIDTH - 1:0] mem_config_wio_ena; 
input	[MEM_DM_WIDTH - 1:0] mem_config_dm_ena; 
input   [DLL_DELAY_CTRL_WIDTH-1:0]  dll_offsetdelay_in ;
`endif
`endif
`endif

`endif
`ifdef DDRII_SRAM
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ld_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rw_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_ld_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_rw_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_zq;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_doff_n;
`endif
`ifdef DDRX
input	[AFI_BANK_WIDTH-1:0]    phy_ddio_bank;
input	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input	[AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;
	`ifndef LPDDR1
input	[AFI_ODT_WIDTH-1:0] phy_ddio_odt;
	`endif
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ras_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_cas_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_we_n;
	`ifdef AC_PARITY
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ac_par;
	`endif
	`ifdef DDR3
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_reset_n;
	`endif

output  [MEM_ADDRESS_WIDTH-1:0]	phy_mem_address;
output	[MEM_BANK_WIDTH-1:0]	phy_mem_bank;
output	[MEM_CHIP_SELECT_WIDTH-1:0]	phy_mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0]	phy_mem_cke;
output  [MEM_ODT_WIDTH-1:0]	phy_mem_odt;
output	[MEM_CONTROL_WIDTH-1:0]	phy_mem_we_n;
output	[MEM_CONTROL_WIDTH-1:0] phy_mem_ras_n;
output	[MEM_CONTROL_WIDTH-1:0] phy_mem_cas_n;
	`ifdef AC_PARITY
output	[MEM_CONTROL_WIDTH-1:0] phy_ac_parity;
input		[MEM_CONTROL_WIDTH-1:0] phy_err_out_n;
output	phy_parity_error_n;
	`endif
	`ifdef DDR3
output	phy_mem_reset_n;
	`endif
`endif
`ifdef LPDDR2
input	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input	[AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;

output  [MEM_ADDRESS_WIDTH-1:0]	phy_mem_address;
output	[MEM_CHIP_SELECT_WIDTH-1:0]	phy_mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0]	phy_mem_cke;
`endif

input	pll_afi_clk;
input	pll_mem_clk;
input	pll_write_clk;
`ifdef CORE_PERIPHERY_DUAL_CLOCK
input	pll_c2p_write_clk;
`endif
`ifdef USE_DR_CLK
input	pll_dr_clk;
`endif
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
input pll_mem_phy_clk;
input pll_afi_phy_clk;
`endif
`ifdef QUARTER_RATE
input	pll_hr_clk;
input	reset_n_hr_clk;
`endif
`ifdef DDRX_LPDDRX
input	pll_dqs_ena_clk;
`endif
input	[AFI_DATA_WIDTH-1:0]  phy_ddio_dq;
`ifdef DDRX_LPDDRX
input	[AFI_DQS_WIDTH-1:0] phy_ddio_dqs_en;
input	[AFI_DQS_WIDTH-1:0] phy_ddio_oct_ena;
input	[DQS_ENABLE_CTRL_WIDTH-1:0] dqs_enable_ctrl;
`endif
`ifdef RLDRAMX
input	[AFI_DQS_WIDTH-1:0] phy_ddio_oct_ena;
`endif
input	[AFI_DQS_WIDTH-1:0] phy_ddio_wrdata_en;
input	[AFI_DATA_MASK_WIDTH-1:0]	phy_ddio_wrdata_mask;	

`ifdef RLDRAMX
inout	[MEM_DQ_WIDTH-1:0] phy_mem_dq;
 `ifdef MEM_IF_DM_PINS_EN
output	[MEM_DM_WIDTH-1:0]	phy_mem_dm;
 `endif
output	[MEM_WRITE_DQS_WIDTH-1:0] phy_mem_dk;
output	[MEM_WRITE_DQS_WIDTH-1:0] phy_mem_dk_n;
output	phy_mem_ck;
output	phy_mem_ck_n;
`endif
`ifdef QDRII
output  [MEM_DQ_WIDTH-1:0] phy_mem_d;
output  [MEM_DM_WIDTH-1:0] phy_mem_bws_n;
output  [MEM_WRITE_DQS_WIDTH-1:0] phy_mem_k;
output  [MEM_WRITE_DQS_WIDTH-1:0] phy_mem_k_n;
`endif
`ifdef DDRII_SRAM 
inout	[MEM_DQ_WIDTH-1:0] phy_mem_dq;
output  [MEM_DM_WIDTH-1:0] phy_mem_bws_n;
output  [MEM_WRITE_DQS_WIDTH-1:0] phy_mem_k;
output  [MEM_WRITE_DQS_WIDTH-1:0] phy_mem_k_n;
output  [MEM_READ_DQS_WIDTH-1:0] phy_mem_c;
output  [MEM_READ_DQS_WIDTH-1:0] phy_mem_c_n;
`endif

`ifdef DDRX_LPDDRX
inout	[MEM_DQ_WIDTH-1:0]	phy_mem_dq;
	`ifdef MEM_IF_DM_PINS_EN
output	[MEM_DM_WIDTH-1:0]	phy_mem_dm;
	`endif
output	[MEM_CK_WIDTH-1:0]	phy_mem_ck;
output	[MEM_CK_WIDTH-1:0]	phy_mem_ck_n;
inout	[MEM_DQS_WIDTH-1:0]	mem_dqs;
	`ifdef MEM_IF_DQSN_EN
inout	[MEM_DQS_WIDTH-1:0]	mem_dqs_n;
	`endif
`endif

input   [DLL_DELAY_CTRL_WIDTH-1:0]  dll_phy_delayctrl;
`ifdef HCX_COMPAT_MODE
input   [DLL_DELAY_CTRL_WIDTH-1:0]  hc_dll_config_dll_offset_ctrl_offsetctrlout;
input   [DLL_DELAY_CTRL_WIDTH-1:0]  hc_dll_config_dll_offset_ctrl_b_offsetctrlout;
`endif
`ifdef RLDRAMX
input	[MEM_READ_DQS_WIDTH-1:0] mem_phy_qk;
input	[MEM_READ_DQS_WIDTH-1:0] mem_phy_qk_n;
`endif
`ifdef QDRII
input   [MEM_READ_DQS_WIDTH-1:0] mem_phy_cq;
input   [MEM_READ_DQS_WIDTH-1:0] mem_phy_cq_n;
input   [MEM_DQ_WIDTH-1:0] mem_phy_q;
`endif
`ifdef DDRII_SRAM
input   [MEM_READ_DQS_WIDTH-1:0] mem_phy_cq;
input   [MEM_READ_DQS_WIDTH-1:0] mem_phy_cq_n;
`endif
`ifdef MAKE_FIFOS_IN_ALTDQDQS
`ifdef QUARTER_RATE
localparam DDIO_PHY_DQ_WIDTH = AFI_DATA_WIDTH/2;
`else
localparam DDIO_PHY_DQ_WIDTH = AFI_DATA_WIDTH;
`endif
`else
localparam DDIO_PHY_DQ_WIDTH = DOUBLE_MEM_DQ_WIDTH;
`endif
output	[DDIO_PHY_DQ_WIDTH-1:0] ddio_phy_dq;	
output	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk;	

input	scc_clk;
input	[SCC_DATA_WIDTH - 1:0] scc_data;
input	[MEM_READ_DQS_WIDTH - 1:0] scc_dqs_ena;
input	[MEM_READ_DQS_WIDTH - 1:0] scc_dqs_io_ena;
input	[MEM_DQ_WIDTH - 1:0] scc_dq_ena;
`ifdef MEM_IF_DM_PINS_EN
input	[MEM_DM_WIDTH - 1:0] scc_dm_ena;
`endif
input   [7:0] scc_sr_dqsenable_delayctrl;
input   [7:0] scc_sr_dqsdisablen_delayctrl;
input   [7:0] scc_sr_multirank_delayctrl;

`ifdef MAKE_FIFOS_IN_ALTDQDQS
input  [AFI_RATE_RATIO-1:0] afi_rdata_en;
input  [AFI_RATE_RATIO-1:0] afi_rdata_en_full;
output [AFI_RATE_RATIO-1:0] afi_rdata_valid;
input [4:0] seq_read_latency_counter;
input seq_read_fifo_reset;
input [MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_fr;
input [MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_hr;
wire [MEM_READ_DQS_WIDTH-1:0] rdata_valid;
`endif
`ifdef USE_SHADOW_REGS
input [MEM_READ_DQS_WIDTH-1:0] phy_ddio_read_rank;
input [AFI_DQS_WIDTH-1:0] phy_ddio_write_rank;
input scc_reset_n;
input [MEM_READ_DQS_WIDTH-1:0] scc_upd;
`else
input [0:0] scc_upd;
`endif
input   [MEM_CK_WIDTH-1:0] enable_mem_clk;
output	[MEM_READ_DQS_WIDTH - 1:0] capture_strobe_tracking;

`ifdef USE_DQS_TRACKING
`else
assign capture_strobe_tracking = 1'd0;
`endif

`ifdef BIDIR_DQ_BUS 
wire	[MEM_DQ_WIDTH-1:0] mem_phy_dq;
wire	[DLL_DELAY_CTRL_WIDTH-1:0] read_bidir_dll_phy_delayctrl;
	`ifdef DDRX_LPDDRX
	`else
wire	[MEM_READ_DQS_WIDTH-1:0] read_bidir_dqs_input_data_in;
	`endif
wire	[MEM_READ_DQS_WIDTH-1:0] bidir_read_dqs_bus_out;
wire	[MEM_DQ_WIDTH-1:0] bidir_read_dq_input_data_out_high;
wire	[MEM_DQ_WIDTH-1:0] bidir_read_dq_input_data_out_low;
`endif

`ifdef QUARTER_RATE
wire	hr_clk = pll_hr_clk;
wire	core_clk = pll_hr_clk;
wire	reset_n_core_clk = reset_n_hr_clk;

wire 	[AFI_DATA_WIDTH/2-1:0] phy_ddio_dq_int;
wire	[AFI_DQS_WIDTH/2-1:0] phy_ddio_wrdata_en_int;
wire	[AFI_DATA_MASK_WIDTH/2-1:0]	phy_ddio_wrdata_mask_int;	
	`ifdef DDRX_LPDDRX
wire	[AFI_DQS_WIDTH/2-1:0] phy_ddio_oct_ena_int;
	`endif
	`ifdef RLDRAMX
wire	[AFI_DQS_WIDTH/2-1:0] phy_ddio_oct_ena_int;
	`endif
	`ifdef DDRII_SRAM
wire	[AFI_DQS_WIDTH/2-1:0] phy_ddio_oct_ena_int;
	`endif
	`ifdef DDRX_LPDDRX
wire	[AFI_DQS_WIDTH/2-1:0] phy_ddio_dqs_en_int;
	`endif
	`ifdef USE_SHADOW_REGS
wire	[AFI_DQS_WIDTH/2-1:0] phy_ddio_write_rank_int;
	`endif

`ifdef MAKE_FIFOS_IN_ALTDQDQS
wire 	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_int;

simple_ddio_out	# (
	.DATA_WIDTH (MEM_READ_DQS_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (MEM_READ_DQS_WIDTH),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (0),
	.REG_POST_RESET_HIGH ("false")
) vfifo_inc_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		({{MEM_READ_DQS_WIDTH{1'b0}}, seq_read_increment_vfifo_fr}),
	.dataout	(seq_read_increment_vfifo_int)
);
`endif
	
simple_ddio_out	# (
	.DATA_WIDTH (MEM_DQ_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DATA_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) dq_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_dq),
	.dataout	(phy_ddio_dq_int)
);

simple_ddio_out	# (
	.DATA_WIDTH (MEM_DM_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DATA_MASK_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) wrdata_mask_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		(phy_ddio_wrdata_mask),
	.dataout	(phy_ddio_wrdata_mask_int)
);

simple_ddio_out	# (
	.DATA_WIDTH (MEM_WRITE_DQS_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DQS_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) wrdata_en_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		(phy_ddio_wrdata_en),
	.dataout	(phy_ddio_wrdata_en_int)
	);
	
	`ifdef DDRX_LPDDRX
simple_ddio_out	# (
	.DATA_WIDTH (MEM_WRITE_DQS_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DQS_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) dqs_en_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		(phy_ddio_dqs_en),
	.dataout	(phy_ddio_dqs_en_int)
	);
	
simple_ddio_out	# (
	.DATA_WIDTH (MEM_WRITE_DQS_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DQS_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) oct_ena_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		(phy_ddio_oct_ena),
	.dataout	(phy_ddio_oct_ena_int)
	);
	`endif
	
	`ifdef USE_SHADOW_REGS
simple_ddio_out	# (
	.DATA_WIDTH (MEM_WRITE_DQS_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DQS_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) write_rank_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		(phy_ddio_write_rank),
	.dataout	(phy_ddio_write_rank_int)
	);
	`endif
	
	`ifdef RLDRAMX
simple_ddio_out	# (
	.DATA_WIDTH (MEM_WRITE_DQS_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DQS_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) oct_ena_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		(phy_ddio_oct_ena),
	.dataout	(phy_ddio_oct_ena_int)
	);
	`endif
	
	`ifdef DDRII_SRAM
simple_ddio_out	# (
	.DATA_WIDTH (MEM_WRITE_DQS_WIDTH),
	.OUTPUT_FULL_DATA_WIDTH (AFI_DQS_WIDTH / 2),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) oct_ena_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		(phy_ddio_oct_ena),
	.dataout	(phy_ddio_oct_ena_int)
	);
	`endif
		
`else
wire	hr_clk = pll_afi_clk;
wire	core_clk = pll_afi_clk;
wire	reset_n_core_clk = reset_n_afi_clk;

reg [AFI_DATA_WIDTH-1:0] phy_ddio_dq_int;
reg [AFI_DQS_WIDTH-1:0] phy_ddio_wrdata_en_int;
reg [AFI_DATA_MASK_WIDTH-1:0] phy_ddio_wrdata_mask_int;
	`ifdef DDRX_LPDDRX
reg [AFI_DQS_WIDTH-1:0] phy_ddio_dqs_en_int;
reg [AFI_DQS_WIDTH-1:0] phy_ddio_oct_ena_int;
	`endif
	`ifdef RLDRAMX
reg [AFI_DQS_WIDTH-1:0] phy_ddio_oct_ena_int;
	`endif
	`ifdef DDRII_SRAM
reg [AFI_DQS_WIDTH-1:0] phy_ddio_oct_ena_int;
	`endif	
	`ifdef USE_SHADOW_REGS
reg [AFI_DQS_WIDTH-1:0] phy_ddio_write_rank_int;
	`endif
	
generate
if (REGISTER_C2P == "false") begin
	always @(*) begin	
		phy_ddio_dq_int = phy_ddio_dq;
		phy_ddio_wrdata_en_int = phy_ddio_wrdata_en;
		phy_ddio_wrdata_mask_int = phy_ddio_wrdata_mask;	
	`ifdef DDRX_LPDDRX
		phy_ddio_dqs_en_int = phy_ddio_dqs_en;
		phy_ddio_oct_ena_int = phy_ddio_oct_ena;
	`endif
	`ifdef RLDRAMX
		phy_ddio_oct_ena_int = phy_ddio_oct_ena;
	`endif	
	`ifdef DDRII_SRAM
		phy_ddio_oct_ena_int = phy_ddio_oct_ena;
	`endif
	`ifdef USE_SHADOW_REGS
		phy_ddio_write_rank_int = phy_ddio_write_rank;
	`endif
	end
	
end else begin

	always @(posedge pll_afi_clk) begin
		phy_ddio_dq_int <= phy_ddio_dq;
		phy_ddio_wrdata_en_int <= phy_ddio_wrdata_en;
		phy_ddio_wrdata_mask_int <= phy_ddio_wrdata_mask;	
	`ifdef DDRX_LPDDRX
		phy_ddio_dqs_en_int <= phy_ddio_dqs_en;
		phy_ddio_oct_ena_int <= phy_ddio_oct_ena;
	`endif
	`ifdef RLDRAMX
		phy_ddio_oct_ena_int <= phy_ddio_oct_ena;
	`endif	
	`ifdef DDRII_SRAM
		phy_ddio_oct_ena_int <= phy_ddio_oct_ena;
	`endif
	`ifdef USE_SHADOW_REGS
		phy_ddio_write_rank_int <= phy_ddio_write_rank;
	`endif
	end
end
endgenerate	
`endif


`ifdef MAKE_FIFOS_IN_ALTDQDQS
wire afi_rdata_en_full_shifted_int;

generate
if (EXTRA_VFIFO_SHIFT > 1) begin
	reg [EXTRA_VFIFO_SHIFT-1:0] extra_vfifo_shift;
	always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
	begin
		if (~reset_n_afi_clk) begin
			extra_vfifo_shift <= {EXTRA_VFIFO_SHIFT{1'b0}};
		end
		else begin
			extra_vfifo_shift <= {extra_vfifo_shift[EXTRA_VFIFO_SHIFT-2:0], afi_rdata_en_full[0]};
		end
	end
	assign afi_rdata_en_full_shifted_int = extra_vfifo_shift[EXTRA_VFIFO_SHIFT-1];
end else if (EXTRA_VFIFO_SHIFT == 1) begin
	reg [EXTRA_VFIFO_SHIFT-1:0] extra_vfifo_shift;
	always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
	begin
		if (~reset_n_afi_clk) begin
			extra_vfifo_shift <= {EXTRA_VFIFO_SHIFT{1'b0}};
		end
		else begin
			extra_vfifo_shift <= {afi_rdata_en_full[0]};
		end
	end
	assign afi_rdata_en_full_shifted_int = extra_vfifo_shift[EXTRA_VFIFO_SHIFT-1];
end else begin
	assign afi_rdata_en_full_shifted_int = afi_rdata_en_full[0];
end
endgenerate

`ifdef QUARTER_RATE
wire [1:0] afi_rdata_en_full_shifted_hr;

simple_ddio_out	# (
	.DATA_WIDTH (1),
	.OUTPUT_FULL_DATA_WIDTH (1),
	.USE_CORE_LOGIC ("true"),
	.REGISTER_OUTPUT (REGISTER_C2P),
	.REG_POST_RESET_HIGH ("false")
) rdata_en_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),	
	.datain		({2{afi_rdata_en_full_shifted_int}}),
	.dataout	(afi_rdata_en_full_shifted_hr)
);
wire afi_rdata_en_full_shifted = afi_rdata_en_full_shifted_hr[0];
`else
wire afi_rdata_en_full_shifted = afi_rdata_en_full_shifted_int;
`endif
`endif

`ifdef USE_LDC_FOR_ADDR_CMD
	addr_cmd_ldc_pads uaddr_cmd_pads(
`else    
	addr_cmd_pads uaddr_cmd_pads(
`endif    
		.reset_n				(reset_n_addr_cmd_clk),
		.reset_n_afi_clk		(reset_n_afi_clk),
		.pll_afi_clk            (pll_afi_clk),
		.pll_mem_clk            (pll_mem_clk),
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
		.pll_mem_phy_clk        (pll_mem_phy_clk),
		.pll_afi_phy_clk        (pll_afi_phy_clk),
`endif		
		.pll_write_clk          (pll_write_clk),
`ifdef CORE_PERIPHERY_DUAL_CLOCK
		.pll_c2p_write_clk      (pll_c2p_write_clk),
`endif		
		.phy_ddio_addr_cmd_clk  (phy_ddio_addr_cmd_clk),
		.dll_delayctrl_in       (dll_phy_delayctrl),
		.enable_mem_clk         (enable_mem_clk),
`ifdef USE_DR_CLK
		.pll_dr_clk             (pll_dr_clk),
`endif
`ifdef QUARTER_RATE
		.pll_hr_clk				(pll_hr_clk),
`endif
		.phy_ddio_address 		(phy_ddio_address),
`ifdef RLDRAMX
		.phy_ddio_bank    		(phy_ddio_bank),
		.phy_ddio_cs_n    		(phy_ddio_cs_n),
		.phy_ddio_we_n    		(phy_ddio_we_n),
		.phy_ddio_ref_n		   	(phy_ddio_ref_n),
 `ifdef RLDRAM3		
		.phy_ddio_reset_n	   	(phy_ddio_reset_n),
 `endif

		.phy_mem_address        (phy_mem_address),
		.phy_mem_bank	        (phy_mem_bank),
		.phy_mem_cs_n	        (phy_mem_cs_n),
		.phy_mem_we_n	        (phy_mem_we_n),
		.phy_mem_ref_n	        (phy_mem_ref_n),
 `ifdef RLDRAM3
		.phy_mem_reset_n	    (phy_mem_reset_n),
 `endif
		.phy_mem_ck			    (phy_mem_ck),
		.phy_mem_ck_n		    (phy_mem_ck_n)
`endif
`ifdef QDRII
		.phy_ddio_wps_n         (phy_ddio_wps_n), 
		.phy_ddio_rps_n         (phy_ddio_rps_n), 
		.phy_ddio_doff_n        (phy_ddio_doff_n),
		
		.phy_mem_address        (phy_mem_address),
		.phy_mem_wps_n          (phy_mem_wps_n),
		.phy_mem_rps_n          (phy_mem_rps_n),
		.phy_mem_doff_n         (phy_mem_doff_n)
`endif
`ifdef DDRII_SRAM
		.phy_ddio_ld_n          (phy_ddio_ld_n),
		.phy_ddio_rw_n          (phy_ddio_rw_n),
		.phy_ddio_doff_n        (phy_ddio_doff_n),

		.phy_mem_address        (phy_mem_address),
		.phy_mem_ld_n           (phy_mem_ld_n),
		.phy_mem_rw_n           (phy_mem_rw_n),
		.phy_mem_zq           	(phy_mem_zq),
		.phy_mem_doff_n         (phy_mem_doff_n)
`endif
`ifdef DDRX
		.phy_ddio_bank		    (phy_ddio_bank),
		.phy_ddio_cs_n		    (phy_ddio_cs_n),
		.phy_ddio_cke			(phy_ddio_cke),
`ifndef LPDDR1
		.phy_ddio_odt			(phy_ddio_odt),
`endif
		.phy_ddio_we_n		    (phy_ddio_we_n),	
		.phy_ddio_ras_n		    (phy_ddio_ras_n),
		.phy_ddio_cas_n		    (phy_ddio_cas_n),
`ifdef AC_PARITY
		.phy_ddio_ac_par	    (phy_ddio_ac_par),
`endif
`ifdef DDR3
		.phy_ddio_reset_n		(phy_ddio_reset_n),
`endif

		.phy_mem_address		(phy_mem_address),
		.phy_mem_bank			(phy_mem_bank),
		.phy_mem_cs_n			(phy_mem_cs_n),
		.phy_mem_cke			(phy_mem_cke),
`ifndef LPDDR1
		.phy_mem_odt			(phy_mem_odt),
`endif
		.phy_mem_we_n			(phy_mem_we_n),
		.phy_mem_ras_n			(phy_mem_ras_n),
		.phy_mem_cas_n			(phy_mem_cas_n),
`ifdef AC_PARITY
		.phy_mem_ac_parity	(phy_ac_parity),
		.phy_err_out_n			(phy_err_out_n),
		.phy_parity_error_n (phy_parity_error_n),
`endif
`ifdef DDR3
		.phy_mem_reset_n		(phy_mem_reset_n),
`endif
		.phy_mem_ck				(phy_mem_ck),
		.phy_mem_ck_n			(phy_mem_ck_n)
`endif
`ifdef LPDDR2
		.phy_ddio_cs_n			(phy_ddio_cs_n),
		.phy_ddio_cke			(phy_ddio_cke),

		.phy_mem_address		(phy_mem_address),
		.phy_mem_cs_n			(phy_mem_cs_n),
		.phy_mem_cke			(phy_mem_cke),
		.phy_mem_ck				(phy_mem_ck),
		.phy_mem_ck_n			(phy_mem_ck_n)
`endif
	);
	defparam uaddr_cmd_pads.DEVICE_FAMILY			= DEVICE_FAMILY;
	defparam uaddr_cmd_pads.MEM_ADDRESS_WIDTH		= MEM_ADDRESS_WIDTH;
`ifdef RLDRAMX
	defparam uaddr_cmd_pads.MEM_BANK_WIDTH			= MEM_BANK_WIDTH;
	defparam uaddr_cmd_pads.MEM_CHIP_SELECT_WIDTH	= MEM_CHIP_SELECT_WIDTH;
`endif
`ifdef DDRX_LPDDRX
	defparam uaddr_cmd_pads.MEM_BANK_WIDTH			= MEM_BANK_WIDTH;
	defparam uaddr_cmd_pads.MEM_CHIP_SELECT_WIDTH	= MEM_CHIP_SELECT_WIDTH;
	defparam uaddr_cmd_pads.MEM_CLK_EN_WIDTH		= MEM_CLK_EN_WIDTH;
	defparam uaddr_cmd_pads.MEM_CK_WIDTH			= MEM_CK_WIDTH;
	defparam uaddr_cmd_pads.MEM_ODT_WIDTH			= MEM_ODT_WIDTH;
`endif
	defparam uaddr_cmd_pads.MEM_CONTROL_WIDTH		= MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_pads.AFI_ADDRESS_WIDTH       = AFI_ADDRESS_WIDTH; 
`ifdef RLDRAMX
	defparam uaddr_cmd_pads.AFI_BANK_WIDTH          = AFI_BANK_WIDTH; 
	defparam uaddr_cmd_pads.AFI_CHIP_SELECT_WIDTH   = AFI_CHIP_SELECT_WIDTH; 
`endif
`ifdef DDRX_LPDDRX
	defparam uaddr_cmd_pads.AFI_BANK_WIDTH          = AFI_BANK_WIDTH; 
	defparam uaddr_cmd_pads.AFI_CHIP_SELECT_WIDTH   = AFI_CHIP_SELECT_WIDTH; 
	defparam uaddr_cmd_pads.AFI_CLK_EN_WIDTH        = AFI_CLK_EN_WIDTH; 
	defparam uaddr_cmd_pads.AFI_ODT_WIDTH           = AFI_ODT_WIDTH; 
`endif
	defparam uaddr_cmd_pads.AFI_CONTROL_WIDTH       = AFI_CONTROL_WIDTH; 
	defparam uaddr_cmd_pads.DLL_WIDTH               = DLL_DELAY_CTRL_WIDTH; 
	defparam uaddr_cmd_pads.REGISTER_C2P            = REGISTER_C2P;
`ifdef USE_LDC_FOR_ADDR_CMD
	defparam uaddr_cmd_pads.LDC_MEM_CK_CPS_PHASE    = LDC_MEM_CK_CPS_PHASE;
`else
	defparam uaddr_cmd_pads.IS_HHP_HPS              = IS_HHP_HPS;
`endif
		
`ifdef RLDRAMX
	localparam NUM_OF_DQDQS = MEM_READ_DQS_WIDTH;
`else
	localparam NUM_OF_DQDQS = MEM_WRITE_DQS_WIDTH;
`endif
	localparam DQDQS_DATA_WIDTH = MEM_DQ_WIDTH / NUM_OF_DQDQS;
	localparam DQDQS_DDIO_PHY_DQ_WIDTH = DDIO_PHY_DQ_WIDTH / NUM_OF_DQDQS;
	
`ifdef RLDRAMX
	localparam DQDQS_DM_WIDTH = 1;
	
	`ifdef RLDRAMII_X36
	localparam NUM_OF_DQDQS_WITH_DM = MEM_WRITE_DQS_WIDTH / 2;
	`else
	localparam NUM_OF_DQDQS_WITH_DM = MEM_WRITE_DQS_WIDTH;
	`endif
`else
	localparam DQDQS_DM_WIDTH = MEM_DM_WIDTH / MEM_WRITE_DQS_WIDTH;
		
	localparam NUM_OF_DQDQS_WITH_DM = MEM_WRITE_DQS_WIDTH;		
`endif

	generate
	genvar i;
	for (i=0; i<NUM_OF_DQDQS; i=i+1)
	begin: dq_ddio
		wire dqs_busout;

		// The phy_ddio_dq_int bus is the write data for all DQS groups in one
		// AFI cycle. The bus is ordered by time slot and subordered by DQS group:
		//
		// FR: D1_T1, D0_T1, D1_T0, D0_T0
		// HR: D1_T3, D0_T3, D1_T2, D0_T2, D1_T1, D0_T1, D1_T0, D0_T0
		//
		// Extract the write data targeting the current DQS group
`ifdef FULL_RATE		
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t0 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+0*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+0*NUM_OF_DQDQS)];
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t1 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+1*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+1*NUM_OF_DQDQS)];
`else
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t0 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+0*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+0*NUM_OF_DQDQS)];
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t1 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+1*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+1*NUM_OF_DQDQS)];
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t2 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+2*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+2*NUM_OF_DQDQS)];
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t3 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+3*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+3*NUM_OF_DQDQS)];
`endif

		// Extract the OE signal targeting the current DQS group
`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK
	`ifdef FULL_RATE
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t0 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[(i-(i%2))/2]}};
	`else
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t0 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[(i-(i%2))/2]}};
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t1 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[(i-(i%2))/2+MEM_WRITE_DQS_WIDTH]}};
	`endif
`else
	`ifdef FULL_RATE
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t0 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[i]}};
	`else
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t0 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[i]}};
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t1 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[i+MEM_WRITE_DQS_WIDTH]}};
	`endif
`endif

`ifdef BIDIR_DQ_BUS
		// Extract the dynamic OCT control signal targeting the current DQS group
	`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK
		`ifdef FULL_RATE
		wire phy_ddio_oct_ena_t0 = phy_ddio_oct_ena_int[(i-(i%2))/2];
		`else		
		wire phy_ddio_oct_ena_t0 = phy_ddio_oct_ena_int[(i-(i%2))/2];
		wire phy_ddio_oct_ena_t1 = phy_ddio_oct_ena_int[(i-(i%2))/2+MEM_WRITE_DQS_WIDTH];
		`endif
	`else
		`ifdef FULL_RATE
		wire phy_ddio_oct_ena_t0 = phy_ddio_oct_ena_int[i];
		`else		
		wire phy_ddio_oct_ena_t0 = phy_ddio_oct_ena_int[i];
		wire phy_ddio_oct_ena_t1 = phy_ddio_oct_ena_int[i+MEM_WRITE_DQS_WIDTH];
		`endif
	`endif	
`endif	

		// Extract the write data mask signal targeting the current DQS group
`ifdef FULL_RATE		
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t0;
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t1;
`else
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t0;
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t1;
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t2;
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t3;
`endif
`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM
		if (i % 2 == 1) begin
	`ifdef FULL_RATE
			assign phy_ddio_wrdata_mask_t0 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(((i-1)/2)+1+0*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(((i-1)/2)+0*NUM_OF_DQDQS_WITH_DM)];
			assign phy_ddio_wrdata_mask_t1 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(((i-1)/2)+1+1*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(((i-1)/2)+1*NUM_OF_DQDQS_WITH_DM)];
	`else
			assign phy_ddio_wrdata_mask_t0 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(((i-1)/2)+1+0*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(((i-1)/2)+0*NUM_OF_DQDQS_WITH_DM)];
			assign phy_ddio_wrdata_mask_t1 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(((i-1)/2)+1+1*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(((i-1)/2)+1*NUM_OF_DQDQS_WITH_DM)];
			assign phy_ddio_wrdata_mask_t2 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(((i-1)/2)+1+2*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(((i-1)/2)+2*NUM_OF_DQDQS_WITH_DM)];
			assign phy_ddio_wrdata_mask_t3 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(((i-1)/2)+1+3*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(((i-1)/2)+3*NUM_OF_DQDQS_WITH_DM)];
	`endif
		end
`else
	`ifdef FULL_RATE
		assign phy_ddio_wrdata_mask_t0 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+0*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+0*NUM_OF_DQDQS_WITH_DM)];
		assign phy_ddio_wrdata_mask_t1 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+1*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+1*NUM_OF_DQDQS_WITH_DM)];
	`else
		assign phy_ddio_wrdata_mask_t0 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+0*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+0*NUM_OF_DQDQS_WITH_DM)];
		assign phy_ddio_wrdata_mask_t1 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+1*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+1*NUM_OF_DQDQS_WITH_DM)];
		assign phy_ddio_wrdata_mask_t2 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+2*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+2*NUM_OF_DQDQS_WITH_DM)];
		assign phy_ddio_wrdata_mask_t3 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+3*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+3*NUM_OF_DQDQS_WITH_DM)];
	`endif
`endif

`ifdef MAKE_FIFOS_IN_ALTDQDQS
	wire [AFI_RATE_RATIO-1:0] lfifo_rdata_en = {AFI_RATE_RATIO{afi_rdata_en[0]}};
	wire [AFI_RATE_RATIO-1:0] lfifo_rdata_en_full = {AFI_RATE_RATIO{afi_rdata_en_full_shifted}};
	wire [AFI_RATE_RATIO-1:0] vfifo_qvld = {AFI_RATE_RATIO{afi_rdata_en_full_shifted}};

`ifdef FULL_RATE
	wire vfifo_inc_wr_ptr = seq_read_increment_vfifo_fr[i];
`endif
`ifdef HALF_RATE
	wire [1:0] vfifo_inc_wr_ptr = {1'b0,seq_read_increment_vfifo_fr[i]};
`endif
`ifdef QUARTER_RATE
	wire [1:0] vfifo_inc_wr_ptr = {1'b0,seq_read_increment_vfifo_int[i]};
`endif
`endif

`ifdef USE_SHADOW_REGS
	wire [23:0] t11_settings;
	core_shadow_registers t11_manager_inst (
		.rank_select(phy_ddio_read_rank[i]),
		.scc_clk(scc_clk),
		.scc_reset_n(scc_reset_n),
		.scc_update(scc_dqs_ena[i]),
		.scc_rank(phy_ddio_read_rank[i]),
		.scc_settings_in({scc_sr_dqsenable_delayctrl, scc_sr_dqsdisablen_delayctrl, scc_sr_multirank_delayctrl}),
		.settings_out(t11_settings)
	);
	defparam t11_manager_inst.SETTINGS_WIDTH = 24;
`endif

`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM
		if (i % 2 == 0) begin
			altdqdqs_r ubidir_dq_dqs (
				.core_clock_in (core_clk),
				.reset_n_core_clock_in (reset_n_core_clk),

	`ifdef DUAL_WRITE_CLOCK
				.fr_data_clock_in (pll_mem_clk),
				.fr_strobe_clock_in (pll_write_clk),
	`else
				.fr_clock_in (pll_write_clk),
	`endif

	`ifdef CORE_PERIPHERY_DUAL_CLOCK
				.hr_clock_in (pll_c2p_write_clk),
	`else
		`ifdef DUPLICATE_PLL_FOR_PHY_CLK
				.hr_clock_in (pll_afi_phy_clk),
		`else
				.hr_clock_in (hr_clk),
		`endif
	`endif
	`ifdef USE_2X_FF
				.dr_clock_in (pll_dr_clk),
	`endif
	`ifdef ARRIAIIGX
				.seriesterminationcontrol_in(oct_ctl_value),
	`else
				.parallelterminationcontrol_in(oct_ctl_rt_value),
				.seriesterminationcontrol_in(oct_ctl_rs_value),
	`endif
	`ifdef RLDRAM3_X36
				.read_write_data_io (phy_mem_dq[(DQDQS_DATA_WIDTH*((i-(i%4)/2)+1)-1) : DQDQS_DATA_WIDTH*(i-(i%4)/2)]),
				.capture_strobe_in (mem_phy_qk[i-(i%4)/2]),
				.capture_strobe_n_in (mem_phy_qk_n[i-(i%4)/2]),
	`else
				.read_write_data_io (phy_mem_dq[(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]),
				.capture_strobe_in (mem_phy_qk[i]),
				.capture_strobe_n_in (mem_phy_qk_n[i]),
	`endif
				.read_data_out (ddio_phy_dq [(DQDQS_DDIO_PHY_DQ_WIDTH*(i+1)-1) : DQDQS_DDIO_PHY_DQ_WIDTH*i]),
				.capture_strobe_out (dqs_busout),
	`ifdef FULL_RATE
				.write_data_in ({phy_ddio_dq_t1, phy_ddio_dq_t0}),
				.write_oe_in (phy_ddio_wrdata_en_t0),
				.oct_ena_in (phy_ddio_oct_ena_t0),
	`else
				.write_data_in ({phy_ddio_dq_t3, phy_ddio_dq_t2, phy_ddio_dq_t1, phy_ddio_dq_t0}),
				.write_oe_in ({phy_ddio_wrdata_en_t1, phy_ddio_wrdata_en_t0}),
				.oct_ena_in ({phy_ddio_oct_ena_t1, phy_ddio_oct_ena_t0}),
	`endif
	`ifdef RLDRAMII_X36
		`ifdef MEM_LEVELING
				.write_strobe_clock_in (1'b0),
		`else
			`ifdef USE_LDC_AS_LOW_SKEW_CLOCK
				.write_strobe_clock_in (1'b0),
			`else
				`ifdef DUPLICATE_PLL_FOR_PHY_CLK
				.write_strobe_clock_in (pll_mem_phy_clk),
				`else
				.write_strobe_clock_in (pll_mem_clk),
				`endif
			`endif
		`endif			
				.output_strobe_out (phy_mem_dk[i]),
				.output_strobe_n_out (phy_mem_dk_n[i]),
	`else
		`ifdef MAKE_FIFOS_IN_ALTDQDQS
				.write_strobe_clock_in (pll_mem_phy_clk),
		`endif
	`endif
	`ifdef NIOS_SEQUENCER		
	            `ifdef TRK_PARALLEL_SCC_LOAD
				.config_data_in (scc_data[i]),
				`else
				.config_data_in (scc_data),
				`endif
				.config_dqs_ena (scc_dqs_ena[i]),
				.config_io_ena (scc_dq_ena[(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]),
				.config_dqs_io_ena (scc_dqs_io_ena[i]),
				.config_update (scc_upd[0]),
				.config_clock_in (scc_clk),
	`endif
	`ifdef HCX_COMPAT_MODE
				.dll_offsetdelay_in((i < 0) ? hc_dll_config_dll_offset_ctrl_offsetctrlout : hc_dll_config_dll_offset_ctrl_offsetctrlout),
	`endif
	`ifdef MAKE_FIFOS_IN_ALTDQDQS
				.lfifo_rdata_en (lfifo_rdata_en),
				.lfifo_rdata_en_full (lfifo_rdata_en_full),
				.lfifo_rd_latency (seq_read_latency_counter),
				.lfifo_reset_n (~reset_n_afi_clk),
				.lfifo_rdata_valid (rdata_valid[i]),
				.vfifo_qvld (vfifo_qvld),
				.vfifo_inc_wr_ptr (vfifo_inc_wr_ptr),
				.vfifo_reset_n (~phy_reset_mem_stable),
				.rfifo_reset_n (seq_read_fifo_reset),
	`endif
				.dll_delayctrl_in (dll_phy_delayctrl)
			);
			defparam ubidir_dq_dqs.ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = FAST_SIM_MODEL;
		end else begin
`endif
`ifdef BIDIR_DQ_BUS
			altdqdqs ubidir_dq_dqs (
`else
			altdqdqs uwrite (
`endif		
`ifdef MEM_LEVELING
				.write_strobe_clock_in (1'b0),
`else
	`ifdef USE_LDC_AS_LOW_SKEW_CLOCK
				.write_strobe_clock_in (1'b0),
	`else
		`ifdef DUPLICATE_PLL_FOR_PHY_CLK
				.write_strobe_clock_in (pll_mem_phy_clk),
		`else
				.write_strobe_clock_in (pll_mem_clk),
		`endif
	`endif
`endif
				.reset_n_core_clock_in (reset_n_core_clk),
				.core_clock_in (core_clk),
	`ifdef DUAL_WRITE_CLOCK
				.fr_data_clock_in (pll_mem_clk),
				.fr_strobe_clock_in (pll_write_clk),
	`else
				.fr_clock_in (pll_write_clk),
	`endif

`ifdef CORE_PERIPHERY_DUAL_CLOCK
				.hr_clock_in (pll_c2p_write_clk),
`else
	`ifdef DUPLICATE_PLL_FOR_PHY_CLK
				.hr_clock_in (pll_afi_phy_clk),
	`else
				.hr_clock_in (hr_clk),
	`endif
`endif
`ifdef USE_2X_FF
				.dr_clock_in (pll_dr_clk),
`endif
`ifdef ARRIAIIGX
				.seriesterminationcontrol_in(oct_ctl_value),
`else
				.parallelterminationcontrol_in(oct_ctl_rt_value),
				.seriesterminationcontrol_in(oct_ctl_rs_value),
`endif				
`ifdef DDRX_LPDDRX
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
				.strobe_ena_hr_clock_in (pll_c2p_write_clk),
	`else
				.strobe_ena_hr_clock_in (hr_clk),
	`endif
	`ifdef ARRIAV
	`else
		`ifdef CYCLONEV
		`else
				.strobe_ena_clock_in (pll_dqs_ena_clk),
		`endif
	`endif
`endif
`ifdef BIDIR_DQ_BUS 
	`ifdef RLDRAM3_X36
				.read_write_data_io (phy_mem_dq[(DQDQS_DATA_WIDTH*((i+i%4%3)+1)-1) : DQDQS_DATA_WIDTH*(i+i%4%3)]),
	`else
				.read_write_data_io (phy_mem_dq[(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]),
	`endif
				.read_data_out (ddio_phy_dq [(DQDQS_DDIO_PHY_DQ_WIDTH*(i+1)-1) : DQDQS_DDIO_PHY_DQ_WIDTH*i]),
	`ifdef RLDRAMX
	 `ifdef RLDRAM3_X36
				.capture_strobe_in (mem_phy_qk[i+i%4%3]),
				.capture_strobe_n_in (mem_phy_qk_n[i+i%4%3]),
	 `else
				.capture_strobe_in (mem_phy_qk[i]),
				.capture_strobe_n_in (mem_phy_qk_n[i]),
	 `endif
	`endif
	`ifdef DDRII_SRAM
				.capture_strobe_in (mem_phy_cq[i]),
				.capture_strobe_n_in (mem_phy_cq_n[i]),
	`endif
				.capture_strobe_out(dqs_busout),
			
	`ifdef FULL_RATE
		`ifdef MEM_IF_DM_PINS_EN
				.extra_write_data_in ({phy_ddio_wrdata_mask_t1, phy_ddio_wrdata_mask_t0}),
		`endif
	`else
		`ifdef MEM_IF_DM_PINS_EN
				.extra_write_data_in ({phy_ddio_wrdata_mask_t3, phy_ddio_wrdata_mask_t2, phy_ddio_wrdata_mask_t1, phy_ddio_wrdata_mask_t0}),
		`endif
	`endif
`else
				.write_data_out (phy_mem_d [(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]),
				
	`ifdef FULL_RATE
				.extra_write_data_in ({phy_ddio_wrdata_mask_t1, phy_ddio_wrdata_mask_t0}),
				.write_oe_in (phy_ddio_wrdata_en_t0),
	`else
				.extra_write_data_in ({phy_ddio_wrdata_mask_t3, phy_ddio_wrdata_mask_t2, phy_ddio_wrdata_mask_t1, phy_ddio_wrdata_mask_t0}),
				.write_oe_in ({phy_ddio_wrdata_en_t1, phy_ddio_wrdata_en_t0}),
	`endif
`endif
				
`ifdef FULL_RATE
				.write_data_in ({phy_ddio_dq_t1, phy_ddio_dq_t0}),
`else
				.write_data_in ({phy_ddio_dq_t3, phy_ddio_dq_t2, phy_ddio_dq_t1, phy_ddio_dq_t0}),
`endif

`ifdef DDRX_LPDDRX
	`ifdef FULL_RATE
				.write_oe_in (phy_ddio_wrdata_en_t0),
	`else
				.write_oe_in ({phy_ddio_wrdata_en_t1, phy_ddio_wrdata_en_t0}),
	`endif
`endif

`ifdef RLDRAMX
	`ifdef FULL_RATE
				.write_oe_in (phy_ddio_wrdata_en_t0),
				.oct_ena_in (phy_ddio_oct_ena_t0),
	`else
				.write_oe_in ({phy_ddio_wrdata_en_t1, phy_ddio_wrdata_en_t0}),
				.oct_ena_in ({phy_ddio_oct_ena_t1, phy_ddio_oct_ena_t0}),
	`endif
	`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK
				.output_strobe_out (phy_mem_dk[(i-1)/2]),
				.output_strobe_n_out (phy_mem_dk_n[(i-1)/2]),
	`else
				.output_strobe_out (phy_mem_dk[i]),
				.output_strobe_n_out (phy_mem_dk_n[i]),
	`endif
	`ifdef MEM_IF_DM_PINS_EN
		`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM
				.extra_write_data_out (phy_mem_dm[(i-1)/2]),
		`else
				.extra_write_data_out (phy_mem_dm[i]),
		`endif
	`endif
`endif
`ifdef QDRII
				.output_strobe_out (phy_mem_k[i]),
				.output_strobe_n_out (phy_mem_k_n[i]),
				.extra_write_data_out (phy_mem_bws_n[DQDQS_DM_WIDTH*(i+1)-1:DQDQS_DM_WIDTH*i]),
`endif
`ifdef DDRII_SRAM 
				.write_oe_in ({phy_ddio_wrdata_en_t1, phy_ddio_wrdata_en_t0}),
				.output_strobe_out (phy_mem_k[i]),
				.output_strobe_n_out (phy_mem_k_n[i]),
				.extra_write_data_out (phy_mem_bws_n[DQDQS_DM_WIDTH*(i+1)-1:DQDQS_DM_WIDTH*i]),
`endif
`ifdef DDRX_LPDDRX
				.strobe_io (mem_dqs[i]),
	`ifdef MEM_IF_DQSN_EN
				.strobe_n_io (mem_dqs_n[i]),
	`endif
	`ifdef FULL_RATE
				.output_strobe_ena (phy_ddio_dqs_en_int[i]),
				.oct_ena_in (phy_ddio_oct_ena_t0),
	`else
				.output_strobe_ena ({phy_ddio_dqs_en_int[i+NUM_OF_DQDQS], phy_ddio_dqs_en_int[i]}),
				.oct_ena_in ({phy_ddio_oct_ena_t1, phy_ddio_oct_ena_t0}),
	`endif
	`ifndef MAKE_FIFOS_IN_ALTDQDQS
		`ifdef VFIFO_FULL_RATE
				.capture_strobe_ena (dqs_enable_ctrl[i]),
		`else
				.capture_strobe_ena ({dqs_enable_ctrl[i+NUM_OF_DQDQS], dqs_enable_ctrl[i]}),
		`endif
	`endif
	`ifdef MEM_IF_DM_PINS_EN
				.extra_write_data_out (phy_mem_dm[i]),
	`endif
`endif
`ifdef NIOS_SEQUENCER		
                `ifdef TRK_PARALLEL_SCC_LOAD
				.config_data_in (scc_data[i]),
				`else
				.config_data_in (scc_data),
				`endif
				.config_dqs_ena (scc_dqs_ena[i]),
				.config_io_ena (scc_dq_ena[(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]),
		`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK
				.config_dqs_io_ena (scc_dqs_io_ena[(i-1)/2]),
		`else
				.config_dqs_io_ena (scc_dqs_io_ena[i]),
		`endif
		`ifdef USE_SHADOW_REGS
				.config_update (scc_upd[i]),
		`else
				.config_update (scc_upd[0]),
		`endif
		`ifdef USE_DQS_TRACKING
				.capture_strobe_tracking (capture_strobe_tracking[i]),
		`endif
				.config_clock_in (scc_clk),
	`ifdef DDRX_LPDDRX
		`ifdef MEM_IF_DM_PINS_EN
				.config_extra_io_ena (scc_dm_ena[i]),
		`endif
	`endif
	`ifdef QDRII
				.config_extra_io_ena (scc_dm_ena[DQDQS_DM_WIDTH*(i+1)-1:DQDQS_DM_WIDTH*i]),
	`endif
	`ifdef RLDRAMX
		`ifdef MEM_IF_DM_PINS_EN
			`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM
				.config_extra_io_ena (scc_dm_ena[(i-1)/2]),
			`else
				.config_extra_io_ena (scc_dm_ena[i]),
			`endif
		`endif
	`endif
`endif
`ifdef HCX_COMPAT_MODE
				.dll_offsetdelay_in((i < 0) ? hc_dll_config_dll_offset_ctrl_offsetctrlout : hc_dll_config_dll_offset_ctrl_offsetctrlout),
`endif
`ifdef MAKE_FIFOS_IN_ALTDQDQS
	`ifndef QDRII
				.lfifo_rdata_en (lfifo_rdata_en),
				.lfifo_rdata_en_full (lfifo_rdata_en_full),
				.lfifo_rd_latency (seq_read_latency_counter),
				.lfifo_reset_n (~reset_n_afi_clk),
				.lfifo_rdata_valid (rdata_valid[i]),
				.vfifo_qvld (vfifo_qvld),
				.vfifo_inc_wr_ptr (vfifo_inc_wr_ptr),
				.vfifo_reset_n (~phy_reset_mem_stable),
				.rfifo_reset_n (seq_read_fifo_reset),
	`endif
`endif
`ifdef USE_SHADOW_REGS
				.corerankselectwritein({phy_ddio_write_rank_int[i+NUM_OF_DQDQS], phy_ddio_write_rank_int[i]}),
				.corerankselectreadin(phy_ddio_read_rank[i]),
				.coredqsenabledelayctrlin(t11_settings[23:16]),
				.coredqsdisablendelayctrlin(t11_settings[15:8]),
				.coremultirankdelayctrlin(t11_settings[7:0]),
`endif

`ifdef QDRII
`ifdef RTL_CALIB
`ifdef STRATIXV
`ifndef NIOS_SEQUENCER
				.config_data_in (mem_config_datain), 
				.config_dqs_ena (mem_config_kdqs_ena[i]), 
				.config_io_ena (mem_config_wio_ena[(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]), 
				.config_dqs_io_ena (mem_config_k_io_ena[i]), 
				.config_update (mem_config_update[0]), 
				.config_clock_in (mem_config_clk), 
				.config_extra_io_ena (mem_config_dm_ena[DQDQS_DM_WIDTH*(i+1)-1:DQDQS_DM_WIDTH*i]), 
				.dll_offsetdelay_in (dll_offsetdelay_in),
`endif
`endif
`endif
`endif
				.dll_delayctrl_in (dll_phy_delayctrl)	
				);
`ifdef BIDIR_DQ_BUS
			defparam ubidir_dq_dqs.ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = FAST_SIM_MODEL;
`else
			defparam uwrite.ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = FAST_SIM_MODEL;
`endif		
						
`ifdef RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM
		end
`endif
			
`ifdef BIDIR_DQ_BUS
	`ifdef USE_HARD_READ_FIFO
		assign read_capture_clk[i] = ~dqs_busout;
	`else
		`ifdef READ_FIFO_HALF_RATE
		assign read_capture_clk[i] = ~dqs_busout;
		`else
		lcell read_capture_clk_buffer(.in(~dqs_busout), .out(read_capture_clk[i])) /* synthesis syn_noprune syn_preserve = 1 */;
		`endif
	`endif
`endif
	end
	endgenerate

`ifdef BIDIR_DQ_BUS
`else
	localparam DQDQS_READ_DATA_WIDTH = MEM_DQ_WIDTH / MEM_READ_DQS_WIDTH;
	localparam DQDQS_READ_DDIO_PHY_DQ_WIDTH = DDIO_PHY_DQ_WIDTH / MEM_READ_DQS_WIDTH;
	
	generate
	genvar c;
		for (c=0; c<MEM_READ_DQS_WIDTH; c=c+1)
		begin: read_capture
			wire dqs_busout;
			
`ifdef MAKE_FIFOS_IN_ALTDQDQS
			wire [AFI_RATE_RATIO-1:0] lfifo_rdata_en = {AFI_RATE_RATIO{afi_rdata_en[0]}};
			wire [AFI_RATE_RATIO-1:0] lfifo_rdata_en_full = {AFI_RATE_RATIO{afi_rdata_en_full_shifted}};
			wire [AFI_RATE_RATIO-1:0] vfifo_qvld = {AFI_RATE_RATIO{afi_rdata_en_full_shifted}};
`ifdef FULL_RATE
			wire vfifo_inc_wr_ptr = seq_read_increment_vfifo_fr[c];
`else
			wire [1:0] vfifo_inc_wr_ptr = {1'b0,seq_read_increment_vfifo_fr[c]};
`endif
`endif
		
			altdqdqs_in uread (
`ifdef MAKE_FIFOS_IN_ALTDQDQS
				.fr_clock_in (pll_write_clk),
				.hr_clock_in (pll_afi_phy_clk),
`else
				.hr_clock_in (1'b0),
`endif
				.read_data_in (mem_phy_q[(DQDQS_READ_DATA_WIDTH*(c+1)-1) : DQDQS_READ_DATA_WIDTH*c]),	
				.read_data_out (ddio_phy_dq[(DQDQS_READ_DDIO_PHY_DQ_WIDTH*(c+1)-1) : DQDQS_READ_DDIO_PHY_DQ_WIDTH*c]),
`ifdef NIOS_SEQUENCER		
                `ifdef TRK_PARALLEL_SCC_LOAD
				.config_data_in (scc_data[c]),
				`else
				.config_data_in (scc_data),
				`endif
				.config_dqs_ena (scc_dqs_ena[c]),
				.config_io_ena (scc_dq_ena[(DQDQS_READ_DATA_WIDTH*(c+1)-1) : DQDQS_READ_DATA_WIDTH*c]),
				.config_dqs_io_ena (scc_dqs_io_ena[c]),
				.config_update (scc_upd[0]),
				.config_clock_in (scc_clk),
`endif
`ifdef HCX_COMPAT_MODE
				.dll_offsetdelay_in((c < 0) ? hc_dll_config_dll_offset_ctrl_offsetctrlout : hc_dll_config_dll_offset_ctrl_offsetctrlout),
`endif					
				.dll_delayctrl_in (dll_phy_delayctrl),
	`ifdef RL2
				.capture_strobe_in (mem_phy_cq_n[c]),
		`ifdef MEM_IF_CQN_EN
				.capture_strobe_n_in (mem_phy_cq[c]),
		`endif
	`else
				.capture_strobe_in (mem_phy_cq[c]),
		`ifdef MEM_IF_CQN_EN
				.capture_strobe_n_in (mem_phy_cq_n[c]),
		`endif
	`endif
	`ifdef MAKE_FIFOS_IN_ALTDQDQS
				.write_strobe_clock_in (pll_mem_phy_clk),
				.lfifo_rdata_en (lfifo_rdata_en),
				.lfifo_rdata_en_full (lfifo_rdata_en_full),
				.lfifo_rd_latency (seq_read_latency_counter),
				.lfifo_reset_n (~reset_n_afi_clk),
				.lfifo_rdata_valid (rdata_valid[c]),
				.vfifo_qvld (vfifo_qvld),
				.vfifo_inc_wr_ptr (vfifo_inc_wr_ptr),
				.vfifo_reset_n (~phy_reset_mem_stable),
				.rfifo_reset_n (seq_read_fifo_reset),
`endif
`ifdef QDRII
`ifdef RTL_CALIB
`ifdef STRATIXV
`ifndef NIOS_SEQUENCER
				.config_data_in (mem_config_datain), 
				.config_dqs_ena (mem_config_cqdqs_ena[c]), 
				.config_io_ena (mem_config_rio_ena[(DQDQS_READ_DATA_WIDTH*(c+1)-1) : DQDQS_READ_DATA_WIDTH*c]), 
				.config_dqs_io_ena (mem_config_cq_io_ena[c]), 
				.config_update (mem_config_update[0]), 
				.config_clock_in (mem_config_clk), 
				.dll_offsetdelay_in (dll_offsetdelay_in),
`endif
`endif
`endif
`endif
				.capture_strobe_out (dqs_busout)
			);
			defparam uread.ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = FAST_SIM_MODEL;

	`ifdef USE_HARD_READ_FIFO
		assign read_capture_clk[c] = dqs_busout;
	`else
		`ifdef READ_FIFO_HALF_RATE
		assign read_capture_clk[c] = dqs_busout;
		`else
		lcell read_capture_clk_buffer(.in(dqs_busout), .out(read_capture_clk[c])) /* synthesis syn_noprune syn_preserve = 1 */;
		`endif
	`endif
		end
	endgenerate
`endif

`ifdef MAKE_FIFOS_IN_ALTDQDQS
	`ifdef FULL_RATE 
		assign afi_rdata_valid = {AFI_RATE_RATIO{&rdata_valid}};
	`else 
		reg [AFI_RATE_RATIO-1:0] afi_rdata_valid;
		always @(posedge pll_mem_clk or negedge reset_n_afi_clk)
		begin
			if (~reset_n_afi_clk) begin	
				afi_rdata_valid <= {AFI_RATE_RATIO{1'b0}};
			end else begin
				afi_rdata_valid <= {AFI_RATE_RATIO{&rdata_valid}};
			end
		end
	`endif
`endif
endmodule
