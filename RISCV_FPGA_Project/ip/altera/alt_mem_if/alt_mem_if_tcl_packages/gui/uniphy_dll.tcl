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


package provide alt_mem_if::gui::uniphy_dll 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils

namespace eval ::alt_mem_if::gui::uniphy_dll:: {

	namespace import ::alt_mem_if::util::messaging::*

}



proc ::alt_mem_if::gui::uniphy_dll::create_parameters { {force_all_non_derived 0} } {
	
	_dprint 1 "Preparing to create parameters for uniphy_dll"



	set derived "true"
	if {$force_all_non_derived} {
		set derived "false"
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_DELAY_CTRL_WIDTH INTEGER 6
	set_parameter_property DLL_DELAY_CTRL_WIDTH DERIVED $derived
	set_parameter_property DLL_DELAY_CTRL_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_OFFSET_CTRL_WIDTH INTEGER 6
	set_parameter_property DLL_OFFSET_CTRL_WIDTH VISIBLE false
	set_parameter_property DLL_OFFSET_CTRL_WIDTH DERIVED $derived
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DELAY_BUFFER_MODE STRING "HIGH"
	set_parameter_property DELAY_BUFFER_MODE VISIBLE false
	set_parameter_property DELAY_BUFFER_MODE DERIVED $derived

	::alt_mem_if::util::hwtcl_utils::_add_parameter DELAY_CHAIN_LENGTH INTEGER 8
	set_parameter_property DELAY_CHAIN_LENGTH VISIBLE false
	set_parameter_property DELAY_CHAIN_LENGTH DERIVED $derived

	::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_SHARING_MODE STRING "None"
	set_parameter_property DLL_SHARING_MODE DISPLAY_NAME "DLL sharing mode"
	set_parameter_property DLL_SHARING_MODE DESCRIPTION "When set to \"No sharing\", a DLL block is instantiated but no DLL signals are exported.<br>When set to \"Master\", a DLL block is instantiated and the signals are exported.<br>When set to \"Slave\", a DLL interface is exposed and an external DLL Master must be connected to drive them."
	set_parameter_property DLL_SHARING_MODE ALLOWED_RANGES {"None:No sharing" "Master:Master" "Slave:Slave"}
	set_parameter_property DLL_SHARING_MODE AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_DLL_SHARING_INTERFACES INTEGER 1
	set_parameter_property NUM_DLL_SHARING_INTERFACES DISPLAY_NAME "Number of DLL sharing interfaces"
	set_parameter_property NUM_DLL_SHARING_INTERFACES DESCRIPTION "When set to \"No sharing\", a DLL block is instantiated but no DLL signals are exported.<br>When set to \"Master\", a DLL block is instantiated and the signals are exported.<br>When set to \"Slave\", a DLL interface is exposed and an external DLL Master must be connected to drive them."
	set_parameter_property NUM_DLL_SHARING_INTERFACES ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10}
	set_parameter_property NUM_DLL_SHARING_INTERFACES AFFECTS_ELABORATION true

	return 1
}


proc ::alt_mem_if::gui::uniphy_dll::validate_component { {skip_derivation 0} } {

	if {$skip_derivation == 0} {
		_derive_parameters
	}

	_dprint 1 "Preparing to validate component for uniphy_dll"
	
	set validation_pass 1

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixiii"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixiv"] == 0 } {
		set_parameter_property HCX_COMPAT_MODE ENABLED TRUE
	} else {
		set_parameter_property HCX_COMPAT_MODE ENABLED FALSE
	}

	if {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "master"] == 0} {
		set_parameter_property NUM_DLL_SHARING_INTERFACES VISIBLE true
		set_parameter_property NUM_DLL_SHARING_INTERFACES ENABLED true
	} else {
		set_parameter_property NUM_DLL_SHARING_INTERFACES VISIBLE false
		set_parameter_property NUM_DLL_SHARING_INTERFACES ENABLED false
	}

	if {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] == 0} {
		_wprint "DLL slave mode selected, DLL inputs must be connected to a Master Memory Controller or user generated DLL"
	}

	return $validation_pass
}


proc ::alt_mem_if::gui::uniphy_dll::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for uniphy_dll"
	
	return 1
}


proc ::alt_mem_if::gui::uniphy_dll::_init {} {

	
}


proc ::alt_mem_if::gui::uniphy_dll::_derive_parameters {} {
	
	_dprint 1 "Preparing to derive the DLL parameters in uniphy_dll for [get_module_property NAME]"

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixv"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriavgz"] == 0} {
		set_parameter_value DLL_DELAY_CTRL_WIDTH 7
	} else {
		set_parameter_value DLL_DELAY_CTRL_WIDTH 6
	}

}


::alt_mem_if::gui::uniphy_dll::_init


