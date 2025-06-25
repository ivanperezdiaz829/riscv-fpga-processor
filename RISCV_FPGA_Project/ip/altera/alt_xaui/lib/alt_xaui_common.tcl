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


#-----------------------------------------------------------------------------
#
# Description: Common files for Altera XAUI PHY components 
#         Current supported Family - Cyclone IV
#
# Authors:     dunnikri    19-Aug-2010
# Modified:     hhleong    08-May-2012
#
#              Copyright (c) Altera Corporation 1997 - 2012
#              All rights reserved.
#
# 
#-----------------------------------------------------------------------------
if { [lsearch $auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control ] == -1 } {
  lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
}
package require altera_xcvr_reset_control::fileset
set common_composed_mode 0

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# |
proc custom_decl_fileset_groups { phy_root reconfig_root } {

  # enable only a single warning per simulator for missing vendor encryption directories
  common_enable_summary_sim_support_warnings 1    ;# 1 to suppress all but summary warning per sim vendor

  #
  # Declare packages first
  #
  common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/" {
    altera_xcvr_functions.sv
  } {ALL_HDL}
  common_fileset_group_plain ./ "$phy_root/../alt_pma/source/alt_pma" {
    alt_pma_functions.sv
  } {SOFT DXAUI}


  #
  # common to all families
  #
  # alt_xaui
  common_fileset_group_plain ./ "$phy_root/lib/" {
    altera_xcvr_xaui.sv
    hxaui_csr_h.sv
    hxaui_csr.sv
    alt_xcvr_mgmt2dec_phyreconfig.sv 
    alt_xcvr_mgmt2dec_xaui.sv 
  } {ALL_HDL}


  # alt_pma_ch_controller
  common_fileset_group_plain ./ "$phy_root/../alt_pma/source/channel_controller/" {
    alt_pma_ch_controller_tgx.v
  } {ALL_HDL}

  # alt_pma_controller
  common_fileset_group_plain ./ "$phy_root/../alt_pma/source/alt_pma_controller/" {
    alt_pma_controller_tgx.v
  } {ALL_HDL}
  #
  # Common CSR blocks and reset controller
  alt_xcvr_csr_decl_fileset_groups $phy_root/../altera_xcvr_generic/  
  
  # Reset controller
  ::altera_xcvr_reset_control::fileset::declare_files

  #
  # PHY IP specific files
  #
  # files related to the soft PCS - S4 and SV only
  common_fileset_group_encrypted ./ "$phy_root/softpcs/" {
    alt_soft_xaui_pcs.v
    alt_soft_xaui_reset.v
    alt_soft_xaui_rx.v
    alt_soft_xaui_rx_8b10b_dec.v
    alt_soft_xaui_rx_channel_synch.v
    alt_soft_xaui_rx_deskew.v
    alt_soft_xaui_rx_deskew_channel.v
    alt_soft_xaui_rx_deskew_ram.v
    altera_soft_xaui_rx_deskew_ram.v
    alt_soft_xaui_rx_invalid_code_det.v
    alt_soft_xaui_rx_parity.v
    alt_soft_xaui_rx_parity_4b.v
    alt_soft_xaui_rx_parity_6b.v
    alt_soft_xaui_rx_rate_match.v
    alt_soft_xaui_rx_rate_match_ram.v
    alt_soft_xaui_rx_rl_chk_6g.v
    alt_soft_xaui_rx_sm.v
    alt_soft_xaui_tx.v
    alt_soft_xaui_tx_8b10b_enc.v
    alt_soft_xaui_tx_idle_conv.v
    l_modules.v
    serdes_4_unit_lc_siv.v
    serdes_4_unit_siv.v
    serdes_4unit.v
  } {SOFT}

  # the File type for OCP file should be OTHER in order to pass compilation -- from V11.1B137 onwards
  common_fileset_group ./ "$phy_root/softpcs/" OTHER {
    alt_soft_xaui_pcs.ocp
  } {SOFT} {QENCRYPT}

  # alt_xaui specific to soft PCS
  common_fileset_group_plain ./ "$phy_root/lib/" {
    sxaui.v
  } {SOFT}

  # alt_xaui specific to S5
  common_fileset_group_plain ./ "$phy_root/lib/" {
    sv_xcvr_xaui.sv 
  } {S5}
  
  # alt_xaui specific to A5
  common_fileset_group_plain ./ "$phy_root/lib/" {
    av_xcvr_xaui.sv  
  } {A5}

  # alt_xaui specific to C5
  common_fileset_group_plain ./ "$phy_root/lib/" {
    cv_xcvr_xaui.sv  
  } {C5}
  
  # alt_pma common
  common_fileset_group_plain ./ "$phy_root/../alt_pma/source/stratixv" {
    sv_xcvr_low_latency_phy_nr.sv
  } {S5}
  
   common_fileset_group_plain ./ "$phy_root/lib/" {
    av_xcvr_low_latency_phy_nr.sv
  } {A5}

  common_fileset_group_plain ./ "$phy_root/lib/" {
    av_xcvr_low_latency_phy_nr.sv
  } {C5}
  

  # alt_pma common
  common_fileset_group_plain ./ "$phy_root/../alt_pma/source/stratixiv" {
    siv_xcvr_low_latency_phy_nr.sv
  } {S4_SOFT}


  # files related to the hard PCS - S4 (includes AII) and C4 only
  common_fileset_group_plain ./ "$phy_root/lib/" {
    hxaui_alt4gxb.v
  } {S4_HARD}

  common_fileset_group_plain ./ "$phy_root/lib/" {
    hxaui.v
  } {S4_HARD C4}

  # altera_xcvr_xaui specific to S4
  common_fileset_group_plain ./ "$phy_root/lib/" {
    siv_xcvr_xaui.sv 
  } {S4_1}

  # alt_xaui specific to C4
  common_fileset_group_plain ./ "$phy_root/lib/" {
    hxaui_alt_c3gxb.v
    civ_xcvr_xaui.v
  } {C4}

  #
  # Stratix V specific files
  #

  #
  # sv_xcvr_native and all sub-modules
  sv_xcvr_native_decl_fileset_groups $phy_root/../altera_xcvr_generic/

  common_fileset_group_plain ./ "$phy_root/../altera_xcvr_8g_custom/sv" {
    sv_xcvr_custom_native.sv
  } {S5}
  
  # Arria V specific files

  av_xcvr_native_decl_fileset_groups $phy_root/../altera_xcvr_generic/

  common_fileset_group_plain ./ "$phy_root/../altera_xcvr_8g_custom/av" {
    av_xcvr_custom_native.sv
  } {A5}
  
  common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/sv/" {
        sv_reconfig_bundle_to_xcvr.sv
        sv_reconfig_bundle_to_ip.sv
        sv_reconfig_bundle_merger.sv
    } {C5}

  common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/av/" {
		av_xcvr_h.sv
        av_xcvr_avmm_csr.sv
        av_tx_pma_ch.sv
        av_tx_pma.sv
        av_rx_pma.sv
        av_pma.sv
        av_pcs_ch.sv
        av_pcs.sv
        av_xcvr_avmm.sv
        av_xcvr_native.sv
        av_xcvr_plls.sv
        av_xcvr_data_adapter.sv
		av_reconfig_bundle_to_basic.sv
        av_reconfig_bundle_to_xcvr.sv
    } {C5}

  common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/av/rbc/" {
                av_hssi_8g_rx_pcs_rbc.sv
                av_hssi_8g_tx_pcs_rbc.sv
                av_hssi_common_pcs_pma_interface_rbc.sv
                av_hssi_common_pld_pcs_interface_rbc.sv
                av_hssi_pipe_gen1_2_rbc.sv
                av_hssi_rx_pcs_pma_interface_rbc.sv
                av_hssi_rx_pld_pcs_interface_rbc.sv
                av_hssi_tx_pcs_pma_interface_rbc.sv
                av_hssi_tx_pld_pcs_interface_rbc.sv
        } {C5}
	
  common_fileset_group_plain ./ "$phy_root/../altera_xcvr_8g_custom/av" {
    av_xcvr_custom_native.sv
  } {C5}
  
  common_fileset_group ./ "$phy_root/lib/" OTHER {
    alt_xaui_phy_top.sdc
  } {ALL_HDL_1} {QIP}

  common_fileset_group ./ "$phy_root/lib/" VERILOG {
    alt4gxb_vo.v
  } {S4_SOFT} {SIM_SCRIPT}

  common_fileset_group ./mentor "$phy_root/lib/mentor" VERILOG {
    alt4gxb_vo.v
  } {S4_SOFT} {MENTOR}

  #
  # dxaui
  #

  # alt_pma_ch_controller

  # alt_pma common
  common_fileset_group_plain ./ "$phy_root/../alt_pma/source/stratixiv" {
    siv_xcvr_low_latency_phy_nr.sv
  } {DXAUI}

  common_fileset_group_plain ./ "$phy_root/dxaui" {
    alt_pma_tgx_dxaui.sv
  } {DXAUI}

  common_fileset_group ./ "$phy_root/dxaui/" OTHER {
    dxaui_timing_atx.sdc
  } {DXAUI_ATX} {QIP}

  common_fileset_group ./ "$phy_root/dxaui/" OTHER {
    dxaui_timing_cmu.sdc
  } {DXAUI_CMU} {QIP}

  common_fileset_group_plain ./ "$phy_root/dxaui/" {
      alt_soft_dxaui_pcs.v
      alt_soft_dxaui_rx_8b10b_dec.v
      alt_soft_dxaui_rx_channel_synch.v
      alt_soft_dxaui_rx_deskew_channel.v
      alt_soft_dxaui_rx_deskew_ram.v
      alt_soft_dxaui_rx_deskew.v
      alt_soft_dxaui_rx_invalid_code_det.v
      alt_soft_dxaui_rx_parity_4b.v
      alt_soft_dxaui_rx_parity_6b.v
      alt_soft_dxaui_rx_parity.v
      alt_soft_dxaui_rx_rate_match_ram.v
      alt_soft_dxaui_rx_rate_match.v
      alt_soft_dxaui_rx_rl_chk_6g.v
      alt_soft_dxaui_rx_sm.v
      alt_soft_dxaui_rx.v
      alt_soft_dxaui_tx_8b10b_enc.v
      alt_soft_dxaui_tx_idle_conv.v
      alt_soft_dxaui_tx.v
      l_modules_dxaui.v
      alt_dpram20x.v
      alt_soft_dxaui_rx_data_pipeline.v
      alt_soft_dxaui_reset.v
      alt_soft_dxaui_tx_data_pipeline.v
      alt_soft_dxaui_tx_FIFO.v
      dxaui_pcs.v
      dxaui_siv.sv
      alt_pma_tgx_dxaui.sv
  } {DXAUI}

  # special case for OCP file - only used for Quartus Synthesis - treat it as a VERILOG file
  common_fileset_group ./ "$phy_root/dxaui/" OTHER {
    dxaui_pcs.ocp
  } {DXAUI} {QENCRYPT}

