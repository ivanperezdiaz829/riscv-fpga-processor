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


package require -exact sopc 11.0

# +-----------------------------------
# | module altera_eth_gmii2avst_converter
# | 
set_module_property DESCRIPTION "Altera Ethernet GMII to Avalon-ST Converter"
set_module_property NAME altera_eth_gmii2avst_converter
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet GMII to Avalon-ST Converter"
set_module_property TOP_LEVEL_HDL_FILE altera_tse_gmii_to_avst_if.v
set_module_property TOP_LEVEL_HDL_MODULE altera_tse_gmii_to_avst_if
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VERILOG true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_tse_gmii_to_avst_if.v {SYNTHESIS}
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_tse_gmii_to_avst_if

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_tse_gmii_to_avst_if.v VERILOG_ENCRYPT PATH "mentor/altera_tse_gmii_to_avst_if.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_tse_gmii_to_avst_if.v VERILOG_ENCRYPT PATH "aldec/altera_tse_gmii_to_avst_if.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_tse_gmii_to_avst_if.v VERILOG_ENCRYPT PATH "cadence/altera_tse_gmii_to_avst_if.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_tse_gmii_to_avst_if.v VERILOG_ENCRYPT PATH "synopsys/altera_tse_gmii_to_avst_if.v" {SYNOPSYS_SPECIFIC}
    }
}

# +-----------------------------------
# | parameters
# | 

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clk clock end
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1

add_interface reset reset end
set_interface_property reset ENABLED true
set_interface_property reset associatedClock clk
add_interface_port reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk_ena
# | 
add_interface clk_ena avalon_streaming end
set_interface_property clk_ena dataBitsPerSymbol 1
set_interface_property clk_ena errorDescriptor ""
set_interface_property clk_ena maxChannel 0
set_interface_property clk_ena readyLatency 0
set_interface_property clk_ena symbolsPerBeat 1

set_interface_property clk_ena associatedClock clk
set_interface_property clk_ena associatedReset reset
set_interface_property clk_ena ENABLED false

add_interface_port clk_ena clk_ena data Input 1

set_port_property clk_ena TERMINATION true
set_port_property clk_ena TERMINATION_VALUE 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point gmii_sink
# | 
# add_interface gmii_sink avalon_streaming end
# set_interface_property gmii_sink dataBitsPerSymbol 10
# set_interface_property gmii_sink errorDescriptor ""
# set_interface_property gmii_sink maxChannel 0
# set_interface_property gmii_sink readyLatency 0
# set_interface_property gmii_sink symbolsPerBeat 1

# set_interface_property gmii_sink associatedClock clk
# set_interface_property gmii_sink associatedReset reset
# set_interface_property gmii_sink ENABLED true

# add_interface_port gmii_sink gmii_sink data Input 10
# set_port_property gmii_sink FRAGMENT_LIST [list tx_err tx_en tx_d(7:0)]

add_interface gmii_sink_error conduit end
set_interface_property gmii_sink_error ENABLED true
add_interface_port gmii_sink_error tx_err export Input 1

add_interface gmii_sink_en conduit end
set_interface_property gmii_sink_en ENABLED true
add_interface_port gmii_sink_en tx_en export Input 1

add_interface gmii_sink_data conduit end
set_interface_property gmii_sink_data ENABLED true
add_interface_port gmii_sink_data tx_d export Input 8
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point data_src
# | 
add_interface data_src avalon_streaming start
set_interface_property data_src dataBitsPerSymbol 8
set_interface_property data_src errorDescriptor ""
set_interface_property data_src maxChannel 0
set_interface_property data_src readyLatency 0
set_interface_property data_src symbolsPerBeat 1

set_interface_property data_src associatedClock clk
set_interface_property data_src associatedReset reset
set_interface_property data_src ENABLED true

add_interface_port data_src data_src_sop startofpacket Output 1
add_interface_port data_src data_src_eop endofpacket Output 1
add_interface_port data_src data_src_valid valid Output 1
add_interface_port data_src data_src_ready ready Input 1
add_interface_port data_src data_src_data data Output 8
add_interface_port data_src data_src_empty empty Output 1
add_interface_port data_src data_src_error error Output 1

# | 
# +-----------------------------------

proc elaborate {} {
    set_port_property data_src_data WIDTH 8
    set_port_property data_src_empty WIDTH 1
    set_port_property data_src_error WIDTH 1
    
    set_port_property tx_d WIDTH 8
}
