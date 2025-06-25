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
# | TCL component for CPRI PHY, including reconfig
# | $Header: //acds/rel/13.1/ip/altera_xcvr_det_latency/soft_pcs/altera_xcvr_dl_soft_pcs_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 13.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

##
# Use alt_xcvr TCL packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
package require alt_xcvr::gui::pll_reconfig
package require alt_xcvr::gui::messages
package require alt_xcvr::utils::params_and_ports
package require alt_xcvr::utils::fileset
package require altera_xcvr_reset_control::fileset

namespace import ::alt_xcvr::utils::params_and_ports::*
namespace import ::alt_xcvr::utils::fileset::*

# +-----------------------------------
# | source tcl files
# |
source ../../altera_xcvr_generic/tgx/alt_xcvr_s4_analog.tcl
source ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xreconf_common.tcl
source altera_xcvr_dl_soft_pcs_common.tcl
source altera_xcvr_dl_soft_pcs_parameters.tcl	;# parameter definitions and validation
source altera_xcvr_dl_soft_pcs_val_params.tcl	;# parameter definitions and validation
source altera_xcvr_dl_soft_pcs_ports.tcl		    ;# port and interface functions
# |
# +---------------------------------------------

set_module_property ALLOW_GREYBOX_GENERATION true

#set_module_property NAME altera_xcvr_det_latency
set_module_property NAME altera_xcvr_dl_soft_pcs
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME "Deterministic Latency Soft PCS PHY"
set_module_property EDITABLE true
set_module_property GROUP "Interface Protocols/Transceiver PHY"
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Deterministic Latency PHY IP with soft PCS"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"
set_module_property ANALYZE_HDL false

set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate


# |
# +---------------------------------------------

# +---------------------------------------------
# | add display tabs
# |
add_display_item "" "General" GROUP tab
add_display_item "" "Additional Options" GROUP tab
add_display_item "" "Reconfiguration" GROUP tab
add_display_item "Reconfiguration" "PLL Reconfiguration" GROUP 
add_display_item "Reconfiguration" "Channel Interface" GROUP 
# |
# |
# +-----------------------------------------------

# +---------------------------------------------
# | Custom PHY parameters
# | 

detlat_add_device_parameters	;# device info parameters
detlat_add_common_parameters	;# add all the common parameters
add_pll_reconfig_parameters "PLL Reconfiguration"
add_mgmt_parameters		;# get clock frequencies from Qsys

# +-----------------------------------
# | Custom PHY ports
# | 

custom_mgmt_interface	;# declare phy_mgmt clock, reset, AvMM interface, and reset controller status streams
detlat_static_native_ports	;# declare exposed clocks, data, control, and status


# +-----------------------------------
# | Validation
# | 
proc validate {} {
	detlat_validate_common_parameters	;# parameter validation common to all levels
	validate_mgmt				;# clock freq parameter assignment
	detlat_validate_wa_parameters 1	;# parameter validation with optional ena/disabling of some controls
	detlat_validate_optional_parameters 1	;# parameter validation with optional ena/disabling of some controls
#	detlat_validate_pll_feedback_path
}

# +-----------------------------------
# | Elaboration
# | 
proc elaborate {} {
	set split [get_parameter_value gui_split_interfaces]
	detlat_set_port_termination	;# sets port termination for all static ports, and sets tag state for dynamic ports
	detlat_dynamic_native_ports $split
  detlat_dynamic_reconfig_ports [get_parameter_value device_family]
}

######################################
# +-----------------------------------
# | Fileset callback functions
# +-----------------------------------
######################################

#
# declare all files, with appropriate implementation and tool-flow tags
#
detlat_decl_fileset_groups .. ../../alt_xcvr_reconfig
	
add_fileset synth2 QUARTUS_SYNTH fileset_quartus_synth
add_fileset sim_verilog SIM_VERILOG fileset_sim_verilog
add_fileset sim_vhdl SIM_VHDL fileset_sim_vhdl

set_fileset_property synth2 TOP_LEVEL altera_xcvr_detlatency_top_phy
set_fileset_property sim_verilog TOP_LEVEL altera_xcvr_detlatency_top_phy
set_fileset_property sim_vhdl TOP_LEVEL altera_xcvr_detlatency_top_phy


# +-----------------------------------
# | Synthesis fileset callback
# | 
proc fileset_quartus_synth {name} {
	custom_add_fileset_for_tool {PLAIN QIP}
}

# +-----------------------------------
# | Verilog simulation fileset callback
# | 
proc fileset_sim_verilog {name} {
	custom_add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]
}

# +-----------------------------------
# | VHDL simulation fileset callback
# | 
proc fileset_sim_vhdl {name} {
	custom_add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]
}
