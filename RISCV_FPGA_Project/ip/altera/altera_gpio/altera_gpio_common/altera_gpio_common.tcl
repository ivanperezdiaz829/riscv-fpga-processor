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


# (C) 2002-2012 Altera Corporation. All rights reserved.
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

# package: altera_gpio::common
#
# Provides common functions for interacting with _hw.tcl API
#
package provide altera_gpio::common 0.1


package require altera_emif::util::hwtcl_utils

################################################################################
###                          TCL INCLUDES                                   ###
################################################################################

################################################################################
###                          TCL NAMESPACE                                   ###
################################################################################
namespace eval ::altera_gpio::common:: {
   # Namespace Variables
   
   # Import functions into namespace

   # Export functions
   namespace export safe_string_compare
   namespace export add_gpio_parameters
   namespace export validate
   namespace export elaborate
   namespace export set_clock_interface
   namespace export set_pad_interface
   namespace export set_data_interface
   namespace export add_all_files_in_dir
   # Package variables
}

################################################################################
###                          TCL PROCEDURES                                  ###
################################################################################
proc ::altera_gpio::common::safe_string_compare { string_1 string_2 } {
	set ret_val [expr {[string compare -nocase $string_1 $string_2] == 0}]
	return $ret_val
}

proc ::altera_gpio::common::legality_checks {} {
	# Check that differential is not used in combination with bus hold or open drain
	set buff_type [get_parameter_value BUFFER_TYPE]
	set open_drain [get_parameter_value OPEN_DRAIN]
	set bus_hold [get_parameter_value BUS_HOLD]
	if {[safe_string_compare $buff_type "differential"] && [safe_string_compare $open_drain "true"]} {
		send_message error "differential buffer and open-drain can't be used at the same time"
	}
	if {[safe_string_compare $buff_type "differential"] && [safe_string_compare $bus_hold "true"]} {
		send_message error "differential buffer and bus-hold can't be used at the same time"
	}
}

# proc: ::altera_gpio::common::add_all_files_in_dir
#
# Recursively finds and adds all files to fileset
# The output mirrors the input directory
# 
# NOTE: If you'd like things to be under a top directory
# set out_dir to an actual value, otherwise out_dir can be ""
#
# parameters: 
# 		dir - absolute directory to find files in
#		out_dir - relative directory to put files in for the output
#
# returns: nothing
#
proc ::altera_gpio::common::add_all_files_in_dir { dir out_dir } {
	# Find all files under dir
	set files [glob -nocomplain -directory $dir *]
	foreach item $files {
		if { [file isfile $item] == 1 } {
			set filename [file tail $item]
			add_fileset_file $out_dir/$filename OTHER PATH $item
		} else {
			set dirname [file tail $item]
			set chain_dirname "${out_dir}/${dirname}"
			add_all_files_in_dir $item $chain_dirname
		}
	}
}

proc ::altera_gpio::common::generate_vhdl_sim {encrypted_files} {
	set rtl_only 0
	set encrypted 1   

	set non_encryp_simulators [::altera_emif::util::hwtcl_utils::get_simulator_attributes 1]

	# Return Verilog/SV files that have an encrypted counterpart
	set file_paths $encrypted_files

	foreach file_path $file_paths {
		set tmp [file split $file_path]
		set file_name [lindex $tmp end]

		# Return the normal verilog file for dual language simulators
		add_fileset_file $file_name [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only 0] PATH $file_path $non_encryp_simulators

		# Return the mentor tagged files
		add_fileset_file [file join mentor $file_name] [::altera_emif::util::hwtcl_utils::get_file_type $file_name $rtl_only $encrypted] PATH [file join mentor $file_path] {MENTOR_SPECIFIC}
	} 
}

