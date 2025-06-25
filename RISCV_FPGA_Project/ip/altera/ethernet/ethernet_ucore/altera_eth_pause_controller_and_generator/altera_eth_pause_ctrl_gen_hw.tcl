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
# | module Ethernet_Pause_Controller_and_Generator
# | 
set_module_property NAME altera_eth_pause_ctrl_gen
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property DESCRIPTION "Altera Ethernet Pause Controller and Generator"
set_module_property DISPLAY_NAME "Ethernet Pause Controller and Generator"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_pause_ctrl_gen.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_pause_ctrl_gen
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
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
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_pause_ctrl_gen

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_ctrl_gen.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_controller.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_gen.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_ctrl_gen.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_controller.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_gen.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_ctrl_gen.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_controller.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_gen.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_ctrl_gen.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_controller.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_gen.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
        add_fileset_file mentor/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_ctrl_gen.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_controller.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pause_gen.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_ctrl_gen.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_controller.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pause_gen.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_ctrl_gen.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_controller.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pause_gen.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pause_ctrl_gen.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_ctrl_gen.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pause_controller.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_controller.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pause_gen.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pause_gen.v" {SYNOPSYS_SPECIFIC}
    }
}


proc elaborate {} {

  set symbols_per_beat 8
  set error_width 1
  set bits_per_symbol 8

  set_interface_property pause_packet dataBitsPerSymbol $bits_per_symbol
  set_interface_property pause_packet symbolsPerBeat $symbols_per_beat
 	
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property pause_source_data WIDTH $data_width
  
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  if {$empty_width > 0} {
    set_port_property pause_source_empty WIDTH $empty_width
  } else {
    set_port_property pause_source_empty WIDTH 1
    set_port_property pause_source_empty TERMINATION true
  }
   
  if {$error_width > 0} {
    set_port_property pause_source_error WIDTH $error_width
  } else {
    set_port_property pause_source_error WIDTH 1
    set_port_property pause_source_error TERMINATION true
  }
  set_port_property pause_source_error VHDL_TYPE STD_LOGIC_VECTOR
    
}

# +-----------------------------------
# | files
# | 
add_file altera_eth_pause_controller.v {SYNTHESIS}
add_file altera_eth_pause_ctrl_gen.v {SYNTHESIS}
add_file altera_eth_pause_ctrl_gen.ocp {SYNTHESIS}
add_file altera_eth_pause_gen.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter BITSPERSYMBOL INTEGER 8
set_parameter_property BITSPERSYMBOL DEFAULT_VALUE 8
set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
set_parameter_property BITSPERSYMBOL TYPE INTEGER
set_parameter_property BITSPERSYMBOL ENABLED false
set_parameter_property BITSPERSYMBOL UNITS None
set_parameter_property BITSPERSYMBOL DISPLAY_HINT ""
set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
set_parameter_property BITSPERSYMBOL HDL_PARAMETER true

add_parameter SYMBOLSPERBEAT INTEGER 8
set_parameter_property SYMBOLSPERBEAT DEFAULT_VALUE 8
set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property SYMBOLSPERBEAT TYPE INTEGER
set_parameter_property SYMBOLSPERBEAT ENABLED false
set_parameter_property SYMBOLSPERBEAT UNITS None
set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLSPERBEAT HDL_PARAMETER true

add_parameter ERROR_WIDTH INTEGER 1
set_parameter_property ERROR_WIDTH DEFAULT_VALUE 1
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH TYPE INTEGER
set_parameter_property ERROR_WIDTH ENABLED false
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH HDL_PARAMETER true
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
# | connection point csr_reset
# |
add_interface csr_reset reset end
set_interface_property csr_reset associatedClock clock_reset
set_interface_property csr_reset synchronousEdges DEASSERT
set_interface_property csr_reset ENABLED true
add_interface_port csr_reset csr_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr
# | 
add_interface csr avalon end
set_interface_property csr addressAlignment DYNAMIC
set_interface_property csr associatedClock clock_reset
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr explicitAddressSpan 0
set_interface_property csr holdTime 0
set_interface_property csr isMemoryDevice false
set_interface_property csr isNonVolatileStorage false
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr printableDevice false
set_interface_property csr readLatency 1
set_interface_property csr readWaitTime 0
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0

set_interface_property csr ASSOCIATED_CLOCK clock_reset
set_interface_property csr ENABLED true

add_interface_port csr csr_address address Input 2
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_writedata writedata Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pause_control
# | 
add_interface pause_control avalon_streaming end
set_interface_property pause_control associatedClock clock_reset
set_interface_property pause_control dataBitsPerSymbol 2
set_interface_property pause_control errorDescriptor ""
set_interface_property pause_control maxChannel 0
set_interface_property pause_control readyLatency 0
set_interface_property pause_control symbolsPerBeat 1

set_interface_property pause_control ASSOCIATED_CLOCK clock_reset
set_interface_property pause_control ENABLED true

add_interface_port pause_control pause_ctrl_sink_data data Input 2
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pause_packet
# | 
add_interface pause_packet avalon_streaming start
set_interface_property pause_packet associatedClock clock_reset
set_interface_property pause_packet dataBitsPerSymbol 8
set_interface_property pause_packet errorDescriptor ""
set_interface_property pause_packet maxChannel 0
set_interface_property pause_packet readyLatency 0
set_interface_property pause_control symbolsPerBeat 8

set_interface_property pause_packet ASSOCIATED_CLOCK clock_reset
set_interface_property pause_packet ENABLED true

add_interface_port pause_packet pause_source_sop startofpacket Output 1
add_interface_port pause_packet pause_source_eop endofpacket Output 1
add_interface_port pause_packet pause_source_valid valid Output 1
add_interface_port pause_packet pause_source_data data Output 1
add_interface_port pause_packet pause_source_empty empty Output 1
add_interface_port pause_packet pause_source_error error Output 1
add_interface_port pause_packet pause_source_ready ready Input 1
# | 
# +-----------------------------------
