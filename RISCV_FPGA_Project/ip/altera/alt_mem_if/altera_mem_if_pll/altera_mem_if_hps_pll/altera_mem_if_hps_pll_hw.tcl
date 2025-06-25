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


source ../../alt_mem_if_interfaces/alt_mem_if_hps_emif/common_hps_emif.tcl

set_module_property DESCRIPTION "HPS SDRAM External Memory PLL block"
set_module_property NAME altera_mem_if_hps_pll
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "HPS SDRAM External Memory PLL block"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc generate_verilog_fileset {name tmpdir fileset} {

	if {[string compare -nocase $fileset SIM_VHDL] == 0} {
		set simulation_fileset "true"
	} elseif {[string compare -nocase $fileset SIM_VERILOG] == 0} {
		set simulation_fileset "true"
	} elseif {[string compare -nocase $fileset QUARTUS_SYNTH] == 0} {
		set simulation_fileset "false"
	} else {
		_error "Fatal Error: Illegal fileset $fileset"
	}
	
	set variant_name $name

	
	set toplevel_file_name "${name}.sv"

	set toplevel_inhdl_files_list [list altera_mem_if_hps_pll.sv]

	array set ifdef_array {}
	alt_mem_if::gui::uniphy_phy::create_ifdef_parameters ifdef_array
	alt_mem_if::gui::uniphy_phy::derive_ifdef_parameters ifdef_array
	alt_mem_if::gui::common_ddrx_phy::derive_ifdef_parameters ifdef_array

	set input_module_list [list]

	set parsed_toplevel_file_list [::alt_mem_if::util::iptclgen::parse_hdl_params $name {} $tmpdir $toplevel_inhdl_files_list $input_module_list ifdef_array]
	
	alt_mem_if::util::iptclgen::sub_strings_params [file join $tmpdir [lindex $parsed_toplevel_file_list 0]] [file join $tmpdir $toplevel_file_name] [list VARIANT_OUTPUT_NAME $name SIM_FILESET $simulation_fileset]
	
	return [list [file join $tmpdir $toplevel_file_name]]
}

proc generate_vhdl_sim {name} {
	_iprint "Preparing to generate VHDL simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_verilog_phy]} {
		foreach generated_file [generate_verilog_fileset $name $tmpdir SIM_VERILOG] {
			_dprint 1 "Preparing to add $generated_file"
			set file_name [file tail $generated_file]
			add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $generated_file
		}
	} else {
		set generated_files [generate_verilog_fileset $name $tmpdir SIM_VHDL]

		alt_mem_if::util::iptclgen::generate_simgen_model $generated_files $tmpdir [::alt_mem_if::gui::system_info::get_device_family] $name [list]
	
		add_fileset_file "${name}.vho" VHDL PATH [file join $tmpdir "${name}.vho"]
	}

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	_dprint 1 "Using temporary directory $tmpdir"

	foreach generated_file [generate_verilog_fileset $name $tmpdir SIM_VERILOG] {
		set file_name [file tail $generated_file]
		_dprint 1 "Preparing to add $generated_file as $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $generated_file
	}

}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	_dprint 1 "Using temporary directory $tmpdir"
	
	foreach generated_file [generate_verilog_fileset $name $tmpdir QUARTUS_SYNTH] {
		set file_name [file tail $generated_file]
		_dprint 1 "Preparing to add $generated_file as $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $generated_file
	}

}




::alt_mem_if::util::hwtcl_utils::_add_parameter REF_CLK_PERIOD_PS INTEGER 0
set_parameter_property REF_CLK_PERIOD_PS VISIBLE false
set_parameter_property REF_CLK_PERIOD_PS DERIVED true



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
	_dprint 1 "Running IP Validation"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::common_ddrx_phy::validate_component

	set_parameter_value REF_CLK_PERIOD_PS [expr {round(1000000.0/[get_parameter_value REF_CLK_FREQ])}]
	
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component
	alt_mem_if::gui::uniphy_controller_phy::elaborate_component
	alt_mem_if::gui::uniphy_phy::elaborate_component
	alt_mem_if::gui::common_ddrx_phy::elaborate_component

	add_interface global_reset reset end
	set_interface_property global_reset synchronousEdges NONE
	
	set_interface_property global_reset ENABLED true
	
	add_interface_port global_reset global_reset_n reset_n Input 1
	
	
	add_interface pll_ref_clk clock end
	set_interface_property pll_ref_clk clockRate 0
	
	set_interface_property pll_ref_clk ENABLED true
	
	add_interface_port pll_ref_clk pll_ref_clk clk Input 1
	

	add_interface afi_clk clock start
	set_interface_property afi_clk clockRate 0
	set_interface_property afi_clk clockRateKnown true
	
	set_interface_property afi_clk ENABLED true
	
	add_interface_port afi_clk afi_clk clk Output 1

	set_interface_property afi_clk clockRate [expr {[get_parameter_value PLL_AFI_CLK_FREQ] * 1000000}]
	set_interface_property afi_clk clockRateKnown true

	
	add_interface afi_half_clk clock start
	set_interface_property afi_half_clk clockRate 0
	set_interface_property afi_half_clk clockRateKnown true
	
	set_interface_property afi_half_clk ENABLED true
	
	add_interface_port afi_half_clk afi_half_clk clk Output 1

	set_interface_property afi_half_clk clockRate [expr {[get_parameter_value PLL_AFI_HALF_CLK_FREQ] * 1000000}]
	set_interface_property afi_half_clk clockRateKnown true



	::alt_mem_if::gen::uniphy_interfaces::pll_sharing "source"

}
