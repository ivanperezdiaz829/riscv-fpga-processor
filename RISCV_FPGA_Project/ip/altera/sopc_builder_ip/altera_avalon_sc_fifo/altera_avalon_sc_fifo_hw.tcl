#+---------------------------------
#|
#| Avalon-ST SCFIFO component description
#|
#+---------------------------------
package require -exact sopc 9.1

set_module_property NAME altera_avalon_sc_fifo
set_module_property DISPLAY_NAME "Avalon-ST Single Clock FIFO"
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Memories and Memory Controllers/On-Chip"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_sc_fifo.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_sc_fifo
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property VERSION 13.1
set_module_property EDITABLE false
set_module_property DATASHEET_URL "http://www.altera.com/literature/hb/nios2/qts_qii55014.pdf"
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property ANALYZE_HDL FALSE
set_module_assignment debug.isTransparent 1

# +-----------------------------------
# | callbacks
# |
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK  validate

# +-----------------------------------
# | files
# |
add_file "altera_avalon_sc_fifo.v" {SYNTHESIS SIMULATION}

# +-----------------------------------
# | parameters
# |
add_parameter SYMBOLS_PER_BEAT    INTEGER 1  ""
add_parameter BITS_PER_SYMBOL     INTEGER 8  ""
add_parameter FIFO_DEPTH          INTEGER 16 ""
add_parameter CHANNEL_WIDTH       INTEGER 0  ""
add_parameter ERROR_WIDTH         INTEGER 0  ""
add_parameter USE_PACKETS         INTEGER 0  ""
add_parameter USE_FILL_LEVEL      INTEGER 0  ""
add_parameter EMPTY_LATENCY       INTEGER 3  ""
add_parameter USE_MEMORY_BLOCKS   INTEGER 1  ""
add_parameter USE_STORE_FORWARD   INTEGER 0  ""
add_parameter USE_ALMOST_FULL_IF  INTEGER 0  ""
add_parameter USE_ALMOST_EMPTY_IF INTEGER 0  ""
add_parameter ENABLE_EXPLICIT_MAXCHANNEL BOOLEAN false
add_parameter EXPLICIT_MAXCHANNEL INTEGER 0  ""

# +-----------------------------------
# | display names and hints
# |
set_parameter_property SYMBOLS_PER_BEAT  DISPLAY_NAME "Symbols per beat"
set_parameter_property BITS_PER_SYMBOL   DISPLAY_NAME "Bits per symbol"
set_parameter_property FIFO_DEPTH        DISPLAY_NAME "FIFO depth"
set_parameter_property CHANNEL_WIDTH     DISPLAY_NAME "Channel width"
set_parameter_property ERROR_WIDTH       DISPLAY_NAME "Error width"
set_parameter_property USE_PACKETS       DISPLAY_NAME "Use packets"
set_parameter_property USE_FILL_LEVEL    DISPLAY_NAME "Use fill level"
set_parameter_property EMPTY_LATENCY     DISPLAY_NAME "Latency"
set_parameter_property USE_MEMORY_BLOCKS DISPLAY_NAME "Use memory blocks"
set_parameter_property USE_STORE_FORWARD   DISPLAY_NAME "Use store and forward"
set_parameter_property USE_ALMOST_FULL_IF  DISPLAY_NAME "Use almost full status"
set_parameter_property USE_ALMOST_EMPTY_IF DISPLAY_NAME "Use almost empty status"
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DISPLAY_NAME "Enable explicit maxChannel"
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DESCRIPTION  "Enable explicit maxChannel"
set_parameter_property EXPLICIT_MAXCHANNEL        DISPLAY_NAME "Explicit maxChannel"
set_parameter_property EXPLICIT_MAXCHANNEL        DESCRIPTION  "Explicit maxChannel"

set_parameter_property USE_PACKETS       DISPLAY_HINT "boolean"
set_parameter_property USE_FILL_LEVEL    DISPLAY_HINT "boolean"
set_parameter_property USE_MEMORY_BLOCKS DISPLAY_HINT "boolean"
set_parameter_property USE_STORE_FORWARD    DISPLAY_HINT "boolean"
set_parameter_property USE_ALMOST_FULL_IF   DISPLAY_HINT "boolean"
set_parameter_property USE_ALMOST_EMPTY_IF  DISPLAY_HINT "boolean"

set_parameter_property EMPTY_LATENCY     VISIBLE      "false"
set_parameter_property USE_MEMORY_BLOCKS VISIBLE      "false"

set_parameter_property SYMBOLS_PER_BEAT    IS_HDL_PARAMETER true
set_parameter_property BITS_PER_SYMBOL     IS_HDL_PARAMETER true
set_parameter_property FIFO_DEPTH          IS_HDL_PARAMETER true
set_parameter_property CHANNEL_WIDTH       IS_HDL_PARAMETER true
set_parameter_property ERROR_WIDTH         IS_HDL_PARAMETER true
set_parameter_property USE_PACKETS         IS_HDL_PARAMETER true
set_parameter_property USE_FILL_LEVEL      IS_HDL_PARAMETER true
set_parameter_property USE_STORE_FORWARD   IS_HDL_PARAMETER true
set_parameter_property EMPTY_LATENCY       IS_HDL_PARAMETER true
set_parameter_property USE_MEMORY_BLOCKS   IS_HDL_PARAMETER true
set_parameter_property USE_ALMOST_FULL_IF  IS_HDL_PARAMETER true
set_parameter_property USE_ALMOST_EMPTY_IF IS_HDL_PARAMETER true


