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


package require quartus::advanced_hssi_legality
package require alt_xcvr::utils::common
package require alt_xcvr::utils::device

package provide alt_xcvr::utils::rbc 11.1

namespace eval ::alt_xcvr::utils::rbc:: {
  namespace export \
    get_valid_refclks_atx_att_rx \
    get_valid_refclks \
    get_valid_base_data_rates \
    validate_pcs_data_rate \
    rbc_values_cleanup

    variable package_name "alt_xcvr::utils::rbc"
}

##
# Get the list of valid reference clock frequencies for rx atx pll in att(gt) mode
#
# @param device_family - device family
# @param base_data_rate - The data rate of the PLL (frequency * 2) (Gbps, Mbps, bps)
proc ::alt_xcvr::utils::rbc::get_valid_refclks_atx_att_rx { device_family base_data_rate } {
  variable package_name
  
  # Extract overloaded device_family to get device_family and speedgrade
  set device_family [split $device_family *]
  set device_speedgrade [lindex $device_family 1]
  set device_family [lindex $device_family 0]
  # Get typical device for family
  set device [::alt_xcvr::utils::device::get_typical_device $device_family $device_speedgrade]

  array set refclk_array { } 
  set refclk_list { }
  
  #convert data rate strings to integer Mbps
  set base_data_int [::alt_xcvr::utils::common::get_data_rate_in_mbps $base_data_rate]
  #convert data rate to output clock frequency
  set output_clk_freq_int [expr $base_data_int / 2.0]  
  lappend output_clk_freq $output_clk_freq_int "MHz"
  
  if [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] {
    # Stratix V
    
    # For reference, the following are the dependencies for the STRATIXV_HSSI_PMA_CDR_ATT_REFERENCE_CLOCK_FREQUENCY
    # part 
    # {this stratixv_atx_pll output_clock_frequency} 
    set return_value [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values \
      -flow_type MEGAWIZARD \
      -configuration_name STRATIXV_HSSI_CONFIG \
      -rule_name STRATIXV_HSSI_PMA_CDR_ATT_REFERENCE_CLOCK_FREQUENCY \
      -param_args [list \
        $device \
        $output_clk_freq] ]
  } else {
    # ONLY S5 has atx pll
    ::alt_xcvr::gui::messages::internal_error_message "${package_name}::get_valid_refclks_atx_gt_rx - ONLY Starix V has atx pll. Selected device is \"$device_family\""
    return "N/A"
  }

  #strip off {{ and }} from RBC
  set return_value [rbc_values_cleanup $return_value]
  
  #split each refclk freq returned
  set return_array [split $return_value |]
  
  #extract frequency
  array set refclk_array { }
  set refclk_max 710  ;#max limit for refclk freq is 710 MHz
  
  foreach freq $return_array {
    regexp {([0-9.]+)} $freq value 
    set refclk_array($value) 1
  }
  
  #append into list
  foreach f [array names refclk_array] {
    lappend refclk_list $f
  }
  
  #writes refclk into correct format
  foreach f [lsort -real [array names refclk_array] ] {
    if { $f <= $refclk_max } {
      lappend refclk_str "$f MHz"
    }
  }
  
  #Prompt error message when data rate is illegal and return 'N/A' as result
  if ![info exist refclk_str] {
    set refclk_str "N/A"
  }
  
  return $refclk_str
}

