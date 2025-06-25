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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_multithread_traffic_limiter/threadid_mapping/altera_merlin_threadid_mapping_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +--------------------------------------------------------------------------
# | altera_merlin_threadid_mapping "Memory-Mapped ThreadID mapping" 
# | This component recieved ID mapping ranges from user setting
# | and map input thread ID from master to each ranges
# +--------------------------------------------------------------------------

# 
# request TCL package from ACDS 13.1
# 
package require -exact qsys 13.1
package require -exact altera_terp 1.0

# 
# module altera_merlin_threadid_mapping
# 
set_module_property DESCRIPTION ""
set_module_property NAME altera_merlin_threadid_mapping
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property VERSION  13.1
set_module_property GROUP "Qsys Interconnect/Memory-Mapped"
set_module_property AUTHOR tgngo
set_module_property DISPLAY_NAME "Memory-Mapped ThreadID mapping"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate
#set_module_property VALIDATION_CALLBACK validate

# 
# file sets
# 

add_fileset my_synthesis_fileset QUARTUS_SYNTH synth_callback_procedure_verilog
add_fileset my_synthesis_fileset SIM_VERILOG synth_callback_procedure_verilog
add_fileset my_synthesis_fileset SIM_VHDL synth_callback_procedure_vhdl

# TODO: VHDL

# 
# parameters
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

add_parameter BINARY_FORMAT_INFO STRING_LIST "11-00000-6-4-001"
set_parameter_property BINARY_FORMAT_INFO DISPLAY_NAME {Binary mapping ranges infos}
set_parameter_property BINARY_FORMAT_INFO UNITS None
set_parameter_property BINARY_FORMAT_INFO HDL_PARAMETER false
set_parameter_property BINARY_FORMAT_INFO GROUP "ID Mapping Table"
set_parameter_property BINARY_FORMAT_INFO DESCRIPTION {ID Dis-continous mapping range}
set_parameter_property BINARY_FORMAT_INFO AFFECTS_ELABORATION true

add_parameter MAPPING_RANGES_FORMAT STRING "hex" 
set_parameter_property MAPPING_RANGES_FORMAT DISPLAY_NAME {ID Mapping range format}
set_parameter_property MAPPING_RANGES_FORMAT UNITS None
set_parameter_property MAPPING_RANGES_FORMAT HDL_PARAMETER false
set_parameter_property MAPPING_RANGES_FORMAT DESCRIPTION {ID Mapping range format}
set_parameter_property MAPPING_RANGES_FORMAT AFFECTS_ELABORATION true

