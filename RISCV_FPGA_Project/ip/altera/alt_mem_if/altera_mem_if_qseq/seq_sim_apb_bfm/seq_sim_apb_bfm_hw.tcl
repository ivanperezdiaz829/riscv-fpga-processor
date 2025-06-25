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
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*

set_module_property NAME 		seq_sim_apb_bfm
set_module_property VERSION 		13.1
set_module_property AUTHOR 		"Altera Corporation"
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP 	true
set_module_property GROUP 		[::alt_mem_if::util::hwtcl_utils::memory_sequencer_components_group_name] 
set_module_property DISPLAY_NAME 	"UniPHY Sequencer APB Master BFM"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE 		false
set_module_property ANALYZE_HDL 	false



add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL seq_sim_apb_bfm

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth

proc generate_verilog_fileset {} {
	set file_list [list \
		seq_sim_apb_bfm.sv \
		seq_sim_apb_bfm_hw.tcl \
		seq_sim_bfm_interface.sv \
		seq_sim_bfm_lib.c \
		vc_hdrs.h
	]
	
	return $file_list
}


proc generate_vhdl_sim {name} {
	_iprint "synthesis fileset for $name not supported"
}

proc generate_verilog_sim {name} {
	_iprint "SEQ_SIM_APB_BFM: Preparing to generate verilog simulation fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_iprint "SEQ_SIM_APB_BFM: Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}
}

proc generate_synth {name} {
	_iprint "synthesis fileset for $name not supported"
}

add_parameter DWIDTH INTEGER 32
set_parameter_property DWIDTH DEFAULT_VALUE 32
set_parameter_property DWIDTH DISPLAY_NAME DWIDTH
set_parameter_property DWIDTH DESCRIPTION {Data width}
set_parameter_property DWIDTH TYPE INTEGER
set_parameter_property DWIDTH UNITS None
set_parameter_property DWIDTH ALLOWED_RANGES 1:128
set_parameter_property DWIDTH AFFECTS_GENERATION false
set_parameter_property DWIDTH AFFECTS_ELABORATION true
set_parameter_property DWIDTH HDL_PARAMETER true

add_parameter AWIDTH INTEGER 10
set_parameter_property AWIDTH DEFAULT_VALUE 10
set_parameter_property AWIDTH DISPLAY_NAME AWIDTH
set_parameter_property AWIDTH DESCRIPTION {Address width}
set_parameter_property AWIDTH TYPE INTEGER
set_parameter_property AWIDTH UNITS None
set_parameter_property AWIDTH ALLOWED_RANGES 1:128
set_parameter_property AWIDTH AFFECTS_GENERATION false
set_parameter_property AWIDTH AFFECTS_ELABORATION true
set_parameter_property AWIDTH HDL_PARAMETER true



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
	_iprint "SEQ_SIM_APB_BFM: Running IP Validation"

}

proc ip_elaborate {} {
	_iprint "SEQ_SIM_APB_BFM: Running IP Elaboration"

	add_interface apb_master conduit start

	set_interface_property apb_master ENABLED true

	add_interface_port apb_master prdata prdata Input [get_parameter_value DWIDTH]
	add_interface_port apb_master pready pready Input 1
	add_interface_port apb_master pslverr pslverr Input 1
	add_interface_port apb_master pwdata pwdata Output [get_parameter_value DWIDTH]
	add_interface_port apb_master pwrite pwrite Output 1
	add_interface_port apb_master penable penable Output 1
	add_interface_port apb_master psel psel Output 1
	add_interface_port apb_master paddr paddr Output [get_parameter_value AWIDTH]

	add_interface pclk clock end
	add_interface sp_reset_n reset end

	set_interface_property pclk ENABLED true
	set_interface_property sp_reset_n associatedClock pclk

	add_interface_port pclk pclk clk Input 1
	add_interface_port sp_reset_n sp_reset_n reset_n Input 1
	
}

