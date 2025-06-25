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


package provide alt_mem_if::gui::common_ddrx_phy 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::uniphy_debug

namespace eval ::alt_mem_if::gui::common_ddrx_phy:: {
	variable VALID_DDR_MODES
	variable ddr_mode

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::common_ddrx_phy::_validate_ddr_mode {} {
	variable ddr_mode
		
	if {$ddr_mode == -1} {
		error "DDR mode in [namespace current] in uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::common_ddrx_phy::set_ddr_mode {in_ddr_mode} {
	variable VALID_DDR_MODES
	
	if {[info exists VALID_DDR_MODES($in_ddr_mode)] == 0} {
		_eprint "Fatal Error: Illegal DDR mode $in_ddr_mode"
		_eprint "Fatal Error: Valid DDR modes are [array names VALID_DDR_MODES]"
		_error "An error occurred"
	} else {
		_dprint 1 "Setting DDR Mode as $in_ddr_mode"
		variable ddr_mode
		set ddr_mode $in_ddr_mode
	}

	return 1
}

proc ::alt_mem_if::gui::common_ddrx_phy::create_parameters {} {
	
	_validate_ddr_mode
	
	_dprint 1 "Preparing to create parameters for common_ddrx_phy"
	
	_create_derived_parameters

	_create_phy_parameters
	
	alt_mem_if::gui::uniphy_debug::create_debug_parameters

	_create_board_settings_parameters

	return 1
}


proc ::alt_mem_if::gui::common_ddrx_phy::create_phy_gui {} {

	_validate_ddr_mode
	
	_create_phy_parameters_gui
	
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		_create_interface_parameters_gui
	}

	return 1
}


proc ::alt_mem_if::gui::common_ddrx_phy::create_board_settings_gui {} {

	_create_board_settings_parameters_gui

	return 1
}


proc ::alt_mem_if::gui::common_ddrx_phy::create_diagnostics_gui {} {

	_create_diagnostics_gui

	return 1
}


proc ::alt_mem_if::gui::common_ddrx_phy::validate_component {} {

	set protocol [_get_protocol]
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixv"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixiii"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixiv"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriaiigz"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriavgz"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "max10fpga"] == 0 } {
	} else {
		if {[string compare -nocase [get_module_property INTERNAL] "true"] != 0 &&
			[string compare -nocase [get_module_property INTERNAL] "1"] != 0} {
			_eprint "[get_module_property DESCRIPTION] is not supported by family [get_parameter_value DEVICE_FAMILY]"
		}
		return 0
	}

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] == 0 || 
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "cyclonev"] == 0} {
		set_parameter_property HARD_EMIF VISIBLE true
		if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
			set_parameter_property HARD_EMIF ENABLED false
		} else {
			set_parameter_property HARD_EMIF ENABLED true
		}
	} else {
		set_parameter_property HARD_EMIF VISIBLE false
		set_parameter_property HARD_EMIF ENABLED false
	}

	::alt_mem_if::gui::uniphy_debug::derive_debug_parameters

	::alt_mem_if::gen::uniphy_gen::derive_delay_params $protocol

	_derive_parameters

	_derive_board_settings_parameters

	::alt_mem_if::gen::uniphy_pll::derive_pll $protocol

	_derive_qvld_wr_address_offset

	_dprint 1 "Preparing to validate component for common_ddrx_phy"
	
	set validation_pass 1

	if {[regexp {^DDR2$} $protocol] == 1} {
		set MEM_CLK_FREQ_MIN 125
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set MEM_CLK_FREQ_MIN 300
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set MEM_CLK_FREQ_MIN 166
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		set MEM_CLK_FREQ_MIN 10
	}
	if {[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1} {
		if {[get_parameter_value MEM_CLK_FREQ] < $MEM_CLK_FREQ_MIN} {
			_eprint "The specified Memory clock frequency is below the minimum defined by the DDR specification. Please select a frequency greater than or equal to $MEM_CLK_FREQ_MIN MHz."
			set validation_pass 0
		} elseif {[get_parameter_value MEM_CLK_FREQ] > [get_parameter_value MEM_CLK_FREQ_MAX]} {
			_eprint "The specified Memory clock frequency exceeds the Memory device speed grade of [get_parameter_value MEM_CLK_FREQ_MAX] MHz. Please increase the [get_parameter_property MEM_CLK_FREQ_MAX DISPLAY_NAME] (in Memory Parameters tab) or decrease the Memory clock frequency."
			set validation_pass 0
		}
	} else {
		_eprint "Memory clock frequency must be between $MEM_CLK_FREQ_MIN MHz and [get_parameter_value MEM_CLK_FREQ_MAX] MHz"
		set validation_pass 0
	}
	
	if {[string compare -nocase $protocol "DDR3"] == 0 &&
		[string compare -nocase [get_parameter_value RATE] "QUARTER"] != 0 &&
		[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1 &&
		([string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] == 0 ||
		 [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] == 0 )&&
		[get_parameter_value MEM_CLK_FREQ] > 533} {
		_wprint "The memory clock frequency specified is above 533MHz and may require the quarter-rate PHY and controller to close timing"
	}

	if {[string compare -nocase $protocol "DDR3"] == 0 &&
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 &&
		[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0 && 
		[get_parameter_value MEM_CLK_FREQ] > 450} {
		_wprint "Arria V SoC HPS DDR3 is only supported to 450MHz in 13.1"

	}

	if {[string compare -nocase $protocol "DDR3"] == 0 &&
		[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1 &&
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] == 0 &&
	    [get_parameter_value MEM_CLK_FREQ] > 666 && 
        [get_parameter_value MEM_CLK_FREQ_MAX] < 800} {
		_wprint "For Arria V DDR3 interfaces running at over 666MHz, an 800MHz speedgrade memory device is recommended."
	}	

	set is_dimm [expr {[string compare -nocase [get_parameter_value MEM_FORMAT] "DISCRETE"] != 0}]
	if {[regexp {^DDR2$} $protocol] == 1} {
		if {$is_dimm && [get_parameter_value TIMING_BOARD_AC_TO_CK_SKEW] < 0.600} {
			_wprint "An average delay difference between address and command and CK of at least 0.6ns is recommended for DDR2 SDRAM DIMMs (Board Settings tab).  Refer to DIMMs specification to estimate exact value."
		}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {$is_dimm && [string compare -nocase [get_parameter_value MEM_LEVELING] "false"] == 0} {
			if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_nolevel_ddr3_dimm_gen] == 1 } {
				_wprint "An interface without leveling has been selected for a DIMM memory topology. Ensure that DQS vs CK timing analysis (including board skew) has positive slack."
			} else {
				_eprint "Use an interface with leveling when you select a DIMM memory topology"
				set validation_pass 0
			}
		}
	}

	set command_phase [get_parameter_value COMMAND_PHASE]
	if { $command_phase > 360 || $command_phase < -360 } {
		_eprint "Additional address and command phase out of range (must be between -360 and +360)"
		set validation_pass 0
	}

	set mem_ck_phase [get_parameter_value MEM_CK_PHASE]
	if { $mem_ck_phase > 360 || $mem_ck_phase < -360 } {
		_eprint "Additional CK/CK# phase out of range (must be between -360 and +360)"
		set validation_pass 0
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

	if {[string compare -nocase [get_parameter_value CALIBRATION_MODE] "skip"] == 0 || [string compare -nocase [get_parameter_value CALIBRATION_MODE] "quick"] == 0 } {
		if {! [::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
			_wprint "'Quick' simulation modes are NOT timing accurate. Some simulation memory models may issue warnings or errors"
			_dprint 1 "Calibration mode is [get_parameter_value CALIBRATION_MODE]"
		}
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_VOLTAGE ] "1.5V DDR3"] != 0} {
			if {([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] != 0) &&
				([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] != 0) &&
				([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] != 0) &&
				 ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] != 0)} {
				_eprint "DDR3L not supported on current device family"
				set validation_pass 0
			}
		}
	}

	if {[get_parameter_value SEQ_MODE] == 2} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			_eprint "Eighth-rate sequencer is not supported"
		} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
			_eprint "Quarter-rate sequencer is not supported"
		}
		set validation_pass 0
	}

	if {([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0) || ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			if {[string compare -nocase [get_parameter_value MEM_LEVELING] "false"] == 0} {
				_eprint "Quarter-rate PHY is not supported for non-leveling configurations"
				set validation_pass 0
			}
		}
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0} {
		if {[get_parameter_value MEM_DQ_PER_DQS] == 4} {
			_wprint "DQ/DQS group size of 4 is not supported on some Stratix V ES devices"
		}
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		if {[get_parameter_value MEM_DQ_PER_DQS] == 4} {
			_wprint "DQ/DQS group size of 4 is not supported on some Arria V GZ ES devices"
		}
	}

	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0 &&
	    [string compare -nocase [get_parameter_value MEM_BT] "Interleaved"] == 0} {
		_eprint "The Altera memory controller does not support '[get_parameter_property MEM_BT DISPLAY_NAME]' set to '[get_parameter_value MEM_BT]'. To use this setting of the memory device, you can use a custom controller by selecting the '[get_parameter_property PHY_ONLY DISPLAY_NAME]' option."
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
		set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED VISIBLE false
		set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED VISIBLE false		
		
	}		

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] > 800} {
			if {[string compare -nocase [get_parameter_value PACKAGE_DESKEW] "true"] == 0} {
				_iprint "DQ/DQS pin package deskew is enabled - Ensure that the PCB is designed to compensate for the FPGA package skews"
			} else {
				_wprint "DQ/DQS pin package skew may need to be compensated on the PCB for speeds above 800MHz to improve timing"
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
		set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE VISIBLE true
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
		set_parameter_property ADVANCED_CK_PHASES VISIBLE false
		set_parameter_property COMMAND_PHASE VISIBLE false
	
		if { [ string compare -nocase [get_parameter_value ENABLE_LDC_MEM_CK_ADJUSTMENT] "true" ] == 0} {
			set_parameter_property MEM_CK_PHASE VISIBLE true
			if { [ string compare -nocase [get_parameter_value DLL_USE_DR_CLK] "true" ] == 0} {
				set_parameter_property MEM_CK_PHASE ALLOWED_RANGES {0 22.5 45 67.5 180 202.5 225 247.5}
			} else {
				set_parameter_property MEM_CK_PHASE ALLOWED_RANGES {0 45 90 135 180 225 270 315}
			}
			if {[get_parameter_value MEM_CLK_FREQ] >= [get_parameter_value MEM_CK_LDC_ADJUSTMENT_THRESHOLD]} {
				set_parameter_property MEM_CK_PHASE ENABLED true
			} else {
				set_parameter_property MEM_CK_PHASE ENABLED false
			}
		} else {
			set_parameter_property MEM_CK_PHASE VISIBLE true
		}			
	} else {
		if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
			set_parameter_property ADVANCED_CK_PHASES VISIBLE false
			set_parameter_property COMMAND_PHASE VISIBLE false
			set_parameter_property MEM_CK_PHASE VISIBLE false
		} else {
			set_parameter_property ADVANCED_CK_PHASES VISIBLE true
			set_parameter_property COMMAND_PHASE VISIBLE true
			if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
				[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
				set_parameter_property MEM_CK_PHASE VISIBLE false
			} else {
				set_parameter_property MEM_CK_PHASE VISIBLE true
			}
		}
	}


	if {[get_parameter_value NIOS_ROM_ADDRESS_WIDTH] != [get_parameter_property NIOS_ROM_ADDRESS_WIDTH DEFAULT_VALUE]} {
		set_parameter_value NIOS_ROM_ADDRESS_WIDTH [get_parameter_property NIOS_ROM_ADDRESS_WIDTH DEFAULT_VALUE]
	}
	
	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0 &&
		[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
		_eprint "The options '[get_parameter_property HARD_EMIF DISPLAY_NAME]' and '[get_parameter_property PHY_ONLY DISPLAY_NAME]' cannot be enabled simultaneously."
		set validation_pass 0
	}	
 	
        if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
                   if { ([get_parameter_value MEM_IF_DQ_WIDTH] == 24 || [get_parameter_value MEM_IF_DQ_WIDTH] == 40 ) } {
                             _iprint "ECC will be enabled in the preloader because an interface width of 24 or 40 has been chosen."
                   }
          }         

	if { ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || 
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)  &&
		 [regexp {^DDR3$} $protocol] == 1 } {
		set_parameter_property PINGPONGPHY_EN VISIBLE true
	} else {
		set_parameter_property PINGPONGPHY_EN VISIBLE false
	}

	if {[string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0} {
		if { ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] != 0 &&
			  	[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] != 0 ) ||
			[regexp {^DDR3$} $protocol] != 1 ||
			[string compare -nocase [get_parameter_value RATE] "QUARTER"] != 0} {
			_eprint "The Ping Pong PHY option is only allowed for the Stratix V or Arria V GZ, DDR3, Quarter Rate EMIF configuration."
			set validation_pass 0
		}
	}


	return $validation_pass

}

proc ::alt_mem_if::gui::common_ddrx_phy::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for common_ddrx_phy"
	
	return 1
}


proc ::alt_mem_if::gui::common_ddrx_phy::_init {} {
	variable VALID_DDR_MODES
	
	::alt_mem_if::util::list_array::array_clean VALID_DDR_MODES
	set VALID_DDR_MODES(DDR2) 1
	set VALID_DDR_MODES(DDR3) 1
	set VALID_DDR_MODES(LPDDR2) 1
	set VALID_DDR_MODES(LPDDR1) 1
	set VALID_DDR_MODES(HPS) 1

	variable ddr_mode -1

}


proc ::alt_mem_if::gui::common_ddrx_phy::_get_protocol {} {

	_validate_ddr_mode

	variable ddr_mode

	set protocol ""
	if {[regexp {^DDR2$} $ddr_mode] == 1} {
		set protocol "DDR2"
	} elseif {[regexp {^DDR3$} $ddr_mode] == 1} {
		set protocol "DDR3"
	} elseif {[regexp {^LPDDR2$} $ddr_mode] == 1} {
		set protocol "LPDDR2"
	} elseif {[regexp {^LPDDR1$} $ddr_mode] == 1} {
		set protocol "LPDDR1"
	} elseif {[regexp {^HPS$} $ddr_mode] == 1} {
		set protocol [get_parameter_value HPS_PROTOCOL]
	}

	return $protocol
}


proc ::alt_mem_if::gui::common_ddrx_phy::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in common_ddrx_phy"
	
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

	::alt_mem_if::util::hwtcl_utils::_add_parameter FORCED_NUM_WRITE_FR_CYCLE_SHIFTS INTEGER 0
	set_parameter_property FORCED_NUM_WRITE_FR_CYCLE_SHIFTS VISIBLE false
	set_parameter_property FORCED_NUM_WRITE_FR_CYCLE_SHIFTS DERIVED false
	
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
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_NS float 0
	set_parameter_property MEM_CLK_NS VISIBLE FALSE
	set_parameter_property MEM_CLK_NS DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_PS float 0
	set_parameter_property MEM_CLK_PS VISIBLE FALSE
	set_parameter_property MEM_CLK_PS DERIVED TRUE
	
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

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_STANDARD STRING ""
	set_parameter_property IO_STANDARD DISPLAY_NAME "I/O standard"
	set_parameter_property IO_STANDARD DESCRIPTION "I/O standard voltage."
	set_parameter_property IO_STANDARD DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter VFIFO_AS_SHIFT_REG boolean false
	set_parameter_property VFIFO_AS_SHIFT_REG DERIVED true
	set_parameter_property VFIFO_AS_SHIFT_REG VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter SEQUENCER_TYPE STRING "NIOS"
	set_parameter_property SEQUENCER_TYPE DERIVED false
	set_parameter_property SEQUENCER_TYPE DISPLAY_NAME "Sequencer optimization"
	set_parameter_property SEQUENCER_TYPE AFFECTS_ELABORATION true
	set_parameter_property SEQUENCER_TYPE ALLOWED_RANGES {"NIOS:Performance (Nios II-based Sequencer)" "RTL:Area (RTL Sequencer)"}
	set_parameter_property SEQUENCER_TYPE DESCRIPTION "Selects optimized version of the sequencer, which performs memory calibration tasks.
	Choose \"Performance\" to enable the Nios(R) II-based sequencer, or \"Area\" for a simple RTL-based sequencer."
	set_parameter_property SEQUENCER_TYPE VISIBLE false


	::alt_mem_if::util::hwtcl_utils::_add_parameter NIOS_HEX_FILE_LOCATION STRING ""
	set_parameter_property NIOS_HEX_FILE_LOCATION VISIBLE false
	set_parameter_property NIOS_HEX_FILE_LOCATION DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter ADVERTIZE_SEQUENCER_SW_BUILD_FILES boolean false
	set_parameter_property ADVERTIZE_SEQUENCER_SW_BUILD_FILES VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter NEGATIVE_WRITE_CK_PHASE boolean false
	set_parameter_property NEGATIVE_WRITE_CK_PHASE DERIVED true
	set_parameter_property NEGATIVE_WRITE_CK_PHASE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_WL integer 0
	set_parameter_property MEM_T_WL DERIVED TRUE
	set_parameter_property MEM_T_WL VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_RL integer 0
	set_parameter_property MEM_T_RL DERIVED TRUE
	set_parameter_property MEM_T_RL VISIBLE false
	
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

	::alt_mem_if::util::hwtcl_utils::_add_parameter FORCED_NON_LDC_ADDR_CMD_MEM_CK_INVERT BOOLEAN false
	set_parameter_property FORCED_NON_LDC_ADDR_CMD_MEM_CK_INVERT VISIBLE false		
	set_parameter_property FORCED_NON_LDC_ADDR_CMD_MEM_CK_INVERT DERIVED false

	::alt_mem_if::util::hwtcl_utils::_add_parameter NON_LDC_ADDR_CMD_MEM_CK_INVERT BOOLEAN false
	set_parameter_property NON_LDC_ADDR_CMD_MEM_CK_INVERT VISIBLE false		
	set_parameter_property NON_LDC_ADDR_CMD_MEM_CK_INVERT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter REGISTER_C2P BOOLEAN false
	set_parameter_property REGISTER_C2P VISIBLE false		
	set_parameter_property REGISTER_C2P DERIVED true	

	::alt_mem_if::util::hwtcl_utils::_add_parameter EARLY_ADDR_CMD_CLK_TRANSFER BOOLEAN false
	set_parameter_property EARLY_ADDR_CMD_CLK_TRANSFER VISIBLE false
	set_parameter_property EARLY_ADDR_CMD_CLK_TRANSFER DERIVED true

}


