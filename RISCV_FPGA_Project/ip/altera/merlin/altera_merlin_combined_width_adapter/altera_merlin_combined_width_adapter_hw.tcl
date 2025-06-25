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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_combined_width_adapter/altera_merlin_combined_width_adapter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | request TCL package from ACDS 11.0
# | 
package require -exact sopc 11.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_merlin_combined_width_adapter
# | 
set_module_property NAME altera_merlin_combined_width_adapter
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Memory Mapped Combined Width Adapter"
set_module_property DESCRIPTION "Combine command and response width adapter."
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property TOP_LEVEL_HDL_FILE altera_merlin_combined_width_adapter.sv
set_module_property TOP_LEVEL_HDL_MODULE altera_merlin_combined_width_adapter
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL FALSE
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property HIDE_FROM_SOPC true
set_module_property STATIC_TOP_LEVEL_MODULE_NAME altera_merlin_combined_width_adapter
set_module_property FIX_110_VIP_PATH false
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_merlin_combined_width_adapter.sv {SYNTHESIS SIMULATION}
add_file ../altera_merlin_width_adapter/altera_merlin_width_adapter.sv {SYNTHESIS SIMULATION}
add_file ../altera_merlin_axi_master_ni/altera_merlin_address_alignment.sv {SYNTHESIS SIMULATION}
add_file ../altera_merlin_slave_agent/altera_merlin_burst_uncompressor.sv {SYNTHESIS SIMULATION}
add_file ../../sopc_builder_ip/altera_avalon_sc_fifo/altera_avalon_sc_fifo.v {SYNTHESIS SIMULATION}
add_file ../../sopc_builder_ip/altera_avalon_sc_fifo/credit_producer.v  {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# |

add_parameter IN_PKT_ADDR_H INTEGER 31
set_parameter_property IN_PKT_ADDR_H DISPLAY_NAME {Input packet address field index - high}
set_parameter_property IN_PKT_ADDR_H UNITS None
set_parameter_property IN_PKT_ADDR_H ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_ADDR_H DISPLAY_HINT ""
set_parameter_property IN_PKT_ADDR_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_ADDR_H HDL_PARAMETER true
set_parameter_property IN_PKT_ADDR_H DESCRIPTION {MSB of the input packet address field index}
add_parameter IN_PKT_ADDR_L INTEGER 0
set_parameter_property IN_PKT_ADDR_L DISPLAY_NAME {Input packet address field index - low}
set_parameter_property IN_PKT_ADDR_L UNITS None
set_parameter_property IN_PKT_ADDR_L ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_ADDR_L DISPLAY_HINT ""
set_parameter_property IN_PKT_ADDR_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_ADDR_L HDL_PARAMETER true
set_parameter_property IN_PKT_ADDR_L DESCRIPTION {LSB of the input packet address field index}
add_parameter IN_PKT_DATA_H INTEGER 63
set_parameter_property IN_PKT_DATA_H DISPLAY_NAME {Input packet data field index - high}
set_parameter_property IN_PKT_DATA_H UNITS None
set_parameter_property IN_PKT_DATA_H ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_DATA_H DISPLAY_HINT ""
set_parameter_property IN_PKT_DATA_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_DATA_H HDL_PARAMETER true
set_parameter_property IN_PKT_DATA_H DESCRIPTION {MSB of the input packet data field index}
add_parameter IN_PKT_DATA_L INTEGER 32
set_parameter_property IN_PKT_DATA_L DISPLAY_NAME {Input packet data field index - low}
set_parameter_property IN_PKT_DATA_L UNITS None
set_parameter_property IN_PKT_DATA_L ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_DATA_L DISPLAY_HINT ""
set_parameter_property IN_PKT_DATA_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_DATA_L HDL_PARAMETER true
set_parameter_property IN_PKT_DATA_L DESCRIPTION {LSB of the input packet data field index}
add_parameter IN_PKT_BYTEEN_H INTEGER 67
set_parameter_property IN_PKT_BYTEEN_H DISPLAY_NAME {Input packet byteenable field index - high}
set_parameter_property IN_PKT_BYTEEN_H UNITS None
set_parameter_property IN_PKT_BYTEEN_H ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BYTEEN_H DISPLAY_HINT ""
set_parameter_property IN_PKT_BYTEEN_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_BYTEEN_H HDL_PARAMETER true
set_parameter_property IN_PKT_BYTEEN_H DESCRIPTION {MSB of the input packet byteenable field index}
add_parameter IN_PKT_BYTEEN_L INTEGER 64
set_parameter_property IN_PKT_BYTEEN_L DISPLAY_NAME {Input packet byteenable field index - low}
set_parameter_property IN_PKT_BYTEEN_L UNITS None
set_parameter_property IN_PKT_BYTEEN_L ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BYTEEN_L DISPLAY_HINT ""
set_parameter_property IN_PKT_BYTEEN_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_BYTEEN_L HDL_PARAMETER true
set_parameter_property IN_PKT_BYTEEN_L DESCRIPTION {LSB of the input packet byteenable field index}
add_parameter IN_PKT_BYTE_CNT_H INTEGER 77
set_parameter_property IN_PKT_BYTE_CNT_H DISPLAY_NAME {Input packet byte count field index - high}
set_parameter_property IN_PKT_BYTE_CNT_H UNITS None
set_parameter_property IN_PKT_BYTE_CNT_H ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BYTE_CNT_H DISPLAY_HINT ""
set_parameter_property IN_PKT_BYTE_CNT_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_BYTE_CNT_H HDL_PARAMETER true
set_parameter_property IN_PKT_BYTE_CNT_H DESCRIPTION {MSB of the input packet byte count field index}
add_parameter IN_PKT_BYTE_CNT_L INTEGER 73 
set_parameter_property IN_PKT_BYTE_CNT_L DISPLAY_NAME {Input packet byte count field index - low}
set_parameter_property IN_PKT_BYTE_CNT_L UNITS None
set_parameter_property IN_PKT_BYTE_CNT_L ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BYTE_CNT_L DISPLAY_HINT ""
set_parameter_property IN_PKT_BYTE_CNT_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_BYTE_CNT_L HDL_PARAMETER true
set_parameter_property IN_PKT_BYTE_CNT_L DESCRIPTION {LSB of the input packet byte count field index}
add_parameter IN_PKT_TRANS_COMPRESSED_READ INTEGER 72
set_parameter_property IN_PKT_TRANS_COMPRESSED_READ DISPLAY_NAME {Input packet compressed read transaction field index}
set_parameter_property IN_PKT_TRANS_COMPRESSED_READ UNITS None
set_parameter_property IN_PKT_TRANS_COMPRESSED_READ ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_TRANS_COMPRESSED_READ DISPLAY_HINT ""
set_parameter_property IN_PKT_TRANS_COMPRESSED_READ HDL_PARAMETER true
set_parameter_property IN_PKT_TRANS_COMPRESSED_READ DESCRIPTION {Input packet compressed read transaction field index}
add_parameter IN_PKT_BURSTWRAP_H INTEGER 82
set_parameter_property IN_PKT_BURSTWRAP_H DISPLAY_NAME {Input packet burstwrap field index - high}
set_parameter_property IN_PKT_BURSTWRAP_H UNITS None
set_parameter_property IN_PKT_BURSTWRAP_H ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BURSTWRAP_H DISPLAY_HINT ""
set_parameter_property IN_PKT_BURSTWRAP_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_BURSTWRAP_H HDL_PARAMETER true
set_parameter_property IN_PKT_BURSTWRAP_H DESCRIPTION {MSB of the input packet burstwrap field index}
add_parameter IN_PKT_BURSTWRAP_L INTEGER 78 
set_parameter_property IN_PKT_BURSTWRAP_L DISPLAY_NAME {Input packet burstwrap field index - low}
set_parameter_property IN_PKT_BURSTWRAP_L UNITS None
set_parameter_property IN_PKT_BURSTWRAP_L ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BURSTWRAP_L DISPLAY_HINT ""
set_parameter_property IN_PKT_BURSTWRAP_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_BURSTWRAP_L HDL_PARAMETER true
set_parameter_property IN_PKT_BURSTWRAP_L DESCRIPTION {LSB of the input packet burstwrap field index}
add_parameter IN_PKT_BURST_SIZE_H INTEGER 85
set_parameter_property IN_PKT_BURST_SIZE_H DISPLAY_NAME {Input packet burst size field index - high}
set_parameter_property IN_PKT_BURST_SIZE_H UNITS None
set_parameter_property IN_PKT_BURST_SIZE_H ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BURST_SIZE_H DISPLAY_HINT ""
set_parameter_property IN_PKT_BURST_SIZE_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_BURST_SIZE_H HDL_PARAMETER true
set_parameter_property IN_PKT_BURST_SIZE_H DESCRIPTION {MSB of the input packet burst size field index}
add_parameter IN_PKT_BURST_SIZE_L INTEGER 83 
set_parameter_property IN_PKT_BURST_SIZE_L DISPLAY_NAME {Input packet burst size field index - low}
set_parameter_property IN_PKT_BURST_SIZE_L UNITS None
set_parameter_property IN_PKT_BURST_SIZE_L ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BURST_SIZE_L DISPLAY_HINT ""
set_parameter_property IN_PKT_BURST_SIZE_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_BURST_SIZE_L HDL_PARAMETER true
set_parameter_property IN_PKT_BURST_SIZE_L DESCRIPTION {LSB of the input packet burst size field index}
add_parameter IN_PKT_RESPONSE_STATUS_H INTEGER 87
set_parameter_property IN_PKT_RESPONSE_STATUS_H DISPLAY_NAME {Input packet response - high}
set_parameter_property IN_PKT_RESPONSE_STATUS_H TYPE INTEGER
set_parameter_property IN_PKT_RESPONSE_STATUS_H UNITS None
set_parameter_property IN_PKT_RESPONSE_STATUS_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_RESPONSE_STATUS_H HDL_PARAMETER true 
add_parameter IN_PKT_RESPONSE_STATUS_L INTEGER 86
set_parameter_property IN_PKT_RESPONSE_STATUS_L DISPLAY_NAME {Input packet response - low}
set_parameter_property IN_PKT_RESPONSE_STATUS_L TYPE INTEGER
set_parameter_property IN_PKT_RESPONSE_STATUS_L UNITS None
set_parameter_property IN_PKT_RESPONSE_STATUS_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_RESPONSE_STATUS_L HDL_PARAMETER true
add_parameter IN_PKT_TRANS_EXCLUSIVE INTEGER 88 
set_parameter_property IN_PKT_TRANS_EXCLUSIVE DISPLAY_NAME {Input packet exclusive trans field }
set_parameter_property IN_PKT_TRANS_EXCLUSIVE UNITS None
set_parameter_property IN_PKT_TRANS_EXCLUSIVE ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_TRANS_EXCLUSIVE DISPLAY_HINT ""
set_parameter_property IN_PKT_TRANS_EXCLUSIVE AFFECTS_GENERATION false
set_parameter_property IN_PKT_TRANS_EXCLUSIVE HDL_PARAMETER true
set_parameter_property IN_PKT_TRANS_EXCLUSIVE DESCRIPTION {the input packet exclusive trans field index}
add_parameter IN_PKT_BURST_TYPE_H INTEGER 90
set_parameter_property IN_PKT_BURST_TYPE_H DISPLAY_NAME {Input packet burst type field index - high}
set_parameter_property IN_PKT_BURST_TYPE_H UNITS None
set_parameter_property IN_PKT_BURST_TYPE_H ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BURST_TYPE_H DISPLAY_HINT ""
set_parameter_property IN_PKT_BURST_TYPE_H AFFECTS_GENERATION false
set_parameter_property IN_PKT_BURST_TYPE_H HDL_PARAMETER true
set_parameter_property IN_PKT_BURST_TYPE_H DESCRIPTION {MSB of the input packet burst type field index}
add_parameter IN_PKT_BURST_TYPE_L INTEGER 89 
set_parameter_property IN_PKT_BURST_TYPE_L DISPLAY_NAME {Input packet burst type field index - low}
set_parameter_property IN_PKT_BURST_TYPE_L UNITS None
set_parameter_property IN_PKT_BURST_TYPE_L ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_BURST_TYPE_L DISPLAY_HINT ""
set_parameter_property IN_PKT_BURST_TYPE_L AFFECTS_GENERATION false
set_parameter_property IN_PKT_BURST_TYPE_L HDL_PARAMETER true
set_parameter_property IN_PKT_BURST_TYPE_L DESCRIPTION {LSB of the input packet burst type field index}
add_parameter IN_PKT_TRANS_POSTED INTEGER 91
set_parameter_property IN_PKT_TRANS_POSTED DEFAULT_VALUE 91
set_parameter_property IN_PKT_TRANS_POSTED DISPLAY_NAME {Input Packet posted transaction field index}
set_parameter_property IN_PKT_TRANS_POSTED UNITS None
set_parameter_property IN_PKT_TRANS_POSTED ALLOWED_RANGES 0:2147483647
set_parameter_property IN_PKT_TRANS_POSTED DISPLAY_HINT ""
set_parameter_property IN_PKT_TRANS_POSTED DESCRIPTION {Input Packet posted transaction field index}
set_parameter_property IN_PKT_TRANS_POSTED AFFECTS_ELABORATION false
set_parameter_property IN_PKT_TRANS_POSTED HDL_PARAMETER true
add_parameter IN_ST_DATA_W INTEGER 110
set_parameter_property IN_ST_DATA_W DISPLAY_NAME {Input data width}
set_parameter_property IN_ST_DATA_W UNITS None
set_parameter_property IN_ST_DATA_W ALLOWED_RANGES 0:2147483647
set_parameter_property IN_ST_DATA_W DISPLAY_HINT ""
set_parameter_property IN_ST_DATA_W AFFECTS_GENERATION false
set_parameter_property IN_ST_DATA_W HDL_PARAMETER true
set_parameter_property IN_ST_DATA_W DESCRIPTION {Input packet data width}


add_parameter OUT_PKT_ADDR_H INTEGER 31
set_parameter_property OUT_PKT_ADDR_H DISPLAY_NAME {Output packet address field index - high}
set_parameter_property OUT_PKT_ADDR_H UNITS None
set_parameter_property OUT_PKT_ADDR_H ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_ADDR_H DISPLAY_HINT ""
set_parameter_property OUT_PKT_ADDR_H AFFECTS_GENERATION false
set_parameter_property OUT_PKT_ADDR_H HDL_PARAMETER true
set_parameter_property OUT_PKT_ADDR_H DESCRIPTION {MSB of the output packet address field index}
add_parameter OUT_PKT_ADDR_L INTEGER 0
set_parameter_property OUT_PKT_ADDR_L DISPLAY_NAME {Output packet address field index - low}
set_parameter_property OUT_PKT_ADDR_L UNITS None
set_parameter_property OUT_PKT_ADDR_L ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_ADDR_L DISPLAY_HINT ""
set_parameter_property OUT_PKT_ADDR_L AFFECTS_GENERATION false
set_parameter_property OUT_PKT_ADDR_L HDL_PARAMETER true
set_parameter_property OUT_PKT_ADDR_L DESCRIPTION {LSB of the output packet address field index}
add_parameter OUT_PKT_DATA_H INTEGER 47
set_parameter_property OUT_PKT_DATA_H DISPLAY_NAME {Output packet byteenable field index - high}
set_parameter_property OUT_PKT_DATA_H UNITS None
set_parameter_property OUT_PKT_DATA_H ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_DATA_H DISPLAY_HINT ""
set_parameter_property OUT_PKT_DATA_H AFFECTS_GENERATION false
set_parameter_property OUT_PKT_DATA_H HDL_PARAMETER true
set_parameter_property OUT_PKT_DATA_H DESCRIPTION {MSB of the output packet byteenable field index}
add_parameter OUT_PKT_DATA_L INTEGER 32
set_parameter_property OUT_PKT_DATA_L DISPLAY_NAME {Output packet byteenable field index - low}
set_parameter_property OUT_PKT_DATA_L UNITS None
set_parameter_property OUT_PKT_DATA_L ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_DATA_L DISPLAY_HINT ""
set_parameter_property OUT_PKT_DATA_L AFFECTS_GENERATION false
set_parameter_property OUT_PKT_DATA_L HDL_PARAMETER true
set_parameter_property OUT_PKT_DATA_L DESCRIPTION {LSB of the output packet byteenable field index}
add_parameter OUT_PKT_BYTEEN_H INTEGER 49
set_parameter_property OUT_PKT_BYTEEN_H DISPLAY_NAME {Output packet byteenable field index - high}
set_parameter_property OUT_PKT_BYTEEN_H UNITS None
set_parameter_property OUT_PKT_BYTEEN_H ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_BYTEEN_H DISPLAY_HINT ""
set_parameter_property OUT_PKT_BYTEEN_H AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BYTEEN_H HDL_PARAMETER true
set_parameter_property OUT_PKT_BYTEEN_H DESCRIPTION {MSB of the output packet byteenable field index}
add_parameter OUT_PKT_BYTEEN_L INTEGER 48
set_parameter_property OUT_PKT_BYTEEN_L DISPLAY_NAME {Output packet byteenable field index - low}
set_parameter_property OUT_PKT_BYTEEN_L UNITS None
set_parameter_property OUT_PKT_BYTEEN_L ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_BYTEEN_L DISPLAY_HINT ""
set_parameter_property OUT_PKT_BYTEEN_L AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BYTEEN_L HDL_PARAMETER true
set_parameter_property OUT_PKT_BYTEEN_L DESCRIPTION {LSB of the output packet byteenable field index}
add_parameter OUT_PKT_BYTE_CNT_H INTEGER 59 
set_parameter_property OUT_PKT_BYTE_CNT_H DISPLAY_NAME {Output packet byte count field index - high}
set_parameter_property OUT_PKT_BYTE_CNT_H UNITS None
set_parameter_property OUT_PKT_BYTE_CNT_H ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_BYTE_CNT_H DISPLAY_HINT ""
set_parameter_property OUT_PKT_BYTE_CNT_H AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BYTE_CNT_H HDL_PARAMETER true
set_parameter_property OUT_PKT_BYTE_CNT_H DESCRIPTION {MSB of the output packet byte count field index}
add_parameter OUT_PKT_BYTE_CNT_L INTEGER 55
set_parameter_property OUT_PKT_BYTE_CNT_L DISPLAY_NAME {Output packet byte count field index - low}
set_parameter_property OUT_PKT_BYTE_CNT_L UNITS None
set_parameter_property OUT_PKT_BYTE_CNT_L ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_BYTE_CNT_L DISPLAY_HINT ""
set_parameter_property OUT_PKT_BYTE_CNT_L AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BYTE_CNT_L HDL_PARAMETER true
set_parameter_property OUT_PKT_BYTE_CNT_L DESCRIPTION {LSB of the output packet byte count field index}
add_parameter OUT_PKT_TRANS_COMPRESSED_READ INTEGER 54
set_parameter_property OUT_PKT_TRANS_COMPRESSED_READ DISPLAY_NAME {Output packet compressed read transaction field index}
set_parameter_property OUT_PKT_TRANS_COMPRESSED_READ UNITS None
set_parameter_property OUT_PKT_TRANS_COMPRESSED_READ ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_TRANS_COMPRESSED_READ DISPLAY_HINT ""
set_parameter_property OUT_PKT_TRANS_COMPRESSED_READ HDL_PARAMETER true
set_parameter_property OUT_PKT_TRANS_COMPRESSED_READ DESCRIPTION {Output packet compressed read transaction field index}

add_parameter OUT_PKT_TRANS_EXCLUSIVE INTEGER 65
set_parameter_property OUT_PKT_TRANS_EXCLUSIVE DISPLAY_NAME {Output packet exclusive trans field }
set_parameter_property OUT_PKT_TRANS_EXCLUSIVE UNITS None
set_parameter_property OUT_PKT_TRANS_EXCLUSIVE ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_PKT_TRANS_EXCLUSIVE DISPLAY_HINT ""
set_parameter_property OUT_PKT_TRANS_EXCLUSIVE AFFECTS_GENERATION false
set_parameter_property OUT_PKT_TRANS_EXCLUSIVE HDL_PARAMETER true
set_parameter_property OUT_PKT_TRANS_EXCLUSIVE DESCRIPTION {the output packet exclusive trans field index}

add_parameter OUT_PKT_RESPONSE_STATUS_H INTEGER 64
set_parameter_property OUT_PKT_RESPONSE_STATUS_H DISPLAY_NAME {Output packet response - high}
set_parameter_property OUT_PKT_RESPONSE_STATUS_H TYPE INTEGER
set_parameter_property OUT_PKT_RESPONSE_STATUS_H UNITS None
set_parameter_property OUT_PKT_RESPONSE_STATUS_H AFFECTS_GENERATION false
set_parameter_property OUT_PKT_RESPONSE_STATUS_H HDL_PARAMETER true 
add_parameter OUT_PKT_RESPONSE_STATUS_L INTEGER 63
set_parameter_property OUT_PKT_RESPONSE_STATUS_L DISPLAY_NAME {Output packet response - low}
set_parameter_property OUT_PKT_RESPONSE_STATUS_L TYPE INTEGER
set_parameter_property OUT_PKT_RESPONSE_STATUS_L UNITS None
set_parameter_property OUT_PKT_RESPONSE_STATUS_L AFFECTS_GENERATION false
set_parameter_property OUT_PKT_RESPONSE_STATUS_L HDL_PARAMETER true
add_parameter OUT_PKT_BURST_SIZE_H INTEGER 62
set_parameter_property OUT_PKT_BURST_SIZE_H DISPLAY_NAME {Output packet burst size - high}
set_parameter_property OUT_PKT_BURST_SIZE_H TYPE INTEGER
set_parameter_property OUT_PKT_BURST_SIZE_H UNITS None
set_parameter_property OUT_PKT_BURST_SIZE_H AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BURST_SIZE_H HDL_PARAMETER true
add_parameter OUT_PKT_BURST_SIZE_L INTEGER 60
set_parameter_property OUT_PKT_BURST_SIZE_L DISPLAY_NAME {Output packet burst size - low}
set_parameter_property OUT_PKT_BURST_SIZE_L TYPE INTEGER
set_parameter_property OUT_PKT_BURST_SIZE_L UNITS None
set_parameter_property OUT_PKT_BURST_SIZE_L AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BURST_SIZE_L HDL_PARAMETER true
add_parameter OUT_PKT_BURST_TYPE_H INTEGER 67
set_parameter_property OUT_PKT_BURST_TYPE_H DISPLAY_NAME {Output packet burst type - high}
set_parameter_property OUT_PKT_BURST_TYPE_H TYPE INTEGER
set_parameter_property OUT_PKT_BURST_TYPE_H UNITS None
set_parameter_property OUT_PKT_BURST_TYPE_H AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BURST_TYPE_H HDL_PARAMETER true
add_parameter OUT_PKT_BURST_TYPE_L INTEGER 66
set_parameter_property OUT_PKT_BURST_TYPE_L DISPLAY_NAME {Output packet burst type - low}
set_parameter_property OUT_PKT_BURST_TYPE_L TYPE INTEGER
set_parameter_property OUT_PKT_BURST_TYPE_L UNITS None
set_parameter_property OUT_PKT_BURST_TYPE_L AFFECTS_GENERATION false
set_parameter_property OUT_PKT_BURST_TYPE_L HDL_PARAMETER true
add_parameter OUT_ST_DATA_W INTEGER 92
set_parameter_property OUT_ST_DATA_W DISPLAY_NAME {Output data width}
set_parameter_property OUT_ST_DATA_W UNITS None
set_parameter_property OUT_ST_DATA_W ALLOWED_RANGES 0:2147483647
set_parameter_property OUT_ST_DATA_W DISPLAY_HINT ""
set_parameter_property OUT_ST_DATA_W AFFECTS_GENERATION false
set_parameter_property OUT_ST_DATA_W HDL_PARAMETER true
set_parameter_property OUT_ST_DATA_W DESCRIPTION {Output packet data width}
add_parameter ST_CHANNEL_W INTEGER 32
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DISPLAY_HINT ""
set_parameter_property ST_CHANNEL_W AFFECTS_GENERATION false
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}

