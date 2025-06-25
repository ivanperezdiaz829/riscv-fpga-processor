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
# | module altera_eth_xgmii_pipeline
# | 
set_module_property DESCRIPTION "Altera Ethernet XGMII Pipeline"
set_module_property NAME altera_eth_xgmii_pipeline
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet XGMII Pipeline"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_xgmii_pipeline.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_xgmii_pipeline
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_xgmii_pipeline.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point xgmii_sink
# | 
add_interface xgmii_sink avalon_streaming end
set_interface_property xgmii_sink dataBitsPerSymbol 9
set_interface_property xgmii_sink errorDescriptor ""
set_interface_property xgmii_sink maxChannel 0
set_interface_property xgmii_sink readyLatency 0
set_interface_property xgmii_sink symbolsPerBeat 8

set_interface_property xgmii_sink ASSOCIATED_CLOCK clock_reset
set_interface_property xgmii_sink ENABLED true

add_interface_port xgmii_sink xgmii_sink_data data Input 72
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point xgmii_source
# | 
add_interface xgmii_source avalon_streaming start
set_interface_property xgmii_source dataBitsPerSymbol 9
set_interface_property xgmii_source errorDescriptor ""
set_interface_property xgmii_source maxChannel 0
set_interface_property xgmii_source readyLatency 0
set_interface_property xgmii_source symbolsPerBeat 8

set_interface_property xgmii_source ASSOCIATED_CLOCK clock_reset
set_interface_property xgmii_source ENABLED true

add_interface_port xgmii_source xgmii_src_data data Output 72

# | 
# +-----------------------------------

proc elaborate {} {

  set symbols_per_beat 8
  set bits_per_symbol 9

  set_interface_property xgmii_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property xgmii_sink symbolsPerBeat $symbols_per_beat
  set_interface_property xgmii_source dataBitsPerSymbol $bits_per_symbol
  set_interface_property xgmii_source symbolsPerBeat $symbols_per_beat

  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property xgmii_sink_data WIDTH $data_width
  set_port_property xgmii_src_data WIDTH $data_width
}
