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
package require alt_mem_if::gui::common_rldram_mem_model
package require alt_mem_if::gui::common_rldram_controller_phy
package require alt_mem_if::gui::common_rldram_controller
package require alt_mem_if::gui::uniphy_phy
package require alt_mem_if::gui::common_rldram_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gui::diagnostics
package require alt_mem_if::gen::uniphy_pll
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::uniphy_oct
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::gui::noise_gen

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera RLDRAM 3 External Memory Interface Example Design"
set_module_property NAME alt_mem_if_rldram3_tg_ed
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_designs_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera RLDRAM 3 External Memory Interface Example Design"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP

alt_mem_if::gui::afi::set_protocol "RLDRAM3"
alt_mem_if::gui::common_rldram_mem_model::set_rldram_mode "RLDRAM3"
alt_mem_if::gui::common_rldram_mem_model::create_parameters
alt_mem_if::gui::common_rldram_controller_phy::set_rldram_mode "RLDRAM3"
alt_mem_if::gui::common_rldram_controller_phy::create_parameters
alt_mem_if::gui::common_rldram_controller::set_rldram_mode "RLDRAM3"
alt_mem_if::gui::common_rldram_controller::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::common_rldram_phy::set_rldram_mode "RLDRAM3"
alt_mem_if::gui::common_rldram_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::diagnostics::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters
alt_mem_if::gui::uniphy_oct::create_parameters
alt_mem_if::gui::noise_gen::create_example_design_parameters

alt_mem_if::gui::common_rldram_phy::create_phy_gui
alt_mem_if::gui::common_rldram_mem_model::create_gui
alt_mem_if::gui::common_rldram_phy::create_board_settings_gui
alt_mem_if::gui::common_rldram_phy::create_diagnostics_gui
alt_mem_if::gui::diagnostics::create_gui
alt_mem_if::gui::noise_gen::create_gui



add_parameter TG_NUM_DRIVER_LOOP integer 1000
set_parameter_property TG_NUM_DRIVER_LOOP DISPLAY_NAME "Number of loops through patterns"
set_parameter_property TG_NUM_DRIVER_LOOP DESCRIPTION "Specifies the number of times the driver will loop through all patterns before asserting test complete. A value of 0 specifies that the driver should infinitely loop."
set_parameter_property TG_NUM_DRIVER_LOOP ALLOWED_RANGES {0:1000000}

::alt_mem_if::util::hwtcl_utils::_add_parameter TG_PNF_ENABLE boolean false
set_parameter_property TG_PNF_ENABLE DISPLAY_NAME "Generate the per-bit pass/fail signals in the status inteface"

::alt_mem_if::util::hwtcl_utils::_add_parameter EXPORT_AFI_CLK_RESET boolean false
set_parameter_property EXPORT_AFI_CLK_RESET VISIBLE false

::alt_mem_if::util::hwtcl_utils::_add_parameter TG_USE_LITE_DRIVER boolean false
set_parameter_property TG_USE_LITE_DRIVER DISPLAY_NAME "Use the internal lite driver"
set_parameter_property TG_USE_LITE_DRIVER VISIBLE false


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
	alt_mem_if::gui::common_rldram_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_oct::validate_component
	alt_mem_if::gui::common_rldram_controller_phy::validate_component
	alt_mem_if::gui::common_rldram_controller::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::common_rldram_phy::validate_component
	alt_mem_if::gui::diagnostics::validate_component [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE]


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

	set EMIF0 "if0"
	set EMIF1 "if1"
	set DRIVER0 "d0"
	set DRIVER1 "d1"




	for {set ii 0} {$ii < $num_emif} {incr ii} {
		set EMIF "if${ii}"
		add_instance $EMIF altera_mem_if_rldram3_emif
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

		if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
			_dprint 1 "Exporting core debug bridge"
			set conn_type [get_parameter_value CORE_DEBUG_CONNECTION]
			if {[string compare -nocase $conn_type "SHARED"] == 0 || [string compare -nocase $conn_type "EXPORT"] == 0} {
				if {$ii == 0 && [string compare -nocase [get_parameter_value ADD_EXTERNAL_SEQ_DEBUG_NIOS] "true"] == 0} {
					::alt_mem_if::gen::uniphy_interfaces::add_external_seq_debug_nios "${EMIF}"
				} elseif {[string compare -nocase [get_parameter_value ED_EXPORT_SEQ_DEBUG] "true"] == 0} {
					set debug_port "seq_debug"
					add_interface "${debug_port}${suffix}" avalon end
					set_interface_property "${debug_port}${suffix}" export_of "${EMIF}.${debug_port}"
					if {$ii == 0} {
						::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${EMIF}" "${debug_port}" "${debug_port}${suffix}"
					}
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
		add_connection "${EMIF1}.afi_reset_export/${EMIF0}.afi_reset_in"
	} else {
		if {[string compare -nocase [get_parameter_value EXPORT_AFI_CLK_RESET] "true"] == 0 || [string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
			add_connection "${EMIF0}.afi_clk/afi_clk.in_clk"
			add_connection "${EMIF0}.afi_half_clk/afi_half_clk.in_clk"
			add_connection "${EMIF0}.afi_reset/afi_reset.in_reset"
		}
		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] == 0} {
			add_connection "${EMIF0}.afi_clk/${EMIF1}.afi_clk_in"
			add_connection "${EMIF0}.afi_half_clk/${EMIF1}.afi_half_clk_in"
			add_connection "${EMIF0}.afi_reset_export/${EMIF1}.afi_reset_in"
		}
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




	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {
		::alt_mem_if::gen::uniphy_gen::instantiate_rldramx_controller "RLDRAM3" "${DRIVER0}" "${EMIF0}.afi_clk" "${EMIF0}.afi_reset"
	} else {
		::alt_mem_if::gen::uniphy_gen::instantiate_rldramx_controller "RLDRAM3" "${DRIVER0}" "${EMIF1}.afi_clk" "${EMIF1}.afi_reset"
	}

	add_connection "${DRIVER0}.afi/${EMIF0}.afi"

	::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${DRIVER0}" "status" "emif_status"

	if {$num_emif == 2} {

		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] != 0} {
			::alt_mem_if::gen::uniphy_gen::instantiate_rldramx_controller "RLDRAM3" "${DRIVER1}" "${EMIF1}.afi_clk" "${EMIF1}.afi_reset" 0
		} else {
			::alt_mem_if::gen::uniphy_gen::instantiate_rldramx_controller "RLDRAM3" "${DRIVER1}" "${EMIF0}.afi_clk" "${EMIF0}.afi_reset" 0
		}

		add_connection "${DRIVER1}.afi/${EMIF1}.afi"

		::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface "${DRIVER1}" "status" "emif_status_1" 0
	}


	if {[string compare -nocase [get_parameter_value ADD_NOISE_GEN] "true"] == 0} {
		::alt_mem_if::gui::noise_gen::add_noise_generator "pll_ref_clk.out_clk" "global_reset.out_reset"
	}
}


