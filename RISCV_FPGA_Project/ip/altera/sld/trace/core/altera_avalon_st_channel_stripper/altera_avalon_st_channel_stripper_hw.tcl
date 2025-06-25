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



#+-------------------------------------------------------
#| Altera Avalon ST channel stripper
#+-------------------------------------------------------
package require -exact sopc 11.0

#+-------------------------------------------------------
#| Module Properties
#+-------------------------------------------------------

set_module_property NAME altera_avalon_st_channel_stripper
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon ST Channel Stripper"
set_module_property ANALYZE_HDL FALSE
set_module_property INTERNAL true
set_module_property GROUP "Verification/Debug & Performance"
set_module_property ELABORATION_CALLBACK elaborate

add_parameter DATA_WIDTH integer 32
add_parameter SYMBOL_WIDTH integer 8

#+-------------------------------------------------------
#| Constant Interfaces
#+-------------------------------------------------------
add_interface clk clock end
add_interface_port clk in_clk clk Input 1

add_interface reset reset end
add_interface_port reset in_reset reset Input 1
set_interface_property reset associatedClock clk

add_interface in avalon_streaming end
add_interface_port in in_ready ready Output 1
add_interface_port in in_valid valid Input 1
add_interface_port in in_data  data  Input 8
add_interface_port in in_sop   startofpacket Input 1
add_interface_port in in_eop   endofpacket   Input 1
add_interface_port in in_channel channel Input 1

set_interface_property in associatedClock clk
set_interface_property in associatedReset reset
set_interface_property in readyLatency 0
set_interface_property in maxChannel 1

add_interface out avalon_streaming start
add_interface_port out out_ready ready Input 1
add_interface_port out out_valid valid Output 1
add_interface_port out out_data  data  Output 8
add_interface_port out out_sop   startofpacket Output 1
add_interface_port out out_eop   endofpacket   Output 1

set_interface_property out associatedClock clk
set_interface_property out associatedReset reset
set_interface_property out readyLatency 0

#+-------------------------------------------------------
#| Declare this component to be just wires
#+-------------------------------------------------------
set_port_property in_ready  DRIVEN_BY out_ready
set_port_property out_valid DRIVEN_BY in_valid
set_port_property out_data  DRIVEN_BY in_data
set_port_property out_sop   DRIVEN_BY in_sop
set_port_property out_eop   DRIVEN_BY in_eop

proc elaborate {} {
	set data_width [get_parameter_value DATA_WIDTH]
	set symbol_width [get_parameter_value SYMBOL_WIDTH]
	
	set_interface_property in dataBitsPerSymbol $symbol_width
	set_interface_property out dataBitsPerSymbol $symbol_width
	
	set_port_property in_data width $data_width
	set_port_property out_data width $data_width

	set empty_width [log2ceil [expr $data_width / $symbol_width]]
	
	add_interface_port in in_empty empty Input $empty_width
	add_interface_port out out_empty empty Output $empty_width
	set_port_property out_empty DRIVEN_BY in_empty
}

proc log2ceil {num} {
    #make log(0), log(1) = 1
    set val 1
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }
    return $val;
}

