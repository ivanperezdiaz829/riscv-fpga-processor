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
# | TCL component declarations
# | $Header: //acds/rel/13.1/ip/altera_xcvr_att_custom/sv/sv_xcvr_att_custom_hw.tcl#1 $
# | 
# +-----------------------------------

# Native interface definition for Stratix V altera_xcvr_custom_phy
#

# +-----------------------------------
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------


# +-----------------------------------
# | source tcl files
# |
source ../../altera_xcvr_generic/alt_xcvr_common.tcl
source ../../altera_xcvr_generic/altera_xcvr_pll_calc.tcl
source ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xreconf_common.tcl
source ../xcvr_generic/xcvr_custom_phy_hw_common.tcl
source ../xcvr_generic/xcvr_custom_phy_parameters.tcl	;# parameter definitions
source ../xcvr_generic/xcvr_custom_phy_val_params.tcl	;# parameter validation
source ../xcvr_generic/xcvr_custom_phy_ports.tcl		;# port and interface functions


# +-----------------------------------
# | module sv_xcvr_att_custom
# | 
set_module_property NAME sv_xcvr_att_custom
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME "Stratix V Custom Native PHY"
set_module_property GROUP "Interfaces/Transceiver PHY"
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Standard Transceiver PCS Stratix V Custom Native PHY IP"
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
add_display_item "General" "Options" GROUP
add_display_item "General" "Additional Options" GROUP
add_display_item "" "8B/10B" GROUP tab
add_display_item "" "Word Aligner" GROUP tab
add_display_item "" "Rate Match" GROUP tab
add_display_item "" "Byte Order" GROUP tab
add_display_item "" "Datapath" GROUP tab
#add_display_item "" "Reconfiguration" GROUP tab
#add_display_item "Reconfiguration" "PLL Reconfiguration" GROUP
# |
# |
# +-----------------------------------------------


# +---------------------------------------------
# | Stratix V Custom Native PHY parameters
# | 

add_common_parameters	;# add all the common parameters


# +-----------------------------------
# | Stratix V Custom Native PHY ports
# | 

custom_static_native_ports	;# declare exposed clocks, data, control, and status


# +-----------------------------------
# | Validation
# | 
proc validate {} {
	validate_common_parameters	;# parameter validation common to all levels
	validate_wa_parameters 0	;# parameter validation with optional ena/disabling of some controls
  validate_reconfiguration_parameters [get_s5_name]
	validate_optional_parameters 0	;# parameter validation with optional ena/disabling of some controls
	validate_s5_constraints
}

# +-----------------------------------
# | Elaboration
# | 
proc elaborate {} {
	custom_set_port_termination	;# sets port termination for all static ports, and sets tag state for dynamic ports
	custom_dynamic_native_ports
  custom_dynamic_reconfig_ports [get_s5_name]
}

######################################
# +-----------------------------------
# | Fileset callback functions
# +-----------------------------------
######################################

#
# declare all files, with appropriate implementation and tool-flow tags
#
custom_decl_fileset_groups .. ../../alt_xcvr_reconfig
	
add_fileset synth2 QUARTUS_SYNTH fileset_quartus_synth
add_fileset sim_verilog SIM_VERILOG fileset_sim_verilog
add_fileset sim_vhdl SIM_VHDL fileset_sim_vhdl

set_fileset_property synth2 TOP_LEVEL sv_xcvr_generic
set_fileset_property sim_verilog TOP_LEVEL sv_xcvr_generic
set_fileset_property sim_vhdl TOP_LEVEL sv_xcvr_generic


# +-----------------------------------
# | Synthesis fileset callback
# | 
proc fileset_quartus_synth {name} {
	common_add_fileset_files {S5 ALL_HDL} {PLAIN QIP}
}

# +-----------------------------------
# | Verilog simulation fileset callback
# | 
proc fileset_sim_verilog {name} {
	common_add_fileset_files {S5 ALL_HDL} [concat PLAIN [common_fileset_tags_all_simulators] ]
}

# +-----------------------------------
# | VHDL simulation fileset callback
# | 
proc fileset_sim_vhdl {name} {
	common_add_fileset_files {S5 ALL_HDL} [concat PLAIN [common_fileset_tags_all_simulators] ]
}
