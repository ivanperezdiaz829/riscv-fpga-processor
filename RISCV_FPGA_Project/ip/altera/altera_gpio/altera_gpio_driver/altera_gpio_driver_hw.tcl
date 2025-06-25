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


# Required header to put the alt_mem_if TCL packages on the TCL path
set alt_mem_if_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/emif/util"
if {[lsearch -exact $auto_path $alt_mem_if_tcl_libs_dir] == -1} {
   lappend auto_path $alt_mem_if_tcl_libs_dir
}

set altera_gpio_tcl_libs_dir "$env(QUARTUS_ROOTDIR)/../ip/altera/altera_gpio/altera_gpio_common"
if {[lsearch -exact $auto_path $altera_gpio_tcl_libs_dir] == -1} {
   lappend auto_path $altera_gpio_tcl_libs_dir
}

# +-----------------------------------
# | request TCL package from ACDS 13.0
# | 
package require -exact qsys 13.0
package require altera_gpio::common
# | 
# +-----------------------------------

# +-----------------------------------
# | module driver
# | 
set_module_property DESCRIPTION "Altera Gpio Driver"
set_module_property NAME altera_gpio_driver
set_module_property VERSION 13.1
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "Altera Gpio Driver"
set_module_property GROUP "I/O"
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property HIDE_FROM_QSYS true
set_module_property HIDE_FROM_SOPC true
set_module_property INTERNAL true
# | 
# +-----------------------------------


# +-----------------------------------
# | Parameters
# | 
add_parameter USE_INVERT STRING "false"
set_parameter_property USE_INVERT DEFAULT_VALUE "false"
set_parameter_property USE_INVERT ALLOWED_RANGES {"false" "true"}
set_parameter_property USE_INVERT AFFECTS_GENERATION true
set_parameter_property USE_INVERT HDL_PARAMETER true
set_parameter_property USE_INVERT VISIBLE false

add_parameter USE_GND_VCC STRING "false"
set_parameter_property USE_GND_VCC DEFAULT_VALUE "false"
set_parameter_property USE_GND_VCC ALLOWED_RANGES {"false" "true"}
set_parameter_property USE_GND_VCC AFFECTS_GENERATION true
set_parameter_property USE_GND_VCC HDL_PARAMETER true
set_parameter_property USE_GND_VCC VISIBLE false

add_parameter BUS_WIDTH INTEGER 4
set_parameter_property BUS_WIDTH DEFAULT_VALUE 4
set_parameter_property BUS_WIDTH AFFECTS_GENERATION true
set_parameter_property BUS_WIDTH DESCRIPTION "Specifies the driver bus width"
set_parameter_property BUS_WIDTH HDL_PARAMETER true

add_parameter INVERSION_BUS INTEGER 4
set_parameter_property INVERSION_BUS DEFAULT_VALUE 0
set_parameter_property INVERSION_BUS AFFECTS_GENERATION true
set_parameter_property INVERSION_BUS HDL_PARAMETER true
	
add_parameter GND_VCC_BUS INTEGER 4
set_parameter_property GND_VCC_BUS DEFAULT_VALUE 0
set_parameter_property GND_VCC_BUS AFFECTS_GENERATION true
set_parameter_property GND_VCC_BUS HDL_PARAMETER true

::altera_gpio::common::add_gpio_parameters "true" "false"
# | 
# +-----------------------------------

# +-----------------------------------
# | IP elaborate and validate callback declarations
# | 
set_module_property ELABORATION_CALLBACK ip_elaborate
set_module_property VALIDATION_CALLBACK ip_validate
# | 
# +-----------------------------------

# +-----------------------------------
# | Filesets
# | 
add_fileset sim_verilog SIM_VERILOG generate_sim_verilog
set_fileset_property sim_verilog TOP_LEVEL altera_gpio_driver

add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL altera_gpio_driver

# | 
# +-----------------------------------

# +-----------------------------------
# | Interfaces
# | 
proc ip_elaborate {} {
	::altera_gpio::common::elaborate "true"
}

proc ip_validate {} {
    ::altera_gpio::common::validate
}

proc generate_vhdl_sim {top_level} {
	::altera_gpio::common::generate_vhdl_sim [list altera_gpio_driver.sv submodules/driver.sv submodules/ext_device.sv]
}

proc generate_sim_verilog { name } {
	set enable_reset_test [get_parameter_value _HIDDEN_ENABLE_RESET_TEST]
	if {[altera_gpio::common::safe_string_compare $enable_reset_test true]} {
		# INTERNAL USE ONLY: Reset verification file-set
		add_fileset_file driver_reset.sv SYSTEM_VERILOG PATH submodules/driver_reset.sv
		add_fileset_file altera_gpio_driver_reset.sv SYSTEM_VERILOG PATH altera_gpio_driver_reset.sv
	} else {
		# Standard driver file-set
		add_fileset_file driver.sv SYSTEM_VERILOG PATH submodules/driver.sv
		add_fileset_file ext_device.sv SYSTEM_VERILOG PATH submodules/ext_device.sv
		add_fileset_file altera_gpio_driver.sv SYSTEM_VERILOG PATH altera_gpio_driver.sv
	}
}
