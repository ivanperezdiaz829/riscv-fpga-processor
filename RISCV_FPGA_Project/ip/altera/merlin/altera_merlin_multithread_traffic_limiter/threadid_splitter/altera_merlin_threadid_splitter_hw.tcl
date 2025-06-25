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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_multithread_traffic_limiter/threadid_splitter/altera_merlin_threadid_splitter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +--------------------------------------------------------------------------
# | altera_merlin_threadid_splitter "Memory-Mapped ThreadIDs Splitter" 
# | This component is a composed component whichis used to split incoming thread id
# | to seperated thread ID mapping. Which uses DEMUX and MUX at command and response
# | path to swtich transactions to correct traffic limiter.
# +--------------------------------------------------------------------------


package require -exact qsys 13.1

# module properties
set_module_property NAME {altera_merlin_threadid_splitter}
set_module_property DISPLAY_NAME {Memory-Mapped ThreadIDs Splitter}

# default module properties
set_module_property VERSION  13.1
set_module_property GROUP "Qsys Interconnect/Memory-Mapped"
set_module_property DESCRIPTION "Multiple thread ID splitter"
set_module_property AUTHOR {tgngo}
set_module_property ELABORATION_CALLBACK elaborate
set_module_property COMPOSITION_CALLBACK compose

# +-----------------------------------
# | parameters this composed components
# | 
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

add_parameter CHANNEL_DECODED STRING_LIST 0 
set_parameter_property CHANNEL_DECODED DISPLAY_NAME {Channel Decoded On ThreadID}
set_parameter_property CHANNEL_DECODED UNITS None
set_parameter_property CHANNEL_DECODED HDL_PARAMETER false
set_parameter_property CHANNEL_DECODED GROUP "ID Mapping Table"
set_parameter_property CHANNEL_DECODED DESCRIPTION {Channel Decoded On ThreadID}
set_parameter_property CHANNEL_DECODED AFFECTS_ELABORATION true

add_parameter LOW_ID STRING_LIST 0 
set_parameter_property LOW_ID DISPLAY_NAME {Start ID}
set_parameter_property LOW_ID UNITS None
set_parameter_property LOW_ID HDL_PARAMETER false
set_parameter_property LOW_ID GROUP "ID Mapping Table"
set_parameter_property LOW_ID DESCRIPTION {Start ID}
set_parameter_property LOW_ID AFFECTS_ELABORATION true

add_parameter HIGH_ID STRING_LIST 0
set_parameter_property HIGH_ID DISPLAY_NAME {End ID}
set_parameter_property HIGH_ID UNITS None
set_parameter_property HIGH_ID HDL_PARAMETER false
set_parameter_property HIGH_ID GROUP "ID Mapping Table"
set_parameter_property HIGH_ID DESCRIPTION {End ID}
set_parameter_property HIGH_ID AFFECTS_ELABORATION true

add_parameter BINARY_FORMAT STRING_LIST 00000xxxx001
set_parameter_property BINARY_FORMAT DISPLAY_NAME {ID binary mapping}
set_parameter_property BINARY_FORMAT UNITS None
set_parameter_property BINARY_FORMAT HDL_PARAMETER false
set_parameter_property BINARY_FORMAT GROUP "ID Mapping Table"
set_parameter_property BINARY_FORMAT DESCRIPTION {ID Dis-continous mapping range}
set_parameter_property BINARY_FORMAT AFFECTS_ELABORATION true

