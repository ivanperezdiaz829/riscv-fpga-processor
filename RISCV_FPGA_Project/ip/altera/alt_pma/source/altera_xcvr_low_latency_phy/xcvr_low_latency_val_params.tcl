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
# | $Header: //acds/rel/13.1/ip/alt_pma/source/altera_xcvr_low_latency_phy/xcvr_low_latency_val_params.tcl#1 $
# +------------------------------------------

# +--------------------------------------
# | Validation for most common parameters
# | 
set is_11_0_upgrade 1
proc validate_common_parameters {} {

    set dev_family              [get_parameter_value device_family]
    set data_rate               [get_parameter_value data_rate]
    set gui_data_path_type      [get_parameter_value gui_data_path_type]
    set op_mode                 [get_parameter_value operation_mode]
    set user_pcs_dw_mode        [get_parameter_value use_double_data_mode]
    set gui_pma_width           [get_parameter_value gui_pma_width]
    set sup_bonding             [get_parameter_value gui_bonding_enable]
    set gui_bonded_mode         [get_parameter_value gui_bonded_mode]
    set num_chs                 [get_parameter_value lanes]
    set ser_factor              [get_parameter_value gui_serialization_factor]
    set serialization_factor    [get_parameter_value serialization_factor]
    set deprecated_select_10g   [get_parameter_value gui_select_10g_pcs]
    set data_rate_int           [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate ]
    
    set sup_rx      [expr {$op_mode == "RX" || $op_mode == "DUPLEX" }]
    set sup_tx      [expr {$op_mode == "TX" || $op_mode == "DUPLEX" }]

    # Data rate validation
    if { ![::alt_xcvr::utils::common::validate_data_rate_string $data_rate] } {
      ::alt_xcvr::gui::messages::data_rate_format_error
    }
    
    # If "serialization_factor" parameter is non-zero (default) the first time through validation,
    # this core is being upgraded from an 11.0 or prior version which is not supported.
    global is_11_0_upgrade
    if { $serialization_factor == 0 } {
      set is_11_0_upgrade 0 
    }

    if { $is_11_0_upgrade == 1 } {
      send_message warning "Upgrade from Low Latency PHY 11.0 is not supported. Please create a new IP variant."
    }

    #In 11.0Sp2 and before, only serialization_factor parameter is exposed
    #In 11.1 onwards, another gui_serialization_factor is added
    # This one for backward compatibility
    # New IP instance with new parameter gui_data_path_type
    set map_value "NO_MAP_VALUE"
    if { $deprecated_select_10g != "DEPRECATED" && $gui_data_path_type == "PARAM_MAPPED" } {
        # serialization_factor was non-derived in previous versions
        if { $deprecated_select_10g == 1 || $serialization_factor == 50 || $serialization_factor == 64 || $serialization_factor == 66 } {
            set map_value "10G"
        } else {
            set map_value "Standard"
        }
        #send_message info "UPGRADE: \"Select 10-Gbps datapath\" setting has been converted to \"Data path type\""
        send_message warning "Upgrade from Low Latency PHY 11.0 is not supported. Please create a new IP variant."
    } else {
        #To handle backward compatibility
        #8G, ATT are used in 11.0SP2, and we need to change to Standard, GT (SPR 384011)
        #8G is used in HDL while Standard is used in GUI display
        #ATT is used in HDL while GT is used in GUI display
        if { $gui_data_path_type == "8G" } {
            set map_value "Standard"
        } elseif { $gui_data_path_type == "ATT" } {
            set map_value "GT"
        } elseif { $gui_data_path_type == "10G" } {
            set map_value "10G"
        }
    }
	
	if [::alt_xcvr::utils::device::has_a5gz_style_hssi $dev_family] {
	  set data_path_value { "Standard" "10G" }
	} else {
	  set data_path_value { "Standard" "10G" "GT" }
	}
	
	
    ::alt_xcvr::utils::common::map_allowed_range gui_data_path_type $data_path_value $map_value
    set hdl_data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]
    
    # derive values for all string-boolean parameters
    derive_all_string_boolean_parameters
    
    if { $hdl_data_path_type == "ATT" } {
        send_message info "GT channel only support data rate between 20G and 28G, 4 channels, no bonding and a fixed data path width of 128-bit"
    }
    
    #Validation for serialization factor
    set gui_serialization_factor_allowed {8 10 16 20 32 40}
    if { ![::alt_xcvr::utils::device::has_s4_style_hssi $dev_family] } {
      if { $hdl_data_path_type == "ATT" } {
        set gui_serialization_factor_allowed {128}
      } elseif { $hdl_data_path_type == "10G" } {
        set gui_serialization_factor_allowed {32 40 50 64 66}
      }
    }

    # If the old "serialization_factor" parameter is non-zero, we will use it as the mapped value    
    ::alt_xcvr::utils::common::map_allowed_range gui_serialization_factor $gui_serialization_factor_allowed $serialization_factor
    set ser_factor [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_serialization_factor]

    set ser_factor_validation [validate_serialization_factor $hdl_data_path_type $ser_factor $dev_family "true"]

    #|-------------------------------
    #| De/serialization calculations
    #|-------------------------------
    #calculate base ser factor
    
    #send_message info "ser_factor is $ser_factor"
    if { [ expr $ser_factor % 10 ] == 0 } {
        set ser_base_factor 10
    } else {
        set ser_base_factor 8
    }
    set ser_words [expr $ser_factor / $ser_base_factor]

    #|----------------
    # Check whether this is an upgrade from old design with deprecated parameter
    #|----------------
    set deprecated_pma_width "NO_MAP_VALUE" 
    if { $user_pcs_dw_mode != "DEPRECATED" && $gui_pma_width == "PARAM_DEFAULT" } {
      # Derive deprecated pcs_dw_mode mode parameter from deprecated user_pcs_dw_mode parameter
      set pcs_dw_mode [validate_deprecated_pcs_dw_mode $dev_family $data_rate_int $ser_words $user_pcs_dw_mode ]
      # Derive deprecated pma_width from deprecated pcs_dw_mode parameter
      set deprecated_pma_width [validate_deprecated_pma_width $hdl_data_path_type $ser_factor $ser_base_factor $pcs_dw_mode $data_rate_int $dev_family]
      send_message info "UPGRADE: \"Datapath\" setting has been converted to \"PCS-PMA Interface Width\""
    }

    # Get new legal set
    set pma_width [validate_pma_width $hdl_data_path_type $ser_factor $ser_base_factor $data_rate_int $dev_family]
    
    ::alt_xcvr::utils::common::map_allowed_range gui_pma_width $pma_width $deprecated_pma_width
    set pcs_pma_width [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pma_width]

    set pcs_dw [validate_pcs_dw $pcs_pma_width $ser_factor $ser_base_factor $data_rate_int $dev_family]


    set pll_type [validate_pll_type $dev_family]
    if {($hdl_data_path_type == "ATT") && ($pll_type != "ATX")} {
        send_message error "GT datapath can only use ATX PLL."
    }
    
    #|----------------
    #| Bonding options
    #|----------------

    # gui_bonded_mode
    set visible false
    if { $sup_bonding == 1 } {
      if { [::alt_xcvr::utils::device::has_s5_style_hssi $dev_family] } {
        set visible true
      }
    }
    set_parameter_property gui_bonded_mode VISIBLE $visible

    # bonded_group_size 
    #Set bonded_group_size to number of lanes when bonding is enabled
    if { $sup_bonding == 1 } {
        set_parameter_value bonded_group_size $num_chs
    } else {
        set_parameter_value bonded_group_size 1
    }

    # Default bonded mode
    if { $sup_bonding == 1 } {
      set gui_bonding_enable "true"
    } else {
      set gui_bonding_enable "false"
    }
    set bonded_mode [validate_bonded_mode $dev_family $gui_bonding_enable $gui_bonded_mode $num_chs $pll_type]
    
    
    #|-------------------------------
    #|Validation for base data rate
    #|
    if { $hdl_data_path_type == "10G" } {
        set pcs_datapath "TEN_G_PCS"
    } else {
        set pcs_datapath "EIGHT_G_PCS"
    }
    
    set pcs_width [get_pcs_width $ser_factor]
    set pma_width [get_pma_width $pcs_pma_width]

    #check user data rate agants PCS data rate rules
    if {$ser_factor_validation == 1} { 
        if {$hdl_data_path_type == "8G" || $hdl_data_path_type == "10G"} {
            #remove 10G setting due to SPR 377867
            ::alt_xcvr::utils::rbc::validate_pcs_data_rate $dev_family $data_rate_int $op_mode "basic" $ser_factor $pcs_datapath $pcs_dw $ser_base_factor $hdl_data_path_type $pma_width
        }
    }
    set base_data_rate_list {}
    if { [::alt_xcvr::utils::device::has_s4_style_hssi $dev_family] } {
        lappend base_data_rate_list "${data_rate_int} Mbps"
    } elseif { $hdl_data_path_type == "ATT" } {
        lappend base_data_rate_list "${data_rate_int} Mbps"
    } else {
        set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $dev_family $data_rate $pll_type]
        if { [llength $base_data_rate_list] == 0 } {
            set base_data_rate_list {"N/A"}
            send_message error "Data rate chosen is not supported or is incompatible with selected PLL type"
        }
    }
    ::alt_xcvr::utils::common::map_allowed_range gui_base_data_rate $base_data_rate_list
    set data_rate_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_base_data_rate]
    
    #|------------------
    # Validation for PLL
    #|------------------
    
   

    if { ![::alt_xcvr::utils::device::has_s4_style_hssi $dev_family] } {
        if {$hdl_data_path_type == "ATT"} {
            set enable_att "true"
        } else {
            set enable_att "false"
        }
        if {$data_rate_str != "N/A" && $data_rate_str != "N.A"} {
          # May return "N/A"
          if { $gui_bonding_enable == "true" && $bonded_mode == "fb_compensation" } {
            # Feedback compensation
            set result [::alt_xcvr::utils::rbc::get_valid_refclks $dev_family $data_rate_str $pll_type $enable_att "PMA" $pcs_pma_width $data_rate]
          } else {
            # Non-feedback compensation
            set result [::alt_xcvr::utils::rbc::get_valid_refclks $dev_family $data_rate_str $pll_type $enable_att]
          }

          # get the refclk range for atx pll att rx and decide on which refclk set to choose from
          if { ($pll_type == "ATX") && ($enable_att == "true") } {
	    set result_atx_att_rx [::alt_xcvr::utils::rbc::get_valid_refclks_atx_att_rx $dev_family $data_rate_str]
          
	    if {$op_mode == "DUPLEX" } {
	      # set result as intersection
	      foreach elem $result {
                if {[lsearch -exact $result_atx_att_rx $elem] != -1} {
                  lappend intersection $elem
                }
              }
              
              if { [llength $intersection] == 0 } {
	        set result "N/A"
              } else {
	        set result $intersection
              }
            } elseif { $op_mode == "RX" } {
	      # set result as result_atx_att_rx
	      set result $result_atx_att_rx
            }
            # otherwise keep result as result
          }          
        } else {
            set result "N/A"
        }
        
        ::alt_xcvr::utils::common::map_allowed_range gui_pll_refclk_freq $result
        set user_pll_refclk_freq [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_refclk_freq]
    } else {
        set user_pll_refclk_freq [get_parameter_value gui_pll_refclk_freq]
    }

	# Enable channel interface option only for Stratix V
    if [::alt_xcvr::utils::device::has_s5_style_hssi $dev_family] {
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
	  
	    if { $ser_factor == 66 } {
	      send_message error "Channel Interface Reconfiguration is not supported for the selected FPGA fabric transceiver interface width (66)"
	    }
    }
  


    #|--------------------------------------------------------
    # Validation of the TX PLL reconfiguration package
    #|--------------------------------------------------------
    if [::alt_xcvr::utils::device::has_s5_style_hssi $dev_family] {
        if {$hdl_data_path_type == "ATT"} {
          set max_plls 1
        } else {
          set max_plls 4
        }
        set max_plls [expr ($sup_tx == 1) ? $max_plls : 0]
        if {$hdl_data_path_type == "ATT"} {
          ::alt_xcvr::gui::pll_reconfig::set_config $dev_family $max_plls 1 [::alt_xcvr::utils::device::get_hssi_pll_types $dev_family] $sup_rx 1; # ATT: 1 PLL, 1 refclks, types, enable rx refclk sel, enable PLL reconfig
        } else {
          ::alt_xcvr::gui::pll_reconfig::set_config $dev_family $max_plls 5 [::alt_xcvr::utils::device::get_hssi_pll_types $dev_family] $sup_rx 1; # 4 PLLs, 5 refclks, types, enable rx refclk sel, enable PLL reconfig
        }
    } else {
        set max_plls [expr ($sup_tx == 1) ? 1 : 0]
        ::alt_xcvr::gui::pll_reconfig::set_config $dev_family $max_plls 1 [::alt_xcvr::utils::device::get_hssi_pll_types $dev_family] $sup_rx; # 1 PLL, 1 refclk
    }
    
    ::alt_xcvr::gui::pll_reconfig::set_main_pll_settings $user_pll_refclk_freq $data_rate_str $pll_type
    ::alt_xcvr::gui::pll_reconfig::validate
    
    set_parameter_value pma_width $pcs_pma_width
    set_parameter_value serialization_factor $ser_factor
    set_parameter_value pll_refclk_freq   [::alt_xcvr::gui::pll_reconfig::get_refclk_freq_string]
    set_parameter_value pll_refclk_select [::alt_xcvr::gui::pll_reconfig::get_refclk_sel_string]
    set_parameter_value pll_type          [::alt_xcvr::gui::pll_reconfig::get_pll_type_string]
    set_parameter_value base_data_rate    [::alt_xcvr::gui::pll_reconfig::get_pll_data_rate_string]
    set_parameter_value pll_select        [::alt_xcvr::gui::pll_reconfig::get_main_pll_index]
    set_parameter_value pll_reconfig      [::alt_xcvr::gui::pll_reconfig::get_pll_reconfig]
    set_parameter_value pll_refclk_cnt    [::alt_xcvr::gui::pll_reconfig::get_refclk_count]
    
	  if { $ser_factor == 66 && [::alt_xcvr::gui::pll_reconfig::get_refclk_count] > 1} {
	    send_message warning "PLL reference clock switching is not supported for the selected FPGA fabric transceiver interface width (66)"
	  }

    if { $sup_tx == 1 } {
        set_parameter_value plls [::alt_xcvr::gui::pll_reconfig::get_pll_count]
    } else {
        set_parameter_value plls 1
    }
    
    if { [expr {$sup_rx == 1 && [::alt_xcvr::utils::device::has_s5_style_hssi $dev_family]}] } {
        set_parameter_value cdr_refclk_select [::alt_xcvr::gui::pll_reconfig::get_cdr_refclk_sel]
    } else {
        set_parameter_value cdr_refclk_select 0
    }
    
    set_parameter_value bonded_mode $bonded_mode

  #*******************************************
  # Resolve number of PLLs to pass down to RTL
  set pll_count [::alt_xcvr::gui::pll_reconfig::get_pll_count]
  if { $sup_tx == 0 } {
    set pll_count 1; #always pass at least 1
  }

    #************************
    # Reset parameters
    validate_embedded_reset $dev_family $pll_count
