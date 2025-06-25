# +---------------------------------------------------------
# | 
# | Name: altpll_avalon_hw.tcl
# | 
# | Description: _hw.tcl file for the Avalon bus-compatible 
# | 		 Altera PLL module
# | 
# | Version: 1.0
# |
# +---------------------------------------------------------

package require -exact sopc 9.0

# +---------------------------------------------------------
# |
# | NOTE: This section has to be in this file (and not in the
# | 	  common code) as it seems that the SOPC builder checks
# |	  for this section to see it should bother with the rest
# |	  of this script
# | 

set_module_property DESCRIPTION "Avalon-compatible Altera PLL module. For Stratix V and newer families, use Altera PLL"
set_module_property NAME altpll
set_module_property VERSION 13.1
set_module_property GROUP "PLL"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon ALTPLL"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property SIMULATION_MODEL_IN_VERILOG true  

# | 
# +---------------------------------------------------------

# +---------------------------------------------------------
# | Set the component-specific constants
# | _hw_tcl file.
# |

set WIZARD_NAME "ALTPLL"

# |
# +---------------------------------------------------------

# +---------------------------------------------------------
# | Include the common code for the Altera megafunction
# | _hw_tcl file.
# |
# | Note: The sourcing should come AFTER the above
# |	  module property setting section. If SOPC
# | 	  builder does not see the above section
# |	  in the *_hw.tcl script, it does not continue
# |       to run it at all.
# |

source "../altera_avalon_mega_common/sopc_mwizc.tcl"

# |
# +---------------------------------------------------------

# +---------------------------------------------------------
# | Exposed (Scriptable) Parameters 
# |

