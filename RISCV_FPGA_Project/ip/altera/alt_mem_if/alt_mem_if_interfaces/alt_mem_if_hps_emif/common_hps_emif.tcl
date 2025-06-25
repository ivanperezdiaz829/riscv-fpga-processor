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




package require alt_mem_if::util::messaging
package require alt_mem_if::util::qini
package require alt_mem_if::util::list_array
package require alt_mem_if::util::profiling
package require alt_mem_if::util::hwtcl_utils
package require alt_mem_if::gui::common_ddr_mem_model
package require alt_mem_if::gui::uniphy_controller_phy
package require alt_mem_if::gui::ddrx_controller
package require alt_mem_if::gui::uniphy_phy
package require alt_mem_if::gui::common_ddrx_phy
package require alt_mem_if::gui::afi
package require alt_mem_if::gui::system_info
package require alt_mem_if::gui::diagnostics
package require alt_mem_if::gen::uniphy_pll
package require alt_mem_if::gui::abstract_ram
package require alt_mem_if::gui::uniphy_dll
package require alt_mem_if::gui::uniphy_oct
package require alt_mem_if::gen::uniphy_interfaces


namespace import ::alt_mem_if::util::messaging::*



alt_mem_if::gui::afi::set_protocol "HPS"
alt_mem_if::gui::common_ddr_mem_model::set_ddr_mode "HPS"
alt_mem_if::gui::common_ddr_mem_model::create_parameters
set mem_model_param_list [split [get_parameters]]
alt_mem_if::gui::uniphy_controller_phy::create_parameters
alt_mem_if::gui::ddrx_controller::set_ddr_mode "HPS"
alt_mem_if::gui::ddrx_controller::create_parameters
alt_mem_if::gui::uniphy_phy::create_parameters
alt_mem_if::gui::common_ddrx_phy::set_ddr_mode "HPS"
alt_mem_if::gui::common_ddrx_phy::create_parameters
alt_mem_if::gui::afi::create_parameters
alt_mem_if::gui::system_info::create_parameters
alt_mem_if::gui::diagnostics::create_parameters
alt_mem_if::gui::abstract_ram::create_parameters
alt_mem_if::gui::uniphy_dll::create_parameters
alt_mem_if::gui::uniphy_oct::create_parameters

set_parameter_property HPS_PROTOCOL DEFAULT_VALUE "DDR3"
set_parameter_property HPS_PROTOCOL DISPLAY_NAME "SDRAM Protocol"
set_parameter_property HPS_PROTOCOL DESCRIPTION "SDRAM protocol."
set_parameter_property HPS_PROTOCOL ALLOWED_RANGES {DDR2 DDR3 LPDDR2}
set_parameter_property HPS_PROTOCOL VISIBLE true

set_parameter_property HARD_EMIF DEFAULT_VALUE true
set_parameter_property HARD_EMIF VISIBLE false

set_parameter_property HHP_HPS DEFAULT_VALUE true

set_parameter_update_callback HPS_PROTOCOL hps_update_protocol arg

proc hps_update_protocol {arg} {
	set prot [get_parameter_value HPS_PROTOCOL]
	if { [string compare -nocase [get_parameter_value HPS_PROTOCOL] "DDR3"] == 0} {
		set_parameter_value MEM_BL OTF
		set_parameter_value MEM_SRT "Normal"
		set_parameter_value MEM_PD "DLL off"
		set_parameter_value MEM_DRV_STR "RZQ/6"
		set_parameter_value MEM_RTT_NOM "ODT Disabled"
		set_parameter_value MEM_ATCL "Disabled"
		set_parameter_value TIMING_TDQSCK 400
	} elseif { [string compare -nocase [get_parameter_value HPS_PROTOCOL] "DDR2"] == 0} {
		set_parameter_value MEM_BL 8
		set_parameter_value MEM_SRT "1x refresh rate"
		set_parameter_value MEM_PD "Fast exit"
		set_parameter_value MEM_DRV_STR "Full"
		set_parameter_value MEM_RTT_NOM "Disabled"
		set_parameter_value MEM_ATCL 0
		set_parameter_value TIMING_TDQSCK 400
	} elseif {[string compare -nocase [get_parameter_value HPS_PROTOCOL] "LPDDR2"] == 0} {
		set_parameter_value MEM_BL 8
		set_parameter_value MEM_DRV_STR "34.3"
		set_parameter_value MEM_ATCL 0
		set_parameter_value TIMING_TDQSCK 2500
	} 
}


