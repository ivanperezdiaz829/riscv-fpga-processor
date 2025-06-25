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


package provide alt_mem_if::gen::uniphy_interfaces 0.1

package require alt_mem_if::util::messaging
package require alt_mem_if::util::list_array
package require alt_mem_if::util::hwtcl_utils
namespace eval ::alt_mem_if::gen::uniphy_interfaces:: {
	

}




proc ::alt_mem_if::gen::uniphy_interfaces::ddrx_hpcii_sideband_signals {} {

	add_interface avl_multicast_write conduit end
	set_interface_property avl_multicast_write ENABLED true
	add_interface_port avl_multicast_write local_multicast local_multicast Input 1
	if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination avl_multicast_write 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination avl_multicast_write 0
	}

	add_interface autoprecharge_req conduit end
	set_interface_property autoprecharge_req ENABLED true
	add_interface_port autoprecharge_req local_autopch_req local_autopch_req Input 1
	if {[string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination autoprecharge_req 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination autoprecharge_req 0
	}

	add_interface user_refresh conduit end
	set_interface_property user_refresh ENABLED true
	add_interface_port user_refresh local_refresh_req local_refresh_req Input 1
	add_interface_port user_refresh local_refresh_chip local_refresh_chip Input [get_parameter_value CTL_CS_WIDTH]
	set_port_property local_refresh_chip VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port user_refresh local_refresh_ack local_refresh_ack Output 1
	if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination user_refresh 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination user_refresh 0
	}

	add_interface self_refresh conduit end
	set_interface_property self_refresh ENABLED true
	add_interface_port self_refresh local_self_rfsh_req local_self_rfsh_req Input 1
	add_interface_port self_refresh local_self_rfsh_chip local_self_rfsh_chip Input [get_parameter_value CTL_CS_WIDTH]
	set_port_property local_self_rfsh_chip VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port self_refresh local_self_rfsh_ack local_self_rfsh_ack Output 1
	if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination self_refresh 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination self_refresh 0
	}

	add_interface local_powerdown conduit end
	set_interface_property local_powerdown ENABLED true
	add_interface_port local_powerdown local_power_down_ack local_power_down_ack Output 1
	if {[string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination local_powerdown 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination local_powerdown 0
	}

        if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
	        add_interface ecc_interrupt conduit end
	        set_interface_property ecc_interrupt ENABLED true
	        add_interface_port ecc_interrupt ecc_interrupt ecc_interrupt Output 1
        }

	if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
		add_interface avl_rdata_error conduit end
		set_interface_property avl_rdata_error ENABLED true
		add_interface_port avl_rdata_error local_rdata_error local_rdata_error Output 1
	}


}


proc ::alt_mem_if::gen::uniphy_interfaces::ddrx_nextgen_sideband_signals {} {

	add_interface avl_multicast_write conduit end
	set_interface_property avl_multicast_write ENABLED true
	add_interface_port avl_multicast_write local_multicast local_multicast Input 1
	if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination avl_multicast_write 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination avl_multicast_write 0
	}

	add_interface user_refresh conduit end
	set_interface_property user_refresh ENABLED true
	add_interface_port user_refresh local_refresh_req local_refresh_req Input 1
	add_interface_port user_refresh local_refresh_chip local_refresh_chip Input [get_parameter_value CTL_CS_WIDTH]
	set_port_property local_refresh_chip VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port user_refresh local_refresh_ack local_refresh_ack Output 1
	if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination user_refresh 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination user_refresh 0
	}

	add_interface self_refresh conduit end
	set_interface_property self_refresh ENABLED true
	add_interface_port self_refresh local_self_rfsh_req local_self_rfsh_req Input 1
	add_interface_port self_refresh local_self_rfsh_chip local_self_rfsh_chip Input [get_parameter_value CTL_CS_WIDTH]
	set_port_property local_self_rfsh_chip VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port self_refresh local_self_rfsh_ack local_self_rfsh_ack Output 1
	if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination self_refresh 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination self_refresh 0
	}
	
	add_interface deep_powerdn conduit end
	set_interface_property deep_powerdn ENABLED true
	add_interface_port deep_powerdn local_deep_powerdn_req local_deep_powerdn_req Input 1
	add_interface_port deep_powerdn local_deep_powerdn_chip local_deep_powerdn_chip Input [get_parameter_value CTL_CS_WIDTH]
	set_port_property local_deep_powerdn_chip VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port deep_powerdn local_deep_powerdn_ack local_deep_powerdn_ack Output 1
	if {[string compare -nocase [get_parameter_value CTL_DEEP_POWERDN_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination deep_powerdn 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination deep_powerdn 0
	}

	add_interface local_powerdown conduit end
	set_interface_property local_powerdown ENABLED true
	add_interface_port local_powerdown local_powerdn_ack local_powerdn_ack Output 1
	if {[string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination local_powerdown 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination local_powerdown 0
	}

	add_interface priority conduit end
	set_interface_property priority ENABLED true
	add_interface_port priority local_priority local_priority Input 1
	set_port_property local_priority termination true
	set_port_property local_priority termination_value 0

        if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0 &&
            [string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0
        } {
	        add_interface ecc_interrupt conduit end
	        set_interface_property ecc_interrupt ENABLED true
	        add_interface_port ecc_interrupt ecc_interrupt ecc_interrupt Output 1
        }


        if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
	        add_interface bonding_in conduit end
	        set_interface_property bonding_in ENABLED true
	        add_interface_port bonding_in bonding_in_1 bonding1 Input 4
                add_interface_port bonding_in bonding_in_2 bonding2 Input 6
                add_interface_port bonding_in bonding_in_3 bonding3 Input 6
	        set_port_property bonding_in_2 VHDL_TYPE STD_LOGIC_VECTOR
                set_port_property bonding_in_3 VHDL_TYPE STD_LOGIC_VECTOR

                add_interface bonding_out conduit start
	        set_interface_property bonding_out ENABLED true
                add_interface_port bonding_out bonding_out_1 bonding1 Output 4
                add_interface_port bonding_out bonding_out_2 bonding2 Output 6
                add_interface_port bonding_out bonding_out_3 bonding3 Output 6
	        set_port_property bonding_out_2 VHDL_TYPE STD_LOGIC_VECTOR
                set_port_property bonding_out_3 VHDL_TYPE STD_LOGIC_VECTOR

	        if {[string compare -nocase [get_parameter_value ENABLE_BONDING] "true"] == 0} {
	        	::alt_mem_if::util::hwtcl_utils::set_interface_termination bonding_in 1
                        ::alt_mem_if::util::hwtcl_utils::set_interface_termination bonding_out 1
	        } else {
	        	::alt_mem_if::util::hwtcl_utils::set_interface_termination bonding_in 0
                        ::alt_mem_if::util::hwtcl_utils::set_interface_termination bonding_out 0
                }

        }
}

proc ::alt_mem_if::gen::uniphy_interfaces::refctrl_interface {} {

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_enable_refctrl] && 
		[string compare -nocase [get_parameter_value ENABLE_REFCTRL] "true"] == 0} {
		add_interface refctrl conduit end
		set_interface_property refctrl ENABLED true
		add_interface_port refctrl tbp_empty tbp_empty Output 1
		add_interface_port refctrl cmd_gen_busy cmd_gen_busy Output 1
		add_interface_port refctrl sideband_in_refresh sideband_in_refresh Output 1
	}
}

proc ::alt_mem_if::gen::uniphy_interfaces::zqcal_interface {} {

	add_interface user_zqcal conduit end
	set_interface_property user_zqcal ENABLED true
	add_interface_port user_zqcal local_zqcal_req local_zqcal_req Input 1
	add_interface_port user_zqcal local_zqcal_chip local_zqcal_chip Input [get_parameter_value CTL_CS_WIDTH]
	set_port_property local_zqcal_chip VHDL_TYPE STD_LOGIC_VECTOR
	if {[string compare -nocase [get_parameter_value CTL_ZQCAL_EN] "true"] == 0} {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination user_zqcal 1
	} else {
		::alt_mem_if::util::hwtcl_utils::set_interface_termination user_zqcal 0
	}
}

proc ::alt_mem_if::gen::uniphy_interfaces::tracking_interface {component {always_define 0}} {
    
    if {[string compare -nocase $component "phy"] == 0} {

	    set input_trk_phy "Input"
	    set output_trk_phy "Output"
	
    } elseif {[string compare -nocase $component "controller"] == 0} {

	    set input_trk_phy "Output"
	    set output_trk_phy "Input"
	
    } else {
	    _error "Invalid component specification to determine afi interface"
    }

    if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0 ||
	[string compare -nocase $component "controller"] == 0 || $always_define} {

	    add_interface tracking conduit end
	    set_interface_property tracking ENABLED true
	    add_interface_port tracking afi_seq_busy afi_seq_busy $output_trk_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
	    set_port_property afi_seq_busy VHDL_TYPE STD_LOGIC_VECTOR
	    add_interface_port tracking afi_ctl_refresh_done afi_ctl_refresh_done $input_trk_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
	    set_port_property afi_ctl_refresh_done VHDL_TYPE STD_LOGIC_VECTOR
	    add_interface_port tracking afi_ctl_long_idle afi_ctl_long_idle $input_trk_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
	    set_port_property afi_ctl_long_idle VHDL_TYPE STD_LOGIC_VECTOR

	    if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
		    ::alt_mem_if::util::hwtcl_utils::set_interface_termination tracking 1
	    } else {
		    ::alt_mem_if::util::hwtcl_utils::set_interface_termination tracking 0
	    }
    }
}

proc ::alt_mem_if::gen::uniphy_interfaces::pingpong_1t {component} {
    
    if {[string compare -nocase $component "phy"] == 0} {

	    set input_phy "Input"
	    set output_phy "Output"
	
    } elseif {[string compare -nocase $component "controller"] == 0} {

	    set input_phy "Output"
	    set output_phy "Input"
	
    } else {
	    _error "Invalid component specification to determine pingpong_1t interface"
    }
	add_interface pingpong_1t conduit end
	set_interface_property pingpong_1t ENABLED true
	add_interface_port pingpong_1t afi_rdata_en_1t afi_rdata_en_1t $input_phy [get_parameter_value AFI_RATE_RATIO]
	add_interface_port pingpong_1t afi_rdata_en_full_1t afi_rdata_en_full_1t $input_phy [get_parameter_value AFI_RATE_RATIO]
	add_interface_port pingpong_1t afi_rdata_valid_1t afi_rdata_valid_1t $output_phy [get_parameter_value AFI_RATE_RATIO]
}

proc ::alt_mem_if::gen::uniphy_interfaces::afi_mem_clk_disable {component} {
    
    if {[string compare -nocase $component "phy"] == 0} {

	    set input_phy "Input"
	
    } elseif {[string compare -nocase $component "controller"] == 0} {

	    set input_phy "Output"
	
    } else {
	    _error "Invalid component specification to determine afi_mem_clk_disable interface"
    }

    add_interface afi_mem_clk_disable conduit end
	set_interface_property afi_mem_clk_disable ENABLED true
	add_interface_port afi_mem_clk_disable afi_mem_clk_disable afi_mem_clk_disable $input_phy [get_parameter_value AFI_CLK_PAIR_COUNT]
	set_port_property afi_mem_clk_disable VHDL_TYPE STD_LOGIC_VECTOR
}

