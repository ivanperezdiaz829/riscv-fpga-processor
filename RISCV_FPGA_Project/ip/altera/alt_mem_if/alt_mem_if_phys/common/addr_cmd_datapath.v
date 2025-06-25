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

module addr_cmd_datapath(
	clk,
	reset_n,
`ifdef QUARTER_RATE
	pll_hr_clk,
	reset_n_hr_clk,
`endif	
	afi_address,
`ifdef RLDRAMX
	afi_bank,
	afi_cas_n,
	afi_cs_n,
	afi_we_n,
 `ifdef RLDRAM3
	afi_rst_n,
 `endif
`endif
`ifdef QDRII
	afi_wps_n,
	afi_rps_n,
	afi_doff_n,
`endif
`ifdef DDRII_SRAM
	afi_ld_n,
	afi_rw_n,
	afi_doff_n,
`endif
`ifdef DDRX
	afi_bank,
	afi_cs_n,
	afi_cke,
	afi_odt,
	afi_ras_n,
	afi_cas_n,
	afi_we_n,
	`ifdef DDR3
	afi_rst_n,
	`endif
`endif
`ifdef LPDDR2
	afi_cs_n,
	afi_cke,
`endif
	phy_ddio_address,
`ifdef RLDRAMX
 `ifdef RLDRAM3
	phy_ddio_reset_n,
 `endif
	phy_ddio_bank,
	phy_ddio_ref_n,
	phy_ddio_cs_n,
	phy_ddio_we_n
`endif
`ifdef QDRII
	phy_ddio_wps_n,
	phy_ddio_rps_n,
	phy_ddio_doff_n
`endif
`ifdef DDRII_SRAM 
	phy_ddio_ld_n,
	phy_ddio_rw_n,
	phy_ddio_doff_n
`endif
`ifdef DDRX
	phy_ddio_bank,
	phy_ddio_cs_n,
	phy_ddio_cke,	
	phy_ddio_we_n,
	phy_ddio_ras_n,
	phy_ddio_cas_n,
	`ifdef AC_PARITY
	phy_ddio_ac_par,
	`endif
	`ifdef DDR3
	phy_ddio_reset_n,
	`endif
	phy_ddio_odt
`endif
`ifdef LPDDR2
	phy_ddio_cs_n,
	phy_ddio_cke
`endif
);


parameter MEM_ADDRESS_WIDTH     = ""; 
`ifdef RLDRAMX
parameter MEM_BANK_WIDTH        = ""; 
parameter MEM_CHIP_SELECT_WIDTH = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter MEM_BANK_WIDTH        = ""; 
parameter MEM_CHIP_SELECT_WIDTH = ""; 
parameter MEM_CLK_EN_WIDTH 		= ""; 
parameter MEM_ODT_WIDTH 		= ""; 
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
parameter AFI_CLK_EN_WIDTH     		= ""; 
parameter AFI_ODT_WIDTH     		= ""; 
`endif
parameter AFI_DATA_MASK_WIDTH       = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 
parameter AFI_DATA_WIDTH            = ""; 

parameter NUM_AC_FR_CYCLE_SHIFTS    = "";

`ifdef FULL_RATE
localparam RATE_MULT = 1;
`endif
`ifdef HALF_RATE
localparam RATE_MULT = 2;
`endif
`ifdef QUARTER_RATE
localparam RATE_MULT = 4;
`endif


input	reset_n;
input	clk;
`ifdef QUARTER_RATE
input	pll_hr_clk;
input	reset_n_hr_clk;
`endif
input	[AFI_ADDRESS_WIDTH-1:0]	afi_address;
`ifdef RLDRAMX
input	[AFI_BANK_WIDTH-1:0] afi_bank;
input	[AFI_CONTROL_WIDTH-1:0]	afi_cas_n;
input	[AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n;
input	[AFI_CONTROL_WIDTH-1:0]	afi_we_n;
 `ifdef RLDRAM3
