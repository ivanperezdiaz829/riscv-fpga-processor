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
package require -exact altera_terp 1.0

source altera_tc_lib.tcl
namespace import ::altera_tc_lib::*

set_module_property NAME altera_tristate_conduit_pin_sharer_core
set_module_property VERSION 13.1
set_module_property GROUP "Tri-State Components"
set_module_property DISPLAY_NAME "Tri-State Conduit Pin Sharer Core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property GENERATION_CALLBACK generate
set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property INTERNAL true
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION  "Multiplexes between the signals of the connected tri-state controllers."
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
set_parameter_property NUM_INTERFACES DESCRIPTION "Determines the number of slave interfaces on this device."

add_display_item "Sharing Assignment" "sharingAssignmentText" text "To share a signal, type the same signal name in the Shared Signal Name column for all controllers that share that signal"

add_display_item "Sharing Assignment" "Update Interface Table" "action" "update_interfaces"

add_display_item "Sharing Assignment" "Sharing Assignment" "group" "table"

add_parameter MODULE_ORIGIN_LIST STRING_LIST ""
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_NAME "Interface"
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_HINT "table"
set_parameter_property MODULE_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property MODULE_ORIGIN_LIST DERIVED false
set_parameter_property MODULE_ORIGIN_LIST HDL_PARAMETER false
set_parameter_property MODULE_ORIGIN_LIST GROUP "Sharing Assignment"
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_HINT "WIDTH:230"
set_parameter_property MODULE_ORIGIN_LIST DESCRIPTION "Master to original signal mapping"

add_parameter SIGNAL_ORIGIN_LIST STRING_LIST ""
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_NAME "Signal Role"
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_LIST DERIVED false
set_parameter_property SIGNAL_ORIGIN_LIST HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_LIST GROUP "Sharing Assignment"
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_HINT "WIDTH:150"
set_parameter_property SIGNAL_ORIGIN_LIST DESCRIPTION "Original signal to original signal mapping"

add_parameter SIGNAL_ORIGIN_TYPE STRING_LIST ""
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_NAME "Signal Type"
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_TYPE AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_TYPE DERIVED true
set_parameter_property SIGNAL_ORIGIN_TYPE HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_TYPE GROUP "Sharing Assignment"
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_HINT "WIDTH:100"
set_parameter_property SIGNAL_ORIGIN_TYPE DESCRIPTION "Signal type to original signal mapping"

add_parameter SIGNAL_ORIGIN_WIDTH INTEGER_LIST ""
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_NAME "Signal Width"
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_WIDTH AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_WIDTH DERIVED true
set_parameter_property SIGNAL_ORIGIN_WIDTH HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_WIDTH GROUP "Sharing Assignment"
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_HINT "WIDTH:80"
set_parameter_property SIGNAL_ORIGIN_WIDTH DESCRIPTION "Signal width to original signal mapping"

add_parameter SHARED_SIGNAL_LIST STRING_LIST ""
set_parameter_property SHARED_SIGNAL_LIST DISPLAY_NAME "Shared Signal Name"
set_parameter_property SHARED_SIGNAL_LIST DISPLAY_HINT "table"
set_parameter_property SHARED_SIGNAL_LIST AFFECTS_ELABORATION true
set_parameter_property SHARED_SIGNAL_LIST HDL_PARAMETER false
set_parameter_property SHARED_SIGNAL_LIST GROUP "Sharing Assignment"
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

add_parameter REALTIME_SIGNAL_ORIGIN_TYPE STRING_LIST ""
set_parameter_property REALTIME_SIGNAL_ORIGIN_TYPE AFFECTS_ELABORATION true
set_parameter_property REALTIME_SIGNAL_ORIGIN_TYPE derived true
set_parameter_property REALTIME_SIGNAL_ORIGIN_TYPE visible false

add_parameter REALTIME_SIGNAL_ORIGIN_WIDTH STRING_LIST ""
set_parameter_property REALTIME_SIGNAL_ORIGIN_WIDTH AFFECTS_ELABORATION true
set_parameter_property REALTIME_SIGNAL_ORIGIN_WIDTH derived true
set_parameter_property REALTIME_SIGNAL_ORIGIN_WIDTH visible false