proc ::alt_mem_if::gen::uniphy_interfaces::pll_sharing {direction {suffix {}}} {

    if {[string compare -nocase $direction "source"] == 0} {

		set src_input "Input"
		set src_output "Output"
	
	} elseif {[string compare -nocase $direction "sink"] == 0} {

		set src_input "Output"
		set src_output "Input"
	
	} else {
		_error "Invalid component specification to determine pll_sharing interface"
	}

	add_interface pll_sharing${suffix} conduit end
	set_interface_property pll_sharing${suffix} ENABLED true

	add_interface_port pll_sharing${suffix} pll_mem_clk${suffix} pll_mem_clk $src_output 1
	add_interface_port pll_sharing${suffix} pll_write_clk${suffix} pll_write_clk $src_output 1
	add_interface_port pll_sharing${suffix} pll_locked${suffix} pll_locked $src_output 1
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "max10fpga"] == 0} {
	    add_interface_port pll_sharing${suffix} pll_capture0_clk${suffix} pll_capture0_clk $src_output 1
		add_interface_port pll_sharing${suffix} pll_capture1_clk${suffix} pll_capture1_clk $src_output 1
	} else {
		add_interface_port pll_sharing${suffix} pll_write_clk_pre_phy_clk${suffix} pll_write_clk_pre_phy_clk $src_output 1
		add_interface_port pll_sharing${suffix} pll_addr_cmd_clk${suffix} pll_addr_cmd_clk $src_output 1
	}
	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0 && [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "max10fpga"] != 0} {
		add_interface_port pll_sharing${suffix} pll_avl_clk${suffix} pll_avl_clk $src_output 1
		add_interface_port pll_sharing${suffix} pll_config_clk${suffix} pll_config_clk $src_output 1
	}
	
	if {[string compare -nocase [get_parameter_value RATE] "QUARTER"] == 0} {
		add_interface_port pll_sharing${suffix} pll_hr_clk${suffix} pll_hr_clk $src_output 1
	}
	if {[string compare -nocase [get_parameter_value CORE_PERIPHERY_DUAL_CLOCK] "true"] == 0} {
		add_interface_port pll_sharing${suffix} pll_p2c_read_clk${suffix} pll_p2c_read_clk $src_output 1
		add_interface_port pll_sharing${suffix} pll_c2p_write_clk${suffix} pll_c2p_write_clk $src_output 1
	}
	if {[string compare -nocase [get_parameter_value USE_DR_CLK] "true"] == 0} {
		add_interface_port pll_sharing${suffix} pll_dr_clk${suffix} pll_dr_clk $src_output 1
		add_interface_port pll_sharing${suffix} pll_dr_clk_pre_phy_clk${suffix} pll_dr_clk_pre_phy_clk $src_output 1
	}			
	if {[string compare -nocase [get_parameter_value DUPLICATE_PLL_FOR_PHY_CLK] "true"] == 0} {
		add_interface_port pll_sharing${suffix} pll_mem_phy_clk${suffix} pll_mem_phy_clk $src_output 1
		add_interface_port pll_sharing${suffix} afi_phy_clk${suffix} afi_phy_clk $src_output 1
		add_interface_port pll_sharing${suffix} pll_avl_phy_clk${suffix} pll_avl_phy_clk $src_output 1
	}
}


proc ::alt_mem_if::gen::uniphy_interfaces::dll_sharing {direction {suffix {}}} {
    
    if {[string compare -nocase $direction "source"] == 0} {

		set src_input "Input"
		set src_output "Output"
	
	} elseif {[string compare -nocase $direction "sink"] == 0} {

		set src_input "Output"
		set src_output "Input"
	
	} else {
		_error "Invalid component specification to determine dll_sharing interface"
	}

	add_interface dll_sharing${suffix} conduit end
	set_interface_property dll_sharing${suffix} ENABLED true
	
    add_interface_port dll_sharing${suffix} dll_pll_locked${suffix} dll_pll_locked $src_input 1

	add_interface_port dll_sharing${suffix} dll_delayctrl${suffix} dll_delayctrl $src_output [get_parameter_value DLL_DELAY_CTRL_WIDTH]

}


proc ::alt_mem_if::gen::uniphy_interfaces::oct_sharing {direction {suffix {}}} {

    if {[string compare -nocase $direction "source"] == 0} {

		set src_input "Input"
		set src_output "Output"
	
	} elseif {[string compare -nocase $direction "sink"] == 0} {

		set src_input "Output"
		set src_output "Input"
	
	} else {
		_error "Invalid component specification to determine oct_sharing interface"
	}

	add_interface oct_sharing${suffix} conduit end
	set_interface_property oct_sharing${suffix} ENABLED true
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriaiigx"] == 0} {
		add_interface_port oct_sharing${suffix} terminationcontrol${suffix} terminationcontrol $src_output [get_parameter_value OCT_TERM_CONTROL_WIDTH]
	} else {
		add_interface_port oct_sharing${suffix} seriesterminationcontrol${suffix} seriesterminationcontrol $src_output [get_parameter_value OCT_TERM_CONTROL_WIDTH]
		add_interface_port oct_sharing${suffix} parallelterminationcontrol${suffix} parallelterminationcontrol $src_output [get_parameter_value OCT_TERM_CONTROL_WIDTH]
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::oct {} {


	add_interface oct conduit end
	set_interface_property oct ENABLED true
	set_interface_assignment "oct" "qsys.ui.export_name" "oct"

	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] == 0} {
		add_interface_port oct oct_rzqin rzqin Input 1
	} else {
		if  {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriav"] == 0 ||
			[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "cyclonev"] == 0} {
			add_interface_port oct oct_rzqin rzqin Input 1
		} else {
			add_interface_port oct oct_rdn rdn Input 1
			add_interface_port oct oct_rup rup Input 1
		}
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::hcx_pll_reconfig {} {

	_dprint 1 "Generating PLL reconfiguration interface"

	add_interface hcx_pll_reconfig conduit end
	set_interface_property hcx_pll_reconfig ENABLED true

	add_interface_port hcx_pll_reconfig hc_pll_config_configupdate configupdate Input 1
	add_interface_port hcx_pll_reconfig hc_pll_config_phasecounterselect phasecounterselect Input [get_parameter_value PLL_PHASE_COUNTER_WIDTH]
	add_interface_port hcx_pll_reconfig hc_pll_config_phasestep phasestep Input 1
	add_interface_port hcx_pll_reconfig hc_pll_config_phaseupdown phaseupdown Input 1
	add_interface_port hcx_pll_reconfig hc_pll_config_scanclk scanclk Input 1
	add_interface_port hcx_pll_reconfig hc_pll_config_scanclkena scanclkena Input 1
	add_interface_port hcx_pll_reconfig hc_pll_config_scandata scandata Input 1
	add_interface_port hcx_pll_reconfig hc_pll_config_phasedone phasedone Output 1
	add_interface_port hcx_pll_reconfig hc_pll_config_scandataout scandataout Output 1
	add_interface_port hcx_pll_reconfig hc_pll_config_scandone scandone Output 1
	add_interface_port hcx_pll_reconfig hc_pll_config_locked locked Output 1

}


proc ::alt_mem_if::gen::uniphy_interfaces::hcx_dll_sharing {direction {suffix {}}} {

	_dprint 1 "Generating DLL reconfiguration interface"

    if {[string compare -nocase $direction "source"] == 0} {

		set src_input "Input"
		set src_output "Output"
	
	} elseif {[string compare -nocase $direction "sink"] == 0} {

		set src_input "Output"
		set src_output "Input"
	
	} else {
		_error "Invalid component specification to determine hcx_dll_reconfig interface"
	}

	add_interface hcx_dll_sharing${suffix} conduit end
	set_interface_property hcx_dll_sharing${suffix} ENABLED true
	add_interface_port hcx_dll_sharing${suffix} hc_dll_config_dll_offset_ctrl_offsetctrlout${suffix} dll_offset_ctrl_offsetctrlout $src_output [get_parameter_value DLL_OFFSET_CTRL_WIDTH]
	add_interface_port hcx_dll_sharing${suffix} hc_dll_config_dll_offset_ctrl_b_offsetctrlout${suffix} dll_offset_ctrl_b_offsetctrlout $src_output [get_parameter_value DLL_OFFSET_CTRL_WIDTH]
	
}


proc ::alt_mem_if::gen::uniphy_interfaces::hcx_dll_reconfig {} {

	_dprint 1 "Generating DLL reconfiguration interface"

	add_interface hcx_dll_reconfig conduit end
	set_interface_property hcx_dll_reconfig ENABLED true
	add_interface_port hcx_dll_reconfig hc_dll_config_dll_offset_ctrl_addnsub dll_offset_ctrl_addnsub Input 1
	add_interface_port hcx_dll_reconfig hc_dll_config_dll_offset_ctrl_offset dll_offset_ctrl_offset Input [get_parameter_value DLL_OFFSET_CTRL_WIDTH]

}


proc ::alt_mem_if::gen::uniphy_interfaces::hcx_rom_reconfig {} {
	
	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] ==0} {
		_dprint 1 "Generating ROM reconfiguration interface"

		add_interface hcx_rom_reconfig conduit end
		
		set_interface_property hcx_rom_reconfig ENABLED true
		
		add_interface_port hcx_rom_reconfig hc_rom_config_clock hc_rom_config_clock Input 1
		add_interface_port hcx_rom_reconfig hc_rom_config_datain hc_rom_config_datain Input 32
		add_interface_port hcx_rom_reconfig hc_rom_config_rom_data_ready hc_rom_config_rom_data_ready Input 1
		add_interface_port hcx_rom_reconfig hc_rom_config_init hc_rom_config_init Input 1
		add_interface_port hcx_rom_reconfig hc_rom_config_init_busy hc_rom_config_init_busy Output 1
		add_interface_port hcx_rom_reconfig hc_rom_config_rom_rden hc_rom_config_rom_rden Output 1
		add_interface_port hcx_rom_reconfig hc_rom_config_rom_address hc_rom_config_rom_address Output [get_parameter_value NIOS_ROM_ADDRESS_WIDTH]
	}

}

proc ::alt_mem_if::gen::uniphy_interfaces::seq_debug_csr {} {
	
	if {[string compare -nocase [get_parameter_value ENABLE_EMIT_JTAG_MASTER] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		_dprint 1 "Generating Sequencer debug access interface"

		add_interface seq_debug avalon slave
		set_interface_property seq_debug addressUnits "SYMBOLS"
		set_interface_property seq_debug associatedClock avl_clk
		set_interface_property seq_debug associatedReset avl_reset
		set_interface_property seq_debug bitsPerSymbol 8
		set_interface_property seq_debug maximumPendingReadTransactions 1
		
		set_interface_property seq_debug ENABLED true
		set_interface_assignment seq_debug debug.visible true

		add_interface_port seq_debug seq_waitrequest waitrequest Output 1
		add_interface_port seq_debug seq_readdata readdata Output 32
		add_interface_port seq_debug seq_readdatavalid readdatavalid Output 1
		add_interface_port seq_debug seq_burstcount burstcount Input 1
		set_port_property seq_burstcount VHDL_TYPE STD_LOGIC_VECTOR
		add_interface_port seq_debug seq_writedata writedata Input 32
		add_interface_port seq_debug seq_address address Input 32
		add_interface_port seq_debug seq_write write Input 1
		add_interface_port seq_debug seq_read read Input 1
		add_interface_port seq_debug seq_byteenable byteenable Input 4
		add_interface_port seq_debug seq_debugaccess debugaccess Input 1
	
		set_port_property seq_debugaccess termination true
		set_port_property seq_debugaccess termination_value 0
	
	}

}

proc ::alt_mem_if::gen::uniphy_interfaces::scc_manager {component} {

	if {[string compare -nocase $component "phy"] == 0} {

		set input_phy "Input"
		set output_phy "Output"
	
	} elseif {[string compare -nocase $component "sequencer"] == 0} {

		set input_phy "Output"
		set output_phy "Input"
		
	} elseif {[string compare -nocase $component "scc"] == 0} {

		set input_phy "Output"
		set output_phy "Input"
	
	} else {
		_error "Invalid component specification to determine SCC manager interface"
	}

	add_interface scc conduit end
	
	set_interface_property scc ENABLED true
	
	add_interface_port scc scc_data scc_data $input_phy [get_parameter_value SCC_DATA_WIDTH]
	add_interface_port scc scc_dqs_ena scc_dqs_ena $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port scc scc_dqs_io_ena scc_dqs_io_ena $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port scc scc_dq_ena scc_dq_ena $input_phy [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port scc scc_dm_ena scc_dm_ena $input_phy [get_parameter_value MEM_IF_DM_WIDTH]
	add_interface_port scc capture_strobe_tracking capture_strobe_tracking $output_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]

	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "TRUE"] == 0} {
		add_interface_port scc scc_upd scc_upd $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	} else {
		add_interface_port scc scc_upd scc_upd $input_phy 1
	}

	foreach port_name [list scc_data scc_dqs_ena scc_dqs_io_ena scc_dq_ena scc_dm_ena scc_upd capture_strobe_tracking] {
		set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
	}
		
	if {[string compare -nocase $component "phy"] == 0 || [string compare -nocase $component "sequencer"] == 0} {
		if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "TRUE"] == 0} {
			add_interface_port scc scc_sr_dqsenable_delayctrl scc_sr_dqsenable_delayctrl $input_phy 8
			add_interface_port scc scc_sr_dqsdisablen_delayctrl scc_sr_dqsdisablen_delayctrl $input_phy 8
			add_interface_port scc scc_sr_multirank_delayctrl scc_sr_multirank_delayctrl $input_phy 8

			foreach port_name [list scc_sr_dqsenable_delayctrl scc_sr_dqsdisablen_delayctrl scc_sr_multirank_delayctrl] {
				set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
			}
		}
	} else {
		add_interface_port scc scc_sr_dqsenable_delayctrl scc_sr_dqsenable_delayctrl $input_phy 8
		add_interface_port scc scc_sr_dqsdisablen_delayctrl scc_sr_dqsdisablen_delayctrl $input_phy 8
		add_interface_port scc scc_sr_multirank_delayctrl scc_sr_multirank_delayctrl $input_phy 8
		
		foreach port_name [list scc_sr_dqsenable_delayctrl scc_sr_dqsdisablen_delayctrl scc_sr_multirank_delayctrl] {
			set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
		}
		
		if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "TRUE"] == 0} {
			set_port_property scc_sr_dqsenable_delayctrl termination false
			set_port_property scc_sr_dqsdisablen_delayctrl termination false
			set_port_property scc_sr_multirank_delayctrl termination false
		} else {
			set_port_property scc_sr_dqsenable_delayctrl termination true
			set_port_property scc_sr_dqsenable_delayctrl termination_value 0
			set_port_property scc_sr_dqsdisablen_delayctrl termination true
			set_port_property scc_sr_dqsdisablen_delayctrl termination_value 0
			set_port_property scc_sr_multirank_delayctrl termination true
			set_port_property scc_sr_multirank_delayctrl termination_value 0
		}
	}
}


