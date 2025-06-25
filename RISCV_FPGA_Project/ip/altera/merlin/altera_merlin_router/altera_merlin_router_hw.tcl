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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_router/altera_merlin_router_hw.tcl#2 $
# $Revision: #2 $
# $Date: 2013/09/12 $
# $Author: kevtan $

# +-----------------------------------
# | 
# | altera_merlin_router "Merlin Router" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact qsys 12.1
package require -exact altera_terp 1.0

# +-----------------------------------
# | module altera_merlin_router
# | 
set_module_property NAME altera_merlin_router
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Memory Mapped Router"
set_module_property DESCRIPTION "Routes command packets from the master to the slave and response packets from the slave to the master."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate
set_module_property HIDE_FROM_SOPC true
#set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 

add_display_item "" "Address Routing Table" "group" "table"

add_parameter DESTINATION_ID INTEGER_LIST 1
set_parameter_property DESTINATION_ID DISPLAY_NAME {Destination ID}
set_parameter_property DESTINATION_ID AFFECTS_ELABORATION true
set_parameter_property DESTINATION_ID HDL_PARAMETER false
set_parameter_property DESTINATION_ID GROUP "Address Routing Table"
set_parameter_property DESTINATION_ID DESCRIPTION {List of destination IDs}

add_parameter CHANNEL_ID STRING_LIST "01"
set_parameter_property CHANNEL_ID DISPLAY_NAME {Binary Channel String}
set_parameter_property CHANNEL_ID AFFECTS_ELABORATION true
set_parameter_property CHANNEL_ID HDL_PARAMETER false
set_parameter_property CHANNEL_ID GROUP "Address Routing Table"
set_parameter_property CHANNEL_ID DESCRIPTION {List of channel IDs}

add_parameter TYPE_OF_TRANSACTION STRING_LIST 
set_parameter_property TYPE_OF_TRANSACTION DISPLAY_NAME {Type of Transaction}
set_parameter_property TYPE_OF_TRANSACTION AFFECTS_ELABORATION true
set_parameter_property TYPE_OF_TRANSACTION HDL_PARAMETER false
set_parameter_property TYPE_OF_TRANSACTION GROUP "Address Routing Table"
set_parameter_property TYPE_OF_TRANSACTION DESCRIPTION {Type of Transaction: both the slave can acepts both write and read}

add_parameter START_ADDRESS STRING_LIST 0
set_parameter_property START_ADDRESS DISPLAY_NAME {Start addresses (inclusive)}
set_parameter_property START_ADDRESS AFFECTS_ELABORATION true
set_parameter_property START_ADDRESS HDL_PARAMETER false
set_parameter_property START_ADDRESS GROUP "Address Routing Table"
set_parameter_property START_ADDRESS DISPLAY_HINT "hexadecimal"
set_parameter_property START_ADDRESS DESCRIPTION {List of start addresses (inclusive)}

add_parameter END_ADDRESS STRING_LIST 0
set_parameter_property END_ADDRESS DISPLAY_NAME {End addresses (exclusive)}
set_parameter_property END_ADDRESS AFFECTS_ELABORATION true
set_parameter_property END_ADDRESS HDL_PARAMETER false
set_parameter_property END_ADDRESS GROUP "Address Routing Table"
set_parameter_property END_ADDRESS DISPLAY_HINT "hexadecimal"
set_parameter_property END_ADDRESS DESCRIPTION {List of end addresses (exclusive)}

add_parameter NON_SECURED_TAG STRING_LIST 
set_parameter_property NON_SECURED_TAG DISPLAY_NAME {Non-secured tags}
set_parameter_property NON_SECURED_TAG AFFECTS_ELABORATION true
set_parameter_property NON_SECURED_TAG HDL_PARAMETER false
set_parameter_property NON_SECURED_TAG GROUP "Address Routing Table"
set_parameter_property NON_SECURED_TAG DISPLAY_HINT "hexadecimal"
set_parameter_property NON_SECURED_TAG DESCRIPTION {List of security tags}

add_parameter SECURED_RANGE_PAIRS STRING_LIST
set_parameter_property SECURED_RANGE_PAIRS DISPLAY_NAME {Number of secured range pairs}
set_parameter_property SECURED_RANGE_PAIRS AFFECTS_ELABORATION true
set_parameter_property SECURED_RANGE_PAIRS HDL_PARAMETER false
set_parameter_property SECURED_RANGE_PAIRS GROUP "Address Routing Table"
set_parameter_property SECURED_RANGE_PAIRS DISPLAY_HINT "hexadecimal"
set_parameter_property SECURED_RANGE_PAIRS DESCRIPTION {Number of security range pairs (if not full)}

