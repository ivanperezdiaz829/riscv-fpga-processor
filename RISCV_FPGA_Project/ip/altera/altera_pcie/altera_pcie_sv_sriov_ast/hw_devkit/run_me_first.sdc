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


# derive_pll_clocks won't create a clock if one exists on a node already
# Make a base clock on the nodes in question to get through derive_pll_clocks
proc create_placeholder_clocks { } {
  # We need to create the clock only once
	global ran_it
  # Needs to be global so the placeholder can be removed later
	global placeholder_clock_name
  # If the procedure ran already, skip it
	if { [info exists ran_it] } { return }
  # Create a name for the clock that's unlikely to be used already in the design
	set placeholder_clock_name [clock clicks]
  # Make the base clock on the appropriate node
	create_clock -name $placeholder_clock_name -period 10 [get_pins -compat *|altpcie_hip_256_pipen1b|g_xcvr.sv_xcvr_pipe_native|inst_sv_xcvr_native|inst_sv_pcs|ch[4].inst_sv_pcs_ch|inst_sv_hssi_8g_rx_pcs|wys|rcvdclkpma]
	# Set the flag to avoid rerunning
  set ran_it 1
}

# Remove the clocks generated from the placeholder, and the placeholder
proc remove_placeholder_clocks {} {
  # Get the name of the base clock which is the master for the generated ones
	global placeholder_clock_name
	# If the clock has already been removed, don't try to remove it again
	if { ! [info exists placeholder_clock_name] } { return }
  # Walk through all the clocks in the design. Remove any that have the placeholder
  # as their master
	foreach_in_collection clk_id [get_clocks *] {
		set this_clock_name [get_clock_info -name $clk_id]
		set master [get_clock_info -master_clock $clk_id]
		if { [string equal $placeholder_clock_name $master] } {
			remove_clock $this_clock_name
		}
	}
  # Finally remove the placeholder
	remove_clock $placeholder_clock_name
	unset placeholder_clock_name
}

# Set up a few commands to run the custom procedures above
# Do it only once per TimeQuest session
if { 0 == [string length [info command derive_pll_clocks_other]] } {
	rename derive_pll_clocks derive_pll_clocks_other
	proc derive_pll_clocks { args } {
    create_placeholder_clocks
    eval derive_pll_clocks_other $args
  }
	rename update_timing_netlist update_timing_netlist_other
	proc update_timing_netlist { args } {
    remove_placeholder_clocks
    eval update_timing_netlist_other $args
  }
  rename reset_design reset_design_other
  proc reset_design { args } {
	global ran_it
	unset ran_it
	reset_design_other
  }
}