add_parameter REALTIME_SIGNAL_OUTPUT_NAMES STRING_LIST ""
set_parameter_property REALTIME_SIGNAL_OUTPUT_NAMES AFFECTS_ELABORATION true
set_parameter_property REALTIME_SIGNAL_OUTPUT_NAMES derived true
set_parameter_property REALTIME_SIGNAL_OUTPUT_NAMES visible false

add_parameter REALTIME_SIGNAL_INPUT_NAMES STRING_LIST ""
set_parameter_property REALTIME_SIGNAL_INPUT_NAMES AFFECTS_ELABORATION true
set_parameter_property REALTIME_SIGNAL_INPUT_NAMES derived true
set_parameter_property REALTIME_SIGNAL_INPUT_NAMES visible false

add_parameter REALTIME_SHARED_SIGNAL_LIST STRING_LIST ""
set_parameter_property REALTIME_SHARED_SIGNAL_LIST AFFECTS_ELABORATION true
set_parameter_property REALTIME_SHARED_SIGNAL_LIST derived true
set_parameter_property REALTIME_SHARED_SIGNAL_LIST visible false

add_parameter HIERARCHY_LEVEL INTEGER 0
set_parameter_property HIERARCHY_LEVEL AFFECTS_ELABORATION true
set_parameter_property HIERARCHY_LEVEL visible false


add_interface clk clock end
add_interface_port clk clk clk Input 1

add_interface reset reset end
add_interface_port reset reset reset Input 1
set_interface_property reset ASSOCIATED_CLOCK clk

set master_output_interface_name tcm
set slave_input_interface_prefix tcs

add_interface ${master_output_interface_name} tristate_conduit master clk
add_interface_port ${master_output_interface_name} request request output 1
add_interface_port ${master_output_interface_name} grant   grant   input 1


proc update_interfaces {} {
    set_parameter MODULE_ORIGIN_LIST [get_parameter REALTIME_MODULE_ORIGIN_LIST]
    set_parameter SIGNAL_ORIGIN_LIST [get_parameter REALTIME_SIGNAL_ORIGIN_LIST]
    set_parameter SHARED_SIGNAL_LIST [get_parameter REALTIME_SHARED_SIGNAL_LIST]
}

