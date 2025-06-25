# $File: //acds/rel/13.1/ip/sopc/components/altera_avalon_dc_fifo/altera_avalon_dc_fifo_hw.tcl $
# $Revision: #1 $
# $Date: 2013/08/11 $
# $Author: swbranch $
#--------------------------------------------------------------------------
# Avalon-ST DCFIFO component description
#--------------------------------------------------------------------------

package require -exact sopc 9.1

set_module_property NAME altera_avalon_dc_fifo
set_module_property DISPLAY_NAME "Avalon-ST Dual Clock FIFO"
set_module_property AUTHOR "Altera Corporation"
set_module_property GROUP "Memories and Memory Controllers/On-Chip"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_dc_fifo.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_dc_fifo
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property VERSION 13.1
set_module_property EDITABLE false
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property DATASHEET_URL "http://www.altera.com/literature/hb/nios2/qts_qii55014.pdf"
set_module_property ANALYZE_HDL false

add_file altera_avalon_dc_fifo.v {SYNTHESIS SIMULATION}
add_file altera_dcfifo_synchronizer_bundle.v {SYNTHESIS SIMULATION}
add_file altera_avalon_dc_fifo.sdc SDC

## --------------------------------------------
#|
#| Module parameters
#|
add_parameter SYMBOLS_PER_BEAT          INTEGER 1  ""
add_parameter BITS_PER_SYMBOL           INTEGER 8  ""
add_parameter FIFO_DEPTH                INTEGER 16 ""
add_parameter CHANNEL_WIDTH             INTEGER 0  ""
add_parameter ERROR_WIDTH               INTEGER 0  ""
add_parameter USE_PACKETS               INTEGER 0  ""
add_parameter USE_IN_FILL_LEVEL         INTEGER 0  ""
add_parameter USE_OUT_FILL_LEVEL        INTEGER 0  ""
add_parameter WR_SYNC_DEPTH             INTEGER 2  ""
add_parameter RD_SYNC_DEPTH             INTEGER 2  ""
add_parameter ENABLE_EXPLICIT_MAXCHANNEL BOOLEAN false
add_parameter EXPLICIT_MAXCHANNEL        INTEGER 0 ""

## ---------------------------------
#|
#| Set display names for all the visible parameters
#|
set_parameter_property SYMBOLS_PER_BEAT   DISPLAY_NAME "Symbols per beat"
set_parameter_property SYMBOLS_PER_BEAT   DESCRIPTION  "Symbols per beat"
set_parameter_property BITS_PER_SYMBOL    DISPLAY_NAME "Bits per symbol"
set_parameter_property BITS_PER_SYMBOL    DESCRIPTION  "Bits per symbol"
set_parameter_property FIFO_DEPTH         DISPLAY_NAME "FIFO depth"
set_parameter_property FIFO_DEPTH         DESCRIPTION  "FIFO depth"
set_parameter_property CHANNEL_WIDTH      DISPLAY_NAME "Channel width"
set_parameter_property CHANNEL_WIDTH      DESCRIPTION  "Channel width"
set_parameter_property ERROR_WIDTH        DISPLAY_NAME "Error width"
set_parameter_property ERROR_WIDTH        DESCRIPTION  "Error width"
set_parameter_property USE_PACKETS        DISPLAY_NAME "Use packets"
set_parameter_property USE_PACKETS        DESCRIPTION  "Use packets"
set_parameter_property USE_IN_FILL_LEVEL  DISPLAY_NAME "Use sink fill level"
set_parameter_property USE_IN_FILL_LEVEL  DESCRIPTION  "Use sink fill level"
set_parameter_property USE_OUT_FILL_LEVEL DISPLAY_NAME "Use source fill level"
set_parameter_property USE_OUT_FILL_LEVEL DESCRIPTION  "Use source fill level"
set_parameter_property WR_SYNC_DEPTH      DISPLAY_NAME "Write pointer synchronizer length"
set_parameter_property WR_SYNC_DEPTH      DESCRIPTION  "Write pointer synchronizer length"
set_parameter_property RD_SYNC_DEPTH      DISPLAY_NAME "Read pointer synchronizer length"
set_parameter_property RD_SYNC_DEPTH      DESCRIPTION  "Read pointer synchronizer length"
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DISPLAY_NAME "Enable explicit maxChannel"
set_parameter_property ENABLE_EXPLICIT_MAXCHANNEL DESCRIPTION  "Enable explicit maxChannel"
set_parameter_property EXPLICIT_MAXCHANNEL        DISPLAY_NAME "Explicit maxChannel"
set_parameter_property EXPLICIT_MAXCHANNEL        DESCRIPTION  "Explicit maxChannel"

## ---------------------------------
#|
#| Set display hints for those boolean-like parameters
#|
set_parameter_property USE_PACKETS        DISPLAY_HINT "boolean"
set_parameter_property USE_IN_FILL_LEVEL  DISPLAY_HINT "boolean"
set_parameter_property USE_OUT_FILL_LEVEL DISPLAY_HINT "boolean"