add_parameter SECURED_RANGE_LIST STRING_LIST
set_parameter_property SECURED_RANGE_LIST DISPLAY_NAME {Secured range pairs}
set_parameter_property SECURED_RANGE_LIST AFFECTS_ELABORATION true
set_parameter_property SECURED_RANGE_LIST HDL_PARAMETER false
set_parameter_property SECURED_RANGE_LIST GROUP "Address Routing Table"
set_parameter_property SECURED_RANGE_LIST DISPLAY_HINT "hexadecimal"
set_parameter_property SECURED_RANGE_LIST DESCRIPTION {List of security range pairs (if not full)}

add_parameter SPAN_OFFSET STRING_LIST
set_parameter_property SPAN_OFFSET DISPLAY_NAME {Offset of a base address from its valid span}
set_parameter_property SPAN_OFFSET AFFECTS_ELABORATION true
set_parameter_property SPAN_OFFSET HDL_PARAMETER false
set_parameter_property SPAN_OFFSET GROUP "Address Routing Table"
set_parameter_property SPAN_OFFSET DISPLAY_HINT "hexadecimal"
set_parameter_property SPAN_OFFSET DESCRIPTION {Used to determine if optimization can be done on routing, and the offset of the address required to be shifted}

add_parameter PKT_ADDR_H INTEGER 0 0
set_parameter_property PKT_ADDR_H DISPLAY_NAME {Packet address field index - high}
set_parameter_property PKT_ADDR_H UNITS None
set_parameter_property PKT_ADDR_H ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_ADDR_H DESCRIPTION {MSB of the packet address field index}
set_parameter_property PKT_ADDR_H AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_H HDL_PARAMETER false

add_parameter PKT_ADDR_L INTEGER 0 0
set_parameter_property PKT_ADDR_L DISPLAY_NAME {Packet address field index - low}
set_parameter_property PKT_ADDR_L UNITS None
set_parameter_property PKT_ADDR_L ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_ADDR_L DESCRIPTION {LSB of the packet address field index}
set_parameter_property PKT_ADDR_L AFFECTS_ELABORATION true
set_parameter_property PKT_ADDR_L HDL_PARAMETER false

add_parameter PKT_PROTECTION_H INTEGER 0 0
set_parameter_property PKT_PROTECTION_H DISPLAY_NAME {Packet AXI protection field index - high}
set_parameter_property PKT_PROTECTION_H UNITS None
set_parameter_property PKT_PROTECTION_H ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_PROTECTION_H DESCRIPTION {MSB of the Packet AXI protection field index}
set_parameter_property PKT_PROTECTION_H AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_H HDL_PARAMETER false

add_parameter PKT_PROTECTION_L INTEGER 0 0
set_parameter_property PKT_PROTECTION_L DISPLAY_NAME {Packet AXI protection field index - low}
set_parameter_property PKT_PROTECTION_L UNITS None
set_parameter_property PKT_PROTECTION_L ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_PROTECTION_L DESCRIPTION {LSB of the Packet AXI protection field index}
set_parameter_property PKT_PROTECTION_L AFFECTS_ELABORATION true
set_parameter_property PKT_PROTECTION_L HDL_PARAMETER false

add_parameter PKT_DEST_ID_H INTEGER 0 0
set_parameter_property PKT_DEST_ID_H DISPLAY_NAME {Packet destination id field index - high}
set_parameter_property PKT_DEST_ID_H UNITS None
set_parameter_property PKT_DEST_ID_H ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_DEST_ID_H DESCRIPTION {MSB of the packet destination id field index}
set_parameter_property PKT_DEST_ID_H AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_H HDL_PARAMETER false

add_parameter PKT_DEST_ID_L INTEGER 0 0
set_parameter_property PKT_DEST_ID_L DISPLAY_NAME {Packet destination id field index - low}
set_parameter_property PKT_DEST_ID_L UNITS None
set_parameter_property PKT_DEST_ID_L ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_DEST_ID_L DESCRIPTION {LSB of the packet destination id field index}
set_parameter_property PKT_DEST_ID_L AFFECTS_ELABORATION true
set_parameter_property PKT_DEST_ID_L HDL_PARAMETER false

