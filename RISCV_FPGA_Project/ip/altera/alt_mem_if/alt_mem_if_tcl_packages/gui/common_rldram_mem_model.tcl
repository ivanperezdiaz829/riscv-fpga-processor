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


package provide alt_mem_if::gui::common_rldram_mem_model 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils


namespace eval ::alt_mem_if::gui::common_rldram_mem_model:: {
	variable VALID_RLDRAM_MODES
	variable rldram_mode

	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::common_rldram_mem_model::_validate_rldram_mode {} {
	variable rldram_mode
		
	if {$rldram_mode == -1} {
		error "RLDRAM mode in [namespace current] in uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::common_rldram_mem_model::set_rldram_mode {in_rldram_mode} {
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


proc ::alt_mem_if::gui::common_rldram_mem_model::create_parameters {} {
	
	_dprint 1 "Preparing to create parameters for common_rldram_mem_model"
	
	_create_derived_parameters
	
	_create_memory_parameters_parameters
	
	_create_memory_timing_parameters
	
		
	return 1
}


proc ::alt_mem_if::gui::common_rldram_mem_model::create_gui {} {

	_create_memory_parameters_gui
	
	_create_memory_timing_gui
	
	return 1
}


proc ::alt_mem_if::gui::common_rldram_mem_model::validate_component {} {

	variable rldram_mode
	
	_validate_rldram_mode

	_derive_parameters

	_derive_mode_register_parameters

	set validation_pass 1
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		if {[get_parameter_value MEM_DQ_WIDTH] == 9} {
			if {[get_parameter_value MEM_READ_DQS_WIDTH] != 1 || [get_parameter_value MEM_WRITE_DQS_WIDTH] != 1} {
				_eprint "DK and QK width must be set to 1 when data width is set to 9"
				set validation_pass 0
			}
		} elseif {[get_parameter_value MEM_DQ_WIDTH] == 18 } {
			if {[get_parameter_value MEM_READ_DQS_WIDTH] != 2 || [get_parameter_value MEM_WRITE_DQS_WIDTH] != 1} {
				_eprint "DK width must be set to 1 and QK width must be set to 2 when data width is set to 18"
				set validation_pass 0
			}
		} elseif {[get_parameter_value MEM_DQ_WIDTH] == 36 } {
			if {[get_parameter_value MEM_READ_DQS_WIDTH] != 2 || [get_parameter_value MEM_WRITE_DQS_WIDTH] != 2} {
				_eprint "DK and QK width must be set to 2 when data width is set to 36"
				set validation_pass 0
			}
		}
		
		if {[get_parameter_value TIMING_TQKQ_MIN] > [get_parameter_value TIMING_TQKQ_MAX]} {
			_eprint "tQKQ_min must be less than tQKQ_max"
			set validation_pass 0
		}		
	} else {
		if {[get_parameter_value MEM_DQ_WIDTH] == 18 } {
			if {[get_parameter_value MEM_READ_DQS_WIDTH] != 2} {
				_eprint "QK width must be set to 2 when data width is set to 18"
				set validation_pass 0
			}
		} elseif {[get_parameter_value MEM_DQ_WIDTH] == 36 } {
			if {[get_parameter_value MEM_READ_DQS_WIDTH] != 4} {
				_eprint "QK width must be set to 4 when data width is set to 36"
				set validation_pass 0
			}
			if {[get_parameter_value MEM_BURST_LENGTH] == 8} {
				_eprint "Burst length must be set to 2 or 4 when data width is set to 36"
				set validation_pass 0
			}
		}
		
		set min_rd_to_wr [expr { [get_parameter_value MEM_BURST_LENGTH]/2 + [get_parameter_value MEM_T_RL] - [get_parameter_value MEM_T_WL] + 2}]
		if {[get_parameter_value TIMING_CONTROLLER_RD_TO_WR_NOP_COMMANDS] < $min_rd_to_wr} {
			_eprint "The \"Read-to-Write NOP commands\" parameter must be at least $min_rd_to_wr (i.e. (Burst Length / 2) + RL - WL + 2) to avoid DQ bus contention."
			set validation_pass 0
		}
		
		set min_wr_to_rd [expr { [get_parameter_value MEM_BURST_LENGTH]/2 + [get_parameter_value MEM_T_WL] - [get_parameter_value MEM_T_RL] + 1}]
		if {[get_parameter_value TIMING_CONTROLLER_WR_TO_RD_NOP_COMMANDS] < $min_wr_to_rd} {
			_eprint "The \"Write-to-Read NOP commands\" parameter must be at least $min_wr_to_rd (i.e. (Burst Length / 2) + WL - RL + 1) to avoid DQ bus contention."
			set validation_pass 0
		}
	}
	
	return $validation_pass
}

proc ::alt_mem_if::gui::common_rldram_mem_model::elaborate_component {} {
	return 1
}


proc ::alt_mem_if::gui::common_rldram_mem_model::_init {} {

variable VALID_RLDRAM_MODES
	
	::alt_mem_if::util::list_array::array_clean VALID_RLDRAM_MODES
	set VALID_RLDRAM_MODES(RLDRAMII) 1
	set VALID_RLDRAM_MODES(RLDRAM3) 1

	variable rldram_mode -1
	
}

proc ::alt_mem_if::gui::common_rldram_mem_model::_create_derived_parameters {} {

	variable rldram_mode

	_dprint 1 "Preparing to create derived parameters in common_rldram_mem_model"

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_WRITE_DQS_WIDTH INTEGER 0
	set_parameter_property MEM_IF_WRITE_DQS_WIDTH DERIVED true
	set_parameter_property MEM_IF_WRITE_DQS_WIDTH VISIBLE false

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

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_BANKADDR_WIDTH INTEGER 0
	set_parameter_property MEM_IF_BANKADDR_WIDTH DERIVED true
	set_parameter_property MEM_IF_BANKADDR_WIDTH VISIBLE false

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
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_MAX_NS float 2.5
	set_parameter_property MEM_CLK_MAX_NS DERIVED true
	set_parameter_property MEM_CLK_MAX_NS VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_MAX_PS float 2500
	set_parameter_property MEM_CLK_MAX_PS DERIVED true
	set_parameter_property MEM_CLK_MAX_PS VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_RC integer 0
	set_parameter_property MEM_T_RC DERIVED TRUE
	set_parameter_property MEM_T_RC VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_WL integer 0
	set_parameter_property MEM_T_WL DERIVED TRUE
	set_parameter_property MEM_T_WL VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_T_RL integer 0
	set_parameter_property MEM_T_RL DERIVED TRUE
	set_parameter_property MEM_T_RL VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_BURST_LENGTH integer 0
	set_parameter_property MRS_BURST_LENGTH DERIVED TRUE
	set_parameter_property MRS_BURST_LENGTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_ADDRESS_MUX integer 0
	set_parameter_property MRS_ADDRESS_MUX DERIVED TRUE
	set_parameter_property MRS_ADDRESS_MUX VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_DLL_RESET integer 0
	set_parameter_property MRS_DLL_RESET DERIVED TRUE
	set_parameter_property MRS_DLL_RESET VISIBLE false
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ADDR_WIDTH_MIN integer 10
		set_parameter_property MEM_ADDR_WIDTH_MIN DERIVED true
		set_parameter_property MEM_ADDR_WIDTH_MIN VISIBLE false
		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_NUMBER_OF_RANKS Integer 0
		set_parameter_property MEM_IF_NUMBER_OF_RANKS Visible false
		set_parameter_property MEM_IF_NUMBER_OF_RANKS Derived true
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ADDR_WIDTH_MIN integer 12
		set_parameter_property MEM_ADDR_WIDTH_MIN DERIVED true
		set_parameter_property MEM_ADDR_WIDTH_MIN VISIBLE false
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_DLL_ENABLE integer 0
		set_parameter_property MRS_DLL_ENABLE DERIVED TRUE
		set_parameter_property MRS_DLL_ENABLE VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_ZQ_CALIB_SELECTION integer 0
		set_parameter_property MRS_ZQ_CALIB_SELECTION DERIVED TRUE
		set_parameter_property MRS_ZQ_CALIB_SELECTION VISIBLE false

		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_ZQ_CALIB_ENABLE integer 0
		set_parameter_property MRS_ZQ_CALIB_ENABLE DERIVED TRUE
		set_parameter_property MRS_ZQ_CALIB_ENABLE VISIBLE false
	}
}


proc ::alt_mem_if::gui::common_rldram_mem_model::_create_memory_timing_parameters {} {
	
	variable rldram_mode
	
	_dprint 1 "Preparing to create memory timing parameters in common_rldram_mem_model"

	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_FREQ_MAX Float 533.3333
		set_parameter_property MEM_CLK_FREQ_MAX DISPLAY_NAME "Maximum memory clock frequency"
		set_parameter_property MEM_CLK_FREQ_MAX UNITS Megahertz
		set_parameter_property MEM_CLK_FREQ_MAX DESCRIPTION "The maximum frequency that the memory device can run at."
		set_parameter_property MEM_CLK_FREQ_MAX ALLOWED_RANGES {170.0:700.0}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_REFRESH_INTERVAL_NS integer 244
		set_parameter_property MEM_REFRESH_INTERVAL_NS DISPLAY_NAME "Refresh interval"
		set_parameter_property MEM_REFRESH_INTERVAL_NS DESCRIPTION "Refresh interval"
		set_parameter_property MEM_REFRESH_INTERVAL_NS UNITS nanoseconds
		set_parameter_property MEM_REFRESH_INTERVAL_NS ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCKH integer 45
		set_parameter_property TIMING_TCKH DESCRIPTION "Input Clock (K/K#) High expressed as a percentage of the full clock period."
		set_parameter_property TIMING_TCKH DISPLAY_NAME "tCKH (%)"
		set_parameter_property TIMING_TCKH ALLOWED_RANGES {1:99}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQKH integer 90
		set_parameter_property TIMING_TQKH DESCRIPTION "Read Clock (QK/QK#) High expressed as a percentage of tCKH"
		set_parameter_property TIMING_TQKH DISPLAY_NAME "tQKH (%)"
		set_parameter_property TIMING_TQKH ALLOWED_RANGES {1:99}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TAS integer 300
		set_parameter_property TIMING_TAS DESCRIPTION "Address and control setup to CK clock rise"
		set_parameter_property TIMING_TAS DISPLAY_NAME "tAS"
		set_parameter_property TIMING_TAS UNITS picoseconds
		set_parameter_property TIMING_TAS ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TAH integer 300
		set_parameter_property TIMING_TAH DESCRIPTION "Address and control hold after CK clock rise"
		set_parameter_property TIMING_TAH DISPLAY_NAME "tAH"
		set_parameter_property TIMING_TAH UNITS picoseconds
		set_parameter_property TIMING_TAH ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDS integer 170
		set_parameter_property TIMING_TDS DESCRIPTION "Data setup to clock (K/K#) rise"
		set_parameter_property TIMING_TDS DISPLAY_NAME "tDS"
		set_parameter_property TIMING_TDS UNITS picoseconds
		set_parameter_property TIMING_TDS ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDH integer 170
		set_parameter_property TIMING_TDH DESCRIPTION "Data hold after clock (K/K#) rise"
		set_parameter_property TIMING_TDH DISPLAY_NAME "tDH"
		set_parameter_property TIMING_TDH UNITS picoseconds
		set_parameter_property TIMING_TDH ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQKQ_MAX integer 120
		set_parameter_property TIMING_TQKQ_MAX DESCRIPTION "QK clock edge to DQ data edge (in same group)"
		set_parameter_property TIMING_TQKQ_MAX DISPLAY_NAME "tQKQ_max"
		set_parameter_property TIMING_TQKQ_MAX UNITS picoseconds
		set_parameter_property TIMING_TQKQ_MAX ALLOWED_RANGES {-5000:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQKQ_MIN integer -120
		set_parameter_property TIMING_TQKQ_MIN DESCRIPTION "QK clock edge to DQ data edge (in same group)"
		set_parameter_property TIMING_TQKQ_MIN DISPLAY_NAME "tQKQ_min"
		set_parameter_property TIMING_TQKQ_MIN UNITS picoseconds
		set_parameter_property TIMING_TQKQ_MIN ALLOWED_RANGES {-5000:5000}

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCKDK_MAX integer 1000
		set_parameter_property TIMING_TCKDK_MAX DESCRIPTION "Clock to Input Data Clock (Max)"
		set_parameter_property TIMING_TCKDK_MAX DISPLAY_NAME "tCKDK_max"
		set_parameter_property TIMING_TCKDK_MAX UNITS picoseconds
		set_parameter_property TIMING_TCKDK_MAX ALLOWED_RANGES {-5000:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCKDK_MIN integer -300
		set_parameter_property TIMING_TCKDK_MIN DESCRIPTION "Clock to Input Data Clock (Min)"
		set_parameter_property TIMING_TCKDK_MIN DISPLAY_NAME "tCKDK_min"
		set_parameter_property TIMING_TCKDK_MIN UNITS picoseconds
		set_parameter_property TIMING_TCKDK_MIN ALLOWED_RANGES {-5000:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCKQK_MAX integer 300
		set_parameter_property TIMING_TCKQK_MAX DESCRIPTION "QK edge to clock edge skew (Max)"
		set_parameter_property TIMING_TCKQK_MAX DISPLAY_NAME "tCKQK_max"
		set_parameter_property TIMING_TCKQK_MAX UNITS picoseconds
		set_parameter_property TIMING_TCKQK_MAX ALLOWED_RANGES {-5000:5000}		
	
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_FREQ_MAX Float 800.0000
		set_parameter_property MEM_CLK_FREQ_MAX DISPLAY_NAME "Maximum memory clock frequency"
		set_parameter_property MEM_CLK_FREQ_MAX UNITS Megahertz
		set_parameter_property MEM_CLK_FREQ_MAX DESCRIPTION "The maximum frequency that the memory device can run at."
		set_parameter_property MEM_CLK_FREQ_MAX ALLOWED_RANGES {200.0:1067.0}

		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_REFRESH_INTERVAL_NS integer 5000
		set_parameter_property MEM_REFRESH_INTERVAL_NS DISPLAY_NAME "Refresh interval"
		set_parameter_property MEM_REFRESH_INTERVAL_NS DESCRIPTION "Refresh interval"
		set_parameter_property MEM_REFRESH_INTERVAL_NS UNITS nanoseconds
		set_parameter_property MEM_REFRESH_INTERVAL_NS ALLOWED_RANGES {0:5000}
		set_parameter_property MEM_REFRESH_INTERVAL_NS VISIBLE false
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDS integer 10
		set_parameter_property TIMING_TDS DESCRIPTION "Base specification for data setup to DK"
		set_parameter_property TIMING_TDS DISPLAY_NAME "tDS (base)"
		set_parameter_property TIMING_TDS UNITS picoseconds
		set_parameter_property TIMING_TDS ALLOWED_RANGES {-100:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDH integer 45
		set_parameter_property TIMING_TDH DESCRIPTION "Base specification for data hold from DK"
		set_parameter_property TIMING_TDH DISPLAY_NAME "tDH (base)"
		set_parameter_property TIMING_TDH UNITS picoseconds
		set_parameter_property TIMING_TDH ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQKQ_MAX integer 100
		set_parameter_property TIMING_TQKQ_MAX DESCRIPTION "QK clock edge to DQ data edge (in same group)."
		set_parameter_property TIMING_TQKQ_MAX DISPLAY_NAME "tQKQ_max"
		set_parameter_property TIMING_TQKQ_MAX UNITS picoseconds
		set_parameter_property TIMING_TQKQ_MAX ALLOWED_RANGES {-5000:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQH float 0.38
		set_parameter_property TIMING_TQH DESCRIPTION "DQ output hold time from QK"
		set_parameter_property TIMING_TQH DISPLAY_NAME "tQH (% of CK)"
		set_parameter_property TIMING_TQH ALLOWED_RANGES {-1:1}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCKDK_MAX float 0.27
		set_parameter_property TIMING_TCKDK_MAX DESCRIPTION "Clock to Input Data Clock (Max)"
		set_parameter_property TIMING_TCKDK_MAX DISPLAY_NAME "tCKDK_max (% of CK)"
		set_parameter_property TIMING_TCKDK_MAX ALLOWED_RANGES {-1:1}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCKDK_MIN float -0.27
		set_parameter_property TIMING_TCKDK_MIN DESCRIPTION "Clock to Input Data Clock (Min)"
		set_parameter_property TIMING_TCKDK_MIN DISPLAY_NAME "tCKDK_min (% of CK)"
		set_parameter_property TIMING_TCKDK_MIN ALLOWED_RANGES {-1:1}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TCKQK_MAX integer 225
		set_parameter_property TIMING_TCKQK_MAX DESCRIPTION "QK edge to clock edge skew (Max)"
		set_parameter_property TIMING_TCKQK_MAX DISPLAY_NAME "tCKQK_max"
		set_parameter_property TIMING_TCKQK_MAX UNITS picoseconds
		set_parameter_property TIMING_TCKQK_MAX ALLOWED_RANGES {-5000:5000}	

		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TIS integer 170
		set_parameter_property TIMING_TIS DESCRIPTION "Base specification for address and control setup to CK"
		set_parameter_property TIMING_TIS DISPLAY_NAME "tIS (base)"
		set_parameter_property TIMING_TIS UNITS picoseconds
		set_parameter_property TIMING_TIS ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TIH integer 120
		set_parameter_property TIMING_TIH DESCRIPTION "Base specification for address and control hold from CK"
		set_parameter_property TIMING_TIH DISPLAY_NAME "tIH (base)"
		set_parameter_property TIMING_TIH UNITS picoseconds
		set_parameter_property TIMING_TIH ALLOWED_RANGES {0:5000}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_CONTROLLER_RD_TO_WR_NOP_COMMANDS integer 6
		set_parameter_property TIMING_CONTROLLER_RD_TO_WR_NOP_COMMANDS DESCRIPTION "Minimum number of NOP commands following a read command and before a write command.  The value must be at least ((Burst Length / 2) + RL - WL + 2).  The value, along with other delay/skew parameters, are used by the \"Bus Turnaround\" timing analysis to determine if bus contention is an issue."
		set_parameter_property TIMING_CONTROLLER_RD_TO_WR_NOP_COMMANDS DISPLAY_NAME "Read-to-Write NOP commands (Min)"
		set_parameter_property TIMING_CONTROLLER_RD_TO_WR_NOP_COMMANDS ALLOWED_RANGES {0:20}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_CONTROLLER_WR_TO_RD_NOP_COMMANDS integer 7
		set_parameter_property TIMING_CONTROLLER_WR_TO_RD_NOP_COMMANDS DESCRIPTION "Minimum number of NOP commands following a write command and before a read command.  The value must be at least ((Burst Length / 2) + WL - RL + 1).  The value, along with other delay/skew parameters, are used by the \"Bus Turnaround\" timing analysis to determine if bus contention is an issue."
		set_parameter_property TIMING_CONTROLLER_WR_TO_RD_NOP_COMMANDS DISPLAY_NAME "Write-to-Read NOP commands (Min)"
		set_parameter_property TIMING_CONTROLLER_WR_TO_RD_NOP_COMMANDS ALLOWED_RANGES {0:20}
	}

	return 1
}

proc ::alt_mem_if::gui::common_rldram_mem_model::_create_memory_parameters_parameters {} {
	
	variable rldram_mode
	
	_dprint 1 "Preparing to create memory parameters parameters in common_rldram_mem_model"
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ADDR_WIDTH integer 21
		set_parameter_property MEM_ADDR_WIDTH DISPLAY_NAME "Address width"
		set_parameter_property MEM_ADDR_WIDTH DESCRIPTION "Width of the address bus on the memory device."
		set_parameter_property MEM_ADDR_WIDTH ALLOWED_RANGES {15:25}	
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BURST_LENGTH integer 4
		set_parameter_property MEM_BURST_LENGTH DISPLAY_NAME "Burst length"
		set_parameter_property MEM_BURST_LENGTH DESCRIPTION "Burst length supported by memory device." 
		set_parameter_property MEM_BURST_LENGTH ALLOWED_RANGES {2 4 8}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DQ_WIDTH integer 9
		set_parameter_property MEM_DQ_WIDTH DISPLAY_NAME "Data width"
		set_parameter_property MEM_DQ_WIDTH DESCRIPTION "Width of the data bus on the memory device." 
		set_parameter_property MEM_DQ_WIDTH ALLOWED_RANGES {9 18 36}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BANKADDR_WIDTH integer 3
		set_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME "Bank-address width"
		set_parameter_property MEM_BANKADDR_WIDTH DESCRIPTION "Width of the bank address bus on the memory device."
		set_parameter_property MEM_BANKADDR_WIDTH ALLOWED_RANGES {3}

		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DM_WIDTH integer 1
		set_parameter_property MEM_DM_WIDTH DISPLAY_NAME "Data-mask width"
		set_parameter_property MEM_DM_WIDTH DESCRIPTION "Width of the data-mask bus on the memory device." 
		set_parameter_property MEM_DM_WIDTH ALLOWED_RANGES {1}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_READ_DQS_WIDTH integer 1
		set_parameter_property MEM_READ_DQS_WIDTH DISPLAY_NAME "QK width"
		set_parameter_property MEM_READ_DQS_WIDTH DESCRIPTION "Width of the QK (read strobe) bus on the memory device." 
		set_parameter_property MEM_READ_DQS_WIDTH ALLOWED_RANGES {1 2}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_WRITE_DQS_WIDTH integer 1
		set_parameter_property MEM_WRITE_DQS_WIDTH DISPLAY_NAME "DK width"
		set_parameter_property MEM_WRITE_DQS_WIDTH DESCRIPTION "Width of the DK (write strobe) bus on the memory device." 
		set_parameter_property MEM_WRITE_DQS_WIDTH ALLOWED_RANGES {1 2}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_CONFIGURATION integer 3
		set_parameter_property MRS_CONFIGURATION DISPLAY_NAME "Configuration"
		set_parameter_property MRS_CONFIGURATION DESCRIPTION "Configuration bits that set the memory mode."
		set_parameter_property MRS_CONFIGURATION ALLOWED_RANGES {"1:tRC=4, tRL=4, tWL=5, f=266-175MHz" "2:tRC=6, tRL=6, tWL=7, f=400-175MHz" "3:tRC=8, tRL=8, tWL=9, f=533-175MHz" "4:tRC=4, tRL=3, tWL=4, f=200-175MHz" "5:tRC=5, tRL=5, tWL=6, f=333-175MHz"}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_IMPEDANCE_MATCHING integer 0
		set_parameter_property MRS_IMPEDANCE_MATCHING DISPLAY_NAME "Drive impedance"
		set_parameter_property MRS_IMPEDANCE_MATCHING DESCRIPTION "Mode register bits that set the drive impedance setting."
		set_parameter_property MRS_IMPEDANCE_MATCHING ALLOWED_RANGES {"0:Internal 50 Ohm" "1:External (ZQ)"}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_ODT integer 1
		set_parameter_property MRS_ODT DISPLAY_NAME "On-Die Termination"
		set_parameter_property MRS_ODT DESCRIPTION "Mode register bits that set the on-die termination setting."
		set_parameter_property MRS_ODT ALLOWED_RANGES {"0:Off" "1:On"}
		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ADDR_WIDTH integer 20
		set_parameter_property MEM_ADDR_WIDTH DISPLAY_NAME "Address width"
		set_parameter_property MEM_ADDR_WIDTH DESCRIPTION "Width of the address bus on the memory device."
		set_parameter_property MEM_ADDR_WIDTH ALLOWED_RANGES {15:25}	
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BURST_LENGTH integer 2
		set_parameter_property MEM_BURST_LENGTH DISPLAY_NAME "Burst length"
		set_parameter_property MEM_BURST_LENGTH DESCRIPTION "Burst length supported by memory device." 
		set_parameter_property MEM_BURST_LENGTH ALLOWED_RANGES {2 4 8}
	
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DQ_WIDTH integer 18
		set_parameter_property MEM_DQ_WIDTH DISPLAY_NAME "Data width"
		set_parameter_property MEM_DQ_WIDTH DESCRIPTION "Width of the data bus on the memory device." 
		set_parameter_property MEM_DQ_WIDTH ALLOWED_RANGES {18 36}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BANKADDR_WIDTH integer 4
		set_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME "Bank-address width"
		set_parameter_property MEM_BANKADDR_WIDTH DESCRIPTION "Width of the bank address bus on the memory device."
		set_parameter_property MEM_BANKADDR_WIDTH ALLOWED_RANGES {4}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DM_WIDTH integer 2
		set_parameter_property MEM_DM_WIDTH DISPLAY_NAME "Data-mask width"
		set_parameter_property MEM_DM_WIDTH DESCRIPTION "Width of the data-mask bus on the memory device." 
		set_parameter_property MEM_DM_WIDTH ALLOWED_RANGES {2}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_READ_DQS_WIDTH integer 2
		set_parameter_property MEM_READ_DQS_WIDTH DISPLAY_NAME "QK width"
		set_parameter_property MEM_READ_DQS_WIDTH DESCRIPTION "Width of the QK (read strobe) bus on the memory device." 
		set_parameter_property MEM_READ_DQS_WIDTH ALLOWED_RANGES {2 4}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_WRITE_DQS_WIDTH integer 2
		set_parameter_property MEM_WRITE_DQS_WIDTH DISPLAY_NAME "DK width"
		set_parameter_property MEM_WRITE_DQS_WIDTH DESCRIPTION "Width of the DK (write strobe) bus on the memory device." 
		set_parameter_property MEM_WRITE_DQS_WIDTH ALLOWED_RANGES {2}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_DATA_LATENCY integer 1
		set_parameter_property MRS_DATA_LATENCY DISPLAY_NAME "Data Latency"
		set_parameter_property MRS_DATA_LATENCY DESCRIPTION "Mode register bits that set the data latency."
		set_parameter_property MRS_DATA_LATENCY ALLOWED_RANGES {"0:RL=3, WL=4" "1:RL=4, WL=5" "2:RL=5, WL=6" "3:RL=6, WL=7" "4:RL=7, WL=8" "5:RL=8, WL=9" "6:RL=9, WL=10" "7:RL=10, WL=11" "8:RL=11, WL=12" "9:RL=12, WL=13" "10:RL=13, WL=14" "11:RL=14, WL=15" "12:RL=15, WL=16" "13:RL=16, WL=17"}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_T_RC integer 0
		set_parameter_property MRS_T_RC DISPLAY_NAME "tRC"
		set_parameter_property MRS_T_RC DESCRIPTION "Mode register bits that set the tRC."
		set_parameter_property MRS_T_RC ALLOWED_RANGES {"0:tRC=2" "1:tRC=3" "2:tRC=4" "3:tRC=5" "4:tRC=6" "5:tRC=7" "6:tRC=8" "7:tRC=9" "8:tRC=10" "9:tRC=11" "10:tRC=12"}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_IMPEDANCE_MATCHING integer 1
		set_parameter_property MRS_IMPEDANCE_MATCHING DISPLAY_NAME "Output Drive"
		set_parameter_property MRS_IMPEDANCE_MATCHING DESCRIPTION "Mode register bits that set the output drive setting."
		set_parameter_property MRS_IMPEDANCE_MATCHING ALLOWED_RANGES {"0:RZQ/6 (40 Ohm)" "1:RZQ/4 (60 Ohm)"}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_ODT integer 2
		set_parameter_property MRS_ODT DISPLAY_NAME "ODT"
		set_parameter_property MRS_ODT DESCRIPTION "Mode register bits that set the ODT setting."
		set_parameter_property MRS_ODT ALLOWED_RANGES {"0:Off" "1:RZQ/6 (40 Ohm)" "2:RZQ/4 (60 Ohm)" "3:RZQ/2 (120 Ohm)"}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_AREF_PROTOCOL integer 0
		set_parameter_property MRS_AREF_PROTOCOL DISPLAY_NAME "AREF protocol"
		set_parameter_property MRS_AREF_PROTOCOL DESCRIPTION "Mode register bits that set the AREF protocol setting."
		set_parameter_property MRS_AREF_PROTOCOL ALLOWED_RANGES {"0:Bank Address Control" "1:Multibank"}
		
		::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_WRITE_PROTOCOL integer 0
		set_parameter_property MRS_WRITE_PROTOCOL DISPLAY_NAME "Write protocol"
		set_parameter_property MRS_WRITE_PROTOCOL DESCRIPTION "Mode register bits that set the write protocol setting."
		set_parameter_property MRS_WRITE_PROTOCOL ALLOWED_RANGES {"0:Single Bank" "1:Dual Bank" "2:Quad Bank"}
	}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DM_PINS_EN Boolean true
	set_parameter_property MEM_IF_DM_PINS_EN DISPLAY_NAME "Enable data-mask pins"
	set_parameter_property MEM_IF_DM_PINS_EN DESCRIPTION "Specifies whether the DM pins of the memory device are driven by the FPGA.  You can turn off this option to reduce FPGA pin usage."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CS_WIDTH integer 1
	set_parameter_property MEM_CS_WIDTH DISPLAY_NAME "Chip-select width"
	set_parameter_property MEM_CS_WIDTH DESCRIPTION "Width of the chip select bus on the memory device." 
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_enable_multi_rank_rldram3]} {
		set_parameter_property MEM_CS_WIDTH ALLOWED_RANGES {1 2 4}
	} else {
		set_parameter_property MEM_CS_WIDTH ALLOWED_RANGES {1}
	}
	set_parameter_property MEM_CS_WIDTH VISIBLE true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CONTROL_WIDTH integer 1
	set_parameter_property MEM_CONTROL_WIDTH DISPLAY_NAME "Control width"
	set_parameter_property MEM_CONTROL_WIDTH DESCRIPTION "Width of the control bus on the memory device." 
	set_parameter_property MEM_CONTROL_WIDTH VISIBLE FALSE

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

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DENALI_SOMA_FILE string "rldramii.soma"
	set_parameter_property MEM_DENALI_SOMA_FILE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DEVICE_MAX_ADDR_WIDTH integer 22
	set_parameter_property MEM_DEVICE_MAX_ADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_BOARD_BASE_DELAY INTEGER 10
	set_parameter_property MEM_IF_BOARD_BASE_DELAY DISPLAY_NAME "Base board delay for board delay model"
	set_parameter_property MEM_IF_BOARD_BASE_DELAY DESCRIPTION "Base delay is required to allow create smaller windows of valid data"
	set_parameter_property MEM_IF_BOARD_BASE_DELAY VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_VERBOSE boolean true 
	set_parameter_property MEM_VERBOSE DISPLAY_NAME "Enable verbose memory model output"
	set_parameter_property MEM_VERBOSE DESCRIPTION "When turned on, more detailed information about each memory access is displayed during simulation.  This information is useful for debugging."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PINGPONGPHY_EN BOOLEAN false
	set_parameter_property PINGPONGPHY_EN DISPLAY_NAME "Enable Ping Pong PHY"
	set_parameter_property PINGPONGPHY_EN DESCRIPTION "Enable Ping Pong PHY"
	set_parameter_property PINGPONGPHY_EN VISIBLE false

	return 1
}

proc ::alt_mem_if::gui::common_rldram_mem_model::_create_memory_timing_gui {} {

	variable rldram_mode

	_dprint 1 "Preparing to create memory timing GUI in common_rldram_mem_model"
	
	add_display_item "" "Memory Timing" GROUP "tab"
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		add_display_item "Memory Timing" id1 TEXT "<html>Timing parameters as found in the manufacturer data sheet.<br>Device presets can be applied from the preset list on the right."
		add_display_item "Memory Timing" MEM_CLK_FREQ_MAX PARAMETER
		add_display_item "Memory Timing" MEM_REFRESH_INTERVAL_NS PARAMETER
		add_display_item "Memory Timing" TIMING_TCKH PARAMETER
		add_display_item "Memory Timing" TIMING_TQKH PARAMETER
		add_display_item "Memory Timing" TIMING_TAS PARAMETER
		add_display_item "Memory Timing" TIMING_TAH PARAMETER
		add_display_item "Memory Timing" TIMING_TDS PARAMETER
		add_display_item "Memory Timing" TIMING_TDH PARAMETER
		add_display_item "Memory Timing" TIMING_TQKQ_MAX PARAMETER
		add_display_item "Memory Timing" TIMING_TQKQ_MIN PARAMETER
		add_display_item "Memory Timing" TIMING_TCKDK_MAX PARAMETER
		add_display_item "Memory Timing" TIMING_TCKDK_MIN PARAMETER
		add_display_item "Memory Timing" TIMING_TCKQK_MAX PARAMETER
		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		
		add_display_item "Memory Timing" "Memory Device Timing" GROUP
		add_display_item "Memory Device Timing" id1 TEXT "<html>Timing parameters as found in the manufacturer data sheet.<br>Device presets can be applied from the preset list on the right."
		add_display_item "Memory Device Timing" MEM_CLK_FREQ_MAX PARAMETER
		add_display_item "Memory Device Timing" TIMING_TDS PARAMETER
		add_display_item "Memory Device Timing" TIMING_TDH PARAMETER
		add_display_item "Memory Device Timing" TIMING_TQKQ_MAX PARAMETER
		add_display_item "Memory Device Timing" TIMING_TQH PARAMETER
		add_display_item "Memory Device Timing" TIMING_TCKDK_MAX PARAMETER
		add_display_item "Memory Device Timing" TIMING_TCKDK_MIN PARAMETER
		add_display_item "Memory Device Timing" TIMING_TCKQK_MAX PARAMETER
		add_display_item "Memory Device Timing" TIMING_TIS PARAMETER
		add_display_item "Memory Device Timing" TIMING_TIH PARAMETER
		
		add_display_item "Memory Timing" "Controller Timing" GROUP
		add_display_item "Controller Timing" id2 TEXT "<html>Consult the vendor or the user manual of your memory controller to obtain the following parameters."
		add_display_item "Controller Timing" TIMING_CONTROLLER_RD_TO_WR_NOP_COMMANDS PARAMETER
		add_display_item "Controller Timing" TIMING_CONTROLLER_WR_TO_RD_NOP_COMMANDS PARAMETER
	}
}

proc ::alt_mem_if::gui::common_rldram_mem_model::_create_memory_parameters_gui {} {

	variable rldram_mode

	add_display_item "" "Memory Parameters" GROUP "tab"

	add_display_item "Memory Parameters" id3 TEXT "<html>Memory parameters as found in the manufacturer data sheet <br>Device presets can be applied from the preset list on the right.<br>Parameters on this page are per-device."
	
	add_display_item "Memory Parameters" MEM_IF_DM_PINS_EN PARAMETER
	add_display_item "Memory Parameters" MEM_DM_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_DQ_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_READ_DQS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_WRITE_DQS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_ADDR_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_BANKADDR_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_CS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_CONTROL_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_BURST_LENGTH PARAMETER
	add_display_item "Memory Parameters" MEM_USE_DENALI_MODEL PARAMETER
	add_display_item "Memory Parameters" MEM_DENALI_SOMA_FILE PARAMETER
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		add_display_item "Memory Parameters" MRS_CONFIGURATION PARAMETER
		add_display_item "Memory Parameters" MRS_IMPEDANCE_MATCHING PARAMETER
		add_display_item "Memory Parameters" MRS_ODT PARAMETER
		add_display_item "Memory Parameters" id4 TEXT "<html>Other mode register bits are not user-configurable and are set as follows: <br>Address mux = false <br>DLL reset = DLL enabled"
		
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		add_display_item "Memory Parameters" MRS_T_RC PARAMETER
		add_display_item "Memory Parameters" MRS_DATA_LATENCY PARAMETER
		add_display_item "Memory Parameters" MRS_IMPEDANCE_MATCHING PARAMETER
		add_display_item "Memory Parameters" MRS_ODT PARAMETER
		add_display_item "Memory Parameters" MRS_AREF_PROTOCOL PARAMETER
		add_display_item "Memory Parameters" MRS_WRITE_PROTOCOL PARAMETER
		add_display_item "Memory Parameters" id4 TEXT "<html>Other mode register bits are not user-configurable and are set as follows: <br>Address mux = false <br>DLL enable = enable"
	}