proc ::alt_mem_if::gen::uniphy_interfaces::afi_init_cal_req {component} {

	if {[string compare -nocase $component "sequencer"] == 0} {

		set input_seq "Input"
		set output_seq "Output"
	
	} elseif {[string compare -nocase $component "controller"] == 0} {

		set input_seq "Output"
		set output_seq "Input"
	
	} else {
		_error "Invalid component specification to determine AFI init/cal request interface"
	}

	add_interface afi_init_cal_req conduit end
	
	set_interface_property afi_init_cal_req ENABLED true
	
	add_interface_port afi_init_cal_req afi_init_req afi_init_req $input_seq 1
	add_interface_port afi_init_cal_req afi_cal_req afi_cal_req $input_seq 1

}


proc ::alt_mem_if::gen::uniphy_interfaces::pll_manager_reconfig {component} {

	if {[string compare -nocase $component "pll"] == 0} {

		set input_pll "Input"
		set output_pll "Output"
	
	} elseif {[string compare -nocase $component "sequencer"] == 0} {

		set input_pll "Output"
		set output_pll "Input"
	
	} else {
		_error "Invalid component specification to determine PLL manager interface"
	}

	add_interface pll_reconfig conduit end	
	set_interface_property pll_reconfig ENABLED true
	
	add_interface_port pll_reconfig phasecounterselect phasecounterselect $input_pll 3
	set_port_property phasecounterselect VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port pll_reconfig phasestep phasestep $input_pll 1
	add_interface_port pll_reconfig phaseupdown phaseupdown $input_pll 1
	add_interface_port pll_reconfig scanclk scanclk $input_pll 1
	add_interface_port pll_reconfig phasedone phasedone $output_pll 1
}


proc ::alt_mem_if::gen::uniphy_interfaces::phy_manager {protocol component {is_qsys_sequencer {1}} {disable_fr_shift_calibration {1}}} {

	if {[string compare -nocase $component "phy"] == 0} {

		set input_phy "Input"
		set output_phy "Output"
	
	} elseif {[string compare -nocase $component "sequencer"] == 0} {

		set input_phy "Output"
		set output_phy "Input"
	
	} else {
		_error "Invalid component specification to determine PHY manager interface"
	}

	add_interface phy conduit end
	
	set_interface_property phy ENABLED true
	
	if {$is_qsys_sequencer} {
		add_interface_port phy phy_clk phy_clk $output_phy 1
		add_interface_port phy phy_reset_n phy_reset_n $output_phy 1
	}
	add_interface_port phy phy_read_latency_counter phy_read_latency_counter $input_phy [get_parameter_value MAX_LATENCY_COUNT_WIDTH]
	if {[string compare -nocase $component "phy"] == 0} {
		add_interface_port phy phy_afi_wlat phy_afi_wlat $input_phy [get_parameter_value AFI_WLAT_WIDTH]
		add_interface_port phy phy_afi_rlat phy_afi_rlat $input_phy [get_parameter_value AFI_RLAT_WIDTH]
		set_port_property phy_afi_wlat VHDL_TYPE STD_LOGIC_VECTOR
		set_port_property phy_afi_rlat VHDL_TYPE STD_LOGIC_VECTOR
	} elseif {[string compare -nocase $component "sequencer"] == 0} {
		add_interface_port phy phy_afi_wlat phy_afi_wlat $input_phy [get_parameter_value AFI_MAX_WRITE_LATENCY_COUNT_WIDTH]
		add_interface_port phy phy_afi_rlat phy_afi_rlat $input_phy [get_parameter_value AFI_MAX_READ_LATENCY_COUNT_WIDTH]
		set_port_property phy_afi_wlat VHDL_TYPE STD_LOGIC_VECTOR
		set_port_property phy_afi_rlat VHDL_TYPE STD_LOGIC_VECTOR
	}
	add_interface_port phy phy_read_increment_vfifo_fr phy_read_increment_vfifo_fr $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port phy phy_read_increment_vfifo_hr phy_read_increment_vfifo_hr $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port phy phy_read_increment_vfifo_qr phy_read_increment_vfifo_qr $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port phy phy_reset_mem_stable phy_reset_mem_stable $input_phy 1
	add_interface_port phy phy_cal_success phy_cal_success $input_phy 1
	add_interface_port phy phy_cal_fail phy_cal_fail $input_phy 1
	if {$is_qsys_sequencer} {
		add_interface_port phy phy_cal_debug_info phy_cal_debug_info $input_phy [get_parameter_value AFI_DEBUG_INFO_WIDTH]
		set_port_property phy_cal_debug_info VHDL_TYPE STD_LOGIC_VECTOR
	}
	add_interface_port phy phy_read_fifo_reset phy_read_fifo_reset $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port phy phy_vfifo_rd_en_override phy_vfifo_rd_en_override $input_phy [get_parameter_value MEM_IF_READ_DQS_WIDTH]
	add_interface_port phy phy_read_fifo_q phy_read_fifo_q $output_phy [get_parameter_value AFI_DQ_WIDTH]
	if { ([string compare -nocase $protocol "DDR3"] == 0) && ([string compare -nocase [get_parameter_value HARD_PHY] "false"] == 0) } {
		add_interface_port phy phy_write_fr_cycle_shifts phy_write_fr_cycle_shifts $input_phy [expr {2*[get_parameter_value MEM_IF_WRITE_DQS_WIDTH]}]
		set_port_property phy_write_fr_cycle_shifts VHDL_TYPE STD_LOGIC_VECTOR
	} elseif {[string compare -nocase $component "sequencer"] == 0} {
		add_interface_port phy phy_write_fr_cycle_shifts phy_write_fr_cycle_shifts $input_phy [expr {2*[get_parameter_value MEM_IF_WRITE_DQS_WIDTH]}]
		set_port_property phy_write_fr_cycle_shifts VHDL_TYPE STD_LOGIC_VECTOR
	
		if {[string compare -nocase $disable_fr_shift_calibration "disable_fr_shift_calibration"] == 0} {	
			set_port_property phy_write_fr_cycle_shifts termination true
			set_port_property phy_write_fr_cycle_shifts termination_value 0
		}
	}
	foreach port_name [list phy_read_latency_counter phy_read_increment_vfifo_fr phy_read_increment_vfifo_hr phy_read_increment_vfifo_qr phy_read_fifo_reset phy_vfifo_rd_en_override phy_read_fifo_q] {
		set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
	}
	


	add_interface calib conduit end
	
	set_interface_property calib ENABLED true
	
	add_interface_port calib calib_skip_steps calib_skip_steps $output_phy [get_parameter_value CALIB_REG_WIDTH]


}


