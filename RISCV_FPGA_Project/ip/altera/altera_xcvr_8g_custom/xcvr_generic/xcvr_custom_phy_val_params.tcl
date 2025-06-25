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


# +------------------------------------------
# | Custom PHY parameter validation functions
# +------------------------------------------

# +--------------------------------------
# | Validation for most common parameters
# | 
proc validate_common_parameters {} {
  # derive values for all string-boolean parameters
  derive_all_string_boolean_parameters

  # Get needed parameters
  set device_family         [get_parameter_value device_family]
  set op_mode               [get_parameter_value operation_mode]
  set parameter_rules       [get_parameter_value gui_parameter_rules]
  set gui_bonding_enable    [get_parameter_value gui_bonding_enable]
  set gui_bonded_mode       [get_parameter_value gui_bonded_mode]
  set lanes                 [get_parameter_value lanes]
  set data_rate             [get_parameter_value data_rate]
  set user_pcs_dw_mode      [get_parameter_value use_double_data_mode]
  set gui_pcs_pma_width     [get_parameter_value gui_pcs_pma_width]
  set use_8b10b             [get_parameter_value use_8b10b]
  set user_pll_refclk_freq  [get_parameter_value pll_refclk_freq]
  set wa_mode               [get_parameter_value word_aligner_mode]
  set sup_rm_fifo           [get_parameter_value use_rate_match_fifo]
  
  set protocol_hint [custom_map_parameter_rules_to_protocol_hint $parameter_rules]
  set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate ]
  set sup_rx [expr {$op_mode == "RX" || $op_mode == "Duplex" }]
  set sup_tx [expr {$op_mode == "TX" || $op_mode == "Duplex" }]

  # Data rate validation
  if { ![::alt_xcvr::utils::common::validate_data_rate_string $data_rate] } {
    ::alt_xcvr::gui::messages::data_rate_format_error
  }
  
  #|-------------------------------
  #| De/serialization calculations
  #|-------------------------------
  #calculate base ser factor
  set deser_factor [validate_deser_factor $parameter_rules $device_family]
  set ser_base_factor [validate_ser_base_factor $deser_factor]
  set ser_words [expr $deser_factor / $ser_base_factor]

  #|----------------
  # Validation for base data rate
  #|----------------
  set base_factor [validate_base_factor $ser_base_factor $use_8b10b]
  
  #************************
  # Validation for PLL type 
  set pll_type [validate_pll_type $device_family $sup_tx]
  
  #|----------------
  # Check whether this is an upgrade from old design with deprecated parameter
  # We only upgrade if the gui_pcs_pma_width has not been overridden with a user selected value
  # && the value of the old user_pcs_dw_mode parameter is non_default (old core)
  set deprecated_pma_width "UNUSED"
  if { $user_pcs_dw_mode != "DEPRECATED" && $gui_pcs_pma_width == "PARAM_DEFAULT" } {
    # Derive deprecated pcs_dw_mode mode parameter from deprecated user_pcs_dw_mode parameter
    set pcs_dw_mode [validate_deprecated_pcs_dw_mode $device_family $data_rate_int $ser_words $user_pcs_dw_mode ]
    # Derive deprecated pma_width from deprecated pcs_dw_mode parameter
    set deprecated_pma_width [validate_deprecated_pma_width $deser_factor $base_factor $pcs_dw_mode $data_rate_int $device_family]
    send_message info "UPGRADE: \"Datapath\" setting has been converted to \"PCS-PMA Interface Width\""
  }

  # Get new legal set
  set pma_width [validate_pma_width $deser_factor $base_factor $data_rate_int $device_family]

  ::alt_xcvr::utils::common::map_allowed_range gui_pcs_pma_width $pma_width $deprecated_pma_width
  set pcs_pma_width [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pcs_pma_width]
  
  if { $pcs_pma_width != 8 && $pcs_pma_width != 10 && $pcs_pma_width != 16 && $pcs_pma_width != 20 } {
    send_message error "Internal Error: illegal value: pcs_pma_width=$pcs_pma_width"
  }
  
  set lanes [validate_lanes $lanes $device_family]
  # Bonding options
  # Bonding only available for TX channel, not an option if creating RX-only design
  if { $gui_bonding_enable && $sup_tx == 0 } {
    send_message error "Lane bonding cannot be enabled for RX only configuration"
  }	
  validate_gui_bonded_mode $device_family $gui_bonding_enable
  validate_pma_bonding_mode $device_family $gui_bonding_enable
  set bonded_group_size [validate_bonded_group_size $gui_bonding_enable $parameter_rules $lanes]
  set bonded_mode [validate_bonded_mode $device_family $gui_bonding_enable $gui_bonded_mode $lanes $pll_type ]

  #check user data rate agants PCS data rate rules
  set pcs_dw [validate_pcs_dw $deser_factor $base_factor $data_rate_int $device_family $pcs_pma_width]
  ::alt_xcvr::utils::rbc::validate_pcs_data_rate $device_family $data_rate_int $op_mode $protocol_hint $deser_factor "EIGHT_G_PCS" $pcs_dw $base_factor "dis_pcs_bypass"
  
  set data_rate_str [validate_base_data_rate $device_family $data_rate $data_rate_int $pll_type $sup_tx]

  #|----------------
  # Validation for PLL
  #|---------------- 
  if { ![::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
    if {$data_rate_str != "N/A" && $data_rate_str != "N.A"} {
      # May return "N/A"
      if { $gui_bonding_enable == "true" && $bonded_mode == "fb_compensation" } {
        # Feedback compensation
        set result [::alt_xcvr::utils::rbc::get_valid_refclks $device_family $data_rate_str $pll_type "false" "PMA" $pcs_pma_width $data_rate]
      } else {
        # Non-feedback compensation
        set result [::alt_xcvr::utils::rbc::get_valid_refclks $device_family $data_rate_str $pll_type]
      }
    } else {
      set result "N/A"
    }
  
    ::alt_xcvr::utils::common::map_allowed_range gui_pll_refclk_freq $result
    set user_pll_refclk_freq [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_refclk_freq]
  } else {
    set user_pll_refclk_freq [get_parameter_value gui_pll_refclk_freq]
  }

  # Validate reference clock frequency
  if {$user_pll_refclk_freq == "N/A" || $user_pll_refclk_freq == "N.A"} {
    send_message error "No legal reference clock frequency could be found for the current configuration"
  }

  # Run validation of the TX PLL reconfiguration package
  if {[::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
    set max_plls [expr ($sup_tx == 1) ? 4 : 0]
    ::alt_xcvr::gui::pll_reconfig::set_config $device_family $max_plls 5 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] $sup_rx 1; # 4 PLLs, 5 refclks, types, enable rx refclk sel, enable PLL reconfig

  } elseif { [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
    set max_plls [expr ($sup_tx == 1) ? 2 : 0]
    ::alt_xcvr::gui::pll_reconfig::set_config $device_family $max_plls 5 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] $sup_rx 1; # 2 PLLs, 5 refclks, types, enable rx refclk sel, enable PLL reconfig

  } elseif { [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
    set max_plls [expr ($sup_tx == 1) ? 2 : 0]
    ::alt_xcvr::gui::pll_reconfig::set_config $device_family $max_plls 2 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] $sup_rx 1; # 2 PLLs, 2 refclks, types, enable rx refclk sel, enable PLL reconfig

  } else {
    set max_plls [expr ($sup_tx == 1) ? 1 : 0]
    ::alt_xcvr::gui::pll_reconfig::set_config $device_family $max_plls 1 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] $sup_rx; # 1 PLL, 1 refclk
  }

  ::alt_xcvr::gui::pll_reconfig::set_main_pll_settings $user_pll_refclk_freq $data_rate_str $pll_type
  ::alt_xcvr::gui::pll_reconfig::validate
  
  # Enable channel interface option only for Stratix V
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] ||  [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
    set_parameter_property channel_interface ENABLED true
  } else {
    set_parameter_property channel_interface ENABLED false
  }
  
  # disable Avalon interface option when channel interface enabled
  set sup_ch_interface [get_parameter_value channel_interface]
  if { $sup_ch_interface == 1} {
    if { [get_parameter_value gui_split_interfaces] == 1 } {
      send_message error "Avalon Data Interfaces is not supported when Channel Interface is enabled"
    }
  }
    
  
  #*******************************
  # Disable RM FIFO when not legal
  if { $sup_rm_fifo == 1 && $pcs_pma_width != 10 && $pcs_pma_width != 20 } {
    send_message error "Rate Match FIFO cannot be enabled without enabling 8B/10B"
  } elseif { $sup_rm_fifo == 1 && $pcs_pma_width == 10 && $wa_mode != "sync_state_machine" } {
    send_message error "Rate Match FIFO cannot be enabled with the chosen Word Align mode"
  } elseif { $sup_rm_fifo == 1 && $pcs_pma_width == 20 && $wa_mode != "manual"} {
    send_message error "Rate Match FIFO cannot be enabled with the chosen Word Align mode"
  } 


  #*******************************************
  # Resolve number of PLLs to pass down to RTL
  set pll_count [::alt_xcvr::gui::pll_reconfig::get_pll_count]
  if { $sup_tx == 0 } {
    set pll_count 1; #always pass at least 1
  }

  #*****************************************
  # Display reconfig interface count message
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] ||  [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
    set pll_reconfig_interfaces [expr ($sup_tx == 0) ? 0 : $pll_count]
    if { ($gui_bonding_enable == "false" || $bonded_mode == "fb_compensation") && ($sup_tx == 1) } {
      set pll_reconfig_interfaces [expr {$pll_count * $lanes}]
    }
    ::alt_xcvr::gui::messages::reconfig_interface_message $device_family $lanes $pll_reconfig_interfaces
  } 

  #*********************************************
  # Error message for bonding with multiple PLLs
  if {$gui_bonding_enable == "true" && $pll_count > 1} {
    send_message error "Lane bonding must be disabled when using multiple TX PLLs"
  }

  #************************
  # Reset parameters
  validate_embedded_reset $device_family $pll_count
  validate_manual_reset

  #***************************
  # Set derived HDL parameters
  set_parameter_value ser_words $ser_words
  set_parameter_value ser_base_factor $ser_base_factor
  set_parameter_value bonded_group_size $bonded_group_size
  set_parameter_value bonded_mode $bonded_mode
  set_parameter_value pcs_pma_width $pcs_pma_width
  set_parameter_value pll_refclk_freq   [::alt_xcvr::gui::pll_reconfig::get_refclk_freq_string]
  set_parameter_value pll_refclk_select [::alt_xcvr::gui::pll_reconfig::get_refclk_sel_string]
  set_parameter_value pll_type          [::alt_xcvr::gui::pll_reconfig::get_pll_type_string]
  set_parameter_value base_data_rate    [::alt_xcvr::gui::pll_reconfig::get_pll_data_rate_string]
  set_parameter_value pll_select        [::alt_xcvr::gui::pll_reconfig::get_main_pll_index]
  set_parameter_value pll_reconfig      [::alt_xcvr::gui::pll_reconfig::get_pll_reconfig]
  set_parameter_value pll_refclk_cnt    [::alt_xcvr::gui::pll_reconfig::get_refclk_count]
  set_parameter_value plls $pll_count

  if { [expr {$sup_rx == 1 && ( [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] ||  [::alt_xcvr::utils::device::has_c5_style_hssi $device_family])}] } {
    set_parameter_value cdr_refclk_select [::alt_xcvr::gui::pll_reconfig::get_cdr_refclk_sel]
  } else {
    set_parameter_value cdr_refclk_select 0
  }
}