proc ::altera_gpio::common::add_gpio_parameters { is_driver is_top } {
	
	if {$is_top == "true"} {
		set has_hdl_parameters "false"
	} else {
		set has_hdl_parameters "true"
	}
	
	# +-----------------------------------
	# | GUI Parameters
	# | 
	add_parameter PIN_TYPE STRING "output"
	set_parameter_property PIN_TYPE DEFAULT_VALUE "output"
	set_parameter_property PIN_TYPE DISPLAY_NAME "Data Direction"
	set_parameter_property PIN_TYPE ALLOWED_RANGES {"input" "output" "bidir"}
	set_parameter_property PIN_TYPE AFFECTS_GENERATION true
	set_parameter_property PIN_TYPE DESCRIPTION "Specifies the data direction for the GPIO"
	set_parameter_property PIN_TYPE HDL_PARAMETER $has_hdl_parameters
	add_display_item "General" PIN_TYPE parameter

	add_parameter SIZE INTEGER 4
	set_parameter_property SIZE DEFAULT_VALUE 4
	set_parameter_property SIZE DISPLAY_NAME "Data width"
	#set_parameter_property SIZE ALLOWED_RANGES {1:16}
	set_parameter_property SIZE AFFECTS_GENERATION true
	set_parameter_property SIZE DESCRIPTION "Specifies the data width"
	set_parameter_property SIZE HDL_PARAMETER $has_hdl_parameters
	add_display_item "General" SIZE parameter

	add_parameter gui_diff_buff BOOLEAN false ""
	set_parameter_property gui_diff_buff DISPLAY_NAME "Use differential buffer"
	set_parameter_property gui_diff_buff AFFECTS_GENERATION true
	set_parameter_property gui_diff_buff DESCRIPTION "Specifies the use of differential buffer"
	set_parameter_property gui_diff_buff HDL_PARAMETER false
	set_parameter_property gui_diff_buff VISIBLE true
	set_parameter_property gui_diff_buff ENABLED true
	add_display_item "Buffer" gui_diff_buff parameter

	add_parameter gui_pseudo_diff BOOLEAN true ""
	set_parameter_property gui_pseudo_diff DISPLAY_NAME "Use pseudo-differential buffer"
	set_parameter_property gui_pseudo_diff AFFECTS_GENERATION true
	set_parameter_property gui_pseudo_diff DESCRIPTION "Specifies the use of pseudo-differential buffer"
	set_parameter_property gui_pseudo_diff HDL_PARAMETER false
	set_parameter_property gui_pseudo_diff VISIBLE true
	set_parameter_property gui_pseudo_diff ENABLED true
	add_display_item "Buffer" gui_pseudo_diff parameter

	add_parameter gui_pseudo_diff_off_shadow BOOLEAN false ""
	set_parameter_property gui_pseudo_diff_off_shadow DISPLAY_NAME "Use pseudo-differential buffer"
	set_parameter_property gui_pseudo_diff_off_shadow AFFECTS_GENERATION true
	set_parameter_property gui_pseudo_diff_off_shadow DESCRIPTION "Specifies the use of pseudo-differential buffer"
	set_parameter_property gui_pseudo_diff_off_shadow HDL_PARAMETER false
	set_parameter_property gui_pseudo_diff_off_shadow VISIBLE false
	set_parameter_property gui_pseudo_diff_off_shadow ENABLED false
	add_display_item "Buffer" gui_pseudo_diff_off_shadow parameter

	add_parameter gui_pseudo_diff_on_shadow BOOLEAN true ""
	set_parameter_property gui_pseudo_diff_on_shadow DISPLAY_NAME "Use pseudo-differential buffer"
	set_parameter_property gui_pseudo_diff_on_shadow AFFECTS_GENERATION true
	set_parameter_property gui_pseudo_diff_on_shadow DESCRIPTION "Specifies the use of pseudo-differential buffer"
	set_parameter_property gui_pseudo_diff_on_shadow HDL_PARAMETER false
	set_parameter_property gui_pseudo_diff_on_shadow VISIBLE false
	set_parameter_property gui_pseudo_diff_on_shadow ENABLED false
	add_display_item "Buffer" gui_pseudo_diff_on_shadow parameter

	add_parameter gui_bus_hold BOOLEAN false ""
	set_parameter_property gui_bus_hold DISPLAY_NAME "Use bus-hold circuitry"
	set_parameter_property gui_bus_hold AFFECTS_GENERATION true
	set_parameter_property gui_bus_hold DESCRIPTION "Specifies the use of bus-hold circuitry"
	set_parameter_property gui_bus_hold HDL_PARAMETER false
	set_parameter_property gui_bus_hold VISIBLE true
	set_parameter_property gui_bus_hold ENABLED true
	add_display_item "Buffer" gui_bus_hold parameter

	add_parameter gui_open_drain BOOLEAN false ""
	set_parameter_property gui_open_drain DISPLAY_NAME "Use open-drain output"
	set_parameter_property gui_open_drain AFFECTS_GENERATION true
	set_parameter_property gui_open_drain DESCRIPTION "Specifies the use of open-drain output"
	set_parameter_property gui_open_drain HDL_PARAMETER false
	set_parameter_property gui_open_drain VISIBLE true
	set_parameter_property gui_open_drain ENABLED true
	add_display_item "Buffer" gui_open_drain parameter

	add_parameter gui_use_oe BOOLEAN false ""
	set_parameter_property gui_use_oe DISPLAY_NAME "Enable OE port"
	set_parameter_property gui_use_oe AFFECTS_GENERATION true
	set_parameter_property gui_use_oe DESCRIPTION "Specifies whether the output buffer will have the OE port exposed"
	set_parameter_property gui_use_oe HDL_PARAMETER false
	set_parameter_property gui_use_oe VISIBLE true
	set_parameter_property gui_use_oe ENABLED true
	add_display_item "Buffer" gui_use_oe parameter
	
	add_parameter gui_bus_hold_shadow BOOLEAN false ""
	set_parameter_property gui_bus_hold_shadow DISPLAY_NAME "Use bus-hold circuitry"
	set_parameter_property gui_bus_hold_shadow AFFECTS_GENERATION true
	set_parameter_property gui_bus_hold_shadow DESCRIPTION "Specifies the use of bus-hold circuitry"
	set_parameter_property gui_bus_hold_shadow HDL_PARAMETER false
	set_parameter_property gui_bus_hold_shadow VISIBLE false
	set_parameter_property gui_bus_hold_shadow ENABLED false
	add_display_item "Buffer" gui_bus_hold_shadow parameter

	add_parameter gui_open_drain_shadow BOOLEAN false ""
	set_parameter_property gui_open_drain_shadow DISPLAY_NAME "Use open-drain output"
	set_parameter_property gui_open_drain_shadow AFFECTS_GENERATION true
	set_parameter_property gui_open_drain_shadow DESCRIPTION "Specifies the use of open-drain output"
	set_parameter_property gui_open_drain_shadow HDL_PARAMETER false
	set_parameter_property gui_open_drain_shadow VISIBLE false
	set_parameter_property gui_open_drain_shadow ENABLED false
	add_display_item "Buffer" gui_open_drain_shadow parameter

	add_parameter gui_use_oe_off_shadow BOOLEAN false ""
	set_parameter_property gui_use_oe_off_shadow DISPLAY_NAME "Enable OE port"
	set_parameter_property gui_use_oe_off_shadow AFFECTS_GENERATION true
	set_parameter_property gui_use_oe_off_shadow DESCRIPTION "Specifies the use of open-drain output"
	set_parameter_property gui_use_oe_off_shadow HDL_PARAMETER false
	set_parameter_property gui_use_oe_off_shadow VISIBLE false
	set_parameter_property gui_use_oe_off_shadow ENABLED false
	add_display_item "Buffer" gui_use_oe_off_shadow parameter

	add_parameter gui_use_oe_on_shadow BOOLEAN true ""
	set_parameter_property gui_use_oe_on_shadow DISPLAY_NAME "Enable OE port"
	set_parameter_property gui_use_oe_on_shadow AFFECTS_GENERATION true
	set_parameter_property gui_use_oe_on_shadow DESCRIPTION "Specifies the use of open-drain output"
	set_parameter_property gui_use_oe_on_shadow HDL_PARAMETER false
	set_parameter_property gui_use_oe_on_shadow VISIBLE false
	set_parameter_property gui_use_oe_on_shadow ENABLED false
	add_display_item "Buffer" gui_use_oe_on_shadow parameter

	add_parameter gui_enable_termination_ports BOOLEAN false ""
	set_parameter_property gui_enable_termination_ports DISPLAY_NAME "Enable seriestermination/paralleltermination ports"
	set_parameter_property gui_enable_termination_ports AFFECTS_GENERATION true
	set_parameter_property gui_enable_termination_ports DESCRIPTION "Specifies whether the output buffer will have the seriestermination/paralleltermination ports enabled"
	set_parameter_property gui_enable_termination_ports HDL_PARAMETER false
	set_parameter_property gui_enable_termination_ports VISIBLE true
	set_parameter_property gui_enable_termination_ports ENABLED true
	add_display_item "Buffer" gui_enable_termination_ports parameter
	
	add_parameter gui_io_reg_mode STRING "none"
	set_parameter_property gui_io_reg_mode DEFAULT_VALUE "none"
	set_parameter_property gui_io_reg_mode DISPLAY_NAME "Register Mode"
	set_parameter_property gui_io_reg_mode ALLOWED_RANGES {"none" "Simple register" "DDIO"}
	set_parameter_property gui_io_reg_mode AFFECTS_GENERATION true
	set_parameter_property gui_io_reg_mode DESCRIPTION "Specifies the register mode for the GPIO (Input, Output, or Both)"
	set_parameter_property gui_io_reg_mode HDL_PARAMETER false
	set_parameter_property gui_io_reg_mode VISIBLE true
	add_display_item "Registers" gui_io_reg_mode parameter

	add_parameter gui_hr_logic BOOLEAN false ""
	set_parameter_property gui_hr_logic DISPLAY_NAME "Half Rate Logic"
	set_parameter_property gui_hr_logic AFFECTS_GENERATION true
	set_parameter_property gui_hr_logic DESCRIPTION "Specifies whether the GPIO uses half rate logic"
	set_parameter_property gui_hr_logic HDL_PARAMETER false
	set_parameter_property gui_hr_logic VISIBLE true
	set_parameter_property gui_hr_logic ENABLED false
	add_display_item "Registers" gui_hr_logic parameter

	add_parameter gui_separate_io_clks BOOLEAN false ""
	set_parameter_property gui_separate_io_clks DISPLAY_NAME "Separate Input/Output Clocks"
	set_parameter_property gui_separate_io_clks AFFECTS_GENERATION true
	set_parameter_property gui_separate_io_clks DESCRIPTION "Specifies whether the GPIO uses separate clocks for input and output"
	set_parameter_property gui_separate_io_clks HDL_PARAMETER false
	set_parameter_property gui_separate_io_clks VISIBLE true
	set_parameter_property gui_separate_io_clks ENABLED false
	add_display_item "Registers" gui_separate_io_clks parameter

	add_parameter gui_sreset_mode STRING "none"
	set_parameter_property gui_sreset_mode DEFAULT_VALUE "none"
	set_parameter_property gui_sreset_mode DISPLAY_NAME "Enable synchronous clear / preset"
	set_parameter_property gui_sreset_mode ALLOWED_RANGES {"none" "clear" "preset"}
	set_parameter_property gui_sreset_mode AFFECTS_GENERATION true
	set_parameter_property gui_sreset_mode DESCRIPTION "Specifies how to implement synchronous reset"
	set_parameter_property gui_sreset_mode HDL_PARAMETER false
	set_parameter_property gui_sreset_mode DISPLAY_HINT radio
	set_parameter_property gui_sreset_mode VISIBLE true
	add_display_item "Registers" gui_sreset_mode parameter

	add_parameter gui_sreset_mode_off_shadow STRING "none"
	set_parameter_property gui_sreset_mode_off_shadow DEFAULT_VALUE "none"
	set_parameter_property gui_sreset_mode_off_shadow DISPLAY_NAME "Enable synchronous clear / preset"
	set_parameter_property gui_sreset_mode_off_shadow ALLOWED_RANGES {"none" "clear" "preset"}
	set_parameter_property gui_sreset_mode_off_shadow AFFECTS_GENERATION true
	set_parameter_property gui_sreset_mode_off_shadow DESCRIPTION "Specifies how to implement synchronous reset"
	set_parameter_property gui_sreset_mode_off_shadow HDL_PARAMETER false
	set_parameter_property gui_sreset_mode_off_shadow DISPLAY_HINT radio
	set_parameter_property gui_sreset_mode_off_shadow VISIBLE false
	set_parameter_property gui_sreset_mode_off_shadow ENABLED false
	add_display_item "Registers" gui_sreset_mode_off_shadow parameter

	add_parameter gui_areset_mode STRING "none"
	set_parameter_property gui_areset_mode DEFAULT_VALUE "none"
	set_parameter_property gui_areset_mode DISPLAY_NAME "Enable asynchronous clear / preset"
	set_parameter_property gui_areset_mode ALLOWED_RANGES {"none" "clear" "preset"}
	set_parameter_property gui_areset_mode AFFECTS_GENERATION true
	set_parameter_property gui_areset_mode DESCRIPTION "Specifies how to implement asynchronous reset"
	set_parameter_property gui_areset_mode HDL_PARAMETER false
	set_parameter_property gui_areset_mode DISPLAY_HINT radio
	set_parameter_property gui_areset_mode VISIBLE true
	add_display_item "Registers" gui_areset_mode parameter

	add_parameter gui_areset_mode_off_shadow STRING "none"
	set_parameter_property gui_areset_mode_off_shadow DEFAULT_VALUE "none"
	set_parameter_property gui_areset_mode_off_shadow DISPLAY_NAME "Enable asynchronous clear / preset"
	set_parameter_property gui_areset_mode_off_shadow ALLOWED_RANGES {"none" "clear" "preset"}
	set_parameter_property gui_areset_mode_off_shadow AFFECTS_GENERATION true
	set_parameter_property gui_areset_mode_off_shadow DESCRIPTION "Specifies how to implement asynchronous reset"
	set_parameter_property gui_areset_mode_off_shadow HDL_PARAMETER false
	set_parameter_property gui_areset_mode_off_shadow DISPLAY_HINT radio
	set_parameter_property gui_areset_mode_off_shadow VISIBLE false
	set_parameter_property gui_areset_mode_off_shadow ENABLED false
	add_display_item "Registers" gui_areset_mode_off_shadow parameter

	add_parameter gui_enable_cke BOOLEAN false ""
	set_parameter_property gui_enable_cke DISPLAY_NAME "Enable clock enable port"
	set_parameter_property gui_enable_cke AFFECTS_GENERATION true
	set_parameter_property gui_enable_cke DESCRIPTION "Specifies whether the DDIO will have the clock enable port exposed"
	set_parameter_property gui_enable_cke HDL_PARAMETER false
	set_parameter_property gui_enable_cke VISIBLE true
	set_parameter_property gui_enable_cke ENABLED true
	add_display_item "Registers" gui_enable_cke parameter

	add_parameter gui_enable_cke_off_shadow BOOLEAN false ""
	set_parameter_property gui_enable_cke_off_shadow DISPLAY_NAME "Enable clock enable port"
	set_parameter_property gui_enable_cke_off_shadow AFFECTS_GENERATION true
	set_parameter_property gui_enable_cke_off_shadow DESCRIPTION "Specifies whether the DDIO will have the clock enable port exposed"
	set_parameter_property gui_enable_cke_off_shadow HDL_PARAMETER false
	set_parameter_property gui_enable_cke_off_shadow VISIBLE false
	set_parameter_property gui_enable_cke_off_shadow ENABLED false
	add_display_item "Registers" gui_enable_cke_off_shadow parameter

	######################################################################### 

	# +-----------------------------------
	# | non-GUI Parameters
	# | 

	add_parameter REGISTER_MODE STRING "sdr"
	set_parameter_property REGISTER_MODE DEFAULT_VALUE "sdr"
	set_parameter_property REGISTER_MODE ALLOWED_RANGES {"none" "sdr" "ddr"}
	set_parameter_property REGISTER_MODE AFFECTS_GENERATION true
	set_parameter_property REGISTER_MODE HDL_PARAMETER $has_hdl_parameters
	set_parameter_property REGISTER_MODE VISIBLE false
	set_parameter_property REGISTER_MODE DERIVED true

	add_parameter HALF_RATE STRING "false"
	set_parameter_property HALF_RATE DEFAULT_VALUE "false"
	set_parameter_property HALF_RATE ALLOWED_RANGES {"false" "true"}
	set_parameter_property HALF_RATE AFFECTS_GENERATION true
	set_parameter_property HALF_RATE HDL_PARAMETER $has_hdl_parameters
	set_parameter_property HALF_RATE VISIBLE false
	set_parameter_property HALF_RATE DERIVED true

	add_parameter SEPARATE_I_O_CLOCKS STRING "false"
	set_parameter_property SEPARATE_I_O_CLOCKS DEFAULT_VALUE "false"
	set_parameter_property SEPARATE_I_O_CLOCKS ALLOWED_RANGES {"true" "false"}
	set_parameter_property SEPARATE_I_O_CLOCKS AFFECTS_GENERATION true
	set_parameter_property SEPARATE_I_O_CLOCKS HDL_PARAMETER $has_hdl_parameters
	set_parameter_property SEPARATE_I_O_CLOCKS VISIBLE false
	set_parameter_property SEPARATE_I_O_CLOCKS DERIVED true

	add_parameter BUFFER_TYPE STRING "single-ended"
	set_parameter_property BUFFER_TYPE DEFAULT_VALUE "single-ended"
	set_parameter_property BUFFER_TYPE ALLOWED_RANGES {"single-ended" "differential"}
	set_parameter_property BUFFER_TYPE AFFECTS_GENERATION true
	set_parameter_property BUFFER_TYPE HDL_PARAMETER $has_hdl_parameters
	set_parameter_property BUFFER_TYPE VISIBLE false
	set_parameter_property BUFFER_TYPE DERIVED true

	add_parameter PSEUDO_DIFF STRING "false"
	set_parameter_property PSEUDO_DIFF DEFAULT_VALUE "false"
	set_parameter_property PSEUDO_DIFF ALLOWED_RANGES {"false" "true"}
	set_parameter_property PSEUDO_DIFF AFFECTS_GENERATION true
	set_parameter_property PSEUDO_DIFF HDL_PARAMETER $has_hdl_parameters
	set_parameter_property PSEUDO_DIFF VISIBLE false
	set_parameter_property PSEUDO_DIFF DERIVED true

	add_parameter ARESET_MODE STRING "none"
	set_parameter_property ARESET_MODE DEFAULT_VALUE "false"
	set_parameter_property ARESET_MODE ALLOWED_RANGES {"none" "clear" "preset"}
	set_parameter_property ARESET_MODE AFFECTS_GENERATION true
	set_parameter_property ARESET_MODE HDL_PARAMETER $has_hdl_parameters
	set_parameter_property ARESET_MODE VISIBLE false
	set_parameter_property ARESET_MODE DERIVED true

	add_parameter SRESET_MODE STRING "none"
	set_parameter_property SRESET_MODE DEFAULT_VALUE "false"
	set_parameter_property SRESET_MODE ALLOWED_RANGES {"none" "clear" "preset"}
	set_parameter_property SRESET_MODE AFFECTS_GENERATION true
	set_parameter_property SRESET_MODE HDL_PARAMETER $has_hdl_parameters
	set_parameter_property SRESET_MODE VISIBLE false
	set_parameter_property SRESET_MODE DERIVED true

	add_parameter OPEN_DRAIN STRING "false"
	set_parameter_property OPEN_DRAIN DEFAULT_VALUE "false"
	set_parameter_property OPEN_DRAIN ALLOWED_RANGES {"false" "true"}
	set_parameter_property OPEN_DRAIN AFFECTS_GENERATION true
	set_parameter_property OPEN_DRAIN HDL_PARAMETER $has_hdl_parameters
	set_parameter_property OPEN_DRAIN VISIBLE false
	set_parameter_property OPEN_DRAIN DERIVED true

	add_parameter BUS_HOLD STRING "false"
	set_parameter_property BUS_HOLD DEFAULT_VALUE "false"
	set_parameter_property BUS_HOLD ALLOWED_RANGES {"false" "true"}
	set_parameter_property BUS_HOLD AFFECTS_GENERATION true
	set_parameter_property BUS_HOLD HDL_PARAMETER $has_hdl_parameters
	set_parameter_property BUS_HOLD VISIBLE false
	set_parameter_property BUS_HOLD DERIVED true

	# | 
	# +-----------------------------------
	
	# +-----------------------------------
	# | Secret Parameters
	# | 
	
	add_parameter _HIDDEN_ENABLE_RESET_TEST BOOLEAN false ""
	set_parameter_property _HIDDEN_ENABLE_RESET_TEST DEFAULT_VALUE "false"
	set_parameter_property _HIDDEN_ENABLE_RESET_TEST AFFECTS_GENERATION true
	set_parameter_property _HIDDEN_ENABLE_RESET_TEST HDL_PARAMETER false
	set_parameter_property _HIDDEN_ENABLE_RESET_TEST VISIBLE false
	set_parameter_property _HIDDEN_ENABLE_RESET_TEST DERIVED false

	add_parameter _HIDDEN_ENABLE_SDC_GENERATION BOOLEAN false ""
	set_parameter_property _HIDDEN_ENABLE_SDC_GENERATION DEFAULT_VALUE "false"
	set_parameter_property _HIDDEN_ENABLE_SDC_GENERATION AFFECTS_GENERATION true
	set_parameter_property _HIDDEN_ENABLE_SDC_GENERATION HDL_PARAMETER false
	set_parameter_property _HIDDEN_ENABLE_SDC_GENERATION VISIBLE false
	set_parameter_property _HIDDEN_ENABLE_SDC_GENERATION DERIVED false

	# | 
	# +-----------------------------------
}

