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


package provide alt_mem_if::gui::common_rldram_controller 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::common_rldram_controller:: {
	variable VALID_RLDRAM_MODES
	variable rldram_mode

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::common_rldram_controller::_validate_rldram_mode {} {
	variable rldram_mode
		
	if {$rldram_mode == -1} {
		error "RLDRAM mode in [namespace current] in uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::common_rldram_controller::set_rldram_mode {in_rldram_mode} {
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

proc ::alt_mem_if::gui::common_rldram_controller::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for RLDRAMx controller"
	
	_create_derived_parameters
	
	_create_controller_parameters
	
	return 1
}


proc ::alt_mem_if::gui::common_rldram_controller::create_gui { {is_top_standalone 0} } {

	_create_controller_parameters_gui $is_top_standalone
	
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		_create_interface_parameters_gui
	}
	
	return 1
}


proc ::alt_mem_if::gui::common_rldram_controller::validate_component {} {

	variable rldram_mode

	_validate_rldram_mode

	_derive_parameters

	_dprint 1 "Preparing to validate component for RLDRAMx controller"
	
	set validation_pass 1

	if {[string compare -nocase [get_parameter_value DEVICE_FAMILY] ""] == 0} {
		_eprint "No device family is set for RLDRAMx controller"
		set validation_pass 0
	}

	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "half"] == 0 && [get_parameter_value MEM_BURST_LENGTH] == 2 } {
			_eprint "Burst length of 2 is not supported in Half Rate"
			set validation_pass 0
		}
	}

	set max_refresh_time [expr {(2000 * [get_parameter_value MEM_T_RC]) / [get_parameter_value MEM_CLK_FREQ]}]
	if {[get_parameter_value MEM_REFRESH_INTERVAL_NS] < $max_refresh_time} {
		_eprint "Refresh Interval must be greater than $max_refresh_time"
		set validation_pass 0
	}


	if {[string compare -nocase [get_parameter_value POWER_OF_TWO_BUS] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value ERROR_DETECTION_PARITY] "true"] == 0} {
			_error "Power-of-two bus width and Error Detection Parity cannot both be used at the same time"
			set validation_pass 0
		}
	}

	if {[string compare -nocase [get_parameter_value ERROR_DETECTION_PARITY] "true"] == 0} {
		set afi_data_width_mod_9 [expr { [get_parameter_value AFI_DQ_WIDTH] % 9 } ]
		if { $afi_data_width_mod_9 != 0 } {
			_error "Error Detection Parity can only be used with DQ buses of a multiple of 9"
			set validation_pass 0
		}
	}

	if {[get_parameter_value CTL_LATENCY] != 2} {
		_iprint "Please refer to the external memory interface handbook for supported latency and maximum frequency combination"
	}

	return $validation_pass

}

proc ::alt_mem_if::gui::common_rldram_controller::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for RLDRAMx controller"
	
	return 1
}


proc ::alt_mem_if::gui::common_rldram_controller::_init {} {
	
	variable VALID_RLDRAM_MODES
	
	::alt_mem_if::util::list_array::array_clean VALID_RLDRAM_MODES
	set VALID_RLDRAM_MODES(RLDRAMII) 1
	set VALID_RLDRAM_MODES(RLDRAM3) 1

	variable rldram_mode -1

}

