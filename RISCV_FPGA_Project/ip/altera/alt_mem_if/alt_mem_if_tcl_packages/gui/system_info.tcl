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


package provide alt_mem_if::gui::system_info 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::system_info:: {
	variable guis
	
	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::system_info::create_parameters {} {
	
	create_generic_parameters
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DISABLE_CHILD_MESSAGING boolean false
	set_parameter_property DISABLE_CHILD_MESSAGING VISIBLE FALSE


	::alt_mem_if::util::hwtcl_utils::_add_parameter HARD_PHY boolean false
	set_parameter_property HARD_PHY DERIVED true
	set_parameter_property HARD_PHY VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter HARD_EMIF boolean false
	set_parameter_property HARD_EMIF DISPLAY_NAME "Enable Hard External Memory Interface"
	set_parameter_property HARD_EMIF DESCRIPTION "When turned on, the Hard Memory Controller and Hard Memory  PHY will be used.
	This option is available for Arria V and Cyclone V."

	::alt_mem_if::util::hwtcl_utils::_add_parameter HHP_HPS boolean false
	set_parameter_property HHP_HPS VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter HHP_HPS_VERIFICATION boolean false
	set_parameter_property HHP_HPS_VERIFICATION VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter HHP_HPS_SIMULATION boolean false
	set_parameter_property HHP_HPS_SIMULATION VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter HPS_PROTOCOL String "DEFAULT"
	set_parameter_property HPS_PROTOCOL VISIBLE false
	set_parameter_property HPS_PROTOCOL DISPLAY_NAME "Memory Protocol"
	set_parameter_property HPS_PROTOCOL DESCRIPTION "Memory protocol."
	set_parameter_property HPS_PROTOCOL ALLOWED_RANGES {DEFAULT DDR2 DDR3 LPDDR2 LPDDR1 QDRII RLDRAMII RLDRAM3}

	::alt_mem_if::util::hwtcl_utils::_add_parameter CUT_NEW_FAMILY_TIMING boolean true
	set_parameter_property CUT_NEW_FAMILY_TIMING VISIBLE false

	return 1
}

proc ::alt_mem_if::gui::system_info::create_generic_parameters {} {
	
	_dprint 1 "Preparing to create parameters for system_info"

	::alt_mem_if::util::hwtcl_utils::_add_parameter SYS_INFO_DEVICE_FAMILY STRING "" 
	set_parameter_property SYS_INFO_DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
	set_parameter_property SYS_INFO_DEVICE_FAMILY VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PARSE_FRIENDLY_DEVICE_FAMILY STRING "" 
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY DERIVED true
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter DEVICE_FAMILY STRING "" 
	set_parameter_property DEVICE_FAMILY DERIVED true
	set_parameter_property DEVICE_FAMILY VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter PRE_V_SERIES_FAMILY BOOLEAN false
	set_parameter_property PRE_V_SERIES_FAMILY DERIVED true
	set_parameter_property PRE_V_SERIES_FAMILY VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID boolean false
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID DERIVED true
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter PARSE_FRIENDLY_DEVICE_FAMILY_PARAM_VALID boolean false
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY_PARAM_VALID VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter PARSE_FRIENDLY_DEVICE_FAMILY_PARAM STRING "" 
	set_parameter_property PARSE_FRIENDLY_DEVICE_FAMILY_PARAM VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter DEVICE_FAMILY_PARAM STRING "" 
	set_parameter_property DEVICE_FAMILY_PARAM VISIBLE FALSE

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter SPEED_GRADE String "7"
	} else {
		::alt_mem_if::util::hwtcl_utils::_add_parameter SPEED_GRADE String "2"
	}
	set_parameter_property SPEED_GRADE DISPLAY_NAME "Speed Grade"
	set_parameter_property SPEED_GRADE VISIBLE true
	set_parameter_property SPEED_GRADE DESCRIPTION "The speed grade of the targeted FPGA device affects the generated timing constraints and timing reporting."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter IS_ES_DEVICE BOOLEAN false
	set_parameter_property IS_ES_DEVICE DISPLAY_NAME "Engineering Sample (ES) Device"
	set_parameter_property IS_ES_DEVICE VISIBLE FALSE
	set_parameter_property IS_ES_DEVICE DESCRIPTION "Indicates whether the targeted FPGA device is an engineering sample (ES)."

	return 1
}

proc ::alt_mem_if::gui::system_info::create_gui {} {

	return 1
}



proc ::alt_mem_if::gui::system_info::validate_component {} {

	_validate_device_family_cache
	
	_derive_parameters
	
	set validation_pass 1

	return $validation_pass

}