# +-----------------------------------
# | Validation for management parameters (clock freq)
# | 
proc validate_mgmt {} {
  set_parameter_value mgmt_clk_in_mhz [expr [get_parameter_value gui_mgmt_clk_in_hz] / 1000000]
}

# +---------------------------------------
# | Validation for word aligner parameters
# | 
proc validate_wa_parameters {{allow_gui_control_disabling 0}} {
  
  set op_mode [get_parameter_value operation_mode]
  set deser_factor [get_parameter_value gui_deser_factor]
  set use_8b10b [get_parameter_value use_8b10b]
  set ser_base_factor [get_parameter_value ser_base_factor]
  set wa_mode [get_parameter_value word_aligner_mode]
  set parameter_rules [get_parameter_value gui_parameter_rules]
  set device_family [get_parameter_value device_family]
  set data_rate [get_parameter_value data_rate]
  set pcs_pma_width [get_parameter_value pcs_pma_width]
  set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate ]
  set base_factor [validate_base_factor $ser_base_factor $use_8b10b]
  
  set pcs_dw [validate_pcs_dw $deser_factor $base_factor $data_rate_int $device_family $pcs_pma_width]
  
  #|--------------------------
  #|word aligner auto-sync SM
  #|--------------------------
  # 3G path for low rate rates
  if { $deser_factor == 8  || $deser_factor == 10 || (($deser_factor == 16 || $deser_factor == 20) && $pcs_dw == "Double") } {
    set use_3g "true"
  } else { 
    set use_3g "false"
  }

  if { $parameter_rules == "GIGE" && $wa_mode != "sync_state_machine"} {
    send_message error "Word aligner must be configured in automatic state machine mode when using '$parameter_rules' parameter rules"
  }

  if { $wa_mode == "sync_state_machine" } {
    if { ($use_3g == "true") || ([::alt_xcvr::utils::device::has_s5_style_hssi [get_parameter_value device_family]]) } {
      # only enable ser_base_factor is 10 or 8b10b enabled
      if { ($use_8b10b == "false") && ($ser_base_factor == 8) } {
        send_message error "Automatic synchronization state machine word aligner cannot be enabled without enabling 8B/10B"
        set sup_wa_auto_sm "false"
      } else {
        set sup_wa_auto_sm "true"
      }
    } else {
      if { $deser_factor == 16 || $deser_factor == 20} {
        send_message error "Automatic synchronization state machine word aligner cannot be enabled with the selected PCS-PMA Interface Width"
        send_message info "Please switch PCS-PMA Interface Width to enable automatic synchronization state machine word aligner"
      } else {
        send_message error "Automatic synchronization state machine word aligner cannot be enabled with the selected FPGA fabric transceiver interface width ($deser_factor)"
        send_message info "Please switch to FPGA fabric transceiver interface width of 8, 10, 16 or 20 bits to enable automatic synchronization state machine word aligner"
      }
      set sup_wa_auto_sm "false"
    }
  } else { 
    set sup_wa_auto_sm "false"
  }

  common_set_parameter_group {WaAutoSm} ENABLED $sup_wa_auto_sm ;# no legality check on values, just enable/disable
  
  
  #|---------------------
  #|word aligner options
  #|---------------------

  #Create optional word aligner status port
  if {$op_mode == "TX"} {
    set allow_wa_status 0
    set sup_wa_status 0
    if {[get_parameter_value gui_use_wa_status] } {
      send_message warning "Word aligner status ports cannot be enabled in TX only mode."
    }
  } elseif { $wa_mode == "bitslip" } {
    set allow_wa_status 0
    set sup_wa_status 0
    if {[get_parameter_value gui_use_wa_status] } {
      send_message warning "Word aligner status ports cannot be enabled in current word aligner mode ($wa_mode)"
    }
  } else {
    set allow_wa_status 1
    set sup_wa_status [get_parameter_value gui_use_wa_status]
  }
  common_set_parameter_group {WaAutoSm} ENABLED [expr {$wa_mode == "sync_state_machine"} ]

  if {$allow_gui_control_disabling} {
    common_set_parameter_group {WaStatus} ENABLED $allow_wa_status
  }

  # RBC rule for basic mode is:
  #fnl_prot_mode == "basic"  ) ?
  # (
  #   (fnl_pma_dw == "eight_bit") ? ("(wa_pd_8_sw,wa_pd_16_sw,wa_pd_fixed_16_a1a2_sw)")
  #    : (fnl_pma_dw == "ten_bit") ? ("(wa_pd_7,wa_pd_10,wa_pd_fixed_7_k28p5,wa_pd_fixed_10_k28p5)")
  #      : (fnl_pma_dw == "sixteen_bit") ? ("(wa_pd_8_dw,wa_pd_16_dw,wa_pd_32,wa_pd_fixed_16_a1a2_dw,wa_pd_fixed_32_a1a1a2a2)")
  #        : ( fnl_wa_boundary_lock_ctrl != "sync_sm" ) ? ("(wa_pd_7,wa_pd_10,wa_pd_20,wa_pd_40,wa_pd_fixed_7_k28p5,wa_pd_fixed_10_k28p5)") : "(wa_pd_7,wa_pd_10,wa_pd_20,wa_pd_fixed_7_k28p5,wa_pd_fixed_10_k28p5)"
  # ) : ...other...
  
  #bitslip mode does not care about pattern length
  if { $wa_mode != "bitslip" && $op_mode != "TX"} {
    if { $parameter_rules == "GIGE" } {
      set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {7 10}
    } elseif { $deser_factor == 8 && $use_8b10b == "false" } {
      set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {8 16}
    } elseif { $deser_factor == 10 || ($deser_factor == 8 && $use_8b10b == "true") } {
      set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {7 10}
    } elseif { $deser_factor == 16 && $use_8b10b == "false" } {
      if { $pcs_dw == "Double"} {
        set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {8 16}
      } else {
        set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {8 16 32}
      }
    } elseif { $deser_factor == 20 || ($deser_factor == 16 && $use_8b10b == "true") } {
      if { $pcs_dw == "Double"} {
        set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {7 10}
      } else {
        set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {7 10 20}
      }
    } elseif { $deser_factor == 32 && $use_8b10b == "false" } {
      set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {8 16 32}
    } else {
      set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {7 10 20}
    }
  } else {
    set_parameter_property word_aligner_pattern_length ALLOWED_RANGES {7 8 10 16 20 32}
  }

  #Disable WA pattern and pattern lengh option in UI for bitslip mode
  set_parameter_property word_aligner_pattern_length ENABLED $allow_wa_status
  set_parameter_property word_align_pattern ENABLED $allow_wa_status
  
  #check whether WA pattern is matching WA pattern length 
  set wa_pat [get_parameter_value word_align_pattern]
  set wa_pat_len [get_parameter_value word_aligner_pattern_length]
  set pat_len [string length $wa_pat]
  
  if { $pat_len != $wa_pat_len } {
    send_message error "Word alignment pattern must be $wa_pat_len bits"
  }
  
  #check whether WA pattern contain illegal character
  set wa_pat_error [string match {[0-1]*} $wa_pat]
  
  if { $wa_pat_error == 0 } {
    send_message error "Word alignment pattern must not contain character other than '0' or '1'."
  }

  
  #run length
  set sup_run_length [get_parameter_value gui_enable_run_length]
  if { $op_mode == "TX" && $sup_run_length == "true"} {
    send_message warning "Run length violation checker cannot be enabled in TX only mode"
    set_parameter_property run_length_violation_checking ENABLED "false"
  } else {
    set_parameter_property run_length_violation_checking ENABLED $sup_run_length
    set run_length [get_parameter_value run_length_violation_checking]
    
    if { $sup_run_length == "true" } {
      if { $use_3g == "true" } {
        if {$use_8b10b == "true" || ($ser_base_factor == 10)} {
          set resolution 5
        } else {
          set resolution 4
        }
        set max_run_length [expr $resolution * 32]  
      } else {
        if {$use_8b10b == "true" || ($ser_base_factor == 10)} {
          set resolution 10
        } else {
          set resolution 8
        }
        set max_run_length [expr $resolution * 64]
      }

      if { $run_length > $max_run_length } {
        set run_length_overflow "true"
      } else {
        set run_length_overflow "false"
      }

      if { $run_length_overflow == "true" || $run_length % $resolution != 0 || $run_length == 0 } {
        send_message error "The valid run length is from $resolution to $max_run_length, and must be multiple of $resolution"
      }
    }
  }
  
  #check whether Rate Match pattern contain illegal character
  set rm_pat1 [get_parameter_value rate_match_pattern1]
  set rm_pat2 [get_parameter_value rate_match_pattern2]
  
  set rm_pat1_error [string match {[0-1]*} $rm_pat1]
  set rm_pat2_error [string match {[0-1]*} $rm_pat2]
  
  if { $rm_pat1_error == 0 || $rm_pat2_error == 0 } {
    send_message error "Rate match pattern must not contain character other than '0' or '1'."
  }
}