proc ::alt_mem_if::gui::common_rldram_controller::_create_derived_parameters {} {

	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set has_controller_gui true
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set has_controller_gui false
	}
		
	_dprint 1 "Preparing to create derived parameters in RLDRAMx controller"

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_BURST_LENGTH INTEGER 0
	set_parameter_property CTL_BURST_LENGTH DERIVED true
	set_parameter_property CTL_BURST_LENGTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ADDR_WIDTH INTEGER 0
	set_parameter_property CTL_ADDR_WIDTH DERIVED true
	set_parameter_property CTL_ADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CHIPADDR_WIDTH INTEGER 0
	set_parameter_property CTL_CHIPADDR_WIDTH DERIVED true
	set_parameter_property CTL_CHIPADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_BANKADDR_WIDTH INTEGER 0
	set_parameter_property CTL_BANKADDR_WIDTH DERIVED true
	set_parameter_property CTL_BANKADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_BEATADDR_WIDTH INTEGER 0
	set_parameter_property CTL_BEATADDR_WIDTH DERIVED true
	set_parameter_property CTL_BEATADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CS_WIDTH INTEGER 0
	set_parameter_property CTL_CS_WIDTH DERIVED true
	set_parameter_property CTL_CS_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CONTROL_WIDTH INTEGER 0
	set_parameter_property CTL_CONTROL_WIDTH DERIVED true
	set_parameter_property CTL_CONTROL_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_T_REFI INTEGER 0
	set_parameter_property CTL_T_REFI DERIVED true
	set_parameter_property CTL_T_REFI VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_ADDR_WIDTH INTEGER 0
	set_parameter_property AVL_ADDR_WIDTH DERIVED true
	set_parameter_property AVL_ADDR_WIDTH VISIBLE $has_controller_gui
	set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME "Avalon interface address width"
	set_parameter_property AVL_ADDR_WIDTH DESCRIPTION "Address width on the Avalon-MM interface"
	set_parameter_property AVL_ADDR_WIDTH UNITS Bits
	set_parameter_property AVL_ADDR_WIDTH ENABLED false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_BE_WIDTH INTEGER 0
	set_parameter_property AVL_BE_WIDTH DERIVED true
	set_parameter_property AVL_BE_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_DATA_WIDTH INTEGER 0
	set_parameter_property AVL_DATA_WIDTH DERIVED true
	set_parameter_property AVL_DATA_WIDTH VISIBLE $has_controller_gui
	set_parameter_property AVL_DATA_WIDTH DISPLAY_NAME "Avalon interface data width"
	set_parameter_property AVL_DATA_WIDTH DESCRIPTION "Data width on the Avalon-MM interface"
	set_parameter_property AVL_DATA_WIDTH UNITS Bits
	set_parameter_property AVL_DATA_WIDTH ENABLED false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_SYMBOL_WIDTH INTEGER 8
	set_parameter_property AVL_SYMBOL_WIDTH DERIVED TRUE
	set_parameter_property AVL_SYMBOL_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_NUM_SYMBOLS integer 2
	set_parameter_property AVL_NUM_SYMBOLS DERIVED TRUE
	set_parameter_property AVL_NUM_SYMBOLS VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_SIZE_WIDTH integer 0
	set_parameter_property AVL_SIZE_WIDTH DERIVED TRUE
	set_parameter_property AVL_SIZE_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_REFI integer 0
	set_parameter_property MEM_T_REFI DERIVED TRUE
	set_parameter_property MEM_T_REFI VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter HR_DDIO_OUT_HAS_THREE_REGS boolean false
	set_parameter_property HR_DDIO_OUT_HAS_THREE_REGS DERIVED true
	set_parameter_property HR_DDIO_OUT_HAS_THREE_REGS VISIBLE false

}