set MF_EXPOSED_PARAMETERS [ list	\
	INTENDED_DEVICE_FAMILY  	\
 	WIDTH_CLOCK  			\
	WIDTH_PHASECOUNTERSELECT  	\
	PRIMARY_CLOCK 			\
	INCLK0_INPUT_FREQUENCY		\
	INCLK1_INPUT_FREQUENCY 		\
 	OPERATION_MODE			\
	PLL_TYPE			\
	QUALIFY_CONF_DONE		\
	COMPENSATE_CLOCK  		\
	SCAN_CHAIN 			\
	GATE_LOCK_SIGNAL 		\
	GATE_LOCK_COUNTER 		\
	LOCK_HIGH			\
	LOCK_LOW 			\
	VALID_LOCK_MULTIPLIER 		\
	INVALID_LOCK_MULTIPLIER 	\
	SWITCH_OVER_ON_LOSSCLK		\
	SWITCH_OVER_ON_GATED_LOCK 	\
	ENABLE_SWITCH_OVER_COUNTER 	\
	SKIP_VCO			\
	SWITCH_OVER_COUNTER		\
	SWITCH_OVER_TYPE		\
	FEEDBACK_SOURCE 		\
	BANDWIDTH 			\
	BANDWIDTH_TYPE			\
	SPREAD_FREQUENCY		\
	DOWN_SPREAD			\
	SELF_RESET_ON_GATED_LOSS_LOCK	\
	SELF_RESET_ON_LOSS_LOCK		\
 	CLK0_MULTIPLY_BY 	 	\
	CLK1_MULTIPLY_BY		\
	CLK2_MULTIPLY_BY		\
	CLK3_MULTIPLY_BY		\
	CLK4_MULTIPLY_BY		\
	CLK5_MULTIPLY_BY  		\
	CLK6_MULTIPLY_BY 		\
	CLK7_MULTIPLY_BY  		\
	CLK8_MULTIPLY_BY  		\
	CLK9_MULTIPLY_BY  		\
	EXTCLK0_MULTIPLY_BY  		\
	EXTCLK1_MULTIPLY_BY  		\
	EXTCLK2_MULTIPLY_BY  		\
	EXTCLK3_MULTIPLY_BY  		\
	CLK0_DIVIDE_BY  		\
	CLK1_DIVIDE_BY  		\
	CLK2_DIVIDE_BY  		\
	CLK3_DIVIDE_BY  		\
	CLK4_DIVIDE_BY  		\
	CLK5_DIVIDE_BY  		\
	CLK6_DIVIDE_BY  		\
	CLK7_DIVIDE_BY  		\
	CLK8_DIVIDE_BY  		\
	CLK9_DIVIDE_BY  		\
	EXTCLK0_DIVIDE_BY  		\
	EXTCLK1_DIVIDE_BY  		\
	EXTCLK2_DIVIDE_BY  		\
	EXTCLK3_DIVIDE_BY  		\
	CLK0_PHASE_SHIFT  		\
	CLK1_PHASE_SHIFT  		\
	CLK2_PHASE_SHIFT  		\
	CLK3_PHASE_SHIFT  		\
	CLK4_PHASE_SHIFT  		\
	CLK5_PHASE_SHIFT  		\
	CLK6_PHASE_SHIFT  		\
	CLK7_PHASE_SHIFT  		\
	CLK8_PHASE_SHIFT  		\
	CLK9_PHASE_SHIFT  		\
	EXTCLK0_PHASE_SHIFT  		\
	EXTCLK1_PHASE_SHIFT  		\
	EXTCLK2_PHASE_SHIFT  		\
	EXTCLK3_PHASE_SHIFT  		\
 	CLK0_DUTY_CYCLE  		\
	CLK1_DUTY_CYCLE  		\
	CLK2_DUTY_CYCLE  		\
	CLK3_DUTY_CYCLE 		\
	CLK4_DUTY_CYCLE  		\
	CLK5_DUTY_CYCLE  		\
	CLK6_DUTY_CYCLE  		\
	CLK7_DUTY_CYCLE  		\
 	CLK8_DUTY_CYCLE  		\
	CLK9_DUTY_CYCLE  		\
	EXTCLK0_DUTY_CYCLE  		\
	EXTCLK1_DUTY_CYCLE  		\
	EXTCLK2_DUTY_CYCLE  		\
	EXTCLK3_DUTY_CYCLE  		\
 	PORT_clkena0  			\
	PORT_clkena1  			\
	PORT_clkena2  			\
	PORT_clkena3  			\
	PORT_clkena4  			\
	PORT_clkena5  			\
	PORT_extclkena0  		\
	PORT_extclkena1 		\
	PORT_extclkena2  		\
	PORT_extclkena3  		\
	PORT_extclk0  			\
	PORT_extclk1  			\
	PORT_extclk2  			\
	PORT_extclk3  			\
	PORT_CLKBAD0  			\
	PORT_CLKBAD1  			\
	PORT_clk0  			\
	PORT_clk1  			\
	PORT_clk2  			\
	PORT_clk3  			\
	PORT_clk4  			\
	PORT_clk5			\
	PORT_clk6  			\
	PORT_clk7  			\
	PORT_clk8  			\
	PORT_clk9  			\
	PORT_SCANDATA  			\
	PORT_SCANDATAOUT  		\
	PORT_SCANDONE  			\
	PORT_SCLKOUT1  			\
	PORT_SCLKOUT0  			\
	PORT_ACTIVECLOCK  		\
	PORT_CLKLOSS  			\
	PORT_INCLK1  			\
	PORT_INCLK0  			\
	PORT_FBIN 			\
	PORT_PLLENA  			\
	PORT_CLKSWITCH  		\
	PORT_ARESET  			\
	PORT_PFDENA  			\
	PORT_SCANCLK  			\
	PORT_SCANACLR  			\
	PORT_SCANREAD  			\
	PORT_SCANWRITE  		\
	PORT_ENABLE0  			\
	PORT_ENABLE1  			\
	PORT_LOCKED 			\
	PORT_CONFIGUPDATE  		\
	PORT_FBOUT  			\
	PORT_PHASEDONE  		\
	PORT_PHASESTEP  		\
	PORT_PHASEUPDOWN  		\
	PORT_SCANCLKENA  		\
	PORT_PHASECOUNTERSELECT  	\
	PORT_VCOOVERRANGE  		\
	PORT_VCOUNDERRANGE  		\
	DPA_MULTIPLY_BY  		\
	DPA_DIVIDE_BY  			\
	DPA_DIVIDER  			\
	VCO_MULTIPLY_BY  		\
	VCO_DIVIDE_BY  			\
	SCLKOUT0_PHASE_SHIFT  		\
	SCLKOUT1_PHASE_SHIFT  		\
 	VCO_FREQUENCY_CONTROL  		\
	VCO_PHASE_SHIFT_STEP 		\
	USING_FBMIMICBIDIR_PORT  	\
	SCAN_CHAIN_MIF_FILE  		\
	AVALON_USE_SEPARATE_SYSCLK	\
]

# |
# +---------------------------------------------------------


# +---------------------------------------------------------
# | Auxuilary data structures
# |

set OUTCLK_LIST [ list	\
 c0 	PORT_clk0	EFF_OUTPUT_FREQ_VALUE0	\
 c1 	PORT_clk1	EFF_OUTPUT_FREQ_VALUE1	\
 c2 	PORT_clk2	EFF_OUTPUT_FREQ_VALUE2	\
 c3 	PORT_clk3	EFF_OUTPUT_FREQ_VALUE3 	\
 c4 	PORT_clk4	EFF_OUTPUT_FREQ_VALUE4 	\
 c5 	PORT_clk5	EFF_OUTPUT_FREQ_VALUE5	\
 c6 	PORT_clk6	EFF_OUTPUT_FREQ_VALUE6	\
 c7 	PORT_clk7	EFF_OUTPUT_FREQ_VALUE7	\
 c8 	PORT_clk8	EFF_OUTPUT_FREQ_VALUE8	\
 c9 	PORT_clk9	EFF_OUTPUT_FREQ_VALUE9	\
 e0 	PORT_extclk0	EFF_OUTPUT_FREQ_VALUE6	\
 e1	PORT_extclk1	EFF_OUTPUT_FREQ_VALUE7	\
 e2 	PORT_extclk2	EFF_OUTPUT_FREQ_VALUE8	\
 e3 	PORT_extclk3	EFF_OUTPUT_FREQ_VALUE9	\
]

