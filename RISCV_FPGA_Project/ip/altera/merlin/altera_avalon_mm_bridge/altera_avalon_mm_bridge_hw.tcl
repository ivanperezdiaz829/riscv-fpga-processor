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
# | altera_avalon_mm_bridge "Avalon-MM Pipeline Bridge"
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.0
# | 
package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module altera_avalon_mm_bridge
# | 
set_module_property DESCRIPTION "Inserts a register stage in the Avalon-MM command and response paths. Accepts commands on its Avalon-MM slave port and propagates them to its Avalon-MM master port."
set_module_property NAME altera_avalon_mm_bridge
set_module_property VERSION 13.1
set_module_property HIDE_FROM_SOPC true 
set_module_property GROUP "Bridges and Adapters/Memory Mapped"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Avalon-MM Pipeline Bridge"
set_module_property AUTHOR "Altera Corporation"
set_module_property TOP_LEVEL_HDL_FILE altera_avalon_mm_bridge.v
set_module_property TOP_LEVEL_HDL_MODULE altera_avalon_mm_bridge
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ELABORATION_CALLBACK elaborate
set_module_property ANALYZE_HDL FALSE
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property HIDE_FROM_SOPC true
set_module_property DATASHEET_URL http://www.altera.com/literature/hb/qts/qsys_interconnect.pdf
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file altera_avalon_mm_bridge.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME {Data width}
set_parameter_property DATA_WIDTH TYPE INTEGER
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true
set_parameter_property DATA_WIDTH DESCRIPTION {Bridge data width}

add_parameter SYMBOL_WIDTH INTEGER 8
set_parameter_property SYMBOL_WIDTH DEFAULT_VALUE 8
set_parameter_property SYMBOL_WIDTH DISPLAY_NAME {Symbol width}
set_parameter_property SYMBOL_WIDTH TYPE INTEGER
set_parameter_property SYMBOL_WIDTH UNITS None
set_parameter_property SYMBOL_WIDTH DISPLAY_HINT ""
set_parameter_property SYMBOL_WIDTH AFFECTS_GENERATION false
set_parameter_property SYMBOL_WIDTH HDL_PARAMETER true
set_parameter_property SYMBOL_WIDTH DESCRIPTION {Symbol (byte) width}

add_parameter ADDRESS_WIDTH INTEGER 10
set_parameter_property ADDRESS_WIDTH DEFAULT_VALUE 10
set_parameter_property ADDRESS_WIDTH DISPLAY_NAME {Address width}
set_parameter_property ADDRESS_WIDTH TYPE INTEGER
set_parameter_property ADDRESS_WIDTH UNITS None
set_parameter_property ADDRESS_WIDTH DISPLAY_HINT ""
set_parameter_property ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property ADDRESS_WIDTH DESCRIPTION {Bridge address width}

add_parameter ADDRESS_UNITS STRING "SYMBOLS"
set_parameter_property ADDRESS_UNITS DISPLAY_NAME {Address units}
set_parameter_property ADDRESS_UNITS UNITS None
set_parameter_property ADDRESS_UNITS DISPLAY_HINT ""
set_parameter_property ADDRESS_UNITS AFFECTS_GENERATION false
set_parameter_property ADDRESS_UNITS HDL_PARAMETER false
set_parameter_property ADDRESS_UNITS ALLOWED_RANGES "SYMBOLS,WORDS"
set_parameter_property ADDRESS_UNITS DESCRIPTION {Address units (Symbols[bytes]/Words)}

add_parameter BURSTCOUNT_WIDTH INTEGER 1
set_parameter_property BURSTCOUNT_WIDTH DEFAULT_VALUE 1
set_parameter_property BURSTCOUNT_WIDTH DISPLAY_NAME {Burstcount width}
set_parameter_property BURSTCOUNT_WIDTH VISIBLE false
set_parameter_property BURSTCOUNT_WIDTH DERIVED true
set_parameter_property BURSTCOUNT_WIDTH TYPE INTEGER
set_parameter_property BURSTCOUNT_WIDTH UNITS None
set_parameter_property BURSTCOUNT_WIDTH DISPLAY_HINT ""
set_parameter_property BURSTCOUNT_WIDTH AFFECTS_GENERATION false
set_parameter_property BURSTCOUNT_WIDTH HDL_PARAMETER true
set_parameter_property BURSTCOUNT_WIDTH DESCRIPTION {Bridge burstcount width}

add_parameter MAX_BURST_SIZE INTEGER 1
set_parameter_property MAX_BURST_SIZE DISPLAY_NAME {Maximum burst size (words)}
set_parameter_property MAX_BURST_SIZE AFFECTS_GENERATION true
set_parameter_property MAX_BURST_SIZE HDL_PARAMETER false
set_parameter_property MAX_BURST_SIZE DESCRIPTION {Specifies the maximum burst size}
set_parameter_property MAX_BURST_SIZE ALLOWED_RANGES "1,2,4,8,16,32,64,128,256,512,1024"

