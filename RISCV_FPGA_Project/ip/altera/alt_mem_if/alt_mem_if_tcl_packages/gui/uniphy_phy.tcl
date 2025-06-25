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


package provide alt_mem_if::gui::uniphy_phy 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gen::uniphy_pll
package require alt_mem_if::gui::uniphy_debug

namespace eval ::alt_mem_if::gui::uniphy_phy:: {

	namespace import ::alt_mem_if::util::messaging::*

}



proc ::alt_mem_if::gui::uniphy_phy::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for uniphy_phy"
	
	_create_derived_parameters
	
	_create_talkback_parameters

	::alt_mem_if::gen::uniphy_pll::create_pll_clock_parameters

	::alt_mem_if::gen::uniphy_pll::create_pll_cache_parameters

	_create_phy_parameters
	
	alt_mem_if::gui::uniphy_debug::register_debug_parameter ENABLE_NIOS_OCI [list 4]
	alt_mem_if::gui::uniphy_debug::register_debug_parameter DEPLOY_SEQUENCER_SW_FILES_FOR_DEBUG [list 4]
	alt_mem_if::gui::uniphy_debug::register_debug_parameter ENABLE_EMIT_JTAG_MASTER [list 1 2 3 4]
	alt_mem_if::gui::uniphy_debug::register_debug_parameter ENABLE_CSR_SOFT_RESET_REQ [list 1 2 3 4]
	alt_mem_if::gui::uniphy_debug::register_debug_parameter ENABLE_MAX_SIZE_SEQ_MEM [list 4]
	alt_mem_if::gui::uniphy_debug::register_debug_parameter MAKE_INTERNAL_NIOS_VISIBLE [list 4]
	alt_mem_if::gui::uniphy_debug::register_debug_parameter ENABLE_NIOS_PRINTF_OUTPUT [list 2 3]
	alt_mem_if::gui::uniphy_debug::register_debug_parameter ENABLE_LARGE_RW_MGR_DI_BUFFER [list 4]

	return 1
}


proc ::alt_mem_if::gui::uniphy_phy::validate_component {} {

	::alt_mem_if::gen::uniphy_pll::_derive_clock_parameters

	_derive_phy_parameters

	_dprint 1 "Preparing to validate component for uniphy_phy"
	
	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] == 0} {
		set_parameter_property NUM_PLL_SHARING_INTERFACES VISIBLE true
		set_parameter_property NUM_PLL_SHARING_INTERFACES ENABLED true
	} else {
		set_parameter_property NUM_PLL_SHARING_INTERFACES VISIBLE false
		set_parameter_property NUM_PLL_SHARING_INTERFACES ENABLED false
	}

	set validation_pass 1

	set validation_pass [::alt_mem_if::gen::uniphy_pll::validate_pll_reference_clock_range]


	if {[string compare -nocase [get_parameter_value PRE_V_SERIES_FAMILY] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] != 0 &&
		    [string compare -nocase [get_parameter_value PLL_SHARING_MODE] [get_parameter_value DLL_SHARING_MODE]] != 0} {
			_eprint "The '[get_parameter_property PLL_SHARING_MODE DISPLAY_NAME]' setting must match the '[get_parameter_property DLL_SHARING_MODE DISPLAY_NAME]' setting"
			set validation_pass 0
		}
	}

	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
		_wprint "PLL slave mode selected, PLL inputs must be connected to a Master Memory Controller or user generated PLL"
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixiii"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "stratixiv"] == 0 } {
		set_parameter_property HCX_COMPAT_MODE ENABLED TRUE
	} else {
		set_parameter_property HCX_COMPAT_MODE ENABLED FALSE
	}

	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {
			set_parameter_property PLL_LOCATION ENABLED TRUE
		} else {
			set_parameter_property PLL_LOCATION ENABLED FALSE
		}
	} else {
		set_parameter_property PLL_LOCATION ENABLED FALSE
	}

	return $validation_pass
}


proc ::alt_mem_if::gui::uniphy_phy::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for uniphy_phy"
	
	return 1
}


proc ::alt_mem_if::gui::uniphy_phy::_init {} {

	
}


proc ::alt_mem_if::gui::uniphy_phy::_create_talkback_parameters {} {


	::alt_mem_if::util::hwtcl_utils::_add_parameter TB_MEM_CLK_FREQ float 0.0
	set_parameter_property TB_MEM_CLK_FREQ VISIBLE FALSE
	set_parameter_property TB_MEM_CLK_FREQ DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TB_RATE STRING ""
	set_parameter_property TB_RATE VISIBLE FALSE
	set_parameter_property TB_RATE DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TB_MEM_IF_DQ_WIDTH integer 0
	set_parameter_property TB_MEM_IF_DQ_WIDTH VISIBLE FALSE
	set_parameter_property TB_MEM_IF_DQ_WIDTH DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TB_MEM_IF_READ_DQS_WIDTH integer 0
	set_parameter_property TB_MEM_IF_READ_DQS_WIDTH VISIBLE FALSE
	set_parameter_property TB_MEM_IF_READ_DQS_WIDTH DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter TB_PLL_DLL_MASTER boolean true
	set_parameter_property TB_PLL_DLL_MASTER VISIBLE FALSE
	set_parameter_property TB_PLL_DLL_MASTER DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter FAST_SIM_CALIBRATION boolean false
	set_parameter_property FAST_SIM_CALIBRATION VISIBLE FALSE
	set_parameter_property FAST_SIM_CALIBRATION DERIVED TRUE

}


