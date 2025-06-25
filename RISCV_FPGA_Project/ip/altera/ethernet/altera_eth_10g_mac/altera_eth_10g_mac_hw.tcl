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
# | module altera_eth_10g_mac
# |
set_module_property NAME altera_eth_10g_mac
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property DISPLAY_NAME "Ethernet 10G MAC"
set_module_property DESCRIPTION "Altera Ethernet 10G MAC"
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/10Gbps_MAC.pdf"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSE_CALLBACK compose
set_module_property ANALYZE_HDL false
set_module_property VALIDATION_CALLBACK validate
# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |
source ./altera_eth_10g_mac_conf.tcl

add_parameter DEVICE_FAMILY STRING "Stratix IV"
set_parameter_property DEVICE_FAMILY DISPLAY_NAME "Device family"
set_parameter_property DEVICE_FAMILY DESCRIPTION "Target device family for ethernet 10G MAC IP"
set_parameter_property DEVICE_FAMILY ALLOWED_RANGES {"Arria GX" "Arria II GX" "Arria II GZ" "Cyclone IV GX" "HardCopy IV" "Stratix II GX" "Stratix III" "Stratix IV"  "Stratix V" "Arria V" "Cyclone V" "Arria V GZ"}
set_parameter_property DEVICE_FAMILY VISIBLE false
set_parameter_property DEVICE_FAMILY IS_HDL_PARAMETER false
set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY

add_display_item "System Info" DEVICE_FAMILY parameter


# |
# +-----------------------------------


sopc::preview_add_transform "foo" "PREVIEW_AVALON_MM_TRANSFORM"

proc validate {} {
    ethernet_10g_mac_update_gui
}

