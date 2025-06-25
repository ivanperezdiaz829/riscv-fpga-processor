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
# | Low Latency port declarations
# | $Header: //acds/rel/13.1/ip/alt_pma/source/altera_xcvr_low_latency_phy/xcvr_low_latency_ports.tcl#1 $
# +---------------------------------------------------------------------------

# +-----------------------------------
# | Management interface ports
# | 
# | - Needed for layers above native PHY layer
# | 
proc low_latency_mgmt_interface { {addr_width 9} } {

    # +-----------------------------------
    # | connection point phy_mgmt_clk and reset
    # | 
    low_latency_add_clock  phy_mgmt_clk  input
    add_interface phy_mgmt_clk_reset reset end
    add_interface_port phy_mgmt_clk_reset phy_mgmt_clk_reset reset Input 1
    set_interface_property phy_mgmt_clk_reset ASSOCIATED_CLOCK phy_mgmt_clk
    
    # +-----------------------------------
    # | connection point phy_mgmt
    # | 
    add_interface phy_mgmt avalon end
    set_interface_property phy_mgmt addressAlignment DYNAMIC
    set_interface_property phy_mgmt writeWaitTime 0
    set_interface_property phy_mgmt ASSOCIATED_CLOCK phy_mgmt_clk
    set_interface_property phy_mgmt ENABLED true
    
    add_interface_port phy_mgmt phy_mgmt_address address Input $addr_width
    add_interface_port phy_mgmt phy_mgmt_read read Input 1
    add_interface_port phy_mgmt phy_mgmt_readdata readdata Output 32
    add_interface_port phy_mgmt phy_mgmt_waitrequest waitrequest Output 1
    add_interface_port phy_mgmt phy_mgmt_write write Input 1
    add_interface_port phy_mgmt phy_mgmt_writedata writedata Input 32
    
    # +-----------------------------------
    # | soft logic status conduits
    # | 
    low_latency_add_tagged_conduit tx_ready output 1 {TXNoReset}
    low_latency_add_tagged_conduit rx_ready output 1 {RXNoReset}
}


