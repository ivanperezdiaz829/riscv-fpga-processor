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


// *****************************************************************
// File name: addr_cmd_ldc_pads.v
//
// Address/command pads using PHY clock and leveling hardware.
// 
// Inputs are addr/cmd signals in the AFI domain. 
// 
// Outputs are addr/cmd signals that can be readily connected to
// top-level ports going out to external memory.
// 
// This version offers higher performance than previous generation
// of addr/cmd pads. To highlight the differences:
// 
// 1) We use the PHY clock tree to clock the addr/cmd I/Os, instead
//    of core clock. The PHY clock tree has much smaller clock skew
//    compared to the core clock, giving us more timing margin.
// 
// 2) The PHY clock tree drives a leveling delay chain which
//    generates both the CK/CK# clock and the launch clock for the
//    addr/cmd signals. The similarity between the CK/CK# path and
//    the addr/cmd signal paths reduces timing margin loss due to
//    min/max. Previous generation uses separate PLL output counter
//    and global networks for CK/CK# and addr/cmd signals.
//
// Important clock signals:
//
// pll_afi_clk       -- AFI clock. Only used by 1/4-rate designs to
//                      convert 1/4 addr/cmd signals to 1/2 rate, or
//                      when REGISTER_C2P is true.
//
// pll_c2p_write_clk -- Half-rate clock that clocks the HR registers
//                      for 1/2-rate to full rate conversion. Only 
//                      used in 1/4 rate and 1/2 rate designs.
//                      This signal must come from the PHY clock.
// 
// pll_write_clk     -- Full-rate clock that goes into the leveling
//                      delay chain and then used to clock the SDIO
//                      register (or DDIO_OUT) and for CK/CK# generation.
//                      This signal must come from the PHY clock.
// 
// *****************************************************************

`timescale 1 ps / 1 ps

module addr_cmd_ldc_pads (
    reset_n,
    reset_n_afi_clk,
    pll_afi_clk,
    pll_mem_clk,
    pll_hr_clk,
    pll_c2p_write_clk,
    pll_write_clk,
    phy_ddio_addr_cmd_clk,
    phy_ddio_address,
    dll_delayctrl_in,
    enable_mem_clk,
`ifdef USE_DR_CLK
    pll_dr_clk,
`endif
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

// *****************************************************************
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in 
// from higher level wrapper with the controller and driver
parameter DEVICE_FAMILY             = "";
parameter DLL_WIDTH                 = "";
parameter REGISTER_C2P              = "";
parameter LDC_MEM_CK_CPS_PHASE      = "";

// Width of the addr/cmd signals going out to the external memory
parameter MEM_ADDRESS_WIDTH         = "";
parameter MEM_CONTROL_WIDTH         = ""; 

`ifdef RLDRAMX
parameter MEM_BANK_WIDTH            = ""; 
parameter MEM_CHIP_SELECT_WIDTH     = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter MEM_BANK_WIDTH            = ""; 
parameter MEM_CHIP_SELECT_WIDTH     = ""; 
parameter MEM_CLK_EN_WIDTH          = ""; 
parameter MEM_CK_WIDTH              = ""; 
parameter MEM_ODT_WIDTH             = ""; 
`else
localparam MEM_CK_WIDTH 			= 1; 
`endif

// Width of the addr/cmd signals coming in from the AFI
parameter AFI_ADDRESS_WIDTH         = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 

`ifdef RLDRAMX
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
`endif
`ifdef DDRX_LPDDRX
parameter AFI_BANK_WIDTH            = ""; 
parameter AFI_CHIP_SELECT_WIDTH     = ""; 
parameter AFI_CLK_EN_WIDTH          = ""; 
parameter AFI_ODT_WIDTH             = ""; 
`endif

// *****************************************************************
// BEGIN PORT SECTION

input   reset_n;
input   reset_n_afi_clk;
input   pll_afi_clk;
input   pll_mem_clk;
input   pll_write_clk;
input   pll_hr_clk;
input   pll_c2p_write_clk;
input   phy_ddio_addr_cmd_clk;
input   [DLL_WIDTH-1:0] dll_delayctrl_in;
input   [MEM_CK_WIDTH-1:0] enable_mem_clk;
`ifdef USE_DR_CLK
input   pll_dr_clk;
`endif