proc elaborate {} {
    global slave_input_interface_prefix
    global master_output_interface_name
    set raw [get_parameter_value INTERFACE_INFO]
    set sys_info [decode_tristate_conduit_masters ${raw}]
    set hierarchy_level [get_parameter_value HIERARCHY_LEVEL]

    set tiers ""
    for { set i 0 } { $i < $hierarchy_level } { incr i } {
	lappend tiers ../
    }

### create slave interfaces ###

    for { set i 0 } { $i < [ get_parameter_value NUM_INTERFACES ] } { incr i } {
	add_interface "${slave_input_interface_prefix}$i" tristate_conduit slave clk
	add_interface_port "${slave_input_interface_prefix}$i" "${slave_input_interface_prefix}${i}_request" request input  1
	add_interface_port "${slave_input_interface_prefix}$i" "${slave_input_interface_prefix}${i}_grant"   grant   output 1
    }

    #Arbitration Input Elaboration
    add_interface "grant" avalon_streaming end clk
    add_interface_port "grant" "ack" ready output 1
    set_interface_property "grant" symbolsPerBeat 1
    add_interface_port "grant" "next_grant" data input [get_parameter_value NUM_INTERFACES]
    set_port_property "next_grant" VHDL_TYPE STD_LOGIC_VECTOR
    set_interface_property "grant" dataBitsPerSymbol [get_parameter_value NUM_INTERFACES]

     #Add arbitration outputs
     iterate_through_sysinfo ${sys_info} {} \
 	{
 	    uplevel "add_interface ${slave_interface_name}_arb avalon_streaming start clk"
 	    uplevel "add_interface_port ${slave_interface_name}_arb arb_${master_module_name}_${master_interface_name} valid output 1"
 	} {} {} ${hierarchy_level}


### elaborate & validate user-entered / button-generated table information ###

    array set slave_list ${sys_info}

    set signal_origin_type ""
    set signal_origin_width ""
    set signal_output_names ""
    set signal_input_names ""
    set signal_output_enable_names ""

    set user_module_origin_list [get_parameter MODULE_ORIGIN_LIST]
    set user_signal_origin_list [get_parameter SIGNAL_ORIGIN_LIST]
    set user_shared_signal_list [get_parameter SHARED_SIGNAL_LIST]

    foreach master $user_module_origin_list signal $user_signal_origin_list shared $user_shared_signal_list {
	set type {}
	set width {}
	set output_name {}
	set input_name {}
	set output_enable_name {}
	set found_master 0
	foreach slave [array names slave_list] {
	    array set master_list $slave_list($slave)
	    if { [string equal [array names master_list] ${tiers}${master}] } {
		set found_master 1
		array set pin_list $master_list(${tiers}$master)
		set pin_index [lsearch [array names pin_list] $signal]
		if { $pin_index != -1 } {
		    set role [lindex [array names pin_list] $pin_index]
		    array set pin_info $pin_list($role)
		    foreach var [array names pin_info] {
			set ${var} $pin_info($var)
		    }

		    lappend signal_origin_type $type
		    lappend signal_origin_width $width
		    lappend signal_output_names $output_name
		    lappend signal_input_names $input_name
		    lappend signal_output_enable_names $output_enable_name
		    set shared_signal_map(${master}:${signal}) $shared

		    if { [array exists pin_info] } { array unset pin_info }
		} else {
		    send_message error "Signal \"${signal}\" on interface  \"${master}\" not found."
		}
		if { [array exists pin_list] } { array unset pin_list }
	    }
	    if { [array exists master_list] } { array unset master_list }
	}
	if { $found_master == 0 } {
	    send_message error "Interface \"${master}\" not found."
	}
    }

### create realtime_shared_signal_list and set derived parameters ###
	    
    array set derived_lists [create_derived_lists ${sys_info} ${hierarchy_level} ]

    set realtime_shared_signal_list ""

    foreach master $derived_lists(module_origin_list) signal $derived_lists(signal_origin_list) {
	if { [lsearch [array names shared_signal_map] ${master}:${signal}] != -1 } {
	    lappend realtime_shared_signal_list $shared_signal_map(${master}:${signal})
	} else {
	    lappend realtime_shared_signal_list {}
	}
    }

    set_parameter REALTIME_MODULE_ORIGIN_LIST $derived_lists(module_origin_list)
    set_parameter REALTIME_SIGNAL_ORIGIN_LIST $derived_lists(signal_origin_list)
    set_parameter REALTIME_SIGNAL_ORIGIN_TYPE $derived_lists(signal_origin_type)
    set_parameter REALTIME_SIGNAL_ORIGIN_WIDTH $derived_lists(signal_origin_width)
    set_parameter REALTIME_SIGNAL_OUTPUT_NAMES $derived_lists(signal_output_names)
    set_parameter REALTIME_SIGNAL_INPUT_NAMES $derived_lists(signal_input_names)
    set_parameter REALTIME_SHARED_SIGNAL_LIST $realtime_shared_signal_list
    set_parameter SIGNAL_ORIGIN_TYPE $signal_origin_type
    set_parameter SIGNAL_ORIGIN_WIDTH $signal_origin_width
    set_parameter SIGNAL_OUTPUT_NAMES $signal_output_names
    set_parameter SIGNAL_INPUT_NAMES $signal_input_names
    set_parameter SIGNAL_OUTPUT_ENABLE_NAMES $signal_output_enable_names


## definitions of slave interface actions based on signal type ##

    set output_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_name} ${role}_out input ${width}"
	uplevel "set_port_property ${slave_interface_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set input_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${input_name} ${role}_in output ${width}"
	uplevel "set_port_property ${slave_interface_name}_${input_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set bidir_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_name} ${role}_out input ${width}"
        uplevel "set_port_property  ${slave_interface_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${input_name} ${role}_in output ${width}"
        uplevel "set_port_property  ${slave_interface_name}_${input_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_enable_name} ${role}_outen input 1"
    }
    set tristatable_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_name} ${role}_out input ${width}"
        uplevel "set_port_property ${slave_interface_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_enable_name} ${role}_outen input 1"
    }
    set includes {
	output_action
	input_action
	bidir_action
	tristatable_action
    }

    iterate_through_sysinfo ${sys_info} {} {} \
	{
	    set ta_includes " [array names pin_info] slave_interface_name role "
	    type_action  ${type} ${output_action} ${input_action} ${bidir_action} ${tristatable_action} ${ta_includes}
	} ${includes} ${hierarchy_level}


