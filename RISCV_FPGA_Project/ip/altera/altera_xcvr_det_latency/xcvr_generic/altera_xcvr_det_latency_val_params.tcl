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
source ../../altera_xcvr_8g_custom/xcvr_generic/xcvr_custom_phy_val_params.tcl


# +--------------------------------------
# | Validation for most common parameters
# | 
proc detlat_validate_common_parameters {} {
  # derive values for all string-boolean parameters
  derive_all_string_boolean_parameters

  # Get needed parameters
  set device_family         [get_parameter_value device_family]
  set op_mode               [get_parameter_value operation_mode]
  set parameter_rules       "CPRI"
  set lanes                 [get_parameter_value lanes]
  set data_rate             [get_parameter_value data_rate]
  set user_pcs_dw_mode      [get_parameter_value use_double_data_mode]
  set gui_pcs_pma_width     [get_parameter_value gui_pcs_pma_width]
  set user_pll_refclk_freq  [get_parameter_value pll_refclk_freq]

  #|-------------------------------
  #| De/serialization calculations
  #|-------------------------------
	set deser_factor          [get_parameter_value gui_deser_factor]  
  set ser_base_factor       [validate_ser_base_factor $deser_factor]
  set ser_words             [expr $deser_factor / $ser_base_factor]

  if {$ser_base_factor == 8} {
  	set use_8b10b "true"
  } else {
  	set use_8b10b "false"
  }

  
#  Need to update the xcvr_custom_phy_val_params.tcl
#  set protocol_hint [custom_map_parameter_rules_to_protocol_hint $parameter_rules]
  set protocol_hint "cpri"
  set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate ]
  set sup_rx [expr {$op_mode == "RX" || $op_mode == "Duplex" }]
  set sup_tx [expr {$op_mode == "TX" || $op_mode == "Duplex" }]

  # Data rate validation
  if { ![::alt_xcvr::utils::common::validate_data_rate_string $data_rate] } {
    ::alt_xcvr::gui::messages::data_rate_format_error
  }

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
  
  #|-------------------------------
  #| Maximum lanes calculations
  #|
  set lanes [validate_lanes $lanes $device_family]

  #check user data rate agants PCS data rate rules
  set pcs_dw [validate_pcs_dw $deser_factor $base_factor $data_rate_int $device_family $pcs_pma_width]
  ::alt_xcvr::utils::rbc::validate_pcs_data_rate $device_family $data_rate_int $op_mode $protocol_hint $deser_factor "EIGHT_G_PCS" $pcs_dw $base_factor "dis_pcs_bypass"
  
  if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
    lappend base_data_rate_list "${data_rate_int} Mbps"
  } else {
  set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $device_family $data_rate $pll_type]
  if { [llength $base_data_rate_list] == 0 } {
      set base_data_rate_list {"N/A"}
      send_message error "Data rate chosen is not supported or is incompatible with selected PLL type"
    }
  }
  
  ::alt_xcvr::utils::common::map_allowed_range gui_base_data_rate $base_data_rate_list
  set data_rate_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_base_data_rate]

  #|----------------
  # Validation for PLL
  #|---------------- 
  if { ![::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
    if {$data_rate_str != "N/A" && $data_rate_str != "N.A"} {
      # May return "N/A"
      set result [::alt_xcvr::utils::rbc::get_valid_refclks $device_family $data_rate_str $pll_type]
    } else {
      set result "N/A"
    }
  
    ::alt_xcvr::utils::common::map_allowed_range gui_pll_refclk_freq $result
    set user_pll_refclk_freq [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_refclk_freq]
  } else {
    set user_pll_refclk_freq [get_parameter_value gui_pll_refclk_freq]
  }


  # Run validation of the TX PLL reconfiguration package
  if [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] {
    set max_plls [expr ($sup_tx == 1) ? 4 : 0]
    ::alt_xcvr::gui::pll_reconfig::set_config $device_family $max_plls 5 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] $sup_rx 1; # 4 PLLs, 5 refclks, types, enable rx refclk sel, enable PLL reconfig
  } else {
    set max_plls [expr ($sup_tx == 1) ? 2 : 0]
    ::alt_xcvr::gui::pll_reconfig::set_config $device_family $max_plls 2 [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] $sup_rx 1; # 2 PLLs, 2 refclks, types, enable rx refclk sel, enable PLL reconfig
  }


  ::alt_xcvr::gui::pll_reconfig::set_main_pll_settings $user_pll_refclk_freq $data_rate_str $pll_type
  ::alt_xcvr::gui::pll_reconfig::validate
  
  # Enable channel interface option only for Stratix V
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] }  {
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
    
  #*******************************************
  # Resolve number of PLLs to pass down to RTL
  set pll_count [::alt_xcvr::gui::pll_reconfig::get_pll_count]
  if { $sup_tx == 0 } {
    set pll_count 1; #always pass at least 1
  }

  #*****************************************
  # Display reconfig interface count message
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
    set pll_reconfig_interfaces [expr ($sup_tx == 0) ? 0 : [expr {$pll_count * $lanes}]]
    ::alt_xcvr::gui::messages::reconfig_interface_message $device_family $lanes $pll_reconfig_interfaces
  }

  #************************
  # Reset parameters
  validate_embedded_reset $device_family $pll_count
  validate_manual_reset

  #***************************
  # Set derived HDL parameters
  set_parameter_value ser_words $ser_words
  set_parameter_value ser_base_factor $ser_base_factor
  set_parameter_value pcs_pma_width $pcs_pma_width
  set_parameter_value pll_refclk_freq   [::alt_xcvr::gui::pll_reconfig::get_refclk_freq_string]
  set_parameter_value pll_refclk_select [::alt_xcvr::gui::pll_reconfig::get_refclk_sel_string]
  set_parameter_value pll_type          [::alt_xcvr::gui::pll_reconfig::get_pll_type_string]
  set_parameter_value base_data_rate    [::alt_xcvr::gui::pll_reconfig::get_pll_data_rate_string]
  set_parameter_value pll_select        [::alt_xcvr::gui::pll_reconfig::get_main_pll_index]
  set_parameter_value pll_reconfig      [::alt_xcvr::gui::pll_reconfig::get_pll_reconfig]
  set_parameter_value pll_refclk_cnt    [::alt_xcvr::gui::pll_reconfig::get_refclk_count]
  set_parameter_value plls $pll_count

  if { [expr {$sup_rx == 1 && ( [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] || [::alt_xcvr::utils::device::has_c5_style_hssi $device_family])}] } {
    set_parameter_value cdr_refclk_select [::alt_xcvr::gui::pll_reconfig::get_cdr_refclk_sel]
  } else {
    set_parameter_value cdr_refclk_select 0
  }
}