add_parameter MAX_OUTSTANDING_RESPONSES INTEGER 16
set_parameter_property MAX_OUTSTANDING_RESPONSES DISPLAY_NAME {Max outstanding responses}
set_parameter_property MAX_OUTSTANDING_RESPONSES TYPE INTEGER
set_parameter_property MAX_OUTSTANDING_RESPONSES UNITS None
set_parameter_property MAX_OUTSTANDING_RESPONSES AFFECTS_GENERATION false
set_parameter_property MAX_OUTSTANDING_RESPONSES HDL_PARAMETER true
set_parameter_property MAX_OUTSTANDING_RESPONSES DESCRIPTION {Number of outstanding command that WA can accept - fifo depth}
add_parameter IN_MERLIN_PACKET_FORMAT String ""
set_parameter_property IN_MERLIN_PACKET_FORMAT DISPLAY_NAME {Input Merlin packet format descriptor}
set_parameter_property IN_MERLIN_PACKET_FORMAT UNITS None
set_parameter_property IN_MERLIN_PACKET_FORMAT DESCRIPTION {Input Merlin packet format descriptor}

add_parameter OUT_MERLIN_PACKET_FORMAT String ""
set_parameter_property OUT_MERLIN_PACKET_FORMAT DISPLAY_NAME {Merlin packet format descriptor - output}
set_parameter_property OUT_MERLIN_PACKET_FORMAT UNITS None
set_parameter_property OUT_MERLIN_PACKET_FORMAT DESCRIPTION {Merlin packet format descriptor - output}


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
set_interface_property clock clockRate 0

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
# | connection point cmd_sink
# | 
add_interface cmd_sink avalon_streaming end
set_interface_property cmd_sink associatedClock clock
set_interface_property cmd_sink associatedReset reset
set_interface_property cmd_sink dataBitsPerSymbol 8
set_interface_property cmd_sink errorDescriptor ""
set_interface_property cmd_sink firstSymbolInHighOrderBits true
set_interface_property cmd_sink maxChannel 0
set_interface_property cmd_sink readyLatency 0

