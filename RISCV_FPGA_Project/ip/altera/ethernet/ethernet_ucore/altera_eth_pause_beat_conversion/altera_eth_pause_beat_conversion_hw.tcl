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
# | module altera_eth_pause_beat_conversion
# | 
set_module_property DESCRIPTION "Altera Ethernet Pause Beat Conversion"
set_module_property NAME altera_eth_pause_beat_conversion
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Pause Beat Conversion"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_pause_beat_conversion.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_pause_beat_conversion
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
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_pause_beat_conversion

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_beat_conversion.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_beat_conversion.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_beat_conversion.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_beat_conversion.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_beat_conversion.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_beat_conversion.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_beat_conversion.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_pause_beat_conversion.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_beat_conversion.v" {SYNOPSYS_SPECIFIC}
   }
}


# +-----------------------------------
# | files
# | 
add_file altera_eth_pause_beat_conversion.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------
set GET_MAC_1G10G_ENA_VALUE                          0

add_parameter GET_MAC_1G10G_ENA INTEGER $GET_MAC_1G10G_ENA_VALUE
set_parameter_property GET_MAC_1G10G_ENA DISPLAY_NAME GET_MAC_1G10G_ENA
set_parameter_property GET_MAC_1G10G_ENA UNITS None
set_parameter_property GET_MAC_1G10G_ENA DISPLAY_HINT "boolean"
set_parameter_property GET_MAC_1G10G_ENA AFFECTS_GENERATION false
set_parameter_property GET_MAC_1G10G_ENA IS_HDL_PARAMETER false
set_parameter_property GET_MAC_1G10G_ENA VISIBLE false


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
# | connection point pause_quanta_sink
# | 
add_interface pause_quanta_sink avalon_streaming end
set_interface_property pause_quanta_sink associatedClock clock_reset
set_interface_property pause_quanta_sink dataBitsPerSymbol 16
set_interface_property pause_quanta_sink symbolsPerBeat 1
set_interface_property pause_quanta_sink errorDescriptor ""
set_interface_property pause_quanta_sink maxChannel 0
set_interface_property pause_quanta_sink readyLatency 0

set_interface_property pause_quanta_sink ENABLED true

add_interface_port pause_quanta_sink pause_quanta_sink_valid valid Input 1
add_interface_port pause_quanta_sink pause_quanta_sink_data data Input 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pause_beat_src
# | 
add_interface pause_beat_src avalon_streaming start
set_interface_property pause_beat_src associatedClock clock_reset
set_interface_property pause_beat_src dataBitsPerSymbol 32
set_interface_property pause_beat_src symbolsPerBeat 1
set_interface_property pause_beat_src errorDescriptor ""
set_interface_property pause_beat_src maxChannel 0
set_interface_property pause_beat_src readyLatency 0

set_interface_property pause_beat_src ENABLED true

add_interface_port pause_beat_src pause_beat_src_valid valid Output 1
add_interface_port pause_beat_src pause_beat_src_data data Output 32
# | 
# +-----------------------------------

proc elaborate {} {
    set GET_MAC_1G10G_ENA 						    [ get_parameter_value GET_MAC_1G10G_ENA ]
    
    if {$GET_MAC_1G10G_ENA == 1} {
        # 
        # connection point sel
        # 
        add_interface "mode_1g_10gbar" conduit end
        set_interface_property "mode_1g_10gbar" ENABLED true
        add_interface_port "mode_1g_10gbar" mode_1g_10gbar export Input 2
        # 
    } else {
        add_interface "mode_1g_10gbar" conduit end
        #set_interface_property "mode_1g_10gbar" ENABLED true
        add_interface_port "mode_1g_10gbar" mode_1g_10gbar export Input 2
        set_port_property mode_1g_10gbar DRIVEN_BY 0
        set_port_property mode_1g_10gbar TERMINATION true
        set_port_property mode_1g_10gbar TERMINATION_VALUE 0 
    }
    
}
    
