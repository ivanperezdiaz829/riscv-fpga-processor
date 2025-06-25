# +-----------------------------------
# | module afd_extractor
# | 
set_module_property NAME afd_extractor
set_module_property VERSION 13.1
set_module_property AUTHOR "Altera Corporation"
set_module_property INTERNAL false
set_module_property GROUP "DSP/Video and Image Processing"
set_module_property DISPLAY_NAME "AFD Extractor"
set_module_property TOP_LEVEL_HDL_FILE afd_extractor.v
set_module_property TOP_LEVEL_HDL_MODULE afd_extractor
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file afd_extractor.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset rst reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_sink
# | 
add_interface avalon_streaming_sink avalon_streaming end
set_interface_property avalon_streaming_sink associatedClock clock_reset
set_interface_property avalon_streaming_sink dataBitsPerSymbol 10
set_interface_property avalon_streaming_sink errorDescriptor ""
set_interface_property avalon_streaming_sink maxChannel 0
set_interface_property avalon_streaming_sink readyLatency 1

set_interface_property avalon_streaming_sink ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_sink ENABLED true

add_interface_port avalon_streaming_sink din_data data Input 20
add_interface_port avalon_streaming_sink din_eop endofpacket Input 1
add_interface_port avalon_streaming_sink din_ready ready Output 1
add_interface_port avalon_streaming_sink din_sop startofpacket Input 1
add_interface_port avalon_streaming_sink din_valid valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_streaming_source
# | 
add_interface avalon_streaming_source avalon_streaming start
set_interface_property avalon_streaming_source associatedClock clock_reset
set_interface_property avalon_streaming_source dataBitsPerSymbol 10
set_interface_property avalon_streaming_source errorDescriptor ""
set_interface_property avalon_streaming_source maxChannel 0
set_interface_property avalon_streaming_source readyLatency 1

set_interface_property avalon_streaming_source ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_streaming_source ENABLED true

add_interface_port avalon_streaming_source dout_data data Output 20
add_interface_port avalon_streaming_source dout_eop endofpacket Output 1
add_interface_port avalon_streaming_source dout_ready ready Input 1
add_interface_port avalon_streaming_source dout_sop startofpacket Output 1
add_interface_port avalon_streaming_source dout_valid valid Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point control
# | 
add_interface control avalon end
set_interface_property control addressAlignment NATIVE
set_interface_property control associatedClock clock_reset
set_interface_property control burstOnBurstBoundariesOnly false
set_interface_property control explicitAddressSpan 0
set_interface_property control holdTime 0
set_interface_property control isMemoryDevice false
set_interface_property control isNonVolatileStorage false
set_interface_property control linewrapBursts false
set_interface_property control maximumPendingReadTransactions 0
set_interface_property control printableDevice false
set_interface_property control readLatency 0
set_interface_property control readWaitTime 1
set_interface_property control setupTime 0
set_interface_property control timingUnits Cycles
set_interface_property control writeWaitTime 0

set_interface_property control ASSOCIATED_CLOCK clock_reset
set_interface_property control ENABLED true

add_interface_port control av_read read Input 1
add_interface_port control av_readdata readdata Output 16
add_interface_port control av_address address Input 4
add_interface_port control av_write write Input 1
add_interface_port control av_writedata writedata Input 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point interrupt_sender
# | 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint control

set_interface_property interrupt_sender ASSOCIATED_CLOCK clock_reset
set_interface_property interrupt_sender ENABLED true

add_interface_port interrupt_sender av_interrupt irq Output 1
# | 
# +-----------------------------------
