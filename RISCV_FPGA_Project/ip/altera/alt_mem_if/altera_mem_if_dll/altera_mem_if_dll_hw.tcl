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
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::system_info
package require alt_mem_if::gen::uniphy_gen
package require alt_mem_if::gen::uniphy_interfaces
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*



set_module_property DESCRIPTION "External Memory DLL block"
set_module_property NAME altera_mem_if_dll
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::memory_phys_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "External Memory DLL block"
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
		HCX_COMPAT_MODE \
		ARRIAIIGX \
		ARRIAIIGZ \
		STRATIXIII \
		STRATIXIV \
		STRATIXV \
		ARRIAVGZ \
		ARRIAV \
		CYCLONEV \
		ABST_REAL_CMP \
		RTL_CALIB \
	]

	set core_params_list [list]

	
	if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGX"] == 0} {
		lappend core_params_list "ARRIAIIGX"
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAIIGZ"] == 0} {
		lappend core_params_list "ARRIAIIGZ"
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIII"] == 0} {
		lappend core_params_list "STRATIXIII"
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXIV"] == 0} {
		lappend core_params_list "STRATIXIV"
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0} {
		lappend core_params_list "STRATIXV"
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAV"] == 0} {
		lappend core_params_list "ARRIAV"
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "CYCLONEV"] == 0} {
		lappend core_params_list "CYCLONEV"
	} elseif {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "ARRIAVGZ"] == 0} {
		lappend core_params_list "ARRIAVGZ"
	}
	
	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		lappend core_params_list "HCX_COMPAT_MODE"
	}

	if {[string compare -nocase [get_parameter_value ABSTRACT_REAL_COMPARE_TEST] "true"] == 0} {
		lappend core_params_list "ABST_REAL_CMP"
	}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0} { 
			lappend core_params_list "RTL_CALIB"	
		}
	}

	return $core_params_list
	
}


proc generate_verilog_fileset {name tmpdir} {

	set core_params_list [solve_core_params]

	set inhdl_files_list [list \
		altera_mem_if_dll.sv \
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

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_dll.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file [file join mentor $generated_file] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor $generated_file] {MENTOR_SPECIFIC}
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

}


proc generate_verilog_sim {name} {
	_dprint 1 "Preparing to generate verilog simulation fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_dll.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

}


proc generate_synth {name} {
	_dprint 1 "Preparing to generate synthesis fileset for $name"

	set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_dll.sv" [solve_core_params]]
	_dprint 1 "Preparing to deploy file $generated_file"
	add_fileset_file $generated_file SYSTEM_VERILOG PATH $generated_file

}


proc create_hdl_parameters {} {

	_dprint 1 "Defining HDL parameters for [get_module_property NAME]"

	set_parameter_property DLL_DELAY_CTRL_WIDTH HDL_PARAMETER true
	set_parameter_property DELAY_BUFFER_MODE HDL_PARAMETER true
	set_parameter_property DELAY_CHAIN_LENGTH HDL_PARAMETER true
	set_parameter_property DLL_INPUT_FREQUENCY_PS_STR HDL_PARAMETER true
	set_parameter_property DLL_OFFSET_CTRL_WIDTH HDL_PARAMETER true
}



alt_mem_if::gui::uniphy_dll::create_parameters 1
alt_mem_if::gui::system_info::create_parameters


::alt_mem_if::util::hwtcl_utils::_add_parameter MEM_CLK_FREQ float 350
set_parameter_property MEM_CLK_FREQ DISPLAY_NAME "Memory clock frequency"
set_parameter_property MEM_CLK_FREQ UNITS Megahertz
set_parameter_property MEM_CLK_FREQ DESCRIPTION "The desired frequency of the clock that drives the memory device.  Up to 4 decimal places of precision can be used."
set_parameter_property MEM_CLK_FREQ DISPLAY_HINT columns:10

::alt_mem_if::util::hwtcl_utils::_add_parameter HCX_COMPAT_MODE boolean false
set_parameter_property HCX_COMPAT_MODE VISIBLE false
set_parameter_property HCX_COMPAT_MODE DISPLAY_NAME "HardCopy Compatibility Mode"
set_parameter_property HCX_COMPAT_MODE DESCRIPTION "When turned on, the UniPHY memory interface generated has all required HardCopy compatibility options enabled.
For example PLLs and DLLs will have their reconfiguration ports exposed."

