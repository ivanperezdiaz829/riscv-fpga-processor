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


package require -exact sopc 9.1

# +-----------------------------------
# | module altera_eth_10g_rx_register_map
# | 
set_module_property DESCRIPTION "Altera Ethernet 10G MAC RX Register Map"
set_module_property NAME altera_eth_10g_rx_register_map
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet 10G MAC RX Register Map"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_10g_rx_register_map.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_10g_rx_register_map
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false


# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_10g_rx_register_map

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_10g_rx_register_map.v VERILOG_ENCRYPT PATH "mentor/altera_eth_10g_rx_register_map.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_10g_rx_register_map.v VERILOG_ENCRYPT PATH "aldec/altera_eth_10g_rx_register_map.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_10g_rx_register_map.v VERILOG_ENCRYPT PATH "cadence/altera_eth_10g_rx_register_map.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_10g_rx_register_map.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_10g_rx_register_map.v" {SYNOPSYS_SPECIFIC}
    }
    
    add_fileset_file altera_avalon_st_clock_crosser.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v"
}


# | Callbacks
# |  
proc elaborate {} {
    if {[ get_parameter_value ENABLE_1G10G_MAC ] == 0} {
        set_interface_property rx_1g_clk ENABLED false
        set_interface_property rx_1g_reset ENABLED false
        
        set_port_property rx_1g_clk TERMINATION true
        set_port_property rx_1g_reset TERMINATION true
        
        set_port_property rx_1g_clk TERMINATION_VALUE 0
        set_port_property rx_1g_reset TERMINATION_VALUE 1
    }
    
    if {[ get_parameter_value ENABLE_TIMESTAMPING ] == 0} {
        set_interface_property csr_tsu ENABLED false
        
        set_port_property csr_tsu_write TERMINATION true
        set_port_property csr_tsu_read TERMINATION true
        set_port_property csr_tsu_address TERMINATION true
        set_port_property csr_tsu_writedata TERMINATION true
        
        set_interface_property tsu_period_ns_fns_10g_src ENABLED false
        set_interface_property tsu_adjust_ns_fns_10g_src ENABLED false
        
        set_interface_property tsu_period_ns_fns_1g_src ENABLED false
        set_interface_property tsu_adjust_ns_fns_1g_src ENABLED false
    } else {
        if {[ get_parameter_value ENABLE_1G10G_MAC ] == 0} {
            set_interface_property tsu_period_ns_fns_1g_src ENABLED false
            set_interface_property tsu_adjust_ns_fns_1g_src ENABLED false
        }
    }
}


# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_10g_rx_register_map.v {SYNTHESIS}
add_file altera_eth_10g_rx_register_map.ocp {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_handshake_clock_crosser/altera_avalon_st_clock_crosser.v {SYNTHESIS}
# | 
# +-----------------------------------


# +-----------------------------------
# | parameters
# | 
add_parameter ENABLE_TIMESTAMPING INTEGER 0
set_parameter_property ENABLE_TIMESTAMPING DISPLAY_NAME "Enable Time Stamping"
set_parameter_property ENABLE_TIMESTAMPING DISPLAY_HINT boolean
set_parameter_property ENABLE_TIMESTAMPING DESCRIPTION "Instantiate Time Stamping Component"
set_parameter_property ENABLE_TIMESTAMPING VISIBLE true

add_parameter ENABLE_1G10G_MAC INTEGER 0
set_parameter_property ENABLE_1G10G_MAC DISPLAY_NAME "1G/10G MAC"
set_parameter_property ENABLE_1G10G_MAC DISPLAY_HINT boolean
set_parameter_property ENABLE_1G10G_MAC DESCRIPTION "Enable 1G/10G MAC support"
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock & reset
# | 

# CSR
add_interface csr_clk clock end
set_interface_property csr_clk ENABLED true
add_interface_port csr_clk csr_clk clk Input 1

add_interface csr_reset reset end
set_interface_property csr_reset ENABLED true
set_interface_property csr_reset associatedClock csr_clk
add_interface_port csr_reset csr_reset reset Input 1

# RX 10G
add_interface rx_10g_clk clock end
set_interface_property rx_10g_clk ENABLED true
add_interface_port rx_10g_clk rx_10g_clk clk Input 1

add_interface rx_10g_reset reset end
set_interface_property rx_10g_reset ENABLED true
set_interface_property rx_10g_reset associatedClock rx_10g_clk
add_interface_port rx_10g_reset rx_10g_reset reset Input 1

# RX 1G
add_interface rx_1g_clk clock end
set_interface_property rx_1g_clk ENABLED true
add_interface_port rx_1g_clk rx_1g_clk clk Input 1

add_interface rx_1g_reset reset end
set_interface_property rx_1g_reset ENABLED true
set_interface_property rx_1g_reset associatedClock rx_1g_clk
add_interface_port rx_1g_reset rx_1g_reset reset Input 1

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr_tsu
# | 
add_interface csr_tsu avalon end
set_interface_property csr_tsu addressAlignment DYNAMIC
set_interface_property csr_tsu bridgesToMaster ""
set_interface_property csr_tsu burstOnBurstBoundariesOnly false
set_interface_property csr_tsu holdTime 0
set_interface_property csr_tsu isMemoryDevice false
set_interface_property csr_tsu isNonVolatileStorage false
set_interface_property csr_tsu linewrapBursts false
set_interface_property csr_tsu maximumPendingReadTransactions 0
set_interface_property csr_tsu printableDevice false
set_interface_property csr_tsu readLatency 1
set_interface_property csr_tsu readWaitTime 0
set_interface_property csr_tsu setupTime 0
set_interface_property csr_tsu timingUnits Cycles
set_interface_property csr_tsu writeWaitTime 0

set_interface_property csr_tsu associatedClock csr_clk
set_interface_property csr_tsu associatedReset csr_reset
set_interface_property csr_tsu ENABLED true

add_interface_port csr_tsu csr_tsu_readdata readdata Output 32
add_interface_port csr_tsu csr_tsu_write write Input 1
add_interface_port csr_tsu csr_tsu_read read Input 1
add_interface_port csr_tsu csr_tsu_address address Input 4
add_interface_port csr_tsu csr_tsu_writedata writedata Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tsu_period_ns_fns_10g_src
# | 
add_interface tsu_period_ns_fns_10g_src avalon_streaming start
set_interface_property tsu_period_ns_fns_10g_src dataBitsPerSymbol 20
set_interface_property tsu_period_ns_fns_10g_src errorDescriptor ""
set_interface_property tsu_period_ns_fns_10g_src maxChannel 0
set_interface_property tsu_period_ns_fns_10g_src readyLatency 0
set_interface_property tsu_period_ns_fns_10g_src symbolsPerBeat 20

set_interface_property tsu_period_ns_fns_10g_src associatedClock rx_10g_clk
set_interface_property tsu_period_ns_fns_10g_src associatedReset rx_10g_reset
set_interface_property tsu_period_ns_fns_10g_src ENABLED true

add_interface_port tsu_period_ns_fns_10g_src tsu_period_ns_fns_10g data Output 20
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tsu_adjust_ns_fns_10g_src
# | 
add_interface tsu_adjust_ns_fns_10g_src avalon_streaming start
set_interface_property tsu_adjust_ns_fns_10g_src dataBitsPerSymbol 32
set_interface_property tsu_adjust_ns_fns_10g_src errorDescriptor ""
set_interface_property tsu_adjust_ns_fns_10g_src maxChannel 0
set_interface_property tsu_adjust_ns_fns_10g_src readyLatency 0
set_interface_property tsu_adjust_ns_fns_10g_src symbolsPerBeat 32

set_interface_property tsu_adjust_ns_fns_10g_src associatedClock rx_10g_clk
set_interface_property tsu_adjust_ns_fns_10g_src associatedReset rx_10g_reset
set_interface_property tsu_adjust_ns_fns_10g_src ENABLED true

add_interface_port tsu_adjust_ns_fns_10g_src tsu_adjust_ns_fns_10g data Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tsu_period_ns_fns_1g_src
# | 
add_interface tsu_period_ns_fns_1g_src avalon_streaming start
set_interface_property tsu_period_ns_fns_1g_src dataBitsPerSymbol 20
set_interface_property tsu_period_ns_fns_1g_src errorDescriptor ""
set_interface_property tsu_period_ns_fns_1g_src maxChannel 0
set_interface_property tsu_period_ns_fns_1g_src readyLatency 0
set_interface_property tsu_period_ns_fns_1g_src symbolsPerBeat 20

set_interface_property tsu_period_ns_fns_1g_src associatedClock rx_1g_clk
set_interface_property tsu_period_ns_fns_1g_src associatedReset rx_1g_reset
set_interface_property tsu_period_ns_fns_1g_src ENABLED true

add_interface_port tsu_period_ns_fns_1g_src tsu_period_ns_fns_1g data Output 20
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tsu_adjust_ns_fns_1g_src
# | 
add_interface tsu_adjust_ns_fns_1g_src avalon_streaming start
set_interface_property tsu_adjust_ns_fns_1g_src dataBitsPerSymbol 32
set_interface_property tsu_adjust_ns_fns_1g_src errorDescriptor ""
set_interface_property tsu_adjust_ns_fns_1g_src maxChannel 0
set_interface_property tsu_adjust_ns_fns_1g_src readyLatency 0
set_interface_property tsu_adjust_ns_fns_1g_src symbolsPerBeat 32

set_interface_property tsu_adjust_ns_fns_1g_src associatedClock rx_1g_clk
set_interface_property tsu_adjust_ns_fns_1g_src associatedReset rx_1g_reset
set_interface_property tsu_adjust_ns_fns_1g_src ENABLED true

add_interface_port tsu_adjust_ns_fns_1g_src tsu_adjust_ns_fns_1g data Output 32
# | 
# +-----------------------------------