#    validate_manual_reset
    

}

# +----------------------------------------------------
# | Validation for management parameters (clock freq)
# +----------------------------------------------------
proc validate_mgmt {} {
    set_parameter_value mgmt_clk_in_mhz [expr [get_parameter_value gui_mgmt_clk_in_hz] / 1000000]
}

# +----------------------------------------------------
# | Validation for reconfiguration parameters
# +----------------------------------------------------
proc validate_reconfiguration_parameters { device_family } {

    set lanes       [get_parameter_value lanes]
    set op_mode     [get_parameter_value operation_mode]
    set sup_bonding [get_parameter_value gui_bonding_enable]
    set bonded_mode [get_parameter_value bonded_mode]
    set hdl_data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]
    set tx_plls     [get_parameter_value plls]
    set pll_reconfig [get_parameter_value pll_reconfig]

    set pll_reconfig_interfaces $tx_plls
    if { $op_mode == "RX" } {
        set pll_reconfig_interfaces 0
    } elseif { $sup_bonding == 0 || $bonded_mode == "fb_compensation" } {
        set pll_reconfig_interfaces [expr {$tx_plls * $lanes}]
    }
    
    if [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] {
        if { $op_mode == "DUPLEX" && $hdl_data_path_type == "ATT" } {
          set lanes [expr {2 * $lanes}]
          ::alt_xcvr::gui::messages::reconfig_interface_message $device_family $lanes $pll_reconfig_interfaces
        } else {
          ::alt_xcvr::gui::messages::reconfig_interface_message $device_family $lanes $pll_reconfig_interfaces
        }
    }

    #*********************************************
    # Error message for enabling reconfig for ATT
    if [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] {
        if { $hdl_data_path_type == "ATT" } {
          if { $pll_reconfig == 1} {
            send_message error "Reconfiguration is not supported for ATT channels"
          }
        }
    }

    #*********************************************
    # Error message for bonding with multiple PLLs
    if {$sup_bonding == 1 && $tx_plls > 1} {
      send_message error "Lane bonding must be disabled when using multiple TX PLLs"
    }
    
}