input	[AFI_CONTROL_WIDTH-1:0]	afi_rst_n; 
 `endif
`endif
`ifdef QDRII
input	[AFI_CONTROL_WIDTH-1:0] afi_wps_n;
input	[AFI_CONTROL_WIDTH-1:0] afi_rps_n;
input	[AFI_CONTROL_WIDTH-1:0] afi_doff_n;
`endif
`ifdef DDRII_SRAM 
input	[AFI_CONTROL_WIDTH-1:0] afi_ld_n;
input	[AFI_CONTROL_WIDTH-1:0] afi_rw_n;
input	[AFI_CONTROL_WIDTH-1:0] afi_doff_n;
`endif
`ifdef DDRX
input   [AFI_BANK_WIDTH-1:0] afi_bank;
input   [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n;
input   [AFI_CLK_EN_WIDTH-1:0] afi_cke;
input   [AFI_ODT_WIDTH-1:0] afi_odt;
input   [AFI_CONTROL_WIDTH-1:0] afi_ras_n;
input   [AFI_CONTROL_WIDTH-1:0] afi_cas_n;
input   [AFI_CONTROL_WIDTH-1:0] afi_we_n;
	`ifdef DDR3
input   [AFI_CONTROL_WIDTH-1:0] afi_rst_n;
	`endif
`endif
`ifdef LPDDR2
input   [AFI_CLK_EN_WIDTH-1:0] afi_cke;
input   [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n;
`endif

output	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;
`ifdef RLDRAMX
output	[AFI_BANK_WIDTH-1:0] phy_ddio_bank;
output	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_ref_n;
output	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
output	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_we_n;
 `ifdef RLDRAM3
output	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_reset_n;
 `endif
`endif
`ifdef QDRII
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;
`endif
`ifdef DDRII_SRAM 
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ld_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rw_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;
`endif
`ifdef DDRX
output	[AFI_BANK_WIDTH-1:0] phy_ddio_bank;
output	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
output	[AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;
output	[AFI_ODT_WIDTH-1:0] phy_ddio_odt;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ras_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_cas_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_we_n;
	`ifdef AC_PARITY
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_ac_par;
	`endif
	`ifdef DDR3
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_reset_n;
	`endif
`endif
`ifdef LPDDR2
output	[AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;
output	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
`endif