### create master interface ###

    array set split_lists [segregate_shared_from_unshared \
			       $derived_lists(module_origin_list) \
			       $derived_lists(signal_origin_list) \
			       $derived_lists(signal_origin_type) \
			       $derived_lists(signal_origin_width) \
			       $derived_lists(signal_output_names) \
			       $derived_lists(signal_input_names) \
			       $derived_lists(signal_output_enable_names) \
			       $user_shared_signal_list \
			       {} ]

## definitions of unshared actions/includes ##

    set unshared_output_action {
	uplevel "add_interface_port $master_output_interface_name ${master_module_name}_${output_name}    ${master_module_name}_${output_name}_out   output $width"
        uplevel "set_port_property ${master_module_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set unshared_input_action {
	uplevel "add_interface_port $master_output_interface_name ${master_module_name}_${input_name}   ${master_module_name}_${input_name}_in    input $width"
        uplevel "set_port_property ${master_module_name}_${input_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set unshared_bidir_action {
	uplevel "add_interface_port $master_output_interface_name ${master_module_name}_${output_name}   ${master_module_name}_${output_name}_out   output $width"
        uplevel "set_port_property ${master_module_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port $master_output_interface_name ${master_module_name}_${input_name}    ${master_module_name}_${output_name}_in    input  $width"
        uplevel "set_port_property ${master_module_name}_${input_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port $master_output_interface_name ${master_module_name}_${output_enable_name} ${master_module_name}_${output_name}_outen output  1"
    }
    set unshared_tristatable_action {
	uplevel "add_interface_port $master_output_interface_name ${master_module_name}_${output_name}   ${master_module_name}_${output_name}_out   output $width"
        uplevel "set_port_property ${master_module_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port $master_output_interface_name ${master_module_name}_${output_enable_name} ${master_module_name}_${output_name}_outen output  1"
    }
    set unshared_includes {
	unshared_output_action
	unshared_input_action
	unshared_bidir_action
	unshared_tristatable_action
	master_output_interface_name
    }

## add unshared master ports ##

    iterate_through_listinfo \
	$split_lists(unshared_module_origin_list) \
	$split_lists(unshared_signal_origin_list) \
	$split_lists(unshared_signal_origin_type) \
	$split_lists(unshared_signal_origin_width) \
	$split_lists(unshared_signal_output_names) \
	$split_lists(unshared_signal_input_names) \
	$split_lists(unshared_signal_output_enable_names) \
	{} \
	{
	    set ta_includes "master_output_interface_name master_module_name output_name input_name output_enable_name width"
	    type_action $type \
		${unshared_output_action} \
		${unshared_input_action} \
		${unshared_bidir_action} \
		${unshared_tristatable_action} \
		${ta_includes}
	} ${unshared_includes}


    array set shared_details [ create_shared_specific_arrays \
				   $split_lists(shared_signal_slave_interface_names) \
				   $split_lists(shared_signal_origin_list) \
				   $split_lists(shared_signal_origin_type) \
				   $split_lists(shared_signal_origin_width) \
				   $split_lists(shared_signal_names)\
				   $split_lists(shared_signal_input_names)\
				   $split_lists(shared_signal_output_names)\
				   $split_lists(shared_signal_output_enable_names)
			       ]
    
    set shared_output_action {
	uplevel "add_interface_port $master_output_interface_name ${shared_name}       ${shared_name}_out   output $shared_widths_array(${shared_name})"
        set_port_property ${shared_name} VHDL_TYPE STD_LOGIC_VECTOR
    }
    set shared_input_action {
	uplevel "add_interface_port $master_output_interface_name ${shared_name}       ${shared_name}_in    input  $shared_widths_array(${shared_name})"
        set_port_property ${shared_name} VHDL_TYPE STD_LOGIC_VECTOR
    }
    set shared_bidir_action {
	uplevel "add_interface_port $master_output_interface_name ${shared_name}       ${shared_name}_out   output $shared_widths_array(${shared_name})"
        set_port_property ${shared_name} VHDL_TYPE STD_LOGIC_VECTOR
	uplevel "add_interface_port $master_output_interface_name ${shared_name}_in    ${shared_name}_in    input  $shared_widths_array(${shared_name})"
        set_port_property ${shared_name}_in VHDL_TYPE STD_LOGIC_VECTOR
	uplevel "add_interface_port $master_output_interface_name ${shared_name}_outen ${shared_name}_outen output  1"
    }
    set shared_tristatable_action {
	uplevel "add_interface_port $master_output_interface_name ${shared_name}       ${shared_name}_out   output $shared_widths_array(${shared_name})"
        set_port_property ${shared_name} VHDL_TYPE STD_LOGIC_VECTOR
	uplevel "add_interface_port $master_output_interface_name ${shared_name}_outen ${shared_name}_outen output  1"
    }

    set shared_widths $shared_details(shared_signal_widths_array)

    set shared_includes {
	shared_output_action
	shared_input_action
	shared_bidir_action
	shared_tristatable_action
	master_output_interface_name
	shared_widths
    }