add_parameter BINARY_FORMAT_INFO STRING_LIST 11,00000,6,4,001
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
add_parameter FIFO_DEPTH INTEGER 32 0
set_parameter_property FIFO_DEPTH DISPLAY_NAME {Number of Commands that each threadID can store}
set_parameter_property FIFO_DEPTH UNITS None
set_parameter_property FIFO_DEPTH DESCRIPTION {Number of Commands that each threadID can store}
set_parameter_property FIFO_DEPTH AFFECTS_ELABORATION true
add_parameter CHANNEL_TYPE_TRANSACTION STRING "write" 
set_parameter_property CHANNEL_TYPE_TRANSACTION DISPLAY_NAME {Channel Type Transaction}
set_parameter_property CHANNEL_TYPE_TRANSACTION UNITS None
set_parameter_property CHANNEL_TYPE_TRANSACTION HDL_PARAMETER false
set_parameter_property CHANNEL_TYPE_TRANSACTION DESCRIPTION {Channel Type Transaction}
set_parameter_property CHANNEL_TYPE_TRANSACTION AFFECTS_ELABORATION true

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters DEMUX
# | 
add_parameter ST_DATA_W INTEGER 72 0
set_parameter_property ST_DATA_W DISPLAY_NAME {Packet data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_DATA_W DESCRIPTION {Packet data width}
set_parameter_property ST_DATA_W AFFECTS_ELABORATION true
set_parameter_property ST_DATA_W HDL_PARAMETER false
add_parameter ST_CHANNEL_W INTEGER 2 0
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
set_parameter_property ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER false
add_parameter NUM_OUTPUTS INTEGER 2 0
set_parameter_property NUM_OUTPUTS DERIVED true
set_parameter_property NUM_OUTPUTS DISPLAY_NAME {Number of demux outputs}
set_parameter_property NUM_OUTPUTS UNITS None
set_parameter_property NUM_OUTPUTS DESCRIPTION {Number of demux outputs}

add_parameter VALID_WIDTH INTEGER 1 0
set_parameter_property VALID_WIDTH DISPLAY_NAME {Valid width}
set_parameter_property VALID_WIDTH HDL_PARAMETER false
set_parameter_property VALID_WIDTH AFFECTS_ELABORATION true
set_parameter_property VALID_WIDTH DESCRIPTION {Width of the valid signal}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters MUX
# | 
add_parameter NUM_INPUTS INTEGER 2 0
set_parameter_property NUM_INPUTS DISPLAY_NAME {Number of mux inputs}
set_parameter_property NUM_INPUTS UNITS None
set_parameter_property NUM_INPUTS DERIVED true
set_parameter_property NUM_INPUTS DESCRIPTION {Number of mux inputs}
set_parameter_property NUM_INPUTS AFFECTS_ELABORATION true
set_parameter_property NUM_INPUTS HDL_PARAMETER false
add_parameter CMD_PIPELINE_ARB INTEGER 0 0
set_parameter_property CMD_PIPELINE_ARB DISPLAY_NAME {Pipelined arbitration for command mux}
set_parameter_property CMD_PIPELINE_ARB UNITS None
set_parameter_property CMD_PIPELINE_ARB ALLOWED_RANGES 0:1
set_parameter_property CMD_PIPELINE_ARB DESCRIPTION {When enabled, the output of the arbiter is registered, reducing the amount of combinational logic between the master and fabric, increasing the frequency of the system}
set_parameter_property CMD_PIPELINE_ARB AFFECTS_ELABORATION true
set_parameter_property CMD_PIPELINE_ARB HDL_PARAMETER false
set_parameter_property CMD_PIPELINE_ARB DISPLAY_HINT boolean
add_parameter RSP_PIPELINE_ARB INTEGER 0 0
set_parameter_property RSP_PIPELINE_ARB DISPLAY_NAME {Pipelined arbitration for response mux}
set_parameter_property RSP_PIPELINE_ARB UNITS None
set_parameter_property RSP_PIPELINE_ARB ALLOWED_RANGES 0:1
set_parameter_property RSP_PIPELINE_ARB DESCRIPTION {When enabled, the output of the arbiter is registered, reducing the amount of combinational logic between the master and fabric, increasing the frequency of the system}
set_parameter_property RSP_PIPELINE_ARB AFFECTS_ELABORATION true
set_parameter_property RSP_PIPELINE_ARB HDL_PARAMETER false
set_parameter_property RSP_PIPELINE_ARB DISPLAY_HINT boolean
add_parameter USE_EXTERNAL_ARB INTEGER 0 0
set_parameter_property USE_EXTERNAL_ARB VISIBLE false
set_parameter_property USE_EXTERNAL_ARB DISPLAY_NAME {Use external arbitration}
set_parameter_property USE_EXTERNAL_ARB UNITS None
set_parameter_property USE_EXTERNAL_ARB ALLOWED_RANGES 0:1
set_parameter_property USE_EXTERNAL_ARB DESCRIPTION {use external arbitration}
set_parameter_property USE_EXTERNAL_ARB AFFECTS_ELABORATION true
set_parameter_property USE_EXTERNAL_ARB HDL_PARAMETER false
set_parameter_property USE_EXTERNAL_ARB DISPLAY_HINT boolean
add_parameter PKT_TRANS_LOCK INTEGER -1
set_parameter_property PKT_TRANS_LOCK DISPLAY_NAME {Packet lock transaction field index}
set_parameter_property PKT_TRANS_LOCK UNITS None
set_parameter_property PKT_TRANS_LOCK AFFECTS_ELABORATION false
set_parameter_property PKT_TRANS_LOCK HDL_PARAMETER false
set_parameter_property PKT_TRANS_LOCK DESCRIPTION {Packet lock transaction field index}

add_parameter ARBITRATION_SCHEME STRING "round-robin"
set_parameter_property ARBITRATION_SCHEME DESCRIPTION {Arbitration scheme}
set_parameter_property ARBITRATION_SCHEME DISPLAY_NAME {Arbitration scheme}
set_parameter_property ARBITRATION_SCHEME AFFECTS_ELABORATION false
set_parameter_property ARBITRATION_SCHEME HDL_PARAMETER false
set_parameter_property ARBITRATION_SCHEME DESCRIPTION {Arbitration scheme}
set_parameter_property ARBITRATION_SCHEME ALLOWED_RANGES {round-robin fixed-priority no-arb} 

add_parameter ARBITRATION_SHARES INTEGER_LIST 1
set_parameter_property ARBITRATION_SHARES DISPLAY_NAME {Arbitration shares}
set_parameter_property ARBITRATION_SHARES AFFECTS_ELABORATION false
set_parameter_property ARBITRATION_SHARES HDL_PARAMETER false
set_parameter_property ARBITRATION_SHARES GROUP "Arbitration Shares"
set_parameter_property ARBITRATION_SHARES DESCRIPTION {Lists the number of arbitration shares assigned to each master. By default, each master has equal shares}

# | 
# +-----------------------------------
# +-----------------------------------
# | parameters LIMITTER
# | 
add_parameter MAX_BURST_LENGTH INTEGER 16 "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH DEFAULT_VALUE 16
set_parameter_property MAX_BURST_LENGTH DISPLAY_NAME "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH TYPE INTEGER
set_parameter_property MAX_BURST_LENGTH UNITS None
set_parameter_property MAX_BURST_LENGTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MAX_BURST_LENGTH DESCRIPTION "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH HDL_PARAMETER false
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
add_parameter MAX_OUTSTANDING_RESPONSES INTEGER 0 "Maximum number of outstanding responses on any destination"
set_parameter_property MAX_OUTSTANDING_RESPONSES DEFAULT_VALUE 0
set_parameter_property MAX_OUTSTANDING_RESPONSES DISPLAY_NAME "Maximum outstanding responses"
set_parameter_property MAX_OUTSTANDING_RESPONSES TYPE INTEGER
set_parameter_property MAX_OUTSTANDING_RESPONSES UNITS None
set_parameter_property MAX_OUTSTANDING_RESPONSES ALLOWED_RANGES 0:2147483647
set_parameter_property MAX_OUTSTANDING_RESPONSES DESCRIPTION "Maximum number of outstanding responses on any destination"
set_parameter_property MAX_OUTSTANDING_RESPONSES HDL_PARAMETER true
add_parameter PIPELINED INTEGER 0 "Enable internal pipelining"
set_parameter_property PIPELINED DEFAULT_VALUE 0
set_parameter_property PIPELINED DISPLAY_NAME Pipeline
set_parameter_property PIPELINED TYPE INTEGER
set_parameter_property PIPELINED UNITS None
set_parameter_property PIPELINED ALLOWED_RANGES 0:1
set_parameter_property PIPELINED DESCRIPTION "Enable internal pipelining"
set_parameter_property PIPELINED DISPLAY_HINT boolean
set_parameter_property PIPELINED HDL_PARAMETER true
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
add_parameter NO_FIFO INTEGER 0 ""
set_parameter_property NO_FIFO DEFAULT_VALUE 0
set_parameter_property NO_FIFO DISPLAY_NAME "No FIFO for this threadID"
set_parameter_property NO_FIFO TYPE INTEGER
set_parameter_property NO_FIFO UNITS None
set_parameter_property NO_FIFO ALLOWED_RANGES -2147483648:2147483647
set_parameter_property NO_FIFO DESCRIPTION "if no mean that each threadID has no FIFO to buffer commands"
set_parameter_property NO_FIFO DISPLAY_HINT boolean
set_parameter_property NO_FIFO HDL_PARAMETER false

add_parameter EMPTY_LATENCY INTEGER 0 ""
set_parameter_property EMPTY_LATENCY DEFAULT_VALUE 0
set_parameter_property EMPTY_LATENCY DISPLAY_NAME Latency
set_parameter_property EMPTY_LATENCY TYPE INTEGER
set_parameter_property EMPTY_LATENCY UNITS None
set_parameter_property EMPTY_LATENCY ALLOWED_RANGES -2147483648:2147483647
set_parameter_property EMPTY_LATENCY DESCRIPTION ""
set_parameter_property EMPTY_LATENCY HDL_PARAMETER true
add_parameter USE_MEMORY_BLOCKS INTEGER 0 ""
set_parameter_property USE_MEMORY_BLOCKS DEFAULT_VALUE 0
set_parameter_property USE_MEMORY_BLOCKS DISPLAY_NAME "Use memory blocks"
set_parameter_property USE_MEMORY_BLOCKS TYPE INTEGER
set_parameter_property USE_MEMORY_BLOCKS UNITS None
set_parameter_property USE_MEMORY_BLOCKS ALLOWED_RANGES -2147483648:2147483647
set_parameter_property USE_MEMORY_BLOCKS DESCRIPTION ""
set_parameter_property USE_MEMORY_BLOCKS DISPLAY_HINT boolean
set_parameter_property USE_MEMORY_BLOCKS HDL_PARAMETER true

# | 
# +-----------------------------------

add_display_item "Component Settings" NUM_THREAD_ID PARAMETER ""
add_display_item "Component Settings" CHANNEL_TYPE_TRANSACTION PARAMETER ""
add_display_item "Internal fifo Settings" FIFO_DEPTH PARAMETER ""
add_display_item "Internal fifo Settings" NO_FIFO PARAMETER ""
add_display_item "Internal fifo Settings" EMPTY_LATENCY PARAMETER ""
add_display_item "Internal fifo Settings" USE_MEMORY_BLOCKS PARAMETER ""
add_display_item "Common Parameters" ST_DATA_W PARAMETER ""
add_display_item "Common Parameters" VALID_WIDTH PARAMETER ""
add_display_item "Common Parameters" ST_CHANNEL_W PARAMETER ""
add_display_item "Demux Parameters" NUM_OUTPUTS PARAMETER ""

add_display_item "Traffic Limiter Parameters" PKT_DEST_ID_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_DEST_ID_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_SRC_ID_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_SRC_ID_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_TRANS_POSTED PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_TRANS_WRITE PARAMETER ""
add_display_item "Traffic Limiter Parameters" MAX_OUTSTANDING_RESPONSES PARAMETER ""
add_display_item "Traffic Limiter Parameters" MAX_BURST_LENGTH PARAMETER ""
add_display_item "Traffic Limiter Parameters" PIPELINED PARAMETER ""
add_display_item "Traffic Limiter Parameters" ENFORCE_ORDER PARAMETER ""
add_display_item "Traffic Limiter Parameters" PREVENT_HAZARDS PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTE_CNT_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTE_CNT_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTEEN_H PARAMETER ""
add_display_item "Traffic Limiter Parameters" PKT_BYTEEN_L PARAMETER ""
add_display_item "Traffic Limiter Parameters" MERLIN_PACKET_FORMAT PARAMETER ""

add_display_item "Mux Parameters" NUM_INPUTS PARAMETER ""
add_display_item "Mux Parameters" CMD_PIPELINE_ARB PARAMETER ""
add_display_item "Mux Parameters" RSP_PIPELINE_ARB PARAMETER ""
add_display_item "Mux Parameters" USE_EXTERNAL_ARB PARAMETER ""
add_display_item "Mux Parameters" PKT_TRANS_LOCK PARAMETER ""
add_display_item "Mux Parameters" ARBITRATION_SCHEME PARAMETER ""
add_display_item "Mux Parameters" ARBITRATION_SHARES PARAMETER ""

proc terplog2 { x } {
    set i 1
	set log2ceil 0
		set decimal_x [expr $x]
		while {$i < $decimal_x} {
			set log2ceil  [expr $log2ceil + 1]
			set i [expr $i*2]
		}
	return $log2ceil
}    

proc elaborate {} {
	
}

proc compose {} {
	# Instances and instance parameters
	# (disabled instances are intentionally culled)
	add_instance in_clk altera_clock_bridge 13.1
	set_instance_parameter_value in_clk EXPLICIT_CLOCK_RATE {50000000.0}
	set_instance_parameter_value in_clk NUM_CLOCK_OUTPUTS {1}
	add_instance in_reset altera_reset_bridge 13.1
	set_instance_parameter_value in_reset ACTIVE_LOW_RESET {0}
	set_instance_parameter_value in_reset SYNCHRONOUS_EDGES {deassert}
	set_instance_parameter_value in_reset NUM_RESET_OUTPUTS {1}

	add_instance cmd_demultiplexer altera_merlin_demultiplexer 13.1
	set_instance_parameter_value cmd_demultiplexer ST_DATA_W {72}
	set_instance_parameter_value cmd_demultiplexer ST_CHANNEL_W {2}
	set_instance_parameter_value cmd_demultiplexer NUM_OUTPUTS {2}
	set_instance_parameter_value cmd_demultiplexer VALID_WIDTH {1}
	set_instance_parameter_value cmd_demultiplexer MERLIN_PACKET_FORMAT {}

	add_instance cmd_multiplexer altera_merlin_multiplexer 13.1
	set_instance_parameter_value cmd_multiplexer ST_DATA_W {72}
	set_instance_parameter_value cmd_multiplexer ST_CHANNEL_W {2}
	set_instance_parameter_value cmd_multiplexer NUM_INPUTS {2}
	set_instance_parameter_value cmd_multiplexer PIPELINE_ARB {0}
	set_instance_parameter_value cmd_multiplexer USE_EXTERNAL_ARB {0}
	set_instance_parameter_value cmd_multiplexer PKT_TRANS_LOCK {-1}
	set_instance_parameter_value cmd_multiplexer ARBITRATION_SCHEME {round-robin}
	set_instance_parameter_value cmd_multiplexer ARBITRATION_SHARES {1}
	set_instance_parameter_value cmd_multiplexer MERLIN_PACKET_FORMAT {}

	add_instance rsp_demultiplexer altera_merlin_demultiplexer 13.1
	set_instance_parameter_value rsp_demultiplexer ST_DATA_W {72}
	set_instance_parameter_value rsp_demultiplexer ST_CHANNEL_W {2}
	set_instance_parameter_value rsp_demultiplexer NUM_OUTPUTS {2}
	set_instance_parameter_value rsp_demultiplexer VALID_WIDTH {1}
	set_instance_parameter_value rsp_demultiplexer MERLIN_PACKET_FORMAT {}

	add_instance rsp_multiplexer altera_merlin_multiplexer 13.1
	set_instance_parameter_value rsp_multiplexer ST_DATA_W {72}
	set_instance_parameter_value rsp_multiplexer ST_CHANNEL_W {2}
	set_instance_parameter_value rsp_multiplexer NUM_INPUTS {2}
	set_instance_parameter_value rsp_multiplexer PIPELINE_ARB {0}
	set_instance_parameter_value rsp_multiplexer USE_EXTERNAL_ARB {0}
	set_instance_parameter_value rsp_multiplexer PKT_TRANS_LOCK {-1}
	set_instance_parameter_value rsp_multiplexer ARBITRATION_SCHEME {round-robin}
	set_instance_parameter_value rsp_multiplexer ARBITRATION_SHARES {1}
	set_instance_parameter_value rsp_multiplexer MERLIN_PACKET_FORMAT {}

	set num_threads     [ get_parameter_value "NUM_THREAD_ID" ]
	set fifo_depth      [ get_parameter_value "FIFO_DEPTH" ]
	set no_fifo      	[ get_parameter_value "NO_FIFO" ]
	set st_data_width   [expr [ get_parameter_value "ST_DATA_W"] + [ get_parameter_value "ST_CHANNEL_W"]]
	set cmd_pipeline_arb [ get_parameter_value "CMD_PIPELINE_ARB" ]
	set rsp_pipeline_arb [ get_parameter_value "RSP_PIPELINE_ARB" ]
	# set the number of output from demux base on thread, display purppose
	set_parameter_value NUM_OUTPUTS $num_threads
	set_parameter_value NUM_INPUTS $num_threads
	# Do some settings to each DEMUX
	set_instance_parameter_value cmd_demultiplexer NUM_OUTPUTS $num_threads
	set_instance_parameter_value cmd_demultiplexer ST_CHANNEL_W $num_threads
	set_instance_parameter_value cmd_demultiplexer ST_DATA_W $st_data_width
	set_instance_parameter_value rsp_demultiplexer NUM_OUTPUTS $num_threads
	set_instance_parameter_value rsp_demultiplexer ST_CHANNEL_W $num_threads
	set_instance_parameter_value rsp_demultiplexer ST_DATA_W $st_data_width
	# Do setting for MUX
	set_instance_parameter_value cmd_multiplexer NUM_INPUTS  $num_threads
	set_instance_parameter_value cmd_multiplexer ARBITRATION_SCHEME {round-robin}
	set_instance_parameter_value cmd_multiplexer ST_DATA_W $st_data_width
	set_instance_parameter_value cmd_multiplexer ST_CHANNEL_W $num_threads
	set_instance_parameter_value cmd_multiplexer PIPELINE_ARB $cmd_pipeline_arb
	set_instance_parameter_value rsp_multiplexer NUM_INPUTS  $num_threads
	set_instance_parameter_value rsp_multiplexer ST_DATA_W $st_data_width
	set_instance_parameter_value rsp_multiplexer ST_CHANNEL_W $num_threads
	set_instance_parameter_value rsp_multiplexer ARBITRATION_SCHEME {round-robin}
	set_instance_parameter_value rsp_multiplexer PIPELINE_ARB $rsp_pipeline_arb
	
	# read paramters for limiter:
	set dest_id_h [ get_parameter_value "PKT_DEST_ID_H" ]
	set dest_id_l [ get_parameter_value "PKT_DEST_ID_L"]
	set src_id_h [ get_parameter_value "PKT_SRC_ID_H" ]
	set src_id_l [ get_parameter_value "PKT_SRC_ID_L"]
	set trans_posted [ get_parameter_value "PKT_TRANS_POSTED" ]
	set trans_write [ get_parameter_value "PKT_TRANS_WRITE" ]
	set max_outstanding_responses [ get_parameter_value "MAX_OUTSTANDING_RESPONSES" ]
	set max_burst_length [ get_parameter_value "MAX_BURST_LENGTH" ]
	set pipeline [ get_parameter_value "PIPELINED" ]
	set enforce_order [ get_parameter_value "ENFORCE_ORDER" ]
	set prevent_hard [ get_parameter_value "PREVENT_HAZARDS" ]
	# Caculate the max burst length this 
	set byte_cnt_h [ get_parameter_value "PKT_BYTE_CNT_H" ]
	set byte_cnt_l [ get_parameter_value "PKT_BYTE_CNT_L" ]
	set byteen_h [ get_parameter_value "PKT_BYTEEN_H" ]
	set byteen_l [ get_parameter_value "PKT_BYTEEN_L" ]
	set merlin_packet_format [ get_parameter_value "MERLIN_PACKET_FORMAT" ]
	set fifo_empty_latency [ get_parameter_value "EMPTY_LATENCY" ]

	# read some parameters to do setting needed for the fifo
	set threadid_depth      [ get_parameter_value THREAD_ID_DEPTH ]
	set threadid_depth_length   [ llength $threadid_depth]
    set channel_type_transaction [get_parameter_value "CHANNEL_TYPE_TRANSACTION" ]
	#send_message {info} "$channel_type_transaction THREAD_ID_DEPTH=$threadid_depth THREAD_ID_DEPTH_LENGTH=$threadid_depth_length "
	
	#Build a list of the depth for each thread and make sure it is a value of 2 power for the fifo (15 -> it must be 16)
	list next_power_of_2_threadid_depth
	# For write channel, need to * max burst (16) which the master can send so that this thead ID depth 
	# can store a full write command (of course write has data)
	# for read, only one cycle so just keep the depth as normal
	# for optimization, for some system with many threads, use memory block to save resource
	# Any system with more than 8 theard we will use memory for write channel
	if {($num_threads >= 8) && ($channel_type_transaction eq "write")} {
		set use_memory 1
		set empty_latency 3
	} else {
		set use_memory 0
		set empty_latency $fifo_empty_latency
	}
	list final_threadid_fifo_depth
	list turn_off_fifo
	foreach depth $threadid_depth {
		set next_power_of_2_depth [ expr  1 <<  [terplog2 $depth ]]
		lappend next_power_of_2_threadid_depth $next_power_of_2_depth
		# note that heere is normal log2, resutl is the value not the bits to represent that value
		if {$depth == 0} {
			lappend turn_off_fifo 1
		} else {
			lappend turn_off_fifo 0
		}
		if { $channel_type_transaction eq "write" } {
			if {$use_memory == 1} {
				lappend final_threadid_fifo_depth [ expr $next_power_of_2_depth * $max_burst_length]
			} else {
				lappend final_threadid_fifo_depth [ expr $depth * $max_burst_length]
			}
			#lappend final_threadid_fifo_depth [ expr $next_power_of_2_depth * 16]
			#lappend final_threadid_fifo_depth [ expr $depth * $max_burst_length]
		} else {
			#lappend final_threadid_fifo_depth $next_power_of_2_depth
			lappend final_threadid_fifo_depth $depth
		}
	}
	# As for now the fifo use register so there is no restiction of power of 2 depth
	# but maybe for later optimization, still leave the caculation here
	#send_message {info} "next_power_of_2_depth next_power_of_2_threadid_depth=$next_power_of_2_threadid_depth final_threadid_fifo_depth=$final_threadid_fifo_depth turn_off_fifo=$turn_off_fifo"
	#send_message {info} "$threadid_depth=$threadid_depth final_threadid_fifo_depth=$final_threadid_fifo_depth turn_off_fifo=$turn_off_fifo"
	
	# base in number of thread add instances
	for { set i 0 } { $i < $num_threads } { incr i } {
		add_instance merlin_sc_fifo_limiter_${i} altera_merlin_sc_fifo_limiter 13.1
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_DEST_ID_H $dest_id_h
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_DEST_ID_L $dest_id_l
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_SRC_ID_H $src_id_h
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_SRC_ID_L $src_id_l
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_TRANS_POSTED $trans_posted
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_TRANS_WRITE $trans_write
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} MAX_OUTSTANDING_RESPONSES $max_outstanding_responses
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} MAX_BURST_LENGTH $max_burst_length
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PIPELINED $pipeline
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} ST_DATA_W $st_data_width
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} ST_CHANNEL_W $num_threads
		# each of the limiter only use one bit for valid
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} VALID_WIDTH {1} 
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} ENFORCE_ORDER $enforce_order
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PREVENT_HAZARDS $prevent_hard
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_BYTE_CNT_H $byte_cnt_h
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_BYTE_CNT_L $byte_cnt_l
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_BYTEEN_H $byteen_h
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} PKT_BYTEEN_L $byteen_l
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} MERLIN_PACKET_FORMAT $merlin_packet_format
	
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} SYMBOLS_PER_BEAT {1}
		#set_instance_parameter_value merlin_sc_fifo_limiter_${i} FIFO_DEPTH $fifo_depth
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} FIFO_DEPTH [lindex $final_threadid_fifo_depth $i ]
		#set_instance_parameter_value merlin_sc_fifo_limiter_${i} FIFO_DEPTH [lindex $threadid_depth $i ]
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} ERROR_WIDTH {0}
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} USE_FILL_LEVEL {0}
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} EMPTY_LATENCY $empty_latency
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} USE_MEMORY_BLOCKS $use_memory
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} USE_STORE_FORWARD {0}
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} USE_ALMOST_FULL_IF {0}
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} USE_ALMOST_EMPTY_IF {0}
		#set_instance_parameter_value merlin_sc_fifo_limiter_${i} NO_FIFO $no_fifo
		set_instance_parameter_value merlin_sc_fifo_limiter_${i} NO_FIFO [lindex $turn_off_fifo $i ]
		
	}
	# Do some settings to each SC_FIFO plus limiter components,
	#do connection base on number of instance
	for { set i 0 } { $i < $num_threads } { incr i } {
		# connect clock and reset for each instance
	
		add_connection in_clk.out_clk merlin_sc_fifo_limiter_${i}.clk clock
		add_connection in_reset.out_reset merlin_sc_fifo_limiter_${i}.reset reset
		# connect each instance with cmd components, cmd_demux and cmd_mux
		add_connection cmd_demultiplexer.src${i} merlin_sc_fifo_limiter_${i}.cmd_sink avalon_streaming
		add_connection merlin_sc_fifo_limiter_${i}.cmd_src cmd_multiplexer.sink${i} avalon_streaming
		# conenct each instance with rsp components, rsp_demux and rsp_mux
		add_connection rsp_demultiplexer.src${i} merlin_sc_fifo_limiter_${i}.rsp_sink avalon_streaming
		add_connection merlin_sc_fifo_limiter_${i}.rsp_src rsp_multiplexer.sink${i} avalon_streaming
	}
