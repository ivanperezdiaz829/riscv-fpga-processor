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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_multiplexer/altera_merlin_multiplexer_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_multiplexer "Merlin Multiplexer" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact sopc 11.0
package require -exact altera_terp 1.0

# +-----------------------------------
# | module altera_merlin_multiplexer
# | 
set_module_property NAME altera_merlin_multiplexer
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Memory Mapped Multiplexer"
set_module_property DESCRIPTION "Arbitrates between requesting masters using an equal share, round-robin algorithm. The arbitration scheme can be changed to weighted round-robin by specifying a relative number of arbitration shares to the masters that access a particular slave."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property GENERATION_CALLBACK generate
set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property VALIDATION_CALLBACK validate
set_module_property HIDE_FROM_SOPC true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

add_file altera_merlin_arbitrator.sv {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter ST_DATA_W INTEGER 71 0
set_parameter_property ST_DATA_W DISPLAY_NAME {Streaming data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_DATA_W DESCRIPTION {StreamingPacket data width}
set_parameter_property ST_DATA_W AFFECTS_ELABORATION true
set_parameter_property ST_DATA_W HDL_PARAMETER false
add_parameter ST_CHANNEL_W INTEGER 32 0
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W ALLOWED_RANGES 0:2147483647
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
set_parameter_property ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER false
add_parameter NUM_INPUTS INTEGER 2 0
set_parameter_property NUM_INPUTS DISPLAY_NAME {Number of mux inputs}
set_parameter_property NUM_INPUTS UNITS None
set_parameter_property NUM_INPUTS DESCRIPTION {Number of mux inputs}
set_parameter_property NUM_INPUTS AFFECTS_ELABORATION true
set_parameter_property NUM_INPUTS HDL_PARAMETER false
add_parameter PIPELINE_ARB INTEGER 0 0
set_parameter_property PIPELINE_ARB DISPLAY_NAME {Pipelined arbitration}
set_parameter_property PIPELINE_ARB UNITS None
set_parameter_property PIPELINE_ARB ALLOWED_RANGES 0:1
set_parameter_property PIPELINE_ARB DESCRIPTION {When enabled, the output of the arbiter is registered, reducing the amount of combinational logic between the master and fabric, increasing the frequency of the system}
set_parameter_property PIPELINE_ARB AFFECTS_ELABORATION true
set_parameter_property PIPELINE_ARB HDL_PARAMETER false
set_parameter_property PIPELINE_ARB DISPLAY_HINT boolean
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

add_display_item "" "Arbitration Shares" "group" "table"
add_parameter ARBITRATION_SHARES INTEGER_LIST 1
set_parameter_property ARBITRATION_SHARES DISPLAY_NAME {Arbitration shares}
set_parameter_property ARBITRATION_SHARES AFFECTS_ELABORATION false
set_parameter_property ARBITRATION_SHARES HDL_PARAMETER false
set_parameter_property ARBITRATION_SHARES GROUP "Arbitration Shares"
set_parameter_property ARBITRATION_SHARES DESCRIPTION {Lists the number of arbitration shares assigned to each master. By default, each master has equal shares}

add_parameter MERLIN_PACKET_FORMAT String ""
set_parameter_property MERLIN_PACKET_FORMAT DISPLAY_NAME {Merlin packet format descriptor}
set_parameter_property MERLIN_PACKET_FORMAT UNITS None
set_parameter_property MERLIN_PACKET_FORMAT AFFECTS_ELABORATION true
set_parameter_property MERLIN_PACKET_FORMAT HDL_PARAMETER false
set_parameter_property MERLIN_PACKET_FORMAT DESCRIPTION {Merlin packet format descriptor}

# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
add_interface_port clk clk clk Input 1
# +-----------------------------------
# | connection point clk
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

# +-----------------------------------
# | Validation callback
# +-----------------------------------
proc validate {} {
  set arb_shares [ get_parameter_value ARBITRATION_SHARES ]
  set max_share [ list_max $arb_shares ]
  set pipe [ get_parameter_value PIPELINE_ARB ]

  # Don't allow more shares to be specified than there are inputs.  The
  # converse, more inputs than shares, is ok, unspecified share values default
  # to 1.
  set num_inputs [ get_parameter_value NUM_INPUTS ]
  if {[ llength $arb_shares ] > $num_inputs } {
    send_message error "length(arbitration shares) > NUM_INPUTS" 
  }
}
# | 
# +-----------------------------------

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

    set st_data_width [ get_parameter_value ST_DATA_W ]
    set st_chan_width [ get_parameter_value ST_CHANNEL_W ]
    set num_inputs    [ get_parameter_value NUM_INPUTS ]
    set packet_format [ get_parameter_value MERLIN_PACKET_FORMAT ]

    set_interface_property src dataBitsPerSymbol $st_data_width
    set_port_property src_data     WIDTH $st_data_width
    set_port_property src_channel  WIDTH $st_chan_width
    set_port_property src_channel  vhdl_type std_logic_vector

    # +-----------------------------------
    # | sinks
    # |
    for { set i 0 } { $i < $num_inputs } { incr i } {

        add_interface sink${i} avalon_streaming end
        set_interface_property sink${i} dataBitsPerSymbol $st_data_width
        set_interface_property sink${i} errorDescriptor ""
        set_interface_property sink${i} maxChannel 0
        set_interface_property sink${i} readyLatency 0
        set_interface_property sink${i} symbolsPerBeat 1
        
        set_interface_property sink${i} associatedClock clk
        set_interface_property sink${i} associatedReset clk_reset
        
        add_interface_port sink${i} sink${i}_ready ready Output 1
        add_interface_port sink${i} sink${i}_valid valid Input 1
        add_interface_port sink${i} sink${i}_channel channel Input $st_chan_width
        add_interface_port sink${i} sink${i}_data data Input $st_data_width
        add_interface_port sink${i} sink${i}_startofpacket startofpacket Input 1
        add_interface_port sink${i} sink${i}_endofpacket endofpacket Input 1

        set_interface_assignment sink${i} merlin.packet_format $packet_format
        set_interface_assignment sink${i} merlin.flow.src src

        set_port_property sink${i}_channel vhdl_type std_logic_vector
    }
    # |
    # +-----------------------------------
    set_interface_assignment src merlin.packet_format $packet_format

    # +-----------------------------------
    # | Single input mux optimization (for neatness and fmax)
    # +-----------------------------------
    #if { $num_inputs == 1 } {
    #    set_port_property sink0_ready       driven_by src_ready        
    #    set_port_property src_valid         driven_by sink0_valid        
    #    set_port_property src_data          driven_by sink0_data         
    #    set_port_property src_channel       driven_by sink0_channel       
    #    set_port_property src_startofpacket driven_by sink0_startofpacket
    #    set_port_property src_endofpacket   driven_by sink0_endofpacket  
    #}

}

# Utility functions - consider making common.
proc log2floor { num } {
  set log 0
  while {$num > 1} {
    set num [ expr $num >> 1 ]
    incr log
  }
  return $log
}

# Return the max value in a list of integer values.
proc list_max { values } {
  set max [ lindex $values 0 ]
  foreach value $values {
    if {$value > $max} {
      set max $value
    }
  }

  return $max
}

# +-----------------------------------
# | get_share_counter_width
# |
# | Input: comma-separated list of arbitration share values
# | Output: the width of the counter required to contain values in
# |   the list.
# |   (The counter needs to contain at most max - 2, where max is the
# |    largest share value.  The counter's minimum width is 1.)
# +-----------------------------------

proc get_share_counter_width { arbitration_shares } {

    set max [ list_max $arbitration_shares ]

    # The counter actually holds share-minus-2 values (if PIPELINE_ARB=0),
    # or share-minus-1 values (if PIPELINE_ARB=1). PIPELINE_ARB is an HDL 
    # parameter, so just make the counter large enough for either case.
    set max [ expr $max - 1]

    if { $max > 1 } {
      set share_counter_width [expr 1 + [ log2floor $max ]]
    } else {
      set share_counter_width 1
    }

    return $share_counter_width
}

# +-----------------------------------
# | Generation callback
# +-----------------------------------
proc generate {} {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_merlin_multiplexer.sv.terp" ]


    set output_dir  [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name [ get_generation_property OUTPUT_NAME ]
    set template    [ read [ open $template_file r ] ]

    set params(output_name) $output_name
    set num_inputs [ get_parameter_value NUM_INPUTS ]
    set params(num_inputs) $num_inputs
    set shares [ get_parameter_value ARBITRATION_SHARES ]
    set params(arbitration_shares) $shares
    set scheme [ get_parameter_value ARBITRATION_SCHEME ]
    set params(arbitration_scheme) \"$scheme\"
    set params(share_counter_width) [ get_share_counter_width $shares ]
    set pipeline_arb [ get_parameter_value PIPELINE_ARB ]
    set params(pipeline_arb) $pipeline_arb
    set params(st_data_w) [ get_parameter_value ST_DATA_W ]
    set params(st_channel_w) [ get_parameter_value ST_CHANNEL_W ]
    set params(use_external_arb) [ get_parameter_value USE_EXTERNAL_ARB ]
    set params(pkt_trans_lock) [ get_parameter_value PKT_TRANS_LOCK ]

    set result          [ altera_terp $template params ]
    set output_file     [ file join $output_dir ${output_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    add_file ${output_file} {SYNTHESIS SIMULATION}
}

