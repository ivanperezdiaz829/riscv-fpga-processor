# +-----------------------------------
# | 
# | altera_avalon_multi_channel_shared_fifo TCL Component Definition File v8.0
# | Altera Corporation 2008
# | 
# | The Avalon Streaming (Avalon-ST) Multi-Channel Shared Memory
# | FIFO core is a FIFO buffer with Avalon-ST data interfaces. The core,
# | which supports up to 16 channels, is a contiguous memory space with
# | dedicated segments of memory allocated for each channel. Data is
# | delivered to the output interface in the same order it was received on the
# | input interface for a given channel.
# |
# | Todo: this can greatly simplified this file
# | a. For parameters that accept only 1/0, change the data type to boolean
# |    whenever the feature is stable in next release. This can avoid doing 
# |    custom validation
# | b. Consider to use let SOPC Builder to infer/derive the parameter according
# |    to the HDL information whenever the feature is stable in next release.
# |    Currently we still need to derive the data_widht, channel_widht, empty_widht
# |    and other values to set the correct port widht and decide which port should 
# |    exist which should not. By specifying -1 as the port widht, some of the port 
# |    is derived correctly and some is not from my initial testing.
# |     
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.0
# | 
package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_multi_channel_shared_fifo
# | 
set_module_property NAME altera_avalon_multi_channel_shared_fifo
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Memories and Memory Controllers/On-Chip"
set_module_property DISPLAY_NAME "Avalon-ST Multi-Channel Shared Memory FIFO"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_multi_channel_shared_fifo.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_multi_channel_shared_fifo
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VERILOG false
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property SIMULATION_MODEL_HAS_TULIPS false
set_module_property SIMULATION_MODEL_IS_OBFUSCATED false
set_module_property previewValidationCallback "validate"
set_module_property previewElaborationCallback "elaborate"
set_module_property datasheetURL "http://www.altera.com/literature/hb/nios2/qts_qii55015.pdf"
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_avalon_multi_channel_shared_fifo.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter MAX_CHANNELS int 1
set_parameter_property MAX_CHANNELS DISPLAY_NAME "Number of channels"
set_parameter_property MAX_CHANNELS UNITS None
set_parameter_property MAX_CHANNELS AFFECTS_PORT_WIDTHS true
set_parameter_property MAX_CHANNELS ALLOWED_RANGES {1 2 4 8 16}
add_parameter SYMBOLS_PER_BEAT int 1
set_parameter_property SYMBOLS_PER_BEAT DISPLAY_NAME "Symbols per beat"
set_parameter_property SYMBOLS_PER_BEAT UNITS None
set_parameter_property SYMBOLS_PER_BEAT AFFECTS_PORT_WIDTHS true
add_parameter BITS_PER_SYMBOL int 8
set_parameter_property BITS_PER_SYMBOL DISPLAY_NAME "Bits per symbol"
set_parameter_property BITS_PER_SYMBOL UNITS bits
set_parameter_property BITS_PER_SYMBOL AFFECTS_PORT_WIDTHS true
add_parameter FIFO_DEPTH int 16
set_parameter_property FIFO_DEPTH DISPLAY_NAME "FIFO depth"
set_parameter_property FIFO_DEPTH UNITS None
set_parameter_property FIFO_DEPTH AFFECTS_PORT_WIDTHS true
add_parameter ADDR_WIDTH int 0
set_parameter_property ADDR_WIDTH DISPLAY_NAME "Address width"
set_parameter_property ADDR_WIDTH UNITS None
set_parameter_property ADDR_WIDTH AFFECTS_PORT_WIDTHS true
set_parameter_property ADDR_WIDTH DERIVED true
add_parameter ERROR_WIDTH int 0
set_parameter_property ERROR_WIDTH DISPLAY_NAME "Error width"
set_parameter_property ERROR_WIDTH UNITS None
set_parameter_property ERROR_WIDTH AFFECTS_PORT_WIDTHS true
set_parameter_update_callback ERROR_WIDTH update_error_width
add_parameter USE_REQUEST int 1
set_parameter_property USE_REQUEST DISPLAY_NAME "Use request"
set_parameter_property USE_REQUEST UNITS None
set_parameter_property USE_REQUEST AFFECTS_PORT_WIDTHS true
set_parameter_property USE_REQUEST DISPLAY_HINT "boolean"
add_parameter USE_ALMOST_FULL int 1
set_parameter_property USE_ALMOST_FULL DISPLAY_NAME "Use almost-full threshold 1"
set_parameter_property USE_ALMOST_FULL UNITS None
set_parameter_property USE_ALMOST_FULL AFFECTS_PORT_WIDTHS true
set_parameter_property USE_ALMOST_FULL DISPLAY_HINT "boolean"
set_parameter_update_callback USE_ALMOST_FULL update_use_almost_full
add_parameter USE_ALMOST_FULL2 int 1
set_parameter_property USE_ALMOST_FULL2 DISPLAY_NAME "Use almost-full threshold 2"
set_parameter_property USE_ALMOST_FULL2 UNITS None
set_parameter_property USE_ALMOST_FULL2 AFFECTS_PORT_WIDTHS true
set_parameter_property USE_ALMOST_FULL2 DISPLAY_HINT "boolean"
add_parameter USE_ALMOST_EMPTY int 0
set_parameter_property USE_ALMOST_EMPTY DISPLAY_NAME "Use almost-empty threshold 1"
set_parameter_property USE_ALMOST_EMPTY UNITS None
set_parameter_property USE_ALMOST_EMPTY AFFECTS_PORT_WIDTHS true
set_parameter_property USE_ALMOST_EMPTY DISPLAY_HINT "boolean"
set_parameter_update_callback USE_ALMOST_EMPTY update_use_almost_empty
add_parameter USE_ALMOST_EMPTY2 int 0
set_parameter_property USE_ALMOST_EMPTY2 DISPLAY_NAME "Use almost-empty threshold 2"
set_parameter_property USE_ALMOST_EMPTY2 UNITS None
set_parameter_property USE_ALMOST_EMPTY2 AFFECTS_PORT_WIDTHS true
set_parameter_property USE_ALMOST_EMPTY2 DISPLAY_HINT "boolean"
#Parameter with fix value
add_parameter USE_PACKETS int 1
set_parameter_property USE_PACKETS DISPLAY_NAME "Use packets"
set_parameter_property USE_PACKETS UNITS None
set_parameter_property USE_PACKETS AFFECTS_PORT_WIDTHS true
set_parameter_property USE_PACKETS VISIBLE false
add_parameter USE_FILL_LEVEL int 1
set_parameter_property USE_FILL_LEVEL DISPLAY_NAME "Use fill level"
set_parameter_property USE_FILL_LEVEL UNITS None
set_parameter_property USE_FILL_LEVEL AFFECTS_PORT_WIDTHS true
set_parameter_property USE_FILL_LEVEL VISIBLE false
add_parameter PACKET_BUFFER_MODE int 1
set_parameter_property PACKET_BUFFER_MODE DISPLAY_NAME "Packet buffer mode"
set_parameter_property PACKET_BUFFER_MODE UNITS None
set_parameter_property PACKET_BUFFER_MODE AFFECTS_PORT_WIDTHS true
set_parameter_property PACKET_BUFFER_MODE VISIBLE false
add_parameter SAV_THRESHOLD int 0
set_parameter_property SAV_THRESHOLD DISPLAY_NAME "Section available threshold"
set_parameter_property SAV_THRESHOLD UNITS None
set_parameter_property SAV_THRESHOLD AFFECTS_PORT_WIDTHS true
set_parameter_property SAV_THRESHOLD VISIBLE false
add_parameter DROP_ON_ERROR int 1
set_parameter_property DROP_ON_ERROR DISPLAY_NAME "Drop on error"
set_parameter_property DROP_ON_ERROR UNITS None
set_parameter_property DROP_ON_ERROR AFFECTS_PORT_WIDTHS true
set_parameter_property DROP_ON_ERROR VISIBLE false
set_parameter_property DROP_ON_ERROR DISPLAY_HINT "boolean"
add_parameter NUM_OF_ALMOST_FULL_THRESHOLD int 2
set_parameter_property NUM_OF_ALMOST_FULL_THRESHOLD DISPLAY_NAME "Number of almost-full thresholds"
set_parameter_property NUM_OF_ALMOST_FULL_THRESHOLD UNITS None
set_parameter_property NUM_OF_ALMOST_FULL_THRESHOLD AFFECTS_PORT_WIDTHS true
set_parameter_property NUM_OF_ALMOST_FULL_THRESHOLD VISIBLE false
add_parameter NUM_OF_ALMOST_EMPTY_THRESHOLD int 0
set_parameter_property NUM_OF_ALMOST_EMPTY_THRESHOLD DISPLAY_NAME "Number of almost-empty thresholds"
set_parameter_property NUM_OF_ALMOST_EMPTY_THRESHOLD UNITS None
set_parameter_property NUM_OF_ALMOST_EMPTY_THRESHOLD AFFECTS_PORT_WIDTHS true
set_parameter_property NUM_OF_ALMOST_EMPTY_THRESHOLD VISIBLE false
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters validation
# | 
proc validate {} {
   # dynamic value validation
   # ----------------------------------------------------------------- 
   set FIFO_DEPTH [ get_parameter_value "FIFO_DEPTH" ]
   set ADDR_WIDTH [ log2ceil $FIFO_DEPTH ]
   set_parameter_value "ADDR_WIDTH" $ADDR_WIDTH
   set real_depth [ expr (1 << $ADDR_WIDTH) ]
   if {$FIFO_DEPTH != $real_depth} {
      send_message "error" "The value of the parameter FIFO depth is invalid. The value must be a power of two"
   }
   
   set USE_ALMOST_FULL [ get_parameter_value "USE_ALMOST_FULL" ]
   set USE_ALMOST_EMPTY [ get_parameter_value "USE_ALMOST_EMPTY" ]
   set USE_ALMOST_FULL2 [ get_parameter_value "USE_ALMOST_FULL2" ]
   set USE_ALMOST_EMPTY2 [ get_parameter_value "USE_ALMOST_EMPTY2" ]
   if { [expr $USE_ALMOST_FULL == 0] } {
      set_parameter_property USE_ALMOST_FULL2 ENABLED false
   } else {
      set_parameter_property USE_ALMOST_FULL2 ENABLED true
   }
   if { [expr $USE_ALMOST_EMPTY == 0] } {
      set_parameter_property USE_ALMOST_EMPTY2 ENABLED false
   } else {
      set_parameter_property USE_ALMOST_EMPTY2 ENABLED true
   }
}
# | 
# +-----------------------------------

