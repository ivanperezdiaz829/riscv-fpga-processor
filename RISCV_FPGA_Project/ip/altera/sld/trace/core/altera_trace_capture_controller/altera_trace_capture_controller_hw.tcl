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
# |
# | alt_trace_capture_controller "alt_trace_capture_controller" v1.0
# | null 2011.05.10.12:00:50
# |
# |
# | S:/data/pclarke/p4_dev/acds/main/ssg/ip/altera_trace/altera_trace_ts_module/alt_trace_capture_controller.v
# |
# |    ./alt_trace_capture_controller.v syn, sim
# |
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.1
# |
package require -exact sopc 10.1
# |
# +-----------------------------------

# +-----------------------------------
# | module alt_trace_capture_controller
# |
set_module_property NAME                         altera_trace_capture_controller
set_module_property VERSION                      13.1
set_module_property AUTHOR                       "Altera Corporation"
set_module_property INTERNAL                     true
set_module_property GROUP                        "Verification/Debug & Performance/Trace"
set_module_property OPAQUE_ADDRESS_MAP           true
set_module_property DISPLAY_NAME                 altera_trace_capture_controller
set_module_property TOP_LEVEL_HDL_FILE           altera_trace_capture_controller.v
set_module_property TOP_LEVEL_HDL_MODULE         altera_trace_capture_controller
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     true
set_module_property ANALYZE_HDL                  false
set_module_property ELABORATION_CALLBACK         elaborate
set_module_property VALIDATION_CALLBACK          validate
# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_file altera_trace_capture_controller.v    {SYNTHESIS SIMULATION}
add_file altera_trace_capture_wr_control.sv   {SYNTHESIS SIMULATION}
add_file altera_trace_capture_rd_control.v    {SYNTHESIS SIMULATION}
add_file altera_trace_capture_segmentiser.v   {SYNTHESIS SIMULATION}
add_file altera_trace_ts_req_generator.v      {SYNTHESIS SIMULATION}
add_file altera_trace_wr_control_pl_stage.v   {SYNTHESIS SIMULATION}
add_file altera_trace_capture_header_parser.v {SYNTHESIS SIMULATION}
add_file altera_trace_capture_regs.v          {SYNTHESIS SIMULATION}
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

#                    name                      type   def_value            is_hdl   VISIBLE  Affects     group     display name             Tooltip hint                    args_range
#                                                                                   generation
proc_add_parameter  DEVICE_FAMILY              STRING    "Cyclone IV GX"   true    false     false        ""                       "Device family"             "monitored data width"
proc_add_parameter  TRACE_DATA_WIDTH           INTEGER    32               true    true      false        ""       TRACE_DATA_WIDTH       ""
proc_add_parameter  TRACE_SYMBOL_WIDTH         INTEGER     8               true    false     false        ""       TRACE_SYMBOL_WIDTH     ""
proc_add_parameter  TRACE_CHNL_WIDTH           INTEGER     1               true    true      false        ""       TRACE_CHNL_WIDTH       ""
proc_add_parameter  TRACE_MAX_CHNL             INTEGER     3               false   true      false        ""       TRACE_MAX_CHNL         ""                                  0:2147483647

# buffer addressing parameterisation...
#   Should probably change this to START_OFFSET and SIZE  (in Bytes...)
proc_add_parameter  BUFF_ADDR_WIDTH            INTEGER   10                true    true      true         ""       "Buffer Addr width (words)"     ""                                  6:31
proc_add_parameter  BUFF_LIMIT_LO              INTEGER    0                true    true      true         ""       "Start (word) address of buffer" ""
proc_add_parameter  BUFF_SIZE                  INTEGER 1024                true    true      true         ""       "maximum size of buffer in word locations" ""

proc_add_parameter  PACKET_LEN_BITS            INTEGER    6                true    true      true         ""       PACKET_LEN_BITS        ""
proc_add_parameter  NUM_PPD                    INTEGER    2                true    true      true         ""       NUM_PPD                ""
# NUM_PPD_OFFSET
#proc_add_parameter  HEADER_NUM_PPD_OFST        INTEGER   16               true    true      true         ""       HEADER_NUM_PPD_OFST    ""
# TODO: validate that we can pack the appropriate number of PPD and header info into the cell header word!


