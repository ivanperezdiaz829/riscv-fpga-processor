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


# $Id: //acds/rel/13.1/ip/merlin/altera_tristate_conduit_bridge_translator/altera_tristate_conduit_bridge_translator_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

package require -exact sopc 11.0
package require -exact altera_terp 1.0

source "../altera_tristate_conduit_pin_sharer_core/altera_tc_lib.tcl"
namespace import ::altera_tc_lib::*

set_module_property NAME altera_tristate_conduit_bridge_translator
set_module_property VERSION 13.1
set_module_property GROUP "Tri-State Components"
set_module_property DISPLAY_NAME "Tri-State Conduit Bridge Translator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL false
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "This component converts false conduit tri-state signals into conduit output signals.  Its primary use is strictly for simulation."

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

set slave_name in
set master_name out

add_interface $slave_name conduit end
add_interface $master_name conduit end

proc elaborate {} {
    global slave_name
    global master_name

    set derived_lists(module_origin_list) [get_parameter MODULE_ORIGIN_LIST]
    set derived_lists(signal_origin_list) [get_parameter SIGNAL_ORIGIN_LIST]
    set derived_lists(signal_origin_type) [get_parameter SIGNAL_ORIGIN_TYPE]
    set derived_lists(signal_origin_width) [get_parameter SIGNAL_ORIGIN_WIDTH]

    set output_action {
	uplevel "add_interface_port $slave_name ${slave_name}_$role $role input $width"
	uplevel "set_port_property ${slave_name}_$role VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port $master_name $role $role output $width"
	uplevel "set_port_property $role VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set input_action {
	uplevel "add_interface_port $slave_name ${slave_name}_$role $role output $width"
	uplevel "set_port_property ${slave_name}_$role VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port $master_name $role $role input $width"
	uplevel "set_port_property $role VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set bidir_action {
	uplevel "add_interface_port $slave_name ${slave_name}_$role $role bidir $width"
	uplevel "set_port_property ${slave_name}_$role VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port $master_name $role $role bidir $width"
	uplevel "set_port_property $role VHDL_TYPE STD_LOGIC_VECTOR"
    }
    set tristatable_action {
	uplevel "add_interface_port $slave_name ${slave_name}_$role $role input $width"
	uplevel "set_port_property ${slave_name}_$role VHDL_TYPE STD_LOGIC_VECTOR"
	uplevel "add_interface_port $master_name $role $role output $width"
	uplevel "set_port_property $role VHDL_TYPE STD_LOGIC_VECTOR"
    }
    
    set includes {
	slave_name
	master_name
	output_action
	input_action
	bidir_action
	tristatable_action
    }

    iterate_through_listinfo \
	$derived_lists(module_origin_list) \
	$derived_lists(signal_origin_list) \
	$derived_lists(signal_origin_type) \
	$derived_lists(signal_origin_width) \
	{} {} {} {} \
	{
	    set ta_includes {role width slave_name master_name}
	    if { ![string equal $role "request"] && ![string equal $role "grant"] } {
		type_action $type \
		    ${output_action} \
		    ${input_action} \
		    ${bidir_action} \
		    ${tristatable_action} \
		    $ta_includes
	    }
	} $includes
}

proc gen_vhdl { output_name } {
    set result [ generate ${output_name} 1 ]
    add_fileset_file altera_inout.vhd VHDL PATH ../altera_conduit_pin_divider/altera_inout.vhd
    add_fileset_file ${output_name}.vhd VHDL TEXT ${result}
}

proc gen_verilog { output_name } {
    set result [ generate ${output_name} 0 ]
    add_fileset_file altera_inout.sv SYSTEM_VERILOG PATH ../altera_conduit_pin_divider/altera_inout.sv
    add_fileset_file ${output_name}.sv SYSTEM_VERILOG TEXT ${result}
}

proc generate { output_name VHDL_GEN } {
    global slave_name

    set template_file altera_tristate_conduit_bridge_translator.sv.terp

    set template      [ read [ open ${template_file} r ] ]

    set params(GEN_VHDL) ${VHDL_GEN}
    set params(CHAIN_LENGTH) [get_parameter CHAIN_LENGTH]
    set params(MODULE_ORIGIN_LIST) [get_parameter MODULE_ORIGIN_LIST]
    set params(SIGNAL_ORIGIN_LIST) [get_parameter SIGNAL_ORIGIN_LIST]
    set params(SIGNAL_ORIGIN_TYPE) [get_parameter SIGNAL_ORIGIN_TYPE]
    set params(SIGNAL_ORIGIN_WIDTH) [get_parameter SIGNAL_ORIGIN_WIDTH]
    set params(OUTPUT_NAME) ${output_name}
    set params(SLAVE_NAME) ${slave_name}

    set result          [ altera_terp ${template} params ]

    return ${result}
}
