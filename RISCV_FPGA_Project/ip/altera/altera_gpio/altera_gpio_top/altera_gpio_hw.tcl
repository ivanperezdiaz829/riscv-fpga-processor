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


set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/emif/util"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
   lappend auto_path $alt_mem_if_tcl_libs_dir
}

set altera_gpio_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/altera_gpio/altera_gpio_common"
if {[lsearch -exact $auto_path $altera_gpio_tcl_libs_dir] == -1} {
   lappend auto_path $altera_gpio_tcl_libs_dir
}

package require -exact qsys 13.0
package require altera_gpio::common

set_module_property DESCRIPTION "Altera Gpio"
set_module_property NAME altera_gpio
set_module_property VERSION 13.1
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "Altera Gpio"
set_module_property GROUP "I/O"
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_QSYS true
set_module_property HIDE_FROM_SOPC true

set_module_property COMPOSITION_CALLBACK composition_callback

add_fileset example_design EXAMPLE_DESIGN generate_example_design

add_display_item "" "General" GROUP
add_display_item "" "Buffer" GROUP
add_display_item "" "Registers" GROUP

add_parameter device_family STRING "ArriaVI"
set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
set_parameter_property device_family VISIBLE false

::altera_gpio::common::add_gpio_parameters "false" "true"

proc ip_validate {} {
    ::altera_gpio::common::validate
}

proc ip_compose {} {
	set core_component "altera_gpio_core"
	set core_name "core"

	add_instance $core_name $core_component

	foreach param_name [get_parameters] {
		set is_derived_param [get_parameter_property $param_name DERIVED]
		set param_val [get_parameter_value $param_name]
		if {$param_name != "device_family" && $is_derived_param != "1"} {
			set_instance_parameter_value $core_name $param_name $param_val
		}
	}

	foreach interface_name [get_instance_interfaces $core_name] {
		add_interface ${core_name}_${interface_name} conduit end
		set_interface_property ${core_name}_${interface_name} EXPORT_OF ${core_name}.${interface_name}
	}

	return 1
}

proc composition_callback { } {
	ip_validate
	ip_compose
}

proc generate_example_design { name } {
	
	set default_device "10AX115R3F40I3SGES"
	
	set synth_qsys_name "ed_synth"
	set synth_qsys_file "${synth_qsys_name}.qsys"
	set synth_qsys_path [create_temp_file $synth_qsys_file]
	set fh [open $synth_qsys_path "w"] 
	close $fh 
	
	set sim_qsys_name   "ed_sim"
	set sim_qsys_file   "${sim_qsys_name}.qsys"
	set sim_qsys_path   [create_temp_file $sim_qsys_file]
	set fh [open $sim_qsys_path "w"] 
	close $fh 
    


	set params_file "params.tcl"
	set params_path [create_temp_file $params_file]
	set fh [open $params_path "w"]    

	puts $fh "# This file is auto-generated."
	puts $fh "# It is used by make_qii_design.tcl and make_sim_design.tcl, and"
	puts $fh "# is not intended to be executed directly."
	puts $fh ""

	foreach param_name [get_parameters] {
		set is_derived_param [get_parameter_property $param_name DERIVED]
		set param_val [get_parameter_value $param_name]
		if {$param_name != "device_family" && $is_derived_param != "1"} {
			puts $fh "set ip_params(${param_name}) \"${param_val}\""
		}
	}

	puts $fh "set device_family \"[get_parameter_value device_family]\""
	puts $fh "set gpio_name           \"$name\""
	puts $fh "set ed_params(DEFAULT_DEVICE)      \"$default_device\""
	puts $fh "set ed_params(SYNTH_QSYS_NAME)     \"$synth_qsys_name\""
	puts $fh "set ed_params(SIM_QSYS_NAME)       \"$sim_qsys_name\""
	puts $fh "set ed_params(TMP_SYNTH_QSYS_PATH) \"$synth_qsys_path\""
	puts $fh "set ed_params(TMP_SIM_QSYS_PATH)   \"$sim_qsys_path\""
	close $fh

	add_fileset_file $params_file OTHER PATH $params_path
	
	set make_qsys_file "make_qsys.tcl"

	set cmd [concat [list exec qsys-script --cmd='source $params_path' --script=./ex_design/$make_qsys_file]]
	set cmd_fail [catch { eval $cmd } tempresult]
	add_fileset_file $synth_qsys_file OTHER PATH $synth_qsys_path
	add_fileset_file $sim_qsys_file OTHER PATH $sim_qsys_path
	
	set file "make_qii_design.tcl"
	set path "ex_design/${file}"
	add_fileset_file $file OTHER PATH $path

	set file "make_sim_design.tcl"
	set path "ex_design/${file}"
	add_fileset_file $file OTHER PATH $path

	set file "readme.txt"
	set path "ex_design/${file}"
	add_fileset_file $file OTHER PATH $path
	
	
	

		  
			 
	
}

