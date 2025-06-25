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


# +--------------------------------------------------------------------------------
# | Tcl library of CPRI PHY common functions interface and port handling
# +----------------------------------------------------------------------------------
source ../../altera_xcvr_8g_custom/xcvr_generic/xcvr_custom_phy_ports.tcl


# +---------------------------------------------------------------------------
# | Native ports that can appear as native, or optionally split into
# | separate interfaces for each lane
# | 
# | Since the splitting option is dynamic, this function should only
# | be called from the elaboration callback
proc detlat_dynamic_native_ports { {split 0} } {

	# get port widths from parameters
	set lanes [get_parameter_value lanes]
	set ser_base_factor [get_parameter_value ser_base_factor]
	set ser_words [get_parameter_value ser_words]

  set tx_plls [get_parameter_value plls]
  
	set total_words [expr {$lanes * $ser_words}]
	
	if { [get_parameter_value channel_interface] == 1 } {
          set total_bits_tx [expr 44 * $lanes]
          set total_bits_rx [expr 64 * $lanes]
        } else {
          set total_bits_tx [expr {$ser_base_factor * $lanes * $ser_words}]
          set total_bits_rx [expr {$ser_base_factor * $lanes * $ser_words}]
        }

	# clocks associated for TX and RX streams
	set tx_clock tx_clkout
	set rx_clock rx_clkout
	
	# Are TX lanes bonded?  If so, must associate to ${tx_clock}0
	set is_bonded 0
	set bonded_size 1
	
	# native, splitable clock buses
	custom_add_dynamic_conduit_or_clock_bus tx_clkout output [expr $lanes / $bonded_size] {TXAll} $split
	custom_add_dynamic_conduit_or_clock_bus rx_clkout output $lanes {RXAll} $split
  dl_add_dynamic_conduit_or_clock_bus cdr_ref_clk input 1 {CDRREF}

	# TX Data conduits/streams
	custom_add_dynamic_conduit_or_stream tx_parallel_data input $total_bits_tx $ser_base_factor {TXAll} $split $lanes $tx_clock $is_bonded
	custom_add_dynamic_conduit_or_stream tx_datak input $total_words 1 {TX8B10B} $split $lanes $tx_clock $is_bonded

	# RX Data conduits/streams
	custom_add_dynamic_conduit_or_stream rx_parallel_data output $total_bits_rx $ser_base_factor {RXAll} $split $lanes $rx_clock 0
	custom_add_dynamic_conduit_or_stream rx_datak output $total_words 1 {RX8B10B} $split $lanes $rx_clock 0

  # Reset ports
  custom_add_dynamic_conduit_or_stream pll_powerdown input $tx_plls 1 {TXReset} $split $tx_plls $tx_clock $is_bonded
  custom_add_dynamic_conduit_or_stream tx_digitalreset input $lanes 1 {TXReset} $split $lanes $tx_clock 0
  custom_add_dynamic_conduit_or_stream tx_analogreset input $lanes 1 {TXReset} $split $lanes $tx_clock 0
  custom_add_dynamic_conduit_or_stream tx_cal_busy output $lanes 1 {TXReset} $split $lanes $tx_clock 0
  custom_add_dynamic_conduit_or_stream rx_digitalreset input $lanes 1 {RXReset} $split $lanes $rx_clock 0
  custom_add_dynamic_conduit_or_stream rx_analogreset input $lanes 1 {RXReset} $split $lanes $rx_clock 0
  custom_add_dynamic_conduit_or_stream rx_cal_busy output $lanes 1 {RXReset} $split $lanes $tx_clock 0
}


# +---------------------------------------------------------------------------
# | Native ports that are common to all levels, with static width expressions
# | 
proc detlat_static_native_ports { } {
	#conduit for PLL reference clock:
	custom_add_tagged_clock_bus pll_ref_clk input "pll_refclk_cnt" {NoTag}

	#conduits for native TX ports:
	custom_add_tagged_conduit_bus tx_serial_data output "lanes" {TXAll}
	custom_add_tagged_conduit_bus tx_bitslipboundaryselect input "lanes*5" {TXBitslip}
  #conduit for TX pll locked status
	custom_add_tagged_conduit_bus pll_locked output "plls" {TXAll}

	#conduits for native RX ports:
	custom_add_tagged_conduit_bus rx_serial_data input "lanes" {RXAll}
	custom_add_tagged_conduit_bus rx_runningdisp output "lanes*ser_words" {RXStatus8B10B}
	custom_add_tagged_conduit_bus rx_disperr output "lanes*ser_words" {RXStatus8B10B}
	custom_add_tagged_conduit_bus rx_errdetect output "lanes*ser_words" {RXStatus8B10B}
	custom_add_tagged_conduit_bus rx_is_lockedtoref output "lanes" {RXMoreStatus}
	custom_add_tagged_conduit_bus rx_is_lockedtodata output "lanes" {RXMoreStatus}
	custom_add_tagged_conduit_bus rx_signaldetect output "lanes" {RXMoreStatus}
	custom_add_tagged_conduit_bus rx_patterndetect output "lanes*ser_words" {RXWaStatus}
	custom_add_tagged_conduit_bus rx_syncstatus output "lanes*ser_words" {RXWaStatus}
  custom_add_tagged_conduit_bus rx_rlv output "lanes" {RXRunLength}
	custom_add_tagged_conduit_bus rx_bitslipboundaryselectout output "lanes*5" {RXAll}
}