proc ::alt_mem_if::gui::common_ddrx_phy::_create_phy_parameters {} {
	
	variable ddr_mode

	_dprint 1 "Preparing to create PHY parameters in common_ddrx_phy"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_ONLY boolean false
	set_parameter_property PHY_ONLY DISPLAY_NAME "Generate PHY only"
	set_parameter_property PHY_ONLY DESCRIPTION "When turned on, no controller will be generated and the AFI interface to the PHY will become available."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter SEQ_MODE integer 0
	set_parameter_property SEQ_MODE DISPLAY_NAME "Full- or half-rate sequencer"
	set_parameter_property SEQ_MODE AFFECTS_ELABORATION true
	set_parameter_property SEQ_MODE VISIBLE false
	set_parameter_property SEQ_MODE ALLOWED_RANGES {0 1 2}

	::alt_mem_if::util::hwtcl_utils::_add_parameter ADVANCED_CK_PHASES boolean false
	set_parameter_property ADVANCED_CK_PHASES DISPLAY_NAME "Advanced clock phase control"
	set_parameter_property ADVANCED_CK_PHASES DESCRIPTION "Enables access to clock phases.
	Modifying default values is not recommended."

	::alt_mem_if::util::hwtcl_utils::_add_parameter COMMAND_PHASE FLOAT 0.0
	set_parameter_property COMMAND_PHASE DISPLAY_NAME "Additional address and command clock phase"
	set_parameter_property COMMAND_PHASE DISPLAY_UNITS Degrees
	set_parameter_property COMMAND_PHASE DESCRIPTION "Allows you to increase or decrease the amount of phase shift on the address and command clocks.
	The base phase shift center aligns the address and command clocks at the memory device, which may not be the optimal setting under all circumstances.
	Increasing or decreasing the amount of phase shift can improve timing."

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CK_PHASE FLOAT 0.0
	set_parameter_property MEM_CK_PHASE DISPLAY_NAME "Additional CK/CK# phase"
	set_parameter_property MEM_CK_PHASE DISPLAY_UNITS Degrees
	set_parameter_property MEM_CK_PHASE DESCRIPTION "Allows you to increase or decrease the amount of phase shift on the CK/CK
	The base phase shift center aligns the address and command clock at the memory device, which may not be the optimal setting under all circumstances.
	Increasing or decreasing the amount of phase shift can improve timing."

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

	if {[regexp {^DDR3$|^HPS$} $ddr_mode ] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_VOLTAGE STRING "1.5V DDR3"
		set_parameter_property MEM_VOLTAGE ALLOWED_RANGES {"1.5V DDR3" "1.35V DDR3L"}
		set_parameter_property MEM_VOLTAGE DISPLAY_NAME "Supply Voltage"
		set_parameter_property MEM_VOLTAGE DESCRIPTION "Supply voltage and sub-family type of memory.<br>
		Note DDR3L is currently supported only on Stratix V, Arria V GZ, Arria V and Cyclone V."
	}

	
	add_parameter HCX_COMPAT_MODE boolean false
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
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter SKIP_MEM_INIT boolean true 
	set_parameter_property SKIP_MEM_INIT DISPLAY_NAME "Skip Memory Initialization Delays"
	set_parameter_property SKIP_MEM_INIT DESCRIPTION "When turned on, required delays between specific memory initialization commands are skipped to speed up simulation.
	There is no change to the generated RTL."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter READ_DQ_DQS_CLOCK_SOURCE string "INVERTED_DQS_BUS"
	set_parameter_property READ_DQ_DQS_CLOCK_SOURCE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQ_INPUT_REG_USE_CLKN boolean false
	set_parameter_property DQ_INPUT_REG_USE_CLKN VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQS_DQSN_MODE string "DIFFERENTIAL"
	set_parameter_property DQS_DQSN_MODE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_DEBUG_INFO_WIDTH INTEGER 32
	set_parameter_property AFI_DEBUG_INFO_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CALIBRATION_MODE STRING "Skip"
	set_parameter_property CALIBRATION_MODE DISPLAY_NAME "Auto-calibration mode"
	set_parameter_property CALIBRATION_MODE AFFECTS_ELABORATION true
	set_parameter_property CALIBRATION_MODE DESCRIPTION "Simulation performance is improved by reduced calibration.
	There is no change to the generated RTL."
	set_parameter_property CALIBRATION_MODE ALLOWED_RANGES {"Skip:Skip calibration" "Quick:Quick calibration" "Full:Full calibration"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter NIOS_ROM_DATA_WIDTH integer 32
	set_parameter_property NIOS_ROM_DATA_WIDTH visible false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter NIOS_ROM_ADDRESS_WIDTH integer 13
	set_parameter_property NIOS_ROM_ADDRESS_WIDTH visible false
	set_parameter_property NIOS_ROM_ADDRESS_WIDTH derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter READ_FIFO_SIZE integer 8
	set_parameter_property READ_FIFO_SIZE DISPLAY_NAME "Depth of the read FIFO"
	set_parameter_property READ_FIFO_SIZE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_CSR_ENABLED Boolean false
	set_parameter_property PHY_CSR_ENABLED DISPLAY_NAME "Enable Configuration and Status Register Interface"
	set_parameter_property PHY_CSR_ENABLED DESCRIPTION "Select this option to enable run-time configuration and status of the memory PHY.
	Enabling this option adds an additional Avalon Memory-Mapped slave port to the memory PHY top level."
	set_parameter_property PHY_CSR_ENABLED VISIBLE true
	set_parameter_property PHY_CSR_ENABLED DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_CSR_CONNECTION STRING "INTERNAL_JTAG"
	set_parameter_property PHY_CSR_CONNECTION DISPLAY_NAME "CSR port host interface"
	set_parameter_property PHY_CSR_CONNECTION DESCRIPTION "Specifies the connection type to CSR port.
	The port can be exported, internally connected to a JTAG Avalon Master, or both"
	set_parameter_property PHY_CSR_CONNECTION UNITS None
	set_parameter_property PHY_CSR_CONNECTION ALLOWED_RANGES {"INTERNAL_JTAG:Internal (JTAG)" "EXPORT:Avalon-MM Slave" "SHARED:Shared"}

}


proc ::alt_mem_if::gui::common_ddrx_phy::_create_board_settings_parameters {} {
	
	_dprint 1 "Preparing to create board settings parameters in common_ddrx_phy"

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

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQS_DQSN_SLEW_RATE Float 2
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE DISPLAY_NAME "DQS/DQS# slew rate (Differential)"
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE DESCRIPTION "DQS/DQS# slew rate (Differential)"
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE DISPLAY_UNITS "V/ns"
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE DISPLAY_HINT columns:10

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

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED Float 2
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED DISPLAY_NAME "DQS/DQS# slew rate (Differential)"
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED DESCRIPTION "DQS/DQS# slew rate (Differential)"
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED DISPLAY_UNITS "V/ns"
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQ_SLEW_RATE_APPLIED Float 1
	set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DISPLAY_NAME "DQ slew rate"
	set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DESCRIPTION "DQ slew rate"
	set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DISPLAY_UNITS "V/ns"
	set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DQ_SLEW_RATE_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIS Float 0
	set_parameter_property TIMING_BOARD_TIS DISPLAY_NAME "tIS"
	set_parameter_property TIMING_BOARD_TIS DESCRIPTION "Address and command setup time to CK"
	set_parameter_property TIMING_BOARD_TIS UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TIS DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIH Float 0
	set_parameter_property TIMING_BOARD_TIH DISPLAY_NAME "tIH"
	set_parameter_property TIMING_BOARD_TIH DESCRIPTION "Address and command hold time from CK"
	set_parameter_property TIMING_BOARD_TIH UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TIH DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDS Float 0
	set_parameter_property TIMING_BOARD_TDS DISPLAY_NAME "tDS"
	set_parameter_property TIMING_BOARD_TDS DESCRIPTION "Data setup time to DQS"
	set_parameter_property TIMING_BOARD_TDS UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TDS DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDH Float 0
	set_parameter_property TIMING_BOARD_TDH DISPLAY_NAME "tDH"
	set_parameter_property TIMING_BOARD_TDH DESCRIPTION "Data hold time from DQS"
	set_parameter_property TIMING_BOARD_TDH UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TDH DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIS_APPLIED Float 0
	set_parameter_property TIMING_BOARD_TIS_APPLIED DISPLAY_NAME "tIS"
	set_parameter_property TIMING_BOARD_TIS_APPLIED DESCRIPTION "Address and command setup time to CK"
	set_parameter_property TIMING_BOARD_TIS_APPLIED UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TIS_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_TIS_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TIH_APPLIED Float 0
	set_parameter_property TIMING_BOARD_TIH_APPLIED DISPLAY_NAME "tIH"
	set_parameter_property TIMING_BOARD_TIH_APPLIED DESCRIPTION "Address and command hold time from CK"
	set_parameter_property TIMING_BOARD_TIH_APPLIED UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TIH_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_TIH_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDS_APPLIED Float 0
	set_parameter_property TIMING_BOARD_TDS_APPLIED DISPLAY_NAME "tDS"
	set_parameter_property TIMING_BOARD_TDS_APPLIED DESCRIPTION "Data setup time to DQS"
	set_parameter_property TIMING_BOARD_TDS_APPLIED UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TDS_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_TDS_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_TDH_APPLIED Float 0
	set_parameter_property TIMING_BOARD_TDH_APPLIED DISPLAY_NAME "tDH"
	set_parameter_property TIMING_BOARD_TDH_APPLIED DESCRIPTION "Data hold time from DQS"
	set_parameter_property TIMING_BOARD_TDH_APPLIED UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_TDH_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_TDH_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_ISI_METHOD String AUTO
	set_parameter_property TIMING_BOARD_ISI_METHOD DISPLAY_NAME "Derating Method"
	set_parameter_property TIMING_BOARD_ISI_METHOD DESCRIPTION "Derating Method"
	set_parameter_property TIMING_BOARD_ISI_METHOD DISPLAY_HINT RADIO
	set_parameter_property TIMING_BOARD_ISI_METHOD ALLOWED_RANGES {"AUTO:Use Altera's default settings" "MANUAL:Specify channel uncertainty values"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_EYE_REDUCTION_SU Float 0
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU DISPLAY_NAME "Address and command eye reduction (setup)"
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU DESCRIPTION "The reduction in the eye diagram on the setup side (or left side of the eye) on the address and command signals."
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU Units Nanoseconds
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_EYE_REDUCTION_H Float 0
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H DISPLAY_NAME "Address and command eye reduction (hold)"
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H DESCRIPTION "The reduction in the eye diagram on the hold side (or right side of the eye) on the address and command signals."
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H Units Nanoseconds
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQ_EYE_REDUCTION Float 0
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DISPLAY_NAME "Write DQ eye reduction"
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DESCRIPTION "The total reduction in the write eye diagram due to SI effects such as ISI/cross talk on DQ signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION Units Nanoseconds
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME Float 0
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DISPLAY_NAME "Write Delta DQS arrival time"
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DESCRIPTION "The increase in variation on the range of arrival times of DQS during a write due to SI effects.  Note it is assumed that the SI effects will cause DQS to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME Units Nanoseconds
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_READ_DQ_EYE_REDUCTION Float 0
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DISPLAY_NAME "Read DQ eye reduction"
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DESCRIPTION "The total reduction in the read eye diagram due to SI effects such as ISI/cross talk on DQ signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION Units Nanoseconds
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME Float 0
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DISPLAY_NAME "Read Delta DQS arrival time"
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DESCRIPTION "The increase in variation on the range of arrival times of DQS during a read due to SI effects.  Note it is assumed that the SI effects will cause DQS to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME Units Nanoseconds
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED Float 0
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED DISPLAY_NAME "Address and command eye reduction (setup)"
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED DESCRIPTION "The reduction in the eye diagram on the setup side (or left side of the eye) due to channel loss on the address and command signals."
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED Units Nanoseconds
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED Float 0
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED DISPLAY_NAME "Address and command eye reduction (hold)"
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED DESCRIPTION "The reduction in the eye diagram on the hold side (or right side of the eye) due to channel loss on the address and command signals."
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED Units Nanoseconds
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED Float 0
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED DISPLAY_NAME "Write DQ eye reduction"
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED DESCRIPTION "The total reduction in the write eye diagram due to SI effects such as ISI/cross talk on DQ signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED Units Nanoseconds
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED Float 0
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED DISPLAY_NAME "Write Delta DQS arrival time"
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED DESCRIPTION "The increase in variation on the range of arrival times of DQS during a write due to SI effects.  Note it is assumed that the SI effects will cause DQS to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED Units Nanoseconds
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED Float 0
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED DISPLAY_NAME "Read DQ eye reduction"
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED DESCRIPTION "The total reduction in the read eye diagram due to SI effects such as ISI/cross talk on DQ signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED Units Nanoseconds
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED Float 0
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED DISPLAY_NAME "Read Delta DQS arrival time"
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED DESCRIPTION "The increase in variation on the range of arrival times of DQS during a read due to SI effects.  Note it is assumed that the SI effects will cause DQS to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED Units Nanoseconds
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PACKAGE_DESKEW Boolean false
	set_parameter_property PACKAGE_DESKEW DISPLAY_NAME "FPGA DQ/DQS package skews deskewed on board"
	set_parameter_property PACKAGE_DESKEW DESCRIPTION "Improve timing margin by user compensation of DQ/DQS FPGA package trace on PCB trace (Please see the External Memory Interface handbook for information regarding customer action)."
	set_parameter_property PACKAGE_DESKEW Visible false
	set_parameter_property PACKAGE_DESKEW DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_PACKAGE_DESKEW Boolean false
	set_parameter_property AC_PACKAGE_DESKEW DISPLAY_NAME "FPGA Address/Command package skews deskewed on board"
	set_parameter_property AC_PACKAGE_DESKEW DESCRIPTION "Improve timing margin by user compensation of Address/Command FPGA package trace on PCB trace (Please see the External Memory Interface handbook for information regarding customer action)."
	set_parameter_property AC_PACKAGE_DESKEW Visible false
	set_parameter_property AC_PACKAGE_DESKEW DISPLAY_HINT columns:10	

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_MAX_CK_DELAY Float 0.6
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY DISPLAY_NAME "Maximum CK delay to DIMM/device"
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY DESCRIPTION "The delay of the longest CK trace from the FPGA to any DIMM/device."
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY Visible true
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY Units Nanoseconds
	set_parameter_property TIMING_BOARD_MAX_CK_DELAY DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_MAX_DQS_DELAY Float 0.6
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY DISPLAY_NAME "Maximum DQS delay to DIMM/device"
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY DESCRIPTION "The delay of the longest DQS trace from the FPGA to any DIMM/device."
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY Visible true
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY Units Nanoseconds
	set_parameter_property TIMING_BOARD_MAX_DQS_DELAY DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_CKDQS_DIMM_MIN Float -0.01
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN DISPLAY_NAME "Minimum delay difference between CK and DQS"
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN DESCRIPTION "The minimum skew (or largest negative skew) between the CK signal and any DQS signal when arriving at the same DIMM over all DIMMs.
	That is take the minimum value over all DIMMs, where for each DIMM the value is equal to the minimum delay of the CK signal minus the maximum delay of the DQS signal.
	This value affects the write leveling margin for DDR3 interfaces with leveling in multi-rank configurations."
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN Visible true
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN Units Nanoseconds
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_CKDQS_DIMM_MIN_APPLIED Float -0.01
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN_APPLIED Visible false
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN_APPLIED Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_CKDQS_DIMM_MAX Float 0.01
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX DISPLAY_NAME "Maximum delay difference between CK and DQS"
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX DESCRIPTION "The maximum skew (or largest positive skew) between the CK signal and any DQS signal when arriving at the same DIMM over all DIMMs.
	That is take the maximum value over all DIMMs, where for each DIMM the value is equal to the maximum delay of the CK signal minus the minimum delay of the DQS signal.
	This value will affect the Write Leveling margin for DDR3 interfaces with leveling in multi-rank configurations."
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX Visible true
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX Units Nanoseconds
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_CKDQS_DIMM_MAX_APPLIED Float 0.01
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX_APPLIED Visible false
	set_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX_APPLIED Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_BETWEEN_DIMMS Float 0.05
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DISPLAY_NAME "Maximum delay difference between DIMMs/devices"
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DESCRIPTION "The largest propagation delay on DQ signals between ranks.
	For example, in a two-rank configuration where you place DIMMs in different slots there is an extra propagation delay for DQ signals going to and coming back from the furthest DIMM compared to the nearest DIMM.
	This value affects the resynchronization margin for DDR2 and DDR3 interfaces in multi-rank configurations for both DIMMs and components."
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS Visible true
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS Units Nanoseconds
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_BETWEEN_DIMMS_APPLIED Float 0.05
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS_APPLIED Visible false
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS_APPLIED Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_WITHIN_DQS Float 0.020
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS DISPLAY_NAME "Maximum skew within DQS group"
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS DESCRIPTION "The largest skew between all DQ and DM pins in a DQS group.
	This value affects the read capture and write margins for DDR2 and DDR3 interfaces in all configurations (single- or multi-rank, DIMM or device)."
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS Visible true
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS Units Nanoseconds
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_BETWEEN_DQS Float 0.020
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DISPLAY_NAME "Maximum skew between DQS groups"
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DESCRIPTION "The largest skew between DQS signals in different DQS groups.
	This value affects the resynchronization margin in memory interfaces without leveling such as DDR2 and discrete-device DDR3 in both single- or multi-rank configurations."
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS Visible true
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS Units Nanoseconds
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DQ_TO_DQS_SKEW Float 0
	set_parameter_property TIMING_BOARD_DQ_TO_DQS_SKEW DISPLAY_NAME "Average delay difference between DQ and DQS"
	set_parameter_property TIMING_BOARD_DQ_TO_DQS_SKEW DESCRIPTION "The average delay difference between each DQ signal and the DQS signal, calculated by averaging the longest and smallest DQ signal delay values minus the delay of DQS."
	set_parameter_property TIMING_BOARD_DQ_TO_DQS_SKEW Visible true
	set_parameter_property TIMING_BOARD_DQ_TO_DQS_SKEW Units Nanoseconds
	set_parameter_property TIMING_BOARD_DQ_TO_DQS_SKEW DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_SKEW Float 0.020
	set_parameter_property TIMING_BOARD_AC_SKEW DISPLAY_NAME "Maximum skew within address and command bus"
	set_parameter_property TIMING_BOARD_AC_SKEW DESCRIPTION "The largest skew between the address and command signals."
	set_parameter_property TIMING_BOARD_AC_SKEW Visible true
	set_parameter_property TIMING_BOARD_AC_SKEW UNITS Nanoseconds
	set_parameter_property TIMING_BOARD_AC_SKEW DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_AC_TO_CK_SKEW Float 0
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DISPLAY_NAME "Average delay difference between address and command and CK"
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DESCRIPTION "The average delay difference between the address and command signals and the CK signal, calculated by averaging the longest and smallest Address/Command signal delay minus the CK delay.
	Positive values represent address and command signals that are longer than CK signals and negative values represent address and command signals that are shorter than CK signals.
	The Quartus II software uses this skew to optimize the delay of the address and command signals to have appropriate setup and hold margins for DDR2 and DDR3 interfaces."
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW Visible true
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW Units Nanoseconds
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DISPLAY_HINT columns:10
	
	return 1
}


proc ::alt_mem_if::gui::common_ddrx_phy::_create_phy_parameters_gui {} {

	variable ddr_mode

	_dprint 1 "Preparing to create PHY GUI in common_ddrx_phy"
	
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
	} else {
		add_display_item "" id2 TEXT "<html>Generation of the [string toupper $ddr_mode] Controller with UniPHY produces unencrypted PHY and Controller HDL, <br>constraint scripts, an example design and a testbench for simulation.<br>"
	}
	
	add_display_item "" "Interface Type" GROUP 
	add_display_item "Interface Type" HARD_EMIF PARAMETER
	
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		add_display_item "SDRAM" "PHY Settings" GROUP "tab"
	} else {
		add_display_item "Interface Type" "PHY Settings" GROUP "tab"
	}
	
	add_display_item "PHY Settings" "General Settings" GROUP 
	add_display_item "General Settings" SPEED_GRADE PARAMETER
	add_display_item "General Settings" IS_ES_DEVICE PARAMETER
	add_display_item "General Settings" HARD_PHY PARAMETER
	add_display_item "General Settings" PHY_ONLY PARAMETER
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property HARD_PHY Visible false
		set_parameter_property PHY_ONLY Visible false
		set_parameter_property SPEED_GRADE Visible false
	}

	add_display_item "PHY Settings" "Clocks" GROUP 
	add_display_item "Clocks" MEM_CLK_FREQ PARAMETER
	add_display_item "Clocks" USE_MEM_CLK_FREQ PARAMETER
	add_display_item "Clocks" PLL_MEM_CLK_FREQ PARAMETER
	add_display_item "Clocks" REF_CLK_FREQ PARAMETER
	add_display_item "Clocks" RATE PARAMETER
	add_display_item "Clocks" PLL_AFI_CLK_FREQ PARAMETER
	add_display_item "Clocks" EXPORT_AFI_HALF_CLK PARAMETER
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property USE_MEM_CLK_FREQ Visible true
		set_parameter_property RATE Visible false
		set_parameter_property PLL_AFI_CLK_FREQ Visible false
		set_parameter_property EXPORT_AFI_HALF_CLK Visible false
	}
	
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		add_display_item "PHY Settings" "Achieved Clocks" GROUP 
		set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_legality_clock_names_list 1]
		foreach clk_name $pll_clock_names {
			set freq_param_name "${clk_name}_FREQ"
			set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
			set phase_ps_param_name "${clk_name}_PHASE_PS"
			set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
			set phase_deg_param_name "${clk_name}_PHASE_DEG"
			set mult_param_name "${clk_name}_MULT"
			set div_param_name "${clk_name}_DIV"
			
			set_parameter_property $freq_param_name VISIBLE true
			set_parameter_property $freq_sim_str_param_name VISIBLE true
			set_parameter_property $phase_ps_param_name VISIBLE true
			set_parameter_property $phase_ps_str_param_name VISIBLE true
			set_parameter_property $mult_param_name VISIBLE true
			set_parameter_property $div_param_name VISIBLE true
			
			if {[string compare -nocase $clk_name "PLL_MEM_CLK"] == 0 ||
			    [string compare -nocase $clk_name "PLL_AFI_CLK"] == 0} {
			} else {
				add_display_item "Achieved Clocks" $freq_param_name PARAMETER
			}
			add_display_item "Achieved Clocks" $freq_sim_str_param_name PARAMETER
			add_display_item "Achieved Clocks" $phase_ps_param_name PARAMETER
			add_display_item "Achieved Clocks" $phase_ps_str_param_name PARAMETER
			add_display_item "Achieved Clocks" $phase_deg_param_name PARAMETER
			add_display_item "Achieved Clocks" $mult_param_name PARAMETER
			add_display_item "Achieved Clocks" $div_param_name PARAMETER
			
		}
	}
	
	add_display_item "PHY Settings" "Configuration and Status" GROUP
	add_display_item "Configuration and Status" PHY_CSR_ENABLED PARAMETER
	add_display_item "Configuration and Status" PHY_CSR_CONNECTION PARAMETER

	add_display_item "PHY Settings" "Advanced PHY Settings" GROUP
	add_display_item "Advanced PHY Settings" ADVANCED_CK_PHASES PARAMETER
	add_display_item "Advanced PHY Settings" COMMAND_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" MEM_CK_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" C2P_WRITE_CLOCK_ADD_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" P2C_READ_CLOCK_ADD_PHASE PARAMETER
	add_display_item "Advanced PHY Settings" ACV_PHY_CLK_ADD_FR_PHASE PARAMETER
	if {[regexp {^DDR3$|^HPS$} $ddr_mode ] == 1} {
	    add_display_item "Advanced PHY Settings" MEM_VOLTAGE PARAMETER
	}
	add_display_item "Advanced PHY Settings" IO_STANDARD PARAMETER
	add_display_item "Advanced PHY Settings" FORCE_DQS_TRACKING PARAMETER
	add_display_item "Advanced PHY Settings" FORCE_SHADOW_REGS PARAMETER
	add_display_item "Advanced PHY Settings" PLL_SHARING_MODE PARAMETER
	add_display_item "Advanced PHY Settings" NUM_PLL_SHARING_INTERFACES PARAMETER
	add_display_item "Advanced PHY Settings" DLL_SHARING_MODE PARAMETER
	add_display_item "Advanced PHY Settings" NUM_DLL_SHARING_INTERFACES PARAMETER
	add_display_item "Advanced PHY Settings" OCT_SHARING_MODE PARAMETER
	add_display_item "Advanced PHY Settings" NUM_OCT_SHARING_INTERFACES PARAMETER
	add_display_item "Advanced PHY Settings" HCX_COMPAT_MODE PARAMETER
	add_display_item "Advanced PHY Settings" PLL_LOCATION PARAMETER
	add_display_item "Advanced PHY Settings" PINGPONGPHY_EN PARAMETER 
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		add_display_item "Advanced PHY Settings" USE_FAKE_PHY PARAMETER
	}
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_non_destructive_calib_gui]} {
		set_parameter_property ENABLE_NON_DESTRUCTIVE_CALIB VISIBLE true
		add_display_item "Advanced PHY Settings" ENABLE_NON_DESTRUCTIVE_CALIB PARAMETER
	}
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property PLL_SHARING_MODE Visible false
		set_parameter_property NUM_PLL_SHARING_INTERFACES Visible false
		set_parameter_property DLL_SHARING_MODE Visible false
		set_parameter_property NUM_DLL_SHARING_INTERFACES Visible false
		set_parameter_property OCT_SHARING_MODE Visible false
		set_parameter_property NUM_OCT_SHARING_INTERFACES Visible false
		set_parameter_property PLL_LOCATION Visible false
		set_parameter_property HCX_COMPAT_MODE Visible false
		set_parameter_property C2P_WRITE_CLOCK_ADD_PHASE Visible false
		set_parameter_property P2C_READ_CLOCK_ADD_PHASE Visible false
		set_parameter_property USE_FAKE_PHY Visible false
		set_parameter_property ENABLE_EXPORT_SEQ_DEBUG_BRIDGE Visible false
		set_parameter_property ENABLE_NON_DESTRUCTIVE_CALIB Visible false
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_create_diagnostics_gui {} {

	_dprint 1 "Preparing to create PHY diagnostics GUI in common_ddrx_phy"

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property CALIBRATION_MODE Visible false
		set_parameter_property SKIP_MEM_INIT Visible false
		set_parameter_property MEM_VERBOSE Visible false
		alt_mem_if::gui::uniphy_debug::add_debug_display_items "Debugging Options"
		return
	}

	add_display_item "Interface Type" "Diagnostics" GROUP "tab"
	
	add_display_item "Diagnostics" "Simulation Options" GROUP
	add_display_item "Simulation Options" CALIBRATION_MODE PARAMETER
	add_display_item "Simulation Options" SKIP_MEM_INIT PARAMETER
	add_display_item "Simulation Options" MEM_VERBOSE PARAMETER
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_non_destructive_calib_gui]} {
		set_parameter_property REFRESH_BURST_VALIDATION VISIBLE true
		add_display_item "Simulation Options" REFRESH_BURST_VALIDATION PARAMETER
	}

	add_display_item "Diagnostics" "Debugging Options" GROUP
	alt_mem_if::gui::uniphy_debug::add_debug_display_items "Debugging Options"

}