set_parameter_property SYMBOLS_PER_BEAT   HDL_PARAMETER true 
set_parameter_property BITS_PER_SYMBOL    HDL_PARAMETER true 
set_parameter_property FIFO_DEPTH         HDL_PARAMETER true
set_parameter_property CHANNEL_WIDTH      HDL_PARAMETER true
set_parameter_property ERROR_WIDTH        HDL_PARAMETER true 
set_parameter_property USE_PACKETS        HDL_PARAMETER true 
set_parameter_property USE_IN_FILL_LEVEL  HDL_PARAMETER true
set_parameter_property USE_OUT_FILL_LEVEL HDL_PARAMETER true 
set_parameter_property WR_SYNC_DEPTH      HDL_PARAMETER true 
set_parameter_property RD_SYNC_DEPTH      HDL_PARAMETER true

## --------------------------------------------
#|
#| Callback routines
#|
set_module_property ELABORATION_CALLBACK "elaborate"
set_module_property VALIDATION_CALLBACK  "validate"

proc log2ceil {num} {

    set val 0
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }

    return $val;
}

## ---------------------------------
#|
#| Ensures that the FIFO depth is a power of two,
#| otherwise errors out with size recommendation.
#|
proc validate {} {

    set required_depth [ get_parameter_value "FIFO_DEPTH" ]
    set addr_width     [ log2ceil $required_depth ]
    set real_depth     [ expr (1 << $addr_width) ]
	
    if {$required_depth != $real_depth} {
        send_message "error" "FIFO depth must be a power of two ($real_depth would be acceptable)"
    }

    if {$required_depth == 1} {
        send_message "error" "FIFO depth must be >= 2"
    }

}