#alt4gxb_vo.v for DXAUI as well as it uses siv_LL underneath
  common_fileset_group ./ "$phy_root/lib/" VERILOG {
    alt4gxb_vo.v
  } {DXAUI} {SIM_SCRIPT}

  common_fileset_group ./mentor "$phy_root/lib/mentor" VERILOG {
    alt4gxb_vo.v
  } {DXAUI} {MENTOR}


  common_fileset_group_plain ./ "$phy_root/dxaui/" {
      altgx4dxaui_atx.v
  } {DXAUI_ATX}
  common_fileset_group_plain ./ "$phy_root/dxaui/" {
      altgx4dxaui_cmu.v
  } {DXAUI_CMU}

  #
  # Reconfiguration block files
  #
  xreconf_decl_fileset_groups $reconfig_root
}

# +------------------------------------------
# | Define fileset by family for given tools
# |
proc custom_add_fileset_for_tool {tool} {
  set if_type         [get_parameter_value interface_type]
#  set pll_type        [get_parameter_value xaui_pll_type]

  # S4-generation family?
  set device_family [get_parameter_value device_family]
  set pll_type     [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_type]
  if { [has_s4_style_hssi $device_family] } {
    if {($if_type == "Soft XAUI")} {
      common_add_fileset_files {SOFT S4 S4_1 S4_SOFT ALL_HDL ALL_HDL_1} $tool
    } elseif {($if_type == "DDR XAUI")} {
      common_add_fileset_files {DXAUI ALL_HDL S4} $tool
        if {($pll_type == "CMU")} {
            common_add_fileset_files {DXAUI_CMU} $tool
        } else {
            common_add_fileset_files {DXAUI_ATX} $tool
        }
    } else {
      common_add_fileset_files {S4_HARD S4 S4_1 ALL_HDL ALL_HDL_1} $tool
    }
  } elseif { [has_s5_style_hssi $device_family] } {
          # S5 and derivatives
    common_add_fileset_files {SOFT S5 ALL_HDL ALL_HDL_1 ALTERA_XCVR_RESET_CONTROL} $tool
  } elseif { [has_a5_style_hssi $device_family] } {
          # A5 and derivatives
    common_add_fileset_files {SOFT A5 ALL_HDL ALL_HDL_1 ALTERA_XCVR_RESET_CONTROL} $tool
  } elseif { [has_c5_style_hssi $device_family] } {
          # C5 and derivatives
    common_add_fileset_files {SOFT C5 ALL_HDL ALL_HDL_1 ALTERA_XCVR_RESET_CONTROL} $tool
  } elseif { [has_c4_style_hssi $device_family] } {
          # Cyclone IV GX
    common_add_fileset_files {C4 ALL_HDL ALL_HDL_1} $tool
  } else {
          # Unknown family
    send_message error "Current device_family ($device_family) is not supported"
  }
}

