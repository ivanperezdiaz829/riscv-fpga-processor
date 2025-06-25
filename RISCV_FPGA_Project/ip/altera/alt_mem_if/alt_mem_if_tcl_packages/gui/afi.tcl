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


package provide alt_mem_if::gui::afi 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils

namespace eval ::alt_mem_if::gui::afi:: {
	variable VALID_PROTOCOLS
	variable protocol
	
	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::afi::_validate_protocol {} {
	variable protocol
	
	if {$protocol == -1} {
		error "Protocol is uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::afi::set_protocol {in_protocol} {
	variable VALID_PROTOCOLS
	
	if {[info exists VALID_PROTOCOLS($in_protocol)] == 0} {
		_eprint "Fatal Error: Illegal protocol $in_protocol"
		_eprint "Fatal Error: Valid protocols are [array names VALID_PROTOCOLS]"
		_error "An error occurred"
	} else {
		_dprint 1 "Setting protocol as $in_protocol"
		variable protocol
		set protocol $in_protocol
	}

	return 1
}

proc ::alt_mem_if::gui::afi::create_parameters {} {
	
	_validate_protocol
	
	_dprint 1 "Preparing to create parameters for afi"
	
	_create_afi_parameters
	
	return 1
}


proc ::alt_mem_if::gui::afi::create_gui {} {

	_validate_protocol
	
	return 1
}



proc ::alt_mem_if::gui::afi::validate_component {} {

	_derive_parameters
	
	set validation_pass 1

	variable protocol

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "MAX10FPGA"] == 0} {
	    set_parameter_property RATE ALLOWED_RANGES {Half}
	} elseif {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "LPDDR2"] == 0} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		    if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				set_parameter_property RATE ALLOWED_RANGES {Full}
			} else {
				set_parameter_property RATE ALLOWED_RANGES {Half}
			}
		} else {
			set_parameter_property RATE ALLOWED_RANGES {Half Full}
		}
	} elseif {[string compare -nocase $protocol "DDR3"] == 0} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 &&
		[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {
			if {[::alt_mem_if::util::qini::cfg_is_on uniphy_allow_full_rate_ddr3]} {
				set_parameter_property RATE ALLOWED_RANGES {Full Half Quarter}
			} else {
				set_parameter_property RATE ALLOWED_RANGES {Half Quarter}
			}
		} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0 &&
			  [string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {
			if {[::alt_mem_if::util::qini::cfg_is_on uniphy_allow_full_rate_ddr3]} {
				set_parameter_property RATE ALLOWED_RANGES {Full Half Quarter}
			} else {
				set_parameter_property RATE ALLOWED_RANGES {Half Quarter}
			}
		} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0} {
			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				set_parameter_property RATE ALLOWED_RANGES {Full}
			} else {
				if {[::alt_mem_if::util::qini::cfg_is_on uniphy_allow_full_rate_ddr3]} {
					set_parameter_property RATE ALLOWED_RANGES {Full Half Quarter}
				} else {
					set_parameter_property RATE ALLOWED_RANGES {Half Quarter}
				}
			}
		} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				set_parameter_property RATE ALLOWED_RANGES {Full}
			} else {
				if {[::alt_mem_if::util::qini::cfg_is_on uniphy_allow_full_rate_ddr3]} {
					set_parameter_property RATE ALLOWED_RANGES {Full Half}
				} else {
					set_parameter_property RATE ALLOWED_RANGES {Half}
				}
			}
		} else {
			set_parameter_property RATE ALLOWED_RANGES {Half}
		}
	} elseif {[string compare -nocase $protocol "HPS"] == 0} {
		set_parameter_property RATE ALLOWED_RANGES {Full}
	} elseif {[string compare -nocase $protocol "QDRII"] == 0} {
		if { [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 || 
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set_parameter_property RATE ALLOWED_RANGES {Half}
		} else {
			set_parameter_property RATE ALLOWED_RANGES {Half Full}
		}
	} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0} {
		if { [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 || 
			[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
			set_parameter_property RATE ALLOWED_RANGES {Half}
		} else {
			set_parameter_property RATE ALLOWED_RANGES {Half Full}
		}
	} elseif {[string compare -nocase $protocol "RLDRAM3"] == 0} {
		set_parameter_property RATE ALLOWED_RANGES {Half Quarter}
	} elseif {[string compare -nocase $protocol "DDRIISRAM"] == 0} {
		set_parameter_property RATE ALLOWED_RANGES {Half Full}
	}

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui] &&
	    ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 || 
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)} {
		set_parameter_property FORCE_DQS_TRACKING visible true
	} else {
		set_parameter_property FORCE_DQS_TRACKING visible false
	}

	if {[string compare -nocase [get_parameter_value FORCE_DQS_TRACKING] "Enabled"] == 0 &&
	    ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] != 0 &&
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] != 0 &&
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] != 0 &&
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] != 0)} {
		_eprint "The option '[get_parameter_property FORCE_DQS_TRACKING DISPLAY_NAME]' is only applicable to Stratix V, Arria V GZ, Arria V, and Cyclone V devices."
		set validation_pass 0
	}

	if {[string compare -nocase $protocol "DDR3"] == 0 &&
		[string compare -nocase [get_parameter_value RATE] "full"] != 0 &&
		[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0 && 	
		([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)} {
		set_parameter_property FORCE_SHADOW_REGS visible true
		if {[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > 1} {
			set_parameter_property FORCE_SHADOW_REGS enabled true
		} else {
			set_parameter_property FORCE_SHADOW_REGS enabled false
		}
	} else {
		set_parameter_property FORCE_SHADOW_REGS visible false
	}

	if {[string compare -nocase [get_parameter_value FORCE_SHADOW_REGS] "Enabled"] == 0 &&
		([string compare -nocase $protocol "DDR3"] != 0 ||
		[get_parameter_value MEM_IF_NUMBER_OF_RANKS] < 1 ||
		[string compare -nocase [get_parameter_value RATE] "full"] == 0 ||
		[string compare -nocase [get_parameter_value NEXTGEN] "true"] != 0 ||
	    ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] != 0 &&
	     [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] != 0))} {
		_eprint "The option '[get_parameter_property FORCE_SHADOW_REGS DISPLAY_NAME]' is only applicable to Stratix V devices or Arria V GZ devices and for DDR3 multi-rank interfaces running at half or quarter-rate."
		set validation_pass 0
	}
	
	
	return $validation_pass

}