proc ::alt_mem_if::gen::uniphy_interfaces::mux_selector {component} {

	add_interface mux_sel conduit end
	set_interface_property mux_sel ENABLED true
	if {[string compare -nocase $component "afi_mux"] == 0} {
		add_interface_port mux_sel mux_sel mux_sel Input 1
	} elseif {[string compare -nocase $component "sequencer"] == 0} {
		add_interface_port mux_sel phy_mux_sel mux_sel Output 1
	} else {
		_error "Invalid component specification to determine mux_selector interface"
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::sequencer_mux_bridge_control {component} {

	add_interface sequencer_mux_bridge_control conduit end
	set_interface_property sequencer_mux_bridge_control ENABLED true
	if {[string compare -nocase $component "bridge"] == 0} {
		add_interface_port sequencer_mux_bridge_control enable_conversion enable_conversion Input 1
		add_interface_port sequencer_mux_bridge_control shift_addr_cmd shift_addr_cmd Input 1
	} elseif {[string compare -nocase $component "sequencer"] == 0} {
		add_interface_port sequencer_mux_bridge_control enable_conversion enable_conversion Output 1
		add_interface_port sequencer_mux_bridge_control shift_addr_cmd shift_addr_cmd Output 1
	} else {
		_error "Invalid component specification to determine sequencer_mux_bridge_control interface"
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::afi {protocol component {name {afi}} {complete_interface {1}} {add_status {1}} {full_controller_if 0} {pingpongphy_if_flag {0}} } {

	if {[string compare -nocase $component "phy"] == 0} {

		set input_phy "Input"
		set output_phy "Output"
	
	} elseif {[string compare -nocase $component "controller"] == 0} {

		set input_phy "Output"
		set output_phy "Input"
	
	} else {
		_error "Invalid component specification to determine afi interface"
	}

	add_interface ${name} conduit end
	set_interface_property ${name} ENABLED true
	
	if {[string compare -nocase $protocol "DDR2"] == 0 || [string compare -nocase $protocol "DDR3"] == 0 || [string compare -nocase $protocol "LPDDR1"] == 0} {

		add_interface_port ${name} ${name}_addr afi_addr $input_phy [get_parameter_value AFI_ADDR_WIDTH]
		add_interface_port ${name} ${name}_ba afi_ba $input_phy [get_parameter_value AFI_BANKADDR_WIDTH]
		add_interface_port ${name} ${name}_ras_n afi_ras_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		add_interface_port ${name} ${name}_we_n afi_we_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		add_interface_port ${name} ${name}_cas_n afi_cas_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
	
		if {[string compare -nocase $protocol "LPDDR1"] != 0} {
			if {$pingpongphy_if_flag == 1 || $pingpongphy_if_flag == 3} {
				_dprint 1 "miliu: Creating AFI half-width ODT for Ping Pong PHY"
				add_interface_port ${name} ${name}_odt afi_odt $input_phy [expr {[get_parameter_value AFI_ODT_WIDTH]/2}]
			} else {
				add_interface_port ${name} ${name}_odt afi_odt $input_phy [get_parameter_value AFI_ODT_WIDTH]
			}
		}

		if {$pingpongphy_if_flag == 1} {
			_dprint 1 "miliu: Creating AFI half IF for Ping Pong PHY"
			add_interface_port ${name} ${name}_cke afi_cke $input_phy [expr {[get_parameter_value AFI_CLK_EN_WIDTH]/2}]
			add_interface_port ${name} ${name}_cs_n afi_cs_n $input_phy [expr {[get_parameter_value AFI_CS_WIDTH]/2}]
			add_interface_port ${name} ${name}_dqs_burst afi_dqs_burst $input_phy [expr {[get_parameter_value AFI_WRITE_DQS_WIDTH]/2}]
			add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy [expr {[get_parameter_value AFI_WRITE_DQS_WIDTH]/2}]
			add_interface_port ${name} ${name}_wdata afi_wdata $input_phy [expr {[get_parameter_value AFI_DQ_WIDTH]/2}]
			add_interface_port ${name} ${name}_dm afi_dm $input_phy [expr {[get_parameter_value AFI_DM_WIDTH]/2}]
			add_interface_port ${name} ${name}_rdata afi_rdata $output_phy [expr {[get_parameter_value AFI_DQ_WIDTH]/2}]
		} elseif {$pingpongphy_if_flag == 3} {
			_dprint 1 "miliu: Creating AFI half-width CS/CKE Seq to AFI_mux IF for Ping Pong PHY"
			add_interface_port ${name} ${name}_cke afi_cke $input_phy [expr {[get_parameter_value AFI_CLK_EN_WIDTH]/2}]

			if {[get_parameter_value MRS_MIRROR_PING_PONG_ATSO]} {
				add_interface_port ${name} ${name}_cs_n afi_cs_n $input_phy [expr {[get_parameter_value AFI_CS_WIDTH]}]
			} else {
				add_interface_port ${name} ${name}_cs_n afi_cs_n $input_phy [expr {[get_parameter_value AFI_CS_WIDTH]/2}]
			}

			add_interface_port ${name} ${name}_dqs_burst afi_dqs_burst $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
			add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
			add_interface_port ${name} ${name}_wdata afi_wdata $input_phy [get_parameter_value AFI_DQ_WIDTH]
			add_interface_port ${name} ${name}_dm afi_dm $input_phy [get_parameter_value AFI_DM_WIDTH]
			add_interface_port ${name} ${name}_rdata afi_rdata $output_phy [get_parameter_value AFI_DQ_WIDTH]
		} else {
			add_interface_port ${name} ${name}_cke afi_cke $input_phy [get_parameter_value AFI_CLK_EN_WIDTH]
			add_interface_port ${name} ${name}_cs_n afi_cs_n $input_phy [expr {[get_parameter_value AFI_CS_WIDTH]}]
			add_interface_port ${name} ${name}_dqs_burst afi_dqs_burst $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
			add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
			add_interface_port ${name} ${name}_wdata afi_wdata $input_phy [get_parameter_value AFI_DQ_WIDTH]
			add_interface_port ${name} ${name}_dm afi_dm $input_phy [get_parameter_value AFI_DM_WIDTH]
			add_interface_port ${name} ${name}_rdata afi_rdata $output_phy [get_parameter_value AFI_DQ_WIDTH]
		}

		if {[string compare -nocase $protocol "DDR3"] == 0} {
			add_interface_port ${name} ${name}_rst_n afi_rst_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		}

		if {$full_controller_if} {
			add_interface_port ${name} ${name}_mem_clk_disable afi_mem_clk_disable $input_phy [get_parameter_value AFI_CLK_PAIR_COUNT]
			add_interface_port ${name} ${name}_init_req afi_init_req $input_phy 1
			add_interface_port ${name} ${name}_cal_req afi_cal_req $input_phy 1
			if {[string compare -nocase $protocol "DDR3"] == 0} {
				add_interface_port ${name} ${name}_seq_busy afi_seq_busy $output_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
				add_interface_port ${name} ${name}_ctl_refresh_done afi_ctl_refresh_done $input_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
				add_interface_port ${name} ${name}_ctl_long_idle afi_ctl_long_idle $input_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]

				set_port_property ${name}_seq_busy VHDL_TYPE STD_LOGIC_VECTOR
				set_port_property ${name}_ctl_refresh_done VHDL_TYPE STD_LOGIC_VECTOR
				set_port_property ${name}_ctl_long_idle VHDL_TYPE STD_LOGIC_VECTOR
				if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
					set_port_property ${name}_seq_busy termination false
					set_port_property ${name}_ctl_refresh_done termination false
					set_port_property ${name}_ctl_long_idle termination false
				} else {
					set_port_property ${name}_seq_busy termination true
					set_port_property ${name}_seq_busy termination_value 0
					set_port_property ${name}_ctl_refresh_done termination true
					set_port_property ${name}_ctl_refresh_done termination_value 0
					set_port_property ${name}_ctl_long_idle termination true
					set_port_property ${name}_ctl_long_idle termination_value 0
				}
			}
		}
		add_interface_port ${name} ${name}_rdata_en afi_rdata_en $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_en_full afi_rdata_en_full $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_valid afi_rdata_valid $output_phy [get_parameter_value AFI_RATE_RATIO]
		
		if {$pingpongphy_if_flag == 2} {
			add_interface_port ${name} ${name}_rdata_en_1t afi_rdata_en_1t $input_phy [get_parameter_value AFI_RATE_RATIO]
			add_interface_port ${name} ${name}_rdata_en_full_1t afi_rdata_en_full_1t $input_phy [get_parameter_value AFI_RATE_RATIO]
			add_interface_port ${name} ${name}_rdata_valid_1t afi_rdata_valid_1t $output_phy [get_parameter_value AFI_RATE_RATIO]
		}
		

		if {[string compare -nocase $protocol "DDR3"] == 0 &&
			[string compare -nocase $component "controller"] == 0 && 
			[string compare -nocase $name "afi"] == 0 && 
			$complete_interface && $full_controller_if} {
			
			add_interface_port ${name} ${name}_rrank afi_rrank $input_phy [get_parameter_value AFI_RRANK_WIDTH]
			add_interface_port ${name} ${name}_wrank afi_wrank $input_phy [get_parameter_value AFI_WRANK_WIDTH]
			
			if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "TRUE"] == 0} {
				set_port_property afi_rrank termination false	
				set_port_property afi_wrank termination false	
			} else {
				set_port_property afi_rrank termination true
				set_port_property afi_rrank termination_value 0
				
				set_port_property afi_wrank termination true
				set_port_property afi_wrank termination_value 0
			}
		} else {
			if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "TRUE"] == 0} {
				if {$pingpongphy_if_flag == 1} { 
					add_interface_port ${name} ${name}_rrank afi_rrank $input_phy [expr {[get_parameter_value AFI_RRANK_WIDTH]/2}]
					add_interface_port ${name} ${name}_wrank afi_wrank $input_phy [expr {[get_parameter_value AFI_WRANK_WIDTH]/2}]
				} else {
					add_interface_port ${name} ${name}_rrank afi_rrank $input_phy [get_parameter_value AFI_RRANK_WIDTH]
					add_interface_port ${name} ${name}_wrank afi_wrank $input_phy [get_parameter_value AFI_WRANK_WIDTH]
				}
			}
		}

	} elseif {[string compare -nocase $protocol "LPDDR2"] == 0} {

		add_interface_port ${name} ${name}_addr afi_addr $input_phy [get_parameter_value AFI_ADDR_WIDTH]
		add_interface_port ${name} ${name}_cke afi_cke $input_phy [get_parameter_value AFI_CS_WIDTH]
		add_interface_port ${name} ${name}_cs_n afi_cs_n $input_phy [get_parameter_value AFI_CS_WIDTH]
		add_interface_port ${name} ${name}_dqs_burst afi_dqs_burst $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
		add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
		add_interface_port ${name} ${name}_wdata afi_wdata $input_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_dm afi_dm $input_phy [get_parameter_value AFI_DM_WIDTH]
		add_interface_port ${name} ${name}_rdata afi_rdata $output_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_rdata_en afi_rdata_en $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_en_full afi_rdata_en_full $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_valid afi_rdata_valid $output_phy [get_parameter_value AFI_RATE_RATIO]
		if {$full_controller_if} {
			add_interface_port ${name} ${name}_mem_clk_disable afi_mem_clk_disable $input_phy [get_parameter_value AFI_CLK_PAIR_COUNT]
			add_interface_port ${name} ${name}_init_req afi_init_req $input_phy 1
			add_interface_port ${name} ${name}_cal_req afi_cal_req $input_phy 1
			add_interface_port ${name} ${name}_seq_busy afi_seq_busy $output_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
			set_port_property ${name}_seq_busy VHDL_TYPE STD_LOGIC_VECTOR
			add_interface_port ${name} ${name}_ctl_refresh_done afi_ctl_refresh_done $input_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
			set_port_property ${name}_ctl_refresh_done VHDL_TYPE STD_LOGIC_VECTOR
			add_interface_port ${name} ${name}_ctl_long_idle afi_ctl_long_idle $input_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
			set_port_property ${name}_ctl_long_idle VHDL_TYPE STD_LOGIC_VECTOR
			if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
				set_port_property ${name}_seq_busy termination false
				set_port_property ${name}_ctl_refresh_done termination false
				set_port_property ${name}_ctl_long_idle termination false
			} else {
				set_port_property ${name}_seq_busy termination true
				set_port_property ${name}_seq_busy termination_value 0
				set_port_property ${name}_ctl_refresh_done termination true
				set_port_property ${name}_ctl_refresh_done termination_value 0
				set_port_property ${name}_ctl_long_idle termination true
				set_port_property ${name}_ctl_long_idle termination_value 0
			}
		}

	} elseif {[string compare -nocase $protocol "RLDRAMII"] == 0 || [string compare -nocase $protocol "RLDRAM3"] == 0} {

		add_interface_port ${name} ${name}_addr afi_addr $input_phy [get_parameter_value AFI_ADDR_WIDTH]
		add_interface_port ${name} ${name}_ba afi_ba $input_phy [get_parameter_value AFI_BANKADDR_WIDTH]
		add_interface_port ${name} ${name}_cs_n afi_cs_n $input_phy [get_parameter_value AFI_CS_WIDTH]
		add_interface_port ${name} ${name}_we_n afi_we_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		add_interface_port ${name} ${name}_ref_n afi_ref_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
		add_interface_port ${name} ${name}_wdata afi_wdata $input_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_dm afi_dm $input_phy [get_parameter_value AFI_DM_WIDTH]
		add_interface_port ${name} ${name}_rdata afi_rdata $output_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_rdata_en afi_rdata_en $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_en_full afi_rdata_en_full $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_valid afi_rdata_valid $output_phy [get_parameter_value AFI_RATE_RATIO]
		
		if {[string compare -nocase $protocol "RLDRAM3"] == 0} {
			add_interface_port ${name} ${name}_rst_n afi_rst_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		}

	} elseif {[string compare -nocase $protocol "QDRII"] == 0} {

		add_interface_port ${name} ${name}_addr afi_addr $input_phy [get_parameter_value AFI_ADDR_WIDTH]
		add_interface_port ${name} ${name}_wps_n afi_wps_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		add_interface_port ${name} ${name}_rps_n afi_rps_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		if {[string compare -nocase $name "afi"] == 0 && $complete_interface} {
		} else {
			add_interface_port ${name} ${name}_doff_n afi_doff_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		}
		add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
		add_interface_port ${name} ${name}_wdata afi_wdata $input_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_bws_n afi_bws_n $input_phy [get_parameter_value AFI_DM_WIDTH]
		add_interface_port ${name} ${name}_rdata afi_rdata $output_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_rdata_en afi_rdata_en $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_en_full afi_rdata_en_full $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_valid afi_rdata_valid $output_phy [get_parameter_value AFI_RATE_RATIO]

	} elseif {[string compare -nocase $protocol "DDRIISRAM"] == 0} {

		add_interface_port ${name} ${name}_addr afi_addr $input_phy [get_parameter_value AFI_ADDR_WIDTH]
		add_interface_port ${name} ${name}_ld_n afi_ld_n $input_phy [get_parameter_value AFI_CS_WIDTH]
		add_interface_port ${name} ${name}_rw_n afi_rw_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		if {[string compare -nocase $name "afi"] == 0 && $complete_interface} {
		} else {
			add_interface_port ${name} ${name}_doff_n afi_doff_n $input_phy [get_parameter_value AFI_CONTROL_WIDTH]
		}
		add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy [get_parameter_value AFI_WRITE_DQS_WIDTH]
		add_interface_port ${name} ${name}_wdata afi_wdata $input_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_bws_n afi_bws_n $input_phy [get_parameter_value AFI_DM_WIDTH]
		add_interface_port ${name} ${name}_rdata afi_rdata $output_phy [get_parameter_value AFI_DQ_WIDTH]
		add_interface_port ${name} ${name}_rdata_en afi_rdata_en $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_en_full afi_rdata_en_full $input_phy [get_parameter_value AFI_RATE_RATIO]
		add_interface_port ${name} ${name}_rdata_valid afi_rdata_valid $output_phy [get_parameter_value AFI_RATE_RATIO]

	} elseif {[string compare -nocase $protocol "HARD"] == 0} {

		add_interface_port ${name} ${name}_addr afi_addr $input_phy 20
		add_interface_port ${name} ${name}_ba afi_ba $input_phy 3
		add_interface_port ${name} ${name}_cke afi_cke $input_phy 2
		add_interface_port ${name} ${name}_cs_n afi_cs_n $input_phy 2
		add_interface_port ${name} ${name}_ras_n afi_ras_n $input_phy 1
		add_interface_port ${name} ${name}_we_n afi_we_n $input_phy 1
		add_interface_port ${name} ${name}_cas_n afi_cas_n $input_phy 1
		add_interface_port ${name} ${name}_rst_n afi_rst_n $input_phy 1
		add_interface_port ${name} ${name}_odt afi_odt $input_phy 2
		if {$full_controller_if} {
			add_interface_port ${name} ${name}_mem_clk_disable afi_mem_clk_disable $input_phy [get_parameter_value AFI_CLK_PAIR_COUNT]
			add_interface_port ${name} ${name}_init_req afi_init_req $input_phy 1
			add_interface_port ${name} ${name}_cal_req afi_cal_req $input_phy 1
			add_interface_port ${name} ${name}_seq_busy afi_seq_busy $output_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
			set_port_property ${name}_seq_busy VHDL_TYPE STD_LOGIC_VECTOR
			add_interface_port ${name} ${name}_ctl_refresh_done afi_ctl_refresh_done $input_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
			set_port_property ${name}_ctl_refresh_done VHDL_TYPE STD_LOGIC_VECTOR
			add_interface_port ${name} ${name}_ctl_long_idle afi_ctl_long_idle $input_phy [get_parameter_value MEM_IF_NUMBER_OF_RANKS]
			set_port_property ${name}_ctl_long_idle VHDL_TYPE STD_LOGIC_VECTOR
			if {[string compare -nocase [get_parameter_value USE_DQS_TRACKING] "true"] == 0} {
				set_port_property ${name}_seq_busy termination false
				set_port_property ${name}_ctl_refresh_done termination false
				set_port_property ${name}_ctl_long_idle termination false
			} else {
				set_port_property ${name}_seq_busy termination true
				set_port_property ${name}_seq_busy termination_value 0
				set_port_property ${name}_ctl_refresh_done termination true
				set_port_property ${name}_ctl_refresh_done termination_value 0
				set_port_property ${name}_ctl_long_idle termination true
				set_port_property ${name}_ctl_long_idle termination_value 0
			}
		}
		add_interface_port ${name} ${name}_dqs_burst afi_dqs_burst $input_phy 5
		add_interface_port ${name} ${name}_wdata_valid afi_wdata_valid $input_phy 5
		add_interface_port ${name} ${name}_wdata afi_wdata $input_phy 80
		add_interface_port ${name} ${name}_dm afi_dm $input_phy 10
		add_interface_port ${name} ${name}_rdata afi_rdata $output_phy 80
		add_interface_port ${name} ${name}_rdata_en afi_rdata_en $input_phy 5
		add_interface_port ${name} ${name}_rdata_en_full afi_rdata_en_full $input_phy 5
		add_interface_port ${name} ${name}_rdata_valid afi_rdata_valid $output_phy 1
		add_interface_port ${name} ${name}_wlat afi_wlat $output_phy 4
		add_interface_port ${name} ${name}_rlat afi_rlat $output_phy 5
		add_interface_port ${name} ${name}_cal_success afi_cal_success $output_phy 1
		add_interface_port ${name} ${name}_cal_fail afi_cal_fail $output_phy 1

	}




	if {$add_status && [string compare -nocase $protocol "HARD"] != 0} {
		add_interface_port ${name} ${name}_cal_success afi_cal_success $output_phy 1
		add_interface_port ${name} ${name}_cal_fail afi_cal_fail $output_phy 1
		if {[string compare -nocase $protocol "DDR2"] == 0 ||
		    [string compare -nocase $protocol "DDR3"] == 0 ||
		    [string compare -nocase $protocol "RLDRAM3"] == 0 ||
		    [string compare -nocase $protocol "LPDDR2"] == 0 ||
		    [string compare -nocase $protocol "LPDDR1"] == 0} {
			add_interface_port ${name} ${name}_wlat afi_wlat $output_phy [get_parameter_value AFI_WLAT_WIDTH]
			add_interface_port ${name} ${name}_rlat afi_rlat $output_phy [get_parameter_value AFI_RLAT_WIDTH]
		}
	}


	foreach port_name [get_interface_ports ${name}] {
		if {[regexp -nocase "${name}_cal_success|${name}_cal_fail|${name}_cal_req|${name}_init_req" $port_name match] == 0} {
			set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
		}
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::csr_slave {component} {


	set csr_enabled 0

	if {[string compare -nocase $component "phy"] == 0} {

		if {[string compare -nocase [get_parameter_value PHY_CSR_ENABLED] "true"] == 0} {
			set csr_enabled 1

			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {

				add_interface csr_clk clock end
				set_interface_property csr_clk ENABLED true
				add_interface_port csr_clk csr_clk clk Input 1

				add_interface csr_reset_n reset end
				set_interface_property csr_reset_n associatedClock csr_clk
				set_interface_property csr_reset_n synchronousEdges DEASSERT
				set_interface_property csr_reset_n ENABLED true
				add_interface_port csr_reset_n csr_reset_n reset_n Input 1
			}

		} else {
			return 1
		}
	
	} elseif {[string compare -nocase $component "controller"] == 0} {

		if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
			set csr_enabled 1
		}
	
	} else {
		_error "Invalid component specification to the csr_slave"
	}

        if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0 &&
            ([string compare -nocase $component "controller"] == 0 ||
             [string compare -nocase $component "phy"] == 0)} {
                set csr_associatedclock csr_clk
                set csr_associatedreset csr_reset_n
        } else {
                set csr_associatedclock afi_clk
                set csr_associatedreset afi_reset
        }

	add_interface csr avalon slave
	set_interface_property csr ENABLED true
	set_interface_property csr addressUnits WORDS
	set_interface_property csr associatedClock $csr_associatedclock
	set_interface_property csr associatedReset $csr_associatedreset
	set_interface_property csr bitsPerSymbol 8
	set_interface_property csr maximumPendingReadTransactions 4
	set_interface_assignment csr debug.visible true

	add_interface_port csr csr_write_req write Input 1
	add_interface_port csr csr_read_req read Input 1
	add_interface_port csr csr_waitrequest waitrequest Output 1
	add_interface_port csr csr_addr address Input [get_parameter_value CSR_ADDR_WIDTH]
	add_interface_port csr csr_be byteenable Input [expr {[get_parameter_value CSR_DATA_WIDTH] / 8}]
	set_port_property csr_be VHDL_TYPE STD_LOGIC_VECTOR
	add_interface_port csr csr_wdata writedata Input [get_parameter_value CSR_DATA_WIDTH]
	add_interface_port csr csr_rdata readdata Output [get_parameter_value CSR_DATA_WIDTH]
	add_interface_port csr csr_rdata_valid readdatavalid Output 1

	::alt_mem_if::util::hwtcl_utils::set_interface_termination csr $csr_enabled
}