proc ::alt_mem_if::gui::common_ddrx_phy::_create_board_settings_parameters_gui {} {

	_dprint 1 "Preparing to board settings GUI in common_ddrx_phy"
	
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		add_display_item "SDRAM" "Board Settings" GROUP "tab"
	} else {
		add_display_item "Interface Type" "Board Settings" GROUP "tab"
	}
	add_display_item "Board Settings" bs1 TEXT "<html>Use the Board Settings to model the board-level effects in the timing analysis.<br>"
	add_display_item "Board Settings" bs2 TEXT "<html>The wizard supports single- and multi-rank configurations.  Altera has determined the<br>effects on the output signaling of these configurations and has stored the effects on the output slew<br>rate and the channel uncertainty within the UniPHY MegaWizard.<br>"
	add_display_item "Board Settings" bs3 TEXT "<html><i>These values are representative of specific Altera boards. You must change the values to account for<br>the board level effects for your board.</i>  You can use HyperLynx or similar simulators to obtain<br>values that are representative of your board.<br>"
	add_display_item "Board Settings" "Setup and Hold Derating" GROUP
	add_display_item "Setup and Hold Derating" bs11 TEXT "<html>The slew rate of the output signals affects the setup and hold times of the memory device.<br>"
	add_display_item "Setup and Hold Derating" bs12 TEXT "<html>You can specify the slew rate of the output signals to refer to  their effect on the setup and hold times of<br>both the address and command signals and the DQ signals, or specify the setup and hold times directly.<br>"
	add_display_item "Setup and Hold Derating" TIMING_BOARD_DERATE_METHOD parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_CK_CKN_SLEW_RATE parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_AC_SLEW_RATE parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_DQS_DQSN_SLEW_RATE parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_DQ_SLEW_RATE parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_AC_SLEW_RATE_APPLIED parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_DQ_SLEW_RATE_APPLIED parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TIS parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TIH parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TDS parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TDH parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TIS_APPLIED parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TIH_APPLIED parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TDS_APPLIED parameter
	add_display_item "Setup and Hold Derating" TIMING_BOARD_TDH_APPLIED parameter

	add_display_item "Board Settings" "Channel Signal Integrity" GROUP
	add_display_item "Channel Signal Integrity" bs21 TEXT "<html>Channel Signal Integrity is a measure of the distortion of the eye due to intersymbol interference<br>or crosstalk or other effects. Typically when going from a single-rank configuration to a multi-rank<br>configuration there is an increase in the channel loss as there are multiple stubs causing<br>reflections. Please perform your channel signal integrity simulations and enter the extra channel<br>uncertainty."
	add_display_item "Channel Signal Integrity" TIMING_BOARD_ISI_METHOD parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_SU parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_H parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DQ_EYE_REDUCTION parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_READ_DQ_EYE_REDUCTION parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME parameter	

	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED parameter	

	add_display_item "Board Settings" "Board Skews" GROUP
	add_display_item "Board Skews" bs31 TEXT "<html>PCB traces can have skews between them that can cause timing margins to be reduced.  Furthermore<br>skews between different ranks can further reduce the timing margin in multi-rank topologies.<br>"
	add_display_item "Board Skews" "Restore default values" ACTION ::alt_mem_if::gui::common_ddrx_phy::_reset_board_skews
	add_display_item "Board Skews" PACKAGE_DESKEW parameter
	add_display_item "Board Skews" AC_PACKAGE_DESKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_MAX_CK_DELAY parameter
	add_display_item "Board Skews" TIMING_BOARD_MAX_DQS_DELAY parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_CKDQS_DIMM_MIN parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_CKDQS_DIMM_MAX parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_BETWEEN_DIMMS parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_WITHIN_DQS parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_BETWEEN_DQS parameter
	add_display_item "Board Skews" TIMING_BOARD_DQ_TO_DQS_SKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_AC_SKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_AC_TO_CK_SKEW parameter

	return 1
}

