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
#| Altera Avalon ST null sink
#+-------------------------------------------------------
package require -exact sopc 11.0

#+-------------------------------------------------------
#| Module Properties
#+-------------------------------------------------------

set_module_property NAME altera_avalon_st_null_sink
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon ST Sink"
set_module_property ANALYZE_HDL FALSE
set_module_property INTERNAL true
set_module_property GROUP "Verification/Debug & Performance"
set_module_property ELABORATION_CALLBACK elaborate

#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------
add_parameter          inBitsPerSymbol INTEGER           8
set_parameter_property inBitsPerSymbol DISPLAY_NAME      "Bits Per Symbol"
set_parameter_property inBitsPerSymbol DESCRIPTION       "Bits Per Symbol"
set_parameter_property inBitsPerSymbol UNITS             bits
set_parameter_property inBitsPerSymbol ALLOWED_RANGES    {1:128}
set_parameter_property inBitsPerSymbol GROUP             "Port Widths"


add_parameter          inSymbolsPerBeat INTEGER           1
set_parameter_property inSymbolsPerBeat DISPLAY_NAME      "Symbols Per Beat"
set_parameter_property inSymbolsPerBeat DESCRIPTION       "Number of symbols transferred in 1 cycle. Data bus width is inBitsPerSymbol * inSymbolsPerBeat."
set_parameter_property inSymbolsPerBeat ALLOWED_RANGES    {1:8}
set_parameter_property inSymbolsPerBeat GROUP             "Port Widths"

add_parameter          inUsePackets    BOOLEAN            true
set_parameter_property inUsePackets    DISPLAY_NAME       "Include SOP, EOP sinks"
set_parameter_property inUsePackets    DESCRIPTION        "Set true to include startofpacket and endofpacket signals"
set_parameter_property inUsePackets    GROUP              "Signal Sinks"

add_parameter          inReadyLatency   INTEGER           0
set_parameter_property inReadyLatency   DISPLAY_NAME      "Ready latency"
set_parameter_property inReadyLatency   ALLOWED_RANGES    {0:4}
set_parameter_property inReadyLatency   GROUP             "Port Widths"

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
add_interface_port in in_data  data  Input inSymbolsPerBeat*inBitsPerSymbol

set_interface_property in associatedClock clk
set_interface_property in associatedReset reset

#+-------------------------------------------------------
#| Declare this component to be constant -
#| in_ready is the only output, so no rtl needed
#+-------------------------------------------------------
set_port_property in_ready DRIVEN_BY "1"

proc elaborate {} {
    if { [ get_parameter_value inUsePackets ] == "true" } {
        add_interface_port in in_sop   startofpacket Input 1
        add_interface_port in in_eop   endofpacket   Input 1
    }

    set_interface_property in dataBitsPerSymbol [get_parameter_value inBitsPerSymbol]
    set_interface_property in symbolsPerBeat    [get_parameter_value inSymbolsPerBeat]
    set_interface_property in readyLatency      [get_parameter_value inReadyLatency]
}