proc ::altera_gpio::common::validate {} {
    set data_dir [get_parameter_value PIN_TYPE]
    set sep_io_clks [get_parameter_value gui_separate_io_clks]
    set half_rate [get_parameter_value gui_hr_logic]
    set io_reg_mode [get_parameter_value gui_io_reg_mode]
	set diff_buff [get_parameter_value gui_diff_buff]
	set pseudo_diff [get_parameter_value gui_pseudo_diff]

    if {$data_dir == "input"} {
		set_parameter_property gui_separate_io_clks ENABLED false
		set_parameter_value SEPARATE_I_O_CLOCKS "false"
    } elseif {$data_dir == "output"} {
		set_parameter_property gui_separate_io_clks ENABLED false
		set_parameter_value SEPARATE_I_O_CLOCKS "false"
    } elseif {$data_dir == "bidir" && (($io_reg_mode == "DDIO") || ([safe_string_compare $io_reg_mode "Simple register"]))} {
		set_parameter_property gui_separate_io_clks ENABLED true

		if {[safe_string_compare $sep_io_clks "true"]} {
	    	set_parameter_value SEPARATE_I_O_CLOCKS "true"
		} else {
	    	set_parameter_value SEPARATE_I_O_CLOCKS "false"
		}
    }

    if {$io_reg_mode == "DDIO"} {
		set_parameter_property gui_hr_logic ENABLED true

		if {[safe_string_compare $half_rate "true"]} {
	    	set_parameter_value HALF_RATE "true"
		} else {
	    	set_parameter_value HALF_RATE "false"
		}

		set_parameter_value REGISTER_MODE "ddr"
    } elseif {[safe_string_compare $io_reg_mode "Simple register"]} {
		set_parameter_property gui_hr_logic ENABLED false
		set_parameter_value HALF_RATE "false"
		set_parameter_value REGISTER_MODE "sdr"
    } else {
		set_parameter_property gui_hr_logic ENABLED false
		set_parameter_value HALF_RATE "false"
		set_parameter_value REGISTER_MODE "none"
    }

	if {[safe_string_compare $diff_buff "true"]} {
		set_parameter_value BUFFER_TYPE "differential"
	} else {
		set_parameter_value BUFFER_TYPE "single-ended"
	}
   
	if {[safe_string_compare $diff_buff "true"]} {
		if {[safe_string_compare $data_dir "output"]} { 
			set_parameter_property gui_pseudo_diff VISIBLE true
			set_parameter_property gui_pseudo_diff_off_shadow VISIBLE false
			set_parameter_property gui_pseudo_diff_on_shadow VISIBLE false

			if {[safe_string_compare $pseudo_diff "true"]} {
				set_parameter_value PSEUDO_DIFF "true"
			} else {
				set_parameter_value PSEUDO_DIFF "false"
			}
		} elseif {[safe_string_compare $data_dir "bidir"]} { 
			set_parameter_property gui_pseudo_diff VISIBLE false
			set_parameter_property gui_pseudo_diff_off_shadow VISIBLE false
			set_parameter_property gui_pseudo_diff_on_shadow VISIBLE true

			set_parameter_value PSEUDO_DIFF "true"
		} else {
			set_parameter_property gui_pseudo_diff VISIBLE false
			set_parameter_property gui_pseudo_diff_off_shadow VISIBLE true
			set_parameter_property gui_pseudo_diff_on_shadow VISIBLE false
			set_parameter_value PSEUDO_DIFF "false"
		}
	} else {
		set_parameter_property gui_pseudo_diff VISIBLE false
		set_parameter_property gui_pseudo_diff_off_shadow VISIBLE true
		set_parameter_property gui_pseudo_diff_on_shadow VISIBLE false
		set_parameter_value PSEUDO_DIFF "false"
	}

	# Open drain derivation
    if {$data_dir == "input"} {
		set_parameter_property gui_open_drain VISIBLE false
		set_parameter_property gui_open_drain_shadow VISIBLE true
		set_parameter_value OPEN_DRAIN "false"
	} else {
		set_parameter_property gui_open_drain VISIBLE true
		set_parameter_property gui_open_drain_shadow VISIBLE false
		set_parameter_value OPEN_DRAIN [get_parameter_value gui_open_drain]
	}

	# Bus hold derivation
	set_parameter_value BUS_HOLD [get_parameter_value gui_bus_hold]
	
	# Output Enable derivation
	if {$data_dir == "output"} {
		set_parameter_property gui_use_oe VISIBLE true
		set_parameter_property gui_use_oe_off_shadow VISIBLE false
		set_parameter_property gui_use_oe_on_shadow VISIBLE false
	} elseif {$data_dir == "input"} {
		set_parameter_property gui_use_oe VISIBLE false
		set_parameter_property gui_use_oe_off_shadow VISIBLE true
		set_parameter_property gui_use_oe_on_shadow VISIBLE false
	} else {
		set_parameter_property gui_use_oe VISIBLE false
		set_parameter_property gui_use_oe_off_shadow VISIBLE false
		set_parameter_property gui_use_oe_on_shadow VISIBLE true
	}

	# ARESET GUI
    if {$io_reg_mode == "DDIO"} {
		set_parameter_property gui_areset_mode VISIBLE true
		set_parameter_property gui_areset_mode_off_shadow VISIBLE false
		set_parameter_value ARESET_MODE [get_parameter_value gui_areset_mode]
	} else {
		set_parameter_property gui_areset_mode VISIBLE false
		set_parameter_property gui_areset_mode_off_shadow VISIBLE true
		set_parameter_value ARESET_MODE "none"
	}

	# SRESET GUI
    if {$io_reg_mode == "DDIO"} {
		set_parameter_property gui_sreset_mode VISIBLE true
		set_parameter_property gui_sreset_mode_off_shadow VISIBLE false
		set_parameter_value SRESET_MODE [get_parameter_value gui_sreset_mode]
	} else {
		set_parameter_property gui_sreset_mode VISIBLE false
		set_parameter_property gui_sreset_mode_off_shadow VISIBLE true
		set_parameter_value SRESET_MODE "none"
	}

	# Clock Enable
	if {[safe_string_compare $io_reg_mode "DDIO"]} { 
		set_parameter_property gui_enable_cke VISIBLE true
		set_parameter_property gui_enable_cke_off_shadow VISIBLE false
	} else {
		set_parameter_property gui_enable_cke VISIBLE false
		set_parameter_property gui_enable_cke_off_shadow VISIBLE true
	}

	::altera_gpio::common::legality_checks
}

