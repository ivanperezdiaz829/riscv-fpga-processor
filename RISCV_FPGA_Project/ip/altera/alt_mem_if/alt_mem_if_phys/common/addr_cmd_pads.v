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

module addr_cmd_pads(
    reset_n,
    reset_n_afi_clk,
    pll_afi_clk,
    pll_mem_clk,
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
    pll_mem_phy_clk,
    pll_afi_phy_clk,
`endif    
    pll_c2p_write_clk,
    pll_write_clk,
    pll_hr_clk,
    phy_ddio_addr_cmd_clk,
    phy_ddio_address,
    dll_delayctrl_in,
    enable_mem_clk,
`ifdef USE_DR_CLK
    pll_dr_clk,
`endif
`ifdef RLDRAMII
    phy_ddio_bank,
    phy_ddio_cs_n,
    phy_ddio_we_n,
    phy_ddio_ref_n,
    phy_mem_address,
    phy_mem_bank,
    phy_mem_cs_n,
    phy_mem_we_n,
    phy_mem_ref_n, 
    phy_mem_ck,
    phy_mem_ck_n
`endif
`ifdef QDRII
    phy_ddio_wps_n,
    phy_ddio_rps_n,
    phy_ddio_doff_n,
    phy_mem_address,
    phy_mem_wps_n,
    phy_mem_rps_n,
    phy_mem_doff_n 
`endif
`ifdef DDRII_SRAM
    phy_ddio_ld_n,
    phy_ddio_rw_n,
    phy_ddio_doff_n,
    phy_mem_address,
    phy_mem_ld_n,
    phy_mem_rw_n,
    phy_mem_zq,
    phy_mem_doff_n
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
`ifndef LPDDR1
    phy_mem_odt,
`endif
    phy_mem_we_n,
    phy_mem_ras_n,
    phy_mem_cas_n,
`ifdef AC_PARITY
    phy_mem_ac_parity,
    phy_err_out_n,
    phy_parity_error_n,
`endif
`ifdef DDR3
    phy_mem_reset_n,
`endif
    phy_mem_ck,
    phy_mem_ck_n
`endif
`ifdef LPDDR2
    phy_ddio_cs_n,
    phy_ddio_cke,
    phy_mem_address,
    phy_mem_cs_n,
    phy_mem_cke,
    phy_mem_ck,
    phy_mem_ck_n
`endif
);

parameter DEVICE_FAMILY = "";
parameter MEM_ADDRESS_WIDTH     = ""; 
`ifdef RLDRAMII
parameter MEM_BANK_WIDTH        = ""; 
parameter MEM_CHIP_SELECT_WIDTH = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter MEM_BANK_WIDTH        = ""; 
parameter MEM_CHIP_SELECT_WIDTH = ""; 
parameter MEM_CLK_EN_WIDTH 		= ""; 
parameter MEM_CK_WIDTH 			= ""; 
parameter MEM_ODT_WIDTH 		= ""; 
`else
localparam MEM_CK_WIDTH 			= 1; 
`endif
parameter MEM_CONTROL_WIDTH     = ""; 

parameter AFI_ADDRESS_WIDTH         = ""; 
`ifdef RLDRAMII
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
parameter AFI_CLK_EN_WIDTH 			= ""; 
parameter AFI_ODT_WIDTH 			= ""; 
`endif
parameter AFI_CONTROL_WIDTH         = ""; 
parameter DLL_WIDTH                 = "";
parameter REGISTER_C2P              = "";
parameter IS_HHP_HPS                = "";

input	reset_n;
input	reset_n_afi_clk;
input	pll_afi_clk;
input	pll_mem_clk;

`ifdef DUPLICATE_PLL_FOR_PHY_CLK
input   pll_mem_phy_clk;
input   pll_afi_phy_clk;
`endif    

input	pll_write_clk;
input	pll_hr_clk;
input	pll_c2p_write_clk;
input	phy_ddio_addr_cmd_clk;
input 	[DLL_WIDTH-1:0] dll_delayctrl_in;
input   [MEM_CK_WIDTH-1:0] enable_mem_clk;

`ifdef USE_DR_CLK
input	pll_dr_clk;
`endif

input	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;
`ifdef RLDRAMII
input	[AFI_BANK_WIDTH-1:0]	phy_ddio_bank;
input	[AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_we_n;
input	[AFI_CONTROL_WIDTH-1:0]	phy_ddio_ref_n;

output	[MEM_ADDRESS_WIDTH-1:0]	phy_mem_address;
output	[MEM_BANK_WIDTH-1:0]	phy_mem_bank;
output	[MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output	[MEM_CONTROL_WIDTH-1:0]	phy_mem_we_n;
output	[MEM_CONTROL_WIDTH-1:0]	phy_mem_ref_n;
output	phy_mem_ck;
output	phy_mem_ck_n;
`endif

`ifdef QDRII
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_wps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_rps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_doff_n;
`endif

`ifdef DDRII_SRAM
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_ld_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_rw_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_ld_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_rw_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_zq;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_doff_n;
`endif

`ifdef DDRX
input   [AFI_BANK_WIDTH-1:0]    phy_ddio_bank;
input   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input   [AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;
    `ifndef LPDDR1
input   [AFI_ODT_WIDTH-1:0] phy_ddio_odt;
	`endif
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_ras_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_cas_n;
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_we_n;
	`ifdef AC_PARITY
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_ac_par;
	`endif
	`ifdef DDR3
input   [AFI_CONTROL_WIDTH-1:0] phy_ddio_reset_n;
	`endif

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_BANK_WIDTH-1:0]    phy_mem_bank;
output  [MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0] phy_mem_cke;
    `ifndef LPDDR1
output  [MEM_ODT_WIDTH-1:0] phy_mem_odt;
	`endif
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_we_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_ras_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_cas_n;
	`ifdef AC_PARITY
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_ac_parity;
input		[MEM_CONTROL_WIDTH-1:0] phy_err_out_n;
output  phy_parity_error_n;
	`endif
	`ifdef DDR3
output  phy_mem_reset_n;
	`endif
output  [MEM_CK_WIDTH-1:0]	phy_mem_ck;
output  [MEM_CK_WIDTH-1:0]	phy_mem_ck_n;
`endif

`ifdef LPDDR2
input   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input   [AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke;

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0] phy_mem_cke;
output  [MEM_CK_WIDTH-1:0]	phy_mem_ck;
output  [MEM_CK_WIDTH-1:0]	phy_mem_ck_n;
`endif

wire	[MEM_ADDRESS_WIDTH-1:0]	address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	address_h;
wire	adc_ldc_ck;
`ifdef DDRX_LPDDRX
wire	[MEM_CHIP_SELECT_WIDTH-1:0] cs_n_l;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] cs_n_h;
wire	[MEM_CLK_EN_WIDTH-1:0] cke_l;
wire	[MEM_CLK_EN_WIDTH-1:0] cke_h;
`endif
`ifdef LPDDR2
wire	hr_seq_clock;
`endif


`ifdef QUARTER_RATE
	`ifdef DDRX
wire   [2*MEM_ADDRESS_WIDTH-1:0] phy_ddio_address_hr;
wire   [2*MEM_BANK_WIDTH-1:0] phy_ddio_bank_hr;
wire   [2*MEM_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_hr;
wire   [2*MEM_CLK_EN_WIDTH-1:0] phy_ddio_cke_hr;
wire   [2*MEM_ODT_WIDTH-1:0] phy_ddio_odt_hr;
wire   [2*MEM_CONTROL_WIDTH-1:0] phy_ddio_ras_n_hr;
wire   [2*MEM_CONTROL_WIDTH-1:0] phy_ddio_cas_n_hr;
wire   [2*MEM_CONTROL_WIDTH-1:0] phy_ddio_we_n_hr;
		`ifdef AC_PARITY
wire   [2*MEM_CONTROL_WIDTH-1:0] phy_ddio_ac_par_hr;
		`endif
		`ifdef DDR3
wire   [2*MEM_CONTROL_WIDTH-1:0] phy_ddio_reset_n_hr;
		`endif
	`endif

simple_ddio_out	uaddress_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_address),
	.dataout	(phy_ddio_address_hr)
	);
defparam
	uaddress_qr_to_hr.DATA_WIDTH = MEM_ADDRESS_WIDTH,
	uaddress_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_ADDRESS_WIDTH,
	uaddress_qr_to_hr.USE_CORE_LOGIC = "true",
	uaddress_qr_to_hr.HALF_RATE_MODE = "true",
	uaddress_qr_to_hr.REG_POST_RESET_HIGH = "false",
	uaddress_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	uaddress_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";


	`ifdef DDRX
simple_ddio_out	ubank_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_bank),
	.dataout	(phy_ddio_bank_hr)
	);