## add shared master ports ##

    iterate_through_listinfo \
	$split_lists(shared_module_origin_list) \
	$split_lists(shared_signal_origin_list) \
	$split_lists(shared_signal_origin_type) \
	$split_lists(shared_signal_origin_width) \
	$split_lists(shared_signal_output_names) \
	$split_lists(shared_signal_input_names) \
	$split_lists(shared_signal_output_enable_names) \
	$split_lists(shared_signal_names) \
	{
	    set ta_includes "master_output_interface_name shared_name width shared_widths"
	    type_action $type \
		${shared_output_action} \
		${shared_input_action} \
		${shared_bidir_action} \
		${shared_tristatable_action} \
		${ta_includes} \
       	        { array set shared_widths_array ${shared_widths} }
	} ${shared_includes}

    #tb partner assignments
    set modified_roles_list ""
    iterate_through_listinfo \
	$derived_lists(module_origin_list) {} \
	$derived_lists(signal_origin_type) {} \
	$derived_lists(signal_output_names) \
	$derived_lists(signal_input_names) {} {} \
	{
	    if { [string equal $type "Input"] } {
		uplevel lappend modified_roles_list ${master_module_name}_${input_name}
	    } else {
		uplevel lappend modified_roles_list ${master_module_name}_${output_name}
	    }
	}

    set_module_assignment testbench.partner.map.tcm pin_divider.in
    set_module_assignment testbench.partner.pin_divider.class altera_conduit_pin_divider    
    set_module_assignment testbench.partner.pin_divider.parameter.MODULE_ORIGIN_LIST $derived_lists(module_origin_list)
    set_module_assignment testbench.partner.pin_divider.parameter.SIGNAL_ORIGIN_LIST $modified_roles_list
    set_module_assignment testbench.partner.pin_divider.parameter.SIGNAL_ORIGIN_TYPE $derived_lists(signal_origin_type)
    set_module_assignment testbench.partner.pin_divider.parameter.SIGNAL_ORIGIN_WIDTH $derived_lists(signal_origin_width)
    set_module_assignment testbench.partner.pin_divider.parameter.SHARED_SIGNAL_LIST $user_shared_signal_list

}

