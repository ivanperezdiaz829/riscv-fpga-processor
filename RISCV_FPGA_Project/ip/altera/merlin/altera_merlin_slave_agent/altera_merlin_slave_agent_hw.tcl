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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_slave_agent/altera_merlin_slave_agent_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_slave_agent "Merlin Slave Agent" v1.0
# | null 2008.09.19.14:00:52
# | 
# | 
# | /data/jyeap/p4root/acds/main/ip_tests/sopc_builder/components/merlin/merlin_agent_integration/ip/altera_merlin_slave_agent/altera_merlin_slave_agent.sv
# | 
# |    ./altera_merlin_slave_agent.sv syn, sim
# | 
# +-----------------------------------

package require -exact qsys 12.1


 proc log2ceiling { num } {
    set val 0
    set i   1
    while { $i < $num } {
        set val [ expr $val + 1 ]
        set i   [ expr 1 << $val ]
    }

    return $val;
 }

proc elaborate {} {
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
  set data_width [ expr [ get_parameter_value PKT_DATA_H ] - [ get_parameter_value PKT_DATA_L ] + 1 ]
  set rdata_fifo_width [ expr $data_width + 2]
  set be_width [ expr $data_width / 8 ]
  set addr_width [ expr [ get_parameter_value PKT_ADDR_H ] - [ get_parameter_value PKT_ADDR_L ] + 1 ]
    
  set mid_width [ expr [ get_parameter_value PKT_SRC_ID_H ] - [ get_parameter_value PKT_SRC_ID_L ] + 1 ]
  set sid_width [ expr [ get_parameter_value PKT_DEST_ID_H ] - [ get_parameter_value PKT_DEST_ID_L ] + 1 ]
  set field_info [ get_parameter_value MERLIN_PACKET_FORMAT ]

  set pkt_width [ get_parameter_value ST_DATA_W ]
  set fifo_width [ expr $pkt_width + 1 ]
  #if { [ get_parameter_value AVS_BURSTCOUNT_SYMBOLS ] } {
      set burstcount_width [ get_parameter_value AVS_BURSTCOUNT_W ]
  #} else {
  #    set burstcount_width [ expr [ get_parameter_value AVS_BURSTCOUNT_W ] + [ log2ceiling $be_width ] ]
  #}
  # +-----------------------------------
  # | connection point m0
  # | 
  set lw [ get_parameter_value AV_LINEWRAPBURSTS ]

  add_interface m0 avalon start
  set_interface_property m0 adaptsTo ""
  set_interface_property m0 burstOnBurstBoundariesOnly false
  set_interface_property m0 doStreamReads false
  set_interface_property m0 doStreamWrites false
  set_interface_property m0 linewrapBursts $lw
  set_interface_property m0 constantBurstBehavior false
  set_interface_property m0 burstcountUnits SYMBOLS
  set_interface_property m0 addressUnits SYMBOLS

  set_interface_property m0 associatedClock clk
  set_interface_property m0 associatedReset clk_reset

  add_interface_port m0 m0_address address Output $addr_width
  set_port_property m0_address vhdl_type std_logic_vector
  add_interface_port m0 m0_burstcount burstcount Output $burstcount_width
  set_port_property m0_burstcount vhdl_type std_logic_vector
  add_interface_port m0 m0_byteenable byteenable Output $be_width
  set_port_property m0_byteenable vhdl_type std_logic_vector
  add_interface_port m0 m0_debugaccess debugaccess Output 1
  add_interface_port m0 m0_lock lock Output 1
  add_interface_port m0 m0_readdata readdata Input $data_width
  set_port_property m0_readdata vhdl_type std_logic_vector
  add_interface_port m0 m0_readdatavalid readdatavalid Input 1
  add_interface_port m0 m0_read read Output 1
  add_interface_port m0 m0_waitrequest waitrequest Input 1
  add_interface_port m0 m0_writedata writedata Output $data_width
  set_port_property m0_writedata vhdl_type std_logic_vector
  add_interface_port m0 m0_write write Output 1
  # Response siganls
  add_interface_port m0 m0_response response Input 2
  set_port_property m0_response vhdl_type std_logic_vector
  add_interface_port m0 m0_writeresponserequest writeresponserequest Output 1
  add_interface_port m0 m0_writeresponsevalid writeresponsevalid Input 1
	if { ([ get_parameter_value USE_READRESPONSE ] == 0) && ([ get_parameter_value USE_WRITERESPONSE ] == 0) } {
		set_port_property m0_response termination true
        set_port_property m0_response termination_value 0
	}
	if { [ get_parameter_value USE_WRITERESPONSE ] == 0 } {
		set_port_property m0_writeresponserequest termination true
        set_port_property m0_writeresponserequest termination_value 0
		set_port_property m0_writeresponsevalid termination true
        set_port_property m0_writeresponsevalid termination_value 0
	}
  set_interface_assignment m0 merlin.flow.rp rp
  # | 
  # +-----------------------------------

  # +-----------------------------------
  # | connection point rp
  # | 
  add_interface rp avalon_streaming start
  set_interface_property rp dataBitsPerSymbol $pkt_width
  set_interface_property rp errorDescriptor ""
  set_interface_property rp maxChannel 0
  set_interface_property rp readyLatency 0
  set_interface_property rp symbolsPerBeat 1

  set_interface_property rp associatedClock clk
  set_interface_property rp associatedReset clk_reset

  add_interface_port rp rp_endofpacket endofpacket Output 1
  add_interface_port rp rp_ready ready Input 1
  add_interface_port rp rp_valid valid Output 1
  add_interface_port rp rp_data data Output $pkt_width
  add_interface_port rp rp_startofpacket startofpacket Output 1

  set_interface_assignment rp merlin.packet_format $field_info
  # | 
  # +-----------------------------------

  # +-----------------------------------
  # | connection point cp
  # | 
  add_interface cp avalon_streaming end
  set_interface_property cp dataBitsPerSymbol $pkt_width
  set_interface_property cp errorDescriptor ""
  set_interface_property cp maxChannel 0
  set_interface_property cp readyLatency 0
  set_interface_property cp symbolsPerBeat 1

  set_interface_property cp associatedClock clk
  set_interface_property cp associatedReset clk_reset

  add_interface_port cp cp_ready ready Output 1
  add_interface_port cp cp_valid valid Input 1
  add_interface_port cp cp_data data Input $pkt_width
  set_port_property cp_data vhdl_type std_logic_vector
  add_interface_port cp cp_startofpacket startofpacket Input 1
  add_interface_port cp cp_endofpacket endofpacket Input 1
  add_interface_port cp cp_channel channel Input [ get_parameter_value ST_CHANNEL_W ]
  set_port_property cp_channel vhdl_type std_logic_vector

  set_interface_assignment cp merlin.packet_format $field_info
  set_interface_assignment cp merlin.flow.m0 m0
  # | 
  # +-----------------------------------

  # +-----------------------------------
  # | connection point rf_sink
  # | 
  add_interface rf_sink avalon_streaming end
  set_interface_property rf_sink dataBitsPerSymbol $fifo_width
  set_interface_property rf_sink errorDescriptor ""
  set_interface_property rf_sink maxChannel 0
  set_interface_property rf_sink readyLatency 0
  set_interface_property rf_sink symbolsPerBeat 1

  set_interface_property rf_sink associatedClock clk
  set_interface_property rf_sink associatedReset clk_reset

  add_interface_port rf_sink rf_sink_ready ready Output 1
  add_interface_port rf_sink rf_sink_valid valid Input 1
  add_interface_port rf_sink rf_sink_startofpacket startofpacket Input 1
  add_interface_port rf_sink rf_sink_endofpacket endofpacket Input 1
  add_interface_port rf_sink rf_sink_data data Input $fifo_width
  set_port_property rf_sink_data vhdl_type std_logic_vector
  # | 
  # +-----------------------------------

  # +-----------------------------------
  # | connection point rf_source
  # | 
  add_interface rf_source avalon_streaming start
  set_interface_property rf_source dataBitsPerSymbol $fifo_width
  set_interface_property rf_source errorDescriptor ""
  set_interface_property rf_source maxChannel 0
  set_interface_property rf_source readyLatency 0
  set_interface_property rf_source symbolsPerBeat 1

  set_interface_property rf_source associatedClock clk
  set_interface_property rf_source associatedReset clk_reset

  add_interface_port rf_source rf_source_ready ready Input 1
  add_interface_port rf_source rf_source_valid valid Output 1
  add_interface_port rf_source rf_source_startofpacket startofpacket Output 1
  add_interface_port rf_source rf_source_endofpacket endofpacket Output 1
  add_interface_port rf_source rf_source_data data Output $fifo_width
  set_port_property rf_source_data vhdl_type std_logic_vector
  # | 
  # +-----------------------------------

  # +-----------------------------------
  # | connection point rdata_fifo_sink
  # |
  add_interface rdata_fifo_sink avalon_streaming end
  set_interface_property rdata_fifo_sink dataBitsPerSymbol $rdata_fifo_width
  set_interface_property rdata_fifo_sink errorDescriptor ""
  set_interface_property rdata_fifo_sink maxChannel 0
  set_interface_property rdata_fifo_sink readyLatency 0
  set_interface_property rdata_fifo_sink symbolsPerBeat 1

  set_interface_property rdata_fifo_sink associatedClock clk
  set_interface_property rdata_fifo_sink associatedReset clk_reset

  add_interface_port rdata_fifo_sink rdata_fifo_sink_ready ready Output 1
  add_interface_port rdata_fifo_sink rdata_fifo_sink_valid valid Input 1
  add_interface_port rdata_fifo_sink rdata_fifo_sink_data data Input $rdata_fifo_width
  set_port_property rdata_fifo_sink_data vhdl_type std_logic_vector
  # |
  # +-----------------------------------

  # +-----------------------------------
  # | connection point rdata_fifo_src
  # |
  add_interface rdata_fifo_src avalon_streaming start
  set_interface_property rdata_fifo_src dataBitsPerSymbol $rdata_fifo_width
  set_interface_property rdata_fifo_src errorDescriptor ""
  set_interface_property rdata_fifo_src maxChannel 0
  set_interface_property rdata_fifo_src readyLatency 0
  set_interface_property rdata_fifo_src symbolsPerBeat 1

  set_interface_property rdata_fifo_src associatedClock clk
  set_interface_property rdata_fifo_src associatedReset clk_reset

  add_interface_port rdata_fifo_src rdata_fifo_src_ready ready Input 1
  add_interface_port rdata_fifo_src rdata_fifo_src_valid valid Output 1
  add_interface_port rdata_fifo_src rdata_fifo_src_data data Output $rdata_fifo_width
  set_port_property rdata_fifo_src_data vhdl_type std_logic_vector
  # |
  # +-----------------------------------
}