defparam
	ubank_qr_to_hr.DATA_WIDTH = MEM_BANK_WIDTH,
	ubank_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_BANK_WIDTH,
	ubank_qr_to_hr.USE_CORE_LOGIC = "true",
	ubank_qr_to_hr.HALF_RATE_MODE = "true",
	ubank_qr_to_hr.REG_POST_RESET_HIGH = "false",
	ubank_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	ubank_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";
	
simple_ddio_out	ucs_n_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_cs_n),
	.dataout	(phy_ddio_cs_n_hr)
	);
defparam
	ucs_n_qr_to_hr.DATA_WIDTH = MEM_CHIP_SELECT_WIDTH,
	ucs_n_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_CHIP_SELECT_WIDTH,
	ucs_n_qr_to_hr.USE_CORE_LOGIC = "true",
	ucs_n_qr_to_hr.HALF_RATE_MODE = "true",
	ucs_n_qr_to_hr.REG_POST_RESET_HIGH = "true",
	ucs_n_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	ucs_n_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";
	
simple_ddio_out	ucke_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_cke),
	.dataout	(phy_ddio_cke_hr)
	);
defparam
	ucke_qr_to_hr.DATA_WIDTH = MEM_CLK_EN_WIDTH,
	ucke_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_CLK_EN_WIDTH,
	ucke_qr_to_hr.USE_CORE_LOGIC = "true",
	ucke_qr_to_hr.HALF_RATE_MODE = "true",
	ucke_qr_to_hr.REG_POST_RESET_HIGH = "false",
	ucke_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	ucke_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";
	
simple_ddio_out	uodt_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_odt),
	.dataout	(phy_ddio_odt_hr)
	);
defparam
	uodt_qr_to_hr.DATA_WIDTH = MEM_ODT_WIDTH,
	uodt_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_ODT_WIDTH,
	uodt_qr_to_hr.USE_CORE_LOGIC = "true",
	uodt_qr_to_hr.HALF_RATE_MODE = "true",
	uodt_qr_to_hr.REG_POST_RESET_HIGH = "false",
	uodt_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	uodt_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";

simple_ddio_out	uwe_n_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_we_n),
	.dataout	(phy_ddio_we_n_hr)
	);
defparam
	uwe_n_qr_to_hr.DATA_WIDTH = MEM_CONTROL_WIDTH,
	uwe_n_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_CONTROL_WIDTH,
	uwe_n_qr_to_hr.USE_CORE_LOGIC = "true",
	uwe_n_qr_to_hr.HALF_RATE_MODE = "true",
	uwe_n_qr_to_hr.REG_POST_RESET_HIGH = "true",
	uwe_n_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	uwe_n_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";

simple_ddio_out	uras_n_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_ras_n),
	.dataout	(phy_ddio_ras_n_hr)
	);
defparam
	uras_n_qr_to_hr.DATA_WIDTH = MEM_CONTROL_WIDTH,
	uras_n_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_CONTROL_WIDTH,
	uras_n_qr_to_hr.USE_CORE_LOGIC = "true",
	uras_n_qr_to_hr.HALF_RATE_MODE = "true",
	uras_n_qr_to_hr.REG_POST_RESET_HIGH = "true",
	uras_n_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	uras_n_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";

simple_ddio_out	ucas_n_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_cas_n),
	.dataout	(phy_ddio_cas_n_hr)
	);
defparam
	ucas_n_qr_to_hr.DATA_WIDTH = MEM_CONTROL_WIDTH,
	ucas_n_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_CONTROL_WIDTH,
	ucas_n_qr_to_hr.USE_CORE_LOGIC = "true",
	ucas_n_qr_to_hr.HALF_RATE_MODE = "true",
	ucas_n_qr_to_hr.REG_POST_RESET_HIGH = "true",
	ucas_n_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	ucas_n_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";
	
		`ifdef DDR3
simple_ddio_out	ureset_n_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_reset_n),
	.dataout	(phy_ddio_reset_n_hr)
	);
defparam
	ureset_n_qr_to_hr.DATA_WIDTH = MEM_CONTROL_WIDTH,
	ureset_n_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_CONTROL_WIDTH,
	ureset_n_qr_to_hr.USE_CORE_LOGIC = "true",
	ureset_n_qr_to_hr.HALF_RATE_MODE = "true",
	ureset_n_qr_to_hr.REG_POST_RESET_HIGH = "true",
	ureset_n_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	ureset_n_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";		
		`endif
		
		`ifdef AC_PARITY
simple_ddio_out	uac_par_qr_to_hr(
	.reset_n	(1'b1),
	.clk		(pll_afi_clk),
	.dr_reset_n	(1'b1),
	.dr_clk		(pll_hr_clk),
	.datain		(phy_ddio_ac_par),
	.dataout	(phy_ddio_ac_par_hr)
	);
defparam
	uac_par_qr_to_hr.DATA_WIDTH = MEM_CONTROL_WIDTH,
	uac_par_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2 * MEM_CONTROL_WIDTH,
	uac_par_qr_to_hr.USE_CORE_LOGIC = "true",
	uac_par_qr_to_hr.HALF_RATE_MODE = "true",
	uac_par_qr_to_hr.REG_POST_RESET_HIGH = "false",
	uac_par_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
	uac_par_qr_to_hr.USE_EXTRA_OUTPUT_REG = "true";		
		`endif
`endif 

`else 

`ifdef RLDRAMII
reg   [AFI_ADDRESS_WIDTH-1:0] phy_ddio_address_hr;
reg   [AFI_BANK_WIDTH-1:0] phy_ddio_bank_hr;
reg   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_we_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_ref_n_hr;
`endif
`ifdef QDRII
reg   [AFI_ADDRESS_WIDTH-1:0] phy_ddio_address_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n_hr;
`endif
`ifdef DDRII_SRAM
reg   [AFI_ADDRESS_WIDTH-1:0] phy_ddio_address_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_ld_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_rw_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n_hr;
`endif
`ifdef DDRX
reg   [AFI_ADDRESS_WIDTH-1:0] phy_ddio_address_hr;
reg   [AFI_BANK_WIDTH-1:0] phy_ddio_bank_hr;
reg   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_hr;
reg   [AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke_hr;
    `ifndef LPDDR1
reg   [AFI_ODT_WIDTH-1:0] phy_ddio_odt_hr;
	`endif
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_ras_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_cas_n_hr;
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_we_n_hr;
	`ifdef AC_PARITY
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_ac_par_hr;
	`endif
	`ifdef DDR3
reg   [AFI_CONTROL_WIDTH-1:0] phy_ddio_reset_n_hr;
	`endif
`endif
`ifdef LPDDR2
reg   [AFI_ADDRESS_WIDTH-1:0] phy_ddio_address_hr;
reg   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_hr;
reg   [AFI_CLK_EN_WIDTH-1:0] phy_ddio_cke_hr;
`endif

generate
if (REGISTER_C2P == "false") begin
	always @(*) begin
`ifdef RLDRAMII
		phy_ddio_address_hr = phy_ddio_address;
		phy_ddio_bank_hr = phy_ddio_bank;
		phy_ddio_cs_n_hr = phy_ddio_cs_n;
		phy_ddio_we_n_hr = phy_ddio_we_n;
		phy_ddio_ref_n_hr = phy_ddio_ref_n;
`endif
`ifdef QDRII
		phy_ddio_address_hr = phy_ddio_address;	
		phy_ddio_wps_n_hr = phy_ddio_wps_n;
		phy_ddio_rps_n_hr = phy_ddio_rps_n;
		phy_ddio_doff_n_hr = phy_ddio_doff_n;
`endif
`ifdef DDRII_SRAM
		phy_ddio_address_hr = phy_ddio_address;	
		phy_ddio_ld_n_hr = phy_ddio_ld_n;
		phy_ddio_rw_n_hr = phy_ddio_rw_n;
		phy_ddio_doff_n_hr = phy_ddio_doff_n;
`endif
`ifdef DDRX
		phy_ddio_address_hr = phy_ddio_address;	
		phy_ddio_bank_hr = phy_ddio_bank;
		phy_ddio_cs_n_hr = phy_ddio_cs_n;
		phy_ddio_cke_hr = phy_ddio_cke;
    `ifndef LPDDR1
		phy_ddio_odt_hr = phy_ddio_odt;
	`endif
		phy_ddio_ras_n_hr = phy_ddio_ras_n;
		phy_ddio_cas_n_hr = phy_ddio_cas_n;
		phy_ddio_we_n_hr = phy_ddio_we_n;
	`ifdef AC_PARITY
		phy_ddio_ac_par_hr = phy_ddio_ac_par;
	`endif
	`ifdef DDR3
		phy_ddio_reset_n_hr = phy_ddio_reset_n;
	`endif
`endif
`ifdef LPDDR2
		phy_ddio_address_hr = phy_ddio_address;	
		phy_ddio_cs_n_hr = phy_ddio_cs_n;
		phy_ddio_cke_hr = phy_ddio_cke;
`endif
	end