proc ::alt_mem_if::gui::uniphy_phy::_derive_phy_parameters {} {

	_dprint 1 "Preparing to derive parameters for uniphy_phy"

	set_parameter_value TB_MEM_CLK_FREQ [get_parameter_value MEM_CLK_FREQ]
	set_parameter_value TB_RATE [string toupper [get_parameter_value RATE]]
	set_parameter_value TB_MEM_IF_DQ_WIDTH [get_parameter_value MEM_IF_DQ_WIDTH]
	set_parameter_value TB_MEM_IF_READ_DQS_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] == 0 ||
		 [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "master"] == 0 } {

			set_parameter_value TB_PLL_DLL_MASTER 1
	} else {
			set_parameter_value TB_PLL_DLL_MASTER 0
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		set_parameter_value CORE_PERIPHERY_DUAL_CLOCK true
	} else {
		set_parameter_value CORE_PERIPHERY_DUAL_CLOCK false
	}

	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		set_parameter_value USE_DR_CLK false
		set_parameter_value USE_2X_FF false
	} else {
		set_parameter_value USE_DR_CLK false
		set_parameter_value USE_2X_FF false
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		set_parameter_value GENERIC_PLL true
	} else {
		set_parameter_value GENERIC_PLL false
	}
	
	set_parameter_value USE_HARD_READ_FIFO false
	set_parameter_value READ_FIFO_HALF_RATE false
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		set_parameter_value USE_HARD_READ_FIFO true
	} else {
		if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0 ||
		    [string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			set_parameter_value READ_FIFO_HALF_RATE true
		}
	}

	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
		set_parameter_value PLL_MASTER false
	} else {
		set_parameter_value PLL_MASTER true
	}

	if {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] == 0} {
		set_parameter_value DLL_MASTER false
	} else {
		set_parameter_value DLL_MASTER true
	}

	set acds_version 13.1
	set_parameter_value PHY_VERSION_NUMBER [expr {int($acds_version * 10)}]

	if {[string compare -nocase [get_parameter_value USE_SEQUENCER_BFM] "true"] == 0} {
		set_parameter_value FAST_SIM_CALIBRATION true
	} else {
		set_parameter_value FAST_SIM_CALIBRATION false
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
	    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set_parameter_value READ_VALID_FIFO_SIZE 16
	} else {
		set_parameter_value READ_VALID_FIFO_SIZE 16
	}
	
}


proc ::alt_mem_if::gui::uniphy_phy::_create_phy_parameters {} {
	
	_dprint 1 "Preparing to create PHY parameters in uniphy_phy"

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_EXTRA_REPORTING BOOLEAN false
	set_parameter_property ENABLE_EXTRA_REPORTING VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_EXTRA_REPORT_PATH INTEGER 10
	set_parameter_property NUM_EXTRA_REPORT_PATH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_ISS_PROBES BOOLEAN false
	set_parameter_property ENABLE_ISS_PROBES VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CALIB_REG_WIDTH integer 8
	set_parameter_property CALIB_REG_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_SEQUENCER_BFM boolean false
	set_parameter_property USE_SEQUENCER_BFM VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DEFAULT_FAST_SIM_MODEL boolean true
	set_parameter_property DEFAULT_FAST_SIM_MODEL VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter PLL_SHARING_MODE STRING "None"
	set_parameter_property PLL_SHARING_MODE DISPLAY_NAME "PLL sharing mode"
	set_parameter_property PLL_SHARING_MODE DESCRIPTION "When set to \"No sharing\", a PLL block is instantiated but no PLL signals are exported.<br>When set to \"Master\", a PLL block is instantiated and the signals are exported.<br>When set to \"Slave\", a PLL interface is exposed and an external PLL Master must be connected to drive them."
	set_parameter_property PLL_SHARING_MODE ALLOWED_RANGES {"None:No sharing" "Master:Master" "Slave:Slave"}
	set_parameter_property PLL_SHARING_MODE AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_PLL_SHARING_INTERFACES INTEGER 1
	set_parameter_property NUM_PLL_SHARING_INTERFACES DISPLAY_NAME "Number of PLL sharing interfaces"
	set_parameter_property NUM_PLL_SHARING_INTERFACES DESCRIPTION "When set to \"No sharing\", a PLL block is instantiated but no PLL signals are exported.<br>When set to \"Master\", a PLL block is instantiated and the signals are exported.<br>When set to \"Slave\", a PLL interface is exposed and an external PLL Master must be connected to drive them."
	set_parameter_property NUM_PLL_SHARING_INTERFACES ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10}
	set_parameter_property NUM_PLL_SHARING_INTERFACES AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter EXPORT_AFI_HALF_CLK boolean false
	set_parameter_property EXPORT_AFI_HALF_CLK DISPLAY_NAME "Enable AFI half rate clock"
	set_parameter_property EXPORT_AFI_HALF_CLK DESCRIPTION "Enables a clock running at half the AFI clock rate on afi_half_clk."

	::alt_mem_if::util::hwtcl_utils::_add_parameter ABSTRACT_REAL_COMPARE_TEST boolean false
	set_parameter_property ABSTRACT_REAL_COMPARE_TEST VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter INCLUDE_BOARD_DELAY_MODEL boolean false
	set_parameter_property INCLUDE_BOARD_DELAY_MODEL VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter INCLUDE_MULTIRANK_BOARD_DELAY_MODEL boolean false
	set_parameter_property INCLUDE_MULTIRANK_BOARD_DELAY_MODEL VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_FAKE_PHY_INTERNAL boolean false
	set_parameter_property USE_FAKE_PHY_INTERNAL VISIBLE false
	set_parameter_property USE_FAKE_PHY_INTERNAL DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_FAKE_PHY boolean false
	set_parameter_property USE_FAKE_PHY VISIBLE false
	set_parameter_property USE_FAKE_PHY DISPLAY_NAME "Use Fake PHY"
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		set_parameter_property USE_FAKE_PHY VISIBLE true
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter FORCE_MAX_LATENCY_COUNT_WIDTH integer 0
	set_parameter_property FORCE_MAX_LATENCY_COUNT_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE boolean false
	set_parameter_property USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE VISIBLE false
	set_parameter_property USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_NON_DESTRUCTIVE_CALIB Boolean false
	set_parameter_property ENABLE_NON_DESTRUCTIVE_CALIB DISPLAY_NAME "Enables Non-Destructive Calibration"
	set_parameter_property ENABLE_NON_DESTRUCTIVE_CALIB DESCRIPTION "Select this option to enable refresh during calibration. Enabling this option forces the sequencer to post refreshes to memory during the calibration process to preserve memory contents."
	set_parameter_property ENABLE_NON_DESTRUCTIVE_CALIB VISIBLE false
	set_parameter_property ENABLE_NON_DESTRUCTIVE_CALIB DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter TRACKING_ERROR_TEST boolean false
	set_parameter_property TRACKING_ERROR_TEST VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter TRACKING_WATCH_TEST boolean false
	set_parameter_property TRACKING_WATCH_TEST VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MARGIN_VARIATION_TEST boolean false
	set_parameter_property MARGIN_VARIATION_TEST VISIBLE false
}