# +-----------------------------------
# | module altera_merlin_slave_agent
# | 
set_module_property NAME altera_merlin_slave_agent
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Avalon MM Slave Agent"
set_module_property DESCRIPTION "Accepts command packets and issues the resulting transactions to the Avalon interface. Refer to the Avalon Interface Specifications (http://www.altera.com/literature/manual/mnl_avalon_spec.pdf) for explanations of the bursting properties."
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
set_fileset_property synthesis_fileset TOP_LEVEL altera_merlin_slave_agent 
add_fileset simulation_fileset SIM_VERILOG synth_callback_procedure
set_fileset_property simulation_fileset TOP_LEVEL altera_merlin_slave_agent
add_fileset vhdl_fileset SIM_VHDL synth_callback_procedure_vhdl
set_fileset_property vhdl_fileset TOP_LEVEL altera_merlin_slave_agent

proc synth_callback_procedure { entity_name } {
    add_fileset_file altera_merlin_slave_agent.sv SYSTEM_VERILOG PATH "altera_merlin_slave_agent.sv"
	add_fileset_file altera_merlin_burst_uncompressor.sv SYSTEM_VERILOG PATH "altera_merlin_burst_uncompressor.sv"
}

proc synth_callback_procedure_vhdl { entity_name } {
   if {1} {
      add_fileset_file mentor/altera_merlin_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_slave_agent.sv" {MENTOR_SPECIFIC}
	  add_fileset_file mentor/altera_merlin_burst_uncompressor.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_merlin_burst_uncompressor.sv" {MENTOR_SPECIFIC}
   }
   if {1} {
      add_fileset_file aldec/altera_merlin_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_slave_agent.sv" {ALDEC_SPECIFIC}
	  add_fileset_file aldec/altera_merlin_burst_uncompressor.sv SYSTEM_VERILOG_ENCRYPT PATH "aldec/altera_merlin_burst_uncompressor.sv" {ALDEC_SPECIFIC}
   }
   if {0} {
      add_fileset_file cadence/altera_merlin_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_slave_agent.sv" {CADENCE_SPECIFIC}
	  add_fileset_file cadence/altera_merlin_burst_uncompressor.sv SYSTEM_VERILOG_ENCRYPT PATH "cadence/altera_merlin_burst_uncompressor.sv" {CADENCE_SPECIFIC}
   }
   if {0} {
      add_fileset_file synopsys/altera_merlin_slave_agent.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_slave_agent.sv" {SYNOPSYS_SPECIFIC}
	  add_fileset_file synopsys/altera_merlin_burst_uncompressor.sv SYSTEM_VERILOG_ENCRYPT PATH "synopsys/altera_merlin_burst_uncompressor.sv" {SYNOPSYS_SPECIFIC}
   }    
}

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter PKT_DATA_H INTEGER 31
set_parameter_property PKT_DATA_H DISPLAY_NAME {Packet data field index - high}
set_parameter_property PKT_DATA_H UNITS None
set_parameter_property PKT_DATA_H AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_H HDL_PARAMETER true
set_parameter_property PKT_DATA_H DESCRIPTION {MSB of the packet data field index}
add_parameter PKT_DATA_L INTEGER 0
set_parameter_property PKT_DATA_L DISPLAY_NAME {Packet data field index - low}
set_parameter_property PKT_DATA_L UNITS None
set_parameter_property PKT_DATA_L AFFECTS_ELABORATION true
set_parameter_property PKT_DATA_L HDL_PARAMETER true
set_parameter_property PKT_DATA_L DESCRIPTION {LSB of the packet data field index}
add_parameter PKT_BEGIN_BURST INTEGER 81
set_parameter_property PKT_BEGIN_BURST DISPLAY_NAME {Packet begin burst field index}
set_parameter_property PKT_BEGIN_BURST UNITS None
set_parameter_property PKT_BEGIN_BURST AFFECTS_ELABORATION false
set_parameter_property PKT_BEGIN_BURST HDL_PARAMETER true
set_parameter_property PKT_BEGIN_BURST DESCRIPTION {Packet begin burst field index}
add_parameter PKT_SYMBOL_W INTEGER 8
set_parameter_property PKT_SYMBOL_W DISPLAY_NAME {Packet symbol width}
set_parameter_property PKT_SYMBOL_W UNITS None
set_parameter_property PKT_SYMBOL_W AFFECTS_ELABORATION true
set_parameter_property PKT_SYMBOL_W HDL_PARAMETER true
set_parameter_property PKT_SYMBOL_W DESCRIPTION {Packet symbol width}
add_parameter PKT_BYTEEN_H INTEGER 71 
set_parameter_property PKT_BYTEEN_H DISPLAY_NAME {Packet byteenable field index - high}
set_parameter_property PKT_BYTEEN_H UNITS None
set_parameter_property PKT_BYTEEN_H AFFECTS_ELABORATION true
set_parameter_property PKT_BYTEEN_H HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_H DESCRIPTION {MSB of the packet byteenable field index}
add_parameter PKT_BYTEEN_L INTEGER 68
set_parameter_property PKT_BYTEEN_L DISPLAY_NAME {Packet byteenable field index - low}
set_parameter_property PKT_BYTEEN_L UNITS None
set_parameter_property PKT_BYTEEN_L AFFECTS_ELABORATION true
set_parameter_property PKT_BYTEEN_L HDL_PARAMETER true
set_parameter_property PKT_BYTEEN_L DESCRIPTION {LSB of the packet byteenable field index}
add_parameter PKT_ADDR_H INTEGER 63
set_parameter_property PKT_ADDR_H DISPLAY_NAME {Packet address field index - high}
set_parameter_property PKT_ADDR_H UNITS None
set_parameter_property PKT_ADDR_H AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_H HDL_PARAMETER true
set_parameter_property PKT_ADDR_H DESCRIPTION {MSB of the packet address field index}
add_parameter PKT_ADDR_L INTEGER 32
set_parameter_property PKT_ADDR_L DISPLAY_NAME {Packet address field index - low}
set_parameter_property PKT_ADDR_L UNITS None
set_parameter_property PKT_ADDR_L AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_L HDL_PARAMETER true
set_parameter_property PKT_ADDR_L DESCRIPTION {LSB of the packet address field index}
add_parameter PKT_TRANS_COMPRESSED_READ INTEGER 67
set_parameter_property PKT_TRANS_COMPRESSED_READ DISPLAY_NAME {Packet compressed read transaction field index}
set_parameter_property PKT_TRANS_COMPRESSED_READ UNITS None
set_parameter_property PKT_TRANS_COMPRESSED_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_COMPRESSED_READ HDL_PARAMETER true
set_parameter_property PKT_TRANS_COMPRESSED_READ DESCRIPTION {Packet compressed read transaction field index}
add_parameter PKT_TRANS_POSTED INTEGER 66
set_parameter_property PKT_TRANS_POSTED DISPLAY_NAME {Packet posted transaction field index}
set_parameter_property PKT_TRANS_POSTED UNITS None
set_parameter_property PKT_TRANS_POSTED AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_POSTED HDL_PARAMETER true
set_parameter_property PKT_TRANS_POSTED DESCRIPTION {Packet posted transaction field index}
add_parameter PKT_TRANS_WRITE INTEGER 65 
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME {Packet write transaction field index}
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER true
set_parameter_property PKT_TRANS_WRITE DESCRIPTION {Packet write transaction field index}
add_parameter PKT_TRANS_READ INTEGER 64
set_parameter_property PKT_TRANS_READ DISPLAY_NAME {Packet read transaction field index}
set_parameter_property PKT_TRANS_READ UNITS None
set_parameter_property PKT_TRANS_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_READ HDL_PARAMETER true
set_parameter_property PKT_TRANS_READ DESCRIPTION {Packet read transaction field index}
add_parameter PKT_TRANS_LOCK INTEGER 87
set_parameter_property PKT_TRANS_LOCK DISPLAY_NAME {Packet lock transaction field index}
set_parameter_property PKT_TRANS_LOCK UNITS None
set_parameter_property PKT_TRANS_LOCK AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_LOCK HDL_PARAMETER true
set_parameter_property PKT_TRANS_LOCK DESCRIPTION {Packet lock transaction field index}
add_parameter PKT_SRC_ID_H INTEGER 74 
set_parameter_property PKT_SRC_ID_H DISPLAY_NAME {Packet source id field index - high}
set_parameter_property PKT_SRC_ID_H UNITS None
set_parameter_property PKT_SRC_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_H HDL_PARAMETER true
set_parameter_property PKT_SRC_ID_H DESCRIPTION {MSB of the packet source id field index}
add_parameter PKT_SRC_ID_L INTEGER 72
set_parameter_property PKT_SRC_ID_L DISPLAY_NAME {Packet source id field index - low}
set_parameter_property PKT_SRC_ID_L UNITS None
set_parameter_property PKT_SRC_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_SRC_ID_L HDL_PARAMETER true
set_parameter_property PKT_SRC_ID_L DESCRIPTION {LSB of the packet source id field index}
add_parameter PKT_DEST_ID_H INTEGER 77
set_parameter_property PKT_DEST_ID_H DISPLAY_NAME {Packet destination id field index - high}
set_parameter_property PKT_DEST_ID_H UNITS None
set_parameter_property PKT_DEST_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_H HDL_PARAMETER true
set_parameter_property PKT_DEST_ID_H DESCRIPTION {MSB of the packet destination id field index}
add_parameter PKT_DEST_ID_L INTEGER 75
set_parameter_property PKT_DEST_ID_L DISPLAY_NAME {Packet destination id field index - low}
set_parameter_property PKT_DEST_ID_L UNITS None
set_parameter_property PKT_DEST_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_L HDL_PARAMETER true
set_parameter_property PKT_DEST_ID_L DESCRIPTION {LSB of the packet destination id field index}
add_parameter PKT_BURSTWRAP_H INTEGER 85
set_parameter_property PKT_BURSTWRAP_H DISPLAY_NAME {Packet burstwrap field index - high}
set_parameter_property PKT_BURSTWRAP_H UNITS None
set_parameter_property PKT_BURSTWRAP_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURSTWRAP_H HDL_PARAMETER true
set_parameter_property PKT_BURSTWRAP_H DESCRIPTION {MSB of the packet burstwrap field index}
add_parameter PKT_BURSTWRAP_L INTEGER 82
set_parameter_property PKT_BURSTWRAP_L DISPLAY_NAME {Packet burstwrap field index - low}
set_parameter_property PKT_BURSTWRAP_L UNITS None
set_parameter_property PKT_BURSTWRAP_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURSTWRAP_L HDL_PARAMETER true
set_parameter_property PKT_BURSTWRAP_L DESCRIPTION {LSB of the packet burstwrap field index}

