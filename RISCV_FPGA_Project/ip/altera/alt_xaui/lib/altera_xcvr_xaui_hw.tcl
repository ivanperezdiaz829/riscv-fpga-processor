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


#-----------------------------------------------------------------------------
#
# Description: altera_xcvr_xaui_hw.tcl
#
# Authors:     dunnikri    19-Aug-2010
# Modified:    ishimony    13-Dec-2010 dxaui added
# Modified:    hhleong     11-May-2012 av xaui added
#
#              Copyright (c) Altera Corporation 1997 - 2012
#              All rights reserved.
#
# 
#-----------------------------------------------------------------------------
# | request TCL package from ACDS 11.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------
#
 set_module_property ALLOW_GREYBOX_GENERATION true

# module alt_xaui_phy_top
set_module_property NAME altera_xcvr_xaui
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property DISPLAY_NAME "XAUI PHY"
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaboration_callback
set_module_property VALIDATION_CALLBACK validation_callback
set_module_property ANALYZE_HDL false
set_module_property AUTHOR Altera
set_module_property DESCRIPTION "XGMII to XAUI transceiver"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/xcvr_user_guide.pdf"

lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/alt_xcvr_tcl_packages
lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
package require alt_xcvr::utils::rbc
package require altera_xcvr_reset_control::fileset

source ipcc_tcl_helper.tcl
source ../../altera_xcvr_generic/alt_xcvr_common.tcl
source ../../altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl	;# function to declare csr soft logic files
source ../../altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl	;# function to decl S5 native channel files
source ../../altera_xcvr_generic/av/av_xcvr_native_fileset.tcl	;# function to decl A5 native channel files
source ../../alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xreconf_common.tcl	;# function to declare reconf block files
source ./alt_xaui_common.tcl

# +-----------------------------------
# | files
# | 

custom_decl_fileset_groups .. ../../alt_xcvr_reconfig

add_fileset          synth2      QUARTUS_SYNTH fileset_quartus_synth
add_fileset          sim_verilog SIM_VERILOG   fileset_sim_verilog
add_fileset          sim_vhdl    SIM_VHDL      fileset_sim_vhdl

set_fileset_property synth2      TOP_LEVEL altera_xcvr_xaui
set_fileset_property sim_verilog TOP_LEVEL altera_xcvr_xaui
set_fileset_property sim_vhdl    TOP_LEVEL altera_xcvr_xaui

# synthesis fileset callback
proc fileset_quartus_synth {name} {
  custom_add_fileset_for_tool {PLAIN QENCRYPT QIP}
}

# Verilog simulation fileset callback
proc fileset_sim_verilog {name} {
  custom_add_fileset_for_tool [concat PLAIN SIM_SCRIPT [common_fileset_tags_all_simulators]]
}

# Verilog simulation fileset callback
proc fileset_sim_vhdl {name} {
  custom_add_fileset_for_tool [concat PLAIN SIM_SCRIPT [common_fileset_tags_all_simulators]]
}

# | 
# +-----------------------------------

# | 
# +-----------------------------------
# | tabs
# |
add_display_item "" "General Options"  GROUP tab
  add_param_str device_family "Stratix IV" {"Stratix IV" "HardCopy IV" "Stratix V" "Arria V" "Cyclone V" "Cyclone IV GX" "Arria II GX" "Arria II GZ" "Arria V GZ"} "General Options"
  set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
  set_parameter_property device_family DESCRIPTION \
    "Possible values are Stratix IV or HardCopy IV or Stratix V or Arria V or Cyclone V or Cyclone IV GX or Arria II GX or Arria II GZ or Arria V GZ"
  set_parameter_property device_family DISPLAY_NAME \
    "Device family"
add_display_item "" "Analog Options"   GROUP tab
add_display_item "" "Advanced Options" GROUP tab

add_display_item "Analog Options" sv_message_text TEXT "These options are only available for families Stratix IV, Arria II and Cyclone IV."

# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
common_add_parameters_for_native_phy
add_extra_parameters_for_top_phy

#
# Elaborate
#----------
proc elaboration_callback { } {
  set use_cs_ports   [get_parameter_value use_control_and_status_ports]
  set external_pcr   [get_parameter_value external_pma_ctrl_reconf]
  set sv_support     [get_parameter_value device_family]
  set sv_support     [get_parameter_value device_family]
  set exp_cdr_clk    [get_parameter_value en_synce_support]
  
  if {[get_parameter_value device_family] == "Stratix V" } {
    set sv_support 1
  } elseif {[get_parameter_value device_family] == "Arria V GZ" } {
    set sv_support 1 
  } else {
    set sv_support 0
   }
 
  set av_support     [get_parameter_value device_family]
  if {[get_parameter_value device_family] == "Arria V" } {
    set av_support 1
  } else {
    set av_support 0
   } 
   
  set cv_support     [get_parameter_value device_family]
  if {[get_parameter_value device_family] == "Cyclone V" } {
    set cv_support 1
  } else {
    set cv_support 0
   } 

  # declare ports and mappings for elaboration callback
  common_clock_interfaces

  #XAUI_RATE:0 for channel_based; 1 for shared
  common_xaui_interface_ports 1 

  # add memory-mapped slave interface, with 9-bit wide word address, readLatency of 0 (uses waitrequest)
  common_mgmt_interface 9 0

  if {$use_cs_ports} {
    common_xaui_controlstatus_ports
  } else { 
    terminate_xaui_controlstatus_ports
  }

  if {$external_pcr } {
    common_xaui_extpma_ports
  } else { 
    terminate_xaui_extpma_ports
  }

  
  if {$exp_cdr_clk} {
    cdr_ref_clk_port
  } else { 
    terminate_cdr_ref_clk_port
  }


  if {$external_pcr & (!$sv_support | !$av_support | !$cv_support )} {
    add_reconfig_ports
  } else { 
    terminate_reconfig_ports
  }
 
   if {$sv_support | $av_support | $cv_support} {
    add_reconfig_ports
    } 

 if {[get_parameter_value device_family] == "Arria V" || [get_parameter_value device_family] == "Cyclone V"} {
 common_display_reconfig_interface_message [get_parameter_value device_family] 4 1
  } else {
    common_display_reconfig_interface_message [get_parameter_value device_family] 4 4
   }

}

#------------------------------------------------------------------------------
#
# Validation
#-------------
# validate - displaying messages and checking parameters
proc validation_callback {} {
    common_parameter_validation
}