# +-----------------------------------
# | parameters
# | 
proc common_add_parameters_for_native_phy { } {

  # parameters - alt_xaui


  add_param_int starting_channel_number   0 {0:127} "General Options"
  set_parameter_property starting_channel_number DESCRIPTION \
    "Possible values are from 0 to 127"
  set_parameter_property starting_channel_number DISPLAY_NAME \
    "Starting channel number"

  add_param_str interface_type "Select" {"Hard XAUI" "Soft XAUI" "DDR XAUI"}   "General Options"
  set_parameter_property interface_type DESCRIPTION \
    "Select whether to use hard PCS XAUI, soft PCS XAUI, or double data rate XAUI"
  set_parameter_property interface_type DISPLAY_NAME \
    "XAUI interface type"
  set_parameter_property interface_type ALLOWED_RANGES {"Hard XAUI" "Soft XAUI" "DDR XAUI"}

        #-----------------------------------------
        # Display only Soft XAUI is supported
        #-----------------------------------------
        add_parameter soft_xaui_cfg STRING "Only Soft XAUI is supported for this device."
        set_parameter_property soft_xaui_cfg DISPLAY_NAME "Note"
        add_display_item "General Options" soft_xaui_cfg PARAMETER
        set_parameter_property soft_xaui_cfg DESCRIPTION \
        "Only Soft XAUI is supported for SV"

        #-----------------------------------------
        # Display only Hard XAUI is supported
        #-----------------------------------------
        add_parameter hard_xaui_cfg STRING "Only Hard XAUI is supported for this device."
        set_parameter_property hard_xaui_cfg DISPLAY_NAME "Note"
        add_display_item "General Options" hard_xaui_cfg PARAMETER


  add_param_str data_rate "3125 Mbps" {"3125 Mbps"} "General Options"
  set_parameter_property data_rate DESCRIPTION \
    "Allows you to choose the data rate for CMU/ATX"
  set_parameter_property data_rate DISPLAY_NAME \
    "Data Rate"
  set_parameter_property data_rate IS_HDL_PARAMETER true
  set_parameter_property data_rate DERIVED true
	
  add_parameter xaui_pll_type STRING
  set_parameter_property xaui_pll_type VISIBLE false
  set_parameter_property xaui_pll_type DEFAULT_VALUE "AUTO"
  set_parameter_property xaui_pll_type HDL_PARAMETER true
  set_parameter_property xaui_pll_type ENABLED true
  set_parameter_property xaui_pll_type DERIVED true
	
  # adding pll type parameter - GUI param is symbolic only
  add_parameter gui_pll_type STRING "CMU"
  set_parameter_property gui_pll_type DEFAULT_VALUE "CMU"
  set_parameter_property gui_pll_type ALLOWED_RANGES {"CMU" "ATX"}
  set_parameter_property gui_pll_type DISPLAY_NAME "PLL type"
  set_parameter_property gui_pll_type UNITS None
  set_parameter_property gui_pll_type ENABLED true
  set_parameter_property gui_pll_type VISIBLE true
  set_parameter_property gui_pll_type DISPLAY_HINT ""
  set_parameter_property gui_pll_type HDL_PARAMETER false
  set_parameter_property gui_pll_type DESCRIPTION "Allows you to choose a clock multiplier unit (CMU) or auxiliary transmit (ATX) PLL. The CMU PLL is designed to achieve low TX channel-to-channel skew. The ATX PLL is designed to improve jitter performance. This option is only available for the soft PCS"
  add_display_item "General Options" gui_pll_type parameter	
	
 # adding base_data_rate parameter
  add_param_str_no_range_hdl GUI_BASE_DATA_RATE "General Options"
  set_parameter_property GUI_BASE_DATA_RATE DISPLAY_NAME "Base data rate"
  set_parameter_property GUI_BASE_DATA_RATE HDL_PARAMETER false
  set_parameter_property GUI_BASE_DATA_RATE DESCRIPTION "Specifies the base data rate for the PLL."
  set_parameter_property GUI_BASE_DATA_RATE VISIBLE false
  
  
  add_param_str_no_range_hdl BASE_DATA_RATE "General Options"
  set_parameter_property BASE_DATA_RATE HDL_PARAMETER true
  set_parameter_property BASE_DATA_RATE DERIVED true
  set_parameter_property BASE_DATA_RATE VISIBLE false

 # adding SyncE option- expose CDR clock
  add_param_int  en_synce_support 0  {0:1} "General Options"
  set_parameter_property en_synce_support DESCRIPTION \
    "Exposes seperate reference clock for CDR PLL and TX PLL."
  set_parameter_property en_synce_support DISPLAY_NAME\
    "Enable Sync-E support"
  set_parameter_property en_synce_support DISPLAY_HINT "Boolean"
 
  
 # adding data_rate parameter
 # add_param_str_no_range_hdl GUI_DATA_RATE1 "General Options"
 # set_parameter_property GUI_DATA_RATE1 DISPLAY_NAME "Data rate"
 # set_parameter_property GUI_DATA_RATE1 HDL_PARAMETER false
 # set_parameter_property GUI_DATA_RATE1 DESCRIPTION "Specifies the XAUI data rate"
 # set_parameter_property GUI_DATA_RATE1 VISIBLE false
 # 
 # 
 # add_param_str_no_range_hdl DATA_RATE1 "General Options"
 # set_parameter_property DATA_RATE1 HDL_PARAMETER false
 # set_parameter_property DATA_RATE1 DERIVED true
 # set_parameter_property DATA_RATE1 VISIBLE false
	

  
  add_param_int  use_control_and_status_ports 0 {0:1} "Advanced Options"
  set_parameter_property use_control_and_status_ports DESCRIPTION \
    "Expose control and status ports at the top level"
  set_parameter_property use_control_and_status_ports DISPLAY_NAME\
    "Include control and status ports"
  set_parameter_property use_control_and_status_ports DISPLAY_HINT "Boolean"

  add_param_int  external_pma_ctrl_reconf 0 {0:1} "Advanced Options"
  set_parameter_property external_pma_ctrl_reconf DESCRIPTION \
    "If you turn this option on, the PMA signals are brought up to the top \
level of the XAUI IP core. This option is useful if your design \
includes multiple instantiations of the XAUI PHY IP core. To save \
FPGA resources, you can instantiate the Low Latency PHY Controller \
and Transceiver Reconfiguration Controller IP cores separately in \
your design to avoid having these IP cores instantiated in each \
instance of the XAUI PHY IP core. \
If you turn this option off, the PMA signals remain internal to the \
core. The default setting is off. This option is only available for \
Arria II GX and Stratix IV GX devices."
  set_parameter_property external_pma_ctrl_reconf DISPLAY_NAME \
    "External PMA control and configuration"
  set_parameter_property external_pma_ctrl_reconf DISPLAY_HINT "Boolean"

  add_param_int recovered_clk_out 0 {0:1} "Advanced Options"
  set_parameter_property recovered_clk_out DESCRIPTION \
    "Enable rx_recovered_clk pins as output"
  set_parameter_property recovered_clk_out DISPLAY_NAME \
    "Enable rx_recovered_clk pin"
  set_parameter_property recovered_clk_out DISPLAY_HINT "Boolean"

  add_param_int number_of_interfaces 1 {1} "General Options"
  set_parameter_property number_of_interfaces ENABLED false
  set_parameter_property number_of_interfaces DESCRIPTION \
    "Currently limited to 1 (one) instance"
  set_parameter_property number_of_interfaces DISPLAY_NAME \
    "Number of XAUI interfaces"

  add_parameter reconfig_interfaces INTEGER
  set_parameter_property reconfig_interfaces VISIBLE false
  set_parameter_property reconfig_interfaces DEFAULT_VALUE 1
  set_parameter_property reconfig_interfaces DERIVED true
  set_parameter_property reconfig_interfaces HDL_PARAMETER true


  add_param_int use_rx_rate_match 0 {0:1} "Advanced Options"
  set_parameter_property use_rx_rate_match DESCRIPTION \
    "When you turn this option on, the RX datapath includes the rate \
match FIFO which compensates for up to a ±PPM difference \
between the RX clock recovered clock and the for receiver data clock \
XGMIII RX clock"
  set_parameter_property use_rx_rate_match DISPLAY_NAME \
    "Use rx rate match"
  set_parameter_property use_rx_rate_match DISPLAY_HINT "Boolean"
  set_parameter_property use_rx_rate_match HDL_PARAMETER true
  set_parameter_property use_rx_rate_match VISIBLE       false 
  set_parameter_property use_rx_rate_match ENABLED       false

  add_param_str tx_termination                OCT_100_OHMS \
    {OCT_85_OHMS OCT_100_OHMS OCT_120_OHMS OCT_150_OHMS} "Analog Options"
  set_parameter_property tx_termination DESCRIPTION \
    "Indicates the value of the termination resistor for the transmitter"
  set_parameter_property tx_termination DISPLAY_NAME \
    "Transmitter termination resistance"

  add_param_int tx_vod_selection          4 {0:7}         "Analog Options"
  set_parameter_property tx_vod_selection DESCRIPTION \
    "Sets VOD for the various TX buffers"
  set_parameter_property tx_vod_selection DISPLAY_NAME \
    "Transmitter VOD control setting"
  
  add_param_int tx_preemp_pretap          0 {0:7}         "Analog Options"
  set_parameter_property tx_preemp_pretap DESCRIPTION \
    "Sets the amount of pre-emphasis on the TX buffer"
  set_parameter_property tx_preemp_pretap DISPLAY_NAME \
    "Pre-emphasis pre-tap setting"

  add_param_str  tx_preemp_pretap_inv     false    \
    {false true}      "Analog Options"
  set_parameter_property tx_preemp_pretap_inv DESCRIPTION \
    "Determines whether or not the pre-emphasis control signal for the pre-tap is inverted. If you turn this option on, the pre-emphasis control signal is inverted"
  set_parameter_property tx_preemp_pretap_inv DISPLAY_NAME \
"Invert the pre-emphasis pre-tap polarity setting"
  set_parameter_property tx_preemp_pretap_inv DISPLAY_HINT "String"

  add_param_int tx_preemp_tap_1           0 {0:15}        "Analog Options"
  set_parameter_property tx_preemp_tap_1 DESCRIPTION \
     "Sets the amount of pre-emphasis for the 1st post-tap"
  set_parameter_property tx_preemp_tap_1 DISPLAY_NAME \
     "Pre-emphasis first post-tap setting"

  add_param_int tx_preemp_tap_2           0 {0:7}         "Analog Options"
  set_parameter_property tx_preemp_tap_2 DESCRIPTION \
    "Sets the amount of pre-emphasis for the 2nd post-tap"
  set_parameter_property tx_preemp_tap_2 DISPLAY_NAME \
    "Pre-emphasis second post-tap setting"

  add_param_str  tx_preemp_tap_2_inv      false    \
    {false true}         "Analog Options"
  set_parameter_property tx_preemp_tap_2_inv DESCRIPTION \
    "Determines whether or not the pre-emphasis control signal for the second post-tap is inverted. If you turn this option on, the pre-emphasis control signa is inverted"
  set_parameter_property tx_preemp_tap_2_inv DISPLAY_NAME \
"Invert the second post-tap polarity setting"
  set_parameter_property tx_preemp_tap_2_inv DISPLAY_HINT "String"

  add_param_str rx_common_mode                0.82v \
    {Tri-state 0.82v 1.1v}                                 "Analog Options"
  set_parameter_property rx_common_mode DESCRIPTION \
    "Specifes the RX common mode voltage"
  set_parameter_property rx_common_mode DISPLAY_NAME \
    "Receiver common mode voltage"

  add_param_str rx_termination                OCT_100_OHMS \
    {OCT_85_OHMS OCT_100_OHMS OCT_120_OHMS OCT_150_OHMS}  "Analog Options"
  set_parameter_property rx_termination DESCRIPTION \
    "Indicates the value of the termination resistor for the receiver"
  set_parameter_property rx_termination DISPLAY_NAME \
    "Receiver termination resistance"

  add_param_int rx_eq_dc_gain             0 {0:4}         "Analog Options"
  set_parameter_property rx_eq_dc_gain DESCRIPTION \
    "Sets the equalization DC gain using one of the following settings"
  set_parameter_property rx_eq_dc_gain DISPLAY_NAME \
    "Receiver DC gain"

  add_param_int rx_eq_ctrl                0 {0:16}       "Analog Options"
  set_parameter_property rx_eq_ctrl DESCRIPTION \
    "This option sets the equalizer control settings. The equalizer uses a pass band filter. Specifying a low value passes low frequencies. Specifying a high value passes high frequencies"
  set_parameter_property rx_eq_ctrl DISPLAY_NAME \
    "Receiver static equalizer setting"


}


