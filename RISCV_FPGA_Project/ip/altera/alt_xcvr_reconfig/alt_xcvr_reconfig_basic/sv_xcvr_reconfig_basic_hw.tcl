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


# Native interface definition for sv_xcvr_reconfig_basic
#
# $Header: //acds/rel/13.1/ip/alt_xcvr_reconfig/alt_xcvr_reconfig_basic/sv_xcvr_reconfig_basic_hw.tcl#1 $

# +-----------------------------------
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

# +-------------------------------------
# | External functions for common blocks
# | 
source ../../altera_xcvr_generic/alt_xcvr_common.tcl
source alt_xrbasic_common.tcl

# +-----------------------------------
# | module pcie
# | 
set_module_property NAME sv_xcvr_reconfig_basic
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME "Stratix V Transceiver Reconfiguration Basic Interface Block"
set_module_property GROUP "Interface Protocols/Transceiver PHY"
set_module_property AUTHOR "Altera Corporation"
set_module_property ANALYZE_HDL false

#set_module_property VALIDATION_CALLBACK validate
#set_module_property ELABORATION_CALLBACK elaborate


# +-----------------------------------
# | native PHY parameters
# | 
proc add_parameters_for_native_phy { } {
	add_parameter basic_ifs INTEGER
	set_parameter_property basic_ifs DEFAULT_VALUE 1
	set_parameter_property basic_ifs DISPLAY_NAME "Number of basic reconfiguration interfaces"
	#set_parameter_property basic_ifs ALLOWED_RANGES {1}
	set_parameter_property basic_ifs HDL_PARAMETER true
	set_parameter_property basic_ifs ENABLED false

	add_parameter native_ifs INTEGER
	set_parameter_property native_ifs DEFAULT_VALUE 1
	set_parameter_property native_ifs DISPLAY_NAME "Number of native reconfig interfaces"
	#set_parameter_property native_ifs ALLOWED_RANGES {1:32}
	set_parameter_property native_ifs HDL_PARAMETER true

	add_parameter w_bundle_to_gxb INTEGER
	set_parameter_property w_bundle_to_gxb DEFAULT_VALUE 49
	set_parameter_property w_bundle_to_gxb DISPLAY_NAME "Bundle width on combined native reconfig sinks"
	set_parameter_property w_bundle_to_gxb ALLOWED_RANGES {49}	;# SV value is 49
	set_parameter_property w_bundle_to_gxb HDL_PARAMETER true
	set_parameter_property w_bundle_to_gxb VISIBLE false

	add_parameter w_bundle_from_gxb INTEGER
	set_parameter_property w_bundle_from_gxb DEFAULT_VALUE 40
	set_parameter_property w_bundle_from_gxb DISPLAY_NAME "Bundle width on combined native reconfig sources"
	set_parameter_property w_bundle_from_gxb ALLOWED_RANGES {40}	;# SV value is 40
	set_parameter_property w_bundle_from_gxb HDL_PARAMETER true
	set_parameter_property w_bundle_from_gxb VISIBLE false

	#add_parameter physical_channel_mapping STRING
	#set_parameter_property physical_channel_mapping DISPLAY_NAME "Logical channel to physical interface/channel mapping"
	#set_parameter_property physical_channel_mapping ALLOWED_RANGES {"one" "two" 3 4}
	#set_parameter_property physical_channel_mapping HDL_PARAMETER true
}


# +-----------------------------------
# | native PHY ports
# | 
proc interface_ports_and_mapping_for_native_phy { } {

	# clock and reset inputs
	xrbasic_add_clock reconfig_clk input
	xrbasic_add_reset reset input

	# Logical-side I/O:
	xrbasic_add_tagged_conduit_bus basic_reconfig_write input "basic_ifs" Basic
	xrbasic_add_tagged_conduit_bus basic_reconfig_read input "basic_ifs" Basic
	xrbasic_add_tagged_conduit_bus basic_reconfig_writedata input "basic_ifs*32" Basic
	xrbasic_add_tagged_conduit_bus basic_reconfig_address input "basic_ifs*3" Basic
	xrbasic_add_tagged_conduit_bus basic_reconfig_readdata output "basic_ifs*32" Basic
	xrbasic_add_tagged_conduit_bus basic_reconfig_waitrequest output "basic_ifs" Basic
	xrbasic_add_tagged_conduit_bus lch_testbus output "basic_ifs*8" Basic

	# Physical-side I/O:
	xrbasic_add_tagged_conduit_bus reconfig_to_gxb   output "native_ifs*w_bundle_to_gxb" Native
	xrbasic_add_tagged_conduit_bus reconfig_from_gxb input  "native_ifs*w_bundle_from_gxb" Native
}

# +-----------------------------------
# | add parameters & static ports
# | 
add_parameters_for_native_phy
interface_ports_and_mapping_for_native_phy

######################################
# +-----------------------------------
# | Fileset callback functions
# +-----------------------------------
######################################

#
# declare all files, with appropriate implementation and tool-flow tags
#
xrbasic_decl_fileset_groups ..
	
add_fileset synth2 QUARTUS_SYNTH fileset_quartus_synth
add_fileset sim_verilog SIM_VERILOG fileset_sim_verilog
add_fileset sim_vhdl SIM_VHDL fileset_sim_vhdl

set_fileset_property synth2 TOP_LEVEL sv_xcvr_reconfig_basic
set_fileset_property sim_verilog TOP_LEVEL sv_xcvr_reconfig_basic
set_fileset_property sim_vhdl TOP_LEVEL sv_xcvr_reconfig_basic


# +-----------------------------------
# | Synthesis fileset callback
# | 
proc fileset_quartus_synth {name} {
	common_add_fileset_files {ALL_HDL S5} {PLAIN QIP}
}

# +-----------------------------------
# | Verilog simulation fileset callback
# | 
proc fileset_sim_verilog {name} {
	common_add_fileset_files {ALL_HDL S5} [concat PLAIN [common_fileset_tags_all_simulators] ]
}

# +-----------------------------------
# | VHDL simulation fileset callback
# | 
proc fileset_sim_vhdl {name} {
	common_add_fileset_files {ALL_HDL S5} [concat PLAIN [common_fileset_tags_all_simulators] ]
}
