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


# (C) 2001-2010 Altera Corporation. All rights reserved.
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

load_package advanced_pll_legality

##################################################
# Get the legal values from Quartus
##################################################
proc get_legal_values {rule_name param_args_list output_filename} {

	##################################################
	# Debug Only
	##################################################
	global DEBUG
	if { $DEBUG == 1 } {
		set args_file [open "rbc_args.txt" w]
		set i 0
		foreach arg $param_args_list {
			puts $args_file "arg[$i] = $arg"
			incr i
		}

		close $args_file
	}

	##################################################
	# Get the legal values from Quartus
	##################################################
	set dest_file [open "$output_filename" w]
	puts $dest_file [get_advanced_pll_legality_legal_values -flow_type MEGAWIZARD -configuration_name GENERIC_PLL -rule_name $rule_name -param_args $param_args_list]
	close $dest_file
}

##################################################
# Debug Only
##################################################
set DEBUG 0
if { $DEBUG == 1 } {
	set args_file [open "args.txt" w]
	set i 0
	foreach arg $argv {
		puts $args_file "arg[$i] = $arg"
		incr i
	}

	close $args_file
}

##################################################
# Get the initial arguments (must always pass in)
##################################################
set reference_clock_frequency_output_filename [lindex $argv 0]
set output_clock_frequency_output_filename [lindex $argv 1]
set phase_shift_output_filename [lindex $argv 2]
set duty_cycle_output_filename [lindex $argv 3]
set part [lindex $argv 4]
set reference_clock_frequency [lindex $argv 5]
set pll_type [lindex $argv 6]
set channel_spacing [lindex $argv 7]
set number_of_clocks [lindex $argv 8]
set arg_index 8

if {$channel_spacing == "0.0 MHz"} {
	set channel_spacing ""
}

##################################################
# Get the reference clock frequency legal range
##################################################
set param_args_list [list $part $pll_type $channel_spacing]
get_legal_values REFERENCE_CLOCK_FREQUENCY $param_args_list $reference_clock_frequency_output_filename

##################################################
# Initialize the arguments
##################################################
set dependent_args_list {}
set MAX_OTUPUT_CLOCKS 18

##################################################
# Get the clock settings for every clock
##################################################
for {set clock_index 0} {$clock_index < $number_of_clocks} {incr clock_index} {

	##################################################
	# Initialize the arguments (in the loop)
	##################################################
	set param_args_list {}
	lappend param_args_list $part
	lappend param_args_list $reference_clock_frequency
	
	##################################################
	# Get the desired output clock frequency
	##################################################
	incr arg_index
	set desired_output_clock_frequency [lindex $argv $arg_index]
	lappend param_args_list $desired_output_clock_frequency
	
	##################################################
	# Get the desired phase shift
	##################################################
	incr arg_index
	set desired_phase_shift [lindex $argv $arg_index]
	lappend param_args_list $desired_phase_shift

	##################################################
	# Get the desired duty cycle
	##################################################
	incr arg_index
	set desired_duty_cycle [lindex $argv $arg_index]
	lappend param_args_list $desired_duty_cycle
	
	##################################################
	# Add the PLL type and channel spacing settings
	##################################################
	lappend param_args_list $pll_type
	lappend param_args_list $channel_spacing

	##################################################
	# Add the dependent clock settings
	##################################################
	foreach dependent_arg $dependent_args_list {
		lappend param_args_list $dependent_arg
	}

	##################################################
	# Add the empty clock settings
	##################################################
	set dependent_clocks [expr [llength $dependent_args_list] / 3]
	for {set depdendent_clock_index [expr 1 + $dependent_clocks]} {$depdendent_clock_index < $MAX_OTUPUT_CLOCKS} {incr depdendent_clock_index} {
		lappend param_args_list ""
		lappend param_args_list ""
		lappend param_args_list ""
	}

	##################################################
	# Check the clock setting based on the other clocks
	##################################################
	get_legal_values OUTPUT_CLOCK_FREQUENCY $param_args_list "$output_clock_frequency_output_filename${clock_index}.txt"
	get_legal_values PHASE_SHIFT $param_args_list "$phase_shift_output_filename${clock_index}.txt"
	get_legal_values DUTY_CYCLE $param_args_list "$duty_cycle_output_filename${clock_index}.txt"
	
	##################################################
	# Add the clock setting as a dependent clock
	##################################################
	lappend dependent_args_list $desired_output_clock_frequency
	lappend dependent_args_list $desired_phase_shift
	lappend dependent_args_list $desired_duty_cycle
}