proc ::alt_mem_if::gui::common_ddrx_phy::_create_interface_parameters_gui {} {

	_dprint 1 "Preparing to create interface GUI in common_ddrx_phy"
	
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		add_display_item "SDRAM" "Interface Settings" GROUP "tab"
	} else {
		add_display_item "" "Interface Settings" GROUP "tab"
	}
	
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


proc ::alt_mem_if::gui::common_ddrx_phy::_derive_board_settings_parameters {} {

	_dprint 1 "Preparing to derive board settings parameters for common_ddrx_phy"

	set protocol [_get_protocol]

	set family [string toupper [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY]]
	set mem_format [get_parameter_value MEM_FORMAT]
	set device_width [get_parameter_value MEM_IF_DQS_WIDTH]
	set discrete_fly_by [string map "true 1 false 0" [get_parameter_value DISCRETE_FLY_BY]]
	if {[string compare -nocase $mem_format "DISCRETE" ] == 0 } {
		set is_discrete 1
		set num_dimms [get_parameter_value DEVICE_DEPTH]
		set num_ranks_per_dimm [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DEVICE]
	} else {
		set is_discrete 0
		set num_dimms [get_parameter_value MEM_NUMBER_OF_DIMMS]
		set num_ranks_per_dimm [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM]
	}
	if {[string compare -nocase $family "arriaiigz"] == 0} {
		set is_aiigz 1
	} else {
		set is_aiigz 0
	}

	set total_cs_num [expr {$num_dimms * $num_ranks_per_dimm}]
	if {[string compare -nocase $family "stratixiii"] == 0} {
		set_parameter_property TIMING_BOARD_DERATE_METHOD ENABLED FALSE
		set_parameter_property TIMING_BOARD_ISI_METHOD ENABLED FALSE
		if { $total_cs_num > 1 } {
			_iprint "For Stratix III multiple chip-select derating refer to the User Guide"
		}
	} else {
		set_parameter_property TIMING_BOARD_DERATE_METHOD ENABLED TRUE
		set_parameter_property TIMING_BOARD_ISI_METHOD ENABLED TURE
	}

	if {[string compare -nocase [get_parameter_value TIMING_BOARD_DERATE_METHOD] SLEW_RATE] == 0} {
		set_parameter_value TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_CK_CKN_SLEW_RATE]
		set_parameter_value TIMING_BOARD_AC_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_AC_SLEW_RATE]
		set_parameter_value TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_DQS_DQSN_SLEW_RATE]
		set_parameter_value TIMING_BOARD_DQ_SLEW_RATE_APPLIED [get_parameter_value TIMING_BOARD_DQ_SLEW_RATE]
	} else {
		set_parameter_value TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED [_default_ck_ckn_slew_rate $family $mem_format $num_dimms $num_ranks_per_dimm]
		set_parameter_value TIMING_BOARD_AC_SLEW_RATE_APPLIED [_default_ac_slew_rate $family $mem_format $num_dimms $num_ranks_per_dimm]
		set_parameter_value TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED [_default_dqs_dqsn_slew_rate $family $mem_format $num_dimms $num_ranks_per_dimm [get_parameter_value HCX_COMPAT_MODE]]
		set_parameter_value TIMING_BOARD_DQ_SLEW_RATE_APPLIED [_default_dq_slew_rate $family $mem_format $num_dimms $num_ranks_per_dimm [get_parameter_value HCX_COMPAT_MODE] [get_parameter_value MEM_CLK_FREQ_MAX]] 
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
		set dqs_dqsn_slew_rate [get_parameter_value TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED]
		set dq_slew_rate [get_parameter_value TIMING_BOARD_DQ_SLEW_RATE_APPLIED]
		if {$ck_ckn_slew_rate > 0 && $ac_slew_rate > 0 && $dqs_dqsn_slew_rate > 0 && $dq_slew_rate > 0} {
			set_parameter_value TIMING_BOARD_TIS_APPLIED [_derate_t_is $mem_fmax $t_is_base $ac_slew_rate $ck_ckn_slew_rate]
			set_parameter_value TIMING_BOARD_TIH_APPLIED [_derate_t_ih $mem_fmax $t_ih_base $ac_slew_rate $ck_ckn_slew_rate]
			set_parameter_value TIMING_BOARD_TDS_APPLIED [_derate_t_ds $mem_fmax $t_ds_base $dq_slew_rate $dqs_dqsn_slew_rate]
			set_parameter_value TIMING_BOARD_TDH_APPLIED [_derate_t_dh $mem_fmax $t_dh_base $dq_slew_rate $dqs_dqsn_slew_rate]
		} else {
			_error "Slew rates must be greater than 0 V/ns"
		}
	}

	if {[string compare -nocase [get_parameter_value TIMING_BOARD_ISI_METHOD] MANUAL] == 0} {
		set ac_eye_reduction_su [get_parameter_value TIMING_BOARD_AC_EYE_REDUCTION_SU]
		set ac_eye_reduction_h [get_parameter_value TIMING_BOARD_AC_EYE_REDUCTION_H]
		set dq_eye_reduction [get_parameter_value TIMING_BOARD_DQ_EYE_REDUCTION]
		set delta_dqs_arrival_time [get_parameter_value TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME]
		set read_dq_eye_reduction [get_parameter_value TIMING_BOARD_READ_DQ_EYE_REDUCTION]
		set delta_read_dqs_arrival_time [get_parameter_value TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME]
		
		if {$ac_eye_reduction_su < 0 || $ac_eye_reduction_h < 0 || $dq_eye_reduction < 0 || $delta_dqs_arrival_time < 0 || $read_dq_eye_reduction < 0 || $delta_read_dqs_arrival_time < 0} {
			_error "Channel uncertainties must be greater than or equal to 0"
		} else {
			set_parameter_value TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED $ac_eye_reduction_su
			set_parameter_value TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED $ac_eye_reduction_h
			set_parameter_value TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED $dq_eye_reduction
			set_parameter_value TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED $delta_dqs_arrival_time
			set_parameter_value TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED $read_dq_eye_reduction
			set_parameter_value TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED $delta_read_dqs_arrival_time
			
		}
	} else {
		set_parameter_value TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED [_default_ac_eye_reduction_su $family $mem_format $num_dimms $num_ranks_per_dimm]
		set_parameter_value TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED [_default_ac_eye_reduction_h $family $mem_format $num_dimms $num_ranks_per_dimm]
		set_parameter_value TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED [_default_dq_eye_reduction $family $mem_format $num_dimms $num_ranks_per_dimm]
		set_parameter_value TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED [_default_delta_dqs_arrival_time $family $mem_format $num_dimms $num_ranks_per_dimm]
		set_parameter_value TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED [_default_read_dq_eye_reduction $family $mem_format $num_dimms $num_ranks_per_dimm]
		set_parameter_value TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED [_default_delta_read_dqs_arrival_time $family $mem_format $num_dimms $num_ranks_per_dimm]

	}

	if {!$is_aiigz && [regexp {^DDR3$} $protocol] == 1 && (!$is_discrete || ($is_discrete && $device_width > 1 && $discrete_fly_by))} {
		set_parameter_value FLY_BY true
	} else {
		set_parameter_value FLY_BY false
	}

	if {[get_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MIN] > [get_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MAX]} {
		_error "The minimum delay difference between CK and DQS must be less than or equal to the maximum delay difference between CK and DQS"
	} else {
		set_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MIN_APPLIED [get_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MIN]
		set_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MAX_APPLIED [get_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MAX]
	}

	if {($is_discrete && [get_parameter_value DEVICE_DEPTH] > 1) || (!$is_discrete && [get_parameter_value MEM_NUMBER_OF_DIMMS] > 1)} {
		if {[get_parameter_value TIMING_BOARD_SKEW_BETWEEN_DIMMS] < 0} {
			_error "The maximum delay difference between DIMMs/devices must be greater than or equal to 0"
		} else {
			set_parameter_value TIMING_BOARD_SKEW_BETWEEN_DIMMS_APPLIED [get_parameter_value TIMING_BOARD_SKEW_BETWEEN_DIMMS]
		}
	} else {
		set_parameter_value TIMING_BOARD_SKEW_BETWEEN_DIMMS_APPLIED 0
	}

	foreach param [list TIMING_BOARD_SKEW_WITHIN_DQS TIMING_BOARD_SKEW_BETWEEN_DQS TIMING_BOARD_AC_SKEW] {
		if {[get_parameter_value $param] < 0} {
			_error "[get_parameter_property $param DISPLAY_NAME] must be greater than or equal to 0"
		}
	}

}


proc ::alt_mem_if::gui::common_ddrx_phy::_default_ck_ckn_slew_rate {family mem_format num_dimms num_ranks_per_dimm} {
	set result 2.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.42 }
						2 { set result 1.42 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.42 }
						2 { set result 1.42 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.28 }
						2 { set result 1.38 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.28 }
						2 { set result 1.38 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 4.85 }
						2 { set result 4.95 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 4.85 }
						2 { set result 4.95 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 2.0 }
						2 { set result 2.27 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.27 }
						2 { set result 2.27 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 2.0 }
						2 { set result 2.07 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.0 }
						2 { set result 2.37 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 2.0 }
						2 { set result 2.27 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.27 }
						2 { set result 2.27 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 2.0 }
						2 { set result 2.07 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.0 }
						2 { set result 2.37 }
					}}
				}}
			}}
		}
	}
	return $result
}


proc ::alt_mem_if::gui::common_ddrx_phy::_default_ac_slew_rate {family mem_format num_dimms num_ranks_per_dimm} {
	set result 1.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 2.34 }
						2 { set result 1.6 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.08 }
						2 { set result 0.9 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 3.51 }
						2 { set result 2.98 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.97 }
						2 { set result 2.49 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 3.47 }
						2 { set result 2.94 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.93 }
						2 { set result 2.45 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.0 }
						2 { set result 1.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.89 }
						2 { set result 0.7 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.0 }
						2 { set result 0.87 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.81 }
						2 { set result 0.65 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.0 }
						2 { set result 1.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.89 }
						2 { set result 0.7 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.0 }
						2 { set result 0.87 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.81 }
						2 { set result 0.65 }
					}}
				}}
			}}
		}
	}
	return $result
}

proc ::alt_mem_if::gui::common_ddrx_phy::_default_dqs_dqsn_slew_rate {family mem_format num_dimms num_ranks_per_dimm hcx_compat} {
	set result 2.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 3.87 }
						2 { set result 2.99 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 3.43 }
						2 { set result 2.67 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 3.87 }
						2 { set result 2.99 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 3.24 }
						2 { set result 2.36 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 4.10 }
						2 { set result 3.22 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 3.47 }
						2 { set result 2.59 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 4.35 }
						2 { set result 1.89 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 4.24 }
						2 { 
							if {[string compare -nocase $hcx_compat "true"] == 0 } {
								set result 1.9
							} else {
								set result 0.93 
							}
						  }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 4.23 }
						2 { set result 1.90 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.83 }
						2 { set result 1.19 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 4.35 }
						2 { set result 1.89 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 4.24 }
						2 { set result 0.93 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 4.23 }
						2 { set result 1.90 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 2.83 }
						2 { set result 1.19 }
					}}
				}}
			}}
		}
	}
	return $result
}

proc ::alt_mem_if::gui::common_ddrx_phy::_default_dq_slew_rate {family mem_format num_dimms num_ranks_per_dimm hcx_compat mem_fmax} {
	set result 1.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { 
							if {$mem_fmax <= 800} {
								set result 1.56
							} else {
								set result 2.0
							}
						  }
						2 { 
							if {$mem_fmax <= 800} {
								set result 1.18 
							} else {
								set result 1.62
							}
						  }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { 
							if {$mem_fmax <= 800} {
								set result 0.89 
							} else {
								set result 1.33
							}								
						  }
						2 { 
							if {$mem_fmax <= 800} {
								set result 0.64 
							} else {
								set result 1.08
							}								
						  }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { 
							if {$mem_fmax <= 800} {
								set result 1.56 
							} else {
								set result 2.0
							}								
						  }
						2 { 
							if {$mem_fmax <= 800} {
								set result 1.18 
							} else {
								set result 1.62
							}								
						  }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { 
							if {$mem_fmax <= 800} {
								set result 1.18 
							} else {
								set result 1.62
							}								
						  }
						2 { 
							if {$mem_fmax <= 800} {
								set result 0.93 
							} else {
								set result 1.37
							}								
						  }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.75 }
						2 { set result 1.37 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.37 }
						2 { set result 1.11 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.39 }
						2 { set result 1.41 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.6 }
						2 { 
							if {[string compare -nocase $hcx_compat "true"] == 0 } {
								set result 1.3
							} else {
								set result 0.74
							}
						  }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.63 }
						2 { set result 1.19 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.33 }
						2 { set result 0.86 }
					}}
				}}
			}}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $family {
			STRATIXIV { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.39 }
						2 { set result 1.41 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.6 }
						2 { set result 0.74 }
					}}
				}}
			}}
			ARRIAIIGX { switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 1.63 }
						2 { set result 1.19 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 1.33 }
						2 { set result 0.86 }
					}}
				}}
			}}
		}
	}
	return $result
}


proc ::alt_mem_if::gui::common_ddrx_phy::_derate_t_is {mem_fmax t_is_base_ps ac_slew_rate ck_ckn_slew_rate} {

	set protocol [_get_protocol]

	set mem_fmax [_snap_to_supported_mem_fmax $mem_fmax]
	
	set ACvalue [_ACvalue $protocol $mem_fmax]
	
	set delta_tIS_ps [_table_lookup [_table_ac_slew_rates $protocol] [_table_ck_ckn_slew_rates $protocol] [_table_delta_tIS $protocol $mem_fmax] $ac_slew_rate $ck_ckn_slew_rate]

	set result [expr {($t_is_base_ps / 1000.0) + ($delta_tIS_ps / 1000.0) + ($ACvalue / $ac_slew_rate)}]

	return [format %.3f $result]
}


proc ::alt_mem_if::gui::common_ddrx_phy::_derate_t_ih {mem_fmax t_ih_base_ps ac_slew_rate ck_ckn_slew_rate} {

	set protocol [_get_protocol]

	set mem_fmax [_snap_to_supported_mem_fmax $mem_fmax]
	
	set DCvalue [_DCvalue $protocol $mem_fmax]
	
	set delta_tIH_ps [_table_lookup [_table_ac_slew_rates $protocol] [_table_ck_ckn_slew_rates $protocol] [_table_delta_tIH $protocol $mem_fmax] $ac_slew_rate $ck_ckn_slew_rate]

	set result [expr {($t_ih_base_ps / 1000.0) + ($delta_tIH_ps / 1000.0) + ($DCvalue / $ac_slew_rate)}]
	
	return [format %.3f $result]
}

proc ::alt_mem_if::gui::common_ddrx_phy::_derate_t_ds {mem_fmax t_ds_base_ps dq_slew_rate dqs_dqsn_slew_rate} {

	set protocol [_get_protocol]

	set mem_fmax [_snap_to_supported_mem_fmax $mem_fmax]
	
	set ACvalue [_ACvalue $protocol $mem_fmax]
	
	if {$mem_fmax <= 800} {
		set base_derating 1
	} else {
		set base_derating 2
	}
	
	set delta_tDS_ps [_table_lookup [_table_dq_slew_rates $protocol $base_derating] [_table_dqs_dqsn_slew_rates $protocol $base_derating] [_table_delta_tDS $protocol $mem_fmax $base_derating] $dq_slew_rate $dqs_dqsn_slew_rate]


	set result [expr {($t_ds_base_ps / 1000.0) + ($delta_tDS_ps / 1000.0) + ($ACvalue / $dq_slew_rate)}]
	
	return [format %.3f $result]
}

proc ::alt_mem_if::gui::common_ddrx_phy::_derate_t_dh {mem_fmax t_dh_base_ps dq_slew_rate dqs_dqsn_slew_rate} {

	set protocol [_get_protocol]

	set mem_fmax [_snap_to_supported_mem_fmax $mem_fmax]
	
	set DCvalue [_DCvalue $protocol $mem_fmax]
	
	if {$mem_fmax <= 800} {
		set base_derating 1
	} else {
		set base_derating 2
	}

	set delta_tDH_ps [_table_lookup [_table_dq_slew_rates $protocol $base_derating] [_table_dqs_dqsn_slew_rates $protocol $base_derating] [_table_delta_tDH $protocol $mem_fmax $base_derating] $dq_slew_rate $dqs_dqsn_slew_rate]
	

	set result [expr {($t_dh_base_ps / 1000.0) + ($delta_tDH_ps / 1000.0) + ($DCvalue / $dq_slew_rate)}]
	
	return [format %.3f $result]
}


