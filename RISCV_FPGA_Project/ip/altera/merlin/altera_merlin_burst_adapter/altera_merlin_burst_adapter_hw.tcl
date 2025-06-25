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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_burst_adapter/altera_merlin_burst_adapter_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_burst_adapter "altera_merlin_burst_adapter" v1.0
# | null 2009.04.08.18:32:04
# | 
# | 
# | /data/aferrucc/p4root/acds/main/ip/sopc/components/merlin/altera_merlin_burst_adapter/altera_merlin_burst_adapter.sv
# | 
# |    ./altera_merlin_burst_adapter.sv syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 12.1
# | 
package require -exact qsys 12.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_merlin_burst_adapter
# | 
set_module_property NAME altera_merlin_burst_adapter
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Memory Mapped Burst Adapter"
set_module_property DESCRIPTION "Accommodates the burst capabilities of each interface in the system, including interfaces that do not support burst transfers, translating burst sizes as required."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 

add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_merlin_burst_adapter 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_merlin_burst_adapter
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_burst_adapter

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_merlin_burst_adapter.sv SYSTEM_VERILOG PATH "altera_merlin_burst_adapter.sv"
	add_fileset_file altera_merlin_address_alignment.sv SYSTEM_VERILOG PATH "../altera_merlin_axi_master_ni/altera_merlin_address_alignment.sv"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_burst_adapter.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_burst_adapter.sv" {MENTOR_SPECIFIC}
	  add_fileset_file mentor/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "../altera_merlin_axi_master_ni/mentor/altera_merlin_address_alignment.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_burst_adapter.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_burst_adapter.sv" {ALDEC_SPECIFIC}
	  add_fileset_file aldec/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "../altera_merlin_axi_master_ni/aldec/altera_merlin_address_alignment.sv" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_merlin_burst_adapter.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_burst_adapter.sv" {CADENCE_SPECIFIC}
	  add_fileset_file cadence/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "../altera_merlin_axi_master_ni/cadence/altera_merlin_address_alignment.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_merlin_burst_adapter.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_burst_adapter.sv" {SYNOPSYS_SPECIFIC}
	  add_fileset_file synopsys/altera_merlin_address_alignment.sv SYSTEM_VERILOG_ENCRYPT PATH "../altera_merlin_axi_master_ni/synopsys/altera_merlin_address_alignment.sv" {SYNOPSYS_SPECIFIC}
   }    
}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter PKT_ADDR_H INTEGER 79
set_parameter_property PKT_ADDR_H DISPLAY_NAME {Packet address field index - high}
set_parameter_property PKT_ADDR_H UNITS None
set_parameter_property PKT_ADDR_H DISPLAY_HINT ""
set_parameter_property PKT_ADDR_H AFFECTS_GENERATION false
set_parameter_property PKT_ADDR_H HDL_PARAMETER true
set_parameter_property PKT_ADDR_H DESCRIPTION {MSB of the packet address field index}
add_parameter PKT_ADDR_L INTEGER 48
set_parameter_property PKT_ADDR_L DISPLAY_NAME {Packet address field index - low}
set_parameter_property PKT_ADDR_L UNITS None
set_parameter_property PKT_ADDR_L DISPLAY_HINT ""
set_parameter_property PKT_ADDR_L AFFECTS_GENERATION false
set_parameter_property PKT_ADDR_L HDL_PARAMETER true
set_parameter_property PKT_ADDR_L DESCRIPTION {LSB of the packet address field index}
add_parameter PKT_BEGIN_BURST INTEGER 81
set_parameter_property PKT_BEGIN_BURST DISPLAY_NAME {Packet begin burst field index}
set_parameter_property PKT_BEGIN_BURST UNITS None
set_parameter_property PKT_BEGIN_BURST DISPLAY_HINT ""
set_parameter_property PKT_BEGIN_BURST AFFECTS_GENERATION false
set_parameter_property PKT_BEGIN_BURST HDL_PARAMETER true
set_parameter_property PKT_BEGIN_BURST DESCRIPTION {Packet begin burst field index}
add_parameter PKT_BYTE_CNT_H INTEGER 5
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

