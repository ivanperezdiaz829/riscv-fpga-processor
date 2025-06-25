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


package provide alt_mem_if::gui::qdrii_phy 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::uniphy_debug

namespace eval ::alt_mem_if::gui::qdrii_phy:: {

	namespace import ::alt_mem_if::util::messaging::*

}



proc ::alt_mem_if::gui::qdrii_phy::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for qdrii_phy"
	
	_create_derived_parameters

	_create_phy_parameters
	
	_create_board_settings_parameters

	alt_mem_if::gui::uniphy_debug::create_debug_parameters

	return 1
}


proc ::alt_mem_if::gui::qdrii_phy::create_phy_gui {} {

	_create_phy_parameters_gui
	
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		_create_interface_parameters_gui
	}

	return 1
}


proc ::alt_mem_if::gui::qdrii_phy::create_board_settings_gui {} {

	_create_board_settings_parameters_gui

	return 1
}


proc ::alt_mem_if::gui::qdrii_phy::create_diagnostics_gui {} {

	_create_diagnostics_gui

	return 1
}


proc ::alt_mem_if::gui::qdrii_phy::validate_component {} {

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixiii"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixiv"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriaiigx"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriaiigz"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0 || 
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] == 0} {
	} else {
		if {[string compare -nocase [get_module_property INTERNAL] "true"] != 0 &&
			[string compare -nocase [get_module_property INTERNAL] "1"] != 0} {
			_eprint "[get_module_property DESCRIPTION] is not supported by family [get_parameter_value DEVICE_FAMILY]"
		}
		return 0
	}

	set_parameter_property HARD_EMIF VISIBLE false
	set_parameter_property HARD_EMIF ENABLED false

	::alt_mem_if::gui::uniphy_debug::derive_debug_parameters

	::alt_mem_if::gen::uniphy_gen::derive_delay_params "QDRII"

	_derive_parameters

	::alt_mem_if::gen::uniphy_pll::derive_pll "QDRII"

	_dprint 1 "Preparing to validate component for qdrii_phy"
	
	set validation_pass 1

	if { [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriaiigz"] == 0 &&
		[get_parameter_value MEM_DQ_WIDTH] == 36 &&
		[get_parameter_value DEVICE_WIDTH] == 2 &&
		[string compare -nocase [get_parameter_value EMULATED_MODE] "false"] == 0} {

		_eprint "QDRII x72 without emulation is not supported in Arria II GZ"
		set validation_pass 0
	}

	set MEM_CLK_FREQ_MIN 119
	set MEM_CLK_FREQ_MAX 600
	if {[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1} {
		if {[get_parameter_value MEM_CLK_FREQ] < $MEM_CLK_FREQ_MIN || [get_parameter_value MEM_CLK_FREQ] > $MEM_CLK_FREQ_MAX} {
			_eprint "Memory clock frequency must be between $MEM_CLK_FREQ_MIN MHz and $MEM_CLK_FREQ_MAX MHz"
			set validation_pass 0
		} 
	} else {
			_eprint "Memory clock frequency must be between $MEM_CLK_FREQ_MIN MHz and $MEM_CLK_FREQ_MAX MHz"
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
		if {[::alt_mem_if::util::list_array::isnumber [get_parameter_value MEM_CLK_FREQ]] == 1 && [get_parameter_value MEM_CLK_FREQ] > 400} {
			_wprint "The memory clock frequency specified is above 400MHz and may require the high-performance Nios II-based sequencer to close timing"
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
				_iprint "D/BWS/Q/K/CQ pin package deskew is enabled - Ensure that the PCB is designed to compensate for the FPGA package skews"
			} else {
				_wprint "D/BWS/Q/K/CQ pin package skew may need to be compensated on the PCB for speeds above 800MHz to improve timing"
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
	
	
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
		
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] != 0 } {
			_eprint "The INI alt_mem_if_rtl_calib Is Only Supported for Stratix V"
			set validation_pass 0
		}

		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0 } {
			_eprint "The INI alt_mem_if_rtl_calib Is Only Valid For A QDRII External Memory Interface Using An RTL Sequencer"
			set validation_pass 0
		}

	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 } {
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] != 0 } {
			_eprint "RTL Sequencer is not supported for QDRII External Memory Interface with ArriaV"
			set validation_pass 0
		}
	}
	return $validation_pass
}

proc ::alt_mem_if::gui::qdrii_phy::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for qdrii_phy"
	
	return 1
}


proc ::alt_mem_if::gui::qdrii_phy::_init {} {
	

}