add_parameter PKT_BYTE_CNT_H INTEGER 81
set_parameter_property PKT_BYTE_CNT_H DISPLAY_NAME {Packet byte count field index - high}
set_parameter_property PKT_BYTE_CNT_H UNITS None
set_parameter_property PKT_BYTE_CNT_H AFFECTS_ELABORATION true
set_parameter_property PKT_BYTE_CNT_H HDL_PARAMETER true
set_parameter_property PKT_BYTE_CNT_H DESCRIPTION {MSB of the packet byte count field index}
add_parameter PKT_BYTE_CNT_L INTEGER 78
set_parameter_property PKT_BYTE_CNT_L DISPLAY_NAME {Packet byte count field index - low}
set_parameter_property PKT_BYTE_CNT_L UNITS None
set_parameter_property PKT_BYTE_CNT_L AFFECTS_ELABORATION true
set_parameter_property PKT_BYTE_CNT_L HDL_PARAMETER true
set_parameter_property PKT_BYTE_CNT_L DESCRIPTION {LSB of the packet byte count field index}

add_parameter PKT_PROTECTION_H INTEGER 86
set_parameter_property PKT_PROTECTION_H DISPLAY_NAME {Packet protection field index - high}
set_parameter_property PKT_PROTECTION_H UNITS None
set_parameter_property PKT_PROTECTION_H AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_H HDL_PARAMETER true
set_parameter_property PKT_PROTECTION_H DESCRIPTION {MSB of the packet protection field index}

