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
// This file instantiates the PLL.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name IP_TOOL_NAME common; -name IP_TOOL_VERSION 13.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100; -name ALLOW_SYNCH_CTRL_USAGE OFF; -name AUTO_CLOCK_ENABLE_RECOGNITION OFF; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)

`ifdef PLL_MASTER
`ifdef DLL_MASTER
`else
// Quartus will merge compatible PLLs by default.
// Since DLL sharing was chosen without PLL sharing, the pin assignments
// will try to find the other PLLs and fail. Instead, tell Quartus to not merge the PLLs.
(* altera_attribute = "-name AUTO_MERGE_PLLS OFF" *)
`endif
`endif

module IPTCL_VARIANT_OUTPUT_NAME (
	global_reset_n,
	pll_ref_clk,
	pll_mem_clk,
	pll_write_clk,
	pll_write_clk_pre_phy_clk,
	pll_addr_cmd_clk,
`ifdef USE_DR_CLK
	pll_dr_clk,
	pll_dr_clk_pre_phy_clk,
`endif
`ifdef QUARTER_RATE
	pll_hr_clk,
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
	pll_p2c_read_clk,
	pll_c2p_write_clk,
`endif
`ifdef NIOS_SEQUENCER
	pll_avl_clk,
	pll_config_clk,
`endif
`ifdef DEBUG_PLL_DYN_PHASE_SHIFT 
	pll_scanclk,
	reset_n_pll_scanclk,
	pll_phasecounterselect,
	pll_phasestep,
	pll_phaseupdown,
	pll_phasedone,
`endif
	pll_locked,
`ifdef HCX_COMPAT_MODE
	hc_pll_config_configupdate,
	hc_pll_config_phasecounterselect,
	hc_pll_config_phasestep,
	hc_pll_config_phaseupdown,
	hc_pll_config_scanclk,
	hc_pll_config_scanclkena,
	hc_pll_config_scandata,
	hc_pll_config_phasedone,
	hc_pll_config_scandataout,
	hc_pll_config_scandone,
	hc_pll_config_locked,
`endif
	afi_clk,
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	pll_mem_phy_clk,
	afi_phy_clk,
	pll_avl_phy_clk,
`endif
	afi_half_clk
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

// The PLL Phase counter width
parameter PLL_PHASE_COUNTER_WIDTH = IPTCL_PLL_PHASE_COUNTER_WIDTH;

`ifdef HCX_COMPAT_MODE
parameter PLL_LOCATION = "IPTCL_PLL_LOCATION";
`endif

// Clock settings
parameter GENERIC_PLL = "IPTCL_GENERIC_PLL";
parameter REF_CLK_FREQ = "IPTCL_REF_CLK_FREQ_STR";
parameter REF_CLK_PERIOD_PS = IPTCL_REF_CLK_PERIOD_PS;

parameter PLL_AFI_CLK_FREQ_STR = "IPTCL_PLL_AFI_CLK_FREQ_STR";
parameter PLL_MEM_CLK_FREQ_STR = "IPTCL_PLL_MEM_CLK_FREQ_STR";
parameter PLL_WRITE_CLK_FREQ_STR = "IPTCL_PLL_WRITE_CLK_FREQ_STR";
parameter PLL_ADDR_CMD_CLK_FREQ_STR = "IPTCL_PLL_ADDR_CMD_CLK_FREQ_STR";
parameter PLL_AFI_HALF_CLK_FREQ_STR = "IPTCL_PLL_AFI_HALF_CLK_FREQ_STR";
parameter PLL_NIOS_CLK_FREQ_STR = "IPTCL_PLL_NIOS_CLK_FREQ_STR";
parameter PLL_CONFIG_CLK_FREQ_STR = "IPTCL_PLL_CONFIG_CLK_FREQ_STR";
parameter PLL_P2C_READ_CLK_FREQ_STR = "IPTCL_PLL_P2C_READ_CLK_FREQ_STR";
parameter PLL_C2P_WRITE_CLK_FREQ_STR = "IPTCL_PLL_C2P_WRITE_CLK_FREQ_STR";
parameter PLL_HR_CLK_FREQ_STR = "IPTCL_PLL_HR_CLK_FREQ_STR";
parameter PLL_DR_CLK_FREQ_STR = "IPTCL_PLL_DR_CLK_FREQ_STR";

parameter PLL_AFI_CLK_FREQ_SIM_STR = "IPTCL_PLL_AFI_CLK_FREQ_SIM_STR";
parameter PLL_MEM_CLK_FREQ_SIM_STR = "IPTCL_PLL_MEM_CLK_FREQ_SIM_STR";
parameter PLL_WRITE_CLK_FREQ_SIM_STR = "IPTCL_PLL_WRITE_CLK_FREQ_SIM_STR";
parameter PLL_ADDR_CMD_CLK_FREQ_SIM_STR = "IPTCL_PLL_ADDR_CMD_CLK_FREQ_SIM_STR";
parameter PLL_AFI_HALF_CLK_FREQ_SIM_STR = "IPTCL_PLL_AFI_HALF_CLK_FREQ_SIM_STR";
parameter PLL_NIOS_CLK_FREQ_SIM_STR = "IPTCL_PLL_NIOS_CLK_FREQ_SIM_STR";
parameter PLL_CONFIG_CLK_FREQ_SIM_STR = "IPTCL_PLL_CONFIG_CLK_FREQ_SIM_STR";
parameter PLL_P2C_READ_CLK_FREQ_SIM_STR = "IPTCL_PLL_P2C_READ_CLK_FREQ_SIM_STR";
parameter PLL_C2P_WRITE_CLK_FREQ_SIM_STR = "IPTCL_PLL_C2P_WRITE_CLK_FREQ_SIM_STR";
parameter PLL_HR_CLK_FREQ_SIM_STR = "IPTCL_PLL_HR_CLK_FREQ_SIM_STR";
parameter PLL_DR_CLK_FREQ_SIM_STR = "IPTCL_PLL_DR_CLK_FREQ_SIM_STR";

