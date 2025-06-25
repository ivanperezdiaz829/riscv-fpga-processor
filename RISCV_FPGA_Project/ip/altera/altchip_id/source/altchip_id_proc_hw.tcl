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
# | 
# | $Header: //acds/rel/13.1/ip/altchip_id/source/altchip_id_proc_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaboration_callback {} {
	
	update_device_type_params elaboration
	
}

proc update_device_type_params {flag} {

	set get_device_family [get_parameter_value DEVICE_FAMILY]
	
	if {!($get_device_family == "Stratix V" || $get_device_family == "Arria V GZ"
			|| $get_device_family == "Arria V" || $get_device_family == "Cyclone V")} {
		send_message error "ALTCHIP_ID only supports 28nm device family."
	}
	
}
	
# +-----------------------------------
# | Callback function when generating variation file
# +-----------------------------------
proc generate_synth {entityname} {

	send_message info "generating top-level entity $entityname"
	add_fileset_file altchip_id.v VERILOG PATH "altchip_id.v"

}

proc generate_vhdl_sim {entityname} {

	if {1} {
		add_fileset_file mentor/altchip_id.v VERILOG_ENCRYPT PATH "../mentor/source/altchip_id_simulation.v" {MENTOR_SPECIFIC}
	}

}

proc generate_verilog_sim {entityname} {

	add_fileset_file altchip_id.v VERILOG PATH "altchip_id_simulation.v"

}
