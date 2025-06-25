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


#########################################
# Represents the SoC partition of the HPS
#########################################
package require -exact qsys 12.0
package require -exact altera_terp 1.0

source ../util/constants.tcl
source ../util/procedures.tcl

set_module_property NAME altera_hps_io
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property SUPPORTED_DEVICE_FAMILIES {CYCLONEV ARRIAV}
set_module_property SUPPRESS_WARNINGS NO_PORTS_AFTER_ELABORATION

add_parameter border_description string "{}" ""
add_parameter hps_parameter_map string ""

#~~~~~~~~~~~~~~~~~~~~~ START OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}
source "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_interfaces/alt_mem_if_hps_emif/common_hps_emif.tcl"
#~~~~~~~~~~~~~~~~~~~~~ END OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set_module_property composition_callback compose

proc compose {} {
    add_instance border altera_interface_generator
    array set border_description [get_parameter_value border_description]
    set_instance_parameter_value border interfaceDefinition [array get border_description]
    set_instance_parameter_value border qipEntries [list "set_instance_assignment -name hps_partition on -entity %entityName% -library %libraryName%"]
    set_instance_parameter_value border ignoreSimulation true
    set_instance_parameter_value border hps_parameter_map [get_parameter_value hps_parameter_map]

    set interfaces $border_description(interfaces)
    expose_border border $interfaces
    
    #~~~~~~~~~~~~~~~~~~~~~ START OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    foreach param_name [get_instance_parameters border] {
	if {$param_name != "interfaceDefinition" &&
	    $param_name != "qipEntries" &&
	    $param_name != "ignoreSimulation" &&
	    $param_name != "hps_parameter_map"} {
            set_instance_parameter border $param_name [get_parameter_value $param_name]
	}
    }
    #~~~~~~~~~~~~~~~~~~~~~ END OF BLOCK ADDED FOR EMIF ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
}
