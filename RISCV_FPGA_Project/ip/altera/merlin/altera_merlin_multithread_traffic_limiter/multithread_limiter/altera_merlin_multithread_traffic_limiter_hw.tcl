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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_multithread_traffic_limiter/multithread_limiter/altera_merlin_multithread_traffic_limiter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +--------------------------------------------------------------------------
# | altera_merlin_multithread_traffic_limiter "Memory-Mapped Multithread Traffic Limiter" 
# | This is the top composed component which represent a "limiter" and it will replace 
# | current traffic limiter if the masters in system has multi thread requirements
# +--------------------------------------------------------------------------

package require -exact qsys 13.1

# module properties
set_module_property NAME {altera_merlin_multithread_traffic_limiter}
set_module_property DISPLAY_NAME {Memory-Mapped Multithread Traffic Limiter}

# default module properties
set_module_property VERSION  13.1
set_module_property GROUP "Qsys Interconnect/Memory-Mapped"
set_module_property DESCRIPTION {Multiple Thread Traffic Limiter}
set_module_property AUTHOR {tgngo}
set_module_property ELABORATION_CALLBACK elaborate
set_module_property COMPOSITION_CALLBACK compose
set_module_property VALIDATION_CALLBACK validate

# 
# parameters thread ID mapping
# 
add_display_item "" "ID Mapping Table" "group" "table"
add_parameter THREAD_ID INTEGER_LIST 0
set_parameter_property THREAD_ID DISPLAY_NAME {Thread ID}
set_parameter_property THREAD_ID UNITS None
set_parameter_property THREAD_ID HDL_PARAMETER false
set_parameter_property THREAD_ID GROUP "ID Mapping Table"
set_parameter_property THREAD_ID DESCRIPTION {Thread ID}
set_parameter_property THREAD_ID AFFECTS_ELABORATION true

add_parameter THREAD_ID_DEPTH INTEGER_LIST 16
set_parameter_property THREAD_ID_DEPTH DISPLAY_NAME {Thread ID Depth}
set_parameter_property THREAD_ID_DEPTH UNITS None
set_parameter_property THREAD_ID_DEPTH HDL_PARAMETER false
set_parameter_property THREAD_ID_DEPTH GROUP "ID Mapping Table"
set_parameter_property THREAD_ID_DEPTH DESCRIPTION {Thread ID Depth}
set_parameter_property THREAD_ID_DEPTH AFFECTS_ELABORATION true

add_parameter CHANNEL_DECODED STRING_LIST 1 
set_parameter_property CHANNEL_DECODED DISPLAY_NAME {Channel Decoded On ThreadID}
set_parameter_property CHANNEL_DECODED UNITS None
set_parameter_property CHANNEL_DECODED HDL_PARAMETER false
set_parameter_property CHANNEL_DECODED GROUP "ID Mapping Table"
set_parameter_property CHANNEL_DECODED DESCRIPTION {Channel Decoded On ThreadID}
set_parameter_property CHANNEL_DECODED AFFECTS_ELABORATION true

add_parameter LOW_ID STRING_LIST 0x0
set_parameter_property LOW_ID DISPLAY_NAME {Start ID}
set_parameter_property LOW_ID UNITS None
set_parameter_property LOW_ID HDL_PARAMETER false
#set_parameter_property LOW_ID GROUP "ID Mapping Table"
set_parameter_property LOW_ID DESCRIPTION {Start ID}
set_parameter_property LOW_ID AFFECTS_ELABORATION true
set_parameter_property LOW_ID VISIBLE false

add_parameter HIGH_ID STRING_LIST 0xf
set_parameter_property HIGH_ID DISPLAY_NAME {End ID}
set_parameter_property HIGH_ID UNITS None
set_parameter_property HIGH_ID HDL_PARAMETER false
#set_parameter_property HIGH_ID GROUP "ID Mapping Table"
set_parameter_property HIGH_ID DESCRIPTION {End ID}
set_parameter_property HIGH_ID AFFECTS_ELABORATION true
set_parameter_property HIGH_ID VISIBLE false

add_parameter BINARY_FORMAT STRING_LIST 00000xxxx001
set_parameter_property BINARY_FORMAT DISPLAY_NAME {ID binary mapping}
set_parameter_property BINARY_FORMAT UNITS None
set_parameter_property BINARY_FORMAT HDL_PARAMETER false
set_parameter_property BINARY_FORMAT GROUP "ID Mapping Table"
set_parameter_property BINARY_FORMAT DESCRIPTION {ID Dis-continous mapping range}
set_parameter_property BINARY_FORMAT AFFECTS_ELABORATION true

add_parameter BINARY_FORMAT_INFO STRING_LIST "11-00000-6-4-001"
set_parameter_property BINARY_FORMAT_INFO DISPLAY_NAME {Binary mapping ranges infos}
set_parameter_property BINARY_FORMAT_INFO UNITS None
set_parameter_property BINARY_FORMAT_INFO HDL_PARAMETER false
set_parameter_property BINARY_FORMAT_INFO GROUP "ID Mapping Table"
set_parameter_property BINARY_FORMAT_INFO DESCRIPTION {ID Dis-continous mapping range}
set_parameter_property BINARY_FORMAT_INFO AFFECTS_ELABORATION true

add_parameter NUM_THREAD_ID INTEGER 1 0
set_parameter_property NUM_THREAD_ID DISPLAY_NAME {Number of thread IDs}
set_parameter_property NUM_THREAD_ID UNITS None
set_parameter_property NUM_THREAD_ID DESCRIPTION {Number of thread IDs}
set_parameter_property NUM_THREAD_ID AFFECTS_ELABORATION true

add_parameter MAPPING_RANGES_FORMAT STRING "binary" 
set_parameter_property MAPPING_RANGES_FORMAT DISPLAY_NAME {ID Mapping range format}
set_parameter_property MAPPING_RANGES_FORMAT UNITS None
set_parameter_property MAPPING_RANGES_FORMAT HDL_PARAMETER false
set_parameter_property MAPPING_RANGES_FORMAT DESCRIPTION {ID Mapping range format}
set_parameter_property MAPPING_RANGES_FORMAT AFFECTS_ELABORATION true

add_parameter CHANNEL_TYPE_TRANSACTION STRING "write" 
set_parameter_property CHANNEL_TYPE_TRANSACTION DISPLAY_NAME {Channel Type Transaction}
set_parameter_property CHANNEL_TYPE_TRANSACTION UNITS None
set_parameter_property CHANNEL_TYPE_TRANSACTION HDL_PARAMETER false
set_parameter_property CHANNEL_TYPE_TRANSACTION DESCRIPTION {Channel Type Transaction}
set_parameter_property CHANNEL_TYPE_TRANSACTION AFFECTS_ELABORATION true

add_parameter FIFO_DEPTH INTEGER 32 0
set_parameter_property FIFO_DEPTH DISPLAY_NAME {Number of Commands that each threadID can store}
set_parameter_property FIFO_DEPTH UNITS None
set_parameter_property FIFO_DEPTH DESCRIPTION {Number of Commands that each threadID can store}
set_parameter_property FIFO_DEPTH AFFECTS_ELABORATION true
add_parameter NO_FIFO INTEGER 0 ""
set_parameter_property NO_FIFO DEFAULT_VALUE 0
set_parameter_property NO_FIFO DISPLAY_NAME "No FIFO for threadID"
set_parameter_property NO_FIFO TYPE INTEGER
set_parameter_property NO_FIFO UNITS None
set_parameter_property NO_FIFO ALLOWED_RANGES -2147483648:2147483647
set_parameter_property NO_FIFO DESCRIPTION "if no mean that each threadID has no FIFO to buffer commands"
set_parameter_property NO_FIFO DISPLAY_HINT boolean
set_parameter_property NO_FIFO HDL_PARAMETER false