proc ::alt_mem_if::gui::common_ddrx_phy::_default_ac_eye_reduction_su {family mem_format num_dimms num_ranks_per_dimm} {
	set result 0.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.046 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.16 }
						2 { set result 0.16 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.05 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.1 }
						2 { set result 0.154 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.028 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.064 }
						2 { set result 0.093 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				LOADREDUCED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.00 }
						2 { set result 0.00 }
						4 { set result 0.00 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.1 }
						2 { set result 0.154 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.028 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.064 }
						2 { set result 0.093 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.1 }
						2 { set result 0.154 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.028 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.064 }
						2 { set result 0.093 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	}
	return $result
}



proc ::alt_mem_if::gui::common_ddrx_phy::_default_ac_eye_reduction_h {family mem_format num_dimms num_ranks_per_dimm} {
	set result 0.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.046 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.16 }
						2 { set result 0.16 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.05 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.1 }
						2 { set result 0.154 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.028 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.064 }
						2 { set result 0.093 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				LOADREDUCED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.1 }
						2 { set result 0.154 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.028 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.064 }
						2 { set result 0.093 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.1 }
						2 { set result 0.154 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.028 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.064 }
						2 { set result 0.093 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	}
	return $result
}


proc ::alt_mem_if::gui::common_ddrx_phy::_default_dq_eye_reduction {family mem_format num_dimms num_ranks_per_dimm} {
	set result 0.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.049 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.049 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.029 }
						2 { set result 0.08 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.038 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.082 }
						2 { set result 0.105 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				LOADREDUCED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.006 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.003 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.038 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.082 }
						2 { set result 0.105 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.006 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.003 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.038 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.082 }
						2 { set result 0.105 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	}
	return $result
}


proc ::alt_mem_if::gui::common_ddrx_phy::_default_delta_dqs_arrival_time {family mem_format num_dimms num_ranks_per_dimm} {
	set result 0.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				REGISTERED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.003 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.03 }
						2 { set result 0.04 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.003 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.006 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				LOADREDUCED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.007 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.001 }
						2 { set result 0.119 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.007 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.001 }
						2 { set result 0.119 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	}
	return $result
}


proc ::alt_mem_if::gui::common_ddrx_phy::_default_read_dq_eye_reduction {family mem_format num_dimms num_ranks_per_dimm} {
	set result 0.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				LOADREDUCED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	}
	return $result
}