proc ::alt_mem_if::gui::afi::elaborate_component {} {


	return 1
}


proc ::alt_mem_if::gui::afi::_init {} {
	variable VALID_PROTOCOLS
	
	::alt_mem_if::util::list_array::array_clean VALID_PROTOCOLS
	set VALID_PROTOCOLS(QDRII) 1
	set VALID_PROTOCOLS(RLDRAMII) 1
	set VALID_PROTOCOLS(RLDRAM3) 1
	set VALID_PROTOCOLS(DDR2) 1
	set VALID_PROTOCOLS(DDR3) 1
	set VALID_PROTOCOLS(LPDDR2) 1
	set VALID_PROTOCOLS(LPDDR1) 1
	set VALID_PROTOCOLS(DDRIISRAM) 1
	set VALID_PROTOCOLS(HPS) 1
}


proc ::alt_mem_if::gui::afi::_create_afi_parameters {} {
	variable protocol

	_dprint 1 "Preparing to create AFI parameters in afi"

	if {[string compare $protocol "HPS"] == 0} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter RATE STRING "Full" 
	} else {
		::alt_mem_if::util::hwtcl_utils::_add_parameter RATE STRING "Half" 
	}
	set_parameter_property RATE DISPLAY_NAME "Rate on Avalon-MM interface"
	set_parameter_property RATE UNITS None
	set_parameter_property RATE AFFECTS_ELABORATION true
	set_parameter_property RATE DESCRIPTION "This setting defines the width of data bus on the Avalon-MM interface.  
	A setting of Full results in a width of 2x the memory data width. A setting of Half results in a width of 4x the memory data width. A setting of Quarter results in a width of 8x the memory data width."
	set_parameter_property RATE ALLOWED_RANGES {Half Full Quarter}

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_FREQ float 300
	set_parameter_property MEM_CLK_FREQ DISPLAY_NAME "Memory clock frequency"
	set_parameter_property MEM_CLK_FREQ UNITS Megahertz
	set_parameter_property MEM_CLK_FREQ DESCRIPTION "The desired frequency of the clock that drives the memory device.  Up to 4 decimal places of precision can be used."
	set_parameter_property MEM_CLK_FREQ DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_MEM_CLK_FREQ boolean false
	set_parameter_property USE_MEM_CLK_FREQ DISPLAY_NAME "Use specified frequency instead of calculated frequency"
	set_parameter_property USE_MEM_CLK_FREQ DESCRIPTION "Select this option if the configuration settings for the PLL are not to be based on the settings calculated by this program, but will instead be chosen directly by the user.  In this case, the user-supplied memory clock frequency will be used directly."
	set_parameter_property USE_MEM_CLK_FREQ VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_DQS_TRACKING boolean false
	set_parameter_property USE_DQS_TRACKING DERIVED true
	set_parameter_property USE_DQS_TRACKING VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter FORCE_DQS_TRACKING string "AUTO"
	set_parameter_property FORCE_DQS_TRACKING VISIBLE false
	set_parameter_property FORCE_DQS_TRACKING DISPLAY_NAME "Force DQS Tracking Enabled/Disabled"
	set_parameter_property FORCE_DQS_TRACKING DESCRIPTION "Enabling DQS tracking enhances timing margin by continuously compensating for temperature variation.  This parameter can be used to override the automatic selection of DQS Tracking.  The default is \"Auto\", indicating that automatic selection is being used."
	set_parameter_property FORCE_DQS_TRACKING ALLOWED_RANGES {"AUTO:Auto" "ENABLED:Enabled" "DISABLED:Disabled"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_HPS_DQS_TRACKING boolean false
	set_parameter_property USE_HPS_DQS_TRACKING DERIVED true
	set_parameter_property USE_HPS_DQS_TRACKING VISIBLE FALSE
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter TRK_PARALLEL_SCC_LOAD boolean false
	set_parameter_property TRK_PARALLEL_SCC_LOAD DERIVED true
	set_parameter_property TRK_PARALLEL_SCC_LOAD VISIBLE FALSE

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_SHADOW_REGS boolean false
	set_parameter_property USE_SHADOW_REGS DERIVED true
	set_parameter_property USE_SHADOW_REGS VISIBLE FALSE
	set_parameter_property USE_SHADOW_REGS AFFECTS_ELABORATION true
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter FORCE_SHADOW_REGS string "AUTO"
	set_parameter_property FORCE_SHADOW_REGS VISIBLE false
	set_parameter_property FORCE_SHADOW_REGS DISPLAY_NAME "Shadow Registers"
	set_parameter_property FORCE_SHADOW_REGS DESCRIPTION "Enabling shadow registers enhances timing margin of multi-rank interfaces by allowing different ranks to be calibrated separately.  The default is \"Auto\", indicating that automatic selection is being used."
	set_parameter_property FORCE_SHADOW_REGS ALLOWED_RANGES {"AUTO:Auto" "DISABLED:Disabled"}
	set_parameter_property FORCE_SHADOW_REGS AFFECTS_ELABORATION true
	
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter DQ_DDR INTEGER 0
	set_parameter_property DQ_DDR DERIVED true
	set_parameter_property DQ_DDR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ADDR_CMD_DDR INTEGER 0
	set_parameter_property ADDR_CMD_DDR DERIVED true
	set_parameter_property ADDR_CMD_DDR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_RATE_RATIO integer 0
	set_parameter_property AFI_RATE_RATIO DERIVED TRUE
	set_parameter_property AFI_RATE_RATIO VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter DATA_RATE_RATIO integer 0
	set_parameter_property DATA_RATE_RATIO DERIVED TRUE
	set_parameter_property DATA_RATE_RATIO VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter ADDR_RATE_RATIO integer 0
	set_parameter_property ADDR_RATE_RATIO DERIVED TRUE
	set_parameter_property ADDR_RATE_RATIO VISIBLE false
	

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_ADDR_WIDTH INTEGER 0
	set_parameter_property AFI_ADDR_WIDTH DERIVED true
	set_parameter_property AFI_ADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_BANKADDR_WIDTH INTEGER 0
	set_parameter_property AFI_BANKADDR_WIDTH DERIVED true
	set_parameter_property AFI_BANKADDR_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CONTROL_WIDTH INTEGER 0
	set_parameter_property AFI_CONTROL_WIDTH DERIVED true
	set_parameter_property AFI_CONTROL_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CS_WIDTH INTEGER 0
	set_parameter_property AFI_CS_WIDTH DERIVED true
	set_parameter_property AFI_CS_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CLK_EN_WIDTH INTEGER 0
	set_parameter_property AFI_CLK_EN_WIDTH DERIVED true
	set_parameter_property AFI_CLK_EN_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_DM_WIDTH INTEGER 0
	set_parameter_property AFI_DM_WIDTH DERIVED true
	set_parameter_property AFI_DM_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_DQ_WIDTH INTEGER 0
	set_parameter_property AFI_DQ_WIDTH DERIVED true
	set_parameter_property AFI_DQ_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_ODT_WIDTH INTEGER 0
	set_parameter_property AFI_ODT_WIDTH DERIVED true
	set_parameter_property AFI_ODT_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_WRITE_DQS_WIDTH INTEGER 0
	set_parameter_property AFI_WRITE_DQS_WIDTH DERIVED true
	set_parameter_property AFI_WRITE_DQS_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_RLAT_WIDTH INTEGER 0
	set_parameter_property AFI_RLAT_WIDTH DERIVED true
	set_parameter_property AFI_RLAT_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_WLAT_WIDTH INTEGER 0
	set_parameter_property AFI_WLAT_WIDTH DERIVED true
	set_parameter_property AFI_WLAT_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_RRANK_WIDTH INTEGER 0
	set_parameter_property AFI_RRANK_WIDTH DERIVED true
	set_parameter_property AFI_RRANK_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_WRANK_WIDTH INTEGER 0
	set_parameter_property AFI_WRANK_WIDTH DERIVED true
	set_parameter_property AFI_WRANK_WIDTH VISIBLE false
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter AFI_CLK_PAIR_COUNT INTEGER 0
	set_parameter_property AFI_CLK_PAIR_COUNT DERIVED true
	set_parameter_property AFI_CLK_PAIR_COUNT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter MRS_MIRROR_PING_PONG_ATSO Boolean false
	set_parameter_property MRS_MIRROR_PING_PONG_ATSO VISIBLE false

	return 1
}