add_parameter MAX_BURST_LENGTH INTEGER 16 "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH DEFAULT_VALUE 16
set_parameter_property MAX_BURST_LENGTH DISPLAY_NAME "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH TYPE INTEGER
set_parameter_property MAX_BURST_LENGTH UNITS None
set_parameter_property MAX_BURST_LENGTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MAX_BURST_LENGTH DESCRIPTION "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH HDL_PARAMETER false

add_parameter MAX_OUTSTANDING_RESPONSES INTEGER 0 "Maximum outstanding responses"
set_parameter_property MAX_OUTSTANDING_RESPONSES DEFAULT_VALUE 0
set_parameter_property MAX_OUTSTANDING_RESPONSES DISPLAY_NAME "Maximum outstanding responses"
set_parameter_property MAX_OUTSTANDING_RESPONSES TYPE INTEGER
set_parameter_property MAX_OUTSTANDING_RESPONSES UNITS None
set_parameter_property MAX_OUTSTANDING_RESPONSES ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MAX_OUTSTANDING_RESPONSES DESCRIPTION "Maximum outstanding responses"
set_parameter_property MAX_OUTSTANDING_RESPONSES HDL_PARAMETER true

add_parameter PKT_THREAD_ID_H INTEGER 0 "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_H DEFAULT_VALUE 0
set_parameter_property PKT_THREAD_ID_H DISPLAY_NAME "Packet thread ID field index MSB"
set_parameter_property PKT_THREAD_ID_H TYPE INTEGER
set_parameter_property PKT_THREAD_ID_H UNITS None
set_parameter_property PKT_THREAD_ID_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_THREAD_ID_H DESCRIPTION "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_H HDL_PARAMETER true
add_parameter PKT_THREAD_ID_L INTEGER 0 "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_L DEFAULT_VALUE 0
set_parameter_property PKT_THREAD_ID_L DISPLAY_NAME "Packet thread ID field index LSB"
set_parameter_property PKT_THREAD_ID_L TYPE INTEGER
set_parameter_property PKT_THREAD_ID_L UNITS None
set_parameter_property PKT_THREAD_ID_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_THREAD_ID_L DESCRIPTION "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_L HDL_PARAMETER true
add_parameter VALID_WIDTH INTEGER 1 "Valid width output vector"
set_parameter_property VALID_WIDTH DEFAULT_VALUE 1
set_parameter_property VALID_WIDTH DISPLAY_NAME "Valid width output vector"
set_parameter_property VALID_WIDTH TYPE INTEGER
set_parameter_property VALID_WIDTH UNITS None
set_parameter_property VALID_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property VALID_WIDTH DESCRIPTION "Valid width output vector"
set_parameter_property VALID_WIDTH HDL_PARAMETER true

add_parameter CMD_ID_MAPPING_IN_ST_DATA_W INTEGER 72 "In Streaming data width ID mapping command"
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W DEFAULT_VALUE 72
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W DISPLAY_NAME "In Streaming data width ID mapping command"
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W TYPE INTEGER
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W UNITS None
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W DERIVED true
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W DESCRIPTION "In Streaming data width ID mapping command"
set_parameter_property CMD_ID_MAPPING_IN_ST_DATA_W HDL_PARAMETER true
add_parameter CMD_ID_MAPPING_IN_ST_CHANNEL_W INTEGER 1 "In Streaming channel width ID mapping command"
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W DEFAULT_VALUE 1
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W DISPLAY_NAME "In Streaming channel width ID mapping command"
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W TYPE INTEGER
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W UNITS None
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W DERIVED true
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W DESCRIPTION "In Streaming channel width ID mapping command"
set_parameter_property CMD_ID_MAPPING_IN_ST_CHANNEL_W HDL_PARAMETER true
add_parameter CMD_ID_MAPPING_OUT_ST_DATA_W INTEGER 74 "Out Streaming data width"
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W DEFAULT_VALUE 74
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W DISPLAY_NAME "Out Streaming data width ID mapping command"
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W TYPE INTEGER
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W UNITS None
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W DERIVED true
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W DESCRIPTION "Output Streaming data width ID mapping command"
set_parameter_property CMD_ID_MAPPING_OUT_ST_DATA_W HDL_PARAMETER true
add_parameter CMD_ID_MAPPING_OUT_ST_CHANNEL_W INTEGER 4 "Out Streaming channel width ID mapping command"
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W DEFAULT_VALUE 4
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W DISPLAY_NAME "Out Streaming channel width ID mapping command"
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W TYPE INTEGER
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W UNITS None
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W DERIVED true
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W DESCRIPTION "Out Streaming channel width ID mapping command"
set_parameter_property CMD_ID_MAPPING_OUT_ST_CHANNEL_W HDL_PARAMETER true

add_parameter RSP_ID_MAPPING_IN_ST_DATA_W INTEGER 72 "In Streaming data width ID mapping response"
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W DEFAULT_VALUE 72
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W DISPLAY_NAME "In Streaming data width ID mapping response"
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W TYPE INTEGER
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W UNITS None
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W DERIVED true
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W DESCRIPTION "In Streaming data width ID mapping response"
set_parameter_property RSP_ID_MAPPING_IN_ST_DATA_W HDL_PARAMETER true
add_parameter RSP_ID_MAPPING_IN_ST_CHANNEL_W INTEGER 1 "In Streaming channel width ID mapping response"
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W DEFAULT_VALUE 1
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W DISPLAY_NAME "In Streaming channel width ID mapping response"
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W TYPE INTEGER
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W UNITS None
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W DERIVED true
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W DESCRIPTION "In Streaming channel width ID mapping response"
set_parameter_property RSP_ID_MAPPING_IN_ST_CHANNEL_W HDL_PARAMETER true
add_parameter RSP_ID_MAPPING_OUT_ST_DATA_W INTEGER 74 "Out Streaming data width"
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W DEFAULT_VALUE 74
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W DISPLAY_NAME "Out Streaming data width ID mapping response"
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W TYPE INTEGER
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W UNITS None
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W DERIVED true
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W DESCRIPTION "Output Streaming data width ID mapping response"
set_parameter_property RSP_ID_MAPPING_OUT_ST_DATA_W HDL_PARAMETER true
add_parameter RSP_ID_MAPPING_OUT_ST_CHANNEL_W INTEGER 4 "Out Streaming channel width ID mapping response"
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W DEFAULT_VALUE 4
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W DISPLAY_NAME "Out Streaming channel width ID mapping response"
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W TYPE INTEGER
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W UNITS None
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W DERIVED true
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W DESCRIPTION "Out Streaming channel width ID mapping response"
set_parameter_property RSP_ID_MAPPING_OUT_ST_CHANNEL_W HDL_PARAMETER true

# -------------------------------------------------------------