# +-----------------------------------
# | parameter validation
# | 
proc common_parameter_validation {} {
#  send_message info "alt_xaui validation callback"
  set num_interfaces    [get_parameter_value number_of_interfaces]
  set if_type           [get_parameter_value interface_type]
  set dev_family        [get_parameter_value device_family]
  set use_rx_rate_match [get_parameter_value use_rx_rate_match]
  set starting_ch_num   [get_parameter_value starting_channel_number]
#  set xaui_pll_type     [get_parameter_value xaui_pll_type]
  set pll_type     [validate_pll_type $dev_family]
  
  
  # General Tab
  set_parameter_property interface_type          ENABLED true
  set_parameter_property starting_channel_number VISIBLE true
  set_parameter_property data_rate VISIBLE false
  set_parameter_property BASE_DATA_RATE VISIBLE false
  set_parameter_property device_family ENABLED false
  set_parameter_property device_family VISIBLE true
  set_parameter_property en_synce_support VISIBLE false


  # Advanced Tab
  set_parameter_property use_control_and_status_ports VISIBLE true

  
  if {($dev_family == "Stratix IV") || ($dev_family == "HardCopy IV") || ($dev_family == "Arria II GX") || ($dev_family == "Arria II GZ")} {

    set mgmt_clk_in_hz_sys  [get_parameter_value mgmt_clk_in_hz]
    set mgmt_clk_in_mhz_cal [expr ceil ([expr $mgmt_clk_in_hz_sys/1000000])]
    set_parameter_value mgmt_clk_in_mhz $mgmt_clk_in_mhz_cal
    
    # General Tab: Interface type is visible 
    set_parameter_property interface_type          ENABLED true
    set_parameter_property starting_channel_number ENABLED true

    # Check starting ch# 0 or divisible by 4
    if { $starting_ch_num % 4 != 0 } {
    send_message error "Please enter starting channel number in multiple of 4 or 0."
    }
    # Advanced Tab: All parameters are visible 
    set_parameter_property external_pma_ctrl_reconf VISIBLE true
    if {(($if_type == "Soft XAUI") || ($if_type == "DDR XAUI"))} {
      set_parameter_property gui_pll_type ENABLED true
      set_parameter_value reconfig_interfaces 4
    } else {
      set_parameter_property gui_pll_type ENABLED false
      set_parameter_value reconfig_interfaces 1
    }
    if {($if_type == "DDR XAUI")} {
      set_parameter_property use_rx_rate_match VISIBLE true
      set_parameter_property use_rx_rate_match ENABLED true
    } else {
      set_parameter_property use_rx_rate_match VISIBLE false
      set_parameter_property use_rx_rate_match ENABLED false
    }
  }  elseif {($dev_family == "Stratix V") || ($dev_family == "Arria V GZ")} {
    set_parameter_value reconfig_interfaces 8
    set_parameter_property en_synce_support VISIBLE true
  }  elseif {($dev_family == "Arria V") || ($dev_family == "Cyclone V")} {
    set_parameter_value reconfig_interfaces 5
    set_parameter_property en_synce_support VISIBLE true
  }

    
  if {($dev_family == "Stratix IV")} {
    set_parameter_property interface_type ALLOWED_RANGES {"Hard XAUI" "Soft XAUI" "DDR XAUI"}
    set_parameter_property soft_xaui_cfg ENABLED false
    set_parameter_property soft_xaui_cfg VISIBLE false
    set_parameter_property hard_xaui_cfg ENABLED false
    set_parameter_property hard_xaui_cfg VISIBLE false

  } elseif {($dev_family == "Stratix V") || ($dev_family == "Arria V GZ")} {
    # General Tab: Interface type is visible 
#    send_message info "Only Soft XAUI is supported for Stratix V and Arria V GZ"
    set_parameter_property interface_type ALLOWED_RANGES {"Soft XAUI"}
    set_parameter_property soft_xaui_cfg ENABLED false
    set_parameter_property soft_xaui_cfg VISIBLE true
    set_parameter_property hard_xaui_cfg ENABLED false
    set_parameter_property hard_xaui_cfg VISIBLE false
    set_parameter_property starting_channel_number ENABLED false
    set_parameter_property data_rate VISIBLE true
    set_parameter_property data_rate ENABLED true
	
        # base data rate .. derived from data rate
	set_parameter_property GUI_BASE_DATA_RATE VISIBLE true
	set dr [get_parameter_value data_rate]
	set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $dev_family $dr $pll_type]
	if { [llength $base_data_rate_list] == 0 } {
        set base_data_rate_list {"N/A"}
        send_message error "Data rate chosen is not supported or is incompatible with selected PLL type" 
	   }
        ::alt_xcvr::utils::common::map_allowed_range GUI_BASE_DATA_RATE $base_data_rate_list
        set data_rate_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value GUI_BASE_DATA_RATE]
	
	set_parameter_value BASE_DATA_RATE    $data_rate_str
	
        # data rate
	#set_parameter_property GUI_DATA_RATE1 VISIBLE true
	#set dr1 [get_parameter_value data_rate]
	#if { [llength $dr1]== 0 } {
        #set dr1 {"N/A"}
        #send_message error "Data rate-NEW chosen is not supported or is incompatible with selected PLL type" 
	#   }
        #:alt_xcvr::utils::common::map_allowed_range GUI_DATA_RATE1 $dr1
        #set dr_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value GUI_DATA_RATE1]
        #puts "Ori data rate:::$dr"  
        #puts "Mapped data rate:::$dr_str"  
	#set_parameter_value DATA_RATE1    $dr1
	

    # Analog Tab: All parameters not visible 
    set_parameter_property tx_termination       VISIBLE false
    set_parameter_property tx_vod_selection     VISIBLE false
    set_parameter_property tx_preemp_pretap     VISIBLE false
    set_parameter_property tx_preemp_pretap_inv VISIBLE false
    set_parameter_property tx_preemp_tap_1      VISIBLE false
    set_parameter_property tx_preemp_tap_2      VISIBLE false
    set_parameter_property tx_preemp_tap_2_inv  VISIBLE false
    set_parameter_property rx_common_mode       VISIBLE false
    set_parameter_property rx_termination       VISIBLE false
    set_parameter_property rx_eq_dc_gain        VISIBLE false
    set_parameter_property rx_eq_ctrl           VISIBLE false
    # Advanced Tab: All parameters are visible 
    set_parameter_property external_pma_ctrl_reconf VISIBLE false
    set_parameter_property gui_pll_type            VISIBLE true
  } elseif {($dev_family == "Arria V")} {
    # General Tab: Interface type is visible 
#    send_message info "Only Soft XAUI is supported for Arria V"
    set_parameter_property interface_type ALLOWED_RANGES {"Soft XAUI"}
    set_parameter_property soft_xaui_cfg ENABLED false
    set_parameter_property soft_xaui_cfg VISIBLE true
    set_parameter_property hard_xaui_cfg ENABLED false
    set_parameter_property hard_xaui_cfg VISIBLE false
    set_parameter_property starting_channel_number ENABLED false
    set_parameter_property data_rate VISIBLE true
    set_parameter_property data_rate ENABLED true
	
        # base data rate .. derived from data rate
	set_parameter_property GUI_BASE_DATA_RATE VISIBLE true
	set dr [get_parameter_value data_rate]
	set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $dev_family $dr $pll_type]
	if { [llength $base_data_rate_list] == 0 } {
        set base_data_rate_list {"N/A"}
        send_message error "Data rate chosen is not supported or is incompatible with selected PLL type" 
	   }
        ::alt_xcvr::utils::common::map_allowed_range GUI_BASE_DATA_RATE $base_data_rate_list
        set data_rate_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value GUI_BASE_DATA_RATE]
	
	set_parameter_value BASE_DATA_RATE    $data_rate_str
	
        # data rate
	#set_parameter_property GUI_DATA_RATE1 VISIBLE true
	#set dr1 [get_parameter_value data_rate]
	#if { [llength $dr1]== 0 } {
        #set dr1 {"N/A"}
        #send_message error "Data rate-NEW chosen is not supported or is incompatible with selected PLL type" 
	#   }
        #:alt_xcvr::utils::common::map_allowed_range GUI_DATA_RATE1 $dr1
        #set dr_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value GUI_DATA_RATE1]
        #puts "Ori data rate:::$dr"  
        #puts "Mapped data rate:::$dr_str"  
	#set_parameter_value DATA_RATE1    $dr1
	

    # Analog Tab: All parameters not visible 
    set_parameter_property tx_termination       VISIBLE false
    set_parameter_property tx_vod_selection     VISIBLE false
    set_parameter_property tx_preemp_pretap     VISIBLE false
    set_parameter_property tx_preemp_pretap_inv VISIBLE false
    set_parameter_property tx_preemp_tap_1      VISIBLE false
    set_parameter_property tx_preemp_tap_2      VISIBLE false
    set_parameter_property tx_preemp_tap_2_inv  VISIBLE false
    set_parameter_property rx_common_mode       VISIBLE false
    set_parameter_property rx_termination       VISIBLE false
    set_parameter_property rx_eq_dc_gain        VISIBLE false
    set_parameter_property rx_eq_ctrl           VISIBLE false
    # Advanced Tab: All parameters are visible 
    set_parameter_property external_pma_ctrl_reconf VISIBLE false
    set_parameter_property gui_pll_type            VISIBLE true
  } elseif {($dev_family == "Cyclone V")} {
    # General Tab: Interface type is visible 
#    send_message info "Only Soft XAUI is supported for Cyclone V"
    set_parameter_property interface_type ALLOWED_RANGES {"Soft XAUI"}
    set_parameter_property soft_xaui_cfg ENABLED false
    set_parameter_property soft_xaui_cfg VISIBLE true
    set_parameter_property hard_xaui_cfg ENABLED false
    set_parameter_property hard_xaui_cfg VISIBLE false
    set_parameter_property starting_channel_number ENABLED false
    set_parameter_property data_rate VISIBLE true
    set_parameter_property data_rate ENABLED true
	
        # base data rate .. derived from data rate
	set_parameter_property GUI_BASE_DATA_RATE VISIBLE true
	set dr [get_parameter_value data_rate]
	set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $dev_family $dr $pll_type]
	if { [llength $base_data_rate_list] == 0 } {
        set base_data_rate_list {"N/A"}
        send_message error "Data rate chosen is not supported or is incompatible with selected PLL type" 
	   }
        ::alt_xcvr::utils::common::map_allowed_range GUI_BASE_DATA_RATE $base_data_rate_list
        set data_rate_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value GUI_BASE_DATA_RATE]
	
	set_parameter_value BASE_DATA_RATE    $data_rate_str
	
        # data rate
	#set_parameter_property GUI_DATA_RATE1 VISIBLE true
	#set dr1 [get_parameter_value data_rate]
	#if { [llength $dr1]== 0 } {
        #set dr1 {"N/A"}
        #send_message error "Data rate-NEW chosen is not supported or is incompatible with selected PLL type" 
	#   }
        #:alt_xcvr::utils::common::map_allowed_range GUI_DATA_RATE1 $dr1
        #set dr_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value GUI_DATA_RATE1]
        #puts "Ori data rate:::$dr"  
        #puts "Mapped data rate:::$dr_str"  
	#set_parameter_value DATA_RATE1    $dr1
	

    # Analog Tab: All parameters not visible 
    set_parameter_property tx_termination       VISIBLE false
    set_parameter_property tx_vod_selection     VISIBLE false
    set_parameter_property tx_preemp_pretap     VISIBLE false
    set_parameter_property tx_preemp_pretap_inv VISIBLE false
    set_parameter_property tx_preemp_tap_1      VISIBLE false
    set_parameter_property tx_preemp_tap_2      VISIBLE false
    set_parameter_property tx_preemp_tap_2_inv  VISIBLE false
    set_parameter_property rx_common_mode       VISIBLE false
    set_parameter_property rx_termination       VISIBLE false
    set_parameter_property rx_eq_dc_gain        VISIBLE false
    set_parameter_property rx_eq_ctrl           VISIBLE false
    # Advanced Tab: All parameters are visible 
    set_parameter_property external_pma_ctrl_reconf VISIBLE false
    set_parameter_property gui_pll_type            VISIBLE true
  }  elseif {($dev_family == "Cyclone IV GX")} {
    # General Tab: Interface type is visible 
    #set_parameter_property interface_type ENABLED false
#    send_message info "Only Hard XAUI is supported for Cyclone IV GX"
    set_parameter_property starting_channel_number ENABLED true
    set_parameter_property interface_type ALLOWED_RANGES {"Hard XAUI"}
    set_parameter_property hard_xaui_cfg ENABLED false
    set_parameter_property hard_xaui_cfg VISIBLE true
    set_parameter_property soft_xaui_cfg ENABLED false
    set_parameter_property soft_xaui_cfg VISIBLE false
  
    # Analog Tab: All parameters visible
    set_parameter_property tx_termination       VISIBLE true
    set_parameter_property tx_vod_selection     VISIBLE true
    set_parameter_property tx_preemp_pretap     VISIBLE false
    set_parameter_property tx_preemp_pretap_inv VISIBLE false
    set_parameter_property tx_preemp_tap_1      VISIBLE true
    set_parameter_property tx_preemp_tap_2      VISIBLE false
    set_parameter_property tx_preemp_tap_2_inv  VISIBLE false
    set_parameter_property rx_common_mode       VISIBLE true
    set_parameter_property rx_termination       VISIBLE true
    set_parameter_property rx_eq_dc_gain        VISIBLE true
    set_parameter_property rx_eq_ctrl           VISIBLE false

    set_parameter_property tx_vod_selection ALLOWED_RANGES {1:6}
    set_parameter_property tx_termination ALLOWED_RANGES {OCT_100_OHMS,OCT_150_OHMS}
    set_parameter_property rx_termination ALLOWED_RANGES {OCT_100_OHMS,OCT_150_OHMS}
    set_parameter_property tx_preemp_tap_1 ALLOWED_RANGES {0,1,5,9,13,16,17,18,19,20,21}
    set_parameter_property rx_eq_dc_gain ALLOWED_RANGES {0:2}
    # Advanced Tab
    set_parameter_property external_pma_ctrl_reconf VISIBLE false
    set_parameter_property gui_pll_type            VISIBLE false

    # Check starting ch# 0 or divisible by 4
    if { $starting_ch_num % 4 != 0 } {
    send_message error "Please enter starting channel number in multiple of 4 or 0"
    }
  } elseif {($dev_family == "Arria II GX")} {
    # General Tab: Interface type is visible 
#    send_message info "Only Hard XAUI is supported for Arria II GX"
    set_parameter_property starting_channel_number ENABLED true
    set_parameter_property interface_type ALLOWED_RANGES {"Hard XAUI"}
    set_parameter_property hard_xaui_cfg ENABLED false
    set_parameter_property hard_xaui_cfg VISIBLE true
    set_parameter_property soft_xaui_cfg ENABLED false
    set_parameter_property soft_xaui_cfg VISIBLE false
  
    # Analog Tab: All parameters visible
    set_parameter_property tx_termination       VISIBLE true
    set_parameter_property tx_vod_selection     VISIBLE true
    set_parameter_property tx_preemp_pretap     VISIBLE false
    set_parameter_property tx_preemp_pretap_inv VISIBLE false
    set_parameter_property tx_preemp_tap_1      VISIBLE true
    set_parameter_property tx_preemp_tap_2      VISIBLE false
    set_parameter_property tx_preemp_tap_2_inv  VISIBLE false
    set_parameter_property rx_common_mode       VISIBLE true
    set_parameter_property rx_termination       VISIBLE true
    set_parameter_property rx_eq_dc_gain        VISIBLE true
    set_parameter_property rx_eq_ctrl           VISIBLE true

    set_parameter_property tx_vod_selection ALLOWED_RANGES {1,2,4,5,6,7}
    set_parameter_property tx_termination ALLOWED_RANGES {OCT_100_OHMS}
    set_parameter_property rx_termination ALLOWED_RANGES {OCT_100_OHMS}
    set_parameter_property tx_preemp_tap_1 ALLOWED_RANGES {0:6}
    set_parameter_property rx_eq_dc_gain ALLOWED_RANGES {0:2}

    # Check starting ch# 0 or divisible by 4
    if { $starting_ch_num % 4 != 0 } {
    send_message error "Please enter starting channel number in multiple of 4 or 0"
    }
  } elseif {($dev_family == "Arria II GZ")} {
    # General Tab: Interface type is visible 
#    send_message info "Only Hard XAUI is supported for Arria II GZ"
    set_parameter_property starting_channel_number ENABLED true
    set_parameter_property interface_type ALLOWED_RANGES {"Hard XAUI"}
    set_parameter_property hard_xaui_cfg ENABLED false
    set_parameter_property hard_xaui_cfg VISIBLE true
    set_parameter_property soft_xaui_cfg ENABLED false
    set_parameter_property soft_xaui_cfg VISIBLE false    

    # Check starting ch# 0 or divisible by 4
    if { $starting_ch_num % 4 != 0 } {
    send_message error "Please enter starting channel number in multiple of 4 or 0"
    }
   } else {
  }


  
  # Only 1 XAUI interface allowed!
  if { [expr ($num_interfaces > 1)] } {
       send_message error "Only one xaui interface is supported in this version."
  }

  # DXAUI specific warning
  set rate_match_warning "Because of timing constraints use rate match logic with StratixIV -3 or faster devices."

  if {($if_type    == "DDR XAUI")   && 
      ($dev_family == "Stratix IV") && 
       $use_rx_rate_match}  {
      puts $rate_match_warning
      send_message warning $rate_match_warning
  }