end else begin
`ifdef LPDDR2
	always @(posedge pll_afi_clk) begin
`else
	always @(posedge phy_ddio_addr_cmd_clk) begin
`endif
`ifdef RLDRAMII
		phy_ddio_address_hr <= phy_ddio_address;
		phy_ddio_bank_hr <= phy_ddio_bank;
		phy_ddio_cs_n_hr <= phy_ddio_cs_n;
		phy_ddio_we_n_hr <= phy_ddio_we_n;
		phy_ddio_ref_n_hr <= phy_ddio_ref_n;
`endif
`ifdef QDRII
		phy_ddio_address_hr <= phy_ddio_address;	
		phy_ddio_wps_n_hr <= phy_ddio_wps_n;
		phy_ddio_rps_n_hr <= phy_ddio_rps_n;
		phy_ddio_doff_n_hr <= phy_ddio_doff_n;
`endif
`ifdef DDRII_SRAM
		phy_ddio_address_hr <= phy_ddio_address;	
		phy_ddio_ld_n_hr <= phy_ddio_ld_n;
		phy_ddio_rw_n_hr <= phy_ddio_rw_n;
		phy_ddio_doff_n_hr <= phy_ddio_doff_n;
`endif
`ifdef DDRX
		phy_ddio_address_hr <= phy_ddio_address;	
		phy_ddio_bank_hr <= phy_ddio_bank;
		phy_ddio_cs_n_hr <= phy_ddio_cs_n;
		phy_ddio_cke_hr <= phy_ddio_cke;
    `ifndef LPDDR1
		phy_ddio_odt_hr <= phy_ddio_odt;
	`endif
		phy_ddio_ras_n_hr <= phy_ddio_ras_n;
		phy_ddio_cas_n_hr <= phy_ddio_cas_n;
		phy_ddio_we_n_hr <= phy_ddio_we_n;
	`ifdef AC_PARITY
		phy_ddio_ac_par_hr <= phy_ddio_ac_par;
	`endif
	`ifdef DDR3
		phy_ddio_reset_n_hr <= phy_ddio_reset_n;
	`endif
`endif
`ifdef LPDDR2
		phy_ddio_address_hr <= phy_ddio_address;	
		phy_ddio_cs_n_hr <= phy_ddio_cs_n;
		phy_ddio_cke_hr <= phy_ddio_cke;
`endif
	end
end
endgenerate	


`endif


`ifdef RLDRAMII
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_h;
wire	[MEM_BANK_WIDTH-1:0] phy_ddio_bank_l;
wire	[MEM_BANK_WIDTH-1:0] phy_ddio_bank_h;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_l;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_h;
wire	[MEM_CONTROL_WIDTH-1:0]	phy_ddio_we_n_l;
wire	[MEM_CONTROL_WIDTH-1:0]	phy_ddio_we_n_h;
wire	[MEM_CONTROL_WIDTH-1:0]	phy_ddio_ref_n_l;
wire	[MEM_CONTROL_WIDTH-1:0]	phy_ddio_ref_n_h;
`endif
`ifdef QDRII
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_doff_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_doff_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_wps_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_wps_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_rps_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_rps_n_h;
`endif
`ifdef DDRII_SRAM 
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_doff_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_doff_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_ld_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_ld_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_rw_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_rw_n_h;
`endif
`ifdef DDRX
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_h;
wire	[MEM_BANK_WIDTH-1:0] phy_ddio_bank_l;
wire	[MEM_BANK_WIDTH-1:0] phy_ddio_bank_h;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_l;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_h;
wire	[MEM_CLK_EN_WIDTH-1:0] phy_ddio_cke_l;
wire	[MEM_CLK_EN_WIDTH-1:0] phy_ddio_cke_h;
	`ifndef LPDDR1
wire	[MEM_ODT_WIDTH-1:0] phy_ddio_odt_l;
wire	[MEM_ODT_WIDTH-1:0] phy_ddio_odt_h;
	`endif
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_ras_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_ras_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_cas_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_cas_n_h;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_we_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_we_n_h;
	`ifdef AC_PARITY
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_ac_par_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_ac_par_h;
	`endif
	`ifdef DDR3
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_reset_n_l;
wire	[MEM_CONTROL_WIDTH-1:0] phy_ddio_reset_n_h;
	`endif
`endif
`ifdef LPDDR2
	`ifdef FULL_RATE
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_l;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_h;
	`else
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_ll;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_lh;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_hl;
wire	[MEM_ADDRESS_WIDTH-1:0]	phy_ddio_address_hh;
	`endif
