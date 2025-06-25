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
# | altera_avalon_mm_clock_crossing_bridge "Avalon-MM Clock Crossing Bridge"
# | 
# +-----------------------------------

# +-----------------------------------
# | 
package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_mm_clock_crossing_bridge
# | 
set_module_property NAME altera_avalon_mm_clock_crossing_bridge
set_module_property VERSION 13.1
set_module_property HIDE_FROM_SOPC true
set_module_property GROUP "Bridges and Adapters/Memory Mapped"
set_module_property DISPLAY_NAME "Avalon-MM Clock Crossing Bridge"
set_module_property DESCRIPTION "Transfers Avalon-MM commands and responses between asynchronous clock domains using asynchronous FIFOs to implement the clock crossing logic."
set_module_property AUTHOR "Altera Corporation"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_mm_clock_crossing_bridge.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_mm_clock_crossing_bridge
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL FALSE
set_module_property HIDE_FROM_SOPC true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf

# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_avalon_mm_clock_crossing_bridge.v {SYNTHESIS SIMULATION}
add_file ../../sopc_builder_ip/altera_avalon_dc_fifo/altera_avalon_dc_fifo.v {SYNTHESIS SIMULATION}
add_file ../../sopc_builder_ip/altera_avalon_dc_fifo/altera_dcfifo_synchronizer_bundle.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data width"
set_parameter_property DATA_WIDTH DESCRIPTION {Bridge data width}
set_parameter_property DATA_WIDTH TYPE INTEGER
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true
add_parameter SYMBOL_WIDTH INTEGER 8
set_parameter_property SYMBOL_WIDTH DEFAULT_VALUE 8
set_parameter_property SYMBOL_WIDTH DISPLAY_NAME "Symbol width"
set_parameter_property SYMBOL_WIDTH DESCRIPTION {Symbol (byte) width}
set_parameter_property SYMBOL_WIDTH TYPE INTEGER
set_parameter_property SYMBOL_WIDTH UNITS None
set_parameter_property SYMBOL_WIDTH AFFECTS_GENERATION false
set_parameter_property SYMBOL_WIDTH HDL_PARAMETER true
add_parameter ADDRESS_WIDTH INTEGER 10
set_parameter_property ADDRESS_WIDTH DEFAULT_VALUE 10
set_parameter_property ADDRESS_WIDTH DISPLAY_NAME "Address width"
set_parameter_property ADDRESS_WIDTH DESCRIPTION {Bridge address width}
set_parameter_property ADDRESS_WIDTH TYPE INTEGER
set_parameter_property ADDRESS_WIDTH UNITS None
set_parameter_property ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDRESS_WIDTH HDL_PARAMETER true
add_parameter ADDRESS_UNITS STRING "SYMBOLS"
set_parameter_property ADDRESS_UNITS DEFAULT_VALUE "SYMBOLS"
set_parameter_property ADDRESS_UNITS DISPLAY_NAME "Address units"
set_parameter_property ADDRESS_UNITS DESCRIPTION {Address units (Symbols[bytes]/Words)}
set_parameter_property ADDRESS_UNITS TYPE STRING
set_parameter_property ADDRESS_UNITS UNITS None
set_parameter_property ADDRESS_UNITS AFFECTS_GENERATION false
set_parameter_property ADDRESS_UNITS HDL_PARAMETER false
set_parameter_property ADDRESS_UNITS ALLOWED_RANGES "SYMBOLS,WORDS"

add_parameter BURSTCOUNT_WIDTH INTEGER 1
set_parameter_property BURSTCOUNT_WIDTH DEFAULT_VALUE 1
set_parameter_property BURSTCOUNT_WIDTH DISPLAY_NAME "Burstcount width"
set_parameter_property BURSTCOUNT_WIDTH DESCRIPTION {Burstcount width}
set_parameter_property BURSTCOUNT_WIDTH TYPE INTEGER
set_parameter_property BURSTCOUNT_WIDTH UNITS None
set_parameter_property BURSTCOUNT_WIDTH AFFECTS_GENERATION false
set_parameter_property BURSTCOUNT_WIDTH HDL_PARAMETER true
set_parameter_property BURSTCOUNT_WIDTH DERIVED true
set_parameter_property BURSTCOUNT_WIDTH VISIBLE false

