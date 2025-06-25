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

source "../altera_tristate_conduit_pin_sharer_core/altera_tc_lib.tcl"
namespace import ::altera_tc_lib::*

set_module_property NAME altera_conduit_pin_divider
set_module_property VERSION 13.1
set_module_property GROUP "Tri-State Components"
set_module_property DISPLAY_NAME "Conduit Pin Divider"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "This component converts shared signals into their associated original signals.  Its primary use is for the testbench generator."

add_display_item "" "Sharing Assignment" "group" "table"

add_fileset SIM_VERILOG SIM_VERILOG gen_verilog
add_fileset SIM_VHDL SIM_VHDL gen_vhdl

add_parameter CHAIN_LENGTH INTEGER 4
set_parameter_property CHAIN_LENGTH AFFECTS_ELABORATION true
set_parameter_property CHAIN_LENGTH HDL_PARAMETER false
set_parameter_property CHAIN_LENGTH ALLOWED_RANGES "1:32000"
set_parameter_property CHAIN_LENGTH DISPLAY_NAME "Chain Length"
set_parameter_property CHAIN_LENGTH DESCRIPTION "VHDL only : Number of wait states before sampling bidirectional signals"

add_parameter MODULE_ORIGIN_LIST STRING_LIST ""
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_NAME "Interface"
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_HINT "table"
set_parameter_property MODULE_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property MODULE_ORIGIN_LIST HDL_PARAMETER false
set_parameter_property MODULE_ORIGIN_LIST GROUP "Sharing Assignment"
set_parameter_property MODULE_ORIGIN_LIST DISPLAY_HINT "WIDTH:230"
set_parameter_property MODULE_ORIGIN_LIST DESCRIPTION "Master to original signal mapping"

add_parameter SIGNAL_ORIGIN_LIST STRING_LIST ""
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_NAME "Signal Role"
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_LIST AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_LIST HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_LIST GROUP "Sharing Assignment"
set_parameter_property SIGNAL_ORIGIN_LIST DISPLAY_HINT "WIDTH:150"
set_parameter_property SIGNAL_ORIGIN_LIST DESCRIPTION "Original signal to original signal mapping"

add_parameter SIGNAL_ORIGIN_TYPE STRING_LIST ""
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_NAME "Signal Type"
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_TYPE AFFECTS_ELABORATION true
set_parameter_property SIGNAL_ORIGIN_TYPE HDL_PARAMETER false
set_parameter_property SIGNAL_ORIGIN_TYPE GROUP "Sharing Assignment"
set_parameter_property SIGNAL_ORIGIN_TYPE DISPLAY_HINT "WIDTH:100"
set_parameter_property SIGNAL_ORIGIN_TYPE DESCRIPTION "Signal type to original signal mapping"

add_parameter SIGNAL_ORIGIN_WIDTH INTEGER_LIST ""
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_NAME "Signal Width"
set_parameter_property SIGNAL_ORIGIN_WIDTH DISPLAY_HINT "table"
set_parameter_property SIGNAL_ORIGIN_WIDTH AFFECTS_ELABORATION true
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

set slave_name in
add_interface ${slave_name} conduit end

