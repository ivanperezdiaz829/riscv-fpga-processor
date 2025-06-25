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


# $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_st_source_bfm/altera_avalon_st_source_bfm_api_wrapper_hw.tcl#1 $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
#------------------------------------------------------------------------------
package require -exact sopc 9.1

set_module_property DESCRIPTION                    "Altera Avalon ST Source BFM with Avalon ST API Wrapper"
set_module_property NAME                           altera_avalon_st_source_bfm_api_wrapper
set_module_property VERSION                        13.1
set_module_property GROUP                          "Avalon Verification Suite"
set_module_property AUTHOR                         "Altera Corporation"
set_module_property DISPLAY_NAME                   "Altera Avalon ST Source BFM with Avalon ST API Wrapper"
set_module_property TOP_LEVEL_HDL_FILE             altera_avalon_st_source_bfm_api_wrapper.sv
set_module_property TOP_LEVEL_HDL_MODULE           altera_avalon_st_source_bfm_api_wrapper
set_module_property INSTANTIATE_IN_SYSTEM_MODULE   true
set_module_property EDITABLE                       false
set_module_property INTERNAL                       true
set_module_property ELABORATION_CALLBACK           elaborate
set_module_property VALIDATION_CALLBACK            validate
set_module_property ANALYZE_HDL                    false

#---------------------------------------------------------------------
# Files
#---------------------------------------------------------------------

add_fileset simulation_verilog SIM_VERILOG sim_ver
add_fileset simulation_vhdl SIM_VHDL sim_vhd

proc sim_ver {name} {
   set HDL_LIB_DIR "../lib"
   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv" 
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG PATH "$HDL_LIB_DIR/verbosity_pkg.sv" 
   add_fileset_file altera_avalon_st_source_bfm.sv SYSTEM_VERILOG PATH "altera_avalon_st_source_bfm.sv" 
   add_fileset_file altera_avalon_st_source_bfm_api_wrapper.sv SYSTEM_VERILOG PATH "altera_avalon_st_source_bfm_api_wrapper.sv" 
}

proc sim_vhd {name} {
   set HDL_LIB_DIR "../lib"
   if {1} {
      add_fileset_file mentor/avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/avalon_utilities_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/mentor/verbosity_pkg.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_st_source_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_source_bfm.sv" {MENTOR_SPECIFIC}
      add_fileset_file mentor/altera_avalon_st_source_bfm_api_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "mentor/altera_avalon_st_source_bfm_api_wrapper.sv" {MENTOR_SPECIFIC}
   }

   add_fileset_file avalon_utilities_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/avalon_utilities_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file verbosity_pkg.sv SYSTEM_VERILOG_ENCRYPT PATH "$HDL_LIB_DIR/verbosity_pkg.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_st_source_bfm.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_st_source_bfm.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}
   add_fileset_file altera_avalon_st_source_bfm_api_wrapper.sv SYSTEM_VERILOG_ENCRYPT PATH "altera_avalon_st_source_bfm_api_wrapper.sv" {ALDEC_SPECIFIC CADENCE_SPECIFIC SYNOPSYS_SPECIFIC}

}

add_documentation_link "User Guide" "http://www.altera.com/literature/ug/ug_avalon_verification_ip.pdf"
#---------------------------------------------------------------------
# Parameters
#---------------------------------------------------------------------
set ST_SYMBOL_W       "ST_SYMBOL_W"
set ST_NUMSYMBOLS     "ST_NUMSYMBOLS"
set ST_CHANNEL_W      "ST_CHANNEL_W"
set ST_ERROR_W        "ST_ERROR_W"
set ST_EMPTY_W        "ST_EMPTY_W"
set USE_PACKET        "USE_PACKET"
set USE_CHANNEL       "USE_CHANNEL"
set USE_ERROR         "USE_ERROR"
set USE_READY         "USE_READY"
set USE_VALID         "USE_VALID"
set USE_EMPTY         "USE_EMPTY"
set ST_READY_LATENCY  "ST_READY_LATENCY"
set ST_MAX_CHANNELS   "ST_MAX_CHANNELS"

set API_CALL_DATA_W           "API_CALL_DATA_W"
set API_RETURN_DATA_W         "API_RETURN_DATA_W"

