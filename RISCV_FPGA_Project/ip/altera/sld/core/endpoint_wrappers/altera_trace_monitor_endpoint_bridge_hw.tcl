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
# altera_trace_monitor_endpoint_bridge "altera_trace_monitor_endpoint_bridge" v1.0
# 

# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0

# 
# module altera_trace_monitor_endpoint_bridge
# 
set_module_property NAME altera_trace_monitor_endpoint_bridge
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Debug & Performance"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_trace_monitor_endpoint_bridge
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property REPORT_TO_TALKBACK true
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate
set_module_assignment debug.isTransparent true

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
add_interface debug_reset reset end
set_interface_property debug_reset associatedClock clk
set_interface_property debug_reset ENABLED true
add_interface_port debug_reset reset reset Input 1


#
# connection point capture
#
add_interface ext_capture avalon_streaming end
set_interface_property ext_capture dataBitsPerSymbol 8
set_interface_property ext_capture readyLatency 0
set_interface_property ext_capture associatedClock clk
set_interface_property ext_capture associatedReset debug_reset
set_interface_property ext_capture ENABLED true
add_interface_port ext_capture ext_capture_ready ready Output 1
add_interface_port ext_capture ext_capture_valid valid Input 1
add_interface_port ext_capture ext_capture_data data Input TRACE_WIDTH
add_interface_port ext_capture ext_capture_startofpacket startofpacket Input 1
add_interface_port ext_capture ext_capture_endofpacket endofpacket Input 1
add_interface_port ext_capture ext_capture_empty empty Input 1

add_interface int_capture avalon_streaming start
set_interface_property int_capture dataBitsPerSymbol 8
set_interface_property int_capture readyLatency 0
set_interface_property int_capture associatedClock clk
set_interface_property int_capture associatedReset debug_reset
set_interface_property int_capture ENABLED true
add_interface_port int_capture int_capture_ready ready Input 1
add_interface_port int_capture int_capture_valid valid Output 1
add_interface_port int_capture int_capture_data data Output TRACE_WIDTH
add_interface_port int_capture int_capture_startofpacket startofpacket Output 1
add_interface_port int_capture int_capture_endofpacket endofpacket Output 1
add_interface_port int_capture int_capture_empty empty Output 1

set_port_property ext_capture_ready driven_by int_capture_ready
set_port_property int_capture_valid driven_by ext_capture_valid
set_port_property int_capture_data driven_by ext_capture_data
set_port_property int_capture_startofpacket driven_by ext_capture_startofpacket
set_port_property int_capture_endofpacket driven_by ext_capture_endofpacket
set_port_property int_capture_empty driven_by ext_capture_empty


#
# connection point control
#
add_interface ext_control avalon start
set_interface_property ext_control addressUnits WORDS
set_interface_property ext_control associatedClock clk
set_interface_property ext_control associatedReset debug_reset
set_interface_property ext_control ENABLED true
add_interface_port ext_control ext_control_write write Output 1
add_interface_port ext_control ext_control_read read Output 1
add_interface_port ext_control ext_control_address address Output ADDR_WIDTH
add_interface_port ext_control ext_control_writedata writedata Output 32
add_interface_port ext_control ext_control_readdata readdata Input 32

add_interface int_control avalon end
set_interface_property int_control addressUnits WORDS
set_interface_property int_control associatedClock clk
set_interface_property int_control associatedReset debug_reset
set_interface_property int_control ENABLED true
add_interface_port int_control int_control_write write Input 1
add_interface_port int_control int_control_read read Input 1
add_interface_port int_control int_control_address address Input ADDR_WIDTH
add_interface_port int_control int_control_writedata writedata Input 32
add_interface_port int_control int_control_readdata readdata Output 32

set_port_property ext_control_write driven_by int_control_write
set_port_property ext_control_read driven_by int_control_read
set_port_property ext_control_address driven_by int_control_address
set_port_property ext_control_writedata driven_by int_control_writedata
set_port_property int_control_readdata driven_by ext_control_readdata


#
# Elaboration callback
#
proc elaborate {} {
    set TRACE_WIDTH [get_parameter_value TRACE_WIDTH]
    set READ_LATENCY [get_parameter_value READ_LATENCY]
    set HAS_READDATAVALID [get_parameter_value HAS_READDATAVALID]

    set_port_property int_capture_empty width_expr [expr {[log2 $TRACE_WIDTH] - 3} ]
    set_port_property ext_capture_empty width_expr [expr {[log2 $TRACE_WIDTH] - 3} ]

    if {$READ_LATENCY > 0} {
        set_interface_property int_control readLatency $READ_LATENCY
        set_interface_property ext_control readLatency $READ_LATENCY
    }

    if {$HAS_READDATAVALID != 0} {
        set_interface_property int_control maximumPendingReadTransactions 1
        set_interface_property ext_control maximumPendingReadTransactions 1
        add_interface_port int_control int_control_readdatavalid readdatavalid Output 1
        add_interface_port ext_control ext_control_readdatavalid readdatavalid Input 1
        set_port_property int_control_readdatavalid driven_by ext_control_readdatavalid
    }

    if {$READ_LATENCY == 0} {
        add_interface_port int_control int_control_waitrequest waitrequest Output 1
        add_interface_port ext_control ext_control_waitrequest waitrequest Input 1
        set_port_property int_control_waitrequest driven_by ext_control_waitrequest
    }
}

proc log2 x {expr {int(ceil(log($x) / log(2)))}}
