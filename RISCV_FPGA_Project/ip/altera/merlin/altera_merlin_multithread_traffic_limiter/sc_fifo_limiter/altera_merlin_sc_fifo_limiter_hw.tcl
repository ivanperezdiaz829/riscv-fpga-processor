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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_multithread_traffic_limiter/sc_fifo_limiter/altera_merlin_sc_fifo_limiter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +--------------------------------------------------------------------------
# | altera_merlin_sc_fifo_limiter: 
# | this component is  a composed component
# | which wraps around current "altera_merlin_traffic_limiter" with all its functions
# | and a sc_fifo connect to the input of the limiter
# | The fifo can be turned on/off or change depth parameters.
# +--------------------------------------------------------------------------

package require -exact qsys 13.1

# module properties
set_module_property NAME {altera_merlin_sc_fifo_limiter}
set_module_property DISPLAY_NAME {Memory-Mapped Combined sc_fifo Limiter}
set_module_property COMPOSITION_CALLBACK compose
# default module properties
set_module_property VERSION  13.1
set_module_property GROUP "Qsys Interconnect/Memory-Mapped"
set_module_property AUTHOR {tgngo}

# 
# parameters
# 
add_parameter MAX_BURST_LENGTH INTEGER 0 "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH DEFAULT_VALUE 0
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
add_parameter VALID_WIDTH INTEGER 1 "Width of the valid signal"
set_parameter_property VALID_WIDTH DEFAULT_VALUE 1
set_parameter_property VALID_WIDTH DISPLAY_NAME "Valid width"
set_parameter_property VALID_WIDTH TYPE INTEGER
set_parameter_property VALID_WIDTH UNITS None
set_parameter_property VALID_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property VALID_WIDTH DESCRIPTION "Width of the valid signal"
set_parameter_property VALID_WIDTH HDL_PARAMETER true
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