#chnaged name from PLL_TYPE to xaui_pll_type  
set_parameter_value xaui_pll_type    $pll_type
}

# +-----------------------------------
# | interfaces and ports common to all XAUI PHY components
# | 
proc common_clock_interfaces { } {
  global common_composed_mode
  set rcvr_out [get_parameter_value recovered_clk_out]
  set if_type  [get_parameter_value interface_type]

  common_add_clock  pll_ref_clk  input 1
  common_add_clock  xgmii_tx_clk input 1
  common_add_clock  xgmii_rx_clk output 1

  set_interface_property xgmii_rx_clk clockRateKnown true
  set_interface_property xgmii_rx_clk clockRate "156250000"

  if { $rcvr_out } {
     common_add_clock rx_recovered_clk output 4
     set_interface_property rx_recovered_clk clockRateKnown true
     set_interface_property rx_recovered_clk clockRate "156250000"
  } else {
	  my_terminate_port rx_recovered_clk 0 output 4
  }

  if {$if_type == "DDR XAUI"} {
      common_add_clock  tx_clk312_5 output 1
      set_interface_property tx_clk312_5 clockRateKnown true
      set_interface_property tx_clk312_5 clockRate "312500000"
  } else {
	  my_terminate_port tx_clk312_5 0 output 1
  }
}