`ifdef ADDR_CMD_PATH_FLOP_STAGE_POST_MUX
	// some bits of afi_address are tied low during calibration (only a few addresses are used for calibration)
	// the purpose of the assignment is to avoid Quartus from connecting the signal to the sclr pin of the flop
	// sclr pin is very slow and causes timing failures
	(* altera_attribute = {"-name ALLOW_SYNCH_CTRL_USAGE OFF"}*) reg [AFI_ADDRESS_WIDTH-1:0] afi_address_r;
	`ifdef RLDRAMX
	reg [AFI_BANK_WIDTH-1:0] afi_bank_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_cas_n_r;
	reg [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_we_n_r;
		`ifdef RLDRAM3
	reg [AFI_CONTROL_WIDTH-1:0] afi_rst_n_r;
		`endif
	`endif
	`ifdef QDRII
	reg [AFI_CONTROL_WIDTH-1:0] afi_wps_n_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_rps_n_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_doff_n_r;
	`endif
	`ifdef DDRII_SRAM 
	reg [AFI_CONTROL_WIDTH-1:0] afi_ld_n_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_rw_n_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_doff_n_r;
	`endif
	`ifdef DDRX
	reg [AFI_BANK_WIDTH-1:0] afi_bank_r;
	reg [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_r;
	reg [AFI_CLK_EN_WIDTH-1:0] afi_cke_r;
	reg [AFI_ODT_WIDTH-1:0] afi_odt_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_ras_n_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_cas_n_r;
	reg [AFI_CONTROL_WIDTH-1:0] afi_we_n_r;
		`ifdef DDR3
	reg [AFI_CONTROL_WIDTH-1:0] afi_rst_n_r;
		`endif
	`endif
	`ifdef LPDDR2
	reg [AFI_CLK_EN_WIDTH-1:0] afi_cke_r;
	reg [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_r;
	`endif
		
	always @(posedge clk)
	begin
		afi_address_r <= afi_address;
	`ifdef RLDRAMX
		afi_bank_r <= afi_bank;
		afi_cas_n_r <= afi_cas_n;
		afi_cs_n_r <= afi_cs_n;
		afi_we_n_r <= afi_we_n;
		`ifdef RLDRAM3
		afi_rst_n_r <= afi_rst_n;
		`endif
	`endif
	`ifdef QDRII
		afi_wps_n_r <= afi_wps_n;
		afi_rps_n_r <= afi_rps_n;
		afi_doff_n_r <= afi_doff_n;
	`endif
	`ifdef DDRII_SRAM 
		afi_ld_n_r <= afi_ld_n;
		afi_rw_n_r <= afi_rw_n;
		afi_doff_n_r <= afi_doff_n;
	`endif
	`ifdef DDRX
		afi_bank_r <= afi_bank;
		afi_cs_n_r <= afi_cs_n;
		afi_cke_r <= afi_cke;
		afi_odt_r <= afi_odt;
		afi_ras_n_r <= afi_ras_n;
		afi_cas_n_r <= afi_cas_n;
		afi_we_n_r <= afi_we_n;
		`ifdef DDR3
		afi_rst_n_r <= afi_rst_n;
		`endif
	`endif
	`ifdef LPDDR2
		afi_cke_r <= afi_cke;
		afi_cs_n_r <= afi_cs_n;
	`endif
	end
`else
	wire [AFI_ADDRESS_WIDTH-1:0] afi_address_r = afi_address;
	`ifdef RLDRAMX
	wire [AFI_BANK_WIDTH-1:0] afi_bank_r = afi_bank;
	wire [AFI_CONTROL_WIDTH-1:0] afi_cas_n_r = afi_cas_n;
	wire [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_r = afi_cs_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_we_n_r = afi_we_n;
		`ifdef RLDRAM3
	wire [AFI_CONTROL_WIDTH-1:0] afi_rst_n_r = afi_rst_n;
		`endif
	`endif
	`ifdef QDRII
	wire [AFI_CONTROL_WIDTH-1:0] afi_wps_n_r = afi_wps_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_rps_n_r = afi_rps_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_doff_n_r = afi_doff_n;
	`endif
	`ifdef DDRII_SRAM 
	wire [AFI_CONTROL_WIDTH-1:0] afi_ld_n_r = afi_ld_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_rw_n_r = afi_rw_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_doff_n_r = afi_doff_n;
	`endif
	`ifdef DDRX
	wire [AFI_BANK_WIDTH-1:0] afi_bank_r = afi_bank;
	wire [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_r = afi_cs_n;
	wire [AFI_CLK_EN_WIDTH-1:0] afi_cke_r = afi_cke;
	wire [AFI_ODT_WIDTH-1:0] afi_odt_r = afi_odt;
	wire [AFI_CONTROL_WIDTH-1:0] afi_ras_n_r = afi_ras_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_cas_n_r = afi_cas_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_we_n_r = afi_we_n;
		`ifdef DDR3
	wire [AFI_CONTROL_WIDTH-1:0] afi_rst_n_r = afi_rst_n;
		`endif
	`endif
	`ifdef LPDDR2
	wire [AFI_CLK_EN_WIDTH-1:0] afi_cke_r = afi_cke;
	wire [AFI_CHIP_SELECT_WIDTH-1:0] afi_cs_n_r = afi_cs_n;	
	`endif
`endif


	wire [1:0] shift_fr_cycle = 
		(NUM_AC_FR_CYCLE_SHIFTS == 0) ? 	2'b00 : (
		(NUM_AC_FR_CYCLE_SHIFTS == 1) ? 	2'b01 : (
		(NUM_AC_FR_CYCLE_SHIFTS == 2) ? 	2'b10 : (
											2'b11 )));

	fr_cycle_shifter uaddr_cmd_shift_address(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_address_r),
		.dataout (phy_ddio_address)
	);
`ifdef LPDDR2
	defparam uaddr_cmd_shift_address.DATA_WIDTH = MEM_ADDRESS_WIDTH * 2;
`else
	`ifdef QDRII
		`ifdef BURST2
	defparam uaddr_cmd_shift_address.DATA_WIDTH = MEM_ADDRESS_WIDTH * 2;
		`else
	defparam uaddr_cmd_shift_address.DATA_WIDTH = MEM_ADDRESS_WIDTH;
		`endif
	`else
	defparam uaddr_cmd_shift_address.DATA_WIDTH = MEM_ADDRESS_WIDTH;
	`endif
`endif
	defparam uaddr_cmd_shift_address.REG_POST_RESET_HIGH = "false";

`ifdef RLDRAMX
	fr_cycle_shifter uaddr_cmd_shift_bank(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_bank_r),
		.dataout (phy_ddio_bank)
	);
	defparam uaddr_cmd_shift_bank.DATA_WIDTH = MEM_BANK_WIDTH;
	defparam uaddr_cmd_shift_bank.REG_POST_RESET_HIGH = "false";

	fr_cycle_shifter uaddr_cmd_shift_cs_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_cs_n_r),
		.dataout (phy_ddio_cs_n)
	);
	defparam uaddr_cmd_shift_cs_n.DATA_WIDTH = MEM_CHIP_SELECT_WIDTH;
	defparam uaddr_cmd_shift_cs_n.REG_POST_RESET_HIGH = "true";

	fr_cycle_shifter uaddr_cmd_shift_we_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_we_n_r),
		.dataout (phy_ddio_we_n)
	);
	defparam uaddr_cmd_shift_we_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_we_n.REG_POST_RESET_HIGH = "true";

	fr_cycle_shifter uaddr_cmd_shift_cas_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_cas_n_r),
		.dataout (phy_ddio_ref_n)
	);
	defparam uaddr_cmd_shift_cas_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_cas_n.REG_POST_RESET_HIGH = "true";
	
 `ifdef RLDRAM3
	fr_cycle_shifter uaddr_cmd_shift_rst_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_rst_n_r),
		.dataout (phy_ddio_reset_n)
	);
	defparam uaddr_cmd_shift_rst_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_rst_n.REG_POST_RESET_HIGH = "true"; 
 `endif
`endif

`ifdef QDRII
	fr_cycle_shifter uaddr_cmd_shift_wps_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_wps_n_r),
		.dataout (phy_ddio_wps_n)
	);
	`ifdef BURST2
	defparam uaddr_cmd_shift_wps_n.DATA_WIDTH = MEM_CONTROL_WIDTH * 2;
	`else
	defparam uaddr_cmd_shift_wps_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	`endif
	defparam uaddr_cmd_shift_wps_n.REG_POST_RESET_HIGH = "true";

	fr_cycle_shifter uaddr_cmd_shift_rps_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_rps_n_r),
		.dataout (phy_ddio_rps_n)
	);
	`ifdef BURST2
	defparam uaddr_cmd_shift_rps_n.DATA_WIDTH = MEM_CONTROL_WIDTH * 2;
	`else
	defparam uaddr_cmd_shift_rps_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	`endif
	defparam uaddr_cmd_shift_rps_n.REG_POST_RESET_HIGH = "true";

	assign phy_ddio_doff_n = afi_doff_n_r;
`endif

