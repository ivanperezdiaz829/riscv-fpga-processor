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
# | module altera_eth_2_5g_system
# |
set_module_property NAME altera_eth_2_5g_system
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet"
set_module_property DISPLAY_NAME "Altera Ethernet 2.5Gb Design Example"
set_module_property DESCRIPTION "Altera Ethernet 2.5Gb System"
#set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_2.5gbe.pdf"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property COMPOSE_CALLBACK compose
set_module_property ANALYZE_HDL false
set_module_property VALIDATION_CALLBACK validate
# |
# +-----------------------------------

# +-----------------------------------
# | Add list of files that need to be simulated
# |
#add_fileset sim EXAMPLE_DESIGN testbench_proc
add_fileset testbench EXAMPLE_DESIGN testbench_proc

# add_file avalon_bfm_wrapper.sv
# add_file avalon_driver.sv
# add_file avalon_if_params_pkg.sv
# add_file avalon_st_eth_packet_monitor.sv
# add_file eth_mac_frame.sv
# add_file eth_register_map_params_pkg.sv
# add_file tb.sv
# add_file tb_run.tcl# |
# +-----------------------------------

# +-----------------------------------
# | parameters
# |

add_display_item "" "General Configuration" GROUP

add_parameter DEVICE_FAMILY STRING "Stratix IV"
set_parameter_property DEVICE_FAMILY DISPLAY_NAME "Device Family"
set_parameter_property DEVICE_FAMILY DESCRIPTION "Target Device Family for Ethernet 2.5G System IP"
set_parameter_property DEVICE_FAMILY ALLOWED_RANGES {"Arria II GX" "Stratix IV" "Arria V" "Arria V GZ" "Stratix V" "Cyclone V"}
set_parameter_property DEVICE_FAMILY ENABLED false
set_parameter_property DEVICE_FAMILY VISIBLE true
add_display_item "General Configuration" "DEVICE_FAMILY" parameter 
set_parameter_property DEVICE_FAMILY IS_HDL_PARAMETER false
set_parameter_property DEVICE_FAMILY SYSTEM_INFO DEVICE_FAMILY

add_parameter CONFIGURATION INTEGER 0 
set_parameter_property CONFIGURATION DEFAULT_VALUE 1
set_parameter_property CONFIGURATION DISPLAY_NAME "Configuration types"
set_parameter_property CONFIGURATION ENABLED true
set_parameter_property CONFIGURATION allowed_ranges {"0:2.5G PHY only" "1:2.5G MAC and PHY"}
set_parameter_property CONFIGURATION DESCRIPTION "Phy only or MAC & PHY seclection"
add_display_item "General Configuration" "CONFIGURATION" parameter 
add_display_item "" "PHY Configuration" GROUP
add_parameter STARTING_CHANNEL_NUMBER INTEGER 0
set_parameter_property STARTING_CHANNEL_NUMBER DISPLAY_NAME "Starting channel number"
set_parameter_property STARTING_CHANNEL_NUMBER DISPLAY_UNITS ""
set_parameter_property STARTING_CHANNEL_NUMBER allowed_ranges {"0" "4" "8"}
set_parameter_property STARTING_CHANNEL_NUMBER DESCRIPTION "Starting channel number"
add_display_item "PHY Configuration" "STARTING_CHANNEL_NUMBER" parameter

add_display_item "" "DC FIFO Configuration" GROUP
add_parameter ASYNC_TX_FIFO_DEPTH INTEGER 0 
set_parameter_property ASYNC_TX_FIFO_DEPTH DEFAULT_VALUE 16
set_parameter_property ASYNC_TX_FIFO_DEPTH DISPLAY_NAME "Transmiter DC FIFO depth"
set_parameter_property ASYNC_TX_FIFO_DEPTH DISPLAY_UNITS "x8 bytes"
set_parameter_property ASYNC_TX_FIFO_DEPTH allowed_ranges {16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072}
set_parameter_property ASYNC_TX_FIFO_DEPTH DESCRIPTION "FIFO depth"
add_display_item "DC FIFO Configuration" "ASYNC_TX_FIFO_DEPTH" parameter