# +---------------------------------------
# | Validation for other common parameters
# | 
proc validate_optional_parameters {{allow_gui_control_disabling 0}} {
  
  set op_mode [get_parameter_value operation_mode]
  set deser_factor [get_parameter_value gui_deser_factor]
  set ser_base_factor [get_parameter_value ser_base_factor]
  set parameter_rules [get_parameter_value gui_parameter_rules]
  set device_family [get_parameter_value device_family]
  set data_rate [get_parameter_value data_rate]
  set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate ]
  set use_8b10b [get_parameter_value use_8b10b]
  set base_factor [validate_base_factor $ser_base_factor $use_8b10b]
  set pcs_pma_width [get_parameter_value pcs_pma_width]
  set wa_mode [get_parameter_value word_aligner_mode]
  
  set sup_rx [expr {$op_mode == "RX" || $op_mode == "Duplex" }]
  set sup_tx [expr {$op_mode == "TX" || $op_mode == "Duplex" }]
  
  set pcs_dw [validate_pcs_dw $deser_factor $base_factor $data_rate_int $device_family $pcs_pma_width]
  
  #|----------------
  #|8B10B options
  #|----------------
  #8B10B
  set use_8b10b [get_parameter_value use_8b10b]
  set sup_8b10b_manual [get_parameter_value use_8b10b_manual_control]
  set sup_8b10b_status [get_parameter_value gui_use_8b10b_status]
  
  if { $parameter_rules == "GIGE" && $use_8b10b == "false" } {
    send_message error "8B/10B must be enabled when using '$parameter_rules' parameter rules"
  }
  #Enable 8b10b option only when ser_base_factor = 8
  if { $ser_base_factor == 10 && $use_8b10b == "true" } {
    send_message error "8B/10B can only be enabled when FPGA fabric transceiver interface width is: 8, 16 or 32"
  } 
  if { $parameter_rules == "GIGE" && $sup_8b10b_manual == "true"} {
    send_message error "8B/10B manual control cannot be enabled when using '$parameter_rules' parameter rules"
  }
  if {$use_8b10b == "false" && $sup_8b10b_manual == "true"} {
    send_message warning "8B/10B manual control can only be enabled when the 8B/10B feature is enabled"
  }
  if {$use_8b10b == "false" && $sup_8b10b_status == "true"} {
    send_message warning "8B/10B status outputs can only be enabled when the 8B/10B feature is enabled"
  }
  
  #Enable 8b10b option only when ser_base_factor = 8
