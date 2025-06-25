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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_traffic_limiter/altera_merlin_traffic_limiter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_traffic_limiter "Merlin Traffic Limiter" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------
package require -exact qsys 12.1

# +-----------------------------------
# | module altera_merlin_traffic_limiter
# | 
set_module_property NAME altera_merlin_traffic_limiter
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Memory Mapped Traffic Limiter"
set_module_property DESCRIPTION "Ensures the responses arrive in order, simplifying the Qsys response network."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | Relative path to the pipeline stage, because there is no other
# | way.
# +-----------------------------------

add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_merlin_traffic_limiter 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_merlin_traffic_limiter
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_traffic_limiter

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_merlin_traffic_limiter.sv SYSTEM_VERILOG PATH "altera_merlin_traffic_limiter.sv"
	add_fileset_file altera_merlin_reorder_memory.sv SYSTEM_VERILOG PATH "altera_merlin_reorder_memory.sv"
	 add_fileset_file altera_avalon_sc_fifo.v SYSTEM_VERILOG PATH "../../sopc_builder_ip/altera_avalon_sc_fifo/altera_avalon_sc_fifo.v"
	add_fileset_file altera_avalon_st_pipeline_base.v SYSTEM_VERILOG PATH "../../avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_traffic_limiter.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_traffic_limiter.sv" {MENTOR_SPECIFIC}
	  add_fileset_file mentor/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../../avalon_st/altera_avalon_st_pipeline_stage/mentor/altera_avalon_st_pipeline_base.v" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_traffic_limiter.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_traffic_limiter.sv" {ALDEC_SPECIFIC}
	  add_fileset_file aldec/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../../avalon_st/altera_avalon_st_pipeline_stage/aldec/altera_avalon_st_pipeline_base.v" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_merlin_traffic_limiter.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_traffic_limiter.sv" {CADENCE_SPECIFIC}
	  add_fileset_file cadence/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../../avalon_st/altera_avalon_st_pipeline_stage/cadence/altera_avalon_st_pipeline_base.v" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_merlin_traffic_limiter.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_traffic_limiter.sv" {SYNOPSYS_SPECIFIC}
	  add_fileset_file synopsys/altera_avalon_st_pipeline_base.v SYSTEM_VERILOG_ENCRYPT PATH "../../avalon_st/altera_avalon_st_pipeline_stage/synopsys/altera_avalon_st_pipeline_base.v" {SYNOPSYS_SPECIFIC}
   }    
}

# +-----------------------------------
# | parameters
# | 
add_parameter MAX_BURST_LENGTH INTEGER 0 "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH DEFAULT_VALUE 0
set_parameter_property MAX_BURST_LENGTH DISPLAY_NAME "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH TYPE INTEGER
set_parameter_property MAX_BURST_LENGTH UNITS None
set_parameter_property MAX_BURST_LENGTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MAX_BURST_LENGTH DESCRIPTION "Maximum burst length"
set_parameter_property MAX_BURST_LENGTH HDL_PARAMETER false
add_parameter PKT_DEST_ID_H INTEGER 0 0
set_parameter_property PKT_DEST_ID_H DISPLAY_NAME {Packet destination id field index - high}
set_parameter_property PKT_DEST_ID_H UNITS None
set_parameter_property PKT_DEST_ID_H ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_DEST_ID_H DESCRIPTION {MSB of the packet destination id field index}
set_parameter_property PKT_DEST_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_H HDL_PARAMETER true
add_parameter PKT_DEST_ID_L INTEGER 0 0
set_parameter_property PKT_DEST_ID_L DISPLAY_NAME {Packet destination id field index - low}
set_parameter_property PKT_DEST_ID_L UNITS None
set_parameter_property PKT_DEST_ID_L ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_DEST_ID_L DESCRIPTION {LSB of the packet destination id field index}
set_parameter_property PKT_DEST_ID_L AFFECTS_ELABORATION true
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
add_parameter PKT_TRANS_POSTED INTEGER 0 0
set_parameter_property PKT_TRANS_POSTED DISPLAY_NAME {Packet posted transaction field index}
set_parameter_property PKT_TRANS_POSTED UNITS None
set_parameter_property PKT_TRANS_POSTED ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_TRANS_POSTED DESCRIPTION {Packet posted transaction field index}
set_parameter_property PKT_TRANS_POSTED AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_POSTED HDL_PARAMETER true

add_parameter PKT_TRANS_WRITE INTEGER 0 0
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME {Packet write transaction field index}
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_TRANS_WRITE DESCRIPTION {Packet write transaction field index}
set_parameter_property PKT_TRANS_WRITE AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER true

