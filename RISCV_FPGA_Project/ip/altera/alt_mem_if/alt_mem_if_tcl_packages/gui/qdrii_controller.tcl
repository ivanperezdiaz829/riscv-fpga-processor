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


package provide alt_mem_if::gui::qdrii_controller 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::qdrii_controller:: {

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::qdrii_controller::create_parameters {} {
	
	_dprint 1 "Preparing tocreate parameters for qdrii_controller"
	
	_create_derived_parameters
	
	_create_controller_parameters
	
	return 1
}


proc ::alt_mem_if::gui::qdrii_controller::create_gui { {is_top_standalone 0} } {

	_create_controller_parameters_gui $is_top_standalone
	
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		_create_interface_parameters_gui
	}

	return 1
}


proc ::alt_mem_if::gui::qdrii_controller::validate_component {} {

	_derive_parameters

	_dprint 1 "Preparing to validate component for qdrii_controller"
	
	set validation_pass 1

	set data_width_mod_symbol_width [expr {[get_parameter_value AVL_DATA_WIDTH] % [get_parameter_value AVL_SYMBOL_WIDTH]}]
	set symbols_log_2 [expr {int(ceil(log([get_parameter_value AVL_NUM_SYMBOLS])/log(2)))}]
	set symbols_log_2_pow_2 [expr {pow(2,$symbols_log_2)}]
	set num_symbols_log_2_pow_2_symbols_with [expr {$symbols_log_2_pow_2 * [get_parameter_value AVL_SYMBOL_WIDTH]} ]

	if {[string compare -nocase [get_parameter_value DEVICE_FAMILY] ""] == 0} {
		_eprint "No device family is set for QDR II controller"
		set validation_pass 0
	}

	if {[string compare -nocase [get_parameter_value BYTE_ENABLE] "true"] == 0} {
		if { $data_width_mod_symbol_width != 0 || $num_symbols_log_2_pow_2_symbols_with != [get_parameter_value AVL_DATA_WIDTH] || [get_parameter_value AVL_DATA_WIDTH] <= [get_parameter_value AVL_SYMBOL_WIDTH]} {
			_eprint "Use of Byte Enable is not possible with the specified data width"
			set validation_pass 0
		}
	}

	if {[string compare -nocase [get_parameter_value RATE] "half"] == 0 && [get_parameter_value MEM_BURST_LENGTH] == 2 } {
		_eprint "Burst length of 2 is not supported in Half Rate"
		set validation_pass 0
	}

	if {[get_parameter_value CTL_LATENCY] != 1} {
		_iprint "Please refer to the external memory interface handbook for supported latency and maximum frequency combination"
	}
	

	return $validation_pass

}

proc ::alt_mem_if::gui::qdrii_controller::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for qdrii_controller"
	
	set data_width_mod_symbol_width [expr {[get_parameter_value AVL_DATA_WIDTH] % [get_parameter_value AVL_SYMBOL_WIDTH]}]
	if { $data_width_mod_symbol_width == 0 && [get_parameter_value AVL_DATA_WIDTH] > [get_parameter_value AVL_SYMBOL_WIDTH]} {
		set_parameter_property BYTE_ENABLE ENABLED TRUE
	} else {
		set_parameter_property BYTE_ENABLE ENABLED FALSE
	}
	
	return 1
}


proc ::alt_mem_if::gui::qdrii_controller::_init {} {
	

}

proc ::alt_mem_if::gui::qdrii_controller::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in qdrii_controller"

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ADDR_WIDTH INTEGER 0
	set_parameter_property CTL_ADDR_WIDTH DERIVED true
	set_parameter_property CTL_ADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CS_WIDTH INTEGER 0
	set_parameter_property CTL_CS_WIDTH DERIVED true
	set_parameter_property CTL_CS_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_ADDR_WIDTH INTEGER 0
	set_parameter_property AVL_ADDR_WIDTH DERIVED true
	set_parameter_property AVL_ADDR_WIDTH VISIBLE true
	set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME "Avalon interface address width"
	set_parameter_property AVL_ADDR_WIDTH DESCRIPTION "Address width on the Avalon-MM interface"
	set_parameter_property AVL_ADDR_WIDTH UNITS Bits
	set_parameter_property AVL_ADDR_WIDTH ENABLED false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_BE_WIDTH INTEGER 0
	set_parameter_property AVL_BE_WIDTH DERIVED true
	set_parameter_property AVL_BE_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_DATA_WIDTH INTEGER 0
	set_parameter_property AVL_DATA_WIDTH DERIVED true
	set_parameter_property AVL_DATA_WIDTH VISIBLE true
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

}