#   if { $ser_base_factor == 10 && $use_8b10b == "true" } {
#     send_message error "8B/10B can only be enabled when FPGA fabric transceiver interface width is: 8, 16 or 32"
#   }

  if { $use_8b10b == "true" && $sup_rx == 1 } {
    set sup_rx_8b10b "true"
  } else {
    set sup_rx_8b10b "false"
  }
  
  if {$allow_gui_control_disabling} {
    common_set_parameter_group {USE8B10B} ENABLED $use_8b10b
    common_set_parameter_group {USE8B10B_RX} ENABLED $sup_rx_8b10b
  }


  #|-------------------
  #|Rate match options
  #|-------------------

  
  set sup_rm_fifo [get_parameter_value use_rate_match_fifo]
  set sup_rm_fifo_status [get_parameter_value gui_use_rmfifo_status]
  
  if { $op_mode == "TX" && $sup_rm_fifo == 1 } {
    send_message warning "Rate matcher cannot be enabled in TX only mode"
  }

  if { $sup_rm_fifo == 0 && $sup_rm_fifo_status == "true" } {
    send_message warning "Rate matcher status outputs can only be enabled when the Rate matcher is enabled"
  } elseif { $op_mode == "TX" && $sup_rm_fifo_status == "true" } {
    send_message warning "Rate matcher status outputs cannot be enabled in TX only mode"
  }


  common_set_parameter_group {RmFIFO} ENABLED $sup_rm_fifo  ;# no legality check on values, just enable/disable

  
  #|-------------------
  #|Byte order options
  #|-------------------
  
  #Enable Byte Ordering option only when PCS is in DW mode
  set sup_byte_order [get_parameter_value gui_use_byte_order_block]
  set sup_byte_order_manual [get_parameter_value gui_byte_order_pld_ctrl_enable]
  
  if { $pcs_dw == "Single" && $sup_byte_order == "true" } {
    send_message error "Byte ordering cannot be enabled with the selected FPGA fabric transceiver interface width/PCS-PMA Interface Width"
  }
  
  if { $op_mode == "TX" && $sup_byte_order == "true" } {
    send_message warning "Byte ordering cannot be enabled in TX only mode"
  }
  
  if {$sup_byte_order == "false" && $sup_byte_order_manual == "true"} {
    send_message warning "Byte ordering manual control can only be enabled when the byte ordering feature is enabled"
  }
  
  if { $sup_byte_order == "true" && $wa_mode == "bitslip" && $sup_byte_order_manual != "true" } {
    send_message error "Byte ordering manual control must be enabled when Word Aligner is in Bitslip mode"
  }
  
  common_set_parameter_group {ByteOrder} ENABLED $sup_byte_order

  if {$allow_gui_control_disabling} {
    common_set_parameter_group {ByteOrder} ENABLED $sup_byte_order
  }
  
  if { $sup_byte_order == "true" } {
    if { $sup_byte_order_manual == "true" } {
      set_parameter_value byte_order_mode "PLD control"
    } else {
      set_parameter_value byte_order_mode "sync state machine"
    }
  } else {
    set_parameter_value byte_order_mode "none"
  }
    

  #|-------------------
  #| Additional options
  #|-------------------
  if {$parameter_rules == "GIGE" && [get_parameter_value tx_bitslip_enable] == "true"} {
    send_message error "TX bitslip is not supported using '$parameter_rules' parameter validation rules"
  }
  if {$sup_tx == 0 && [get_parameter_value tx_bitslip_enable] == "true"} {
    send_message warning "TX bitlip is not supported on RX-only channels"
  }
  if {$sup_tx == 0 && [get_parameter_value tx_use_coreclk] == "true"} {
    send_message warning "tx_coreclkin is not supported on RX-only channels"
  }
  if {$sup_rx == 0 && [get_parameter_value rx_use_coreclk] == "true"} {
    send_message warning "rx_coreclkin is not supported on TX-only channels"
  }
  if {$sup_rx == 0 && [get_parameter_value gui_rx_use_recovered_clk] == "true"} {
    send_message warning "rx_recovered_clk is not supported on TX-only channels"
  } elseif { [get_parameter_value gui_rx_use_recovered_clk] == "true"} {
    send_message info "rx_recovered_clk should not be used to clock RX datapath. Use rx_clkout or rx_coreclkin"
  }
  

  #|----------------------------------------------------------
  #| Bulk disable all RX/TX options when channel not enabled
  #|----------------------------------------------------------
  
  if {$allow_gui_control_disabling} {
    common_set_parameter_group {TX} ENABLED $sup_tx
    common_set_parameter_group {RX} ENABLED $sup_rx
  }
}
  

