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


# $Id: //acds/rel/13.1/ip/sld/st/altera_mm_debug_link_datawidth_matcher/altera_mm_debug_link_datawidth_matcher_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $

# 
# request TCL package from ACDS 12.0
# 
package require -exact qsys 12.0


# 
# module altera_mm_debug_link_datawidth_matcher
# 
set_module_property NAME altera_mm_debug_link_datawidth_matcher
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_mm_debug_link_datawidth_matcher
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_mm_debug_link_datawidth_matcher
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_mm_debug_link_datawidth_matcher.sv SYSTEM_VERILOG PATH altera_mm_debug_link_datawidth_matcher.sv

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL altera_mm_debug_link_datawidth_matcher
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_mm_debug_link_datawidth_matcher.sv SYSTEM_VERILOG PATH altera_mm_debug_link_datawidth_matcher.sv

# 
# parameters
# 
add_parameter SINK_DATAWIDTH INTEGER 8
set_parameter_property SINK_DATAWIDTH DEFAULT_VALUE 8
set_parameter_property SINK_DATAWIDTH DISPLAY_NAME SINK_DATAWIDTH
set_parameter_property SINK_DATAWIDTH TYPE INTEGER
set_parameter_property SINK_DATAWIDTH UNITS None
set_parameter_property SINK_DATAWIDTH ALLOWED_RANGES {8 32}
set_parameter_property SINK_DATAWIDTH HDL_PARAMETER true
set_parameter_property SINK_DATAWIDTH AFFECTS_ELABORATION true
add_parameter SOURCE_DATAWIDTH INTEGER 32
set_parameter_property SOURCE_DATAWIDTH DEFAULT_VALUE 32
set_parameter_property SOURCE_DATAWIDTH DISPLAY_NAME SOURCE_DATAWIDTH
set_parameter_property SOURCE_DATAWIDTH TYPE INTEGER
set_parameter_property SOURCE_DATAWIDTH UNITS None
set_parameter_property SOURCE_DATAWIDTH ALLOWED_RANGES {8 32}
set_parameter_property SOURCE_DATAWIDTH HDL_PARAMETER true
set_parameter_property SOURCE_DATAWIDTH AFFECTS_ELABORATION true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true

add_interface_port reset reset reset Input 1


# 
# connection point source
# 
add_interface source avalon_streaming start
set_interface_property source associatedClock clock
set_interface_property source associatedReset reset
set_interface_property source dataBitsPerSymbol 8
set_interface_property source errorDescriptor ""
set_interface_property source firstSymbolInHighOrderBits true
set_interface_property source maxChannel 0
set_interface_property source readyLatency 0
set_interface_property source ENABLED true

add_interface_port source source_data data Output SOURCE_DATAWIDTH
add_interface_port source source_valid valid Output 1
add_interface_port source source_ready ready Input 1


# 
# connection point sink
# 
add_interface sink avalon_streaming end
set_interface_property sink associatedClock clock
set_interface_property sink associatedReset reset
set_interface_property sink dataBitsPerSymbol 8
set_interface_property sink errorDescriptor ""
set_interface_property sink firstSymbolInHighOrderBits true
set_interface_property sink maxChannel 0
set_interface_property sink readyLatency 0
set_interface_property sink ENABLED true

add_interface_port sink sink_data data Input SINK_DATAWIDTH
add_interface_port sink sink_valid valid Input 1
add_interface_port sink sink_ready ready Output 1

