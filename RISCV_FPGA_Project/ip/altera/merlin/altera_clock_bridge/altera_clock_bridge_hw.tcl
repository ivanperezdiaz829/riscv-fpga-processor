# (C) 2001-2013 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


#+-------------------------------------------------------
#| Altera Clock Bridge
#+-------------------------------------------------------
package require sopc 9.1

#+-------------------------------------------------------
#| Module Properties
#+-------------------------------------------------------

set_module_property NAME altera_clock_bridge
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Clock Bridge"
set_module_property DESCRIPTION "Allows you to route clocks between Qsys subsystems."
set_module_property AUTHOR "Altera Corporation"
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC false
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

#+-------------------------------------------------------
#| Constant Interfaces
#+-------------------------------------------------------
add_interface in_clk clock end
add_interface_port in_clk in_clk clk Input 1

add_interface out_clk clock start
add_interface_port out_clk out_clk clk Output 1

#+-------------------------------------------------------
#| Parameters
#+-------------------------------------------------------
add_parameter DERIVED_CLOCK_RATE LONG 0
set_parameter_property DERIVED_CLOCK_RATE DISPLAY_NAME "Derived clock rate"
set_parameter_property DERIVED_CLOCK_RATE DESCRIPTION {Derived clock rate}
set_parameter_property DERIVED_CLOCK_RATE UNITS None
set_parameter_property DERIVED_CLOCK_RATE SYSTEM_INFO { CLOCK_RATE "in_clk" }
set_parameter_property DERIVED_CLOCK_RATE AFFECTS_ELABORATION true

add_parameter EXPLICIT_CLOCK_RATE LONG 0
set_parameter_property EXPLICIT_CLOCK_RATE DISPLAY_NAME "Explicit clock rate"
set_parameter_property EXPLICIT_CLOCK_RATE DESCRIPTION {Explicit clock rate}
set_parameter_property EXPLICIT_CLOCK_RATE UNITS None
set_parameter_property EXPLICIT_CLOCK_RATE AFFECTS_ELABORATION true

add_parameter NUM_CLOCK_OUTPUTS int 1
set_parameter_property NUM_CLOCK_OUTPUTS DISPLAY_NAME "Number of Clock Outputs"
set_parameter_property NUM_CLOCK_OUTPUTS DESCRIPTION {Qsys supports multiple clock sink connections to a single clock source interface.  However, there are situations in composed systems where an internally generated clock must be exported from the composed system in addition to being used to connect internal components.  This situation requires that one clock output interface be declared as an export, and another used to connect internal components.}
set_parameter_property NUM_CLOCK_OUTPUTS AFFECTS_ELABORATION true
set_parameter_property NUM_CLOCK_OUTPUTS ALLOWED_RANGES {1:64}

#+-------------------------------------------------------
#| Declare this component to be a direct bridge.
#+-------------------------------------------------------
set_interface_property out_clk associatedDirectClock "in_clk"
set_port_property out_clk DRIVEN_BY "in_clk"

#+-------------------------------------------------------
#| Set the clock rate on the clock source from the derived
#| (or explicit) values
#+-------------------------------------------------------
proc elaborate {} {
    set clock_rate    [ get_parameter_value DERIVED_CLOCK_RATE ]
    set explicit_rate [ get_parameter_value EXPLICIT_CLOCK_RATE ]
    set num_clocks    [ get_parameter_value NUM_CLOCK_OUTPUTS ]

    if { $explicit_rate > 0 } {
        set clock_rate $explicit_rate
    }

    set_interface_property out_clk clockRate $clock_rate
    set_interface_property out_clk clockRateKnown [expr $clock_rate > 0]

    for { set i 1 } { $i < $num_clocks } { incr i } {
	add_interface "out_clk_${i}" clock start
	add_interface_port "out_clk_${i}" "out_clk_${i}" clk output 1

	set_interface_property "out_clk_${i}" associatedDirectClock "in_clk"
	set_interface_property "out_clk_${i}" clockRate $clock_rate
	set_interface_property "out_clk_${i}" clockRateKnown [expr $clock_rate > 0]
	
	set_port_property "out_clk_${i}" DRIVEN_BY "in_clk"
    }
}

