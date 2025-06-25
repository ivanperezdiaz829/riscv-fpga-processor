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


package provide alt_mem_if::gui::common_ddr_mem_model 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils

package require alt_mem_if::gen::uniphy_gen


namespace eval ::alt_mem_if::gui::common_ddr_mem_model:: {
	variable VALID_DDR_MODES
	variable ddr_mode
	
	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::common_ddr_mem_model::_validate_ddr_mode {} {
	variable ddr_mode
		
	if {$ddr_mode == -1} {
		error "DDR mode in [namespace current] in uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_family_supports_non_leveling {} {
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
	    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0 ||
	    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "MAX10FPGA"] == 0} {
		return 0
	} else {
		return 1
	}
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_family_supports_leveling {} {
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		return 0
	} else {
		return 1
	}
}

proc ::alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode {in_ddr_mode} {
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

proc ::alt_mem_if::gui::common_ddr_mem_model::create_parameters {} {

	_validate_ddr_mode
	
	_dprint 1 "Preparing tocreate parameters for common_ddr_mem_model"
	
	_create_derived_mode_register_parameters
	_create_derived_parameters
	
	_create_memory_parameters_parameters
	
	_create_memory_initialization_parameters
		
	_create_memory_timing_parameters
		
	return 1
}


proc ::alt_mem_if::gui::common_ddr_mem_model::create_gui {} {

	_validate_ddr_mode

	_create_memory_parameters_gui
	
	_create_memory_timing_gui
	
	return 1
}



proc ::alt_mem_if::gui::common_ddr_mem_model::validate_component {} {

	variable ddr_mode
	set is_hps [regexp {^HPS$} $ddr_mode]

	set protocol [_get_protocol]

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property MEM_BL ALLOWED_RANGES {"4" "8"}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {$is_hps} {
			set_parameter_property MEM_BL ALLOWED_RANGES {"OTF:Burst chop 4 or 8 (on the fly)"}
		} else {
			set_parameter_property MEM_BL ALLOWED_RANGES {"8:8" "OTF:Burst chop 4 or 8 (on the fly)" "BC4:Burst chop 4"}
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_property MEM_BL ALLOWED_RANGES {"4" "8" "16"}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		set_parameter_property MEM_BL ALLOWED_RANGES {"2" "4" "8" "16"}
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_ASR VISIBLE true
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property MEM_ASR VISIBLE false
	} else {
		if {$is_hps} {
			set_parameter_property MEM_ASR VISIBLE false
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property MEM_SRT VISIBLE true
		set_parameter_property MEM_SRT ENABLED true
		set_parameter_property MEM_SRT ALLOWED_RANGES {"1x refresh rate" "2x refresh rate"}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_SRT VISIBLE true
		set_parameter_property MEM_SRT ENABLED true
		set_parameter_property MEM_SRT ALLOWED_RANGES {"Normal" "Extended"}
	} else {
		if {$is_hps} {
			set_parameter_property MEM_SRT VISIBLE false
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property MEM_PD VISIBLE true
		set_parameter_property MEM_PD ALLOWED_RANGES {"Fast exit" "Slow exit"}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_PD VISIBLE true
		set_parameter_property MEM_PD ALLOWED_RANGES {"DLL off" "DLL on"}
	} else {
		if {$is_hps} {
			set_parameter_property MEM_PD VISIBLE false
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property MEM_DRV_STR VISIBLE true
		set_parameter_property MEM_DRV_STR ALLOWED_RANGES {"Full" "Reduced"}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_DRV_STR VISIBLE true
		set_parameter_property MEM_DRV_STR ALLOWED_RANGES {"RZQ/6" "RZQ/7"}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_property MEM_DRV_STR VISIBLE true
		set_parameter_property MEM_DRV_STR ALLOWED_RANGES {"34.3" "40" "48" "60" "80" "120"}
	} else {
		if {$is_hps} {
			set_parameter_property MEM_DRV_STR VISIBLE false
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property MEM_RTT_NOM VISIBLE true
		set_parameter_property MEM_RTT_NOM ALLOWED_RANGES {"Disabled" "75" "150" "50"}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_RTT_NOM VISIBLE true
		set_parameter_property MEM_RTT_NOM ALLOWED_RANGES {"ODT Disabled" "RZQ/4" "RZQ/2" "RZQ/6"}
	} else {
		if {$is_hps} {
			set_parameter_property MEM_RTT_NOM VISIBLE false
		}
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_RTT_WR VISIBLE true
		set_parameter_property MEM_RTT_WR ALLOWED_RANGES {"Dynamic ODT off" "RZQ/4" "RZQ/2"}
	} else {
		if {$is_hps} {
			set_parameter_property MEM_RTT_WR VISIBLE false
		}
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_WTCL VISIBLE true
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || 
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0 } {
			set_parameter_property MEM_WTCL ALLOWED_RANGES {5 6 7 8 9 10}
		} else {
			set_parameter_property MEM_WTCL ALLOWED_RANGES {5 6 7 8}
		}
	} else {
		if {$is_hps} {
			set_parameter_property MEM_WTCL VISIBLE false
		}
	}

	if {[regexp {^DDR2$} $ddr_mode] == 1} {
		set_parameter_property MEM_TCL ALLOWED_RANGES {3 4 5 6 7}
	} elseif {[regexp {^DDR3$} $ddr_mode] == 1} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || 
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			set_parameter_property MEM_TCL ALLOWED_RANGES {5 6 7 8 9 10 11 12 13 14}
		} else {
			set_parameter_property MEM_TCL ALLOWED_RANGES {5 6 7 8 9 10 11}
		}
	} elseif {[regexp {^LPDDR2$} $ddr_mode] == 1} {
		set_parameter_property MEM_TCL ALLOWED_RANGES {3 4 5 6 7 8}
	} elseif {[regexp {^LPDDR1$} $ddr_mode] == 1} {
		set_parameter_property MEM_TCL ALLOWED_RANGES {2 3}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property MEM_ATCL VISIBLE true
		set_parameter_property MEM_ATCL ALLOWED_RANGES {0 1 2 3 4 5 6}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_ATCL VISIBLE true
		set_parameter_property MEM_ATCL ALLOWED_RANGES {"Disabled" "CL-1" "CL-2"}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {$is_hps} {
			set_parameter_property MEM_ATCL VISIBLE true
		} else {
			set_parameter_property MEM_ATCL VISIBLE false
		}
		set_parameter_property MEM_ATCL ALLOWED_RANGES {0}
	} else {
		if {$is_hps} {
			set_parameter_property MEM_ATCL VISIBLE false
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_property TIMING_TDQSCK ALLOWED_RANGES {0:5000}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property TIMING_TDQSCK ALLOWED_RANGES {0:5000}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_property TIMING_TDQSCK ALLOWED_RANGES {2500:5500}
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		set_parameter_property TIMING_TDQSCK ALLOWED_RANGES {0:10000}
	}

	if {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_property TIMING_TDQSCKDS VISIBLE true
		set_parameter_property TIMING_TDQSCKDM VISIBLE true
		set_parameter_property TIMING_TDQSCKDL VISIBLE true
	} else {
		set_parameter_property TIMING_TDQSCKDS VISIBLE false
		set_parameter_property TIMING_TDQSCKDM VISIBLE false
		set_parameter_property TIMING_TDQSCKDL VISIBLE false
	}

	if {$is_hps} {
		if {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_property TIMING_TQHS VISIBLE false
			set_parameter_property TIMING_TQH VISIBLE true
			set_parameter_property TIMING_TDQSH VISIBLE false
			set_parameter_property TIMING_TQSH VISIBLE true
		} else {
			set_parameter_property TIMING_TQHS VISIBLE true
			set_parameter_property TIMING_TQH VISIBLE false
			set_parameter_property TIMING_TDQSH VISIBLE true
			set_parameter_property TIMING_TQSH VISIBLE false
		}
	}

	if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_VENDOR ENABLED TRUE
	} elseif {[regexp {^LPDDR2$|^LPDDR1$} $protocol] == 1} {
		set_parameter_property MEM_VENDOR ENABLED FALSE
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_nolevel_ddr3_dimm_gen] == 1} {
				set_parameter_property MEM_FORMAT ALLOWED_RANGES {"DISCRETE:Discrete Device" "UNBUFFERED:Unbuffered DIMM" "REGISTERED:Registered DIMM" "LOADREDUCED:Load-Reduced DIMM"}
				set_parameter_property MEM_FORMAT ENABLED true
			} else {
				set_parameter_property MEM_FORMAT ALLOWED_RANGES {"DISCRETE:Discrete Device"}
				set_parameter_property MEM_FORMAT ENABLED false
			}
		} else {
			set_parameter_property MEM_FORMAT ALLOWED_RANGES {"DISCRETE:Discrete Device" "UNBUFFERED:Unbuffered DIMM" "REGISTERED:Registered DIMM" "LOADREDUCED:Load-Reduced DIMM"}
			set_parameter_property MEM_FORMAT ENABLED true
		}
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
		if {[regexp {^HPS$} $ddr_mode] == 1} {
			set_parameter_property MEM_FORMAT ALLOWED_RANGES {"DISCRETE:Discrete Device"}
		} else {
			set_parameter_property MEM_FORMAT ALLOWED_RANGES {"DISCRETE:Discrete Device" "UNBUFFERED:Unbuffered DIMM" "REGISTERED:Registered DIMM"}
		}
			set_parameter_property MEM_FORMAT ENABLED true
	} elseif {[regexp {^LPDDR2$|^LPDDR1$} $protocol] == 1} {
		set_parameter_property MEM_FORMAT ALLOWED_RANGES {"DISCRETE:Discrete Device"}
		set_parameter_property MEM_FORMAT ENABLED false
	}

	if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
		set_parameter_property AC_PARITY VISIBLE TRUE
		if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 ||
		    [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} { 
			set_parameter_value AC_PARITY TRUE
		} else {
			
			set_parameter_value AC_PARITY FALSE
		} 
	} elseif {[regexp {^LPDDR2$|^LPDDR1$} $protocol] == 1} {
		set_parameter_property AC_PARITY VISIBLE FALSE
		set_parameter_value AC_PARITY FALSE
	}

	if {$is_hps} {
		if {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_property RDIMM_CONFIG VISIBLE true
		} else {
			set_parameter_property RDIMM_CONFIG VISIBLE false
		}
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_property MEM_MIRROR_ADDRESSING VISIBLE true
	} else {
		set_parameter_property MEM_MIRROR_ADDRESSING VISIBLE false
	}

	if {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_property DEVICE_DEPTH ALLOWED_RANGES {1}
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE ALLOWED_RANGES {1}
	} else {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set_parameter_property DEVICE_DEPTH ALLOWED_RANGES {1 2}
		} else {
			set_parameter_property DEVICE_DEPTH ALLOWED_RANGES {1 2 4}
		}
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE ALLOWED_RANGES {1 2}
	}

	set_parameter_property MEM_CLK_FREQ_MAX ALLOWED_RANGES [_supported_mem_fmax $protocol]

	_derive_parameters
	_derive_mode_register_parameters
	
	set validation_pass 1

	set mem_clk_mhz [get_parameter_value MEM_CLK_FREQ]
	set mem_clk_ns [expr {round(1000000.0 / $mem_clk_mhz) / 1000.0}]
    set mem_trcd_ns [get_parameter_value MEM_TRCD_NS]
	
	set number_of_dq_bits [ get_parameter_value MEM_DQ_WIDTH ]
	set number_of_dq_per_dqs [ get_parameter_value MEM_DQ_PER_DQS ]
	if { $number_of_dq_bits % $number_of_dq_per_dqs != 0 } {
		_eprint "The number of DQ bits must be an integer multiple of the number of DQ bits per DQS bit"
		set validation_pass 0
	}
	
	set mem_trcd_ck_min 2
	if {$mem_clk_mhz > 800.0} {
		set mem_trcd_ck_max 15
	} else {
		set mem_trcd_ck_max 11
	}
	set mem_trcd_ns_min [_tck_to_ns $mem_trcd_ck_min $mem_clk_mhz 2]
	set mem_trcd_ns_max [_tck_to_ns $mem_trcd_ck_max $mem_clk_mhz 2]
	set mem_trcd_ck [_ns_to_tck $mem_trcd_ns $mem_clk_ns]
	if {$mem_trcd_ck < $mem_trcd_ck_min} {
		_wprint "Cannot meet tRCD requirement of $mem_trcd_ns ns. For a Memory interface clock frequency of $mem_clk_mhz MHz, the minimum is $mem_trcd_ns_min ns."
	}
	if {$mem_trcd_ck > $mem_trcd_ck_max} {
		_eprint "Cannot meet tRCD requirement of $mem_trcd_ns ns. For a Memory interface clock frequency of $mem_clk_mhz MHz, the maximum is $mem_trcd_ns_max ns."
		set validation_pass 0
	}

	set mem_trtp_ck_min 2
	set mem_trtp_ck_max 8
	set mem_trtp_ns_min [_tck_to_ns $mem_trtp_ck_min $mem_clk_mhz 2]
	set mem_trtp_ns_max [_tck_to_ns $mem_trtp_ck_max $mem_clk_mhz 2]
	if {$mem_clk_ns == 0.937} {
		set mem_trtp_ck [_ns_to_tck [get_parameter_value MEM_TRTP_NS] 0.937501]
	} else {
		set mem_trtp_ck [_ns_to_tck [get_parameter_value MEM_TRTP_NS] $mem_clk_ns]
	}
	if {$mem_trtp_ck < $mem_trtp_ck_min} {
		_wprint "Cannot meet tRTP requirement of [get_parameter_value MEM_TRTP_NS] ns. For a Memory interface clock frequency of $mem_clk_mhz MHz, the minimum is $mem_trtp_ns_min ns."
	}
	if {$mem_trtp_ck > $mem_trtp_ck_max} {
		_eprint "Cannot meet tRTP requirement of [get_parameter_value MEM_TRTP_NS] ns. For a Memory interface clock frequency of $mem_clk_mhz MHz, the maximum is $mem_trtp_ns_max ns."
		set validation_pass 0
	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriaiigz"] == 0 &&
		[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [ get_parameter_value MEM_FORMAT ] "UNBUFFERED" ] == 0 } {
			_eprint "ArriaII GZ does not support unbuffered DDR3 DIMMs. Memory format should be set to discrete under the Memory Parameter tab"
			set validation_pass 0
		}
		if {[string compare -nocase [ get_parameter_value MEM_FORMAT ] "REGISTERED" ] == 0 } {
			_eprint "ArriaII GZ does not support registered DDR3 DIMMs. Memory format should be set to discrete under the Memory Parameter tab"
			set validation_pass 0
		}
		if {[string compare -nocase [ get_parameter_value MEM_FORMAT ] "LOADREDUCED" ] == 0 } {
			_eprint "ArriaII GZ does not support load-reduced DDR3 DIMMs. Memory format should be set to discrete under the Memory Parameter tab"
			set validation_pass 0
		}
		if {[string compare -nocase [get_parameter_value DISCRETE_FLY_BY] "TRUE"] == 0 &&
			[string compare -nocase [get_parameter_value MEM_FORMAT] "DISCRETE"] == 0 &&
			[get_parameter_value MEM_IF_DQS_WIDTH] > 1} {
			_eprint "ArriaII GZ does not support discrete DDR3 devices in fly-by topology"
			set validation_pass 0
		}
	}

	if { [get_parameter_value MEM_IF_DQ_WIDTH] > 144 } {
		_eprint "The maximum supported number of DQ bits is 144"
		set validation_pass 0
	} elseif { [get_parameter_value MEM_IF_DQ_WIDTH] > 72 } {
		_wprint "The maximum achievable speed for interfaces larger than 72 bits may differ from those reported in the Handbook"
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		if {!$is_hps} {
			set_parameter_property MEM_IF_DQSN_EN VISIBLE false
		}
		if {[string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "false"] == 0} {
			_eprint "DQS# Enable cannot be disabled for DDR3"
			set validation_pass 0
		}
	}

	if {[regexp {^LPDDR2$} $protocol] == 1} {
		if {!$is_hps} {
			set_parameter_property MEM_IF_DQSN_EN VISIBLE false
		}
		if {[string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "false"] == 0} {
			_eprint "DQS# Enable cannot be disabled for LPDDR2"
			set validation_pass 0
		}
	}

	if {[regexp {^LPDDR1$} $protocol] == 1} {
		if {!$is_hps} {
			set_parameter_property MEM_IF_DQSN_EN VISIBLE false
		}
		if {[string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "true"] == 0} {
			_eprint "DQS# Enable cannot be enabled for LPDDR(1)"
			set validation_pass 0
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		if {[get_parameter_value MEM_DQ_PER_DQS] == 4 &&
		    [string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0 &&
		    [string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "true"] == 0} {
			_eprint "When using x4 group size, \"[get_parameter_property MEM_IF_DM_PINS_EN DISPLAY_NAME]\" and \"[get_parameter_property MEM_IF_DQSN_EN DISPLAY_NAME]\" options cannot be both selected"
			set validation_pass 0
		}
		if {[string compare -nocase [get_parameter_value MEM_IF_DQSN_EN] "true"] == 0} {
			set_parameter_value MR1_DQS 0
		} else {
			set_parameter_value MR1_DQS 1
		}
	} else {
		if {[get_parameter_value MEM_DQ_PER_DQS] == 4 &&
		    [string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
			_eprint "When using x4 group size, \"[get_parameter_property MEM_IF_DM_PINS_EN DISPLAY_NAME]\" option cannot be selected"
			set validation_pass 0
		}
	}

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
		if {[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > [expr {8*[get_parameter_value MEM_NUMBER_OF_DIMMS]}]} {
			_eprint "Total number of ranks ([get_parameter_value MEM_IF_NUMBER_OF_RANKS]) out of range. Only 1, 2, 4 or 8 ranks per DIMM supported"
			set validation_pass 0
		}
	} else {
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] == 0 ||
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "cyclonev"] == 0} {
			if {[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > 2 } {
				_eprint "Total number of ranks ([get_parameter_value MEM_IF_NUMBER_OF_RANKS]) out of range. Only 1 or 2 ranks supported"
				set validation_pass 0
			}
		} elseif {[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > [expr {4*[get_parameter_value MEM_NUMBER_OF_DIMMS]}] } {
			_eprint "Total number of ranks ([get_parameter_value MEM_IF_NUMBER_OF_RANKS]) out of range. Only 1, 2 or 4 ranks supported"
			set validation_pass 0
		}
	}

	set_parameter_value MEM_MIRROR_ADDRESSING_DEC [ _compute_mirror_addressing [ get_parameter_value MEM_MIRROR_ADDRESSING ] ]
	if {[get_parameter_value MEM_MIRROR_ADDRESSING_DEC] == -1} {
	  	_eprint "Invalid Mirror Addressing String: \"[ get_parameter_value MEM_MIRROR_ADDRESSING ]\""
		set validation_pass 0
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
			set rdimm_config [get_parameter_value RDIMM_CONFIG]
			set rdimm_config_ok 0

			if {([string length $rdimm_config] <= 18) && ([regexp -nocase {^0x[0-9ABCDEF]+$} $rdimm_config] == 1)} {
				set rdimm_config_ok 1
			} elseif {([string length $rdimm_config] <= 16) && ([regexp -nocase {^[0-9ABCDEF]+$} $rdimm_config] == 1)} {
				set rdimm_config_ok 1
			}

			if {$rdimm_config_ok == 0} {
				_eprint "DDR3 RDIMM/LRDIMM Configuration must be 16 Hexadecimal characters"
				set validation_pass 0
			}

			if {([string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
				set lrdimm_extended_config [get_parameter_value LRDIMM_EXTENDED_CONFIG]
				set lrdimm_extended_config_ok 0
				if {([string length $lrdimm_extended_config] <= 20) && ([regexp -nocase {^0x[0-9ABCDEF]+$} $lrdimm_extended_config] == 1)} {
					set lrdimm_extended_config_ok 1
				} elseif {([string length $lrdimm_extended_config] <= 18) && ([regexp -nocase {^[0-9ABCDEF]+$} $lrdimm_extended_config] == 1)} {
					set lrdimm_extended_config_ok 1
				}

				if {$lrdimm_extended_config_ok == 0} {
					_eprint "DDR3 LRDIMM Extended Configuration must be 18 Hexadecimal characters"
					set validation_pass 0
				}
			}
		}
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		if {([string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] != 0) && ([get_parameter_value MEM_RANK_MULTIPLICATION_FACTOR] != 1)} {
			_eprint "Rank multiplication is only supported for Load-Reduced DIMMs"
			set validation_pass 0
		}
	}

	if { [_family_supports_non_leveling] } {
		if {[get_parameter_value MEM_CLK_FREQ] <= 240 && [string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
			_eprint "Leveling interfaces are NOT supported below 240MHz"
		}
	}

	if {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_FORMAT] "DISCRETE"] == 0 && 
			[get_parameter_value MEM_IF_DQS_WIDTH] > 1 &&
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] != 0 &&
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "cyclonev"] != 0} {

			set_parameter_property DISCRETE_FLY_BY VISIBLE TRUE
		} else {
			set_parameter_property DISCRETE_FLY_BY VISIBLE FALSE
		}
	} else {
		set_parameter_property DISCRETE_FLY_BY VISIBLE FALSE
	}

	if {[string compare -nocase [ get_parameter_value MEM_FORMAT ] "DISCRETE" ] == 0 } {
		set_parameter_property DEVICE_DEPTH VISIBLE TRUE
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE VISIBLE FALSE
		set_parameter_property MEM_NUMBER_OF_DIMMS VISIBLE FALSE
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM VISIBLE FALSE
	} else {
		set_parameter_property DEVICE_DEPTH VISIBLE FALSE
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE VISIBLE FALSE
		set_parameter_property MEM_NUMBER_OF_DIMMS VISIBLE TRUE
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM VISIBLE TRUE
	}

	if {([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "false"] == 0} {
			_eprint "[get_parameter_property AC_PARITY DISPLAY_NAME] must be enabled for Registered DIMM and Load Reduced DIMM formats"
		}
		if {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_property RDIMM_CONFIG VISIBLE TRUE

			if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
				set_parameter_property LRDIMM_EXTENDED_CONFIG VISIBLE TRUE
			}
		}

		set_parameter_property MEM_CS_WIDTH VISIBLE true
		set_parameter_property MEM_CLK_EN_WIDTH VISIBLE true
	} else {
		if {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_property RDIMM_CONFIG VISIBLE FALSE
			set_parameter_property LRDIMM_EXTENDED_CONFIG VISIBLE FALSE
		}
		set_parameter_property MEM_CS_WIDTH VISIBLE false
		set_parameter_property MEM_CLK_EN_WIDTH VISIBLE false
	}

	if {([regexp {^DDR3$} $protocol] == 1 && [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM ALLOWED_RANGES {1 2 4 8}
	} else {
		set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM ALLOWED_RANGES {1 2 4}
	}

	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
			if {[get_parameter_value MEM_CK_WIDTH] > 1} {
					_eprint "When using hard EMIF, mem_ck width is limited to 1.  Either use the soft interface or reduce the mem_ck width to 1."
					set validation_pass 0
			}
	}

	return $validation_pass

}