proc ::alt_mem_if::gui::system_info::validate_generic_component {} {

	_validate_device_family_cache
	
	_derive_generic_parameters
	
	set validation_pass 1

	return $validation_pass

}

proc ::alt_mem_if::gui::system_info::elaborate_component {} {

	return 1
}

proc ::alt_mem_if::gui::system_info::get_device_family {} {

	set parse_friendly_device_family [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
	
	if { [regexp  {^[ ]*$} $parse_friendly_device_family match] == 1 || [string compare -nocase $parse_friendly_device_family "Unknown"] == 0 } {
		_error "Device family can not be determined"
	} else {
		return $parse_friendly_device_family
	}

}

proc ::alt_mem_if::gui::system_info::cache_sys_info_parameters {child_instance} {

	set_instance_parameter $child_instance PARSE_FRIENDLY_DEVICE_FAMILY_PARAM_VALID [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID]
	set_instance_parameter $child_instance PARSE_FRIENDLY_DEVICE_FAMILY_PARAM [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
	set_instance_parameter $child_instance DEVICE_FAMILY_PARAM [get_parameter_value DEVICE_FAMILY]


}

proc ::alt_mem_if::gui::system_info::_init {} {
	variable VALID_PROTOCOLS
}



proc ::alt_mem_if::gui::system_info::_derive_generic_parameters {} {

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID] "true"] == 0} {
		_dprint 1 "Using cache for PARSE_FRIENDLY_DEVICE_FAMILY"
	
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_PARAM_VALID] "true"] == 0} {
		_dprint 1 "Using parameter value for PARSE_FRIENDLY_DEVICE_FAMILY"

		set_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_PARAM]
		set_parameter_value DEVICE_FAMILY [get_parameter_value DEVICE_FAMILY_PARAM]
		set_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID true

	} else {
		_dprint 1 "Solving value for PARSE_FRIENDLY_DEVICE_FAMILY from SYS_INFO"

		set sys_info_device_family [get_parameter_value SYS_INFO_DEVICE_FAMILY]
		_dprint 1 "SYSTEM_INFO Family = $sys_info_device_family"
		
		if { [regexp  {^[ ]*$} $sys_info_device_family match] == 1 || [string compare -nocase $sys_info_device_family "Unknown"] == 0 } {
			set case_103224_fixed 0
      
			if {$case_103224_fixed} {
				_error "Device family can not be determined"
			} else {
				set sys_info_device_family "STRATIXV"
			}      
		} 

		set_parameter_value DEVICE_FAMILY $sys_info_device_family

		regsub -all {[ ]} $sys_info_device_family "" parse_device_family

		if {[string compare -nocase $parse_device_family "arriaii"] == 0} {
			set parse_device_family "arriaiigx"
		}

	
		set_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY [string toupper $parse_device_family]

		_dprint 1 "Using device family = [get_parameter_value DEVICE_FAMILY] ([get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY])"
		
		set_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID true

		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIII"] == 0 ||
	        [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIV"] == 0 ||
	        [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGX"] == 0 ||
	        [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGZ"] == 0 ||
	        [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "MAX10FPGA"] == 0} {
			set_parameter_value PRE_V_SERIES_FAMILY true
		} else {
			set_parameter_value PRE_V_SERIES_FAMILY false
		}

		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			set_parameter_property IS_ES_DEVICE VISIBLE false
		} else {
			set_parameter_property IS_ES_DEVICE VISIBLE false
		}

		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0} {
			set_parameter_property SPEED_GRADE ALLOWED_RANGES {1 2 3 4}
		} else {
			set_parameter_property SPEED_GRADE ALLOWED_RANGES {1 2 2X 3 4 4L 5 6 7 8}
		}
	}

	return 1
}

proc ::alt_mem_if::gui::system_info::_derive_parameters {} {

	_derive_generic_parameters

	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set_parameter_value HARD_PHY true
	} else {
                set_parameter_value HARD_PHY false
        }

	return 1
}

proc ::alt_mem_if::gui::system_info::_validate_device_family_cache {} {

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID] "true"] == 0} {
		set sys_info_device_family [get_parameter_value SYS_INFO_DEVICE_FAMILY]
		_dprint 1 "SYSTEM_INFO Family = $sys_info_device_family"
		
		if { [regexp  {^[ ]*$} $sys_info_device_family match] == 1 || [string compare -nocase $sys_info_device_family "Unknown"] == 0 } {
		} else {
			if {[string compare -nocase [get_parameter_value DEVICE_FAMILY] $sys_info_device_family] != 0} {
				_dprint 1 "Invalidating device cache due to change in device from $sys_info_device_family to [get_parameter_value DEVICE_FAMILY]"
				set_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY_CACHE_VALID false
			}
		}
	}
	
}


::alt_mem_if::gui::system_info::_init
