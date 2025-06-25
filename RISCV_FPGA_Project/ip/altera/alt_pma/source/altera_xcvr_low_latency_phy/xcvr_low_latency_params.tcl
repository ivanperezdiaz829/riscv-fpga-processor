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


# +---------------------------------------------------------------------------
# | Low Latency parameter declarations
# | $Header: //acds/rel/13.1/ip/alt_pma/source/altera_xcvr_low_latency_phy/xcvr_low_latency_params.tcl#1 $
# +---------------------------------------------------------------------------

# +---------------------------------------------------------------------------
# | Parameters that appear in levels with a management interface
# | 
proc low_latency_add_mgmt_parameters {} {
    global additional_options
    
    add_parameter mgmt_clk_in_mhz INTEGER
    set_parameter_property mgmt_clk_in_mhz DERIVED true
    set_parameter_property mgmt_clk_in_mhz DEFAULT_VALUE 150
    set_parameter_property mgmt_clk_in_mhz VISIBLE false
    set_parameter_property mgmt_clk_in_mhz HDL_PARAMETER true
    
    add_parameter gui_mgmt_clk_in_hz LONG 150000000
    set_parameter_property gui_mgmt_clk_in_hz SYSTEM_INFO {CLOCK_RATE mgmt_clk}
    set_parameter_property gui_mgmt_clk_in_hz VISIBLE false
    set_parameter_property gui_mgmt_clk_in_hz HDL_PARAMETER false
    
#    set DESCRIPTION "Forces the internal reset controller to perform no reset on the receiver"
#    add_string_parameter_as_boolean manual_reset "false" {NoTag} "Force manual reset control" $DESCRIPTION $additional_options
#     add_parameter gui_manual_reset STRING "DEPRECATED"
#     set_parameter_property gui_manual_reset DEFAULT_VALUE "DEPRECATED"
#     set_parameter_property gui_manual_reset VISIBLE false
#     set_parameter_property gui_manual_reset HDL_PARAMETER false
#     set_parameter_property gui_manual_reset DERIVED false
#     set_parameter_property gui_manual_reset DESCRIPTION "This parameter has been deprecated."


#     add_parameter manual_reset STRING "DEPRECATED"
#     set_parameter_property manual_reset DEFAULT_VALUE "DEPRECATED"
#     set_parameter_property manual_reset VISIBLE false
#     set_parameter_property manual_reset HDL_PARAMETER false
#     set_parameter_property manual_reset DERIVED true
#     set_parameter_property manual_reset DESCRIPTION "This parameter has been deprecated."

 
    # UI parameter for enabling / disabling embedded reset controller
    set DESCRIPTION "Enables the embedded reset controller. When disabled, the reset control ports (pll_powerdown, tx_digitalreset, rx_analogreset, and rx_digitalreset) will be exposed \
                    for manual control."
    add_parameter gui_embedded_reset INTEGER 1
    set_parameter_property gui_embedded_reset DEFAULT_VALUE 1
    set_parameter_property gui_embedded_reset VISIBLE true
    set_parameter_property gui_embedded_reset HDL_PARAMETER false
    set_parameter_property gui_embedded_reset DESCRIPTION $DESCRIPTION
    set_parameter_property gui_embedded_reset DISPLAY_NAME "Enabled embedded reset controller"
    set_parameter_property gui_embedded_reset DISPLAY_HINT BOOLEAN
    add_display_item "Options" gui_embedded_reset parameter
    
    # Derived HDL parameter for enabling / disabling embedded reset controller
    add_parameter embedded_reset INTEGER 1
    set_parameter_property embedded_reset DEFAULT_VALUE 1
    set_parameter_property embedded_reset VISIBLE false
    set_parameter_property embedded_reset HDL_PARAMETER true
    set_parameter_property embedded_reset DERIVED true
    add_display_item "Additional Options" embedded_reset parameter

   
    # data streams and recovered clock buses can be split into multiple interfaces
    # or left as a wide bus for direct-HDL use
    add_parameter gui_split_interfaces INTEGER
    set_parameter_property gui_split_interfaces DEFAULT_VALUE 0
	  set_parameter_property gui_split_interfaces DISPLAY_NAME "Enable avalon data interfaces and bit reversal"
    set_parameter_property gui_split_interfaces VISIBLE true	;# normally disabled?
    set_parameter_property gui_split_interfaces DISPLAY_HINT "boolean"
    set_parameter_property gui_split_interfaces HDL_PARAMETER false
	  set_parameter_property gui_split_interfaces DESCRIPTION "When enabled, the parallel data interfaces to the PHY will be split by channel and will be created as Avalon-ST interfaces as opposed to conduit interfaces. This option also causes the bits within each parallel interface to be presented in reverse order."
    add_display_item $additional_options gui_split_interfaces parameter
    
    # with split interfaces, allow user to split word into multiple symbols
    add_parameter gui_avalon_symbol_size INTEGER
    set_parameter_property gui_avalon_symbol_size DEFAULT_VALUE 0
    set_parameter_property gui_avalon_symbol_size DISPLAY_NAME {Avalon data symbol size}
    set_parameter_property gui_avalon_symbol_size VISIBLE false	;# normally disabled?
    set_parameter_property gui_avalon_symbol_size ALLOWED_RANGES {"0:All bits" 8 10 16 20}
    set_parameter_property gui_avalon_symbol_size HDL_PARAMETER false
    add_display_item $additional_options gui_avalon_symbol_size parameter
   
}