add_parameter ASYNC_RX_FIFO_DEPTH INTEGER 0 
set_parameter_property ASYNC_RX_FIFO_DEPTH DEFAULT_VALUE 16
set_parameter_property ASYNC_RX_FIFO_DEPTH DISPLAY_NAME "Receiver DC FIFO depth"
set_parameter_property ASYNC_RX_FIFO_DEPTH DISPLAY_UNITS "x8 bytes"
set_parameter_property ASYNC_RX_FIFO_DEPTH allowed_ranges {16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072}
set_parameter_property ASYNC_RX_FIFO_DEPTH DESCRIPTION "FIFO depth"
add_display_item "DC FIFO Configuration" "ASYNC_RX_FIFO_DEPTH" parameter



# |
# +-----------------------------------


sopc::preview_add_transform "foo" "PREVIEW_AVALON_MM_TRANSFORM"

proc validate {} {
    set configuration [get_parameter_value CONFIGURATION]     
    if {$configuration == "0"} {
    set_parameter_property ASYNC_RX_FIFO_DEPTH ENABLED FALSE
    set_parameter_property ASYNC_TX_FIFO_DEPTH ENABLED FALSE
    } else {
    set_parameter_property ASYNC_RX_FIFO_DEPTH ENABLED TRUE
    set_parameter_property ASYNC_TX_FIFO_DEPTH ENABLED TRUE
    }
    if {[_is_phy_ip]} {
    set_parameter_property STARTING_CHANNEL_NUMBER ENABLED FALSE
	} else {
    set_parameter_property STARTING_CHANNEL_NUMBER ENABLED TRUE
	}
}

