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
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::uniphy_oct
package require alt_mem_if::gui::diagnostics
package require alt_mem_if::gen::uniphy_pll
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::gui::abstract_ram
package require alt_mem_if::gui::noise_gen

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera RLDRAM II External Memory Interface Example Design Simulation"
set_module_property NAME alt_mem_if_rldramii_tg_eds
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_designs_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera RLDRAM II External Memory Interface Example Design Simulation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP

alt_mem_if::gui::afi::set_protocol "RLDRAMII"
alt_mem_if::gui::common_rldram_mem_model::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_mem_model::create_parameters
alt_mem_if::gui::common_rldram_controller_phy::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_controller_phy::create_parameters
alt_mem_if::gui::common_rldram_controller::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_controller::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::common_rldram_phy::set_rldram_mode "RLDRAMII"
alt_mem_if::gui::common_rldram_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::diagnostics::create_parameters
alt_mem_if::gui::abstract_ram::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters
alt_mem_if::gui::uniphy_oct::create_parameters
alt_mem_if::gui::noise_gen::create_example_design_parameters

alt_mem_if::gui::common_rldram_phy::create_phy_gui
alt_mem_if::gui::common_rldram_mem_model::create_gui
alt_mem_if::gui::common_rldram_phy::create_board_settings_gui
alt_mem_if::gui::common_rldram_controller::create_gui
alt_mem_if::gui::common_rldram_phy::create_diagnostics_gui
alt_mem_if::gui::diagnostics::create_gui
alt_mem_if::gui::noise_gen::create_gui


add_parameter TG_NUM_DRIVER_LOOP integer 1
set_parameter_property TG_NUM_DRIVER_LOOP DISPLAY_NAME "Number of loops through patterns"
set_parameter_property TG_NUM_DRIVER_LOOP DESCRIPTION "Specifies the number of times the driver will loop through all patterns before asserting test complete. A value of 0 specifies that the driver should infinitely loop."
set_parameter_property TG_NUM_DRIVER_LOOP ALLOWED_RANGES {0:1000000}

::alt_mem_if::util::hwtcl_utils::_add_parameter TG_PNF_ENABLE boolean false
set_parameter_property TG_PNF_ENABLE DISPLAY_NAME "Generate the per-bit pass/fail signals in the status inteface"

::alt_mem_if::util::hwtcl_utils::_add_parameter EXPORT_AFI_CLK_RESET boolean false
set_parameter_property EXPORT_AFI_CLK_RESET VISIBLE false