proc compose {} {
    # Get parameter values
    set datapath_option [get_parameter_value DATAPATH_OPTION]
    set supp_addr_ena [get_parameter_value ENABLE_SUPP_ADDR]
    set pfc_ena [get_parameter_value ENABLE_PFC]
    set pfc_priority_num [get_parameter_value PFC_PRIORITY_NUM]
    set stat_ena [get_parameter_value INSTANTIATE_STATISTICS]
    set reg_stat [get_parameter_value REGISTER_BASED_STATISTICS]
    set crc_tx [get_parameter_value INSTANTIATE_TX_CRC]
    set preamble_mode [get_parameter_value PREAMBLE_PASSTHROUGH]
    set timestamp_ena [get_parameter_value ENABLE_TIMESTAMPING]
    set ptp_1step_ena [get_parameter_value ENABLE_PTP_1STEP]
    set tstamp_fp_width [get_parameter_value TSTAMP_FP_WIDTH]
    set mac_1g10g_ena [get_parameter_value ENABLE_1G10G_MAC]
    
    
    # Common for TX & RX
    if { [expr ($datapath_option & 0x3)] } {
        #  CSR Clock Source 
        add_instance csr_clk_module clock_source  
        set_instance_parameter csr_clk_module clockFrequencyKnown "true"
        set_instance_parameter csr_clk_module clockFrequency "156250000"
        
        add_interface csr_clk clock end
        set_interface_property csr_clk export_of csr_clk_module.clk_in
        
        add_interface csr_reset reset end
        set_interface_property csr_reset export_of csr_clk_module.clk_in_reset
        
        #  Merlin Master Translator
        add_instance merlin_master_translator altera_merlin_master_translator 
        set_instance_parameter merlin_master_translator AV_ADDRESS_W "13"
        set_instance_parameter merlin_master_translator AV_DATA_W "32"
        set_instance_parameter merlin_master_translator AV_BURSTCOUNT_W "1"
        set_instance_parameter merlin_master_translator AV_BYTEENABLE_W "4"
        set_instance_parameter merlin_master_translator UAV_ADDRESS_W "15"
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
        set_instance_parameter merlin_master_translator AV_REGISTEROUTGOINGSIGNALS "1"
        set_instance_parameter merlin_master_translator AV_REGISTERINCOMINGSIGNALS "1"
        set_instance_parameter merlin_master_translator AV_ALWAYSBURSTMAXBURST "0"
        
        add_connection csr_clk_module.clk/merlin_master_translator.clk
        add_connection csr_clk_module.clk_reset/merlin_master_translator.reset
        
        # XGMII Conversion
        add_instance interface_conversion altera_eth_interface_conversion
        set_instance_parameter interface_conversion DATAPATH_OPTION $datapath_option
        
        #  Export CSR
        add_interface csr avalon end
        set_interface_property csr export_of merlin_master_translator.avalon_anti_master_0
        
        if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
            
            
            add_interface speed_sel conduit end
            add_instance speed_sel_splitter altera_eth_splitter
            set_instance_parameter speed_sel_splitter DATA_WIDTH "2"
            

            
            if {$timestamp_ena == 1} {
                if {$ptp_1step_ena == 1} {
                    set_instance_parameter speed_sel_splitter OUTPUT_NUM "8"
                } else {
                    set_instance_parameter speed_sel_splitter OUTPUT_NUM "7"
                }
            } else {
                set_instance_parameter speed_sel_splitter OUTPUT_NUM "5"
            }


            
            set_interface_property speed_sel export_of speed_sel_splitter.din
            set_interface_property speed_sel PORT_NAME_MAP "speed_sel din"
            #set_interface_property speed_sel export_of clk_switcher.speed_sel
                     
            
        }        
    }
    
    # TX
    if { [expr ($datapath_option & 0x1)] } {
        #  TX Clock Source 
        add_instance tx_clk_module clock_source  
        set_instance_parameter tx_clk_module clockFrequencyKnown "true"
        set_instance_parameter tx_clk_module clockFrequency "156250000"
        
        add_interface tx_clk clock end
        set_interface_property tx_clk export_of tx_clk_module.clk_in
        
        add_interface tx_reset reset end
        set_interface_property tx_reset export_of tx_clk_module.clk_in_reset
        
        
        if {[_get_device_type]} {
        
        
        
        } else {
        
        #MM Bridge
        add_instance tx_bridge altera_avalon_mm_bridge
        set_instance_parameter tx_bridge DATA_WIDTH 32
        set_instance_parameter tx_bridge ADDRESS_WIDTH 14
        set_instance_parameter tx_bridge MAX_PENDING_RESPONSES 1
        set_instance_parameter tx_bridge PIPELINE_COMMAND 0
        set_instance_parameter tx_bridge PIPELINE_RESPONSE 0
        

        
        add_connection merlin_master_translator.avalon_universal_master_0 tx_bridge.s0
        set_connection_parameter merlin_master_translator.avalon_universal_master_0/tx_bridge.s0 baseAddress 0x4000
        
        #Clock Connections
        add_connection tx_clk_module.clk/tx_bridge.clk
        add_connection csr_clk_module.clk_reset/tx_bridge.reset
        
        }
        
        add_connection tx_clk_module.clk/interface_conversion.clock_reset_tx
        add_connection tx_clk_module.clk_reset/interface_conversion.clock_reset_tx_reset
        
        #GMII TX 
        set tx_1g_clock_src ""
        set tx_1g_reset_src ""
        if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
            
            
            #CLIENT_TX_CLK
            #add_instance client_tx_clk_module clock_source  
            #set_instance_parameter client_tx_clk_module clockFrequencyKnown "true"
            #set_instance_parameter client_tx_clk_module clockFrequency "156250000"
            
            #add_interface client_tx_clk clock end
            #set_interface_property client_tx_clk export_of client_tx_clk_module.clk_in
            #add_connection tx_clk_module.clk_reset/client_tx_clk_module.clk_in_reset
            
            #GMII_TX_CLK
            add_instance gmii_tx_clk_module clock_source  
            set_instance_parameter gmii_tx_clk_module clockFrequencyKnown "true"
            set_instance_parameter gmii_tx_clk_module clockFrequency "125000000"
           
            add_interface gmii_tx_clk clock end
            set_interface_property gmii_tx_clk export_of gmii_tx_clk_module.clk_in
            add_connection tx_clk_module.clk_reset/gmii_tx_clk_module.clk_in_reset
            
            #GMII_TX DATA
            #Change this to a conduit or data 
            add_interface gmii_tx_d conduit start
            add_interface gmii_tx_err conduit start
            add_interface gmii_tx_en conduit start
            
            set_interface_property gmii_tx_d export_of tx_eth_gmii_mii_encoder.gmii_source_data
            set_interface_property gmii_tx_err export_of tx_eth_gmii_mii_encoder.gmii_source_error
            set_interface_property gmii_tx_en export_of tx_eth_gmii_mii_encoder.gmii_source_control  

			set_interface_property gmii_tx_d PORT_NAME_MAP "gmii_tx_d gmii_source_data"
			set_interface_property gmii_tx_err PORT_NAME_MAP "gmii_tx_err gmii_source_error"
			set_interface_property gmii_tx_en PORT_NAME_MAP "gmii_tx_en gmii_source_control"
            
            set tx_1g_clock_src gmii_tx_clk_module.clk
            set tx_1g_reset_src gmii_tx_clk_module.clk_reset
            
            
            if {$mac_1g10g_ena == 2} {
            
            add_interface mii_tx_d conduit start
            add_interface mii_tx_err conduit start
            add_interface mii_tx_en conduit start
            
            
            # add_interface speed_mii_gmii_bar conduit end
            # add_interface set_1000 conduit end
            add_interface tx_clkena conduit end
            add_interface tx_clkena_half_rate conduit end

            
            
            set_interface_property mii_tx_d export_of tx_eth_gmii_mii_encoder.mii_source_data
            set_interface_property mii_tx_err export_of tx_eth_gmii_mii_encoder.mii_source_error
            set_interface_property mii_tx_en export_of tx_eth_gmii_mii_encoder.mii_source_control  
            
            # set_interface_property speed_mii_gmii_bar export_of tx_eth_gmii_mii_encoder.speed_mii_gmii_bar  
            # set_interface_property set_1000 export_of tx_eth_gmii_mii_encoder.set_1000  
            set_interface_property tx_clkena export_of tx_eth_gmii_mii_encoder.tx_clkena  
            set_interface_property tx_clkena_half_rate export_of tx_eth_gmii_mii_encoder.tx_clkena_half_rate
            # set_interface_property rx_clkena export_of tx_eth_gmii_mii_encoder.rx_clkena  
            
            

			set_interface_property mii_tx_d PORT_NAME_MAP "mii_tx_d mii_source_data"
			set_interface_property mii_tx_err PORT_NAME_MAP "mii_tx_err mii_source_error"
			set_interface_property mii_tx_en PORT_NAME_MAP "mii_tx_en mii_source_control"
			# set_interface_property speed_mii_gmii_bar PORT_NAME_MAP "speed_mii_gmii_bar speed_mii_gmii_bar"
			# set_interface_property set_1000 PORT_NAME_MAP "set_1000 set_1000"
			set_interface_property tx_clkena PORT_NAME_MAP "tx_clkena tx_clkena"
			set_interface_property tx_clkena_half_rate PORT_NAME_MAP "tx_clkena_half_rate tx_clkena_half_rate"
            
            
            
            }
        }
        
        
         
        # Compose MAC TX
        if {[_get_device_type]} {
        compose_eth_10g_mac_tx tx_clk_module.clk tx_clk_module.clk_reset csr_clk_module.clk_reset $tx_1g_clock_src $tx_1g_reset_src merlin_master_translator.avalon_universal_master_0 $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        
        } else {
        compose_eth_10g_mac_tx tx_clk_module.clk tx_clk_module.clk_reset csr_clk_module.clk_reset $tx_1g_clock_src $tx_1g_reset_src tx_bridge.m0 $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
        }
        
        
        
        # XGMII Conversion
        add_connection tx_eth_link_fault_generation.mii_src/interface_conversion.xgmii_tx_bridge_sink
        
        #  Export Avalon-ST TX
        if { $preamble_mode == 1 } {
            add_instance tx_preamble_passthrough altera_eth_preamble_custom
            add_connection tx_clk_module.clk/tx_preamble_passthrough.clock
            add_connection tx_clk_module.clk_reset/tx_preamble_passthrough.reset
            add_connection csr_clk_module.clk_reset/tx_preamble_passthrough.csr_reset
            add_connection tx_preamble_passthrough.avalon_streaming_source_user/tx_eth_packet_underflow_control.avalon_streaming_sink
            add_connection tx_preamble_passthrough.preamble_src/tx_eth_packet_formatter.preamble_sink
        }    
        
        #    Export of Timestamping Avalon ST for TX
        if {$timestamp_ena == 1} {
            add_interface avalon_st_tx avalon_streaming end    
            set_interface_property avalon_st_tx export_of tx_st_splitter_tx_data.in
            
            add_interface tx_egress_timestamp_request conduit end
            set_interface_property tx_egress_timestamp_request export_of tx_eth_timestamp_req_ctrl.egress_timestamp_request
            #set_interface_property tx_egress_timestamp_request PORT_NAME_MAP "tx_egress_timestamp_request_valid time_stamp_req_data_sink_valid \
            #                                                                  tx_egress_timestamp_request_fingerprint time_stamp_req_data_sink_data"
            
            if {$ptp_1step_ena == 1} {            
                add_interface tx_etstamp_ins_ctrl conduit end
                set_interface_property tx_etstamp_ins_ctrl export_of tx_eth_timestamp_req_ctrl.egress_timestamp_insert_control
                
                #set_interface_property tx_etstamp_ins_ctrl PORT_NAME_MAP "tx_etstamp_ins_ctrl_timestamp_insert etstamp_ins_timestamp_insert \
                #                                                          tx_etstamp_ins_ctrl_timestamp_format etstamp_ins_timestamp_format \
                #                                                          tx_etstamp_ins_ctrl_residence_time_update etstamp_ins_residence_time_update \
                #                                                          tx_etstamp_ins_ctrl_ingress_timestamp_96b etstamp_ins_ingress_timestamp_96b \
                #                                                          tx_etstamp_ins_ctrl_ingress_timestamp_64b etstamp_ins_ingress_timestamp_64b \
                #                                                          tx_etstamp_ins_ctrl_residence_time_calc_format etstamp_ins_residence_time_calc_format \
                #                                                          tx_etstamp_ins_ctrl_checksum_zero etstamp_ins_checksum_zero \
                #                                                          tx_etstamp_ins_ctrl_checksum_correct etstamp_ins_checksum_correct \
                #                                                          tx_etstamp_ins_ctrl_offset_timestamp etstamp_ins_offset_timestamp \
                #                                                          tx_etstamp_ins_ctrl_offset_correction_field etstamp_ins_offset_correction_field \
                #                                                          tx_etstamp_ins_ctrl_offset_checksum_field etstamp_ins_offset_checksum_field \
                #                                                          tx_etstamp_ins_ctrl_offset_checksum_correction etstamp_ins_offset_checksum_correction"
            }
            
            add_interface tx_egress_timestamp_96b conduit start
            set_interface_property tx_egress_timestamp_96b export_of tx_eth_timestamp_req_ctrl.timestamp_fingerprint_96b_data_src
            #set_interface_property tx_egress_timestamp_96b PORT_NAME_MAP "tx_egress_timestamp_96b_valid timestamp_fingerprint_96b_data_src_valid \
            #                                                              tx_egress_timestamp_96b_data timestamp_fingerprint_96b_data_src_data_ts \
            #                                                              tx_egress_timestamp_96b_fingerprint timestamp_fingerprint_96b_data_src_data_fp"
            
            add_interface tx_egress_timestamp_64b conduit start
            set_interface_property tx_egress_timestamp_64b export_of tx_eth_timestamp_req_ctrl.timestamp_fingerprint_64b_data_src
            #set_interface_property tx_egress_timestamp_64b PORT_NAME_MAP "tx_egress_timestamp_64b_valid timestamp_fingerprint_64b_data_src_valid \
            #                                                              tx_egress_timestamp_64b_data timestamp_fingerprint_64b_data_src_data_ts \
            #                                                              tx_egress_timestamp_64b_fingerprint timestamp_fingerprint_64b_data_src_data_fp"
            
            #  Export of time_of_day
            add_interface tx_time_of_day_96b_10g conduit end
            set_interface_property tx_time_of_day_96b_10g export_of tx_eth_xgmii_tsu.time_of_day_96b
            #set_interface_property tx_time_of_day_96b_10g PORT_NAME_MAP "tx_time_of_day_96b_10g_data time_of_day_96b_data"
            
            add_interface tx_time_of_day_64b_10g conduit end
            set_interface_property tx_time_of_day_64b_10g export_of tx_eth_xgmii_tsu.time_of_day_64b
            #set_interface_property tx_time_of_day_64b_10g PORT_NAME_MAP "tx_time_of_day_64b_10g_data time_of_day_64b_data"
            
            #  Export of path_delay
            add_interface tx_path_delay_10g conduit end
            set_interface_property tx_path_delay_10g export_of tx_eth_xgmii_tsu.path_delay
            #set_interface_property tx_path_delay_10g PORT_NAME_MAP "tx_path_delay_10g_data path_delay_data"
            
            if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
                #  Export of time_of_day
                add_interface tx_time_of_day_96b_1g conduit end
                set_interface_property tx_time_of_day_96b_1g export_of tx_eth_gmii_mii_encoder.time_of_day_96b
                #set_interface_property tx_time_of_day_96b_1g PORT_NAME_MAP "tx_time_of_day_96b_1g_data time_of_day_96b_data"
                
                add_interface tx_time_of_day_64b_1g conduit end
                set_interface_property tx_time_of_day_64b_1g export_of tx_eth_gmii_mii_encoder.time_of_day_64b
                #set_interface_property tx_time_of_day_64b_1g PORT_NAME_MAP "tx_time_of_day_64b_1g_data time_of_day_64b_data"
            
            #  Export of path_delay
                add_interface tx_path_delay_1g conduit end
                set_interface_property tx_path_delay_1g export_of tx_eth_gmii_mii_encoder.path_delay
                #set_interface_property tx_path_delay_1g PORT_NAME_MAP "tx_path_delay_1g_data path_delay_data"
            }
            
        } else {
            if { $preamble_mode == 1 } {
                add_interface avalon_st_tx avalon_streaming end    
                set_interface_property avalon_st_tx export_of tx_preamble_passthrough.avalon_streaming_sink_user
            } else {
                add_interface avalon_st_tx avalon_streaming end    
                set_interface_property avalon_st_tx export_of tx_eth_packet_underflow_control.avalon_streaming_sink
            }
        }
        
        #  Export Avalon-ST Pause Generation TX
        add_interface avalon_st_pause avalon_streaming end
        set_interface_property avalon_st_pause export_of tx_eth_pause_ctrl_gen.pause_control
        
        #  Export Avalon-ST PFC TX
        if { $pfc_ena == 1 } {
            #  Export Avalon-ST PFC Generation Control TX
            add_interface avalon_st_tx_pfc_gen avalon_streaming end
            set_interface_property avalon_st_tx_pfc_gen export_of tx_eth_pfc_gen.pfc_ctrl_sink
            
            #  Export of PFC Status TX
            add_interface avalon_st_tx_pfc_status avalon_streaming start
            set_interface_property avalon_st_tx_pfc_status export_of tx_eth_pfc_gen.pfc_status_src
        }
        
        #  Export of XGMII TX
        add_interface xgmii_tx avalon_streaming start
        set_interface_property xgmii_tx export_of interface_conversion.xgmii_tx_bridge_src
        
        #  Export of TX Status
        if { $stat_ena == 1 } {
            add_interface avalon_st_txstatus avalon_streaming start
            set_interface_property avalon_st_txstatus export_of tx_st_timing_adapter_splitter_status_output.out
        }
        
    }
    
    # RX
    if { [expr ($datapath_option & 0x2)] } {
        #  RX Clock Source 
        add_instance rx_clk_module clock_source  
        set_instance_parameter rx_clk_module clockFrequencyKnown "true"
        set_instance_parameter rx_clk_module clockFrequency "156250000"
        
        add_interface rx_clk clock end
        set_interface_property rx_clk export_of rx_clk_module.clk_in
        
        add_interface rx_reset reset end
        set_interface_property rx_reset export_of rx_clk_module.clk_in_reset
        
        
        if {[_get_device_type]} {
        
        
        
        } else {
        # MM Bridge
        add_instance rx_bridge altera_avalon_mm_bridge
        set_instance_parameter rx_bridge DATA_WIDTH 32
        set_instance_parameter rx_bridge ADDRESS_WIDTH 14
        set_instance_parameter rx_bridge MAX_PENDING_RESPONSES 1
        set_instance_parameter rx_bridge PIPELINE_COMMAND 0
        set_instance_parameter rx_bridge PIPELINE_RESPONSE 0
        
        add_connection merlin_master_translator.avalon_universal_master_0 rx_bridge.s0
        set_connection_parameter merlin_master_translator.avalon_universal_master_0/rx_bridge.s0 baseAddress 0x0
        
        #Clock Connections
        add_connection rx_clk_module.clk/rx_bridge.clk
        add_connection csr_clk_module.clk_reset/rx_bridge.reset
        
        }
        
        # MM Bridge
        # add_instance rx_bridge altera_avalon_mm_bridge
        # set_instance_parameter rx_bridge DATA_WIDTH 32
        # set_instance_parameter rx_bridge ADDRESS_WIDTH 14
        # set_instance_parameter rx_bridge MAX_PENDING_RESPONSES 1
        # set_instance_parameter rx_bridge PIPELINE_COMMAND 0
        # set_instance_parameter rx_bridge PIPELINE_RESPONSE 0
        
        # add_connection merlin_master_translator.avalon_universal_master_0 rx_bridge.s0
        # set_connection_parameter merlin_master_translator.avalon_universal_master_0/rx_bridge.s0 baseAddress 0x0
        
        # Clock Connections
        # add_connection rx_clk_module.clk/rx_bridge.clk
        # add_connection csr_clk_module.clk_reset/rx_bridge.reset
        add_connection rx_clk_module.clk/interface_conversion.clock_reset_rx
        add_connection rx_clk_module.clk_reset/interface_conversion.clock_reset_rx_reset
        
        # GMII RX Clock Source
        set rx_1g_clock_src ""
        set rx_1g_reset_src ""
        if { [expr ($mac_1g10g_ena == 1)] || [expr ($mac_1g10g_ena == 2)]} {
                        
            #Client RX Clock
            #add_instance client_rx_clk_module clock_source  
            #set_instance_parameter client_rx_clk_module clockFrequencyKnown "true"
            #set_instance_parameter client_rx_clk_module clockFrequency "156250000"
            
            #add_interface client_rx_clk conduit end
            #set_interface_property client_rx_clk export_of client_rx_clk_module.clk_in
            #add_connection rx_clk_module.clk_reset/client_rx_clk_module.clk_in_reset
            
            #GMII RX Clock
            add_instance gmii_rx_clk_module clock_source  
            set_instance_parameter gmii_rx_clk_module clockFrequencyKnown "true"
            set_instance_parameter gmii_rx_clk_module clockFrequency "125000000"
            
            add_interface gmii_rx_clk clock end
            set_interface_property gmii_rx_clk export_of gmii_rx_clk_module.clk_in
            add_connection rx_clk_module.clk_reset/gmii_rx_clk_module.clk_in_reset
            
            set rx_1g_clock_src gmii_rx_clk_module.clk
            set rx_1g_reset_src gmii_rx_clk_module.clk_reset
         }
         
        # Compose MAC RX
        
        if {[_get_device_type]} {
        compose_eth_10g_mac_rx rx_clk_module.clk rx_clk_module.clk_reset csr_clk_module.clk_reset $rx_1g_clock_src $rx_1g_reset_src merlin_master_translator.avalon_universal_master_0 $stat_ena $reg_stat $supp_addr_ena $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $mac_1g10g_ena
        
        
        } else {
        compose_eth_10g_mac_rx rx_clk_module.clk rx_clk_module.clk_reset csr_clk_module.clk_reset $rx_1g_clock_src $rx_1g_reset_src rx_bridge.m0 $stat_ena $reg_stat $supp_addr_ena $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $mac_1g10g_ena
        }
        
        
        # XGMII Conversion
        add_connection interface_conversion.xgmii_rx_bridge_src/rx_st_timing_adapter_interface_conversion.in
        
        #  Export of XGMII RX
        add_interface xgmii_rx avalon_streaming end
        set_interface_property xgmii_rx export_of interface_conversion.xgmii_rx_bridge_sink
        
        if {$timestamp_ena == 1} {
            #  Export Avalon-ST RX
            add_interface avalon_st_rx avalon_streaming start
            set_interface_property avalon_st_rx export_of rx_eth_pkt_timestamp_aligner.avalon_streaming_source    
        
            #  Export of RX Status
            add_interface avalon_st_rxstatus avalon_streaming start
            set_interface_property avalon_st_rxstatus export_of rx_st_status_splitter_3.out1
            
            #  Export of RX Timestamp
            add_interface rx_ingress_timestamp_96b conduit start
            set_interface_property rx_ingress_timestamp_96b export_of rx_eth_pkt_timestamp_aligner.rx_ingress_timestamp_96b_src
            #set_interface_property rx_ingress_timestamp_96b PORT_NAME_MAP "rx_ingress_timestamp_96b_valid rx_ingress_timestamp_96b_src_valid \
            #                                                               rx_ingress_timestamp_96b_data rx_ingress_timestamp_96b_src_data"
            
            add_interface rx_ingress_timestamp_64b conduit start
            set_interface_property rx_ingress_timestamp_64b export_of rx_eth_pkt_timestamp_aligner.rx_ingress_timestamp_64b_src
            #set_interface_property rx_ingress_timestamp_64b PORT_NAME_MAP "rx_ingress_timestamp_64b_valid rx_ingress_timestamp_64b_src_valid \
            #                                                               rx_ingress_timestamp_64b_data rx_ingress_timestamp_64b_src_data"
            
            #  Export of time_of_day
            add_interface rx_time_of_day_96b_10g conduit end
            set_interface_property rx_time_of_day_96b_10g export_of rx_eth_xgmii_tsu.time_of_day_96b
            #set_interface_property rx_time_of_day_96b_10g PORT_NAME_MAP "rx_time_of_day_96b_10g_data time_of_day_96b_data"
            
            add_interface rx_time_of_day_64b_10g conduit end
            set_interface_property rx_time_of_day_64b_10g export_of rx_eth_xgmii_tsu.time_of_day_64b
            #set_interface_property rx_time_of_day_64b_10g PORT_NAME_MAP "rx_time_of_day_64b_10g_data time_of_day_64b_data"

            #  Export of path_delay
            add_interface rx_path_delay_10g conduit end
            set_interface_property rx_path_delay_10g export_of rx_eth_xgmii_tsu.path_delay
            #set_interface_property rx_path_delay_10g PORT_NAME_MAP "rx_path_delay_10g_data path_delay_data"
            
            if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
                #  Export of time_of_day
                add_interface rx_time_of_day_96b_1g conduit end
                set_interface_property rx_time_of_day_96b_1g export_of rx_eth_gmii_mii_decoder.time_of_day_96b
                #set_interface_property rx_time_of_day_96b_1g PORT_NAME_MAP "rx_time_of_day_96b_1g_data time_of_day_96b_data"
                
                add_interface rx_time_of_day_64b_1g conduit end
                set_interface_property rx_time_of_day_64b_1g export_of rx_eth_gmii_mii_decoder.time_of_day_64b
                #set_interface_property rx_time_of_day_64b_1g PORT_NAME_MAP "rx_time_of_day_64b_1g_data time_of_day_64b_data"

            #  Export of path_delay
                add_interface rx_path_delay_1g conduit end
                set_interface_property rx_path_delay_1g export_of rx_eth_gmii_mii_decoder.path_delay
                #set_interface_property rx_path_delay_1g PORT_NAME_MAP "rx_path_delay_1g_data path_delay_data"
            }
        } else {
            #  Export Avalon-ST RX
            add_interface avalon_st_rx avalon_streaming start
            set_interface_property avalon_st_rx export_of rx_eth_packet_overflow_control.avalon_streaming_source            
        
            #  Export of RX Status
            add_interface avalon_st_rxstatus avalon_streaming start
            if { $preamble_mode == 1 } {
                set_interface_property avalon_st_rxstatus export_of rx_st_status_output_delay_final.out
            } else {
                set_interface_property avalon_st_rxstatus export_of rx_st_status_output_delay.out
            }    
        }
        
        
        #  Export Avalon-ST PFC RX
        if { $pfc_ena == 1 } {
            #  Export of PFC Pause Enable RX
            add_interface avalon_st_rx_pfc_pause avalon_streaming start
            set_interface_property avalon_st_rx_pfc_pause export_of rx_eth_pfc_pause_conversion.pfc_pause_ena_src
            
            #  Export of PFC Status RX
            add_interface avalon_st_rx_pfc_status avalon_streaming start
            set_interface_property avalon_st_rx_pfc_status export_of rx_eth_delay_pfc_status.out
        }
        
        #  Export of GMII RX
        #  Change this to a conduit or data 
        if { $mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
            add_interface gmii_rx_d conduit end
            add_interface gmii_rx_err conduit end
            add_interface gmii_rx_dv conduit end
            
            set_interface_property gmii_rx_d export_of rx_eth_gmii_mii_decoder.gmii_sink_data
            set_interface_property gmii_rx_err export_of rx_eth_gmii_mii_decoder.gmii_sink_error
            set_interface_property gmii_rx_dv export_of rx_eth_gmii_mii_decoder.gmii_sink_control 

			set_interface_property gmii_rx_d PORT_NAME_MAP "gmii_rx_d gmii_sink_data"
			set_interface_property gmii_rx_err PORT_NAME_MAP "gmii_rx_err gmii_sink_error"
			set_interface_property gmii_rx_dv PORT_NAME_MAP "gmii_rx_dv gmii_sink_control"
            
            if {$mac_1g10g_ena == 2} {
            
            add_interface mii_rx_d conduit end
            add_interface mii_rx_err conduit end
            add_interface mii_rx_dv conduit end
            
            # add_interface speed_mii_gmii_bar conduit end
            add_interface rx_clkena conduit end
            add_interface rx_clkena_half_rate conduit end
            
            
            
            set_interface_property mii_rx_d export_of rx_eth_gmii_mii_decoder.mii_sink_data
            set_interface_property mii_rx_err export_of rx_eth_gmii_mii_decoder.mii_sink_error
            set_interface_property mii_rx_dv export_of rx_eth_gmii_mii_decoder.mii_sink_control 
            # set_interface_property speed_mii_gmii_bar export_of rx_eth_gmii_mii_decoder.speed_mii_gmii_bar 
            set_interface_property rx_clkena export_of rx_eth_gmii_mii_decoder.rx_clkena 
            set_interface_property rx_clkena_half_rate export_of rx_eth_gmii_mii_decoder.rx_clkena_half_rate

			set_interface_property mii_rx_d PORT_NAME_MAP "mii_rx_d mii_sink_data"
			set_interface_property mii_rx_err PORT_NAME_MAP "mii_rx_err mii_sink_error"
			set_interface_property mii_rx_dv PORT_NAME_MAP "mii_rx_dv mii_sink_control"
			# set_interface_property speed_mii_gmii_bar PORT_NAME_MAP "speed_mii_gmii_bar speed_mii_gmii_bar"
			set_interface_property rx_clkena PORT_NAME_MAP "rx_clkena rx_clkena"
			set_interface_property rx_clkena_half_rate PORT_NAME_MAP "rx_clkena_half_rate rx_clkena_half_rate"
            
            
            }
        }
    }
    
            
    # TX Only
    if { $datapath_option == 1 } {
        #  Export of Pause Length
        add_interface avalon_st_tx_pause_length avalon_streaming end
        set_interface_property avalon_st_tx_pause_length export_of tx_eth_pause_beat_conversion.pause_quanta_sink
        
        #  Export of Link Fault Status
        add_interface link_fault_status_xgmii_tx avalon_streaming end
        set_interface_property link_fault_status_xgmii_tx export_of tx_eth_link_fault_generation.link_fault_sink
    }
    
    # RX Only
    if { $datapath_option == 2 } {
        #  Export of Pause Length
        add_interface avalon_st_rx_pause_length avalon_streaming start
        set_interface_property avalon_st_rx_pause_length export_of rx_eth_frame_status_merger.pauselen_src
        
        #  Export of Link Fault Status
        add_interface link_fault_status_xgmii_rx avalon_streaming start
        set_interface_property link_fault_status_xgmii_rx export_of rx_eth_link_fault_detection.link_fault_src
    }
    
    # TX & RX
    if { $datapath_option == 3 } {
        # Crossing between RX and TX
        # Link Fault Signaling
        #  Timing Adapter Link Fault Status RX
        add_instance txrx_timing_adapter_link_fault_status_rx timing_adapter
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx generationLanguage "VERILOG"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inBitsPerSymbol "2"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inChannelWidth "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inErrorDescriptor ""
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inErrorWidth "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inMaxChannel "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inReadyLatency "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inSymbolsPerBeat "1"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inUseEmpty "true"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inUseEmptyPort "YES"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inUsePackets "false"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inUseReady "false"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx inUseValid "false"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx moduleName ""
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx outReadyLatency "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx outUseReady "true"
        set_instance_parameter txrx_timing_adapter_link_fault_status_rx outUseValid "true"
        
        #  Avalon St Splitter Link Fault Status RX
        add_instance txrx_st_splitter_link_fault_status altera_avalon_st_splitter
        set_instance_parameter txrx_st_splitter_link_fault_status NUMBER_OF_OUTPUTS "2"
        set_instance_parameter txrx_st_splitter_link_fault_status QUALIFY_VALID_OUT "0"
        set_instance_parameter txrx_st_splitter_link_fault_status DATA_WIDTH "2"
        set_instance_parameter txrx_st_splitter_link_fault_status BITS_PER_SYMBOL "2"
        set_instance_parameter txrx_st_splitter_link_fault_status USE_PACKETS "0"
        set_instance_parameter txrx_st_splitter_link_fault_status USE_CHANNEL "0"
        set_instance_parameter txrx_st_splitter_link_fault_status CHANNEL_WIDTH "1"
        set_instance_parameter txrx_st_splitter_link_fault_status MAX_CHANNELS "1"
        set_instance_parameter txrx_st_splitter_link_fault_status USE_ERROR "0"
        set_instance_parameter txrx_st_splitter_link_fault_status ERROR_WIDTH "1"
        
        #  Timing Adapter Link Fault Status RX Export
        add_instance txrx_timing_adapter_link_fault_status_export timing_adapter
        set_instance_parameter txrx_timing_adapter_link_fault_status_export generationLanguage "VERILOG"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inBitsPerSymbol "2"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inChannelWidth "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inErrorDescriptor ""
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inErrorWidth "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inMaxChannel "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inReadyLatency "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inSymbolsPerBeat "1"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inUseEmpty "true"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inUseEmptyPort "YES"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inUsePackets "false"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inUseReady "true"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export inUseValid "true"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export moduleName ""
        set_instance_parameter txrx_timing_adapter_link_fault_status_export outReadyLatency "0"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export outUseReady "false"
        set_instance_parameter txrx_timing_adapter_link_fault_status_export outUseValid "false"
        
        # DC Fifo ( link_fault_src to link_fault_sink )
        add_instance rxtx_dc_fifo_link_fault_status altera_avalon_dc_fifo
        set_instance_parameter rxtx_dc_fifo_link_fault_status SYMBOLS_PER_BEAT "1"
        set_instance_parameter rxtx_dc_fifo_link_fault_status BITS_PER_SYMBOL "2"
        set_instance_parameter rxtx_dc_fifo_link_fault_status FIFO_DEPTH "16"
        set_instance_parameter rxtx_dc_fifo_link_fault_status CHANNEL_WIDTH "0"
        set_instance_parameter rxtx_dc_fifo_link_fault_status ERROR_WIDTH "0"
        set_instance_parameter rxtx_dc_fifo_link_fault_status USE_PACKETS "0"
        set_instance_parameter rxtx_dc_fifo_link_fault_status USE_IN_FILL_LEVEL "0"
        set_instance_parameter rxtx_dc_fifo_link_fault_status USE_OUT_FILL_LEVEL "0"
        set_instance_parameter rxtx_dc_fifo_link_fault_status WR_SYNC_DEPTH "2"
        set_instance_parameter rxtx_dc_fifo_link_fault_status RD_SYNC_DEPTH "2"
        set_instance_parameter rxtx_dc_fifo_link_fault_status ENABLE_EXPLICIT_MAXCHANNEL "false"
        set_instance_parameter rxtx_dc_fifo_link_fault_status EXPLICIT_MAXCHANNEL "0"
        
        #  Timing Adapter Link Fault TX
        add_instance rxtx_timing_adapter_link_fault_status_tx timing_adapter
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx generationLanguage "VERILOG"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inBitsPerSymbol "2"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inChannelWidth "0"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inErrorDescriptor ""
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inErrorWidth "0"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inMaxChannel "0"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inReadyLatency "0"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inSymbolsPerBeat "1"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inUseEmpty "true"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inUseEmptyPort "YES"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inUsePackets "false"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inUseReady "true"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx inUseValid "true"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx moduleName ""
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx outReadyLatency "0"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx outUseReady "false"
        set_instance_parameter rxtx_timing_adapter_link_fault_status_tx outUseValid "false"
        
        # Clock Connections
        add_connection rx_clk_module.clk/txrx_timing_adapter_link_fault_status_rx.clk
        add_connection rx_clk_module.clk_reset/txrx_timing_adapter_link_fault_status_rx.reset
        add_connection rx_clk_module.clk/txrx_st_splitter_link_fault_status.clk
        add_connection rx_clk_module.clk_reset/txrx_st_splitter_link_fault_status.reset
        add_connection rx_clk_module.clk/txrx_timing_adapter_link_fault_status_export.clk
        add_connection rx_clk_module.clk_reset/txrx_timing_adapter_link_fault_status_export.reset
        add_connection rx_clk_module.clk/rxtx_dc_fifo_link_fault_status.in_clk
        add_connection rx_clk_module.clk_reset/rxtx_dc_fifo_link_fault_status.in_clk_reset
        
        add_connection tx_clk_module.clk/rxtx_dc_fifo_link_fault_status.out_clk
        add_connection tx_clk_module.clk_reset/rxtx_dc_fifo_link_fault_status.out_clk_reset
        add_connection tx_clk_module.clk/rxtx_timing_adapter_link_fault_status_tx.clk
        add_connection tx_clk_module.clk_reset/rxtx_timing_adapter_link_fault_status_tx.reset
        
        # Connections
        add_connection rx_eth_link_fault_detection.link_fault_src/txrx_timing_adapter_link_fault_status_rx.in
        add_connection txrx_timing_adapter_link_fault_status_rx.out/txrx_st_splitter_link_fault_status.in
        add_connection txrx_st_splitter_link_fault_status.out0/txrx_timing_adapter_link_fault_status_export.in
        
        add_connection txrx_st_splitter_link_fault_status.out1/rxtx_dc_fifo_link_fault_status.in
        add_connection rxtx_dc_fifo_link_fault_status.out/rxtx_timing_adapter_link_fault_status_tx.in
        add_connection rxtx_timing_adapter_link_fault_status_tx.out/tx_eth_link_fault_generation.link_fault_sink
        
        #  Export of Link Fault Status
        add_interface link_fault_status_xgmii_rx avalon_streaming start
        set_interface_property link_fault_status_xgmii_rx export_of txrx_timing_adapter_link_fault_status_export.out
        
        
        
        # Pause Length
        #  Timing Adapter Pauselen RX
        add_instance rxtx_timing_adapter_pauselen_rx timing_adapter
        set_instance_parameter rxtx_timing_adapter_pauselen_rx generationLanguage "VERILOG"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inBitsPerSymbol "16"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inChannelWidth "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inErrorDescriptor ""
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inErrorWidth "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inMaxChannel "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inReadyLatency "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inSymbolsPerBeat "1"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inUseEmpty "true"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inUseEmptyPort "YES"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inUsePackets "false"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inUseReady "false"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx inUseValid "true"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx moduleName ""
        set_instance_parameter rxtx_timing_adapter_pauselen_rx outReadyLatency "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx outUseReady "true"
        set_instance_parameter rxtx_timing_adapter_pauselen_rx outUseValid "true"
        
        # DC Fifo ( frame decoder to pkt backpressure )
        add_instance rxtx_dc_fifo_pauselen altera_avalon_dc_fifo
        set_instance_parameter rxtx_dc_fifo_pauselen SYMBOLS_PER_BEAT "1"
        set_instance_parameter rxtx_dc_fifo_pauselen BITS_PER_SYMBOL "16"
        set_instance_parameter rxtx_dc_fifo_pauselen FIFO_DEPTH "16"
        set_instance_parameter rxtx_dc_fifo_pauselen CHANNEL_WIDTH "0"
        set_instance_parameter rxtx_dc_fifo_pauselen ERROR_WIDTH "0"
        set_instance_parameter rxtx_dc_fifo_pauselen USE_PACKETS "0"
        set_instance_parameter rxtx_dc_fifo_pauselen USE_IN_FILL_LEVEL "0"
        set_instance_parameter rxtx_dc_fifo_pauselen USE_OUT_FILL_LEVEL "0"
        set_instance_parameter rxtx_dc_fifo_pauselen WR_SYNC_DEPTH "2"
        set_instance_parameter rxtx_dc_fifo_pauselen RD_SYNC_DEPTH "2"
        set_instance_parameter rxtx_dc_fifo_pauselen ENABLE_EXPLICIT_MAXCHANNEL "false"
        set_instance_parameter rxtx_dc_fifo_pauselen EXPLICIT_MAXCHANNEL "0"
        
        #  Timing Adapter Pauselen TX
        add_instance rxtx_timing_adapter_pauselen_tx timing_adapter
        set_instance_parameter rxtx_timing_adapter_pauselen_tx generationLanguage "VERILOG"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inBitsPerSymbol "16"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inChannelWidth "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inErrorDescriptor ""
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inErrorWidth "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inMaxChannel "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inReadyLatency "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inSymbolsPerBeat "1"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inUseEmpty "true"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inUseEmptyPort "YES"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inUsePackets "false"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inUseReady "true"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx inUseValid "true"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx moduleName ""
        set_instance_parameter rxtx_timing_adapter_pauselen_tx outReadyLatency "0"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx outUseReady "false"
        set_instance_parameter rxtx_timing_adapter_pauselen_tx outUseValid "true"
        
        # Clock Connections
        add_connection rx_clk_module.clk/rxtx_dc_fifo_pauselen.in_clk
        add_connection rx_clk_module.clk_reset/rxtx_dc_fifo_pauselen.in_clk_reset
        add_connection tx_clk_module.clk/rxtx_dc_fifo_pauselen.out_clk
        add_connection tx_clk_module.clk_reset/rxtx_dc_fifo_pauselen.out_clk_reset
        add_connection rx_clk_module.clk/rxtx_timing_adapter_pauselen_rx.clk
        add_connection rx_clk_module.clk_reset/rxtx_timing_adapter_pauselen_rx.reset
        add_connection tx_clk_module.clk/rxtx_timing_adapter_pauselen_tx.clk
        add_connection tx_clk_module.clk_reset/rxtx_timing_adapter_pauselen_tx.reset
        
        # Connections
        add_connection rx_eth_frame_status_merger.pauselen_src/rxtx_timing_adapter_pauselen_rx.in
        add_connection rxtx_timing_adapter_pauselen_rx.out/rxtx_dc_fifo_pauselen.in
        add_connection rxtx_dc_fifo_pauselen.out/rxtx_timing_adapter_pauselen_tx.in
        add_connection rxtx_timing_adapter_pauselen_tx.out/tx_eth_pause_beat_conversion.pause_quanta_sink
    }
    
}