# +---------------------------------------------------------------------------
# | Native ports that can appear as native, or optionally split into
# | separate interfaces for each lane
# | 
# | Since the splitting option is dynamic, this function should only
# | be called from the elaboration callback
proc low_latency_dynamic_native_ports { {split 0} } {

    # get port widths from parameters
    set lanes [get_parameter_value lanes]
    set ser_factor [get_parameter_value serialization_factor]
    set symbol_size [get_avalon_symbol_size]
    set tx_plls [get_parameter_value plls]

    # Set port width base on 8g/10g datapath and channel interface 
	set hdl_data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]
    set op_mode             [get_parameter_value operation_mode]

	
	# Set port width base on 8g/10g datapath and channel interface 
	set hdl_data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]
    
	if { [get_parameter_value channel_interface] == 1 } {
      set total_bits_rx [expr 64 * $lanes]
	  if {$hdl_data_path_type == "10G" } {
	    set total_bits_tx [expr 64 * $lanes]
	  } else {
	    set total_bits_tx [expr 44 * $lanes]
	  }
    } else {
      set total_bits_tx [expr {$ser_factor * $lanes}]
      set total_bits_rx [expr {$ser_factor * $lanes}]
    }
  
    # which associated clocks for TX and RX streams?
    set user_tx_use_coreclk [get_parameter_value gui_tx_use_coreclk]
    set user_rx_use_coreclk [get_parameter_value gui_rx_use_coreclk]
    
    if {$user_tx_use_coreclk == 1} {
    	set tx_clock tx_coreclkin
    } else {
    	set tx_clock tx_clkout
    }
    if {$user_rx_use_coreclk == 1} {
    	set rx_clock rx_coreclkin
    } else {
    	set rx_clock rx_clkout
    }
    
    # Are TX lanes bonded?  If so, must associate to ${tx_clock}0
    set bonded_mode [get_parameter_value gui_bonding_enable ]
    set is_bonded [expr {$bonded_mode == 1} ]
    
    if { $is_bonded } {
        set tx_clkout_width 1
    } else {
        set tx_clkout_width $lanes
    }
    
    # native, splitable clock buses
    low_latency_add_dynamic_conduit_or_clock_bus tx_coreclkin input $lanes {TxCoreclkin} $split
    low_latency_add_dynamic_conduit_or_clock_bus rx_coreclkin input $lanes {RxCoreclkin} $split
    low_latency_add_dynamic_conduit_or_clock_bus tx_clkout output $tx_clkout_width {TxAll} $split
    low_latency_add_dynamic_conduit_or_clock_bus rx_clkout output $lanes {RxAll} $split

    #syncE
    low_latency_add_tagged_conduit_bus cdr_ref_clk input "pll_refclk_cnt" {NoTag}
    if { [get_parameter_value en_synce_support]  == 1 } {
      set_port_property cdr_ref_clk TERMINATION 0
    } else { 
      set_port_property cdr_ref_clk TERMINATION 1
    }
    
    
    
    # TX Data conduits/streams
    low_latency_add_dynamic_conduit_or_stream tx_parallel_data input $total_bits_tx $symbol_size {TxAll} $split $lanes $tx_clock $is_bonded
    
    # RX Data conduits/streams
    low_latency_add_dynamic_conduit_or_stream rx_parallel_data output $total_bits_rx $symbol_size {RxAll} $split $lanes $rx_clock 0

  # Reset ports
  low_latency_add_dynamic_conduit_or_stream pll_powerdown input $tx_plls 1 {TXReset} $split $tx_plls $tx_clock $is_bonded
  low_latency_add_dynamic_conduit_or_stream tx_digitalreset input $lanes 1 {TXReset} $split $lanes $tx_clock 0
  low_latency_add_dynamic_conduit_or_stream tx_analogreset input $lanes 1 {TXReset} $split $lanes $tx_clock 0
  low_latency_add_dynamic_conduit_or_stream tx_cal_busy output $lanes 1 {TXReset} $split $lanes $tx_clock 0
  low_latency_add_dynamic_conduit_or_stream rx_digitalreset input $lanes 1 {RXReset} $split $lanes $rx_clock 0
  low_latency_add_dynamic_conduit_or_stream rx_analogreset input $lanes 1 {RXReset} $split $lanes $rx_clock 0
  low_latency_add_dynamic_conduit_or_stream rx_cal_busy output $lanes 1 {RXReset} $split $lanes $tx_clock 0

  #New optional port to gate CDR reset for ATT channels
  low_latency_add_dynamic_conduit_or_stream rx_cdr_reset_disable input $lanes 1 {RxAttCDR} 0 $lanes $rx_clock 0

}


# +---------------------------------------------------------------------------
# | Native ports that are common to all levels, with static width expressions
# | 
proc low_latency_static_native_ports { } {

    #conduit for PLL reference clock and locked status:
    low_latency_add_tagged_clock_bus pll_ref_clk input "pll_refclk_cnt" {NoTag}
    low_latency_add_tagged_conduit_bus pll_locked output "plls" {TxAll}
    
    #conduits for native TX ports:
    low_latency_add_tagged_conduit_bus tx_serial_data output "lanes" {TxAll}
    low_latency_add_tagged_conduit_bus tx_bitslip input "lanes*tx_bitslip_width" {TxBitslip}
    
    #conduits for native RX ports:
    low_latency_add_tagged_conduit_bus rx_serial_data input "lanes" {RxAll}
    low_latency_add_tagged_conduit_bus rx_is_lockedtoref output "lanes" {RxAll}
    low_latency_add_tagged_conduit_bus rx_is_lockedtodata output "lanes" {RxAll}
    low_latency_add_tagged_conduit_bus rx_bitslip input "lanes" {RxBitslip}

}

