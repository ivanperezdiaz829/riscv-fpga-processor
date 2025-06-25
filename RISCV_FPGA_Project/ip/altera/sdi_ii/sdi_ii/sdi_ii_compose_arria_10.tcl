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


proc compose_arria_10 {dir config device video_std 2xhd txpll xcvr_tx_pll_sel insert_vpid extract_vpid crc_err a2b b2a} {

# +-----------------------------------
# | Set component to be instantiated 
# |
   if { $dir == "du" } {
      set rx_component 1
      set tx_component 1
   } elseif { $dir == "tx" } {
      set rx_component 0
      set tx_component 1
   } elseif { $dir == "rx" } {
      set rx_component 1
      set tx_component 0
   }

# +-----------------------------------
# | Set proto / xcvr to be instantiated 
# |
   if { $config == "xcvr_proto" } {
      set gen_proto 1
      set gen_xcvr  1
   } elseif { $config == "xcvr" } {
      set gen_proto 0
      set gen_xcvr  1
   } elseif { $config == "proto" } {
      set gen_proto 1
      set gen_xcvr  0
   }

# +------------------------------------------------
# | Set number of tx pll (For Tx PLL Switching)
# |
   # if { $xcvr_tx_pll_sel } {
      # set txpll_num 2
   # } else {
      set txpll_num 1
   # }

# +------------------------------------------------
# | Set parameter values for xcvr
# |
   if { ($video_std == "hd" &  $2xhd == 0 )|| $video_std == "dl"} {
      set data_rate         "1485"
      set data_rate_1       "1483.5"
      set pll_refclk_freq   "74.250"
      set pll_refclk_freq_1 "74.175"
   } else {
      set data_rate         "2970"
      set data_rate_1       "2967"
      set pll_refclk_freq   "148.500"
      set pll_refclk_freq_1 "148.350"
   }
   


# +-----------------------------------
# | Instantiate phy adapter and phy
# |
   if { $gen_xcvr } {
      add_instance       u_phy_adapter     sdi_ii_phy_adapter
      propagate_params   u_phy_adapter

      add_native_x_phy u_tx_pll u_phy u_tx_phy_rst_ctrl u_rx_phy_rst_ctrl $dir $video_std $txpll $data_rate $data_rate_1 $pll_refclk_freq $pll_refclk_freq_1 $xcvr_tx_pll_sel
      if { $video_std == "dl" } {
         add_native_x_phy u_tx_pll_b u_phy_b u_tx_phy_rst_ctrl_b u_rx_phy_rst_ctrl_b $dir $video_std $txpll $data_rate $data_rate_1 $pll_refclk_freq $pll_refclk_freq_1 $xcvr_tx_pll_sel
      }
   }

# +-----------------------------------
# | Instantiate tx components
# |
   if { $tx_component } {
      add_rst_bridge            tx

      if { $gen_proto } {
         add_instance       u_tx_protocol     sdi_ii_tx_protocol
         propagate_params   u_tx_protocol
         tx_protocol__add_export_interface u_tx_protocol $config $insert_vpid  $video_std
      }

      if { $gen_xcvr } {
         add_instance       u_tx_phy_mgmt     sdi_ii_tx_phy_mgmt
         propagate_params   u_tx_phy_mgmt
         tx_phy_mgmt__add_export_interface u_tx_phy_mgmt $config $video_std
         add_tx_phy_mgmt__phy_connection         u_tx_phy_mgmt u_phy_adapter $video_std    $dir   $device 

         add_instance            pll_locked_fanout                altera_fanout
         set_instance_parameter  pll_locked_fanout                SPECIFY_SIGNAL_TYPE    1
         set_instance_parameter  pll_locked_fanout                SIGNAL_TYPE            pll_locked
         set_instance_parameter  pll_locked_fanout                WIDTH                  $txpll_num
         add_connection          u_tx_pll.pll_locked              pll_locked_fanout.sig_input

         add_instance              tx_pclk_rst_bridge         altera_reset_bridge
         add_connection            tx_rst_bridge.out_reset    tx_pclk_rst_bridge.in_reset
      }

      if { $gen_xcvr & $gen_proto } {
         add_tx_protocol__tx_phy_mgmt_connection u_tx_protocol u_tx_phy_mgmt $config       $video_std
      }

      add_tx_clk_rst_connection $config  $dir  $video_std  $device 
   }

# +-----------------------------------
# | Instantiate rx components
# |
   if { $rx_component } {
      if { $gen_proto } {
         add_instance       u_rx_protocol     sdi_ii_rx_protocol
         propagate_params   u_rx_protocol
         rx_protocol__add_export_interface u_rx_protocol $config $extract_vpid $video_std $crc_err $a2b $b2a 
      }

      if { $gen_xcvr } {
         add_instance       u_rx_phy_mgmt     sdi_ii_rx_phy_mgmt
         propagate_params   u_rx_phy_mgmt
         rx_phy_mgmt__add_export_interface u_rx_phy_mgmt $config $video_std
         add_phy__rx_phy_mgmt_connection         u_phy_adapter u_rx_phy_mgmt $video_std  $device 

         add_rst_bridge            rx
         add_rx_clk_rst_connection $video_std  $device

         add_instance              rx_phy_rst_ctrl_bridge     altera_reset_bridge
         if { $video_std == "dl" } {
            add_instance           rx_phy_rst_ctrl_b_bridge   altera_reset_bridge
         }
      }

      if { $gen_xcvr & $gen_proto } {
         add_rx_phy_mgmt__rx_protocol_connection u_rx_phy_mgmt u_rx_protocol $video_std
      }
   }

# +-----------------------------------
# | Connects phy to tx / rx components
# | after they are instantiated
# |
   if { $gen_xcvr } {
      add_xcvr_clk_connection   $video_std  $device  $dir  $xcvr_tx_pll_sel
      add_xcvr_rst_ctrl_connection   u_phy   u_tx_phy_rst_ctrl   u_rx_phy_rst_ctrl   $video_std   $dir   $device
      phy__add_export_interface         u_phy_adapter $dir    $video_std  $device   $xcvr_tx_pll_sel
      add_phy_xcvr_connection                 u_phy_adapter u_phy         $dir          $device 
      if { $video_std == "dl" } {
         add_phy_xcvr_b_connection            u_phy_adapter u_phy_b       $dir          $device 
      }
   }
}