add_parameter MAX_BURST_SIZE INTEGER 1
set_parameter_property MAX_BURST_SIZE DISPLAY_NAME "Maximum burst size (words)"
set_parameter_property MAX_BURST_SIZE AFFECTS_GENERATION true
set_parameter_property MAX_BURST_SIZE HDL_PARAMETER false
set_parameter_property MAX_BURST_SIZE DESCRIPTION {Specifies the maximum burst size}
set_parameter_property MAX_BURST_SIZE ALLOWED_RANGES "1,2,4,8,16,32,64,128,256,512,1024"

add_parameter COMMAND_FIFO_DEPTH INTEGER 4
set_parameter_property COMMAND_FIFO_DEPTH DEFAULT_VALUE 4
set_parameter_property COMMAND_FIFO_DEPTH DISPLAY_NAME "Command FIFO depth"
set_parameter_property COMMAND_FIFO_DEPTH DESCRIPTION {Command (master-to-slave) FIFO depth}
set_parameter_property COMMAND_FIFO_DEPTH TYPE INTEGER
set_parameter_property COMMAND_FIFO_DEPTH UNITS None
set_parameter_property COMMAND_FIFO_DEPTH AFFECTS_GENERATION false
set_parameter_property COMMAND_FIFO_DEPTH HDL_PARAMETER true
add_parameter RESPONSE_FIFO_DEPTH INTEGER 4
set_parameter_property RESPONSE_FIFO_DEPTH DEFAULT_VALUE 4
set_parameter_property RESPONSE_FIFO_DEPTH DISPLAY_NAME "Response FIFO depth"
set_parameter_property RESPONSE_FIFO_DEPTH DESCRIPTION {Response (slave-to-master) FIFO depth}
set_parameter_property RESPONSE_FIFO_DEPTH TYPE INTEGER
set_parameter_property RESPONSE_FIFO_DEPTH UNITS None
set_parameter_property RESPONSE_FIFO_DEPTH AFFECTS_GENERATION false
set_parameter_property RESPONSE_FIFO_DEPTH HDL_PARAMETER true
add_parameter MASTER_SYNC_DEPTH INTEGER 2
set_parameter_property MASTER_SYNC_DEPTH DEFAULT_VALUE 2
set_parameter_property MASTER_SYNC_DEPTH DISPLAY_NAME "Master clock domain synchronizer depth"
set_parameter_property MASTER_SYNC_DEPTH DESCRIPTION {Specifies the number of pipeline stages used to avoid metastable events}
set_parameter_property MASTER_SYNC_DEPTH TYPE INTEGER
set_parameter_property MASTER_SYNC_DEPTH UNITS None
set_parameter_property MASTER_SYNC_DEPTH AFFECTS_GENERATION false
set_parameter_property MASTER_SYNC_DEPTH HDL_PARAMETER true
add_parameter SLAVE_SYNC_DEPTH INTEGER 2
set_parameter_property SLAVE_SYNC_DEPTH DEFAULT_VALUE 2
set_parameter_property SLAVE_SYNC_DEPTH DISPLAY_NAME "Slave clock domain synchronizer depth"
set_parameter_property SLAVE_SYNC_DEPTH DESCRIPTION {Specifies the number of pipeline stages used to avoid metastable events}
set_parameter_property SLAVE_SYNC_DEPTH TYPE INTEGER
set_parameter_property SLAVE_SYNC_DEPTH UNITS None
set_parameter_property SLAVE_SYNC_DEPTH AFFECTS_GENERATION false
set_parameter_property SLAVE_SYNC_DEPTH HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point m0_clk
# | 
add_interface m0_clk clock end
add_interface m0_reset reset end

set_interface_property m0_clk ENABLED true
set_interface_property m0_reset ASSOCIATED_CLOCK "m0_clk"

add_interface_port m0_clk m0_clk clk Input 1
add_interface_port m0_reset m0_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point s0_clk
# | 
add_interface s0_clk clock end
add_interface s0_reset reset end

set_interface_property s0_clk ENABLED true
set_interface_property s0_reset ASSOCIATED_CLOCK "s0_clk"

add_interface_port s0_clk s0_clk clk Input 1
add_interface_port s0_reset s0_reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point s0
# | 
add_interface s0 avalon end
set_interface_property s0 addressAlignment DYNAMIC
set_interface_property s0 bridgesToMaster m0
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 isMemoryDevice false
set_interface_property s0 isNonVolatileStorage false
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 1
set_interface_property s0 printableDevice false
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 0
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitTime 0