# +----------------------------------------------------
# | Validation for other common parameters
# +----------------------------------------------------
proc validate_optional_parameters {} {

    set op_mode             [get_parameter_value operation_mode]
    set ser_factor          [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_serialization_factor]
    set user_pma_width [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pma_width]
    set gui_data_path_type  [get_parameter_value gui_data_path_type]
    set hdl_data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]
    set dev_family          [get_parameter_value device_family]
    
    set sup_rx      [expr {$op_mode == "RX" || $op_mode == "DUPLEX" }]
    set sup_tx      [expr {$op_mode == "TX" || $op_mode == "DUPLEX" }]


    #|-------------------
    #| Additional options
    #|-------------------
    if {$sup_tx == 0 && [get_parameter_value tx_bitslip_enable] == 1} {
        send_message error "TX bitslip is not supported on RX-only channels"
    } 
    if {$sup_rx == 0 && [get_parameter_value rx_bitslip_enable] == 1} {
        send_message error "RX bitslip is not supported on TX-only channels"
    } else {
	if { [get_parameter_value rx_bitslip_enable] == 1} {	
	    ## For production, disable RX bitslip for 50:40 and 64:32 modes
	    if { $ser_factor == 50 && $user_pma_width == 40} {
		send_message error "RX bitslip is not supported when FPGA fabric transceiver interface width is 50"
	    } 
	    if {$ser_factor == 64 && $user_pma_width == 32 } {
		send_message error "RX bitslip is not supported when FPGA fabric transceiver interface width is 64 and PCS-PMA interface width is 32"
	    }
	}
    }

    ## RX bitslip is enabled only in 10G mode
    if {$hdl_data_path_type == "10G" } {
        set_parameter_value tx_bitslip_width 7
	set_parameter_property rx_bitslip_enable VISIBLE true
    } else {
        set_parameter_value tx_bitslip_width 5
        set_parameter_property rx_bitslip_enable VISIBLE false
    }
    
    #validate coreclk must be used
    set coreclk_validate_result [validate_coreclk $ser_factor $user_pma_width]
    
    #hide tx_bitslip_enable for S4
    if [::alt_xcvr::utils::device::has_s4_style_hssi $dev_family] {
        set_parameter_property tx_bitslip_enable VISIBLE false
        set_parameter_property tx_bitslip_enable ENABLED false
    } else {
        set_parameter_property tx_bitslip_enable VISIBLE true
        if { $hdl_data_path_type == "ATT" } {
         set_parameter_property tx_bitslip_enable ENABLED false
        } else {
         set_parameter_property tx_bitslip_enable ENABLED true
        }
    }


    #tx/rx coreclk should be used for 8G or serialization factor = 32 or 40 for 10G
    if { $hdl_data_path_type == "ATT" } {
        set_parameter_property gui_tx_use_coreclk ENABLED false
        set_parameter_property gui_tx_use_coreclk VISIBLE false
        set_parameter_property tx_use_coreclk ENABLED false
        set_parameter_property tx_use_coreclk VISIBLE true
        set_parameter_value tx_use_coreclk 0
    } elseif {$sup_tx} {
        set_parameter_property gui_tx_use_coreclk VISIBLE true
        set_parameter_property gui_tx_use_coreclk ENABLED true
        set_parameter_property tx_use_coreclk VISIBLE false
        set_parameter_property tx_use_coreclk ENABLED false
        
        
        set_parameter_value tx_use_coreclk [get_parameter_value gui_tx_use_coreclk]

        if {($hdl_data_path_type == "10G") && ($coreclk_validate_result == 1) && ($ser_factor != 66)} {
            if {[get_parameter_value gui_tx_use_coreclk] == 0} {
                send_message error "$ser_factor bits FPGA fabric transceiver interface width with $user_pma_width bits PCS-PMA interface width must use tx_coreclkin."
            }
        } 
        
    } else {
        set_parameter_property gui_tx_use_coreclk VISIBLE true
        set_parameter_property gui_tx_use_coreclk ENABLED true
        set_parameter_property tx_use_coreclk VISIBLE false
        set_parameter_property tx_use_coreclk ENABLED false
        
        set_parameter_value tx_use_coreclk [get_parameter_value gui_tx_use_coreclk]
        
        if {[get_parameter_value gui_tx_use_coreclk] == 1} {
            send_message error "tx_coreclkin is not supported on Rx-only channel."
        }
    }
    
    if { $hdl_data_path_type == "ATT" } {
        set_parameter_property gui_rx_use_coreclk ENABLED false
        set_parameter_property gui_rx_use_coreclk VISIBLE false
        set_parameter_property rx_use_coreclk ENABLED false
        set_parameter_property rx_use_coreclk VISIBLE true
        set_parameter_value rx_use_coreclk 0
    } elseif {$sup_rx} {
        set_parameter_property gui_rx_use_coreclk VISIBLE true
        set_parameter_property gui_rx_use_coreclk ENABLED true
        set_parameter_property rx_use_coreclk VISIBLE false
        set_parameter_property rx_use_coreclk ENABLED false
        
        set_parameter_value rx_use_coreclk [get_parameter_value gui_rx_use_coreclk]
        
        if {($hdl_data_path_type == "10G") && ($coreclk_validate_result == 1) && ($ser_factor != 66)} {
            if {[get_parameter_value gui_rx_use_coreclk] == 0} {
                send_message error "$ser_factor bits FPGA fabric transceiver interface width with $user_pma_width bits PCS-PMA interface width must use rx_coreclkin."
            }
        } 
        
    } else {
        set_parameter_property gui_rx_use_coreclk VISIBLE true
        set_parameter_property gui_rx_use_coreclk ENABLED true
        set_parameter_property rx_use_coreclk VISIBLE false
        set_parameter_property rx_use_coreclk ENABLED false
        
        set_parameter_value rx_use_coreclk [get_parameter_value gui_rx_use_coreclk]
        
        if {[get_parameter_value gui_rx_use_coreclk] == 1} {
            send_message error "rx_coreclkin is not supported on Tx-only channel."
        }
    }

    if { [get_parameter_value gui_tx_use_coreclk] == 1 && ($hdl_data_path_type == "ATT") } {
         send_message error "GT does not support using tx_coreclk_in"
    }

    if { [get_parameter_value gui_rx_use_coreclk] == 1 && ($hdl_data_path_type == "ATT") } {
        send_message error "GT does not support using rx_coreclk_in"
    }

    if { [get_parameter_value tx_bitslip_enable] == 1 && ($hdl_data_path_type == "ATT") } {
         send_message error "GT does not support using tx_bitslip"
    }

    #|----------------------------
    #| validate PPM detector threshold and check for new optional CDR port
    #|----------------------------

    if { $hdl_data_path_type == "ATT" && $sup_rx} {
        set_parameter_property gui_ppm_det_threshold VISIBLE true 
        set_parameter_value ppm_det_threshold [get_parameter_value gui_ppm_det_threshold]
        set_parameter_property gui_enable_att_reset_gate VISIBLE true
    } else {
        set_parameter_property gui_ppm_det_threshold VISIBLE false
        set_parameter_value ppm_det_threshold [get_parameter_value gui_ppm_det_threshold]
        set_parameter_property gui_enable_att_reset_gate VISIBLE false
    }


    #|----------------------------
    #| set symbol size visibility
    #|----------------------------
    set gui_avalon_interfaces [get_parameter_value gui_split_interfaces]
    set symbol_size [get_parameter_value gui_avalon_symbol_size]
    set_parameter_property gui_avalon_symbol_size VISIBLE $gui_avalon_interfaces
    if {$gui_avalon_interfaces && $symbol_size > 0} {
        set ser_factor [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_serialization_factor]
        if { [expr {($ser_factor % $symbol_size) != 0} ] } {
            send_message error "The serialization factor ($ser_factor) is not evenly divisble by the Avalon ST symbol size ($symbol_size)."
        }
    }
}


