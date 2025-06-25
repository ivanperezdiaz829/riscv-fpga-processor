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
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "UniPHY Sequencer Reset"
set_module_property NAME altera_mem_if_sequencer_rst
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "UniPHY Sequencer Reset"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth



proc generate_verilog_fileset {name tmpdir} {

	set generated_files_list [list]

	lappend generated_files_list "altera_mem_if_sequencer_rst.sv"   

	_dprint 1 "Using generated files list of $generated_files_list"

	return $generated_files_list
	
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set generated_file "altera_mem_if_sequencer_rst.sv" 
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]
	add_fileset_file [file join mentor   $generated_file] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor   $generated_file] {MENTOR_SPECIFIC}
}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set generated_file "altera_mem_if_sequencer_rst.sv"
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	set generated_file "altera_mem_if_sequencer_rst.sv"
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

}


add_parameter DEPTH INTEGER 8
set_parameter_property DEPTH DISPLAY_NAME DEPTH
set_parameter_property DEPTH ALLOWED_RANGES 3:16
set_parameter_property DEPTH HDL_PARAMETER true

add_parameter CLKEN_LAGS_RESET INTEGER 0
set_parameter_property CLKEN_LAGS_RESET DISPLAY_NAME CLKEN_LAGS_RESET
set_parameter_property CLKEN_LAGS_RESET ALLOWED_RANGES 0:1
set_parameter_property CLKEN_LAGS_RESET HDL_PARAMETER true




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

	add_interface clk clock end
	set_interface_property clk ENABLED true
	add_interface_port clk clk clk Input 1

	add_interface rst reset end
	set_interface_property rst ENABLED true
	add_interface_port rst rst reset Input 1
	set_interface_property rst associatedClock "clk"

	add_interface reset_out reset start
	add_interface_port reset_out reset_out reset Output 1
	set_interface_property reset_out associatedClock "clk"
	set_interface_property reset_out synchronousEdges "deassert"
	set_interface_property reset_out associatedResetSinks "rst"

	add_interface clken_out conduit start
	set_interface_property clken_out associatedClock "clk"
	set_interface_property clken_out associatedReset "rst"
	add_interface_port clken_out clken_out clken Output 1


	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL "altera_mem_if_sequencer_rst"
	}

}
