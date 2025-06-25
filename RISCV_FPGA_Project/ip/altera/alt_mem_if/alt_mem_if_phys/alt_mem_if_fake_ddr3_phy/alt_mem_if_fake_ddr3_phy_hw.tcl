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

set_module_property DESCRIPTION "Fake DDR3 SDRAM External Memory PHY"
set_module_property NAME altera_mem_if_fake_ddr3_phy
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Fake DDR3 SDRAM External Memory PHY"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE

add_display_item "" "Block Diagram" GROUP


add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth


proc solve_core_params {} {
	set supported_ifdefs_list [list \
		"DDRX_LPDDRX" \
	        "FULL_RATE" \
	]
	
	set core_params_list [list]

	lappend core_params_list "DDRX_LPDDRX"

	if {[string compare -nocase [get_parameter_value RATE] "FULL"] == 0} {
		lappend core_params_list "FULL_RATE"
	}
	
	return $core_params_list

}


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
	set new_inhdl_common_dir "${qdir}/../ip/altera/alt_mem_if/alt_mem_if_phys/common"
	set new_inhdl_dir "${qdir}/../ip/altera/alt_mem_if/alt_mem_if_phys/alt_mem_if_fake_ddr3_phy"
	
	
	set megafunction_files_list [list]
	
	set inhdl_files_list [list \
		reset.v \
		reset_sync.v \
		memphy_fake.v 
	]
	
	set toplevel_inhdl_files_list [list alt_mem_if_fake_ddr3_phy_top.sv]

	
	set input_module_list [list \
		memphy_fake \
		memphy \
		reset \
		reset_sync 
	]

	array set ifdef_array {}
	alt_mem_if::gui::uniphy_phy::create_ifdef_parameters ifdef_array
	alt_mem_if::gui::uniphy_phy::derive_ifdef_parameters ifdef_array
	alt_mem_if::gui::common_ddrx_phy::derive_ifdef_parameters ifdef_array
	set parsed_file_list [::alt_mem_if::util::iptclgen::parse_hdl_params $name $new_inhdl_common_dir $tmpdir $inhdl_files_list $input_module_list ifdef_array]

	set parsed_toplevel_file_list        [::alt_mem_if::util::iptclgen::parse_hdl_params $name $new_inhdl_dir        $tmpdir $toplevel_inhdl_files_list        $input_module_list ifdef_array]
	
	alt_mem_if::util::iptclgen::sub_strings_params [file join $tmpdir [lindex $parsed_toplevel_file_list 0]] [file join $tmpdir $toplevel_file_name] \
		[list VARIANT_OUTPUT_NAME $variant_name SIM_FILESET $simulation_fileset "FAST_SIM_MODEL_DEFAULT" 0 TB_PROTOCOL "DDR3"]
	

	set file_list [list]
	foreach file_name $parsed_file_list {
		lappend file_list [file join $tmpdir $file_name]
	}

	lappend file_list [file join $tmpdir $toplevel_file_name]

	set file_list [concat $megafunction_files_list $file_list]

	return $file_list	
	
}