# +-----------------------------------
# | cal_blk_clk is only needed for native and top-HDL
# | 
proc common_cal_blk_clk_interface { } {

  common_add_clock  cal_blk_clk    input 1
  set_port_property cal_blk_clk TERMINATION true
  set_port_property cal_blk_clk TERMINATION_VALUE 0
}

# +-----------------------------------
# | native PHY ports
# | 
proc common_xaui_interface_ports {shared} {
  
  #streams for XAUI I/O:
  common_add_xaui_stream xgmii_rx_dc output 72 true xgmii_rx_clk
  common_add_xaui_stream xgmii_tx_dc input  72 true  xgmii_tx_clk
  common_add_optional_conduit xaui_rx_serial_data input  4 true
  common_add_optional_conduit xaui_tx_serial_data output 4 true
  
  # status conduits
  common_add_optional_conduit rx_ready output 1 true
  common_add_optional_conduit tx_ready output 1 true
  
  #serial I/O pin conduits
}

# +-----------------------------------
# | control and status ports
# |
proc common_xaui_controlstatus_ports {} {
  set if_type         [get_parameter_value interface_type]
  #set dev_family   [get_parameter_value device_family]


  common_add_xaui_stream rx_channelaligned        output 1 true phy_mgmt_clk
  common_add_xaui_stream rx_syncstatus            output 8 true phy_mgmt_clk
  common_add_xaui_stream rx_disperr               output 8 true phy_mgmt_clk
  common_add_xaui_stream rx_errdetect             output 8 true phy_mgmt_clk

  if {$if_type == "Hard XAUI"} {
    # specific to hard xaui only
	common_add_xaui_stream rx_digitalreset          input  1 true phy_mgmt_clk 
    common_add_xaui_stream tx_digitalreset          input  1 true phy_mgmt_clk 
    common_add_xaui_stream rx_analogreset           input  1 true phy_mgmt_clk
    common_add_xaui_stream rx_invpolarity           input  4 true phy_mgmt_clk
    common_add_xaui_stream rx_set_locktodata        input  4 true phy_mgmt_clk
    common_add_xaui_stream rx_set_locktoref         input  4 true phy_mgmt_clk
    common_add_xaui_stream rx_seriallpbken          input  4 true phy_mgmt_clk
    common_add_xaui_stream tx_invpolarity           input  4 true phy_mgmt_clk
    common_add_xaui_stream rx_is_lockedtodata       output 4 true phy_mgmt_clk
    common_add_xaui_stream rx_phase_comp_fifo_error output 4 true phy_mgmt_clk
    common_add_xaui_stream rx_is_lockedtoref        output 4 true phy_mgmt_clk
    common_add_xaui_stream rx_rlv                   output 4 true phy_mgmt_clk
    common_add_xaui_stream rx_rmfifoempty           output 4 true phy_mgmt_clk
    common_add_xaui_stream rx_rmfifofull            output 4 true phy_mgmt_clk
    common_add_xaui_stream tx_phase_comp_fifo_error output 4 true phy_mgmt_clk
    common_add_xaui_stream rx_patterndetect         output 8 true phy_mgmt_clk
    common_add_xaui_stream rx_rmfifodatadeleted     output 8 true phy_mgmt_clk
    common_add_xaui_stream rx_rmfifodatainserted    output 8 true phy_mgmt_clk
    common_add_xaui_stream rx_runningdisp           output 8 true phy_mgmt_clk
  } 
  if {$if_type == "DDR XAUI"} {
    common_add_xaui_stream rx_is_lockedtodata       output 4 true phy_mgmt_clk
    common_add_xaui_stream rx_is_lockedtoref        output 4 true phy_mgmt_clk

  }


}

