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


# (C) 2001-2012 Altera Corporation. All rights reserved.
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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_master_agent/altera_merlin_master_agent_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_master_agent "altera_merlin_master_agent" v1.0
# | null 2008.09.17.09:54:14
# | 
# | 
# | /data/jyeap/p4root/acds/main/ip/sopc/components/merlin/altera_merlin_master_agent/altera_merlin_master_agent.sv
# | 
# |    ./altera_merlin_master_agent.sv syn, sim
# | 
# +-----------------------------------
package require -exact qsys 12.1


# +-----------------------------------
# | module altera_merlin_master_agent
# | 
set_module_property NAME altera_merlin_master_agent
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Avalon MM Master Agent"
set_module_property DESCRIPTION "Translates Avalon-MM master transactions into Qsys command packets and translates the Qsys Avalon-MM slave response packets into Avalon-MM responses. Refer to the Avalon Interface Specifications (http://www.altera.com/literature/manual/mnl_avalon_spec.pdf) for an explanation of bursting behavior."
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
# | files
# | 
add_fileset synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
set_fileset_property synthesis_fileset TOP_LEVEL altera_merlin_master_agent 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_merlin_master_agent
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_master_agent

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_merlin_master_agent.sv SYSTEM_VERILOG PATH "altera_merlin_master_agent.sv"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_master_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_master_agent.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_master_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_master_agent.sv" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_merlin_master_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_master_agent.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_merlin_master_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_master_agent.sv" {SYNOPSYS_SPECIFIC}
   }    
}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