proc create_shared_specific_arrays { slave_interface_names signal_roles signal_types signal_widths shared_names input_names output_names output_enable_names} {
    if { [array exists shared_signal_widths_array                  ] } { array unset shared_signal_widths_array                  }
    if { [array exists shared_signal_count_array                   ] } { array unset shared_signal_count_array                   }
    if { [array exists shared_signal_types_array                   ] } { array unset shared_signal_types_array                   }
    if { [array exists signal_name_to_interface_array              ] } { array unset signal_name_to_interface_array              }
    if { [array exists shared_name_to_signal_name_and_widths_array ] } { array unset shared_name_to_signal_name_and_widths_array }
    if { [array exists signal_name_to_input_name_array             ] } { array unset signal_name_to_input_name_array             }
    if { [array exists signal_name_to_output_name_array            ] } { array unset signal_name_to_output_name_array            }
    if { [array exists signal_name_to_output_enable_name_array     ] } { array unset signal_name_to_output_enable_name_array     }
    if { [array exists toReturn                                    ] } { array unset toReturn                                    }

    set shared_signal_widths ""
    set shared_signal_count ""
    set shared_signal_types ""

    foreach \
	slave_interface_name ${slave_interface_names}\
	signal_role          ${signal_roles}\
	signal_type          ${signal_types}\
	signal_width         ${signal_widths}\
	shared_name          ${shared_names}\
        input_name           ${input_names}\
	output_name          ${output_names}\
	output_enable_name   ${output_enable_names}\
    {
	if { [ string length ${shared_name} ] != 0 } {

	    set signal_name "${slave_interface_name}_${signal_role}"
	    set signal_name_to_interface_array(${signal_name})          ${slave_interface_name}
	    set signal_name_to_input_name_array(${signal_name})         ${input_name}
	    set signal_name_to_output_name_array(${signal_name})        ${output_name}
	    set signal_name_to_output_enable_name_array(${signal_name}) ${output_enable_name}

	    
	    if { [ llength [ array names shared_name_to_signal_name_and_widths_array ${shared_name} ] ] == 1  } {
		set temp $shared_name_to_signal_name_and_widths_array(${shared_name})
	    } else {
		set temp ""
	    }
	    lappend temp ${signal_name}
	    lappend temp ${signal_width}

	    set shared_name_to_signal_name_and_widths_array(${shared_name}) ${temp}

	    if { [string length [array names shared_signal_widths_array ${shared_name} ] ] != 0 } {
		set width $shared_signal_widths_array(${shared_name})
		
		if { $width < $signal_width } {
		    set shared_signal_widths_array(${shared_name}) $signal_width
		}

		set shared_signal_count_array(${shared_name}) [expr $shared_signal_count_array(${shared_name}) + 1 ]
	    } else {
		set shared_signal_widths_array(${shared_name}) $signal_width
		set shared_signal_count_array(${shared_name}) 1
	    }

	    set shared_signal_types_array(${shared_name}) ${signal_type}
	}
    }

 foreach \
	signal_role ${signal_roles}\
	signal_type ${signal_types}\
	signal_width ${signal_widths}\
	shared_name ${shared_names}\
    {

	if { [ string length ${shared_name} ] != 0 } {
	    lappend shared_signal_types  $shared_signal_types_array(${shared_name})
	    lappend shared_signal_count  $shared_signal_count_array(${shared_name})
	    lappend shared_signal_widths $shared_signal_count_array(${shared_name})
	} else {
	    lappend shared_signal_types  {}
	    lappend shared_signal_widths {}
	    lappend shared_signal_count  {}
	}
    }
    
    set toReturn(shared_signal_count)  ${shared_signal_count}
    set toReturn(shared_signal_widths) ${shared_signal_widths}
    set toReturn(shared_signal_types)  ${shared_signal_types}

    set toReturn(shared_signal_count_array)                   [ array get shared_signal_count_array                    ]
    set toReturn(shared_signal_widths_array)                  [ array get shared_signal_widths_array                   ]
    set toReturn(shared_signal_types_array)                   [ array get shared_signal_types_array                    ]
    set toReturn(shared_name_to_signal_name_and_widths_array) [ array get shared_name_to_signal_name_and_widths_array  ]
    set toReturn(signal_name_to_interface_array)              [ array get signal_name_to_interface_array               ]
    set toReturn(signal_name_to_input_name_array)             [ array get signal_name_to_input_name_array              ]
    set toReturn(signal_name_to_output_name_array)            [ array get signal_name_to_output_name_array             ]
    set toReturn(signal_name_to_output_enable_name_array)     [ array get signal_name_to_output_enable_name_array           ]
    
    return [array get toReturn]
}

proc generate {} {
    global slave_input_interface_prefix

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_tristate_conduit_pin_sharer_core.sv.terp" ]

    set output_dir    [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name   [ get_generation_property OUTPUT_NAME ]
    set template      [ read [ open $template_file r ] ]

    set raw [get_parameter_value INTERFACE_INFO]

    set params(TRISTATECONDUIT_INFO) ${raw}
    set params(NUM_INTERFACES)               [ get_parameter NUM_INTERFACES     ]
    set params(SHARED_SIGNAL_LIST)           [ get_parameter SHARED_SIGNAL_LIST ]
    set params(OUTPUT_NAME)                  ${output_name}
    set params(SLAVE_INPUT_INTERFACE_PREFIX) ${slave_input_interface_prefix}
    set params(HIERARCHY_LEVEL)              [ get_parameter HIERARCHY_LEVEL    ]

    set result          [ altera_terp $template params ]
    set output_file     [ file join $output_dir ${output_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result

    close $output_handle

    add_file ${output_file} {SYNTHESIS SIMULATION}
}