# +-----------------------------------
# | Validation for S4-generation parameters
# | 
proc get_avalon_symbol_size {} {
    set gui_avalon_interfaces [get_parameter_value gui_split_interfaces]
    set symbol_size [get_parameter_value gui_avalon_symbol_size]
    if {! $gui_avalon_interfaces || $symbol_size == 0} {
        # set symbol size to the full serialization factor word size
        set symbol_size [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_serialization_factor]
    }
    return $symbol_size
}


# +-----------------------------------
# | Validation for S4-generation parameters
# | 
proc validate_s4_constraints {} {
    set num_chs     [get_parameter_value lanes]
    set sup_bonding [get_parameter_value gui_bonding_enable]
    set phase_comp_fifo_mode [get_parameter_value phase_comp_fifo_mode]
    set ser_factor [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_serialization_factor]
    set hdl_data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]
    
    # enable S4 analog params
    common_set_parameter_group {S4} VISIBLE true
    
    #|-------------------------------
    #| De/serialization calculations
    #|-------------------------------
    #calculate base ser factor
    set ser_factor [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_serialization_factor]
    #send_message info "ser_factor is $ser_factor"
    if { [ expr $ser_factor % 10 ] == 0 } {
        set ser_base_factor 10
    } else {
        set ser_base_factor 8
    }
    set ser_words [expr $ser_factor / $ser_base_factor]

    if {$ser_words > 2 && $phase_comp_fifo_mode != "EMBEDDED" && ($hdl_data_path_type != "10G")} {
        set error_text "Invalid serialization factor ($ser_factor).  For serialization factors above 20, set the Phase compensation FIFO mode to 'EMBEDDED'."
        if { [::alt_xcvr::utils::device::has_s5_style_hssi [get_parameter_value device_family]] } {
            set error_text "$error_text, or enable the 10-Gbps datapath"
        }
        send_message error $error_text
    }

    #intended_device_variant
    set_parameter_property intended_device_variant VISIBLE true

    set_parameter_property base_data_rate VISIBLE false

    #number of lanes
    set_parameter_property lanes ALLOWED_RANGES 1:24

    #10G PCS only exist for Stratix V onwards
    #select_10g_pcs
