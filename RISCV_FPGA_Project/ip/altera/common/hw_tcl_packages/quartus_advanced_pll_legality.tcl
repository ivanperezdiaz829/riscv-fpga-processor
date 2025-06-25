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


# package: quartus::advanced_pll_legality
#
# Provides a wrapper around the Quartus advanced_pll_legality functions
#
package provide quartus::advanced_pll_legality 1.0

################################################################################
###                          TCL INCLUDES                                   ###
################################################################################
package require altera_hwtcl_qtcl
package require quartus::device

################################################################################
###                          TCL NAMESPACE                                   ###
################################################################################
namespace eval ::quartus::advanced_pll_legality:: {
	# Package Exports
	
	# Namespace variables

	# The maximum number of output clocks
	variable MAX_OUTPUT_CLOCKS 18

	# The default configuration name for solving PLL settings
	variable CONFIGURATION_NAME GENERIC_PLL

	# The default PLL mode is integer-N
	variable FRACTIONAL_VCO_MULTIPLIER "false"

	# The default channel spacing to use when solving PLL settings
	variable CHANNEL_SPACING 0.0

	# The default PLL type to use
	variable PLL_TYPE fPLL
	
	# Import functions into namespace
	
}

################################################################################
###                      EXPORTED WRAPPERS                                   ###
################################################################################

proc ::quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values {args} {
	return [run_quartus_tcl_command "advanced_pll_legality:get_advanced_pll_legality_legal_values $args"]
}


################################################################################
###                       PUBLIC FUNCTIONS                                   ###
################################################################################

# proc: get_advanced_pll_legality_solved_ref_clock_freq
#
# Interfaces with the advanced_pll_legality Quartus package to solve the PLL
# legal pll reference clock frequency range for the supplied part
#
# parameters:
#
#  part_name : The part to use when solving for clocks
#
# returns:
#
#    2-D list of solved frequencies. The first element is the minimum frequency
#    in MHz, and the second is the max frequency in MHz
#
proc ::quartus::advanced_pll_legality::get_advanced_pll_legality_solved_ref_clock_freq {pll_part} {
	# Import package variables
	variable CONFIGURATION_NAME
	variable FRACTIONAL_VCO_MULTIPLIER
	variable CHANNEL_SPACING


	set pll_ref_freq_range [quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values -configuration_name $CONFIGURATION_NAME -rule_name REFERENCE_CLOCK_FREQUENCY -flow MEGAWIZARD -param_args [list $pll_part $FRACTIONAL_VCO_MULTIPLIER fPLL "$CHANNEL_SPACING MHz"]]
	_dprint 1 "PLL ref = $pll_ref_freq_range"
	# Format of return string is: {5.0 MHz..800.0 MHz}
	if {[regexp -nocase {[\{ ]*([0-9]+\.*[0-9]*)[ ]*MHz\.\.([0-9]+\.*[0-9]*)[ ]*MHz[\} ]*$} $pll_ref_freq_range junk ref_clk_freq_min ref_clk_freq_max] == 0} {
		_error "Fatal Error: Cannot pattern match PLL reference clock from $pll_ref_freq_range"
	}
	
	return [list $ref_clk_freq_min $ref_clk_freq_max]
}