add_parameter NUM_THREAD_ID INTEGER 2 0
set_parameter_property NUM_THREAD_ID DISPLAY_NAME {Number of thread IDs}
set_parameter_property NUM_THREAD_ID UNITS None
set_parameter_property NUM_THREAD_ID DESCRIPTION {Number of thread IDs}
set_parameter_property NUM_THREAD_ID AFFECTS_ELABORATION true
add_parameter IN_ST_DATA_W INTEGER 72 "In Streaming data width"
set_parameter_property IN_ST_DATA_W DEFAULT_VALUE 72
set_parameter_property IN_ST_DATA_W DISPLAY_NAME "In Streaming data width"
set_parameter_property IN_ST_DATA_W TYPE INTEGER
set_parameter_property IN_ST_DATA_W UNITS None
set_parameter_property IN_ST_DATA_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property IN_ST_DATA_W DESCRIPTION "In Streaming data width"
set_parameter_property IN_ST_DATA_W HDL_PARAMETER false
add_parameter IN_ST_CHANNEL_W INTEGER 1 "In Streaming channel width"
set_parameter_property IN_ST_CHANNEL_W DEFAULT_VALUE 1
set_parameter_property IN_ST_CHANNEL_W DISPLAY_NAME "In Streaming channel width"
set_parameter_property IN_ST_CHANNEL_W TYPE INTEGER
set_parameter_property IN_ST_CHANNEL_W UNITS None
set_parameter_property IN_ST_CHANNEL_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property IN_ST_CHANNEL_W DESCRIPTION "In Streaming channel width"
set_parameter_property IN_ST_CHANNEL_W HDL_PARAMETER false
add_parameter MAX_OUTSTANDING_RESPONSES INTEGER 0 "Maximum outstanding responses"
set_parameter_property MAX_OUTSTANDING_RESPONSES DEFAULT_VALUE 0
set_parameter_property MAX_OUTSTANDING_RESPONSES DISPLAY_NAME "Maximum outstanding responses"
set_parameter_property MAX_OUTSTANDING_RESPONSES TYPE INTEGER
set_parameter_property MAX_OUTSTANDING_RESPONSES UNITS None
set_parameter_property MAX_OUTSTANDING_RESPONSES ALLOWED_RANGES -2147483648:2147483647
set_parameter_property MAX_OUTSTANDING_RESPONSES DESCRIPTION "Maximum outstanding responses"
set_parameter_property MAX_OUTSTANDING_RESPONSES HDL_PARAMETER false
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
add_parameter OUT_ST_DATA_W INTEGER 74 "Out Streaming data width"
set_parameter_property OUT_ST_DATA_W DEFAULT_VALUE 74
set_parameter_property OUT_ST_DATA_W DISPLAY_NAME "Out Streaming data width"
set_parameter_property OUT_ST_DATA_W TYPE INTEGER
set_parameter_property OUT_ST_DATA_W UNITS None
set_parameter_property OUT_ST_DATA_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property OUT_ST_DATA_W DESCRIPTION "Output Streaming data width"
set_parameter_property OUT_ST_DATA_W HDL_PARAMETER false
add_parameter OUT_ST_CHANNEL_W INTEGER 4 "Out Streaming channel  width"
set_parameter_property OUT_ST_CHANNEL_W DEFAULT_VALUE 4
set_parameter_property OUT_ST_CHANNEL_W DISPLAY_NAME "Out Streaming channel  width"
set_parameter_property OUT_ST_CHANNEL_W TYPE INTEGER
set_parameter_property OUT_ST_CHANNEL_W UNITS None
set_parameter_property OUT_ST_CHANNEL_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property OUT_ST_CHANNEL_W DESCRIPTION "Out Streaming channel  width"
set_parameter_property OUT_ST_CHANNEL_W HDL_PARAMETER false
add_parameter VALID_WIDTH INTEGER 1 "Valid width output vector"
set_parameter_property VALID_WIDTH DEFAULT_VALUE 1
set_parameter_property VALID_WIDTH DISPLAY_NAME "Valid width output vector"
set_parameter_property VALID_WIDTH TYPE INTEGER
set_parameter_property VALID_WIDTH UNITS None
set_parameter_property VALID_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property VALID_WIDTH DESCRIPTION "Valid width output vector"
set_parameter_property VALID_WIDTH HDL_PARAMETER false

add_parameter THREADID_INFO STRING "" 0
set_parameter_property THREADID_INFO UNITS None
set_parameter_property THREADID_INFO AFFECTS_ELABORATION true
set_parameter_property THREADID_INFO VISIBLE false
set_parameter_property THREADID_INFO DERIVED false

add_parameter COMMAND_ID_MAPPER INTEGER 0
set_parameter_property COMMAND_ID_MAPPER DISPLAY_NAME {ThreadID mapper at command (1: command; 0: response)}
set_parameter_property COMMAND_ID_MAPPER UNITS None
set_parameter_property COMMAND_ID_MAPPER ALLOWED_RANGES 0:1
set_parameter_property COMMAND_ID_MAPPER DESCRIPTION {ThreadID mapper at command (1: command; 0: response)}
set_parameter_property COMMAND_ID_MAPPER AFFECTS_ELABORATION true
set_parameter_property COMMAND_ID_MAPPER HDL_PARAMETER false


# 
# display items
# 


# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED true
set_interface_property clk EXPORT_OF ""
set_interface_property clk PORT_NAME_MAP ""
set_interface_property clk SVD_ADDRESS_GROUP ""

add_interface_port clk clk clk Input 1


# 
# connection point clk_reset
# 
add_interface clk_reset reset end
set_interface_property clk_reset associatedClock clk
set_interface_property clk_reset synchronousEdges DEASSERT
set_interface_property clk_reset ENABLED true
set_interface_property clk_reset EXPORT_OF ""
set_interface_property clk_reset PORT_NAME_MAP ""
set_interface_property clk_reset SVD_ADDRESS_GROUP ""

