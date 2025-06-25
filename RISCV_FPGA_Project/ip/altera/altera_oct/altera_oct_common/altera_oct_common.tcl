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

# package: altera_oct::common
#
# Provides common functions for interacting with _hw.tcl API
#
package provide altera_oct::common 0.1

################################################################################
###                          TCL INCLUDES                                   ###
################################################################################

################################################################################
###                          TCL NAMESPACE                                   ###
################################################################################
namespace eval ::altera_oct::common:: {
   # Namespace Variables
   
   # Import functions into namespace

   # Export functions
   namespace export safe_string_compare
   namespace export add_oct_parameters
   namespace export validate
   namespace export elaborate
#   namespace export set_clock_interface
#   namespace export set_pad_interface
#   namespace export set_data_interface
   namespace export set_oct_interface   
   namespace export add_all_files_in_dir
   # Package variables
}

################################################################################
###                          TCL PROCEDURES                                  ###
################################################################################
proc ::altera_oct::common::safe_string_compare { string_1 string_2 } {
	set ret_val [expr {[string compare -nocase $string_1 $string_2] == 0}]
	return $ret_val
}

# proc: ::altera_oct::common::add_all_files_in_dir
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
proc ::altera_oct::common::add_all_files_in_dir { dir out_dir } {
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

proc ::altera_oct::common::add_oct_parameters { is_driver is_top } {

	if {$is_top == "true"} {
		set has_hdl_parameters "false"
	} else {
		set has_hdl_parameters "true"
	}
	
	# +-----------------------------------
	# | GUI Parameters
	# | 
	add_parameter OCT_CAL_MODE STRING "single"
	set_parameter_property OCT_CAL_MODE DEFAULT_VALUE "single"
	set_parameter_property OCT_CAL_MODE DISPLAY_NAME "Calibration mode"
	set_parameter_property OCT_CAL_MODE ALLOWED_RANGES {"single" "double" "POD"}
	set_parameter_property OCT_CAL_MODE AFFECTS_GENERATION true
	set_parameter_property OCT_CAL_MODE DESCRIPTION "Specifies the calibration mode for the oct"
	set_parameter_property OCT_CAL_MODE HDL_PARAMETER false
	add_display_item "General" OCT_CAL_MODE parameter

	add_parameter OCT_MODE BOOLEAN false ""
	set_parameter_property OCT_MODE DISPLAY_NAME "OCT mode"
	set_parameter_property OCT_MODE AFFECTS_GENERATION true
	set_parameter_property OCT_MODE DESCRIPTION "Specifies whether OCT will be user-controlled or not"
	set_parameter_property OCT_MODE HDL_PARAMETER false
	set_parameter_property OCT_MODE VISIBLE true
	set_parameter_property OCT_MODE ENABLED false
	add_display_item "General" OCT_MODE parameter

	######################################################################### 


	# +-----------------------------------
	# | non-GUI Parameters
	# | 

	add_parameter OCT_2X_CAL_MODE STRING ""
	set_parameter_property OCT_2X_CAL_MODE DEFAULT_VALUE "A_OCT_CAL_X2_DIS"
	set_parameter_property OCT_2X_CAL_MODE ALLOWED_RANGES {"A_OCT_CAL_X2_EN" "A_OCT_CAL_X2_DIS"}
	set_parameter_property OCT_2X_CAL_MODE AFFECTS_GENERATION true
	set_parameter_property OCT_2X_CAL_MODE HDL_PARAMETER $has_hdl_parameters
	set_parameter_property OCT_2X_CAL_MODE VISIBLE false
	set_parameter_property OCT_2X_CAL_MODE DERIVED true

	add_parameter OCT_DDR4_CAL_MODE STRING ""
	set_parameter_property OCT_DDR4_CAL_MODE DEFAULT_VALUE "A_OCT_CAL_DDR4_DIS"
	set_parameter_property OCT_DDR4_CAL_MODE ALLOWED_RANGES {"A_OCT_CAL_DDR4_EN" "A_OCT_CAL_DDR4_DIS"}
	set_parameter_property OCT_DDR4_CAL_MODE AFFECTS_GENERATION true
	set_parameter_property OCT_DDR4_CAL_MODE HDL_PARAMETER $has_hdl_parameters
	set_parameter_property OCT_DDR4_CAL_MODE VISIBLE false
	set_parameter_property OCT_DDR4_CAL_MODE DERIVED true

	# | 
	# +-----------------------------------
}

proc ::altera_oct::common::validate {} {
    set oct_cal_mode [get_parameter_value OCT_CAL_MODE]

    if {$oct_cal_mode == "single"} {
		set_parameter_value OCT_2X_CAL_MODE "A_OCT_CAL_X2_DIS"
		set_parameter_value OCT_DDR4_CAL_MODE "A_OCT_CAL_DDR4_DIS"
    } elseif {$oct_cal_mode == "double"} {
		set_parameter_value OCT_2X_CAL_MODE "A_OCT_CAL_X2_EN"
		set_parameter_value OCT_DDR4_CAL_MODE "A_OCT_CAL_DDR4_DIS"
    } elseif {$oct_cal_mode == "POD"} {
		set_parameter_value OCT_2X_CAL_MODE "A_OCT_CAL_X2_DIS"
		set_parameter_value OCT_DDR4_CAL_MODE "A_OCT_CAL_DDR4_EN"
    }

}

proc ::altera_oct::common::elaborate { is_driver } {
#	set_clock_interface $is_driver
#	set_data_interface $is_driver
#	set_pad_interface $is_driver
	set_oct_interface $is_driver
}

proc ::altera_oct::common::set_oct_interface { is_driver } {

	
	add_interface rzqin conduit end
	set_interface_property rzqin ENABLED true
	add_interface_port rzqin rzqin export Input 1

	add_interface series_termination_control conduit end
	set_interface_property series_termination_control ENABLED true
	add_interface_port series_termination_control series_termination_control export Output 16
	
	add_interface parallel_termination_control conduit end
	set_interface_property parallel_termination_control ENABLED true
	add_interface_port parallel_termination_control parallel_termination_control export Output 16
	
}
