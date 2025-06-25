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


# +-----------------------------------
# | request TCL package from ACDS 11.0
# |
package require -exact sopc 11.0
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_trace_av_st_example_distiller
# |
set_module_property NAME                          altera_trace_av_st_monitor
set_module_property VERSION                       13.1
set_module_property AUTHOR                        "Altera Corporation"
set_module_property INTERNAL                      true
set_module_property OPAQUE_ADDRESS_MAP            true
set_module_property DISPLAY_NAME                  "avalon streaming monitor"
set_module_property GROUP                         "Verification/Debug & Performance/Trace"
set_module_property TOP_LEVEL_HDL_FILE            altera_trace_av_st_monitor.v
set_module_property TOP_LEVEL_HDL_MODULE          altera_trace_av_st_monitor
set_module_property INSTANTIATE_IN_SYSTEM_MODULE  true
set_module_property EDITABLE                      true
set_module_property ANALYZE_HDL                   false
set_module_property STATIC_TOP_LEVEL_MODULE_NAME  "altera_trace_av_st_monitor"
set_module_property ELABORATION_CALLBACK          elaborate
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_file altera_trace_av_st_monitor.v                           {SYNTHESIS SIMULATION}
add_file altera_trace_av_st_example_monitor.v                   {SYNTHESIS SIMULATION}
add_file altera_trace_av_st_ex_monitor_buffered_width_adapter.v {SYNTHESIS SIMULATION}
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |


proc proc_add_parameter {NAME TYPE DEFAULT IS_HDL VISIBLE AFFECTS_GENERATION GROUP DISP_NAME DESCRIPTION  args} {
    add_parameter           $NAME $TYPE $DEFAULT $DESCRIPTION
    if {$args != ""} then {
        set_parameter_property  $NAME "ALLOWED_RANGES" $args
    }
    set_parameter_property  $NAME "VISIBLE"            $VISIBLE
    set_parameter_property  $NAME "HDL_PARAMETER"      $IS_HDL
    set_parameter_property  $NAME "GROUP"              $GROUP
    set_parameter_property  $NAME "DISPLAY_NAME"       $DISP_NAME
    set_parameter_property  $NAME "AFFECTS_GENERATION" $AFFECTS_GENERATION
}

#                    name                      type   def_value           is_hdl   VISIBLE  Affects     group                     display name                                      Tooltip hint                    args_range
#                                                                                           generation
#proc_add_parameter ARGWIDTH                   INTEGER    32               false   true      false        ""                       "Argument Width"                               "Width of an Argument in bits"
proc_add_parameter  DEVICE_FAMILY              STRING    "Cyclone IV GX"   true    false     false        ""                       "Device family"                                "monitored data width"
proc_add_parameter  MON_DATA_WIDTH             INTEGER     8               true    true      true         "Input interface"        "monitored data width"                         ""
proc_add_parameter  MON_EMPTY_WIDTH            INTEGER     8               true    true      true         "Input interface"        "monitored empty width"                        ""
proc_add_parameter  MON_ERR_WIDTH              INTEGER     8               true    true      true         "Input interface"        "monitored error width"                        ""
proc_add_parameter  MON_CHANNEL_WIDTH          INTEGER     8               true    true      true         "Input interface"        "monitored channel width"                      ""
proc_add_parameter  MON_READY_LATENCY          INTEGER     0               true    true      true         "Input interface"        "Ready latency of the monitored interface"     ""


proc_add_parameter  TRACE_OUT_SYMBOL_WIDTH     INTEGER    4                true    true       true         "output interface"       "output num symbols"                          ""

proc_add_parameter  FULL_TS_LENGTH             INTEGER    48               true     true      true        "internal configuration" "full timestamp width"                         ""
proc_add_parameter  COUNTER_WIDTHS             INTEGER    15               true     true      true        "internal configuration" "bits per counter"                             ""
proc_add_parameter  BUFFER_DEPTH_WIDTH         INTEGER     5               true     true      true        "internal configuration" "Width of fifo address"                        ""
proc_add_parameter  TAP_CAPTURED_WORDS         INTEGER     1               true    false      true        "internal configuration" "Number of words captured"                     ""

proc_add_parameter  TYPE_NUM                   INTEGER     270             true    false      true        "internal configuration" "Type identifier"                              ""

set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY

# |
# +-----------------------------------


# +-----------------------------------
# | connection point clk
# |
add_interface clk clock end
set_interface_property clk clockRate 0

set_interface_property clk ENABLED true

add_interface_port clk clk clk Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point reset
# |
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT

set_interface_property reset ENABLED true