proc log2ceil {num} {

    set val 0
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }

    return $val;
}

#+---------------------------------
#| 
#| Ensures that the FIFO depth is a power of two when
#| it uses embedded memory blocks, otherwise errors 
#| out with size recommendation.
#|
proc validate {} {

    set required_depth [ get_parameter_value "FIFO_DEPTH" ]
    set addr_width     [ log2ceil $required_depth ]
    set real_depth     [ expr (1 << $addr_width) ]
    set uses_memory    [ get_parameter_value "USE_MEMORY_BLOCKS" ]
    set use_fill_level   [ get_parameter_value "USE_FILL_LEVEL" ]
    set use_almost_full  [ get_parameter_value "USE_ALMOST_FULL_IF" ]
    set use_almost_empty [ get_parameter_value "USE_ALMOST_EMPTY_IF" ]
    set use_store_forward [ get_parameter_value "USE_STORE_FORWARD" ]

    if { $uses_memory } {
        if { $required_depth != $real_depth } {
            send_message "error" "FIFO depth must be a power of two ($real_depth would be acceptable)"
        }
    }

    if { $uses_memory == 0 } {
        if { $use_store_forward == 1 } {
            send_message "error" "can not use store and foward feature with Register mode of the FIFO; need to use memory blocks"
        }
    }

    if { $use_fill_level == 0 } {
        if { $use_almost_full == 1 } {
            send_message "error" "must use fill level in order to use almost full status"
        }
    }

    if { $use_fill_level == 0 } {
        if { $use_almost_empty == 1 } {
            send_message "error" "must use fill level in order to use almost empty status"
        }
    }

    if { $use_fill_level == 0 } {
        if { $use_store_forward == 1 } {
            send_message "error" "must use fill level in order to use store and forward feature"
        }
    }
}

