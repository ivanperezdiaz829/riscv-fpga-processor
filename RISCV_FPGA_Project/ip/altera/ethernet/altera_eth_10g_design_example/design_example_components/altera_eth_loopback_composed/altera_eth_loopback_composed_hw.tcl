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
# | request TCL package from ACDS 9.1
# |
package require -exact sopc 9.1
# |
# +-----------------------------------

# +-----------------------------------
# | module altera_eth_loopback_composed
# |
set_module_property NAME altera_eth_loopback_composed
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet/Example"
set_module_property DISPLAY_NAME "Ethernet Loopback Composed"
set_module_property DESCRIPTION "Altera Ethernet Loopback Composed"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSE_CALLBACK compose
set_module_property ANALYZE_HDL false
# |
# +-----------------------------------

sopc::preview_add_transform "foo" "PREVIEW_AVALON_MM_TRANSFORM"

proc compose {} {

    #  TX Clock Source 
    add_instance tx_clk_module clock_source  
    set_instance_parameter tx_clk_module clockFrequencyKnown "true"
    set_instance_parameter tx_clk_module clockFrequency "156250000"
    
    add_interface tx_clk clock end
    set_interface_property tx_clk export_of tx_clk_module.clk_in
    # TX Reset
    add_interface tx_reset reset end
    set_interface_property tx_reset export_of tx_clk_module.clk_in_reset

    #  RX Clock Source 
    add_instance rx_clk_module clock_source  
    set_instance_parameter rx_clk_module clockFrequencyKnown "true"
    set_instance_parameter rx_clk_module clockFrequency "156250000"
    
    add_interface rx_clk clock end
    set_interface_property rx_clk export_of rx_clk_module.clk_in
    # RX Reset
    add_interface rx_reset reset end
    set_interface_property rx_reset export_of rx_clk_module.clk_in_reset
    
    #  CSR Clock Source 
    add_instance csr_clk_module clock_source  
    set_instance_parameter csr_clk_module clockFrequencyKnown "true"
    set_instance_parameter csr_clk_module clockFrequency "156250000"
    
    add_interface csr_clk clock end
    set_interface_property csr_clk export_of csr_clk_module.clk_in
    # CSR Reset
    add_interface csr_reset reset end
    set_interface_property csr_reset export_of csr_clk_module.clk_in_reset
    
    

    # Timing Adapter 1
    add_instance lc_splitter_timing_adapter timing_adapter
    set_instance_parameter lc_splitter_timing_adapter generationLanguage "VERILOG"
    set_instance_parameter lc_splitter_timing_adapter inBitsPerSymbol "72"
    set_instance_parameter lc_splitter_timing_adapter inChannelWidth "0"
    set_instance_parameter lc_splitter_timing_adapter inErrorDescriptor ""
    set_instance_parameter lc_splitter_timing_adapter inErrorWidth "0"
    set_instance_parameter lc_splitter_timing_adapter inMaxChannel "0"
    set_instance_parameter lc_splitter_timing_adapter inReadyLatency "0"
    set_instance_parameter lc_splitter_timing_adapter inSymbolsPerBeat "1"
    set_instance_parameter lc_splitter_timing_adapter inUseEmpty "false"
    set_instance_parameter lc_splitter_timing_adapter inUseEmptyPort "NO"
    set_instance_parameter lc_splitter_timing_adapter inUsePackets "false"
    set_instance_parameter lc_splitter_timing_adapter inUseReady "false"
    set_instance_parameter lc_splitter_timing_adapter inUseValid "false"
    set_instance_parameter lc_splitter_timing_adapter moduleName "lc_splitter_timing_adapter"
    set_instance_parameter lc_splitter_timing_adapter outReadyLatency "0"
    set_instance_parameter lc_splitter_timing_adapter outUseReady "true"
    set_instance_parameter lc_splitter_timing_adapter outUseValid "true"
    
    
    # Local Splitter
    add_instance local_splitter altera_avalon_st_splitter
    set_instance_parameter local_splitter NUMBER_OF_OUTPUTS "2"
    set_instance_parameter local_splitter QUALIFY_VALID_OUT "0"
    set_instance_parameter local_splitter DATA_WIDTH "72"
    set_instance_parameter local_splitter BITS_PER_SYMBOL "72"
    set_instance_parameter local_splitter USE_PACKETS "0"
    set_instance_parameter local_splitter USE_CHANNEL "0"
    set_instance_parameter local_splitter CHANNEL_WIDTH "1"
    set_instance_parameter local_splitter MAX_CHANNELS "1"
    set_instance_parameter local_splitter USE_ERROR "0"
    set_instance_parameter local_splitter ERROR_WIDTH "1"
    set_instance_parameter local_splitter ERROR_DESCRIPTOR ""  
    
    # Line Loopback
    add_instance line_loopback altera_eth_loopback
    set_instance_parameter line_loopback SYMBOLS_PER_BEAT "1"
    set_instance_parameter line_loopback BITS_PER_SYMBOL "72"
    set_instance_parameter line_loopback ERROR_WIDTH "0"
    set_instance_parameter line_loopback USE_PACKETS "0"
    set_instance_parameter line_loopback NUM_OF_INPUT "2"
    set_instance_parameter line_loopback EMPTY_WIDTH "0"
    
    # Timing Adapter 2
    add_instance line_lb_timing_adapter timing_adapter
    set_instance_parameter line_lb_timing_adapter generationLanguage "VERILOG"
    set_instance_parameter line_lb_timing_adapter inBitsPerSymbol "72"
    set_instance_parameter line_lb_timing_adapter inChannelWidth "0"
    set_instance_parameter line_lb_timing_adapter inErrorDescriptor ""
    set_instance_parameter line_lb_timing_adapter inErrorWidth "0"
    set_instance_parameter line_lb_timing_adapter inMaxChannel "0"
    set_instance_parameter line_lb_timing_adapter inReadyLatency "0"
    set_instance_parameter line_lb_timing_adapter inSymbolsPerBeat "1"
    set_instance_parameter line_lb_timing_adapter inUseEmpty "false"
    set_instance_parameter line_lb_timing_adapter inUseEmptyPort "NO"
    set_instance_parameter line_lb_timing_adapter inUsePackets "false"
    set_instance_parameter line_lb_timing_adapter inUseReady "true"
    set_instance_parameter line_lb_timing_adapter inUseValid "true"
    set_instance_parameter line_lb_timing_adapter moduleName "line_lb_timing_adapter"
    set_instance_parameter line_lb_timing_adapter outReadyLatency "0"
    set_instance_parameter line_lb_timing_adapter outUseReady "false"
    set_instance_parameter line_lb_timing_adapter outUseValid "false"
    
    # Timing Adapter 3
    add_instance line_splitter_timing_adapter timing_adapter
    set_instance_parameter line_splitter_timing_adapter generationLanguage "VERILOG"
    set_instance_parameter line_splitter_timing_adapter inBitsPerSymbol "72"
    set_instance_parameter line_splitter_timing_adapter inChannelWidth "0"
    set_instance_parameter line_splitter_timing_adapter inErrorDescriptor ""
    set_instance_parameter line_splitter_timing_adapter inErrorWidth "0"
    set_instance_parameter line_splitter_timing_adapter inMaxChannel "0"
    set_instance_parameter line_splitter_timing_adapter inReadyLatency "0"
    set_instance_parameter line_splitter_timing_adapter inSymbolsPerBeat "1"
    set_instance_parameter line_splitter_timing_adapter inUseEmpty "false"
    set_instance_parameter line_splitter_timing_adapter inUseEmptyPort "NO"
    set_instance_parameter line_splitter_timing_adapter inUsePackets "false"
    set_instance_parameter line_splitter_timing_adapter inUseReady "false"
    set_instance_parameter line_splitter_timing_adapter inUseValid "false"
    set_instance_parameter line_splitter_timing_adapter moduleName "line_splitter_timing_adapter"
    set_instance_parameter line_splitter_timing_adapter outReadyLatency "0"
    set_instance_parameter line_splitter_timing_adapter outUseReady "true"
    set_instance_parameter line_splitter_timing_adapter outUseValid "true"
    
    # Line Splitter
    add_instance line_splitter altera_avalon_st_splitter
    set_instance_parameter line_splitter NUMBER_OF_OUTPUTS "2"
    set_instance_parameter line_splitter QUALIFY_VALID_OUT "0"
    set_instance_parameter line_splitter DATA_WIDTH "72"
    set_instance_parameter line_splitter BITS_PER_SYMBOL "72"
    set_instance_parameter line_splitter USE_PACKETS "0"
    set_instance_parameter line_splitter USE_CHANNEL "0"
    set_instance_parameter line_splitter CHANNEL_WIDTH "1"
    set_instance_parameter line_splitter MAX_CHANNELS "1"
    set_instance_parameter line_splitter USE_ERROR "0"
    set_instance_parameter line_splitter ERROR_WIDTH "1"
    set_instance_parameter line_splitter ERROR_DESCRIPTOR ""

    # Local Loopback
    add_instance local_loopback altera_eth_loopback
    set_instance_parameter local_loopback SYMBOLS_PER_BEAT "1"
    set_instance_parameter local_loopback BITS_PER_SYMBOL "72"
    set_instance_parameter local_loopback ERROR_WIDTH "0"
    set_instance_parameter local_loopback USE_PACKETS "0"
    set_instance_parameter local_loopback NUM_OF_INPUT "2"
    set_instance_parameter local_loopback EMPTY_WIDTH "0"
    
    # Timing Adapter 4
    add_instance lc_lb_timing_adapter timing_adapter
    set_instance_parameter lc_lb_timing_adapter generationLanguage "VERILOG"
    set_instance_parameter lc_lb_timing_adapter inBitsPerSymbol "72"
    set_instance_parameter lc_lb_timing_adapter inChannelWidth "0"
    set_instance_parameter lc_lb_timing_adapter inErrorDescriptor ""
    set_instance_parameter lc_lb_timing_adapter inErrorWidth "0"
    set_instance_parameter lc_lb_timing_adapter inMaxChannel "0"
    set_instance_parameter lc_lb_timing_adapter inReadyLatency "0"
    set_instance_parameter lc_lb_timing_adapter inSymbolsPerBeat "1"
    set_instance_parameter lc_lb_timing_adapter inUseEmpty "false"
    set_instance_parameter lc_lb_timing_adapter inUseEmptyPort "NO"
    set_instance_parameter lc_lb_timing_adapter inUsePackets "false"
    set_instance_parameter lc_lb_timing_adapter inUseReady "true"
    set_instance_parameter lc_lb_timing_adapter inUseValid "true"
    set_instance_parameter lc_lb_timing_adapter moduleName "lc_lb_timing_adapter"
    set_instance_parameter lc_lb_timing_adapter outReadyLatency "0"
    set_instance_parameter lc_lb_timing_adapter outUseReady "false"
    set_instance_parameter lc_lb_timing_adapter outUseValid "false"

    # MM Bridge
    # add_instance mm_pipeline_bridge altera_avalon_pipeline_bridge 
    # set_parameter mm_pipeline_bridge burstEnable "false"
    # set_parameter mm_pipeline_bridge dataWidth "32"
    # set_parameter mm_pipeline_bridge downstreamPipeline "true"
    # set_parameter mm_pipeline_bridge enableArbiterlock "false"
    # set_parameter mm_pipeline_bridge maxBurstSize "2"
    # set_parameter mm_pipeline_bridge maximumPendingReadTransactions "4"
    # set_parameter mm_pipeline_bridge upstreamPipeline "true"
    # set_parameter mm_pipeline_bridge waitrequestPipeline "true"
    
    # DC Fifo 1 ( local_splitter to local_loopback )
    add_instance dc_fifo_1 altera_avalon_dc_fifo
    set_instance_parameter dc_fifo_1 SYMBOLS_PER_BEAT "1"
    set_instance_parameter dc_fifo_1 BITS_PER_SYMBOL "72"
    set_instance_parameter dc_fifo_1 FIFO_DEPTH "16"
    set_instance_parameter dc_fifo_1 CHANNEL_WIDTH "0"
    set_instance_parameter dc_fifo_1 ERROR_WIDTH "0"
    set_instance_parameter dc_fifo_1 USE_PACKETS "0"
    set_instance_parameter dc_fifo_1 USE_IN_FILL_LEVEL "0"
    set_instance_parameter dc_fifo_1 USE_OUT_FILL_LEVEL "0"
    set_instance_parameter dc_fifo_1 WR_SYNC_DEPTH "2"
    set_instance_parameter dc_fifo_1 RD_SYNC_DEPTH "2"
    set_instance_parameter dc_fifo_1 ENABLE_EXPLICIT_MAXCHANNEL "false"
    set_instance_parameter dc_fifo_1 EXPLICIT_MAXCHANNEL "0"
    
    # DC Fifo 2 ( line_splitter to line_loopback )
    add_instance dc_fifo_2 altera_avalon_dc_fifo
    set_instance_parameter dc_fifo_2 SYMBOLS_PER_BEAT "1"
    set_instance_parameter dc_fifo_2 BITS_PER_SYMBOL "72"
    set_instance_parameter dc_fifo_2 FIFO_DEPTH "16"
    set_instance_parameter dc_fifo_2 CHANNEL_WIDTH "0"
    set_instance_parameter dc_fifo_2 ERROR_WIDTH "0"
    set_instance_parameter dc_fifo_2 USE_PACKETS "0"
    set_instance_parameter dc_fifo_2 USE_IN_FILL_LEVEL "0"
    set_instance_parameter dc_fifo_2 USE_OUT_FILL_LEVEL "0"
    set_instance_parameter dc_fifo_2 WR_SYNC_DEPTH "2"
    set_instance_parameter dc_fifo_2 RD_SYNC_DEPTH "2"
    set_instance_parameter dc_fifo_2 ENABLE_EXPLICIT_MAXCHANNEL "false"
    set_instance_parameter dc_fifo_2 EXPLICIT_MAXCHANNEL "0"

        #  Merlin Master Translator
    add_instance mm_pipeline_bridge altera_merlin_master_translator 
    set_instance_parameter mm_pipeline_bridge AV_ADDRESS_W "4"
    set_instance_parameter mm_pipeline_bridge AV_DATA_W "32"
    set_instance_parameter mm_pipeline_bridge AV_BURSTCOUNT_W "1"
    set_instance_parameter mm_pipeline_bridge AV_BYTEENABLE_W "4"
    set_instance_parameter mm_pipeline_bridge UAV_ADDRESS_W "6"
    set_instance_parameter mm_pipeline_bridge UAV_BURSTCOUNT_W "3"
    set_instance_parameter mm_pipeline_bridge AV_READLATENCY "0"
    set_instance_parameter mm_pipeline_bridge AV_WRITE_WAIT "0"
    set_instance_parameter mm_pipeline_bridge AV_READ_WAIT "0"
    set_instance_parameter mm_pipeline_bridge AV_DATA_HOLD "0"
    set_instance_parameter mm_pipeline_bridge AV_SETUP_WAIT "0"
    set_instance_parameter mm_pipeline_bridge USE_READDATA "1"
    set_instance_parameter mm_pipeline_bridge USE_WRITEDATA "1"
    set_instance_parameter mm_pipeline_bridge USE_READ "1"
    set_instance_parameter mm_pipeline_bridge USE_WRITE "1"
    set_instance_parameter mm_pipeline_bridge USE_BEGINBURSTTRANSFER "0"
    set_instance_parameter mm_pipeline_bridge USE_BEGINTRANSFER "0"
    set_instance_parameter mm_pipeline_bridge USE_BYTEENABLE "0"
    set_instance_parameter mm_pipeline_bridge USE_CHIPSELECT "0"
    set_instance_parameter mm_pipeline_bridge USE_ADDRESS "1"
    set_instance_parameter mm_pipeline_bridge USE_BURSTCOUNT "0"
    set_instance_parameter mm_pipeline_bridge USE_READDATAVALID "0"
    set_instance_parameter mm_pipeline_bridge USE_WAITREQUEST "1"
    set_instance_parameter mm_pipeline_bridge USE_LOCK "0"
    set_instance_parameter mm_pipeline_bridge AV_SYMBOLS_PER_WORD "4"
    set_instance_parameter mm_pipeline_bridge AV_ADDRESS_SYMBOLS "0"
    set_instance_parameter mm_pipeline_bridge AV_BURSTCOUNT_SYMBOLS "0"
    set_instance_parameter mm_pipeline_bridge AV_CONSTANT_BURST_BEHAVIOR "0"
    set_instance_parameter mm_pipeline_bridge AV_LINEWRAPBURSTS "0"
    set_instance_parameter mm_pipeline_bridge AV_MAX_PENDING_READ_TRANSACTIONS "0"
    set_instance_parameter mm_pipeline_bridge AV_BURSTBOUNDARIES "0"
    set_instance_parameter mm_pipeline_bridge AV_INTERLEAVEBURSTS "0"
    set_instance_parameter mm_pipeline_bridge AV_BITS_PER_SYMBOL "8"
    set_instance_parameter mm_pipeline_bridge AV_ISBIGENDIAN "0"
    set_instance_parameter mm_pipeline_bridge AV_ADDRESSGROUP "0"
    set_instance_parameter mm_pipeline_bridge UAV_ADDRESSGROUP "0"
    set_instance_parameter mm_pipeline_bridge AV_REGISTEROUTGOINGSIGNALS "0"
    set_instance_parameter mm_pipeline_bridge AV_REGISTERINCOMINGSIGNALS "0"
    set_instance_parameter mm_pipeline_bridge AV_ALWAYSBURSTMAXBURST "0"
    
    #  Export Out

    #  Loopback TX SINK
    add_interface lb_tx_sink_data avalon_streaming end
    set_interface_property lb_tx_sink_data export_of lc_splitter_timing_adapter.in
    
    #  Loopback TX SRC
    add_interface lb_tx_src_data avalon_streaming start
    set_interface_property lb_tx_src_data export_of line_lb_timing_adapter.out
    
    # Loopback RX SINK
    add_interface lb_rx_sink_data avalon_streaming end 
    set_interface_property lb_rx_sink_data export_of line_splitter_timing_adapter.in
    
    #  Loopback RX SRC
    add_interface lb_rx_src_data avalon_streaming start
    set_interface_property lb_rx_src_data export_of lc_lb_timing_adapter.out
    
    #  Export Merlin Master Translator
    add_interface csr avalon end
    set_interface_property csr export_of mm_pipeline_bridge.avalon_anti_master_0

    #  Connections
    add_connection tx_clk_module.clk/lc_splitter_timing_adapter.clk
    add_connection tx_clk_module.clk_reset/lc_splitter_timing_adapter.reset
    
    add_connection tx_clk_module.clk/local_splitter.clk
    add_connection tx_clk_module.clk_reset/local_splitter.reset
    
    add_connection tx_clk_module.clk/line_loopback.clock
    add_connection tx_clk_module.clk_reset/line_loopback.clock_reset
    
    add_connection tx_clk_module.clk/line_lb_timing_adapter.clk
    add_connection tx_clk_module.clk_reset/line_lb_timing_adapter.reset
    
    add_connection rx_clk_module.clk/line_splitter_timing_adapter.clk
    add_connection rx_clk_module.clk_reset/line_splitter_timing_adapter.reset
    
    add_connection rx_clk_module.clk/line_splitter.clk  
    add_connection rx_clk_module.clk_reset/line_splitter.reset  
    
    add_connection rx_clk_module.clk/local_loopback.clock
    add_connection rx_clk_module.clk_reset/local_loopback.clock_reset  
    
    add_connection rx_clk_module.clk/lc_lb_timing_adapter.clk
    add_connection rx_clk_module.clk_reset/lc_lb_timing_adapter.reset
    
    add_connection csr_clk_module.clk/mm_pipeline_bridge.clk
    add_connection csr_clk_module.clk_reset/mm_pipeline_bridge.reset
    
    # RX <-> TX
    add_connection tx_clk_module.clk/dc_fifo_1.in_clk
    add_connection tx_clk_module.clk_reset/dc_fifo_1.in_clk_reset
    
    
    add_connection rx_clk_module.clk/dc_fifo_1.out_clk
    add_connection rx_clk_module.clk_reset/dc_fifo_1.out_clk_reset
    
    
    add_connection rx_clk_module.clk/dc_fifo_2.in_clk
    add_connection rx_clk_module.clk_reset/dc_fifo_2.in_clk_reset
    
    add_connection tx_clk_module.clk/dc_fifo_2.out_clk
    add_connection tx_clk_module.clk_reset/dc_fifo_2.out_clk_reset
    
    
    
    add_connection lc_splitter_timing_adapter.out/local_splitter.in
    add_connection local_splitter.out0/line_loopback.avalon_streaming_sink
    add_connection local_splitter.out1/dc_fifo_1.in
    add_connection dc_fifo_1.out/local_loopback.avalon_streaming_sink_1    
    add_connection line_loopback.avalon_streaming_source/line_lb_timing_adapter.in
    
    add_connection line_splitter_timing_adapter.out/line_splitter.in
    add_connection line_splitter.out0/dc_fifo_2.in
    add_connection dc_fifo_2.out/line_loopback.avalon_streaming_sink_1    
    add_connection line_splitter.out1/local_loopback.avalon_streaming_sink
    add_connection local_loopback.avalon_streaming_source/lc_lb_timing_adapter.in
    
    # AV-MM
    add_connection mm_pipeline_bridge.avalon_universal_master_0/local_loopback.control
    add_connection mm_pipeline_bridge.avalon_universal_master_0/line_loopback.control
    
    ## Connection mm_pipeline_bridge.avalon_universal_master_0/local_loopback.control
    set_connection_parameter_value mm_pipeline_bridge.avalon_universal_master_0/local_loopback.control arbitrationPriority "1"
    set_connection_parameter_value mm_pipeline_bridge.avalon_universal_master_0/local_loopback.control baseAddress "0x0008"
       
    
    ## Connection mm_pipeline_bridge.avalon_universal_master_0/line_loopback.control
    set_connection_parameter_value mm_pipeline_bridge.avalon_universal_master_0/line_loopback.control arbitrationPriority "1"
    set_connection_parameter_value mm_pipeline_bridge.avalon_universal_master_0/line_loopback.control baseAddress "0x0000"
}



