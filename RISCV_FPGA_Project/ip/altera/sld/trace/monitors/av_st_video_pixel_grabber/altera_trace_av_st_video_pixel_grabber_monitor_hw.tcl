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
# | module altera_trace_av_st_video_pixel_grabber_monitor
# | 
set_module_property NAME                          altera_trace_av_st_video_pixel_grabber_monitor
set_module_property DISPLAY_NAME altera_trace_av_st_video_pixel_grabber_monitor
set_module_property VERSION                       13.1
set_module_property AUTHOR                        "Altera Corporation"
set_module_property INTERNAL                      true
set_module_property OPAQUE_ADDRESS_MAP            true
set_module_property DISPLAY_NAME                  "video pixel sampling monitor"
set_module_property GROUP                         "Verification/Debug & Performance/Trace"
set_module_property TOP_LEVEL_HDL_FILE            altera_trace_av_st_video_pixel_grabber_monitor.v
set_module_property TOP_LEVEL_HDL_MODULE          altera_trace_av_st_video_pixel_grabber_monitor
set_module_property INSTANTIATE_IN_SYSTEM_MODULE  true
set_module_property EDITABLE                      true
set_module_property ANALYZE_HDL                   false
set_module_property STATIC_TOP_LEVEL_MODULE_NAME  "altera_trace_av_st_video_pixel_grabber_monitor"
set_module_property ELABORATION_CALLBACK          elaborate

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_trace_av_st_video_pixel_grabber_monitor.v {SYNTHESIS SIMULATION}
add_file altera_trace_av_st_video_pxl_grab_smplr.v        {SYNTHESIS SIMULATION}
add_file altera_trace_av_st_vpg_lfsr_gen.v                {SYNTHESIS SIMULATION}
add_file altera_trace_av_st_vpg_output.v                  {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +----------------------MAX_COUNT_WIDTH-------------
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
proc_add_parameter  MON_NUM_PIXELS             integer   1                 true    true     false        "MON_IF_cfg"            "Num pixels per word"                            ""
proc_add_parameter  MON_PIXEL_WIDTH            integer   30                true    true     false        "MON_IF_cfg"            "Pixel width"                                    ""
proc_add_parameter  MON_CHANNEL_WIDTH          integer   0                 false   false     false       "MON_IF_cfg"            "channel width"                                  ""
proc_add_parameter  MON_MTY_WIDTH              integer   0                 false   false     false       "MON_IF_cfg"            "empty width"                                    ""
proc_add_parameter  MON_READY_LATENCY          integer   1                 true    false     false       "Monitor_cfg"           "Ready latency"                                  ""                                0:1

proc_add_parameter  BUFF_ADDR_WIDTH            integer   8                 true    true      true        "Monitor_cfg"            "Address Width of the internal pixel sample buffer"                               4:10

proc_add_parameter  FULL_TS_LENGTH             integer  32                 true    true      false       "Monitor_cfg"            "Bits in full timestamp"                        ""
proc_add_parameter  WAKE_UP_RUNNING            integer   0                 true    false     false       "Monitor_cfg"            "Wake up running"                               ""                                0:1
proc_add_parameter  USE_READY                  integer   1                 true    false     false       "Monitor_cfg"            "Use ready"                                     ""                                0:1
                                                                                                                                                                                  
proc_add_parameter  TRACE_OUT_SYM_WIDTH        integer   4                 true    true     false        "capture_if_cfg"        "Number of Symbols"                              ""                               

set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY





# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

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
add_interface_port capture av_st_tr_data  data  Output [expr [get_parameter_value TRACE_OUT_SYM_WIDTH]  * 8]
add_interface_port capture av_st_tr_empty empty Output [log2ceil [get_parameter_value TRACE_OUT_SYM_WIDTH]]

set width_dat [expr [get_parameter_value MON_NUM_PIXELS] * [get_parameter_value MON_PIXEL_WIDTH]]
#set width_chn [get_parameter_value MON_CHANNEL_WIDTH]
#set width_mty [get_parameter_value MON_EMPTY_WIDTH]
#set width_err [get_parameter_value MON_ERR_WIDTH]

    add_interface_port tap_input iut_st_ready ready         Input 1
    add_interface_port tap_input iut_st_valid valid         Input 1
    add_interface_port tap_input iut_st_sop   startofpacket Input 1
    add_interface_port tap_input iut_st_eop   endofpacket   Input 1

if {$width_dat} {add_interface_port tap_input iut_st_data  data    Input $width_dat }  else { add_interface_port tap_input iut_st_data  data    Input 1;  set_port_property iut_st_data  TERMINATION TRUE; set_port_property iut_st_data  TERMINATION_VALUE 0}
#if {$width_chn} {add_interface_port tap_input iut_st_ch    channel Input $width_chn }  else { add_interface_port tap_input iut_st_ch    channel Input 1;  set_port_property iut_st_ch    TERMINATION TRUE; set_port_property iut_st_ch    TERMINATION_VALUE 0}
#if {$width_mty} {add_interface_port tap_input iut_st_empty empty   Input $width_mty }  else { add_interface_port tap_input iut_st_empty empty   Input 1;  set_port_property iut_st_empty TERMINATION TRUE; set_port_property iut_st_empty TERMINATION_VALUE 0}
#if {$width_err} {add_interface_port tap_input iut_st_err   error   Input $width_err }  else { add_interface_port tap_input iut_st_err   error   Input 1;  set_port_property iut_st_err   TERMINATION TRUE; set_port_property iut_st_err   TERMINATION_VALUE 0}


}

