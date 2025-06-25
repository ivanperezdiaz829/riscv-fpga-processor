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
# | request TCL package from ACDS 10.0
# | 
package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_fifo_pause_ctrl_adapter
# | 
set_module_property NAME altera_eth_fifo_pause_ctrl_adapter
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet/Example"
set_module_property DISPLAY_NAME "Ethernet FIFO Pause Control Adapter"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_fifo_pause_ctrl_adapter.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_fifo_pause_ctrl_adapter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_fifo_pause_ctrl_adapter.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end

set_interface_property clock ENABLED true

add_interface_port clock reset reset Input 1
add_interface_port clock clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink_almost_full
# | 
add_interface avalon_streaming_sink_almost_full avalon_streaming end
set_interface_property avalon_streaming_sink_almost_full associatedClock clock
set_interface_property avalon_streaming_sink_almost_full dataBitsPerSymbol 1
set_interface_property avalon_streaming_sink_almost_full errorDescriptor ""
set_interface_property avalon_streaming_sink_almost_full maxChannel 0
set_interface_property avalon_streaming_sink_almost_full readyLatency 0

set_interface_property avalon_streaming_sink_almost_full ASSOCIATED_CLOCK clock
set_interface_property avalon_streaming_sink_almost_full ENABLED true

add_interface_port avalon_streaming_sink_almost_full data_sink_almost_full data Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink_almost_empty
# | 
add_interface avalon_streaming_sink_almost_empty avalon_streaming end
set_interface_property avalon_streaming_sink_almost_empty associatedClock clock
set_interface_property avalon_streaming_sink_almost_empty dataBitsPerSymbol 1
set_interface_property avalon_streaming_sink_almost_empty errorDescriptor ""
set_interface_property avalon_streaming_sink_almost_empty maxChannel 0
set_interface_property avalon_streaming_sink_almost_empty readyLatency 0

set_interface_property avalon_streaming_sink_almost_empty ASSOCIATED_CLOCK clock
set_interface_property avalon_streaming_sink_almost_empty ENABLED true

add_interface_port avalon_streaming_sink_almost_empty data_sink_almost_empty data Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# | 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source associatedClock clock
set_interface_property avalon_streaming_source dataBitsPerSymbol 2
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 0

set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock
set_interface_property avalon_streaming_source ENABLED true

add_interface_port avalon_streaming_source pause_ctrl_src_data data Output 2
# | 
# +-----------------------------------
