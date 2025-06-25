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


package provide alt_mem_if::gui::common_rldram_phy 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::uniphy_debug

namespace eval ::alt_mem_if::gui::common_rldram_phy:: {
	variable VALID_RLDRAM_MODES
	variable rldram_mode

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::common_rldram_phy::_validate_rldram_mode {} {
	variable rldram_mode
		
	if {$rldram_mode == -1} {
		error "RLDRAM mode in [namespace current] in uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::common_rldram_phy::set_rldram_mode {in_rldram_mode} {
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

proc ::alt_mem_if::gui::common_rldram_phy::create_parameters {} {

	_validate_rldram_mode
	
	_dprint 1 "Preparing to create parameters for common_rldram_phy"
	
	_create_derived_parameters

	_create_phy_parameters
	
	_create_board_settings_parameters

	alt_mem_if::gui::uniphy_debug::create_debug_parameters

	return 1
}


proc ::alt_mem_if::gui::common_rldram_phy::create_phy_gui {} {

	_create_phy_parameters_gui
	
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		_create_interface_parameters_gui
	}

	return 1
}


proc ::alt_mem_if::gui::common_rldram_phy::create_board_settings_gui {} {

	_create_board_settings_parameters_gui

	return 1
}


proc ::alt_mem_if::gui::common_rldram_phy::create_diagnostics_gui {} {

	_create_diagnostics_gui

	return 1
}


proc ::alt_mem_if::gui::common_rldram_phy::validate_component {} {

	variable rldram_mode
	
	set legal_family 0
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] == 0 ||
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixiii"] == 0 ||
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixiv"] == 0 ||
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriaiigz"] == 0 ||
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0 ||
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] == 0} {
			set legal_family 1
		}
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] == 0} {
			set legal_family 1
		}
	}
	
	if {! $legal_family} {
		if {[string compare -nocase [get_module_property INTERNAL] "true"] != 0 &&
			[string compare -nocase [get_module_property INTERNAL] "1"] != 0} {
			_eprint "[get_module_property DESCRIPTION] is not supported by family [get_parameter_value DEVICE_FAMILY]"
		}
		return 0
	}

	set_parameter_property HARD_EMIF VISIBLE false
	set_parameter_property HARD_EMIF ENABLED false

	::alt_mem_if::gui::uniphy_debug::derive_debug_parameters

	::alt_mem_if::gen::uniphy_gen::derive_delay_params $rldram_mode

	_derive_parameters
	
	_derive_board_settings_parameters

	::alt_mem_if::gen::uniphy_pll::derive_pll $rldram_mode

	_dprint 1 "Preparing to validate component for common_rldram_phy"
	
	set validation_pass 1
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set MEM_CLK_FREQ_MIN 170
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set MEM_CLK_FREQ_MIN 200
	}

	if {[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1} {
		if {[get_parameter_value MEM_CLK_FREQ] < $MEM_CLK_FREQ_MIN || [get_parameter_value MEM_CLK_FREQ] > [get_parameter_value MEM_CLK_FREQ_MAX]} {
			_eprint "Memory clock frequency must be between $MEM_CLK_FREQ_MIN MHz and [get_parameter_value MEM_CLK_FREQ_MAX] MHz"
			set validation_pass 0
		} else {
			if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
				set MEM_REFRESH_INTERVAL_NS_MIN [expr {(2000 * [get_parameter_value MEM_T_RC]) / [get_parameter_value MEM_CLK_FREQ]}]
				if {[get_parameter_value MEM_REFRESH_INTERVAL_NS] < $MEM_REFRESH_INTERVAL_NS_MIN} {
					_eprint "Refresh Interval must be greater than $MEM_REFRESH_INTERVAL_NS_MIN"
					set validation_pass 0
				}
			}
		} 
	} else {
		_eprint "Memory clock frequency must be between $MEM_CLK_FREQ_MIN MHz and [get_parameter_value MEM_CLK_FREQ_MAX] MHz"
		set validation_pass 0
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriaiigx"] == 0} {
			_eprint "The high-performance Nios II-based sequencer is not supported in Arria II GX"
			set validation_pass 0
		}
		if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
			_eprint "The high-performance Nios II-based sequencer is not supported in full rate"
			set validation_pass 0
		}
		if {[string compare -nocase [get_parameter_value CALIBRATION_MODE] "skip"] == 0 || [string compare -nocase [get_parameter_value CALIBRATION_MODE] "quick"] == 0 } {
			_wprint "'Quick' simulation modes are NOT timing accurate. Some simulation memory models may issue warnings or errors"
		}
	} else {
		if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
			_eprint "The RLDRAM 3 protocol requires the high-performance Nios II-based sequencer"
			set validation_pass 0
		}
		if {[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1 && [get_parameter_value MEM_CLK_FREQ] > 400} {
			_wprint "The memory clock frequency specified is above 400MHz and may require the high-performance Nios II-based sequencer to close timing"
		}
	}
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0 &&
		[string compare -nocase [get_parameter_value RATE] "QUARTER"] != 0 &&
		[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1 &&
		[get_parameter_value MEM_CLK_FREQ] > 533} {
		_wprint "The memory clock frequency specified is above 533MHz and may require the quarter-rate PHY to close timing"
	}
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0 &&
		[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1 &&
		[get_parameter_value MEM_CLK_FREQ] > 800 &&
		[string compare -nocase [get_parameter_value IO_STANDARD] "1.2-V HSTL Class II"] != 0} {
		_wprint "For interfaces faster than 800MHz, I/O standard \"1.2-V HSTL Class II\" should be used for improved output signal integrity due to higher drive strength"
	}
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			if {[get_parameter_value MRS_DATA_LATENCY] <= 5} {
				_eprint "RL smaller than 9 is only supported by the half-rate PHY"
				set validation_pass 0
			}
		}
	}

	set p2c_read_clk_add_phase [get_parameter_value P2C_READ_CLOCK_ADD_PHASE]
	if { $p2c_read_clk_add_phase > 179 || $p2c_read_clk_add_phase < -179 } {
		_eprint "Additional periphery-to-core phase out of range (must be between -179 and +179)"
		set validation_pass 0
	}	
	
	set c2p_write_clk_add_phase [get_parameter_value C2P_WRITE_CLOCK_ADD_PHASE]
	if { $c2p_write_clk_add_phase > 179 || $c2p_write_clk_add_phase < -179 } {
		_eprint "Additional core-to-periphery phase out of range (must be between -179 and +179)"
		set validation_pass 0
	}
	
	set acv_phy_clk_add_fr_phase [get_parameter_value ACV_PHY_CLK_ADD_FR_PHASE]
	if { $acv_phy_clk_add_fr_phase > 179 || $acv_phy_clk_add_fr_phase < -179 } {
		_eprint "'[get_parameter_property ACV_PHY_CLK_ADD_FR_PHASE DISPLAY_NAME]' out of range (must be between -179 and +179)"
		set validation_pass 0
	}	

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		set_parameter_property PACKAGE_DESKEW VISIBLE true
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		set_parameter_property AC_PACKAGE_DESKEW VISIBLE true
	}
	
	set family [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]
	if {[string compare -nocase $family "STRATIXIII"] == 0 ||
		[string compare -nocase $family "STRATIXIV"] == 0 ||
		[string compare -nocase $family "ARRIAIIGX"] == 0 ||
		[string compare -nocase $family "ARRIAIIGZ"] == 0} {
		set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION VISIBLE false
		set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME VISIBLE false
	}		
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] > 800} {
			if {[string compare -nocase [get_parameter_value PACKAGE_DESKEW] "true"] == 0} {
				_iprint "DQ/DM/DK/QK pin package deskew is enabled - Ensure that the PCB is designed to compensate for the FPGA package skews"
			} else {
				_wprint "DQ/DM/DK/QK  pin package skew may need to be compensated on the PCB for speeds above 800MHz to improve timing"
				_wprint "For more information, see Altera Knowledge Base Solution rd11302012_466"
			}
			
			if {[string compare -nocase [get_parameter_value AC_PACKAGE_DESKEW] "true"] == 0} {
				_iprint "Address/command pin package deskew is enabled - Ensure that the PCB is designed to compensate for the FPGA package skews"
			} else {
				_wprint "Address/command pin FPGA package skew may need to be compensated on the PCB for speeds above 800MHz to improve timing"
				_wprint "For more information, see Altera Knowledge Base Solution rd11302012_466"
			}
		}
	}
	
	if { [ string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true" ] == 0} {
		if {[string compare -nocase [get_parameter_value PHY_CLKBUF] "true"] == 0} {
			set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE VISIBLE true
		} else {
			set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE VISIBLE false
		}
	} else {
		set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE VISIBLE false
	}		
	
	set_parameter_property P2C_READ_CLOCK_ADD_PHASE VISIBLE false
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
	    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set_parameter_property ACV_PHY_CLK_ADD_FR_PHASE VISIBLE false
	} else {
		set_parameter_property ACV_PHY_CLK_ADD_FR_PHASE VISIBLE false
	}

	if { [ string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true" ] == 0} {
		set_parameter_property COMMAND_PHASE VISIBLE false
	} else {
		set_parameter_property COMMAND_PHASE VISIBLE true
	}
	
	if {[get_parameter_value NIOS_ROM_ADDRESS_WIDTH] != [get_parameter_property NIOS_ROM_ADDRESS_WIDTH DEFAULT_VALUE]} {
		set_parameter_value NIOS_ROM_ADDRESS_WIDTH [get_parameter_property NIOS_ROM_ADDRESS_WIDTH DEFAULT_VALUE]
	}
	
	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0 &&
		[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
		_eprint "The options '[get_parameter_property HARD_EMIF DISPLAY_NAME]' and '[get_parameter_property PHY_ONLY DISPLAY_NAME]' cannot be enabled simultaneously."
		set validation_pass 0
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 } {
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] != 0 } {
			_eprint "RTL Sequencer is not supported for RLDRAMII External Memory Interface with ArriaV"
			set validation_pass 0
		}
	}	
	
	return $validation_pass
}

proc ::alt_mem_if::gui::common_rldram_phy::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for common_rldram_phy"
	
	return 1
}


proc ::alt_mem_if::gui::common_rldram_phy::_init {} {
	
	variable VALID_RLDRAM_MODES
	
	::alt_mem_if::util::list_array::array_clean VALID_RLDRAM_MODES
	set VALID_RLDRAM_MODES(RLDRAMII) 1
	set VALID_RLDRAM_MODES(RLDRAM3) 1

	variable rldram_mode -1

}