# +-----------------------------------
# | parameters LIMITTER
# | 
add_parameter PKT_DEST_ID_H INTEGER 0 "MSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_H DEFAULT_VALUE 0
set_parameter_property PKT_DEST_ID_H DISPLAY_NAME "Packet destination id field index - high"
set_parameter_property PKT_DEST_ID_H TYPE INTEGER
set_parameter_property PKT_DEST_ID_H UNITS None
set_parameter_property PKT_DEST_ID_H ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_DEST_ID_H DESCRIPTION "MSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_H HDL_PARAMETER true
add_parameter PKT_DEST_ID_L INTEGER 0 "LSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_L DEFAULT_VALUE 0
set_parameter_property PKT_DEST_ID_L DISPLAY_NAME "Packet destination id field index - low"
set_parameter_property PKT_DEST_ID_L TYPE INTEGER
set_parameter_property PKT_DEST_ID_L UNITS None
set_parameter_property PKT_DEST_ID_L ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_DEST_ID_L DESCRIPTION "LSB of the packet destination id field index"
set_parameter_property PKT_DEST_ID_L HDL_PARAMETER true
add_parameter PKT_SRC_ID_H INTEGER 0 0
set_parameter_property PKT_SRC_ID_H DISPLAY_NAME {Packet destination id field index - high}
set_parameter_property PKT_SRC_ID_H UNITS None
set_parameter_property PKT_SRC_ID_H ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_SRC_ID_H DESCRIPTION {MSB of the packet destination id field index}
set_parameter_property PKT_SRC_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_H HDL_PARAMETER true
add_parameter PKT_SRC_ID_L INTEGER 0 0
set_parameter_property PKT_SRC_ID_L DISPLAY_NAME {Packet destination id field index - low}
set_parameter_property PKT_SRC_ID_L UNITS None
set_parameter_property PKT_SRC_ID_L ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_SRC_ID_L DESCRIPTION {LSB of the packet destination id field index}
set_parameter_property PKT_SRC_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_L HDL_PARAMETER true
add_parameter PKT_TRANS_POSTED INTEGER 0 "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED DEFAULT_VALUE 0
set_parameter_property PKT_TRANS_POSTED DISPLAY_NAME "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED TYPE INTEGER
set_parameter_property PKT_TRANS_POSTED UNITS None
set_parameter_property PKT_TRANS_POSTED ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_TRANS_POSTED DESCRIPTION "Packet posted transaction field index"
set_parameter_property PKT_TRANS_POSTED HDL_PARAMETER true
add_parameter PKT_TRANS_WRITE INTEGER 0 "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE DEFAULT_VALUE 0
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE TYPE INTEGER
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_TRANS_WRITE DESCRIPTION "Packet write transaction field index"
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER true
add_parameter PIPELINED INTEGER 0 "Enable internal pipelining"
set_parameter_property PIPELINED DEFAULT_VALUE 1
set_parameter_property PIPELINED DISPLAY_NAME Pipeline
set_parameter_property PIPELINED TYPE INTEGER
set_parameter_property PIPELINED UNITS None
set_parameter_property PIPELINED ALLOWED_RANGES 0:1
set_parameter_property PIPELINED DESCRIPTION "Enable internal pipelining"
set_parameter_property PIPELINED DISPLAY_HINT boolean
set_parameter_property PIPELINED HDL_PARAMETER true
add_parameter CMD_PIPELINE_ARB INTEGER 1 "Enable internal pipelining cmd mux"
set_parameter_property CMD_PIPELINE_ARB DEFAULT_VALUE 1
set_parameter_property CMD_PIPELINE_ARB DISPLAY_NAME "Enable Command Mux Pipeline"
set_parameter_property CMD_PIPELINE_ARB TYPE INTEGER
set_parameter_property CMD_PIPELINE_ARB UNITS None
set_parameter_property CMD_PIPELINE_ARB ALLOWED_RANGES 0:1
set_parameter_property CMD_PIPELINE_ARB DESCRIPTION "Enable internal pipelining cmd mux"
set_parameter_property CMD_PIPELINE_ARB DISPLAY_HINT boolean
set_parameter_property CMD_PIPELINE_ARB HDL_PARAMETER true
add_parameter RSP_PIPELINE_ARB INTEGER 1 "Enable internal pipelining rsp mux"
set_parameter_property RSP_PIPELINE_ARB DEFAULT_VALUE 1
set_parameter_property RSP_PIPELINE_ARB DISPLAY_NAME "Enable Response Mux Pipeline"
set_parameter_property RSP_PIPELINE_ARB TYPE INTEGER
set_parameter_property RSP_PIPELINE_ARB UNITS None
set_parameter_property RSP_PIPELINE_ARB ALLOWED_RANGES 0:1
set_parameter_property RSP_PIPELINE_ARB DESCRIPTION "Enable internal pipelining rsp mux"
set_parameter_property RSP_PIPELINE_ARB DISPLAY_HINT boolean
set_parameter_property RSP_PIPELINE_ARB HDL_PARAMETER true

add_parameter CMD_SINK_ID_MAPPING_PIPELINE INTEGER 1 "Enable internal pipelining cmd sink id mapping"
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE DEFAULT_VALUE 1
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE DISPLAY_NAME "Enable pipeline cmd sink id mapping"
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE TYPE INTEGER
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE UNITS None
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE ALLOWED_RANGES 0:1
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE DESCRIPTION "Enable internal pipelining cmd mux"
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE DISPLAY_HINT boolean
set_parameter_property CMD_SINK_ID_MAPPING_PIPELINE HDL_PARAMETER false
add_parameter CMD_SOURCE_ID_MAPPING_PIPELINE INTEGER 1 "Enable internal pipelining cmd source id mapping"
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE DEFAULT_VALUE 1
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE DISPLAY_NAME "Enable pipeline cmd source id mapping"
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE TYPE INTEGER
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE UNITS None
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE ALLOWED_RANGES 0:1
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE DESCRIPTION "Enable internal pipelining cmd mux"
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE DISPLAY_HINT boolean
set_parameter_property CMD_SOURCE_ID_MAPPING_PIPELINE HDL_PARAMETER false
add_parameter RSP_SINK_ID_MAPPING_PIPELINE INTEGER 1 "Enable internal pipelining rsp sink id mapping"
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE DEFAULT_VALUE 1
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE DISPLAY_NAME "Enable pipeline rsp sink id mapping"
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE TYPE INTEGER
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE UNITS None
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE ALLOWED_RANGES 0:1
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE DESCRIPTION "Enable internal pipelining rsp mux"
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE DISPLAY_HINT boolean
set_parameter_property RSP_SINK_ID_MAPPING_PIPELINE HDL_PARAMETER false
add_parameter RSP_SOURCE_ID_MAPPING_PIPELINE INTEGER 1 "Enable internal pipelining rsp source id mapping"
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE DEFAULT_VALUE 1
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE DISPLAY_NAME "Enable pipeline rsp source id mapping"
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE TYPE INTEGER
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE UNITS None
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE ALLOWED_RANGES 0:1
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE DESCRIPTION "Enable internal pipelining rsp mux"
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE DISPLAY_HINT boolean
set_parameter_property RSP_SOURCE_ID_MAPPING_PIPELINE HDL_PARAMETER false


