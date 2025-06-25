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
# | Tcl library of Custum PHY common functions interface and port handling
# +----------------------------------------------------------------------------------



# +-----------------------------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc custom_add_tagged_conduit { port_name port_dir width tags {port_role "export"} } {

  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name conduit $in_out($port_dir)
  set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
  #set_interface_property $port_name ENABLED $used
  common_add_interface_port $port_name $port_name $port_role $port_dir $width $tags
  if {$port_dir == "input"} {
    set_port_property $port_name TERMINATION_VALUE 0
  }
}
proc custom_add_tagged_conduit_bus { port_name port_dir width tags {port_role "export"} } {
  custom_add_tagged_conduit $port_name $port_dir $width $tags $port_role
  set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}
# +---------------------------------------------------------
# | Add dynamic conduit interface with optional termination
# | 
proc custom_add_dynamic_conduit_bus { port_name port_dir width terminated } {

  custom_add_tagged_conduit_bus $port_name $port_dir $width {NoTag} 

  # if this interface is terminated, do it here since it's dynamically generated
  if {$terminated} {
    set_port_property $port_name TERMINATION 1
  }
}


# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, associated with phy_mgmt_clk
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc custom_add_mgmt_clk_stream { port_name port_dir width used } {

  array set in_out [list {output} {start} {input} {end} ]
  # create interface details
  add_interface $port_name avalon_streaming $in_out($port_dir)
  set_interface_property $port_name dataBitsPerSymbol $width
  set_interface_property $port_name maxChannel 0
  set_interface_property $port_name readyLatency 0
  set_interface_property $port_name symbolsPerBeat 1
  set_interface_property $port_name ENABLED $used
  set_interface_property $port_name ASSOCIATED_CLOCK phy_mgmt_clk
  add_interface_port $port_name $port_name data $port_dir $width
  set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}


# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc custom_add_clock { port_name port_dir } {

  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name clock $in_out($port_dir)
  set_interface_property $port_name ENABLED true
  add_interface_port $port_name $port_name clk $port_dir 1
}


# +-----------------------------------
# | Add clock bus as a clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc custom_add_tagged_clock_bus { port_name port_dir port_width tags} {

  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name clock $in_out($port_dir)
  set_interface_property $port_name ENABLED true
  common_add_interface_port $port_name $port_name clk $port_dir $port_width $tags
}


# +-----------------------------------------------------------
# | Add clock bus as a split clock interface or a conduit bus
# | 
# | $port_dir - can be 'input' or 'output'
proc custom_add_dynamic_conduit_or_clock_bus { port_name port_dir port_width tags {split 0}} {

  array set in_out [list {output} {start} {input} {end} ]

  # even if split indicated, only split if not terminated
  set terminated [common_get_tagged_property_state $tags TERMINATION 0 ]

  if {$split && ! $terminated} {
    for {set i 0} {$i < $port_width} {incr i} {
      add_interface ${port_name}$i clock $in_out($port_dir)
      set_interface_property ${port_name}$i ENABLED true
      add_interface_port ${port_name}$i ${port_name}$i clk $port_dir 1
      set_port_property ${port_name}$i FRAGMENT_LIST ${port_name}@${i}
    }
  } else {
    custom_add_dynamic_conduit_bus $port_name $port_dir $port_width $terminated
  }
}


# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, split into multiple streams
# | 
# | This function is intended to be called from an elaboration callback, so it does not
# | register ports with the common tagged port API
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc custom_add_split_stream { port_name port_dir width bits_per_symbol assoc_clock is_bonded fragments } {

  array set in_out [list {output} {start} {input} {end} ]
  set fragment_width [expr {$width / $fragments}]
  set num_symbols [expr {$fragment_width / $bits_per_symbol } ]

  for {set i 0} {$i < $fragments} {incr i} {
    # which clock index?
    if {$is_bonded} {
      set clock_index 0
    } else {
      set clock_index $i
    }
    add_interface ${port_name}$i avalon_streaming $in_out($port_dir)
    set_interface_property ${port_name}$i dataBitsPerSymbol $bits_per_symbol
    set_interface_property ${port_name}$i maxChannel 0
    set_interface_property ${port_name}$i readyLatency 0
    set_interface_property ${port_name}$i symbolsPerBeat $num_symbols
    set_interface_property ${port_name}$i ASSOCIATED_CLOCK $assoc_clock$clock_index

    add_interface_port ${port_name}$i ${port_name}$i data $port_dir $fragment_width
    set frag_base [expr {$i * $fragment_width}]
    set frag_top [expr {$i * $fragment_width + $fragment_width - 1}]
      
    for {set w 0} {$w < $fragment_width} {incr w} {
      lappend port_temp ${port_name}@[expr $frag_base + $w]
    }
      
    set port_flipped [lrange $port_temp $frag_base $frag_top]
    
    set_port_property ${port_name}$i FRAGMENT_LIST  $port_flipped
    set_port_property ${port_name}$i VHDL_TYPE STD_LOGIC_VECTOR
  }
}


# +----------------------------------------------------
# | Declare either native conduit bus or split streams
# | 
proc custom_add_dynamic_conduit_or_stream { port_name port_dir width bits_per_symbol tags split fragments assoc_clock is_bonded } {
  # if split indicated, only split if not terminated
  set terminated [common_get_tagged_property_state $tags TERMINATION 0 ]

  if {$split == 1 && $terminated == 0} {
    custom_add_split_stream $port_name $port_dir $width $bits_per_symbol $assoc_clock $is_bonded $fragments
  } else {
    custom_add_dynamic_conduit_bus $port_name $port_dir $width $terminated
  }
}

# +-----------------------------------
# | Management interface ports
# | 
# | - Needed for layers above native PHY layer
# | 
proc custom_mgmt_interface { {addr_width 9} } {
  
  # +-----------------------------------
  # | connection point phy_mgmt_clk and reset
  # | 
  custom_add_clock  phy_mgmt_clk  input
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
  custom_add_tagged_conduit tx_ready output 1 {TXNoReset}
  custom_add_tagged_conduit rx_ready output 1 {RXNoReset}
}