proc ::alt_mem_if::gui::common_rldram_controller::_create_controller_parameters {} {
	
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set has_controller_gui true
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set has_controller_gui false
	}	
	
	_dprint 1 "Preparing to create controller parameters in RLDRAMx controller"

	::alt_mem_if::util::hwtcl_utils::_add_parameter POWER_OF_TWO_BUS boolean false
	set_parameter_property POWER_OF_TWO_BUS DISPLAY_NAME "Generate power-of-2 data bus widths for Qsys or SOPC Builder"
	set_parameter_property POWER_OF_TWO_BUS DESCRIPTION "This option must be enabled if this core is to be used in a Qsys or SOPC Builder system.  When turned on, the Avalon-MM side data bus width is rounded down to the nearest power of 2."
	set_parameter_property POWER_OF_TWO_BUS AFFECTS_ELABORATION true
	set_parameter_property POWER_OF_TWO_BUS VISIBLE $has_controller_gui

	::alt_mem_if::util::hwtcl_utils::_add_parameter SOPC_COMPAT_RESET boolean false
	set_parameter_property SOPC_COMPAT_RESET DISPLAY_NAME "Generate SOPC Builder compatible resets"
	set_parameter_property SOPC_COMPAT_RESET DESCRIPTION "This option must be enabled if this core is to be used in an SOPC Builder system.  When turned on, the reset inputs become associated with the PLL reference clock and the paths must be cut."
	set_parameter_property SOPC_COMPAT_RESET AFFECTS_ELABORATION true
	set_parameter_property SOPC_COMPAT_RESET VISIBLE $has_controller_gui

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_MAX_SIZE integer 4
	set_parameter_property AVL_MAX_SIZE DISPLAY_NAME "Maximum Avalon-MM burst length"
	set_parameter_property AVL_MAX_SIZE DESCRIPTION "Specifies the maximum burst length on the Avalon-MM bus."
	set_parameter_property AVL_MAX_SIZE ALLOWED_RANGES {1 2 4 8 16 32 64 128 256 512 1024}
	set_parameter_property AVL_MAX_SIZE AFFECTS_ELABORATION true
	set_parameter_property AVL_MAX_SIZE VISIBLE $has_controller_gui

	::alt_mem_if::util::hwtcl_utils::_add_parameter BYTE_ENABLE boolean false
	set_parameter_property BYTE_ENABLE DISPLAY_NAME "Enable Avalon-MM byte-enable signal"
	set_parameter_property BYTE_ENABLE DESCRIPTION "When turned on, the controller will add the byte-enable signal for the Avalon-MM bus"
	set_parameter_property BYTE_ENABLE AFFECTS_ELABORATION true
	set_parameter_property BYTE_ENABLE VISIBLE false
	set_parameter_property BYTE_ENABLE ENABLED false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_LATENCY String 2
	set_parameter_property CTL_LATENCY DISPLAY_NAME "Reduce Controller Latency by"
	set_parameter_property CTL_LATENCY DESCRIPTION "Select the number of controller latency to be reduce in controller clock cycles for better latency or fmax.
	Lower latency controller would not be able to run as fast as the default frequency.
	Refer to the External Memory Interface handbook for supported latency and maximum frequency combination."
	set_parameter_property CTL_LATENCY ALLOWED_RANGES {"1:1" "2:0"}
	set_parameter_property CTL_LATENCY VISIBLE $has_controller_gui
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USER_REFRESH boolean false 
	set_parameter_property USER_REFRESH DISPLAY_NAME "Enable User Refresh"
	set_parameter_property USER_REFRESH DESCRIPTION "To enable user to control when to place the memory into refresh mode.The user refresh will have the higher priority over the read/write requests"
	set_parameter_property USER_REFRESH AFFECTS_ELABORATION true
	set_parameter_property USER_REFRESH VISIBLE $has_controller_gui
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ERROR_DETECTION_PARITY boolean false
	set_parameter_property ERROR_DETECTION_PARITY DISPLAY_NAME "Enable Error Detection Parity"
	set_parameter_property ERROR_DETECTION_PARITY DESCRIPTION "To enable per byte parity protection to the writen data"
	set_parameter_property ERROR_DETECTION_PARITY AFFECTS_ELABORATION true
	set_parameter_property ERROR_DETECTION_PARITY VISIBLE $has_controller_gui

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_CTRL_AVALON_INTERFACE boolean true
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE DISPLAY_NAME "Enable Avalon interface"
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE VISIBLE false
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE AFFECTS_ELABORATION true

	return 1
}


proc ::alt_mem_if::gui::common_rldram_controller::_create_controller_parameters_gui {is_top_standalone} {

	_dprint 1 "Preparing to create controller GUI in RLDRAMx controller"

	add_display_item "" "Controller Settings" GROUP "tab"
	
	if {$is_top_standalone} {
		add_display_item "Controller Settings" RATE PARAMETER
		add_display_item "Controller Settings" MEM_CLK_FREQ PARAMETER
		add_display_item "Controller Settings" SPEED_GRADE PARAMETER
	}

	add_display_item "Controller Settings" POWER_OF_TWO_BUS PARAMETER
	add_display_item "Controller Settings" SOPC_COMPAT_RESET PARAMETER
	add_display_item "Controller Settings" AVL_MAX_SIZE PARAMETER
	add_display_item "Controller Settings" BYTE_ENABLE PARAMETER
	add_display_item "Controller Settings" AVL_ADDR_WIDTH parameter
	add_display_item "Controller Settings" AVL_DATA_WIDTH parameter
	add_display_item "Controller Settings" CTL_LATENCY PARAMETER
	add_display_item "Controller Settings" USER_REFRESH PARAMETER
	add_display_item "Controller Settings" ERROR_DETECTION_PARITY PARAMETER

	return 1
}