proc elaborate {} {
    global slave_name

    set derived_lists(module_origin_list) [get_parameter MODULE_ORIGIN_LIST]
    set derived_lists(signal_origin_list) [get_parameter SIGNAL_ORIGIN_LIST]
    set derived_lists(signal_origin_type) [get_parameter SIGNAL_ORIGIN_TYPE]
    set derived_lists(signal_origin_width) [get_parameter SIGNAL_ORIGIN_WIDTH]

    foreach module $derived_lists(module_origin_list) {
	regexp {(.*)\.(.*)} $module junk master interface
	add_interface ${master}_${interface} conduit end
    }
    
    set master_output_action {
	uplevel "add_interface_port ${master_module_name}_${master_interface_name} ${role} ${short_role} output ${width}"
   uplevel "set_port_property ${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set master_input_action {
	uplevel "add_interface_port ${master_module_name}_${master_interface_name} ${role} ${short_role} input ${width}"
   uplevel "set_port_property ${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set master_bidir_action {
	uplevel "add_interface_port ${master_module_name}_${master_interface_name} ${role} ${short_role} bidir ${width}"
   uplevel "set_port_property ${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set master_tristatable_action {
	uplevel "add_interface_port ${master_module_name}_${master_interface_name} ${role} ${short_role} output ${width}"
   uplevel "set_port_property ${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_unshared_output_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${role} ${role} input ${width}"
   uplevel "set_port_property ${slave_name}_${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_unshared_input_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${role} ${role} output ${width}"
   uplevel "set_port_property ${slave_name}_${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_unshared_bidir_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${role} ${role} bidir ${width}"
   uplevel "set_port_property ${slave_name}_${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_unshared_tristatable_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${role} ${role} input ${width}"
   uplevel "set_port_property ${slave_name}_${role} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_shared_output_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${shared_name} ${shared_name} input ${max_width}"
   uplevel "set_port_property ${slave_name}_${shared_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_shared_input_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${shared_name} ${shared_name} output ${max_width}"
   uplevel "set_port_property ${slave_name}_${shared_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_shared_bidir_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${shared_name} ${shared_name} bidir ${max_width}"
   uplevel "set_port_property ${slave_name}_${shared_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set slave_shared_tristatable_action {
	uplevel "add_interface_port ${slave_name} ${slave_name}_${shared_name} ${shared_name} input ${max_width}"
   uplevel "set_port_property ${slave_name}_${shared_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }

    set master_includes {
	master_output_action
	master_input_action
	master_bidir_action
	master_tristatable_action
    }
    set slave_unshared_includes {
	slave_unshared_output_action
	slave_unshared_input_action
	slave_unshared_bidir_action
	slave_unshared_tristatable_action
	slave_name
    }
    set slave_shared_includes {
	slave_shared_output_action
	slave_shared_input_action
	slave_shared_bidir_action
	slave_shared_tristatable_action
	slave_name
    }
    set unshared_assign_includes {
	unshared_assign_output_action
	unshared_assign_input_action
	unshared_assign_bidir_action
	unshared_assign_tristatable_action
	slave_name
    }
    set shared_assign_includes {
	shared_assign_output_action
	shared_assign_input_action
	shared_assign_bidir_action
	shared_assign_tristatable_action
	slave_name
    }
    
    iterate_through_listinfo \
	$derived_lists(module_origin_list) \
	$derived_lists(signal_origin_list) \
	$derived_lists(signal_origin_type) \
	$derived_lists(signal_origin_width) \
	{} {} {} {} \
	{
	    regsub -- ${master_module_name}_ $role "" short_role
	    set ta_includes {master_module_name master_interface_name role short_role width}
	    type_action $type \
		${master_output_action} \
		${master_input_action} \
		${master_bidir_action} \
		${master_tristatable_action} \
		$ta_includes
	} $master_includes
    
    array set split_lists [segregate_shared_from_unshared \
			       $derived_lists(module_origin_list) \
			       $derived_lists(signal_origin_list) \
			       $derived_lists(signal_origin_type) \
			       $derived_lists(signal_origin_width) \
			       {} {} {} \
			       [get_parameter SHARED_SIGNAL_LIST] \
			       {}]
    
    iterate_through_listinfo \
	$split_lists(unshared_module_origin_list) \
	$split_lists(unshared_signal_origin_list) \
	$split_lists(unshared_signal_origin_type) \
	$split_lists(unshared_signal_origin_width) \
	{} {} {} {} \
	{
	    regexp {(.*)\..*} $master_path junk master
	    set ta_includes {slave_name width master role}
	    type_action $type \
		${slave_unshared_output_action} \
		${slave_unshared_input_action} \
		${slave_unshared_bidir_action} \
		${slave_unshared_tristatable_action} \
		$ta_includes
	} $slave_unshared_includes
    
    iterate_through_listinfo \
	$split_lists(shared_module_origin_list) \
	$split_lists(shared_signal_origin_list) \
	$split_lists(shared_signal_origin_type) \
	$split_lists(shared_signal_origin_width) \
	{} {} {} \
	$split_lists(shared_signal_names) \
	{
	    set max_width $width
	    foreach temp_width $signal_origin_width temp_shared $shared_signal_names {
		if { [string equal $temp_shared $shared_name] } {
		    if { [expr $temp_width > $max_width] } {
			set max_width $temp_width
		    }
		}
	    }
		
	    set ta_includes {slave_name max_width shared_name}
	    lappend already_declared ""
	    if { [lsearch $already_declared ${slave_name}_${shared_name}] == -1 } {
		type_action $type \
		    ${slave_shared_output_action} \
		    ${slave_shared_input_action} \
		    ${slave_shared_bidir_action} \
		    ${slave_shared_tristatable_action} \
		    $ta_includes
		lappend already_declared ${slave_name}_${shared_name}
	    }
	} $slave_shared_includes
}

proc gen_vhdl { output_name } {
    set result [ generate ${output_name} 1 ]
    add_fileset_file altera_inout.vhd VHDL PATH altera_inout.vhd
    add_fileset_file ${output_name}.vhd VHDL TEXT ${result}    
}

proc gen_verilog { output_name } {
    set result [ generate ${output_name} 0 ]
    add_fileset_file altera_inout.sv SYSTEM_VERILOG PATH altera_inout.sv
    add_fileset_file ${output_name}.sv SYSTEM_VERILOG TEXT ${result}
}

proc generate { output_name VHDL_GEN } {
    global slave_name

    set template_file altera_conduit_pin_divider.sv.terp

    set template      [ read [ open ${template_file} r ] ]

    set params(GEN_VHDL) ${VHDL_GEN}
    set params(CHAIN_LENGTH) [get_parameter CHAIN_LENGTH]
    set params(MODULE_ORIGIN_LIST) [get_parameter MODULE_ORIGIN_LIST]
    set params(SIGNAL_ORIGIN_LIST) [get_parameter SIGNAL_ORIGIN_LIST]
    set params(SIGNAL_ORIGIN_TYPE) [get_parameter SIGNAL_ORIGIN_TYPE]
    set params(SIGNAL_ORIGIN_WIDTH) [get_parameter SIGNAL_ORIGIN_WIDTH]
    set params(SHARED_SIGNAL_LIST) [get_parameter SHARED_SIGNAL_LIST]
    set params(SLAVE_NAME) ${slave_name}
    set params(OUTPUT_NAME) ${output_name}

    set result          [ altera_terp ${template} params ]

    return ${result}
}
