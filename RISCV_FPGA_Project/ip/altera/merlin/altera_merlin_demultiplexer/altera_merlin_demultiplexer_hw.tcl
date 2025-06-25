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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_demultiplexer/altera_merlin_demultiplexer_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_demultiplexer "Merlin Demultiplexer" v1.0
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact altera_terp 1.0

# +-----------------------------------
# | module altera_merlin_demultiplexer
# | 
set_module_property NAME altera_merlin_demultiplexer
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Memory Mapped Demultiplexer"
set_module_property DESCRIPTION "Accepts channelized data on its sink interface and transmits the data on one of its source interfaces."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property GENERATION_CALLBACK generate
set_module_property _PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property HIDE_FROM_SOPC true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE
set_module_property VALIDATION_CALLBACK validate
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter ST_DATA_W INTEGER 8 0
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
set_parameter_property NUM_OUTPUTS DISPLAY_NAME {Number of demux outputs}
set_parameter_property NUM_OUTPUTS UNITS None
set_parameter_property NUM_OUTPUTS DESCRIPTION {Number of demux outputs}
set_parameter_property NUM_OUTPUTS AFFECTS_ELABORATION true

add_parameter VALID_WIDTH INTEGER 1 0
set_parameter_property VALID_WIDTH DISPLAY_NAME {Valid width}
set_parameter_property VALID_WIDTH HDL_PARAMETER false
set_parameter_property VALID_WIDTH AFFECTS_ELABORATION true
set_parameter_property VALID_WIDTH DESCRIPTION {Width of the valid signal}

add_parameter MERLIN_PACKET_FORMAT STRING ""
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
# | connection point clk_reset
# | 
add_interface clk_reset reset end
add_interface_port clk_reset reset reset Input 1
set_interface_property clk_reset associatedClock clk
# | 
# +-----------------------------------


# +-----------------------------------
# | Validation callback
# +-----------------------------------
proc validate {} {
  set st_channel_width [ get_parameter_value ST_CHANNEL_W ]
  set num_outputs [ get_parameter_value NUM_OUTPUTS ]

  # We need to prevent the case where there is more outputs than channel width
  # this is because the number of sink_channel that is initialised is dependent on ST_CHANNEL_W
  # but the number of sink channels being assign is dependent on NUM_OUTPUTS.
  
  if {$st_channel_width < $num_outputs } {
    send_message error "ST_CHANNEL_W < NUM_OUTPUTS"
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
    set num_outputs   [ get_parameter_value NUM_OUTPUTS ]
    set packet_format [ get_parameter_value MERLIN_PACKET_FORMAT ]
    set validw        [ get_parameter_value VALID_WIDTH ]

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
    set_interface_property sink dataBitsPerSymbol $st_data_width
    set_interface_assignment sink merlin.packet_format $packet_format

    add_interface_port sink sink_ready ready Output 1
    add_interface_port sink sink_valid valid Input $validw
    add_interface_port sink sink_channel channel Input $st_chan_width
    add_interface_port sink sink_data data Input $st_data_width
    add_interface_port sink sink_startofpacket startofpacket Input 1
    add_interface_port sink sink_endofpacket endofpacket Input 1

    set_merlin_flow_assignments_for_sink

    if { $validw == 1 } {

        add_interface_port sink sink_valid valid Input 1

    } else {

        add_interface sink_valid avalon_streaming end
        set_interface_property sink_valid dataBitsPerSymbol $validw
        set_interface_property sink_valid associatedClock clk
        set_interface_property sink_valid associatedReset clk_reset

        add_interface_port sink_valid sink_valid data Input $validw

    }

    set_port_property sink_valid VHDL_TYPE STD_LOGIC_VECTOR
    set_port_property sink_channel VHDL_TYPE STD_LOGIC_VECTOR

    # | 
    # +-----------------------------------

    # +-----------------------------------
    # | sources
    # |
    for { set i 0 } { $i < $num_outputs } { incr i } {
        add_interface src${i} avalon_streaming start
        set_interface_property src${i} dataBitsPerSymbol $st_data_width
        set_interface_property src${i} errorDescriptor ""
        set_interface_property src${i} maxChannel 0
        set_interface_property src${i} readyLatency 0
        set_interface_property src${i} symbolsPerBeat 1
        
        set_interface_property src${i} ASSOCIATED_CLOCK clk
        
        add_interface_port src${i} src${i}_ready ready Input 1
        add_interface_port src${i} src${i}_valid valid Output 1
        add_interface_port src${i} src${i}_data data Output $st_data_width
        add_interface_port src${i} src${i}_channel channel Output $st_chan_width
        add_interface_port src${i} src${i}_startofpacket startofpacket Output 1
        add_interface_port src${i} src${i}_endofpacket endofpacket Output 1

        set_interface_assignment src${i} merlin.packet_format $packet_format

        set_port_property src${i}_channel VHDL_TYPE STD_LOGIC_VECTOR
    }
    # |
    # +-----------------------------------
}

proc get_channel_for_output { index } {

    set channel   [ string repeat "0" [ get_parameter_value NUM_OUTPUTS ] ]
    set bit_index [ expr [ get_parameter_value NUM_OUTPUTS ] - $index - 1 ]
    set channel   [ string replace $channel $bit_index $bit_index "1" ]

    return $channel
}

proc set_merlin_flow_assignments_for_sink { } {

    set num_outputs   [ get_parameter_value NUM_OUTPUTS ]
    for { set i 0 } { $i < $num_outputs } { incr i } { 

        set_interface_assignment sink merlin.flow.src${i} src${i}
        set_interface_assignment sink merlin.channel.src${i} [ get_channel_for_output $i ]

    }

}

# +-----------------------------------
# | Generation callback
# +-----------------------------------
proc generate {} {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_merlin_demultiplexer.sv.terp" ]


    set output_dir  [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name [ get_generation_property OUTPUT_NAME ]
    set template    [ read [ open $template_file r ] ]

    set params(output_name) $output_name
    set params(NUM_OUTPUTS) [ get_parameter_value NUM_OUTPUTS ]
    set params(st_data_w) [ get_parameter_value ST_DATA_W ]
    set params(st_channel_w) [ get_parameter_value ST_CHANNEL_W ]
    set params(valid_w) [ get_parameter_value VALID_WIDTH ]

    set result          [ altera_terp $template params ]
    set output_file     [ file join $output_dir ${output_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    add_file ${output_file} {SYNTHESIS SIMULATION}
}