# +---------------------------------------------------------------------------
# | Native ports that can appear as native, or optionally split into
# | separate interfaces for each lane
# | 
# | Since the splitting option is dynamic, this function should only
# | be called from the elaboration callback
proc custom_dynamic_native_ports { {split 0} } {

  # get port widths from parameters
  set lanes [get_parameter_value lanes]
  set ser_base_factor [get_parameter_value ser_base_factor]
  set ser_words [get_parameter_value ser_words]
  set tx_plls [get_parameter_value plls]

  set total_words [expr {$lanes * $ser_words}]
  if { [get_parameter_value channel_interface] == 1 } {    set total_bits_tx [expr 44 * $lanes]    set total_bits_rx [expr 64 * $lanes]  } else {    set total_bits_tx [expr {$ser_base_factor * $lanes * $ser_words}]    set total_bits_rx [expr {$ser_base_factor * $lanes * $ser_words}]  }

  # which associated clocks for TX and RX streams?
  set rx_use_coreclk [get_parameter_value rx_use_coreclk]
  set tx_use_coreclk [get_parameter_value tx_use_coreclk]
  if {$tx_use_coreclk == "true"} {
    set tx_clock tx_coreclkin
  } else {
    set tx_clock tx_clkout
  }
  if {$rx_use_coreclk == "true"} {
    set rx_clock rx_coreclkin
  } else {
    set rx_clock rx_clkout
  }

   

  
  # Are TX lanes bonded?  If so, must associate to ${tx_clock}0
  set bonded_mode [get_parameter_value gui_bonding_enable ]
  set is_bonded [expr {$bonded_mode == "true"} ]
  set bonded_size [get_parameter_value bonded_group_size]
  
  # native, splitable clock buses
  custom_add_dynamic_conduit_or_clock_bus tx_coreclkin input $lanes {TXCoreclkin} $split
  custom_add_dynamic_conduit_or_clock_bus rx_coreclkin input $lanes {RXCoreclkin} $split
  custom_add_dynamic_conduit_or_clock_bus rx_recovered_clk output $lanes {RXRecoveredClk} $split
  custom_add_dynamic_conduit_or_clock_bus tx_clkout output [expr $lanes / $bonded_size] {TXAll} $split
  custom_add_dynamic_conduit_or_clock_bus rx_clkout output $lanes {RXAll} $split
  custom_add_dynamic_conduit_or_clock_bus cdr_ref_clk input 1 {SYNCE} 0

  # TX Data conduits/streams
  custom_add_dynamic_conduit_or_stream tx_parallel_data input $total_bits_tx $ser_base_factor {TXAll} $split $lanes $tx_clock $is_bonded
  custom_add_dynamic_conduit_or_stream tx_datak input $total_words 1 {TX8B10B} $split $lanes $tx_clock $is_bonded
  custom_add_dynamic_conduit_or_stream tx_dispval input $total_words 1 {TXManual8B10B} $split $lanes $tx_clock $is_bonded
  custom_add_dynamic_conduit_or_stream tx_forcedisp input $total_words 1 {TXManual8B10B} $split $lanes $tx_clock $is_bonded

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
  custom_add_dynamic_conduit_or_stream rx_cal_busy output $lanes 1 {RXReset} $split $lanes $tx_clock 0    # Ports for external PLL clock    custom_add_dynamic_conduit_or_clock_bus ext_pll_clk input [expr $lanes * $tx_plls] {TXExtPLL} $split
}


# +---------------------------------------------------------------------------
# | Native ports that are common to all levels, with static width expressions
# | 
proc custom_static_native_ports { } {

  #conduit for PLL reference clock:
  custom_add_tagged_clock_bus pll_ref_clk input "pll_refclk_cnt" {NoTag}

  #conduits for native TX ports:
  custom_add_tagged_conduit_bus tx_serial_data output "lanes" {TXAll}
  custom_add_tagged_conduit_bus tx_forceelecidle input "lanes" {TXMoreStatus}
  custom_add_tagged_conduit_bus tx_bitslipboundaryselect input "lanes*5" {TXBitslip}
  #conduit for TX pll locked status
  custom_add_tagged_conduit_bus pll_locked output "plls" {TXPLL}

  #conduits for native RX ports:
  custom_add_tagged_conduit_bus rx_serial_data input "lanes" {RXAll}
  custom_add_tagged_conduit_bus rx_runningdisp output "lanes*ser_words" {RX8B10B}
  custom_add_tagged_conduit_bus rx_disperr output "lanes*ser_words" {RXStatus8B10B}
  custom_add_tagged_conduit_bus rx_errdetect output "lanes*ser_words" {RXStatus8B10B}
  custom_add_tagged_conduit_bus rx_is_lockedtoref output "lanes" {RXMoreStatus}
  custom_add_tagged_conduit_bus rx_is_lockedtodata output "lanes" {RXMoreStatus}
  custom_add_tagged_conduit_bus rx_signaldetect output "lanes" {RXMoreStatus}
  custom_add_tagged_conduit_bus rx_patterndetect output "lanes*ser_words" {RXWaStatus}
  custom_add_tagged_conduit_bus rx_syncstatus output "lanes*ser_words" {RXWaStatus}    custom_add_tagged_conduit_bus rx_bitslipboundaryselectout output "lanes*5" {RXWaStatus}
  custom_add_tagged_conduit_bus rx_enabyteord input "lanes" {RXByteOrderCtrl}
  custom_add_tagged_conduit_bus rx_bitslip input "lanes" {RXWaBitslip}
  custom_add_tagged_conduit_bus rx_rmfifodatainserted output "lanes*ser_words" {RmFIFOStatus}
  custom_add_tagged_conduit_bus rx_rmfifodatadeleted output "lanes*ser_words" {RmFIFOStatus}
  custom_add_tagged_conduit_bus rx_rlv output "lanes" {RXRunLength}
  custom_add_tagged_conduit_bus rx_byteordflag output "lanes" {RXByteOrder}
}

