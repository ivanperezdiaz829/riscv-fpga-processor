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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
	lappend auto_path $alt_mem_if_tcl_libs_dir
}

package require -exact qsys 12.0

package require alt_mem_if::util::messaging
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::uniphy_phy
package require alt_mem_if::gui::common_ddrx_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gui::diagnostics
package require alt_mem_if::gen::uniphy_pll
package require alt_mem_if::gui::abstract_ram
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::uniphy_oct
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::gui::noise_gen

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera LPDDR SDRAM External Memory Interface Example Design"
set_module_property NAME alt_mem_if_lpddr_tg_ed
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_designs_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera LPDDR SDRAM External Memory Interface Example Design"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP

alt_mem_if::gui::afi::set_protocol "LPDDR1"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "LPDDR1"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::ddrx_controller::set_ddr_mode "LPDDR1"
alt_mem_if::gui::ddrx_controller::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::common_ddrx_phy::set_ddr_mode "LPDDR1"
alt_mem_if::gui::common_ddrx_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::diagnostics::create_parameters
alt_mem_if::gui::abstract_ram::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters
alt_mem_if::gui::uniphy_oct::create_parameters
alt_mem_if::gui::noise_gen::create_example_design_parameters

alt_mem_if::gui::common_ddrx_phy::create_phy_gui
alt_mem_if::gui::common_ddr_mem_model::create_gui
alt_mem_if::gui::common_ddrx_phy::create_board_settings_gui
alt_mem_if::gui::ddrx_controller::create_gui
alt_mem_if::gui::common_ddrx_phy::create_diagnostics_gui
alt_mem_if::gui::diagnostics::create_gui
alt_mem_if::gui::noise_gen::create_gui

alt_mem_if::gui::abstract_ram::create_memif_gui

set_parameter_property PHY_CSR_ENABLED VISIBLE false
set_parameter_property PHY_CSR_CONNECTION VISIBLE false



add_parameter TG_NUM_DRIVER_LOOP integer 1000
set_parameter_property TG_NUM_DRIVER_LOOP DISPLAY_NAME "Number of loops through patterns"
set_parameter_property TG_NUM_DRIVER_LOOP DESCRIPTION "Specifies the number of times the driver will loop through all patterns before asserting test complete. A value of 0 specifies that the driver should infinitely loop."
set_parameter_property TG_NUM_DRIVER_LOOP ALLOWED_RANGES {0:1000000}

::alt_mem_if::util::hwtcl_utils::_add_parameter TG_PNF_ENABLE boolean false
set_parameter_property TG_PNF_ENABLE DISPLAY_NAME "Generate the per-bit pass/fail signals in the status inteface"

::alt_mem_if::util::hwtcl_utils::_add_parameter EXPORT_AFI_CLK_RESET boolean false
set_parameter_property EXPORT_AFI_CLK_RESET VISIBLE false


if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property VALIDATION_CALLBACK ip_validate
	set_module_property COMPOSITION_CALLBACK ip_compose
} else {
	set_module_property COMPOSITION_CALLBACK combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_compose
}

proc ip_validate {} {

	_dprint 1 "Running IP Validation for [get_module_property NAME]"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_oct::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::ddrx_controller::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::common_ddrx_phy::validate_component
	alt_mem_if::gui::diagnostics::validate_component [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE]

	alt_mem_if::gui::abstract_ram::validate_component
	
	if {[string compare -nocase [get_parameter_value ADD_EFFICIENCY_MONITOR] "true"] == 0 &&
		[string compare -nocase [get_parameter_value ENABLE_ABSTRACT_RAM] "true"] == 0} {
			_eprint "Efficiency monitor and memory initialization cannot both be enabled at the same time"
	}

}

