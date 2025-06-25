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


# $Id: //acds/rel/13.1/ip/merlin/altera_irq_mapper/altera_irq_mapper_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

package require -exact altera_terp 1.0

#  -----------------------------------
# | altera_irq_mapper
#  -----------------------------------
set_module_property NAME altera_irq_mapper
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Merlin IRQ Mapper"
set_module_property DESCRIPTION "Converts individual interrupt wires to a bus. By default, the interrupt sender connected to the receiver0 interface of the IRQ mapper is the highest priority with sequential receivers beiing successively lower priority."
set_module_property AUTHOR "Altera Corporation"
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property GENERATION_CALLBACK generate
set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter NUM_RCVRS INTEGER 2  "Number of receiver interfaces"
set_parameter_property NUM_RCVRS DISPLAY_NAME "Number of receivers"
set_parameter_property NUM_RCVRS ALLOWED_RANGES 0:64

add_parameter SENDER_IRQ_WIDTH INTEGER 2  "Number of bits in the sender interface's irq signal."
set_parameter_property SENDER_IRQ_WIDTH DISPLAY_NAME "Sender interrupt width"
set_parameter_property SENDER_IRQ_WIDTH ALLOWED_RANGES 1:64

add_parameter IRQ_MAP STRING "0:0,1:1" "A map of interrupt receiver interfaces to interrupt sender bits.  This is a comma separated list of pairs of the form RcvrIf:SndrBit.  The String \"0:1,1:2\" means that receiver interfaces 0 and 1 connect to the sender interface irq bits 1 and 2, respectively."
set_parameter_property IRQ_MAP DISPLAY_NAME "IRQ map"

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {
    
    # Collect parameter values into local variables
    foreach var [get_parameters] {
	set $var [get_parameter_value $var]
    }

    # Clock interface
    add_interface clk clock end
    add_interface_port clk clk clk Input 1
   
    # Reset interface
    add_interface clk_reset reset end
    add_interface_port clk_reset reset reset Input 1
    set_interface_property clk_reset associatedClock clk

    # Interrupt Receiver Interfaces
    for {set r 0} {$r < $NUM_RCVRS} {incr r} {
	add_interface "receiver$r" interrupt start
	set_interface_property "receiver$r" irqScheme         INDIVIDUAL_REQUESTS
	set_interface_property "receiver$r" ASSOCIATED_CLOCK  clk
	add_interface_port "receiver$r" "receiver${r}_irq" irq input 1
    }

    # Interrupt Sender Interface
    add_interface "sender" interrupt end
#    set_interface_property "sender" irqScheme         INDIVIDUAL_REQUESTS
    set_interface_property "sender" ASSOCIATED_CLOCK  clk
    add_interface_port "sender" "sender_irq" irq output $SENDER_IRQ_WIDTH
    set_port_property "sender_irq" VHDL_TYPE STD_LOGIC_VECTOR

    # Validate for bad irq_map values
    # Things to Check, for a list of A:Bs-
    # 1. The string really is of the form "A:B{A1,B1}+" , where A and B are non-negative integers.
    # 2. all A's are within range.
    # 3. all B's are within range.
    # 4. No A or B is used twice.

    set used_a {}
    set used_b {}

    set pairs [split $IRQ_MAP ","]
    foreach pair $pairs {
	# Only numeric & Colon!
	if {[regexp {[^0-9:]} $pair] > 0 } {send_message error "IRQ_MAP has non-numeric characters at $pair. (IRQ_MAP = $IRQ_MAP)"}

	set ab [split $pair ":"]
	if {[llength $ab] != 2} {send_message error "IRQ_MAP is malformed at $pair. (IRQ_MAP = $IRQ_MAP)"}
	set a [lindex $ab 0]
	set b [lindex $ab 1]


	if {$a >= $NUM_RCVRS}        {send_message error "IRQ_MAP indicates a connection to a nonexistant receiver interface at $pair. (IRQ_MAP = $IRQ_MAP)"}
	if {$b >= $SENDER_IRQ_WIDTH} {send_message error "IRQ_MAP indicates a connection to a nonexistant sender bit at $pair. (IRQ_MAP = $IRQ_MAP)"}

	if {[lsearch -exact $used_a $a] >= 0} {send_message error "IRQ_MAP receiver interface $a used twice at $pair. (IRQ_MAP = $IRQ_MAP)"}
	if {[lsearch -exact $used_b $b] >= 0} {send_message error "IRQ_MAP sender bit $b used twice at $pair. (IRQ_MAP = $IRQ_MAP)"}

	lappend used_a $a
	lappend used_b $b
	
    }

    
}

#  -----------------------------------
# | Generation callback
#  -----------------------------------
proc generate {} {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_irq_mapper.sv.terp" ]


    set output_dir  [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name [ get_generation_property OUTPUT_NAME ]
    set template    [ read [ open $template_file r ] ]

    # Collect parameter values for Terp
    set params(output_name) $output_name
    foreach var [get_parameters] {
	set params($var) [ get_parameter_value $var ]
    }

    set result          [ altera_terp $template params ]
    set output_file     [ file join $output_dir ${output_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    add_file ${output_file} {SYNTHESIS SIMULATION}
}