add_parameter MAX_PENDING_RESPONSES INTEGER 4
set_parameter_property MAX_PENDING_RESPONSES DISPLAY_NAME {Maximum pending read transactions}
set_parameter_property MAX_PENDING_RESPONSES TYPE INTEGER
set_parameter_property MAX_PENDING_RESPONSES UNITS None
set_parameter_property MAX_PENDING_RESPONSES DISPLAY_HINT ""
set_parameter_property MAX_PENDING_RESPONSES AFFECTS_GENERATION false
set_parameter_property MAX_PENDING_RESPONSES DESCRIPTION {Controls the Avalon-MM maximum pending read transactions interface property of the bridge}

add_parameter LINEWRAPBURSTS INTEGER 0
set_parameter_property LINEWRAPBURSTS DISPLAY_NAME "Line wrap bursts"
set_parameter_property LINEWRAPBURSTS TYPE INTEGER
set_parameter_property LINEWRAPBURSTS AFFECTS_ELABORATION true
set_parameter_property LINEWRAPBURSTS HDL_PARAMETER false
set_parameter_property LINEWRAPBURSTS DISPLAY_HINT BOOLEAN
set_parameter_property LINEWRAPBURSTS AFFECTS_GENERATION false
set_parameter_property LINEWRAPBURSTS DESCRIPTION "This parameter allows you to match the behavior of some memory devices that implement a wrapping burst instead of an incrementing burst. The difference between the two is that with a wrapping burst, when the address reaches a burst boundary, the address wraps back to the previous burst boundary so that only the low-order bits are required for address counting"

add_parameter PIPELINE_COMMAND INTEGER 1
set_parameter_property PIPELINE_COMMAND DEFAULT_VALUE 1
set_parameter_property PIPELINE_COMMAND DISPLAY_NAME "Pipeline command signals"
set_parameter_property PIPELINE_COMMAND DESCRIPTION {When enabled, the command (or response) networks are pipelined, potentially increasing the frequency at the expense of increase logic and latency.}
set_parameter_property PIPELINE_COMMAND TYPE INTEGER
set_parameter_property PIPELINE_COMMAND UNITS None
set_parameter_property PIPELINE_COMMAND DISPLAY_HINT "boolean"
set_parameter_property PIPELINE_COMMAND AFFECTS_GENERATION false
set_parameter_property PIPELINE_COMMAND HDL_PARAMETER true

add_parameter PIPELINE_RESPONSE INTEGER 1
set_parameter_property PIPELINE_RESPONSE DEFAULT_VALUE 1
set_parameter_property PIPELINE_RESPONSE DISPLAY_NAME "Pipeline response signals"
set_parameter_property PIPELINE_RESPONSE DESCRIPTION {When enabled, the command (or response) networks are pipelined, potentially increasing the frequency at the expense of increase logic and latency.}
set_parameter_property PIPELINE_RESPONSE TYPE INTEGER
set_parameter_property PIPELINE_RESPONSE UNITS None
set_parameter_property PIPELINE_RESPONSE DISPLAY_HINT "boolean"
set_parameter_property PIPELINE_RESPONSE AFFECTS_GENERATION false
set_parameter_property PIPELINE_RESPONSE HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clk
# | 
add_interface clk clock end
add_interface reset reset end

set_interface_property clk ENABLED true
set_interface_property reset ENABLED true
set_interface_property reset ASSOCIATED_CLOCK clk

add_interface_port clk clk clk Input 1
add_interface_port reset reset reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point s0
# | 
add_interface s0 avalon end
set_interface_property s0 addressAlignment DYNAMIC
set_interface_property s0 associatedClock clk
set_interface_property s0 bridgesToMaster m0
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 isMemoryDevice false
set_interface_property s0 isNonVolatileStorage false
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 4
set_interface_property s0 printableDevice false
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 0
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitTime 0

set_interface_property s0 ASSOCIATED_CLOCK clk
set_interface_property s0 associatedReset reset
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
set_interface_property m0 associatedClock clk
set_interface_property m0 burstOnBurstBoundariesOnly false
set_interface_property m0 doStreamReads false
set_interface_property m0 doStreamWrites false
set_interface_property m0 linewrapBursts false

set_interface_property m0 ASSOCIATED_CLOCK clk
set_interface_property m0 associatedReset reset
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
    set mprt         [ get_parameter_value MAX_PENDING_RESPONSES ]
    set aunits       [ get_parameter_value ADDRESS_UNITS ]
    set burst_size   [ get_parameter_value MAX_BURST_SIZE ]
    set linewrap     [ get_parameter_value LINEWRAPBURSTS ]

    set_port_property m0_byteenable WIDTH $byteen_width
    set_port_property s0_byteenable WIDTH $byteen_width

    set_interface_property m0 bitsPerSymbol $sym_width
    set_interface_property s0 bitsPerSymbol $sym_width

    set_interface_property m0 addressUnits $aunits
    set_interface_property s0 addressUnits $aunits

    set_interface_property s0 maximumPendingReadTransactions $mprt

    set burstcount_width [ expr int (ceil (log($burst_size) / log(2))) + 1 ]
    set_parameter_value BURSTCOUNT_WIDTH $burstcount_width

    set_interface_property m0 linewrapBursts $linewrap
    set_interface_property s0 linewrapBursts $linewrap
}
