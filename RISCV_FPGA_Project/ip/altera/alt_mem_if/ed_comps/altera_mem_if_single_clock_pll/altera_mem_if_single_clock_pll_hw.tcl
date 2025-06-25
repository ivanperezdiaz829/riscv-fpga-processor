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
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gen::uniphy_pll
package require alt_mem_if::gui::system_info

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "alt_mem_if Single Clock PLL"
set_module_property NAME altera_mem_if_single_clock_pll
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "alt_mem_if Single Clock PLL"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_mem_if_single_clock_pll

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL altera_mem_if_single_clock_pll

add_fileset quartus_synth QUARTUS_SYNTH generate_synth
set_fileset_property quartus_synth TOP_LEVEL altera_mem_if_single_clock_pll



proc generate_verilog_fileset {} {
	set file_list [list \
		altera_mem_if_single_clock_pll.sv \
	]
	
	return $file_list
}


proc generate_vhdl_sim {name} {
	_dprint 1 "Preparing to generate VHDL simulation fileset for $name"

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"

		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name $non_encryp_simulators

		add_fileset_file [file join mentor $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 1 1] PATH [file join mentor $file_name] {MENTOR_SPECIFIC}
	}
}

proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name
	}
}

proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	foreach file_name [generate_verilog_fileset] {
		_dprint 1 "Preparing to add $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $file_name
	}
}





alt_mem_if::gui::system_info::create_generic_parameters
set_parameter_property DEVICE_FAMILY HDL_PARAMETER true

::alt_mem_if::util::hwtcl_utils::_add_parameter REQ_CLK_FREQ float 125
set_parameter_property REQ_CLK_FREQ DISPLAY_NAME "Requested clock frequency"
set_parameter_property REQ_CLK_FREQ UNITS Megahertz
set_parameter_property REQ_CLK_FREQ DISPLAY_HINT columns:10

::alt_mem_if::gen::uniphy_pll::create_pll_clock_parameters_on_list [list "PLL_CLK"]

set_parameter_property REF_CLK_FREQ_STR HDL_PARAMETER true
set_parameter_property PLL_CLK_FREQ_STR HDL_PARAMETER true
set_parameter_property PLL_CLK_DIV HDL_PARAMETER true
set_parameter_property PLL_CLK_MULT HDL_PARAMETER true
set_parameter_property PLL_CLK_PHASE_PS HDL_PARAMETER true
set_parameter_property REF_CLK_PS HDL_PARAMETER true

set_parameter_property PLL_CLK_FREQ DISPLAY_NAME "Achieved clock frequency"

::alt_mem_if::util::hwtcl_utils::_add_parameter USE_GENERIC_PLL BOOLEAN "true"
set_parameter_property USE_GENERIC_PLL HDL_PARAMETER true
set_parameter_property USE_GENERIC_PLL DERIVED true
set_parameter_property USE_GENERIC_PLL VISIBLE false

::alt_mem_if::util::hwtcl_utils::_add_parameter ENABLE_RESET_OUTPUT BOOLEAN "false"
set_parameter_property ENABLE_RESET_OUTPUT VISIBLE true




add_display_item "Clocks" REF_CLK_FREQ PARAMETER
add_display_item "Clocks" REQ_CLK_FREQ PARAMETER
add_display_item "Clocks" PLL_CLK_FREQ PARAMETER