add_parameter $USE_PACKET Integer 0 
set_parameter_property $USE_PACKET DISPLAY_NAME "Include the ports supporting packets."
set_parameter_property $USE_PACKET AFFECTS_ELABORATION true
set_parameter_property $USE_PACKET DESCRIPTION "Enables the use of start and end of packet interface ports."
set_parameter_property $USE_PACKET HDL_PARAMETER true
set_parameter_property $USE_PACKET DISPLAY_HINT boolean

add_parameter $USE_CHANNEL Integer 0 
set_parameter_property $USE_CHANNEL DISPLAY_NAME "Use the channel signal"
set_parameter_property $USE_CHANNEL AFFECTS_ELABORATION true
set_parameter_property $USE_CHANNEL DESCRIPTION "Use the channel signal"
set_parameter_property $USE_CHANNEL HDL_PARAMETER true
set_parameter_property $USE_CHANNEL DISPLAY_HINT boolean

add_parameter $USE_ERROR Integer 0 
set_parameter_property $USE_ERROR DISPLAY_NAME "Use the error signal"
set_parameter_property $USE_ERROR AFFECTS_ELABORATION true
set_parameter_property $USE_ERROR DESCRIPTION "Use the error signal"
set_parameter_property $USE_ERROR HDL_PARAMETER true
set_parameter_property $USE_ERROR DISPLAY_HINT boolean

add_parameter $USE_READY Integer 1 
set_parameter_property $USE_READY DISPLAY_NAME "Use the ready signal"
set_parameter_property $USE_READY AFFECTS_ELABORATION true
set_parameter_property $USE_READY DESCRIPTION "Use the ready signal"
set_parameter_property $USE_READY HDL_PARAMETER true
set_parameter_property $USE_READY DISPLAY_HINT boolean

add_parameter $USE_VALID Integer 1 
set_parameter_property $USE_VALID DISPLAY_NAME "Use the valid signal"
set_parameter_property $USE_VALID AFFECTS_ELABORATION true
set_parameter_property $USE_VALID DESCRIPTION "Use the valid port"
set_parameter_property $USE_VALID HDL_PARAMETER true
set_parameter_property $USE_VALID DISPLAY_HINT boolean

add_parameter $USE_EMPTY Integer 0 
set_parameter_property $USE_EMPTY DISPLAY_NAME "Use the empty signal"
set_parameter_property $USE_EMPTY AFFECTS_ELABORATION true
set_parameter_property $USE_EMPTY DESCRIPTION "Use the empty signal"
set_parameter_property $USE_EMPTY HDL_PARAMETER true
set_parameter_property $USE_EMPTY DISPLAY_HINT boolean

add_parameter $ST_SYMBOL_W Positive 8 
set_parameter_property $ST_SYMBOL_W DISPLAY_NAME "Symbol width"
set_parameter_property $ST_SYMBOL_W AFFECTS_ELABORATION true
set_parameter_property $ST_SYMBOL_W HDL_PARAMETER true
set_parameter_property $ST_SYMBOL_W DESCRIPTION "Symbol width (bits) "
set_parameter_property $ST_SYMBOL_W ALLOWED_RANGES {1:1024}

add_parameter $ST_NUMSYMBOLS Positive 4 
set_parameter_property $ST_NUMSYMBOLS DISPLAY_NAME "Number of Symbols"
set_parameter_property $ST_NUMSYMBOLS AFFECTS_ELABORATION true
set_parameter_property $ST_NUMSYMBOLS HDL_PARAMETER true
set_parameter_property $ST_NUMSYMBOLS DESCRIPTION "Number of symbols"
set_parameter_property $ST_NUMSYMBOLS ALLOWED_RANGES {1:1024}

add_parameter $ST_CHANNEL_W Positive 1 
set_parameter_property $ST_CHANNEL_W DISPLAY_NAME "Width of the channel signal"
set_parameter_property $ST_CHANNEL_W AFFECTS_ELABORATION true
set_parameter_property $ST_CHANNEL_W HDL_PARAMETER true
set_parameter_property $ST_CHANNEL_W DESCRIPTION "Width of the channel signal"
set_parameter_property $ST_CHANNEL_W ALLOWED_RANGES {1:32}

