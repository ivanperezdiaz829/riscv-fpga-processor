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


proc compose_v_series {dir config device video_std 2xhd txpll xcvr_tx_pll_sel insert_vpid extract_vpid crc_err a2b b2a atxpll_data_rate hd_frequency} {

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
  if { $xcvr_tx_pll_sel } {
    set txpll_num 2
  } else {
    set txpll_num 1
  }
  
# +------------------------------------------------
# | Set parameter values for xcvr
# |
  if { $txpll == "CMU" } {
    if { ($video_std == "hd" || $video_std == "dl") & $hd_frequency == "74.25"} {
    	   set pll_refclk_freq   "74.25 MHz"
           set pll_refclk_freq_1 "74.175 MHz"
    	   set data_rate         "1485"
    	   set pll_data_rate     "2970.0 Mbps"
           set pll_data_rate_1   "2967.0 Mbps"
           set tx_pma_clk_div    2
    } elseif { ($video_std == "hd" || $video_std == "dl") & $hd_frequency == "148.5"} {
    	   set pll_refclk_freq   "148.5 MHz"
           set pll_refclk_freq_1 "148.35 MHz"
    	   set data_rate         "1485"
    	   set pll_data_rate     "2970.0 Mbps"
           set pll_data_rate_1   "2967.0 Mbps"
           set tx_pma_clk_div    2       
    } else {
           set pll_refclk_freq   "148.5 MHz"
           set pll_refclk_freq_1 "148.35 MHz"
    	   set data_rate         "2970"
    	   set pll_data_rate     "2970.0 Mbps"
           set pll_data_rate_1   "2967.0 Mbps"
           set tx_pma_clk_div    1
    }  

  } else { # ATX
      set pll_refclk_freq   	"148.5 MHz"
      set pll_refclk_freq_1 	"148.35 MHz"
      if {$device == "Stratix V"} {
      	if { ($video_std == "hd" || $video_std == "dl") } {
          set data_rate         	"1485.0"
          set pll_data_rate     	"11880.0 Mbps"
          set pll_data_rate_1   	"11868.0 Mbps"
          set tx_pma_clk_div 	8
        } else {     
          set data_rate         	"2970.0"
          set pll_data_rate     	"11880.0 Mbps"
          set pll_data_rate_1   	"11868.0 Mbps"
          set tx_pma_clk_div 	4
        } 
      } elseif {$device == "Arria V GZ"} {	        	        	      
        if { ($video_std == "hd" || $video_std == "dl") } {
          set data_rate         	"1485.0"
          set pll_data_rate     	"5940.0 Mbps"
          set pll_data_rate_1   	"5934.0 Mbps"
          set tx_pma_clk_div 	4
        } else {     
          set data_rate         	"2970.0"
          set pll_data_rate     	"5940.0 Mbps"
          set pll_data_rate_1   	"5934.0 Mbps"
          set tx_pma_clk_div 	2
        }
      }  
  }


# +-----------------------------------
# | Instantiate phy adapter and phy
# |
   if { $gen_xcvr } {
      add_instance       u_phy_adapter     sdi_ii_phy_adapter
      propagate_params   u_phy_adapter

      add_native_v_phy $device u_phy u_tx_phy_rst_ctrl u_rx_phy_rst_ctrl $dir $video_std $txpll $pll_data_rate $pll_data_rate_1 $pll_refclk_freq $pll_refclk_freq_1 $xcvr_tx_pll_sel $txpll $data_rate $tx_pma_clk_div
      if { $video_std == "dl" } {
         add_native_v_phy $device u_phy_b u_tx_phy_rst_ctrl_b u_rx_phy_rst_ctrl_b $dir $video_std $txpll $pll_data_rate $pll_data_rate_1 $pll_refclk_freq $pll_refclk_freq_1 $xcvr_tx_pll_sel $txpll $data_rate $tx_pma_clk_div
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
         add_connection          u_phy.pll_locked                 pll_locked_fanout.sig_input

         add_instance                  tx_rst_coreclk_sync           altera_reset_controller
         set_instance_parameter_value  tx_rst_coreclk_sync           NUM_RESET_INPUTS                 1
         add_connection                tx_rst_bridge.out_reset       tx_rst_coreclk_sync.reset_in0
      }

      if { $gen_xcvr & $gen_proto } {
         add_tx_protocol__tx_phy_mgmt_connection u_tx_protocol u_tx_phy_mgmt $config       $video_std
      }

      add_instance                  tx_rst_pclk_sync           altera_reset_controller
      set_instance_parameter_value  tx_rst_pclk_sync           NUM_RESET_INPUTS                 1
      add_connection                tx_rst_bridge.out_reset    tx_rst_pclk_sync.reset_in0

      add_tx_clk_rst_connection $config  $dir  $video_std  $device  $hd_frequency
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

         add_instance                  rx_rst_coreclk_sync           altera_reset_controller
         set_instance_parameter_value  rx_rst_coreclk_sync           NUM_RESET_INPUTS                 1
         add_connection                rx_rst_bridge.out_reset       rx_rst_coreclk_sync.reset_in0

         add_rx_clk_rst_connection $video_std  $device  $hd_frequency

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

proc add_native_v_phy {family phy_name tx_xcvr_rst_name rx_xcvr_rst_name dir video_std pll_type pll0_data_rate pll1_data_rate pll_refclk_freq0 pll_refclk_freq1 xcvr_tx_pll_sel txpll data_rate pma_clk_div} {
    
   if { $family == "Cyclone V" } {
      add_instance                  $phy_name   altera_xcvr_native_cv
      set_instance_parameter_value  $phy_name   enable_std                 1
   } elseif { $family == "Arria V" } {
      add_instance                  $phy_name   altera_xcvr_native_av
      set_instance_parameter_value  $phy_name   enable_std                 1
   } elseif { $family == "Arria V GZ" } {
      add_instance                  $phy_name   altera_xcvr_native_avgz
      set_instance_parameter_value  $phy_name   enable_std                 1
   } else {
      add_instance                  $phy_name   altera_xcvr_native_sv
      set_instance_parameter_value  $phy_name   enable_std                 1
   }
   
   if { $xcvr_tx_pll_sel } {
      set txpll_num 2
      set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll1_data_rate       $pll1_data_rate
      set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll1_refclk_freq     $pll_refclk_freq1
      set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll1_refclk_sel      1
      set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll1_pll_type        $pll_type
    } else {
      set txpll_num 1
    }
   
   set_instance_parameter_value   $phy_name   set_data_rate                         $data_rate
   set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll0_refclk_freq     $pll_refclk_freq0
   
   set_instance_parameter_value   $phy_name   set_cdr_refclk_freq                   $pll_refclk_freq0
   set_instance_parameter_value   $phy_name   pma_direct_width                      10
   set_instance_parameter_value   $phy_name   std_pcs_pma_width                     10
   set_instance_parameter_value   $phy_name   std_tx_byte_ser_enable                1
   set_instance_parameter_value   $phy_name   std_rx_byte_deser_enable              1
   set_instance_parameter_value   $phy_name   plls                                  $txpll_num
   set_instance_parameter_value   $phy_name   pll_refclk_cnt                        $txpll_num
   set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll0_data_rate       $pll0_data_rate
   set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll0_refclk_sel      0
   set_instance_parameter_value   $phy_name   gui_pll_reconfig_pll0_pll_type        $pll_type
   set_instance_parameter_value   $phy_name   tx_pma_clk_div			    $pma_clk_div
   
   if { $dir == "tx" } {
      set_instance_parameter_value   $phy_name   rx_enable                        0
   } elseif { $dir == "rx" } {
      set_instance_parameter_value   $phy_name   tx_enable                        0
   }
   
   if { $dir == "du" || $dir == "tx" } {
      if { $video_std == "ds" || $video_std == "tr" || $xcvr_tx_pll_sel } {
         set_instance_parameter_value $phy_name  pll_reconfig_enable              true
      } else {
         set_instance_parameter_value $phy_name  pll_reconfig_enable              false
      }

      add_instance                   $tx_xcvr_rst_name   altera_xcvr_reset_control
      if { $pll_refclk_freq0 == "148.5 MHz" } {
        set_instance_parameter_value   $tx_xcvr_rst_name   SYS_CLK_IN_MHZ            148
      } elseif { $pll_refclk_freq0 == "74.25 MHz" } {
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
      if { $video_std == "ds" || $video_std == "tr"  || $xcvr_tx_pll_sel } {
         set_instance_parameter_value $phy_name   cdr_reconfig_enable              true
      } else {
         set_instance_parameter_value $phy_name   cdr_reconfig_enable              false
      }

      add_instance                   $rx_xcvr_rst_name   altera_xcvr_reset_control
      if { $pll_refclk_freq0 == "148.5 MHz" } {
        set_instance_parameter_value   $rx_xcvr_rst_name   SYS_CLK_IN_MHZ            148
      } elseif { $pll_refclk_freq0 == "74.25 MHz" } {
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