# +-----------------------------------
# | Validation for S4-generation parameters
# | 
proc validate_s4_constraints {} {
  set lanes [get_parameter_value lanes]
  set gui_bonding_enable [get_parameter_value gui_bonding_enable]

  # enable S4 analog params
  common_set_parameter_group {S4} VISIBLE true
  set_display_item_property "Analog Options" VISIBLE true

  if { $lanes != 4 && $lanes != 8 && $gui_bonding_enable == "true" } {
    send_message error "Bonding is only supported when number of lane is 4 or 8"
  }
}


# +-----------------------------------
# | Validation for S5-generation parameters
# | 
proc validate_s5_constraints {} {
  # hide S4 analog params
  common_set_parameter_group {S4} VISIBLE false
  set_display_item_property "Analog Options" VISIBLE false
}


# +------------------------------------------------
# | Map Custom PHY parameter rules to protocol_hint
# |
proc custom_map_parameter_rules_to_protocol_hint {parameter_rules} {
  # NOTE - Current implementation for Stratix V only
  set protocol_hint ""
  if { $parameter_rules == "Custom" } {
    set protocol_hint "basic"
  } elseif { $parameter_rules == "GIGE" } {
    set protocol_hint "gige"
  } else {
    set protocol_hint "basic"
  }

  set_parameter_value protocol_hint $protocol_hint
  return $protocol_hint
}