proc ::altera_gpio::common::elaborate { is_driver } {
	set_clock_interface $is_driver
	set_data_interface $is_driver
	set_pad_interface $is_driver
	set_termination_interface $is_driver
	set_reset_cke_interface  $is_driver
}

proc ::altera_gpio::common::add_interface_and_port { interfaces direction } {
	foreach interface $interfaces {
		add_interface $interface conduit end
		add_interface_port $interface $interface export $direction 1
		set_interface_property $interface ENABLED false
	}
}

proc ::altera_gpio::common::set_clock_interface { is_driver } {
	set reg_mode [get_parameter_value gui_io_reg_mode]
    set half_rate [get_parameter_value gui_hr_logic]
	set sep_io_clocks [get_parameter_value SEPARATE_I_O_CLOCKS]
	
	if {$is_driver == "true"} {
		set gpio_input_driver_output "Output"
		set gpio_output_driver_input "Input"
	} else {
		set gpio_input_driver_output "Input"
		set gpio_output_driver_input "Output"
	}
	
	# Possible clock interfaces
	# - Combinational: No clock
	# - Unidirectional channel, only FR: ck
	# - Unidirectional channel, FR and HR: ck_fr , ck_hr
	# - Bidirectional channel, separate clocks, only FR: ck_in , ck_out
	# - Bidirectional channel, separate clocks, FR and HR: ck_in_fr , ck_in_hr , ck_out_fr , ck_out_hr

	set ck_input_interfaces [list ck_fr_in \
								ck_fr_out \
								ck_in \
								ck_out \
								ck_fr \
								ck \
								ck_hr_in \
								ck_hr_out \
								ck_hr ]
	
	add_interface_and_port $ck_input_interfaces $gpio_input_driver_output
	
	if {$reg_mode == "none"} {
		# No clock interface is required
	} else {
		# FR Clock section
		if {[safe_string_compare $sep_io_clocks true]} {
			if {[safe_string_compare $half_rate true]} {
	    		set_interface_property ck_fr_in ENABLED true
	    		set_interface_property ck_fr_out ENABLED true
			} else {
	    		set_interface_property ck_in ENABLED true
	    		set_interface_property ck_out ENABLED true
			}
		} else {
			if {[safe_string_compare $half_rate true]} {
	    		set_interface_property ck_fr ENABLED true
			} else {
	    		set_interface_property ck ENABLED true
			}
		}
		# HR Clock section
		if {[safe_string_compare $half_rate true]} {
			if {[safe_string_compare $sep_io_clocks true]} {
	    		set_interface_property ck_hr_in ENABLED true
	    		set_interface_property ck_hr_out ENABLED true
			} else {
	    		set_interface_property ck_hr ENABLED true
			}
		}
	}
}

