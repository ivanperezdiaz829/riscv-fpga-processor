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


package require alt_xcvr::utils::device

package provide alt_xcvr::gui::messages 11.1

namespace eval ::alt_xcvr::gui::messages:: {
  namespace export \
    reconfig_interface_message
}

###
# Display messages indicating the number of reconfig interfaces required for a given configuration
#
# @param fam - The device family
# @param channels - The number of data channels
# @param tx_plls - The number of transmit plls
proc ::alt_xcvr::gui::messages::reconfig_interface_message { fam channels tx_plls } {
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $fam] | \
       [::alt_xcvr::utils::device::has_a5_style_hssi $fam] | \
       [::alt_xcvr::utils::device::has_c5_style_hssi $fam] } {
    # Total
    set total [expr $channels + $tx_plls]
    set add_s [expr {$total > 1 ? "s" : " "}]
    send_message info "PHY IP will require ${total} reconfiguration interface${add_s} for connection to the external reconfiguration controller."

    # Channels
    set max [expr $channels - 1]
    set add_s [expr {$channels > 1 ? "s" : " "}]
    set is_are [expr {$channels > 1 ? "are" : "is"}]
    set count [expr {$channels > 1 ? "0-${max}" : "0"}]
    send_message info "Reconfiguration interface offset${add_s} ${count} $is_are connected to the transceiver channel${add_s}."

    # TX PLLS
    if { [expr {$tx_plls > 0} ] } {
      set min $channels
      set max [expr $min + $tx_plls - 1]
      set add_s [expr {$tx_plls > 1 ? "s" : " "}]
      set is_are [expr {$tx_plls > 1 ? "are" : "is"}]
      set count [expr {$tx_plls > 1 ? "${min}-${max}" : "${min}"}]
      send_message info "Reconfiguration interface offset${add_s} ${count} ${is_are} connected to the transmit PLL${add_s}."
    }
  }
}


proc ::alt_xcvr::gui::messages::internal_error_message { error_text } {
  send_message error "Internal Error: $error_text"
}

proc ::alt_xcvr::gui::messages::data_rate_format_error {} {
  send_message error "Data rate must be specified as a decimal value followed by a unit (Mbps or Gbps). Example \"1250 Mbps\""
}
