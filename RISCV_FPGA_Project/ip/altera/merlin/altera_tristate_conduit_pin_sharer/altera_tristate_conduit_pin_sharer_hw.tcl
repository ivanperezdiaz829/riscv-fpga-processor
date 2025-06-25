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


package require -exact sopc 11.0

source "../altera_tristate_conduit_pin_sharer_core/altera_tc_lib.tcl"
namespace import ::altera_tc_lib::*

set_module_property NAME altera_tristate_conduit_pin_sharer
set_module_property VERSION 13.1
set_module_property GROUP "Tri-State Components"
set_module_property DISPLAY_NAME "Tri-State Conduit Pin Sharer"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property COMPOSE_CALLBACK compose
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Multiplexes between the signals of the connected tri-state controllers"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_avalon_tc.pdf

add_parameter INTERFACE_INFO string ""
set_parameter_property INTERFACE_INFO system_info TRISTATECONDUIT_INFO
set_parameter_property INTERFACE_INFO system_info_arg "*"
set_parameter_property INTERFACE_INFO AFFECTS_ELABORATION true
set_parameter_property INTERFACE_INFO visible false

add_parameter NUM_INTERFACES INTEGER 2
set_parameter_property NUM_INTERFACES DISPLAY_NAME "Number of Interfaces"
set_parameter_property NUM_INTERFACES UNITS None
set_parameter_property NUM_INTERFACES AFFECTS_ELABORATION true
set_parameter_property NUM_INTERFACES HDL_PARAMETER false
set_parameter_property NUM_INTERFACES ALLOWED_RANGES "1:32000"
set_parameter_property NUM_INTERFACES DESCRIPTION "Determines the number of slave interfaces on this device"

add_display_item "" "Sharing Assignment" GROUP ""

add_display_item "Sharing Assignment" "sharingAssignmentText" text "To share a signal, type the same signal name in the Shared Signal Name column for all controllers that share that signal"

add_display_item "Sharing Assignment" "Update Interface Table" "action" "update_interfaces"

add_display_item "Sharing Assignment" "Interface Table" GROUP "table"

add_parameter MODULE_ORIGIN_LIST STRING_LIST ""
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_NAME "Interface"
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_HINT "table"
set_parameter_property MODULE_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property MODULE_ORIGIN_LIST DERIVED false
set_parameter_property MODULE_ORIGIN_LIST HDL_PARAMETER false
set_parameter_property MODULE_ORIGIN_LIST GROUP "Interface Table"
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_HINT "WIDTH:230"
set_parameter_property MODULE_ORIGIN_LIST DESCRIPTION "Master to original signal mapping"

add_parameter SIGNAL_ORIGIN_LIST STRING_LIST ""
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_NAME "Signal Role"
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_LIST DERIVED false
set_parameter_property SIGNAL_ORIGIN_LIST HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_LIST GROUP "Interface Table"
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_HINT "WIDTH:150"
set_parameter_property SIGNAL_ORIGIN_LIST DESCRIPTION "Original signal to original signal mapping"

add_parameter SIGNAL_ORIGIN_TYPE STRING_LIST ""
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_NAME "Signal Type"
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_TYPE AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_TYPE DERIVED true
set_parameter_property SIGNAL_ORIGIN_TYPE HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_TYPE GROUP "Interface Table"
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_HINT "WIDTH:100"
set_parameter_property SIGNAL_ORIGIN_TYPE DESCRIPTION "Signal type to original signal mapping"

add_parameter SIGNAL_ORIGIN_WIDTH INTEGER_LIST ""
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_NAME "Signal Width"
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_WIDTH AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_WIDTH DERIVED true
set_parameter_property SIGNAL_ORIGIN_WIDTH HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_WIDTH GROUP "Interface Table"
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_HINT "WIDTH:80"
set_parameter_property SIGNAL_ORIGIN_WIDTH DESCRIPTION "Signal width to original signal mapping"

add_parameter SHARED_SIGNAL_LIST STRING_LIST ""
set_parameter_property SHARED_SIGNAL_LIST DISPLAY_NAME "Shared Signal Name"
set_parameter_property SHARED_SIGNAL_LIST DISPLAY_HINT "table"
set_parameter_property SHARED_SIGNAL_LIST AFFECTS_ELABORATION true
set_parameter_property SHARED_SIGNAL_LIST HDL_PARAMETER false
set_parameter_property SHARED_SIGNAL_LIST GROUP "Interface Table"
set_parameter_property SHARED_SIGNAL_LIST DISPLAY_HINT "WIDTH:230"
set_parameter_property SHARED_SIGNAL_LIST DESCRIPTION "Shared signal to original signal mapping"