`ifdef DDRII_SRAM
	fr_cycle_shifter uaddr_cmd_shift_ld_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_ld_n_r),
		.dataout (phy_ddio_ld_n)
	);
	defparam uaddr_cmd_shift_ld_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_ld_n.REG_POST_RESET_HIGH = "true";

	fr_cycle_shifter uaddr_cmd_shift_rw_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_rw_n_r),
		.dataout (phy_ddio_rw_n)
	);
	defparam uaddr_cmd_shift_rw_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_rw_n.REG_POST_RESET_HIGH = "true";

	assign phy_ddio_doff_n = afi_doff_n_r;
`endif

`ifdef DDRX
	fr_cycle_shifter uaddr_cmd_shift_bank(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_bank_r),
		.dataout (phy_ddio_bank)
	);
	defparam uaddr_cmd_shift_bank.DATA_WIDTH = MEM_BANK_WIDTH;
	defparam uaddr_cmd_shift_bank.REG_POST_RESET_HIGH = "false";

	fr_cycle_shifter uaddr_cmd_shift_cke(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_cke_r),
		.dataout (phy_ddio_cke)
	);
	defparam uaddr_cmd_shift_cke.DATA_WIDTH = MEM_CLK_EN_WIDTH;
	defparam uaddr_cmd_shift_cke.REG_POST_RESET_HIGH = "false";
	
	fr_cycle_shifter uaddr_cmd_shift_cs_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_cs_n_r),
		.dataout (phy_ddio_cs_n)
	);
	defparam uaddr_cmd_shift_cs_n.DATA_WIDTH = MEM_CHIP_SELECT_WIDTH;
	defparam uaddr_cmd_shift_cs_n.REG_POST_RESET_HIGH = "true";	

	fr_cycle_shifter uaddr_cmd_shift_odt(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_odt_r),
		.dataout (phy_ddio_odt)
	);
	defparam uaddr_cmd_shift_odt.DATA_WIDTH = MEM_ODT_WIDTH;
	defparam uaddr_cmd_shift_odt.REG_POST_RESET_HIGH = "false";		
	
	fr_cycle_shifter uaddr_cmd_shift_ras_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_ras_n_r),
		.dataout (phy_ddio_ras_n)
	);
	defparam uaddr_cmd_shift_ras_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_ras_n.REG_POST_RESET_HIGH = "true";	
	
	fr_cycle_shifter uaddr_cmd_shift_cas_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_cas_n_r),
		.dataout (phy_ddio_cas_n)
	);
	defparam uaddr_cmd_shift_cas_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_cas_n.REG_POST_RESET_HIGH = "true";

	fr_cycle_shifter uaddr_cmd_shift_we_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_we_n_r),
		.dataout (phy_ddio_we_n)
	);
	defparam uaddr_cmd_shift_we_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_we_n.REG_POST_RESET_HIGH = "true";	
	
	`ifdef DDR3
	fr_cycle_shifter uaddr_cmd_shift_rst_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_rst_n_r),
		.dataout (phy_ddio_reset_n)
	);
	defparam uaddr_cmd_shift_rst_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_rst_n.REG_POST_RESET_HIGH = "true";		
	`endif
`endif