proc compose {} {
    # Get parameter values
    set starting_channel_number [get_parameter_value STARTING_CHANNEL_NUMBER]       
    set async_tx_fifo_depth [get_parameter_value ASYNC_TX_FIFO_DEPTH] 
    set async_rx_fifo_depth [get_parameter_value ASYNC_RX_FIFO_DEPTH] 
    set configuration [get_parameter_value CONFIGURATION]     
     
    
    if {$configuration == "0"} {
    
    add_instance eth_2_5G_phy altera_eth_2_5g_pcs_pma_16b
    set_instance_parameter eth_2_5G_phy STARTING_CHANNEL_NUMBER $starting_channel_number    
    set_instance_parameter eth_2_5G_phy CONFIGURATION $configuration    
    
    add_interface avalon_mm_csr avalon end
    set_interface_property avalon_mm_csr export_of eth_2_5G_phy.avalon_mm_csr
    set_interface_property avalon_mm_csr  PORT_NAME_MAP    {readdata readdata waitrequest waitrequest address address read read writedata writedata write write} 
	
    add_interface gmii_tx_data avalon_streaming end
    set_interface_property gmii_tx_data export_of eth_2_5G_phy.gmii_tx_data
    set_interface_property gmii_tx_data  PORT_NAME_MAP    {gmii_tx_d gmii_tx_d gmii_tx_err gmii_tx_err} 
	
    add_interface gmii_tx_enable avalon_streaming end
    set_interface_property gmii_tx_enable export_of eth_2_5G_phy.gmii_tx_enable
    set_interface_property gmii_tx_enable  PORT_NAME_MAP    {gmii_tx_en gmii_tx_en} 	
    
    add_interface tx_clk_reset reset end
    set_interface_property tx_clk_reset export_of eth_2_5G_phy.tx_clk_reset 
    set_interface_property tx_clk_reset  PORT_NAME_MAP   {reset_tx_clk reset_tx_clk}	
    
    add_interface rx_clk_reset reset end
    set_interface_property rx_clk_reset export_of eth_2_5G_phy.rx_clk_reset    
    set_interface_property rx_clk_reset  PORT_NAME_MAP   {reset_rx_clk reset_rx_clk}	
    
    add_interface clk clock end
    set_interface_property clk export_of eth_2_5G_phy.clk 
    set_interface_property clk  PORT_NAME_MAP   {clk clk}	

    add_interface clk_reset reset end
    set_interface_property clk_reset export_of eth_2_5G_phy.clk_reset
    set_interface_property clk_reset  PORT_NAME_MAP   {reset reset}	
    
    add_interface led_link conduit end
    set_interface_property led_link export_of eth_2_5G_phy.led_link
    set_interface_property led_link  PORT_NAME_MAP   {led_link led_link}	
    
    add_interface led_char_err conduit end
    set_interface_property led_char_err export_of eth_2_5G_phy.led_char_err
    set_interface_property led_char_err  PORT_NAME_MAP   {led_char_err led_char_err}	
    
    add_interface led_disp_err conduit end
    set_interface_property led_disp_err export_of eth_2_5G_phy.led_disp_err          
    set_interface_property led_disp_err  PORT_NAME_MAP   {led_disp_err led_disp_err}	

    add_interface led_an conduit end
    set_interface_property led_an export_of eth_2_5G_phy.led_an  
    set_interface_property led_an  PORT_NAME_MAP   {led_an led_an}	

    add_interface txp conduit end
    set_interface_property txp export_of eth_2_5G_phy.txp
    set_interface_property txp  PORT_NAME_MAP   {txp txp}
        
    add_interface rxp conduit end
    set_interface_property rxp export_of eth_2_5G_phy.rxp
    set_interface_property rxp  PORT_NAME_MAP   {rxp rxp}

    add_interface tx_pll_locked conduit end
    set_interface_property tx_pll_locked export_of eth_2_5G_phy.tx_pll_locked  
    set_interface_property tx_pll_locked  PORT_NAME_MAP   {tx_pll_locked tx_pll_locked}		

    add_interface reconfig_togxb conduit end
    set_interface_property reconfig_togxb export_of eth_2_5G_phy.reconfig_togxb
    set_interface_property reconfig_togxb  PORT_NAME_MAP   {reconfig_togxb reconfig_togxb}
 
    add_interface reconfig_fromgxb conduit end
    set_interface_property reconfig_fromgxb export_of eth_2_5G_phy.reconfig_fromgxb
    set_interface_property reconfig_fromgxb  PORT_NAME_MAP   {reconfig_fromgxb reconfig_fromgxb}

    add_interface ref_clk clock end
    set_interface_property ref_clk export_of eth_2_5G_phy.ref_clk
    set_interface_property ref_clk  PORT_NAME_MAP   {ref_clk ref_clk}	
	
    if {![_is_phy_ip]} {
        add_interface reconfig_busy conduit end
        set_interface_property reconfig_busy export_of eth_2_5G_phy.reconfig_busy
        set_interface_property reconfig_busy  PORT_NAME_MAP   {reconfig_busy reconfig_busy}
        
        add_interface reconfig_clk conduit end
        set_interface_property reconfig_clk export_of eth_2_5G_phy.reconfig_clk
        set_interface_property reconfig_clk  PORT_NAME_MAP   {reconfig_clk reconfig_clk}

    	add_interface gxb_cal_blk_clk conduit end
    	set_interface_property gxb_cal_blk_clk export_of eth_2_5G_phy.gxb_cal_blk_clk
    	set_interface_property gxb_cal_blk_clk  PORT_NAME_MAP   {gxb_cal_blk_clk gxb_cal_blk_clk}	

    	add_interface pll_powerdown conduit end
    	set_interface_property pll_powerdown export_of eth_2_5G_phy.pll_powerdown
    	set_interface_property pll_powerdown  PORT_NAME_MAP   {pll_powerdown pll_powerdown}	

    	add_interface gxb_pwrdn_in conduit end
    	set_interface_property gxb_pwrdn_in export_of eth_2_5G_phy.gxb_pwrdn_in
    	set_interface_property gxb_pwrdn_in  PORT_NAME_MAP   {gxb_pwrdn_in gxb_pwrdn_in}			
    }
    if {[_is_phy_ip] != "3" 
    && [_is_phy_ip] != "4" } {    
        # rx_recovered_clk not supported for Cyclone V & Arria V
        add_interface rx_recovered_clk conduit start
        set_interface_property rx_recovered_clk export_of eth_2_5G_phy.rx_recovered_clk
        set_interface_property rx_recovered_clk  PORT_NAME_MAP    {rx_recovered_clk rx_recovered_clk}
    }

    add_interface gmii_rx_data avalon_streaming start
    set_interface_property gmii_rx_data export_of eth_2_5G_phy.gmii_rx_data
    set_interface_property gmii_rx_data  PORT_NAME_MAP   {gmii_rx_d gmii_rx_d gmii_rx_err gmii_rx_err}	
    
    add_interface gmii_rx_enable avalon_streaming start
    set_interface_property gmii_rx_enable export_of eth_2_5G_phy.gmii_rx_enable
    set_interface_property gmii_rx_enable  PORT_NAME_MAP   {gmii_rx_dv gmii_rx_dv}	

    add_interface tx_clk clock start
    set_interface_property tx_clk export_of eth_2_5G_phy.tx_clk    
    set_interface_property tx_clk  PORT_NAME_MAP   {tx_clk tx_clk}	

    add_interface rx_clk clock start
    set_interface_property rx_clk export_of eth_2_5G_phy.rx_clk        
    set_interface_property rx_clk  PORT_NAME_MAP   {rx_clk rx_clk}	
    } else {
    
    #  CLK 122 Clock Source 
    add_instance clk_122_module altera_clock_bridge
    set_instance_parameter clk_122_module EXPLICIT_CLOCK_RATE "122000000"
    add_interface          clk_122_module                      clock           end
    set_interface_property clk_122_module                      EXPORT_OF       clk_122_module.in_clk
    set_interface_property clk_122_module                      PORT_NAME_MAP   {clk_122 in_clk}
        
    #  CLK 39 Clock Source 
    add_instance clk_39_module altera_clock_bridge
    set_instance_parameter clk_39_module EXPLICIT_CLOCK_RATE "39062500"
    add_interface          clk_39_module                      clock           end
    set_interface_property clk_39_module                      EXPORT_OF       clk_39_module.in_clk
    set_interface_property clk_39_module                      PORT_NAME_MAP   {clk_39 in_clk}

	#  Clock Bridge for eth_2_5g_phy_tx_clk_out
	add_instance tx_clk_out_bridge altera_clock_bridge


    # Reset Bridge
    add_instance reset_n_module altera_reset_bridge
    set_instance_parameter reset_n_module SYNCHRONOUS_EDGES "none"
    set_instance_parameter reset_n_module ACTIVE_LOW_RESET "1"
    set_instance_parameter reset_n_module NUM_RESET_OUTPUTS "1"
  
    add_interface reset_n reset end
    set_interface_property reset_n export_of reset_n_module.in_reset    
    set_interface_property reset_n  PORT_NAME_MAP    {reset_n in_reset_n}
    
    #  reset_n Clock Source 
    #add_instance reset_n_module clock_source  
    #set_instance_parameter reset_n_module clockFrequencyKnown "false"
    #set_instance_parameter reset_n_module resetSynchronousEdges "Deassert"
    #add_interface clk_rst clock end
    #set_interface_property clk_rst export_of reset_n_module.clk_in
    #add_interface reset_n reset end
    #set_interface_property reset_n export_of reset_n_module.clk_in_reset    
    
    # 2.5GMAC Instance
    add_instance eth_2_5gmac altera_eth_2_5g_mac
    
    # 2.5GPHY Instance
    add_instance eth_2_5G_phy altera_eth_2_5g_pcs_pma_16b
    set_instance_parameter eth_2_5G_phy STARTING_CHANNEL_NUMBER $starting_channel_number
    set_instance_parameter eth_2_5G_phy CONFIGURATION $configuration    
    
    # Transmit(TX) Dual Clock Fifo Instance
    add_instance tx_dc_fifo altera_avalon_dc_fifo
    set_instance_parameter tx_dc_fifo SYMBOLS_PER_BEAT "8"
    set_instance_parameter tx_dc_fifo BITS_PER_SYMBOL "8"
    set_instance_parameter tx_dc_fifo FIFO_DEPTH $async_tx_fifo_depth
    set_instance_parameter tx_dc_fifo CHANNEL_WIDTH "0"
    set_instance_parameter tx_dc_fifo ERROR_WIDTH "1"
    set_instance_parameter tx_dc_fifo USE_PACKETS "1"
    set_instance_parameter tx_dc_fifo USE_IN_FILL_LEVEL "0"
    set_instance_parameter tx_dc_fifo USE_OUT_FILL_LEVEL "0"
    set_instance_parameter tx_dc_fifo WR_SYNC_DEPTH "2"
    set_instance_parameter tx_dc_fifo RD_SYNC_DEPTH "2"
    set_instance_parameter tx_dc_fifo ENABLE_EXPLICIT_MAXCHANNEL "false"
    set_instance_parameter tx_dc_fifo EXPLICIT_MAXCHANNEL "0"
    
    # Receive(RX) Dual Clock Fifo Instance
    add_instance rx_dc_fifo altera_avalon_dc_fifo
    set_instance_parameter rx_dc_fifo SYMBOLS_PER_BEAT "8"
    set_instance_parameter rx_dc_fifo BITS_PER_SYMBOL "8"
    set_instance_parameter rx_dc_fifo FIFO_DEPTH $async_rx_fifo_depth
    set_instance_parameter rx_dc_fifo CHANNEL_WIDTH "0"
    set_instance_parameter rx_dc_fifo ERROR_WIDTH "6"
    set_instance_parameter rx_dc_fifo USE_PACKETS "1"
    set_instance_parameter rx_dc_fifo USE_IN_FILL_LEVEL "0"
    set_instance_parameter rx_dc_fifo USE_OUT_FILL_LEVEL "0"
    set_instance_parameter rx_dc_fifo WR_SYNC_DEPTH "2"
    set_instance_parameter rx_dc_fifo RD_SYNC_DEPTH "2"
    set_instance_parameter rx_dc_fifo ENABLE_EXPLICIT_MAXCHANNEL "false"
    set_instance_parameter rx_dc_fifo EXPLICIT_MAXCHANNEL "0"
    
    # Merlin Master Translator Instance
    #  Merlin Master Translator
    add_instance merlin_master_translator altera_merlin_master_translator 
    set_instance_parameter merlin_master_translator AV_ADDRESS_W "19"
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
    set_instance_parameter merlin_master_translator AV_ADDRESS_SYMBOLS "1"
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
    
    # Terminate Pause Control Request interface
    add_instance pause_req_termination altera_eth_pause_req_termination
    add_connection clk_39_module.out_clk/pause_req_termination.clock_reset
    add_connection reset_n_module.out_reset/pause_req_termination.clock_reset_reset
    add_connection pause_req_termination.pause_control_src/eth_2_5gmac.avalon_st_pause
    
    #AVALON TX (MAC<->FIFO))
    # export tx_dc_fifo.in
    add_interface avalon_st_tx avalon_streaming end
    set_interface_property avalon_st_tx export_of tx_dc_fifo.in
    add_connection tx_dc_fifo.out/eth_2_5gmac.avalon_st_tx

    set_interface_property avalon_st_tx  PORT_NAME_MAP    {avalon_st_tx_eop in_endofpacket avalon_st_tx_sop in_startofpacket} 

    #GMII TX (MAC<->PHY)
    add_connection eth_2_5gmac.gmii_data_tx/eth_2_5G_phy.gmii_tx_data
    add_connection eth_2_5gmac.gmii_enable_tx/eth_2_5G_phy.gmii_tx_enable
    
    #GMII RX (MAC<->PHY)
    add_connection eth_2_5G_phy.gmii_rx_data/eth_2_5gmac.gmii_rx_data
    add_connection eth_2_5G_phy.gmii_rx_enable/eth_2_5gmac.gmii_rx_control
    
    #AVALON RX (MAC<->FIFO))
    add_connection eth_2_5gmac.avalon_st_rx/rx_dc_fifo.in
    # export rx_dc_fifo.out
    add_interface avalon_st_rx avalon_streaming start
    set_interface_property avalon_st_rx export_of rx_dc_fifo.out
    set_interface_property avalon_st_rx  PORT_NAME_MAP    {avalon_st_rx_eop out_endofpacket avalon_st_rx_sop out_startofpacket}

    # AVALON RX STATUS
    add_interface avalon_st_rxstatus avalon_streaming start
    set_interface_property avalon_st_rxstatus export_of eth_2_5gmac.avalon_st_rxstatus
    
    # SERDES CONTROL INTERFACE
    #add_interface gxb_pwrdwn avalon_streaming end
    #set_interface_property gxb_pwrdwn export_of eth_2_5G_phy.gxb_pwrdn_in
    
    #add_interface pll_pwrdwn avalon_streaming end
    #set_interface_property pll_pwrdwn export_of eth_2_5G_phy.pll_powerdown
    
    # MERLIN MASTER (EXPORT avalon_mm_csr)
    add_interface avalon_mm_csr avalon end
    set_interface_property avalon_mm_csr export_of merlin_master_translator.avalon_anti_master_0
    
    # CSR CONNECTION
    add_connection merlin_master_translator.avalon_universal_master_0 eth_2_5gmac.csr
    set_connection_parameter merlin_master_translator.avalon_universal_master_0/eth_2_5gmac.csr baseAddress 0x000
    add_connection merlin_master_translator.avalon_universal_master_0 eth_2_5G_phy.avalon_mm_csr
    set_connection_parameter merlin_master_translator.avalon_universal_master_0/eth_2_5G_phy.avalon_mm_csr baseAddress 0x800
        
    # EXPORT CONDUIT
    if {![_is_phy_ip]} {
        add_interface pll_pwrdwn conduit end
        set_interface_property pll_pwrdwn export_of eth_2_5G_phy.pll_powerdown
        set_interface_property pll_pwrdwn  PORT_NAME_MAP    {pll_pwrdwn pll_powerdown}
        
        add_interface gxb_pwrdwn conduit end
        set_interface_property gxb_pwrdwn export_of eth_2_5G_phy.gxb_pwrdn_in
        set_interface_property gxb_pwrdwn  PORT_NAME_MAP    {gxb_pwrdwn gxb_pwrdn_in}
        
        add_interface gxb_cal_blk_clk conduit end
        set_interface_property gxb_cal_blk_clk export_of eth_2_5G_phy.gxb_cal_blk_clk
        set_interface_property gxb_cal_blk_clk  PORT_NAME_MAP    {gxb_cal_blk_clk gxb_cal_blk_clk}
        
        add_interface reconfig_busy conduit end
        set_interface_property reconfig_busy export_of eth_2_5G_phy.reconfig_busy
        set_interface_property reconfig_busy  PORT_NAME_MAP    {reconfig_busy reconfig_busy}
        
        add_interface reconfig_clk conduit end
        set_interface_property reconfig_clk export_of eth_2_5G_phy.reconfig_clk
        set_interface_property reconfig_clk  PORT_NAME_MAP    {reconfig_clk reconfig_clk}
    } 

    if {[_is_phy_ip] != "3"
    && [_is_phy_ip] != "4" } {    
        # rx_recovered_clk not supported for Cyclone V & Arria V
        add_interface rx_recovered_clk conduit start
        set_interface_property rx_recovered_clk export_of eth_2_5G_phy.rx_recovered_clk
        set_interface_property rx_recovered_clk  PORT_NAME_MAP    {rx_recovered_clk rx_recovered_clk}
    }


    add_interface ref_clk clock end
    set_interface_property ref_clk export_of eth_2_5G_phy.ref_clk
    set_interface_property ref_clk  PORT_NAME_MAP    {ref_clk ref_clk}
    
    add_interface reconfig_togxb conduit end
    set_interface_property reconfig_togxb export_of eth_2_5G_phy.reconfig_togxb
    set_interface_property reconfig_togxb  PORT_NAME_MAP    {reconfig_togxb reconfig_togxb}
    
    add_interface rxp conduit end
    set_interface_property rxp export_of eth_2_5G_phy.rxp
    set_interface_property rxp  PORT_NAME_MAP    {rxp rxp}
    
    add_interface led_link conduit start
    set_interface_property led_link export_of eth_2_5G_phy.led_link
    set_interface_property led_link  PORT_NAME_MAP    {led_link led_link}
    
    add_interface led_char_err conduit start
    set_interface_property led_char_err export_of eth_2_5G_phy.led_char_err
    set_interface_property led_char_err  PORT_NAME_MAP    {led_char_err led_char_err}
    
    add_interface led_disp_err conduit start
    set_interface_property led_disp_err export_of eth_2_5G_phy.led_disp_err
    set_interface_property led_disp_err  PORT_NAME_MAP    {led_disp_err led_disp_err}
    
    add_interface led_an conduit start
    set_interface_property led_an export_of eth_2_5G_phy.led_an
    set_interface_property led_an  PORT_NAME_MAP    {led_an led_an}
    
    add_interface tx_pll_locked conduit start
    set_interface_property tx_pll_locked export_of eth_2_5G_phy.tx_pll_locked
    set_interface_property tx_pll_locked  PORT_NAME_MAP    {eth_2_5g_phy_tx_pll_locked tx_pll_locked}
    
    add_interface reconfig_fromgxb conduit start
    set_interface_property reconfig_fromgxb export_of eth_2_5G_phy.reconfig_fromgxb
    set_interface_property reconfig_fromgxb  PORT_NAME_MAP    {reconfig_fromgxb reconfig_fromgxb}
    
    add_interface txp conduit start
    set_interface_property txp export_of eth_2_5G_phy.txp
    set_interface_property txp  PORT_NAME_MAP    {txp txp}
    
    
    # CLOCK CONNECTION
    # MAC
    add_connection clk_39_module.out_clk/eth_2_5gmac.tx_clk
    add_connection clk_39_module.out_clk/eth_2_5gmac.rx_clk
    add_connection clk_122_module.out_clk/eth_2_5gmac.csr_clk
    add_connection eth_2_5G_phy.tx_clk/eth_2_5gmac.tx_gmii_clk
    add_connection eth_2_5G_phy.rx_clk/eth_2_5gmac.rx_gmii_clk

    add_connection eth_2_5G_phy.tx_clk/tx_clk_out_bridge.in_clk

    # EXPORT TX CLOCK
    add_interface eth_2_5g_phy_tx_clk_out clock start
    set_interface_property eth_2_5g_phy_tx_clk_out export_of tx_clk_out_bridge.out_clk
    set_interface_property eth_2_5g_phy_tx_clk_out  PORT_NAME_MAP    {eth_2_5g_phy_tx_clk_out out_clk}
 
    # PHY
    add_connection clk_122_module.out_clk/eth_2_5G_phy.clk
    #add_connection gxb_cal_blk_clk_module.clk/eth_2_5G_phy.gxb_cal_blk_clk
    
    # DC FIFO
    add_connection clk_122_module.out_clk/tx_dc_fifo.in_clk
    add_connection clk_39_module.out_clk/tx_dc_fifo.out_clk
    add_connection clk_39_module.out_clk/rx_dc_fifo.in_clk
    add_connection clk_122_module.out_clk/rx_dc_fifo.out_clk
    
    # MERLIN MASTER
    add_connection clk_122_module.out_clk/merlin_master_translator.clk
    
    # RESET CONNECTION
    # MAC
    add_connection reset_n_module.out_reset/eth_2_5gmac.tx_reset
    add_connection reset_n_module.out_reset/eth_2_5gmac.rx_reset
    add_connection reset_n_module.out_reset/eth_2_5gmac.rx_gmii_reset
    add_connection reset_n_module.out_reset/eth_2_5gmac.tx_gmii_reset
    add_connection reset_n_module.out_reset/eth_2_5gmac.csr_reset
    
    # ALL CLOCKS
    #add_connection reset_n_module.out_reset/clk_122_module.out_clk_in_reset
    #add_connection reset_n_module.out_reset/clk_39_module.clk_in_reset
    #add_connection reset_n_module.out_reset/ref_clk_module.clk_in_reset
    
    # PHY
    add_connection reset_n_module.out_reset/eth_2_5G_phy.clk_reset
    add_connection reset_n_module.out_reset/eth_2_5G_phy.rx_clk_reset
    add_connection reset_n_module.out_reset/eth_2_5G_phy.tx_clk_reset
    
    # DC FIFO
    add_connection reset_n_module.out_reset/tx_dc_fifo.in_clk_reset
    add_connection reset_n_module.out_reset/tx_dc_fifo.out_clk_reset
    add_connection reset_n_module.out_reset/rx_dc_fifo.in_clk_reset
    add_connection reset_n_module.out_reset/rx_dc_fifo.out_clk_reset
    
    # MERLIN MASTER
    add_connection reset_n_module.out_reset/merlin_master_translator.reset
    } 
}