add_parameter SYMBOLS_PER_BEAT INTEGER 1 ""
set_parameter_property SYMBOLS_PER_BEAT DEFAULT_VALUE 1
set_parameter_property SYMBOLS_PER_BEAT DISPLAY_NAME "Symbols per beat"
set_parameter_property SYMBOLS_PER_BEAT TYPE INTEGER
set_parameter_property SYMBOLS_PER_BEAT UNITS None
set_parameter_property SYMBOLS_PER_BEAT ALLOWED_RANGES -2147483648:2147483647
set_parameter_property SYMBOLS_PER_BEAT DESCRIPTION ""
set_parameter_property SYMBOLS_PER_BEAT HDL_PARAMETER true
add_parameter BITS_PER_SYMBOL INTEGER 8 ""
set_parameter_property BITS_PER_SYMBOL DEFAULT_VALUE 8
set_parameter_property BITS_PER_SYMBOL DERIVED true
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
set_parameter_property BITS_PER_SYMBOL TYPE INTEGER
set_parameter_property BITS_PER_SYMBOL UNITS None
set_parameter_property BITS_PER_SYMBOL ALLOWED_RANGES -2147483648:2147483647
set_parameter_property BITS_PER_SYMBOL DESCRIPTION ""
set_parameter_property BITS_PER_SYMBOL HDL_PARAMETER true
add_parameter FIFO_DEPTH INTEGER 16 ""
set_parameter_property FIFO_DEPTH DEFAULT_VALUE 16
set_parameter_property FIFO_DEPTH DISPLAY_NAME "FIFO depth"
set_parameter_property FIFO_DEPTH TYPE INTEGER
set_parameter_property FIFO_DEPTH UNITS None
set_parameter_property FIFO_DEPTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property FIFO_DEPTH DESCRIPTION ""
set_parameter_property FIFO_DEPTH HDL_PARAMETER true
add_parameter CHANNEL_WIDTH INTEGER 0 ""
set_parameter_property CHANNEL_WIDTH DEFAULT_VALUE 0
set_parameter_property CHANNEL_WIDTH DERIVED true
set_parameter_property CHANNEL_WIDTH DISPLAY_NAME "Channel width"
set_parameter_property CHANNEL_WIDTH TYPE INTEGER
set_parameter_property CHANNEL_WIDTH UNITS None
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CHANNEL_WIDTH DESCRIPTION ""
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true
add_parameter ERROR_WIDTH INTEGER 0 ""
set_parameter_property ERROR_WIDTH DEFAULT_VALUE 0
set_parameter_property ERROR_WIDTH DISPLAY_NAME "Error width"
set_parameter_property ERROR_WIDTH TYPE INTEGER
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ERROR_WIDTH DESCRIPTION ""
set_parameter_property ERROR_WIDTH HDL_PARAMETER true
add_parameter USE_PACKETS INTEGER 0 ""
set_parameter_property USE_PACKETS DEFAULT_VALUE 1
set_parameter_property USE_PACKETS DERIVED true 
set_parameter_property USE_PACKETS DISPLAY_NAME "Use packets"
set_parameter_property USE_PACKETS TYPE INTEGER
set_parameter_property USE_PACKETS UNITS None
set_parameter_property USE_PACKETS ALLOWED_RANGES -2147483648:2147483647
set_parameter_property USE_PACKETS DESCRIPTION ""
set_parameter_property USE_PACKETS DISPLAY_HINT boolean
set_parameter_property USE_PACKETS HDL_PARAMETER true
add_parameter USE_FILL_LEVEL INTEGER 0 ""
set_parameter_property USE_FILL_LEVEL DEFAULT_VALUE 0
set_parameter_property USE_FILL_LEVEL DISPLAY_NAME "Use fill level"
set_parameter_property USE_FILL_LEVEL TYPE INTEGER
set_parameter_property USE_FILL_LEVEL UNITS None
set_parameter_property USE_FILL_LEVEL ALLOWED_RANGES -2147483648:2147483647
set_parameter_property USE_FILL_LEVEL DESCRIPTION ""
set_parameter_property USE_FILL_LEVEL DISPLAY_HINT boolean
set_parameter_property USE_FILL_LEVEL HDL_PARAMETER true
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
add_parameter USE_STORE_FORWARD INTEGER 0 ""
set_parameter_property USE_STORE_FORWARD DEFAULT_VALUE 0
set_parameter_property USE_STORE_FORWARD DISPLAY_NAME "Use store and forward"
set_parameter_property USE_STORE_FORWARD TYPE INTEGER
set_parameter_property USE_STORE_FORWARD UNITS None
set_parameter_property USE_STORE_FORWARD ALLOWED_RANGES -2147483648:2147483647
set_parameter_property USE_STORE_FORWARD DESCRIPTION ""
set_parameter_property USE_STORE_FORWARD DISPLAY_HINT boolean
set_parameter_property USE_STORE_FORWARD HDL_PARAMETER true
add_parameter USE_ALMOST_FULL_IF INTEGER 0 ""
set_parameter_property USE_ALMOST_FULL_IF DEFAULT_VALUE 0
set_parameter_property USE_ALMOST_FULL_IF DISPLAY_NAME "Use almost full status"
set_parameter_property USE_ALMOST_FULL_IF TYPE INTEGER
set_parameter_property USE_ALMOST_FULL_IF UNITS None
set_parameter_property USE_ALMOST_FULL_IF ALLOWED_RANGES -2147483648:2147483647
set_parameter_property USE_ALMOST_FULL_IF DESCRIPTION ""
set_parameter_property USE_ALMOST_FULL_IF DISPLAY_HINT boolean
set_parameter_property USE_ALMOST_FULL_IF HDL_PARAMETER true
add_parameter USE_ALMOST_EMPTY_IF INTEGER 0 ""
set_parameter_property USE_ALMOST_EMPTY_IF DEFAULT_VALUE 0
set_parameter_property USE_ALMOST_EMPTY_IF DISPLAY_NAME "Use almost empty status"
set_parameter_property USE_ALMOST_EMPTY_IF TYPE INTEGER
set_parameter_property USE_ALMOST_EMPTY_IF UNITS None
set_parameter_property USE_ALMOST_EMPTY_IF ALLOWED_RANGES -2147483648:2147483647
set_parameter_property USE_ALMOST_EMPTY_IF DESCRIPTION ""
set_parameter_property USE_ALMOST_EMPTY_IF DISPLAY_HINT boolean
set_parameter_property USE_ALMOST_EMPTY_IF HDL_PARAMETER true
add_parameter ENABLE_EXPLICIT_MAXCHANNEL BOOLEAN false "Enable explicit maxChannel"
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DEFAULT_VALUE true
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DERIVED true
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DISPLAY_NAME "Enable explicit maxChannel"
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL TYPE BOOLEAN
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL UNITS None
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DESCRIPTION "Enable explicit maxChannel"
add_parameter EXPLICIT_MAXCHANNEL INTEGER 0 "Explicit maxChannel"
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DEFAULT_VALUE true
set_parameter_property EXPLICIT_MAXCHANNEL DEFAULT_VALUE 0
set_parameter_property EXPLICIT_MAXCHANNEL DERIVED true
set_parameter_property EXPLICIT_MAXCHANNEL DISPLAY_NAME "Explicit maxChannel"
set_parameter_property EXPLICIT_MAXCHANNEL TYPE INTEGER
set_parameter_property EXPLICIT_MAXCHANNEL UNITS None
set_parameter_property EXPLICIT_MAXCHANNEL ALLOWED_RANGES -2147483648:2147483647
set_parameter_property EXPLICIT_MAXCHANNEL DESCRIPTION "Explicit maxChannel"


