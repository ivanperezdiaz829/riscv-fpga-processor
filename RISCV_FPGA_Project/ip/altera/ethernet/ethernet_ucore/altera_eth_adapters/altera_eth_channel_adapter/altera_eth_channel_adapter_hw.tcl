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


# altera_eth_channel_adapter module
set_module_property DESCRIPTION "Ethernet XGMII Channel Adapter"
set_module_property NAME altera_eth_channel_adapter
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet XGMII Channel Adapter"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false
set_module_property ELABORATION_CALLBACK elaborate

# +-----------------------------------
# | parameters
# | 
add_parameter ERROR_WIDTH INTEGER 2
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH IS_HDL_PARAMETER false
set_parameter_property ERROR_WIDTH ALLOWED_RANGES 1:32

# | 
# +-----------------------------------

# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1



# +-----------------------------------
# | connection point channel_adapter_sink
# | 
add_interface channel_adapter_sink avalon_streaming end
set_interface_property channel_adapter_sink dataBitsPerSymbol 8
set_interface_property channel_adapter_sink errorDescriptor ""
set_interface_property channel_adapter_sink maxChannel 1
set_interface_property channel_adapter_sink readyLatency 0
set_interface_property channel_adapter_sink symbolsPerBeat 8
set_interface_property channel_adapter_sink ASSOCIATED_CLOCK clock_reset
set_interface_property channel_adapter_sink ENABLED true

add_interface_port channel_adapter_sink channel_adapter_sink_sop startofpacket input 1
add_interface_port channel_adapter_sink channel_adapter_sink_eop endofpacket input 1
add_interface_port channel_adapter_sink channel_adapter_sink_valid valid input 1
add_interface_port channel_adapter_sink channel_adapter_sink_data data input 64
add_interface_port channel_adapter_sink channel_adapter_sink_empty empty input 3
add_interface_port channel_adapter_sink channel_adapter_sink_error error input 2
add_interface_port channel_adapter_sink channel_adapter_sink_ready ready output 1
add_interface_port channel_adapter_sink channel_adapter_sink_channel channel Input 1


# +-----------------------------------
# | connection point channel_adapter_src
# | 
add_interface channel_adapter_src avalon_streaming start
set_interface_property channel_adapter_src dataBitsPerSymbol 8
set_interface_property channel_adapter_src errorDescriptor ""
set_interface_property channel_adapter_src maxChannel 0
set_interface_property channel_adapter_src readyLatency 0
set_interface_property channel_adapter_src symbolsPerBeat 8
set_interface_property channel_adapter_src ASSOCIATED_CLOCK clock_reset
set_interface_property channel_adapter_src ENABLED true

add_interface_port channel_adapter_src channel_adapter_src_sop startofpacket Output 1
add_interface_port channel_adapter_src channel_adapter_src_eop endofpacket Output 1
add_interface_port channel_adapter_src channel_adapter_src_valid valid Output 1
add_interface_port channel_adapter_src channel_adapter_src_data data Output 64
add_interface_port channel_adapter_src channel_adapter_src_empty empty Output 3
add_interface_port channel_adapter_src channel_adapter_src_error error Output 2
add_interface_port channel_adapter_src channel_adapter_src_ready ready Input 1
#add_interface_port channel_adapter_src channel_adapter_src_channel channel Output 1

#set_port_property channel_adapter_src_channel TERMINATION true
#set_port_property channel_adapter_src_channel TERMINATION_VALUE 1

set_port_property channel_adapter_src_sop DRIVEN_BY channel_adapter_sink_sop
set_port_property channel_adapter_src_eop DRIVEN_BY channel_adapter_sink_eop
set_port_property channel_adapter_src_valid DRIVEN_BY channel_adapter_sink_valid
set_port_property channel_adapter_src_data DRIVEN_BY channel_adapter_sink_data
set_port_property channel_adapter_src_empty DRIVEN_BY channel_adapter_sink_empty
set_port_property channel_adapter_src_error DRIVEN_BY channel_adapter_sink_error
set_port_property channel_adapter_sink_ready DRIVEN_BY channel_adapter_src_ready
#set_port_property channel_adapter_src_channel DRIVEN_BY channel_adapter_sink_channel

proc elaborate {} {
    set error_width [ get_parameter_value ERROR_WIDTH ]
    
    set_port_property channel_adapter_sink_error WIDTH $error_width
    set_port_property channel_adapter_src_error WIDTH $error_width
}
