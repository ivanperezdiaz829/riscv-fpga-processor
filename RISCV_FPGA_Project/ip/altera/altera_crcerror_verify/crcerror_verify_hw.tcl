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





package require -exact sopc 11.0

set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/alt_mem_if/alt_mem_if_tcl_packages"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
    lappend auto_path $alt_mem_if_tcl_libs_dir
}

package require alt_mem_if::util::messaging
package require alt_mem_if::util::iptclgen
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*

set_module_property NAME altera_crcerror_verify
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property HIDE_FROM_SOPC true
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Altera CRCERROR Verify"
set_module_property DESCRIPTION "Altera CRC error verification module for Stratix IV and Arria II"
set_module_property DATASHEET_URL ""


set_module_property ANALYZE_HDL false
set_module_property EDITABLE true

set_module_property SIMULATION_MODEL_IN_VERILOG true  

set_module_property STATIC_TOP_LEVEL_MODULE_NAME altera_crcerror_verify_top


set_module_property ELABORATION_CALLBACK elaboration_callback

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
add_fileset quartus_synth QUARTUS_SYNTH generate_synth

add_parameter device_family STRING
set_parameter_property device_family ALLOWED_RANGES {"Stratix IV" "Arria II GZ" "Arria II GX"}
set_parameter_property device_family VISIBLE false
set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property device_family HDL_PARAMETER true
set_parameter_property device_family AFFECTS_GENERATION true

add_parameter in_clk_frequency int
set_parameter_property in_clk_frequency DEFAULT_VALUE 50
set_parameter_property in_clk_frequency ALLOWED_RANGES {10:50}
set_parameter_property in_clk_frequency DISPLAY_NAME "Input clock frequency"
set_parameter_property in_clk_frequency UNITS Megahertz
set_parameter_property in_clk_frequency AFFECTS_GENERATION true
set_parameter_property in_clk_frequency HDL_PARAMETER true
set_parameter_property in_clk_frequency DESCRIPTION "Specifies the frequency of CRC Error Verification block input clock, must be withing 10-50 MHz range."

add_parameter error_check_frequency_divisor int
set_parameter_property error_check_frequency_divisor DEFAULT_VALUE 2
set_parameter_property error_check_frequency_divisor ALLOWED_RANGES {1 2 4 8 16 32 64 128 256}
set_parameter_property error_check_frequency_divisor DISPLAY_NAME "CRC error check clock divisor"
set_parameter_property error_check_frequency_divisor UNITS None
set_parameter_property error_check_frequency_divisor AFFECTS_GENERATION true
set_parameter_property error_check_frequency_divisor HDL_PARAMETER true
set_parameter_property error_check_frequency_divisor DESCRIPTION "Specifies the the divide value of the internal clock, which determines the frequency of the CRC. Should match the Quartus II CRC settings."

add_display_item "" "Options" GROUP 
add_display_item "Options" add_core_interface PARAMETER
add_display_item "Options" change_pin_assignment PARAMETER
add_display_item "Options" crc_error_pin_name PARAMETER
add_display_item "Options" crc_error_pin_location PARAMETER

add_parameter add_core_interface boolean false
set_parameter_property add_core_interface DISPLAY_NAME "Make core interface available"
set_parameter_property add_core_interface AFFECTS_GENERATION true
set_parameter_property add_core_interface AFFECTS_ELABORATION true
set_parameter_property add_core_interface DESCRIPTION "Provides CRC Error Verification block interface simular to the crcerror block core interface."

add_parameter change_pin_assignment boolean true
set_parameter_property change_pin_assignment DISPLAY_NAME "Generate CRC_ERROR pin assignment script"
set_parameter_property error_check_frequency_divisor AFFECTS_GENERATION true
set_parameter_property change_pin_assignment DESCRIPTION "Generates manually run script to replace original CRCERROR pin connection with EDCRC Error Verification block crc_error pin."

add_parameter crc_error_pin_name STRING ""
set_parameter_property crc_error_pin_name DISPLAY_NAME "Top level crc_error signal pin name"
set_parameter_property crc_error_pin_name UNITS None
set_parameter_property crc_error_pin_name AFFECTS_GENERATION true
set_parameter_property crc_error_pin_name DESCRIPTION "Specify here the name of top level pin that will be connected to crc_error signal, for example crc_error_final."

add_parameter crc_error_pin_location STRING ""
set_parameter_property crc_error_pin_location DISPLAY_NAME "CRC_ERROR pin location"
set_parameter_property crc_error_pin_location UNITS None
set_parameter_property crc_error_pin_location AFFECTS_GENERATION true
set_parameter_property crc_error_pin_location DESCRIPTION "Specify here the original CRCERROR pin location to be used for script generation, for example N24."

proc elaboration_callback {} {

    set supported_families [list "Stratix IV" "Arria II GZ" "Arria II GX"]
	set current_family [get_parameter_value device_family]
	if {[lsearch $supported_families $current_family] == -1} {
		send_message error "The selected device family is not supported. Please select $supported_families."
	}

	set enable_core_interface [get_parameter_value add_core_interface]	

	if { $enable_core_interface } {
		set is_core_interface_added true

		add_interface crcerror_core conduit end
		add_interface_port crcerror_core clk_core clk input 1
		add_interface_port crcerror_core shiftnld_core shiftnld input 1
		add_interface_port crcerror_core crcerror_core crcerror output 1
		add_interface_port crcerror_core regout_core regout output 1
		set_interface_assignment crcerror_core "ui.blockdiagram.direction" OUTPUT
	}

	set generate_script [get_parameter_value change_pin_assignment]	
	set_parameter_property crc_error_pin_location VISIBLE $generate_script
	set_parameter_property crc_error_pin_name VISIBLE $generate_script
}

