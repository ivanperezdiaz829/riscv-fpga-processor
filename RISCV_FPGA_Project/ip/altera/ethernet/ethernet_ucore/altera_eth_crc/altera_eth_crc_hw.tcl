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
# | module altera_eth_crc
# | 
set_module_property DESCRIPTION "Altera Ethernet CRC"
set_module_property NAME altera_eth_crc
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet CRC"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_crc.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_crc
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_crc.v {SYNTHESIS}
add_file altera_eth_crc.ocp {SYNTHESIS}
add_file crc32.v {SYNTHESIS}
add_file gf_mult32_kc.v {SYNTHESIS}
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
set HDL_LIB_DIR "../lib"

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_crc

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_crc.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/crc32.v VERILOG_ENCRYPT PATH "mentor/crc32.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/gf_mult32_kc.v VERILOG_ENCRYPT PATH "mentor/gf_mult32_kc.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_crc.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/crc32.v VERILOG_ENCRYPT PATH "aldec/crc32.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/gf_mult32_kc.v VERILOG_ENCRYPT PATH "aldec/gf_mult32_kc.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_crc.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/crc32.v VERILOG_ENCRYPT PATH "cadence/crc32.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/gf_mult32_kc.v VERILOG_ENCRYPT PATH "cadence/gf_mult32_kc.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_crc.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/crc32.v VERILOG_ENCRYPT PATH "synopsys/crc32.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/gf_mult32_kc.v VERILOG_ENCRYPT PATH "synopsys/gf_mult32_kc.v" {SYNOPSYS_SPECIFIC}
    }
}

proc sim_vhd {name} {
   if {1} {
        add_fileset_file mentor/altera_eth_crc.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/crc32.v VERILOG_ENCRYPT PATH "mentor/crc32.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/gf_mult32_kc.v VERILOG_ENCRYPT PATH "mentor/gf_mult32_kc.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_crc.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/crc32.v VERILOG_ENCRYPT PATH "aldec/crc32.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/gf_mult32_kc.v VERILOG_ENCRYPT PATH "aldec/gf_mult32_kc.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_crc.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/crc32.v VERILOG_ENCRYPT PATH "cadence/crc32.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/gf_mult32_kc.v VERILOG_ENCRYPT PATH "cadence/gf_mult32_kc.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_crc.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/crc32.v VERILOG_ENCRYPT PATH "synopsys/crc32.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/gf_mult32_kc.v VERILOG_ENCRYPT PATH "synopsys/gf_mult32_kc.v" {SYNOPSYS_SPECIFIC}
    }
}


# +-----------------------------------
# | parameters
# | 
add_parameter BITSPERSYMBOL INTEGER 8 "Ethernet is a byte oriented."
set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
set_parameter_property BITSPERSYMBOL ENABLED false
set_parameter_property BITSPERSYMBOL UNITS None
set_parameter_property BITSPERSYMBOL ALLOWED_RANGES -2147483648:2147483647
set_parameter_property BITSPERSYMBOL DESCRIPTION "Ethernet is a byte oriented."
set_parameter_property BITSPERSYMBOL DISPLAY_HINT ""
set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
set_parameter_property BITSPERSYMBOL HDL_PARAMETER true

add_parameter SYMBOLSPERBEAT INTEGER 8 "Ethernet 10G width is 64 bits."
set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property SYMBOLSPERBEAT ENABLED false
set_parameter_property SYMBOLSPERBEAT UNITS None
set_parameter_property SYMBOLSPERBEAT ALLOWED_RANGES -2147483648:2147483647
set_parameter_property SYMBOLSPERBEAT DESCRIPTION "Ethernet 10G width is 64 bits."
set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLSPERBEAT HDL_PARAMETER true

add_parameter ERROR_WIDTH INTEGER 2 "Error size to sink interface."
set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ERROR_WIDTH DESCRIPTION "Error size to sink interface."
set_parameter_property ERROR_WIDTH DISPLAY_HINT ""
set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
set_parameter_property ERROR_WIDTH HDL_PARAMETER true

add_parameter MODE_CHECKER_0_INSERTER_1 INTEGER 1 "Inserter/Transmit Checker/Receive"
set_parameter_property MODE_CHECKER_0_INSERTER_1 DISPLAY_NAME MODE_CHECKER_0_INSERTER_1
set_parameter_property MODE_CHECKER_0_INSERTER_1 UNITS None
set_parameter_property MODE_CHECKER_0_INSERTER_1 ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MODE_CHECKER_0_INSERTER_1 DESCRIPTION "Inserter/Transmit Checker/Receive"
set_parameter_property MODE_CHECKER_0_INSERTER_1 DISPLAY_HINT ""
set_parameter_property MODE_CHECKER_0_INSERTER_1 AFFECTS_GENERATION false
set_parameter_property MODE_CHECKER_0_INSERTER_1 HDL_PARAMETER true