add_parameter PKT_PROTECTION_L INTEGER 86
set_parameter_property PKT_PROTECTION_L DISPLAY_NAME {Packet protection field index - low}
set_parameter_property PKT_PROTECTION_L UNITS None
set_parameter_property PKT_PROTECTION_L AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_L HDL_PARAMETER true
set_parameter_property PKT_PROTECTION_L DESCRIPTION {LSB of the packet protection field index}

add_parameter PKT_RESPONSE_STATUS_H INTEGER 89
set_parameter_property PKT_RESPONSE_STATUS_H DISPLAY_NAME {Packet response field index - high}
set_parameter_property PKT_RESPONSE_STATUS_H UNITS None
set_parameter_property PKT_RESPONSE_STATUS_H AFFECTS_ELABORATION true
set_parameter_property PKT_RESPONSE_STATUS_H HDL_PARAMETER true
set_parameter_property PKT_RESPONSE_STATUS_H DESCRIPTION {MSB of the packet response field index}
add_parameter PKT_RESPONSE_STATUS_L INTEGER 88
set_parameter_property PKT_RESPONSE_STATUS_L DISPLAY_NAME {Packet response field index - low}
set_parameter_property PKT_RESPONSE_STATUS_L UNITS None
set_parameter_property PKT_RESPONSE_STATUS_L AFFECTS_ELABORATION true
set_parameter_property PKT_RESPONSE_STATUS_L HDL_PARAMETER true
set_parameter_property PKT_RESPONSE_STATUS_L DESCRIPTION {LSB of the packet response field index}