proc elaborate {} {

    set symbols_per_beat    [ get_parameter_value "SYMBOLS_PER_BEAT" ]
    set bits_per_symbol     [ get_parameter_value "BITS_PER_SYMBOL" ]
    set data_width          [ expr $symbols_per_beat * $bits_per_symbol ]
    set empty_width         [ log2ceil $symbols_per_beat ] 
    set channel_width       [ get_parameter_value "CHANNEL_WIDTH" ]
    set max_channel         [ expr (1 << $channel_width) - 1 ]
    set error_width         [ get_parameter_value "ERROR_WIDTH" ]
    set use_packets         [ get_parameter_value "USE_PACKETS" ]
    set use_out_fill_level  [ get_parameter_value "USE_OUT_FILL_LEVEL" ]
    set use_in_fill_level   [ get_parameter_value "USE_IN_FILL_LEVEL" ]
    set override_maxchannel [ get_parameter_value "ENABLE_EXPLICIT_MAXCHANNEL" ]
    set override_value      [ get_parameter_value "EXPLICIT_MAXCHANNEL" ]

    if { $override_maxchannel } {
        set max_channel $override_value
    }

    # In clock interface
    add_interface in_clk "clock" end 
    add_interface_port in_clk in_clk clk Input 1
    add_interface_port in_clk in_reset_n reset_n Input 1

    # Out clock interface
    add_interface out_clk "clock" end
    add_interface_port out_clk out_clk clk Input 1
    add_interface_port out_clk out_reset_n reset_n Input 1

    # In fill level -----------------------------------------------------
    add_interface "in_csr" "avalon" "slave" "in_clk"
    set_interface_property "in_csr" "isNonVolatileStorage" "false"
    set_interface_property "in_csr" "burstOnBurstBoundariesOnly" "false"
    set_interface_property "in_csr" "readLatency" "1"
    set_interface_property "in_csr" "holdTime" "0"
    set_interface_property "in_csr" "printableDevice" "false"
    set_interface_property "in_csr" "readWaitTime" "0"
    set_interface_property "in_csr" "setupTime" "0"
    set_interface_property "in_csr" "addressAlignment" "DYNAMIC"
    set_interface_property "in_csr" "writeWaitTime" "0"
    set_interface_property "in_csr" "timingUnits" "Cycles"
    set_interface_property "in_csr" "minimumUninterruptedRunLength" "1"
    set_interface_property "in_csr" "isMemoryDevice" "false"
    set_interface_property "in_csr" "linewrapBursts" "false"
    set_interface_property "in_csr" "maximumPendingReadTransactions" "0"

    add_interface_port in_csr in_csr_address address Input 1
    add_interface_port in_csr in_csr_read "read" Input 1
    add_interface_port in_csr in_csr_write write Input 1
    add_interface_port in_csr in_csr_readdata readdata Output 32
    add_interface_port in_csr in_csr_writedata writedata Input 32

    if {$use_in_fill_level == "0"} {
        set_port_property  in_csr_address     termination true
        set_port_property  in_csr_address     termination_value 0
        set_port_property  in_csr_read        termination true
        set_port_property  in_csr_read        termination_value 0
        set_port_property  in_csr_write       termination true
        set_port_property  in_csr_write       termination_value 0
        set_port_property  in_csr_writedata   termination true
        set_port_property  in_csr_writedata   termination_value 0
        set_port_property  in_csr_readdata    termination true
    }
#-----------------------------------------------------------------




    # Out fill level-----------------------------------------------
    add_interface "out_csr" "avalon" "slave" "out_clk"
    set_interface_property "out_csr" "isNonVolatileStorage" "false"
    set_interface_property "out_csr" "burstOnBurstBoundariesOnly" "false"
    set_interface_property "out_csr" "readLatency" "0"
    set_interface_property "out_csr" "holdTime" "0"
    set_interface_property "out_csr" "printableDevice" "false"
    set_interface_property "out_csr" "readWaitTime" "1"
    set_interface_property "out_csr" "setupTime" "0"
    set_interface_property "out_csr" "addressAlignment" "DYNAMIC"
    set_interface_property "out_csr" "writeWaitTime" "0"
    set_interface_property "out_csr" "timingUnits" "Cycles"
    set_interface_property "out_csr" "minimumUninterruptedRunLength" "1"
    set_interface_property "out_csr" "isMemoryDevice" "false"
    set_interface_property "out_csr" "linewrapBursts" "false"
    set_interface_property "out_csr" "maximumPendingReadTransactions" "0"

    add_interface_port out_csr out_csr_address address Input 1
    add_interface_port out_csr out_csr_read "read" Input 1
    add_interface_port out_csr out_csr_write write Input 1
    add_interface_port out_csr out_csr_readdata readdata Output 32
    add_interface_port out_csr out_csr_writedata writedata Input 32

    if {$use_out_fill_level == "0"} {
        set_port_property  out_csr_address     termination true
        set_port_property  out_csr_address     termination_value 0
        set_port_property  out_csr_read        termination true
        set_port_property  out_csr_read        termination_value 0
        set_port_property  out_csr_write       termination true
        set_port_property  out_csr_write       termination_value 0
        set_port_property  out_csr_writedata   termination true
        set_port_property  out_csr_writedata   termination_value 0
        set_port_property  out_csr_readdata    termination true
    }
#-----------------------------------------------------------------

    # Avalon-ST sink interface
    add_interface "in" "avalon_streaming" "sink" "in_clk"
    set_interface_property "in" symbolsPerBeat $symbols_per_beat
    set_interface_property "in" dataBitsPerSymbol $bits_per_symbol
    set_interface_property "in" readyLatency 0
    set_interface_property "in" maxChannel $max_channel

    # Avalon-ST source interface
    add_interface "out" "avalon_streaming" "source" "out_clk"
    set_interface_property "out" symbolsPerBeat $symbols_per_beat
    set_interface_property "out" dataBitsPerSymbol $bits_per_symbol
    set_interface_property "out" readyLatency 0
    set_interface_property "out" maxChannel $max_channel

    add_interface_port "in" "in_data" "data" Input $data_width
    add_interface_port "in" "in_valid" "valid" Input 1
    add_interface_port "in" "in_ready" "ready" Output 1

    add_interface_port "out" "out_data" "data" Output $data_width
    add_interface_port "out" "out_valid" "valid" Output 1
    add_interface_port "out" "out_ready" "ready" Input 1


    # Use Packets ----------------------------------------------------
    add_interface_port "in"  "in_startofpacket"  "startofpacket" Input 1
    add_interface_port "in"  "in_endofpacket"    "endofpacket"   Input 1
    add_interface_port "out" "out_startofpacket" "startofpacket" Output 1
    add_interface_port "out" "out_endofpacket"   "endofpacket"   Output 1

    if {$use_packets == "0"} {
        set_port_property  "in_startofpacket"   termination true
        set_port_property  "in_startofpacket"   termination_value 0
        set_port_property  "in_endofpacket"     termination true
        set_port_property  "in_endofpacket"     termination_value 0
        set_port_property  "out_startofpacket"  termination true
        set_port_property  "out_endofpacket"    termination true
    }

    if {($use_packets==1) && ($empty_width>0)} {
       add_interface_port "in"  "in_empty"          "empty"         Input $empty_width
       add_interface_port "out" "out_empty"         "empty"         Output $empty_width
    }

#------------------------------------------------------------------------------

    #Error signal--------------------------------------------------------
    if {$error_width > 0} {
    add_interface_port in  in_error   "error" Input  $error_width
    add_interface_port out out_error  "error" Output $error_width
    }
#--------------------------------------------------------------------------------------


    #Channel signal--------------------------------------------------------
    if {$channel_width > 0} {
    add_interface_port in  in_channel  channel Input  $channel_width
    add_interface_port out out_channel channel Output $channel_width
    }
#--------------------------------------------------------------------------------------

}

