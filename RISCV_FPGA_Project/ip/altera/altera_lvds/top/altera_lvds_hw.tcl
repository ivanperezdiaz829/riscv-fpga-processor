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


set altera_lvds_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/altera_lvds/util"
if {[lsearch -exact $auto_path $altera_lvds_tcl_libs_dir] == -1} {
	lappend auto_path $altera_lvds_tcl_libs_dir
}

set altera_emif_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/emif/util"
if {[lsearch -exact $auto_path $altera_emif_tcl_libs_dir] == -1} {
	lappend auto_path $altera_emif_tcl_libs_dir
}


package require -exact qsys 13.1


package require altera_lvds::top::main
package require altera_lvds::top::ex_design

load_strings gui.properties

set_module_property DESCRIPTION [get_string HWTCL_MODULE_DESCRIPTION]
set_module_property NAME altera_lvds
set_module_property VERSION 13.1
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME [get_string HWTCL_MODULE_DISPLAY_NAME]
set_module_property GROUP "I\/O"
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property HIDE_FROM_QSYS true
set_module_property HIDE_FROM_SOPC true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

set_module_property SUPPRESS_WARNINGS NO_PORTS_AFTER_ELABORATION

set_module_property COMPOSITION_CALLBACK ::altera_lvds::top::main::composition_callback
set_module_property VALIDATION_CALLBACK ::altera_lvds::top::main::validation_callback 
add_fileset example_design EXAMPLE_DESIGN ::altera_lvds::top::ex_design::example_design_fileset_callback 



::altera_lvds::top::main::create_parameters 
::altera_lvds::top::main::add_display_items