proc ::alt_mem_if::gui::common_rldram_phy::_create_derived_parameters {} {

	variable rldram_mode	

	_dprint 1 "Preparing to create derived parameters in common_rldram_phy"
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {	
		::alt_mem_if::util::hwtcl_utils::_add_parameter DERATED_TAS integer 0
		set_parameter_property DERATED_TAS DISPLAY_NAME "Derated tAS"
		set_parameter_property DERATED_TAS DESCRIPTION "The derated address/command setup time is calculated automatically from the \"tAS\", the \"tAS Vref to CK/CK# Crossing\", and the \"tAS VIH MIN to CK/CK# Crossing\" parameters."
		set_parameter_property DERATED_TAS Visible true
		set_parameter_property DERATED_TAS Units picoseconds
		set_parameter_property DERATED_TAS DISPLAY_HINT columns:10
		set_parameter_property DERATED_TAS DERIVED true
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter DERATED_TAH integer 0
		set_parameter_property DERATED_TAH DISPLAY_NAME "Derated tAH"
		set_parameter_property DERATED_TAH DESCRIPTION "The derated address/command hold time is calculated automatically from the \"tAH\", the \"tAH CK/CK# Crossing to Vref\", and the \"tAH CK/CK# Crossing to VIH MIN\" parameters."
		set_parameter_property DERATED_TAH Visible true
		set_parameter_property DERATED_TAH Units picoseconds
		set_parameter_property DERATED_TAH DISPLAY_HINT columns:10
		set_parameter_property DERATED_TAH DERIVED true

		::alt_mem_if::util::hwtcl_utils::_add_parameter DERATED_TDS integer 25
		set_parameter_property DERATED_TDS DISPLAY_NAME "Derated tDS"
		set_parameter_property DERATED_TDS DESCRIPTION "The derated data setup time is calculated automatically from the \"tDS\", the \"tDS Vref to CK/CK# Crossing\", and the \"tDS VIH MIN to CK/CK# Crossing\" parameters."
		set_parameter_property DERATED_TDS Visible true
		set_parameter_property DERATED_TDS Units picoseconds
		set_parameter_property DERATED_TDS DISPLAY_HINT columns:10
		set_parameter_property DERATED_TDS DERIVED true
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter DERATED_TDH integer 13
		set_parameter_property DERATED_TDH DISPLAY_NAME "Derated tDH"
		set_parameter_property DERATED_TDH DESCRIPTION "The derated data hold time is calculated automatically from the \"tDH\", the \"tDH CK/CK# Crossing to Vref\", and the \"tDH CK/CK# Crossing to VIH MIN\" parameters."
		set_parameter_property DERATED_TDH Visible true
		set_parameter_property DERATED_TDH Units picoseconds
		set_parameter_property DERATED_TDH DISPLAY_HINT columns:10
		set_parameter_property DERATED_TDH DERIVED true
	} 
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter EXTRA_SETTINGS string ""
	set_parameter_property EXTRA_SETTINGS VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DEVICE string "MISSING_MODEL"
	set_parameter_property MEM_DEVICE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter FORCE_SYNTHESIS_LANGUAGE string ""             
	set_parameter_property FORCE_SYNTHESIS_LANGUAGE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_SUBGROUP_PER_READ_DQS INTEGER 0
	set_parameter_property NUM_SUBGROUP_PER_READ_DQS VISIBLE false
	set_parameter_property NUM_SUBGROUP_PER_READ_DQS DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter QVLD_EXTRA_FLOP_STAGES INTEGER 0
	set_parameter_property QVLD_EXTRA_FLOP_STAGES VISIBLE false
	set_parameter_property QVLD_EXTRA_FLOP_STAGES DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter QVLD_WR_ADDRESS_OFFSET INTEGER 0
	set_parameter_property QVLD_WR_ADDRESS_OFFSET DERIVED true
	set_parameter_property QVLD_WR_ADDRESS_OFFSET VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MAX_WRITE_LATENCY_COUNT_WIDTH INTEGER 4
	set_parameter_property MAX_WRITE_LATENCY_COUNT_WIDTH VISIBLE false
	set_parameter_property MAX_WRITE_LATENCY_COUNT_WIDTH DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_WRITE_PATH_FLOP_STAGES INTEGER 0
	set_parameter_property NUM_WRITE_PATH_FLOP_STAGES VISIBLE false
	set_parameter_property NUM_WRITE_PATH_FLOP_STAGES DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_AC_FR_CYCLE_SHIFTS INTEGER 0
	set_parameter_property NUM_AC_FR_CYCLE_SHIFTS VISIBLE false
	set_parameter_property NUM_AC_FR_CYCLE_SHIFTS DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_WRITE_FR_CYCLE_SHIFTS INTEGER 0
	set_parameter_property NUM_WRITE_FR_CYCLE_SHIFTS VISIBLE false
	set_parameter_property NUM_WRITE_FR_CYCLE_SHIFTS DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PERFORM_READ_AFTER_WRITE_CALIBRATION BOOLEAN false
	set_parameter_property PERFORM_READ_AFTER_WRITE_CALIBRATION VISIBLE false
	set_parameter_property PERFORM_READ_AFTER_WRITE_CALIBRATION DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter SEQ_BURST_COUNT_WIDTH INTEGER 0
	set_parameter_property SEQ_BURST_COUNT_WIDTH VISIBLE false
	set_parameter_property SEQ_BURST_COUNT_WIDTH DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter VCALIB_COUNT_WIDTH INTEGER 0
	set_parameter_property VCALIB_COUNT_WIDTH VISIBLE false
	set_parameter_property VCALIB_COUNT_WIDTH DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PLL_PHASE_COUNTER_WIDTH INTEGER 0
	set_parameter_property PLL_PHASE_COUNTER_WIDTH VISIBLE false
	set_parameter_property PLL_PHASE_COUNTER_WIDTH DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_DEBUG_INFO_WIDTH INTEGER 32
	set_parameter_property AFI_DEBUG_INFO_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQS_DELAY_CHAIN_PHASE_SETTING INTEGER 2
	set_parameter_property DQS_DELAY_CHAIN_PHASE_SETTING VISIBLE false
	set_parameter_property DQS_DELAY_CHAIN_PHASE_SETTING DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQS_PHASE_SHIFT INTEGER 9000
	set_parameter_property DQS_PHASE_SHIFT VISIBLE false
	set_parameter_property DQS_PHASE_SHIFT DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DELAYED_CLOCK_PHASE_SETTING INTEGER 2
	set_parameter_property DELAYED_CLOCK_PHASE_SETTING VISIBLE false
	set_parameter_property DELAYED_CLOCK_PHASE_SETTING DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_DQS_IN_RESERVE INTEGER 3
	set_parameter_property IO_DQS_IN_RESERVE VISIBLE false
	set_parameter_property IO_DQS_IN_RESERVE DERIVED true	
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_DQS_OUT_RESERVE INTEGER 3
	set_parameter_property IO_DQS_OUT_RESERVE VISIBLE false
	set_parameter_property IO_DQS_OUT_RESERVE DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_DQ_OUT_RESERVE INTEGER 0
	set_parameter_property IO_DQ_OUT_RESERVE VISIBLE false
	set_parameter_property IO_DQ_OUT_RESERVE DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_DM_OUT_RESERVE INTEGER 0
	set_parameter_property IO_DM_OUT_RESERVE VISIBLE false
	set_parameter_property IO_DM_OUT_RESERVE DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_DQS_EN_DELAY_OFFSET INTEGER 0
	set_parameter_property IO_DQS_EN_DELAY_OFFSET VISIBLE false
	set_parameter_property IO_DQS_EN_DELAY_OFFSET DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_DQS_EN_PHASE_MAX INTEGER 0
	set_parameter_property IO_DQS_EN_PHASE_MAX VISIBLE false
	set_parameter_property IO_DQS_EN_PHASE_MAX DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_DQDQS_OUT_PHASE_MAX INTEGER 0
	set_parameter_property IO_DQDQS_OUT_PHASE_MAX VISIBLE false
	set_parameter_property IO_DQDQS_OUT_PHASE_MAX DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_SHIFT_DQS_EN_WHEN_SHIFT_DQS BOOLEAN false
	set_parameter_property IO_SHIFT_DQS_EN_WHEN_SHIFT_DQS VISIBLE false
	set_parameter_property IO_SHIFT_DQS_EN_WHEN_SHIFT_DQS DERIVED true

	add_parameter HR_DDIO_OUT_HAS_THREE_REGS BOOLEAN false
	set_parameter_property HR_DDIO_OUT_HAS_THREE_REGS VISIBLE false
	set_parameter_property HR_DDIO_OUT_HAS_THREE_REGS DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ADDR_CMD_PATH_FLOP_STAGE_POST_MUX BOOLEAN false
	set_parameter_property ADDR_CMD_PATH_FLOP_STAGE_POST_MUX VISIBLE false
	set_parameter_property ADDR_CMD_PATH_FLOP_STAGE_POST_MUX DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_NS float 0
	set_parameter_property MEM_CLK_NS VISIBLE FALSE
	set_parameter_property MEM_CLK_NS DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_PS float 0
	set_parameter_property MEM_CLK_PS VISIBLE FALSE
	set_parameter_property MEM_CLK_PS DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ADDR_CTRL_SKEW float 0.02
	set_parameter_property ADDR_CTRL_SKEW VISIBLE false
	set_parameter_property ADDR_CTRL_SKEW DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CALIB_LFIFO_OFFSET integer -1
	set_parameter_property CALIB_LFIFO_OFFSET DERIVED true
	set_parameter_property CALIB_LFIFO_OFFSET VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CALIB_VFIFO_OFFSET integer -1
	set_parameter_property CALIB_VFIFO_OFFSET DERIVED true
	set_parameter_property CALIB_VFIFO_OFFSET VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DELAY_PER_OPA_TAP integer -1
	set_parameter_property DELAY_PER_OPA_TAP DERIVED true
	set_parameter_property DELAY_PER_OPA_TAP VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DELAY_PER_DCHAIN_TAP integer -1
	set_parameter_property DELAY_PER_DCHAIN_TAP DERIVED true
	set_parameter_property DELAY_PER_DCHAIN_TAP VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DELAY_PER_DQS_EN_DCHAIN_TAP integer -1
	set_parameter_property DELAY_PER_DQS_EN_DCHAIN_TAP DERIVED true
	set_parameter_property DELAY_PER_DQS_EN_DCHAIN_TAP VISIBLE false	
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQS_EN_DELAY_MAX integer -1
	set_parameter_property DQS_EN_DELAY_MAX DERIVED true
	set_parameter_property DQS_EN_DELAY_MAX VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQS_IN_DELAY_MAX integer -1
	set_parameter_property DQS_IN_DELAY_MAX DERIVED true
	set_parameter_property DQS_IN_DELAY_MAX VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_IN_DELAY_MAX integer -1
	set_parameter_property IO_IN_DELAY_MAX DERIVED true
	set_parameter_property IO_IN_DELAY_MAX VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_OUT1_DELAY_MAX integer -1
	set_parameter_property IO_OUT1_DELAY_MAX DERIVED true
	set_parameter_property IO_OUT1_DELAY_MAX VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_OUT2_DELAY_MAX integer -1
	set_parameter_property IO_OUT2_DELAY_MAX DERIVED true
	set_parameter_property IO_OUT2_DELAY_MAX VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ADVERTIZE_SEQUENCER_SW_BUILD_FILES boolean false
	set_parameter_property ADVERTIZE_SEQUENCER_SW_BUILD_FILES VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_RESERVED_PINS_WIDTH integer -1
	set_parameter_property MEM_IF_RESERVED_PINS_WIDTH DERIVED true
	set_parameter_property MEM_IF_RESERVED_PINS_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter RESERVED_PINS_FOR_DK_GROUP boolean false
	set_parameter_property RESERVED_PINS_FOR_DK_GROUP DERIVED true
	set_parameter_property RESERVED_PINS_FOR_DK_GROUP VISIBLE false

	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0 string ""
		set_parameter_property AC_ROM_MR0 DERIVED true
		set_parameter_property AC_ROM_MR0 VISIBLE false
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0_CALIB_DLL_OFF string ""
		set_parameter_property AC_ROM_MR0_CALIB_DLL_OFF DERIVED true
		set_parameter_property AC_ROM_MR0_CALIB_DLL_OFF VISIBLE false
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0_CALIB_DLL_ON string ""
		set_parameter_property AC_ROM_MR0_CALIB_DLL_ON DERIVED true
		set_parameter_property AC_ROM_MR0_CALIB_DLL_ON VISIBLE false

	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {	
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0 string ""
		set_parameter_property AC_ROM_MR0 DERIVED true
		set_parameter_property AC_ROM_MR0 VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0_QUAD_RANK string ""
		set_parameter_property AC_ROM_MR0_QUAD_RANK DERIVED true
		set_parameter_property AC_ROM_MR0_QUAD_RANK VISIBLE false
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR1 string ""
		set_parameter_property AC_ROM_MR1 DERIVED true
		set_parameter_property AC_ROM_MR1 VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR1_CALIB string ""
		set_parameter_property AC_ROM_MR1_CALIB DERIVED true
		set_parameter_property AC_ROM_MR1_CALIB VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR2 string ""
		set_parameter_property AC_ROM_MR2 DERIVED true
		set_parameter_property AC_ROM_MR2 VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR2_CALIB string ""
		set_parameter_property AC_ROM_MR2_CALIB DERIVED true
		set_parameter_property AC_ROM_MR2_CALIB VISIBLE false
	}
		
	::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_CLKBUF BOOLEAN false
	set_parameter_property PHY_CLKBUF VISIBLE false		
	set_parameter_property PHY_CLKBUF DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_LDC_AS_LOW_SKEW_CLOCK BOOLEAN false
	set_parameter_property USE_LDC_AS_LOW_SKEW_CLOCK VISIBLE false		
	set_parameter_property USE_LDC_AS_LOW_SKEW_CLOCK DERIVED true
    
	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_LDC_FOR_ADDR_CMD BOOLEAN false
	set_parameter_property USE_LDC_FOR_ADDR_CMD VISIBLE false		
	set_parameter_property USE_LDC_FOR_ADDR_CMD DERIVED true	

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_LDC_MEM_CK_ADJUSTMENT BOOLEAN false
	set_parameter_property ENABLE_LDC_MEM_CK_ADJUSTMENT VISIBLE false		
	set_parameter_property ENABLE_LDC_MEM_CK_ADJUSTMENT DERIVED true	

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CK_LDC_ADJUSTMENT_THRESHOLD integer 0
	set_parameter_property MEM_CK_LDC_ADJUSTMENT_THRESHOLD VISIBLE false		
	set_parameter_property MEM_CK_LDC_ADJUSTMENT_THRESHOLD DERIVED true	

	::alt_mem_if::util::hwtcl_utils::_add_parameter LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT BOOLEAN true
	set_parameter_property LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT VISIBLE false		
	set_parameter_property LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT DERIVED true	

	::alt_mem_if::util::hwtcl_utils::_add_parameter LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE integer 0
	set_parameter_property LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE VISIBLE false		
	set_parameter_property LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE DERIVED true	
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter REGISTER_C2P BOOLEAN false
	set_parameter_property REGISTER_C2P VISIBLE false		
	set_parameter_property REGISTER_C2P DERIVED true	
}


