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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_apb_slave_agent/altera_merlin_apb_slave_agent_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
# 
# request TCL package from ACDS 12.1
# 
package require -exact qsys 12.1


# 
# module altera_merlin_apb_slave_ni
# 
set_module_property NAME altera_merlin_apb_slave_agent
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Qsys Interconnect/Memory-Mapped"
set_module_property DISPLAY_NAME "APB Slave Agent"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ALLOW_GREYBOX_GENERATION false
add_documentation_link "DATASHEET_URL" http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_merlin_apb_slave_agent
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_merlin_apb_slave_agent.sv SYSTEM_VERILOG PATH altera_merlin_apb_slave_agent.sv

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL altera_merlin_apb_slave_agent
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_merlin_apb_slave_agent.sv SYSTEM_VERILOG PATH altera_merlin_apb_slave_agent.sv

add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_apb_slave_agent

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_apb_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_apb_slave_agent.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_apb_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_apb_slave_agent.sv" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_merlin_apb_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_apb_slave_agent.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_merlin_apb_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_apb_slave_agent.sv" {SYNOPSYS_SPECIFIC}
   }    
}

# 
# parameters
# 
add_parameter ADDR_WIDTH INTEGER 32 "APB Address width"
set_parameter_property ADDR_WIDTH DEFAULT_VALUE 32
set_parameter_property ADDR_WIDTH DISPLAY_NAME "Address width"
set_parameter_property ADDR_WIDTH TYPE INTEGER
set_parameter_property ADDR_WIDTH UNITS None
set_parameter_property ADDR_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ADDR_WIDTH DESCRIPTION "APB Address width"
set_parameter_property ADDR_WIDTH HDL_PARAMETER true
add_parameter DATA_WIDTH INTEGER 32 "ABP Data width"
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data width"
set_parameter_property DATA_WIDTH TYPE INTEGER
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property DATA_WIDTH DESCRIPTION "ABP Data width"
set_parameter_property DATA_WIDTH HDL_PARAMETER true
add_parameter PKT_DATA_H INTEGER 31 "MSB of the packet data field index"
set_parameter_property PKT_DATA_H DEFAULT_VALUE 31
set_parameter_property PKT_DATA_H DISPLAY_NAME "Packet data field index - high"
set_parameter_property PKT_DATA_H TYPE INTEGER
set_parameter_property PKT_DATA_H UNITS None
set_parameter_property PKT_DATA_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_DATA_H DESCRIPTION "MSB of the packet data field index"
set_parameter_property PKT_DATA_H HDL_PARAMETER true
add_parameter PKT_DATA_L INTEGER 0 "LSB of the packet data field index"
set_parameter_property PKT_DATA_L DEFAULT_VALUE 0
set_parameter_property PKT_DATA_L DISPLAY_NAME "Packet data field index - low"
set_parameter_property PKT_DATA_L TYPE INTEGER
set_parameter_property PKT_DATA_L UNITS None
set_parameter_property PKT_DATA_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_DATA_L DESCRIPTION "LSB of the packet data field index"
set_parameter_property PKT_DATA_L HDL_PARAMETER true
add_parameter PKT_BEGIN_BURST INTEGER 81 "Packet begin burst field index"
set_parameter_property PKT_BEGIN_BURST DEFAULT_VALUE 81
set_parameter_property PKT_BEGIN_BURST DISPLAY_NAME "Packet begin burst field index"
set_parameter_property PKT_BEGIN_BURST TYPE INTEGER
set_parameter_property PKT_BEGIN_BURST UNITS None
set_parameter_property PKT_BEGIN_BURST ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BEGIN_BURST DESCRIPTION "Packet begin burst field index"
set_parameter_property PKT_BEGIN_BURST AFFECTS_ELABORATION false
set_parameter_property PKT_BEGIN_BURST HDL_PARAMETER true
add_parameter PKT_SYMBOL_W INTEGER 8 "Packet symbol width"
set_parameter_property PKT_SYMBOL_W DEFAULT_VALUE 8
set_parameter_property PKT_SYMBOL_W DISPLAY_NAME "Packet symbol width"
set_parameter_property PKT_SYMBOL_W TYPE INTEGER
set_parameter_property PKT_SYMBOL_W UNITS None
set_parameter_property PKT_SYMBOL_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_SYMBOL_W DESCRIPTION "Packet symbol width"
set_parameter_property PKT_SYMBOL_W HDL_PARAMETER true
add_parameter PKT_BYTEEN_H INTEGER 71 "MSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_H DEFAULT_VALUE 71
set_parameter_property PKT_BYTEEN_H DISPLAY_NAME "Packet byteenable field index - high"
set_parameter_property PKT_BYTEEN_H TYPE INTEGER
set_parameter_property PKT_BYTEEN_H UNITS None
set_parameter_property PKT_BYTEEN_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTEEN_H DESCRIPTION "MSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_H HDL_PARAMETER true
add_parameter PKT_BYTEEN_L INTEGER 68 "LSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_L DEFAULT_VALUE 68
set_parameter_property PKT_BYTEEN_L DISPLAY_NAME "Packet byteenable field index - low"
set_parameter_property PKT_BYTEEN_L TYPE INTEGER
set_parameter_property PKT_BYTEEN_L UNITS None
set_parameter_property PKT_BYTEEN_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTEEN_L DESCRIPTION "LSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_L HDL_PARAMETER true
add_parameter PKT_ADDR_H INTEGER 63 "MSB of the packet address field index"
set_parameter_property PKT_ADDR_H DEFAULT_VALUE 63
set_parameter_property PKT_ADDR_H DISPLAY_NAME "Packet address field index - high"
set_parameter_property PKT_ADDR_H TYPE INTEGER
set_parameter_property PKT_ADDR_H UNITS None
set_parameter_property PKT_ADDR_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_ADDR_H DESCRIPTION "MSB of the packet address field index"
set_parameter_property PKT_ADDR_H HDL_PARAMETER true
add_parameter PKT_ADDR_L INTEGER 32 "LSB of the packet address field index"
set_parameter_property PKT_ADDR_L DEFAULT_VALUE 32
set_parameter_property PKT_ADDR_L DISPLAY_NAME "Packet address field index - low"
set_parameter_property PKT_ADDR_L TYPE INTEGER
set_parameter_property PKT_ADDR_L UNITS None
set_parameter_property PKT_ADDR_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_ADDR_L DESCRIPTION "LSB of the packet address field index"
set_parameter_property PKT_ADDR_L HDL_PARAMETER true
add_parameter PKT_TRANS_COMPRESSED_READ INTEGER 67 "Packet compressed read transaction field index"
set_parameter_property PKT_TRANS_COMPRESSED_READ DEFAULT_VALUE 67
set_parameter_property PKT_TRANS_COMPRESSED_READ DISPLAY_NAME "Packet compressed read transaction field index"
set_parameter_property PKT_TRANS_COMPRESSED_READ TYPE INTEGER
set_parameter_property PKT_TRANS_COMPRESSED_READ UNITS None
set_parameter_property PKT_TRANS_COMPRESSED_READ ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_TRANS_COMPRESSED_READ DESCRIPTION "Packet compressed read transaction field index"
set_parameter_property PKT_TRANS_COMPRESSED_READ HDL_PARAMETER true
add_parameter PKT_TRANS_POSTED INTEGER 66 "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED DEFAULT_VALUE 66
set_parameter_property PKT_TRANS_POSTED DISPLAY_NAME "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED TYPE INTEGER
set_parameter_property PKT_TRANS_POSTED UNITS None
set_parameter_property PKT_TRANS_POSTED ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_TRANS_POSTED DESCRIPTION "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED HDL_PARAMETER true
add_parameter PKT_TRANS_WRITE INTEGER 65 "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE DEFAULT_VALUE 65
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE TYPE INTEGER
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_TRANS_WRITE DESCRIPTION "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER true
add_parameter PKT_TRANS_READ INTEGER 64 "Packet read transaction field index"
set_parameter_property PKT_TRANS_READ DEFAULT_VALUE 64
set_parameter_property PKT_TRANS_READ DISPLAY_NAME "Packet read transaction field index"
set_parameter_property PKT_TRANS_READ TYPE INTEGER
set_parameter_property PKT_TRANS_READ UNITS None
set_parameter_property PKT_TRANS_READ ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_TRANS_READ DESCRIPTION "Packet read transaction field index"
set_parameter_property PKT_TRANS_READ HDL_PARAMETER true
add_parameter PKT_TRANS_LOCK INTEGER 87 "Packet lock transaction field index"
set_parameter_property PKT_TRANS_LOCK DEFAULT_VALUE 87
set_parameter_property PKT_TRANS_LOCK DISPLAY_NAME "Packet lock transaction field index"
set_parameter_property PKT_TRANS_LOCK TYPE INTEGER
set_parameter_property PKT_TRANS_LOCK UNITS None
set_parameter_property PKT_TRANS_LOCK ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_TRANS_LOCK DESCRIPTION "Packet lock transaction field index"
set_parameter_property PKT_TRANS_LOCK HDL_PARAMETER true
add_parameter PKT_SRC_ID_H INTEGER 74 "MSB of the packet source id field index"
set_parameter_property PKT_SRC_ID_H DEFAULT_VALUE 74
set_parameter_property PKT_SRC_ID_H DISPLAY_NAME "Packet source id field index - high"
set_parameter_property PKT_SRC_ID_H TYPE INTEGER
set_parameter_property PKT_SRC_ID_H UNITS None
set_parameter_property PKT_SRC_ID_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_SRC_ID_H DESCRIPTION "MSB of the packet source id field index"
set_parameter_property PKT_SRC_ID_H HDL_PARAMETER true
add_parameter PKT_SRC_ID_L INTEGER 72 "LSB of the packet source id field index"
set_parameter_property PKT_SRC_ID_L DEFAULT_VALUE 72
set_parameter_property PKT_SRC_ID_L DISPLAY_NAME "Packet source id field index - low"
set_parameter_property PKT_SRC_ID_L TYPE INTEGER
set_parameter_property PKT_SRC_ID_L UNITS None
set_parameter_property PKT_SRC_ID_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_SRC_ID_L DESCRIPTION "LSB of the packet source id field index"
set_parameter_property PKT_SRC_ID_L HDL_PARAMETER true
add_parameter PKT_DEST_ID_H INTEGER 77 "MSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_H DEFAULT_VALUE 77
set_parameter_property PKT_DEST_ID_H DISPLAY_NAME "Packet destination id field index - high"
set_parameter_property PKT_DEST_ID_H TYPE INTEGER
set_parameter_property PKT_DEST_ID_H UNITS None
set_parameter_property PKT_DEST_ID_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_DEST_ID_H DESCRIPTION "MSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_H HDL_PARAMETER true
add_parameter PKT_DEST_ID_L INTEGER 75 "LSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_L DEFAULT_VALUE 75
set_parameter_property PKT_DEST_ID_L DISPLAY_NAME "Packet destination id field index - low"
set_parameter_property PKT_DEST_ID_L TYPE INTEGER
set_parameter_property PKT_DEST_ID_L UNITS None
set_parameter_property PKT_DEST_ID_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_DEST_ID_L DESCRIPTION "LSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_L HDL_PARAMETER true
add_parameter PKT_BURSTWRAP_H INTEGER 85 "MSB of the packet burstwrap field index"
set_parameter_property PKT_BURSTWRAP_H DEFAULT_VALUE 85
set_parameter_property PKT_BURSTWRAP_H DISPLAY_NAME "Packet burstwrap field index - high"
set_parameter_property PKT_BURSTWRAP_H TYPE INTEGER
set_parameter_property PKT_BURSTWRAP_H UNITS None
set_parameter_property PKT_BURSTWRAP_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BURSTWRAP_H DESCRIPTION "MSB of the packet burstwrap field index"
set_parameter_property PKT_BURSTWRAP_H HDL_PARAMETER true
add_parameter PKT_BURSTWRAP_L INTEGER 82 "LSB of the packet burstwrap field index"
set_parameter_property PKT_BURSTWRAP_L DEFAULT_VALUE 82
set_parameter_property PKT_BURSTWRAP_L DISPLAY_NAME "Packet burstwrap field index - low"
set_parameter_property PKT_BURSTWRAP_L TYPE INTEGER
set_parameter_property PKT_BURSTWRAP_L UNITS None
set_parameter_property PKT_BURSTWRAP_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BURSTWRAP_L DESCRIPTION "LSB of the packet burstwrap field index"
set_parameter_property PKT_BURSTWRAP_L HDL_PARAMETER true
add_parameter PKT_BYTE_CNT_H INTEGER 81 "MSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_H DEFAULT_VALUE 81
set_parameter_property PKT_BYTE_CNT_H DISPLAY_NAME "Packet byte count field index - high"
set_parameter_property PKT_BYTE_CNT_H TYPE INTEGER
set_parameter_property PKT_BYTE_CNT_H UNITS None
set_parameter_property PKT_BYTE_CNT_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTE_CNT_H DESCRIPTION "MSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_H HDL_PARAMETER true
add_parameter PKT_BYTE_CNT_L INTEGER 78 "LSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_L DEFAULT_VALUE 78
set_parameter_property PKT_BYTE_CNT_L DISPLAY_NAME "Packet byte count field index - low"
set_parameter_property PKT_BYTE_CNT_L TYPE INTEGER
set_parameter_property PKT_BYTE_CNT_L UNITS None
set_parameter_property PKT_BYTE_CNT_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTE_CNT_L DESCRIPTION "LSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_L HDL_PARAMETER true
add_parameter PKT_PROTECTION_H INTEGER 86 "MSB of the packet protection field index"
set_parameter_property PKT_PROTECTION_H DEFAULT_VALUE 86
set_parameter_property PKT_PROTECTION_H DISPLAY_NAME "Packet protection field index - high"
set_parameter_property PKT_PROTECTION_H TYPE INTEGER
set_parameter_property PKT_PROTECTION_H UNITS None
set_parameter_property PKT_PROTECTION_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_PROTECTION_H DESCRIPTION "MSB of the packet protection field index"
set_parameter_property PKT_PROTECTION_H HDL_PARAMETER true
add_parameter PKT_PROTECTION_L INTEGER 86 "LSB of the packet protection field index"
set_parameter_property PKT_PROTECTION_L DEFAULT_VALUE 86
set_parameter_property PKT_PROTECTION_L DISPLAY_NAME "Packet protection field index - low"
set_parameter_property PKT_PROTECTION_L TYPE INTEGER
set_parameter_property PKT_PROTECTION_L UNITS None
set_parameter_property PKT_PROTECTION_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_PROTECTION_L DESCRIPTION "LSB of the packet protection field index"
set_parameter_property PKT_PROTECTION_L HDL_PARAMETER true
add_parameter PKT_RESPONSE_STATUS_H INTEGER 89 "MSB of the packet response field index"
set_parameter_property PKT_RESPONSE_STATUS_H DEFAULT_VALUE 89
set_parameter_property PKT_RESPONSE_STATUS_H DISPLAY_NAME "Packet response field index - high"
set_parameter_property PKT_RESPONSE_STATUS_H TYPE INTEGER
set_parameter_property PKT_RESPONSE_STATUS_H UNITS None
set_parameter_property PKT_RESPONSE_STATUS_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_RESPONSE_STATUS_H DESCRIPTION "MSB of the packet response field index"
set_parameter_property PKT_RESPONSE_STATUS_H HDL_PARAMETER true
add_parameter PKT_RESPONSE_STATUS_L INTEGER 88 "LSB of the packet response field index"
set_parameter_property PKT_RESPONSE_STATUS_L DEFAULT_VALUE 88
set_parameter_property PKT_RESPONSE_STATUS_L DISPLAY_NAME "Packet response field index - low"
set_parameter_property PKT_RESPONSE_STATUS_L TYPE INTEGER
set_parameter_property PKT_RESPONSE_STATUS_L UNITS None
set_parameter_property PKT_RESPONSE_STATUS_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_RESPONSE_STATUS_L DESCRIPTION "LSB of the packet response field index"
set_parameter_property PKT_RESPONSE_STATUS_L HDL_PARAMETER true
add_parameter PKT_THREAD_ID_H INTEGER 88 "MSB of the packet thread id field index"
set_parameter_property PKT_THREAD_ID_H DEFAULT_VALUE 88
set_parameter_property PKT_THREAD_ID_H DISPLAY_NAME "Packet thread id field index - high"
set_parameter_property PKT_THREAD_ID_H TYPE INTEGER
set_parameter_property PKT_THREAD_ID_H UNITS None
set_parameter_property PKT_THREAD_ID_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_THREAD_ID_H DESCRIPTION "MSB of the packet thread id field index"
set_parameter_property PKT_THREAD_ID_H HDL_PARAMETER true
add_parameter PKT_THREAD_ID_L INTEGER 87 "LSB of the packet thread id field index"
set_parameter_property PKT_THREAD_ID_L DEFAULT_VALUE 87
set_parameter_property PKT_THREAD_ID_L DISPLAY_NAME "Packet thread id field index - low"
set_parameter_property PKT_THREAD_ID_L TYPE INTEGER
set_parameter_property PKT_THREAD_ID_L UNITS None
set_parameter_property PKT_THREAD_ID_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_THREAD_ID_L DESCRIPTION "LSB of the packet thread id field index"
set_parameter_property PKT_THREAD_ID_L HDL_PARAMETER true
add_parameter PKT_CACHE_H INTEGER 92 "MSB of the packet cache field index"
set_parameter_property PKT_CACHE_H DEFAULT_VALUE 92
set_parameter_property PKT_CACHE_H DISPLAY_NAME "Packet cache field index - high"
set_parameter_property PKT_CACHE_H TYPE INTEGER
set_parameter_property PKT_CACHE_H UNITS None
set_parameter_property PKT_CACHE_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_CACHE_H DESCRIPTION "MSB of the packet cache field index"
set_parameter_property PKT_CACHE_H HDL_PARAMETER true
add_parameter PKT_CACHE_L INTEGER 89 "LSB of the packet cache field index"
set_parameter_property PKT_CACHE_L DEFAULT_VALUE 89
set_parameter_property PKT_CACHE_L DISPLAY_NAME "Packet cache field index - low"
set_parameter_property PKT_CACHE_L TYPE INTEGER
set_parameter_property PKT_CACHE_L UNITS None
set_parameter_property PKT_CACHE_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_CACHE_L DESCRIPTION "LSB of the packet cache field index"
set_parameter_property PKT_CACHE_L HDL_PARAMETER true
add_parameter PKT_DATA_SIDEBAND_H INTEGER 105 "MSB of the data address sideband field index"
set_parameter_property PKT_DATA_SIDEBAND_H DEFAULT_VALUE 105
set_parameter_property PKT_DATA_SIDEBAND_H DISPLAY_NAME "Packet data sideband field index - high"
set_parameter_property PKT_DATA_SIDEBAND_H TYPE INTEGER
set_parameter_property PKT_DATA_SIDEBAND_H UNITS None
set_parameter_property PKT_DATA_SIDEBAND_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_DATA_SIDEBAND_H DESCRIPTION "MSB of the data address sideband field index"
set_parameter_property PKT_DATA_SIDEBAND_H HDL_PARAMETER true
add_parameter PKT_DATA_SIDEBAND_L INTEGER 98 "LSB of the data address sideband field index"
set_parameter_property PKT_DATA_SIDEBAND_L DEFAULT_VALUE 98
set_parameter_property PKT_DATA_SIDEBAND_L DISPLAY_NAME "Packet data sideband field index - low"
set_parameter_property PKT_DATA_SIDEBAND_L TYPE INTEGER
set_parameter_property PKT_DATA_SIDEBAND_L UNITS None
set_parameter_property PKT_DATA_SIDEBAND_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_DATA_SIDEBAND_L DESCRIPTION "LSB of the data address sideband field index"
set_parameter_property PKT_DATA_SIDEBAND_L HDL_PARAMETER true
add_parameter PKT_QOS_H INTEGER 109 "MSB of the qos address sideband field index"
set_parameter_property PKT_QOS_H DEFAULT_VALUE 109
set_parameter_property PKT_QOS_H DISPLAY_NAME "Packet qos sideband field index - high"
set_parameter_property PKT_QOS_H TYPE INTEGER
set_parameter_property PKT_QOS_H UNITS None
set_parameter_property PKT_QOS_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_QOS_H DESCRIPTION "MSB of the qos address sideband field index"
set_parameter_property PKT_QOS_H HDL_PARAMETER true
add_parameter PKT_QOS_L INTEGER 106 "LSB of the qos address sideband field index"
set_parameter_property PKT_QOS_L DEFAULT_VALUE 106
set_parameter_property PKT_QOS_L DISPLAY_NAME "Packet qos sideband field index - low"
set_parameter_property PKT_QOS_L TYPE INTEGER
set_parameter_property PKT_QOS_L UNITS None
set_parameter_property PKT_QOS_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_QOS_L DESCRIPTION "LSB of the qos address sideband field index"
set_parameter_property PKT_QOS_L HDL_PARAMETER true
add_parameter PKT_ADDR_SIDEBAND_H INTEGER 97 "MSB of the packet address sideband field index"
set_parameter_property PKT_ADDR_SIDEBAND_H DEFAULT_VALUE 97
set_parameter_property PKT_ADDR_SIDEBAND_H DISPLAY_NAME "Packet address sideband field index - high"
set_parameter_property PKT_ADDR_SIDEBAND_H TYPE INTEGER
set_parameter_property PKT_ADDR_SIDEBAND_H UNITS None
set_parameter_property PKT_ADDR_SIDEBAND_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_ADDR_SIDEBAND_H DESCRIPTION "MSB of the packet address sideband field index"
set_parameter_property PKT_ADDR_SIDEBAND_H HDL_PARAMETER true
add_parameter PKT_ADDR_SIDEBAND_L INTEGER 93 "LSB of the packet address sideband field index"
set_parameter_property PKT_ADDR_SIDEBAND_L DEFAULT_VALUE 93
set_parameter_property PKT_ADDR_SIDEBAND_L DISPLAY_NAME "Packet address sideband field index - low"
set_parameter_property PKT_ADDR_SIDEBAND_L TYPE INTEGER
set_parameter_property PKT_ADDR_SIDEBAND_L UNITS None
set_parameter_property PKT_ADDR_SIDEBAND_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_ADDR_SIDEBAND_L DESCRIPTION "LSB of the packet address sideband field index"
set_parameter_property PKT_ADDR_SIDEBAND_L HDL_PARAMETER true
add_parameter PKT_BURST_SIZE_H INTEGER 92 "MSB of the packet burst size field index"
set_parameter_property PKT_BURST_SIZE_H DEFAULT_VALUE 92
set_parameter_property PKT_BURST_SIZE_H DISPLAY_NAME "Packet burst size field index - high"
set_parameter_property PKT_BURST_SIZE_H TYPE INTEGER
set_parameter_property PKT_BURST_SIZE_H UNITS None
set_parameter_property PKT_BURST_SIZE_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BURST_SIZE_H DESCRIPTION "MSB of the packet burst size field index"
set_parameter_property PKT_BURST_SIZE_H HDL_PARAMETER true
add_parameter PKT_BURST_SIZE_L INTEGER 90 "LSB of the packet burst size field index"
set_parameter_property PKT_BURST_SIZE_L DEFAULT_VALUE 90
set_parameter_property PKT_BURST_SIZE_L DISPLAY_NAME "Packet burst size field index - low"
set_parameter_property PKT_BURST_SIZE_L TYPE INTEGER
set_parameter_property PKT_BURST_SIZE_L UNITS None
set_parameter_property PKT_BURST_SIZE_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BURST_SIZE_L DESCRIPTION "LSB of the packet burst size field index"
set_parameter_property PKT_BURST_SIZE_L HDL_PARAMETER true
add_parameter PKT_BURST_TYPE_H INTEGER 94 "MSB of the packet bursttype field index"
set_parameter_property PKT_BURST_TYPE_H DEFAULT_VALUE 94
set_parameter_property PKT_BURST_TYPE_H DISPLAY_NAME "Packet bursttype field index - high"
set_parameter_property PKT_BURST_TYPE_H TYPE INTEGER
set_parameter_property PKT_BURST_TYPE_H UNITS None
set_parameter_property PKT_BURST_TYPE_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BURST_TYPE_H DESCRIPTION "MSB of the packet bursttype field index"
set_parameter_property PKT_BURST_TYPE_H HDL_PARAMETER true
add_parameter PKT_BURST_TYPE_L INTEGER 93 "LSB of the packet bursttype field index"
set_parameter_property PKT_BURST_TYPE_L DEFAULT_VALUE 93
set_parameter_property PKT_BURST_TYPE_L DISPLAY_NAME "Packet bursttype field index - low"
set_parameter_property PKT_BURST_TYPE_L TYPE INTEGER
set_parameter_property PKT_BURST_TYPE_L UNITS None
set_parameter_property PKT_BURST_TYPE_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BURST_TYPE_L DESCRIPTION "LSB of the packet bursttype field index"
set_parameter_property PKT_BURST_TYPE_L HDL_PARAMETER true
add_parameter PKT_TRANS_EXCLUSIVE INTEGER 83 "Packet exclusive transaction field index"
set_parameter_property PKT_TRANS_EXCLUSIVE DEFAULT_VALUE 83
set_parameter_property PKT_TRANS_EXCLUSIVE DISPLAY_NAME "Packet exclusive transaction field index"
set_parameter_property PKT_TRANS_EXCLUSIVE TYPE INTEGER
set_parameter_property PKT_TRANS_EXCLUSIVE UNITS None
set_parameter_property PKT_TRANS_EXCLUSIVE ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_TRANS_EXCLUSIVE DESCRIPTION "Packet exclusive transaction field index"
set_parameter_property PKT_TRANS_EXCLUSIVE HDL_PARAMETER true
add_parameter PKT_ORI_BURST_SIZE_L INTEGER 118
set_parameter_property PKT_ORI_BURST_SIZE_L DISPLAY_NAME "Packet original burst size index - low"
set_parameter_property PKT_ORI_BURST_SIZE_L TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_L UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_L DESCRIPTION "LSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_L AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_L HDL_PARAMETER true
add_parameter PKT_ORI_BURST_SIZE_H INTEGER 120
set_parameter_property PKT_ORI_BURST_SIZE_H DISPLAY_NAME "Packet original burst size index - high"
set_parameter_property PKT_ORI_BURST_SIZE_H TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_H UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_H DESCRIPTION "MSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_H AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_H HDL_PARAMETER true
add_parameter ST_CHANNEL_W INTEGER 8 "Streaming channel width"
set_parameter_property ST_CHANNEL_W DEFAULT_VALUE 8
set_parameter_property ST_CHANNEL_W DISPLAY_NAME "Streaming channel width"
set_parameter_property ST_CHANNEL_W TYPE INTEGER
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION "Streaming channel width"
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true
add_parameter ST_DATA_W INTEGER 121 "StreamingPacket data width"
set_parameter_property ST_DATA_W DEFAULT_VALUE 121
set_parameter_property ST_DATA_W DISPLAY_NAME "Streaming data width"
set_parameter_property ST_DATA_W TYPE INTEGER
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ST_DATA_W DESCRIPTION "StreamingPacket data width"
set_parameter_property ST_DATA_W HDL_PARAMETER true
add_parameter MERLIN_PACKET_FORMAT STRING "" "Merlin packet format descriptor"
set_parameter_property MERLIN_PACKET_FORMAT DEFAULT_VALUE ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME "Merlin packet format descriptor"
set_parameter_property MERLIN_PACKET_FORMAT TYPE STRING
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION "Merlin packet format descriptor"
add_parameter ID INTEGER 1 "Network-domain-unique Slave ID"
set_parameter_property ID DEFAULT_VALUE 1
set_parameter_property ID DISPLAY_NAME "Slave ID"
set_parameter_property ID TYPE INTEGER
set_parameter_property ID UNITS None
set_parameter_property ID ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ID DESCRIPTION "Network-domain-unique Slave ID"