###
# Get the list of valid reference clock frequencies for a given configuration.
#
# @param device_family - device family
# @param base_data_rate - The data rate of the PLL (frequency * 2) (Gbps, Mbps, bps)
# @param pll_type - ATX,CMU,FPLL
# @param enable_att - OPTIONAL - "true" for ATT configurations, "false" otherwise.
# @param pll_feedback - OPTIONAL - "internal" for internal PLL feedback, "PCS" for feedback from the PCS, "PMA" for feedback from PMA
# @param pma_width - OPTIONAL - Required if PLL feedback is "PCS" or "PMA". PMA serializer/deserializer width 
# @param pma_data_rate - OPTIONAL - Required if PLL feedback is "PCS" or "PMA". Data rate of the channel. Used to calculate CGB divider value
# @param byte_serializer - OPTIONAL - Required if PLL feedback is "PCS". "disabled" or "2" or "4"
proc ::alt_xcvr::utils::rbc::get_valid_refclks { device_family base_data_rate pll_type {enable_att "false"} {pll_feedback "internal"} {pma_width "unused"} {pma_data_rate "unused"} { byte_serializer "disabled"} } {
  variable package_name
  
  # Extract overloaded device_family to get device_family and speedgrade
  set device_family [split $device_family *]
  set device_speedgrade [lindex $device_family 1]
  set device_family [lindex $device_family 0]
  # Get typical device for family
  set device [::alt_xcvr::utils::device::get_typical_device $device_family $device_speedgrade]

  array set refclk_array { } 
  set refclk_list { }
  
  #convert data rate strings to integer Mbps
  set base_data_int [::alt_xcvr::utils::common::get_data_rate_in_mbps $base_data_rate]
  set cgb_div 1
  # Get cgb divider value
  if { $pll_feedback == "PCS" || $pll_feedback == "PMA"} {
    if { $pma_data_rate == "unused" } {
      ::alt_xcvr::gui::messages::internal_error_message "${package_name}::get_valid_refclks - illegal value \"$pma_data_rate\" for argument \"pma_data_rate\""
      return "N/A"
    } else {
      set data_rate_int [::alt_xcvr::utils::common::get_data_rate_in_mbps $pma_data_rate]
      # Calculate CGB divider value
      set cgb_div [expr $base_data_int / $data_rate_int]
    }
  } 
  #convert data rate to output clock frequency
  set output_clk_freq_int [expr $base_data_int / 2.0]
  
  lappend output_clk_freq $output_clk_freq_int "MHz"

  
  if [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] {
    # Stratix V

    # Byte serializer
    set lcl_byte_serializer "dis_bs"
    if { $pll_feedback == "PCS" } {
      if { $byte_serializer == 2 } {
        set lcl_byte_serializer "en_bs_by_2"
      } elseif { $byte_serializer == 4 } {
        set lcl_byte_serializer "en_bs_by_4"
      } else {
        ::alt_xcvr::gui::messages::internal_error_message "${package_name}::get_valid_refclks - illegal value \"$byte_serializer\" for argument \"byte_serializer\""
        return "N/A"
      }
    }

    # fbclk_sel parameter
    if { $pll_type == [::alt_xcvr::utils::device::get_atx_pll_name] } {
      # fbclk_sel parameter
      if { $pll_feedback == "PCS" || $pll_feedback == "PMA" } {
        set fbclk_sel "external_fb"
      } else {
        set fbclk_sel "internal_fb"
      }

      # 8G / 14G output connectivity
    
      set connected_8g "CONNECTED"
      set connected_14g "DISCONNECTED"
      if { $enable_att == "true" } {
        set connected_8g "DISCONNECTED"
        set connected_14g "CONNECTED"
      }

      # For reference, the following are the dependencies for the STRATIXV_LC_PLL_REFERENCE_CLOCK_FREQUENCY_CALL
      # part 
      # {this stratixv_atx_pll output_clock_frequency} 
      # {this stratixv_atx_pll fbclk_sel} 
      # {this stratixv_atx_pll_db_oport_clk010g_bus connect_state} 
      # {this stratixv_atx_pll_db_oport_clk025g_bus connect_state} 
      # {this stratixv_atx_pll_db_iport_extfbclk_bus connect_state} 
      # {external_feedback_pma_tx_ser stratixv_hssi_pma_tx_ser mode}
      set return_value [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values \
        -flow_type MEGAWIZARD \
        -configuration_name STRATIXV_HSSI_CONFIG \
        -rule_name STRATIXV_LC_PLL_REFERENCE_CLOCK_FREQUENCY \
        -param_args [list \
          $device \
          $output_clk_freq \
          $fbclk_sel \
          $connected_8g \
          $connected_14g \
          "CONNECTED" \
          $pma_width \
          $cgb_div] ]
    } elseif { $pll_type == "CMU" } {

      # fb_sel parameter
      set fb_sel "vcoclk"
      if { $pll_feedback == "PCS" || $pll_feedback == "PMA" } {
        set fb_sel "extclk"
      }
      # part 
      # {this stratixv_channel_pll output_clock_frequency} 
      # {this stratixv_channel_pll fb_sel} 
      # {this stratixv_channel_pll_db_iport_rxp_bus connect_state} 
      # {this stratixv_channel_pll_db_iport_extclk_bus connect_state} 
      # {external_feedback_pma_tx_ser stratixv_hssi_pma_tx_ser mode} 
      # {external_feedback_tx_8g_pcs stratixv_hssi_8g_tx_pcs byte_serializer}
      #puts "$device $output_clk_freq $fb_sel DISCONNECTED CONNECTED $pma_width $lcl_byte_serializer $cgb_div"
      set return_value [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values \
        -flow_type MEGAWIZARD \
        -configuration_name STRATIXV_HSSI_CONFIG \
        -rule_name STRATIXV_CDR_PLL_REFERENCE_CLOCK_FREQUENCY \
        -param_args [list \
          $device \
          $output_clk_freq \
          $fb_sel \
          "DISCONNECTED" \
          "CONNECTED" \
          $pma_width \
          $lcl_byte_serializer \
          $cgb_div] ]
    }
  } else {
    # Arria V / Cyclone V
    if { $pll_type == "CMU" } {
      set return_value [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values \
        -flow_type MEGAWIZARD \
        -configuration_name ARRIAV_HSSI_CONFIG \
        -rule_name ARRIAV_CDR_PLL_REFERENCE_CLOCK_FREQUENCY \
        -param_args [list \
          $device \
          $output_clk_freq \
          "DISCONNECTED" \
          "EIGHT_G_PCS" \
          "" \
          "basic" \
          "TWENTY_BIT" \
          "basic" \
          "basic" \
          "TWENTY_BIT" \
          "basic"]]
    } else {
      set return_value "{{}}"
    }
  }

  #strip off {{ and }} from RBC
  set return_value [rbc_values_cleanup $return_value]
  
  #split each refclk freq returned
  set return_array [split $return_value |]
  
  #extract frequency
  array set refclk_array { }
  set refclk_max 710  ;#max limit for refclk freq is 710 MHz
  
  foreach freq $return_array {
    regexp {([0-9.]+)} $freq value 
    set refclk_array($value) 1
  }
  
  #append into list
  foreach f [array names refclk_array] {
    lappend refclk_list $f
  }
  
  #writes refclk into correct format
  foreach f [lsort -real [array names refclk_array] ] {
    if { $f <= $refclk_max } {
      lappend refclk_str "$f MHz"
    }
  }
  
  #Prompt error message when data rate is illegal and return 'N/A' as result
  if ![info exist refclk_str] {
    set refclk_str "N/A"
  }
  
  return $refclk_str
}


