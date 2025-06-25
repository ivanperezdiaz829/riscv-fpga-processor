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


# (C) 2002-2010 Altera Corporation. All rights reserved.
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
# | 
# | $Header: //acds/rel/13.1/ip/altera_mult_add/source/top/altera_mult_add_proc.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | 
# | This function checks on clocks or aclr usage
# | Return true if the clock or aclr signal is used
# +-----------------------------------
proc is_use_dedicated_clock_or_aclr {if_reg_use reg_signal signal_type} {
	
	set get_if_reg_use [get_parameter_value $if_reg_use]
	set get_reg_signal [get_parameter_value $reg_signal]
	
	if {$get_if_reg_use == 1 || $get_if_reg_use eq "true" || $get_if_reg_use eq "CLOCK0" || $get_if_reg_use eq "CLOCK1" || $get_if_reg_use eq "CLOCK2" || $get_if_reg_use eq "CLOCK3"} {
		set result [expr {($get_reg_signal == $signal_type)? "true" : "false"}]
	} else {
		set result "false"
	}

	return $result
}

# +----------------------------------------------
# | 
# | Function to add port interface
# | 	port_type (range): "in", "out", "clock"
# |		port_name: "<string>"
# | 	port_width : <integer>
# | 	terminate_flag : "true", "false"
# | 	termination_value : <integer>
# | 
# +----------------------------------------------
proc my_add_interface_port {port_type port_name port_width terminate_flag termination_value} {
	
	if {$port_type eq "in"} {
		add_interface $port_name conduit end
		add_interface_port $port_name $port_name $port_name Input $port_width
	} elseif {$port_type eq "out"} {
		add_interface $port_name conduit start
		set_interface_assignment $port_name "ui.blockdiagram.direction" OUTPUT
		add_interface_port $port_name $port_name $port_name Output $port_width
	} elseif {$port_type eq "clk"} {
		add_interface $port_name clock end
		add_interface_port $port_name $port_name clk Input $port_width
	} else {
		send_message error "Illegal port type"
	}
	
	if {$terminate_flag eq "true"} {
		set_port_property $port_name TERMINATION true
		set_port_property $port_name TERMINATION_VALUE $termination_value
	}
}