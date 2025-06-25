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
package require alt_mem_if::gui::diagnostics

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "QDRII RTL Sequencer"
set_module_property NAME altera_mem_if_qdrii_rseq
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencers_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "QDRII RTL Sequencer"
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
	set new_inhdl_common_dir "${qdir}/../ip/altera/alt_mem_if/altera_mem_if_rseq/common"
	set new_inhdl_dir "${qdir}/../ip/altera/alt_mem_if/altera_mem_if_rseq/altera_mem_if_qdrii_rseq"
	
	
	set inhdl_files_list [list \
		sequencer.sv \
	]
	
	if {$include_sim_vhdl_files} {
		lappend inhdl_files_list "sim_filter_xz.vhd"
	}


	set toplevel_inhdl_files_list [list altera_mem_if_qdrii_rseq_top.sv]

	
	set input_module_list [list \
		sequencer \
		sim_filter_xz \
	]
	array set ifdef_array {}
	alt_mem_if::gui::uniphy_phy::create_ifdef_parameters ifdef_array
	alt_mem_if::gui::uniphy_phy::derive_ifdef_parameters ifdef_array
	alt_mem_if::gui::qdrii_phy::derive_ifdef_parameters ifdef_array
	
	set parsed_file_list [::alt_mem_if::util::iptclgen::parse_hdl_params $name $new_inhdl_common_dir $tmpdir $inhdl_files_list $input_module_list ifdef_array]

	set parsed_toplevel_file_list [::alt_mem_if::util::iptclgen::parse_hdl_params $name $new_inhdl_dir $tmpdir $toplevel_inhdl_files_list $input_module_list ifdef_array]
	
	alt_mem_if::util::iptclgen::sub_strings_params [file join $tmpdir [lindex $parsed_toplevel_file_list 0]] [file join $tmpdir $toplevel_file_name] [list VARIANT_OUTPUT_NAME $variant_name SIM_FILESET $simulation_fileset]
	

	set file_list [list]
	foreach file_name $parsed_file_list {
		lappend file_list [file join $tmpdir $file_name]
	}

	lappend file_list [file join $tmpdir $toplevel_file_name]

	return $file_list	
	
}

proc generate_vhdl_sim {name} {
	_iprint "Preparing to generate VHDL simulation fileset for $name"

	set qdir $::env(QUARTUS_ROOTDIR)
	set new_inhdl_common_dir "${qdir}/../ip/altera/alt_mem_if/alt_mem_if_phys/common"
	set encrypted_dir [file join $new_inhdl_common_dir "mentor" "abstract"]

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
			"${name}_sim_filter_xz" \
		]
	
		set vhdl_gen_files [list \
			"${name}_sim_filter_xz.vhd" \
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
alt_mem_if::gui::diagnostics::create_parameters



add_parameter          AFI_MAX_WRITE_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH DERIVED true

add_parameter          AFI_MAX_READ_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH DERIVED true

add_parameter          READ_FIFO_WRITE_ADDR_WIDTH INTEGER 0
set_parameter_property READ_FIFO_WRITE_ADDR_WIDTH DERIVED true

add_parameter          READ_FIFO_READ_ADDR_WIDTH INTEGER 0
set_parameter_property READ_FIFO_READ_ADDR_WIDTH DERIVED true


alt_mem_if::gui::system_info::create_gui
alt_mem_if::gui::afi::create_gui
alt_mem_if::gui::qdrii_phy::create_phy_gui
alt_mem_if::gui::qdrii_mem_model::create_gui
alt_mem_if::gui::qdrii_phy::create_board_settings_gui
alt_mem_if::gui::qdrii_phy::create_diagnostics_gui


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

	set_parameter_value AFI_MAX_WRITE_LATENCY_COUNT_WIDTH [get_parameter_value AFI_WLAT_WIDTH]
	set_parameter_value AFI_MAX_READ_LATENCY_COUNT_WIDTH [get_parameter_value AFI_RLAT_WIDTH]

	if {[string compare -nocase [get_parameter_value READ_FIFO_HALF_RATE] "true"] == 0} {
		set_parameter_value READ_FIFO_WRITE_ADDR_WIDTH [expr {log([get_parameter_value READ_FIFO_SIZE] / 2.0)/log(2)}]
	} else {
		set_parameter_value READ_FIFO_WRITE_ADDR_WIDTH [expr {log([get_parameter_value READ_FIFO_SIZE])/log(2)}]
	}

	if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		set_parameter_value READ_FIFO_READ_ADDR_WIDTH [expr {log([get_parameter_value READ_FIFO_SIZE])/log(2)}]
	} else {
		set_parameter_value READ_FIFO_READ_ADDR_WIDTH [expr {log([get_parameter_value READ_FIFO_SIZE] / 2.0)/log(2)}]
	}

	if {[string compare -nocase [get_parameter_value ENABLE_EXPORT_SEQ_DEBUG_BRIDGE] "true"] == 0} {
		_error "Core sequencer debug access is not available with the RTL sequencer.  Use the Nios sequencer instead."
	}

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::qdrii_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component
	alt_mem_if::gui::uniphy_phy::elaborate_component
	alt_mem_if::gui::qdrii_phy::elaborate_component






	::alt_mem_if::gen::uniphy_interfaces::phy_manager "QDRII" "sequencer" 0 "disable_fr_shift_calibration"

	::alt_mem_if::gen::uniphy_interfaces::mux_selector "sequencer"



	add_interface afi_clk clock end
	set_interface_property afi_clk ENABLED true
	add_interface_port afi_clk afi_clk clk Input 1

	add_interface afi_reset reset end
	set_interface_property afi_reset ENABLED true
	set_interface_property afi_reset synchronousEdges NONE
	add_interface_port afi_reset afi_reset_n reset_n Input 1

	::alt_mem_if::gen::uniphy_interfaces::afi "QDRII" "controller" "afi" 0 0


	
}
