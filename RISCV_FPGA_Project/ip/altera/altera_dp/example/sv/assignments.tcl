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


#######################################################
#
# Device, pin and other assignments for the 
# DisplayPort MegaCore Example Design
# 
# #####################################################

# Set the family, device, top-level entity
set_global_assignment -name FAMILY "Stratix V"
set_global_assignment -name DEVICE 5SGXEA7K2F40C2
set_global_assignment -name TOP_LEVEL_ENTITY sv_dp_example

# add files to the project
set_global_assignment -name VERILOG_FILE sv_dp_example.v
set_global_assignment -name QIP_FILE sv_dp.qip
set_global_assignment -name QIP_FILE sv_xcvr_reconfig.qip
set_global_assignment -name VERILOG_FILE reconfig_mgmt_write.v
set_global_assignment -name VERILOG_FILE reconfig_mgmt_hw_ctrl.v
set_global_assignment -name VERILOG_FILE dp_analog_mappings.v
set_global_assignment -name VERILOG_FILE dp_mif_mappings.v

# Add the example SDC last to not get overwritten by the IP ones
set_global_assignment -name SDC_FILE sv_dp_example.sdc

# Assign some I/O standards to eliminate fitter warnings
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rx_serial_data[*]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to tx_serial_data[*]
set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to xcvr_refclk[*]

# Use this assignment to allow fitter to pack all the channels into
# one reconfig group. 
set_instance_assignment -name XCVR_TX_PLL_RECONFIG_GROUP 0 -to *cmu_pll.tx_pll

