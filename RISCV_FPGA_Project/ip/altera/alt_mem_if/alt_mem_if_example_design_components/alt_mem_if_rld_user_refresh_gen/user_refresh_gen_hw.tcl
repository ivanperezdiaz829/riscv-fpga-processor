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


set_module_property DESCRIPTION "RLDRAM II User Refresh Generator"
set_module_property NAME altera_mem_if_rld_user_refresh_gen
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "RLDRAM II User Refresh Generator"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL user_refresh_gen

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL user_refresh_gen

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL user_refresh_gen


proc generate_vhdl_sim {name} {
	add_fileset_file user_refresh_gen.sv SYSTEM_VERILOG PATH user_refresh_gen.sv [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	add_fileset_file [file join mentor user_refresh_gen.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor user_refresh_gen.sv] {MENTOR_SPECIFIC}
}

proc generate_verilog_sim {name} {
	add_fileset_file user_refresh_gen.sv SYSTEM_VERILOG PATH user_refresh_gen.sv
}

proc generate_synth {name} {
	add_fileset_file user_refresh_gen.sv SYSTEM_VERILOG PATH user_refresh_gen.sv
}


add_parameter CTL_BANKADDR_WIDTH INTEGER 1 
set_parameter_property CTL_BANKADDR_WIDTH DISPLAY_NAME "Controller bank address width"
set_parameter_property CTL_BANKADDR_WIDTH ALLOWED_RANGES 1:1000
set_parameter_property CTL_BANKADDR_WIDTH DESCRIPTION "Controller bank address width"
set_parameter_property CTL_BANKADDR_WIDTH HDL_PARAMETER true

add_parameter CTL_T_REFI INTEGER 1 
set_parameter_property CTL_T_REFI DISPLAY_NAME "Refresh period in controller clock cycles"
set_parameter_property CTL_T_REFI ALLOWED_RANGES 1:2147483647
set_parameter_property CTL_T_REFI DESCRIPTION "Refresh period in controller clock cycles"
set_parameter_property CTL_T_REFI HDL_PARAMETER true


if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property Validation_Callback ip_validate
	set_module_property elaboration_Callback ip_elaborate
} else {
	set_module_property elaboration_Callback combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_elaborate
}

proc ip_validate {} {
	_dprint 1 "Running IP Validation"

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	add_interface avl_clock clock end
	
	set_interface_property avl_clock ENABLED true
	
	add_interface_port avl_clock clk clk Input 1
	
	add_interface avl_reset reset end
	set_interface_property avl_reset synchronousEdges NONE
	
	set_interface_property avl_reset ENABLED true
	
	add_interface_port avl_reset reset_n reset_n Input 1
	
	add_interface user_refresh conduit end
	
	set_interface_property user_refresh ENABLED true
	
	add_interface_port user_refresh ref_ack ref_ack Input 1
	add_interface_port user_refresh ref_req ref_req Output 1
	add_interface_port user_refresh ref_ba ref_ba Output [get_parameter_value CTL_BANKADDR_WIDTH]
}