proc low_latency_dynamic_reconfig_ports { device_family } {
    # reconfig_interfaces parameter
    set lanes           [get_parameter_value lanes]
    set op_mode         [get_parameter_value operation_mode]
    set sup_bonding     [get_parameter_value gui_bonding_enable]
    set bonded_mode     [get_parameter_value bonded_mode]
    set tx_plls         [get_parameter_value plls]
    set hdl_data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]

    
    if { $op_mode == "RX" } {
        set tx_plls 0
    } elseif { $sup_bonding == 0 || $bonded_mode == "fb_compensation"} {
        set tx_plls [expr {$tx_plls * $lanes}]
    }

    #ATT duplex channels use 2 bundles per duplex channel
    if { $hdl_data_path_type == "ATT" && $op_mode == "DUPLEX" } {
        set lanes [expr {2 * $lanes}]
    } 
    
    set reconfig_interfaces [::alt_xcvr::utils::device::get_reconfig_interface_count $device_family $lanes $tx_plls]
    
    #conduit for dynamic reconfiguration
    low_latency_add_tagged_conduit_bus reconfig_from_xcvr output [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg} reconfig_from_xcvr
    low_latency_add_tagged_conduit_bus reconfig_to_xcvr input [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg} reconfig_to_xcvr
    
    if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
        common_set_port_group {XcvrRcfg} TERMINATION "true"
    }
}


# +----------------------------------------------------------
# | Set termination state for static ports and all port tags
# | 
# | For dynamic interfaces and ports, sets port tags
proc low_latency_set_port_termination {} {
    # in case of RX-only or TX-only modes
    set op_mode [get_parameter_value operation_mode]
    set sup_tx [expr {$op_mode == "TX" || $op_mode == "DUPLEX" }]
    set sup_rx [expr {$op_mode == "RX" || $op_mode == "DUPLEX" }]
    
    #TX Bitslip
    set sup_tx_bitslip [get_parameter_value tx_bitslip_enable]
    set sup_rx_bitslip [get_parameter_value rx_bitslip_enable]
    set sup_rx_att_cdr_gate [get_parameter_value gui_enable_att_reset_gate]
    
    # optional input clocks
    set user_tx_use_coreclk [get_parameter_value gui_tx_use_coreclk]
    set user_rx_use_coreclk [get_parameter_value gui_rx_use_coreclk]
    
    # TX optional ports	termination status
    common_set_port_group {TxBitslip} TERMINATION [expr {$sup_tx == 0 || $sup_tx_bitslip == 0}]
    common_set_port_group {TxAll} TERMINATION [expr {$sup_tx == 0} ]
    common_set_port_group {TxCoreclkin} TERMINATION [expr {$sup_tx == 0 || $user_tx_use_coreclk == 0}]
    
    # RX optional ports	termination status
    common_set_port_group {RxBitslip} TERMINATION [expr {$sup_rx == 0 || $sup_rx_bitslip == 0}]
    common_set_port_group {RxAll} TERMINATION [expr {$sup_rx == 0} ]
    common_set_port_group {RxCoreclkin} TERMINATION [expr {$sup_rx == 0 || $user_rx_use_coreclk == 0}]

    # New GT specific port 
    common_set_port_group {RxAttCDR} TERMINATION [expr {$sup_rx == 0 || $sup_rx_att_cdr_gate == 0}]

    
    # enable more status ports? (tx_forceelecidle, rx_is_lockedtoref, rx_is_lockedtodata, rx_signaldetect)
    #set gui_use_status [get_parameter_value gui_use_status]
    #common_set_port_group {TxMoreStatus} TERMINATION [expr {$sup_tx == 0 || $gui_use_status == "false"}]
    #common_set_port_group {RxMoreStatus} TERMINATION [expr {$sup_rx == 0 || $gui_use_status == "false"}]

    set embedded_reset [get_parameter_value embedded_reset]
    common_set_port_group {TXReset} TERMINATION [expr {$sup_tx == 0 || $embedded_reset == 1}]
    common_set_port_group {RXReset} TERMINATION [expr {$sup_rx == 0 || $embedded_reset == 1}]
    common_set_port_group {TXNoReset} TERMINATION [expr {$sup_tx == 0 || $embedded_reset == 0}]
    common_set_port_group {RXNoReset} TERMINATION [expr {$sup_rx == 0 || $embedded_reset == 0}]

}

