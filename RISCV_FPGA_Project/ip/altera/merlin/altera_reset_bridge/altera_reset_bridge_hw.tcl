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
#| Altera Reset Bridge
#+-------------------------------------------------------
package require -exact sopc 9.1

#+-------------------------------------------------------
#| Module Properties
#+-------------------------------------------------------
set_module_property NAME altera_reset_bridge
set_module_property VERSION 13.1
set_module_property DISPLAY_NAME "Reset Bridge"
set_module_property DESCRIPTION "Allows you to use a reset signal in two or more subsystems of your Qsys system. You can connect one reset source to the local components and export one or more to other subsystems as required."
set_module_property AUTHOR "Altera Corporation"
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC false
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

#+-------------------------------------------------------
#| Parameters
#+-------------------------------------------------------
add_parameter ACTIVE_LOW_RESET INTEGER 0
set_parameter_property ACTIVE_LOW_RESET DISPLAY_NAME "Active low reset"
set_parameter_property ACTIVE_LOW_RESET DESCRIPTION "When enabled reset is asserted low."
set_parameter_property ACTIVE_LOW_RESET UNITS None
set_parameter_property ACTIVE_LOW_RESET ALLOWED_RANGES "0:1"
set_parameter_property ACTIVE_LOW_RESET DISPLAY_HINT "boolean"
set_parameter_property ACTIVE_LOW_RESET AFFECTS_ELABORATION true

add_parameter SYNCHRONOUS_EDGES String "deassert"
set_parameter_property SYNCHRONOUS_EDGES DISPLAY_NAME "Synchronous edges"
set_parameter_property SYNCHRONOUS_EDGES DESCRIPTION "None: The reset is asserted and deasserted asynchronously. Use this setting if you have designed internal synchronization circuitry.Both: The reset is asserted and deasserted synchronously. Deassert: The reset is deasserted synchronously and asserted asynchronously."
set_parameter_property SYNCHRONOUS_EDGES UNITS None
set_parameter_property SYNCHRONOUS_EDGES ALLOWED_RANGES "none,both,deassert"
set_parameter_property SYNCHRONOUS_EDGES AFFECTS_ELABORATION true

add_parameter NUM_RESET_OUTPUTS int 1
set_parameter_property NUM_RESET_OUTPUTS DISPLAY_NAME "Number of reset outputs"
set_parameter_property NUM_RESET_OUTPUTS DESCRIPTION {Qsys supports multiple reset sink connections to a single reset source interface.  However, there are situations in composed systems where an internally generated reset must be exported from the composed system in addition to being used to connect internal components.  This situation requires that one reset output interface be declared as an export, and another used to connect internal components.}
set_parameter_property NUM_RESET_OUTPUTS AFFECTS_ELABORATION true
set_parameter_property NUM_RESET_OUTPUTS ALLOWED_RANGES {1:64}


#+-------------------------------------------------------
#| Constant Interfaces
#+-------------------------------------------------------
add_interface clk clock end
add_interface_port clk clk clk Input 1

add_interface in_reset reset end
add_interface out_reset reset start

#+-------------------------------------------------------
#| Elaboration callback
#+-------------------------------------------------------
proc elaborate {} {
    set active_low  [ get_parameter_value ACTIVE_LOW_RESET ]
    set sync_edges  [ get_parameter_value SYNCHRONOUS_EDGES ]
    set num_resets  [ get_parameter_value NUM_RESET_OUTPUTS ]

    if { $active_low == 0 } {
	add_interface_port in_reset in_reset reset Input 1	
	add_interface_port out_reset out_reset reset Output 1
	set_port_property out_reset DRIVEN_BY in_reset
    } else {
	add_interface_port in_reset in_reset_n reset_n Input 1
	add_interface_port out_reset out_reset_n reset_n Output 1
	set_port_property out_reset_n DRIVEN_BY in_reset_n
    }

    if { $sync_edges == "none" } {
	set_interface_property in_reset associatedClock ""
	set_interface_property out_reset associatedClock ""
	set_port_property clk TERMINATION true
    } else {    
	set_interface_property in_reset associatedClock "clk"
	set_interface_property out_reset associatedClock "clk"
	set_port_property clk TERMINATION false
    }
    
    set_interface_property out_reset synchronousEdges $sync_edges
    set_interface_property in_reset synchronousEdges $sync_edges

    set_interface_property out_reset associatedDirectReset "in_reset"
    set_interface_property out_reset associatedResetSinks "in_reset"
    
    # Multiple Interfaces

    for { set i 1 } { $i < $num_resets } { incr i } {
	add_interface out_reset_${i} reset start
	if { $active_low == 0 } {
	    add_interface_port out_reset_${i} out_reset_${i} reset Output 1
	    set_port_property out_reset_${i} DRIVEN_BY in_reset
	} else {
	    add_interface_port out_reset_${i} out_reset_${i}_n reset_n Output 1
	    set_port_property out_reset_${i}_n DRIVEN_BY in_reset_n
	}
	
	if { $sync_edges == "none" } {
	    set_interface_property out_reset_${i} associatedClock ""
	    set_port_property clk TERMINATION true
	} else {
	    set_interface_property out_reset_${i} associatedClock "clk"
	    set_port_property clk TERMINATION false
	}

	set_interface_property out_reset_${i} synchronousEdges $sync_edges

	#+-------------------------------------------------------
	#| Declare this component to be a direct bridge.
	#+-------------------------------------------------------

	set_interface_property out_reset_${i} associatedDirectReset "in_reset"
	set_interface_property out_reset_${i} associatedResetSinks "in_reset"
    }

}