proc validate_deser_factor { parameter_rules device_family} {
  if { $parameter_rules == "GIGE" } {
    if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
      set_parameter_property gui_deser_factor ALLOWED_RANGES {8 16}
    } else {
      set_parameter_property gui_deser_factor ALLOWED_RANGES { 8 }
    }
  } else {
    set_parameter_property gui_deser_factor ALLOWED_RANGES {8 10 16 20 32 40}
    #::alt_xcvr::utils::common::map_allowed_range gui_deser_factor {8 10 16 20 32 40}
  }
    return [get_parameter_value gui_deser_factor]
    #return [alt_xcvr::utils::common::get_mapped_allowed_range_value gui_deser_factor]
}

proc validate_pll_type { device_family {sup_tx 1} } {
  set gui_pll_type [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 
  # For SV RX only mode remove ATX PLL option
  if { !$sup_tx  && [::alt_xcvr::utils::device::has_s5_style_hssi $device_family]} {
    set index [lsearch $gui_pll_type [::alt_xcvr::utils::device::get_atx_pll_name]] 
    set gui_pll_type [lreplace $gui_pll_type $index $index]
  }
  ::alt_xcvr::utils::common::map_allowed_range gui_pll_type $gui_pll_type

  if { $sup_tx } {
    set_parameter_property gui_pll_type ENABLED true
  } else {
    set_parameter_property gui_pll_type ENABLED false
  }

  return [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_type]
}

proc validate_base_data_rate { device_family data_rate data_rate_int pll_type sup_tx } {
  if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] || !$sup_tx} {
    lappend base_data_rate_list "${data_rate_int} Mbps"
  } else {
  set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $device_family $data_rate $pll_type]
  if { [llength $base_data_rate_list] == 0 } {
      set base_data_rate_list {"N/A"}
      send_message error "Data rate chosen is not supported or is incompatible with selected PLL type"
    }
  }
  
  ::alt_xcvr::utils::common::map_allowed_range gui_base_data_rate $base_data_rate_list

  if {$sup_tx} {
    set_parameter_property gui_base_data_rate ENABLED true
  } else {
    set_parameter_property gui_base_data_rate ENABLED false
  }

  return  [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_base_data_rate]
}

