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


package provide alt_mem_if::gui::common_rldram_controller_phy 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::common_rldram_controller_phy:: {
	variable VALID_RLDRAM_MODES
	variable rldram_mode

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::common_rldram_controller_phy::_validate_rldram_mode {} {
	variable rldram_mode
		
	if {$rldram_mode == -1} {
		error "RLDRAM mode in [namespace current] in uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::common_rldram_controller_phy::set_rldram_mode {in_rldram_mode} {
	variable VALID_RLDRAM_MODES
	
	if {[info exists VALID_RLDRAM_MODES($in_rldram_mode)] == 0} {
		_eprint "Fatal Error: Illegal RLDRAM mode $in_rldram_mode"
		_eprint "Fatal Error: Valid RLDRAM modes are [array names VALID_RLDRAM_MODES]"
		_error "An error occurred"
	} else {
		_dprint 1 "Setting RLDRAM Mode as $in_rldram_mode"
		variable rldram_mode
		set rldram_mode $in_rldram_mode
	}

	return 1
}

proc ::alt_mem_if::gui::common_rldram_controller_phy::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for common_rldram_controller_phy"
	
	_create_derived_parameters	
	
	return 1
}


proc ::alt_mem_if::gui::common_rldram_controller_phy::validate_component {} {

	_validate_rldram_mode

	_derive_parameters 
	
	return 1

}


proc ::alt_mem_if::gui::common_rldram_controller_phy::_init {} {
	
	variable VALID_RLDRAM_MODES
	
	::alt_mem_if::util::list_array::array_clean VALID_RLDRAM_MODES
	set VALID_RLDRAM_MODES(RLDRAMII) 1
	set VALID_RLDRAM_MODES(RLDRAM3) 1

	variable rldram_mode -1
	
}

proc ::alt_mem_if::gui::common_rldram_controller_phy::_create_derived_parameters {} {

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR integer 0
	set_parameter_property MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR DERIVED TRUE
	set_parameter_property MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD integer 0
	set_parameter_property MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD DERIVED TRUE
	set_parameter_property MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD VISIBLE false

	return 1	
}


proc ::alt_mem_if::gui::common_rldram_controller_phy::_derive_parameters {} {

	if { [get_parameter_value MEM_CLK_FREQ] <= 267 } {
		set_parameter_value MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR 2
	} else {
		set_parameter_value MEM_BUS_TURNAROUND_CYCLES_RD_TO_WR 3
	}
	
	if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		set_parameter_value MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD 1
	} else {
		set_parameter_value MEM_BUS_TURNAROUND_CYCLES_WR_TO_RD 0
	}
	return 1
}


::alt_mem_if::gui::common_rldram_controller_phy::_init