proc elaborate {} {

    set use_fill_level   [ get_parameter_value "USE_FILL_LEVEL" ]
    set symbols_per_beat [ get_parameter_value "SYMBOLS_PER_BEAT" ]
    set bits_per_symbol  [ get_parameter_value "BITS_PER_SYMBOL" ]
    set data_width       [ expr $symbols_per_beat * $bits_per_symbol ]
    set channel_width    [ get_parameter_value "CHANNEL_WIDTH" ]
    set max_channel      [ expr (1 << $channel_width) - 1 ]
    set empty_width      [ log2ceil $symbols_per_beat ] 
    set error_width      [ get_parameter_value "ERROR_WIDTH" ]
    set use_packets      [ get_parameter_value "USE_PACKETS" ]
    set use_almost_full  [ get_parameter_value "USE_ALMOST_FULL_IF" ]
    set use_almost_empty [ get_parameter_value "USE_ALMOST_EMPTY_IF" ]
    set use_store_forward [ get_parameter_value "USE_STORE_FORWARD" ]
    set override_maxchannel [ get_parameter_value "ENABLE_EXPLICIT_MAXCHANNEL" ]
    set override_value      [ get_parameter_value "EXPLICIT_MAXCHANNEL" ]

    if { $override_maxchannel } {
        set max_channel $override_value
    }


    # +-----------------------------------
    # | connection point clk
    # |
    add_interface clk clock end
    add_interface_port clk clk clk Input 1
    add_interface_port clk reset reset Input 1

    # +-----------------------------------
    # | connection point csr
    # |
        add_interface "csr" "avalon" "slave" "clk"
        set_interface_property "csr" "isNonVolatileStorage" "false"
        set_interface_property "csr" "burstOnBurstBoundariesOnly" "false"
        set_interface_property "csr" "readLatency" "1"
        set_interface_property "csr" "holdTime" "0"
        set_interface_property "csr" "printableDevice" "false"
        set_interface_property "csr" "readWaitTime" "0"
        set_interface_property "csr" "setupTime" "0"
        set_interface_property "csr" "addressAlignment" "DYNAMIC"
        set_interface_property "csr" "writeWaitTime" "0"
        set_interface_property "csr" "timingUnits" "Cycles"
        set_interface_property "csr" "minimumUninterruptedRunLength" "1"
        set_interface_property "csr" "isMemoryDevice" "false"
        set_interface_property "csr" "linewrapBursts" "false"
        set_interface_property "csr" "maximumPendingReadTransactions" "0"

        if {$use_store_forward == "1"} {
          add_interface_port "csr" "csr_address" "address" "input" 3
        } else {
          add_interface_port "csr" "csr_address" "address" "input" 2
        }
        add_interface_port "csr" "csr_read" "read" "input" 1
        add_interface_port "csr" "csr_write" "write" "input" 1
        add_interface_port "csr" "csr_readdata" "readdata" "output" 32
        add_interface_port "csr" "csr_writedata" "writedata" "input" 32

    if {$use_fill_level == "0"} {
        set_port_property "csr_address" TERMINATION 1
        set_port_property "csr_readdata" TERMINATION 1
        set_port_property "csr_writedata" TERMINATION 1
        set_port_property "csr_write" TERMINATION 1
        set_port_property "csr_write" TERMINATION_VALUE 0
        set_port_property "csr_read" TERMINATION 1
        set_port_property "csr_read" TERMINATION_VALUE 0
    }
     
# almost_full interface
    add_interface "almost_full" "avalon_streaming" "source" "clk"
    set_interface_property "almost_full" "symbolsPerBeat" "1"
    set_interface_property "almost_full" "dataBitsPerSymbol" "1"
    set_interface_property "almost_full" "readyLatency" "0"
    set_interface_property "almost_full" "maxChannel" "0"
    add_interface_port     "almost_full" "almost_full_data" "data" "output" 1

    if {$use_almost_full == "0"} {
        set_port_property  "almost_full_data" TERMINATION 1
    }

# almost_empty interface
    add_interface "almost_empty" "avalon_streaming" "source" "clk"
    set_interface_property "almost_empty" "symbolsPerBeat" 1
    set_interface_property "almost_empty" "dataBitsPerSymbol" 1
    set_interface_property "almost_empty" "readyLatency" "0"
    set_interface_property "almost_empty" "maxChannel" "0"
    add_interface_port     "almost_empty" "almost_empty_data" "data" "output" 1
    if {$use_almost_empty == "0"} {
        set_port_property  "almost_empty_data" TERMINATION 1
    }


    # Avalon-ST sink interface
    add_interface "in" "avalon_streaming" "sink" "clk"
    set_interface_property "in" "symbolsPerBeat" $symbols_per_beat
    set_interface_property "in" "dataBitsPerSymbol" $bits_per_symbol
    set_interface_property "in" "readyLatency" "0"
    set_interface_property "in" "maxChannel" "$max_channel"

    # Avalon-ST source interface
    add_interface "out" "avalon_streaming" "source" "clk"
    set_interface_property "out" "symbolsPerBeat" $symbols_per_beat
    set_interface_property "out" "dataBitsPerSymbol" $bits_per_symbol
    set_interface_property "out" "readyLatency" "0"
    set_interface_property "out" "maxChannel" "$max_channel"

    set_interface_assignment out debug.controlledBy in

    add_interface_port "in" "in_data" "data" "input" $data_width
    add_interface_port "in" "in_valid" "valid" "input" 1
    add_interface_port "in" "in_ready" "ready" "output" 1

    add_interface_port "out" "out_data" "data" "output" $data_width
    add_interface_port "out" "out_valid" "valid" "output" 1
    add_interface_port "out" "out_ready" "ready" "input" 1

    add_interface_port "in" "in_startofpacket" "startofpacket" "input" 1
    add_interface_port "in" "in_endofpacket" "endofpacket" "input" 1

    add_interface_port "out" "out_startofpacket" "startofpacket" "output" 1
    add_interface_port "out" "out_endofpacket" "endofpacket" "output" 1
    add_interface_port "in" "in_empty" "empty" "input" 1
    add_interface_port "out" "out_empty" "empty" "output" 1
    add_interface_port "in" "in_error" "error" "input" 1
    add_interface_port "out" "out_error" "error" "output" 1

    if {$use_packets } {
      if {$symbols_per_beat > 1 } {
        set_port_property in_empty TERMINATION false
        set_port_property in_empty WIDTH $empty_width
        set_port_property out_empty TERMINATION false
        set_port_property out_empty WIDTH $empty_width
      } else {
        set_port_property in_empty TERMINATION true
        set_port_property out_empty TERMINATION true
      }       
    } else {
        set_port_property in_empty TERMINATION true
        set_port_property out_empty TERMINATION true
    }


      if {$error_width > 0} {
        set_port_property in_error TERMINATION false
        set_port_property in_error WIDTH $error_width
        set_port_property out_error TERMINATION false
        set_port_property out_error WIDTH $error_width
      } else {
        set_port_property "in_error" TERMINATION true
        set_port_property "out_error" TERMINATION true
      }

    if {$use_packets == "0"} {
        set_port_property "in_startofpacket" TERMINATION 1
        set_port_property "in_startofpacket" TERMINATION_VALUE 0
        set_port_property "in_endofpacket" TERMINATION 1
        set_port_property "in_endofpacket" TERMINATION_VALUE 0
        set_port_property "out_startofpacket" TERMINATION 1
        set_port_property "out_endofpacket" TERMINATION 1
    }



    if {$channel_width > 0} {
      add_interface_port "in" "in_channel" "channel" "input" $channel_width
      add_interface_port "out" "out_channel" "channel" "output" $channel_width
    } else {
      add_interface_port "in" "in_channel" "channel" "input" 1
      add_interface_port "out" "out_channel" "channel" "output" 1
      set_port_property  "in_channel" TERMINATION 1
      set_port_property  "in_channel" TERMINATION_VALUE 0
      set_port_property  "out_channel" TERMINATION 1
    }

}