proc ::alt_xcvr::utils::rbc::get_valid_base_data_rates { device_family data_rate pll_type } {
  set base_data_rate_list {}

  set cgb_divider_list [ ::alt_xcvr::utils::device::get_cgb_divider_values $device_family ]
  set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate ]

  foreach i $cgb_divider_list {
    set base_data_rate [expr {$i * $data_rate_int}]
    set data_rate_str "${base_data_rate} Mbps"
    set result [get_valid_refclks $device_family $data_rate_str $pll_type]
    if { $result != "N/A" && $result != "N.A" } { 
      # add base_data_rate to list
      lappend base_data_rate_list $data_rate_str
    }
  }

  return $base_data_rate_list
}

proc ::alt_xcvr::utils::rbc::get_pma_dw { deser_factor base_factor pcs_dw_mode } {
  if { ($deser_factor == 8 && $base_factor == 8) || ($deser_factor == 16 && $base_factor == 8 && $pcs_dw_mode == "Double") }  {
    set pma_dw "EIGHT_BIT"
  } elseif { ($deser_factor == 10 ||  ($deser_factor == 8 && $base_factor == 10)) || (($deser_factor == 20 || ($deser_factor == 16 && $base_factor == 10)) && $pcs_dw_mode == "Double") }  {
    set pma_dw "TEN_BIT"
  } elseif { ($deser_factor == 16 || $deser_factor == 32) && $base_factor == 8 } {
    set pma_dw "SIXTEEN_BIT"
  } else {
    set pma_dw "TWENTY_BIT"
  }
}

