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
# | module altera_eth_xgmii_termination
# | 
set_module_property DESCRIPTION "Altera Ethernet XGMII Termination"
set_module_property NAME altera_eth_xgmii_termination
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet XGMII Termination"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_xgmii_termination.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_xgmii_termination
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_xgmii_termination

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_termination.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_termination.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_termination.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_termination.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "mentor/altera_eth_xgmii_termination.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "aldec/altera_eth_xgmii_termination.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "cadence/altera_eth_xgmii_termination.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_xgmii_termination.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_xgmii_termination.v" {SYNOPSYS_SPECIFIC}
   }
}



# +-----------------------------------
# | files
# | 
add_file altera_eth_xgmii_termination.v {SYNTHESIS}
add_file altera_eth_xgmii_termination.ocp {SYNTHESIS}
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
# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# | 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source associatedClock clock_reset
set_interface_property avalon_streaming_source dataBitsPerSymbol 9
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 0

set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_source ENABLED true

add_interface_port avalon_streaming_source xgmii_src_data data Output 72
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink
# | 
add_interface avalon_streaming_sink avalon_streaming end
set_interface_property avalon_streaming_sink associatedClock clock_reset
set_interface_property avalon_streaming_sink dataBitsPerSymbol 9
set_interface_property avalon_streaming_sink errorDescriptor ""
set_interface_property avalon_streaming_sink maxChannel 0
set_interface_property avalon_streaming_sink readyLatency 0

set_interface_property avalon_streaming_sink ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_sink ENABLED true

add_interface_port avalon_streaming_sink data_sink_sop startofpacket Input 1
add_interface_port avalon_streaming_sink data_sink_eop endofpacket Input 1
add_interface_port avalon_streaming_sink data_sink_valid valid Input 1
add_interface_port avalon_streaming_sink data_sink_data data Input 72
add_interface_port avalon_streaming_sink data_sink_empty empty Input 3
add_interface_port avalon_streaming_sink data_sink_ready ready Output 1
# | 
# +-----------------------------------