proc ::alt_mem_if::gui::common_rldram_controller::_create_interface_parameters_gui {} {

	_dprint 1 "Preparing to create interface GUI in RLDRAMx controller"

	add_display_item "" "Interface Settings" GROUP "tab"

	add_display_item "Interface Settings" "AFI Interface" GROUP
	set_parameter_property AFI_RATE_RATIO VISIBLE true
	set_parameter_property DATA_RATE_RATIO VISIBLE true
	set_parameter_property ADDR_RATE_RATIO VISIBLE true
	add_display_item "AFI Interface" AFI_RATE_RATIO PARAMETER
	add_display_item "AFI Interface" DATA_RATE_RATIO PARAMETER
	add_display_item "AFI Interface" ADDR_RATE_RATIO PARAMETER

	set_parameter_property AFI_ADDR_WIDTH VISIBLE true
	set_parameter_property AFI_CS_WIDTH VISIBLE true
	set_parameter_property AFI_DM_WIDTH VISIBLE true
	set_parameter_property AFI_DQ_WIDTH VISIBLE true
	add_display_item "AFI Interface" AFI_ADDR_WIDTH PARAMETER
	add_display_item "AFI Interface" AFI_CS_WIDTH PARAMETER
	add_display_item "AFI Interface" AFI_DM_WIDTH PARAMETER
	add_display_item "AFI Interface" AFI_DQ_WIDTH PARAMETER
	
	set_parameter_property AVL_SYMBOL_WIDTH VISIBLE true
	set_parameter_property AVL_SIZE_WIDTH VISIBLE true
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE VISIBLE true
	add_display_item "Interface Settings" "Avalon-MM Interface" GROUP
	add_display_item "Avalon-MM Interface" AVL_SYMBOL_WIDTH PARAMETER
	add_display_item "Avalon-MM Interface" AVL_SIZE_WIDTH PARAMETER
	add_display_item "Avalon-MM Interface" ENABLE_CTRL_AVALON_INTERFACE PARAMETER
	
	return 1
}