#   set_parameter_property gui_select_10g_pcs ENABLED false
    set_parameter_value select_10g_pcs 0
    set_parameter_property gui_data_path_type VISIBLE false
    set_parameter_property gui_data_path_type ENABLED false

    #phase_comp_fifo_mode
    set_parameter_property phase_comp_fifo_mode VISIBLE true
        
    #loopback_mode
    set_parameter_property loopback_mode VISIBLE false
    
    #starting_channel_number
    set_parameter_property starting_channel_number VISIBLE true
    
    #plls
    set_parameter_property plls VISIBLE false
    
    #pll_refclk_cnt
    set_parameter_property pll_refclk_cnt VISIBLE false
    
    #gui_pma_width
    set_parameter_property gui_pma_width VISIBLE false
    
    set_parameter_value tx_use_coreclk [get_parameter_value gui_tx_use_coreclk]
    
    set_parameter_value rx_use_coreclk [get_parameter_value gui_rx_use_coreclk]
    
}


# +-----------------------------------
# | Validation for S5-generation parameters
# | 
proc validate_s5_constraints {} {
    set hdl_data_path_type              [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]
    set_parameter_value data_path_type  hdl_data_path_type
    set num_chs                         [get_parameter_value lanes]
    set sup_bonding                     [get_parameter_value gui_bonding_enable]
    set bonded_mode                     [get_parameter_value bonded_mode]
    set ser_factor                      [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_serialization_factor]
    set data_rate_str                   [get_parameter_value data_rate]
    set user_pma_width                  [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pma_width]

    
    set_parameter_value data_path_type  $hdl_data_path_type

    # 10G range is 600 Mbps to 12500 Mbps
    set data_int [::alt_xcvr::utils::common::get_data_rate_in_mbps $data_rate_str]

    if { $hdl_data_path_type == "ATT" } {
        if { $data_int < 19600 || $data_int > 28050 } {
            send_message error "Invalid GT datapath data rate ($data_rate_str). GT datapath can support data rates are from 19600 Mbps to 28050 Mbps."
        }
    } 
    
    #elseif { $is_10g } {
    #    if { $data_int < 600 || $data_int > 12500 } {
    #        send_message error "Invalid 10-Gbps datapath data rate ($data_rate_str). 10-Gbps datapath can support data rates are from 600 Mbps to 12500 Mbps."
    #    }
    #} else {
    #    if { $data_int < 400 || $data_int > 8500 } {
    #        send_message error "Invalid 8-Gbps datapath data rate ($data_rate_str). 8-Gbps datapath can support data rates from 400 Mbps to 8500 Mbps."
    #    }
    #}

    set_parameter_property gui_base_data_rate VISIBLE true

    #intended_device_variant
    set_parameter_property intended_device_variant VISIBLE false

    #number of lanes
    if { $hdl_data_path_type == "ATT" } {
        set_parameter_property lanes ALLOWED_RANGES 1:1
    } else {
        set_parameter_property lanes ALLOWED_RANGES 1:32
    }
    
    # hide S4 analog params
    common_set_parameter_group {S4} VISIBLE false

    if { ($hdl_data_path_type == "ATT")  &&  $num_chs > 1 } {
        send_message error "GT can only support up to maximum of 1 lane per IP instance."
    }

    #gui_bonding_enable
    if { $hdl_data_path_type == "ATT" } {
        if { $sup_bonding == 1 } {
            send_message error "GT datapath does not support bonding ."
        }
    }

    #serialization_factor
    #if { $is_att } {
    #    set_parameter_property serialization_factor ALLOWED_RANGES {128}
    #    send_message info "ATT width is fixed at 128-bit."
    #} else {
        
    #}
    
    
    #Validataion for pma_width
    set_parameter_property gui_pma_width VISIBLE true

    if {$hdl_data_path_type == "10G"} {
        set_parameter_value select_10g_pcs 1
#       send_message info "IS 10G so set select_10g_pcs to 1 ."
    } else {
        set_parameter_value select_10g_pcs 0
    }

    #phase_comp_fifo_mode
    set_parameter_property phase_comp_fifo_mode VISIBLE false

    #loopback_mode
    set_parameter_property loopback_mode VISIBLE false
    
    #starting_channel_number
    set_parameter_property starting_channel_number VISIBLE false
    
    #plls
    set_parameter_property plls VISIBLE false
    
    #pll_refclk_cnt
    set_parameter_property pll_refclk_cnt VISIBLE false
}

