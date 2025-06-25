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
# altera_avalon_st_debug_host_endpoint_bridge "altera_avalon_st_debug_host_endpoint_bridge" v1.0
# 

# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0

# 
# module altera_avalon_st_debug_host_endpoint_bridge
# 
set_module_property NAME altera_avalon_st_debug_host_endpoint_bridge
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Debug & Performance"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_avalon_st_debug_host_endpoint_bridge
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
add_parameter DATA_WIDTH INTEGER 8
set_parameter_property DATA_WIDTH ALLOWED_RANGES {8 16 32 64}
set_parameter_property DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true

add_parameter CHANNEL_WIDTH INTEGER 8
set_parameter_property CHANNEL_WIDTH ALLOWED_RANGES {2:32}
set_parameter_property CHANNEL_WIDTH AFFECTS_ELABORATION true
set_parameter_property CHANNEL_WIDTH AFFECTS_GENERATION false
set_parameter_property CHANNEL_WIDTH HDL_PARAMETER true


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
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset ENABLED true
add_interface_port reset reset reset Input 1


#
# connection point h2t
#
add_interface ext_h2t avalon_streaming end
set_interface_property ext_h2t dataBitsPerSymbol 8
set_interface_property ext_h2t readyLatency 0
set_interface_property ext_h2t associatedClock clk
set_interface_property ext_h2t associatedReset reset
set_interface_property ext_h2t ENABLED true
add_interface_port ext_h2t ext_h2t_ready ready Output 1
add_interface_port ext_h2t ext_h2t_valid valid Input 1
add_interface_port ext_h2t ext_h2t_data data Input DATA_WIDTH
add_interface_port ext_h2t ext_h2t_startofpacket startofpacket Input 1
add_interface_port ext_h2t ext_h2t_endofpacket endofpacket Input 1
add_interface_port ext_h2t ext_h2t_channel channel Input CHANNEL_WIDTH

add_interface int_h2t avalon_streaming start
set_interface_property int_h2t dataBitsPerSymbol 8
set_interface_property int_h2t readyLatency 0
set_interface_property int_h2t associatedClock clk
set_interface_property int_h2t associatedReset reset
set_interface_property int_h2t ENABLED true
add_interface_port int_h2t int_h2t_ready ready Input 1
add_interface_port int_h2t int_h2t_valid valid Output 1
add_interface_port int_h2t int_h2t_data data Output DATA_WIDTH
add_interface_port int_h2t int_h2t_startofpacket startofpacket Output 1
add_interface_port int_h2t int_h2t_endofpacket endofpacket Output 1
add_interface_port int_h2t int_h2t_channel channel Output CHANNEL_WIDTH

set_port_property ext_h2t_ready driven_by int_h2t_ready
set_port_property int_h2t_valid driven_by ext_h2t_valid
set_port_property int_h2t_data driven_by ext_h2t_data
set_port_property int_h2t_startofpacket driven_by ext_h2t_startofpacket
set_port_property int_h2t_endofpacket driven_by ext_h2t_endofpacket
set_port_property int_h2t_channel driven_by ext_h2t_channel


#
# connection point t2h
#
add_interface ext_t2h avalon_streaming start
set_interface_property ext_t2h dataBitsPerSymbol 8
set_interface_property ext_t2h readyLatency 0
set_interface_property ext_t2h associatedClock clk
set_interface_property ext_t2h associatedReset reset
set_interface_property ext_t2h ENABLED true
add_interface_port ext_t2h ext_t2h_ready ready Input 1
add_interface_port ext_t2h ext_t2h_valid valid Output 1
add_interface_port ext_t2h ext_t2h_data data Output DATA_WIDTH
add_interface_port ext_t2h ext_t2h_startofpacket startofpacket Output 1
add_interface_port ext_t2h ext_t2h_endofpacket endofpacket Output 1
add_interface_port ext_t2h ext_t2h_channel channel Output CHANNEL_WIDTH

add_interface int_t2h avalon_streaming end
set_interface_property int_t2h dataBitsPerSymbol 8
set_interface_property int_t2h readyLatency 0
set_interface_property int_t2h associatedClock clk
set_interface_property int_t2h associatedReset reset
set_interface_property int_t2h ENABLED true
add_interface_port int_t2h int_t2h_ready ready Output 1
add_interface_port int_t2h int_t2h_valid valid Input 1
add_interface_port int_t2h int_t2h_data data Input DATA_WIDTH
add_interface_port int_t2h int_t2h_startofpacket startofpacket Input 1
add_interface_port int_t2h int_t2h_endofpacket endofpacket Input 1
add_interface_port int_t2h int_t2h_channel channel Input CHANNEL_WIDTH

set_port_property int_t2h_ready driven_by ext_t2h_ready
set_port_property ext_t2h_valid driven_by int_t2h_valid
set_port_property ext_t2h_data driven_by int_t2h_data
set_port_property ext_t2h_startofpacket driven_by int_t2h_startofpacket
set_port_property ext_t2h_endofpacket driven_by int_t2h_endofpacket
set_port_property ext_t2h_channel driven_by int_t2h_channel


#
# connection point mgmt
#
add_interface ext_mgmt avalon_streaming end
set_interface_property ext_mgmt dataBitsPerSymbol 1
set_interface_property ext_mgmt associatedClock clk
set_interface_property ext_mgmt associatedReset reset
set_interface_property ext_mgmt ENABLED true
add_interface_port ext_mgmt ext_mgmt_valid valid Input 1
add_interface_port ext_mgmt ext_mgmt_data data Input 1
add_interface_port ext_mgmt ext_mgmt_channel channel Input CHANNEL_WIDTH

add_interface int_mgmt avalon_streaming start
set_interface_property int_mgmt dataBitsPerSymbol 1
set_interface_property int_mgmt associatedClock clk
set_interface_property int_mgmt associatedReset reset
set_interface_property int_mgmt ENABLED true
add_interface_port int_mgmt int_mgmt_valid valid Output 1
add_interface_port int_mgmt int_mgmt_data data Output 1
add_interface_port int_mgmt int_mgmt_channel channel Output CHANNEL_WIDTH

set_port_property int_mgmt_valid driven_by ext_mgmt_valid
set_port_property int_mgmt_data driven_by ext_mgmt_data
set_port_property int_mgmt_channel driven_by ext_mgmt_channel


#
# Elaboration callback
#
proc elaborate {} {
    set DATA_WIDTH [get_parameter_value DATA_WIDTH]
    set CHANNEL_WIDTH [get_parameter_value CHANNEL_WIDTH]

    set_interface_property int_h2t maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
    set_interface_property ext_h2t maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
    set_interface_property int_t2h maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
    set_interface_property ext_t2h maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
    set_interface_property int_mgmt maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]
    set_interface_property ext_mgmt maxChannel [expr {(1 << $CHANNEL_WIDTH) - 1} ]

    if {$DATA_WIDTH > 8} {
        add_interface_port int_h2t int_h2t_empty empty Output [expr {[log2 $DATA_WIDTH] - 3} ]
        add_interface_port ext_h2t ext_h2t_empty empty Input [expr {[log2 $DATA_WIDTH] - 3} ]
        set_port_property int_h2t_empty driven_by ext_h2t_empty
        add_interface_port int_t2h int_t2h_empty empty Input [expr {[log2 $DATA_WIDTH] - 3} ]
        add_interface_port ext_t2h ext_t2h_empty empty Output [expr {[log2 $DATA_WIDTH] - 3} ]
        set_port_property ext_t2h_empty driven_by int_t2h_empty
    }
}

proc log2 x {expr {int(ceil(log($x) / log(2)))}}