add_interface_port reset arst_n reset_n Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point csr_s
# |
add_interface csr_s avalon end
set_interface_property csr_s addressUnits                   WORDS
set_interface_property csr_s associatedClock                clk
set_interface_property csr_s associatedReset                reset
set_interface_property csr_s bitsPerSymbol                  8
set_interface_property csr_s burstOnBurstBoundariesOnly     false
set_interface_property csr_s burstcountUnits                WORDS
set_interface_property csr_s explicitAddressSpan            0
set_interface_property csr_s holdTime                       0
set_interface_property csr_s linewrapBursts                 false
set_interface_property csr_s maximumPendingReadTransactions 0
set_interface_property csr_s readLatency                    2
set_interface_property csr_s readWaitStates                 0
set_interface_property csr_s readWaitTime                   0
set_interface_property csr_s setupTime                      0
set_interface_property csr_s timingUnits                    Cycles
set_interface_property csr_s writeWaitTime                  0

set_interface_property csr_s ENABLED                        true

add_interface_port csr_s csr_s_read       read      Input  1
add_interface_port csr_s csr_s_address    address   Input  4
add_interface_port csr_s csr_s_readdata   readdata  Output 32
add_interface_port csr_s csr_s_write      write     Input  1
add_interface_port csr_s csr_s_write_data writedata Input  32
# |
# +-----------------------------------

# +-----------------------------------
# | connection point tap_input
# |
add_interface          tap_input conduit end
set_interface_property tap_input ENABLED true
# |
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# |
add_interface          capture avalon_streaming start
set_interface_property capture associatedClock clk
set_interface_property capture associatedReset reset
set_interface_property capture dataBitsPerSymbol 8
set_interface_property capture errorDescriptor ""
set_interface_property capture firstSymbolInHighOrderBits true
set_interface_property capture maxChannel 0
set_interface_property capture readyLatency 0
set_interface_property capture ENABLED true
set_interface_assignment capture debug.providesServices traceMonitor
set_interface_assignment capture debug.interfaceGroup {associatedControl csr_s}
add_interface_port     capture av_st_tr_ready ready        Input 1
add_interface_port     capture av_st_tr_valid valid        Output 1
add_interface_port     capture av_st_tr_sop  startofpacket Output 1
add_interface_port     capture av_st_tr_eop  endofpacket   Output 1

set_interface_assignment capture debug.param.setting.Enable {
    proc get_value {c i} {expr [trace_read_monitor $c $i 4] != 0}
    proc set_value {c i v} {trace_write_monitor $c $i 4 [expr ($v != 0) ? 0x301 : 0]}
    set hints boolean
}

# |
# +-----------------------------------

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

proc elaborate {} {

# time to work out the numebr of symbols in data!
set num_data_symbols     [expr ([get_parameter_value MON_DATA_WIDTH]    + 7) /8]
set num_syms_chn         [expr ([get_parameter_value MON_CHANNEL_WIDTH] + 7) / 8]
set num_syms_mty         [expr ([get_parameter_value MON_EMPTY_WIDTH]   + 7) / 8]
set num_syms_err         [expr ([get_parameter_value MON_ERR_WIDTH]     + 7) / 8]


add_interface_port capture av_st_tr_data  data  Output [expr [get_parameter_value TRACE_OUT_SYMBOL_WIDTH]  * 8]
add_interface_port capture av_st_tr_empty empty Output [log2ceil [get_parameter_value TRACE_OUT_SYMBOL_WIDTH]]

set width_dat [get_parameter_value MON_DATA_WIDTH]
set width_chn [get_parameter_value MON_CHANNEL_WIDTH]
set width_mty [get_parameter_value MON_EMPTY_WIDTH]
set width_err [get_parameter_value MON_ERR_WIDTH]

    add_interface_port tap_input iut_st_ready ready         Input 1
    add_interface_port tap_input iut_st_valid valid         Input 1
    add_interface_port tap_input iut_st_sop   startofpacket Input 1
    add_interface_port tap_input iut_st_eop   endofpacket   Input 1

if {$width_dat} {add_interface_port tap_input iut_st_data  data    Input $width_dat }  else { add_interface_port tap_input iut_st_data  data    Input 1;  set_port_property iut_st_data  TERMINATION TRUE; set_port_property iut_st_data  TERMINATION_VALUE 0}
if {$width_chn} {add_interface_port tap_input iut_st_ch    channel Input $width_chn }  else { add_interface_port tap_input iut_st_ch    channel Input 1;  set_port_property iut_st_ch    TERMINATION TRUE; set_port_property iut_st_ch    TERMINATION_VALUE 0}
if {$width_mty} {add_interface_port tap_input iut_st_empty empty   Input $width_mty }  else { add_interface_port tap_input iut_st_empty empty   Input 1;  set_port_property iut_st_empty TERMINATION TRUE; set_port_property iut_st_empty TERMINATION_VALUE 0}
if {$width_err} {add_interface_port tap_input iut_st_err   error   Input $width_err }  else { add_interface_port tap_input iut_st_err   error   Input 1;  set_port_property iut_st_err   TERMINATION TRUE; set_port_property iut_st_err   TERMINATION_VALUE 0}


}

