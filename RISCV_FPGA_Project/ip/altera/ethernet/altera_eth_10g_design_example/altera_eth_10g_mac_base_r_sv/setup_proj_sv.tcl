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


global env ;

#==============================================================================
# Create project top and ip folder                
#==============================================================================
if {![project_exists top_sv]} {
    project_new top_sv
    post_message -type info "Created new project: top\n"
}
 
#==============================================================================
# Set project environment              
#==============================================================================
set_global_assignment -name FAMILY "Stratix V"
set_global_assignment -name TOP_LEVEL_ENTITY top_sv
set_global_assignment -name QIP_FILE altera_eth_10g_mac_base_r_sv/synthesis/altera_eth_10g_mac_base_r_sv.qip
set_global_assignment -name VERILOG_FILE top_sv.v
set_global_assignment -name VERILOG_FILE $env(QUARTUS_ROOTDIR)/../ip/altera/ethernet/altera_eth_10g_design_example/design_example_components/altera_eth_addr_swapper/altera_eth_addr_swapper.v
set_global_assignment -name SDC_FILE top.sdc
set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
set_global_assignment -name AUTO_GLOBAL_REGISTER_CONTROLS OFF
set_global_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION OFF

export_assignments