# +-----------------------------------
# | packet parameters
# |
add_parameter PKT_PROTECTION_H INTEGER 80
set_parameter_property PKT_PROTECTION_H DISPLAY_NAME {Packet protection field index - high}
set_parameter_property PKT_PROTECTION_H UNITS None
set_parameter_property PKT_PROTECTION_H AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_H HDL_PARAMETER true
set_parameter_property PKT_PROTECTION_H DESCRIPTION {MSB of the packet protection field index}
add_parameter PKT_PROTECTION_L INTEGER 80
set_parameter_property PKT_PROTECTION_L DISPLAY_NAME {Packet protection field index - low}
set_parameter_property PKT_PROTECTION_L UNITS None
set_parameter_property PKT_PROTECTION_L AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_L HDL_PARAMETER true
set_parameter_property PKT_PROTECTION_L DESCRIPTION {LSB of the packet protection field index}
add_parameter PKT_BEGIN_BURST INTEGER 81
set_parameter_property PKT_BEGIN_BURST DISPLAY_NAME {Packet begin burst field index}
set_parameter_property PKT_BEGIN_BURST UNITS None
set_parameter_property PKT_BEGIN_BURST AFFECTS_ELABORATION true
set_parameter_property PKT_BEGIN_BURST HDL_PARAMETER true
set_parameter_property PKT_BEGIN_BURST DESCRIPTION {Packet begin burst field index}
add_parameter PKT_BURSTWRAP_H INTEGER 79
set_parameter_property PKT_BURSTWRAP_H DISPLAY_NAME {Packet burstwrap field index - high}
set_parameter_property PKT_BURSTWRAP_H UNITS None
set_parameter_property PKT_BURSTWRAP_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURSTWRAP_H HDL_PARAMETER true
set_parameter_property PKT_BURSTWRAP_H DESCRIPTION {MSB of the packet burstwrap field index}
add_parameter PKT_BURSTWRAP_L INTEGER 77
set_parameter_property PKT_BURSTWRAP_L DISPLAY_NAME {Packet burstwrap field index - low}
set_parameter_property PKT_BURSTWRAP_L UNITS None
set_parameter_property PKT_BURSTWRAP_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURSTWRAP_L HDL_PARAMETER true
set_parameter_property PKT_BURSTWRAP_L DESCRIPTION {LSB of the packet burstwrap field index}
add_parameter PKT_BURST_SIZE_H INTEGER 86
set_parameter_property PKT_BURST_SIZE_H DISPLAY_NAME {Packet burstsize field index - high}
set_parameter_property PKT_BURST_SIZE_H UNITS None
set_parameter_property PKT_BURST_SIZE_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_SIZE_H HDL_PARAMETER true
set_parameter_property PKT_BURST_SIZE_H DESCRIPTION {MSB of the packet burstsize field index}
add_parameter PKT_BURST_SIZE_L INTEGER 84
set_parameter_property PKT_BURST_SIZE_L DISPLAY_NAME {Packet burstsize field index - low}
set_parameter_property PKT_BURST_SIZE_L UNITS None
set_parameter_property PKT_BURST_SIZE_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_SIZE_L HDL_PARAMETER true
set_parameter_property PKT_BURST_SIZE_L DESCRIPTION {LSB of the packet burstsize field index}    
add_parameter PKT_BURST_TYPE_H INTEGER 94
set_parameter_property PKT_BURST_TYPE_H DISPLAY_NAME {Packet bursttype field index - high}
set_parameter_property PKT_BURST_TYPE_H UNITS None
set_parameter_property PKT_BURST_TYPE_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_TYPE_H HDL_PARAMETER true
set_parameter_property PKT_BURST_TYPE_H DESCRIPTION {MSB of the packet bursttype field index}
add_parameter PKT_BURST_TYPE_L INTEGER 93
set_parameter_property PKT_BURST_TYPE_L DISPLAY_NAME {Packet bursttype field index - low}
set_parameter_property PKT_BURST_TYPE_L UNITS None
set_parameter_property PKT_BURST_TYPE_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_TYPE_L HDL_PARAMETER true
set_parameter_property PKT_BURST_TYPE_L DESCRIPTION {LSB of the packet bursttype field index}       
add_parameter PKT_BYTE_CNT_H INTEGER 76
set_parameter_property PKT_BYTE_CNT_H DISPLAY_NAME {Packet byte count field index - high}
set_parameter_property PKT_BYTE_CNT_H UNITS None
set_parameter_property PKT_BYTE_CNT_H AFFECTS_ELABORATION true
set_parameter_property PKT_BYTE_CNT_H HDL_PARAMETER true
set_parameter_property PKT_BYTE_CNT_H DESCRIPTION {MSB of the packet byte count field index}
add_parameter PKT_BYTE_CNT_L INTEGER 74
set_parameter_property PKT_BYTE_CNT_L DISPLAY_NAME {Packet byte count field index - low}
set_parameter_property PKT_BYTE_CNT_L UNITS None
set_parameter_property PKT_BYTE_CNT_L AFFECTS_ELABORATION true
set_parameter_property PKT_BYTE_CNT_L HDL_PARAMETER true
set_parameter_property PKT_BYTE_CNT_L DESCRIPTION {LSB of the packet byte count field index}
add_parameter PKT_ADDR_H INTEGER 73
set_parameter_property PKT_ADDR_H DISPLAY_NAME {Packet address field index - high}
set_parameter_property PKT_ADDR_H UNITS None
set_parameter_property PKT_ADDR_H AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_H HDL_PARAMETER true
set_parameter_property PKT_ADDR_H DESCRIPTION {MSB of the packet address field index}
add_parameter PKT_ADDR_L INTEGER 42
set_parameter_property PKT_ADDR_L DISPLAY_NAME {Packet address field index - low}
set_parameter_property PKT_ADDR_L UNITS None
set_parameter_property PKT_ADDR_L AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_L HDL_PARAMETER true
set_parameter_property PKT_ADDR_L DESCRIPTION {LSB of the packet address field index}
add_parameter PKT_TRANS_COMPRESSED_READ INTEGER 41
set_parameter_property PKT_TRANS_COMPRESSED_READ DISPLAY_NAME {Packet compressed read transaction field index}
set_parameter_property PKT_TRANS_COMPRESSED_READ UNITS None
set_parameter_property PKT_TRANS_COMPRESSED_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_COMPRESSED_READ HDL_PARAMETER true
set_parameter_property PKT_TRANS_COMPRESSED_READ DESCRIPTION {Packet compressed read transaction field index}
add_parameter PKT_TRANS_POSTED INTEGER 40
set_parameter_property PKT_TRANS_POSTED DISPLAY_NAME {Packet posted transaction field index}
set_parameter_property PKT_TRANS_POSTED UNITS None
set_parameter_property PKT_TRANS_POSTED AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_POSTED HDL_PARAMETER true
set_parameter_property PKT_TRANS_POSTED DESCRIPTION {Packet posted transaction field index}
add_parameter PKT_TRANS_WRITE INTEGER 39
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME {Packet write transaction field index}
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER true
set_parameter_property PKT_TRANS_WRITE DESCRIPTION {Packet write transaction field index}
add_parameter PKT_TRANS_READ INTEGER 38
set_parameter_property PKT_TRANS_READ DISPLAY_NAME {Packet read transaction field index}
set_parameter_property PKT_TRANS_READ UNITS None
set_parameter_property PKT_TRANS_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_READ HDL_PARAMETER true
set_parameter_property PKT_TRANS_READ DESCRIPTION {Packet read transaction field index}
add_parameter PKT_TRANS_LOCK INTEGER 82
set_parameter_property PKT_TRANS_LOCK DISPLAY_NAME {Packet lock transaction field index}
set_parameter_property PKT_TRANS_LOCK UNITS None
set_parameter_property PKT_TRANS_LOCK AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_LOCK HDL_PARAMETER true
set_parameter_property PKT_TRANS_LOCK DESCRIPTION {Packet lock transaction field index}
add_parameter PKT_TRANS_EXCLUSIVE INTEGER 83
set_parameter_property PKT_TRANS_EXCLUSIVE DISPLAY_NAME {Packet exclusive transaction field index}
set_parameter_property PKT_TRANS_EXCLUSIVE UNITS None
set_parameter_property PKT_TRANS_EXCLUSIVE AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_EXCLUSIVE HDL_PARAMETER true
set_parameter_property PKT_TRANS_EXCLUSIVE DESCRIPTION {Packet exclusive transaction field index}
add_parameter PKT_DATA_H INTEGER 37
set_parameter_property PKT_DATA_H DISPLAY_NAME {Packet data field index - high}
set_parameter_property PKT_DATA_H UNITS None
set_parameter_property PKT_DATA_H AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_H HDL_PARAMETER true
set_parameter_property PKT_DATA_H DESCRIPTION {MSB of the packet data field index}
add_parameter PKT_DATA_L INTEGER 6
set_parameter_property PKT_DATA_L DISPLAY_NAME {Packet data field index - low}
set_parameter_property PKT_DATA_L UNITS None
set_parameter_property PKT_DATA_L AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_L HDL_PARAMETER true
set_parameter_property PKT_DATA_L DESCRIPTION {LSB of the packet data field index}
add_parameter PKT_BYTEEN_H INTEGER 5
set_parameter_property PKT_BYTEEN_H DISPLAY_NAME {Packet byteenable field index - high}
set_parameter_property PKT_BYTEEN_H UNITS None
set_parameter_property PKT_BYTEEN_H AFFECTS_ELABORATION true
set_parameter_property PKT_BYTEEN_H HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_H DESCRIPTION {MSB of the packet byteenable field index}
add_parameter PKT_BYTEEN_L INTEGER 2
set_parameter_property PKT_BYTEEN_L DISPLAY_NAME {Packet byteenable field index - low}
set_parameter_property PKT_BYTEEN_L UNITS None
set_parameter_property PKT_BYTEEN_L AFFECTS_ELABORATION true
set_parameter_property PKT_BYTEEN_L HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_L DESCRIPTION {LSB of the packet byteenable field index}
add_parameter PKT_SRC_ID_H INTEGER 1
set_parameter_property PKT_SRC_ID_H DISPLAY_NAME {Packet source id field index - high}
set_parameter_property PKT_SRC_ID_H UNITS None
set_parameter_property PKT_SRC_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_H HDL_PARAMETER true
set_parameter_property PKT_SRC_ID_H DESCRIPTION {MSB of the packet source id field index}
add_parameter PKT_SRC_ID_L INTEGER 1
set_parameter_property PKT_SRC_ID_L DISPLAY_NAME {Packet source id field index - low}
set_parameter_property PKT_SRC_ID_L UNITS None
set_parameter_property PKT_SRC_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_L HDL_PARAMETER true
set_parameter_property PKT_SRC_ID_L DESCRIPTION {LSB of the packet source id field index}
add_parameter PKT_DEST_ID_H INTEGER 0
set_parameter_property PKT_DEST_ID_H DISPLAY_NAME {Packet destination id field index - high}
set_parameter_property PKT_DEST_ID_H UNITS None
set_parameter_property PKT_DEST_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_H HDL_PARAMETER true
set_parameter_property PKT_DEST_ID_H DESCRIPTION {MSB of the packet destination id field index}
add_parameter PKT_DEST_ID_L INTEGER 0
set_parameter_property PKT_DEST_ID_L DISPLAY_NAME {Packet destination id field index - low}
set_parameter_property PKT_DEST_ID_L UNITS None
set_parameter_property PKT_DEST_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_L HDL_PARAMETER true
set_parameter_property PKT_DEST_ID_L DESCRIPTION {LSB of the packet destination id field index}

