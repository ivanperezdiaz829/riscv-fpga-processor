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


# +----------------------------------
# | 
# | SDI II Testbench v12.1
# | Altera Corporation 2009.08.19.17:10:07
# | 
# +-----------------------------------

package require -exact sopc 11.0

source ../sdi_ii/sdi_ii_params.tcl
source ../sdi_ii/sdi_ii_ed.tcl
source ../sdi_ii/sdi_ii_interface.tcl

# +-----------------------------------
# | module SDI II Testbench
# | 
set_module_property DESCRIPTION "SDI II Testbench"
set_module_property NAME sdi_ii_tb
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/SDI II Testbench"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II Testbench"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
set_module_property COMPOSE_CALLBACK compose_callback
set_module_property SIMULATION_MODEL_IN_VERILOG true
set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property HIDE_FROM_QSYS true
# | 
# +-----------------------------------

# +-----------------------------------
# | IP core, testbench, example design
# | Common parameters
# |
sdi_ii_common_params

# +-----------------------------------
# | Testbench, Example Design 
# | Common parameters
# |
sdi_ii_tb_ed_common_params
sdi_ii_ed_reconfig_params

# +-----------------------------------
# | Testbench 
# | Specific parameters
# |
sdi_ii_test_params
sdi_ii_test_pattgen_params
sdi_ii_test_multi_ch_params

# set_parameter_property    TEST_LN_OUTPUT        HDL_PARAMETER true
# set_parameter_property    TEST_RECONFIG_SEQ     HDL_PARAMETER true
# set_parameter_property    TEST_DISTURB_SERIAL   HDL_PARAMETER true
# set_parameter_property    TEST_DATA_COMPARE     HDL_PARAMETER true
# set_parameter_property    TEST_DL_SYNC          HDL_PARAMETER true
# set_parameter_property    TEST_TRS_LOCKED       HDL_PARAMETER true
# set_parameter_property    TEST_FRAME_LOCKED     HDL_PARAMETER true
# set_parameter_property    TEST_VPID_OVERWRITE   HDL_PARAMETER true
# set_parameter_property    TEST_MULTI_RECON      HDL_PARAMETER true
# set_parameter_property    IS_RTL_SIM            HDL_PARAMETER true
# set_parameter_property    TEST_RESET_RECON      HDL_PARAMETER true
# set_parameter_property    TEST_RXSAMPLE_CHK     HDL_PARAMETER true

