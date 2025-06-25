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
package require alt_mem_if::gui::qdrii_mem_model
package require alt_mem_if::gui::uniphy_phy
package require alt_mem_if::gui::qdrii_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::uniphy_dll

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "QDR II/II+ External Memory PLL/DLL/OCT block"
set_module_property NAME altera_mem_if_qdrii_pll
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "QDR II/II+ External Memory PLL/DLL/OCT block"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc generate_verilog_fileset {name tmpdir fileset {include_sim_vhdl_files 0}} {

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

	
	set toplevel_file_name "${variant_name}.sv"


	set qdir $::env(QUARTUS_ROOTDIR)
	set new_inhdl_phy_dir "${qdir}/../ip/altera/alt_mem_if/alt_mem_if_phys/common"
	set new_inhdl_dir "${qdir}/../ip/altera/alt_mem_if/altera_mem_if_pll/common"
	
	
	set megafunction_files_list [list]
	
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {

		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIII"] == 0} {
			set pll_device_family "stratix iii"
		} elseif {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXIV"] == 0} {
			set pll_device_family "stratix iv"
		} else {
			_error "Fatal Error: Unknown family [get_parameter_value DEVICE_FAMILY] for HCX compatibility"
		}

		set pll_device_speed_grade [get_parameter_value SPEED_GRADE]

		set pll_clock_names [::alt_mem_if::gen::uniphy_pll::get_pll_clock_names_list]

		set requested_pll_output_freq [list]
		set requested_pll_output_phase [list]
		foreach clk_name $pll_clock_names {
			set freq_param_name "${clk_name}_FREQ"
			set phase_param_name "${clk_name}_PHASE_DEG"
			
			lappend requested_pll_output_freq [get_parameter_value $freq_param_name]
			lappend requested_pll_output_phase [get_parameter_value $phase_param_name]
		}

		set pll_params [alt_mem_if::util::iptclgen::compute_pll_params \
				"$pll_device_family" \
				$pll_device_speed_grade \
				"fast_pll" \
				[get_parameter_value REF_CLK_FREQ] \
				$requested_pll_output_freq \
				$requested_pll_output_phase \
				$tmpdir \
				1 \
				$name]

		set megafunction_files_list [concat $megafunction_files_list [file join $tmpdir "${name}.mif"]]

	}

	set inhdl_files_list [list]
	
	if {$include_sim_vhdl_files} {
		lappend inhdl_files_list "sim_delay.vhd"
	}


	set toplevel_inhdl_files_list [list altera_mem_if_pll.sv]


	set device_family [::alt_mem_if::gui::system_info::get_device_family]
	if {[string compare -nocase $device_family "STRATIXV"] == 0 || [string compare -nocase $device_family "ARRIAVGZ"] == 0} {
		set new_inhdl_dir [file join $new_inhdl_dir sv]
	} elseif {[string compare -nocase $device_family "ARRIAV"] == 0 ||
	          [string compare -nocase $device_family "CYCLONEV"] == 0} {
		set new_inhdl_dir [file join $new_inhdl_dir acv]
	} else {
		set new_inhdl_dir [file join $new_inhdl_dir prev]
	}

	
	set input_module_list [list \
		sim_delay \
	]
	

	array set ifdef_array {}
	alt_mem_if::gui::uniphy_phy::create_ifdef_parameters ifdef_array
	alt_mem_if::gui::uniphy_phy::derive_ifdef_parameters ifdef_array
	alt_mem_if::gui::qdrii_phy::derive_ifdef_parameters ifdef_array

	set parsed_file_list [::alt_mem_if::util::iptclgen::parse_hdl_params $name $new_inhdl_phy_dir $tmpdir $inhdl_files_list $input_module_list ifdef_array]

	if {[string compare -nocase $fileset "QUARTUS_SYNTH"] == 0} {
		set fast_sim_model_default 0
	} elseif {[string compare -nocase [get_parameter_value DEFAULT_FAST_SIM_MODEL] "true"] == 0} {
		set fast_sim_model_default 1
	} else {
		set fast_sim_model_default 0
	}

	set parsed_toplevel_file_list [::alt_mem_if::util::iptclgen::parse_hdl_params $name $new_inhdl_dir $tmpdir $toplevel_inhdl_files_list $input_module_list ifdef_array]
	
	alt_mem_if::util::iptclgen::sub_strings_params [file join $tmpdir [lindex $parsed_toplevel_file_list 0]] [file join $tmpdir $toplevel_file_name] [list VARIANT_OUTPUT_NAME $variant_name SIM_FILESET $simulation_fileset "FAST_SIM_MODEL_DEFAULT" $fast_sim_model_default "MIF_FILENAME" "${variant_name}.mif"]
	
	set file_list [list]
	foreach file_name $parsed_file_list {
		lappend file_list [file join $tmpdir $file_name]
	}

	lappend file_list [file join $tmpdir $toplevel_file_name]

	set file_list [concat $megafunction_files_list $file_list]

	return $file_list	
	
}