proc ::alt_mem_if::gui::common_rldram_controller::_derive_parameters {} {

	_dprint 1 "Preparing to derive parametres for RLDRAMx controller"
	
	set_parameter_value CTL_ADDR_WIDTH [get_parameter_value MEM_IF_ADDR_WIDTH]
	set_parameter_value CTL_BANKADDR_WIDTH [get_parameter_value MEM_IF_BANKADDR_WIDTH]

	set_parameter_value CTL_CS_WIDTH [get_parameter_value MEM_IF_CS_WIDTH]
	set_parameter_value CTL_CONTROL_WIDTH [get_parameter_value MEM_IF_CONTROL_WIDTH]

	set_parameter_value CTL_BURST_LENGTH [ expr { [get_parameter_value MEM_BURST_LENGTH] / ( [get_parameter_value AFI_RATE_RATIO] * [get_parameter_value DATA_RATE_RATIO] ) } ]

        if {[get_parameter_value CTL_BURST_LENGTH] > 0} {
                set_parameter_value CTL_BEATADDR_WIDTH [expr { int(ceil(log([get_parameter_value CTL_BURST_LENGTH])/log(2))) } ]
        }
	set_parameter_value CTL_CHIPADDR_WIDTH  [expr { int(ceil(log([get_parameter_value MEM_IF_CS_WIDTH])/log(2))) } ]

	set_parameter_value AVL_ADDR_WIDTH [expr {[get_parameter_value MEM_IF_ADDR_WIDTH] + [get_parameter_value CTL_CHIPADDR_WIDTH] + [get_parameter_value MEM_IF_BANKADDR_WIDTH] + [get_parameter_value CTL_BEATADDR_WIDTH]} ]


	set AVL_DATA_WIDTH [get_parameter_value AFI_DQ_WIDTH]
	_dprint 1 "Initially setting AVL_DATA_WIDTH = $AVL_DATA_WIDTH"
		
	set avl_data_width_mod_8 [expr { $AVL_DATA_WIDTH % 8 } ]
	set avl_data_width_mod_9 [expr { $AVL_DATA_WIDTH % 9 } ]
	if { $avl_data_width_mod_9 == 0} {
		set_parameter_value AVL_SYMBOL_WIDTH 9
	} elseif { $avl_data_width_mod_8 == 0} {
		set_parameter_value AVL_SYMBOL_WIDTH 8
	} else {
		set_parameter_value AVL_SYMBOL_WIDTH $AVL_DATA_WIDTH
	}
	_dprint 1 "Using AVL_SYMBOL_WIDTH == [get_parameter_value AVL_SYMBOL_WIDTH]"
	

	if {[string compare -nocase [get_parameter_value POWER_OF_TWO_BUS] "true"] == 0} {
		set AVL_DATA_WIDTH [expr {int(pow(2,(int(floor(log($AVL_DATA_WIDTH)/log(2))))))}]
		set_parameter_value AVL_SYMBOL_WIDTH 8
		_dprint 1 "Updating AVL_DATA_WIDTH = $AVL_DATA_WIDTH and AVL_SYMBOL_WIDTH = 8 because of power-of-two bus width"
	}

	if {[string compare -nocase [get_parameter_value ERROR_DETECTION_PARITY] "true"] ==0} {
		set AVL_DATA_WIDTH [expr { int($AVL_DATA_WIDTH - ($AVL_DATA_WIDTH/9)) } ]
		set_parameter_value AVL_SYMBOL_WIDTH 8
		_dprint 1 "Updating AVL_DATA_WIDTH = $AVL_DATA_WIDTH and AVL_SYMBOL_WIDTH = 8 because of parity bits"
	}

	set_parameter_value AVL_DATA_WIDTH $AVL_DATA_WIDTH

	set_parameter_value AVL_NUM_SYMBOLS [ expr { [get_parameter_value AVL_DATA_WIDTH] / [get_parameter_value AVL_SYMBOL_WIDTH] } ]
	

	set_parameter_value AVL_NUM_SYMBOLS [expr {$AVL_DATA_WIDTH / [get_parameter_value AVL_SYMBOL_WIDTH]}]
	set data_mod_symbols [expr {[get_parameter_value AVL_DATA_WIDTH] % [get_parameter_value AVL_SYMBOL_WIDTH]}]
	set symbols_log_2 [expr {int(ceil(log([get_parameter_value AVL_NUM_SYMBOLS])/log(2)))}]
	set symbols_log_2_pow_2 [expr {pow(2,$symbols_log_2)}]

	set_parameter_value AVL_SIZE_WIDTH [expr {int(ceil(log([get_parameter_value AVL_MAX_SIZE]+1)/log(2)))}]


	set mem_clk_ps [expr { round (1000000.0 / [get_parameter_value MEM_CLK_FREQ]) } ]
	set_parameter_value MEM_T_REFI [expr { int([get_parameter_value MEM_REFRESH_INTERVAL_NS] * 1000 / $mem_clk_ps) } ]

	if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		set_parameter_value CTL_T_REFI [expr { [get_parameter_value MEM_T_REFI] / 2 }]
	} else {
		set_parameter_value CTL_T_REFI [get_parameter_value MEM_T_REFI]
	}

		
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIII"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGX"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGZ"] == 0} {
		set_parameter_value HR_DDIO_OUT_HAS_THREE_REGS true
	} else {
		set_parameter_value HR_DDIO_OUT_HAS_THREE_REGS false
	}

}


::alt_mem_if::gui::common_rldram_controller::_init