proc ::alt_mem_if::gui::common_rldram_phy::_create_phy_parameters {} {
	
	variable rldram_mode
	
	_dprint 1 "Preparing to create PHY parameters in common_rldram_phy"
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {	
		::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_ONLY boolean false
		set_parameter_property PHY_ONLY VISIBLE true
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_ONLY boolean true
		set_parameter_property PHY_ONLY VISIBLE false
	}
	set_parameter_property PHY_ONLY DISPLAY_NAME "Generate PHY only"
	set_parameter_property PHY_ONLY DESCRIPTION "When turned on, no controller will be generated and the AFI interface to the PHY will become available."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter COMMAND_PHASE STRING "0" 
	set_parameter_property COMMAND_PHASE DISPLAY_NAME "Additional Address/Command clock phase"
	set_parameter_property COMMAND_PHASE UNITS None
	set_parameter_property COMMAND_PHASE DISPLAY_UNITS Degrees
	set_parameter_property COMMAND_PHASE DESCRIPTION "This setting allows for increasing or decreasing the amount of phase shift on the address/command clock.  
	The base phase shift center aligns the address/command clock at the memory device.
	This may not be the optimal setting under all circumstances.  Increasing or decreasing the amount of phase shift can improve timing."
	set_parameter_property COMMAND_PHASE ALLOWED_RANGES {-45 -22.5 0 22.5 45}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CK_PHASE FLOAT 0.0
	set_parameter_property MEM_CK_PHASE DISPLAY_NAME "Additional CK/CK# phase"
	set_parameter_property MEM_CK_PHASE DISPLAY_UNITS Degrees
	set_parameter_property MEM_CK_PHASE DESCRIPTION "Allows you to increase or decrease the amount of phase shift on the CK/CK
	The base phase shift center aligns the address and command clock at the memory device, which may not be the optimal setting under all circumstances.
	Increasing or decreasing the amount of phase shift can improve timing."
	set_parameter_property MEM_CK_PHASE VISIBLE false
	set_parameter_property MEM_CK_PHASE ENABLED false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter P2C_READ_CLOCK_ADD_PHASE FLOAT 0.0 
	set_parameter_property P2C_READ_CLOCK_ADD_PHASE DISPLAY_NAME "Additional phase for periphery-to-core transfer"
	set_parameter_property P2C_READ_CLOCK_ADD_PHASE DISPLAY_UNITS Degrees
	set_parameter_property P2C_READ_CLOCK_ADD_PHASE DESCRIPTION "This setting allows for phase shifting the launch clock of the periphery-to-core transfers.  
	A negative value can improve setup timing for transfers from the read fifo in the I/O periphery to core logic, by making the launch clock earlier."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter C2P_WRITE_CLOCK_ADD_PHASE FLOAT 0.0 
	set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE DISPLAY_NAME "Additional phase for core-to-periphery transfer"
	set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE DISPLAY_UNITS Degrees
	set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE DESCRIPTION "This setting allows for phase shifting the latch clock of the core-to-periphery transfers.  
	A positive value can improve setup timing for transfers from core logic to registers in the I/O periphery, by delaying the latch clock."

	::alt_mem_if::util::hwtcl_utils::_add_parameter ACV_PHY_CLK_ADD_FR_PHASE FLOAT 0.0 
	set_parameter_property ACV_PHY_CLK_ADD_FR_PHASE DISPLAY_NAME "Additional phase for PHY clock tree"
	set_parameter_property ACV_PHY_CLK_ADD_FR_PHASE DISPLAY_UNITS Degrees
	set_parameter_property ACV_PHY_CLK_ADD_FR_PHASE DESCRIPTION "This setting allows for phase shifting the PHY tree clocks."

	
	::alt_mem_if::util::hwtcl_utils::_add_parameter HCX_COMPAT_MODE boolean false
	set_parameter_property HCX_COMPAT_MODE VISIBLE false
	set_parameter_property HCX_COMPAT_MODE DISPLAY_NAME "HardCopy Compatibility Mode"
	set_parameter_property HCX_COMPAT_MODE DESCRIPTION "When turned on, the UniPHY memory interface generated has all required HardCopy compatibility options enabled.
	For example PLLs and DLLs will have their reconfiguration ports exposed."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PLL_LOCATION STRING "Top_Bottom" 
	set_parameter_property PLL_LOCATION DISPLAY_NAME "Reconfigurable PLL Location"
	set_parameter_property PLL_LOCATION UNITS None
	set_parameter_property PLL_LOCATION DESCRIPTION "When the PLL used in the UniPHY memory interface is set to be reconfigurable at run time, the location of the PLL must be specified.
	This assignment will generate a PLL which can only be placed in the given sides."
	set_parameter_property PLL_LOCATION ALLOWED_RANGES {Top_Bottom Left_Right}
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter IO_STANDARD STRING "1.8-V HSTL"
		set_parameter_property IO_STANDARD DISPLAY_NAME "I/O standard"
		set_parameter_property IO_STANDARD DESCRIPTION "I/O standard voltage."
		set_parameter_property IO_STANDARD ALLOWED_RANGES {"1.8-V HSTL" "1.5-V HSTL"}
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter SEQUENCER_TYPE STRING "RTL"
		set_parameter_property SEQUENCER_TYPE DERIVED false
		set_parameter_property SEQUENCER_TYPE VISIBLE true
		set_parameter_property SEQUENCER_TYPE DISPLAY_NAME "Sequencer optimization"
		set_parameter_property SEQUENCER_TYPE AFFECTS_ELABORATION true
		set_parameter_property SEQUENCER_TYPE ALLOWED_RANGES {"NIOS:Performance (Nios II-based Sequencer)" "RTL:Area (RTL Sequencer)"}
		set_parameter_property SEQUENCER_TYPE DESCRIPTION "Selects the optimized version of the sequencer, which performs memory calibration tasks.
		Choose \"Performance\" to enable the Nios(R) II-based sequencer which performs per-bit deskew.
		It is recommended at speeds above 400 MHz.
		Choose \"Area\" for a simple RTL-based sequencer."
		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter IO_STANDARD STRING "1.2-V HSTL Class II"
		set_parameter_property IO_STANDARD DISPLAY_NAME "I/O standard"
		set_parameter_property IO_STANDARD DESCRIPTION "I/O standard voltage. For interfaces faster than 800MHz, 1.2-V HSTL Class II is recommended for improved output signal integrity due to higher drive strength."
		set_parameter_property IO_STANDARD ALLOWED_RANGES {"1.2-V HSTL Class II" "1.2-V HSTL Class I" "SSTL-12"}

		::alt_mem_if::util::hwtcl_utils::_add_parameter SEQUENCER_TYPE STRING "NIOS"
		set_parameter_property SEQUENCER_TYPE DERIVED false
		set_parameter_property SEQUENCER_TYPE VISIBLE true
		set_parameter_property SEQUENCER_TYPE DISPLAY_NAME "Sequencer optimization"
		set_parameter_property SEQUENCER_TYPE AFFECTS_ELABORATION true
		set_parameter_property SEQUENCER_TYPE ALLOWED_RANGES {"NIOS:Performance (Nios II-based Sequencer)"}
		set_parameter_property SEQUENCER_TYPE DESCRIPTION "Selects the optimized version of the sequencer, which performs memory calibration tasks.
		Only the Nios(R) II-based sequencer is supported for the RLDRAM 3 protocol due to its higher speed requirement."
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter SKIP_MEM_INIT boolean true 
	set_parameter_property SKIP_MEM_INIT DISPLAY_NAME "Skip Memory Initialization Delays"
	set_parameter_property SKIP_MEM_INIT DESCRIPTION "When turned on, required delays between specific memory initialization commands are skipped to speed up simulation.
	There is no change to the generated RTL"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter CALIBRATION_MODE STRING "Skip"
	set_parameter_property CALIBRATION_MODE DISPLAY_NAME "Auto-calibration mode"
	set_parameter_property CALIBRATION_MODE AFFECTS_ELABORATION true
	set_parameter_property CALIBRATION_MODE DESCRIPTION "Simulation performance is improved by reduced calibration.
	There is no change to the generated RTL.
	The Nios II-based sequencer must be selected to enable this option."
	set_parameter_property CALIBRATION_MODE ALLOWED_RANGES {"Skip:Skip calibration" "Quick:Quick calibration" "Full:Full calibration"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DQSN_EN boolean true
	set_parameter_property MEM_IF_DQSN_EN VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_LEVELING boolean false
	set_parameter_property MEM_LEVELING VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter READ_DQ_DQS_CLOCK_SOURCE string "INVERTED_DQS_BUS"
	set_parameter_property READ_DQ_DQS_CLOCK_SOURCE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQ_INPUT_REG_USE_CLKN boolean false
	set_parameter_property DQ_INPUT_REG_USE_CLKN VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQS_DQSN_MODE string "none"
	set_parameter_property DQS_DQSN_MODE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter READ_FIFO_SIZE integer 8
	set_parameter_property READ_FIFO_SIZE DISPLAY_NAME "Depth of the read FIFO"
	set_parameter_property READ_FIFO_SIZE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter NIOS_ROM_DATA_WIDTH integer 32
	set_parameter_property NIOS_ROM_DATA_WIDTH visible false

	::alt_mem_if::util::hwtcl_utils::_add_parameter NIOS_ROM_ADDRESS_WIDTH integer 13
	set_parameter_property NIOS_ROM_ADDRESS_WIDTH visible false
	set_parameter_property NIOS_ROM_ADDRESS_WIDTH derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_CSR_ENABLED Boolean false
	set_parameter_property PHY_CSR_ENABLED DISPLAY_NAME "Enable Configuration and Status Register Interface"
	set_parameter_property PHY_CSR_ENABLED DESCRIPTION "Select this option to enable run-time configuration and status of the memory PHY.
	Enabling this option adds an additional Avalon Memory-Mapped slave port to the memory PHY top level."
	set_parameter_property PHY_CSR_ENABLED VISIBLE false
	set_parameter_property PHY_CSR_ENABLED DISPLAY_HINT boolean

	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {	
	    ::alt_mem_if::util::hwtcl_utils::_add_parameter RLDRAMII_AV_EMIF_INVERT_CAPTURE_STROBE boolean false
	    set_parameter_property RLDRAMII_AV_EMIF_INVERT_CAPTURE_STROBE VISIBLE false
	}
	
}




proc ::alt_mem_if::gui::common_rldram_phy::_create_board_settings_parameters {} {
	
	variable rldram_mode
	
	_validate_rldram_mode	
	
	_dprint 1 "Preparing to create board settings parameters in common_rldram_phy"
		
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_EYE_REDUCTION_SU integer 0
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU DISPLAY_NAME "Address/Command eye reduction (setup)"
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU DESCRIPTION "The reduction in the eye diagram on the setup side (or left side of the eye) due to channel loss on the address/command signals."
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU Visible true
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU Units picoseconds
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_EYE_REDUCTION_H integer 0
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H DISPLAY_NAME "Address/Command eye reduction (hold)"
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H DESCRIPTION "The reduction in the eye diagram on the hold side (or right side of the eye) due to channel loss on the address/command signals."
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H Visible true
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H Units picoseconds
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQ_EYE_REDUCTION integer 0
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DISPLAY_NAME "Write DQ eye reduction"
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DESCRIPTION "The total reduction in the write eye diagram due to SI effects such as ISI/cross talk on DQ signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION Visible true
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION Units picoseconds
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME integer 0
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DISPLAY_NAME "Delta DK arrival time"
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DESCRIPTION "The increase in variation on the range of arrival times of DK during a write due to SI effects.  Note it is assumed that the SI effects will cause DK to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME Visible true
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME Units picoseconds
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_READ_DQ_EYE_REDUCTION Float 0
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DISPLAY_NAME "Read DQ eye reduction"
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DESCRIPTION "The total reduction in the read eye diagram due to SI effects such as ISI/cross talk on DQ signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION Units Nanoseconds
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME Float 0
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DISPLAY_NAME "Delta QK arrival time"
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DESCRIPTION "The increase in variation on the range of arrival times of QK during a read due to SI effects.  Note it is assumed that the SI effects will cause QK to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME Units Nanoseconds
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PACKAGE_DESKEW boolean false
	set_parameter_property PACKAGE_DESKEW DISPLAY_NAME "FPGA DQ package skews deskewed on board"
	set_parameter_property PACKAGE_DESKEW DESCRIPTION "Improve timing margin by user compensation of DQ/DM/DK/QK FPGA package trace on PCB trace (Please see the External Memory Interface handbook for information regarding customer action)."
	set_parameter_property PACKAGE_DESKEW Visible false
	set_parameter_property PACKAGE_DESKEW DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_PACKAGE_DESKEW boolean false
	set_parameter_property AC_PACKAGE_DESKEW DISPLAY_NAME "FPGA Address/Command package skews deskewed on board"
	set_parameter_property AC_PACKAGE_DESKEW DESCRIPTION "Improve timing margin by user compensation of Address/Command and CK FPGA package trace on PCB trace (Please see the External Memory Interface handbook for information regarding customer action)."
	set_parameter_property AC_PACKAGE_DESKEW Visible false
	set_parameter_property AC_PACKAGE_DESKEW DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_MAX_CK_DELAY integer 600
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY DISPLAY_NAME "Maximum CK delay to device"
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY DESCRIPTION "The delay of the longest CK trace from the FPGA to any device."
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY Visible true
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY Units picoseconds
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY ALLOWED_RANGES {0:2000}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_MAX_DQS_DELAY integer 600
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY DISPLAY_NAME "Maximum DK delay to device"
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY DESCRIPTION "The delay of the longest DK trace from the FPGA to any device."
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY Visible true
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY Units picoseconds
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY ALLOWED_RANGES {0:2000}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_CKDQS_DIMM_MIN integer 0
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN DISPLAY_NAME "Minimum delay difference between CK and DK"
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN DESCRIPTION "The minimum delay difference between the CK signal and any DK signal when arriving at the memory device(s).  
	The value is equal to the minimum delay of the CK signal minus the maximum delay of the DK signal.
	The value can be positive or negative."
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN Visible true
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN ALLOWED_RANGES {-500:500}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_CKDQS_DIMM_MAX integer 0
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX DISPLAY_NAME "Maximum delay difference between CK and DK"
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX DESCRIPTION "The maximum delay difference between the CK signal and any DK signal when arriving at the memory device(s).  
	The value is equal to the maximum delay of the CK signal minus the minimum delay of the DK signal.
	The value can be positive or negative."
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX Visible true
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX ALLOWED_RANGES {-500:500}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_BETWEEN_DIMMS integer 0
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DISPLAY_NAME "Maximum delay difference between devices"
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DESCRIPTION "The maximum delay difference of data signals (i.e. DQ, M) between devices.  
	For example, in a two-device configuration there is an extra propagation delay for data signals going to and coming back from the furthest device compared to the nearest device."
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS Visible true
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_WITHIN_DQS integer 20
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS DISPLAY_NAME "Maximum skew within QK group"
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS DESCRIPTION "The maximum skew between the DQ signals referenced by a common QK signal."
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS Visible true
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_BETWEEN_DQS integer 20
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DISPLAY_NAME "Maximum skew between QK groups"
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DESCRIPTION "The maximum skew between QK signals of different data groups."
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS Visible true
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_ADDR_CTRL_SKEW integer 20
	set_parameter_property TIMING_ADDR_CTRL_SKEW DISPLAY_NAME "Maximum skew within Address/Command bus"
	set_parameter_property TIMING_ADDR_CTRL_SKEW DESCRIPTION "The maximum skew between the Address/Command signals."
	set_parameter_property TIMING_ADDR_CTRL_SKEW UNITS picoseconds
	set_parameter_property TIMING_ADDR_CTRL_SKEW ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_TO_CK_SKEW integer 0
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DISPLAY_NAME "Average delay difference between Address/Command and CK"
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DESCRIPTION "The value is equal to the average of the longest and the smallest Address/Command signal delay values, minus the delay of the CK signal.  
	The value can be positive or negative."
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW Visible true
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW Units picoseconds
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW ALLOWED_RANGES {-500:500}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DATA_TO_DK_SKEW integer 0
	set_parameter_property TIMING_BOARD_DATA_TO_DK_SKEW DISPLAY_NAME "Average delay difference between write data signals and DK"
	set_parameter_property TIMING_BOARD_DATA_TO_DK_SKEW DESCRIPTION "The value is equal to the average of the longest and the smallest write data signal delay values, minus the delay of the DK signal.  
	Write data signals include the DQ and the DM signals.
	The value can be positive or negative."
	set_parameter_property TIMING_BOARD_DATA_TO_DK_SKEW Visible true
	set_parameter_property TIMING_BOARD_DATA_TO_DK_SKEW Units picoseconds
	set_parameter_property TIMING_BOARD_DATA_TO_DK_SKEW DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DATA_TO_DK_SKEW ALLOWED_RANGES {-500:500}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DATA_TO_QK_SKEW integer 0
	set_parameter_property TIMING_BOARD_DATA_TO_QK_SKEW DISPLAY_NAME "Average delay difference between read data signals and QK"
	set_parameter_property TIMING_BOARD_DATA_TO_QK_SKEW DESCRIPTION "The value is equal to the average of the longest and the smallest read data signal delay values, minus the delay of the QK signal.  
	The value can be positive or negative."
	set_parameter_property TIMING_BOARD_DATA_TO_QK_SKEW Visible true
	set_parameter_property TIMING_BOARD_DATA_TO_QK_SKEW Units picoseconds
	set_parameter_property TIMING_BOARD_DATA_TO_QK_SKEW DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DATA_TO_QK_SKEW ALLOWED_RANGES {-500:500}
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TAS integer 0
		set_parameter_property TIMING_BOARD_TAS DISPLAY_NAME "tAS Vref to CK/CK# Crossing"
		set_parameter_property TIMING_BOARD_TAS DESCRIPTION "For a given address/command and CK/CK# slew rate, the memory device data sheet provides a corresponding \"tAS Vref to CK/CK# Crossing\" value that can be used to determine the derated address/command setup time."
		set_parameter_property TIMING_BOARD_TAS Visible true
		set_parameter_property TIMING_BOARD_TAS Units picoseconds
		set_parameter_property TIMING_BOARD_TAS DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TAS ALLOWED_RANGES {0:2000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TAS_VIH integer -100
		set_parameter_property TIMING_BOARD_TAS_VIH DISPLAY_NAME "tAS VIH MIN to CK/CK# Crossing"
		set_parameter_property TIMING_BOARD_TAS_VIH DESCRIPTION "For a given address/command and CK/CK# slew rate, the memory device data sheet provides a corresponding \"tAS VIH MIN to CK/CK# Crossing\" value that can be used to determine the derated address/command setup time."
		set_parameter_property TIMING_BOARD_TAS_VIH Visible true
		set_parameter_property TIMING_BOARD_TAS_VIH Units picoseconds
		set_parameter_property TIMING_BOARD_TAS_VIH DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TAS_VIH ALLOWED_RANGES {-500:500}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TAH integer 0
		set_parameter_property TIMING_BOARD_TAH DISPLAY_NAME "tAH CK/CK# Crossing to Vref"
		set_parameter_property TIMING_BOARD_TAH DESCRIPTION "For a given address/command and CK/CK# slew rate, the memory device data sheet provides a corresponding \"tAH CK/CK# Crossing to Vref\" value that can be used to determine the derated address/command hold time."
		set_parameter_property TIMING_BOARD_TAH Visible true
		set_parameter_property TIMING_BOARD_TAH Units picoseconds
		set_parameter_property TIMING_BOARD_TAH DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TAH ALLOWED_RANGES {0:2000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TAH_VIH integer -50
		set_parameter_property TIMING_BOARD_TAH_VIH DISPLAY_NAME "tAH CK/CK# Crossing to VIH MIN"
		set_parameter_property TIMING_BOARD_TAH_VIH DESCRIPTION "For a given address/command and CK/CK# slew rate, the memory device data sheet provides a corresponding \"tAH CK/CK# Crossing to VIH MIN\" value that can be used to determine the derated address/command hold time."
		set_parameter_property TIMING_BOARD_TAH_VIH Visible true
		set_parameter_property TIMING_BOARD_TAH_VIH Units picoseconds
		set_parameter_property TIMING_BOARD_TAH_VIH DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TAH_VIH ALLOWED_RANGES {-500:500}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDS integer 25
		set_parameter_property TIMING_BOARD_TDS DISPLAY_NAME "tDS Vref to CK/CK# Crossing"
		set_parameter_property TIMING_BOARD_TDS DESCRIPTION "For a given data and DK/DK# slew rate, the memory device data sheet provides a corresponding \"tDS Vref to CK/CK# Crossing\" value that can be used to determine the derated data setup time."
		set_parameter_property TIMING_BOARD_TDS Visible true
		set_parameter_property TIMING_BOARD_TDS Units picoseconds
		set_parameter_property TIMING_BOARD_TDS DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TDS ALLOWED_RANGES {0:2000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDS_VIH integer -100
		set_parameter_property TIMING_BOARD_TDS_VIH DISPLAY_NAME "tDS VIH MIN to CK/CK# Crossing"
		set_parameter_property TIMING_BOARD_TDS_VIH DESCRIPTION "For a given data and DK/DK# slew rate, the memory device data sheet provides a corresponding \"tDS VIH MIN to CK/CK# Crossing\" value that can be used to determine the derated data setup time."
		set_parameter_property TIMING_BOARD_TDS_VIH Visible true
		set_parameter_property TIMING_BOARD_TDS_VIH Units picoseconds
		set_parameter_property TIMING_BOARD_TDS_VIH DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TDS_VIH ALLOWED_RANGES {-500:500}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDH integer 13
		set_parameter_property TIMING_BOARD_TDH DISPLAY_NAME "tDH CK/CK# Crossing to Vref"
		set_parameter_property TIMING_BOARD_TDH DESCRIPTION "For a given data and DK/DK# slew rate, the memory device data sheet provides a corresponding \"tDH CK/CK# Crossing to Vref\" value that can be used to determine the derated data hold time."
		set_parameter_property TIMING_BOARD_TDH Visible true
		set_parameter_property TIMING_BOARD_TDH Units picoseconds
		set_parameter_property TIMING_BOARD_TDH DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TDH ALLOWED_RANGES {0:2000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDH_VIH integer -50
		set_parameter_property TIMING_BOARD_TDH_VIH DISPLAY_NAME "tDH CK/CK# Crossing to VIH MIN"
		set_parameter_property TIMING_BOARD_TDH_VIH DESCRIPTION "For a given data and DK/DK# slew rate, the memory device data sheet provides a corresponding \"tDH CK/CK# Crossing to VIH MIN\" value that can be used to determine the derated data hold time."
		set_parameter_property TIMING_BOARD_TDH_VIH Visible true
		set_parameter_property TIMING_BOARD_TDH_VIH Units picoseconds
		set_parameter_property TIMING_BOARD_TDH_VIH DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TDH_VIH ALLOWED_RANGES {-500:500}
		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DERATE_METHOD String AUTO
		set_parameter_property TIMING_BOARD_DERATE_METHOD DISPLAY_NAME "Derating method"
		set_parameter_property TIMING_BOARD_DERATE_METHOD DESCRIPTION "Derating method"
		set_parameter_property TIMING_BOARD_DERATE_METHOD DISPLAY_HINT RADIO
		set_parameter_property TIMING_BOARD_DERATE_METHOD ALLOWED_RANGES {"AUTO:Use Altera's default settings" "SLEW_RATE:Specify slew rates to calculate setup and hold times" "MANUAL:Specify setup and hold times directly"}

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_CK_CKN_SLEW_RATE Float 2
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE DISPLAY_NAME "CK/CK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE DESCRIPTION "CK/CK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_SLEW_RATE Float 1
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE DISPLAY_NAME "Address and command slew rate"
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE DESCRIPTION "Address and command slew rate"
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DK_DKN_SLEW_RATE Float 2
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE DISPLAY_NAME "DK/DK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE DESCRIPTION "DK/DK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQ_SLEW_RATE Float 1
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE DISPLAY_NAME "DQ slew rate"
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE DESCRIPTION "DQ slew rate"
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED Float 2
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED DISPLAY_NAME "CK/CK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED DESCRIPTION "CK/CK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_SLEW_RATE_APPLIED Float 1
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE_APPLIED DISPLAY_NAME "Address and command slew rate"
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE_APPLIED DESCRIPTION "Address and command slew rate"
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE_APPLIED DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_AC_SLEW_RATE_APPLIED DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED Float 2
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED DISPLAY_NAME "DK/DK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED DESCRIPTION "DK/DK# slew rate (Differential)"
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQ_SLEW_RATE_APPLIED Float 1
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DISPLAY_NAME "DQ slew rate"
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DESCRIPTION "DQ slew rate"
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DISPLAY_UNITS "V/ns"
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIS integer 0
		set_parameter_property TIMING_BOARD_TIS DISPLAY_NAME "tIS"
		set_parameter_property TIMING_BOARD_TIS DESCRIPTION "Address and command setup time to CK"
		set_parameter_property TIMING_BOARD_TIS UNITS picoseconds
		set_parameter_property TIMING_BOARD_TIS DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIH integer 0
		set_parameter_property TIMING_BOARD_TIH DISPLAY_NAME "tIH"
		set_parameter_property TIMING_BOARD_TIH DESCRIPTION "Address and command hold time from CK"
		set_parameter_property TIMING_BOARD_TIH UNITS picoseconds
		set_parameter_property TIMING_BOARD_TIH DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDS integer 0
		set_parameter_property TIMING_BOARD_TDS DISPLAY_NAME "tDS"
		set_parameter_property TIMING_BOARD_TDS DESCRIPTION "Data setup time to DK"
		set_parameter_property TIMING_BOARD_TDS UNITS picoseconds
		set_parameter_property TIMING_BOARD_TDS DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDH integer 0
		set_parameter_property TIMING_BOARD_TDH DISPLAY_NAME "tDH"
		set_parameter_property TIMING_BOARD_TDH DESCRIPTION "Data hold time from DK"
		set_parameter_property TIMING_BOARD_TDH UNITS picoseconds
		set_parameter_property TIMING_BOARD_TDH DISPLAY_HINT columns:10

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIS_APPLIED integer 0
		set_parameter_property TIMING_BOARD_TIS_APPLIED DISPLAY_NAME "tIS"
		set_parameter_property TIMING_BOARD_TIS_APPLIED DESCRIPTION "Address and command setup time to CK"
		set_parameter_property TIMING_BOARD_TIS_APPLIED UNITS picoseconds
		set_parameter_property TIMING_BOARD_TIS_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TIS_APPLIED DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIH_APPLIED integer 0
		set_parameter_property TIMING_BOARD_TIH_APPLIED DISPLAY_NAME "tIH"
		set_parameter_property TIMING_BOARD_TIH_APPLIED DESCRIPTION "Address and command hold time from CK"
		set_parameter_property TIMING_BOARD_TIH_APPLIED UNITS picoseconds
		set_parameter_property TIMING_BOARD_TIH_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TIH_APPLIED DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDS_APPLIED integer 0
		set_parameter_property TIMING_BOARD_TDS_APPLIED DISPLAY_NAME "tDS"
		set_parameter_property TIMING_BOARD_TDS_APPLIED DESCRIPTION "Data setup time to DK"
		set_parameter_property TIMING_BOARD_TDS_APPLIED UNITS picoseconds
		set_parameter_property TIMING_BOARD_TDS_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TDS_APPLIED DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDH_APPLIED integer 0
		set_parameter_property TIMING_BOARD_TDH_APPLIED DISPLAY_NAME "tDH"
		set_parameter_property TIMING_BOARD_TDH_APPLIED DESCRIPTION "Data hold time from DK"
		set_parameter_property TIMING_BOARD_TDH_APPLIED UNITS picoseconds
		set_parameter_property TIMING_BOARD_TDH_APPLIED DISPLAY_HINT columns:10
		set_parameter_property TIMING_BOARD_TDH_APPLIED DERIVED TRUE
	}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW integer 20
	set_parameter_property TIMING_BOARD_SKEW DISPLAY_NAME "Maximum board skew (data)"
	set_parameter_property TIMING_BOARD_SKEW DESCRIPTION "Maximum expected skew on data signals between FPGA and memory device."
	set_parameter_property TIMING_BOARD_SKEW Visible false
	set_parameter_property TIMING_BOARD_SKEW UNITS picoseconds
	set_parameter_property TIMING_BOARD_SKEW ALLOWED_RANGES {0:5000}
		
	return 1
}


proc ::alt_mem_if::gui::common_rldram_phy::_create_phy_parameters_gui {} {

	variable rldram_mode

	_dprint 1 "Preparing to create PHY GUI in common_rldram_phy"
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set rldram_mode_user "RLDRAM II"
		add_display_item "" id2 TEXT "<html>Generation of the $rldram_mode_user Controller with UniPHY produces unencrypted PHY and Controller HDL, <br>constraint scripts, an example design and a testbench for simulation.<br>"
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set rldram_mode_user "RLDRAM 3"
		add_display_item "" id2 TEXT "<html>Generation of the $rldram_mode_user UniPHY IP core (without controller) produces unencrypted PHY HDL, <br>constraint scripts, an example design and a testbench for simulation.<br>"
	}
	
	
	add_display_item "" "PHY Settings" GROUP "tab"
	
	add_display_item "PHY Settings" "General Settings" GROUP 
	add_display_item "General Settings" SPEED_GRADE PARAMETER
	add_display_item "General Settings" IS_ES_DEVICE PARAMETER
	add_display_item "General Settings" HARD_PHY PARAMETER
	add_display_item "General Settings" PHY_ONLY PARAMETER

	add_display_item "PHY Settings" "Clocks" GROUP 
	add_display_item "Clocks" MEM_CLK_FREQ PARAMETER
	add_display_item "Clocks" PLL_MEM_CLK_FREQ PARAMETER
	add_display_item "Clocks" REF_CLK_FREQ PARAMETER
	add_display_item "Clocks" RATE PARAMETER
	add_display_item "Clocks" PLL_AFI_CLK_FREQ PARAMETER
	add_display_item "Clocks" EXPORT_AFI_HALF_CLK PARAMETER

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		add_display_item "PHY Settings" "Achieved Clocks" GROUP 
		set_parameter_property PLL_WRITE_CLK_FREQ VISIBLE true
		set_parameter_property PLL_ADDR_CMD_CLK_FREQ VISIBLE true
		set_parameter_property PLL_AFI_HALF_CLK_FREQ VISIBLE true
		set_parameter_property PLL_AFI_CLK_PHASE_PS VISIBLE true
		set_parameter_property PLL_AFI_CLK_PHASE_DEG VISIBLE true
		set_parameter_property PLL_MEM_CLK_PHASE_PS VISIBLE true
		set_parameter_property PLL_MEM_CLK_PHASE_DEG VISIBLE true
		set_parameter_property PLL_WRITE_CLK_PHASE_PS VISIBLE true
		set_parameter_property PLL_WRITE_CLK_PHASE_DEG VISIBLE true
		set_parameter_property PLL_ADDR_CMD_CLK_PHASE_PS VISIBLE true
		set_parameter_property PLL_ADDR_CMD_CLK_PHASE_DEG VISIBLE true
		set_parameter_property PLL_AFI_HALF_CLK_PHASE_PS VISIBLE true
		set_parameter_property PLL_AFI_HALF_CLK_PHASE_DEG VISIBLE true
		
		add_display_item "Achieved Clocks" PLL_AFI_CLK_PHASE_PS PARAMETER
		add_display_item "Achieved Clocks" PLL_AFI_CLK_PHASE_DEG PARAMETER
		add_display_item "Achieved Clocks" PLL_MEM_CLK_PHASE_PS PARAMETER
		add_display_item "Achieved Clocks" PLL_MEM_CLK_PHASE_DEG PARAMETER
		add_display_item "Achieved Clocks" PLL_WRITE_CLK_FREQ PARAMETER
		add_display_item "Achieved Clocks" PLL_WRITE_CLK_PHASE_PS PARAMETER
		add_display_item "Achieved Clocks" PLL_WRITE_CLK_PHASE_DEG PARAMETER
		add_display_item "Achieved Clocks" PLL_ADDR_CMD_CLK_FREQ PARAMETER
		add_display_item "Achieved Clocks" PLL_ADDR_CMD_CLK_PHASE_PS PARAMETER
		add_display_item "Achieved Clocks" PLL_ADDR_CMD_CLK_PHASE_DEG PARAMETER
		add_display_item "Achieved Clocks" PLL_AFI_HALF_CLK_FREQ PARAMETER
		add_display_item "Achieved Clocks" PLL_AFI_HALF_CLK_PHASE_PS PARAMETER
		add_display_item "Achieved Clocks" PLL_AFI_HALF_CLK_PHASE_DEG PARAMETER
	}
	
	add_display_item "PHY Settings" "Advanced PHY Settings" GROUP
	add_display_item "Advanced PHY Settings" COMMAND_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" C2P_WRITE_CLOCK_ADD_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" P2C_READ_CLOCK_ADD_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" ACV_PHY_CLK_ADD_FR_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" IO_STANDARD PARAMETER
	add_display_item "Advanced PHY Settings" PLL_SHARING_MODE PARAMETER
	add_display_item "Advanced PHY Settings" NUM_PLL_SHARING_INTERFACES PARAMETER
	add_display_item "Advanced PHY Settings" DLL_SHARING_MODE PARAMETER
	add_display_item "Advanced PHY Settings" NUM_DLL_SHARING_INTERFACES PARAMETER
	add_display_item "Advanced PHY Settings" OCT_SHARING_MODE PARAMETER
	add_display_item "Advanced PHY Settings" NUM_OCT_SHARING_INTERFACES PARAMETER
	add_display_item "Advanced PHY Settings" HCX_COMPAT_MODE PARAMETER
	add_display_item "Advanced PHY Settings" PLL_LOCATION PARAMETER
	add_display_item "Advanced PHY Settings" SEQUENCER_TYPE PARAMETER
	
}


proc ::alt_mem_if::gui::common_rldram_phy::_create_diagnostics_gui {} {

	variable ddr_mode

	_dprint 1 "Preparing to create PHY diagnostics GUI in common_rldram_phy"

	add_display_item "" "Diagnostics" GROUP "tab"
	add_display_item "Diagnostics" "Simulation Options" GROUP
	add_display_item "Simulation Options" CALIBRATION_MODE PARAMETER
	add_display_item "Simulation Options" SKIP_MEM_INIT PARAMETER
	add_display_item "Simulation Options" MEM_VERBOSE PARAMETER

	add_display_item "Diagnostics" "Debugging Options" GROUP
	alt_mem_if::gui::uniphy_debug::add_debug_display_items "Debugging Options"

}


proc ::alt_mem_if::gui::common_rldram_phy::_create_board_settings_parameters_gui {} {

	variable rldram_mode
	
	_dprint 1 "Preparing to board settings GUI in common_rldram_phy"
	
	add_display_item "" "Board Settings" GROUP "tab"
	add_display_item "Board Settings" bs1 TEXT "<html>The Board Settings panel is used to model the UniPHY interface board level effects in the timing analysis.<br>"
	add_display_item "Board Settings" bs2 TEXT "<html>The following data should be based on board simulation and on the memory device data sheet:<br>"
	
	add_display_item "Board Settings" "Setup and Hold Derating" GROUP
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		add_display_item "Setup and Hold Derating" bs3 TEXT "<html>The slew rate of the output signals affects the setup and hold times of the memory device.<br> \
		Enter the input slew rate derating parameters from the device data sheet to obtain the <br> \
		derated setup and hold times<br>"
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TAS parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TAS_VIH parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TAH parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TAH_VIH parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDS parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDS_VIH parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDH parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDH_VIH parameter
		add_display_item "Setup and Hold Derating" DERATED_TAS parameter
		add_display_item "Setup and Hold Derating" DERATED_TAH parameter
		add_display_item "Setup and Hold Derating" DERATED_TDS parameter
		add_display_item "Setup and Hold Derating" DERATED_TDH parameter
	
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		add_display_item "Setup and Hold Derating" bs11 TEXT "<html>The slew rate of the output signals affects the setup and hold times of the memory device.<br>"
		add_display_item "Setup and Hold Derating" bs12 TEXT "<html>You can specify the slew rate of the output signals to refer to  their effect on the setup and hold times of<br>both the address and command signals and the DQ signals, or specify the setup and hold times directly.<br>"
		add_display_item "Setup and Hold Derating" TIMING_BOARD_DERATE_METHOD parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_CK_CKN_SLEW_RATE parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_AC_SLEW_RATE parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_DK_DKN_SLEW_RATE parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_DQ_SLEW_RATE parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_AC_SLEW_RATE_APPLIED parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_DQ_SLEW_RATE_APPLIED parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TIS parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TIH parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDS parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDH parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TIS_APPLIED parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TIH_APPLIED parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDS_APPLIED parameter
		add_display_item "Setup and Hold Derating" TIMING_BOARD_TDH_APPLIED parameter	
	}
	
	add_display_item "Board Settings" "Channel Signal Integrity" GROUP
	add_display_item "Channel Signal Integrity" bs4 TEXT "<html>Channel Signal Integrity is a measure of the distortion of the eye due to intersymbol interference<br>or crosstalk or other effects. Typically when using a device depth greater than 1<br>there is an increase in the channel loss as there are multiple stubs causing<br>reflections. Please perform you channel signal integrity simulations and enter the extra channel<br>uncertainty."		
	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_SU parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_H parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DQ_EYE_REDUCTION parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_READ_DQ_EYE_REDUCTION parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME parameter	
	
	add_display_item "Board Settings" "Board Skews" GROUP
	add_display_item "Board Skews" bs5 TEXT "<html>PCB traces can have skews between them that can cause timing margins to be reduced.<br>"
	add_display_item "Board Skews" PACKAGE_DESKEW parameter	
	add_display_item "Board Skews" AC_PACKAGE_DESKEW parameter		
	add_display_item "Board Skews" TIMING_BOARD_MAX_CK_DELAY parameter
	add_display_item "Board Skews" TIMING_BOARD_MAX_DQS_DELAY parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_CKDQS_DIMM_MIN parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_CKDQS_DIMM_MAX parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_BETWEEN_DIMMS parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_WITHIN_DQS parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_BETWEEN_DQS parameter
	add_display_item "Board Skews" TIMING_ADDR_CTRL_SKEW PARAMETER
	add_display_item "Board Skews" TIMING_BOARD_AC_TO_CK_SKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_DATA_TO_DK_SKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_DATA_TO_QK_SKEW parameter		
	
	return 1
}

proc ::alt_mem_if::gui::common_rldram_phy::_create_interface_parameters_gui {} {

	_dprint 1 "Preparing to create interface GUI in common_rldram_phy"
	
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
	
	return 1
}


proc ::alt_mem_if::gui::common_rldram_phy::_derive_parameters {} {

	variable rldram_mode
	
	_dprint 1 "Preparing to derive parametres for common_rldram_phy"
	
	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set_parameter_property PHY_ONLY ENABLED false
	} else {
		set_parameter_property PHY_ONLY ENABLED true
	}	
	
	set_parameter_value ADDR_CTRL_SKEW [expr {[get_parameter_value TIMING_ADDR_CTRL_SKEW] / 1000.0}]
	
	set_parameter_value PLL_PHASE_COUNTER_WIDTH 4

	set_parameter_value VCALIB_COUNT_WIDTH 2

	set_parameter_value QVLD_EXTRA_FLOP_STAGES 0

	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set_parameter_value USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE true

		set_parameter_value READ_VALID_FIFO_SIZE 32
	}
	
	if {([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		 [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 ||
		 [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || 
		 [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)} {
		set seriesv 1
	} else {
		set seriesv 0
	}	
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGX"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAIIGZ"] == 0} {
		set_parameter_value HR_DDIO_OUT_HAS_THREE_REGS true
	} else {
		set_parameter_value HR_DDIO_OUT_HAS_THREE_REGS false
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		set_parameter_value PHY_CLKBUF true
		set_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK true
		set_parameter_value USE_LDC_FOR_ADDR_CMD true
		set_parameter_value REGISTER_C2P true
	} else {
		set_parameter_value PHY_CLKBUF false
		set_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK false
		set_parameter_value USE_LDC_FOR_ADDR_CMD false
		set_parameter_value REGISTER_C2P false
	}
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		set mem_clk_period [ expr {1000000.0 / [get_parameter_value MEM_CLK_FREQ]} ]
		set mem_clk_ps [ expr {round($mem_clk_period)} ]

		if {$mem_clk_ps > 3332} {
			set_parameter_value USE_DR_CLK true
			set_parameter_value DLL_USE_DR_CLK true
		} else {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		}
	}		
    
	set dq_per_dqs [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value MEM_IF_READ_DQS_WIDTH]} ]
	
	if {$dq_per_dqs <= 9} {
		set target_dq_per_subgroup $dq_per_dqs
	} else {
		set target_dq_per_subgroup 1
	}
	set dq_per_dqs_mod_target_dqs [expr {$dq_per_dqs % $target_dq_per_subgroup}]
	if { $dq_per_dqs_mod_target_dqs == 0 } {
		set_parameter_value NUM_SUBGROUP_PER_READ_DQS [expr {$dq_per_dqs / $target_dq_per_subgroup}]
	} else {
		set_parameter_value NUM_SUBGROUP_PER_READ_DQS $dq_per_dqs
	}
	
	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 0
		set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX false
		set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 0
		
		set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS [expr {([get_parameter_value MEM_T_WL]-1) % 4}]
		
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true"] == 0 ||
			[string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true"] == 0} {
			if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
				set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS [expr {1 - ([get_parameter_value MEM_T_WL] % 2)}]
			} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
				set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS [expr {[get_parameter_value MEM_T_WL] % 2}]
			}
			set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 0
		} else {
			set effective_wl [get_parameter_value MEM_T_WL]
			if {[string compare -nocase [get_parameter_value HR_DDIO_OUT_HAS_THREE_REGS] "false"] == 0} {
				incr effective_wl 1
			}
			set_parameter_value NUM_AC_FR_CYCLE_SHIFTS [expr {1 - ($effective_wl % 2)}]
			set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS 0
		}
	
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 1
			set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX false
		} else {
			if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
				set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 2
				set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX true
			} else {
				set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 1
				set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX false
			}		
		}
	} else {
		set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 0
		set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS 0
	
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 1
			set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX false
		} else {
			set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 1
			set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX true
		}
	}
	
	if { $seriesv == 1 } {
		if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_disable_read_after_write_calibration] == 1 } {
			set_parameter_value PERFORM_READ_AFTER_WRITE_CALIBRATION false
		} else {
			set_parameter_value PERFORM_READ_AFTER_WRITE_CALIBRATION true
		}
	} else {
		if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_read_after_write_calibration] == 1 } {
			set_parameter_value PERFORM_READ_AFTER_WRITE_CALIBRATION true
		} else {
			set_parameter_value PERFORM_READ_AFTER_WRITE_CALIBRATION false
		}
	}
	
	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		if {[get_parameter_value MEM_BURST_LENGTH] == 2} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
			set_parameter_value MRS_BURST_LENGTH 0
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
			set_parameter_value MRS_BURST_LENGTH 1
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
			set_parameter_value MRS_BURST_LENGTH 2
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[get_parameter_value MEM_BURST_LENGTH] == 2} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
			set_parameter_value MRS_BURST_LENGTH 0
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
			set_parameter_value MRS_BURST_LENGTH 1
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 1
			set_parameter_value MRS_BURST_LENGTH 2
		}
	} else {
		if {[get_parameter_value MEM_BURST_LENGTH] == 2} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
			set_parameter_value MRS_BURST_LENGTH 0
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 1
			set_parameter_value MRS_BURST_LENGTH 1
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 2
			set_parameter_value MRS_BURST_LENGTH 2
		}
	}

	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set ac_rom_mr0 0
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 3 [get_parameter_value MRS_CONFIGURATION]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 3 2 [get_parameter_value MRS_BURST_LENGTH]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 5 1 [get_parameter_value MRS_ADDRESS_MUX]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 7 1 [get_parameter_value MRS_DLL_RESET]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 8 1 [get_parameter_value MRS_IMPEDANCE_MATCHING]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 9 1 [get_parameter_value MRS_ODT]]
		set_parameter_value AC_ROM_MR0 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_ADDR_WIDTH_MIN]]
		
		set ac_rom_mr0_calib_dll_off $ac_rom_mr0
		set ac_rom_mr0_calib_dll_off [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_calib_dll_off 3 2 2]
		set ac_rom_mr0_calib_dll_off [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_calib_dll_off 7 1 0]
		set_parameter_value AC_ROM_MR0_CALIB_DLL_OFF [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0_calib_dll_off [get_parameter_value MEM_ADDR_WIDTH_MIN]]

		set ac_rom_mr0_calib_dll_on $ac_rom_mr0
		set ac_rom_mr0_calib_dll_on [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_calib_dll_on 3 2 2]
		set ac_rom_mr0_calib_dll_on [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_calib_dll_on 7 1 1]
		set_parameter_value AC_ROM_MR0_CALIB_DLL_ON [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0_calib_dll_on [get_parameter_value MEM_ADDR_WIDTH_MIN]]
		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set ac_rom_mr0 0
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 4 [get_parameter_value MRS_T_RC]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 4 4 [get_parameter_value MRS_DATA_LATENCY]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 8 1 [get_parameter_value MRS_DLL_ENABLE]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 9 1 [get_parameter_value MRS_ADDRESS_MUX]]
		if {[get_parameter_value MEM_IF_CS_WIDTH] > 1} {
			set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 10 2 1]  
		}
		set_parameter_value AC_ROM_MR0 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_ADDR_WIDTH_MIN]]
		
		set ac_rom_mr0_quad_rank 0
		set ac_rom_mr0_quad_rank [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_quad_rank 0 4 [get_parameter_value MRS_T_RC]]
		set ac_rom_mr0_quad_rank [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_quad_rank 4 4 [get_parameter_value MRS_DATA_LATENCY]]
		set ac_rom_mr0_quad_rank [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_quad_rank 8 1 [get_parameter_value MRS_DLL_ENABLE]]
		set ac_rom_mr0_quad_rank [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_quad_rank 9 1 [get_parameter_value MRS_ADDRESS_MUX]]
		if {[get_parameter_value MEM_IF_CS_WIDTH] > 1} {
			set ac_rom_mr0_quad_rank [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0_quad_rank 10 2 2]  
		}
		set_parameter_value AC_ROM_MR0_QUAD_RANK [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0_quad_rank [get_parameter_value MEM_ADDR_WIDTH_MIN]]
		
		set ac_rom_mr1 0
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 0 2 [get_parameter_value MRS_IMPEDANCE_MATCHING]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 2 3 [get_parameter_value MRS_ODT]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 5 1 [get_parameter_value MRS_DLL_RESET]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 6 1 [get_parameter_value MRS_ZQ_CALIB_SELECTION]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 7 1 [get_parameter_value MRS_ZQ_CALIB_ENABLE]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 8 1 [get_parameter_value MRS_AREF_PROTOCOL]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 9 2 [get_parameter_value MRS_BURST_LENGTH]]
		set_parameter_value AC_ROM_MR1 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1 [get_parameter_value MEM_ADDR_WIDTH_MIN]]

		set ac_rom_mr1_calib $ac_rom_mr1
		set ac_rom_mr1_calib [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1_calib 9 2 0]
		set ac_rom_mr1_calib [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1_calib 5 1 1]
		set ac_rom_mr1_calib [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1_calib 6 1 1]
		set ac_rom_mr1_calib [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1_calib 7 1 1]
		set ac_rom_mr1_calib [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1_calib 8 1 0]
		set_parameter_value AC_ROM_MR1_CALIB [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1_calib [get_parameter_value MEM_ADDR_WIDTH_MIN]]
		
		set ac_rom_mr2 0
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 3 2 [get_parameter_value MRS_WRITE_PROTOCOL]]
		set_parameter_value AC_ROM_MR2 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr2 [get_parameter_value MEM_ADDR_WIDTH_MIN]]
		
		set ac_rom_mr2_calib $ac_rom_mr2
		set ac_rom_mr2_calib [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2_calib 3 2 0]
		set_parameter_value AC_ROM_MR2_CALIB [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr2_calib [get_parameter_value MEM_ADDR_WIDTH_MIN]]
	}
	
	set qvld_wr_address_offset [expr {[get_parameter_value MEM_T_RL] - [get_parameter_value QVLD_EXTRA_FLOP_STAGES]}]
	if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[string compare -nocase [get_parameter_value USE_HARD_READ_FIFO] "false"] == 0} {
			incr qvld_wr_address_offset -1
		}
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
			incr qvld_wr_address_offset 2
		}
		if {[string compare -nocase [get_parameter_value USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE] "true"] == 0} {
			incr qvld_wr_address_offset -1
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		incr qvld_wr_address_offset -3
	}
	
	if {[string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true"] == 0} {
		incr qvld_wr_address_offset 2
	}
	incr qvld_wr_address_offset [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]
	set_parameter_value QVLD_WR_ADDRESS_OFFSET $qvld_wr_address_offset

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		set_parameter_property CALIBRATION_MODE ENABLED true
	} else {
		set_parameter_property CALIBRATION_MODE ENABLED false
	}

	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		set vfifo_offset 8
		set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 6}]
		set_parameter_value CALIB_LFIFO_OFFSET [expr {([get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 3) / 4}]
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set vfifo_offset 3
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {[get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 1}]
		} else {
			set vfifo_offset 4
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 3}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {([get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 3) / 2}]
		}
	} else {
		set vfifo_offset 0
		set_parameter_value CALIB_VFIFO_OFFSET [expr {($vfifo_offset + [get_parameter_value MEM_T_RL]) * 2}]
		set_parameter_value CALIB_LFIFO_OFFSET [expr {[get_parameter_value MEM_T_RL] + 2}]
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		set mem_clk_ps_real [expr {[get_parameter_value MEM_CLK_PS] * 1.0}]
		set delay_chain_length_real [expr {[get_parameter_value DELAY_CHAIN_LENGTH] * 1.0}]
		set_parameter_value DELAY_PER_OPA_TAP [expr {int($mem_clk_ps_real / $delay_chain_length_real)}]
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			set_parameter_value DELAY_PER_DCHAIN_TAP 11
			set_parameter_value DELAY_PER_DQS_EN_DCHAIN_TAP 11
		} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
			  [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set_parameter_value DELAY_PER_DCHAIN_TAP 25
			set_parameter_value DELAY_PER_DQS_EN_DCHAIN_TAP 25
		} else {
			set_parameter_value DELAY_PER_DCHAIN_TAP 50
			set_parameter_value DELAY_PER_DQS_EN_DCHAIN_TAP 50
		}
	}

	if {[string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true"] == 0} {
		set_parameter_value RESERVED_PINS_FOR_DK_GROUP false
		set_parameter_value MEM_IF_RESERVED_PINS_WIDTH -1
	} else {
		if {([string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0 && $dq_per_dqs <= 9) &&
			!([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0)} {
			set_parameter_value RESERVED_PINS_FOR_DK_GROUP true
			set_parameter_value MEM_IF_RESERVED_PINS_WIDTH [get_parameter_value MEM_IF_WRITE_DQS_WIDTH]
		} else {
			set_parameter_value RESERVED_PINS_FOR_DK_GROUP false
			set_parameter_value MEM_IF_RESERVED_PINS_WIDTH -1
		}
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set_parameter_value DUPLICATE_PLL_FOR_PHY_CLK true
	} else {
		set_parameter_value DUPLICATE_PLL_FOR_PHY_CLK false
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
	    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set_parameter_value MAX_LATENCY_COUNT_WIDTH 5
	} elseif {[get_parameter_value FORCE_MAX_LATENCY_COUNT_WIDTH] > 0} {
		set_parameter_value MAX_LATENCY_COUNT_WIDTH [get_parameter_value FORCE_MAX_LATENCY_COUNT_WIDTH]
	} else {
		if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
			set_parameter_value MAX_LATENCY_COUNT_WIDTH 5
		} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
			set_parameter_value MAX_LATENCY_COUNT_WIDTH 4
		} elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			set_parameter_value MAX_LATENCY_COUNT_WIDTH 4
		} else {
			_error "Fatal Error: Unknown rate [get_parameter_value RATE]"
		}
	}
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set slew_rates [list TIMING_BOARD_CK_CKN_SLEW_RATE \
							 TIMING_BOARD_AC_SLEW_RATE \
							 TIMING_BOARD_DK_DKN_SLEW_RATE \
							 TIMING_BOARD_DQ_SLEW_RATE]
							 
		set slew_rates_applied [list TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED \
									 TIMING_BOARD_AC_SLEW_RATE_APPLIED \
									 TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED \
									 TIMING_BOARD_DQ_SLEW_RATE_APPLIED]
									 
		set setup_hold [list TIMING_BOARD_TIS \
							 TIMING_BOARD_TIH \
							 TIMING_BOARD_TDS \
							 TIMING_BOARD_TDH]
							 
		set setup_hold_applied [list TIMING_BOARD_TIS_APPLIED \
									 TIMING_BOARD_TIH_APPLIED \
									 TIMING_BOARD_TDS_APPLIED \
									 TIMING_BOARD_TDH_APPLIED]

		if {[string compare -nocase [get_parameter_value TIMING_BOARD_DERATE_METHOD] "MANUAL"] == 0} {
			foreach param [concat $slew_rates $slew_rates_applied $setup_hold_applied ] {
				set_parameter_property $param VISIBLE FALSE
			}
			foreach param [concat $setup_hold ] {
				set_parameter_property $param VISIBLE TRUE
			}
		} elseif {[string compare -nocase [get_parameter_value TIMING_BOARD_DERATE_METHOD] "SLEW_RATE"] == 0} {
			foreach param [concat $slew_rates_applied $setup_hold ] {
				set_parameter_property $param VISIBLE FALSE
			}
			foreach param [concat $slew_rates $setup_hold_applied ] {
				set_parameter_property $param VISIBLE TRUE
			}
		} else {
			foreach param [concat $slew_rates $setup_hold ] {
				set_parameter_property $param VISIBLE FALSE
			}
			foreach param [concat $slew_rates_applied $setup_hold_applied ] {
				set_parameter_property $param VISIBLE TRUE
			}
		}	
	}
}