proc detlat_dynamic_reconfig_ports { device_family } {
  # reconfig_interfaces parameter
	set lanes       [get_parameter_value lanes]
  set op_mode     [get_parameter_value operation_mode]
	set sup_bonding "false"
  set tx_plls     [get_parameter_value plls]
  if { $op_mode == "RX" } {
    set tx_plls 0
  } elseif { $sup_bonding == "false" } {
    set tx_plls [expr {$tx_plls * $lanes}]
  }
  set reconfig_interfaces [::alt_xcvr::utils::device::get_reconfig_interface_count $device_family $lanes $tx_plls]
  
  #conduit for dynamic reconfiguration
  custom_add_tagged_conduit_bus reconfig_from_xcvr output [::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg} reconfig_from_xcvr
  custom_add_tagged_conduit_bus reconfig_to_xcvr input [::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg} reconfig_to_xcvr

  if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
    common_set_port_group {XcvrRcfg} TERMINATION "true"
  }
}


# +----------------------------------------------------------
# | Set termination state for static ports and all port tags
# | 
# | For dynamic interfaces and ports, sets port tags
proc detlat_set_port_termination {} {
	# in case of RX-only or TX-only modes
	set op_mode [get_parameter_value operation_mode]
	set sup_tx [expr {$op_mode == "TX" || $op_mode == "Duplex" }]
	set sup_rx [expr {$op_mode == "RX" || $op_mode == "Duplex" }]
	
	# Check whether channel interface enabled
  
    set sup_ch_interface [get_parameter_value channel_interface]

  # CDRREF
  set sup_cdr_clk [get_parameter_value en_cdrref_support]
  set terminate_cdrref_port [expr {$sup_cdr_clk == 0}]

	#8B10B
	set ser_base_factor [get_parameter_value ser_base_factor]
	if { $ser_base_factor == 8 } {
		set sup_8b10b "true"
	} else {
		set sup_8b10b "false"
	}
	set sup_8b10b_status [get_parameter_value gui_use_8b10b_status]

	set terminate_8b10b_tx [expr {$sup_tx == 0 || ($sup_8b10b == "false" || $sup_ch_interface == 1) }]
	set terminate_8b10b_rx [expr {$sup_rx == 0 || ($sup_8b10b == "false" || $sup_ch_interface == 1) }]
	set terminate_8b10b_status [expr {$terminate_8b10b_rx == 1 || $sup_8b10b_status == "false" }]
	
	#TX Bitslip
	set sup_tx_bitslip [get_parameter_value tx_bitslip_enable]
	set terminate_tx_bitslip_rx [expr {$sup_rx == 0 || $sup_tx_bitslip == "false" }]
	
	#Word Aligner
	set wa_mode [get_parameter_value word_aligner_mode]
	set sup_wa_status [get_parameter_value gui_use_wa_status]
  set sup_run_length [get_parameter_value gui_enable_run_length]
	set terminate_wa_status [expr {$sup_rx == 0 || ($sup_wa_status == "false" || $sup_ch_interface == 1) }]
  set terminate_rx_run_length [expr {$sup_rx == 0 || ($sup_run_length == "false" && $sup_ch_interface == 0)}]

	# TX optional ports	termination status
	common_set_port_group {TX8B10B} TERMINATION $terminate_8b10b_tx
	common_set_port_group {TXBitslip} TERMINATION [expr {$sup_tx == 0 || $sup_tx_bitslip == "false"}]
	common_set_port_group {TXAll} TERMINATION [expr {$sup_tx == 0} ]
  common_set_port_group {CDRREF} TERMINATION $terminate_cdrref_port

	# RX optional ports	termination status
	common_set_port_group {RX8B10B} TERMINATION $terminate_8b10b_rx
	common_set_port_group {RXStatus8B10B} TERMINATION $terminate_8b10b_status
	common_set_port_group {RXTXBitslip} TERMINATION $terminate_tx_bitslip_rx
	common_set_port_group {RXWaStatus} TERMINATION $terminate_wa_status
	common_set_port_group {RXAll} TERMINATION [expr {$sup_rx == 0} ]
  common_set_port_group {RXRunLength} TERMINATION $terminate_rx_run_length
	
	# enable more status ports? (rx_is_lockedtoref, rx_is_lockedtodata, rx_signaldetect)
	set gui_use_status [get_parameter_value gui_use_status]
	common_set_port_group {TXMoreStatus} TERMINATION [expr {$sup_tx == 0 || $gui_use_status == "false"}]
	common_set_port_group {RXMoreStatus} TERMINATION [expr {$sup_rx == 0 || $gui_use_status == "false"}]

  set embedded_reset [get_parameter_value embedded_reset]
  common_set_port_group {TXReset} TERMINATION [expr {$sup_tx == 0 || $embedded_reset == 1}]
  common_set_port_group {RXReset} TERMINATION [expr {$sup_rx == 0 || $embedded_reset == 1}]
  common_set_port_group {TXNoReset} TERMINATION [expr {$sup_tx == 0 || $embedded_reset == 0}]
  common_set_port_group {RXNoReset} TERMINATION [expr {$sup_rx == 0 || $embedded_reset == 0}]
}

# +-----------------------------------------------------------
# | Add clock bus as a split clock interface or a conduit bus
# | 
# | $port_dir - can be 'input' or 'output'
proc dl_add_dynamic_conduit_or_clock_bus { port_name port_dir port_width tags } {

  array set in_out [list {output} {start} {input} {end} ]

  set terminated [common_get_tagged_property_state $tags TERMINATION 0 ]
#  custom_add_dynamic_conduit_bus $port_name $port_dir $port_width $terminated
#  custom_add_tagged_clock_bus $port_name $port_dir $port_width $tags
#  custom_add_tagged_clock_bus pll_ref_clk input "pll_refclk_cnt" {NoTag}

  add_interface ${port_name} clock $in_out($port_dir)
  set_interface_property ${port_name} ENABLED true
  add_interface_port ${port_name} ${port_name} clk $port_dir $port_width
  if {$terminated} {
    set_port_property $port_name TERMINATION 1
  }
  
}