proc ::alt_mem_if::gen::uniphy_interfaces::emif_csr_connections {controller phy} {
	
	set use_bridge 0
	set use_jtag_master 0

	set jtag_afi_reset "afi_reset.out_reset_1"

	if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "EXPORT"] == 0} {
			set use_bridge 1
			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
					set bridge_afi_clk "csr_clk.out_clk"
					set bridge_afi_reset "csr_reset_n.out_reset"
			} else {
					set bridge_afi_clk "afi_clk.out_clk_1"
					set bridge_afi_reset "afi_reset.out_reset_1"
			}
		} elseif {[string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "INTERNAL_JTAG"] == 0} {
			set use_jtag_master 1
			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				set jtag_afi_clk "csr_clk.out_clk"
				set jtag_afi_reset "csr_reset_n.out_reset"
			} else {
				set jtag_afi_clk "afi_clk.out_clk_1"
			}
		} elseif {[string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "SHARED"] == 0} {
			set use_bridge 1
			set use_jtag_master 1
			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				set bridge_afi_clk "csr_clk.out_clk"
				set bridge_afi_reset "csr_reset_n.out_reset"
				set jtag_afi_clk "csr_clk.out_clk"
				set jtag_afi_reset "csr_reset_n.out_reset"
			} else {
				set bridge_afi_clk "afi_clk.out_clk_1"
				set bridge_afi_reset "afi_reset.out_reset_1"
				set jtag_afi_clk "afi_clk.out_clk_2"
			}
		}
	}

	if {$use_jtag_master} {
		set CSR_MASTER if_csr_m0
		add_instance $CSR_MASTER altera_jtag_avalon_master 

		set_instance_parameter $CSR_MASTER USE_PLI "0"
		set_instance_parameter $CSR_MASTER PLI_PORT "50000"

		set byte_address_width [expr {8 + int(log(32/8)/log(2))}]

		add_connection "${jtag_afi_clk}/${CSR_MASTER}.clk"
		add_connection "${jtag_afi_reset}/${CSR_MASTER}.clk_reset"

		add_connection "${CSR_MASTER}.master/${phy}.csr"
		set_connection_parameter_value "${CSR_MASTER}.master/${phy}.csr" arbitrationPriority "1"
		set_connection_parameter_value "${CSR_MASTER}.master/${phy}.csr" baseAddress "0x0000"

		if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
			add_connection "${CSR_MASTER}.master/${controller}.csr"
			set_connection_parameter_value "${CSR_MASTER}.master/${controller}.csr" arbitrationPriority "1"
			set_connection_parameter_value "${CSR_MASTER}.master/${controller}.csr" baseAddress [expr {int(pow(2,$byte_address_width))}]
		}
	}

	if {$use_bridge} {


		set csr_byte_addr_width [expr {8 + int(log(32/8)/log(2))}]

		set CSR_BRIDGE csr_bridge
		add_instance ${CSR_BRIDGE} altera_mem_if_simple_avalon_mm_bridge 

		set_instance_parameter ${CSR_BRIDGE} DATA_WIDTH 32
		set_instance_parameter ${CSR_BRIDGE} SYMBOL_WIDTH 8
		set_instance_parameter ${CSR_BRIDGE} ADDRESS_WIDTH 16
		set_instance_parameter ${CSR_BRIDGE} ADDRESS_UNITS "WORDS"
		set_instance_parameter ${CSR_BRIDGE} USE_BYTEENABLE 1
		set_instance_parameter ${CSR_BRIDGE} USE_READDATAVALID 1

		add_connection "${bridge_afi_clk}/${CSR_BRIDGE}.clk"
		add_connection "${bridge_afi_reset}/${CSR_BRIDGE}.reset"

		add_connection "${CSR_BRIDGE}.m0/${phy}.csr"
		set_connection_parameter_value "${CSR_BRIDGE}.m0/${phy}.csr" baseAddress "0x0"

		if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {
			add_connection "${CSR_BRIDGE}.m0/${controller}.csr"
			set_connection_parameter_value "${CSR_BRIDGE}.m0/${controller}.csr" baseAddress [expr {int(pow(2,$csr_byte_addr_width))}]
		}

		add_interface csr avalon end
		set_interface_property csr export_of ${CSR_BRIDGE}.s0
        set_interface_assignment csr debug.visible true

		set_interface_property csr PORT_NAME_MAP [list \
			csr_addr s0_address \
			csr_write_req s0_write \
			csr_wdata s0_writedata \
			csr_read_req s0_read \
			csr_rdata s0_readdata \
			csr_rdata_valid s0_readdatavalid \
			csr_waitrequest s0_waitrequest \
			csr_be s0_byteenable \
		]

	}

}