add_parameter $ST_ERROR_W Positive 1 
set_parameter_property $ST_ERROR_W DISPLAY_NAME "Width of the error signal"
set_parameter_property $ST_ERROR_W AFFECTS_ELABORATION true
set_parameter_property $ST_ERROR_W HDL_PARAMETER true
set_parameter_property $ST_ERROR_W DESCRIPTION "Width of the error signal"
set_parameter_property $ST_ERROR_W ALLOWED_RANGES {1:1024}

add_parameter $ST_EMPTY_W Positive 1 
set_parameter_property $ST_EMPTY_W DISPLAY_NAME "Width of the empty signal"
set_parameter_property $ST_EMPTY_W DERIVED true
set_parameter_property $ST_EMPTY_W AFFECTS_ELABORATION true
set_parameter_property $ST_EMPTY_W HDL_PARAMETER true
set_parameter_property $ST_EMPTY_W DESCRIPTION "Empty word width in bits"
set_parameter_property $ST_EMPTY_W ALLOWED_RANGES {1:1024}

add_parameter $ST_READY_LATENCY Integer 0 
set_parameter_property $ST_READY_LATENCY DISPLAY_NAME "Ready latency"
set_parameter_property $ST_READY_LATENCY AFFECTS_ELABORATION true
set_parameter_property $ST_READY_LATENCY HDL_PARAMETER true
set_parameter_property $ST_READY_LATENCY DESCRIPTION "Ready latency"
set_parameter_property $ST_READY_LATENCY ALLOWED_RANGES {0:8}

add_parameter $ST_MAX_CHANNELS Integer 1 
set_parameter_property $ST_MAX_CHANNELS DISPLAY_NAME "Max Channel Number"
set_parameter_property $ST_MAX_CHANNELS AFFECTS_ELABORATION true
set_parameter_property $ST_MAX_CHANNELS HDL_PARAMETER true
set_parameter_property $ST_MAX_CHANNELS DESCRIPTION "Maximum number of channels supported"

add_parameter $API_CALL_DATA_W Integer 64
set_parameter_property $API_CALL_DATA_W DISPLAY_NAME "Width of API interface data signal"
set_parameter_property $API_CALL_DATA_W AFFECTS_ELABORATION true
set_parameter_property $API_CALL_DATA_W DESCRIPTION "Width of API interface data signal.  This is the maximum bit width of all the API method call arguments."
set_parameter_property $API_CALL_DATA_W HDL_PARAMETER true
set_parameter_property $API_CALL_DATA_W GROUP "API Streaming Interface"

add_parameter $API_RETURN_DATA_W Integer 64
set_parameter_property $API_RETURN_DATA_W DISPLAY_NAME "Width of API Return interface data signal"
set_parameter_property $API_RETURN_DATA_W AFFECTS_ELABORATION true
set_parameter_property $API_RETURN_DATA_W DESCRIPTION "Width of API return interface data signal.  This is the maximum bit width of all the API method return values."
set_parameter_property $API_RETURN_DATA_W HDL_PARAMETER true
set_parameter_property $API_RETURN_DATA_W GROUP "API Streaming Interface"