set_interface_property s0 ASSOCIATED_CLOCK "s0_clk"
set_interface_property s0 associatedReset "s0_reset"
set_interface_property s0 ENABLED true

add_interface_port s0 s0_waitrequest waitrequest Output 1
add_interface_port s0 s0_readdata readdata Output DATA_WIDTH
add_interface_port s0 s0_readdatavalid readdatavalid Output 1
add_interface_port s0 s0_burstcount burstcount Input BURSTCOUNT_WIDTH
add_interface_port s0 s0_writedata writedata Input DATA_WIDTH
add_interface_port s0 s0_address address Input ADDRESS_WIDTH
add_interface_port s0 s0_write write Input 1
add_interface_port s0 s0_read read Input 1
add_interface_port s0 s0_byteenable byteenable Input 4
add_interface_port s0 s0_debugaccess debugaccess Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point m0
# | 
add_interface m0 avalon start
set_interface_property m0 burstOnBurstBoundariesOnly false
set_interface_property m0 doStreamReads false
set_interface_property m0 doStreamWrites false
set_interface_property m0 linewrapBursts false

set_interface_property m0 ASSOCIATED_CLOCK "m0_clk"
set_interface_property m0 associatedReset "m0_reset"
set_interface_property m0 ENABLED true

add_interface_port m0 m0_waitrequest waitrequest Input 1
add_interface_port m0 m0_readdata readdata Input DATA_WIDTH
add_interface_port m0 m0_readdatavalid readdatavalid Input 1
add_interface_port m0 m0_burstcount burstcount Output BURSTCOUNT_WIDTH
add_interface_port m0 m0_writedata writedata Output DATA_WIDTH
add_interface_port m0 m0_address address Output ADDRESS_WIDTH
add_interface_port m0 m0_write write Output 1
add_interface_port m0 m0_read read Output 1
add_interface_port m0 m0_byteenable byteenable Output 4
add_interface_port m0 m0_debugaccess debugaccess Output 1
# | 
# +-----------------------------------

proc elaborate { } {
    set data_width   [ get_parameter_value DATA_WIDTH ]
    set sym_width    [ get_parameter_value SYMBOL_WIDTH ]
    set byteen_width [ expr $data_width / $sym_width ]
    set cmd_depth    [ get_parameter_value COMMAND_FIFO_DEPTH ]
    set rsp_depth    [ get_parameter_value RESPONSE_FIFO_DEPTH ]
    set aunits       [ get_parameter_value ADDRESS_UNITS ]
    set burst_size   [ get_parameter_value MAX_BURST_SIZE ]

    set_port_property m0_byteenable WIDTH $byteen_width
    set_port_property s0_byteenable WIDTH $byteen_width

    set_interface_property m0 bitsPerSymbol $sym_width
    set_interface_property s0 bitsPerSymbol $sym_width
 
    set_interface_property m0 addressUnits $aunits
    set_interface_property s0 addressUnits $aunits

    #+---------------------------------------
    #| The bridge implementation allows only as many pending reads 
    #| as can be held in both FIFOs
    #+---------------------------------------
    set mprt [ expr $cmd_depth + $rsp_depth ]
    set_interface_property s0 maximumPendingReadTransactions $mprt

    set cmd_ok_depth [ expr ( 1 << [ log2ceil $cmd_depth ] ) ]
    if { $cmd_ok_depth != $cmd_depth } {
        send_message error "command FIFO depth must be a power of two"
    }
    set rsp_ok_depth [ expr ( 1 << [ log2ceil $rsp_depth ] ) ]
    if { $rsp_ok_depth != $rsp_depth } {
        send_message error "response FIFO depth must be a power of two"
    }

    set min_depth [ expr ( 2 * $burst_size ) ]
    if  { $rsp_depth < $min_depth } {
        send_message error "response FIFO depth must be >= $min_depth"
    }

    set width [ expr int (ceil (log($burst_size) / log(2))) + 1 ]
    set_parameter_value BURSTCOUNT_WIDTH $width

}

proc log2ceil {num} {

    set val 0
    set i 1
    while {$i < $num} {
        set val [expr $val + 1]
        set i [expr 1 << $val]
    }

    return $val;
}
