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


#__ACDS_USER_COMMENT__####################################################################
#__ACDS_USER_COMMENT__
#__ACDS_USER_COMMENT__ THIS IS AN AUTO-GENERATED FILE!
#__ACDS_USER_COMMENT__ -------------------------------
#__ACDS_USER_COMMENT__ If you modify this files, all your changes will be lost if you
#__ACDS_USER_COMMENT__ regenerate the core!
#__ACDS_USER_COMMENT__
#__ACDS_USER_COMMENT__ FILE DESCRIPTION
#__ACDS_USER_COMMENT__ ----------------
#__ACDS_USER_COMMENT__ This file contains the timing constraints for the Altera PLL.
#__ACDS_USER_COMMENT__    * The helper routines are defined in alterapll_pin_map.tcl
#__ACDS_USER_COMMENT__
#__ACDS_USER_COMMENT__ NOTE
#__ACDS_USER_COMMENT__ ----

set script_dir [file dirname [info script]]

source "$script_dir/alterapll_parameters.tcl"
source "$script_dir/alterapll_pin_map.tcl"


#__ACDS_USER_COMMENT__###################
#__ACDS_USER_COMMENT__                  #
#__ACDS_USER_COMMENT__ GENERAL SETTINGS #
#__ACDS_USER_COMMENT__                  #
#__ACDS_USER_COMMENT__###################

#__ACDS_USER_COMMENT__ This is a global setting and will apply to the whole design.
#__ACDS_USER_COMMENT__ This setting is required for the memory interface to be
#__ACDS_USER_COMMENT__ properly constrained.
derive_clock_uncertainty

#__ACDS_USER_COMMENT__ Debug switch. Change to 1 to get more run-time debug information
set debug 0

#__ACDS_USER_COMMENT__ All timing requirements will be represented in nanoseconds with up to 3 decimal places of precision
set_time_format -unit ns -decimal_places 3

#__ACDS_USER_COMMENT__ Determine if entity names are on
set entity_names_on [ alterapll_are_entity_names_on ]

load_package atoms
load_package sdc_ext
catch {read_atom_netlist} read_atom_netlist_out
set read_atom_netlist_error [regexp "ERROR" $read_atom_netlist_out]

#__ACDS_USER_COMMENT__ This is the main call to the netlist traversal routines
#__ACDS_USER_COMMENT__ that will automatically find all pins and registers required
#__ACDS_USER_COMMENT__ to apply timing constraints.
#__ACDS_USER_COMMENT__ During the fitter, the routines will be called only once
#__ACDS_USER_COMMENT__ and cached data will be used in all subsequent calls.


if { ! [ info exists alterapll_sdc_cache ] } {
	alterapll_initialize_pll_db alterapll_pll_db
	set alterapll_sdc_cache 1
} else {
	if { $debug } {
		post_message -type info "SDC: reusing cached PLL DB"
	}
}

#__ACDS_USER_COMMENT__ If multiple instances of this core are present in the
#__ACDS_USER_COMMENT__ design they will all be constrained through the
#__ACDS_USER_COMMENT__ following loop
set instances [ array names alterapll_pll_db ]
foreach { inst } $instances {
	if { [ info exists pins ] } {
		#__ACDS_USER_COMMENT__ Clean-up stale content
		unset pins
	}
	array set pins $alterapll_pll_db($inst)
	
	set prefix $inst
	if { $entity_names_on } {
		set prefix [ string map "| |*:" $inst ]
		set prefix "*:$prefix"
	}
	
	#__ACDS_USER_COMMENT__ -------------------------------- #
	#__ACDS_USER_COMMENT__ -                              - #
	#__ACDS_USER_COMMENT__ --- Determine PLL Parameters --- #
	#__ACDS_USER_COMMENT__ -                              - #
	#__ACDS_USER_COMMENT__ -------------------------------- #
	
	set pll_atoms [get_atom_nodes -matching ${prefix}* -type IOPLL]
	set num_pll_inst [get_collection_size $pll_atoms]
	
	if {$num_pll_inst > 1} { 
		#__ACDS_USER_COMMENT__ Error condition
		post_message -type error "SDC: More than one PLL atom found with instance name $inst"
	} elseif {($num_pll_inst == 0) || ($read_atom_netlist_error == 1)}  {
		#__ACDS_USER_COMMENT__ Use IP generated parameters
		if { $debug } {
			post_message -type info "SDC: using IP generated parameter values"
		}
	} else {
		#__ACDS_USER_COMMENT__ Use Quartus determined parameters
		if { $debug } {
			post_message -type info "SDC: using Quartus atom parameter values"
		}
		alterapll_get_pll_atom_parameters $pll_atoms
	}
	
	
	#__ACDS_USER_COMMENT__ ----------------------- #
	#__ACDS_USER_COMMENT__ -                     - #
	#__ACDS_USER_COMMENT__ --- REFERENCE CLOCK --- #
	#__ACDS_USER_COMMENT__ -                     - #
	#__ACDS_USER_COMMENT__ ----------------------- #

	#__ACDS_USER_COMMENT__ This is the reference clock used by the PLL to derive any other clock in the core
	if { [get_collection_size [get_clocks -nowarn $pins(ref_clk_in)]] > 0 } { remove_clock $pins(ref_clk_in) }
	if {[regexp {([0-9Ee\.]+)\s+MHz} $::GLOBAL_pll_ref_freq ref_clk_freq ref_clk_freq]} {
		set ref_clk_period [expr 1/ ($ref_clk_freq * 1e6) * 1e9]
	} elseif {[regexp {([0-9Ee\.]+)\s+kHz} $::GLOBAL_pll_ref_freq ref_clk_freq ref_clk_freq]} {
		set ref_clk_period [expr 1/ ($ref_clk_freq * 1e3) * 1e9]
	} elseif {[regexp {([0-9Ee\.]+)} $::GLOBAL_pll_ref_freq ref_clk_freq ref_clk_freq]} {
		set ref_clk_period [expr 1/ ($ref_clk_freq) * 1e9]
	}	
	set half_ref_clk_period [expr $ref_clk_period / 2.0]
	
	create_clock -period $ref_clk_period -waveform [ list 0 $half_ref_clk_period ] [get_ports $pins(ref_clk_in)] -name $pins(ref_clk_in)
	
	#__ACDS_USER_COMMENT__ ------------------------- #
	#__ACDS_USER_COMMENT__ -                       - #
	#__ACDS_USER_COMMENT__ --- OUTPUT PLL CLOCKS --- #
	#__ACDS_USER_COMMENT__ -                       - #
	#__ACDS_USER_COMMENT__ ------------------------- #
	
	for { set i 0 } { $i < $::GLOBAL_num_pll_clock } { incr i } {
		
		set iclk [lindex $pins(pll_out_clks) $i]
		 
		create_generated_clock -add \
			-source $pins(ref_clk_in) \
			-name pll_out_${inst}_$i \
			-multiply_by $::GLOBAL_pll_mult($i) \
			-divide_by $::GLOBAL_pll_div($i) \
			-phase $::GLOBAL_pll_phase($i) \
			-duty_cycle $::GLOBAL_pll_dutycycle($i) \
			$iclk
	}
}

