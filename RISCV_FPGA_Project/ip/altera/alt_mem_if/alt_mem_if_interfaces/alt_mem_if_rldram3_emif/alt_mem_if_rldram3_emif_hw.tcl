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
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::uniphy_oct

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "RLDRAM 3 UniPHY"
set_module_property NAME altera_mem_if_rldram3_emif
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "[::alt_mem_if::util::hwtcl_utils::mem_ifs_group_name]/RLDRAM 3 Interfaces"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "RLDRAM 3 UniPHY"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property DATASHEET_URL "http://www.altera.com/literature/lit-external-memory-interface.jsp"

set_module_assignment "testbench.partner.map.memory" "mem_model.memory"
set_module_assignment "testbench.partner.mem_model.class" "altera_mem_if_rldram3_mem_model"


add_display_item "" "Block Diagram" GROUP

alt_mem_if::gui::afi::set_protocol "RLDRAM3"
alt_mem_if::gui::common_rldram_mem_model::set_rldram_mode "RLDRAM3"
alt_mem_if::gui::common_rldram_mem_model::create_parameters
set mem_model_param_list [split [get_parameters]]
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

alt_mem_if::gui::common_rldram_phy::create_phy_gui
alt_mem_if::gui::common_rldram_mem_model::create_gui
alt_mem_if::gui::common_rldram_phy::create_board_settings_gui
alt_mem_if::gui::common_rldram_phy::create_diagnostics_gui




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
	
	if {[string compare -nocase [get_parameter_value USER_DEBUG_LEVEL] "0"] != 0 &&
		[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0 &&
	    [string compare -nocase [get_parameter_value SOPC_COMPAT_RESET] "true"] == 0} {
			_eprint "'[get_parameter_property USER_DEBUG_LEVEL DISPLAY_NAME]' must be set to 'No Debugging' when '[get_parameter_property SOPC_COMPAT_RESET DISPLAY_NAME]' is enabled"
	}

}

