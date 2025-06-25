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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_st_monitor_bfm/altera_avalon_st_monitor_hw.tcl#2 $
# $Revision: #2 $
# $Date: 2013/08/15 $
# $Author: saafnan $
#---------------------------------------------------------------------
package require -exact qsys 13.1

set_module_property NAME                            altera_avalon_st_monitor
set_module_property DISPLAY_NAME                    "Altera Avalon-ST Monitor"
set_module_property DESCRIPTION                     "Altera Avalon-ST Monitor"
set_module_property VERSION                         13.1
set_module_property GROUP                           "Avalon Verification Suite"
set_module_property AUTHOR                          "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE    true
set_module_property EDITABLE                        false
set_module_property INTERNAL                        false
set_module_property VALIDATION_CALLBACK             validate
set_module_property ELABORATION_CALLBACK            elaborate
set_module_property ANALYZE_HDL                     false

# ---------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------
# Define file set
add_fileset sim_verilog SIM_VERILOG sim_verilog
set_fileset_property sim_verilog top_level altera_avalon_st_monitor

add_fileset quartus_synth QUARTUS_SYNTH quartus_synth_proc
set_fileset_property quartus_synth top_level altera_avalon_st_monitor

add_fileset sim_vhdl SIM_VHDL sim_vhdl
set_fileset_property sim_vhdl top_level altera_avalon_st_monitor_vhdl

# SIM_VERILOG generation callback procedure
proc sim_verilog {altera_avalon_st_monitor} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv" 
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv" 
   add_fileset_file altera_avalon_st_monitor_assertion.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor_assertion.sv"
   add_fileset_file altera_avalon_st_monitor_coverage.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor_coverage.sv"
   add_fileset_file altera_avalon_st_monitor_transactions.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor_transactions.sv"
   add_fileset_file altera_avalon_st_monitor.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor.sv"
   
   set_fileset_file_attribute verbosity_pkg.sv           COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_utilities_pkg.sv    COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_utilities_pkg
}

proc quartus_synth_proc {altera_avalon_st_monitor} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv" 
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv" 
   add_fileset_file altera_avalon_st_monitor_assertion.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor_assertion.sv"
   add_fileset_file altera_avalon_st_monitor_coverage.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor_coverage.sv"
   add_fileset_file altera_avalon_st_monitor_transactions.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor_transactions.sv"
   add_fileset_file altera_avalon_st_monitor.sv SYSTEM_VERILOG PATH "altera_avalon_st_monitor.sv"
}

# SIM_VHDL generation callback procedure
proc sim_vhdl {altera_avalon_st_monitor_vhdl} {
   set HDL_LIB_DIR "../lib"
   set VHDL_DIR      "../altera_avalon_st_monitor_bfm_vhdl";
   
   if {1} {
      add_fileset_file mentor/verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/verbosity_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/avalon_utilities_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_st_monitor_transactions.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_monitor_transactions.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_st_monitor_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_monitor_vhdl_wrapper.sv" {MENTOR_SPECIFIC}
   
      set_fileset_file_attribute mentor/verbosity_pkg.sv           COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_verbosity_pkg
      set_fileset_file_attribute mentor/avalon_utilities_pkg.sv    COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_mentor_avalon_utilities_pkg
   }

   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/verbosity_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_st_monitor_transactions.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_st_monitor_transactions.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_st_monitor_vhdl_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_st_monitor_vhdl_wrapper.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   
   set_fileset_file_attribute verbosity_pkg.sv           COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_verbosity_pkg
   set_fileset_file_attribute avalon_utilities_pkg.sv    COMMON_SYSTEMVERILOG_PACKAGE avalon_vip_avalon_utilities_pkg
   
   add_fileset_file altera_avalon_st_monitor_vhdl_pkg.vhd VHDL path "$VHDL_DIR/altera_avalon_st_monitor_vhdl_pkg.vhd"
   add_fileset_file altera_avalon_st_monitor_vhdl.vhd VHDL path "$VHDL_DIR/altera_avalon_st_monitor_vhdl.vhd"

}