add_parameter ST_DATA_W INTEGER 72 "StreamingPacket data width"
set_parameter_property ST_DATA_W DEFAULT_VALUE 72
set_parameter_property ST_DATA_W DISPLAY_NAME "Streaming data width"
set_parameter_property ST_DATA_W TYPE INTEGER
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_DATA_W DESCRIPTION "StreamingPacket data width"
set_parameter_property ST_DATA_W HDL_PARAMETER true
add_parameter ST_CHANNEL_W INTEGER 1 "Streaming channel width"
set_parameter_property ST_CHANNEL_W DEFAULT_VALUE 1
set_parameter_property ST_CHANNEL_W DISPLAY_NAME "Streaming channel width"
set_parameter_property ST_CHANNEL_W TYPE INTEGER
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION "Streaming channel width"
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true
add_parameter ENFORCE_ORDER INTEGER 1 "Enforce response order by backpressuring destination change while responses are outstanding"
set_parameter_property ENFORCE_ORDER DEFAULT_VALUE 1
set_parameter_property ENFORCE_ORDER DISPLAY_NAME "Enforce order"
set_parameter_property ENFORCE_ORDER TYPE INTEGER
set_parameter_property ENFORCE_ORDER UNITS None
set_parameter_property ENFORCE_ORDER ALLOWED_RANGES 0:1
set_parameter_property ENFORCE_ORDER DESCRIPTION "Enforce response order by backpressuring destination change while responses are outstanding"
set_parameter_property ENFORCE_ORDER DISPLAY_HINT boolean
set_parameter_property ENFORCE_ORDER HDL_PARAMETER true
add_parameter PREVENT_HAZARDS INTEGER 0 "Prevent hazards by backpressuring transaction type change while responses are outstanding"
set_parameter_property PREVENT_HAZARDS DEFAULT_VALUE 0
set_parameter_property PREVENT_HAZARDS DISPLAY_NAME "Prevent hazards"
set_parameter_property PREVENT_HAZARDS TYPE INTEGER
set_parameter_property PREVENT_HAZARDS UNITS None
set_parameter_property PREVENT_HAZARDS ALLOWED_RANGES 0:1
set_parameter_property PREVENT_HAZARDS DESCRIPTION "Prevent hazards by backpressuring transaction type change while responses are outstanding"
set_parameter_property PREVENT_HAZARDS DISPLAY_HINT boolean
set_parameter_property PREVENT_HAZARDS HDL_PARAMETER true
add_parameter PKT_BYTE_CNT_H INTEGER 0 "MSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_H DEFAULT_VALUE 0
set_parameter_property PKT_BYTE_CNT_H DISPLAY_NAME "Packet byte count field index - high"
set_parameter_property PKT_BYTE_CNT_H TYPE INTEGER
set_parameter_property PKT_BYTE_CNT_H UNITS None
set_parameter_property PKT_BYTE_CNT_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTE_CNT_H DESCRIPTION "MSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_H HDL_PARAMETER true
add_parameter PKT_BYTE_CNT_L INTEGER 0 "LSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_L DEFAULT_VALUE 0
set_parameter_property PKT_BYTE_CNT_L DISPLAY_NAME "Packet byte count field index - low"
set_parameter_property PKT_BYTE_CNT_L TYPE INTEGER
set_parameter_property PKT_BYTE_CNT_L UNITS None
set_parameter_property PKT_BYTE_CNT_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTE_CNT_L DESCRIPTION "LSB of the packet byte count field index"
set_parameter_property PKT_BYTE_CNT_L HDL_PARAMETER true
add_parameter PKT_BYTEEN_H INTEGER 0 "MSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_H DEFAULT_VALUE 0
set_parameter_property PKT_BYTEEN_H DISPLAY_NAME "Packet byteenable field index - high"
set_parameter_property PKT_BYTEEN_H TYPE INTEGER
set_parameter_property PKT_BYTEEN_H UNITS None
set_parameter_property PKT_BYTEEN_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTEEN_H DESCRIPTION "MSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_H HDL_PARAMETER true
add_parameter PKT_BYTEEN_L INTEGER 0 "LSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_L DEFAULT_VALUE 0
set_parameter_property PKT_BYTEEN_L DISPLAY_NAME "Packet byteenable field index - low"
set_parameter_property PKT_BYTEEN_L TYPE INTEGER
set_parameter_property PKT_BYTEEN_L UNITS None
set_parameter_property PKT_BYTEEN_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_BYTEEN_L DESCRIPTION "LSB of the packet byteenable field index"
set_parameter_property PKT_BYTEEN_L HDL_PARAMETER true
add_parameter MERLIN_PACKET_FORMAT STRING "" "Merlin packet format descriptor"
set_parameter_property MERLIN_PACKET_FORMAT DEFAULT_VALUE ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME "Merlin packet format descriptor"
set_parameter_property MERLIN_PACKET_FORMAT TYPE STRING
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION "Merlin packet format descriptor"

add_parameter THREADID_INFO STRING "" 0
set_parameter_property THREADID_INFO UNITS None
set_parameter_property THREADID_INFO AFFECTS_ELABORATION true
set_parameter_property THREADID_INFO VISIBLE false
set_parameter_property THREADID_INFO DERIVED true

add_parameter REORDER INTEGER 0 0
set_parameter_property REORDER DISPLAY_NAME {Enable reorder buffer}
set_parameter_property REORDER UNITS None
set_parameter_property REORDER ALLOWED_RANGES 0:1
set_parameter_property REORDER DISPLAY_HINT boolean
set_parameter_property REORDER DESCRIPTION {Enable reorder buffer}
set_parameter_property REORDER AFFECTS_ELABORATION true
set_parameter_property REORDER HDL_PARAMETER false

# | 
# +-----------------------------------


add_display_item "ThreadIDs Settings" NUM_THREAD_ID PARAMETER ""
add_display_item "ThreadIDs Settings" FIFO_DEPTH PARAMETER ""
add_display_item "ThreadIDs Settings" NO_FIFO PARAMETER ""
add_display_item "ThreadIDs Settings" IN_ST_DATA_W PARAMETER ""
add_display_item "ThreadIDs Settings" IN_ST_CHANNEL_W PARAMETER ""
add_display_item "ThreadIDs Settings" MAX_OUTSTANDING_RESPONSES PARAMETER ""
add_display_item "ThreadIDs Settings" PKT_THREAD_ID_H PARAMETER ""
add_display_item "ThreadIDs Settings" PKT_THREAD_ID_L PARAMETER ""
add_display_item "ThreadIDs Settings" OUT_ST_DATA_W PARAMETER ""
add_display_item "ThreadIDs Settings" OUT_ST_CHANNEL_W PARAMETER ""
add_display_item "ThreadIDs Settings" MAPPING_RANGES_FORMAT PARAMETER ""
add_display_item "ThreadIDs Settings" CHANNEL_TYPE_TRANSACTION PARAMETER ""

add_display_item "Traffic Limiter Parameters" ST_DATA_W PARAMETER ""
add_display_item "Traffic Limiter Parameters" ST_CHANNEL_W PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_DEST_ID_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_DEST_ID_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_SRC_ID_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_SRC_ID_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_TRANS_POSTED PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_TRANS_WRITE PARAMETER ""
add_display_item "Traffic Limiter Parameters" VALID_WIDTH PARAMETER ""
add_display_item "Traffic Limiter Parameters" MAX_OUTSTANDING_RESPONSES PARAMETER ""
add_display_item "Traffic Limiter Parameters" MAX_BURST_LENGTH PARAMETER ""
add_display_item "Traffic Limiter Parameters" PIPELINED PARAMETER ""
add_display_item "Traffic Limiter Parameters" REORDER PARAMETER ""
add_display_item "Traffic Limiter Parameters" ENFORCE_ORDER PARAMETER ""
add_display_item "Traffic Limiter Parameters" PREVENT_HAZARDS PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTE_CNT_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTE_CNT_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTEEN_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTEEN_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" MERLIN_PACKET_FORMAT PARAMETER ""