proc terminate_xaui_controlstatus_ports {} {
  set if_type         [get_parameter_value interface_type]

  my_terminate_port rx_digitalreset   0 input  1
  my_terminate_port tx_digitalreset   0 input  1
  my_terminate_port rx_channelaligned 0 output 1
  my_terminate_port rx_syncstatus     0 output 8
  my_terminate_port rx_disperr        0 output 8
  my_terminate_port rx_errdetect      0 output 8

  my_terminate_port rx_analogreset           0 input  1
  my_terminate_port rx_invpolarity           0 input  4
  my_terminate_port rx_set_locktodata        0 input  4
  my_terminate_port rx_set_locktoref         0 input  4
  my_terminate_port rx_seriallpbken          0 input  4
  my_terminate_port tx_invpolarity           0 input  4
  my_terminate_port rx_is_lockedtodata       0 output 4
  my_terminate_port rx_phase_comp_fifo_error 0 output 4
  my_terminate_port rx_is_lockedtoref        0 output 4
  my_terminate_port rx_rlv                   0 output 4
  my_terminate_port rx_rmfifoempty           0 output 4
  my_terminate_port rx_rmfifofull            0 output 4
  my_terminate_port tx_phase_comp_fifo_error 0 output 4
  my_terminate_port rx_patterndetect         0 output 8
  my_terminate_port rx_rmfifodatadeleted     0 output 8
  my_terminate_port rx_rmfifodatainserted    0 output 8
  my_terminate_port rx_runningdisp           0 output 8
}