parameter AFI_CLK_PHASE      = "IPTCL_PLL_AFI_CLK_PHASE_PS_STR";
`ifdef DUPLICATE_PLL_FOR_PHY_CLK
parameter AFI_PHY_CLK_PHASE  = "IPTCL_PLL_AFI_PHY_CLK_PHASE_PS_STR";
`endif
parameter MEM_CLK_PHASE      = "IPTCL_PLL_MEM_CLK_PHASE_PS_STR";
parameter WRITE_CLK_PHASE    = "IPTCL_PLL_WRITE_CLK_PHASE_PS_STR";
parameter ADDR_CMD_CLK_PHASE = "IPTCL_PLL_ADDR_CMD_CLK_PHASE_PS_STR";
parameter AFI_HALF_CLK_PHASE = "IPTCL_PLL_AFI_HALF_CLK_PHASE_PS_STR";
`ifdef NIOS_SEQUENCER
parameter AVL_CLK_PHASE      = "IPTCL_PLL_NIOS_CLK_PHASE_PS_STR";
parameter CONFIG_CLK_PHASE   = "IPTCL_PLL_CONFIG_CLK_PHASE_PS_STR";
`endif
`ifdef QUARTER_RATE
parameter HR_CLK_PHASE       = "IPTCL_PLL_HR_CLK_PHASE_PS_STR";
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
parameter P2C_READ_CLK_PHASE  = "IPTCL_PLL_P2C_READ_CLK_PHASE_PS_STR";
parameter C2P_WRITE_CLK_PHASE = "IPTCL_PLL_C2P_WRITE_CLK_PHASE_PS_STR";
`endif	
`ifdef USE_DR_CLK
parameter DR_CLK_PHASE       = "IPTCL_PLL_DR_CLK_PHASE_PS_STR";
`endif

`ifdef DUAL_WRITE_CLOCK
parameter MEM_CLK_PHASE_SIM       = "IPTCL_PLL_MEM_CLK_PHASE_PS_SIM_STR";
parameter WRITE_CLK_PHASE_SIM     = "IPTCL_PLL_WRITE_CLK_PHASE_PS_SIM_STR";
`else
	`ifdef DUPLICATE_PLL_FOR_PHY_CLK
parameter MEM_CLK_PHASE_SIM       = "IPTCL_PLL_MEM_CLK_PHASE_PS_SIM_STR";
parameter WRITE_CLK_PHASE_SIM     = "IPTCL_PLL_WRITE_CLK_PHASE_PS_SIM_STR";
parameter ADDR_CMD_CLK_PHASE_SIM  = "IPTCL_PLL_ADDR_CMD_CLK_PHASE_PS_SIM_STR";
	`endif
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
parameter P2C_READ_CLK_PHASE_SIM  = "IPTCL_PLL_P2C_READ_CLK_PHASE_PS_SIM_STR";
parameter C2P_WRITE_CLK_PHASE_SIM = "IPTCL_PLL_C2P_WRITE_CLK_PHASE_PS_SIM_STR";
`endif	


parameter ABSTRACT_REAL_COMPARE_TEST = "IPTCL_ABSTRACT_REAL_COMPARE_TEST";

localparam SIM_FILESET = ("IPTCL_SIM_FILESET" == "true");

localparam AFI_CLK_FREQ       = SIM_FILESET ? PLL_AFI_CLK_FREQ_SIM_STR : PLL_AFI_CLK_FREQ_STR;
localparam MEM_CLK_FREQ       = SIM_FILESET ? PLL_MEM_CLK_FREQ_SIM_STR : PLL_MEM_CLK_FREQ_STR;
localparam WRITE_CLK_FREQ     = SIM_FILESET ? PLL_WRITE_CLK_FREQ_SIM_STR : PLL_WRITE_CLK_FREQ_STR;
localparam ADDR_CMD_CLK_FREQ  = SIM_FILESET ? PLL_ADDR_CMD_CLK_FREQ_SIM_STR : PLL_ADDR_CMD_CLK_FREQ_STR;
localparam AFI_HALF_CLK_FREQ  = SIM_FILESET ? PLL_AFI_HALF_CLK_FREQ_SIM_STR : PLL_AFI_HALF_CLK_FREQ_STR;
localparam AVL_CLK_FREQ       = SIM_FILESET ? PLL_NIOS_CLK_FREQ_SIM_STR : PLL_NIOS_CLK_FREQ_STR;
localparam CONFIG_CLK_FREQ    = SIM_FILESET ? PLL_CONFIG_CLK_FREQ_SIM_STR : PLL_CONFIG_CLK_FREQ_STR;
localparam P2C_READ_CLK_FREQ  = SIM_FILESET ? PLL_P2C_READ_CLK_FREQ_SIM_STR : PLL_P2C_READ_CLK_FREQ_STR;
localparam C2P_WRITE_CLK_FREQ = SIM_FILESET ? PLL_C2P_WRITE_CLK_FREQ_SIM_STR : PLL_C2P_WRITE_CLK_FREQ_STR;
localparam HR_CLK_FREQ        = SIM_FILESET ? PLL_HR_CLK_FREQ_SIM_STR : PLL_HR_CLK_FREQ_STR;
localparam DR_CLK_FREQ        = SIM_FILESET ? PLL_DR_CLK_FREQ_SIM_STR : PLL_DR_CLK_FREQ_STR;

`ifdef GENERIC_PLL
`else
parameter PLL_AFI_CLK_DIV           = IPTCL_PLL_AFI_CLK_DIV;
parameter PLL_MEM_CLK_DIV           = IPTCL_PLL_MEM_CLK_DIV;
parameter PLL_WRITE_CLK_DIV         = IPTCL_PLL_WRITE_CLK_DIV;
parameter PLL_ADDR_CMD_CLK_DIV      = IPTCL_PLL_ADDR_CMD_CLK_DIV;
parameter PLL_AFI_HALF_CLK_DIV      = IPTCL_PLL_AFI_HALF_CLK_DIV;
	`ifdef NIOS_SEQUENCER
parameter PLL_NIOS_CLK_DIV          = IPTCL_PLL_NIOS_CLK_DIV;
parameter PLL_CONFIG_CLK_DIV        = IPTCL_PLL_CONFIG_CLK_DIV;
	`endif
	`ifdef QUARTER_RATE
parameter PLL_HR_CLK_DIV            = IPTCL_PLL_HR_CLK_DIV;
	`endif

parameter PLL_AFI_CLK_MULT          = IPTCL_PLL_AFI_CLK_MULT;
parameter PLL_MEM_CLK_MULT          = IPTCL_PLL_MEM_CLK_MULT;
parameter PLL_WRITE_CLK_MULT        = IPTCL_PLL_WRITE_CLK_MULT;
parameter PLL_ADDR_CMD_CLK_MULT     = IPTCL_PLL_ADDR_CMD_CLK_MULT;
parameter PLL_AFI_HALF_CLK_MULT     = IPTCL_PLL_AFI_HALF_CLK_MULT;
	`ifdef NIOS_SEQUENCER