add_parameter PKT_BURST_SIZE_H INTEGER 92
set_parameter_property PKT_BURST_SIZE_H DISPLAY_NAME {Packet burst size field index - high}
set_parameter_property PKT_BURST_SIZE_H UNITS None
set_parameter_property PKT_BURST_SIZE_H AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_SIZE_H HDL_PARAMETER true
set_parameter_property PKT_BURST_SIZE_H DESCRIPTION {MSB of the packet burst size field index}
add_parameter PKT_BURST_SIZE_L INTEGER 90
set_parameter_property PKT_BURST_SIZE_L DISPLAY_NAME {Packet burst size field index - low}
set_parameter_property PKT_BURST_SIZE_L UNITS None
set_parameter_property PKT_BURST_SIZE_L AFFECTS_ELABORATION true
set_parameter_property PKT_BURST_SIZE_L HDL_PARAMETER true
set_parameter_property PKT_BURST_SIZE_L DESCRIPTION {LSB of the packet burst size field index}  

add_parameter PKT_ORI_BURST_SIZE_L INTEGER 93
set_parameter_property PKT_ORI_BURST_SIZE_L DISPLAY_NAME "Packet original burst size index - low"
set_parameter_property PKT_ORI_BURST_SIZE_L TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_L UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_L DESCRIPTION "LSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_L AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_L HDL_PARAMETER true
add_parameter PKT_ORI_BURST_SIZE_H INTEGER 95
set_parameter_property PKT_ORI_BURST_SIZE_H DISPLAY_NAME "Packet original burst size index - high"
set_parameter_property PKT_ORI_BURST_SIZE_H TYPE INTEGER
set_parameter_property PKT_ORI_BURST_SIZE_H UNITS None
set_parameter_property PKT_ORI_BURST_SIZE_H DESCRIPTION "MSB of the packet original burst size field index"
set_parameter_property PKT_ORI_BURST_SIZE_H AFFECTS_ELABORATION true
set_parameter_property PKT_ORI_BURST_SIZE_H HDL_PARAMETER true