proc compose_eth_10g_mac_rx {rx_clock_src rx_reset_src csr_reset rx_1g_clock_src rx_1g_reset_src rx_csr_master stat_ena reg_stat supp_addr_ena preamble_mode pfc_ena pfc_priority_num timestamp_ena mac_1g10g_ena} {
    add_instance rx_register_map altera_eth_10g_rx_register_map
    set_instance_parameter rx_register_map ENABLE_1G10G_MAC $mac_1g10g_ena
    set_instance_parameter rx_register_map ENABLE_TIMESTAMPING $timestamp_ena
    
    add_connection ${rx_clock_src}/rx_register_map.csr_clk
    add_connection ${csr_reset}/rx_register_map.csr_reset
    add_connection ${rx_clock_src}/rx_register_map.rx_10g_clk
    add_connection ${rx_reset_src}/rx_register_map.rx_10g_reset
    
    compose_eth_xgmii_rx $rx_clock_src $rx_reset_src $csr_reset $rx_csr_master $preamble_mode $timestamp_ena
    
    compose_eth_mac_rx $rx_clock_src $rx_reset_src $csr_reset $rx_1g_clock_src $rx_1g_reset_src $rx_csr_master $stat_ena $reg_stat $supp_addr_ena $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $mac_1g10g_ena  
    
    if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
        compose_eth_gmii_rx $rx_clock_src $rx_reset_src $rx_1g_clock_src $rx_1g_reset_src $timestamp_ena $mac_1g10g_ena
        
        add_connection ${rx_1g_clock_src}/rx_register_map.rx_1g_clk
        add_connection ${rx_1g_reset_src}/rx_register_map.rx_1g_reset
    }
    
    # Data Mux between MAC and RS Layer
    if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
            
        add_connection rx_eth_lane_decoder.avalon_streaming_source/rx_st_mux_rs_layer_2_avst.in0
        add_connection rx_eth_gmii_mii_decoder.avalon_streaming_source/rx_st_mux_rs_layer_2_avst.in1
        add_connection rx_st_mux_rs_layer_2_avst.out/rx_eth_pkt_backpressure_control.avalon_st_sink_data
        #add_connection rx_st_mux_rs_layer_2_avst.sel/clk_switcher.sel_out2
        add_connection rx_st_mux_rs_layer_2_avst.sel/speed_sel_splitter.dout1
    } else {
        add_connection rx_eth_lane_decoder.avalon_streaming_source/rx_eth_pkt_backpressure_control.avalon_st_sink_data
    }
    
}

proc compose_eth_10g_mac_tx {tx_clock_src tx_reset_src csr_reset tx_1g_clock_src tx_1g_reset_src tx_csr_master stat_ena reg_stat crc_tx preamble_mode pfc_ena pfc_priority_num timestamp_ena ptp_1step_ena tstamp_fp_width mac_1g10g_ena} {
    add_instance tx_register_map altera_eth_10g_tx_register_map
    set_instance_parameter tx_register_map ENABLE_1G10G_MAC $mac_1g10g_ena
    set_instance_parameter tx_register_map ENABLE_TIMESTAMPING $timestamp_ena
    set_instance_parameter tx_register_map ENABLE_PTP_1STEP $ptp_1step_ena
    
    add_connection ${tx_clock_src}/tx_register_map.csr_clk
    add_connection ${csr_reset}/tx_register_map.csr_reset
    add_connection ${tx_clock_src}/tx_register_map.tx_10g_clk
    add_connection ${tx_reset_src}/tx_register_map.tx_10g_reset
    
    if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
        #Avalon ST Demultiplexer for GMII and XGMII RS Layer
        add_instance tx_st_mux_avst_2_rs_layer altera_eth_rs_demux
        add_connection ${tx_clock_src}/tx_st_mux_avst_2_rs_layer.clock_reset
        add_connection ${tx_reset_src}/tx_st_mux_avst_2_rs_layer.clock_reset_reset
    }
    
    compose_eth_mac_tx $tx_clock_src $tx_reset_src $csr_reset $tx_1g_clock_src $tx_1g_reset_src $tx_csr_master $stat_ena $reg_stat $crc_tx $preamble_mode $pfc_ena $pfc_priority_num $timestamp_ena $ptp_1step_ena $tstamp_fp_width $mac_1g10g_ena
        
    if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
        add_connection ${tx_1g_clock_src}/tx_register_map.tx_1g_clk
        add_connection ${tx_1g_reset_src}/tx_register_map.tx_1g_reset
        
        compose_eth_gmii_tx $tx_clock_src $tx_reset_src $tx_1g_clock_src $tx_1g_reset_src $timestamp_ena $ptp_1step_ena $mac_1g10g_ena
    }
       
    compose_eth_xgmii_tx $tx_clock_src $tx_reset_src $tx_csr_master $crc_tx $preamble_mode $timestamp_ena $ptp_1step_ena
}

