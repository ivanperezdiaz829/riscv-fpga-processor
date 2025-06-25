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
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "Register File (11.1)"
set_module_property NAME sequencer_reg_file_111
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY Register File (11.1 Version)"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL sequencer_reg_file

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL sequencer_reg_file

add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL sequencer_reg_file



proc generate_verilog_fileset {} {
	set file_list [list \
		sequencer_reg_file.sv \
	]
	
	return $file_list
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"

		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name $non_encryp_simulators

		add_fileset_file [file join mentor $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 1 1] PATH [file join mentor $file_name] {MENTOR_SPECIFIC}
	}
}

proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name
	}
}

proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}
}

add_parameter AVL_DATA_WIDTH INTEGER 32
set_parameter_property AVL_DATA_WIDTH DISPLAY_NAME AVL_DATA_WIDTH
set_parameter_property AVL_DATA_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property AVL_DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true

add_parameter AVL_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME AVL_ADDR_WIDTH
set_parameter_property AVL_ADDR_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property AVL_ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true

add_parameter AVL_NUM_SYMBOLS INTEGER 4
set_parameter_property AVL_NUM_SYMBOLS DISPLAY_NAME AVL_NUM_SYMBOLS
set_parameter_property AVL_NUM_SYMBOLS AFFECTS_ELABORATION true
set_parameter_property AVL_NUM_SYMBOLS HDL_PARAMETER true
set_parameter_property AVL_NUM_SYMBOLS DERIVED true

add_parameter AVL_SYMBOL_WIDTH INTEGER 8
set_parameter_property AVL_SYMBOL_WIDTH DISPLAY_NAME AVL_SYMBOL_WIDTH
set_parameter_property AVL_SYMBOL_WIDTH ALLOWED_RANGES 1:1024
set_parameter_property AVL_SYMBOL_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_SYMBOL_WIDTH HDL_PARAMETER true

add_parameter REGISTER_RDATA BOOLEAN false
set_parameter_property REGISTER_RDATA DISPLAY_NAME REGISTER_RDATA
set_parameter_property REGISTER_RDATA HDL_PARAMETER true

add_parameter NUM_REGFILE_WORDS INTEGER 8
set_parameter_property NUM_REGFILE_WORDS DISPLAY_NAME NUM_REGFILE_WORDS
set_parameter_property NUM_REGFILE_WORDS ALLOWED_RANGES 1:1024
set_parameter_property NUM_REGFILE_WORDS HDL_PARAMETER true


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
	
	set num_symbols [expr {int([get_parameter_value AVL_DATA_WIDTH] / [get_parameter_value AVL_SYMBOL_WIDTH])}]
	set_parameter_value AVL_NUM_SYMBOLS $num_symbols
	
	set num_sym_mult_sym_width [expr {$num_symbols * [get_parameter_value AVL_SYMBOL_WIDTH]}]
	
	if {$num_sym_mult_sym_width != [get_parameter_value AVL_DATA_WIDTH]} {
		_eprint "Symbol width is not a multiple of data width"
	}
	

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	::alt_mem_if::gen::uniphy_interfaces::basic_sequencer_manager_interfaces 1
}