#------------------------------------------------------------------------------
# logarithm to base 2
#---------------------------------------------------------------------
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
    global API_CALL_DATA_W

    if {[get_parameter $ST_NUMSYMBOLS] > 1} {
	set_parameter_value $ST_EMPTY_W [clog2 [get_parameter $ST_NUMSYMBOLS]]
    }
    if { [get_parameter $USE_EMPTY] == 1 && [get_parameter $USE_PACKET] == 0 } {
	send_message error "The empty port can only be used with the packet ports."
    }
    if {[get_parameter $USE_CHANNEL] > 0} {
	if {[get_parameter $ST_MAX_CHANNELS] > [expr 1 << [get_parameter $ST_CHANNEL_W]]} {
	    send_message error "ST_MAX_CHANNELS may not be greater than ST_CHANNEL_W ** 2."
	}
    }
    if { [get_parameter $API_CALL_DATA_W] < 64 } {
	send_message error "API_CALL_DATA_W must be equal or greater than 64"
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

    global API_CALL_DATA_W
    global API_RETURN_DATA_W

    set ST_SYMBOL_W_VALUE      [ get_parameter $ST_SYMBOL_W ]
    set ST_NUMSYMBOLS_VALUE    [ get_parameter $ST_NUMSYMBOLS ]
    set ST_CHANNEL_W_VALUE     [ get_parameter $ST_CHANNEL_W ]
    set ST_ERROR_W_VALUE       [ get_parameter $ST_ERROR_W ]
    set ST_EMPTY_W_VALUE       [ get_parameter $ST_EMPTY_W ]

    set ST_READY_LATENCY_VALUE [ get_parameter $ST_READY_LATENCY ]
    set ST_MAX_CHANNELS_VALUE  [ get_parameter $ST_MAX_CHANNELS]

    set USE_PACKET_VALUE       [ get_parameter $USE_PACKET ]
    set USE_CHANNEL_VALUE      [ get_parameter $USE_CHANNEL ]
    set USE_ERROR_VALUE        [ get_parameter $USE_ERROR ]
    set USE_READY_VALUE        [ get_parameter $USE_READY ]
    set USE_VALID_VALUE        [ get_parameter $USE_VALID ]
    set USE_EMPTY_VALUE        [ get_parameter $USE_EMPTY ]

    set API_CALL_DATA_W_VALUE     	[ get_parameter $API_CALL_DATA_W ] 
    set API_RETURN_DATA_W_VALUE         [ get_parameter $API_RETURN_DATA_W ]

    set ST_DATA_W_VALUE [expr $ST_SYMBOL_W_VALUE * $ST_NUMSYMBOLS_VALUE]

    #---------------------------------------------------------------------
    # Clock-Reset connection point
    #---------------------------------------------------------------------
    set AV_CLOCK_INTERFACE  "av_clk"
    add_interface $AV_CLOCK_INTERFACE clock end

    set_interface_property $AV_CLOCK_INTERFACE ENABLED true

    add_interface_port $AV_CLOCK_INTERFACE av_clk clk Input 1
    add_interface_port $AV_CLOCK_INTERFACE av_reset reset Input 1

    #---------------------------------------------------------------------
    #  Avalon Streaming Source connection point 
    #---------------------------------------------------------------------
    set SOURCE_INTERFACE "src"
    add_interface $SOURCE_INTERFACE avalon_streaming source

    set_interface_property $SOURCE_INTERFACE ENABLED true
    set_interface_property $SOURCE_INTERFACE ASSOCIATED_CLOCK $AV_CLOCK_INTERFACE

    set_interface_property $SOURCE_INTERFACE dataBitsPerSymbol $ST_SYMBOL_W_VALUE
    set_interface_property $SOURCE_INTERFACE symbolsPerBeat $ST_NUMSYMBOLS_VALUE
    set_interface_property $SOURCE_INTERFACE errorDescriptor ""
    set_interface_property $SOURCE_INTERFACE maxChannel $ST_MAX_CHANNELS_VALUE
    set_interface_property $SOURCE_INTERFACE readyLatency $ST_READY_LATENCY_VALUE

    #---------------------------------------------------------------------
    # add ports to interface
    #---------------------------------------------------------------------    
    add_interface_port $SOURCE_INTERFACE src_data data Output $ST_DATA_W_VALUE
    set_port_property src_data VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_valid valid Output 1
    add_interface_port $SOURCE_INTERFACE src_ready ready Input 1
    add_interface_port $SOURCE_INTERFACE src_startofpacket startofpacket Output 1
    add_interface_port $SOURCE_INTERFACE src_endofpacket endofpacket Output 1
    add_interface_port $SOURCE_INTERFACE src_empty empty Output $ST_EMPTY_W_VALUE
    set_port_property src_empty VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_channel channel Output $ST_CHANNEL_W_VALUE
    set_port_property src_channel VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $SOURCE_INTERFACE src_error error Output $ST_ERROR_W_VALUE
    set_port_property src_error VHDL_TYPE STD_LOGIC_VECTOR
    #---------------------------------------------------------------------
    # Terminate unused ports 
    #---------------------------------------------------------------------    
    if { $USE_VALID_VALUE == 0 } {  
	send_message Info "Use Valid set to zero - omitting src_valid port"
	set_port_property src_valid TERMINATION 1
    }
    if { $USE_READY_VALUE == 0 } {  
	send_message Info "Use Ready set to zero - omitting src_ready port"
	set_port_property src_ready TERMINATION 1
	set_port_property src_ready TERMINATION_VALUE 1'b1
    }
    if { $USE_PACKET_VALUE == 0 } {  
	send_message Info "Use Packets set to zero - omitting src_startofpacket, src_endofpacket and src_empty ports"
	set_port_property src_startofpacket TERMINATION 1
	set_port_property src_endofpacket TERMINATION 1
	set_port_property src_empty TERMINATION 1
    }
    if { $USE_EMPTY_VALUE == 0 } {   
	send_message Info "Use Empty set to zero - omitting src_empty port"
	set_port_property src_empty TERMINATION 1
    }
    if { $USE_CHANNEL_VALUE == 0 } { 
	send_message Info "Use Channels set to zero - omitting src_channel port"
	set_port_property src_channel TERMINATION 1
    }
    if { $USE_ERROR_VALUE == 0 } {   
	send_message Info "Use Error set to zero - omitting src_error port"
	set_port_property src_error TERMINATION 1
    }


    #---------------------------------------------------------------------
    # API Clock-Reset connection point
    #---------------------------------------------------------------------
    set API_CLOCK_INTERFACE   "api_clk"
    add_interface $API_CLOCK_INTERFACE clock end
    add_interface_port $API_CLOCK_INTERFACE api_clk   clk   Input 1
    add_interface_port $API_CLOCK_INTERFACE api_reset reset Input 1

    #---------------------------------------------------------------------
    #  API Event Source connection point 
    #---------------------------------------------------------------------
    set API_EVENT_INTERFACE "api_event"
    add_interface $API_EVENT_INTERFACE avalon_streaming source

    set_interface_property $API_EVENT_INTERFACE ENABLED true
    set_interface_property $API_EVENT_INTERFACE ASSOCIATED_CLOCK $API_CLOCK_INTERFACE

    set_interface_property $API_EVENT_INTERFACE dataBitsPerSymbol 8
    set_interface_property $API_EVENT_INTERFACE symbolsPerBeat 1
    set_interface_property $API_EVENT_INTERFACE errorDescriptor ""
    set_interface_property $API_EVENT_INTERFACE maxChannel 0
    set_interface_property $API_EVENT_INTERFACE readyLatency 0

    add_interface_port $API_EVENT_INTERFACE api_event_data  data  Output 8
    add_interface_port $API_EVENT_INTERFACE api_event_valid valid Output 1

    #---------------------------------------------------------------------
    #  API Return Source connection point 
    #---------------------------------------------------------------------
    set API_RETURN "api_return"
    add_interface $API_RETURN avalon_streaming source

    set_interface_property $API_RETURN ENABLED true
    set_interface_property $API_RETURN ASSOCIATED_CLOCK $API_CLOCK_INTERFACE

    set_interface_property $API_RETURN dataBitsPerSymbol $API_RETURN_DATA_W_VALUE
    set_interface_property $API_RETURN symbolsPerBeat 1
    set_interface_property $API_RETURN errorDescriptor ""
    set_interface_property $API_RETURN maxChannel 128
    set_interface_property $API_RETURN readyLatency 0

    add_interface_port $API_RETURN api_return_data   data    Output $API_RETURN_DATA_W_VALUE
    set_port_property api_return_data VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $API_RETURN api_return_valid  valid   Output 1
    add_interface_port $API_RETURN api_return_method channel Output 8


    #---------------------------------------------------------------------
    #  API Call Sink connection point 
    #---------------------------------------------------------------------
    set API_CALL "api_call"
    add_interface $API_CALL avalon_streaming sink

    set_interface_property $API_CALL ENABLED true
    set_interface_property $API_CALL ASSOCIATED_CLOCK $API_CLOCK_INTERFACE
    set_interface_property $API_CALL dataBitsPerSymbol $API_CALL_DATA_W_VALUE
    set_interface_property $API_CALL symbolsPerBeat 1
    set_interface_property $API_CALL errorDescriptor ""
    set_interface_property $API_CALL maxChannel 128
    set_interface_property $API_CALL readyLatency 0

    add_interface_port $API_CALL api_call_data data Input $API_CALL_DATA_W_VALUE
    set_port_property api_call_data VHDL_TYPE STD_LOGIC_VECTOR
    add_interface_port $API_CALL api_call_valid valid Input 1
    add_interface_port $API_CALL api_call_method channel Input 8

}