proc custom_dynamic_reconfig_ports { device_family } {
  # reconfig_interfaces parameter
  set lanes       [get_parameter_value lanes]
  set op_mode     [get_parameter_value operation_mode]
  set sup_bonding [get_parameter_value gui_bonding_enable]
  set bonded_mode [get_parameter_value bonded_mode]
  set tx_plls     [get_parameter_value plls]

  if { $op_mode == "RX" } {
    set tx_plls 0
  } elseif { $sup_bonding == "false" || $bonded_mode == "fb_compensation"} {
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
proc custom_set_port_termination {} {
  # in case of RX-only or TX-only modes
  set op_mode [get_parameter_value operation_mode]
  set sup_tx [expr {$op_mode == "TX" || $op_mode == "Duplex" }]
  set sup_rx [expr {$op_mode == "RX" || $op_mode == "Duplex" }]  # Check whether channel interface enabled    set sup_ch_interface [get_parameter_value channel_interface]

  # SYNCE
  set sup_cdr_clk [get_parameter_value en_synce_support]
  set terminate_syncE_port [expr {$sup_cdr_clk == 0}]
  #8B10B
  set sup_8b10b [get_parameter_value use_8b10b]
  set sup_8b10b_manual [get_parameter_value use_8b10b_manual_control]
  set sup_8b10b_status [get_parameter_value gui_use_8b10b_status]

  set terminate_8b10b_tx [expr {$sup_tx == 0 || ($sup_8b10b == "false" || $sup_ch_interface == 1) }]
  set terminate_8b10b_manual [expr {$terminate_8b10b_tx == 1 || $sup_8b10b_manual == "false" }]
  set terminate_8b10b_rx [expr {$sup_rx == 0 || ($sup_8b10b == "false" || $sup_ch_interface == 1) }]
  set terminate_8b10b_status [expr {$terminate_8b10b_rx == 1 || $sup_8b10b_status == "false" }]
  
  #TX Bitslip
  set sup_tx_bitslip [get_parameter_value tx_bitslip_enable]
  set terminate_tx_bitslip_rx [expr {$sup_rx == 0 || $sup_tx_bitslip == "false" }]
  
  #Byte order
  set sup_byte_order [get_parameter_value gui_use_byte_order_block]
  set sup_byte_order_manual [get_parameter_value gui_byte_order_pld_ctrl_enable]
  set terminate_byte_order_control [expr {$sup_rx == 0 || (($sup_byte_order == "false" || $sup_byte_order_manual == "false") && $sup_ch_interface == 0)}]
  set terminate_byte_order_status [expr {$sup_rx == 0 || ($sup_byte_order == "false" && $sup_ch_interface == 0)}]
  
  #Word Aligner
  set wa_mode [get_parameter_value word_aligner_mode]
  set sup_wa_status [get_parameter_value gui_use_wa_status]
  set sup_run_length [get_parameter_value gui_enable_run_length]
  set terminate_wa_status [expr {$sup_rx == 0 || ($wa_mode == "bitslip" || $sup_wa_status == "false" || $sup_ch_interface == 1) }]
  set terminate_rx_bitslip_control [expr {$sup_rx == 0 || ($wa_mode != "bitslip" && $sup_ch_interface == 0) }]
  set terminate_rx_run_length [expr {$sup_rx == 0 || ($sup_run_length == "false" && $sup_ch_interface == 0)}]

  # optional input clocks
  set rx_use_coreclk [get_parameter_value rx_use_coreclk]
  set tx_use_coreclk [get_parameter_value tx_use_coreclk]
  set rx_use_recovered_clk [get_parameter_value gui_rx_use_recovered_clk]

  # Rate Match
  set sup_rm_fifo [get_parameter_value use_rate_match_fifo]
  set sup_rm_fifo_status [get_parameter_value gui_use_rmfifo_status]

  set terminate_rm_fifo_status [expr {$sup_rx == 0 || ($sup_rm_fifo == "false" || $sup_rm_fifo_status == "false" || $sup_ch_interface == 1)}]
  # External TX PLL  set ext_pll [get_parameter_value pll_external_enable]
  # TX optional ports termination status
  common_set_port_group {TX8B10B} TERMINATION $terminate_8b10b_tx
  common_set_port_group {TXManual8B10B} TERMINATION $terminate_8b10b_manual
  common_set_port_group {TXBitslip} TERMINATION [expr {$sup_tx == 0 || $sup_tx_bitslip == "false"}]
  common_set_port_group {TXAll} TERMINATION [expr {$sup_tx == 0} ]    common_set_port_group {TXPLL} TERMINATION [expr {($sup_tx == 0) || ($ext_pll == 1)} ]    common_set_port_group {TXExtPLL} TERMINATION [expr {($sup_tx == 0) || ($ext_pll == 0)} ]
  common_set_port_group {TXCoreclkin} TERMINATION [expr {$sup_tx == 0 || $tx_use_coreclk == "false"}]
  common_set_port_group {SYNCE} TERMINATION $terminate_syncE_port

  # RX optional ports termination status
  common_set_port_group {RX8B10B} TERMINATION $terminate_8b10b_rx
  common_set_port_group {RXStatus8B10B} TERMINATION $terminate_8b10b_status
  common_set_port_group {RXTXBitslip} TERMINATION $terminate_tx_bitslip_rx
  common_set_port_group {RXByteOrderCtrl} TERMINATION $terminate_byte_order_control
  common_set_port_group {RXByteOrder} TERMINATION $terminate_byte_order_status
  common_set_port_group {RXWaStatus} TERMINATION $terminate_wa_status
  common_set_port_group {RXWaBitslip} TERMINATION $terminate_rx_bitslip_control
  common_set_port_group {RXAll} TERMINATION [expr {$sup_rx == 0} ]
  common_set_port_group {RXCoreclkin} TERMINATION [expr {$sup_rx == 0 || $rx_use_coreclk == "false"}]
  common_set_port_group {RmFIFOStatus} TERMINATION $terminate_rm_fifo_status
  common_set_port_group {RXRunLength} TERMINATION $terminate_rx_run_length
  common_set_port_group {RXRecoveredClk} TERMINATION [expr {$sup_rx == 0 || $rx_use_recovered_clk == "false"}]
  
  # enable more status ports? (tx_forceelecidle, rx_is_lockedtoref, rx_is_lockedtodata, rx_signaldetect)
  set gui_use_status [get_parameter_value gui_use_status]
  common_set_port_group {TXMoreStatus} TERMINATION [expr {$sup_tx == 0 || $sup_rx == 0 || $gui_use_status == "false"}]
  common_set_port_group {RXMoreStatus} TERMINATION [expr {$sup_rx == 0 || $gui_use_status == "false"}]

  set embedded_reset [get_parameter_value embedded_reset]
  common_set_port_group {TXReset} TERMINATION [expr {$sup_tx == 0 || $embedded_reset == 1}]
  common_set_port_group {RXReset} TERMINATION [expr {$sup_rx == 0 || $embedded_reset == 1}]
  common_set_port_group {TXNoReset} TERMINATION [expr {$sup_tx == 0 || $embedded_reset == 0}]
  common_set_port_group {RXNoReset} TERMINATION [expr {$sup_rx == 0 || $embedded_reset == 0}]
}
