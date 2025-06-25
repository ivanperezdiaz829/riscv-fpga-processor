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
# | module alt_trace_transacto_lite
# |
set_module_property NAME                         altera_trace_transacto_lite
set_module_property VERSION                      13.1
set_module_property AUTHOR                       "Altera Corporation"
set_module_property INTERNAL                     true
set_module_property OPAQUE_ADDRESS_MAP           true
set_module_property GROUP                        "Verification/Debug & Performance/Trace"
set_module_property DISPLAY_NAME                 transacto_lite
set_module_property TOP_LEVEL_HDL_FILE           altera_trace_transacto_lite.v
set_module_property TOP_LEVEL_HDL_MODULE         altera_trace_transacto_lite
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE                     true
set_module_property ANALYZE_HDL                  false
set_module_property STATIC_TOP_LEVEL_MODULE_NAME "altera_trace_transacto_lite"

# |
# +-----------------------------------

# +-----------------------------------
# | files
# |
add_file altera_trace_transacto_lite.v {SYNTHESIS SIMULATION}
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter          ADDR_WIDTH INTEGER            10
set_parameter_property ADDR_WIDTH DEFAULT_VALUE      10
set_parameter_property ADDR_WIDTH DISPLAY_NAME       "Word address width"
set_parameter_property ADDR_WIDTH TYPE               INTEGER
set_parameter_property ADDR_WIDTH ALLOWED_RANGES     1:13
set_parameter_property ADDR_WIDTH UNITS              None
set_parameter_property ADDR_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDR_WIDTH HDL_PARAMETER      true

add_parameter          DEBUG_PIPE_WIDTH INTEGER            8
set_parameter_property DEBUG_PIPE_WIDTH DEFAULT_VALUE      8
set_parameter_property DEBUG_PIPE_WIDTH DISPLAY_NAME       DEBUG_PIPE_WIDTH
set_parameter_property DEBUG_PIPE_WIDTH TYPE               INTEGER
set_parameter_property DEBUG_PIPE_WIDTH UNITS              None
set_parameter_property DEBUG_PIPE_WIDTH AFFECTS_GENERATION false
set_parameter_property DEBUG_PIPE_WIDTH VISIBLE            false
set_parameter_property DEBUG_PIPE_WIDTH HDL_PARAMETER      true

add_parameter          DATA_WIDTH INTEGER            32
set_parameter_property DATA_WIDTH DEFAULT_VALUE      32
set_parameter_property DATA_WIDTH DISPLAY_NAME       DATA_WIDTH
set_parameter_property DATA_WIDTH TYPE               INTEGER
set_parameter_property DATA_WIDTH UNITS              None
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH VISIBLE            false
set_parameter_property DATA_WIDTH HDL_PARAMETER      true


add_parameter          USE_RDV INTEGER            1
set_parameter_property USE_RDV DEFAULT_VALUE      1
set_parameter_property USE_RDV DISPLAY_NAME       "Use read_data_valid"
set_parameter_property USE_RDV TYPE               INTEGER
set_parameter_property USE_RDV UNITS              None
set_parameter_property USE_RDV AFFECTS_GENERATION true
set_parameter_property USE_RDV VISIBLE            true
set_parameter_property USE_RDV HDL_PARAMETER      true
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
add_interface_port     clk clk       clk Input 1
# |
# +-----------------------------------

# +-----------------------------------
# | connection point reset_sink
# |
add_interface          reset reset            end
set_interface_property reset associatedClock  clk
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED          true
add_interface_port     reset arst_n           reset_n    Input   1
# |
# +-----------------------------------


# +-----------------------------------
# | connection point avalon_streaming_sink
# |
add_interface          dbg_enable avalon_streaming  end
set_interface_property dbg_enable associatedClock   clk
set_interface_property dbg_enable associatedReset   reset
set_interface_property dbg_enable dataBitsPerSymbol 1
set_interface_property dbg_enable errorDescriptor   ""
set_interface_property dbg_enable firstSymbolInHighOrderBits true
set_interface_property dbg_enable maxChannel                 0
set_interface_property dbg_enable readyLatency               0
set_interface_property dbg_enable ENABLED                    false

add_interface_port     dbg_enable enable  data  Input  1
set_port_property     enable TERMINATION TRUE
set_port_property     enable TERMINATION_VALUE 1

# |
# +-----------------------------------





# +-----------------------------------
# | connection point avalon_streaming_sink
# |
add_interface          h2t avalon_streaming           end
set_interface_property h2t associatedClock            clk
set_interface_property h2t associatedReset            reset
set_interface_property h2t dataBitsPerSymbol          8
set_interface_property h2t errorDescriptor            ""
set_interface_property h2t firstSymbolInHighOrderBits true
set_interface_property h2t maxChannel                 0
set_interface_property h2t readyLatency               0
set_interface_property h2t ENABLED                    true

add_interface_port     h2t dbg_in_ready ready         Output 1
add_interface_port     h2t dbg_in_sop   startofpacket Input  1
add_interface_port     h2t dbg_in_valid valid         Input  1
add_interface_port     h2t dbg_in_eop   endofpacket   Input  1
add_interface_port     h2t dbg_in_data  data          Input  DEBUG_PIPE_WIDTH
set_interface_assignment h2t debug.interfaceGroup {associatedT2h t2h}
# |
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# |
add_interface          t2h avalon_streaming            start
set_interface_property t2h associatedClock             clk
set_interface_property t2h associatedReset             reset
set_interface_property t2h dataBitsPerSymbol           8
set_interface_property t2h errorDescriptor             ""
set_interface_property t2h firstSymbolInHighOrderBits  true
set_interface_property t2h maxChannel                  0
set_interface_property t2h readyLatency                0
set_interface_property t2h ENABLED                     true
add_interface_port     t2h dbg_out_ready ready         Input  1
add_interface_port     t2h dbg_out_valid valid         Output 1
add_interface_port     t2h dbg_out_sop   startofpacket Output 1
add_interface_port     t2h dbg_out_eop   endofpacket   Output 1
add_interface_port     t2h dbg_out_data  data          Output DEBUG_PIPE_WIDTH
# |
# +-----------------------------------




# +-----------------------------------
# | connection point master
# |
add_interface          master avalon                         start
set_interface_property master addressUnits                   WORDS
set_interface_property master associatedClock                clk
set_interface_property master associatedReset                reset
set_interface_property master bitsPerSymbol                  8
set_interface_property master burstOnBurstBoundariesOnly     false
set_interface_property master burstcountUnits                WORDS
set_interface_property master doStreamReads                  false
set_interface_property master doStreamWrites                 false
set_interface_property master holdTime                       0
set_interface_property master linewrapBursts                 false
set_interface_property master maximumPendingReadTransactions USE_RDV
set_interface_property master readLatency                    0
set_interface_property master readWaitTime                   0
set_interface_property master setupTime                      0
set_interface_property master timingUnits                    Cycles
set_interface_property master writeWaitTime                  0
set_interface_property master ENABLED true
add_interface_port     master master_write             write         Output      1
add_interface_port     master master_read              read          Output      1
add_interface_port     master master_address           address       Output      ADDR_WIDTH
add_interface_port     master master_write_data        writedata     Output      DATA_WIDTH
add_interface_port     master master_waitrequest       waitrequest   Input       1
add_interface_port     master master_read_data_valid   readdatavalid Input       1
add_interface_port     master master_readdata          readdata      Input       DATA_WIDTH
set_interface_assignment master debug.providesServices master
set_interface_assignment master debug.controlledBy h2t
# |
# +-----------------------------------
