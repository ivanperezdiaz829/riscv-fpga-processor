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
package require alt_mem_if::util::qini
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::uniphy_phy
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::uniphy_oct
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::common_ddrx_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils


namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "DDR3 SDRAM External Memory Ping Pong PHY Gasket"
set_module_property NAME alt_mem_if_pp_gasket
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "DDR3 SDRAM External Memory Ping Pong PHY Gasket"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc solve_core_params {} {

	set supported_ifdefs_list [list \
		USE_SHADOW_REGS \
	]
	
	set core_params_list [list]
	
	if {[string compare -nocase [get_parameter_value USE_SHADOW_REGS] "true"] == 0} {
		lappend core_params_list "USE_SHADOW_REGS"
	}

	return $core_params_list

}




proc generate_verilog_fileset {name tmpdir} {

	set core_params_list [solve_core_params]

	set inhdl_files_list [list \
		alt_mem_if_pp_gasket.sv \
		fr_cycle_shifter_qr.v \
	]

	set generated_files_list [list]

	foreach ifdef_source_file $inhdl_files_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $ifdef_source_file $core_params_list]
		lappend generated_files_list $generated_file
	}

	_dprint 1 "Using generated files list of $generated_files_list"

	return $generated_files_list
	
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_pp_gasket.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	set generated_file "fr_cycle_shifter_qr.v"
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] VERILOG_ENCRYPT PATH [file join mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file VERILOG PATH $generated_file [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_pp_gasket.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file
	
	set generated_file "fr_cycle_shifter_qr.v"
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file VERILOG PATH $generated_file
}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_pp_gasket.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file
	
	set generated_file "fr_cycle_shifter_qr.v"
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file VERILOG PATH $generated_file
}

proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for [get_module_property NAME]"

	set_parameter_property AFI_ADDR_WIDTH      HDL_PARAMETER true
	set_parameter_property AFI_BANKADDR_WIDTH  HDL_PARAMETER true
	set_parameter_property AFI_CS_WIDTH        HDL_PARAMETER true
	set_parameter_property AFI_CLK_EN_WIDTH    HDL_PARAMETER true
	set_parameter_property AFI_ODT_WIDTH       HDL_PARAMETER true
	set_parameter_property AFI_WLAT_WIDTH      HDL_PARAMETER true
	set_parameter_property AFI_RLAT_WIDTH      HDL_PARAMETER true
	set_parameter_property AFI_DM_WIDTH        HDL_PARAMETER true
	set_parameter_property AFI_CONTROL_WIDTH   HDL_PARAMETER true
	set_parameter_property AFI_DQ_WIDTH        HDL_PARAMETER true
	set_parameter_property AFI_WRITE_DQS_WIDTH HDL_PARAMETER true
	set_parameter_property AFI_RATE_RATIO      HDL_PARAMETER true
	set_parameter_property AFI_RRANK_WIDTH      HDL_PARAMETER true
	set_parameter_property AFI_WRANK_WIDTH      HDL_PARAMETER true
	set_parameter_property AFI_CLK_PAIR_COUNT   HDL_PARAMETER true

	set_parameter_property MEM_IF_DQ_WIDTH      HDL_PARAMETER true
	set_parameter_property MEM_IF_DQS_WIDTH      HDL_PARAMETER true
	set_parameter_property MEM_IF_NUMBER_OF_RANKS HDL_PARAMETER true
	
}


alt_mem_if::gui::afi::set_protocol "DDR3"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "DDR3"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::common_ddrx_phy::set_ddr_mode "DDR3"
alt_mem_if::gui::common_ddrx_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters
alt_mem_if::gui::uniphy_oct::create_parameters

create_hdl_parameters

alt_mem_if::gui::system_info::create_gui
alt_mem_if::gui::afi::create_gui
alt_mem_if::gui::common_ddrx_phy::create_phy_gui
alt_mem_if::gui::common_ddr_mem_model::create_gui
alt_mem_if::gui::common_ddrx_phy::create_board_settings_gui
alt_mem_if::gui::common_ddrx_phy::create_diagnostics_gui




if {[string compare -nocase [::alt_mem_if::util::hwtcl_utils::combined_callbacks] "false"] == 0} {
	set_module_property Validation_Callback ip_validate
	set_module_property elaboration_Callback ip_elaborate
} else {
	set_module_property elaboration_Callback combined_callback
}

proc combined_callback {} {
	ip_validate
	ip_elaborate
}

proc ip_validate {} {
	_dprint 1 "Running IP Validation for [get_module_property NAME]"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"
	
	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component

	add_interface afi_reset reset end
	set_interface_property afi_reset synchronousEdges NONE
	set_interface_property afi_reset ENABLED true
	add_interface_port afi_reset afi_reset_n reset_n Input 1

	add_interface afi_clk clock end
	set_interface_property afi_clk ENABLED true
	add_interface_port afi_clk afi_clk clk Input 1

	::alt_mem_if::gen::uniphy_interfaces::afi "DDR3" "phy" "ctl_l" 1 1 1 1
	::alt_mem_if::gen::uniphy_interfaces::afi "DDR3" "phy" "ctl_r" 1 1 1 1
	::alt_mem_if::gen::uniphy_interfaces::afi "DDR3" "controller" "phy" 1 1 1 2


	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "alt_mem_if_pp_gasket.sv" [solve_core_params] 1]
	}

}