proc ::alt_mem_if::gui::common_ddr_mem_model::elaborate_component {} {

	return 1
}



proc ::alt_mem_if::gui::common_ddr_mem_model::_get_protocol {} {

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


proc ::alt_mem_if::gui::common_ddr_mem_model::_supported_mem_fmax {ddr_mode} {
	if {[regexp {^DDR3$} $ddr_mode ] == 1} {
		return {400 533.333 666.667 800 933.333 1066.667}
	} elseif {[regexp {^DDR2$} $ddr_mode ] == 1} {
		return {200 266.667 333.333 400 533.333}
	} elseif {[regexp {^LPDDR2$} $ddr_mode ] == 1} {
		return {200 266.667 333.333 400 533.333}
	} elseif {[regexp {^LPDDR1$} $ddr_mode ] == 1} {
		return {200}
	} else {
		_error "Fatal Error: Unknown DDR mode $ddr_mode"
	}
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_within {n min max} {
    if {$n < $min}  {
        return $min
    } elseif {$n > $max} {
        return $max
    }
    return $n
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_tck_to_ns {tck_value clk_freq_mhz n_dec} {
    
	set clk_period_ns [expr {1.0 / $clk_freq_mhz * 1000.0}]
    set ns_value [expr {$tck_value * $clk_period_ns}]
    
    for {set i 0} {$i < $n_dec} {incr i 1} {
        set ns_value [expr {$ns_value * 10.0}]
    }
    set ns_value [expr {ceil($ns_value)}]
    for {set i 0} {$i < $n_dec} {incr i 1} {
        set ns_value [expr {$ns_value / 10.0}]
    }
    return $ns_value
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_ns_to_tck {ns_value clk_period_ns} {

    set ns_to_tck_float [expr {$ns_value / $clk_period_ns}]
	
	return [expr {int(ceil($ns_to_tck_float))}]
}


proc ::alt_mem_if::gui::common_ddr_mem_model::_pow { base exponent } {
	set result 1
	for { set i 0 } { $i < $exponent } { incr i } {
		set result [ expr $result * $base ]
	}

	return $result
}


proc ::alt_mem_if::gui::common_ddr_mem_model::_compute_mirror_addressing { ma_string } {
	set mirror_addressing -1

	set strlen [ string length $ma_string ]
	set found_error 0
	if { $strlen > 0 && $strlen <= 4 } {
		set mirror_addressing 0
		for { set j 0 } { $j < $strlen } { incr j } {
			set i [ expr $strlen - $j - 1 ]
			set C [ string index $ma_string $j ]
			if { [ string compare $C 0 ] && [ string compare $C 1 ] } {
				set found_error 1
			} else {
				set mirror_addressing [ expr $mirror_addressing + ($C * [ _pow 2 $i ] )]
			}
		}
	}

	if { $found_error } {
		set mirror_addressing -1
	}

	return $mirror_addressing
}


proc ::alt_mem_if::gui::common_ddr_mem_model::_init {} {
	variable VALID_DDR_MODES
	
	::alt_mem_if::util::list_array::array_clean VALID_DDR_MODES
	set VALID_DDR_MODES(DDR2) 1
	set VALID_DDR_MODES(DDR3) 1
	set VALID_DDR_MODES(LPDDR2) 1
	set VALID_DDR_MODES(LPDDR1) 1
	set VALID_DDR_MODES(HPS) 1

	variable ddr_mode -1

}


proc ::alt_mem_if::gui::common_ddr_mem_model::_create_derived_mode_register_parameters {} {
	
	_validate_ddr_mode

	variable ddr_mode

	_dprint 1 "Preparing to create derived mode register parameters in common_ddr_mem_model"
	
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0 string ""
	set_parameter_property AC_ROM_MR0 DERIVED true
	set_parameter_property AC_ROM_MR0 VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0_MIRR string ""
	set_parameter_property AC_ROM_MR0_MIRR DERIVED true
	set_parameter_property AC_ROM_MR0_MIRR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0_CALIB string ""
	set_parameter_property AC_ROM_MR0_CALIB DERIVED true
	set_parameter_property AC_ROM_MR0_CALIB VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0_DLL_RESET string ""
	set_parameter_property AC_ROM_MR0_DLL_RESET DERIVED true
	set_parameter_property AC_ROM_MR0_DLL_RESET VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR0_DLL_RESET_MIRR string ""
	set_parameter_property AC_ROM_MR0_DLL_RESET_MIRR DERIVED true
	set_parameter_property AC_ROM_MR0_DLL_RESET_MIRR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR1 string ""
	set_parameter_property AC_ROM_MR1 DERIVED true
	set_parameter_property AC_ROM_MR1 VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR1_MIRR string ""
	set_parameter_property AC_ROM_MR1_MIRR DERIVED true
	set_parameter_property AC_ROM_MR1_MIRR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR1_CALIB string ""
	set_parameter_property AC_ROM_MR1_CALIB DERIVED true
	set_parameter_property AC_ROM_MR1_CALIB VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR1_OCD_ENABLE string ""
	set_parameter_property AC_ROM_MR1_OCD_ENABLE DERIVED true
	set_parameter_property AC_ROM_MR1_OCD_ENABLE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR2 string ""
	set_parameter_property AC_ROM_MR2 DERIVED true
	set_parameter_property AC_ROM_MR2 VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR2_MIRR string ""
	set_parameter_property AC_ROM_MR2_MIRR DERIVED true
	set_parameter_property AC_ROM_MR2_MIRR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR3 string ""
	set_parameter_property AC_ROM_MR3 DERIVED true
	set_parameter_property AC_ROM_MR3 VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_ROM_MR3_MIRR string ""
	set_parameter_property AC_ROM_MR3_MIRR DERIVED true
	set_parameter_property AC_ROM_MR3_MIRR VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY BOOLEAN false
	set_parameter_property USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY VISIBLE false
	set_parameter_property USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY DERIVED true

	if {[regexp {^DDR2$|^DDR3$|^LPDDR1$|^HPS$} $ddr_mode] == 1} {

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR0_BL Integer 2
		set_parameter_property MR0_BL VISIBLE FALSE
		set_parameter_property MR0_BL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR0_BT Integer 0
		set_parameter_property MR0_BT VISIBLE FALSE
		set_parameter_property MR0_BT DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR0_CAS_LATENCY Integer 3
		set_parameter_property MR0_CAS_LATENCY VISIBLE FALSE
		set_parameter_property MR0_CAS_LATENCY DERIVED TRUE

	}

	if {[regexp {^DDR2$|^DDR3$|^HPS$} $ddr_mode] == 1} {

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR0_DLL Integer 1
		set_parameter_property MR0_DLL VISIBLE FALSE
		set_parameter_property MR0_DLL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR0_WR Integer 4
		set_parameter_property MR0_WR VISIBLE FALSE
		set_parameter_property MR0_WR DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR0_PD Integer 0
		set_parameter_property MR0_PD VISIBLE FALSE
		set_parameter_property MR0_PD DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_DLL Integer 0
		set_parameter_property MR1_DLL VISIBLE FALSE
		set_parameter_property MR1_DLL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_ODS Integer 1
		set_parameter_property MR1_ODS VISIBLE FALSE
		set_parameter_property MR1_ODS DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_RTT Integer 1
		set_parameter_property MR1_RTT VISIBLE FALSE
		set_parameter_property MR1_RTT DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_AL Integer 0
		set_parameter_property MR1_AL VISIBLE FALSE
		set_parameter_property MR1_AL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_WL Integer 0
		set_parameter_property MR1_WL VISIBLE FALSE
		set_parameter_property MR1_WL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_TDQS Integer 0
		set_parameter_property MR1_TDQS VISIBLE FALSE
		set_parameter_property MR1_TDQS DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_QOFF Integer 0
		set_parameter_property MR1_QOFF VISIBLE FALSE
		set_parameter_property MR1_QOFF DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_DQS Integer 0
		set_parameter_property MR1_DQS VISIBLE FALSE
		set_parameter_property MR1_DQS DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_RDQS Integer 0
		set_parameter_property MR1_RDQS VISIBLE FALSE
		set_parameter_property MR1_RDQS DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR2_CWL Integer 1
		set_parameter_property MR2_CWL VISIBLE FALSE
		set_parameter_property MR2_CWL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR2_ASR Integer 0
		set_parameter_property MR2_ASR VISIBLE FALSE
		set_parameter_property MR2_ASR DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR2_SRT Integer 0
		set_parameter_property MR2_SRT VISIBLE FALSE
		set_parameter_property MR2_SRT DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR2_SRF Integer 0
		set_parameter_property MR2_SRF VISIBLE FALSE
		set_parameter_property MR2_SRF DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR2_RTT_WR Integer 1
		set_parameter_property MR2_RTT_WR VISIBLE FALSE
		set_parameter_property MR2_RTT_WR DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR3_MPR_RF Integer 0
		set_parameter_property MR3_MPR_RF VISIBLE FALSE
		set_parameter_property MR3_MPR_RF DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR3_MPR Integer 0
		set_parameter_property MR3_MPR VISIBLE FALSE
		set_parameter_property MR3_MPR DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR3_MPR_AA Integer 0
		set_parameter_property MR3_MPR_AA VISIBLE FALSE
		set_parameter_property MR3_MPR_AA DERIVED TRUE

	}

	if {[regexp {^LPDDR2$|^HPS$} $ddr_mode] == 1} {

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_BL Integer 2
		set_parameter_property MR1_BL VISIBLE FALSE
		set_parameter_property MR1_BL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_BT Integer 0
		set_parameter_property MR1_BT VISIBLE FALSE
		set_parameter_property MR1_BT DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_WC Integer 0
		set_parameter_property MR1_WC VISIBLE FALSE
		set_parameter_property MR1_WC DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_WR Integer 1
		set_parameter_property MR1_WR VISIBLE FALSE
		set_parameter_property MR1_WR DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR2_RLWL Integer 1
		set_parameter_property MR2_RLWL VISIBLE FALSE
		set_parameter_property MR2_RLWL DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR3_DS Integer 2
		set_parameter_property MR3_DS VISIBLE FALSE
		set_parameter_property MR3_DS DERIVED TRUE

	}

	if {[regexp {^LPDDR1$|^HPS$} $ddr_mode] == 1} {

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_DS Integer 0
		set_parameter_property MR1_DS VISIBLE FALSE
		set_parameter_property MR1_DS DERIVED TRUE

		::alt_mem_if::util::hwtcl_utils::_add_parameter MR1_PASR Integer 0
		set_parameter_property MR1_PASR VISIBLE FALSE
		set_parameter_property MR1_PASR DERIVED TRUE

	}
}


proc ::alt_mem_if::gui::common_ddr_mem_model::_create_derived_parameters {} {

	_validate_ddr_mode

	_dprint 1 "Preparing to create derived parameters in common_ddr_mem_model"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_READ_DQS_WIDTH integer 0
	set_parameter_property MEM_IF_READ_DQS_WIDTH VISIBLE FALSE
	set_parameter_property MEM_IF_READ_DQS_WIDTH DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_WRITE_DQS_WIDTH integer 0
	set_parameter_property MEM_IF_WRITE_DQS_WIDTH VISIBLE FALSE
	set_parameter_property MEM_IF_WRITE_DQS_WIDTH DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter SCC_DATA_WIDTH integer 0
	set_parameter_property SCC_DATA_WIDTH VISIBLE FALSE
	set_parameter_property SCC_DATA_WIDTH DERIVED TRUE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_ADDR_WIDTH Integer 0
	set_parameter_property MEM_IF_ADDR_WIDTH Visible false
	set_parameter_property MEM_IF_ADDR_WIDTH Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_ADDR_WIDTH_MIN Integer 10
	set_parameter_property MEM_IF_ADDR_WIDTH_MIN Visible false
	set_parameter_property MEM_IF_ADDR_WIDTH_MIN Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_ROW_ADDR_WIDTH Integer 0
	set_parameter_property MEM_IF_ROW_ADDR_WIDTH Visible false
	set_parameter_property MEM_IF_ROW_ADDR_WIDTH Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_COL_ADDR_WIDTH Integer 0
	set_parameter_property MEM_IF_COL_ADDR_WIDTH Visible false
	set_parameter_property MEM_IF_COL_ADDR_WIDTH Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DM_WIDTH Integer 0
	set_parameter_property MEM_IF_DM_WIDTH Visible false
	set_parameter_property MEM_IF_DM_WIDTH Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CS_PER_RANK Integer 0
	set_parameter_property MEM_IF_CS_PER_RANK Visible false
	set_parameter_property MEM_IF_CS_PER_RANK Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_NUMBER_OF_RANKS Integer 0
	set_parameter_property MEM_IF_NUMBER_OF_RANKS Visible false
	set_parameter_property MEM_IF_NUMBER_OF_RANKS Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CS_PER_DIMM Integer 0
	set_parameter_property MEM_IF_CS_PER_DIMM Visible false
	set_parameter_property MEM_IF_CS_PER_DIMM Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CONTROL_WIDTH Integer 0
	set_parameter_property MEM_IF_CONTROL_WIDTH Visible false
	set_parameter_property MEM_IF_CONTROL_WIDTH Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BURST_LENGTH Integer 8
	set_parameter_property MEM_BURST_LENGTH Visible false
	set_parameter_property MEM_BURST_LENGTH Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_LEVELING BOOLEAN true
	set_parameter_property MEM_LEVELING Visible false
	set_parameter_property MEM_LEVELING Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DQS_WIDTH Integer 0
	set_parameter_property MEM_IF_DQS_WIDTH Visible true
	set_parameter_property MEM_IF_DQS_WIDTH Derived true
	set_parameter_property MEM_IF_DQS_WIDTH DISPLAY_NAME "Number of DQS groups"
	set_parameter_property MEM_IF_DQS_WIDTH DESCRIPTION "Number of DQS groups is calculated automatically from the Total interface width and the DQ/DQS group size parameters."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CS_WIDTH Integer 0
	set_parameter_property MEM_IF_CS_WIDTH Visible false
	set_parameter_property MEM_IF_CS_WIDTH Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CHIP_BITS integer -1
	set_parameter_property MEM_IF_CHIP_BITS visible false
	set_parameter_property MEM_IF_CHIP_BITS derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_BANKADDR_WIDTH Integer 0
	set_parameter_property MEM_IF_BANKADDR_WIDTH Visible false
	set_parameter_property MEM_IF_BANKADDR_WIDTH Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DQ_WIDTH INTEGER 0
	set_parameter_property MEM_IF_DQ_WIDTH DERIVED true
	set_parameter_property MEM_IF_DQ_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CK_WIDTH Integer 0
	set_parameter_property MEM_IF_CK_WIDTH Visible false
	set_parameter_property MEM_IF_CK_WIDTH Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CLK_EN_WIDTH integer 0
	set_parameter_property MEM_IF_CLK_EN_WIDTH VISIBLE false
	set_parameter_property MEM_IF_CLK_EN_WIDTH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_CLK_PAIR_COUNT INTEGER 1
	set_parameter_property MEM_IF_CLK_PAIR_COUNT DERIVED true
	set_parameter_property MEM_IF_CLK_PAIR_COUNT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DEVICE_WIDTH integer 1
	set_parameter_property DEVICE_WIDTH VISIBLE FALSE
	set_parameter_property DEVICE_WIDTH DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_MAX_NS float 2.5
	set_parameter_property MEM_CLK_MAX_NS DERIVED true
	set_parameter_property MEM_CLK_MAX_NS VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_MAX_PS float 2500
	set_parameter_property MEM_CLK_MAX_PS DERIVED true
	set_parameter_property MEM_CLK_MAX_PS VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRC Integer 0
	set_parameter_property MEM_TRC VISIBLE false
	set_parameter_property MEM_TRC DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRAS Integer 0
	set_parameter_property MEM_TRAS DERIVED true
	set_parameter_property MEM_TRAS VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRCD Integer 0
	set_parameter_property MEM_TRCD Derived true
	set_parameter_property MEM_TRCD Visible false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRP Integer 0
	set_parameter_property MEM_TRP DERIVED true
	set_parameter_property MEM_TRP VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TREFI Integer 0
	set_parameter_property MEM_TREFI DERIVED true
	set_parameter_property MEM_TREFI VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRFC Integer 0
	set_parameter_property MEM_TRFC DERIVED true
	set_parameter_property MEM_TRFC VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_TCCD Integer 0
	set_parameter_property CFG_TCCD DERIVED true
	set_parameter_property CFG_TCCD VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TWR Integer 0
	set_parameter_property MEM_TWR DERIVED true
	set_parameter_property MEM_TWR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TFAW Integer 0
	set_parameter_property MEM_TFAW DERIVED true
	set_parameter_property MEM_TFAW VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRRD Integer 0
	set_parameter_property MEM_TRRD VISIBLE false
	set_parameter_property MEM_TRRD DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRTP Integer 0
	set_parameter_property MEM_TRTP Derived true
	set_parameter_property MEM_TRTP Visible false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DQS_TO_CLK_CAPTURE_DELAY Integer 0
	set_parameter_property MEM_DQS_TO_CLK_CAPTURE_DELAY Derived true
	set_parameter_property MEM_DQS_TO_CLK_CAPTURE_DELAY Visible false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_TO_DQS_CAPTURE_DELAY Integer 0
	set_parameter_property MEM_CLK_TO_DQS_CAPTURE_DELAY Derived true
	set_parameter_property MEM_CLK_TO_DQS_CAPTURE_DELAY Visible false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_ODT_WIDTH Integer 0
	set_parameter_property MEM_IF_ODT_WIDTH Visible false
	set_parameter_property MEM_IF_ODT_WIDTH Derived true		

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_WTCL_INT Integer 6
	set_parameter_property MEM_WTCL_INT Visible false
	set_parameter_property MEM_WTCL_INT Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter FLY_BY boolean true
	set_parameter_property FLY_BY VISIBLE FALSE
	set_parameter_property FLY_BY DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter RDIMM boolean false
	set_parameter_property RDIMM VISIBLE FALSE
	set_parameter_property RDIMM DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter LRDIMM boolean false
	set_parameter_property LRDIMM VISIBLE FALSE
	set_parameter_property LRDIMM DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter RDIMM_INT Integer 0
	set_parameter_property RDIMM_INT VISIBLE false
	set_parameter_property RDIMM_INT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter LRDIMM_INT Integer 0
	set_parameter_property LRDIMM_INT VISIBLE false
	set_parameter_property LRDIMM_INT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_RD_TO_WR_TURNAROUND_OCT Integer 0
	set_parameter_property MEM_IF_RD_TO_WR_TURNAROUND_OCT VISIBLE false
	set_parameter_property MEM_IF_RD_TO_WR_TURNAROUND_OCT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_WR_TO_RD_TURNAROUND_OCT Integer 3
	set_parameter_property MEM_IF_WR_TO_RD_TURNAROUND_OCT VISIBLE false
	set_parameter_property MEM_IF_WR_TO_RD_TURNAROUND_OCT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_RD_TO_PCH_EXTRA_CLK Integer 0
	set_parameter_property CTL_RD_TO_PCH_EXTRA_CLK VISIBLE false
	set_parameter_property CTL_RD_TO_PCH_EXTRA_CLK DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_RD_TO_RD_EXTRA_CLK Integer 0
	set_parameter_property CTL_RD_TO_RD_EXTRA_CLK VISIBLE false
	set_parameter_property CTL_RD_TO_RD_EXTRA_CLK DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_WR_TO_WR_EXTRA_CLK Integer 0
	set_parameter_property CTL_WR_TO_WR_EXTRA_CLK VISIBLE false
	set_parameter_property CTL_WR_TO_WR_EXTRA_CLK DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK Integer 0
	set_parameter_property CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK VISIBLE false
	set_parameter_property CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK Integer 0
	set_parameter_property CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK VISIBLE false
	set_parameter_property CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TYPE String ""
	set_parameter_property MEM_TYPE Visible false
	set_parameter_property MEM_TYPE Derived true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_MIRROR_ADDRESSING_DEC INTEGER 0
	set_parameter_property MEM_MIRROR_ADDRESSING_DEC VISIBLE FALSE
	set_parameter_property MEM_MIRROR_ADDRESSING_DEC DERIVED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ATCL_INT INTEGER 0
	set_parameter_property MEM_ATCL_INT VISIBLE false
	set_parameter_property MEM_ATCL_INT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_REGDIMM_ENABLED BOOLEAN false
	set_parameter_property MEM_REGDIMM_ENABLED VISIBLE false
	set_parameter_property MEM_REGDIMM_ENABLED DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_LRDIMM_ENABLED BOOLEAN false
	set_parameter_property MEM_LRDIMM_ENABLED VISIBLE false
	set_parameter_property MEM_LRDIMM_ENABLED DERIVED true
}


proc ::alt_mem_if::gui::common_ddr_mem_model::_create_memory_initialization_parameters {} {

	_validate_ddr_mode

	variable ddr_mode

	_dprint 1 "Preparing to create memory initialization parameters in common_ddr_mem_model"

	if {[regexp {^DDR2$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BL String "8"
	} elseif {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BL String "OTF"
	} elseif {[regexp {^LPDDR2$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BL String "8"
	} elseif {[regexp {^LPDDR1$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BL String "4"
	}
	set_parameter_property MEM_BL Display_Name "Burst Length"
	set_parameter_property MEM_BL Visible false
	set_parameter_property MEM_BL DESCRIPTION "Specify the burst length."

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BT String "Sequential"
	set_parameter_property MEM_BT Display_Name "Read Burst Type"
	set_parameter_property MEM_BT Visible true
	set_parameter_property MEM_BT Allowed_Ranges {"Sequential" "Interleaved"}
	set_parameter_property MEM_BT DESCRIPTION "Specify whether accesses within a given burst are in sequential or interleaved order."

	if {[regexp {^DDR2$|^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ASR String "Manual"
		set_parameter_property MEM_ASR Display_Name "Auto selfrefresh method"
		set_parameter_property MEM_ASR DESCRIPTION "Turn on or off auto selfrefresh."
		set_parameter_property MEM_ASR Allowed_Ranges {"Manual" "Automatic"}
	}

	if {[regexp {^DDR2$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_SRT String "2x refresh rate"
		set_parameter_property MEM_SRT Display_Name "SRT Enable"
		set_parameter_property MEM_SRT DESCRIPTION "Specify SRT Enable is  \"1x refresh rate\" mode or  \"2x refresh rate\" mode (for high-temperature operations)."

		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_PD String "Fast exit"
		set_parameter_property MEM_PD Display_Name "DLL precharge power down"
		set_parameter_property MEM_PD DESCRIPTION "Specify whether the DLL in the memory device is \"slow exit\" or \"fast exit\" during precharge power-down."

		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DRV_STR String "Full"
		set_parameter_property MEM_DRV_STR Display_Name "Output drive strength setting"
		set_parameter_property MEM_DRV_STR DESCRIPTION "Specify the output driver impedance setting at the memory device."
	} elseif {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_SRT String "Normal"
		set_parameter_property MEM_SRT Display_Name "Selfrefresh temperature"
		set_parameter_property MEM_SRT DESCRIPTION "Specify the self-refresh temperature is  \"Normal\" or \"Extended\" mode."

		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_PD String "DLL off"
		set_parameter_property MEM_PD Display_Name "DLL precharge power down"
		set_parameter_property MEM_PD DESCRIPTION "Specify whether the DLL in the memory device is off or on during precharge power-down."

		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DRV_STR String "RZQ/6"
		set_parameter_property MEM_DRV_STR Display_Name "Output drive strength setting"
		set_parameter_property MEM_DRV_STR DESCRIPTION "Specify the output driver impedance setting at the memory device."
	} elseif {[regexp {^LPDDR2$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DRV_STR String "40"
		set_parameter_property MEM_DRV_STR Display_Name "Output drive strength setting"
		set_parameter_property MEM_DRV_STR DESCRIPTION "Specify the output driver impedance setting at the memory device."
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DLL_EN Boolean true
	set_parameter_property MEM_DLL_EN Display_Name "Enable the DLL in memory devices"
	set_parameter_property MEM_DLL_EN Visible false
	set_parameter_property MEM_DLL_EN Display_Hint boolean

	if {[regexp {^DDR2$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_RTT_NOM String "Disabled"
		set_parameter_property MEM_RTT_NOM Display_Name "Memory on-die termination (ODT) setting"
		set_parameter_property MEM_RTT_NOM DESCRIPTION "Determines the ODT resistance at the memory device."
	} elseif {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_RTT_NOM String "ODT Disabled"
		set_parameter_property MEM_RTT_NOM Display_Name "ODT Rtt nominal value"
		set_parameter_property MEM_RTT_NOM DESCRIPTION "Determines the ODT resistance at the memory device."
	}
	
	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_RTT_WR String "Dynamic ODT off"
		set_parameter_property MEM_RTT_WR Display_Name "Dynamic ODT (Rtt_WR) value"
		set_parameter_property MEM_RTT_WR DESCRIPTION "Specify the mode of the dynamic ODT feature of the memory device."
	}

	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_WTCL Integer 6
		set_parameter_property MEM_WTCL Display_Name "Memory write CAS latency setting"
		set_parameter_property MEM_WTCL DESCRIPTION "Specify the number of clock cycles from the releasing of the internal write to the latching of the first data in, at the memory device."
	}

	if {[regexp {^DDR2$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ATCL Integer 0
		set_parameter_property MEM_ATCL Display_Name "Memory additive CAS latency setting"
		set_parameter_property MEM_ATCL DESCRIPTION "Determines the posted CAS additive latency of the memory device."
	} elseif {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ATCL String "Disabled"
		set_parameter_property MEM_ATCL Display_Name "Memory additive CAS latency setting"
		set_parameter_property MEM_ATCL DESCRIPTION "Determines the posted CAS additive latency of the memory device."
	} elseif {[regexp {^LPDDR2$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ATCL Integer 0
		set_parameter_property MEM_ATCL Display_Name "Memory additive CAS latency setting"
		set_parameter_property MEM_ATCL DESCRIPTION "Determines the posted CAS additive latency of the memory device."
	}

	if {[regexp {^LPDDR1$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TCL integer 3
	} else {
	    ::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TCL integer 7
	}
	if {[regexp {^LPDDR2$} $ddr_mode] == 1} {
	    set_parameter_property MEM_TCL Display_Name "Read latency setting"
	} else {
	    set_parameter_property MEM_TCL Display_Name "Memory CAS latency setting"
	}
	set_parameter_property MEM_TCL Visible true
	set_parameter_property MEM_TCL DESCRIPTION "Determines the number of clock cycles between the READ command and the availability of the first bit of output data at the memory device."

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_AUTO_LEVELING_MODE BOOLEAN true
	set_parameter_property MEM_AUTO_LEVELING_MODE DISPLAY_NAME "Autoleveling selection"
	set_parameter_property MEM_AUTO_LEVELING_MODE UNITS None
	set_parameter_property MEM_AUTO_LEVELING_MODE VISIBLE false
	set_parameter_property MEM_AUTO_LEVELING_MODE AFFECTS_ELABORATION true
	set_parameter_property MEM_AUTO_LEVELING_MODE DESCRIPTION "Enables autoselection of the type of leveling. The UniPHY IP selects the optimal interface type depending on frequency and geometry. DDR2 and DDR3 SDRAM controllers with UniPHY can implement leveling calibration to minimize the skew between DQS and CK on the write side. Leveling is strictly required for DDR3 SDRAM DIMMs, however it can be beneficial for DDR2 and DDR3 interfaces which do not use a fly-by clock topology. By default, the wizard always implements leveling above 240 MHz. To override this default turn off Autoleveling selection and then set the Leveling interface mode to the value you require."

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_USER_LEVELING_MODE STRING "Leveling"
	set_parameter_property MEM_USER_LEVELING_MODE DISPLAY_NAME "Leveling interface mode"
	set_parameter_property MEM_USER_LEVELING_MODE UNITS None
	set_parameter_property MEM_USER_LEVELING_MODE VISIBLE false
	set_parameter_property MEM_USER_LEVELING_MODE AFFECTS_ELABORATION true
	set_parameter_property MEM_USER_LEVELING_MODE DESCRIPTION "Specify whether the IP core instantiates an interface with or without leveling."
	set_parameter_property MEM_USER_LEVELING_MODE ALLOWED_RANGES {"Leveling" "Non-Leveling"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_INIT_EN BOOLEAN false
	set_parameter_property MEM_INIT_EN Display_Name "Enables memory content initialization"
	set_parameter_property MEM_INIT_EN Visible false
	set_parameter_property MEM_INIT_EN DESCRIPTION "Enables memory content initialization from a file"

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_INIT_FILE String ""
	set_parameter_property MEM_INIT_FILE Display_Name "Memory Initialization File"
	set_parameter_property MEM_INIT_FILE Visible false
	set_parameter_property MEM_INIT_FILE DESCRIPTION "Specify the full path to the file that contains the avalon address and the avalon data to be loaded into memory"

	::alt_mem_if::util::hwtcl_utils::_add_parameter DAT_DATA_WIDTH integer 32
	set_parameter_property DAT_DATA_WIDTH Display_Name "Data width"
	set_parameter_property DAT_DATA_WIDTH Visible false
	set_parameter_property DAT_DATA_WIDTH DESCRIPTION "Width of the avalon data in the memory initialization file"

	return 1

}


proc ::alt_mem_if::gui::common_ddr_mem_model::_create_memory_timing_parameters {} {

	_validate_ddr_mode

	variable ddr_mode

	_dprint 1 "Preparing to create memory timing parameters in common_ddr_mem_model"

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TIS integer 175
	set_parameter_property TIMING_TIS DESCRIPTION "Address and control setup to K clock rise"
	set_parameter_property TIMING_TIS DISPLAY_NAME "tIS (base)"
	set_parameter_property TIMING_TIS UNITS picoseconds
	set_parameter_property TIMING_TIS ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TIH integer 250
	set_parameter_property TIMING_TIH DESCRIPTION "Address and control hold after K clock rise"
	set_parameter_property TIMING_TIH DISPLAY_NAME "tIH (base)"
	set_parameter_property TIMING_TIH UNITS picoseconds
	set_parameter_property TIMING_TIH ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDS integer 50
	set_parameter_property TIMING_TDS DESCRIPTION "Data setup to clock (K/K#) rise"
	set_parameter_property TIMING_TDS DISPLAY_NAME "tDS (base)"
	set_parameter_property TIMING_TDS UNITS picoseconds
	set_parameter_property TIMING_TDS ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDH integer 125
	set_parameter_property TIMING_TDH DESCRIPTION "Data hold after clock (K/K#) rise"
	set_parameter_property TIMING_TDH DISPLAY_NAME "tDH (base)"
	set_parameter_property TIMING_TDH UNITS picoseconds
	set_parameter_property TIMING_TDH ALLOWED_RANGES {0:5000}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSQ integer 120
	set_parameter_property TIMING_TDQSQ DESCRIPTION "DQS, DQS# to DQ skew, per access"
	set_parameter_property TIMING_TDQSQ DISPLAY_NAME "tDQSQ"
	set_parameter_property TIMING_TDQSQ UNITS picoseconds
	set_parameter_property TIMING_TDQSQ ALLOWED_RANGES {-5000:5000}
	
	if {[regexp {^DDR2$|^LPDDR2$|^LPDDR1$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQHS integer 300
		set_parameter_property TIMING_TQHS DESCRIPTION "DQ hold skew factor"
		set_parameter_property TIMING_TQHS DISPLAY_NAME "tQHS"
		set_parameter_property TIMING_TQHS UNITS picoseconds
		set_parameter_property TIMING_TQHS DISPLAY_HINT columns:10
	}

	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQH Float 0.38
		set_parameter_property TIMING_TQH DESCRIPTION "DQ output hold time from DQS, DQS# (percentage of tCK)"
		set_parameter_property TIMING_TQH DISPLAY_NAME "tQH"
		set_parameter_property TIMING_TQH UNITS Cycles
		set_parameter_property TIMING_TQH DISPLAY_HINT columns:10
	}
	
	if {[regexp {^LPDDR2$} $ddr_mode] == 1} {
	    ::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSCK integer 2500
	} else {
	    ::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSCK integer 400
	}
	set_parameter_property TIMING_TDQSCK DESCRIPTION "DQS output access time from CK/CK#"
	set_parameter_property TIMING_TDQSCK DISPLAY_NAME "tDQSCK"
	set_parameter_property TIMING_TDQSCK UNITS picoseconds
	
    ::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSCKDS integer 450
	set_parameter_property TIMING_TDQSCKDS DESCRIPTION "Absolute difference between any two tDQSCK measurements (within a byte lane) within a contiguous sequence of bursts within a 160ns rolling window"
	set_parameter_property TIMING_TDQSCKDS DISPLAY_NAME "tDQSCK Delta Short"
	set_parameter_property TIMING_TDQSCKDS UNITS picoseconds
	
    ::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSCKDM integer 900
	set_parameter_property TIMING_TDQSCKDM DESCRIPTION "Absolute difference between any two tDQSCK measurements (within a byte lane) within a contiguous sequence of bursts within a 1.6us rolling window"
	set_parameter_property TIMING_TDQSCKDM DISPLAY_NAME "tDQSCK Delta Medium"
	set_parameter_property TIMING_TDQSCKDM UNITS picoseconds
	
    ::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSCKDL integer 1200
	set_parameter_property TIMING_TDQSCKDL DESCRIPTION "Absolute difference between any two tDQSCK measurements (within a byte lane) within a contiguous sequence of bursts within a 32ms rolling window"
	set_parameter_property TIMING_TDQSCKDL DISPLAY_NAME "tDQSCK Delta Long"
	set_parameter_property TIMING_TDQSCKDL UNITS picoseconds
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSS Float 0.25
	set_parameter_property TIMING_TDQSS DESCRIPTION "First latching edge of DQS to associated clock edge (percentage of tCK)"
	set_parameter_property TIMING_TDQSS DISPLAY_NAME "tDQSS"
	set_parameter_property TIMING_TDQSS UNITS Cycles
	set_parameter_property TIMING_TDQSS DISPLAY_HINT columns:10
	
	if {[regexp {^DDR2$|^LPDDR2$|^LPDDR1$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDQSH Float 0.35
		set_parameter_property TIMING_TDQSH DESCRIPTION "DQS High Pulse Width (percentage of tCK)"
		set_parameter_property TIMING_TDQSH DISPLAY_NAME "tDQSH"
		set_parameter_property TIMING_TDQSH UNITS Cycles
		set_parameter_property TIMING_TDQSH DISPLAY_HINT columns:10
	}

	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TQSH Float 0.38
		set_parameter_property TIMING_TQSH DESCRIPTION "DQS Differential High Pulse Width (percentage of tCK)"
		set_parameter_property TIMING_TQSH DISPLAY_NAME "tQSH"
		set_parameter_property TIMING_TQSH UNITS Cycles
		set_parameter_property TIMING_TQSH DISPLAY_HINT columns:10
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDSH Float 0.2
	set_parameter_property TIMING_TDSH DESCRIPTION "DQS falling edge hold time from CK (percentage of tCK)"
	set_parameter_property TIMING_TDSH DISPLAY_NAME "tDSH"
	set_parameter_property TIMING_TDSH UNITS Cycles
	set_parameter_property TIMING_TDSH DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TIMING_TDSS Float 0.2
	set_parameter_property TIMING_TDSS DESCRIPTION "DQS falling edge to CK setup time (percentage of tCK)"
	set_parameter_property TIMING_TDSS DISPLAY_NAME "tDSS"
	set_parameter_property TIMING_TDSS UNITS Cycles
	set_parameter_property TIMING_TDSS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TINIT_US integer 499
	set_parameter_property MEM_TINIT_US Description "Memory initialization time at power-up"
	set_parameter_property MEM_TINIT_US Display_Name "tINIT"
	set_parameter_property MEM_TINIT_US Visible true
	set_parameter_property MEM_TINIT_US Units Microseconds
	set_parameter_property MEM_TINIT_US DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TINIT_CK integer 499
	set_parameter_property MEM_TINIT_CK Visible false
	set_parameter_property MEM_TINIT_CK Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TDQSCK integer 2
	set_parameter_property MEM_TDQSCK Visible false
	set_parameter_property MEM_TDQSCK Derived true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TMRD_CK integer 3
	set_parameter_property MEM_TMRD_CK Description "Load mode register command period"
	if {[regexp {^LPDDR2$} $ddr_mode] == 1} {
	        set_parameter_property MEM_TMRD_CK Display_Name "tMRW"
        } else {
                set_parameter_property MEM_TMRD_CK Display_Name "tMRD"
        }
	set_parameter_property MEM_TMRD_CK Visible true
	set_parameter_property MEM_TMRD_CK Units Cycles
	set_parameter_property MEM_TMRD_CK DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRAS_NS Float 40
	set_parameter_property MEM_TRAS_NS Description "Active to precharge time"
	set_parameter_property MEM_TRAS_NS Display_Name "tRAS"
	set_parameter_property MEM_TRAS_NS Visible true
	set_parameter_property MEM_TRAS_NS Units Nanoseconds
	set_parameter_property MEM_TRAS_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRCD_NS Float 15
	set_parameter_property MEM_TRCD_NS Description "Active to read/write time"
	set_parameter_property MEM_TRCD_NS Display_Name "tRCD"
	set_parameter_property MEM_TRCD_NS Visible true
	set_parameter_property MEM_TRCD_NS Units Nanoseconds
	set_parameter_property MEM_TRCD_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRP_NS Float 15
	set_parameter_property MEM_TRP_NS Description "Precharge command period"
	set_parameter_property MEM_TRP_NS Display_Name "tRP"
	set_parameter_property MEM_TRP_NS Visible true
	set_parameter_property MEM_TRP_NS Units Nanoseconds
	set_parameter_property MEM_TRP_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TREFI_US Float 7
	if {[regexp {^LPDDR2$} $ddr_mode] == 1} {
	        set_parameter_property MEM_TREFI_US Description "Refresh command interval (all bank only)"
	        set_parameter_property MEM_TREFI_US Display_Name "tREFIab"
        } else {
	        set_parameter_property MEM_TREFI_US Description "Refresh command interval"
	        set_parameter_property MEM_TREFI_US Display_Name "tREFI"
        }
	set_parameter_property MEM_TREFI_US Visible true
	set_parameter_property MEM_TREFI_US Units Microseconds
	set_parameter_property MEM_TREFI_US DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRFC_NS Float 75
	if {[regexp {^LPDDR2$} $ddr_mode] == 1} {
	        set_parameter_property MEM_TRFC_NS Description "Auto-refresh command interval (all bank only)"
	        set_parameter_property MEM_TRFC_NS Display_Name "tRFCab"
        } else {
	        set_parameter_property MEM_TRFC_NS Description "Auto-refresh command interval"
	        set_parameter_property MEM_TRFC_NS Display_Name "tRFC"
        }
	set_parameter_property MEM_TRFC_NS Visible true
	set_parameter_property MEM_TRFC_NS Units Nanoseconds
	set_parameter_property MEM_TRFC_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_TCCD_NS Float 2.5
	set_parameter_property CFG_TCCD_NS Description "Read output timing"
	set_parameter_property CFG_TCCD_NS Display_Name "tCCD"
	set_parameter_property CFG_TCCD_NS Visible false
	set_parameter_property CFG_TCCD_NS Units Nanoseconds
	set_parameter_property CFG_TCCD_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TWR_NS Float 15
	set_parameter_property MEM_TWR_NS Description "Write recovery time"
	set_parameter_property MEM_TWR_NS Display_Name "tWR"
	set_parameter_property MEM_TWR_NS Visible true
	set_parameter_property MEM_TWR_NS Units Nanoseconds
	set_parameter_property MEM_TWR_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TWTR Integer 2
	set_parameter_property MEM_TWTR Description "Write to read period"
	set_parameter_property MEM_TWTR Display_Name "tWTR"
	set_parameter_property MEM_TWTR Visible true
	set_parameter_property MEM_TWTR Units Cycles
	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		set_parameter_property MEM_TWTR Allowed_Ranges {1:8}
	} else {
		set_parameter_property MEM_TWTR Allowed_Ranges {1:6}
	}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TFAW_NS Float 37.5
	set_parameter_property MEM_TFAW_NS Description "Four active window time"
	set_parameter_property MEM_TFAW_NS Display_Name "tFAW"
	set_parameter_property MEM_TFAW_NS Visible true
	set_parameter_property MEM_TFAW_NS Units Nanoseconds
	set_parameter_property MEM_TFAW_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRRD_NS Float 7.5
	set_parameter_property MEM_TRRD_NS Description "RAS to RAS delay time"
	set_parameter_property MEM_TRRD_NS Display_Name "tRRD"
	set_parameter_property MEM_TRRD_NS Visible true
	set_parameter_property MEM_TRRD_NS Units Nanoseconds
	set_parameter_property MEM_TRRD_NS DISPLAY_HINT columns:10
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_TRTP_NS Float 7.5
	set_parameter_property MEM_TRTP_NS Description "Read to precharge time"
	set_parameter_property MEM_TRTP_NS Display_Name "tRTP"
	set_parameter_property MEM_TRTP_NS Visible true
	set_parameter_property MEM_TRTP_NS Units Nanoseconds
	set_parameter_property MEM_TRTP_NS DISPLAY_HINT columns:10

	return 1
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_create_memory_parameters_parameters {} {

	_validate_ddr_mode

	variable ddr_mode

	_dprint 1 "Preparing to create memory parameters parameters in common_ddr_mem_model"

	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_VENDOR String JEDEC
	set_parameter_property MEM_VENDOR DISPLAY_NAME "Memory vendor"
	set_parameter_property MEM_VENDOR DESCRIPTION "Vendor of the memory device is set automatically when you select a configuration from the list of memory presets."
	set_parameter_property MEM_VENDOR VISIBLE TRUE
	set_parameter_property MEM_VENDOR ENABLED FALSE
	set_parameter_property MEM_VENDOR ALLOWED_RANGES {JEDEC Qimonda Micron Samsung Hynix Elpida Nanya Other}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_FORMAT String "DISCRETE"
	set_parameter_property MEM_FORMAT DISPLAY_NAME "Memory format"
	set_parameter_property MEM_FORMAT VISIBLE TRUE
	set_parameter_property MEM_FORMAT DESCRIPTION "Format of the memory device."
	set_parameter_property MEM_VENDOR ENABLED TRUE

	::alt_mem_if::util::hwtcl_utils::_add_parameter AC_PARITY boolean false
	set_parameter_property AC_PARITY DISPLAY_NAME "Address and command parity"
	set_parameter_property AC_PARITY DESCRIPTION "Enables address/command parity checking."
	set_parameter_property AC_PARITY ENABLED false
	set_parameter_property AC_PARITY DERIVED TRUE

	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		add_parameter RDIMM_CONFIG String "0000000000000000"
		set_parameter_property RDIMM_CONFIG DISPLAY_NAME "DDR3 RDIMM/LRDIMM Control Words"
		set_parameter_property RDIMM_CONFIG DESCRIPTION "Each 4-bit word can be obtained from the manufacturer's data sheet, and
		should be entered in hexidecimal, starting with RC15 on the left and ending with RC0 on the right."

		add_parameter LRDIMM_EXTENDED_CONFIG String "0x000000000000000000"
		set_parameter_property LRDIMM_EXTENDED_CONFIG DISPLAY_NAME "LRDIMM Additional Control Words"
		set_parameter_property LRDIMM_EXTENDED_CONFIG DESCRIPTION "Each 4-bit word can be obtained from the LRDIMM SPD info, and
		should be entered in hexadecimal, starting with SPD(77-72) or SPD(83-78) on the left and ending with SPD(71-69) on the right."
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter DISCRETE_FLY_BY boolean true
	set_parameter_property DISCRETE_FLY_BY DISPLAY_NAME "Fly-by topology"
	set_parameter_property DISCRETE_FLY_BY DESCRIPTION "Defines whether the IP core uses fly-by topology  in the layout of width expanded discrete devices."

	::alt_mem_if::util::hwtcl_utils::_add_parameter DEVICE_DEPTH integer 1
	if {[regexp {^DDR2$|^DDR3$|^LPDDR1$|^LPDDR2$} $ddr_mode] == 1} {
		set_parameter_property DEVICE_DEPTH DISPLAY_NAME "Number of chip selects"
		set_parameter_property DEVICE_DEPTH DESCRIPTION "Defines how many chip-selects that the current device configuration uses"
	} elseif {[regexp {^HPS$} $ddr_mode] == 1} {
		set_parameter_property DEVICE_DEPTH DISPLAY_NAME "Number of chip select/depth expansion"
		set_parameter_property DEVICE_DEPTH DESCRIPTION "Defines the number of chip-selects or device depth of the current device configuration"
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_MIRROR_ADDRESSING STRING 0
	set_parameter_property MEM_MIRROR_ADDRESSING DISPLAY_NAME "Mirror Addressing: 1 per chip select"
	set_parameter_property MEM_MIRROR_ADDRESSING DESCRIPTION "Mirror Addressing: 1 per chip select (for example, for four CS, \"1101\" makes CS #3, #2 and #0 mirrored"
	set_parameter_property MEM_MIRROR_ADDRESSING DISPLAY_HINT columns:4

	if {[regexp {^LPDDR1$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_FREQ_MAX Float 200
	} else {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_FREQ_MAX Float 400
	}
	set_parameter_property MEM_CLK_FREQ_MAX DISPLAY_NAME "Memory device speed grade"
	set_parameter_property MEM_CLK_FREQ_MAX UNITS Megahertz
	set_parameter_property MEM_CLK_FREQ_MAX DESCRIPTION "The maximum frequency at which the memory device can run."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ROW_ADDR_WIDTH integer 12
	set_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME "Row address width"
	set_parameter_property MEM_ROW_ADDR_WIDTH DESCRIPTION "Width of the row address on the memory device."
	set_parameter_property MEM_ROW_ADDR_WIDTH ALLOWED_RANGES {12:18}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_COL_ADDR_WIDTH integer 8
	set_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME "Column address width"
	set_parameter_property MEM_COL_ADDR_WIDTH DESCRIPTION "Width of the column address on the memory device."
	set_parameter_property MEM_COL_ADDR_WIDTH ALLOWED_RANGES {8:12}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DQ_WIDTH integer 8
	set_parameter_property MEM_DQ_WIDTH VISIBLE true
	set_parameter_property MEM_DQ_WIDTH DISPLAY_NAME "Total interface width"
	set_parameter_property MEM_DQ_WIDTH DESCRIPTION "Total number of DQ pins of the memory device."
	set_parameter_property MEM_DQ_WIDTH ALLOWED_RANGES {4:144}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_DQ_PER_DQS integer 8
	set_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME "DQ/DQS group size"
	set_parameter_property MEM_DQ_PER_DQS DESCRIPTION "Number of DQ bits per DQS group"
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_BANKADDR_WIDTH integer 3
	set_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME "Bank-address width"
	set_parameter_property MEM_BANKADDR_WIDTH DESCRIPTION "Width of the bank address bus on the memory device."
	set_parameter_property MEM_BANKADDR_WIDTH ALLOWED_RANGES {2:3}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DM_PINS_EN Boolean true
	set_parameter_property MEM_IF_DM_PINS_EN VISIBLE true
	set_parameter_property MEM_IF_DM_PINS_EN Display_Name "Enable DM pins"
	set_parameter_property MEM_IF_DM_PINS_EN DESCRIPTION "Specifies whether the DM pins of the memory device are driven by the FPGA.  You can turn off this option to avoid overusing FPGA device pins when using x4 mode memory devices."
	
	if {[regexp {^LPDDR1$} $ddr_mode] == 1} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DQSN_EN Boolean false
	} else {
	    ::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_DQSN_EN Boolean true
	}
	set_parameter_property MEM_IF_DQSN_EN Display_Name "DQS# Enable"
	set_parameter_property MEM_IF_DQSN_EN DESCRIPTION "Generates an additional DQS# pin per DQS group as the complement of the differential data strobe pair DQS/DQS#."
	set_parameter_property MEM_IF_DQSN_EN Visible true
	set_parameter_property MEM_IF_DQSN_EN Display_Hint Boolean
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_NUMBER_OF_DIMMS integer 1
	set_parameter_property MEM_NUMBER_OF_DIMMS DISPLAY_NAME "Number of slots"
	set_parameter_property MEM_NUMBER_OF_DIMMS DESCRIPTION "Number of DIMM slots."
	set_parameter_property MEM_NUMBER_OF_DIMMS ALLOWED_RANGES {1 2}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_NUMBER_OF_RANKS_PER_DIMM integer 1
	set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DISPLAY_NAME "Number of ranks per slot"
	set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DESCRIPTION "Number of ranks per DIMM slot."
	set_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM ALLOWED_RANGES {1 2 4}
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_NUMBER_OF_RANKS_PER_DEVICE integer 1
	set_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE DISPLAY_NAME "Number of ranks per device"
	set_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE DESCRIPTION "Number of ranks per memory device."

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_RANK_MULTIPLICATION_FACTOR integer 1
	set_parameter_property MEM_RANK_MULTIPLICATION_FACTOR DISPLAY_NAME "LRDIMM Rank Multiplication Factor"
	set_parameter_property MEM_RANK_MULTIPLICATION_FACTOR DESCRIPTION "Specifies the multiplication factor for LRDIMM chip select encoding."
	set_parameter_property MEM_RANK_MULTIPLICATION_FACTOR ALLOWED_RANGES {1 2 4}
	set_parameter_property MEM_RANK_MULTIPLICATION_FACTOR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CK_WIDTH integer 1
	set_parameter_property MEM_CK_WIDTH DISPLAY_NAME "Number of clocks"
	set_parameter_property MEM_CK_WIDTH DESCRIPTION "Width of the clock bus on the memory device."
	set_parameter_property MEM_CK_WIDTH ALLOWED_RANGES {1 2 3 4 5 6}
	set_parameter_property MEM_CK_WIDTH VISIBLE true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CS_WIDTH integer 1
	set_parameter_property MEM_CS_WIDTH DISPLAY_NAME "Number of chip-selects per device/DIMM"
	set_parameter_property MEM_CS_WIDTH DESCRIPTION "Number of chip-selects per device/DIMM. Not necessarily equal to ranks for RDIMM/LRDIMMs"
	set_parameter_property MEM_CS_WIDTH ALLOWED_RANGES {1 2 4}
	set_parameter_property MEM_CS_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_EN_WIDTH integer 1
	set_parameter_property MEM_CLK_EN_WIDTH DISPLAY_NAME "Number of clock enables per device/DIMM"
	set_parameter_property MEM_CLK_EN_WIDTH DESCRIPTION "Number of clock enable pins per device/DIMM."
	set_parameter_property MEM_CLK_EN_WIDTH ALLOWED_RANGES {1 2}
	set_parameter_property MEM_CLK_EN_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ALTMEMPHY_COMPATIBLE_MODE Boolean false
	set_parameter_property ALTMEMPHY_COMPATIBLE_MODE DISPLAY_NAME "Allow the memory model to be use in ALTMEMPHY"
	set_parameter_property ALTMEMPHY_COMPATIBLE_MODE DESCRIPTION "Set mem_ck and mem_ck_n port to bidirectional and adjust the role naming"
	set_parameter_property ALTMEMPHY_COMPATIBLE_MODE VISIBLE false

	add_parameter NEXTGEN Boolean true
	set_parameter_property NEXTGEN DISPLAY_NAME "Enable 11.0 extra controller features"
	set_parameter_property NEXTGEN DESCRIPTION "Deselect this option if you are upgrading a pre-11.0 design to retain the expected original controller features."
	set_parameter_property NEXTGEN DISPLAY_HINT boolean
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		set_parameter_property NEXTGEN VISIBLE true
	} else {
		set_parameter_property NEXTGEN VISIBLE false
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_BOARD_BASE_DELAY INTEGER 10
	set_parameter_property MEM_IF_BOARD_BASE_DELAY DISPLAY_NAME "Base board delay for board delay model"
	set_parameter_property MEM_IF_BOARD_BASE_DELAY DESCRIPTION "Base delay is required to allow create smaller windows of valid data"
	set_parameter_property MEM_IF_BOARD_BASE_DELAY VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_IF_SIM_VALID_WINDOW INTEGER 0
	set_parameter_property MEM_IF_SIM_VALID_WINDOW DESCRIPTION "Size in picoseconds of valid window for DQS around CK"
	set_parameter_property MEM_IF_SIM_VALID_WINDOW VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_GUARANTEED_WRITE_INIT Boolean false
	set_parameter_property MEM_GUARANTEED_WRITE_INIT DESCRIPTION "When true, memory will be pre-initialized with calibration guaranteed write values"
	set_parameter_property MEM_GUARANTEED_WRITE_INIT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_VERBOSE boolean true 
	set_parameter_property MEM_VERBOSE DISPLAY_NAME "Enable verbose memory model output"
	set_parameter_property MEM_VERBOSE DESCRIPTION "When turned on, more detailed information about each memory access is displayed during simulation.  This information is useful for debugging."
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter PINGPONGPHY_EN BOOLEAN false
	set_parameter_property PINGPONGPHY_EN DISPLAY_NAME "Enable Ping Pong PHY"
	set_parameter_property PINGPONGPHY_EN DESCRIPTION "Ping Pong PHY instantiates two identical memory interfaces with shared and time-multiplexed address/command buses."
	set_parameter_property PINGPONGPHY_EN VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter REFRESH_BURST_VALIDATION boolean false
	set_parameter_property REFRESH_BURST_VALIDATION DISPLAY_NAME "Enable memory model refresh burst validation"
	set_parameter_property REFRESH_BURST_VALIDATION DESCRIPTION "When turned on, refresh bursts will be validated to adhere to the JEDEC specification. While calibration normally does not preserve data in memory, this option is useful for testing the non-detructive calibration feature."
	set_parameter_property REFRESH_BURST_VALIDATION VISIBLE false
	
	return 1
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_create_memory_timing_gui {} {

	_validate_ddr_mode

	variable ddr_mode
	
	_dprint 1 "Preparing to create memory timing GUI in common_ddr_mem_model"

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		add_display_item "SDRAM" "Memory Timing" GROUP "tab"
	} else {
		add_display_item "Interface Type" "Memory Timing" GROUP "tab"
	}
	
	add_display_item "Memory Timing" id1 TEXT "<html>Apply timing parameters from the manufacturer data sheet <br>Apply device presets from the preset list on the right.<br>  "

	add_display_item "Memory Timing" TIMING_TIS PARAMETER
	add_display_item "Memory Timing" TIMING_TIH PARAMETER
	add_display_item "Memory Timing" TIMING_TDS PARAMETER
	add_display_item "Memory Timing" TIMING_TDH PARAMETER
	add_display_item "Memory Timing" TIMING_TDQSQ PARAMETER
	if {[regexp {^DDR2$|^LPDDR2$|^LPDDR1$|^HPS$} $ddr_mode] == 1} {
		add_display_item "Memory Timing" TIMING_TQHS PARAMETER
	}
	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		add_display_item "Memory Timing" TIMING_TQH PARAMETER
	}
	add_display_item "Memory Timing" TIMING_TDQSCK PARAMETER
	add_display_item "Memory Timing" TIMING_TDQSCKDS PARAMETER
	add_display_item "Memory Timing" TIMING_TDQSCKDM PARAMETER
	add_display_item "Memory Timing" TIMING_TDQSCKDL PARAMETER
	add_display_item "Memory Timing" TIMING_TDQSS PARAMETER
	if {[regexp {^DDR2$|^LPDDR2$|^LPDDR1$|^HPS$} $ddr_mode] == 1} {
		add_display_item "Memory Timing" TIMING_TDQSH PARAMETER
	}
	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		add_display_item "Memory Timing" TIMING_TQSH PARAMETER
	}
	add_display_item "Memory Timing" TIMING_TDSH PARAMETER
	add_display_item "Memory Timing" TIMING_TDSS PARAMETER
	add_display_item "Memory Timing" MEM_TINIT_US parameter
	add_display_item "Memory Timing" MEM_TMRD_CK parameter
	add_display_item "Memory Timing" MEM_TRAS_NS parameter
	add_display_item "Memory Timing" MEM_TRCD_NS parameter
	add_display_item "Memory Timing" MEM_TRP_NS parameter
	add_display_item "Memory Timing" MEM_TREFI_US parameter
	add_display_item "Memory Timing" MEM_TRFC_NS parameter
	add_display_item "Memory Timing" CFG_TCCD_NS parameter
	add_display_item "Memory Timing" MEM_TWR_NS parameter
	add_display_item "Memory Timing" MEM_TWTR parameter
	add_display_item "Memory Timing" MEM_TFAW_NS parameter
	add_display_item "Memory Timing" MEM_TRRD_NS parameter
	add_display_item "Memory Timing" MEM_TRTP_NS parameter
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_create_memory_parameters_gui {} {

	_validate_ddr_mode

	variable ddr_mode

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		add_display_item "SDRAM" "Memory Parameters" GROUP "tab"
	} else {
		add_display_item "Interface Type" "Memory Parameters" GROUP "tab"
	}

	add_display_item "Memory Parameters" id3 TEXT "<html>Apply memory parameters from the manufacturer data sheet <br>Apply device presets  from the preset list on the right.<br>"
	add_display_item "Memory Parameters" MEM_VENDOR PARAMETER
	add_display_item "Memory Parameters" MEM_FORMAT PARAMETER
	add_display_item "Memory Parameters" MEM_CLK_FREQ_MAX PARAMETER
	add_display_item "Memory Parameters" MEM_DQ_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_DQ_PER_DQS PARAMETER
	add_display_item "Memory Parameters" MEM_IF_DQS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_NUMBER_OF_DIMMS PARAMETER
	add_display_item "Memory Parameters" MEM_NUMBER_OF_RANKS_PER_DIMM PARAMETER
	add_display_item "Memory Parameters" MEM_CS_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_CLK_EN_WIDTH PARAMETER
	add_display_item "Memory Parameters" DEVICE_DEPTH PARAMETER
	add_display_item "Memory Parameters" MEM_NUMBER_OF_RANKS_PER_DEVICE PARAMETER
	add_display_item "Memory Parameters" MEM_RANK_MULTIPLICATION_FACTOR PARAMETER
	add_display_item "Memory Parameters" MEM_CK_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_ROW_ADDR_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_COL_ADDR_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_BANKADDR_WIDTH PARAMETER
	add_display_item "Memory Parameters" MEM_IF_DM_PINS_EN PARAMETER
	add_display_item "Memory Parameters" MEM_IF_DQSN_EN PARAMETER
	add_display_item "Memory Parameters" MEM_AUTO_LEVELING_MODE PARAMETER
	add_display_item "Memory Parameters" MEM_USER_LEVELING_MODE PARAMETER

	add_display_item "Memory Parameters" "Memory Topology" GROUP

	add_display_item "Memory Topology" DISCRETE_FLY_BY PARAMETER

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {

		add_display_item "Memory Parameters" "Memory Interface" GROUP

		set_parameter_property MEM_IF_CLK_PAIR_COUNT VISIBLE true
		set_parameter_property MEM_IF_ADDR_WIDTH VISIBLE true
		set_parameter_property MEM_IF_READ_DQS_WIDTH VISIBLE true
		set_parameter_property MEM_IF_WRITE_DQS_WIDTH VISIBLE true
		set_parameter_property MEM_IF_DQ_WIDTH VISIBLE true
		set_parameter_property MEM_IF_DM_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CONTROL_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CS_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CK_WIDTH VISIBLE true
		set_parameter_property MEM_IF_CLK_EN_WIDTH VISIBLE true
		set_parameter_property MEM_IF_ODT_WIDTH VISIBLE true

		add_display_item "Memory Interface" MEM_IF_CLK_PAIR_COUNT PARAMETER
		add_display_item "Memory Interface" MEM_IF_ADDR_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_READ_DQS_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_WRITE_DQS_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_DQ_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_DM_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CONTROL_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CS_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CK_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_CLK_EN_WIDTH PARAMETER
		add_display_item "Memory Interface" MEM_IF_ODT_WIDTH PARAMETER

	}
	
	add_display_item "Memory Parameters" "Memory Initialization Options" GROUP

	add_display_item "Memory Initialization Options" MEM_MIRROR_ADDRESSING PARAMETER
	add_display_item "Memory Initialization Options" AC_PARITY PARAMETER
	if {[regexp {^DDR2$|^DDR3$|^HPS$} $ddr_mode] == 1} {
		add_display_item "Memory Initialization Options" mi1 TEXT "<html><b>Mode Register 0</b><br>"
		add_display_item "Memory Initialization Options" MEM_BL parameter
		add_display_item "Memory Initialization Options" MEM_BT parameter
		add_display_item "Memory Initialization Options" MEM_PD parameter
		add_display_item "Memory Initialization Options" MEM_TCL parameter
		add_display_item "Memory Initialization Options" mi2 TEXT "<html><b>Mode Register 1</b><br>"
		add_display_item "Memory Initialization Options" MEM_DLL_EN parameter
		add_display_item "Memory Initialization Options" MEM_DRV_STR parameter
		add_display_item "Memory Initialization Options" MEM_ATCL parameter
		add_display_item "Memory Initialization Options" MEM_RTT_NOM parameter
		add_display_item "Memory Initialization Options" mi3 TEXT "<html><b>Mode Register 2</b><br>"
		add_display_item "Memory Initialization Options" MEM_ASR parameter
		add_display_item "Memory Initialization Options" MEM_SRT parameter
	}
	if {[regexp {^DDR3$|^HPS$} $ddr_mode] == 1} {
		add_display_item "Memory Initialization Options" MEM_WTCL parameter
		add_display_item "Memory Initialization Options" MEM_RTT_WR parameter
	}
	if {[regexp {^DDR2$|^DDR3$|^HPS$} $ddr_mode] == 1} {
		add_display_item "Memory Initialization Options" MEM_INIT_EN parameter
		add_display_item "Memory Initialization Options" MEM_INIT_FILE parameter
		add_display_item "Memory Initialization Options" DAT_DATA_WIDTH parameter
	}
	if {[regexp {^LPDDR2$} $ddr_mode] == 1} {
	    add_display_item "Memory Initialization Options" mi1 TEXT "<html><b>Mode Register 1</b><br>"
		add_display_item "Memory Initialization Options" MEM_BL parameter
		add_display_item "Memory Initialization Options" MEM_BT parameter
		add_display_item "Memory Initialization Options" mi2 TEXT "<html><b>Mode Register 2</b><br>"
		add_display_item "Memory Initialization Options" MEM_TCL parameter
		add_display_item "Memory Initialization Options" mi3 TEXT "<html><b>Mode Register 3</b><br>"
		add_display_item "Memory Initialization Options" MEM_DRV_STR parameter
	}
	if {[regexp {^LPDDR1$} $ddr_mode] == 1} {
		add_display_item "Memory Initialization Options" MEM_BL parameter
		add_display_item "Memory Initialization Options" MEM_BT parameter
		add_display_item "Memory Initialization Options" MEM_TCL parameter
	}
	if {[regexp {^DDR3$} $ddr_mode] == 1} {
		add_display_item "Memory Initialization Options" RDIMM_CONFIG PARAMETER
		add_display_item "Memory Initialization Options" LRDIMM_EXTENDED_CONFIG PARAMETER
	}

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property MEM_DQ_PER_DQS Visible false
	}
	return 1
}


proc ::alt_mem_if::gui::common_ddr_mem_model::create_diagnostics_gui {} {

	_dprint 1 "Preparing to create Memory Model diagnostics GUI in common_ddr_mem_model"

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		set_parameter_property MEM_VERBOSE Visible false
		return
	} else {
		add_display_item "Interface Type" "Diagnostics" GROUP "tab"
	}
	add_display_item "Diagnostics" "Simulation Options" GROUP
	add_display_item "Simulation Options" MEM_VERBOSE PARAMETER
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_non_destructive_calib_gui]} {
		set_parameter_property REFRESH_BURST_VALIDATION VISIBLE true
		add_display_item "Simulation Options" REFRESH_BURST_VALIDATION PARAMETER
	}
}

proc ::alt_mem_if::gui::common_ddr_mem_model::_derive_mode_register_parameters {} {
	
	variable ddr_mode
	set is_hps [regexp {^HPS$} $ddr_mode]

	set protocol [_get_protocol]

	_dprint 1 "Preparing to derive mode register settings in common_ddr_mem_model"
	
	if {[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {
		if {[regexp {^DDR2$} $protocol] == 1} {
			if {[string compare -nocase [get_parameter_value MEM_BL] "4"] == 0} {
				set_parameter_value MR0_BL 2
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "8"] == 0} {
				set_parameter_value MR0_BL 3
			}
		} elseif {[regexp {^DDR3$} $protocol] == 1} {
			if {[string compare -nocase [get_parameter_value MEM_BL] "8"] == 0} {
				set_parameter_value MR0_BL 0
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "OTF"] == 0} {
				set_parameter_value MR0_BL 1
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "BC4"] == 0} {
				set_parameter_value MR0_BL 2
			}
		} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
			if {[string compare -nocase [get_parameter_value MEM_BL] "4"] == 0} {
				set_parameter_value MR1_BL 2
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "8"] == 0} {
				set_parameter_value MR1_BL 3
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "16"] == 0} {
				set_parameter_value MR1_BL 4
			}
		} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
			if {[string compare -nocase [get_parameter_value MEM_BL] "2"] == 0} {
				set_parameter_value MR0_BL 1
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "4"] == 0} {
				set_parameter_value MR0_BL 2
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "8"] == 0} {
				set_parameter_value MR0_BL 3
			} elseif {[string compare -nocase [get_parameter_value MEM_BL] "16"] == 0} {
				set_parameter_value MR0_BL 4
			}
		}
	} else {
		if {[regexp {^DDR2$} $protocol] == 1} {
			if {[string compare -nocase [get_parameter_value RATE] "HALF"] == 0} {
				set_parameter_value MR0_BL 3
			} else {
				set_parameter_value MR0_BL 2
			}
		} elseif {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_value MR0_BL 1
		} elseif {[regexp {^LPDDR2$|^LPDDR1$} $protocol] == 1} {
			_error "LPDDR2 and LPDDR is not supported by HPCII"
		}
	}

	if {[regexp {^DDR2$|^DDR3$|^LPDDR1$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_BT] "Sequential"] == 0} {
			set_parameter_value MR0_BT 0
		} elseif {[string compare -nocase [get_parameter_value MEM_BT] "Interleaved"] == 0} {
			set_parameter_value MR0_BT 1
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_BT] "Sequential"] == 0} {
			set_parameter_value MR1_BT 0
		} elseif {[string compare -nocase [get_parameter_value MEM_BT] "Interleaved"] == 0} {
			set_parameter_value MR1_BT 1
		}
	}

	if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_ASR] "Manual"] == 0} {
			set_parameter_value MR2_ASR 0
		} elseif {[string compare -nocase [get_parameter_value MEM_ASR] "Automatic"] == 0} {
			set_parameter_value MR2_ASR 1
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_SRT] "1x refresh rate"] == 0} {
			set_parameter_value MR2_SRT 0
		} elseif {[string compare -nocase [get_parameter_value MEM_SRT] "2x refresh rate"] == 0} {
			set_parameter_value MR2_SRT 1
		}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_SRT] "Normal"] == 0} {
			set_parameter_value MR2_SRT 0
		} elseif {[string compare -nocase [get_parameter_value MEM_SRT] "Extended"] == 0} {
			set_parameter_value MR2_SRT 1
		}
	}
	if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
		set_parameter_value MR2_SRF [get_parameter_value MR2_SRT]
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_PD] "Fast exit"] == 0} {
			set_parameter_value MR0_PD 0
		} elseif {[string compare -nocase [get_parameter_value MEM_PD] "Slow exit"] == 0} {
			set_parameter_value MR0_PD 1
		}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_PD] "DLL off"] == 0} {
			set_parameter_value MR0_PD 0
		} elseif {[string compare -nocase [get_parameter_value MEM_PD] "DLL on"] == 0} {
			set_parameter_value MR0_PD 1
		}
	}

	if {[regexp {^DDR2$|^LPDDR1$} $protocol] == 1} {
		set_parameter_value MR0_CAS_LATENCY [get_parameter_value MEM_TCL]
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_value MR0_CAS_LATENCY [ expr [get_parameter_value MEM_TCL] - 4 ]
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_value MR2_RLWL [ expr [get_parameter_value MEM_TCL] - 2 ]
	}

	if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_DLL_EN] "true"] == 0} {
			set_parameter_value MR1_DLL 0
		} else {
			set_parameter_value MR1_DLL 1
		}
	}

	set clock_period [ expr 1000.0 / [ get_parameter_value MEM_CLK_FREQ] ]
	set write_recovery_cycles [ expr int(ceil([expr [get_parameter_value MEM_TWR_NS] / $clock_period]))]
	if {[regexp {^DDR2$} $protocol] == 1} {
		if { $write_recovery_cycles < 2 } {
			set write_recovery_cycles 2
		} elseif { $write_recovery_cycles > 8 } {
			set write_recovery_cycles 8
		}
		set_parameter_value MR0_WR [ expr $write_recovery_cycles - 1 ]
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if { $write_recovery_cycles < 5 } {
			set write_recovery_cycles 5
		} elseif { $write_recovery_cycles > 16 } {
			set write_recovery_cycles 16
		}

		if { $write_recovery_cycles <= 8 } {
			set_parameter_value MR0_WR [ expr $write_recovery_cycles - 4 ]
		} elseif { $write_recovery_cycles <= 10 } {
			set_parameter_value MR0_WR 5
		} elseif { $write_recovery_cycles <= 12 } {
			set_parameter_value MR0_WR 6
		} elseif { $write_recovery_cycles <= 14 } {
			set_parameter_value MR0_WR 7
		} elseif { $write_recovery_cycles <= 16 } {
			set_parameter_value MR0_WR 0
		} else {
			_error "Can't compute MR0_WR value"
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if { $write_recovery_cycles < 3 } {
			set write_recovery_cycles 3
		} elseif { $write_recovery_cycles > 8 } {
			set write_recovery_cycles 8
		}
		set_parameter_value MR1_WR [ expr $write_recovery_cycles - 2 ]
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_DRV_STR] "Full"] == 0} {
			set_parameter_value MR1_ODS 0
		} elseif {[string compare -nocase [get_parameter_value MEM_DRV_STR] "Reduced"] == 0} {
			set_parameter_value MR1_ODS 1
		}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_DRV_STR] "RZQ/6"] == 0} {
			set_parameter_value MR1_ODS 0
		} elseif {[string compare -nocase [get_parameter_value MEM_DRV_STR] "RZQ/7"] == 0} {
			set_parameter_value MR1_ODS 1
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_DRV_STR] "34.3"] == 0} {
			set_parameter_value MR3_DS 1
		} elseif {[string compare -nocase [get_parameter_value MEM_DRV_STR] "40"] == 0} {
			set_parameter_value MR3_DS 2
		} elseif {[string compare -nocase [get_parameter_value MEM_DRV_STR] "48"] == 0} {
			set_parameter_value MR3_DS 3
		} elseif {[string compare -nocase [get_parameter_value MEM_DRV_STR] "60"] == 0} {
			set_parameter_value MR3_DS 4
		} elseif {[string compare -nocase [get_parameter_value MEM_DRV_STR] "80"] == 0} {
			set_parameter_value MR3_DS 6
		} elseif {[string compare -nocase [get_parameter_value MEM_DRV_STR] "120"] == 0} {
			set_parameter_value MR3_DS 7
		} else {
			set_parameter_value MR3_DS 0
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "Disabled"] == 0} {
			_wprint "ODT is disabled. Enabling ODT (Mode Register 1) may improve signal integrity"
			set_parameter_value MR1_RTT 0
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "75"] == 0} {
			set_parameter_value MR1_RTT 1
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "150"] == 0} {
			set_parameter_value MR1_RTT 2
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "50"] == 0} {
			set_parameter_value MR1_RTT 3
		}
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "ODT Disabled"] == 0} {
			_wprint "ODT is disabled. Enabling ODT (Mode Register 1) may improve signal integrity"
			set_parameter_value MR1_RTT 0
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "RZQ/4"] == 0} {
			set_parameter_value MR1_RTT 1
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "RZQ/2"] == 0} {
			set_parameter_value MR1_RTT 2
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_NOM] "RZQ/6"] == 0} {
			set_parameter_value MR1_RTT 3
		}

		set_parameter_value MR2_CWL [ expr [get_parameter_value MEM_WTCL_INT] - 5]
		
		if {[string compare -nocase [get_parameter_value MEM_RTT_WR] "Dynamic ODT off"] == 0} {
			set_parameter_value MR2_RTT_WR 0
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_WR] "RZQ/4"] == 0} {
			set_parameter_value MR2_RTT_WR 1
		} elseif {[string compare -nocase [get_parameter_value MEM_RTT_WR] "RZQ/2"] == 0} {
			set_parameter_value MR2_RTT_WR 2
		}
	}

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_value MR1_AL [get_parameter_value MEM_ATCL]
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		if {[string compare -nocase [get_parameter_value MEM_ATCL] "Disabled"] == 0} {
			set_parameter_value MR1_AL 0
		} elseif {[string compare -nocase [get_parameter_value MEM_ATCL] "CL-1"] == 0} {
			set_parameter_value MR1_AL 1
		} elseif {[string compare -nocase [get_parameter_value MEM_ATCL] "CL-2"] == 0} {
			set_parameter_value MR1_AL 2
		}
	}






	if {[regexp {^DDR2$} $protocol] == 1} {
		set ac_rom_mr0 0
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 3 [get_parameter_value MR0_BL]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 3 1 [get_parameter_value MR0_BT]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 4 3 [get_parameter_value MR0_CAS_LATENCY]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 8 1 0]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 9 3 [get_parameter_value MR0_WR]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 12 1 [get_parameter_value MR0_PD]]
		set_parameter_value AC_ROM_MR0 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 3 3]
		set_parameter_value AC_ROM_MR0_CALIB [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 3 3]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 8 1 1]
		set_parameter_value AC_ROM_MR0_DLL_RESET [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr1 0
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 0 1 [get_parameter_value MR1_DLL]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 1 1 [get_parameter_value MR1_ODS]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 2 1 [get_parameter_value MR1_RTT]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 3 3 [get_parameter_value MR1_AL]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 6 1 [expr {[get_parameter_value MR1_RTT] >> 1}]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 7 3 0]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 10 1 [get_parameter_value MR1_DQS]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 11 1 [get_parameter_value MR1_RDQS]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 12 1 [get_parameter_value MR1_QOFF]]
		set_parameter_value AC_ROM_MR1 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 7 3 7]
		set_parameter_value AC_ROM_MR1_OCD_ENABLE [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr2 0
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 7 1 [get_parameter_value MR2_SRT]]
		set_parameter_value AC_ROM_MR2 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr2 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr3 0
		set_parameter_value AC_ROM_MR3 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr3 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set ac_rom_mr0 0
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 2 [get_parameter_value MR0_BL]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 3 1 [get_parameter_value MR0_BT]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 4 3 [get_parameter_value MR0_CAS_LATENCY]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 2 1 [expr (([get_parameter_value MR0_CAS_LATENCY] >> 3) & 1)]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 8 1 0]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 9 3 [get_parameter_value MR0_WR]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 12 1 [get_parameter_value MR0_PD]]
		set_parameter_value AC_ROM_MR0 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]
		set_parameter_value AC_ROM_MR0_MIRR [alt_mem_if::gen::uniphy_gen::to_binary_string [_get_ddr3_mirrored_address $ac_rom_mr0] [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 2 0]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 8 1 1]
		set_parameter_value AC_ROM_MR0_DLL_RESET [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]
		set_parameter_value AC_ROM_MR0_DLL_RESET_MIRR [alt_mem_if::gen::uniphy_gen::to_binary_string [_get_ddr3_mirrored_address $ac_rom_mr0] [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr1 0
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 0 1 [get_parameter_value MR1_DLL]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 1 1 [get_parameter_value MR1_ODS]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 2 1 [get_parameter_value MR1_RTT]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 3 2 [get_parameter_value MR1_AL]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 5 1 [expr {[get_parameter_value MR1_ODS] >> 1}]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 6 1 [expr {[get_parameter_value MR1_RTT] >> 1}]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 7 1 [get_parameter_value MR1_WL]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 9 1 [expr {[get_parameter_value MR1_RTT] >> 2}]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 11 1 [get_parameter_value MR1_TDQS]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 12 1 [get_parameter_value MR1_QOFF]]
		set_parameter_value AC_ROM_MR1 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]
		set_parameter_value AC_ROM_MR1_MIRR [alt_mem_if::gen::uniphy_gen::to_binary_string [_get_ddr3_mirrored_address $ac_rom_mr1] [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr2 0
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 3 3 [get_parameter_value MR2_CWL]]
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 6 1 [get_parameter_value MR2_ASR]]
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 7 1 [get_parameter_value MR2_SRT]]
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 9 2 [get_parameter_value MR2_RTT_WR]]
		set_parameter_value AC_ROM_MR2 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr2 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]
		set_parameter_value AC_ROM_MR2_MIRR [alt_mem_if::gen::uniphy_gen::to_binary_string [_get_ddr3_mirrored_address $ac_rom_mr2] [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr3 0
		set ac_rom_mr3 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr3 0 2 [get_parameter_value MR3_MPR_RF]]
		set_parameter_value MR3_MPR_AA [get_parameter_value MR3_MPR]
		set ac_rom_mr3 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr3 2 1 [get_parameter_value MR3_MPR_AA]]
		set_parameter_value AC_ROM_MR3 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr3 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]
		set_parameter_value AC_ROM_MR3_MIRR [alt_mem_if::gen::uniphy_gen::to_binary_string [_get_ddr3_mirrored_address $ac_rom_mr3] [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {

		set ac_rom_mr1 0
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 4 8 1]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 12 3 [get_parameter_value MR1_BL]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 15 1 [get_parameter_value MR1_BT]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 16 1 [get_parameter_value MR1_WC]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 17 3 [get_parameter_value MR1_WR]]
		set_parameter_value AC_ROM_MR1 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1 [expr 2 * [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]]

		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 12 3 3]
		set_parameter_value AC_ROM_MR1_CALIB [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1 [expr 2 * [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]]

		set ac_rom_mr2 0
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 4 8 2]
		set ac_rom_mr2 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr2 12 4 [get_parameter_value MR2_RLWL]]
		set_parameter_value AC_ROM_MR2 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr2 [expr 2 * [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]]

		set ac_rom_mr3 0
		set ac_rom_mr3 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr3 4 8 3]
		set ac_rom_mr3 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr3 12 4 [get_parameter_value MR3_DS]]
		set_parameter_value AC_ROM_MR3 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr3 [expr 2 * [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]]

	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		set ac_rom_mr0 0
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 3 [get_parameter_value MR0_BL]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 3 1 [get_parameter_value MR0_BT]]
		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 4 3 [get_parameter_value MR0_CAS_LATENCY]]
		set_parameter_value AC_ROM_MR0 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr0 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr0 0 3 3]
		set_parameter_value AC_ROM_MR0_CALIB [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr0 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

		set ac_rom_mr1 0
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 0 3 [get_parameter_value MR1_PASR]]
		set ac_rom_mr1 [alt_mem_if::gen::uniphy_gen::set_bits $ac_rom_mr1 5 3 [get_parameter_value MR1_DS]]
		set_parameter_value AC_ROM_MR1 [alt_mem_if::gen::uniphy_gen::to_binary_string $ac_rom_mr1 [get_parameter_value MEM_IF_ADDR_WIDTH_MIN]]

	}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		set_parameter_property MEM_DQ_PER_DQS ALLOWED_RANGES {8}
	} else {
		if {[regexp {^LPDDR2$} $protocol] == 1} {
			set_parameter_property MEM_DQ_PER_DQS ALLOWED_RANGES {8}
		} else {
			set_parameter_property MEM_DQ_PER_DQS ALLOWED_RANGES {4 8}
		}
	}
}


