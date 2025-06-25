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

# 
# altera_trace_monitor_endpoint "altera_trace_monitor_endpoint" v1.0
# 

# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0

# 
# module altera_trace_monitor_endpoint
# 
set_module_property NAME altera_trace_monitor_endpoint
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Debug & Performance"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_trace_monitor_endpoint
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property REPORT_TO_TALKBACK true
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate
set_module_assignment debug.virtualInterface.link {debug.fabricLink {fabric trace} }
set_module_assignment debug.isTransparent true

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_trace_monitor_endpoint_wrapper
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_trace_monitor_endpoint_wrapper.sv system_verilog path altera_trace_monitor_endpoint_wrapper.sv


# 
# parameters
# 
add_parameter TRACE_WIDTH INTEGER 32
set_parameter_property TRACE_WIDTH ALLOWED_RANGES {32 64 128}
set_parameter_property TRACE_WIDTH AFFECTS_ELABORATION true
set_parameter_property TRACE_WIDTH AFFECTS_GENERATION false
set_parameter_property TRACE_WIDTH HDL_PARAMETER true

add_parameter ADDR_WIDTH INTEGER 4
set_parameter_property ADDR_WIDTH ALLOWED_RANGES {3:6}
set_parameter_property ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ADDR_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDR_WIDTH HDL_PARAMETER true

add_parameter READ_LATENCY INTEGER 0
set_parameter_property READ_LATENCY ALLOWED_RANGES {0:4}
set_parameter_property READ_LATENCY AFFECTS_ELABORATION true
set_parameter_property READ_LATENCY AFFECTS_GENERATION false
set_parameter_property READ_LATENCY HDL_PARAMETER true

add_parameter HAS_READDATAVALID INTEGER 0
set_parameter_property HAS_READDATAVALID ALLOWED_RANGES {0 1}
set_parameter_property HAS_READDATAVALID AFFECTS_ELABORATION true
set_parameter_property HAS_READDATAVALID AFFECTS_GENERATION false
set_parameter_property HAS_READDATAVALID HDL_PARAMETER true

add_parameter PREFER_TRACEID STRING {}
set_parameter_property PREFER_TRACEID AFFECTS_ELABORATION false
set_parameter_property PREFER_TRACEID AFFECTS_GENERATION false
set_parameter_property PREFER_TRACEID HDL_PARAMETER true

add_parameter CLOCK_RATE_CLK INTEGER 0
set_parameter_property CLOCK_RATE_CLK SYSTEM_INFO {CLOCK_RATE clk}
set_parameter_property CLOCK_RATE_CLK AFFECTS_ELABORATION false
set_parameter_property CLOCK_RATE_CLK AFFECTS_GENERATION false
set_parameter_property CLOCK_RATE_CLK HDL_PARAMETER true


# 
# display items
# 

#
# connection point clk
#
add_interface clk clock end
set_interface_property clk ENABLED true
add_interface_port clk clk clk Input 1


#
# connection point debug_reset
#
add_interface debug_reset reset start
set_interface_property debug_reset associatedClock clk
set_interface_property debug_reset ENABLED true
add_interface_port debug_reset reset reset Output 1


#
# connection point capture
#
add_interface capture avalon_streaming end
set_interface_property capture dataBitsPerSymbol 8
set_interface_property capture readyLatency 0
set_interface_property capture associatedClock clk
set_interface_property capture associatedReset debug_reset
set_interface_property capture ENABLED true
set_interface_assignment capture debug.controlledBy {link}
set_interface_assignment capture debug.interfaceGroup {associatedControl control}
add_interface_port capture capture_ready ready Output 1
add_interface_port capture capture_valid valid Input 1
add_interface_port capture capture_data data Input TRACE_WIDTH
add_interface_port capture capture_startofpacket startofpacket Input 1
add_interface_port capture capture_endofpacket endofpacket Input 1
add_interface_port capture capture_empty empty Input 1


#
# connection point control
#
add_interface control avalon start
set_interface_property control addressUnits WORDS
set_interface_property control associatedClock clk
set_interface_property control associatedReset debug_reset
set_interface_property control ENABLED true
add_interface_port control control_write write Output 1
add_interface_port control control_read read Output 1
add_interface_port control control_address address Output ADDR_WIDTH
add_interface_port control control_writedata writedata Output 32
add_interface_port control control_waitrequest waitrequest Input 1
set_port_property control_waitrequest termination true
add_interface_port control control_readdata readdata Input 32
add_interface_port control control_readdatavalid readdatavalid Input 1
set_port_property control_readdatavalid termination true


#
# Elaboration callback
#
proc elaborate {} {
    set TRACE_WIDTH [get_parameter_value TRACE_WIDTH]
    set READ_LATENCY [get_parameter_value READ_LATENCY]
    set HAS_READDATAVALID [get_parameter_value HAS_READDATAVALID]

    if {!($HAS_READDATAVALID == 0 || $READ_LATENCY == 0)} {
        send_message {error text} {Must have waitrequest to have readdatavalid}
    }

    set_port_property capture_empty width_expr [expr {[log2 $TRACE_WIDTH] - 3} ]

    if {$READ_LATENCY > 0} {
        set_interface_property control readLatency $READ_LATENCY
    }

    if {$HAS_READDATAVALID != 0} {
        set_interface_property control maximumPendingReadTransactions 1
        set_port_property control_readdatavalid termination false
    }

    if {$READ_LATENCY == 0} {
        set_port_property control_waitrequest termination false
    }
}

proc log2 x {expr {int(ceil(log($x) / log(2)))}}
