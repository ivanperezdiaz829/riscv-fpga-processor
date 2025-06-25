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


# altera_eth_pause_req_termination module
set_module_property DESCRIPTION "Ethernet Pause Request Termination"
set_module_property NAME altera_eth_pause_req_termination
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Pause Request Termination"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false

# +-----------------------------------
# | parameters
# | 

# | 
# +-----------------------------------

# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1



# +-----------------------------------
# | connection point pause_control_src
# | 
add_interface pause_control_src avalon_streaming start
set_interface_property pause_control_src dataBitsPerSymbol 2
set_interface_property pause_control_src errorDescriptor ""
set_interface_property pause_control_src maxChannel 0
set_interface_property pause_control_src readyLatency 0
set_interface_property pause_control_src symbolsPerBeat 1
set_interface_property pause_control_src ASSOCIATED_CLOCK clock_reset
set_interface_property pause_control_src ENABLED true

add_interface_port pause_control_src pause_control_src_data data Output 2

set_port_property pause_control_src_data DRIVEN_BY 0
