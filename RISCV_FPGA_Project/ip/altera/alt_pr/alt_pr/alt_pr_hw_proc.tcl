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
# | $Header: //acds/rel/13.1/ip/alt_pr/alt_pr/alt_pr_hw_proc.tcl#3 $
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaboration_callback {} {
	
	# set a randomly generated 31 bits unsigned unique identifier to replace default value
	set id [get_parameter_value UNIQUE_IDENTIFIER]
	if {$id == 2013} {
		set max 2147483647
		set unique_id [expr {int(rand()*$max)}]
		set_parameter_value UNIQUE_IDENTIFIER $unique_id
	}
	
	# edcrc osc divisor settings only available for internal host
	set is_internal_host [get_parameter_value PR_INTERNAL_HOST]
	set_parameter_property EDCRC_OSC_DIVIDER ENABLED $is_internal_host
	
	# PR megafunction is available for all devices when used as external host
	# however, internal host only available for devices that support PR
	if {$is_internal_host == "true"} {
		update_device_type_params
	}
	
	# display ports for external host
	if {$is_internal_host == "true"} {
		set_interface_property pr_ready_pin ENABLED false
		set_interface_property pr_done_pin ENABLED false
		set_interface_property pr_error_pin ENABLED false
		set_interface_property crc_error_pin ENABLED false
		set_interface_property pr_request_pin ENABLED false
		set_interface_property pr_clk_pin ENABLED false
		set_interface_property pr_data_pin ENABLED false
	} else {
        set_interface_property pr_ready_pin ENABLED true
		set_interface_property pr_done_pin ENABLED true
		set_interface_property pr_error_pin ENABLED true
		set_interface_property crc_error_pin ENABLED true
		set_interface_property pr_request_pin ENABLED true
		set_interface_property pr_clk_pin ENABLED true
		set_interface_property pr_data_pin ENABLED true
    }
}

proc update_device_type_params {} {

	set get_device_family [get_parameter_value DEVICE_FAMILY]
	
	if {!(($get_device_family == "Stratix V") || ($get_device_family == "Arria V GZ"))} {
		
		set skip_dev_check [get_quartus_ini "enable_alt_pr_instantiation"]
		
		if {!($skip_dev_check)} {
			send_message error "Partial Reconfiguration megafunction is not supported for the specified device family when used as Internal Host."
		}
	}
}
	
proc generate_synth {entityname} {
	send_message info "generating top-level entity $entityname"
	
	add_fileset_file alt_pr.v VERILOG PATH alt_pr.v
	
	add_fileset_file ../rtl/alt_pr_bitstream_controller.v VERILOG PATH ../rtl/alt_pr_bitstream_controller.v
	add_fileset_file ../rtl/alt_pr_bitstream_host.v VERILOG PATH ../rtl/alt_pr_bitstream_host.v
	add_fileset_file ../rtl/alt_pr_cb_controller.v VERILOG PATH ../rtl/alt_pr_cb_controller.v
	add_fileset_file ../rtl/alt_pr_cb_interface.v VERILOG PATH ../rtl/alt_pr_cb_interface.v
	add_fileset_file ../rtl/alt_pr_data_source_controller.v VERILOG PATH ../rtl/alt_pr_data_source_controller.v
	add_fileset_file ../rtl/alt_pr_jtag_interface.v VERILOG PATH ../rtl/alt_pr_jtag_interface.v
	add_fileset_file ../rtl/alt_pr_standard_data_interface.v VERILOG PATH ../rtl/alt_pr_standard_data_interface.v
	add_fileset_file ../rtl/alt_pr_bitstream_compatibility_checker.v VERILOG PATH ../rtl/alt_pr_bitstream_compatibility_checker.v
}


