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

# 
# module altera_eth_packet_classifier
# 
set_module_property NAME altera_eth_packet_classifier
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet Packet Classifier"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_packet_classifier.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_packet_classifier
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL false

# 
# file sets
# 
add_file altera_eth_packet_classifier.v {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_sc_fifo/altera_avalon_sc_fifo.v {SYNTHESIS}
add_file $env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v {SYNTHESIS}

# -----------------------------------
# IEEE encryption
# ----------------------------------- 
add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_ver
set_fileset_property simulation_verilog TOP_LEVEL altera_eth_packet_classifier

proc sim_ver {name} {

add_fileset_file altera_eth_packet_classifier.v VERILOG PATH  "altera_eth_packet_classifier.v" 
add_fileset_file altera_avalon_st_pipeline_stage.sv SYSTEM_VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv" 
add_fileset_file altera_avalon_sc_fifo.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/sopc_builder_ip/altera_avalon_sc_fifo/altera_avalon_sc_fifo.v" 
add_fileset_file altera_avalon_st_pipeline_base.v VERILOG PATH "$::env(QUARTUS_ROOTDIR)/../ip/altera/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_base.v" 
}

# 
# parameters
# 
add_parameter "TSTAMP_FP_WIDTH" INTEGER 4
set_parameter_property "TSTAMP_FP_WIDTH" DEFAULT_VALUE 4
set_parameter_property "TSTAMP_FP_WIDTH" DISPLAY_NAME TSTAMP_FP_WIDTH
set_parameter_property "TSTAMP_FP_WIDTH" TYPE INTEGER
set_parameter_property "TSTAMP_FP_WIDTH" ENABLED true
set_parameter_property "TSTAMP_FP_WIDTH" UNITS None
set_parameter_property "TSTAMP_FP_WIDTH" HDL_PARAMETER true

add_parameter "SYMBOLSPERBEAT" INTEGER 8
set_parameter_property "SYMBOLSPERBEAT" DEFAULT_VALUE 8
set_parameter_property "SYMBOLSPERBEAT" DISPLAY_NAME SYMBOLSPERBEAT
set_parameter_property "SYMBOLSPERBEAT" TYPE INTEGER
set_parameter_property "SYMBOLSPERBEAT" ENABLED true
set_parameter_property "SYMBOLSPERBEAT" DERIVED false
set_parameter_property "SYMBOLSPERBEAT" HDL_PARAMETER true

add_parameter "BITSPERSYMBOL" INTEGER 8
set_parameter_property "BITSPERSYMBOL" DEFAULT_VALUE 8
set_parameter_property "BITSPERSYMBOL" DISPLAY_NAME BITSPERSYMBOL
set_parameter_property "BITSPERSYMBOL" TYPE INTEGER
set_parameter_property "BITSPERSYMBOL" ENABLED true
set_parameter_property "BITSPERSYMBOL" DERIVED false
set_parameter_property "BITSPERSYMBOL" HDL_PARAMETER true



proc elaborate {} {
    set TSTAMP_FP_WIDTH [ get_parameter_value TSTAMP_FP_WIDTH ]
    set SYMBOLSPERBEAT [ get_parameter_value SYMBOLSPERBEAT ]
    set BITSPERSYMBOL [ get_parameter_value BITSPERSYMBOL ]

    set_interface_property data_sink dataBitsPerSymbol $BITSPERSYMBOL
    set_interface_property data_sink symbolsPerBeat $SYMBOLSPERBEAT
    set_interface_property data_sink maxChannel 0
    set_interface_property data_src dataBitsPerSymbol $BITSPERSYMBOL
    set_interface_property data_src symbolsPerBeat $SYMBOLSPERBEAT
    set_interface_property data_src maxChannel 0

    set_port_property tx_egress_timestamp_request_in_fingerprint WIDTH $TSTAMP_FP_WIDTH
    set_port_property tx_egress_timestamp_request_out_fingerprint WIDTH $TSTAMP_FP_WIDTH


    set data_width [ expr $SYMBOLSPERBEAT * $BITSPERSYMBOL ]
    set_port_property data_sink_data WIDTH $data_width
    set_port_property data_src_data WIDTH $data_width
	
	if {$SYMBOLSPERBEAT >= 8} {
		add_interface_port data_sink data_sink_empty empty Input 3
		add_interface_port data_src data_src_empty empty Output 3
	
		set empty_width [ expr int(ceil(log($SYMBOLSPERBEAT) / log(2))) ]
		set_port_property data_sink_empty WIDTH $empty_width
		set_port_property data_src_empty WIDTH $empty_width
	}
  
    set_port_property data_sink_error WIDTH 1
    set_port_property data_src_error WIDTH 1

    set_port_property tx_etstamp_ins_ctrl_in_ingress_timestamp_96b WIDTH 96
    set_port_property tx_etstamp_ins_ctrl_in_ingress_timestamp_64b WIDTH 64
    set_port_property tx_etstamp_ins_ctrl_out_ingress_timestamp_96b WIDTH 96
    set_port_property tx_etstamp_ins_ctrl_out_ingress_timestamp_64b WIDTH 64
}


# 
# display items
# 


# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end
set_interface_property clock_reset ptfSchematicName ""

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset reset reset Input 1
# | 
# +-----------------------------------


# +-----------------------------------
# | connection point data_sink
# | 
add_interface data_sink avalon_streaming end
set_interface_property data_sink dataBitsPerSymbol 8
set_interface_property data_sink errorDescriptor ""
set_interface_property data_sink maxChannel 1
set_interface_property data_sink readyLatency 0
set_interface_property data_sink symbolsPerBeat 8

set_interface_property data_sink associatedClock clock_reset
set_interface_property data_sink ENABLED true

add_interface_port data_sink data_sink_sop startofpacket Input 1
add_interface_port data_sink data_sink_eop endofpacket Input 1
add_interface_port data_sink data_sink_valid valid Input 1
add_interface_port data_sink data_sink_ready ready Output 1
add_interface_port data_sink data_sink_data data Input 64


add_interface_port data_sink data_sink_error error Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point data_src
# | 
add_interface data_src avalon_streaming start
set_interface_property data_src dataBitsPerSymbol 8
set_interface_property data_src errorDescriptor ""
set_interface_property data_src maxChannel 1
set_interface_property data_src readyLatency 0
set_interface_property data_src symbolsPerBeat 8

set_interface_property data_src associatedClock clock_reset
set_interface_property data_src ENABLED true

add_interface_port data_src data_src_sop startofpacket Output 1
add_interface_port data_src data_src_eop endofpacket Output 1
add_interface_port data_src data_src_valid valid Output 1
add_interface_port data_src data_src_ready ready Input 1
add_interface_port data_src data_src_data data Output 64
add_interface_port data_src data_src_error error Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock operation mode 
# | 
add_interface clock_operation_mode conduit end
#set_interface_assignment clock_operation_mode "ui.blockdiagram.direction" Input

set_interface_property clock_operation_mode ENABLED true
add_interface_port clock_operation_mode clock_mode mode Input 2
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point is packet with crc
# | 1 = packet with crc; 0 = packet without crc
add_interface pkt_with_crc conduit end
#set_interface_assignment pkt_with_crc "ui.blockdiagram.direction" Input

set_interface_property pkt_with_crc ENABLED true
add_interface_port pkt_with_crc pkt_with_crc mode Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tx_egress_timestamp_request_in
# | 
add_interface tx_egress_timestamp_request_in conduit end
#set_interface_assignment tx_egress_timestamp_request_in "ui.blockdiagram.direction" Input
set_interface_property tx_egress_timestamp_request_in ENABLED true

add_interface_port tx_egress_timestamp_request_in tx_egress_timestamp_request_in_valid valid Input 1
add_interface_port tx_egress_timestamp_request_in tx_egress_timestamp_request_in_fingerprint fingerprint Input 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point egress_timestamp_request
# | 
add_interface tx_egress_timestamp_request_out conduit start
#set_interface_assignment tx_egress_timestamp_request_out "ui.blockdiagram.direction" Input
set_interface_property tx_egress_timestamp_request_out ENABLED true

add_interface_port tx_egress_timestamp_request_out tx_egress_timestamp_request_out_valid valid Output 1
add_interface_port tx_egress_timestamp_request_out tx_egress_timestamp_request_out_fingerprint fingerprint Output 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tx_etstamp_ins_ctrl_in
# | 
add_interface tx_etstamp_ins_ctrl_in conduit end
#set_interface_assignment tx_egress_timestamp_insertcontrol_in "ui.blockdiagram.direction" Input
set_interface_property tx_etstamp_ins_ctrl_in ENABLED true

add_interface_port tx_etstamp_ins_ctrl_in tx_etstamp_ins_ctrl_in_residence_time_update residence_time_update Input 1
add_interface_port tx_etstamp_ins_ctrl_in tx_etstamp_ins_ctrl_in_ingress_timestamp_96b ingress_timestamp_96b Input 96
add_interface_port tx_etstamp_ins_ctrl_in tx_etstamp_ins_ctrl_in_ingress_timestamp_64b ingress_timestamp_64b Input 64
add_interface_port tx_etstamp_ins_ctrl_in tx_etstamp_ins_ctrl_in_residence_time_calc_format residence_time_calc_format Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point tx_etstamp_ins_ctrl_out
# | 
add_interface tx_etstamp_ins_ctrl_out conduit start
#set_interface_assignment tx_egress_timestamp_insertcontrol_out "ui.blockdiagram.direction" Input
set_interface_property tx_etstamp_ins_ctrl_out ENABLED true

add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_timestamp_insert timestamp_insert Output 1
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_timestamp_format timestamp_format Output 1

add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_residence_time_update residence_time_update Output 1
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_ingress_timestamp_96b ingress_timestamp_96b Output 96
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_ingress_timestamp_64b ingress_timestamp_64b Output 64
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_residence_time_calc_format residence_time_calc_format Output 1

add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_checksum_zero checksum_zero Output 1
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_checksum_correct checksum_correct Output 1

add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_offset_timestamp offset_timestamp Output 16
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_offset_correction_field offset_correction_field Output 16
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_offset_checksum_field offset_checksum_field Output 16
add_interface_port tx_etstamp_ins_ctrl_out tx_etstamp_ins_ctrl_out_offset_checksum_correction offset_checksum_correction Output 16
# | 
# +-----------------------------------
