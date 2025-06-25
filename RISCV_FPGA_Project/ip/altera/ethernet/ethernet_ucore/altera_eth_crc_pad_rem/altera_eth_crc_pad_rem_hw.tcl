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
# | module altera_eth_crc_pad_rem
# | 
set_module_property DESCRIPTION "Ethernet CRC PAD Remover"
set_module_property NAME altera_eth_crc_pad_rem
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property DISPLAY_NAME "Ethernet CRC PAD Remover"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_crc_pad_rem.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_crc_pad_rem
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
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
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_crc_pad_rem

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc_pad_rem.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc_rem.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_packet_stripper.v VERILOG_ENCRYPT PATH "mentor/altera_packet_stripper.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc_pad_rem.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc_rem.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_packet_stripper.v VERILOG_ENCRYPT PATH "aldec/altera_packet_stripper.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc_pad_rem.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc_rem.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_packet_stripper.v VERILOG_ENCRYPT PATH "cadence/altera_packet_stripper.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc_pad_rem.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc_rem.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_packet_stripper.v VERILOG_ENCRYPT PATH "synopsys/altera_packet_stripper.v" {SYNOPSYS_SPECIFIC}       
    }
    add_fileset_file altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv"
    add_fileset_file altera_avalon_st_pipeline_base.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v"
}

proc sim_vhd {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc_pad_rem.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "mentor/altera_eth_crc_rem.v" {MENTOR_SPECIFIC}
        add_fileset_file mentor/altera_packet_stripper.v VERILOG_ENCRYPT PATH "mentor/altera_packet_stripper.v" {MENTOR_SPECIFIC}
	add_fileset_file mentor/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_base.v" {MENTOR_SPECIFIC}
	add_fileset_file mentor/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_stage.sv" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc_pad_rem.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "aldec/altera_eth_crc_rem.v" {ALDEC_SPECIFIC}
        add_fileset_file aldec/altera_packet_stripper.v VERILOG_ENCRYPT PATH "aldec/altera_packet_stripper.v" {ALDEC_SPECIFIC}
	add_fileset_file aldec/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_base.v" {ALDEC__SPECIFIC}
	add_fileset_file aldec/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_stage.sv" {ALDEC__SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc_pad_rem.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "cadence/altera_eth_crc_rem.v" {CADENCE_SPECIFIC}
        add_fileset_file cadence/altera_packet_stripper.v VERILOG_ENCRYPT PATH "cadence/altera_packet_stripper.v" {CADENCE_SPECIFIC}
	add_fileset_file cadence/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_base.v" {CADENCE_SPECIFIC}
	add_fileset_file cadence/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_stage.sv" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_crc_pad_rem.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc_pad_rem.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_eth_crc_rem.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_crc_rem.v" {SYNOPSYS_SPECIFIC}
        add_fileset_file synopsys/altera_packet_stripper.v VERILOG_ENCRYPT PATH "synopsys/altera_packet_stripper.v" {SYNOPSYS_SPECIFIC}   
	add_fileset_file synopsys/altera_avalon_st_pipeline_base.v VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/synopsys/altera_avalon_st_pipeline_base.v" {SYNOPSYS_SPECIFIC}   
	add_fileset_file synopsys/altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG_ENCRYPT PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/synopsys/altera_avalon_st_pipeline_stage.sv" {SYNOPSYS_SPECIFIC}   
    }
}




# | Callbacks
# | 

# Utility routines
proc _get_empty_width {} {
  set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  return $empty_width
}

proc validate {} {
  # Calculate the required payload data width for the altera_avalon_st_pipeline_base
  # instance.  (The spec requires <= 256.)
  set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  if { $data_width < 1 } {
    send_message error "Data Width less than 1 is not supported (SYMBOLS_PER_BEAT: $symbols_per_beat; BITS_PER_SYMBOL: $bits_per_symbol)"
  }
}
  