proc ::alt_mem_if::gui::afi::_derive_parameters {} {

	variable protocol
	
	if {[string compare $protocol "RLDRAMII"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 0
			
		set enable_bank_addr 1
		set odt 0
		set support_rank 0
			
	} elseif {[string compare $protocol "RLDRAM3"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 0
			
		set enable_bank_addr 1
		set odt 0
		set support_rank 0
			
	} elseif {[string compare $protocol "QDRII"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 0

		set enable_bank_addr 0
		set odt 0
		set support_rank 0

		if {[get_parameter_value MEM_BURST_LENGTH] == 2 && [string compare -nocase [get_parameter_value RATE] "full"] == 0} {
			set_parameter_value ADDR_CMD_DDR 1
		}
	} elseif {[string compare $protocol "DDRIISRAM"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 0

		set enable_bank_addr 0
		set odt 1
		set support_rank 0
		
	} elseif {[string compare $protocol "DDR2"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 0

		set enable_bank_addr 1
		set odt 1
		set support_rank 1
		
	} elseif {[string compare $protocol "DDR3"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 0

		set enable_bank_addr 1
		set odt 1
		set support_rank 1
		
	} elseif {[string compare $protocol "LPDDR2"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 1

		set enable_bank_addr 0
		set odt 0
		set support_rank 1
		
	} elseif {[string compare $protocol "LPDDR1"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 0

		set enable_bank_addr 1
		set odt 0
		set support_rank 1
		
	} elseif {[string compare $protocol "HPS"] == 0} {
		set_parameter_value DQ_DDR 1
		set_parameter_value ADDR_CMD_DDR 1
		set enable_bank_addr 1
		set odt 1
		set support_rank 0
		
	} else {
		_error "Fatal Error: Unknown protocol $protocol"
	}
	
	if {[string compare -nocase [get_parameter_value RATE] "full"] == 0} {
		set_parameter_value AFI_RATE_RATIO 1
	} elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
		set_parameter_value AFI_RATE_RATIO 2
	} elseif {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
		set_parameter_value AFI_RATE_RATIO 4
	} else {
		_error "Fatal Error: Unknown rate [get_parameter_value RATE]"
	}
	
	if { [get_parameter_value DQ_DDR] == 0 } {
		set_parameter_value DATA_RATE_RATIO 1
	} elseif { [get_parameter_value DQ_DDR] == 1 } {
		set_parameter_value DATA_RATE_RATIO 2
	} else {
		_error "Fatal Error: Illegal DQ_DDR [get_parameter_value DQ_DDR]"
	}

	if { [get_parameter_value ADDR_CMD_DDR] == 0 } {
		set_parameter_value ADDR_RATE_RATIO 1
	} elseif { [get_parameter_value ADDR_CMD_DDR] == 1 } {
		set_parameter_value ADDR_RATE_RATIO 2
	} else {
		_error "Fatal Error: Illegal DQ_DDR [get_parameter_value DQ_DDR]"
	}


	set_parameter_value AFI_ADDR_WIDTH [ expr { [get_parameter_value MEM_IF_ADDR_WIDTH] * [get_parameter_value AFI_RATE_RATIO] * [get_parameter_value ADDR_RATE_RATIO] } ]
	if { $enable_bank_addr == 1 } {
		set_parameter_value AFI_BANKADDR_WIDTH [ expr { [get_parameter_value MEM_IF_BANKADDR_WIDTH] * [get_parameter_value AFI_RATE_RATIO] * [get_parameter_value ADDR_RATE_RATIO]} ]
	}
	set_parameter_value AFI_CONTROL_WIDTH [ expr { [get_parameter_value AFI_RATE_RATIO] * [get_parameter_value ADDR_RATE_RATIO] } ]	

	if {([string compare $protocol "DDR3"] == 0 || [string compare $protocol "DDR2"] == 0) && ([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
		set_parameter_value AFI_CLK_EN_WIDTH [ expr { [get_parameter_value MEM_IF_CLK_EN_WIDTH] * [get_parameter_value AFI_RATE_RATIO] } ]
	} else {
		set_parameter_value AFI_CLK_EN_WIDTH [ expr { [get_parameter_value MEM_IF_CS_WIDTH] * [get_parameter_value AFI_RATE_RATIO] } ]
	}
	set_parameter_value AFI_CS_WIDTH [ expr { [get_parameter_value MEM_IF_CS_WIDTH] * [get_parameter_value AFI_RATE_RATIO] } ]
	set_parameter_value AFI_DM_WIDTH [ expr { [get_parameter_value MEM_IF_DM_WIDTH] * [get_parameter_value AFI_RATE_RATIO] * [get_parameter_value DATA_RATE_RATIO] } ]
	set_parameter_value AFI_DQ_WIDTH [ expr { [get_parameter_value MEM_IF_DQ_WIDTH] * [get_parameter_value AFI_RATE_RATIO] * [get_parameter_value DATA_RATE_RATIO] } ]
	
	if { $support_rank == 1} {
		set_parameter_value AFI_WRANK_WIDTH [ expr { [get_parameter_value MEM_IF_WRITE_DQS_WIDTH] * [get_parameter_value MEM_IF_NUMBER_OF_RANKS] * [get_parameter_value AFI_RATE_RATIO] } ]
		set_parameter_value AFI_RRANK_WIDTH [ expr { [get_parameter_value MEM_IF_READ_DQS_WIDTH] * [get_parameter_value MEM_IF_NUMBER_OF_RANKS] * [get_parameter_value AFI_RATE_RATIO] } ]
	}
		
	if { $odt == 1 } {
		set_parameter_value AFI_ODT_WIDTH [ expr { [get_parameter_value MEM_IF_ODT_WIDTH] * [get_parameter_value AFI_RATE_RATIO] } ]
	}
	set_parameter_value AFI_WRITE_DQS_WIDTH [ expr { [get_parameter_value MEM_IF_WRITE_DQS_WIDTH] * [get_parameter_value AFI_RATE_RATIO] } ]
	set_parameter_value AFI_CLK_PAIR_COUNT [ get_parameter_value MEM_IF_CLK_PAIR_COUNT ]
	
	set AFI_LAT_WIDTH 6
	set_parameter_value AFI_RLAT_WIDTH $AFI_LAT_WIDTH

	set_parameter_value AFI_WLAT_WIDTH $AFI_LAT_WIDTH
	
	if {[string compare -nocase [get_parameter_value FORCE_SHADOW_REGS] "DISABLED"] == 0} {
		set_parameter_value USE_SHADOW_REGS false
	} else {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0 } {
			if {[string compare $protocol "DDR3"] == 0 && 
				[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > 1 &&
				[string compare -nocase [get_parameter_value RATE] "full"] != 0 &&
				[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {
				set_parameter_value USE_SHADOW_REGS true
				_iprint "Usage of shadow registers is enabled to improve multi-rank interface performance"
			} else {
				set_parameter_value USE_SHADOW_REGS false
			}
		} else {
			set_parameter_value USE_SHADOW_REGS false
		}
	}	

	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		set_parameter_value USE_DQS_TRACKING true
		if {[string compare $protocol "LPDDR2"] == 0} { 
			if {[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > 1} {
				set_parameter_value USE_HPS_DQS_TRACKING false
			} else {
				set_parameter_value USE_HPS_DQS_TRACKING true
			}
		} else {
			set_parameter_value USE_HPS_DQS_TRACKING false
		}
	} elseif {[string compare -nocase [get_parameter_value FORCE_DQS_TRACKING] "ENABLED"] == 0} {
		set_parameter_value USE_DQS_TRACKING true
	} elseif {[string compare -nocase [get_parameter_value FORCE_DQS_TRACKING] "DISABLED"] == 0} {
		set_parameter_value USE_DQS_TRACKING false
	} else {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			if {[string compare $protocol "LPDDR2"] == 0} {
				if {[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > 1} {
				    set_parameter_value USE_DQS_TRACKING false
				} else {
				    set_parameter_value USE_DQS_TRACKING true
				}
			} elseif {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
				set_parameter_value USE_DQS_TRACKING false
			} elseif {[string compare $protocol "DDR3"] == 0} {
				if {[get_parameter_value MEM_IF_NUMBER_OF_RANKS] > 1} {
				    set_parameter_value USE_DQS_TRACKING false
				} elseif {[get_parameter_value MEM_CLK_FREQ] >= 750 && ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0)} {
				    set_parameter_value USE_DQS_TRACKING true
				} elseif {[get_parameter_value MEM_CLK_FREQ] >= 534  && ([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 || [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0)} {
				    set_parameter_value USE_DQS_TRACKING true
				} elseif {[get_parameter_value MEM_CLK_FREQ] >= 450 && [string compare -nocase [get_parameter_value SPEED_GRADE] "5"] == 0} {
					set_parameter_value USE_DQS_TRACKING true
				} else {
					set_parameter_value USE_DQS_TRACKING false
				}
			} else {
				set_parameter_value USE_DQS_TRACKING false
			}
		} else {
			set_parameter_value USE_DQS_TRACKING false
		}
	}
	
	if {[string compare $protocol "DDR3"] == 0 && [string compare -nocase [get_parameter_value PINGPONGPHY_EN] "true"] == 0} {
		_dprint 1 "Disabling DQS tracking for ping-pong PHY"
		set_parameter_value USE_DQS_TRACKING false
	}
	
	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		set_parameter_value TRK_PARALLEL_SCC_LOAD false
	} elseif {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set_parameter_value TRK_PARALLEL_SCC_LOAD false
	} elseif {([string compare $protocol "DDR3"] == 0 || [string compare $protocol "LPDDR2"] == 0) && [string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0 && ([get_parameter_value MEM_IF_READ_DQS_WIDTH] > 1)} {
		set_parameter_value TRK_PARALLEL_SCC_LOAD true
	}

	return 1
}


::alt_mem_if::gui::afi::_init