# +-----------------------------------
# | Interface elaboration
# | 
proc elaborate {} {
   # non-derived parameters
   # -----------------------------------------------------------------
   set SYMBOLS_PER_BEAT [ get_parameter_value "SYMBOLS_PER_BEAT" ]
   set BITS_PER_SYMBOL [ get_parameter_value "BITS_PER_SYMBOL" ]
   set ERROR_WIDTH [ get_parameter_value "ERROR_WIDTH" ]
   set MAX_CHANNELS [ get_parameter_value "MAX_CHANNELS" ]
   set FIFO_DEPTH [ get_parameter_value "FIFO_DEPTH" ]
   set USE_REQUEST [ get_parameter_value "USE_REQUEST" ]
   set USE_ALMOST_FULL [ get_parameter_value "USE_ALMOST_FULL" ]
   set USE_ALMOST_EMPTY [ get_parameter_value "USE_ALMOST_EMPTY" ]
   set USE_ALMOST_FULL2 [ get_parameter_value "USE_ALMOST_FULL2" ]
   set USE_ALMOST_EMPTY2 [ get_parameter_value "USE_ALMOST_EMPTY2" ]

   # derived parameters
   # -----------------------------------------------------------------
   set datawidth [ expr $SYMBOLS_PER_BEAT * $BITS_PER_SYMBOL]
   set empty_width [ log2ceil $SYMBOLS_PER_BEAT ]
   set channel_width [ log2ceil $MAX_CHANNELS ]
   if {$channel_width > 0} {
   } else {
	  set channel_width 1
   }

   # interface creation
   # -----------------------------------------------------------------
   # Interface clock
   add_interface "clock" "clock" "sink" "asynchronous"
   # Ports in interface clock
   add_interface_port "clock" "clk" "clk" "input" 1
   add_interface_port "clock" "reset_n" "reset_n" "input" 1

   # Interface out
   add_interface "out" "avalon_streaming" "source" "clock"
   set_interface_property "out" "symbolsPerBeat" $SYMBOLS_PER_BEAT
   set_interface_property "out" "dataBitsPerSymbol" $BITS_PER_SYMBOL
   set_interface_property "out" "readyLatency" "0"
   set_interface_property "out" "maxChannel" [ expr $MAX_CHANNELS - 1 ]
   # Ports in interface out
   add_interface_port "out" "out_data" "data" "output" $datawidth
   add_interface_port "out" "out_valid" "valid" "output" 1
   add_interface_port "out" "out_ready" "ready" "input" 1
   
   if { [expr $MAX_CHANNELS > 1] } {
	  add_interface_port "out" "out_channel" "channel" "output" $channel_width
   } 

   add_interface_port "out" "out_endofpacket" "endofpacket" "output" 1
   add_interface_port "out" "out_startofpacket" "startofpacket" "output" 1
   
   if { [expr $empty_width > 0] } {
	  add_interface_port "out" "out_empty" "empty" "output" $empty_width
   }

   if { [expr $ERROR_WIDTH > 0] } {
	  add_interface_port "out" "out_error" "error" "output" $ERROR_WIDTH
   }
   
   # Interface in
   add_interface "in" "avalon_streaming" "sink" "clock"
   set_interface_property "in" "symbolsPerBeat" $SYMBOLS_PER_BEAT
   set_interface_property "in" "dataBitsPerSymbol" $BITS_PER_SYMBOL
   set_interface_property "in" "readyLatency" "0"
   set_interface_property "in" "maxChannel"  [ expr $MAX_CHANNELS - 1 ]
   # Ports in interface in
   add_interface_port "in" "in_data" "data" "input" $datawidth
   add_interface_port "in" "in_valid" "valid" "input" 1
   add_interface_port "in" "in_ready" "ready" "output" 1
   
   if { [expr $MAX_CHANNELS > 1] } {
	  add_interface_port "in" "in_channel" "channel" "input" $channel_width
   }  

   add_interface_port "in" "in_endofpacket" "endofpacket" "input" 1
   add_interface_port "in" "in_startofpacket" "startofpacket" "input" 1
   
   if { [expr $empty_width > 0] } {
      add_interface_port "in" "in_empty" "empty" "input" $empty_width
   }	

   if { [expr $ERROR_WIDTH > 0] } {
	  add_interface_port "in" "in_error" "error" "input" $ERROR_WIDTH
   } 

   # Interface almost_full
   if { [expr $USE_ALMOST_FULL == 1] } {
	 add_interface "almost_full" "avalon_streaming" "source" "clock"
	 set_interface_property "almost_full" "symbolsPerBeat" 1
	 if { [expr $USE_ALMOST_FULL2 == 1] } {
		set_interface_property "almost_full" "dataBitsPerSymbol" 2
	 } else {
		set_interface_property "almost_full" "dataBitsPerSymbol" 1
	 }
	 set_interface_property "almost_full" "readyLatency" "0"
	 set_interface_property "almost_full" "maxChannel"  [ expr $MAX_CHANNELS - 1 ]
   # Ports in interface almost_full
	 add_interface_port "almost_full" "almost_full_channel" "channel" "output" $channel_width
	 add_interface_port "almost_full" "almost_full_valid" "valid" "output" 1
	 
	 if { [expr $USE_ALMOST_FULL2 == 1]} {
		add_interface_port "almost_full" "almost_full_data" "data" "output" 2
	 } else {
		add_interface_port "almost_full" "almost_full_data" "data" "output" 1
	 }
   }
   
   # Interface almost_empty
   if { [expr $USE_ALMOST_EMPTY == 1] } {
      add_interface "almost_empty" "avalon_streaming" "source" "clock"
      set_interface_property "almost_empty" "symbolsPerBeat" 1
	  if { [expr $USE_ALMOST_EMPTY2 == 1] } {
         set_interface_property "almost_empty" "dataBitsPerSymbol" 2
      } else {
	     set_interface_property "almost_empty" "dataBitsPerSymbol" 1
	  }
	  set_interface_property "almost_empty" "readyLatency" "0"
      set_interface_property "almost_empty" "maxChannel"  [ expr $MAX_CHANNELS - 1 ]
   
      # Ports in interface almost_empty
      add_interface_port "almost_empty" "almost_empty_channel" "channel" "output" $channel_width
      add_interface_port "almost_empty" "almost_empty_valid" "valid" "output" 1
      
	  if { [expr $USE_ALMOST_EMPTY2 == 1] } {
         add_interface_port "almost_empty" "almost_empty_data" "data" "output" 2
      } else {
         add_interface_port "almost_empty" "almost_empty_data" "data" "output" 1
      }
   }

   # Interface control
   add_interface "control" "avalon" "slave" "clock"
   set_interface_property "control" "isNonVolatileStorage" "false"
   set_interface_property "control" "burstOnBurstBoundariesOnly" "false"
   set_interface_property "control" "readLatency" "0"
   set_interface_property "control" "holdTime" "0"
   set_interface_property "control" "printableDevice" "false"
   set_interface_property "control" "readWaitTime" "1"
   set_interface_property "control" "setupTime" "0"
   set_interface_property "control" "addressAlignment" "DYNAMIC"
   set_interface_property "control" "writeWaitTime" "0"
   set_interface_property "control" "timingUnits" "Cycles"
   set_interface_property "control" "minimumUninterruptedRunLength" "1"
   set_interface_property "control" "isMemoryDevice" "false"
   set_interface_property "control" "linewrapBursts" "false"
   set_interface_property "control" "maximumPendingReadTransactions" "0"
   
   # Ports in interface control
   add_interface_port "control" "control_address" "address" "input" 2
   add_interface_port "control" "control_read" "read" "input" 1
   add_interface_port "control" "control_readdata" "readdata" "output" 32
   add_interface_port "control" "control_write" "write" "input" 1
   add_interface_port "control" "control_writedata" "writedata" "input" 32  

   # Interface fill_level
   add_interface "fill_level" "avalon" "slave" "clock"
   set_interface_property "fill_level" "isNonVolatileStorage" "false"
   set_interface_property "fill_level" "burstOnBurstBoundariesOnly" "false"
   set_interface_property "fill_level" "readLatency" "0"
   set_interface_property "fill_level" "holdTime" "0"
   set_interface_property "fill_level" "printableDevice" "false"
   set_interface_property "fill_level" "readWaitTime" "1"
   set_interface_property "fill_level" "setupTime" "0"
   set_interface_property "fill_level" "addressAlignment" "DYNAMIC"
   set_interface_property "fill_level" "writeWaitTime" "0"
   set_interface_property "fill_level" "timingUnits" "Cycles"
   set_interface_property "fill_level" "minimumUninterruptedRunLength" "1"
   set_interface_property "fill_level" "isMemoryDevice" "false"
   set_interface_property "fill_level" "linewrapBursts" "false"
   set_interface_property "fill_level" "maximumPendingReadTransactions" "0"
   
   # Ports in interface fill_level
   add_interface_port "fill_level" "status_address" "address" "input" 4
   add_interface_port "fill_level" "status_read" "read" "input" 1
   add_interface_port "fill_level" "status_readdata" "readdata" "output" 32
   
   # Interface request
   if {  [ expr $USE_REQUEST ==  1] } {
	  add_interface "request" "avalon" "slave" "clock"
	  set_interface_property "request" "isNonVolatileStorage" "false"
	  set_interface_property "request" "burstOnBurstBoundariesOnly" "false"
	  set_interface_property "request" "readLatency" "0"
	  set_interface_property "request" "holdTime" "0"
	  set_interface_property "request" "printableDevice" "false"
	  set_interface_property "request" "readWaitTime" "1"
	  set_interface_property "request" "setupTime" "0"
	  set_interface_property "request" "addressAlignment" "DYNAMIC"
	  set_interface_property "request" "writeWaitTime" "0"
	  set_interface_property "request" "timingUnits" "Cycles"
	  set_interface_property "request" "minimumUninterruptedRunLength" "1"
	  set_interface_property "request" "isMemoryDevice" "false"
	  set_interface_property "request" "linewrapBursts" "false"
	  set_interface_property "request" "maximumPendingReadTransactions" "0"
   # Ports in interface request
	  add_interface_port "request" "request_address" "address" "input" $channel_width
	  add_interface_port "request" "request_write" "write" "input" 1
	  add_interface_port "request" "request_writedata" "writedata" "input" 32	  
   }
   
   # Drop on error
   if { [expr $ERROR_WIDTH == 0] } {
      set_parameter_property DROP_ON_ERROR ENABLED false
   } else {
      set_parameter_property DROP_ON_ERROR ENABLED true
   }
} 

# | 
# +-----------------------------------

# +-----------------------------------
# | Update callback
# | 
proc update_use_almost_full {arg1} {
    set use_almost_full [get_parameter_value $arg1]

    if {$use_almost_full == 0} {
        set_parameter_value USE_ALMOST_FULL2 0
    }
}
# | 
# +-----------------------------------

proc update_use_almost_empty {arg1} {
    set use_almost_empty [get_parameter_value $arg1]

    if {$use_almost_empty == 0} {
        set_parameter_value USE_ALMOST_EMPTY2 0
    }
}

proc update_error_width {arg1} {
    set error_width [get_parameter_value $arg1]

    if {$error_width == 0} {
        set_parameter_value DROP_ON_ERROR 0
    }
}
# | 
# +-----------------------------------

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

