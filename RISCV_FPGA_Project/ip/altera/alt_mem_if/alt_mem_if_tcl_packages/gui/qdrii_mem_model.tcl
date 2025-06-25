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


package provide alt_mem_if::gui::qdrii_mem_model 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils

namespace eval ::alt_mem_if::gui::qdrii_mem_model:: {
	variable MSG

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::qdrii_mem_model::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for qdrii_mem_model"
	
	_create_derived_parameters

	_create_memory_parameters_parameters
	
	_create_memory_timing_parameters
	
		
	return 1
}


proc ::alt_mem_if::gui::qdrii_mem_model::create_gui {} {

	_create_memory_parameters_gui
	
	_create_memory_timing_gui
	
	return 1
}


proc ::alt_mem_if::gui::qdrii_mem_model::validate_component {} {

	_derive_parameters

	_dprint 1 "Preparing to validate component for qdrii_mem_model"

	set validation_pass 1
	
	if {[get_parameter_value MEM_BURST_LENGTH] == 2 && [get_parameter_value MEM_T_WL] != 0} {
		_eprint "When burst length is 2, write latency must be 0"
		set validation_pass 0
	}
	
	if {[get_parameter_value MEM_BURST_LENGTH] == 4 && [get_parameter_value MEM_T_WL] != 1} {
		_eprint "When burst length is 4, write latency must be 1"
		set validation_pass 0
	}
	
	set expected_dm_width [expr {[get_parameter_value MEM_DQ_WIDTH] / 9}]
	if {[get_parameter_value MEM_DM_WIDTH] != $expected_dm_width} {
		_eprint "When data width is [get_parameter_value MEM_DQ_WIDTH], data mask width must be $expected_dm_width"
		set validation_pass 0
	}
	
	return $validation_pass

}

proc ::alt_mem_if::gui::qdrii_mem_model::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for qdrii_mem_model"
	
	return 1
}


proc ::alt_mem_if::gui::qdrii_mem_model::_init {} {
	variable MSG
	
	::alt_mem_if::util::list_array::array_clean MSG
	
	
}

proc ::alt_mem_if::gui::qdrii_mem_model::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in qdrii_mem_model"

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_WRITE_DQS_WIDTH INTEGER 0
	set_parameter_property MEM_IF_WRITE_DQS_WIDTH DERIVED true
	set_parameter_property MEM_IF_WRITE_DQS_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_WRITE_GROUPS INTEGER 0
	set_parameter_property MEM_IF_WRITE_GROUPS DERIVED true
	set_parameter_property MEM_IF_WRITE_GROUPS VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DM_WIDTH INTEGER 0
	set_parameter_property MEM_IF_DM_WIDTH DERIVED true
	set_parameter_property MEM_IF_DM_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DQ_WIDTH INTEGER 0
	set_parameter_property MEM_IF_DQ_WIDTH DERIVED true
	set_parameter_property MEM_IF_DQ_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_READ_DQS_WIDTH INTEGER 0
	set_parameter_property MEM_IF_READ_DQS_WIDTH DERIVED true
	set_parameter_property MEM_IF_READ_DQS_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter SCC_DATA_WIDTH integer 1
	set_parameter_property SCC_DATA_WIDTH VISIBLE FALSE
	set_parameter_property SCC_DATA_WIDTH DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_ADDR_WIDTH INTEGER 0
	set_parameter_property MEM_IF_ADDR_WIDTH DERIVED true
	set_parameter_property MEM_IF_ADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CONTROL_WIDTH INTEGER 0
	set_parameter_property MEM_IF_CONTROL_WIDTH DERIVED true
	set_parameter_property MEM_IF_CONTROL_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CS_WIDTH INTEGER 0
	set_parameter_property MEM_IF_CS_WIDTH DERIVED true
	set_parameter_property MEM_IF_CS_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CLK_PAIR_COUNT INTEGER 1
	set_parameter_property MEM_IF_CLK_PAIR_COUNT DERIVED true
	set_parameter_property MEM_IF_CLK_PAIR_COUNT VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter NO_COMPLIMENTARY_STROBE BOOLEAN false
	set_parameter_property NO_COMPLIMENTARY_STROBE DERIVED true
	set_parameter_property NO_COMPLIMENTARY_STROBE VISIBLE false
}

