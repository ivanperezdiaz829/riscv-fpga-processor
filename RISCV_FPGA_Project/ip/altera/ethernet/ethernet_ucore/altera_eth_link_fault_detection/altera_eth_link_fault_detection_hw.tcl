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



# Ensure this component works in 9.1 environment
#---------------------------------------------------------------------
package require -exact sopc 10.0


# Module settings
#---------------------------------------------------------------------
set_module_property DESCRIPTION "Altera Ethernet Link Fault Detection"
set_module_property NAME altera_eth_link_fault_detection
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property DISPLAY_NAME "Ethernet Link Fault Detection"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_link_fault_detection.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_link_fault_detection
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_link_fault_detection

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "mentor/altera_eth_link_fault_detection.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "aldec/altera_eth_link_fault_detection.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "cadence/altera_eth_link_fault_detection.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_link_fault_detection.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "mentor/altera_eth_link_fault_detection.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "aldec/altera_eth_link_fault_detection.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "cadence/altera_eth_link_fault_detection.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_link_fault_detection.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_link_fault_detection.v" {SYNOPSYS_SPECIFIC}
   }
}


# Files
#---------------------------------------------------------------------
add_file altera_eth_link_fault_detection.v {SYNTHESIS}
add_file altera_eth_link_fault_detection.ocp {SYNTHESIS}

# Parameters Default Values
#---------------------------------------------------------------------
set MII_SYMBOLSPERBEAT_VALUE                    8
set MII_SYMBOLSPERCOLUMN_VALUE                  4


# Constants
#---------------------------------------------------------------------
set MII_BITSPERSYMBOLS_VALUE                    9

set LINK_FAULT_BITSPERSYMBOLS_VALUE             2
set LINK_FAULT_SYMBOLSPERBEAT_VALUE             1



#  Avalon Slave 
#---------------------------------------------------------------------
# N/A



#  Avalon Streaming Sink
#---------------------------------------------------------------------
# N/A



#  Avalon Streaming Source
#---------------------------------------------------------------------
# N/A





set CLOCK_INTERFACE                             "clk"
set MII_SINK_INTERFACE                          "mii_sink"
set LINK_FAULT_SRC_INTERFACE                    "link_fault_src"


# connection point - clock
#---------------------------------------------------------------------
add_interface       $CLOCK_INTERFACE clock sink
add_interface_port  $CLOCK_INTERFACE clk clk Input 1
add_interface_port  $CLOCK_INTERFACE reset reset Input 1

# connection point - streamin clock
#---------------------------------------------------------------------
# N/A


#  Avalon Slave connection point 
#---------------------------------------------------------------------
# N/A

#  Avalon Streaming Sink connection point 
#---------------------------------------------------------------------
add_interface $MII_SINK_INTERFACE avalon_streaming sink
set_interface_property $MII_SINK_INTERFACE ENABLED true
set_interface_property $MII_SINK_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
set_interface_property $MII_SINK_INTERFACE dataBitsPerSymbol $MII_BITSPERSYMBOLS_VALUE
set_interface_property $MII_SINK_INTERFACE errorDescriptor ""
set_interface_property $MII_SINK_INTERFACE maxChannel 0
set_interface_property $MII_SINK_INTERFACE readyLatency 0
set_interface_property $MII_SINK_INTERFACE symbolsPerBeat $MII_SYMBOLSPERBEAT_VALUE

add_interface_port $MII_SINK_INTERFACE mii_sink_data data Input [expr {$MII_BITSPERSYMBOLS_VALUE * $MII_SYMBOLSPERBEAT_VALUE }]



#  Avalon Streaming Source connection point 
#---------------------------------------------------------------------
add_interface $LINK_FAULT_SRC_INTERFACE avalon_streaming source
set_interface_property $LINK_FAULT_SRC_INTERFACE ENABLED true
set_interface_property $LINK_FAULT_SRC_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
set_interface_property $LINK_FAULT_SRC_INTERFACE dataBitsPerSymbol $LINK_FAULT_BITSPERSYMBOLS_VALUE
set_interface_property $LINK_FAULT_SRC_INTERFACE errorDescriptor ""
set_interface_property $LINK_FAULT_SRC_INTERFACE maxChannel 0
set_interface_property $LINK_FAULT_SRC_INTERFACE readyLatency 0
set_interface_property $LINK_FAULT_SRC_INTERFACE symbolsPerBeat $LINK_FAULT_SYMBOLSPERBEAT_VALUE

add_interface_port $LINK_FAULT_SRC_INTERFACE link_fault_src_data data Output [expr {$LINK_FAULT_BITSPERSYMBOLS_VALUE * $LINK_FAULT_SYMBOLSPERBEAT_VALUE }]
