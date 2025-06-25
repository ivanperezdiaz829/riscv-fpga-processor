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
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "Altera DDR2 AFI Multiplexer"
set_module_property NAME altera_mem_if_ddr2_afi_mux
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_afi_mux_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera DDR2 AFI Multiplexer"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_SOPC true

add_display_item "" "Block Diagram" GROUP

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc solve_core_params {} {

	set supported_ifdefs_list [list \
		DDRX \
		DDR3 \
		LPDDR2 \
		QDRII \
		RLDRAMX \
		RLDRAM3 \
		DDRIISRAM \
		LPDDR1
	]

	set core_params_list [list]

	
	lappend core_params_list "DDRX"
	
	return $core_params_list
	
}


proc generate_verilog_fileset {name tmpdir} {

	
	set core_params_list [solve_core_params]

	set inhdl_files_list [list \
		afi_mux.v \
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

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "afi_mux.v" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] VERILOG_ENCRYPT PATH [file join ".." common mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file VERILOG PATH [file join ".." common $generated_file] [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "afi_mux.v" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file VERILOG PATH [file join ".." common $generated_file]

}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "afi_mux.v" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file VERILOG PATH [file join ".." common $generated_file]

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
}


alt_mem_if::gui::afi::set_protocol "DDR2"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "DDR2"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters


create_hdl_parameters


alt_mem_if::gui::common_ddr_mem_model::create_gui



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
	_dprint 1 "Running IP Elaboration for [get_module_property NAME]"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component

	add_interface clk clock end
	set_interface_property clk ENABLED true
	add_interface_port clk clk clk Input 1

	::alt_mem_if::gen::uniphy_interfaces::afi "DDR2" "phy" "afi" 1 1
	::alt_mem_if::gen::uniphy_interfaces::afi "DDR2" "phy" "seq_mux" 1 0
	::alt_mem_if::gen::uniphy_interfaces::afi "DDR2" "controller" "phy_mux" 1 1

	::alt_mem_if::gen::uniphy_interfaces::mux_selector "afi_mux"

	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "afi_mux.v" [solve_core_params] 1]
	}

}