add_parameter MAX_OUTSTANDING_RESPONSES INTEGER 0 0
set_parameter_property MAX_OUTSTANDING_RESPONSES DISPLAY_NAME {Maximum outstanding responses}
set_parameter_property MAX_OUTSTANDING_RESPONSES UNITS None
set_parameter_property MAX_OUTSTANDING_RESPONSES ALLOWED_RANGES 0:2147483647
set_parameter_property MAX_OUTSTANDING_RESPONSES DESCRIPTION {Maximum number of outstanding responses on any destination}
set_parameter_property MAX_OUTSTANDING_RESPONSES AFFECTS_ELABORATION true
set_parameter_property MAX_OUTSTANDING_RESPONSES HDL_PARAMETER true

add_parameter PIPELINED INTEGER 0 0
set_parameter_property PIPELINED DISPLAY_NAME {Pipeline}
set_parameter_property PIPELINED UNITS None
set_parameter_property PIPELINED ALLOWED_RANGES 0:1
set_parameter_property PIPELINED DISPLAY_HINT boolean
set_parameter_property PIPELINED DESCRIPTION {Enable internal pipelining}
set_parameter_property PIPELINED AFFECTS_ELABORATION true
set_parameter_property PIPELINED HDL_PARAMETER true


add_parameter ST_DATA_W INTEGER 72 0
set_parameter_property ST_DATA_W DISPLAY_NAME {Streaming data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_DATA_W DESCRIPTION {StreamingPacket data width}
set_parameter_property ST_DATA_W AFFECTS_ELABORATION true
set_parameter_property ST_DATA_W HDL_PARAMETER true

add_parameter ST_CHANNEL_W INTEGER 1 0
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
set_parameter_property ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true

add_parameter VALID_WIDTH INTEGER 1 0
set_parameter_property VALID_WIDTH DISPLAY_NAME {Valid width}
set_parameter_property VALID_WIDTH AFFECTS_ELABORATION true
set_parameter_property VALID_WIDTH HDL_PARAMETER true
set_parameter_property VALID_WIDTH DESCRIPTION {Width of the valid signal}

add_parameter ENFORCE_ORDER INTEGER 1 0
set_parameter_property ENFORCE_ORDER DISPLAY_NAME {Enforce order}
set_parameter_property ENFORCE_ORDER AFFECTS_ELABORATION false 
set_parameter_property ENFORCE_ORDER HDL_PARAMETER true
set_parameter_property ENFORCE_ORDER DISPLAY_HINT boolean
set_parameter_property ENFORCE_ORDER ALLOWED_RANGES 0:1
set_parameter_property ENFORCE_ORDER DESCRIPTION {Enforce response order by backpressuring destination change while responses are outstanding}

add_parameter PREVENT_HAZARDS INTEGER 0 0
set_parameter_property PREVENT_HAZARDS DISPLAY_NAME {Prevent hazards}
set_parameter_property PREVENT_HAZARDS AFFECTS_ELABORATION false 
set_parameter_property PREVENT_HAZARDS HDL_PARAMETER true
set_parameter_property PREVENT_HAZARDS DISPLAY_HINT boolean
set_parameter_property PREVENT_HAZARDS ALLOWED_RANGES 0:1
set_parameter_property PREVENT_HAZARDS DESCRIPTION {Prevent hazards by backpressuring transaction type change while responses are outstanding}

add_parameter PKT_BYTE_CNT_H INTEGER 0
set_parameter_property PKT_BYTE_CNT_H DISPLAY_NAME {Packet byte count field index - high}
set_parameter_property PKT_BYTE_CNT_H UNITS None
set_parameter_property PKT_BYTE_CNT_H DISPLAY_HINT ""
set_parameter_property PKT_BYTE_CNT_H AFFECTS_GENERATION false
set_parameter_property PKT_BYTE_CNT_H HDL_PARAMETER true
set_parameter_property PKT_BYTE_CNT_H DESCRIPTION {MSB of the packet byte count field index}

add_parameter PKT_BYTE_CNT_L INTEGER 0
set_parameter_property PKT_BYTE_CNT_L DISPLAY_NAME {Packet byte count field index - low}
set_parameter_property PKT_BYTE_CNT_L UNITS None
set_parameter_property PKT_BYTE_CNT_L DISPLAY_HINT ""
set_parameter_property PKT_BYTE_CNT_L AFFECTS_GENERATION false
set_parameter_property PKT_BYTE_CNT_L HDL_PARAMETER true
set_parameter_property PKT_BYTE_CNT_L DESCRIPTION {LSB of the packet byte count field index}

add_parameter PKT_BYTEEN_H INTEGER 0
set_parameter_property PKT_BYTEEN_H DISPLAY_NAME {Packet byteenable field index - high}
set_parameter_property PKT_BYTEEN_H UNITS None
set_parameter_property PKT_BYTEEN_H DISPLAY_HINT ""
set_parameter_property PKT_BYTEEN_H AFFECTS_GENERATION false
set_parameter_property PKT_BYTEEN_H HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_H DESCRIPTION {MSB of the packet byteenable field index}

add_parameter PKT_BYTEEN_L INTEGER 0
set_parameter_property PKT_BYTEEN_L DISPLAY_NAME {Packet byteenable field index - low}
set_parameter_property PKT_BYTEEN_L UNITS None
set_parameter_property PKT_BYTEEN_L DISPLAY_HINT ""
set_parameter_property PKT_BYTEEN_L AFFECTS_GENERATION false
set_parameter_property PKT_BYTEEN_L HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_L DESCRIPTION {LSB of the packet byteenable field index}

add_parameter PKT_THREAD_ID_H INTEGER 0 "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_H DEFAULT_VALUE 0
set_parameter_property PKT_THREAD_ID_H DISPLAY_NAME "Packet thread ID field index MSB"
set_parameter_property PKT_THREAD_ID_H TYPE INTEGER
set_parameter_property PKT_THREAD_ID_H UNITS None
set_parameter_property PKT_THREAD_ID_H ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_THREAD_ID_H DESCRIPTION "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_H HDL_PARAMETER false
add_parameter PKT_THREAD_ID_L INTEGER 0 "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_L DEFAULT_VALUE 0
set_parameter_property PKT_THREAD_ID_L DISPLAY_NAME "Packet thread ID field index LSB"
set_parameter_property PKT_THREAD_ID_L TYPE INTEGER
set_parameter_property PKT_THREAD_ID_L UNITS None
set_parameter_property PKT_THREAD_ID_L ALLOWED_RANGES -2147483648:2147483647
set_parameter_property PKT_THREAD_ID_L DESCRIPTION "Packet thread ID field index"
set_parameter_property PKT_THREAD_ID_L HDL_PARAMETER false

add_parameter MERLIN_PACKET_FORMAT String ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME {Merlin packet format descriptor}
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION {Merlin packet format descriptor}

add_parameter REORDER INTEGER 0 0
set_parameter_property REORDER DISPLAY_NAME {Enable reorder buffer}
set_parameter_property REORDER UNITS None
set_parameter_property REORDER ALLOWED_RANGES 0:1
set_parameter_property REORDER DISPLAY_HINT boolean
set_parameter_property REORDER DESCRIPTION {Enable reorder buffer}
set_parameter_property REORDER AFFECTS_ELABORATION true
set_parameter_property REORDER HDL_PARAMETER true

# | 
# +-----------------------------------

# +-----------------------------------
# | Set all parameters to AFFECTS_GENERATION false
# | 
foreach parameter [get_parameters] { 
	set_parameter_property $parameter AFFECTS_GENERATION false 
 }
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
add_interface_port clk clk clk Input 1
# +-----------------------------------
# | connection point clk_reset
# | 
add_interface clk_reset reset end
add_interface_port clk_reset reset reset Input 1
set_interface_property clk_reset associatedClock clk
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point cmd_sink
# | 
add_interface cmd_sink avalon_streaming end
set_interface_property cmd_sink dataBitsPerSymbol 8
set_interface_property cmd_sink errorDescriptor ""
set_interface_property cmd_sink maxChannel 0
set_interface_property cmd_sink readyLatency 0
set_interface_property cmd_sink symbolsPerBeat 1

set_interface_property cmd_sink associatedClock clk
set_interface_property cmd_sink associatedReset clk_reset

add_interface_port cmd_sink cmd_sink_ready ready Output 1
add_interface_port cmd_sink cmd_sink_valid valid Input 1
add_interface_port cmd_sink cmd_sink_data data Input 8
add_interface_port cmd_sink cmd_sink_channel channel Input 1
add_interface_port cmd_sink cmd_sink_startofpacket startofpacket Input 1
add_interface_port cmd_sink cmd_sink_endofpacket endofpacket Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point cmd_src
# | 

add_interface cmd_src avalon_streaming start
set_interface_property cmd_src dataBitsPerSymbol 8
set_interface_property cmd_src errorDescriptor ""
set_interface_property cmd_src maxChannel 0
set_interface_property cmd_src readyLatency 0
set_interface_property cmd_src symbolsPerBeat 1

set_interface_property cmd_src associatedClock clk
set_interface_property cmd_src associatedReset clk_reset

add_interface_port cmd_src cmd_src_ready ready Input 1
add_interface_port cmd_src cmd_src_data data Output 8
add_interface_port cmd_src cmd_src_channel channel Output 1
add_interface_port cmd_src cmd_src_startofpacket startofpacket Output 1
add_interface_port cmd_src cmd_src_endofpacket endofpacket Output 1

# | 
# +-----------------------------------


# +-----------------------------------
# | connection point rsp_sink
# |
add_interface rsp_sink avalon_streaming end
set_interface_property rsp_sink dataBitsPerSymbol 8
set_interface_property rsp_sink errorDescriptor ""
set_interface_property rsp_sink maxChannel 0
set_interface_property rsp_sink readyLatency 0
set_interface_property rsp_sink symbolsPerBeat 1

set_interface_property rsp_sink associatedClock clk
set_interface_property rsp_sink associatedReset clk_reset

add_interface_port rsp_sink rsp_sink_ready ready Output 1
add_interface_port rsp_sink rsp_sink_valid valid Input 1
add_interface_port rsp_sink rsp_sink_channel channel Input 1
add_interface_port rsp_sink rsp_sink_data data Input 8
add_interface_port rsp_sink rsp_sink_startofpacket startofpacket Input 1
add_interface_port rsp_sink rsp_sink_endofpacket endofpacket Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point rsp_src
# |
add_interface rsp_src avalon_streaming start
set_interface_property rsp_src dataBitsPerSymbol 8
set_interface_property rsp_src errorDescriptor ""
set_interface_property rsp_src maxChannel 0
set_interface_property rsp_src readyLatency 0
set_interface_property rsp_src symbolsPerBeat 1

set_interface_property rsp_src associatedClock clk
set_interface_property rsp_src associatedReset clk_reset

add_interface_port rsp_src rsp_src_ready ready Input 1
add_interface_port rsp_src rsp_src_valid valid Output 1
add_interface_port rsp_src rsp_src_data data Output 8
add_interface_port rsp_src rsp_src_channel channel Output 1
add_interface_port rsp_src rsp_src_startofpacket startofpacket Output 1
add_interface_port rsp_src rsp_src_endofpacket endofpacket Output 1
# |
# +-----------------------------------


# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

    set st_data_width [ get_parameter_value ST_DATA_W    ]
    set st_chan_width [ get_parameter_value ST_CHANNEL_W ]
    set valid_width   [ get_parameter_value VALID_WIDTH ]

    set_interface_property cmd_sink dataBitsPerSymbol $st_data_width
    set_interface_property cmd_src  dataBitsPerSymbol $st_data_width
    set_interface_property rsp_src  dataBitsPerSymbol $st_data_width
    set_interface_property rsp_sink dataBitsPerSymbol $st_data_width

    set_port_property cmd_sink_data WIDTH_EXPR $st_data_width
	set_port_property  cmd_sink_data vhdl_type std_logic_vector
    set_port_property cmd_src_data  WIDTH_EXPR $st_data_width
	set_port_property  cmd_src_data vhdl_type std_logic_vector
    set_port_property rsp_src_data  WIDTH_EXPR $st_data_width
	set_port_property  rsp_src_data vhdl_type std_logic_vector
    set_port_property rsp_sink_data WIDTH_EXPR $st_data_width
	set_port_property  rsp_sink_data vhdl_type std_logic_vector

    set_port_property rsp_src_channel WIDTH_EXPR $st_chan_width
	set_port_property  rsp_src_channel vhdl_type std_logic_vector
    set_port_property cmd_sink_channel WIDTH_EXPR $st_chan_width
	set_port_property  cmd_sink_channel vhdl_type std_logic_vector
    set_port_property cmd_src_channel WIDTH_EXPR $st_chan_width
	set_port_property  cmd_src_channel vhdl_type std_logic_vector
    set_port_property rsp_sink_channel WIDTH_EXPR $st_chan_width
	set_port_property  rsp_sink_channel vhdl_type std_logic_vector
    
    set_merlin_assignments

    if { $valid_width == 1 } {

        add_interface_port cmd_src cmd_src_valid valid Output 1

    } else {

        add_interface cmd_valid avalon_streaming start
        set_interface_property cmd_valid dataBitsPerSymbol $valid_width
        set_interface_property cmd_valid associatedClock clk
        set_interface_property cmd_valid associatedReset clk_reset

        add_interface_port cmd_valid cmd_src_valid data Output $valid_width
		

    }

    # cmd_src_valid is declared as a vector in HDL, even if width=1
    set_port_property cmd_src_valid VHDL_TYPE STD_LOGIC_VECTOR

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

