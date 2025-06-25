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


# altera_eth_interface_conversion module
set_module_property DESCRIPTION "Ethernet XGMII Interface Conversion"
set_module_property NAME altera_eth_interface_conversion
set_module_property VERSION 13.1
set_module_property INTERNAL true
set_module_property GROUP "Interface Protocols/Ethernet/Submodules"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "Ethernet XGMII Interface Conversion"
set_module_property EDITABLE true
set_module_property ANALYZE_HDL false
set_module_property ELABORATION_CALLBACK elaborate

add_parameter DATAPATH_OPTION INTEGER 3
set_parameter_property DATAPATH_OPTION DISPLAY_NAME "Datapath Option"
set_parameter_property DATAPATH_OPTION allowed_ranges {"1:TX Only" "2:RX Only" "3:TX & RX"}
set_parameter_property DATAPATH_OPTION DESCRIPTION "Datapath Option"

proc elaborate {} {
    set datapath_option [get_parameter_value DATAPATH_OPTION]
    
    # TX
    if { [expr ($datapath_option & 0x1)] } {
        # Clock & Reset
        add_interface clock_reset_tx clock end
        set_interface_property clock_reset_tx ENABLED true

        add_interface_port clock_reset_tx clk clk Input 1
        add_interface_port clock_reset_tx reset reset Input 1
        
        # Sink
        add_interface xgmii_tx_bridge_sink avalon_streaming end
        set_interface_property xgmii_tx_bridge_sink dataBitsPerSymbol 9
        set_interface_property xgmii_tx_bridge_sink errorDescriptor ""
        set_interface_property xgmii_tx_bridge_sink maxChannel 0
        set_interface_property xgmii_tx_bridge_sink readyLatency 0
        set_interface_property xgmii_tx_bridge_sink symbolsPerBeat 8
        
        set_interface_property xgmii_tx_bridge_sink ASSOCIATED_CLOCK clock_reset_tx
        set_interface_property xgmii_tx_bridge_sink ENABLED true
        
        add_interface_port xgmii_tx_bridge_sink xgmii_tx_data_sink data Input 72
        
        # Source
        add_interface xgmii_tx_bridge_src avalon_streaming start
        set_interface_property xgmii_tx_bridge_src dataBitsPerSymbol 72
        set_interface_property xgmii_tx_bridge_src errorDescriptor ""
        set_interface_property xgmii_tx_bridge_src maxChannel 0
        set_interface_property xgmii_tx_bridge_src readyLatency 0
        set_interface_property xgmii_tx_bridge_src symbolsPerBeat 1
        
        set_interface_property xgmii_tx_bridge_src ASSOCIATED_CLOCK clock_reset_tx
        set_interface_property xgmii_tx_bridge_src ENABLED true
        
        add_interface_port xgmii_tx_bridge_src xgmii_tx_data_src data Output 72
        
        # Connection
        set_port_property xgmii_tx_data_src DRIVEN_BY xgmii_tx_data_sink
    }
    
    # RX
    if { [expr ($datapath_option & 0x2)] } {
        # Clock & Reset
        add_interface clock_reset_rx clock end
        set_interface_property clock_reset_rx ENABLED true

        add_interface_port clock_reset_rx clk_out clk Input 1
        add_interface_port clock_reset_rx reset_out reset Input 1
        
        # Sink
        add_interface xgmii_rx_bridge_sink avalon_streaming end
        set_interface_property xgmii_rx_bridge_sink dataBitsPerSymbol 72
        set_interface_property xgmii_rx_bridge_sink errorDescriptor ""
        set_interface_property xgmii_rx_bridge_sink maxChannel 0
        set_interface_property xgmii_rx_bridge_sink readyLatency 0
        set_interface_property xgmii_rx_bridge_sink symbolsPerBeat 1
        
        set_interface_property xgmii_rx_bridge_sink ASSOCIATED_CLOCK clock_reset_rx
        set_interface_property xgmii_rx_bridge_sink ENABLED true
        
        add_interface_port xgmii_rx_bridge_sink xgmii_rx_data_sink data Input 72
        
        # Source
        add_interface xgmii_rx_bridge_src avalon_streaming start
        set_interface_property xgmii_rx_bridge_src dataBitsPerSymbol 9
        set_interface_property xgmii_rx_bridge_src errorDescriptor ""
        set_interface_property xgmii_rx_bridge_src maxChannel 0
        set_interface_property xgmii_rx_bridge_src readyLatency 0
        set_interface_property xgmii_rx_bridge_src symbolsPerBeat 8
        
        set_interface_property xgmii_rx_bridge_src ASSOCIATED_CLOCK clock_reset_rx
        set_interface_property xgmii_rx_bridge_src ENABLED true
        
        add_interface_port xgmii_rx_bridge_src xgmii_rx_data_src data Output 72
        
        # Connection
        set_port_property xgmii_rx_data_src DRIVEN_BY xgmii_rx_data_sink
    }
    
}
