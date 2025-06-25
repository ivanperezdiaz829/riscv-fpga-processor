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
	afi_half_clk,
	pll_mem_phy_clk,
	afi_phy_clk,
	pll_avl_phy_clk,
	afi_clk
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


// Clock settings
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
parameter AFI_PHY_CLK_PHASE  = "IPTCL_PLL_AFI_PHY_CLK_PHASE_PS_STR";
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
`ifdef USE_DR_CLK
parameter DR_CLK_PHASE       = "IPTCL_PLL_DR_CLK_PHASE_PS_STR";
`endif

parameter MEM_CLK_PHASE_SIM       = "IPTCL_PLL_MEM_CLK_PHASE_PS_SIM_STR";
parameter WRITE_CLK_PHASE_SIM     = "IPTCL_PLL_WRITE_CLK_PHASE_PS_SIM_STR";
parameter ADDR_CMD_CLK_PHASE_SIM  = "IPTCL_PLL_ADDR_CMD_CLK_PHASE_PS_SIM_STR";


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



// PLL Interface
output	afi_clk;
output	afi_half_clk;
`ifdef EXPORT_AFI_HALF_CLK

wire	pll_afi_half_clk;
`endif

output	pll_mem_phy_clk;
output	afi_phy_clk;
output	pll_avl_phy_clk;

`ifdef BREAK_EXPORTED_AFI_CLK_DOMAIN
reg afi_clk_export;
`endif


// END PARAMETER SECTION
// ******************************************************************************************************************************** 

initial $display("Using %0s pll emif simulation models", FAST_SIM_MODEL ? "Fast" : "Regular");


	wire fbout;
	

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
`ifdef QUARTER_RATE
	defparam pll1_phy.output_clock_frequency = HR_CLK_FREQ;
`else
	defparam pll1_phy.output_clock_frequency = AFI_CLK_FREQ;
`endif
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
	
	generic_pll pll2 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_mem_clk),
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
	defparam pll2.duty_cycle = 50;
			
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
	defparam pll3.duty_cycle = 50;

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
	defparam pll4.duty_cycle = 50;

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
`else
    assign pll_avl_phy_clk = 1'b0;
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
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
	`ifdef USE_DR_CLK
	assign pll_dr_clk = pll_dr_clk_pre_phy_clk;
	`endif
`else 
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
	`ifdef USE_DR_CLK
	assign pll_dr_clk = pll_dr_clk_pre_phy_clk;
	`endif
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

`ifdef EXPORT_AFI_HALF_CLK	 
	assign afi_half_clk = pll_afi_half_clk;
`else
  assign afi_half_clk = 1'b0;
`endif	 


endmodule