add_display_item "Internal Optimization Pipeline" CMD_PIPELINE_ARB PARAMETER ""
add_display_item "Internal Optimization Pipeline" RSP_PIPELINE_ARB PARAMETER ""
add_display_item "Internal Optimization Pipeline" CMD_SINK_ID_MAPPING_PIPELINE PARAMETER ""
add_display_item "Internal Optimization Pipeline" CMD_SOURCE_ID_MAPPING_PIPELINE PARAMETER ""
add_display_item "Internal Optimization Pipeline" RSP_SINK_ID_MAPPING_PIPELINE PARAMETER ""
add_display_item "Internal Optimization Pipeline" RSP_SOURCE_ID_MAPPING_PIPELINE PARAMETER ""


add_display_item "Command ID mapping Settings" CMD_ID_MAPPING_IN_ST_DATA_W PARAMETER "" 
add_display_item "Command ID mapping Settings" CMD_ID_MAPPING_IN_ST_CHANNEL_W PARAMETER ""
add_display_item "Command ID mapping Settings" CMD_ID_MAPPING_OUT_ST_DATA_W PARAMETER "" 
add_display_item "Command ID mapping Settings" CMD_ID_MAPPING_OUT_ST_CHANNEL_W PARAMETER ""  

add_display_item "Response ID mapping Settings" RSP_ID_MAPPING_IN_ST_DATA_W PARAMETER "" 
add_display_item "Response ID mapping Settings" RSP_ID_MAPPING_IN_ST_CHANNEL_W PARAMETER ""
add_display_item "Response ID mapping Settings" RSP_ID_MAPPING_OUT_ST_DATA_W PARAMETER "" 
add_display_item "Response ID mapping Settings" RSP_ID_MAPPING_OUT_ST_CHANNEL_W PARAMETER ""  