add_parameter PKT_BYTEEN_H INTEGER 83
set_parameter_property PKT_BYTEEN_H DISPLAY_NAME {Packet byteenable field index - high}
set_parameter_property PKT_BYTEEN_H UNITS None
set_parameter_property PKT_BYTEEN_H DISPLAY_HINT ""
set_parameter_property PKT_BYTEEN_H AFFECTS_GENERATION false
set_parameter_property PKT_BYTEEN_H HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_H DESCRIPTION {MSB of the packet byteenable field index}
add_parameter PKT_BYTEEN_L INTEGER 80
set_parameter_property PKT_BYTEEN_L DISPLAY_NAME {Packet byteenable field index - low}
set_parameter_property PKT_BYTEEN_L UNITS None
set_parameter_property PKT_BYTEEN_L DISPLAY_HINT ""
set_parameter_property PKT_BYTEEN_L AFFECTS_GENERATION false
set_parameter_property PKT_BYTEEN_L HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_L DESCRIPTION {LSB of the packet byteenable field index}
add_parameter PKT_BURST_SIZE_H INTEGER 86
set_parameter_property PKT_BURST_SIZE_H DISPLAY_NAME {Packet burstsize field index - high}
set_parameter_property PKT_BURST_SIZE_H UNITS None
set_parameter_property PKT_BURST_SIZE_H DISPLAY_HINT ""
set_parameter_property PKT_BURST_SIZE_H AFFECTS_GENERATION false
set_parameter_property PKT_BURST_SIZE_H HDL_PARAMETER true
set_parameter_property PKT_BURST_SIZE_H DESCRIPTION {MSB of the packet burstsize field index}
add_parameter PKT_BURST_SIZE_L INTEGER 84
set_parameter_property PKT_BURST_SIZE_L DISPLAY_NAME {Packet burstsize field index - low}
set_parameter_property PKT_BURST_SIZE_L UNITS None
set_parameter_property PKT_BURST_SIZE_L DISPLAY_HINT ""
set_parameter_property PKT_BURST_SIZE_L AFFECTS_GENERATION false
set_parameter_property PKT_BURST_SIZE_L HDL_PARAMETER true
set_parameter_property PKT_BURST_SIZE_L DESCRIPTION {LSB of the packet burstsize field index}  
add_parameter PKT_BURST_TYPE_H INTEGER 88
set_parameter_property PKT_BURST_TYPE_H DISPLAY_NAME {Packet bursttype field index - high}
set_parameter_property PKT_BURST_TYPE_H UNITS None
set_parameter_property PKT_BURST_TYPE_H DISPLAY_HINT ""
set_parameter_property PKT_BURST_TYPE_H AFFECTS_GENERATION false
set_parameter_property PKT_BURST_TYPE_H HDL_PARAMETER true
set_parameter_property PKT_BURST_TYPE_H DESCRIPTION {MSB of the packet bursttype field index}
add_parameter PKT_BURST_TYPE_L INTEGER 87
set_parameter_property PKT_BURST_TYPE_L DISPLAY_NAME {Packet bursttype field index - low}
set_parameter_property PKT_BURST_TYPE_L UNITS None
set_parameter_property PKT_BURST_TYPE_L DISPLAY_HINT ""
set_parameter_property PKT_BURST_TYPE_L AFFECTS_GENERATION false
set_parameter_property PKT_BURST_TYPE_L HDL_PARAMETER true
set_parameter_property PKT_BURST_TYPE_L DESCRIPTION {LSB of the packet bursttype field index}     
add_parameter PKT_BURSTWRAP_H INTEGER 11
set_parameter_property PKT_BURSTWRAP_H DISPLAY_NAME {Packet burstwrap field index - high}
set_parameter_property PKT_BURSTWRAP_H UNITS None
set_parameter_property PKT_BURSTWRAP_H DISPLAY_HINT ""
set_parameter_property PKT_BURSTWRAP_H AFFECTS_GENERATION false
set_parameter_property PKT_BURSTWRAP_H HDL_PARAMETER true
set_parameter_property PKT_BURSTWRAP_H DESCRIPTION {MSB of the packet burstwrap field index}
add_parameter PKT_BURSTWRAP_L INTEGER 6
set_parameter_property PKT_BURSTWRAP_L DISPLAY_NAME {Packet burstwrap field index - low}
set_parameter_property PKT_BURSTWRAP_L UNITS None
set_parameter_property PKT_BURSTWRAP_L DISPLAY_HINT ""
set_parameter_property PKT_BURSTWRAP_L AFFECTS_GENERATION false
set_parameter_property PKT_BURSTWRAP_L HDL_PARAMETER true
set_parameter_property PKT_BURSTWRAP_L DESCRIPTION {LSB of the packet burstwrap field index}
add_parameter PKT_TRANS_COMPRESSED_READ INTEGER 14
set_parameter_property PKT_TRANS_COMPRESSED_READ DISPLAY_NAME {Packet compressed read transaction field index}
set_parameter_property PKT_TRANS_COMPRESSED_READ UNITS None
set_parameter_property PKT_TRANS_COMPRESSED_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_COMPRESSED_READ HDL_PARAMETER true
set_parameter_property PKT_TRANS_COMPRESSED_READ DESCRIPTION {Packet compressed read transaction field index}
add_parameter PKT_TRANS_WRITE INTEGER 13
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME {Packet write transaction field index}
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE DISPLAY_HINT ""
set_parameter_property PKT_TRANS_WRITE AFFECTS_GENERATION false
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER true
set_parameter_property PKT_TRANS_WRITE DESCRIPTION {Packet write transaction field index}
add_parameter PKT_TRANS_READ INTEGER 12 
set_parameter_property PKT_TRANS_READ DISPLAY_NAME {Packet read transaction field index}
set_parameter_property PKT_TRANS_READ UNITS None
set_parameter_property PKT_TRANS_READ DISPLAY_HINT ""
set_parameter_property PKT_TRANS_READ AFFECTS_GENERATION false
set_parameter_property PKT_TRANS_READ HDL_PARAMETER true
set_parameter_property PKT_TRANS_READ DESCRIPTION {Packet read transaction field index}
add_parameter OUT_NARROW_SIZE INTEGER 0
set_parameter_property OUT_NARROW_SIZE DISPLAY_NAME {slave narrow sized output}
set_parameter_property OUT_NARROW_SIZE UNITS None
set_parameter_property OUT_NARROW_SIZE DISPLAY_HINT ""
set_parameter_property OUT_NARROW_SIZE AFFECTS_GENERATION false
set_parameter_property OUT_NARROW_SIZE HDL_PARAMETER true
set_parameter_property OUT_NARROW_SIZE DESCRIPTION {Slave is able to receive narrow sized output}
add_parameter IN_NARROW_SIZE INTEGER 0
set_parameter_property IN_NARROW_SIZE DISPLAY_NAME {slave narrow sized output}
set_parameter_property IN_NARROW_SIZE UNITS None
set_parameter_property IN_NARROW_SIZE DISPLAY_HINT ""
set_parameter_property IN_NARROW_SIZE AFFECTS_GENERATION false
set_parameter_property IN_NARROW_SIZE HDL_PARAMETER true
set_parameter_property IN_NARROW_SIZE DESCRIPTION {Slave is able to receive narrow sized output}    
add_parameter OUT_FIXED INTEGER 0
set_parameter_property OUT_FIXED DISPLAY_NAME {slave fixed output}
set_parameter_property OUT_FIXED UNITS None
set_parameter_property OUT_FIXED DISPLAY_HINT ""
set_parameter_property OUT_FIXED AFFECTS_GENERATION false
set_parameter_property OUT_FIXED HDL_PARAMETER true
set_parameter_property OUT_FIXED DESCRIPTION {Slave is able to receive narrow sized output}
add_parameter OUT_COMPLETE_WRAP INTEGER 0
set_parameter_property OUT_COMPLETE_WRAP DISPLAY_NAME {slave complete wrap output}
set_parameter_property OUT_COMPLETE_WRAP UNITS None
set_parameter_property OUT_COMPLETE_WRAP DISPLAY_HINT ""
set_parameter_property OUT_COMPLETE_WRAP AFFECTS_GENERATION false
set_parameter_property OUT_COMPLETE_WRAP HDL_PARAMETER true
set_parameter_property OUT_COMPLETE_WRAP DESCRIPTION {Slave is able to receive complete wrap output}     
add_parameter ST_DATA_W INTEGER 89 
set_parameter_property ST_DATA_W DISPLAY_NAME {Streaming data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W DISPLAY_HINT ""
set_parameter_property ST_DATA_W AFFECTS_GENERATION false
set_parameter_property ST_DATA_W HDL_PARAMETER true
set_parameter_property ST_DATA_W DESCRIPTION {StreamingPacket data width}
add_parameter ST_CHANNEL_W INTEGER 8
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W DISPLAY_HINT ""
set_parameter_property ST_CHANNEL_W AFFECTS_GENERATION false
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
add_parameter OUT_BYTE_CNT_H INTEGER 5
set_parameter_property OUT_BYTE_CNT_H DISPLAY_NAME {Maximum output packet byte count index}
set_parameter_property OUT_BYTE_CNT_H UNITS None
set_parameter_property OUT_BYTE_CNT_H DISPLAY_HINT ""
set_parameter_property OUT_BYTE_CNT_H AFFECTS_GENERATION false
set_parameter_property OUT_BYTE_CNT_H HDL_PARAMETER true
set_parameter_property OUT_BYTE_CNT_H DESCRIPTION {Maximum output packet byte count index}
add_parameter OUT_BURSTWRAP_H INTEGER 11
set_parameter_property OUT_BURSTWRAP_H DISPLAY_NAME {Maximum output packet burstwrap index}
set_parameter_property OUT_BURSTWRAP_H UNITS None
set_parameter_property OUT_BURSTWRAP_H DISPLAY_HINT ""
set_parameter_property OUT_BURSTWRAP_H AFFECTS_GENERATION false
set_parameter_property OUT_BURSTWRAP_H HDL_PARAMETER true
set_parameter_property OUT_BURSTWRAP_H DESCRIPTION {Maximum output packet burstwrap index}
add_parameter MERLIN_PACKET_FORMAT String ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME {Merlin packet format descriptor}
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION {Merlin packet format descriptor}

add_parameter COMPRESSED_READ_SUPPORT INTEGER 1
set_parameter_property COMPRESSED_READ_SUPPORT DISPLAY_NAME {Compressed read support}
set_parameter_property COMPRESSED_READ_SUPPORT UNITS None
set_parameter_property COMPRESSED_READ_SUPPORT DISPLAY_HINT boolean
set_parameter_property COMPRESSED_READ_SUPPORT AFFECTS_GENERATION false
set_parameter_property COMPRESSED_READ_SUPPORT HDL_PARAMETER true
set_parameter_property COMPRESSED_READ_SUPPORT DESCRIPTION {When enabled, the burst is transferred in a single cycle. When disabled, the burst occurs over burst size/symbol size cycles.}

add_parameter BYTEENABLE_SYNTHESIS INTEGER
set_parameter_property BYTEENABLE_SYNTHESIS DEFAULT_VALUE 0
set_parameter_property BYTEENABLE_SYNTHESIS DISPLAY_NAME {Byteenable Synthesis Support}
set_parameter_property BYTEENABLE_SYNTHESIS UNITS None
set_parameter_property BYTEENABLE_SYNTHESIS DISPLAY_HINT boolean
set_parameter_property BYTEENABLE_SYNTHESIS AFFECTS_GENERATION false
set_parameter_property BYTEENABLE_SYNTHESIS HDL_PARAMETER true
set_parameter_property BYTEENABLE_SYNTHESIS DESCRIPTION {When enabled, byteenable bit is set based on size-aligned address. When disabled, byteenable bit is passed along from master.}
 
add_parameter PIPE_INPUTS INTEGER 0
set_parameter_property PIPE_INPUTS DISPLAY_NAME {burst adapter input pipeline}
set_parameter_property PIPE_INPUTS UNITS None
set_parameter_property PIPE_INPUTS DISPLAY_HINT ""
set_parameter_property PIPE_INPUTS AFFECTS_GENERATION false
set_parameter_property PIPE_INPUTS HDL_PARAMETER true
set_parameter_property PIPE_INPUTS DESCRIPTION {Inputs to burst adapter will be pipelined after initial decode}

add_parameter NO_WRAP_SUPPORT INTEGER 0
set_parameter_property NO_WRAP_SUPPORT DISPLAY_NAME {no wrap calculation support}
set_parameter_property NO_WRAP_SUPPORT UNITS None
set_parameter_property NO_WRAP_SUPPORT DISPLAY_HINT ""
set_parameter_property NO_WRAP_SUPPORT AFFECTS_GENERATION false
set_parameter_property NO_WRAP_SUPPORT HDL_PARAMETER true
set_parameter_property NO_WRAP_SUPPORT DESCRIPTION {No wrapping calculations will be done once this is set.}

add_parameter BURSTWRAP_CONST_MASK INTEGER
set_parameter_property BURSTWRAP_CONST_MASK DEFAULT_VALUE 0
set_parameter_property BURSTWRAP_CONST_MASK DISPLAY_NAME {Burstwrap-constant mask}
set_parameter_property BURSTWRAP_CONST_MASK UNITS None
set_parameter_property BURSTWRAP_CONST_MASK DISPLAY_HINT hexadecimal
set_parameter_property BURSTWRAP_CONST_MASK AFFECTS_GENERATION false
set_parameter_property BURSTWRAP_CONST_MASK HDL_PARAMETER true
set_parameter_property BURSTWRAP_CONST_MASK DESCRIPTION {1-bits indicate
constant positions}

add_parameter BURSTWRAP_CONST_VALUE INTEGER
set_parameter_property BURSTWRAP_CONST_VALUE DEFAULT_VALUE -1
set_parameter_property BURSTWRAP_CONST_VALUE DISPLAY_NAME {Burstwrap-constant value}
set_parameter_property BURSTWRAP_CONST_VALUE UNITS None
set_parameter_property BURSTWRAP_CONST_VALUE DISPLAY_HINT hexadecimal 
set_parameter_property BURSTWRAP_CONST_VALUE AFFECTS_GENERATION false
set_parameter_property BURSTWRAP_CONST_VALUE HDL_PARAMETER true
set_parameter_property BURSTWRAP_CONST_VALUE DESCRIPTION {Constant burstwrap value, if enabled by corresponding burstwrap-constant mask bit}
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point cr0
# | 
add_interface cr0 clock end

set_interface_property cr0 ENABLED true
set_interface_property cr0 EXPORT_OF true

add_interface_port cr0 clk clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point cr0_reset
# | 
add_interface cr0_reset reset end
add_interface_port cr0_reset reset reset Input 1

set_interface_property cr0_reset ENABLED true
set_interface_property cr0_reset EXPORT_OF true
set_interface_property cr0_reset associatedClock cr0
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point sink0
# | 
add_interface sink0 avalon_streaming end
set_interface_property sink0 dataBitsPerSymbol 8
set_interface_property sink0 errorDescriptor ""
set_interface_property sink0 maxChannel 0
set_interface_property sink0 readyLatency 0
set_interface_property sink0 symbolsPerBeat 1

set_interface_property sink0 ASSOCIATED_CLOCK cr0
set_interface_property sink0 ENABLED true
set_interface_property sink0 EXPORT_OF true

add_interface_port sink0 sink0_valid valid Input 1
add_interface_port sink0 sink0_data data Input -1
add_interface_port sink0 sink0_channel channel Input -1
add_interface_port sink0 sink0_startofpacket startofpacket Input 1
add_interface_port sink0 sink0_endofpacket endofpacket Input 1
add_interface_port sink0 sink0_ready ready Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point source0
# | 
add_interface source0 avalon_streaming start
set_interface_property source0 dataBitsPerSymbol 8
set_interface_property source0 errorDescriptor ""
set_interface_property source0 maxChannel 0
set_interface_property source0 readyLatency 0
set_interface_property source0 symbolsPerBeat 1

set_interface_property source0 ASSOCIATED_CLOCK cr0
set_interface_property source0 ENABLED true
set_interface_property source0 EXPORT_OF true

add_interface_port source0 source0_valid valid Output 1
add_interface_port source0 source0_data data Output -1
add_interface_port source0 source0_channel channel Output -1
add_interface_port source0 source0_startofpacket startofpacket Output 1
add_interface_port source0 source0_endofpacket endofpacket Output 1
add_interface_port source0 source0_ready ready Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {
  set st_data_width [ get_parameter_value ST_DATA_W    ]
  set field_info    [ get_parameter_value MERLIN_PACKET_FORMAT ]

  set_interface_property source0  dataBitsPerSymbol $st_data_width
  set_interface_property sink0 dataBitsPerSymbol $st_data_width

  set_port_property source0_data  WIDTH_EXPR $st_data_width
  set_port_property  source0_data vhdl_type std_logic_vector
  set_port_property sink0_data WIDTH_EXPR $st_data_width
  set_port_property  sink0_data vhdl_type std_logic_vector

  set st_chan_width [ get_parameter_value ST_CHANNEL_W ]
  set_port_property source0_channel WIDTH_EXPR $st_chan_width
  set_port_property  source0_channel vhdl_type std_logic_vector
  set_port_property sink0_channel WIDTH_EXPR $st_chan_width
  set_port_property  sink0_channel vhdl_type std_logic_vector

  set_interface_assignment sink0 merlin.packet_format $field_info
  set_interface_assignment source0 merlin.packet_format $field_info

  set_interface_assignment sink0 merlin.flow.source0 source0
}