add_interface_port clk_reset reset reset Input 1


# 
# connection point cmd_sink
# 
add_interface cmd_sink avalon_streaming end
set_interface_property cmd_sink associatedClock clk
set_interface_property cmd_sink associatedReset clk_reset
set_interface_property cmd_sink dataBitsPerSymbol 8
set_interface_property cmd_sink errorDescriptor ""
set_interface_property cmd_sink firstSymbolInHighOrderBits true
set_interface_property cmd_sink maxChannel 0
set_interface_property cmd_sink readyLatency 0
set_interface_property cmd_sink ENABLED true
set_interface_property cmd_sink EXPORT_OF ""
set_interface_property cmd_sink PORT_NAME_MAP ""
set_interface_property cmd_sink SVD_ADDRESS_GROUP ""

add_interface_port cmd_sink cmd_sink_ready ready Output 1
add_interface_port cmd_sink cmd_sink_valid valid Input 1
add_interface_port cmd_sink cmd_sink_data data Input 8
add_interface_port cmd_sink cmd_sink_channel channel Input 1
add_interface_port cmd_sink cmd_sink_startofpacket startofpacket Input 1
add_interface_port cmd_sink cmd_sink_endofpacket endofpacket Input 1


# 
# connection point cmd_src
# 
add_interface cmd_src avalon_streaming start
set_interface_property cmd_src associatedClock clk
set_interface_property cmd_src associatedReset clk_reset
set_interface_property cmd_src dataBitsPerSymbol 8
set_interface_property cmd_src errorDescriptor ""
set_interface_property cmd_src firstSymbolInHighOrderBits true
set_interface_property cmd_src maxChannel 0
set_interface_property cmd_src readyLatency 0
set_interface_property cmd_src ENABLED true
set_interface_property cmd_src EXPORT_OF ""
set_interface_property cmd_src PORT_NAME_MAP ""
set_interface_property cmd_src SVD_ADDRESS_GROUP ""

add_interface_port cmd_src cmd_src_ready ready Input 1
add_interface_port cmd_src cmd_src_data data Output 8
add_interface_port cmd_src cmd_src_channel channel Output 1
add_interface_port cmd_src cmd_src_startofpacket startofpacket Output 1
add_interface_port cmd_src cmd_src_endofpacket endofpacket Output 1


# 
# connection point rsp_sink
# 
add_interface rsp_sink avalon_streaming end
set_interface_property rsp_sink associatedClock clk
set_interface_property rsp_sink associatedReset clk_reset
set_interface_property rsp_sink dataBitsPerSymbol 8
set_interface_property rsp_sink errorDescriptor ""
set_interface_property rsp_sink firstSymbolInHighOrderBits true
set_interface_property rsp_sink maxChannel 0
set_interface_property rsp_sink readyLatency 0
set_interface_property rsp_sink ENABLED true
set_interface_property rsp_sink EXPORT_OF ""
set_interface_property rsp_sink PORT_NAME_MAP ""
set_interface_property rsp_sink SVD_ADDRESS_GROUP ""

add_interface_port rsp_sink rsp_sink_ready ready Output 1
add_interface_port rsp_sink rsp_sink_valid valid Input 1
add_interface_port rsp_sink rsp_sink_channel channel Input 1
add_interface_port rsp_sink rsp_sink_data data Input 8
add_interface_port rsp_sink rsp_sink_startofpacket startofpacket Input 1
add_interface_port rsp_sink rsp_sink_endofpacket endofpacket Input 1


# 
# connection point rsp_src
# 
add_interface rsp_src avalon_streaming start
set_interface_property rsp_src associatedClock clk
set_interface_property rsp_src associatedReset clk_reset
set_interface_property rsp_src dataBitsPerSymbol 8
set_interface_property rsp_src errorDescriptor ""
set_interface_property rsp_src firstSymbolInHighOrderBits true
set_interface_property rsp_src maxChannel 0
set_interface_property rsp_src readyLatency 0
set_interface_property rsp_src ENABLED true
set_interface_property rsp_src EXPORT_OF ""
set_interface_property rsp_src PORT_NAME_MAP ""
set_interface_property rsp_src SVD_ADDRESS_GROUP ""