add_parameter PKT_THREAD_ID_H INTEGER 88
set_parameter_property PKT_THREAD_ID_H DISPLAY_NAME {Packet thread id field index - high}
set_parameter_property PKT_THREAD_ID_H UNITS None
set_parameter_property PKT_THREAD_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_THREAD_ID_H HDL_PARAMETER true
set_parameter_property PKT_THREAD_ID_H DESCRIPTION {MSB of the packet thread id field index}
add_parameter PKT_THREAD_ID_L INTEGER 87
set_parameter_property PKT_THREAD_ID_L DISPLAY_NAME {Packet thread id field index - low}
set_parameter_property PKT_THREAD_ID_L UNITS None
set_parameter_property PKT_THREAD_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_THREAD_ID_L HDL_PARAMETER true
set_parameter_property PKT_THREAD_ID_L DESCRIPTION {LSB of the packet thread id field index}

add_parameter PKT_CACHE_H INTEGER 92
set_parameter_property PKT_CACHE_H DISPLAY_NAME {Packet cache field index - high}
set_parameter_property PKT_CACHE_H UNITS None
set_parameter_property PKT_CACHE_H AFFECTS_ELABORATION true
set_parameter_property PKT_CACHE_H HDL_PARAMETER true
set_parameter_property PKT_CACHE_H DESCRIPTION {MSB of the packet cache field index}
add_parameter PKT_CACHE_L INTEGER 89
set_parameter_property PKT_CACHE_L DISPLAY_NAME {Packet cache field index - low}
set_parameter_property PKT_CACHE_L UNITS None
set_parameter_property PKT_CACHE_L AFFECTS_ELABORATION true
set_parameter_property PKT_CACHE_L HDL_PARAMETER true
set_parameter_property PKT_CACHE_L DESCRIPTION {LSB of the packet cache field index}

