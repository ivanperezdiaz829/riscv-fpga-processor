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
package require alt_mem_if::util::hwtcl_utils

namespace import ::alt_mem_if::util::messaging::*


set_module_property DESCRIPTION "UniPHY HCx ROM Reconfig Generator"
set_module_property NAME altera_mem_if_hcx_rom_reconfig_gen
set_module_property VERSION 13.1
::alt_mem_if::util::hwtcl_utils::set_module_internal_mode
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME "HCx ROM Reconfig Generator"
set_module_property GROUP [::alt_mem_if::util::hwtcl_utils::example_design_components_group_name]
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE


add_parameter INIT_FILE string ""
set_parameter_property INIT_FILE DISPLAY_NAME "Initialization file"
set_parameter_property INIT_FILE HDL_PARAMETER true

add_parameter ROM_ADDRESS_WIDTH integer 13
set_parameter_property ROM_ADDRESS_WIDTH DISPLAY_NAME "Address width of rom"
set_parameter_property ROM_ADDRESS_WIDTH HDL_PARAMETER true




add_fileset sim_vhdl SIM_VHDL generate_vhdl_sim
set_fileset_property sim_vhdl TOP_LEVEL hc_rom_reconfig_gen

add_fileset sim_verilog SIM_VERILOG generate_verilog_sim
set_fileset_property sim_verilog TOP_LEVEL hc_rom_reconfig_gen

add_fileset synth QUARTUS_SYNTH generate_synth
set_fileset_property synth TOP_LEVEL hc_rom_reconfig_gen

proc generate_vhdl_sim {name} {

	add_fileset_file hc_rom_reconfig_gen.sv SYSTEM_VERILOG PATH hc_rom_reconfig_gen.sv [::alt_mem_if::util::hwtcl_utils::get_simulator_attributes 1]

	add_fileset_file [file join mentor hc_rom_reconfig_gen.sv] SYSTEM_VERILOG_ENCRYPT PATH [file join mentor hc_rom_reconfig_gen.sv] {MENTOR_SPECIFIC}
}

proc generate_verilog_sim {name} {
	add_fileset_file hc_rom_reconfig_gen.sv SYSTEM_VERILOG PATH hc_rom_reconfig_gen.sv
}

proc generate_synth {name} {
	_error "Quartus SYNTH fileset is not supported for alt_mem_if_hcx_rom_reconfig_gen"
}



set_module_property elaboration_Callback ip_elaborate

proc ip_elaborate {} {

	add_interface hcx_rom_reconfig conduit end

	set_interface_property hcx_rom_reconfig ENABLED true

	add_interface_port hcx_rom_reconfig hc_rom_config_clock hc_rom_config_clock Output 1
	add_interface_port hcx_rom_reconfig hc_rom_config_datain hc_rom_config_datain Output 32
	add_interface_port hcx_rom_reconfig hc_rom_config_rom_data_ready hc_rom_config_rom_data_ready Output 1
	add_interface_port hcx_rom_reconfig hc_rom_config_init hc_rom_config_init Output 1
	add_interface_port hcx_rom_reconfig hc_rom_config_init_busy hc_rom_config_init_busy Input 1
	add_interface_port hcx_rom_reconfig hc_rom_config_rom_rden hc_rom_config_rom_rden Input 1
	add_interface_port hcx_rom_reconfig hc_rom_config_rom_address hc_rom_config_rom_address Input [get_parameter_value ROM_ADDRESS_WIDTH]


	add_interface soft_reset reset source
	set_interface_property soft_reset synchronousEdges NONE

	set_interface_property soft_reset ENABLED true

	add_interface_port soft_reset soft_reset_n reset_n Output 1
}