	add_display_item "Memory Parameters" "Topology" GROUP

	add_display_item "Topology" DEVICE_WIDTH PARAMETER
	add_display_item "Topology" DEVICE_DEPTH PARAMETER

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {

		add_display_item "Memory Parameters" "Memory Interface" GROUP

		set_parameter_property MEM_IF_CLK_PAIR_COUNT VISIBLE true
		set_parameter_property MEM_IF_ADDR_WIDTH VISIBLE true
		set_parameter_property MEM_IF_BANKADDR_WIDTH VISIBLE true
		set_parameter_property MEM_IF_READ_DQS_WIDTH VISIBLE true
		set_parameter_property MEM_IF_WRITE_DQS_WIDTH VISIBLE true
		set_parameter_property MEM_IF_DQ_WIDTH VISIBLE true
		set_parameter_property MEM_IF_DM_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CONTROL_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CS_WIDTH VISIBLE true

		add_display_item "Memory Interface" MEM_IF_CLK_PAIR_COUNT PARAMETER
		add_display_item "Memory Interface" MEM_IF_ADDR_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_BANKADDR_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_READ_DQS_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_WRITE_DQS_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_DQ_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_DM_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CONTROL_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CS_WIDTH PARAMETER

	}
	
	return 1
}

proc ::alt_mem_if::gui::common_rldram_mem_model::create_diagnostics_gui {} {

	_dprint 1 "Preparing to create Memory Model diagnostics GUI in common_rldram_mem_model"

	add_display_item "" "Diagnostics" GROUP "tab"
	add_display_item "Diagnostics" "Simulation Options" GROUP
	add_display_item "Simulation Options" MEM_VERBOSE PARAMETER
}