# +----------------------------------------------
# | validate callback
# +----------------------------------------------
proc validate {} {

    set num_threadids       [ get_parameter_value THREAD_ID ]
    set threadid_depth      [ get_parameter_value THREAD_ID_DEPTH ]
	set channel_decoded     [ get_parameter_value CHANNEL_DECODED ]
    set lowid_range         [ get_parameter_value LOW_ID ]
    set highid_range        [ get_parameter_value HIGH_ID ]
	set binary_formats      [ get_parameter_value BINARY_FORMAT ]
	set binary_format_infos [ get_parameter_value BINARY_FORMAT_INFO ]
	set mapping_format		[ get_parameter_value MAPPING_RANGES_FORMAT ]

    set num_threadids_length    [ llength $num_threadids ]
    set threadid_depth_length   [ llength $threadid_depth]
    set channel_decoded_length  [ llength $channel_decoded ]
    set lowid_range_length      [ llength $lowid_range]
    set highid_range_length     [ llength $highid_range]

## Check/Validate lengths are consistent
if { $mapping_format eq "hex" && ($num_threadids_length != $threadid_depth_length  || $num_threadids_length != $lowid_range_length || $num_threadids_length != $highid_range_length || $num_threadids_length != $channel_decoded_length)} {
    send_message {error} "Thread ID Mapping Table not fully specified .... NUM_THREAD_ID=$num_threadids_length, THREAD_ID_DEPTH=$threadid_depth_length CHANNEL_DECODED=$channel_decoded_length LOW_ID=$lowid_range_length HIGH_ID=$highid_range_length"
} else {
    set threadid_info ""
    ## SET slave_info for TERP based on inputs from transform
	# use this if format is hex, 
	if { $mapping_format eq "hex" } {
		foreach threadid ${num_threadids} depthid ${threadid_depth} channel ${channel_decoded} lowid ${lowid_range} highid ${highid_range} {
			if { ! [ string equal "" $threadid_info ] } {
				set threadid_info "$threadid_info,${threadid}:${depthid}:${channel}:${lowid}:${highid}"
			} else {
				set threadid_info "${threadid}:${depthid}:${channel}:${lowid}:${highid}"
			}
		}
	} else {
		# binary format
		foreach threadid ${num_threadids} depthid ${threadid_depth} channel ${channel_decoded} binary_format ${binary_formats} binary_format_info ${binary_format_infos} {
			if { ! [ string equal "" $threadid_info ] } {
				set threadid_info "$threadid_info,${threadid}:${depthid}:${channel}:${binary_format}:${binary_format_info}"
			} else {
				set threadid_info "${threadid}:${depthid}:${channel}:${binary_format}:${binary_format_info}"
			}
		}
	}
	set_parameter_value THREADID_INFO $threadid_info
    }
}
#if { $channel_type_transaction eq "write" } {

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc compose {} {
	# add_instance clk_0 clock_source 13.0
	add_instance in_clk altera_clock_bridge 13.1
	set_instance_parameter_value in_clk EXPLICIT_CLOCK_RATE {50000000.0}
	set_instance_parameter_value in_clk NUM_CLOCK_OUTPUTS {1}
	add_instance in_reset altera_reset_bridge 13.1
	set_instance_parameter_value in_reset ACTIVE_LOW_RESET {0}
	set_instance_parameter_value in_reset SYNCHRONOUS_EDGES {deassert}
	set_instance_parameter_value in_reset NUM_RESET_OUTPUTS {1}

	add_instance merlin_threadid_mapping_rsp altera_merlin_threadid_mapping 13.1
	set_instance_parameter_value merlin_threadid_mapping_rsp NUM_THREAD_ID {2}
	set_instance_parameter_value merlin_threadid_mapping_rsp IN_ST_DATA_W {74}
	set_instance_parameter_value merlin_threadid_mapping_rsp IN_ST_CHANNEL_W {2}
	set_instance_parameter_value merlin_threadid_mapping_rsp MAX_OUTSTANDING_RESPONSES {0}
	set_instance_parameter_value merlin_threadid_mapping_rsp PKT_THREAD_ID_H {0}
	set_instance_parameter_value merlin_threadid_mapping_rsp PKT_THREAD_ID_L {0}
	set_instance_parameter_value merlin_threadid_mapping_rsp OUT_ST_DATA_W {72}
	set_instance_parameter_value merlin_threadid_mapping_rsp OUT_ST_CHANNEL_W {2}
	set_instance_parameter_value merlin_threadid_mapping_rsp VALID_WIDTH {1}

	add_instance merlin_threadid_splitter_0 altera_merlin_threadid_splitter 13.1
	set_instance_parameter_value merlin_threadid_splitter_0 NUM_THREAD_ID {2}
	set_instance_parameter_value merlin_threadid_splitter_0 ST_DATA_W {72}
	set_instance_parameter_value merlin_threadid_splitter_0 ST_CHANNEL_W {2}
	set_instance_parameter_value merlin_threadid_splitter_0 VALID_WIDTH {1}
	set_instance_parameter_value merlin_threadid_splitter_0 CMD_PIPELINE_ARB {0}
	set_instance_parameter_value merlin_threadid_splitter_0 RSP_PIPELINE_ARB {0}
	set_instance_parameter_value merlin_threadid_splitter_0 USE_EXTERNAL_ARB {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_TRANS_LOCK {-1}
	set_instance_parameter_value merlin_threadid_splitter_0 ARBITRATION_SCHEME {round-robin}
	set_instance_parameter_value merlin_threadid_splitter_0 ARBITRATION_SHARES {1}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_DEST_ID_H {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_DEST_ID_L {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_TRANS_POSTED {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_TRANS_WRITE {0}
	set_instance_parameter_value merlin_threadid_splitter_0 MAX_OUTSTANDING_RESPONSES {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PIPELINED {0}
	set_instance_parameter_value merlin_threadid_splitter_0 ENFORCE_ORDER {1}
	set_instance_parameter_value merlin_threadid_splitter_0 PREVENT_HAZARDS {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTE_CNT_H {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTE_CNT_L {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTEEN_H {0}
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTEEN_L {0}
	set_instance_parameter_value merlin_threadid_splitter_0 MERLIN_PACKET_FORMAT {}

	add_instance merlin_threadid_mapping_cmd altera_merlin_threadid_mapping 13.1
	set_instance_parameter_value merlin_threadid_mapping_cmd NUM_THREAD_ID {2}
	set_instance_parameter_value merlin_threadid_mapping_cmd IN_ST_DATA_W {72}
	set_instance_parameter_value merlin_threadid_mapping_cmd IN_ST_CHANNEL_W {1}
	set_instance_parameter_value merlin_threadid_mapping_cmd MAX_OUTSTANDING_RESPONSES {0}
	set_instance_parameter_value merlin_threadid_mapping_cmd PKT_THREAD_ID_H {0}
	set_instance_parameter_value merlin_threadid_mapping_cmd PKT_THREAD_ID_L {0}
	set_instance_parameter_value merlin_threadid_mapping_cmd OUT_ST_DATA_W {74}
	set_instance_parameter_value merlin_threadid_mapping_cmd OUT_ST_CHANNEL_W {2}
	set_instance_parameter_value merlin_threadid_mapping_cmd VALID_WIDTH {1}

	set num_threads     [ get_parameter_value "NUM_THREAD_ID" ]
	set fifo_depth      [ get_parameter_value "FIFO_DEPTH" ]
	set no_fifo      [ get_parameter_value "NO_FIFO" ]
	
	set st_data_width [ get_parameter_value "ST_DATA_W" ]
    set st_chan_width [ get_parameter_value "ST_CHANNEL_W" ]
    set valid_width   [ get_parameter_value "VALID_WIDTH" ]
	set dest_id_h [ get_parameter_value "PKT_DEST_ID_H" ]
	set dest_id_l [ get_parameter_value "PKT_DEST_ID_L"]
	set src_id_h [ get_parameter_value "PKT_SRC_ID_H" ]
	set src_id_l [ get_parameter_value "PKT_SRC_ID_L"]
	set thread_id_h [ get_parameter_value "PKT_THREAD_ID_H" ]
	set thread_id_l [ get_parameter_value "PKT_THREAD_ID_L" ]
	set trans_posted [ get_parameter_value "PKT_TRANS_POSTED" ]
	set trans_write [ get_parameter_value "PKT_TRANS_WRITE" ]
	set max_outstanding_responses [ get_parameter_value "MAX_OUTSTANDING_RESPONSES" ]
	set max_burst_length [ get_parameter_value "MAX_BURST_LENGTH" ]
	set pipeline [ get_parameter_value "PIPELINED" ]
	set enforce_order [ get_parameter_value "ENFORCE_ORDER" ]
	set prevent_hard [ get_parameter_value "PREVENT_HAZARDS" ]
	set byte_cnt_h [ get_parameter_value "PKT_BYTE_CNT_H" ]
	set byte_cnt_l [ get_parameter_value "PKT_BYTE_CNT_L" ]
	set byteen_h [ get_parameter_value "PKT_BYTEEN_H" ]
	set byteen_l [ get_parameter_value "PKT_BYTEEN_L" ]
	set merlin_packet_format [ get_parameter_value "MERLIN_PACKET_FORMAT" ]
	
	# parameter of the ID mapping table
	set thread_id	[ get_parameter_value "THREAD_ID" ]
	set thread_id_depth [ get_parameter_value "THREAD_ID_DEPTH" ]
	set channel_decoded_threadid [ get_parameter_value "CHANNEL_DECODED" ]
	set low_id [ get_parameter_value "LOW_ID" ]
	set high_id [ get_parameter_value "HIGH_ID" ]
	set channel_type_transaction [get_parameter_value "CHANNEL_TYPE_TRANSACTION" ]
	set binary_formats      [ get_parameter_value BINARY_FORMAT ]
	set binary_format_infos [ get_parameter_value BINARY_FORMAT_INFO ]
	set mapping_format		[ get_parameter_value MAPPING_RANGES_FORMAT ]
	set threadid_info       [ get_parameter_value THREADID_INFO ]
	set cmd_mux_pipeline [get_parameter_value "CMD_PIPELINE_ARB" ]
	set rsp_mux_pipeline [get_parameter_value "RSP_PIPELINE_ARB" ]
	set cmd_sink_pipeline [get_parameter_value "CMD_SINK_ID_MAPPING_PIPELINE" ]
	set cmd_source_pipeline [get_parameter_value "CMD_SOURCE_ID_MAPPING_PIPELINE" ]
	set rsp_sink_pipeline [get_parameter_value "RSP_SINK_ID_MAPPING_PIPELINE" ]
	set rsp_source_pipeline [get_parameter_value "RSP_SOURCE_ID_MAPPING_PIPELINE" ]
	
	# pass parameter to limiter
	set_instance_parameter_value merlin_threadid_splitter_0 THREAD_ID $thread_id
	set_instance_parameter_value merlin_threadid_splitter_0 THREAD_ID_DEPTH $thread_id_depth
	set_instance_parameter_value merlin_threadid_splitter_0 CHANNEL_DECODED $channel_decoded_threadid
	set_instance_parameter_value merlin_threadid_splitter_0 LOW_ID $low_id
	set_instance_parameter_value merlin_threadid_splitter_0 HIGH_ID $high_id
	set_instance_parameter_value merlin_threadid_splitter_0 BINARY_FORMAT $binary_formats
	set_instance_parameter_value merlin_threadid_splitter_0 BINARY_FORMAT_INFO $binary_format_infos
	set_instance_parameter_value merlin_threadid_splitter_0 CHANNEL_TYPE_TRANSACTION $channel_type_transaction
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_DEST_ID_H $dest_id_h
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_DEST_ID_L $dest_id_l
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_SRC_ID_H $src_id_h
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_SRC_ID_L $src_id_l
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_TRANS_POSTED $trans_posted
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_TRANS_WRITE $trans_write
	set_instance_parameter_value merlin_threadid_splitter_0 MAX_OUTSTANDING_RESPONSES $max_outstanding_responses
	set_instance_parameter_value merlin_threadid_splitter_0 MAX_BURST_LENGTH $max_burst_length
	set_instance_parameter_value merlin_threadid_splitter_0 PIPELINED $pipeline
	set_instance_parameter_value merlin_threadid_splitter_0 CMD_PIPELINE_ARB $cmd_mux_pipeline
	set_instance_parameter_value merlin_threadid_splitter_0 RSP_PIPELINE_ARB $rsp_mux_pipeline
	set_instance_parameter_value merlin_threadid_splitter_0 ST_DATA_W $st_data_width
	set_instance_parameter_value merlin_threadid_splitter_0 ST_CHANNEL_W $st_chan_width
	set_instance_parameter_value merlin_threadid_splitter_0 VALID_WIDTH $valid_width
	set_instance_parameter_value merlin_threadid_splitter_0 ENFORCE_ORDER $enforce_order
	set_instance_parameter_value merlin_threadid_splitter_0 PREVENT_HAZARDS $prevent_hard
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTE_CNT_H $byte_cnt_h
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTE_CNT_L $byte_cnt_l
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTEEN_H $byteen_h
	set_instance_parameter_value merlin_threadid_splitter_0 PKT_BYTEEN_L $byteen_l
	set_instance_parameter_value merlin_threadid_splitter_0 MERLIN_PACKET_FORMAT $merlin_packet_format
	set_instance_parameter_value merlin_threadid_splitter_0 NUM_THREAD_ID $num_threads
	set_instance_parameter_value merlin_threadid_splitter_0 FIFO_DEPTH $fifo_depth
	set_instance_parameter_value merlin_threadid_splitter_0 NO_FIFO $no_fifo
	
	# set derived parameters to setting ID mapping at command and response
	set_parameter_value CMD_ID_MAPPING_IN_ST_DATA_W $st_data_width
	set_parameter_value CMD_ID_MAPPING_IN_ST_CHANNEL_W $st_chan_width
	set_parameter_value CMD_ID_MAPPING_OUT_ST_DATA_W [expr $st_data_width + $st_chan_width]
	set_parameter_value CMD_ID_MAPPING_OUT_ST_CHANNEL_W $num_threads

	set_parameter_value RSP_ID_MAPPING_IN_ST_DATA_W [expr $st_data_width + $st_chan_width]
	set_parameter_value RSP_ID_MAPPING_IN_ST_CHANNEL_W $num_threads
	set_parameter_value RSP_ID_MAPPING_OUT_ST_DATA_W $st_data_width
	set_parameter_value RSP_ID_MAPPING_OUT_ST_CHANNEL_W $st_chan_width
	
	set cmd_id_mapping_in_st_data_w [ get_parameter_value "CMD_ID_MAPPING_IN_ST_DATA_W" ]
	set cmd_id_mapping_in_st_chan_w [ get_parameter_value "CMD_ID_MAPPING_IN_ST_CHANNEL_W" ]
	set cmd_id_mapping_out_st_data_w [ get_parameter_value "CMD_ID_MAPPING_OUT_ST_DATA_W" ]
	set cmd_id_mapping_out_st_chan_w [ get_parameter_value "CMD_ID_MAPPING_OUT_ST_CHANNEL_W" ] 

	set rsp_id_mapping_in_st_data_w [ get_parameter_value "RSP_ID_MAPPING_IN_ST_DATA_W" ]
	set rsp_id_mapping_in_st_chan_w [ get_parameter_value "RSP_ID_MAPPING_IN_ST_CHANNEL_W" ]
	set rsp_id_mapping_out_st_data_w [ get_parameter_value "RSP_ID_MAPPING_OUT_ST_DATA_W" ]
	set rsp_id_mapping_out_st_chan_w [ get_parameter_value "RSP_ID_MAPPING_OUT_ST_CHANNEL_W" ] 
	
	
	# pass parameter to ID mapping command
	set_instance_parameter_value merlin_threadid_mapping_cmd THREAD_ID $thread_id
	set_instance_parameter_value merlin_threadid_mapping_cmd THREAD_ID_DEPTH $thread_id_depth
	set_instance_parameter_value merlin_threadid_mapping_cmd CHANNEL_DECODED $channel_decoded_threadid
	set_instance_parameter_value merlin_threadid_mapping_cmd LOW_ID $low_id
	set_instance_parameter_value merlin_threadid_mapping_cmd HIGH_ID $high_id
	set_instance_parameter_value merlin_threadid_mapping_cmd BINARY_FORMAT $binary_formats
	set_instance_parameter_value merlin_threadid_mapping_cmd BINARY_FORMAT_INFO $binary_format_infos
	set_instance_parameter_value merlin_threadid_mapping_cmd MAPPING_RANGES_FORMAT $mapping_format
	
	set_instance_parameter_value merlin_threadid_mapping_cmd NUM_THREAD_ID $num_threads
	set_instance_parameter_value merlin_threadid_mapping_cmd IN_ST_DATA_W $cmd_id_mapping_in_st_data_w
	set_instance_parameter_value merlin_threadid_mapping_cmd IN_ST_CHANNEL_W $cmd_id_mapping_in_st_chan_w
	set_instance_parameter_value merlin_threadid_mapping_cmd MAX_OUTSTANDING_RESPONSES $max_outstanding_responses
	set_instance_parameter_value merlin_threadid_mapping_cmd PKT_THREAD_ID_H $thread_id_h
	set_instance_parameter_value merlin_threadid_mapping_cmd PKT_THREAD_ID_L $thread_id_l
	set_instance_parameter_value merlin_threadid_mapping_cmd OUT_ST_DATA_W $cmd_id_mapping_out_st_data_w
	set_instance_parameter_value merlin_threadid_mapping_cmd OUT_ST_CHANNEL_W $cmd_id_mapping_out_st_chan_w
	# think optimize later id need, as this connect to the Demux
	set_instance_parameter_value merlin_threadid_mapping_cmd VALID_WIDTH {1}
	set_instance_parameter_value merlin_threadid_mapping_cmd COMMAND_ID_MAPPER {1}
	set_instance_parameter_value merlin_threadid_mapping_cmd THREADID_INFO $threadid_info
	

	# pass parameter to ID mapping rsp
	set_instance_parameter_value merlin_threadid_mapping_rsp THREAD_ID $thread_id
	set_instance_parameter_value merlin_threadid_mapping_rsp THREAD_ID_DEPTH $thread_id_depth
	set_instance_parameter_value merlin_threadid_mapping_rsp CHANNEL_DECODED $channel_decoded_threadid
	set_instance_parameter_value merlin_threadid_mapping_rsp LOW_ID $low_id
	set_instance_parameter_value merlin_threadid_mapping_rsp HIGH_ID $high_id
	set_instance_parameter_value merlin_threadid_mapping_rsp BINARY_FORMAT $binary_formats
	set_instance_parameter_value merlin_threadid_mapping_rsp BINARY_FORMAT_INFO $binary_format_infos
	set_instance_parameter_value merlin_threadid_mapping_rsp MAPPING_RANGES_FORMAT $mapping_format
	
	set_instance_parameter_value merlin_threadid_mapping_rsp NUM_THREAD_ID $num_threads
	set_instance_parameter_value merlin_threadid_mapping_rsp IN_ST_DATA_W $rsp_id_mapping_in_st_data_w
	set_instance_parameter_value merlin_threadid_mapping_rsp IN_ST_CHANNEL_W $rsp_id_mapping_in_st_chan_w
	set_instance_parameter_value merlin_threadid_mapping_rsp MAX_OUTSTANDING_RESPONSES $max_outstanding_responses
	set_instance_parameter_value merlin_threadid_mapping_rsp PKT_THREAD_ID_H $thread_id_h
	set_instance_parameter_value merlin_threadid_mapping_rsp PKT_THREAD_ID_L $thread_id_l
	set_instance_parameter_value merlin_threadid_mapping_rsp OUT_ST_DATA_W $rsp_id_mapping_out_st_data_w
	set_instance_parameter_value merlin_threadid_mapping_rsp OUT_ST_CHANNEL_W $rsp_id_mapping_out_st_chan_w
	set_instance_parameter_value merlin_threadid_mapping_rsp VALID_WIDTH $valid_width
	set_instance_parameter_value merlin_threadid_mapping_rsp COMMAND_ID_MAPPER {0}
	set_instance_parameter_value merlin_threadid_mapping_rsp THREADID_INFO $threadid_info
	if { $valid_width > 1 } {
		add_interface cmd_valid avalon_streaming start
		# Connect cmd_valid of this component to the cmd_valid of ID mapping in response path
		set_interface_property cmd_valid EXPORT_OF merlin_threadid_mapping_rsp.cmd_valid
		# cmd_src_valid is declared as a vector in HDL, even if width=1
		# Somthing to take note here, cannot do set_property inside compose
		# instead doing it inside child instance
		#set_port_property cmd_src_valid VHDL_TYPE STD_LOGIC_VECTOR
	}
	
	# connections and connection parameters
	add_connection in_clk.out_clk in_reset.clk clock
	add_connection in_clk.out_clk merlin_threadid_splitter_0.clk clock
	add_connection in_reset.out_reset merlin_threadid_splitter_0.reset reset
	add_connection in_clk.out_clk merlin_threadid_mapping_rsp.clk clock
	add_connection in_reset.out_reset merlin_threadid_mapping_rsp.clk_reset reset
	add_connection merlin_threadid_splitter_0.cmd_src merlin_threadid_mapping_rsp.cmd_sink avalon_streaming
	add_connection in_clk.out_clk merlin_threadid_mapping_cmd.clk clock
	add_connection in_reset.out_reset merlin_threadid_mapping_cmd.clk_reset reset
	

	# exported interfaces
	add_interface clk clock sink
	set_interface_property clk EXPORT_OF in_clk.in_clk
	add_interface reset reset sink
	set_interface_property reset EXPORT_OF in_reset.in_reset
	add_interface cmd_src avalon_streaming source
	set_interface_property cmd_src EXPORT_OF merlin_threadid_mapping_rsp.cmd_src
	add_interface rsp_sink avalon_streaming sink
	add_interface rsp_src avalon_streaming source

	add_interface cmd_sink avalon_streaming sink
	set_merlin_assignments
		# Add in those pipeline stages when needed
	if {$cmd_sink_pipeline == 1} {
		add_instance avl_st_pipeline_stage_cmd_sink altera_avalon_st_pipeline_stage 13.1
		set_instance_parameter_value avl_st_pipeline_stage_cmd_sink SYMBOLS_PER_BEAT {1}
		set_instance_parameter_value avl_st_pipeline_stage_cmd_sink BITS_PER_SYMBOL $st_data_width
		set_instance_parameter_value avl_st_pipeline_stage_cmd_sink USE_PACKETS {1}
		set_instance_parameter_value avl_st_pipeline_stage_cmd_sink CHANNEL_WIDTH $st_chan_width
		set_instance_parameter_value avl_st_pipeline_stage_cmd_sink PIPELINE_READY {1}
		#Connections
		add_connection in_clk.out_clk avl_st_pipeline_stage_cmd_sink.cr0 clock
		add_connection in_reset.out_reset avl_st_pipeline_stage_cmd_sink.cr0_reset reset
		
		set_interface_property cmd_sink EXPORT_OF avl_st_pipeline_stage_cmd_sink.sink0
		add_connection avl_st_pipeline_stage_cmd_sink.source0 merlin_threadid_mapping_cmd.cmd_sink avalon_streaming
		add_connection merlin_threadid_mapping_cmd.cmd_src merlin_threadid_splitter_0.cmd_sink avalon_streaming
	} else {
		set_interface_property cmd_sink EXPORT_OF merlin_threadid_mapping_cmd.cmd_sink
		add_connection merlin_threadid_mapping_cmd.cmd_src merlin_threadid_splitter_0.cmd_sink avalon_streaming
	}
	if {$rsp_sink_pipeline == 1} {
		add_instance avl_st_pipeline_stage_rsp_sink altera_avalon_st_pipeline_stage 13.1
		set_instance_parameter_value avl_st_pipeline_stage_rsp_sink SYMBOLS_PER_BEAT {1}
		set_instance_parameter_value avl_st_pipeline_stage_rsp_sink BITS_PER_SYMBOL $st_data_width
		set_instance_parameter_value avl_st_pipeline_stage_rsp_sink USE_PACKETS {1}
		set_instance_parameter_value avl_st_pipeline_stage_rsp_sink CHANNEL_WIDTH $st_chan_width
		set_instance_parameter_value avl_st_pipeline_stage_rsp_sink PIPELINE_READY {1}
		#Connections
		add_connection in_clk.out_clk avl_st_pipeline_stage_rsp_sink.cr0 clock
		add_connection in_reset.out_reset avl_st_pipeline_stage_rsp_sink.cr0_reset reset
		
		set_interface_property rsp_sink EXPORT_OF avl_st_pipeline_stage_rsp_sink.sink0
		add_connection avl_st_pipeline_stage_rsp_sink.source0 merlin_threadid_mapping_rsp.rsp_sink avalon_streaming
		add_connection merlin_threadid_mapping_rsp.rsp_src merlin_threadid_splitter_0.rsp_sink avalon_streaming
	} else {
		set_interface_property rsp_sink EXPORT_OF merlin_threadid_mapping_rsp.rsp_sink
		add_connection merlin_threadid_mapping_rsp.rsp_src merlin_threadid_splitter_0.rsp_sink avalon_streaming
	}
	if {$rsp_source_pipeline == 1} {
		add_instance avl_st_pipeline_stage_rsp_source altera_avalon_st_pipeline_stage 13.1
		set_instance_parameter_value avl_st_pipeline_stage_rsp_source SYMBOLS_PER_BEAT {1}
		set_instance_parameter_value avl_st_pipeline_stage_rsp_source BITS_PER_SYMBOL $st_data_width
		set_instance_parameter_value avl_st_pipeline_stage_rsp_source USE_PACKETS {1}
		set_instance_parameter_value avl_st_pipeline_stage_rsp_source CHANNEL_WIDTH $st_chan_width
		set_instance_parameter_value avl_st_pipeline_stage_rsp_source PIPELINE_READY {1}
		#Connections
		add_connection in_clk.out_clk avl_st_pipeline_stage_rsp_source.cr0 clock
		add_connection in_reset.out_reset avl_st_pipeline_stage_rsp_source.cr0_reset reset
		
		set_interface_property rsp_src EXPORT_OF avl_st_pipeline_stage_rsp_source.source0
		add_connection merlin_threadid_mapping_cmd.rsp_src avl_st_pipeline_stage_rsp_source.sink0 avalon_streaming
		add_connection merlin_threadid_splitter_0.rsp_src merlin_threadid_mapping_cmd.rsp_sink avalon_streaming
	} else {
		set_interface_property rsp_src EXPORT_OF merlin_threadid_mapping_cmd.rsp_src
		add_connection merlin_threadid_splitter_0.rsp_src merlin_threadid_mapping_cmd.rsp_sink avalon_streaming
	}
}

proc set_merlin_assignments { } {
    set field_info    [ get_parameter_value MERLIN_PACKET_FORMAT ]
    set_interface_assignment cmd_sink merlin.packet_format $field_info
    set_interface_assignment cmd_src merlin.packet_format $field_info
    set_interface_assignment rsp_sink merlin.packet_format $field_info
    set_interface_assignment rsp_src merlin.packet_format $field_info

    set_interface_assignment cmd_sink merlin.flow.cmd_src cmd_src
    set_interface_assignment rsp_sink merlin.flow.rsp_src rsp_src
}	