proc validate_deprecated_pcs_dw_mode { device_family data_rate_int ser_words user_pcs_dw_mode } {
  if { $ser_words == 1 } {
    set pcs_dw_mode "Single"  ;# 1 word (8 or 10) always single-width, in PCS and PMA
  } elseif { $ser_words == 4 } {
    set pcs_dw_mode "Double"  ;# 4 words (32 or 40) always double-width, in PCS and PMA
  } elseif { ($ser_words == 2 && $data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
    set pcs_dw_mode "Double"  ;# 2 words with 3G mode (single-w PMA) must have double-width PCS
  } elseif { $ser_words == 2 && $data_rate_int >= 3750} {
    set pcs_dw_mode "Single"  ;# 2 words with 6G mode (double-w PMA) must have single-width PCS
  } elseif { $user_pcs_dw_mode == "false" } {
    set pcs_dw_mode "Single"  ;# user prefers single-w PCS
  } else {
    set pcs_dw_mode "Double"  ;# 2 words with eiher 3G or 6G mode, default to (single-w PMA, double-width PCS)
  }

  return $pcs_dw_mode
}

proc validate_deprecated_pma_width { deser_factor base_factor pcs_dw_mode data_rate_int device_family } {
  
  #calculate pma_width
  if { ($deser_factor == 8 && $base_factor == 8) } {
    set pma_width 8
  } elseif { $deser_factor == 16 && $base_factor == 8 && ($pcs_dw_mode == "Double" || $data_rate_int <= 1000 || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family]) }  {
    set pma_width 8
  } elseif { $deser_factor == 10 ||  $deser_factor == 8 && $base_factor == 10 }  { 
    set pma_width 10
  } elseif { ($deser_factor == 20 || $deser_factor == 16 && $base_factor == 10) && ($pcs_dw_mode == "Double" || $data_rate_int <= 1000 || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family]) }  {
    set pma_width 10
  } elseif { ($deser_factor == 16 || $deser_factor == 32) && $base_factor == 8 } {
    set pma_width 16
  } else {
    set pma_width 20
  }
  
  return $pma_width
}

proc validate_base_factor { ser_base_factor use_8b10b } {
  if { $ser_base_factor == 8 && $use_8b10b == "false" } {
    set base_factor 8
  } else {
    set base_factor 10
  }
  
  return $base_factor
}

proc validate_ser_base_factor { deser_factor } {
  if { [ expr $deser_factor % 10 ] == 0 } {
    set ser_base_factor 10
  } else {
    set ser_base_factor 8
  }
  return $ser_base_factor
}

proc validate_pma_width { deser_factor base_factor data_rate_int device_family } {
  if { $deser_factor == 8 && $base_factor == 8 }  {
    set pma_width 8
  } elseif { $deser_factor == 10 || ($deser_factor == 8 && $base_factor == 10) } {
    set pma_width 10
  } elseif { $deser_factor == 16 && $base_factor == 8 } {
    if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family]} {
      set pma_width 8
    } else {
      set pma_width {8 16}
    }
  } elseif { ($deser_factor == 16 && $base_factor == 10) || $deser_factor == 20 } {
    if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
      set pma_width 10
    } else {
      set pma_width {10 20}
    }
  } elseif { $deser_factor == 32 } {
    if { $base_factor == 8 } {
      set pma_width 16
    } else {
      set pma_width 20
    }
  } elseif { $deser_factor == 40 } {
    set pma_width 20
  } else {
    set pma_width "N/A"
    send_message error "Internal Error: illegal value: pma_width=$pma_width"
  }
  
  return $pma_width
}

proc validate_pcs_dw { deser_factor base_factor data_rate_int device_family pcs_pma_width} {
    set pcs_dw "Single"
   
    if { $deser_factor == 16 && $base_factor == 8 } {
      if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family]} {
        set pcs_dw "Double"
      } elseif { $pcs_pma_width == 8 } {
        set pcs_dw "Double"
      }
    } elseif { ($deser_factor == 16 && $base_factor == 10) || $deser_factor == 20 } {
      if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family]} {
        set pcs_dw "Double"
      } elseif { $pcs_pma_width == 10 } {
        set pcs_dw "Double"
      }
    } elseif { $deser_factor == 32 } {
      set pcs_dw "Double"
    } elseif { $deser_factor == 40 } {
      set pcs_dw "Double"
    }
    
    return $pcs_dw
}

###
# Validation for "embedded_reset" parameter
#
# @param - device_family - Current selected device family
# @param - pll_count - Current configured number of TX plls for reconfiguration
proc validate_embedded_reset { device_family pll_count } {
  set gui_embedded_reset [get_parameter_value gui_embedded_reset]

  # Support for embedded reset removal in SV only.
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
    # Embedded reset prohibited with multiple PLLs
    if { $gui_embedded_reset == 1 && $pll_count > 1 } {
      send_message error "Embedded reset controller must be disabled when using multiple TX PLLs."
    }
    set_parameter_value embedded_reset $gui_embedded_reset
  } else {
    # Embedded reset required for other familes
    set_parameter_property gui_embedded_reset VISIBLE false
    set_parameter_value embedded_reset 1
  }
}