proc ::alt_mem_if::gui::uniphy_phy::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in uniphy_phy"

	::alt_mem_if::util::hwtcl_utils::_add_parameter CORE_PERIPHERY_DUAL_CLOCK BOOLEAN false
	set_parameter_property CORE_PERIPHERY_DUAL_CLOCK VISIBLE false		
	set_parameter_property CORE_PERIPHERY_DUAL_CLOCK DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_DR_CLK BOOLEAN false
	set_parameter_property USE_DR_CLK VISIBLE false		
	set_parameter_property USE_DR_CLK DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_USE_DR_CLK BOOLEAN false
	set_parameter_property DLL_USE_DR_CLK VISIBLE false		
	set_parameter_property DLL_USE_DR_CLK DERIVED true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_2X_FF BOOLEAN false
	set_parameter_property USE_2X_FF VISIBLE false		
	set_parameter_property USE_2X_FF DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter DUAL_WRITE_CLOCK boolean false
	set_parameter_property DUAL_WRITE_CLOCK VISIBLE FALSE
	set_parameter_property DUAL_WRITE_CLOCK DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter GENERIC_PLL boolean false
	set_parameter_property GENERIC_PLL VISIBLE false
	set_parameter_property GENERIC_PLL DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_HARD_READ_FIFO boolean false
	set_parameter_property USE_HARD_READ_FIFO VISIBLE false
	set_parameter_property USE_HARD_READ_FIFO DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter READ_FIFO_HALF_RATE boolean false
	set_parameter_property READ_FIFO_HALF_RATE VISIBLE false
	set_parameter_property READ_FIFO_HALF_RATE DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter PLL_MASTER boolean false
	set_parameter_property PLL_MASTER DERIVED true
	set_parameter_property PLL_MASTER VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_MASTER boolean false
	set_parameter_property DLL_MASTER DERIVED true
	set_parameter_property DLL_MASTER VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter PHY_VERSION_NUMBER integer 0
	set_parameter_property PHY_VERSION_NUMBER DERIVED true
	set_parameter_property PHY_VERSION_NUMBER VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_NIOS_OCI boolean false
	set_parameter_property ENABLE_NIOS_OCI DERIVED true
	set_parameter_property ENABLE_NIOS_OCI VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_EMIT_JTAG_MASTER boolean false
	set_parameter_property ENABLE_EMIT_JTAG_MASTER DERIVED true
	set_parameter_property ENABLE_EMIT_JTAG_MASTER VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_NIOS_JTAG_UART boolean false
	set_parameter_property ENABLE_NIOS_JTAG_UART DERIVED true
	set_parameter_property ENABLE_NIOS_JTAG_UART VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_NIOS_PRINTF_OUTPUT boolean false
	set_parameter_property ENABLE_NIOS_PRINTF_OUTPUT DERIVED true
	set_parameter_property ENABLE_NIOS_PRINTF_OUTPUT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_LARGE_RW_MGR_DI_BUFFER boolean false
	set_parameter_property ENABLE_LARGE_RW_MGR_DI_BUFFER DERIVED true
	set_parameter_property ENABLE_LARGE_RW_MGR_DI_BUFFER VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_EMIT_BFM_MASTER boolean false
	set_parameter_property ENABLE_EMIT_BFM_MASTER VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter FORCE_SEQUENCER_TCL_DEBUG_MODE boolean false
	set_parameter_property FORCE_SEQUENCER_TCL_DEBUG_MODE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_SEQUENCER_MARGINING_ON_BY_DEFAULT boolean false
	set_parameter_property ENABLE_SEQUENCER_MARGINING_ON_BY_DEFAULT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_MAX_SIZE_SEQ_MEM boolean false
	set_parameter_property ENABLE_MAX_SIZE_SEQ_MEM DERIVED true
	set_parameter_property ENABLE_MAX_SIZE_SEQ_MEM VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MAKE_INTERNAL_NIOS_VISIBLE boolean false
	set_parameter_property MAKE_INTERNAL_NIOS_VISIBLE DERIVED true
	set_parameter_property MAKE_INTERNAL_NIOS_VISIBLE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DEPLOY_SEQUENCER_SW_FILES_FOR_DEBUG boolean false
	set_parameter_property DEPLOY_SEQUENCER_SW_FILES_FOR_DEBUG DERIVED true
	set_parameter_property DEPLOY_SEQUENCER_SW_FILES_FOR_DEBUG VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_CSR_SOFT_RESET_REQ boolean false
	set_parameter_property ENABLE_CSR_SOFT_RESET_REQ DERIVED true
	set_parameter_property ENABLE_CSR_SOFT_RESET_REQ VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DUPLICATE_PLL_FOR_PHY_CLK boolean false
	set_parameter_property DUPLICATE_PLL_FOR_PHY_CLK DERIVED true
	set_parameter_property DUPLICATE_PLL_FOR_PHY_CLK VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MAX_LATENCY_COUNT_WIDTH integer 6
	set_parameter_property MAX_LATENCY_COUNT_WIDTH DERIVED true
	set_parameter_property MAX_LATENCY_COUNT_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter READ_VALID_FIFO_SIZE integer 16
	set_parameter_property READ_VALID_FIFO_SIZE DERIVED true
	set_parameter_property READ_VALID_FIFO_SIZE VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter EXTRA_VFIFO_SHIFT integer 0
	set_parameter_property EXTRA_VFIFO_SHIFT DERIVED true
	set_parameter_property EXTRA_VFIFO_SHIFT VISIBLE false
}