proc compose_eth_mac_rx {rx_clock_src rx_reset_src csr_reset rx_1g_clock_src rx_1g_reset_src rx_csr_master stat_ena reg_stat supp_addr_ena preamble_mode pfc_ena pfc_priority_num timestamp_ena mac_1g10g_ena} {
    if {$timestamp_ena == 1} {
        # Splitter for RX Status After Final Delay
        add_instance rx_st_status_splitter_3 altera_avalon_st_splitter 
        set_instance_parameter rx_st_status_splitter_3 NUMBER_OF_OUTPUTS "2"
        set_instance_parameter rx_st_status_splitter_3 QUALIFY_VALID_OUT "1"
        set_instance_parameter rx_st_status_splitter_3 DATA_WIDTH "40"
        set_instance_parameter rx_st_status_splitter_3 BITS_PER_SYMBOL "40"
        set_instance_parameter rx_st_status_splitter_3 USE_PACKETS "0"
        set_instance_parameter rx_st_status_splitter_3 USE_READY "0"
        set_instance_parameter rx_st_status_splitter_3 USE_CHANNEL "0"
        set_instance_parameter rx_st_status_splitter_3 CHANNEL_WIDTH "1"
        set_instance_parameter rx_st_status_splitter_3 MAX_CHANNELS "1"
        set_instance_parameter rx_st_status_splitter_3 USE_ERROR "1"
        set_instance_parameter rx_st_status_splitter_3 ERROR_WIDTH "7"
        
        #  Timing Adapter for timestamp aligner input from Final Delay Splitter
        add_instance rx_st_timing_adapter_timestamp_aligner_in timing_adapter
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in generationLanguage "VERILOG"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inBitsPerSymbol "40"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inChannelWidth "0"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inErrorDescriptor ""
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inErrorWidth "7"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inMaxChannel "0"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inSymbolsPerBeat "1"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inUseEmpty "false"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inUseEmptyPort "false"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inUsePackets "false"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inUseReady "false"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in inUseValid "true"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in moduleName ""
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in outReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in outUseReady "false"
        set_instance_parameter rx_st_timing_adapter_timestamp_aligner_in outUseValid "true"
       
        #Time Stamp Aligner in RX
        add_instance rx_eth_pkt_timestamp_aligner altera_eth_timestamp_aligner
        
        #Valid Timestamp Detector in RX
        if {$timestamp_ena == 1} {
            add_instance rx_eth_valid_timestamp_detector altera_eth_valid_timestamp_detector    
            set_instance_parameter rx_eth_valid_timestamp_detector ENABLE_1G10G_MAC $mac_1g10g_ena
        }
        
        # Splitter for RX Overflow Control Sink port
        add_instance rx_overflowcontrol_sink_splitter altera_avalon_st_splitter 
        set_instance_parameter rx_overflowcontrol_sink_splitter NUMBER_OF_OUTPUTS "2"
        set_instance_parameter rx_overflowcontrol_sink_splitter QUALIFY_VALID_OUT "1"
        set_instance_parameter rx_overflowcontrol_sink_splitter DATA_WIDTH "64"
        set_instance_parameter rx_overflowcontrol_sink_splitter BITS_PER_SYMBOL "8"
        set_instance_parameter rx_overflowcontrol_sink_splitter USE_PACKETS "1"
        set_instance_parameter rx_overflowcontrol_sink_splitter USE_READY "0"
        set_instance_parameter rx_overflowcontrol_sink_splitter USE_CHANNEL "0"
        set_instance_parameter rx_overflowcontrol_sink_splitter CHANNEL_WIDTH "1"
        set_instance_parameter rx_overflowcontrol_sink_splitter MAX_CHANNELS "1"
        set_instance_parameter rx_overflowcontrol_sink_splitter USE_ERROR "1"
        set_instance_parameter rx_overflowcontrol_sink_splitter ERROR_WIDTH "5"        
    }
    

    #  Packet Back Pressure RX
    add_instance rx_eth_pkt_backpressure_control altera_eth_pkt_backpressure_control
    set_instance_parameter rx_eth_pkt_backpressure_control BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_pkt_backpressure_control SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_pkt_backpressure_control ERROR_WIDTH "1"
    set_instance_parameter rx_eth_pkt_backpressure_control USE_READY "0"
    set_instance_parameter rx_eth_pkt_backpressure_control USE_PAUSE "0"
    
    #  Timing Adapter Frame Status In RX
    add_instance rx_st_timing_adapter_frame_status_in timing_adapter
    set_instance_parameter rx_st_timing_adapter_frame_status_in generationLanguage "VERILOG"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inBitsPerSymbol "8"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inChannelWidth "0"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inErrorDescriptor ""
    set_instance_parameter rx_st_timing_adapter_frame_status_in inErrorWidth "1"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inMaxChannel "0"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inSymbolsPerBeat "8"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inUseEmpty "true"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inUseEmptyPort "YES"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inUsePackets "true"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inUseReady "false"
    set_instance_parameter rx_st_timing_adapter_frame_status_in inUseValid "true"
    set_instance_parameter rx_st_timing_adapter_frame_status_in moduleName ""
    set_instance_parameter rx_st_timing_adapter_frame_status_in outReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_frame_status_in outUseReady "true"
    set_instance_parameter rx_st_timing_adapter_frame_status_in outUseValid "true"
    
    # Connections
    add_connection rx_eth_pkt_backpressure_control.avalon_st_source_data/rx_st_timing_adapter_frame_status_in.in
    
    #  Avalon St Splitter RX
    add_instance rx_st_frame_status_splitter altera_avalon_st_splitter
    if {$timestamp_ena == 1} {
        set_instance_parameter rx_st_frame_status_splitter NUMBER_OF_OUTPUTS "3"
    } else {
        set_instance_parameter rx_st_frame_status_splitter NUMBER_OF_OUTPUTS "2"
    }
    set_instance_parameter rx_st_frame_status_splitter QUALIFY_VALID_OUT "1"
    set_instance_parameter rx_st_frame_status_splitter DATA_WIDTH "64"
    set_instance_parameter rx_st_frame_status_splitter BITS_PER_SYMBOL "8"
    set_instance_parameter rx_st_frame_status_splitter USE_PACKETS "1"
    set_instance_parameter rx_st_frame_status_splitter USE_CHANNEL "0"
    set_instance_parameter rx_st_frame_status_splitter CHANNEL_WIDTH "1"
    set_instance_parameter rx_st_frame_status_splitter MAX_CHANNELS "1"
    set_instance_parameter rx_st_frame_status_splitter USE_ERROR "1"
    set_instance_parameter rx_st_frame_status_splitter ERROR_WIDTH "1"
    
    #  Frame Decoder RX
    add_instance rx_eth_frame_decoder altera_eth_frame_decoder
    set_instance_parameter rx_eth_frame_decoder BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_frame_decoder SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_frame_decoder ERROR_WIDTH "1"
    set_instance_parameter rx_eth_frame_decoder ENABLE_SUPP_ADDR $supp_addr_ena
    set_instance_parameter rx_eth_frame_decoder ENABLE_DATA_SOURCE "1"
    set_instance_parameter rx_eth_frame_decoder ENABLE_PAUSELEN "1"
    set_instance_parameter rx_eth_frame_decoder ENABLE_PKTINFO "1"
    set_instance_parameter rx_eth_frame_decoder USE_READY "0"
    set_instance_parameter rx_eth_frame_decoder ENABLE_PFC $pfc_ena
    set_instance_parameter rx_eth_frame_decoder PFC_PRIORITY_NUM $pfc_priority_num
    set_instance_parameter rx_eth_frame_decoder ENABLE_PFC_PQ "1"
    set_instance_parameter rx_eth_frame_decoder ENABLE_PFC_STATUS "1"
    
    if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
      set_instance_parameter rx_eth_frame_decoder CONTINUOUS_VALID "0"
    }
    
    
    #  CRC Checker Rx
    add_instance rx_eth_crc_checker altera_eth_crc
    set_instance_parameter rx_eth_crc_checker BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_crc_checker SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_crc_checker ERROR_WIDTH "1"
    set_instance_parameter rx_eth_crc_checker MODE_CHECKER_0_INSERTER_1 "0"
    set_instance_parameter rx_eth_crc_checker USE_READY "false"
    set_instance_parameter rx_eth_crc_checker USE_CHANNEL "0"
    
    #  Timing Adapter Frame Status Out Frame Decoder RX
    add_instance rx_timing_adapter_frame_status_out_frame_decoder timing_adapter
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder generationLanguage "VERILOG"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inBitsPerSymbol "8"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inChannelWidth "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inErrorDescriptor ""
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inErrorWidth "1"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inMaxChannel "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inReadyLatency "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inSymbolsPerBeat "8"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inUseEmpty "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inUseEmptyPort "YES"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inUsePackets "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inUseReady "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder inUseValid "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder moduleName ""
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder outReadyLatency "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder outUseReady "false"
    set_instance_parameter rx_timing_adapter_frame_status_out_frame_decoder outUseValid "true"
    
    #  Timing Adapter Frame Status Out CRC Checker RX
    add_instance rx_timing_adapter_frame_status_out_crc_checker timing_adapter
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker generationLanguage "VERILOG"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inBitsPerSymbol "8"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inChannelWidth "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inErrorDescriptor ""
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inErrorWidth "1"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inMaxChannel "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inReadyLatency "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inSymbolsPerBeat "8"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inUseEmpty "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inUseEmptyPort "YES"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inUsePackets "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inUseReady "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker inUseValid "true"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker moduleName ""
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker outReadyLatency "0"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker outUseReady "false"
    set_instance_parameter rx_timing_adapter_frame_status_out_crc_checker outUseValid "true"
    
    # Frame Status Merger RX
    add_instance rx_eth_frame_status_merger altera_eth_frame_status_merger
    set_instance_parameter rx_eth_frame_status_merger ENABLE_PFC $pfc_ena
    set_instance_parameter rx_eth_frame_status_merger PFC_PRIORITY_NUM $pfc_priority_num
    
    # Connections
    add_connection rx_st_timing_adapter_frame_status_in.out/rx_st_frame_status_splitter.in
    
    add_connection rx_st_frame_status_splitter.out0/rx_timing_adapter_frame_status_out_frame_decoder.in
    add_connection rx_timing_adapter_frame_status_out_frame_decoder.out/rx_eth_frame_decoder.avalon_st_data_sink
    add_connection rx_eth_frame_decoder.avalon_st_data_src/rx_eth_frame_status_merger.frame_decoder_data_sink
    add_connection rx_eth_frame_decoder.avalon_st_pauselen_src/rx_eth_frame_status_merger.pauselen_sink
    
    add_connection rx_st_frame_status_splitter.out1/rx_timing_adapter_frame_status_out_crc_checker.in
    add_connection rx_timing_adapter_frame_status_out_crc_checker.out/rx_eth_crc_checker.avalon_streaming_sink
    
    if {$timestamp_ena == 1} {
        add_connection rx_st_frame_status_splitter.out2/rx_eth_valid_timestamp_detector.data_sink
    }    
    
    
    # CRC Pad Remover RX
    add_instance rx_eth_crc_pad_rem altera_eth_crc_pad_rem
    set_instance_parameter rx_eth_crc_pad_rem BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_crc_pad_rem SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_crc_pad_rem ERRORWIDTH "5"
    
    # Connections
    add_connection rx_eth_frame_status_merger.data_src/rx_eth_crc_pad_rem.avalon_streaming_sink_data
    add_connection rx_eth_frame_decoder.avalon_st_pktinfo_src/rx_eth_crc_pad_rem.avalon_streaming_sink_status
    
    if {$preamble_mode == 1} {
        # Preamble Inserter on RX
        add_instance rx_preamble_inserter altera_eth_preamble_inserter
        
        # Connections
        add_connection rx_eth_lane_decoder.preamble_src/rx_preamble_inserter.preamble_sink
        add_connection rx_eth_crc_pad_rem.avalon_streaming_source_data/rx_preamble_inserter.avalon_streaming_sink_data_line
    }
    
    #  Overflow Controller RX
    add_instance rx_eth_packet_overflow_control altera_eth_packet_overflow_control
    set_instance_parameter rx_eth_packet_overflow_control BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_packet_overflow_control SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_packet_overflow_control ERROR_WIDTH "5"
    
    # Connections
    if {$preamble_mode == 0} {
        if {$timestamp_ena == 1} {
            add_connection rx_eth_crc_pad_rem.avalon_streaming_source_data/rx_overflowcontrol_sink_splitter.in
            add_connection rx_overflowcontrol_sink_splitter.out0/rx_eth_packet_overflow_control.avalon_streaming_sink
        } else {
            add_connection rx_eth_crc_pad_rem.avalon_streaming_source_data/rx_eth_packet_overflow_control.avalon_streaming_sink
        }
    } else {
        if {$timestamp_ena == 1} {
            add_connection rx_preamble_inserter.avalon_streaming_source_data_line/rx_overflowcontrol_sink_splitter.in
            add_connection rx_overflowcontrol_sink_splitter.out0/rx_eth_packet_overflow_control.avalon_streaming_sink
        } else {
            add_connection rx_preamble_inserter.avalon_streaming_source_data_line/rx_eth_packet_overflow_control.avalon_streaming_sink
        }
    }
    # Avalon ST Delay to align avalon_st_rx with avalon_st_rxstatus
    add_instance rx_st_status_output_delay altera_avalon_st_delay
    set_instance_parameter rx_st_status_output_delay NUMBER_OF_DELAY_CLOCKS "2"
    set_instance_parameter rx_st_status_output_delay DATA_WIDTH "40"
    set_instance_parameter rx_st_status_output_delay BITS_PER_SYMBOL "40"
    set_instance_parameter rx_st_status_output_delay USE_PACKETS "0"
    set_instance_parameter rx_st_status_output_delay USE_CHANNEL "0"
    set_instance_parameter rx_st_status_output_delay CHANNEL_WIDTH "1"
    set_instance_parameter rx_st_status_output_delay MAX_CHANNELS "1"
    set_instance_parameter rx_st_status_output_delay USE_ERROR "1"
    set_instance_parameter rx_st_status_output_delay ERROR_WIDTH "7"
    
    if { $pfc_ena == 1} {
        # PFC Pause Quanta Conversion
        add_instance rx_eth_pfc_pause_conversion altera_eth_pfc_pause_conversion
        set_instance_parameter rx_eth_pfc_pause_conversion PFC_PRIORITY_NUM $pfc_priority_num
        
        add_connection rx_eth_frame_decoder.avalon_st_pfc_pause_quanta_src/rx_eth_frame_status_merger.pfc_pause_quanta_sink
        add_connection rx_eth_frame_status_merger.pfc_pause_quanta_src/rx_eth_pfc_pause_conversion.pfc_pause_quanta_sink
        
        # Avalon ST Delay to align output of RX Frame Decoder and CRC Checker
        add_instance rx_st_delay_pfc_crc altera_avalon_st_delay
        set_instance_parameter rx_st_delay_pfc_crc NUMBER_OF_DELAY_CLOCKS "2"
        set_instance_parameter rx_st_delay_pfc_crc DATA_WIDTH "64"
        set_instance_parameter rx_st_delay_pfc_crc BITS_PER_SYMBOL "8"
        set_instance_parameter rx_st_delay_pfc_crc USE_PACKETS "1"
        set_instance_parameter rx_st_delay_pfc_crc USE_CHANNEL "0"
        set_instance_parameter rx_st_delay_pfc_crc CHANNEL_WIDTH "1"
        set_instance_parameter rx_st_delay_pfc_crc MAX_CHANNELS "1"
        set_instance_parameter rx_st_delay_pfc_crc USE_ERROR "1"
        set_instance_parameter rx_st_delay_pfc_crc ERROR_WIDTH "2"
        
        add_connection rx_eth_crc_checker.avalon_streaming_source/rx_st_delay_pfc_crc.in
        add_connection rx_st_delay_pfc_crc.out/rx_eth_frame_status_merger.crc_checker_data_sink
        
        # Avalon ST Delay to align avalon_st_rx with avalon_st_rx_pfc_status
        add_instance rx_eth_delay_pfc_status altera_avalon_st_delay
        set_instance_parameter rx_eth_delay_pfc_status NUMBER_OF_DELAY_CLOCKS "2"
        set_instance_parameter rx_eth_delay_pfc_status DATA_WIDTH [ expr 2 * $pfc_priority_num ]
        set_instance_parameter rx_eth_delay_pfc_status BITS_PER_SYMBOL [ expr 2 * $pfc_priority_num ]
        set_instance_parameter rx_eth_delay_pfc_status USE_PACKETS "0"
        set_instance_parameter rx_eth_delay_pfc_status USE_CHANNEL "0"
        set_instance_parameter rx_eth_delay_pfc_status CHANNEL_WIDTH "1"
        set_instance_parameter rx_eth_delay_pfc_status MAX_CHANNELS "1"
        set_instance_parameter rx_eth_delay_pfc_status USE_ERROR "0"
        set_instance_parameter rx_eth_delay_pfc_status ERROR_WIDTH "1"
        
        if { $preamble_mode == 1} {
            set_instance_parameter rx_eth_delay_pfc_status NUMBER_OF_DELAY_CLOCKS "3"
        } else {
            set_instance_parameter rx_eth_delay_pfc_status NUMBER_OF_DELAY_CLOCKS "2"
        }
        
        add_connection rx_eth_frame_decoder.avalon_st_pfc_status_src/rx_eth_delay_pfc_status.in
    } else {
        add_connection rx_eth_crc_checker.avalon_streaming_source/rx_eth_frame_status_merger.crc_checker_data_sink
    }
    
    # RX Status Connections
    add_connection rx_eth_frame_decoder.avalon_st_rxstatus_src/rx_eth_frame_status_merger.rxstatus_sink
    
    if {$preamble_mode == 1} {
    
        # Splitter for RX Status After First Delay
        add_instance rx_st_status_splitter_2 altera_avalon_st_splitter 
        set_instance_parameter rx_st_status_splitter_2 NUMBER_OF_OUTPUTS "2"
        set_instance_parameter rx_st_status_splitter_2 QUALIFY_VALID_OUT "1"
        set_instance_parameter rx_st_status_splitter_2 DATA_WIDTH "40"
        set_instance_parameter rx_st_status_splitter_2 BITS_PER_SYMBOL "40"
        set_instance_parameter rx_st_status_splitter_2 USE_PACKETS "0"
        set_instance_parameter rx_st_status_splitter_2 USE_READY "0"
        set_instance_parameter rx_st_status_splitter_2 USE_CHANNEL "0"
        set_instance_parameter rx_st_status_splitter_2 CHANNEL_WIDTH "1"
        set_instance_parameter rx_st_status_splitter_2 MAX_CHANNELS "1"
        set_instance_parameter rx_st_status_splitter_2 USE_ERROR "1"
        set_instance_parameter rx_st_status_splitter_2 ERROR_WIDTH "7"
        
        # Connections
        add_connection rx_st_status_output_delay.out/rx_st_status_splitter_2.in
        
        # Avalon ST Delay to align avalon_st_rx with avalon_st_rxstatus after Preamble Inserterion
        add_instance rx_st_status_output_delay_final altera_avalon_st_delay
        set_instance_parameter rx_st_status_output_delay_final NUMBER_OF_DELAY_CLOCKS "1"
        set_instance_parameter rx_st_status_output_delay_final DATA_WIDTH "40"
        set_instance_parameter rx_st_status_output_delay_final BITS_PER_SYMBOL "40"
        set_instance_parameter rx_st_status_output_delay_final USE_PACKETS "0"
        set_instance_parameter rx_st_status_output_delay_final USE_CHANNEL "0"
        set_instance_parameter rx_st_status_output_delay_final CHANNEL_WIDTH "1"
        set_instance_parameter rx_st_status_output_delay_final MAX_CHANNELS "1"
        set_instance_parameter rx_st_status_output_delay_final USE_ERROR "1"
        set_instance_parameter rx_st_status_output_delay_final ERROR_WIDTH "7"
        
        #Connections
        add_connection rx_st_status_splitter_2.out0/rx_preamble_inserter.avalon_streaming_sink_packet_status
        add_connection rx_st_status_splitter_2.out1/rx_st_status_output_delay_final.in
    
    }
    
    #  Error Adapter for RX Status
    add_instance rx_st_error_adapter_stat error_adapter
    set_instance_parameter rx_st_error_adapter_stat generationLanguage "VERILOG"
    set_instance_parameter rx_st_error_adapter_stat inBitsPerSymbol "40"
    set_instance_parameter rx_st_error_adapter_stat inChannelWidth "0"
    set_instance_parameter rx_st_error_adapter_stat inErrorDescriptor "payload_length,oversize,undersize,crc,phy"
    set_instance_parameter rx_st_error_adapter_stat inErrorWidth "5"
    set_instance_parameter rx_st_error_adapter_stat inMaxChannel "0"
    set_instance_parameter rx_st_error_adapter_stat inReadyLatency "0"
    set_instance_parameter rx_st_error_adapter_stat inSymbolsPerBeat "1"
    set_instance_parameter rx_st_error_adapter_stat inUseEmpty "false"
    set_instance_parameter rx_st_error_adapter_stat inUseEmptyPort "AUTO"
    set_instance_parameter rx_st_error_adapter_stat inUsePackets "false"
    set_instance_parameter rx_st_error_adapter_stat inUseReady "false"
    set_instance_parameter rx_st_error_adapter_stat moduleName ""
    set_instance_parameter rx_st_error_adapter_stat outErrorDescriptor "phy,user,underflow,crc,payload_length,oversize,undersize"
    set_instance_parameter rx_st_error_adapter_stat outErrorWidth "7"
    
    add_connection rx_eth_frame_status_merger.rxstatus_src/rx_st_error_adapter_stat.in
    
    if {$stat_ena == 1} {
        
        #  Timing Adapter for Status Splitter Input
        add_instance rx_st_timing_adapter_splitter_status_in timing_adapter
        set_instance_parameter rx_st_timing_adapter_splitter_status_in generationLanguage "VERILOG"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inBitsPerSymbol "40"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inChannelWidth "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inErrorDescriptor ""
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inErrorWidth "7"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inMaxChannel "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inSymbolsPerBeat "1"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inUseEmpty "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inUseEmptyPort "YES"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inUsePackets "false"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inUseReady "false"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in inUseValid "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in moduleName ""
        set_instance_parameter rx_st_timing_adapter_splitter_status_in outReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in outUseReady "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_in outUseValid "true"
        
        # Splitter for RX Status
        add_instance rx_st_status_splitter altera_avalon_st_splitter 
        set_instance_parameter rx_st_status_splitter NUMBER_OF_OUTPUTS "2"
        set_instance_parameter rx_st_status_splitter QUALIFY_VALID_OUT "1"
        set_instance_parameter rx_st_status_splitter DATA_WIDTH "40"
        set_instance_parameter rx_st_status_splitter BITS_PER_SYMBOL "40"
        set_instance_parameter rx_st_status_splitter USE_PACKETS "0"
        set_instance_parameter rx_st_status_splitter USE_CHANNEL "0"
        set_instance_parameter rx_st_status_splitter CHANNEL_WIDTH "1"
        set_instance_parameter rx_st_status_splitter MAX_CHANNELS "1"
        set_instance_parameter rx_st_status_splitter USE_ERROR "1"
        set_instance_parameter rx_st_status_splitter ERROR_WIDTH "7"
        
        #  Timing Adapter for Statistics of Status Splitter
        add_instance rx_st_timing_adapter_splitter_status_statistics timing_adapter
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics generationLanguage "VERILOG"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inBitsPerSymbol "40"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inChannelWidth "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inErrorDescriptor ""
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inErrorWidth "7"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inMaxChannel "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inSymbolsPerBeat "1"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inUseEmpty "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inUseEmptyPort "YES"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inUsePackets "false"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inUseReady "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics inUseValid "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics moduleName ""
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics outReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics outUseReady "false"
        set_instance_parameter rx_st_timing_adapter_splitter_status_statistics outUseValid "true"

        #  Timing Adapter for Statistics of Status Splitter
        add_instance rx_st_timing_adapter_splitter_status_output timing_adapter
        set_instance_parameter rx_st_timing_adapter_splitter_status_output generationLanguage "VERILOG"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inBitsPerSymbol "40"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inChannelWidth "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inErrorDescriptor ""
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inErrorWidth "7"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inMaxChannel "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inSymbolsPerBeat "1"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inUseEmpty "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inUseEmptyPort "YES"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inUsePackets "false"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inUseReady "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output inUseValid "true"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output moduleName ""
        set_instance_parameter rx_st_timing_adapter_splitter_status_output outReadyLatency "0"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output outUseReady "false"
        set_instance_parameter rx_st_timing_adapter_splitter_status_output outUseValid "true"
        
        # Avalon ST Delay to pipeline input to RX statistics
        add_instance rx_st_status_statistics_delay altera_avalon_st_delay
        set_instance_parameter rx_st_status_statistics_delay NUMBER_OF_DELAY_CLOCKS "1"
        set_instance_parameter rx_st_status_statistics_delay DATA_WIDTH "40"
        set_instance_parameter rx_st_status_statistics_delay BITS_PER_SYMBOL "40"
        set_instance_parameter rx_st_status_statistics_delay USE_PACKETS "0"
        set_instance_parameter rx_st_status_statistics_delay USE_CHANNEL "0"
        set_instance_parameter rx_st_status_statistics_delay CHANNEL_WIDTH "1"
        set_instance_parameter rx_st_status_statistics_delay MAX_CHANNELS "1"
        set_instance_parameter rx_st_status_statistics_delay USE_ERROR "1"
        set_instance_parameter rx_st_status_statistics_delay ERROR_WIDTH "7"
        
        if {$reg_stat == 1} {
            #  Statistics Collector TX Register-Based
            add_instance rx_eth_statistics_collector altera_eth_statistics_collector
            set_instance_parameter rx_eth_statistics_collector ENABLE_PFC $pfc_ena
        } else {
            # Statistics Collector TX Memory-Based
            add_instance rx_eth_statistics_collector altera_eth_10gmem_statistics_collector
            set_instance_parameter rx_eth_statistics_collector ENABLE_PFC $pfc_ena
        }
        
        # Connections
        add_connection rx_st_error_adapter_stat.out/rx_st_timing_adapter_splitter_status_in.in
        add_connection rx_st_timing_adapter_splitter_status_in.out/rx_st_status_splitter.in
        add_connection rx_st_status_splitter.out0/rx_st_timing_adapter_splitter_status_statistics.in
        add_connection rx_st_timing_adapter_splitter_status_statistics.out/rx_st_status_statistics_delay.in
        add_connection rx_st_status_statistics_delay.out/rx_eth_statistics_collector.avalon_st_sink_data
        
        add_connection rx_st_status_splitter.out1/rx_st_timing_adapter_splitter_status_output.in
        add_connection rx_st_timing_adapter_splitter_status_output.out/rx_st_status_output_delay.in
    } else {
        add_connection rx_st_error_adapter_stat.out/rx_st_status_output_delay.in
    }
    
    if {$timestamp_ena == 1} {    
        # add connection for Timestamp Aligner and Valid Timestamp Detector
        add_connection rx_st_status_splitter_3.out0/rx_st_timing_adapter_timestamp_aligner_in.in
        add_connection rx_st_timing_adapter_timestamp_aligner_in.out/rx_eth_pkt_timestamp_aligner.avalon_streaming_sink_rx_status
        
		add_connection rx_eth_valid_timestamp_detector.timestamp_96b_out/rx_eth_pkt_timestamp_aligner.timestamp_96b_sink
		add_connection rx_eth_valid_timestamp_detector.timestamp_64b_out/rx_eth_pkt_timestamp_aligner.timestamp_64b_sink
		if { $preamble_mode == 1 } {
			add_connection rx_st_status_output_delay_final.out/rx_st_status_splitter_3.in
		} else {
			add_connection rx_st_status_output_delay.out/rx_st_status_splitter_3.in
		}
		
		#add connection for overflow control to splitter
		add_connection rx_eth_packet_overflow_control.avalon_streaming_source/rx_eth_pkt_timestamp_aligner.avalon_streaming_sink_overflow_control_srcport
		add_connection rx_overflowcontrol_sink_splitter.out1/rx_eth_pkt_timestamp_aligner.avalon_streaming_sink_overflow_control_sinkport

		# Clock Connections
		add_connection ${rx_clock_src}/rx_st_status_splitter_3.clk
		add_connection ${rx_reset_src}/rx_st_status_splitter_3.reset
		add_connection ${rx_clock_src}/rx_st_timing_adapter_timestamp_aligner_in.clk
		add_connection ${rx_reset_src}/rx_st_timing_adapter_timestamp_aligner_in.reset
		add_connection ${rx_clock_src}/rx_eth_pkt_timestamp_aligner.clock
		add_connection ${rx_reset_src}/rx_eth_pkt_timestamp_aligner.reset
		add_connection ${rx_clock_src}/rx_eth_valid_timestamp_detector.clk_10g
		add_connection ${rx_reset_src}/rx_eth_valid_timestamp_detector.reset_10g	
		add_connection ${rx_clock_src}/rx_overflowcontrol_sink_splitter.clk		
        add_connection ${rx_reset_src}/rx_overflowcontrol_sink_splitter.reset	
        
        if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
            add_connection ${rx_1g_clock_src}/rx_eth_valid_timestamp_detector.clk_1g
            add_connection ${rx_1g_reset_src}/rx_eth_valid_timestamp_detector.reset_1g
	}
	}
    
    # Clock Connections
    add_connection ${rx_clock_src}/rx_eth_pkt_backpressure_control.clock_reset
    add_connection ${rx_reset_src}/rx_eth_pkt_backpressure_control.clock_reset_reset
    add_connection ${csr_reset}/rx_eth_pkt_backpressure_control.csr_reset
    add_connection ${rx_clock_src}/rx_eth_crc_checker.clock_reset
    add_connection ${rx_reset_src}/rx_eth_crc_checker.clock_reset_reset
    add_connection ${csr_reset}/rx_eth_crc_checker.csr_reset
    add_connection ${rx_clock_src}/rx_eth_frame_decoder.clock_reset
    add_connection ${rx_reset_src}/rx_eth_frame_decoder.clock_reset_reset
    add_connection ${csr_reset}/rx_eth_frame_decoder.csr_reset
    add_connection ${rx_clock_src}/rx_st_frame_status_splitter.clk
    add_connection ${rx_reset_src}/rx_st_frame_status_splitter.reset
    add_connection ${rx_clock_src}/rx_st_timing_adapter_frame_status_in.clk
    add_connection ${rx_reset_src}/rx_st_timing_adapter_frame_status_in.reset
    add_connection ${rx_clock_src}/rx_timing_adapter_frame_status_out_frame_decoder.clk
    add_connection ${rx_reset_src}/rx_timing_adapter_frame_status_out_frame_decoder.reset
    add_connection ${rx_clock_src}/rx_timing_adapter_frame_status_out_crc_checker.clk
    add_connection ${rx_reset_src}/rx_timing_adapter_frame_status_out_crc_checker.reset
    add_connection ${rx_clock_src}/rx_eth_frame_status_merger.clock_reset
    add_connection ${rx_reset_src}/rx_eth_frame_status_merger.clock_reset_reset
    if {$preamble_mode == 1} {
		add_connection ${rx_clock_src}/rx_preamble_inserter.clock
		add_connection ${rx_reset_src}/rx_preamble_inserter.reset
      add_connection ${csr_reset}/rx_preamble_inserter.csr_reset
		add_connection ${rx_clock_src}/rx_st_status_splitter_2.clk
		add_connection ${rx_reset_src}/rx_st_status_splitter_2.reset
		add_connection ${rx_clock_src}/rx_st_status_output_delay_final.clk
		add_connection ${rx_reset_src}/rx_st_status_output_delay_final.clk_reset
	}
	
	add_connection ${rx_clock_src}/rx_eth_crc_pad_rem.clock_reset
    add_connection ${rx_reset_src}/rx_eth_crc_pad_rem.clock_reset_reset
    add_connection ${csr_reset}/rx_eth_crc_pad_rem.csr_reset
    add_connection ${rx_clock_src}/rx_eth_packet_overflow_control.clock_reset
    add_connection ${rx_reset_src}/rx_eth_packet_overflow_control.clock_reset_reset
    add_connection ${csr_reset}/rx_eth_packet_overflow_control.csr_reset
    add_connection ${rx_clock_src}/rx_st_error_adapter_stat.clk
    add_connection ${rx_reset_src}/rx_st_error_adapter_stat.reset
    if {$stat_ena == 1} {
        add_connection ${rx_clock_src}/rx_st_timing_adapter_splitter_status_in.clk
        add_connection ${rx_reset_src}/rx_st_timing_adapter_splitter_status_in.reset
        add_connection ${rx_clock_src}/rx_st_status_splitter.clk
        add_connection ${rx_reset_src}/rx_st_status_splitter.reset
        add_connection ${rx_clock_src}/rx_st_timing_adapter_splitter_status_output.clk
        add_connection ${rx_reset_src}/rx_st_timing_adapter_splitter_status_output.reset
        add_connection ${rx_clock_src}/rx_st_timing_adapter_splitter_status_statistics.clk
        add_connection ${rx_reset_src}/rx_st_timing_adapter_splitter_status_statistics.reset
        add_connection ${rx_clock_src}/rx_st_status_statistics_delay.clk
        add_connection ${rx_reset_src}/rx_st_status_statistics_delay.clk_reset
        add_connection ${rx_clock_src}/rx_eth_statistics_collector.clock
        add_connection ${csr_reset}/rx_eth_statistics_collector.csr_reset
    }
    add_connection ${rx_clock_src}/rx_st_status_output_delay.clk
    add_connection ${rx_reset_src}/rx_st_status_output_delay.clk_reset
    if {$pfc_ena == 1} {
        add_connection ${rx_clock_src}/rx_eth_pfc_pause_conversion.clock_reset
        add_connection ${rx_reset_src}/rx_eth_pfc_pause_conversion.clock_reset_reset
        
        add_connection ${rx_clock_src}/rx_st_delay_pfc_crc.clk
        add_connection ${rx_reset_src}/rx_st_delay_pfc_crc.clk_reset
        
        add_connection ${rx_clock_src}/rx_eth_delay_pfc_status.clk
        add_connection ${rx_reset_src}/rx_eth_delay_pfc_status.clk_reset
    }
    
    # CSR Connections
    add_connection ${rx_csr_master}/rx_eth_pkt_backpressure_control.csr
    set_connection_parameter_value ${rx_csr_master}/rx_eth_pkt_backpressure_control.csr arbitrationPriority "1"
    set_connection_parameter_value ${rx_csr_master}/rx_eth_pkt_backpressure_control.csr baseAddress "0x0000"
    
    add_connection ${rx_csr_master}/rx_eth_crc_pad_rem.csr
    set_connection_parameter_value ${rx_csr_master}/rx_eth_crc_pad_rem.csr arbitrationPriority "1"
    set_connection_parameter_value ${rx_csr_master}/rx_eth_crc_pad_rem.csr baseAddress "0x0100"
    
    add_connection ${rx_csr_master}/rx_eth_crc_checker.csr
    set_connection_parameter_value ${rx_csr_master}/rx_eth_crc_checker.csr arbitrationPriority "1"
    set_connection_parameter_value ${rx_csr_master}/rx_eth_crc_checker.csr baseAddress "0x0200"
    
    add_connection ${rx_csr_master}/rx_eth_frame_decoder.avalom_mm_csr
    set_connection_parameter_value ${rx_csr_master}/rx_eth_frame_decoder.avalom_mm_csr arbitrationPriority "1"
    set_connection_parameter_value ${rx_csr_master}/rx_eth_frame_decoder.avalom_mm_csr baseAddress "0x02000"
    
    add_connection ${rx_csr_master}/rx_eth_packet_overflow_control.csr
    set_connection_parameter_value ${rx_csr_master}/rx_eth_packet_overflow_control.csr arbitrationPriority "1"
    set_connection_parameter_value ${rx_csr_master}/rx_eth_packet_overflow_control.csr baseAddress "0x0300"
    
    if {$stat_ena == 1} {
        add_connection ${rx_csr_master}/rx_eth_statistics_collector.csr
        set_connection_parameter_value ${rx_csr_master}/rx_eth_statistics_collector.csr arbitrationPriority "1"
        set_connection_parameter_value ${rx_csr_master}/rx_eth_statistics_collector.csr baseAddress "0x3000"
    }
	
	add_connection ${rx_csr_master}/rx_eth_lane_decoder.csr
	set_connection_parameter_value ${rx_csr_master}/rx_eth_lane_decoder.csr arbitrationPriority "1"
	set_connection_parameter_value ${rx_csr_master}/rx_eth_lane_decoder.csr baseAddress "0x0500"
	
	if {$preamble_mode == 1} {
		add_connection ${rx_csr_master}/rx_preamble_inserter.csr
        set_connection_parameter_value ${rx_csr_master}/rx_preamble_inserter.csr arbitrationPriority "1"
        set_connection_parameter_value ${rx_csr_master}/rx_preamble_inserter.csr baseAddress "0x400"
	}
	
}

