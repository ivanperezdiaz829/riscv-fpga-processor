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
// This file instantiates the Ping Pong PHY Gasket.
// ******************************************************************************************************************************** 



`timescale 1 ps / 1 ps

(* altera_attribute = "-name IP_TOOL_NAME alt_mem_if_pp_gasket; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100; -name ALLOW_SYNCH_CTRL_USAGE OFF; -name AUTO_CLOCK_ENABLE_RECOGNITION OFF; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)

module alt_mem_if_pp_gasket_use_shadow_regs (
	afi_clk,
	afi_reset_n,

	phy_cal_success,
	phy_cal_fail,

	// PHY interface
	phy_addr,
	phy_ba,
	phy_ras_n,
	phy_cas_n,
	phy_we_n,
	phy_cke,
	phy_cs_n,
	phy_odt,
	phy_rst_n,

	phy_dqs_burst,
	phy_wdata_valid,
	phy_wdata,
	phy_dm,
	phy_wlat,
	phy_rlat,
	phy_rdata_en,
	phy_rdata_en_full,
	phy_rdata_en_1t, 
	phy_rdata_en_full_1t, 
	phy_rdata_valid_1t, 
	phy_rdata,
	phy_rdata_valid,
	phy_wrank,
	phy_rrank,
	phy_cal_req,
	phy_init_req,
	phy_mem_clk_disable,
	phy_ctl_refresh_done,
	phy_ctl_long_idle,
	phy_seq_busy,


	// LHS Controller
	ctl_l_addr,
	ctl_l_ba,
	ctl_l_ras_n,
	ctl_l_cas_n,
	ctl_l_we_n,
	ctl_l_cs_n,
	ctl_l_odt,
	ctl_l_cke,
	ctl_l_rst_n,
	ctl_l_rdata_en,
	ctl_l_rdata_en_full,
	ctl_l_dqs_burst,
	ctl_l_wdata_valid,
	ctl_l_wdata,
	ctl_l_dm,
	ctl_l_wlat,
	ctl_l_rlat,
	ctl_l_rdata,
	ctl_l_rdata_valid,
	ctl_l_cal_success,
	ctl_l_cal_fail,
	ctl_l_wrank,
	ctl_l_rrank,
	ctl_l_cal_req,
	ctl_l_init_req,
	ctl_l_mem_clk_disable,
	ctl_l_ctl_refresh_done, 
	ctl_l_ctl_long_idle,	
	ctl_l_seq_busy,	


	// RHS Controller
	ctl_r_addr,
	ctl_r_ba,
	ctl_r_ras_n,
	ctl_r_cas_n,
	ctl_r_we_n,
	ctl_r_cs_n,
	ctl_r_odt,
	ctl_r_cke,
	ctl_r_rst_n,
	ctl_r_rdata_en,
	ctl_r_rdata_en_full,
	ctl_r_dqs_burst,
	ctl_r_wdata_valid,
	ctl_r_wdata,
	ctl_r_dm,
	ctl_r_wlat,
	ctl_r_rlat,
	ctl_r_rdata,
	ctl_r_rdata_valid,
	ctl_r_cal_success,
	ctl_r_cal_fail,
	ctl_r_wrank,
	ctl_r_rrank,
	ctl_r_cal_req,
	ctl_r_init_req,
	ctl_r_mem_clk_disable,
	ctl_r_ctl_refresh_done, 
	ctl_r_ctl_long_idle,	
	ctl_r_seq_busy	

);


// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver. 

parameter AFI_ADDR_WIDTH 	        = 0;
parameter AFI_DM_WIDTH 	        	= 0;
parameter AFI_BANKADDR_WIDTH        = 0;
parameter AFI_CS_WIDTH				= 0;
parameter AFI_CLK_EN_WIDTH			= 0;
parameter AFI_CONTROL_WIDTH         = 0;
parameter AFI_ODT_WIDTH             = 0;
parameter AFI_DQ_WIDTH				= 0;
parameter AFI_WRITE_DQS_WIDTH		= 0;
parameter AFI_RATE_RATIO			= 0;
parameter AFI_WLAT_WIDTH			= 0;
parameter AFI_RLAT_WIDTH			= 0;
parameter AFI_RRANK_WIDTH           = 0;
parameter AFI_WRANK_WIDTH           = 0;
parameter AFI_CLK_PAIR_COUNT		= 0;

parameter MEM_IF_DQ_WIDTH				= 0; 
parameter MEM_IF_DQS_WIDTH				= 0;
parameter MEM_IF_CS_WIDTH				= 0;
parameter MEM_IF_NUMBER_OF_RANKS			= 0;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION

input  wire										afi_clk;
input  wire										afi_reset_n;


output wire	[AFI_ADDR_WIDTH-1 : 0]				phy_addr;
output wire	[AFI_BANKADDR_WIDTH-1 : 0]			phy_ba;
output wire	[AFI_CONTROL_WIDTH-1 : 0]			phy_ras_n;
output wire	[AFI_CONTROL_WIDTH-1 : 0]			phy_cas_n;
output wire	[AFI_CONTROL_WIDTH-1 : 0]			phy_we_n;

output reg	[AFI_CS_WIDTH-1 : 0]				phy_cs_n;
output reg	[AFI_ODT_WIDTH-1 : 0]				phy_odt;
output reg	[AFI_CLK_EN_WIDTH-1 : 0]			phy_cke;
output wire	[AFI_CONTROL_WIDTH-1 : 0]			phy_rst_n;
output wire	[AFI_RATE_RATIO-1 : 0]				phy_rdata_en;
output wire	[AFI_RATE_RATIO-1 : 0]				phy_rdata_en_full;
output wire	[AFI_RATE_RATIO-1 : 0]				phy_rdata_en_1t; 
output wire	[AFI_RATE_RATIO-1 : 0]				phy_rdata_en_full_1t;
output reg	[AFI_WRITE_DQS_WIDTH-1 : 0]			phy_dqs_burst;
output reg	[AFI_WRITE_DQS_WIDTH-1 : 0]			phy_wdata_valid;
output reg	[AFI_DQ_WIDTH-1 : 0]				phy_wdata;
output reg	[AFI_DM_WIDTH-1 : 0]				phy_dm;
output wire										phy_cal_req;
output wire										phy_init_req;
output wire	[AFI_CLK_PAIR_COUNT-1 : 0]  		phy_mem_clk_disable;
output wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]	phy_ctl_refresh_done; 
output wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]	phy_ctl_long_idle;	

input wire	[AFI_WLAT_WIDTH-1 : 0]				phy_wlat;
input wire	[AFI_RLAT_WIDTH-1 : 0]				phy_rlat;
input wire	[AFI_DQ_WIDTH-1 : 0]				phy_rdata;
input wire	[AFI_RATE_RATIO-1 : 0]				phy_rdata_valid;
input wire	[AFI_RATE_RATIO-1 : 0]				phy_rdata_valid_1t;
input wire										phy_cal_success;
input wire										phy_cal_fail;
input wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]	phy_seq_busy;	

output reg	[AFI_WRANK_WIDTH-1:0]				phy_wrank;
output reg	[AFI_RRANK_WIDTH-1:0]				phy_rrank;


input wire	[AFI_ADDR_WIDTH-1 : 0]				ctl_l_addr;		
input wire	[AFI_BANKADDR_WIDTH-1 : 0]			ctl_l_ba;		
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_l_ras_n;	
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_l_cas_n;	
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_l_we_n;		

input wire	[AFI_CS_WIDTH/2 -1 : 0]				ctl_l_cs_n;
input wire	[AFI_ODT_WIDTH/2 -1 : 0]			ctl_l_odt;
input wire	[AFI_CLK_EN_WIDTH/2 -1 : 0]			ctl_l_cke;
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_l_rst_n;	
input wire	[AFI_RATE_RATIO-1 : 0]				ctl_l_rdata_en;
input wire	[AFI_RATE_RATIO-1 : 0]				ctl_l_rdata_en_full;
input wire	[AFI_WRITE_DQS_WIDTH/2 -1 : 0]		ctl_l_dqs_burst;
input wire	[AFI_WRITE_DQS_WIDTH/2 -1 : 0]		ctl_l_wdata_valid;
input wire	[AFI_DQ_WIDTH/2 -1 : 0]				ctl_l_wdata;
input wire	[AFI_DM_WIDTH/2 -1 : 0]				ctl_l_dm;
input wire										ctl_l_cal_req;			
input wire	 									ctl_l_init_req;			
input wire	[AFI_CLK_PAIR_COUNT-1 : 0]  		ctl_l_mem_clk_disable;	
input wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]		ctl_l_ctl_refresh_done; 
input wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]		ctl_l_ctl_long_idle;	

output wire	[AFI_WLAT_WIDTH-1 : 0]				ctl_l_wlat;
output wire	[AFI_RLAT_WIDTH-1 : 0]				ctl_l_rlat;
output reg 	[AFI_DQ_WIDTH/2 -1 : 0]				ctl_l_rdata;
output wire	[AFI_RATE_RATIO-1 : 0]				ctl_l_rdata_valid;
output wire										ctl_l_cal_success;
output wire										ctl_l_cal_fail;
output wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]		ctl_l_seq_busy;	

input wire	[AFI_WRANK_WIDTH/2 -1:0]			ctl_l_wrank;
input wire	[AFI_RRANK_WIDTH/2 -1:0]			ctl_l_rrank;

input wire	[AFI_ADDR_WIDTH-1 : 0]				ctl_r_addr;		
input wire	[AFI_BANKADDR_WIDTH-1 : 0]			ctl_r_ba;		
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_r_ras_n;	
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_r_cas_n;	
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_r_we_n;		

input wire	[AFI_CS_WIDTH/2 -1 : 0]				ctl_r_cs_n;
input wire	[AFI_ODT_WIDTH/2 -1 : 0]			ctl_r_odt;
input wire	[AFI_CLK_EN_WIDTH/2 -1 : 0]			ctl_r_cke;
input wire	[AFI_CONTROL_WIDTH-1 : 0]			ctl_r_rst_n;	
input wire	[AFI_RATE_RATIO-1 : 0]				ctl_r_rdata_en;
input wire	[AFI_RATE_RATIO-1 : 0]				ctl_r_rdata_en_full;
input wire	[AFI_WRITE_DQS_WIDTH/2 -1 : 0]		ctl_r_dqs_burst;
input wire	[AFI_WRITE_DQS_WIDTH/2 -1 : 0]		ctl_r_wdata_valid;
input wire	[AFI_DQ_WIDTH/2 -1 : 0]				ctl_r_wdata;
input wire	[AFI_DM_WIDTH/2 -1 : 0]				ctl_r_dm;
input wire										ctl_r_cal_req;
input wire	 									ctl_r_init_req;
input wire	[AFI_CLK_PAIR_COUNT-1 : 0]  		ctl_r_mem_clk_disable;
input wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]		ctl_r_ctl_refresh_done; 
input wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]		ctl_r_ctl_long_idle;	

output wire	[AFI_WLAT_WIDTH-1 : 0]				ctl_r_wlat;
output wire	[AFI_RLAT_WIDTH-1 : 0]				ctl_r_rlat;
output reg	[AFI_DQ_WIDTH/2 -1 : 0]				ctl_r_rdata;
output wire	[AFI_RATE_RATIO-1 : 0]				ctl_r_rdata_valid;
output wire 									ctl_r_cal_success;
output wire 									ctl_r_cal_fail;
output wire	[MEM_IF_NUMBER_OF_RANKS   -1 : 0]		ctl_r_seq_busy;	

input wire	[AFI_WRANK_WIDTH/2 -1:0]			ctl_r_wrank;
input wire	[AFI_RRANK_WIDTH/2 -1:0]			ctl_r_rrank;


// END PORT SECTION


integer dqs_gp_num;
integer beat;

assign ctl_l_wlat       	= phy_wlat;
assign ctl_r_wlat        	= phy_wlat;
assign ctl_l_rlat       	= phy_rlat;
assign ctl_r_rlat        	= phy_rlat;
assign ctl_l_cal_success	= phy_cal_success;
assign ctl_r_cal_success 	= phy_cal_success;
assign ctl_l_cal_fail 		= phy_cal_fail;
assign ctl_r_cal_fail 		= phy_cal_fail;

assign phy_rst_n = ctl_l_rst_n & ctl_r_rst_n; 
assign phy_cal_req = ctl_l_cal_req | ctl_r_cal_req;
assign phy_init_req = ctl_l_init_req | ctl_r_init_req;
assign phy_mem_clk_disable = ctl_l_mem_clk_disable & ctl_r_mem_clk_disable;
assign phy_ctl_refresh_done = ctl_l_ctl_refresh_done & ctl_r_ctl_refresh_done;
assign phy_ctl_long_idle = ctl_l_ctl_long_idle & ctl_r_ctl_long_idle;
assign ctl_l_seq_busy = phy_seq_busy;
assign ctl_r_seq_busy = phy_seq_busy;

reg [AFI_ADDR_WIDTH/AFI_RATE_RATIO -1 : 0]			ctl_r_addr_1t;
reg [AFI_BANKADDR_WIDTH/AFI_RATE_RATIO -1 : 0]		ctl_r_ba_1t;
reg [AFI_CONTROL_WIDTH/AFI_RATE_RATIO -1 : 0]		ctl_r_cas_n_1t;
reg [AFI_CONTROL_WIDTH/AFI_RATE_RATIO -1 : 0]		ctl_r_ras_n_1t;
reg [AFI_CONTROL_WIDTH/AFI_RATE_RATIO -1 : 0]		ctl_r_we_n_1t;

always @ (posedge afi_clk or negedge afi_reset_n)
begin
    if (afi_reset_n == 1'b0) begin
         ctl_r_addr_1t   <= 0;
         ctl_r_ba_1t     <= 0;
         ctl_r_cas_n_1t  <= 0;
         ctl_r_ras_n_1t  <= 0;
         ctl_r_we_n_1t   <= 0;
    end
    else
    begin
         ctl_r_addr_1t  <= ctl_r_addr[AFI_ADDR_WIDTH-1 : AFI_ADDR_WIDTH - AFI_ADDR_WIDTH/AFI_RATE_RATIO];
         ctl_r_ba_1t    <= ctl_r_ba[AFI_BANKADDR_WIDTH-1 : AFI_BANKADDR_WIDTH - AFI_BANKADDR_WIDTH/AFI_RATE_RATIO];
         ctl_r_cas_n_1t <= ctl_r_cas_n[AFI_CONTROL_WIDTH-1 : AFI_CONTROL_WIDTH - AFI_CONTROL_WIDTH/AFI_RATE_RATIO];
         ctl_r_ras_n_1t <= ctl_r_ras_n[AFI_CONTROL_WIDTH-1 : AFI_CONTROL_WIDTH - AFI_CONTROL_WIDTH/AFI_RATE_RATIO];
         ctl_r_we_n_1t  <= ctl_r_we_n[AFI_CONTROL_WIDTH-1 : AFI_CONTROL_WIDTH - AFI_CONTROL_WIDTH/AFI_RATE_RATIO];
    end
end

localparam ADDR_WIDTH_QUARTER = AFI_ADDR_WIDTH/AFI_RATE_RATIO; 
assign phy_addr = {	ctl_l_addr[(ADDR_WIDTH_QUARTER*4)-1 : ADDR_WIDTH_QUARTER*3],
					ctl_r_addr[(ADDR_WIDTH_QUARTER*2)-1 : ADDR_WIDTH_QUARTER*1],
					ctl_l_addr[(ADDR_WIDTH_QUARTER*2)-1 : ADDR_WIDTH_QUARTER*1],
					ctl_r_addr_1t[(ADDR_WIDTH_QUARTER*1)-1 : 0]
				  };

localparam BANKADDR_WIDTH_QUARTER = AFI_BANKADDR_WIDTH/AFI_RATE_RATIO; 
assign phy_ba = {	ctl_l_ba[(BANKADDR_WIDTH_QUARTER*4)-1 : BANKADDR_WIDTH_QUARTER*3],
					ctl_r_ba[(BANKADDR_WIDTH_QUARTER*2)-1 : BANKADDR_WIDTH_QUARTER*1],
					ctl_l_ba[(BANKADDR_WIDTH_QUARTER*2)-1 : BANKADDR_WIDTH_QUARTER*1],
					ctl_r_ba_1t[(BANKADDR_WIDTH_QUARTER*1)-1 : 0]
				};

assign phy_cas_n = {ctl_l_cas_n[3], ctl_r_cas_n[1], ctl_l_cas_n[1], ctl_r_cas_n_1t};
assign phy_ras_n = {ctl_l_ras_n[3], ctl_r_ras_n[1], ctl_l_ras_n[1], ctl_r_ras_n_1t};
assign phy_we_n = {ctl_l_we_n[3], ctl_r_we_n[1], ctl_l_we_n[1], ctl_r_we_n_1t};


localparam CS_WIDTH_PER_SIDE = AFI_CS_WIDTH/AFI_RATE_RATIO/2;
localparam ODT_WIDTH_PER_SIDE = AFI_ODT_WIDTH/AFI_RATE_RATIO/2;
localparam CLK_EN_WIDTH_PER_SIDE = AFI_CLK_EN_WIDTH/AFI_RATE_RATIO/2;
wire [AFI_CS_WIDTH/2 -1 : 0]		ctl_r_cs_n_1t;
wire [AFI_ODT_WIDTH/2 -1 : 0]		ctl_r_odt_1t;
wire [AFI_CLK_EN_WIDTH/2 -1 : 0]	ctl_r_cke_1t;

fr_cycle_shifter_qr odt_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_odt),
		.dataout (ctl_r_odt_1t)
	);
	defparam odt_shifter.DATA_WIDTH = ODT_WIDTH_PER_SIDE;
	defparam odt_shifter.REG_POST_RESET_HIGH = "false";

fr_cycle_shifter_qr cke_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_cke),
		.dataout (ctl_r_cke_1t)
	);
	defparam cke_shifter.DATA_WIDTH = CLK_EN_WIDTH_PER_SIDE;
	defparam cke_shifter.REG_POST_RESET_HIGH = "false";

fr_cycle_shifter_qr cs_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_cs_n),
		.dataout (ctl_r_cs_n_1t)
	);
	defparam cs_shifter.DATA_WIDTH = CS_WIDTH_PER_SIDE;
	defparam cs_shifter.REG_POST_RESET_HIGH = "false";



always @(*)
begin
	for (beat=0; beat<AFI_RATE_RATIO; beat=beat+1) begin 
		phy_odt[(2 * ODT_WIDTH_PER_SIDE * beat) +: ODT_WIDTH_PER_SIDE] 
			<= ctl_l_odt[ODT_WIDTH_PER_SIDE * beat +: ODT_WIDTH_PER_SIDE];
		
		phy_cke[(2 * CLK_EN_WIDTH_PER_SIDE * beat) +: CLK_EN_WIDTH_PER_SIDE] 
			<= ctl_l_cke[CLK_EN_WIDTH_PER_SIDE * beat +: CLK_EN_WIDTH_PER_SIDE];
		
		phy_cs_n[(2 * CS_WIDTH_PER_SIDE * beat) +: CS_WIDTH_PER_SIDE] 
			<= ctl_l_cs_n[CS_WIDTH_PER_SIDE * beat +: CS_WIDTH_PER_SIDE];
	end

	for (beat=0; beat<AFI_RATE_RATIO; beat=beat+1) begin
		phy_odt[(2 * ODT_WIDTH_PER_SIDE * beat) + ODT_WIDTH_PER_SIDE +: ODT_WIDTH_PER_SIDE]
			<= ctl_r_odt_1t[ODT_WIDTH_PER_SIDE * beat +: ODT_WIDTH_PER_SIDE];
		
		phy_cke[(2 * CLK_EN_WIDTH_PER_SIDE * beat) + CLK_EN_WIDTH_PER_SIDE +: CLK_EN_WIDTH_PER_SIDE]
			<= ctl_r_cke_1t[CLK_EN_WIDTH_PER_SIDE * beat +: CLK_EN_WIDTH_PER_SIDE];
		
		phy_cs_n[(2 * CS_WIDTH_PER_SIDE * beat) + CS_WIDTH_PER_SIDE +: CS_WIDTH_PER_SIDE]
			<= ctl_r_cs_n_1t[CS_WIDTH_PER_SIDE * beat +: CS_WIDTH_PER_SIDE];
	end
end


wire [AFI_DQ_WIDTH/2 -1 : 0]		ctl_r_wdata_1t;
wire [AFI_DM_WIDTH/2 -1 : 0]		ctl_r_dm_1t;

fr_cycle_shifter_qr wdata_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_wdata),
		.dataout (ctl_r_wdata_1t)
	);
	defparam wdata_shifter.DATA_WIDTH = AFI_DQ_WIDTH/2/AFI_RATE_RATIO; 
	defparam wdata_shifter.REG_POST_RESET_HIGH = "false";

fr_cycle_shifter_qr dm_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_dm),
		.dataout (ctl_r_dm_1t)
	);
	defparam dm_shifter.DATA_WIDTH = AFI_DM_WIDTH/2/AFI_RATE_RATIO;
	defparam dm_shifter.REG_POST_RESET_HIGH = "false";


localparam DQ_WIDTH_PER_SIDE = AFI_DQ_WIDTH/2/AFI_RATE_RATIO/2; 
localparam DM_WIDTH_PER_SIDE = AFI_DM_WIDTH/2/AFI_RATE_RATIO/2; 
always @(*)
begin
	for (beat=0; beat< AFI_RATE_RATIO*2; beat =beat + 1) begin 
		phy_wdata[(2 * DQ_WIDTH_PER_SIDE * beat) +: DQ_WIDTH_PER_SIDE]
			<= ctl_l_wdata[DQ_WIDTH_PER_SIDE * beat +: DQ_WIDTH_PER_SIDE];

		phy_dm [(2 * DM_WIDTH_PER_SIDE * beat) +: DM_WIDTH_PER_SIDE]
			<= ctl_l_dm[DM_WIDTH_PER_SIDE * beat +: DM_WIDTH_PER_SIDE];
	end

	for (beat=0; beat< AFI_RATE_RATIO*2; beat =beat + 1) begin
		phy_wdata[(2 * DQ_WIDTH_PER_SIDE * beat + DQ_WIDTH_PER_SIDE) +: DQ_WIDTH_PER_SIDE]
			<= ctl_r_wdata_1t[DQ_WIDTH_PER_SIDE * beat +: DQ_WIDTH_PER_SIDE];
		
		phy_dm [(2 * DM_WIDTH_PER_SIDE * beat + DM_WIDTH_PER_SIDE) +: DM_WIDTH_PER_SIDE]
			<= ctl_r_dm_1t[DM_WIDTH_PER_SIDE * beat +: DM_WIDTH_PER_SIDE];
	end
end


localparam WRITE_DQS_WIDTH_PER_SIDE = AFI_WRITE_DQS_WIDTH/2/AFI_RATE_RATIO;
wire [AFI_WRITE_DQS_WIDTH/2 -1 : 0]				ctl_r_dqs_burst_1t;
wire [AFI_WRITE_DQS_WIDTH/2 -1 : 0]				ctl_r_wdata_valid_1t;
	
fr_cycle_shifter_qr wdata_valid_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_wdata_valid),
		.dataout (ctl_r_wdata_valid_1t)
	);
	defparam wdata_valid_shifter.DATA_WIDTH = WRITE_DQS_WIDTH_PER_SIDE;
	defparam wdata_valid_shifter.REG_POST_RESET_HIGH = "false";

fr_cycle_shifter_qr dqs_burst_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_dqs_burst),
		.dataout (ctl_r_dqs_burst_1t)
	);
	defparam dqs_burst_shifter.DATA_WIDTH = WRITE_DQS_WIDTH_PER_SIDE;
	defparam dqs_burst_shifter.REG_POST_RESET_HIGH = "false";

always @(*)
begin
	for (beat=0; beat< AFI_RATE_RATIO; beat =beat + 1) begin 
		phy_dqs_burst[(2 * WRITE_DQS_WIDTH_PER_SIDE * beat) +: WRITE_DQS_WIDTH_PER_SIDE] 
			<= ctl_l_dqs_burst[WRITE_DQS_WIDTH_PER_SIDE * beat +: WRITE_DQS_WIDTH_PER_SIDE];
		phy_wdata_valid[(2 * WRITE_DQS_WIDTH_PER_SIDE * beat) +: WRITE_DQS_WIDTH_PER_SIDE]
			<= ctl_l_wdata_valid[WRITE_DQS_WIDTH_PER_SIDE * beat +: WRITE_DQS_WIDTH_PER_SIDE];
	end

	for (beat=0; beat< AFI_RATE_RATIO; beat =beat + 1) begin
		phy_dqs_burst[(2 * WRITE_DQS_WIDTH_PER_SIDE * beat + WRITE_DQS_WIDTH_PER_SIDE) +: WRITE_DQS_WIDTH_PER_SIDE] 
			<= ctl_r_dqs_burst_1t[WRITE_DQS_WIDTH_PER_SIDE * beat +: WRITE_DQS_WIDTH_PER_SIDE];
		phy_wdata_valid[(2 * WRITE_DQS_WIDTH_PER_SIDE * beat + WRITE_DQS_WIDTH_PER_SIDE) +: WRITE_DQS_WIDTH_PER_SIDE] 
			<= ctl_r_wdata_valid_1t[WRITE_DQS_WIDTH_PER_SIDE * beat +: WRITE_DQS_WIDTH_PER_SIDE];
	end
end

localparam WRANK_WIDTH_PER_SIDE = AFI_WRANK_WIDTH/2/AFI_RATE_RATIO;
localparam RRANK_WIDTH_PER_SIDE = AFI_RRANK_WIDTH/2/AFI_RATE_RATIO;
wire [AFI_WRANK_WIDTH/2 -1 : 0]		ctl_r_wrank_1t;
wire [AFI_RRANK_WIDTH/2 -1 : 0]		ctl_r_rrank_1t;

fr_cycle_shifter_qr wrank_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_wrank),
		.dataout (ctl_r_wrank_1t)
	);
	defparam wrank_shifter.DATA_WIDTH = WRANK_WIDTH_PER_SIDE;
	defparam wrank_shifter.REG_POST_RESET_HIGH = "false";

fr_cycle_shifter_qr rrank_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_rrank),
		.dataout (ctl_r_rrank_1t)
	);
	defparam rrank_shifter.DATA_WIDTH = RRANK_WIDTH_PER_SIDE;
	defparam rrank_shifter.REG_POST_RESET_HIGH = "false";


always @ (*)
begin
	for (beat=0; beat< AFI_RATE_RATIO; beat =beat + 1) begin 
		phy_wrank[(2 * WRANK_WIDTH_PER_SIDE * beat) +: WRANK_WIDTH_PER_SIDE] 
			<= ctl_l_wrank[WRANK_WIDTH_PER_SIDE * beat +: WRANK_WIDTH_PER_SIDE];
		phy_rrank[(2 * RRANK_WIDTH_PER_SIDE * beat) +: RRANK_WIDTH_PER_SIDE] 
			<= ctl_l_rrank[RRANK_WIDTH_PER_SIDE * beat +: RRANK_WIDTH_PER_SIDE];
	end

	for (beat=0; beat< AFI_RATE_RATIO; beat =beat + 1) begin 
		phy_wrank[(2 * WRANK_WIDTH_PER_SIDE * beat + WRANK_WIDTH_PER_SIDE) +: WRANK_WIDTH_PER_SIDE] 
			<= ctl_r_wrank_1t[WRANK_WIDTH_PER_SIDE * beat +: WRANK_WIDTH_PER_SIDE];
		phy_rrank[(2 * RRANK_WIDTH_PER_SIDE * beat + RRANK_WIDTH_PER_SIDE) +: RRANK_WIDTH_PER_SIDE] 
			<= ctl_r_rrank_1t[RRANK_WIDTH_PER_SIDE * beat +: RRANK_WIDTH_PER_SIDE];
	end
end

assign phy_rdata_en = ctl_l_rdata_en;
assign phy_rdata_en_full = ctl_l_rdata_en_full;

fr_cycle_shifter_qr ctl_r_rdata_en_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_rdata_en),
		.dataout (phy_rdata_en_1t)
	);
	defparam ctl_r_rdata_en_shifter.DATA_WIDTH = 1; 
	defparam ctl_r_rdata_en_shifter.REG_POST_RESET_HIGH = "false";

fr_cycle_shifter_qr ctl_r_rdata_en_full_shifter(
		.clk (afi_clk),
		.reset_n (afi_reset_n),
		.shift_by (2'b01),
		.datain (ctl_r_rdata_en_full),
		.dataout (phy_rdata_en_full_1t)
	);
	defparam ctl_r_rdata_en_full_shifter.DATA_WIDTH = 1;
	defparam ctl_r_rdata_en_full_shifter.REG_POST_RESET_HIGH = "false";



localparam MEM_IF_DQ_PER_DQS 			= MEM_IF_DQ_WIDTH / MEM_IF_DQS_WIDTH;
localparam MEM_IF_DQS_GROUPS_PER_SIDE	= MEM_IF_DQS_WIDTH / 2;
localparam MEM_IF_DQ_WIDTH_PER_SIDE 	= MEM_IF_DQ_WIDTH / 2;
always @(*)
begin
	for (beat=0; beat<AFI_RATE_RATIO*2; beat =beat + 1) begin		
		ctl_l_rdata[(MEM_IF_DQ_WIDTH_PER_SIDE * beat) +: MEM_IF_DQ_WIDTH_PER_SIDE]
			<= phy_rdata[(2 * MEM_IF_DQ_WIDTH_PER_SIDE * beat) +: MEM_IF_DQ_WIDTH_PER_SIDE];
	end

	for (beat=0; beat<AFI_RATE_RATIO*2; beat =beat + 1) begin		
		ctl_r_rdata[(MEM_IF_DQ_WIDTH_PER_SIDE * beat) +: MEM_IF_DQ_WIDTH_PER_SIDE]
			<= phy_rdata[(2 * MEM_IF_DQ_WIDTH_PER_SIDE * beat) + MEM_IF_DQ_WIDTH_PER_SIDE +: MEM_IF_DQ_WIDTH_PER_SIDE];
	end
end


assign ctl_l_rdata_valid = phy_rdata_valid;
assign ctl_r_rdata_valid = phy_rdata_valid_1t;

endmodule