wire	[MEM_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_l;
wire	[MEM_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n_h;
wire	[MEM_CLK_EN_WIDTH-1:0] phy_ddio_cke_l;
wire	[MEM_CLK_EN_WIDTH-1:0] phy_ddio_cke_h;
`endif

// each signal has a high and a low portion,
// connecting to the high and low inputs of the DDIO_OUT,
// for the purpose of creating double data rate
`ifdef RLDRAMII
	assign phy_ddio_address_l = phy_ddio_address_hr[MEM_ADDRESS_WIDTH-1:0];
	assign phy_ddio_bank_l = phy_ddio_bank_hr[MEM_BANK_WIDTH-1:0];
	assign phy_ddio_cs_n_l = phy_ddio_cs_n_hr[MEM_CHIP_SELECT_WIDTH-1:0];
	assign phy_ddio_we_n_l = phy_ddio_we_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_ref_n_l = phy_ddio_ref_n_hr[MEM_CONTROL_WIDTH-1:0];
`endif
`ifdef QDRII
	assign phy_ddio_address_l = phy_ddio_address_hr[MEM_ADDRESS_WIDTH-1:0];
	assign phy_ddio_doff_n_l = phy_ddio_doff_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_wps_n_l = phy_ddio_wps_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_rps_n_l = phy_ddio_rps_n_hr[MEM_CONTROL_WIDTH-1:0];
`endif
`ifdef DDRII_SRAM
	assign phy_ddio_address_l = phy_ddio_address_hr[MEM_ADDRESS_WIDTH-1:0];
	assign phy_ddio_doff_n_l = phy_ddio_doff_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_ld_n_l = phy_ddio_ld_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_rw_n_l = phy_ddio_rw_n_hr[MEM_CONTROL_WIDTH-1:0];
`endif
`ifdef DDRX
	assign phy_ddio_address_l = phy_ddio_address_hr[MEM_ADDRESS_WIDTH-1:0];
	assign phy_ddio_bank_l = phy_ddio_bank_hr[MEM_BANK_WIDTH-1:0];
	assign phy_ddio_cke_l = phy_ddio_cke_hr[MEM_CLK_EN_WIDTH-1:0];
	`ifndef LPDDR1
	assign phy_ddio_odt_l = phy_ddio_odt_hr[MEM_ODT_WIDTH-1:0];
	`endif
	assign phy_ddio_cs_n_l = phy_ddio_cs_n_hr[MEM_CHIP_SELECT_WIDTH-1:0];
	assign phy_ddio_we_n_l = phy_ddio_we_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_ras_n_l = phy_ddio_ras_n_hr[MEM_CONTROL_WIDTH-1:0];
	assign phy_ddio_cas_n_l = phy_ddio_cas_n_hr[MEM_CONTROL_WIDTH-1:0];
	`ifdef AC_PARITY
	assign phy_ddio_ac_par_l = phy_ddio_ac_par_hr[MEM_CONTROL_WIDTH-1:0];
	`endif
	`ifdef DDR3
	assign phy_ddio_reset_n_l = phy_ddio_reset_n_hr[MEM_CONTROL_WIDTH-1:0];
	`endif
`endif
`ifdef LPDDR2
	`ifdef FULL_RATE
	assign phy_ddio_address_l = phy_ddio_address_hr[MEM_ADDRESS_WIDTH-1:0];
	`else
	assign phy_ddio_address_lh = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_address_ll = phy_ddio_address_hr[MEM_ADDRESS_WIDTH-1:0];
	`endif
	assign phy_ddio_cke_l = phy_ddio_cke_hr[MEM_CLK_EN_WIDTH-1:0];
	assign phy_ddio_cs_n_l = phy_ddio_cs_n_hr[MEM_CHIP_SELECT_WIDTH-1:0];
`endif

`ifdef FULL_RATE
	`ifdef RLDRAMII
	assign phy_ddio_address_h = phy_ddio_address_l;
	assign phy_ddio_bank_h = phy_ddio_bank_l;
	assign phy_ddio_cs_n_h = phy_ddio_cs_n_l;
	assign phy_ddio_we_n_h = phy_ddio_we_n_l;
	assign phy_ddio_ref_n_h = phy_ddio_ref_n_l;
	`endif
	`ifdef QDRII
		`ifdef BURST2
	// In QDRII burst of 2, address and command are double data rate
	// so the AFI address and command widths are double that of the memory interface
	assign phy_ddio_address_h = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_doff_n_h = phy_ddio_doff_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_wps_n_h = phy_ddio_wps_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_rps_n_h = phy_ddio_rps_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
		`else
	assign phy_ddio_address_h = phy_ddio_address_l;
	assign phy_ddio_doff_n_h = phy_ddio_doff_n_l;
	assign phy_ddio_wps_n_h = phy_ddio_wps_n_l;
	assign phy_ddio_rps_n_h = phy_ddio_rps_n_l;
		`endif
	`endif
	`ifdef DDRII_SRAM
	assign phy_ddio_address_h = phy_ddio_address_l;
	assign phy_ddio_doff_n_h = phy_ddio_doff_n_l;
	assign phy_ddio_ld_n_h = phy_ddio_ld_n_l;
	assign phy_ddio_rw_n_h = phy_ddio_rw_n_l;
	`endif
	`ifdef DDRX
	assign phy_ddio_address_h = phy_ddio_address_l;
	assign phy_ddio_bank_h = phy_ddio_bank_l;
	assign phy_ddio_cke_h = phy_ddio_cke_l;
		`ifndef LPDDR1
	assign phy_ddio_odt_h = phy_ddio_odt_l;
		`endif	
	assign phy_ddio_cs_n_h = phy_ddio_cs_n_l;
	assign phy_ddio_we_n_h = phy_ddio_we_n_l;
	assign phy_ddio_ras_n_h = phy_ddio_ras_n_l;
	assign phy_ddio_cas_n_h = phy_ddio_cas_n_l;
		`ifdef AC_PARITY
	assign phy_ddio_ac_par_h = phy_ddio_ac_par_l;
		`endif	
		`ifdef DDR3
	assign phy_ddio_reset_n_h = phy_ddio_reset_n_l;
		`endif
	`endif
	`ifdef LPDDR2
	assign phy_ddio_address_h = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_cke_h = phy_ddio_cke_l;
	assign phy_ddio_cs_n_h = phy_ddio_cs_n_l;
	`endif
`else
	`ifdef RLDRAMII
	assign phy_ddio_address_h = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_bank_h = phy_ddio_bank_hr[2*MEM_BANK_WIDTH-1:MEM_BANK_WIDTH];
	assign phy_ddio_cs_n_h = phy_ddio_cs_n_hr[2*MEM_CHIP_SELECT_WIDTH-1:MEM_CHIP_SELECT_WIDTH];
	assign phy_ddio_we_n_h = phy_ddio_we_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_ref_n_h = phy_ddio_ref_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	`endif
	`ifdef QDRII
	assign phy_ddio_address_h = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_doff_n_h = phy_ddio_doff_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_wps_n_h = phy_ddio_wps_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_rps_n_h = phy_ddio_rps_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	`endif
	`ifdef DDRII_SRAM
	assign phy_ddio_address_h = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_doff_n_h = phy_ddio_doff_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_ld_n_h = phy_ddio_ld_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_rw_n_h = phy_ddio_rw_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	`endif
	`ifdef DDRX
	assign phy_ddio_address_h = phy_ddio_address_hr[2*MEM_ADDRESS_WIDTH-1:MEM_ADDRESS_WIDTH];
	assign phy_ddio_bank_h = phy_ddio_bank_hr[2*MEM_BANK_WIDTH-1:MEM_BANK_WIDTH];
	assign phy_ddio_cke_h = phy_ddio_cke_hr[2*MEM_CLK_EN_WIDTH-1:MEM_CLK_EN_WIDTH];
		`ifndef LPDDR1
	assign phy_ddio_odt_h = phy_ddio_odt_hr[2*MEM_ODT_WIDTH-1:MEM_ODT_WIDTH];
		`endif
	assign phy_ddio_cs_n_h = phy_ddio_cs_n_hr[2*MEM_CHIP_SELECT_WIDTH-1:MEM_CHIP_SELECT_WIDTH];
	assign phy_ddio_we_n_h = phy_ddio_we_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_ras_n_h = phy_ddio_ras_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
	assign phy_ddio_cas_n_h = phy_ddio_cas_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
		`ifdef AC_PARITY
	assign phy_ddio_ac_par_h = phy_ddio_ac_par_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
		`endif
		`ifdef DDR3
	assign phy_ddio_reset_n_h = phy_ddio_reset_n_hr[2*MEM_CONTROL_WIDTH-1:MEM_CONTROL_WIDTH];
		`endif
	`endif
	`ifdef LPDDR2
	assign phy_ddio_address_hh = phy_ddio_address_hr[4*MEM_ADDRESS_WIDTH-1:3*MEM_ADDRESS_WIDTH];
	assign phy_ddio_address_hl = phy_ddio_address_hr[3*MEM_ADDRESS_WIDTH-1:2*MEM_ADDRESS_WIDTH];
	assign phy_ddio_cke_h = phy_ddio_cke_hr[2*MEM_CLK_EN_WIDTH-1:MEM_CLK_EN_WIDTH];
	assign phy_ddio_cs_n_h = phy_ddio_cs_n_hr[2*MEM_CHIP_SELECT_WIDTH-1:MEM_CHIP_SELECT_WIDTH];
	`endif
`endif


`ifdef LPDDR2
	`ifdef FULL_RATE
	assign address_l = phy_ddio_address_l;
	assign address_h = phy_ddio_address_h;
	`else
	wire	[MEM_ADDRESS_WIDTH-1:0]adc_ldc_ca;
	wire	[MEM_ADDRESS_WIDTH-1:0]hr_seq_clock_ca;
	
	genvar i;
	generate
	for (i = 0; i < MEM_ADDRESS_WIDTH; i = i + 1)
	begin :address_gen
	    
	    `ifndef SIMGEN
        	acv_ldc # (
        		.DLL_DELAY_CTRL_WIDTH(DLL_WIDTH),
        		.ADC_PHASE_SETTING(2),
        		.ADC_INVERT_PHASE("true"),
        		.IS_HHP_HPS(IS_HHP_HPS)
        	) acv_adc_ca_ldc (
        		.pll_hr_clk(pll_afi_phy_clk),
        		.pll_dq_clk(pll_write_clk),
        		.pll_dqs_clk (pll_mem_phy_clk),
        		.dll_phy_delayctrl (dll_delayctrl_in),
        		.adc_clk_cps (adc_ldc_ca[i]),
        		.hr_clk (hr_seq_clock_ca[i])
        	);
        `else
        	assign adc_ldc_ca[i] = pll_write_clk;
        	assign hr_seq_clock_ca[i] = pll_afi_phy_clk;
        `endif
	    
		`ifdef STRATIXV
		stratixv_ddio_out hr_to_fr_hi (
		`endif
		`ifdef ARRIAVGZ
		arriavgz_ddio_out hr_to_fr_hi (
		`endif
		`ifdef ARRIAV
		arriav_ddio_out hr_to_fr_hi (
		`endif
		`ifdef CYCLONEV
		cyclonev_ddio_out hr_to_fr_hi (
		`endif
		    .areset(~reset_n),
			.datainhi(phy_ddio_address_lh[i]),
			.datainlo(phy_ddio_address_hh[i]),
			.dataout(address_h[i]),
			.clkhi (hr_seq_clock_ca[i]),
			.clklo (hr_seq_clock_ca[i]),
			.muxsel (hr_seq_clock_ca[i])
		);
		defparam hr_to_fr_hi.half_rate_mode = "true",
				hr_to_fr_hi.use_new_clocking_model = "true",
				hr_to_fr_hi.async_mode = "none";

		`ifdef STRATIXV
		stratixv_ddio_out hr_to_fr_lo (
		`endif
		`ifdef ARRIAVGZ
		arriavgz_ddio_out hr_to_fr_lo (
		`endif
		`ifdef ARRIAV
		arriav_ddio_out hr_to_fr_lo (
		`endif
		`ifdef CYCLONEV
		cyclonev_ddio_out hr_to_fr_lo (
		`endif
		    .areset(~reset_n),
			.datainhi(phy_ddio_address_ll[i]),
			.datainlo(phy_ddio_address_hl[i]),
			.dataout(address_l[i]),
			.clkhi (hr_seq_clock_ca[i]),
			.clklo (hr_seq_clock_ca[i]),
			.muxsel (hr_seq_clock_ca[i])
		);
		defparam hr_to_fr_lo.half_rate_mode = "true",
				hr_to_fr_lo.use_new_clocking_model = "true",
				hr_to_fr_lo.async_mode = "none";
		
		altddio_out	uaddress_pad(
	    	.aclr	    (~reset_n),
	    	.aset	    (1'b0),
	    	.datain_h   (address_l[i]),
	    	.datain_l   (address_h[i]),
	    	.dataout    (phy_mem_address[i]),
	    	.oe	    	(1'b1),
	    	.outclock   (adc_ldc_ca[i]),
	    	.outclocken (1'b1)
        );
        
        defparam 
	    	uaddress_pad.extend_oe_disable = "UNUSED",
	    	uaddress_pad.intended_device_family = DEVICE_FAMILY,
	    	uaddress_pad.invert_output = "OFF",
	    	uaddress_pad.lpm_hint = "UNUSED",
	    	uaddress_pad.lpm_type = "altddio_out",
	    	uaddress_pad.oe_reg = "UNUSED",
	    	uaddress_pad.power_up_high = "OFF",
	    	uaddress_pad.width = 1;
	    	
	end
	endgenerate
	`endif
`else
	assign address_l = phy_ddio_address_l;
	assign address_h = phy_ddio_address_h;

    altddio_out	uaddress_pad(
		.aclr	    (~reset_n),
		.aset	    (1'b0),
		.datain_h   (address_l),
		.datain_l   (address_h),
		.dataout    (phy_mem_address),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		uaddress_pad.extend_oe_disable = "UNUSED",
		uaddress_pad.intended_device_family = DEVICE_FAMILY,
		uaddress_pad.invert_output = "OFF",
		uaddress_pad.lpm_hint = "UNUSED",
		uaddress_pad.lpm_type = "altddio_out",
		uaddress_pad.oe_reg = "UNUSED",
		uaddress_pad.power_up_high = "OFF",
		uaddress_pad.width = MEM_ADDRESS_WIDTH;
`endif

`ifdef RLDRAMII
    altddio_out	ubank_pad(
		.aclr	    (~reset_n),
		.aset	    (1'b0),
		.datain_h   (phy_ddio_bank_l),
		.datain_l   (phy_ddio_bank_h),
		.dataout    (phy_mem_bank),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		ubank_pad.extend_oe_disable = "UNUSED",
		ubank_pad.intended_device_family = DEVICE_FAMILY,
		ubank_pad.invert_output = "OFF",
		ubank_pad.lpm_hint = "UNUSED",
		ubank_pad.lpm_type = "altddio_out",
		ubank_pad.oe_reg = "UNUSED",
		ubank_pad.power_up_high = "OFF",
		ubank_pad.width = MEM_BANK_WIDTH;



    altddio_out	ucs_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (phy_ddio_cs_n_l),
		.datain_l   (phy_ddio_cs_n_h),
		.dataout    (phy_mem_cs_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		ucs_n_pad.extend_oe_disable = "UNUSED",
		ucs_n_pad.intended_device_family = DEVICE_FAMILY,
		ucs_n_pad.invert_output = "OFF",
		ucs_n_pad.lpm_hint = "UNUSED",
		ucs_n_pad.lpm_type = "altddio_out",
		ucs_n_pad.oe_reg = "UNUSED",
		ucs_n_pad.power_up_high = "OFF",
		ucs_n_pad.width = MEM_CHIP_SELECT_WIDTH;



    altddio_out	uwe_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (phy_ddio_we_n_l),
		.datain_l   (phy_ddio_we_n_h),
		.dataout    (phy_mem_we_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		uwe_n_pad.extend_oe_disable = "UNUSED",
		uwe_n_pad.intended_device_family = DEVICE_FAMILY,
		uwe_n_pad.invert_output = "OFF",
		uwe_n_pad.lpm_hint = "UNUSED",
		uwe_n_pad.lpm_type = "altddio_out",
		uwe_n_pad.oe_reg = "UNUSED",
		uwe_n_pad.power_up_high = "OFF",
		uwe_n_pad.width = MEM_CONTROL_WIDTH;



    altddio_out	uref_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (phy_ddio_ref_n_l),
		.datain_l   (phy_ddio_ref_n_h),
		.dataout    (phy_mem_ref_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		uref_n_pad.extend_oe_disable = "UNUSED",
		uref_n_pad.intended_device_family = DEVICE_FAMILY,
		uref_n_pad.invert_output = "OFF",
		uref_n_pad.lpm_hint = "UNUSED",
		uref_n_pad.lpm_type = "altddio_out",
		uref_n_pad.oe_reg = "UNUSED",
		uref_n_pad.power_up_high = "OFF",
		uref_n_pad.width = MEM_CONTROL_WIDTH;
		
    wire mem_ck_source;
	
`ifdef USE_LDC_AS_LOW_SKEW_CLOCK
	
    wire [3:0] delayed_clocks;
    `ifdef STRATIXV
    stratixv_leveling_delay_chain thechain (
    `endif
    `ifdef ARRIAVGZ
    arriavgz_leveling_delay_chain thechain (
     `endif
        .clkin (pll_write_clk),
        .delayctrlin (dll_delayctrl_in),
        .clkout(delayed_clocks)
    );
	
	`ifdef STRATIXV
    stratixv_clk_phase_select
	`endif
	`ifdef ARRIAVGZ
     arriavgz_clk_phase_select 
	`endif
    #(
        .physical_clock_source("add_cmd"),
        .use_phasectrlin("false"), 
        .invert_phase("false"), 
        `ifdef DLL_USE_DR_CLK
        .phase_setting(3)       
        `else
        .phase_setting(2)       
        `endif
    ) ck_select (
        .clkin (delayed_clocks),
        .clkout (mem_ck_source)
    );

	
`else

     `ifdef DUPLICATE_PLL_FOR_PHY_CLK
     acv_ldc # (
     	.DLL_DELAY_CTRL_WIDTH(DLL_WIDTH),
     	.ADC_PHASE_SETTING(0),
     	.ADC_INVERT_PHASE("false"),
	.IS_HHP_HPS(IS_HHP_HPS)
     ) acv_ck_ldc (
     	.pll_hr_clk(pll_afi_phy_clk),
     	.pll_dq_clk(pll_write_clk),
     	.pll_dqs_clk (pll_mem_phy_clk),
     	.dll_phy_delayctrl(dll_delayctrl_in),
     	.adc_clk_cps(mem_ck_source)
     );
     `else
    	assign mem_ck_source = pll_mem_clk;
     `endif

`endif


    wire mem_ck;

    altddio_out umem_ck_pad(
    	.aclr       (1'b0),
    	.aset       (1'b0),
    	.datain_h   (enable_mem_clk),
    	.datain_l   (1'b0),
    	.dataout    (mem_ck),
    	.oe         (1'b1),
    	.outclock   (mem_ck_source),
    	.outclocken (1'b1)
    );
    defparam
    	umem_ck_pad.extend_oe_disable = "UNUSED",
    	umem_ck_pad.intended_device_family = DEVICE_FAMILY,
    	umem_ck_pad.invert_output = "OFF",
    	umem_ck_pad.lpm_hint = "UNUSED",
    	umem_ck_pad.lpm_type = "altddio_out",
    	umem_ck_pad.oe_reg = "UNUSED",
    	umem_ck_pad.power_up_high = "OFF",
    	umem_ck_pad.width = 1;


    clock_pair_generator    uclk_generator(
        .datain     (mem_ck),
        .dataout    (phy_mem_ck),
        .dataout_b  (phy_mem_ck_n)
    );
`endif

`ifdef QDRII
    altddio_out uwps_n_pad(
        .aclr       (1'b0),
        .aset       (~reset_n),
        .datain_h   (phy_ddio_wps_n_l),
        .datain_l   (phy_ddio_wps_n_h),
        .dataout    (phy_mem_wps_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        uwps_n_pad.extend_oe_disable = "UNUSED",
        uwps_n_pad.intended_device_family = DEVICE_FAMILY,
        uwps_n_pad.invert_output = "OFF",
        uwps_n_pad.lpm_hint = "UNUSED",
        uwps_n_pad.lpm_type = "altddio_out",
        uwps_n_pad.oe_reg = "UNUSED",
        uwps_n_pad.power_up_high = "OFF",
        uwps_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out urps_n_pad(
        .aclr       (1'b0),
        .aset       (~reset_n),
        .datain_h   (phy_ddio_rps_n_l),
        .datain_l   (phy_ddio_rps_n_h),
        .dataout    (phy_mem_rps_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        urps_n_pad.extend_oe_disable = "UNUSED",
        urps_n_pad.intended_device_family = DEVICE_FAMILY,
        urps_n_pad.invert_output = "OFF",
        urps_n_pad.lpm_hint = "UNUSED",
        urps_n_pad.lpm_type = "altddio_out",
        urps_n_pad.oe_reg = "UNUSED",
        urps_n_pad.power_up_high = "OFF",
        urps_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out udoff_n_pad(
        .aclr       (~reset_n),
        .aset       (1'b0),
        .datain_h   (phy_ddio_doff_n_l),
        .datain_l   (phy_ddio_doff_n_h),
        .dataout    (phy_mem_doff_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        udoff_n_pad.extend_oe_disable = "UNUSED",
        udoff_n_pad.intended_device_family = DEVICE_FAMILY,
        udoff_n_pad.invert_output = "OFF",
        udoff_n_pad.lpm_hint = "UNUSED",
        udoff_n_pad.lpm_type = "altddio_out",
        udoff_n_pad.oe_reg = "UNUSED",
        udoff_n_pad.power_up_high = "OFF",
        udoff_n_pad.width = MEM_CONTROL_WIDTH;
`endif


`ifdef DDRII_SRAM 
    altddio_out uld_n_pad(
        .aclr       (1'b0),
        .aset       (~reset_n),
        .datain_h   (phy_ddio_ld_n_l),
        .datain_l   (phy_ddio_ld_n_h),
        .dataout    (phy_mem_ld_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        uld_n_pad.extend_oe_disable = "UNUSED",
        uld_n_pad.intended_device_family = DEVICE_FAMILY,
        uld_n_pad.invert_output = "OFF",
        uld_n_pad.lpm_hint = "UNUSED",
        uld_n_pad.lpm_type = "altddio_out",
        uld_n_pad.oe_reg = "UNUSED",
        uld_n_pad.power_up_high = "OFF",
        uld_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out urw_n_pad(
        .aclr       (1'b0),
        .aset       (~reset_n),
        .datain_h   (phy_ddio_rw_n_l),
        .datain_l   (phy_ddio_rw_n_h),
        .dataout    (phy_mem_rw_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        urw_n_pad.extend_oe_disable = "UNUSED",
        urw_n_pad.intended_device_family = DEVICE_FAMILY,
        urw_n_pad.invert_output = "OFF",
        urw_n_pad.lpm_hint = "UNUSED",
        urw_n_pad.lpm_type = "altddio_out",
        urw_n_pad.oe_reg = "UNUSED",
        urw_n_pad.power_up_high = "OFF",
        urw_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out udoff_n_pad(
        .aclr       (~reset_n),
        .aset       (1'b0),
        .datain_h   (phy_ddio_doff_n_l),
        .datain_l   (phy_ddio_doff_n_h),
        .dataout    (phy_mem_doff_n),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        udoff_n_pad.extend_oe_disable = "UNUSED",
        udoff_n_pad.intended_device_family = DEVICE_FAMILY,
        udoff_n_pad.invert_output = "OFF",
        udoff_n_pad.lpm_hint = "UNUSED",
        udoff_n_pad.lpm_type = "altddio_out",
        udoff_n_pad.oe_reg = "UNUSED",
        udoff_n_pad.power_up_high = "OFF",
        udoff_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out uzq_pad(
        .aclr       (1'b0),
        .aset       (~reset_n),
        .datain_h   (1'b1),
        .datain_l   (1'b1),
        .dataout    (phy_mem_zq),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam 
        uzq_pad.extend_oe_disable = "UNUSED",
        uzq_pad.intended_device_family = DEVICE_FAMILY,
        uzq_pad.invert_output = "OFF",
        uzq_pad.lpm_hint = "UNUSED",
        uzq_pad.lpm_type = "altddio_out",
        uzq_pad.oe_reg = "UNUSED",
        uzq_pad.power_up_high = "OFF",
        uzq_pad.width = MEM_CONTROL_WIDTH;

`endif

`ifdef DDRX
    altddio_out	ubank_pad(
		.aclr	    (~reset_n),
		.aset	    (1'b0),
		.datain_h   (phy_ddio_bank_l),
		.datain_l   (phy_ddio_bank_h),
		.dataout    (phy_mem_bank),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		ubank_pad.extend_oe_disable = "UNUSED",
		ubank_pad.intended_device_family = DEVICE_FAMILY,
		ubank_pad.invert_output = "OFF",
		ubank_pad.lpm_hint = "UNUSED",
		ubank_pad.lpm_type = "altddio_out",
		ubank_pad.oe_reg = "UNUSED",
		ubank_pad.power_up_high = "OFF",
		ubank_pad.width = MEM_BANK_WIDTH;
`endif

`ifdef DDRX_LPDDRX
	`ifdef LPDDR2
		`ifdef FULL_RATE
	assign cs_n_l = phy_ddio_cs_n_l;
	assign cs_n_h = phy_ddio_cs_n_h;
		`else
	wire	[MEM_CHIP_SELECT_WIDTH-1:0]adc_ldc_cs;
	wire	[MEM_CHIP_SELECT_WIDTH-1:0]hr_seq_clock_cs;
	generate
	for (i = 0; i < MEM_CHIP_SELECT_WIDTH; i = i + 1)
	begin :cs_n_gen
	    
	        `ifndef SIMGEN
        	acv_ldc # (
        		.DLL_DELAY_CTRL_WIDTH(DLL_WIDTH),
        		.ADC_PHASE_SETTING(2),
        		.ADC_INVERT_PHASE("true"),
        		.IS_HHP_HPS(IS_HHP_HPS)
        	) acv_adc_cs_ldc (
        		.pll_hr_clk(pll_afi_phy_clk),
        		.pll_dq_clk(pll_write_clk),
        		.pll_dqs_clk (pll_mem_phy_clk),
        		.dll_phy_delayctrl (dll_delayctrl_in),
        		.adc_clk_cps (adc_ldc_cs[i]),
        		.hr_clk (hr_seq_clock_cs[i])
        	);
        	`else
        	assign adc_ldc_cs[i] = pll_write_clk;
        	assign hr_seq_clock_cs[i] = pll_afi_phy_clk;
        	`endif
	    
			`ifdef STRATIXV
		stratixv_ddio_out hr_to_fr_hi (
			`endif
			`ifdef ARRIAVGZ
		arriavgz_ddio_out hr_to_fr_hi (
			`endif
			`ifdef ARRIAV
		arriav_ddio_out hr_to_fr_hi (
			`endif
			`ifdef CYCLONEV
		cyclonev_ddio_out hr_to_fr_hi (
			`endif
			.areset(~reset_n),
			.datainhi(phy_ddio_cs_n_l[i]),
			.datainlo(phy_ddio_cs_n_h[i]),
			.dataout(cs_n_h[i]),
			.clkhi (hr_seq_clock_cs[i]),
			.clklo (hr_seq_clock_cs[i]),
			.muxsel (hr_seq_clock_cs[i])
		);
		defparam hr_to_fr_hi.half_rate_mode = "true",
				hr_to_fr_hi.use_new_clocking_model = "true",
				hr_to_fr_hi.async_mode = "none";

			`ifdef STRATIXV
		stratixv_ddio_out hr_to_fr_lo (
			`endif
			`ifdef ARRIAVGZ
		arriavgz_ddio_out hr_to_fr_lo (
			`endif
			`ifdef ARRIAV
		arriav_ddio_out hr_to_fr_lo (
			`endif
			`ifdef CYCLONEV
		cyclonev_ddio_out hr_to_fr_lo (
			`endif
			.areset(~reset_n),
			.datainhi(phy_ddio_cs_n_l[i]),
			.datainlo(phy_ddio_cs_n_h[i]),
			.dataout(cs_n_l[i]),
			.clkhi (hr_seq_clock_cs[i]),
			.clklo (hr_seq_clock_cs[i]),
			.muxsel (hr_seq_clock_cs[i])
		);
		defparam hr_to_fr_lo.half_rate_mode = "true",
				hr_to_fr_lo.use_new_clocking_model = "true",
				hr_to_fr_lo.async_mode = "none";
		
		altddio_out	ucs_n_pad(
    		.aclr	    (~reset_n),
    		.aset	    (1'b0),
    		.datain_h   (cs_n_l[i]),
    		.datain_l   (cs_n_h[i]),
    		.dataout    (phy_mem_cs_n[i]),
    		.oe	    	(1'b1),
    		.outclock   (adc_ldc_cs[i]),
    		.outclocken (1'b1)
        );
    
        defparam 
    		ucs_n_pad.extend_oe_disable = "UNUSED",
    		ucs_n_pad.intended_device_family = DEVICE_FAMILY,
    		ucs_n_pad.invert_output = "OFF",
    		ucs_n_pad.lpm_hint = "UNUSED",
    		ucs_n_pad.lpm_type = "altddio_out",
    		ucs_n_pad.oe_reg = "UNUSED",
    		ucs_n_pad.power_up_high = "OFF",
    		ucs_n_pad.width = 1;
    		
	end
	endgenerate
		`endif
	`else
	assign cs_n_l = phy_ddio_cs_n_l;
	assign cs_n_h = phy_ddio_cs_n_h;

    altddio_out	ucs_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (cs_n_l),
		.datain_l   (cs_n_h),
		.dataout    (phy_mem_cs_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		ucs_n_pad.extend_oe_disable = "UNUSED",
		ucs_n_pad.intended_device_family = DEVICE_FAMILY,
		ucs_n_pad.invert_output = "OFF",
		ucs_n_pad.lpm_hint = "UNUSED",
		ucs_n_pad.lpm_type = "altddio_out",
		ucs_n_pad.oe_reg = "UNUSED",
		ucs_n_pad.power_up_high = "OFF",
		ucs_n_pad.width = MEM_CHIP_SELECT_WIDTH;
	`endif

	`ifdef LPDDR2
		`ifdef FULL_RATE
	assign cke_l = phy_ddio_cke_l;
	assign cke_h = phy_ddio_cke_h;		
		`else
	wire	[MEM_CHIP_SELECT_WIDTH-1:0]adc_ldc_cke;
	wire	[MEM_CHIP_SELECT_WIDTH-1:0]hr_seq_clock_cke;
	
	generate
	for (i = 0; i < MEM_CLK_EN_WIDTH; i = i + 1)
	begin :cke_gen
	        `ifndef SIMGEN
        	acv_ldc # (
        		.DLL_DELAY_CTRL_WIDTH(DLL_WIDTH),
        		.ADC_PHASE_SETTING(2),
        		.ADC_INVERT_PHASE("true"),
        		.IS_HHP_HPS(IS_HHP_HPS)
        	) acv_adc_cke_ldc (
        		.pll_hr_clk(pll_afi_phy_clk),
        		.pll_dq_clk(pll_write_clk),
        		.pll_dqs_clk (pll_mem_phy_clk),
        		.dll_phy_delayctrl (dll_delayctrl_in),
        		.adc_clk_cps (adc_ldc_cke[i]),
        		.hr_clk (hr_seq_clock_cke[i])
        	);
        	`else
        	assign adc_ldc_cke[i] = pll_write_clk;
        	assign hr_seq_clock_cke[i] = pll_afi_phy_clk;
        	`endif
	    
			`ifdef STRATIXV
		stratixv_ddio_out hr_to_fr_hi (
			`endif
			`ifdef ARRIAVGZ
		arriavgz_ddio_out hr_to_fr_hi (
			`endif
			`ifdef ARRIAV
		arriav_ddio_out hr_to_fr_hi (
			`endif
			`ifdef CYCLONEV
		cyclonev_ddio_out hr_to_fr_hi (
			`endif
			.areset(~reset_n),
			.datainhi(phy_ddio_cke_l[i]),
			.datainlo(phy_ddio_cke_h[i]),
			.dataout(cke_h[i]),
			.clkhi (hr_seq_clock_cke[i]),
			.clklo (hr_seq_clock_cke[i]),
			.muxsel (hr_seq_clock_cke[i])
		);
		defparam hr_to_fr_hi.half_rate_mode = "true",
				hr_to_fr_hi.use_new_clocking_model = "true",
				hr_to_fr_hi.async_mode = "none";

			`ifdef STRATIXV
		stratixv_ddio_out hr_to_fr_lo (
			`endif
			`ifdef ARRIAVGZ
		arriavgz_ddio_out hr_to_fr_lo (
			`endif
			`ifdef ARRIAV
		arriav_ddio_out hr_to_fr_lo (
			`endif
			`ifdef CYCLONEV
		cyclonev_ddio_out hr_to_fr_lo (
			`endif
			.areset(~reset_n),
			.datainhi(phy_ddio_cke_l[i]),
			.datainlo(phy_ddio_cke_h[i]),
			.dataout(cke_l[i]),
			.clkhi (hr_seq_clock_cke[i]),
			.clklo (hr_seq_clock_cke[i]),
			.muxsel (hr_seq_clock_cke[i])
		);
		defparam hr_to_fr_lo.half_rate_mode = "true",
				hr_to_fr_lo.use_new_clocking_model = "true",
				hr_to_fr_lo.async_mode = "none";
		
        altddio_out ucke_pad(
            .aclr       (~reset_n),
            .aset       (1'b0),
            .datain_h   (cke_l[i]),
            .datain_l   (cke_h[i]),
            .dataout    (phy_mem_cke[i]),
            .oe         (1'b1),
	    	.outclock   (adc_ldc_cke[i]),
            .outclocken (1'b1)
        );
        
        defparam
            ucke_pad.extend_oe_disable = "UNUSED",
            ucke_pad.intended_device_family = DEVICE_FAMILY,
            ucke_pad.invert_output = "OFF",
            ucke_pad.lpm_hint = "UNUSED",
            ucke_pad.lpm_type = "altddio_out",
            ucke_pad.oe_reg = "UNUSED",
            ucke_pad.power_up_high = "OFF",
            ucke_pad.width = 1;
            
	end
	endgenerate
		`endif
	`else
	assign cke_l = phy_ddio_cke_l;
	assign cke_h = phy_ddio_cke_h;

    altddio_out ucke_pad(
        .aclr       (~reset_n),
        .aset       (1'b0),
        .datain_h   (cke_l),
        .datain_l   (cke_h),
        .dataout    (phy_mem_cke),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam
        ucke_pad.extend_oe_disable = "UNUSED",
        ucke_pad.intended_device_family = DEVICE_FAMILY,
        ucke_pad.invert_output = "OFF",
        ucke_pad.lpm_hint = "UNUSED",
        ucke_pad.lpm_type = "altddio_out",
        ucke_pad.oe_reg = "UNUSED",
        ucke_pad.power_up_high = "OFF",
        ucke_pad.width = MEM_CLK_EN_WIDTH;
	`endif
`endif

`ifdef DDRX
	`ifndef LPDDR1
    altddio_out uodt_pad(
        .aclr       (~reset_n),
        .aset       (1'b0),
        .datain_h   (phy_ddio_odt_l),
        .datain_l   (phy_ddio_odt_h),
        .dataout    (phy_mem_odt),
        .oe         (1'b1),
        .outclock   (phy_ddio_addr_cmd_clk),
        .outclocken (1'b1)
    );

    defparam
        uodt_pad.extend_oe_disable = "UNUSED",
        uodt_pad.intended_device_family = DEVICE_FAMILY,
        uodt_pad.invert_output = "OFF",
        uodt_pad.lpm_hint = "UNUSED",
        uodt_pad.lpm_type = "altddio_out",
        uodt_pad.oe_reg = "UNUSED",
        uodt_pad.power_up_high = "OFF",
        uodt_pad.width = MEM_ODT_WIDTH;
	`endif

    altddio_out	uwe_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (phy_ddio_we_n_l),
		.datain_l   (phy_ddio_we_n_h),
		.dataout    (phy_mem_we_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		uwe_n_pad.extend_oe_disable = "UNUSED",
		uwe_n_pad.intended_device_family = DEVICE_FAMILY,
		uwe_n_pad.invert_output = "OFF",
		uwe_n_pad.lpm_hint = "UNUSED",
		uwe_n_pad.lpm_type = "altddio_out",
		uwe_n_pad.oe_reg = "UNUSED",
		uwe_n_pad.power_up_high = "OFF",
		uwe_n_pad.width = MEM_CONTROL_WIDTH;


    altddio_out	uras_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (phy_ddio_ras_n_l),
		.datain_l   (phy_ddio_ras_n_h),
		.dataout    (phy_mem_ras_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		uras_n_pad.extend_oe_disable = "UNUSED",
		uras_n_pad.intended_device_family = DEVICE_FAMILY,
		uras_n_pad.invert_output = "OFF",
		uras_n_pad.lpm_hint = "UNUSED",
		uras_n_pad.lpm_type = "altddio_out",
		uras_n_pad.oe_reg = "UNUSED",
		uras_n_pad.power_up_high = "OFF",
		uras_n_pad.width = MEM_CONTROL_WIDTH;



    altddio_out	ucas_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (phy_ddio_cas_n_l),
		.datain_l   (phy_ddio_cas_n_h),
		.dataout    (phy_mem_cas_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		ucas_n_pad.extend_oe_disable = "UNUSED",
		ucas_n_pad.intended_device_family = DEVICE_FAMILY,
		ucas_n_pad.invert_output = "OFF",
		ucas_n_pad.lpm_hint = "UNUSED",
		ucas_n_pad.lpm_type = "altddio_out",
		ucas_n_pad.oe_reg = "UNUSED",
		ucas_n_pad.power_up_high = "OFF",
		ucas_n_pad.width = MEM_CONTROL_WIDTH;

	`ifdef DDR3
    altddio_out	ureset_n_pad(
		.aclr	    (1'b0),
		.aset	    (~reset_n),
		.datain_h   (phy_ddio_reset_n_l),
		.datain_l   (phy_ddio_reset_n_h),
		.dataout    (phy_mem_reset_n),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		ureset_n_pad.extend_oe_disable = "UNUSED",
		ureset_n_pad.intended_device_family = DEVICE_FAMILY,
		ureset_n_pad.invert_output = "OFF",
		ureset_n_pad.lpm_hint = "UNUSED",
		ureset_n_pad.lpm_type = "altddio_out",
		ureset_n_pad.oe_reg = "UNUSED",
		ureset_n_pad.power_up_high = "OFF",
		ureset_n_pad.width = MEM_CONTROL_WIDTH;
	`endif

	`ifdef AC_PARITY
		altddio_out	uac_par_pad(
		.aclr	    (~reset_n),
		.aset	    (1'b0),
		.datain_h   (phy_ddio_ac_par_l),
		.datain_l   (phy_ddio_ac_par_h),
		.dataout    (phy_mem_ac_parity),
		.oe	    	(1'b1),
		.outclock   (phy_ddio_addr_cmd_clk),
		.outclocken (1'b1)
    );

    defparam 
		uac_par_pad.extend_oe_disable = "UNUSED",
		uac_par_pad.intended_device_family = DEVICE_FAMILY,
		uac_par_pad.invert_output = "OFF",
		uac_par_pad.lpm_hint = "UNUSED",
		uac_par_pad.lpm_type = "altddio_out",
		uac_par_pad.oe_reg = "UNUSED",
		uac_par_pad.power_up_high = "OFF",
		uac_par_pad.width = MEM_CONTROL_WIDTH;
		
		reg parity_error_n;
		always @(posedge phy_ddio_addr_cmd_clk or negedge reset_n)
		begin
			if (~reset_n)
				parity_error_n <= 1'b1;
			else
				parity_error_n <= parity_error_n && &(phy_err_out_n);
		end
		assign phy_parity_error_n = parity_error_n;
	`endif
`endif

`ifdef DDRX_LPDDRX

  wire  [MEM_CK_WIDTH-1:0] mem_ck_source;
  wire	[MEM_CK_WIDTH-1:0] mem_ck;

`ifdef USE_2X_FF
	wire [3:0] delayed_dr_clocks;
	wire mem_dr_clk;
	`ifdef STRATIXV
	stratixv_leveling_delay_chain 
	`endif
	`ifdef ARRIAVGZ
	arriavgz_leveling_delay_chain 
	`endif
	#( 
		.physical_clock_source ("resync")
	) drchain (
		.clkin (pll_dr_clk),
		.delayctrlin (dll_delayctrl_in),
		.clkout(delayed_dr_clocks)
	);
	
	`ifdef STRATIXV	
	stratixv_clk_phase_select
	`endif
	`ifdef ARRIAVGZ
	arriavgz_clk_phase_select
	`endif
	#(
	  	.use_phasectrlin("false"),
		.phase_setting(3), 
		.invert_phase("false"),
		.physical_clock_source("ck_2x")
	) dq_dr_select (
		.clkin (delayed_dr_clocks),
		.clkout (mem_dr_clk)
	);
	
`endif

`ifdef DDRX
localparam USE_ADDR_CMD_CPS_FOR_MEM_CK = "true";
`else
localparam USE_ADDR_CMD_CPS_FOR_MEM_CK = "false";
`endif

generate
genvar clock_width;
    for (clock_width=0; clock_width<MEM_CK_WIDTH; clock_width=clock_width+1)
    begin: clock_gen


`ifdef DUPLICATE_PLL_FOR_PHY_CLK


if(USE_ADDR_CMD_CPS_FOR_MEM_CK == "true")
begin
     acv_ldc # (
     	.DLL_DELAY_CTRL_WIDTH(DLL_WIDTH),
     	.ADC_PHASE_SETTING(0),
     	.ADC_INVERT_PHASE("false"),
	.IS_HHP_HPS(IS_HHP_HPS)
     ) acv_ck_ldc (
     	.pll_hr_clk(pll_afi_phy_clk),
     	.pll_dq_clk(pll_write_clk),
     	.pll_dqs_clk (pll_mem_phy_clk),
     	.dll_phy_delayctrl (dll_delayctrl_in),
     	.adc_clk_cps (mem_ck_source[clock_width])
     );
end
else
begin
	wire [3:0] phy_clk_in;
	wire [3:0] phy_clk_out;
	assign phy_clk_in = {pll_afi_phy_clk,pll_write_clk,pll_mem_phy_clk,1'b0};
		
	`ifdef ARRIAV
	arriav_phy_clkbuf phy_clkbuf (
	`else
	cyclonev_phy_clkbuf phy_clkbuf (
	`endif
		.inclk (phy_clk_in),
		.outclk (phy_clk_out)
	);

	wire [3:0] leveled_dqs_clocks;
	`ifdef ARRIAV
	arriav_leveling_delay_chain leveling_delay_chain_dqs (
	`else
	cyclonev_leveling_delay_chain leveling_delay_chain_dqs (
	`endif
		.clkin (phy_clk_out[1]),
		.delayctrlin (dll_delayctrl_in),
		.clkout(leveled_dqs_clocks)
	);
	defparam leveling_delay_chain_dqs.physical_clock_source = "DQS";

	`ifdef ARRIAV
	arriav_clk_phase_select clk_phase_select_dqs (
	`else
	cyclonev_clk_phase_select clk_phase_select_dqs (
	`endif
		`ifndef SIMGEN
		.clkin(leveled_dqs_clocks[0]),
		`else
		.clkin(leveled_dqs_clocks),
		`endif
		.clkout(mem_ck_source[clock_width])
	);
	defparam clk_phase_select_dqs.physical_clock_source = "DQS";
	defparam clk_phase_select_dqs.use_phasectrlin = "false";
	defparam clk_phase_select_dqs.phase_setting = 0;
end

`else
  assign mem_ck_source[clock_width] = pll_mem_clk;
`endif


    altddio_out umem_ck_pad(
    	.aclr       (1'b0),
    	.aset       (1'b0),
`ifdef NON_LDC_ADDR_CMD_MEM_CK_INVERT
    	.datain_h   (1'b0),
    	.datain_l   (enable_mem_clk[clock_width]),
`else
    	.datain_h   (enable_mem_clk[clock_width]),
    	.datain_l   (1'b0),
`endif
    	.dataout    (mem_ck[clock_width]),
    	.oe     	(1'b1),
    	.outclock   (mem_ck_source[clock_width]),
    	.outclocken (1'b1)
    );

    defparam
    	umem_ck_pad.extend_oe_disable = "UNUSED",
    	umem_ck_pad.intended_device_family = DEVICE_FAMILY,
    	umem_ck_pad.invert_output = "OFF",
    	umem_ck_pad.lpm_hint = "UNUSED",
    	umem_ck_pad.lpm_type = "altddio_out",
    	umem_ck_pad.oe_reg = "UNUSED",
    	umem_ck_pad.power_up_high = "OFF",
    	umem_ck_pad.width = 1;

	wire mem_ck_temp;

`ifdef USE_2X_FF

	reg mem_ck_reg;
	always @(posedge mem_dr_clk)
		mem_ck_reg <= mem_ck [clock_width];

	assign mem_ck_temp = mem_ck_reg;
`else
	assign mem_ck_temp = mem_ck[clock_width];
`endif

    clock_pair_generator    uclk_generator(
        .datain     (mem_ck_temp),
        .dataout    (phy_mem_ck[clock_width]),
        .dataout_b  (phy_mem_ck_n[clock_width])
    );
	end
endgenerate

`endif

endmodule
