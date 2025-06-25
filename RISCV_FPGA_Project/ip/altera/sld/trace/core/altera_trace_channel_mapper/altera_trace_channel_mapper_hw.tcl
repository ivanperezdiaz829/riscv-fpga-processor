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


# $Id: //acds/rel/13.1/ip/sld/trace/core/altera_trace_channel_mapper/altera_trace_channel_mapper_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

package require -exact qsys 13.1
package require altera_terp 1.0

#  -----------------------------------
# | altera_trace_channel_remap
#  -----------------------------------
set_module_property name altera_trace_channel_mapper
set_module_property version 13.1
set_module_property GROUP "Verification/Debug & Performance"
set_module_property display_name "Trace channel mapper"
set_module_property editable false
set_module_property internal true
set_module_property elaboration_callback elaborate

add_fileset synth quartus_synth generate "Quartus Synthesis"

#  -----------------------------------
# | parameters
#  -----------------------------------
add_parameter DATA_WIDTH  integer 8 "Data width"
add_parameter EMPTY_WIDTH integer 2 "Empty signal width"
add_parameter IN_CHANNEL  integer 8 "Input channel width"
add_parameter OUT_CHANNEL integer 8 "Output channel width"

add_parameter MAPPING string ""  "Mapping of input to output channel numbers"

#  -----------------------------------
# | interfaces
#  -----------------------------------

# Clock interface
add_interface clk clock end
add_interface_port clk clk clk Input 1

add_interface reset reset end
set_interface_property reset associatedClock clk
add_interface_port reset reset reset Input 1

# Downstream interface
add_interface in avalon_streaming end

set_interface_property in associatedClock clk
set_interface_property in associatedReset reset
set_interface_property in readyLatency 0

add_interface_port in in_ready ready Output 1
add_interface_port in in_valid valid Input 1
add_interface_port in in_data data Input DATA_WIDTH
add_interface_port in in_startofpacket startofpacket Input 1
add_interface_port in in_endofpacket endofpacket Input 1
add_interface_port in in_empty empty Input 1
set_port_property in_empty termination true
add_interface_port in in_channel channel Input IN_CHANNEL

# Upstream interface
add_interface out avalon_streaming start

set_interface_property out associatedClock clk
set_interface_property out associatedReset reset
set_interface_property out readyLatency 0

add_interface_port out out_ready ready Input 1
add_interface_port out out_valid valid Output 1
add_interface_port out out_data data Output DATA_WIDTH
add_interface_port out out_startofpacket startofpacket Output 1
add_interface_port out out_endofpacket endofpacket Output 1
add_interface_port out out_empty empty Output 1
set_port_property out_empty termination true
add_interface_port out out_channel channel Output OUT_CHANNEL

#  -----------------------------------
# | Elaboration callback
#  -----------------------------------
proc elaborate {} {
    set empty_width [get_parameter_value EMPTY_WIDTH]

	if {$empty_width > 0} {
		set_port_property in_empty width_expr $empty_width
		set_port_property in_empty termination false
		set_port_property out_empty width_expr $empty_width
		set_port_property out_empty termination false
	}
        set_interface_property in maxChannel [ expr {-1 + 2**[ get_parameter_value IN_CHANNEL ]} ]
        set_interface_property out maxChannel [ expr {-1 + 2**[ get_parameter_value OUT_CHANNEL ]} ]
}

#  -----------------------------------
# | Generation callback
#  -----------------------------------
proc generate output_name {
    set this_dir      [get_module_property MODULE_DIRECTORY]
    set template_file [file join $this_dir "altera_trace_channel_mapper.sv.terp"]

    set template    [read [open $template_file r] ]

    # Collect parameter values for Terp
    set params(output_name) $output_name
    set params(data_width)  [get_parameter_value DATA_WIDTH]
    set empty_width [get_parameter_value EMPTY_WIDTH]
    if {$empty_width < 1} {
    	set empty_width 1
    }
    set params(empty_width) $empty_width
    set params(in_channel)  [get_parameter_value IN_CHANNEL]
    set params(out_channel) [get_parameter_value OUT_CHANNEL]
    set params(mapping)     [get_parameter_value MAPPING]
	
	set result [altera_terp $template params]

    add_fileset_file ${output_name}.sv system_verilog text $result top_level_file
}
