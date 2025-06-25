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


package provide alt_mem_if::gui::uniphy_debug 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array

namespace eval ::alt_mem_if::gui::uniphy_debug:: {
	variable USER_DEBUG_TEXT

	variable LEGAL_DEBUG_LEVELS [list 0 1 2 3 4]
	variable DEBUG_PARAM_LEVELS
	variable KNOWN_DEBUG_PARAMS

	namespace import ::alt_mem_if::util::messaging::*

}



proc ::alt_mem_if::gui::uniphy_debug::create_debug_parameters {} {
	
	variable USER_DEBUG_TEXT

	_dprint 1 "Preparing to create PHY debug parameters in common_ddrx_phy"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USER_DEBUG_LEVEL STRING "1"
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_internal_debug]} {
		set_parameter_property USER_DEBUG_LEVEL ALLOWED_RANGES {"0:No Debugging"  "1:Option 1"  "2:Option 2"  "3:Option 3"  "4:Option 4"}
	} else {
		set_parameter_property USER_DEBUG_LEVEL ALLOWED_RANGES {"0:No Debugging"  "1:Option 1"}
	}
	set_parameter_property USER_DEBUG_LEVEL DISPLAY_NAME "Debugging feature set"
	set_parameter_property USER_DEBUG_LEVEL DESCRIPTION "Specifies the debugging feature set of the memory interface."

	set USER_DEBUG_TEXT "<html>
		<table border=\"1\" width=\"100%\">
			<tr bgcolor=\"#C9DBF3\">
				<th>Feature Set</th>
				<th>Included Debugging Features</th>
				<th>Additional<BR>Utilization</th>
			</tr>
			<tr bgcolor=\"#FFFFFF\">
				<td><B>No Debugging</B></td>
				<td>None</td>
				<td>None</td>
			</tr>
			<tr bgcolor=\"#E8E8E8\">
				<td><B>Option 1<B></td>
				<td>Connectivity to the EMIF toolkit allowing you to display information about your interface and generate reports.</td>
				<td>+600 Registers<BR>+700 ALUTs<BR>+8 M9Ks</td>
			</tr>
	"
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_internal_debug]} {
		append USER_DEBUG_TEXT "
			<tr bgcolor=\"#FFFFFF\">
				<td><B>Option 2</B></td>
				<td>
					Connectivity to the EMIF toolkit allowing you to display information about your interface and generate reports.<BR>
					Calibration messages log to provide more information about calibration.
				</td>
				<td>+600 Registers<BR>+700 ALUTs<BR>+20 M9Ks</td>
			</tr>
			<tr bgcolor=\"#E8E8E8\">
				<td><B>Option 3</B></td>
				<td>
					Connectivity to the EMIF toolkit allowing you to display information about your interface and generate reports.<BR>
					Calibration messages log to provide more information about calibration.
				</td>
				<td>+600 Registers<BR>+700 ALUTs<BR>+20 M9Ks</td>
			</tr>
			<tr bgcolor=\"#FFFFFF\">
				<td><B>Option 4<BR>(Internal Only)</B></td>
				<td>
					Connectivity to the EMIF toolkit allowing you to display information about your interface and generate reports.<BR>
					Deployment of sequencer software files.<BR>
					Nios IIe development environment to debug calibraion software.<BR>
					Large Nios IIe memory to allow software compilation without optimizations.
				</td>
				<td>+800 Registers<BR>+1000 ALUTs<BR>+24 M9Ks</td>
			</tr>
		"
	}
	append USER_DEBUG_TEXT "
		</table>
	</html>
	"

}

proc ::alt_mem_if::gui::uniphy_debug::add_debug_display_items {display_group} {
	variable USER_DEBUG_TEXT


	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property USER_DEBUG_LEVEL Visible false
		set_parameter_property ENABLE_EXPORT_SEQ_DEBUG_BRIDGE Visible false
		set_parameter_property CORE_DEBUG_CONNECTION Visible false
		return
	}

	add_display_item $display_group USER_DEBUG_LEVEL PARAMETER
    add_display_item $display_group "text_debug_1" text $USER_DEBUG_TEXT

	add_display_item $display_group ENABLE_EXPORT_SEQ_DEBUG_BRIDGE PARAMETER
	add_display_item $display_group CORE_DEBUG_CONNECTION PARAMETER
}


proc ::alt_mem_if::gui::uniphy_debug::register_debug_parameter {param_name levels} {
	variable DEBUG_PARAM_LEVELS
	variable KNOWN_DEBUG_PARAMS
	variable LEGAL_DEBUG_LEVELS

	_dprint 1 "Preparing to register parameter $param_name for levels $levels"
	
	
	foreach level $levels {
		if {[lsearch -exact $LEGAL_DEBUG_LEVELS $level] == -1} {
			_error "Illegal input debug level $level for parameter $param_name"
		}
	}

	set KNOWN_DEBUG_PARAMS($param_name) 1

	foreach level $LEGAL_DEBUG_LEVELS {
		if {[lsearch -exact $levels $level] != -1} {
			_dprint 1 "Registering $param_name enabled for debug level $level"
			lappend DEBUG_PARAM_LEVELS($level) $param_name
		} else {
			_dprint 1 "Registering $param_name as disabled for debug level $level"
		}
	}

}


proc ::alt_mem_if::gui::uniphy_debug::derive_debug_parameters {} {
	variable DEBUG_PARAM_LEVELS
	variable KNOWN_DEBUG_PARAMS
	
	set cur_debug_level [get_parameter_value USER_DEBUG_LEVEL]
	
	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
	
		set_parameter_property USER_DEBUG_LEVEL ENABLED true
	
		foreach param_name [array names KNOWN_DEBUG_PARAMS] {
			if {[lsearch -exact [::alt_mem_if::util::list_array::safe_array_val DEBUG_PARAM_LEVELS $cur_debug_level] $param_name] != -1} {
				_dprint 1 "Enabling parameter $param_name as it is registered for debug level $cur_debug_level"
				set_parameter_value $param_name true
			} else {
				set_parameter_value $param_name false
			}
		}
	} else {
		set_parameter_property USER_DEBUG_LEVEL ENABLED false

		foreach param_name [array names KNOWN_DEBUG_PARAMS] {
			set_parameter_value $param_name false
		}
	}
}


proc ::alt_mem_if::gui::uniphy_debug::_init {} {
	variable USER_DEBUG_TEXT
	variable DEBUG_PARAM_LEVELS
	variable KNOWN_DEBUG_PARAMS
	variable LEGAL_DEBUG_LEVELS

	set USER_DEBUG_TEXT ""

	::alt_mem_if::util::list_array::array_clean DEBUG_PARAM_LEVELS
	foreach level $LEGAL_DEBUG_LEVELS {
		set DEBUG_PARAM_LEVELS($level) [list]
	}

	::alt_mem_if::util::list_array::array_clean KNOWN_DEBUG_PARAMS
	
	

}


::alt_mem_if::gui::uniphy_debug::_init


