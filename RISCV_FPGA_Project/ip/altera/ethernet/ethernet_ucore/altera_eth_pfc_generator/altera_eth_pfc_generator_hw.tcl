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
# | module altera_eth_pfc_generator
# | 
set_module_property NAME altera_eth_pfc_generator
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property DESCRIPTION "Altera Ethernet PFC Generator"
set_module_property DISPLAY_NAME "Ethernet PFC Generator"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_pfc_generator.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_pfc_generator
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
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_pfc_generator

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pfc_generator.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pfc_generator_qfsm.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pfc_generator.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pfc_generator_qfsm.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pfc_generator.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pfc_generator_qfsm.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pfc_generator.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pfc_generator_qfsm.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pfc_generator.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "mentor/altera_eth_pfc_generator_qfsm.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pfc_generator.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "aldec/altera_eth_pfc_generator_qfsm.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pfc_generator.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "cadence/altera_eth_pfc_generator_qfsm.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_pfc_generator.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pfc_generator.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_pfc_generator_qfsm.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_pfc_generator_qfsm.v" {SYNOPSYS_SPECIFIC}
    }
}



proc elaborate {} {
  
  set symbols_per_beat 8
  set error_width 1
  set bits_per_symbol 8

  set_interface_property pfc_data_src dataBitsPerSymbol $bits_per_symbol
  set_interface_property pfc_data_src symbolsPerBeat $symbols_per_beat
  
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property pfc_data_src_data WIDTH $data_width
  
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  if {$empty_width > 0} {
    set_port_property pfc_data_src_empty WIDTH $empty_width
  } else {
    set_port_property pfc_data_src_empty WIDTH 1
    set_port_property pfc_data_src_empty TERMINATION true
  }
   
  if {$error_width > 0} {
    set_port_property pfc_data_src_error WIDTH $error_width
  } else {
    set_port_property pfc_data_src_error WIDTH 1
    set_port_property pfc_data_src_error TERMINATION true
  }
  
  
  
  set pfc_priority_num [ get_parameter_value PFC_PRIORITY_NUM ]
  
  set_interface_property pfc_ctrl_sink dataBitsPerSymbol [ expr 2 * $pfc_priority_num ]
  set_interface_property pfc_status_src dataBitsPerSymbol [ expr 2 * $pfc_priority_num ]
  
  set_port_property pfc_ctrl_sink_data WIDTH [ expr 2 * $pfc_priority_num ]
  set_port_property pfc_status_src_data WIDTH [ expr 2 * $pfc_priority_num ]
  
}

# +-----------------------------------
# | files
# | 
add_file altera_eth_pfc_generator.v {SYNTHESIS}
add_file altera_eth_pfc_generator_qfsm.v {SYNTHESIS}
add_file altera_eth_pfc_generator.ocp {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter PFC_PRIORITY_NUM INTEGER 8
set_parameter_property PFC_PRIORITY_NUM DEFAULT_VALUE 8
set_parameter_property PFC_PRIORITY_NUM DISPLAY_NAME PFC_PRIORITY_NUM
set_parameter_property PFC_PRIORITY_NUM TYPE INTEGER
set_parameter_property PFC_PRIORITY_NUM ENABLED true
set_parameter_property PFC_PRIORITY_NUM UNITS None
set_parameter_property PFC_PRIORITY_NUM DISPLAY_HINT ""
set_parameter_property PFC_PRIORITY_NUM AFFECTS_GENERATION false
set_parameter_property PFC_PRIORITY_NUM HDL_PARAMETER true

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

add_interface_port csr csr_address address Input 6
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_writedata writedata Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pfc_ctrl_sink
# | 
add_interface pfc_ctrl_sink avalon_streaming end
set_interface_property pfc_ctrl_sink associatedClock clock_reset
set_interface_property pfc_ctrl_sink dataBitsPerSymbol 16
set_interface_property pfc_ctrl_sink errorDescriptor ""
set_interface_property pfc_ctrl_sink maxChannel 0
set_interface_property pfc_ctrl_sink readyLatency 0
set_interface_property pfc_ctrl_sink symbolsPerBeat 1

set_interface_property pfc_ctrl_sink ASSOCIATED_CLOCK clock_reset
set_interface_property pfc_ctrl_sink ENABLED true

add_interface_port pfc_ctrl_sink pfc_ctrl_sink_data data Input 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pfc_status_src
# | 
add_interface pfc_status_src avalon_streaming start
set_interface_property pfc_status_src associatedClock clock_reset
set_interface_property pfc_status_src dataBitsPerSymbol 16
set_interface_property pfc_status_src errorDescriptor ""
set_interface_property pfc_status_src maxChannel 0
set_interface_property pfc_status_src readyLatency 0
set_interface_property pfc_status_src symbolsPerBeat 1

set_interface_property pfc_status_src ASSOCIATED_CLOCK clock_reset
set_interface_property pfc_status_src ENABLED true

add_interface_port pfc_status_src pfc_status_src_valid valid Output 1
add_interface_port pfc_status_src pfc_status_src_data data Output 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pfc_data_src
# | 
add_interface pfc_data_src avalon_streaming start
set_interface_property pfc_data_src associatedClock clock_reset
set_interface_property pfc_data_src dataBitsPerSymbol 8
set_interface_property pfc_data_src errorDescriptor ""
set_interface_property pfc_data_src maxChannel 0
set_interface_property pfc_data_src readyLatency 0
set_interface_property pfc_data_src symbolsPerBeat 8

set_interface_property pfc_data_src ASSOCIATED_CLOCK clock_reset
set_interface_property pfc_data_src ENABLED true

add_interface_port pfc_data_src pfc_data_src_sop startofpacket Output 1
add_interface_port pfc_data_src pfc_data_src_eop endofpacket Output 1
add_interface_port pfc_data_src pfc_data_src_valid valid Output 1
add_interface_port pfc_data_src pfc_data_src_data data Output 1
add_interface_port pfc_data_src pfc_data_src_empty empty Output 1
add_interface_port pfc_data_src pfc_data_src_error error Output 1
add_interface_port pfc_data_src pfc_data_src_ready ready Input 1
# | 
# +-----------------------------------