proc add_native_x_phy {tx_pll_name phy_name tx_xcvr_rst_name rx_xcvr_rst_name dir video_std pll_type pll0_data_rate pll1_data_rate pll_refclk_freq0 pll_refclk_freq1 xcvr_tx_pll_sel} {

   if { $dir != "rx" } {
      add_instance                  $tx_pll_name   altera_xcvr_cdr_pll_vi
      set_instance_parameter_value  $tx_pll_name   output_clock_frequency      "1485"
      set_instance_parameter_value  $tx_pll_name   reference_clock_frequency   "148.500000"
   }
   
   add_instance                  $phy_name   altera_xcvr_native_a10
   
   # if { $xcvr_tx_pll_sel } {
      # set txpll_num 2
    # } else {
      set txpll_num 1
    # }
   
   set_instance_parameter_value   $phy_name   set_data_rate                         $pll0_data_rate
   set_instance_parameter_value   $phy_name   set_cdr_refclk_freq                   $pll_refclk_freq0
   set_instance_parameter_value   $phy_name   enable_ports_rx_manual_cdr_mode       1
   set_instance_parameter_value   $phy_name   std_tx_byte_ser_mode                  "Serialize x2"
   set_instance_parameter_value   $phy_name   std_rx_byte_deser_mode                "Deserialize x2"

   if { $dir == "tx" } {
      set_instance_parameter_value   $phy_name   duplex_mode   "tx"
   } elseif { $dir == "rx" } {
      set_instance_parameter_value   $phy_name   duplex_mode   "rx"
   } elseif { $dir == "du" } {
      set_instance_parameter_value   $phy_name   duplex_mode   "duplex"
   }
   
   if { $dir == "du" || $dir == "tx" } {
      # if { $video_std == "ds" || $video_std == "tr" || $xcvr_tx_pll_sel } {
         # set_instance_parameter_value $phy_name  pll_reconfig_enable              true
      # } else {
         # set_instance_parameter_value $phy_name  pll_reconfig_enable              false
      # }

      add_instance                   $tx_xcvr_rst_name   altera_xcvr_reset_control
      if { $pll_refclk_freq0 == "148.500" } {
        set_instance_parameter_value   $tx_xcvr_rst_name   SYS_CLK_IN_MHZ            148
      } elseif { $pll_refclk_freq0 == "74.250" } {
        set_instance_parameter_value   $tx_xcvr_rst_name   SYS_CLK_IN_MHZ            74
      }
      set_instance_parameter_value   $tx_xcvr_rst_name   SYNCHRONIZE_RESET         0
      set_instance_parameter_value   $tx_xcvr_rst_name   REDUCED_SIM_TIME          0
      set_instance_parameter_value   $tx_xcvr_rst_name   TX_PLL_ENABLE             1
      set_instance_parameter_value   $tx_xcvr_rst_name   TX_ENABLE                 1
      set_instance_parameter_value   $tx_xcvr_rst_name   RX_ENABLE                 0
      set_instance_parameter_value   $tx_xcvr_rst_name   gui_tx_auto_reset         0
      set_instance_parameter_value   $tx_xcvr_rst_name   PLLS                      $txpll_num
       
   }

   if { $dir == "du" || $dir == "rx" } {
      # if { $video_std == "ds" || $video_std == "tr"  || $xcvr_tx_pll_sel } {
         # set_instance_parameter_value $phy_name   cdr_reconfig_enable              true
      # } else {
         # set_instance_parameter_value $phy_name   cdr_reconfig_enable              false
      # }

      add_instance                   $rx_xcvr_rst_name   altera_xcvr_reset_control
      if { $pll_refclk_freq0 == "148.500" } {
        set_instance_parameter_value   $rx_xcvr_rst_name   SYS_CLK_IN_MHZ            148
      } elseif { $pll_refclk_freq0 == "74.250" } {
        set_instance_parameter_value   $rx_xcvr_rst_name   SYS_CLK_IN_MHZ            74
      }
      set_instance_parameter_value   $rx_xcvr_rst_name   SYNCHRONIZE_RESET         0
      set_instance_parameter_value   $rx_xcvr_rst_name   REDUCED_SIM_TIME          0
      set_instance_parameter_value   $rx_xcvr_rst_name   TX_PLL_ENABLE             0
      set_instance_parameter_value   $rx_xcvr_rst_name   TX_ENABLE                 0
      set_instance_parameter_value   $rx_xcvr_rst_name   RX_ENABLE                 1
      set_instance_parameter_value   $rx_xcvr_rst_name   RX_PER_CHANNEL            1
      set_instance_parameter_value   $rx_xcvr_rst_name   T_RX_ANALOGRESET          80
      set_instance_parameter_value   $rx_xcvr_rst_name   gui_rx_auto_reset         2
   }
}
