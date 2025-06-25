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
# | module altera_eth10g_mac
# |
set_module_property NAME altera_eth_2_5g_mac
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property DISPLAY_NAME "Ethernet 2.5G MAC"
set_module_property DESCRIPTION "Altera Ethernet 2.5G MAC"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSE_CALLBACK compose
set_module_property VALIDATION_CALLBACK validate
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
add_parameter ENABLE_SUPP_ADDR INTEGER 1
set_parameter_property ENABLE_SUPP_ADDR DISPLAY_NAME "Enable Supplementary Address"
set_parameter_property ENABLE_SUPP_ADDR DISPLAY_HINT boolean
set_parameter_property ENABLE_SUPP_ADDR DESCRIPTION "Enable Supplementary Address Feature"


add_parameter ENABLE_STATISTICS INTEGER 1
set_parameter_property ENABLE_STATISTICS DISPLAY_NAME "Enable Statistics"
set_parameter_property ENABLE_STATISTICS DISPLAY_HINT boolean
set_parameter_property ENABLE_STATISTICS DESCRIPTION "Enable Statistics Feature"

add_parameter REGISTER_BASED_STATISTICS INTEGER 0
set_parameter_property REGISTER_BASED_STATISTICS DISPLAY_NAME "Register-based Statistics"
set_parameter_property REGISTER_BASED_STATISTICS DISPLAY_HINT boolean
set_parameter_property REGISTER_BASED_STATISTICS DISPLAY_HINT "boolean"
set_parameter_property REGISTER_BASED_STATISTICS DESCRIPTION "Enable Statistics Implemented Using Register"

# |
# +-----------------------------------

sopc::preview_add_transform "foo" "PREVIEW_AVALON_MM_TRANSFORM"

proc validate {} {
    set stat_ena [get_parameter_value ENABLE_STATISTICS]
    if {$stat_ena == 0} {
    set_parameter_property REGISTER_BASED_STATISTICS ENABLED false
    } else {
    set_parameter_property REGISTER_BASED_STATISTICS ENABLED true
    }
    
}

