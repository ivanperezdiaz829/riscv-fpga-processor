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


package provide alt_mem_if::gui::factory 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::list_array

package require alt_mem_if::gui::common_rldram_mem_model
package require alt_mem_if::gui::qdrii_mem_model
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::avalon_mm_traffic_gen
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::qdrii_controller
package require alt_mem_if::gui::uniphy_phy
package require alt_mem_if::gui::qdrii_phy
package require alt_mem_if::gui::common_rldram_phy
package require alt_mem_if::gui::common_rldram_controller
package require alt_mem_if::gui::common_rldram_controller_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info

namespace eval ::alt_mem_if::gui::factory {
	
	variable VALID_GUIS
	
	variable CREATED_GUIS

	namespace import ::alt_mem_if::util::messaging::*
	namespace import ::alt_mem_if::util::list_array::*

}


proc ::alt_mem_if::gui::factory::gui_types {} {
	variable VALID_GUIS
	
	return [array names VALID_GUIS]
}

proc ::alt_mem_if::gui::factory::_validate_gui_type {gui_type} {
	variable VALID_GUIS
	
	if {[info exists VALID_GUIS($gui_type)] == 0} {
		error "Unknown GUI type $gui_type. Valid types are [gui_types]"
		return 0
	} else {
		return 1
	}
}

proc ::alt_mem_if::gui::factory::create_gui {gui_type} {
	variable CREATED_GUIS

	_validate_gui_type $gui_type


	set parent_namespace "::alt_mem_if::gui::${gui_type}"
	set handle_namespace "::alt_mem_if::gui::${gui_type}1"

	if {[info exists CREATED_GUIS($gui_type)] == 1} {
		_dprint 1 "A namespace for a GUI of type $gui_type already exists as $CREATED_GUIS($gui_type)"
		return $CREATED_GUIS($gui_type)
	} else {
		_dprint 1 "Creating GUI namespace $handle_namespace for GUI type $gui_type"
		namespace eval $handle_namespace "
			namespace import ::alt_mem_if::util::messaging::*
	
		"
		${parent_namespace}::_create_namespace $handle_namespace
		
		set CREATED_GUIS($gui_type) $handle_namespace
			
		return $handle_namespace
	}
}


proc ::alt_mem_if::gui::factory::_init {} {
	variable VALID_GUIS
	variable CREATED_GUIS
	
	::alt_mem_if::util::list_array::array_clean VALID_GUIS
	::alt_mem_if::util::list_array::array_clean CREATED_GUIS
	
	set VALID_GUIS(common_rldram_mem_model) 1
	set VALID_GUIS(qdrii_mem_model) 1
	set VALID_GUIS(common_ddr_mem_model) 1
	set VALID_GUIS(avalon_mm_traffic_gen) 1
	set VALID_GUIS(ddrx_controller) 1
	set VALID_GUIS(qdrii_controller) 1
	set VALID_GUIS(uniphy_phy) 1
	set VALID_GUIS(qdrii_phy) 1
	set VALID_GUIS(common_rldram_phy) 1
	set VALID_GUIS(common_rldram_controller) 1
	set VALID_GUIS(common_rldram_controller_phy) 1
	set VALID_GUIS(afi) 1
	set VALID_GUIS(system_info) 1
}

::alt_mem_if::gui::factory::_init