set_interface_property cmd_sink ENABLED true

add_interface_port cmd_sink cmd_in_valid valid Input 1
add_interface_port cmd_sink cmd_in_channel channel Input 1
add_interface_port cmd_sink cmd_in_data data Input 64
add_interface_port cmd_sink cmd_in_startofpacket startofpacket Input 1
add_interface_port cmd_sink cmd_in_endofpacket endofpacket Input 1
add_interface_port cmd_sink cmd_in_ready ready Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point cmd_source
# | 
add_interface cmd_source avalon_streaming start
set_interface_property cmd_source associatedClock clock
set_interface_property cmd_source associatedReset reset
set_interface_property cmd_source dataBitsPerSymbol 8
set_interface_property cmd_source errorDescriptor ""
set_interface_property cmd_source firstSymbolInHighOrderBits true
set_interface_property cmd_source maxChannel 0
set_interface_property cmd_source readyLatency 0

set_interface_property cmd_source ENABLED true

add_interface_port cmd_source cmd_out_ready ready Input 1
add_interface_port cmd_source cmd_out_valid valid Output 1
add_interface_port cmd_source cmd_out_channel channel Output 1
add_interface_port cmd_source cmd_out_data data Output 64
add_interface_port cmd_source cmd_out_startofpacket startofpacket Output 1
add_interface_port cmd_source cmd_out_endofpacket endofpacket Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point rsp_sink
# | 
add_interface rsp_sink avalon_streaming end
set_interface_property rsp_sink associatedClock clock
set_interface_property rsp_sink associatedReset reset
set_interface_property rsp_sink dataBitsPerSymbol 8
set_interface_property rsp_sink errorDescriptor ""
set_interface_property rsp_sink firstSymbolInHighOrderBits true
set_interface_property rsp_sink maxChannel 0
set_interface_property rsp_sink readyLatency 0