add_parameter PKT_DATA_SIDEBAND_H INTEGER 105
set_parameter_property PKT_DATA_SIDEBAND_H DISPLAY_NAME {Packet data sideband field index - high}
set_parameter_property PKT_DATA_SIDEBAND_H UNITS None
set_parameter_property PKT_DATA_SIDEBAND_H AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_SIDEBAND_H HDL_PARAMETER true
set_parameter_property PKT_DATA_SIDEBAND_H DESCRIPTION {MSB of the data address sideband field index}
add_parameter PKT_DATA_SIDEBAND_L INTEGER 98
set_parameter_property PKT_DATA_SIDEBAND_L DISPLAY_NAME {Packet data sideband field index - low}
set_parameter_property PKT_DATA_SIDEBAND_L UNITS None
set_parameter_property PKT_DATA_SIDEBAND_L AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_SIDEBAND_L HDL_PARAMETER true
set_parameter_property PKT_DATA_SIDEBAND_L DESCRIPTION {LSB of the data address sideband field index}

add_parameter PKT_QOS_H INTEGER 109
set_parameter_property PKT_QOS_H DISPLAY_NAME {Packet qos sideband field index - high}
set_parameter_property PKT_QOS_H UNITS None
set_parameter_property PKT_QOS_H AFFECTS_ELABORATION true
set_parameter_property PKT_QOS_H HDL_PARAMETER true
set_parameter_property PKT_QOS_H DESCRIPTION {MSB of the qos address sideband field index}
add_parameter PKT_QOS_L INTEGER 106
set_parameter_property PKT_QOS_L DISPLAY_NAME {Packet qos sideband field index - low}
set_parameter_property PKT_QOS_L UNITS None
set_parameter_property PKT_QOS_L AFFECTS_ELABORATION true
set_parameter_property PKT_QOS_L HDL_PARAMETER true
set_parameter_property PKT_QOS_L DESCRIPTION {LSB of the qos address sideband field index}

