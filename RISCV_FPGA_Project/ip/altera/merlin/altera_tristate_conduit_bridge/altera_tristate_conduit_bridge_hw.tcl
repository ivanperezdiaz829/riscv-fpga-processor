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

set_module_property NAME altera_tristate_conduit_bridge
set_module_property VERSION 13.1
set_module_property GROUP "Tri-State Components"
set_module_property DISPLAY_NAME "Tri-State Conduit Bridge"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property GENERATION_CALLBACK generate
set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Converts between an on-chip encoding of tri-state signals and true bidirectional signals"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_avalon_tc.pdf

add_parameter INTERFACE_INFO string ""
set_parameter_property INTERFACE_INFO system_info TRISTATECONDUIT_INFO
set_parameter_property INTERFACE_INFO system_info_arg "*"
set_parameter_property INTERFACE_INFO AFFECTS_ELABORATION true
set_parameter_property INTERFACE_INFO visible false

add_interface clk clock end
add_interface_port clk clk clk Input 1

add_interface reset reset end
add_interface_port reset reset reset Input 1
set_interface_property reset ASSOCIATED_CLOCK clk

set {master_output_interface_name} out
set slave_input_interface_name tcs

add_interface ${slave_input_interface_name} tristate_conduit slave clk
add_interface_port ${slave_input_interface_name} request request input 1
add_interface_port ${slave_input_interface_name} grant grant output 1

add_interface ${master_output_interface_name} conduit end

proc elaborate {} {
    global master_output_interface_name
    set raw [get_parameter_value INTERFACE_INFO]
    set sys_info [decode_tristate_conduit_masters ${raw}]

    set output_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_name} ${role}_out input ${width}"
	uplevel "set_port_property ${slave_interface_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	if { ![string equal $role "request"] } {
	    uplevel "add_interface_port ${master_output_interface_name} ${output_name} ${output_name} output ${width}"
            uplevel "set_port_property ${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	}
    }
    set input_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${input_name} ${role}_in output ${width}"
	uplevel "set_port_property ${slave_interface_name}_${input_name} VHDL_TYPE STD_LOGIC_VECTOR"
	if { ![string equal $role "grant"] } {
	    uplevel "add_interface_port ${master_output_interface_name} ${input_name} ${input_name} input ${width}"
            uplevel "set_port_property ${input_name} VHDL_TYPE STD_LOGIC_VECTOR"
	}
    }
    set bidir_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_name} ${role}_out input ${width}"
        uplevel "set_port_property  ${slave_interface_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_enable_name} ${role}_outen input 1"
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${input_name} ${role}_in output ${width}"
        uplevel "set_port_property  ${slave_interface_name}_${input_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port ${master_output_interface_name} ${output_name} ${output_name} bidir ${width}"
        uplevel "set_port_property  ${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set tristatable_action {
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_name} ${role}_out input ${width}"
        uplevel "set_port_property ${slave_interface_name}_${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port ${slave_interface_name} ${slave_interface_name}_${output_enable_name} ${role}_outen input 1"
	uplevel "add_interface_port ${master_output_interface_name} ${output_name} ${output_name} output ${width}"
        uplevel "set_port_property ${output_name} VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set includes {
	output_action
	input_action
	bidir_action
	tristatable_action
	master_output_interface_name
    }

    iterate_through_sysinfo ${sys_info} {} {} \
	{
	    set ta_includes {
		role
		width
		output_name
		input_name
		output_enable_name
		slave_interface_name
		master_output_interface_name
	    }
	    type_action ${type} ${output_action} ${input_action} ${bidir_action} ${tristatable_action} ${ta_includes}
	} ${includes}

### tb partner module assignments ###

    array set derived_lists [create_derived_lists $sys_info]

    set modified_roles_list ""
    iterate_through_listinfo \
	$derived_lists(module_origin_list) {} \
	$derived_lists(signal_origin_type) {} \
	$derived_lists(signal_output_names) \
	$derived_lists(signal_input_names) {} {} \
	{
	    if { [string equal $type "Input"] } {
		uplevel lappend modified_roles_list ${input_name}
	    } else {
		uplevel lappend modified_roles_list ${output_name}
	    }
	}

    set_module_assignment testbench.partner.tcb_translator.class altera_tristate_conduit_bridge_translator
    set_module_assignment testbench.partner.tcb_translator.parameter.MODULE_ORIGIN_LIST $derived_lists(module_origin_list)
    set_module_assignment testbench.partner.tcb_translator.parameter.SIGNAL_ORIGIN_LIST $modified_roles_list
    set_module_assignment testbench.partner.tcb_translator.parameter.SIGNAL_ORIGIN_TYPE $derived_lists(signal_origin_type)
    set_module_assignment testbench.partner.tcb_translator.parameter.SIGNAL_ORIGIN_WIDTH $derived_lists(signal_origin_width)
    set_module_assignment testbench.partner.map.out tcb_translator.in
}

proc generate {} {
    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join ${this_dir} "altera_tristate_conduit_bridge.sv.terp" ]

    set output_dir    [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name   [ get_generation_property OUTPUT_NAME ]
    set template      [ read [ open ${template_file} r ] ]

    set params(TRISTATECONDUIT_INFO) [get_parameter_value INTERFACE_INFO]
    set params(MODULE_NAME) ${output_name}

    set result          [ altera_terp ${template} params ]
    set output_file     [ file join ${output_dir} ${output_name}.sv ]
    set output_handle   [ open ${output_file} w ]

    puts ${output_handle} ${result}

    close ${output_handle}

    add_file ${output_file} {SYNTHESIS SIMULATION}
}