proc low_latency_add_device_parameters {} {
    global general
    
    #adding device_family from SYSTEM INFO
    add_parameter device_family STRING 
    set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
    set_parameter_property device_family DISPLAY_NAME "Device family"
    set_parameter_property device_family ENABLED false
    set_parameter_property device_family HDL_PARAMETER true
    set_parameter_property device_family DESCRIPTION "Specifies which Altera FPGAs the Low Latency PHY supports."
    add_display_item $general device_family parameter
    set fams [::alt_xcvr::utils::device::list_s4_style_hssi_families]
    set fams [concat $fams [::alt_xcvr::utils::device::list_s5_style_hssi_families] ]
    send_message info "set_parameter_property device_family ALLOWED_RANGES $fams"
    
    add_parameter intended_device_variant string ANY
    set_parameter_property intended_device_variant DEFAULT_VALUE ANY
    set_parameter_property intended_device_variant ALLOWED_RANGES {ANY GT}
    set_parameter_property intended_device_variant HDL_PARAMETER true
    set_parameter_property intended_device_variant DISPLAY_NAME "Intended device variant"
    #set_parameter_property intended_device_variant DESCRIPTION "Specifies which intended device variant the Low Latency PHY supports."
    add_display_item $general intended_device_variant parameter
}

proc low_latency_add_datapath_parameters {} {
    global general
    global additional_options
    global datapath
    
    add_parameter gui_data_path_type STRING "PARAM_MAPPED"
    set_parameter_property gui_data_path_type DEFAULT_VALUE "PARAM_MAPPED"
    set_parameter_property gui_data_path_type DISPLAY_NAME "Data path type"
    set_parameter_property gui_data_path_type HDL_PARAMETER false
    set_parameter_property gui_data_path_type DESCRIPTION "Specifies data path type as Standard, 10G, or GT mode."
    add_display_item $general gui_data_path_type parameter
    
    add_parameter data_path_type STRING 8G
    set_parameter_property data_path_type DEFAULT_VALUE 8G
    set_parameter_property data_path_type VISIBLE false
    set_parameter_property data_path_type DERIVED true
    set_parameter_property data_path_type DESCRIPTION "Specifies data path type as Standard, 10G, or GT mode."
    set_parameter_property data_path_type HDL_PARAMETER true
    
    add_parameter operation_mode STRING DUPLEX
    set_parameter_property operation_mode DEFAULT_VALUE DUPLEX
    set_parameter_property operation_mode DISPLAY_NAME "Mode of operation"
    set_parameter_property operation_mode ALLOWED_RANGES {"DUPLEX:Duplex" "RX:RX" "TX:TX"}
    set_parameter_property operation_mode HDL_PARAMETER true
    set_parameter_property operation_mode DESCRIPTION "Specifies mode of operation as RX, TX or Duplex mode."
    add_display_item $general operation_mode parameter
    
    add_parameter lanes INTEGER 1
    set_parameter_property lanes DEFAULT_VALUE 1
    set_parameter_property lanes DISPLAY_NAME "Number of lanes"
    set_parameter_property lanes HDL_PARAMETER true
    set_parameter_property lanes DESCRIPTION "Specifies the total number of lanes in each direction."
    add_display_item $general lanes parameter
    
    add_parameter gui_bonding_enable integer 0
    set_parameter_property gui_bonding_enable DEFAULT_VALUE 0
    set_parameter_property gui_bonding_enable DISPLAY_NAME "Enable lane bonding"
    set_parameter_property gui_bonding_enable DISPLAY_HINT "Boolean"
    set_parameter_property gui_bonding_enable HDL_PARAMETER false
    set_parameter_property gui_bonding_enable VISIBLE true
    set_parameter_property gui_bonding_enable ENABLED true
    set_parameter_property gui_bonding_enable DESCRIPTION "When enabled, the PMA uses bonded clocks. This option is only available for the 8-Gbps datapath."
    add_display_item $general gui_bonding_enable parameter

    add_parameter gui_bonded_mode STRING "xN"
    set_parameter_property gui_bonded_mode DEFAULT_VALUE "xN"
    set_parameter_property gui_bonded_mode ALLOWED_RANGES {"xN" "fb_compensation"}
    set_parameter_property gui_bonded_mode VISIBLE true
    set_parameter_property gui_bonded_mode DERIVED false
    set_parameter_property gui_bonded_mode HDL_PARAMETER false
    set_parameter_property gui_bonded_mode DISPLAY_NAME "Bonding mode"
    add_display_item $general gui_bonded_mode parameter
    
    # Legal values for bonded_mode are (true,false) for SIV, (xN,fb_compensation) for SV.
    add_parameter bonded_mode STRING FALSE
    set_parameter_property bonded_mode VISIBLE false
#    set_parameter_property bonded_mode DISPLAY_NAME "Bonded mode"
#    set_parameter_property bonded_mode DISPLAY_NAME "Enable lane bonding"
#    set_parameter_property bonded_mode DISPLAY_HINT "Boolean"
    set_parameter_property bonded_mode DERIVED true
    set_parameter_property bonded_mode HDL_PARAMETER true
    add_display_item $general bonded_mode parameter
    
    add_parameter gui_serialization_factor STRING "PARAM_MAPPED"
    set_parameter_property gui_serialization_factor DEFAULT_VALUE "PARAM_MAPPED"
    set_parameter_property gui_serialization_factor DISPLAY_NAME "FPGA fabric transceiver interface width"
    set_parameter_property gui_serialization_factor HDL_PARAMETER false
    set_parameter_property gui_serialization_factor VISIBLE true
    set_parameter_property gui_serialization_factor DESCRIPTION "This option indicates the parallel data interface width. The maximum width is 40 bits for Stratix IV devices and 66 bits for Stratix V or Arria V GZ devices."
    add_display_item $general gui_serialization_factor parameter
    
    add_parameter serialization_factor INTEGER 0
    set_parameter_property serialization_factor DEFAULT_VALUE 0
    set_parameter_property serialization_factor DISPLAY_NAME "FPGA fabric transceiver interface width"
    set_parameter_property serialization_factor HDL_PARAMETER true
    set_parameter_property serialization_factor VISIBLE false
    set_parameter_property serialization_factor DERIVED true
    set_parameter_property serialization_factor DESCRIPTION "This option indicates the parallel data interface width. The maximum width is 40 bits for Stratix IV devices and 66 bits for Stratix V or Arria V GZ devices."
    add_display_item $general serialization_factor parameter
    
    add_parameter pma_width INTEGER 8
    set_parameter_property pma_width DEFAULT_VALUE 8
    set_parameter_property pma_width DISPLAY_NAME "PCS-PMA interface width"
    set_parameter_property pma_width HDL_PARAMETER true
    set_parameter_property pma_width DERIVED true
    set_parameter_property pma_width VISIBLE false
    set_parameter_property pma_width DESCRIPTION "This option indicates the data width between PMA and PCS interface. This value determines the gearbox ratio. This option only available for 64 bits serialization factor."
    add_display_item $general pma_width parameter
    
    add_parameter gui_pma_width STRING "PARAM_DEFAULT"
    set_parameter_property gui_pma_width DEFAULT_VALUE "PARAM_DEFAULT"
    set_parameter_property gui_pma_width DISPLAY_NAME "PCS-PMA interface width"
    set_parameter_property gui_pma_width HDL_PARAMETER false
    set_parameter_property gui_pma_width VISIBLE true
    set_parameter_property gui_pma_width DESCRIPTION "This option indicates the data width between PMA and PCS interface. This value determines the gearbox ratio. This option only available for 64 bits serialization factor."
    add_display_item $general gui_pma_width parameter
    
     # adding pll type parameter - GUI param is symbolic only
    add_parameter gui_pll_type STRING "CMU"
    set_parameter_property gui_pll_type DEFAULT_VALUE "CMU"
    set_parameter_property gui_pll_type ALLOWED_RANGES {"CMU" "ATX"}
    set_parameter_property gui_pll_type DISPLAY_NAME "PLL type"
    set_parameter_property gui_pll_type UNITS None
    set_parameter_property gui_pll_type ENABLED true
    set_parameter_property gui_pll_type VISIBLE true
    set_parameter_property gui_pll_type DISPLAY_HINT ""
    set_parameter_property gui_pll_type HDL_PARAMETER false
    set_parameter_property gui_pll_type DESCRIPTION "Specifies the PLL type"
    add_display_item $general gui_pll_type parameter
    
    add_parameter data_rate STRING "1250 Mbps"
    set_parameter_property data_rate DEFAULT_VALUE "1250 Mbps"
    set_parameter_property data_rate DISPLAY_NAME "Data rate"
    set_parameter_property data_rate HDL_PARAMETER true
    set_parameter_property data_rate DESCRIPTION "Specifies the data rate in Mbps. If you choose Bonded mode on the Additional Options tab, the maximum data rate is 8000 Mbps."
    add_display_item $general data_rate parameter
    
    add_parameter gui_base_data_rate STRING "1250 Mbps"
    set_parameter_property gui_base_data_rate DEFAULT_VALUE "1250 Mbps"
    set_parameter_property gui_base_data_rate DISPLAY_NAME "Base data rate"
    set_parameter_property gui_base_data_rate HDL_PARAMETER false
    #set_parameter_property gui_base_data_rate ALLOWED_RANGES {"1250 Mbps"}
    set_parameter_property gui_base_data_rate DESCRIPTION "Specifies the base data rate for the TX PLL. Channels that require TX PLL merging must share the same base data rate."
    add_display_item $general gui_base_data_rate parameter
    
    add_parameter base_data_rate STRING "1250 Mbps"
    set_parameter_property base_data_rate DEFAULT_VALUE "1250 Mbps"
    set_parameter_property base_data_rate HDL_PARAMETER true
    set_parameter_property base_data_rate DERIVED true
    set_parameter_property base_data_rate VISIBLE false
    
    # adding pll input clock aka pll_refclk_freq parameter - GUI param is symbolic only
    add_parameter gui_pll_refclk_freq STRING "62.5 MHz"
    set_parameter_property gui_pll_refclk_freq DEFAULT_VALUE "62.5 MHz"
    set_parameter_property gui_pll_refclk_freq DISPLAY_NAME "Input clock frequency"
    set_parameter_property gui_pll_refclk_freq UNITS None
    set_parameter_property gui_pll_refclk_freq DISPLAY_HINT "include frequency or period unit"
    set_parameter_property gui_pll_refclk_freq HDL_PARAMETER false
    set_parameter_property gui_pll_refclk_freq DESCRIPTION "TX PLL input reference frequency in MHz. The allowed range depends on the data rate that you choose."
    add_display_item $general gui_pll_refclk_freq parameter
    
    # adding word aligner pattern length parameter - HDL param derived from symbolic GUI param
    add_parameter pll_refclk_freq STRING "62.5 MHz"
    set_parameter_property pll_refclk_freq DEFAULT_VALUE "62.5 MHz"
    set_parameter_property pll_refclk_freq VISIBLE false
    set_parameter_property pll_refclk_freq DERIVED true
    set_parameter_property pll_refclk_freq DESCRIPTION "TX PLL input reference frequency in MHz. The allowed range depends on the data rate that you choose."
    set_parameter_property pll_refclk_freq HDL_PARAMETER true
    
    add_parameter bonded_group_size INTEGER 1
    set_parameter_property bonded_group_size DEFAULT_VALUE 1
    set_parameter_property bonded_group_size VISIBLE false
    set_parameter_property bonded_group_size DERIVED true
    set_parameter_property bonded_group_size HDL_PARAMETER true
    add_display_item $general bonded_group_size parameter
    
    add_parameter gui_select_10g_pcs STRING "DEPRECATED"
    set_parameter_property gui_select_10g_pcs DEFAULT_VALUE "DEPRECATED"
    set_parameter_property gui_select_10g_pcs HDL_PARAMETER false
    set_parameter_property gui_select_10g_pcs VISIBLE false
    set_parameter_property gui_select_10g_pcs DERIVED false
    set_parameter_property gui_select_10g_pcs DESCRIPTION "This parameter has been deprecated."
    
    add_parameter select_10g_pcs INTEGER 0
    set_parameter_property select_10g_pcs DEFAULT_VALUE 0
    set_parameter_property select_10g_pcs HDL_PARAMETER true
    set_parameter_property select_10g_pcs VISIBLE false
    set_parameter_property select_10g_pcs DERIVED true
    set_parameter_property select_10g_pcs DESCRIPTION "This parameter has been deprecated."
    #     add_display_item $additional_options select_10g_pcs parameter
    
    add_parameter gui_tx_use_coreclk integer 0
    set_parameter_property gui_tx_use_coreclk DEFAULT_VALUE 0
    set_parameter_property gui_tx_use_coreclk DISPLAY_NAME "Enable tx_coreclkin"
    set_parameter_property gui_tx_use_coreclk DISPLAY_HINT "Boolean"
    set_parameter_property gui_tx_use_coreclk HDL_PARAMETER false
    set_parameter_property gui_tx_use_coreclk DESCRIPTION "When you turn this option on, tx_coreclk connects to the write clock of the TX phase compensation FIFO and you can clock the parallel TX data generated in the FPGA fabric using this port. This port allows you to clock the write side of the TX phase compensation FIFO with a user-provided clock, either the FPGA fabric clock, the FPGA fabric-TX interface clock, or the input reference clock. This option must be turned on if the serialization factor is not 40 in Stratix V or Arria V GZ devices when 10-Gbps datapath is used."
    add_display_item $additional_options gui_tx_use_coreclk parameter
    
    add_parameter tx_use_coreclk integer 0
    set_parameter_property tx_use_coreclk DEFAULT_VALUE 0
    set_parameter_property tx_use_coreclk DISPLAY_NAME "Enable tx_coreclkin"
    set_parameter_property tx_use_coreclk DISPLAY_HINT "Boolean"
    set_parameter_property tx_use_coreclk HDL_PARAMETER true
    set_parameter_property tx_use_coreclk DERIVED true
    set_parameter_property tx_use_coreclk DESCRIPTION "When you turn this option on, tx_coreclk connects to the write clock of the TX phase compensation FIFO and you can clock the parallel TX data generated in the FPGA fabric using this port. This port allows you to clock the write side of the TX phase compensation FIFO with a user-provided clock, either the FPGA fabric clock, the FPGA fabric-TX interface clock, or the input reference clock. This option must be turned on if the serialization factor is not 40 in Stratix V or Arria V GZ devices when 10-Gbps datapath is used."
    add_display_item $additional_options tx_use_coreclk parameter
    
    add_parameter gui_rx_use_coreclk integer 0
    set_parameter_property gui_rx_use_coreclk DEFAULT_VALUE 0
    set_parameter_property gui_rx_use_coreclk DISPLAY_NAME "Enable rx_coreclkin"
    set_parameter_property gui_rx_use_coreclk DISPLAY_HINT "Boolean"
    set_parameter_property gui_rx_use_coreclk HDL_PARAMETER false
    set_parameter_property gui_rx_use_coreclk DESCRIPTION "When you turn this option on, rx_coreclk connects to the read clock of the RX phase compensation FIFO and you can clock the parallel RX output data using rx_coreclk. This port allows you to clock the read side of the RX phase compensation FIFO with a user-provided clock, either the FPGA fabric clock, the FPGA fabric RX interface clock, or the input reference clock."
    add_display_item $additional_options gui_rx_use_coreclk parameter
    
    add_parameter rx_use_coreclk integer 0
    set_parameter_property rx_use_coreclk DEFAULT_VALUE 0
    set_parameter_property rx_use_coreclk DISPLAY_NAME "Enable rx_coreclkin"
    set_parameter_property rx_use_coreclk DISPLAY_HINT "Boolean"
    set_parameter_property rx_use_coreclk HDL_PARAMETER true
    set_parameter_property rx_use_coreclk DERIVED true
    set_parameter_property rx_use_coreclk DESCRIPTION "When you turn this option on, rx_coreclk connects to the read clock of the RX phase compensation FIFO and you can clock the parallel RX output data using rx_coreclk. This port allows you to clock the read side of the RX phase compensation FIFO with a user-provided clock, either the FPGA fabric clock, the FPGA fabric RX interface clock, or the input reference clock."
    add_display_item $additional_options rx_use_coreclk parameter
    
    add_parameter tx_bitslip_enable integer 0	;# 10G path only
    set_parameter_property tx_bitslip_enable DEFAULT_VALUE 0
    set_parameter_property tx_bitslip_enable DISPLAY_NAME "Enable TX bitslip"
    set_parameter_property tx_bitslip_enable DISPLAY_HINT "Boolean"
    set_parameter_property tx_bitslip_enable HDL_PARAMETER true
    set_parameter_property tx_bitslip_enable DESCRIPTION "When set, the word aligner operates in bit-slip mode. This option is available for Stratix V or Arria V GZ devices using the 10-Gbps datapath."
    add_display_item $additional_options tx_bitslip_enable parameter
    
    add_parameter tx_bitslip_width integer 0
    set_parameter_property tx_bitslip_width DEFAULT_VALUE 5
    set_parameter_property tx_bitslip_width DISPLAY_NAME "TX bitslip port width."
    set_parameter_property tx_bitslip_width HDL_PARAMETER true
    set_parameter_property tx_bitslip_width DERIVED true
    set_parameter_property tx_bitslip_width VISIBLE false
    set_parameter_property tx_bitslip_width DESCRIPTION "It will be automatically set to 5 bits for 8-Gbps datapath and 7 bits for 10-Gbps datapath."
    add_display_item $additional_options tx_bitslip_width parameter
    
    add_parameter rx_bitslip_enable integer 0	;# 10G path only
    set_parameter_property rx_bitslip_enable DEFAULT_VALUE 0
    set_parameter_property rx_bitslip_enable DISPLAY_NAME "Enable RX bitslip"
    set_parameter_property rx_bitslip_enable DISPLAY_HINT "Boolean"
    set_parameter_property rx_bitslip_enable HDL_PARAMETER true
    set_parameter_property rx_bitslip_enable VISIBLE true
    set_parameter_property rx_bitslip_enable DESCRIPTION "When set, the word aligner operates in bit-slip mode. This option is available for Stratix V or Arria V GZ devices using the 10-Gbps datapath."
    add_display_item $additional_options rx_bitslip_enable parameter

    # New PPM detector threshold for GT channels
    add_parameter gui_ppm_det_threshold INTEGER ;# GT path only
    set_parameter_property gui_ppm_det_threshold DEFAULT_VALUE 100
    set_parameter_property gui_ppm_det_threshold DISPLAY_NAME "PPM Detector Threshold"
    set_parameter_property gui_ppm_det_threshold VISIBLE true	;# normally disabled?
    set_parameter_property gui_ppm_det_threshold ALLOWED_RANGES {62 100 125 200 250 300 500 1000}
    set_parameter_property gui_ppm_det_threshold HDL_PARAMETER false
    set_parameter_property gui_ppm_det_threshold VISIBLE false
    set_parameter_property gui_ppm_det_threshold DESCRIPTION "Sets the Hard PPM detector threshold for GT channels using auto-CDR mode"
    add_display_item $additional_options gui_ppm_det_threshold parameter
    
    add_parameter ppm_det_threshold STRING ;# GT path only
    set_parameter_property ppm_det_threshold DEFAULT_VALUE 100
    set_parameter_property ppm_det_threshold DISPLAY_NAME "PPM Detector Threshold"
    set_parameter_property ppm_det_threshold VISIBLE true	;# normally disabled?
    set_parameter_property ppm_det_threshold ALLOWED_RANGES {"62" "100" "125" "200" "250" "300" "500" "1000"}
    set_parameter_property ppm_det_threshold HDL_PARAMETER true
    set_parameter_property ppm_det_threshold VISIBLE false
    set_parameter_property ppm_det_threshold DERIVED true
    set_parameter_property ppm_det_threshold DESCRIPTION "Sets the Hard PPM detector threshold for GT channels using auto-CDR mode"
    add_display_item $additional_options ppm_det_threshold parameter

    # New CDR reset gate for GT channels
    add_parameter gui_enable_att_reset_gate INTEGER ;# GT path only
    set_parameter_property gui_enable_att_reset_gate DEFAULT_VALUE 0
    set_parameter_property gui_enable_att_reset_gate DISPLAY_NAME "CDR reset disable control port"
    set_parameter_property gui_enable_att_reset_gate DISPLAY_HINT boolean
    set_parameter_property gui_enable_att_reset_gate HDL_PARAMETER false
    set_parameter_property gui_enable_att_reset_gate VISIBLE false
    set_parameter_property gui_enable_att_reset_gate DESCRIPTION "Enables optional port to gate GT channel CDR reset assertion"
    add_display_item $additional_options gui_enable_att_reset_gate parameter
    
    add_parameter phase_comp_fifo_mode STRING NONE
    set_parameter_property phase_comp_fifo_mode DEFAULT_VALUE NONE
    set_parameter_property phase_comp_fifo_mode ALLOWED_RANGES {"NONE:None" "EMBEDDED:Embedded"}
    set_parameter_property phase_comp_fifo_mode DISPLAY_NAME "Phase compensation FIFO mode"
    set_parameter_property phase_comp_fifo_mode HDL_PARAMETER true
    set_parameter_property phase_comp_fifo_mode DESCRIPTION "When you select Embedded, the PCS includes the phase compensation FIFO and byte serializer, if required, to double the data width. Default value is None. This option is available for Stratix IV devices."
    add_display_item $additional_options phase_comp_fifo_mode parameter
    
    add_parameter loopback_mode STRING SLB
    set_parameter_property loopback_mode DEFAULT_VALUE NONE
    set_parameter_property loopback_mode DISPLAY_NAME "Loopback mode"
    set_parameter_property loopback_mode ALLOWED_RANGES {"NONE:None" "SLB:Serial loopback" "PRECDR_RSLB:Pre-CDR reverse serial loopback" "POSTCDR_RSLB:Post-CDR reverse rerial loopback" }
    set_parameter_property loopback_mode HDL_PARAMETER true
    add_display_item $additional_options loopback_mode parameter
    
    # SW/DW path selection
    set description "The desired width of the data interface between the deserializer and the PCS. 'Single' for an 8 or 10 bits. 'Double' for a 16 or 20 bits."
    add_parameter use_double_data_mode string "DEPRECATED"
    set_parameter_property use_double_data_mode DEFAULT_VALUE "DEPRECATED"
    set_parameter_property use_double_data_mode DERIVED false
    set_parameter_property use_double_data_mode VISIBLE false
    set_parameter_property use_double_data_mode HDL_PARAMETER false
    set_parameter_property use_double_data_mode DESCRIPTION $description
}