proc create_emif_gui {} {

	set_parameter_property HPS_PROTOCOL group "SDRAM"
	
	alt_mem_if::gui::common_ddrx_phy::create_phy_gui
	alt_mem_if::gui::common_ddr_mem_model::create_gui
	alt_mem_if::gui::common_ddrx_phy::create_board_settings_gui
	alt_mem_if::gui::ddrx_controller::create_gui
	alt_mem_if::gui::common_ddrx_phy::create_diagnostics_gui
	alt_mem_if::gui::diagnostics::create_gui
	
	alt_mem_if::gui::abstract_ram::create_memif_gui

	set_parameter_property PHY_CSR_ENABLED VISIBLE false
	set_parameter_property PHY_CSR_CONNECTION VISIBLE false

}


proc validate_emif_component {} {

	alt_mem_if::gui::system_info::validate_component
	alt_mem_if::gui::common_ddr_mem_model::validate_component
	alt_mem_if::gui::afi::validate_component
	alt_mem_if::gui::uniphy_dll::validate_component
	alt_mem_if::gui::uniphy_oct::validate_component
	alt_mem_if::gui::uniphy_controller_phy::validate_component
	alt_mem_if::gui::ddrx_controller::validate_component
	alt_mem_if::gui::uniphy_phy::validate_component
	alt_mem_if::gui::common_ddrx_phy::validate_component
	alt_mem_if::gui::diagnostics::validate_component [get_parameter_value ENABLE_CTRL_AVALON_INTERFACE]
	alt_mem_if::gui::abstract_ram::validate_component


	set validation_pass 1

	set_parameter_property HARD_EMIF VISIBLE false

	set_parameter_property HCX_COMPAT_MODE VISIBLE false
	set_parameter_property HCX_COMPAT_MODE ENABLED false
	set_parameter_property PLL_LOCATION VISIBLE false
	set_parameter_property PLL_LOCATION ENABLED false
	set_parameter_property SOPC_COMPAT_RESET VISIBLE false
	set_parameter_property SOPC_COMPAT_RESET ENABLED false

	return $validation_pass
}


proc instantiate_hps_emif_component {name} {

	set EMIF $name
	add_instance $EMIF altera_mem_if_hps_emif
	foreach param_name [get_instance_parameters $EMIF] {
		_dprint 1 "Assigning parameter $param_name = [get_parameter_value $param_name] for $EMIF"
		set_instance_parameter $EMIF $param_name [get_parameter_value $param_name]
	}
	::alt_mem_if::gen::uniphy_pll::cache_pll_parameters $EMIF
	::alt_mem_if::gui::system_info::cache_sys_info_parameters $EMIF
	set_instance_parameter $EMIF DISABLE_CHILD_MESSAGING true

	set_instance_parameter $EMIF HARD_EMIF true

	if {[string compare -nocase [get_parameter_value HHP_HPS_VERIFICATION] "true"] != 0 &&
	    [string compare -nocase [get_parameter_value HHP_HPS_SIMULATION] "true"] != 0} {
		add_instance clk_reset_src altera_mem_if_clk_rst_source
		add_connection clk_reset_src.clk/${EMIF}.pll_ref_clk
		add_connection clk_reset_src.global_reset/${EMIF}.global_reset
		add_connection clk_reset_src.soft_reset/${EMIF}.soft_reset
	}
}