proc ::alt_mem_if::gui::qdrii_controller::_create_controller_parameters {} {
	
	_dprint 1 "Preparing to create controller parameters in qdrii_controller"

	::alt_mem_if::util::hwtcl_utils::_add_parameter POWER_OF_TWO_BUS boolean false
	set_parameter_property POWER_OF_TWO_BUS DISPLAY_NAME "Generate power-of-2 data bus widths for Qsys or SOPC Builder"
	set_parameter_property POWER_OF_TWO_BUS DESCRIPTION "This option must be enabled if this core is to be used in a Qsys or SOPC Builder system.  When turned on, the Avalon-MM side data bus width is rounded down to the nearest power of 2."
	set_parameter_property POWER_OF_TWO_BUS AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter SOPC_COMPAT_RESET boolean false
	set_parameter_property SOPC_COMPAT_RESET DISPLAY_NAME "Generate SOPC Builder compatible resets"
	set_parameter_property SOPC_COMPAT_RESET DESCRIPTION "This option must be enabled if this core is to be used in an SOPC Builder system.  When turned on, the reset inputs become associated with the PLL reference clock and the paths must be cut."
	set_parameter_property SOPC_COMPAT_RESET AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_MAX_SIZE integer 4
	set_parameter_property AVL_MAX_SIZE DISPLAY_NAME "Maximum Avalon-MM burst length"
	set_parameter_property AVL_MAX_SIZE DESCRIPTION "Specifies the maximum burst length on the Avalon-MM bus."
	set_parameter_property AVL_MAX_SIZE ALLOWED_RANGES {1 2 4 8 16 32 64 128 256 512 1024}
	set_parameter_property AVL_MAX_SIZE AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter BYTE_ENABLE boolean true
	set_parameter_property BYTE_ENABLE DISPLAY_NAME "Enable Avalon-MM byte-enable signal"
	set_parameter_property BYTE_ENABLE DESCRIPTION "When turned on, the controller will add the byte-enable signal for the Avalon-MM bus"
	set_parameter_property BYTE_ENABLE AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_LATENCY String 1
	set_parameter_property CTL_LATENCY DISPLAY_NAME "Reduce Controller Latency by"
	set_parameter_property CTL_LATENCY DESCRIPTION "Select the number of controller latency to be reduce in controller clock cycles for better latency or fmax.
	Lower latency controller would not be able to run as fast as the default frequency.
	Refer to the External Memory Interface handbook for supported latency and maximum frequency combination."
	set_parameter_property CTL_LATENCY ALLOWED_RANGES {"1:Zero" "0:One"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_CTRL_AVALON_INTERFACE boolean true
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE DISPLAY_NAME "Enable Avalon interface"
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE VISIBLE false
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE AFFECTS_ELABORATION true

	return 1
}


proc ::alt_mem_if::gui::qdrii_controller::_create_controller_parameters_gui {is_top_standalone} {

	_dprint 1 "Preparing to create controller GUI in qdrii_controller"

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
	
	return 1
}

proc ::alt_mem_if::gui::qdrii_controller::_create_interface_parameters_gui {} {

	_dprint 1 "Preparing to create interface GUI in qdrii_controller"

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

proc ::alt_mem_if::gui::qdrii_controller::_derive_parameters {} {

	_dprint 1 "Preparing to derive parametres for qdrii_controller"

	if {[expr {[get_parameter_value MEM_IF_DQ_WIDTH]%9}] == 0} {
		set_parameter_value AVL_SYMBOL_WIDTH 9
	} elseif {[expr {[get_parameter_value MEM_IF_DQ_WIDTH]%8}] == 0} {
		set_parameter_value AVL_SYMBOL_WIDTH 8
	} else {
		set_parameter_value AVL_SYMBOL_WIDTH [get_parameter_value MEM_IF_DQ_WIDTH]
		_wprint "Unrecognized DQ width of [get_parameter_value MEM_IF_DQ_WIDTH]. Using Avalon-MM symbol width of [get_parameter_value MEM_IF_DQ_WIDTH]"
	}

	
	set_parameter_value AVL_ADDR_WIDTH [get_parameter_value MEM_IF_ADDR_WIDTH]
	set_parameter_value CTL_ADDR_WIDTH [get_parameter_value MEM_IF_ADDR_WIDTH]

	set_parameter_value CTL_CS_WIDTH [get_parameter_value MEM_IF_CS_WIDTH]


	set AVL_DATA_WIDTH [get_parameter_value AFI_DQ_WIDTH]
	_dprint 1 "Initially setting AVL_DATA_WIDTH = $AVL_DATA_WIDTH"

	if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
		if {[string compare [get_parameter_value MEM_BURST_LENGTH] "4"] == 0} {
			set AVL_DATA_WIDTH [expr {$AVL_DATA_WIDTH * 2}]
			_dprint 1 "Updating AVL_DATA_WIDTH = $AVL_DATA_WIDTH because of FR BL4"
		}
	}

	if {[string compare -nocase [get_parameter_value POWER_OF_TWO_BUS] "true"] == 0} {
		set AVL_DATA_WIDTH [expr {int(pow(2,(int(floor(log($AVL_DATA_WIDTH)/log(2))))))}]
		set_parameter_value AVL_SYMBOL_WIDTH 8
		_dprint 1 "Updating AVL_DATA_WIDTH = $AVL_DATA_WIDTH and AVL_SYMBOL_WIDTH = 8 because of power-of-two bus width"
	}
	set_parameter_value AVL_DATA_WIDTH $AVL_DATA_WIDTH

	set_parameter_value AVL_NUM_SYMBOLS [expr {$AVL_DATA_WIDTH / [get_parameter_value AVL_SYMBOL_WIDTH]}]
	set data_mod_symbols [expr {[get_parameter_value AVL_DATA_WIDTH] % [get_parameter_value AVL_SYMBOL_WIDTH]}]
	set symbols_log_2 [expr {int(ceil(log([get_parameter_value AVL_NUM_SYMBOLS])/log(2)))}]
	set symbols_log_2_pow_2 [expr {pow(2,$symbols_log_2)}]

	if {[get_parameter_value MEM_IF_DQ_WIDTH] == 8 && [get_parameter_value MEM_IF_DM_WIDTH] == 2} {
		set_parameter_value AVL_BE_WIDTH [expr {[get_parameter_value AFI_DM_WIDTH] / 2}]
	} else {
		set_parameter_value AVL_BE_WIDTH [get_parameter_value AVL_NUM_SYMBOLS]
	}

	set_parameter_value AVL_SIZE_WIDTH [expr {int(ceil(log([get_parameter_value AVL_MAX_SIZE]+1)/log(2)))}]
}


::alt_mem_if::gui::qdrii_controller::_init
