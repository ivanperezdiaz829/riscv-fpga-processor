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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_mins_network_generator/altera_merlin_st_pass_through_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | Pass Through Component
# | 2008.10.15.13:20:06
# | 
# | 
# +-----------------------------------

package require -exact sopc 11.0
package require -exact altera_terp 1.0

# +-----------------------------------
# | module altera_merlin_multiplexer
# | 
set_module_property NAME altera_merlin_st_pass_through
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Pass Through"
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property HIDE_FROM_SOPC true
set_module_property ANALYZE_HDL FALSE
set_module_property INTERNAL true

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
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {

    set st_data_width [ get_parameter_value ST_DATA_W ]
    set st_chan_width [ get_parameter_value ST_CHANNEL_W ]

    set_interface_property src dataBitsPerSymbol $st_data_width
    set_port_property src_data     WIDTH $st_data_width
    set_port_property src_channel  WIDTH $st_chan_width

    # +-----------------------------------
    # | sinks
    # |

    add_interface sink avalon_streaming end
    set_interface_property sink dataBitsPerSymbol $st_data_width
    set_interface_property sink errorDescriptor ""
    set_interface_property sink maxChannel 0
    set_interface_property sink readyLatency 0
    set_interface_property sink symbolsPerBeat 1
    
    set_interface_property sink associatedClock clk
    set_interface_property sink associatedReset clk_reset
    
    add_interface_port sink sink_ready ready Output 1
    add_interface_port sink sink_valid valid Input 1
    add_interface_port sink sink_channel channel Input $st_chan_width
    add_interface_port sink sink_data data Input $st_data_width
    add_interface_port sink sink_startofpacket startofpacket Input 1
    add_interface_port sink sink_endofpacket endofpacket Input 1
    # |
    # +-----------------------------------

    # +-----------------------------------
    # | Pass through
    # +-----------------------------------
    set_port_property sink_ready        driven_by src_ready        
    set_port_property src_valid         driven_by sink_valid        
    set_port_property src_data          driven_by sink_data         
    set_port_property src_channel       driven_by sink_channel       
    set_port_property src_startofpacket driven_by sink_startofpacket
    set_port_property src_endofpacket   driven_by sink_endofpacket  

}