proc elaborate {} {
  set symbols_per_beat [ get_parameter_value SYMBOLSPERBEAT ]
  set bits_per_symbol [ get_parameter_value BITSPERSYMBOL ]
  set error_width [ get_parameter_value ERRORWIDTH ]
  
  set_interface_property avalon_streaming_sink_data dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_streaming_sink_data symbolsPerBeat $symbols_per_beat
  set_interface_property avalon_streaming_source_data dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_streaming_source_data symbolsPerBeat $symbols_per_beat
  
  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set_port_property data_sink_data WIDTH $data_width
  set_port_property data_source_data WIDTH $data_width
  
  set empty_width [ _get_empty_width ]
  set_port_property data_sink_empty WIDTH $empty_width
  set_port_property data_source_empty WIDTH $empty_width

  
  set error_width [ get_parameter_value ERRORWIDTH ]
  if {$error_width > 0} {
    set_port_property data_sink_error WIDTH $error_width
    set_port_property data_source_error WIDTH $error_width
  } else {
    set_port_property data_sink_error WIDTH 1
    set_port_property data_source_error WIDTH 1
  }
  
  set_port_property status_sink_data WIDTH 23
 
}
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_eth_crc_pad_rem.v {SYNTHESIS}
add_file altera_eth_crc_pad_rem.ocp {SYNTHESIS}
add_file altera_eth_crc_rem.v {SYNTHESIS}
add_file altera_packet_stripper.v {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v {SYNTHESIS}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter BITSPERSYMBOL INTEGER 8
set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
set_parameter_property BITSPERSYMBOL ENABLED true
set_parameter_property BITSPERSYMBOL UNITS None
set_parameter_property BITSPERSYMBOL ALLOWED_RANGES 1:256
set_parameter_property BITSPERSYMBOL DESCRIPTION ""
set_parameter_property BITSPERSYMBOL DISPLAY_HINT ""
set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
set_parameter_property BITSPERSYMBOL IS_HDL_PARAMETER true

add_parameter SYMBOLSPERBEAT INTEGER 8
set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property SYMBOLSPERBEAT ENABLED true
set_parameter_property SYMBOLSPERBEAT UNITS None
set_parameter_property SYMBOLSPERBEAT ALLOWED_RANGES 1:256
set_parameter_property SYMBOLSPERBEAT DESCRIPTION ""
set_parameter_property SYMBOLSPERBEAT DISPLAY_HINT ""
set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
set_parameter_property SYMBOLSPERBEAT IS_HDL_PARAMETER true

add_parameter ERRORWIDTH INTEGER 5
set_parameter_property ERRORWIDTH DISPLAY_NAME ERRORWIDTH
set_parameter_property ERRORWIDTH ENABLED true
set_parameter_property ERRORWIDTH UNITS None
set_parameter_property ERRORWIDTH ALLOWED_RANGES 1:256
set_parameter_property ERRORWIDTH DESCRIPTION ""
set_parameter_property ERRORWIDTH DISPLAY_HINT ""
set_parameter_property ERRORWIDTH AFFECTS_GENERATION false
set_parameter_property ERRORWIDTH IS_HDL_PARAMETER true
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

add_interface_port csr csr_read read Input 1
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_address address Input 2
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink_data
# | 
add_interface avalon_streaming_sink_data avalon_streaming end
set_interface_property avalon_streaming_sink_data dataBitsPerSymbol 8
set_interface_property avalon_streaming_sink_data errorDescriptor ""
set_interface_property avalon_streaming_sink_data maxChannel 0
set_interface_property avalon_streaming_sink_data readyLatency 0
set_interface_property avalon_streaming_sink_data symbolsPerBeat 8

set_interface_property avalon_streaming_sink_data ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_sink_data ENABLED true

add_interface_port avalon_streaming_sink_data data_sink_sop startofpacket Input 1
add_interface_port avalon_streaming_sink_data data_sink_eop endofpacket Input 1
add_interface_port avalon_streaming_sink_data data_sink_valid valid Input 1
add_interface_port avalon_streaming_sink_data data_sink_data data Input 32
add_interface_port avalon_streaming_sink_data data_sink_empty empty Input 4
add_interface_port avalon_streaming_sink_data data_sink_error error Input 5
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink_status
# | 
add_interface avalon_streaming_sink_status avalon_streaming end
set_interface_property avalon_streaming_sink_status dataBitsPerSymbol 23
set_interface_property avalon_streaming_sink_status errorDescriptor ""
set_interface_property avalon_streaming_sink_status maxChannel 0
set_interface_property avalon_streaming_sink_status readyLatency 0
set_interface_property avalon_streaming_sink_status symbolsPerBeat 1

set_interface_property avalon_streaming_sink_status ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_sink_status ENABLED true

add_interface_port avalon_streaming_sink_status status_sink_valid valid Input 1
add_interface_port avalon_streaming_sink_status status_sink_data data Input 23
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source_data
# | 
add_interface avalon_streaming_source_data avalon_streaming start
set_interface_property avalon_streaming_source_data dataBitsPerSymbol 8
set_interface_property avalon_streaming_source_data errorDescriptor ""
set_interface_property avalon_streaming_source_data maxChannel 0
set_interface_property avalon_streaming_source_data readyLatency 0
set_interface_property avalon_streaming_source_data symbolsPerBeat 8

set_interface_property avalon_streaming_source_data ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_source_data ENABLED true

add_interface_port avalon_streaming_source_data data_source_sop startofpacket Output 1
add_interface_port avalon_streaming_source_data data_source_eop endofpacket Output 1
add_interface_port avalon_streaming_source_data data_source_valid valid Output 1
add_interface_port avalon_streaming_source_data data_source_data data Output 64
add_interface_port avalon_streaming_source_data data_source_empty empty Output 4
add_interface_port avalon_streaming_source_data data_source_error error Output 5
# | 
# +-----------------------------------