proc compose {} {

    set supp_addr_ena [get_parameter_value ENABLE_SUPP_ADDR]
    set stat_ena [get_parameter_value ENABLE_STATISTICS]
    set reg_stat [get_parameter_value REGISTER_BASED_STATISTICS]
    #  TX Clock Source 
    add_instance tx_clk_module clock_source  
    set_instance_parameter tx_clk_module clockFrequencyKnown "true"
    set_instance_parameter tx_clk_module clockFrequency "39062500"
    
    add_interface tx_clk clock end
    set_interface_property tx_clk export_of tx_clk_module.clk_in
    # TX Reset
    add_interface tx_reset reset end
    set_interface_property tx_reset export_of tx_clk_module.clk_in_reset

    #  RX Clock Source 
    add_instance rx_clk_module clock_source  
    set_instance_parameter rx_clk_module clockFrequencyKnown "true"
    set_instance_parameter rx_clk_module clockFrequency "39062500"
    
    add_interface rx_clk clock end
    set_interface_property rx_clk export_of rx_clk_module.clk_in
    # RX Reset
    add_interface rx_reset reset end
    set_interface_property rx_reset export_of rx_clk_module.clk_in_reset



    #  GMII RX Clock Source 
    add_instance rx_gmii_clk_module clock_source  
    set_instance_parameter rx_gmii_clk_module clockFrequencyKnown "true"
    set_instance_parameter rx_gmii_clk_module clockFrequency "156250000"
    
    add_interface rx_gmii_clk clock end
    set_interface_property rx_gmii_clk export_of rx_gmii_clk_module.clk_in
    # GMII RX Reset
    add_interface rx_gmii_reset reset end
    set_interface_property rx_gmii_reset export_of rx_gmii_clk_module.clk_in_reset


    #  GMII RX Clock Source 
    add_instance tx_gmii_clk_module clock_source  
    set_instance_parameter tx_gmii_clk_module clockFrequencyKnown "true"
    set_instance_parameter tx_gmii_clk_module clockFrequency "156250000"
    
    add_interface tx_gmii_clk clock end
    set_interface_property tx_gmii_clk export_of tx_gmii_clk_module.clk_in
    # GMII RX Reset
    add_interface tx_gmii_reset reset end
    set_interface_property tx_gmii_reset export_of tx_gmii_clk_module.clk_in_reset
    
    #  CSR Clock Source 
    add_instance csr_clk_module clock_source  
    set_instance_parameter csr_clk_module clockFrequencyKnown "true"
    set_instance_parameter csr_clk_module clockFrequency "122000000"
    
    add_interface csr_clk clock end
    set_interface_property csr_clk export_of csr_clk_module.clk_in
    # CSR Reset
    add_interface csr_reset reset end
    set_interface_property csr_reset export_of csr_clk_module.clk_in_reset
    

    #  Lane Decoder RX
    add_instance rx_eth_lane_decoder altera_eth_lane_decoder_2_5g 

  


    #  Packet Back Pressure RX
    add_instance rx_eth_pkt_backpressure_control altera_eth_pkt_backpressure_control 
    set_instance_parameter rx_eth_pkt_backpressure_control BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_pkt_backpressure_control SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_pkt_backpressure_control ERROR_WIDTH "1"
    set_instance_parameter rx_eth_pkt_backpressure_control USE_READY "0"
    set_instance_parameter rx_eth_pkt_backpressure_control USE_PAUSE "0"

    #  CRC Checker Rx
    add_instance rx_eth_crc altera_eth_crc 
    set_instance_parameter rx_eth_crc BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_crc SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_crc ERROR_WIDTH "1"
    set_instance_parameter rx_eth_crc MODE_CHECKER_0_INSERTER_1 "0"
    set_instance_parameter rx_eth_crc USE_READY "false"
    set_instance_parameter rx_eth_crc USE_CHANNEL "0"

    #  Frame Decoder RX
    add_instance rx_eth_frame_decoder altera_eth_frame_decoder_2_5g 
    set_instance_parameter rx_eth_frame_decoder BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_frame_decoder SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_frame_decoder ERROR_WIDTH "2"
    set_instance_parameter rx_eth_frame_decoder ENABLE_SUPP_ADDR $supp_addr_ena
    set_instance_parameter rx_eth_frame_decoder ENABLE_DATA_SOURCE "1"
    set_instance_parameter rx_eth_frame_decoder ENABLE_PAUSELEN "1"
    set_instance_parameter rx_eth_frame_decoder ENABLE_PKTINFO "1"
    set_instance_parameter rx_eth_frame_decoder USE_READY "0"

    if {$stat_ena == 1} {

    #  ERROR Adapter
    add_instance error_adapter_rx error_adapter
    set_instance_parameter error_adapter_rx generationLanguage "VERILOG"
    set_instance_parameter error_adapter_rx inBitsPerSymbol "39"
    set_instance_parameter error_adapter_rx inChannelWidth "0"
    set_instance_parameter error_adapter_rx inErrorDescriptor "payload_length,oversize,undersize,crc,phy"
    set_instance_parameter error_adapter_rx inErrorWidth "5"
    set_instance_parameter error_adapter_rx inMaxChannel "0"
    set_instance_parameter error_adapter_rx inReadyLatency "0"
    set_instance_parameter error_adapter_rx inSymbolsPerBeat "1"
    set_instance_parameter error_adapter_rx inUseEmpty "false"
    set_instance_parameter error_adapter_rx inUseEmptyPort "AUTO"
    set_instance_parameter error_adapter_rx inUsePackets "false"
    set_instance_parameter error_adapter_rx inUseReady "false"
    set_instance_parameter error_adapter_rx moduleName ""
    set_instance_parameter error_adapter_rx outErrorDescriptor "phy,user,underflow,crc,payload_length,oversize,undersize"
    set_instance_parameter error_adapter_rx outErrorWidth "7"
    
    #  Module Timing Adapter 4
    add_instance timing_adapter_4 timing_adapter
    set_instance_parameter timing_adapter_4 generationLanguage "VERILOG"
    set_instance_parameter timing_adapter_4 inBitsPerSymbol "39"
    set_instance_parameter timing_adapter_4 inChannelWidth "0"
    set_instance_parameter timing_adapter_4 inErrorDescriptor ""
    set_instance_parameter timing_adapter_4 inErrorWidth "7"
    set_instance_parameter timing_adapter_4 inMaxChannel "0"
    set_instance_parameter timing_adapter_4 inReadyLatency "0"
    set_instance_parameter timing_adapter_4 inSymbolsPerBeat "1"
    set_instance_parameter timing_adapter_4 inUseEmpty "true"
    set_instance_parameter timing_adapter_4 inUseEmptyPort "YES"
    set_instance_parameter timing_adapter_4 inUsePackets "false"
    set_instance_parameter timing_adapter_4 inUseReady "false"
    set_instance_parameter timing_adapter_4 inUseValid "true"
    set_instance_parameter timing_adapter_4 moduleName ""
    set_instance_parameter timing_adapter_4 outReadyLatency "0"
    set_instance_parameter timing_adapter_4 outUseReady "true"
    set_instance_parameter timing_adapter_4 outUseValid "true"       
    

    # SPLITTER FOR ERROR_ADAPTER
    add_instance rxstatus_st_splitter altera_avalon_st_splitter 
    set_instance_parameter rxstatus_st_splitter NUMBER_OF_OUTPUTS "2"
    set_instance_parameter rxstatus_st_splitter QUALIFY_VALID_OUT "1"
    set_instance_parameter rxstatus_st_splitter DATA_WIDTH "39"
    set_instance_parameter rxstatus_st_splitter BITS_PER_SYMBOL "39"
    set_instance_parameter rxstatus_st_splitter USE_PACKETS "0"
    set_instance_parameter rxstatus_st_splitter USE_CHANNEL "0"
    set_instance_parameter rxstatus_st_splitter CHANNEL_WIDTH "1"
    set_instance_parameter rxstatus_st_splitter MAX_CHANNELS "1"
    set_instance_parameter rxstatus_st_splitter USE_ERROR "1"
    set_instance_parameter rxstatus_st_splitter ERROR_WIDTH "7"       

    #  Module Timing Adapter 5
    add_instance timing_adapter_5 timing_adapter
    set_instance_parameter timing_adapter_5 generationLanguage "VERILOG"
    set_instance_parameter timing_adapter_5 inBitsPerSymbol "39"
    set_instance_parameter timing_adapter_5 inChannelWidth "0"
    set_instance_parameter timing_adapter_5 inErrorDescriptor ""
    set_instance_parameter timing_adapter_5 inErrorWidth "7"
    set_instance_parameter timing_adapter_5 inMaxChannel "0"
    set_instance_parameter timing_adapter_5 inReadyLatency "0"
    set_instance_parameter timing_adapter_5 inSymbolsPerBeat "1"
    set_instance_parameter timing_adapter_5 inUseEmpty "true"
    set_instance_parameter timing_adapter_5 inUseEmptyPort "YES"
    set_instance_parameter timing_adapter_5 inUsePackets "false"
    set_instance_parameter timing_adapter_5 inUseReady "true"
    set_instance_parameter timing_adapter_5 inUseValid "true"
    set_instance_parameter timing_adapter_5 moduleName ""
    set_instance_parameter timing_adapter_5 outReadyLatency "0"
    set_instance_parameter timing_adapter_5 outUseReady "false"
    set_instance_parameter timing_adapter_5 outUseValid "true"           

    #  Module Timing Adapter 6
    add_instance timing_adapter_6 timing_adapter
    set_instance_parameter timing_adapter_6 generationLanguage "VERILOG"
    set_instance_parameter timing_adapter_6 inBitsPerSymbol "39"
    set_instance_parameter timing_adapter_6 inChannelWidth "0"
    set_instance_parameter timing_adapter_6 inErrorDescriptor ""
    set_instance_parameter timing_adapter_6 inErrorWidth "7"
    set_instance_parameter timing_adapter_6 inMaxChannel "0"
    set_instance_parameter timing_adapter_6 inReadyLatency "0"
    set_instance_parameter timing_adapter_6 inSymbolsPerBeat "1"
    set_instance_parameter timing_adapter_6 inUseEmpty "true"
    set_instance_parameter timing_adapter_6 inUseEmptyPort "YES"
    set_instance_parameter timing_adapter_6 inUsePackets "false"
    set_instance_parameter timing_adapter_6 inUseReady "true"
    set_instance_parameter timing_adapter_6 inUseValid "true"
    set_instance_parameter timing_adapter_6 moduleName ""
    set_instance_parameter timing_adapter_6 outReadyLatency "0"
    set_instance_parameter timing_adapter_6 outUseReady "false"
    set_instance_parameter timing_adapter_6 outUseValid "true"               

    #  Bit Inserter
    add_instance rx_eth_databus_bit_inserter altera_eth_databus_bit_inserter
    
        if {$reg_stat == 1} {
        #  Statistics Collector TX Register-Based
        add_instance rx_eth_statistics_collector altera_eth_statistics_collector
        set_instance_parameter rx_eth_statistics_collector STATUS_WIDTH "40"                  
        } else {
        # Statistics Collector TX Memory-Based
        add_instance rx_eth_statistics_collector altera_eth_10gmem_statistics_collector
        set_instance_parameter rx_eth_statistics_collector STATUS_WIDTH "40" 
        }
    } else {

    #  ERROR Adapter
    add_instance error_adapter_rx error_adapter
    set_instance_parameter error_adapter_rx generationLanguage "VERILOG"
    set_instance_parameter error_adapter_rx inBitsPerSymbol "39"
    set_instance_parameter error_adapter_rx inChannelWidth "0"
    set_instance_parameter error_adapter_rx inErrorDescriptor "payload_length,oversize,undersize,crc,phy"
    set_instance_parameter error_adapter_rx inErrorWidth "5"
    set_instance_parameter error_adapter_rx inMaxChannel "0"
    set_instance_parameter error_adapter_rx inReadyLatency "0"
    set_instance_parameter error_adapter_rx inSymbolsPerBeat "1"
    set_instance_parameter error_adapter_rx inUseEmpty "false"
    set_instance_parameter error_adapter_rx inUseEmptyPort "AUTO"
    set_instance_parameter error_adapter_rx inUsePackets "false"
    set_instance_parameter error_adapter_rx inUseReady "false"
    set_instance_parameter error_adapter_rx moduleName ""
    set_instance_parameter error_adapter_rx outErrorDescriptor "phy,user,underflow,crc,payload_length,oversize,undersize"
    set_instance_parameter error_adapter_rx outErrorWidth "7"

    }   

    #  CRC Pad Remover
    add_instance rx_eth_crc_pad_rem altera_eth_crc_pad_rem 
    set_instance_parameter rx_eth_crc_pad_rem BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_crc_pad_rem SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_crc_pad_rem ERRORWIDTH "5"

    #  Overflow Controller RX
    add_instance rx_eth_packet_overflow_control altera_eth_packet_overflow_control    
    set_instance_parameter rx_eth_packet_overflow_control BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_packet_overflow_control SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_packet_overflow_control ERROR_WIDTH "5"
    
    
    # DC Fifo 1 ( frame decoder to pkt backpressure )
    add_instance dc_fifo_2 altera_avalon_dc_fifo
    set_instance_parameter dc_fifo_2 SYMBOLS_PER_BEAT "1"
    set_instance_parameter dc_fifo_2 BITS_PER_SYMBOL "32"
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
    

    
    #  Module Timing Adapter 9
    add_instance timing_adapter_9 timing_adapter
    set_instance_parameter timing_adapter_9 generationLanguage "VERILOG"
    set_instance_parameter timing_adapter_9 inBitsPerSymbol "32"
    set_instance_parameter timing_adapter_9 inChannelWidth "0"
    set_instance_parameter timing_adapter_9 inErrorDescriptor ""
    set_instance_parameter timing_adapter_9 inErrorWidth "0"
    set_instance_parameter timing_adapter_9 inMaxChannel "0"
    set_instance_parameter timing_adapter_9 inReadyLatency "0"
    set_instance_parameter timing_adapter_9 inSymbolsPerBeat "1"
    set_instance_parameter timing_adapter_9 inUseEmpty "true"
    set_instance_parameter timing_adapter_9 inUseEmptyPort "YES"
    set_instance_parameter timing_adapter_9 inUsePackets "false"
    set_instance_parameter timing_adapter_9 inUseReady "false"
    set_instance_parameter timing_adapter_9 inUseValid "true"
    set_instance_parameter timing_adapter_9 moduleName ""
    set_instance_parameter timing_adapter_9 outReadyLatency "0"
    set_instance_parameter timing_adapter_9 outUseReady "true"
    set_instance_parameter timing_adapter_9 outUseValid "true"

    #  Module Timing Adapter 10
    add_instance timing_adapter_10 timing_adapter
    set_instance_parameter timing_adapter_10 generationLanguage "VERILOG"
    set_instance_parameter timing_adapter_10 inBitsPerSymbol "32"
    set_instance_parameter timing_adapter_10 inChannelWidth "0"
    set_instance_parameter timing_adapter_10 inErrorDescriptor ""
    set_instance_parameter timing_adapter_10 inErrorWidth "0"
    set_instance_parameter timing_adapter_10 inMaxChannel "0"
    set_instance_parameter timing_adapter_10 inReadyLatency "0"
    set_instance_parameter timing_adapter_10 inSymbolsPerBeat "1"
    set_instance_parameter timing_adapter_10 inUseEmpty "true"
    set_instance_parameter timing_adapter_10 inUseEmptyPort "YES"
    set_instance_parameter timing_adapter_10 inUsePackets "false"
    set_instance_parameter timing_adapter_10 inUseReady "true"
    set_instance_parameter timing_adapter_10 inUseValid "true"
    set_instance_parameter timing_adapter_10 moduleName ""
    set_instance_parameter timing_adapter_10 outReadyLatency "0"
    set_instance_parameter timing_adapter_10 outUseReady "false"
    set_instance_parameter timing_adapter_10 outUseValid "true"   
    
    #  Underflow Controller   
    add_instance eth_packet_underflow_control altera_eth_packet_underflow_control
    set_instance_parameter eth_packet_underflow_control BITSPERSYMBOL "8"
    set_instance_parameter eth_packet_underflow_control SYMBOLSPERBEAT "8"
    set_instance_parameter eth_packet_underflow_control ERROR_WIDTH "1"

    #  Pad Inserter TX
    add_instance tx_eth_pad_inserter altera_eth_pad_inserter 
    set_instance_parameter tx_eth_pad_inserter BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_pad_inserter SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_pad_inserter ERROR_WIDTH "2"   

    #  Back Pressure Controller TX
    add_instance tx_eth_pkt_backpressure_control altera_eth_pkt_backpressure_control 
    set_instance_parameter tx_eth_pkt_backpressure_control BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_pkt_backpressure_control SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_pkt_backpressure_control ERROR_WIDTH "2"
    set_instance_parameter tx_eth_pkt_backpressure_control USE_READY "1"
    set_instance_parameter tx_eth_pkt_backpressure_control USE_PAUSE "1"
    
    # Pause Controller
    add_instance tx_pause_ctrl_gen altera_eth_pause_ctrl_gen
    set_instance_parameter tx_pause_ctrl_gen BITSPERSYMBOL "8"
    set_instance_parameter tx_pause_ctrl_gen SYMBOLSPERBEAT "8"
    set_instance_parameter tx_pause_ctrl_gen ERROR_WIDTH "1"
    
    #  Error Adapter for Pause Controller
    add_instance pause_ctrl_error_adapter error_adapter
    set_instance_parameter pause_ctrl_error_adapter generationLanguage "VERILOG"
    set_instance_parameter pause_ctrl_error_adapter inBitsPerSymbol "8"
    set_instance_parameter pause_ctrl_error_adapter inChannelWidth "0"
    set_instance_parameter pause_ctrl_error_adapter inErrorDescriptor ""
    set_instance_parameter pause_ctrl_error_adapter inErrorWidth "1"
    set_instance_parameter pause_ctrl_error_adapter inMaxChannel "0"
    set_instance_parameter pause_ctrl_error_adapter inReadyLatency "0"
    set_instance_parameter pause_ctrl_error_adapter inSymbolsPerBeat "8"
    set_instance_parameter pause_ctrl_error_adapter inUseEmpty "true"
    set_instance_parameter pause_ctrl_error_adapter inUseEmptyPort "AUTO"
    set_instance_parameter pause_ctrl_error_adapter inUsePackets "true"
    set_instance_parameter pause_ctrl_error_adapter inUseReady "true"
    set_instance_parameter pause_ctrl_error_adapter moduleName ""
    set_instance_parameter pause_ctrl_error_adapter outErrorDescriptor ""
    set_instance_parameter pause_ctrl_error_adapter outErrorWidth "2"   
    
    # Avalon ST Multiplexer
    add_instance tx_mux multiplexer
    set_instance_parameter tx_mux bitsPerSymbol "8"
    set_instance_parameter tx_mux errorWidth "2"
    set_instance_parameter tx_mux generationLanguage "VERILOG"
    set_instance_parameter tx_mux moduleName ""
    set_instance_parameter tx_mux numInputInterfaces "2"
    set_instance_parameter tx_mux outChannelWidth "1"
    set_instance_parameter tx_mux packetScheduling "true"
    set_instance_parameter tx_mux schedulingSize "2"
    set_instance_parameter tx_mux symbolsPerBeat "8"
    set_instance_parameter tx_mux useHighBitsOfChannel "true"
    set_instance_parameter tx_mux usePackets "true"    
    
    # Channel Adapter
    add_instance tx_channel_adapter altera_eth_channel_adapter
    set_instance_parameter tx_channel_adapter ERROR_WIDTH "3"

    #  Address Inserter TX
    add_instance tx_eth_address_inserter altera_eth_address_inserter 
    set_instance_parameter tx_eth_address_inserter BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_address_inserter SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_address_inserter ERROR_WIDTH "2"

    #  CRC Inserter TX
    add_instance tx_eth_crc altera_eth_crc      
    set_instance_parameter tx_eth_crc BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_crc SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_crc ERROR_WIDTH "2"
    set_instance_parameter tx_eth_crc MODE_CHECKER_0_INSERTER_1 "1"
    set_instance_parameter tx_eth_crc USE_READY "true"
    set_instance_parameter tx_eth_crc USE_CHANNEL "1"

    #  Pipeline Stage
    add_instance st_pipeline_stage_0 altera_avalon_st_pipeline_stage
    set_instance_parameter st_pipeline_stage_0 SYMBOLS_PER_BEAT "8"
    set_instance_parameter st_pipeline_stage_0 BITS_PER_SYMBOL "8"
    set_instance_parameter st_pipeline_stage_0 USE_PACKETS "1"
    set_instance_parameter st_pipeline_stage_0 USE_EMPTY "1"
    set_instance_parameter st_pipeline_stage_0 CHANNEL_WIDTH "0"
    set_instance_parameter st_pipeline_stage_0 ERROR_WIDTH "3"
    set_instance_parameter st_pipeline_stage_0 PIPELINE_READY "1"   

    if {$stat_ena == 1} {
    #  Avalon ST Splitter TX
    add_instance tx_st_splitter altera_avalon_st_splitter 
    set_instance_parameter tx_st_splitter NUMBER_OF_OUTPUTS "2"
    set_instance_parameter tx_st_splitter QUALIFY_VALID_OUT "1"
    set_instance_parameter tx_st_splitter DATA_WIDTH "64"
    set_instance_parameter tx_st_splitter BITS_PER_SYMBOL "8"
    set_instance_parameter tx_st_splitter USE_PACKETS "1"
    set_instance_parameter tx_st_splitter USE_CHANNEL "0"
    set_instance_parameter tx_st_splitter CHANNEL_WIDTH "1"
    set_instance_parameter tx_st_splitter MAX_CHANNELS "1"
    set_instance_parameter tx_st_splitter USE_ERROR "1"
    set_instance_parameter tx_st_splitter ERROR_WIDTH "3"

    #  Module Timing Adapter 3
    add_instance timing_adapter_3 timing_adapter
    set_instance_parameter timing_adapter_3 generationLanguage "VERILOG"
    set_instance_parameter timing_adapter_3 inBitsPerSymbol "8"
    set_instance_parameter timing_adapter_3 inChannelWidth "0"
    set_instance_parameter timing_adapter_3 inErrorDescriptor ""
    set_instance_parameter timing_adapter_3 inErrorWidth "3"
    set_instance_parameter timing_adapter_3 inMaxChannel "0"
    set_instance_parameter timing_adapter_3 inReadyLatency "0"
    set_instance_parameter timing_adapter_3 inSymbolsPerBeat "8"
    set_instance_parameter timing_adapter_3 inUseEmpty "true"
    set_instance_parameter timing_adapter_3 inUseEmptyPort "YES"
    set_instance_parameter timing_adapter_3 inUsePackets "true"
    set_instance_parameter timing_adapter_3 inUseReady "true"
    set_instance_parameter timing_adapter_3 inUseValid "true"
    set_instance_parameter timing_adapter_3 moduleName ""
    set_instance_parameter timing_adapter_3 outReadyLatency "0"
    set_instance_parameter timing_adapter_3 outUseReady "false"
    set_instance_parameter timing_adapter_3 outUseValid "true"    
       
    #  Frame Decoder TX
    add_instance tx_eth_frame_decoder altera_eth_frame_decoder_2_5g 
    set_instance_parameter tx_eth_frame_decoder BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_frame_decoder SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_frame_decoder ERROR_WIDTH "3"
    set_instance_parameter tx_eth_frame_decoder ENABLE_SUPP_ADDR $supp_addr_ena
    set_instance_parameter tx_eth_frame_decoder ENABLE_DATA_SOURCE "0"
    set_instance_parameter tx_eth_frame_decoder ENABLE_PAUSELEN "0"
    set_instance_parameter tx_eth_frame_decoder ENABLE_PKTINFO "0"
    set_instance_parameter tx_eth_frame_decoder USE_READY "0"

    #  ERROR Adapter
    add_instance error_adapter_tx error_adapter
    set_instance_parameter error_adapter_tx generationLanguage "VERILOG"
    set_instance_parameter error_adapter_tx inBitsPerSymbol "39"
    set_instance_parameter error_adapter_tx inChannelWidth "0"
    set_instance_parameter error_adapter_tx inErrorDescriptor "payload_length,oversize,undersize,crc,underflow,user"
    set_instance_parameter error_adapter_tx inErrorWidth "6"
    set_instance_parameter error_adapter_tx inMaxChannel "0"
    set_instance_parameter error_adapter_tx inReadyLatency "0"
    set_instance_parameter error_adapter_tx inSymbolsPerBeat "1"
    set_instance_parameter error_adapter_tx inUseEmpty "false"
    set_instance_parameter error_adapter_tx inUseEmptyPort "AUTO"
    set_instance_parameter error_adapter_tx inUsePackets "false"
    set_instance_parameter error_adapter_tx inUseReady "false"
    set_instance_parameter error_adapter_tx moduleName ""
    set_instance_parameter error_adapter_tx outErrorDescriptor "phy,user,underflow,crc,payload_length,oversize,undersize"
    set_instance_parameter error_adapter_tx outErrorWidth "7"   

    #  Bit Inserter
    add_instance tx_eth_databus_bit_inserter altera_eth_databus_bit_inserter
 
        if {$reg_stat == 1} {
             #  Statistics Collector TX
            add_instance tx_eth_statistics_collector altera_eth_statistics_collector
            set_instance_parameter tx_eth_statistics_collector STATUS_WIDTH "40"                   
        } else {
            # Statistics Collector TX Memory Based
            add_instance tx_eth_statistics_collector altera_eth_10gmem_statistics_collector
            set_instance_parameter tx_eth_statistics_collector STATUS_WIDTH "40" 
        }

    } else {


    }
 
    add_instance lane_encoder altera_eth_lane_encoder_2_5g

    #  Merlin Master Translator
    add_instance merlin_master_translator altera_merlin_master_translator 
    set_instance_parameter merlin_master_translator AV_ADDRESS_W "9"
    set_instance_parameter merlin_master_translator AV_DATA_W "32"
    set_instance_parameter merlin_master_translator AV_BURSTCOUNT_W "1"
    set_instance_parameter merlin_master_translator AV_BYTEENABLE_W "4"
    set_instance_parameter merlin_master_translator UAV_ADDRESS_W "11"
    set_instance_parameter merlin_master_translator UAV_BURSTCOUNT_W "3"
    set_instance_parameter merlin_master_translator AV_READLATENCY "0"
    set_instance_parameter merlin_master_translator AV_WRITE_WAIT "0"
    set_instance_parameter merlin_master_translator AV_READ_WAIT "0"
    set_instance_parameter merlin_master_translator AV_DATA_HOLD "0"
    set_instance_parameter merlin_master_translator AV_SETUP_WAIT "0"
    set_instance_parameter merlin_master_translator USE_READDATA "1"
    set_instance_parameter merlin_master_translator USE_WRITEDATA "1"
    set_instance_parameter merlin_master_translator USE_READ "1"
    set_instance_parameter merlin_master_translator USE_WRITE "1"
    set_instance_parameter merlin_master_translator USE_BEGINBURSTTRANSFER "0"
    set_instance_parameter merlin_master_translator USE_BEGINTRANSFER "0"
    set_instance_parameter merlin_master_translator USE_BYTEENABLE "0"
    set_instance_parameter merlin_master_translator USE_CHIPSELECT "0"
    set_instance_parameter merlin_master_translator USE_ADDRESS "1"
    set_instance_parameter merlin_master_translator USE_BURSTCOUNT "0"
    set_instance_parameter merlin_master_translator USE_READDATAVALID "0"
    set_instance_parameter merlin_master_translator USE_WAITREQUEST "1"
    set_instance_parameter merlin_master_translator USE_LOCK "0"
    set_instance_parameter merlin_master_translator AV_SYMBOLS_PER_WORD "4"
    set_instance_parameter merlin_master_translator AV_ADDRESS_SYMBOLS "0"
    set_instance_parameter merlin_master_translator AV_BURSTCOUNT_SYMBOLS "0"
    set_instance_parameter merlin_master_translator AV_CONSTANT_BURST_BEHAVIOR "0"
    set_instance_parameter merlin_master_translator AV_LINEWRAPBURSTS "0"
    set_instance_parameter merlin_master_translator AV_MAX_PENDING_READ_TRANSACTIONS "0"
    set_instance_parameter merlin_master_translator AV_BURSTBOUNDARIES "0"
    set_instance_parameter merlin_master_translator AV_INTERLEAVEBURSTS "0"
    set_instance_parameter merlin_master_translator AV_BITS_PER_SYMBOL "8"
    set_instance_parameter merlin_master_translator AV_ISBIGENDIAN "0"
    set_instance_parameter merlin_master_translator AV_ADDRESSGROUP "0"
    set_instance_parameter merlin_master_translator UAV_ADDRESSGROUP "0"
    set_instance_parameter merlin_master_translator AV_REGISTEROUTGOINGSIGNALS "0"
    set_instance_parameter merlin_master_translator AV_REGISTERINCOMINGSIGNALS "0"
    set_instance_parameter merlin_master_translator AV_ALWAYSBURSTMAXBURST "0"


    #  Export Out

    #  GMII RX
    add_interface gmii_rx_data avalon_streaming end
    set_interface_property gmii_rx_data export_of rx_eth_lane_decoder.avalon_sink_gmii_data
    add_interface gmii_rx_control avalon_streaming end
    set_interface_property gmii_rx_control export_of rx_eth_lane_decoder.avalon_sink_gmii_control

    #  Export Frame Decoder RX
    add_interface avalon_st_rxstatus avalon_streaming start
    
    #  Export Pause Frame
    add_interface avalon_st_pause avalon_streaming end
    set_interface_property avalon_st_pause export_of tx_pause_ctrl_gen.pause_control
    
    #  Export Packet Overflow Controller RX
    add_interface avalon_st_rx avalon_streaming start
    set_interface_property avalon_st_rx export_of rx_eth_packet_overflow_control.avalon_streaming_source

    #  Export Back Pressure Controller TX
    add_interface avalon_st_tx avalon_streaming end
    set_interface_property avalon_st_tx export_of eth_packet_underflow_control.avalon_streaming_sink

    #  Export of Link Fault Generation
    add_interface gmii_data_tx avalon_streaming start
    add_interface gmii_enable_tx avalon_streaming start
    set_interface_property gmii_data_tx export_of lane_encoder.source_gmii_data
    set_interface_property gmii_enable_tx export_of lane_encoder.source_gmii_control

    #  Export Merlin Master Translator
    add_interface csr avalon end
    set_interface_property csr export_of merlin_master_translator.avalon_anti_master_0

    #  Connections
    add_connection rx_clk_module.clk/rx_eth_lane_decoder.clock_reset_mac
    add_connection rx_clk_module.clk_reset/rx_eth_lane_decoder.clock_reset_mac_reset
    add_connection rx_gmii_clk_module.clk/rx_eth_lane_decoder.clock_reset_gmii
    add_connection rx_gmii_clk_module.clk_reset/rx_eth_lane_decoder.clock_reset_gmii_reset
    add_connection rx_clk_module.clk/rx_eth_pkt_backpressure_control.clock_reset
    add_connection rx_clk_module.clk_reset/rx_eth_pkt_backpressure_control.clock_reset_reset
    add_connection rx_clk_module.clk_reset/rx_eth_pkt_backpressure_control.csr_reset
    add_connection rx_clk_module.clk/rx_eth_frame_decoder.clock_reset
    add_connection rx_clk_module.clk_reset/rx_eth_frame_decoder.clock_reset_reset
    add_connection rx_clk_module.clk/rx_eth_packet_overflow_control.clock_reset
    add_connection rx_clk_module.clk_reset/rx_eth_packet_overflow_control.clock_reset_reset
    add_connection rx_clk_module.clk_reset/rx_eth_packet_overflow_control.csr_reset
    add_connection rx_clk_module.clk/rx_eth_crc.clock_reset
    add_connection rx_clk_module.clk_reset/rx_eth_crc.clock_reset_reset
    add_connection rx_clk_module.clk_reset/rx_eth_crc.csr_reset
    add_connection rx_clk_module.clk/rx_eth_crc_pad_rem.clock_reset
    add_connection rx_clk_module.clk_reset/rx_eth_crc_pad_rem.clock_reset_reset
    add_connection rx_clk_module.clk_reset/rx_eth_crc_pad_rem.csr_reset
    add_connection tx_clk_module.clk/eth_packet_underflow_control.clock_reset
    add_connection tx_clk_module.clk_reset/eth_packet_underflow_control.clock_reset_reset
    add_connection tx_clk_module.clk_reset/eth_packet_underflow_control.csr_reset
    add_connection tx_clk_module.clk/tx_eth_pad_inserter.clock_reset
    add_connection tx_clk_module.clk_reset/tx_eth_pad_inserter.clock_reset_reset
    add_connection tx_clk_module.clk_reset/tx_eth_pad_inserter.csr_reset
    add_connection tx_clk_module.clk/tx_eth_pkt_backpressure_control.clock_reset
    add_connection tx_clk_module.clk_reset/tx_eth_pkt_backpressure_control.clock_reset_reset
    add_connection tx_clk_module.clk_reset/tx_eth_pkt_backpressure_control.csr_reset
    add_connection tx_clk_module.clk/tx_pause_ctrl_gen.clock_reset
    add_connection tx_clk_module.clk_reset/tx_pause_ctrl_gen.clock_reset_reset
    add_connection tx_clk_module.clk_reset/tx_pause_ctrl_gen.csr_reset
    add_connection tx_clk_module.clk/pause_ctrl_error_adapter.clk
    add_connection tx_clk_module.clk_reset/pause_ctrl_error_adapter.reset
    add_connection tx_clk_module.clk/tx_mux.clk
    add_connection tx_clk_module.clk_reset/tx_mux.reset
    add_connection tx_clk_module.clk/tx_channel_adapter.clock_reset
    add_connection tx_clk_module.clk_reset/tx_channel_adapter.clock_reset_reset
    add_connection tx_clk_module.clk/tx_eth_address_inserter.clock_reset
    add_connection tx_clk_module.clk_reset/tx_eth_address_inserter.clock_reset_reset
    add_connection tx_clk_module.clk_reset/tx_eth_address_inserter.csr_reset
    add_connection tx_clk_module.clk/tx_eth_crc.clock_reset
    add_connection tx_clk_module.clk_reset/tx_eth_crc.clock_reset_reset
    add_connection tx_clk_module.clk_reset/tx_eth_crc.csr_reset
    add_connection tx_clk_module.clk/st_pipeline_stage_0.cr0
    add_connection tx_clk_module.clk_reset/st_pipeline_stage_0.cr0_reset
    add_connection rx_clk_module.clk/error_adapter_rx.clk
    add_connection rx_clk_module.clk_reset/error_adapter_rx.reset
    
    # RX <-> TX
    add_connection rx_clk_module.clk/dc_fifo_2.in_clk
    add_connection rx_clk_module.clk_reset/dc_fifo_2.in_clk_reset
    add_connection tx_clk_module.clk/dc_fifo_2.out_clk
    add_connection tx_clk_module.clk_reset/dc_fifo_2.out_clk_reset
    add_connection rx_clk_module.clk/timing_adapter_9.clk
    add_connection rx_clk_module.clk_reset/timing_adapter_9.reset
    add_connection tx_clk_module.clk/timing_adapter_10.clk
    add_connection tx_clk_module.clk_reset/timing_adapter_10.reset
    
    if {$stat_ena == 1} {
    add_connection tx_clk_module.clk/tx_st_splitter.clk
    add_connection tx_clk_module.clk_reset/tx_st_splitter.reset
    add_connection tx_clk_module.clk/tx_eth_frame_decoder.clock_reset
    add_connection tx_clk_module.clk_reset/tx_eth_frame_decoder.clock_reset_reset
    add_connection tx_clk_module.clk/error_adapter_tx.clk
    add_connection tx_clk_module.clk_reset/error_adapter_tx.reset
    add_connection tx_clk_module.clk/tx_eth_statistics_collector.clock
    add_connection tx_clk_module.clk_reset/tx_eth_statistics_collector.csr_reset
    
    add_connection rx_clk_module.clk/rxstatus_st_splitter.clk
    add_connection rx_clk_module.clk_reset/rxstatus_st_splitter.reset
    add_connection rx_clk_module.clk/rx_eth_statistics_collector.clock   
    add_connection rx_clk_module.clk_reset/rx_eth_statistics_collector.csr_reset
    add_connection rx_clk_module.clk/timing_adapter_6.clk
    add_connection rx_clk_module.clk_reset/timing_adapter_6.reset
    add_connection rx_clk_module.clk/timing_adapter_5.clk
    add_connection rx_clk_module.clk_reset/timing_adapter_5.reset
    add_connection rx_clk_module.clk/timing_adapter_4.clk
    add_connection rx_clk_module.clk_reset/timing_adapter_4.reset
    add_connection tx_clk_module.clk/timing_adapter_3.clk
    add_connection tx_clk_module.clk_reset/timing_adapter_3.reset
    add_connection tx_clk_module.clk/tx_eth_databus_bit_inserter.clk
    add_connection tx_clk_module.clk_reset/tx_eth_databus_bit_inserter.reset
    add_connection rx_clk_module.clk/rx_eth_databus_bit_inserter.clk
    add_connection rx_clk_module.clk_reset/rx_eth_databus_bit_inserter.reset
    } else {

    }
    add_connection tx_gmii_clk_module.clk/lane_encoder.clock_reset_gmii
    add_connection tx_gmii_clk_module.clk_reset/lane_encoder.clock_reset_gmii_reset
    add_connection tx_clk_module.clk/lane_encoder.clock_reset_mac
    add_connection tx_clk_module.clk_reset/lane_encoder.clock_reset_mac_reset
    add_connection csr_clk_module.clk/merlin_master_translator.clk
    add_connection csr_clk_module.clk_reset/merlin_master_translator.reset
   
    #  RX
    # AV-ST
    add_connection rx_eth_lane_decoder.avalon_streaming_source/rx_eth_pkt_backpressure_control.avalon_st_sink_data
    add_connection rx_eth_pkt_backpressure_control.avalon_st_source_data/rx_eth_crc.avalon_streaming_sink
    add_connection rx_eth_crc.avalon_streaming_source/rx_eth_frame_decoder.avalon_st_data_sink
    add_connection rx_eth_frame_decoder.avalon_st_data_src/rx_eth_crc_pad_rem.avalon_streaming_sink_data
    add_connection rx_eth_frame_decoder.avalon_st_pktinfo_src/rx_eth_crc_pad_rem.avalon_streaming_sink_status
    if {$stat_ena == 1} {
    add_connection rx_eth_frame_decoder.avalon_st_rxstatus_src/error_adapter_rx.in
    add_connection error_adapter_rx.out/timing_adapter_4.in
    add_connection timing_adapter_4.out/rxstatus_st_splitter.in
    add_connection rxstatus_st_splitter.out0/timing_adapter_5.in
    add_connection rxstatus_st_splitter.out1/timing_adapter_6.in
    add_connection timing_adapter_5.out/rx_eth_databus_bit_inserter.avalon_st_sink_data
    add_connection rx_eth_databus_bit_inserter.avalon_st_source_data/rx_eth_statistics_collector.avalon_st_sink_data

    set_interface_property avalon_st_rxstatus export_of timing_adapter_6.out
    } else {
    add_connection rx_eth_frame_decoder.avalon_st_rxstatus_src/error_adapter_rx.in
    set_interface_property avalon_st_rxstatus export_of error_adapter_rx.out
    }   
    add_connection rx_eth_crc_pad_rem.avalon_streaming_source_data/rx_eth_packet_overflow_control.avalon_streaming_sink
    # AV-MM
    add_connection merlin_master_translator.avalon_universal_master_0/rx_eth_packet_overflow_control.csr
    add_connection merlin_master_translator.avalon_universal_master_0/rx_eth_crc_pad_rem.csr
    add_connection merlin_master_translator.avalon_universal_master_0/rx_eth_frame_decoder.avalom_mm_csr
    add_connection merlin_master_translator.avalon_universal_master_0/rx_eth_crc.csr
    add_connection merlin_master_translator.avalon_universal_master_0/rx_eth_pkt_backpressure_control.csr
    if {$stat_ena == 1} {
    add_connection merlin_master_translator.avalon_universal_master_0/rx_eth_statistics_collector.csr
    } else {

    }   

    #  RX ~ TX
    # AV-ST
    add_connection rx_eth_frame_decoder.avalon_st_pauselen_src/timing_adapter_9.in
    add_connection timing_adapter_9.out/dc_fifo_2.in
    add_connection dc_fifo_2.out/timing_adapter_10.in
    add_connection timing_adapter_10.out/tx_eth_pkt_backpressure_control.avalon_st_pause
    # AV-MM

    #  TX
    # AV-ST
    add_connection eth_packet_underflow_control.avalon_streaming_source/tx_eth_pad_inserter.avalon_st_sink_data
    add_connection tx_eth_pad_inserter.avalon_st_source_data/tx_eth_pkt_backpressure_control.avalon_st_sink_data
    add_connection tx_pause_ctrl_gen.pause_packet/pause_ctrl_error_adapter.in
    add_connection pause_ctrl_error_adapter.out/tx_mux.in1
    add_connection tx_eth_pkt_backpressure_control.avalon_st_source_data/tx_mux.in0    
    add_connection tx_mux.out/tx_eth_address_inserter.avalon_streaming_sink   
    add_connection tx_eth_address_inserter.avalon_streaming_source/tx_eth_crc.avalon_streaming_sink
    add_connection tx_eth_crc.avalon_streaming_source/tx_channel_adapter.channel_adapter_sink
    add_connection tx_channel_adapter.channel_adapter_src/st_pipeline_stage_0.sink0
    if {$stat_ena == 1} {
    add_connection st_pipeline_stage_0.source0/tx_st_splitter.in
    add_connection tx_st_splitter.out1/lane_encoder.avalon_streaming_sink
    add_connection tx_st_splitter.out0/timing_adapter_3.in
    add_connection timing_adapter_3.out/tx_eth_frame_decoder.avalon_st_data_sink  
    add_connection tx_eth_frame_decoder.avalon_st_rxstatus_src/error_adapter_tx.in
    add_connection error_adapter_tx.out/tx_eth_databus_bit_inserter.avalon_st_sink_data
    add_connection tx_eth_databus_bit_inserter.avalon_st_source_data/tx_eth_statistics_collector.avalon_st_sink_data
    } else {
    add_connection st_pipeline_stage_0.source0/lane_encoder.avalon_streaming_sink
    }
    # AV-MM
    add_connection merlin_master_translator.avalon_universal_master_0/tx_eth_crc.csr
    add_connection merlin_master_translator.avalon_universal_master_0/tx_eth_pad_inserter.csr    
    add_connection merlin_master_translator.avalon_universal_master_0/tx_eth_address_inserter.csr
    add_connection merlin_master_translator.avalon_universal_master_0/tx_eth_pkt_backpressure_control.csr
    add_connection merlin_master_translator.avalon_universal_master_0/eth_packet_underflow_control.avalon_slave_0
    add_connection merlin_master_translator.avalon_universal_master_0/tx_pause_ctrl_gen.csr
    if {$stat_ena == 1} {
    add_connection merlin_master_translator.avalon_universal_master_0/tx_eth_statistics_collector.csr
    add_connection merlin_master_translator.avalon_universal_master_0/tx_eth_frame_decoder.avalom_mm_csr
    } else {

    }
   
   

    if {$stat_ena == 1} {
    ## Connection merlin_master_translator.avalon_universal_master_0/tx_eth_statistics_collector.avalom_mm_csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_statistics_collector.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_statistics_collector.csr baseAddress "0x0600"   

    ## Connection merlin_master_translator.avalon_universal_master_0/rx_eth_statistics_collector.avalom_mm_csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_statistics_collector.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_statistics_collector.csr baseAddress "0x0400"   
    
    ## Connection merlin_master_translator.avalon_universal_master_0/tx_eth_frame_decoder.avalom_mm_csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_frame_decoder.avalom_mm_csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_frame_decoder.avalom_mm_csr baseAddress "0x0300"
    } else {

    }     
    
    ## Connection merlin_master_translator.avalon_universal_master_0/eth_packet_underflow_control.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/eth_packet_underflow_control.avalon_slave_0 arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/eth_packet_underflow_control.avalon_slave_0 baseAddress "0x0380"

    ## Connection merlin_master_translator.avalon_universal_master_0/tx_eth_address_inserter.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_address_inserter.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_address_inserter.csr baseAddress "0x0280"
    
    
    ## Connection merlin_master_translator.avalon_universal_master_0/tx_pause_ctrl_gen.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_pause_ctrl_gen.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_pause_ctrl_gen.csr baseAddress "0x0260"         
    
    ## Connection merlin_master_translator.avalon_universal_master_0/tx_eth_crc.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_crc.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_crc.csr baseAddress "0x0220"
      
    
    ## Connection merlin_master_translator.avalon_universal_master_0/tx_eth_pad_inserter.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_pad_inserter.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_pad_inserter.csr baseAddress "0x0210"        
    
    
    ## Connection merlin_master_translator.avalon_universal_master_0/tx_eth_pkt_backpressure_control.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_pkt_backpressure_control.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/tx_eth_pkt_backpressure_control.csr baseAddress "0x0200"


    ## Connection merlin_master_translator.avalon_universal_master_0/rx_eth_packet_overflow_control.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_packet_overflow_control.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_packet_overflow_control.csr baseAddress "0x0180"             

    ## Connection merlin_master_translator.avalon_universal_master_0/rx_eth_frame_decoder.avalom_mm_csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_frame_decoder.avalom_mm_csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_frame_decoder.avalom_mm_csr baseAddress "0x0100"

    ## Connection merlin_master_translator.avalon_universal_master_0/rx_eth_crc.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_crc.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_crc.csr baseAddress "0x0020"

    ## Connection merlin_master_translator.avalon_universal_master_0/rx_eth_crc_pad_rem.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_crc_pad_rem.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_crc_pad_rem.csr baseAddress "0x0010"
       
    
    ## Connection merlin_master_translator.avalon_universal_master_0/rx_eth_pkt_backpressure_control.csr
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_pkt_backpressure_control.csr arbitrationPriority "1"
    set_connection_parameter_value merlin_master_translator.avalon_universal_master_0/rx_eth_pkt_backpressure_control.csr baseAddress "0x0000"

}


# proc validate {} {  

# }

