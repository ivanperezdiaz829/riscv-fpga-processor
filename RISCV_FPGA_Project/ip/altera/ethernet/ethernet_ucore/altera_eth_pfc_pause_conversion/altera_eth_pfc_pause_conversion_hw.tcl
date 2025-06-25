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
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_pfc_pause_conversion
# | 
set_module_property DESCRIPTION "Altera Ethernet PFC Pause Conversion"
set_module_property NAME altera_eth_pfc_pause_conversion
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet PFC Pause Conversion"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_pfc_pause_conversion.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_pfc_pause_conversion
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
set_module_property ELABORATION_CALLBACK elaborate
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_pfc_pause_conversion

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pfc_pause_conversion.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/mentor/altera_eth_pkt_backpressure_control.v"
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pfc_pause_conversion.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/aldec/altera_eth_pkt_backpressure_control.v"
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pfc_pause_conversion.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/cadence/altera_eth_pkt_backpressure_control.v"
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pfc_pause_conversion.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/synopsys/altera_eth_pkt_backpressure_control.v"
    }
}

proc sim_vhd {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pfc_pause_conversion.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/mentor/altera_eth_pkt_backpressure_control.v"
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pfc_pause_conversion.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/aldec/altera_eth_pkt_backpressure_control.v"
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pfc_pause_conversion.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/cadence/altera_eth_pkt_backpressure_control.v"
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pfc_pause_conversion.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pfc_pause_conversion.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pkt_backpressure_control.v VERILOG_ENCRYPT PATH "../altera_eth_pkt_backpressure_control/synopsys/altera_eth_pkt_backpressure_control.v"
    }
}



# +-----------------------------------
# | files
# | 
add_file altera_eth_pfc_pause_conversion.v {SYNTHESIS}
add_file ../altera_eth_pkt_backpressure_control/altera_eth_pkt_backpressure_control.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------
add_parameter PFC_PRIORITY_NUM INTEGER 8 "Number of PFC priority"
set_parameter_property PFC_PRIORITY_NUM DISPLAY_NAME BITSPERSYMBOL
set_parameter_property PFC_PRIORITY_NUM ENABLED true
set_parameter_property PFC_PRIORITY_NUM UNITS None
set_parameter_property PFC_PRIORITY_NUM ALLOWED_RANGES 2:16
set_parameter_property PFC_PRIORITY_NUM DESCRIPTION "Number of PFC priority"
set_parameter_property PFC_PRIORITY_NUM DISPLAY_HINT ""
set_parameter_property PFC_PRIORITY_NUM AFFECTS_GENERATION false
set_parameter_property PFC_PRIORITY_NUM HDL_PARAMETER true

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pfc_pause_quanta_sink
# | 
add_interface pfc_pause_quanta_sink avalon_streaming end
set_interface_property pfc_pause_quanta_sink associatedClock clock_reset
set_interface_property pfc_pause_quanta_sink dataBitsPerSymbol 136
set_interface_property pfc_pause_quanta_sink symbolsPerBeat 1
set_interface_property pfc_pause_quanta_sink errorDescriptor ""
set_interface_property pfc_pause_quanta_sink maxChannel 0
set_interface_property pfc_pause_quanta_sink readyLatency 0

set_interface_property pfc_pause_quanta_sink ENABLED true

add_interface_port pfc_pause_quanta_sink pfc_pause_quanta_sink_valid valid Input 1
add_interface_port pfc_pause_quanta_sink pfc_pause_quanta_sink_data data Input 136
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pfc_pause_ena_src
# | 
add_interface pfc_pause_ena_src avalon_streaming start
set_interface_property pfc_pause_ena_src associatedClock clock_reset
set_interface_property pfc_pause_ena_src dataBitsPerSymbol 8
set_interface_property pfc_pause_ena_src symbolsPerBeat 1
set_interface_property pfc_pause_ena_src errorDescriptor ""
set_interface_property pfc_pause_ena_src maxChannel 0
set_interface_property pfc_pause_ena_src readyLatency 0

set_interface_property pfc_pause_ena_src ENABLED true

add_interface_port pfc_pause_ena_src pfc_pause_ena_src_data data Output 8
# | 
# +-----------------------------------

proc elaborate {} {
    set pfc_priority_num [ get_parameter_value PFC_PRIORITY_NUM ]
    
    set_interface_property pfc_pause_quanta_sink dataBitsPerSymbol [ expr 17 * $pfc_priority_num ]
    set_interface_property pfc_pause_ena_src dataBitsPerSymbol [ expr 1 * $pfc_priority_num ]
    
    set_port_property pfc_pause_quanta_sink_data WIDTH [ expr 17 * $pfc_priority_num ]
    set_port_property pfc_pause_ena_src_data WIDTH [ expr 1 * $pfc_priority_num ]
}