add_interface_port rsp_src rsp_src_ready ready Input 1
add_interface_port rsp_src rsp_src_valid valid Output 1
add_interface_port rsp_src rsp_src_data data Output 8
add_interface_port rsp_src rsp_src_channel channel Output 1
add_interface_port rsp_src rsp_src_startofpacket startofpacket Output 1
add_interface_port rsp_src rsp_src_endofpacket endofpacket Output 1

# +----------------------------------------------
# | generate callback
# +----------------------------------------------
proc synth_callback_procedure_verilog { entity_name } {
    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_merlin_threadid_mapping.sv.terp" ]

    set template_fh [ open $template_file r ]
    set template    [ read $template_fh ]
    close $template_fh


    set params(pkt_threadid_h)    [ get_parameter_value PKT_THREAD_ID_H ]
    set params(pkt_threadid_l)    [ get_parameter_value PKT_THREAD_ID_L ]
    set params(in_st_data_w)      [ get_parameter_value IN_ST_DATA_W ]
    set params(in_st_channel_w)   [ get_parameter_value IN_ST_CHANNEL_W ]
    set params(out_st_data_w)     [ get_parameter_value OUT_ST_DATA_W ]
    set params(out_st_channel_w)  [ get_parameter_value OUT_ST_CHANNEL_W ]
    set params(valid_w)  	      [ get_parameter_value VALID_WIDTH ]
	set params(id_mapping_format)  	      [ get_parameter_value MAPPING_RANGES_FORMAT ]
	set params(command_threadid_mapper)       [ get_parameter_value COMMAND_ID_MAPPER ]
    set params(output_name) $entity_name

    set params(threadid_info) [ get_parameter_value THREADID_INFO ]
    set result          [ altera_terp $template params ]
    set output_file     [ create_temp_file ${entity_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    add_fileset_file ${entity_name}.sv SYSTEM_VERILOG PATH ${output_file}

}   

proc synth_callback_procedure_vhdl { entity_name } {
    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_merlin_threadid_mapping.sv.terp" ]

    set template_fh [ open $template_file r ]
    set template    [ read $template_fh ]
    close $template_fh


    set params(pkt_threadid_h)    [ get_parameter_value PKT_THREAD_ID_H ]
    set params(pkt_threadid_l)    [ get_parameter_value PKT_THREAD_ID_L ]
    set params(in_st_data_w)      [ get_parameter_value IN_ST_DATA_W ]
    set params(in_st_channel_w)   [ get_parameter_value IN_ST_CHANNEL_W ]
    set params(out_st_data_w)     [ get_parameter_value OUT_ST_DATA_W ]
    set params(out_st_channel_w)  [ get_parameter_value OUT_ST_CHANNEL_W ]
    set params(valid_w)  	      [ get_parameter_value VALID_WIDTH ]
	set params(id_mapping_format)  	      [ get_parameter_value MAPPING_RANGES_FORMAT ]
	set params(command_threadid_mapper)       [ get_parameter_value COMMAND_ID_MAPPER ]
    set params(output_name) $entity_name

    set params(threadid_info) [ get_parameter_value THREADID_INFO ]
    set result          [ altera_terp $template params ]
    set output_file     [ create_temp_file ${entity_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

	set vhdl_file_without_extension [call_simgen  ${output_file} "--simgen_parameter=CBX_HDL_LANGUAGE=VHDL"]
    add_fileset_file ${entity_name}.vho VHDL PATH ${vhdl_file_without_extension}.vho
}

# +----------------------------------------------
# | validate callback
# +----------------------------------------------
# proc validate {} {

    # set num_threadids       [ get_parameter_value THREAD_ID ]
    # set threadid_depth      [ get_parameter_value THREAD_ID_DEPTH ]
	# set channel_decoded     [ get_parameter_value CHANNEL_DECODED ]
    # set lowid_range         [ get_parameter_value LOW_ID ]
    # set highid_range        [ get_parameter_value HIGH_ID ]

    # set num_threadids_length    [ llength $num_threadids ]
    # set threadid_depth_length   [ llength $threadid_depth]
    # set channel_decoded_length  [ llength $channel_decoded ]
    # set lowid_range_length      [ llength $lowid_range]
    # set highid_range_length     [ llength $highid_range]

# ## Check/Validate lengths are consistent
# if { $num_threadids_length != $threadid_depth_length  || $num_threadids_length != $lowid_range_length || $num_threadids_length != $highid_range_length || $num_threadids_length != $channel_decoded_length} {
    # send_message {error} "Thread ID Mapping Table not fully specified .... NUM_THREAD_ID=$num_threadids_length, THREAD_ID_DEPTH=$threadid_depth_length CHANNEL_DECODED=$channel_decoded_length LOW_ID=$lowid_range_length HIGH_ID=$highid_range_length"
# } else {
    # set threadid_info ""
    # # SET slave_info for TERP based on inputs from transform
	# foreach threadid ${num_threadids} depthid ${threadid_depth} channel ${channel_decoded} lowid ${lowid_range} highid ${highid_range} {
	    # if { ! [ string equal "" $threadid_info ] } {
            # set threadid_info "$threadid_info,${threadid}:${depthid}:${channel}:${lowid}:${highid}"
	    # } else {
            # set threadid_info "${threadid}:${depthid}:${channel}:${lowid}:${highid}"
	    # }
        
	# }
	# set_parameter_value THREADID_INFO $threadid_info
    # }

# }

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

	set num_threads     [ get_parameter_value NUM_THREAD_ID ]
    set in_st_data_width [ get_parameter_value IN_ST_DATA_W    ]
    set in_st_chan_width [ get_parameter_value IN_ST_CHANNEL_W ]
	# OUT_ST_DATA_W = IN_ST_DATA_W + IN_ST_CHANNEL_W
	set threadid_info [ get_parameter_value THREADID_INFO ]
	
	set out_st_data_width [ get_parameter_value OUT_ST_DATA_W    ]
    set out_st_chan_width [ get_parameter_value OUT_ST_CHANNEL_W ]
    set valid_width   [ get_parameter_value VALID_WIDTH ]

    set_interface_property cmd_sink dataBitsPerSymbol $in_st_data_width
    set_interface_property cmd_src  dataBitsPerSymbol $out_st_data_width
    set_interface_property rsp_src  dataBitsPerSymbol $in_st_data_width
    set_interface_property rsp_sink dataBitsPerSymbol $out_st_data_width

    set_port_property cmd_sink_data WIDTH_EXPR $in_st_data_width
	set_port_property  cmd_sink_data vhdl_type std_logic_vector
    set_port_property cmd_src_data  WIDTH_EXPR $out_st_data_width
	set_port_property  cmd_src_data vhdl_type std_logic_vector
    set_port_property rsp_src_data  WIDTH_EXPR $in_st_data_width
	set_port_property  rsp_src_data vhdl_type std_logic_vector
    set_port_property rsp_sink_data WIDTH_EXPR $out_st_data_width
	set_port_property  rsp_sink_data vhdl_type std_logic_vector

	set_port_property cmd_sink_channel WIDTH_EXPR $in_st_chan_width
	set_port_property  cmd_sink_channel vhdl_type std_logic_vector
    set_port_property cmd_src_channel WIDTH_EXPR $out_st_chan_width
	set_port_property  cmd_src_channel vhdl_type std_logic_vector
    set_port_property rsp_src_channel WIDTH_EXPR $in_st_chan_width
	set_port_property  rsp_src_channel vhdl_type std_logic_vector
    set_port_property rsp_sink_channel WIDTH_EXPR $out_st_chan_width
	set_port_property  rsp_sink_channel vhdl_type std_logic_vector
    

    if { $valid_width == 1 } {
        add_interface_port cmd_src cmd_src_valid valid Output 1
    } else {
        add_interface cmd_valid avalon_streaming start
        set_interface_property cmd_valid dataBitsPerSymbol $valid_width
        set_interface_property cmd_valid associatedClock clk
        set_interface_property cmd_valid associatedReset clk_reset
        add_interface_port cmd_valid cmd_src_valid data Output $valid_width
    }
	set_port_property cmd_src_valid VHDL_TYPE STD_LOGIC_VECTOR
}