proc ::alt_mem_if::gui::common_rldram_mem_model::_derive_parameters {} {
	
	variable rldram_mode
	
	_dprint 1 "Preparing to derive parametres for common_rldram_mem_model"
	
	set_parameter_value MEM_IF_ADDR_WIDTH [get_parameter_value MEM_ADDR_WIDTH]
	set_parameter_value MEM_IF_BANKADDR_WIDTH [get_parameter_value MEM_BANKADDR_WIDTH]
	set_parameter_value MEM_IF_CONTROL_WIDTH [get_parameter_value MEM_CONTROL_WIDTH]
	
	set_parameter_value MEM_IF_CS_WIDTH [expr { [get_parameter_value MEM_CS_WIDTH] * [get_parameter_value DEVICE_DEPTH] }]
	set_parameter_value MEM_IF_DM_WIDTH [expr { [get_parameter_value MEM_DM_WIDTH] * [get_parameter_value DEVICE_WIDTH] }]
	set_parameter_value MEM_IF_DQ_WIDTH [expr { [get_parameter_value MEM_DQ_WIDTH] * [get_parameter_value DEVICE_WIDTH] }]
	set_parameter_value MEM_IF_READ_DQS_WIDTH [expr { [get_parameter_value MEM_READ_DQS_WIDTH] * [get_parameter_value DEVICE_WIDTH] }]
	set_parameter_value MEM_IF_WRITE_DQS_WIDTH [expr { [get_parameter_value MEM_WRITE_DQS_WIDTH] * [get_parameter_value DEVICE_WIDTH] }]
	
	set_parameter_value MEM_CLK_MAX_PS [expr {round(1000000 / [get_parameter_value MEM_CLK_FREQ_MAX])}]
	set_parameter_value MEM_CLK_MAX_NS [expr {[get_parameter_value MEM_CLK_MAX_PS] / 1000.0}]
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set_parameter_property MEM_IF_DM_PINS_EN VISIBLE false
		set_parameter_property MEM_DM_WIDTH ENABLED true
	} elseif {[string compare -nocase $rldram_mode "RLDRAM3"] == 0} {
		set_parameter_value MEM_IF_NUMBER_OF_RANKS [ get_parameter_value MEM_CS_WIDTH ]
		set_parameter_property MEM_IF_DM_PINS_EN VISIBLE true
		if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
			set_parameter_property MEM_DM_WIDTH ENABLED true
		} else {
			set_parameter_property MEM_DM_WIDTH ENABLED false
		}
	}
}