proc ::altera_gpio::common::set_pad_interface { is_driver } {
    set data_size [get_parameter_value SIZE]
    set data_dir [get_parameter_value PIN_TYPE]
	set diff_buff [get_parameter_value gui_diff_buff]
	
	if {$is_driver == "true"} {
		set gpio_input_driver_output "Output"
		set gpio_output_driver_input "Input"
	} else {
		set gpio_input_driver_output "Input"
		set gpio_output_driver_input "Output"
	}
	
	# PAD IO
	add_interface pad_io conduit end
	add_interface pad_io_b conduit end
	set_interface_property pad_io ENABLED false
	set_interface_property pad_io_b ENABLED false
	add_interface_port pad_io pad_io export Bidir $data_size
	add_interface_port pad_io_b pad_io_b export Bidir $data_size
	
	# PAD IN
	add_interface pad_in conduit end
	add_interface pad_in_b conduit end
	set_interface_property pad_in ENABLED false
	set_interface_property pad_in_b ENABLED false
	add_interface_port pad_in pad_in export $gpio_input_driver_output $data_size
	add_interface_port pad_in_b pad_in_b export $gpio_input_driver_output $data_size
	
	# PAD OUT
	add_interface pad_out conduit end
	add_interface pad_out_b conduit end
	set_interface_property pad_out ENABLED false
	set_interface_property pad_out_b ENABLED false
	add_interface_port pad_out pad_out export $gpio_output_driver_input $data_size
	add_interface_port pad_out_b pad_out_b export $gpio_output_driver_input $data_size
	
	if {$data_dir == "input"} {
	    set_interface_property pad_in ENABLED true
		if {[safe_string_compare $diff_buff true]} {
	    	set_interface_property pad_in_b ENABLED true
		}
	} elseif {$data_dir == "output"} {
		set_interface_property pad_out ENABLED true
	    if {[safe_string_compare $diff_buff true]} {
	    	set_interface_property pad_out_b ENABLED true
		}
	} else {
		set_interface_property pad_io ENABLED true
		if {[safe_string_compare $diff_buff true]} {
    		set_interface_property pad_io_b ENABLED true
		}
	}
}