# +-----------------------------------
# | Set all parameters to AFFECTS_GENERATION false
# | 
foreach parameter [get_parameters] { 
	set_parameter_property $parameter AFFECTS_GENERATION false 
 }
# | 
# +-----------------------------------

# 
# display items
# 
add_display_item "APB Parameters" ADDR_WIDTH PARAMETER ""
add_display_item "APB Parameters" DATA_WIDTH PARAMETER ""
add_display_item "Packet Parameters" PKT_DATA_H PARAMETER ""
add_display_item "Packet Parameters" PKT_DATA_L PARAMETER ""
add_display_item "Packet Parameters" PKT_BEGIN_BURST PARAMETER ""
add_display_item "Packet Parameters" PKT_SYMBOL_W PARAMETER ""
add_display_item "Packet Parameters" PKT_BYTEEN_H PARAMETER ""
add_display_item "Packet Parameters" PKT_BYTEEN_L PARAMETER ""
add_display_item "Packet Parameters" PKT_ADDR_H PARAMETER ""
add_display_item "Packet Parameters" PKT_ADDR_L PARAMETER ""
add_display_item "Packet Parameters" PKT_TRANS_COMPRESSED_READ PARAMETER ""
add_display_item "Packet Parameters" PKT_TRANS_POSTED PARAMETER ""
add_display_item "Packet Parameters" PKT_TRANS_WRITE PARAMETER ""
add_display_item "Packet Parameters" PKT_TRANS_READ PARAMETER ""
add_display_item "Packet Parameters" PKT_TRANS_LOCK PARAMETER ""
add_display_item "Packet Parameters" PKT_SRC_ID_H PARAMETER ""
add_display_item "Packet Parameters" PKT_SRC_ID_L PARAMETER ""
add_display_item "Packet Parameters" PKT_DEST_ID_H PARAMETER ""
add_display_item "Packet Parameters" PKT_DEST_ID_L PARAMETER ""
add_display_item "Packet Parameters" PKT_BURSTWRAP_H PARAMETER ""
add_display_item "Packet Parameters" PKT_BURSTWRAP_L PARAMETER ""
add_display_item "Packet Parameters" PKT_BYTE_CNT_H PARAMETER ""
add_display_item "Packet Parameters" PKT_BYTE_CNT_L PARAMETER ""
add_display_item "Packet Parameters" PKT_PROTECTION_H PARAMETER ""
add_display_item "Packet Parameters" PKT_PROTECTION_L PARAMETER ""
add_display_item "Packet Parameters" PKT_RESPONSE_STATUS_H PARAMETER ""
add_display_item "Packet Parameters" PKT_RESPONSE_STATUS_L PARAMETER ""
add_display_item "Packet Parameters" PKT_BURST_TYPE_H PARAMETER ""
add_display_item "Packet Parameters" PKT_BURST_TYPE_L PARAMETER ""
add_display_item "Packet Parameters" PKT_ORI_BURST_SIZE_H PARAMETER ""
add_display_item "Packet Parameters" PKT_ORI_BURST_SIZE_L PARAMETER ""
add_display_item "Packet Parameters" PKT_BURST_SIZE_H PARAMETER ""
add_display_item "Packet Parameters" PKT_BURST_SIZE_L PARAMETER ""
add_display_item "Packet Parameters" PKT_TRANS_EXCLUSIVE PARAMETER ""
add_display_item "Packet Parameters" PKT_THREAD_ID_H PARAMETER ""
add_display_item "Packet Parameters" PKT_THREAD_ID_L PARAMETER ""
add_display_item "Packet Parameters" PKT_CACHE_H PARAMETER ""
add_display_item "Packet Parameters" PKT_CACHE_L PARAMETER ""
add_display_item "Packet Parameters" PKT_DATA_SIDEBAND_H PARAMETER ""
add_display_item "Packet Parameters" PKT_DATA_SIDEBAND_L PARAMETER ""
add_display_item "Packet Parameters" PKT_QOS_H PARAMETER ""
add_display_item "Packet Parameters" PKT_QOS_L PARAMETER ""
add_display_item "Packet Parameters" PKT_ADDR_SIDEBAND_H PARAMETER ""
add_display_item "Packet Parameters" PKT_ADDR_SIDEBAND_L PARAMETER ""
add_display_item "Packet Parameters" ST_CHANNEL_W PARAMETER ""
add_display_item "Packet Parameters" ST_DATA_W PARAMETER ""
add_display_item "Packet Parameters" MERLIN_PACKET_FORMAT PARAMETER ""
add_display_item "Packet Parameters" ID PARAMETER ""


