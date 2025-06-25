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
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::common_ddrx_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::diagnostics

namespace import ::alt_mem_if::util::messaging::*

set_module_property DESCRIPTION "LPDDR SDRAM Qsys Sequencer"
set_module_property NAME altera_mem_if_lpddr_qseq
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_sequencers_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "LPDDR SDRAM Qsys Sequencer"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc generate_vhdl_sim {name} {
	_iprint "Preparing to generate VHDL simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	_dprint 1 "Using temporary directory $tmpdir"

	set qsys_sequencer_dir [file join "qsys" "${name}"]
	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_use_verilog_sequencer]} {
		set seq_gen_files [alt_mem_if::gen::uniphy_gen::generate_sequencer_files $name "LPDDR1" $tmpdir SIM_VERILOG]
	} else {
		set seq_gen_files [alt_mem_if::gen::uniphy_gen::generate_sequencer_files $name "LPDDR1" $tmpdir SIM_VHDL]
	}

	set non_encryp_simulators [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	foreach generated_file $seq_gen_files {
		set file_name [file tail $generated_file]
		set file_dirname [file dirname $generated_file]
		if {[string compare -nocase [file tail $file_dirname] "mentor"] == 0} {
			_dprint 1 "Preparing to add Mentor-encrypted file mentor/$generated_file"
			add_fileset_file [file join mentor $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0 1] PATH $generated_file {MENTOR_SPECIFIC}
		} elseif {[string compare -nocase [file tail $file_dirname] "synopsys"] == 0} {
			_dprint 1 "Preparing to add Synopsys-encrypted file synopsys/$generated_file"
			add_fileset_file [file join synopsys $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0 1] PATH $generated_file {SYNOPSYS_SPECIFIC}
		} elseif {[string compare -nocase [file tail $file_dirname] "cadence"] == 0} {
			_dprint 1 "Preparing to add Cadence-encrypted file cadence/$generated_file"
			add_fileset_file [file join cadence $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0 1] PATH $generated_file {CADENCE_SPECIFIC}
		} elseif {[string compare -nocase [file tail $file_dirname] "riviera"] == 0 || [string compare -nocase [file tail $file_dirname] "aldec"] == 0} {
			_dprint 1 "Preparing to add Riviera-encrypted file riviera/$generated_file"
			add_fileset_file [file join aldec $file_name] [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0 1] PATH $generated_file {ALDEC_SPECIFIC}
		} else {
			_dprint 1 "Preparing to add $generated_file"
			set file_type [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0]
			if {[string compare -nocase $file_type "VHDL"] == 0} {
				add_fileset_file $file_name $file_type PATH $generated_file
			} elseif {[string compare -nocase $file_type "HEX"] == 0} {
				add_fileset_file $file_name $file_type PATH $generated_file
			} else {
				add_fileset_file $file_name $file_type PATH $generated_file $non_encryp_simulators
			}
		}
	}

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	_dprint 1 "Using temporary directory $tmpdir"

	foreach generated_file [alt_mem_if::gen::uniphy_gen::generate_sequencer_files $name "LPDDR1" $tmpdir SIM_VERILOG] {
		set file_name [file tail $generated_file]
		_dprint 1 "Preparing to add $generated_file as $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $generated_file
	}
}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate verilog synthesis fileset for $name"

	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	_dprint 1 "Using temporary directory $tmpdir"
	

	foreach generated_file [alt_mem_if::gen::uniphy_gen::generate_sequencer_files $name "LPDDR1" $tmpdir QUARTUS_SYNTH] {
		set file_name [file tail $generated_file]
		_dprint 1 "Preparing to add $generated_file as $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $generated_file
	}
}



alt_mem_if::gui::afi::set_protocol "LPDDR1"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "LPDDR1"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::common_ddrx_phy::set_ddr_mode "LPDDR1"
alt_mem_if::gui::common_ddrx_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters
alt_mem_if::gui::diagnostics::create_parameters



add_parameter AFI_MAX_WRITE_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_WRITE_LATENCY_COUNT_WIDTH DERIVED true

add_parameter AFI_MAX_READ_LATENCY_COUNT_WIDTH INTEGER 5
set_parameter_property AFI_MAX_READ_LATENCY_COUNT_WIDTH DERIVED true

add_parameter AVL_DATA_WIDTH INTEGER 32
set_parameter_property AVL_DATA_WIDTH DISPLAY_NAME AVL_DATA_WIDTH

add_parameter AVL_ADDR_WIDTH INTEGER 13
set_parameter_property AVL_ADDR_WIDTH DISPLAY_NAME AVL_ADDR_WIDTH


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
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::common_ddrx_phy::validate_component

	set_parameter_value AFI_MAX_WRITE_LATENCY_COUNT_WIDTH [get_parameter_value AFI_WLAT_WIDTH]
	set_parameter_value AFI_MAX_READ_LATENCY_COUNT_WIDTH [get_parameter_value AFI_RLAT_WIDTH]
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration for [get_module_property NAME]"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component
	alt_mem_if::gui::uniphy_controller_phy::elaborate_component
	alt_mem_if::gui::uniphy_phy::elaborate_component
	alt_mem_if::gui::common_ddrx_phy::elaborate_component


	add_interface avl_clk clock end
	set_interface_property avl_clk ENABLED true
	add_interface_port avl_clk avl_clk clk Input 1
	

	add_interface avl_reset reset end
	set_interface_property avl_reset ENABLED true
	set_interface_property avl_reset synchronousEdges NONE
	add_interface_port avl_reset avl_reset_n reset_n Input 1
	


	add_interface scc_clk clock end
	set_interface_property scc_clk ENABLED true
	add_interface_port scc_clk scc_clk clk Input 1

	add_interface scc_reset reset end
	set_interface_property scc_reset ENABLED true
	set_interface_property scc_reset synchronousEdges NONE
	add_interface_port scc_reset reset_n_scc_clk reset_n Input 1

	::alt_mem_if::gen::uniphy_interfaces::scc_manager "sequencer"

	::alt_mem_if::gen::uniphy_interfaces::afi_init_cal_req "sequencer"


	if {[string compare -nocase [get_parameter_value ENABLE_EMIT_JTAG_MASTER] "true"] == 0} {
		::alt_mem_if::gen::uniphy_interfaces::seq_debug_csr
	}


	if {[string compare -nocase [get_parameter_value HARD_PHY] "false"] == 0} {


		::alt_mem_if::gen::uniphy_interfaces::phy_manager "LPDDR1" "sequencer" 1 "disable_fr_shift_calibration"

		::alt_mem_if::gen::uniphy_interfaces::mux_selector "sequencer"




		add_interface afi_clk clock end
		set_interface_property afi_clk ENABLED true
		add_interface_port afi_clk afi_clk clk Input 1

		add_interface afi_reset reset end
		set_interface_property afi_reset ENABLED true
		set_interface_property afi_reset synchronousEdges NONE
		add_interface_port afi_reset afi_reset_n reset_n Input 1

		::alt_mem_if::gen::uniphy_interfaces::afi "LPDDR1" "controller" "afi" 0 0


	} else {

		::alt_mem_if::gen::uniphy_interfaces::qsys_sequencer_avl "master"

	}


	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {

		::alt_mem_if::gen::uniphy_interfaces::hcx_rom_reconfig


	}


}