add_parameter SIGNAL_OUTPUT_NAMES STRING_LIST ""
set_parameter_property SIGNAL_OUTPUT_NAMES AFFECTS_ELABORATION true
set_parameter_property SIGNAL_OUTPUT_NAMES derived true
set_parameter_property SIGNAL_OUTPUT_NAMES visible false

add_parameter SIGNAL_INPUT_NAMES STRING_LIST ""
set_parameter_property SIGNAL_INPUT_NAMES AFFECTS_ELABORATION true
set_parameter_property SIGNAL_INPUT_NAMES derived true
set_parameter_property SIGNAL_INPUT_NAMES visible false

add_parameter SIGNAL_OUTPUT_ENABLE_NAMES STRING_LIST ""
set_parameter_property SIGNAL_OUTPUT_ENABLE_NAMES AFFECTS_ELABORATION true
set_parameter_property SIGNAL_OUTPUT_ENABLE_NAMES derived true
set_parameter_property SIGNAL_OUTPUT_ENABLE_NAMES visible false

add_parameter REALTIME_MODULE_ORIGIN_LIST STRING_LIST ""
set_parameter_property REALTIME_MODULE_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property REALTIME_MODULE_ORIGIN_LIST derived true
set_parameter_property REALTIME_MODULE_ORIGIN_LIST visible false

add_parameter REALTIME_SIGNAL_ORIGIN_LIST STRING_LIST ""
set_parameter_property REALTIME_SIGNAL_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property REALTIME_SIGNAL_ORIGIN_LIST derived true
set_parameter_property REALTIME_SIGNAL_ORIGIN_LIST visible false

add_parameter REALTIME_SHARED_SIGNAL_LIST STRING_LIST ""
set_parameter_property REALTIME_SHARED_SIGNAL_LIST AFFECTS_ELABORATION true
set_parameter_property REALTIME_SHARED_SIGNAL_LIST derived true
set_parameter_property REALTIME_SHARED_SIGNAL_LIST visible false

#Clock connections
add_instance clock altera_clock_bridge
add_instance reset altera_reset_bridge

add_interface clk clock end
set_interface_property clk export_of clock.in_clk

add_interface reset reset end
set_interface_property reset export_of reset.in_reset

add_connection clock.out_clk reset.clk

#Always true pin_sharing declarations
add_instance pin_sharer altera_tristate_conduit_pin_sharer_core

add_connection clock.out_clk pin_sharer.clk
add_connection reset.out_reset pin_sharer.reset

set_instance_parameter pin_sharer HIERARCHY_LEVEL 1

add_interface "tcm" tristate_conduit master
set_interface_property "tcm" export_of pin_sharer.tcm

proc update_interfaces {} {
    set_parameter MODULE_ORIGIN_LIST [get_parameter REALTIME_MODULE_ORIGIN_LIST]
    set_parameter SIGNAL_ORIGIN_LIST [get_parameter REALTIME_SIGNAL_ORIGIN_LIST]
    set_parameter SHARED_SIGNAL_LIST [get_parameter REALTIME_SHARED_SIGNAL_LIST]
}

