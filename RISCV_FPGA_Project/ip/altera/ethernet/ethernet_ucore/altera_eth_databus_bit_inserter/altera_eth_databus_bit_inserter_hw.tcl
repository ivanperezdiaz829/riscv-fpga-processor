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
# | request TCL package from ACDS 11.0
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_databus_bit_inserter
# | 
set_module_property DESCRIPTION altera_eth_databus_bit_inserter
set_module_property NAME altera_eth_databus_bit_inserter
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME altera_eth_databus_bit_inserter
set_module_property TOP_LEVEL_HDL_FILE altera_eth_databus_bit_inserter.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_databus_bit_inserter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_databus_bit_inserter

proc sim_ver {name} {
        add_fileset_file altera_eth_databus_bit_inserter.v VERILOG PATH "altera_eth_databus_bit_inserter.v"
}
proc sim_vhd {name} {
        add_fileset_file altera_eth_databus_bit_inserter.v VERILOG PATH "altera_eth_databus_bit_inserter.v"
}


# +-----------------------------------
# | files
# | 
add_file altera_eth_databus_bit_inserter.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection # | 
add_interface clk clock end
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1

add_interface reset reset end
set_interface_property reset ENABLED true
add_interface_port reset reset reset Input 1
set_interface_property reset ASSOCIATED_CLOCK clk

add_interface avalon_st_sink_data avalon_streaming sink asynchronous
set_interface_property avalon_st_sink_data dataBitsPerSymbol 39
set_interface_property avalon_st_sink_data errorDescriptor ""
set_interface_property avalon_st_sink_data maxChannel 0
set_interface_property avalon_st_sink_data readyLatency 0
set_interface_property avalon_st_sink_data symbolsPerBeat 1
set_interface_property avalon_st_sink_data ENABLED true
set_interface_property avalon_st_sink_data ASSOCIATED_CLOCK clk
set_interface_property avalon_st_sink_data associatedReset reset

add_interface_port avalon_st_sink_data stat_sink_valid valid Input 1
add_interface_port avalon_st_sink_data stat_sink_data data Input 39
add_interface_port avalon_st_sink_data stat_sink_error error Input 7


add_interface avalon_st_source_data avalon_streaming source asynchronous
set_interface_property avalon_st_source_data dataBitsPerSymbol 40
set_interface_property avalon_st_source_data errorDescriptor ""
set_interface_property avalon_st_source_data maxChannel 0
set_interface_property avalon_st_source_data readyLatency 0
set_interface_property avalon_st_source_data symbolsPerBeat 1
set_interface_property avalon_st_source_data ENABLED true
set_interface_property avalon_st_source_data ASSOCIATED_CLOCK clk
set_interface_property avalon_st_source_data associatedReset reset

add_interface_port avalon_st_source_data stat_source_valid valid Output 1
add_interface_port avalon_st_source_data stat_source_data data Output 40
add_interface_port avalon_st_source_data stat_source_error error Output 7

# | 
# +-----------------------------------