set pll_clock_names [list "PLL_CLK"]
foreach clk_name $pll_clock_names {
	set freq_param_name "${clk_name}_FREQ"
	set freq_sim_str_param_name "${clk_name}_FREQ_SIM_STR"
	set phase_ps_param_name "${clk_name}_PHASE_PS"
	set phase_ps_str_param_name "${clk_name}_PHASE_PS_STR"
	set phase_deg_param_name "${clk_name}_PHASE_DEG"
	set mult_param_name "${clk_name}_MULT"
	set div_param_name "${clk_name}_DIV"
	
	set_parameter_property $freq_param_name VISIBLE true
	set_parameter_property $freq_sim_str_param_name VISIBLE true
	set_parameter_property $phase_ps_param_name VISIBLE true
	set_parameter_property $phase_ps_str_param_name VISIBLE true
	set_parameter_property $mult_param_name VISIBLE true
	set_parameter_property $div_param_name VISIBLE true
	
	add_display_item "Achieved Clocks" $freq_sim_str_param_name PARAMETER
	add_display_item "Achieved Clocks" $phase_ps_param_name PARAMETER
	add_display_item "Achieved Clocks" $phase_ps_str_param_name PARAMETER
	add_display_item "Achieved Clocks" $phase_deg_param_name PARAMETER
	add_display_item "Achieved Clocks" $mult_param_name PARAMETER
	add_display_item "Achieved Clocks" $div_param_name PARAMETER
	
}



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

	set clock_list [list "PLL_CLK"]

	alt_mem_if::gui::system_info::validate_generic_component	
	
	if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixv"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixiii"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "stratixiv"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriaiigz"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "arriav"] == 0 ||
		[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "cyclonev"] == 0 ||
		[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "arriavgz"] == 0} {
	} else {
		if {[string compare -nocase [get_module_property INTERNAL] "true"] != 0 &&
			[string compare -nocase [get_module_property INTERNAL] "1"] != 0} {
			_eprint "[get_module_property DESCRIPTION] is not supported by family [get_parameter_value DEVICE_FAMILY]"
		}
		return 0
	}


	if {[string compare -nocase [get_parameter_value PRE_V_SERIES_FAMILY] "true"] == 0} {
		set_parameter_value USE_GENERIC_PLL "false"
	} else {
		set_parameter_value USE_GENERIC_PLL "true"
	}


	set_parameter_value REF_CLK_PS [ expr {int(1000000.0 / [get_parameter_value REF_CLK_FREQ])} ]

	set_parameter_value PLL_CLK_FREQ [get_parameter_value REQ_CLK_FREQ]

	set_parameter_value REF_CLK_FREQ_STR "[get_parameter_value REF_CLK_FREQ] MHz"

	set pll_clk_period [expr {1000000.0 / [get_parameter_value REQ_CLK_FREQ]}]
	set pll_clk_period_int [expr {int($pll_clk_period)}]
	set pll_clk_period_plus1_int [expr {int($pll_clk_period+1)}]
	set pll_clk_sim_period $pll_clk_period_int
	if {$pll_clk_period_int & 1} {
		set pll_clk_sim_period $pll_clk_period_plus1_int
	}
	set_parameter_value PLL_CLK_FREQ_SIM_STR $pll_clk_sim_period

	if {[string compare -nocase [get_parameter_value USE_GENERIC_PLL] "true"] == 0} {
		set solved_clock_params [list]
		::alt_mem_if::gen::uniphy_pll::_update_pll_parameters_from_pll_legality_from_list $clock_list solved_clock_params
	} else {
		::alt_mem_if::gen::uniphy_pll::_update_pll_parameters_from_computepll_from_list $clock_list
	}

	::alt_mem_if::gen::uniphy_pll::update_derived_clock_parameters_from_list $clock_list

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	add_interface pll_ref_clk clock end
	set_interface_property pll_ref_clk ENABLED true
	
	add_interface_port pll_ref_clk pll_ref_clk clk input 1

	add_interface pll_clk clock start
	set_interface_property pll_clk ENABLED true
	
	add_interface_port pll_clk pll_clk clk output 1
	set_interface_property pll_clk  clockRate [expr {[get_parameter_value PLL_CLK_FREQ] * 1000000}]
	set_interface_property pll_clk  clockRateKnown true
	
	add_interface global_reset_n reset end
	set_interface_property global_reset_n synchronousEdges NONE
	set_interface_property global_reset_n ENABLED true

	add_interface_port global_reset_n global_reset_n reset_n input 1
	
	add_interface pll_locked conduit start
	set_interface_property pll_locked ENABLED true
	
	add_interface_port pll_locked pll_locked pll_locked output 1
	
	add_interface reset_out reset source
	set_interface_property reset_out synchronousEdges NONE

	set_interface_property reset_out ENABLED true

	add_interface_port reset_out reset_out_n reset_n Output 1
	set_interface_property reset_out associatedResetSinks {global_reset_n}

	if {[string compare -nocase [get_parameter_value ENABLE_RESET_OUTPUT] "false"] == 0} {
		set_port_property reset_out_n termination true
	} else {
		set_port_property reset_out_n termination false
	}


}