proc ::alt_mem_if::gui::common_rldram_phy::_derive_board_settings_parameters {} {

	variable rldram_mode
	
	_dprint 1 "Preparing to derive board settings parameters for common_rldram_phy"
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {

		set_parameter_value DERATED_TAS [expr {[get_parameter_value TIMING_TAS] + [get_parameter_value TIMING_BOARD_TAS] + [get_parameter_value TIMING_BOARD_TAS_VIH]}]
		set_parameter_value DERATED_TDS [expr {[get_parameter_value TIMING_TDS] + [get_parameter_value TIMING_BOARD_TDS] + [get_parameter_value TIMING_BOARD_TDS_VIH]}]
		set_parameter_value DERATED_TAH [expr {[get_parameter_value TIMING_TAH] + [get_parameter_value TIMING_BOARD_TAH] + [get_parameter_value TIMING_BOARD_TAH_VIH]}]
		set_parameter_value DERATED_TDH [expr {[get_parameter_value TIMING_TDH] + [get_parameter_value TIMING_BOARD_TDH] + [get_parameter_value TIMING_BOARD_TDH_VIH]}]

	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
	
		
		if {[get_parameter_value TIMING_BOARD_SKEW_BETWEEN_DIMMS] < 0} {
			_error "The maximum delay difference between DIMMs/devices must be greater than or equal to 0"
		} 
		
		if {[string compare -nocase [get_parameter_value TIMING_BOARD_DERATE_METHOD] SLEW_RATE] == 0} {
			set_parameter_value TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_CK_CKN_SLEW_RATE]
			set_parameter_value TIMING_BOARD_AC_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_AC_SLEW_RATE]
			set_parameter_value TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_DK_DKN_SLEW_RATE]
			set_parameter_value TIMING_BOARD_DQ_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_DQ_SLEW_RATE]
		} else {
			set_parameter_value TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED 2.0
			set_parameter_value TIMING_BOARD_AC_SLEW_RATE_APPLIED 1.0
			set_parameter_value TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED 2.0
			set_parameter_value TIMING_BOARD_DQ_SLEW_RATE_APPLIED 1.0
		}

		if {[string compare -nocase [get_parameter_value TIMING_BOARD_DERATE_METHOD] "MANUAL"] == 0} {
			set t_is [get_parameter_value TIMING_BOARD_TIS]
			set t_ih [get_parameter_value TIMING_BOARD_TIH]
			set t_ds [get_parameter_value TIMING_BOARD_TDS]
			set t_dh [get_parameter_value TIMING_BOARD_TDH]
			if {$t_is < 0 || $t_ih < 0 || $t_ds < 0 || $t_dh < 0} {
				_error "Setup and hold times must be greater than or equal to 0"
			} else {
				set_parameter_value TIMING_BOARD_TIS_APPLIED $t_is
				set_parameter_value TIMING_BOARD_TIH_APPLIED $t_ih
				set_parameter_value TIMING_BOARD_TDS_APPLIED $t_ds
				set_parameter_value TIMING_BOARD_TDH_APPLIED $t_dh
			}
		} else {
			set mem_fmax [get_parameter_value MEM_CLK_FREQ_MAX]
			set t_is_base [get_parameter_value TIMING_TIS]
			set t_ih_base [get_parameter_value TIMING_TIH]
			set t_ds_base [get_parameter_value TIMING_TDS]
			set t_dh_base [get_parameter_value TIMING_TDH]
			set ck_ckn_slew_rate [get_parameter_value TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED]
			set ac_slew_rate [get_parameter_value TIMING_BOARD_AC_SLEW_RATE_APPLIED]
			set dk_dkn_slew_rate [get_parameter_value TIMING_BOARD_DK_DKN_SLEW_RATE_APPLIED]
			set dq_slew_rate [get_parameter_value TIMING_BOARD_DQ_SLEW_RATE_APPLIED]
			if {$ck_ckn_slew_rate > 0 && $ac_slew_rate > 0 && $dk_dkn_slew_rate > 0 && $dq_slew_rate > 0} {
				set_parameter_value TIMING_BOARD_TIS_APPLIED [_derate_t_is $mem_fmax $t_is_base $ac_slew_rate $ck_ckn_slew_rate]
				set_parameter_value TIMING_BOARD_TIH_APPLIED [_derate_t_ih $mem_fmax $t_ih_base $ac_slew_rate $ck_ckn_slew_rate]
				set_parameter_value TIMING_BOARD_TDS_APPLIED [_derate_t_ds $mem_fmax $t_ds_base $dq_slew_rate $dk_dkn_slew_rate]
				set_parameter_value TIMING_BOARD_TDH_APPLIED [_derate_t_dh $mem_fmax $t_dh_base $dq_slew_rate $dk_dkn_slew_rate]
			} else {
				_error "Slew rates must be greater than 0 V/ns"
			}
		}
	}
}