add_parameter NO_FIFO INTEGER 0 ""
set_parameter_property NO_FIFO DEFAULT_VALUE 0
set_parameter_property NO_FIFO DISPLAY_NAME "No FIFO for this threadID"
set_parameter_property NO_FIFO TYPE INTEGER
set_parameter_property NO_FIFO UNITS None
set_parameter_property NO_FIFO ALLOWED_RANGES -2147483648:2147483647
set_parameter_property NO_FIFO DESCRIPTION "if no mean that each threadID has no FIFO to buffer commands"
set_parameter_property NO_FIFO DISPLAY_HINT boolean
set_parameter_property NO_FIFO HDL_PARAMETER false


# 
# display items
# 
add_display_item "Component Setting" NO_FIFO PARAMETER ""
add_display_item "Component Setting" FIFO_DEPTH PARAMETER ""
add_display_item "Traffic Limiter" PKT_DEST_ID_H PARAMETER ""
add_display_item "Traffic Limiter" PKT_DEST_ID_L PARAMETER ""
add_display_item "Traffic Limiter" PKT_SRC_ID_H PARAMETER ""
add_display_item "Traffic Limiter" PKT_SRC_ID_L PARAMETER ""
add_display_item "Traffic Limiter" PKT_TRANS_POSTED PARAMETER ""
add_display_item "Traffic Limiter" PKT_TRANS_WRITE PARAMETER ""
add_display_item "Traffic Limiter" MAX_OUTSTANDING_RESPONSES PARAMETER ""
add_display_item "Traffic Limiter" MAX_BURST_LENGTH PARAMETER ""
add_display_item "Traffic Limiter" PIPELINED PARAMETER ""
add_display_item "Traffic Limiter" ST_DATA_W PARAMETER ""
add_display_item "Traffic Limiter" ST_CHANNEL_W PARAMETER ""
add_display_item "Traffic Limiter" VALID_WIDTH PARAMETER ""
add_display_item "Traffic Limiter" ENFORCE_ORDER PARAMETER ""
add_display_item "Traffic Limiter" PREVENT_HAZARDS PARAMETER ""
add_display_item "Traffic Limiter" PKT_BYTE_CNT_H PARAMETER ""
add_display_item "Traffic Limiter" PKT_BYTE_CNT_L PARAMETER ""
add_display_item "Traffic Limiter" PKT_BYTEEN_H PARAMETER ""
add_display_item "Traffic Limiter" PKT_BYTEEN_L PARAMETER ""
add_display_item "Traffic Limiter" MERLIN_PACKET_FORMAT PARAMETER ""
add_display_item SC_fifo SYMBOLS_PER_BEAT PARAMETER ""
add_display_item SC_fifo BITS_PER_SYMBOL PARAMETER ""
add_display_item SC_fifo CHANNEL_WIDTH PARAMETER ""
add_display_item SC_fifo ERROR_WIDTH PARAMETER ""
add_display_item SC_fifo USE_PACKETS PARAMETER ""
add_display_item SC_fifo USE_FILL_LEVEL PARAMETER ""
add_display_item SC_fifo EMPTY_LATENCY PARAMETER ""
add_display_item SC_fifo USE_MEMORY_BLOCKS PARAMETER ""
add_display_item SC_fifo USE_STORE_FORWARD PARAMETER ""
add_display_item SC_fifo USE_ALMOST_FULL_IF PARAMETER ""
add_display_item SC_fifo USE_ALMOST_EMPTY_IF PARAMETER ""
add_display_item SC_fifo ENABLE_EXPLICIT_MAXCHANNEL PARAMETER ""
add_display_item SC_fifo EXPLICIT_MAXCHANNEL PARAMETER ""