proc ::alt_xcvr::utils::rbc::validate_pcs_data_rate { device_family data_rate op_mode prot_mode deser_factor pcs_datapath pcs_dw_mode base_factor pcs_bypass {pma_width "width_32"}} {
  
  #Select device according to family
  set device [::alt_xcvr::utils::device::get_typical_device $device_family]
  
  #convert data rate to output clock frequency
  set output_clk_freq_int [expr $data_rate / 2.0]
  
  #get rule dependencies
  if {$op_mode == "Rx" || $op_mode == "RX"} {
    set rxp_bus "CONNECTED"
    set tx_pcs ""
    set rx_pcs $pcs_datapath
  } else {
    set rxp_bus "DISCONNECTED"
    set tx_pcs $pcs_datapath
    set rx_pcs ""
  }
  
  if { $pcs_dw_mode == "Double" && $prot_mode == "cpri" } {
    set byte_deser_mode "en_bds_by_2_det"
    set byte_ser_mode "en_bs_by_2"
  } elseif { $pcs_dw_mode == "Double" } {
    set byte_deser_mode "en_bds_by_2"
    set byte_ser_mode "en_bs_by_2"
  } else {
    set byte_deser_mode "dis_bds"
    set byte_ser_mode "dis_bs"
  }
  
  if { $prot_mode == "cpri" } {
    set ph_fifo_mode "register_fifo"
  } else {
    set ph_fifo_mode "low_latency"
  }
  
  set pma_dw [get_pma_dw $deser_factor $base_factor $pcs_dw_mode]
  
  if { $pma_dw == "EIGHT_BIT" } {
    set pma_mode 8
  } elseif { $pma_dw == "TEN_BIT" } {
    set pma_mode 10
  } elseif { $pma_dw == "SIXTEEN_BIT" } {
    set pma_mode 16
  } else {
    set pma_mode 20
  }
  
  if { $deser_factor == 8} {
        set pcs_width_str "WIDTH_8"
    } elseif { $deser_factor == 10} {
        set pcs_width_str "WIDTH_10"
    } elseif { $deser_factor == 16} {
        set pcs_width_str "WIDTH_16"
    } elseif { $deser_factor == 20} {
        set pcs_width_str "WIDTH_20"
    } elseif { $deser_factor == 32} {
        set pcs_width_str "WIDTH_32"
    } elseif { $deser_factor == 40} {
        set pcs_width_str "WIDTH_40"
    } elseif { $deser_factor == 50} {
        set pcs_width_str "WIDTH_50"
    } elseif { $deser_factor == 64} {
        set pcs_width_str "WIDTH_64"
    } elseif { $deser_factor == 66} {
        set pcs_width_str "WIDTH_66"
    } else {
        set pcs_width_str ""
    }
  
  #Check user data rate againts PCS data rate rule
  #Use RX rule if in RX-only mode, else use TX rule
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
    set device [::alt_xcvr::utils::device::get_typical_device $device_family]
    if {$op_mode == "Rx" || $op_mode == "RX"} {
      set return_value_PCS [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name STRATIXV_HSSI_CONFIG  -rule_name STRATIXV_HSSI_RX_PCS_DATA_RATE -param_args [list $device $output_clk_freq_int $pcs_datapath $pma_mode $prot_mode $pma_dw $pcs_bypass $byte_deser_mode $ph_fifo_mode "basic" $pma_width $pcs_width_str]]
    } else {
      set return_value_PCS [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name STRATIXV_HSSI_CONFIG  -rule_name STRATIXV_HSSI_TX_PCS_DATA_RATE -param_args [list $device $data_rate $pcs_datapath $pma_mode $prot_mode $pma_dw $pcs_bypass $byte_ser_mode $ph_fifo_mode "basic" $pcs_width_str $pma_width]]
    }
  } else {
    if {$op_mode == "Rx" || $op_mode == "RX"} {
      set return_value_PCS [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name ARRIAV_HSSI_CONFIG  -rule_name ARRIAV_HSSI_RX_PCS_DATA_RATE -param_args [list $device $rx_pcs $pma_mode "false" $prot_mode "dont_care_test" $pma_dw $pcs_bypass $ph_fifo_mode $byte_deser_mode "dis_hip"]]
    } else {
      set return_value_PCS [quartus::advanced_hssi_legality::get_advanced_hssi_legality_legal_values -flow_type MEGAWIZARD -configuration_name ARRIAV_HSSI_CONFIG  -rule_name ARRIAV_HSSI_TX_PCS_DATA_RATE -param_args [list $device $tx_pcs $pma_mode "false" $prot_mode "dont_care_test" $pma_dw $pcs_bypass $ph_fifo_mode $byte_ser_mode "dis_hip"]]
    }
  }

  #strip off {{ and }} from RBC
  set return_value_PCS [rbc_values_cleanup $return_value_PCS]
  if { [expr {![info exists return_value_PCS]}] } {
    ::alt_xcvr::gui::messages::internal_error_message "PCS data rate check returned unexpected value"
    return
  }
  
  #Check whether data rate is legal
  regexp -nocase {([0-9.]+).([a-z]+)\.+([0-9.]+).([a-z]+)(.*)} $return_value_PCS match min_rate unit_min max_rate unit_max second_range
  if { [expr {![info exists min_rate]} || {![info exists max_rate]} ] } {
    ::alt_xcvr::gui::messages::internal_error_message "PCS data rate check returned unexpected value"
    return
  }

  #ArriaV ARRIAV_HSSI_RX_PCS_DATA_RATE returns data rate in Mbps while STRATIXV_HSSI_RX_PCS_DATA_RATE returns output clock frequency in MHz
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
    if {$op_mode == "Rx" || $op_mode == "RX"} {
      set max_rate [expr $max_rate*2]
      set min_rate [expr $min_rate*2]
    }
  }  


  if { $data_rate < $min_rate || $data_rate > $max_rate } {
    set range_str "${min_rate} Mbps to ${max_rate} Mbps"

    # We add support for multiple return ranges for Cyclone V ONLY so as to limit exposure of this addition
    if { [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
      # parse remaining string for a second range
      set second_range [string replace $second_range 0 0]
      regexp -nocase {([0-9.]+).([a-z]+)\.+([0-9.]+).([a-z]+)} $second_range match min_rate2 unit_min max_rate2 unit_max third_range
      if { [expr {[info exists min_rate2] && [info exists max_rate2] } ] } {
        if {($data_rate >= $min_rate2 && $data_rate <= $max_rate2)} {
          # Don't issue a message if the value is in the second set of ranges
          return
        } else {
          set range_str "${range_str} and ${min_rate2} Mbps to ${max_rate2} Mbps"
        }
      }
    }
  
    send_message error "The allowed data rate range for this configuration is ${range_str}"
  }
}


#common processes
proc ::alt_xcvr::utils::rbc::rbc_values_cleanup { rbc_values } {
  regsub {([\{]+)} $rbc_values {} rbc_values
  regsub {([\}]+)} $rbc_values {} rbc_values
  
  return $rbc_values
}