add_parameter PKT_TRANS_WRITE INTEGER 0 0
set_parameter_property PKT_TRANS_WRITE DISPLAY_NAME {Packet write transaction field index}
set_parameter_property PKT_TRANS_WRITE UNITS None
set_parameter_property PKT_TRANS_WRITE ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_TRANS_WRITE DESCRIPTION {Packet write transaction field index}
set_parameter_property PKT_TRANS_WRITE AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_WRITE HDL_PARAMETER false

add_parameter PKT_TRANS_READ INTEGER 0 0
set_parameter_property PKT_TRANS_READ DISPLAY_NAME {Packet read transaction field index}
set_parameter_property PKT_TRANS_READ UNITS None
set_parameter_property PKT_TRANS_READ ALLOWED_RANGES 0:2147483647
set_parameter_property PKT_TRANS_READ DESCRIPTION {Packet read transaction field index}
set_parameter_property PKT_TRANS_READ AFFECTS_ELABORATION true
set_parameter_property PKT_TRANS_READ HDL_PARAMETER false

add_parameter ST_DATA_W INTEGER 8 0
set_parameter_property ST_DATA_W DISPLAY_NAME {Streaming data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_DATA_W DESCRIPTION {StreamingPacket data width}
set_parameter_property ST_DATA_W AFFECTS_ELABORATION true
set_parameter_property ST_DATA_W HDL_PARAMETER false

add_parameter ST_CHANNEL_W INTEGER 0 0
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
set_parameter_property ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER false

add_parameter SLAVES_INFO STRING "" 0
set_parameter_property SLAVES_INFO UNITS None
set_parameter_property SLAVES_INFO AFFECTS_ELABORATION true
set_parameter_property SLAVES_INFO VISIBLE false
set_parameter_property SLAVES_INFO DERIVED true

add_parameter DECODER_TYPE INTEGER 0
set_parameter_property DECODER_TYPE DISPLAY_NAME {Decoder type}
set_parameter_property DECODER_TYPE UNITS None
set_parameter_property DECODER_TYPE ALLOWED_RANGES 0:1
set_parameter_property DECODER_TYPE DESCRIPTION {Decoder type}
set_parameter_property DECODER_TYPE AFFECTS_ELABORATION true
set_parameter_property DECODER_TYPE HDL_PARAMETER false

add_parameter DEFAULT_CHANNEL INTEGER -1
set_parameter_property DEFAULT_CHANNEL DISPLAY_NAME {Default channel}
set_parameter_property DEFAULT_CHANNEL UNITS None
set_parameter_property DEFAULT_CHANNEL ALLOWED_RANGES -1:2147483647
set_parameter_property DEFAULT_CHANNEL DESCRIPTION {Default channel}
set_parameter_property DEFAULT_CHANNEL AFFECTS_ELABORATION true
set_parameter_property DEFAULT_CHANNEL HDL_PARAMETER false

add_parameter DEFAULT_WR_CHANNEL INTEGER -1
set_parameter_property DEFAULT_WR_CHANNEL DISPLAY_NAME {Default wr channel}
set_parameter_property DEFAULT_WR_CHANNEL UNITS None
set_parameter_property DEFAULT_WR_CHANNEL ALLOWED_RANGES -1:2147483647
set_parameter_property DEFAULT_WR_CHANNEL DESCRIPTION {Default channel}
set_parameter_property DEFAULT_WR_CHANNEL AFFECTS_ELABORATION true
set_parameter_property DEFAULT_WR_CHANNEL HDL_PARAMETER false

add_parameter DEFAULT_RD_CHANNEL INTEGER -1
set_parameter_property DEFAULT_RD_CHANNEL DISPLAY_NAME {Default rd channel}
set_parameter_property DEFAULT_RD_CHANNEL UNITS None
set_parameter_property DEFAULT_RD_CHANNEL ALLOWED_RANGES -1:2147483647
set_parameter_property DEFAULT_RD_CHANNEL DESCRIPTION {Default channel}
set_parameter_property DEFAULT_RD_CHANNEL AFFECTS_ELABORATION true
set_parameter_property DEFAULT_RD_CHANNEL HDL_PARAMETER false

add_parameter DEFAULT_DESTID INTEGER 0 0
set_parameter_property DEFAULT_DESTID DISPLAY_NAME {Default destination ID}
set_parameter_property DEFAULT_DESTID UNITS None
set_parameter_property DEFAULT_DESTID ALLOWED_RANGES 0:2147483647
set_parameter_property DEFAULT_DESTID DESCRIPTION {Default destination ID}
set_parameter_property DEFAULT_DESTID AFFECTS_ELABORATION true
set_parameter_property DEFAULT_DESTID HDL_PARAMETER false

add_parameter MERLIN_PACKET_FORMAT String ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME {Merlin packet format descriptor}
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION {Merlin packet format descriptor}

add_parameter MEMORY_ALIASING_DECODE INTEGER 0
set_parameter_property MEMORY_ALIASING_DECODE DISPLAY_NAME "Memory Aliasing Decode"
set_parameter_property MEMORY_ALIASING_DECODE UNITS None
set_parameter_property MEMORY_ALIASING_DECODE ALLOWED_RANGES 0:1
set_parameter_property MEMORY_ALIASING_DECODE DESCRIPTION "Controls whether upper unused memory bits are decoded"
set_parameter_property MEMORY_ALIASING_DECODE AFFECTS_ELABORATION true
set_parameter_property MEMORY_ALIASING_DECODE HDL_PARAMETER false


# | 
# +-----------------------------------

# +-----------------------------------
# | connection point sink
# | 
add_interface sink avalon_streaming end
set_interface_property sink dataBitsPerSymbol 8
set_interface_property sink errorDescriptor ""
set_interface_property sink maxChannel 0
set_interface_property sink readyLatency 0
set_interface_property sink symbolsPerBeat 1

set_interface_property sink associatedClock clk
set_interface_property sink associatedReset clk_reset

add_interface_port sink sink_ready ready Output 1
add_interface_port sink sink_valid valid Input 1
add_interface_port sink sink_data data Input 8
add_interface_port sink sink_startofpacket startofpacket Input 1
add_interface_port sink sink_endofpacket endofpacket Input 1

set_interface_assignment sink merlin.flow.src src
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
# | connection point src
# | 
add_interface src avalon_streaming start
set_interface_property src dataBitsPerSymbol 8
set_interface_property src errorDescriptor ""
set_interface_property src maxChannel 0
set_interface_property src readyLatency 0
set_interface_property src symbolsPerBeat 1

set_interface_property src associatedClock clk
set_interface_property src associatedReset clk_reset

add_interface_port src src_ready ready Input 1
add_interface_port src src_valid valid Output 1
add_interface_port src src_data data Output 8
add_interface_port src src_channel channel Output 1
add_interface_port src src_startofpacket startofpacket Output 1
add_interface_port src src_endofpacket endofpacket Output 1
# | 
# +-----------------------------------

# add quartus_synth fileset
add_fileset my_synthesis_fileset QUARTUS_SYNTH synth_callback_procedure
add_fileset my_synthesis_fileset SIM_VERILOG synth_callback_procedure
add_fileset my_synthesis_fileset SIM_VHDL synth_callback_procedure_vhdl

proc synth_callback_procedure { entity_name } {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_merlin_router.sv.terp" ]


    set template_fh [ open $template_file r ]
    set template    [ read $template_fh ]
    close $template_fh


    set params(pkt_addr_h)    [ get_parameter_value PKT_ADDR_H ]
    set params(pkt_addr_l)    [ get_parameter_value PKT_ADDR_L ]
    set params(pkt_protection_h) [ get_parameter_value PKT_PROTECTION_H ]
    set params(pkt_protection_l) [ get_parameter_value PKT_PROTECTION_L ]
    set params(pkt_dest_id_h) [ get_parameter_value PKT_DEST_ID_H ]
    set params(pkt_dest_id_l) [ get_parameter_value PKT_DEST_ID_L ]

    set params(pkt_trans_write) [ get_parameter_value PKT_TRANS_WRITE ]
    set params(pkt_trans_read) [ get_parameter_value PKT_TRANS_READ ]

    set params(st_data_w)     [ get_parameter_value ST_DATA_W ]
    set params(st_channel_w)  [ get_parameter_value ST_CHANNEL_W ]
    set params(decoder_type)  [ get_parameter_value DECODER_TYPE ]

    set params(default_channel) [ get_parameter_value DEFAULT_CHANNEL ]
    set params(default_wr_channel) [ get_parameter_value DEFAULT_WR_CHANNEL ]
    set params(default_rd_channel) [ get_parameter_value DEFAULT_RD_CHANNEL ]
    set params(default_destid)  [ get_parameter_value DEFAULT_DESTID ]
    set params(memory_aliasing_decode)  [ get_parameter_value MEMORY_ALIASING_DECODE ]


    set params(output_name) $entity_name

    set params(slaves_info) [ get_parameter_value SLAVES_INFO ]

    set result          [ altera_terp $template params ]
    set output_file     [ create_temp_file ${entity_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    add_fileset_file ${entity_name}.sv SYSTEM_VERILOG PATH ${output_file}

}     

proc synth_callback_procedure_vhdl { entity_name } {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_merlin_router.sv.terp" ]


    set template_fh [ open $template_file r ]
    set template    [ read $template_fh ]
    close $template_fh


    set params(pkt_addr_h)    [ get_parameter_value PKT_ADDR_H ]
    set params(pkt_addr_l)    [ get_parameter_value PKT_ADDR_L ]
    set params(pkt_protection_h) [ get_parameter_value PKT_PROTECTION_H ]
    set params(pkt_protection_l) [ get_parameter_value PKT_PROTECTION_L ]
    set params(pkt_dest_id_h) [ get_parameter_value PKT_DEST_ID_H ]
    set params(pkt_dest_id_l) [ get_parameter_value PKT_DEST_ID_L ]

    set params(pkt_trans_write) [ get_parameter_value PKT_TRANS_WRITE ]
    set params(pkt_trans_read) [ get_parameter_value PKT_TRANS_READ ]

    set params(st_data_w)     [ get_parameter_value ST_DATA_W ]
    set params(st_channel_w)  [ get_parameter_value ST_CHANNEL_W ]
    set params(decoder_type)  [ get_parameter_value DECODER_TYPE ]

    set params(default_channel) [ get_parameter_value DEFAULT_CHANNEL ]
    set params(default_wr_channel) [ get_parameter_value DEFAULT_WR_CHANNEL ]
    set params(default_rd_channel) [ get_parameter_value DEFAULT_RD_CHANNEL ]
    set params(default_destid)  [ get_parameter_value DEFAULT_DESTID ]
    set params(memory_aliasing_decode)  [ get_parameter_value MEMORY_ALIASING_DECODE ]

    set params(output_name) $entity_name

    set params(slaves_info) [ get_parameter_value SLAVES_INFO ]

    set result          [ altera_terp $template params ]
    set output_file     [ create_temp_file ${entity_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    set vhdl_file_without_extension [call_simgen  ${output_file} "--simgen_parameter=CBX_HDL_LANGUAGE=VHDL"]
    add_fileset_file ${entity_name}.vho VHDL PATH ${vhdl_file_without_extension}.vho
}  

proc validate {} {

    set dest_id             [ get_parameter_value DESTINATION_ID ]
    set chan_id             [ get_parameter_value CHANNEL_ID ]
    set start_add           [ get_parameter_value START_ADDRESS ]
    set end_add             [ get_parameter_value END_ADDRESS ]
	set type_transaction    [ get_parameter_value TYPE_OF_TRANSACTION]
    set non_secured_tag     [ get_parameter_value NON_SECURED_TAG ]
    set secured_range_pair  [ get_parameter_value SECURED_RANGE_PAIRS ]
    set secured_range_list  [ get_parameter_value SECURED_RANGE_LIST ]
    set span_offset          [ get_parameter_value SPAN_OFFSET ]

    set default_destid      [ get_parameter_value DEFAULT_DESTID ]
    set default_channel     [ get_parameter_value DEFAULT_CHANNEL ]
    set default_wr_channel  [ get_parameter_value DEFAULT_WR_CHANNEL ]
    set default_rd_channel  [ get_parameter_value DEFAULT_RD_CHANNEL ]
    set memory_aliasing_decode  [ get_parameter_value MEMORY_ALIASING_DECODE ]

    set dest_length             [ llength $dest_id]
    set chan_length             [ llength $chan_id]
    set start_length            [ llength $start_add]
    set end_length              [ llength $end_add]
	set type_transaction_length [ llength $type_transaction]
    set non_secured_length      [ llength $non_secured_tag ]
    set secured_range_pair_length   [ llength $secured_range_pair ]
    set secured_range_list_length   [ llength $secured_range_list ]
    set span_offset_length       [ llength $span_offset ]

# +----------------------------------------------
# | If the type_of_transaction is not set, then expect this is avalon slave
# | add "both" by default
# +----------------------------------------------
	if {! $type_transaction_length} {
	    foreach dest ${dest_id} {
	        lappend type_transaction "both"
	    }
	}

# +----------------------------------------------
# | If no secured tag is set, then assume it to be non-secured.
# | This is so that router will not do anything special with this. 
# | Which is the case for both non-secured or TZ-aware peripherals.
# +----------------------------------------------
    if {! $non_secured_length} {
        foreach dest ${dest_id} {
            lappend non_secured_tag "1"
        }
    }

# +----------------------------------------------
# | If no secured range is set, then assume it to be non-secured.
# +----------------------------------------------
if {! $secured_range_pair_length} {
    foreach dest ${dest_id} {
        lappend secured_range_pair "0"
        lappend secured_range_list ""
    }
}

# +----------------------------------------------
# | If no secured range is set, then assume it to be non-secured.
# +----------------------------------------------
if {! $span_offset_length} {
    foreach dest ${dest_id} {
        lappend span_offset "1"
    }
}


# run get length again to read new length of transaction type / security
set type_transaction_length   [ llength $type_transaction]
set non_secured_length        [ llength $non_secured_tag]
set secured_range_pair_length   [ llength $secured_range_pair ]
set span_offset_length         [ llength $span_offset ]


## Check/Validate lengths are consistent
if { $dest_length != $chan_length || $dest_length != $start_length || $dest_length != $end_length || $dest_length != $type_transaction_length || $dest_length != $non_secured_length || $dest_length != $secured_range_pair_length || $dest_length != $span_offset_length} {
    send_message {error} "Address Routing Table not fully specified .... DEST=$dest_length, CHAN=$chan_length ST=$start_length END=$end_length TYPE=$type_transaction_length SEC=$non_secured_length SEC_PAIR=$secured_range_pair_length SEC_LIST=$secured_range_list SPAN_OFFSET=$span_offset"
} else {
	
    set slave_info ""
    ## SET slave_info for TERP based on inputs from transform
	foreach dest ${dest_id} chan ${chan_id} start ${start_add} end ${end_add} tr ${type_transaction} non_secured ${non_secured_tag} sec_pair ${secured_range_pair} sec_list ${secured_range_list} offset ${span_offset} {

	    if { ! [ string equal "" $slave_info ] } {
		set slave_info "$slave_info,${dest}:${chan}:${start}:${end}:${tr}:${non_secured}:${sec_pair}:${sec_list}:${offset}"
	    } else {
		set slave_info "${dest}:${chan}:${start}:${end}:${tr}:${non_secured}:${sec_pair}:${sec_list}:${offset}"
	    }

        ## Check inconsistent security pair settings
        if { (${sec_pair} > 0) && ($non_secured==1) }  { 
            send_message {error} "Secured range pair is set for non-secured slave routing DEST_ID=$dest"
        }
        ## Checks security range list is within range
        if { (${sec_pair} > 0) }  {
         set my_sec_list [ list ]
         set my_sec_list [ split ${sec_list} - ] 
         foreach cur_sec ${my_sec_list} { 
           if { ( [expr ${start}] <= [expr $cur_sec] ) && ( [expr ${end}] >= [expr $cur_sec ]) } {
           } else { send_message {error} "Secured range is outside of slave's address range DEST_ID=$dest. Range $start-$end. User set $cur_sec" }
         }
        }

	}
	set_parameter_value SLAVES_INFO $slave_info
    }

}

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

    set st_data_width [ get_parameter_value ST_DATA_W    ]
    set st_chan_width [ get_parameter_value ST_CHANNEL_W ]
    set field_info    [ get_parameter_value MERLIN_PACKET_FORMAT   ]

    set_interface_property src  dataBitsPerSymbol $st_data_width
    set_interface_property sink dataBitsPerSymbol $st_data_width
    set_port_property src_data  WIDTH_EXPR $st_data_width
    set_port_property sink_data WIDTH_EXPR $st_data_width

    set_port_property src_channel WIDTH_EXPR $st_chan_width
    # src_channel is declared as a vector in HDL, even if width=1
    set_port_property src_channel VHDL_TYPE STD_LOGIC_VECTOR

    set_interface_assignment src merlin.packet_format $field_info
    set_interface_assignment sink merlin.packet_format $field_info
}

# TEMP PROC
proc remove0x { addr } {
    set len [ string length $addr ]
    return  [ string range $addr 2 [ expr $len - 1 ] ]
}