add_documentation_link "User Guide" "http://www.altera.com/literature/ug/ug_avalon_verification_ip.pdf"
#---------------------------------------------------------------------
# Parameters
#---------------------------------------------------------------------
set ST_SYMBOL_W             "ST_SYMBOL_W"
set ST_NUMSYMBOLS           "ST_NUMSYMBOLS"
set ST_CHANNEL_W            "ST_CHANNEL_W"
set ST_ERROR_W              "ST_ERROR_W"
set ST_EMPTY_W              "ST_EMPTY_W"
set USE_PACKET              "USE_PACKET"
set USE_CHANNEL             "USE_CHANNEL"
set USE_ERROR               "USE_ERROR"
set USE_READY               "USE_READY"
set USE_VALID               "USE_VALID"
set USE_EMPTY               "USE_EMPTY"
set ST_READY_LATENCY        "ST_READY_LATENCY"
set ST_MAX_CHANNELS         "ST_MAX_CHANNELS"
set ST_BEATSPERCYCLE        "ST_BEATSPERCYCLE"
set ST_MAX_PACKET_SIZE      "ST_MAX_PACKET_SIZE"
set VHDL_ID                 "VHDL_ID"

#---------------------------------------------------------------------
add_parameter $USE_PACKET Integer 1
set_parameter_property $USE_PACKET DISPLAY_NAME "Use the start and end of packet ports."
set_parameter_property $USE_PACKET AFFECTS_ELABORATION true
set_parameter_property $USE_PACKET DESCRIPTION "Use the start and end of packet ports."
set_parameter_property $USE_PACKET DISPLAY_HINT boolean
set_parameter_property $USE_PACKET HDL_PARAMETER true
set_parameter_property $USE_PACKET GROUP "Port Enables"

add_parameter $USE_CHANNEL Integer 1 
set_parameter_property $USE_CHANNEL DISPLAY_NAME "Use the channel port"
set_parameter_property $USE_CHANNEL AFFECTS_ELABORATION true
set_parameter_property $USE_CHANNEL DESCRIPTION "Use the channel port"
set_parameter_property $USE_CHANNEL DISPLAY_HINT boolean
set_parameter_property $USE_CHANNEL HDL_PARAMETER true
set_parameter_property $USE_CHANNEL GROUP "Port Enables"

add_parameter $USE_ERROR Integer 1 
set_parameter_property $USE_ERROR DISPLAY_NAME "Use the error port"
set_parameter_property $USE_ERROR AFFECTS_ELABORATION true
set_parameter_property $USE_ERROR DESCRIPTION "Use the error port"
set_parameter_property $USE_ERROR DISPLAY_HINT boolean
set_parameter_property $USE_ERROR HDL_PARAMETER true
set_parameter_property $USE_ERROR GROUP "Port Enables"

add_parameter $USE_READY Integer 1 
set_parameter_property $USE_READY DISPLAY_NAME "Use the ready port"
set_parameter_property $USE_READY AFFECTS_ELABORATION true
set_parameter_property $USE_READY DESCRIPTION "Use the ready port"
set_parameter_property $USE_READY DISPLAY_HINT boolean
set_parameter_property $USE_READY HDL_PARAMETER true
set_parameter_property $USE_READY GROUP "Port Enables"

add_parameter $USE_VALID Integer 1 
set_parameter_property $USE_VALID DISPLAY_NAME "Use the valid port"
set_parameter_property $USE_VALID AFFECTS_ELABORATION true
set_parameter_property $USE_VALID DESCRIPTION "Use the valid port"
set_parameter_property $USE_VALID DISPLAY_HINT boolean
set_parameter_property $USE_VALID HDL_PARAMETER true
set_parameter_property $USE_VALID GROUP "Port Enables"

add_parameter $USE_EMPTY Integer 1 
set_parameter_property $USE_EMPTY DISPLAY_NAME "Use the empty port"
set_parameter_property $USE_EMPTY AFFECTS_ELABORATION true
set_parameter_property $USE_EMPTY DESCRIPTION "Use the empty port"
set_parameter_property $USE_EMPTY DISPLAY_HINT boolean
set_parameter_property $USE_EMPTY HDL_PARAMETER true
set_parameter_property $USE_EMPTY GROUP "Port Enables"