proc ::alt_mem_if::gui::uniphy_phy::create_ifdef_parameters {ifdef_array} {
	
	_dprint 1 "Preparing to create common UniPHY PHY ifdef parameters in uniphy_phy"
	upvar $ifdef_array ifdef_db_array

	set ifdef_db_array(IFDEF_AC_PARITY) false
	set ifdef_db_array(IFDEF_ADDR_CMD_DDR) false
	set ifdef_db_array(IFDEF_ADDR_CMD_PATH_FLOP_STAGE_POST_MUX) false
	set ifdef_db_array(IFDEF_ADD_DATA_CORRUPTION) false
	set ifdef_db_array(IFDEF_ADD_EFFICIENCY_MONITOR) false
	set ifdef_db_array(IFDEF_ADD_NOISE_GENERATOR) false
	set ifdef_db_array(IFDEF_ADD_OPENCORES_LOGIC) false
	set ifdef_db_array(IFDEF_ADD_REFRESH_MONITOR) false
	set ifdef_db_array(IFDEF_ADD_TEMP_SENSE) false
	set ifdef_db_array(IFDEF_ADD_UNIPHY_SIM_SVA) false
	set ifdef_db_array(IFDEF_ADD_USER_REFRESH_DRIVER) false
	set ifdef_db_array(IFDEF_AIIGZ_QDRII_x36) false
	set ifdef_db_array(IFDEF_ALTSYNCRAM) false
	set ifdef_db_array(IFDEF_ARRIAIIGX) false
	set ifdef_db_array(IFDEF_ARRIAIIGZ) false
	set ifdef_db_array(IFDEF_AUTO_POWERDN_EN) false
	set ifdef_db_array(IFDEF_AVL_USE_BE) false
	set ifdef_db_array(IFDEF_AVL_USE_BURSTBEGIN) false
	set ifdef_db_array(IFDEF_BIDIR_DQ_BUS) false
	set ifdef_db_array(IFDEF_BREAK_EXPORTED_AFI_CLK_DOMAIN) false
	set ifdef_db_array(IFDEF_BURST2) false
	set ifdef_db_array(IFDEF_BURST4) false
	set ifdef_db_array(IFDEF_BURST8) false
	set ifdef_db_array(IFDEF_CALIBRATION_MODE_FULL) false
	set ifdef_db_array(IFDEF_CALIBRATION_MODE_QUICK) false
	set ifdef_db_array(IFDEF_CALIBRATION_MODE_SKIP) false
	set ifdef_db_array(IFDEF_CFG_BURST_LENGTH) false
	set ifdef_db_array(IFDEF_CFG_INTERFACE_WIDTH) false
	set ifdef_db_array(IFDEF_CFG_REORDER_DATA) false
	set ifdef_db_array(IFDEF_CFG_STARVE_LIMIT) false
	set ifdef_db_array(IFDEF_CFG_TYPE) false
	set ifdef_db_array(IFDEF_CORE_PERIPHERY_DUAL_CLOCK) false	
	set ifdef_db_array(IFDEF_USE_DR_CLK) false	
	set ifdef_db_array(IFDEF_USE_LDC_FOR_ADDR_CMD) false	
	set ifdef_db_array(IFDEF_DLL_USE_DR_CLK) false	
	set ifdef_db_array(IFDEF_USE_2X_FF) false	
	set ifdef_db_array(IFDEF_DUAL_WRITE_CLOCK) false
	set ifdef_db_array(IFDEF_CTL_AUTOPCH_EN) false
	set ifdef_db_array(IFDEF_DUPLICATE_PLL_FOR_PHY_CLK) false
	set ifdef_db_array(IFDEF_NO_COMPLIMENTARY_STROBE) false
	set ifdef_db_array(IFDEF_CTL_BURST_LENGTH_IS_ONE) false
	set ifdef_db_array(IFDEF_PHY_CSR_ENABLED) false
	set ifdef_db_array(IFDEF_CTL_CS_WIDTH_IS_ONE) false
	set ifdef_db_array(IFDEF_CTL_ECC_AUTO_CORRECTION_ENABLED) false
	set ifdef_db_array(IFDEF_CTL_ECC_CSR_ENABLED) false
	set ifdef_db_array(IFDEF_CTL_ECC_ENABLED) false
	set ifdef_db_array(IFDEF_CTL_HRB_ENABLED) false
	set ifdef_db_array(IFDEF_CTL_ODT_ENABLED) false
	set ifdef_db_array(IFDEF_CTL_OUTPUT_REGD) false
	set ifdef_db_array(IFDEF_CTL_REGDIMM_ENABLED) false
	set ifdef_db_array(IFDEF_CTL_SELF_REFRESH_EN) false
	set ifdef_db_array(IFDEF_CTL_DEEP_POWERDN_EN) false
	set ifdef_db_array(IFDEF_CTL_TBP_NUM) false
	set ifdef_db_array(IFDEF_CTL_USR_REFRESH_EN) false
	set ifdef_db_array(IFDEF_DDR2) false
	set ifdef_db_array(IFDEF_DDR3) false
	set ifdef_db_array(IFDEF_DDRX) false
	set ifdef_db_array(IFDEF_DDRX_LPDDRX) false
	set ifdef_db_array(IFDEF_DEBUG_PLL_DYN_PHASE_SHIFT) false

	set ifdef_db_array(IFDEF_DECREASE_ONE_CTL_LATENCY) false
	set ifdef_db_array(IFDEF_DENALI_MEM_MODEL) false
	set ifdef_db_array(IFDEF_DQS_HACK) false
	set ifdef_db_array(IFDEF_RESERVED_PINS_FOR_DK_GROUP) false
	set ifdef_db_array(IFDEF_DQ_DDR) false
	set ifdef_db_array(IFDEF_USE_DQS_TRACKING) false
	set ifdef_db_array(IFDEF_USE_SHADOW_REGS) false
	set ifdef_db_array(IFDEF_PINGPONGPHY_EN) false
	set ifdef_db_array(USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE) false
	set ifdef_db_array(IFDEF_PACKAGE_DESKEW) false
	set ifdef_db_array(IFDEF_AC_PACKAGE_DESKEW) false
	set ifdef_db_array(IFDEF_EARLY_ADDR_CMD_CLK_TRANSFER) false
	set ifdef_db_array(IFDEF_EMULATED_MODE) false
	set ifdef_db_array(IFDEF_ENABLE_BURST_MERGE) false
	set ifdef_db_array(IFDEF_ENABLE_CSR_BFM) false
	set ifdef_db_array(IFDEF_ENABLE_DRIVER_SIM_STATUS) false
	set ifdef_db_array(IFDEF_ENABLE_HRB) false
	set ifdef_db_array(IFDEF_ENABLE_ISS_PROBES) false
	set ifdef_db_array(IFDEF_ENABLE_VCDPLUSON_SIM) false
	set ifdef_db_array(IFDEF_ERROR_DETECTION_ECC) false
	set ifdef_db_array(IFDEF_ERROR_DETECTION_PARITY) false
	set ifdef_db_array(IFDEF_EXPORT_BANK_INFO) false
	set ifdef_db_array(IFDEF_EXPORT_CSR_PORT) false
	set ifdef_db_array(IFDEF_EXPORT_DEBUG_PORT) false
	set ifdef_db_array(IFDEF_FULL_RATE) false
	set ifdef_db_array(IFDEF_GENERIC_MEM_MODEL) false
	set ifdef_db_array(IFDEF_GENERIC_PLL) false
	set ifdef_db_array(IFDEF_GRCIB) false
	set ifdef_db_array(IFDEF_HALF_RATE) false
	set ifdef_db_array(IFDEF_HAS_FINE_DELAY_SUPPORT) false
	set ifdef_db_array(IFDEF_HCX_COMPAT_MODE) false
	set ifdef_db_array(IFDEF_HR_DDIO_OUT_HAS_THREE_REGS) false
	set ifdef_db_array(IFDEF_LOCAL_ID_WIDTH) false
	set ifdef_db_array(IFDEF_LOW_LATENCY) false
	set ifdef_db_array(IFDEF_LPDDR2) false
	set ifdef_db_array(IFDEF_LPDDR1) false
	set ifdef_db_array(IFDEF_MEM_IF_CLK_PAIR_COUNT) false
	set ifdef_db_array(IFDEF_MEM_IF_DM_PINS_EN) false
	set ifdef_db_array(IFDEF_MEM_IF_DQSN_EN) false
	set ifdef_db_array(IFDEF_MEM_LEVELING) false
	set ifdef_db_array(IFDEF_MONITOR_T_REFC) false
	set ifdef_db_array(IFDEF_MULTICAST_EN) false
	set ifdef_db_array(IFDEF_MULTI_SIM_PASSFAIL_FACTOR) false
	set ifdef_db_array(IFDEF_NEGATIVE_WRITE_CK_PHASE) false
	set ifdef_db_array(IFDEF_NEXTGEN) false
	set ifdef_db_array(IFDEF_NIOS_SEQUENCER) false
	set ifdef_db_array(IFDEF_NO_BURST_COUNT) false
	set ifdef_db_array(IFDEF_PHY_CLKBUF) false	
	set ifdef_db_array(IFDEF_PLL_MASTER) false
	set ifdef_db_array(IFDEF_PLL_SLAVE) false
	set ifdef_db_array(IFDEF_DLL_MASTER) false
	set ifdef_db_array(IFDEF_DLL_SLAVE) false
	set ifdef_db_array(IFDEF_QDRII) false
	set ifdef_db_array(IFDEF_DDRII_SRAM) false
	set ifdef_db_array(IFDEF_QDRII_CALIB_CONT_READ) false
	set ifdef_db_array(IFDEF_QDRII_NORMAL) false
	set ifdef_db_array(IFDEF_QDRII_PLUS) false
	set ifdef_db_array(IFDEF_QDR_FR_BL2) false
	set ifdef_db_array(IFDEF_QDR_FR_BL4) false
	set ifdef_db_array(IFDEF_QDR_HR_BL4) false
	set ifdef_db_array(IFDEF_QDR_USE_NWS) false
	set ifdef_db_array(IFDEF_DDRII_SRAM_FR_BL2) false
	set ifdef_db_array(IFDEF_DDRII_SRAM_FR_BL4) false
	set ifdef_db_array(IFDEF_DDRII_SRAM_HR_BL4) false
	set ifdef_db_array(IFDEF_DDRII_SRAM_USE_NWS) false
	set ifdef_db_array(IFDEF_QUARTER_RATE) false
	set ifdef_db_array(IFDEF_RANK_PER_SLOT_1) false
	set ifdef_db_array(IFDEF_RDBUFFER_ADDR_WIDTH) false
	set ifdef_db_array(IFDEF_READ_FIFO_HALF_RATE) false
	set ifdef_db_array(IFDEF_REAL_PLL) false
	set ifdef_db_array(IFDEF_REGISTER_C2P) false
	set ifdef_db_array(IFDEF_RL2) false
	set ifdef_db_array(IFDEF_RLDRAMX) false
	set ifdef_db_array(IFDEF_RLDRAMII) false
	set ifdef_db_array(IFDEF_RLDRAM3) false
	set ifdef_db_array(IFDEF_RLDRAMII_X18) false
	set ifdef_db_array(IFDEF_RLDRAMII_X18_OR_X36) false
	set ifdef_db_array(IFDEF_RLDRAMII_X36) false
	set ifdef_db_array(IFDEF_RLDRAM3_X36) false
	set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_WCLK) false
	set ifdef_db_array(IFDEF_RLDRAMX_ODD_ALTDQ_DQS2_HAS_DM) false
	set ifdef_db_array(IFDEF_RTL_SIMULATION) false
	set ifdef_db_array(IFDEF_SEQUENCER_BRIDGE) false
	set ifdef_db_array(IFDEF_SEQUENCER_BRIDGE_DDR) false
	set ifdef_db_array(IFDEF_SEQUENCER_BRIDGE_SHIFT_AC_BY_1FR_CYCLE) false
	set ifdef_db_array(IFDEF_SEQUENCER_FULL_RATE) false
	set ifdef_db_array(IFDEF_SEQUENCER_HALF_RATE) false
	set ifdef_db_array(IFDEF_SEQUENCER_QUARTER_RATE) false
	set ifdef_db_array(IFDEF_SKIP_MEM_INIT) false
	set ifdef_db_array(IFDEF_SOPCB_COMPLIANT) false
	set ifdef_db_array(IFDEF_STRATIXIII) false
	set ifdef_db_array(IFDEF_STRATIXIV) false
	set ifdef_db_array(IFDEF_STRATIXV) false
	set ifdef_db_array(IFDEF_ARRIAVGZ) false
	set ifdef_db_array(IFDEF_SV_AVGZ) false
	set ifdef_db_array(IFDEF_ARRIAV) false
	set ifdef_db_array(IFDEF_CYCLONEV) false
	set ifdef_db_array(IFDEF_TIMING_SIMULATION) false
	set ifdef_db_array(IFDEF_UNIPHY_DRIVER_FORCE_ERROR) false
	set ifdef_db_array(IFDEF_USER_REFRESH) false
	set ifdef_db_array(IFDEF_USE_ALTDQ_DQS2) false
	set ifdef_db_array(IFDEF_USE_EFFMON_CSR_BFM) false
	set ifdef_db_array(IFDEF_USE_HARD_READ_FIFO) false
	set ifdef_db_array(IFDEF_USE_IO_CLOCK_DIVIDER) false
	set ifdef_db_array(IFDEF_USE_LDC_AS_LOW_SKEW_CLOCK) false	
	set ifdef_db_array(IFDEF_VENDOR_MEM_MODEL) false
	set ifdef_db_array(IFDEF_VFIFO_AS_SHIFT_REG) false
	set ifdef_db_array(IFDEF_VFIFO_FULL_RATE) false
	set ifdef_db_array(IFDEF_VFIFO_HALF_RATE) false
	set ifdef_db_array(IFDEF_VFIFO_QUARTER_RATE) false
	set ifdef_db_array(IFDEF_VMM_SIMPLE_DRIVER_TB) false
	set ifdef_db_array(IFDEF_WRBUFFER_ADDR_WIDTH) false
	set ifdef_db_array(IFDEF_MAKE_FIFOS_IN_ALTDQDQS) false
	set ifdef_db_array(IFDEF_MEM_IF_CQN_EN) false
	set ifdef_db_array(IFDEF_TRK_PARALLEL_SCC_LOAD) false
	set ifdef_db_array(IFDEF_USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY) false

	set ifdef_db_array(IFDEF_RTL_CALIB) false
	set ifdef_db_array(IFDEF_ENABLE_LDC_MEM_CK_ADJUSTMENT) false
	set ifdef_db_array(IFDEF_LDC_FOR_ADDR_CMD_MEM_CK_CPS_INVERT) false
}