proc_add_parameter  MAX_OUT_PACKET_LENGTH      INTEGER 1024                true    false     true         ""       "Maximum output packet length"    ""
proc_add_parameter  ALIGNMENT_BOUNDARIES       INTEGER    0                true    false     true         ""       ALIGNMENT_BOUNDARIES   ""
proc_add_parameter  CREDIT_WIDTH               INTEGER   10                true    true      true         ""       CREDIT_WIDTH           ""
                                                                           
proc_add_parameter  WAKE_UP_MODE               string    "IDLE"            true    true      true        "Startup" "Wake up mode"                                "what happens on release of reset" 
proc_add_parameter  PERIODIC_TS_REQ_STARTUP    INTEGER    0                true    true      true        "Startup" "Periodic Timestamp service default period"   "set to 0 to disable at startup"    
                                                                           
proc_add_parameter  DEBUG_READBACK             INTEGER    1                true    false      true        "Debug "       "enable additional debug readback"   " "     0:1


set_parameter_property  WAKE_UP_MODE ALLOWED_RANGES  {"IDLE:IDLE" "CAPTURE:CAPTURE" "FIFO:FIFO"}

set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY
# |
# +-----------------------------------

# +-----------------------------------
# | display items
# |
# |
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# |
add_interface          clk clock     end
set_interface_property clk clockRate 0
set_interface_property clk ENABLED   true
add_interface_port     clk clk       clk   Input  1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point arst_n
# |
add_interface          reset reset            end
set_interface_property reset associatedClock  clk
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED          true
add_interface_port     reset arst_n           reset_n   Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point st_sync_req_clk
# |
add_interface          st_sync_req_clk clock             start
#set_interface_property st_sync_req_clk clockRate         17
set_interface_property st_sync_req_clk ENABLED           true
add_interface_port     st_sync_req_clk async_ts_sync_clk clk    Output 1
# |
# +-----------------------------------


add_interface          trace_packet_sink avalon_streaming   end
set_interface_property trace_packet_sink associatedClock    clk
set_interface_property trace_packet_sink associatedReset    reset
set_interface_property trace_packet_sink dataBitsPerSymbol  8
set_interface_property trace_packet_sink errorDescriptor    ""
set_interface_property trace_packet_sink readyLatency       0
set_interface_property trace_packet_sink ENABLED            true


add_interface          t2h avalon_streaming  start
set_interface_property t2h associatedClock   clk
set_interface_property t2h associatedReset   reset
set_interface_property t2h dataBitsPerSymbol 8
set_interface_property t2h errorDescriptor   ""
set_interface_property t2h maxChannel        0
set_interface_property t2h readyLatency      0
set_interface_property t2h ENABLED true





# +-----------------------------------
# | connection point avalon_master
# |
add_interface          storage_mm_master avalon                     start
set_interface_property storage_mm_master addressUnits               WORDS
set_interface_property storage_mm_master associatedClock            clk
set_interface_property storage_mm_master associatedReset            reset
set_interface_property storage_mm_master burstOnBurstBoundariesOnly false
set_interface_property storage_mm_master doStreamReads              false
set_interface_property storage_mm_master doStreamWrites             false
set_interface_property storage_mm_master linewrapBursts             false
set_interface_property storage_mm_master readLatency                0

set_interface_property storage_mm_master ENABLED         true

add_interface_port     storage_mm_master stg_m_write           write         Output 1
add_interface_port     storage_mm_master stg_m_read            read          Output 1
add_interface_port     storage_mm_master stg_m_address         address       Output BUFF_ADDR_WIDTH
add_interface_port     storage_mm_master stg_m_write_data      writedata     Output TRACE_DATA_WIDTH
add_interface_port     storage_mm_master stg_m_waitrequest     waitrequest   Input  1
add_interface_port     storage_mm_master stg_m_read_data_valid readdatavalid Input  1
add_interface_port     storage_mm_master stg_m_readdata        readdata      Input  TRACE_DATA_WIDTH
# |
# +-----------------------------------




add_interface          csr_slave avalon                     end
set_interface_property csr_slave addressUnits               WORDS
set_interface_property csr_slave associatedClock            clk
set_interface_property csr_slave associatedReset            reset
set_interface_property csr_slave burstOnBurstBoundariesOnly false
set_interface_property csr_slave linewrapBursts             false
set_interface_property csr_slave readWaitTime               0
set_interface_property csr_slave writeWaitTime              0
set_interface_property csr_slave readLatency                2