add_parameter $ST_SYMBOL_W Positive 8 
set_parameter_property $ST_SYMBOL_W DISPLAY_NAME "Symbol width"
set_parameter_property $ST_SYMBOL_W AFFECTS_ELABORATION true
set_parameter_property $ST_SYMBOL_W DESCRIPTION "Symbol width (bits) "
set_parameter_property $ST_SYMBOL_W HDL_PARAMETER true
set_parameter_property $ST_SYMBOL_W GROUP "Port Widths"

add_parameter $ST_NUMSYMBOLS Positive 4 
set_parameter_property $ST_NUMSYMBOLS DISPLAY_NAME "Number of Symbols"
set_parameter_property $ST_NUMSYMBOLS AFFECTS_ELABORATION true
set_parameter_property $ST_NUMSYMBOLS DESCRIPTION "Number of symbols"
set_parameter_property $ST_NUMSYMBOLS HDL_PARAMETER true
set_parameter_property $ST_NUMSYMBOLS GROUP "Port Widths"

add_parameter $ST_CHANNEL_W Positive 1 
set_parameter_property $ST_CHANNEL_W DISPLAY_NAME "Width of the channel port"
set_parameter_property $ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property $ST_CHANNEL_W DESCRIPTION "Width of the channel port"
set_parameter_property $ST_CHANNEL_W HDL_PARAMETER true
set_parameter_property $ST_CHANNEL_W ALLOWED_RANGES {0:8}
set_parameter_property $ST_CHANNEL_W GROUP "Port Widths"

add_parameter $ST_ERROR_W Positive 1 
set_parameter_property $ST_ERROR_W DISPLAY_NAME "Width of the error port"
set_parameter_property $ST_ERROR_W AFFECTS_ELABORATION true
set_parameter_property $ST_ERROR_W DESCRIPTION "Width of the error port"
set_parameter_property $ST_ERROR_W HDL_PARAMETER true
set_parameter_property $ST_ERROR_W ALLOWED_RANGES {1:255}
set_parameter_property $ST_ERROR_W GROUP "Port Widths"

add_parameter $ST_EMPTY_W Positive 1 
set_parameter_property $ST_EMPTY_W DERIVED true
set_parameter_property $ST_EMPTY_W DISPLAY_NAME "Width of the empty port"
set_parameter_property $ST_EMPTY_W AFFECTS_ELABORATION true
set_parameter_property $ST_EMPTY_W DESCRIPTION "Empty word width in bits"
set_parameter_property $ST_EMPTY_W HDL_PARAMETER true
set_parameter_property $ST_EMPTY_W GROUP "Port Widths"
set_parameter_property $ST_EMPTY_W ENABLED false

add_parameter $ST_READY_LATENCY Integer 0 
set_parameter_property $ST_READY_LATENCY DISPLAY_NAME "Ready latency"
set_parameter_property $ST_READY_LATENCY AFFECTS_ELABORATION true
set_parameter_property $ST_READY_LATENCY HDL_PARAMETER true
set_parameter_property $ST_READY_LATENCY DESCRIPTION "Number of cycles from the time ready is asserted until valid data is driven"
set_parameter_property $ST_READY_LATENCY GROUP "Timing Attributes"

add_parameter $ST_BEATSPERCYCLE Integer 1 
set_parameter_property $ST_BEATSPERCYCLE DISPLAY_NAME "Number of beats per cycle"
set_parameter_property $ST_BEATSPERCYCLE AFFECTS_ELABORATION true
set_parameter_property $ST_BEATSPERCYCLE HDL_PARAMETER true
set_parameter_property $ST_BEATSPERCYCLE DESCRIPTION "Maximum number of packets per clock cycle"
set_parameter_property $ST_BEATSPERCYCLE ALLOWED_RANGES {1:1024}
set_parameter_property $ST_BEATSPERCYCLE GROUP "Timing Attributes"

add_parameter $ST_MAX_CHANNELS Integer 1 
set_parameter_property $ST_MAX_CHANNELS DISPLAY_NAME "Max Channel Number"
set_parameter_property $ST_MAX_CHANNELS AFFECTS_ELABORATION true
set_parameter_property $ST_MAX_CHANNELS HDL_PARAMETER true
set_parameter_property $ST_MAX_CHANNELS DESCRIPTION "Maximum number of channels supported"
set_parameter_property $ST_MAX_CHANNELS GROUP "Channel Attributes"

