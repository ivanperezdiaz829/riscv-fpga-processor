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

module memphy_m10(
    global_reset_n,
    soft_reset_n,
	afi_addr,
	afi_cke,
	afi_cs_n,
	afi_ba,
	afi_cas_n,
	afi_odt,
	afi_ras_n,
	afi_we_n,
`ifdef DDR3
	afi_rst_n,
`endif
	afi_dqs_burst,
	afi_wlat,
	afi_rlat,
	afi_wdata,
	afi_wdata_valid,
	afi_dm,
	afi_rdata,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
	afi_cal_debug_info,
	afi_cal_success,
	afi_cal_fail,
`ifdef LPDDR2
    mem_ca,
`else
	mem_a,
	mem_ba,
	mem_ras_n,
	mem_cas_n,
	mem_we_n,
`endif
	mem_ck,
	mem_ck_n,
	mem_cke,
	mem_cs_n,
`ifdef MEM_IF_DM_PINS_EN
	mem_dm,
`endif
	mem_odt,
`ifdef DDR3
	mem_reset_n,
`endif
	mem_dq,
	mem_dqs,
`ifdef MEM_IF_DQSN_EN
	mem_dqs_n,
`endif
	phy_read_latency_counter,
	phy_afi_wlat,
	phy_afi_rlat,
	phy_num_write_fr_cycle_shifts,
	phy_read_increment_vfifo_fr,
	phy_read_increment_vfifo_hr,
	phy_read_increment_vfifo_qr,
	phy_reset_mem_stable,
	phy_cal_debug_info,
	phy_read_fifo_reset,
	phy_vfifo_rd_en_override,
	calib_skip_steps,
	pll_afi_clk,
	pll_mem_clk,
	pll_write_clk,
	pll_capture0_clk,
	pll_capture1_clk
);

parameter DEVICE_FAMILY = "";

parameter MEM_ADDRESS_WIDTH     = ""; 
parameter MEM_BANK_WIDTH        = "";
parameter MEM_CLK_EN_WIDTH 	    = ""; 
parameter MEM_CK_WIDTH 	    	= ""; 
parameter MEM_ODT_WIDTH 		= ""; 
parameter MEM_DQS_WIDTH         = "";
parameter MEM_CHIP_SELECT_WIDTH = ""; 
parameter MEM_CONTROL_WIDTH     = ""; 
parameter MEM_DM_WIDTH          = ""; 
parameter MEM_DQ_WIDTH          = ""; 
parameter MEM_READ_DQS_WIDTH    = ""; 
parameter MEM_WRITE_DQS_WIDTH   = "";
parameter MEM_IF_NUMBER_OF_RANKS	= "";

parameter AFI_ADDRESS_WIDTH         = ""; 
parameter AFI_DEBUG_INFO_WIDTH = "";
parameter AFI_BANK_WIDTH            = "";
parameter AFI_CHIP_SELECT_WIDTH     = "";
parameter AFI_CLK_EN_WIDTH     		= "";
parameter AFI_ODT_WIDTH     		= "";
parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH = "";
parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH = "";
parameter AFI_DATA_MASK_WIDTH       = "";
parameter AFI_CONTROL_WIDTH         = "";
parameter AFI_DATA_WIDTH            = "";
parameter AFI_DQS_WIDTH             = "";
parameter AFI_RATE_RATIO            = "";
parameter AFI_RRANK_WIDTH	    = "";
parameter AFI_WRANK_WIDTH	    = "";

parameter READ_VALID_FIFO_SIZE             = "";
parameter READ_FIFO_SIZE                   = "";

parameter MAX_LATENCY_COUNT_WIDTH          = "";
parameter MAX_READ_LATENCY                 = "";

parameter CALIB_REG_WIDTH = "";



input	global_reset_n;			
input   soft_reset_n;

input   [AFI_ADDRESS_WIDTH-1:0] afi_addr;       

input   [AFI_CLK_EN_WIDTH-1:0] afi_cke;
input   [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n;
input   [AFI_BANK_WIDTH-1:0]    afi_ba;
input   [AFI_CONTROL_WIDTH-1:0] afi_cas_n;
input   [AFI_ODT_WIDTH-1:0] afi_odt;
input   [AFI_CONTROL_WIDTH-1:0] afi_ras_n;
input   [AFI_CONTROL_WIDTH-1:0] afi_we_n;
`ifdef DDR3
input   [AFI_CONTROL_WIDTH-1:0] afi_rst_n;
`endif
input   [AFI_DQS_WIDTH-1:0]	afi_dqs_burst;	
output  [AFI_MAX_WRITE_LATENCY_COUNT_WIDTH-1:0] afi_wlat;
output  [AFI_MAX_READ_LATENCY_COUNT_WIDTH-1:0]  afi_rlat;

input   [AFI_DATA_WIDTH-1:0]    afi_wdata;              
input   [AFI_DQS_WIDTH-1:0]		afi_wdata_valid;    	
input   [AFI_DATA_MASK_WIDTH-1:0]   afi_dm;             

output  [AFI_DATA_WIDTH-1:0]    afi_rdata;              
input   [AFI_RATE_RATIO-1:0]    afi_rdata_en;           
input   [AFI_RATE_RATIO-1:0]    afi_rdata_en_full;      
output  [AFI_RATE_RATIO-1:0]    afi_rdata_valid;        

input  afi_cal_success;    
input  afi_cal_fail;       
output [AFI_DEBUG_INFO_WIDTH - 1:0] afi_cal_debug_info;


`ifdef LPDDR2
output  [MEM_ADDRESS_WIDTH-1:0] mem_ca;
`else
output  [MEM_ADDRESS_WIDTH-1:0] mem_a;
output  [MEM_BANK_WIDTH-1:0]    mem_ba;
output  [MEM_CONTROL_WIDTH-1:0] mem_ras_n;
output  [MEM_CONTROL_WIDTH-1:0] mem_cas_n;
output  [MEM_CONTROL_WIDTH-1:0] mem_we_n;
`endif
output  [MEM_CK_WIDTH-1:0]	mem_ck;
output  [MEM_CK_WIDTH-1:0]	mem_ck_n;
output  [MEM_CLK_EN_WIDTH-1:0] mem_cke;
output  [MEM_CHIP_SELECT_WIDTH-1:0] mem_cs_n;
`ifdef MEM_IF_DM_PINS_EN
output  [MEM_DM_WIDTH-1:0]  mem_dm;
`endif
output  [MEM_ODT_WIDTH-1:0] mem_odt;
`ifdef DDR3
output  mem_reset_n;
`endif
inout   [MEM_DQ_WIDTH-1:0]  mem_dq;
inout   [MEM_DQS_WIDTH-1:0] mem_dqs;
`ifdef MEM_IF_DQSN_EN
inout   [MEM_DQS_WIDTH-1:0] mem_dqs_n;
`endif

input  [MAX_LATENCY_COUNT_WIDTH-1:0]  phy_read_latency_counter;
input  [AFI_MAX_WRITE_LATENCY_COUNT_WIDTH-1:0]  phy_afi_wlat;
input  [AFI_MAX_READ_LATENCY_COUNT_WIDTH-1:0]  phy_afi_rlat;
input  [MEM_WRITE_DQS_WIDTH*2-1:0]  phy_num_write_fr_cycle_shifts;
input  [MEM_READ_DQS_WIDTH-1:0]     phy_read_increment_vfifo_fr;
input  [MEM_READ_DQS_WIDTH-1:0]     phy_read_increment_vfifo_hr;
input  [MEM_READ_DQS_WIDTH-1:0]     phy_read_increment_vfifo_qr;
input                               phy_reset_mem_stable;
input   [AFI_DEBUG_INFO_WIDTH - 1:0]  phy_cal_debug_info;
input   [MEM_READ_DQS_WIDTH-1:0]  phy_read_fifo_reset;
input   [MEM_READ_DQS_WIDTH-1:0]  phy_vfifo_rd_en_override;

output  [CALIB_REG_WIDTH-1:0]  calib_skip_steps;

input	pll_afi_clk;		
input	pll_mem_clk;		
input	pll_write_clk;		
input   pll_capture0_clk;
input   pll_capture1_clk;


endmodule
