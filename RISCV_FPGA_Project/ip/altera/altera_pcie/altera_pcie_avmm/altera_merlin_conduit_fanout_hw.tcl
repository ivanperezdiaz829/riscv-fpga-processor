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


package require -exact sopc 10.1

set_module_property NAME altera_merlin_conduit_fanout
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Merlin Conduit Fanout"
set_module_property EDITABLE false
set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate
set_module_property INTERNAL true


add_parameter CONDUIT_WIDTH integer 1
set_parameter_property CONDUIT_WIDTH AFFECTS_ELABORATION true

add_parameter CONDUIT_INPUT_ROLE string conduit
set_parameter_property CONDUIT_INPUT_ROLE AFFECTS_ELABORATION true

add_parameter CONDUIT_OUTPUT_ROLES string_list conduit
set_parameter_property CONDUIT_OUTPUT_ROLES AFFECTS_ELABORATION true

add_parameter NUM_OUTPUTS integer 1
set_parameter_property NUM_OUTPUTS AFFECTS_ELABORATION true 


add_interface conduit_in conduit end

proc validate {} {
    set conduit_output_roles [split [get_parameter_value CONDUIT_OUTPUT_ROLES] ,]
    set length [ llength ${conduit_output_roles} ]

    if { $length != [get_parameter_value NUM_OUTPUTS] } {
	send_message {error} "The number of Conduit Output Role entries must match Number of Conduit Outputs parameter"
    } 
}
proc elaborate {} {
    set width [get_parameter_value CONDUIT_WIDTH]
    set input_role [get_parameter_value CONDUIT_INPUT_ROLE]
    set output_roles [split [get_parameter_value CONDUIT_OUTPUT_ROLES] ,]
    
    set outputs [get_parameter_value NUM_OUTPUTS]

    add_interface_port conduit_in conduit_in ${input_role} input $width

    for { set i 0 } { $i < $outputs } { incr i } {
	set output_role [ lindex ${output_roles} $i ]

	add_interface conduit_out_${i} conduit end
	add_interface_port conduit_out_${i} conduit_out_${i} ${output_role} output ${width}
	set_port_property conduit_out_${i} DRIVEN_BY conduit_in
    }
}