`ifdef LPDDR2
	fr_cycle_shifter uaddr_cmd_shift_cke(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_cke_r),
		.dataout (phy_ddio_cke)
	);
	defparam uaddr_cmd_shift_cke.DATA_WIDTH = MEM_CLK_EN_WIDTH;
	defparam uaddr_cmd_shift_cke.REG_POST_RESET_HIGH = "false";
	
	fr_cycle_shifter uaddr_cmd_shift_cs_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_cs_n_r),
		.dataout (phy_ddio_cs_n)
	);
	defparam uaddr_cmd_shift_cs_n.DATA_WIDTH = MEM_CHIP_SELECT_WIDTH;
	defparam uaddr_cmd_shift_cs_n.REG_POST_RESET_HIGH = "true";
`endif

`ifdef DDRX
	`ifdef AC_PARITY
	wire [AFI_CONTROL_WIDTH-1:0] ac_par;
	
	generate
	genvar timeslot;
	for (timeslot=0; timeslot<RATE_MULT; timeslot=timeslot+1)
	begin: ac_parity_mapping_timeslot
		wire [MEM_ADDRESS_WIDTH-1:0] phy_ddio_address_slot = phy_ddio_address [(MEM_ADDRESS_WIDTH*(timeslot+1))-1 : MEM_ADDRESS_WIDTH*timeslot];
		wire [MEM_BANK_WIDTH-1:0] phy_ddio_bank_slot = phy_ddio_bank [(MEM_BANK_WIDTH*(timeslot+1))-1 : MEM_BANK_WIDTH*timeslot];
		wire [MEM_CONTROL_WIDTH-1:0] phy_ddio_ras_n_slot = phy_ddio_ras_n [(MEM_CONTROL_WIDTH*(timeslot+1))-1 : MEM_CONTROL_WIDTH*timeslot];
		wire [MEM_CONTROL_WIDTH-1:0] phy_ddio_cas_n_slot = phy_ddio_cas_n [(MEM_CONTROL_WIDTH*(timeslot+1))-1 : MEM_CONTROL_WIDTH*timeslot];
		wire [MEM_CONTROL_WIDTH-1:0] phy_ddio_we_n_slot = phy_ddio_we_n	[(MEM_CONTROL_WIDTH*(timeslot+1))-1	: MEM_CONTROL_WIDTH*timeslot];
		
		assign ac_par[(MEM_CONTROL_WIDTH*(timeslot+1))-1:MEM_CONTROL_WIDTH*timeslot] = {MEM_CONTROL_WIDTH{^({
			phy_ddio_address_slot, 
			phy_ddio_bank_slot,
			phy_ddio_ras_n_slot,
			phy_ddio_cas_n_slot,
			phy_ddio_we_n_slot})}};
	end
	endgenerate
	
	// Delay ac parity bit by one FR cycle.
	wire [1:0] shift_ac_par_fr_cycle = 2'b01;
	fr_cycle_shifter uaddr_cmd_shift_ac_par(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_ac_par_fr_cycle),
		.datain (ac_par),
		.dataout (phy_ddio_ac_par)
	);
	defparam uaddr_cmd_shift_ac_par.DATA_WIDTH = MEM_CONTROL_WIDTH;
	`endif
`endif
endmodule