proc low_latency_add_reconfig_parameters { group } {
    
    add_parameter starting_channel_number INTEGER 0
    set_parameter_property starting_channel_number DEFAULT_VALUE 0
    set_parameter_property starting_channel_number DISPLAY_NAME "Starting channel number"
    set_parameter_property starting_channel_number UNITS None
    set_parameter_property starting_channel_number ALLOWED_RANGES {0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100}
    set_parameter_property starting_channel_number HDL_PARAMETER true
    set_parameter_property starting_channel_number DESCRIPTION {For Stratix IV devices only.  Must be a multiple of 4.}
    add_display_item $group starting_channel_number parameter
 
    # add pll_refclk_cnt parameter
    add_parameter pll_refclk_cnt INTEGER
    set_parameter_property pll_refclk_cnt VISIBLE false
    set_parameter_property pll_refclk_cnt DEFAULT_VALUE 1
    set_parameter_property pll_refclk_cnt HDL_PARAMETER true
    set_parameter_property pll_refclk_cnt DERIVED true
    set_parameter_property pll_refclk_cnt ENABLED true
    
    # add cdr_refclk_cnt parameter for synce
    add_parameter en_synce_support INTEGER 0
    set_parameter_property en_synce_support VISIBLE false
    set_parameter_property en_synce_support DEFAULT_VALUE 0
    set_parameter_property en_synce_support HDL_PARAMETER true
    set_parameter_property en_synce_support DERIVED false
    set_parameter_property en_synce_support ENABLED true
                         
    # add plls parameter
    add_parameter plls INTEGER
    set_parameter_property plls VISIBLE false
    set_parameter_property plls DEFAULT_VALUE 1
    set_parameter_property plls HDL_PARAMETER true
    set_parameter_property plls ENABLED true
    set_parameter_property plls DERIVED true
    
    # add pll_refclk_select parameter
    add_parameter pll_refclk_select STRING "0"
    set_parameter_property pll_refclk_select DEFAULT_VALUE "0"
    set_parameter_property pll_refclk_select VISIBLE false
    set_parameter_property pll_refclk_select DERIVED true
    set_parameter_property pll_refclk_select HDL_PARAMETER true
    
    # add cdr_refclk_select parameter
    add_parameter cdr_refclk_select INTEGER 0
    set_parameter_property cdr_refclk_select DEFAULT_VALUE 0
    set_parameter_property cdr_refclk_select VISIBLE false
    set_parameter_property cdr_refclk_select DERIVED true
    set_parameter_property cdr_refclk_select HDL_PARAMETER true
    
    add_parameter pll_type STRING
    set_parameter_property pll_type VISIBLE false
    set_parameter_property pll_type DEFAULT_VALUE "AUTO"
    set_parameter_property pll_type HDL_PARAMETER true
    set_parameter_property pll_type ENABLED true
    set_parameter_property pll_type DERIVED true
    
    add_parameter pll_select INTEGER
    set_parameter_property pll_select VISIBLE false
    set_parameter_property pll_select DEFAULT_VALUE 0
    set_parameter_property pll_select HDL_PARAMETER true
    set_parameter_property pll_select ENABLED true
    set_parameter_property pll_select DERIVED true
  
    add_parameter pll_reconfig INTEGER
    set_parameter_property pll_reconfig VISIBLE false
    set_parameter_property pll_reconfig DEFAULT_VALUE 0
    set_parameter_property pll_reconfig HDL_PARAMETER true
    set_parameter_property pll_reconfig ENABLED true
    set_parameter_property pll_reconfig DERIVED true
	
	  add_parameter channel_interface INTEGER 0
    set_parameter_property channel_interface DEFAULT_VALUE 0
    set_parameter_property channel_interface DISPLAY_NAME "Enable Channel Interface"
    set_parameter_property channel_interface DISPLAY_HINT boolean
    set_parameter_property channel_interface HDL_PARAMETER true
    set_parameter_property channel_interface DESCRIPTION "Enables channel interface reconfiguration."
    add_display_item "Channel Interface" channel_interface parameter

    add_parameter pll_feedback_path  STRING "no_compensation"
    set_parameter_property pll_feedback_path DEFAULT_VALUE "no_compensation"
    set_parameter_property pll_feedback_path HDL_PARAMETER true
    set_parameter_property pll_feedback_path DESCRIPTION "RESERVED"
    set_parameter_property pll_feedback_path VISIBLE false
    set_parameter_property pll_feedback_path DERIVED true

    add_parameter enable_fpll_clkdiv33 INTEGER 1
    set_parameter_property enable_fpll_clkdiv33 DEFAULT_VALUE 1
    set_parameter_property enable_fpll_clkdiv33 DISPLAY_NAME "Generate /66 TX interface clock using fPLL"
    set_parameter_property enable_fpll_clkdiv33 DISPLAY_HINT boolean
    set_parameter_property enable_fpll_clkdiv33 HDL_PARAMETER true
    set_parameter_property enable_fpll_clkdiv33 VISIBLE false
    set_parameter_property enable_fpll_clkdiv33 DERIVED true
    set_parameter_property enable_fpll_clkdiv33 DESCRIPTION "Insert a PLL to create the Data rate/66 
      clock needed to clock the PLD/PCS interface in 66:40 mode.
      If disabled, the data rate / 40 clock is provided as tx_clkout. You must therefore enable the \
      tx_coreclkin clock input and provide your own /66 clock to clock the interface."
}

proc add_pll_reconfig_parameters {group} {
  set max_plls 4
  set max_refclks 5

  if { [::alt_xcvr::gui::pll_reconfig::initialize $group $max_plls $max_refclks 1] == 0} {
    puts "Error, could not initialize pll_reconfig package"
  }
}