set_interface_property rsp_sink ENABLED true

add_interface_port rsp_sink rsp_in_ready ready Output 1
add_interface_port rsp_sink rsp_in_valid valid Input 1
add_interface_port rsp_sink rsp_in_channel channel Input 1
add_interface_port rsp_sink rsp_in_data data Input 64
add_interface_port rsp_sink rsp_in_startofpacket startofpacket Input 1
add_interface_port rsp_sink rsp_in_endofpacket endofpacket Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point rsp_source
# | 
add_interface rsp_source avalon_streaming start
set_interface_property rsp_source associatedClock clock
set_interface_property rsp_source associatedReset reset
set_interface_property rsp_source dataBitsPerSymbol 8
set_interface_property rsp_source errorDescriptor ""
set_interface_property rsp_source firstSymbolInHighOrderBits true
set_interface_property rsp_source maxChannel 0
set_interface_property rsp_source readyLatency 0

set_interface_property rsp_source ENABLED true

add_interface_port rsp_source rsp_out_ready ready Input 1
add_interface_port rsp_source rsp_out_valid valid Output 1
add_interface_port rsp_source rsp_out_channel channel Output 1
add_interface_port rsp_source rsp_out_data data Output 64
add_interface_port rsp_source rsp_out_startofpacket startofpacket Output 1
add_interface_port rsp_source rsp_out_endofpacket endofpacket Output 1
# | 
# +-----------------------------------
# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

    set in_st_data_width  [ get_parameter_value IN_ST_DATA_W  ]
    set out_st_data_width [ get_parameter_value OUT_ST_DATA_W ]
    set st_chan_width     [ get_parameter_value ST_CHANNEL_W  ]
    set in_fields         [ get_parameter_value IN_MERLIN_PACKET_FORMAT ]
    set out_fields        [ get_parameter_value OUT_MERLIN_PACKET_FORMAT ]

    set_interface_property cmd_source  dataBitsPerSymbol $out_st_data_width
    set_interface_property rsp_sink dataBitsPerSymbol $out_st_data_width
    set_interface_property cmd_sink dataBitsPerSymbol $in_st_data_width
    set_interface_property rsp_source  dataBitsPerSymbol $in_st_data_width

    set_port_property cmd_in_data  WIDTH $in_st_data_width
    set_port_property rsp_out_data WIDTH $in_st_data_width
    set_port_property cmd_out_data WIDTH $out_st_data_width
    set_port_property rsp_in_data  WIDTH $out_st_data_width

    set_interface_assignment cmd_sink merlin.packet_format $in_fields
    set_interface_assignment rsp_source merlin.packet_format $out_fields

    set_interface_assignment cmd_sink merlin.flow.cmd_source cmd_source
    set_interface_assignment rsp_sink merlin.flow.rsp_source rsp_source
    
    set_port_property cmd_in_channel  WIDTH $st_chan_width
    set_port_property rsp_in_channel  WIDTH $st_chan_width
    set_port_property cmd_out_channel WIDTH $st_chan_width
    set_port_property rsp_out_channel WIDTH $st_chan_width
}