# +---------------------------------------
# | Validation for word aligner parameters
# | 
proc detlat_validate_wa_parameters {{allow_gui_control_disabling 0}} {
	
  set op_mode [get_parameter_value operation_mode]
  set deser_factor [get_parameter_value gui_deser_factor]
  set ser_base_factor [get_parameter_value ser_base_factor]
  set wa_mode [get_parameter_value word_aligner_mode]
  set dev_family [get_parameter_value device_family]
  set data_rate [get_parameter_value data_rate]
  set pcs_pma_width [get_parameter_value pcs_pma_width]
  set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate ]

  if {$ser_base_factor == 8} {
  	set use_8b10b "true"
  } else {
  	set use_8b10b "false"
  }

  set base_factor [validate_base_factor $ser_base_factor $use_8b10b]
  
  set pcs_dw [validate_pcs_dw $deser_factor $base_factor $data_rate_int $dev_family $pcs_pma_width]

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
	} else {
    set allow_wa_status 1
		set sup_wa_status [get_parameter_value gui_use_wa_status]
  }

	if {$allow_gui_control_disabling} {
		common_set_parameter_group {WaStatus} ENABLED $allow_wa_status
	}

	#run length
	set sup_run_length [get_parameter_value gui_enable_run_length]
  if { $op_mode == "TX" && $sup_run_length == "true"} {
		send_message warning "Run length violation checker cannot be enabled in TX only mode"
    set_parameter_property run_length_violation_checking ENABLED "false"
  } else {
	  set_parameter_property run_length_violation_checking ENABLED $sup_run_length
  }
  # 3G path for low rate rates
  if { $deser_factor == 8  || $deser_factor == 10 || (($deser_factor == 16 || $deser_factor == 20) && $pcs_dw == "Double") } {
    set use_3g "true"
  } else { 
    set use_3g "false"
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
}


