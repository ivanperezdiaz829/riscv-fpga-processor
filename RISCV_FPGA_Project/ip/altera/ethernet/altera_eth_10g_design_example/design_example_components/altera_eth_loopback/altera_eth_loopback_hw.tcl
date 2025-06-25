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


package require -exact sopc 11.0

set_module_property DESCRIPTION "Altera Ethernet Loopback"
set_module_property NAME altera_eth_loopback
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Interface Protocols/Ethernet/Example"
set_module_property DISPLAY_NAME "Ethernet Loopback"
set_module_property TOP_LEVEL_HDL_FILE altera_eth_loopback.v
set_module_property TOP_LEVEL_HDL_MODULE altera_eth_loopback
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE yes
set_module_property ANALYZE_HDL false

set_module_property ELABORATION_CALLBACK elaborate
set_module_property SIMULATION_MODEL_IN_VHDL true

add_file altera_eth_loopback.v {SYNTHESIS SIMULATION}

# Module parameters
add_parameter "SYMBOLS_PER_BEAT" "integer" "4" ""
set_parameter_property "SYMBOLS_PER_BEAT" "visible" "true"
set_parameter_property "SYMBOLS_PER_BEAT" "displayName" "SYMBOLS_PER_BEAT"
set_parameter_property "SYMBOLS_PER_BEAT" "derived" "false"
set_parameter_property "SYMBOLS_PER_BEAT" "HDL_PARAMETER" "true"

add_parameter "BITS_PER_SYMBOL" "integer" "8" ""
set_parameter_property "BITS_PER_SYMBOL" "visible" "true"
set_parameter_property "BITS_PER_SYMBOL" "displayName" "BITS_PER_SYMBOL"
set_parameter_property "BITS_PER_SYMBOL" "derived" "false"
set_parameter_property "BITS_PER_SYMBOL" "HDL_PARAMETER" "true"

add_parameter "ERROR_WIDTH" "integer" "1" ""
set_parameter_property "ERROR_WIDTH" "visible" "true"
set_parameter_property "ERROR_WIDTH" "displayName" "ERROR_WIDTH"
set_parameter_property "ERROR_WIDTH" "derived" "false"
set_parameter_property "ERROR_WIDTH" "HDL_PARAMETER" "true"

add_parameter "USE_PACKETS" "integer" "1" ""
set_parameter_property "USE_PACKETS" "visible" "true"
set_parameter_property "USE_PACKETS" "displayName" "USE_PACKETS"
set_parameter_property "USE_PACKETS" "derived" "false"
set_parameter_property "USE_PACKETS" "HDL_PARAMETER" "true"

add_parameter "NUM_OF_INPUT" "integer" "2" ""
set_parameter_property "NUM_OF_INPUT" "visible" "true"
set_parameter_property "NUM_OF_INPUT" "displayName" "NUM_OF_INPUT"
set_parameter_property "NUM_OF_INPUT" "derived" "false"
set_parameter_property "NUM_OF_INPUT" "HDL_PARAMETER" "false"

add_parameter "EMPTY_WIDTH" "integer" "0" ""
set_parameter_property "EMPTY_WIDTH" "visible" "true"
set_parameter_property "EMPTY_WIDTH" "displayName" "EMPTY_WIDTH"
set_parameter_property "EMPTY_WIDTH" "derived" "false"
set_parameter_property "EMPTY_WIDTH" "HDL_PARAMETER" "true"

proc validate {} {

   # non-derived parameters
   # -----------------------------------------------------------------
   
   set SYMBOLS_PER_BEAT [ get_parameter_value "SYMBOLS_PER_BEAT" ]
   set BITS_PER_SYMBOL [ get_parameter_value "BITS_PER_SYMBOL" ]
   set ERROR_WIDTH [ get_parameter_value "ERROR_WIDTH" ]
   set USE_PACKETS [ get_parameter_value "USE_PACKETS" ] 
   set NUM_OF_INPUT [ get_parameter_value "NUM_OF_INPUT" ]

   # derived parameters
   # -----------------------------------------------------------------
   set EMPTY_WIDTH [ log2ceil $SYMBOLS_PER_BEAT ]
   set_parameter_value "EMPTY_WIDTH" $EMPTY_WIDTH
    

}

