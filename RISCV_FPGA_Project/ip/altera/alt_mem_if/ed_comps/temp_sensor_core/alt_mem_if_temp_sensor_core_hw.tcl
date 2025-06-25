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
package require alt_mem_if::util::qini
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::system_info

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "alt_mem_if Temperature Sensor Core"
set_module_property NAME alt_mem_if_temp_sense_core
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "alt_mem_if Temperature Sensor Core"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL alt_mem_if_temp_sensor

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL alt_mem_if_temp_sensor

add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL alt_mem_if_temp_sensor



proc generate_verilog_fileset {} {
	set file_list [list \
		alt_mem_if_temp_sensor.sv \
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




add_parameter SENSE_WORD_WIDTH INTEGER 8
set_parameter_property SENSE_WORD_WIDTH DEFAULT_VALUE 8
set_parameter_property SENSE_WORD_WIDTH TYPE INTEGER
set_parameter_property SENSE_WORD_WIDTH AFFECTS_GENERATION false
set_parameter_property SENSE_WORD_WIDTH HDL_PARAMETER true
set_parameter_property SENSE_WORD_WIDTH VISIBLE false


alt_mem_if::gui::system_info::create_generic_parameters
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true
set_parameter_property SPEED_GRADE VISIBLE false



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

	alt_mem_if::gui::system_info::validate_generic_component	

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"


	add_interface pll_clk clock end
	set_interface_property pll_clk ENABLED true
	
	add_interface_port pll_clk pll_clk clk input 1
	
	add_interface global_reset_n reset end
	set_interface_property global_reset_n synchronousEdges NONE
	set_interface_property global_reset_n ENABLED true

	add_interface_port global_reset_n global_reset_n reset_n input 1
	
	add_interface pll_locked conduit end
	set_interface_property pll_locked ENABLED true
	
	add_interface_port pll_locked pll_locked pll_locked input 1
	
	add_interface sense_value conduit end
	set_interface_property sense_value ENABLED true
	
	add_interface_port sense_value sense_value sense_value output [get_parameter_value SENSE_WORD_WIDTH]

}