proc compose {} {

    #Make Connections

    set_instance_parameter pin_sharer NUM_INTERFACES [get_parameter NUM_INTERFACES]

    add_instance arbiter altera_merlin_std_arbitrator
    add_connection clock.out_clk arbiter.clk
    add_connection reset.out_reset arbiter.clk_reset
    
    set_instance_parameter arbiter USE_PACKETS 0
    set_instance_parameter arbiter USE_CHANNEL 0
    set_instance_parameter arbiter USE_DATA 0
    
    set_instance_parameter arbiter NUM_REQUESTERS [get_parameter NUM_INTERFACES]
    add_connection arbiter.grant pin_sharer.grant
    
    for {set i 0} { ${i} < [get_parameter NUM_INTERFACES] } { incr i } {
	set interface_name "tcs${i}"
	add_interface $interface_name tristate_conduit slave
	set_interface_property $interface_name export_of pin_sharer.${interface_name}
    }

    
    foreach interface_name [get_instance_interfaces pin_sharer] {
	if { [regexp {^tcs([0-9]*)_arb$} $interface_name junk number] } {
	    add_connection pin_sharer.${interface_name} arbiter.sink${number}
	}
    }

    set user_module_origin_list [get_parameter MODULE_ORIGIN_LIST]
    set user_signal_origin_list [get_parameter SIGNAL_ORIGIN_LIST]
    set user_shared_signal_list [get_parameter SHARED_SIGNAL_LIST]

    set_instance_parameter pin_sharer MODULE_ORIGIN_LIST $user_module_origin_list
    set_instance_parameter pin_sharer SIGNAL_ORIGIN_LIST $user_signal_origin_list

    set signal_origin_type [get_instance_parameter pin_sharer SIGNAL_ORIGIN_TYPE]
    set signal_origin_width [get_instance_parameter pin_sharer SIGNAL_ORIGIN_WIDTH]
    set signal_output_names [get_instance_parameter pin_sharer SIGNAL_OUTPUT_NAMES]
    set signal_input_names [get_instance_parameter pin_sharer SIGNAL_INPUT_NAMES]
    set signal_output_enable_names [get_instance_parameter pin_sharer SIGNAL_OUTPUT_ENABLE_NAMES]

    set_parameter SIGNAL_ORIGIN_TYPE $signal_origin_type
    set_parameter SIGNAL_ORIGIN_WIDTH $signal_origin_width
    set_parameter SIGNAL_OUTPUT_NAMES $signal_output_names
    set_parameter SIGNAL_INPUT_NAMES $signal_input_names
    set_parameter SIGNAL_OUTPUT_ENABLE_NAMES $signal_output_enable_names

    set_instance_parameter pin_sharer SHARED_SIGNAL_LIST $user_shared_signal_list

    set realtime_module_origin_list [get_instance_parameter pin_sharer REALTIME_MODULE_ORIGIN_LIST]
    set realtime_signal_origin_list [get_instance_parameter pin_sharer REALTIME_SIGNAL_ORIGIN_LIST]
    set realtime_signal_origin_type [get_instance_parameter pin_sharer REALTIME_SIGNAL_ORIGIN_TYPE]
    set realtime_signal_origin_width [get_instance_parameter pin_sharer REALTIME_SIGNAL_ORIGIN_WIDTH]
    set realtime_signal_output_names [get_instance_parameter pin_sharer REALTIME_SIGNAL_OUTPUT_NAMES]
    set realtime_signal_input_names [get_instance_parameter pin_sharer REALTIME_SIGNAL_INPUT_NAMES]
    set realtime_shared_signal_list [get_instance_parameter pin_sharer REALTIME_SHARED_SIGNAL_LIST]

    set_parameter REALTIME_MODULE_ORIGIN_LIST $realtime_module_origin_list
    set_parameter REALTIME_SIGNAL_ORIGIN_LIST $realtime_signal_origin_list
    set_parameter REALTIME_SHARED_SIGNAL_LIST $realtime_shared_signal_list
        
### set exported interface names equal to output names ###
    set port_name_map ""

    foreach port [get_instance_interface_ports pin_sharer tcm] {
	lappend port_name_map $port $port
    }

    set_interface_property tcm PORT_NAME_MAP $port_name_map

    #tb partner assignments
    set modified_roles_list ""
    iterate_through_listinfo \
	$realtime_module_origin_list \
	{} \
	$realtime_signal_origin_type \
	{} \
	$realtime_signal_output_names \
	$realtime_signal_input_names \
	{} \
	{} \
	{
	    if { [string equal $type "Input"] } {
		uplevel lappend modified_roles_list ${master_module_name}_${input_name}
	    } else {
		uplevel lappend modified_roles_list ${master_module_name}_${output_name}
	    }
	}

    set_module_assignment testbench.partner.map.tcm pin_divider.in
    set_module_assignment testbench.partner.pin_divider.class altera_conduit_pin_divider    
    set_module_assignment testbench.partner.pin_divider.parameter.MODULE_ORIGIN_LIST $realtime_module_origin_list
    set_module_assignment testbench.partner.pin_divider.parameter.SIGNAL_ORIGIN_LIST $modified_roles_list
    set_module_assignment testbench.partner.pin_divider.parameter.SIGNAL_ORIGIN_TYPE $realtime_signal_origin_type
    set_module_assignment testbench.partner.pin_divider.parameter.SIGNAL_ORIGIN_WIDTH $realtime_signal_origin_width
    set_module_assignment testbench.partner.pin_divider.parameter.SHARED_SIGNAL_LIST $user_shared_signal_list
}    