add_parameter USE_CHANNEL INTEGER 0 
set_parameter_property USE_CHANNEL DISPLAY_NAME "Add channel interface "
set_parameter_property USE_CHANNEL DEFAULT_VALUE 0
set_parameter_property USE_CHANNEL DISPLAY_HINT boolean
set_parameter_property USE_CHANNEL DESCRIPTION "Add channel interface "
set_parameter_property USE_CHANNEL AFFECTS_GENERATION false
set_parameter_property USE_CHANNEL HDL_PARAMETER true

add_parameter USE_READY boolean true
set_parameter_property USE_READY DEFAULT_VALUE 1
set_parameter_property USE_READY DISPLAY_NAME USE_READY
set_parameter_property USE_READY UNITS None
set_parameter_property USE_READY DISPLAY_HINT ""
set_parameter_property USE_READY AFFECTS_GENERATION false
set_parameter_property USE_READY HDL_PARAMETER false
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""

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

add_interface_port csr csr_write write Input 1
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_address address Input 1
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink
# | 
add_interface avalon_streaming_sink avalon_streaming end
set_interface_property avalon_streaming_sink dataBitsPerSymbol 8
set_interface_property avalon_streaming_sink errorDescriptor ""
set_interface_property avalon_streaming_sink maxChannel 1
set_interface_property avalon_streaming_sink readyLatency 0
set_interface_property avalon_streaming_sink symbolsPerBeat 8

set_interface_property avalon_streaming_sink ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_sink ENABLED true

add_interface_port avalon_streaming_sink data_sink_sop startofpacket Input 1
add_interface_port avalon_streaming_sink data_sink_eop endofpacket Input 1
add_interface_port avalon_streaming_sink data_sink_valid valid Input 1
add_interface_port avalon_streaming_sink data_sink_ready ready Output 1
add_interface_port avalon_streaming_sink data_sink_data data Input -1
add_interface_port avalon_streaming_sink data_sink_empty empty Input -1
add_interface_port avalon_streaming_sink data_sink_error error Input 1
add_interface_port avalon_streaming_sink data_sink_channel channel Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# | 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source dataBitsPerSymbol 8
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source maxChannel 1
set_interface_property avalon_streaming_source readyLatency 0
set_interface_property avalon_streaming_source symbolsPerBeat 8

set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_source ENABLED true

add_interface_port avalon_streaming_source data_src_sop startofpacket Output 1
add_interface_port avalon_streaming_source data_src_eop endofpacket Output 1
add_interface_port avalon_streaming_source data_src_valid valid Output 1
add_interface_port avalon_streaming_source data_src_ready ready Input 1
add_interface_port avalon_streaming_source data_src_data data Output -1
add_interface_port avalon_streaming_source data_src_empty empty Output -1
add_interface_port avalon_streaming_source data_src_error error Output 2
add_interface_port avalon_streaming_source data_src_channel channel Output 1
# | 
# +-----------------------------------

proc elaborate {} {

  set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set pausebeats_width 32
  set csr_datapath_width 32
  set csr_address_width 1
  set use_ready [ get_parameter_value USE_READY ]
  set use_channel [get_parameter_value USE_CHANNEL]

  set_interface_property avalon_streaming_sink dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_streaming_sink symbolsPerBeat $symbols_per_beat
  set_interface_property avalon_streaming_source dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_streaming_source symbolsPerBeat $symbols_per_beat
 	
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property data_sink_data WIDTH $data_width
  set_port_property data_src_data WIDTH $data_width
  
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  set_port_property data_sink_empty WIDTH $empty_width
  set_port_property data_src_empty WIDTH $empty_width
  
  set_interface_property avalon_streaming_source maxChannel $use_channel
  set_interface_property avalon_streaming_sink maxChannel $use_channel

  set_port_property csr_address WIDTH $csr_address_width 
  set_port_property csr_writedata WIDTH $csr_datapath_width
  set_port_property csr_readdata WIDTH $csr_datapath_width
	
  if {$use_ready} {
    } else {
	set_port_property data_sink_ready TERMINATION_VALUE 1
    set_port_property data_src_ready TERMINATION_VALUE 1
	set_port_property data_sink_ready TERMINATION true
    set_port_property data_src_ready TERMINATION true
  }
  
  if {$use_channel} {
    } else {
	set_port_property data_src_channel TERMINATION_VALUE 1
    set_port_property data_sink_channel TERMINATION_VALUE 1
	set_port_property data_src_channel TERMINATION true
    set_port_property data_sink_channel TERMINATION true
  }
  
  set error_width [ get_parameter_value ERROR_WIDTH ]
  if {$error_width > 0} {
    set_port_property data_sink_error WIDTH $error_width
    set_port_property data_src_error WIDTH [expr $error_width+1 ]
  } else {
    set_port_property data_sink_error WIDTH 1
    set_port_property data_src_error WIDTH 1
    set_port_property data_sink_error TERMINATION true
    set_port_property data_sink_error TERMINATION_VALUE 0
    set_port_property data_src_error TERMINATION true
  }
  set_port_property data_sink_error VHDL_TYPE STD_LOGIC_VECTOR
  set_port_property data_src_error VHDL_TYPE STD_LOGIC_VECTOR
}