proc get_hps_emif_files {initial_path sub_path} {
	set files [list]
	foreach filename_full [glob -nocomplain [file join $initial_path $sub_path "*"]] {
		set filename [file tail $filename_full]
		if {[file isdirectory $filename_full] && [string compare $filename "."] != 0 && [string compare $filename ".."] != 0} {
			set files [concat $files [get_hps_emif_files $initial_path [file join $sub_path $filename]]]
		} elseif {[file isfile $filename_full]} {
			lappend files [file join $sub_path $filename]
		}
	}
	return $files
}

proc generate_hps_emif_component {prefix fileset} {
	
	set arg_list [list]
	foreach param_name [get_parameters] {
		if {$param_name != "interfaceDefinition" &&
		    $param_name != "qipEntries" &&
		    $param_name != "ignoreSimulation"} {

			if {[get_parameter_property $param_name DERIVED] == 0} {
				if {[string compare -nocase $param_name "hps_parameter_map"] != 0 } {

					set value [get_parameter_value $param_name]
					if {[string compare -nocase [get_parameter_property $param_name TYPE] "string_list"] == 0 || 
						[string compare -nocase [get_parameter_property $param_name TYPE] "integer_list"] == 0 } {
						set value [string map {{ } {,}} $value]
					}
					lappend arg_list "--component-param=$param_name=$value"
				}
			}
		}
	}

	set device_family [get_parameter_value DEVICE_FAMILY]
	
	set tmpdir [add_fileset_file {} OTHER TEMP {}]
	set sdram_outname "${prefix}_sdram"

	set arg_list [concat [list "--file-set=$fileset" "--component-param=extended_family_support=true" "--output_name=$sdram_outname" "--output-dir=$tmpdir" "--system-info=DEVICE_FAMILY=$device_family"] $arg_list]

	_dprint 1 "HPS EMIF: arg_list=$arg_list"

	set output [::alt_mem_if::gen::uniphy_gen::generate_ip_from_quartus_sh altera_mem_if_hps_emif $arg_list $tmpdir generate_hps_sdram.tcl]

	_dprint 1 "HPS EMIF: output=$output"

	set generated_dir [file join $tmpdir "submodules"]

	set files [get_hps_emif_files $generated_dir {}]

	_dprint 1 "HPS EMIF: ip-generate returned files: $files"

	set simulators [list mentor synopsys cadence aldec]
	
	if {[string compare -nocase $fileset "QUARTUS_SYNTH"] == 0 ||
	    [string compare -nocase $fileset "SIM_VERILOG"] == 0} {

		alt_mem_if::util::iptclgen::advertize_file $fileset ${sdram_outname}.v $tmpdir {} $fileset

		foreach file_subpath $files {
			_dprint 1 "HPS EMIF: processing file $file_subpath"
			set file_name [file tail $file_subpath]
			set dir_subpath [file dirname $file_subpath]
			set dir [file tail $dir_subpath]
			set fullname [file join $generated_dir $file_subpath]
			_dprint 1 "HPS EMIF: processing file $fullname: $generated_dir $dir_subpath $file_name (last dir=$dir)"
			if {[lsearch -exact $simulators $dir] >= 0} {
				set sim $dir
				set file_type [::alt_mem_if::util::hwtcl_utils::get_file_type $fullname 0 1 1] 
				add_fileset_file $file_subpath $file_type PATH $fullname [string toupper $sim]_SPECIFIC
			} else {
				set file_type [::alt_mem_if::util::hwtcl_utils::get_file_type $fullname 0 0 1]
				if {[string compare -nocase $fileset "QUARTUS_SYNTH"] == 0} {
					if { [regexp {\.pre\.} $fullname ]} {
						set file_type "HPS_ISW"
						_dprint 1 "Setting filetype $file_type for $file_subpath in $fullname"
					}
				}
				add_fileset_file $file_subpath $file_type PATH $fullname
			}
		}
	} elseif {[string compare -nocase $fileset "SIM_VHDL"] == 0} {
		_error "HPS SDRAM VHDL simulation is not currently supported"
	} else {
		_error "Unknown/unsupported fileset $fileset"
	}

}