proc ::alt_mem_if::gui::common_ddrx_phy::_default_delta_read_dqs_arrival_time {family mem_format num_dimms num_ranks_per_dimm} {
	set result 0.0
	set protocol [_get_protocol]
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				LOADREDUCED { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
					4 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
						4 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {([string compare -nocase $family "STRATIXIV"] == 0) || ([string compare -nocase $family "ARRIAVIIGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {[string compare -nocase $family "ARRIAIIGX"] == 0} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "STRATIXV"] == 0) || ([string compare -nocase $family "ARRIAVGZ"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		} elseif {([string compare -nocase $family "CYCLONEV"] == 0) || ([string compare -nocase $family "ARRIAV"] == 0)} {
			switch $mem_format {
				default { switch $num_dimms {
					1 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
					2 { switch $num_ranks_per_dimm {
						1 { set result 0.0 }
						2 { set result 0.0 }
					}}
				}}
			}
		}
	}
	return $result
}



proc ::alt_mem_if::gui::common_ddrx_phy::_snap_to_supported_mem_fmax {f} {
	set protocol [_get_protocol]
	set supported_mem_fmax [alt_mem_if::gui::common_ddr_mem_model::_supported_mem_fmax $protocol]
	set last [expr {[llength $supported_mem_fmax] - 1}]
	for {set i 0} {$i < $last} {incr i} {
		set j [expr {$i + 1}]
		if {$f < [expr {([lindex $supported_mem_fmax $i] + [lindex $supported_mem_fmax $j]) / 2.0}]} { break }
	}
	return [lindex $supported_mem_fmax $i]
}

proc ::alt_mem_if::gui::common_ddrx_phy::_table_lookup {x_name y_name q_name a b} {
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

	set val [_bilinear_interpolate [lindex $x $x_index1] [lindex $x $x_index2] \
	                               [lindex $y $y_index1] [lindex $y $y_index2] \
	                               [lindex [lindex $q $x_index1] $y_index1] [lindex [lindex $q $x_index1] $y_index2] \
	                               [lindex [lindex $q $x_index2] $y_index1] [lindex [lindex $q $x_index2] $y_index2] $a $b]
	if {$val < -500} {
		_eprint "Error: unsupported derating value!"
	}
	return $val
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_ac_slew_rates {ddr_mode} {
	if {[regexp {^DDR3$} $ddr_mode ] == 1} {
		return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
	} elseif {[regexp {^DDR2$} $ddr_mode ] == 1} {
		return {4.0 3.5 3.0 2.5 2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.25 0.2 0.15 0.1}
	} elseif {[regexp {^LPDDR2$} $ddr_mode ] == 1} {
		return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
	} elseif {[regexp {^LPDDR1$} $ddr_mode ] == 1} {
		return {4.0 3.5 3.0 2.5 2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.25 0.2 0.15 0.1}
	} else {
		_error "Fatal Error: Unknown DDR mode $ddr_mode"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_ck_ckn_slew_rates {ddr_mode} {
	if {[regexp {^DDR3$} $ddr_mode ] == 1} {
		return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0}
	} elseif {[regexp {^DDR2$} $ddr_mode ] == 1} {
		return {2.0 1.5 1.0}
	} elseif {[regexp {^LPDDR2$} $ddr_mode ] == 1} {
		return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0}
	} elseif {[regexp {^LPDDR1$} $ddr_mode ] == 1} {
		return {2.0 1.5 1.0}
	} else {
		_error "Fatal Error: Unknown DDR mode $ddr_mode"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_dq_slew_rates {ddr_mode base_derating} {
	if {[regexp {^DDR3$} $ddr_mode ] == 1} {
		if {$base_derating == 1} {
			return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
		} else {
			return {4.0 3.5 3.0 2.5 2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
		}
	} elseif {[regexp {^DDR2$} $ddr_mode ] == 1} {
		return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
	} elseif {[regexp {^LPDDR2$} $ddr_mode ] == 1} {
		return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
	} elseif {[regexp {^LPDDR1$} $ddr_mode ] == 1} {
		return {2.0 1.5 1.0 0.9 0.8 0.7 0.6 0.5 0.4}
	} else {
		_error "Fatal Error: Unknown DDR mode $ddr_mode"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_dqs_dqsn_slew_rates {ddr_mode base_derating} {
	if {[regexp {^DDR3$} $ddr_mode ] == 1} {
		if {$base_derating == 1} {
			return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0}
		} else {
			return {8.0 7.0 6.0 5.0 4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0}
		}
	} elseif {[regexp {^DDR2$} $ddr_mode ] == 1} {
		return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0 0.8}
	} elseif {[regexp {^LPDDR2$} $ddr_mode ] == 1} {
		return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0}
	} elseif {[regexp {^LPDDR1$} $ddr_mode ] == 1} {
		return {4.0 3.0 2.0 1.8 1.6 1.4 1.2 1.0 0.8}
	} else {
		_error "Fatal Error: Unknown DDR mode $ddr_mode"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_ACvalue {protocol mem_fmax} {
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-15"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return 0.175
				}
				666.667 -
				800 {
					return 0.150
				}
				933.333 -
				1066.667 {
					return 0.135
				}				
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
		} elseif {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-135"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return 0.160
				}
				666.667 -
				800 {
					return 0.135
				}
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return 0.250
			}
			333.333 -
			400 -
			533.333 {
				return 0.200
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 {
				return 0.300
			}
			266.667 -
			333.333 -
			400 -
			533.333 {
				return 0.220
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return 0.250
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} else {
		_error "Fatal Error: Unknown DDR mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_DCvalue {protocol mem_fmax} {
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-15"] == 0} {
			return 0.100
		} elseif {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-135"] == 0} {
			return 0.090
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		return 0.125
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 {
				return 0.200
			}
			266.667 -
			333.333 -
			400 -
			533.333 {
				return 0.130
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		return 0.125
	} else {
		_error "Fatal Error: Unknown DDR mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_delta_tIS {protocol mem_fmax} {
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-15"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return {{ 88  88  88  96 104 112 120 128} \
					        { 59  59  59  67  75  83  91  99} \
					        {  0   0   0   8  16  24  32  40} \
					        { -2  -2  -2   6  14  22  30  38} \
					        { -6  -6  -6   2  10  18  26  34} \
					        {-11 -11 -11  -3   5  13  21  29} \
					        {-17 -17 -17  -9  -1   7  15  23} \
					        {-35 -35 -35 -27 -19 -11  -2   5} \
					        {-62 -62 -62 -54 -46 -38 -30 -22}}
				}
				666.667 -
				800 {
					return {{ 75  75  75  83  91  99 107 115} \
					        { 50  50  50  58  66  74  82  90} \
					        {  0   0   0   8  16  24  32  40} \
					        {  0   0   0   8  16  24  32  40} \
					        {  0   0   0   8  16  24  32  40} \
					        {  0   0   0   8  16  24  32  40} \
					        { -1  -1  -1   7  15  23  31  39} \
					        {-10 -10 -10  -2   6  14  22  30} \
					        {-25 -25 -25 -17  -9  -1   7  15}}
				}
				933.333 -
				1066.667 {
					return {{ 68  68  68  76  84  92 100 100} \
					        { 45  45  45  53  61  69  77  85} \
					        {  0   0   0   8  16  24  32  40} \
					        {  2   2   2  10  18  26  34  42} \
					        {  3   3   3  11  19  27  35  43} \
					        {  6   6   6  14  22  30  38  46} \
					        {  9   9   9  17  25  33  41  49} \
					        {  5   5   5  13  21  29  37  45} \
					        { -3  -3  -3   6  14  22  30  38}}
				}				
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
			
		} elseif {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-135"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return {{ 80  80  80  88  96 104 112 120} \
					        { 53  53  53  61  69  77  85  93} \
					        {  0   0   0   8  16  24  32  40} \
					        { -1  -1  -1   7  15  23  31  39} \
					        { -3  -3  -3   5  13  21  29  37} \
					        { -5  -5  -5   3  11  19  27  35} \
					        { -8  -8  -8   0   8  16  24  32} \
					        {-20 -20 -20 -12  -4   4  12  20} \
					        {-40 -40 -40 -32 -24 -16  -8   0}}
				}
				666.667 -
				800 {
					return {{ 68  68  45  76  84  92 100 108} \
					        { 45  45  30  53  61  69  77  85} \
					        {  0   0   0   8  16  24  32  40} \
					        {  2   2   2  10  18  26  34  42} \
					        {  3   3   3  11  19  27  35  43} \
					        {  6   6   6  14  22  30  38  46} \
					        {  9   9   9  17  25  33  41  49} \
					        {  5   5   5  13  21  29  37  45} \
					        { -3  -3  -3   6  14  22  30  38}}
				}
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
		} else {
			_eprint "Error: \"[get_parameter_value IO_STANDARD]\" is not a valid $protocol I/O Standard"
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{  187   217   247} \
				        {  179   209   239} \
				        {  167   197   227} \
				        {  150   180   210} \
				        {  125   155   185} \
				        {   83   113   143} \
				        {    0    30    60} \
				        {  -11    19    49} \
				        {  -25     5    35} \
				        {  -43   -13    17} \
				        {  -67   -37    -7} \
				        { -110   -80   -50} \
				        { -175  -145  -115} \
				        { -285  -255  -225} \
				        { -350  -320  -290} \
				        { -525  -495  -465} \
				        { -800  -770  -740} \
				        {-1450 -1420 -1390}}
			}
			333.333 -
			400 -
			533.333 {
				return {{  150   180   210} \
				        {  143   173   203} \
				        {  133   163   193} \
				        {  120   150   180} \
				        {  100   130   160} \
				        {   67    97   127} \
				        {    0    30    60} \
				        {   -5    25    55} \
				        {  -13    17    47} \
				        {  -22     8    38} \
				        {  -34    -4    26} \
				        {  -60   -30     0} \
				        { -100   -70   -40} \
				        { -168  -138  -108} \
				        { -200  -170  -140} \
				        { -325  -295  -265} \
				        { -517  -487  -457} \
				        {-1000  -970  -940}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 {
				return {{   150    150    150   -999   -999   -999   -999   -999} \
				        {   100    100    100    116   -999   -999   -999   -999} \
				        {     0      0      0     16     32   -999   -999   -999} \
				        {  -999     -4     -4     12     28     44   -999   -999} \
				        {  -999   -999    -12      4     20     36     52   -999} \
				        {  -999   -999   -999     -3     13     29     45     61} \
				        {  -999   -999   -999   -999      2     18     34     50} \
				        {  -999   -999   -999   -999   -999    -12      4     20} \
				        {  -999   -999   -999   -999   -999   -999    -35    -11}}
			}
			266.667 -
			333.333 -
			400 -
			533.333 {
				return {{   110    110    110   -999   -999   -999   -999   -999} \
				        {    74     73     73     89   -999   -999   -999   -999} \
				        {     0      0      0     16     32   -999   -999   -999} \
				        {  -999     -3     -3     13     29     45   -999   -999} \
				        {  -999   -999     -8      8     24     40     56   -999} \
				        {  -999   -999   -999      2     18     34     50     66} \
				        {  -999   -999   -999   -999     10     26     42     58} \
				        {  -999   -999   -999   -999   -999      4     20     36} \
				        {  -999   -999   -999   -999   -999   -999     -7     17}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{  187   217   247} \
				        {  179   209   239} \
				        {  167   197   227} \
				        {  150   180   210} \
				        {  125   155   185} \
				        {   83   113   143} \
				        {    0    30    60} \
				        {  -11    19    49} \
				        {  -25     5    35} \
				        {  -43   -13    17} \
				        {  -67   -37    -7} \
				        { -110   -80   -50} \
				        { -175  -145  -115} \
				        { -285  -255  -225} \
				        { -350  -320  -290} \
				        { -525  -495  -465} \
				        { -800  -770  -740} \
				        {-1450 -1420 -1390}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} else {
		_error "Fatal Error: Unknown DDR mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_delta_tIH {protocol mem_fmax} {
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-15"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return {{ 50  50  50  58  66  74  84 100} \
					        { 34  34  34  42  50  58  68  84} \
					        {  0   0   0   8  16  24  34  50} \
					        { -4  -4  -4   4  12  20  30  46} \
					        {-10 -10 -10  -2   6  14  24  40} \
					        {-16 -16 -16  -8   0   8  18  34} \
					        {-26 -26 -26 -18 -10  -2   8  24} \
					        {-40 -40 -40 -32 -24 -16  -6  10} \
					        {-60 -60 -60 -52 -44 -36 -26 -10}}
				}
				666.667 -
				800 {
					return {{ 50  50  50  58  66  74  84 100} \
					        { 34  34  34  42  50  58  68  84} \
					        {  0   0   0   8  16  24  34  50} \
					        { -4  -4  -4   4  12  20  30  46} \
					        {-10 -10 -10  -2   6  14  24  40} \
					        {-16 -16 -16  -8   0   8  18  34} \
					        {-26 -26 -26 -18 -10  -2   8  24} \
					        {-40 -40 -40 -32 -24 -16  -6  10} \
					        {-60 -60 -60 -52 -44 -36 -26 -10}}
				}
				933.333 -
				1066.667 {
					return {{ 50  50  50  58  66  74  84 100} \
					        { 34  34  34  42  50  58  68  84} \
					        {  0   0   0   8  16  24  34  50} \
					        { -4  -4  -4   4  12  20  30  46} \
					        {-10 -10 -10  -2   6  14  24  40} \
					        {-16 -16 -16  -8   0   8  18  34} \
					        {-26 -26 -26 -18 -10  -2   8  24} \
					        {-40 -40 -40 -32 -24 -16  -6  10} \
					        {-60 -60 -60 -52 -44 -36 -26 -10}}
				}			
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
			
		} elseif {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-135"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return {{ 45  45  45  53  61  69  79  95} \
					        { 30  30  30  38  46  54  64  80} \
					        {  0   0   0   8  16  24  34  50} \
					        { -3  -3  -3   5  13  21  31  47} \
					        { -8  -8  -8   1   9  17  27  43} \
					        {-13 -13 -13  -5   3  11  21  37} \
					        {-20 -20 -20 -12  -4   4  14  30} \
					        {-30 -30 -30 -22 -14  -6   4  20} \
					        {-45 -45 -45 -37 -29 -21 -11   5}}
				}
				666.667 -
				800 {	
					return {{ 45  45  45  53  61  69  79  95} \
					        { 30  30  30  38  46  54  64  80} \
					        {  0   0   0   8  16  24  34  50} \
					        { -3  -3  -3   5  13  21  31  47} \
					        { -8  -8  -8   1   9  17  27  43} \
					        {-13 -13 -13  -5   3  11  21  37} \
					        {-20 -20 -20 -12  -4   4  14  30} \
					        {-30 -30 -30 -22 -14  -6   4  20} \
					        {-45 -45 -45 -37 -29 -21 -11   5}}
				}
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
		} else {
			_eprint "Error: \"[get_parameter_value IO_STANDARD]\" is not a valid $protocol I/O Standard"
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{   94   124   154} \
				        {   89   119   149} \
				        {   83   113   143} \
				        {   75   105   135} \
				        {   45    75   105} \
				        {   21    51    81} \
				        {    0    30    60} \
				        {  -14    16    46} \
				        {  -31    -1    29} \
				        {  -54   -24     6} \
				        {  -83   -53   -23} \
				        { -125   -95   -65} \
				        { -188  -158  -128} \
				        { -292  -262  -232} \
				        { -375  -345  -315} \
				        { -500  -470  -440} \
				        { -708  -678  -648} \
				        {-1125 -1095 -1065}}
			}
			333.333 -
			400 -
			533.333 {
				return {{   94   124   154} \
				        {   89   119   149} \
				        {   83   113   143} \
				        {   75   105   135} \
				        {   45    75   105} \
				        {   21    51    81} \
				        {    0    30    60} \
				        {  -14    16    46} \
				        {  -31    -1    29} \
				        {  -54   -24     6} \
				        {  -83   -53   -23} \
				        { -125   -95   -65} \
				        { -188  -158  -128} \
				        { -292  -262  -232} \
				        { -375  -345  -315} \
				        { -500  -470  -440} \
				        { -708  -678  -648} \
				        {-1125 -1095 -1065}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 {
				return {{   100    100    100   -999   -999   -999   -999   -999} \
				        {    67     67     67     83   -999   -999   -999   -999} \
				        {     0      0      0     16     32   -999   -999   -999} \
				        {  -999     -8     -8      8     24     40   -999   -999} \
				        {  -999   -999    -20     -4     12     28     48   -999} \
				        {  -999   -999   -999    -18     -2     14     34     66} \
				        {  -999   -999   -999   -999    -21    -5      15     47} \
				        {  -999   -999   -999   -999   -999    -32    -12     20} \
				        {  -999   -999   -999   -999   -999   -999    -40     -8}}
			}
			266.667 -
			333.333 -
			400 -
			533.333 {
				return {{    65     65     65   -999   -999   -999   -999   -999} \
				        {    43     43     43     59   -999   -999   -999   -999} \
				        {     0      0      0     16     32   -999   -999   -999} \
				        {  -999     -5     -5     11     27     43   -999   -999} \
				        {  -999   -999    -13      3     19     35     55   -999} \
				        {  -999   -999   -999     -6     10     26     46     78} \
				        {  -999   -999   -999   -999     -3     13     33     65} \
				        {  -999   -999   -999   -999   -999     -4     16     48} \
				        {  -999   -999   -999   -999   -999   -999      2     34}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{   94   124   154} \
				        {   89   119   149} \
				        {   83   113   143} \
				        {   75   105   135} \
				        {   45    75   105} \
				        {   21    51    81} \
				        {    0    30    60} \
				        {  -14    16    46} \
				        {  -31    -1    29} \
				        {  -54   -24     6} \
				        {  -83   -53   -23} \
				        { -125   -95   -65} \
				        { -188  -158  -128} \
				        { -292  -262  -232} \
				        { -375  -345  -315} \
				        { -500  -470  -440} \
				        { -708  -678  -648} \
				        {-1125 -1095 -1065}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} else {
		_error "Fatal Error: Unknown DDR mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_delta_tDS {protocol mem_fmax base_derating} {
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-15"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return {{ 88  88  88  88  88  88  88  88} \
					        { 59  59  59  67  67  67  67  67} \
					        {  0   0   0   8  16  22  26  29} \
					        { -2  -2  -2   6  14  22  26  29} \
					        { -6  -6  -6   2  10  18  26  29} \
					        { -6  -6  -6  -3   5  13  21  29} \
					        { -6  -6  -6  -3  -1   7  15  23} \
					        {-11 -11 -11 -11 -11 -11  -2   5} \
					        {-30 -30 -30 -30 -30 -30 -30 -22}}
				}
				666.667 -
				800 {
					return {{ 75  75  75  75  75  75  75  75} \
					        { 50  50  50  58  58  58  58  58} \
					        {  0   0   0   8  16  24  32  40} \
					        {  0   0   0   8  16  24  32  40} \
					        {  0   0   0   8  16  24  32  40} \
					        {  0   0   0   8  16  24  32  40} \
					        {  0   0   0   8  15  23  31  39} \
					        {  0   0   0   8  14  14  22  30} \
					        {  0   0   0   7   7   7   7  15}}
				}
				933.333 -
				1066.667 {
					if {$base_derating == 1} {
						return {{ 68  68  68  68  68  68  68  68} \
								{ 45  45  45  53  53  53  53  53} \
								{  0   0   0   8  16  24  32  40} \
								{  0   2   2  10  18  26  32  40} \
								{  0   2   3  11  19  27  35  40} \
								{  0   2   3  14  22  30  38  46} \
								{  0   2   3  14  25  33  41  49} \
								{  0   2   3  14  25  29  37  45} \
								{  0   2   3  14  25  29  30  38}}
					} else {
						return {{34	34	34	42	50	58	66	74	82	90	98} \
								{29	29	29	29	37	45	53	61	69	77	85} \
								{23	23	23	23	23	31	39	47	55	63	71} \
								{18	14	14	14	14	14	22	30	38	46	54} \
								{13	9	0	0	0	0	0	8	16	24	32} \
								{8	4	-5	-23	-23	-23	-23	-15	-7	1	9} \
								{3	-1	-10	-29	-68	-68	-68	-60	-52	-44	-36} \
								{-2	-6	-15	-35	-66	-66	-66	-58	-50	-42	-34} \
								{-7	-11	-20	-41	-64	-64	-64	-56	-48	-40	-32} \
								{-12 -16	-25	-47	-53	-53	-53	-53	-45	-37	-29} \
								{-17 -21	-30	-43	-43	-43	-43	-43	-43	-35	-27} \
								{-22 -26	-35	-39	-39	-39	-39	-39	-39	-39	-31} \
								{-27 -31	-30	-30	-30	-30	-30	-30	-30	-30	-30}}
				
					}
				}			
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
		} elseif {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-135"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {   
					return {{ 80  80  80  80  80  80  80  80} \
					        { 53  53  53  61  61  61  61  61} \
					        {  0   0   0   8  16  23  29  35} \
					        { -1  -1  -1   7  15  23  29  35} \
					        { -3  -3  -3   5  13  21  29  35} \
					        { -3  -3  -3  -3  11  19  27  35} \
					        { -3  -3  -3  -3   8  16  24  32} \
					        { -3  -3  -3  -3   4   4  12  20} \
					        { -8  -8  -8  -8  -8  -8  -8   0}}

				}
				666.667 -
				800 {	
					return {{ 68  68  68  68  68  68  68  68} \
					        { 45  45  45  53  53  53  53  53} \
					        {  0   0   0   8  16  26  35  46} \
					        {  0   2   2  10  18  26  35  46} \
					        {  0   2   3  11  19  27  35  46} \
					        {  0   2   3  14  22  30  38  46} \
					        {  0   2   3  14  25  33  41  49} \
					        {  0   2   3  14  25  39  37  45} \
					        {  0   2   3  14  25  30  30  38}}

				}
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
		} else {
			_eprint "Error: \"[get_parameter_value IO_STANDARD]\" is not a valid $protocol I/O Standard"
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{ 125  125  125  125  125  125  125  125  125} \
				        {  83   83   83   95   95   95   95   95   95} \
				        {   0    0    0   12   24   25   25   25   25} \
				        { -11  -11  -11    1   13   25   25   25   25} \
				        { -25  -25  -25  -13   -1   11   23   23   23} \
				        { -31  -31  -31  -31  -19   -7    5   17   17} \
				        { -43  -43  -43  -43  -43  -31  -19   -7    5} \
				        { -74  -74  -74  -74  -74  -74  -62  -50  -38} \
				        {-127 -127 -127 -127 -127 -127 -127 -115 -103}}
			}
			333.333 -
			400 -
			533.333 {
				return {{ 100  100  100  100  100  100  100  100  100} \
				        {  67   67   67   79   79   79   79   79   79} \
				        {   0    0    0   12   24   31   35   38   38} \
				        {  -5   -5   -5    7   19   31   35   38   38} \
				        { -13  -13  -13   -1   11   23   35   38   38} \
				        { -13  -13  -13  -10    2   14   26   38   38} \
				        { -13  -13  -13  -10  -10    2   14   26   38} \
				        { -24  -24  -24  -24  -24  -24  -12    0   12} \
				        { -52  -52  -52  -52  -52  -52  -52  -40  -28}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 {
				return {{  150   150   150   -99   -99   -99   -99   -99} \
				        {  100   100   100   116   -99   -99   -99   -99} \
				        {    0     0     0    16    32   -99   -99   -99} \
				        {  -99    -4    -4    12    28    44   -99   -99} \
				        {  -99   -99   -12     4    20    36    52   -99} \
				        {  -99   -99   -99    -3    13    29    45    61} \
				        {  -99   -99   -99   -99     2    18    34    50} \
				        {  -99   -99   -99   -99   -99   -12     4    20} \
				        {  -99   -99   -99   -99   -99   -99   -35   -11}}
			}
			266.667 -
			333.333 -
			400 -
			533.333 {
				return {{  110   110   110   -99   -99   -99   -99   -99} \
				        {   74    73    73    89   -99   -99   -99   -99} \
				        {    0     0     0    16    32   -99   -99   -99} \
				        {  -99    -3    -3    13    29    45   -99   -99} \
				        {  -99   -99    -8     8    24    40    56   -99} \
				        {  -99   -99   -99     2    18    34    50    66} \
				        {  -99   -99   -99   -99    10    26    42    58} \
				        {  -99   -99   -99   -99   -99     4    20    36} \
				        {  -99   -99   -99   -99   -99   -99    -7    17}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{ 125  125  125  125  125  125  125  125  125} \
				        {  83   83   83   95   95   95   95   95   95} \
				        {   0    0    0   12   24   25   25   25   25} \
				        { -11  -11  -11    1   13   25   25   25   25} \
				        { -25  -25  -25  -13   -1   11   23   23   23} \
				        { -31  -31  -31  -31  -19   -7    5   17   17} \
				        { -43  -43  -43  -43  -43  -31  -19   -7    5} \
				        { -74  -74  -74  -74  -74  -74  -62  -50  -38} \
				        {-127 -127 -127 -127 -127 -127 -127 -115 -103}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} else {
		_error "Fatal Error: Unknown DDR mode $protocol"
	}
}


proc ::alt_mem_if::gui::common_ddrx_phy::_table_delta_tDH {protocol mem_fmax base_derating} {
	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-15"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return {{ 50  50  50  50  50  50  50  50} \
					        { 34  34  34  42  42  42  42  42} \
					        {  0   0   0   8  16  20  24  34} \
					        { -4  -4  -4   4  12  20  24  34} \
					        {-10 -10 -10  -2   6  14  24  34} \
					        {-10 -10 -10  -8   0   8  18  34} \
					        {-10 -10 -10 -10 -10  -2   8  24} \
					        {-16 -16 -16 -16 -16 -16  -6  10} \
					        {-26 -26 -26 -26 -26 -26 -26 -10}}
				}
				666.667 -
				800 {
					return {{ 50  50  50  50  50  50  50  50} \
					        { 34  34  34  42  42  42  42  42} \
					        {  0   0   0   8  16  20  24  34} \
					        { -4  -4  -4   4  12  20  24  34} \
					        {-10 -10 -10  -2   6  14  24  34} \
					        {-10 -10 -10  -8   0   8  18  34} \
					        {-10 -10 -10 -10 -10  -2   8  24} \
					        {-16 -16 -16 -16 -16 -16  -6  10} \
					        {-26 -26 -26 -26 -26 -26 -26 -10}}
				}
				933.333 -
				1066.667 {
					if {$base_derating == 1} {
						return {{ 50  50  50  50  50  50  50  50} \
								{ 34  34  34  42  42  42  42  42} \
								{  0   0   0   8  16  20  24  34} \
								{ -4  -4  -4   4  12  20  24  34} \
								{-10 -10 -10  -2   6  14  24  34} \
								{-10 -10 -10  -8   0   8  18  34} \
								{-10 -10 -10 -10 -10  -2   8  24} \
								{-16 -16 -16 -16 -16 -16  -6  10} \
								{-26 -26 -26 -26 -26 -26 -26 -10}}
					} else {
						return {{ 25  25	25	33	41	49	57	65	73	81	89} \
								{ 21  21	21	21	29	37	45	53	61	69	77} \
								{ 17  17	17	17	17	25	33	41	49	57	65} \
								{ 13  10	10	10	10	10	18	26	34	42	50} \
								{  9   6	0	0	0	0	0	8	16	24	32} \
								{  5   2	-4	-17	-17	-17	-17	-19	-11	-3	5} \
								{  1  -2	-8	-21	-50	-50	-50	-42	-34	-26	-18} \
								{ -3  -6	-12	-25	-54	-54	-54	-46	-38	-30	-22} \
								{ -7 -10	-16	-29	-60	-60	-60	-52	-40	-36	-26} \
								{-11 -14	-20	-33	-59	-59	-59	-59	-51	-43	-33} \
								{-15 -18	-24	-37	-61	-61	-61	-61	-61	-53	-43} \
								{-19 -22	-28	-41	-66	-66	-66	-66	-65	-66	-56} \
								{-23 -26	-32	-45	-73	-76	-76	-76	-69	-72	-76}}
					}
				}					
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
					
			
		} elseif {[string compare -nocase [get_parameter_value IO_STANDARD] "SSTL-135"] == 0} {
			switch $mem_fmax {
				400 -
				533.333 {
					return {{ 45  45  45  45  45  45  45  45}\
					        { 30  30  30  38  38  38  38  38}\
					        {  0   0   0   8  16  21  27  37}\
					        { -3  -3  -3   5  13  21  27  37}\
					        { -8  -8  -8   1   9  17  27  37}\
					        { -8  -8  -8  -5   3  11  21  37}\
					        { -8  -8  -8  -5  -4   4  14  30}\
					        { -8  -8  -8  -5  -4   6   4  20}\
					        {-11 -11 -11 -11 -11 -11 -11   5}}
				}
				666.667 -
				800 {
					return {{ 45  45  45  45  45  45  45  45}\
					        { 30  30  30  38  38  38  38  38}\
					        {  0   0   0   8  16  21  27  37}\
					        { -3  -3  -3   5  13  21  27  37}\
					        { -8  -8  -8   1   9  17  27  37}\
					        { -8  -8  -8  -5   3  11  21  37}\
					        { -8  -8  -8  -5  -4   4  14  30}\
					        { -8  -8  -8  -6  -6  -6   4  20}\
					        {-11 -11 -11 -11 -11 -11 -11   5}}

				}
				default {
					_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
				}
			}
		} else {
			_eprint "Error: \"[get_parameter_value IO_STANDARD]\" is not a valid $protocol I/O Standard"
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{  45   45   45   45   45   45   45   45   45} \
				        {  21   21   21   33   33   33   33   33   33} \
				        {   0    0    0   12   24   24   24   24   24} \
				        { -14  -14  -14   -2   10   22   22   22   22} \
				        { -31  -31  -31  -19   -7    5   17   17   17} \
				        { -42  -42  -42  -42  -30  -18   -6    6    6} \
				        { -59  -59  -59  -59  -59  -47  -35  -23  -11} \
				        { -89  -89  -89  -89  -89  -89  -77  -65  -53} \
				        {-140 -140 -140 -140 -140 -140 -140 -128 -116}}
			}
			333.333 -
			400 -
			533.333 {
				return {{  45   45   45   45   45   45   45   45   45} \
				        {  21   21   21   33   33   33   33   33   33} \
				        {   0    0    0   12   24   24   24   24   24} \
				        { -14  -14  -14   -2   10   22   22   22   22} \
				        { -31  -31  -31  -19   -7    5   17   17   17} \
				        { -42  -42  -42  -42  -30  -18   -6    6    6} \
				        { -59  -59  -59  -59  -59  -47  -35  -23  -11} \
				        { -89  -89  -89  -89  -89  -89  -77  -65  -53} \
				        {-140 -140 -140 -140 -140 -140 -140 -128 -116}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		switch $mem_fmax {
			200 {
				return {{  100   100   100   -99   -99   -99   -99   -99} \
				        {   67    67    67    83   -99   -99   -99   -99} \
				        {    0     0     0    16    32   -99   -99   -99} \
				        {  -99    -8    -8     8    24    40   -99   -99} \
				        {  -99   -99   -20    -4    12    28    48   -99} \
				        {  -99   -99   -99   -18    -2    14    34    66} \
				        {  -99   -99   -99   -99    -21   -5    15    47} \
				        {  -99   -99   -99   -99   -99   -32   -12    20} \
				        {  -99   -99   -99   -99   -99   -99   -40    -8}}
			}
			266.667 -
			333.333 -
			400 -
			533.333 {
				return {{   65    65    65   -99   -99   -99   -99   -99} \
				        {   43    43    43    59   -99   -99   -99   -99} \
				        {    0     0     0    16    32   -99   -99   -99} \
				        {  -99    -5    -5    11    27    43   -99   -99} \
				        {  -99   -99   -13     3    19    35    55   -99} \
				        {  -99   -99   -99    -6    10    26    46    78} \
				        {  -99   -99   -99   -99    -3    13    33    65} \
				        {  -99   -99   -99   -99   -99    -4    16    48} \
				        {  -99   -99   -99   -99   -99   -99     2    34}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		switch $mem_fmax {
			200 -
			266.667 {
				return {{  45   45   45   45   45   45   45   45   45} \
				        {  21   21   21   33   33   33   33   33   33} \
				        {   0    0    0   12   24   24   24   24   24} \
				        { -14  -14  -14   -2   10   22   22   22   22} \
				        { -31  -31  -31  -19   -7    5   17   17   17} \
				        { -42  -42  -42  -42  -30  -18   -6    6    6} \
				        { -59  -59  -59  -59  -59  -47  -35  -23  -11} \
				        { -89  -89  -89  -89  -89  -89  -77  -65  -53} \
				        {-140 -140 -140 -140 -140 -140 -140 -128 -116}}
			}
			default {
				_eprint "Error: \"[get_parameter_value MEM_CLK_FREQ_MAX]\" is not a valid memory speedgrade"
			}
		}
	} else {
		_error "Fatal Error: Unknown DDR mode $protocol"
	}
}

proc ::alt_mem_if::gui::common_ddrx_phy::_bilinear_interpolate {x1 x2 y1 y2 q11 q12 q21 q22 a b} {
	set r1 [_linear_interpolate $x1 $x2 $q11 $q21 $a]
	set r2 [_linear_interpolate $x1 $x2 $q12 $q22 $a]
	return [_linear_interpolate $y1 $y2 $r1 $r2 $b]
}


proc ::alt_mem_if::gui::common_ddrx_phy::_linear_interpolate {x1 x2 q1 q2 a} {
	return [expr {double($q1) + (($a - $x1) * ($q2 - $q1) / ($x2 - $x1))}]
}


proc ::alt_mem_if::gui::common_ddrx_phy::_reset_board_skews {} {
	set_parameter_value PACKAGE_DESKEW [get_parameter_property PACKAGE_DESKEW DEFAULT_VALUE]
	set_parameter_value AC_PACKAGE_DESKEW [get_parameter_property AC_PACKAGE_DESKEW DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_MAX_CK_DELAY [get_parameter_property TIMING_BOARD_MAX_CK_DELAY DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_MAX_DQS_DELAY [get_parameter_property TIMING_BOARD_MAX_DQS_DELAY DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MIN [get_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MIN DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_SKEW_CKDQS_DIMM_MAX [get_parameter_property TIMING_BOARD_SKEW_CKDQS_DIMM_MAX DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_SKEW_BETWEEN_DIMMS [get_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_SKEW_WITHIN_DQS [get_parameter_property TIMING_BOARD_SKEW_WITHIN_DQS DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_SKEW_BETWEEN_DQS [get_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_DQ_TO_DQS_SKEW [get_parameter_property TIMING_BOARD_DQ_TO_DQS_SKEW DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_AC_SKEW [get_parameter_property TIMING_BOARD_AC_SKEW DEFAULT_VALUE]
	set_parameter_value TIMING_BOARD_AC_TO_CK_SKEW [get_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DEFAULT_VALUE]
}


proc ::alt_mem_if::gui::common_ddrx_phy::_derive_parameters {} {

	variable ddr_mode
	set is_hps [regexp {^HPS$} $ddr_mode]

	set protocol [_get_protocol]

	_dprint 1 "Preparing to derive parametres for common_ddrx_phy"
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] == 0 || 
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "cyclonev"] == 0} {
		set_parameter_property HARD_EMIF VISIBLE true
		if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
			set_parameter_property HARD_EMIF ENABLED false
		} else {
			set_parameter_property HARD_EMIF ENABLED true
		}
	} else {
		set_parameter_property HARD_EMIF VISIBLE false
		set_parameter_property HARD_EMIF ENABLED false
	}

	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set_parameter_property PHY_ONLY ENABLED false
	} else {
		set_parameter_property PHY_ONLY ENABLED true
	}	

	if {([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		 [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 ||
		 [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || 
		 [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)} {
		set seriesv 1
	} else {
		set seriesv 0
	}

	if {$is_hps} {
		if {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_property MEM_VOLTAGE ENABLED true
			set_parameter_property MEM_VOLTAGE VISIBLE true
		} else {
			set_parameter_property MEM_VOLTAGE ENABLED false
			set_parameter_property MEM_VOLTAGE VISIBLE false
		}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] != 0) &&
			([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] != 0) &&
			([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] != 0) &&
			([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] != 0) } {
			set_parameter_property MEM_VOLTAGE ENABLED false
		} else {
			set_parameter_property MEM_VOLTAGE ENABLED true
		}
	}

	if {[regexp {^DDR2$|^LPDDR1$} $protocol] == 1} {
		set_parameter_property IO_STANDARD ALLOWED_RANGES {"SSTL-18"}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property IO_STANDARD ALLOWED_RANGES {"SSTL-15" "SSTL-135"}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_property IO_STANDARD ALLOWED_RANGES {"1.2-V HSUL"}
	}

	if {[regexp {^DDR2$|^LPDDR1$} $protocol] == 1} {
		set_parameter_value IO_STANDARD "SSTL-18"
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_VOLTAGE] "1.5V DDR3"] == 0} {
			set_parameter_value IO_STANDARD "SSTL-15"
		} else {
			set_parameter_value IO_STANDARD "SSTL-135"
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_value IO_STANDARD "1.2-V HSUL"
	}

	set_parameter_value PLL_PHASE_COUNTER_WIDTH 4


	set_parameter_value VCALIB_COUNT_WIDTH 2


	set dq_per_dqs [get_parameter_value MEM_DQ_PER_DQS]

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


	set_parameter_value VFIFO_AS_SHIFT_REG false
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		set_parameter_value VFIFO_AS_SHIFT_REG true
	} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
			set_parameter_value VFIFO_AS_SHIFT_REG true
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		set_parameter_value VFIFO_AS_SHIFT_REG true
	}


	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIII"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGX"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGZ"] == 0} {
		set_parameter_value HR_DDIO_OUT_HAS_THREE_REGS true
	} else {
		set_parameter_value HR_DDIO_OUT_HAS_THREE_REGS false
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
        
		set_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK false
        
		set_parameter_value PHY_CLKBUF true 
		set_parameter_value USE_LDC_FOR_ADDR_CMD true
		set_parameter_value REGISTER_C2P true
		
		set_parameter_value DUAL_WRITE_CLOCK true
		
		if {[regexp {^DDR2$} $protocol] == 1} {
			set_parameter_value MEM_CK_LDC_ADJUSTMENT_THRESHOLD 150
			set_parameter_value ENABLE_LDC_MEM_CK_ADJUSTMENT true
		}
		
	} else {
		set_parameter_value PHY_CLKBUF false
		set_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK false
		set_parameter_value USE_LDC_FOR_ADDR_CMD false
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
				set_parameter_value REGISTER_C2P false
			} elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
				set_parameter_value REGISTER_C2P true
			} else {
				set_parameter_value REGISTER_C2P true
			}
		} else {
			set_parameter_value REGISTER_C2P false
		}
		set_parameter_value DUAL_WRITE_CLOCK false
	}
	
	set mem_clk_frequency [get_parameter_value MEM_CLK_FREQ]
	set mem_clk_period [ expr {1000000.0 / $mem_clk_frequency} ]
	set mem_clk_ps [ expr {round($mem_clk_period)} ]
	set speed_grade [get_parameter_value SPEED_GRADE]
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 ||
	   [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
		if {$mem_clk_ps > 6667} {
	                _eprint "UniPHY doesn't support memory clock frequency less than 150 MHz for [::alt_mem_if::gui::system_info::get_device_family]"
		} elseif {($speed_grade >= 3) && (($mem_clk_ps > 2247) && ($mem_clk_ps < 4484)) } {
			set_parameter_value USE_DR_CLK true
			set_parameter_value DLL_USE_DR_CLK true
		} elseif {($speed_grade <= 2) && (($mem_clk_ps > 2083) && ($mem_clk_ps < 4166))} {
			set_parameter_value USE_DR_CLK true
			set_parameter_value DLL_USE_DR_CLK true
		} else {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		}
	}

	set hps_mode [expr [string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0]

	if {[::alt_mem_if::util::qini::cfg_is_on use_2x_dll_clock] == 1 } {
		_iprint "The DLL will be configured to use a 2x clock due to the ini use_2x_dll_clock"
		set_parameter_value USE_DR_CLK true
		set_parameter_value DLL_USE_DR_CLK true
	} elseif {([regexp {^LPDDR2$} $protocol] == 1)} {
		set_parameter_value USE_DR_CLK false
		set_parameter_value DLL_USE_DR_CLK false
	} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAV"] == 0 } {
		if { $hps_mode } {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		} elseif {$mem_clk_frequency < 250} {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		} elseif {$mem_clk_frequency < 450} {
			set_parameter_value USE_DR_CLK true
			set_parameter_value DLL_USE_DR_CLK true
		} else {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		}
	}  elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "CYCLONEV"] == 0} {
		if { $hps_mode } {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		} elseif {$mem_clk_frequency < 250} {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		} elseif {$mem_clk_frequency <= 400} {
			set_parameter_value USE_DR_CLK true
			set_parameter_value DLL_USE_DR_CLK true
		} else {
			set_parameter_value USE_DR_CLK false
			set_parameter_value DLL_USE_DR_CLK false
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {

		set cas_latency [get_parameter_value MR0_CAS_LATENCY]
		set additive_latency [get_parameter_value MR1_AL]

		set_parameter_value MEM_T_RL [expr {$cas_latency + $additive_latency}]
		set_parameter_value MEM_T_WL [expr {$cas_latency + $additive_latency - 1}]

		if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
			set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] + 1}]
			set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] + 1}]
		}

	} elseif {[regexp {^DDR3$} $protocol] == 1} {

		set cas_latency [expr {[get_parameter_value MR0_CAS_LATENCY] + 4}]
		set cas_write_latency [expr {[get_parameter_value MR2_CWL] + 5}]
		set additive_latency 0
		if {[get_parameter_value MR1_AL] >= 1 && [get_parameter_value MR1_AL] <= 2} {
			set additive_latency [expr {$cas_latency - [get_parameter_value MR1_AL]}]
		}

		set_parameter_value MEM_T_RL [expr {$cas_latency + $additive_latency}]
		set_parameter_value MEM_T_WL [expr {$cas_write_latency + $additive_latency}]

		if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
			set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] + 1}]
			set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] + 1}]
		}
		if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
			if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
				set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] + 2}]
			} elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
				set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] + 4}]
			} else {
				_eprint "Unsupported rate [get_parameter_value RATE] for LOADREDUCED devices"
			}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {

		set rlwl [list 0 0 0 1 2 2 3 4 4]
		set read_latency [expr {[get_parameter_value MR2_RLWL] + 2}]
		set write_latency [lindex $rlwl $read_latency]

		set_parameter_value MEM_T_RL [expr {$read_latency + ceil([expr 2500.0/$mem_clk_ps])}]
		
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set_parameter_value MEM_T_WL [expr {$write_latency + 2}]
		} else {
			set_parameter_value MEM_T_WL [expr {$write_latency + 1}]
		}

	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {

		set read_latency [get_parameter_value MR0_CAS_LATENCY]
		set write_latency 1

		set_parameter_value MEM_T_RL $read_latency
		set_parameter_value MEM_T_WL $write_latency

	}

	if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
		set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] - 1}]
	}
	
	if {[string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		} else {
			set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] + 1}]
			set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] + 1}]
		}
	}	
		
	if {[string compare -nocase [get_parameter_value REGISTER_C2P] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
			set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] + 1}]
		} else {
			set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] + 2}]
		}
	}	

	if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0 ||
	    [string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		if {[string compare -nocase [get_parameter_value HR_DDIO_OUT_HAS_THREE_REGS] "false"] == 0} {
			set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] + 1}]
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1 ||
		[regexp {^DDR3$} $protocol] == 1} {
	    if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0 &&
		    [string compare -nocase [get_parameter_value HR_DDIO_OUT_HAS_THREE_REGS] "false"] == 0} {
				set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] - 2}]
				set_parameter_value MEM_T_RL [expr {[get_parameter_value MEM_T_RL] - 2}]
		}
	}

	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0 &&
		([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0)} {
		set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] + 2}]
	}
	
	if {([regexp {^DDR3$} $ddr_mode] == 1) && 
		[get_parameter_value MEM_CLK_FREQ] > 800 && (
		([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0) || ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0))} {
		set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS -1
	} else {
		set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS [get_parameter_value FORCED_NUM_WRITE_FR_CYCLE_SHIFTS]
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
	
	if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {	
		set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 1
	} else {
		set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 0
	}
	
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			set mem_t_wl_with_pipeline [expr {[get_parameter_value MEM_T_WL] - 4}]
		} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
			set mem_t_wl_with_pipeline [expr {[get_parameter_value MEM_T_WL] - 2}]
		} else {
			set mem_t_wl_with_pipeline [expr {[get_parameter_value MEM_T_WL] - 1}]
		}
		
		if {$mem_t_wl_with_pipeline >= 0} {
			set_parameter_value MEM_T_WL $mem_t_wl_with_pipeline
			set_parameter_value NUM_WRITE_PATH_FLOP_STAGES [expr {[get_parameter_value NUM_WRITE_PATH_FLOP_STAGES] + 1}]
		}
	}
	
	if {[get_parameter_value NUM_WRITE_PATH_FLOP_STAGES] == 0} {
		set_parameter_value MEM_T_WL [expr {[get_parameter_value MEM_T_WL] - 1}]
	}
	
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		set_parameter_value NUM_AC_FR_CYCLE_SHIFTS [expr {3-([get_parameter_value MEM_T_WL]+2)%4}]
	} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		set_parameter_value NUM_AC_FR_CYCLE_SHIFTS [expr {1-([get_parameter_value MEM_T_WL])%2}]
	} else {
		set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 0
	}
		
	if {[regexp {^LPDDR1$} $protocol] == 1} {
	    set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 1
	}

	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		set qvld_stage [expr {[get_parameter_value MEM_T_RL] / 4}]
	} else {
		set qvld_stage [expr {[get_parameter_value MEM_T_RL] - 6}]
		if {[string compare -nocase [get_parameter_value VFIFO_AS_SHIFT_REG] "true"] == 0} {
			if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				set qvld_stage [expr $qvld_stage / 2 - 1]
			}
			if {$qvld_stage < 0} { set qvld_stage 0 }
		} else {
			if {$qvld_stage < 2} { set qvld_stage 2 }
		}
	}
	set_parameter_value QVLD_EXTRA_FLOP_STAGES $qvld_stage


	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 1
		}
	} else {
		if {[get_parameter_value MEM_BURST_LENGTH] == 2} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 0
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 1
		}
		if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set_parameter_value SEQ_BURST_COUNT_WIDTH 2
		}
	}

	set_parameter_value EARLY_ADDR_CMD_CLK_TRANSFER false
	if {[string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true"] == 0} {
	} elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
	} elseif {[regexp {^LPDDR2$} $protocol] == 1 &&
	          [string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
	} else {
		set_parameter_value EARLY_ADDR_CMD_CLK_TRANSFER true
	}



	set slew_rates [list TIMING_BOARD_CK_CKN_SLEW_RATE \
	                     TIMING_BOARD_AC_SLEW_RATE \
	                     TIMING_BOARD_DQS_DQSN_SLEW_RATE \
	                     TIMING_BOARD_DQ_SLEW_RATE]
	set slew_rates_applied [list TIMING_BOARD_CK_CKN_SLEW_RATE_APPLIED \
	                             TIMING_BOARD_AC_SLEW_RATE_APPLIED \
	                             TIMING_BOARD_DQS_DQSN_SLEW_RATE_APPLIED \
	                             TIMING_BOARD_DQ_SLEW_RATE_APPLIED]
	set setup_hold [list TIMING_BOARD_TIS \
	                     TIMING_BOARD_TIH \
	                     TIMING_BOARD_TDS \
	                     TIMING_BOARD_TDH]
	set setup_hold_applied [list TIMING_BOARD_TIS_APPLIED \
	                             TIMING_BOARD_TIH_APPLIED \
	                             TIMING_BOARD_TDS_APPLIED \
	                             TIMING_BOARD_TDH_APPLIED]
	set isi_params [list TIMING_BOARD_AC_EYE_REDUCTION_SU \
	                     TIMING_BOARD_AC_EYE_REDUCTION_H \
	                     TIMING_BOARD_DQ_EYE_REDUCTION \
	                     TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME \
	                     TIMING_BOARD_READ_DQ_EYE_REDUCTION \
	                     TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME]
	set isi_params_applied [list TIMING_BOARD_AC_EYE_REDUCTION_SU_APPLIED \
	                             TIMING_BOARD_AC_EYE_REDUCTION_H_APPLIED \
	                             TIMING_BOARD_DQ_EYE_REDUCTION_APPLIED \
	                             TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME_APPLIED \
	                             TIMING_BOARD_READ_DQ_EYE_REDUCTION_APPLIED \
	                             TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME_APPLIED]

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

	if {[string compare -nocase [get_parameter_value TIMING_BOARD_ISI_METHOD] "MANUAL"] == 0} {
		foreach param [concat $isi_params_applied ] {
			set_parameter_property $param VISIBLE FALSE
		}
		foreach param [concat $isi_params ] {
			set_parameter_property $param VISIBLE TRUE
		}
	} else {
		foreach param [concat $isi_params ] {
			set_parameter_property $param VISIBLE FALSE
		}
		foreach param [concat $isi_params_applied ] {
			set_parameter_property $param VISIBLE TRUE
		}
	}

	set is_discrete 0
	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "DISCRETE"] == 0} {
		set is_discrete 1
	}
	if {($is_discrete && [get_parameter_value DEVICE_DEPTH] > 1) ||
	    (!$is_discrete && [get_parameter_value MEM_NUMBER_OF_DIMMS] > 1)} {
		set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS VISIBLE TRUE
	} else {
		set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS VISIBLE FALSE
	}

	if {[string compare -nocase [get_parameter_value ADVANCED_CK_PHASES] "true"] == 0} {
		set_parameter_property COMMAND_PHASE ENABLED true
		set_parameter_property MEM_CK_PHASE ENABLED true
	} else {
		set_parameter_property COMMAND_PHASE ENABLED false
		set_parameter_property MEM_CK_PHASE ENABLED false
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
	    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set total_latency [expr {[get_parameter_value MEM_ATCL_INT] + [get_parameter_value MEM_TCL]} ]
		if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
			if { $total_latency > (16 - 4)} {
				set_parameter_value EXTRA_VFIFO_SHIFT [expr { 1 + ($total_latency - 16 + 4) / 2 }]
			}
		} elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			if { $total_latency > (4)} {
				set_parameter_value EXTRA_VFIFO_SHIFT [expr { 1 + ($total_latency) / 4 }]
			}
		}
	}	

	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set vfifo_offset [expr {16 - 4 * [get_parameter_value EXTRA_VFIFO_SHIFT]} ]
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]} + 6]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {($vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]) / 4}]
		} else {
			set vfifo_offset 8
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 6}]
			if { [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 } {
				set_parameter_value CALIB_LFIFO_OFFSET [expr {([get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 12) / 4 - 1}]
			} else {
				set_parameter_value CALIB_LFIFO_OFFSET [expr {([get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 12) / 4}]
			}
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			if {[regexp {^LPDDR2$} $protocol] == 1} {	
				set vfifo_offset [expr {1 + int(ceil([expr ([get_parameter_value TIMING_TDQSCK]-2500)/$mem_clk_ps]))}]
			} else {
				set vfifo_offset 0
			}
			set vfifo_offset [expr {$vfifo_offset - 2 * [get_parameter_value EXTRA_VFIFO_SHIFT]}]
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {($vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 4) / 2}]
		} else {
			set vfifo_offset 4
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 3}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {([get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 4) / 2}]	
		}
	} else {
		if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
		    if {[regexp {^LPDDR2$} $protocol] == 1} {	
				set vfifo_offset [expr {0 + int(ceil([expr ([get_parameter_value TIMING_TDQSCK]-2500)/$mem_clk_ps]))}]
			} else {
				set vfifo_offset 0
			}
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] - 2}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {[get_parameter_value MEM_T_RL]}]
		} else {
			set vfifo_offset 0
			set_parameter_value CALIB_VFIFO_OFFSET [expr {($vfifo_offset + [get_parameter_value MEM_T_RL]) * 2}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {[get_parameter_value MEM_T_RL] + 2}]
		}
		
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			if {([string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0)} {
				if {[string compare -nocase [get_parameter_value USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY] "true"] == 0} {
					if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
						set_parameter_value CALIB_VFIFO_OFFSET [ expr [get_parameter_value CALIB_VFIFO_OFFSET] + 1]
						set_parameter_value CALIB_LFIFO_OFFSET [ expr [get_parameter_value CALIB_LFIFO_OFFSET] + 1]
					}
				}
			}
		}

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

	if {[string compare -nocase [get_parameter_value ENABLE_LDC_MEM_CK_ADJUSTMENT] "true"] == 0} {
		if {[get_parameter_value MEM_CLK_FREQ] >= [get_parameter_value MEM_CK_LDC_ADJUSTMENT_THRESHOLD]} {
			if { [ string compare -nocase [get_parameter_value DLL_USE_DR_CLK] "true" ] == 0} {
				if {[get_parameter_value MEM_CK_PHASE] == 0} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 0
				} elseif {[get_parameter_value MEM_CK_PHASE] == 22.5} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 1
				} elseif {[get_parameter_value MEM_CK_PHASE] == 45} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 2
				} elseif {[get_parameter_value MEM_CK_PHASE] == 67.5} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 3
				} elseif {[get_parameter_value MEM_CK_PHASE] == 180} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 0
				} elseif {[get_parameter_value MEM_CK_PHASE] == 202.5} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 1
				} elseif {[get_parameter_value MEM_CK_PHASE] == 225} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 2
				} elseif {[get_parameter_value MEM_CK_PHASE] == 247.5} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 3
				} else {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 0
				}
			} else {
				if {[get_parameter_value MEM_CK_PHASE] == 0} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 0
				} elseif {[get_parameter_value MEM_CK_PHASE] == 45} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 1
				} elseif {[get_parameter_value MEM_CK_PHASE] == 90} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 2
				} elseif {[get_parameter_value MEM_CK_PHASE] == 135} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 3
				} elseif {[get_parameter_value MEM_CK_PHASE] == 180} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 0
				} elseif {[get_parameter_value MEM_CK_PHASE] == 225} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 1
				} elseif {[get_parameter_value MEM_CK_PHASE] == 270} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 2
				} elseif {[get_parameter_value MEM_CK_PHASE] == 315} {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT false
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 3
				} else {
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
					set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 0
				}
			}
		} else {
			set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT true
			set_parameter_value LDC_FOR_ADDR_CMD_MEM_CK_CPS_PHASE 0
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1 || [regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set_parameter_value NON_LDC_ADDR_CMD_MEM_CK_INVERT [get_parameter_value FORCED_NON_LDC_ADDR_CMD_MEM_CK_INVERT]
		}
	}

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		set_parameter_value NIOS_HEX_FILE_LOCATION "../"
	}
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set_parameter_value DUPLICATE_PLL_FOR_PHY_CLK true
	} else {
		set_parameter_value DUPLICATE_PLL_FOR_PHY_CLK false
	}

	set device_family [::alt_mem_if::gui::system_info::get_device_family]
	
	if {[string compare -nocase $device_family "STRATIXIII"] == 0 || [string compare -nocase $device_family "STRATIXIV"] == 0 ||
	    [string compare -nocase $device_family "ARRIAIIGX"] == 0 || [string compare -nocase $device_family "ARRIAIIGZ"] == 0} {
		set_parameter_value IO_SHIFT_DQS_EN_WHEN_SHIFT_DQS true
	} else {
		set_parameter_value IO_SHIFT_DQS_EN_WHEN_SHIFT_DQS false
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
}