# +-----------------------------------
# | Compose Callback
# |
proc compose_callback {} {
    #_dprint 1 "Running IP Compose for [get_module_property NAME]"
   
    set  fam              [get_parameter_value FAMILY]
    set  dir              [get_parameter_value DIRECTION]
    set  config           [get_parameter_value TRANSCEIVER_PROTOCOL]
    set  video_std        [get_parameter_value VIDEO_STANDARD]
    set  crc_err          [get_parameter_value RX_CRC_ERROR_OUTPUT]
    set  a2b              [get_parameter_value RX_EN_A2B_CONV]
    set  b2a              [get_parameter_value RX_EN_B2A_CONV]
    set  disturb_serial   [get_parameter_value TEST_DISTURB_SERIAL]
    set  dl_sync          [get_parameter_value TEST_DL_SYNC]
    set  cmp_data         [get_parameter_value TEST_DATA_COMPARE]
    set  insert_vpid      [get_parameter_value TX_EN_VPID_INSERT]
    set  extract_vpid     [get_parameter_value RX_EN_VPID_EXTRACT] 
    set  trs_test         [get_parameter_value TEST_TRS_LOCKED]
    set  frame_test       [get_parameter_value TEST_FRAME_LOCKED]
    set  err_vpid         [get_parameter_value TEST_ERR_VPID]
    set  multi_reconfig   [get_parameter_value TEST_MULTI_RECON]
    set  reset_reconfig   [get_parameter_value TEST_RESET_RECON]
    set  rxsample_test    [get_parameter_value TEST_RXSAMPLE_CHK]
    set  xcvr_tx_pll_sel  [get_parameter_value XCVR_TX_PLL_SEL]
    set  xcvr_tx_pll_recon [get_parameter_value TEST_TXPLL_RECONFIG]
    set  hd_frequency 	  [get_parameter_value HD_FREQ]
     
    # Derive the desired variation name of each sub instances 
    # (eg du xcvr, du proto) in a core
    derive_instance_name  $dir  $config  $video_std
    
    # Instantiate example design component
    add_instance  example_design   sdi_ii_example_design
    set  inst1  [get_parameter_value INST1]
    set  inst2  [get_parameter_value INST2]
    set  inst3  [get_parameter_value INST3]
    set  inst4  [get_parameter_value INST4]
   
    # Propagate the value of parameters to the example design component
    propagate_params  example_design
    #foreach param_name [get_instance_parameters example_design] {
    #  set_instance_parameter example_design $param_name [get_parameter_value $param_name]
    #}

    # Adding test components
    add_instance      tb_test_control  sdi_ii_tb_control
    propagate_params  tb_test_control
    add_instance      tb_tx_checker    sdi_ii_tb_tx_checker
    propagate_params  tb_tx_checker
    add_instance      tb_rx_checker    sdi_ii_tb_rx_checker
    propagate_params  tb_rx_checker

    if { $extract_vpid & !$insert_vpid } {
      set_instance_parameter tb_rx_checker   TEST_GEN_ANC 1
      set_instance_parameter tb_rx_checker   TEST_GEN_VPID 1
    }
    
    # Extra Rx checked is needed for multi-channel test
    if { $multi_reconfig } {

      add_instance            tb_rx_checker_ch0  sdi_ii_tb_rx_checker
      propagate_params        tb_rx_checker_ch0
      set_instance_parameter  tb_rx_checker_ch0  CH_NUMBER             0
      if { $video_std == "tr"} {
        set_instance_parameter  tb_rx_checker_ch0  TX_EN_VPID_INSERT     1
      } else {
        set_instance_parameter  tb_rx_checker_ch0  TX_EN_VPID_INSERT     0
      }
    }

    # For level A (HD-DL) to level B (3Gb) conversion demo, the tx/rx checker could be configured
    # to become tr or 3g checker. To ease maintanance effort, force to 3g. 
    if { $a2b } {

      # set insert_vpid         1
      set_instance_parameter  tb_tx_checker  VIDEO_STANDARD  threeg
      set_instance_parameter  tb_rx_checker  VIDEO_STANDARD  threeg

    }

    # For level B (3Gb) to level A (HD-DL) conversion demo, configure the tx/rx checker to become dl
    if { $b2a } {

      # set insert_vpid         1
      set_instance_parameter  tb_tx_checker  VIDEO_STANDARD  dl
      set_instance_parameter  tb_rx_checker  VIDEO_STANDARD  dl

    }

    #add_instance            tb_fanout_serial_a  altera_fanout
    #set_instance_parameter  tb_fanout_serial_a  WIDTH 1

    #TEMP # Apply all the parameters
    #TEMP foreach param_name [get_instance_parameters dut] {
    #TEMP   #_dprint 1 "Assigning parameter $param_name = [get_parameter_value $param_name] for dut"
    #TEMP   set_instance_parameter dut $param_name [get_parameter_value $param_name]
    #TEMP }

    # Clock and reset connections for IP cores at ch0
    # ch0 is only used for multi-channel test
    # If it is unused, best to connect the clk and rst to avoid generation error 
    add_connection  tb_test_control.tx_rst_ch0      example_design.ch0_du_tx_rst
    add_connection  tb_test_control.rx_rst_ch0      example_design.ch0_du_rx_rst

    add_connection  tb_test_control.rx_xcvr_refclk  example_design.ch0_du_xcvr_refclk
    if { $hd_frequency == "74.25" } {
      add_connection  tb_test_control.rx_coreclk      example_design.ch0_du_rx_coreclk_hd
      add_connection  tb_test_control.tx_coreclk      example_design.ch0_du_tx_coreclk_hd
    } else {
      add_connection  tb_test_control.rx_coreclk      example_design.ch0_du_rx_coreclk
      add_connection  tb_test_control.tx_coreclk      example_design.ch0_du_tx_coreclk
    }
    #if { $fam == "Stratix V" || $fam == "Arria V" || $fam == "Arria V GZ"} {
    #   add_connection  tb_test_control.rx_rst_ch0      example_design.ch0_du_phy_mgmt_clk_rst
    #   add_connection  tb_test_control.phy_mgmt_clk    example_design.ch0_du_phy_mgmt_clk
    #}

    if { $fam != "Arria 10"} {
       if { $reset_reconfig } {
         add_connection  tb_test_control.reconfig_rst  example_design.reconfig_rst ;# use reconfig_rst for reconfig_rst, for reset during reconfig test
       } else {
         add_connection  tb_test_control.rx_rst        example_design.reconfig_rst ;# use rx_rst for reconfig_rst, will be synchronized to reconfig_clk domain in ed
       }
    }

    #add_connection  tb_test_control.tx_rst  example_design.tx_rst 
    #add_connection  tb_test_control.rx_rst  example_design.rx_rst
    #add_connection  tb_test_control.rx_rst  example_design.reconfig_rst 

    ##if { $fam == "Stratix V" | $fam == "Arria V" } {
    #  if { $dir == "du" } {
    #    add_connection  tb_test_control.rx_rst  example_design.du_phy_mgmt_clk_rst
    #  } else {
    #    add_connection  tb_test_control.tx_rst  example_design.tx_phy_mgmt_clk_rst
    #    add_connection  tb_test_control.rx_rst  example_design.rx_phy_mgmt_clk_rst        
    #  }
    ##}

    #add_connection  tb_test_control.tx_rst          example_design.tx_ch0_rst
    #add_connection  tb_test_control.rx_rst          example_design.rx_ch0_rst
    #add_connection  tb_test_control.rx_rst          example_design.du_phy_mgmt_clk_ch0_rst
    #add_connection  tb_test_control.rx_xcvr_refclk  example_design.du_xcvr_refclk_ch0

    # Reset connections for IP cores at ch1
    if { $dir == "du" } {
       #if { $fam == "Stratix V" || $fam == "Arria V" || $fam == "Arria V GZ"} {
       #   add_connection  tb_test_control.rx_phy_mgmt_clk_rst  example_design.ch1_du_phy_mgmt_clk_rst
       #}
       add_connection  tb_test_control.tx_rst               example_design.ch1_du_tx_rst
       add_connection  tb_test_control.rx_rst               example_design.ch1_du_rx_rst

    } else {
       #if { $fam == "Stratix V" || $fam == "Arria V" || $fam == "Arria V GZ"} {
       #   add_connection  tb_test_control.tx_phy_mgmt_clk_rst  example_design.ch1_tx_phy_mgmt_clk_rst
       #   add_connection  tb_test_control.rx_phy_mgmt_clk_rst  example_design.ch1_rx_phy_mgmt_clk_rst
       #}
       add_connection  tb_test_control.rx_rst               example_design.ch1_rx_rst
       add_connection  tb_test_control.tx_rst               example_design.ch1_tx_rst        

    }
	
	       
    if { $xcvr_tx_pll_sel | $xcvr_tx_pll_recon } {
         add_connection          tb_test_control.tx_xcvr_refclk_alt              example_design.ch1_${dir}_xcvr_refclk_alt
         #add_connection          tb_test_control.tx_xcvr_refclk_sel              example_design.ch1_du_xcvr_refclk_sel       
         add_connection          tb_test_control.tx_sdi_pll_sel                  example_design.ch1_${dir}_tx_sdi_pll_sel
         add_connection          example_design.ch1_${dir}_tx_sdi_reconfig_done  tb_rx_checker.tx_sdi_reconfig_done
         #add_connection          example_design.${inst2}_tx_pll_locked           tb_tx_checker.tx_pll_locked
         #add_connection          example_design.${inst2}_tx_pll_locked_alt       tb_tx_checker.tx_pll_locked_alt
         add_connection          example_design.${inst2}_tx_clkout               tb_tx_checker.tx_clkout
         add_connection          tb_tx_checker.tx_clkout_match                   tb_test_control.tx_clkout_match
         add_connection          tb_rx_checker.rx_check_posedge                  tb_test_control.rx_check_posedge
         add_instance            tb_fanout_tx_sdi_start_reconfig                 altera_fanout
         set_instance_parameter  tb_fanout_tx_sdi_start_reconfig                 WIDTH 1
	 add_connection          tb_test_control.tx_sdi_start_reconfig           tb_fanout_tx_sdi_start_reconfig.sig_input
	 add_connection          tb_fanout_tx_sdi_start_reconfig.sig_fanout0     tb_rx_checker.tx_sdi_start_reconfig
	 add_connection          tb_fanout_tx_sdi_start_reconfig.sig_fanout1     example_design.ch1_${dir}_tx_sdi_start_reconfig		 
    }
	
	
       # if { $xcvr_tx_pll_sel | $xcvr_tx_pll_recon } {
         # add_connection  tb_test_control.tx_xcvr_refclk_alt         example_design.ch1_tx_xcvr_refclk_alt
         # #add_connection  tb_test_control.tx_xcvr_refclk_sel         example_design.ch1_tx_xcvr_refclk_sel
         # add_connection  tb_test_control.tx_sdi_start_reconfig      example_design.ch1_tx_tx_sdi_start_reconfig
         # add_connection  tb_test_control.tx_sdi_pll_sel             example_design.ch1_tx_tx_sdi_pll_sel
         # add_connection  example_design.ch1_tx_tx_sdi_reconfig_done tb_rx_checker.tx_sdi_reconfig_done
         # add_connection  example_design.${inst2}_tx_clkout          tb_tx_checker.tx_clkout
         # add_connection  tb_tx_checker.tx_clkout_match              tb_test_control.tx_clkout_match
         # add_connection  tb_rx_checker.rx_check_posedge             tb_test_control.rx_check_posedge
	 # add_instance            tb_fanout_tx_sdi_start_reconfig                 altera_fanout
         # set_instance_parameter  tb_fanout_tx_sdi_start_reconfig                 WIDTH 1
	 # add_connection          tb_test_control.tx_sdi_start_reconfig           tb_fanout_tx_sdi_start_reconfig.sig_input
	 # add_connection          tb_fanout_tx_sdi_start_reconfig.sig_fanout0     tb_rx_checker.tx_sdi_start_reconfig
	 # add_connection          tb_fanout_tx_sdi_start_reconfig.sig_fanout1     example_design.ch1_tx_tx_sdi_start_reconfig	
    # }
    # Clock connections for IP cores at ch1
    if { $dir == "du" } {

       add_connection  tb_test_control.rx_xcvr_refclk  example_design.ch1_du_xcvr_refclk

       
       if { $hd_frequency == "74.25" } {
         add_connection  tb_test_control.rx_coreclk      example_design.ch1_du_rx_coreclk_hd
         add_connection  tb_test_control.tx_coreclk      example_design.ch1_du_tx_coreclk_hd
       } else {
         add_connection  tb_test_control.rx_coreclk      example_design.ch1_du_rx_coreclk
         add_connection  tb_test_control.tx_coreclk      example_design.ch1_du_tx_coreclk
       }
       #if { $fam == "Stratix V" || $fam == "Arria V" || $fam == "Arria V GZ"} {
       #   add_connection  tb_test_control.phy_mgmt_clk    example_design.ch1_du_phy_mgmt_clk
       #}
    } else {

       add_connection  tb_test_control.tx_xcvr_refclk  example_design.ch1_tx_xcvr_refclk
       add_connection  tb_test_control.rx_xcvr_refclk  example_design.ch1_rx_xcvr_refclk
       if { $hd_frequency == "74.25" } {
         add_connection  tb_test_control.rx_coreclk      example_design.ch1_rx_coreclk_hd
         add_connection  tb_test_control.tx_coreclk      example_design.ch1_tx_coreclk_hd
       } else {
         add_connection  tb_test_control.rx_coreclk      example_design.ch1_rx_coreclk 
         add_connection  tb_test_control.tx_coreclk      example_design.ch1_tx_coreclk 
       }
       #if { $fam == "Stratix V" || $fam == "Arria V" || $fam == "Arria V GZ"} {
       #   add_connection  tb_test_control.phy_mgmt_clk    example_design.ch1_rx_phy_mgmt_clk
       #   add_connection  tb_test_control.phy_mgmt_clk    example_design.ch1_tx_phy_mgmt_clk
       #}
    }

    #if { $multi_reconfig } {
    #  # Reset connections for IP cores
    #  add_connection  tb_test_control.tx_rst  example_design.tx_ch0_rst 
    #  add_connection  tb_test_control.rx_rst  example_design.rx_ch0_rst
    #  if { $fam == "Stratix V" | $fam == "Arria V" } {
    #      add_connection  tb_test_control.rx_rst  example_design.du_phy_mgmt_clk_ch0_rst
    #}

    #  # Clock connections for IP cores
    #  if { $fam == "Stratix V" | $fam == "Arria V" } {
    #    add_connection  tb_test_control.rx_xcvr_refclk  example_design.du_xcvr_refclk_ch0
    #  }
    #}

    #add_connection  tb_test_control.rx_coreclk  example_design.rx_coreclk
    #if { $fam == "Stratix V" | $fam== "Arria V" } {
    #  if { $dir == "du" } {
    #    add_connection  tb_test_control.rx_xcvr_refclk  example_design.du_xcvr_refclk
    #  } else {
    #    add_connection  tb_test_control.tx_xcvr_refclk  example_design.tx_xcvr_refclk
    #    add_connection  tb_test_control.rx_xcvr_refclk  example_design.rx_xcvr_refclk
    #  }
    #}
    
    #if { $fam == "Stratix V" | $fam== "Arria V" } {
    #    add_connection tb_test_control.phy_mgmt_clk  example_design.phy_mgmt_clk
    #} else {
    #    add_connection tb_test_control.tx_coreclk  example_design.tx_coreclk
    #}
    
    # Control signals connections
    add_connection  tb_test_control.pattgen_bar_100_75n  example_design.pattgen_bar_100_75n
    #add_connection  tb_test_control.pattgen_enable       example_design.pattgen_enable
    add_connection  tb_test_control.pattgen_patho        example_design.pattgen_patho
    add_connection  tb_test_control.pattgen_blank        example_design.pattgen_blank
    add_connection  tb_test_control.pattgen_no_color     example_design.pattgen_no_color
    add_connection  tb_test_control.pattgen_sgmt_frame   example_design.pattgen_sgmt_frame
    add_connection  tb_test_control.pattgen_dl_mapping   example_design.pattgen_dl_mapping
    add_connection  tb_test_control.pattgen_tx_format    example_design.pattgen_tx_format
    add_connection  tb_test_control.pattgen_ntsc_paln    example_design.pattgen_ntsc_paln
    
    if { $multi_reconfig } {
      add_instance            dl_mapping_fanout                  altera_fanout
      set_instance_parameter  dl_mapping_fanout                  WIDTH                        1
      add_connection          tb_test_control.rx_chk_dl_mapping  dl_mapping_fanout.sig_input
      add_connection          dl_mapping_fanout.sig_fanout0      tb_rx_checker.dl_mapping
      add_connection          dl_mapping_fanout.sig_fanout1      tb_rx_checker_ch0.dl_mapping

    } else {
      add_connection          tb_test_control.rx_chk_dl_mapping  tb_rx_checker.dl_mapping
    }
  
    # Control signals connections for TX inputs
    #if { $dir == "du" } {
    #  if { $fam == "Stratix V" | $fam == "Arria V" } {
    #    ##
    #  } else {
    #    add_connection  tb_test_control.sdi_gxb_powerdown  example_design.${inst2}_gxb_powerdown
    #  }
    #} else {
    #  if { $fam == "Stratix V" | $fam == "Arria V" } {
    #    ##
    #  } else {
    #    add_instance            tb_fanout1                         altera_fanout
    #    set_instance_parameter  tb_fanout1
    #    add_connection          tb_test_control.sdi_gxb_powerdown  tb_fanout1.sig_input
    #    add_connection          tb_fanout1.sig_fanout0             example_design.${inst2}_gxb_powerdown
    #    add_connection          tb_fanout1.sig_fanout1             example_design.${inst4}_gxb_powerdown
    #  }
    #}
    if { $video_std != "sd" } {
      add_connection  tb_test_control.tx_enable_crc  example_design.${inst1}_tx_enable_crc       
      add_connection  tb_test_control.tx_enable_ln   example_design.${inst1}_tx_enable_ln
    }

    if { $insert_vpid } {
      # add_connection  tb_test_control.tx_enable_vpid_c   example_design.${inst1}_tx_enable_vpid_c
      add_connection  tb_test_control.tx_vpid_overwrite  example_design.${inst1}_tx_vpid_overwrite
    }

    # if { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
    #  # set_instance_parameter   tx_std_fanout  NUM_FANOUT 3
    # } else {
    #
    # }
    
    if { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {

      add_connection  tb_test_control.tx_std          example_design.${inst1}_tx_std
      add_connection  tb_test_control.pattgen_tx_std  example_design.pattgen_tx_std

    } else {

      add_connection  tb_test_control.pattgen_tx_std  example_design.pattgen_tx_std

    }

    #add_connection  tx_std_fanout.sig_fanout2      tb_checker_serial.tx_std
    add_connection  tb_test_control.tx_chk_tx_std  tb_tx_checker.tx_std

    # Determine the TX and RX cores that need to be checked against
    if { $a2b } {

      set  tx_to_check    ch2_smpte372_tx_3g
      set  rx_to_control  ch2_smpte372_rx_3g
      set  rx_to_check    ch2_smpte372_rx_3g
 
    } elseif { $b2a } {

      set  tx_to_check    ch2_smpte372_tx_dl
      set  rx_to_control  ch2_smpte372_rx_dl
      set  rx_to_check    ch2_smpte372_rx_dl

    } else {

      set  tx_to_check    $inst2
      set  rx_to_control  $inst4
      set  rx_to_check    $inst3

    }
    
    # Clocks and resets connection for secondary IP cores which used for SMPTE 372M level A/B conversion demo
    if { $a2b | $b2a } {
      #if { $fam == "Stratix V" || $fam == "Arria V" || $fam == "Arria V GZ"} {
      #   add_connection  tb_test_control.phy_mgmt_clk_smpte372  example_design.ch2_smpte372_tx_phy_mgmt_clk
      #   add_connection  tb_test_control.phy_mgmt_clk_smpte372  example_design.ch2_smpte372_rx_phy_mgmt_clk
      #}
      #if { $fam == "Stratix V" | $fam== "Arria V" } {
      #
      #  add_connection  tb_test_control.phy_mgmt_clk_smpte372  example_design.phy_mgmt_clk_smpte372
      #
      #} else {
      #
      #  add_connection  tb_test_control.tx_coreclk_smpte372 example_design.tx_coreclk_smpte372
      #}

      if { $video_std == "dl" } {
        add_connection  tb_test_control.rx_coreclk_smpte372      example_design.ch2_smpte372_rx_coreclk
        add_connection  tb_test_control.tx_coreclk_smpte372      example_design.ch2_smpte372_tx_coreclk
      } else {
        add_connection  tb_test_control.rx_coreclk_smpte372      example_design.ch2_smpte372_rx_coreclk
        add_connection  tb_test_control.tx_coreclk_smpte372      example_design.ch2_smpte372_tx_coreclk
      }
      add_connection  tb_test_control.rx_xcvr_refclk_smpte372  example_design.ch2_smpte372_rx_xcvr_refclk
      add_connection  tb_test_control.tx_xcvr_refclk_smpte372  example_design.ch2_smpte372_tx_xcvr_refclk
      add_connection  tb_test_control.tx_rst_smpte372          example_design.ch2_smpte372_tx_rst
      add_connection  tb_test_control.rx_rst_smpte372          example_design.ch2_smpte372_rx_rst
      #if { $fam == "Stratix V" || $fam == "Arria V" || $fam == "Arria V GZ"} {
      #   add_connection  tb_test_control.tx_rst_smpte372          example_design.ch2_smpte372_tx_phy_mgmt_clk_rst
      #   add_connection  tb_test_control.rx_rst_smpte372          example_design.ch2_smpte372_rx_phy_mgmt_clk_rst
      #}
      add_connection  tb_test_control.rx_rst_proto             example_design.${inst4}_rx_rst_proto_out
    }  

    add_connection  tb_test_control.rx_chk_rst  tb_rx_checker.ref_rst

    if { $multi_reconfig } {

      add_connection  tb_test_control.rx_chk_rst  tb_rx_checker_ch0.ref_rst

    }

    # Control signals connections for Rx inputs
    # add_instance            tb_fanout_enable_sd_search           altera_fanout
    # set_instance_parameter  tb_fanout_enable_sd_search           WIDTH 1
    # add_connection          tb_test_control.rx_enable_sd_search  tb_fanout_enable_sd_search.sig_input
    
    # add_instance            tb_fanout_enable_hd_search           altera_fanout
    # set_instance_parameter  tb_fanout_enable_hd_search           WIDTH 1
    # add_connection          tb_test_control.rx_enable_hd_search  tb_fanout_enable_hd_search.sig_input
    
    # add_instance            tb_fanout_enable_3g_search           altera_fanout
    # set_instance_parameter  tb_fanout_enable_3g_search           WIDTH 1
    # add_connection          tb_test_control.rx_enable_3g_search  tb_fanout_enable_3g_search.sig_input
    
    # if { $b2a } {

      # add_connection  tb_fanout_enable_sd_search.sig_fanout0  example_design.${inst4}_rx_enable_sd_search
      # add_connection  tb_fanout_enable_hd_search.sig_fanout0  example_design.${inst4}_rx_enable_hd_search
      # add_connection  tb_fanout_enable_3g_search.sig_fanout0  example_design.${inst4}_rx_enable_3g_search

    # } else {

      # add_connection  tb_fanout_enable_sd_search.sig_fanout0  example_design.${rx_to_control}_rx_enable_sd_search
      # add_connection  tb_fanout_enable_hd_search.sig_fanout0  example_design.${rx_to_control}_rx_enable_hd_search
      # add_connection  tb_fanout_enable_3g_search.sig_fanout0  example_design.${rx_to_control}_rx_enable_3g_search

    # }

    # if { $multi_reconfig } {

      # add_connection  tb_fanout_enable_sd_search.sig_fanout1  example_design.ch0_loopback_du_${video_std}_rx_enable_sd_search
      # add_connection  tb_fanout_enable_hd_search.sig_fanout1  example_design.ch0_loopback_du_${video_std}_rx_enable_hd_search
      # add_connection  tb_fanout_enable_3g_search.sig_fanout1  example_design.ch0_loopback_du_${video_std}_rx_enable_3g_search 
 
    # }

    #TEMP # Status signals connections (DUT Tx output)
    #TEMP add_connection     example_design.tx_clkout 
    
    #add_connection  example_design.${tx_to_check}_tx_pll_locked     tb_tx_checker.tx_status
    #add_connection  tb_test_control.chk_tx                          tb_tx_checker.chk_tx
    #add_connection  tb_test_control.serial_rx                       example_design.${rx_to_control}_sdi_rx


    add_connection          tb_test_control.tx_status                       tb_tx_checker.tx_status
    add_connection          tb_test_control.tx_chk_start_chk                tb_tx_checker.chk_tx
    add_connection          example_design.${tx_to_check}_tx_pll_locked     tb_test_control.tx_pll_locked
    
    if { $xcvr_tx_pll_sel } {
        add_connection  example_design.${tx_to_check}_tx_pll_locked_alt     tb_test_control.tx_pll_locked_alt
    }

    # Data signal connections (Serial loopback)
    add_instance            tb_fanout_serial_a                    altera_fanout
    set_instance_parameter  tb_fanout_serial_a                    WIDTH 1

    if { $multi_reconfig } {
      set_instance_parameter  tb_fanout_serial_a                  NUM_FANOUT  3
    } else {
      set_instance_parameter  tb_fanout_serial_a                  NUM_FANOUT  2
    }

    add_connection          example_design.${tx_to_check}_sdi_tx  tb_fanout_serial_a.sig_input
    
    if { ($video_std == "dl" & !$a2b) | $b2a } {

      add_instance            tb_fanout_serial_b                      altera_fanout
      set_instance_parameter  tb_fanout_serial_b                      WIDTH 1
      add_connection          example_design.${tx_to_check}_sdi_tx_b  tb_fanout_serial_b.sig_input

    }

    if { $disturb_serial | $dl_sync | $trs_test | $frame_test } {

      add_connection  tb_fanout_serial_a.sig_fanout0  tb_test_control.tx_sdi_serial
      add_connection  tb_fanout_serial_a.sig_fanout1  tb_tx_checker.sdi_serial
      add_connection  tb_test_control.rx_sdi_serial   example_design.${rx_to_control}_sdi_rx
      
      if { $multi_reconfig } {

        add_connection  tb_test_control.rx_sdi_serial_ch0  example_design.ch0_loopback_du_${video_std}_sdi_rx

      }            

      if { $a2b } {

        add_connection  example_design.${inst2}_sdi_tx    example_design.${inst4}_sdi_rx
        add_connection  example_design.${inst2}_sdi_tx_b  example_design.${inst4}_sdi_rx_b

      } elseif { $b2a } {

        add_connection  example_design.${inst2}_sdi_tx   example_design.${inst4}_sdi_rx
        add_connection  tb_fanout_serial_b.sig_fanout0   tb_test_control.tx_sdi_serial_b
        add_connection  tb_fanout_serial_b.sig_fanout1   tb_tx_checker.sdi_serial_b
        add_connection  tb_test_control.rx_sdi_serial_b  example_design.${rx_to_control}_sdi_rx_b

      } else {

        if { $video_std == "dl" } {

          add_connection  tb_fanout_serial_b.sig_fanout0   tb_test_control.tx_sdi_serial_b
          add_connection  tb_fanout_serial_b.sig_fanout1   tb_tx_checker.sdi_serial_b
          add_connection  tb_test_control.rx_sdi_serial_b  example_design.${rx_to_control}_sdi_rx_b

        }
      }

    } else {

      add_connection  tb_fanout_serial_a.sig_fanout0  example_design.${rx_to_control}_sdi_rx
      add_connection  tb_fanout_serial_a.sig_fanout1  tb_tx_checker.sdi_serial
      
      if { $multi_reconfig } {

        if { $disturb_serial == "0" } {

          add_connection  tb_fanout_serial_a.sig_fanout2   tb_test_control.tx_sdi_serial

        }

        add_connection  tb_test_control.rx_sdi_serial_ch0  example_design.ch0_loopback_du_${video_std}_sdi_rx

      }

      if { $a2b } {

        add_connection  example_design.${inst2}_sdi_tx    example_design.${inst4}_sdi_rx
        add_connection  example_design.${inst2}_sdi_tx_b  example_design.${inst4}_sdi_rx_b

      } elseif { $b2a } {

        add_connection  example_design.${inst2}_sdi_tx   example_design.${inst4}_sdi_rx
        add_connection  tb_fanout_serial_b.sig_fanout0   example_design.${rx_to_control}_sdi_rx_b
        add_connection  tb_fanout_serial_b.sig_fanout1   tb_tx_checker.sdi_serial_b

      } else {

        if { $video_std == "dl" } {

          add_connection  tb_fanout_serial_b.sig_fanout0  example_design.${rx_to_control}_sdi_rx_b
          add_connection  tb_fanout_serial_b.sig_fanout1  tb_tx_checker.sdi_serial_b

        }
      }
    }

    # Rx/Tx outputs -> checker connections


    add_connection  example_design.${rx_to_check}_rx_clkout  tb_rx_checker.rx_clk
    if { $fam != "Arria 10"} {
       add_connection  tb_test_control.reconfig_clk             example_design.reconfig_clk
    }
    #if { $fam == "Stratix V" | $fam == "Arria V" } {
    #  ##
    #} else {
    #  add_connection  tb_test_control.clk_fpga  example_design.clk_fpga    
    #}

    add_connection  tb_test_control.tx_chk_refclk                  tb_tx_checker.ref_clk
    #add_connection  tb_test_control.tx_coreclk                     example_design.ch1_tx_coreclk
    add_connection  tb_test_control.rx_chk_refclk                  tb_rx_checker.rx_refclk
    add_connection  example_design.${rx_to_check}_rx_align_locked  tb_rx_checker.align_locked
    add_connection  example_design.${rx_to_check}_rx_trs_locked    tb_rx_checker.trs_locked
    add_connection  example_design.${rx_to_check}_rx_frame_locked  tb_rx_checker.frame_locked
    add_connection  example_design.${rx_to_check}_rx_f             tb_rx_checker.rx_f
    add_connection  example_design.${rx_to_check}_rx_v             tb_rx_checker.rx_v
    add_connection  example_design.${rx_to_check}_rx_h             tb_rx_checker.rx_h
    add_connection  example_design.${rx_to_check}_rx_ap            tb_rx_checker.rx_ap
    add_connection  tb_rx_checker.rxcheck_done                     tb_test_control.rx_chk_done
    add_connection  tb_test_control.rx_chk_start_chk               tb_rx_checker.chk_rx
    add_connection  tb_rx_checker.chk_completed                    tb_test_control.rx_chk_completed

    if { $multi_reconfig } {
       add_instance             tb_fanout_tx_format                altera_fanout
       set_instance_parameter   tb_fanout_tx_format                WIDTH         4
       add_connection           tb_test_control.rx_chk_tx_format   tb_fanout_tx_format.sig_input

       add_connection           tb_fanout_tx_format.sig_fanout0    tb_rx_checker.tx_format
    } else {
       add_connection           tb_test_control.rx_chk_tx_format   tb_rx_checker.tx_format
    }

    if { $video_std != "sd" } {
      add_connection  example_design.${rx_to_check}_rx_ln            tb_rx_checker.rx_ln
    }
    if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {
      add_connection  example_design.${rx_to_check}_rx_ln_b          tb_rx_checker.rx_ln_b
    }

    if { (($video_std == "ds" | $video_std == "tr") & !$b2a)} {

       add_instance            tb_fanout_rx_sdi_start_reconfig                            altera_fanout
       set_instance_parameter  tb_fanout_rx_sdi_start_reconfig                            WIDTH 1
       add_connection          example_design.${rx_to_control}_rx_sdi_start_reconfig      tb_fanout_rx_sdi_start_reconfig.sig_input
       add_connection          tb_fanout_rx_sdi_start_reconfig.sig_fanout0                tb_rx_checker.rx_sdi_start_reconfig
       if { $reset_reconfig } {
          add_connection          tb_fanout_rx_sdi_start_reconfig.sig_fanout1                tb_test_control.rx_sdi_start_reconfig
       }
    }

    if { ($video_std == "dl" & !$a2b) | $b2a } {

       add_connection  example_design.${rx_to_check}_rx_align_locked_b   tb_rx_checker.align_locked_b
       add_connection  example_design.${rx_to_check}_rx_trs_locked_b     tb_rx_checker.trs_locked_b
       add_connection  example_design.${rx_to_check}_rx_dl_locked        tb_rx_checker.dl_locked
       add_connection  example_design.${rx_to_check}_rx_frame_locked_b   tb_rx_checker.frame_locked_b
       add_connection  example_design.${rx_to_check}_rx_dataout_b        tb_rx_checker.rxdata_b
       add_connection  example_design.${rx_to_check}_rx_dataout_valid_b  tb_rx_checker.rxdata_valid_b

    }

    if { $crc_err } {

       add_connection  example_design.${rx_to_check}_rx_crc_error_c  tb_rx_checker.rx_crc_error_c
       add_connection  example_design.${rx_to_check}_rx_crc_error_y  tb_rx_checker.rx_crc_error_y

       if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {

          add_connection  example_design.${rx_to_check}_rx_crc_error_c_b  tb_rx_checker.rx_crc_error_c_b
          add_connection  example_design.${rx_to_check}_rx_crc_error_y_b  tb_rx_checker.rx_crc_error_y_b

       }
    }

    if { $frame_test } {
      add_connection  example_design.${rx_to_check}_rx_format  tb_rx_checker.rx_format
    } 

    if { $trs_test | $frame_test | $rxsample_test | $dl_sync } {

      add_connection  example_design.${rx_to_check}_rx_eav  tb_rx_checker.rx_eav
      add_connection  example_design.${rx_to_check}_rx_trs  tb_rx_checker.rx_trs
 
    }    

    # if { $video_std == "threeg" | $video_std == "ds" | $video_std == "tr" } {
    # if { !$b2a } {
    # add_connection  example_design.${rx_to_check}_rx_std  tb_rx_checker.rx_std
    # }
    # }

    add_connection  example_design.${rx_to_check}_rx_dataout        tb_rx_checker.rxdata
    add_connection  example_design.${rx_to_check}_rx_dataout_valid  tb_rx_checker.rxdata_valid

    #if { $cmp_data } {
    #  add_connection  example_design.${tx_to_check}_tx_clkout      tb_rx_checker.tx_clk
    #  add_connection  example_design.pattgen_dout                  tb_rx_checker.txdata
    #  add_connection  example_design.pattgen_dout_valid            tb_rx_checker.txdata_valid
    #  if { $video_std == "dl" & !$a2b } {
    #    add_connection  example_design.pattgen_dout_b        tb_rx_checker.txdata_b
    #    add_connection  example_design.pattgen_dout_valid_b  tb_rx_checker.txdata_valid_b
    #  }
    #}
    #if { ($video_std == "dl" & !$a2b) | $b2a } {
    #  add_instance            tb_fanout_serial_b                      altera_fanout
    #  set_instance_parameter  tb_fanout_serial_b                      WIDTH 1
    #  add_connection          example_design.${tx_to_check}_sdi_tx_b  tb_fanout_serial_b.sig_input
    #  add_connection          tb_fanout_serial_b.sig_fanout0          tb_test_control.sdi_serial_b
    #  add_connection          tb_fanout_serial_b.sig_fanout1          tb_checker_serial.sdi_serial_b
    #  add_connection          tb_test_control.serial_rx_b             example_design.${rx_to_control}_sdi_rx_b
    #}

    # Status signals connections (DUT Rx output)
    #TEMP add_connection  example_design.rx_clk
    #TEMP add_connection  example_design.crc_error_y
    #TEMP add_connection  example_design.crc_error_c
    #TEMP add_connection  example_design.rx_AP
    #TEMP add_connection  example_design.rx_F
    #TEMP add_connection  example_design.rx_V
    #TEMP add_connection  example_design.rx_H
    #TEMP add_connection  example_design.rx_ln
    #TEMP add_connection  example_design.rx_std
    #TEMP add_connection  example_design.rx_xyz
    #TEMP add_connection  example_design.xyz_valid
    #TEMP add_connection  example_design.rx_eav
    #TEMP add_connection  example_design.rx_trs

    if { $dl_sync | $trs_test | $frame_test } {

      add_connection  example_design.pattgen_trs  tb_test_control.pattgen_trs
      add_connection  tb_test_control.tx_dout     example_design.${inst1}_tx_datain
      add_connection  tb_test_control.tx_dvalid   example_design.${inst1}_tx_datain_valid
      add_connection  tb_test_control.tx_trs      example_design.${inst1}_tx_trs

      if { $video_std == "dl" } {

        add_connection  example_design.pattgen_trs_b tb_test_control.pattgen_trs_b
        add_connection  tb_test_control.tx_dout_b    example_design.${inst1}_tx_datain_b
        add_connection  tb_test_control.tx_dvalid_b  example_design.${inst1}_tx_datain_valid_b
        add_connection  tb_test_control.tx_trs_b     example_design.${inst1}_tx_trs_b

      }
    }
      
    if { $cmp_data & ($dl_sync | $trs_test | $frame_test) } {

      add_connection          example_design.${tx_to_check}_tx_clkout       tb_rx_checker.tx_clk
      add_instance            pattgen_dout_fanout                           altera_fanout
      set_instance_parameter  pattgen_dout_fanout                           WIDTH                 20
      add_connection          example_design.pattgen_dout                   pattgen_dout_fanout.sig_input
      add_connection          pattgen_dout_fanout.sig_fanout0               tb_rx_checker.txdata
      add_connection          pattgen_dout_fanout.sig_fanout1               tb_test_control.pattgen_dout

      add_instance            pattgen_doutvalid_fanout              altera_fanout
      set_instance_parameter  pattgen_doutvalid_fanout              WIDTH          1
      add_connection          example_design.pattgen_dout_valid     pattgen_doutvalid_fanout.sig_input
      add_connection          pattgen_doutvalid_fanout.sig_fanout0  tb_rx_checker.txdata_valid
      add_connection          pattgen_doutvalid_fanout.sig_fanout1  tb_test_control.pattgen_dvalid

      if { $video_std == "dl" & !$a2b } {

        add_instance            pattgen_dout_b_fanout                    altera_fanout
        set_instance_parameter  pattgen_dout_b_fanout                    WIDTH          20
        add_connection          example_design.pattgen_dout_b            pattgen_dout_b_fanout.sig_input
        add_connection          pattgen_dout_b_fanout.sig_fanout0        tb_rx_checker.txdata_b
        add_connection          pattgen_dout_b_fanout.sig_fanout1        tb_test_control.pattgen_dout_b

        add_instance            pattgen_dout_valid_b_fanout              altera_fanout
        set_instance_parameter  pattgen_dout_valid_b_fanout              WIDTH          1
        add_connection          example_design.pattgen_dout_valid_b      pattgen_dout_valid_b_fanout.sig_input
        add_connection          pattgen_dout_valid_b_fanout.sig_fanout0  tb_rx_checker.txdata_valid_b
        add_connection          pattgen_dout_valid_b_fanout.sig_fanout1  tb_test_control.pattgen_dvalid_b

      }

    } elseif { $cmp_data } {

      add_connection  example_design.${tx_to_check}_tx_clkout       tb_rx_checker.tx_clk
      add_connection  example_design.pattgen_dout                   tb_rx_checker.txdata
      add_connection  example_design.pattgen_dout_valid             tb_rx_checker.txdata_valid

      if { $video_std == "dl" & !$a2b } {

        add_connection  example_design.pattgen_dout_b        tb_rx_checker.txdata_b
        add_connection  example_design.pattgen_dout_valid_b  tb_rx_checker.txdata_valid_b

      }

    } elseif { $dl_sync | $trs_test | $frame_test} {

      add_connection  example_design.pattgen_dout        tb_test_control.pattgen_dout
      add_connection  example_design.pattgen_dout_valid  tb_test_control.pattgen_dvalid

      if { $video_std == "dl" & !$a2b | $b2a} {

        add_connection  example_design.pattgen_dout_b        tb_test_control.pattgen_dout_b
        add_connection  example_design.pattgen_dout_valid_b  tb_test_control.pattgen_dvalid_b

      }
    }

    if { $extract_vpid } {

      add_connection  example_design.${rx_to_check}_rx_vpid_byte1           tb_rx_checker.rx_vpid_byte1
      add_connection  example_design.${rx_to_check}_rx_vpid_byte2           tb_rx_checker.rx_vpid_byte2
      add_connection  example_design.${rx_to_check}_rx_vpid_byte3           tb_rx_checker.rx_vpid_byte3
      add_connection  example_design.${rx_to_check}_rx_vpid_byte4           tb_rx_checker.rx_vpid_byte4
      add_connection  example_design.${rx_to_check}_rx_vpid_valid           tb_rx_checker.rx_vpid_valid
      add_connection  example_design.${rx_to_check}_rx_vpid_checksum_error  tb_rx_checker.rx_vpid_checksum_error
      add_connection  example_design.${rx_to_check}_rx_line_f0              tb_rx_checker.rx_line_f0
      add_connection  example_design.${rx_to_check}_rx_line_f1              tb_rx_checker.rx_line_f1
      if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {

        add_connection  example_design.${rx_to_check}_rx_vpid_byte1_b           tb_rx_checker.rx_vpid_byte1_b
        add_connection  example_design.${rx_to_check}_rx_vpid_byte2_b           tb_rx_checker.rx_vpid_byte2_b
        add_connection  example_design.${rx_to_check}_rx_vpid_byte3_b           tb_rx_checker.rx_vpid_byte3_b
        add_connection  example_design.${rx_to_check}_rx_vpid_byte4_b           tb_rx_checker.rx_vpid_byte4_b
        add_connection  example_design.${rx_to_check}_rx_vpid_valid_b           tb_rx_checker.rx_vpid_valid_b
        add_connection  example_design.${rx_to_check}_rx_vpid_checksum_error_b  tb_rx_checker.rx_vpid_checksum_error_b

      }
    }

    if { $reset_reconfig } {
      add_connection  example_design.u_reconfig_reconfig_busy  tb_test_control.rx_reconfig_busy
    }

    ## Setting connection from SDI DU CH 0 to second rx_checker block, when multi-channel reconfiguration
    ## test is enabled
    
    if { $multi_reconfig } {
      add_connection  tb_test_control.rx_chk_refclk                                tb_rx_checker_ch0.rx_refclk
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_clkout        tb_rx_checker_ch0.rx_clk
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_align_locked  tb_rx_checker_ch0.align_locked
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_trs_locked    tb_rx_checker_ch0.trs_locked
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_frame_locked  tb_rx_checker_ch0.frame_locked
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_f             tb_rx_checker_ch0.rx_f
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_v             tb_rx_checker_ch0.rx_v
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_h             tb_rx_checker_ch0.rx_h
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_ap            tb_rx_checker_ch0.rx_ap
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_ln            tb_rx_checker_ch0.rx_ln
      if { $video_std == "tr" } {
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_ln_b          tb_rx_checker_ch0.rx_ln_b
      }
      add_connection  tb_fanout_tx_format.sig_fanout1  tb_rx_checker_ch0.tx_format
      ## see this
      add_connection  tb_rx_checker_ch0.rxcheck_done                     tb_test_control.rx_chk_done_ch0
      add_connection  tb_rx_checker_ch0.chk_completed                    tb_test_control.rx_chk_completed_ch0
      add_connection  tb_test_control.rx_chk_start_chk_ch0               tb_rx_checker_ch0.chk_rx

      if { (($video_std == "ds" | $video_std == "tr") & !$b2a) } {

        add_connection  example_design.ch0_loopback_du_${video_std}_rx_sdi_start_reconfig  tb_rx_checker_ch0.rx_sdi_start_reconfig

      }

      if { $crc_err } {

        add_connection  example_design.ch0_loopback_du_${video_std}_rx_crc_error_c  tb_rx_checker_ch0.rx_crc_error_c
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_crc_error_y  tb_rx_checker_ch0.rx_crc_error_y

        if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {

          add_connection  example_design.ch0_loopback_du_${video_std}_rx_crc_error_c_b  tb_rx_checker_ch0.rx_crc_error_c_b
          add_connection  example_design.ch0_loopback_du_${video_std}_rx_crc_error_y_b  tb_rx_checker_ch0.rx_crc_error_y_b

        }
      }

      #if { $sync } {
      #
      #  add_connection  example_design.ch0_loopback_du_${video_std}_rx_format  tb_rx_checker_ch0.rx_format
      #  add_connection  tb_fanout_tx_format.sig_fanout1  tb_rx_checker_ch0.tx_format
      # 
      #}

      add_connection  example_design.ch0_loopback_du_${video_std}_rx_dataout        tb_rx_checker_ch0.rxdata
      add_connection  example_design.ch0_loopback_du_${video_std}_rx_dataout_valid  tb_rx_checker_ch0.rxdata_valid
  
      if { $extract_vpid } {

        add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte1                tb_rx_checker_ch0.rx_vpid_byte1
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte2                tb_rx_checker_ch0.rx_vpid_byte2
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte3                tb_rx_checker_ch0.rx_vpid_byte3
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte4                tb_rx_checker_ch0.rx_vpid_byte4
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_valid                tb_rx_checker_ch0.rx_vpid_valid
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_checksum_error       tb_rx_checker_ch0.rx_vpid_checksum_error
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_line_f0                   tb_rx_checker_ch0.rx_line_f0
        add_connection  example_design.ch0_loopback_du_${video_std}_rx_line_f1                   tb_rx_checker_ch0.rx_line_f1
        if { $video_std == "threeg" | $video_std == "dl" | $video_std == "tr" } {
          add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte1_b            tb_rx_checker_ch0.rx_vpid_byte1_b
          add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte2_b            tb_rx_checker_ch0.rx_vpid_byte2_b
          add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte3_b            tb_rx_checker_ch0.rx_vpid_byte3_b
          add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_byte4_b            tb_rx_checker_ch0.rx_vpid_byte4_b
          add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_valid_b            tb_rx_checker_ch0.rx_vpid_valid_b
          add_connection  example_design.ch0_loopback_du_${video_std}_rx_vpid_checksum_error_b   tb_rx_checker_ch0.rx_vpid_checksum_error_b
        }
      }
    }
}
