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
# | module altera_eth_timestamp_aligner
# | 
set_module_property DESCRIPTION "Altera Ethernet TIMESTAMP ALIGNER"
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property NAME altera_eth_timestamp_aligner
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property DISPLAY_NAME "Ethernet Timestamp Aligner"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_timestamp_aligner.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_timestamp_aligner
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL false

# | 
# +-----------------------------------

proc _get_empty_width {} {
  set symbols_per_beat 8
  set empty_width [ expr int(ceil(log($symbols_per_beat) / log(2))) ]
  return $empty_width
}

proc elaborate {} {

  set symbols_per_beat 8
  set bits_per_symbol 8
  
  set_interface_property avalon_streaming_source dataBitsPerSymbol $bits_per_symbol
  set_interface_property avalon_streaming_source symbolsPerBeat $symbols_per_beat

  set data_width [ expr $symbols_per_beat * $bits_per_symbol ]
  set empty_width [ _get_empty_width ]
  set error_width 5
  set status_width 40
  set status_error_width 7
  set timestamp_96b_width 96
  set timestamp_64b_width 64


  set_port_property delay_ins_data_sink_data WIDTH $status_width
  set_port_property delay_ins_data_sink_error WIDTH $status_error_width
  
  set_port_property timestamp_96b_sink_data WIDTH $timestamp_96b_width
  set_port_property timestamp_64b_sink_data WIDTH $timestamp_64b_width
  
  set_port_property overflow_control_sink_data_sink_data WIDTH $data_width
  set_port_property overflow_control_sink_data_sink_empty WIDTH $empty_width
  set_port_property overflow_control_sink_data_sink_error WIDTH $error_width
  
  set_port_property overflow_control_src_data_sink_data WIDTH $data_width
  set_port_property overflow_control_src_data_sink_empty WIDTH $empty_width
  set_port_property overflow_control_src_data_sink_error WIDTH $error_width+1
  
  set_port_property data_src_data WIDTH $data_width
  set_port_property data_src_empty WIDTH $empty_width
  set_port_property data_src_error WIDTH $error_width+1
  
  set_port_property rx_ingress_timestamp_96b_src_data WIDTH $timestamp_96b_width
  set_port_property rx_ingress_timestamp_64b_src_data WIDTH $timestamp_64b_width
  
  }
  
  
# +-----------------------------------
# | files
# | 
add_file altera_eth_timestamp_aligner.v {SYNTHESIS}
add_file altera_eth_timestamp_aligner.ocp {SYNTHESIS}
add_file $::env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_sc_fifo/altera_avalon_sc_fifo.v {SYNTHESIS}
# | 
# +-----------------------------------

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_timestamp_aligner

proc sim_ver {name} {
    if {1} {
        add_fileset_file mentor/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "mentor/altera_eth_timestamp_aligner.v" {MENTOR_SPECIFIC}
    }
    if {1} {
        add_fileset_file aldec/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "aldec/altera_eth_timestamp_aligner.v" {ALDEC_SPECIFIC}
    }
    if {0} {
        add_fileset_file cadence/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "cadence/altera_eth_timestamp_aligner.v" {CADENCE_SPECIFIC}
    }
    if {0} {
        add_fileset_file synopsys/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_timestamp_aligner.v" {SYNOPSYS_SPECIFIC}
    }
    add_fileset_file altera_avalon_sc_fifo.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_sc_fifo/altera_avalon_sc_fifo.v"
}

# proc sim_vhd {name} {
   # if {1} {
        # add_fileset_file mentor/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "mentor/altera_eth_timestamp_aligner.v" {MENTOR_SPECIFIC}
    # }
    # if {1} {
        # add_fileset_file aldec/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "aldec/altera_eth_timestamp_aligner.v" {ALDEC_SPECIFIC}
    # }
    # if {0} {
        # add_fileset_file cadence/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "cadence/altera_eth_timestamp_aligner.v" {CADENCE_SPECIFIC}
    # }
    # if {0} {
        # add_fileset_file synopsys/altera_eth_timestamp_aligner.v VERILOG_ENCRYPT PATH "synopsys/altera_eth_timestamp_aligner.v" {SYNOPSYS_SPECIFIC}
    # }
# }