proc compose_eth_mac_tx {tx_clock_src tx_reset_src csr_reset tx_1g_clock_src tx_1g_reset_src tx_csr_master stat_ena reg_stat crc_tx preamble_mode pfc_ena pfc_priority_num timestamp_ena ptp_1step_ena tstamp_fp_width mac_1g10g_ena} {

	if {$timestamp_ena == 1} {
		#Splitter for avalon st TX data
		add_instance tx_st_splitter_tx_data altera_avalon_st_splitter 
		set_instance_parameter tx_st_splitter_tx_data NUMBER_OF_OUTPUTS "2"
		set_instance_parameter tx_st_splitter_tx_data QUALIFY_VALID_OUT "1"
		set_instance_parameter tx_st_splitter_tx_data DATA_WIDTH "64"
		set_instance_parameter tx_st_splitter_tx_data BITS_PER_SYMBOL "8"
		set_instance_parameter tx_st_splitter_tx_data USE_PACKETS "1"
		set_instance_parameter tx_st_splitter_tx_data USE_CHANNEL "0"
		set_instance_parameter tx_st_splitter_tx_data CHANNEL_WIDTH "1"
		set_instance_parameter tx_st_splitter_tx_data MAX_CHANNELS "1"
		set_instance_parameter tx_st_splitter_tx_data USE_ERROR "1"
		set_instance_parameter tx_st_splitter_tx_data ERROR_WIDTH "1"
		
		#Timing adapter for TX data
		add_instance tx_st_timing_adapter_tx_data timing_adapter
		set_instance_parameter tx_st_timing_adapter_tx_data generationLanguage "VERILOG"
		set_instance_parameter tx_st_timing_adapter_tx_data inBitsPerSymbol "8"
		set_instance_parameter tx_st_timing_adapter_tx_data inChannelWidth "0"
		set_instance_parameter tx_st_timing_adapter_tx_data inErrorDescriptor ""
		set_instance_parameter tx_st_timing_adapter_tx_data inErrorWidth "1"
		set_instance_parameter tx_st_timing_adapter_tx_data inMaxChannel "0"
		set_instance_parameter tx_st_timing_adapter_tx_data inReadyLatency "0"
		set_instance_parameter tx_st_timing_adapter_tx_data inSymbolsPerBeat "8"
		set_instance_parameter tx_st_timing_adapter_tx_data inUseEmpty "true"
		set_instance_parameter tx_st_timing_adapter_tx_data inUseEmptyPort "YES"
		set_instance_parameter tx_st_timing_adapter_tx_data inUsePackets "true"
		set_instance_parameter tx_st_timing_adapter_tx_data inUseReady "true"
		set_instance_parameter tx_st_timing_adapter_tx_data inUseValid "true"
		set_instance_parameter tx_st_timing_adapter_tx_data moduleName ""
		set_instance_parameter tx_st_timing_adapter_tx_data outReadyLatency "0"
		set_instance_parameter tx_st_timing_adapter_tx_data outUseReady "false"
		set_instance_parameter tx_st_timing_adapter_tx_data outUseValid "true"	
		
        #Time stamp request controller
        add_instance tx_eth_timestamp_req_ctrl altera_eth_timestamp_req_ctrl
        set_instance_parameter tx_eth_timestamp_req_ctrl BITSPERSYMBOL "8"
        set_instance_parameter tx_eth_timestamp_req_ctrl SYMBOLSPERBEAT "8"	
        set_instance_parameter tx_eth_timestamp_req_ctrl ERROR_WIDTH "1"
        set_instance_parameter tx_eth_timestamp_req_ctrl EMPTY_WIDTH "3"
        set_instance_parameter tx_eth_timestamp_req_ctrl FINGERPRINT_WIDTH $tstamp_fp_width
        set_instance_parameter tx_eth_timestamp_req_ctrl USE_TIMESTAMP_INSERTER $ptp_1step_ena
        set_instance_parameter tx_eth_timestamp_req_ctrl ENABLE_1G10G_MAC $mac_1g10g_ena
    
		#Timing adapter for mux
		add_instance tx_st_timing_adapter_mux timing_adapter
		set_instance_parameter tx_st_timing_adapter_mux generationLanguage "VERILOG"
		set_instance_parameter tx_st_timing_adapter_mux inBitsPerSymbol "8"
		set_instance_parameter tx_st_timing_adapter_mux inChannelWidth "1"
		set_instance_parameter tx_st_timing_adapter_mux inErrorDescriptor ""
		set_instance_parameter tx_st_timing_adapter_mux inErrorWidth "2"
		set_instance_parameter tx_st_timing_adapter_mux inMaxChannel "1"
		set_instance_parameter tx_st_timing_adapter_mux inReadyLatency "0"
		set_instance_parameter tx_st_timing_adapter_mux inSymbolsPerBeat "8"
		set_instance_parameter tx_st_timing_adapter_mux inUseEmpty "true"
		set_instance_parameter tx_st_timing_adapter_mux inUseEmptyPort "YES"
		set_instance_parameter tx_st_timing_adapter_mux inUsePackets "true"
		set_instance_parameter tx_st_timing_adapter_mux inUseReady "true"
		set_instance_parameter tx_st_timing_adapter_mux inUseValid "true"
		set_instance_parameter tx_st_timing_adapter_mux moduleName ""
		set_instance_parameter tx_st_timing_adapter_mux outReadyLatency "0"
		set_instance_parameter tx_st_timing_adapter_mux outUseReady "false"
		set_instance_parameter tx_st_timing_adapter_mux outUseValid "true"
		
		#Splitter for avalon st mux data
		add_instance tx_st_splitter_mux altera_avalon_st_splitter 
		set_instance_parameter tx_st_splitter_mux NUMBER_OF_OUTPUTS "2"
		set_instance_parameter tx_st_splitter_mux QUALIFY_VALID_OUT "1"
		set_instance_parameter tx_st_splitter_mux DATA_WIDTH "64"
		set_instance_parameter tx_st_splitter_mux BITS_PER_SYMBOL "8"
		set_instance_parameter tx_st_splitter_mux USE_PACKETS "1"
		set_instance_parameter tx_st_splitter_mux USE_CHANNEL "1"
		set_instance_parameter tx_st_splitter_mux CHANNEL_WIDTH "1"
		set_instance_parameter tx_st_splitter_mux MAX_CHANNELS "1"
		set_instance_parameter tx_st_splitter_mux USE_ERROR "1"
		set_instance_parameter tx_st_splitter_mux ERROR_WIDTH "2"
	}
      
    #  Underflow Controller TX
    add_instance tx_eth_packet_underflow_control altera_eth_packet_underflow_control
    set_instance_parameter tx_eth_packet_underflow_control BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_packet_underflow_control SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_packet_underflow_control ERROR_WIDTH "1"

    #  Pad Inserter TX
    add_instance tx_eth_pad_inserter altera_eth_pad_inserter
    set_instance_parameter tx_eth_pad_inserter BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_pad_inserter SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_pad_inserter ERROR_WIDTH "2"
    
    # Connections
    add_connection tx_eth_packet_underflow_control.avalon_streaming_source/tx_eth_pad_inserter.avalon_st_sink_data
    
    #  Back Pressure Controller TX
    add_instance tx_eth_pkt_backpressure_control altera_eth_pkt_backpressure_control
    set_instance_parameter tx_eth_pkt_backpressure_control BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_pkt_backpressure_control SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_pkt_backpressure_control ERROR_WIDTH "2"
    set_instance_parameter tx_eth_pkt_backpressure_control USE_READY "1"
    set_instance_parameter tx_eth_pkt_backpressure_control USE_PAUSE "1"
    
    #  Pause Beat Conversion TX
    add_instance tx_eth_pause_beat_conversion altera_eth_pause_beat_conversion
    if {$mac_1g10g_ena ==1 || $mac_1g10g_ena == 2} {
        set_instance_parameter tx_eth_pause_beat_conversion GET_MAC_1G10G_ENA "1"
        add_connection speed_sel_splitter.dout2/tx_eth_pause_beat_conversion.mode_1g_10gbar
    }
    add_connection tx_eth_pause_beat_conversion.pause_beat_src/tx_eth_pkt_backpressure_control.avalon_st_pause
    
    # Connections
    if {[_get_device_type]} {
        #  Pipeline Stage TX ST
        add_instance tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control altera_avalon_st_pipeline_stage
        set_instance_parameter tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control SYMBOLS_PER_BEAT "8"
        set_instance_parameter tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control BITS_PER_SYMBOL "8"
        set_instance_parameter tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control USE_PACKETS "1"
        set_instance_parameter tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control USE_EMPTY "1"
        set_instance_parameter tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control CHANNEL_WIDTH "0"
        set_instance_parameter tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control ERROR_WIDTH "2"
        set_instance_parameter tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control PIPELINE_READY "1"
        
        # Connections
        add_connection tx_eth_pad_inserter.avalon_st_source_data/tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control.sink0
        add_connection tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control.source0/tx_eth_pkt_backpressure_control.avalon_st_sink_data
    } else {
        add_connection tx_eth_pad_inserter.avalon_st_source_data/tx_eth_pkt_backpressure_control.avalon_st_sink_data
    }
    
    # Pause Controller TX
    add_instance tx_eth_pause_ctrl_gen altera_eth_pause_ctrl_gen
    set_instance_parameter tx_eth_pause_ctrl_gen BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_pause_ctrl_gen SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_pause_ctrl_gen ERROR_WIDTH "1"
    
    #  Error Adapter for Pause Controller TX
    add_instance tx_st_pause_ctrl_error_adapter error_adapter
    set_instance_parameter tx_st_pause_ctrl_error_adapter generationLanguage "VERILOG"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inBitsPerSymbol "8"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inChannelWidth "0"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inErrorDescriptor ""
    set_instance_parameter tx_st_pause_ctrl_error_adapter inErrorWidth "1"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inMaxChannel "0"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inReadyLatency "0"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inSymbolsPerBeat "8"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inUseEmpty "true"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inUseEmptyPort "AUTO"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inUsePackets "true"
    set_instance_parameter tx_st_pause_ctrl_error_adapter inUseReady "true"
    set_instance_parameter tx_st_pause_ctrl_error_adapter moduleName ""
    set_instance_parameter tx_st_pause_ctrl_error_adapter outErrorDescriptor ""
    set_instance_parameter tx_st_pause_ctrl_error_adapter outErrorWidth "2"
    
    # Avalon ST Multiplexer for TX Flow Control and User Frames
    add_instance tx_st_mux_flow_control_user_frame multiplexer
    set_instance_parameter tx_st_mux_flow_control_user_frame bitsPerSymbol "8"
    set_instance_parameter tx_st_mux_flow_control_user_frame errorWidth "2"
    set_instance_parameter tx_st_mux_flow_control_user_frame generationLanguage "VERILOG"
    set_instance_parameter tx_st_mux_flow_control_user_frame moduleName ""
    set_instance_parameter tx_st_mux_flow_control_user_frame numInputInterfaces "2"
    set_instance_parameter tx_st_mux_flow_control_user_frame outChannelWidth "1"
    set_instance_parameter tx_st_mux_flow_control_user_frame packetScheduling "true"
    set_instance_parameter tx_st_mux_flow_control_user_frame schedulingSize "2"
    set_instance_parameter tx_st_mux_flow_control_user_frame symbolsPerBeat "8"
    set_instance_parameter tx_st_mux_flow_control_user_frame useHighBitsOfChannel "true"
    set_instance_parameter tx_st_mux_flow_control_user_frame usePackets "true"
    
    # Channel Adapter TX
    add_instance tx_st_channel_adapter_mux_crc altera_eth_channel_adapter
    set_instance_parameter tx_st_channel_adapter_mux_crc ERROR_WIDTH 3
    
    if { $pfc_ena == 1 } {
        # PFC Generator TX
        add_instance tx_eth_pfc_gen altera_eth_pfc_generator
        set_instance_parameter tx_eth_pfc_gen PFC_PRIORITY_NUM $pfc_priority_num
        
        # Avalon ST Multiplexer for TX Flow Control and TX PFC
        add_instance tx_st_mux_fc_pfc multiplexer
        set_instance_parameter tx_st_mux_fc_pfc bitsPerSymbol "8"
        set_instance_parameter tx_st_mux_fc_pfc errorWidth "1"
        set_instance_parameter tx_st_mux_fc_pfc generationLanguage "VERILOG"
        set_instance_parameter tx_st_mux_fc_pfc moduleName ""
        set_instance_parameter tx_st_mux_fc_pfc numInputInterfaces "2"
        set_instance_parameter tx_st_mux_fc_pfc outChannelWidth "1"
        set_instance_parameter tx_st_mux_fc_pfc packetScheduling "true"
        set_instance_parameter tx_st_mux_fc_pfc schedulingSize "2"
        set_instance_parameter tx_st_mux_fc_pfc symbolsPerBeat "8"
        set_instance_parameter tx_st_mux_fc_pfc useHighBitsOfChannel "true"
        set_instance_parameter tx_st_mux_fc_pfc usePackets "true"
        
        # Channel Adapter TX FC PFC
        add_instance tx_st_channel_adapter_mux_fc_pfc altera_eth_channel_adapter
        set_instance_parameter tx_st_channel_adapter_mux_fc_pfc ERROR_WIDTH 1
        
        # Connections
        add_connection tx_eth_pause_ctrl_gen.pause_packet/tx_st_mux_fc_pfc.in0
        add_connection tx_eth_pfc_gen.pfc_data_src/tx_st_mux_fc_pfc.in1
        
        add_connection tx_st_mux_fc_pfc.out/tx_st_channel_adapter_mux_fc_pfc.channel_adapter_sink
        add_connection tx_st_channel_adapter_mux_fc_pfc.channel_adapter_src/tx_st_pause_ctrl_error_adapter.in
    } else {
        add_connection tx_eth_pause_ctrl_gen.pause_packet/tx_st_pause_ctrl_error_adapter.in
    }
    
    # Connections
	add_connection tx_eth_pkt_backpressure_control.avalon_st_source_data/tx_st_mux_flow_control_user_frame.in0
    add_connection tx_st_pause_ctrl_error_adapter.out/tx_st_mux_flow_control_user_frame.in1
	
    if {$preamble_mode == 0 } {
		if {$timestamp_ena == 1} {
			add_connection tx_st_mux_flow_control_user_frame.out/tx_st_splitter_mux.in
			add_connection tx_st_splitter_mux.out0/tx_eth_address_inserter.avalon_streaming_sink
		} else {
            add_connection tx_st_mux_flow_control_user_frame.out/tx_eth_address_inserter.avalon_streaming_sink
		}

	} else {
        #  Avalon ST Splitter TX 2
        add_instance tx_st_splitter_2 altera_avalon_st_splitter 
        set_instance_parameter tx_st_splitter_2 NUMBER_OF_OUTPUTS "2"
        set_instance_parameter tx_st_splitter_2 QUALIFY_VALID_OUT "1"
        set_instance_parameter tx_st_splitter_2 DATA_WIDTH "64"
        set_instance_parameter tx_st_splitter_2 BITS_PER_SYMBOL "8"
        set_instance_parameter tx_st_splitter_2 USE_PACKETS "1"
        set_instance_parameter tx_st_splitter_2 USE_CHANNEL "1"
        set_instance_parameter tx_st_splitter_2 CHANNEL_WIDTH "1"
        set_instance_parameter tx_st_splitter_2 MAX_CHANNELS "1"
        set_instance_parameter tx_st_splitter_2 USE_ERROR "1"
        set_instance_parameter tx_st_splitter_2 ERROR_WIDTH "2"
        
        # Connections
		if {$timestamp_ena == 1} {
			add_connection tx_st_mux_flow_control_user_frame.out/tx_st_splitter_mux.in
            add_connection tx_st_splitter_mux.out0/tx_st_splitter_2.in
		} else {
			add_connection tx_st_mux_flow_control_user_frame.out/tx_st_splitter_2.in
		}
        add_connection tx_st_splitter_2.out1/tx_preamble_passthrough.avalon_streaming_sink_channel_info
        add_connection tx_st_splitter_2.out0/tx_eth_address_inserter.avalon_streaming_sink
	}
	
    
    #  Address Inserter TX
    add_instance tx_eth_address_inserter altera_eth_address_inserter
    set_instance_parameter tx_eth_address_inserter BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_address_inserter SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_address_inserter ERROR_WIDTH "2"
    
    if {$crc_tx == 1} {
        if {$timestamp_ena == 1 && $ptp_1step_ena == 1} {
            #  CRC Allocation TX
            add_instance tx_eth_crc_allocation altera_eth_crc_allocation
            set_instance_parameter tx_eth_crc_allocation BITSPERSYMBOL "8"
            set_instance_parameter tx_eth_crc_allocation SYMBOLSPERBEAT "8"
            set_instance_parameter tx_eth_crc_allocation ERROR_WIDTH "2"
            set_instance_parameter tx_eth_crc_allocation USE_READY "true"
            set_instance_parameter tx_eth_crc_allocation USE_CHANNEL "1"
            set_instance_parameter tx_eth_crc_allocation ENABLE_1G10G_MAC $mac_1g10g_ena
            
            # Connections
            add_connection tx_eth_address_inserter.avalon_streaming_source/tx_eth_crc_allocation.data_sink
            add_connection tx_eth_crc_allocation.data_src/tx_st_channel_adapter_mux_crc.channel_adapter_sink
            add_connection tx_st_channel_adapter_mux_crc.channel_adapter_src/tx_st_pipeline_stage_rs.sink0
        } else {
            #  CRC Inserter TX
            add_instance tx_eth_crc_inserter altera_eth_crc
            set_instance_parameter tx_eth_crc_inserter BITSPERSYMBOL "8"
            set_instance_parameter tx_eth_crc_inserter SYMBOLSPERBEAT "8"
            set_instance_parameter tx_eth_crc_inserter ERROR_WIDTH "2"
            set_instance_parameter tx_eth_crc_inserter MODE_CHECKER_0_INSERTER_1 "1"
            set_instance_parameter tx_eth_crc_inserter USE_READY "true"
            set_instance_parameter tx_eth_crc_inserter USE_CHANNEL "1"
            
            # Connections
            add_connection tx_eth_address_inserter.avalon_streaming_source/tx_eth_crc_inserter.avalon_streaming_sink
            add_connection tx_eth_crc_inserter.avalon_streaming_source/tx_st_channel_adapter_mux_crc.channel_adapter_sink
            add_connection tx_st_channel_adapter_mux_crc.channel_adapter_src/tx_st_pipeline_stage_rs.sink0
        }
    } else {
        # Error Adapter NO_TX_CRC
        add_instance tx_st_error_adapter_no_crc error_adapter
        set_instance_parameter tx_st_error_adapter_no_crc generationLanguage "VERILOG"
        set_instance_parameter tx_st_error_adapter_no_crc inBitsPerSymbol "8"
        set_instance_parameter tx_st_error_adapter_no_crc inChannelWidth "1"
        set_instance_parameter tx_st_error_adapter_no_crc inErrorDescriptor ""
        set_instance_parameter tx_st_error_adapter_no_crc inErrorWidth "2"
        set_instance_parameter tx_st_error_adapter_no_crc inMaxChannel "1"
        set_instance_parameter tx_st_error_adapter_no_crc inReadyLatency "0"
        set_instance_parameter tx_st_error_adapter_no_crc inSymbolsPerBeat "8"
        set_instance_parameter tx_st_error_adapter_no_crc inUseEmpty "true"
        set_instance_parameter tx_st_error_adapter_no_crc inUseEmptyPort "AUTO"
        set_instance_parameter tx_st_error_adapter_no_crc inUsePackets "true"
        set_instance_parameter tx_st_error_adapter_no_crc inUseReady "true"
        set_instance_parameter tx_st_error_adapter_no_crc moduleName ""
        set_instance_parameter tx_st_error_adapter_no_crc outErrorDescriptor ""
        set_instance_parameter tx_st_error_adapter_no_crc outErrorWidth "3"
        
        # Connections
        add_connection tx_eth_address_inserter.avalon_streaming_source/tx_st_error_adapter_no_crc.in
        add_connection tx_st_error_adapter_no_crc.out/tx_st_channel_adapter_mux_crc.channel_adapter_sink
        add_connection tx_st_channel_adapter_mux_crc.channel_adapter_src/tx_st_pipeline_stage_rs.sink0
    }
    
    #  Pipeline Stage TX RS
    add_instance tx_st_pipeline_stage_rs altera_avalon_st_pipeline_stage
    set_instance_parameter tx_st_pipeline_stage_rs SYMBOLS_PER_BEAT "8"
    set_instance_parameter tx_st_pipeline_stage_rs BITS_PER_SYMBOL "8"
    set_instance_parameter tx_st_pipeline_stage_rs USE_PACKETS "1"
    set_instance_parameter tx_st_pipeline_stage_rs USE_EMPTY "1"
    set_instance_parameter tx_st_pipeline_stage_rs CHANNEL_WIDTH "0"
    set_instance_parameter tx_st_pipeline_stage_rs ERROR_WIDTH "3"
    set_instance_parameter tx_st_pipeline_stage_rs PIPELINE_READY "1"
    
    # Statistics on TX
    if {$stat_ena == 1} {
		if {$preamble_mode == 1} {
            #  Avalon ST Splitter TX 1
            add_instance tx_st_splitter_1 altera_avalon_st_splitter 
            set_instance_parameter tx_st_splitter_1 NUMBER_OF_OUTPUTS "3"
            set_instance_parameter tx_st_splitter_1 QUALIFY_VALID_OUT "1"
            set_instance_parameter tx_st_splitter_1 DATA_WIDTH "64"
            set_instance_parameter tx_st_splitter_1 BITS_PER_SYMBOL "8"
            set_instance_parameter tx_st_splitter_1 USE_PACKETS "1"
            set_instance_parameter tx_st_splitter_1 USE_CHANNEL "0"
            set_instance_parameter tx_st_splitter_1 CHANNEL_WIDTH "1"
            set_instance_parameter tx_st_splitter_1 MAX_CHANNELS "1"
            set_instance_parameter tx_st_splitter_1 USE_ERROR "1"
            set_instance_parameter tx_st_splitter_1 ERROR_WIDTH "3"
		} else {
            #  Avalon ST Splitter TX 1
            add_instance tx_st_splitter_1 altera_avalon_st_splitter 
            set_instance_parameter tx_st_splitter_1 NUMBER_OF_OUTPUTS "2"
            set_instance_parameter tx_st_splitter_1 QUALIFY_VALID_OUT "1"
            set_instance_parameter tx_st_splitter_1 DATA_WIDTH "64"
            set_instance_parameter tx_st_splitter_1 BITS_PER_SYMBOL "8"
            set_instance_parameter tx_st_splitter_1 USE_PACKETS "1"
            set_instance_parameter tx_st_splitter_1 USE_CHANNEL "0"
            set_instance_parameter tx_st_splitter_1 CHANNEL_WIDTH "1"
            set_instance_parameter tx_st_splitter_1 MAX_CHANNELS "1"
            set_instance_parameter tx_st_splitter_1 USE_ERROR "1"
            set_instance_parameter tx_st_splitter_1 ERROR_WIDTH "3"
		}
        
        #  Timing Adapter for Frame Decoder
        add_instance tx_st_timing_adapter_frame_decoder timing_adapter
        set_instance_parameter tx_st_timing_adapter_frame_decoder generationLanguage "VERILOG"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inBitsPerSymbol "8"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inChannelWidth "0"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inErrorDescriptor ""
        set_instance_parameter tx_st_timing_adapter_frame_decoder inErrorWidth "3"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inMaxChannel "0"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inSymbolsPerBeat "8"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inUseEmpty "true"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inUseEmptyPort "YES"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inUsePackets "true"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inUseReady "true"
        set_instance_parameter tx_st_timing_adapter_frame_decoder inUseValid "true"
        set_instance_parameter tx_st_timing_adapter_frame_decoder moduleName ""
        set_instance_parameter tx_st_timing_adapter_frame_decoder outReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_frame_decoder outUseReady "false"
        set_instance_parameter tx_st_timing_adapter_frame_decoder outUseValid "true"
        
        #  Frame Decoder TX
        add_instance tx_eth_frame_decoder altera_eth_frame_decoder
        set_instance_parameter tx_eth_frame_decoder BITSPERSYMBOL "8"
        set_instance_parameter tx_eth_frame_decoder SYMBOLSPERBEAT "8"
        set_instance_parameter tx_eth_frame_decoder ERROR_WIDTH "3"
        set_instance_parameter tx_eth_frame_decoder ENABLE_SUPP_ADDR "0"
        set_instance_parameter tx_eth_frame_decoder ENABLE_DATA_SOURCE "0"
        set_instance_parameter tx_eth_frame_decoder ENABLE_PAUSELEN "0"
        set_instance_parameter tx_eth_frame_decoder ENABLE_PKTINFO "0"
        set_instance_parameter tx_eth_frame_decoder USE_READY "0"
        set_instance_parameter tx_eth_frame_decoder ENABLE_PFC $pfc_ena
        set_instance_parameter tx_eth_frame_decoder PFC_PRIORITY_NUM $pfc_priority_num
        set_instance_parameter tx_eth_frame_decoder ENABLE_PFC_PQ "0"
        set_instance_parameter tx_eth_frame_decoder ENABLE_PFC_STATUS "0"
        set_instance_parameter tx_eth_frame_decoder CONTINUOUS_VALID "0"

        #  Error Adapter TX for Statistics
        add_instance tx_st_error_adapter_stat error_adapter
        set_instance_parameter tx_st_error_adapter_stat generationLanguage "VERILOG"
        set_instance_parameter tx_st_error_adapter_stat inBitsPerSymbol "40"
        set_instance_parameter tx_st_error_adapter_stat inChannelWidth "0"
        set_instance_parameter tx_st_error_adapter_stat inErrorDescriptor "payload_length,oversize,undersize,crc,underflow,user"
        set_instance_parameter tx_st_error_adapter_stat inErrorWidth "6"
        set_instance_parameter tx_st_error_adapter_stat inMaxChannel "0"
        set_instance_parameter tx_st_error_adapter_stat inReadyLatency "0"
        set_instance_parameter tx_st_error_adapter_stat inSymbolsPerBeat "1"
        set_instance_parameter tx_st_error_adapter_stat inUseEmpty "false"
        set_instance_parameter tx_st_error_adapter_stat inUseEmptyPort "AUTO"
        set_instance_parameter tx_st_error_adapter_stat inUsePackets "false"
        set_instance_parameter tx_st_error_adapter_stat inUseReady "false"
        set_instance_parameter tx_st_error_adapter_stat moduleName ""
        set_instance_parameter tx_st_error_adapter_stat outErrorDescriptor "phy,user,underflow,crc,payload_length,oversize,undersize"
        set_instance_parameter tx_st_error_adapter_stat outErrorWidth "7"

		#  Timing Adapter for Status Splitter Input
        add_instance tx_st_timing_adapter_splitter_status_in timing_adapter
        set_instance_parameter tx_st_timing_adapter_splitter_status_in generationLanguage "VERILOG"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inBitsPerSymbol "40"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inChannelWidth "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inErrorDescriptor ""
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inErrorWidth "7"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inMaxChannel "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inSymbolsPerBeat "1"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inUseEmpty "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inUseEmptyPort "YES"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inUsePackets "false"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inUseReady "false"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in inUseValid "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in moduleName ""
        set_instance_parameter tx_st_timing_adapter_splitter_status_in outReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in outUseReady "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_in outUseValid "true"
		
		#  Timing Adapter for Statistics of Status Splitter
        add_instance tx_st_timing_adapter_splitter_status_output timing_adapter
        set_instance_parameter tx_st_timing_adapter_splitter_status_output generationLanguage "VERILOG"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inBitsPerSymbol "40"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inChannelWidth "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inErrorDescriptor ""
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inErrorWidth "7"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inMaxChannel "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inSymbolsPerBeat "1"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inUseEmpty "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inUseEmptyPort "YES"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inUsePackets "false"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inUseReady "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output inUseValid "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output moduleName ""
        set_instance_parameter tx_st_timing_adapter_splitter_status_output outReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output outUseReady "false"
        set_instance_parameter tx_st_timing_adapter_splitter_status_output outUseValid "true"
		
		# Splitter for TX Status
        add_instance tx_st_status_splitter altera_avalon_st_splitter 
        set_instance_parameter tx_st_status_splitter NUMBER_OF_OUTPUTS "2"
        set_instance_parameter tx_st_status_splitter QUALIFY_VALID_OUT "1"
        set_instance_parameter tx_st_status_splitter DATA_WIDTH "40"
        set_instance_parameter tx_st_status_splitter BITS_PER_SYMBOL "40"
        set_instance_parameter tx_st_status_splitter USE_PACKETS "0"
        set_instance_parameter tx_st_status_splitter USE_CHANNEL "0"
        set_instance_parameter tx_st_status_splitter CHANNEL_WIDTH "1"
        set_instance_parameter tx_st_status_splitter MAX_CHANNELS "1"
        set_instance_parameter tx_st_status_splitter USE_ERROR "1"
        set_instance_parameter tx_st_status_splitter ERROR_WIDTH "7"	
	   
		#  Timing Adapter for Statistics of Status Splitter
        add_instance tx_st_timing_adapter_splitter_status_statistics timing_adapter
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics generationLanguage "VERILOG"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inBitsPerSymbol "40"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inChannelWidth "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inErrorDescriptor ""
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inErrorWidth "7"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inMaxChannel "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inSymbolsPerBeat "1"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inUseEmpty "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inUseEmptyPort "YES"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inUsePackets "false"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inUseReady "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics inUseValid "true"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics moduleName ""
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics outReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics outUseReady "false"
        set_instance_parameter tx_st_timing_adapter_splitter_status_statistics outUseValid "true"
		
        if {$reg_stat == 1} {
            # Statistics Collector TX Register Based
            add_instance tx_eth_statistics_collector altera_eth_statistics_collector
            set_instance_parameter tx_eth_statistics_collector ENABLE_PFC $pfc_ena
        } else {
            # Statistics Collector TX Memory Based
            add_instance tx_eth_statistics_collector altera_eth_10gmem_statistics_collector
            set_instance_parameter tx_eth_statistics_collector ENABLE_PFC $pfc_ena
        }
    } else {
		if {$preamble_mode == 1} {
			#  Avalon ST Splitter TX 1
			add_instance tx_st_splitter_1 altera_avalon_st_splitter 
			set_instance_parameter tx_st_splitter_1 NUMBER_OF_OUTPUTS "2"
			set_instance_parameter tx_st_splitter_1 QUALIFY_VALID_OUT "1"
			set_instance_parameter tx_st_splitter_1 DATA_WIDTH "64"
			set_instance_parameter tx_st_splitter_1 BITS_PER_SYMBOL "8"
			set_instance_parameter tx_st_splitter_1 USE_PACKETS "1"
			set_instance_parameter tx_st_splitter_1 USE_CHANNEL "0"
			set_instance_parameter tx_st_splitter_1 CHANNEL_WIDTH "1"
			set_instance_parameter tx_st_splitter_1 MAX_CHANNELS "1"
			set_instance_parameter tx_st_splitter_1 USE_ERROR "1"
			set_instance_parameter tx_st_splitter_1 ERROR_WIDTH "3"
		}	
	}
       
    if {$stat_ena == 1} {
		add_connection tx_st_pipeline_stage_rs.source0/tx_st_splitter_1.in
		if {$preamble_mode == 1} {
			add_connection tx_st_splitter_1.out0/tx_st_timing_adapter_frame_decoder.in
			add_connection tx_st_splitter_1.out1/tx_eth_packet_formatter.data_sink
			add_connection tx_st_splitter_1.out2/tx_preamble_passthrough.avalon_streaming_sink_pkt_f
		} else {
            if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
                #Data Mux for MAC and RS Layer
                add_connection tx_st_splitter_1.out0/tx_st_timing_adapter_frame_decoder.in
                add_connection tx_st_splitter_1.out1/tx_st_mux_avst_2_rs_layer.avalon_streaming_sink

                
                add_connection tx_st_mux_avst_2_rs_layer.out0/tx_eth_packet_formatter.data_sink
                add_connection tx_st_mux_avst_2_rs_layer.out1/tx_eth_gmii_mii_encoder.avalon_streaming_sink
                #add_connection tx_st_mux_avst_2_rs_layer.sel/clk_switcher.sel_out1
                add_connection tx_st_mux_avst_2_rs_layer.sel/speed_sel_splitter.dout0
                
                

            } else {
                add_connection tx_st_splitter_1.out0/tx_st_timing_adapter_frame_decoder.in
                add_connection tx_st_splitter_1.out1/tx_eth_packet_formatter.data_sink
            }
		}
        add_connection tx_st_timing_adapter_frame_decoder.out/tx_eth_frame_decoder.avalon_st_data_sink
        add_connection tx_eth_frame_decoder.avalon_st_rxstatus_src/tx_st_error_adapter_stat.in

		add_connection tx_st_error_adapter_stat.out/tx_st_timing_adapter_splitter_status_in.in
        add_connection tx_st_timing_adapter_splitter_status_in.out/tx_st_status_splitter.in
        add_connection tx_st_status_splitter.out0/tx_st_timing_adapter_splitter_status_statistics.in
        
        add_instance tx_st_status_output_delay_to_statistic altera_avalon_st_delay
        set_instance_parameter tx_st_status_output_delay_to_statistic NUMBER_OF_DELAY_CLOCKS "1"
        set_instance_parameter tx_st_status_output_delay_to_statistic DATA_WIDTH "40"
        set_instance_parameter tx_st_status_output_delay_to_statistic BITS_PER_SYMBOL "40"
        set_instance_parameter tx_st_status_output_delay_to_statistic USE_PACKETS "0"
        set_instance_parameter tx_st_status_output_delay_to_statistic USE_CHANNEL "0"
        set_instance_parameter tx_st_status_output_delay_to_statistic CHANNEL_WIDTH "1"
        set_instance_parameter tx_st_status_output_delay_to_statistic MAX_CHANNELS "1"
        set_instance_parameter tx_st_status_output_delay_to_statistic USE_ERROR "1"
        set_instance_parameter tx_st_status_output_delay_to_statistic ERROR_WIDTH "7"
        
        # add_connection tx_st_timing_adapter_splitter_status_statistics.out/tx_eth_statistics_collector.avalon_st_sink_data
        add_connection tx_st_timing_adapter_splitter_status_statistics.out/tx_st_status_output_delay_to_statistic.in
        add_connection tx_st_status_output_delay_to_statistic.out/tx_eth_statistics_collector.avalon_st_sink_data
		
        
		add_connection tx_st_status_splitter.out1/tx_st_timing_adapter_splitter_status_output.in	
    } else {
		if {$preamble_mode == 1} {
		add_connection tx_st_pipeline_stage_rs.source0/tx_st_splitter_1.in
		add_connection tx_st_splitter_1.out0/tx_eth_packet_formatter.data_sink
        add_connection tx_st_splitter_1.out1/tx_preamble_passthrough.avalon_streaming_sink_pkt_f	
		} else {
            if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
               ##Data Mux for MAC and RS Layer
                add_connection tx_st_pipeline_stage_rs.source0/tx_st_mux_avst_2_rs_layer.avalon_streaming_sink
                add_connection tx_st_mux_avst_2_rs_layer.out0/tx_eth_packet_formatter.data_sink
                add_connection tx_st_mux_avst_2_rs_layer.out1/tx_eth_gmii_mii_encoder.avalon_streaming_sink
                add_connection tx_st_mux_avst_2_rs_layer.sel/speed_sel_splitter.dout0
            } else {
                add_connection tx_st_pipeline_stage_rs.source0/tx_eth_packet_formatter.data_sink
            }
		}		
	}
    
	if {$timestamp_ena == 1} {
		# Clock Connections
		add_connection ${tx_clock_src}/tx_st_splitter_tx_data.clk
		add_connection ${tx_reset_src}/tx_st_splitter_tx_data.reset
		add_connection ${tx_clock_src}/tx_st_timing_adapter_tx_data.clk
		add_connection ${tx_reset_src}/tx_st_timing_adapter_tx_data.reset
		add_connection ${tx_clock_src}/tx_eth_timestamp_req_ctrl.clk_10g
		add_connection ${tx_reset_src}/tx_eth_timestamp_req_ctrl.reset_10g
		add_connection ${tx_clock_src}/tx_st_splitter_mux.clk
		add_connection ${tx_reset_src}/tx_st_splitter_mux.reset
		add_connection ${tx_clock_src}/tx_st_timing_adapter_mux.clk
		add_connection ${tx_reset_src}/tx_st_timing_adapter_mux.reset
        
        if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
            add_connection ${tx_1g_clock_src}/tx_eth_timestamp_req_ctrl.clk_1g
            add_connection ${tx_1g_reset_src}/tx_eth_timestamp_req_ctrl.reset_1g
        }
	}
    
    if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
    add_connection speed_sel_splitter.dout3/tx_eth_gmii_mii_encoder.speed_sel
    add_connection speed_sel_splitter.dout4/rx_eth_gmii_mii_decoder.speed_sel
    
    
    
    }

    if {$crc_tx == 1} {
        if {$timestamp_ena == 1 && $ptp_1step_ena == 1} {
            add_connection ${tx_clock_src}/tx_eth_crc_allocation.clk_10g
            add_connection ${tx_reset_src}/tx_eth_crc_allocation.reset_10g
            add_connection ${csr_reset}/tx_eth_crc_allocation.csr_reset
            
            if {$mac_1g10g_ena == 1 || $mac_1g10g_ena == 2} {
                add_connection ${tx_1g_clock_src}/tx_eth_crc_allocation.clk_1g
                add_connection ${tx_1g_reset_src}/tx_eth_crc_allocation.reset_1g
            }
        } else {
            add_connection ${tx_clock_src}/tx_eth_crc_inserter.clock_reset
            add_connection ${tx_reset_src}/tx_eth_crc_inserter.clock_reset_reset
            add_connection ${csr_reset}/tx_eth_crc_inserter.csr_reset
        }
    } else {
        add_connection ${tx_clock_src}/tx_st_error_adapter_no_crc.clk
        add_connection ${tx_reset_src}/tx_st_error_adapter_no_crc.reset
    }

	
    add_connection ${tx_clock_src}/tx_eth_packet_underflow_control.clock_reset
    add_connection ${tx_reset_src}/tx_eth_packet_underflow_control.clock_reset_reset
    add_connection ${csr_reset}/tx_eth_packet_underflow_control.csr_reset
    add_connection ${tx_clock_src}/tx_eth_pad_inserter.clock_reset
    add_connection ${tx_reset_src}/tx_eth_pad_inserter.clock_reset_reset
    add_connection ${csr_reset}/tx_eth_pad_inserter.csr_reset
    add_connection ${tx_clock_src}/tx_eth_pkt_backpressure_control.clock_reset
    add_connection ${tx_reset_src}/tx_eth_pkt_backpressure_control.clock_reset_reset
    add_connection ${csr_reset}/tx_eth_pkt_backpressure_control.csr_reset
    add_connection ${tx_clock_src}/tx_eth_pause_beat_conversion.clock_reset
    add_connection ${tx_reset_src}/tx_eth_pause_beat_conversion.clock_reset_reset
    
    if {[_get_device_type]} {
        add_connection ${tx_clock_src}/tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control.cr0
        add_connection ${tx_reset_src}/tx_st_pipeline_stage_pad_inserter_pkt_backpressure_control.cr0_reset
    }
    
    add_connection ${tx_clock_src}/tx_eth_pause_ctrl_gen.clock_reset
    add_connection ${tx_reset_src}/tx_eth_pause_ctrl_gen.clock_reset_reset
    add_connection ${csr_reset}/tx_eth_pause_ctrl_gen.csr_reset
    add_connection ${tx_clock_src}/tx_st_pause_ctrl_error_adapter.clk
    add_connection ${tx_reset_src}/tx_st_pause_ctrl_error_adapter.reset
    add_connection ${tx_clock_src}/tx_st_mux_flow_control_user_frame.clk
    add_connection ${tx_reset_src}/tx_st_mux_flow_control_user_frame.reset
    add_connection ${tx_clock_src}/tx_st_channel_adapter_mux_crc.clock_reset
    add_connection ${tx_reset_src}/tx_st_channel_adapter_mux_crc.clock_reset_reset
    add_connection ${tx_clock_src}/tx_eth_address_inserter.clock_reset
    add_connection ${tx_reset_src}/tx_eth_address_inserter.clock_reset_reset
    add_connection ${csr_reset}/tx_eth_address_inserter.csr_reset
    
    add_connection ${tx_clock_src}/tx_st_pipeline_stage_rs.cr0
    add_connection ${tx_reset_src}/tx_st_pipeline_stage_rs.cr0_reset
    
	
    if {$stat_ena == 1} {
		add_connection ${tx_clock_src}/tx_st_splitter_1.clk
        add_connection ${tx_reset_src}/tx_st_splitter_1.reset	
        add_connection ${tx_clock_src}/tx_st_timing_adapter_frame_decoder.clk
        add_connection ${tx_reset_src}/tx_st_timing_adapter_frame_decoder.reset
        add_connection ${tx_clock_src}/tx_eth_frame_decoder.clock_reset
        add_connection ${tx_reset_src}/tx_eth_frame_decoder.clock_reset_reset
        add_connection ${csr_reset}/tx_eth_frame_decoder.csr_reset
        add_connection ${tx_clock_src}/tx_st_error_adapter_stat.clk
        add_connection ${tx_reset_src}/tx_st_error_adapter_stat.reset
        add_connection ${tx_clock_src}/tx_st_timing_adapter_splitter_status_in.clk
        add_connection ${tx_reset_src}/tx_st_timing_adapter_splitter_status_in.reset
		add_connection ${tx_clock_src}/tx_st_timing_adapter_splitter_status_output.clk
        add_connection ${tx_reset_src}/tx_st_timing_adapter_splitter_status_output.reset
		add_connection ${tx_clock_src}/tx_st_status_splitter.clk
		add_connection ${tx_reset_src}/tx_st_status_splitter.reset
        add_connection ${tx_clock_src}/tx_st_status_output_delay_to_statistic.clk
		add_connection ${tx_reset_src}/tx_st_status_output_delay_to_statistic.clk_reset
		add_connection ${tx_clock_src}/tx_st_timing_adapter_splitter_status_statistics.clk
        add_connection ${tx_reset_src}/tx_st_timing_adapter_splitter_status_statistics.reset
		
        add_connection ${tx_clock_src}/tx_eth_statistics_collector.clock
        add_connection ${csr_reset}/tx_eth_statistics_collector.csr_reset
    } else {
		if {$preamble_mode == 1} {
			add_connection ${tx_clock_src}/tx_st_splitter_1.clk
            add_connection ${tx_reset_src}/tx_st_splitter_1.reset	
		}
	}
    
    if {$pfc_ena == 1} {
        add_connection ${tx_clock_src}/tx_eth_pfc_gen.clock_reset
        add_connection ${tx_reset_src}/tx_eth_pfc_gen.clock_reset_reset
        add_connection ${csr_reset}/tx_eth_pfc_gen.csr_reset
        add_connection ${tx_clock_src}/tx_st_mux_fc_pfc.clk
        add_connection ${tx_reset_src}/tx_st_mux_fc_pfc.reset
        add_connection ${tx_clock_src}/tx_st_channel_adapter_mux_fc_pfc.clock_reset
        add_connection ${tx_reset_src}/tx_st_channel_adapter_mux_fc_pfc.clock_reset_reset
    }
    
	if {$preamble_mode == 1} {
		add_connection ${tx_clock_src}/tx_st_splitter_2.clk
        add_connection ${tx_reset_src}/tx_st_splitter_2.reset
	}
	
    # CSR Connections
    add_connection ${tx_csr_master}/tx_eth_pkt_backpressure_control.csr
    set_connection_parameter_value ${tx_csr_master}/tx_eth_pkt_backpressure_control.csr arbitrationPriority "1"
    if {[_get_device_type]} {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_pkt_backpressure_control.csr baseAddress "0x4000"         
    } else {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_pkt_backpressure_control.csr baseAddress "0x0000"
    }
   
    add_connection ${tx_csr_master}/tx_eth_pad_inserter.csr
    set_connection_parameter_value ${tx_csr_master}/tx_eth_pad_inserter.csr arbitrationPriority "1"
    if {[_get_device_type]} {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_pad_inserter.csr baseAddress "0x4100"
    } else {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_pad_inserter.csr baseAddress "0x0100"   
    }
    
    add_connection ${tx_csr_master}/tx_eth_pause_ctrl_gen.csr
    set_connection_parameter_value ${tx_csr_master}/tx_eth_pause_ctrl_gen.csr arbitrationPriority "1"
    if {[_get_device_type]} {
    set_connection_parameter_value ${tx_csr_master}/tx_eth_pause_ctrl_gen.csr baseAddress "0x4500"
    } else {
    set_connection_parameter_value ${tx_csr_master}/tx_eth_pause_ctrl_gen.csr baseAddress "0x0500"
    }
    add_connection ${tx_csr_master}/tx_eth_address_inserter.csr
    set_connection_parameter_value ${tx_csr_master}/tx_eth_address_inserter.csr arbitrationPriority "1"
    if {[_get_device_type]} {
    set_connection_parameter_value ${tx_csr_master}/tx_eth_address_inserter.csr baseAddress "0x4800"
    } else {
    set_connection_parameter_value ${tx_csr_master}/tx_eth_address_inserter.csr baseAddress "0x0800"
    }
    
    add_connection ${tx_csr_master}/tx_eth_packet_underflow_control.avalon_slave_0
    set_connection_parameter_value ${tx_csr_master}/tx_eth_packet_underflow_control.avalon_slave_0 arbitrationPriority "1"
    if {[_get_device_type]} {
    set_connection_parameter_value ${tx_csr_master}/tx_eth_packet_underflow_control.avalon_slave_0 baseAddress "0x4300"
    } else {
    set_connection_parameter_value ${tx_csr_master}/tx_eth_packet_underflow_control.avalon_slave_0 baseAddress "0x0300"
    }
    
    if {$stat_ena == 1} {
        add_connection ${tx_csr_master}/tx_eth_frame_decoder.avalom_mm_csr
        set_connection_parameter_value ${tx_csr_master}/tx_eth_frame_decoder.avalom_mm_csr arbitrationPriority "1"
        if {[_get_device_type]} {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_frame_decoder.avalom_mm_csr baseAddress "0x06000"
        } else {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_frame_decoder.avalom_mm_csr baseAddress "0x02000"
        }
        
        add_connection ${tx_csr_master}/tx_eth_statistics_collector.csr
        set_connection_parameter_value ${tx_csr_master}/tx_eth_statistics_collector.csr arbitrationPriority "1"
        if {[_get_device_type]} {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_statistics_collector.csr baseAddress "0x07000"
        } else {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_statistics_collector.csr baseAddress "0x03000"
        }
    }
	
    if {$pfc_ena == 1} {
        add_connection ${tx_csr_master}/tx_eth_pfc_gen.csr
        set_connection_parameter_value ${tx_csr_master}/tx_eth_pfc_gen.csr arbitrationPriority "1"
        if {[_get_device_type]} {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_pfc_gen.csr baseAddress "0x4600"
        } else {
        set_connection_parameter_value ${tx_csr_master}/tx_eth_pfc_gen.csr baseAddress "0x0600"
        }
    }
    
	if {$preamble_mode == 1} {
		add_connection ${tx_csr_master}/tx_preamble_passthrough.csr
		set_connection_parameter_value ${tx_csr_master}/tx_preamble_passthrough.csr arbitrationPriority "1"
        if {[_get_device_type]} {
        set_connection_parameter_value ${tx_csr_master}/tx_preamble_passthrough.csr baseAddress "0x4400"
        } else {
        set_connection_parameter_value ${tx_csr_master}/tx_preamble_passthrough.csr baseAddress "0x0400"
        }
        
	}
	
	#connection changes due to time stamping
	if {$timestamp_ena == 1} {
		if { $preamble_mode == 1 } {
			add_connection tx_st_splitter_tx_data.out0/tx_preamble_passthrough.avalon_streaming_sink_user
		} else {
			add_connection tx_st_splitter_tx_data.out0/tx_eth_packet_underflow_control.avalon_streaming_sink
		}
		add_connection tx_st_splitter_tx_data.out1/tx_st_timing_adapter_tx_data.in
		add_connection tx_st_timing_adapter_tx_data.out/tx_eth_timestamp_req_ctrl.avalon_streaming_sink
		add_connection tx_st_splitter_mux.out1/tx_st_timing_adapter_mux.in
		add_connection tx_st_timing_adapter_mux.out/tx_eth_timestamp_req_ctrl.avalon_streaming_sink_mux
	}
	
}