proc generate_vhdl_sim {name} {
	_error "VHDL not supported"
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

	if {[string compare [get_parameter_value ENABLE_EXTRA_REPORTING] "true"] == 0} {
		set param_files [alt_mem_if::gen::uniphy_gen::generate_parameters_txt_file "${name}_" "DDR3" $tmpdir]
		foreach generated_file $param_files {
			set file_name [file tail $generated_file]
			_dprint 1 "Preparing to add $generated_file as $file_name"
			add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $generated_file
		}
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

	if {[string compare [get_parameter_value ENABLE_EXTRA_REPORTING] "true"] == 0} {
		set param_files [alt_mem_if::gen::uniphy_gen::generate_parameters_txt_file "${name}_" "DDR3" $tmpdir]
		foreach generated_file $param_files {
			set file_name [file tail $generated_file]
			_dprint 1 "Preparing to add $generated_file as $file_name"
			add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name 0] PATH $generated_file
		}
	}

	set qdir $::env(QUARTUS_ROOTDIR)
	set inhdl_dir "${qdir}/../ip/altera/alt_mem_if/alt_mem_if_phys/alt_mem_if_ddr3_phy_core"
	set constraints_dir [file join $inhdl_dir constraints]
	set common_constraints_dir "${qdir}/../ip/altera/alt_mem_if/alt_mem_if_phys/common/constraints"


	foreach tcl_file [::alt_mem_if::gen::uniphy_gen::generate_fake_pin_assignments_file $name "DDR3" $constraints_dir $tmpdir] {
		set file_name [file tail $tcl_file]
		add_fileset_file $file_name OTHER PATH $tcl_file
	}

	foreach tcl_file [::alt_mem_if::gen::uniphy_gen::generate_parameters_file $name "DDR3" $constraints_dir $tmpdir] {
		set file_name [file tail $tcl_file]
		add_fileset_file $file_name OTHER PATH $tcl_file
	}

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
	_dprint 1 "Running IP Validation"

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_oct::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::common_ddrx_phy::validate_component
}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::common_ddr_mem_model::elaborate_component
	alt_mem_if::gui::afi::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component
	alt_mem_if::gui::uniphy_oct::elaborate_component
	alt_mem_if::gui::uniphy_controller_phy::elaborate_component
	alt_mem_if::gui::uniphy_phy::elaborate_component
	alt_mem_if::gui::common_ddrx_phy::elaborate_component

	add_interface global_reset reset end
	set_interface_property global_reset synchronousEdges NONE
	
	set_interface_property global_reset ENABLED true
	
	add_interface_port global_reset global_reset_n reset_n Input 1
	
	add_interface soft_reset reset end
	set_interface_property soft_reset synchronousEdges NONE
	
	set_interface_property soft_reset ENABLED true
	
	add_interface_port soft_reset soft_reset_n reset_n Input 1
	
	add_interface afi_reset reset source
	
	set_interface_property afi_reset ENABLED true
	
	add_interface_port afi_reset afi_reset_n reset_n Output 1
	set_interface_property afi_reset associatedResetSinks {soft_reset global_reset}
	set_interface_property afi_reset associatedClock afi_clk

	add_interface afi_clk clock end
	set_interface_property afi_clk ENABLED true
	add_interface_port afi_clk afi_clk clk Input 1

	add_interface afi_half_clk clock end
	set_interface_property afi_half_clk ENABLED true
	add_interface_port afi_half_clk afi_half_clk clk Input 1
	
	add_interface addr_cmd_clk clock start
	set_interface_property addr_cmd_clk clockRate 0
	set_interface_property addr_cmd_clk clockRateKnown true
	
	set_interface_property addr_cmd_clk ENABLED true
	
	add_interface_port addr_cmd_clk addr_cmd_clk clk Output 1

	set_interface_property addr_cmd_clk clockRate [expr {[get_parameter_value PLL_ADDR_CMD_CLK_FREQ] * 1000000}]
	set_interface_property addr_cmd_clk clockRateKnown true

	
	if {[string compare [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {

		add_interface avl_clk clock start
		set_interface_property avl_clk clockRate 0
		set_interface_property avl_clk clockRateKnown true
		
		set_interface_property avl_clk ENABLED true
		
		add_interface_port avl_clk avl_clk clk Output 1

		set_interface_property avl_clk clockRate [expr {[get_parameter_value PLL_NIOS_CLK_FREQ] * 1000000}]
		set_interface_property avl_clk clockRateKnown true


		add_interface avl_reset reset source
		
		set_interface_property avl_reset ENABLED true
		
		add_interface_port avl_reset avl_reset_n reset_n Output 1
		set_interface_property avl_reset associatedResetSinks {soft_reset global_reset}
		set_interface_property avl_reset associatedClock avl_clk


		add_interface scc_clk clock start
		set_interface_property scc_clk clockRate 0
		set_interface_property scc_clk clockRateKnown true
		
		set_interface_property scc_clk ENABLED true
		
		add_interface_port scc_clk scc_clk clk Output 1

		set_interface_property scc_clk clockRate [expr {[get_parameter_value PLL_CONFIG_CLK_FREQ] * 1000000}]
		set_interface_property scc_clk clockRateKnown true


		add_interface scc_reset reset source
		
		set_interface_property scc_reset ENABLED true
		
		add_interface_port scc_reset scc_reset_n reset_n Output 1
		set_interface_property scc_reset associatedResetSinks {soft_reset global_reset}
		set_interface_property scc_reset associatedClock scc_clk

	}

	
	add_interface dll_clk clock start
	set_interface_property dll_clk ENABLED true
	if {[string compare -nocase [get_parameter_value USE_DR_CLK] "true"] == 0} {
		set_interface_property dll_clk clockRate [expr {[get_parameter_value PLL_DR_CLK_FREQ] * 1000000}]
	} else {
		set_interface_property dll_clk clockRate [expr {[get_parameter_value PLL_WRITE_CLK_FREQ] * 1000000}]
	}
	set_interface_property dll_clk clockRateKnown true
	add_interface_port dll_clk dll_clk clk Output 1
	

	::alt_mem_if::gen::uniphy_interfaces::afi "DDR3" "phy" "afi" 0


	if {[string compare [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		::alt_mem_if::gen::uniphy_interfaces::phy_manager "DDR3" "phy" 1
	} else {
		::alt_mem_if::gen::uniphy_interfaces::phy_manager "DDR3" "phy" 0
	}


	if {[string compare [get_parameter_value SEQUENCER_TYPE] "NIOS"] == 0} {
		::alt_mem_if::gen::uniphy_interfaces::scc_manager "phy"
	}

	::alt_mem_if::gen::uniphy_interfaces::afi_mem_clk_disable "phy"

	::alt_mem_if::gen::uniphy_interfaces::pll_sharing "sink"


	::alt_mem_if::gen::uniphy_interfaces::dll_sharing "sink"


	::alt_mem_if::gen::uniphy_interfaces::oct_sharing "sink"


	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] ==0} {
		::alt_mem_if::gen::uniphy_interfaces::hcx_dll_sharing "sink"
	}


	add_interface memory conduit end
	
	set_interface_property memory ENABLED true
	set_interface_assignment "memory" "qsys.ui.export_name" "memory"
	
	add_interface_port memory mem_a mem_a Output [get_parameter_value MEM_IF_ADDR_WIDTH]
	add_interface_port memory mem_ba mem_ba Output [get_parameter_value MEM_IF_BANKADDR_WIDTH]
	add_interface_port memory mem_ck mem_ck Output [get_parameter_value MEM_IF_CK_WIDTH]
	add_interface_port memory mem_ck_n mem_ck_n Output [get_parameter_value MEM_IF_CK_WIDTH]
	add_interface_port memory mem_cke mem_cke Output [get_parameter_value MEM_IF_CLK_EN_WIDTH]
	add_interface_port memory mem_cs_n mem_cs_n Output [get_parameter_value MEM_IF_CS_WIDTH]
	if {[string compare -nocase [get_parameter_value MEM_IF_DM_PINS_EN] "true"] == 0} {
		add_interface_port memory mem_dm mem_dm Output [get_parameter_value MEM_IF_DM_WIDTH]
	}
	add_interface_port memory mem_ras_n mem_ras_n Output [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_cas_n mem_cas_n Output [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_we_n mem_we_n Output [get_parameter_value MEM_IF_CONTROL_WIDTH]
	add_interface_port memory mem_reset_n mem_reset_n Output 1
	add_interface_port memory mem_dq mem_dq Bidir [get_parameter_value MEM_IF_DQ_WIDTH]
	add_interface_port memory mem_dqs mem_dqs Bidir [get_parameter_value MEM_IF_DQS_WIDTH]
	add_interface_port memory mem_dqs_n mem_dqs_n Bidir [get_parameter_value MEM_IF_DQS_WIDTH]
	add_interface_port memory mem_odt mem_odt Output [get_parameter_value MEM_IF_ODT_WIDTH]

	if {([string compare -nocase [get_parameter_value MEM_FORMAT] "REGISTERED"] == 0 || [string compare -nocase [get_parameter_value MEM_FORMAT] "LOADREDUCED"] == 0)} {
		if {[string compare -nocase [get_parameter_value AC_PARITY] "true"] == 0} {
			add_interface_port memory mem_ac_parity mem_ac_parity Output 1
			add_interface_port memory mem_err_out_n mem_err_out_n Input 1
			add_interface_port memory mem_parity_error_n mem_parity_error_n Output 1

		}
	}

	foreach port_name [get_interface_ports memory] {
		if {[regexp -nocase {mem_ac_parity|mem_err_out_n|mem_parity_error_n|mem_reset_n} $port_name match] == 0} {
			set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
		}
	}
	
	set_interface_assignment memory "ui.blockdiagram.direction" "output"
	
	

	::alt_mem_if::gen::uniphy_interfaces::csr_slave "phy"


}