add_parameter $ST_MAX_PACKET_SIZE Integer 1 
set_parameter_property $ST_MAX_PACKET_SIZE DISPLAY_NAME "Max Packet Size Covered"
set_parameter_property $ST_MAX_PACKET_SIZE AFFECTS_ELABORATION true
set_parameter_property $ST_MAX_PACKET_SIZE DESCRIPTION "Maximum number of packet size covered"
set_parameter_property $ST_MAX_PACKET_SIZE HDL_PARAMETER true
set_parameter_property $ST_MAX_PACKET_SIZE GROUP "Miscellaneous Properties"

add_parameter $VHDL_ID Integer 0
set_parameter_property $VHDL_ID DISPLAY_NAME "VHDL BFM ID"
set_parameter_property $VHDL_ID DESCRIPTION "BFM ID number for VHDL"
set_parameter_property $VHDL_ID HDL_PARAMETER true
set_parameter_property $VHDL_ID ALLOWED_RANGES {0:1023}
set_parameter_property $VHDL_ID GROUP "VHDL BFM"

   
#------------------------------------------------------------------------------
# logarithm to base 2
#------------------------------------------------------------------------------
proc clog2 x {
    if { $x > 0 } {
    expr int(ceil(log($x) / log(2)))
    } else {
    return 0
    }
}

