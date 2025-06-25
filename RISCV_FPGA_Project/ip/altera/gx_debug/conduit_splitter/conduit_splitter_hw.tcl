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


# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module conduit splitter 
# | 
set_module_property DESCRIPTION "A conduit signal splitter"
set_module_property NAME conduit_splitter 
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Peripherals/Debug and Performance"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Conduit splitter"
set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_embedded_ip.pdf
set_module_property TOP_LEVEL_HDL_FILE conduit_splitter.v
set_module_property TOP_LEVEL_HDL_MODULE conduit_splitter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file conduit_splitter.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter OUTPUT_NUM INTEGER 2 
set_parameter_property OUTPUT_NUM ALLOWED_RANGES {0:5}
set_parameter_property OUTPUT_NUM DISPLAY_NAME NUM_OF_OUTPUT_PORTS 
set_parameter_property OUTPUT_NUM UNITS None
set_parameter_property OUTPUT_NUM DISPLAY_HINT ""
set_parameter_property OUTPUT_NUM AFFECTS_GENERATION true
set_parameter_property OUTPUT_NUM IS_HDL_PARAMETER true

add_interface conduit_input conduit end 
add_interface_port conduit_input conduit_input export Input 1 

proc elaborate {} {
    set output_num [get_parameter_value OUTPUT_NUM]
    for { set i 0 } { $i <  $output_num } { incr i } {
        set port_name "conduit_output_$i"
        add_interface $port_name conduit start
        set_interface_property $port_name ENABLED true
        add_interface_port $port_name $port_name export Output 1
    }
}


