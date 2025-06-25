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


proc publish_debug_info {} {
    publish_connections
    publish_module_parameters
}

proc publish_connections {} {
    set con_list [get_connections]

    foreach connection $con_list {
	set_module_assignment "debug.connections.${connection}" true
    }
}

proc publish_module_parameters {} {
    set inst_list [get_instances]

    foreach instance $inst_list {
	set_module_assignment "debug.instances.${instance}" true
	foreach parameter [get_instance_parameters ${instance}] {
	    set_module_assignment "debug.instances.${instance}.${parameter}" [get_instance_parameter_value ${instance} ${parameter} ]
	}
    }
}
