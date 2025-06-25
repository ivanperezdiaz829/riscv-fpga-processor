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
# | $Header: //acds/rel/13.1/ip/alt_pma/source/altera_xcvr_low_latency_phy/altera_xcvr_low_latency_phy_hw.tcl#1 $
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.1
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

source ../../../altera_xcvr_generic/tgx/alt_xcvr_s4_analog.tcl	;# function to declare S4 analog parameters
source ../../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xreconf_common.tcl	;# function to declare reconf block files
source xcvr_low_latency_files.tcl
source xcvr_low_latency_params.tcl	;# parameter definitions
source xcvr_low_latency_val_params.tcl	;# parameter validation
source xcvr_low_latency_port_procs.tcl	;# port and interface common functions
source xcvr_low_latency_ports.tcl		;# port and interface declaration functions

set_module_property ALLOW_GREYBOX_GENERATION true

# +-----------------------------------
# | module altera_xcvr_low_latency_phy
# | 
set_module_property NAME altera_xcvr_low_latency_phy
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME "Low Latency PHY"
set_module_property EDITABLE true
set_module_property GROUP "Interface Protocols/Transceiver PHY"
set_module_property AUTHOR "Altera Corporation"
set_module_property DESCRIPTION "Standard Transceiver PCS Low Latency PHY IP"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"
set_module_property ANALYZE_HDL false

set_module_property VALIDATION_CALLBACK validate
set_module_property ELABORATION_CALLBACK elaborate


# |
# +---------------------------------------------

# +---------------------------------------------
# | add display tabs
# |
set general "General"
set additional_options "Options"
set datapath "Datapath"
set analog_options "Analog Options"
set pll_reconfiguration "PLL Reconfiguration"

add_display_item "" $general GROUP tab
add_display_item "" "Additional Options" GROUP tab
add_display_item "Additional Options" $additional_options GROUP
add_display_item "Additional Options" $datapath GROUP
add_display_item "" "Reconfiguration" GROUP tab
add_display_item "Reconfiguration" "PLL Reconfiguration" GROUP 
add_display_item "Reconfiguration" "Channel Interface" GROUP 
add_display_item "" $analog_options GROUP tab
#add_display_item "" $reconfiguration GROUP tab
# |
# |
# +-----------------------------------------------


#set s4fams [join [ list_s4_style_hssi_families ] ", " ]
#add_display_item $analog_options sv_message_text TEXT "These options are only available for: $s4fams"
add_display_item "Analog Options" analog_message_text1 TEXT "Transceiver analog options may be set using the Quartus II Assignment Editor, Pin Planner, or QSF assignments."
add_display_item "Analog Options" analog_message_text2 TEXT "Refer to the device family user's guide for details."

# +---------------------------------------------
# | Low Latency PHY parameters
# | 

low_latency_add_device_parameters	;# device info parameters
low_latency_add_datapath_parameters	;# add all the common parameters
add_s4_analog_parameters $analog_options	;# S4-generation only analog settings, but must always declare
low_latency_add_reconfig_parameters $pll_reconfiguration
add_pll_reconfig_parameters $pll_reconfiguration
low_latency_add_mgmt_parameters		;# get clock frequencies from Qsys


# +-----------------------------------
# | Low Latency PHY ports
# | 

low_latency_mgmt_interface	;# declare phy_mgmt clock, reset, AvMM interface, and reset controller status streams
low_latency_static_native_ports	;# declare exposed clocks, data, control, and status


# +-----------------------------------
# | Validation
# | 
proc validate {} {
    validate_common_parameters ;# parameter validation common to all levels
    validate_mgmt   ;# clock freq parameter assignment
    validate_reconfiguration_parameters [get_parameter_value device_family];
    validate_optional_parameters    ;# parameter validation
    
    set device_family [get_parameter_value device_family]
    
    # family-specific validation
    if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
        validate_s4_constraints
    } else {
        validate_s5_constraints
    }
}

# +-----------------------------------
# | Elaboration
# | 
proc elaborate {} {
    set split [get_parameter_value gui_split_interfaces]
    low_latency_set_port_termination	;# sets port termination for all static ports, and sets tag state for dynamic ports
    low_latency_dynamic_native_ports $split
    low_latency_dynamic_reconfig_ports [get_parameter_value device_family]
}

######################################
# +-----------------------------------
# | Fileset callback functions
# +-----------------------------------
######################################

#
# declare all files, with appropriate implementation and tool-flow tags
#
low_latency_decl_fileset_groups ../..
	
add_fileset synth2 QUARTUS_SYNTH fileset_quartus_synth
add_fileset sim_verilog SIM_VERILOG fileset_sim_verilog
add_fileset sim_vhdl SIM_VHDL fileset_sim_vhdl

set_fileset_property synth2 TOP_LEVEL altera_xcvr_low_latency_phy
set_fileset_property sim_verilog TOP_LEVEL altera_xcvr_low_latency_phy
set_fileset_property sim_vhdl TOP_LEVEL altera_xcvr_low_latency_phy


# +-----------------------------------
# | Synthesis fileset callback
# | 
proc fileset_quartus_synth {name} {
	low_latency_add_fileset_for_tool {PLAIN QIP}
}

# +-----------------------------------
# | Verilog simulation fileset callback
# | 
proc fileset_sim_verilog {name} {
	low_latency_add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]
}

# +-----------------------------------
# | VHDL simulation fileset callback
# | 
proc fileset_sim_vhdl {name} {
	low_latency_add_fileset_for_tool [concat PLAIN [common_fileset_tags_all_simulators] ]
}