proc validate_pll_type { device_family } {
    ::alt_xcvr::utils::common::map_allowed_range gui_pll_type [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 
    return [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_type]
}

proc validate_serialization_factor { hdl_data_path_type ser_factor device_family print_message} {

    if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
            if { $ser_factor != 8 && $ser_factor != 10 && $ser_factor != 16 && $ser_factor != 20 && $ser_factor != 32 && $ser_factor != 40 } {
                if { $print_message == "true" } {
                    send_message error "Stratix IV only supports FPGA fabric transceiver interface width of 8, 10, 16, 20, 32 and 40 bits."
                }
                return 0
            } else {
                return 1
            }
    } else {
        if { $hdl_data_path_type == "ATT" } {
            if { $ser_factor != 128 } {
                if { $print_message == "true" } {
                    send_message error "GT datapath only supports FPGA fabric transceiver interface width of 128 bits."
                }
                return 0
            } else {
                return 1
            }
        } elseif { $hdl_data_path_type == "10G" } {
            if { $ser_factor != 32 && $ser_factor != 40 && $ser_factor != 50 && $ser_factor != 64 && $ser_factor != 66 } {
                if { $print_message == "true" } {
                    send_message error "10-Gbps datapath only supports FPGA fabric transceiver interface width of 32, 40, 50, 64 and 66 bits."
                }
                return 0
            } else {
                return 1
            }
        } else {
             if { $ser_factor != 8 && $ser_factor != 10 && $ser_factor != 16 && $ser_factor != 20 && $ser_factor != 32 && $ser_factor != 40 } {
                 if { $print_message == "true" } {
                    send_message error "8-Gbps datapath only supports FPGA fabric transceiver interface width of 8, 10, 16, 20, 32 and 40 bits."
                }
                return 0
            } else {
                return 1
            }
        }
    }
}