add_parameter PKT_ADDR_SIDEBAND_H INTEGER 97
set_parameter_property PKT_ADDR_SIDEBAND_H DISPLAY_NAME {Packet address sideband field index - high}
set_parameter_property PKT_ADDR_SIDEBAND_H UNITS None
set_parameter_property PKT_ADDR_SIDEBAND_H AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_SIDEBAND_H HDL_PARAMETER true
set_parameter_property PKT_ADDR_SIDEBAND_H DESCRIPTION {MSB of the packet address sideband field index}
add_parameter PKT_ADDR_SIDEBAND_L INTEGER 93
set_parameter_property PKT_ADDR_SIDEBAND_L DISPLAY_NAME {Packet address sideband field index - low}
set_parameter_property PKT_ADDR_SIDEBAND_L UNITS None
set_parameter_property PKT_ADDR_SIDEBAND_L AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_SIDEBAND_L HDL_PARAMETER true
set_parameter_property PKT_ADDR_SIDEBAND_L DESCRIPTION {LSB of the packet address sideband field index}

add_parameter PKT_RESPONSE_STATUS_H INTEGER 111
set_parameter_property PKT_RESPONSE_STATUS_H DISPLAY_NAME {Packet response status field index - high}
set_parameter_property PKT_RESPONSE_STATUS_H UNITS None
set_parameter_property PKT_RESPONSE_STATUS_H AFFECTS_ELABORATION true
set_parameter_property PKT_RESPONSE_STATUS_H HDL_PARAMETER true
set_parameter_property PKT_RESPONSE_STATUS_H DESCRIPTION {MSB of the packet response status field index}
add_parameter PKT_RESPONSE_STATUS_L INTEGER 110
set_parameter_property PKT_RESPONSE_STATUS_L DISPLAY_NAME {Packet response status index - low}
set_parameter_property PKT_RESPONSE_STATUS_L UNITS None
set_parameter_property PKT_RESPONSE_STATUS_L AFFECTS_ELABORATION true
set_parameter_property PKT_RESPONSE_STATUS_L HDL_PARAMETER true
set_parameter_property PKT_RESPONSE_STATUS_L DESCRIPTION {LSB of the packet response status field index}

add_parameter PKT_ORI_BURST_SIZE_L INTEGER 112
set_parameter_property PKT_ORI_BURST_SIZE_L DISPLAY_NAME "Packet original burst size index - low"
set_parameter_property PKT_ORI_BURST_SIZE_L TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_L UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_L DESCRIPTION "LSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_L AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_L HDL_PARAMETER true
add_parameter PKT_ORI_BURST_SIZE_H INTEGER 114
set_parameter_property PKT_ORI_BURST_SIZE_H DISPLAY_NAME "Packet original burst size index - high"
set_parameter_property PKT_ORI_BURST_SIZE_H TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_H UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_H DESCRIPTION "MSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_H AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_H HDL_PARAMETER true