proc ip_compose {} {

	_dprint 1 "Running IP Compose for [get_module_property NAME]"

	set need_extra_pll_ref_clk_pin 0
	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] == 0 &&
	    ([string compare -nocase [get_parameter_value DLL_SHARING_MODE] "none"] != 0 ||
	     [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "none"] != 0)} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			set need_extra_pll_ref_clk_pin 1
		}
	}

	add_interface pll_ref_clk clock end
	add_instance pll_ref_clk altera_clock_bridge
	set_interface_property pll_ref_clk export_of pll_ref_clk.in_clk 
	set_interface_property pll_ref_clk PORT_NAME_MAP { pll_ref_clk in_clk }

	if {$need_extra_pll_ref_clk_pin} {
		add_interface pll_ref_clk_1 clock end
		add_instance pll_ref_clk_1 altera_clock_bridge
		set_interface_property pll_ref_clk_1 export_of pll_ref_clk_1.in_clk 
		set_interface_property pll_ref_clk_1 PORT_NAME_MAP { pll_ref_clk_1 in_clk }
	}

	add_interface global_reset reset end
	add_instance global_reset altera_reset_bridge
	set_interface_property global_reset export_of global_reset.in_reset
	set_instance_parameter global_reset SYNCHRONOUS_EDGES none
	set_instance_parameter global_reset ACTIVE_LOW_RESET 1
	set_interface_property global_reset PORT_NAME_MAP { global_reset_n in_reset_n }

	add_interface soft_reset reset end
	add_instance soft_reset altera_reset_bridge
	set_interface_property soft_reset export_of soft_reset.in_reset
	set_instance_parameter soft_reset SYNCHRONOUS_EDGES none
	set_instance_parameter soft_reset ACTIVE_LOW_RESET 1
	set_interface_property soft_reset PORT_NAME_MAP { soft_reset_n in_reset_n }

	if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		add_interface afi_clk clock start
		add_instance afi_clk altera_clock_bridge
		set_interface_property afi_clk export_of afi_clk.out_clk
		set_interface_property afi_clk PORT_NAME_MAP { afi_clk out_clk }
	}

	if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		add_interface afi_half_clk clock start
		add_instance afi_half_clk altera_clock_bridge
		set_interface_property afi_half_clk export_of afi_half_clk.out_clk
		set_interface_property afi_half_clk PORT_NAME_MAP { afi_half_clk out_clk }
	}

	if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		add_interface afi_reset reset source
		add_instance afi_reset altera_reset_bridge
		set_instance_parameter afi_reset SYNCHRONOUS_EDGES none
		set_instance_parameter afi_reset ACTIVE_LOW_RESET 1
		set_interface_property afi_reset export_of afi_reset.out_reset
		set_interface_property afi_reset PORT_NAME_MAP { afi_reset_n out_reset_n }
	}

	set num_emif 1
	set interface_suffixes [list {}]
	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] != 0 ||
	    [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "none"] != 0 ||
	    [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "none"] != 0} {
		set num_emif 2
		lappend interface_suffixes {_1}
	}

	set num_mpfe_ports 1
	set mpfe_suffixes [list {}]
	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set num_mpfe_ports [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]
                if {$num_mpfe_ports > 1} {
                        set mpfe_suffixes [list {_mp0}]
                }
		for {set i 1} {$i < $num_mpfe_ports} {incr i} {
			lappend mpfe_suffixes "_mp${i}"
		}
	}

	set EMIF0 "if0"
	set EMIF1 "if1"
	set CONTROLLER0 "c0"
	set CONTROLLER1 "c1"




	for {set ii 0} {$ii < $num_emif} {incr ii} {
		set EMIF "if${ii}"
		add_instance $EMIF altera_mem_if_lpddr_emif
		foreach param_name [get_instance_parameters $EMIF] {
			_dprint 1 "Assigning parameter $param_name = [get_parameter_value $param_name] for $EMIF"
			set_instance_parameter $EMIF $param_name [get_parameter_value $param_name]
		}
		if {$ii == 1} {
			if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] == 0} {
				set_instance_parameter $EMIF PLL_SHARING_MODE "Slave"
			} elseif {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
				set_instance_parameter $EMIF PLL_SHARING_MODE "Master"
			}
			if {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "master"] == 0} {
				set_instance_parameter $EMIF DLL_SHARING_MODE "Slave"
			} elseif {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] == 0} {
				set_instance_parameter $EMIF DLL_SHARING_MODE "Master"
			}
			if {[string compare -nocase [get_parameter_value OCT_SHARING_MODE] "master"] == 0} {
				set_instance_parameter $EMIF OCT_SHARING_MODE "Slave"
			} elseif {[string compare -nocase [get_parameter_value OCT_SHARING_MODE] "slave"] == 0} {
				set_instance_parameter $EMIF OCT_SHARING_MODE "Master"
			}
		}
		::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $EMIF
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $EMIF
		set_instance_parameter $EMIF DISABLE_CHILD_MESSAGING true

		if {$need_extra_pll_ref_clk_pin && ($ii == 1)} {
			add_connection "pll_ref_clk_1.out_clk/${EMIF}.pll_ref_clk"
		} else {
			if {([string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] == 0 && ($ii == 0)) ||
				([string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0 && ($ii == 1)) ||
				([string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] == 0)} {
				add_connection "pll_ref_clk.out_clk/${EMIF}.pll_ref_clk"
			}
		}
		add_connection "soft_reset.out_reset/${EMIF}.soft_reset"
		add_connection "global_reset.out_reset/${EMIF}.global_reset"

		set suffix [lindex $interface_suffixes $ii]

		add_interface "memory${suffix}" conduit end
		set_interface_property "memory${suffix}" export_of "${EMIF}.memory"
		if {$ii == 0} {
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF}" "memory" "memory${suffix}"
		}

		if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0} {
			if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
				if {[string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "EXPORT"] == 0 ||
					[string compare -nocase [get_parameter_value CTL_CSR_CONNECTION] "SHARED"] == 0} {

					if {$ii == 0} {
						add_interface "csr${suffix}" avalon end
						set_interface_property "csr${suffix}" export_of "${EMIF}.csr"
						::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF}" "csr" "csr${suffix}"
					}
				}
			}
		}

		if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
			_dprint 1 "Exporting core debug bridge"
			set conn_type [get_parameter_value CORE_DEBUG_CONNECTION]
			if {[string compare -nocase $conn_type "SHARED"] == 0 || [string compare -nocase $conn_type "EXPORT"] == 0} {
				_dprint 1 "Export or shared"
				set debug_port "seq_debug"
				add_interface "${debug_port}${suffix}" avalon end
				set_interface_property "${debug_port}${suffix}" export_of "${EMIF}.${debug_port}"
				if {$ii == 0} {
					::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF}" "${debug_port}" "${debug_port}${suffix}"
				}
			}
		}
	}




	if {$num_emif == 2} {
		if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] != 0} {
			add_connection "${EMIF0}.pll_sharing/${EMIF1}.pll_sharing"
		}
		if { [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "none"] != 0} {
			add_connection "${EMIF0}.dll_sharing/${EMIF1}.dll_sharing"
			if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
				add_connection "${EMIF0}.hcx_dll_sharing/${EMIF1}.hcx_dll_sharing"
			}
		}
		if { [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "none"] != 0} {
			add_connection "${EMIF0}.oct_sharing/${EMIF1}.oct_sharing"
		}
	}




	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
		if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
			add_connection "${EMIF1}.afi_clk/afi_clk.in_clk"
			add_connection "${EMIF1}.afi_half_clk/afi_half_clk.in_clk"
			add_connection "${EMIF1}.afi_reset/afi_reset.in_reset"
		}
		add_connection "${EMIF1}.afi_clk/${EMIF0}.afi_clk_in"
		add_connection "${EMIF1}.afi_half_clk/${EMIF0}.afi_half_clk_in"
		add_connection "${EMIF1}.afi_reset/${EMIF0}.afi_reset_in"
	} else {
		if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
			add_connection "${EMIF0}.afi_clk/afi_clk.in_clk"
			add_connection "${EMIF0}.afi_half_clk/afi_half_clk.in_clk"
			add_connection "${EMIF0}.afi_reset/afi_reset.in_reset"
		}
		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] == 0} {
			add_connection "${EMIF0}.afi_clk/${EMIF1}.afi_clk_in"
			add_connection "${EMIF0}.afi_half_clk/${EMIF1}.afi_half_clk_in"
			add_connection "${EMIF0}.afi_reset/${EMIF1}.afi_reset_in"
		}
	}




	if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
		set PLL pll0
		add_instance $PLL altera_mem_if_single_clock_pll
		foreach param_name [get_instance_parameters $PLL] {
			if {[string compare -nocase $param_name REQ_CLK_FREQ] == 0} {
				set_instance_parameter $PLL REQ_CLK_FREQ [get_parameter_value REF_CLK_FREQ]
			} elseif {[string compare -nocase $param_name ENABLE_RESET_OUTPUT] == 0} {
				set_instance_parameter $PLL ENABLE_RESET_OUTPUT true
			} else {
				_dprint 1 "Assigning parameter $param_name = [get_parameter_value $param_name] for $PLL"
				set_instance_parameter $PLL $param_name [get_parameter_value $param_name]
			}
		}

		add_connection "pll_ref_clk.out_clk/${PLL}.pll_ref_clk"
		add_connection "global_reset.out_reset/${PLL}.global_reset_n"

	}




	if {[string compare -nocase [get_parameter_value OCT_SHARING_MODE] "slave"] != 0} {
		add_interface "oct" conduit end
		set_interface_property "oct" export_of "${EMIF0}.oct"
		::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF0}" "oct" "oct"
		set_interface_assignment "oct" "qsys.ui.export_name" "oct"
	}
	if {$num_emif == 2} {
		if {[string compare -nocase [get_parameter_value OCT_SHARING_MODE] "master"] != 0} {
			add_interface "oct_1" conduit end
			set_interface_property "oct_1" export_of "${EMIF1}.oct"
			set_interface_assignment "oct_1" "qsys.ui.export_name" "oct_1"
		}
	}


	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {




		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {
			add_interface "hcx_pll_reconfig" conduit end
			set_interface_property "hcx_pll_reconfig" export_of "${EMIF0}.hcx_pll_reconfig"
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF0}" "hcx_pll_reconfig" "hcx_pll_reconfig"
		}
		if {$num_emif == 2} {
			if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] != 0} {
				add_interface "hcx_pll_reconfig_1" conduit end
				set_interface_property "hcx_pll_reconfig_1" export_of "${EMIF1}.hcx_pll_reconfig"
			}
		}




		if {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] != 0} {
			add_interface "hcx_dll_reconfig" conduit end
			set_interface_property "hcx_dll_reconfig" export_of "${EMIF0}.hcx_dll_reconfig"
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF0}" "hcx_dll_reconfig" "hcx_dll_reconfig"
		}
		if {$num_emif == 2} {
			if {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "master"] != 0} {
				add_interface "hcx_dll_reconfig_1" conduit end
				set_interface_property "hcx_dll_reconfig_1" export_of "${EMIF1}.hcx_dll_reconfig"
			}
		}




		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
			add_interface "hcx_rom_reconfig" conduit end
			set_interface_property "hcx_rom_reconfig" export_of "${EMIF0}.hcx_rom_reconfig"
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF0}" "hcx_rom_reconfig" "hcx_rom_reconfig"
			if {$num_emif == 2} {
				add_interface "hcx_rom_reconfig_1" conduit end
				set_interface_property "hcx_rom_reconfig_1" export_of "${EMIF1}.hcx_rom_reconfig"
			}
		}
	}




	if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {

		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {
			::alt_mem_if::gen::uniphy_gen::instantiate_ddrx_controller "lpddr" "${CONTROLLER0}" "${EMIF0}.afi_clk" "${EMIF0}.afi_half_clk" "${EMIF0}.afi_reset"
		} else {
			::alt_mem_if::gen::uniphy_gen::instantiate_ddrx_controller "lpddr" "${CONTROLLER0}" "${EMIF1}.afi_clk" "${EMIF1}.afi_half_clk" "${EMIF1}.afi_reset"
		}

		add_connection "${CONTROLLER0}.afi/${EMIF0}.afi"

		::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${CONTROLLER0}" "status" "emif_status"
		::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces "${CONTROLLER0}" {} {}

		if {$num_emif == 2} {

			if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] != 0} {
				::alt_mem_if::gen::uniphy_gen::instantiate_ddrx_controller "lpddr" "${CONTROLLER1}" "${EMIF1}.afi_clk" "${EMIF1}.afi_half_clk" "${EMIF1}.afi_reset" 0
			} else {
				::alt_mem_if::gen::uniphy_gen::instantiate_ddrx_controller "lpddr" "${CONTROLLER1}" "${EMIF0}.afi_clk" "${EMIF0}.afi_half_clk" "${EMIF0}.afi_reset" 0
			}

			add_connection "${CONTROLLER1}.afi/${EMIF1}.afi"

			::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${CONTROLLER1}" "status" "emif_status_1" 0
			::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces "${CONTROLLER1}" {} {_1} 0
		}

	} else {

		::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${EMIF0}" "status" "emif_status"
		::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces "${EMIF0}" {} {}
		if {$num_emif == 2} {
			::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${EMIF1}" "status" "emif_status_1" 0
			::alt_mem_if::gen::uniphy_interfaces::export_ddrx_controller_sideband_interfaces "${EMIF1}" {} {_1} 0
		}

                if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
                        for {set ii 0} {$ii < $num_emif} {incr ii} {
                                set EMIF "if${ii}"

			        if {$ii == 0} {
			        	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {
			        		set pll_master_instance "${EMIF0}"
			        	} else {
			        		set pll_master_instance "${EMIF1}"
			        	}
			        } else {
			        	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] != 0} {
			        		set pll_master_instance "${EMIF1}"
			        	} else {
			        		set pll_master_instance "${EMIF0}"
			        	}
			        }

                                for {set port_id 0} {$port_id < [::alt_mem_if::gui::ddrx_controller::get_NUM_OF_PORTS]} {incr port_id} {
                                        add_connection "${pll_master_instance}.afi_clk/${EMIF}.mp_cmd_clk_${port_id}"
                                        add_connection "global_reset.out_reset/${EMIF}.mp_cmd_reset_n_${port_id}"
                                        add_connection "soft_reset.out_reset/${EMIF}.mp_cmd_reset_n_${port_id}"
                                }
                        
                                for {set fifo_id 0} {$fifo_id < 4} {incr fifo_id} {
                                        if {[string compare -nocase [get_parameter_value ENUM_RD_FIFO_IN_USE_${fifo_id}] "true"] == 0} {
                                                add_connection "${pll_master_instance}.afi_clk/${EMIF}.mp_rfifo_clk_${fifo_id}"
                                                add_connection "global_reset.out_reset/${EMIF}.mp_rfifo_reset_n_${fifo_id}"
                                                add_connection "soft_reset.out_reset/${EMIF}.mp_rfifo_reset_n_${fifo_id}"
                                        }

                                        if {[string compare -nocase [get_parameter_value ENUM_WR_FIFO_IN_USE_${fifo_id}] "true"] == 0} {
                                                add_connection "${pll_master_instance}.afi_clk/${EMIF}.mp_wfifo_clk_${fifo_id}"
                                                add_connection "global_reset.out_reset/${EMIF}.mp_wfifo_reset_n_${fifo_id}"
                                                add_connection "soft_reset.out_reset/${EMIF}.mp_wfifo_reset_n_${fifo_id}"
                                        }
                                }
                        
                                if {[string compare -nocase [get_parameter_value CTL_CSR_ENABLED] "true"] == 0} {
                                                add_connection "${pll_master_instance}.afi_clk/${EMIF}.csr_clk"
                                                add_connection "global_reset.out_reset/${EMIF}.csr_reset_n"
                                                add_connection "soft_reset.out_reset/${EMIF}.csr_reset_n"
                        
                                }
                        }
                }

	}



	set unix_id 0

	for {set ii 0} {$ii < $num_emif} {incr ii} {
		set EMIF "if${ii}"
		set CONTROLLER "c${ii}"
		set emif_suffix [lindex $interface_suffixes $ii]

		for {set jj 0} {$jj < $num_mpfe_ports} {incr jj} {

			set mpfe_suffix [lindex $mpfe_suffixes $jj]
			set TRAFFIC_GEN "d${ii}${mpfe_suffix}"

			add_instance $TRAFFIC_GEN altera_avalon_mm_traffic_generator

			set_instance_parameter $TRAFFIC_GEN TG_AVL_ADDR_WIDTH_IN [get_parameter_value AVL_ADDR_WIDTH]
			set_instance_parameter $TRAFFIC_GEN TG_POWER_OF_TWO_BUS [get_parameter_value POWER_OF_TWO_BUS]
			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				set_instance_parameter $TRAFFIC_GEN TG_AVL_DATA_WIDTH_IN [get_parameter_value AVL_DATA_WIDTH_PORT_${jj}]
			} else {
				set_instance_parameter $TRAFFIC_GEN TG_AVL_DATA_WIDTH_IN [get_parameter_value AVL_DATA_WIDTH]
			}
			set_instance_parameter $TRAFFIC_GEN TG_AVL_SYMBOL_WIDTH [get_parameter_value AVL_SYMBOL_WIDTH]

			if {[string compare -nocase [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE] "true"] == 0} {
				set_instance_parameter $TRAFFIC_GEN TG_GEN_BYTE_ADDR "true"
			} else {
				set_instance_parameter $TRAFFIC_GEN TG_GEN_BYTE_ADDR "false"
			}

			set_instance_parameter $TRAFFIC_GEN TG_AVL_MAX_SIZE [get_parameter_value AVL_MAX_SIZE]
			set_instance_parameter $TRAFFIC_GEN TG_TWO_AVL_INTERFACES "false"

			if {[string compare -nocase [get_parameter_value BYTE_ENABLE] "true"] == 0} {
				set_instance_parameter $TRAFFIC_GEN TG_BYTE_ENABLE "true"
				if {[string compare -nocase [get_parameter_value CTL_ECC_ENABLED] "true"] == 0} {
					set_instance_parameter $TRAFFIC_GEN TG_RANDOM_BYTE_ENABLE "false"
				} else {
					set_instance_parameter $TRAFFIC_GEN TG_RANDOM_BYTE_ENABLE "true"
				}
			} else {
				set_instance_parameter $TRAFFIC_GEN TG_BYTE_ENABLE "false"
			}

			set_instance_parameter $TRAFFIC_GEN TG_BURST_BEGIN "true"
			set_instance_parameter $TRAFFIC_GEN TG_NUM_DRIVER_LOOP [get_parameter_value TG_NUM_DRIVER_LOOP]

			set_instance_parameter $TRAFFIC_GEN ENABLE_CTRL_AVALON_INTERFACE [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE]

			set_instance_parameter $TRAFFIC_GEN TG_PNF_ENABLE [get_parameter_value TG_PNF_ENABLE]

		    if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "false"] == 0} {
		    	set_instance_parameter $TRAFFIC_GEN TG_BURST_ON_BURST_BOUNDARY "true"
		    	
		    	set_instance_parameter $TRAFFIC_GEN TG_TEMPLATE_STAGE_COUNT 0
		    	
		    	set_instance_parameter $TRAFFIC_GEN TG_POWER_OF_TWO_BURSTS_ONLY "true"
		    	
		    	set minimum_size [expr [get_parameter_value MEM_BURST_LENGTH] / [get_parameter_value DWIDTH_RATIO]]
		    	
		    	if {$minimum_size > 0} {
		    		set_instance_parameter $TRAFFIC_GEN TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT      $minimum_size
		    		set_instance_parameter $TRAFFIC_GEN TG_RAND_ADDR_GEN_MIN_BURSTCOUNT     $minimum_size
		    		set_instance_parameter $TRAFFIC_GEN TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT $minimum_size
		    	} else {
		    		set_instance_parameter $TRAFFIC_GEN TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT      1
		    		set_instance_parameter $TRAFFIC_GEN TG_RAND_ADDR_GEN_MIN_BURSTCOUNT     1
		    		set_instance_parameter $TRAFFIC_GEN TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT 1
		    	}
		    }

                	if {$num_mpfe_ports > 1} {
                		set_instance_parameter $TRAFFIC_GEN TG_ENABLE_UNIX_ID "true"
                        	set_instance_parameter $TRAFFIC_GEN TG_USE_UNIX_ID ${unix_id}
                        	incr unix_id
			}
			::alt_mem_if::gui::system_info::cache_sys_info_parameters $TRAFFIC_GEN

			if {$ii == 0} {
				if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {
					set pll_master_instance "${EMIF0}"
				} else {
					set pll_master_instance "${EMIF1}"
				}
			} else {
				if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] != 0} {
					set pll_master_instance "${EMIF1}"
				} else {
					set pll_master_instance "${EMIF0}"
				}
			}
			if {[string compare -nocase [get_parameter_value CTL_HRB_ENABLED] "true"] == 0} {
				add_connection "${pll_master_instance}.afi_half_clk/${TRAFFIC_GEN}.avl_clock"
			} else {
				add_connection "${pll_master_instance}.afi_clk/${TRAFFIC_GEN}.avl_clock"
			}

			if {[string compare -nocase [get_parameter_value HARD_EMIF] "true"] == 0} {
				add_connection "global_reset.out_reset/${TRAFFIC_GEN}.avl_reset"
				if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
					add_connection "${TRAFFIC_GEN}.avl/${CONTROLLER}.avl_${jj}"
				} else {
					add_connection "${TRAFFIC_GEN}.avl/${EMIF}.avl_${jj}"
				}
			} else {
				add_connection "${pll_master_instance}.afi_reset/${TRAFFIC_GEN}.avl_reset"
				if {[string compare -nocase [get_parameter_value PHY_ONLY] "true"] == 0} {
					add_connection "${TRAFFIC_GEN}.avl/${CONTROLLER}.avl"
				} else {
					add_connection "${TRAFFIC_GEN}.avl/${EMIF}.avl"
				}
			}

			add_interface "drv_status${emif_suffix}${mpfe_suffix}" conduit end
			set_interface_property "drv_status${emif_suffix}${mpfe_suffix}" export_of "${TRAFFIC_GEN}.status"

			if {[string compare -nocase [get_parameter_value TG_PNF_ENABLE] "true"] == 0} {
				add_interface "drv_pnf${emif_suffix}${mpfe_suffix}" conduit end
				set_interface_property "drv_pnf${emif_suffix}${mpfe_suffix}" export_of "${TRAFFIC_GEN}.pnf"
				if {$ii == 0} {
					::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${TRAFFIC_GEN}" "pnf" "drv_pnf${emif_suffix}${mpfe_suffix}"
				}
			}

		}
	}

	if {[string compare -nocase [get_parameter_value ADD_NOISE_GEN] "true"] == 0} {
		::alt_mem_if::gui::noise_gen::add_noise_generator "pll_ref_clk.out_clk" "global_reset.out_reset"
	}
}