proc ::alt_mem_if::gui::common_ddrx_phy::_derive_qvld_wr_address_offset {} {

	if {[expr {int([get_parameter_value PLL_WRITE_CLK_PHASE_DEG]) % 360}] >= 180} {
		set_parameter_value NEGATIVE_WRITE_CK_PHASE true
	} else {
		set_parameter_value NEGATIVE_WRITE_CK_PHASE false
	}

	if {[string compare -nocase [get_parameter_value VFIFO_AS_SHIFT_REG] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
			set qvld_wr_address_offset 2
			
			if {[string compare -nocase [get_parameter_value REGISTER_C2P] "true"] == 0} {
				incr qvld_wr_address_offset -2
			}
						
			incr qvld_wr_address_offset [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]
			incr qvld_wr_address_offset [get_parameter_value MEM_T_RL]
			incr qvld_wr_address_offset [expr {-4 * [get_parameter_value QVLD_EXTRA_FLOP_STAGES]}]
		} else {
			set qvld_wr_address_offset [expr {[get_parameter_value MEM_T_RL] - [get_parameter_value QVLD_EXTRA_FLOP_STAGES] - 1}]
			
			if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
				incr qvld_wr_address_offset [expr {-1 - [get_parameter_value QVLD_EXTRA_FLOP_STAGES]}]
			}
			
			if {[string compare -nocase [get_parameter_value REGISTER_C2P] "true"] == 0} {
				if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
					incr qvld_wr_address_offset -2
				} else {
					incr qvld_wr_address_offset -1
				}
			}

			incr qvld_wr_address_offset [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]
		}
	} else {
		set qvld_wr_address_offset [expr {[get_parameter_value MEM_T_RL] - [get_parameter_value QVLD_EXTRA_FLOP_STAGES]}]
		if {[string compare -nocase [get_parameter_value RATE] "half"] == 0 ||
		    [string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {

			incr qvld_wr_address_offset 3

	    	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
				incr qvld_wr_address_offset 3
			}
		}

	    if {[string compare -nocase [get_parameter_value NEGATIVE_WRITE_CK_PHASE] "true"] == 0} {
			incr qvld_wr_address_offset -1
		}

		incr qvld_wr_address_offset [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS]
	}
			
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0 ||
	    ([string compare -nocase [get_parameter_value RATE] "HALF"] == 0 &&
		 [string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0)} {
		if {[string compare -nocase [get_parameter_value HR_DDIO_OUT_HAS_THREE_REGS] "false"] == 0} {
			incr qvld_wr_address_offset
		}
	}

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			incr qvld_wr_address_offset -1
		}
	}

	set_parameter_value QVLD_WR_ADDRESS_OFFSET $qvld_wr_address_offset

}