# proc: get_advanced_pll_legality_solved_legal_pll_values
#
# Interfaces with the advanced_pll_legality Quartus package to solve the PLL
# parameters for the clocks supplied
#
# parameters:
#
#  part_name : The part to use when solving for clocks
#  ref_clock_freq : The reference clock frequency in MHz
#  clock_params : A 2-D list of clock parameters. The sublist is a list of
#     desired clock frequency in MHz, desired phase in ps, and desired duty
#     cycle in %. If phase is obmitted, the phase is assumed to be 0ps. If the
#     duty cycle if omitted the duty cycle is assumed to be 50% (note: currently
#     only 50% DC is supported). The clock should be ordered in such a way that
#     the fastest clock is listed first.
#  safe_halved_clock : Optional boolean parameter that forces the fastest solved 
#     clock frequency to be one which when halved and doubled won't cause period 
#     mismatches due truncation in TimeQuest.
#
#
# returns:
#
#    2-D list of solved clocks. The elements in the sublist are frequency in MHz,
#    phase in ps, duty cycle in deg.
#
#   0 : An error occurred solving any clock
#
proc ::quartus::advanced_pll_legality::get_advanced_pll_legality_solved_legal_pll_values {pll_part ref_clk_freq clock_params {safe_halved_clock 0}} {

	# Import package constants
	variable MAX_OUTPUT_CLOCKS
	variable CONFIGURATION_NAME
	variable FRACTIONAL_VCO_MULTIPLIER
	variable CHANNEL_SPACING
	variable PLL_TYPE
	
	if {[llength $clock_params] > $MAX_OUTPUT_CLOCKS} {
		_error "Fatal Error: Illegal number of clock params"
	}
	
	set solved_clocks [list]
	set solved_freqs [list]
	set solved_phases [list]
	
	# Format of the parameters is:
	#part
	#this generic_pll reference_clock_frequency
	#this generic_pll output_clock_frequency
	#this generic_pll phase_shift
	#this generic_pll duty_cycle
	#this generic_pll pll_type
	#this generic_pll pll_channel_spacing
	#outclk1 generic_pll output_clock_frequency
	#outclk1 generic_pll phase_shift
	#outclk1 generic_pll duty_cycle
	#outclk2 generic_pll output_clock_frequency
	#outclk2 generic_pll phase_shift
	#outclk2 generic_pll duty_cycle

	# Iterate through each clock to solve the frequencies, assuming 0 phase, 50% DC
	foreach clk_info $clock_params {
		if {[llength $clk_info] > 3} {
			_error "Illegal number of clock info elements ($clk_info)"
		}
		set requested_pll_output_freq [lindex $clk_info 0]
		
		# Append the requested parameters		
		set pll_params [list $pll_part "$ref_clk_freq MHz"]
		lappend pll_params "$requested_pll_output_freq MHz"
		lappend pll_params "0 ps"
		lappend pll_params 50
		
		# Append the PLL type and channel spacing
		lappend pll_params $FRACTIONAL_VCO_MULTIPLIER
		lappend pll_params $PLL_TYPE
		lappend pll_params "$CHANNEL_SPACING MHz"

		# Append the dependant clock parameters
		for {set solved_clock_index 0} {$solved_clock_index < [llength $solved_freqs]} {incr solved_clock_index} {
			set solved_freq [lindex $solved_freqs $solved_clock_index]
			lappend pll_params "$solved_freq MHz"
			lappend pll_params "0 ps"
			lappend pll_params 50
		}

		# Pad the list to have the correct number of clocks
		for {set depdendant_clock_index [expr {1 + [llength $solved_freqs]}]} {$depdendant_clock_index < $MAX_OUTPUT_CLOCKS} {incr depdendant_clock_index} {
			lappend pll_params ""
			lappend pll_params ""
			lappend pll_params ""
		}
		
		_dprint 1 "Using PLL params of $pll_params"
		
		# Test to see if the frequency can be solved
		_dprint 1 "Calling get_advanced_pll_legality_legal_values -configuration_name GENERIC_PLL -rule_name OUTPUT_CLOCK_FREQUENCY -flow MEGAWIZARD -param_args $pll_params"
		set solved_pll_output_freq_list [quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values -configuration_name GENERIC_PLL -rule_name OUTPUT_CLOCK_FREQUENCY -flow MEGAWIZARD -param_args $pll_params]
		_dprint 1 "Solved clock freq to be $solved_pll_output_freq_list MHz based on requested frequency of $requested_pll_output_freq"
		if {[regexp {^[\{\} ]*$} $solved_pll_output_freq_list junk] == 1} {
			_eprint "Cannot determine valid frequency for clock ($requested_pll_output_freq MHz)"
			return 0
		}
		
		# Format of output is:
		#350.0 MHz|349.70238 MHz|349.637681 MHz|349.609375 MHz|349.537037 MHz
		
		if {($safe_halved_clock == 1) && ([llength $solved_freqs] == 0)} {
			# For the first clock choose one that provides a period that when doubled doesn't have rounding issues
			
			# First make the list solely of frequencies by removing extraneous characters
			_dprint 1 "\t\t$solved_pll_output_freq_list"
			set temp [string map {\{ ""} $solved_pll_output_freq_list]
			set temp2 [string map {\} ""} $temp]
			set temp [string map {" MHz" ""} $temp2]
			
			# Now loop through the frequencies
			set frequency_value_list [split $temp "|"]
			set found 0
			foreach frequency_value $frequency_value_list {
				set period_ps [expr 1000*1000/$frequency_value]
				set int_double_period_ps [expr int($period_ps*2)]
				set double_int_period_ps [expr int($period_ps)*2]
				if {$int_double_period_ps == $double_int_period_ps} {
					set found 1
					set solved_pll_output_freq $frequency_value
					break
				}
			}
			if {$found == 0} {
				_error "Fatal Error: Cannot find PLL settings that allow for truncation-free problems in TimeQuest"
			}
		} else {
			# For now always just choose the first entry for all other clocks
			if {[regexp -nocase {[\{]*[ ]*([0-9]+\.*[0-9]*)[ ]*MHz} $solved_pll_output_freq_list junk solved_pll_output_freq] == 0} {
				_error "Fatal Error: Cannot pattern match $solved_pll_output_freq_list for frequency"
			}
		}

		# Add this solved freq
		_dprint 1 "Solved frequency: $requested_pll_output_freq MHz => $solved_pll_output_freq MHz"
		lappend solved_freqs $solved_pll_output_freq
		
		# Coarse sanity check to ensure solved freq is not too different from requested freq
		if { [expr { abs($solved_pll_output_freq - $requested_pll_output_freq) * 1.0 / $requested_pll_output_freq}] > 0.05 } {
			_eprint "Solved freq ($solved_pll_output_freq MHz) differs from requested freq ($requested_pll_output_freq MHz) by too much!"
			return 0
		}
	}

	# Iterate through each clock to solve the phases using solved frequencies, assuming 50% DC
	foreach clk_info $clock_params {
		if {[llength $clk_info] > 1} {
			set requested_pll_output_phase [lindex $clk_info 1]
		} else {
			set requested_pll_output_phase 0
		}

		# Get the solved frequency corresponding to the phase being requested
		set solved_clock_index [llength $solved_phases]
		set solved_pll_output_freq [lindex $solved_freqs $solved_clock_index]
		
		# Append the requested parameters		
		set pll_params [list $pll_part "$ref_clk_freq MHz"]
		lappend pll_params "$solved_pll_output_freq MHz"
		lappend pll_params "$requested_pll_output_phase ps"
		lappend pll_params 50
		
		# Append the PLL type and channel spacing
		lappend pll_params $FRACTIONAL_VCO_MULTIPLIER
		lappend pll_params $PLL_TYPE
		lappend pll_params "$CHANNEL_SPACING MHz"

		# Append the dependant clock parameters. 
		# All frequencies and phases solved so far need to be included.
		# For clock outputs where the frequency has been solved but not the phase, use 0
		for {set solved_clock_index 0} {$solved_clock_index < [llength $solved_freqs]} {incr solved_clock_index} {
			set solved_freq [lindex $solved_freqs $solved_clock_index]
			if {$solved_clock_index < [llength $solved_phases]} {
				set solved_phase [lindex $solved_phases $solved_clock_index]
			} else {
				set solved_phase 0
			}
			lappend pll_params "$solved_freq MHz"
			lappend pll_params "$solved_phase ps"
			lappend pll_params 50
		}		

		# Pad the list to have the correct number of clocks
		for {set depdendant_clock_index [expr {1 + [llength $solved_freqs]}]} {$depdendant_clock_index < $MAX_OUTPUT_CLOCKS} {incr depdendant_clock_index} {
			lappend pll_params ""
			lappend pll_params ""
			lappend pll_params ""
		}
		
		_dprint 1 "Using PLL params of $pll_params"
		
		if {$requested_pll_output_phase != 0} {
			_dprint 1 "Calling get_advanced_pll_legality_legal_values -configuration_name GENERIC_PLL -rule_name PHASE_SHIFT -flow MEGAWIZARD -param_args $pll_params"
			set solved_pll_output_phase_list [quartus::advanced_pll_legality::get_advanced_pll_legality_legal_values -configuration_name GENERIC_PLL -rule_name PHASE_SHIFT -flow MEGAWIZARD -param_args $pll_params]
			_dprint 1 "Solved clock phase to be $solved_pll_output_phase_list ps based on requested phase of $requested_pll_output_phase"
			if {[regexp {^[\{\} ]*$} $solved_pll_output_phase_list junk] == 1} {
				_error "Cannot determine valid phase for clock ($solved_pll_output_freq MHz $requested_pll_output_phase ps)"
				return 0
			}
		} else {
			# 0ps phase is always possible
			set solved_pll_output_phase_list "0 ps"
		}		
				
		# Format of output is:
		#0 ps|0 ps|0 ps|0 ps|0 ps
		# For now always just choose the first entry
		if {[regexp -nocase {^[\{]*[ ]*([0-9]+\.*[0-9]*)[ ]*ps} $solved_pll_output_phase_list junk solved_pll_output_phase] == 0} {
			_error "Fatal Error: Cannot pattern match $solved_pll_output_phase_list for phase"
		}

		# Add this solved phase
		_dprint 1 "Solved phase: $requested_pll_output_phase ps => $solved_pll_output_phase ps"
		lappend solved_phases $solved_pll_output_phase
		
		# Coarse sanity check to ensure that solved phase is not too different from requested phase
		if {$requested_pll_output_phase != 0} {
			if { [expr { abs($solved_pll_output_phase - $requested_pll_output_phase) * 1.0 / $requested_pll_output_phase}] > 0.3 } {
				_error "Solved phase ($solved_pll_output_phase) differs from requested phase ($requested_pll_output_phase ps) by too much!"
				return 0
			}
		}
	}
	
	# Populate the solved_clocks list
	for {set solved_clock_index 0} {$solved_clock_index < [llength $solved_freqs]} {incr solved_clock_index} {
		set solved_freq [lindex $solved_freqs $solved_clock_index]
		set solved_phase [lindex $solved_phases $solved_clock_index]
		set solved_duty_cycle 50
		lappend solved_clocks [list $solved_freq $solved_phase $solved_duty_cycle]
	}
	
	return $solved_clocks
}


################################################################################
###                       PRIVATE FUNCTIONS                                  ###
################################################################################

# proc: _init
#
# Private function to initialize the package
# file
#
# parameters:
#
# returns:
#
proc ::quartus::advanced_pll_legality::_init {} {

	return 1
}


################################################################################
###                   AUTO RUN CODE AT STARTUP                               ###
################################################################################
# Run the initialization
::quartus::advanced_pll_legality::_init
