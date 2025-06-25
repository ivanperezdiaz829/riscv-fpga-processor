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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/emif/util"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
   lappend auto_path $alt_mem_if_tcl_libs_dir
}

set altera_phylite_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/altera_phylite/util"
if {[lsearch -exact $auto_path $altera_phylite_tcl_libs_dir] == -1} {
   lappend auto_path $altera_phylite_tcl_libs_dir
}

package require -exact qsys 13.0

package require altera_emif::util::hwtcl_utils
package require altera_emif::util::device_family
package require altera_phylite::ip_sim_ctrl::main

load_strings common_messages.properties
load_strings common_gui.properties
load_strings messages.properties
load_strings gui.properties

set_module_property DESCRIPTION [get_string HWTCL_MODULE_DESCRIPTION]
set_module_property NAME altera_phylite_sim_ctrl
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [get_string INTERNAL_COMPONENT_ROOT_FOLDER]
set_module_property AUTHOR [get_string AUTHOR]
set_module_property DISPLAY_NAME [get_string HWTCL_MODULE_DISPLAY_NAME]
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property DATASHEET_URL [get_string DATASHEET_URL]
set_module_property SUPPORTED_DEVICE_FAMILIES [::altera_emif::util::device_family::get_qsys_supported_families]

set_module_property ELABORATION_CALLBACK ::altera_phylite::ip_sim_ctrl::main::elaboration_callback

add_fileset sim_vhdl SIM_VHDL ::altera_phylite::ip_sim_ctrl::main::sim_vhdl_fileset_callback
set_fileset_property sim_vhdl TOP_LEVEL phylite_sim_ctrl

add_fileset sim_verilog SIM_VERILOG ::altera_phylite::ip_sim_ctrl::main::sim_verilog_fileset_callback
set_fileset_property sim_verilog TOP_LEVEL phylite_sim_ctrl

add_fileset quartus_synth QUARTUS_SYNTH ::altera_phylite::ip_sim_ctrl::main::quartus_synth_fileset_callback
set_fileset_property quartus_synth TOP_LEVEL phylite_sim_ctrl

add_display_item "" QSYS_GUI_FOR_INTERNAL_COMPONENTS_TEXT TEXT [get_string QSYS_GUI_FOR_INTERNAL_COMPONENTS_DESC]

::altera_phylite::ip_sim_ctrl::main::create_parameters