#------------------------------------------------------------------------------
proc validate {} {
    global USE_PACKET
    global USE_EMPTY
    global USE_CHANNEL
    global ST_EMPTY_W
    global ST_CHANNEL_W
    global ST_NUMSYMBOLS
    global ST_READY_LATENCY 
    global ST_MAX_CHANNELS

    if {[get_parameter $ST_NUMSYMBOLS] > 1} {
    set_parameter_value $ST_EMPTY_W [clog2 [get_parameter $ST_NUMSYMBOLS]]
    }

    if { [get_parameter $ST_READY_LATENCY] < 0 } {
    send_message error "ST_READY_LATENCY must be equal or greater than 0"
    }
    if { [get_parameter $USE_EMPTY] == 1 && [get_parameter $USE_PACKET] == 0 } {
    send_message error "The empty port can only be used with the packet ports."
    }
    if {[get_parameter $USE_CHANNEL] > 0} {
    if {[get_parameter $ST_MAX_CHANNELS] > [expr 1 << [get_parameter $ST_CHANNEL_W]]} {
        send_message error "ST_MAX_CHANNELS may not be greater than ST_CHANNEL_W ** 2."
    }
    }
}
#------------------------------------------------------------------------------
proc elaborate {} {
    global ST_SYMBOL_W  
    global ST_NUMSYMBOLS  
    global ST_CHANNEL_W  
    global ST_ERROR_W  
    global ST_EMPTY_W  

    global ST_READY_LATENCY  
    global ST_MAX_CHANNELS

    global USE_PACKET  
    global USE_CHANNEL  
    global USE_ERROR  
    global USE_READY
    global USE_VALID
    global USE_EMPTY
    global ST_BEATSPERCYCLE
    global ST_MAX_PACKET_SIZE

    set ST_SYMBOL_W_VALUE             [ get_parameter $ST_SYMBOL_W ]
    set ST_NUMSYMBOLS_VALUE           [ get_parameter $ST_NUMSYMBOLS ]
    set ST_CHANNEL_W_VALUE            [ get_parameter $ST_CHANNEL_W ]
    set ST_ERROR_W_VALUE              [ get_parameter $ST_ERROR_W ]
    set ST_EMPTY_W_VALUE              [ get_parameter $ST_EMPTY_W ]

    set ST_READY_LATENCY_VALUE        [ get_parameter $ST_READY_LATENCY ]
    set ST_MAX_CHANNELS_VALUE         [ get_parameter $ST_MAX_CHANNELS]
    set ST_BEATSPERCYCLE_VALUE        [ get_parameter $ST_BEATSPERCYCLE ]
    set ST_MAX_PACKET_SIZE_VALUE      [ get_parameter $ST_MAX_PACKET_SIZE ]

    set USE_PACKET_VALUE              [ get_parameter $USE_PACKET ]
    set USE_CHANNEL_VALUE             [ get_parameter $USE_CHANNEL ]
    set USE_ERROR_VALUE               [ get_parameter $USE_ERROR ]
    set USE_READY_VALUE               [ get_parameter $USE_READY ]
    set USE_VALID_VALUE               [ get_parameter $USE_VALID ]
    set USE_EMPTY_VALUE               [ get_parameter $USE_EMPTY ]

    set ST_DATA_W_VALUE               [expr $ST_SYMBOL_W_VALUE * $ST_NUMSYMBOLS_VALUE]
    set ST_MDATA_W_VALUE              [expr $ST_DATA_W_VALUE * $ST_BEATSPERCYCLE_VALUE]
    set ST_MCHANNEL_W_VALUE           [expr $ST_CHANNEL_W_VALUE * $ST_BEATSPERCYCLE_VALUE]
    set ST_MERROR_W_VALUE             [expr $ST_ERROR_W_VALUE * $ST_BEATSPERCYCLE_VALUE]
    set ST_MEMPTY_W_VALUE             [expr $ST_EMPTY_W_VALUE * $ST_BEATSPERCYCLE_VALUE]
    
    #---------------------------------------------------------------------
    # Clock-Reset connection point
    #---------------------------------------------------------------------
    set CLOCK_INTERFACE  "clk"
    add_interface $CLOCK_INTERFACE clock end

    set_interface_property $CLOCK_INTERFACE ENABLED true

    add_interface_port $CLOCK_INTERFACE clk clk Input 1
    add_interface_port $CLOCK_INTERFACE reset reset Input 1

    #---------------------------------------------------------------------
    #  Avalon Streaming Source connection point 
    #---------------------------------------------------------------------
    set SOURCE_INTERFACE "src"
    add_interface $SOURCE_INTERFACE avalon_streaming source

    set_interface_property $SOURCE_INTERFACE ENABLED true
    set_interface_property $SOURCE_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $SOURCE_INTERFACE dataBitsPerSymbol $ST_SYMBOL_W_VALUE
    set_interface_property $SOURCE_INTERFACE symbolsPerBeat $ST_NUMSYMBOLS_VALUE
    set_interface_property $SOURCE_INTERFACE errorDescriptor ""
    set_interface_property $SOURCE_INTERFACE maxChannel $ST_MAX_CHANNELS_VALUE
    set_interface_property $SOURCE_INTERFACE readyLatency $ST_READY_LATENCY_VALUE
    set_interface_property $SOURCE_INTERFACE beatsPerCycle $ST_BEATSPERCYCLE_VALUE

    add_interface_port $SOURCE_INTERFACE src_data data Output $ST_MDATA_W_VALUE
    set_port_property src_data VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_valid valid Output $ST_BEATSPERCYCLE_VALUE
    set_port_property src_valid VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_ready ready Input 1
    add_interface_port $SOURCE_INTERFACE src_startofpacket startofpacket Output $ST_BEATSPERCYCLE_VALUE
    set_port_property src_startofpacket VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_endofpacket endofpacket Output $ST_BEATSPERCYCLE_VALUE
    set_port_property src_endofpacket VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_empty empty Output $ST_MEMPTY_W_VALUE
    set_port_property src_empty VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_channel channel Output $ST_MCHANNEL_W_VALUE
    set_port_property src_channel VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_error error Output $ST_MERROR_W_VALUE
    set_port_property src_error VHDL_TYPE STD_LOGIC_VECTOR
    
    
    #---------------------------------------------------------------------
    #  Avalon Streaming Sink connection point 
    #---------------------------------------------------------------------
    set SINK_INTERFACE "sink"
    add_interface $SINK_INTERFACE avalon_streaming sink

    set_interface_property $SINK_INTERFACE ENABLED true
    set_interface_property $SINK_INTERFACE ASSOCIATED_CLOCK $CLOCK_INTERFACE
    set_interface_property $SINK_INTERFACE dataBitsPerSymbol $ST_SYMBOL_W_VALUE
    set_interface_property $SINK_INTERFACE symbolsPerBeat $ST_NUMSYMBOLS_VALUE
    set_interface_property $SINK_INTERFACE errorDescriptor ""
    set_interface_property $SINK_INTERFACE maxChannel $ST_MAX_CHANNELS_VALUE
    set_interface_property $SINK_INTERFACE readyLatency $ST_READY_LATENCY_VALUE

    add_interface_port $SINK_INTERFACE sink_data data Input $ST_MDATA_W_VALUE
    set_port_property sink_data VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SINK_INTERFACE sink_valid valid Input $ST_BEATSPERCYCLE_VALUE
    set_port_property sink_valid VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SINK_INTERFACE sink_ready ready Output 1
    add_interface_port $SINK_INTERFACE sink_startofpacket startofpacket Input $ST_BEATSPERCYCLE_VALUE
    set_port_property sink_startofpacket VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SINK_INTERFACE sink_endofpacket endofpacket Input $ST_BEATSPERCYCLE_VALUE
    set_port_property sink_endofpacket VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SINK_INTERFACE sink_empty empty Input $ST_MEMPTY_W_VALUE
    set_port_property sink_empty VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SINK_INTERFACE sink_channel channel Input $ST_MCHANNEL_W_VALUE
    set_port_property sink_channel VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SINK_INTERFACE sink_error error Input $ST_MERROR_W_VALUE
    set_port_property sink_error VHDL_TYPE STD_LOGIC_VECTOR

    #---------------------------------------------------------------------
    # teminate unused ports 
    #---------------------------------------------------------------------    
    if { $USE_VALID_VALUE == 0 } {  
    send_message Info "Use Valid set to zero - omitting valid ports"
    set_port_property src_valid TERMINATION 1
    set_port_property sink_valid TERMINATION 1
    set_port_property sink_valid TERMINATION_VALUE 1'b1
    }
    if { $USE_READY_VALUE == 0 } {  
    send_message Info "Use Ready set to zero - omitting ready ports"
    set_port_property src_ready TERMINATION 1
    set_port_property src_ready TERMINATION_VALUE 1'b1
    set_port_property sink_ready TERMINATION 1
    }
    if { $USE_PACKET_VALUE == 0 } {  
    send_message Info "Use Packets set to zero - omitting startofpacket, endofpacket and empty ports"
    set_port_property src_startofpacket TERMINATION 1
    set_port_property src_endofpacket TERMINATION 1
    set_port_property src_empty TERMINATION 1

    set_port_property sink_startofpacket TERMINATION 1
    set_port_property sink_endofpacket TERMINATION 1
    set_port_property sink_empty TERMINATION 1
    set_port_property sink_startofpacket TERMINATION_VALUE 1'b0
    set_port_property sink_endofpacket TERMINATION_VALUE 1'b0
    set_port_property sink_empty TERMINATION_VALUE 0
    
    set_parameter_property $USE_EMPTY ENABLED false
    } else {
    set_parameter_property $USE_EMPTY ENABLED true
    }
    if { $USE_EMPTY_VALUE == 0 } {   
    send_message Info "Use Empty set to zero - omitting empty ports"
    set_port_property src_empty TERMINATION 1
    set_port_property sink_empty TERMINATION 1
    set_port_property sink_empty TERMINATION_VALUE 0
    }
    if { $USE_CHANNEL_VALUE == 0 } { 
    send_message Info "Use Channels set to zero - omitting channel ports"
    set_port_property src_channel TERMINATION 1
    set_port_property sink_channel TERMINATION 1
    set_port_property sink_channel TERMINATION_VALUE 0
    set_parameter_property $ST_CHANNEL_W ENABLED false
    } else {
    set_parameter_property $ST_CHANNEL_W ENABLED true
    }

    if { $USE_ERROR_VALUE == 0 } {   
    send_message Info "Use Error set to zero - omitting error ports"
    set_port_property src_error TERMINATION 1
    set_port_property sink_error TERMINATION 1
    set_port_property sink_error TERMINATION_VALUE 0
    set_parameter_property $ST_ERROR_W ENABLED false
    } else {
    set_parameter_property $ST_ERROR_W ENABLED true
    }
}