proc compose_eth_xgmii_tx {tx_clock_src tx_reset_src tx_csr_master crc_tx preamble_mode timestamp_ena ptp_1step_ena} {

    #  Packet Formatter
    add_instance tx_eth_packet_formatter altera_eth_packet_formatter
    set_instance_parameter tx_eth_packet_formatter ERROR_WIDTH "3"
    set_instance_parameter tx_eth_packet_formatter GET_PREAMBLE $preamble_mode
    
    #  XGMII Termination
    add_instance tx_eth_xgmii_termination altera_eth_xgmii_termination
    
    #  Timing Adapter TX Splitter In
    add_instance tx_st_timing_adapter_splitter_in timing_adapter
    set_instance_parameter tx_st_timing_adapter_splitter_in generationLanguage "VERILOG"
    set_instance_parameter tx_st_timing_adapter_splitter_in inBitsPerSymbol "9"
    set_instance_parameter tx_st_timing_adapter_splitter_in inChannelWidth "0"
    set_instance_parameter tx_st_timing_adapter_splitter_in inErrorDescriptor ""
    set_instance_parameter tx_st_timing_adapter_splitter_in inErrorWidth "0"
    set_instance_parameter tx_st_timing_adapter_splitter_in inMaxChannel "0"
    set_instance_parameter tx_st_timing_adapter_splitter_in inReadyLatency "0"
    set_instance_parameter tx_st_timing_adapter_splitter_in inSymbolsPerBeat "8"
    set_instance_parameter tx_st_timing_adapter_splitter_in inUseEmpty "false"
    set_instance_parameter tx_st_timing_adapter_splitter_in inUseEmptyPort "NO"
    set_instance_parameter tx_st_timing_adapter_splitter_in inUsePackets "false"
    set_instance_parameter tx_st_timing_adapter_splitter_in inUseReady "false"
    set_instance_parameter tx_st_timing_adapter_splitter_in inUseValid "false"
    set_instance_parameter tx_st_timing_adapter_splitter_in moduleName ""
    set_instance_parameter tx_st_timing_adapter_splitter_in outReadyLatency "0"
    set_instance_parameter tx_st_timing_adapter_splitter_in outUseReady "true"
    set_instance_parameter tx_st_timing_adapter_splitter_in outUseValid "true"
    add_connection ${tx_clock_src}/tx_st_timing_adapter_splitter_in.clk
    add_connection ${tx_reset_src}/tx_st_timing_adapter_splitter_in.reset
    
    #  Splitter
    add_instance tx_st_splitter_xgmii altera_avalon_st_splitter
    if {$timestamp_ena == 1 && $ptp_1step_ena == 0} {
        set_instance_parameter tx_st_splitter_xgmii NUMBER_OF_OUTPUTS "2"
    } else {
        set_instance_parameter tx_st_splitter_xgmii NUMBER_OF_OUTPUTS "1"
    }
    set_instance_parameter tx_st_splitter_xgmii QUALIFY_VALID_OUT "1"
    set_instance_parameter tx_st_splitter_xgmii DATA_WIDTH "72"
    set_instance_parameter tx_st_splitter_xgmii BITS_PER_SYMBOL "9"
    set_instance_parameter tx_st_splitter_xgmii USE_PACKETS "0"
    set_instance_parameter tx_st_splitter_xgmii USE_CHANNEL "0"
    set_instance_parameter tx_st_splitter_xgmii CHANNEL_WIDTH "1"
    set_instance_parameter tx_st_splitter_xgmii MAX_CHANNELS "1"
    set_instance_parameter tx_st_splitter_xgmii USE_ERROR "0"
    set_instance_parameter tx_st_splitter_xgmii ERROR_WIDTH "1"
    add_connection ${tx_clock_src}/tx_st_splitter_xgmii.clk
    add_connection ${tx_reset_src}/tx_st_splitter_xgmii.reset
    
    #  Timing Adapter TX Splitter Out 0
    add_instance tx_st_timing_adapter_splitter_out_0 timing_adapter
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 generationLanguage "VERILOG"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inBitsPerSymbol "9"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inChannelWidth "0"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inErrorDescriptor ""
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inErrorWidth "0"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inMaxChannel "0"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inReadyLatency "0"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inSymbolsPerBeat "8"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inUseEmpty "false"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inUseEmptyPort "NO"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inUsePackets "false"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inUseReady "true"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 inUseValid "true"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 moduleName ""
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 outReadyLatency "0"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 outUseReady "false"
    set_instance_parameter tx_st_timing_adapter_splitter_out_0 outUseValid "false"
    add_connection ${tx_clock_src}/tx_st_timing_adapter_splitter_out_0.clk
    add_connection ${tx_reset_src}/tx_st_timing_adapter_splitter_out_0.reset
    
    if {$timestamp_ena == 1 && $ptp_1step_ena == 0} {
        #  Timing Adapter TX Splitter Out 1
        add_instance tx_st_timing_adapter_splitter_out_1 timing_adapter
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 generationLanguage "VERILOG"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inBitsPerSymbol "9"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inChannelWidth "0"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inErrorDescriptor ""
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inErrorWidth "0"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inMaxChannel "0"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inSymbolsPerBeat "8"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inUseEmpty "false"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inUseEmptyPort "NO"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inUsePackets "false"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inUseReady "true"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 inUseValid "true"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 moduleName ""
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 outReadyLatency "0"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 outUseReady "false"
        set_instance_parameter tx_st_timing_adapter_splitter_out_1 outUseValid "false"
        add_connection ${tx_clock_src}/tx_st_timing_adapter_splitter_out_1.clk
        add_connection ${tx_reset_src}/tx_st_timing_adapter_splitter_out_1.reset
    }
    #  Link Fault Generation
    add_instance tx_eth_link_fault_generation altera_eth_link_fault_generation
    
    if {$timestamp_ena == 1} {
        # XGMII TSU in TX
		add_instance tx_eth_xgmii_tsu altera_eth_xgmii_tsu
        set_instance_parameter tx_eth_xgmii_tsu INTERNAL_PATH_DELAY_CYCLE "1"
        set_instance_parameter tx_eth_xgmii_tsu DELAY_SIGN "0"
        set_instance_parameter tx_eth_xgmii_tsu ENABLE_DATA_SRC $ptp_1step_ena
		
		# Add 1-stage pipeline between XGMII Termination and XGMII TSU for devices: Arria V, Cyclone V
		if {[_get_device_type_1588]} {
			#  Pipeline between XGMII Termination and XGMII TSU
			add_instance xgmii_pipeline altera_eth_xgmii_pipeline
		}
		
        if {$ptp_1step_ena == 1} {          
            # XGMII Timestamp inserter
            # Internal Path Delay increased to 11 when timestamp inserter is instantiated
            set_instance_parameter tx_eth_xgmii_tsu INTERNAL_PATH_DELAY_CYCLE "11"
            add_instance tx_eth_xgmii_ptp_inserter altera_eth_xgmii_ptp_inserter
            
            if {$crc_tx == 1} {
                #  CRC Inserter TX
                add_instance tx_eth_xgmii_crc_inserter altera_eth_xgmii_crc
                set_instance_parameter tx_eth_xgmii_crc_inserter USE_FRAME_MODIFIED $ptp_1step_ena
            }
        } else {
            
        }
        
        
    }
    
    
    
    # Clock Connections
    add_connection ${tx_clock_src}/tx_eth_packet_formatter.clk
    add_connection ${tx_reset_src}/tx_eth_packet_formatter.clk_reset
    add_connection ${tx_clock_src}/tx_eth_xgmii_termination.clock_reset
    add_connection ${tx_reset_src}/tx_eth_xgmii_termination.clock_reset_reset
    add_connection ${tx_clock_src}/tx_eth_link_fault_generation.clk
    add_connection ${tx_reset_src}/tx_eth_link_fault_generation.clk_reset

    if {$timestamp_ena == 1} {
    
		add_connection ${tx_clock_src}/tx_eth_xgmii_tsu.clock_reset
		add_connection ${tx_reset_src}/tx_eth_xgmii_tsu.clock_reset_reset  
 
		if {[_get_device_type_1588]} { 
			add_connection ${tx_clock_src}/xgmii_pipeline.clock_reset
			add_connection ${tx_reset_src}/xgmii_pipeline.clock_reset_reset
		}
		
        if {$ptp_1step_ena == 1} {
            add_connection ${tx_clock_src}/tx_eth_xgmii_ptp_inserter.clock_reset
            add_connection ${tx_reset_src}/tx_eth_xgmii_ptp_inserter.clock_reset_reset
            
            if {$crc_tx == 1} {
                add_connection ${tx_clock_src}/tx_eth_xgmii_crc_inserter.clock_reset
                add_connection ${tx_reset_src}/tx_eth_xgmii_crc_inserter.clock_reset_reset
            }
        }
        
        
	}
    
    
    
    # Connections	
    add_connection tx_eth_packet_formatter.data_src/tx_eth_xgmii_termination.avalon_streaming_sink
    add_connection tx_eth_xgmii_termination.avalon_streaming_source/tx_st_timing_adapter_splitter_in.in
    add_connection tx_st_timing_adapter_splitter_in.out/tx_st_splitter_xgmii.in
    add_connection tx_st_splitter_xgmii.out0/tx_st_timing_adapter_splitter_out_0.in
    
    #connection changes due to timestamping
    if { $timestamp_ena == 1 } {       
        add_connection tx_register_map.tsu_period_ns_fns_10g_src/tx_eth_xgmii_tsu.csr_period_sink
        add_connection tx_register_map.tsu_adjust_ns_fns_10g_src/tx_eth_xgmii_tsu.csr_adjust_sink
        
		if {[_get_device_type_1588] && $ptp_1step_ena == 1} {
			add_connection tx_st_timing_adapter_splitter_out_0.out/xgmii_pipeline.xgmii_sink
			add_connection xgmii_pipeline.xgmii_source/tx_eth_xgmii_tsu.data_sink
		} else {
            if {$ptp_1step_ena == 1} {
                add_connection tx_st_timing_adapter_splitter_out_0.out/tx_eth_xgmii_tsu.data_sink
            } else {
                add_connection tx_st_splitter_xgmii.out1/tx_st_timing_adapter_splitter_out_1.in
                add_connection tx_st_timing_adapter_splitter_out_1.out/tx_eth_xgmii_tsu.data_sink
            }
		}
        
        add_connection tx_eth_xgmii_tsu.timestamp_96b/tx_eth_timestamp_req_ctrl.tsu_96b_10g_data_sink
        add_connection tx_eth_xgmii_tsu.timestamp_64b/tx_eth_timestamp_req_ctrl.tsu_64b_10g_data_sink
        
        if { $ptp_1step_ena == 1 } {
            add_connection tx_eth_xgmii_tsu.data_src/tx_eth_xgmii_ptp_inserter.xgmii_sink
            add_connection tx_eth_timestamp_req_ctrl.req_ctrl_valid_10g/tx_eth_xgmii_ptp_inserter.req_ctrl_valid
            add_connection tx_eth_timestamp_req_ctrl.time_stamp_data_10g/tx_eth_xgmii_ptp_inserter.time_stamp_data
            add_connection tx_eth_timestamp_req_ctrl.ctrl_signal_10g/tx_eth_xgmii_ptp_inserter.ctrl_signal
            add_connection tx_eth_timestamp_req_ctrl.octet_location_10g/tx_eth_xgmii_ptp_inserter.octet_location
        }
    }
            
    #connection changes due to crc
    if { $crc_tx == 1 } {  
        if { $timestamp_ena == 1 && $ptp_1step_ena == 1 } {
            add_connection tx_eth_xgmii_ptp_inserter.xgmii_source/tx_eth_xgmii_crc_inserter.xgmii_sink
            add_connection tx_eth_xgmii_crc_inserter.xgmii_source/tx_eth_link_fault_generation.mii_sink
            
            add_connection tx_eth_xgmii_ptp_inserter.packet_modified/tx_eth_xgmii_crc_inserter.frame_modified_sink
            add_connection tx_eth_crc_allocation.crc_insert_10g_src/tx_eth_xgmii_crc_inserter.crc_insert_sink
        } else {
            add_connection tx_st_timing_adapter_splitter_out_0.out/tx_eth_link_fault_generation.mii_sink
        }
    } else {    
        if { $timestamp_ena == 1 } {      
            if { $ptp_1step_ena == 1 } {
                add_connection tx_eth_xgmii_ptp_inserter.xgmii_source/tx_eth_link_fault_generation.mii_sink   
            } else {
                add_connection tx_st_timing_adapter_splitter_out_0.out/tx_eth_link_fault_generation.mii_sink
            }
        } else {
            add_connection tx_st_timing_adapter_splitter_out_0.out/tx_eth_link_fault_generation.mii_sink
        }       
    }
    
    

    # CSR Connections
	if { $timestamp_ena == 1 } {
        add_connection ${tx_csr_master}/tx_register_map.csr_tsu
        set_connection_parameter_value ${tx_csr_master}/tx_register_map.csr_tsu arbitrationPriority "1"
        if {[_get_device_type]} {
		set_connection_parameter_value ${tx_csr_master}/tx_register_map.csr_tsu baseAddress "0x4440"
        } else {
        set_connection_parameter_value ${tx_csr_master}/tx_register_map.csr_tsu baseAddress "0x0440"
        }
	}
    
    if { $crc_tx == 1 } {
        if {$timestamp_ena == 1 && $ptp_1step_ena == 1} {
            add_connection ${tx_csr_master}/tx_eth_crc_allocation.csr
            set_connection_parameter_value ${tx_csr_master}/tx_eth_crc_allocation.csr arbitrationPriority "1"
            if {[_get_device_type]} {
            set_connection_parameter_value ${tx_csr_master}/tx_eth_crc_allocation.csr baseAddress "0x4200"
            } else {
            set_connection_parameter_value ${tx_csr_master}/tx_eth_crc_allocation.csr baseAddress "0x0200"
            }
        } else {
            add_connection ${tx_csr_master}/tx_eth_crc_inserter.csr
            set_connection_parameter_value ${tx_csr_master}/tx_eth_crc_inserter.csr arbitrationPriority "1"
            if {[_get_device_type]} {
            set_connection_parameter_value ${tx_csr_master}/tx_eth_crc_inserter.csr baseAddress "0x4200"
            } else {
            set_connection_parameter_value ${tx_csr_master}/tx_eth_crc_inserter.csr baseAddress "0x0200"
            }
        }
    }
    
    
}