proc ::alt_mem_if::gen::uniphy_interfaces::add_core_debug_interface {seq} {
	
	set use_bridge 0
	set use_jtag_master 0

	set jtag_afi_reset "global_reset.out_reset"

	if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
			if {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "EXPORT"] == 0} {
				set use_bridge 1
				set bridge_afi_clk "seq_debug_clk.out_clk"
				set bridge_afi_reset "seq_debug_reset.out_reset"
			} elseif {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "INTERNAL_JTAG"] == 0} {
				set use_jtag_master 1
				set jtag_afi_clk "seq_debug_clk.out_clk"
			} elseif {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "SHARED"] == 0} {
				set use_bridge 1
				set use_jtag_master 1
				set bridge_afi_clk "seq_debug_clk.out_clk"
				set bridge_afi_reset "seq_debug_reset.out_reset"
				set jtag_afi_clk "seq_debug_clk.out_clk_1"
			}
		} else {
			if {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "EXPORT"] == 0} {
				set use_bridge 1
				set bridge_afi_clk "afi_clk.out_clk_1"
				set bridge_afi_reset "afi_reset.out_reset_1"
			} elseif {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "INTERNAL_JTAG"] == 0} {
				set use_jtag_master 1
				set jtag_afi_clk "afi_clk.out_clk_1"
			} elseif {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "SHARED"] == 0} {
				set use_bridge 1
				set use_jtag_master 1
				set bridge_afi_clk "afi_clk.out_clk_1"
				set bridge_afi_reset "afi_reset.out_reset_1"
				set jtag_afi_clk "afi_clk.out_clk_2"
			}
		}
	}

	_dprint 1 "use_bridge: $use_bridge use_jtag_master: $use_jtag_master"

	if {$use_jtag_master} {
		set SEQ_MASTER seq_jtag
		add_instance $SEQ_MASTER altera_jtag_avalon_master 

		set_instance_parameter $SEQ_MASTER USE_PLI "0"
		set_instance_parameter $SEQ_MASTER PLI_PORT "50000"

		add_connection "${jtag_afi_clk}/${SEQ_MASTER}.clk"
		add_connection "${jtag_afi_reset}/${SEQ_MASTER}.clk_reset"

		add_connection "${SEQ_MASTER}.master/${seq}.seq_debug"
		set_connection_parameter_value "${SEQ_MASTER}.master/${seq}.seq_debug" arbitrationPriority "1"
			set_connection_parameter_value "${SEQ_MASTER}.master/${seq}.seq_debug" baseAddress "0x0000"

	}

	if {$use_bridge} {

		set SEQ_BRIDGE seq_bridge
		add_instance ${SEQ_BRIDGE} altera_mem_if_simple_avalon_mm_bridge 

		set_instance_parameter ${SEQ_BRIDGE} DATA_WIDTH 32
		set_instance_parameter ${SEQ_BRIDGE} SYMBOL_WIDTH 8
		set_instance_parameter ${SEQ_BRIDGE} MASTER_ADDRESS_WIDTH 32
		set_instance_parameter ${SEQ_BRIDGE} SLAVE_ADDRESS_WIDTH 20
		set_instance_parameter ${SEQ_BRIDGE} ADDRESS_UNITS "SYMBOLS"
		set_instance_parameter ${SEQ_BRIDGE} USE_BYTEENABLE 1
		set_instance_parameter ${SEQ_BRIDGE} USE_READDATAVALID 1

		add_connection "${bridge_afi_clk}/${SEQ_BRIDGE}.clk"
		add_connection "${bridge_afi_reset}/${SEQ_BRIDGE}.reset"

		add_connection "${SEQ_BRIDGE}.m0/${seq}.seq_debug"
		set_connection_parameter_value "${SEQ_BRIDGE}.m0/${seq}.seq_debug" baseAddress "0x0"

		add_interface seq_debug avalon end
		set_interface_property seq_debug export_of ${SEQ_BRIDGE}.s0
        set_interface_assignment seq_debug debug.visible true

		set_interface_property seq_debug PORT_NAME_MAP [list \
			seq_debug_addr s0_address \
			seq_debug_write_req s0_write \
			seq_debug_wdata s0_writedata \
			seq_debug_read_req s0_read \
			seq_debug_rdata s0_readdata \
			seq_debug_rdata_valid s0_readdatavalid \
			seq_debug_waitrequest s0_waitrequest \
			seq_debug_be s0_byteenable \
		]

	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::add_external_seq_debug_nios {EMIF} {

	_dprint 1 "Adding external Nios for sequencer debug"

	set CLK_BRIDGE clk_bridge
	add_instance ${CLK_BRIDGE} altera_avalon_mm_clock_crossing_bridge
	set_instance_parameter ${CLK_BRIDGE} DATA_WIDTH 32
	set_instance_parameter ${CLK_BRIDGE} SYMBOL_WIDTH 8
	set_instance_parameter ${CLK_BRIDGE} ADDRESS_WIDTH 20
	set_instance_parameter ${CLK_BRIDGE} ADDRESS_UNITS "SYMBOLS"

	set CLK ext_nios_clk
	add_instance ${CLK} clock_source
	set_instance_parameter ${CLK} clockFrequency [expr [get_parameter_value REF_CLK_FREQ] * 1000000]
	set_instance_parameter ${CLK} clockFrequencyKnown true

	set NIOS_MEM ext_nios_mem
	add_instance ${NIOS_MEM} altera_avalon_onchip_memory2
	set_instance_parameter ${NIOS_MEM} dataWidth 32
	set_instance_parameter ${NIOS_MEM} memorySize 65536

	set NIOS ext_nios
	add_instance ${NIOS} altera_nios2_qsys
	set_instance_parameter ${NIOS} resetSlave "ext_nios_mem.s1"
	set_instance_parameter ${NIOS} exceptionSlave "ext_nios_mem.s1"
	set_instance_parameter ${NIOS} breakSlave "${NIOS}.jtag_debug_module"
	set_instance_parameter ${NIOS} resetOffset 0
	set_instance_parameter ${NIOS} exceptionOffset 32
	set_instance_parameter ${NIOS} breakOffset 32

	set JTAG_UART jtag_uart
	add_instance ${JTAG_UART} altera_avalon_jtag_uart

	add_connection "pll_ref_clk.out_clk/${CLK}.clk_in"
	add_connection "soft_reset.out_reset/${CLK}.clk_in_reset"

	add_connection "${EMIF}.afi_clk/${CLK_BRIDGE}.m0_clk"
	add_connection "${EMIF}.afi_reset/${CLK_BRIDGE}.m0_reset"
	add_connection "${CLK_BRIDGE}.m0/${EMIF}.seq_debug"
	add_connection "${CLK}.clk/${CLK_BRIDGE}.s0_clk"
	add_connection "${CLK}.clk_reset/${CLK_BRIDGE}.s0_reset"
	add_connection "${NIOS}.data_master/${CLK_BRIDGE}.s0"
	set_connection_parameter_value "${NIOS}.data_master/${CLK_BRIDGE}.s0" baseAddress "0x0"
	add_connection "${CLK}.clk/${NIOS}.clk"
	add_connection "${CLK}.clk_reset/${NIOS}.reset_n"
	add_connection "${CLK}.clk/${JTAG_UART}.clk"
	add_connection "${CLK}.clk_reset/${JTAG_UART}.reset"
	add_connection "${NIOS}.data_master/${JTAG_UART}.avalon_jtag_slave"
	set_connection_parameter_value "${NIOS}.data_master/${JTAG_UART}.avalon_jtag_slave" baseAddress "0x01021000"
	add_connection "${NIOS}.d_irq/${JTAG_UART}.irq"
	set_connection_parameter_value "${NIOS}.d_irq/${JTAG_UART}.irq" irqNumber 16

	add_connection "${CLK}.clk/${NIOS_MEM}.clk1"
	add_connection "${CLK}.clk_reset/${NIOS_MEM}.reset1"
	add_connection "${NIOS}.instruction_master/${NIOS_MEM}.s1"
	set_connection_parameter_value "${NIOS}.instruction_master/${NIOS_MEM}.s1" baseAddress "0x01010000"
	add_connection "${NIOS}.data_master/${NIOS_MEM}.s1"
	set_connection_parameter_value "${NIOS}.data_master/${NIOS_MEM}.s1" baseAddress "0x01010000"
	
	add_connection "${NIOS}.instruction_master/${NIOS}.jtag_debug_module"
	set_connection_parameter_value "${NIOS}.instruction_master/${NIOS}.jtag_debug_module" baseAddress "0x01020800"
	add_connection "${NIOS}.data_master/${NIOS}.jtag_debug_module"
	set_connection_parameter_value "${NIOS}.data_master/${NIOS}.jtag_debug_module" baseAddress "0x01020800"
	
}

proc ::alt_mem_if::gen::uniphy_interfaces::basic_sequencer_manager_interfaces {{use_be 0}} {

	_dprint 1 "Creating default QSYS manager interfaces"

	add_interface avl_clk clock end
	set_interface_property avl_clk ENABLED true
	add_interface_port avl_clk avl_clk clk Input 1

	add_interface avl_reset reset end
	set_interface_property avl_reset associatedClock avl_clk
	set_interface_property avl_reset synchronousEdges DEASSERT
	set_interface_property avl_reset ENABLED true
	add_interface_port avl_reset avl_reset_n reset_n Input 1

	::alt_mem_if::gen::uniphy_interfaces::qsys_sequencer_avl "slave" $use_be

}


proc ::alt_mem_if::gen::uniphy_interfaces::qsys_sequencer_avl {component {use_be 0} {name "avl"}} {

	if {[string compare -nocase $component "slave"] == 0} {

		set input_slave "Input"
		set output_slave "Output"
		set avalon_dir "end"
	
	} elseif {[string compare -nocase $component "master"] == 0} {

		set input_slave "Output"
		set output_slave "Input"
		set avalon_dir "start"
	
	} else {
		_error "Invalid component specification to determine afi interface"
	}


	add_interface ${name} avalon $avalon_dir
	set_interface_property ${name} addressUnits WORDS
	set_interface_property ${name} associatedClock avl_clk
	set_interface_property ${name} associatedReset avl_reset
	if {$use_be} {
		set_interface_property ${name} bitsPerSymbol [get_parameter_value AVL_SYMBOL_WIDTH]
	} else {
		set_interface_property ${name} bitsPerSymbol 8
	}
	set_interface_property ${name} burstOnBurstBoundariesOnly false
	set_interface_property ${name} burstcountUnits WORDS
	set_interface_property ${name} constantBurstBehavior true
	
	set_interface_property ${name} ENABLED true
	
	set is_sequencer [regexp -nocase {qseq$} [get_module_property NAME]]
	set is_hard_phy_core [regexp -nocase {hard_phy_core$} [get_module_property NAME]]
	if { $is_sequencer || $is_hard_phy_core } {
		set is_hard_phy [string compare -nocase [get_parameter_value HARD_PHY ] "true"]
		if { $is_hard_phy == 0 } {
			add_interface_port ${name} ${name}_address address $input_slave 16
		} else {
			add_interface_port ${name} ${name}_address address $input_slave [get_parameter_value AVL_ADDR_WIDTH]
		}
	} else {
		add_interface_port ${name} ${name}_address address $input_slave [get_parameter_value AVL_ADDR_WIDTH]
	}
	add_interface_port ${name} ${name}_write write $input_slave 1
	add_interface_port ${name} ${name}_writedata writedata $input_slave [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port ${name} ${name}_read read $input_slave 1
	add_interface_port ${name} ${name}_readdata readdata $output_slave [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port ${name} ${name}_waitrequest waitrequest $output_slave 1
	if {$use_be} {
		add_interface_port ${name} ${name}_be byteenable $input_slave [get_parameter_value AVL_NUM_SYMBOLS]
	}
}



proc ::alt_mem_if::gen::uniphy_interfaces::qsys_sequencer_mmr {component {use_be 0} {name "mmr_avl"}} {

	if {[string compare -nocase $component "slave"] == 0} {

		set input_slave "Input"
		set output_slave "Output"
		set avalon_dir "end"
	
	} elseif {[string compare -nocase $component "master"] == 0} {

		set input_slave "Output"
		set output_slave "Input"
		set avalon_dir "start"
	
	} else {
		_error "Invalid component specification to determine afi interface"
	}


	add_interface ${name} avalon $avalon_dir
	set_interface_property ${name} addressUnits WORDS
	set_interface_property ${name} associatedClock avl_clk
	set_interface_property ${name} associatedReset avl_reset
	set_interface_property ${name} bitsPerSymbol 8
	set_interface_property ${name} burstOnBurstBoundariesOnly false
	set_interface_property ${name} burstcountUnits WORDS
	set_interface_property ${name} constantBurstBehavior true
	
	set_interface_property ${name} ENABLED true
	
	add_interface_port ${name} ${name}_address address $input_slave 8
	add_interface_port ${name} ${name}_write write $input_slave 1
	add_interface_port ${name} ${name}_writedata writedata $input_slave 32
	add_interface_port ${name} ${name}_read read $input_slave 1
	add_interface_port ${name} ${name}_readdata readdata $output_slave 32
	add_interface_port ${name} ${name}_waitrequest waitrequest $output_slave 1
	if {$use_be} {
		add_interface_port ${name} ${name}_be byteenable $input_slave 4
	}

	set_interface_property ${name} maximumPendingReadTransactions 4

	add_interface_port ${name} ${name}_burstcount burstcount Output 1
	add_interface_port ${name} ${name}_readdatavalid readdatavalid Input 1
}

proc ::alt_mem_if::gen::uniphy_interfaces::tracking_manager_interfaces {component name} {

    if {[string compare -nocase $component "slave"] == 0} {

		set input_slave "Input"
		set output_slave "Output"
		set avalon_dir "end"
	
	} elseif {[string compare -nocase $component "master"] == 0} {

		set input_slave "Output"
		set output_slave "Input"
		set avalon_dir "start"
	
	} else {
		_error "Invalid component specification to determine afi interface"
	}
    
	_dprint 1 "Creating $component QSYS manager interfaces ${name}"

	add_interface ${name} avalon $avalon_dir
	if {[string compare -nocase $component "master"] == 0} {
	    set_interface_property ${name} addressUnits SYMBOLS
	} else {
	    set_interface_property ${name} addressUnits WORDS
	}
	set_interface_property ${name} associatedClock avl_clk
	set_interface_property ${name} associatedReset avl_reset
	set_interface_property ${name} bitsPerSymbol 8
	set_interface_property ${name} burstOnBurstBoundariesOnly false
	set_interface_property ${name} burstcountUnits WORDS
	set_interface_property ${name} constantBurstBehavior true
	
	set_interface_property ${name} ENABLED true
	
	if {[string compare -nocase $component "master"] == 0} {
	    add_interface_port ${name} ${name}_address address Output 20
	} else {
	    add_interface_port ${name} ${name}_address address Input 6
	}
	add_interface_port ${name} ${name}_write write $input_slave 1
	add_interface_port ${name} ${name}_writedata writedata $input_slave [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port ${name} ${name}_read read $input_slave 1
	add_interface_port ${name} ${name}_readdata readdata $output_slave [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port ${name} ${name}_waitrequest waitrequest $output_slave 1


}


proc ::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface {instance_name instance_interface export_interface {rename_interfaces 1}} {

	add_interface $export_interface conduit end
	set_interface_property $export_interface export_of "${instance_name}.${instance_interface}"
	if {$rename_interfaces} {
		::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name $instance_interface $export_interface
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::export_rldramx_controller_sideband_interfaces {protocol instance_name {suffix {}} {exported_suffix {}} {rename_interfaces 1}} {

	if {[string compare -nocase [get_parameter_value ERROR_DETECTION_PARITY] "true"] == 0} {
		add_interface "parity_error_interrupt${exported_suffix}" conduit end
		set_interface_property "parity_error_interrupt${exported_suffix}" export_of "${instance_name}.parity_error_interrupt${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "parity_error_interrupt${suffix}" "parity_error_interrupt${exported_suffix}"
		}
	}

	if {[string compare -nocase [get_parameter_value USER_REFRESH] "true"] == 0} {
		if {[regexp {emif} [get_module_property NAME]]} {
			add_interface "user_refresh${exported_suffix}" conduit end
			set_interface_property "user_refresh${exported_suffix}" export_of "${instance_name}.user_refresh${suffix}"
			if {$rename_interfaces} {
				::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "user_refresh${suffix}" "user_refresh${exported_suffix}"
			}
		}
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces {instance_name {suffix {}} {exported_suffix {}} {rename_interfaces 1}} {

	if {[string compare -nocase [get_parameter_value NEXTGEN] "false"] == 0 ||
	    [string compare -nocase [get_parameter_value USE_MM_ADAPTOR] "true"] == 0} {

		
		if {[string compare -nocase [get_parameter_value MULTICAST_EN] "true"] == 0} {
			add_interface "avl_multicast_write${exported_suffix}" conduit end
			set_interface_property "avl_multicast_write${exported_suffix}" export_of "${instance_name}.avl_multicast_write${suffix}"
			if {$rename_interfaces} {
				::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "avl_multicast_write${suffix}" "avl_multicast_write${exported_suffix}"
			}
		}

		if {[string compare -nocase [get_parameter_value CTL_AUTOPCH_EN] "true"] == 0 &&
                    [string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0
                } {
			add_interface "autoprecharge_req${exported_suffix}" conduit end
			set_interface_property "autoprecharge_req${exported_suffix}" export_of "${instance_name}.autoprecharge_req${suffix}"
			if {$rename_interfaces} {
				::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "autoprecharge_req${suffix}" "autoprecharge_req${exported_suffix}"
			}
		}

		if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
                        if {[string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0} {
			        add_interface "avl_rdata_error${exported_suffix}" conduit end
			        set_interface_property "avl_rdata_error${exported_suffix}" export_of "${instance_name}.avl_rdata_error${suffix}"
			        if {$rename_interfaces} {
			        	::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "avl_rdata_error${suffix}" "avl_rdata_error${exported_suffix}"
			        }
                        }
		}

	}
    
	if {[string compare -nocase [get_parameter_value CTL_DEEP_POWERDN_EN] "true"] == 0} {
		add_interface "deep_powerdn${exported_suffix}" conduit end
		set_interface_property "deep_powerdn${exported_suffix}" export_of "${instance_name}.deep_powerdn${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "deep_powerdn${suffix}" "deep_powerdn${exported_suffix}"
		}
	}
    
	if {[string compare -nocase [get_parameter_value CTL_USR_REFRESH_EN] "true"] == 0} {
		add_interface "user_refresh${exported_suffix}" conduit end
		set_interface_property "user_refresh${exported_suffix}" export_of "${instance_name}.user_refresh${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "user_refresh${suffix}" "user_refresh${exported_suffix}"
		}
	}
	
	if {[string compare -nocase [get_parameter_value CTL_SELF_REFRESH_EN] "true"] == 0} {
		add_interface "self_refresh${exported_suffix}" conduit end
		set_interface_property "self_refresh${exported_suffix}" export_of "${instance_name}.self_refresh${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "self_refresh${suffix}" "self_refresh${exported_suffix}"
		}
	}
	
	if {[string compare -nocase [get_parameter_value AUTO_POWERDN_EN] "true"] == 0} {
		add_interface "local_powerdown${exported_suffix}" conduit end
		set_interface_property "local_powerdown${exported_suffix}" export_of "${instance_name}.local_powerdown${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "local_powerdown${suffix}" "local_powerdown${exported_suffix}"
		}
	}

	if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0 &&
            [string compare -nocase [get_parameter_value HARD_EMIF] "false"] == 0
        } {
                
		add_interface "ecc_interrupt${exported_suffix}" conduit end
		set_interface_property "ecc_interrupt${exported_suffix}" export_of "${instance_name}.ecc_interrupt${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "ecc_interrupt${suffix}" "ecc_interrupt${exported_suffix}"
		}
	}

	if {[string compare -nocase [get_parameter_value CTL_ZQCAL_EN] "true"] == 0} {
		add_interface "user_zqcal${exported_suffix}" conduit end
		set_interface_property "user_zqcal${exported_suffix}" export_of "${instance_name}.user_zqcal${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "user_zqcal${suffix}" "user_zqcal${exported_suffix}"
		}
	}

	if {[string compare -nocase [get_parameter_value ENABLE_BONDING] "true"] == 0} {
		add_interface "bonding_in${exported_suffix}" conduit end
		set_interface_property "bonding_in${exported_suffix}" export_of "${instance_name}.bonding_in${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "bonding_in${suffix}" "bonding_in${exported_suffix}"
		}

		add_interface "bonding_out${exported_suffix}" conduit start
		set_interface_property "bonding_out${exported_suffix}" export_of "${instance_name}.bonding_out${suffix}"
		if {$rename_interfaces} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $instance_name "bonding_out${suffix}" "bonding_out${exported_suffix}"
		}
	}

}