proc ::alt_mem_if::gui::common_ddrx_phy::derive_ifdef_parameters {ifdef_array} {

	set protocol [_get_protocol]

	_dprint 1 "Preparing to derive ifdef parameters for common_ddrx_phy"
	upvar $ifdef_array ifdef_DB_array

	if {[regexp {^DDR2$} $protocol] == 1} {
		set ifdef_DB_array(IFDEF_DDR2) true
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set ifdef_DB_array(IFDEF_DDR3) true
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set ifdef_DB_array(IFDEF_LPDDR2) true
		set ifdef_DB_array(IFDEF_ADDR_CMD_DDR) true
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		set ifdef_DB_array(IFDEF_LPDDR1) true
	}

	if {[regexp {^DDR2$} $protocol] == 1 ||
		[regexp {^DDR3$} $protocol] == 1 ||
		[regexp {^LPDDR1$} $protocol] == 1} {
		set ifdef_DB_array(IFDEF_DDRX) true
	}

	set ifdef_DB_array(IFDEF_DDRX_LPDDRX) true
	
	set ifdef_DB_array(IFDEF_DQ_DDR) true
	
	set ifdef_DB_array(IFDEF_BIDIR_DQ_BUS) true

	if {[get_parameter_value SEQ_MODE] > 0} {
		set ifdef_DB_array(IFDEF_SEQUENCER_BRIDGE) true
		if {[get_parameter_value SEQ_MODE] == 2} {
			set ifdef_DB_array(IFDEF_SEQUENCER_BRIDGE_DDR) true
			if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0 &&
			    [expr {[get_parameter_value MEM_T_WL]%2}] != 0} {
				set ifdef_DB_array(IFDEF_SEQUENCER_BRIDGE_SHIFT_AC_BY_1FR_CYCLE) true
			} else {
				set ifdef_DB_array(IFDEF_SEQUENCER_BRIDGE_SHIFT_AC_BY_1FR_CYCLE) false
			}
		} else {
			set ifdef_DB_array(IFDEF_SEQUENCER_BRIDGE_DDR) false
		}
	} else {
		set ifdef_DB_array(IFDEF_SEQUENCER_BRIDGE) false
	}

	set ifdef_DB_array(IFDEF_SEQUENCER_QUARTER_RATE) false
	set ifdef_DB_array(IFDEF_SEQUENCER_HALF_RATE) false
	set ifdef_DB_array(IFDEF_SEQUENCER_FULL_RATE) false
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		set ifdef_DB_array(IFDEF_SEQUENCER_QUARTER_RATE) true
	} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		set ifdef_DB_array(IFDEF_SEQUENCER_HALF_RATE) true
	} elseif {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0 &&
	          [get_parameter_value SEQ_MODE] == 2} {
		set ifdef_DB_array(IFDEF_SEQUENCER_HALF_RATE) true
	}

	set ifdef_DB_array(IFDEF_VFIFO_QUARTER_RATE) false
	set ifdef_DB_array(IFDEF_VFIFO_HALF_RATE) false
	set ifdef_DB_array(IFDEF_VFIFO_FULL_RATE) false
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
			set ifdef_DB_array(IFDEF_VFIFO_QUARTER_RATE) true
		} else {
			set ifdef_DB_array(IFDEF_VFIFO_FULL_RATE) true
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
			set ifdef_DB_array(IFDEF_VFIFO_HALF_RATE) true
		} else {
			set ifdef_DB_array(IFDEF_VFIFO_FULL_RATE) true
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		set ifdef_DB_array(IFDEF_VFIFO_FULL_RATE) true
	}

	set ifdef_DB_array(IFDEF_CALIBRATION_MODE_FULL) false
	set ifdef_DB_array(IFDEF_CALIBRATION_MODE_QUICK) false
	set ifdef_DB_array(IFDEF_CALIBRATION_MODE_SKIP) false
	if {[string compare -nocase [get_parameter_value CALIBRATION_MODE] "FULL"] == 0} {
		set ifdef_DB_array(IFDEF_CALIBRATION_MODE_FULL) true
	} elseif {[string compare -nocase [get_parameter_value CALIBRATION_MODE] "QUICK"] == 0} {
		set ifdef_DB_array(IFDEF_CALIBRATION_MODE_QUICK) true
	} else {
		set ifdef_DB_array(IFDEF_CALIBRATION_MODE_SKIP) true
	}

	set param_list [list \
		MEM_IF_DM_PINS_EN \
		MEM_IF_DQSN_EN \
		MEM_LEVELING \
		NEGATIVE_WRITE_CK_PHASE \
		DUPLICATE_PLL_FOR_PHY_CLK \
		ENABLE_LDC_MEM_CK_ADJUSTMENT \
		LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT \
		NON_LDC_ADDR_CMD_MEM_CK_INVERT \
		USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY \
	]
	foreach param $param_list {
		if {[lsearch [split [get_parameters]] $param] != -1} {
			if {[string compare -nocase [get_parameter_value $param] "true"] == 0} {
				set ifdef_DB_array(IFDEF_$param) true
			} else {
				set ifdef_DB_array(IFDEF_$param) false
			}
		}
	}

}


::alt_mem_if::gui::common_ddrx_phy::_init