`ifdef RLDRAMX
input   [AFI_ADDRESS_WIDTH-1:0]     phy_ddio_address;
input   [AFI_BANK_WIDTH-1:0]        phy_ddio_bank;
input   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_we_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_ref_n;
 `ifdef RLDRAM3
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_reset_n;
 `endif

output  [MEM_ADDRESS_WIDTH-1:0]     phy_mem_address;
output  [MEM_BANK_WIDTH-1:0]        phy_mem_bank;
output  [MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_we_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_ref_n;
 `ifdef RLDRAM3
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_reset_n;
 `endif

output  phy_mem_ck;
output  phy_mem_ck_n;
`endif

`ifdef QDRII
input   [AFI_ADDRESS_WIDTH-1:0]     phy_ddio_address;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_wps_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_rps_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0]     phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_wps_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_rps_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_doff_n;
`endif

`ifdef DDRII_SRAM
input   [AFI_ADDRESS_WIDTH-1:0]     phy_ddio_address;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_ld_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_rw_n;

output  [MEM_ADDRESS_WIDTH-1:0]     phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_ld_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_rw_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_zq;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_doff_n;
`endif

`ifdef DDRX
input   [AFI_ADDRESS_WIDTH-1:0]     phy_ddio_address;
input   [AFI_BANK_WIDTH-1:0]        phy_ddio_bank;
input   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input   [AFI_CLK_EN_WIDTH-1:0]      phy_ddio_cke;
    `ifndef LPDDR1
input   [AFI_ODT_WIDTH-1:0]         phy_ddio_odt;
    `endif
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_ras_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_cas_n;
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_we_n;
    `ifdef AC_PARITY
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_ac_par;
    `endif
    `ifdef DDR3
input   [AFI_CONTROL_WIDTH-1:0]     phy_ddio_reset_n;
    `endif
    
output  [MEM_ADDRESS_WIDTH-1:0]     phy_mem_address;
output  [MEM_BANK_WIDTH-1:0]        phy_mem_bank;
output  [MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0]      phy_mem_cke;
    `ifndef LPDDR1
output  [MEM_ODT_WIDTH-1:0]         phy_mem_odt;
    `endif
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_we_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_ras_n;
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_cas_n;
    `ifdef AC_PARITY
output  [MEM_CONTROL_WIDTH-1:0]     phy_mem_ac_parity;
input   [MEM_CONTROL_WIDTH-1:0]     phy_err_out_n;
output                              phy_parity_error_n;
    `endif
    `ifdef DDR3
output                              phy_mem_reset_n;
    `endif
output  [MEM_CK_WIDTH-1:0]          phy_mem_ck;
output  [MEM_CK_WIDTH-1:0]          phy_mem_ck_n;
`endif

`ifdef LPDDR2
input   [AFI_ADDRESS_WIDTH-1:0]     phy_ddio_address;
input   [AFI_CHIP_SELECT_WIDTH-1:0] phy_ddio_cs_n;
input   [AFI_CLK_EN_WIDTH-1:0]      phy_ddio_cke;

output  [MEM_ADDRESS_WIDTH-1:0]     phy_mem_address;
output  [MEM_CHIP_SELECT_WIDTH-1:0] phy_mem_cs_n;
output  [MEM_CLK_EN_WIDTH-1:0]      phy_mem_cke;
output  [MEM_CK_WIDTH-1:0]          phy_mem_ck;
output  [MEM_CK_WIDTH-1:0]          phy_mem_ck_n;
`endif

// *****************************************************************
// Instantiate pads for every a/c signal

`ifdef RLDRAMX
addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_ADDRESS_WIDTH),
    .MEM_DATA_WIDTH (MEM_ADDRESS_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uaddress_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_address),
    .mem_dataout (phy_mem_address)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_BANK_WIDTH),
    .MEM_DATA_WIDTH (MEM_BANK_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ubank_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_bank),
    .mem_dataout (phy_mem_bank)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CHIP_SELECT_WIDTH),
    .MEM_DATA_WIDTH (MEM_CHIP_SELECT_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucs_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cs_n),
    .mem_dataout (phy_mem_cs_n)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uwe_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_we_n),
    .mem_dataout (phy_mem_we_n)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uref_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_ref_n),
    .mem_dataout (phy_mem_ref_n)
);

`ifdef RLDRAM3
addr_cmd_non_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ureset_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .afi_datain (phy_ddio_reset_n),
    .mem_dataout (phy_mem_reset_n)
);
`endif
`endif