proc ::alt_mem_if::gui::uniphy_phy::derive_ifdef_parameters {ifdef_array} {

	_dprint 1 "Preparing to derive ifdef parameters for uniphy_phy"
	upvar $ifdef_array ifdef_DB_array

	if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		set ifdef_DB_array(IFDEF_HALF_RATE) true
		set ifdef_DB_array(IFDEF_FULL_RATE) false
		set ifdef_DB_array(IFDEF_QUARTER_RATE) false
	} elseif {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		set ifdef_DB_array(IFDEF_FULL_RATE) true
		set ifdef_DB_array(IFDEF_HALF_RATE) false
		set ifdef_DB_array(IFDEF_QUARTER_RATE) false
	} elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		set ifdef_DB_array(IFDEF_FULL_RATE) false
		set ifdef_DB_array(IFDEF_HALF_RATE) false
		set ifdef_DB_array(IFDEF_QUARTER_RATE) true
	} else {
		_error "Fatal Error: Unknown rate [get_parameter_value RATE]"
	}
	
	if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
	    set ifdef_DB_array(IFDEF_USE_DQS_TRACKING) true
	} else {
	    set ifdef_DB_array(IFDEF_USE_DQS_TRACKING) false
	}

	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
	    set ifdef_DB_array(IFDEF_USE_SHADOW_REGS) true
	} else {
	    set ifdef_DB_array(IFDEF_USE_SHADOW_REGS) false
	}
	
	if {[string compare -nocase [get_parameter_value USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE] "true"] == 0} {
	    set ifdef_DB_array(IFDEF_USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE) true
	} else {
	    set ifdef_DB_array(IFDEF_USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE) false
	}
	
	set ifdef_DB_array(IFDEF_BURST2) false
	set ifdef_DB_array(IFDEF_BURST4) false
	set ifdef_DB_array(IFDEF_BURST8) false
	set ifdef_DB_array(IFDEF_NO_BURST_COUNT) false
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set ifdef_DB_array(IFDEF_BURST8) true
			set ifdef_DB_array(IFDEF_NO_BURST_COUNT) true
		}
	} elseif {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
		if {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set ifdef_DB_array(IFDEF_BURST4) true
			set ifdef_DB_array(IFDEF_NO_BURST_COUNT) true
		} elseif {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set ifdef_DB_array(IFDEF_BURST8) true
		}
	} else {
		if {[get_parameter_value MEM_BURST_LENGTH] == 2} {
			set ifdef_DB_array(IFDEF_BURST2) true
			set ifdef_DB_array(IFDEF_NO_BURST_COUNT) true
		} elseif {[get_parameter_value MEM_BURST_LENGTH] == 4} {
			set ifdef_DB_array(IFDEF_BURST4) true
		} elseif {[get_parameter_value MEM_BURST_LENGTH] == 8} {
			set ifdef_DB_array(IFDEF_BURST8) true
		}
	}
	
	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
		set ifdef_DB_array(IFDEF_PLL_SLAVE) true
		set ifdef_DB_array(IFDEF_PLL_MASTER) false
	} else {
		set ifdef_DB_array(IFDEF_PLL_MASTER) true
		set ifdef_DB_array(IFDEF_PLL_SLAVE) false
	}

	if { [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] == 0} {
		set ifdef_DB_array(IFDEF_DLL_SLAVE) true
		set ifdef_DB_array(IFDEF_DLL_MASTER) false
	} else {
		set ifdef_DB_array(IFDEF_DLL_MASTER) true
		set ifdef_DB_array(IFDEF_DLL_SLAVE) false
	}

	set ifdef_DB_array(IFDEF_RTL_SIMULATION) true
	set ifdef_DB_array(IFDEF_ARRIAIIGX) false
	set ifdef_DB_array(IFDEF_ARRIAIIGZ) false
	set ifdef_DB_array(IFDEF_STRATIXIII) false
	set ifdef_DB_array(IFDEF_STRATIXIV) false
	set ifdef_DB_array(IFDEF_STRATIXV) false
	set ifdef_DB_array(IFDEF_ARRIAVGZ) false
	set ifdef_DB_array(IFDEF_SV_AVGZ) false
	set ifdef_DB_array(IFDEF_ARRIAV) false
	set ifdef_DB_array(IFDEF_CYCLONEV) false
	set ifdef_DB_array(IFDEF_MAX10FPGA) false

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGX"] == 0} {
		set ifdef_DB_array(IFDEF_ARRIAIIGX) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGZ"] == 0} {
		set ifdef_DB_array(IFDEF_ARRIAIIGZ) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIII"] == 0} {
		set ifdef_DB_array(IFDEF_STRATIXIII) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIV"] == 0} {
		set ifdef_DB_array(IFDEF_STRATIXIV) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 } {
		set ifdef_DB_array(IFDEF_SV_AVGZ) true
		set ifdef_DB_array(IFDEF_STRATIXV) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0 } {
		set ifdef_DB_array(IFDEF_SV_AVGZ) true
		set ifdef_DB_array(IFDEF_ARRIAVGZ) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0} {
		set ifdef_DB_array(IFDEF_ARRIAV) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set ifdef_DB_array(IFDEF_CYCLONEV) true
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "MAX10FPGA"] == 0} {
		set ifdef_DB_array(IFDEF_MAX10FPGA) true
	}
	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set ifdef_DB_array(IFDEF_MAKE_FIFOS_IN_ALTDQDQS) true
	} else {
		set ifdef_DB_array(IFDEF_MAKE_FIFOS_IN_ALTDQDQS) false
	}
	
	set ifdef_DB_array(IFDEF_USE_ALTDQ_DQS2) true
	
	if {[string compare -nocase [get_parameter_value ENABLE_ISS_PROBES] "true"] == 0} {
		set ifdef_DB_array(IFDEF_ENABLE_ISS_PROBES) true
	} else {
		set ifdef_DB_array(IFDEF_ENABLE_ISS_PROBES) false
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		set ifdef_DB_array(IFDEF_HAS_FINE_DELAY_SUPPORT) true
	} else {
		set ifdef_DB_array(IFDEF_HAS_FINE_DELAY_SUPPORT) false
	}
	
	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		set ifdef_DB_array(IFDEF_NIOS_SEQUENCER) true
	} else {
		set ifdef_DB_array(IFDEF_NIOS_SEQUENCER) false
	}
	
	if {[string compare -nocase [get_parameter_value TRK_PARALLEL_SCC_LOAD] "true"] == 0} {
		set ifdef_DB_array(IFDEF_TRK_PARALLEL_SCC_LOAD) true
	} else {
		set ifdef_DB_array(IFDEF_TRK_PARALLEL_SCC_LOAD) false
	}

	
	set all_parameters_list [get_parameters]
	set param_list [list \
		AC_PARITY \
		CORE_PERIPHERY_DUAL_CLOCK \
		CTL_AUTOPCH_EN \
		CTL_ECC_AUTO_CORRECTION_ENABLED \
		CTL_ECC_CSR_ENABLED \
		CTL_ECC_ENABLED \
		CTL_HRB_ENABLED \
		CTL_ODT_ENABLED \
		CTL_OUTPUT_REGD \
		CTL_REGDIMM_ENABLED \
		CTL_SELF_REFRESH_EN \
		CTL_DEEP_POWERDN_EN \
		CTL_USR_REFRESH_EN \
		DLL_USE_DR_CLK \
		HCX_COMPAT_MODE \
		HR_DDIO_OUT_HAS_THREE_REGS \
		PHY_CLKBUF \
		SKIP_MEM_INIT \
		VFIFO_AS_SHIFT_REG \
		RESERVED_PINS_FOR_DK_GROUP \
		USE_HARD_READ_FIFO \
		USE_DR_CLK \
		USE_2X_FF \
		DUAL_WRITE_CLOCK \
		USE_LDC_AS_LOW_SKEW_CLOCK \
		USE_LDC_FOR_ADDR_CMD \
		READ_FIFO_HALF_RATE \
		REGISTER_C2P \
		GENERIC_PLL \
		PHY_CSR_ENABLED \
		USE_DQS_TRACKING \
		USE_SHADOW_REGS \
		PINGPONGPHY_EN \
		PACKAGE_DESKEW \
		AC_PACKAGE_DESKEW \
		EARLY_ADDR_CMD_CLK_TRANSFER \
		NO_COMPLIMENTARY_STROBE \
		USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE \
		EXPORT_AFI_HALF_CLK
	]

	foreach param $param_list {
		if {[lsearch [split $all_parameters_list] $param] != -1} {
			if {[string compare -nocase [get_parameter_value $param] "true"] == 0} {
				set ifdef_DB_array(IFDEF_$param) true
			} else {
				set ifdef_DB_array(IFDEF_$param) false
			}
		}
	}
	
	if {[lsearch [split $all_parameters_list] "EXPORT_CSR_PORT"] != -1} {
		if {[string compare -nocase [get_parameter_value EXPORT_CSR_PORT] "true"] == 0} {
			set ifdef_DB_array(IFDEF_EXPORT_CSR_PORT) true
		} else {
			set ifdef_DB_array(IFDEF_EXPORT_CSR_PORT) false
		}
	}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
	 	set ifdef_DB_array(IFDEF_RTL_CALIB) true
	} else {
		set ifdef_DB_array(IFDEF_RTL_CALIB) false
	}
	
}


::alt_mem_if::gui::uniphy_phy::_init


