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


package provide alt_mem_if::gui::ddrx_controller 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils

namespace eval ::alt_mem_if::gui::ddrx_controller:: {
	variable VALID_DDR_MODES
	variable ddr_mode
	variable parameters
	
	namespace import ::alt_mem_if::util::messaging::*

}


proc ::alt_mem_if::gui::ddrx_controller::_validate_ddr_mode {} {
	variable ddr_mode
		
	if {$ddr_mode == -1} {
		error "DDR mode in [namespace current] in uninitialized!"
	}
	return 1
}

proc ::alt_mem_if::gui::ddrx_controller::set_ddr_mode {in_ddr_mode} {
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

proc ::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS {} {
	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] != 0} {
		return 0
	} else {
		return [get_parameter_value NUM_OF_PORTS]
	}
}

proc ::alt_mem_if::gui::ddrx_controller::create_parameters {} {

	variable parameters
	
	_validate_ddr_mode
	
	_dprint 1 "Preparing to create parameters for ddrx_controller"
	
	set pre_list [split [get_parameters]]
	
	_create_derived_parameters

	_create_controller_parameters
		
	set post_list [split [get_parameters]]

	::alt_mem_if::util::list_array::intersect3 $pre_list $post_list in_list1 parameters in_both

	return 1
}


proc ::alt_mem_if::gui::ddrx_controller::create_gui { {is_top_standalone 0} } {

	_validate_ddr_mode

	_create_controller_parameters_gui $is_top_standalone
	
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		_create_interface_parameters_gui
	}
	
	return 1
}

if {! [::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
	set_module_property PARAMETER_UPGRADE_CALLBACK ip_upgrade
}

proc ip_upgrade {ip_core_type version parameters} {

	_dprint 1 "Upgrading from previous component version"
		
	foreach { name value } $parameters {

		if {[string compare -nocase $name SYS_INFO_DEVICE_FAMILY] == 0} {
			continue
		}

		set new_value $value
		if {[string compare -nocase $version "11.1"] == 0 ||
			[string compare -nocase $version "11.0"] == 0} {

			if {[string compare -nocase $name HHP_REMAP_ADDR] == 0 ||
			    [string compare -nocase $name USE_SEQUENCER_APB_BRIDGE] == 0 ||
			    [string compare -nocase $name DLL_DELAY_CHAIN_LENGTH] == 0 ||
			    [string compare -nocase $name QSYS_SEQUENCER_DEBUG] == 0 ||
			    [string compare -nocase $name DQS_TRK_ENABLED] == 0} {
				continue
			} elseif {[string compare -nocase $name PRIORITY_PORT] == 0} {
				set new_value [string map {{,} { }} $value]
				if { ([get_parameter_value NUM_OF_PORTS] == 1)} {
					set new_value "[lindex $new_value 0] 1 1 1 1 1"
				} elseif { ([get_parameter_value NUM_OF_PORTS] == 2)} {
					set new_value "[lindex $new_value 0] [lindex $new_value 1] 1 1 1 1"
				} elseif { ([get_parameter_value NUM_OF_PORTS] == 3)} {
					set new_value "[lindex $new_value 0] [lindex $new_value 1] [lindex $new_value 2] 1 1 1"
				} elseif { ([get_parameter_value NUM_OF_PORTS] == 4)} {
					set new_value "[lindex $new_value 0] [lindex $new_value 1] [lindex $new_value 2] [lindex $new_value 3] 1 1"
				} elseif { ([get_parameter_value NUM_OF_PORTS] == 5)} {
					set new_value "[lindex $new_value 0] [lindex $new_value 1] [lindex $new_value 2] [lindex $new_value 3] [lindex $new_value 4] 1"
				}

			} elseif {[string compare -nocase $name CPORT_TYPE_PORT] == 0} {
				set new_value [string map {{,} { }} $value]
			} elseif {[string compare -nocase $name AVL_DATA_WIDTH_PORT] == 0} {
				set new_value [string map {{,} { }} $value]
			} elseif {[string compare -nocase $name WEIGHT_PORT] == 0} {
				set new_value [string map {{,} { }} $value]
			}
		}

                if {[string compare -nocase $name CFG_STARVE_LIMIT] == 0} {
                        set_parameter_value STARVE_LIMIT $value
                        continue
                } elseif {[string compare -nocase $name MEM_AUTO_PD_CYCLES] == 0} {
                        set_parameter_value AUTO_PD_CYCLES $value
                        continue
                }

		_dprint 1 "Setting $name = $new_value"
		set_parameter_value $name $new_value
	}
}


proc ::alt_mem_if::gui::ddrx_controller::validate_component {} {

	set protocol [_get_protocol]

	_derive_parameters
	
	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0} {
		return 1
	}
	
	_dprint 1 "Preparing to validate component for DDRX controller"



    if {[string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "false"] == 0} {
        set_parameter_property AUTO_PD_CYCLES Enabled false
    } else {
        set_parameter_property AUTO_PD_CYCLES Enabled true
    }

    if {[string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "false"] == 0} {
        set_parameter_property CTL_DYNAMIC_BANK_NUM Enabled false
    } else {
        set_parameter_property CTL_DYNAMIC_BANK_NUM Enabled true
    }

    if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0} {
        set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED Enabled false
    } else {
        set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED Enabled true
    }
	
	if {[regexp {^LPDDR2$|^LPDDR1$} $protocol] == 1} {
		set_parameter_property CTL_DEEP_POWERDN_EN VISIBLE true
	} else {
		set_parameter_property CTL_DEEP_POWERDN_EN VISIBLE false
	}

    if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
        set_parameter_property CONTROLLER_LATENCY Visible false
        set_parameter_property MULTICAST_EN Visible false
        set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION Visible false
        set_parameter_property CTL_DYNAMIC_BANK_NUM Visible false
        set_parameter_property CFG_REORDER_DATA Visible true
        set_parameter_property STARVE_LIMIT Visible true
        set_parameter_property CTL_HRB_ENABLED VISIBLE false

        if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0 ||
            [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0} {
                set_parameter_property ENABLE_BONDING Visible true
                set_parameter_property ENABLE_USER_ECC Visible true
                set_parameter_property NUM_OF_PORTS Visible true
	        set_parameter_property AVL_PORT Visible true
                set_parameter_property AVL_DATA_WIDTH_PORT Visible true
                set_parameter_property WEIGHT_PORT Visible true
                set_parameter_property CPORT_TYPE_PORT Visible true
                set_parameter_property ALLOCATED_WFIFO_PORT Visible true
                set_parameter_property ALLOCATED_RFIFO_PORT Visible true
                             
                if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
                        set_parameter_property NUM_OF_PORTS Enabled true
                        set_parameter_property ENABLE_BONDING Enabled true
                        set_parameter_property ENABLE_USER_ECC Enabled true
	        	set_parameter_property AVL_PORT Enabled true
                        set_parameter_property AVL_DATA_WIDTH_PORT Enabled true
	        	set_parameter_property PRIORITY_PORT Enabled true
                        set_parameter_property WEIGHT_PORT Enabled true
                        set_parameter_property CPORT_TYPE_PORT Enabled true
                        set_parameter_property CTL_LOOK_AHEAD_DEPTH Enabled false
                        set_parameter_property CTL_HRB_ENABLED Enabled false
                        set_parameter_property AVL_ADDR_WIDTH Visible false
                        set_parameter_property AVL_DATA_WIDTH Visible false
                        if {[::alt_mem_if::util::qini::cfg_is_on uniphy_overwrite_auto_fifo_mapping]} {
                                set_parameter_property ALLOCATED_WFIFO_PORT Enabled true
                                set_parameter_property ALLOCATED_RFIFO_PORT Enabled true
                        } else {
                                set_parameter_property ALLOCATED_WFIFO_PORT Enabled false
                                set_parameter_property ALLOCATED_RFIFO_PORT Enabled false
                        }
                } else {
                        set_parameter_property NUM_OF_PORTS Enabled false
                        set_parameter_property ENABLE_BONDING Enabled false
                        set_parameter_property ENABLE_USER_ECC Enabled false
	        	set_parameter_property AVL_PORT Enabled false
                        set_parameter_property AVL_DATA_WIDTH_PORT Enabled false
	        	set_parameter_property PRIORITY_PORT Enabled false
                        set_parameter_property WEIGHT_PORT Enabled false
                        set_parameter_property CPORT_TYPE_PORT Enabled false
                        set_parameter_property CTL_LOOK_AHEAD_DEPTH Enabled true
                        set_parameter_property CTL_HRB_ENABLED Enabled true
                        set_parameter_property ALLOCATED_WFIFO_PORT Enabled false
                        set_parameter_property ALLOCATED_RFIFO_PORT Enabled false
                        set_parameter_property AVL_ADDR_WIDTH Visible true
                        set_parameter_property AVL_DATA_WIDTH Visible true
                }
	} else {
                set_parameter_property NUM_OF_PORTS Visible false
                set_parameter_property ENABLE_BONDING Visible false
                set_parameter_property ENABLE_USER_ECC Visible false
	        set_parameter_property AVL_PORT Visible false
                set_parameter_property AVL_DATA_WIDTH_PORT Visible false
	        set_parameter_property PRIORITY_PORT Visible false
                set_parameter_property WEIGHT_PORT Visible false
                set_parameter_property CPORT_TYPE_PORT Visible false
                set_parameter_property ALLOCATED_WFIFO_PORT Visible false
                set_parameter_property ALLOCATED_RFIFO_PORT Visible false
                
                set_display_item_property "Multiple Port Front End" VISIBLE false
	}

    } else {
        set_parameter_property CONTROLLER_LATENCY Visible true
        set_parameter_property MULTICAST_EN Visible true
        set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION Visible true
        set_parameter_property CTL_HRB_ENABLED VISIBLE true
        set_parameter_property CTL_DYNAMIC_BANK_NUM Visible true
        set_parameter_property CFG_REORDER_DATA Visible false
        set_parameter_property STARVE_LIMIT Visible false
        set_parameter_property NUM_OF_PORTS Visible false
        set_parameter_property ENABLE_BONDING Visible false
        set_parameter_property ENABLE_USER_ECC Visible false
	set_parameter_property AVL_PORT Visible false
        set_parameter_property AVL_DATA_WIDTH_PORT Visible false
	set_parameter_property PRIORITY_PORT Visible false
        set_parameter_property WEIGHT_PORT Visible false
        set_parameter_property CPORT_TYPE_PORT Visible false

    }

    if {[string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0} {
        set_parameter_property STARVE_LIMIT Enabled true
    } else {
        set_parameter_property STARVE_LIMIT Enabled false
    }

    if {[string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0} {
        set_parameter_property CFG_DATA_REORDERING_TYPE Enabled true
    } else {
        set_parameter_property CFG_DATA_REORDERING_TYPE Enabled false
    }

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {

                if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0 &&
                    [string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "EXPORT"] == 0 } {
                        set_parameter_property MMRD_ENABLED Enabled true
                } else {
                        set_parameter_property MMRD_ENABLED Enabled false
                }

    for {set port_id 0} {$port_id != 6} {incr port_id} {
            if {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {
                set_parameter_property ENABLE_UNIX_ID_${port_id} Enabled true
                set_parameter_property USE_UNIX_ID_${port_id} Enabled true
                set_parameter_property USE_SYNC_READY_${port_id} Enabled true
                set_parameter_property USER_ADDR_ENABLED_${port_id} Enabled true
                set_parameter_property USER_ADDR_FILE_${port_id} Enabled true
                set_parameter_property USER_ADDR_BINARY_${port_id} Enabled true
                set_parameter_property USER_ADDR_DEPTH_${port_id} Enabled true
                set_parameter_property USER_DATA_ENABLED_${port_id} Enabled true
                set_parameter_property USER_DATA_FILE_${port_id} Enabled true
                set_parameter_property USER_DATA_BINARY_${port_id} Enabled true
                set_parameter_property USER_DATA_DEPTH_${port_id} Enabled true
                set_parameter_property ENABLE_READ_ONLY_COMPARE_${port_id} Enabled true
                set_parameter_property TURN_PORT_${port_id} Enabled true
                set_display_item_property pof${port_id} Enabled true
                set_display_item_property pofA${port_id} Enabled true
                set_display_item_property pofB${port_id} Enabled true
                set_display_item_property pofC${port_id} Enabled true
                set_display_item_property pofD${port_id} Enabled true
                set_display_item_property pofE${port_id} Enabled true
            } else {
                set_parameter_property ENABLE_UNIX_ID_${port_id} Enabled false
                set_parameter_property USE_UNIX_ID_${port_id} Enabled false
                set_parameter_property USE_SYNC_READY_${port_id} Enabled false
                set_parameter_property USER_ADDR_ENABLED_${port_id} Enabled false
                set_parameter_property USER_ADDR_FILE_${port_id} Enabled false
                set_parameter_property USER_ADDR_BINARY_${port_id} Enabled false
                set_parameter_property USER_ADDR_DEPTH_${port_id} Enabled false
                set_parameter_property USER_DATA_ENABLED_${port_id} Enabled false
                set_parameter_property USER_DATA_FILE_${port_id} Enabled false
                set_parameter_property USER_DATA_BINARY_${port_id} Enabled false
                set_parameter_property USER_DATA_DEPTH_${port_id} Enabled false
                set_parameter_property ENABLE_READ_ONLY_COMPARE_${port_id} Enabled false
                set_parameter_property TURN_PORT_${port_id} Enabled false
                set_display_item_property pof${port_id} Enabled false
                set_display_item_property pofA${port_id} Enabled false
                set_display_item_property pofB${port_id} Enabled false
                set_display_item_property pofC${port_id} Enabled false
                set_display_item_property pofD${port_id} Enabled false
                set_display_item_property pofE${port_id} Enabled false
            }
    }
    }

    if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
        set_parameter_property ADDR_ORDER ALLOWED_RANGES {0:CHIP-ROW-BANK-COL 1:CHIP-BANK-ROW-COL 2:ROW-CHIP-BANK-COL}
        set_parameter_property CTL_LOOK_AHEAD_DEPTH ALLOWED_RANGES {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
    } else {
        set_parameter_property ADDR_ORDER ALLOWED_RANGES {0:CHIP-ROW-BANK-COL 1:CHIP-BANK-ROW-COL}
        set_parameter_property CTL_LOOK_AHEAD_DEPTH ALLOWED_RANGES {0 2 4 6 8}
    }

    if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
    	set_parameter_property AVL_MAX_SIZE ALLOWED_RANGES {1 2 4 8 16 32 64 128}
    } else {
    set_parameter_property AVL_MAX_SIZE ALLOWED_RANGES {1 2 4 8 16 32 64 128 256 512 1024}
    }
    
    if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
	set_parameter_property PRIORITY_PORT ALLOWED_RANGES {1 2 3 4 5 6 7}
    } else {
	set_parameter_property PRIORITY_PORT ALLOWED_RANGES {0 1}
    }
    
	set validation_pass 1

	if {[string compare -nocase [get_parameter_value DEVICE_FAMILY] ""] == 0} {
		_eprint "No device family is set for DDRx controller"
		set validation_pass 0
	}


    if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "false"] == 0 } {
    	if {[string compare -nocase [get_parameter_value BYTE_ENABLE] "true"] == 0 && 
	    [string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0} {
			_eprint "When '[get_parameter_property MEM_IF_DM_PINS_EN DISPLAY_NAME]' is disabled, the '[get_parameter_property BYTE_ENABLE DISPLAY_NAME]' option must not be selected if '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is disabled."  
			set validation_pass 0
		}
	}


    set max_freq_for_reduce_latency 400

	set min_dynamic_bank_num 1
	set max_dynamic_bank_num 16
    if {[get_parameter_value CTL_LOOK_AHEAD_DEPTH] > 1} {
        set min_dynamic_bank_num [expr [get_parameter_value CTL_LOOK_AHEAD_DEPTH] + 1]
    }

    if {([string compare -nocase [get_parameter_value RATE] "full"] == 0) &&
		([regexp {^DDR3$} $protocol] == 1) &&
	    ([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0)} {
		_eprint "DDR3 SDRAM is not supported at full rate by [get_parameter_value DEVICE_FAMILY] devices."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value RATE] "full"] != 0) &&
	    ([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0)} {
        _eprint "The '[get_parameter_property CTL_HRB_ENABLED DISPLAY_NAME]' checkbox is only applicable for full rate."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "false"] == 0) &&
	    ([get_parameter_value MEM_AUTO_PD_CYCLES] != [get_parameter_property AUTO_PD_CYCLES DEFAULT_VALUE])} {
        _eprint "The value for '[get_parameter_property AUTO_PD_CYCLES DISPLAY_NAME]' is only valid when '[get_parameter_property AUTO_POWERDN_EN DISPLAY_NAME]' checkbox is checked."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([get_parameter_value ADDR_ORDER] == 2)} {
        _eprint "The '[get_parameter_property ADDR_ORDER DISPLAY_NAME]' value of [string map {0 CHIP-ROW-BANK-COL 1 CHIP-BANK-ROW-COL 2 ROW-CHIP-BANK-COL} [get_parameter_value ADDR_ORDER]] is only supported in the new memory controller architecture."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) &&
	    ([get_parameter_value CTL_LOOK_AHEAD_DEPTH] > [get_parameter_property CTL_LOOK_AHEAD_DEPTH DEFAULT_VALUE])} {
        _wprint "Timing closure may not be achievable at maximum frequency for '[get_parameter_property CTL_LOOK_AHEAD_DEPTH DISPLAY_NAME]' value greater than [get_parameter_property CTL_LOOK_AHEAD_DEPTH DEFAULT_VALUE]."
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) &&
	    ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE])} {
        _eprint "The value for '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' is only valid in the previous memory controller architecture."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]) &&
	    ([get_parameter_value MEM_CLK_FREQ] > $max_freq_for_reduce_latency)} {
        _eprint "The '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' value of [string map {5 0 4 1} [get_parameter_value CONTROLLER_LATENCY]] is only supported for '[get_parameter_property MEM_CLK_FREQ DISPLAY_NAME]' that is less than $max_freq_for_reduce_latency MHz."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]) &&
	    ([get_parameter_value MEM_CLK_FREQ] <= $max_freq_for_reduce_latency)} {
        _wprint "Timing closure may not be achievable at maximum frequency for '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' value greater than [string map {5 0 4 1} [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]]."
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0)} {
        _eprint "The '[get_parameter_property CFG_REORDER_DATA DISPLAY_NAME]' checkbox is only applicable in the new memory controller architecture."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) &&
	    ([string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0) &&
	    ([get_parameter_value CFG_STARVE_LIMIT] > [get_parameter_property STARVE_LIMIT DEFAULT_VALUE])} {
        _wprint "Timing closure may not be achievable at maximum frequency for '[get_parameter_property STARVE_LIMIT DISPLAY_NAME]' value that is greater than [get_parameter_property STARVE_LIMIT DEFAULT_VALUE]."
    }

    if {([string compare -nocase [get_parameter_value CFG_REORDER_DATA] "false"] == 0) &&
	    ([get_parameter_value CFG_STARVE_LIMIT] != [get_parameter_property STARVE_LIMIT DEFAULT_VALUE]) &&
	    ([get_parameter_value CFG_STARVE_LIMIT] != 4)} {
        _eprint "The value for '[get_parameter_property STARVE_LIMIT DISPLAY_NAME]' is only valid when '[get_parameter_property CFG_REORDER_DATA DISPLAY_NAME]' checkbox is checked."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0) &&
		([string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "export"] == 0)} {
        _wprint "CSR port can only be connected to debug GUI when using a CSR port connection with an internally connected JTAG Avalon Master."
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) &&
	    ([string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0) &&
            ([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) &&
	    ([get_parameter_value CTL_ECC_MULTIPLES_16_24_40_72] == 0)} {
        _eprint "The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' must be a multiple of 16, 24, 40 or 72 bits when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) &&
	    ([get_parameter_value CTL_ECC_MULTIPLES_40_72] == 0)} {
        _eprint "The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value that is a multiple of 40 or 72 bits is required when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) &&
	    ([string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "false"] == 0)} {
        _eprint "The '[get_parameter_property CTL_CSR_ENABLED DISPLAY_NAME]' checkbox must be checked to access ECC status bits."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0) &&
	    ([get_parameter_value CONTROLLER_LATENCY] != [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE])} {
        _eprint "The '[get_parameter_property CONTROLLER_LATENCY DISPLAY_NAME]' value of [string map {5 0 4 1} [get_parameter_property CONTROLLER_LATENCY DEFAULT_VALUE]] is required when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0) &&
	    ([string compare -nocase [get_parameter_value CTL_ECC_AUTO_CORRECTION_ENABLED] "true"] == 0)} {
        _eprint "The '[get_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_NAME]' checkbox is only applicable when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) &&
	    ([string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0)} {
        _eprint "The '[get_parameter_property MULTICAST_EN DISPLAY_NAME]' checkbox is only applicable in the previous memory controller architecture."
		set validation_pass 0
    }
	
	if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) &&
	    ([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0)} {
        _eprint "The '[get_parameter_property CTL_HRB_ENABLED DISPLAY_NAME]' checkbox is only applicable in the previous memory controller architecture."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0) &&
	    ([get_parameter_value MEM_IF_CS_WIDTH] == 1) &&
	    ([string compare -nocase [get_parameter_value MEM_FORMAT] "discrete"] == 0)} {
        _eprint "The '[get_parameter_property MULTICAST_EN DISPLAY_NAME]' checkbox is only applicable when there is more than 1 memory chip selects. To change the number of memory chip selects, modify the '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' value."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0) &&
	    ([string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0) &&
	    ([get_parameter_value MEM_IF_CS_WIDTH] == 1) &&
	    ([string compare -nocase [get_parameter_value MEM_FORMAT] "discrete"] != 0)} {
        _eprint "The '[get_parameter_property MULTICAST_EN DISPLAY_NAME]' checkbox is only applicable when there is more than 1 memory chip selects. To change the number of memory chip selects, modify the '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DISPLAY_NAME]' value."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) &&
	    ([string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "true"] == 0)} {
        _eprint "The '[get_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_NAME]' checkbox is only applicable in the previous memory controller architecture."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "false"] == 0) &&
	    ([get_parameter_value CTL_DYNAMIC_BANK_NUM] != [get_parameter_property CTL_DYNAMIC_BANK_NUM DEFAULT_VALUE])} {
        _eprint "The value for '[get_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_NAME]' is only valid when '[get_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_NAME]' checkbox is checked."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CTL_DYNAMIC_BANK_ALLOCATION] "true"] == 0) &&
	    (([get_parameter_value CTL_DYNAMIC_BANK_NUM] < $min_dynamic_bank_num) ||
	     ([get_parameter_value CTL_DYNAMIC_BANK_NUM] > $max_dynamic_bank_num))} {
        _eprint "The '[get_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_NAME]' value of [get_parameter_value CTL_DYNAMIC_BANK_NUM] is not supported. For a '[get_parameter_property CTL_LOOK_AHEAD_DEPTH DISPLAY_NAME]' of [get_parameter_value CTL_LOOK_AHEAD_DEPTH], the minimum is $min_dynamic_bank_num and maximum is $max_dynamic_bank_num."
		set validation_pass 0
    }

    if {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "ddrx"] == 0)} {
        _iprint "This design uses a [get_module_property DISPLAY_NAME] memory controller architecture earlier than version 11.0. Altera recommends that all designs upgrade to the 11.0 version of the [get_module_property DISPLAY_NAME]."
        _iprint "To use the 11.0 version of the [get_module_property DISPLAY_NAME], close this window and create a new variation of [get_module_property DISPLAY_NAME]."
    }

    if {[string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0} {
        if {([string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "true"] == 0) &&
		    ([string compare -nocase [get_parameter_value USE_AXI_ADAPTOR] "true"] == 0)} {
        	_eprint "Only 1 type of adaptor can be instantiated."
			set validation_pass 0
        } elseif {([string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "false"] == 0) &&
		          ([string compare -nocase [get_parameter_value USE_AXI_ADAPTOR] "false"] == 0)} {
        	_wprint "Current example driver only supports Avalon-MM interface."
        } elseif {[string compare -nocase [get_parameter_value USE_AXI_ADAPTOR] "true"] ==0} {
        	_eprint "Current example driver only supports Avalon-MM interface."
			set validation_pass 0
        }
    }


        
	if {([string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0)} {
	        if { [string compare -nocase [get_parameter_value RATE] "full"] != 0 } {
	        	_eprint "The '[get_parameter_property RATE DISPLAY_NAME]' must be set to Full when '[get_parameter_property HARD_EMIF DISPLAY_NAME]' checkbox is checked."
	        	set validation_pass 0
	        }
                
                if { [string compare -nocase [get_parameter_value ENABLE_BONDING] "true"] == 0 } {
                        _wprint "Manual instantiation and connection required to bond 2 Hard External Memory Interface together. Please refer to the External Memory Interface handbook for the steps."
                }
                
                set uni_directional_port_exist 0
                for {set port_id 0} {$port_id != 6} {incr port_id} {
                        set port_type [string map {"Not in use" 0 "Write-only" 1 "Read-only" 2 "Bidirectional" 3} [lindex [split [get_parameter_value CPORT_TYPE_PORT] " "] $port_id]]
                        if { $port_type == 1 || $port_type == 2 } {
                                set uni_directional_port_exist 1
                        }
                
                }
                
                if { $uni_directional_port_exist == 1 } {
                        _wprint "The '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Bidirectional if you plan to simulate the example design."
                }

                if { [string compare -nocase [get_parameter_value ENABLE_USER_ECC] "true"] == 0 } {
                        for {set port_id 0} {$port_id != 6} {incr port_id} {
                                if {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {
                                        set width_value [lindex [split [get_parameter_value AVL_DATA_WIDTH_PORT] " "] $port_id]
                                        if { ($width_value != 48 && $width_value != 80 && $width_value != 160 && $width_value != 320) } {
                                                _eprint "The Port $port_id '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be either 48, 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked."
                                        }
                                }
                        }
                } else {
                        for {set port_id 0} {$port_id != 6} {incr port_id} {
                                if {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {
                                        set width_value [lindex [split [get_parameter_value AVL_DATA_WIDTH_PORT] " "] $port_id]
                                        if { ($width_value != 32 && $width_value != 64 && $width_value != 128 && $width_value != 256) } {  
                                                _eprint "The Port $port_id '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
                                        }
                                }
                        }
                }

                if { [get_parameter_value AVL_MAX_SIZE] > 128 } {
                        _eprint "The '[get_parameter_property AVL_MAX_SIZE DISPLAY_NAME]' must be less than or equal to 128 when '[get_parameter_property HARD_EMIF DISPLAY_NAME]' checkbox is checked."
                }


                if {[string compare -nocase [ get_parameter_value MEM_FORMAT ] "DISCRETE" ] != 0 } {
                        _eprint "The '[get_parameter_property MEM_FORMAT DISPLAY_NAME]' must be set to Discrete Device when '[get_parameter_property HARD_EMIF DISPLAY_NAME]' checkbox is checked."
                }

		set rbc_validation_pass [_validate_hmc_atom_parameters]
		if {$rbc_validation_pass == 0} {
			if {[::alt_mem_if::util::qini::cfg_is_on uniphy_ignore_rbc_violation]} {
				_wprint "Some violation related to the Hard Memory Controller atom parameter has occured. Please follow the suggested fix (if available) or report to Altera together with the rule ID that has been violated."
			} else {
				_eprint "Some violation related to the Hard Memory Controller atom parameter has occured. Please follow the suggested fix (if available) or report to Altera together with the rule ID that has been violated."
				set validation_pass 0
			}
		}

                regsub -all _ [get_parameter_value ENUM_MEM_IF_SPEEDBIN] - speedbin_string
                _dprint 3 "The suggested memory speed bin is $speedbin_string. Please change the '[get_parameter_property MEM_CLK_FREQ_MAX DISPLAY_NAME]', '[get_parameter_property MEM_TCL DISPLAY_NAME]', '[get_parameter_property MEM_TRCD DISPLAY_NAME]' and '[get_parameter_property MEM_TRP DISPLAY_NAME]' value if other memory speed bin is required."
                if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0} {
                        _rederive_hmc_atom_derived_parameters
                }
	}

	return $validation_pass

}

proc ::alt_mem_if::gui::ddrx_controller::elaborate_component {} {

	_dprint 1 "Preparing to elaborate component for Common DDRX controller"

	return 1
}


proc ::alt_mem_if::gui::ddrx_controller::_init {} {
	variable VALID_DDR_MODES
	
	::alt_mem_if::util::list_array::array_clean VALID_DDR_MODES
	set VALID_DDR_MODES(DDR2) 1
	set VALID_DDR_MODES(DDR3) 1
	set VALID_DDR_MODES(LPDDR2) 1
	set VALID_DDR_MODES(LPDDR1) 1
	set VALID_DDR_MODES(HPS) 1

	variable ddr_mode -1
	
}


proc ::alt_mem_if::gui::ddrx_controller::_get_protocol {} {

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


proc ::alt_mem_if::gui::ddrx_controller::_create_derived_parameters {} {

	_dprint 1 "Preparing to create derived parameters in ddrx_controller"

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

	::alt_mem_if::util::hwtcl_utils::_add_parameter HR_DDIO_OUT_HAS_THREE_REGS boolean false
	set_parameter_property HR_DDIO_OUT_HAS_THREE_REGS DERIVED true
	set_parameter_property HR_DDIO_OUT_HAS_THREE_REGS VISIBLE false


	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ECC_CSR_ENABLED Boolean false
	set_parameter_property CTL_ECC_CSR_ENABLED VISIBLE false
	set_parameter_property CTL_ECC_CSR_ENABLED DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter DWIDTH_RATIO Integer 4
	set_parameter_property DWIDTH_RATIO VISIBLE false
	set_parameter_property DWIDTH_RATIO DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ODT_ENABLED Boolean false
	set_parameter_property CTL_ODT_ENABLED VISIBLE false
	set_parameter_property CTL_ODT_ENABLED DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_OUTPUT_REGD Boolean false
	set_parameter_property CTL_OUTPUT_REGD VISIBLE false
	set_parameter_property CTL_OUTPUT_REGD DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ECC_MULTIPLES_40_72 Integer 0
	set_parameter_property CTL_ECC_MULTIPLES_40_72 VISIBLE false
	set_parameter_property CTL_ECC_MULTIPLES_40_72 DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ECC_MULTIPLES_16_24_40_72 Integer 0
	set_parameter_property CTL_ECC_MULTIPLES_16_24_40_72 VISIBLE false
	set_parameter_property CTL_ECC_MULTIPLES_16_24_40_72 DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_REGDIMM_ENABLED Boolean false
	set_parameter_property CTL_REGDIMM_ENABLED VISIBLE false
	set_parameter_property CTL_REGDIMM_ENABLED DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter LOW_LATENCY Boolean false
	set_parameter_property LOW_LATENCY VISIBLE false
	set_parameter_property LOW_LATENCY DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CONTROLLER_TYPE String "nextgen_v110"
	set_parameter_property CONTROLLER_TYPE VISIBLE false
	set_parameter_property CONTROLLER_TYPE DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_TBP_NUM Integer 4
	set_parameter_property CTL_TBP_NUM VISIBLE false
	set_parameter_property CTL_TBP_NUM DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_USR_REFRESH Integer 0
	set_parameter_property CTL_USR_REFRESH VISIBLE false
	set_parameter_property CTL_USR_REFRESH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_SELF_REFRESH Integer 0
	set_parameter_property CTL_SELF_REFRESH VISIBLE false
	set_parameter_property CTL_SELF_REFRESH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_TYPE Integer 0
	set_parameter_property CFG_TYPE VISIBLE false
	set_parameter_property CFG_TYPE DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_INTERFACE_WIDTH Integer 0
	set_parameter_property CFG_INTERFACE_WIDTH VISIBLE false
	set_parameter_property CFG_INTERFACE_WIDTH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_BURST_LENGTH Integer 0
	set_parameter_property CFG_BURST_LENGTH VISIBLE false
	set_parameter_property CFG_BURST_LENGTH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_ADDR_ORDER Integer 0
	set_parameter_property CFG_ADDR_ORDER VISIBLE false
	set_parameter_property CFG_ADDR_ORDER DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_PDN_EXIT_CYCLES Integer 0
	set_parameter_property CFG_PDN_EXIT_CYCLES VISIBLE false
	set_parameter_property CFG_PDN_EXIT_CYCLES DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_POWER_SAVING_EXIT_CYCLES Integer 0
	set_parameter_property CFG_POWER_SAVING_EXIT_CYCLES VISIBLE false
	set_parameter_property CFG_POWER_SAVING_EXIT_CYCLES DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_MEM_CLK_ENTRY_CYCLES Integer 0
	set_parameter_property CFG_MEM_CLK_ENTRY_CYCLES VISIBLE false
	set_parameter_property CFG_MEM_CLK_ENTRY_CYCLES DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_SELF_RFSH_EXIT_CYCLES Integer 0
	set_parameter_property CFG_SELF_RFSH_EXIT_CYCLES VISIBLE false
	set_parameter_property CFG_SELF_RFSH_EXIT_CYCLES DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_PORT_WIDTH_WRITE_ODT_CHIP Integer 0
	set_parameter_property CFG_PORT_WIDTH_WRITE_ODT_CHIP VISIBLE false
	set_parameter_property CFG_PORT_WIDTH_WRITE_ODT_CHIP DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_PORT_WIDTH_READ_ODT_CHIP Integer 0
	set_parameter_property CFG_PORT_WIDTH_READ_ODT_CHIP VISIBLE false
	set_parameter_property CFG_PORT_WIDTH_READ_ODT_CHIP DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_WRITE_ODT_CHIP Integer 0
	set_parameter_property CFG_WRITE_ODT_CHIP VISIBLE false
	set_parameter_property CFG_WRITE_ODT_CHIP DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_READ_ODT_CHIP Integer 0
	set_parameter_property CFG_READ_ODT_CHIP VISIBLE false
	set_parameter_property CFG_READ_ODT_CHIP DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter LOCAL_CS_WIDTH Integer 0
	set_parameter_property LOCAL_CS_WIDTH VISIBLE false
	set_parameter_property LOCAL_CS_WIDTH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_CLR_INTR Integer 0
	set_parameter_property CFG_CLR_INTR VISIBLE false
	set_parameter_property CFG_CLR_INTR DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_ENABLE_NO_DM Integer 0
	set_parameter_property CFG_ENABLE_NO_DM VISIBLE false
	set_parameter_property CFG_ENABLE_NO_DM DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_ADD_LAT INTEGER 0
	set_parameter_property MEM_ADD_LAT DERIVED true
	set_parameter_property MEM_ADD_LAT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ENABLE_BURST_INTERRUPT_INT Boolean false
	set_parameter_property CTL_ENABLE_BURST_INTERRUPT_INT DERIVED true
	set_parameter_property CTL_ENABLE_BURST_INTERRUPT_INT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ENABLE_BURST_TERMINATE_INT Boolean false
	set_parameter_property CTL_ENABLE_BURST_TERMINATE_INT DERIVED true
	set_parameter_property CTL_ENABLE_BURST_TERMINATE_INT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_ERRCMD_FIFO_REG Integer 0
	set_parameter_property CFG_ERRCMD_FIFO_REG VISIBLE false
	set_parameter_property CFG_ERRCMD_FIFO_REG DERIVED true
	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_ECC_DECODER_REG Integer 0
	set_parameter_property CFG_ECC_DECODER_REG VISIBLE false
	set_parameter_property CFG_ECC_DECODER_REG DERIVED true
	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ENABLE_WDATA_PATH_LATENCY Boolean false
	set_parameter_property CTL_ENABLE_WDATA_PATH_LATENCY VISIBLE false
	set_parameter_property CTL_ENABLE_WDATA_PATH_LATENCY DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_STARVE_LIMIT Integer 0
	set_parameter_property CFG_STARVE_LIMIT VISIBLE false
	set_parameter_property CFG_STARVE_LIMIT DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_AUTO_PD_CYCLES Integer 0
	set_parameter_property MEM_AUTO_PD_CYCLES VISIBLE false
	set_parameter_property MEM_AUTO_PD_CYCLES DERIVED true


	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_PORT string_list ""
	set_parameter_property AVL_PORT DISPLAY_NAME "Port"
        set_parameter_property AVL_PORT DESCRIPTION "Specifies the Avalon-MM Slave port to be configure"
        set_parameter_property AVL_PORT DERIVED true                           
	set_parameter_property AVL_PORT DISPLAY_HINT FIXED_SIZE

        for {set port_id 0} {$port_id != 6} {incr port_id} {
	        ::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_DATA_WIDTH_PORT_${port_id} Integer 0
	        set_parameter_property AVL_DATA_WIDTH_PORT_${port_id} DERIVED true
                set_parameter_property AVL_DATA_WIDTH_PORT_${port_id} VISIBLE false
			
	        ::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_ADDR_WIDTH_PORT_${port_id} Integer 0
	        set_parameter_property AVL_ADDR_WIDTH_PORT_${port_id} DERIVED true
                set_parameter_property AVL_ADDR_WIDTH_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter PRIORITY_PORT_${port_id} Integer 0
	        set_parameter_property PRIORITY_PORT_${port_id} DERIVED true
                set_parameter_property PRIORITY_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter WEIGHT_PORT_${port_id} Integer 0
	        set_parameter_property WEIGHT_PORT_${port_id} DERIVED true
                set_parameter_property WEIGHT_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CPORT_TYPE_PORT_${port_id} Integer 0
	        set_parameter_property CPORT_TYPE_PORT_${port_id} DERIVED true
                set_parameter_property CPORT_TYPE_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_NUM_SYMBOLS_PORT_${port_id} integer 2
	        set_parameter_property AVL_NUM_SYMBOLS_PORT_${port_id} DERIVED TRUE
	        set_parameter_property AVL_NUM_SYMBOLS_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter LSB_WFIFO_PORT_${port_id} integer 5
	        set_parameter_property LSB_WFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property LSB_WFIFO_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter MSB_WFIFO_PORT_${port_id} integer 5
	        set_parameter_property MSB_WFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property MSB_WFIFO_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter LSB_RFIFO_PORT_${port_id} integer 5
	        set_parameter_property LSB_RFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property LSB_RFIFO_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter MSB_RFIFO_PORT_${port_id} integer 5
	        set_parameter_property MSB_RFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property MSB_RFIFO_PORT_${port_id} VISIBLE false
        }

	::alt_mem_if::util::hwtcl_utils::_add_parameter ALLOCATED_RFIFO_PORT string_list "0 None None None None None"
	set_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME "Allocated Read-Data FIFO"
	set_parameter_property ALLOCATED_RFIFO_PORT DESCRIPTION "Indicate which group of Asychronous FIFO being allocated for the specific active port to buffer the read data.
        Depending on the Port 'Width' and 'Type', the allocated FIFO maybe set to either F0-F3, F0-F1, F2-F3, F0, F1, F2 or F3.
        The active port should never being assigned to None (which indicate the overall Port configuration is illegal and would not be honored) unless the Port 'Type' is set to Write-Only."

	::alt_mem_if::util::hwtcl_utils::_add_parameter ALLOCATED_WFIFO_PORT string_list "0 None None None None None"
	set_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME "Allocated Write-Data FIFO"
	set_parameter_property ALLOCATED_WFIFO_PORT DESCRIPTION "Indicate which group of Asychronous FIFO being allocated for the specific active port to buffer the write data. 
        Depending on the Port 'Width' and 'Type', the allocated FIFO maybe set to either F0-F3, F0-F1, F2-F3, F0, F1, F2 or F3.
        The active port should never being assigned to None (which indicate the overall Port configuration is illegal and would not be honored) unless the Port 'Type' is set to Read-Only."

        if {[::alt_mem_if::util::qini::cfg_is_on uniphy_overwrite_auto_fifo_mapping]} {
                set_parameter_property ALLOCATED_RFIFO_PORT DERIVED false
                set_parameter_property ALLOCATED_WFIFO_PORT DERIVED false
                set_parameter_property ALLOCATED_RFIFO_PORT ALLOWED_RANGES {"F0-F3" "F0-F1" "F2-F3" "F0" "F1" "F2" "F3" "None"}
                set_parameter_property ALLOCATED_WFIFO_PORT ALLOWED_RANGES {"F0-F3" "F0-F1" "F2-F3" "F0" "F1" "F2" "F3" "None"}
        } else {
                set_parameter_property ALLOCATED_RFIFO_PORT DERIVED true
                set_parameter_property ALLOCATED_WFIFO_PORT DERIVED true
        }

        _create_hmc_atom_derived_parameters
}

proc ::alt_mem_if::gui::ddrx_controller::_create_controller_parameters {} {

	_dprint 1 "Preparing to create controller parameters in DDRX controller"

	::alt_mem_if::util::hwtcl_utils::_add_parameter POWER_OF_TWO_BUS boolean false
	set_parameter_property POWER_OF_TWO_BUS DISPLAY_NAME "Generate power-of-2 data bus widths for Qsys or SOPC Builder"
	set_parameter_property POWER_OF_TWO_BUS DESCRIPTION "This option must be enabled if this core is to be used in a Qsys or SOPC Builder system.  When turned on, the Avalon-MM side data bus width is rounded down to the nearest power of 2."
	set_parameter_property POWER_OF_TWO_BUS AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter SOPC_COMPAT_RESET boolean false
	set_parameter_property SOPC_COMPAT_RESET DISPLAY_NAME "Generate SOPC Builder compatible resets"
	set_parameter_property SOPC_COMPAT_RESET DESCRIPTION "This option must be enabled if this core is to be used in an SOPC Builder system.  When turned on, the reset inputs become associated with the PLL reference clock and the paths must be cut."
	set_parameter_property SOPC_COMPAT_RESET AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_MAX_SIZE String 4
	set_parameter_property AVL_MAX_SIZE DISPLAY_NAME "Maximum Avalon-MM burst length"
	set_parameter_property AVL_MAX_SIZE DESCRIPTION "Specifies the maximum burst length on the Avalon-MM bus."
	set_parameter_property AVL_MAX_SIZE AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter BYTE_ENABLE boolean true
	set_parameter_property BYTE_ENABLE DISPLAY_NAME "Enable Avalon-MM byte-enable signal"
	set_parameter_property BYTE_ENABLE DESCRIPTION "When turned on, the controller will add the byte-enable signal for the Avalon-MM bus"
	set_parameter_property BYTE_ENABLE AFFECTS_ELABORATION true

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_CTRL_AVALON_INTERFACE boolean true
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE DISPLAY_NAME "Enable Avalon interface"
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE VISIBLE false
	set_parameter_property ENABLE_CTRL_AVALON_INTERFACE AFFECTS_ELABORATION true


	
	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_DEEP_POWERDN_EN Boolean false
	set_parameter_property CTL_DEEP_POWERDN_EN DISPLAY_NAME "Enable Deep Power-Down Controls"
	set_parameter_property CTL_DEEP_POWERDN_EN DESCRIPTION "Select this option to enable the Deep-Powerdown signals on the controller top level. These controls allow you to control when the memory is placed into Deep-Powerdown mode."
	set_parameter_property CTL_DEEP_POWERDN_EN DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_SELF_REFRESH_EN Boolean false
	set_parameter_property CTL_SELF_REFRESH_EN DISPLAY_NAME "Enable Self-Refresh Controls"
	set_parameter_property CTL_SELF_REFRESH_EN DESCRIPTION "Select this option to enable the self-refresh signals on the controller top level. These controls allow you to control when the memory is placed into self-refresh mode."
	set_parameter_property CTL_SELF_REFRESH_EN VISIBLE true
	set_parameter_property CTL_SELF_REFRESH_EN DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter AUTO_POWERDN_EN Boolean false
	set_parameter_property AUTO_POWERDN_EN DISPLAY_NAME "Enable Auto Power-Down"
	set_parameter_property AUTO_POWERDN_EN DESCRIPTION "Select this option to allow the controller to automatically place the memory into power down mode after a specified number of idle cycles. You can specify the number of idle cycles after which the controller powers down the memory in the Auto Power-Down Cycles box below."
	set_parameter_property AUTO_POWERDN_EN VISIBLE true
	set_parameter_property AUTO_POWERDN_EN DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter AUTO_PD_CYCLES Integer 0
	set_parameter_property AUTO_PD_CYCLES DISPLAY_NAME "Auto Power-Down Cycles"
	set_parameter_property AUTO_PD_CYCLES DESCRIPTION "The number of idle controller clock cycles after which the controller automatically powers down the memory. The legal range is from 1 to 65,535 controller clock cycles."
	set_parameter_property AUTO_PD_CYCLES VISIBLE true
	set_parameter_property AUTO_PD_CYCLES DISPLAY_HINT columns:10
	set_parameter_property AUTO_PD_CYCLES UNITS Cycles
	set_parameter_property AUTO_PD_CYCLES ALLOWED_RANGES {0:65535}

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_USR_REFRESH_EN Boolean false
	set_parameter_property CTL_USR_REFRESH_EN DISPLAY_NAME "Enable User Auto-Refresh Controls"
	set_parameter_property CTL_USR_REFRESH_EN DESCRIPTION "Select this option to enable the user auto-refresh control signals on the controller top level. These controller signals allow you to control when the controller issues memory auto-refresh commands."
	set_parameter_property CTL_USR_REFRESH_EN VISIBLE true
	set_parameter_property CTL_USR_REFRESH_EN DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_AUTOPCH_EN Boolean false
	set_parameter_property CTL_AUTOPCH_EN DISPLAY_NAME "Enable Auto-Precharge Control"
	set_parameter_property CTL_AUTOPCH_EN DESCRIPTION "Select this option to enable the auto-precharge control on the controller top level. Asserting the auto-precharge control signal while requesting a read or write burst allows you to specify whether or not the controller should close (auto-precharge) the currently open page at the end of the read or write burst."
	set_parameter_property CTL_AUTOPCH_EN VISIBLE true
	set_parameter_property CTL_AUTOPCH_EN DISPLAY_HINT boolean

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_pingpong_ctl]} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ZQCAL_EN Boolean true
		set_parameter_property CTL_ZQCAL_EN VISIBLE true
	} else {
		::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ZQCAL_EN Boolean false
		set_parameter_property CTL_ZQCAL_EN VISIBLE false
	}
	set_parameter_property CTL_ZQCAL_EN DISPLAY_NAME "Enable ZQ Calibration Control"
	set_parameter_property CTL_ZQCAL_EN DESCRIPTION "Select this option to enable the ZQ calibration control on the controller top level. Asserting the ZQ calibration request signal allows you to send a ZQ calibration command to the memory device."

	set_parameter_property CTL_ZQCAL_EN DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter ADDR_ORDER Integer 0
	set_parameter_property ADDR_ORDER DISPLAY_NAME "Local-to-Memory Address Mapping"
	set_parameter_property ADDR_ORDER DESCRIPTION "This option allows you to control the mapping between the address bits on the Avalon interface and the chip, row, bank and column bits on the memory."
	set_parameter_property ADDR_ORDER VISIBLE true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_LOOK_AHEAD_DEPTH Integer 4
	set_parameter_property CTL_LOOK_AHEAD_DEPTH DISPLAY_NAME "Command Queue Look-Ahead Depth"
	set_parameter_property CTL_LOOK_AHEAD_DEPTH DESCRIPTION "Select a look-ahead depth value to control how many read or writes requests the look-ahead bank management logic examines. Larger numbers are likely to increase the efficiency of the bank management, but at the cost of higher resource usage. Smaller values may be less efficient, but also use fewer resources."
	set_parameter_property CTL_LOOK_AHEAD_DEPTH VISIBLE true

	::alt_mem_if::util::hwtcl_utils::_add_parameter CONTROLLER_LATENCY String 5
	set_parameter_property CONTROLLER_LATENCY DISPLAY_NAME "Reduce Controller Latency By"
	set_parameter_property CONTROLLER_LATENCY DESCRIPTION "Select the number of controller latency to be reduce in controller clock cycles for better latency or fmax.
	Lower latency controller would not be able to run as fast as the default frequency.
	Refer to the External Memory Interface handbook for supported latency and maximum frequency combination."
	set_parameter_property CONTROLLER_LATENCY DISPLAY_HINT columns:10
	set_parameter_property CONTROLLER_LATENCY ALLOWED_RANGES {"4:1" "5:0"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_REORDER_DATA Boolean true
	set_parameter_property CFG_REORDER_DATA DISPLAY_NAME "Enable Reordering"
	set_parameter_property CFG_REORDER_DATA DESCRIPTION "Select this option to allow the controller to perform Command and Data Reordering to achieve the highest possible efficiency"
	set_parameter_property CFG_REORDER_DATA DISPLAY_HINT columns:10

	::alt_mem_if::util::hwtcl_utils::_add_parameter STARVE_LIMIT Integer 10
	set_parameter_property STARVE_LIMIT DISPLAY_NAME "Starvation limit for each command"
	set_parameter_property STARVE_LIMIT DESCRIPTION "Specify the number of commands that can be served before a starved command. The legal range is from 1 to 63 commands."
	set_parameter_property STARVE_LIMIT DISPLAY_HINT columns:10
	set_parameter_property STARVE_LIMIT ALLOWED_RANGES {1:63}
	set_parameter_property STARVE_LIMIT DISPLAY_UNITS "commands"

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CSR_ENABLED Boolean false
	set_parameter_property CTL_CSR_ENABLED DISPLAY_NAME "Enable Configuration and Status Register Interface"
	set_parameter_property CTL_CSR_ENABLED DESCRIPTION "Select this option to enable run-time configuration and status of the memory controller. Enabling this option adds an additional Avalon Memory-Mapped slave port to the memory controller top level. Using this slave port, you can change or read out the memory timing parameters, memory address sizes, mode register settings and controller status. If Error Detection and Correction Logic are enabled, the same slave port also allows you to control and retrieve the status of this logic."
	set_parameter_property CTL_CSR_ENABLED VISIBLE true
	set_parameter_property CTL_CSR_ENABLED DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CSR_CONNECTION STRING "INTERNAL_JTAG"
	set_parameter_property CTL_CSR_CONNECTION DISPLAY_NAME "CSR port host interface"
	set_parameter_property CTL_CSR_CONNECTION DESCRIPTION "Specifies the connection type to CSR port. The port can be exported, internally connected to a JTAG Avalon Master, or both"
	set_parameter_property CTL_CSR_CONNECTION UNITS None
	set_parameter_property CTL_CSR_CONNECTION ALLOWED_RANGES {"INTERNAL_JTAG:Internal (JTAG)" "EXPORT:Avalon-MM Slave" "SHARED:Shared"}

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ECC_ENABLED Boolean false
	set_parameter_property CTL_ECC_ENABLED DISPLAY_NAME "Enable Error Detection and Correction Logic"
	set_parameter_property CTL_ECC_ENABLED DESCRIPTION "Select this option to enable Error Correction Code (ECC) for single-bit error correction and double-bit error detection. Your memory interface must be a multiple of 40 or 72 bits wide in order to be able to use ECC."
	set_parameter_property CTL_ECC_ENABLED VISIBLE true
	set_parameter_property CTL_ECC_ENABLED DISPLAY_HINT boolean
	
	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_HRB_ENABLED Boolean false
	set_parameter_property CTL_HRB_ENABLED DISPLAY_NAME "Enable half rate bridge"
	set_parameter_property CTL_HRB_ENABLED DESCRIPTION "Select this option to enable Half Rate Bridge block"
	set_parameter_property CTL_HRB_ENABLED DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ECC_AUTO_CORRECTION_ENABLED Boolean false
	set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_NAME "Enable Auto Error Correction"
	set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DESCRIPTION "Select this option to allow the controller to perform auto correction when a single-bit error has been detected by the ECC logic."
	set_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter MULTICAST_EN Boolean false
	set_parameter_property MULTICAST_EN DISPLAY_NAME "Enable Multi-cast Write Control"
	set_parameter_property MULTICAST_EN DESCRIPTION "Select this option to enable the multi-cast write control on the controller top level. Multi-cast write is not supported if the ECC logic is enabled or for registered DIMM interfaces."
	set_parameter_property MULTICAST_EN DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_DYNAMIC_BANK_ALLOCATION Boolean false
	set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_NAME "Enable reduced bank tracking for area optimization"
	set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DESCRIPTION "Select this option to reduce the number of bank and timer blocks in the controller. Specify the number of banks to track in the \"Number of banks to track\" box below."
	set_parameter_property CTL_DYNAMIC_BANK_ALLOCATION DISPLAY_HINT boolean

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_DYNAMIC_BANK_NUM Integer 4
	set_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_NAME "Number of banks to track"
	set_parameter_property CTL_DYNAMIC_BANK_NUM DESCRIPTION "Specify the number of banks to track when \"Enable reduced bank tracking for area optimization\" is enabled. The legal range is from 1 or the value of Command Queue Look-Ahead depth (whichever is greater) to 16."
	set_parameter_property CTL_DYNAMIC_BANK_NUM DISPLAY_HINT columns:10


	::alt_mem_if::util::hwtcl_utils::_add_parameter DEBUG_MODE Boolean false
	set_parameter_property DEBUG_MODE DISPLAY_NAME "Enable internal debug parameter"
	set_parameter_property DEBUG_MODE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_BURST_MERGE Boolean false
	set_parameter_property ENABLE_BURST_MERGE DISPLAY_NAME "Enable burst merging"
	set_parameter_property ENABLE_BURST_MERGE VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ENABLE_BURST_INTERRUPT Boolean false
	set_parameter_property CTL_ENABLE_BURST_INTERRUPT DISPLAY_NAME "Enable burst interrupt"
	set_parameter_property CTL_ENABLE_BURST_INTERRUPT VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_ENABLE_BURST_TERMINATE Boolean false
	set_parameter_property CTL_ENABLE_BURST_TERMINATE DISPLAY_NAME "Enable burst terminate"
	set_parameter_property CTL_ENABLE_BURST_TERMINATE VISIBLE false

	add_parameter NEXTGEN Boolean true
	set_parameter_property NEXTGEN DISPLAY_NAME "Enable 11.0 extra controller features"
	set_parameter_property NEXTGEN DESCRIPTION "Deselect this option if you are upgrading a pre-11.0 design to retain the expected original controller features."
	set_parameter_property NEXTGEN DISPLAY_HINT boolean
	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_display_extra_parameters_gui]} {
		set_parameter_property NEXTGEN VISIBLE true
	} else {
		set_parameter_property NEXTGEN VISIBLE false
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter LOCAL_ID_WIDTH Integer 8
	set_parameter_property LOCAL_ID_WIDTH DISPLAY_NAME "Local ID width"
	set_parameter_property LOCAL_ID_WIDTH VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter RDBUFFER_ADDR_WIDTH Integer 6
	set_parameter_property RDBUFFER_ADDR_WIDTH DISPLAY_NAME "Read buffer address width"
	set_parameter_property RDBUFFER_ADDR_WIDTH VISIBLE false
	set_parameter_property RDBUFFER_ADDR_WIDTH DERIVED true

	::alt_mem_if::util::hwtcl_utils::_add_parameter WRBUFFER_ADDR_WIDTH Integer 6
	set_parameter_property WRBUFFER_ADDR_WIDTH DISPLAY_NAME "Write buffer address width"
	set_parameter_property WRBUFFER_ADDR_WIDTH VISIBLE false

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_pingpong_ctl]} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter MAX_PENDING_WR_CMD Integer 32
		::alt_mem_if::util::hwtcl_utils::_add_parameter MAX_PENDING_RD_CMD Integer 32
	} else {
	    ::alt_mem_if::util::hwtcl_utils::_add_parameter MAX_PENDING_WR_CMD Integer 16
	    ::alt_mem_if::util::hwtcl_utils::_add_parameter MAX_PENDING_RD_CMD Integer 32
	}
	set_parameter_property MAX_PENDING_RD_CMD DISPLAY_NAME "Max pending read commands"
	set_parameter_property MAX_PENDING_RD_CMD VISIBLE false
	set_parameter_property MAX_PENDING_WR_CMD DISPLAY_NAME "Max pending write commands"
	set_parameter_property MAX_PENDING_WR_CMD VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_MM_ADAPTOR Boolean true
	set_parameter_property USE_MM_ADAPTOR DISPLAY_NAME "Use Avalon MM Adaptor"
	set_parameter_property USE_MM_ADAPTOR VISIBLE false

	::alt_mem_if::util::hwtcl_utils::_add_parameter USE_AXI_ADAPTOR Boolean false
	set_parameter_property USE_AXI_ADAPTOR DISPLAY_NAME "Use AXI Adaptor"
	set_parameter_property USE_AXI_ADAPTOR VISIBLE false

	add_parameter HCX_COMPAT_MODE boolean false
	set_parameter_property HCX_COMPAT_MODE VISIBLE false
	set_parameter_property HCX_COMPAT_MODE DISPLAY_NAME "HardCopy Compatibility Mode"
	set_parameter_property HCX_COMPAT_MODE DESCRIPTION "When turned on, the UniPHY memory interface generated has all required HardCopy compatibility options enabled. For example PLLs and DLLs will have their reconfiguration ports exposed."

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CMD_QUEUE_DEPTH Integer 8
	set_parameter_property CTL_CMD_QUEUE_DEPTH VISIBLE false
	set_parameter_property CTL_CMD_QUEUE_DEPTH DERIVED false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CTL_CSR_READ_ONLY Integer 1
	set_parameter_property CTL_CSR_READ_ONLY VISIBLE false
	set_parameter_property CTL_CSR_READ_ONLY DERIVED false

	::alt_mem_if::util::hwtcl_utils::_add_parameter CFG_DATA_REORDERING_TYPE String "INTER_BANK"
	set_parameter_property CFG_DATA_REORDERING_TYPE DISPLAY_NAME "Reordering type"
	set_parameter_property CFG_DATA_REORDERING_TYPE VISIBLE false
	set_parameter_property CFG_DATA_REORDERING_TYPE ALLOWED_RANGES {"INTER_ROW" "INTER_BANK"}


	::alt_mem_if::util::hwtcl_utils::_add_parameter NUM_OF_PORTS Integer 1
	set_parameter_property NUM_OF_PORTS DISPLAY_NAME "Number of ports"
	set_parameter_property NUM_OF_PORTS DESCRIPTION "Specifies the number of Avalon-MM Slave port to be exported."
	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		_dprint 1 "NUM_OF_PORTS: setting range and default to 0"
	} else {
		set_parameter_property NUM_OF_PORTS ALLOWED_RANGES {1 2 3 4 5 6}
		_dprint 1 "NUM_OF_PORTS: setting range and default to normal values"
	}

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_BONDING Boolean false
	set_parameter_property ENABLE_BONDING DISPLAY_NAME "Export bonding interface"
	set_parameter_property ENABLE_BONDING DESCRIPTION "Select this option to export bonding interface for wider avalon data width."

	::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_USER_ECC Boolean false
	set_parameter_property ENABLE_USER_ECC DISPLAY_NAME "Expand Avalon-MM data for ECC"
	set_parameter_property ENABLE_USER_ECC DESCRIPTION "Turn on this option to allow wider Avalon-MM data widths to support user error correction code bits."

	::alt_mem_if::util::hwtcl_utils::_add_parameter AVL_DATA_WIDTH_PORT integer_list "32 32 32 32 32 32"
	set_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME "Width"
	set_parameter_property AVL_DATA_WIDTH_PORT DESCRIPTION "Specifies the data width for each Avalon-MM Slave port."
	set_parameter_property AVL_DATA_WIDTH_PORT ALLOWED_RANGES {32 48 64 80 128 160 256 320}

	::alt_mem_if::util::hwtcl_utils::_add_parameter PRIORITY_PORT integer_list "1 1 1 1 1 1"
	set_parameter_property PRIORITY_PORT DISPLAY_NAME "Priority"
	set_parameter_property PRIORITY_PORT DESCRIPTION "Specifies the absolute priority for each Avalon-MM Slave port. Any transaction from the port with higher (bigger number) priority will always be serve before transactions from the port with lower (smaller number) priority."

	::alt_mem_if::util::hwtcl_utils::_add_parameter WEIGHT_PORT integer_list "0 0 0 0 0 0"
	set_parameter_property WEIGHT_PORT DISPLAY_NAME "Weight"
	set_parameter_property WEIGHT_PORT DESCRIPTION "Specifies the relative priority for each Avalon-MM Slave port. When two or more ports having same absolute priority, the transaction from the port with higher (bigger number) relative priority will always be serve first."
	set_parameter_property WEIGHT_PORT ALLOWED_RANGES 0:31

	::alt_mem_if::util::hwtcl_utils::_add_parameter CPORT_TYPE_PORT string_list "Bidirectional Bidirectional Bidirectional Bidirectional Bidirectional Bidirectional"
	set_parameter_property CPORT_TYPE_PORT DISPLAY_NAME "Type"
	set_parameter_property CPORT_TYPE_PORT DESCRIPTION "Specifies whether each Avalon-MM Slave port is use for read only port, write only port or Bidirectional port."
        set_parameter_property CPORT_TYPE_PORT ALLOWED_RANGES {"Write-only" "Read-only" "Bidirectional"}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {

                ::alt_mem_if::util::hwtcl_utils::_add_parameter MMRD_ENABLED Boolean false
                set_parameter_property MMRD_ENABLED DISPLAY_NAME "Enable MMR Driver"

                ::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_UNIX_ID_ALLPORT Boolean false
                set_parameter_property ENABLE_UNIX_ID_ALLPORT DISPLAY_NAME "Enable Unix ID for all port"

                ::alt_mem_if::util::hwtcl_utils::_add_parameter USE_SYNC_READY_ALLPORT Boolean false
                set_parameter_property USE_SYNC_READY_ALLPORT DISPLAY_NAME "Use Synchronize Ready for all port"

                for {set port_id 0} {$port_id != 6} {incr port_id} {

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_UNIX_ID_${port_id} Boolean false
                        set_parameter_property ENABLE_UNIX_ID_${port_id} DISPLAY_NAME "Enable Unix ID"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USE_UNIX_ID_${port_id} Integer ${port_id}
                        set_parameter_property USE_UNIX_ID_${port_id} DISPLAY_NAME "Unix ID"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USE_SYNC_READY_${port_id} Boolean false
                        set_parameter_property USE_SYNC_READY_${port_id} DISPLAY_NAME "Use Synchronize Ready"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_ADDR_ENABLED_${port_id} Boolean false
                        set_parameter_property USER_ADDR_ENABLED_${port_id} DISPLAY_NAME "Enable User Input Address"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_ADDR_FILE_${port_id} String "example_input_file.hex"
                        set_parameter_property USER_ADDR_FILE_${port_id} DISPLAY_NAME "Input filename"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_ADDR_BINARY_${port_id} Boolean false
                        set_parameter_property USER_ADDR_BINARY_${port_id} DISPLAY_NAME "Input is in Binary"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_ADDR_DEPTH_${port_id} Integer 10
                        set_parameter_property USER_ADDR_DEPTH_${port_id} DISPLAY_NAME "Input depth"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_DATA_ENABLED_${port_id} Boolean false
                        set_parameter_property USER_DATA_ENABLED_${port_id} DISPLAY_NAME "Enable User Input Write / Expected Read Data"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_DATA_FILE_${port_id} String "example_input_file.hex"
                        set_parameter_property USER_DATA_FILE_${port_id} DISPLAY_NAME "Input filename"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_DATA_BINARY_${port_id} Boolean false
                        set_parameter_property USER_DATA_BINARY_${port_id} DISPLAY_NAME "Input is in binary"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter USER_DATA_DEPTH_${port_id} Integer 10
                        set_parameter_property USER_DATA_DEPTH_${port_id} DISPLAY_NAME "Input depth"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_READ_ONLY_COMPARE_${port_id} Boolean false
                        set_parameter_property ENABLE_READ_ONLY_COMPARE_${port_id} DISPLAY_NAME "Enable compare"

                        ::alt_mem_if::util::hwtcl_utils::_add_parameter TURN_PORT_${port_id} Integer 0
                        set_parameter_property TURN_PORT_${port_id} DISPLAY_NAME "Service turn"
                        set_parameter_property TURN_PORT_${port_id} DESCRIPTION "Specify the turn when the driver for this port should be serve. (0 will be the earlieast and same number indicate the driver will be served at same time)"
                        set_parameter_property TURN_PORT_${port_id} ALLOWED_RANGES {0 1 2 3 4 5 6 7 8 9 10 11}

                }

	}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_refctrl]} {
		::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_REFCTRL Boolean true
		set_parameter_property ENABLE_REFCTRL DISPLAY_NAME "Enable refresh controller interface"
		set_parameter_property ENABLE_REFCTRL DESCRIPTION "Enable refresh controller interface"
		set_parameter_property ENABLE_REFCTRL VISIBLE true
	}

        return 1
}


proc ::alt_mem_if::gui::ddrx_controller::_create_controller_parameters_gui {is_top_standalone} {

	_dprint 1 "Preparing to create controller GUI in ddrx_controller"

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {

		variable parameters

		foreach param $parameters {
			set_parameter_property $param Visible false
		}
		
		return
	}
	
	add_display_item "Interface Type" "Controller Settings" GROUP "tab"

	if {$is_top_standalone} {
		add_display_item "Controller Settings" RATE PARAMETER
		add_display_item "Controller Settings" MEM_CLK_FREQ PARAMETER
		add_display_item "Controller Settings" SPEED_GRADE PARAMETER
	}

	add_display_item "Controller Settings" "Avalon Interface" GROUP
	add_display_item "Avalon Interface" POWER_OF_TWO_BUS PARAMETER
	add_display_item "Avalon Interface" SOPC_COMPAT_RESET PARAMETER
	add_display_item "Avalon Interface" AVL_MAX_SIZE PARAMETER
	add_display_item "Avalon Interface" BYTE_ENABLE PARAMETER
	add_display_item "Avalon Interface" AVL_ADDR_WIDTH parameter
	add_display_item "Avalon Interface" AVL_DATA_WIDTH parameter

	add_display_item "Controller Settings" "Low Power Mode" GROUP
	add_display_item "Low Power Mode" CTL_SELF_REFRESH_EN parameter
	add_display_item "Low Power Mode" CTL_DEEP_POWERDN_EN parameter
	add_display_item "Low Power Mode" AUTO_POWERDN_EN parameter
	add_display_item "Low Power Mode" AUTO_PD_CYCLES parameter

	add_display_item "Controller Settings" "Efficiency" GROUP
	add_display_item "Efficiency" CTL_USR_REFRESH_EN parameter
	add_display_item "Efficiency" CTL_AUTOPCH_EN parameter
	add_display_item "Efficiency" ADDR_ORDER parameter
	add_display_item "Efficiency" CTL_LOOK_AHEAD_DEPTH parameter
	add_display_item "Efficiency" CONTROLLER_LATENCY parameter
	add_display_item "Efficiency" CTL_TBP_NUM parameter
	add_display_item "Efficiency" CFG_REORDER_DATA parameter
	add_display_item "Efficiency" STARVE_LIMIT parameter

	add_display_item "Controller Settings" "Configuration, Status and Error Handling" GROUP
	add_display_item "Configuration, Status and Error Handling" CTL_CSR_ENABLED parameter
	add_display_item "Configuration, Status and Error Handling" CTL_CSR_CONNECTION parameter
	add_display_item "Configuration, Status and Error Handling" CTL_ECC_ENABLED parameter
	add_display_item "Configuration, Status and Error Handling" CTL_ECC_AUTO_CORRECTION_ENABLED parameter

	add_display_item "Controller Settings" "Advanced Controller Features" GROUP
	add_display_item "Advanced Controller Features" CTL_HRB_ENABLED parameter
	add_display_item "Advanced Controller Features" MULTICAST_EN parameter
	add_display_item "Advanced Controller Features" CTL_DYNAMIC_BANK_ALLOCATION parameter
	add_display_item "Advanced Controller Features" CTL_DYNAMIC_BANK_NUM parameter
	add_display_item "Advanced Controller Features" NEXTGEN parameter

	add_display_item "Controller Settings" "Multiple Port Front End" GROUP
        add_display_item "Multiple Port Front End" ENABLE_BONDING parameter
        add_display_item "Multiple Port Front End" ENABLE_USER_ECC parameter
	add_display_item "Multiple Port Front End" NUM_OF_PORTS parameter

        add_display_item "Multiple Port Front End" "Port Group" GROUP TABLE
        add_display_item "Port Group" AVL_PORT parameter
        add_display_item "Port Group" CPORT_TYPE_PORT parameter
        add_display_item "Port Group" AVL_DATA_WIDTH_PORT parameter
	add_display_item "Port Group" PRIORITY_PORT parameter
        add_display_item "Port Group" WEIGHT_PORT parameter
        add_display_item "Port Group" ALLOCATED_WFIFO_PORT parameter
        add_display_item "Port Group" ALLOCATED_RFIFO_PORT parameter

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_pof_driver]} {

	        add_display_item "Controller Settings" "For POF Verification" GROUP
                add_display_item "For POF Verification" pofall TEXT "<html><b>Global Settings <em>(Will overwrite individual port settings)</em></b><br>"

                add_display_item "For POF Verification" MMRD_ENABLED parameter
                add_display_item "For POF Verification" MMRD_TOTAL_INSTANCE parameter

                add_display_item "For POF Verification" ENABLE_UNIX_ID_ALLPORT parameter
                add_display_item "For POF Verification" USE_SYNC_READY_ALLPORT parameter
                for {set port_id 0} {$port_id != 6} {incr port_id} {
                        add_display_item "For POF Verification" pof${port_id} TEXT "<html><b>Port ${port_id} </b><br>"

                        add_display_item "For POF Verification" pofA${port_id} TEXT "<html><em>Address Space Options:</em><br>"
                        add_display_item "For POF Verification" ENABLE_UNIX_ID_${port_id} parameter
                        add_display_item "For POF Verification" USE_UNIX_ID_${port_id} parameter

                        add_display_item "For POF Verification" pofB${port_id} TEXT "<html><em>Traffic Flow Options:</em><br>"
                        add_display_item "For POF Verification" USE_SYNC_READY_${port_id} parameter
                        add_display_item "For POF Verification" TURN_PORT_${port_id} parameter

                        add_display_item "For POF Verification" pofC${port_id} TEXT "<html><em>User Address Options :</em><br>"
                        add_display_item "For POF Verification" USER_ADDR_ENABLED_${port_id} parameter
                        add_display_item "For POF Verification" USER_ADDR_FILE_${port_id} parameter
                        add_display_item "For POF Verification" USER_ADDR_BINARY_${port_id} parameter
                        add_display_item "For POF Verification" USER_ADDR_DEPTH_${port_id} parameter

                        add_display_item "For POF Verification" pofD${port_id} TEXT "<html><em>User Data Options :</em><br>"
                        add_display_item "For POF Verification" USER_DATA_ENABLED_${port_id} parameter
                        add_display_item "For POF Verification" USER_DATA_FILE_${port_id} parameter
                        add_display_item "For POF Verification" USER_DATA_BINARY_${port_id} parameter
                        add_display_item "For POF Verification" USER_DATA_DEPTH_${port_id} parameter

                        add_display_item "For POF Verification" pofE${port_id} TEXT "<html><em>Read Only Options :</em><br>"
                        add_display_item "For POF Verification" ENABLE_READ_ONLY_COMPARE_${port_id} parameter
                }

	}
	return 1
}

proc ::alt_mem_if::gui::ddrx_controller::_create_interface_parameters_gui {} {

	_dprint 1 "Preparing to create interface GUI in ddrx_controller"

	if {[::alt_mem_if::util::hwtcl_utils::is_hps_top]} {
		return 1
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
	set_parameter_property AFI_CLK_EN_WIDTH VISIBLE true
	set_parameter_property AFI_DM_WIDTH VISIBLE true
	set_parameter_property AFI_DQ_WIDTH VISIBLE true
	add_display_item "AFI Interface" AFI_ADDR_WIDTH PARAMETER
	add_display_item "AFI Interface" AFI_CS_WIDTH PARAMETER
	add_display_item "AFI Interface" AFI_CLK_EN_WIDTH PARAMETER
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


proc ::alt_mem_if::gui::ddrx_controller::_derive_parameters {} {

	set protocol [_get_protocol]

	_dprint 1 "Preparing to derive parametres for DDRX controller"

    set hrb_factor [expr {([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0) ? 2 : 1}]


    set_parameter_value DWIDTH_RATIO [expr {[get_parameter_value AFI_RATE_RATIO] * [get_parameter_value DATA_RATE_RATIO]}]






    if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0 && [get_parameter_value DWIDTH_RATIO] == 2} {
        set minus_col_bit 2
    } elseif {([string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0 && [get_parameter_value DWIDTH_RATIO] == 4) || ([get_parameter_value DWIDTH_RATIO] == 8)} {
        set minus_col_bit 3
    } else {
        set minus_col_bit [expr {[get_parameter_value DWIDTH_RATIO] / 2}]
    }

	if {[regexp {^DDR3$} $protocol] == 1 && ([string compare -nocase [get_parameter_value MEM_FORMAT] "registered"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
        set_parameter_value AVL_ADDR_WIDTH [expr {[_log2 [get_parameter_value MEM_IF_NUMBER_OF_RANKS]]
		                                               + [get_parameter_value MEM_IF_ROW_ADDR_WIDTH]
		                                               + [get_parameter_value MEM_IF_BANKADDR_WIDTH]
		                                               + [get_parameter_value MEM_IF_COL_ADDR_WIDTH] - $minus_col_bit}]
    } else {
        set_parameter_value AVL_ADDR_WIDTH [expr {[_log2 [get_parameter_value MEM_IF_CS_WIDTH]]
		                                               + [get_parameter_value MEM_IF_ROW_ADDR_WIDTH]
		                                               + [get_parameter_value MEM_IF_BANKADDR_WIDTH]
		                                               + [get_parameter_value MEM_IF_COL_ADDR_WIDTH] - $minus_col_bit}]
    }




    set local_data_width 0
    set multiples_16_24_40_72 1
    if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0} {
        if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
            set local_data_width [expr {2 * [get_parameter_value MEM_IF_DQ_WIDTH] * [get_parameter_value DWIDTH_RATIO]}]
        } else {
            set local_data_width [expr {[get_parameter_value MEM_IF_DQ_WIDTH] * [get_parameter_value DWIDTH_RATIO]}]
        }
    } else {

        set div_16 [expr [get_parameter_value MEM_IF_DQ_WIDTH] % 16]
        set div_24 [expr [get_parameter_value MEM_IF_DQ_WIDTH] % 24]
        set div_40 [expr [get_parameter_value MEM_IF_DQ_WIDTH] % 40]
        set div_72 [expr [get_parameter_value MEM_IF_DQ_WIDTH] % 72]
        if {$div_72 == 0} {
            set local_data_width [expr ([get_parameter_value MEM_IF_DQ_WIDTH] - (8 * [get_parameter_value MEM_IF_DQ_WIDTH] / 72)) * [get_parameter_value DWIDTH_RATIO] * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_IF_DQ_WIDTH] / 72]
        } elseif {$div_40 == 0} {
            set local_data_width [expr ([get_parameter_value MEM_IF_DQ_WIDTH] - (8 * [get_parameter_value MEM_IF_DQ_WIDTH] / 40)) * [get_parameter_value DWIDTH_RATIO] * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_IF_DQ_WIDTH] / 40]
        } elseif {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ($div_24 == 0)} {
            set local_data_width [expr ([get_parameter_value MEM_IF_DQ_WIDTH] - (8 * [get_parameter_value MEM_IF_DQ_WIDTH] / 24)) * [get_parameter_value DWIDTH_RATIO] * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_IF_DQ_WIDTH] / 24]
        } elseif {([string compare -nocase [get_parameter_value CONTROLLER_TYPE] "nextgen_v110"] == 0) && ($div_16 == 0)} {
            set local_data_width [expr ([get_parameter_value MEM_IF_DQ_WIDTH] - (8 * [get_parameter_value MEM_IF_DQ_WIDTH] / 16)) * [get_parameter_value DWIDTH_RATIO] * $hrb_factor]
            set multiples_16_24_40_72 [expr  [get_parameter_value MEM_IF_DQ_WIDTH] / 16]
        } else {
        	set local_data_width [expr {[get_parameter_value MEM_IF_DQ_WIDTH] * [get_parameter_value DWIDTH_RATIO] * $hrb_factor}]
	    	set multiples_16_24_40_72 0
		}
    }

	if {[string compare -nocase [get_parameter_value POWER_OF_TWO_BUS] "true"] == 0} {
		set local_data_width [expr {int(pow(2,(int(floor(log($local_data_width)/log(2))))))}]
		_dprint 1 "Updating AVL_DATA_WIDTH = $local_data_width because of power-of-two bus width"
	}

    set_parameter_value AVL_DATA_WIDTH $local_data_width
    set_parameter_value CTL_ECC_MULTIPLES_40_72 $multiples_16_24_40_72
    set_parameter_value CTL_ECC_MULTIPLES_16_24_40_72 $multiples_16_24_40_72

	set_parameter_value AVL_BE_WIDTH [expr {int([get_parameter_value AVL_DATA_WIDTH] / 8)}]

	set_parameter_value AVL_NUM_SYMBOLS [expr {int([get_parameter_value AVL_DATA_WIDTH] / 8)}]

	set_parameter_value AVL_SIZE_WIDTH [expr {int(ceil(log([get_parameter_value AVL_MAX_SIZE]+1)/log(2)))}]



	if {([regexp {^DDR2$} $protocol] == 1 && [string compare -nocase [get_parameter_value MEM_RTT_NOM] "disabled"] != 0) ||
	    ([regexp {^DDR3$} $protocol] == 1 && (    ([string compare -nocase [get_parameter_value MEM_RTT_NOM] "odt disabled"] != 0)
											   || ([string compare -nocase [get_parameter_value MEM_RTT_WR] "dynamic odt off"] != 0)))} {
    	set_parameter_value CTL_ODT_ENABLED 1
    } else {
    	set_parameter_value CTL_ODT_ENABLED 0
	}


	if {[regexp {^DDR2$|^DDR3$} $protocol] == 1} {
		set mem_al [get_parameter_value MR1_AL]
	}

    set mem_twl 0
	if {[regexp {^DDR3$} $protocol] == 1} {
        set mem_twl [expr {[get_parameter_value MEM_WTCL_INT] + $mem_al}]
	} elseif {[regexp {^DDR2$} $protocol] == 1} {
        set mem_twl [expr [get_parameter_value MEM_TCL] - 1 + $mem_al]
    }

    if {[string compare -nocase [get_parameter_value MEM_FORMAT] "registered"] == 0} {
        set mem_twl [expr $mem_twl + 1]
    }

    if {[string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
        set mem_twl [expr $mem_twl + 4]
    }

    if {[string compare -nocase [get_parameter_value MEM_LEVELING] "true"] == 0} {
        set mem_twl [expr $mem_twl - 1]
    }

    if {[string compare -nocase [get_parameter_value RATE] "quarter"] == 0} {
        set afi_wlat [expr $mem_twl / ([get_parameter_value DWIDTH_RATIO] / 4)]
    } elseif {[string compare -nocase [get_parameter_value RATE] "half"] == 0} {
        set afi_wlat [expr $mem_twl / ([get_parameter_value DWIDTH_RATIO] / 2)]
    } else {
        set afi_wlat [expr $mem_twl - 1]
    }

    if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0 &&
	    ($afi_wlat > 1 || ($afi_wlat == 1 && [string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "false"] == 0))} {
        incr afi_wlat -1
    }

	if {[regexp {^DDR2$} $protocol] == 1 &&
		[get_parameter_value MEM_TCL] == 3 &&
	    [string compare -nocase [get_parameter_value MEM_RTT_NOM] "disabled"] != 0} {
        set_parameter_value CTL_OUTPUT_REGD true
	} elseif {$afi_wlat == 0} {
        set_parameter_value CTL_OUTPUT_REGD true
	} elseif {$afi_wlat == 1 && [string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
        set_parameter_value CTL_OUTPUT_REGD true
	} else {
		set_parameter_value CTL_OUTPUT_REGD false
    }



    if {([string compare -nocase [get_parameter_value MEM_FORMAT] "registered"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
        set_parameter_value CTL_REGDIMM_ENABLED true
    } else {
        set_parameter_value CTL_REGDIMM_ENABLED false
    }
	



    if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
        set_parameter_value CTL_ECC_CSR_ENABLED true
    } else {
        set_parameter_value CTL_ECC_CSR_ENABLED false
    }



    if {[get_parameter_value CONTROLLER_LATENCY] < 5} {
        set_parameter_value LOW_LATENCY true
    } else {
        set_parameter_value LOW_LATENCY false
    }


    set_parameter_value CTL_TBP_NUM [get_parameter_value CTL_LOOK_AHEAD_DEPTH]



    if {[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {
        set_parameter_value CONTROLLER_TYPE "nextgen_v110"
    } else {
        set_parameter_value CONTROLLER_TYPE "ddrx"
    }


    set_parameter_value EXPORT_CSR_PORT false
    if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
            set_parameter_property CTL_CSR_CONNECTION ENABLED true

            if {[string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "export"] == 0 ||
                [string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "shared"] == 0} {
                    set_parameter_value EXPORT_CSR_PORT true
            }

    } else {
        set_parameter_property CTL_CSR_CONNECTION ENABLED false
    }

    if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
        set_parameter_value CTL_USR_REFRESH 1
    } else {
        set_parameter_value CTL_USR_REFRESH 0
    }

    if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
        set_parameter_value CTL_SELF_REFRESH 1
    } else {
        set_parameter_value CTL_SELF_REFRESH 0
    }


    if {[string compare -nocase [get_parameter_value NEXTGEN] "true"] == 0} {

		if {[regexp {^DDR1$} $protocol] == 1} {
			set_parameter_value CFG_TYPE 0
		} elseif {[regexp {^DDR2$} $protocol] == 1} {
			set_parameter_value CFG_TYPE 1
		} elseif {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_value CFG_TYPE 2
		} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
			set_parameter_value CFG_TYPE 3
		} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
			set_parameter_value CFG_TYPE 4
		} else {
			_error "Protocol $protocol is not supported"
		}

		set_parameter_value CFG_INTERFACE_WIDTH [get_parameter_value MEM_IF_DQ_WIDTH]

		switch [get_parameter_value MEM_BURST_LENGTH] {
			2  {
				set_parameter_value CFG_BURST_LENGTH 2}
			4  {
				set_parameter_value CFG_BURST_LENGTH 4}
			8  {
				set_parameter_value CFG_BURST_LENGTH 8}
			16 {
				set_parameter_value CFG_BURST_LENGTH 16}
			default {_error "MEM_BURST_LENGTH=[get_parameter_value MEM_BURST_LENGTH] is not supported"}
		}

		switch [get_parameter_value ADDR_ORDER] {
			0 {
				set_parameter_value CFG_ADDR_ORDER 0}
			1 {
				set_parameter_value CFG_ADDR_ORDER 1}
			2 {
				set_parameter_value CFG_ADDR_ORDER 2}
			3 {
				set_parameter_value CFG_ADDR_ORDER 3}
			default {_error "ADDR_ORDER=[get_parameter_value ADDR_ORDER] is not supported"}
		}

		if {[regexp {^DDR3$} $protocol] == 1 && ([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0) } {
			set total_ranks [ expr [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM] * [get_parameter_value MEM_NUMBER_OF_DIMMS]]
			if {$total_ranks == 1} {
				set_parameter_value LOCAL_CS_WIDTH 0
			} elseif { $total_ranks == 2 } {
				set_parameter_value LOCAL_CS_WIDTH 1
			} elseif { ($total_ranks == 3 || $total_ranks == 4) } {
				set_parameter_value LOCAL_CS_WIDTH 2
			} elseif { ($total_ranks >= 5 || $total_ranks <= 8) } {
				set_parameter_value LOCAL_CS_WIDTH 3
			} elseif { ($total_ranks >= 9 || $total_ranks <= 16) } {
				set_parameter_value LOCAL_CS_WIDTH 4
			} else {
				_error "Total number of ranks (${total_ranks}) is not supported"
			}
		} else {
			if {[get_parameter_value MEM_IF_CS_WIDTH] == 1} {
				set_parameter_value LOCAL_CS_WIDTH 0
			} elseif {[get_parameter_value MEM_IF_CS_WIDTH] == 2} {
				set_parameter_value LOCAL_CS_WIDTH 1
			} elseif {[get_parameter_value MEM_IF_CS_WIDTH] == 3 || [get_parameter_value MEM_IF_CS_WIDTH] == 4} {
				set_parameter_value LOCAL_CS_WIDTH 2
			} elseif {[get_parameter_value MEM_IF_CS_WIDTH] >= 5 && [get_parameter_value MEM_IF_CS_WIDTH] <= 8} {
				set_parameter_value LOCAL_CS_WIDTH 3
			} elseif {[get_parameter_value MEM_IF_CS_WIDTH] >= 9 && [get_parameter_value MEM_IF_CS_WIDTH] <= 16} {
				set_parameter_value LOCAL_CS_WIDTH 4
			} else {
				_error "MEM_IF_CS_WIDTH=[get_parameter_value MEM_IF_CS_WIDTH] is not supported"
			}
		}

		if {([string compare -nocase [get_parameter_value RATE] "full"] == 0)} {
		    set_parameter_value RDBUFFER_ADDR_WIDTH 8
		} elseif {([string compare -nocase [get_parameter_value RATE] "half"] == 0)} {
		    set_parameter_value RDBUFFER_ADDR_WIDTH 7
		} elseif {([string compare -nocase [get_parameter_value RATE] "quarter"] == 0)} {
            	    set_parameter_value RDBUFFER_ADDR_WIDTH 7    
        	}
				
		if {[regexp {^LPDDR2$|^LPDDR1$} $protocol] == 1} {
			set_parameter_value CFG_PDN_EXIT_CYCLES 10
		} elseif {[string compare -nocase [get_parameter_value MEM_PD] "Fast exit"] == 0 ||
		          [string compare -nocase [get_parameter_value MEM_PD] "DLL on"] == 0} {
			set_parameter_value CFG_PDN_EXIT_CYCLES 3
		} else {
			set_parameter_value CFG_PDN_EXIT_CYCLES 10
		}
        
		if {[regexp {^LPDDR2$} $protocol] == 1} {
		    set clk_period_ns [ expr 1000.0 / [ get_parameter_value MEM_CLK_FREQ] ]
			set_parameter_value CFG_POWER_SAVING_EXIT_CYCLES [expr {int(ceil([expr {15.0 / $clk_period_ns}]))}]
		} else {
			set_parameter_value CFG_POWER_SAVING_EXIT_CYCLES 5 
		}
		
		if {(([regexp {^DDR[23]$} $protocol] == 1) && (([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0) || ([string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)))} {
			set clk_period_ns [ expr 1000.0 / [ get_parameter_value MEM_CLK_FREQ] ]
			set_parameter_value CFG_MEM_CLK_ENTRY_CYCLES [expr {int(ceil([expr {6000.0 / $clk_period_ns}]))}]
		} else {
			if {([string compare -nocase [get_parameter_value RATE] "full"] == 0)} {
				set_parameter_value CFG_MEM_CLK_ENTRY_CYCLES 10
			} elseif {([string compare -nocase [get_parameter_value RATE] "half"] == 0)} {
				set_parameter_value CFG_MEM_CLK_ENTRY_CYCLES 20
			} elseif {([string compare -nocase [get_parameter_value RATE] "quarter"] == 0)} {
				set_parameter_value CFG_MEM_CLK_ENTRY_CYCLES 40
			}
		}

		if {[regexp {^DDR1$} $protocol] == 1} {
			set_parameter_value CFG_SELF_RFSH_EXIT_CYCLES 200
		} elseif {[regexp {^DDR2$} $protocol] == 1} {
			set_parameter_value CFG_SELF_RFSH_EXIT_CYCLES 200
		} elseif {[regexp {^DDR3$} $protocol] == 1} {
			set_parameter_value CFG_SELF_RFSH_EXIT_CYCLES 512
		} elseif {[regexp {^LPDDR2$} $protocol] == 1} {
			set clk_period_ns [ expr 1000.0 / [ get_parameter_value MEM_CLK_FREQ] ]
			set_parameter_value CFG_SELF_RFSH_EXIT_CYCLES [expr {int(ceil([expr {220.0 / $clk_period_ns}]))}]
		} elseif {[regexp {^LPDDR1$} $protocol] == 1} {
			set_parameter_value CFG_SELF_RFSH_EXIT_CYCLES 200
		} else {
			_error "Protocol $protocol is not supported"
		}


		set_parameter_value CFG_PORT_WIDTH_WRITE_ODT_CHIP [expr {[get_parameter_value MEM_IF_CS_WIDTH] * [get_parameter_value MEM_IF_ODT_WIDTH]}]
		set_parameter_value CFG_PORT_WIDTH_READ_ODT_CHIP  [expr {[get_parameter_value MEM_IF_CS_WIDTH] * [get_parameter_value MEM_IF_ODT_WIDTH]}]

		set_parameter_value CFG_WRITE_ODT_CHIP [_compute_odt_chip 1]
		set_parameter_value CFG_READ_ODT_CHIP [_compute_odt_chip 0]

			set_parameter_value CFG_CLR_INTR 0

		if {[string compare -nocase [get_parameter_value BYTE_ENABLE] "true"] == 0 && [string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "false"] == 0} {
			set_parameter_value CFG_ENABLE_NO_DM 1
		} else {
			set_parameter_value CFG_ENABLE_NO_DM 0
		}
        
        if {[regexp {^LPDDR1$} $protocol] == 1} {
            set_parameter_value CTL_ENABLE_BURST_INTERRUPT_INT [get_parameter_value CTL_ENABLE_BURST_INTERRUPT]
            set_parameter_value CTL_ENABLE_BURST_TERMINATE_INT false 
        } elseif {[regexp {^LPDDR2$} $protocol] == 1} {
            set_parameter_value CTL_ENABLE_BURST_INTERRUPT_INT [get_parameter_value CTL_ENABLE_BURST_INTERRUPT]
            set_parameter_value CTL_ENABLE_BURST_TERMINATE_INT [get_parameter_value CTL_ENABLE_BURST_TERMINATE]
        } else {
            set_parameter_value CTL_ENABLE_BURST_INTERRUPT_INT false 
            set_parameter_value CTL_ENABLE_BURST_TERMINATE_INT false 
        }

	}

	if {[regexp {^DDR3$} $protocol] == 1 && ([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
		set_parameter_value CTL_CS_WIDTH [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
	} else {
		set_parameter_value CTL_CS_WIDTH [get_parameter_value MEM_IF_CS_WIDTH]
	}

	set_parameter_value  MEM_ADD_LAT [get_parameter_value MEM_ATCL_INT]
	
	if {([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0) && ([string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0)} {
	    set_parameter_value CTL_ENABLE_WDATA_PATH_LATENCY true
	} else {
	    set_parameter_value CTL_ENABLE_WDATA_PATH_LATENCY false
	}

	set AFI_CLK [expr [get_parameter_value MEM_CLK_FREQ] /  [get_parameter_value AFI_RATE_RATIO]]

	if {([string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0) && ($AFI_CLK >= 165.0) && ([string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0) && ([string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0)} {		
		set_parameter_value CFG_ERRCMD_FIFO_REG 1
		set_parameter_value CFG_ECC_DECODER_REG 1
	} else {
	    set_parameter_value CFG_ERRCMD_FIFO_REG 0
	    set_parameter_value CFG_ECC_DECODER_REG 0
	}

        if {([string compare -nocase [get_parameter_value CFG_REORDER_DATA] "false"] == 0)} {
                set_parameter_value CFG_STARVE_LIMIT [get_parameter_property STARVE_LIMIT DEFAULT_VALUE]
        } else {
                set_parameter_value CFG_STARVE_LIMIT [get_parameter_value STARVE_LIMIT]
        }

        if {([string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "false"] == 0)} {
                set_parameter_value MEM_AUTO_PD_CYCLES [get_parameter_property AUTO_PD_CYCLES DEFAULT_VALUE]
        } else {
                set_parameter_value MEM_AUTO_PD_CYCLES [get_parameter_value AUTO_PD_CYCLES]
        }



	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
                set port [list "Port 0"]
                for {set port_id 1} {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {incr port_id} { 
                        set port [lappend port "Port $port_id"]
                }
                set_parameter_value AVL_PORT $port

                for {set port_id 0} {$port_id != 6} {incr port_id} {
                        if {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {
	                        set_parameter_value AVL_DATA_WIDTH_PORT_${port_id} [lindex [split [get_parameter_value AVL_DATA_WIDTH_PORT] " "] $port_id]
	                        set_parameter_value AVL_NUM_SYMBOLS_PORT_${port_id} [expr {int([get_parameter_value AVL_DATA_WIDTH_PORT_${port_id}] / 8)}]

	                        if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0 && [get_parameter_value MEM_IF_DQ_WIDTH] > 8} {
                                        set minus_col_bit [expr log([get_parameter_value AVL_DATA_WIDTH_PORT_${port_id}] / ([get_parameter_value MEM_IF_DQ_WIDTH] - 8)) / log(2)]
	                        } else {
                                        set minus_col_bit [expr log([get_parameter_value AVL_DATA_WIDTH_PORT_${port_id}] / [get_parameter_value MEM_IF_DQ_WIDTH]) / log(2)]
	                        }
	                        set_parameter_value AVL_ADDR_WIDTH_PORT_${port_id} [expr {[_log2 [get_parameter_value MEM_IF_CS_WIDTH]] + [get_parameter_value MEM_IF_ROW_ADDR_WIDTH] + [get_parameter_value MEM_IF_BANKADDR_WIDTH] + [get_parameter_value MEM_IF_COL_ADDR_WIDTH] - $minus_col_bit}]
	                        set_parameter_value PRIORITY_PORT_${port_id} [lindex [split [get_parameter_value PRIORITY_PORT] " "] $port_id]
	                        set_parameter_value WEIGHT_PORT_${port_id} [lindex [split [get_parameter_value WEIGHT_PORT] " "] $port_id]
	                        set_parameter_value CPORT_TYPE_PORT_${port_id} [string map {"Not in use" 0 "Write-only" 1 "Read-only" 2 "Bidirectional" 3} [lindex [split [get_parameter_value CPORT_TYPE_PORT] " "] $port_id]]
                        } else {
	                        set_parameter_value AVL_DATA_WIDTH_PORT_${port_id} 1
	                        set_parameter_value AVL_NUM_SYMBOLS_PORT_${port_id} 1
	                        set_parameter_value AVL_ADDR_WIDTH_PORT_${port_id} 1
	                        set_parameter_value PRIORITY_PORT_${port_id} 1
	                        set_parameter_value WEIGHT_PORT_${port_id} 0
	                        set_parameter_value CPORT_TYPE_PORT_${port_id} 0
                        }

                }

                set_parameter_value CSR_ADDR_WIDTH 10
                set_parameter_value CSR_DATA_WIDTH 8
                set_parameter_value CSR_BE_WIDTH 1
                _derive_hmc_atom_derived_parameters

                if {[::alt_mem_if::util::qini::cfg_is_on uniphy_overwrite_auto_fifo_mapping]} {
                } else {
                        set allocated_rfifo [list [string map {"USE_0_1_2_3" "F0-F3" "USE_0_1" "F0-F1" "USE_2_3" "F2-F3" "USE_0" "F0" "USE_1" "F1" "USE_2" "F2" "USE_3" "F3" "USE_NO" "None"} [get_parameter_value ENUM_RD_PORT_INFO_0]]]
                        set allocated_wfifo [list [string map {"USE_0_1_2_3" "F0-F3" "USE_0_1" "F0-F1" "USE_2_3" "F2-F3" "USE_0" "F0" "USE_1" "F1" "USE_2" "F2" "USE_3" "F3" "USE_NO" "None"} [get_parameter_value ENUM_WR_PORT_INFO_0]]]
                        for {set port_id 1} {$port_id != 6} {incr port_id} {
                                set allocated_rfifo [lappend allocated_rfifo [string map {"USE_0_1_2_3" "F0-F3" "USE_0_1" "F0-F1" "USE_2_3" "F2-F3" "USE_0" "F0" "USE_1" "F1" "USE_2" "F2" "USE_3" "F3" "USE_NO" "None"} [get_parameter_value ENUM_RD_PORT_INFO_${port_id}]]]
                                set allocated_wfifo [lappend allocated_wfifo [string map {"USE_0_1_2_3" "F0-F3" "USE_0_1" "F0-F1" "USE_2_3" "F2-F3" "USE_0" "F0" "USE_1" "F1" "USE_2" "F2" "USE_3" "F3" "USE_NO" "None"} [get_parameter_value ENUM_WR_PORT_INFO_${port_id}]]]
                        }
                        set_parameter_value ALLOCATED_WFIFO_PORT $allocated_wfifo
                        set_parameter_value ALLOCATED_RFIFO_PORT $allocated_rfifo
                }

        }

	return 1
}


proc ::alt_mem_if::gui::ddrx_controller::_log2 {n} {
	return [expr log($n) / log(2)]
}



proc ::alt_mem_if::gui::ddrx_controller::_compute_odt_chip {write} {

        set protocol [_get_protocol]

        if {[string compare -nocase [ get_parameter_value MEM_FORMAT ] "DISCRETE" ] == 0 } {
            set key_mem_if_cs_width     [get_parameter_value MEM_IF_CS_WIDTH]
            set key_mem_if_cs_per_dimm  [get_parameter_value MEM_IF_CS_PER_DIMM]
        } else {
            set key_mem_if_cs_width     [expr {[get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM] * [get_parameter_value MEM_NUMBER_OF_DIMMS]}]
            set key_mem_if_cs_per_dimm  [get_parameter_value MEM_NUMBER_OF_RANKS_PER_DIMM]
        }

        set key_name "$key_mem_if_cs_width$key_mem_if_cs_per_dimm"
        set generated_cfg_odt_chip 0


        array set cfg_write_ddr2_table {
                11  0x1
                21  0x6
                22  0x9
                41  0x7BDE
                42  0x2184
                44  0x8421
                81  0x7FBFDFEFF7FBFDFE
                82  0x2A158A45A251A854
                84  0x0804020180402010
        }

        array set cfg_write_ddr3_table {
                11  0x1
                21  0xF
                22  0x9
                41  0xFFFF
                42  0xA5A5
                44  0x8421
                81  0xFFFFFFFFFFFFFFFF
                82  0xAA55AA55AA55AA55
                84  0x8844221188442211
        }

        array set cfg_read_ddr2_ddr3_table {
                11  0x0
                21  0x6
                22  0x0
                41  0x7BDE
                42  0x2184
                44  0x0
                81  0x7FBFDFEFF7FBFDFE
                82  0x2A158A45A251A854
                84  0x0804020180402010
        }

        array set cfg_read_ddr3_lrdimm_table {
                22  0x0
                42  0X33CC
        }

        array set cfg_write_ddr3_lrdimm_table {
                22  0xF
                42  0XFFFF
        }

        if {[regexp {^DDR2$} $protocol] == 1 && ([array names cfg_write_ddr2_table $key_name] != "") && $write} {
                set generated_cfg_odt_chip $cfg_write_ddr2_table($key_name)
        } elseif {[regexp {^DDR3$} $protocol] == 1 && [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0} {
                if {$write} {
                        set generated_cfg_odt_chip  $cfg_write_ddr3_lrdimm_table($key_name)
                } else {
                        set generated_cfg_odt_chip $cfg_read_ddr3_lrdimm_table($key_name)
                }
        } elseif {[regexp {^DDR3$} $protocol] == 1 && ([array names cfg_write_ddr3_table $key_name] != "") && $write} {
                set generated_cfg_odt_chip $cfg_write_ddr3_table($key_name)
        } elseif {([regexp {^DDR2$} $protocol] == 1 || [regexp {^DDR3$} $protocol] == 1) && ([array names cfg_read_ddr2_ddr3_table $key_name] != "") && !$write} {
                set generated_cfg_odt_chip $cfg_read_ddr2_ddr3_table($key_name)
        } else {
                set generated_cfg_odt_chip 0
        }

        return $generated_cfg_odt_chip
}


proc _binary_to_int {binary_value} {

	set int_value 0

	set blen [string length $binary_value]

	set factor 1
	for {set ii 0} {$ii < $blen} {incr ii} {
		if {[string compare -nocase [string index $binary_value $ii] "1"] == 0} {
			incr int_value $factor
		}
		set factor [expr {2 * $factor}]
	}
	
	return $int_value
}

proc _pow { base exponent } {
	set result 1
	for { set i 0 } { $i < $exponent } { incr i } {
		set result [ expr $result * $base ]
	}

	return $result
}

proc _tck2tns {tck_value n_dec} {
        set result [::alt_mem_if::gui::common_ddr_mem_model::_tck_to_ns $tck_value [get_parameter_value MEM_CLK_FREQ] $n_dec]
        return $result
}

proc ::alt_mem_if::gui::ddrx_controller::_create_hmc_atom_derived_parameters {} {
	
		
::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ATTR_COUNTER_ONE_RESET String "DISABLED"
set_parameter_property ENUM_ATTR_COUNTER_ONE_RESET VISIBLE false
set_parameter_property ENUM_ATTR_COUNTER_ONE_RESET DERIVED true
set_parameter_property ENUM_ATTR_COUNTER_ONE_RESET DISPLAY_NAME "attr_counter_one_reset"
set_parameter_property ENUM_ATTR_COUNTER_ONE_RESET ALLOWED_RANGES {"ENABLED" "DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ATTR_COUNTER_ZERO_RESET String "DISABLED"
set_parameter_property ENUM_ATTR_COUNTER_ZERO_RESET VISIBLE false
set_parameter_property ENUM_ATTR_COUNTER_ZERO_RESET DERIVED true
set_parameter_property ENUM_ATTR_COUNTER_ZERO_RESET DISPLAY_NAME "attr_counter_zero_reset"
set_parameter_property ENUM_ATTR_COUNTER_ZERO_RESET ALLOWED_RANGES {"ENABLED" "DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ATTR_STATIC_CONFIG_VALID String "DISABLED"
set_parameter_property ENUM_ATTR_STATIC_CONFIG_VALID VISIBLE false
set_parameter_property ENUM_ATTR_STATIC_CONFIG_VALID DERIVED true
set_parameter_property ENUM_ATTR_STATIC_CONFIG_VALID DISPLAY_NAME "attr_static_config_valid"
set_parameter_property ENUM_ATTR_STATIC_CONFIG_VALID ALLOWED_RANGES {"ENABLED" "DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_AUTO_PCH_ENABLE_0 String "DISABLED"
set_parameter_property ENUM_AUTO_PCH_ENABLE_0 VISIBLE false
set_parameter_property ENUM_AUTO_PCH_ENABLE_0 DERIVED true
set_parameter_property ENUM_AUTO_PCH_ENABLE_0 DISPLAY_NAME "auto_pch_enable_0"
set_parameter_property ENUM_AUTO_PCH_ENABLE_0 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_AUTO_PCH_ENABLE_1 String "DISABLED"
set_parameter_property ENUM_AUTO_PCH_ENABLE_1 VISIBLE false
set_parameter_property ENUM_AUTO_PCH_ENABLE_1 DERIVED true
set_parameter_property ENUM_AUTO_PCH_ENABLE_1 DISPLAY_NAME "auto_pch_enable_1"
set_parameter_property ENUM_AUTO_PCH_ENABLE_1 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_AUTO_PCH_ENABLE_2 String "DISABLED"
set_parameter_property ENUM_AUTO_PCH_ENABLE_2 VISIBLE false
set_parameter_property ENUM_AUTO_PCH_ENABLE_2 DERIVED true
set_parameter_property ENUM_AUTO_PCH_ENABLE_2 DISPLAY_NAME "auto_pch_enable_2"
set_parameter_property ENUM_AUTO_PCH_ENABLE_2 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_AUTO_PCH_ENABLE_3 String "DISABLED"
set_parameter_property ENUM_AUTO_PCH_ENABLE_3 VISIBLE false
set_parameter_property ENUM_AUTO_PCH_ENABLE_3 DERIVED true
set_parameter_property ENUM_AUTO_PCH_ENABLE_3 DISPLAY_NAME "auto_pch_enable_3"
set_parameter_property ENUM_AUTO_PCH_ENABLE_3 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_AUTO_PCH_ENABLE_4 String "DISABLED"
set_parameter_property ENUM_AUTO_PCH_ENABLE_4 VISIBLE false
set_parameter_property ENUM_AUTO_PCH_ENABLE_4 DERIVED true
set_parameter_property ENUM_AUTO_PCH_ENABLE_4 DISPLAY_NAME "auto_pch_enable_4"
set_parameter_property ENUM_AUTO_PCH_ENABLE_4 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_AUTO_PCH_ENABLE_5 String "DISABLED"
set_parameter_property ENUM_AUTO_PCH_ENABLE_5 VISIBLE false
set_parameter_property ENUM_AUTO_PCH_ENABLE_5 DERIVED true
set_parameter_property ENUM_AUTO_PCH_ENABLE_5 DISPLAY_NAME "auto_pch_enable_5"
set_parameter_property ENUM_AUTO_PCH_ENABLE_5 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CAL_REQ String "DISABLED"
set_parameter_property ENUM_CAL_REQ VISIBLE false
set_parameter_property ENUM_CAL_REQ DERIVED true
set_parameter_property ENUM_CAL_REQ DISPLAY_NAME "cal_req"
set_parameter_property ENUM_CAL_REQ ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CFG_BURST_LENGTH String "BL_8"
set_parameter_property ENUM_CFG_BURST_LENGTH VISIBLE false
set_parameter_property ENUM_CFG_BURST_LENGTH DERIVED true
set_parameter_property ENUM_CFG_BURST_LENGTH DISPLAY_NAME "cfg_burst_length"
set_parameter_property ENUM_CFG_BURST_LENGTH ALLOWED_RANGES {"BL_2" "BL_4" "BL_8" "BL_16"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CFG_INTERFACE_WIDTH String "DWIDTH_32"
set_parameter_property ENUM_CFG_INTERFACE_WIDTH VISIBLE false
set_parameter_property ENUM_CFG_INTERFACE_WIDTH DERIVED true
set_parameter_property ENUM_CFG_INTERFACE_WIDTH DISPLAY_NAME "cfg_interface_width"
set_parameter_property ENUM_CFG_INTERFACE_WIDTH ALLOWED_RANGES {"DWIDTH_8" "DWIDTH_16" "DWIDTH_24" "DWIDTH_32" "DWIDTH_40"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CFG_SELF_RFSH_EXIT_CYCLES String ""
set_parameter_property ENUM_CFG_SELF_RFSH_EXIT_CYCLES VISIBLE false
set_parameter_property ENUM_CFG_SELF_RFSH_EXIT_CYCLES DERIVED true
set_parameter_property ENUM_CFG_SELF_RFSH_EXIT_CYCLES DISPLAY_NAME "cfg_self_rfsh_exit_cycles"

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CFG_STARVE_LIMIT String "STARVE_LIMIT_32"
set_parameter_property ENUM_CFG_STARVE_LIMIT VISIBLE false
set_parameter_property ENUM_CFG_STARVE_LIMIT DERIVED true
set_parameter_property ENUM_CFG_STARVE_LIMIT DISPLAY_NAME "cfg_starve_limit"
set_parameter_property ENUM_CFG_STARVE_LIMIT ALLOWED_RANGES {"STARVE_LIMIT_1" "STARVE_LIMIT_2" "STARVE_LIMIT_3" "STARVE_LIMIT_4" "STARVE_LIMIT_5" "STARVE_LIMIT_6" "STARVE_LIMIT_7" "STARVE_LIMIT_8" "STARVE_LIMIT_9" "STARVE_LIMIT_10" "STARVE_LIMIT_11" "STARVE_LIMIT_12" "STARVE_LIMIT_13" "STARVE_LIMIT_14" "STARVE_LIMIT_15" "STARVE_LIMIT_16" "STARVE_LIMIT_17" "STARVE_LIMIT_18" "STARVE_LIMIT_19" "STARVE_LIMIT_20" "STARVE_LIMIT_21" "STARVE_LIMIT_22" "STARVE_LIMIT_23" "STARVE_LIMIT_24" "STARVE_LIMIT_25" "STARVE_LIMIT_26" "STARVE_LIMIT_27" "STARVE_LIMIT_28" "STARVE_LIMIT_29" "STARVE_LIMIT_30" "STARVE_LIMIT_31" "STARVE_LIMIT_32" "STARVE_LIMIT_33" "STARVE_LIMIT_34" "STARVE_LIMIT_35" "STARVE_LIMIT_36" "STARVE_LIMIT_37" "STARVE_LIMIT_38" "STARVE_LIMIT_39" "STARVE_LIMIT_40" "STARVE_LIMIT_41" "STARVE_LIMIT_42" "STARVE_LIMIT_43" "STARVE_LIMIT_44" "STARVE_LIMIT_45" "STARVE_LIMIT_46" "STARVE_LIMIT_47" "STARVE_LIMIT_48" "STARVE_LIMIT_49" "STARVE_LIMIT_50" "STARVE_LIMIT_51" "STARVE_LIMIT_52" "STARVE_LIMIT_53" "STARVE_LIMIT_54" "STARVE_LIMIT_55" "STARVE_LIMIT_56" "STARVE_LIMIT_57" "STARVE_LIMIT_58" "STARVE_LIMIT_59" "STARVE_LIMIT_60" "STARVE_LIMIT_61" "STARVE_LIMIT_62" "STARVE_LIMIT_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CFG_TYPE String "DDR3"
set_parameter_property ENUM_CFG_TYPE VISIBLE false
set_parameter_property ENUM_CFG_TYPE DERIVED true
set_parameter_property ENUM_CFG_TYPE DISPLAY_NAME "cfg_type"
set_parameter_property ENUM_CFG_TYPE ALLOWED_RANGES {"DDR" "DDR2" "DDR3" "LPDDR2" "LPDDR"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CLOCK_OFF_0 String "DISABLED"
set_parameter_property ENUM_CLOCK_OFF_0 VISIBLE false
set_parameter_property ENUM_CLOCK_OFF_0 DERIVED true
set_parameter_property ENUM_CLOCK_OFF_0 DISPLAY_NAME "clock_off_0"
set_parameter_property ENUM_CLOCK_OFF_0 ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CLOCK_OFF_1 String "DISABLED"
set_parameter_property ENUM_CLOCK_OFF_1 VISIBLE false
set_parameter_property ENUM_CLOCK_OFF_1 DERIVED true
set_parameter_property ENUM_CLOCK_OFF_1 DISPLAY_NAME "clock_off_1"
set_parameter_property ENUM_CLOCK_OFF_1 ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CLOCK_OFF_2 String "DISABLED"
set_parameter_property ENUM_CLOCK_OFF_2 VISIBLE false
set_parameter_property ENUM_CLOCK_OFF_2 DERIVED true
set_parameter_property ENUM_CLOCK_OFF_2 DISPLAY_NAME "clock_off_2"
set_parameter_property ENUM_CLOCK_OFF_2 ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CLOCK_OFF_3 String "DISABLED"
set_parameter_property ENUM_CLOCK_OFF_3 VISIBLE false
set_parameter_property ENUM_CLOCK_OFF_3 DERIVED true
set_parameter_property ENUM_CLOCK_OFF_3 DISPLAY_NAME "clock_off_3"
set_parameter_property ENUM_CLOCK_OFF_3 ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CLOCK_OFF_4 String "DISABLED"
set_parameter_property ENUM_CLOCK_OFF_4 VISIBLE false
set_parameter_property ENUM_CLOCK_OFF_4 DERIVED true
set_parameter_property ENUM_CLOCK_OFF_4 DISPLAY_NAME "clock_off_4"
set_parameter_property ENUM_CLOCK_OFF_4 ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CLOCK_OFF_5 String "DISABLED"
set_parameter_property ENUM_CLOCK_OFF_5 VISIBLE false
set_parameter_property ENUM_CLOCK_OFF_5 DERIVED true
set_parameter_property ENUM_CLOCK_OFF_5 DISPLAY_NAME "clock_off_5"
set_parameter_property ENUM_CLOCK_OFF_5 ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CLR_INTR String "NO_CLR_INTR"
set_parameter_property ENUM_CLR_INTR VISIBLE false
set_parameter_property ENUM_CLR_INTR DERIVED true
set_parameter_property ENUM_CLR_INTR DISPLAY_NAME "clr_intr"
set_parameter_property ENUM_CLR_INTR ALLOWED_RANGES {"CLR_INTR" "NO_CLR_INTR"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CMD_PORT_IN_USE_0 String "FALSE"
set_parameter_property ENUM_CMD_PORT_IN_USE_0 VISIBLE false
set_parameter_property ENUM_CMD_PORT_IN_USE_0 DERIVED true
set_parameter_property ENUM_CMD_PORT_IN_USE_0 DISPLAY_NAME "cmd_port_in_use_0"
set_parameter_property ENUM_CMD_PORT_IN_USE_0 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CMD_PORT_IN_USE_1 String "FALSE"
set_parameter_property ENUM_CMD_PORT_IN_USE_1 VISIBLE false
set_parameter_property ENUM_CMD_PORT_IN_USE_1 DERIVED true
set_parameter_property ENUM_CMD_PORT_IN_USE_1 DISPLAY_NAME "cmd_port_in_use_1"
set_parameter_property ENUM_CMD_PORT_IN_USE_1 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CMD_PORT_IN_USE_2 String "FALSE"
set_parameter_property ENUM_CMD_PORT_IN_USE_2 VISIBLE false
set_parameter_property ENUM_CMD_PORT_IN_USE_2 DERIVED true
set_parameter_property ENUM_CMD_PORT_IN_USE_2 DISPLAY_NAME "cmd_port_in_use_2"
set_parameter_property ENUM_CMD_PORT_IN_USE_2 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CMD_PORT_IN_USE_3 String "FALSE"
set_parameter_property ENUM_CMD_PORT_IN_USE_3 VISIBLE false
set_parameter_property ENUM_CMD_PORT_IN_USE_3 DERIVED true
set_parameter_property ENUM_CMD_PORT_IN_USE_3 DISPLAY_NAME "cmd_port_in_use_3"
set_parameter_property ENUM_CMD_PORT_IN_USE_3 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CMD_PORT_IN_USE_4 String "FALSE"
set_parameter_property ENUM_CMD_PORT_IN_USE_4 VISIBLE false
set_parameter_property ENUM_CMD_PORT_IN_USE_4 DERIVED true
set_parameter_property ENUM_CMD_PORT_IN_USE_4 DISPLAY_NAME "cmd_port_in_use_4"
set_parameter_property ENUM_CMD_PORT_IN_USE_4 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CMD_PORT_IN_USE_5 String "FALSE"
set_parameter_property ENUM_CMD_PORT_IN_USE_5 VISIBLE false
set_parameter_property ENUM_CMD_PORT_IN_USE_5 DERIVED true
set_parameter_property ENUM_CMD_PORT_IN_USE_5 DISPLAY_NAME "cmd_port_in_use_5"
set_parameter_property ENUM_CMD_PORT_IN_USE_5 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT0_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_CPORT0_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_CPORT0_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_CPORT0_RDY_ALMOST_FULL DISPLAY_NAME "cport0_rdy_almost_full"
set_parameter_property ENUM_CPORT0_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT0_RFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT0_RFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT0_RFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT0_RFIFO_MAP DISPLAY_NAME "cport0_rfifo_map"
set_parameter_property ENUM_CPORT0_RFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT0_TYPE String "DISABLE"
set_parameter_property ENUM_CPORT0_TYPE VISIBLE false
set_parameter_property ENUM_CPORT0_TYPE DERIVED true
set_parameter_property ENUM_CPORT0_TYPE DISPLAY_NAME "cport0_type"
set_parameter_property ENUM_CPORT0_TYPE ALLOWED_RANGES {"DISABLE" "WRITE" "READ" "BI_DIRECTION"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT0_WFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT0_WFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT0_WFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT0_WFIFO_MAP DISPLAY_NAME "cport0_wfifo_map"
set_parameter_property ENUM_CPORT0_WFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT1_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_CPORT1_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_CPORT1_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_CPORT1_RDY_ALMOST_FULL DISPLAY_NAME "cport1_rdy_almost_full"
set_parameter_property ENUM_CPORT1_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT1_RFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT1_RFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT1_RFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT1_RFIFO_MAP DISPLAY_NAME "cport1_rfifo_map"
set_parameter_property ENUM_CPORT1_RFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT1_TYPE String "DISABLE"
set_parameter_property ENUM_CPORT1_TYPE VISIBLE false
set_parameter_property ENUM_CPORT1_TYPE DERIVED true
set_parameter_property ENUM_CPORT1_TYPE DISPLAY_NAME "cport1_type"
set_parameter_property ENUM_CPORT1_TYPE ALLOWED_RANGES {"DISABLE" "WRITE" "READ" "BI_DIRECTION"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT1_WFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT1_WFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT1_WFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT1_WFIFO_MAP DISPLAY_NAME "cport1_wfifo_map"
set_parameter_property ENUM_CPORT1_WFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT2_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_CPORT2_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_CPORT2_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_CPORT2_RDY_ALMOST_FULL DISPLAY_NAME "cport2_rdy_almost_full"
set_parameter_property ENUM_CPORT2_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT2_RFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT2_RFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT2_RFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT2_RFIFO_MAP DISPLAY_NAME "cport2_rfifo_map"
set_parameter_property ENUM_CPORT2_RFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT2_TYPE String "DISABLE"
set_parameter_property ENUM_CPORT2_TYPE VISIBLE false
set_parameter_property ENUM_CPORT2_TYPE DERIVED true
set_parameter_property ENUM_CPORT2_TYPE DISPLAY_NAME "cport2_type"
set_parameter_property ENUM_CPORT2_TYPE ALLOWED_RANGES {"DISABLE" "WRITE" "READ" "BI_DIRECTION"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT2_WFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT2_WFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT2_WFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT2_WFIFO_MAP DISPLAY_NAME "cport2_wfifo_map"
set_parameter_property ENUM_CPORT2_WFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT3_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_CPORT3_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_CPORT3_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_CPORT3_RDY_ALMOST_FULL DISPLAY_NAME "cport3_rdy_almost_full"
set_parameter_property ENUM_CPORT3_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT3_RFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT3_RFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT3_RFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT3_RFIFO_MAP DISPLAY_NAME "cport3_rfifo_map"
set_parameter_property ENUM_CPORT3_RFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT3_TYPE String "DISABLE"
set_parameter_property ENUM_CPORT3_TYPE VISIBLE false
set_parameter_property ENUM_CPORT3_TYPE DERIVED true
set_parameter_property ENUM_CPORT3_TYPE DISPLAY_NAME "cport3_type"
set_parameter_property ENUM_CPORT3_TYPE ALLOWED_RANGES {"DISABLE" "WRITE" "READ" "BI_DIRECTION"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT3_WFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT3_WFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT3_WFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT3_WFIFO_MAP DISPLAY_NAME "cport3_wfifo_map"
set_parameter_property ENUM_CPORT3_WFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT4_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_CPORT4_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_CPORT4_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_CPORT4_RDY_ALMOST_FULL DISPLAY_NAME "cport4_rdy_almost_full"
set_parameter_property ENUM_CPORT4_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT4_RFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT4_RFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT4_RFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT4_RFIFO_MAP DISPLAY_NAME "cport4_rfifo_map"
set_parameter_property ENUM_CPORT4_RFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT4_TYPE String "DISABLE"
set_parameter_property ENUM_CPORT4_TYPE VISIBLE false
set_parameter_property ENUM_CPORT4_TYPE DERIVED true
set_parameter_property ENUM_CPORT4_TYPE DISPLAY_NAME "cport4_type"
set_parameter_property ENUM_CPORT4_TYPE ALLOWED_RANGES {"DISABLE" "WRITE" "READ" "BI_DIRECTION"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT4_WFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT4_WFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT4_WFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT4_WFIFO_MAP DISPLAY_NAME "cport4_wfifo_map"
set_parameter_property ENUM_CPORT4_WFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT5_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_CPORT5_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_CPORT5_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_CPORT5_RDY_ALMOST_FULL DISPLAY_NAME "cport5_rdy_almost_full"
set_parameter_property ENUM_CPORT5_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT5_RFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT5_RFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT5_RFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT5_RFIFO_MAP DISPLAY_NAME "cport5_rfifo_map"
set_parameter_property ENUM_CPORT5_RFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT5_TYPE String "DISABLE"
set_parameter_property ENUM_CPORT5_TYPE VISIBLE false
set_parameter_property ENUM_CPORT5_TYPE DERIVED true
set_parameter_property ENUM_CPORT5_TYPE DISPLAY_NAME "cport5_type"
set_parameter_property ENUM_CPORT5_TYPE ALLOWED_RANGES {"DISABLE" "WRITE" "READ" "BI_DIRECTION"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CPORT5_WFIFO_MAP String "FIFO_0"
set_parameter_property ENUM_CPORT5_WFIFO_MAP VISIBLE false
set_parameter_property ENUM_CPORT5_WFIFO_MAP DERIVED true
set_parameter_property ENUM_CPORT5_WFIFO_MAP DISPLAY_NAME "cport5_wfifo_map"
set_parameter_property ENUM_CPORT5_WFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CTL_ADDR_ORDER String "CHIP_BANK_ROW_COL"
set_parameter_property ENUM_CTL_ADDR_ORDER VISIBLE false
set_parameter_property ENUM_CTL_ADDR_ORDER DERIVED true
set_parameter_property ENUM_CTL_ADDR_ORDER DISPLAY_NAME "ctl_addr_order"
set_parameter_property ENUM_CTL_ADDR_ORDER ALLOWED_RANGES {"CHIP_ROW_BANK_COL" "CHIP_BANK_ROW_COL" "ROW_CHIP_BANK_COL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CTL_ECC_ENABLED String "CTL_ECC_DISABLED"
set_parameter_property ENUM_CTL_ECC_ENABLED VISIBLE false
set_parameter_property ENUM_CTL_ECC_ENABLED DERIVED true
set_parameter_property ENUM_CTL_ECC_ENABLED DISPLAY_NAME "ctl_ecc_enabled"
set_parameter_property ENUM_CTL_ECC_ENABLED ALLOWED_RANGES {"CTL_ECC_DISABLED" "CTL_ECC_ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CTL_ECC_RMW_ENABLED String "CTL_ECC_RMW_DISABLED"
set_parameter_property ENUM_CTL_ECC_RMW_ENABLED VISIBLE false
set_parameter_property ENUM_CTL_ECC_RMW_ENABLED DERIVED true
set_parameter_property ENUM_CTL_ECC_RMW_ENABLED DISPLAY_NAME "ctl_ecc_rmw_enabled"
set_parameter_property ENUM_CTL_ECC_RMW_ENABLED ALLOWED_RANGES {"CTL_ECC_RMW_DISABLED" "CTL_ECC_RMW_ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CTL_REGDIMM_ENABLED String "REGDIMM_DISABLED"
set_parameter_property ENUM_CTL_REGDIMM_ENABLED VISIBLE false
set_parameter_property ENUM_CTL_REGDIMM_ENABLED DERIVED true
set_parameter_property ENUM_CTL_REGDIMM_ENABLED DISPLAY_NAME "ctl_regdimm_enabled"
set_parameter_property ENUM_CTL_REGDIMM_ENABLED ALLOWED_RANGES {"REGDIMM_DISABLED" "REGDIMM_ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CTL_USR_REFRESH String "CTL_USR_REFRESH_DISABLED"
set_parameter_property ENUM_CTL_USR_REFRESH VISIBLE false
set_parameter_property ENUM_CTL_USR_REFRESH DERIVED true
set_parameter_property ENUM_CTL_USR_REFRESH DISPLAY_NAME "ctl_usr_refresh"
set_parameter_property ENUM_CTL_USR_REFRESH ALLOWED_RANGES {"CTL_USR_REFRESH_ENABLED" "CTL_USR_REFRESH_DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_CTRL_WIDTH String "DATA_WIDTH_64_BIT"
set_parameter_property ENUM_CTRL_WIDTH VISIBLE false
set_parameter_property ENUM_CTRL_WIDTH DERIVED true
set_parameter_property ENUM_CTRL_WIDTH DISPLAY_NAME "ctrl_width"
set_parameter_property ENUM_CTRL_WIDTH ALLOWED_RANGES {"DATA_WIDTH_16_BIT" "DATA_WIDTH_32_BIT" "DATA_WIDTH_64_BIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_DELAY_BONDING String "BONDING_LATENCY_0"
set_parameter_property ENUM_DELAY_BONDING VISIBLE false
set_parameter_property ENUM_DELAY_BONDING DERIVED true
set_parameter_property ENUM_DELAY_BONDING DISPLAY_NAME "delay_bonding"
set_parameter_property ENUM_DELAY_BONDING ALLOWED_RANGES {"BONDING_LATENCY_0" "BONDING_LATENCY_1" "BONDING_LATENCY_2" "BONDING_LATENCY_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_DFX_BYPASS_ENABLE String "DFX_BYPASS_DISABLED"
set_parameter_property ENUM_DFX_BYPASS_ENABLE VISIBLE false
set_parameter_property ENUM_DFX_BYPASS_ENABLE DERIVED true
set_parameter_property ENUM_DFX_BYPASS_ENABLE DISPLAY_NAME "dfx_bypass_enable"
set_parameter_property ENUM_DFX_BYPASS_ENABLE ALLOWED_RANGES {"DFX_BYPASS_ENABLED" "DFX_BYPASS_DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_DISABLE_MERGING String "MERGING_ENABLED"
set_parameter_property ENUM_DISABLE_MERGING VISIBLE false
set_parameter_property ENUM_DISABLE_MERGING DERIVED true
set_parameter_property ENUM_DISABLE_MERGING DISPLAY_NAME "disable_merging"
set_parameter_property ENUM_DISABLE_MERGING ALLOWED_RANGES {"MERGING_ENABLED" "MERGING_DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ECC_DQ_WIDTH String "ECC_DQ_WIDTH_0"
set_parameter_property ENUM_ECC_DQ_WIDTH VISIBLE false
set_parameter_property ENUM_ECC_DQ_WIDTH DERIVED true
set_parameter_property ENUM_ECC_DQ_WIDTH DISPLAY_NAME "ecc_dq_width"
set_parameter_property ENUM_ECC_DQ_WIDTH ALLOWED_RANGES {"ECC_DQ_WIDTH_0" "ECC_DQ_WIDTH_8"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_ATPG String "DISABLED"
set_parameter_property ENUM_ENABLE_ATPG VISIBLE false
set_parameter_property ENUM_ENABLE_ATPG DERIVED true
set_parameter_property ENUM_ENABLE_ATPG DISPLAY_NAME "enable_atpg"
set_parameter_property ENUM_ENABLE_ATPG ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BONDING_0 String "DISABLED"
set_parameter_property ENUM_ENABLE_BONDING_0 VISIBLE false
set_parameter_property ENUM_ENABLE_BONDING_0 DERIVED true
set_parameter_property ENUM_ENABLE_BONDING_0 DISPLAY_NAME "enable_bonding_0"
set_parameter_property ENUM_ENABLE_BONDING_0 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BONDING_1 String "DISABLED"
set_parameter_property ENUM_ENABLE_BONDING_1 VISIBLE false
set_parameter_property ENUM_ENABLE_BONDING_1 DERIVED true
set_parameter_property ENUM_ENABLE_BONDING_1 DISPLAY_NAME "enable_bonding_1"
set_parameter_property ENUM_ENABLE_BONDING_1 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BONDING_2 String "DISABLED"
set_parameter_property ENUM_ENABLE_BONDING_2 VISIBLE false
set_parameter_property ENUM_ENABLE_BONDING_2 DERIVED true
set_parameter_property ENUM_ENABLE_BONDING_2 DISPLAY_NAME "enable_bonding_2"
set_parameter_property ENUM_ENABLE_BONDING_2 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BONDING_3 String "DISABLED"
set_parameter_property ENUM_ENABLE_BONDING_3 VISIBLE false
set_parameter_property ENUM_ENABLE_BONDING_3 DERIVED true
set_parameter_property ENUM_ENABLE_BONDING_3 DISPLAY_NAME "enable_bonding_3"
set_parameter_property ENUM_ENABLE_BONDING_3 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BONDING_4 String "DISABLED"
set_parameter_property ENUM_ENABLE_BONDING_4 VISIBLE false
set_parameter_property ENUM_ENABLE_BONDING_4 DERIVED true
set_parameter_property ENUM_ENABLE_BONDING_4 DISPLAY_NAME "enable_bonding_4"
set_parameter_property ENUM_ENABLE_BONDING_4 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BONDING_5 String "DISABLED"
set_parameter_property ENUM_ENABLE_BONDING_5 VISIBLE false
set_parameter_property ENUM_ENABLE_BONDING_5 DERIVED true
set_parameter_property ENUM_ENABLE_BONDING_5 DISPLAY_NAME "enable_bonding_5"
set_parameter_property ENUM_ENABLE_BONDING_5 ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BONDING_WRAPBACK String "DISABLED"
set_parameter_property ENUM_ENABLE_BONDING_WRAPBACK VISIBLE false
set_parameter_property ENUM_ENABLE_BONDING_WRAPBACK DERIVED true
set_parameter_property ENUM_ENABLE_BONDING_WRAPBACK DISPLAY_NAME "enable_bonding_wrapback"
set_parameter_property ENUM_ENABLE_BONDING_WRAPBACK ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_DQS_TRACKING String "DISABLED"
set_parameter_property ENUM_ENABLE_DQS_TRACKING VISIBLE false
set_parameter_property ENUM_ENABLE_DQS_TRACKING DERIVED true
set_parameter_property ENUM_ENABLE_DQS_TRACKING DISPLAY_NAME "enable_dqs_tracking"
set_parameter_property ENUM_ENABLE_DQS_TRACKING ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_ECC_CODE_OVERWRITES String "DISABLED"
set_parameter_property ENUM_ENABLE_ECC_CODE_OVERWRITES VISIBLE false
set_parameter_property ENUM_ENABLE_ECC_CODE_OVERWRITES DERIVED true
set_parameter_property ENUM_ENABLE_ECC_CODE_OVERWRITES DISPLAY_NAME "enable_ecc_code_overwrites"
set_parameter_property ENUM_ENABLE_ECC_CODE_OVERWRITES ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_FAST_EXIT_PPD String "DISABLED"
set_parameter_property ENUM_ENABLE_FAST_EXIT_PPD VISIBLE false
set_parameter_property ENUM_ENABLE_FAST_EXIT_PPD DERIVED true
set_parameter_property ENUM_ENABLE_FAST_EXIT_PPD DISPLAY_NAME "enable_fast_exit_ppd"
set_parameter_property ENUM_ENABLE_FAST_EXIT_PPD ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_INTR String "DISABLED"
set_parameter_property ENUM_ENABLE_INTR VISIBLE false
set_parameter_property ENUM_ENABLE_INTR DERIVED true
set_parameter_property ENUM_ENABLE_INTR DISPLAY_NAME "enable_intr"
set_parameter_property ENUM_ENABLE_INTR ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_NO_DM String "DISABLED"
set_parameter_property ENUM_ENABLE_NO_DM VISIBLE false
set_parameter_property ENUM_ENABLE_NO_DM DERIVED true
set_parameter_property ENUM_ENABLE_NO_DM DISPLAY_NAME "enable_no_dm"
set_parameter_property ENUM_ENABLE_NO_DM ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_PIPELINEGLOBAL String "DISABLED"
set_parameter_property ENUM_ENABLE_PIPELINEGLOBAL VISIBLE false
set_parameter_property ENUM_ENABLE_PIPELINEGLOBAL DERIVED true
set_parameter_property ENUM_ENABLE_PIPELINEGLOBAL DISPLAY_NAME "enable_pipelineglobal"
set_parameter_property ENUM_ENABLE_PIPELINEGLOBAL ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_GANGED_ARF String "DISABLED"
set_parameter_property ENUM_GANGED_ARF VISIBLE false
set_parameter_property ENUM_GANGED_ARF DERIVED true
set_parameter_property ENUM_GANGED_ARF DISPLAY_NAME "ganged_arf"
set_parameter_property ENUM_GANGED_ARF ALLOWED_RANGES {"DISABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_GEN_DBE String "GEN_DBE_DISABLED"
set_parameter_property ENUM_GEN_DBE VISIBLE false
set_parameter_property ENUM_GEN_DBE DERIVED true
set_parameter_property ENUM_GEN_DBE DISPLAY_NAME "gen_dbe"
set_parameter_property ENUM_GEN_DBE ALLOWED_RANGES {"GEN_DBE_DISABLED" "GEN_DBE_ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_GEN_SBE String "GEN_SBE_DISABLED"
set_parameter_property ENUM_GEN_SBE VISIBLE false
set_parameter_property ENUM_GEN_SBE DERIVED true
set_parameter_property ENUM_GEN_SBE DISPLAY_NAME "gen_sbe"
set_parameter_property ENUM_GEN_SBE ALLOWED_RANGES {"GEN_SBE_DISABLED" "GEN_SBE_ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_INC_SYNC String "FIFO_SET_2"
set_parameter_property ENUM_INC_SYNC VISIBLE false
set_parameter_property ENUM_INC_SYNC DERIVED true
set_parameter_property ENUM_INC_SYNC DISPLAY_NAME "inc_sync"
set_parameter_property ENUM_INC_SYNC ALLOWED_RANGES {"FIFO_SET_2" "FIFO_SET_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_LOCAL_IF_CS_WIDTH String "ADDR_WIDTH_2"
set_parameter_property ENUM_LOCAL_IF_CS_WIDTH VISIBLE false
set_parameter_property ENUM_LOCAL_IF_CS_WIDTH DERIVED true
set_parameter_property ENUM_LOCAL_IF_CS_WIDTH DISPLAY_NAME "local_if_cs_width"
set_parameter_property ENUM_LOCAL_IF_CS_WIDTH ALLOWED_RANGES {"ADDR_WIDTH_0" "ADDR_WIDTH_1" "ADDR_WIDTH_2" "ADDR_WIDTH_3" "ADDR_WIDTH_4"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MASK_CORR_DROPPED_INTR String "DISABLED"
set_parameter_property ENUM_MASK_CORR_DROPPED_INTR VISIBLE false
set_parameter_property ENUM_MASK_CORR_DROPPED_INTR DERIVED true
set_parameter_property ENUM_MASK_CORR_DROPPED_INTR DISPLAY_NAME "mask_corr_dropped_intr"
set_parameter_property ENUM_MASK_CORR_DROPPED_INTR ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MASK_DBE_INTR String "DISABLED"
set_parameter_property ENUM_MASK_DBE_INTR VISIBLE false
set_parameter_property ENUM_MASK_DBE_INTR DERIVED true
set_parameter_property ENUM_MASK_DBE_INTR DISPLAY_NAME "mask_dbe_intr"
set_parameter_property ENUM_MASK_DBE_INTR ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MASK_SBE_INTR String "DISABLED"
set_parameter_property ENUM_MASK_SBE_INTR VISIBLE false
set_parameter_property ENUM_MASK_SBE_INTR DERIVED true
set_parameter_property ENUM_MASK_SBE_INTR DISPLAY_NAME "mask_sbe_intr"
set_parameter_property ENUM_MASK_SBE_INTR ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_AL String "AL_0"
set_parameter_property ENUM_MEM_IF_AL VISIBLE false
set_parameter_property ENUM_MEM_IF_AL DERIVED true
set_parameter_property ENUM_MEM_IF_AL DISPLAY_NAME "mem_if_al"
set_parameter_property ENUM_MEM_IF_AL ALLOWED_RANGES {"AL_0" "AL_1" "AL_2" "AL_3" "AL_4" "AL_5" "AL_6" "AL_7" "AL_8" "AL_9" "AL_10"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_BANKADDR_WIDTH String "ADDR_WIDTH_3"
set_parameter_property ENUM_MEM_IF_BANKADDR_WIDTH VISIBLE false
set_parameter_property ENUM_MEM_IF_BANKADDR_WIDTH DERIVED true
set_parameter_property ENUM_MEM_IF_BANKADDR_WIDTH DISPLAY_NAME "mem_if_bankaddr_width"
set_parameter_property ENUM_MEM_IF_BANKADDR_WIDTH ALLOWED_RANGES {"ADDR_WIDTH_2" "ADDR_WIDTH_3"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_BURSTLENGTH String "MEM_IF_BURSTLENGTH_8"
set_parameter_property ENUM_MEM_IF_BURSTLENGTH VISIBLE false
set_parameter_property ENUM_MEM_IF_BURSTLENGTH DERIVED true
set_parameter_property ENUM_MEM_IF_BURSTLENGTH DISPLAY_NAME "mem_if_burstlength"
set_parameter_property ENUM_MEM_IF_BURSTLENGTH ALLOWED_RANGES {"MEM_IF_BURSTLENGTH_2" "MEM_IF_BURSTLENGTH_4" "MEM_IF_BURSTLENGTH_8" "MEM_IF_BURSTLENGTH_16"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_COLADDR_WIDTH String "ADDR_WIDTH_12"
set_parameter_property ENUM_MEM_IF_COLADDR_WIDTH VISIBLE false
set_parameter_property ENUM_MEM_IF_COLADDR_WIDTH DERIVED true
set_parameter_property ENUM_MEM_IF_COLADDR_WIDTH DISPLAY_NAME "mem_if_coladdr_width"
set_parameter_property ENUM_MEM_IF_COLADDR_WIDTH ALLOWED_RANGES {"ADDR_WIDTH_8" "ADDR_WIDTH_9" "ADDR_WIDTH_10" "ADDR_WIDTH_11" "ADDR_WIDTH_12"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_CS_PER_RANK String "MEM_IF_CS_PER_RANK_1"
set_parameter_property ENUM_MEM_IF_CS_PER_RANK VISIBLE false
set_parameter_property ENUM_MEM_IF_CS_PER_RANK DERIVED true
set_parameter_property ENUM_MEM_IF_CS_PER_RANK DISPLAY_NAME "mem_if_cs_per_rank"
set_parameter_property ENUM_MEM_IF_CS_PER_RANK ALLOWED_RANGES {"MEM_IF_CS_PER_RANK_1" "MEM_IF_CS_PER_RANK_2"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_CS_WIDTH String "MEM_IF_CS_WIDTH_1"
set_parameter_property ENUM_MEM_IF_CS_WIDTH VISIBLE false
set_parameter_property ENUM_MEM_IF_CS_WIDTH DERIVED true
set_parameter_property ENUM_MEM_IF_CS_WIDTH DISPLAY_NAME "mem_if_cs_width"
set_parameter_property ENUM_MEM_IF_CS_WIDTH ALLOWED_RANGES {"MEM_IF_CS_WIDTH_1" "MEM_IF_CS_WIDTH_2" "MEM_IF_CS_WIDTH_4" "MEM_IF_CS_WIDTH_8"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_DQ_PER_CHIP String "MEM_IF_DQ_PER_CHIP_8"
set_parameter_property ENUM_MEM_IF_DQ_PER_CHIP VISIBLE false
set_parameter_property ENUM_MEM_IF_DQ_PER_CHIP DERIVED true
set_parameter_property ENUM_MEM_IF_DQ_PER_CHIP DISPLAY_NAME "mem_if_dq_per_chip"
set_parameter_property ENUM_MEM_IF_DQ_PER_CHIP ALLOWED_RANGES {"MEM_IF_DQ_PER_CHIP_4" "MEM_IF_DQ_PER_CHIP_8" "MEM_IF_DQ_PER_CHIP_16" "MEM_IF_DQ_PER_CHIP_32"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_DQS_WIDTH String "DQS_WIDTH_4"
set_parameter_property ENUM_MEM_IF_DQS_WIDTH VISIBLE false
set_parameter_property ENUM_MEM_IF_DQS_WIDTH DERIVED true
set_parameter_property ENUM_MEM_IF_DQS_WIDTH DISPLAY_NAME "mem_if_dqs_width"
set_parameter_property ENUM_MEM_IF_DQS_WIDTH ALLOWED_RANGES {"DQS_WIDTH_1" "DQS_WIDTH_2" "DQS_WIDTH_3" "DQS_WIDTH_4" "DQS_WIDTH_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_DWIDTH String "MEM_IF_DWIDTH_32"
set_parameter_property ENUM_MEM_IF_DWIDTH VISIBLE false
set_parameter_property ENUM_MEM_IF_DWIDTH DERIVED true
set_parameter_property ENUM_MEM_IF_DWIDTH DISPLAY_NAME "mem_if_dwidth"
set_parameter_property ENUM_MEM_IF_DWIDTH ALLOWED_RANGES {"MEM_IF_DWIDTH_8" "MEM_IF_DWIDTH_16" "MEM_IF_DWIDTH_24" "MEM_IF_DWIDTH_32" "MEM_IF_DWIDTH_40"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_MEMTYPE String "DDR3_SDRAM"
set_parameter_property ENUM_MEM_IF_MEMTYPE VISIBLE false
set_parameter_property ENUM_MEM_IF_MEMTYPE DERIVED true
set_parameter_property ENUM_MEM_IF_MEMTYPE DISPLAY_NAME "mem_if_memtype"
set_parameter_property ENUM_MEM_IF_MEMTYPE ALLOWED_RANGES {"DDR_SDRAM" "DDR2_SDRAM" "DDR3_SDRAM" "LPDDR2_SDRAM"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_ROWADDR_WIDTH String "ADDR_WIDTH_16"
set_parameter_property ENUM_MEM_IF_ROWADDR_WIDTH VISIBLE false
set_parameter_property ENUM_MEM_IF_ROWADDR_WIDTH DERIVED true
set_parameter_property ENUM_MEM_IF_ROWADDR_WIDTH DISPLAY_NAME "mem_if_rowaddr_width"
set_parameter_property ENUM_MEM_IF_ROWADDR_WIDTH ALLOWED_RANGES {"ADDR_WIDTH_12" "ADDR_WIDTH_13" "ADDR_WIDTH_14" "ADDR_WIDTH_15" "ADDR_WIDTH_16"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_SPEEDBIN String "DDR3_1066_6_6_6"
set_parameter_property ENUM_MEM_IF_SPEEDBIN VISIBLE false
set_parameter_property ENUM_MEM_IF_SPEEDBIN DERIVED true
set_parameter_property ENUM_MEM_IF_SPEEDBIN DISPLAY_NAME "mem_if_speedbin"
set_parameter_property ENUM_MEM_IF_SPEEDBIN ALLOWED_RANGES {"DDR_400_3_3_3" "DDR2_400_3_3_3" "DDR2_400_4_4_4" "DDR2_533_3_3_3" "DDR2_533_4_4_4" "DDR2_667_4_4_4" "DDR2_667_5_5_5" "DDR2_800_4_4_4" "DDR2_800_5_5_5" "DDR2_800_6_6_6" "DDR3_800_5_5_5" "DDR3_800_6_6_6" "DDR3_1066_6_6_6" "DDR3_1066_7_7_7" "DDR3_1066_8_8_8" "DDR3_1333_7_7_7" "DDR3_1333_8_8_8" "DDR3_1333_9_9_9" "DDR3_1333_10_10_10" "DDR3_1600_8_8_8" "DDR3_1600_9_9_9" "DDR3_1600_10_10_10" "DDR3_1600_11_11_11"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TCCD String "TCCD_4"
set_parameter_property ENUM_MEM_IF_TCCD VISIBLE false
set_parameter_property ENUM_MEM_IF_TCCD DERIVED true
set_parameter_property ENUM_MEM_IF_TCCD DISPLAY_NAME "mem_if_tccd"
set_parameter_property ENUM_MEM_IF_TCCD ALLOWED_RANGES {"TCCD_0" "TCCD_1" "TCCD_2" "TCCD_3" "TCCD_4"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TCL String "TCL_6"
set_parameter_property ENUM_MEM_IF_TCL VISIBLE false
set_parameter_property ENUM_MEM_IF_TCL DERIVED true
set_parameter_property ENUM_MEM_IF_TCL DISPLAY_NAME "mem_if_tcl"
set_parameter_property ENUM_MEM_IF_TCL ALLOWED_RANGES {"TCL_3" "TCL_4" "TCL_5" "TCL_6" "TCL_7" "TCL_8" "TCL_9" "TCL_10" "TCL_11"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TCWL String "TCWL_5"
set_parameter_property ENUM_MEM_IF_TCWL VISIBLE false
set_parameter_property ENUM_MEM_IF_TCWL DERIVED true
set_parameter_property ENUM_MEM_IF_TCWL DISPLAY_NAME "mem_if_tcwl"
set_parameter_property ENUM_MEM_IF_TCWL ALLOWED_RANGES {"TCWL_0" "TCWL_1" "TCWL_2" "TCWL_3" "TCWL_4" "TCWL_5" "TCWL_6" "TCWL_7" "TCWL_8"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TFAW String "TFAW_16"
set_parameter_property ENUM_MEM_IF_TFAW VISIBLE false
set_parameter_property ENUM_MEM_IF_TFAW DERIVED true
set_parameter_property ENUM_MEM_IF_TFAW DISPLAY_NAME "mem_if_tfaw"
set_parameter_property ENUM_MEM_IF_TFAW ALLOWED_RANGES {"TFAW_0" "TFAW_1" "TFAW_2" "TFAW_3" "TFAW_4" "TFAW_5" "TFAW_6" "TFAW_7" "TFAW_8" "TFAW_9" "TFAW_10" "TFAW_11" "TFAW_12" "TFAW_13" "TFAW_14" "TFAW_15" "TFAW_16" "TFAW_17" "TFAW_18" "TFAW_19" "TFAW_20" "TFAW_21" "TFAW_22" "TFAW_23" "TFAW_24" "TFAW_25" "TFAW_26" "TFAW_27" "TFAW_28" "TFAW_29" "TFAW_30" "TFAW_31" "TFAW_32"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TMRD String ""
set_parameter_property ENUM_MEM_IF_TMRD VISIBLE false
set_parameter_property ENUM_MEM_IF_TMRD DERIVED true
set_parameter_property ENUM_MEM_IF_TMRD DISPLAY_NAME "mem_if_tmrd"

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TRAS String "TRAS_16"
set_parameter_property ENUM_MEM_IF_TRAS VISIBLE false
set_parameter_property ENUM_MEM_IF_TRAS DERIVED true
set_parameter_property ENUM_MEM_IF_TRAS DISPLAY_NAME "mem_if_tras"
set_parameter_property ENUM_MEM_IF_TRAS ALLOWED_RANGES {"TRAS_0" "TRAS_1" "TRAS_2" "TRAS_3" "TRAS_4" "TRAS_5" "TRAS_6" "TRAS_7" "TRAS_8" "TRAS_9" "TRAS_10" "TRAS_11" "TRAS_12" "TRAS_13" "TRAS_14" "TRAS_15" "TRAS_16" "TRAS_17" "TRAS_18" "TRAS_19" "TRAS_20" "TRAS_21" "TRAS_22" "TRAS_23" "TRAS_24" "TRAS_25" "TRAS_26" "TRAS_27" "TRAS_28" "TRAS_29"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TRC String "TRC_22"
set_parameter_property ENUM_MEM_IF_TRC VISIBLE false
set_parameter_property ENUM_MEM_IF_TRC DERIVED true
set_parameter_property ENUM_MEM_IF_TRC DISPLAY_NAME "mem_if_trc"
set_parameter_property ENUM_MEM_IF_TRC ALLOWED_RANGES {"TRC_0" "TRC_1" "TRC_2" "TRC_3" "TRC_4" "TRC_5" "TRC_6" "TRC_7" "TRC_8" "TRC_9" "TRC_10" "TRC_11" "TRC_12" "TRC_13" "TRC_14" "TRC_15" "TRC_16" "TRC_17" "TRC_18" "TRC_19" "TRC_20" "TRC_21" "TRC_22" "TRC_23" "TRC_24" "TRC_25" "TRC_26" "TRC_27" "TRC_28" "TRC_29" "TRC_30" "TRC_31" "TRC_32" "TRC_33" "TRC_34" "TRC_35" "TRC_36" "TRC_37" "TRC_38" "TRC_39" "TRC_40"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TRCD String "TRCD_6"
set_parameter_property ENUM_MEM_IF_TRCD VISIBLE false
set_parameter_property ENUM_MEM_IF_TRCD DERIVED true
set_parameter_property ENUM_MEM_IF_TRCD DISPLAY_NAME "mem_if_trcd"
set_parameter_property ENUM_MEM_IF_TRCD ALLOWED_RANGES {"TRCD_0" "TRCD_1" "TRCD_2" "TRCD_3" "TRCD_4" "TRCD_5" "TRCD_6" "TRCD_7" "TRCD_8" "TRCD_9" "TRCD_10" "TRCD_11"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TRP String "TRP_6"
set_parameter_property ENUM_MEM_IF_TRP VISIBLE false
set_parameter_property ENUM_MEM_IF_TRP DERIVED true
set_parameter_property ENUM_MEM_IF_TRP DISPLAY_NAME "mem_if_trp"
set_parameter_property ENUM_MEM_IF_TRP ALLOWED_RANGES {"TRP_2" "TRP_3" "TRP_4" "TRP_5" "TRP_6" "TRP_7" "TRP_8" "TRP_9"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TRRD String "TRRD_4"
set_parameter_property ENUM_MEM_IF_TRRD VISIBLE false
set_parameter_property ENUM_MEM_IF_TRRD DERIVED true
set_parameter_property ENUM_MEM_IF_TRRD DISPLAY_NAME "mem_if_trrd"
set_parameter_property ENUM_MEM_IF_TRRD ALLOWED_RANGES {"TRRD_1" "TRRD_2" "TRRD_3" "TRRD_4" "TRRD_5" "TRRD_6"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TRTP String "TRTP_4"
set_parameter_property ENUM_MEM_IF_TRTP VISIBLE false
set_parameter_property ENUM_MEM_IF_TRTP DERIVED true
set_parameter_property ENUM_MEM_IF_TRTP DISPLAY_NAME "mem_if_trtp"
set_parameter_property ENUM_MEM_IF_TRTP ALLOWED_RANGES {"TRTP_0" "TRTP_1" "TRTP_2" "TRTP_3" "TRTP_4" "TRTP_5" "TRTP_6" "TRTP_7" "TRTP_8"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TWR String "TWR_6"
set_parameter_property ENUM_MEM_IF_TWR VISIBLE false
set_parameter_property ENUM_MEM_IF_TWR DERIVED true
set_parameter_property ENUM_MEM_IF_TWR DISPLAY_NAME "mem_if_twr"
set_parameter_property ENUM_MEM_IF_TWR ALLOWED_RANGES {"TWR_1" "TWR_2" "TWR_3" "TWR_4" "TWR_5" "TWR_6" "TWR_7" "TWR_8" "TWR_9" "TWR_10" "TWR_11" "TWR_12"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MEM_IF_TWTR String "TWTR_4"
set_parameter_property ENUM_MEM_IF_TWTR VISIBLE false
set_parameter_property ENUM_MEM_IF_TWTR DERIVED true
set_parameter_property ENUM_MEM_IF_TWTR DISPLAY_NAME "mem_if_twtr"
set_parameter_property ENUM_MEM_IF_TWTR ALLOWED_RANGES {"TWTR_0" "TWTR_1" "TWTR_2" "TWTR_3" "TWTR_4" "TWTR_5" "TWTR_6" "TWTR_7" "TWTR_8"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_MMR_CFG_MEM_BL String "MP_BL_8"
set_parameter_property ENUM_MMR_CFG_MEM_BL VISIBLE false
set_parameter_property ENUM_MMR_CFG_MEM_BL DERIVED true
set_parameter_property ENUM_MMR_CFG_MEM_BL DISPLAY_NAME "mmr_cfg_mem_bl"
set_parameter_property ENUM_MMR_CFG_MEM_BL ALLOWED_RANGES {"MP_BL_2" "MP_BL_4" "MP_BL_8" "MP_BL_16"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_OUTPUT_REGD String "DISABLED"
set_parameter_property ENUM_OUTPUT_REGD VISIBLE false
set_parameter_property ENUM_OUTPUT_REGD DERIVED true
set_parameter_property ENUM_OUTPUT_REGD DISPLAY_NAME "output_regd"
set_parameter_property ENUM_OUTPUT_REGD ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PDN_EXIT_CYCLES String "SLOW_EXIT"
set_parameter_property ENUM_PDN_EXIT_CYCLES VISIBLE false
set_parameter_property ENUM_PDN_EXIT_CYCLES DERIVED true
set_parameter_property ENUM_PDN_EXIT_CYCLES DISPLAY_NAME "pdn_exit_cycles"
set_parameter_property ENUM_PDN_EXIT_CYCLES ALLOWED_RANGES {"FAST_EXIT" "SLOW_EXIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PORT0_WIDTH String "PORT_64_BIT"
set_parameter_property ENUM_PORT0_WIDTH VISIBLE false
set_parameter_property ENUM_PORT0_WIDTH DERIVED true
set_parameter_property ENUM_PORT0_WIDTH DISPLAY_NAME "port0_width"
set_parameter_property ENUM_PORT0_WIDTH ALLOWED_RANGES {"PORT_32_BIT" "PORT_64_BIT" "PORT_128_BIT" "PORT_256_BIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PORT1_WIDTH String "PORT_64_BIT"
set_parameter_property ENUM_PORT1_WIDTH VISIBLE false
set_parameter_property ENUM_PORT1_WIDTH DERIVED true
set_parameter_property ENUM_PORT1_WIDTH DISPLAY_NAME "port1_width"
set_parameter_property ENUM_PORT1_WIDTH ALLOWED_RANGES {"PORT_32_BIT" "PORT_64_BIT" "PORT_128_BIT" "PORT_256_BIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PORT2_WIDTH String "PORT_64_BIT"
set_parameter_property ENUM_PORT2_WIDTH VISIBLE false
set_parameter_property ENUM_PORT2_WIDTH DERIVED true
set_parameter_property ENUM_PORT2_WIDTH DISPLAY_NAME "port2_width"
set_parameter_property ENUM_PORT2_WIDTH ALLOWED_RANGES {"PORT_32_BIT" "PORT_64_BIT" "PORT_128_BIT" "PORT_256_BIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PORT3_WIDTH String "PORT_64_BIT"
set_parameter_property ENUM_PORT3_WIDTH VISIBLE false
set_parameter_property ENUM_PORT3_WIDTH DERIVED true
set_parameter_property ENUM_PORT3_WIDTH DISPLAY_NAME "port3_width"
set_parameter_property ENUM_PORT3_WIDTH ALLOWED_RANGES {"PORT_32_BIT" "PORT_64_BIT" "PORT_128_BIT" "PORT_256_BIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PORT4_WIDTH String "PORT_64_BIT"
set_parameter_property ENUM_PORT4_WIDTH VISIBLE false
set_parameter_property ENUM_PORT4_WIDTH DERIVED true
set_parameter_property ENUM_PORT4_WIDTH DISPLAY_NAME "port4_width"
set_parameter_property ENUM_PORT4_WIDTH ALLOWED_RANGES {"PORT_32_BIT" "PORT_64_BIT" "PORT_128_BIT" "PORT_256_BIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PORT5_WIDTH String "PORT_64_BIT"
set_parameter_property ENUM_PORT5_WIDTH VISIBLE false
set_parameter_property ENUM_PORT5_WIDTH DERIVED true
set_parameter_property ENUM_PORT5_WIDTH DISPLAY_NAME "port5_width"
set_parameter_property ENUM_PORT5_WIDTH ALLOWED_RANGES {"PORT_32_BIT" "PORT_64_BIT" "PORT_128_BIT" "PORT_256_BIT"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_0_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_0_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_0_0 DERIVED true
set_parameter_property ENUM_PRIORITY_0_0 DISPLAY_NAME "priority_0_0"
set_parameter_property ENUM_PRIORITY_0_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_0_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_0_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_0_1 DERIVED true
set_parameter_property ENUM_PRIORITY_0_1 DISPLAY_NAME "priority_0_1"
set_parameter_property ENUM_PRIORITY_0_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_0_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_0_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_0_2 DERIVED true
set_parameter_property ENUM_PRIORITY_0_2 DISPLAY_NAME "priority_0_2"
set_parameter_property ENUM_PRIORITY_0_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_0_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_0_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_0_3 DERIVED true
set_parameter_property ENUM_PRIORITY_0_3 DISPLAY_NAME "priority_0_3"
set_parameter_property ENUM_PRIORITY_0_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_0_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_0_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_0_4 DERIVED true
set_parameter_property ENUM_PRIORITY_0_4 DISPLAY_NAME "priority_0_4"
set_parameter_property ENUM_PRIORITY_0_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_0_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_0_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_0_5 DERIVED true
set_parameter_property ENUM_PRIORITY_0_5 DISPLAY_NAME "priority_0_5"
set_parameter_property ENUM_PRIORITY_0_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_1_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_1_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_1_0 DERIVED true
set_parameter_property ENUM_PRIORITY_1_0 DISPLAY_NAME "priority_1_0"
set_parameter_property ENUM_PRIORITY_1_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_1_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_1_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_1_1 DERIVED true
set_parameter_property ENUM_PRIORITY_1_1 DISPLAY_NAME "priority_1_1"
set_parameter_property ENUM_PRIORITY_1_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_1_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_1_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_1_2 DERIVED true
set_parameter_property ENUM_PRIORITY_1_2 DISPLAY_NAME "priority_1_2"
set_parameter_property ENUM_PRIORITY_1_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_1_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_1_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_1_3 DERIVED true
set_parameter_property ENUM_PRIORITY_1_3 DISPLAY_NAME "priority_1_3"
set_parameter_property ENUM_PRIORITY_1_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_1_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_1_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_1_4 DERIVED true
set_parameter_property ENUM_PRIORITY_1_4 DISPLAY_NAME "priority_1_4"
set_parameter_property ENUM_PRIORITY_1_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_1_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_1_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_1_5 DERIVED true
set_parameter_property ENUM_PRIORITY_1_5 DISPLAY_NAME "priority_1_5"
set_parameter_property ENUM_PRIORITY_1_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_2_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_2_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_2_0 DERIVED true
set_parameter_property ENUM_PRIORITY_2_0 DISPLAY_NAME "priority_2_0"
set_parameter_property ENUM_PRIORITY_2_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_2_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_2_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_2_1 DERIVED true
set_parameter_property ENUM_PRIORITY_2_1 DISPLAY_NAME "priority_2_1"
set_parameter_property ENUM_PRIORITY_2_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_2_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_2_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_2_2 DERIVED true
set_parameter_property ENUM_PRIORITY_2_2 DISPLAY_NAME "priority_2_2"
set_parameter_property ENUM_PRIORITY_2_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_2_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_2_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_2_3 DERIVED true
set_parameter_property ENUM_PRIORITY_2_3 DISPLAY_NAME "priority_2_3"
set_parameter_property ENUM_PRIORITY_2_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_2_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_2_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_2_4 DERIVED true
set_parameter_property ENUM_PRIORITY_2_4 DISPLAY_NAME "priority_2_4"
set_parameter_property ENUM_PRIORITY_2_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_2_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_2_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_2_5 DERIVED true
set_parameter_property ENUM_PRIORITY_2_5 DISPLAY_NAME "priority_2_5"
set_parameter_property ENUM_PRIORITY_2_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_3_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_3_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_3_0 DERIVED true
set_parameter_property ENUM_PRIORITY_3_0 DISPLAY_NAME "priority_3_0"
set_parameter_property ENUM_PRIORITY_3_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_3_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_3_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_3_1 DERIVED true
set_parameter_property ENUM_PRIORITY_3_1 DISPLAY_NAME "priority_3_1"
set_parameter_property ENUM_PRIORITY_3_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_3_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_3_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_3_2 DERIVED true
set_parameter_property ENUM_PRIORITY_3_2 DISPLAY_NAME "priority_3_2"
set_parameter_property ENUM_PRIORITY_3_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_3_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_3_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_3_3 DERIVED true
set_parameter_property ENUM_PRIORITY_3_3 DISPLAY_NAME "priority_3_3"
set_parameter_property ENUM_PRIORITY_3_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_3_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_3_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_3_4 DERIVED true
set_parameter_property ENUM_PRIORITY_3_4 DISPLAY_NAME "priority_3_4"
set_parameter_property ENUM_PRIORITY_3_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_3_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_3_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_3_5 DERIVED true
set_parameter_property ENUM_PRIORITY_3_5 DISPLAY_NAME "priority_3_5"
set_parameter_property ENUM_PRIORITY_3_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_4_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_4_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_4_0 DERIVED true
set_parameter_property ENUM_PRIORITY_4_0 DISPLAY_NAME "priority_4_0"
set_parameter_property ENUM_PRIORITY_4_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_4_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_4_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_4_1 DERIVED true
set_parameter_property ENUM_PRIORITY_4_1 DISPLAY_NAME "priority_4_1"
set_parameter_property ENUM_PRIORITY_4_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_4_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_4_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_4_2 DERIVED true
set_parameter_property ENUM_PRIORITY_4_2 DISPLAY_NAME "priority_4_2"
set_parameter_property ENUM_PRIORITY_4_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_4_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_4_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_4_3 DERIVED true
set_parameter_property ENUM_PRIORITY_4_3 DISPLAY_NAME "priority_4_3"
set_parameter_property ENUM_PRIORITY_4_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_4_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_4_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_4_4 DERIVED true
set_parameter_property ENUM_PRIORITY_4_4 DISPLAY_NAME "priority_4_4"
set_parameter_property ENUM_PRIORITY_4_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_4_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_4_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_4_5 DERIVED true
set_parameter_property ENUM_PRIORITY_4_5 DISPLAY_NAME "priority_4_5"
set_parameter_property ENUM_PRIORITY_4_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_5_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_5_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_5_0 DERIVED true
set_parameter_property ENUM_PRIORITY_5_0 DISPLAY_NAME "priority_5_0"
set_parameter_property ENUM_PRIORITY_5_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_5_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_5_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_5_1 DERIVED true
set_parameter_property ENUM_PRIORITY_5_1 DISPLAY_NAME "priority_5_1"
set_parameter_property ENUM_PRIORITY_5_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_5_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_5_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_5_2 DERIVED true
set_parameter_property ENUM_PRIORITY_5_2 DISPLAY_NAME "priority_5_2"
set_parameter_property ENUM_PRIORITY_5_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_5_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_5_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_5_3 DERIVED true
set_parameter_property ENUM_PRIORITY_5_3 DISPLAY_NAME "priority_5_3"
set_parameter_property ENUM_PRIORITY_5_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_5_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_5_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_5_4 DERIVED true
set_parameter_property ENUM_PRIORITY_5_4 DISPLAY_NAME "priority_5_4"
set_parameter_property ENUM_PRIORITY_5_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_5_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_5_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_5_5 DERIVED true
set_parameter_property ENUM_PRIORITY_5_5 DISPLAY_NAME "priority_5_5"
set_parameter_property ENUM_PRIORITY_5_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_6_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_6_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_6_0 DERIVED true
set_parameter_property ENUM_PRIORITY_6_0 DISPLAY_NAME "priority_6_0"
set_parameter_property ENUM_PRIORITY_6_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_6_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_6_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_6_1 DERIVED true
set_parameter_property ENUM_PRIORITY_6_1 DISPLAY_NAME "priority_6_1"
set_parameter_property ENUM_PRIORITY_6_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_6_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_6_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_6_2 DERIVED true
set_parameter_property ENUM_PRIORITY_6_2 DISPLAY_NAME "priority_6_2"
set_parameter_property ENUM_PRIORITY_6_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_6_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_6_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_6_3 DERIVED true
set_parameter_property ENUM_PRIORITY_6_3 DISPLAY_NAME "priority_6_3"
set_parameter_property ENUM_PRIORITY_6_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_6_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_6_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_6_4 DERIVED true
set_parameter_property ENUM_PRIORITY_6_4 DISPLAY_NAME "priority_6_4"
set_parameter_property ENUM_PRIORITY_6_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_6_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_6_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_6_5 DERIVED true
set_parameter_property ENUM_PRIORITY_6_5 DISPLAY_NAME "priority_6_5"
set_parameter_property ENUM_PRIORITY_6_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_7_0 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_7_0 VISIBLE false
set_parameter_property ENUM_PRIORITY_7_0 DERIVED true
set_parameter_property ENUM_PRIORITY_7_0 DISPLAY_NAME "priority_7_0"
set_parameter_property ENUM_PRIORITY_7_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_7_1 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_7_1 VISIBLE false
set_parameter_property ENUM_PRIORITY_7_1 DERIVED true
set_parameter_property ENUM_PRIORITY_7_1 DISPLAY_NAME "priority_7_1"
set_parameter_property ENUM_PRIORITY_7_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_7_2 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_7_2 VISIBLE false
set_parameter_property ENUM_PRIORITY_7_2 DERIVED true
set_parameter_property ENUM_PRIORITY_7_2 DISPLAY_NAME "priority_7_2"
set_parameter_property ENUM_PRIORITY_7_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_7_3 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_7_3 VISIBLE false
set_parameter_property ENUM_PRIORITY_7_3 DERIVED true
set_parameter_property ENUM_PRIORITY_7_3 DISPLAY_NAME "priority_7_3"
set_parameter_property ENUM_PRIORITY_7_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_7_4 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_7_4 VISIBLE false
set_parameter_property ENUM_PRIORITY_7_4 DERIVED true
set_parameter_property ENUM_PRIORITY_7_4 DISPLAY_NAME "priority_7_4"
set_parameter_property ENUM_PRIORITY_7_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_PRIORITY_7_5 String "WEIGHT_0"
set_parameter_property ENUM_PRIORITY_7_5 VISIBLE false
set_parameter_property ENUM_PRIORITY_7_5 DERIVED true
set_parameter_property ENUM_PRIORITY_7_5 DISPLAY_NAME "priority_7_5"
set_parameter_property ENUM_PRIORITY_7_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_STATIC_WEIGHT_0 String "WEIGHT_0"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_0 VISIBLE false
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_0 DERIVED true
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_0 DISPLAY_NAME "rcfg_static_weight_0"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_STATIC_WEIGHT_1 String "WEIGHT_0"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_1 VISIBLE false
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_1 DERIVED true
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_1 DISPLAY_NAME "rcfg_static_weight_1"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_STATIC_WEIGHT_2 String "WEIGHT_0"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_2 VISIBLE false
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_2 DERIVED true
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_2 DISPLAY_NAME "rcfg_static_weight_2"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_STATIC_WEIGHT_3 String "WEIGHT_0"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_3 VISIBLE false
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_3 DERIVED true
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_3 DISPLAY_NAME "rcfg_static_weight_3"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_STATIC_WEIGHT_4 String "WEIGHT_0"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_4 VISIBLE false
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_4 DERIVED true
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_4 DISPLAY_NAME "rcfg_static_weight_4"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_STATIC_WEIGHT_5 String "WEIGHT_0"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_5 VISIBLE false
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_5 DERIVED true
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_5 DISPLAY_NAME "rcfg_static_weight_5"
set_parameter_property ENUM_RCFG_STATIC_WEIGHT_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_USER_PRIORITY_0 String "PRIORITY_0"
set_parameter_property ENUM_RCFG_USER_PRIORITY_0 VISIBLE false
set_parameter_property ENUM_RCFG_USER_PRIORITY_0 DERIVED true
set_parameter_property ENUM_RCFG_USER_PRIORITY_0 DISPLAY_NAME "rcfg_user_priority_0"
set_parameter_property ENUM_RCFG_USER_PRIORITY_0 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_USER_PRIORITY_1 String "PRIORITY_0"
set_parameter_property ENUM_RCFG_USER_PRIORITY_1 VISIBLE false
set_parameter_property ENUM_RCFG_USER_PRIORITY_1 DERIVED true
set_parameter_property ENUM_RCFG_USER_PRIORITY_1 DISPLAY_NAME "rcfg_user_priority_1"
set_parameter_property ENUM_RCFG_USER_PRIORITY_1 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_USER_PRIORITY_2 String "PRIORITY_0"
set_parameter_property ENUM_RCFG_USER_PRIORITY_2 VISIBLE false
set_parameter_property ENUM_RCFG_USER_PRIORITY_2 DERIVED true
set_parameter_property ENUM_RCFG_USER_PRIORITY_2 DISPLAY_NAME "rcfg_user_priority_2"
set_parameter_property ENUM_RCFG_USER_PRIORITY_2 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_USER_PRIORITY_3 String "PRIORITY_0"
set_parameter_property ENUM_RCFG_USER_PRIORITY_3 VISIBLE false
set_parameter_property ENUM_RCFG_USER_PRIORITY_3 DERIVED true
set_parameter_property ENUM_RCFG_USER_PRIORITY_3 DISPLAY_NAME "rcfg_user_priority_3"
set_parameter_property ENUM_RCFG_USER_PRIORITY_3 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_USER_PRIORITY_4 String "PRIORITY_0"
set_parameter_property ENUM_RCFG_USER_PRIORITY_4 VISIBLE false
set_parameter_property ENUM_RCFG_USER_PRIORITY_4 DERIVED true
set_parameter_property ENUM_RCFG_USER_PRIORITY_4 DISPLAY_NAME "rcfg_user_priority_4"
set_parameter_property ENUM_RCFG_USER_PRIORITY_4 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RCFG_USER_PRIORITY_5 String "PRIORITY_0"
set_parameter_property ENUM_RCFG_USER_PRIORITY_5 VISIBLE false
set_parameter_property ENUM_RCFG_USER_PRIORITY_5 DERIVED true
set_parameter_property ENUM_RCFG_USER_PRIORITY_5 DISPLAY_NAME "rcfg_user_priority_5"
set_parameter_property ENUM_RCFG_USER_PRIORITY_5 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_DWIDTH_0 String "DWIDTH_0"
set_parameter_property ENUM_RD_DWIDTH_0 VISIBLE false
set_parameter_property ENUM_RD_DWIDTH_0 DERIVED true
set_parameter_property ENUM_RD_DWIDTH_0 DISPLAY_NAME "rd_dwidth_0"
set_parameter_property ENUM_RD_DWIDTH_0 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_DWIDTH_1 String "DWIDTH_0"
set_parameter_property ENUM_RD_DWIDTH_1 VISIBLE false
set_parameter_property ENUM_RD_DWIDTH_1 DERIVED true
set_parameter_property ENUM_RD_DWIDTH_1 DISPLAY_NAME "rd_dwidth_1"
set_parameter_property ENUM_RD_DWIDTH_1 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_DWIDTH_2 String "DWIDTH_0"
set_parameter_property ENUM_RD_DWIDTH_2 VISIBLE false
set_parameter_property ENUM_RD_DWIDTH_2 DERIVED true
set_parameter_property ENUM_RD_DWIDTH_2 DISPLAY_NAME "rd_dwidth_2"
set_parameter_property ENUM_RD_DWIDTH_2 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_DWIDTH_3 String "DWIDTH_0"
set_parameter_property ENUM_RD_DWIDTH_3 VISIBLE false
set_parameter_property ENUM_RD_DWIDTH_3 DERIVED true
set_parameter_property ENUM_RD_DWIDTH_3 DISPLAY_NAME "rd_dwidth_3"
set_parameter_property ENUM_RD_DWIDTH_3 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_DWIDTH_4 String "DWIDTH_0"
set_parameter_property ENUM_RD_DWIDTH_4 VISIBLE false
set_parameter_property ENUM_RD_DWIDTH_4 DERIVED true
set_parameter_property ENUM_RD_DWIDTH_4 DISPLAY_NAME "rd_dwidth_4"
set_parameter_property ENUM_RD_DWIDTH_4 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_DWIDTH_5 String "DWIDTH_0"
set_parameter_property ENUM_RD_DWIDTH_5 VISIBLE false
set_parameter_property ENUM_RD_DWIDTH_5 DERIVED true
set_parameter_property ENUM_RD_DWIDTH_5 DISPLAY_NAME "rd_dwidth_5"
set_parameter_property ENUM_RD_DWIDTH_5 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_FIFO_IN_USE_0 String "FALSE"
set_parameter_property ENUM_RD_FIFO_IN_USE_0 VISIBLE false
set_parameter_property ENUM_RD_FIFO_IN_USE_0 DERIVED true
set_parameter_property ENUM_RD_FIFO_IN_USE_0 DISPLAY_NAME "rd_fifo_in_use_0"
set_parameter_property ENUM_RD_FIFO_IN_USE_0 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_FIFO_IN_USE_1 String "FALSE"
set_parameter_property ENUM_RD_FIFO_IN_USE_1 VISIBLE false
set_parameter_property ENUM_RD_FIFO_IN_USE_1 DERIVED true
set_parameter_property ENUM_RD_FIFO_IN_USE_1 DISPLAY_NAME "rd_fifo_in_use_1"
set_parameter_property ENUM_RD_FIFO_IN_USE_1 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_FIFO_IN_USE_2 String "FALSE"
set_parameter_property ENUM_RD_FIFO_IN_USE_2 VISIBLE false
set_parameter_property ENUM_RD_FIFO_IN_USE_2 DERIVED true
set_parameter_property ENUM_RD_FIFO_IN_USE_2 DISPLAY_NAME "rd_fifo_in_use_2"
set_parameter_property ENUM_RD_FIFO_IN_USE_2 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_FIFO_IN_USE_3 String "FALSE"
set_parameter_property ENUM_RD_FIFO_IN_USE_3 VISIBLE false
set_parameter_property ENUM_RD_FIFO_IN_USE_3 DERIVED true
set_parameter_property ENUM_RD_FIFO_IN_USE_3 DISPLAY_NAME "rd_fifo_in_use_3"
set_parameter_property ENUM_RD_FIFO_IN_USE_3 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_PORT_INFO_0 String "USE_NO"
set_parameter_property ENUM_RD_PORT_INFO_0 VISIBLE false
set_parameter_property ENUM_RD_PORT_INFO_0 DERIVED true
set_parameter_property ENUM_RD_PORT_INFO_0 DISPLAY_NAME "rd_port_info_0"
set_parameter_property ENUM_RD_PORT_INFO_0 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_PORT_INFO_1 String "USE_NO"
set_parameter_property ENUM_RD_PORT_INFO_1 VISIBLE false
set_parameter_property ENUM_RD_PORT_INFO_1 DERIVED true
set_parameter_property ENUM_RD_PORT_INFO_1 DISPLAY_NAME "rd_port_info_1"
set_parameter_property ENUM_RD_PORT_INFO_1 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_PORT_INFO_2 String "USE_NO"
set_parameter_property ENUM_RD_PORT_INFO_2 VISIBLE false
set_parameter_property ENUM_RD_PORT_INFO_2 DERIVED true
set_parameter_property ENUM_RD_PORT_INFO_2 DISPLAY_NAME "rd_port_info_2"
set_parameter_property ENUM_RD_PORT_INFO_2 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_PORT_INFO_3 String "USE_NO"
set_parameter_property ENUM_RD_PORT_INFO_3 VISIBLE false
set_parameter_property ENUM_RD_PORT_INFO_3 DERIVED true
set_parameter_property ENUM_RD_PORT_INFO_3 DISPLAY_NAME "rd_port_info_3"
set_parameter_property ENUM_RD_PORT_INFO_3 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_PORT_INFO_4 String "USE_NO"
set_parameter_property ENUM_RD_PORT_INFO_4 VISIBLE false
set_parameter_property ENUM_RD_PORT_INFO_4 DERIVED true
set_parameter_property ENUM_RD_PORT_INFO_4 DISPLAY_NAME "rd_port_info_4"
set_parameter_property ENUM_RD_PORT_INFO_4 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RD_PORT_INFO_5 String "USE_NO"
set_parameter_property ENUM_RD_PORT_INFO_5 VISIBLE false
set_parameter_property ENUM_RD_PORT_INFO_5 DERIVED true
set_parameter_property ENUM_RD_PORT_INFO_5 DISPLAY_NAME "rd_port_info_5"
set_parameter_property ENUM_RD_PORT_INFO_5 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_READ_ODT_CHIP String "ODT_DISABLED"
set_parameter_property ENUM_READ_ODT_CHIP VISIBLE false
set_parameter_property ENUM_READ_ODT_CHIP DERIVED true
set_parameter_property ENUM_READ_ODT_CHIP DISPLAY_NAME "read_odt_chip"
set_parameter_property ENUM_READ_ODT_CHIP ALLOWED_RANGES {"ODT_DISABLED" "READ_CHIP0_ODT0_CHIP1" "READ_CHIP0_ODT1_CHIP1" "READ_CHIP0_ODT01_CHIP1" "READ_CHIP0_CHIP1_ODT0" "READ_CHIP0_ODT0_CHIP1_ODT0" "READ_CHIP0_ODT1_CHIP1_ODT0" "READ_CHIP0_ODT01_CHIP1_ODT0" "READ_CHIP0_CHIP1_ODT1" "READ_CHIP0_ODT0_CHIP1_ODT1" "READ_CHIP0_ODT1_CHIP1_ODT1" "READ_CHIP0_ODT01_CHIP1_ODT1" "READ_CHIP0_CHIP1_ODT01" "READ_CHIP0_ODT0_CHIP1_ODT01" "READ_CHIP0_ODT1_CHIP1_ODT01" "READ_CHIP0_ODT01_CHIP1_ODT01"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_REORDER_DATA String "DATA_REORDERING"
set_parameter_property ENUM_REORDER_DATA VISIBLE false
set_parameter_property ENUM_REORDER_DATA DERIVED true
set_parameter_property ENUM_REORDER_DATA DISPLAY_NAME "reorder_data"
set_parameter_property ENUM_REORDER_DATA ALLOWED_RANGES {"NO_DATA_REORDERING" "DATA_REORDERING"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RFIFO0_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_RFIFO0_CPORT_MAP VISIBLE false
set_parameter_property ENUM_RFIFO0_CPORT_MAP DERIVED true
set_parameter_property ENUM_RFIFO0_CPORT_MAP DISPLAY_NAME "rfifo0_cport_map"
set_parameter_property ENUM_RFIFO0_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RFIFO1_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_RFIFO1_CPORT_MAP VISIBLE false
set_parameter_property ENUM_RFIFO1_CPORT_MAP DERIVED true
set_parameter_property ENUM_RFIFO1_CPORT_MAP DISPLAY_NAME "rfifo1_cport_map"
set_parameter_property ENUM_RFIFO1_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RFIFO2_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_RFIFO2_CPORT_MAP VISIBLE false
set_parameter_property ENUM_RFIFO2_CPORT_MAP DERIVED true
set_parameter_property ENUM_RFIFO2_CPORT_MAP DISPLAY_NAME "rfifo2_cport_map"
set_parameter_property ENUM_RFIFO2_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_RFIFO3_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_RFIFO3_CPORT_MAP VISIBLE false
set_parameter_property ENUM_RFIFO3_CPORT_MAP DERIVED true
set_parameter_property ENUM_RFIFO3_CPORT_MAP DISPLAY_NAME "rfifo3_cport_map"
set_parameter_property ENUM_RFIFO3_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SINGLE_READY_0 String "CONCATENATE_RDY"
set_parameter_property ENUM_SINGLE_READY_0 VISIBLE false
set_parameter_property ENUM_SINGLE_READY_0 DERIVED true
set_parameter_property ENUM_SINGLE_READY_0 DISPLAY_NAME "single_ready_0"
set_parameter_property ENUM_SINGLE_READY_0 ALLOWED_RANGES {"CONCATENATE_RDY" "SEPARATE_RDY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SINGLE_READY_1 String "CONCATENATE_RDY"
set_parameter_property ENUM_SINGLE_READY_1 VISIBLE false
set_parameter_property ENUM_SINGLE_READY_1 DERIVED true
set_parameter_property ENUM_SINGLE_READY_1 DISPLAY_NAME "single_ready_1"
set_parameter_property ENUM_SINGLE_READY_1 ALLOWED_RANGES {"CONCATENATE_RDY" "SEPARATE_RDY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SINGLE_READY_2 String "CONCATENATE_RDY"
set_parameter_property ENUM_SINGLE_READY_2 VISIBLE false
set_parameter_property ENUM_SINGLE_READY_2 DERIVED true
set_parameter_property ENUM_SINGLE_READY_2 DISPLAY_NAME "single_ready_2"
set_parameter_property ENUM_SINGLE_READY_2 ALLOWED_RANGES {"CONCATENATE_RDY" "SEPARATE_RDY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SINGLE_READY_3 String "CONCATENATE_RDY"
set_parameter_property ENUM_SINGLE_READY_3 VISIBLE false
set_parameter_property ENUM_SINGLE_READY_3 DERIVED true
set_parameter_property ENUM_SINGLE_READY_3 DISPLAY_NAME "single_ready_3"
set_parameter_property ENUM_SINGLE_READY_3 ALLOWED_RANGES {"CONCATENATE_RDY" "SEPARATE_RDY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_STATIC_WEIGHT_0 String "WEIGHT_0"
set_parameter_property ENUM_STATIC_WEIGHT_0 VISIBLE false
set_parameter_property ENUM_STATIC_WEIGHT_0 DERIVED true
set_parameter_property ENUM_STATIC_WEIGHT_0 DISPLAY_NAME "static_weight_0"
set_parameter_property ENUM_STATIC_WEIGHT_0 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_STATIC_WEIGHT_1 String "WEIGHT_0"
set_parameter_property ENUM_STATIC_WEIGHT_1 VISIBLE false
set_parameter_property ENUM_STATIC_WEIGHT_1 DERIVED true
set_parameter_property ENUM_STATIC_WEIGHT_1 DISPLAY_NAME "static_weight_1"
set_parameter_property ENUM_STATIC_WEIGHT_1 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_STATIC_WEIGHT_2 String "WEIGHT_0"
set_parameter_property ENUM_STATIC_WEIGHT_2 VISIBLE false
set_parameter_property ENUM_STATIC_WEIGHT_2 DERIVED true
set_parameter_property ENUM_STATIC_WEIGHT_2 DISPLAY_NAME "static_weight_2"
set_parameter_property ENUM_STATIC_WEIGHT_2 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_STATIC_WEIGHT_3 String "WEIGHT_0"
set_parameter_property ENUM_STATIC_WEIGHT_3 VISIBLE false
set_parameter_property ENUM_STATIC_WEIGHT_3 DERIVED true
set_parameter_property ENUM_STATIC_WEIGHT_3 DISPLAY_NAME "static_weight_3"
set_parameter_property ENUM_STATIC_WEIGHT_3 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_STATIC_WEIGHT_4 String "WEIGHT_0"
set_parameter_property ENUM_STATIC_WEIGHT_4 VISIBLE false
set_parameter_property ENUM_STATIC_WEIGHT_4 DERIVED true
set_parameter_property ENUM_STATIC_WEIGHT_4 DISPLAY_NAME "static_weight_4"
set_parameter_property ENUM_STATIC_WEIGHT_4 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_STATIC_WEIGHT_5 String "WEIGHT_0"
set_parameter_property ENUM_STATIC_WEIGHT_5 VISIBLE false
set_parameter_property ENUM_STATIC_WEIGHT_5 DERIVED true
set_parameter_property ENUM_STATIC_WEIGHT_5 DISPLAY_NAME "static_weight_5"
set_parameter_property ENUM_STATIC_WEIGHT_5 ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SYNC_MODE_0 String "ASYNCHRONOUS"
set_parameter_property ENUM_SYNC_MODE_0 VISIBLE false
set_parameter_property ENUM_SYNC_MODE_0 DERIVED true
set_parameter_property ENUM_SYNC_MODE_0 DISPLAY_NAME "sync_mode_0"
set_parameter_property ENUM_SYNC_MODE_0 ALLOWED_RANGES {"ASYNCHRONOUS" "SYNCHRONOUS"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SYNC_MODE_1 String "ASYNCHRONOUS"
set_parameter_property ENUM_SYNC_MODE_1 VISIBLE false
set_parameter_property ENUM_SYNC_MODE_1 DERIVED true
set_parameter_property ENUM_SYNC_MODE_1 DISPLAY_NAME "sync_mode_1"
set_parameter_property ENUM_SYNC_MODE_1 ALLOWED_RANGES {"ASYNCHRONOUS" "SYNCHRONOUS"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SYNC_MODE_2 String "ASYNCHRONOUS"
set_parameter_property ENUM_SYNC_MODE_2 VISIBLE false
set_parameter_property ENUM_SYNC_MODE_2 DERIVED true
set_parameter_property ENUM_SYNC_MODE_2 DISPLAY_NAME "sync_mode_2"
set_parameter_property ENUM_SYNC_MODE_2 ALLOWED_RANGES {"ASYNCHRONOUS" "SYNCHRONOUS"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SYNC_MODE_3 String "ASYNCHRONOUS"
set_parameter_property ENUM_SYNC_MODE_3 VISIBLE false
set_parameter_property ENUM_SYNC_MODE_3 DERIVED true
set_parameter_property ENUM_SYNC_MODE_3 DISPLAY_NAME "sync_mode_3"
set_parameter_property ENUM_SYNC_MODE_3 ALLOWED_RANGES {"ASYNCHRONOUS" "SYNCHRONOUS"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SYNC_MODE_4 String "ASYNCHRONOUS"
set_parameter_property ENUM_SYNC_MODE_4 VISIBLE false
set_parameter_property ENUM_SYNC_MODE_4 DERIVED true
set_parameter_property ENUM_SYNC_MODE_4 DISPLAY_NAME "sync_mode_4"
set_parameter_property ENUM_SYNC_MODE_4 ALLOWED_RANGES {"ASYNCHRONOUS" "SYNCHRONOUS"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_SYNC_MODE_5 String "ASYNCHRONOUS"
set_parameter_property ENUM_SYNC_MODE_5 VISIBLE false
set_parameter_property ENUM_SYNC_MODE_5 DERIVED true
set_parameter_property ENUM_SYNC_MODE_5 DISPLAY_NAME "sync_mode_5"
set_parameter_property ENUM_SYNC_MODE_5 ALLOWED_RANGES {"ASYNCHRONOUS" "SYNCHRONOUS"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_TEST_MODE String "NORMAL_MODE"
set_parameter_property ENUM_TEST_MODE VISIBLE false
set_parameter_property ENUM_TEST_MODE DERIVED true
set_parameter_property ENUM_TEST_MODE DISPLAY_NAME "test_mode"
set_parameter_property ENUM_TEST_MODE ALLOWED_RANGES {"NORMAL_MODE" "TEST_MODE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR1_0 String "THRESHOLD_32"
set_parameter_property ENUM_THLD_JAR1_0 VISIBLE false
set_parameter_property ENUM_THLD_JAR1_0 DERIVED true
set_parameter_property ENUM_THLD_JAR1_0 DISPLAY_NAME "thld_jar1_0"
set_parameter_property ENUM_THLD_JAR1_0 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR1_1 String "THRESHOLD_32"
set_parameter_property ENUM_THLD_JAR1_1 VISIBLE false
set_parameter_property ENUM_THLD_JAR1_1 DERIVED true
set_parameter_property ENUM_THLD_JAR1_1 DISPLAY_NAME "thld_jar1_1"
set_parameter_property ENUM_THLD_JAR1_1 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR1_2 String "THRESHOLD_32"
set_parameter_property ENUM_THLD_JAR1_2 VISIBLE false
set_parameter_property ENUM_THLD_JAR1_2 DERIVED true
set_parameter_property ENUM_THLD_JAR1_2 DISPLAY_NAME "thld_jar1_2"
set_parameter_property ENUM_THLD_JAR1_2 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR1_3 String "THRESHOLD_32"
set_parameter_property ENUM_THLD_JAR1_3 VISIBLE false
set_parameter_property ENUM_THLD_JAR1_3 DERIVED true
set_parameter_property ENUM_THLD_JAR1_3 DISPLAY_NAME "thld_jar1_3"
set_parameter_property ENUM_THLD_JAR1_3 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR1_4 String "THRESHOLD_32"
set_parameter_property ENUM_THLD_JAR1_4 VISIBLE false
set_parameter_property ENUM_THLD_JAR1_4 DERIVED true
set_parameter_property ENUM_THLD_JAR1_4 DISPLAY_NAME "thld_jar1_4"
set_parameter_property ENUM_THLD_JAR1_4 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR1_5 String "THRESHOLD_32"
set_parameter_property ENUM_THLD_JAR1_5 VISIBLE false
set_parameter_property ENUM_THLD_JAR1_5 DERIVED true
set_parameter_property ENUM_THLD_JAR1_5 DISPLAY_NAME "thld_jar1_5"
set_parameter_property ENUM_THLD_JAR1_5 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR2_0 String "THRESHOLD_16"
set_parameter_property ENUM_THLD_JAR2_0 VISIBLE false
set_parameter_property ENUM_THLD_JAR2_0 DERIVED true
set_parameter_property ENUM_THLD_JAR2_0 DISPLAY_NAME "thld_jar2_0"
set_parameter_property ENUM_THLD_JAR2_0 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR2_1 String "THRESHOLD_16"
set_parameter_property ENUM_THLD_JAR2_1 VISIBLE false
set_parameter_property ENUM_THLD_JAR2_1 DERIVED true
set_parameter_property ENUM_THLD_JAR2_1 DISPLAY_NAME "thld_jar2_1"
set_parameter_property ENUM_THLD_JAR2_1 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR2_2 String "THRESHOLD_16"
set_parameter_property ENUM_THLD_JAR2_2 VISIBLE false
set_parameter_property ENUM_THLD_JAR2_2 DERIVED true
set_parameter_property ENUM_THLD_JAR2_2 DISPLAY_NAME "thld_jar2_2"
set_parameter_property ENUM_THLD_JAR2_2 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR2_3 String "THRESHOLD_16"
set_parameter_property ENUM_THLD_JAR2_3 VISIBLE false
set_parameter_property ENUM_THLD_JAR2_3 DERIVED true
set_parameter_property ENUM_THLD_JAR2_3 DISPLAY_NAME "thld_jar2_3"
set_parameter_property ENUM_THLD_JAR2_3 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR2_4 String "THRESHOLD_16"
set_parameter_property ENUM_THLD_JAR2_4 VISIBLE false
set_parameter_property ENUM_THLD_JAR2_4 DERIVED true
set_parameter_property ENUM_THLD_JAR2_4 DISPLAY_NAME "thld_jar2_4"
set_parameter_property ENUM_THLD_JAR2_4 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_THLD_JAR2_5 String "THRESHOLD_16"
set_parameter_property ENUM_THLD_JAR2_5 VISIBLE false
set_parameter_property ENUM_THLD_JAR2_5 DERIVED true
set_parameter_property ENUM_THLD_JAR2_5 DISPLAY_NAME "thld_jar2_5"
set_parameter_property ENUM_THLD_JAR2_5 ALLOWED_RANGES {"THRESHOLD_1" "THRESHOLD_2" "THRESHOLD_3" "THRESHOLD_4" "THRESHOLD_5" "THRESHOLD_6" "THRESHOLD_7" "THRESHOLD_8" "THRESHOLD_9" "THRESHOLD_10" "THRESHOLD_11" "THRESHOLD_12" "THRESHOLD_13" "THRESHOLD_14" "THRESHOLD_15" "THRESHOLD_16" "THRESHOLD_17" "THRESHOLD_18" "THRESHOLD_19" "THRESHOLD_20" "THRESHOLD_21" "THRESHOLD_22" "THRESHOLD_23" "THRESHOLD_24" "THRESHOLD_25" "THRESHOLD_26" "THRESHOLD_27" "THRESHOLD_28" "THRESHOLD_29" "THRESHOLD_30" "THRESHOLD_31" "THRESHOLD_32" "THRESHOLD_33" "THRESHOLD_34" "THRESHOLD_35" "THRESHOLD_36" "THRESHOLD_37" "THRESHOLD_38" "THRESHOLD_39" "THRESHOLD_40" "THRESHOLD_41" "THRESHOLD_42" "THRESHOLD_43" "THRESHOLD_44" "THRESHOLD_45" "THRESHOLD_46" "THRESHOLD_47" "THRESHOLD_48" "THRESHOLD_49" "THRESHOLD_50" "THRESHOLD_51" "THRESHOLD_52" "THRESHOLD_53" "THRESHOLD_54" "THRESHOLD_55" "THRESHOLD_56" "THRESHOLD_57" "THRESHOLD_58" "THRESHOLD_59" "THRESHOLD_60" "THRESHOLD_61" "THRESHOLD_62" "THRESHOLD_63"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USE_ALMOST_EMPTY_0 String "EMPTY"
set_parameter_property ENUM_USE_ALMOST_EMPTY_0 VISIBLE false
set_parameter_property ENUM_USE_ALMOST_EMPTY_0 DERIVED true
set_parameter_property ENUM_USE_ALMOST_EMPTY_0 DISPLAY_NAME "use_almost_empty_0"
set_parameter_property ENUM_USE_ALMOST_EMPTY_0 ALLOWED_RANGES {"EMPTY" "ALMOST_EMPTY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USE_ALMOST_EMPTY_1 String "EMPTY"
set_parameter_property ENUM_USE_ALMOST_EMPTY_1 VISIBLE false
set_parameter_property ENUM_USE_ALMOST_EMPTY_1 DERIVED true
set_parameter_property ENUM_USE_ALMOST_EMPTY_1 DISPLAY_NAME "use_almost_empty_1"
set_parameter_property ENUM_USE_ALMOST_EMPTY_1 ALLOWED_RANGES {"EMPTY" "ALMOST_EMPTY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USE_ALMOST_EMPTY_2 String "EMPTY"
set_parameter_property ENUM_USE_ALMOST_EMPTY_2 VISIBLE false
set_parameter_property ENUM_USE_ALMOST_EMPTY_2 DERIVED true
set_parameter_property ENUM_USE_ALMOST_EMPTY_2 DISPLAY_NAME "use_almost_empty_2"
set_parameter_property ENUM_USE_ALMOST_EMPTY_2 ALLOWED_RANGES {"EMPTY" "ALMOST_EMPTY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USE_ALMOST_EMPTY_3 String "EMPTY"
set_parameter_property ENUM_USE_ALMOST_EMPTY_3 VISIBLE false
set_parameter_property ENUM_USE_ALMOST_EMPTY_3 DERIVED true
set_parameter_property ENUM_USE_ALMOST_EMPTY_3 DISPLAY_NAME "use_almost_empty_3"
set_parameter_property ENUM_USE_ALMOST_EMPTY_3 ALLOWED_RANGES {"EMPTY" "ALMOST_EMPTY"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USER_ECC_EN String "DISABLE"
set_parameter_property ENUM_USER_ECC_EN VISIBLE false
set_parameter_property ENUM_USER_ECC_EN DERIVED true
set_parameter_property ENUM_USER_ECC_EN DISPLAY_NAME "user_ecc_en"
set_parameter_property ENUM_USER_ECC_EN ALLOWED_RANGES {"DISABLE" "ENABLE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USER_PRIORITY_0 String "PRIORITY_0"
set_parameter_property ENUM_USER_PRIORITY_0 VISIBLE false
set_parameter_property ENUM_USER_PRIORITY_0 DERIVED true
set_parameter_property ENUM_USER_PRIORITY_0 DISPLAY_NAME "user_priority_0"
set_parameter_property ENUM_USER_PRIORITY_0 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USER_PRIORITY_1 String "PRIORITY_0"
set_parameter_property ENUM_USER_PRIORITY_1 VISIBLE false
set_parameter_property ENUM_USER_PRIORITY_1 DERIVED true
set_parameter_property ENUM_USER_PRIORITY_1 DISPLAY_NAME "user_priority_1"
set_parameter_property ENUM_USER_PRIORITY_1 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USER_PRIORITY_2 String "PRIORITY_0"
set_parameter_property ENUM_USER_PRIORITY_2 VISIBLE false
set_parameter_property ENUM_USER_PRIORITY_2 DERIVED true
set_parameter_property ENUM_USER_PRIORITY_2 DISPLAY_NAME "user_priority_2"
set_parameter_property ENUM_USER_PRIORITY_2 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USER_PRIORITY_3 String "PRIORITY_0"
set_parameter_property ENUM_USER_PRIORITY_3 VISIBLE false
set_parameter_property ENUM_USER_PRIORITY_3 DERIVED true
set_parameter_property ENUM_USER_PRIORITY_3 DISPLAY_NAME "user_priority_3"
set_parameter_property ENUM_USER_PRIORITY_3 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USER_PRIORITY_4 String "PRIORITY_0"
set_parameter_property ENUM_USER_PRIORITY_4 VISIBLE false
set_parameter_property ENUM_USER_PRIORITY_4 DERIVED true
set_parameter_property ENUM_USER_PRIORITY_4 DISPLAY_NAME "user_priority_4"
set_parameter_property ENUM_USER_PRIORITY_4 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_USER_PRIORITY_5 String "PRIORITY_0"
set_parameter_property ENUM_USER_PRIORITY_5 VISIBLE false
set_parameter_property ENUM_USER_PRIORITY_5 DERIVED true
set_parameter_property ENUM_USER_PRIORITY_5 DISPLAY_NAME "user_priority_5"
set_parameter_property ENUM_USER_PRIORITY_5 ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO0_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_WFIFO0_CPORT_MAP VISIBLE false
set_parameter_property ENUM_WFIFO0_CPORT_MAP DERIVED true
set_parameter_property ENUM_WFIFO0_CPORT_MAP DISPLAY_NAME "wfifo0_cport_map"
set_parameter_property ENUM_WFIFO0_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO0_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_WFIFO0_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_WFIFO0_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_WFIFO0_RDY_ALMOST_FULL DISPLAY_NAME "wfifo0_rdy_almost_full"
set_parameter_property ENUM_WFIFO0_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO1_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_WFIFO1_CPORT_MAP VISIBLE false
set_parameter_property ENUM_WFIFO1_CPORT_MAP DERIVED true
set_parameter_property ENUM_WFIFO1_CPORT_MAP DISPLAY_NAME "wfifo1_cport_map"
set_parameter_property ENUM_WFIFO1_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO1_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_WFIFO1_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_WFIFO1_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_WFIFO1_RDY_ALMOST_FULL DISPLAY_NAME "wfifo1_rdy_almost_full"
set_parameter_property ENUM_WFIFO1_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO2_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_WFIFO2_CPORT_MAP VISIBLE false
set_parameter_property ENUM_WFIFO2_CPORT_MAP DERIVED true
set_parameter_property ENUM_WFIFO2_CPORT_MAP DISPLAY_NAME "wfifo2_cport_map"
set_parameter_property ENUM_WFIFO2_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO2_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_WFIFO2_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_WFIFO2_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_WFIFO2_RDY_ALMOST_FULL DISPLAY_NAME "wfifo2_rdy_almost_full"
set_parameter_property ENUM_WFIFO2_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO3_CPORT_MAP String "CMD_PORT_0"
set_parameter_property ENUM_WFIFO3_CPORT_MAP VISIBLE false
set_parameter_property ENUM_WFIFO3_CPORT_MAP DERIVED true
set_parameter_property ENUM_WFIFO3_CPORT_MAP DISPLAY_NAME "wfifo3_cport_map"
set_parameter_property ENUM_WFIFO3_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WFIFO3_RDY_ALMOST_FULL String "NOT_FULL"
set_parameter_property ENUM_WFIFO3_RDY_ALMOST_FULL VISIBLE false
set_parameter_property ENUM_WFIFO3_RDY_ALMOST_FULL DERIVED true
set_parameter_property ENUM_WFIFO3_RDY_ALMOST_FULL DISPLAY_NAME "wfifo3_rdy_almost_full"
set_parameter_property ENUM_WFIFO3_RDY_ALMOST_FULL ALLOWED_RANGES {"NOT_FULL" "NOT_ALMOST_FULL"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_DWIDTH_0 String "DWIDTH_0"
set_parameter_property ENUM_WR_DWIDTH_0 VISIBLE false
set_parameter_property ENUM_WR_DWIDTH_0 DERIVED true
set_parameter_property ENUM_WR_DWIDTH_0 DISPLAY_NAME "wr_dwidth_0"
set_parameter_property ENUM_WR_DWIDTH_0 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_DWIDTH_1 String "DWIDTH_0"
set_parameter_property ENUM_WR_DWIDTH_1 VISIBLE false
set_parameter_property ENUM_WR_DWIDTH_1 DERIVED true
set_parameter_property ENUM_WR_DWIDTH_1 DISPLAY_NAME "wr_dwidth_1"
set_parameter_property ENUM_WR_DWIDTH_1 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_DWIDTH_2 String "DWIDTH_0"
set_parameter_property ENUM_WR_DWIDTH_2 VISIBLE false
set_parameter_property ENUM_WR_DWIDTH_2 DERIVED true
set_parameter_property ENUM_WR_DWIDTH_2 DISPLAY_NAME "wr_dwidth_2"
set_parameter_property ENUM_WR_DWIDTH_2 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_DWIDTH_3 String "DWIDTH_0"
set_parameter_property ENUM_WR_DWIDTH_3 VISIBLE false
set_parameter_property ENUM_WR_DWIDTH_3 DERIVED true
set_parameter_property ENUM_WR_DWIDTH_3 DISPLAY_NAME "wr_dwidth_3"
set_parameter_property ENUM_WR_DWIDTH_3 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_DWIDTH_4 String "DWIDTH_0"
set_parameter_property ENUM_WR_DWIDTH_4 VISIBLE false
set_parameter_property ENUM_WR_DWIDTH_4 DERIVED true
set_parameter_property ENUM_WR_DWIDTH_4 DISPLAY_NAME "wr_dwidth_4"
set_parameter_property ENUM_WR_DWIDTH_4 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_DWIDTH_5 String "DWIDTH_0"
set_parameter_property ENUM_WR_DWIDTH_5 VISIBLE false
set_parameter_property ENUM_WR_DWIDTH_5 DERIVED true
set_parameter_property ENUM_WR_DWIDTH_5 DISPLAY_NAME "wr_dwidth_5"
set_parameter_property ENUM_WR_DWIDTH_5 ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_FIFO_IN_USE_0 String "FALSE"
set_parameter_property ENUM_WR_FIFO_IN_USE_0 VISIBLE false
set_parameter_property ENUM_WR_FIFO_IN_USE_0 DERIVED true
set_parameter_property ENUM_WR_FIFO_IN_USE_0 DISPLAY_NAME "wr_fifo_in_use_0"
set_parameter_property ENUM_WR_FIFO_IN_USE_0 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_FIFO_IN_USE_1 String "FALSE"
set_parameter_property ENUM_WR_FIFO_IN_USE_1 VISIBLE false
set_parameter_property ENUM_WR_FIFO_IN_USE_1 DERIVED true
set_parameter_property ENUM_WR_FIFO_IN_USE_1 DISPLAY_NAME "wr_fifo_in_use_1"
set_parameter_property ENUM_WR_FIFO_IN_USE_1 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_FIFO_IN_USE_2 String "FALSE"
set_parameter_property ENUM_WR_FIFO_IN_USE_2 VISIBLE false
set_parameter_property ENUM_WR_FIFO_IN_USE_2 DERIVED true
set_parameter_property ENUM_WR_FIFO_IN_USE_2 DISPLAY_NAME "wr_fifo_in_use_2"
set_parameter_property ENUM_WR_FIFO_IN_USE_2 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_FIFO_IN_USE_3 String "FALSE"
set_parameter_property ENUM_WR_FIFO_IN_USE_3 VISIBLE false
set_parameter_property ENUM_WR_FIFO_IN_USE_3 DERIVED true
set_parameter_property ENUM_WR_FIFO_IN_USE_3 DISPLAY_NAME "wr_fifo_in_use_3"
set_parameter_property ENUM_WR_FIFO_IN_USE_3 ALLOWED_RANGES {"FALSE" "TRUE"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_PORT_INFO_0 String "USE_NO"
set_parameter_property ENUM_WR_PORT_INFO_0 VISIBLE false
set_parameter_property ENUM_WR_PORT_INFO_0 DERIVED true
set_parameter_property ENUM_WR_PORT_INFO_0 DISPLAY_NAME "wr_port_info_0"
set_parameter_property ENUM_WR_PORT_INFO_0 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_PORT_INFO_1 String "USE_NO"
set_parameter_property ENUM_WR_PORT_INFO_1 VISIBLE false
set_parameter_property ENUM_WR_PORT_INFO_1 DERIVED true
set_parameter_property ENUM_WR_PORT_INFO_1 DISPLAY_NAME "wr_port_info_1"
set_parameter_property ENUM_WR_PORT_INFO_1 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_PORT_INFO_2 String "USE_NO"
set_parameter_property ENUM_WR_PORT_INFO_2 VISIBLE false
set_parameter_property ENUM_WR_PORT_INFO_2 DERIVED true
set_parameter_property ENUM_WR_PORT_INFO_2 DISPLAY_NAME "wr_port_info_2"
set_parameter_property ENUM_WR_PORT_INFO_2 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_PORT_INFO_3 String "USE_NO"
set_parameter_property ENUM_WR_PORT_INFO_3 VISIBLE false
set_parameter_property ENUM_WR_PORT_INFO_3 DERIVED true
set_parameter_property ENUM_WR_PORT_INFO_3 DISPLAY_NAME "wr_port_info_3"
set_parameter_property ENUM_WR_PORT_INFO_3 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_PORT_INFO_4 String "USE_NO"
set_parameter_property ENUM_WR_PORT_INFO_4 VISIBLE false
set_parameter_property ENUM_WR_PORT_INFO_4 DERIVED true
set_parameter_property ENUM_WR_PORT_INFO_4 DISPLAY_NAME "wr_port_info_4"
set_parameter_property ENUM_WR_PORT_INFO_4 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WR_PORT_INFO_5 String "USE_NO"
set_parameter_property ENUM_WR_PORT_INFO_5 VISIBLE false
set_parameter_property ENUM_WR_PORT_INFO_5 DERIVED true
set_parameter_property ENUM_WR_PORT_INFO_5 DISPLAY_NAME "wr_port_info_5"
set_parameter_property ENUM_WR_PORT_INFO_5 ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_WRITE_ODT_CHIP String "ODT_DISABLED"
set_parameter_property ENUM_WRITE_ODT_CHIP VISIBLE false
set_parameter_property ENUM_WRITE_ODT_CHIP DERIVED true
set_parameter_property ENUM_WRITE_ODT_CHIP DISPLAY_NAME "write_odt_chip"
set_parameter_property ENUM_WRITE_ODT_CHIP ALLOWED_RANGES {"ODT_DISABLED" "WRITE_CHIP0_ODT0_CHIP1" "WRITE_CHIP0_ODT1_CHIP1" "WRITE_CHIP0_ODT01_CHIP1" "WRITE_CHIP0_CHIP1_ODT0" "WRITE_CHIP0_ODT0_CHIP1_ODT0" "WRITE_CHIP0_ODT1_CHIP1_ODT0" "WRITE_CHIP0_ODT01_CHIP1_ODT0" "WRITE_CHIP0_CHIP1_ODT1" "WRITE_CHIP0_ODT0_CHIP1_ODT1" "WRITE_CHIP0_ODT1_CHIP1_ODT1" "WRITE_CHIP0_ODT01_CHIP1_ODT1" "WRITE_CHIP0_CHIP1_ODT01" "WRITE_CHIP0_ODT0_CHIP1_ODT01" "WRITE_CHIP0_ODT1_CHIP1_ODT01" "WRITE_CHIP0_ODT01_CHIP1_ODT01"}

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_MEM_AUTO_PD_CYCLES Integer 0
set_parameter_property INTG_MEM_AUTO_PD_CYCLES VISIBLE false
set_parameter_property INTG_MEM_AUTO_PD_CYCLES DERIVED true
set_parameter_property INTG_MEM_AUTO_PD_CYCLES DISPLAY_NAME "mem_auto_pd_cycles"
set_parameter_property INTG_MEM_AUTO_PD_CYCLES ALLOWED_RANGES 0:65535

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_CYC_TO_RLD_JARS_0 Integer 1
set_parameter_property INTG_CYC_TO_RLD_JARS_0 VISIBLE false
set_parameter_property INTG_CYC_TO_RLD_JARS_0 DERIVED true
set_parameter_property INTG_CYC_TO_RLD_JARS_0 DISPLAY_NAME "cyc_to_rld_jars_0"
set_parameter_property INTG_CYC_TO_RLD_JARS_0 ALLOWED_RANGES 0:255

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_CYC_TO_RLD_JARS_1 Integer 1
set_parameter_property INTG_CYC_TO_RLD_JARS_1 VISIBLE false
set_parameter_property INTG_CYC_TO_RLD_JARS_1 DERIVED true
set_parameter_property INTG_CYC_TO_RLD_JARS_1 DISPLAY_NAME "cyc_to_rld_jars_1"
set_parameter_property INTG_CYC_TO_RLD_JARS_1 ALLOWED_RANGES 0:255

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_CYC_TO_RLD_JARS_2 Integer 1
set_parameter_property INTG_CYC_TO_RLD_JARS_2 VISIBLE false
set_parameter_property INTG_CYC_TO_RLD_JARS_2 DERIVED true
set_parameter_property INTG_CYC_TO_RLD_JARS_2 DISPLAY_NAME "cyc_to_rld_jars_2"
set_parameter_property INTG_CYC_TO_RLD_JARS_2 ALLOWED_RANGES 0:255

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_CYC_TO_RLD_JARS_3 Integer 1
set_parameter_property INTG_CYC_TO_RLD_JARS_3 VISIBLE false
set_parameter_property INTG_CYC_TO_RLD_JARS_3 DERIVED true
set_parameter_property INTG_CYC_TO_RLD_JARS_3 DISPLAY_NAME "cyc_to_rld_jars_3"
set_parameter_property INTG_CYC_TO_RLD_JARS_3 ALLOWED_RANGES 0:255

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_CYC_TO_RLD_JARS_4 Integer 1
set_parameter_property INTG_CYC_TO_RLD_JARS_4 VISIBLE false
set_parameter_property INTG_CYC_TO_RLD_JARS_4 DERIVED true
set_parameter_property INTG_CYC_TO_RLD_JARS_4 DISPLAY_NAME "cyc_to_rld_jars_4"
set_parameter_property INTG_CYC_TO_RLD_JARS_4 ALLOWED_RANGES 0:255

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_CYC_TO_RLD_JARS_5 Integer 1
set_parameter_property INTG_CYC_TO_RLD_JARS_5 VISIBLE false
set_parameter_property INTG_CYC_TO_RLD_JARS_5 DERIVED true
set_parameter_property INTG_CYC_TO_RLD_JARS_5 DISPLAY_NAME "cyc_to_rld_jars_5"
set_parameter_property INTG_CYC_TO_RLD_JARS_5 ALLOWED_RANGES 0:255

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_ACT_TO_ACT Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT DISPLAY_NAME "extra_ctl_clk_act_to_act"
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_ACT_TO_ACT_DIFF_BANK Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT_DIFF_BANK VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT_DIFF_BANK DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT_DIFF_BANK DISPLAY_NAME "extra_ctl_clk_act_to_act_diff_bank"
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_ACT_DIFF_BANK ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_ACT_TO_PCH Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_PCH VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_PCH DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_PCH DISPLAY_NAME "extra_ctl_clk_act_to_pch"
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_PCH ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_ACT_TO_RDWR Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_RDWR VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_RDWR DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_RDWR DISPLAY_NAME "extra_ctl_clk_act_to_rdwr"
set_parameter_property INTG_EXTRA_CTL_CLK_ACT_TO_RDWR ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_ARF_PERIOD Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_PERIOD VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_PERIOD DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_PERIOD DISPLAY_NAME "extra_ctl_clk_arf_period"
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_PERIOD ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_ARF_TO_VALID Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_TO_VALID VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_TO_VALID DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_TO_VALID DISPLAY_NAME "extra_ctl_clk_arf_to_valid"
set_parameter_property INTG_EXTRA_CTL_CLK_ARF_TO_VALID ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_FOUR_ACT_TO_ACT Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_FOUR_ACT_TO_ACT VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_FOUR_ACT_TO_ACT DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_FOUR_ACT_TO_ACT DISPLAY_NAME "extra_ctl_clk_four_act_to_act"
set_parameter_property INTG_EXTRA_CTL_CLK_FOUR_ACT_TO_ACT ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_PCH_ALL_TO_VALID Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_ALL_TO_VALID VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_ALL_TO_VALID DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_ALL_TO_VALID DISPLAY_NAME "extra_ctl_clk_pch_all_to_valid"
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_ALL_TO_VALID ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_PCH_TO_VALID Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_TO_VALID VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_TO_VALID DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_TO_VALID DISPLAY_NAME "extra_ctl_clk_pch_to_valid"
set_parameter_property INTG_EXTRA_CTL_CLK_PCH_TO_VALID ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_PDN_PERIOD Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_PERIOD VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_PERIOD DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_PERIOD DISPLAY_NAME "extra_ctl_clk_pdn_period"
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_PERIOD ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_PDN_TO_VALID Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_TO_VALID VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_TO_VALID DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_TO_VALID DISPLAY_NAME "extra_ctl_clk_pdn_to_valid"
set_parameter_property INTG_EXTRA_CTL_CLK_PDN_TO_VALID ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_RD_AP_TO_VALID Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_RD_AP_TO_VALID VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_RD_AP_TO_VALID DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_RD_AP_TO_VALID DISPLAY_NAME "extra_ctl_clk_rd_ap_to_valid"
set_parameter_property INTG_EXTRA_CTL_CLK_RD_AP_TO_VALID ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_RD_TO_PCH Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_PCH VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_PCH DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_PCH DISPLAY_NAME "extra_ctl_clk_rd_to_pch"
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_PCH ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_RD_TO_RD Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD DISPLAY_NAME "extra_ctl_clk_rd_to_rd"
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_RD_TO_RD_DIFF_CHIP Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD_DIFF_CHIP VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD_DIFF_CHIP DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD_DIFF_CHIP DISPLAY_NAME "extra_ctl_clk_rd_to_rd_diff_chip"
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_RD_DIFF_CHIP ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_RD_TO_WR Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR DISPLAY_NAME "extra_ctl_clk_rd_to_wr"
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_RD_TO_WR_BC Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_BC VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_BC DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_BC DISPLAY_NAME "extra_ctl_clk_rd_to_wr_bc"
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_BC ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP DISPLAY_NAME "extra_ctl_clk_rd_to_wr_diff_chip"
set_parameter_property INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_SRF_TO_VALID Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_VALID VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_VALID DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_VALID DISPLAY_NAME "extra_ctl_clk_srf_to_valid"
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_VALID ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_SRF_TO_ZQ_CAL Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_ZQ_CAL VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_ZQ_CAL DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_ZQ_CAL DISPLAY_NAME "extra_ctl_clk_srf_to_zq_cal"
set_parameter_property INTG_EXTRA_CTL_CLK_SRF_TO_ZQ_CAL ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_WR_AP_TO_VALID Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_WR_AP_TO_VALID VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_WR_AP_TO_VALID DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_WR_AP_TO_VALID DISPLAY_NAME "extra_ctl_clk_wr_ap_to_valid"
set_parameter_property INTG_EXTRA_CTL_CLK_WR_AP_TO_VALID ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_WR_TO_PCH Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_PCH VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_PCH DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_PCH DISPLAY_NAME "extra_ctl_clk_wr_to_pch"
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_PCH ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_WR_TO_RD Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD DISPLAY_NAME "extra_ctl_clk_wr_to_rd"
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_WR_TO_RD_BC Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_BC VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_BC DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_BC DISPLAY_NAME "extra_ctl_clk_wr_to_rd_bc"
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_BC ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP DISPLAY_NAME "extra_ctl_clk_wr_to_rd_diff_chip"
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_WR_TO_WR Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR DISPLAY_NAME "extra_ctl_clk_wr_to_wr"
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_EXTRA_CTL_CLK_WR_TO_WR_DIFF_CHIP Integer 0
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR_DIFF_CHIP VISIBLE false
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR_DIFF_CHIP DERIVED true
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR_DIFF_CHIP DISPLAY_NAME "extra_ctl_clk_wr_to_wr_diff_chip"
set_parameter_property INTG_EXTRA_CTL_CLK_WR_TO_WR_DIFF_CHIP ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_MEM_IF_TREFI Integer 3120
set_parameter_property INTG_MEM_IF_TREFI VISIBLE false
set_parameter_property INTG_MEM_IF_TREFI DERIVED true
set_parameter_property INTG_MEM_IF_TREFI DISPLAY_NAME "mem_if_trefi"
set_parameter_property INTG_MEM_IF_TREFI ALLOWED_RANGES 0:8191

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_MEM_IF_TRFC Integer 34
set_parameter_property INTG_MEM_IF_TRFC VISIBLE false
set_parameter_property INTG_MEM_IF_TRFC DERIVED true
set_parameter_property INTG_MEM_IF_TRFC DISPLAY_NAME "mem_if_trfc"
set_parameter_property INTG_MEM_IF_TRFC ALLOWED_RANGES 0:255

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_0 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_0 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_0 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_0 DISPLAY_NAME "rcfg_sum_wt_priority_0"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_0 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_1 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_1 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_1 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_1 DISPLAY_NAME "rcfg_sum_wt_priority_1"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_1 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_2 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_2 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_2 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_2 DISPLAY_NAME "rcfg_sum_wt_priority_2"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_2 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_3 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_3 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_3 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_3 DISPLAY_NAME "rcfg_sum_wt_priority_3"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_3 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_4 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_4 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_4 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_4 DISPLAY_NAME "rcfg_sum_wt_priority_4"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_4 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_5 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_5 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_5 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_5 DISPLAY_NAME "rcfg_sum_wt_priority_5"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_5 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_6 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_6 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_6 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_6 DISPLAY_NAME "rcfg_sum_wt_priority_6"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_6 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_RCFG_SUM_WT_PRIORITY_7 Integer 0
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_7 VISIBLE false
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_7 DERIVED true
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_7 DISPLAY_NAME "rcfg_sum_wt_priority_7"
set_parameter_property INTG_RCFG_SUM_WT_PRIORITY_7 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_0 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_0 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_0 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_0 DISPLAY_NAME "sum_wt_priority_0"
set_parameter_property INTG_SUM_WT_PRIORITY_0 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_1 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_1 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_1 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_1 DISPLAY_NAME "sum_wt_priority_1"
set_parameter_property INTG_SUM_WT_PRIORITY_1 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_2 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_2 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_2 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_2 DISPLAY_NAME "sum_wt_priority_2"
set_parameter_property INTG_SUM_WT_PRIORITY_2 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_3 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_3 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_3 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_3 DISPLAY_NAME "sum_wt_priority_3"
set_parameter_property INTG_SUM_WT_PRIORITY_3 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_4 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_4 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_4 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_4 DISPLAY_NAME "sum_wt_priority_4"
set_parameter_property INTG_SUM_WT_PRIORITY_4 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_5 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_5 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_5 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_5 DISPLAY_NAME "sum_wt_priority_5"
set_parameter_property INTG_SUM_WT_PRIORITY_5 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_6 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_6 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_6 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_6 DISPLAY_NAME "sum_wt_priority_6"
set_parameter_property INTG_SUM_WT_PRIORITY_6 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_SUM_WT_PRIORITY_7 Integer 0
set_parameter_property INTG_SUM_WT_PRIORITY_7 VISIBLE false
set_parameter_property INTG_SUM_WT_PRIORITY_7 DERIVED true
set_parameter_property INTG_SUM_WT_PRIORITY_7 DISPLAY_NAME "sum_wt_priority_7"
set_parameter_property INTG_SUM_WT_PRIORITY_7 ALLOWED_RANGES 0:186

::alt_mem_if::util::hwtcl_utils::_add_parameter VECT_ATTR_COUNTER_ONE_MASK Std_logic_vector 0
set_parameter_property VECT_ATTR_COUNTER_ONE_MASK VISIBLE false
set_parameter_property VECT_ATTR_COUNTER_ONE_MASK DERIVED true
set_parameter_property VECT_ATTR_COUNTER_ONE_MASK DISPLAY_NAME "attr_counter_one_mask"
set_parameter_property VECT_ATTR_COUNTER_ONE_MASK ALLOWED_RANGES 0:18446744073709551615
set_parameter_property VECT_ATTR_COUNTER_ONE_MASK WIDTH 64

::alt_mem_if::util::hwtcl_utils::_add_parameter VECT_ATTR_COUNTER_ONE_MATCH Std_logic_vector 0
set_parameter_property VECT_ATTR_COUNTER_ONE_MATCH VISIBLE false
set_parameter_property VECT_ATTR_COUNTER_ONE_MATCH DERIVED true
set_parameter_property VECT_ATTR_COUNTER_ONE_MATCH DISPLAY_NAME "attr_counter_one_match"
set_parameter_property VECT_ATTR_COUNTER_ONE_MATCH ALLOWED_RANGES 0:18446744073709551615
set_parameter_property VECT_ATTR_COUNTER_ONE_MATCH WIDTH 64


::alt_mem_if::util::hwtcl_utils::_add_parameter VECT_ATTR_COUNTER_ZERO_MASK Std_logic_vector 0
set_parameter_property VECT_ATTR_COUNTER_ZERO_MASK VISIBLE false
set_parameter_property VECT_ATTR_COUNTER_ZERO_MASK DERIVED true
set_parameter_property VECT_ATTR_COUNTER_ZERO_MASK DISPLAY_NAME "attr_counter_zero_mask"
set_parameter_property VECT_ATTR_COUNTER_ZERO_MASK ALLOWED_RANGES 0:18446744073709551615
set_parameter_property VECT_ATTR_COUNTER_ZERO_MASK WIDTH 64

::alt_mem_if::util::hwtcl_utils::_add_parameter VECT_ATTR_COUNTER_ZERO_MATCH Std_logic_vector 0
set_parameter_property VECT_ATTR_COUNTER_ZERO_MATCH VISIBLE false
set_parameter_property VECT_ATTR_COUNTER_ZERO_MATCH DERIVED true
set_parameter_property VECT_ATTR_COUNTER_ZERO_MATCH DISPLAY_NAME "attr_counter_zero_match"
set_parameter_property VECT_ATTR_COUNTER_ZERO_MATCH ALLOWED_RANGES 0:18446744073709551615
set_parameter_property VECT_ATTR_COUNTER_ZERO_MATCH WIDTH 64

::alt_mem_if::util::hwtcl_utils::_add_parameter VECT_ATTR_DEBUG_SELECT_BYTE Std_logic_vector 0
set_parameter_property VECT_ATTR_DEBUG_SELECT_BYTE VISIBLE false
set_parameter_property VECT_ATTR_DEBUG_SELECT_BYTE DERIVED true
set_parameter_property VECT_ATTR_DEBUG_SELECT_BYTE DISPLAY_NAME "attr_debug_select_byte"
set_parameter_property VECT_ATTR_DEBUG_SELECT_BYTE ALLOWED_RANGES 0:4294967295
set_parameter_property VECT_ATTR_DEBUG_SELECT_BYTE WIDTH 32

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_POWER_SAVING_EXIT_CYCLES Integer 5
set_parameter_property INTG_POWER_SAVING_EXIT_CYCLES VISIBLE false
set_parameter_property INTG_POWER_SAVING_EXIT_CYCLES DERIVED true
set_parameter_property INTG_POWER_SAVING_EXIT_CYCLES DISPLAY_NAME "power_saving_exit_cycles"
set_parameter_property INTG_POWER_SAVING_EXIT_CYCLES ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter INTG_MEM_CLK_ENTRY_CYCLES Integer 10
set_parameter_property INTG_MEM_CLK_ENTRY_CYCLES VISIBLE false
set_parameter_property INTG_MEM_CLK_ENTRY_CYCLES DERIVED true
set_parameter_property INTG_MEM_CLK_ENTRY_CYCLES DISPLAY_NAME "mem_clk_entry_cycles"
set_parameter_property INTG_MEM_CLK_ENTRY_CYCLES ALLOWED_RANGES 0:15

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BURST_INTERRUPT String "DISABLED"
set_parameter_property ENUM_ENABLE_BURST_INTERRUPT VISIBLE false
set_parameter_property ENUM_ENABLE_BURST_INTERRUPT DERIVED true
set_parameter_property ENUM_ENABLE_BURST_INTERRUPT DISPLAY_NAME "enable_burst_interrupt"
set_parameter_property ENUM_ENABLE_BURST_INTERRUPT ALLOWED_RANGES {"DISABLED" "ENABLED"}

::alt_mem_if::util::hwtcl_utils::_add_parameter ENUM_ENABLE_BURST_TERMINATE String "DISABLED"
set_parameter_property ENUM_ENABLE_BURST_TERMINATE VISIBLE false
set_parameter_property ENUM_ENABLE_BURST_TERMINATE DERIVED true
set_parameter_property ENUM_ENABLE_BURST_TERMINATE DISPLAY_NAME "enable_burst_terminate"
set_parameter_property ENUM_ENABLE_BURST_TERMINATE ALLOWED_RANGES {"ENABLED" "DISABLED"}




        for {set port_id 0} {$port_id != 6} {incr port_id} {

                ::alt_mem_if::util::hwtcl_utils::_add_parameter AV_PORT_${port_id}_CONNECT_TO_CV_PORT Integer ${port_id}
                set_parameter_property AV_PORT_${port_id}_CONNECT_TO_CV_PORT VISIBLE false
                set_parameter_property AV_PORT_${port_id}_CONNECT_TO_CV_PORT DERIVED true
                set_parameter_property AV_PORT_${port_id}_CONNECT_TO_CV_PORT DISPLAY_NAME "av_port_${port_id}_connect_to_cv_port"
                set_parameter_property AV_PORT_${port_id}_CONNECT_TO_CV_PORT ALLOWED_RANGES 0:186

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_PORT_${port_id}_CONNECT_TO_AV_PORT Integer ${port_id}
                set_parameter_property CV_PORT_${port_id}_CONNECT_TO_AV_PORT VISIBLE false      
                set_parameter_property CV_PORT_${port_id}_CONNECT_TO_AV_PORT DERIVED true
                set_parameter_property CV_PORT_${port_id}_CONNECT_TO_AV_PORT DISPLAY_NAME "cv_port_${port_id}_connect_to_av_port"
                set_parameter_property CV_PORT_${port_id}_CONNECT_TO_AV_PORT ALLOWED_RANGES 0:186

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_AVL_DATA_WIDTH_PORT_${port_id} Integer 0
	        set_parameter_property CV_AVL_DATA_WIDTH_PORT_${port_id} DERIVED true
                set_parameter_property CV_AVL_DATA_WIDTH_PORT_${port_id} VISIBLE false
			
	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_AVL_ADDR_WIDTH_PORT_${port_id} Integer 0
	        set_parameter_property CV_AVL_ADDR_WIDTH_PORT_${port_id} DERIVED true
                set_parameter_property CV_AVL_ADDR_WIDTH_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_CPORT_TYPE_PORT_${port_id} Integer 0
	        set_parameter_property CV_CPORT_TYPE_PORT_${port_id} DERIVED true
                set_parameter_property CV_CPORT_TYPE_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_AVL_NUM_SYMBOLS_PORT_${port_id} integer 2
	        set_parameter_property CV_AVL_NUM_SYMBOLS_PORT_${port_id} DERIVED TRUE
	        set_parameter_property CV_AVL_NUM_SYMBOLS_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_LSB_WFIFO_PORT_${port_id} integer 5
	        set_parameter_property CV_LSB_WFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property CV_LSB_WFIFO_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_MSB_WFIFO_PORT_${port_id} integer 5
	        set_parameter_property CV_MSB_WFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property CV_MSB_WFIFO_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_LSB_RFIFO_PORT_${port_id} integer 5
	        set_parameter_property CV_LSB_RFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property CV_LSB_RFIFO_PORT_${port_id} VISIBLE false

	        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_MSB_RFIFO_PORT_${port_id} integer 5
	        set_parameter_property CV_MSB_RFIFO_PORT_${port_id} DERIVED TRUE
	        set_parameter_property CV_MSB_RFIFO_PORT_${port_id} VISIBLE false

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_AUTO_PCH_ENABLE_${port_id} String "DISABLED"
                set_parameter_property CV_ENUM_AUTO_PCH_ENABLE_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_AUTO_PCH_ENABLE_${port_id} DERIVED true
                set_parameter_property CV_ENUM_AUTO_PCH_ENABLE_${port_id} DISPLAY_NAME "auto_pch_enable_${port_id}"
                set_parameter_property CV_ENUM_AUTO_PCH_ENABLE_${port_id} ALLOWED_RANGES {"DISABLED" "ENABLED"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_CMD_PORT_IN_USE_${port_id} String "FALSE"
                set_parameter_property CV_ENUM_CMD_PORT_IN_USE_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_CMD_PORT_IN_USE_${port_id} DERIVED true
                set_parameter_property CV_ENUM_CMD_PORT_IN_USE_${port_id} DISPLAY_NAME "cmd_port_in_use_${port_id}"
                set_parameter_property CV_ENUM_CMD_PORT_IN_USE_${port_id} ALLOWED_RANGES {"FALSE" "TRUE"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_CPORT${port_id}_RFIFO_MAP String "FIFO_0"
                set_parameter_property CV_ENUM_CPORT${port_id}_RFIFO_MAP VISIBLE false
                set_parameter_property CV_ENUM_CPORT${port_id}_RFIFO_MAP DERIVED true
                set_parameter_property CV_ENUM_CPORT${port_id}_RFIFO_MAP DISPLAY_NAME "cport${port_id}_rfifo_map"
                set_parameter_property CV_ENUM_CPORT${port_id}_RFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_CPORT${port_id}_TYPE String "DISABLE"
                set_parameter_property CV_ENUM_CPORT${port_id}_TYPE VISIBLE false
                set_parameter_property CV_ENUM_CPORT${port_id}_TYPE DERIVED true
                set_parameter_property CV_ENUM_CPORT${port_id}_TYPE DISPLAY_NAME "cport${port_id}_type"
                set_parameter_property CV_ENUM_CPORT${port_id}_TYPE ALLOWED_RANGES {"DISABLE" "WRITE" "READ" "BI_DIRECTION"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_CPORT${port_id}_WFIFO_MAP String "FIFO_0"
                set_parameter_property CV_ENUM_CPORT${port_id}_WFIFO_MAP VISIBLE false
                set_parameter_property CV_ENUM_CPORT${port_id}_WFIFO_MAP DERIVED true
                set_parameter_property CV_ENUM_CPORT${port_id}_WFIFO_MAP DISPLAY_NAME "cport${port_id}_wfifo_map"
                set_parameter_property CV_ENUM_CPORT${port_id}_WFIFO_MAP ALLOWED_RANGES {"FIFO_0" "FIFO_1" "FIFO_2" "FIFO_3"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_ENABLE_BONDING_${port_id} String "DISABLED"
                set_parameter_property CV_ENUM_ENABLE_BONDING_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_ENABLE_BONDING_${port_id} DERIVED true
                set_parameter_property CV_ENUM_ENABLE_BONDING_${port_id} DISPLAY_NAME "enable_bonding_${port_id}"
                set_parameter_property CV_ENUM_ENABLE_BONDING_${port_id} ALLOWED_RANGES {"DISABLED" "ENABLED"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_PORT${port_id}_WIDTH String "PORT_64_BIT"
                set_parameter_property CV_ENUM_PORT${port_id}_WIDTH VISIBLE false
                set_parameter_property CV_ENUM_PORT${port_id}_WIDTH DERIVED true
                set_parameter_property CV_ENUM_PORT${port_id}_WIDTH DISPLAY_NAME "port${port_id}_width"
                set_parameter_property CV_ENUM_PORT${port_id}_WIDTH ALLOWED_RANGES {"PORT_32_BIT" "PORT_64_BIT" "PORT_128_BIT" "PORT_256_BIT"}

                for {set priority_id 0} {$priority_id != 8} {incr priority_id} {
                        ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_PRIORITY_${priority_id}_${port_id} String "WEIGHT_0"
                        set_parameter_property CV_ENUM_PRIORITY_${priority_id}_${port_id} VISIBLE false
                        set_parameter_property CV_ENUM_PRIORITY_${priority_id}_${port_id} DERIVED true
                        set_parameter_property CV_ENUM_PRIORITY_${priority_id}_${port_id} DISPLAY_NAME "priority_${priority_id}_${port_id}"
                        set_parameter_property CV_ENUM_PRIORITY_${priority_id}_${port_id} ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}
                }

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_RCFG_STATIC_WEIGHT_${port_id} String "WEIGHT_0"
                set_parameter_property CV_ENUM_RCFG_STATIC_WEIGHT_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_RCFG_STATIC_WEIGHT_${port_id} DERIVED true
                set_parameter_property CV_ENUM_RCFG_STATIC_WEIGHT_${port_id} DISPLAY_NAME "rcfg_static_weight_0"
                set_parameter_property CV_ENUM_RCFG_STATIC_WEIGHT_${port_id} ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_RCFG_USER_PRIORITY_${port_id} String "PRIORITY_0"
                set_parameter_property CV_ENUM_RCFG_USER_PRIORITY_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_RCFG_USER_PRIORITY_${port_id} DERIVED true
                set_parameter_property CV_ENUM_RCFG_USER_PRIORITY_${port_id} DISPLAY_NAME "rcfg_user_priority_0"
                set_parameter_property CV_ENUM_RCFG_USER_PRIORITY_${port_id} ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_RD_DWIDTH_${port_id} String "DWIDTH_0"
                set_parameter_property CV_ENUM_RD_DWIDTH_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_RD_DWIDTH_${port_id} DERIVED true
                set_parameter_property CV_ENUM_RD_DWIDTH_${port_id} DISPLAY_NAME "rd_dwidth_${port_id}"
                set_parameter_property CV_ENUM_RD_DWIDTH_${port_id} ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_RD_PORT_INFO_${port_id} String "USE_NO"
                set_parameter_property CV_ENUM_RD_PORT_INFO_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_RD_PORT_INFO_${port_id} DERIVED true
                set_parameter_property CV_ENUM_RD_PORT_INFO_${port_id} DISPLAY_NAME "rd_port_info_${port_id}"
                set_parameter_property CV_ENUM_RD_PORT_INFO_${port_id} ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_STATIC_WEIGHT_${port_id} String "WEIGHT_0"
                set_parameter_property CV_ENUM_STATIC_WEIGHT_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_STATIC_WEIGHT_${port_id} DERIVED true
                set_parameter_property CV_ENUM_STATIC_WEIGHT_${port_id} DISPLAY_NAME "static_weight_${port_id}"
                set_parameter_property CV_ENUM_STATIC_WEIGHT_${port_id} ALLOWED_RANGES {"WEIGHT_0" "WEIGHT_1" "WEIGHT_2" "WEIGHT_3" "WEIGHT_4" "WEIGHT_5" "WEIGHT_6" "WEIGHT_7" "WEIGHT_8" "WEIGHT_9" "WEIGHT_10" "WEIGHT_11" "WEIGHT_12" "WEIGHT_13" "WEIGHT_14" "WEIGHT_15" "WEIGHT_16" "WEIGHT_17" "WEIGHT_18" "WEIGHT_19" "WEIGHT_20" "WEIGHT_21" "WEIGHT_22" "WEIGHT_23" "WEIGHT_24" "WEIGHT_25" "WEIGHT_26" "WEIGHT_27" "WEIGHT_28" "WEIGHT_29" "WEIGHT_30" "WEIGHT_31"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_USER_PRIORITY_${port_id} String "PRIORITY_0"
                set_parameter_property CV_ENUM_USER_PRIORITY_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_USER_PRIORITY_${port_id} DERIVED true
                set_parameter_property CV_ENUM_USER_PRIORITY_${port_id} DISPLAY_NAME "user_priority_${port_id}"
                set_parameter_property CV_ENUM_USER_PRIORITY_${port_id} ALLOWED_RANGES {"PRIORITY_0" "PRIORITY_1" "PRIORITY_2" "PRIORITY_3" "PRIORITY_4" "PRIORITY_5" "PRIORITY_6" "PRIORITY_7"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_WR_DWIDTH_${port_id} String "DWIDTH_0"
                set_parameter_property CV_ENUM_WR_DWIDTH_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_WR_DWIDTH_${port_id} DERIVED true
                set_parameter_property CV_ENUM_WR_DWIDTH_${port_id} DISPLAY_NAME "wr_dwidth_0"
                set_parameter_property CV_ENUM_WR_DWIDTH_${port_id} ALLOWED_RANGES {"DWIDTH_0" "DWIDTH_32" "DWIDTH_64" "DWIDTH_128" "DWIDTH_256"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_WR_PORT_INFO_${port_id} String "USE_NO"
                set_parameter_property CV_ENUM_WR_PORT_INFO_${port_id} VISIBLE false
                set_parameter_property CV_ENUM_WR_PORT_INFO_${port_id} DERIVED true
                set_parameter_property CV_ENUM_WR_PORT_INFO_${port_id} DISPLAY_NAME "wr_port_info_0"
                set_parameter_property CV_ENUM_WR_PORT_INFO_${port_id} ALLOWED_RANGES {"USE_0_1_2_3" "USE_0_1" "USE_2_3" "USE_0" "USE_1" "USE_2" "USE_3" "USE_NO"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter TG_TEMP_PORT_${port_id} Integer 0
	        set_parameter_property TG_TEMP_PORT_${port_id} DERIVED true
                set_parameter_property TG_TEMP_PORT_${port_id} VISIBLE false
                
        }

        for {set fifo_id 0} {$fifo_id != 4} {incr fifo_id} {

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_RFIFO${fifo_id}_CPORT_MAP String "CMD_PORT_0"
                set_parameter_property CV_ENUM_RFIFO${fifo_id}_CPORT_MAP VISIBLE false
                set_parameter_property CV_ENUM_RFIFO${fifo_id}_CPORT_MAP DERIVED true
                set_parameter_property CV_ENUM_RFIFO${fifo_id}_CPORT_MAP DISPLAY_NAME "rfifo${fifo_id}_cport_map"
                set_parameter_property CV_ENUM_RFIFO${fifo_id}_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_ENUM_WFIFO${fifo_id}_CPORT_MAP String "CMD_PORT_0"
                set_parameter_property CV_ENUM_WFIFO${fifo_id}_CPORT_MAP VISIBLE false
                set_parameter_property CV_ENUM_WFIFO${fifo_id}_CPORT_MAP DERIVED true
                set_parameter_property CV_ENUM_WFIFO${fifo_id}_CPORT_MAP DISPLAY_NAME "wfifo${fifo_id}_cport_map"
                set_parameter_property CV_ENUM_WFIFO${fifo_id}_CPORT_MAP ALLOWED_RANGES {"CMD_PORT_0" "CMD_PORT_1" "CMD_PORT_2" "CMD_PORT_3" "CMD_PORT_4" "CMD_PORT_5"}

        }

        for {set priority_id 0} {$priority_id != 8} {incr priority_id} {
                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_INTG_RCFG_SUM_WT_PRIORITY_${priority_id} Integer 0
                set_parameter_property CV_INTG_RCFG_SUM_WT_PRIORITY_${priority_id} VISIBLE false
                set_parameter_property CV_INTG_RCFG_SUM_WT_PRIORITY_${priority_id} DERIVED true
                set_parameter_property CV_INTG_RCFG_SUM_WT_PRIORITY_${priority_id} DISPLAY_NAME "rcfg_sum_wt_priority_${priority_id}"
                set_parameter_property CV_INTG_RCFG_SUM_WT_PRIORITY_${priority_id} ALLOWED_RANGES 0:186

                ::alt_mem_if::util::hwtcl_utils::_add_parameter CV_INTG_SUM_WT_PRIORITY_${priority_id} Integer 0
                set_parameter_property CV_INTG_SUM_WT_PRIORITY_${priority_id} VISIBLE false
                set_parameter_property CV_INTG_SUM_WT_PRIORITY_${priority_id} DERIVED true
                set_parameter_property CV_INTG_SUM_WT_PRIORITY_${priority_id} DISPLAY_NAME "sum_wt_priority_${priority_id}"
                set_parameter_property CV_INTG_SUM_WT_PRIORITY_${priority_id} ALLOWED_RANGES 0:186
        }
        return 1
}


proc ::alt_mem_if::gui::ddrx_controller::_derive_hmc_atom_derived_parameters {} {
		

	set protocol [_get_protocol]


        foreach atom_param [get_parameters] {
                if {[regexp {^ENUM|^INTG|^VECT} $atom_param ] == 1} {
                        set_parameter_value $atom_param [get_parameter_property $atom_param DEFAULT_VALUE]
                }
        }


        if {[string compare -nocase [get_parameter_value ENABLE_USER_ECC] "true"] == 0} {
                set_parameter_value ENUM_USER_ECC_EN "ENABLE"
        } else {
                set_parameter_value ENUM_USER_ECC_EN "DISABLE"
        }

        if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
                set_parameter_value ENUM_CTL_USR_REFRESH "CTL_USR_REFRESH_ENABLED"
        } else {
                set_parameter_value ENUM_CTL_USR_REFRESH "CTL_USR_REFRESH_DISABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
                set_parameter_value ENUM_CTL_ECC_ENABLED "CTL_ECC_ENABLED"
        } else {
                set_parameter_value ENUM_CTL_ECC_ENABLED "CTL_ECC_DISABLED"
        }

        if {[string compare -nocase [get_parameter_value CTL_ENABLE_BURST_INTERRUPT_INT] "true"] == 0} {
                set_parameter_value ENUM_ENABLE_BURST_INTERRUPT "ENABLED"
        } else {
                set_parameter_value ENUM_ENABLE_BURST_INTERRUPT "DISABLED"
        }
                
        if {[string compare -nocase [get_parameter_value CTL_ENABLE_BURST_TERMINATE_INT] "true"] == 0} {
                set_parameter_value ENUM_ENABLE_BURST_TERMINATE "ENABLED"
        } else {
                set_parameter_value ENUM_ENABLE_BURST_TERMINATE "DISABLED"
        }
        
        if {[regexp {^LPDDR2$|^LPDDR1$} $protocol] == 1} {
            set_parameter_value ENUM_ENABLE_FAST_EXIT_PPD "DISABLED"
        } else {
            if {[string compare -nocase [get_parameter_value MEM_PD] "Fast exit"] == 0 || [string compare -nocase [get_parameter_value MEM_PD] "DLL on"] == 0} {
                    set_parameter_value ENUM_ENABLE_FAST_EXIT_PPD "ENABLED"
            } else {
                    set_parameter_value ENUM_ENABLE_FAST_EXIT_PPD "DISABLED"
            }
        }

        set_parameter_value ENUM_MEM_IF_AL "AL_[get_parameter_value MEM_ADD_LAT]"

        set_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH "ADDR_WIDTH_[get_parameter_value MEM_IF_BANKADDR_WIDTH]"

        set_parameter_value ENUM_MEM_IF_BURSTLENGTH "MEM_IF_BURSTLENGTH_[get_parameter_value MEM_BURST_LENGTH]"

        set_parameter_value ENUM_MEM_IF_COLADDR_WIDTH "ADDR_WIDTH_[get_parameter_value MEM_IF_COL_ADDR_WIDTH]"

        set_parameter_value ENUM_MEM_IF_CS_WIDTH "MEM_IF_CS_WIDTH_[get_parameter_value MEM_IF_CS_WIDTH]"

        set_parameter_value ENUM_MEM_IF_DQ_PER_CHIP "MEM_IF_DQ_PER_CHIP_[get_parameter_value MEM_DQ_PER_DQS]"

        if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0 && [get_parameter_value MEM_IF_DQ_WIDTH] > 8} {
                set_parameter_value ENUM_MEM_IF_DWIDTH "MEM_IF_DWIDTH_[expr {[get_parameter_value MEM_IF_DQ_WIDTH] - 8}]"
        } else {
                set_parameter_value ENUM_MEM_IF_DWIDTH "MEM_IF_DWIDTH_[get_parameter_value MEM_IF_DQ_WIDTH]"
        }

        set_parameter_value ENUM_MEM_IF_MEMTYPE "${protocol}_SDRAM"

        set_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH "ADDR_WIDTH_[get_parameter_value MEM_IF_ROW_ADDR_WIDTH]"

        if {[regexp {^DDR1$} $protocol] == 1} {
                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR_400_3_3_3"
        } elseif {[regexp {^DDR2$} $protocol] == 1} {
                if {[get_parameter_value MEM_CLK_FREQ_MAX] * 2 <= 400} { 
                        if { ([get_parameter_value MEM_TRCD] >=  4 && [get_parameter_value MEM_TRP] >=  4 && [get_parameter_value MEM_TCL] ==  4)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_400_4_4_4"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_400_3_3_3"
                        }
                } elseif {[get_parameter_value MEM_CLK_FREQ_MAX] * 2 <= 533} {
                        if { ([get_parameter_value MEM_TRCD] >=  3 && [get_parameter_value MEM_TRP] >=  3) && ([get_parameter_value MEM_TCL] >=  3 && [get_parameter_value MEM_TCL] <=  4)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_533_3_3_3"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_533_4_4_4"
                        }
                } elseif {[get_parameter_value MEM_CLK_FREQ_MAX] * 2 <= 667} {
                        if { ([get_parameter_value MEM_TRCD] >=  5 && [get_parameter_value MEM_TRP] >=  5) && ([get_parameter_value MEM_TCL] >=  4 && [get_parameter_value MEM_TCL] <=  5)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_667_5_5_5"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_667_4_4_4"
                        }
                } else {
                        if { ([get_parameter_value MEM_TRCD] >=  6 && [get_parameter_value MEM_TRP] >=  6) && ([get_parameter_value MEM_TCL] >=  4 && [get_parameter_value MEM_TCL] <=  6)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_800_6_6_6"
                        } elseif { ([get_parameter_value MEM_TRCD] >=  5 && [get_parameter_value MEM_TRP] >=  5) && ([get_parameter_value MEM_TCL] >=  4 && [get_parameter_value MEM_TCL] <=  5)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_800_5_5_5"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR2_800_4_4_4"
                        }
                }
        } elseif {[regexp {^DDR3$} $protocol] == 1} {
                if {[get_parameter_value MEM_CLK_FREQ_MAX] * 2 <= 800} { 
                        if { ([get_parameter_value MEM_TRCD] >=  6 && [get_parameter_value MEM_TRP] >=  6 && [get_parameter_value MEM_TCL] ==  6)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_800_6_6_6"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_800_5_5_5"
                        }
                } elseif {[get_parameter_value MEM_CLK_FREQ_MAX] * 2 <= 1066} {
                        if { ([get_parameter_value MEM_TRCD] >=  8 && [get_parameter_value MEM_TRP] >=  8) && ([get_parameter_value MEM_TCL] ==  6 || [get_parameter_value MEM_TCL] ==  8)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1066_8_8_8"
                        } elseif {([get_parameter_value MEM_TRCD] >=  7 && [get_parameter_value MEM_TRP] >=  7) && ([get_parameter_value MEM_TCL] >=  6 &&  [get_parameter_value MEM_TCL] <=  8)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1066_7_7_7"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1066_6_6_6"
                        }
                } elseif {[get_parameter_value MEM_CLK_FREQ_MAX] * 2 <= 1333} {
                        if { ([get_parameter_value MEM_TRCD] >= 10 && [get_parameter_value MEM_TRP] >= 10) && ([get_parameter_value MEM_TCL] ==  6 || [get_parameter_value MEM_TCL] ==  8 || [get_parameter_value MEM_TCL] == 10)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1333_10_10_10"
                        } elseif {([get_parameter_value MEM_TRCD] >=  9 && [get_parameter_value MEM_TRP] >=  9) && ([get_parameter_value MEM_TCL] ==  6 || [get_parameter_value MEM_TCL] ==  8 || [get_parameter_value MEM_TCL] ==  9 ||[get_parameter_value MEM_TCL] == 10)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1333_9_9_9"
                        } elseif {([get_parameter_value MEM_TRCD] >=  8 && [get_parameter_value MEM_TRP] >=  8) && ([get_parameter_value MEM_TCL] >=  5 &&  [get_parameter_value MEM_TCL] <= 10)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1333_8_8_8"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1333_7_7_7"
                        }
                } else {
                        if { ([get_parameter_value MEM_TRCD] >= 11 && [get_parameter_value MEM_TRP] >= 11) && ([get_parameter_value MEM_TCL] ==  6 || [get_parameter_value MEM_TCL] ==  8 || [get_parameter_value MEM_TCL] == 10 || [get_parameter_value MEM_TCL] == 11)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1600_11_11_11"
                        } elseif {([get_parameter_value MEM_TRCD] >= 10 && [get_parameter_value MEM_TRP] >= 10) && ([get_parameter_value MEM_TCL] >=  5 &&  [get_parameter_value MEM_TCL] <= 11)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1600_10_10_10"
                        } elseif {([get_parameter_value MEM_TRCD] >=  9 && [get_parameter_value MEM_TRP] >=  9) && ([get_parameter_value MEM_TCL] >=  5 &&  [get_parameter_value MEM_TCL] <= 11)} {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1600_9_9_9"
                        } else {
                                set_parameter_value ENUM_MEM_IF_SPEEDBIN "DDR3_1600_8_8_8"
                        }
                }
        }

        set_parameter_value ENUM_MEM_IF_TCL "TCL_[get_parameter_value MEM_TCL]"

        set_parameter_value ENUM_MEM_IF_TWR "TWR_[get_parameter_value MEM_TWR]"

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 0) && (([get_parameter_value CPORT_TYPE_PORT_0] == 2) || ([get_parameter_value CPORT_TYPE_PORT_0] == 3))} {
                set int_rwidth_0 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_0]]
                set_parameter_value ENUM_RD_DWIDTH_0 "DWIDTH_$int_rwidth_0"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 1) && (([get_parameter_value CPORT_TYPE_PORT_1] == 2) || ([get_parameter_value CPORT_TYPE_PORT_1] == 3))} {
                set int_rwidth_1 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_1]]
                set_parameter_value ENUM_RD_DWIDTH_1 "DWIDTH_$int_rwidth_1"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 2) && (([get_parameter_value CPORT_TYPE_PORT_2] == 2) || ([get_parameter_value CPORT_TYPE_PORT_2] == 3))} {
                set int_rwidth_2 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_2]]
                set_parameter_value ENUM_RD_DWIDTH_2 "DWIDTH_$int_rwidth_2"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 3) && (([get_parameter_value CPORT_TYPE_PORT_3] == 2) || ([get_parameter_value CPORT_TYPE_PORT_3] == 3))} {
                set int_rwidth_3 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_3]]
                set_parameter_value ENUM_RD_DWIDTH_3 "DWIDTH_$int_rwidth_3"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 4) && (([get_parameter_value CPORT_TYPE_PORT_4] == 2) || ([get_parameter_value CPORT_TYPE_PORT_4] == 3))} {
                set int_rwidth_4 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_4]]
                set_parameter_value ENUM_RD_DWIDTH_4 "DWIDTH_$int_rwidth_4"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 5) && (([get_parameter_value CPORT_TYPE_PORT_5] == 2) || ([get_parameter_value CPORT_TYPE_PORT_5] == 3))} {
                set int_rwidth_5 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_5]]
                set_parameter_value ENUM_RD_DWIDTH_5 "DWIDTH_$int_rwidth_5"
        }

        if {[string compare -nocase [get_parameter_value CFG_REORDER_DATA] "true"] == 0} {
                set_parameter_value ENUM_REORDER_DATA "DATA_REORDERING"
        } else {
                set_parameter_value ENUM_REORDER_DATA "NO_DATA_REORDERING"
        }

        set_parameter_value ENUM_STATIC_WEIGHT_0 "WEIGHT_[get_parameter_value WEIGHT_PORT_0]"

        set_parameter_value ENUM_STATIC_WEIGHT_1 "WEIGHT_[get_parameter_value WEIGHT_PORT_1]"

        set_parameter_value ENUM_STATIC_WEIGHT_2 "WEIGHT_[get_parameter_value WEIGHT_PORT_2]"

        set_parameter_value ENUM_STATIC_WEIGHT_3 "WEIGHT_[get_parameter_value WEIGHT_PORT_3]"

        set_parameter_value ENUM_STATIC_WEIGHT_4 "WEIGHT_[get_parameter_value WEIGHT_PORT_4]"

        set_parameter_value ENUM_STATIC_WEIGHT_5 "WEIGHT_[get_parameter_value WEIGHT_PORT_5]"

        set_parameter_value ENUM_USER_PRIORITY_0 "PRIORITY_[get_parameter_value PRIORITY_PORT_0]"

        set_parameter_value ENUM_USER_PRIORITY_1 "PRIORITY_[get_parameter_value PRIORITY_PORT_1]"

        set_parameter_value ENUM_USER_PRIORITY_2 "PRIORITY_[get_parameter_value PRIORITY_PORT_2]"

        set_parameter_value ENUM_USER_PRIORITY_3 "PRIORITY_[get_parameter_value PRIORITY_PORT_3]"

        set_parameter_value ENUM_USER_PRIORITY_4 "PRIORITY_[get_parameter_value PRIORITY_PORT_4]"

        set_parameter_value ENUM_USER_PRIORITY_5 "PRIORITY_[get_parameter_value PRIORITY_PORT_5]"

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 0) && (([get_parameter_value CPORT_TYPE_PORT_0] == 1) || ([get_parameter_value CPORT_TYPE_PORT_0] == 3))} {
                set int_wwidth_0 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_0]]
                set_parameter_value ENUM_WR_DWIDTH_0 "DWIDTH_$int_wwidth_0"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 1) && (([get_parameter_value CPORT_TYPE_PORT_1] == 1) || ([get_parameter_value CPORT_TYPE_PORT_1] == 3))} {
                set int_wwidth_1 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_1]]
                set_parameter_value ENUM_WR_DWIDTH_1 "DWIDTH_$int_wwidth_1"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 2) && (([get_parameter_value CPORT_TYPE_PORT_2] == 1) || ([get_parameter_value CPORT_TYPE_PORT_2] == 3))} {
                set int_wwidth_2 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_2]]
                set_parameter_value ENUM_WR_DWIDTH_2 "DWIDTH_$int_wwidth_2"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 3) && (([get_parameter_value CPORT_TYPE_PORT_3] == 1) || ([get_parameter_value CPORT_TYPE_PORT_3] == 3))} {
                set int_wwidth_3 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_3]]
                set_parameter_value ENUM_WR_DWIDTH_3 "DWIDTH_$int_wwidth_3"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 4) && (([get_parameter_value CPORT_TYPE_PORT_4] == 1) || ([get_parameter_value CPORT_TYPE_PORT_4] == 3))} {
                set int_wwidth_4 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_4]]
                set_parameter_value ENUM_WR_DWIDTH_4 "DWIDTH_$int_wwidth_4"
        }

        if {([::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 5) && (([get_parameter_value CPORT_TYPE_PORT_5] == 1) || ([get_parameter_value CPORT_TYPE_PORT_5] == 3))} {
                set int_wwidth_5 [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_5]]
                set_parameter_value ENUM_WR_DWIDTH_5 "DWIDTH_$int_wwidth_5"
        }

        if {[string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0} {
                set_parameter_value ENUM_AUTO_PCH_ENABLE_0 "ENABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_1 "ENABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_2 "ENABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_3 "ENABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_4 "ENABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_5 "ENABLED"
        } else {
                set_parameter_value ENUM_AUTO_PCH_ENABLE_0 "DISABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_1 "DISABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_2 "DISABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_3 "DISABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_4 "DISABLED"
                set_parameter_value ENUM_AUTO_PCH_ENABLE_5 "DISABLED"
        }

        set_parameter_value ENUM_CFG_STARVE_LIMIT "STARVE_LIMIT_[get_parameter_value CFG_STARVE_LIMIT]"

        if {[get_parameter_value ADDR_ORDER] == 0} {
                set_parameter_value ENUM_CTL_ADDR_ORDER "CHIP_ROW_BANK_COL"
        } elseif {[get_parameter_value ADDR_ORDER] == 1} {
                set_parameter_value ENUM_CTL_ADDR_ORDER "CHIP_BANK_ROW_COL"
        } elseif {[get_parameter_value ADDR_ORDER] == 2} {
                set_parameter_value ENUM_CTL_ADDR_ORDER "ROW_CHIP_BANK_COL"
        }

        if {[string compare -nocase [get_parameter_value CTL_ECC_AUTO_CORRECTION_ENABLED] "true"] == 0} {
                set_parameter_value ENUM_CTL_ECC_RMW_ENABLED "CTL_ECC_RMW_ENABLED"
        } else {
                set_parameter_value ENUM_CTL_ECC_RMW_ENABLED "CTL_ECC_RMW_DISABLED"
        }

        set_parameter_value ENUM_LOCAL_IF_CS_WIDTH "ADDR_WIDTH_[get_parameter_value LOCAL_CS_WIDTH]"

        set_parameter_value ENUM_MEM_IF_CS_PER_RANK "MEM_IF_CS_PER_RANK_[get_parameter_value MEM_IF_CS_PER_RANK]"

        set_parameter_value INTG_MEM_AUTO_PD_CYCLES [get_parameter_value MEM_AUTO_PD_CYCLES]

        if {[string compare -nocase [get_parameter_value MEM_FORMAT] "registered"] == 0} {
        	set_parameter_value ENUM_CTL_REGDIMM_ENABLED "REGDIMM_ENABLED"
        } else {
        	set_parameter_value ENUM_CTL_REGDIMM_ENABLED "REGDIMM_DISABLED"
        }

	if {[string compare -nocase [get_parameter_value HHP_HPS] "true"] == 0 &&
	    ([string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] == 0 ||
	     [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] == 0)} {
		if {[string compare -nocase [get_parameter_value FORCE_DQS_TRACKING] "ENABLED"] == 0} {
			set_parameter_value ENUM_ENABLE_DQS_TRACKING "ENABLED"
		} else {
			set_parameter_value ENUM_ENABLE_DQS_TRACKING "DISABLED"
		}
	} elseif {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
        	set_parameter_value ENUM_ENABLE_DQS_TRACKING "ENABLED"
        } else {
        	set_parameter_value ENUM_ENABLE_DQS_TRACKING "DISABLED"
        }
        set_parameter_value ENUM_MEM_IF_TCCD "TCCD_[get_parameter_value CFG_TCCD]"

        set_parameter_value ENUM_MEM_IF_TCWL "TCWL_[get_parameter_value MEM_WTCL_INT]"

        set_parameter_value ENUM_MEM_IF_TFAW "TFAW_[get_parameter_value MEM_TFAW]"

        set_parameter_value ENUM_MEM_IF_TRAS "TRAS_[get_parameter_value MEM_TRAS]"

        set_parameter_value ENUM_MEM_IF_TRC "TRC_[get_parameter_value MEM_TRC]"

        set_parameter_value ENUM_MEM_IF_TRCD "TRCD_[get_parameter_value MEM_TRCD]"

        set_parameter_value ENUM_MEM_IF_TRP "TRP_[get_parameter_value MEM_TRP]"

        if {[get_parameter_value MEM_TRRD] > 6 } {
                set_parameter_value MEM_TRRD 6
        }
        set_parameter_value ENUM_MEM_IF_TRRD "TRRD_[get_parameter_value MEM_TRRD]"

        set_parameter_value ENUM_MEM_IF_TRTP "TRTP_[get_parameter_value MEM_TRTP]"

        set_parameter_value ENUM_MEM_IF_TWTR "TWTR_[get_parameter_value MEM_TWTR]"

        set_parameter_value INTG_MEM_IF_TREFI [get_parameter_value MEM_TREFI]

        set_parameter_value INTG_MEM_IF_TRFC [get_parameter_value MEM_TRFC]

        if {[string compare -nocase [get_parameter_value ENABLE_BONDING] "true"] == 0} {
                if {[::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 0} {
                        set_parameter_value ENUM_ENABLE_BONDING_0 "ENABLED"
                }

                if {[::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 1} {
                        set_parameter_value ENUM_ENABLE_BONDING_1 "ENABLED"
                }

                if {[::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 2} {
                        set_parameter_value ENUM_ENABLE_BONDING_2 "ENABLED"
                }

                if {[::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 3} {
                        set_parameter_value ENUM_ENABLE_BONDING_3 "ENABLED"
                }

                if {[::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 4} {
                        set_parameter_value ENUM_ENABLE_BONDING_4 "ENABLED"
                }

                if {[::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS] > 5} {
                        set_parameter_value ENUM_ENABLE_BONDING_5 "ENABLED"
                }
        } else {
                set_parameter_value ENUM_ENABLE_BONDING_0 "DISABLED"
                set_parameter_value ENUM_ENABLE_BONDING_1 "DISABLED"
                set_parameter_value ENUM_ENABLE_BONDING_2 "DISABLED"
                set_parameter_value ENUM_ENABLE_BONDING_3 "DISABLED"
                set_parameter_value ENUM_ENABLE_BONDING_4 "DISABLED"
                set_parameter_value ENUM_ENABLE_BONDING_5 "DISABLED"
        }

	if {[::alt_mem_if::util::qini::cfg_is_on uniphy_overwrite_auto_fifo_mapping]} {
                for {set port_id 0} {$port_id != 6} {incr port_id} {
                        set_parameter_value ENUM_RD_PORT_INFO_${port_id} [string map {"USE_0_1_2_3" "F0-F3" "USE_0_1" "F0-F1" "USE_2_3" "F2-F3" "USE_0" "F0" "USE_1" "F1" "USE_2" "F2" "USE_3" "F3" "USE_NO" "None"} [lindex [split [get_parameter_value ALLOCATED_RFIFO_PORT] " "] $port_id]]
                        set_parameter_value ENUM_WR_PORT_INFO_${port_id} [string map {"USE_0_1_2_3" "F0-F3" "USE_0_1" "F0-F1" "USE_2_3" "F2-F3" "USE_0" "F0" "USE_1" "F1" "USE_2" "F2" "USE_3" "F3" "USE_NO" "None"} [lindex [split [get_parameter_value ALLOCATED_WFIFO_PORT] " "] $port_id]]
                }
	} else {


		set used_rd_0 0
		set used_rd_1 0
		set used_rd_2 0
		set used_rd_3 0
		set used_rd_4 0
		set used_rd_5 0
		set used_rd_6 0
		set used_rd_7 0

		set used_wr_0 0
		set used_wr_1 0
		set used_wr_2 0
		set used_wr_3 0
		set used_wr_4 0
		set used_wr_5 0
		set used_wr_6 0
		set used_wr_7 0

		for {set port_id 0} {$port_id != 6} {incr port_id} {

			set av [string map {48 32 80 64 160 128 320 256} [get_parameter_value AVL_DATA_WIDTH_PORT_${port_id}]]
			set ty [get_parameter_value CPORT_TYPE_PORT_${port_id}]

			if { $av == 256 } {
                                if { $ty == 3 } {
                                        if { $used_rd_0 != 1 && $used_wr_0 != 1 } { 
					        set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_0_1_2_3"
					        set used_rd_0 1
					        set used_rd_1 1
					        set used_rd_2 1
					        set used_rd_3 1
					        set used_rd_4 1
					        set used_rd_5 1
					        set used_rd_6 1
					        set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_0_1_2_3"
					        set used_wr_0 1
					        set used_wr_1 1
					        set used_wr_2 1
					        set used_wr_3 1
					        set used_wr_4 1
					        set used_wr_5 1
					        set used_wr_6 1
                                        } else {
					        set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_NO"
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_NO"
                                        }
                                } elseif { $ty == 2 } {
                                        if { $used_rd_0 != 1 } {
					        set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_0_1_2_3"
					        set used_rd_0 1
					        set used_rd_1 1
					        set used_rd_2 1
					        set used_rd_3 1
					        set used_rd_4 1
					        set used_rd_5 1
					        set used_rd_6 1
				        } else {
				        	set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_NO"
				        }
                                } else {
				        if { $used_wr_0 != 1 } {
				        	set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_0_1_2_3"
				        	set used_wr_0 1
				        	set used_wr_1 1
				        	set used_wr_2 1
				        	set used_wr_3 1
				        	set used_wr_4 1
				        	set used_wr_5 1
				        	set used_wr_6 1
				        } else {
				        	set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_NO"
				        }
                                }
                        } elseif { $av == 128 } {
                                if { $ty == 3 } {
                                        if { $used_rd_1 != 1 && $used_wr_1 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_0_1"
                                                set used_rd_0 1
                                                set used_rd_1 1
                                                set used_rd_3 1
                                                set used_rd_4 1
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_0_1"
                                                set used_wr_0 1
                                                set used_wr_1 1
                                                set used_wr_3 1
                                                set used_wr_4 1
                                        } elseif { $used_rd_2 != 1 && $used_wr_2 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_2_3"
                                                set used_rd_0 1
                                                set used_rd_2 1
                                                set used_rd_5 1
                                                set used_rd_6 1
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_2_3"
                                                set used_wr_0 1
                                                set used_wr_2 1
                                                set used_wr_5 1
                                                set used_wr_6 1
                                        } else {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_NO"
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_NO"
                                        }
                                } elseif { $ty == 2 } {
                                        if { $used_rd_1 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_0_1"
                                                set used_rd_0 1
                                                set used_rd_1 1
                                                set used_rd_3 1
                                                set used_rd_4 1
                                        } elseif { $used_rd_2 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_2_3"
                                                set used_rd_0 1
                                                set used_rd_2 1
                                                set used_rd_5 1
                                                set used_rd_6 1
                                        } else {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_NO"
                                        }
                                } else {
                                        if { $used_wr_1 != 1 } {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_0_1"
                                                set used_wr_0 1
                                                set used_wr_1 1
                                                set used_wr_3 1
                                                set used_wr_4 1
                                        } elseif { $used_wr_2 != 1 } {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_2_3"
                                                set used_wr_0 1
                                                set used_wr_2 1
                                                set used_wr_5 1
                                                set used_wr_6 1
                                        } else {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_NO"
                                        }
                                }
                        } elseif { $av == 64 || $av == 32 } {
                                if { $ty == 3 } {
                                        if { $used_rd_3 != 1 && $used_wr_3 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_0"
                                                set used_rd_0 1
                                                set used_rd_1 1
                                                set used_rd_3 1
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_0"
                                                set used_wr_0 1
                                                set used_wr_1 1
                                                set used_wr_3 1
                                        } elseif { $used_rd_4 != 1 && $used_wr_4 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_1"
                                                set used_rd_0 1
                                                set used_rd_1 1
                                                set used_rd_4 1
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_1"
                                                set used_wr_0 1
                                                set used_wr_1 1
                                                set used_wr_4 1
                                        } elseif { $used_rd_5 != 1 && $used_wr_5 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_2"
                                                set used_rd_0 1
                                                set used_rd_2 1
                                                set used_rd_5 1
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_2"
                                                set used_wr_0 1
                                                set used_wr_2 1
                                                set used_wr_5 1
                                        } elseif { $used_rd_6 != 1 && $used_wr_6 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_3"
                                                set used_rd_0 1
                                                set used_rd_2 1
                                                set used_rd_6 1
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_3"
                                                set used_wr_0 1
                                                set used_wr_2 1
                                                set used_wr_6 1
                                        } else {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_NO"
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_NO"
                                        }
                                } elseif { $ty == 2 } {
                                        if { $used_rd_3 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_0"
                                                set used_rd_0 1
                                                set used_rd_1 1
                                                set used_rd_3 1
                                        } elseif { $used_rd_4 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_1"
                                                set used_rd_0 1
                                                set used_rd_1 1
                                                set used_rd_4 1
                                        } elseif { $used_rd_5 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_2"
                                                set used_rd_0 1
                                                set used_rd_2 1
                                                set used_rd_5 1
                                        } elseif { $used_rd_6 != 1 } {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_3"
                                                set used_rd_0 1
                                                set used_rd_2 1
                                                set used_rd_6 1
                                        } else {
                                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_NO"
                                        }
                                } else {
                                        if { $used_wr_3 != 1 } {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_0"
                                                set used_wr_0 1
                                                set used_wr_1 1
                                                set used_wr_3 1
                                        } elseif { $used_wr_4 != 1 } {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_1"
                                                set used_wr_0 1
                                                set used_wr_1 1
                                                set used_wr_4 1
                                        } elseif { $used_wr_5 != 1 } {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_2"
                                                set used_wr_0 1
                                                set used_wr_2 1
                                                set used_wr_5 1
                                        } elseif { $used_wr_6 != 1 } {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_3"
                                                set used_wr_0 1
                                                set used_wr_2 1
                                                set used_wr_6 1
                                        } else {
                                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_NO"
                                        }
                                }
                        } elseif { $av == 0 } {
                                set_parameter_value ENUM_RD_PORT_INFO_${port_id} "USE_NO"
                                set_parameter_value ENUM_WR_PORT_INFO_${port_id} "USE_NO"
                        }
                }
        }

        
	if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM"} {
		set_parameter_value ENUM_CFG_TYPE "DDR2"
	} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR3_SDRAM"} {
		set_parameter_value ENUM_CFG_TYPE "DDR3"
	} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR2_SDRAM"} {
		set_parameter_value ENUM_CFG_TYPE "LPDDR2"
	}
	
        if { [get_parameter_value ENUM_CTL_ECC_ENABLED] == "CTL_ECC_ENABLED"} {
        	set_parameter_value ENUM_ECC_DQ_WIDTH "ECC_DQ_WIDTH_8"
        } else {
        	set_parameter_value ENUM_CTL_ECC_RMW_ENABLED "CTL_ECC_RMW_DISABLED"
        	set_parameter_value ENUM_ECC_DQ_WIDTH "ECC_DQ_WIDTH_0"
        	set_parameter_value ENUM_ENABLE_INTR "DISABLED"
        	set_parameter_value ENUM_MASK_SBE_INTR "DISABLED"
        	set_parameter_value ENUM_MASK_DBE_INTR "DISABLED"
        	set_parameter_value ENUM_MASK_CORR_DROPPED_INTR "DISABLED"
        }

        if { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_8"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_0"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_8"
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_8"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_16"
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_16"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_0"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_16"
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_8"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_24"
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_24"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_0"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_24"
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_8"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_32"
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_32"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_0"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_32"
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_8"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_40"
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_40"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH] == "ECC_DQ_WIDTH_0"} {
        		set_parameter_value ENUM_CFG_INTERFACE_WIDTH "DWIDTH_40"
        	}
        }

        if { [get_parameter_value ENUM_REORDER_DATA] != "DATA_REORDERING"} {
        	set_parameter_value ENUM_CFG_STARVE_LIMIT "STARVE_LIMIT_4"
        }

        if { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_2"} {
        	set_parameter_value ENUM_CFG_BURST_LENGTH "BL_2"
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_4"} {
        	set_parameter_value ENUM_CFG_BURST_LENGTH "BL_4"
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_8"} {
        	set_parameter_value ENUM_CFG_BURST_LENGTH "BL_8"
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_16"} {
        	set_parameter_value ENUM_CFG_BURST_LENGTH "BL_16"
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TCL] == "TCL_3"} {
        		set_parameter_value ENUM_MEM_IF_TCWL "TCWL_2"
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL] == "TCL_4"} {
        		set_parameter_value ENUM_MEM_IF_TCWL "TCWL_3"
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL] == "TCL_5"} {
        		set_parameter_value ENUM_MEM_IF_TCWL "TCWL_4"
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL] == "TCL_6"} {
        		set_parameter_value ENUM_MEM_IF_TCWL "TCWL_5"
        	}
        }

        if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0} {
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM"} {
			set_parameter_value ENUM_MEM_IF_TMRD "TMRD_2"
		}
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR3_SDRAM"} {
			set_parameter_value ENUM_MEM_IF_TMRD "TMRD_4"
		}
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR2_SDRAM"} {
			set_parameter_value ENUM_MEM_IF_TMRD "TMRD_2"
		}    
        } elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0}  {
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM"} {
			set_parameter_value ENUM_MEM_IF_TMRD "DDR2_TMRD"
		}
	
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR3_SDRAM"} {
			set_parameter_value ENUM_MEM_IF_TMRD "DDR3_TMRD"
		} 
 	}
		
        if { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_8"} {
        	set_parameter_value ENUM_MEM_IF_DQS_WIDTH "DQS_WIDTH_1"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_16"} {
        	set_parameter_value ENUM_MEM_IF_DQS_WIDTH "DQS_WIDTH_2"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_24"} {
        	set_parameter_value ENUM_MEM_IF_DQS_WIDTH "DQS_WIDTH_3"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_32"} {
        	set_parameter_value ENUM_MEM_IF_DQS_WIDTH "DQS_WIDTH_4"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_40"} {
        	set_parameter_value ENUM_MEM_IF_DQS_WIDTH "DQS_WIDTH_5"
        }        
   
        
        set_parameter_value ENUM_MEM_IF_CS_PER_RANK "MEM_IF_CS_PER_RANK_1"

        if { ( [get_parameter_value ENUM_MEM_IF_CS_WIDTH] == "MEM_IF_CS_WIDTH_1") && ([get_parameter_value ENUM_MEM_IF_CS_PER_RANK] == "MEM_IF_CS_PER_RANK_1")} {
        	set_parameter_value ENUM_LOCAL_IF_CS_WIDTH "ADDR_WIDTH_0"
        } elseif { ([get_parameter_value ENUM_MEM_IF_CS_WIDTH] == "MEM_IF_CS_WIDTH_2") && ([get_parameter_value ENUM_MEM_IF_CS_PER_RANK] == "MEM_IF_CS_PER_RANK_1")} {
        	set_parameter_value ENUM_LOCAL_IF_CS_WIDTH "ADDR_WIDTH_1"
        }

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0}   {
		if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM") || ([get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR_SDRAM")} {
			set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_200"
		} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR3_SDRAM"} {
			set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_512"
		} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR2_SDRAM"} {
                        if {[get_parameter_value CFG_SELF_RFSH_EXIT_CYCLES ] > 88} {
                                set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_200"
                        } elseif {[get_parameter_value CFG_SELF_RFSH_EXIT_CYCLES] > 74} {
                                set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_88"
                        } elseif {[get_parameter_value CFG_SELF_RFSH_EXIT_CYCLES] > 59} {
                                set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_74"
                        } elseif {[get_parameter_value CFG_SELF_RFSH_EXIT_CYCLES] > 52} {
                                set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_59"
                        } elseif {[get_parameter_value CFG_SELF_RFSH_EXIT_CYCLES] > 44} {
                                set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_52"
                        } elseif {[get_parameter_value CFG_SELF_RFSH_EXIT_CYCLES] > 37} {
                                set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_44"
                        } else {
                                set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "SELF_RFSH_EXIT_CYCLES_37"
                        }
		}       
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0}  {
		if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM") || ([get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR_SDRAM")} {
			set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "DDR2_SELF_RFSH_EXIT_CYCLES"
		} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR3_SDRAM"} {
			set_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES "DDR3_SELF_RFSH_EXIT_CYCLES"
		}
	}

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM"} {
        	set_parameter_value ENUM_MEM_IF_TCCD "TCCD_2"
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR3_SDRAM"} {
        	set_parameter_value ENUM_MEM_IF_TCCD "TCCD_4"
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR2_SDRAM"} {
                set_parameter_value ENUM_MEM_IF_TCCD "TCCD_2"
        }


	if {[string compare -nocase [get_parameter_value CTL_ODT_ENABLED] "true"] == 0} {
		if { [get_parameter_value ENUM_MEM_IF_CS_WIDTH] == "MEM_IF_CS_WIDTH_1"} {
        		set_parameter_value ENUM_WRITE_ODT_CHIP "WRITE_CHIP0_ODT0_CHIP1"
        	} elseif { [get_parameter_value ENUM_MEM_IF_CS_WIDTH] == "MEM_IF_CS_WIDTH_2"} {
        		set_parameter_value ENUM_WRITE_ODT_CHIP "WRITE_CHIP0_ODT0_CHIP1_ODT1"
        	} else {
			set_parameter_value ENUM_WRITE_ODT_CHIP "ODT_DISABLED"
		}
	} else {
		set_parameter_value ENUM_WRITE_ODT_CHIP "ODT_DISABLED"
	}

        
        if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR2_SDRAM") || ([get_parameter_value ENUM_MEM_IF_MEMTYPE] == "DDR3_SDRAM")} {
        	set_parameter_value INTG_POWER_SAVING_EXIT_CYCLES [get_parameter_value CFG_POWER_SAVING_EXIT_CYCLES]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR_BC [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_PCH [get_parameter_value CTL_RD_TO_PCH_EXTRA_CLK]
        	set_parameter_value INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP [get_parameter_value MEM_IF_WR_TO_RD_TURNAROUND_OCT]
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR2_SDRAM"} {
        	set_parameter_value INTG_POWER_SAVING_EXIT_CYCLES [get_parameter_value CFG_POWER_SAVING_EXIT_CYCLES]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR_BC [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP [get_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR]  
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_PCH [get_parameter_value CTL_RD_TO_PCH_EXTRA_CLK]
        	set_parameter_value INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP [get_parameter_value MEM_IF_WR_TO_RD_TURNAROUND_OCT]
	} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR_SDRAM"} {
        	set_parameter_value INTG_POWER_SAVING_EXIT_CYCLES [get_parameter_value CFG_POWER_SAVING_EXIT_CYCLES]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR_BC [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        	set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        	if { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_2"} {
        		set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_PCH [get_parameter_value CTL_RD_TO_PCH_EXTRA_CLK]
        	} else {
        		set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_PCH [get_parameter_value CTL_RD_TO_PCH_EXTRA_CLK]
        	}
        	set_parameter_value INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP [get_parameter_value MEM_IF_WR_TO_RD_TURNAROUND_OCT]
        }       	
        	
        	
        if { [get_parameter_value ENUM_ENABLE_FAST_EXIT_PPD] == "ENABLED"} {
        	set_parameter_value ENUM_PDN_EXIT_CYCLES "FAST_EXIT"
        } else {
        	set_parameter_value ENUM_PDN_EXIT_CYCLES "SLOW_EXIT"
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_0] == "DWIDTH_256"} {
        	set_parameter_value ENUM_RD_PORT_INFO_0 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_0] == "DWIDTH_0"} {
        	set_parameter_value ENUM_RD_PORT_INFO_0 "USE_NO"
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_1] == "DWIDTH_256"} {
        	set_parameter_value ENUM_RD_PORT_INFO_1 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_1] == "DWIDTH_0"} {
        	set_parameter_value ENUM_RD_PORT_INFO_1 "USE_NO"
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_2] == "DWIDTH_256"} {
        	set_parameter_value ENUM_RD_PORT_INFO_2 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_2] == "DWIDTH_0"} {
        	set_parameter_value ENUM_RD_PORT_INFO_2 "USE_NO"
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_3] == "DWIDTH_256"} {
        	set_parameter_value ENUM_RD_PORT_INFO_3 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_3] == "DWIDTH_0"} {
        	set_parameter_value ENUM_RD_PORT_INFO_3 "USE_NO"
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_4] == "DWIDTH_256"} {
        	set_parameter_value ENUM_RD_PORT_INFO_4 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_4] == "DWIDTH_0"} {
        	set_parameter_value ENUM_RD_PORT_INFO_4 "USE_NO"
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_5] == "DWIDTH_256"} {
        	set_parameter_value ENUM_RD_PORT_INFO_5 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_5] == "DWIDTH_0"} {
        	set_parameter_value ENUM_RD_PORT_INFO_5 "USE_NO"
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_0] == "DWIDTH_256"} {
        	set_parameter_value ENUM_WR_PORT_INFO_0 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_0] == "DWIDTH_0"} {
        	set_parameter_value ENUM_WR_PORT_INFO_0 "USE_NO"
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_1] == "DWIDTH_256"} {
        	set_parameter_value ENUM_WR_PORT_INFO_1 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_1] == "DWIDTH_0"} {
        	set_parameter_value ENUM_WR_PORT_INFO_1 "USE_NO"
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_2] == "DWIDTH_256"} {
        	set_parameter_value ENUM_WR_PORT_INFO_2 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_2] == "DWIDTH_0"} {
        	set_parameter_value ENUM_WR_PORT_INFO_2 "USE_NO"
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_3] == "DWIDTH_256"} {
        	set_parameter_value ENUM_WR_PORT_INFO_3 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_3] == "DWIDTH_0"} {
        	set_parameter_value ENUM_WR_PORT_INFO_3 "USE_NO"
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_4] == "DWIDTH_256"} {
        	set_parameter_value ENUM_WR_PORT_INFO_4 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_4] == "DWIDTH_0"} {
        	set_parameter_value ENUM_WR_PORT_INFO_4 "USE_NO"
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_5] == "DWIDTH_256"} {
        	set_parameter_value ENUM_WR_PORT_INFO_5 "USE_0_1_2_3"
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_5] == "DWIDTH_0"} {
        	set_parameter_value ENUM_WR_PORT_INFO_5 "USE_NO"
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1")||([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0"))) } {
        	set_parameter_value ENUM_RD_FIFO_IN_USE_0 "TRUE"
        } else {
        	set_parameter_value ENUM_RD_FIFO_IN_USE_0 "FALSE"
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_1")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_1")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_1")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_1")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_1")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_1"))) } {
        	set_parameter_value ENUM_RD_FIFO_IN_USE_1 "TRUE"
        } else {
                set_parameter_value ENUM_RD_FIFO_IN_USE_1 "FALSE"
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3" ) || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2_3" ) || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2"))) } {
                set_parameter_value ENUM_RD_FIFO_IN_USE_2 "TRUE"
        } else {
                set_parameter_value ENUM_RD_FIFO_IN_USE_2 "FALSE"
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_3"))) } {
                set_parameter_value ENUM_RD_FIFO_IN_USE_3 "TRUE"
        } else {
                set_parameter_value ENUM_RD_FIFO_IN_USE_3 "FALSE"
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0"))) } {
                set_parameter_value ENUM_WR_FIFO_IN_USE_0 "TRUE"
        } else {
                set_parameter_value ENUM_WR_FIFO_IN_USE_0 "FALSE"
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_1"))) } {
                set_parameter_value ENUM_WR_FIFO_IN_USE_1 "TRUE"
        } else {
                set_parameter_value ENUM_WR_FIFO_IN_USE_1 "FALSE"
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2"))) } {
                set_parameter_value ENUM_WR_FIFO_IN_USE_2 "TRUE"
        } else {
                set_parameter_value ENUM_WR_FIFO_IN_USE_2 "FALSE"
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_3"))) } {
                set_parameter_value ENUM_WR_FIFO_IN_USE_3 "TRUE"
        } else {
                set_parameter_value ENUM_WR_FIFO_IN_USE_3 "FALSE"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_0] == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0] == "DWIDTH_0")} {
                set_parameter_value ENUM_CMD_PORT_IN_USE_0 "FALSE"
        } else {
                set_parameter_value ENUM_CMD_PORT_IN_USE_0 "TRUE"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_1] == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1] == "DWIDTH_0")} {
                set_parameter_value ENUM_CMD_PORT_IN_USE_1 "FALSE"
        } else {
                set_parameter_value ENUM_CMD_PORT_IN_USE_1 "TRUE"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_2] == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2] == "DWIDTH_0")} {
                set_parameter_value ENUM_CMD_PORT_IN_USE_2 "FALSE"
        } else {
                set_parameter_value ENUM_CMD_PORT_IN_USE_2 "TRUE"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_3] == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3] == "DWIDTH_0")} {
                set_parameter_value ENUM_CMD_PORT_IN_USE_3 "FALSE"
        } else {
                set_parameter_value ENUM_CMD_PORT_IN_USE_3 "TRUE"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_4] == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4] == "DWIDTH_0")} {
                set_parameter_value ENUM_CMD_PORT_IN_USE_4 "FALSE"
        } else {
                set_parameter_value ENUM_CMD_PORT_IN_USE_4 "TRUE"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_5] == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5] == "DWIDTH_0")} {
                set_parameter_value ENUM_CMD_PORT_IN_USE_5 "FALSE"
        } else {
                set_parameter_value ENUM_CMD_PORT_IN_USE_5 "TRUE"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_0"} {
                set_parameter_value ENUM_PRIORITY_0_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
                set_parameter_value ENUM_PRIORITY_0_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_0"} {
        	set_parameter_value ENUM_PRIORITY_0_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_0_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_0"} {
        	set_parameter_value ENUM_PRIORITY_0_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_0_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_0"} {
        	set_parameter_value ENUM_PRIORITY_0_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_0_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_0"} {
        	set_parameter_value ENUM_PRIORITY_0_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_0_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_0"} {
        	set_parameter_value ENUM_PRIORITY_0_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_0_5 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_1"} {
        	set_parameter_value ENUM_PRIORITY_1_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
        	set_parameter_value ENUM_PRIORITY_1_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_1"} {
        	set_parameter_value ENUM_PRIORITY_1_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_1_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_1"} {
        	set_parameter_value ENUM_PRIORITY_1_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_1_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_1"} {
        	set_parameter_value ENUM_PRIORITY_1_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_1_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_1"} {
        	set_parameter_value ENUM_PRIORITY_1_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_1_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_1"} {
        	set_parameter_value ENUM_PRIORITY_1_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_1_5 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_2"} {
        	set_parameter_value ENUM_PRIORITY_2_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
        	set_parameter_value ENUM_PRIORITY_2_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_2"} {
        	set_parameter_value ENUM_PRIORITY_2_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_2_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_2"} {
        	set_parameter_value ENUM_PRIORITY_2_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_2_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_2"} {
        	set_parameter_value ENUM_PRIORITY_2_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_2_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_2"} {
        	set_parameter_value ENUM_PRIORITY_2_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_2_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_2"} {
        	set_parameter_value ENUM_PRIORITY_2_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_2_5 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_3"} {
        	set_parameter_value ENUM_PRIORITY_3_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
        	set_parameter_value ENUM_PRIORITY_3_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_3"} {
        	set_parameter_value ENUM_PRIORITY_3_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_3_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_3"} {
        	set_parameter_value ENUM_PRIORITY_3_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_3_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_3"} {
        	set_parameter_value ENUM_PRIORITY_3_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_3_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_3"} {
        	set_parameter_value ENUM_PRIORITY_3_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_3_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_3"} {
        	set_parameter_value ENUM_PRIORITY_3_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_3_5 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_4"} {
        	set_parameter_value ENUM_PRIORITY_4_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
        	set_parameter_value ENUM_PRIORITY_4_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_4"} {
        	set_parameter_value ENUM_PRIORITY_4_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_4_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_4"} {
        	set_parameter_value ENUM_PRIORITY_4_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_4_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_4"} {
        	set_parameter_value ENUM_PRIORITY_4_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_4_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_4"} {
        	set_parameter_value ENUM_PRIORITY_4_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_4_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_4"} {
        	set_parameter_value ENUM_PRIORITY_4_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_4_5 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_5"} {
        	set_parameter_value ENUM_PRIORITY_5_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
        	set_parameter_value ENUM_PRIORITY_5_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_5"} {
        	set_parameter_value ENUM_PRIORITY_5_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_5_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_5"} {
        	set_parameter_value ENUM_PRIORITY_5_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_5_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_5"} {
        	set_parameter_value ENUM_PRIORITY_5_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_5_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_5"} {
        	set_parameter_value ENUM_PRIORITY_5_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_5_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_5"} {
        	set_parameter_value ENUM_PRIORITY_5_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_5_5 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_6"} {
        	set_parameter_value ENUM_PRIORITY_6_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
        	set_parameter_value ENUM_PRIORITY_6_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_6"} {
        	set_parameter_value ENUM_PRIORITY_6_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_6_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_6"} {
        	set_parameter_value ENUM_PRIORITY_6_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_6_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_6"} {
        	set_parameter_value ENUM_PRIORITY_6_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_6_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_6"} {
        	set_parameter_value ENUM_PRIORITY_6_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_6_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_6"} {
        	set_parameter_value ENUM_PRIORITY_6_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_6_5 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0] == "PRIORITY_7"} {
        	set_parameter_value ENUM_PRIORITY_7_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        } else {
        	set_parameter_value ENUM_PRIORITY_7_0 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1] == "PRIORITY_7"} {
        	set_parameter_value ENUM_PRIORITY_7_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        } else {
        	set_parameter_value ENUM_PRIORITY_7_1 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2] == "PRIORITY_7"} {
        	set_parameter_value ENUM_PRIORITY_7_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        } else {
        	set_parameter_value ENUM_PRIORITY_7_2 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3] == "PRIORITY_7"} {
        	set_parameter_value ENUM_PRIORITY_7_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        } else {
        	set_parameter_value ENUM_PRIORITY_7_3 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4] == "PRIORITY_7"} {
        	set_parameter_value ENUM_PRIORITY_7_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        } else {
        	set_parameter_value ENUM_PRIORITY_7_4 "WEIGHT_0"
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5] == "PRIORITY_7"} {
        	set_parameter_value ENUM_PRIORITY_7_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]
        } else {
        	set_parameter_value ENUM_PRIORITY_7_5 "WEIGHT_0"
        }

        for {set priority_id 0} {$priority_id != 8} {incr priority_id} {
                set sum_wt_priority 0
                for {set port_id 0} {$port_id != 6} {incr port_id} {
                        set sum_wt_priority [expr $sum_wt_priority + [lindex [split [get_parameter_value ENUM_PRIORITY_${priority_id}_${port_id}] "_"] 1]]
                }

                set_parameter_value INTG_SUM_WT_PRIORITY_${priority_id} $sum_wt_priority
        }

        if { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_2"} {
        	set_parameter_value ENUM_MMR_CFG_MEM_BL "MP_BL_2"
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_4"} {
        	set_parameter_value ENUM_MMR_CFG_MEM_BL "MP_BL_4"
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_8"} {
        	set_parameter_value ENUM_MMR_CFG_MEM_BL "MP_BL_8"
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH] == "MEM_IF_BURSTLENGTH_16"} {
        	set_parameter_value ENUM_MMR_CFG_MEM_BL "MP_BL_16"
        }

        if { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_8"} {
        	set_parameter_value ENUM_CTRL_WIDTH "DATA_WIDTH_16_BIT"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_16"} {
        	set_parameter_value ENUM_CTRL_WIDTH "DATA_WIDTH_32_BIT"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_24"} {
        	set_parameter_value ENUM_CTRL_WIDTH "DATA_WIDTH_32_BIT"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_32"} {
        	set_parameter_value ENUM_CTRL_WIDTH "DATA_WIDTH_64_BIT"
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH] == "MEM_IF_DWIDTH_40"} {
        	set_parameter_value ENUM_CTRL_WIDTH "DATA_WIDTH_64_BIT"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_0] == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_0] == "DWIDTH_64") } {
        	set_parameter_value ENUM_PORT0_WIDTH  "PORT_64_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_0] == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_0] == "DWIDTH_128") } {
        	set_parameter_value ENUM_PORT0_WIDTH  "PORT_128_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_0] == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_0] == "DWIDTH_256") } {
        	set_parameter_value ENUM_PORT0_WIDTH  "PORT_256_BIT"
        } else {
        	set_parameter_value ENUM_PORT0_WIDTH  "PORT_32_BIT"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_1] == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_1] == "DWIDTH_64") } {
        	set_parameter_value ENUM_PORT1_WIDTH  "PORT_64_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_1] == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_1] == "DWIDTH_128") } {
        	set_parameter_value ENUM_PORT1_WIDTH  "PORT_128_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_1] == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_1] == "DWIDTH_256") } {
        	set_parameter_value ENUM_PORT1_WIDTH  "PORT_256_BIT"
        } else {
        	set_parameter_value ENUM_PORT1_WIDTH  "PORT_32_BIT"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_2] == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_2] == "DWIDTH_64") } {
        	set_parameter_value ENUM_PORT2_WIDTH  "PORT_64_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_2] == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_2] == "DWIDTH_128") } {
        	set_parameter_value ENUM_PORT2_WIDTH  "PORT_128_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_2] == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_2] == "DWIDTH_256") } {
        	set_parameter_value ENUM_PORT2_WIDTH  "PORT_256_BIT"
        } else {
        	set_parameter_value ENUM_PORT2_WIDTH  "PORT_32_BIT"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_3] == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_3] == "DWIDTH_64") } {
        	set_parameter_value ENUM_PORT3_WIDTH  "PORT_64_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_3] == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_3] == "DWIDTH_128") } {
        	set_parameter_value ENUM_PORT3_WIDTH  "PORT_128_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_3] == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_3] == "DWIDTH_256") } {
        	set_parameter_value ENUM_PORT3_WIDTH  "PORT_256_BIT"
        } else {
        	set_parameter_value ENUM_PORT3_WIDTH  "PORT_32_BIT"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_4] == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_4] == "DWIDTH_64") } {
        	set_parameter_value ENUM_PORT4_WIDTH  "PORT_64_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_4] == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_4] == "DWIDTH_128") } {
        	set_parameter_value ENUM_PORT4_WIDTH  "PORT_128_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_4] == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_4] == "DWIDTH_256") } {
        	set_parameter_value ENUM_PORT4_WIDTH  "PORT_256_BIT"
        } else {
        	set_parameter_value ENUM_PORT4_WIDTH  "PORT_32_BIT"
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_5] == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_5] == "DWIDTH_64") } {
        	set_parameter_value ENUM_PORT5_WIDTH  "PORT_64_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_5] == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_5] == "DWIDTH_128") } {
        	set_parameter_value ENUM_PORT5_WIDTH  "PORT_128_BIT"
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_5] == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_5] == "DWIDTH_256") } {
        	set_parameter_value ENUM_PORT5_WIDTH  "PORT_256_BIT"
        } else {
        	set_parameter_value ENUM_PORT5_WIDTH  "PORT_32_BIT"
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT0_TYPE "DISABLE"
                } else {
                        set_parameter_value ENUM_CPORT0_TYPE "WRITE"
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT0_TYPE "READ"
                } else {
                        set_parameter_value ENUM_CPORT0_TYPE "BI_DIRECTION"
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT1_TYPE "DISABLE"
                } else {
                        set_parameter_value ENUM_CPORT1_TYPE "WRITE"
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT1_TYPE "READ"
                } else {
                        set_parameter_value ENUM_CPORT1_TYPE "BI_DIRECTION"
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT2_TYPE "DISABLE"
                } else {
                        set_parameter_value ENUM_CPORT2_TYPE "WRITE"
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT2_TYPE "READ"
                } else {
                        set_parameter_value ENUM_CPORT2_TYPE "BI_DIRECTION"
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT3_TYPE "DISABLE"
                } else {
                        set_parameter_value ENUM_CPORT3_TYPE "WRITE"
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT3_TYPE "READ"
                } else {
                        set_parameter_value ENUM_CPORT3_TYPE "BI_DIRECTION"
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT4_TYPE "DISABLE"
                } else {
                        set_parameter_value ENUM_CPORT4_TYPE "WRITE"
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT4_TYPE "READ"
                } else {
                        set_parameter_value ENUM_CPORT4_TYPE "BI_DIRECTION"
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT5_TYPE "DISABLE"
                } else {
                        set_parameter_value ENUM_CPORT5_TYPE "WRITE"
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_NO"} {
                        set_parameter_value ENUM_CPORT5_TYPE "READ"
                } else {
                        set_parameter_value ENUM_CPORT5_TYPE "BI_DIRECTION"
                }
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT0_WFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_1"} {
        	set_parameter_value ENUM_CPORT0_WFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2") } {
        	set_parameter_value ENUM_CPORT0_WFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_3"} {
        	set_parameter_value ENUM_CPORT0_WFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT1_WFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_1"} {
        	set_parameter_value ENUM_CPORT1_WFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2") } {
        	set_parameter_value ENUM_CPORT1_WFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_3"} {
        	set_parameter_value ENUM_CPORT1_WFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT2_WFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_1"} {
        	set_parameter_value ENUM_CPORT2_WFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2") } {
        	set_parameter_value ENUM_CPORT2_WFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_3"} {
        	set_parameter_value ENUM_CPORT2_WFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT3_WFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_1"} {
        	set_parameter_value ENUM_CPORT3_WFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2") } {
        	set_parameter_value ENUM_CPORT3_WFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_3"} {
        	set_parameter_value ENUM_CPORT3_WFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT4_WFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_1"} {
        	set_parameter_value ENUM_CPORT4_WFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2") } {
        	set_parameter_value ENUM_CPORT4_WFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_3"} {
        	set_parameter_value ENUM_CPORT4_WFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT5_WFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_1"} {
        	set_parameter_value ENUM_CPORT5_WFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2") } {
        	set_parameter_value ENUM_CPORT5_WFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_3"} {
        	set_parameter_value ENUM_CPORT5_WFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT0_RFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_1"} {
        	set_parameter_value ENUM_CPORT0_RFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2") } {
        	set_parameter_value ENUM_CPORT0_RFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_3"} {
        	set_parameter_value ENUM_CPORT0_RFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT1_RFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_1"} {
        	set_parameter_value ENUM_CPORT1_RFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2") } {
        	set_parameter_value ENUM_CPORT1_RFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_3"} {
        	set_parameter_value ENUM_CPORT1_RFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT2_RFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_1"} {
        	set_parameter_value ENUM_CPORT2_RFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2") } {
        	set_parameter_value ENUM_CPORT2_RFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_3"} {
        	set_parameter_value ENUM_CPORT2_RFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT3_RFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_1"} {
        	set_parameter_value ENUM_CPORT3_RFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2") } {
        	set_parameter_value ENUM_CPORT3_RFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_3"} {
        	set_parameter_value ENUM_CPORT3_RFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT4_RFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_1"} {
        	set_parameter_value ENUM_CPORT4_RFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2") } {
        	set_parameter_value ENUM_CPORT4_RFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_3"} {
        	set_parameter_value ENUM_CPORT4_RFIFO_MAP "FIFO_3"
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_NO") } {
        	set_parameter_value ENUM_CPORT5_RFIFO_MAP "FIFO_0"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_1"} {
        	set_parameter_value ENUM_CPORT5_RFIFO_MAP "FIFO_1"
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2") } {
        	set_parameter_value ENUM_CPORT5_RFIFO_MAP "FIFO_2"
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_3"} {
        	set_parameter_value ENUM_CPORT5_RFIFO_MAP "FIFO_3"
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_0] == "FALSE"} {
        	set_parameter_value ENUM_RFIFO0_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0") } {
        		set_parameter_value ENUM_RFIFO0_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0") } {
        		set_parameter_value ENUM_RFIFO0_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0") } {
        		set_parameter_value ENUM_RFIFO0_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0") } {
        		set_parameter_value ENUM_RFIFO0_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0") } {
        		set_parameter_value ENUM_RFIFO0_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0") } {
        		set_parameter_value ENUM_RFIFO0_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_1] == "FALSE"} {
        	set_parameter_value ENUM_RFIFO1_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_1") } {
        		set_parameter_value ENUM_RFIFO1_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_1") } {
        		set_parameter_value ENUM_RFIFO1_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_1") } {
        		set_parameter_value ENUM_RFIFO1_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_1") } {
        		set_parameter_value ENUM_RFIFO1_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_1") } {
        		set_parameter_value ENUM_RFIFO1_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_1") } {
        		set_parameter_value ENUM_RFIFO1_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_2] == "FALSE"} {
        	set_parameter_value ENUM_RFIFO2_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2") } {
        		set_parameter_value ENUM_RFIFO2_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2") } {
        		set_parameter_value ENUM_RFIFO2_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2") } {
        		set_parameter_value ENUM_RFIFO2_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2") } {
        		set_parameter_value ENUM_RFIFO2_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2") } {
        		set_parameter_value ENUM_RFIFO2_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2") } {
        		set_parameter_value ENUM_RFIFO2_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_3] == "FALSE"} {
        	set_parameter_value ENUM_RFIFO3_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0] == "USE_3") } {
        		set_parameter_value ENUM_RFIFO3_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1] == "USE_3") } {
        		set_parameter_value ENUM_RFIFO3_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2] == "USE_3") } {
        		set_parameter_value ENUM_RFIFO3_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3] == "USE_3") } {
        		set_parameter_value ENUM_RFIFO3_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4] == "USE_3") } {
        		set_parameter_value ENUM_RFIFO3_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5] == "USE_3") } {
        		set_parameter_value ENUM_RFIFO3_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_0] == "FALSE"} {
        	set_parameter_value ENUM_WFIFO0_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0") } {
        		set_parameter_value ENUM_WFIFO0_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0") } {
        		set_parameter_value ENUM_WFIFO0_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0") } {
        		set_parameter_value ENUM_WFIFO0_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0") } {
        		set_parameter_value ENUM_WFIFO0_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0") } {
        		set_parameter_value ENUM_WFIFO0_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0") } {
        		set_parameter_value ENUM_WFIFO0_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_1] == "FALSE"} {
        	set_parameter_value ENUM_WFIFO1_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_1") } {
        		set_parameter_value ENUM_WFIFO1_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_1") } {
        		set_parameter_value ENUM_WFIFO1_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_1") } {
        		set_parameter_value ENUM_WFIFO1_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_1") } {
        		set_parameter_value ENUM_WFIFO1_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_1") } {
        		set_parameter_value ENUM_WFIFO1_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_1") } {
        		set_parameter_value ENUM_WFIFO1_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_2] == "FALSE"} {
        	set_parameter_value ENUM_WFIFO2_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2") } {
        		set_parameter_value ENUM_WFIFO2_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2") } {
        		set_parameter_value ENUM_WFIFO2_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2") } {
        		set_parameter_value ENUM_WFIFO2_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2") } {
        		set_parameter_value ENUM_WFIFO2_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2") } {
        		set_parameter_value ENUM_WFIFO2_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2") } {
        		set_parameter_value ENUM_WFIFO2_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_3] == "FALSE"} {
        	set_parameter_value ENUM_WFIFO3_CPORT_MAP "CMD_PORT_0"
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0] == "USE_3") } {
        		set_parameter_value ENUM_WFIFO3_CPORT_MAP "CMD_PORT_0"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1] == "USE_3") } {
        		set_parameter_value ENUM_WFIFO3_CPORT_MAP "CMD_PORT_1"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2] == "USE_3") } {
        		set_parameter_value ENUM_WFIFO3_CPORT_MAP "CMD_PORT_2"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3] == "USE_3") } {
        		set_parameter_value ENUM_WFIFO3_CPORT_MAP "CMD_PORT_3"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4] == "USE_3") } {
        		set_parameter_value ENUM_WFIFO3_CPORT_MAP "CMD_PORT_4"
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5] == "USE_3") } {
        		set_parameter_value ENUM_WFIFO3_CPORT_MAP "CMD_PORT_5"
        	}
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_0] == "TRUE"} {
        } else {
        	set_parameter_value ENUM_AUTO_PCH_ENABLE_0 "DISABLED"
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_1] == "TRUE"} {
        } else {
        	set_parameter_value ENUM_AUTO_PCH_ENABLE_1 "DISABLED"
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_2] == "TRUE"} {
        } else {
        	set_parameter_value ENUM_AUTO_PCH_ENABLE_2 "DISABLED"
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_3] == "TRUE"} {
        } else {
        	set_parameter_value ENUM_AUTO_PCH_ENABLE_3 "DISABLED"
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_4] == "TRUE"} {
        } else {
        	set_parameter_value ENUM_AUTO_PCH_ENABLE_4 "DISABLED"
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_5] == "TRUE"} {
        } else {
        	set_parameter_value ENUM_AUTO_PCH_ENABLE_5 "DISABLED"
        }

        set_parameter_value ENUM_RCFG_USER_PRIORITY_0 [get_parameter_value ENUM_USER_PRIORITY_0]
        set_parameter_value ENUM_RCFG_USER_PRIORITY_1 [get_parameter_value ENUM_USER_PRIORITY_1]
        set_parameter_value ENUM_RCFG_USER_PRIORITY_2 [get_parameter_value ENUM_USER_PRIORITY_2]
        set_parameter_value ENUM_RCFG_USER_PRIORITY_3 [get_parameter_value ENUM_USER_PRIORITY_3]
        set_parameter_value ENUM_RCFG_USER_PRIORITY_4 [get_parameter_value ENUM_USER_PRIORITY_4]
        set_parameter_value ENUM_RCFG_USER_PRIORITY_5 [get_parameter_value ENUM_USER_PRIORITY_5]

        set_parameter_value ENUM_RCFG_STATIC_WEIGHT_0 [get_parameter_value ENUM_STATIC_WEIGHT_0]
        set_parameter_value ENUM_RCFG_STATIC_WEIGHT_1 [get_parameter_value ENUM_STATIC_WEIGHT_1]
        set_parameter_value ENUM_RCFG_STATIC_WEIGHT_2 [get_parameter_value ENUM_STATIC_WEIGHT_2]
        set_parameter_value ENUM_RCFG_STATIC_WEIGHT_3 [get_parameter_value ENUM_STATIC_WEIGHT_3]
        set_parameter_value ENUM_RCFG_STATIC_WEIGHT_4 [get_parameter_value ENUM_STATIC_WEIGHT_4]
        set_parameter_value ENUM_RCFG_STATIC_WEIGHT_5 [get_parameter_value ENUM_STATIC_WEIGHT_5]

        for {set priority_id 0} {$priority_id != 8} {incr priority_id} {
                set_parameter_value INTG_RCFG_SUM_WT_PRIORITY_${priority_id} [get_parameter_value INTG_SUM_WT_PRIORITY_${priority_id}]
        }

        set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR_BC [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]
        set_parameter_value INTG_EXTRA_CTL_CLK_RD_TO_WR_DIFF_CHIP [get_parameter_value MEM_IF_RD_TO_WR_TURNAROUND_OCT]

        set_parameter_value INTG_EXTRA_CTL_CLK_WR_TO_RD [get_parameter_value MEM_IF_WR_TO_RD_TURNAROUND_OCT]
        set_parameter_value INTG_EXTRA_CTL_CLK_WR_TO_RD_BC [get_parameter_value MEM_IF_WR_TO_RD_TURNAROUND_OCT]
        set_parameter_value INTG_EXTRA_CTL_CLK_WR_TO_RD_DIFF_CHIP [get_parameter_value MEM_IF_WR_TO_RD_TURNAROUND_OCT]

        for {set port_id 0} {$port_id != 6} {incr port_id} {

                set wr [get_parameter_value ENUM_WR_PORT_INFO_${port_id}]
                set rd [get_parameter_value ENUM_RD_PORT_INFO_${port_id}]

                if {[string compare -nocase $wr "USE_0_1_2_3"] == 0} {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 0
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 3
                } elseif {[string compare -nocase $wr "USE_0_1"] == 0} {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 0
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 1
                } elseif {[string compare -nocase $wr "USE_2_3"] == 0} {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 2
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 3
                } elseif {[string compare -nocase $wr "USE_0"] == 0} {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 0
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 0
                } elseif {[string compare -nocase $wr "USE_1"] == 0} {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 1
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 1
                } elseif {[string compare -nocase $wr "USE_2"] == 0} {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 2
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 2
                } elseif {[string compare -nocase $wr "USE_3"] == 0} {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 3
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 3
                } else {
                        set_parameter_value LSB_WFIFO_PORT_${port_id} 5
                        set_parameter_value MSB_WFIFO_PORT_${port_id} 5
                }

                if {[string compare -nocase $rd "USE_0_1_2_3"] == 0} {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 0
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 3
                } elseif {[string compare -nocase $rd "USE_0_1"] == 0} {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 0
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 1
                } elseif {[string compare -nocase $rd "USE_2_3"] == 0} {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 2
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 3
                } elseif {[string compare -nocase $rd "USE_0"] == 0} {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 0
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 0
                } elseif {[string compare -nocase $rd "USE_1"] == 0} {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 1
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 1
                } elseif {[string compare -nocase $rd "USE_2"] == 0} {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 2
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 2
                } elseif {[string compare -nocase $rd "USE_3"] == 0} {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 3
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 3
                } else {
                        set_parameter_value LSB_RFIFO_PORT_${port_id} 5
                        set_parameter_value MSB_RFIFO_PORT_${port_id} 5
                }
        }
        
        if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0} {
        	_derive_cv_hmc_atom_derived_parameters
        }

        return 1
}

proc ::alt_mem_if::gui::ddrx_controller::_derive_cv_hmc_atom_derived_parameters {} {

        set port_0_being_used 0
        set port_1_being_used 0
        set port_2_being_used 0
        set port_3_being_used 0
        set port_4_being_used 0
        set port_5_being_used 0
        set extra_port_0_being_used 0
        set extra_port_1_being_used 0
        set extra_port_2_being_used 0
        set extra_port_3_being_used 0
        set extra_port_4_being_used 0
        set extra_port_5_being_used 0      
  
        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set_parameter_value CV_PORT_${port_id}_CONNECT_TO_AV_PORT $port_id
        }

        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set wr_fifo_comb [string map {"USE_0_1_2_3" 0 "USE_0_1" 1 "USE_2_3" 2 "USE_0" 3 "USE_1" 4 "USE_2" 5 "USE_3" 6 "USE_NO" 7} [get_parameter_value ENUM_WR_PORT_INFO_${port_id}]]
                set ty [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                set can_use_port_0 0
                set can_use_port_1 0
                set can_use_port_2 0
                set can_use_port_3 0
                set can_use_port_4 0
                set can_use_port_5 0
      
                if { $wr_fifo_comb == 0 || $wr_fifo_comb == 1 || $wr_fifo_comb == 3 || $wr_fifo_comb == 7 } {
                       	set can_use_port_0 1
                }
 
                if { $wr_fifo_comb == 0 || $wr_fifo_comb == 1 || $wr_fifo_comb == 4 || $wr_fifo_comb == 7 } {
                       	set can_use_port_1 1
                }

                if { $wr_fifo_comb == 0 || $wr_fifo_comb == 2 || $wr_fifo_comb == 5 || $wr_fifo_comb == 7 } {
                       	set can_use_port_2 1
                }

              	if { $wr_fifo_comb == 0 || $wr_fifo_comb == 2 || $wr_fifo_comb == 6 || $wr_fifo_comb == 7 } {
                       	set can_use_port_3 1
               	}

                if {$ty == 3 || $ty == 1 } {
                        if { $can_use_port_0 == 1 && $port_0_being_used == 0 } {
                                set_parameter_value CV_PORT_0_CONNECT_TO_AV_PORT $port_id
                                set port_0_being_used 1
                                if { $wr_fifo_comb == 1 } {
                                	set extra_port_1_being_used 1
                                } elseif { $wr_fifo_comb == 0 } {
                                	set extra_port_1_being_used 1
                                	set extra_port_2_being_used 1
                                	set extra_port_3_being_used 1
                               	}
                        } elseif { $can_use_port_1 == 1 && $port_1_being_used == 0 } {
                                set_parameter_value CV_PORT_1_CONNECT_TO_AV_PORT $port_id
                                set port_1_being_used 1
                        } elseif { $can_use_port_2 == 1 && $port_2_being_used == 0 } {
                                set_parameter_value CV_PORT_2_CONNECT_TO_AV_PORT $port_id
                                set port_2_being_used 1
                                if { $wr_fifo_comb == 2 } {
                                	set extra_port_3_being_used 1
                                } elseif { $wr_fifo_comb == 0 } {
                                	set extra_port_0_being_used 1
                                	set extra_port_1_being_used 1
                                	set extra_port_3_being_used 1
                               	}
                        } elseif { $can_use_port_3 == 1 && $port_3_being_used == 0 } {
                                set_parameter_value CV_PORT_3_CONNECT_TO_AV_PORT $port_id
                                set port_3_being_used 1
                        } else {
                        }
                } else {
                }
       	}

        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set ty [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                set can_use_port_0 1
                set can_use_port_1 1
                set can_use_port_2 1
                set can_use_port_3 1
                set can_use_port_4 1
                set can_use_port_5 1

                if {$ty == 2 } {
                        if { $can_use_port_0 == 1 && $port_0_being_used == 0 && $extra_port_0_being_used == 0} {
                                set_parameter_value CV_PORT_0_CONNECT_TO_AV_PORT $port_id
                                set port_0_being_used 1
                        } elseif { $can_use_port_1 == 1 && $port_1_being_used == 0 && $extra_port_1_being_used == 0} {
                                set_parameter_value CV_PORT_1_CONNECT_TO_AV_PORT $port_id
                                set port_1_being_used 1
                        } elseif { $can_use_port_2 == 1 && $port_2_being_used == 0 && $extra_port_2_being_used == 0} {
                                set_parameter_value CV_PORT_2_CONNECT_TO_AV_PORT $port_id
                                set port_2_being_used 1
                        } elseif { $can_use_port_3 == 1 && $port_3_being_used == 0 && $extra_port_3_being_used == 0} {
                                set_parameter_value CV_PORT_3_CONNECT_TO_AV_PORT $port_id
                                set port_3_being_used 1
                        } elseif { $can_use_port_4 == 1 && $port_4_being_used == 0 } {
                                set_parameter_value CV_PORT_4_CONNECT_TO_AV_PORT $port_id
                                set port_4_being_used 1
                        } elseif { $can_use_port_5 == 1 && $port_5_being_used == 0 } {
                                set_parameter_value CV_PORT_5_CONNECT_TO_AV_PORT $port_id
                                set port_5_being_used 1
                        } else {
                        }
                } else {
                }
        }
               
        
        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set ty [get_parameter_value CPORT_TYPE_PORT_${port_id}]

                if {$port_id == 0} { 
                set tg_can_use_port_0 1
                set tg_can_use_port_1 1
                set tg_can_use_port_2 1
                set tg_can_use_port_3 1
                set tg_can_use_port_4 1
                set tg_can_use_port_5 1
                }
                                
                if {$ty == 3 || $ty == 1} {
                        if {$tg_can_use_port_0 == 1} {
                                set_parameter_value TG_TEMP_PORT_0 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_0 0
                        } elseif {$tg_can_use_port_1 == 1} {
                                set_parameter_value TG_TEMP_PORT_1 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_1 0
                        } elseif {$tg_can_use_port_2 == 1} {
                                set_parameter_value TG_TEMP_PORT_2 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_2 0
                      	} elseif {$tg_can_use_port_3 == 1} {
                                set_parameter_value TG_TEMP_PORT_3 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_3 0
                     	} elseif {$tg_can_use_port_4 == 1} {
                                set_parameter_value TG_TEMP_PORT_4 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_4 0
                     	} elseif {$tg_can_use_port_5 == 1} {
                                set_parameter_value TG_TEMP_PORT_5 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_5 0                             
                        } else {
                        }
                } else {
                }
        }
        
        
        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set ty [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                            
                if {$ty == 2} {
                        if {$tg_can_use_port_0 == 1} {
                                set_parameter_value TG_TEMP_PORT_0 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_0 0
                        } elseif {$tg_can_use_port_1 == 1} {
                                set_parameter_value TG_TEMP_PORT_1 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_1 0
                        } elseif {$tg_can_use_port_2 == 1} {
                                set_parameter_value TG_TEMP_PORT_2 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_2 0
                      	} elseif {$tg_can_use_port_3 == 1} {
                                set_parameter_value TG_TEMP_PORT_3 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_3 0
                     	} elseif {$tg_can_use_port_4 == 1} {
                                set_parameter_value TG_TEMP_PORT_4 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_4 0
                     	} elseif {$tg_can_use_port_5 == 1} {
                                set_parameter_value TG_TEMP_PORT_5 [get_parameter_value CPORT_TYPE_PORT_${port_id}]
                                set tg_can_use_port_5 0                             
                        } else {
                        }
                } else {
                }
        }
                

        set av_port_id [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]

        for {set port_id 0} {$port_id != 6} {incr port_id} {
                if { [set port_${port_id}_being_used] == 0 } {
                       	if { $av_port_id < 6 } {
                                set_parameter_value CV_PORT_${port_id}_CONNECT_TO_AV_PORT $av_port_id
                                set port_${port_id}_being_used 1
                                incr av_port_id
                        }
                }
        }


        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set av_port [get_parameter_value CV_PORT_${port_id}_CONNECT_TO_AV_PORT]
                set_parameter_value CV_AVL_DATA_WIDTH_PORT_${port_id} [get_parameter_value AVL_DATA_WIDTH_PORT_${av_port}]
                set_parameter_value CV_AVL_ADDR_WIDTH_PORT_${port_id} [get_parameter_value AVL_ADDR_WIDTH_PORT_${av_port}]
                set_parameter_value CV_AVL_NUM_SYMBOLS_PORT_${port_id} [get_parameter_value AVL_NUM_SYMBOLS_PORT_${av_port}]
                set_parameter_value CV_CPORT_TYPE_PORT_${port_id} [get_parameter_value CPORT_TYPE_PORT_${av_port}]
                set_parameter_value CV_LSB_WFIFO_PORT_${port_id} [get_parameter_value LSB_WFIFO_PORT_${av_port}]
                set_parameter_value CV_MSB_WFIFO_PORT_${port_id} [get_parameter_value MSB_WFIFO_PORT_${av_port}]
                set_parameter_value CV_LSB_RFIFO_PORT_${port_id} [get_parameter_value LSB_RFIFO_PORT_${av_port}]
                set_parameter_value CV_MSB_RFIFO_PORT_${port_id} [get_parameter_value MSB_RFIFO_PORT_${av_port}]
                set_parameter_value CV_ENUM_AUTO_PCH_ENABLE_${port_id} [get_parameter_value ENUM_AUTO_PCH_ENABLE_${av_port}]
                set_parameter_value CV_ENUM_CMD_PORT_IN_USE_${port_id} [get_parameter_value ENUM_CMD_PORT_IN_USE_${av_port}]
                set_parameter_value CV_ENUM_CPORT${port_id}_RFIFO_MAP [get_parameter_value ENUM_CPORT${av_port}_RFIFO_MAP]
                set_parameter_value CV_ENUM_CPORT${port_id}_TYPE [get_parameter_value ENUM_CPORT${av_port}_TYPE]
                set_parameter_value CV_ENUM_CPORT${port_id}_WFIFO_MAP [get_parameter_value ENUM_CPORT${av_port}_WFIFO_MAP]
                set_parameter_value CV_ENUM_ENABLE_BONDING_${port_id} [get_parameter_value ENUM_ENABLE_BONDING_${av_port}]
                set_parameter_value CV_ENUM_PORT${port_id}_WIDTH [get_parameter_value ENUM_PORT${av_port}_WIDTH]
                for {set priority_id 0} {$priority_id != 8} {incr priority_id} {
                        set_parameter_value CV_ENUM_PRIORITY_${priority_id}_${port_id} [get_parameter_value ENUM_PRIORITY_${priority_id}_${av_port}]
                }
                set_parameter_value CV_ENUM_RCFG_STATIC_WEIGHT_${port_id} [get_parameter_value ENUM_RCFG_STATIC_WEIGHT_${av_port}]
                set_parameter_value CV_ENUM_RCFG_USER_PRIORITY_${port_id} [get_parameter_value ENUM_RCFG_USER_PRIORITY_${av_port}]
                set_parameter_value CV_ENUM_RD_DWIDTH_${port_id} [get_parameter_value ENUM_RD_DWIDTH_${av_port}]
                set_parameter_value CV_ENUM_RD_PORT_INFO_${port_id} [get_parameter_value ENUM_RD_PORT_INFO_${av_port}]
                set_parameter_value CV_ENUM_STATIC_WEIGHT_${port_id} [get_parameter_value ENUM_STATIC_WEIGHT_${av_port}]
                set_parameter_value CV_ENUM_USER_PRIORITY_${port_id} [get_parameter_value ENUM_USER_PRIORITY_${av_port}]
                set_parameter_value CV_ENUM_WR_DWIDTH_${port_id} [get_parameter_value ENUM_WR_DWIDTH_${av_port}]
                set_parameter_value CV_ENUM_WR_PORT_INFO_${port_id} [get_parameter_value ENUM_WR_PORT_INFO_${av_port}]
        }

        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set av_port [get_parameter_value CV_PORT_${port_id}_CONNECT_TO_AV_PORT]
                set_parameter_value AV_PORT_${av_port}_CONNECT_TO_CV_PORT $port_id
        }

        for {set fifo_id 0} {$fifo_id != 4} {incr fifo_id} {
                set av_port [string map {"CMD_PORT_0" 0 "CMD_PORT_1" 1 "CMD_PORT_2" 2 "CMD_PORT_3" 3 "CMD_PORT_4" 4 "CMD_PORT_5" 5} [get_parameter_value ENUM_RFIFO${fifo_id}_CPORT_MAP]]

                if {[string compare -nocase [get_parameter_value ENUM_RD_FIFO_IN_USE_${fifo_id}] "TRUE"] == 0} {
                        set_parameter_value CV_ENUM_RFIFO${fifo_id}_CPORT_MAP "CMD_PORT_[get_parameter_value AV_PORT_${av_port}_CONNECT_TO_CV_PORT]"
                } else {
                        set_parameter_value CV_ENUM_RFIFO${fifo_id}_CPORT_MAP "CMD_PORT_0"
                }

                set av_port [string map {"CMD_PORT_0" 0 "CMD_PORT_1" 1 "CMD_PORT_2" 2 "CMD_PORT_3" 3 "CMD_PORT_4" 4 "CMD_PORT_5" 5} [get_parameter_value ENUM_WFIFO${fifo_id}_CPORT_MAP]]

                if {[string compare -nocase [get_parameter_value ENUM_WR_FIFO_IN_USE_${fifo_id}] "TRUE"] == 0} {
                        set_parameter_value CV_ENUM_WFIFO${fifo_id}_CPORT_MAP "CMD_PORT_[get_parameter_value AV_PORT_${av_port}_CONNECT_TO_CV_PORT]"
                } else {
                        set_parameter_value CV_ENUM_WFIFO${fifo_id}_CPORT_MAP "CMD_PORT_0"
                }
        }
}

proc ::alt_mem_if::gui::ddrx_controller::_rederive_hmc_atom_derived_parameters {} {

        for {set port_id 0} {$port_id != 6} {incr port_id} {
                set_parameter_value AVL_DATA_WIDTH_PORT_${port_id} [get_parameter_value CV_AVL_DATA_WIDTH_PORT_${port_id}]
                set_parameter_value AVL_ADDR_WIDTH_PORT_${port_id} [get_parameter_value CV_AVL_ADDR_WIDTH_PORT_${port_id}]
                set_parameter_value AVL_NUM_SYMBOLS_PORT_${port_id} [get_parameter_value CV_AVL_NUM_SYMBOLS_PORT_${port_id}]
                set_parameter_value LSB_WFIFO_PORT_${port_id} [get_parameter_value CV_LSB_WFIFO_PORT_${port_id}]
                set_parameter_value MSB_WFIFO_PORT_${port_id} [get_parameter_value CV_MSB_WFIFO_PORT_${port_id}]
                set_parameter_value LSB_RFIFO_PORT_${port_id} [get_parameter_value CV_LSB_RFIFO_PORT_${port_id}]
               	set_parameter_value MSB_RFIFO_PORT_${port_id} [get_parameter_value CV_MSB_RFIFO_PORT_${port_id}]
                set_parameter_value ENUM_AUTO_PCH_ENABLE_${port_id} [get_parameter_value CV_ENUM_AUTO_PCH_ENABLE_${port_id}]
                set_parameter_value ENUM_CMD_PORT_IN_USE_${port_id} [get_parameter_value CV_ENUM_CMD_PORT_IN_USE_${port_id}]
                set_parameter_value ENUM_CPORT${port_id}_RFIFO_MAP [get_parameter_value CV_ENUM_CPORT${port_id}_RFIFO_MAP]
                set_parameter_value ENUM_CPORT${port_id}_TYPE [get_parameter_value CV_ENUM_CPORT${port_id}_TYPE]
                set_parameter_value ENUM_CPORT${port_id}_WFIFO_MAP [get_parameter_value CV_ENUM_CPORT${port_id}_WFIFO_MAP]
                set_parameter_value ENUM_ENABLE_BONDING_${port_id} [get_parameter_value CV_ENUM_ENABLE_BONDING_${port_id}]
                set_parameter_value ENUM_PORT${port_id}_WIDTH [get_parameter_value CV_ENUM_PORT${port_id}_WIDTH]
                for {set priority_id 0} {$priority_id != 8} {incr priority_id} {
                        set_parameter_value ENUM_PRIORITY_${priority_id}_${port_id} [get_parameter_value CV_ENUM_PRIORITY_${priority_id}_${port_id}]
                }
                set_parameter_value ENUM_RCFG_STATIC_WEIGHT_${port_id} [get_parameter_value CV_ENUM_RCFG_STATIC_WEIGHT_${port_id}]
                set_parameter_value ENUM_RCFG_USER_PRIORITY_${port_id} [get_parameter_value CV_ENUM_RCFG_USER_PRIORITY_${port_id}]
                set_parameter_value ENUM_RD_DWIDTH_${port_id} [get_parameter_value CV_ENUM_RD_DWIDTH_${port_id}]
                set_parameter_value ENUM_RD_PORT_INFO_${port_id} [get_parameter_value CV_ENUM_RD_PORT_INFO_${port_id}]
                set_parameter_value ENUM_STATIC_WEIGHT_${port_id} [get_parameter_value CV_ENUM_STATIC_WEIGHT_${port_id}]
                set_parameter_value ENUM_USER_PRIORITY_${port_id} [get_parameter_value CV_ENUM_USER_PRIORITY_${port_id}]
                set_parameter_value ENUM_WR_DWIDTH_${port_id} [get_parameter_value CV_ENUM_WR_DWIDTH_${port_id}]
                set_parameter_value ENUM_WR_PORT_INFO_${port_id} [get_parameter_value CV_ENUM_WR_PORT_INFO_${port_id}]
        }

        for {set fifo_id 0} {$fifo_id != 4} {incr fifo_id} {
                set_parameter_value ENUM_RFIFO${fifo_id}_CPORT_MAP [get_parameter_value CV_ENUM_RFIFO${fifo_id}_CPORT_MAP]
                set_parameter_value ENUM_WFIFO${fifo_id}_CPORT_MAP [get_parameter_value CV_ENUM_WFIFO${fifo_id}_CPORT_MAP]
        }
}

proc ::alt_mem_if::gui::ddrx_controller::_validate_hmc_atom_parameters {} {

if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0} {
        set arriav_rbc 1
} else {
        set arriav_rbc 0
}

	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0} {
		if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR2_SDRAM") && ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR3_SDRAM")} {
        	_eprint "For Arria V devices, the internal protocol for Hard External Memory Interface must be set to DDR2 or DDR3 only."
        	}
        } elseif  {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0} {
		if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR2_SDRAM") && ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR3_SDRAM") && ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "LPDDR2_SDRAM")} {
        	_eprint "For Cyclone V devices, the internal protocol for Hard External Memory Interface must be set to DDR2, DDR3, or LPDDR2 only."
        	}
        }
        
        

	set protocol [_get_protocol]

	set rbc_validation_pass 1

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_CFG_TYPE]  != "DDR2" } {
        		_eprint "Hard EMIF : \[Rule 0\] has been violated. The internal protocol must be set to DDR2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { [get_parameter_value ENUM_CFG_TYPE]  != "DDR3" } {
        		_eprint "Hard EMIF : \[Rule 1\] has been violated. The internal protocol must be set to DDR3."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_CFG_TYPE]  != "LPDDR2" } {
        		_eprint "Hard EMIF : \[Rule 782\] has been violated. The internal protocol must be set to LPDDR2."
        		set rbc_validation_pass 0
        	}
        }
        
        if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_8"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_0"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_8" } {
        			_eprint "Hard EMIF : \[Rule 2\] has been violated. The internal interface width must be set to 8 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to 8."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_8"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_16" } {
        			_eprint "Hard EMIF : \[Rule 3\] has been violated. The internal interface width must be set to 16 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to [expr 8 + 8]."
        			set rbc_validation_pass 0
        		}
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_16"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_0"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_16" } {
        			_eprint "Hard EMIF : \[Rule 4\] has been violated. The internal interface width must be set to 16 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to 16."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_8"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_24" } {
        			_eprint "Hard EMIF : \[Rule 5\] has been violated. The internal interface width must be set to 24 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to [expr 16 + 8]."
        			set rbc_validation_pass 0
        		}
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_0"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_24" } {
        			_eprint "Hard EMIF : \[Rule 6\] has been violated. The internal interface width must be set to 24 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to 24."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_8"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_32" } {
        			_eprint "Hard EMIF : \[Rule 7\] has been violated. The internal interface width must be set to 32 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to [expr 24 + 8]."
        			set rbc_validation_pass 0
        		}
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_32"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_0"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_32" } {
        			_eprint "Hard EMIF : \[Rule 8\] has been violated. The internal interface width must be set to 32 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to 32."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_8"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_40" } {
        			_eprint "Hard EMIF : \[Rule 9\] has been violated. The internal interface width must be set to 40 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to [expr 32 + 8]."
        			set rbc_validation_pass 0
        		}
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH]  == "ECC_DQ_WIDTH_0"} {
        		if { [get_parameter_value ENUM_CFG_INTERFACE_WIDTH]  != "DWIDTH_40" } {
        			_eprint "Hard EMIF : \[Rule 10\] has been violated. The internal interface width must be set to 40 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' set to 40."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if {$arriav_rbc == 1} {
		if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR2_SDRAM") && ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR3_SDRAM") } {
			_eprint "Hard EMIF : \[Rule 11\] has been violated. Protocol ${protocol} is not supported"
			set rbc_validation_pass 0
		}
	} 
	if {$arriav_rbc == 0} {
		if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR2_SDRAM") && ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "DDR3_SDRAM") && ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "LPDDR_SDRAM") && ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  != "LPDDR2_SDRAM") } {
			_eprint "Hard EMIF : \[Rule 794\] has been violated. Protocol ${protocol} is not supported"
			set rbc_validation_pass 0
		}	
	}

        if { [get_parameter_value ENUM_REORDER_DATA]  != "DATA_REORDERING"} {
        	if { [get_parameter_value ENUM_CFG_STARVE_LIMIT]  != "STARVE_LIMIT_4" } {
        		_eprint "Hard EMIF : \[Rule 12\] has been violated. The '[get_parameter_property STARVE_LIMIT DISPLAY_NAME]' value must be set to 4 when '[get_parameter_property CFG_REORDER_DATA DISPLAY_NAME]' checkbox is unchecked"
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_2"} {
        	if { [get_parameter_value ENUM_CFG_BURST_LENGTH]  != "BL_2" } {
        		_eprint "Hard EMIF : \[Rule 13\] has been violated. The internal burst length must be set to 2 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_4"} {
        	if { [get_parameter_value ENUM_CFG_BURST_LENGTH]  != "BL_4" } {
        		_eprint "Hard EMIF : \[Rule 14\] has been violated. The internal burst length must be set to 4 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_8"} {
        	if { [get_parameter_value ENUM_CFG_BURST_LENGTH]  != "BL_8" } {
        		_eprint "Hard EMIF : \[Rule 15\] has been violated. The internal burst length must be set to 8 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 8."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_16"} {
        	if { [get_parameter_value ENUM_CFG_BURST_LENGTH]  != "BL_16" } {
        		_eprint "Hard EMIF : \[Rule 16\] has been violated. The internal burst length must be set to 16 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 16."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_1") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_2") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_4") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_8") } {
        	_eprint "Hard EMIF : \[Rule 17\] has been violated. The multiplication result of '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE DISPLAY_NAME]' or '[get_parameter_property MEM_NUMBER_OF_DIMMS DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DISPLAY_NAME]' must be either 1, 2, 4 or 8."
        	set rbc_validation_pass 0
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_4" } {
                        _eprint "Hard EMIF : \[Rule 18\] has been violated. The '[get_parameter_property MEM_BL DISPLAY_NAME]' value must be set to 4 for DDR3"
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_800_5_5_5") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_800_6_6_6") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1066_6_6_6") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1066_7_7_7") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1066_8_8_8") } {
        		_dprint 3 "Hard EMIF : \[Rule 19\] has been violated. The memory speed bin must be either DDR3_800_5_5_5, DDR3_800_6_6_6, DDR3_1066_6_6_6, DDR3_1066_7_7_7 or DDR3_1066_8_8_8 for DDR3."
        	}
        }

        if { ([get_parameter_value ENUM_CTL_USR_REFRESH]  != "CTL_USR_REFRESH_ENABLED") && ([get_parameter_value ENUM_CTL_USR_REFRESH]  != "CTL_USR_REFRESH_DISABLED") } {
                _eprint "Hard EMIF : \[Rule 20\] has been violated. The '[get_parameter_property CTL_USR_REFRESH_EN DISPLAY_NAME]' must be checked or unchecked."
                set rbc_validation_pass 0
        }

        if { ([get_parameter_value ENUM_CTL_ECC_ENABLED]  != "CTL_ECC_DISABLED") && ([get_parameter_value ENUM_CTL_ECC_ENABLED]  != "CTL_ECC_ENABLED") } {
                _eprint "Hard EMIF : \[Rule 21\] has been violated.. The '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' must be checked or unchecked."
                set rbc_validation_pass 0
        }


	if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
		if { [get_parameter_value ENUM_CTL_ECC_ENABLED]  == "CTL_ECC_ENABLED"} {
			if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
				if { ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32")} {
					_eprint "Hard EMIF : \[Rule 784\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either 16 or 32 '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8"
					set rbc_validation_pass 0
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16"} {
					_eprint "Hard EMIF : \[Rule 785\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 16 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16."
					set rbc_validation_pass 0 
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_32"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32"} {
					_eprint "Hard EMIF : \[Rule 786\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 32 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 32."
					set rbc_validation_pass 0  
				}
			}
		} else {
			if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16"} {
					_eprint "Hard EMIF : \[Rule 787\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 16 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16."
					set rbc_validation_pass 0 
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_32"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32"} {
					_eprint "Hard EMIF : \[Rule 788\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 32 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 32."
					set rbc_validation_pass 0  
				}
			}
		}
	} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
		if { [get_parameter_value ENUM_CTL_ECC_ENABLED]  == "CTL_ECC_ENABLED"} {
			if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
				if { ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32") } {
					_eprint "Hard EMIF : \[Rule 789\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either 16 or 32 '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8"
					set rbc_validation_pass 0
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16"} {
					_eprint "Hard EMIF : \[Rule 790\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 16 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16."
					set rbc_validation_pass 0 
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_32"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32"} {
					_eprint "Hard EMIF : \[Rule 791\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 32 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 32."
					set rbc_validation_pass 0  
				}
			}
		} else {
			if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16"} {
					_eprint "Hard EMIF : \[Rule 792\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 16 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16."
					set rbc_validation_pass 0 
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_32"} {
				if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32"} {
					_eprint "Hard EMIF : \[Rule 793\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to 32 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 32."
					set rbc_validation_pass 0  
				}
			}
		}        
	} else {
		if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
			if { (([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_8") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_24") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_40")) } {
				_eprint "Hard EMIF : \[Rule 22\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either 8, 16, 24, 32 or 40 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8"
				set rbc_validation_pass 0
			}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
        		if { (([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32")) } {
        			_eprint "Hard EMIF : \[Rule 23\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either 16 or 32 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16."
        			set rbc_validation_pass 0
        		}
		}
	}

        if { [get_parameter_value ENUM_CTL_ECC_ENABLED]  == "CTL_ECC_ENABLED"} {
        	if { ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_4") && ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_8") } {
        		_eprint "Hard EMIF : \[Rule 24\] has been violated. The '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' value must be set to either 4 or 8 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
        		set rbc_validation_pass 0
        	}
        } else { 
        	if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        		if { ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_16") && ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_32") } {
        			_eprint "Hard EMIF : \[Rule 800\] has been violated. The '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' value must be set to either 16 or 32 when '[get_parameter_property ENUM_MEM_IF_MEMTYPE]' is LPDDR."
        		} 
        	} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        		if { ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_8") && ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_16") && ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_32") } {
        			_eprint "Hard EMIF : \[Rule 801\] has been violated. The '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' value must be set to either 8, 16 or 32 when '[get_parameter_property ENUM_MEM_IF_MEMTYPE]' is LPDDR2."
        		} 
        	} else { 
        		if {([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_4") && ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_8") && ([get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  != "MEM_IF_DQ_PER_CHIP_16") } {
        		_eprint "Hard EMIF : \[Rule 25\] has been violated. The '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' value must be set to either 4, 8 or 16 when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is unchecked."
        		set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_400_3_3_3") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_400_4_4_4") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_533_3_3_3") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_533_4_4_4") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_667_4_4_4") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_667_5_5_5") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_800_4_4_4") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_800_5_5_5") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR2_800_6_6_6") } {
        		_dprint 3 "Hard EMIF : \[Rule 26\] has been violated. The memory speed bin must be either DDR2_400_3_3_3, DDR2_400_4_4_4, DDR2_533_3_3_3, DDR2_533_4_4_4, DDR2_667_4_4_4, DDR2_667_5_5_5, DDR2_800_4_4_4, DDR2_800_5_5_5 or  DDR2_800_6_6_6 for DDR2."
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_1") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_2") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_4") } {
        		_eprint "Hard EMIF : \[Rule 27\] has been violated. The multiplication result of '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE DISPLAY_NAME]' or '[get_parameter_property MEM_NUMBER_OF_DIMMS DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DISPLAY_NAME]' must be either 1, 2 or 4 for DDR2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH]  != "ADDR_WIDTH_2") && ([get_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH]  != "ADDR_WIDTH_3") } {
        		_dprint 3 "Hard EMIF : \[Rule 28\] has been violated. The '[get_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME]' value must be set to either 2 or 3 for DDR2."
        	}
        	if { [get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  == "ADDR_WIDTH_13"} {
        	        if { ([get_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH]  != "ADDR_WIDTH_2") } {
        	        	_dprint 3 "Hard EMIF : \[Rule 29\] has been violated. The '[get_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME]' value must be set to 2 when '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' is set to 13 for DDR2."
        	        }
        	} elseif { [get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  == "ADDR_WIDTH_9"} {
        	        if { ([get_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH]  != "ADDR_WIDTH_2") } {
        	        	_dprint 3 "Hard EMIF : \[Rule 30\] has been violated. The '[get_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME]' value must be set to 2 when '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' is set to 9 for DDR2."
        	        }
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_14") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_15") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_16") } {
        		_dprint 3 "Hard EMIF : \[Rule 31\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 13, 14, 15 or 16 for DDR2."
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_9") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_11") } {
        		_dprint 3 "Hard EMIF : \[Rule 32\] has been violated. The '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 9, 10 or 11 for DDR2."
        	}
        	if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_4"} {
        		if { ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_11") } {
        			_dprint 3 "Hard EMIF : \[Rule 33\] has been violated. The '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 11 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 4 for DDR2."
        		}
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_400_3_3_3"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_3") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") } {
        			_dprint 3 "Hard EMIF : \[Rule 34\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 3 or 4 when the memory speed bin used is DDR2-400-3-3-3 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_400_4_4_4"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") } {
        			_dprint 3 "Hard EMIF : \[Rule 35\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to 4 when the memory speed bin used is DDR2-400-4-4-4 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_533_3_3_3"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_3") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") } {
        			_dprint 3 "Hard EMIF : \[Rule 36\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 3 or 4 when the memory speed bin used is DDR2-533-3-3-3 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_533_4_4_4"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_3") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") } {
        			_dprint 3 "Hard EMIF : \[Rule 37\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 3 or 4 when the memory speed bin used is DDR2-533-4-4-4 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_667_4_4_4"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 38\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 4 or 5 when the memory speed bin used is DDR2-667-4-4-4 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_667_5_5_5"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 39\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 4 or 5 when the memory speed bin used is DDR2-667-5-5-5 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_800_4_4_4"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 40\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 4 or 5 when the memory speed bin used is DDR2-800-4-4-4 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_800_5_5_5"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 41\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 4 or 5 when the memory speed bin used is DDR2-800-5-5-5 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_800_6_6_6"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 42\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 4 or 5 when the memory speed bin used is DDR2-800-6-6-6 for DDR2."
        		}
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_3"} {
        		if { [get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_2" } {
        			_dprint 3 "Hard EMIF : \[Rule 43\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with 1 must be 2 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_4"} {
        		if { [get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_3" } {
        			_dprint 3 "Hard EMIF : \[Rule 44\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with 1 must be 3 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5"} {
        		if { [get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_4" } {
        			_dprint 3 "Hard EMIF : \[Rule 45\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with 1 must be 4 for DDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6"} {
        		if { [get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5" } {
        			_dprint 3 "Hard EMIF : \[Rule 46\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with 1 must be 5 for DDR2."
        		}
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if {$arriav_rbc == 1} {
			if { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_400_3_3_3"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") } {
					_dprint 3 "Hard EMIF : \[Rule 47\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns or [_tck2tns 3 0] ns when the memory speed bin used is DDR2-400-3-3-3 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_400_4_4_4"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") } {
					_dprint 3 "Hard EMIF : \[Rule 48\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns or [_tck2tns 3 0] ns when the memory speed bin used is DDR2-400-4-4-4 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_533_3_3_3"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") } {
					_dprint 3 "Hard EMIF : \[Rule 49\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns, [_tck2tns 3 0] ns or [_tck2tns 4 0] ns when the memory speed bin used is DDR2-533-3-3-3 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_533_4_4_4"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") } {
					_dprint 3 "Hard EMIF : \[Rule 50\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns, [_tck2tns 3 0] ns or [_tck2tns 4 0] ns when the memory speed bin used is DDR2-533-4-4-4 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_667_4_4_4"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") } {
					_dprint 3 "Hard EMIF : \[Rule 51\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns, [_tck2tns 3 0] ns, [_tck2tns 4 0] ns or [_tck2tns 5 0] ns when the memory speed bin used is DDR2-667-4-4-4 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_667_5_5_5"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") } {
					_dprint 3 "Hard EMIF : \[Rule 52\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns, [_tck2tns 3 0] ns, [_tck2tns 4 0] ns or [_tck2tns 5 0] ns when the memory speed bin used is DDR2-667-5-5-5 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_800_4_4_4"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_6") } {
					_dprint 3 "Hard EMIF : \[Rule 53\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns, [_tck2tns 3 0] ns, [_tck2tns 4 0] ns, [_tck2tns 5 0] ns or [_tck2tns 6 0] ns when the memory speed bin used is DDR2-800-4-4-4 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_800_5_5_5"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_6") } {
					_dprint 3 "Hard EMIF : \[Rule 54\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns, [_tck2tns 3 0] ns, [_tck2tns 4 0] ns, [_tck2tns 5 0] ns or [_tck2tns 6 0] ns when the memory speed bin used is DDR2-800-5-5-5 for DDR2."
				}
			} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_800_6_6_6"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_6") } {
					_dprint 3 "Hard EMIF : \[Rule 55\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 2 0] ns, [_tck2tns 3 0] ns, [_tck2tns 4 0] ns, [_tck2tns 5 0] ns or [_tck2tns 6 0] ns when the memory speed bin used is DDR2-800-6-6-6 for DDR2."
				}
			}
		}
	}
	
	if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
		if {$arriav_rbc == 0} {
			if { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR2_400_3_3_3"} {
				if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_6") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_7") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_8") } {
				_eprint 3 "Hard EMIF : \[Rule 783\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either 2, 3, 4, 5, 6, 7 or 8 when the memory speed bin used is DDR2-400-3-3-3 for DDR2."
				set rbc_validation_pass 0
				}
			}
		}
	}

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_1") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_2") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_3") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_4") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_5") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_6") } {
        		_eprint "Hard EMIF : \[Rule 56\] has been violated. The '[get_parameter_property MEM_ATCL DISPLAY_NAME]' value must be set to either 0, 1, 2, 3, 4, 5 or 6 for DDR2."
        		set rbc_validation_pass 0
        	}
        }

         if {$arriav_rbc == 0} {
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
			if { [get_parameter_value ENUM_MEM_IF_TMRD]  != "TMRD_2" } {
				_eprint "Hard EMIF : \[Rule 865\] has been violated. For Cyclone V devices, the internal TMRD must be set to TMRD_2 for DDR2."
				set rbc_validation_pass 0
			}
		}
	
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
			if { [get_parameter_value ENUM_MEM_IF_TMRD]  != "TMRD_4" } {
				_eprint "Hard EMIF : \[Rule 866\] has been violated. For Cyclone V devices, the internal TMRD must be set to TMRD_4 for DDR3."
				set rbc_validation_pass 0
			}
		}
	 }
	 
	 if {$arriav_rbc == 1} {
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
			if { [get_parameter_value ENUM_MEM_IF_TMRD]  != "DDR2_TMRD" } {
				_eprint "Hard EMIF : \[Rule 57\] has been violated. For Arria V devices, the internal TMRD must be set to DDR2_TMRD for DDR2."
				set rbc_validation_pass 0
			}
		}
	
		if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
			if { [get_parameter_value ENUM_MEM_IF_TMRD]  != "DDR3_TMRD" } {
				_eprint "Hard EMIF : \[Rule 58\] has been violated. For Arria V devices, the internal TMRD must be set to DDR3_TMRD for DDR3."
				set rbc_validation_pass 0
			}
		}
	 }
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE] == "LPDDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "LPDDR2_667") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "LPDDR2_800") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "LPDDR2_1066") } {
        		_dprint 3 "Hard EMIF : \[Rule 802\] has been violated. The memory speed bin must be either LPDDR2_667, LPDDR2_800, or LPDDR2_1066 for LPDDR2."
        	}
        }
        
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM" } {
        	if { ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_1") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_2") } {
        		_eprint "Hard EMIF : \[Rule 804\] has been violated. The multiplication result of '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE DISPLAY_NAME]' or '[get_parameter_property MEM_NUMBER_OF_DIMMS DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DISPLAY_NAME]' must be either 1 or 2 for LPDDR2. Currently it is set to '[get_parameter_value MEM_IF_CS_WIDTH]'"
        		set rbc_validation_pass 0
        	}
        }
        
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH]  != "ADDR_WIDTH_3") } {
        		_dprint 3 "Hard EMIF : \[Rule 805\] has been violated. The '[get_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME]' value must be set to 3 for LPDDR2."
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH]  != "ADDR_WIDTH_2") } {
        		_dprint 3 "Hard EMIF : \[Rule 806\] has been violated. The '[get_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME]' value must be set to 2 for LPDDR."
        	}
        }
        
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_12") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_12") } {
        			_dprint 3 "Hard EMIF : \[Rule 807\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to 12 and '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 12 when'[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8 for LPDDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_12") } {
        			_dprint 3 "Hard EMIF : \[Rule 808\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to 13 and '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 12 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16 for LPDDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_32"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_12") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 809\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to 12 and '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 10 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 32 for LPDDR2."
        		}
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 810\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to 13 and '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 10 when'[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8 for LPDDR."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 811\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to 13 and '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 10 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16 for LPDDR."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_32"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 812\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to 13 and '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 10 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 32 for LPDDR."
        		}
        	}
        }
       
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_2") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_3") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") } {
        		_dprint 3 "Hard EMIF : \[Rule 813\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to 2, 3 or 4 for LPDDR."
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_667"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_3") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_4") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 814\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 3, 4 or 5 when the memory speed bin used is 667MHz for LPDDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_800"} {
        		if { [get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6" } {
        			_dprint 3 "Hard EMIF : \[Rule 815\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 6 when the memory speed bin used is 800MHz for LPDDR2."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_1066"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 816\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 7 or 8 when the memory speed bin used is 1066MHz for LPDDR2."
        		}	
        	}
        }
        
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_1" } {
        		_dprint 3 "Hard EMIF : \[Rule 817\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 1 for LPDDR."
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_667") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_3")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_1") } {
        			_dprint 3 "Hard EMIF : \[Rule 818\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 1 when the memory speed bin used is 667MHz and and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 3 for LPDDR2."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_667") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_4")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_2") } {
        			_dprint 3 "Hard EMIF : \[Rule 819\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 2 when the memory speed bin used is 667MHz and and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 4 for LPDDR2."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_667") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_2") } {
        			_dprint 3 "Hard EMIF : \[Rule 820\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 2 when the memory speed bin used is 667MHz and and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 for LPDDR2."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_800") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_3") } {
        			_dprint 3 "Hard EMIF : \[Rule 821\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 3 when the memory speed bin used is 800MHz and and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for LPDDR2."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_1066") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_4") } {
        			_dprint 3 "Hard EMIF : \[Rule 822\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 4 when the memory speed bin used is 1066MHz and and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for LPDDR2."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "LPDDR2_1066") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_4") } {
        			_dprint 3 "Hard EMIF : \[Rule 823\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 4 when the memory speed bin used is 1066MHz and and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for LPDDR2."
        		}
        	}
        }
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TMRD]  != "TMRD_2" } {
        		_eprint "Hard EMIF : \[Rule 824\] has been violated. The internal TMRD must be set to TMRD_2 for LPDDR."
        		set rbc_validation_pass 0
        	}
        }
        
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_1") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_6") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_7") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_8") } {
        		_eprint 3 "Hard EMIF : \[Rule 825\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6, 7 or 8 for LPDDR2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_1") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_2") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_3") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_4") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_6") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_7") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_8") } {
        		_eprint 3 "Hard EMIF : \[Rule 826\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6, 7 or 8 for LPDDR."
        		set rbc_validation_pass 0
        	}
        }

        
        if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM") || ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM") } {
        	if { [get_parameter_value ENUM_MEM_IF_AL]  != "AL_0"} {
        		_eprint "Hard EMIF : \[Rule 827\] has been violated. The '[get_parameter_property MEM_ATCL DISPLAY_NAME]' value must be set to 0 for LPDDR and LPDDR2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { [get_parameter_value NUM_MEM_IF_SPEEDBIN]  == "LPDDR_267"} {
        		if { [get_parameter_value ENUM_MEM_IF_TWTR]  != "TWTR_1" } {
        			_dprint 3 "Hard EMIF : \[Rule 828\] has been violated. The '[get_parameter_property MEM_TWTR DISPLAY_NAME]' value must be set to 1 when the memory speed bin used is 267MHz for LPDDR."
        		}
        	} elseif { [get_parameter_value NUM_MEM_IF_SPEEDBIN]  == "LPDDR_333"} {
        		if { [get_parameter_value ENUM_MEM_IF_TWTR]  != "TWTR_1" } {
        			_dprint 3 "Hard EMIF : \[Rule 829\] has been violated. The '[get_parameter_property MEM_TWTR DISPLAY_NAME]' value must be set to 1 when the memory speed bin used is 333MHz for LPDDR."
        		}
         	} elseif { [get_parameter_value NUM_MEM_IF_SPEEDBIN]  == "LPDDR_370"} {
        		if { [get_parameter_value ENUM_MEM_IF_TWTR]  != "TWTR_2" } {
        			_dprint 3 "Hard EMIF : \[Rule 830\] has been violated. The '[get_parameter_property MEM_TWTR DISPLAY_NAME]' value must be set to 2 when the memory speed bin used is 370MHz for LPDDR."
        		}
        	} elseif { [get_parameter_value NUM_MEM_IF_SPEEDBIN]  == "LPDDR_400"} {
        		if { [get_parameter_value ENUM_MEM_IF_TWTR]  != "TWTR_2" } {
        			_dprint 3 "Hard EMIF : \[Rule 831\] has been violated. The '[get_parameter_property MEM_TWTR DISPLAY_NAME]' value must be set to 2 when the memory speed bin used is 400MHz for LPDDR."
        		}
        	}
        }
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TFAW]  != "TFAW_0" } {
        		_eprint "Hard EMIF : \[Rule 832\] has been violated. The internal TFAW must be set to TFAW_0 for LPDDR."
        		set rbc_validation_pass 0
        	}
        }        
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TRTP]  != "TFAW_0" } {
        		_eprint "Hard EMIF : \[Rule 833\] has been violated. The internal TRTP must be set to TRTP_0 for LPDDR."
        		set rbc_validation_pass 0
        	}
        }         
        
        
        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_800_5_5_5") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_800_6_6_6") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1066_6_6_6") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1066_7_7_7") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1066_8_8_8") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1333_7_7_7") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1333_8_8_8") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1333_9_9_9") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1333_10_10_10") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  != "DDR3_1600_11_11_11") } {
        		_dprint 3 "Hard EMIF : \[Rule 59\] has been violated. The memory speed bin must be either DDR3_800_5_5_5, DDR3_800_6_6_6, DDR3_1066_6_6_6, DDR3_1066_7_7_7, DDR3_1066_8_8_8, DDR3_1333_7_7_7, DDR3_1333_8_8_8, DDR3_1333_9_9_9, DDR3_1333_10_10_10, DDR3_1600_8_8_8, DDR3_1600_9_9_9, DDR3_1600_10_10_10 or DDR3_1600_11_11_11 for DDR3."
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_1") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_2") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_4") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_8") } {
        		_eprint "Hard EMIF : \[Rule 60\] has been violated. The multiplication result of '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DEVICE DISPLAY_NAME]' or '[get_parameter_property MEM_NUMBER_OF_DIMMS DISPLAY_NAME]' with '[get_parameter_property MEM_NUMBER_OF_RANKS_PER_DIMM DISPLAY_NAME]' must be either 1, 2, 4 or 8 for DDR3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_BANKADDR_WIDTH]  != "ADDR_WIDTH_3") } {
        		_dprint 3 "Hard EMIF : \[Rule 61\] has been violated. The '[get_parameter_property MEM_BANKADDR_WIDTH DISPLAY_NAME]' value must be set to 3 for DDR3."
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_12") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_14") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_15") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_16") } {
        		_dprint 3 "Hard EMIF : \[Rule 62\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 12, 13, 14, 15 or 16 for DDR3."
        	}
        	if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_4"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_14") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_15") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_16") } {
        			_dprint 3 "Hard EMIF : \[Rule 63\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 13, 14, 15 or 16 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 4 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_14") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_15") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_16") } {
        			_dprint 3 "Hard EMIF : \[Rule 64\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 13, 14, 15 or 16 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
        		if { ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_12") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_13") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_14") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_15") && ([get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  != "ADDR_WIDTH_16") } {
        			_dprint 3 "Hard EMIF : \[Rule 65\] has been violated. The '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 12, 13, 14, 15 or 16 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16 for DDR3."
        		}
        	}

        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_11") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_12") } {
        		_dprint 3 "Hard EMIF : \[Rule 66\] has been violated. The '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 10, 11 or 12 for DDR3."
        	}

        	if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") && ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_11") } {
                                _dprint 3 "Hard EMIF : \[Rule 67\] has been violated. The '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to either 10 or 11 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_4"} {
        		if { [get_parameter_value ENUM_MEM_IF_ROWADDR_WIDTH]  == "ADDR_WIDTH_16"} {
                                if { ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_12") } {
                                        _dprint 3 "Hard EMIF : \[Rule 68\] has been violated. The '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 12 when '[get_parameter_property MEM_ROW_ADDR_WIDTH DISPLAY_NAME]' is set to 16 and '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 4 for DDR3."
                                }
        		} else {
                                if { ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_11") } {
                                        _dprint 3 "Hard EMIF : \[Rule 69\] has been violated. The '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 11 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 4 for DDR3."
                                }
        		}

        	} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
        		if { ([get_parameter_value ENUM_MEM_IF_COLADDR_WIDTH]  != "ADDR_WIDTH_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 70\] has been violated. The '[get_parameter_property MEM_COL_ADDR_WIDTH DISPLAY_NAME]' value must be set to 10 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16 for DDR3."
        		}
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_800_5_5_5"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 71\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 5 or 6 when the memory speed bin used is DDR3-800-5-5-5 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_800_6_6_6"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 72\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-800-6-6-6 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_6_6_6"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 73\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 5, 6, 7 or 8 when the memory speed bin used is DDR3-1066-6-6-6 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_7_7_7"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 74\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 6, 7 or 8 when the memory speed bin used is DDR3-1066-7-7-7 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_8_8_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 75\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 6 or 8 when the memory speed bin used is DDR3-1066-8-8-8 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_7_7_7"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 76\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 5, 6, 7, 8, 9, or 10 when the memory speed bin used is DDR3-1333-7-7-7 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_8_8_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 77\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 5, 6, 7, 8, 9, or 10 when the memory speed bin used is DDR3-1333-8-8-8 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_9_9_9"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 78\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 6, 8, 9 or 10 when the memory speed bin used is DDR3-1333-9-9-9 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_10_10_10"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 79\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 6, 8 or 10 when the memory speed bin used is DDR3-1333-10-10-10 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_11") } {
        			_dprint 3 "Hard EMIF : \[Rule 80\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 5, 6, 7, 8, 9, 10 or 11 when the memory speed bin used is DDR3-1600-8-8-8 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_11") } {
        			_dprint 3 "Hard EMIF : \[Rule 81\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 5, 6, 7, 8, 9, 10 or 11 when the memory speed bin used is DDR3-1600-9-9-9 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_5") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_11") } {
        			_dprint 3 "Hard EMIF : \[Rule 82\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 5, 6, 7, 8, 9, 10 or 11 when the memory speed bin used is DDR3-1600-10-10-10 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_11_11_11"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  != "TCL_11") } {
        			_dprint 3 "Hard EMIF : \[Rule 83\] has been violated. The '[get_parameter_property MEM_TCL DISPLAY_NAME]' value must be set to either 6, 8, 10 or 11 when the memory speed bin used is DDR3-1600-11-11-11 for DDR3."
        		}
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM" } {
        	if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        		_eprint "Hard EMIF : \[Rule 84\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 5, 6, 7 or 8 for DDR3."
        		set rbc_validation_pass 0
        	}

        	if { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_800_5_5_5"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 85\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-800-5-5-5 for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_800_6_6_6"} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 86\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-800-6-6-6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_6_6_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 87\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1066-6-6-6 and and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_6_6_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 88\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 5 or 6 when the memory speed bin used is DDR3-1066-6-6-6 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_6_6_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 89\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1066-6-6-6 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_6_6_6") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 90\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1066-6-6-6 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 91\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1066-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 92\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1066-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 93\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1066-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 94\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1066-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1066_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 95\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1066-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 96\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1333-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 97\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 5 or 6 when the memory speed bin used is DDR3-1333-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 98\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 6 or 7 when the memory speed bin used is DDR3-1333-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 99\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 6 or 7 when the memory speed bin used is DDR3-1333-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_9")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 100\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1333-7-7-7 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 9 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_7_7_7") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 101\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-800-6-6-6 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 102\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1333-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 103\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1333-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 104\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1333-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 105\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 6 or 7 when the memory speed bin used is DDR3-1333-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_9")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 106\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1333-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 9 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 107\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1333-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 108\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1333-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 109\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1333-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_9")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 110\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1333-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 9 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 111\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1333-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 112\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1333-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 113\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1333-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1333_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 114\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1333-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 115\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1600-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 116\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 5 or 6 when the memory speed bin used is DDR3-1600-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 117\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 6 or 7 when the memory speed bin used is DDR3-1600-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 118\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 6 or 7 when the memory speed bin used is DDR3-1600-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_9")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 119\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 7 or 8 when the memory speed bin used is DDR3-1600-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 9 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 120\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 7 or 8 when the memory speed bin used is DDR3-1600-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_8_8_8") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_11")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 121\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 8 when the memory speed bin used is DDR3-1600-8-8-8 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 11 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 122\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1600-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 123\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 5 or 6 when the memory speed bin used is DDR3-1600-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 124\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1600-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 125\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 6 or 7 when the memory speed bin used is DDR3-1600-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_9")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 126\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 7 or 8 when the memory speed bin used is DDR3-800-6-6-6 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 9 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 127\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 7 or 8 when the memory speed bin used is DDR3-1600-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_9_9_9") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_11")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 128\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 8 when the memory speed bin used is DDR3-1600-9-9-9 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 11 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 129\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1600-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 130\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1600-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 131\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1600-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 132\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1600-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_9")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 133\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1600-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 9 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") && ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 134\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to either 7 or 8 when the memory speed bin used is DDR3-1600-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_10_10_10") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_11")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 135\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 8 when the memory speed bin used is DDR3-1600-10-10-10 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 11 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_11_11_11") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 136\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 5 when the memory speed bin used is DDR3-1600-11-11-11 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_11_11_11") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 137\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 6 when the memory speed bin used is DDR3-1600-11-11-11 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_11_11_11") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 138\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 7 when the memory speed bin used is DDR3-1600-11-11-11 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 for DDR3."
        		}
        	} elseif { ([get_parameter_value ENUM_MEM_IF_SPEEDBIN]  == "DDR3_1600_11_11_11") && ([get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_11")} {
        		if { ([get_parameter_value ENUM_MEM_IF_TCWL]  != "TCWL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 139\] has been violated. The '[get_parameter_property MEM_WTCL DISPLAY_NAME]' value must be set to 8 when the memory speed bin used is DDR3-1600-11-11-11 and the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 11 for DDR3."
        		}
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_5") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_6") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_7") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_8") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_10") && ([get_parameter_value ENUM_MEM_IF_TWR]  != "TWR_12") } {
        		_dprint 3 "Hard EMIF : \[Rule 140\] has been violated. The '[get_parameter_property MEM_TWR_NS DISPLAY_NAME]' value must be set to either [_tck2tns 5 0] ns, [_tck2tns 6 0] ns, [_tck2tns 7 0] ns, [_tck2tns 8 0] ns, [_tck2tns 10 0] ns or [_tck2tns 12 0] ns for DDR3."
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_5"} {
        		if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_3") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_4") } {
        			_dprint 3 "Hard EMIF : \[Rule 141\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with [get_parameter_value MR1_AL] must be either 0, 3 or 4 when the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 5 and '[get_parameter_property MEM_ATCL DISPLAY_NAME]' set to [get_parameter_value MEM_ATCL] for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_6"} {
        		if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_4") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_5") } {
        			_dprint 3 "Hard EMIF : \[Rule 142\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with [get_parameter_value MR1_AL] must be either 0, 4 or 5 when the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 6 and '[get_parameter_property MEM_ATCL DISPLAY_NAME]' set to [get_parameter_value MEM_ATCL] for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_7"} {
        		if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_5") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_6") } {
        			_dprint 3 "Hard EMIF : \[Rule 143\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with [get_parameter_value MR1_AL] must be either 0, 5 or 6 when the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 7 and '[get_parameter_property MEM_ATCL DISPLAY_NAME]' set to [get_parameter_value MEM_ATCL] for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_8"} {
        		if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_6") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_7") } {
        			_dprint 3 "Hard EMIF : \[Rule 144\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with [get_parameter_value MR1_AL] must be either 0, 6 or 7 when the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 8 and '[get_parameter_property MEM_ATCL DISPLAY_NAME]' set to [get_parameter_value MEM_ATCL] for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_9"} {
        		if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_7") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_8") } {
        			_dprint 3 "Hard EMIF : \[Rule 145\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with [get_parameter_value MR1_AL] must be either 0, 7 or 8 when the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 9 and '[get_parameter_property MEM_ATCL DISPLAY_NAME]' set to [get_parameter_value MEM_ATCL] for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_10"} {
        		if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_8") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_9") } {
        			_dprint 3 "Hard EMIF : \[Rule 146\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with [get_parameter_value MR1_AL] must be either 0, 8 or 9 when the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 10 and '[get_parameter_property MEM_ATCL DISPLAY_NAME]' set to [get_parameter_value MEM_ATCL] for DDR3."
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_TCL]  == "TCL_11"} {
        		if { ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_0") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_9") && ([get_parameter_value ENUM_MEM_IF_AL]  != "AL_10") } {
        			_dprint 3 "Hard EMIF : \[Rule 147\] has been violated. The substraction result of '[get_parameter_property MEM_TCL DISPLAY_NAME]' with [get_parameter_value MR1_AL] must be either 0, 9 or 10 when the '[get_parameter_property MEM_TCL DISPLAY_NAME]' set to 11 and '[get_parameter_property MEM_ATCL DISPLAY_NAME]' set to [get_parameter_value MEM_ATCL] for DDR3."
        		}
        	}

        }

        if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_8"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQS_WIDTH]  != "DQS_WIDTH_1" } {
        		_eprint "Hard EMIF : \[Rule 148\] has been violated. The internal DQS width must be set to 1 when the '[get_parameter_property MEM_IF_DQ_WIDTH DISPLAY_NAME]' set tp 8."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_16"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQS_WIDTH]  != "DQS_WIDTH_2" } {
        		_eprint "Hard EMIF : \[Rule 149\] has been violated. The internal DQS width must be set to 2 when the '[get_parameter_property MEM_IF_DQ_WIDTH DISPLAY_NAME]' set tp 16."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQS_WIDTH]  != "DQS_WIDTH_3" } {
        		_eprint "Hard EMIF : \[Rule 150\] has been violated. The internal DQS width must be set to 3 when the '[get_parameter_property MEM_IF_DQ_WIDTH DISPLAY_NAME]' set tp 24."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_32"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQS_WIDTH]  != "DQS_WIDTH_4" } {
        		_eprint "Hard EMIF : \[Rule 151\] has been violated. The internal DQS width must be set to 4 when the '[get_parameter_property MEM_IF_DQ_WIDTH DISPLAY_NAME]' set tp 32."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQS_WIDTH]  != "DQS_WIDTH_5" } {
        		_eprint "Hard EMIF : \[Rule 152\] has been violated. The internal DQS width must be set to 5 when the '[get_parameter_property MEM_IF_DQ_WIDTH DISPLAY_NAME]' set tp 40."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_CS_PER_RANK]  != "MEM_IF_CS_PER_RANK_1" } {
        	_eprint "Hard EMIF : \[Rule 153\] has been violated. The '[get_parameter_property MEM_FORMAT DISPLAY_NAME]' value must be set to Discrete Device."
        	set rbc_validation_pass 0
        }

        if { ( [get_parameter_value ENUM_MEM_IF_CS_WIDTH]  == "MEM_IF_CS_WIDTH_1") && ([get_parameter_value ENUM_MEM_IF_CS_PER_RANK]  == "MEM_IF_CS_PER_RANK_1")} {
        	if { [get_parameter_value ENUM_LOCAL_IF_CS_WIDTH]  != "ADDR_WIDTH_0" } {
        		_eprint "Hard EMIF : \[Rule 154\] has been violated. The internal local chip select width must be set to 0 when the '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' set to 1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  == "MEM_IF_CS_WIDTH_2") && ([get_parameter_value ENUM_MEM_IF_CS_PER_RANK]  == "MEM_IF_CS_PER_RANK_1")} {
        	if { [get_parameter_value ENUM_LOCAL_IF_CS_WIDTH]  != "ADDR_WIDTH_1" } {
        		_eprint "Hard EMIF : \[Rule 155\] has been violated. The internal local chip select width must be set to 1 when the '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' set to 2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_CTL_ECC_ENABLED]  == "CTL_ECC_ENABLED"} {
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH]  != "ECC_DQ_WIDTH_8" } {
        		_eprint "Hard EMIF : \[Rule 156\] has been violated. The internal ECC DQ width must be set to 8 when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_CTL_ECC_RMW_ENABLED]  != "CTL_ECC_RMW_DISABLED") && ([get_parameter_value ENUM_CTL_ECC_RMW_ENABLED]  != "CTL_ECC_RMW_ENABLED") } {
        		_eprint "Hard EMIF : \[Rule 157\] has been violated. The '[get_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_NAME]' must be either checked or unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_ENABLE_INTR]  != "ENABLED") && ([get_parameter_value ENUM_ENABLE_INTR]  != "DISABLED") } {
        		_eprint "Hard EMIF : \[Rule 158\] has been violated. The '[get_parameter_property ENUM_ENABLE_INTR DISPLAY_NAME]' must be either checked or unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_MASK_SBE_INTR]  != "ENABLED") && ([get_parameter_value ENUM_MASK_SBE_INTR]  != "DISABLED") } {
        		_eprint "Hard EMIF : \[Rule 159\] has been violated. The '[get_parameter_property ENUM_MASK_SBE_INTR DISPLAY_NAME]' must be either checked or unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_MASK_DBE_INTR]  != "ENABLED") && ([get_parameter_value ENUM_MASK_DBE_INTR]  != "DISABLED") } {
        		_eprint "Hard EMIF : \[Rule 160\] has been violated. The '[get_parameter_property ENUM_MASK_DBE_INTR DISPLAY_NAME]' must be either checked or unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_MASK_CORR_DROPPED_INTR]  != "ENABLED") && ([get_parameter_value ENUM_MASK_CORR_DROPPED_INTR]  != "DISABLED") } {
        		_eprint "Hard EMIF : \[Rule 161\] has been violated. The '[get_parameter_property ENUM_MASK_CORR_DROPPED_INTR DISPLAY_NAME]' must be either checked or unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_CTL_ECC_RMW_ENABLED]  != "CTL_ECC_RMW_DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 162\] has been violated. The '[get_parameter_property CTL_ECC_AUTO_CORRECTION_ENABLED DISPLAY_NAME]' must be unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { [get_parameter_value ENUM_ECC_DQ_WIDTH]  != "ECC_DQ_WIDTH_0" } {
        		_eprint "Hard EMIF : \[Rule 163\] has been violated. The internal ECC DQ width must be set to 0 when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked."
        		set rbc_validation_pass 0
        	}

        	if { [get_parameter_value ENUM_ENABLE_INTR]  != "DISABLED" } {

        		_eprint "Hard EMIF : \[Rule 164\] has been violated. The '[get_parameter_property ENUM_ENABLE_INTR DISPLAY_NAME]' must be unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked."
        		set rbc_validation_pass 0

        	}
        	if { [get_parameter_value ENUM_MASK_SBE_INTR]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 165\] has been violated. The '[get_parameter_property ENUM_MASK_SBE_INTR DISPLAY_NAME]' must be unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { [get_parameter_value ENUM_MASK_DBE_INTR]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 166\] has been violated. The '[get_parameter_property ENUM_MASK_DBE_INTR DISPLAY_NAME]' must be unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { [get_parameter_value ENUM_MASK_CORR_DROPPED_INTR]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 167\] has been violated. The '[get_parameter_property ENUM_MASK_CORR_DROPPED_INTR DISPLAY_NAME]' must be unchecked when the '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is unchecked."
        		set rbc_validation_pass 0
        	}
        }

        if {$arriav_rbc == 0} {
		if { ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM") || ([get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM")} {
			if { [get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_200" } {
				_dprint 3 "Hard EMIF : \[Rule 863\] has been violated. The internal Self-Refresh exit cycles must be set to 200 exit cycles for DDR2."
			}
		} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
			if { [get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_512" } {
				_dprint 3 "Hard EMIF : \[Rule 864\] has been violated. The internal Self-Refresh exit cycles must be set to 512 exit cycles for DDR3."
			}
		} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
			if { ([get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_37") && ([get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_44") && ([get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_52") &&([get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_59") && ([get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_74") && ([get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "SELF_RFSH_EXIT_CYCLES_88") } {
				_dprint 3 "Hard EMIF : \[Rule 834\] has been violated. The internal Self-Refresh exit cycles must be set to 37, 44, 52, 59, 74 and 88 exit cycles for LPDDR2"
			}
		}        
        }
        
       if {$arriav_rbc == 1} {
	       if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
			if { [get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "DDR2_SELF_RFSH_EXIT_CYCLES" } {
				_eprint "Hard EMIF : \[Rule 168\] has been violated. The internal Self-Refresh exit cycles must be set to DDR2_SELF_RFSH_EXIT_CYCLES for DDR2."
				set rbc_validation_pass 0
			}
		} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
			if { [get_parameter_value ENUM_CFG_SELF_RFSH_EXIT_CYCLES]  != "DDR3_SELF_RFSH_EXIT_CYCLES" } {
				_eprint "Hard EMIF : \[Rule 169\] has been violated. The internal Self-Refresh exit cycles must be set to DDR3_SELF_RFSH_EXIT_CYCLES for DDR3."
				set rbc_validation_pass 0
			}
		} 
        }        

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TCCD]  != "TCCD_2" } {
        		_dprint 3 "Hard EMIF : \[Rule 170\] has been violated. The '[get_parameter_property CFG_TCCD DISPLAY_NAME]' value must be set to 2 for DDR2."
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TCCD]  != "TCCD_4" } {
        		_dprint 3 "Hard EMIF : \[Rule 171\] has been violated. The '[get_parameter_property CFG_TCCD DISPLAY_NAME]' value must be set to 4 for DDR3."
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_TCCD]  != "TCCD_1" } {
        		_dprint 3 "Hard EMIF : \[Rule 835\] has been violated. The '[get_parameter_property CFG_TCCD DISPLAY_NAME]' value must be set to 1 for LPDDR."
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM"} {
        	if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_8"} {
			if { [get_parameter_value ENUM_MEM_IF_TCCD]  != "TCCD_1" } {
			_dprint 3 "Hard EMIF : \[Rule 836\] has been violated. The '[get_parameter_property CFG_TCCD DISPLAY_NAME]' value must be set to 1 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 8 for LPDDR2."
			} 
		} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_16"} {
			if { [get_parameter_value ENUM_MEM_IF_TCCD]  != "TCCD_1" } {
			_dprint 3 "Hard EMIF : \[Rule 837\] has been violated. The '[get_parameter_property CFG_TCCD DISPLAY_NAME]' value must be set to 1 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 16 for LPDDR2."
			} 
		} elseif { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_32"} {
			if { [get_parameter_value ENUM_MEM_IF_TCCD]  != "TCCD_2" } {
			_dprint 3 "Hard EMIF : \[Rule 838\] has been violated. The '[get_parameter_property CFG_TCCD DISPLAY_NAME]' value must be set to 2 when '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' is set to 32 for LPDDR2."
			} 
		}
	}

        if { ([get_parameter_value ENUM_ENABLE_FAST_EXIT_PPD]  != "ENABLED") && ([get_parameter_value ENUM_ENABLE_FAST_EXIT_PPD]  != "DISABLED") } {
        	_eprint "Hard EMIF : \[Rule 172\] has been violated. The '[get_parameter_property MEM_PD DISPLAY_NAME]' value must be set to either [get_parameter_property MEM_PD ALLOWED_RANGES]."
        	set rbc_validation_pass 0
        }

        if { [get_parameter_value ENUM_READ_ODT_CHIP]  != "ODT_DISABLED" } {
        	_eprint "Hard EMIF : \[Rule 174\] has been violated. The internal Read ODT Chip must be disabled."
        	set rbc_validation_pass 0
        }

        
 
               	
        		
        if { [get_parameter_value ENUM_ENABLE_FAST_EXIT_PPD]  == "ENABLED"} {
        	if { [get_parameter_value ENUM_PDN_EXIT_CYCLES]  != "FAST_EXIT" } {
        		_eprint "Hard EMIF : \[Rule 177\] has been violated. The internal power down exit cycle must be set to fast exit when '[get_parameter_property MEM_PD DISPLAY_NAME]' set to Fast exit or DLL on."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PDN_EXIT_CYCLES]  != "SLOW_EXIT" } {
        		_eprint "Hard EMIF : \[Rule 178\] has been violated. The internal power down exit cycle must be set to slow exit when '[get_parameter_property MEM_PD DISPLAY_NAME]' other than Fast exit or DLL on."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_1") && ([get_parameter_value ENUM_MEM_IF_CS_WIDTH]  != "MEM_IF_CS_WIDTH_2") } {
        	_eprint "Hard EMIF : \[Rule 179\] has been violated. The '[get_parameter_property DEVICE_DEPTH DISPLAY_NAME]' value must be either 1 or 2."
        	set rbc_validation_pass 0
        }

        if { [get_parameter_value ENUM_MEM_IF_DQ_PER_CHIP]  == "MEM_IF_DQ_PER_CHIP_4" } {
        	_eprint "Hard EMIF : \[Rule 180\] has been violated. The '[get_parameter_property MEM_DQ_PER_DQS DISPLAY_NAME]' value must be set to other than 4."
        	set rbc_validation_pass 0
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR_SDRAM" } {
        	_eprint "Hard EMIF : \[Rule 181\] has been violated. DDR1 is not supported."
        	set rbc_validation_pass 0
        }

        if { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR2_SDRAM" } {
		if { ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_4") && ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_8") } {
			_eprint "Hard EMIF : \[Rule 182\] has been violated. The '[get_parameter_property MEM_BL DISPLAY_NAME]' value must be set to either 4 or 8 for DDR2"
			set rbc_validation_pass 0
		} 
	} elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "DDR3_SDRAM" } {
		if { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_8" } {
			_eprint "Hard EMIF : \[Rule 839\] has been violated. The '[get_parameter_property MEM_BL DISPLAY_NAME]' value must be set to 8 for DDR3"
			set rbc_validation_pass 0
		} 
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR_SDRAM" } {
		if { ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_2") && ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_4") && ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_8") } {
			_eprint "Hard EMIF : \[Rule 840\] has been violated. The '[get_parameter_property MEM_BL DISPLAY_NAME]' value must be set to either 2, 4 or 8 for LPDDR"
			set rbc_validation_pass 0
		} 
        } elseif { [get_parameter_value ENUM_MEM_IF_MEMTYPE]  == "LPDDR2_SDRAM" } {
		if { ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_4") && ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_8") && ([get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  != "MEM_IF_BURSTLENGTH_16") } {
			_eprint "Hard EMIF : \[Rule 841\] has been violated. The '[get_parameter_property MEM_BL DISPLAY_NAME]' value must be set to either 4, 8 or 16 for LPDDR2"
			set rbc_validation_pass 0
		} 		
	}
		
        if { ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_8") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_24") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_40") } {
        	_eprint "Hard EMIF : \[Rule 183\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either 8, 16, 24, 32 or 40."
        	set rbc_validation_pass 0
        }

        if { [get_parameter_value ENUM_CTL_ECC_ENABLED]  == "CTL_ECC_ENABLED"} {
        	if { ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32") } {
        		_eprint "Hard EMIF : \[Rule 184\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either [expr 16 + 8] or [expr 32 + 8] when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox is checked."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_ECC_EN]  == "DISABLE"} {
        	if { ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_32") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_256") } {
        		_eprint "Hard EMIF : \[Rule 185\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_32") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_256") } {
        		_eprint "Hard EMIF : \[Rule 186\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_32") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_256") } {
        		_eprint "Hard EMIF : \[Rule 187\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_32") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_256") } {
        		_eprint "Hard EMIF : \[Rule 188\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_32") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_256") } {
        		_eprint "Hard EMIF : \[Rule 189\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        		set rbc_validation_pass 0
        	}
        	if { ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_32") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_256") } {
        		_eprint "Hard EMIF : \[Rule 190\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        		if { ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 191\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 192\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 193\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 194\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 195\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 196\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        		if { ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_0]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 197\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_1]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 198\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_2]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 199\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_3]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 200\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_4]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 201\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        			set rbc_validation_pass 0
        		}
        		if { ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_64") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_128") && ([get_parameter_value ENUM_RD_DWIDTH_5]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 202\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        			set rbc_validation_pass 0
        		}
        	}

        }

        if { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_USER_ECC_EN]  == "DISABLE"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_32") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 203\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        			set rbc_validation_pass 0
        		}
        	} else {
        		if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_32") } {
        				_eprint "Hard EMIF : \[Rule 204\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        				set rbc_validation_pass 0
        			}
        		} elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_256") } {
        				_eprint "Hard EMIF : \[Rule 205\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        				set rbc_validation_pass 0
        			}
        		}

        	}

        } else {
        	if { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_32"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 206\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32 or 48."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_64"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_64") } {
        			_eprint "Hard EMIF : \[Rule 207\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 64 or 80."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_128"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_128") } {
        			_eprint "Hard EMIF : \[Rule 208\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 128 or 160."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_256"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 209\] has been violated. The Port 0 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 256 or 320."
        			set rbc_validation_pass 0
        		}
        	}

        }

        if { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_USER_ECC_EN]  == "DISABLE"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_32") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 210\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        			set rbc_validation_pass 0
        		}
        	} else {
        		if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_32") } {
        				_eprint "Hard EMIF : \[Rule 211\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        				set rbc_validation_pass 0
        			}
        		} elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_256") } {
        				_eprint "Hard EMIF : \[Rule 212\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        				set rbc_validation_pass 0
        			}
        		}

        	}

        } else {
        	if { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_32"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 213\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32 or 48."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_64"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_64") } {
        			_eprint "Hard EMIF : \[Rule 214\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 64 or 80."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_128"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_128") } {
        			_eprint "Hard EMIF : \[Rule 215\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 128 or 160."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_256"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 216\] has been violated. The Port 1 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 256 or 320."
        			set rbc_validation_pass 0
        		}

        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_USER_ECC_EN]  == "DISABLE"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_32") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 217\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        			set rbc_validation_pass 0
        		}
        	} else {
        		if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_32") } {
        				_eprint "Hard EMIF : \[Rule 218\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        				set rbc_validation_pass 0
        			}
        		} elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_256") } {
        				_eprint "Hard EMIF : \[Rule 219\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        				set rbc_validation_pass 0
        			}
        		}
        	}

        } else {
        	if { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_32"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 220\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32 or 48."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_64"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_64") } {
        			_eprint "Hard EMIF : \[Rule 221\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 64 or 80."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_128"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_128") } {
        			_eprint "Hard EMIF : \[Rule 222\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 128 or 160."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_256"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 223\] has been violated. The Port 2 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 256 or 320."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_USER_ECC_EN]  == "DISABLE"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_32") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 224\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        			set rbc_validation_pass 0
        		}
        	} else {
        		if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_32") } {
        				_eprint "Hard EMIF : \[Rule 225\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        				set rbc_validation_pass 0
        			}
        		} elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_256") } {
        				_eprint "Hard EMIF : \[Rule 226\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        				set rbc_validation_pass 0
        			}
        		}
        	}
        } else {
        	if { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_32"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 227\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32 or 48."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_64"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_64") } {
        			_eprint "Hard EMIF : \[Rule 228\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 64 or 80."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_128"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_128") } {
        			_eprint "Hard EMIF : \[Rule 229\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 128 or 160."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_256"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 230\] has been violated. The Port 3 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 256 or 320."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_USER_ECC_EN]  == "DISABLE"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_32") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 231\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        			set rbc_validation_pass 0
        		}
        	} else {
        		if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_32") } {
        				_eprint "Hard EMIF : \[Rule 232\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        				set rbc_validation_pass 0
        			}
        		} elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_256") } {
        				_eprint "Hard EMIF : \[Rule 233\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        				set rbc_validation_pass 0
        			}
        		}
        	}
        } else {
        	if { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_32"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 234\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32 or 48."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_64"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_64") } {
        			_eprint "Hard EMIF : \[Rule 235\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 64 or 80."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_128"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_128") } {
        			_eprint "Hard EMIF : \[Rule 236\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 128 or 160."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_256"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 237\] has been violated. The Port 4 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 256 or 320."
        			set rbc_validation_pass 0
        		}
        	}

        }

        if { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_USER_ECC_EN]  == "DISABLE"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_32") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 238\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32, 64, 128 or 256 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is unchecked."
        			set rbc_validation_pass 0
        		}
        	} else {
        		if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_32") } {
        				_eprint "Hard EMIF : \[Rule 239\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to 48 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        				set rbc_validation_pass 0
        			}
        		} elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        			if { ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_64") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_128") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_256") } {
        				_eprint "Hard EMIF : \[Rule 240\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 80, 160 or 320 when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked and '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        				set rbc_validation_pass 0
        			}
        		}
        	}
        } else {
        	if { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_32"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_32") } {
        			_eprint "Hard EMIF : \[Rule 241\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 32 or 48."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_64"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_64") } {
        			_eprint "Hard EMIF : \[Rule 242\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 64 or 80."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_128"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_128") } {
        			_eprint "Hard EMIF : \[Rule 243\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 128 or 160."
        			set rbc_validation_pass 0
        		}
        	} elseif { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_256"} {
        		if { ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  != "DWIDTH_256") } {
        			_eprint "Hard EMIF : \[Rule 244\] has been violated. The Port 5 must be disabled or the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' value must be set to either 256 or 320."
        			set rbc_validation_pass 0
        		}
        	}
        }



        if { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 245\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be F0-F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 246\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1 or F2-F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 247\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0, F1, F2 or F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 248\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0, F1, F2 or F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 249\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be None when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Write-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 250\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be F0-F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 251\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1 or F2-F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 252\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0, F1, F2 or F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 253\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0, F1, F2 or F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 254\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be None when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Write-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 255\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be F0-F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 256\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1 or F2-F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 257\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0, F1, F2 or F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 258\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0, F1, F2 or F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 259\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be None when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Write-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 260\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be F0-F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 261\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1 or F2-F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 262\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0, F1, F2 or F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 263\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0, F1, F2 or F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 264\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be None when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Write-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 265\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be F0-F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 266\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1 or F2-F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 267\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0, F1, F2 or F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 268\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0, F1, F2 or F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 269\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be None when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Write-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 270\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be F0-F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 271\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1 or F2-F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 272\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0, F1, F2 or F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 273\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0, F1, F2 or F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Read-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 274\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be None when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Write-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 275\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be F0-F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 276\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1 or F2-F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 277\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0, F1, F2 or F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 278\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0, F1, F2 or F3 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 279\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be None when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Read-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 280\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be F0-F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 281\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1 or F2-F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 282\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0, F1, F2 or F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 283\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0, F1, F2 or F3 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 284\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be None when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Read-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 285\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be F0-F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 286\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1 or F2-F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 287\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0, F1, F2 or F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 288\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0, F1, F2 or F3 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 289\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be None when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Read-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 290\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be F0-F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 291\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1 or F2-F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 292\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0, F1, F2 or F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 293\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0, F1, F2 or F3 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 294\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be None when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Read-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 295\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be F0-F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 296\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1 or F2-F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 297\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0, F1, F2 or F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 298\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0, F1, F2 or F3 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 299\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be None when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Read-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_256"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1_2_3" } {
        		_eprint "Hard EMIF : \[Rule 300\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be F0-F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 256 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_128"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2_3") } {
        		_eprint "Hard EMIF : \[Rule 301\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1 or F2-F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 128 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_64"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 302\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0, F1, F2 or F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 64 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_32"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") } {
        		_eprint "Hard EMIF : \[Rule 303\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0, F1, F2 or F3 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 32 and '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to either Write-only or Bidirectional. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_0"} {
        	if { [get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO" } {
        		_eprint "Hard EMIF : \[Rule 304\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be None when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' set to 0 or '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' set to Read-only. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 305\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None, F0, F1, F2, F3, F0-F1, F2-F3 or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 306\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 307\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None or F0-F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 308\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None or F2-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 309\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None or F0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 310\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None or F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 311\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None or F2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 312\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either None or F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 313\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None, F0, F1, F2, F3, F0-F1, F2-F3 or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 314\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 315\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None or F0-F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 316\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None or F2-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 317\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None or F0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 318\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None or F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 319\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None or F2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 320\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either None or F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 321\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None, F0, F1, F2, F3, F0-F1, F2-F3 or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 322\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 323\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None or F0-F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 324\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None or F2-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 325\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None or F0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 326\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None or F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 327\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None or F2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 328\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either None or F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 329\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None, F0, F1, F2, F3, F0-F1, F2-F3 or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 330\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 331\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None or F0-F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 332\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None or F2-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 333\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None or F0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 334\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None or F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 335\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None or F2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 336\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either None or F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 337\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None, F0, F1, F2, F3, F0-F1, F2-F3 or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 338\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 339\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None or F0-F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 340\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None or F2-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 341\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None or F0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 342\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None or F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 343\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None or F2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 344\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either None or F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 345\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None, F0, F1, F2, F3, F0-F1, F2-F3 or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 346\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None or F0-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 347\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None or F0-F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 348\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None or F2-F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 349\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None or F0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 350\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None or F1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 351\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None or F2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3"} {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 352\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either None or F3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 353\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 354\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 355\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 356\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 357\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 358\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 359\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 360\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 361\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 362\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 363\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 364\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 365\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 366\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 367\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 368\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 369\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 370\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 371\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 372\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 373\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 374\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 375\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 376\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 377\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 378\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 379\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 380\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 381\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 382\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 383\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 384\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 385\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 386\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 387\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 388\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 389\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 390\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 391\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 392\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 393\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 394\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 395\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 396\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 397\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 398\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 399\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_RD_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 400\] has been violated. The '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 401\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 402\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 403\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 404\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 405\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 406\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 407\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_0]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 408\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 409\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 410\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 411\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 412\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 413\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 414\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 415\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_1]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 416\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 417\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 418\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 419\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 420\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 421\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 422\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 423\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_2]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 424\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 425\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 426\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 427\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 428\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 429\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 430\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 431\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_3]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 432\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 433\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 434\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 435\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 436\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 437\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 438\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 439\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_4]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 440\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 441\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 442\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F2-F3, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0-F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 443\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F0, F1 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2-F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 444\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F2-F3, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 445\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F2-F3, F0, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F1. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 446\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F0, F1, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F2. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 447\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F0, F1, F2 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to F3. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }
        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO") ||
        	([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO") } {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_0") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_1") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_2") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_3") && ([get_parameter_value ENUM_WR_PORT_INFO_5]  != "USE_NO") } {
        		_eprint "Hard EMIF : \[Rule 448\] has been violated. The '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 must be either F0-F1, F2-F3, F0, F1, F2, F3 or None when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for other port set to None. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1")||([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0"))) } {
        	if { [get_parameter_value ENUM_RD_FIFO_IN_USE_0]  != "TRUE" } {
        		_eprint "Hard EMIF : \[Rule 449\] has been violated. The in-use status for Read-Data FIFO 0 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_RD_FIFO_IN_USE_0]  != "FALSE" } {
        		_eprint "Hard EMIF : \[Rule 450\] has been violated. The in-use status for Read-Data FIFO 0 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1")) ||
        	(([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1"))) } {
        	if { [get_parameter_value ENUM_RD_FIFO_IN_USE_1]  != "TRUE" } {
        		_eprint "Hard EMIF : \[Rule 451\] has been violated. The in-use status for Read-Data FIFO 1 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
        		set rbc_validation_pass 0
        	}
        } else {
                if { [get_parameter_value ENUM_RD_FIFO_IN_USE_1]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 452\] has been violated. The in-use status for Read-Data FIFO 1 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3" ) || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3" ) || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2"))) } {
                if { [get_parameter_value ENUM_RD_FIFO_IN_USE_2]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 453\] has been violated. The in-use status for Read-Data FIFO 2 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_RD_FIFO_IN_USE_2]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 454\] has been violated. The in-use status for Read-Data FIFO 2 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ((([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3")) ||
                (([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3"))) } {
                if { [get_parameter_value ENUM_RD_FIFO_IN_USE_3]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 455\] has been violated. The in-use status for Read-Data FIFO 3 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_RD_FIFO_IN_USE_3]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 456\] has been violated. The in-use status for Read-Data FIFO 3 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0"))) } {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_0]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 457\] has been violated. The in-use status for Write-Data FIFO 0 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_0]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 458\] has been violated. The in-use status for Write-Data FIFO 0 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1"))) } {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_1]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 459\] has been violated. The in-use status for Write-Data FIFO 1 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_1]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 460\] has been violated. The in-use status for Write-Data FIFO 1 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2"))) } {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_2]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 461\] has been violated. The in-use status for Write-Data FIFO 2 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_2]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 462\] has been violated. The in-use status for Write-Data FIFO 2 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ((([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3")) ||
                (([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3"))) } {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_3]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 463\] has been violated. The in-use status for Write-Data FIFO 3 must be true when it being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_WR_FIFO_IN_USE_3]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 464\] has been violated. The in-use status for Write-Data FIFO 3 must be false when it not being allocated to any port. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_0")} {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_0]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 465\] has been violated. The in-use status for Port 0 must be set to false when the Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_0]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 466\] has been violated. The in-use status for Port 0 must be set to true when the Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32, 64, 128 or 256. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_0")} {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_1]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 467\] has been violated. The in-use status for Port 1 must be set to false when the Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_1]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 468\] has been violated. The in-use status for Port 1 must be set to true when the Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32, 64, 128 or 256. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_0")} {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_2]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 469\] has been violated. The in-use status for Port 2 must be set to false when the Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_2]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 470\] has been violated. The in-use status for Port 2 must be set to true when the Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32, 64, 128 or 256. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_0")} {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_3]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 471\] has been violated. The in-use status for Port 3 must be set to false when the Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_3]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 472\] has been violated. The in-use status for Port 3 must be set to true when the Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32, 64, 128 or 256. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_0")} {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_4]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 473\] has been violated. The in-use status for Port 4 must be set to false when the Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_4]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 474\] has been violated. The in-use status for Port 4 must be set to true when the Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32, 64, 128 or 256. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_0") && ([get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_0")} {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_5]  != "FALSE" } {
                	_eprint "Hard EMIF : \[Rule 475\] has been violated. The in-use status for Port 5 must be set to false when the Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 0. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_CMD_PORT_IN_USE_5]  != "TRUE" } {
                	_eprint "Hard EMIF : \[Rule 476\] has been violated. The in-use status for Port 5 must be set to true when the Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32, 64, 128 or 256. Please reduce the '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]', change the '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' or disable one of the active port to fix this issue."
                	set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_0]  == "TRUE"} {
                if { ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_1") && ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_2") && ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_3") && ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_4") && ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_5") && ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_6") && ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_7") } {
        		_eprint "Hard EMIF : \[Rule 477\] has been violated. The Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6 or 7 when Port 0 being enabled."
        		set rbc_validation_pass 0
        	}
        } else {
                if { ([get_parameter_value ENUM_USER_PRIORITY_0]  != "PRIORITY_1") } {
        		_eprint "Hard EMIF : \[Rule 478\] has been violated. The Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to 1 when Port 0 being disabled."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_1]  == "TRUE"} {
                if { ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_1") && ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_2") && ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_3") && ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_4") && ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_5") && ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_6") && ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_7") } {
        		_eprint "Hard EMIF : \[Rule 479\] has been violated. The Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6 or 7 when Port 1 being enabled."
        		set rbc_validation_pass 0
        	}
        } else { 
                if { ([get_parameter_value ENUM_USER_PRIORITY_1]  != "PRIORITY_1") } {
        		_eprint "Hard EMIF : \[Rule 480\] has been violated. The Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to 1 when Port 1 being disabled."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_2]  == "TRUE"} {
                if { ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_1") && ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_2") && ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_3") && ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_4") && ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_5") && ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_6") && ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_7") } {
                        _eprint "Hard EMIF : \[Rule 481\] has been violated. The Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6 or 7 when Port 2 being enabled."
                        set rbc_validation_pass 0
        	}
        } else {
                if { ([get_parameter_value ENUM_USER_PRIORITY_2]  != "PRIORITY_1") } {
        		_eprint "Hard EMIF : \[Rule 482\] has been violated. The Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to 1 when Port 2 being disabled."
        		set rbc_validation_pass 0
        	}
        }
 
        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_3]  == "TRUE"} {
                if { ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_1") && ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_2") && ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_3") && ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_4") && ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_5") && ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_6") && ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_7") } {
        		_eprint "Hard EMIF : \[Rule 483\] has been violated. The Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6 or 7 when Port 3 being enabled."
        		set rbc_validation_pass 0
        	}
        } else {
                if { ([get_parameter_value ENUM_USER_PRIORITY_3]  != "PRIORITY_1") } {
        		_eprint "Hard EMIF : \[Rule 484\] has been violated. The Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to 1 when Port 3 being disabled."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_4]  == "TRUE"} {
                if { ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_1") && ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_2") && ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_3") && ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_4") && ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_5") && ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_6") && ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_7") } {
                        _eprint "Hard EMIF : \[Rule 485\] has been violated. The Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6 or 7 when Port 4 being enabled."
                        set rbc_validation_pass 0
        	}
        } else {
                if { ([get_parameter_value ENUM_USER_PRIORITY_4]  != "PRIORITY_1") } {
        		_eprint "Hard EMIF : \[Rule 486\] has been violated. The Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to 1 when Port 4 being disabled."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_5]  == "TRUE"} {
                if { ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_1") && ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_2") && ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_3") && ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_4") && ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_5") && ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_6") && ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_7") } {
                        _eprint "Hard EMIF : \[Rule 487\] has been violated. The Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to either 1, 2, 3, 4, 5, 6 or 7 when Port 5 being enabled."
                        set rbc_validation_pass 0
        	}
        } else {
                if { ([get_parameter_value ENUM_USER_PRIORITY_5]  != "PRIORITY_1") } {
        		_eprint "Hard EMIF : \[Rule 488\] has been violated. The Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' value must be set to 1 when Port 5 being disabled."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_0]  == "FALSE"} {
                if { [get_parameter_value ENUM_STATIC_WEIGHT_0]  != "WEIGHT_0" } {
                        _eprint "Hard EMIF : \[Rule 489\] has been violated. The Port 0 '[get_parameter_property WEIGHT_PORT DISPLAY_NAME]' value must be set to 0 when Port 0 being disabled."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_1]  == "FALSE"} {
                if { [get_parameter_value ENUM_STATIC_WEIGHT_1]  != "WEIGHT_0" } {
                        _eprint "Hard EMIF : \[Rule 490\] has been violated. The Port 1 '[get_parameter_property WEIGHT_PORT DISPLAY_NAME]' value must be set to 0 when Port 1 being disabled."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_2]  == "FALSE"} {
                if { [get_parameter_value ENUM_STATIC_WEIGHT_2]  != "WEIGHT_0" } {
                        _eprint "Hard EMIF : \[Rule 491\] has been violated. The Port 2 '[get_parameter_property WEIGHT_PORT DISPLAY_NAME]' value must be set to 0 when Port 2 being disabled."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_3]  == "FALSE"} {
                if { [get_parameter_value ENUM_STATIC_WEIGHT_3]  != "WEIGHT_0" } {
                        _eprint "Hard EMIF : \[Rule 492\] has been violated. The Port 3 '[get_parameter_property WEIGHT_PORT DISPLAY_NAME]' value must be set to 0 when Port 3 being disabled."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_4]  == "FALSE"} {
                if { [get_parameter_value ENUM_STATIC_WEIGHT_4]  != "WEIGHT_0" } {
                        _eprint "Hard EMIF : \[Rule 493\] has been violated. The Port 4 '[get_parameter_property WEIGHT_PORT DISPLAY_NAME]' value must be set to 0 when Port 4 being disabled."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_5]  == "FALSE"} {
                if { [get_parameter_value ENUM_STATIC_WEIGHT_5]  != "WEIGHT_0" } {
                        _eprint "Hard EMIF : \[Rule 494\] has been violated. The Port 5 '[get_parameter_property WEIGHT_PORT DISPLAY_NAME]' value must be set to 0 when Port 5 being disabled."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_0"} {
                if { [get_parameter_value ENUM_PRIORITY_0_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
                	_eprint "Hard EMIF : \[Rule 495\] has been violated. The internal 2D Priority 0 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 0."
                	set rbc_validation_pass 0
                }
        } else {
                if { [get_parameter_value ENUM_PRIORITY_0_0]  != "WEIGHT_0" } {
                	_eprint "Hard EMIF : \[Rule 496\] has been violated. The internal 2D Priority 0 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 0."
                	set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_0"} {
        	if { [get_parameter_value ENUM_PRIORITY_0_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 497\] has been violated. The internal 2D Priority 0 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 0."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_0_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 498\] has been violated. The internal 2D Priority 0 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 0."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_0"} {
        	if { [get_parameter_value ENUM_PRIORITY_0_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 499\] has been violated. The internal 2D Priority 0 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 0."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_0_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 500\] has been violated. The internal 2D Priority 0 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 0."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_0"} {
        	if { [get_parameter_value ENUM_PRIORITY_0_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 501\] has been violated. The internal 2D Priority 0 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 0."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_0_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 502\] has been violated. The internal 2D Priority 0 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 0."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_0"} {
        	if { [get_parameter_value ENUM_PRIORITY_0_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 503\] has been violated. The internal 2D Priority 0 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 0."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_0_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 504\] has been violated. The internal 2D Priority 0 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 0."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_0"} {
        	if { [get_parameter_value ENUM_PRIORITY_0_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 505\] has been violated. The internal 2D Priority 0 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 0."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_0_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 506\] has been violated. The internal 2D Priority 0 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 0."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_1"} {
        	if { [get_parameter_value ENUM_PRIORITY_1_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        		_eprint "Hard EMIF : \[Rule 507\] has been violated. The internal 2D Priority 1 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 1."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_1_0]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 508\] has been violated. The internal 2D Priority 1 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 1."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_1"} {
        	if { [get_parameter_value ENUM_PRIORITY_1_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 509\] has been violated. The internal 2D Priority 1 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 1."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_1_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 510\] has been violated. The internal 2D Priority 1 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 1."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_1"} {
        	if { [get_parameter_value ENUM_PRIORITY_1_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 511\] has been violated. The internal 2D Priority 1 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 1."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_1_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 512\] has been violated. The internal 2D Priority 1 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 1."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_1"} {
        	if { [get_parameter_value ENUM_PRIORITY_1_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 513\] has been violated. The internal 2D Priority 1 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 1."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_1_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 514\] has been violated. The internal 2D Priority 1 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 1."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_1"} {
        	if { [get_parameter_value ENUM_PRIORITY_1_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 515\] has been violated. The internal 2D Priority 1 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 1."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_1_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 516\] has been violated. The internal 2D Priority 1 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 1."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_1"} {
        	if { [get_parameter_value ENUM_PRIORITY_1_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 517\] has been violated. The internal 2D Priority 1 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 1."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_1_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 518\] has been violated. The internal 2D Priority 1 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 1."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_2"} {
        	if { [get_parameter_value ENUM_PRIORITY_2_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        		_eprint "Hard EMIF : \[Rule 519\] has been violated. The internal 2D Priority 2 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_2_0]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 520\] has been violated. The internal 2D Priority 2 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_2"} {
        	if { [get_parameter_value ENUM_PRIORITY_2_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 521\] has been violated. The internal 2D Priority 2 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_2_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 522\] has been violated. The internal 2D Priority 2 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_2"} {
        	if { [get_parameter_value ENUM_PRIORITY_2_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 523\] has been violated. The internal 2D Priority 2 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_2_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 524\] has been violated. The internal 2D Priority 2 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_2"} {
        	if { [get_parameter_value ENUM_PRIORITY_2_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 525\] has been violated. The internal 2D Priority 2 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_2_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 526\] has been violated. The internal 2D Priority 2 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_2"} {
        	if { [get_parameter_value ENUM_PRIORITY_2_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 527\] has been violated. The internal 2D Priority 2 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_2_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 528\] has been violated. The internal 2D Priority 2 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_2"} {
        	if { [get_parameter_value ENUM_PRIORITY_2_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 529\] has been violated. The internal 2D Priority 2 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_2_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 530\] has been violated. The internal 2D Priority 2 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 2."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_3"} {
        	if { [get_parameter_value ENUM_PRIORITY_3_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        		_eprint "Hard EMIF : \[Rule 531\] has been violated. The internal 2D Priority 3 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 3."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_3_0]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 532\] has been violated. The internal 2D Priority 3 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_3"} {
        	if { [get_parameter_value ENUM_PRIORITY_3_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 533\] has been violated. The internal 2D Priority 3 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 3."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_3_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 534\] has been violated. The internal 2D Priority 3 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_3"} {
        	if { [get_parameter_value ENUM_PRIORITY_3_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 535\] has been violated. The internal 2D Priority 3 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 3."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_3_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 536\] has been violated. The internal 2D Priority 3 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_3"} {
        	if { [get_parameter_value ENUM_PRIORITY_3_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 537\] has been violated. The internal 2D Priority 3 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 3."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_3_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 538\] has been violated. The internal 2D Priority 3 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_3"} {
        	if { [get_parameter_value ENUM_PRIORITY_3_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 539\] has been violated. The internal 2D Priority 3 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 3."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_3_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 540\] has been violated. The internal 2D Priority 3 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_3"} {
        	if { [get_parameter_value ENUM_PRIORITY_3_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 541\] has been violated. The internal 2D Priority 3 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 3."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_3_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 542\] has been violated. The internal 2D Priority 3 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_4"} {
        	if { [get_parameter_value ENUM_PRIORITY_4_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        		_eprint "Hard EMIF : \[Rule 543\] has been violated. The internal 2D Priority 4 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_4_0]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 544\] has been violated. The internal 2D Priority 4 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 4."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_4"} {
        	if { [get_parameter_value ENUM_PRIORITY_4_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 545\] has been violated. The internal 2D Priority 4 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_4_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 546\] has been violated. The internal 2D Priority 4 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 4."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_4"} {
        	if { [get_parameter_value ENUM_PRIORITY_4_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 547\] has been violated. The internal 2D Priority 4 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_4_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 548\] has been violated. The internal 2D Priority 4 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 4."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_4"} {
        	if { [get_parameter_value ENUM_PRIORITY_4_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 549\] has been violated. The internal 2D Priority 4 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_4_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 550\] has been violated. The internal 2D Priority 4 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 4."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_4"} {
        	if { [get_parameter_value ENUM_PRIORITY_4_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 551\] has been violated. The internal 2D Priority 4 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_4_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 552\] has been violated. The internal 2D Priority 4 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 4."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_4"} {
        	if { [get_parameter_value ENUM_PRIORITY_4_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 553\] has been violated. The internal 2D Priority 4 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_4_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 554\] has been violated. The internal 2D Priority 4 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 4."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_5"} {
        	if { [get_parameter_value ENUM_PRIORITY_5_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        		_eprint "Hard EMIF : \[Rule 555\] has been violated. The internal 2D Priority 5 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 5."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_5_0]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 556\] has been violated. The internal 2D Priority 5 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 5."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_5"} {
        	if { [get_parameter_value ENUM_PRIORITY_5_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 557\] has been violated. The internal 2D Priority 5 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 5."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_5_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 558\] has been violated. The internal 2D Priority 5 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 5."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_5"} {
        	if { [get_parameter_value ENUM_PRIORITY_5_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 559\] has been violated. The internal 2D Priority 5 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 5."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_5_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 560\] has been violated. The internal 2D Priority 5 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 5."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_5"} {
        	if { [get_parameter_value ENUM_PRIORITY_5_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 561\] has been violated. The internal 2D Priority 5 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 5."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_5_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 562\] has been violated. The internal 2D Priority 5 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 5."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_5"} {
        	if { [get_parameter_value ENUM_PRIORITY_5_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 563\] has been violated. The internal 2D Priority 5 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 5."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_5_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 564\] has been violated. The internal 2D Priority 5 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 5."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_5"} {
        	if { [get_parameter_value ENUM_PRIORITY_5_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 565\] has been violated. The internal 2D Priority 5 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 5."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_5_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 566\] has been violated. The internal 2D Priority 5 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 5."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_6"} {
        	if { [get_parameter_value ENUM_PRIORITY_6_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        		_eprint "Hard EMIF : \[Rule 567\] has been violated. The internal 2D Priority 6 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 6."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_6_0]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 568\] has been violated. The internal 2D Priority 6 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 6."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_6"} {
        	if { [get_parameter_value ENUM_PRIORITY_6_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 569\] has been violated. The internal 2D Priority 6 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 6."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_6_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 570\] has been violated. The internal 2D Priority 6 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 6."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_6"} {
        	if { [get_parameter_value ENUM_PRIORITY_6_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 571\] has been violated. The internal 2D Priority 6 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 6."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_6_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 572\] has been violated. The internal 2D Priority 6 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 6."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_6"} {
        	if { [get_parameter_value ENUM_PRIORITY_6_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 573\] has been violated. The internal 2D Priority 6 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 6."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_6_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 574\] has been violated. The internal 2D Priority 6 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 6."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_6"} {
        	if { [get_parameter_value ENUM_PRIORITY_6_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 575\] has been violated. The internal 2D Priority 6 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 6."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_6_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 576\] has been violated. The internal 2D Priority 6 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 6."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_6"} {
        	if { [get_parameter_value ENUM_PRIORITY_6_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 577\] has been violated. The internal 2D Priority 6 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 6."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_6_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 578\] has been violated. The internal 2D Priority 6 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 6."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_0]  == "PRIORITY_7"} {
        	if { [get_parameter_value ENUM_PRIORITY_7_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        		_eprint "Hard EMIF : \[Rule 579\] has been violated. The internal 2D Priority 7 Port 0 must be [get_parameter_value ENUM_STATIC_WEIGHT_0] when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 7."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_7_0]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 580\] has been violated. The internal 2D Priority 7 Port 0 must be 0 when Port 0 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 7."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_1]  == "PRIORITY_7"} {
        	if { [get_parameter_value ENUM_PRIORITY_7_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        		_eprint "Hard EMIF : \[Rule 581\] has been violated. The internal 2D Priority 7 Port 1 must be [get_parameter_value ENUM_STATIC_WEIGHT_1] when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 7."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_7_1]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 582\] has been violated. The internal 2D Priority 7 Port 1 must be 0 when Port 1 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 7."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_2]  == "PRIORITY_7"} {
        	if { [get_parameter_value ENUM_PRIORITY_7_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        		_eprint "Hard EMIF : \[Rule 583\] has been violated. The internal 2D Priority 7 Port 2 must be [get_parameter_value ENUM_STATIC_WEIGHT_2] when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 7."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_7_2]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 584\] has been violated. The internal 2D Priority 7 Port 2 must be 0 when Port 2 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 7."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_3]  == "PRIORITY_7"} {
        	if { [get_parameter_value ENUM_PRIORITY_7_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        		_eprint "Hard EMIF : \[Rule 585\] has been violated. The internal 2D Priority 7 Port 3 must be [get_parameter_value ENUM_STATIC_WEIGHT_3] when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 7."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_7_3]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 586\] has been violated. The internal 2D Priority 7 Port 3 must be 0 when Port 3 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 7."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_4]  == "PRIORITY_7"} {
        	if { [get_parameter_value ENUM_PRIORITY_7_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        		_eprint "Hard EMIF : \[Rule 587\] has been violated. The internal 2D Priority 7 Port 4 must be [get_parameter_value ENUM_STATIC_WEIGHT_4] when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 7."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_7_4]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 588\] has been violated. The internal 2D Priority 7 Port 4 must be 0 when Port 4 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 7."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_PRIORITY_5]  == "PRIORITY_7"} {
        	if { [get_parameter_value ENUM_PRIORITY_7_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        		_eprint "Hard EMIF : \[Rule 589\] has been violated. The internal 2D Priority 7 Port 5 must be [get_parameter_value ENUM_STATIC_WEIGHT_5] when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to 7."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PRIORITY_7_5]  != "WEIGHT_0" } {
        		_eprint "Hard EMIF : \[Rule 590\] has been violated. The internal 2D Priority 7 Port 5 must be 0 when Port 5 '[get_parameter_property PRIORITY_PORT DISPLAY_NAME]' is set to other than 7."
        		set rbc_validation_pass 0
        	}
        }


        if { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_2"} {
        	if { [get_parameter_value ENUM_MMR_CFG_MEM_BL]  != "MP_BL_2" } {
        		_eprint "Hard EMIF : \[Rule 591\] has been violated. The internal burst length must be set to 2 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_4"} {
        	if { [get_parameter_value ENUM_MMR_CFG_MEM_BL]  != "MP_BL_4" } {
        		_eprint "Hard EMIF : \[Rule 592\] has been violated. The internal burst length must be set to 4 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 4."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_8"} {
        	if { [get_parameter_value ENUM_MMR_CFG_MEM_BL]  != "MP_BL_8" } {
        		_eprint "Hard EMIF : \[Rule 593\] has been violated. The internal burst length must be set to 8 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 8."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_BURSTLENGTH]  == "MEM_IF_BURSTLENGTH_16"} {
        	if { [get_parameter_value ENUM_MMR_CFG_MEM_BL]  != "MP_BL_16" } {
        		_eprint "Hard EMIF : \[Rule 594\] has been violated. The internal burst length must be set to 16 when '[get_parameter_property MEM_BL DISPLAY_NAME]' is set to 16."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_8"} {
        	if { [get_parameter_value ENUM_CTRL_WIDTH]  != "DATA_WIDTH_16_BIT" } {
        		_eprint "Hard EMIF : \[Rule 595\] has been violated. The internal Single-port local data width must be set to 16 when '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 8."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_16"} {
        	if { [get_parameter_value ENUM_CTRL_WIDTH]  != "DATA_WIDTH_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 596\] has been violated. The internal Single-port local data width must be set to 32 when '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 16."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_24"} {
        	if { [get_parameter_value ENUM_CTRL_WIDTH]  != "DATA_WIDTH_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 597\] has been violated. The internal Single-port local data width must be set to 32 when '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 24."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_32"} {
        	if { [get_parameter_value ENUM_CTRL_WIDTH]  != "DATA_WIDTH_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 598\] has been violated. The internal Single-port local data width must be set to 64 when '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 32."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_MEM_IF_DWIDTH]  == "MEM_IF_DWIDTH_40"} {
        	if { [get_parameter_value ENUM_CTRL_WIDTH]  != "DATA_WIDTH_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 599\] has been violated. The internal Single-port local data width must be set to 64 when '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' is set to 40."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_64") } {
        	if { [get_parameter_value ENUM_PORT0_WIDTH]   != "PORT_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 600\] has been violated. The internal Port 0 local data width must be set to 64 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 64."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_128") } {
        	if { [get_parameter_value ENUM_PORT0_WIDTH]   != "PORT_128_BIT" } {
        		_eprint "Hard EMIF : \[Rule 601\] has been violated. The internal Port 0 local data width must be set to 128 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 128."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_0]  == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_0]  == "DWIDTH_256") } {
        	if { [get_parameter_value ENUM_PORT0_WIDTH]   != "PORT_256_BIT" } {
        		_eprint "Hard EMIF : \[Rule 602\] has been violated. The internal Port 0 local data width must be set to 256 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 256."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PORT0_WIDTH]   != "PORT_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 603\] has been violated. The internal Port 0 local data width must be set to 32 when Port 0 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_64") } {
        	if { [get_parameter_value ENUM_PORT1_WIDTH]   != "PORT_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 604\] has been violated. The internal Port 1 local data width must be set to 64 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 64."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_128") } {
        	if { [get_parameter_value ENUM_PORT1_WIDTH]   != "PORT_128_BIT" } {
        		_eprint "Hard EMIF : \[Rule 605\] has been violated. The internal Port 1 local data width must be set to 128 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 128."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_1]  == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_1]  == "DWIDTH_256") } {
        	if { [get_parameter_value ENUM_PORT1_WIDTH]   != "PORT_256_BIT" } {
        		_eprint "Hard EMIF : \[Rule 606\] has been violated. The internal Port 1 local data width must be set to 256 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 256."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PORT1_WIDTH]   != "PORT_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 607\] has been violated. The internal Port 1 local data width must be set to 32 when Port 1 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_64") } {
        	if { [get_parameter_value ENUM_PORT2_WIDTH]   != "PORT_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 608\] has been violated. The internal Port 2 local data width must be set to 64 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 64."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_128") } {
        	if { [get_parameter_value ENUM_PORT2_WIDTH]   != "PORT_128_BIT" } {
        		_eprint "Hard EMIF : \[Rule 609\] has been violated. The internal Port 2 local data width must be set to 128 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 128."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_2]  == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_2]  == "DWIDTH_256") } {
        	if { [get_parameter_value ENUM_PORT2_WIDTH]   != "PORT_256_BIT" } {
        		_eprint "Hard EMIF : \[Rule 610\] has been violated. The internal Port 2 local data width must be set to 256 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 256."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PORT2_WIDTH]   != "PORT_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 611\] has been violated. The internal Port 2 local data width must be set to 32 when Port 2 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_64") } {
        	if { [get_parameter_value ENUM_PORT3_WIDTH]   != "PORT_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 612\] has been violated. The internal Port 3 local data width must be set to 64 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 64."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_128") } {
        	if { [get_parameter_value ENUM_PORT3_WIDTH]   != "PORT_128_BIT" } {
        		_eprint "Hard EMIF : \[Rule 613\] has been violated. The internal Port 3 local data width must be set to 128 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 128."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_3]  == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_3]  == "DWIDTH_256") } {
        	if { [get_parameter_value ENUM_PORT3_WIDTH]   != "PORT_256_BIT" } {
        		_eprint "Hard EMIF : \[Rule 614\] has been violated. The internal Port 3 local data width must be set to 256 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 256."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PORT3_WIDTH]   != "PORT_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 615\] has been violated. The internal Port 3 local data width must be set to 32 when Port 3 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_64") } {
        	if { [get_parameter_value ENUM_PORT4_WIDTH]   != "PORT_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 616\] has been violated. The internal Port 4 local data width must be set to 64 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 64."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_128") } {
        	if { [get_parameter_value ENUM_PORT4_WIDTH]   != "PORT_128_BIT" } {
        		_eprint "Hard EMIF : \[Rule 617\] has been violated. The internal Port 4 local data width must be set to 128 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 128."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_4]  == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_4]  == "DWIDTH_256") } {
        	if { [get_parameter_value ENUM_PORT4_WIDTH]   != "PORT_256_BIT" } {
        		_eprint "Hard EMIF : \[Rule 618\] has been violated. The internal Port 4 local data width must be set to 256 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 256."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PORT4_WIDTH]   != "PORT_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 619\] has been violated. The internal Port 4 local data width must be set to 32 when Port 4 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_64") || ([get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_64") } {
        	if { [get_parameter_value ENUM_PORT5_WIDTH]   != "PORT_64_BIT" } {
        		_eprint "Hard EMIF : \[Rule 620\] has been violated. The internal Port 5 local data width must be set to 64 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 64."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_128") || ([get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_128") } {
        	if { [get_parameter_value ENUM_PORT5_WIDTH]   != "PORT_128_BIT" } {
        		_eprint "Hard EMIF : \[Rule 621\] has been violated. The internal Port 5 local data width must be set to 128 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 128."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_DWIDTH_5]  == "DWIDTH_256") || ([get_parameter_value ENUM_WR_DWIDTH_5]  == "DWIDTH_256") } {
        	if { [get_parameter_value ENUM_PORT5_WIDTH]   != "PORT_256_BIT" } {
        		_eprint "Hard EMIF : \[Rule 622\] has been violated. The internal Port 5 local data width must be set to 256 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 256."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { [get_parameter_value ENUM_PORT5_WIDTH]   != "PORT_32_BIT" } {
        		_eprint "Hard EMIF : \[Rule 623\] has been violated. The internal Port 5 local data width must be set to 32 when Port 5 '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' is set to 32."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_USER_ECC_EN]  == "ENABLE"} {
                if { [get_parameter_value ENUM_CTL_ECC_ENABLED]  != "CTL_ECC_DISABLED" } {
                        _eprint "Hard EMIF : \[Rule 624\] has been violated. The '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' checkbox must be unchecked when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' is checked."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_CTL_ECC_ENABLED]  == "CTL_ECC_ENABLED"} {
                if { [get_parameter_value ENUM_USER_ECC_EN]  != "DISABLE" } {
                        _eprint "Hard EMIF : \[Rule 625\] has been violated. The '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox must be unchecked when '[get_parameter_property CTL_ECC_ENABLED DISPLAY_NAME]' is checked."
                        set rbc_validation_pass 0
                }
        } else {
                if { ([get_parameter_value ENUM_USER_ECC_EN]  != "DISABLE") && ([get_parameter_value ENUM_USER_ECC_EN]  != "ENABLE") } {
                        _eprint "Hard EMIF : \[Rule 626\] has been violated. The '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox must be either checked or unchecked."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_USER_ECC_EN]  == "ENABLE"} {
                if { ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_24") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_40") } {
                        _eprint "Hard EMIF : \[Rule 627\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either 24 (for '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' of 48) or 40 (for '[get_parameter_property AVL_DATA_WIDTH_PORT DISPLAY_NAME]' of 80, 160 and 320) when '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkbox is checked."
                        set rbc_validation_pass 0
                }
        } else {
                if { ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_8") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_16") && ([get_parameter_value ENUM_MEM_IF_DWIDTH]  != "MEM_IF_DWIDTH_32") } {
                        _eprint "Hard EMIF : \[Rule 628\] has been violated. The '[get_parameter_property MEM_DQ_WIDTH DISPLAY_NAME]' value must be set to either 8, 16 or 32 when both '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' and '[get_parameter_property ENABLE_USER_ECC DISPLAY_NAME]' checkboxes is unchecked."
                        set rbc_validation_pass 0
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT0_TYPE]  != "DISABLE" } {
                        	_eprint "Hard EMIF : \[Rule 629\] has been violated. The Port 0 must be disabled when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT0_TYPE]  != "WRITE" } {
                        	_eprint "Hard EMIF : \[Rule 630\] has been violated. The Port 0 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Write-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to None and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to others."
                        	set rbc_validation_pass 0
                        }
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT0_TYPE]  != "READ" } {
                        	_eprint "Hard EMIF : \[Rule 631\] has been violated. The Port 0 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Read-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to others and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT0_TYPE]  != "BI_DIRECTION" } {
                        	_eprint "Hard EMIF : \[Rule 632\] has been violated. The Port 0 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Bidirectional when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to other than None."
                        	set rbc_validation_pass 0
                        }
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT1_TYPE]  != "DISABLE" } {
                        	_eprint "Hard EMIF : \[Rule 633\] has been violated. The Port 1 must be disabled when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT1_TYPE]  != "WRITE" } {
                        	_eprint "Hard EMIF : \[Rule 634\] has been violated. The Port 1 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Write-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to None and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to others."
                        	set rbc_validation_pass 0
                        }
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT1_TYPE]  != "READ" } {
                        	_eprint "Hard EMIF : \[Rule 635\] has been violated. The Port 1 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Read-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to others and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT1_TYPE]  != "BI_DIRECTION" } {
                        	_eprint "Hard EMIF : \[Rule 636\] has been violated. The Port 1 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Bidirectional when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to other than None."
                        	set rbc_validation_pass 0
                        }
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT2_TYPE]  != "DISABLE" } {
                        	_eprint "Hard EMIF : \[Rule 637\] has been violated. The Port 2 must be disabled when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT2_TYPE]  != "WRITE" } {
                        	_eprint "Hard EMIF : \[Rule 638\] has been violated. The Port 2 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Write-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to None and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to others."
                        	set rbc_validation_pass 0
                        }
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT2_TYPE]  != "READ" } {
                        	_eprint "Hard EMIF : \[Rule 639\] has been violated. The Port 2 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Read-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to others and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT2_TYPE]  != "BI_DIRECTION" } {
                        	_eprint "Hard EMIF : \[Rule 640\] has been violated. The Port 2 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Bidirectional when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to other than None."
                        	set rbc_validation_pass 0
                        }
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT3_TYPE]  != "DISABLE" } {
                        	_eprint "Hard EMIF : \[Rule 641\] has been violated. The Port 3 must be disabled when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT3_TYPE]  != "WRITE" } {
                        	_eprint "Hard EMIF : \[Rule 642\] has been violated. The Port 3 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Write-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to None and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to others."
                        	set rbc_validation_pass 0
                        }
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT3_TYPE]  != "READ" } {
                        	_eprint "Hard EMIF : \[Rule 643\] has been violated. The Port 3 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Read-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to others and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT3_TYPE]  != "BI_DIRECTION" } {
                        	_eprint "Hard EMIF : \[Rule 644\] has been violated. The Port 3 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Bidirectional when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to other than None."
                        	set rbc_validation_pass 0
                        }
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT4_TYPE]  != "DISABLE" } {
                        	_eprint "Hard EMIF : \[Rule 645\] has been violated. The Port 4 must be disabled when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT4_TYPE]  != "WRITE" } {
                        	_eprint "Hard EMIF : \[Rule 646\] has been violated. The Port 4 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Write-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to None and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to others."
                        	set rbc_validation_pass 0
                        }
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT4_TYPE]  != "READ" } {
                        	_eprint "Hard EMIF : \[Rule 647\] has been violated. The Port 4 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Read-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to others and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT4_TYPE]  != "BI_DIRECTION" } {
                        	_eprint "Hard EMIF : \[Rule 648\] has been violated. The Port 4 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Bidirectional when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to other than None."
                        	set rbc_validation_pass 0
                        }
                }
        }

        if { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO"} {
                if { [get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT5_TYPE]  != "DISABLE" } {
                        	_eprint "Hard EMIF : \[Rule 649\] has been violated. The Port 5 must be disabled when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT5_TYPE]  != "WRITE" } {
                        	_eprint "Hard EMIF : \[Rule 650\] has been violated. The Port 5 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Write-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to None and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to others."
                        	set rbc_validation_pass 0
                        }
                }
        } else {
                if { [get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO"} {
                        if { [get_parameter_value ENUM_CPORT5_TYPE]  != "READ" } {
                        	_eprint "Hard EMIF : \[Rule 651\] has been violated. The Port 5 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Read-only when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' is set to others and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to None."
                        	set rbc_validation_pass 0
                        }
                } else {
                        if { [get_parameter_value ENUM_CPORT5_TYPE]  != "BI_DIRECTION" } {
                        	_eprint "Hard EMIF : \[Rule 652\] has been violated. The Port 5 '[get_parameter_property CPORT_TYPE_PORT DISPLAY_NAME]' value must be set to Bidirectional when both the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' and the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' is set to other than None."
                        	set rbc_validation_pass 0
                        }
                }
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT0_WFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 653\] has been violated. The internal associated Write-Data FIFO for Port 0 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT0_WFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 654\] has been violated. The internal associated Write-Data FIFO for Port 0 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT0_WFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 655\] has been violated. The internal associated Write-Data FIFO for Port 0 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT0_WFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 656\] has been violated. The internal associated Write-Data FIFO for Port 0 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT1_WFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 657\] has been violated. The internal associated Write-Data FIFO for Port 1 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT1_WFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 658\] has been violated. The internal associated Write-Data FIFO for Port 1 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT1_WFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 659\] has been violated. The internal associated Write-Data FIFO for Port 1 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT1_WFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 660\] has been violated. The internal associated Write-Data FIFO for Port 1 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT2_WFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 661\] has been violated. The internal associated Write-Data FIFO for Port 2 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT2_WFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 662\] has been violated. The internal associated Write-Data FIFO for Port 2 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT2_WFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 663\] has been violated. The internal associated Write-Data FIFO for Port 2 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT2_WFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 664\] has been violated. The internal associated Write-Data FIFO for Port 2 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT3_WFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 665\] has been violated. The internal associated Write-Data FIFO for Port 3 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT3_WFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 666\] has been violated. The internal associated Write-Data FIFO for Port 3 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT3_WFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 667\] has been violated. The internal associated Write-Data FIFO for Port 3 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT3_WFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 668\] has been violated. The internal associated Write-Data FIFO for Port 3 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT4_WFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 669\] has been violated. The internal associated Write-Data FIFO for Port 4 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT4_WFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 670\] has been violated. The internal associated Write-Data FIFO for Port 4 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT4_WFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 671\] has been violated. The internal associated Write-Data FIFO for Port 4 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT4_WFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 672\] has been violated. The internal associated Write-Data FIFO for Port 4 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT5_WFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 673\] has been violated. The internal associated Write-Data FIFO for Port 5 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT5_WFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 674\] has been violated. The internal associated Write-Data FIFO for Port 5 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT5_WFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 675\] has been violated. The internal associated Write-Data FIFO for Port 5 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT5_WFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 676\] has been violated. The internal associated Write-Data FIFO for Port 5 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT0_RFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 677\] has been violated. The internal associated Read-Data FIFO for Port 0 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT0_RFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 678\] has been violated. The internal associated Read-Data FIFO for Port 0 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT0_RFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 679\] has been violated. The internal associated Read-Data FIFO for Port 0 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT0_RFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 680\] has been violated. The internal associated Read-Data FIFO for Port 0 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 0 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT1_RFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 681\] has been violated. The internal associated Read-Data FIFO for Port 1 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT1_RFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 682\] has been violated. The internal associated Read-Data FIFO for Port 1 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT1_RFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 683\] has been violated. The internal associated Read-Data FIFO for Port 1 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT1_RFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 684\] has been violated. The internal associated Read-Data FIFO for Port 1 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 1 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT2_RFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 685\] has been violated. The internal associated Read-Data FIFO for Port 2 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT2_RFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 686\] has been violated. The internal associated Read-Data FIFO for Port 2 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT2_RFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 687\] has been violated. The internal associated Read-Data FIFO for Port 2 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT2_RFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 688\] has been violated. The internal associated Read-Data FIFO for Port 2 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 2 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT3_RFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 689\] has been violated. The internal associated Read-Data FIFO for Port 3 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT3_RFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 690\] has been violated. The internal associated Read-Data FIFO for Port 3 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT3_RFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 691\] has been violated. The internal associated Read-Data FIFO for Port 3 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT3_RFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 692\] has been violated. The internal associated Read-Data FIFO for Port 3 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 3 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT4_RFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 693\] has been violated. The internal associated Read-Data FIFO for Port 4 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT4_RFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 694\] has been violated. The internal associated Read-Data FIFO for Port 4 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT4_RFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 695\] has been violated. The internal associated Read-Data FIFO for Port 4 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT4_RFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 696\] has been violated. The internal associated Read-Data FIFO for Port 4 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 4 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_NO") } {
        	if { [get_parameter_value ENUM_CPORT5_RFIFO_MAP]  != "FIFO_0" } {
        		_eprint "Hard EMIF : \[Rule 697\] has been violated. The internal associated Read-Data FIFO for Port 5 must begin with FIFO 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to either F0-F3, F0-F1, F0 or None."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1"} {
        	if { [get_parameter_value ENUM_CPORT5_RFIFO_MAP]  != "FIFO_1" } {
        		_eprint "Hard EMIF : \[Rule 698\] has been violated. The internal associated Read-Data FIFO for Port 5 must begin with FIFO 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F1."
        		set rbc_validation_pass 0
        	}
        } elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2") } {
        	if { [get_parameter_value ENUM_CPORT5_RFIFO_MAP]  != "FIFO_2" } {
        		_eprint "Hard EMIF : \[Rule 699\] has been violated. The internal associated Read-Data FIFO for Port 5 must begin with FIFO 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to either F2-F3 or F2."
        		set rbc_validation_pass 0
        	}
        } elseif { [get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3"} {
        	if { [get_parameter_value ENUM_CPORT5_RFIFO_MAP]  != "FIFO_3" } {
        		_eprint "Hard EMIF : \[Rule 700\] has been violated. The internal associated Read-Data FIFO for Port 5 must begin with FIFO 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for Port 5 is set to F3."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_0]  == "FALSE"} {
        	if { [get_parameter_value ENUM_RFIFO0_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 701\] has been violated. The internal associated port for Read-Data FIFO 0 must be set to Port 0 when in-use status for Read-Data FIFO 0 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0") } {
        		if { [get_parameter_value ENUM_RFIFO0_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 702\] has been violated. The internal associated port for Read-Data FIFO 0 must be set to Port 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0") } {
        		if { [get_parameter_value ENUM_RFIFO0_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 703\] has been violated. The internal associated port for Read-Data FIFO 0 must be set to Port 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0") } {
        		if { [get_parameter_value ENUM_RFIFO0_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 704\] has been violated. The internal associated port for Read-Data FIFO 0 must be set to Port 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0") } {
        		if { [get_parameter_value ENUM_RFIFO0_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 705\] has been violated. The internal associated port for Read-Data FIFO 0 must be set to Port 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0") } {
        		if { [get_parameter_value ENUM_RFIFO0_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 706\] has been violated. The internal associated port for Read-Data FIFO 0 must be set to Port 4 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0") } {
        		if { [get_parameter_value ENUM_RFIFO0_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 707\] has been violated. The internal associated port for Read-Data FIFO 0 must be set to Port 5 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_1]  == "FALSE"} {
        	if { [get_parameter_value ENUM_RFIFO1_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 708\] has been violated. The internal associated port for Read-Data FIFO 1 must be set to Port 0 when in-use status for Read-Data FIFO 1 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_1") } {
        		if { [get_parameter_value ENUM_RFIFO1_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 709\] has been violated. The internal associated port for Read-Data FIFO 1 must be set to Port 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_1") } {
        		if { [get_parameter_value ENUM_RFIFO1_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 710\] has been violated. The internal associated port for Read-Data FIFO 1 must be set to Port 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_1") } {
        		if { [get_parameter_value ENUM_RFIFO1_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 711\] has been violated. The internal associated port for Read-Data FIFO 1 must be set to Port 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_1") } {
        		if { [get_parameter_value ENUM_RFIFO1_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 712\] has been violated. The internal associated port for Read-Data FIFO 1 must be set to Port 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_1") } {
        		if { [get_parameter_value ENUM_RFIFO1_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 713\] has been violated. The internal associated port for Read-Data FIFO 1 must be set to Port 4 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_1") } {
        		if { [get_parameter_value ENUM_RFIFO1_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 714\] has been violated. The internal associated port for Read-Data FIFO 1 must be set to Port 5 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_2]  == "FALSE"} {
        	if { [get_parameter_value ENUM_RFIFO2_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 715\] has been violated. The internal associated port for Read-Data FIFO 2 must be set to Port 0 when in-use status for Read-Data FIFO 2 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2") } {
        		if { [get_parameter_value ENUM_RFIFO2_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 716\] has been violated. The internal associated port for Read-Data FIFO 2 must be set to Port 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 0 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2") } {
        		if { [get_parameter_value ENUM_RFIFO2_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 717\] has been violated. The internal associated port for Read-Data FIFO 2 must be set to Port 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 1 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2") } {
        		if { [get_parameter_value ENUM_RFIFO2_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 718\] has been violated. The internal associated port for Read-Data FIFO 2 must be set to Port 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 2 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2") } {
        		if { [get_parameter_value ENUM_RFIFO2_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 719\] has been violated. The internal associated port for Read-Data FIFO 2 must be set to Port 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 3 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2") } {
        		if { [get_parameter_value ENUM_RFIFO2_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 720\] has been violated. The internal associated port for Read-Data FIFO 2 must be set to Port 4 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 4 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2") } {
        		if { [get_parameter_value ENUM_RFIFO2_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 721\] has been violated. The internal associated port for Read-Data FIFO 2 must be set to Port 5 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 5 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_RD_FIFO_IN_USE_3]  == "FALSE"} {
        	if { [get_parameter_value ENUM_RFIFO3_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 722\] has been violated. The internal associated port for Read-Data FIFO 3 must be set to Port 0 when in-use status for Read-Data FIFO 3 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_0]  == "USE_3") } {
        		if { [get_parameter_value ENUM_RFIFO3_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 723\] has been violated. The internal associated port for Read-Data FIFO 3 must be set to Port 0 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 0 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_1]  == "USE_3") } {
        		if { [get_parameter_value ENUM_RFIFO3_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 724\] has been violated. The internal associated port for Read-Data FIFO 3 must be set to Port 1 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 1 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_2]  == "USE_3") } {
        		if { [get_parameter_value ENUM_RFIFO3_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 725\] has been violated. The internal associated port for Read-Data FIFO 3 must be set to Port 2 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 2 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_3]  == "USE_3") } {
        		if { [get_parameter_value ENUM_RFIFO3_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 726\] has been violated. The internal associated port for Read-Data FIFO 3 must be set to Port 3 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 3 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_4]  == "USE_3") } {
        		if { [get_parameter_value ENUM_RFIFO3_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 727\] has been violated. The internal associated port for Read-Data FIFO 3 must be set to Port 4 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 4 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_RD_PORT_INFO_5]  == "USE_3") } {
        		if { [get_parameter_value ENUM_RFIFO3_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 728\] has been violated. The internal associated port for Read-Data FIFO 3 must be set to Port 5 when the '[get_parameter_property ALLOCATED_RFIFO_PORT DISPLAY_NAME]' for  Port 5 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_0]  == "FALSE"} {
        	if { [get_parameter_value ENUM_WFIFO0_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 729\] has been violated. The internal associated port for Write-Data FIFO 0 must be set to Port 0 when in-use status for Write-Data FIFO 0 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0") } {
        		if { [get_parameter_value ENUM_WFIFO0_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 730\] has been violated. The internal associated port for Write-Data FIFO 0 must be set to Port 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0") } {
        		if { [get_parameter_value ENUM_WFIFO0_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 731\] has been violated. The internal associated port for Write-Data FIFO 0 must be set to Port 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0") } {
        		if { [get_parameter_value ENUM_WFIFO0_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 732\] has been violated. The internal associated port for Write-Data FIFO 0 must be set to Port 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0") } {
        		if { [get_parameter_value ENUM_WFIFO0_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 733\] has been violated. The internal associated port for Write-Data FIFO 0 must be set to Port 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0") } {
        		if { [get_parameter_value ENUM_WFIFO0_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 734\] has been violated. The internal associated port for Write-Data FIFO 0 must be set to Port 4 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0") } {
        		if { [get_parameter_value ENUM_WFIFO0_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 735\] has been violated. The internal associated port for Write-Data FIFO 0 must be set to Port 5 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F0."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_1]  == "FALSE"} {
        	if { [get_parameter_value ENUM_WFIFO1_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 736\] has been violated. The internal associated port for Write-Data FIFO 1 must be set to Port 0 when in-use status for Write-Data FIFO 1 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_1") } {
        		if { [get_parameter_value ENUM_WFIFO1_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 737\] has been violated. The internal associated port for Write-Data FIFO 1 must be set to Port 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_1") } {
        		if { [get_parameter_value ENUM_WFIFO1_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 738\] has been violated. The internal associated port for Write-Data FIFO 1 must be set to Port 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_1") } {
        		if { [get_parameter_value ENUM_WFIFO1_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 739\] has been violated. The internal associated port for Write-Data FIFO 1 must be set to Port 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_1") } {
        		if { [get_parameter_value ENUM_WFIFO1_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 740\] has been violated. The internal associated port for Write-Data FIFO 1 must be set to Port 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_1") } {
        		if { [get_parameter_value ENUM_WFIFO1_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 741\] has been violated. The internal associated port for Write-Data FIFO 1 must be set to Port 4 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_1") } {
        		if { [get_parameter_value ENUM_WFIFO1_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 742\] has been violated. The internal associated port for Write-Data FIFO 1 must be set to Port 5 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port  is set to either F0-F3, F0-F1 or F1."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_2]  == "FALSE"} {
        	if { [get_parameter_value ENUM_WFIFO2_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 743\] has been violated. The internal associated port for Write-Data FIFO 2 must be set to Port 0 when in-use status for Write-Data FIFO 2 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2") } {
        		if { [get_parameter_value ENUM_WFIFO2_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 744\] has been violated. The internal associated port for Write-Data FIFO 2 must be set to Port 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 0 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2") } {
        		if { [get_parameter_value ENUM_WFIFO2_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 745\] has been violated. The internal associated port for Write-Data FIFO 2 must be set to Port 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 1 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2") } {
        		if { [get_parameter_value ENUM_WFIFO2_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 746\] has been violated. The internal associated port for Write-Data FIFO 2 must be set to Port 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 2 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2") } {
        		if { [get_parameter_value ENUM_WFIFO2_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 747\] has been violated. The internal associated port for Write-Data FIFO 2 must be set to Port 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 3 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2") } {
        		if { [get_parameter_value ENUM_WFIFO2_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 748\] has been violated. The internal associated port for Write-Data FIFO 2 must be set to Port 4 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 4 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2") } {
        		if { [get_parameter_value ENUM_WFIFO2_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 749\] has been violated. The internal associated port for Write-Data FIFO 2 must be set to Port 5 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 5 is set to either F0-F3, F2-F3 or F2."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_WR_FIFO_IN_USE_3]  == "FALSE"} {
        	if { [get_parameter_value ENUM_WFIFO3_CPORT_MAP]  != "CMD_PORT_0" } {
        		_eprint "Hard EMIF : \[Rule 750\] has been violated. The internal associated port for Write-Data FIFO 3 must be set to Port 0 when in-use status for Write-Data FIFO 3 is set to false."
        		set rbc_validation_pass 0
        	}
        } else {
        	if { ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_0]  == "USE_3") } {
        		if { [get_parameter_value ENUM_WFIFO3_CPORT_MAP]  != "CMD_PORT_0" } {
        			_eprint "Hard EMIF : \[Rule 751\] has been violated. The internal associated port for Write-Data FIFO 3 must be set to Port 0 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 0 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_1]  == "USE_3") } {
        		if { [get_parameter_value ENUM_WFIFO3_CPORT_MAP]  != "CMD_PORT_1" } {
        			_eprint "Hard EMIF : \[Rule 752\] has been violated. The internal associated port for Write-Data FIFO 3 must be set to Port 1 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 1 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_2]  == "USE_3") } {
        		if { [get_parameter_value ENUM_WFIFO3_CPORT_MAP]  != "CMD_PORT_2" } {
        			_eprint "Hard EMIF : \[Rule 753\] has been violated. The internal associated port for Write-Data FIFO 3 must be set to Port 2 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 2 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_3]  == "USE_3") } {
        		if { [get_parameter_value ENUM_WFIFO3_CPORT_MAP]  != "CMD_PORT_3" } {
        			_eprint "Hard EMIF : \[Rule 754\] has been violated. The internal associated port for Write-Data FIFO 3 must be set to Port 3 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 3 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_4]  == "USE_3") } {
        		if { [get_parameter_value ENUM_WFIFO3_CPORT_MAP]  != "CMD_PORT_4" } {
        			_eprint "Hard EMIF : \[Rule 755\] has been violated. The internal associated port for Write-Data FIFO 3 must be set to Port 4 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 4 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	} elseif { ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_0_1_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_2_3") || ([get_parameter_value ENUM_WR_PORT_INFO_5]  == "USE_3") } {
        		if { [get_parameter_value ENUM_WFIFO3_CPORT_MAP]  != "CMD_PORT_5" } {
        			_eprint "Hard EMIF : \[Rule 756\] has been violated. The internal associated port for Write-Data FIFO 3 must be set to Port 5 when the '[get_parameter_property ALLOCATED_WFIFO_PORT DISPLAY_NAME]' for  Port 5 is set to either F0-F3, F2-F3 or F3."
        			set rbc_validation_pass 0
        		}
        	}
        }

        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_0]  == "TRUE"} {
        	if { ([get_parameter_value ENUM_AUTO_PCH_ENABLE_0]  != "ENABLED") && ([get_parameter_value ENUM_AUTO_PCH_ENABLE_0]  != "DISABLED") } {
                        _eprint "Hard EMIF : \[Rule 757\] has been violated. The internal Port 0 auto-precharge must be set to either enabled or disabled when Port 0 being enabled."
                        set rbc_validation_pass 0
                }
        } else {
        	if { [get_parameter_value ENUM_AUTO_PCH_ENABLE_0]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 758\] has been violated. The internal Port 0 auto-precharge must be set to disabled when Port 0 being disabled."
        		set rbc_validation_pass 0
        	}
        }
        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_1]  == "TRUE"} {
        	if { ([get_parameter_value ENUM_AUTO_PCH_ENABLE_1]  != "ENABLED") && ([get_parameter_value ENUM_AUTO_PCH_ENABLE_1]  != "DISABLED") } {
                        _eprint "Hard EMIF : \[Rule 759\] has been violated. The internal Port 1 auto-precharge must be set to either enabled or disabled when Port 1 being enabled."
                        set rbc_validation_pass 0
                }
        } else {
        	if { [get_parameter_value ENUM_AUTO_PCH_ENABLE_1]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 760\] has been violated. The internal Port 1 auto-precharge must be set to disabled when Port 1 being disabled."
        		set rbc_validation_pass 0
        	}
        }
        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_2]  == "TRUE"} {
        	if { ([get_parameter_value ENUM_AUTO_PCH_ENABLE_2]  != "ENABLED") && ([get_parameter_value ENUM_AUTO_PCH_ENABLE_2]  != "DISABLED") } {
                        _eprint "Hard EMIF : \[Rule 761\] has been violated. The internal Port 2 auto-precharge must be set to either enabled or disabled when Port 2 being enabled."
                        set rbc_validation_pass 0
                }
        } else {
        	if { [get_parameter_value ENUM_AUTO_PCH_ENABLE_2]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 762\] has been violated. The internal Port 2 auto-precharge must be set to disabled when Port 2 being disabled."
        		set rbc_validation_pass 0
        	}
        }
        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_3]  == "TRUE"} {
        	if { ([get_parameter_value ENUM_AUTO_PCH_ENABLE_3]  != "ENABLED") && ([get_parameter_value ENUM_AUTO_PCH_ENABLE_3]  != "DISABLED") } {
                        _eprint "Hard EMIF : \[Rule 763\] has been violated. The internal Port 3 auto-precharge must be set to either enabled or disabled when Port 3 being enabled."
                        set rbc_validation_pass 0
                }
        } else {
        	if { [get_parameter_value ENUM_AUTO_PCH_ENABLE_3]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 764\] has been violated. The internal Port 3 auto-precharge must be set to disabled when Port 3 being disabled."
        		set rbc_validation_pass 0
        	}
        }
        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_4]  == "TRUE"} {
        	if { ([get_parameter_value ENUM_AUTO_PCH_ENABLE_4]  != "ENABLED") && ([get_parameter_value ENUM_AUTO_PCH_ENABLE_4]  != "DISABLED") } {
                        _eprint "Hard EMIF : \[Rule 765\] has been violated. The internal Port 4 auto-precharge must be set to either enabled or disabled when Port 4 being enabled."
                        set rbc_validation_pass 0
                }
        } else {
        	if { [get_parameter_value ENUM_AUTO_PCH_ENABLE_4]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 766\] has been violated. The internal Port 4 auto-precharge must be set to disabled when Port 4 being disabled."
        		set rbc_validation_pass 0
        	}
        }
        if { [get_parameter_value ENUM_CMD_PORT_IN_USE_5]  == "TRUE"} {
        	if { ([get_parameter_value ENUM_AUTO_PCH_ENABLE_5]  != "ENABLED") && ([get_parameter_value ENUM_AUTO_PCH_ENABLE_5]  != "DISABLED") } {
                        _eprint "Hard EMIF : \[Rule 767\] has been violated. The internal Port 5 auto-precharge must be set to either enabled or disabled when Port 5 being enabled."
                        set rbc_validation_pass 0
                }
        } else {
        	if { [get_parameter_value ENUM_AUTO_PCH_ENABLE_5]  != "DISABLED" } {
        		_eprint "Hard EMIF : \[Rule 768\] has been violated. The internal Port 5 auto-precharge must be set to disabled when Port 5 being disabled."
        		set rbc_validation_pass 0
        	}
        }

        if { [get_parameter_value ENUM_RCFG_USER_PRIORITY_0]  != [get_parameter_value ENUM_USER_PRIORITY_0]  } {
        	_eprint "Hard EMIF : \[Rule 769\] has been violated. The internal reconfigure user priority for Port 0 must be set to [get_parameter_value ENUM_USER_PRIORITY_0]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_USER_PRIORITY_1]  != [get_parameter_value ENUM_USER_PRIORITY_1]  } {
        	_eprint "Hard EMIF : \[Rule 770\] has been violated. The internal reconfigure user priority for Port 1 must be set to [get_parameter_value ENUM_USER_PRIORITY_1]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_USER_PRIORITY_2]  != [get_parameter_value ENUM_USER_PRIORITY_2]  } {
        	_eprint "Hard EMIF : \[Rule 771\] has been violated. The internal reconfigure user priority for Port 2 must be set to [get_parameter_value ENUM_USER_PRIORITY_2]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_USER_PRIORITY_3]  != [get_parameter_value ENUM_USER_PRIORITY_3]  } {
        	_eprint "Hard EMIF : \[Rule 772\] has been violated. The internal reconfigure user priority for Port 3 must be set to [get_parameter_value ENUM_USER_PRIORITY_3]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_USER_PRIORITY_4]  != [get_parameter_value ENUM_USER_PRIORITY_4]  } {
        	_eprint "Hard EMIF : \[Rule 773\] has been violated. The internal reconfigure user priority for Port 4 must be set to [get_parameter_value ENUM_USER_PRIORITY_4]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_USER_PRIORITY_5]  != [get_parameter_value ENUM_USER_PRIORITY_5]  } {
        	_eprint "Hard EMIF : \[Rule 774\] has been violated. The internal reconfigure user priority for Port 5 must be set to [get_parameter_value ENUM_USER_PRIORITY_5]."
        	set rbc_validation_pass 0
        }

        if { [get_parameter_value ENUM_RCFG_STATIC_WEIGHT_0]  != [get_parameter_value ENUM_STATIC_WEIGHT_0]  } {
        	_eprint "Hard EMIF : \[Rule 775\] has been violated. The internal reconfigure user static weight for Port 0 must be set to [get_parameter_value ENUM_STATIC_WEIGHT_0]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_STATIC_WEIGHT_1]  != [get_parameter_value ENUM_STATIC_WEIGHT_1]  } {
        	_eprint "Hard EMIF : \[Rule 776\] has been violated. The internal reconfigure user static weight for Port 1 must be set to [get_parameter_value ENUM_STATIC_WEIGHT_1]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_STATIC_WEIGHT_2]  != [get_parameter_value ENUM_STATIC_WEIGHT_2]  } {
        	_eprint "Hard EMIF : \[Rule 777\] has been violated. The internal reconfigure user static weight for Port 2 must be set to [get_parameter_value ENUM_STATIC_WEIGHT_2]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_STATIC_WEIGHT_3]  != [get_parameter_value ENUM_STATIC_WEIGHT_3]  } {
        	_eprint "Hard EMIF : \[Rule 778\] has been violated. The internal reconfigure user static weight for Port 3 must be set to [get_parameter_value ENUM_STATIC_WEIGHT_3]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_STATIC_WEIGHT_4]  != [get_parameter_value ENUM_STATIC_WEIGHT_4]  } {
        	_eprint "Hard EMIF : \[Rule 779\] has been violated. The internal reconfigure user static weight for Port 4 must be set to [get_parameter_value ENUM_STATIC_WEIGHT_4]."
        	set rbc_validation_pass 0
        }
        if { [get_parameter_value ENUM_RCFG_STATIC_WEIGHT_5]  != [get_parameter_value ENUM_STATIC_WEIGHT_5]  } {
        	_eprint "Hard EMIF : \[Rule 780\] has been violated. The internal reconfigure user static weight for Port 5 must be set to [get_parameter_value ENUM_STATIC_WEIGHT_5]."
        	set rbc_validation_pass 0
        }


        return $rbc_validation_pass

}
::alt_mem_if::gui::ddrx_controller::_init