parameter PLL_NIOS_CLK_MULT         = IPTCL_PLL_NIOS_CLK_MULT;
parameter PLL_CONFIG_CLK_MULT       = IPTCL_PLL_CONFIG_CLK_MULT;
	`endif
	`ifdef QUARTER_RATE
parameter PLL_HR_CLK_MULT            = IPTCL_PLL_HR_CLK_MULT;
	`endif

parameter PLL_AFI_CLK_PHASE_PS      = "IPTCL_PLL_AFI_CLK_PHASE_PS";
parameter PLL_MEM_CLK_PHASE_PS      = "IPTCL_PLL_MEM_CLK_PHASE_PS";
parameter PLL_WRITE_CLK_PHASE_PS    = "IPTCL_PLL_WRITE_CLK_PHASE_PS";
parameter PLL_ADDR_CMD_CLK_PHASE_PS = "IPTCL_PLL_ADDR_CMD_CLK_PHASE_PS";
parameter PLL_AFI_HALF_CLK_PHASE_PS = "IPTCL_PLL_AFI_HALF_CLK_PHASE_PS";
	`ifdef NIOS_SEQUENCER
parameter PLL_NIOS_CLK_PHASE_PS     = "IPTCL_PLL_NIOS_CLK_PHASE_PS";
parameter PLL_CONFIG_CLK_PHASE_PS   = "IPTCL_PLL_CONFIG_CLK_PHASE_PS";
	`endif
	`ifdef QUARTER_RATE
parameter PLL_HR_CLK_PHASE_PS       = "IPTCL_PLL_HR_CLK_PHASE_PS";
	`endif
`endif

// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION


input	pll_ref_clk;		// PLL reference clock

// When the PHY is selected to be a PLL/DLL MASTER, the PLL and DLL are instantied on this top level
wire	pll_afi_clk;		// See pll_memphy instantiation below for detailed description of each clock

output	pll_mem_clk;
output	pll_write_clk;
output	pll_write_clk_pre_phy_clk;
output	pll_addr_cmd_clk;
`ifdef QUARTER_RATE
output	pll_hr_clk;
`endif
`ifdef CORE_PERIPHERY_DUAL_CLOCK
output	pll_p2c_read_clk;
output	pll_c2p_write_clk;
`endif
`ifdef USE_DR_CLK
output pll_dr_clk;
output pll_dr_clk_pre_phy_clk;
`endif
`ifdef NIOS_SEQUENCER
output	pll_avl_clk;
output	pll_config_clk;
`endif
output	pll_locked;    // When 0, PLL is out of lock
                       // should be used to reset system level afi_clk domain logic


`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
input	[3:0] pll_phasecounterselect;
input	pll_phasestep;    
input	pll_phaseupdown;  
output	pll_phasedone;    
output	pll_scanclk;
output	reset_n_pll_scanclk;
`endif

// Reset Interface, AFI 2.0
input   global_reset_n;		// Resets (active-low) the whole system (all PHY logic + PLL)


`ifdef HCX_COMPAT_MODE
input hc_pll_config_configupdate;
input [PLL_PHASE_COUNTER_WIDTH-1:0] hc_pll_config_phasecounterselect;
input hc_pll_config_phasestep;
input hc_pll_config_phaseupdown;
input hc_pll_config_scanclk;
input hc_pll_config_scanclkena;
input hc_pll_config_scandata;
output hc_pll_config_phasedone;
output hc_pll_config_scandataout;
output hc_pll_config_scandone;
output hc_pll_config_locked;
`endif


