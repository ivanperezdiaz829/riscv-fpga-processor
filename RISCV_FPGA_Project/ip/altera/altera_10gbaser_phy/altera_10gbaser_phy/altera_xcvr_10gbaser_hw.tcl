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


# +-----------------------------------
# | 
# | TCL component for 10GBASE-R PHY, including reconfig
# | $Header: //acds/rel/13.1/ip/altera_10gbaser_phy/altera_10gbaser_phy/altera_xcvr_10gbaser_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 13.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------
# Use alt_xcvr TCL packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::params_and_ports
package require alt_xcvr::utils::fileset

namespace import ::alt_xcvr::utils::params_and_ports::*
namespace import ::alt_xcvr::utils::fileset::*

set_module_property ALLOW_GREYBOX_GENERATION true 

set_module_property DESCRIPTION "10GBASE-R PHY"
set_module_property NAME altera_xcvr_10gbaser
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property DISPLAY_NAME "10GBASE-R PHY"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK validation_callback
set_module_property AUTHOR "Altera Corporation"

# | 
# +-----------------------------------
source ../../altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl	;# function to declare csr soft logic files
source ../../altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl	;# function to decl S5 native channel files
source ../../altera_xcvr_generic/av/av_xcvr_native_fileset.tcl	;# function to decl A5 native channel files
source ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xreconf_common.tcl	;# function to declare reconf block files
source ./altera_xcvr_10gbaser_common.tcl

# +-----------------------------------
# | files
# | 

decl_fileset_groups ..

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhdl
add_fileset synth2 QUARTUS_SYNTH fileset_quartus_synth

set_fileset_property synth2 TOP_LEVEL altera_xcvr_10gbaser
set_fileset_property simulation_verilog TOP_LEVEL altera_xcvr_10gbaser
set_fileset_property simulation_vhdl TOP_LEVEL altera_xcvr_10gbaser


# | 
# +-----------------------------------

# +-----------------------------------
# | tabs
# |
add_display_item "" "General Options" GROUP tab
add_display_item "" "Analog Options" GROUP tab
add_display_item "Analog Options" sv_message_text TEXT "These options are only available for family Stratix IV."
add_display_item "" "Additional Options" GROUP tab

# +-----------------------------------
# | parameters
# | 
common_add_parameters_for_common_gui
source ../../alt_interlaken/alt_interlaken_pcs/parameter_manager.tcl
add_pma_parameters_raw
set_parameter_property tx_vod_selection DEFAULT_VALUE 7
set_parameter_property rx_eq_ctrl DEFAULT_VALUE 0
set_parameter_property tx_preemp_tap_1 DEFAULT_VALUE 15

add_extra_parameters_for_top_phy
# | 
# +-----------------------------------

# +-----------------------------------
# | define interfaces and ports
# | 
proc elaboration_callback { } {
	# declare ports and mappings for elaboration callback
	common_clock_interfaces

	#set common interface ports, terminate unnecessary ports
	common_10gbaser_phy_interface_ports  

	# add memory-mapped slave interface, with 9-bit wide word address, readLatency of 0 (uses waitrequest)
	common_mgmt_interface 9 0
}
# | 
# +-----------------------------------

# +-----------------------------------
# | validate parameters
# | 
proc validation_callback {} {
	set device_family [get_parameter_value device_family]
	common_parameter_validation
  validate_reconfiguration_parameters $device_family;
  validate_pll_type $device_family

}
# | 
# +-----------------------------------