# +-----------------------------------
# | external pma
# |
proc common_xaui_extpma_ports {} {
  common_add_xaui_stream cal_blk_powerdown input   1 true phy_mgmt_clk
  common_add_xaui_stream pll_powerdown     input   1 true phy_mgmt_clk
  common_add_xaui_stream gxb_powerdown     input   1 true phy_mgmt_clk
  common_add_xaui_stream pll_locked        output  1 true phy_mgmt_clk
}

proc terminate_xaui_extpma_ports {} {
  my_terminate_port cal_blk_powerdown 0 input   1 
  my_terminate_port pll_powerdown     0 input   1
  my_terminate_port gxb_powerdown     0 input   1
  my_terminate_port pll_locked        0 output  1
}


proc cdr_ref_clk_port {} {
  common_add_clock  cdr_ref_clk  input 1
}	

proc terminate_cdr_ref_clk_port {} {
  my_terminate_port cdr_ref_clk     0 input   1
}	

# +-----------------------------------
# | Management interface ports
# | 
# | - Needed for layers above native PHY layer
# | 
proc common_mgmt_interface { addr_width {readLatency 1} } {
  global common_composed_mode
  
  # +-----------------------------------
  # | connection point mgmt_clk
  # | 
  common_add_clock  phy_mgmt_clk  input 1
  add_interface_port phy_mgmt_clk phy_mgmt_clk_reset reset Input 1

  # +-----------------------------------
  # | connection point phy_mgmt
  # | 
  add_interface phy_mgmt avalon end
  set_interface_property phy_mgmt addressAlignment DYNAMIC
  set_interface_property phy_mgmt burstOnBurstBoundariesOnly false
  set_interface_property phy_mgmt explicitAddressSpan 0
  set_interface_property phy_mgmt holdTime 0
  set_interface_property phy_mgmt isMemoryDevice false
  set_interface_property phy_mgmt isNonVolatileStorage false
  set_interface_property phy_mgmt linewrapBursts false
  set_interface_property phy_mgmt maximumPendingReadTransactions 0
  set_interface_property phy_mgmt printableDevice false
  set_interface_property phy_mgmt readLatency $readLatency
  set_interface_property phy_mgmt readWaitStates 0
  set_interface_property phy_mgmt readWaitTime 0
  set_interface_property phy_mgmt setupTime 0
  set_interface_property phy_mgmt timingUnits Cycles
  set_interface_property phy_mgmt writeWaitTime 0
  set_interface_property phy_mgmt ASSOCIATED_CLOCK phy_mgmt_clk
  set_interface_property phy_mgmt ENABLED true
    
  add_interface_port phy_mgmt phy_mgmt_address address Input $addr_width
  add_interface_port phy_mgmt phy_mgmt_read read Input 1
  add_interface_port phy_mgmt phy_mgmt_readdata readdata Output 32
  add_interface_port phy_mgmt phy_mgmt_write write Input 1
  add_interface_port phy_mgmt phy_mgmt_writedata writedata Input 32
  add_interface_port phy_mgmt phy_mgmt_waitrequest waitrequest Output 1
}

# +-----------------------------------
# | top-PHY extra parameters
# | 
proc add_extra_parameters_for_top_phy { } {

  add_parameter mgmt_clk_in_hz LONG 150000000
  set_parameter_property mgmt_clk_in_hz SYSTEM_INFO {CLOCK_RATE phy_mgmt_clk}
  set_parameter_property mgmt_clk_in_hz VISIBLE false
  set_parameter_property mgmt_clk_in_hz AFFECTS_GENERATION true
  set_parameter_property mgmt_clk_in_hz HDL_PARAMETER false

  add_parameter mgmt_clk_in_mhz INTEGER 150 
  set_parameter_property mgmt_clk_in_mhz DERIVED true
  set_parameter_property mgmt_clk_in_mhz VISIBLE false
  set_parameter_property mgmt_clk_in_mhz AFFECTS_GENERATION true
  set_parameter_property mgmt_clk_in_mhz HDL_PARAMETER true
}

# +-----------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_optional_conduit { port_name port_dir width used } {

  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name conduit $in_out($port_dir)
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED $used
    add_interface_port $port_name $port_name export $port_dir $width
  }
}

# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, associated with refclk
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
# | #clk      - Specify clock
proc common_add_xaui_stream { port_name port_dir width used clk} {

  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  # create interface details
  add_interface $port_name avalon_streaming $in_out($port_dir)
  if {$common_composed_mode == 0} {
    set_interface_property $port_name dataBitsPerSymbol $width
    set_interface_property $port_name maxChannel 0
    set_interface_property $port_name readyLatency 0
    set_interface_property $port_name symbolsPerBeat 1
    set_interface_property $port_name ENABLED $used
    set_interface_property $port_name ASSOCIATED_CLOCK $clk
    add_interface_port $port_name $port_name data $port_dir $width
  }
}

proc my_terminate_port { port_name termination_value direction width } {
  if { $direction == "input" || $direction == "Input" || $direction == "INPUT" } {
    add_interface $port_name conduit end
    add_interface_port $port_name $port_name export Input $width
    set_port_property $port_name termination 1
    set_port_property $port_name termination_value $termination_value
  } else {
    add_interface $port_name conduit start
    add_interface_port $port_name $port_name export Output $width
    set_port_property $port_name termination 1
  }
}

# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc common_add_clock { port_name port_dir port_width} {

  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name clock $in_out($port_dir) 
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED true
    add_interface_port $port_name $port_name clk $port_dir $port_width
  } else {
    # create clock source instance for composed mode
    add_instance $port_name clock_source
    set_interface_property $port_name export_of $port_name.clk_in
  }
}

proc validate_pll_type { device_family } {
  ::alt_xcvr::utils::common::map_allowed_range gui_pll_type [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 
  return [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_type]
}



proc add_reconfig_ports { } {
  
  common_add_xaui_stream reconfig_from_xcvr  output [common_get_reconfig_from_xcvr_total_width [get_parameter_value device_family] [get_parameter_value reconfig_interfaces]] true phy_mgmt_clk
  common_add_xaui_stream reconfig_to_xcvr  input [common_get_reconfig_to_xcvr_total_width [get_parameter_value device_family] [get_parameter_value reconfig_interfaces]] true phy_mgmt_clk
  
}
proc terminate_reconfig_ports { } {
  my_terminate_port reconfig_from_xcvr 0 output [common_get_reconfig_from_xcvr_total_width [get_parameter_value device_family] [get_parameter_value reconfig_interfaces]]
  my_terminate_port reconfig_to_xcvr 0 input [common_get_reconfig_to_xcvr_total_width [get_parameter_value device_family] [get_parameter_value reconfig_interfaces]] 
}

# +-----------------------------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc custom_add_tagged_conduit { port_name port_dir width tags } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name conduit $in_out($port_dir)
	set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
	#set_interface_property $port_name ENABLED $used
	common_add_interface_port $port_name $port_name export $port_dir $width $tags
	if {$port_dir == "input"} {
		set_port_property $port_name TERMINATION_VALUE 0
	}
}
proc custom_add_tagged_conduit_bus { port_name port_dir width tags } {
	custom_add_tagged_conduit $port_name $port_dir $width $tags 
	set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}
