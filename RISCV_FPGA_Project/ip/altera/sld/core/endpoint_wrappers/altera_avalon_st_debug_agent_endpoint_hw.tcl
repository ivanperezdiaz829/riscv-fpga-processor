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
# altera_avalon_st_debug_agent_endpoint "altera_avalon_st_debug_agent_endpoint" v1.0
# 

# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0

# 
# module altera_avalon_st_debug_agent_endpoint
# 
set_module_property NAME altera_avalon_st_debug_agent_endpoint
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Debug & Performance"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_avalon_st_debug_agent_endpoint
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property REPORT_TO_TALKBACK true
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate
set_module_assignment debug.virtualInterface.link {debug.fabricLink {fabric stream} }
set_module_assignment debug.isTransparent true

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_avalon_st_debug_agent_endpoint_wrapper
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_avalon_st_debug_agent_endpoint_wrapper.sv system_verilog path altera_avalon_st_debug_agent_endpoint_wrapper.sv


# 
# parameters
# 
add_parameter DATA_WIDTH INTEGER 8
set_parameter_property DATA_WIDTH ALLOWED_RANGES {8 16 32 64}
set_parameter_property DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true

add_parameter CHANNEL_WIDTH INTEGER 0
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES {0:32}
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH AFFECTS_GENERATION false
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true

add_parameter HAS_MGMT INTEGER 0
set_parameter_property HAS_MGMT ALLOWED_RANGES 0
set_parameter_property HAS_MGMT VISIBLE false
set_parameter_property HAS_MGMT AFFECTS_ELABORATION true
set_parameter_property HAS_MGMT AFFECTS_GENERATION false
set_parameter_property HAS_MGMT HDL_PARAMETER true

add_parameter READY_LATENCY INTEGER 0
set_parameter_property READY_LATENCY ALLOWED_RANGES {0:7}
set_parameter_property READY_LATENCY AFFECTS_ELABORATION true
set_parameter_property READY_LATENCY AFFECTS_GENERATION false
set_parameter_property READY_LATENCY HDL_PARAMETER true

add_parameter MFR_CODE INTEGER 0
set_parameter_property MFR_CODE AFFECTS_ELABORATION false
set_parameter_property MFR_CODE AFFECTS_GENERATION false
set_parameter_property MFR_CODE HDL_PARAMETER true

add_parameter TYPE_CODE INTEGER 0
set_parameter_property TYPE_CODE AFFECTS_ELABORATION false
set_parameter_property TYPE_CODE AFFECTS_GENERATION false
set_parameter_property TYPE_CODE HDL_PARAMETER true

add_parameter PREFER_HOST STRING {}
set_parameter_property PREFER_HOST AFFECTS_ELABORATION false
set_parameter_property PREFER_HOST AFFECTS_GENERATION false
set_parameter_property PREFER_HOST HDL_PARAMETER true

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
# connection point reset
#
add_interface reset reset start
set_interface_property reset associatedClock clk
set_interface_property reset ENABLED true
add_interface_port reset reset reset Output 1


#
# connection point h2t
#
add_interface h2t avalon_streaming start
set_interface_property h2t dataBitsPerSymbol 8
set_interface_property h2t associatedClock clk
set_interface_property h2t associatedReset reset
set_interface_property h2t ENABLED true
set_interface_assignment h2t debug.controlledBy {link}
set_interface_assignment h2t debug.interfaceGroup {associatedT2h t2h associatedMgmt mgmt}
add_interface_port h2t h2t_ready ready Input 1
add_interface_port h2t h2t_valid valid Output 1
add_interface_port h2t h2t_data data Output DATA_WIDTH
add_interface_port h2t h2t_startofpacket startofpacket Output 1
add_interface_port h2t h2t_endofpacket endofpacket Output 1
add_interface_port h2t h2t_empty empty Output 1
set_port_property h2t_empty termination true
add_interface_port h2t h2t_channel channel Output 1
set_port_property h2t_channel termination true


#
# connection point t2h
#
add_interface t2h avalon_streaming end
set_interface_property t2h dataBitsPerSymbol 8
set_interface_property t2h associatedClock clk
set_interface_property t2h associatedReset reset
set_interface_property t2h ENABLED true
add_interface_port t2h t2h_ready ready Output 1
add_interface_port t2h t2h_valid valid Input 1
add_interface_port t2h t2h_data data Input DATA_WIDTH
add_interface_port t2h t2h_startofpacket startofpacket Input 1
add_interface_port t2h t2h_endofpacket endofpacket Input 1
add_interface_port t2h t2h_empty empty Input 1
set_port_property t2h_empty termination true
add_interface_port t2h t2h_channel channel Input 1
set_port_property t2h_channel termination true


#
# connection point mgmt
#
add_interface mgmt avalon_streaming start
set_interface_property mgmt dataBitsPerSymbol 1
set_interface_property mgmt associatedClock clk
set_interface_property mgmt associatedReset reset
set_interface_property mgmt ENABLED false
add_interface_port mgmt mgmt_valid valid Output 1
set_port_property mgmt_valid termination true
add_interface_port mgmt mgmt_data data Output 1
set_port_property mgmt_data termination true
add_interface_port mgmt mgmt_channel channel Output 1
set_port_property mgmt_channel termination true


#
# Elaboration callback
#
proc elaborate {} {
    set DATA_WIDTH [get_parameter_value DATA_WIDTH]
    set CHANNEL_WIDTH [get_parameter_value CHANNEL_WIDTH]
    set HAS_MGMT [get_parameter_value HAS_MGMT]
    set READY_LATENCY [get_parameter_value READY_LATENCY]

    if {!($HAS_MGMT == 0 || $CHANNEL_WIDTH > 0)} {
        send_message {error text} {CHANNEL_WIDTH must be >0 for agents with a management interface}
    }

    set_interface_property h2t readyLatency $READY_LATENCY
    set_interface_property t2h readyLatency $READY_LATENCY

    if {$CHANNEL_WIDTH > 0} {
        set_interface_property h2t maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
        set_port_property h2t_channel width_expr $CHANNEL_WIDTH
        set_port_property h2t_channel termination false
        set_interface_property t2h maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
        set_port_property t2h_channel width_expr $CHANNEL_WIDTH
        set_port_property t2h_channel termination false
        set_interface_property mgmt maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
    }

    if {$DATA_WIDTH > 8} {
        set_port_property h2t_empty width_expr [expr {[log2 $DATA_WIDTH] - 3} ]
        set_port_property h2t_empty termination false
        set_port_property t2h_empty width_expr [expr {[log2 $DATA_WIDTH] - 3} ]
        set_port_property t2h_empty termination false
    }

    if {$CHANNEL_WIDTH > 0 && $HAS_MGMT != 0} {
        set_interface_property mgmt ENABLED true
        set_port_property mgmt_valid termination false
        set_port_property mgmt_data termination false
        set_port_property mgmt_channel width_expr $CHANNEL_WIDTH
        set_port_property mgmt_channel termination false
    }
}

proc log2 x {expr {int(ceil(log($x) / log(2)))}}