proc elaborate {} {

   # non-derived parameters
   # -----------------------------------------------------------------
   
   set SYMBOLS_PER_BEAT [ get_parameter_value "SYMBOLS_PER_BEAT" ]
   set BITS_PER_SYMBOL [ get_parameter_value "BITS_PER_SYMBOL" ]
   set ERROR_WIDTH [ get_parameter_value "ERROR_WIDTH" ]
   set USE_PACKETS [ get_parameter_value "USE_PACKETS" ] 
   set NUM_OF_INPUT [ get_parameter_value "NUM_OF_INPUT" ]

   # derived parameters
   # -----------------------------------------------------------------
   
   set datawidth [ expr $SYMBOLS_PER_BEAT * $BITS_PER_SYMBOL ]
      
   set EMPTY_WIDTH [ log2ceil $SYMBOLS_PER_BEAT ]
    
   set address_width [ log2ceil $NUM_OF_INPUT ]

# Interface clock
add_interface "clock" "clock" "sink" "asynchronous"
# Ports in interface clock
add_interface_port "clock" "clk" "clk" "input" 1
add_interface_port "clock" "reset_n" "reset_n" "input" 1


# Interface control
add_interface "control" "avalon" "slave" "clock"
set_interface_property "control" "isNonVolatileStorage" "false"
set_interface_property "control" "burstOnBurstBoundariesOnly" "false"
set_interface_property "control" "readLatency" "1"
set_interface_property "control" "holdTime" "0"
set_interface_property "control" "printableDevice" "false"
set_interface_property "control" "readWaitTime" "0"
set_interface_property "control" "setupTime" "0"
set_interface_property "control" "addressAlignment" "DYNAMIC"
set_interface_property "control" "writeWaitTime" "0"
set_interface_property "control" "timingUnits" "Cycles"
set_interface_property "control" "minimumUninterruptedRunLength" "1"
set_interface_property "control" "isMemoryDevice" "false"
set_interface_property "control" "linewrapBursts" "false"
set_interface_property "control" "maximumPendingReadTransactions" "0"
# Ports in interface control
add_interface_port "control" "control_address" "address" "input" $address_width
add_interface_port "control" "control_write" "write" "input" 1
add_interface_port "control" "control_read" "read" "input" 1
add_interface_port "control" "control_readdata" "readdata" "output" 32
add_interface_port "control" "control_writedata" "writedata" "input" 32


# Interface avalon_streaming_sink
add_interface "avalon_streaming_sink" "avalon_streaming" "sink" "clock"
set_interface_property "avalon_streaming_sink" "symbolsPerBeat" "$SYMBOLS_PER_BEAT"
set_interface_property "avalon_streaming_sink" "dataBitsPerSymbol" "$BITS_PER_SYMBOL"
set_interface_property "avalon_streaming_sink" "readyLatency" "0"
set_interface_property "avalon_streaming_sink" "maxChannel" "0"
# Ports in interface avalon_streaming_sink
add_interface_port "avalon_streaming_sink" "in_data_0" "data" "input" $datawidth
add_interface_port "avalon_streaming_sink" "in_valid_0" "valid" "input" 1
add_interface_port "avalon_streaming_sink" "in_ready_0" "ready" "output" 1


if { [expr $USE_PACKETS == 1] } {
add_interface_port "avalon_streaming_sink" "in_startofpacket_0" "startofpacket" "input" 1
add_interface_port "avalon_streaming_sink" "in_endofpacket_0" "endofpacket" "input" 1


   if { [expr $EMPTY_WIDTH > 0] } {
      add_interface_port "avalon_streaming_sink" "in_empty_0" "empty" "input" $EMPTY_WIDTH
   }
}

if { [expr $ERROR_WIDTH > 0] } {
	add_interface_port "avalon_streaming_sink" "in_error_0" "error" "input" $ERROR_WIDTH
}

# Interface avalon_streaming_sink_1
add_interface "avalon_streaming_sink_1" "avalon_streaming" "sink" "clock"
set_interface_property "avalon_streaming_sink_1" "symbolsPerBeat" "$SYMBOLS_PER_BEAT"
set_interface_property "avalon_streaming_sink_1" "dataBitsPerSymbol" "$BITS_PER_SYMBOL"
set_interface_property "avalon_streaming_sink_1" "readyLatency" "0"
set_interface_property "avalon_streaming_sink_1" "maxChannel" "0"
# Ports in interface avalon_streaming_sink_1
add_interface_port "avalon_streaming_sink_1" "in_data_1" "data" "input" $datawidth
add_interface_port "avalon_streaming_sink_1" "in_valid_1" "valid" "input" 1
add_interface_port "avalon_streaming_sink_1" "in_ready_1" "ready" "output" 1


if { [expr $USE_PACKETS == 1] } {
add_interface_port "avalon_streaming_sink_1" "in_startofpacket_1" "startofpacket" "input" 1
add_interface_port "avalon_streaming_sink_1" "in_endofpacket_1" "endofpacket" "input" 1


   if { [expr $EMPTY_WIDTH > 0] } {
      add_interface_port "avalon_streaming_sink_1" "in_empty_1" "empty" "input" $EMPTY_WIDTH
   }
}

if { [expr $ERROR_WIDTH > 0] } {
add_interface_port "avalon_streaming_sink_1" "in_error_1" "error" "input" $ERROR_WIDTH
}

# Interface avalon_streaming_source
add_interface "avalon_streaming_source" "avalon_streaming" "source" "clock"
set_interface_property "avalon_streaming_source" "symbolsPerBeat" "$SYMBOLS_PER_BEAT"
set_interface_property "avalon_streaming_source" "dataBitsPerSymbol" "$BITS_PER_SYMBOL"
set_interface_property "avalon_streaming_source" "readyLatency" "0"
set_interface_property "avalon_streaming_source" "maxChannel" "0"
# Ports in interface avalon_streaming_source
add_interface_port "avalon_streaming_source" "out_data" "data" "output" $datawidth
add_interface_port "avalon_streaming_source" "out_valid" "valid" "output" 1
add_interface_port "avalon_streaming_source" "out_ready" "ready" "input" 1


if { [expr $USE_PACKETS == 1] } {
add_interface_port "avalon_streaming_source" "out_startofpacket" "startofpacket" "output" 1
add_interface_port "avalon_streaming_source" "out_endofpacket" "endofpacket" "output" 1

   if { [expr $EMPTY_WIDTH > 0] } {
      add_interface_port "avalon_streaming_source" "out_empty" "empty" "output" $EMPTY_WIDTH
   }
}

if { [expr $ERROR_WIDTH > 0] } {
add_interface_port "avalon_streaming_source" "out_error" "error" "output" $ERROR_WIDTH
}

}




# +-----------------------------------
# | Utility funcitons
# | 
proc log2ceil {num} {

    set val 0
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }

    return $val;
}
# | 
# +-----------------------------------