proc ::alt_mem_if::gui::common_rldram_phy::derive_ifdef_parameters {ifdef_array} {
	
	variable rldram_mode
	
	_dprint 1 "Preparing to derive ifdef parameters for common_rldram_phy"
	
	upvar $ifdef_array ifdef_db_array

	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set ifdef_db_array(IFDEF_RLDRAMII) true

		set dq_width_per_device [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value DEVICE_WIDTH]}]
		if {$dq_width_per_device == 36} {
			set ifdef_db_array(IFDEF_RLDRAMII_X18) false
			set ifdef_db_array(IFDEF_RLDRAMII_X36) true
			set ifdef_db_array(IFDEF_RLDRAMII_X18_OR_X36) true
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK) false
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM) true
		} elseif {$dq_width_per_device == 18} {
			set ifdef_db_array(IFDEF_RLDRAMII_X18) true
			set ifdef_db_array(IFDEF_RLDRAMII_X36) false
			set ifdef_db_array(IFDEF_RLDRAMII_X18_OR_X36) true
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK) true
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM) true
		} else {
			set ifdef_db_array(IFDEF_RLDRAMII_X18) false
			set ifdef_db_array(IFDEF_RLDRAMII_X36) false
			set ifdef_db_array(IFDEF_RLDRAMII_X18_OR_X36) false
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK) false
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM) false
		}		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set ifdef_db_array(IFDEF_RLDRAM3) true
		
		set dq_width_per_device [expr {[get_parameter_value MEM_IF_DQ_WIDTH] / [get_parameter_value DEVICE_WIDTH]}]
		if {$dq_width_per_device == 36} {
			set ifdef_db_array(IFDEF_RLDRAM3_X36) true
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK) true
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM) true
		} else {
			set ifdef_db_array(IFDEF_RLDRAM3_X36) false
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK) false
			set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM) false
		}
	}
	
	set ifdef_db_array(IFDEF_RLDRAMX) true
	
	set ifdef_db_array(IFDEF_DQ_DDR) true
	
	set ifdef_db_array(IFDEF_BIDIR_DQ_BUS) true

	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		set ifdef_db_array(IFDEF_MEM_IF_DM_PINS_EN) true
	} else {
		set ifdef_db_array(IFDEF_MEM_IF_DM_PINS_EN) false
	}

	set ifdef_db_array(IFDEF_MEM_IF_DQSN_EN) true
	
	if {[get_parameter_value MEM_CS_WIDTH] == 1} {
		set ifdef_db_array(IFDEF_CTL_CS_WIDTH_IS_ONE) true
	} else {
		set ifdef_db_array(IFDEF_CTL_CS_WIDTH_IS_ONE) false
	}
	
	if {[string compare -nocase [get_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX] "true"] == 0} {
		set ifdef_db_array(IFDEF_ADDR_CMD_PATH_FLOP_STAGE_POST_MUX) true
	} else {
		set ifdef_db_array(IFDEF_ADDR_CMD_PATH_FLOP_STAGE_POST_MUX) false
	}
		
	set ifdef_db_array(IFDEF_VFIFO_FULL_RATE) false
	set ifdef_db_array(IFDEF_VFIFO_HALF_RATE) false
	set ifdef_db_array(IFDEF_VFIFO_QUARTER_RATE) false
	if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		set ifdef_db_array(IFDEF_VFIFO_FULL_RATE) true
	}
	if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		set ifdef_db_array(IFDEF_VFIFO_HALF_RATE) true
	}
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		set ifdef_db_array(IFDEF_VFIFO_QUARTER_RATE) true
	}

	set ifdef_db_array(IFDEF_USE_IO_CLOCK_DIVIDER) false
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0 ||
		    [string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			set ifdef_db_array(IFDEF_USE_IO_CLOCK_DIVIDER) true
		}
	}

	set ifdef_db_array(IFDEF_CALIBRATION_MODE_FULL) false
	set ifdef_db_array(IFDEF_CALIBRATION_MODE_QUICK) false
	set ifdef_db_array(IFDEF_CALIBRATION_MODE_SKIP) false
	if {[string compare -nocase [get_parameter_value CALIBRATION_MODE] "FULL"] == 0} {
		set ifdef_db_array(IFDEF_CALIBRATION_MODE_FULL) true
	} elseif {[string compare -nocase [get_parameter_value CALIBRATION_MODE] "QUICK"] == 0} {
		set ifdef_db_array(IFDEF_CALIBRATION_MODE_QUICK) true
	} else {
		set ifdef_db_array(IFDEF_CALIBRATION_MODE_SKIP) true
	}
	
	set ifdef_db_array(IFDEF_DUPLICATE_PLL_FOR_PHY_CLK) [get_parameter_value DUPLICATE_PLL_FOR_PHY_CLK]
}