proc ::altera_gpio::common::set_data_interface { is_driver } {
    set io_reg_mode [get_parameter_value REGISTER_MODE]
    set data_size [get_parameter_value SIZE]
    set half_rate [get_parameter_value HALF_RATE]
    set data_dir [get_parameter_value PIN_TYPE]

	if {$is_driver == "true"} {
		set gpio_input_driver_output "Output"
		set gpio_output_driver_input "Input"
	} else {
		set gpio_input_driver_output "Input"
		set gpio_output_driver_input "Output"
	}
	
	add_interface dout conduit end
	add_interface din conduit end
	add_interface oe conduit end
	set_interface_property dout ENABLED false
	set_interface_property din ENABLED false
	set_interface_property oe ENABLED false
	
	if {[safe_string_compare $io_reg_mode ddr]} {
		if {[safe_string_compare $half_rate true]} {
			add_interface_port dout dout export $gpio_output_driver_input [expr $data_size * 4]
		} else {
			add_interface_port dout dout export $gpio_output_driver_input [expr $data_size * 2]
		}
	} else {
		add_interface_port dout dout export $gpio_output_driver_input $data_size
	}
	
	if {[safe_string_compare $data_dir input] || [safe_string_compare $data_dir bidir]} {
    	set_interface_property dout ENABLED true
	}

	if {[safe_string_compare $io_reg_mode ddr]} {
		if {[safe_string_compare $half_rate true]} {
			add_interface_port oe oe export $gpio_input_driver_output [expr $data_size * 2]
			add_interface_port din din export $gpio_input_driver_output [expr $data_size * 4]
		} else {
			add_interface_port oe oe export $gpio_input_driver_output [expr $data_size]
			add_interface_port din din export $gpio_input_driver_output [expr $data_size * 2]
		}
	} else {
		add_interface_port oe oe export $gpio_input_driver_output [expr $data_size]
		add_interface_port din din export $gpio_input_driver_output $data_size
	}
	if {[safe_string_compare $data_dir output] || [safe_string_compare $data_dir bidir]} {
		set_interface_property din ENABLED true
	}

	set use_oe_port [get_parameter_value gui_use_oe]
	if {[safe_string_compare $data_dir bidir] || ([safe_string_compare $data_dir output] && [safe_string_compare $use_oe_port true]) } {
		set_interface_property oe ENABLED true
	}
}