proc ::alt_mem_if::gen::uniphy_interfaces::create_nextgen_st_interface {is_controller} {

	if {$is_controller} {
		set ctl_output "Output"
		set ctl_input "Input"
	} else {
		set ctl_output "Input"
		set ctl_input "Output"
	}

	add_interface native_st conduit end
	
	set_interface_property native_st ENABLED true
	
	add_interface_port native_st itf_cmd_ready itf_cmd_ready $ctl_output 1
	add_interface_port native_st itf_cmd_valid itf_cmd_valid $ctl_input 1
	add_interface_port native_st itf_cmd itf_cmd $ctl_input 1
	add_interface_port native_st itf_cmd_address itf_cmd_address $ctl_input [get_parameter_value AVL_ADDR_WIDTH]
	add_interface_port native_st itf_cmd_burstlen itf_cmd_burstlen $ctl_input [get_parameter_value AVL_SIZE_WIDTH]
	add_interface_port native_st itf_cmd_id itf_cmd_id $ctl_input [get_parameter_value LOCAL_ID_WIDTH]
	add_interface_port native_st itf_cmd_priority itf_cmd_priority $ctl_input 1
	add_interface_port native_st itf_cmd_autopercharge itf_cmd_autopercharge $ctl_input 1
	add_interface_port native_st itf_cmd_multicast itf_cmd_multicast $ctl_input 1
	add_interface_port native_st itf_wr_data_ready itf_wr_data_ready $ctl_output 1
	add_interface_port native_st itf_wr_data_valid itf_wr_data_valid $ctl_input 1
	add_interface_port native_st itf_wr_data itf_wr_data $ctl_input [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port native_st itf_wr_data_byte_en itf_wr_data_byte_en $ctl_input [get_parameter_value AVL_NUM_SYMBOLS]
	add_interface_port native_st itf_wr_data_begin itf_wr_data_begin $ctl_input 1
	add_interface_port native_st itf_wr_data_last itf_wr_data_last $ctl_input 1
	add_interface_port native_st itf_wr_data_id itf_wr_data_id $ctl_input [get_parameter_value LOCAL_ID_WIDTH]
	add_interface_port native_st itf_rd_data_ready itf_rd_data_ready $ctl_input 1
	add_interface_port native_st itf_rd_data_valid itf_rd_data_valid $ctl_output 1
	add_interface_port native_st itf_rd_data itf_rd_data $ctl_output [get_parameter_value AVL_DATA_WIDTH]
	add_interface_port native_st itf_rd_data_error itf_rd_data_error $ctl_output 1
	add_interface_port native_st itf_rd_data_begin itf_rd_data_begin $ctl_output 1
	add_interface_port native_st itf_rd_data_last itf_rd_data_last $ctl_output 1
	add_interface_port native_st itf_rd_data_id itf_rd_data_id $ctl_output [get_parameter_value LOCAL_ID_WIDTH]
	
}


proc ::alt_mem_if::gen::uniphy_interfaces::hard_phy_cfg {component_end} {

	if {[string compare -nocase $component_end "phy"] == 0} {
		set phy_output "Output"
		set phy_input "Input"
	} elseif {[string compare -nocase $component_end "controller"] == 0} {
		set phy_output "Input"
		set phy_input "Output"
	} else {
		_error "Invalid component_end argument to determine hard_phy_cfg interface"
	}

	add_interface hard_phy_cfg conduit end
	set_interface_property hard_phy_cfg ENABLED true
	add_interface_port hard_phy_cfg cfg_addlat cfg_addlat $phy_input 8
	add_interface_port hard_phy_cfg cfg_bankaddrwidth cfg_bankaddrwidth $phy_input 8
	add_interface_port hard_phy_cfg cfg_caswrlat cfg_caswrlat $phy_input 8
	add_interface_port hard_phy_cfg cfg_coladdrwidth cfg_coladdrwidth $phy_input 8
	add_interface_port hard_phy_cfg cfg_csaddrwidth cfg_csaddrwidth $phy_input 8
	add_interface_port hard_phy_cfg cfg_devicewidth cfg_devicewidth $phy_input 8
	add_interface_port hard_phy_cfg cfg_dramconfig cfg_dramconfig $phy_input 24
	add_interface_port hard_phy_cfg cfg_interfacewidth cfg_interfacewidth $phy_input 8
	add_interface_port hard_phy_cfg cfg_rowaddrwidth cfg_rowaddrwidth $phy_input 8
	add_interface_port hard_phy_cfg cfg_tcl cfg_tcl $phy_input 8
	add_interface_port hard_phy_cfg cfg_tmrd cfg_tmrd $phy_input 8
	add_interface_port hard_phy_cfg cfg_trefi cfg_trefi $phy_input 16
	add_interface_port hard_phy_cfg cfg_trfc cfg_trfc $phy_input 8
	add_interface_port hard_phy_cfg cfg_twr cfg_twr $phy_input 8

}


proc ::alt_mem_if::gen::uniphy_interfaces::hard_phy_io {component_end} {

	if {[string compare -nocase $component_end "phy"] == 0} {
		set phy_output "Output"
		set phy_input "Input"
	} elseif {[string compare -nocase $component_end "controller"] == 0} {
		set phy_output "Input"
		set phy_input "Output"
	} else {
		_error "Invalid component_end argument to determine hard_phy_io interface"
	}

	add_interface hard_phy_io conduit end
	set_interface_property hard_phy_io ENABLED true
	add_interface_port hard_phy_io io_intaddrdout io_intaddrdout $phy_input 64
	add_interface_port hard_phy_io io_intbadout io_intbadout $phy_input 12
	add_interface_port hard_phy_io io_intcasndout io_intcasndout $phy_input 4
	add_interface_port hard_phy_io io_intckdout io_intckdout $phy_input 4
	add_interface_port hard_phy_io io_intckedout io_intckedout $phy_input 8
	add_interface_port hard_phy_io io_intckndout io_intckndout $phy_input 4
	add_interface_port hard_phy_io io_intcsndout io_intcsndout $phy_input 8
	add_interface_port hard_phy_io io_intdmdout io_intdmdout $phy_input 20
	add_interface_port hard_phy_io io_intdqdin io_intdqdin $phy_output 180
	add_interface_port hard_phy_io io_intdqdout io_intdqdout $phy_input 180
	add_interface_port hard_phy_io io_intdqoe io_intdqoe $phy_input 90
	add_interface_port hard_phy_io io_intdqsbdout io_intdqsbdout $phy_input 20
	add_interface_port hard_phy_io io_intdqsboe io_intdqsboe $phy_input 10
	add_interface_port hard_phy_io io_intdqsdout io_intdqsdout $phy_input 20
	add_interface_port hard_phy_io io_intdqslogicdqsena io_intdqslogicdqsena $phy_input 10
	add_interface_port hard_phy_io io_intdqslogicfiforeset io_intdqslogicfiforeset $phy_input 5
	add_interface_port hard_phy_io io_intdqslogicincrdataen io_intdqslogicincrdataen $phy_input 10
	add_interface_port hard_phy_io io_intdqslogicincwrptr io_intdqslogicincwrptr $phy_input 10
	add_interface_port hard_phy_io io_intdqslogicoct io_intdqslogicoct $phy_input 10
	add_interface_port hard_phy_io io_intdqslogicrdatavalid io_intdqslogicrdatavalid $phy_output 5
	add_interface_port hard_phy_io io_intdqslogicreadlatency io_intdqslogicreadlatency $phy_input 25
	add_interface_port hard_phy_io io_intdqsoe io_intdqsoe $phy_input 10
	add_interface_port hard_phy_io io_intodtdout io_intodtdout $phy_input 8
	add_interface_port hard_phy_io io_intrasndout io_intrasndou $phy_input 4
	add_interface_port hard_phy_io io_intresetndout io_intresetndout $phy_input 4
	add_interface_port hard_phy_io io_intwendout io_intwendout $phy_input 4
	add_interface_port hard_phy_io io_intafirlat io_intafirlat $phy_output 5
	add_interface_port hard_phy_io io_intafiwlat io_intafiwlat $phy_output 4
	add_interface_port hard_phy_io io_intaficalfail io_intaficalfail $phy_output 1
	add_interface_port hard_phy_io io_intaficalsuccess io_intaficalsuccess $phy_output 1

	::alt_mem_if::util::hwtcl_utils::set_interface_termination hard_phy_io 0

}
	
proc ::alt_mem_if::gen::uniphy_interfaces::add_toolkit_master {phy_clk phy_reset seq_debug {reset_target ""}} {
	set TOOLKIT_MASTER dmaster

	if {[string compare -nocase [get_parameter_value ENABLE_EMIT_JTAG_MASTER] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value ENABLE_EMIT_BFM_MASTER] "true"] == 0} {
			add_instance $TOOLKIT_MASTER altera_avalon_mm_master_bfm
			
			set_instance_parameter $TOOLKIT_MASTER AV_ADDRESS_W 32
			set_instance_parameter $TOOLKIT_MASTER AV_SYMBOL_W 8
			set_instance_parameter $TOOLKIT_MASTER AV_NUMSYMBOLS 4
			set_instance_parameter $TOOLKIT_MASTER AV_BURSTCOUNT_W 1

			add_connection "${phy_clk}/${TOOLKIT_MASTER}.clk"
			add_connection "${phy_reset}/${TOOLKIT_MASTER}.clk_reset"
		
			add_connection "${TOOLKIT_MASTER}.m0/${seq_debug}"
			set_connection_parameter_value "${TOOLKIT_MASTER}.m0/${seq_debug}" baseAddress 0
		} else {
			add_instance $TOOLKIT_MASTER altera_jtag_avalon_master 
		
			set_instance_parameter $TOOLKIT_MASTER USE_PLI "0"
			set_instance_parameter $TOOLKIT_MASTER PLI_PORT "50000"
		
			add_connection "${phy_clk}/${TOOLKIT_MASTER}.clk"
			add_connection "${phy_reset}/${TOOLKIT_MASTER}.clk_reset"
		
			add_connection "${TOOLKIT_MASTER}.master/${seq_debug}"
			set_connection_parameter_value "${TOOLKIT_MASTER}.master/${seq_debug}" baseAddress 0

			if {[string compare $reset_target ""] != 0} {
				add_connection "${TOOLKIT_MASTER}.master_reset/$reset_target"
			}


		}
	}
}