proc ::alt_mem_if::gui::common_rldram_phy::_table_delta_tIS {} {
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {{75 75 75 83 91 99 107 115} \
				{50 50 50 58 66 74 82 90} \
				{0 0 0 8 16 24 32 40} \
				{0 0 0 8 16 24 32 40} \
				{0 0 0 8 16 24 32 40} \
				{0 0 0 8 16 24 32 40} \
				{-1 -1 -1 7 15 23 31 39} \
				{-10 -10 -10 -2 6 14 22 30} \
				{-25 -25 -25 -17 -9 -1 7 15}}
	} else {
		_error "Fatal Error: Unknown RLDRAM mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_rldram_phy::_table_delta_tIH {} {
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {{50 50 50 58 66 74 84 100} \
				{34 34 34 42 50 58 68 84} \
				{0 0 0 8 16 24 34 50} \
				{-4 -4 -4 4 12 20 30 46} \
				{-10 -10 -10 -2 6 14 24 40} \
				{-16 -16 -16 -8 0 8 18 34} \
				{-26 -26 -26 -18 -10 -2 8 24} \
				{-40 -40 -40 -32 -24 -16 -6 10} \
				{-60 -60 -60 -52 -44 -36 -26 -10}}
	} else {
		_error "Fatal Error: Unknown RLDRAM mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_rldram_phy::_table_delta_tDS {} {
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {{75 75 75 999 999 999 999 999} \
				{50 50 50 58 999 999 999 999} \
				{0 0 0 8 16 999 999 999} \
				{-999 0 0 8 16 24 999 999} \
				{-999 -999 0 8 16 24 32 999} \
				{-999 -999 -999 8 16 24 32 40} \
				{-999 -999 -999 -999 15 23 31 39} \
				{-999 -999 -999 -999 -999 14 22 30} \
				{-999 -999 -999 -999 -999 -999 7 15}}
	} else {
		_error "Fatal Error: Unknown DDR mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_rldram_phy::_table_delta_tDH {} {
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {{50 50 50 999 999 999 999 999} \
				{34 34 34 42 999 999 999 999} \
				{0 0 0 8 16 999 999 999} \
				{-999 -4 -4 4 12 20 999 999} \
				{-999 -999 -10 -2 6 14 24 999} \
				{-999 -999 -999 -8 0 8 18 34} \
				{-999 -999 -999 -999 -10 -2 8 24} \
				{-999 -999 -999 -999 -999 -16 -6 10} \
				{-999 -999 -999 -999 -999 -999 -26 -10}}
	} else {
		_error "Fatal Error: Unknown RLDRAM mode $protocol"
	}
}