add_parameter ST_DATA_W INTEGER 115
set_parameter_property ST_DATA_W DISPLAY_NAME {Streaming data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W AFFECTS_ELABORATION true
set_parameter_property ST_DATA_W HDL_PARAMETER true
set_parameter_property ST_DATA_W DESCRIPTION {StreamingPacket data width}

add_parameter ST_CHANNEL_W INTEGER 1 0
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
set_parameter_property ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true

add_parameter AV_BURSTCOUNT_W INTEGER 3
set_parameter_property AV_BURSTCOUNT_W DISPLAY_NAME {Avalon-MM burstcount width}
set_parameter_property AV_BURSTCOUNT_W UNITS None
set_parameter_property AV_BURSTCOUNT_W AFFECTS_ELABORATION true
set_parameter_property AV_BURSTCOUNT_W HDL_PARAMETER true
set_parameter_property AV_BURSTCOUNT_W DESCRIPTION {Avalon-MM burstcount width}

add_parameter AV_LINEWRAPBURSTS INTEGER 0
set_parameter_property AV_LINEWRAPBURSTS DISPLAY_NAME {linewrapBursts}
set_parameter_property AV_LINEWRAPBURSTS UNITS None
set_parameter_property AV_LINEWRAPBURSTS AFFECTS_ELABORATION true
set_parameter_property AV_LINEWRAPBURSTS HDL_PARAMETER false
set_parameter_property AV_LINEWRAPBURSTS DISPLAY_HINT boolean
set_parameter_property AV_LINEWRAPBURSTS DESCRIPTION {Avalon-MM linewrapBursts interface property}

add_parameter AV_BURSTBOUNDARIES INTEGER 0
set_parameter_property AV_BURSTBOUNDARIES AFFECTS_ELABORATION true
set_parameter_property AV_BURSTBOUNDARIES HDL_PARAMETER false
set_parameter_property AV_BURSTBOUNDARIES DISPLAY_HINT BOOLEAN
set_parameter_property AV_BURSTBOUNDARIES DESCRIPTION {Avalon-MM burstOnBurstBoundariesOnly interface property}
set_parameter_property AV_BURSTBOUNDARIES DISPLAY_NAME {burstOnBurstBoundariesOnly}

add_parameter MERLIN_PACKET_FORMAT String ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME {Merlin packet format descriptor}
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION {Merlin packet format descriptor}

add_parameter ADDR_MAP String ""
set_parameter_property ADDR_MAP DISPLAY_NAME {Address map}
set_parameter_property ADDR_MAP UNITS None
set_parameter_property ADDR_MAP DESCRIPTION {Address map}

add_parameter SUPPRESS_0_BYTEEN_RSP INTEGER 1
set_parameter_property SUPPRESS_0_BYTEEN_RSP DISPLAY_NAME {Suppress 0-byteenable responses}
set_parameter_property SUPPRESS_0_BYTEEN_RSP UNITS None
set_parameter_property SUPPRESS_0_BYTEEN_RSP AFFECTS_ELABORATION true
set_parameter_property SUPPRESS_0_BYTEEN_RSP HDL_PARAMETER true
set_parameter_property SUPPRESS_0_BYTEEN_RSP DESCRIPTION {Suppress readdatavalid for transactions issued with deasserted byteenable}
# +-----------------------------------
# | agent parameters
# |
add_parameter ID INTEGER 1
set_parameter_property ID DISPLAY_NAME {Master ID}
set_parameter_property ID UNITS None
set_parameter_property ID AFFECTS_ELABORATION true
set_parameter_property ID HDL_PARAMETER true
set_parameter_property ID DESCRIPTION {Network-domain-unique Master ID}

add_parameter BURSTWRAP_VALUE INTEGER 4
set_parameter_property BURSTWRAP_VALUE DISPLAY_NAME {Burstwrap value}
set_parameter_property BURSTWRAP_VALUE UNITS None
set_parameter_property BURSTWRAP_VALUE AFFECTS_ELABORATION true
set_parameter_property BURSTWRAP_VALUE HDL_PARAMETER true
set_parameter_property BURSTWRAP_VALUE DESCRIPTION {Constant value to assert on the burstwrap packet field}

add_parameter CACHE_VALUE INTEGER 0
set_parameter_property CACHE_VALUE DISPLAY_NAME {Cache value}
set_parameter_property CACHE_VALUE UNITS None
set_parameter_property CACHE_VALUE AFFECTS_ELABORATION true
set_parameter_property CACHE_VALUE HDL_PARAMETER true
set_parameter_property CACHE_VALUE ALLOWED_RANGES 0:15
set_parameter_property CACHE_VALUE DESCRIPTION {Constant value to assert on the cache packet field}

add_parameter SECURE_ACCESS_BIT INTEGER 1
set_parameter_property SECURE_ACCESS_BIT DISPLAY_NAME {Security bit value}
set_parameter_property SECURE_ACCESS_BIT UNITS None
set_parameter_property SECURE_ACCESS_BIT AFFECTS_ELABORATION true
set_parameter_property SECURE_ACCESS_BIT HDL_PARAMETER true
set_parameter_property CACHE_VALUE ALLOWED_RANGES 0:1
set_parameter_property SECURE_ACCESS_BIT DESCRIPTION {Constant value to be fed into security field. 1-non-secured. 0-secured.}

add_parameter USE_READRESPONSE INTEGER 0
set_parameter_property USE_READRESPONSE AFFECTS_ELABORATION true
set_parameter_property USE_READRESPONSE HDL_PARAMETER true
set_parameter_property USE_READRESPONSE DISPLAY_HINT BOOLEAN
set_parameter_property USE_READRESPONSE DESCRIPTION {Enable the read response signal}
set_parameter_property USE_READRESPONSE DISPLAY_NAME {Use readresponse}

add_parameter USE_WRITERESPONSE INTEGER 0
set_parameter_property USE_WRITERESPONSE AFFECTS_ELABORATION true
set_parameter_property USE_WRITERESPONSE HDL_PARAMETER true
set_parameter_property USE_WRITERESPONSE DISPLAY_HINT BOOLEAN
set_parameter_property USE_WRITERESPONSE DESCRIPTION {Enable the write response signals}
set_parameter_property USE_WRITERESPONSE DISPLAY_NAME {Use writeresponse}

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
set_interface_property clk ptfSchematicName ""

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
# | connection point av
# | 
add_interface av avalon end
set_interface_property av addressAlignment DYNAMIC
set_interface_property av bridgesToMaster ""
set_interface_property av burstOnBurstBoundariesOnly false
set_interface_property av holdTime 0
set_interface_property av isMemoryDevice false
set_interface_property av isNonVolatileStorage false
set_interface_property av linewrapBursts false
set_interface_property av maximumPendingReadTransactions 1
set_interface_property av minimumUninterruptedRunLength 1
set_interface_property av printableDevice false
set_interface_property av readLatency 0
set_interface_property av readWaitTime 0
set_interface_property av setupTime 0
set_interface_property av timingUnits Cycles
set_interface_property av writeWaitTime 0
set_interface_property av constantBurstBehavior false
set_interface_property av burstcountUnits SYMBOLS
set_interface_property av addressUnits SYMBOLS

set_interface_property av ASSOCIATED_CLOCK clk
set_interface_property av associatedReset clk_reset

add_interface_port av av_address address Input 32
add_interface_port av av_write write Input 1
add_interface_port av av_read read Input 1
add_interface_port av av_writedata writedata Input 32
add_interface_port av av_readdata readdata Output 32
add_interface_port av av_waitrequest waitrequest Output 1
add_interface_port av av_readdatavalid readdatavalid Output 1
add_interface_port av av_byteenable byteenable Input 4
add_interface_port av av_burstcount burstcount Input 4
add_interface_port av av_debugaccess debugaccess Input 1
add_interface_port av av_lock        lock        Input 1
# Response signals
add_interface_port av av_response response Output 2
add_interface_port av av_writeresponserequest writeresponserequest Input 1
add_interface_port av av_writeresponsevalid writeresponsevalid Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point cp
# | 
add_interface cp avalon_streaming start
set_interface_property cp dataBitsPerSymbol 71
set_interface_property cp errorDescriptor ""
set_interface_property cp maxChannel 0
set_interface_property cp readyLatency 0
set_interface_property cp symbolsPerBeat 1

set_interface_property cp ASSOCIATED_CLOCK clk
set_interface_property cp associatedReset clk_reset

add_interface_port cp cp_valid valid Output 1
add_interface_port cp cp_data data Output 71
add_interface_port cp cp_startofpacket startofpacket Output 1
add_interface_port cp cp_endofpacket endofpacket Output 1
add_interface_port cp cp_ready ready Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point rp
# | 
add_interface rp avalon_streaming end
set_interface_property rp dataBitsPerSymbol 71
set_interface_property rp errorDescriptor ""
set_interface_property rp maxChannel 0
set_interface_property rp readyLatency 0
set_interface_property rp symbolsPerBeat 1

set_interface_property rp ASSOCIATED_CLOCK clk
set_interface_property rp associatedReset clk_reset

add_interface_port rp rp_valid valid Input 1
add_interface_port rp rp_data data Input 71
add_interface_port rp rp_channel channel Input 1
add_interface_port rp rp_startofpacket startofpacket Input 1
add_interface_port rp rp_endofpacket endofpacket Input 1
add_interface_port rp rp_ready ready Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

    set st_data_width [ get_parameter_value ST_DATA_W ]
    set channel_width [ get_parameter_value ST_CHANNEL_W ]
    set mm_data_h     [ get_parameter_value PKT_DATA_H ]
    set mm_data_l     [ get_parameter_value PKT_DATA_L ]
    set mm_data_w     [ expr ($mm_data_h - $mm_data_l + 1) ]
    set addr_h        [ get_parameter_value PKT_ADDR_H ]
    set addr_l        [ get_parameter_value PKT_ADDR_L ]
    set av_addr_w     [ expr ($addr_h - $addr_l + 1) ]
    set byteen_h      [ get_parameter_value PKT_BYTEEN_H ]
    set byteen_l      [ get_parameter_value PKT_BYTEEN_L ]
    set byteen_w      [ expr ($byteen_h - $byteen_l + 1) ]
    set bytecnt_w     [ get_parameter_value AV_BURSTCOUNT_W ]
    set field_info    [ get_parameter_value MERLIN_PACKET_FORMAT ]

    set_interface_property cp dataBitsPerSymbol $st_data_width
    set_interface_property rp dataBitsPerSymbol $st_data_width

    set_port_property cp_data       WIDTH_EXPR $st_data_width
	set_port_property cp_data vhdl_type std_logic_vector
    set_port_property rp_data       WIDTH_EXPR $st_data_width
	set_port_property rp_data vhdl_type std_logic_vector
    set_port_property rp_channel    WIDTH_EXPR $channel_width
	set_port_property rp_channel vhdl_type std_logic_vector

    set_port_property av_address    WIDTH_EXPR $av_addr_w
	set_port_property av_address vhdl_type std_logic_vector
    set_port_property av_writedata  WIDTH_EXPR $mm_data_w
	set_port_property av_writedata vhdl_type std_logic_vector
    set_port_property av_readdata   WIDTH_EXPR $mm_data_w
	set_port_property av_readdata vhdl_type std_logic_vector
    set_port_property av_byteenable WIDTH_EXPR $byteen_w
	set_port_property av_byteenable vhdl_type std_logic_vector
    set_port_property av_burstcount WIDTH_EXPR $bytecnt_w
	set_port_property av_burstcount vhdl_type std_logic_vector

    set_interface_assignment cp merlin.packet_format $field_info
    set_interface_assignment rp merlin.packet_format $field_info

    set_interface_assignment av merlin.flow.cp cp
    set_interface_assignment rp merlin.flow.av av

    set lw [ get_parameter_value AV_LINEWRAPBURSTS ]
    set_interface_property av linewrapBursts $lw

    set bobbo [ get_parameter_value AV_BURSTBOUNDARIES ]
    set_interface_property av burstOnBurstBoundariesOnly $bobbo
	
	if { ([ get_parameter_value USE_READRESPONSE ] == 0) && ([ get_parameter_value USE_WRITERESPONSE ] == 0) } {
		set_port_property av_response termination true
        set_port_property av_response termination_value 0
	}
	if { [ get_parameter_value USE_WRITERESPONSE ] == 0 } {
		set_port_property av_writeresponserequest termination true
        set_port_property av_writeresponserequest termination_value 0
		set_port_property av_writeresponsevalid termination true
        set_port_property av_writeresponsevalid termination_value 0
	}
}