proc ::alt_mem_if::gen::uniphy_interfaces::hps_controller_f2sdram {component_end} {

	if {[string compare -nocase $component_end "hps"] == 0} {
		set hps_output "Output"
		set hps_input "Input"
	} elseif {[string compare -nocase $component_end "fpga"] == 0} {
		set hps_output "Input"
		set hps_input "Output"
	} else {
		_error "Invalid component_end argument to determine hps_controller_f2sdram interface"
	}

	add_interface hps_f2sdram conduit end
	set_interface_property hps_f2sdram ENABLED true

	add_interface_port hps_f2sdram cfg_axi_mm_select 	cfg_axi_mm_select 	$hps_input     6
	add_interface_port hps_f2sdram cfg_cport_rfifo_map 	cfg_cport_rfifo_map 	$hps_input    18
	add_interface_port hps_f2sdram cfg_cport_type 		cfg_cport_type 		$hps_input    12
	add_interface_port hps_f2sdram cfg_cport_wfifo_map 	cfg_cport_wfifo_map 	$hps_input    18
	add_interface_port hps_f2sdram cfg_port_width 		cfg_port_width 		$hps_input    12
	add_interface_port hps_f2sdram cfg_rfifo_cport_map 	cfg_rfifo_cport_map 	$hps_input    16
	add_interface_port hps_f2sdram cfg_wfifo_cport_map 	cfg_wfifo_cport_map 	$hps_input    16
	add_interface_port hps_f2sdram cmd_data_0	 	cmd_data_0	 	$hps_input    60
	add_interface_port hps_f2sdram cmd_data_1 		cmd_data_1 		$hps_input    60
	add_interface_port hps_f2sdram cmd_data_2 		cmd_data_2 		$hps_input    60
	add_interface_port hps_f2sdram cmd_data_3 		cmd_data_3 		$hps_input    60
	add_interface_port hps_f2sdram cmd_data_4 		cmd_data_4 		$hps_input    60
	add_interface_port hps_f2sdram cmd_data_5 		cmd_data_5 		$hps_input    60
	add_interface_port hps_f2sdram cmd_port_clk_0 		cmd_port_clk_0 		$hps_input     1
	add_interface_port hps_f2sdram cmd_port_clk_1 		cmd_port_clk_1 		$hps_input     1
	add_interface_port hps_f2sdram cmd_port_clk_2 		cmd_port_clk_2 		$hps_input     1
	add_interface_port hps_f2sdram cmd_port_clk_3 		cmd_port_clk_3 		$hps_input     1
	add_interface_port hps_f2sdram cmd_port_clk_4 		cmd_port_clk_4 		$hps_input     1
	add_interface_port hps_f2sdram cmd_port_clk_5 		cmd_port_clk_5 		$hps_input     1
	add_interface_port hps_f2sdram cmd_valid_0 		cmd_valid_0 		$hps_input     1
	add_interface_port hps_f2sdram cmd_valid_1 		cmd_valid_1 		$hps_input     1
	add_interface_port hps_f2sdram cmd_valid_2 		cmd_valid_2 		$hps_input     1
	add_interface_port hps_f2sdram cmd_valid_3 		cmd_valid_3 		$hps_input     1
	add_interface_port hps_f2sdram cmd_valid_4 		cmd_valid_4 		$hps_input     1
	add_interface_port hps_f2sdram cmd_valid_5 		cmd_valid_5 		$hps_input     1
	add_interface_port hps_f2sdram rd_clk_0 		rd_clk_0 		$hps_input     1
	add_interface_port hps_f2sdram rd_clk_1 		rd_clk_1 		$hps_input     1
	add_interface_port hps_f2sdram rd_clk_2 		rd_clk_2 		$hps_input     1
	add_interface_port hps_f2sdram rd_clk_3 		rd_clk_3 		$hps_input     1
	add_interface_port hps_f2sdram rd_ready_0 		rd_ready_0 		$hps_input     1
	add_interface_port hps_f2sdram rd_ready_1 		rd_ready_1 		$hps_input     1
	add_interface_port hps_f2sdram rd_ready_2 		rd_ready_2 		$hps_input     1
	add_interface_port hps_f2sdram rd_ready_3 		rd_ready_3 		$hps_input     1
	add_interface_port hps_f2sdram wr_clk_0 		wr_clk_0 		$hps_input     1
	add_interface_port hps_f2sdram wr_clk_1 		wr_clk_1 		$hps_input     1
	add_interface_port hps_f2sdram wr_clk_2 		wr_clk_2 		$hps_input     1
	add_interface_port hps_f2sdram wr_clk_3 		wr_clk_3 		$hps_input     1
	add_interface_port hps_f2sdram wr_data_0 		wr_data_0 		$hps_input    90
	add_interface_port hps_f2sdram wr_data_1 		wr_data_1 		$hps_input    90
	add_interface_port hps_f2sdram wr_data_2 		wr_data_2 		$hps_input    90
	add_interface_port hps_f2sdram wr_data_3 		wr_data_3 		$hps_input    90
	add_interface_port hps_f2sdram wr_valid_0 		wr_valid_0 		$hps_input     1
	add_interface_port hps_f2sdram wr_valid_1 		wr_valid_1 		$hps_input     1
	add_interface_port hps_f2sdram wr_valid_2 		wr_valid_2 		$hps_input     1
	add_interface_port hps_f2sdram wr_valid_3 		wr_valid_3 		$hps_input     1
	add_interface_port hps_f2sdram wrack_ready_0 		wrack_ready_0 		$hps_input     1
	add_interface_port hps_f2sdram wrack_ready_1 		wrack_ready_1 		$hps_input     1
	add_interface_port hps_f2sdram wrack_ready_2 		wrack_ready_2 		$hps_input     1
	add_interface_port hps_f2sdram wrack_ready_3 		wrack_ready_3 		$hps_input     1
	add_interface_port hps_f2sdram wrack_ready_4 		wrack_ready_4 		$hps_input     1
	add_interface_port hps_f2sdram wrack_ready_5 		wrack_ready_5 		$hps_input     1
	add_interface_port hps_f2sdram bonding_out_1 		bonding_out_1 		$hps_output    4
	add_interface_port hps_f2sdram bonding_out_2 		bonding_out_2 		$hps_output    4
	add_interface_port hps_f2sdram cmd_ready_0 		cmd_ready_0 		$hps_output    1
	add_interface_port hps_f2sdram cmd_ready_1 		cmd_ready_1 		$hps_output    1
	add_interface_port hps_f2sdram cmd_ready_2 		cmd_ready_2 		$hps_output    1
	add_interface_port hps_f2sdram cmd_ready_3 		cmd_ready_3 		$hps_output    1
	add_interface_port hps_f2sdram cmd_ready_4 		cmd_ready_4 		$hps_output    1
	add_interface_port hps_f2sdram cmd_ready_5 		cmd_ready_5 		$hps_output    1
	add_interface_port hps_f2sdram rd_data_0 		rd_data_0 		$hps_output   80
	add_interface_port hps_f2sdram rd_data_1 		rd_data_1 		$hps_output   80
	add_interface_port hps_f2sdram rd_data_2 		rd_data_2 		$hps_output   80
	add_interface_port hps_f2sdram rd_data_3 		rd_data_3 		$hps_output   80
	add_interface_port hps_f2sdram rd_valid_0 		rd_valid_0 		$hps_output    1
	add_interface_port hps_f2sdram rd_valid_1 		rd_valid_1 		$hps_output    1
	add_interface_port hps_f2sdram rd_valid_2 		rd_valid_2 		$hps_output    1
	add_interface_port hps_f2sdram rd_valid_3 		rd_valid_3 		$hps_output    1
	add_interface_port hps_f2sdram wr_ready_0 		wr_ready_0 		$hps_output    1
	add_interface_port hps_f2sdram wr_ready_1 		wr_ready_1 		$hps_output    1
	add_interface_port hps_f2sdram wr_ready_2 		wr_ready_2 		$hps_output    1
	add_interface_port hps_f2sdram wr_ready_3 		wr_ready_3 		$hps_output    1
	add_interface_port hps_f2sdram wrack_data_0 		wrack_data_0 		$hps_output   10
	add_interface_port hps_f2sdram wrack_data_1 		wrack_data_1 		$hps_output   10
	add_interface_port hps_f2sdram wrack_data_2 		wrack_data_2 		$hps_output   10
	add_interface_port hps_f2sdram wrack_data_3 		wrack_data_3 		$hps_output   10
	add_interface_port hps_f2sdram wrack_data_4 		wrack_data_4 		$hps_output   10
	add_interface_port hps_f2sdram wrack_data_5 		wrack_data_5 		$hps_output   10
	add_interface_port hps_f2sdram wrack_valid_0 		wrack_valid_0 		$hps_output    1
	add_interface_port hps_f2sdram wrack_valid_1 		wrack_valid_1 		$hps_output    1
	add_interface_port hps_f2sdram wrack_valid_2 		wrack_valid_2 		$hps_output    1
	add_interface_port hps_f2sdram wrack_valid_3 		wrack_valid_3 		$hps_output    1
	add_interface_port hps_f2sdram wrack_valid_4 		wrack_valid_4 		$hps_output    1
	add_interface_port hps_f2sdram wrack_valid_5 		wrack_valid_5 		$hps_output    1
}


proc ::alt_mem_if::gen::uniphy_interfaces::_init {} {
	return 1
}


::alt_mem_if::gen::uniphy_interfaces::_init