proc ::alt_mem_if::gui::common_rldram_phy::_bilinear_interpolate {x1 x2 y1 y2 q11 q12 q21 q22 a b} {
	set r1 [_linear_interpolate $x1 $x2 $q11 $q21 $a]
	set r2 [_linear_interpolate $x1 $x2 $q12 $q22 $a]
	return [_linear_interpolate $y1 $y2 $r1 $r2 $b]
}


proc ::alt_mem_if::gui::common_rldram_phy::_linear_interpolate {x1 x2 q1 q2 a} {
	return [expr {double($q1) + (($a - $x1) * ($q2 - $q1) / ($x2 - $x1))}]
}


proc ::alt_mem_if::gui::common_rldram_phy::_table_lookup {x_name y_name q_name a b} {
	set x $x_name
	set y $y_name
	set q $q_name

	set x_last [expr {[llength $x] - 1}]
	set y_last [expr {[llength $y] - 1}]

	if {$a > [lindex $x 0]} {
		set a [lindex $x 0]
	} elseif {$a < [lindex $x $x_last]} {
		set a [lindex $x $x_last]
	}
	if {$b > [lindex $y 0]} {
		set b [lindex $y 0]
	} elseif {$b < [lindex $y $y_last]} {
		set b [lindex $y $y_last]
	}

	for {set x_index1 1} {$x_index1 < $x_last} {incr x_index1} {
		if {$a > [lindex $x $x_index1]} { break }
	}
	for {set y_index1 1} {$y_index1 < $y_last} {incr y_index1} {
		if {$b > [lindex $y $y_index1]} { break }
	}
		
	set x_index2 [expr {$x_index1 - 1}]
	set y_index2 [expr {$y_index1 - 1}]
	
	if {[expr abs([lindex $x $x_index1])] == 999 || [expr abs([lindex $y $y_index1])] == 999} {
		_eprint "Error: Slew rate combination is not supported by memory specification"
	}
	if {[expr abs([lindex $x $x_index2])] == 999 || [expr abs([lindex $y $y_index2])] == 999} {
		_eprint "Error: Slew rate combination is not supported by memory specification"
	}
	
	set val [_bilinear_interpolate [lindex $x $x_index1] [lindex $x $x_index2] \
	                               [lindex $y $y_index1] [lindex $y $y_index2] \
	                               [lindex [lindex $q $x_index1] $y_index1] [lindex [lindex $q $x_index1] $y_index2] \
	                               [lindex [lindex $q $x_index2] $y_index1] [lindex [lindex $q $x_index2] $y_index2] $a $b]
	if {$val < -500} {
		_eprint "Error: Unsupported derating value! Ensure that the slew rates are supported by the memory device"
	}
	return $val
}