set INCLK_LIST [ list \
 inclk0		PORT_INCLK0	\
 inclk1 	PORT_INCLK1
]

# +---------------------------------------------------------


# ============================================================
#		Custom (MF-specific) Routines
# ============================================================
proc get_exposed_mf_param_list { } {
	
	global MF_EXPOSED_PARAMETERS
	return $MF_EXPOSED_PARAMETERS
}

# Start the script run
# Add parameters
add_parameter HIDDEN_CUSTOM_ELABORATION STRING "altpll_avalon_elaboration" "CustomElaborationFunction"
add_parameter HIDDEN_CUSTOM_POST_EDIT STRING "altpll_avalon_post_edit" "CustomPostEditFunction"

# +---------------------------------------------------------
# |
# | Adding Connection Points
# |
# Input clock interface

# This is the system clock interface

set INCLK_INTERFACE "inclk_interface"
add_interface $INCLK_INTERFACE clock sink 
add_interface_port $INCLK_INTERFACE "clk" "clk" input 1
add_interface_port $INCLK_INTERFACE "reset" "reset" input 1

	
# The Memory-mapped Avalon slave interface
add_interface "pll_slave" "avalon" "slave" $INCLK_INTERFACE
set_interface_property 	"pll_slave" "isNonVolatileStorage" "false"
set_interface_property 	"pll_slave" "burstOnBurstBoundariesOnly" "false"
set_interface_property 	"pll_slave" "readLatency" "0"
set_interface_property 	"pll_slave" "holdTime" "0"
set_interface_property 	"pll_slave" "printableDevice" "false"
set_interface_property 	"pll_slave" "readWaitTime" "0"
set_interface_property 	"pll_slave" "setupTime" "0"
set_interface_property 	"pll_slave" "addressAlignment" "DYNAMIC"
set_interface_property 	"pll_slave" "writeWaitTime" "0"
set_interface_property 	"pll_slave" "timingUnits" "Cycles"
set_interface_property 	"pll_slave" "minimumUninterruptedRunLength" "1"
set_interface_property 	"pll_slave" "isMemoryDevice" "false"
set_interface_property 	"pll_slave" "linewrapBursts" "false"
set_interface_property 	"pll_slave" "maximumPendingReadTransactions" "0"
set_interface_property 	"pll_slave" bridgesToMaster ""
	
add_interface_port 	"pll_slave" "read" "read" "Input" 1
add_interface_port 	"pll_slave" "write" "write" "Input" 1
add_interface_port 	"pll_slave" "address" "address" "Input" 2
add_interface_port 	"pll_slave" "readdata" "readdata" "Output" 32
add_interface_port 	"pll_slave" "writedata" "writedata" "Input" 32

# +---------------------------------------------------------

do_init  

# +---------------------------------------------------------
#
# The altpll_avalon_post_edit is a function called at 
# the end of the standard edit callback.  This function 
# looks for a parameter in the privates list and adds it to
# the constants list so that it is written out as a megafunction 
# parameter
#
# +---------------------------------------------------------
proc altpll_avalon_post_edit {} {

	set param_name "AVALON_USE_SEPARATE_SYSCLK"
	set param_val [get_private_parameter $param_name]

	set_constant_parameter $param_name $param_val

	if { $param_val == "YES" } {
		set inclk0_port_used [get_parameter_value PORT_INCLK0]
		if { $inclk0_port_used == "PORT_USED" } {
			set_ifport_parameter inclk0 {input 0}
		}
	}
}

proc altpll_avalon_elaboration {} {

	# Add inclk0 interface if required
	set separate_sysclk [get_parameter_value AVALON_USE_SEPARATE_SYSCLK]
	if { $separate_sysclk == "YES" } {
		# interface and clk are named inclk0
		add_interface inclk0 clock sink
		add_interface_port inclk0 inclk0 clk input 1
	}

	global OUTCLK_LIST
	# Output clock interfaces
	foreach {clk_name clk_connection_param	clk_freq_private } $OUTCLK_LIST {
	
		set use_clock [get_parameter_value $clk_connection_param]
		if { $use_clock == "PORT_USED" } {
			set av_interface_name $clk_name
			add_interface $av_interface_name clock source 
			add_interface_port $av_interface_name $clk_name "clk" output 1
			set freq [get_private_parameter $clk_freq_private]
			set freq [expr $freq * 1000000]
			set_interface_property $av_interface_name clockRate $freq
			set_interface_property $av_interface_name clockRateKnown true
		}
	}
}