proc get_pcs_width {ser_factor} {
    if { $ser_factor == 8} {
        set pcs_width "WIDTH_8"
    } elseif { $ser_factor == 10} {
        set pcs_width "WIDTH_10"
    } elseif { $ser_factor == 16} {
        set pcs_width "WIDTH_16"
    } elseif { $ser_factor == 20} {
        set pcs_width "WIDTH_20"
    } elseif { $ser_factor == 32} {
        set pcs_width "WIDTH_32"
    } elseif { $ser_factor == 40} {
        set pcs_width "WIDTH_40"
    } elseif { $ser_factor == 50} {
        set pcs_width "WIDTH_50"
    } elseif { $ser_factor == 64} {
        set pcs_width "WIDTH_64"
    } elseif { $ser_factor == 66} {
        set pcs_width "WIDTH_66"
    } else {
        set pcs_width ""
    }
    return $pcs_width
}

proc get_pma_width {user_pma_width} {
    if { $user_pma_width == 32} {
        set pma_width "WIDTH_32"
    } elseif { $user_pma_width == 40} {
        set pma_width "WIDTH_40"
    } elseif { $user_pma_width == 64} {
        set pma_width "WIDTH_64"
    } else {
        set pma_width ""
    } 
    
    return $pma_width
}

proc validate_pcs_pma_width {ser_factor user_pma_width} {
    
    if { $ser_factor == 64 } {
        if {$user_pma_width != 64 && $user_pma_width != 32 } {
            send_message error "$ser_factor bits PLD-PCS interface width only allows 32 or 64 bits PCS-PMA interface width."
        }
    } elseif { $ser_factor == 66 } {
        if {$user_pma_width != 40 } {
            send_message error "$ser_factor bits PLD-PCS interface width only allows 40 bits PCS-PMA interface width."
        }
    } elseif { $ser_factor == 50 || $ser_factor == 40 } {
        if {$user_pma_width != 40 } {
            send_message error "$ser_factor bits PLD-PCS interface width only allows 40 bits PCS-PMA interface width."
        }
    } elseif { $ser_factor == 32} {
        if {$user_pma_width != 32 } {
            send_message error "$ser_factor bits PLD-PCS interface width only allows 32 bits PCS-PMA interface width."
        }
    } else {
        send_message info "PCS-PMA interface width selection only used for 10-Gbps datapath."
    }
}