proc ::alt_mem_if::gui::common_rldram_mem_model::_derive_mode_register_parameters {} {
	
	variable rldram_mode
	
	_dprint 1 "Preparing to derive mode register settings in common_rldram_mem_model"
	
	set_parameter_value MRS_BURST_LENGTH 1
	
	set_parameter_value MRS_ADDRESS_MUX 0
	
	if {[string compare -nocase $rldram_mode "RLDRAMII"] == 0} {
		set_parameter_value MRS_DLL_RESET 1
		
		switch -- [get_parameter_value MRS_CONFIGURATION] {
		1	{
			set_parameter_value MEM_T_RC 4
			set_parameter_value MEM_T_RL 4
			set_parameter_value MEM_T_WL 5
			}
		2	{
			set_parameter_value MEM_T_RC 6
			set_parameter_value MEM_T_RL 6
			set_parameter_value MEM_T_WL 7
			}
		3	{
			set_parameter_value MEM_T_RC 8
			set_parameter_value MEM_T_RL 8
			set_parameter_value MEM_T_WL 9
			}
		4	{
			set_parameter_value MEM_T_RC 4
			set_parameter_value MEM_T_RL 3
			set_parameter_value MEM_T_WL 4
			}
		5	{
			set_parameter_value MEM_T_RC 5
			set_parameter_value MEM_T_RL 5
			set_parameter_value MEM_T_WL 6
			}
		default {
			_error "Fatal Error: Unknown MRS configuration [get_parameter_value MRS_CONFIGURATION]"
			}
		}
	} else {
		set_parameter_value MRS_DLL_ENABLE 0
		
		set_parameter_value MRS_DLL_RESET 0
		
		set_parameter_value MRS_ZQ_CALIB_ENABLE 0
		
		set_parameter_value MRS_ZQ_CALIB_SELECTION 0
		
		set mrs_data_latency [get_parameter_value MRS_DATA_LATENCY]
		set_parameter_value MEM_T_RL [expr 3 + $mrs_data_latency]
		set_parameter_value MEM_T_WL [expr 4 + $mrs_data_latency]
		set_parameter_value MEM_T_RC [expr 2 + [get_parameter_value MRS_T_RC]]
	}
}


::alt_mem_if::gui::common_rldram_mem_model::_init