proc ::alt_mem_if::gui::qdrii_mem_model::_create_memory_timing_parameters {} {
	
	_dprint 1 "Preparing to create memory timing parameters in qdrii_mem_model"

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_WL integer 1
	set_parameter_property MEM_T_WL DESCRIPTION "Write latency"
	set_parameter_property MEM_T_WL DISPLAY_NAME "tWL (cycles)"
	set_parameter_property MEM_T_WL ALLOWED_RANGES {0 1}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_RL float 2.5
	set_parameter_property MEM_T_RL DESCRIPTION "Read latency"
	set_parameter_property MEM_T_RL DISPLAY_NAME "tRL (cycles)"
	set_parameter_property MEM_T_RL ALLOWED_RANGES {1.5 2 2.5}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TKH integer 400
	set_parameter_property TIMING_TKH VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TSA integer 400
	set_parameter_property TIMING_TSA DESCRIPTION "Address and control setup to K clock rise"
	set_parameter_property TIMING_TSA DISPLAY_NAME "tSA"
	set_parameter_property TIMING_TSA UNITS picoseconds
	set_parameter_property TIMING_TSA ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_THA integer 400
	set_parameter_property TIMING_THA DESCRIPTION "Address and control hold after K clock rise"
	set_parameter_property TIMING_THA DISPLAY_NAME "tHA"
	set_parameter_property TIMING_THA UNITS picoseconds
	set_parameter_property TIMING_THA ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TSD integer 280
	set_parameter_property TIMING_TSD DESCRIPTION "Data setup to clock (K/K#) rise"
	set_parameter_property TIMING_TSD DISPLAY_NAME "tSD"
	set_parameter_property TIMING_TSD UNITS picoseconds
	set_parameter_property TIMING_TSD ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_THD integer 280
	set_parameter_property TIMING_THD DESCRIPTION "Data hold after clock (K/K#) rise"
	set_parameter_property TIMING_THD DISPLAY_NAME "tHD"
	set_parameter_property TIMING_THD UNITS picoseconds
	set_parameter_property TIMING_THD ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCQD integer 200
	set_parameter_property TIMING_TCQD DESCRIPTION "Echo clock high to data valid"
	set_parameter_property TIMING_TCQD DISPLAY_NAME "tCQD"
	set_parameter_property TIMING_TCQD UNITS picoseconds
	set_parameter_property TIMING_TCQD ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCQDOH integer -200
	set_parameter_property TIMING_TCQDOH DESCRIPTION "Echo clock high to data invalid"
	set_parameter_property TIMING_TCQDOH DISPLAY_NAME "tCQDOH"
	set_parameter_property TIMING_TCQDOH UNITS picoseconds
	set_parameter_property TIMING_TCQDOH ALLOWED_RANGES {-5000:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_QDR_INTERNAL_JITTER integer 250
	set_parameter_property TIMING_QDR_INTERNAL_JITTER DESCRIPTION "QDRII/II+ internal jitter"
	set_parameter_property TIMING_QDR_INTERNAL_JITTER DISPLAY_NAME "Internal jitter"
	set_parameter_property TIMING_QDR_INTERNAL_JITTER UNITS picoseconds
	set_parameter_property TIMING_QDR_INTERNAL_JITTER ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCQHCQnH integer 1000
	set_parameter_property TIMING_TCQHCQnH DESCRIPTION "CQ Clock Rise to CQn Clock Rise (rising edge to rising edge)"
	set_parameter_property TIMING_TCQHCQnH DISPLAY_NAME "TCQHCQnH"
	set_parameter_property TIMING_TCQHCQnH UNITS picoseconds
	set_parameter_property TIMING_TCQHCQnH ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TKHKnH integer 1000
	set_parameter_property TIMING_TKHKnH DESCRIPTION "K Clock Rise to Kn Clock Rise (rising edge to rising edge)"
	set_parameter_property TIMING_TKHKnH DISPLAY_NAME "TKHKnH"
	set_parameter_property TIMING_TKHKnH UNITS picoseconds
	set_parameter_property TIMING_TKHKnH ALLOWED_RANGES {0:5000}

	return 1
}

proc ::alt_mem_if::gui::qdrii_mem_model::_create_memory_parameters_parameters {} {
	
	_dprint 1 "Preparing to create memory parameters parameters in qdrii_mem_model"

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ADDR_WIDTH integer 20
	set_parameter_property MEM_ADDR_WIDTH DISPLAY_NAME "Address width"
	set_parameter_property MEM_ADDR_WIDTH DESCRIPTION "Width of the address bus on the memory device."
	set_parameter_property MEM_ADDR_WIDTH ALLOWED_RANGES {15:25}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DQ_WIDTH integer 9
	set_parameter_property MEM_DQ_WIDTH DISPLAY_NAME "Data width"
	set_parameter_property MEM_DQ_WIDTH DESCRIPTION "Width of the data bus on the memory device." 
	set_parameter_property MEM_DQ_WIDTH ALLOWED_RANGES {9 18 36}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CS_WIDTH integer 1
	set_parameter_property MEM_CS_WIDTH DISPLAY_NAME "Chip-select width"
	set_parameter_property MEM_CS_WIDTH DESCRIPTION "Width of the chip select bus on the memory device." 
	set_parameter_property MEM_CS_WIDTH ALLOWED_RANGES {1}
	set_parameter_property MEM_CS_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DM_WIDTH integer 1
	set_parameter_property MEM_DM_WIDTH DISPLAY_NAME "Data-mask width"
	set_parameter_property MEM_DM_WIDTH DESCRIPTION "Width of the data-mask bus on the memory device." 
	set_parameter_property MEM_DM_WIDTH ALLOWED_RANGES {1 2 4}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CONTROL_WIDTH integer 1
	set_parameter_property MEM_CONTROL_WIDTH DISPLAY_NAME "Control width"
	set_parameter_property MEM_CONTROL_WIDTH VISIBLE FALSE
	set_parameter_property MEM_CONTROL_WIDTH DESCRIPTION "Width of the control bus on the memory device." 
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_READ_DQS_WIDTH integer 1
	set_parameter_property MEM_READ_DQS_WIDTH DISPLAY_NAME "CQ width"
	set_parameter_property MEM_READ_DQS_WIDTH DESCRIPTION "Width of the CQ (read strobe) bus on the memory device." 
	set_parameter_property MEM_READ_DQS_WIDTH ALLOWED_RANGES {1}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_WRITE_DQS_WIDTH integer 1
	set_parameter_property MEM_WRITE_DQS_WIDTH DISPLAY_NAME "K width"
	set_parameter_property MEM_WRITE_DQS_WIDTH DESCRIPTION "Width of the K (write strobe) bus on the memory device." 
	set_parameter_property MEM_WRITE_DQS_WIDTH ALLOWED_RANGES {1}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BURST_LENGTH integer 4
	set_parameter_property MEM_BURST_LENGTH DISPLAY_NAME "Burst length"
	set_parameter_property MEM_BURST_LENGTH DESCRIPTION "Burst length supported by memory device." 
	set_parameter_property MEM_BURST_LENGTH ALLOWED_RANGES {2 4}

	::alt_mem_if::util::hwtcl_utils::_add_parameter EMULATED_MODE boolean false
	set_parameter_property EMULATED_MODE DISPLAY_NAME "x36 emulated mode"
	set_parameter_property EMULATED_MODE DESCRIPTION "When turned on a larger memory width interface is emulated using multiple smaller memory width interfaces (on the FPGA).  For example, if Emulated Write Groups is set to 2 and the Memory Data Width is set to 36, 2 groups of 18 are created to form the 36 bit wide interface." 
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter EMULATED_WRITE_GROUPS integer 2
	set_parameter_property EMULATED_WRITE_GROUPS DISPLAY_NAME "Emulated write groups"
	set_parameter_property EMULATED_WRITE_GROUPS DESCRIPTION "Number of write groups to use to form the x36 memory interface on the FPGA.  In x36 emulated mode there are always 2 x18 read groups.  The number of write groups can be set to 2 x18 groups or 4 x9 groups. "
	set_parameter_property EMULATED_WRITE_GROUPS ALLOWED_RANGES {2 4}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DERIVED_EMULATED_MODE boolean false
	set_parameter_property DERIVED_EMULATED_MODE DERIVED TRUE
	set_parameter_property DERIVED_EMULATED_MODE VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_EMULATED_READ_GROUPS integer 1
	set_parameter_property MEM_EMULATED_READ_GROUPS DERIVED TRUE
	set_parameter_property MEM_EMULATED_READ_GROUPS VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_EMULATED_WRITE_GROUPS integer 1
	set_parameter_property MEM_EMULATED_WRITE_GROUPS DERIVED TRUE
	set_parameter_property MEM_EMULATED_WRITE_GROUPS VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DEVICE_WIDTH integer 1
	set_parameter_property DEVICE_WIDTH DISPLAY_NAME "Device width"
	set_parameter_property DEVICE_WIDTH DESCRIPTION "Defines the number of devices used for width expansion."
	set_parameter_property DEVICE_WIDTH ALLOWED_RANGES {1 2}
	set_parameter_property DEVICE_WIDTH VISIBLE true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DEVICE_DEPTH integer 1
	set_parameter_property DEVICE_DEPTH DISPLAY_NAME "Device depth"
	set_parameter_property DEVICE_DEPTH DESCRIPTION "Defines the number of devices (ranks) used for depth expansion (Depth expansion is currently not supported)."
	set_parameter_property DEVICE_DEPTH ALLOWED_RANGES {1}
	set_parameter_property DEVICE_DEPTH VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_USE_DENALI_MODEL boolean false
	set_parameter_property MEM_USE_DENALI_MODEL VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter QDRII_PLUS_MODE boolean false
	set_parameter_property QDRII_PLUS_MODE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DENALI_SOMA_FILE string "qdrii.soma"
	set_parameter_property MEM_DENALI_SOMA_FILE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_BOARD_BASE_DELAY INTEGER 10
	set_parameter_property MEM_IF_BOARD_BASE_DELAY DISPLAY_NAME "Base board delay for board delay model"
	set_parameter_property MEM_IF_BOARD_BASE_DELAY DESCRIPTION "Base delay is required to allow create smaller windows of valid data"
	set_parameter_property MEM_IF_BOARD_BASE_DELAY VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_SUPPRESS_CMD_TIMING_ERROR INTEGER 0
	set_parameter_property MEM_SUPPRESS_CMD_TIMING_ERROR DERIVED false
	set_parameter_property MEM_SUPPRESS_CMD_TIMING_ERROR VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_VERBOSE boolean true 
	set_parameter_property MEM_VERBOSE DISPLAY_NAME "Enable verbose memory model output"
	set_parameter_property MEM_VERBOSE DESCRIPTION "When turned on, more detailed information about each memory access is displayed during simulation.  This information is useful for debugging."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PINGPONGPHY_EN BOOLEAN false
	set_parameter_property PINGPONGPHY_EN DISPLAY_NAME "Enable Ping Pong PHY"
	set_parameter_property PINGPONGPHY_EN DESCRIPTION "Enable Ping Pong PHY"
	set_parameter_property PINGPONGPHY_EN VISIBLE false

	return 1
}

proc ::alt_mem_if::gui::qdrii_mem_model::_create_memory_timing_gui {} {

	_dprint 1 "Preparing to create memory timing GUI in qdrii_mem_model"

	add_display_item "" "Memory Timing" GROUP "tab"
	
	add_display_item "Memory Timing" id1 TEXT "<html>Timing parameters as found in the manufacturer data sheet.<br>Device presets can be applied from the preset list on the right.<br>Parameters on this page are per-device."
	
	add_display_item "Memory Timing" MEM_T_WL PARAMETER
	add_display_item "Memory Timing" MEM_T_RL PARAMETER
	add_display_item "Memory Timing" TIMING_TSA PARAMETER
	add_display_item "Memory Timing" TIMING_THA PARAMETER
	add_display_item "Memory Timing" TIMING_TSD PARAMETER
	add_display_item "Memory Timing" TIMING_THD PARAMETER
	add_display_item "Memory Timing" TIMING_TCQD PARAMETER
	add_display_item "Memory Timing" TIMING_TCQDOH PARAMETER
	add_display_item "Memory Timing" TIMING_QDR_INTERNAL_JITTER PARAMETER
	add_display_item "Memory Timing" TIMING_TCQHCQnH PARAMETER
	add_display_item "Memory Timing" TIMING_TKHKnH PARAMETER
}

proc ::alt_mem_if::gui::qdrii_mem_model::_create_memory_parameters_gui {} {

	variable MSG

	add_display_item "" "Memory Parameters" GROUP "tab"
	
	add_display_item "Memory Parameters" id3 TEXT "<html>Memory parameters as found in the manufacturer data sheet <br>Device presets can be applied from the preset list on the right.<br>"

	add_display_item "Memory Parameters" MEM_ADDR_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_DQ_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_CS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_DM_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_CONTROL_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_READ_DQS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_WRITE_DQS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_BURST_LENGTH PARAMETER
	add_display_item "Memory Parameters" MEM_USE_DENALI_MODEL PARAMETER
	add_display_item "Memory Parameters" QDRII_PLUS_MODE PARAMETER
	add_display_item "Memory Parameters" MEM_DENALI_SOMA_FILE PARAMETER

	add_display_item "Memory Parameters" "Topology" GROUP

	add_display_item "Topology" EMULATED_MODE PARAMETER
	add_display_item "Topology" EMULATED_WRITE_GROUPS PARAMETER
	add_display_item "Topology" DEVICE_WIDTH PARAMETER
	add_display_item "Topology" DEVICE_DEPTH PARAMETER

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {

		add_display_item "Memory Parameters" "Memory Interface" GROUP

		set_parameter_property MEM_IF_CLK_PAIR_COUNT VISIBLE true
		set_parameter_property MEM_IF_ADDR_WIDTH VISIBLE true
		set_parameter_property MEM_IF_READ_DQS_WIDTH VISIBLE true
		set_parameter_property MEM_IF_WRITE_DQS_WIDTH VISIBLE true
		set_parameter_property MEM_IF_WRITE_GROUPS VISIBLE true
		set_parameter_property MEM_IF_DQ_WIDTH VISIBLE true
		set_parameter_property MEM_IF_DM_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CONTROL_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CS_WIDTH VISIBLE true

		add_display_item "Memory Interface" MEM_IF_CLK_PAIR_COUNT PARAMETER
		add_display_item "Memory Interface" MEM_IF_ADDR_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_READ_DQS_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_WRITE_DQS_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_WRITE_GROUPS PARAMETER
		add_display_item "Memory Interface" MEM_IF_DQ_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_DM_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CONTROL_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CS_WIDTH PARAMETER

	}
	
	return 1
}

proc ::alt_mem_if::gui::qdrii_mem_model::create_diagnostics_gui {} {

	variable ddr_mode

	_dprint 1 "Preparing to create Memory Model diagnostics GUI in qdrii_mem_model"

	add_display_item "" "Diagnostics" GROUP "tab"
	add_display_item "Diagnostics" "Simulation Options" GROUP
	add_display_item "Simulation Options" MEM_VERBOSE PARAMETER
}


proc ::alt_mem_if::gui::qdrii_mem_model::_derive_parameters {} {

	_dprint 1 "Preparing to derive parametres for qdrii_mem_model"
	
	if {[get_parameter_value MEM_DQ_WIDTH] == 36} {
		if { ([string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] != 0 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] != 0)  || ([string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] == 0 && [alt_mem_if::util::qini::cfg_is_on "alt_mem_if_enable_stratixv_x36_emulation"] == 1)} {

			set_parameter_property EMULATED_MODE ENABLED TRUE
			if {[get_parameter_value EMULATED_MODE]} {
				set_parameter_property EMULATED_WRITE_GROUPS ENABLED TRUE
			} else {
				set_parameter_property EMULATED_WRITE_GROUPS ENABLED FALSE
			}
		} elseif { ([string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] == 0 && [alt_mem_if::util::qini::cfg_is_on "alt_mem_if_enable_arriavgz_x36_emulation"] == 1)} {

			set_parameter_property EMULATED_MODE ENABLED TRUE
			if {[get_parameter_value EMULATED_MODE]} {
				set_parameter_property EMULATED_WRITE_GROUPS ENABLED TRUE
			} else {
				set_parameter_property EMULATED_WRITE_GROUPS ENABLED FALSE
			}
		} else {
			set_parameter_property EMULATED_MODE ENABLED FALSE
			set_parameter_property EMULATED_WRITE_GROUPS ENABLED FALSE
		}
	} else {
		set_parameter_property EMULATED_MODE ENABLED FALSE
		set_parameter_property EMULATED_WRITE_GROUPS ENABLED FALSE
	}
	
	if { [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "cyclonev"] == 0 || 
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] == 0} {
		
			set_parameter_property EMULATED_MODE ENABLED FALSE
			set_parameter_property EMULATED_WRITE_GROUPS ENABLED FALSE
	}


	if {[string compare -nocase [get_parameter_value EMULATED_MODE] "true"] == 0} {
		set_parameter_property EMULATED_WRITE_GROUPS VISIBLE TRUE
	} else {
		set_parameter_property EMULATED_WRITE_GROUPS VISIBLE FALSE
	}

	if {[get_parameter_value MEM_DQ_WIDTH] == 36 && [string compare -nocase [get_parameter_value EMULATED_MODE] "true"] == 0} {
		set_parameter_value DERIVED_EMULATED_MODE true
		set_parameter_value MEM_EMULATED_READ_GROUPS 2
		set_parameter_value MEM_EMULATED_WRITE_GROUPS [get_parameter_value EMULATED_WRITE_GROUPS]
	} else {
		set_parameter_value DERIVED_EMULATED_MODE false
		set_parameter_value MEM_EMULATED_READ_GROUPS 1
		set_parameter_value MEM_EMULATED_WRITE_GROUPS 1
	}

	set_parameter_value MEM_IF_ADDR_WIDTH [get_parameter_value MEM_ADDR_WIDTH]
	set_parameter_value MEM_IF_CONTROL_WIDTH [get_parameter_value MEM_CONTROL_WIDTH]

	set_parameter_value MEM_IF_CS_WIDTH [expr { [get_parameter_value MEM_CS_WIDTH] * [get_parameter_value DEVICE_DEPTH] }]
	set_parameter_value MEM_IF_DM_WIDTH [expr { [get_parameter_value MEM_DM_WIDTH] * [get_parameter_value DEVICE_WIDTH] }]
	set_parameter_value MEM_IF_DQ_WIDTH [expr { [get_parameter_value MEM_DQ_WIDTH] * [get_parameter_value DEVICE_WIDTH] }]
	set_parameter_value MEM_IF_READ_DQS_WIDTH [expr { [get_parameter_value MEM_READ_DQS_WIDTH] * [get_parameter_value DEVICE_WIDTH] * [get_parameter_value MEM_EMULATED_READ_GROUPS] }]
	
	set_parameter_value MEM_IF_WRITE_DQS_WIDTH [expr { [get_parameter_value MEM_WRITE_DQS_WIDTH] * [get_parameter_value DEVICE_WIDTH] }]
	set_parameter_value MEM_IF_WRITE_GROUPS [expr { [get_parameter_value MEM_IF_WRITE_DQS_WIDTH] * [get_parameter_value MEM_EMULATED_WRITE_GROUPS] }]
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "cyclonev"] == 0} {
		set_parameter_value NO_COMPLIMENTARY_STROBE true
	} else {
		set_parameter_value NO_COMPLIMENTARY_STROBE false
	}
}


::alt_mem_if::gui::qdrii_mem_model::_init