proc ::alt_mem_if::gui::qdrii_phy::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in qdrii_phy"

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

	::alt_mem_if::util::hwtcl_utils::_add_parameter HR_DDIO_OUT_HAS_THREE_REGS BOOLEAN false
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

proc ::alt_mem_if::gui::qdrii_phy::_create_phy_parameters {} {
	
	_dprint 1 "Preparing to create PHY parameters in qdrii_phy"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_ONLY boolean false
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

	::alt_mem_if::util::hwtcl_utils::_add_parameter IO_STANDARD STRING "1.5-V HSTL"
	set_parameter_property IO_STANDARD DISPLAY_NAME "I/O standard"
	set_parameter_property IO_STANDARD DESCRIPTION "I/O standard voltage."
	set_parameter_property IO_STANDARD ALLOWED_RANGES {"1.8-V HSTL" "1.5-V HSTL"}
	

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

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DM_PINS_EN boolean true
	set_parameter_property MEM_IF_DM_PINS_EN VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DQSN_EN boolean true
	set_parameter_property MEM_IF_DQSN_EN VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_LEVELING boolean false
	set_parameter_property MEM_LEVELING VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter READ_DQ_DQS_CLOCK_SOURCE string "DQS_BUS"
	set_parameter_property READ_DQ_DQS_CLOCK_SOURCE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQ_INPUT_REG_USE_CLKN boolean true
	set_parameter_property DQ_INPUT_REG_USE_CLKN VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQS_DQSN_MODE string "COMPLEMENTARY"
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


}