proc compose_eth_xgmii_rx {rx_clock_src rx_reset_src csr_reset rx_csr_master preamble_mode timestamp_ena} {
    #  Timing Adapter RX Interface Conversion
    add_instance rx_st_timing_adapter_interface_conversion timing_adapter
    set_instance_parameter rx_st_timing_adapter_interface_conversion generationLanguage "VERILOG"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inBitsPerSymbol "9"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inChannelWidth "0"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inErrorDescriptor ""
    set_instance_parameter rx_st_timing_adapter_interface_conversion inErrorWidth "0"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inMaxChannel "0"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inSymbolsPerBeat "8"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inUseEmpty "false"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inUseEmptyPort "NO"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inUsePackets "false"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inUseReady "false"
    set_instance_parameter rx_st_timing_adapter_interface_conversion inUseValid "false"
    set_instance_parameter rx_st_timing_adapter_interface_conversion moduleName ""
    set_instance_parameter rx_st_timing_adapter_interface_conversion outReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_interface_conversion outUseReady "true"
    set_instance_parameter rx_st_timing_adapter_interface_conversion outUseValid "true"
    
    #  Avalon St Splitter RX XGMII
    add_instance rx_st_splitter_xgmii altera_avalon_st_splitter
    if {$timestamp_ena == 1} {
        set_instance_parameter rx_st_splitter_xgmii NUMBER_OF_OUTPUTS "3"
    } else {
        set_instance_parameter rx_st_splitter_xgmii NUMBER_OF_OUTPUTS "2"
    }
    set_instance_parameter rx_st_splitter_xgmii QUALIFY_VALID_OUT "1"
    set_instance_parameter rx_st_splitter_xgmii DATA_WIDTH "72"
    set_instance_parameter rx_st_splitter_xgmii BITS_PER_SYMBOL "9"
    set_instance_parameter rx_st_splitter_xgmii USE_PACKETS "0"
    set_instance_parameter rx_st_splitter_xgmii USE_CHANNEL "0"
    set_instance_parameter rx_st_splitter_xgmii CHANNEL_WIDTH "1"
    set_instance_parameter rx_st_splitter_xgmii MAX_CHANNELS "1"
    set_instance_parameter rx_st_splitter_xgmii USE_ERROR "0"
    set_instance_parameter rx_st_splitter_xgmii ERROR_WIDTH "1"
 
    #  Timing Adapter RX Lane Decoder
    add_instance rx_st_timing_adapter_lane_decoder timing_adapter
    set_instance_parameter rx_st_timing_adapter_lane_decoder generationLanguage "VERILOG"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inBitsPerSymbol "9"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inChannelWidth "0"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inErrorDescriptor ""
    set_instance_parameter rx_st_timing_adapter_lane_decoder inErrorWidth "0"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inMaxChannel "0"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inSymbolsPerBeat "8"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inUseEmpty "false"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inUseEmptyPort "NO"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inUsePackets "false"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inUseReady "true"
    set_instance_parameter rx_st_timing_adapter_lane_decoder inUseValid "true"
    set_instance_parameter rx_st_timing_adapter_lane_decoder moduleName ""
    set_instance_parameter rx_st_timing_adapter_lane_decoder outReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_lane_decoder outUseReady "false"
    set_instance_parameter rx_st_timing_adapter_lane_decoder outUseValid "false"
    
    #  Timing Adapter RX Link Fault Detection
    add_instance rx_st_timing_adapter_link_fault_detection timing_adapter
    set_instance_parameter rx_st_timing_adapter_link_fault_detection generationLanguage "VERILOG"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inBitsPerSymbol "9"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inChannelWidth "0"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inErrorDescriptor ""
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inErrorWidth "0"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inMaxChannel "0"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inSymbolsPerBeat "8"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inUseEmpty "false"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inUseEmptyPort "NO"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inUsePackets "false"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inUseReady "true"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection inUseValid "true"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection moduleName ""
    set_instance_parameter rx_st_timing_adapter_link_fault_detection outReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection outUseReady "false"
    set_instance_parameter rx_st_timing_adapter_link_fault_detection outUseValid "false"
    
    #  Link Fault Detection RX
    add_instance rx_eth_link_fault_detection altera_eth_link_fault_detection
    
    #  Lane Decoder RX
    add_instance rx_eth_lane_decoder altera_eth_lane_decoder
	set_instance_parameter rx_eth_lane_decoder PREAMBLE_MODE $preamble_mode

    # XGMII TSU in RX	
    if {$timestamp_ena == 1} {
	add_instance rx_eth_xgmii_tsu altera_eth_xgmii_tsu
        set_instance_parameter rx_eth_xgmii_tsu INTERNAL_PATH_DELAY_CYCLE "0"
        set_instance_parameter rx_eth_xgmii_tsu DELAY_SIGN "1"
        set_instance_parameter rx_eth_xgmii_tsu ENABLE_DATA_SRC "0"
        
        #  Timing Adapter RX XGMII TSU
    add_instance rx_st_timing_adapter_xgmii_tsu timing_adapter
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu generationLanguage "VERILOG"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inBitsPerSymbol "9"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inChannelWidth "0"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inErrorDescriptor ""
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inErrorWidth "0"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inMaxChannel "0"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inSymbolsPerBeat "8"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inUseEmpty "false"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inUseEmptyPort "NO"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inUsePackets "false"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inUseReady "true"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu inUseValid "true"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu moduleName ""
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu outReadyLatency "0"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu outUseReady "false"
    set_instance_parameter rx_st_timing_adapter_xgmii_tsu outUseValid "false"
    
    }

    # Clock Connections
    add_connection ${rx_clock_src}/rx_st_timing_adapter_interface_conversion.clk
    add_connection ${rx_reset_src}/rx_st_timing_adapter_interface_conversion.reset
    add_connection ${rx_clock_src}/rx_st_splitter_xgmii.clk
    add_connection ${rx_reset_src}/rx_st_splitter_xgmii.reset
    
    add_connection ${rx_clock_src}/rx_st_timing_adapter_lane_decoder.clk
    add_connection ${rx_reset_src}/rx_st_timing_adapter_lane_decoder.reset
    add_connection ${rx_clock_src}/rx_eth_lane_decoder.clock_reset
    add_connection ${rx_reset_src}/rx_eth_lane_decoder.clock_reset_reset
    add_connection ${csr_reset}/rx_eth_lane_decoder.csr_reset
    
    add_connection ${rx_clock_src}/rx_st_timing_adapter_link_fault_detection.clk
    add_connection ${rx_reset_src}/rx_st_timing_adapter_link_fault_detection.reset
    add_connection ${rx_clock_src}/rx_eth_link_fault_detection.clk
    add_connection ${rx_reset_src}/rx_eth_link_fault_detection.clk_reset
    if {$timestamp_ena == 1} { 
        add_connection ${rx_clock_src}/rx_eth_xgmii_tsu.clock_reset
        add_connection ${rx_reset_src}/rx_eth_xgmii_tsu.clock_reset_reset	
        add_connection ${rx_clock_src}/rx_st_timing_adapter_xgmii_tsu.clk
        add_connection ${rx_reset_src}/rx_st_timing_adapter_xgmii_tsu.reset
    }
    
    # Connections
    add_connection rx_st_timing_adapter_interface_conversion.out/rx_st_splitter_xgmii.in
    
    add_connection rx_st_splitter_xgmii.out0/rx_st_timing_adapter_lane_decoder.in
    add_connection rx_st_timing_adapter_lane_decoder.out/rx_eth_lane_decoder.avalon_streaming_sink 
 
    add_connection rx_st_splitter_xgmii.out1/rx_st_timing_adapter_link_fault_detection.in
    add_connection rx_st_timing_adapter_link_fault_detection.out/rx_eth_link_fault_detection.mii_sink
        
    if {$timestamp_ena == 1} { 
        add_connection rx_register_map.tsu_period_ns_fns_10g_src/rx_eth_xgmii_tsu.csr_period_sink
        add_connection rx_register_map.tsu_adjust_ns_fns_10g_src/rx_eth_xgmii_tsu.csr_adjust_sink
        
        add_connection rx_st_splitter_xgmii.out2/rx_st_timing_adapter_xgmii_tsu.in
        add_connection rx_st_timing_adapter_xgmii_tsu.out/rx_eth_xgmii_tsu.data_sink
        add_connection rx_eth_xgmii_tsu.timestamp_96b/rx_eth_valid_timestamp_detector.timestamp_96b_10g_in
        add_connection rx_eth_xgmii_tsu.timestamp_64b/rx_eth_valid_timestamp_detector.timestamp_64b_10g_in
    }

    
    # CSR Connections
    if {$timestamp_ena == 1} {
		add_connection ${rx_csr_master}/rx_register_map.csr_tsu
		set_connection_parameter_value ${rx_csr_master}/rx_register_map.csr_tsu arbitrationPriority "1"
		set_connection_parameter_value ${rx_csr_master}/rx_register_map.csr_tsu baseAddress "0x440"
	}
    
}

