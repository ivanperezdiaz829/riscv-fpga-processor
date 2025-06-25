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
# | SDI II v12.0
# | Altera Corporation 2009.08.19.17:10:07
# | 
# +-----------------------------------

package require -exact qsys 12.0

source sdi_ii_params.tcl
source sdi_ii_ed.tcl
source sdi_ii_interface.tcl
source sdi_ii_compose_v_series.tcl
source sdi_ii_compose_arria_10.tcl

# +-----------------------------------
# | module SDI II
# | 
set_module_property DESCRIPTION "SDI II"
set_module_property NAME sdi_ii
set_module_property VERSION 13.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/SDI II"
set_module_property AUTHOR "Altera Corporation"
set_module_property DISPLAY_NAME "SDI II"
# set_module_property DATASHEET_URL http://www.altera.com/literature/ug/ug_sdi.pdf
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
# set_module_property SIMULATION_MODEL_IN_VERILOG true
# set_module_property SIMULATION_MODEL_IN_VHDL true
set_module_property VALIDATION_CALLBACK validate_callback
set_module_property COMPOSITION_CALLBACK compose_callback
set_module_property HIDE_FROM_QSYS true
add_documentation_link "SDI II MegaCore Function User Guide" http://www.altera.com/literature/ug/ug_sdi_ii.pdf
# | 
# +-----------------------------------

sdi_ii_common_params
sdi_ii_test_params
sdi_ii_test_pattgen_params

set_parameter_property TEST_GEN_ANC        HDL_PARAMETER false
set_parameter_property TEST_GEN_VPID       HDL_PARAMETER false
set_parameter_property TEST_VPID_PKT_COUNT HDL_PARAMETER false
set_parameter_property TEST_ERR_VPID       HDL_PARAMETER false
set_parameter_property IS_RTL_SIM          HDL_PARAMETER true

set common_composed_mode 0

proc validate_callback {} {
  
  set_parameter_property RX_INC_ERR_TOLERANCE  ENABLED false
  set_parameter_property RX_CRC_ERROR_OUTPUT   ENABLED false
  set_parameter_property RX_EN_VPID_EXTRACT    ENABLED false
  # set_parameter_property RX_EN_TRS_MISC        ENABLED false
  set_parameter_property RX_EN_A2B_CONV       ENABLED false
  set_parameter_property RX_EN_B2A_CONV       ENABLED false
  set_parameter_property TX_HD_2X_OVERSAMPLING ENABLED false
  set_parameter_property TX_EN_VPID_INSERT     ENABLED false
  set_parameter_property XCVR_TXPLL_TYPE       ENABLED false
  set_parameter_property XCVR_TX_PLL_SEL       ENABLED false
  set_parameter_property SD_BIT_WIDTH          ENABLED false
  set_parameter_property XCVR_ATXPLL_DATA_RATE ENABLED false
  set_parameter_property HD_FREQ               ENABLED false
  
  set fam [get_parameter_value FAMILY]
  set std [get_parameter_value VIDEO_STANDARD]
  set dir [get_parameter_value DIRECTION]
  set a2b [get_parameter_value RX_EN_A2B_CONV]
  set b2a [get_parameter_value RX_EN_B2A_CONV]
  set config [get_parameter_value TRANSCEIVER_PROTOCOL]
  set vpid_insert  [get_parameter_value TX_EN_VPID_INSERT]
  set vpid_extract [get_parameter_value RX_EN_VPID_EXTRACT]
  set hd_2xos [get_parameter_value TX_HD_2X_OVERSAMPLING]
  set xcvr_tx_pll_sel [get_parameter_value XCVR_TX_PLL_SEL]
  set txpll [get_parameter_value XCVR_TXPLL_TYPE]
  # set trs_misc [get_parameter_value RX_EN_TRS_MISC]

  if { $dir == "du" | $dir == "rx" } {
    set_parameter_property RX_INC_ERR_TOLERANCE  ENABLED true

    if { $std != "sd"} {
      set_parameter_property RX_CRC_ERROR_OUTPUT ENABLED true
    }
    
    if { $std != "threeg" && $std != "dl" && $std != "tr" } {
      set_parameter_property RX_EN_VPID_EXTRACT    ENABLED true
    }
    # set_parameter_property RX_EN_TRS_MISC     ENABLED true
  } 

  if { $dir == "rx" } {
    if { $std == "tr" | $std == "threeg" } {
      set_parameter_property RX_EN_B2A_CONV      ENABLED true
    } elseif { $std == "dl" } {
      set_parameter_property RX_EN_A2B_CONV      ENABLED true
    }
  }

  if { $txpll != "ATX" & $config != "proto" & ($std == "hd" || $std == "dl") } {
    set_parameter_property HD_FREQ ENABLED true
  } 
  	  
  if { $dir == "du" | $dir == "tx" } {
    set_parameter_property TX_EN_VPID_INSERT  ENABLED true
  } 
  
  if { $std == "tr" | $std == "ds" } {
     set_parameter_property SD_BIT_WIDTH ENABLED true
  }

  if { $a2b } {
    if { $dir == "rx" & $std == "dl" & ($config == "xcvr_proto" | $config == "proto") } {
      #send_message info "Enable SMPTE 352M payload extraction for SMPTE 372M example design demonstration"
    } else {
      send_message error "Level A to level B conversion is only supported for HD dual link receiver with protocol block"
    }

    if { !$vpid_extract } {
      send_message error "Enable extract payload ID (SMPTE 352M) for SMPTE 372M example design demonstration"
    }

    # if { !$trs_misc } {
      # send_message error "Enable TRS miscellaneous output ports for SMPTE 372M example design demonstration"
    # }
  }

  if { $b2a } {
    if { $dir == "rx" & ($std == "tr" | $std == "threeg") & ($config == "xcvr_proto" | $config == "proto") } {
      #send_message info "Enable SMPTE 352M payload extraction for SMPTE 372M example design demonstration"
    } else {
      send_message error "Level B to level A conversion is only supported for 3G or triple rate receiver with protocol block"
    }

    if { !$vpid_extract } {
      send_message error "Enable extract payload ID (SMPTE 352M) for SMPTE 372M example design demonstration"
    }

    # if { !$trs_misc } {
      # send_message error "Enable TRS miscellaneous output ports for SMPTE 372M example design demonstration"
    # }
  }

  if { ($dir == "rx" | $dir == "du" ) & ($std == "tr" | $std == "threeg" | $std == "dl") } {
    if { !$vpid_extract } {
      send_message error "Enable extract payload ID (SMPTE 352M) for consistent 1080p video format indication"
    } else {
      send_message { Info Text } "Extract payload ID (SMPTE 352M) must be enabled for consistent 1080p video format indication"
    }
  }

  if { ($hd_2xos) & ($std == "hd") } {
    if { $dir == "du" } {
      send_message error "Two times oversample mode is only supported for HD Transmitter"  
    }
  }

  #if { $std == "dl" & $dir == "rx" } {
  #  set_parameter_property RX_EN_A2B_CONV     ENABLED true
  #}

  #if { ($std == "threeg" | $std == "tr") & $dir == "rx" } {
  #  set_parameter_property RX_EN_B2A_CONV     ENABLED true
  #}

  if { ($fam == "Stratix V" ||$fam == "Arria V GZ")  & $dir != "rx" & $config != "proto" } {
     set_parameter_property  XCVR_TXPLL_TYPE  ENABLED  true
  }  
  
  if { $fam == "Stratix V" & $txpll == "ATX" } {
     set_parameter_property  XCVR_ATXPLL_DATA_RATE  ENABLED  true
     send_message { Info Text } "Bottom ATX PLLs in transceiver banks of the Stratix V transceiver speed grade 3 devices do not support the data rate required. Use top ATX PLL or CMU PLL when targeting transceiver speed grade 3 devices."
  } 
  
  if { $dir != "rx" & $config != "proto" } {
     set_parameter_property XCVR_TX_PLL_SEL  ENABLED true   
  }
  
  if { $dir == "rx" & $xcvr_tx_pll_sel } {
      send_message error "Tx PLL switching can only be enabled for Duplex or Tx direction."
  }
  
   if { $config == "proto" & $xcvr_tx_pll_sel } {
      send_message error "Tx PLL switching can only be enabled for Transceiver or Combined transceiver/protocol configuration."
  } 
  
  if { $std == "sd" & $xcvr_tx_pll_sel } {
      send_message error "Tx PLL switching is not supported for SD video standard."
  } 
  
}