set_interface_property csr_slave ENABLED true

add_interface_port     csr_slave csr_s_write          write         input  1
add_interface_port     csr_slave csr_s_read           read          input  1
add_interface_port     csr_slave csr_s_address        address       input  6
add_interface_port     csr_slave csr_s_write_data     writedata     input  32
#add_interface_port     csr_slave csr_s_waitrequest    waitrequest   Output 1
add_interface_port     csr_slave csr_s_readdata       readdata      output 32



proc log2ceil {num} {
    #make log(0), log(1) = 1
    set val 1
    set i 2
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }
    return $val;
}


proc validate {} {
	set data_width [get_parameter_value TRACE_DATA_WIDTH]

	set used_bits_in_header [get_header_width [get_parameter_value TRACE_CHNL_WIDTH] [get_parameter_value NUM_PPD] [get_parameter_value PACKET_LEN_BITS] ]
	
	if {$used_bits_in_header > $data_width} { 
		send_message {text error} "Trace Capture controller: illegal system config! ($used_bits_in_header > $data_width). Please reduce the ammount of data that needs packing into the cell header: 1/number of sources, 2/size of packet part, 3/number of packet parts"		
	}
}

proc get_header_width {channel_width num_ppd packet_len_width} {
	set stored_num_ppd_width [log2ceil [expr {1 + $num_ppd}] ]
	set ppd_width  [expr {1 + $packet_len_width + $channel_width}]
	set size_of_hdr_pointer [expr {[log2ceil $num_ppd] + 1 + $packet_len_width}] 
	set used_bits_in_header [expr {$stored_num_ppd_width + ($ppd_width * $num_ppd) + $size_of_hdr_pointer}] 
	return $used_bits_in_header
}


proc elaborate {} {

    set_interface_property trace_packet_sink maxChannel         [get_parameter_value  TRACE_MAX_CHNL]
    add_interface_port     trace_packet_sink trace_packet_ready ready         Output 1
    add_interface_port     trace_packet_sink trace_packet_valid valid         Input  1
    add_interface_port     trace_packet_sink trace_packet_sop   startofpacket Input  1
    add_interface_port     trace_packet_sink trace_packet_eop   endofpacket   Input  1
    add_interface_port     trace_packet_sink trace_packet_data  data          Input  [get_parameter_value TRACE_DATA_WIDTH]
    add_interface_port     trace_packet_sink trace_packet_chnl  channel       Input  [get_parameter_value TRACE_CHNL_WIDTH]

    if {[get_parameter_value TRACE_DATA_WIDTH] == [get_parameter_value TRACE_SYMBOL_WIDTH]} {
        add_interface_port    trace_packet_sink trace_packet_empty empty output 1
        set_port_property     trace_packet_empty TERMINATION TRUE
        set_port_property     trace_packet_empty TERMINATION_VALUE 0
    } else {
        set empty_width [log2ceil [expr [get_parameter_value TRACE_DATA_WIDTH] / 8]]
        add_interface_port     trace_packet_sink trace_packet_empty empty         Input  $empty_width
    }



    add_interface_port     t2h               dbg_out_ready      ready         Input  1
    add_interface_port     t2h               dbg_out_valid      valid         Output 1
    add_interface_port     t2h               dbg_out_sop        startofpacket Output 1
    add_interface_port     t2h               dbg_out_eop        endofpacket   Output 1
    add_interface_port     t2h               dbg_out_data       data          Output [get_parameter_value TRACE_DATA_WIDTH]

    if {[get_parameter_value TRACE_DATA_WIDTH] == [get_parameter_value TRACE_SYMBOL_WIDTH]} {
        add_interface_port    t2h               dbg_out_empty      empty output 1
        set_port_property     dbg_out_empty TERMINATION TRUE
    } else {
        set empty_width [log2ceil [expr [get_parameter_value TRACE_DATA_WIDTH] / [get_parameter_value TRACE_SYMBOL_WIDTH]]]
        add_interface_port     t2h               dbg_out_empty      empty         Output $empty_width
    }
}