# 
# connection point altera_apb_master
# 
add_interface altera_apb_master apb start
set_interface_property altera_apb_master associatedClock clk
set_interface_property altera_apb_master associatedReset clk_reset
set_interface_property altera_apb_master ENABLED true

add_interface_port altera_apb_master paddr paddr Output 32
set_port_property paddr vhdl_type std_logic_vector
# add_interface_port altera_apb_master pprot pprot Output 3
add_interface_port altera_apb_master psel psel Output 1
add_interface_port altera_apb_master penable penable Output 1
add_interface_port altera_apb_master pwrite pwrite Output 1
add_interface_port altera_apb_master pwdata pwdata Output 32
set_port_property pwdata vhdl_type std_logic_vector
# add_interface_port altera_apb_master pstrb pstrb Output 4
add_interface_port altera_apb_master pready pready Input 1
add_interface_port altera_apb_master prdata prdata Input 32
set_port_property prdata vhdl_type std_logic_vector
add_interface_port altera_apb_master pslverr pslverr Input 1
add_interface_port altera_apb_master paddr31 paddr31 Output 1

# 
# connection point cp
# 
add_interface cp avalon_streaming end
set_interface_property cp associatedClock clk
set_interface_property cp associatedReset clk_reset
set_interface_property cp dataBitsPerSymbol 8
set_interface_property cp errorDescriptor ""
set_interface_property cp firstSymbolInHighOrderBits true
set_interface_property cp maxChannel 0
set_interface_property cp readyLatency 0
set_interface_property cp ENABLED true