# +-----------------------------------
# | parameters
# | 
# add_parameter BITSPERSYMBOL INTEGER 8
# set_parameter_property BITSPERSYMBOL DEFAULT_VALUE 8
# set_parameter_property BITSPERSYMBOL DISPLAY_NAME BITSPERSYMBOL
# set_parameter_property BITSPERSYMBOL TYPE INTEGER
# set_parameter_property BITSPERSYMBOL ENABLED false
# set_parameter_property BITSPERSYMBOL UNITS None
# set_parameter_property BITSPERSYMBOL AFFECTS_GENERATION false
# set_parameter_property BITSPERSYMBOL HDL_PARAMETER true
# add_parameter SYMBOLSPERBEAT INTEGER 8
# set_parameter_property SYMBOLSPERBEAT DEFAULT_VALUE 8
# set_parameter_property SYMBOLSPERBEAT DISPLAY_NAME SYMBOLSPERBEAT
# set_parameter_property SYMBOLSPERBEAT TYPE INTEGER
# set_parameter_property SYMBOLSPERBEAT ENABLED false
# set_parameter_property SYMBOLSPERBEAT UNITS None
# set_parameter_property SYMBOLSPERBEAT AFFECTS_GENERATION false
# set_parameter_property SYMBOLSPERBEAT HDL_PARAMETER true
# add_parameter ERROR_WIDTH INTEGER 5
# set_parameter_property ERROR_WIDTH DEFAULT_VALUE 5
# set_parameter_property ERROR_WIDTH DISPLAY_NAME ERROR_WIDTH
# set_parameter_property ERROR_WIDTH TYPE INTEGER
# set_parameter_property ERROR_WIDTH ENABLED false
# set_parameter_property ERROR_WIDTH UNITS None
# set_parameter_property ERROR_WIDTH AFFECTS_GENERATION false
# set_parameter_property ERROR_WIDTH HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end

set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# | 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink_rx_status
# | 
add_interface avalon_streaming_sink_rx_status avalon_streaming end
set_interface_property avalon_streaming_sink_rx_status associatedClock clock
set_interface_property avalon_streaming_sink_rx_status dataBitsPerSymbol 40
set_interface_property avalon_streaming_sink_rx_status symbolsPerBeat 1
set_interface_property avalon_streaming_sink_rx_status errorDescriptor ""
set_interface_property avalon_streaming_sink_rx_status firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_sink_rx_status maxChannel 0
set_interface_property avalon_streaming_sink_rx_status readyLatency 0

set_interface_property avalon_streaming_sink_rx_status ENABLED true

set_interface_property avalon_streaming_sink_rx_status ASSOCIATED_CLOCK clock

add_interface_port avalon_streaming_sink_rx_status delay_ins_data_sink_valid valid Input 1
add_interface_port avalon_streaming_sink_rx_status delay_ins_data_sink_data data Input 40
add_interface_port avalon_streaming_sink_rx_status delay_ins_data_sink_error error Input 7
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_96b_sink
# | 
add_interface timestamp_96b_sink avalon_streaming end
set_interface_property timestamp_96b_sink associatedClock clock
set_interface_property timestamp_96b_sink dataBitsPerSymbol 96
set_interface_property timestamp_96b_sink symbolsPerBeat 1
set_interface_property timestamp_96b_sink errorDescriptor ""
set_interface_property timestamp_96b_sink firstSymbolInHighOrderBits true
set_interface_property timestamp_96b_sink maxChannel 0
set_interface_property timestamp_96b_sink readyLatency 0

set_interface_property timestamp_96b_sink ENABLED true

set_interface_property timestamp_96b_sink ASSOCIATED_CLOCK clock

add_interface_port timestamp_96b_sink timestamp_96b_sink_valid valid Input 1
add_interface_port timestamp_96b_sink timestamp_96b_sink_data data Input 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point timestamp_64b_sink
# | 
add_interface timestamp_64b_sink avalon_streaming end
set_interface_property timestamp_64b_sink associatedClock clock
set_interface_property timestamp_64b_sink dataBitsPerSymbol 64
set_interface_property timestamp_64b_sink symbolsPerBeat 1
set_interface_property timestamp_64b_sink errorDescriptor ""
set_interface_property timestamp_64b_sink firstSymbolInHighOrderBits true
set_interface_property timestamp_64b_sink maxChannel 0
set_interface_property timestamp_64b_sink readyLatency 0

set_interface_property timestamp_64b_sink ENABLED true

set_interface_property timestamp_64b_sink ASSOCIATED_CLOCK clock

add_interface_port timestamp_64b_sink timestamp_64b_sink_valid valid Input 1
add_interface_port timestamp_64b_sink timestamp_64b_sink_data data Input 64
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink_overflow_control_sinkport
# | 
add_interface avalon_streaming_sink_overflow_control_sinkport avalon_streaming end
set_interface_property avalon_streaming_sink_overflow_control_sinkport associatedClock clock
set_interface_property avalon_streaming_sink_overflow_control_sinkport dataBitsPerSymbol 8
set_interface_property avalon_streaming_sink_overflow_control_sinkport symbolsPerBeat 8
set_interface_property avalon_streaming_sink_overflow_control_sinkport errorDescriptor ""
set_interface_property avalon_streaming_sink_overflow_control_sinkport firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_sink_overflow_control_sinkport maxChannel 0
set_interface_property avalon_streaming_sink_overflow_control_sinkport readyLatency 0

