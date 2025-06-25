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


package provide alt_mem_if::gui::diagnostics 0.1

package require alt_mem_if::util::messaging


namespace eval ::alt_mem_if::gui::diagnostics:: {

	namespace import ::alt_mem_if::util::messaging::*

}



proc ::alt_mem_if::gui::diagnostics::create_parameters {} {

	_dprint 1 "Preparing to create parameters for diagnostics"
	
	_create_derived_parameters

	_create_diagnostics_parameters

	return 1	
}


proc ::alt_mem_if::gui::diagnostics::create_gui {} {

	_create_diagnostics_parameters_gui
	
	return 1
}


proc ::alt_mem_if::gui::diagnostics::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in diagnostics"

}


proc ::alt_mem_if::gui::diagnostics::_create_diagnostics_parameters {} {
	
	_dprint 1 "Preparing to create parameters in diagnostics"
	
	_dprint 1 "Preparing to create parameters in altera_core_em_pc"

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_EXPORT_SEQ_DEBUG_BRIDGE boolean false
	set_parameter_property ENABLE_EXPORT_SEQ_DEBUG_BRIDGE DISPLAY_NAME "Enable EMIF On-Chip Debug Toolkit"
	set_parameter_property ENABLE_EXPORT_SEQ_DEBUG_BRIDGE DESCRIPTION "Enables access to sequencer debug functions via JTAG/Avalon-MM interface"
	set_parameter_property ENABLE_EXPORT_SEQ_DEBUG_BRIDGE ENABLED true
	set_parameter_property ENABLE_EXPORT_SEQ_DEBUG_BRIDGE VISIBLE true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter CORE_DEBUG_CONNECTION STRING "EXPORT"
	set_parameter_property CORE_DEBUG_CONNECTION ALLOWED_RANGES {"INTERNAL_JTAG:Internal (JTAG)"  "EXPORT:Avalon-MM Slave"  "SHARED:Shared"}
	set_parameter_property CORE_DEBUG_CONNECTION DISPLAY_NAME "EMIF On-Chip Debug Toolkit interface type"
	set_parameter_property CORE_DEBUG_CONNECTION DESCRIPTION "Specifies the type of interface used for accessing calibration debug data."
	set_parameter_property CORE_DEBUG_CONNECTION ENABLED true
	set_parameter_property CORE_DEBUG_CONNECTION VISIBLE true

	::alt_mem_if::util::hwtcl_utils::_add_parameter ADD_EXTERNAL_SEQ_DEBUG_NIOS boolean false
	set_parameter_property ADD_EXTERNAL_SEQ_DEBUG_NIOS DISPLAY_NAME "Add external Nios to connect to sequencer debug interface"
	set_parameter_property ADD_EXTERNAL_SEQ_DEBUG_NIOS DESCRIPTION "Add external Nios to connect to sequencer debug interface"
	set_parameter_property ADD_EXTERNAL_SEQ_DEBUG_NIOS ENABLED true
	set_parameter_property ADD_EXTERNAL_SEQ_DEBUG_NIOS VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ED_EXPORT_SEQ_DEBUG boolean false
	set_parameter_property ED_EXPORT_SEQ_DEBUG DISPLAY_NAME "Export sequencer debug interface from example design"
	set_parameter_property ED_EXPORT_SEQ_DEBUG DESCRIPTION "Export sequencer debug interface from example design"
	set_parameter_property ED_EXPORT_SEQ_DEBUG ENABLED true
	set_parameter_property ED_EXPORT_SEQ_DEBUG VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ADD_EFFICIENCY_MONITOR boolean false
	set_parameter_property ADD_EFFICIENCY_MONITOR DISPLAY_NAME "Enable the Efficiency Monitor and Protocol Checker on the Controller Avalon Interface"
	set_parameter_property ADD_EFFICIENCY_MONITOR DESCRIPTION "Enable efficiency measurements to be performed on the controller avalon interface"

	set_parameter_property ADD_EFFICIENCY_MONITOR VISIBLE false
}


proc ::alt_mem_if::gui::diagnostics::_create_diagnostics_parameters_gui {} {

	_dprint 1 "Preparing to create GUI in diagnostics"
	
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property ADD_EFFICIENCY_MONITOR VISIBLE false
	} else {
		set_parameter_property ADD_EFFICIENCY_MONITOR VISIBLE true
	add_display_item "Diagnostics" "Efficiency Monitor and Protocol Checker Settings" GROUP
        add_display_item "Efficiency Monitor and Protocol Checker Settings" bs11 TEXT "<html>The Efficiency Monitor and Protocol Checker is used to measure efficiency on the Avalon interface between<br> the Traffic Generator and the Controller.  It will also perform protocol checking on the bus.<br>"
	add_display_item "Efficiency Monitor and Protocol Checker Settings" ADD_EFFICIENCY_MONITOR PARAMETER
	}
}


proc ::alt_mem_if::gui::diagnostics::validate_component {enable_ctrl_avalon_interface} {
	_dprint 1 "Preparing to run validate_component in diagnostics"

        set validation_pass 1

	if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "TRUE"] == 0} {
		if {[string compare -nocase $enable_ctrl_avalon_interface "TRUE"] == 0} {
			set validation_pass 1
		} else {
			set validation_pass 0
			_error "The ENABLE_CTRL_AVALON_INTERFACE setting must be checked for the Efficiency Monitor and Protocol Checker to function."
		}
	}
	
	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value USER_DEBUG_LEVEL] "0"] == 0} {
			set validation_pass 0
			_error "Core sequencer debug access is not available at USER_DEBUG_LEVEL 0."
		}

	}

	return $validation_pass
}