proc generate_synth {name} {

	send_message info "Preparing to generate synthesis fileset for $name"

	set ifdef_params_list [list]
	if {[string compare -nocase [get_parameter_value add_core_interface] "true"] == 0} {
		lappend ifdef_params_list "CORE_INTERFACE"
	}
	
	generate_verilog_fileset $name $ifdef_params_list

	set qdir $::env(QUARTUS_ROOTDIR)
	set tmp_dir [create_temp_file {}]		
	set src_dir "${qdir}/../ip/altera/altera_crcerror_verify"
		
	set file_list "crcerror_verify_constraints.sdc"
	foreach sdc_file [alt_mem_if::util::iptclgen::parse_tcl_params $name $src_dir $tmp_dir [list $file_list] $ifdef_params_list] {
		set file_name [file tail $sdc_file]
		send_message info "Adding $file_name"
		add_fileset_file $file_name SDC PATH $sdc_file
	}
	
	if {[string compare -nocase [get_parameter_value change_pin_assignment] "true"] == 0} {
		set gen_file_name [generate_drive_strengths_assignment $name $src_dir $tmp_dir ]
		add_fileset_file [file tail $gen_file_name] OTHER PATH $gen_file_name

		foreach tcl_file [generate_pin_assignment_script $name $src_dir $tmp_dir ] {
			set file_name [ string map "crcerror_verify $name" [file tail $tcl_file] ]
			send_message info "Adding $file_name"
			add_fileset_file $file_name OTHER PATH $tcl_file
		}	

		print_generation_done_message $name		
	}
}

proc generate_verilog_sim {name} {

	send_message info "Preparing to generate simulation fileset for $name"

	set ifdef_params_list [list]
	if {[string compare -nocase [get_parameter_value add_core_interface] "true"] == 0} {
		lappend ifdef_params_list "CORE_INTERFACE"
	}
	
	lappend ifdef_params_list "SIMULATION"
	
	generate_verilog_fileset $name $ifdef_params_list
}

proc generate_verilog_fileset {name ifdef_params} {

	set ifdef_source_list [list \
		altera_crcerror_verify_top.v \
		crcerror_verify_core.v \
	]

	foreach file_name $ifdef_source_list {
		set generated_file [alt_mem_if::util::iptclgen::generate_outfile_name $file_name $ifdef_params]
		send_message info "Adding $generated_file as $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $generated_file
	}

	set source_list [list \
		crcerror_read_emr.v \
		crcerror_verify_define.iv \
	]

	foreach file_name $source_list {
		send_message info "Adding $file_name"
		add_fileset_file $file_name [::alt_mem_if::util::hwtcl_utils::get_file_type $file_name] PATH $file_name
	}	
}

proc generate_drive_strengths_assignment {core_name src_dir dest_dir} {

	set dest_file_name [file join $dest_dir "${core_name}_drive_strengths.xml"]
	
	set top_crcerror_pin_name [get_parameter_value crc_error_pin_name]	

	file copy [file join $src_dir "crcerror_drive_strengths.xml.dat"] $dest_file_name
	alt_mem_if::util::iptclgen::sub_strings_params  $dest_file_name $dest_file_name \
				[list TOP_CRCERROR_PIN $top_crcerror_pin_name]

	return $dest_file_name
}

proc generate_pin_assignment_script {core_name src_dir dest_dir} {

	send_message info "Generating ${core_name}_pin_assignments.tcl"

	set file_list "crcerror_verify_pin_assignments.tcl"

	set ifdef_params_list [ list "IPTCL_FAKE" ]

	set top_crcerror_pin_name [get_parameter_value crc_error_pin_name]	
	set crcerror_pin_location [get_parameter_value crc_error_pin_location]	
	set keys_params_list [list TOP_CRCERROR_PIN $top_crcerror_pin_name \
						  CRCERROR_PIN_LOCATION "PIN_${crcerror_pin_location}"]
	
	set script_file_list [alt_mem_if::util::iptclgen::parse_tcl_params $core_name $src_dir $dest_dir [list $file_list] $ifdef_params_list]
	
	foreach sfile $script_file_list {
		alt_mem_if::util::iptclgen::sub_strings_params $sfile $sfile $keys_params_list
	}
	
	return $script_file_list
}


proc print_generation_done_message { outputname } {
		send_message "info" ""
		send_message "info" "CRCERROR Verify Component Generation is Complete"
		send_message "info" "*****************************"
		send_message "info" ""
		send_message "info" "Remember to run the ${outputname}_pin_assignments.tcl"
		send_message "info" "script before project compilation"
		send_message "info" ""
		send_message "info" "*****************************"
		send_message "info" ""
}



add_interface err_verify_in_clk clock sink
add_interface_port err_verify_in_clk err_verify_in_clk clk input 1

add_interface reset reset sink err_verify_in_clk
add_interface_port reset reset reset input 1

add_interface crc_error conduit end err_verify_in_clk
add_interface_port crc_error crc_error crc_error output 1
set_interface_assignment crc_error "ui.blockdiagram.direction" OUTPUT




