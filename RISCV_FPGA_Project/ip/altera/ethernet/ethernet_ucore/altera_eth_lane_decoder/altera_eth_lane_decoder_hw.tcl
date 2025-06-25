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
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_lane_decoder
# | 
set_module_property DESCRIPTION "Altera Eth Lane Decoder"
set_module_property NAME altera_eth_lane_decoder
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property DISPLAY_NAME "Ethernet Lane Decoder"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_lane_decoder.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_lane_decoder
set_module_property ELABORATION_CALLBACK elaborate
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
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
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_lane_decoder

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "mentor/altera_eth_lane_decoder.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "aldec/altera_eth_lane_decoder.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "cadence/altera_eth_lane_decoder.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_lane_decoder.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
      add_fileset_file mentor/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "mentor/altera_eth_lane_decoder.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "aldec/altera_eth_lane_decoder.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "cadence/altera_eth_lane_decoder.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_eth_lane_decoder.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_lane_decoder.v" {SYNOPSYS_SPECIFIC}
   }
}


add_parameter PREAMBLE_MODE INTEGER 0 "PREAMBLE_MODE"
set_parameter_property PREAMBLE_MODE DISPLAY_NAME PREAMBLE_MODE
set_parameter_property PREAMBLE_MODE UNITS None
set_parameter_property PREAMBLE_MODE ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PREAMBLE_MODE DISPLAY_HINT boolean
set_parameter_property PREAMBLE_MODE AFFECTS_GENERATION false
set_parameter_property PREAMBLE_MODE HDL_PARAMETER false

# +-----------------------------------
# | files
# | 
add_file altera_eth_lane_decoder.v {SYNTHESIS}
add_file altera_eth_lane_decoder.ocp {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
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
# | connection point avalon_streaming_sink
# | 
add_interface avalon_streaming_sink avalon_streaming end
set_interface_property avalon_streaming_sink dataBitsPerSymbol 9
set_interface_property avalon_streaming_sink errorDescriptor ""
set_interface_property avalon_streaming_sink maxChannel 0
set_interface_property avalon_streaming_sink readyLatency 0
set_interface_property avalon_streaming_sink symbolsPerBeat 8

set_interface_property avalon_streaming_sink ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_sink ENABLED true

add_interface_port avalon_streaming_sink xgmii_sink_data data Input 72
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# | 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source dataBitsPerSymbol 8
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 0
set_interface_property avalon_streaming_source symbolsPerBeat 8

set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_source ENABLED true

add_interface_port avalon_streaming_source rxdata_src_eop endofpacket Output 1
add_interface_port avalon_streaming_source rxdata_src_sop startofpacket Output 1
add_interface_port avalon_streaming_source rxdata_src_valid valid Output 1
add_interface_port avalon_streaming_source rxdata_src_data data Output 64
add_interface_port avalon_streaming_source rxdata_src_empty empty Output 3
add_interface_port avalon_streaming_source rxdata_src_error error Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point csr
# | 
add_interface csr avalon end
set_interface_property csr addressAlignment DYNAMIC
set_interface_property csr bridgesToMaster ""
set_interface_property csr burstOnBurstBoundariesOnly false
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

add_interface_port csr csr_read read Input 1
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_address address Input 1
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_readdata readdata Output 32

# +-----------------------------------
# | connection point preamble_src
# | 
add_interface preamble_src avalon_streaming start
set_interface_property preamble_src associatedClock clock_reset
#set_interface_property preamble_src associatedReset reset
set_interface_property preamble_src dataBitsPerSymbol 8
set_interface_property preamble_src symbolsPerBeat 8
set_interface_property preamble_src errorDescriptor ""
set_interface_property preamble_src maxChannel 0
set_interface_property preamble_src readyLatency 0

set_interface_property preamble_src ENABLED true

add_interface_port preamble_src preamble_valid valid Output 1
add_interface_port preamble_src preamble_bytes data Output 64
# | 
# +-----------------------------------

proc elaborate {} {
	set PREAMBLE_MODE [ get_parameter_value PREAMBLE_MODE ]
	
	
	if {$PREAMBLE_MODE == 0} {
		set_port_property  preamble_valid TERMINATION true
		set_port_property  preamble_valid TERMINATION_VALUE 0 
		
		set_port_property  preamble_bytes TERMINATION true
		set_port_property  preamble_bytes TERMINATION_VALUE 0
	} else {
		
	}
    set_port_property rxdata_src_error VHDL_TYPE STD_LOGIC_VECTOR

}