proc ip_compose {} {

	_dprint 1 "Running IP Compose for [get_module_property NAME]"

	::alt_mem_if::util::hwtcl_utils::print_user_parameter_values



	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0 ||
	    [string compare -nocase [get_parameter_value SOPC_COMPAT_RESET] "true"] == 0} {
		add_interface pll_ref_clk clock end
		add_instance pll_ref_clk altera_clock_bridge
		set_interface_property pll_ref_clk export_of pll_ref_clk.in_clk 
		set_interface_property pll_ref_clk PORT_NAME_MAP { pll_ref_clk in_clk }
	}
	
	add_interface global_reset reset end
	add_instance global_reset altera_reset_bridge
	set_interface_property global_reset export_of global_reset.in_reset
	if {[string compare -nocase [get_parameter_value SOPC_COMPAT_RESET] "true"] == 0} {
		set_instance_parameter global_reset SYNCHRONOUS_EDGES deassert
		add_connection "pll_ref_clk.out_clk/global_reset.clk"
	} else {
		set_instance_parameter global_reset SYNCHRONOUS_EDGES none
	}
	set_instance_parameter global_reset ACTIVE_LOW_RESET 1
	set_interface_property global_reset PORT_NAME_MAP { global_reset_n in_reset_n }
	
	add_interface soft_reset reset end
	add_instance soft_reset altera_reset_bridge
	set_interface_property soft_reset export_of soft_reset.in_reset
	if {[string compare -nocase [get_parameter_value SOPC_COMPAT_RESET] "true"] == 0} {
		set_instance_parameter soft_reset SYNCHRONOUS_EDGES deassert
		add_connection "pll_ref_clk.out_clk/soft_reset.clk"
	} else {
		set_instance_parameter soft_reset SYNCHRONOUS_EDGES none
	}
	set_instance_parameter soft_reset ACTIVE_LOW_RESET 1
	set_interface_property soft_reset PORT_NAME_MAP { soft_reset_n in_reset_n }

	set num_afi_clk_outputs 1
	set num_afi_reset_outputs 1

	set csr_num_clks 0
	set csr_num_resets 0

	set seq_debug_num_clks 0
	set seq_debug_num_resets 0
	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "EXPORT"] == 0} {
			incr seq_debug_num_clks 1
			incr seq_debug_num_resets 1
		} elseif {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "INTERNAL_JTAG"] == 0} {
			incr seq_debug_num_clks 1
		} elseif {[string compare -nocase [get_parameter_value CORE_DEBUG_CONNECTION] "SHARED"] == 0} {
			incr seq_debug_num_clks 2
			incr seq_debug_num_resets 1
		}
	}

	set num_afi_clk_outputs [expr $num_afi_clk_outputs + (($seq_debug_num_clks > $csr_num_clks) ? $seq_debug_num_clks : $csr_num_clks)] 
	set num_afi_reset_outputs [expr $num_afi_reset_outputs + (($seq_debug_num_resets > $csr_num_resets) ? $seq_debug_num_resets : $csr_num_resets)] 
	
	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] == 0 ||
	     [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] == 0} {

		add_interface afi_clk clock start
		add_instance afi_clk altera_clock_bridge
		set_instance_parameter afi_clk NUM_CLOCK_OUTPUTS $num_afi_clk_outputs
		set_interface_property afi_clk export_of afi_clk.out_clk
		set_interface_property afi_clk PORT_NAME_MAP { afi_clk out_clk }
		
		add_interface afi_half_clk clock start
		add_instance afi_half_clk altera_clock_bridge
		set_interface_property afi_half_clk export_of afi_half_clk.out_clk
		set_interface_property afi_half_clk PORT_NAME_MAP { afi_half_clk out_clk }

		add_interface afi_reset reset source
		add_instance afi_reset altera_reset_bridge
		set_instance_parameter afi_reset NUM_RESET_OUTPUTS $num_afi_reset_outputs
		set_interface_property afi_reset export_of afi_reset.out_reset
		if {[string compare -nocase [get_parameter_value SOPC_COMPAT_RESET] "true"] == 0} {
			set_instance_parameter afi_reset SYNCHRONOUS_EDGES deassert
		} else {
			set_instance_parameter afi_reset SYNCHRONOUS_EDGES none
		}
		set_instance_parameter afi_reset ACTIVE_LOW_RESET 1
		set_interface_property afi_reset PORT_NAME_MAP { afi_reset_n out_reset_n }
		add_interface afi_reset_export reset source
		add_instance afi_reset_export altera_reset_bridge
		set_instance_parameter afi_reset_export NUM_RESET_OUTPUTS $num_afi_clk_outputs
		set_interface_property afi_reset_export export_of afi_reset_export.out_reset
		if {[string compare -nocase [get_parameter_value SOPC_COMPAT_RESET] "true"] == 0} {
			set_instance_parameter afi_reset_export SYNCHRONOUS_EDGES deassert
		} else {
			set_instance_parameter afi_reset_export SYNCHRONOUS_EDGES none
		}
		set_instance_parameter afi_reset_export ACTIVE_LOW_RESET 1
		set_interface_property afi_reset_export PORT_NAME_MAP { afi_reset_export_n out_reset_n }

	} elseif { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {

		add_interface afi_clk_in clock end
		add_instance afi_clk altera_clock_bridge
		set_instance_parameter afi_clk NUM_CLOCK_OUTPUTS $num_afi_clk_outputs
		set_interface_property afi_clk_in export_of afi_clk.in_clk 
		set_interface_property afi_clk_in PORT_NAME_MAP { afi_clk in_clk }
		
		add_interface afi_half_clk_in clock end
		add_instance afi_half_clk altera_clock_bridge
		set_interface_property afi_half_clk_in export_of afi_half_clk.in_clk 
		set_interface_property afi_half_clk_in PORT_NAME_MAP { afi_half_clk in_clk }
		
		add_interface afi_reset_in reset end
		add_instance afi_reset altera_reset_bridge
		set_instance_parameter afi_reset NUM_RESET_OUTPUTS $num_afi_reset_outputs
		set_interface_property afi_reset_in export_of afi_reset.in_reset
		set_instance_parameter afi_reset SYNCHRONOUS_EDGES none
		set_instance_parameter afi_reset ACTIVE_LOW_RESET 1
		set_interface_property afi_reset_in PORT_NAME_MAP { afi_reset_n in_reset_n }

	}




	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {

		set PLL pll0
		add_instance $PLL altera_mem_if_rldram3_pll
		foreach param_name [get_instance_parameters $PLL] {
			set_instance_parameter $PLL $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $PLL
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $PLL
		set_instance_parameter $PLL DISABLE_CHILD_MESSAGING true

		add_connection "pll_ref_clk.out_clk/${PLL}.pll_ref_clk"
		add_connection "global_reset.out_reset/${PLL}.global_reset"

		add_connection "${PLL}.afi_clk/afi_clk.in_clk"
		add_connection "${PLL}.afi_half_clk/afi_half_clk.in_clk"

		if {[string compare -nocase [get_parameter_value SOPC_COMPAT_RESET] "true"] == 0} {
			add_connection "${PLL}.afi_clk/afi_reset.clk"
			add_connection "${PLL}.afi_clk/afi_reset_export.clk"
		}

	}




	set PHY p0
	if {[string compare -nocase [get_parameter_value USE_FAKE_PHY] "true"] == 0 ||
		[string compare -nocase [get_parameter_value USE_FAKE_PHY_INTERNAL] "true"] == 0} {
		_error "There is no fake PHY support for RLDRAM3"
	} else {
		if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
			_error "There is no hard PHY support for RLDRAM3"
		} else {
			add_instance $PHY altera_mem_if_rldram3_phy_core
		}
	}
	foreach param_name [get_instance_parameters $PHY] {
		if {[string compare -nocase $param_name "AVL_ADDR_WIDTH"] == 0 ||
			[string compare -nocase $param_name "AVL_DATA_WIDTH"] == 0} {
			continue
		}
		set_instance_parameter $PHY $param_name [get_parameter_value $param_name]
	}
	if {[string compare -nocase [get_parameter_value HARD_PHY] "false"] == 0} {
		::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $PHY
	}
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $PHY
	set_instance_parameter $PHY DISABLE_CHILD_MESSAGING true

	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
		set afi_clk_source "afi_clk.out_clk"
		set afi_half_clk_source "afi_half_clk.out_clk"
		set afi_reset_source "afi_reset.out_reset"
	} else {
		set afi_clk_source "${PLL}.afi_clk"
		set afi_half_clk_source "${PLL}.afi_half_clk"
		set afi_reset_source "${PHY}.afi_reset"
	}
	add_connection "soft_reset.out_reset/${PHY}.soft_reset"
	add_connection "global_reset.out_reset/${PHY}.global_reset"
	add_connection "${afi_clk_source}/${PHY}.afi_clk"
	add_connection "${afi_half_clk_source}/${PHY}.afi_half_clk"
	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {
	} else {
		add_connection "${PHY}.afi_reset_export/afi_reset_export.in_reset"
		add_connection "${afi_reset_source}/afi_reset.in_reset"
	}

	add_interface memory conduit end
	set_interface_property memory export_of "${PHY}.memory"
	alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY memory memory
	set_interface_assignment "memory" "qsys.ui.export_name" "memory"

	if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
		upvar 1 mem_model_param_list mem_model_param_list
	} else {
		upvar 2 mem_model_param_list mem_model_param_list
	}
	foreach param_name $mem_model_param_list {
		set_module_assignment "testbench.partner.mem_model.parameter.${param_name}" [get_parameter_value $param_name]
	}



	if {[string compare -nocase [get_parameter_value USE_FAKE_PHY] "true"] == 0 ||
		[string compare -nocase [get_parameter_value USE_FAKE_PHY_INTERNAL] "true"] == 0 ||
	    [string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {


	} else {

		set AFI_MUX m0
		add_instance $AFI_MUX altera_mem_if_rldram3_afi_mux
		foreach param_name [get_instance_parameters $AFI_MUX] {
			set_instance_parameter $AFI_MUX $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $AFI_MUX
		set_instance_parameter $AFI_MUX DISABLE_CHILD_MESSAGING true

		add_connection "${AFI_MUX}.phy_mux/${PHY}.afi"

	}




	if {[string compare -nocase [get_parameter_value USE_FAKE_PHY] "true"] == 0 ||
		[string compare -nocase [get_parameter_value USE_FAKE_PHY_INTERNAL] "true"] == 0} {


	} else {

		set SEQ s0
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
			add_instance $SEQ altera_mem_if_rldram3_qseq
		} elseif {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "RTL"] == 0} {
			_error "There is no RTL sequencer support for RLDRAM 3"
		} else {
			_error "Illegal value [get_parameter_value SEQUENCER_TYPE] for [get_parameter_property SEQUENCER_TYPE DISPLAY_NAME]"
		}
		foreach param_name [get_instance_parameters $SEQ] {
			if {[string compare -nocase $param_name "AVL_ADDR_WIDTH"] == 0 ||
				[string compare -nocase $param_name "AVL_DATA_WIDTH"] == 0} {
				continue
			}
			set_instance_parameter $SEQ $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $SEQ
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $SEQ
		set_instance_parameter $SEQ DISABLE_CHILD_MESSAGING true

		if {[string compare -nocase [get_parameter_value HARD_PHY] "false"] == 0} {
			add_connection "${afi_clk_source}/${SEQ}.afi_clk"
			add_connection "${afi_reset_source}/${SEQ}.afi_reset"
		}
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
			add_connection "${PHY}.avl_clk/${SEQ}.avl_clk"
			add_connection "${PHY}.avl_reset/${SEQ}.avl_reset"
			add_connection "${PHY}.scc_clk/${SEQ}.scc_clk"
			add_connection "${PHY}.scc_reset/${SEQ}.scc_reset"
		}

		if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
			add_connection "${SEQ}.avl/${PHY}.avl"
		} else {
			add_connection "${SEQ}.afi/${AFI_MUX}.seq_mux"
			add_connection "${SEQ}.mux_sel/${AFI_MUX}.mux_sel"
			add_connection "${SEQ}.phy/${PHY}.phy"
			add_connection "${SEQ}.calib/${PHY}.calib"
		}
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
			add_connection "${SEQ}.scc/${PHY}.scc"
		}

		::alt_mem_if::gen::uniphy_interfaces::add_toolkit_master "${PHY}.avl_clk" "${PHY}.avl_reset" "${SEQ}.seq_debug" "${PHY}.csr_soft_reset_req" 
	}



	if {[string compare -nocase [get_parameter_value PHY_ONLY] "false"] == 0} {

		set CONTROLLER c0
		::alt_mem_if::gen::uniphy_gen::instantiate_rldramx_controller "RLDRAM3" $CONTROLLER $afi_clk_source $afi_reset_source

		if {[string compare -nocase [get_parameter_value USE_FAKE_PHY] "true"] == 0 ||
		    [string compare -nocase [get_parameter_value USE_FAKE_PHY_INTERNAL] "true"] == 0} {
			add_connection "${CONTROLLER}.afi/${PHY}.afi"
		} else {
			if {[string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {
				add_connection "${CONTROLLER}.afi/${PHY}.afi"
			} else {
				add_connection "${CONTROLLER}.afi/${AFI_MUX}.afi"
			}
		}

		::alt_mem_if::gen::uniphy_interfaces::export_controller_status_interface $CONTROLLER status status
		::alt_mem_if::gen::uniphy_interfaces::export_rldramx_controller_sideband_interfaces "RLDRAM3" $CONTROLLER

	} else {

		if {[string compare -nocase [get_parameter_value USE_FAKE_PHY] "true"] == 0 ||
		    [string compare -nocase [get_parameter_value USE_FAKE_PHY_INTERNAL] "true"] == 0 ||
		    [string compare -nocase [get_parameter_value HARD_PHY] "true"] == 0} {

			add_interface afi conduit end
			set_interface_property afi export_of "${PHY}.afi"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY afi afi

		} else {

			add_interface afi conduit end
			set_interface_property afi export_of "${AFI_MUX}.afi"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $AFI_MUX afi afi
		}

	}




	if { [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "slave"] != 0} {

		set OCT oct0
		add_instance $OCT altera_mem_if_oct
		foreach param_name [get_instance_parameters $OCT] {
			set_instance_parameter $OCT $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $OCT
		set_instance_parameter $OCT DISABLE_CHILD_MESSAGING true

	}




	if { [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "slave"] != 0} {
		add_interface oct conduit end
		set_interface_property oct export_of "${OCT}.oct"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $OCT oct oct
		set_interface_assignment "oct" "qsys.ui.export_name" "oct"
	}

	if { [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "none"] == 0} {

		add_connection "${OCT}.oct_sharing/${PHY}.oct_sharing"

	} elseif { [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "master"] == 0} {

		set OCT_BRIDGE oct_bridge
		add_instance $OCT_BRIDGE altera_mem_if_oct_bridge
		foreach param_name [get_instance_parameters $OCT_BRIDGE] {
			set_instance_parameter $OCT_BRIDGE $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $OCT_BRIDGE
		set_instance_parameter $OCT_BRIDGE DISABLE_CHILD_MESSAGING true

		add_connection "${OCT}.oct_sharing/${OCT_BRIDGE}.oct_sharing_in"
		add_connection "${OCT_BRIDGE}.oct_sharing/${PHY}.oct_sharing"

		for {set ii 0} {$ii < [get_parameter_value NUM_OCT_SHARING_INTERFACES]} {incr ii} {
			if {$ii == 0} {
				set suffix {}
			} else {
				set suffix "_${ii}"
			}
			add_interface oct_sharing${suffix} conduit end
			set_interface_property oct_sharing${suffix} export_of "${OCT_BRIDGE}.oct_sharing${suffix}"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $OCT_BRIDGE "oct_sharing${suffix}" "oct_sharing${suffix}"
		}

	} elseif { [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "slave"] == 0} {

		add_interface oct_sharing conduit end
		set_interface_property oct_sharing export_of "${PHY}.oct_sharing"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY oct_sharing oct_sharing

	}



	if { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] == 0 ||
	     [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "master"] == 0 } {

		set PLL_BRIDGE pll_bridge
		add_instance $PLL_BRIDGE altera_mem_if_pll_bridge
		foreach param_name [get_instance_parameters $PLL_BRIDGE] {
			set_instance_parameter $PLL_BRIDGE $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $PLL_BRIDGE
		set_instance_parameter $PLL_BRIDGE DISABLE_CHILD_MESSAGING true

		add_connection "${PLL}.pll_sharing/${PLL_BRIDGE}.pll_sharing_in"
		add_connection "${PLL_BRIDGE}.pll_sharing/${PHY}.pll_sharing"

		for {set ii 0} {$ii < [get_parameter_value NUM_PLL_SHARING_INTERFACES]} {incr ii} {
			if {$ii == 0} {
				set suffix {}
			} else {
				set suffix "_${ii}"
			}
			add_interface pll_sharing${suffix} conduit end
			set_interface_property pll_sharing${suffix} export_of "${PLL_BRIDGE}.pll_sharing${suffix}"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PLL_BRIDGE "pll_sharing${suffix}" "pll_sharing${suffix}"
		}

	} elseif { [string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] == 0} {

		add_interface pll_sharing conduit end
		set_interface_property pll_sharing export_of "${PHY}.pll_sharing"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY pll_sharing pll_sharing

	}




	if { [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] != 0} {

		set DLL dll0
		add_instance $DLL altera_mem_if_dll
		foreach param_name [get_instance_parameters $DLL] {
			set_instance_parameter $DLL $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $DLL
		set_instance_parameter $DLL DISABLE_CHILD_MESSAGING true

		add_connection "${PHY}.dll_clk/${DLL}.clk"
	}



	if { [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "none"] == 0} {
	
		add_connection "${DLL}.dll_sharing/${PHY}.dll_sharing"

	} elseif { [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "master"] == 0} {
	
		set DLL_BRIDGE dll_bridge
		add_instance $DLL_BRIDGE altera_mem_if_dll_bridge
		foreach param_name [get_instance_parameters $DLL_BRIDGE] {
			set_instance_parameter $DLL_BRIDGE $param_name [get_parameter_value $param_name]
		}
		::alt_mem_if::gui::system_info::cache_sys_info_parameters $DLL_BRIDGE
		set_instance_parameter $DLL_BRIDGE DISABLE_CHILD_MESSAGING true

		add_connection "${DLL}.dll_sharing/${DLL_BRIDGE}.dll_sharing_in"
		add_connection "${DLL_BRIDGE}.dll_sharing_x/${PHY}.dll_sharing"

		for {set ii 0} {$ii < [get_parameter_value NUM_DLL_SHARING_INTERFACES]} {incr ii} {
			if {$ii == 0} {
				set suffix {}
			} else {
				set suffix "_${ii}"
			}
			add_interface dll_sharing${suffix} conduit end
			set_interface_property dll_sharing${suffix} export_of "${DLL_BRIDGE}.dll_sharing${suffix}"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $DLL_BRIDGE "dll_sharing${suffix}" "dll_sharing${suffix}"
		}

	} elseif { [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] == 0} {

		add_interface dll_sharing conduit end
		set_interface_property dll_sharing export_of "${PHY}.dll_sharing"
		alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY dll_sharing dll_sharing

	}



	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "none"] == 0} {

			add_interface hcx_dll_reconfig conduit end
			set_interface_property hcx_dll_reconfig export_of "${DLL}.hcx_dll_reconfig"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $DLL hcx_dll_reconfig hcx_dll_reconfig

			add_connection "${DLL}.hcx_dll_sharing/${PHY}.hcx_dll_sharing"

		} elseif {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "master"] == 0} {

			add_interface hcx_dll_reconfig conduit end
			set_interface_property hcx_dll_reconfig export_of "${DLL}.hcx_dll_reconfig"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $DLL hcx_dll_reconfig hcx_dll_reconfig

			add_connection "${DLL}.hcx_dll_sharing/${DLL_BRIDGE}.hcx_dll_sharing_in"
			add_connection "${DLL_BRIDGE}.hcx_dll_sharing_x/${PHY}.hcx_dll_sharing"

			for {set ii 0} {$ii < [get_parameter_value NUM_DLL_SHARING_INTERFACES]} {incr ii} {
				if {$ii == 0} {
					set suffix {}
				} else {
					set suffix "_${ii}"
				}
				add_interface hcx_dll_sharing${suffix} conduit end
				set_interface_property hcx_dll_sharing${suffix} export_of "${DLL_BRIDGE}.hcx_dll_sharing${suffix}"
				alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $DLL_BRIDGE "hcx_dll_sharing${suffix}" "hcx_dll_sharing${suffix}"
			}

		} elseif {[string compare -nocase [get_parameter_value DLL_SHARING_MODE] "slave"] == 0} {

			add_interface hcx_dll_sharing conduit end
			set_interface_property hcx_dll_sharing export_of "${PHY}.hcx_dll_sharing"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PHY hcx_dll_sharing hcx_dll_sharing

		}
	}
	


	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] ==0} {
		if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "slave"] != 0} {
			add_interface hcx_pll_reconfig conduit end
			set_interface_property hcx_pll_reconfig export_of "${PLL}.hcx_pll_reconfig"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $PLL hcx_pll_reconfig hcx_pll_reconfig
		}
	}
	


	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] ==0} {
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] ==0} {
			add_interface hcx_rom_reconfig conduit end
			set_interface_property hcx_rom_reconfig export_of "${SEQ}.hcx_rom_reconfig"
			alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports $SEQ hcx_rom_reconfig hcx_rom_reconfig
		}
	}

	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		_dprint 1 "add core debug interface"
		::alt_mem_if::gen::uniphy_interfaces::add_core_debug_interface "${SEQ}" 
	}
}



add_fileset example_design EXAMPLE_DESIGN generate_example

proc generate_example {name} {

	alt_mem_if::gen::uniphy_gen::generate_example_design_fileset "RLDRAM3" $name

}

