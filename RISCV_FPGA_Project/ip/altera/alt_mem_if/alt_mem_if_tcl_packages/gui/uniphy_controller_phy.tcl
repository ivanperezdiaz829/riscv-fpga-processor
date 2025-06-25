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


package provide alt_mem_if::gui::uniphy_controller_phy 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::util::hwtcl_utils

namespace eval ::alt_mem_if::gui::uniphy_controller_phy:: {

	namespace import ::alt_mem_if::util::messaging::*

}



proc ::alt_mem_if::gui::uniphy_controller_phy::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for uniphy_controller_phy"
	
	_create_derived_parameters
	
	_create_parameters
	
	return 1
}


proc ::alt_mem_if::gui::uniphy_controller_phy::validate_component {} {

	_derive_parameters

	_dprint 1 "Preparing to validate component for uniphy_controller_phy"
	
	set validation_pass 1

	return $validation_pass
}


proc ::alt_mem_if::gui::uniphy_controller_phy::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for uniphy_controller_phy"
	
	return 1
}


proc ::alt_mem_if::gui::uniphy_controller_phy::_init {} {

	
}


proc ::alt_mem_if::gui::uniphy_controller_phy::_derive_parameters {} {

	_dprint 1 "Preparing to derive parameters for uniphy_controller_phy"

	if {[get_parameter_value CSR_ADDR_WIDTH] != [get_parameter_property CSR_ADDR_WIDTH DEFAULT_VALUE]} {
		set_parameter_value CSR_ADDR_WIDTH [get_parameter_property CSR_ADDR_WIDTH DEFAULT_VALUE]
	}

}


proc ::alt_mem_if::gui::uniphy_controller_phy::_create_parameters {} {
	
	_dprint 1 "Preparing to create PHY parameters in uniphy_controller_phy"

	::alt_mem_if::util::hwtcl_utils::_add_parameter CSR_ADDR_WIDTH Integer 8
	set_parameter_property CSR_ADDR_WIDTH VISIBLE false
	set_parameter_property CSR_ADDR_WIDTH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CSR_DATA_WIDTH Integer 32
	set_parameter_property CSR_DATA_WIDTH VISIBLE false
	set_parameter_property CSR_DATA_WIDTH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CSR_BE_WIDTH Integer 4
	set_parameter_property CSR_BE_WIDTH VISIBLE false
	set_parameter_property CSR_BE_WIDTH DERIVED true
}


proc ::alt_mem_if::gui::uniphy_controller_phy::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in uniphy_controller_phy"

	::alt_mem_if::util::hwtcl_utils::_add_parameter EXPORT_CSR_PORT boolean false
	set_parameter_property EXPORT_CSR_PORT visible false
	set_parameter_property EXPORT_CSR_PORT derived true

}


::alt_mem_if::gui::uniphy_controller_phy::_init