::alt_mem_if::util::hwtcl_utils::_add_parameter ABSTRACT_REAL_COMPARE_TEST boolean false
set_parameter_property ABSTRACT_REAL_COMPARE_TEST VISIBLE false

::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_USE_DR_CLK BOOLEAN false
set_parameter_property DLL_USE_DR_CLK VISIBLE false
set_parameter_property DLL_USE_DR_CLK DERIVED false

::alt_mem_if::util::hwtcl_utils::_add_parameter DEFAULT_FAST_SIM_MODEL boolean true
set_parameter_property DEFAULT_FAST_SIM_MODEL VISIBLE false

::alt_mem_if::util::hwtcl_utils::_add_parameter DLL_INPUT_FREQUENCY_PS_STR STRING ""
set_parameter_property DLL_INPUT_FREQUENCY_PS_STR VISIBLE false
set_parameter_property DLL_INPUT_FREQUENCY_PS_STR DERIVED true


create_hdl_parameters


alt_mem_if::gui::system_info::create_gui



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
	alt_mem_if::gui::uniphy_dll::validate_component 1

	
	set mem_clk_period [ expr {1000000.0 / [get_parameter_value MEM_CLK_FREQ]} ]
	set mem_clk_ps [ expr {round($mem_clk_period)} ]
	
	if {[string compare -nocase [get_parameter_value DLL_USE_DR_CLK] "true"] == 0} {
		set mem_clk_ps [ expr {round($mem_clk_period / 2.0)} ]
		_iprint "DLL will be fed by a 2X clock."
	} else {
		if {[string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "STRATIXV"] == 0 || [string compare -nocase [::alt_mem_if::gui::system_info::get_device_family] "ARRIAVGZ"] == 0} {
			if {$mem_clk_ps > 3333} {
				set mem_clk_ps 3333
				_iprint "DLL input clock is slower than 300MHz and may not lock."
			}
		}	
	}

	set_parameter_value DLL_INPUT_FREQUENCY_PS_STR "${mem_clk_ps} ps"

}

proc ip_elaborate {} {
	_dprint 1 "Running IP Elaboration for [get_module_property NAME]"

	alt_mem_if::gui::system_info::elaborate_component
	alt_mem_if::gui::uniphy_dll::elaborate_component


	add_interface clk clock end
	set_interface_property clk clockRate 0
	set_interface_property clk ENABLED true
	add_interface_port clk clk clk Input 1
	

	::alt_mem_if::gen::uniphy_interfaces::dll_sharing "source"


	if {[string compare -nocase [get_parameter_value HCX_COMPAT_MODE] "true"] == 0} {
		::alt_mem_if::gen::uniphy_interfaces::hcx_dll_reconfig
		::alt_mem_if::gen::uniphy_interfaces::hcx_dll_sharing "source"
	}

	if {[::alt_mem_if::util::qini::cfg_is_on alt_mem_if_rtl_calib]} {
		if {[string compare -nocase [get_parameter_value PARSE_FRIENDLY_DEVICE_FAMILY] "STRATIXV"] == 0} { 

			add_interface rtl_dll_sharing conduit end
			set_interface_property rtl_dll_sharing ENABLED true
			add_interface_port rtl_dll_sharing dll_offsetctrlout dll_offset_ctrl_offsetctrlout OUTPUT [get_parameter_value DLL_DELAY_CTRL_WIDTH]

			add_interface rtl_dll_reconfig conduit end
			set_interface_property rtl_dll_reconfig ENABLED true
			add_interface_port rtl_dll_reconfig dll_offset_ctrl_a_addnsub dll_offset_ctrl_addnsub Input 1
			add_interface_port rtl_dll_reconfig dll_offset_ctrl_a_offset dll_offset_ctrl_offset Input [get_parameter_value DLL_DELAY_CTRL_WIDTH] 
				
		}
	}

	foreach fset_name [list SIM_VERILOG SIM_VHDL QUARTUS_SYNTH] {
		set_fileset_property [string tolower $fset_name] TOP_LEVEL [alt_mem_if::util::iptclgen::generate_outfile_name "altera_mem_if_dll.sv" [solve_core_params] 1]
	}

}