proc compose_eth_gmii_tx {tx_clock_src tx_reset_src tx_1g_clock_src tx_1g_reset_src timestamp_ena ptp_1step_ena mac_1g10g_ena} {

    #  TX GMII Encoder
    add_instance tx_eth_gmii_mii_encoder altera_eth_gmii_mii_encoder
    set_instance_parameter tx_eth_gmii_mii_encoder W_GMII_WIDTH "8"
    set_instance_parameter tx_eth_gmii_mii_encoder BITSPERSYMBOL "8"
    set_instance_parameter tx_eth_gmii_mii_encoder SYMBOLSPERBEAT "8"
    set_instance_parameter tx_eth_gmii_mii_encoder QUAD_SPEED_ENA [expr ($mac_1g10g_ena - 1)]
    set_instance_parameter tx_eth_gmii_mii_encoder ENABLE_TIMESTAMPING $timestamp_ena
    set_instance_parameter tx_eth_gmii_mii_encoder ENABLE_PTP_1STEP $ptp_1step_ena
    
    if {$ptp_1step_ena == 0} {
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_1000 0
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_100_ALIGN_0 5
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_100_ALIGN_1 5
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_10_ALIGN_0 50
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_10_ALIGN_1 50
    } else {
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_1000 23
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_100_ALIGN_0 235
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_100_ALIGN_1 235
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_10_ALIGN_0 2350
        set_instance_parameter tx_eth_gmii_mii_encoder INTERNAL_PATH_DELAY_CYCLE_10_ALIGN_1 2350
    }
    
    # Clock Connections
    add_connection ${tx_1g_clock_src}/tx_eth_gmii_mii_encoder.clk_gmii
    add_connection ${tx_1g_reset_src}/tx_eth_gmii_mii_encoder.reset_gmii    
    
    add_connection ${tx_clock_src}/tx_eth_gmii_mii_encoder.clk_mac 
    add_connection ${tx_reset_src}/tx_eth_gmii_mii_encoder.reset_mac 

    if {$timestamp_ena == 1} {
        add_connection tx_eth_gmii_mii_encoder.timestamp_96b/tx_eth_timestamp_req_ctrl.tsu_96b_1g_data_sink
        add_connection tx_eth_gmii_mii_encoder.timestamp_64b/tx_eth_timestamp_req_ctrl.tsu_64b_1g_data_sink
    
        add_connection tx_register_map.tsu_period_ns_fns_1g_src/tx_eth_gmii_mii_encoder.period_ns_fns
        add_connection tx_register_map.tsu_adjust_ns_fns_1g_src/tx_eth_gmii_mii_encoder.adjust_ns_fns
        
        add_connection tx_eth_timestamp_req_ctrl.speed_select/speed_sel_splitter.dout5
        
        if {$ptp_1step_ena == 1} {
            add_connection tx_eth_timestamp_req_ctrl.req_ctrl_valid_1g/tx_eth_gmii_mii_encoder.req_ctrl_valid
            add_connection tx_eth_timestamp_req_ctrl.time_stamp_data_1g/tx_eth_gmii_mii_encoder.time_stamp_data
            add_connection tx_eth_timestamp_req_ctrl.ctrl_signal_1g/tx_eth_gmii_mii_encoder.ctrl_signal
            add_connection tx_eth_timestamp_req_ctrl.octet_location_1g/tx_eth_gmii_mii_encoder.octet_location
            
            add_connection tx_eth_crc_allocation.crc_insert_1g_src/tx_eth_gmii_mii_encoder.crc_insert_sink
            add_connection tx_eth_crc_allocation.speed_select/speed_sel_splitter.dout7
        }
    }
}

              
proc compose_eth_gmii_rx {rx_clock_src rx_reset_src rx_1g_clock_src rx_1g_reset_src timestamp_ena mac_1g10g_ena} {
            
    # RX GMII Decoder
    add_instance rx_eth_gmii_mii_decoder altera_eth_gmii_mii_decoder
    
    set_instance_parameter rx_eth_gmii_mii_decoder W_GMII_WIDTH "8"
    set_instance_parameter rx_eth_gmii_mii_decoder BITSPERSYMBOL "8"
    set_instance_parameter rx_eth_gmii_mii_decoder SYMBOLSPERBEAT "8"
    set_instance_parameter rx_eth_gmii_mii_decoder QUAD_SPEED_ENA [expr ($mac_1g10g_ena - 1)]
    set_instance_parameter rx_eth_gmii_mii_decoder ENABLE_TIMESTAMPING $timestamp_ena
    set_instance_parameter rx_eth_gmii_mii_decoder INTERNAL_PATH_DELAY_CYCLE_1000 "1"
    set_instance_parameter rx_eth_gmii_mii_decoder INTERNAL_PATH_DELAY_CYCLE_100_ALIGN_0 20
    set_instance_parameter rx_eth_gmii_mii_decoder INTERNAL_PATH_DELAY_CYCLE_100_ALIGN_1 25
    set_instance_parameter rx_eth_gmii_mii_decoder INTERNAL_PATH_DELAY_CYCLE_10_ALIGN_0 200
    set_instance_parameter rx_eth_gmii_mii_decoder INTERNAL_PATH_DELAY_CYCLE_10_ALIGN_1 250
    
    # Clock Connections  
    add_connection ${rx_clock_src}/rx_eth_gmii_mii_decoder.clk_mac 
    add_connection ${rx_reset_src}/rx_eth_gmii_mii_decoder.reset_mac 
    
    add_connection ${rx_1g_clock_src}/rx_eth_gmii_mii_decoder.clk_gmii
    add_connection ${rx_1g_reset_src}/rx_eth_gmii_mii_decoder.reset_gmii
    
    # Avalon ST Multiplexer for GMII and XGMII RS layer
    add_instance rx_st_mux_rs_layer_2_avst altera_eth_rs_mux
    set_instance_parameter rx_st_mux_rs_layer_2_avst SYMBOLS_PER_BEAT "8"
    set_instance_parameter rx_st_mux_rs_layer_2_avst BITS_PER_SYMBOL "8"
    set_instance_parameter rx_st_mux_rs_layer_2_avst ERROR_WIDTH "1"
    
    add_connection ${rx_clock_src}/rx_st_mux_rs_layer_2_avst.clock_reset
    add_connection ${rx_reset_src}/rx_st_mux_rs_layer_2_avst.clock_reset_reset
    
    if {$timestamp_ena == 1} {
        add_connection rx_register_map.tsu_period_ns_fns_1g_src/rx_eth_gmii_mii_decoder.period_ns_fns
        add_connection rx_register_map.tsu_adjust_ns_fns_1g_src/rx_eth_gmii_mii_decoder.adjust_ns_fns
        
        add_connection rx_eth_gmii_mii_decoder.timestamp_96b/rx_eth_valid_timestamp_detector.timestamp_96b_1g_in
        add_connection rx_eth_gmii_mii_decoder.timestamp_64b/rx_eth_valid_timestamp_detector.timestamp_64b_1g_in
        
        add_connection rx_eth_valid_timestamp_detector.speed_select/speed_sel_splitter.dout6
    }
}

proc _get_device_type {} {
    set device_family [get_parameter_value DEVICE_FAMILY]
    
    if {![string compare $device_family "Cyclone IV GX"]} {
        return 1;
    } elseif {![string compare $device_family "Cyclone V"]} {
        return 1;
    } elseif {![string compare $device_family "Arria GX"]} {
        return 1;
    } else {
        return 0;
    }
}

proc _get_device_type_1588 {} {
    set device_family [get_parameter_value DEVICE_FAMILY]
    
    if {![string compare $device_family "Arria V"]} {
        return 1;
    #} elseif {![string compare $device_family "Cyclone V"]} {
    #    return 1;
    } else {
        return 0;
    }
}