add_interface_port cp cp_valid valid Input 1
add_interface_port cp cp_ready ready Output 1
add_interface_port cp cp_data data Input 128
set_port_property cp_data vhdl_type std_logic_vector
add_interface_port cp cp_channel channel Input 1
set_port_property cp_channel vhdl_type std_logic_vector
add_interface_port cp cp_startofpacket startofpacket Input 1
add_interface_port cp cp_endofpacket endofpacket Input 1


# 
# connection point rp
# 
add_interface rp avalon_streaming start
set_interface_property rp associatedClock clk
set_interface_property rp associatedReset clk_reset
set_interface_property rp dataBitsPerSymbol 8
set_interface_property rp errorDescriptor ""
set_interface_property rp firstSymbolInHighOrderBits true
set_interface_property rp maxChannel 0
set_interface_property rp readyLatency 0
set_interface_property rp ENABLED true

add_interface_port rp rp_valid valid Output 1
add_interface_port rp rp_ready ready Input 1
add_interface_port rp rp_data data Output 128
set_port_property rp_data vhdl_type std_logic_vector
add_interface_port rp rp_startofpacket startofpacket Output 1
add_interface_port rp rp_endofpacket endofpacket Output 1


# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true

add_interface_port clk clk clk Input 1


# 
# connection point clk_reset
# 
add_interface clk_reset reset end
set_interface_property clk_reset associatedClock clk
set_interface_property clk_reset synchronousEdges DEASSERT
set_interface_property clk_reset ENABLED true