# +---------------------------------------
# | Validation for other common parameters
# | 
proc detlat_validate_optional_parameters {{allow_gui_control_disabling 0}} {
	
	set op_mode [get_parameter_value operation_mode]
	set deser_factor [get_parameter_value gui_deser_factor]
	set ser_base_factor [get_parameter_value ser_base_factor]
	
	set sup_rx [expr {$op_mode == "RX" || $op_mode == "Duplex" }]
	set sup_tx [expr {$op_mode == "TX" || $op_mode == "Duplex" }]
	
	#|----------------
	#|8B10B options
	#|----------------
	#8B10B
	if { $ser_base_factor == 8 && $sup_rx == 1 } {
		set sup_rx_8b10b "true"
	} else {
		set sup_rx_8b10b "false"
	}
	
	if {$allow_gui_control_disabling} {
		common_set_parameter_group {USE8B10B_RX} ENABLED $sup_rx_8b10b
	}

	#|-------------------
	#| Additional options
	#|-------------------
	set word_aligner_mode    [get_parameter_value word_aligner_mode]
  set tx_bitslip_enable_en [get_parameter_value gui_tx_bitslip_enable]

	if { $sup_tx == 1 } {
	  if { $tx_bitslip_enable_en == "false" } {
	  	if {$word_aligner_mode!="manual"} {
			  set_parameter_value tx_bitslip_enable "false"
	  	} else {
				send_message error "Please enable Tx bitslip for manual mode."
	  	}
		} else {
		  set_parameter_value tx_bitslip_enable "true"
		}
	} else {
		  set_parameter_value tx_bitslip_enable "false"
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
# | Validation for pll_feedback_path parameters
# | 
proc detlat_validate_pll_feedback_path {} {
  set pll_refclk_freq [::alt_xcvr::utils::common::get_freq_in_mhz [get_parameter_value pll_refclk_freq]]
	set data_rate_int   [::alt_xcvr::utils::common::get_data_rate_in_mbps [get_parameter_value data_rate]]
	set dev_family      [get_parameter_value device_family]
	set base_data_rate  [::alt_xcvr::utils::common::get_data_rate_in_mbps [get_parameter_value base_data_rate]]
	set lanes           [get_parameter_value lanes]
  set op_mode         [get_parameter_value operation_mode]
  set plls            [get_parameter_value plls]
  set parameter_rules       "CPRI"

	set deser_factor    [get_parameter_value gui_deser_factor]
  set ser_base_factor [get_parameter_value ser_base_factor]

  if {$ser_base_factor == 8} {
  	set use_8b10b "true"
  } else {
  	set use_8b10b "false"
  }
  
  set base_factor [validate_base_factor $ser_base_factor $use_8b10b]
	
  set pcs_pma_width [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pcs_pma_width]
  set pcs_dw [validate_pcs_dw $deser_factor $base_factor $data_rate_int $dev_family $pcs_pma_width]

	#calculate pma_width
	if { ($deser_factor == 10||$deser_factor == 8) || (($deser_factor == 20||$deser_factor == 16) && $pcs_dw == "Double") }  {
		set clkdiv_tx_div 5 ;#PMA Single word
	} else {
		set clkdiv_tx_div 10 ;#PMA Double word
	}
	
	if {$pcs_dw=="Single"} {
		set pcs_byte_ser 1
	} else {
		set pcs_byte_ser 2
	}
	
	set clkdiv_tx_freq [expr $data_rate_int/(2.0*$clkdiv_tx_div)]
	set tx_clkout_freq [expr $clkdiv_tx_freq/$pcs_byte_ser]

  if { $pll_refclk_freq == $tx_clkout_freq } {
   set en_pllfeedback "true"
  } else {
   set en_pllfeedback "false"
  }
	
  set pll_feedback_path_en [get_parameter_value gui_pll_feedback_path]

  if { $pll_feedback_path_en == "true" } {
  	if { $op_mode=="RX" } {
			send_message error "RX only does not support tx_clkout feedback."
  	}
  	if {$plls!=1} {
			send_message error "tx_clkout feedback is only supported when using a single TX PLL instance. You cannot use tx_clockout feedback for designs including multiple TX PLLs."
  	}
  	if {$lanes!=1} {
			send_message error "tx_clkout feedback is only supported when using a single lane instance."
  	}
  	if {$pll_refclk_freq!=$tx_clkout_freq} {
			send_message error "Selected input clock frequency cannot support tx_clkout feedback. Please make sure input clock frequency is identical to tx_clkout."
			send_message error "The input clock frequency that can support tx_clkout feedback for your setting is $tx_clkout_freq MHz."
  	}
  	if {$base_data_rate!=$data_rate_int} {
			send_message error "tx_clkout feedback is only available when the base data rate equals the data rate."
  	}
  	if {$pll_refclk_freq==$tx_clkout_freq && $base_data_rate==$data_rate_int && $lanes==1} {
		  set_parameter_value pll_feedback_path "tx_clkout"
  	} else {
			send_message error "Tx_clkout feedback feature is invalid for your setting."
  	}
	} else {
	  set_parameter_value pll_feedback_path "no_compensation"
	}
}