// PLL Interface
output	afi_clk;
output	afi_half_clk;
`ifdef CTL_HRB_ENABLED
wire	pll_afi_half_clk;
`else
`ifdef EXPORT_AFI_HALF_CLK
wire	pll_afi_half_clk;
`endif
`endif

`ifdef DUPLICATE_PLL_FOR_PHY_CLK
output	pll_mem_phy_clk;
output	afi_phy_clk;
output	pll_avl_phy_clk;
`endif

wire	pll_mem_clk_pre_phy_clk;

`ifdef BREAK_EXPORTED_AFI_CLK_DOMAIN
reg afi_clk_export;
`endif


// END PARAMETER SECTION
// ******************************************************************************************************************************** 

initial $display("Using %0s pll emif simulation models", FAST_SIM_MODEL ? "Fast" : "Regular");


`ifdef GENERIC_PLL
	wire fbout;
	
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
	wire pll_c2p_write_clk_pre_phy_clk;	
	`endif

	generic_pll pll1 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_afi_clk),
		.fboutclk(fbout),
		.locked(pll_locked),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll1.reference_clock_frequency = REF_CLK_FREQ,
		pll1.output_clock_frequency = AFI_CLK_FREQ,
		pll1.phase_shift = AFI_CLK_PHASE,
		pll1.duty_cycle = 50;
		
	`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	generic_pll pll1_phy (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(afi_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								

	);	
	defparam pll1_phy.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll1_phy.output_clock_frequency = AFI_CLK_FREQ;
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll1_phy.phase_shift = AFI_CLK_PHASE;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll1_phy.phase_shift = AFI_CLK_PHASE;
`else
	// defparam pll1_phy.phase_shift = AFI_PHY_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
	defparam pll1_phy.duty_cycle = 50;
	`endif
	
	`ifdef DUAL_WRITE_CLOCK
	generic_pll pll2 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_mem_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
  	.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								

	);	
	defparam pll2.reference_clock_frequency = REF_CLK_FREQ,
		pll2.output_clock_frequency = MEM_CLK_FREQ,
		pll2.duty_cycle = 50;
		
	// pll_mem_clk is used for data output and pll_write_clk is used for
	// output strobe generation. pll_mem_clk always leads pll_write_clk by 90
	// degree. For timing closure reasons the actual phases vary depending
	// on frequencies. In simulation we fix the pll_write_clk phase
	// to 135 degree and the the pll_mem_clk 45 degree, to avoid false sim
	// failures.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
	// synthesis translate_on
	
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
	// defparam pll2.phase_shift = MEM_CLK_PHASE;
	// synthesis read_comments_as_HDL off
`endif
	`else
	`ifdef USE_LDC_AS_LOW_SKEW_CLOCK
	assign pll_mem_clk_pre_phy_clk = 1'b0;
	`else
		`ifdef USE_LDC_FOR_ADDR_CMD
	assign pll_mem_clk_pre_phy_clk = 1'b0;
		`else	
	generic_pll pll2 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_mem_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								

	);	
	defparam pll2.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll2.output_clock_frequency = MEM_CLK_FREQ;
			`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
`else
	// defparam pll2.phase_shift = MEM_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
			`else
	defparam pll2.phase_shift = MEM_CLK_PHASE;
			`endif
	defparam pll2.duty_cycle = 50;
			
			`ifdef DUPLICATE_PLL_FOR_PHY_CLK
			
	generic_pll pll2_phy (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_mem_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll2_phy.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll2_phy.output_clock_frequency = MEM_CLK_FREQ;
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll2_phy.phase_shift = MEM_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll2_phy.phase_shift = MEM_CLK_PHASE_SIM;
`else
	// defparam pll2_phy.phase_shift = MEM_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
	defparam pll2_phy.duty_cycle = 50;
			`endif
		`endif
	`endif
	`endif

	`ifdef DUAL_WRITE_CLOCK
	generic_pll pll3 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_write_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll3.reference_clock_frequency = REF_CLK_FREQ,
		pll3.output_clock_frequency = WRITE_CLK_FREQ,
		pll3.duty_cycle = 50;
		
	// pll_mem_clk is used for data output and pll_write_clk is used for
	// output strobe generation. pll_mem_clk always leads pll_write_clk by 90
	// degree. For timing closure reasons the actual phases vary depending
	// on frequencies. In simulation we fix the pll_write_clk phase
	// to 135 degree and the the pll_mem_clk 45 degree, to avoid false sim
	// failures.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
	// synthesis translate_on
	
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
	// defparam pll3.phase_shift = WRITE_CLK_PHASE;
	// synthesis read_comments_as_HDL off		
`endif	
	`else
	generic_pll pll3 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_write_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll3.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll3.output_clock_frequency = WRITE_CLK_FREQ;
		`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
`else
	// defparam pll3.phase_shift = WRITE_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
		`else
	defparam pll3.phase_shift = WRITE_CLK_PHASE;
		`endif
	defparam pll3.duty_cycle = 50;
	`endif

	`ifdef USE_LDC_FOR_ADDR_CMD
	assign pll_addr_cmd_clk = 1'b0;
	`else		
	generic_pll pll4 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_addr_cmd_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll4.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll4.output_clock_frequency = ADDR_CMD_CLK_FREQ;
		`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll4.phase_shift = ADDR_CMD_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll4.phase_shift = ADDR_CMD_CLK_PHASE_SIM;
`else
	// defparam pll4.phase_shift = ADDR_CMD_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
		`else
	defparam pll4.phase_shift = ADDR_CMD_CLK_PHASE;
		`endif
	defparam pll4.duty_cycle = 50;
	`endif

	 `ifdef CTL_HRB_ENABLED
	generic_pll pll5 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_afi_half_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll5.reference_clock_frequency = REF_CLK_FREQ,
		pll5.output_clock_frequency = AFI_HALF_CLK_FREQ,
		pll5.phase_shift = AFI_HALF_CLK_PHASE,
		pll5.duty_cycle = 50;
	`else
	`ifdef EXPORT_AFI_HALF_CLK
	generic_pll pll5 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_afi_half_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll5.reference_clock_frequency = REF_CLK_FREQ,
		pll5.output_clock_frequency = AFI_HALF_CLK_FREQ,
		pll5.phase_shift = AFI_HALF_CLK_PHASE,
		pll5.duty_cycle = 50;
	`endif
	`endif 
	 
		`ifdef NIOS_SEQUENCER
	generic_pll pll6 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_avl_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll6.reference_clock_frequency = REF_CLK_FREQ,
		pll6.output_clock_frequency = AVL_CLK_FREQ,
		pll6.phase_shift = AVL_CLK_PHASE,
		pll6.duty_cycle = 50;
		
			`ifdef DUPLICATE_PLL_FOR_PHY_CLK
	generic_pll pll6_phy (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_avl_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll6_phy.reference_clock_frequency = REF_CLK_FREQ,
		pll6_phy.output_clock_frequency = AVL_CLK_FREQ,
		pll6_phy.phase_shift = AVL_CLK_PHASE,
		pll6_phy.duty_cycle = 50;
			`endif

	generic_pll pll7 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_config_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll7.reference_clock_frequency = REF_CLK_FREQ,
		pll7.output_clock_frequency = CONFIG_CLK_FREQ,
		pll7.phase_shift = CONFIG_CLK_PHASE,
		pll7.duty_cycle = 50;
	
		`endif
		
		`ifdef QUARTER_RATE
	generic_pll pll8 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_hr_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll8.reference_clock_frequency = REF_CLK_FREQ,
		pll8.output_clock_frequency = HR_CLK_FREQ,
		pll8.phase_shift = HR_CLK_PHASE,
		pll8.duty_cycle = 50;		
		`endif
		
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
			`ifdef QUARTER_RATE
	generic_pll pll9 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_p2c_read_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll9.reference_clock_frequency = REF_CLK_FREQ,
		pll9.output_clock_frequency = P2C_READ_CLK_FREQ,
		pll9.duty_cycle = 50;		
		
	// The purpose of pll_p2c_read_clk is to help timing closure by offseting the
	// periphery-2-core delays. The phase shift can cause zero-delay simulation to
	// fail. Therefore, the following ensures that the phase shift is 0 if the design
	// is for simulation purpose.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll9.phase_shift = P2C_READ_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll9.phase_shift = P2C_READ_CLK_PHASE_SIM;
	// synthesis translate_on
		
	// The following is evaluated for physical realization 
	// synthesis read_comments_as_HDL on
	// defparam pll9.phase_shift = P2C_READ_CLK_PHASE;
	// synthesis read_comments_as_HDL off
`endif
			`else
	assign pll_p2c_read_clk = 1'b0;
			`endif

			`ifdef FULL_RATE
	assign pll_c2p_write_clk_pre_phy_clk = 1'b0;
			`else
	generic_pll pll10 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_c2p_write_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll10.reference_clock_frequency = REF_CLK_FREQ,
		pll10.output_clock_frequency = C2P_WRITE_CLK_FREQ,	
		pll10.duty_cycle = 50;

	// The purpose of pll_c2p_write_clk is to help timing closure by offseting the
	// core-2-periphery delays. The phase shift can cause zero-delay simulation to
	// fail. Therefore, the following ensures that the phase shift is 0 if the design
	// is for simulation purpose.
`ifdef SYNTH_FOR_SIM
	// The following is evaluated for post-fit 0-delay simulation
	defparam pll10.phase_shift = C2P_WRITE_CLK_PHASE_SIM;
`else
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll10.phase_shift = C2P_WRITE_CLK_PHASE_SIM;
	// synthesis translate_on
	
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
	// defparam pll10.phase_shift = C2P_WRITE_CLK_PHASE;
	// synthesis read_comments_as_HDL off
`endif		
			`endif 
		`endif 

`ifdef USE_DR_CLK
	generic_pll pll11 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_dr_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll11.reference_clock_frequency = REF_CLK_FREQ,
		pll11.output_clock_frequency = DR_CLK_FREQ,
		pll11.phase_shift = DR_CLK_PHASE,
		pll11.duty_cycle = 50;	
`endif


`ifndef SIMGEN		
	`ifdef PHY_CLKBUF
	wire [3:0] in_phyclk;
	wire [3:0] out_phyclk;

	assign in_phyclk[0] = pll_write_clk_pre_phy_clk;
	assign pll_write_clk = out_phyclk[0];

	`ifdef DUAL_WRITE_CLOCK
	assign in_phyclk[1] = pll_mem_clk_pre_phy_clk;
	assign pll_mem_clk = out_phyclk[1];
	`else	
	assign in_phyclk[1] = 1'b1;
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;
	`endif
	
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
			`ifdef FULL_RATE
	assign in_phyclk[2] = 1'b1;
	assign pll_c2p_write_clk = pll_c2p_write_clk_pre_phy_clk;
			`else
	assign in_phyclk[2] = pll_c2p_write_clk_pre_phy_clk;
	assign pll_c2p_write_clk = out_phyclk[2];	
			`endif
		`else
	assign in_phyclk[2] = 1'b1;
		`endif

		`ifdef USE_DR_CLK	
	assign in_phyclk[3] = pll_dr_clk_pre_phy_clk;
	assign pll_dr_clk = out_phyclk[3];
		`else
	assign in_phyclk[3] = 1'b1;
		`endif

	stratixv_phy_clkbuf uphy_clkbuf_memphy (
		.inclk(in_phyclk),
		.outclk(out_phyclk)
	);
	`else		
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
	assign pll_c2p_write_clk = pll_c2p_write_clk_pre_phy_clk;	
		`endif
		`ifdef USE_DR_CLK
	assign pll_dr_clk = pll_dr_clk_pre_phy_clk;
		`endif
	`endif 
`else 
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
	assign pll_c2p_write_clk = pll_c2p_write_clk_pre_phy_clk;	
		`endif
		`ifdef USE_DR_CLK
	assign pll_dr_clk = pll_dr_clk_pre_phy_clk;
		`endif
`endif 



`else 



localparam NUM_PLL = 10; 
				

generate
if (FAST_SIM_MODEL)
begin


`ifndef SIMGEN
	// synthesis translate_off
`endif
	
	wire fbout;


	wire [NUM_PLL-1:0] pll_clks;
	
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
	wire pll_c2p_write_clk_pre_phy_clk;	
	`endif

	altera_pll #(
	      .reference_clock_frequency(REF_CLK_FREQ),
	      .sim_additional_refclk_cycles_to_lock(4), 
	      .number_of_clocks(NUM_PLL),
	      .output_clock_frequency0(AFI_CLK_FREQ),
	      .phase_shift0(AFI_CLK_PHASE),
	      .duty_cycle0(50),
	      .output_clock_frequency1(MEM_CLK_FREQ),
	      .phase_shift1(MEM_CLK_PHASE),
	      .duty_cycle1(50),
	      .output_clock_frequency2(WRITE_CLK_FREQ),
	      .phase_shift2(WRITE_CLK_PHASE),
	      .duty_cycle2(50),
	      .output_clock_frequency3(ADDR_CMD_CLK_FREQ),
	      .phase_shift3(ADDR_CMD_CLK_PHASE),
	      .duty_cycle3(50),
	      .output_clock_frequency4(AFI_HALF_CLK_FREQ),
	      .phase_shift4(AFI_HALF_CLK_PHASE),
	      .duty_cycle4(50),
		`ifdef NIOS_SEQUENCER
	      .output_clock_frequency5(AVL_CLK_FREQ),
	      .phase_shift5(AVL_CLK_PHASE),
	      .duty_cycle5(50),
	      .output_clock_frequency6(CONFIG_CLK_FREQ),
	      .phase_shift6(CONFIG_CLK_PHASE),
	      .duty_cycle6(50),
		`else
	      .output_clock_frequency5(AFI_CLK_FREQ),
	      .phase_shift5("0 ps"),
	      .duty_cycle5(50),
	      .output_clock_frequency6(AFI_CLK_FREQ),
	      .phase_shift6("0 ps"),
	      .duty_cycle6(50),
		`endif
		`ifdef QUARTER_RATE
	      .output_clock_frequency7(HR_CLK_FREQ),
	      .phase_shift7(HR_CLK_PHASE),
	      .duty_cycle7(50),
		`else
	      .output_clock_frequency7(AFI_CLK_FREQ),
	      .phase_shift7("0 ps"),
	      .duty_cycle7(50),
		`endif
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
	      .output_clock_frequency8(P2C_READ_CLK_FREQ),
	      .phase_shift8("0 ps"), 
	      .duty_cycle8(50),
	      .output_clock_frequency9(C2P_WRITE_CLK_FREQ),
	      .phase_shift9("0 ps"), 
	      .duty_cycle9(50)
		`else
	      .output_clock_frequency8(AFI_CLK_FREQ),
	      .phase_shift8("0 ps"),
	      .duty_cycle8(50),
	      .output_clock_frequency9(AFI_CLK_FREQ),
	      .phase_shift9("0 ps"),
	      .duty_cycle9(50)
		`endif
		     ) pll_inst (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_clks),
		.fboutclk(fbout),
		.locked(pll_locked)
	);

	wire delayed_pll_locked_pre;
	wire delayed_pll_locked;
`ifndef SIMGEN
	assign #1 delayed_pll_locked_pre = pll_locked;
`else
	sim_delay #(.delay(1)) sim_delay_inst(.o(delayed_pll_locked_pre), .i(pll_locked));
`endif

	reg default_pll_clk_value = 1'b0;
	
	initial
	begin
		repeat (6) @(negedge pll_ref_clk);
		default_pll_clk_value = 1'bx;
		repeat (2) @(negedge pll_ref_clk);
		default_pll_clk_value = 1'b1;
	end

	
	assign delayed_pll_locked = delayed_pll_locked_pre === 1'b1 ? 1'b1 : 1'b0;

	assign pll_afi_clk = delayed_pll_locked ? pll_clks[0] : default_pll_clk_value;
	assign pll_mem_clk_pre_phy_clk = delayed_pll_locked ? pll_clks[1] : default_pll_clk_value;
	assign pll_write_clk_pre_phy_clk = delayed_pll_locked ? pll_clks[2] : default_pll_clk_value;
	assign pll_addr_cmd_clk = delayed_pll_locked ? pll_clks[3] : default_pll_clk_value;
`ifdef CTL_HRB_ENABLED
	assign pll_afi_half_clk = delayed_pll_locked ? pll_clks[4] : default_pll_clk_value;
`else
`ifdef EXPORT_AFI_HALF_CLK
	assign pll_afi_half_clk = delayed_pll_locked ? pll_clks[4] : default_pll_clk_value;
`endif
`endif
		
	`ifdef NIOS_SEQUENCER
	assign pll_avl_clk = delayed_pll_locked ? pll_clks[5] : default_pll_clk_value;
	assign pll_config_clk = delayed_pll_locked ? pll_clks[6] : default_pll_clk_value;
	`endif
		
	`ifdef QUARTER_RATE
	assign pll_hr_clk = delayed_pll_locked ? pll_clks[7] : default_pll_clk_value;
	`endif
		
	`ifdef CORE_PERIPHERY_DUAL_CLOCK
	assign pll_p2c_read_clk = delayed_pll_locked ? pll_clks[8] : default_pll_clk_value;
	assign pll_c2p_write_clk_pre_phy_clk = delayed_pll_locked ? pll_clks[9] : default_pll_clk_value;
	`endif


`ifndef SIMGEN	
	`ifdef PHY_CLKBUF
	wire [3:0] in_phyclk;
	wire [3:0] out_phyclk;

	assign in_phyclk[0] = pll_write_clk_pre_phy_clk;
	assign pll_write_clk = out_phyclk[0];
	
	`ifdef DUAL_WRITE_CLOCK
	assign in_phyclk[1] = pll_mem_clk_pre_phy_clk;
	assign pll_mem_clk = out_phyclk[1];
	`else
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;
	assign in_phyclk[1] = 1'b1;
	`endif
	
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
	assign in_phyclk[2] = pll_c2p_write_clk_pre_phy_clk;
	assign pll_c2p_write_clk = out_phyclk[2];
		`else
	assign in_phyclk[2] = 1'b1;
		`endif
	
	assign in_phyclk[3] = 1'b1;

	stratixv_phy_clkbuf uphy_clkbuf_memphy (
		.inclk(in_phyclk),
		.outclk(out_phyclk)
	);
	`else		
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
	assign pll_c2p_write_clk = pll_c2p_write_clk_pre_phy_clk;	
		`endif
	`endif 
`else 
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
		`ifdef CORE_PERIPHERY_DUAL_CLOCK
	assign pll_c2p_write_clk = pll_c2p_write_clk_pre_phy_clk;	
		`endif
`endif 

`ifndef SIMGEN
	// synthesis translate_on
`endif
	
end
else 
begin


	wire [NUM_PLL-1:0] pll_clks;
	wire [1:0] inclk;
	`ifdef HCX_COMPAT_MODE
	wire phasedone;
	wire scanclk;
	wire scandataout;
	wire scandone;
	`endif
	`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
	wire [PLL_PHASE_COUNTER_WIDTH-1:0]  phasecounterselect;
	wire phasedone;
	`endif

	`ifndef ALTERA_RESERVED_QIS
	//synopsys translate_off
	`endif
	tri0	  areset;
	`ifdef HCX_COMPAT_MODE
	tri0	  configupdate;
	tri0	[PLL_PHASE_COUNTER_WIDTH-1:0]  phasecounterselect;
	tri0	  phasestep;
	tri0	  phaseupdown;
	tri0	  scanclkena;
	tri0	  scandata;
	`endif
	`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
	tri0	[PLL_PHASE_COUNTER_WIDTH-1:0]  phasecounterselect;
	tri0	  phasestep;
	tri0	  phaseupdown;
	`endif
	`ifndef ALTERA_RESERVED_QIS
	//synopsys translate_on
	`endif

	assign areset = ~global_reset_n;
	assign inclk = {1'b0, pll_ref_clk};
	`ifdef HCX_COMPAT_MODE
	assign configupdate = hc_pll_config_configupdate;
	assign phasecounterselect = hc_pll_config_phasecounterselect;
	assign hc_pll_config_phasedone = phasedone;
	assign phasestep = hc_pll_config_phasestep;
	assign phaseupdown = hc_pll_config_phaseupdown;
	assign scanclk = hc_pll_config_scanclk;
	assign scanclkena = hc_pll_config_scanclkena;
	assign scandata = hc_pll_config_scandata;
	assign hc_pll_config_scandataout = scandataout;
	assign hc_pll_config_scandone = scandone;
	assign hc_pll_config_locked = pll_locked;
	`endif
	`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
	assign phasecounterselect = pll_phasecounterselect;
	assign pll_phasedone = phasedone;
	assign phasestep = pll_phasestep;
	assign phaseupdown = pll_phaseupdown;
	`endif

	altpll	upll_memphy (
				.areset (areset),
				.inclk (inclk),
				.clk (pll_clks),
				.locked (pll_locked),
				.activeclock (),
				.clkbad (),
				.clkena ({6{1'b1}}),
				.clkloss (),
				.clkswitch (1'b0),
				.enable0 (),
				.enable1 (),	
				.extclk (),
				.extclkena ({PLL_PHASE_COUNTER_WIDTH{1'b1}}),
				.fbin (1'b1),
				.fbmimicbidir (),
				.fbout (),
				.fref (),
				.icdrclk (),
				.pfdena (1'b1),
				.pllena (1'b1),
				.scanaclr (1'b0),
				.scanread (1'b0),
				.scanwrite (1'b0),
	`ifdef HCX_COMPAT_MODE
				.configupdate(configupdate),
				.phasecounterselect(phasecounterselect),
				.phasedone(phasedone),
				.phasestep(phasestep),
				.phaseupdown(phaseupdown),
				.scanclk(scanclk),
				.scanclkena(scanclkena),
				.scandata(scandata),
				.scandataout(scandataout),
				.scandone(scandone),
	`else
				.configupdate(1'b0),
				.scandata(1'b0),
				.scandataout(),
				.scandone(),
		`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
				.phasecounterselect(phasecounterselect),
				.phasedone(phasedone),
				.phasestep(phasestep),
				.phaseupdown(phaseupdown),
				.scanclk(pll_config_clk),
				.scanclkena(1'b0),
		`else
				.phasecounterselect({PLL_PHASE_COUNTER_WIDTH{1'b1}}),
				.phasedone(),
				.phasestep(1'b1),
				.phaseupdown(1'b1),
				.scanclk(1'b0),
				.scanclkena(1'b1),
		`endif
	`endif
				.sclkout0 (),
				.sclkout1 (),
				.vcooverrange (),
				.vcounderrange ()
		);
	defparam upll_memphy.bandwidth_type = "AUTO";
	defparam upll_memphy.clk0_divide_by = PLL_AFI_CLK_DIV;
	defparam upll_memphy.clk0_duty_cycle = 50;
	defparam upll_memphy.clk0_multiply_by = PLL_AFI_CLK_MULT;
	defparam upll_memphy.clk0_phase_shift = PLL_AFI_CLK_PHASE_PS;
	defparam upll_memphy.clk1_divide_by = PLL_MEM_CLK_DIV;
	defparam upll_memphy.clk1_duty_cycle = 50;
	defparam upll_memphy.clk1_multiply_by = PLL_MEM_CLK_MULT;
	defparam upll_memphy.clk1_phase_shift = PLL_MEM_CLK_PHASE_PS;
	defparam upll_memphy.clk2_divide_by = PLL_WRITE_CLK_DIV;
	defparam upll_memphy.clk2_duty_cycle = 50;
	defparam upll_memphy.clk2_multiply_by = PLL_WRITE_CLK_MULT;
	defparam upll_memphy.clk2_phase_shift = PLL_WRITE_CLK_PHASE_PS;
	defparam upll_memphy.clk3_divide_by = PLL_ADDR_CMD_CLK_DIV;
	defparam upll_memphy.clk3_duty_cycle = 50;
	defparam upll_memphy.clk3_multiply_by = PLL_ADDR_CMD_CLK_MULT;
	defparam upll_memphy.clk3_phase_shift = PLL_ADDR_CMD_CLK_PHASE_PS;
	`ifdef CTL_HRB_ENABLED
	defparam upll_memphy.clk4_divide_by = PLL_AFI_HALF_CLK_DIV;
	defparam upll_memphy.clk4_duty_cycle = 50;
	defparam upll_memphy.clk4_multiply_by = PLL_AFI_HALF_CLK_MULT;
	defparam upll_memphy.clk4_phase_shift = PLL_AFI_HALF_CLK_PHASE_PS;
    `else
	`ifdef EXPORT_AFI_HALF_CLK
	defparam upll_memphy.clk4_divide_by = PLL_AFI_HALF_CLK_DIV;
	defparam upll_memphy.clk4_duty_cycle = 50;
	defparam upll_memphy.clk4_multiply_by = PLL_AFI_HALF_CLK_MULT;
	defparam upll_memphy.clk4_phase_shift = PLL_AFI_HALF_CLK_PHASE_PS;
	`endif
	`endif
	`ifdef NIOS_SEQUENCER
	defparam upll_memphy.clk5_divide_by = PLL_NIOS_CLK_DIV;
	defparam upll_memphy.clk5_duty_cycle = 50;
	defparam upll_memphy.clk5_multiply_by = PLL_NIOS_CLK_MULT;
	defparam upll_memphy.clk5_phase_shift = PLL_NIOS_CLK_PHASE_PS;
	defparam upll_memphy.clk6_divide_by = PLL_CONFIG_CLK_DIV;
	defparam upll_memphy.clk6_duty_cycle = 50;
	defparam upll_memphy.clk6_multiply_by = PLL_CONFIG_CLK_MULT;
	defparam upll_memphy.clk6_phase_shift = PLL_CONFIG_CLK_PHASE_PS;
	`endif
	`ifdef QUARTER_RATE
	defparam upll_memphy.clk7_divide_by = PLL_HR_CLK_DIV;
	defparam upll_memphy.clk7_duty_cycle = 50;
	defparam upll_memphy.clk7_multiply_by = PLL_HR_CLK_MULT;
	defparam upll_memphy.clk7_phase_shift = PLL_HR_CLK_PHASE_PS;
    `endif
	defparam upll_memphy.inclk0_input_frequency = REF_CLK_PERIOD_PS;
	defparam upll_memphy.intended_device_family = DEVICE_FAMILY;
	defparam upll_memphy.lpm_type = "altpll";
	defparam upll_memphy.operation_mode = "NO_COMPENSATION";
	`ifdef HCX_COMPAT_MODE
	defparam upll_memphy.pll_type = PLL_LOCATION;
	`else
	defparam upll_memphy.pll_type = "AUTO";
	`endif
	defparam upll_memphy.port_activeclock = "PORT_UNUSED";
	defparam upll_memphy.port_areset = "PORT_USED";
	defparam upll_memphy.port_clkbad0 = "PORT_UNUSED";
	defparam upll_memphy.port_clkbad1 = "PORT_UNUSED";
	defparam upll_memphy.port_clkloss = "PORT_UNUSED";
	defparam upll_memphy.port_clkswitch = "PORT_UNUSED";
	defparam upll_memphy.port_fbin = "PORT_UNUSED";
	defparam upll_memphy.port_fbout = "PORT_UNUSED";
	defparam upll_memphy.port_inclk0 = "PORT_USED";
	defparam upll_memphy.port_inclk1 = "PORT_UNUSED";
	defparam upll_memphy.port_locked = "PORT_USED";
	defparam upll_memphy.port_pfdena = "PORT_UNUSED";
	defparam upll_memphy.port_pllena = "PORT_UNUSED";
	`ifdef HCX_COMPAT_MODE
	defparam upll_memphy.port_configupdate = "PORT_USED";
	defparam upll_memphy.port_phasecounterselect = "PORT_USED";
	defparam upll_memphy.port_phasedone = "PORT_USED";
	defparam upll_memphy.port_phasestep = "PORT_USED";
	defparam upll_memphy.port_phaseupdown = "PORT_USED";
	defparam upll_memphy.port_scanclk = "PORT_USED";
	defparam upll_memphy.port_scanclkena = "PORT_USED";
	defparam upll_memphy.port_scandata = "PORT_USED";
	defparam upll_memphy.port_scandataout = "PORT_USED";
	defparam upll_memphy.port_scandone = "PORT_USED";
	`else
	defparam upll_memphy.port_configupdate = "PORT_UNUSED";
	defparam upll_memphy.port_scandata = "PORT_UNUSED";
	defparam upll_memphy.port_scandataout = "PORT_UNUSED";
	defparam upll_memphy.port_scandone = "PORT_UNUSED";
		`ifdef DEBUG_PLL_DYN_PHASE_SHIFT
	defparam upll_memphy.port_phasecounterselect = "PORT_USED";
	defparam upll_memphy.port_phasedone = "PORT_USED";
	defparam upll_memphy.port_phasestep = "PORT_USED";
	defparam upll_memphy.port_phaseupdown = "PORT_USED";
	defparam upll_memphy.port_scanclk = "PORT_USED";
	defparam upll_memphy.port_scanclkena = "PORT_USED";
		`else
	defparam upll_memphy.port_phasecounterselect = "PORT_UNUSED";
	defparam upll_memphy.port_phasedone = "PORT_UNUSED";
	defparam upll_memphy.port_phasestep = "PORT_UNUSED";
	defparam upll_memphy.port_phaseupdown = "PORT_UNUSED";
	defparam upll_memphy.port_scanclk = "PORT_UNUSED";
	defparam upll_memphy.port_scanclkena = "PORT_UNUSED";
		`endif
	`endif
	defparam upll_memphy.port_scanaclr = "PORT_UNUSED";
	defparam upll_memphy.port_scanread = "PORT_UNUSED";
	defparam upll_memphy.port_scanwrite = "PORT_UNUSED";
	defparam upll_memphy.port_clk0 = "PORT_USED";
	defparam upll_memphy.port_clk1 = "PORT_USED";
	defparam upll_memphy.port_clk2 = "PORT_USED";
	defparam upll_memphy.port_clk3 = "PORT_USED";
	defparam upll_memphy.port_clk4 = "PORT_USED";
	`ifdef NIOS_SEQUENCER
	defparam upll_memphy.port_clk5 = "PORT_USED";
	defparam upll_memphy.port_clk6 = "PORT_USED";
	`endif
	`ifdef QUARTER_RATE
	defparam upll_memphy.port_clk7 = "PORT_USED";
    `else
	defparam upll_memphy.port_clk7 = "PORT_UNUSED";
	`endif
    defparam upll_memphy.port_clk8 = "PORT_UNUSED";
	defparam upll_memphy.port_clk9 = "PORT_UNUSED";
	defparam upll_memphy.port_clkena0 = "PORT_UNUSED";
	defparam upll_memphy.port_clkena1 = "PORT_UNUSED";
	defparam upll_memphy.port_clkena2 = "PORT_UNUSED";
	defparam upll_memphy.port_clkena3 = "PORT_UNUSED";
	defparam upll_memphy.port_clkena4 = "PORT_UNUSED";
	defparam upll_memphy.port_clkena5 = "PORT_UNUSED";
	defparam upll_memphy.self_reset_on_loss_lock = "OFF";
	defparam upll_memphy.using_fbmimicbidir_port = "OFF";
	defparam upll_memphy.width_clock = 10;
	`ifdef HCX_COMPAT_MODE
	defparam upll_memphy.scan_chain_mif_file = "IPTCL_MIF_FILENAME";
	`endif

	assign pll_afi_clk = pll_clks[0];
	assign pll_mem_clk_pre_phy_clk = pll_clks[1];
	assign pll_write_clk_pre_phy_clk = pll_clks[2];
	assign pll_addr_cmd_clk = pll_clks[3];
	`ifdef CTL_HRB_ENABLED
	assign pll_afi_half_clk = pll_clks[4];
	`else
	`ifdef EXPORT_AFI_HALF_CLK
	assign pll_afi_half_clk = pll_clks[4];
	`endif
	`endif
	`ifdef NIOS_SEQUENCER
	assign pll_avl_clk = pll_clks[5];
	assign pll_config_clk = pll_clks[6];
	`endif
	`ifdef QUARTER_RATE
	assign pll_hr_clk = pll_clks[7] ;
	`endif
	
	assign pll_mem_clk = pll_mem_clk_pre_phy_clk;	
	assign pll_write_clk = pll_write_clk_pre_phy_clk;	
end
endgenerate

`endif 

	`ifdef QUARTER_RATE
	// Clock descriptions
	// pll_afi_clk: quarter-rate clock, 0 degree phase shift, clock for AFI interface logic
	// pll_mem_clk: full-rate clock, 0 degree phase shift, clock output to memory
	// pll_write_clk: full-rate clock, -90 degree phase shift, clocks write data out to memory
	// pll_addr_cmd_clk: half-rate clock, 270 degree phase shift, clocks address/command out to memory
	// pll_hr_clk: half-rate clock, 0 degree phase shift, clock for HR->QR and HR->FR conversion
	`endif
	`ifdef HALF_RATE
	// Clock descriptions
	// pll_afi_clk: half-rate clock, 0 degree phase shift, clock for AFI interface logic
	// pll_mem_clk: full-rate clock, 0 degree phase shift, clock output to memory
	// pll_write_clk: full-rate clock, -90 degree phase shift, clocks write data out to memory
	// pll_addr_cmd_clk: half-rate clock, 270 degree phase shift, clocks address/command out to memory
	// pll_afi_half_clk: quad-rate clock, 0 degree phase shift
	`endif
	`ifdef FULL_RATE
	// Clock descriptions
	// pll_afi_clk: full-rate clock, 0 degree phase shift, clock for AFI interface logic
	// pll_mem_clk: full-rate clock, 0 degree phase shift, clock output to memory
	// pll_write_clk: full-rate clock, -90 degree phase shift, clocks write data out to memory
	// pll_addr_cmd_clk: full-rate clock, inverted version (180 degree phase shift) of pll_afi_clk, clocks address/command out to memory
	//					 In the special case of QDRII, BL2, address/command is double data rate (same as write data)
	//					 pll_addr_cmd_clk will have -90 degree phase shift (same as write clock)
	// pll_afi_half_clk: half-rate clock, 0 degree phase shift
	`endif
	// the purpose of these clock settings is so that address/command/write data are centred aligned with the output clock(s) to memory 

`ifdef BREAK_EXPORTED_AFI_CLK_DOMAIN
	`ifdef PLL_MASTER
	always @ (posedge pll_afi_clk)
		afi_clk_export <= ~afi_clk_export;
	assign afi_clk = afi_clk_export;
	`else
	`endif
`else
	assign afi_clk = pll_afi_clk;
`endif

`ifdef CTL_HRB_ENABLED	 
	assign afi_half_clk = pll_afi_half_clk;
`else
`ifdef EXPORT_AFI_HALF_CLK
	assign afi_half_clk = pll_afi_half_clk;
`else
	assign afi_half_clk = 1'b0;
`endif
`endif	 


endmodule

