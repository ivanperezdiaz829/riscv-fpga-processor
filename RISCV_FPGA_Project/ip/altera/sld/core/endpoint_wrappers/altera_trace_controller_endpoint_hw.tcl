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
# altera_trace_controller_endpoint "altera_trace_controller_endpoint" v1.0
# 

# request TCL package from ACDS 13.0
# 
package require -exact qsys 13.0

# 
# module altera_trace_controller_endpoint
# 
set_module_property NAME altera_trace_controller_endpoint
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Verification/Debug & Performance"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property DISPLAY_NAME altera_trace_controller_endpoint
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property REPORT_TO_TALKBACK true
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property ELABORATION_CALLBACK elaborate
set_module_assignment debug.virtualInterface.link {debug.fabricLink {fabric mapped} }
set_module_assignment debug.isTransparent true

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL altera_trace_controller_endpoint_wrapper
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
add_fileset_file altera_trace_controller_endpoint_wrapper.sv system_verilog path altera_trace_controller_endpoint_wrapper.sv


# 
# parameters
# 
add_parameter ADDR_WIDTH INTEGER 10
set_parameter_property ADDR_WIDTH ALLOWED_RANGES {6:31}
set_parameter_property ADDR_WIDTH AFFECTS_ELABORATION true
set_parameter_property ADDR_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDR_WIDTH HDL_PARAMETER true

add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH ALLOWED_RANGES {32 64 128}
set_parameter_property DATA_WIDTH AFFECTS_ELABORATION true
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true

add_parameter MEMSIZE INTEGER 32768
set_parameter_property MEMSIZE ALLOWED_RANGES {0:External 8192:8k 16384:16k 32768:32k 65536:64k}
set_parameter_property MEMSIZE DISPLAY_NAME {Internal trace buffer size}
set_parameter_property MEMSIZE AFFECTS_ELABORATION true
set_parameter_property MEMSIZE AFFECTS_GENERATION false
set_parameter_property MEMSIZE HDL_PARAMETER true

add_parameter EXTMEM_BASE INTEGER 0
set_parameter_property EXTMEM_BASE DISPLAY_HINT hexadecimal
set_parameter_property EXTMEM_BASE DISPLAY_NAME {External memory base address}
set_parameter_property EXTMEM_BASE AFFECTS_ELABORATION false
set_parameter_property EXTMEM_BASE AFFECTS_GENERATION false
set_parameter_property EXTMEM_BASE HDL_PARAMETER true

add_parameter EXTMEM_SIZE INTEGER 1048576
set_parameter_property EXTMEM_SIZE DISPLAY_HINT hexadecimal
set_parameter_property EXTMEM_SIZE DISPLAY_NAME {External memory base size}
set_parameter_property EXTMEM_SIZE AFFECTS_ELABORATION false
set_parameter_property EXTMEM_SIZE AFFECTS_GENERATION false
set_parameter_property EXTMEM_SIZE HDL_PARAMETER true

add_parameter TRACEID STRING {}
set_parameter_property TRACEID AFFECTS_ELABORATION false
set_parameter_property TRACEID AFFECTS_GENERATION false
set_parameter_property TRACEID HDL_PARAMETER true

add_parameter TRACEID_PRIORITY INTEGER 100
set_parameter_property TRACEID_PRIORITY AFFECTS_ELABORATION false
set_parameter_property TRACEID_PRIORITY AFFECTS_GENERATION false
set_parameter_property TRACEID_PRIORITY HDL_PARAMETER true

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
# connection point debug_reset
#
add_interface debug_reset reset start
set_interface_property debug_reset associatedClock clk
set_interface_property debug_reset ENABLED true
add_interface_port debug_reset reset reset Output 1


#
# connection point master
#
add_interface master avalon start
set_interface_property master addressUnits WORDS
set_interface_property master maximumPendingReadTransactions 1
set_interface_property master associatedClock clk
set_interface_property master associatedReset reset
set_interface_property master ENABLED false
set_interface_assignment master debug.controlledBy {link}
add_interface_port master master_write write Output 1
set_port_property master_write termination true
add_interface_port master master_read read Output 1
set_port_property master_read termination true
add_interface_port master master_address address Output 1
set_port_property master_address termination true
add_interface_port master master_writedata writedata Output 1
set_port_property master_writedata termination true
add_interface_port master master_waitrequest waitrequest Input 1
set_port_property master_waitrequest termination true
add_interface_port master master_readdatavalid readdatavalid Input 1
set_port_property master_readdatavalid termination true
add_interface_port master master_readdata readdata Input 1
set_port_property master_readdata termination true


#
# Elaboration callback
#
proc elaborate {} {
    set MEMSIZE [get_parameter_value MEMSIZE]

    set_parameter_property EXTMEM_BASE ENABLED [expr {$MEMSIZE == 0} ]

    set_parameter_property EXTMEM_SIZE ENABLED [expr {$MEMSIZE == 0} ]

    if {$MEMSIZE == 0} {
        set_interface_property master ENABLED true
        set_port_property master_write width_expr 1
        set_port_property master_write termination false
        set_port_property master_read width_expr 1
        set_port_property master_read termination false
        set_port_property master_address width_expr $ADDR_WIDTH
        set_port_property master_address termination false
        set_port_property master_writedata width_expr $DATA_WIDTH
        set_port_property master_writedata termination false
        set_port_property master_waitrequest width_expr 1
        set_port_property master_waitrequest termination false
        set_port_property master_readdatavalid width_expr 1
        set_port_property master_readdatavalid termination false
        set_port_property master_readdata width_expr $DATA_WIDTH
        set_port_property master_readdata termination false
    }
}

proc log2 x {expr {int(ceil(log($x) / log(2)))}}