proc testbench_proc { none } {

    set configuration [get_parameter_value CONFIGURATION]     
    if {$configuration == "0"} {
      if {[_is_phy_ip]} {
        add_fileset_file tb.sv VERILOG PATH tb_phy/tb_phy.sv 
      } else {
        add_fileset_file tb.sv VERILOG PATH tb_phy/tb.sv 
      }
      add_fileset_file avalon_bfm_wrapper.sv SYSTEM_VERILOG PATH tb_phy/avalon_bfm_wrapper.sv 
      add_fileset_file avalon_checker.v VERILOG PATH tb_phy/avalon_checker.v 
      add_fileset_file avalon_driver.sv VERILOG PATH tb_phy/avalon_driver.sv 
      add_fileset_file avalon_gmii_converter.v VERILOG PATH tb_phy/avalon_gmii_converter.v 
      add_fileset_file avalon_if_params_pkg.sv VERILOG PATH tb_phy/avalon_if_params_pkg.sv 
      add_fileset_file avalon_st_eth_packet_monitor.sv VERILOG PATH tb_phy/avalon_st_eth_packet_monitor.sv 
      add_fileset_file clock_divider.v VERILOG PATH tb_phy/clock_divider.v 
      add_fileset_file eth_mac_frame.sv VERILOG PATH tb_phy/eth_mac_frame.sv 
      add_fileset_file eth_register_map_params_pkg.sv VERILOG PATH tb_phy/eth_register_map_params_pkg.sv 
      add_fileset_file gmii_to_avalon_convertor.v VERILOG PATH tb_phy/gmii_to_avalon_convertor.v 
      add_fileset_file altera_tse_gmii_rx_aligner_16b.v VERILOG PATH tb_phy/altera_tse_gmii_rx_aligner_16b.v
      add_fileset_file tb_run.tcl OTHER PATH tb_phy/tb_run.tcl 
      add_fileset_file tb_ncsim_run.sh OTHER PATH tb_phy/tb_ncsim_run.sh
      add_fileset_file tb_vcs_run.sh OTHER PATH tb_phy/tb_vcs_run.sh
    } else {
      if {[_is_phy_ip]} {
        add_fileset_file tb.sv VERILOG PATH tb_system/tb_phy.sv
      } else {
        add_fileset_file tb.sv VERILOG PATH tb_system/tb.sv
      }			
      add_fileset_file avalon_bfm_wrapper.sv VERILOG PATH tb_system/avalon_bfm_wrapper.sv
      add_fileset_file avalon_driver.sv VERILOG PATH tb_system/avalon_driver.sv
      add_fileset_file avalon_if_params_pkg.sv VERILOG PATH tb_system/avalon_if_params_pkg.sv
      add_fileset_file avalon_st_eth_packet_monitor.sv VERILOG PATH tb_system/avalon_st_eth_packet_monitor.sv
      add_fileset_file eth_mac_frame.sv VERILOG PATH tb_system/eth_mac_frame.sv
      add_fileset_file eth_register_map_params_pkg.sv VERILOG PATH tb_system/eth_register_map_params_pkg.sv
      add_fileset_file tb_run.tcl OTHER PATH tb_system/tb_run.tcl
      add_fileset_file tb_ncsim_run.sh OTHER PATH tb_system/tb_ncsim_run.sh
      add_fileset_file tb_vcs_run.sh OTHER PATH tb_system/tb_vcs_run.sh
    }
}

#proc _get_device_type {} {
#    set device_family [get_parameter_value DEVICE_FAMILY]
#    
#    if {![string compare $device_family "Cyclone IV GX"]} {
#        return 1;
#    } elseif {![string compare $device_family "Arria GX"]} {
#        return 1;
#    } else {
#        return 0;
#    }
#}

proc _is_phy_ip {} {
    set device_family [get_parameter_value DEVICE_FAMILY]
    
    if {![string compare $device_family "Stratix V"]} {
        return 1;
    } elseif {![string compare $device_family "Arria V GZ"]} {
        return 2;
    } elseif {![string compare $device_family "Arria V"]} {
        return 3;
    } elseif {![string compare $device_family "Cyclone V"]} {
        return 4;
    } else {
        return 0;
    }
}
