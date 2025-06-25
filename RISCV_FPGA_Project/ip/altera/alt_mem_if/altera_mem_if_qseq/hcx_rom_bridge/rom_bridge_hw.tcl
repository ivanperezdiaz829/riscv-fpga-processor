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

set_module_property NAME hcx_rom_bridge
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME hcx_rom_bridge
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL rom_bridge

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL rom_bridge

add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL rom_bridge


proc generate_verilog_fileset {} {
	set file_list [list \
		rom_bridge.v \
		sequencer_raminit.v \
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
set_parameter_property AVL_DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_DATA_WIDTH HDL_PARAMETER true

add_parameter AVL_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME AVL_ADDR_WIDTH
set_parameter_property AVL_ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property AVL_ADDR_WIDTH HDL_PARAMETER true

add_parameter ROM_SIZE INTEGER 13
set_parameter_property ROM_SIZE DISPLAY_NAME AVL_ADDR_WIDTH
set_parameter_property ROM_SIZE AFFECTS_ELABORATION true
set_parameter_property ROM_SIZE HDL_PARAMETER true

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

	add_interface write_clock clock end
	set_interface_property write_clock ENABLED true
	add_interface_port write_clock write_clock clk Input 1
	
	add_interface reset_sink reset end
	set_interface_property reset_sink ENABLED true
	set_interface_property reset_sink synchronousEdges none
	add_interface_port reset_sink soft_reset_n reset_n Input 1
	
	add_interface hc_rom_interface conduit end
	set_interface_property hc_rom_interface ENABLED true
	add_interface_port hc_rom_interface rom_address rom_address Output  [get_parameter_value AVL_ADDR_WIDTH]
	add_interface_port hc_rom_interface rom_data rom_data Input [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port hc_rom_interface rom_rden rom_rden Output 1
	add_interface_port hc_rom_interface init init Input 1
	add_interface_port hc_rom_interface rom_data_ready rom_data_ready Input 1
	add_interface_port hc_rom_interface init_busy init_busy Output 1
	
	add_interface avalon_master avalon start
	set_interface_property avalon_master associatedClock write_clock
	set_interface_property avalon_master associatedReset reset_sink	
	set_interface_property avalon_master burstOnBurstBoundariesOnly false
	set_interface_property avalon_master doStreamReads false
	set_interface_property avalon_master doStreamWrites false
	set_interface_property avalon_master linewrapBursts false
	
	set_interface_property avalon_master ASSOCIATED_CLOCK write_clock
	set_interface_property avalon_master ENABLED true
	
	add_interface_port avalon_master avlm_address address Output [expr {[get_parameter_value AVL_ADDR_WIDTH] + 2}]
	add_interface_port avalon_master avlm_writedata writedata Output [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port avalon_master avlm_wren write Output 1
	add_interface_port avalon_master avlm_waitrequest waitrequest Input 1
}
