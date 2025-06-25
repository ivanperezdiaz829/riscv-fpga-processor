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


set altera_oct_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/altera_oct/altera_oct_common"
if {[lsearch -exact $auto_path $altera_oct_tcl_libs_dir] == -1} {
   lappend auto_path $altera_oct_tcl_libs_dir
}

package require -exact qsys 13.0
package require altera_oct::common

set ipcc_path "$env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_mega_common/ipcc_wrap_split.tcl"
source $ipcc_path

set_module_property DESCRIPTION "Altera oct Core"
set_module_property NAME altera_oct_core
set_module_property VERSION 13.1
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "Altera oct Core"
set_module_property GROUP "I/O"
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_QSYS true
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL true

add_display_item "" "General" GROUP

::altera_oct::common::add_oct_parameters "false" "false"
    
proc ip_elaborate {} {
	::altera_oct::common::elaborate "false"
}

proc ip_validate {} {
    ::altera_oct::common::validate
}

set_module_property ELABORATION_CALLBACK ip_elaborate
set_module_property VALIDATION_CALLBACK ip_validate

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_oct

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL altera_oct

proc generate_verilog_sim {name} {
	add_fileset_file altera_oct.sv SYSTEM_VERILOG PATH altera_oct.sv
}

proc generate_synth {name} {
	add_fileset_file altera_oct.sv SYSTEM_VERILOG PATH altera_oct.sv
}