proc ::altera_gpio::common::set_termination_interface { is_driver } {
    set enable_termination_ports [get_parameter_value gui_enable_termination_ports]

	if {$is_driver == "true"} {
		set gpio_input_driver_output "Output"
		set gpio_output_driver_input "Input"
	} else {
		set gpio_input_driver_output "Input"
		set gpio_output_driver_input "Output"
	}
	
	# Series
	add_interface seriesterminationcontrol conduit end
	set_interface_property seriesterminationcontrol ENABLED false
	add_interface_port seriesterminationcontrol seriesterminationcontrol export $gpio_input_driver_output 16

	# Parallel
	add_interface parallelterminationcontrol conduit end
	set_interface_property parallelterminationcontrol ENABLED false
	add_interface_port parallelterminationcontrol parallelterminationcontrol export $gpio_input_driver_output 16
	
	if {[safe_string_compare $enable_termination_ports true]} {
		set_interface_property seriesterminationcontrol ENABLED true
		set_interface_property parallelterminationcontrol ENABLED true
	}
}

proc ::altera_gpio::common::set_reset_cke_interface { is_driver } {
	set areset_mode [ get_parameter_value ARESET_MODE ]
	set sreset_mode [ get_parameter_value SRESET_MODE ]
    set io_reg_mode [get_parameter_value REGISTER_MODE]
    set enable_cke [get_parameter_value gui_enable_cke]

	if {$is_driver == "true"} {
		set gpio_input_driver_output "Output"
		set gpio_output_driver_input "Input"
	} else {
		set gpio_input_driver_output "Input"
		set gpio_output_driver_input "Output"
	}
	
	add_interface aclr conduit end
	add_interface_port aclr aclr export $gpio_input_driver_output 1
	set_interface_property aclr ENABLED false
	
	add_interface aset conduit end
	add_interface_port aset aset export $gpio_input_driver_output 1
	set_interface_property aset ENABLED false
	
	add_interface sclr conduit end
	add_interface_port sclr sclr export $gpio_input_driver_output 1
	set_interface_property sclr ENABLED false
	
	add_interface sset conduit end
	add_interface_port sset sset export $gpio_input_driver_output 1
	set_interface_property sset ENABLED false
	
	if {[safe_string_compare $areset_mode clear]} {
		set_interface_property aclr ENABLED true
	} elseif {[safe_string_compare $areset_mode preset]} {
		set_interface_property aset ENABLED true
	}

	if {[safe_string_compare $sreset_mode clear]} {
		set_interface_property sclr ENABLED true
	} elseif {[safe_string_compare $sreset_mode preset]} {
		set_interface_property sset ENABLED true
	}

	add_interface cke conduit end
	add_interface_port cke cke export $gpio_input_driver_output 1
	set_port_property cke TERMINATION_VALUE 1
	if {[safe_string_compare $io_reg_mode ddr] && [safe_string_compare $enable_cke true]} {
		set_interface_property cke ENABLED true
	} else {
		set_interface_property cke ENABLED false
		set_port_property cke TERMINATION true
	}
}
