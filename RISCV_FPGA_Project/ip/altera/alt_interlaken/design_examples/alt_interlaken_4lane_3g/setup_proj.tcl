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



# Quartus II: Generate Tcl File for Project
# File: setup_proj.tcl
# Generated on: Wed Sep 22 10:05:49 2010

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "alt_interlaken_4lane_3g"]} {
		puts "Project alt_interlaken_4lane_3g is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists alt_interlaken_4lane_3g]} {
		project_open -revision alt_interlaken_4lane_3g alt_interlaken_4lane_3g
	} else {
		project_new -revision alt_interlaken_4lane_3g alt_interlaken_4lane_3g
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Stratix IV"
	set_global_assignment -name DEVICE EP4SGX530NF45C2
	set_global_assignment -name SDC_FILE alt_interlaken_4lane_3g.sdc
	set_global_assignment -name QIP_FILE ./alt_interlaken_4lane_3g/synthesis/alt_interlaken_4lane_3g.qip
	set_instance_assignment -name GXB_0PPM_CORE_CLOCK ON -from *tx_serial_data* -to *tx_serial_data*
	set_instance_assignment -name GXB_0PPM_CORE_CLOCK ON -from *rx_serial_data* -to *rx_serial_data*

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