proc ::alt_mem_if::gui::qdrii_phy::_create_board_settings_parameters {} {
	
	_dprint 1 "Preparing to create board settings parameters in qdrii_phy"

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
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DISPLAY_NAME "D eye reduction"
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DESCRIPTION "The total reduction in the write eye diagram due to SI effects such as ISI/cross talk on D signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION Visible true
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION Units picoseconds
	set_parameter_property TIMING_BOARD_DQ_EYE_REDUCTION DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME integer 0
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DISPLAY_NAME "Delta K arrival time"
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DESCRIPTION "The increase in variation on the range of arrival times of K during a write due to SI effects.  Note it is assumed that the SI effects will cause K to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME Visible true
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME Units picoseconds
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_READ_DQ_EYE_REDUCTION Float 0
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DISPLAY_NAME "Q eye reduction"
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DESCRIPTION "The total reduction in the read eye diagram due to SI effects such as ISI/cross talk on Q signals.  Note it is assumed that the channel loss reduces the eye width symmetrically on the left and right side of the eye."
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION Units Nanoseconds
	set_parameter_property TIMING_BOARD_READ_DQ_EYE_REDUCTION DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME Float 0
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DISPLAY_NAME "Delta CQ arrival time"
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DESCRIPTION "The increase in variation on the range of arrival times of CQ during a read due to SI effects.  Note it is assumed that the SI effects will cause CQ to further vary symmetrically to the left and to the right."
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME Units Nanoseconds
	set_parameter_property TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME DISPLAY_HINT columns:10
	
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PACKAGE_DESKEW boolean false
	set_parameter_property PACKAGE_DESKEW DISPLAY_NAME "FPGA D/Q package skews deskewed on board"
	set_parameter_property PACKAGE_DESKEW DESCRIPTION "Improve timing margin by user compensation of D/BWS/Q/K/CQ FPGA package trace on PCB trace (Please see the External Memory Interface handbook for information regarding customer action)."
	set_parameter_property PACKAGE_DESKEW Visible false
	set_parameter_property PACKAGE_DESKEW DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_PACKAGE_DESKEW boolean false
	set_parameter_property AC_PACKAGE_DESKEW DISPLAY_NAME "FPGA Address/Command package skews deskewed on board"
	set_parameter_property AC_PACKAGE_DESKEW DESCRIPTION "Improve timing margin by user compensation of Address/Command FPGA package trace on PCB trace (Please see the External Memory Interface handbook for information regarding customer action)."
	set_parameter_property AC_PACKAGE_DESKEW Visible false
	set_parameter_property AC_PACKAGE_DESKEW DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_BETWEEN_DIMMS integer 0
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DISPLAY_NAME "Maximum delay difference between devices"
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DESCRIPTION "The maximum delay difference of data signals (i.e. Q, D, BWS) between devices.  
	For example, in a two-device configuration there is an extra propagation delay for data signals going to and coming back from the furthest device compared to the nearest device."
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS Visible true
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DIMMS ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_WITHIN_K integer 20
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_K DISPLAY_NAME "Maximum skew within write data group (i.e. K group)"
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_K DESCRIPTION "The maximum skew between D and BWS signals referenced by a common K signal."
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_K Visible true
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_K Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_K DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_K ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_WITHIN_CQ integer 20
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_CQ DISPLAY_NAME "Maximum skew within read data group (i.e. CQ group)"
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_CQ DESCRIPTION "The maximum skew between Q signals referenced by a common CQ signal."
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_CQ Visible true
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_CQ Units picoseconds
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_CQ DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_SKEW_WITHIN_CQ ALLOWED_RANGES {0:2000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW_BETWEEN_DQS integer 20
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DISPLAY_NAME "Maximum skew between CQ groups"
	set_parameter_property TIMING_BOARD_SKEW_BETWEEN_DQS DESCRIPTION "The maximum skew between CQ signals of different read data groups."
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
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DISPLAY_NAME "Average delay difference between Address/Command and K"
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DESCRIPTION "The value is equal to the average of the longest and the smallest Address/Command signal delay values, minus the delay of the K signal.  
	The value can be positive or negative."
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW Visible true
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW Units picoseconds
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_AC_TO_CK_SKEW ALLOWED_RANGES {-500:500}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DATA_TO_K_SKEW integer 0
	set_parameter_property TIMING_BOARD_DATA_TO_K_SKEW DISPLAY_NAME "Average delay difference between write data signals and K"
	set_parameter_property TIMING_BOARD_DATA_TO_K_SKEW DESCRIPTION "The value is equal to the average of the longest and the smallest write data signal delay values, minus the delay of the K signal.  
	Write data signals include the D and the BWS signals. The value can be positive or negative."
	set_parameter_property TIMING_BOARD_DATA_TO_K_SKEW Visible true
	set_parameter_property TIMING_BOARD_DATA_TO_K_SKEW Units picoseconds
	set_parameter_property TIMING_BOARD_DATA_TO_K_SKEW DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DATA_TO_K_SKEW ALLOWED_RANGES {-500:500}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_DATA_TO_CQ_SKEW integer 0
	set_parameter_property TIMING_BOARD_DATA_TO_CQ_SKEW DISPLAY_NAME "Average delay difference between read data signals and CQ"
	set_parameter_property TIMING_BOARD_DATA_TO_CQ_SKEW DESCRIPTION "The value is equal to the average of the longest and the smallest read data signal delay values, minus the delay of the CQ signal.  
	The value can be positive or negative."
	set_parameter_property TIMING_BOARD_DATA_TO_CQ_SKEW Visible true
	set_parameter_property TIMING_BOARD_DATA_TO_CQ_SKEW Units picoseconds
	set_parameter_property TIMING_BOARD_DATA_TO_CQ_SKEW DISPLAY_HINT columns:10
	set_parameter_property TIMING_BOARD_DATA_TO_CQ_SKEW ALLOWED_RANGES {-500:500}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_BOARD_SKEW integer 20
	set_parameter_property TIMING_BOARD_SKEW DISPLAY_NAME "Maximum board skew (data)"
	set_parameter_property TIMING_BOARD_SKEW DESCRIPTION "Maximum expected skew on data signals between FPGA and memory device."
	set_parameter_property TIMING_BOARD_SKEW Visible false
	set_parameter_property TIMING_BOARD_SKEW UNITS picoseconds
	set_parameter_property TIMING_BOARD_SKEW ALLOWED_RANGES {0:5000}
	
	return 1
}


proc ::alt_mem_if::gui::qdrii_phy::_create_phy_parameters_gui {} {

	_dprint 1 "Preparing to create PHY GUI in qdrii_phy"

	add_display_item "" id2 TEXT "<html>Generation of the QDR II and QDR II+ SRAM Controller with UniPHY produces unencrypted PHY and Controller HDL, <br>constraint scripts, an example design and a testbench for simulation.<br>"
	
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


proc ::alt_mem_if::gui::qdrii_phy::_create_diagnostics_gui {} {

	variable ddr_mode

	_dprint 1 "Preparing to create PHY diagnostics GUI in qdrii_phy"

	add_display_item "" "Diagnostics" GROUP "tab"
	add_display_item "Diagnostics" "Simulation Options" GROUP
	add_display_item "Simulation Options" CALIBRATION_MODE PARAMETER
	add_display_item "Simulation Options" SKIP_MEM_INIT PARAMETER
	add_display_item "Simulation Options" MEM_VERBOSE PARAMETER

	add_display_item "Diagnostics" "Debugging Options" GROUP
	alt_mem_if::gui::uniphy_debug::add_debug_display_items "Debugging Options"

}


proc ::alt_mem_if::gui::qdrii_phy::_create_board_settings_parameters_gui {} {

	_dprint 1 "Preparing to board settings GUI in qdrii_phy"

	add_display_item "" "Board Settings" GROUP "tab"
	add_display_item "Board Settings" bs1 TEXT "The following data should be based on board simulation:"

	add_display_item "Board Settings" "Channel Signal Integrity" GROUP
	add_display_item "Channel Signal Integrity" bs2 TEXT "<html>Channel Signal Integrity is a measure of the distortion of the eye due to intersymbol interference<br>or crosstalk or other effects. Typically when using a device depth greater than 1<br>there is an increase in the channel loss as there are multiple stubs causing<br>reflections. Please perform you channel signal integrity simulations and enter the extra channel<br>uncertainty."	
	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_SU parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_AC_EYE_REDUCTION_H parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DQ_EYE_REDUCTION parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_READ_DQ_EYE_REDUCTION parameter
	add_display_item "Channel Signal Integrity" TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME parameter	

	add_display_item "Board Settings" "Board Skews" GROUP
	add_display_item "Board Skews" bs3 TEXT "<html>PCB traces can have skews between them that can cause timing margins to be reduced.<br>"
	add_display_item "Board Skews" PACKAGE_DESKEW parameter
	add_display_item "Board Skews" AC_PACKAGE_DESKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_BETWEEN_DIMMS parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_WITHIN_K parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_WITHIN_CQ parameter
	add_display_item "Board Skews" TIMING_BOARD_SKEW_BETWEEN_DQS parameter
	add_display_item "Board Skews" TIMING_ADDR_CTRL_SKEW PARAMETER
	add_display_item "Board Skews" TIMING_BOARD_AC_TO_CK_SKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_DATA_TO_K_SKEW parameter
	add_display_item "Board Skews" TIMING_BOARD_DATA_TO_CQ_SKEW parameter
	
	return 1
}

proc ::alt_mem_if::gui::qdrii_phy::_create_interface_parameters_gui {} {

	_dprint 1 "Preparing to create interface GUI in qdrii_phy"

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

proc ::alt_mem_if::gui::qdrii_phy::_derive_parameters {} {

	_dprint 1 "Preparing to derive parametres for qdrii_phy"

	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set_parameter_property PHY_ONLY ENABLED false
	} else {
		set_parameter_property PHY_ONLY ENABLED true
	}	
	
	set_parameter_value PLL_PHASE_COUNTER_WIDTH 4

	set_parameter_value VCALIB_COUNT_WIDTH 2

	set_parameter_value QVLD_EXTRA_FLOP_STAGES 0
	
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

		if {$mem_clk_ps > 6667} {
	                _eprint "UniPHY doesn't support memory clock frequency less than 150 MHz for [::alt_mem_if::gui::system_info::get_device_family]"
		} elseif {$mem_clk_ps > 3333} {
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
		set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 0
		set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS 0		
		set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX false
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[string compare -nocase [get_parameter_value USE_LDC_AS_LOW_SKEW_CLOCK] "true"] == 0 ||
			[string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true"] == 0} {
			set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS [expr {[get_parameter_value MEM_T_WL] % 2}]
			set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 0
		} else {
			set effective_wl [get_parameter_value MEM_T_WL]
			if {[string compare -nocase [get_parameter_value HR_DDIO_OUT_HAS_THREE_REGS] "false"] == 0} {
				incr effective_wl 1
			}
			set_parameter_value NUM_AC_FR_CYCLE_SHIFTS [expr {$effective_wl%2}]
			set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS 0
		}
		set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 0
		set_parameter_value ADDR_CMD_PATH_FLOP_STAGE_POST_MUX false
		
	} else {
		set_parameter_value NUM_AC_FR_CYCLE_SHIFTS 0
		set_parameter_value NUM_WRITE_FR_CYCLE_SHIFTS 0		
		
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			set_parameter_value NUM_WRITE_PATH_FLOP_STAGES 0
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

	if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
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

	if {[string compare -nocase [get_parameter_value USE_HARD_READ_FIFO] "false"] == 0} {
		set rl_round_factor 0.5
	} else {
		if {[string compare -nocase [get_parameter_value USE_LDC_FOR_ADDR_CMD] "true"] == 0} {
			set rl_round_factor 2.0
		} else {
			if {[get_parameter_value MEM_T_RL] == 2.0} {
				set rl_round_factor 0.0
			} else {
				set rl_round_factor 1.5
			}
		}
	}
	set qvld_wr_address_offset [expr {int([get_parameter_value MEM_T_RL] + $rl_round_factor) - [get_parameter_value QVLD_EXTRA_FLOP_STAGES]}]
	if {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[string compare -nocase [get_parameter_value USE_HARD_READ_FIFO] "false"] == 0} {
			incr qvld_wr_address_offset -1
		}
		
		if {[string compare -nocase [get_parameter_value REGISTER_C2P] "true"] == 0} {
			incr qvld_wr_address_offset 2
		}		
	}

	if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
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
		set_parameter_value CALIB_LFIFO_OFFSET [expr {([get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 12) / 4}]
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set_parameter_value CALIB_VFIFO_OFFSET [expr {int([get_parameter_value MEM_T_RL]) + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 1}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {int([get_parameter_value MEM_T_RL]) + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 1}]
		} else {
			set vfifo_offset 4
			set_parameter_value CALIB_VFIFO_OFFSET [expr {$vfifo_offset + [get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 3}]
			set_parameter_value CALIB_LFIFO_OFFSET [expr {([get_parameter_value MEM_T_RL] + [get_parameter_value NUM_AC_FR_CYCLE_SHIFTS] + 4) / 2}]
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
}


proc ::alt_mem_if::gui::qdrii_phy::derive_ifdef_parameters {ifdef_array} {

	_dprint 1 "Preparing to derive ifdef parameters for qdrii_phy"
	upvar $ifdef_array ifdef_db_array

	set ifdef_db_array(IFDEF_QDRII) true

	set ifdef_db_array(IFDEF_MEM_IF_DM_PINS_EN) true

	set ifdef_db_array(IFDEF_MEM_IF_DQSN_EN) true
	set ifdef_db_array(IFDEF_MEM_IF_CQN_EN) true
	set family [::alt_mem_if::gui::system_info::get_device_family]
	if {[string compare -nocase $family "ARRIAV"] == 0 || [string compare -nocase $family "CYCLONEV"] == 0} {
		set ifdef_db_array(IFDEF_MEM_IF_CQN_EN) false
	}

	set ifdef_db_array(IFDEF_QDR_HR_BL4) false
	set ifdef_db_array(IFDEF_QDR_FR_BL2) false
	set ifdef_db_array(IFDEF_QDR_FR_BL4) false
	set ifdef_db_array(IFDEF_ADDR_CMD_DDR) false
	if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		
		if {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set ifdef_db_array(IFDEF_QDR_HR_BL4) true
		}
		
	} else {
		
		if {[get_parameter_value MEM_BURST_LENGTH] == 2} {
			
			set ifdef_db_array(IFDEF_QDR_FR_BL2) true
			
			set ifdef_db_array(IFDEF_ADDR_CMD_DDR) true
			
			set mem_dq_per_dqs [expr {[get_parameter_value MEM_DQ_WIDTH]/[get_parameter_value MEM_READ_DQS_WIDTH]}]
			if {$mem_dq_per_dqs % 2 == 0} {
				set ifdef_db_array(IFDEF_QDRII_CALIB_CONT_READ) true
			} else {
				set ifdef_db_array(IFDEF_QDRII_CALIB_CONT_READ) false
			}
		} elseif {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set ifdef_db_array(IFDEF_QDR_FR_BL4) true
		}
	}
	
	if {[get_parameter_value MEM_CS_WIDTH] == 1} {
		set ifdef_db_array(IFDEF_CTL_CS_WIDTH_IS_ONE) true
	} else {
		set ifdef_db_array(IFDEF_CTL_CS_WIDTH_IS_ONE) false
	}
	
	if {[string compare -nocase [get_parameter_value EMULATED_MODE] "true"] == 0} {
		set ifdef_db_array(IFDEF_EMULATED_MODE) true
	} else {
		set ifdef_db_array(IFDEF_EMULATED_MODE) false
	}
	
	if {[get_parameter_value MEM_DQ_WIDTH] == 8 && [get_parameter_value MEM_DM_WIDTH] == 2} {
		set ifdef_db_array(IFDEF_QDR_USE_NWS) true
	} else {
		set ifdef_db_array(IFDEF_QDR_USE_NWS) false
	}
	
	if {[get_parameter_value MEM_T_RL] == 2} {
		set ifdef_db_array(IFDEF_RL2) true
	} else {
		set ifdef_db_array(IFDEF_RL2) false
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

::alt_mem_if::gui::qdrii_phy::_init