add_interface_port clk_reset reset reset Input 1

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {
    set st_data_width [ get_parameter_value ST_DATA_W ]
    set channel_width [ get_parameter_value ST_CHANNEL_W ]
    set data_high     [ get_parameter_value PKT_DATA_H ]
    set data_low      [ get_parameter_value PKT_DATA_L ]
    set data_width    [ expr ($data_high - $data_low + 1) ]
    set addr_high     [ get_parameter_value PKT_ADDR_H ]
    set addr_low      [ get_parameter_value PKT_ADDR_L ]
    set addr_width    [ get_parameter_value ADDR_WIDTH ]
    set field_info    [ get_parameter_value MERLIN_PACKET_FORMAT ]
    # +-----------------------------------
    # | Set correct width for each signals
    # +-----------------------------------    
    set_port_property paddr  			WIDTH_EXPR $addr_width
    set_port_property pwdata            WIDTH_EXPR $data_width
    set_port_property prdata            WIDTH_EXPR $data_width
    set_port_property cp_data		    WIDTH_EXPR $st_data_width
    set_port_property rp_data	        WIDTH_EXPR $st_data_width
    set_port_property cp_channel  		WIDTH_EXPR $channel_width
    
    set_interface_property cp 	dataBitsPerSymbol $st_data_width
    set_interface_property rp  	dataBitsPerSymbol $st_data_width
    
    set_interface_assignment cp merlin.packet_format $field_info
    set_interface_assignment rp merlin.packet_format $field_info

    set_interface_assignment altera_apb_master merlin.flow.rp rp
    set_interface_assignment cp merlin.flow.altera_apb_master altera_apb_master
}
