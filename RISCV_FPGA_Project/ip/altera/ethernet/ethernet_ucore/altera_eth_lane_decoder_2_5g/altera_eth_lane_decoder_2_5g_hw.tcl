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


# (C) 2001-2010 Altera Corporation. All rights reserved.
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
# | module altera_eth_lane_decoder_2_5g
# | 
set_module_property DESCRIPTION altera_eth_lane_decoder_2_5g
set_module_property NAME altera_eth_lane_decoder_2_5g
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME altera_eth_lane_decoder_2_5g
set_module_property TOP_LEVEL_HDL_FILE altera_eth_lane_decoder_2_5g.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_lane_decoder_2_5g
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
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
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_lane_decoder_2_5g

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_lane_decoder_2_5g.sv VERILOG_ENCRYPT PATH "mentor/altera_eth_lane_decoder_2_5g.sv" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_lane_decoder_2_5g.sv VERILOG_ENCRYPT PATH "aldec/altera_eth_lane_decoder_2_5g.sv" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_lane_decoder_2_5g.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_eth_lane_decoder_2_5g.sv" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_lane_decoder_2_5g.sv VERILOG_ENCRYPT PATH "synopsys/altera_eth_lane_decoder_2_5g.sv" {SYNOPSYS_SPECIFIC}
    }
    add_fileset_file altera_avalon_dc_fifo.v VERILOG PATH "../../../sopc_builder_ip/altera_avalon_dc_fifo/altera_avalon_dc_fifo.v"
    add_fileset_file altera_dcfifo_synchronizer_bundle.v VERILOG PATH "../../../sopc_builder_ip/altera_avalon_dc_fifo/altera_dcfifo_synchronizer_bundle.v"
}


# +-----------------------------------
# | files
# | 
add_file altera_eth_lane_decoder_2_5g.sv {SYNTHESIS}
add_file altera_eth_lane_decoder_2_5g.ocp {SYNTHESIS}
add_file ../../../sopc_builder_ip/altera_avalon_dc_fifo/altera_avalon_dc_fifo.v {SYNTHESIS}
add_file ../../../sopc_builder_ip/altera_avalon_dc_fifo/altera_dcfifo_synchronizer_bundle.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter W_GMII_WIDTH INTEGER 16
set_parameter_property W_GMII_WIDTH DEFAULT_VALUE 16
set_parameter_property W_GMII_WIDTH DISPLAY_NAME W_GMII_WIDTH
set_parameter_property W_GMII_WIDTH TYPE INTEGER
set_parameter_property W_GMII_WIDTH ENABLED false
set_parameter_property W_GMII_WIDTH UNITS None
set_parameter_property W_GMII_WIDTH AFFECTS_GENERATION false
set_parameter_property W_GMII_WIDTH HDL_PARAMETER true
add_parameter BITSPERSYMBOL INTEGER 8
set_parameter_property BITSPERSYMBOL DEFAULT_VALUE 8
set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
set_parameter_property BITSPERSYMBOL TYPE INTEGER
set_parameter_property BITSPERSYMBOL ENABLED false
set_parameter_property BITSPERSYMBOL UNITS None
set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
set_parameter_property BITSPERSYMBOL HDL_PARAMETER true
add_parameter SYMBOLSPERBEAT INTEGER 8
set_parameter_property SYMBOLSPERBEAT DEFAULT_VALUE 8
set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property SYMBOLSPERBEAT TYPE INTEGER
set_parameter_property SYMBOLSPERBEAT ENABLED false
set_parameter_property SYMBOLSPERBEAT UNITS None
set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLSPERBEAT HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_sink_gmii_data
# | 
add_interface avalon_sink_gmii_data avalon_streaming end
set_interface_property avalon_sink_gmii_data associatedClock clock_reset_gmii
set_interface_property avalon_sink_gmii_data dataBitsPerSymbol 16
set_interface_property avalon_sink_gmii_data errorDescriptor ""
set_interface_property avalon_sink_gmii_data maxChannel 0
set_interface_property avalon_sink_gmii_data readyLatency 0

set_interface_property avalon_sink_gmii_data ASSOCIATED_CLOCK clock_reset_gmii
set_interface_property avalon_sink_gmii_data ENABLED true

add_interface_port avalon_sink_gmii_data gmii_sink_data data Input 16
add_interface_port avalon_sink_gmii_data gmii_sink_error error Input 2
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# | 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source associatedClock clock_reset_mac
set_interface_property avalon_streaming_source dataBitsPerSymbol 8
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 0

set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock_reset_mac
set_interface_property avalon_streaming_source ENABLED true

add_interface_port avalon_streaming_source rxdata_src_sop startofpacket Output 1
add_interface_port avalon_streaming_source rxdata_src_eop endofpacket Output 1
add_interface_port avalon_streaming_source rxdata_src_valid valid Output 1
add_interface_port avalon_streaming_source rxdata_src_data data Output 64
add_interface_port avalon_streaming_source rxdata_src_empty empty Output 3
add_interface_port avalon_streaming_source rxdata_src_error error Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset_mac
# | 
add_interface clock_reset_mac clock end

set_interface_property clock_reset_mac ENABLED true

add_interface_port clock_reset_mac clk_mac clk Input 1
add_interface_port clock_reset_mac reset_mac reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset_gmii
# | 
add_interface clock_reset_gmii clock end

set_interface_property clock_reset_gmii ENABLED true

add_interface_port clock_reset_gmii clk_gmii clk Input 1
add_interface_port clock_reset_gmii reset_gmii reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_sink_gmii_control
# | 
add_interface avalon_sink_gmii_control avalon_streaming end
set_interface_property avalon_sink_gmii_control associatedClock clock_reset_gmii
set_interface_property avalon_sink_gmii_control dataBitsPerSymbol 2
set_interface_property avalon_sink_gmii_control errorDescriptor ""
set_interface_property avalon_sink_gmii_control maxChannel 0
set_interface_property avalon_sink_gmii_control readyLatency 0

set_interface_property avalon_sink_gmii_control ASSOCIATED_CLOCK clock_reset_gmii
set_interface_property avalon_sink_gmii_control ENABLED true

add_interface_port avalon_sink_gmii_control gmii_sink_control data Input 2
# | 
# +-----------------------------------