`ifdef QDRII
addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_ADDRESS_WIDTH),
    .MEM_DATA_WIDTH (MEM_ADDRESS_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uaddress_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_address),
    .mem_dataout (phy_mem_address)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uwps_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_wps_n),
    .mem_dataout (phy_mem_wps_n)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) urps_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_rps_n),
    .mem_dataout (phy_mem_rps_n)
);

addr_cmd_non_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) udoff_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .afi_datain (phy_ddio_doff_n),
    .mem_dataout (phy_mem_doff_n)
);
`endif

`ifdef DDRX
addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_ADDRESS_WIDTH),
    .MEM_DATA_WIDTH (MEM_ADDRESS_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uaddress_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_address),
    .mem_dataout (phy_mem_address)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_BANK_WIDTH),
    .MEM_DATA_WIDTH (MEM_BANK_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ubank_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_bank),
    .mem_dataout (phy_mem_bank)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CHIP_SELECT_WIDTH),
    .MEM_DATA_WIDTH (MEM_CHIP_SELECT_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucs_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cs_n),
    .mem_dataout (phy_mem_cs_n)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CLK_EN_WIDTH),
    .MEM_DATA_WIDTH (MEM_CLK_EN_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucke_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cke),
    .mem_dataout (phy_mem_cke)
);

`ifndef LPDDR1
addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_ODT_WIDTH),
    .MEM_DATA_WIDTH (MEM_ODT_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uodt_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_odt),
    .mem_dataout (phy_mem_odt)
);
`endif

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uwe_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_we_n),
    .mem_dataout (phy_mem_we_n)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uras_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_ras_n),
    .mem_dataout (phy_mem_ras_n)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucas_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cas_n),
    .mem_dataout (phy_mem_cas_n)
);

`ifdef DDR3
addr_cmd_non_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ureset_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .afi_datain (phy_ddio_reset_n),
    .mem_dataout (phy_mem_reset_n)
);
`endif
		
`ifdef AC_PARITY
addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CONTROL_WIDTH),
    .MEM_DATA_WIDTH (MEM_CONTROL_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uac_par_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_ac_par),
    .mem_dataout (phy_mem_ac_parity)
);

assign phy_parity_error_n = 1'b1;
`endif
`endif

`ifdef LPDDR2
addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_ADDRESS_WIDTH),
    .MEM_DATA_WIDTH (MEM_ADDRESS_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) uaddress_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_address),
    .mem_dataout (phy_mem_address)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CHIP_SELECT_WIDTH),
    .MEM_DATA_WIDTH (MEM_CHIP_SELECT_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucs_n_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cs_n),
    .mem_dataout (phy_mem_cs_n)
);

addr_cmd_ldc_pad # (
    .AFI_DATA_WIDTH (AFI_CLK_EN_WIDTH),
    .MEM_DATA_WIDTH (MEM_CLK_EN_WIDTH),
    .DLL_WIDTH (DLL_WIDTH),
    .REGISTER_C2P (REGISTER_C2P)
) ucke_pad (
    .pll_afi_clk (pll_afi_clk),
    .pll_hr_clk (pll_hr_clk),
    .pll_c2p_write_clk (pll_c2p_write_clk),
    .pll_write_clk (pll_write_clk),
    .dll_delayctrl_in (dll_delayctrl_in),
    .afi_datain (phy_ddio_cke),
    .mem_dataout (phy_mem_cke)
);

`endif