proc ::alt_mem_if::gui::common_rldram_phy::_table_ac_slew_rates {} {

	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
	} else {
		_error "Fatal Error: Unknown RLDRAM mode $rldram_mode"
	}
}


proc ::alt_mem_if::gui::common_rldram_phy::_table_ck_ckn_slew_rates {} {
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0}
	} else {
		_error "Fatal Error: Unknown RLDRAM mode $rldram_mode"
	}
}


proc ::alt_mem_if::gui::common_rldram_phy::_table_dq_slew_rates {} {
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
	} else {
		_error "Fatal Error: Unknown RLDRAM mode $rldram_mode"
	}
}


proc ::alt_mem_if::gui::common_rldram_phy::_table_dk_dkn_slew_rates {} {
	variable rldram_mode
	
	if {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0}
	} else {
		_error "Fatal Error: Unknown RLDRAM mode $rldram_mode"
	}
}



proc ::alt_mem_if::gui::common_rldram_phy::_derate_t_is {mem_fmax t_is_base_ps ac_slew_rate ck_ckn_slew_rate} {

	set ACvalue 0.150
	
	set delta_tIS_ps [_table_lookup [_table_ac_slew_rates] [_table_ck_ckn_slew_rates] [_table_delta_tIS] $ac_slew_rate $ck_ckn_slew_rate]

	set result [expr {$t_is_base_ps + $delta_tIS_ps + ($ACvalue / $ac_slew_rate) * 1000}]

	return [expr round($result)]
}


proc ::alt_mem_if::gui::common_rldram_phy::_derate_t_ih {mem_fmax t_ih_base_ps ac_slew_rate ck_ckn_slew_rate} {

	set DCvalue 0.100
	
	set delta_tIH_ps [_table_lookup [_table_ac_slew_rates] [_table_ck_ckn_slew_rates] [_table_delta_tIH] $ac_slew_rate $ck_ckn_slew_rate]

	set result [expr {$t_ih_base_ps + $delta_tIH_ps + ($DCvalue / $ac_slew_rate) * 1000}]
	
	return [expr round($result)]
}

proc ::alt_mem_if::gui::common_rldram_phy::_derate_t_ds {mem_fmax t_ds_base_ps dq_slew_rate dk_dkn_slew_rate} {

	set ACvalue 0.150
	
	set delta_tDS_ps [_table_lookup [_table_dq_slew_rates] [_table_dk_dkn_slew_rates] [_table_delta_tDS] $dq_slew_rate $dk_dkn_slew_rate]

	set result [expr {$t_ds_base_ps + $delta_tDS_ps + ($ACvalue / $dq_slew_rate) * 1000}]
	
	return [expr round($result)]
}

proc ::alt_mem_if::gui::common_rldram_phy::_derate_t_dh {mem_fmax t_dh_base_ps dq_slew_rate dk_dkn_slew_rate} {
	
	set DCvalue 0.100

	set delta_tDH_ps [_table_lookup [_table_dq_slew_rates] [_table_dk_dkn_slew_rates] [_table_delta_tDH] $dq_slew_rate $dk_dkn_slew_rate]

	set result [expr {$t_dh_base_ps + $delta_tDH_ps + ($DCvalue / $dq_slew_rate) * 1000}]
	
	return [expr round($result)]
}


::alt_mem_if::gui::common_rldram_phy::_init