proc log2ceil {num} {

    set val 0
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }

    return $val;
}


proc compose {} {
	# Add instances
	add_instance in_clk altera_clock_bridge 13.1
	set_instance_parameter_value in_clk EXPLICIT_CLOCK_RATE {50000000.0}
	set_instance_parameter_value in_clk NUM_CLOCK_OUTPUTS {1}
	add_instance in_reset altera_reset_bridge 13.1
	set_instance_parameter_value in_reset ACTIVE_LOW_RESET {0}
	set_instance_parameter_value in_reset SYNCHRONOUS_EDGES {deassert}
	set_instance_parameter_value in_reset NUM_RESET_OUTPUTS {1}

	add_instance merlin_traffic_limiter_0 altera_merlin_traffic_limiter 13.1
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_DEST_ID_H {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_DEST_ID_L {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_TRANS_POSTED {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_TRANS_WRITE {0}
	set_instance_parameter_value merlin_traffic_limiter_0 MAX_OUTSTANDING_RESPONSES {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PIPELINED {0}
	set_instance_parameter_value merlin_traffic_limiter_0 ST_DATA_W {72}
	set_instance_parameter_value merlin_traffic_limiter_0 ST_CHANNEL_W {2}
	set_instance_parameter_value merlin_traffic_limiter_0 VALID_WIDTH {1}
	set_instance_parameter_value merlin_traffic_limiter_0 ENFORCE_ORDER {1}
	set_instance_parameter_value merlin_traffic_limiter_0 PREVENT_HAZARDS {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTE_CNT_H {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTE_CNT_L {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTEEN_H {0}
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTEEN_L {0}
	set_instance_parameter_value merlin_traffic_limiter_0 MERLIN_PACKET_FORMAT {}

	# force setting fifo to match limiter which user cannot control these parameter
	set_parameter_value EXPLICIT_MAXCHANNEL 0
	set_parameter_value ENABLE_EXPLICIT_MAXCHANNEL 1
	set_parameter_value USE_PACKETS 1
	
	set_parameter_value CHANNEL_WIDTH [ get_parameter_value "ST_CHANNEL_W" ]
	set_parameter_value BITS_PER_SYMBOL [ get_parameter_value "ST_DATA_W" ]
	
	# sc fifo parameters
	set no_fifo      [ get_parameter_value "NO_FIFO" ]
	set use_fill_level   [ get_parameter_value "USE_FILL_LEVEL" ]
    set symbols_per_beat [ get_parameter_value "SYMBOLS_PER_BEAT" ]
    set bits_per_symbol  [ get_parameter_value "BITS_PER_SYMBOL" ]
    set data_width       [ expr $symbols_per_beat * $bits_per_symbol ]
    set channel_width    [ get_parameter_value "CHANNEL_WIDTH" ]
    set max_channel      [ expr (1 << $channel_width) - 1 ]
    set empty_width      [ log2ceil $symbols_per_beat ] 
    set error_width      [ get_parameter_value "ERROR_WIDTH" ]
    set use_packets      [ get_parameter_value "USE_PACKETS" ]
    set use_almost_full  [ get_parameter_value "USE_ALMOST_FULL_IF" ]
    set use_almost_empty [ get_parameter_value "USE_ALMOST_EMPTY_IF" ]
    set use_store_forward [ get_parameter_value "USE_STORE_FORWARD" ]
    set override_maxchannel [ get_parameter_value "ENABLE_EXPLICIT_MAXCHANNEL" ]
    set override_value      [ get_parameter_value "EXPLICIT_MAXCHANNEL" ]
	set required_depth [ get_parameter_value "FIFO_DEPTH" ]
	set uses_memory    [ get_parameter_value "USE_MEMORY_BLOCKS" ]
	set empty_latency    [ get_parameter_value "EMPTY_LATENCY" ]

	# traffic limiter parameters
	set st_data_width [ get_parameter_value "ST_DATA_W" ]
    set st_chan_width [ get_parameter_value "ST_CHANNEL_W" ]
    set valid_width   [ get_parameter_value "VALID_WIDTH" ]
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
	set byte_cnt_h [ get_parameter_value "PKT_BYTE_CNT_H" ]
	set byte_cnt_l [ get_parameter_value "PKT_BYTE_CNT_L" ]
	set byteen_h [ get_parameter_value "PKT_BYTEEN_H" ]
	set byteen_l [ get_parameter_value "PKT_BYTEEN_L" ]

	set merlin_packet_format [ get_parameter_value "MERLIN_PACKET_FORMAT" ]
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_DEST_ID_H $dest_id_h
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_DEST_ID_L $dest_id_l
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_SRC_ID_H $src_id_h
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_SRC_ID_L $src_id_l
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_TRANS_POSTED $trans_posted
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_TRANS_WRITE $trans_write
	set_instance_parameter_value merlin_traffic_limiter_0 MAX_OUTSTANDING_RESPONSES $max_outstanding_responses
	set_instance_parameter_value merlin_traffic_limiter_0 MAX_BURST_LENGTH $max_burst_length
	set_instance_parameter_value merlin_traffic_limiter_0 PIPELINED $pipeline
	set_instance_parameter_value merlin_traffic_limiter_0 ST_DATA_W $st_data_width
	set_instance_parameter_value merlin_traffic_limiter_0 ST_CHANNEL_W $st_chan_width
	set_instance_parameter_value merlin_traffic_limiter_0 VALID_WIDTH $valid_width
	set_instance_parameter_value merlin_traffic_limiter_0 ENFORCE_ORDER $enforce_order
	set_instance_parameter_value merlin_traffic_limiter_0 PREVENT_HAZARDS $prevent_hard
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTE_CNT_H $byte_cnt_h
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTE_CNT_L $byte_cnt_l
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTEEN_H $byteen_h
	set_instance_parameter_value merlin_traffic_limiter_0 PKT_BYTEEN_L $byteen_l
	set_instance_parameter_value merlin_traffic_limiter_0 MERLIN_PACKET_FORMAT $merlin_packet_format
	
	# This is used to turn on or off the fifo
	if { $no_fifo == 0 } {
	# add in sc fifo
	add_instance sc_fifo_0 altera_avalon_sc_fifo 13.1
	set_instance_parameter_value sc_fifo_0 SYMBOLS_PER_BEAT {1}
	set_instance_parameter_value sc_fifo_0 BITS_PER_SYMBOL {72}
	set_instance_parameter_value sc_fifo_0 FIFO_DEPTH {16}
	set_instance_parameter_value sc_fifo_0 CHANNEL_WIDTH {2}
	set_instance_parameter_value sc_fifo_0 ERROR_WIDTH {0}
	set_instance_parameter_value sc_fifo_0 USE_PACKETS {1}
	set_instance_parameter_value sc_fifo_0 USE_FILL_LEVEL {0}
	set_instance_parameter_value sc_fifo_0 EMPTY_LATENCY {0}
	set_instance_parameter_value sc_fifo_0 USE_MEMORY_BLOCKS {0}
	set_instance_parameter_value sc_fifo_0 USE_STORE_FORWARD {0}
	set_instance_parameter_value sc_fifo_0 USE_ALMOST_FULL_IF {0}
	set_instance_parameter_value sc_fifo_0 USE_ALMOST_EMPTY_IF {0}
	set_instance_parameter_value sc_fifo_0 ENABLE_EXPLICIT_MAXCHANNEL {1}
	set_instance_parameter_value sc_fifo_0 EXPLICIT_MAXCHANNEL {0}
	# pass parameters values to instance

    set_instance_parameter_value sc_fifo_0 SYMBOLS_PER_BEAT $symbols_per_beat
	# reassign fifo width to traffic limtiter width
    set_instance_parameter_value sc_fifo_0 BITS_PER_SYMBOL $st_data_width
    set_instance_parameter_value sc_fifo_0 FIFO_DEPTH $required_depth
    set_instance_parameter_value sc_fifo_0 CHANNEL_WIDTH $st_chan_width
    set_instance_parameter_value sc_fifo_0 ERROR_WIDTH $error_width
    set_instance_parameter_value sc_fifo_0 USE_PACKETS $use_packets
    set_instance_parameter_value sc_fifo_0 USE_FILL_LEVEL $use_fill_level
    # Use register
	set_instance_parameter_value sc_fifo_0 USE_MEMORY_BLOCKS $uses_memory
	set_instance_parameter_value sc_fifo_0 EMPTY_LATENCY $empty_latency
    set_instance_parameter_value sc_fifo_0 USE_STORE_FORWARD $use_store_forward
    set_instance_parameter_value sc_fifo_0 USE_ALMOST_FULL_IF $use_almost_full
    set_instance_parameter_value sc_fifo_0 USE_ALMOST_EMPTY_IF $use_almost_empty
    set_instance_parameter_value sc_fifo_0 ENABLE_EXPLICIT_MAXCHANNEL $override_maxchannel
    set_instance_parameter_value sc_fifo_0 EXPLICIT_MAXCHANNEL $override_value
	# set same channel with limiter

	# connections and connection parameters
	add_connection in_clk.out_clk sc_fifo_0.clk clock
	add_connection in_reset.out_reset sc_fifo_0.clk_reset reset
	add_connection sc_fifo_0.out merlin_traffic_limiter_0.cmd_sink avalon_streaming
	# exported interfaces
	add_interface cmd_sink avalon_streaming sink
	set_interface_property cmd_sink EXPORT_OF sc_fifo_0.in
	} else {
	# reconnect clock direct to the limiter as no more fifo
	# if there is no fifo then export cmd_sink of the traffic limiter to top level
	add_interface cmd_sink avalon_streaming sink
	set_interface_property cmd_sink EXPORT_OF merlin_traffic_limiter_0.cmd_sink
	}

add_connection in_clk.out_clk in_reset.clk clock
add_connection in_clk.out_clk merlin_traffic_limiter_0.clk clock
add_connection in_reset.out_reset merlin_traffic_limiter_0.clk_reset reset
	

# exported interfaces
add_interface clk clock sink
set_interface_property clk EXPORT_OF in_clk.in_clk
add_interface reset reset sink
set_interface_property reset EXPORT_OF in_reset.in_reset


add_interface cmd_src avalon_streaming source
set_interface_property cmd_src EXPORT_OF merlin_traffic_limiter_0.cmd_src
add_interface rsp_src avalon_streaming source
set_interface_property rsp_src EXPORT_OF merlin_traffic_limiter_0.rsp_src
add_interface rsp_sink avalon_streaming sink
set_interface_property rsp_sink EXPORT_OF merlin_traffic_limiter_0.rsp_sink
}