set_interface_property avalon_streaming_sink_overflow_control_sinkport ENABLED true

set_interface_property avalon_streaming_sink_overflow_control_sinkport ASSOCIATED_CLOCK clock

add_interface_port avalon_streaming_sink_overflow_control_sinkport overflow_control_sink_data_sink_valid valid Input 1
add_interface_port avalon_streaming_sink_overflow_control_sinkport overflow_control_sink_data_sink_data data Input 64
add_interface_port avalon_streaming_sink_overflow_control_sinkport overflow_control_sink_data_sink_sop startofpacket Input 1
add_interface_port avalon_streaming_sink_overflow_control_sinkport overflow_control_sink_data_sink_eop endofpacket Input 1
add_interface_port avalon_streaming_sink_overflow_control_sinkport overflow_control_sink_data_sink_empty empty Input 3
add_interface_port avalon_streaming_sink_overflow_control_sinkport overflow_control_sink_data_sink_error error Input 5
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point avalon_streaming_sink_overflow_control_srcport
# | 
add_interface avalon_streaming_sink_overflow_control_srcport avalon_streaming end
set_interface_property avalon_streaming_sink_overflow_control_srcport associatedClock clock
set_interface_property avalon_streaming_sink_overflow_control_srcport dataBitsPerSymbol 8
set_interface_property avalon_streaming_sink_overflow_control_srcport symbolsPerBeat 8
set_interface_property avalon_streaming_sink_overflow_control_srcport errorDescriptor ""
set_interface_property avalon_streaming_sink_overflow_control_srcport firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_sink_overflow_control_srcport maxChannel 0
set_interface_property avalon_streaming_sink_overflow_control_srcport readyLatency 0

set_interface_property avalon_streaming_sink_overflow_control_srcport ENABLED true

set_interface_property avalon_streaming_sink_overflow_control_srcport ASSOCIATED_CLOCK clock

add_interface_port avalon_streaming_sink_overflow_control_srcport overflow_control_src_data_sink_valid valid Input 1
add_interface_port avalon_streaming_sink_overflow_control_srcport overflow_control_src_data_sink_data data Input 64
add_interface_port avalon_streaming_sink_overflow_control_srcport overflow_control_src_data_sink_ready ready Output 1
add_interface_port avalon_streaming_sink_overflow_control_srcport overflow_control_src_data_sink_sop startofpacket Input 1
add_interface_port avalon_streaming_sink_overflow_control_srcport overflow_control_src_data_sink_eop endofpacket Input 1
add_interface_port avalon_streaming_sink_overflow_control_srcport overflow_control_src_data_sink_empty empty Input 3
add_interface_port avalon_streaming_sink_overflow_control_srcport overflow_control_src_data_sink_error error Input 6
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# | 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source associatedClock clock
set_interface_property avalon_streaming_source dataBitsPerSymbol 8
set_interface_property avalon_streaming_source symbolsPerBeat 8
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source firstSymbolInHighOrderBits true
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 0

set_interface_property avalon_streaming_source ENABLED true

set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock

add_interface_port avalon_streaming_source data_src_valid valid output 1
add_interface_port avalon_streaming_source data_src_data data output 64
add_interface_port avalon_streaming_source data_src_ready ready input 1
add_interface_port avalon_streaming_source data_src_sop startofpacket output 1
add_interface_port avalon_streaming_source data_src_eop endofpacket output 1
add_interface_port avalon_streaming_source data_src_empty empty output 3
add_interface_port avalon_streaming_source data_src_error error output 6
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point rx_ingress_timestamp_96b_src
# | 
add_interface rx_ingress_timestamp_96b_src conduit start
set_interface_assignment rx_ingress_timestamp_96b_src "ui.blockdiagram.direction" Output
set_interface_property rx_ingress_timestamp_96b_src ENABLED true

add_interface_port rx_ingress_timestamp_96b_src rx_ingress_timestamp_96b_src_valid valid Output 1
add_interface_port rx_ingress_timestamp_96b_src rx_ingress_timestamp_96b_src_data data Output 96
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point rx_ingress_timestamp_64b_src
# | 
add_interface rx_ingress_timestamp_64b_src conduit start
set_interface_assignment rx_ingress_timestamp_64b_src "ui.blockdiagram.direction" Output
set_interface_property rx_ingress_timestamp_64b_src ENABLED true

add_interface_port rx_ingress_timestamp_64b_src rx_ingress_timestamp_64b_src_valid valid Output 1
add_interface_port rx_ingress_timestamp_64b_src rx_ingress_timestamp_64b_src_data data Output 64
# | 
# +-----------------------------------