###
# Validation for deprecated manual_reset parameter
proc validate_manual_reset {} {
  set manual_reset [get_parameter_value manual_reset]
  if { $manual_reset == "true" } {
    send_message warning "UPGRADE: \"Force manual reset\" option is no longer available."
  }
}


###
# Validation for "bonded_group_size" parameter
#
# @param - gui_bonding_enable - Resolved value of "gui_bonding_enable" parameter
# @param - parameter_rules - Resolved value of "parameter_rules" parameter
proc validate_bonded_group_size { gui_bonding_enable parameter_rules lanes } {
  #Set bonded_group_size to number of lanes when bonding is enabled
  
  set bonded_group_size 1
  if { $gui_bonding_enable } {
    if { $parameter_rules == "GIGE" } {
      send_message error "Lane bonding cannot be enabled when using the '$parameter_rules' parameter rules"
    }
    set bonded_group_size $lanes
  }
  return $bonded_group_size
}


###
# Validation for "gui_bonded_mode" parameter
#
# @param - device_family - Current selected device family
# @param - gui_bonding_enable - Resolved value of "gui_bonding_enable" parameter
proc validate_gui_bonded_mode { device_family gui_bonding_enable } {
  set allowed_ranges {"xN" "fb_compensation"}
  if { $gui_bonding_enable } {
    if { ![::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
      set allowed_ranges {"xN"}
    }
    if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
      set visible true
    } else {
      set visible false
    }
  } else {
    set visible false
  }

  set_parameter_property gui_bonded_mode ALLOWED_RANGES $allowed_ranges
  set_parameter_property gui_bonded_mode VISIBLE $visible

}

###
# Validation for "bonded_mode" parameter
#
# @param - device_family - Current selected device family
# @param - gui_bonding_enable - Resolved value of "gui_bonding_enable" parameter
# @param - gui_bonded_mode - Resolved value of "gui_bonded_mode" parameter
# @param - lanes - Current value of the "lanes" parameter
# @param - pll_type - Resolved value of "pll_type" parameter
proc validate_bonded_mode { device_family gui_bonding_enable gui_bonded_mode lanes pll_type} {
  # bonded_mode
  set bonded_mode "xN"
  if { $gui_bonding_enable && $gui_bonded_mode == "fb_compensation"} {
    set bonded_mode "fb_compensation"
  }

  # Max lanes messages
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
    if { $gui_bonding_enable == "true" } {
      if { $bonded_mode != "fb_compensation" } {
        # xN Bonding
        if { $lanes > 6 } {
          send_message error "\"xN\" bonding supports a maximum of 6 lanes"
        } elseif { $lanes > 4 && $pll_type != [::alt_xcvr::utils::device::get_atx_pll_name] } {
          send_message error "\"xN\" bonding greater than 4 lanes requires \"ATX\" PLL type"
        }
      }
    }
  } 

  return $bonded_mode
}

###
# Validation for "pma_bonding_mode" parameter
#
# @param - device_family - Current selected device family
# @param - pma_bonding_mode - Resolved value of "pma_bonding_mode" parameter
proc validate_pma_bonding_mode { device_family gui_bonding_enable } {
  set op_mode [get_parameter_value operation_mode]
  set sup_tx  [expr {$op_mode == "TX" || $op_mode == "Duplex" }]
  
  set allowed_ranges {"x1" "xN"}
  
  if { [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family]} {
    set visible true
	# PMA bonding only apply for TX channel
	if { $sup_tx == 0 } {
	  set_parameter_property gui_pma_bonding_mode ENABLED false
	} else {
	  set_parameter_property gui_pma_bonding_mode ENABLED true
	}
	
    if { $gui_bonding_enable } {
      set allowed_ranges {"xN"}
    } 
  } else {
    set visible false
  }

  ::alt_xcvr::utils::common::map_allowed_range gui_pma_bonding_mode $allowed_ranges
  set_parameter_property gui_pma_bonding_mode VISIBLE $visible
  
  set pma_bonded_mode [get_parameter_value gui_pma_bonding_mode]
  
  if { [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] && ($sup_tx == 1) } {
    if { $pma_bonded_mode == "x1" } {
      send_message info "The chosen PMA Bonding mode only allows the TX PLL to be placed within six-pack"
    } else {
      send_message info "The chosen PMA Bonding mode allows the TX PLL to be placed within or out of six-pack"
    }
  }
  
  if { $gui_bonding_enable && ([get_parameter_value bonded_group_size] != 1) } {
    set_parameter_value pma_bonding_mode "xN"
  } else {
    set_parameter_value pma_bonding_mode $pma_bonded_mode
  }
}

###
# Validation for "lanes" parameter
#
# @param - lanes - Current value of the "lanes" parameter
# @param - device_family - Current selected device family
proc validate_lanes { lanes device_family } {
  # Max lanes calculations
  set max_lanes [::alt_xcvr::utils::device::get_device_family_max_channels $device_family]
  # PHY IP CSR supports maximum of 32 channels
  if { $max_lanes > 32 } {
    set max_lanes 32
  }
  set_parameter_property lanes ALLOWED_RANGES 1:$max_lanes

  return $lanes
}