# connections and connection parameters
add_connection in_clk.out_clk in_reset.clk clock
add_connection in_clk.out_clk cmd_demultiplexer.clk clock

add_connection in_reset.out_reset cmd_demultiplexer.clk_reset reset

add_connection in_clk.out_clk cmd_multiplexer.clk clock

add_connection in_reset.out_reset cmd_multiplexer.clk_reset reset

add_connection in_clk.out_clk rsp_demultiplexer.clk clock

add_connection in_reset.out_reset rsp_demultiplexer.clk_reset reset

add_connection in_clk.out_clk rsp_multiplexer.clk clock

add_connection in_reset.out_reset rsp_multiplexer.clk_reset reset

# exported interfaces
add_interface clk clock sink
set_interface_property clk EXPORT_OF in_clk.in_clk
add_interface reset reset sink
set_interface_property reset EXPORT_OF in_reset.in_reset
add_interface cmd_sink avalon_streaming sink
set_interface_property cmd_sink EXPORT_OF cmd_demultiplexer.sink
add_interface cmd_src avalon_streaming source
set_interface_property cmd_src EXPORT_OF cmd_multiplexer.src
add_interface rsp_sink avalon_streaming sink
set_interface_property rsp_sink EXPORT_OF rsp_demultiplexer.sink
add_interface rsp_src avalon_streaming source
set_interface_property rsp_src EXPORT_OF rsp_multiplexer.src
}