proc compose_callback {} {
  
  set config       [get_parameter_value TRANSCEIVER_PROTOCOL]
  set dir          [get_parameter_value DIRECTION]
  set insert_vpid  [get_parameter_value TX_EN_VPID_INSERT]
  set extract_vpid [get_parameter_value RX_EN_VPID_EXTRACT]
  set video_std    [get_parameter_value VIDEO_STANDARD]
  set crc_err      [get_parameter_value RX_CRC_ERROR_OUTPUT]
  # set trs_misc     [get_parameter_value RX_EN_TRS_MISC]
  set a2b          [get_parameter_value RX_EN_A2B_CONV]
  set b2a          [get_parameter_value RX_EN_B2A_CONV]
  set device       [get_parameter_value FAMILY]
  set 2xhd         [get_parameter_value TX_HD_2X_OVERSAMPLING]
  set txpll        [get_parameter_value XCVR_TXPLL_TYPE]
  set xcvr_tx_pll_sel [get_parameter_value XCVR_TX_PLL_SEL]
  set atxpll_data_rate [get_parameter_value XCVR_ATXPLL_DATA_RATE]
  set hd_frequency [get_parameter_value HD_FREQ]

   if { $device == "Cyclone V" || $device == "Arria V" || $device == "Stratix V" || $device == "Arria V GZ" } {
      compose_v_series $dir $config $device $video_std $2xhd $txpll $xcvr_tx_pll_sel $insert_vpid $extract_vpid $crc_err $a2b $b2a $atxpll_data_rate $hd_frequency
   } elseif { $device == "Arria 10" } {
      compose_arria_10 $dir $config $device $video_std $2xhd $txpll $xcvr_tx_pll_sel $insert_vpid $extract_vpid $crc_err $a2b $b2a
   } 
}

# +-----------------------------------
# | Example design fileset generation
# | 

add_fileset example_design EXAMPLE_DESIGN generate_example

proc generate_example {name} {

    generate_example_design_fileset $name [get_parameter_value FAMILY]
    
}