proc validate_coreclk {ser_factor user_pma_width} {
    #coreclk must be used when PLD-PCS width != PCS-PMA width
    #exception for 66:40 ratio as the clkdiv33 in rx_deesr is used for Rx path and FFPLL is used for Tx path
    if { $ser_factor == 50 || ($ser_factor == 64 && $user_pma_width == 32)} {
        return 1
    } else {
        return 0
    }
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

proc validate_deprecated_pma_width { datapath_type deser_factor base_factor pcs_dw_mode data_rate_int dev_family } {
  
    #calculate pma_width
    if { $datapath_type == "8G" } {
        if { ($deser_factor == 8 && $base_factor == 8) } {
            set pma_width 8
        } elseif { $deser_factor == 16 && $base_factor == 8 && ($pcs_dw_mode == "Double" || $data_rate_int <= 1000 || [::alt_xcvr::utils::device::has_a5_style_hssi $dev_family]) }  {
            set pma_width 8
        } elseif { $deser_factor == 10 ||  $deser_factor == 8 && $base_factor == 10 }  { 
            set pma_width 10
        } elseif { ($deser_factor == 20 || $deser_factor == 16 && $base_factor == 10) && ($pcs_dw_mode == "Double" || $data_rate_int <= 1000 || [::alt_xcvr::utils::device::has_a5_style_hssi $dev_family]) }  {
            set pma_width 10
        } elseif { ($deser_factor == 16 || $deser_factor == 32) && $base_factor == 8 } {
            set pma_width 16
        } else {
            set pma_width 20
        }
    } elseif { $datapath_type == "ATT" } {
        set pma_width "NA"
        send_message INFO "PCS-PMA interface width selection is not available for GT datapath."
    } elseif { $datapath_type == "10G" } {
        if { $deser_factor == 40 || $deser_factor == 50 || $deser_factor == 66 } {
            set pma_width 40
        } elseif { $deser_factor == 32 } {
            set pma_width 32
        } elseif { $deser_factor == 64 } {
            set pma_width {32 64}
        } else {
            set pma_width "NA"
            send_message error "Invalid FPGA fabric transceiver interface width of $deser_factor bits."
        }
    } else {
        set pma_width "NA"
        #send_message error "Invalid datapath type of $datapath_type."
    }
    
    return $pma_width
}

proc validate_pma_width { datapath_type deser_factor base_factor data_rate_int dev_family } {
    if { $datapath_type == "8G" } {
        if { $deser_factor == 8 && $base_factor == 8 }  {
            set pma_width 8
        } elseif { $deser_factor == 10 || ($deser_factor == 8 && $base_factor == 10) } {
            set pma_width 10
        } elseif { $deser_factor == 16 && $base_factor == 8 } {
            if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $dev_family] } {
                set pma_width 8
            } else {
                set pma_width {8 16}
            }
        } elseif { ($deser_factor == 16 && $base_factor == 10) || $deser_factor == 20 } {
            if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $dev_family] } {
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
    } elseif { $datapath_type == "ATT" } {
        set pma_width "NA"
        send_message INFO "PCS-PMA interface width selection is not available for GT datapath."
    } elseif { $datapath_type == "10G" } {
        if { $deser_factor == 40 || $deser_factor == 50 || $deser_factor == 66 } {
            set pma_width 40
        } elseif { $deser_factor == 32 } {
            set pma_width 32
        } elseif { $deser_factor == 64 } {
            set pma_width {32 64}
        } else {
            set pma_width "NA"
            send_message error "Invalid FPGA fabric transceiver interface width of $deser_factor bits."
        }
    } else {
        set pma_width "NA"
        #send_message error "Invalid datapath type of $datapath_type."
    }
  
  return $pma_width
}

proc validate_pcs_dw { pcs_pma_width deser_factor base_factor data_rate_int dev_family } {
    set pcs_dw "Single"
   
    if { $deser_factor == 16 && $base_factor == 8 } {
      if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $dev_family] } {
        set pcs_dw "Double"
      }  elseif { $pcs_pma_width == 8 } {
        set pcs_dw "Double"
      }
    } elseif { ($deser_factor == 16 && $base_factor == 10) || $deser_factor == 20 } {
      if { ($data_rate_int <= 1000) || [::alt_xcvr::utils::device::has_a5_style_hssi $dev_family] } {
        set pcs_dw "Double"
      }  elseif { $pcs_pma_width == 10 } {
        set pcs_dw "Double"
      }
    } elseif { $deser_factor == 32 } {
      set pcs_dw "Double"
    } elseif { $deser_factor == 40 } {
      set pcs_dw "Double"
    }
    
    return $pcs_dw
}

proc get_datapath_mapped_hdl { gui_datapath_type } {
    if { $gui_datapath_type == "Standard" } {
        set datapath_type "8G"
    } elseif { $gui_datapath_type == "GT" } {
        set datapath_type "ATT"
    } else {
        set datapath_type $gui_datapath_type
    }
    
    return $datapath_type
}

###
# Validation for "embedded_reset" parameter
#
# @param - device_family - Current selected device family
# @param - pll_count - Current configured number of TX plls for reconfiguration
proc validate_embedded_reset { device_family pll_count } {
  set gui_embedded_reset [get_parameter_value gui_embedded_reset]

  # Support for embedded reset removal in SV only.
  if { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
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
# Validation for "bonded_mode" parameter
#
# @param - device_family - Current selected device family
# @param - gui_bonding_enable - Resolved value of "gui_bonding_enable" parameter
# @param - gui_bonded_mode - Resolved value of "gui_bonded_mode" parameter
# @param - lanes - Current value of the "lanes" parameter
# @param - pll_type - Resolved value of "pll_type" parameter
proc validate_bonded_mode { device_family gui_bonding_enable gui_bonded_mode lanes pll_type} {

  # bonded_mode
  # Default bonded mode
  if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
    set bonded_mode "FALSE"; # Stratix IV
  } else {
    set bonded_mode "xN"; # Stratix V
  }
  
  if { $gui_bonding_enable == "true" } {
    if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
      set bonded_mode "TRUE"; # Stratix IV
    } else {
      set bonded_mode $gui_bonded_mode; # Stratix V
    }
  }

  # Max lanes messages
  if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
    if { $lanes != 4 && $lanes != 8 && $gui_bonding_enable == "true" } {
        send_message error "Bonding is only supported when number of lanes is 4 or 8"
    }
  } elseif { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
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
  } elseif { [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
    if { $lanes > 6 && $gui_bonding_enable == "true"} {
      send_message error "Bonding is only supported up to a maximum of 6 lanes"
    }
  }

  return $bonded_mode
}