proc generate_vhdl_sim {name} {
	_iprint "Preparing to generate VHDL simulation fileset for $name"

	set qdir $::env(QUARTUS_ROOTDIR)
	set new_inhdl_dir "${qdir}/../ip/altera/alt_mem_if/alt_mem_if_phys/common"
	set encrypted_dir [file join $new_inhdl_dir "mentor" "abstract"]

	set tmpdir [add_fileset_file {} OTHER TEMP {}]

	set bb_top_files [list]

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_verilog_phy]} {
		foreach generated_file [generate_verilog_fileset $name $tmpdir SIM_VERILOG] {
			_dprint 1 "Preparing to add $generated_file"
			set file_name [file tail $generated_file]
			add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $generated_file
		}
	} else {
		set generated_files [generate_verilog_fileset $name $tmpdir SIM_VHDL 1]

		set generated_files [concat $generated_files $bb_top_files]

		set blackbox_list [list \
			"${name}_sim_delay" \
		]
	
		set vhdl_gen_files [list \
			"${name}_sim_delay.vhd"
		]

		alt_mem_if::util::iptclgen::generate_simgen_model $generated_files $tmpdir [::alt_mem_if::gui::system_info::get_device_family] $name $blackbox_list
	
		add_fileset_file "${name}.vho" VHDL PATH [file join $tmpdir "${name}.vho"]
		foreach vhdl_file $vhdl_gen_files {
			set file_name [file tail $vhdl_file]
			add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH [file join $tmpdir $file_name]
		}

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



alt_mem_if::gui::afi::set_protocol "QDRII"
alt_mem_if::gui::qdrii_mem_model::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::qdrii_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters

alt_mem_if::gui::system_info::create_gui
alt_mem_if::gui::afi::create_gui
alt_mem_if::gui::qdrii_phy::create_phy_gui
alt_mem_if::gui::qdrii_mem_model::create_gui
alt_mem_if::gui::qdrii_phy::create_board_settings_gui
alt_mem_if::gui::qdrii_phy::create_diagnostics_gui



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
	alt_mem_if::gui::qdrii_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::qdrii_phy::validate_component

	set_parameter_value REF_CLK_PERIOD_PS [expr {round(1000000.0/[get_parameter_value REF_CLK_FREQ])}]
	
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::qdrii_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component
	alt_mem_if::gui::uniphy_phy::elaborate_component
	alt_mem_if::gui::qdrii_phy::elaborate_component

	add_interface global_reset reset end
	set_interface_property global_reset synchronousEdges NONE
	
	set_interface_property global_reset ENABLED true
	
	add_interface_port global_reset global_reset_n reset_n Input 1
	
	
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



	add_interface pll_ref_clk clock end
	set_interface_property pll_ref_clk clockRate 0
	
	set_interface_property pll_ref_clk ENABLED true
	
	add_interface_port pll_ref_clk pll_ref_clk clk Input 1
	


	::alt_mem_if::gen::uniphy_interfaces::pll_sharing "source"


	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] ==0} {
		::alt_mem_if::gen::uniphy_interfaces::hcx_pll_reconfig
	}


}