`ifdef QDRII
`else
`ifdef DDRII_SRAM
`else
// *****************************************************************
// Instantiate CK/CK# generation circuitry if needed
genvar clock_width;
generate
    for (clock_width = 0; clock_width < MEM_CK_WIDTH; clock_width = clock_width + 1)
    begin: clock_gen
        wire [MEM_CK_WIDTH-1:0] mem_ck_ddio_out;	
        wire [3:0] delayed_clks;
        wire leveling_clk;

	`ifdef STRATIXV            
        stratixv_leveling_delay_chain # (
	`endif
	`ifdef ARRIAVGZ           
        arriavgz_leveling_delay_chain # (
	`endif
            .physical_clock_source  ("dqs")
        ) ldc (
            .clkin          (pll_write_clk),
            .delayctrlin    (dll_delayctrl_in),
            .clkout         (delayed_clks)
        );

`ifdef LPDDR2
	`ifdef STRATIXV
        stratixv_clk_phase_select # (
	`endif
	`ifdef ARRIAVGZ
        arriavgz_clk_phase_select # (
	`endif
            .physical_clock_source  ("dqs"),
            .use_phasectrlin        ("false"), 
            .invert_phase           ("false"), 
	`ifdef DLL_USE_DR_CLK
			.phase_setting          (3)        
	`else
			.phase_setting          (2)        
	`endif
        ) cps (
            .clkin  (delayed_clks),
            .clkout (leveling_clk),
            .phasectrlin(),
            .phaseinvertctrl(),
            .powerdown()
        );
`else
	`ifdef ENABLE_LDC_MEM_CK_ADJUSTMENT
		`ifdef STRATIXV
        stratixv_clk_phase_select # (
		`endif
		`ifdef ARRIAVGZ
        arriavgz_clk_phase_select # (
		`endif
            .physical_clock_source  ("dq"),
            .use_phasectrlin        ("false"),
		`ifdef LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT
            .invert_phase           ("true"), 
		`else
            .invert_phase           ("false"), 
		`endif
            .phase_setting          (LDC_MEM_CK_CPS_PHASE) 
        ) cps (
            .clkin  (delayed_clks),
            .clkout (leveling_clk),
            .phasectrlin(),
            .phaseinvertctrl(),
            .powerdown()
        );
	`else
		`ifdef STRATIXV
        stratixv_clk_phase_select # (
		`endif
		`ifdef ARRIAVGZ
        arriavgz_clk_phase_select # (
		`endif

            .physical_clock_source  ("add_cmd"),
            .use_phasectrlin        ("false"), 
            .invert_phase           ("false"), 
            .phase_setting          (0)        
        ) cps (
            .clkin  (delayed_clks),
            .clkout (leveling_clk),
            .phasectrlin(),
            .phaseinvertctrl(),
            .powerdown()
        );
	`endif
`endif		
	
        altddio_out # (
            .extend_oe_disable       ("UNUSED"),
            .intended_device_family  (DEVICE_FAMILY),
            .invert_output           ("OFF"),
            .lpm_hint                ("UNUSED"),
            .lpm_type                ("altddio_out"),
            .oe_reg                  ("UNUSED"),
            .power_up_high           ("OFF"),
            .width                   (1)
        ) umem_ck_pad (
            .aclr       (1'b0),
            .aset       (1'b0),
`ifdef LPDDR2
            .datain_h   (enable_mem_clk[clock_width]),  
            .datain_l   (1'b0),
`else
	`ifdef ENABLE_LDC_MEM_CK_ADJUSTMENT
            .datain_h   (enable_mem_clk[clock_width]),  
            .datain_l   (1'b0),
	`else
            .datain_h   (1'b0),  
            .datain_l   (enable_mem_clk[clock_width]),
	`endif
`endif
            .dataout    (mem_ck_ddio_out[clock_width]),
            .oe         (1'b1),
            .outclock   (leveling_clk),
            .outclocken (1'b1),
            .sset       (),
            .sclr       (),
            .oe_out     ()
        );

        clock_pair_generator uclk_generator (
            .datain     (mem_ck_ddio_out[clock_width]),
`ifdef RLDRAMX
            .dataout    (phy_mem_ck),
            .dataout_b  (phy_mem_ck_n)
`else                
            .dataout    (phy_mem_ck[clock_width]),
            .dataout_b  (phy_mem_ck_n[clock_width])
`endif                
        );
    end
endgenerate
`endif 
`endif 

endmodule
