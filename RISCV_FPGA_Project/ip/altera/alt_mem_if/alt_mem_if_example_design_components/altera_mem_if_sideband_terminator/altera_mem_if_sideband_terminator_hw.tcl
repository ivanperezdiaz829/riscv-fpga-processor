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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}

package require -exact qsys 12.0

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "UniPHY Controller Sideband Terminator"
set_module_property NAME altera_mem_if_sideband_terminator
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "UniPHY Controller Sideband Terminator"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_parameter MULTICAST_EN Boolean false
add_parameter CTL_AUTOPCH_EN Boolean false
add_parameter CTL_USR_REFRESH_EN Boolean false
add_parameter CTL_SELF_REFRESH_EN Boolean false
add_parameter CTL_DEEP_POWERDN_EN Boolean false

add_parameter CTL_CS_WIDTH Integer 1



set_module_property elaboration_Callback ip_elaborate

proc ip_elaborate {} {


	if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0} {
		add_interface avl_multicast_write conduit end
		set_interface_property avl_multicast_write ENABLED true
		add_interface_port avl_multicast_write local_multicast local_multicast Output 1
		set_port_property local_multicast DRIVEN_BY 0
	}

	if {[string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0} {
		add_interface autoprecharge_req conduit end
		set_interface_property autoprecharge_req ENABLED true
		add_interface_port autoprecharge_req local_autopch_req local_autopch_req Output 1
		set_port_property local_autopch_req DRIVEN_BY 0
	}

	if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
		add_interface user_refresh conduit end
		set_interface_property user_refresh ENABLED true
		add_interface_port user_refresh local_refresh_req local_refresh_req Output 1
		add_interface_port user_refresh local_refresh_chip local_refresh_chip Output [get_parameter_value CTL_CS_WIDTH]
		set_port_property local_refresh_chip VHDL_TYPE STD_LOGIC_VECTOR
		add_interface_port user_refresh local_refresh_ack local_refresh_ack Input 1
		set_port_property local_refresh_req DRIVEN_BY 0
		set_port_property local_refresh_chip DRIVEN_BY 0
		set_port_property local_refresh_ack DRIVEN_BY 0
	}

	if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
		add_interface self_refresh conduit end
		set_interface_property self_refresh ENABLED true
		add_interface_port self_refresh local_self_rfsh_req local_self_rfsh_req Output 1
		add_interface_port self_refresh local_self_rfsh_chip local_self_rfsh_chip Output [get_parameter_value CTL_CS_WIDTH]
		set_port_property local_self_rfsh_chip VHDL_TYPE STD_LOGIC_VECTOR
		add_interface_port self_refresh local_self_rfsh_ack local_self_rfsh_ack Input 1
		set_port_property local_self_rfsh_req DRIVEN_BY 0
		set_port_property local_self_rfsh_chip DRIVEN_BY 0
		set_port_property local_self_rfsh_ack DRIVEN_BY 0
	}
	
	if {[string compare -nocase [get_parameter_value CTL_DEEP_POWERDN_EN] "true"] == 0} {
		add_interface deep_powerdn conduit end
		set_interface_property deep_powerdn ENABLED true
		add_interface_port deep_powerdn local_deep_powerdn_req local_deep_powerdn_req Output 1
		add_interface_port deep_powerdn local_deep_powerdn_chip local_deep_powerdn_chip Output [get_parameter_value CTL_CS_WIDTH]
		set_port_property local_deep_powerdn_chip VHDL_TYPE STD_LOGIC_VECTOR
		add_interface_port deep_powerdn local_deep_powerdn_ack local_deep_powerdn_ack Input 1
		set_port_property local_deep_powerdn_req DRIVEN_BY 0
		set_port_property local_deep_powerdn_chip DRIVEN_BY 0
		set_port_property local_deep_powerdn_ack DRIVEN_BY 0
	}

}
