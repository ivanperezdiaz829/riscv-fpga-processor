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


# $Id: //acds/rel/13.1/ip/merlin/altera_merlin_std_arbitrator/altera_merlin_std_arbitrator_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# +-----------------------------------
# | 
# | altera_merlin_std_arbitrator "altera_merlin_std_arbitrator" v1.0
# | null 2009.04.23.15:04:54
# | 
# | 
# |    ./altera_merlin_std_arbitrator.sv syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
package require -exact altera_terp 1.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_merlin_std_arbitrator
# | 
set_module_property NAME altera_merlin_std_arbitrator
set_module_property VERSION 13.1
set_module_property GROUP "Merlin Components"
set_module_property DISPLAY_NAME "Memory Mapped Arbiter"
set_module_property DESCRIPTION "Arbitrates between requesting masters using an equal share, round-robin algorithm. The arbitration scheme can be changed to weighted round-robin by specifying a relative number of arbitration shares to the masters that access a particular slave."
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property PREVIEW_GENERATE_VERILOG_SIMULATION_CALLBACK generate
set_module_property GENERATION_CALLBACK generate
set_module_property HIDE_FROM_SOPC true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_merlin_std_arbitrator_core.sv {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter NUM_REQUESTERS INTEGER 8
set_parameter_property NUM_REQUESTERS DISPLAY_NAME {Number of requesters}
set_parameter_property NUM_REQUESTERS UNITS None
set_parameter_property NUM_REQUESTERS DISPLAY_HINT ""
set_parameter_property NUM_REQUESTERS AFFECTS_GENERATION true
set_parameter_property NUM_REQUESTERS HDL_PARAMETER false
set_parameter_property NUM_REQUESTERS DESCRIPTION {Number of requesters}
add_parameter SCHEME String "round-robin"
set_parameter_property SCHEME DESCRIPTION {Arbitration scheme}
set_parameter_property SCHEME DISPLAY_NAME {Arbitration scheme}
set_parameter_property SCHEME UNITS None
set_parameter_property SCHEME DISPLAY_HINT ""
set_parameter_property SCHEME AFFECTS_GENERATION true
set_parameter_property SCHEME HDL_PARAMETER false
set_parameter_property SCHEME ALLOWED_RANGES {round-robin fixed-priority no-arb} 
add_parameter ST_DATA_W INTEGER 8
set_parameter_property ST_DATA_W DISPLAY_NAME {Packet data width}
set_parameter_property ST_DATA_W UNITS None
set_parameter_property ST_DATA_W DISPLAY_HINT ""
set_parameter_property ST_DATA_W AFFECTS_GENERATION true
set_parameter_property ST_DATA_W HDL_PARAMETER false
set_parameter_property ST_DATA_W DESCRIPTION {Packet data width}
add_parameter ST_CHANNEL_W INTEGER 1
set_parameter_property ST_CHANNEL_W DISPLAY_NAME {Streaming channel width}
set_parameter_property ST_CHANNEL_W UNITS None
set_parameter_property ST_CHANNEL_W DISPLAY_HINT ""
set_parameter_property ST_CHANNEL_W AFFECTS_GENERATION true
set_parameter_property ST_CHANNEL_W HDL_PARAMETER false
set_parameter_property ST_CHANNEL_W DESCRIPTION {Streaming channel width}
add_parameter USE_PACKETS INTEGER 1
set_parameter_property USE_PACKETS DISPLAY_NAME {Use packets}
set_parameter_property USE_PACKETS UNITS None
set_parameter_property USE_PACKETS DISPLAY_HINT ""
set_parameter_property USE_PACKETS AFFECTS_ELABORATION true
set_parameter_property USE_PACKETS HDL_PARAMETER false
set_parameter_property USE_PACKETS DESCRIPTION {Use Avalon-ST packet signals (startofpacket, endofpacket)}
add_parameter USE_CHANNEL INTEGER 1
set_parameter_property USE_CHANNEL DISPLAY_NAME {Use channel}
set_parameter_property USE_CHANNEL UNITS None
set_parameter_property USE_CHANNEL DISPLAY_HINT ""
set_parameter_property USE_CHANNEL AFFECTS_ELABORATION true
set_parameter_property USE_CHANNEL HDL_PARAMETER false
set_parameter_property USE_CHANNEL DESCRIPTION {Use Avalon-ST channel signal}
add_parameter USE_DATA INTEGER 1
set_parameter_property USE_DATA DISPLAY_NAME {Use data}
set_parameter_property USE_DATA UNITS None
set_parameter_property USE_DATA DISPLAY_HINT ""
set_parameter_property USE_DATA AFFECTS_ELABORATION true
set_parameter_property USE_DATA HDL_PARAMETER false
set_parameter_property USE_DATA DESCRIPTION {Use Avalon-ST data signal}
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clk clock end

set_interface_property clk ENABLED true

add_interface_port clk clk clk Input 1
add_interface_port clk reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point grant
# | 
add_interface grant avalon_streaming start
set_interface_property grant dataBitsPerSymbol 8
set_interface_property grant errorDescriptor ""
set_interface_property grant maxChannel 0
set_interface_property grant readyLatency 0
set_interface_property grant symbolsPerBeat 1

set_interface_property grant ASSOCIATED_CLOCK clk
set_interface_property grant ENABLED true

add_interface_port grant ack ready Input 1
add_interface_port grant next_grant data Output -1
set_port_property next_grant VHDL_TYPE STD_LOGIC_VECTOR
# | 
# +-----------------------------------

proc elaborate {} {

    set num_requests  [ get_parameter_value NUM_REQUESTERS ]
    set st_data_width [ get_parameter_value ST_DATA_W ]
    set st_chan_width [ get_parameter_value ST_CHANNEL_W ]

    # +-----------------------------------
    # | sinks
    # |
    for { set i 0 } { $i < $num_requests } { incr i } {

        add_interface sink${i} avalon_streaming end
        set_interface_property sink${i} dataBitsPerSymbol $st_data_width
        set_interface_property sink${i} errorDescriptor ""
        set_interface_property sink${i} maxChannel 0
        set_interface_property sink${i} readyLatency 0
        set_interface_property sink${i} symbolsPerBeat 1

        set_interface_property sink${i} ASSOCIATED_CLOCK clk

        add_interface_port sink${i} sink${i}_valid valid Input 1
        
	if { [get_parameter_value USE_PACKETS] != 0 } {
	    add_interface_port sink${i} sink${i}_startofpacket startofpacket Input 1
        add_interface_port sink${i} sink${i}_endofpacket endofpacket Input 1
	}
	
	if { [get_parameter_value USE_DATA] != 0 } {
	    add_interface_port sink${i} sink${i}_data data Input $st_data_width
            set_port_property sink${i}_data VHDL_TYPE STD_LOGIC_VECTOR
	}
	
	if { [get_parameter_value USE_CHANNEL] != 0 } {
	    add_interface_port sink${i} sink${i}_channel channel Input $st_chan_width
            set_port_property sink${i}_channel VHDL_TYPE STD_LOGIC_VECTOR
	}

    }
    # |
    # +-----------------------------------

    set_interface_property grant dataBitsPerSymbol $num_requests
    set_port_property next_grant WIDTH $num_requests

}

# +-----------------------------------
# | Generation callback
# +-----------------------------------
proc generate {} {

    set this_dir      [ get_module_property MODULE_DIRECTORY ]
    set template_file [ file join $this_dir "altera_merlin_std_arbitrator.sv.terp" ]


    set output_dir  [ get_generation_property OUTPUT_DIRECTORY ]
    set output_name [ get_generation_property OUTPUT_NAME ]
    set template    [ read [ open $template_file r ] ]

    set params(output_name) $output_name
    set params(num_requesters)  [ get_parameter_value NUM_REQUESTERS ]
    set arb_scheme [ get_parameter_value SCHEME ]
    set params(scheme)  "\"$arb_scheme\""
    set params(st_data_w) [ get_parameter_value ST_DATA_W ]
    set params(st_channel_w) [ get_parameter_value ST_CHANNEL_W ]
	set params(use_packets) [ get_parameter_value USE_PACKETS ]
	set params(use_data) [ get_parameter_value USE_DATA ]
	set params(use_channel) [ get_parameter_value USE_CHANNEL ]
    set result          [ altera_terp $template params ]
    set output_file     [ file join $output_dir ${output_name}.sv ]
    set output_handle   [ open $output_file w ]

    puts $output_handle $result
    close $output_handle

    add_file ${output_file} {SYNTHESIS SIMULATION}
}