::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_VCDPLUS BOOLEAN false
set_parameter_property ENABLE_VCDPLUS DISPLAY_NAME "Enable VCDplus in initial block"
set_parameter_property ENABLE_VCDPLUS TYPE BOOLEAN
set_parameter_property ENABLE_VCDPLUS DESCRIPTION "Use this parameter to add vcspluson to the initial block in the simulation model"

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


	set CLOCK pll_ref_clk
	add_instance $CLOCK altera_avalon_clock_source
	set_instance_parameter $CLOCK CLOCK_RATE [expr {round([get_parameter_value REF_CLK_FREQ] * 1000000.0)}]
	set_instance_parameter $CLOCK CLOCK_UNIT 1

	set RESET global_reset
	add_instance $RESET altera_avalon_reset_source
	set_instance_parameter $RESET ASSERT_HIGH_RESET 0
	set_instance_parameter $RESET INITIAL_RESET_CYCLES 5




	set ED e0
	add_instance $ED alt_mem_if_rldramii_tg_ed
	foreach param_name [get_instance_parameters $ED] {
		set_instance_parameter $ED $param_name [get_parameter_value $param_name]
	}
	set_instance_parameter $ED EXPORT_AFI_CLK_RESET true
	::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $ED
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $ED
	set_instance_parameter $ED DISABLE_CHILD_MESSAGING true

	add_connection "${CLOCK}.clk/${ED}.pll_ref_clk"
	add_connection "${CLOCK}.clk/${RESET}.clk"
	add_connection "${RESET}.reset/${ED}.global_reset"
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0 &&
	    [string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
	} else {
		add_connection "${RESET}.reset/${ED}.soft_reset"
	}
	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] == 0 &&
	    ([string compare -nocase [get_parameter_value DLL_SHARING_MODE] "none"] != 0 ||
	     [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "none"] != 0)} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0 ||
		    [string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
			add_connection "${CLOCK}.clk/${ED}.pll_ref_clk_1"
		}
	}

	set num_emif 1
	set interface_suffixes [list {}]
	if {[string compare -nocase [get_parameter_value PLL_SHARING_MODE] "none"] != 0 ||
	    [string compare -nocase [get_parameter_value DLL_SHARING_MODE] "none"] != 0 ||
	    [string compare -nocase [get_parameter_value OCT_SHARING_MODE] "none"] != 0} {
		set num_emif 2
		lappend interface_suffixes {_1}
	}




	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		if {[string compare -nocase [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {

			for {set i 0} {$i < $num_emif} {incr i} {
				set HCX_ROM_RECONFIG "h${i}"
				add_instance $HCX_ROM_RECONFIG altera_mem_if_hcx_rom_reconfig_gen
			
				set suffix [lindex $interface_suffixes $i]

				add_connection "${ED}.hcx_rom_reconfig${suffix}/${HCX_ROM_RECONFIG}.hcx_rom_reconfig"
				add_connection "${HCX_ROM_RECONFIG}.soft_reset/${ED}.soft_reset"
				set_instance_parameter $HCX_ROM_RECONFIG INIT_FILE "dut_${ED}_if${i}_s0_sequencer_mem.hex"
				set_instance_parameter $HCX_ROM_RECONFIG ROM_ADDRESS_WIDTH [get_parameter_value NIOS_ROM_ADDRESS_WIDTH]
			}
		}
	}




	if {[string compare -nocase [get_parameter_value TG_PNF_ENABLE] "true"] == 0} {
		foreach ii $interface_suffixes {
			add_interface "drv_pnf${ii}" conduit end
			set_interface_property "drv_pnf${ii}" ENABLED true
			set_interface_property "drv_pnf${ii}" export_of "${ED}.pnf${ii}"
			::alt_mem_if::util::hwtcl_utils::rename_exported_interface_ports "${ED}" "pnf${ii}" "drv_pnf${ii}"
		}
	}

	
	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0 && [string compare -nocase [get_parameter_value ED_EXPORT_SEQ_DEBUG] "true"] == 0} {
		set conn_type [get_parameter_value CORE_DEBUG_CONNECTION]
		if {[string compare -nocase $conn_type "SHARED"] == 0 || [string compare -nocase $conn_type "EXPORT"] == 0} {
			for {set i 0} {$i < $num_emif} {incr i} {
				
				set suffix [lindex $interface_suffixes $i]
				
				set debug_port "seq_debug${suffix}"
				add_interface "${debug_port}" avalon end
				set_interface_property "${debug_port}" export_of "${ED}.${debug_port}"
					
			}

			add_interface avl_clk clock start
			add_instance avl_clk altera_clock_bridge
			add_connection "${ED}.afi_clk/avl_clk.in_clk"
			set_interface_property avl_clk export_of "avl_clk.out_clk"
			
			add_interface avl_reset reset start
			add_instance avl_reset altera_reset_bridge
			set_instance_parameter avl_reset SYNCHRONOUS_EDGES none
			set_instance_parameter avl_reset ACTIVE_LOW_RESET 1
			add_connection "${ED}.afi_reset/avl_reset.in_reset"
			set_interface_property avl_reset export_of "avl_reset.out_reset"

		}
	}



	set TRAFFIC_GEN_CHECKER t0
	add_instance $TRAFFIC_GEN_CHECKER altera_mem_if_checker
	
	set_instance_parameter $TRAFFIC_GEN_CHECKER ENABLE_VCDPLUS [get_parameter_value ENABLE_VCDPLUS]
	set_instance_parameter $TRAFFIC_GEN_CHECKER NUM_STATUS_INTERFACES_TGEN $num_emif
	set_instance_parameter $TRAFFIC_GEN_CHECKER NUM_STATUS_INTERFACES $num_emif

	add_connection "${ED}.afi_clk/${TRAFFIC_GEN_CHECKER}.avl_clock"
	add_connection "${ED}.afi_reset/${TRAFFIC_GEN_CHECKER}.avl_reset"

	foreach ii $interface_suffixes {
		add_connection "${ED}.drv_status${ii}/${TRAFFIC_GEN_CHECKER}.drv_status${ii}"
		add_connection "${ED}.emif_status${ii}/${TRAFFIC_GEN_CHECKER}.emif_status${ii}"
	}




	for {set i 0} {$i < $num_emif} {incr i} {
		set MEM_MODEL "m${i}"
		add_instance $MEM_MODEL altera_mem_if_rldramii_mem_model
		foreach param_name [get_instance_parameters $MEM_MODEL] {
			set_instance_parameter $MEM_MODEL $param_name [get_parameter_value $param_name]
		}
		set_instance_parameter $MEM_MODEL DISABLE_CHILD_MESSAGING true
		
		set suffix [lindex $interface_suffixes $i]

		if {[string compare -nocase [get_parameter_value INCLUDE_BOARD_DELAY_MODEL] "true"] == 0} {




			set BOARD_DELAY_MODEL "dly${i}"
			add_instance $BOARD_DELAY_MODEL altera_rldramii_board_delay_model
			foreach param_name [get_instance_parameters $BOARD_DELAY_MODEL] {
				set_instance_parameter $BOARD_DELAY_MODEL $param_name [get_parameter_value $param_name]
			}
		
			add_connection "${ED}.memory${suffix}/${BOARD_DELAY_MODEL}.board_to_phy"

			add_connection "${BOARD_DELAY_MODEL}.board_to_mem/${MEM_MODEL}.memory"
			
		} else {

			add_connection "${ED}.memory${suffix}/${MEM_MODEL}.memory"

		}
	}




	set count 0
	foreach ii $interface_suffixes {
		::alt_mem_if::gen::uniphy_interfaces::export_rldramx_controller_sideband_interfaces "RLDRAMII" "${ED}" "$ii" "$ii" [expr {$count==0}]
		incr count
	}

}