proc ::alt_mem_if::gui::common_ddr_mem_model::_get_ddr3_mirrored_address { addr } {
	foreach i [list 3 5 7] j [list 4 6 8] {
		set temp_bit [expr ($addr >> $i) & 1]
		set addr [alt_mem_if::gen::uniphy_gen::set_bits $addr $i 1 [expr ($addr >> $j) & 1]]
		set addr [alt_mem_if::gen::uniphy_gen::set_bits $addr $j 1 $temp_bit]
	}
	return $addr
}


proc ::alt_mem_if::gui::common_ddr_mem_model::_derive_parameters {} {

	_dprint 1 "Preparing to derive parametres for common_ddr_mem_model"

	variable ddr_mode
	set is_hps [regexp {^HPS$} $ddr_mode]

	set protocol [_get_protocol]

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_value MEM_TYPE "DDR2"
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_value MEM_TYPE "DDR3"
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_value MEM_TYPE "LPDDR2"
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		set_parameter_value MEM_TYPE "LPDDR1"
	}

	set_parameter_value MEM_IF_ROW_ADDR_WIDTH [get_parameter_value MEM_ROW_ADDR_WIDTH]
	set_parameter_value MEM_IF_COL_ADDR_WIDTH [get_parameter_value MEM_COL_ADDR_WIDTH]
	set_parameter_value MEM_IF_BANKADDR_WIDTH [get_parameter_value MEM_BANKADDR_WIDTH]

	if {[regexp {^DDR2$} $protocol] == 1} {
		set_parameter_value MEM_WTCL_INT [expr {[get_parameter_value MEM_TCL] - 1}]
		set_parameter_value MEM_ATCL_INT [get_parameter_value MEM_ATCL]
		
	} elseif {[regexp {^DDR3$} $protocol] == 1} {
		set_parameter_value MEM_WTCL_INT [get_parameter_value MEM_WTCL]
		if {[string compare -nocase [get_parameter_value MEM_ATCL] "Disabled"] == 0} {
			set_parameter_value MEM_ATCL_INT 0
		} else {
			set_parameter_value MEM_ATCL_INT [expr {[get_parameter_value MEM_TCL] - [get_parameter_value MR1_AL]}]
		}
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set rlwl [list 0 0 0 1 2 2 3 4 4]
		set_parameter_value MEM_WTCL_INT [lindex $rlwl [get_parameter_value MEM_TCL]]
		set_parameter_value MEM_ATCL_INT 0
	} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
		set_parameter_value MEM_WTCL_INT 1
		set_parameter_value MEM_ATCL_INT 0
	}
	
	set mem_clk_mhz [get_parameter_value MEM_CLK_FREQ]
	set mem_clk_ns [expr {round(1000000.0 / $mem_clk_mhz) / 1000.0}]	

	
	set_parameter_value USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY "false"
	if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			if {([string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0)} {		
				if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
					if {$mem_clk_ns < 33.334} {
						set_parameter_value USE_NEG_EDGE_AC_TRANSFER_FOR_HPHY "true"
					}
				}
			}
		}
	}
	
	if {[regexp {^DDR2$|^DDR3$|^LPDDR1$} $protocol] == 1} {
		if {[get_parameter_value MEM_COL_ADDR_WIDTH] > [get_parameter_value MEM_ROW_ADDR_WIDTH] } {
			set_parameter_value MEM_IF_ADDR_WIDTH [get_parameter_value MEM_COL_ADDR_WIDTH ]
		} else {
			set_parameter_value MEM_IF_ADDR_WIDTH [get_parameter_value MEM_ROW_ADDR_WIDTH ]
		}
		if {[regexp {^DDR2$|^LPDDR1$} $protocol] == 1} {
			if { [ get_parameter_value MEM_IF_ADDR_WIDTH ] < 11 } {
				set_parameter_value MEM_IF_ADDR_WIDTH 11
			}
		} elseif {[regexp {^DDR3$} $protocol] == 1} {
			if { [ get_parameter_value MEM_IF_ADDR_WIDTH ] < 13 } {
				set_parameter_value MEM_IF_ADDR_WIDTH 13
			}
		}
		set_parameter_value MEM_IF_ADDR_WIDTH_MIN 13
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_value MEM_IF_ADDR_WIDTH 10
		set_parameter_value MEM_IF_ADDR_WIDTH_MIN 10
	}
	if { [ get_parameter_value MEM_IF_ADDR_WIDTH ] < [ get_parameter_value MEM_IF_ADDR_WIDTH_MIN ] } {
		set_parameter_value MEM_IF_ADDR_WIDTH [ get_parameter_value MEM_IF_ADDR_WIDTH_MIN ]
	}

	if { [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 &&
		 [string compare -nocase [get_module_property NAME] "alt_mem_if_ddr3_tg_ed"] != 0} {
		set_parameter_value MEM_IF_DQ_WIDTH [ expr {2*[get_parameter_value MEM_DQ_WIDTH]} ]
		set_parameter_value MEM_IF_DQS_WIDTH [ expr {2*[get_parameter_value MEM_DQ_WIDTH] / [get_parameter_value MEM_DQ_PER_DQS]} ]
	} else {
		set_parameter_value MEM_IF_DQ_WIDTH [get_parameter_value MEM_DQ_WIDTH]
		set_parameter_value MEM_IF_DQS_WIDTH [ expr {[get_parameter_value MEM_DQ_WIDTH] / [get_parameter_value MEM_DQ_PER_DQS]} ]
	}

	set_parameter_value MEM_IF_READ_DQS_WIDTH [get_parameter_value MEM_IF_DQS_WIDTH]
	set_parameter_value MEM_IF_WRITE_DQS_WIDTH [get_parameter_value MEM_IF_DQS_WIDTH]

	set_parameter_value MEM_IF_DM_WIDTH [get_parameter_value MEM_IF_DQS_WIDTH]
	
	if {[string compare -nocase [get_parameter_value TRK_PARALLEL_SCC_LOAD] "true"] == 0} {
	    set_parameter_value SCC_DATA_WIDTH [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	} else {
	    set_parameter_value SCC_DATA_WIDTH 1
	}

	if {[string compare -nocase [ get_parameter_value MEM_FORMAT ] "DISCRETE" ] == 0 } {
		set_parameter_value MEM_IF_NUMBER_OF_RANKS [expr {[get_parameter_value DEVICE_DEPTH] * [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DEVICE]}]
		set_parameter_value MEM_IF_CS_WIDTH [get_parameter_value MEM_IF_NUMBER_OF_RANKS]

		set_parameter_value MEM_IF_CS_PER_RANK 1
		set_parameter_value MEM_IF_CS_PER_DIMM [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM]
		set_parameter_value MEM_IF_CLK_EN_WIDTH [ get_parameter_value MEM_IF_CS_WIDTH ]
		set_parameter_value MEM_IF_ODT_WIDTH [ get_parameter_value MEM_IF_CS_WIDTH ]


	} elseif {([string compare -nocase [ get_parameter_value MEM_FORMAT ] "REGISTERED" ] == 0 || [string compare -nocase [ get_parameter_value MEM_FORMAT ] "LOADREDUCED" ] == 0)} {
		if {([get_parameter_value MEM_CS_WIDTH] < 2)} {
			_eprint "The parameter MEM_CS_WIDTH ([get_parameter_property MEM_CS_WIDTH DISPLAY_NAME]) must be set to 2 or greater for RDIMM/LRDIMM devices"
		}

		if {([string compare -nocase [ get_parameter_value MEM_FORMAT ] "REGISTERED" ] == 0)} {
			set_parameter_property MEM_CS_WIDTH ALLOWED_RANGES {1 2 4}
		} elseif {([string compare -nocase [ get_parameter_value MEM_FORMAT ] "LOADREDUCED" ] == 0)} {
			set_parameter_property MEM_CS_WIDTH ALLOWED_RANGES {1 2 3 4}
		}

		set_parameter_value MEM_IF_NUMBER_OF_RANKS [expr {[get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM]}]

		set_parameter_value MEM_IF_CS_PER_DIMM [get_parameter_value MEM_CS_WIDTH]
		set_parameter_value MEM_IF_CLK_EN_WIDTH [expr {[get_parameter_value MEM_CLK_EN_WIDTH] * [get_parameter_value MEM_NUMBER_OF_DIMMS]}]
		set_parameter_value MEM_IF_ODT_WIDTH [get_parameter_value MEM_IF_CLK_EN_WIDTH]
                

		set physical_cs_encoding [list \
			altera_mem_if_ddr2_emif \
			altera_mem_if_ddr3_emif \
			altera_mem_if_ddr2_pll \
			altera_mem_if_ddr3_pll \
			altera_mem_if_ddr2_phy_core \
			altera_mem_if_ddr3_phy_core \
			altera_mem_if_ddr2_afi_mux \
			altera_mem_if_ddr3_afi_mux \
			altera_mem_if_ddr2_afi_splitter \
			altera_mem_if_ddr3_afi_splitter \
			altera_mem_if_ddr2_qseq \
			altera_mem_if_ddr3_qseq \
			altera_mem_if_ddr2_mem_model \
			altera_mem_if_ddr3_mem_model \
			alt_mem_if_ddr2_tg_ed \
			alt_mem_if_ddr3_tg_ed \
			alt_mem_if_ddr2_tg_eds \
			alt_mem_if_ddr3_tg_eds \
			altera_ddr2_board_delay_model \
			altera_ddr3_board_delay_model \
			altera_mem_if_pp_mem_model_bridge ]

		set logical_cs_encoding [list \
			altera_mem_if_nextgen_ddr2_controller \
			altera_mem_if_nextgen_ddr2_controller_core \
			altera_mem_if_nextgen_ddr3_controller \
			altera_mem_if_nextgen_ddr3_controller_core \
			altera_mem_if_ddr2_controller \
			altera_mem_if_ddr3_controller \
			altera_mem_if_ddr2_afi_gasket \
			altera_mem_if_ddr3_afi_gasket \
			alt_mem_if_pp_gasket ]

		if {[lsearch -exact $physical_cs_encoding [get_module_property NAME]] != -1} {
			_dprint 1 "Module [get_module_property NAME] -> Physical Chip-Select Encoding"
			set_parameter_value MEM_IF_CS_WIDTH [expr {[get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value MEM_CS_WIDTH]}]

			if {[regexp {^DDR3$} $protocol] == 1} {
				if {([string compare -nocase [ get_parameter_value MEM_FORMAT ] "LOADREDUCED" ] == 0)} {
					if {[get_parameter_value MEM_ROW_ADDR_WIDTH] > 16} {
						_dprint 1 "Overriding physical memory row address width from [get_parameter_value MEM_ROW_ADDR_WIDTH] to 16"
						set_parameter_value MEM_IF_ADDR_WIDTH 16
					}
				}
			}
		} elseif {[lsearch -exact $logical_cs_encoding [get_module_property NAME]] != -1} {
			_dprint 1 "Module [get_module_property NAME] -> Logical Chip-Select Encoding"
			set_parameter_value MEM_IF_CS_WIDTH [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
		} else {
			_error "Could not map module [get_module_property NAME] to either physical or logical mapping list"
		}
	} else {
		set_parameter_value MEM_IF_NUMBER_OF_RANKS [expr {[get_parameter_value MEM_NUMBER_OF_DIMMS] * [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM]}]
		set_parameter_value MEM_IF_CS_WIDTH [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
		set_parameter_value MEM_IF_CS_PER_DIMM [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM]
		set_parameter_value MEM_IF_CLK_EN_WIDTH [ get_parameter_value MEM_IF_CS_WIDTH ]

		set_parameter_value MEM_IF_ODT_WIDTH [ get_parameter_value MEM_IF_CS_WIDTH ]
	}

	if {[get_parameter_value MEM_IF_CS_WIDTH] > 1} {
		set_parameter_value MEM_IF_CHIP_BITS [expr {log([get_parameter_value MEM_IF_CS_WIDTH])/log(2)}]
	} else {
		set_parameter_value MEM_IF_CHIP_BITS 1
	}
        
	set_parameter_value MEM_IF_CS_PER_RANK 1

	if {[string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0 && 
		[string compare -nocase [get_module_property NAME] "altera_mem_if_ddr3_qseq"] != 0 &&
		[string compare -nocase [get_module_property NAME] "altera_mem_if_ddr3_seq_mux_bridge"] != 0 && 
		[string compare -nocase [get_module_property NAME] "alt_mem_if_ddr3_tg_ed"] != 0} {
		set_parameter_value MEM_IF_CS_WIDTH [expr {2*[get_parameter_value MEM_IF_CS_WIDTH]}]
		set_parameter_value MEM_IF_CLK_EN_WIDTH [expr {2*[get_parameter_value MEM_IF_CLK_EN_WIDTH]}]
		set_parameter_value MEM_IF_ODT_WIDTH [expr {2*[get_parameter_value MEM_IF_ODT_WIDTH]}]
		_dprint 1 "Doubling MEM_IF_CS_WIDTH to [get_parameter_value MEM_IF_CS_WIDTH], MEM_IF_ODT_WIDTH to [get_parameter_value MEM_IF_ODT_WIDTH] and MEM_IF_CLK_EN_WIDTH to [get_parameter_value MEM_IF_CLK_EN_WIDTH] for Ping-Pong PHY (module [get_module_property NAME]"
	} else {
		set_parameter_value MEM_IF_CS_WIDTH [get_parameter_value MEM_IF_CS_WIDTH]
	}

	_dprint 1 "Set MEM_IF_CS_WIDTH to [get_parameter_value MEM_IF_CS_WIDTH] for module [get_module_property NAME]" 


    set mem_trc_ns [expr {[get_parameter_value MEM_TRAS_NS] + [get_parameter_value MEM_TRP_NS]}]
    set mem_trc_ck [_ns_to_tck $mem_trc_ns $mem_clk_ns]
    set_parameter_value MEM_TRC [_within $mem_trc_ck 8 46]

    set mem_tras_ck_min 4
    set mem_tras_ck_max 32
    set mem_tras_ns_min [_tck_to_ns $mem_tras_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tras_ns_max [_tck_to_ns $mem_tras_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tras_ck [_ns_to_tck [get_parameter_value MEM_TRAS_NS] $mem_clk_ns]
    set_parameter_value MEM_TRAS [_within $mem_tras_ck $mem_tras_ck_min $mem_tras_ck_max]

	set mem_trcd_ck_min 2
	set mem_trcd_ck_max 13
	set mem_trcd_ns_min [_tck_to_ns $mem_trcd_ck_min $mem_clk_mhz 2]
	set mem_trcd_ns_max [_tck_to_ns $mem_trcd_ck_max $mem_clk_mhz 2]
	set mem_trcd_ck [_ns_to_tck [get_parameter_value MEM_TRCD_NS] $mem_clk_ns]
	set_parameter_value MEM_TRCD [_within $mem_trcd_ck $mem_trcd_ck_min $mem_trcd_ck_max]
  
    set mem_trp_ck_min 2
    set mem_trp_ck_max 13
    set mem_trp_ns_min [_tck_to_ns $mem_trp_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trp_ns_max [_tck_to_ns $mem_trp_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trp_ck [_ns_to_tck [get_parameter_value MEM_TRP_NS] $mem_clk_ns]
    set_parameter_value MEM_TRP [_within $mem_trp_ck $mem_trp_ck_min $mem_trp_ck_max]

    set mem_trefi_ck_min 780
    set mem_trefi_ck_max 7281
    set mem_trefi_us_min [expr {[_tck_to_ns $mem_trefi_ck_min [get_parameter_value MEM_CLK_FREQ] 5] / 1000.0}]
    set mem_trefi_us_max [expr {[_tck_to_ns $mem_trefi_ck_max [get_parameter_value MEM_CLK_FREQ] 5] / 1000.0}]
    set mem_trefi_ck [_ns_to_tck [expr {[get_parameter_value MEM_TREFI_US] * 1000.0}] $mem_clk_ns]
    set_parameter_value MEM_TREFI [_within $mem_trefi_ck $mem_trefi_ck_min $mem_trefi_ck_max]

    set mem_trfc_ck_min 12
    set mem_trfc_ck_max 255
    set mem_trfc_ns_min [_tck_to_ns $mem_trfc_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trfc_ns_max [_tck_to_ns $mem_trfc_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trfc_ck [_ns_to_tck [get_parameter_value MEM_TRFC_NS] $mem_clk_ns]
    set_parameter_value MEM_TRFC [_within $mem_trfc_ck $mem_trfc_ck_min $mem_trfc_ck_max]

    set cfg_tccd_ck_min 1
    set cfg_tccd_ck_max 3
    set cfg_tccd_ns_min [_tck_to_ns $cfg_tccd_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set cfg_tccd_ns_max [_tck_to_ns $cfg_tccd_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set cfg_tccd_ck [_ns_to_tck [get_parameter_value CFG_TCCD_NS] $mem_clk_ns]
    if {[regexp {^LPDDR2$} $ddr_mode] == 1} {
        set_parameter_value CFG_TCCD 2
    } else {
        set_parameter_value CFG_TCCD [_within $cfg_tccd_ck $cfg_tccd_ck_min $cfg_tccd_ck_max]
    }

    set mem_twr_ck_min 2
    set mem_twr_ck_max 16
    set mem_twr_ns_min [_tck_to_ns $mem_twr_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_twr_ns_max [_tck_to_ns $mem_twr_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_twr_ck [_ns_to_tck [get_parameter_value MEM_TWR_NS] $mem_clk_ns]
    set_parameter_value MEM_TWR [_within $mem_twr_ck $mem_twr_ck_min $mem_twr_ck_max]

    set mem_tfaw_ck_min 5
    set mem_tfaw_ck_max 33
    set mem_tfaw_ns_min [_tck_to_ns $mem_tfaw_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tfaw_ns_max [_tck_to_ns $mem_tfaw_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_tfaw_ck [_ns_to_tck [get_parameter_value MEM_TFAW_NS] $mem_clk_ns]
    set_parameter_value MEM_TFAW [_within $mem_tfaw_ck $mem_tfaw_ck_min $mem_tfaw_ck_max]

    set mem_trrd_ck_min 2
    set mem_trrd_ck_max 8
    set mem_trrd_ns_min [_tck_to_ns $mem_trrd_ck_min [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trrd_ns_max [_tck_to_ns $mem_trrd_ck_max [get_parameter_value MEM_CLK_FREQ] 2]
    set mem_trrd_ck [_ns_to_tck [get_parameter_value MEM_TRRD_NS] $mem_clk_ns]
    set_parameter_value MEM_TRRD [_within $mem_trrd_ck $mem_trrd_ck_min $mem_trrd_ck_max]

	set mem_trtp_ck_min 2
	set mem_trtp_ck_max 8
	set mem_trtp_ns_min [_tck_to_ns $mem_trtp_ck_min $mem_clk_mhz 2]
	set mem_trtp_ns_max [_tck_to_ns $mem_trtp_ck_max $mem_clk_mhz 2]
	set mem_trtp_ck [_ns_to_tck [get_parameter_value MEM_TRTP_NS] $mem_clk_ns]
	set_parameter_value MEM_TRTP [_within $mem_trtp_ck $mem_trtp_ck_min $mem_trtp_ck_max]


	set_parameter_value MEM_IF_CONTROL_WIDTH 1

	set_parameter_value MEM_IF_CK_WIDTH [ get_parameter_value MEM_CK_WIDTH ]
	set_parameter_value MEM_IF_CLK_PAIR_COUNT [ get_parameter_value MEM_CK_WIDTH ]

	if { ! [_family_supports_non_leveling] } {
		set_parameter_value MEM_LEVELING true
	} elseif { ! [_family_supports_leveling] } {
		set_parameter_value MEM_LEVELING false
	} elseif {[string compare -nocase [get_parameter_value MEM_AUTO_LEVELING_MODE] "true"] == 0} {
		if {[expr {! [catch {expr {int([get_parameter_value MEM_CLK_FREQ])}}]}]==1} {
			if {[get_parameter_value MEM_CLK_FREQ] <= 240 } {
				set_parameter_value MEM_LEVELING false
				_iprint "Auto interface leveling mode set to 'Non-Leveling'"
			} else {
				set_parameter_value MEM_LEVELING true
				_iprint "Auto interface leveling mode set to 'Leveling'"
			}
		}
		set_parameter_property MEM_USER_LEVELING_MODE ENABLED false
	} else {
		if {[string compare -nocase [get_parameter_value MEM_USER_LEVELING_MODE] "Leveling"] == 0} {
			set_parameter_value MEM_LEVELING true
		} elseif {[string compare -nocase [get_parameter_value MEM_USER_LEVELING_MODE] "Non-Leveling"] == 0} {
			set_parameter_value MEM_LEVELING false
		}
		set_parameter_property MEM_USER_LEVELING_MODE ENABLED true
	}

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
		set_parameter_value RDIMM true
		set_parameter_value RDIMM_INT 1
	} else {
		set_parameter_value RDIMM false
		set_parameter_value RDIMM_INT 0
	}

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
		set_parameter_value LRDIMM true
		set_parameter_value LRDIMM_INT 1
	} else {
		set_parameter_value LRDIMM false
		set_parameter_value LRDIMM_INT 0
	}

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0} {
		set_parameter_value MEM_REGDIMM_ENABLED true
	} else {
		set_parameter_value MEM_REGDIMM_ENABLED false
	}

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
		set_parameter_value MEM_LRDIMM_ENABLED true
	} else {
		set_parameter_value MEM_LRDIMM_ENABLED false
	}

	set clock_period_ns [expr {1000.0 / [ get_parameter_value MEM_CLK_FREQ]}]
	set_parameter_value MEM_TINIT_CK [expr {int(ceil([expr [get_parameter_value MEM_TINIT_US] * 1000.0 / $clock_period_ns]))}]

	set_parameter_value MEM_CLK_MAX_PS [expr {round(1000000 / [get_parameter_value MEM_CLK_FREQ_MAX])}]
	set_parameter_value MEM_CLK_MAX_NS [expr {[get_parameter_value MEM_CLK_MAX_PS] / 1000.0}]

	
	set_parameter_value MEM_TDQSCK [expr {int(ceil([expr [get_parameter_value TIMING_TDQSCK] / ($clock_period_ns * 1000) ]))}]

    if {[regexp {^DDR2$} $protocol] == 1} {
        set_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT 3
	} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
		set_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT [expr {2 + [ get_parameter_value MEM_TDQSCK ]}]
    } elseif {([regexp {^DDR3$} $protocol] == 1) && ([string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
		if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
			set_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT 5
		} else {
			set_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT 3
		}
	} else {
		set_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT 2
    }

    if {[regexp {^LPDDR1$} $protocol] == 1} {
        if       {[string compare -nocase [get_parameter_value RATE] "FULL"]    == 0 && [string compare -nocase [get_parameter_value MEM_BL] "2"] == 0} {
            set_parameter_value CTL_RD_TO_PCH_EXTRA_CLK 1
        } elseif {[string compare -nocase [get_parameter_value RATE] "HALF"]    == 0 && [string compare -nocase [get_parameter_value MEM_BL] "4"] == 0} {
            set_parameter_value CTL_RD_TO_PCH_EXTRA_CLK 1
        } elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0 && [string compare -nocase [get_parameter_value MEM_BL] "8"] == 0} {
            set_parameter_value CTL_RD_TO_PCH_EXTRA_CLK 1
        } else {
            set_parameter_value CTL_RD_TO_PCH_EXTRA_CLK 0
        }
    } else {
        set_parameter_value CTL_RD_TO_PCH_EXTRA_CLK 0
    }
    
    if       {[string compare -nocase [get_parameter_value RATE] "FULL"]    == 0} {
        set_parameter_value CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK 1
        set_parameter_value CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK 2
    } elseif {[string compare -nocase [get_parameter_value RATE] "HALF"]    == 0} {
        set_parameter_value CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK 1
        set_parameter_value CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK 1
    } elseif {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
        if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
            set_parameter_value CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK 2
            set_parameter_value CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK 2
        } else {
            set_parameter_value CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK 0
            set_parameter_value CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK 0
        }
    } else {
        set_parameter_value CTL_RD_TO_RD_DIFF_CHIP_EXTRA_CLK 0
        set_parameter_value CTL_WR_TO_WR_DIFF_CHIP_EXTRA_CLK 0
    }
    
	if {[get_parameter_value MEM_IF_SIM_VALID_WINDOW] == 0} {
		if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
			set_parameter_value MEM_DQS_TO_CLK_CAPTURE_DELAY 100
		} else {
			set_parameter_value MEM_DQS_TO_CLK_CAPTURE_DELAY 450
		}
		set_parameter_value MEM_CLK_TO_DQS_CAPTURE_DELAY 100000
	} else {
		set_parameter_value MEM_DQS_TO_CLK_CAPTURE_DELAY [expr {int([get_parameter_value MEM_IF_SIM_VALID_WINDOW] / 2)}]
		set_parameter_value MEM_CLK_TO_DQS_CAPTURE_DELAY [expr {int([get_parameter_value MEM_IF_SIM_VALID_WINDOW] / 2)}]
		_iprint "Setting memory window to [get_parameter_value MEM_IF_SIM_VALID_WINDOW]"
	}

	if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
		if {[get_parameter_value MEM_RANK_MULTIPLICATION_FACTOR] != 1} {
			_dprint 1 "Inserting delay cycle for Read-to-Read and Write-to-Write LRDIMM commands"
			set_parameter_value CTL_RD_TO_RD_EXTRA_CLK 1
			set_parameter_value CTL_WR_TO_WR_EXTRA_CLK 1
			_dprint 1 "CTL_RD_TO_RD_EXTRA_CLK => [get_parameter_value CTL_RD_TO_RD_EXTRA_CLK]"
			_dprint 1 "CTL_WR_TO_WR_EXTRA_CLK => [get_parameter_value CTL_WR_TO_WR_EXTRA_CLK]"
		}
	}


	if {[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {

    	if {[regexp {^DDR3$} $protocol] == 1 && $is_hps == 0} {
			set_parameter_property MEM_BL VISIBLE false
		} else {
			set_parameter_property MEM_BL VISIBLE TRUE
		}

		if {[string compare -nocase [get_parameter_value MEM_BL] "2"] == 0 ||
		    [string compare -nocase [get_parameter_value MEM_BL] "4"] == 0 ||
		    [string compare -nocase [get_parameter_value MEM_BL] "8"] == 0 ||
		    [string compare -nocase [get_parameter_value MEM_BL] "16"] == 0} {
			set_parameter_value MEM_BURST_LENGTH [get_parameter_value MEM_BL]
		} else {
			set_parameter_value MEM_BURST_LENGTH 8
		}

	} else {
		set_parameter_property MEM_BL VISIBLE FALSE
	}

	if {[string compare -nocase [get_parameter_value MEM_INIT_EN] "true"] == 0} {
                set_parameter_property MEM_INIT_FILE ENABLED TRUE
                set_parameter_property DAT_DATA_WIDTH ENABLED TRUE
        } else {
                set_parameter_property MEM_INIT_FILE ENABLED FALSE
                set_parameter_property DAT_DATA_WIDTH ENABLED FALSE
        }

	return 1
}


::alt_mem_if::gui::common_ddr_mem_model::_init