add_parameter ST_CHANNEL_W INTEGER 8
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
set_parameter_property ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER true

add_parameter ST_DATA_W INTEGER 96
set_parameter_property ST_DATA_W DISPLAY_NAME {Streaming data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W AFFECTS_ELABORATION true
set_parameter_property ST_DATA_W HDL_PARAMETER true
set_parameter_property ST_DATA_W DESCRIPTION {StreamingPacket data width}

add_parameter AVS_BURSTCOUNT_SYMBOLS INTEGER 0
set_parameter_property AVS_BURSTCOUNT_SYMBOLS DISPLAY_NAME {burstcountSymbols}
set_parameter_property AVS_BURSTCOUNT_SYMBOLS UNITS None
set_parameter_property AVS_BURSTCOUNT_SYMBOLS AFFECTS_ELABORATION true
set_parameter_property AVS_BURSTCOUNT_SYMBOLS DESCRIPTION {Avalon-MM burstcountSymbols interface property - universal Avalon interface}

add_parameter AVS_BURSTCOUNT_W INTEGER 4
set_parameter_property AVS_BURSTCOUNT_W DISPLAY_NAME {burstcount width}
set_parameter_property AVS_BURSTCOUNT_W UNITS None
set_parameter_property AVS_BURSTCOUNT_W AFFECTS_ELABORATION true
set_parameter_property AVS_BURSTCOUNT_W HDL_PARAMETER true
set_parameter_property AVS_BURSTCOUNT_W DESCRIPTION {Width of the burstcount signal - universal Avalon interface}

add_parameter AV_LINEWRAPBURSTS INTEGER 0
set_parameter_property AV_LINEWRAPBURSTS DISPLAY_NAME {linewrapBursts}
set_parameter_property AV_LINEWRAPBURSTS UNITS None
set_parameter_property AV_LINEWRAPBURSTS AFFECTS_ELABORATION true
set_parameter_property AV_LINEWRAPBURSTS HDL_PARAMETER false
set_parameter_property AV_LINEWRAPBURSTS DISPLAY_HINT boolean
set_parameter_property AV_LINEWRAPBURSTS DESCRIPTION {Avalon-MM linewrapBursts interface property}

add_parameter MERLIN_PACKET_FORMAT String ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME {Merlin packet format descriptor}
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION {Merlin packet format descriptor}

add_parameter SUPPRESS_0_BYTEEN_CMD INTEGER 1
set_parameter_property SUPPRESS_0_BYTEEN_CMD DISPLAY_NAME {Suppress 0-byteenable transactions}
set_parameter_property SUPPRESS_0_BYTEEN_CMD UNITS None
set_parameter_property SUPPRESS_0_BYTEEN_CMD DESCRIPTION {Suppress transactions with all byteenables deasserted}
set_parameter_property SUPPRESS_0_BYTEEN_CMD HDL_PARAMETER true

add_parameter PREVENT_FIFO_OVERFLOW INTEGER 0
set_parameter_property PREVENT_FIFO_OVERFLOW DISPLAY_NAME {Prevent FIFO overflow}
set_parameter_property PREVENT_FIFO_OVERFLOW UNITS None
set_parameter_property PREVENT_FIFO_OVERFLOW DESCRIPTION {Backpressure to prevent FIFO overflow}
set_parameter_property PREVENT_FIFO_OVERFLOW HDL_PARAMETER true

add_parameter MAX_BYTE_CNT INTEGER 8
set_parameter_property MAX_BYTE_CNT DISPLAY_NAME {Maximum byte-count value}
set_parameter_property MAX_BYTE_CNT UNITS None
set_parameter_property MAX_BYTE_CNT DESCRIPTION {Maximum byte-count value}
set_parameter_property MAX_BYTE_CNT HDL_PARAMETER false

add_parameter MAX_BURSTWRAP INTEGER 15
set_parameter_property MAX_BURSTWRAP DISPLAY_NAME {Maximum burstwrap value}
set_parameter_property MAX_BURSTWRAP UNITS None
set_parameter_property MAX_BURSTWRAP DESCRIPTION {Maximum burstwrap value}
set_parameter_property MAX_BURSTWRAP HDL_PARAMETER false

add_parameter ID INTEGER 1
set_parameter_property ID DISPLAY_NAME {Slave ID}
set_parameter_property ID UNITS None
set_parameter_property ID HDL_PARAMETER false
set_parameter_property ID DESCRIPTION {Network-domain-unique Slave ID}

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

