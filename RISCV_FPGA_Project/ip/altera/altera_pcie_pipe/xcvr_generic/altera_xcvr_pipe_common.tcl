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


# (C) 2001-2011 Altera Corporation. All rights reserved.
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


# Common files for PCIExpress PIPE components
#
# $Header: //acds/rel/13.1/ip/altera_pcie_pipe/xcvr_generic/altera_xcvr_pipe_common.tcl#1 $

source ../../altera_xcvr_generic/alt_xcvr_common.tcl
source ../../altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl
source ../../altera_xcvr_generic/av/av_xcvr_native_fileset.tcl
source ../../altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl    

set common_composed_mode 0

# +-----------------------------------
# | initialize the exported interface data to an empty set
# | 
# | Set composed mode, affects common_add* interface methods
# | 
proc common_initialize { composed } {
  global common_composed_mode
  set common_composed_mode $composed
}


######################################
# +-----------------------------------
# | File set tagging
# +-----------------------------------
######################################

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# | 
proc pipe_decl_fileset_groups_sv_xcvr_pipe_native { phy_root } {

  sv_xcvr_native_decl_fileset_groups $phy_root/../../altera_xcvr_generic
  alt_xcvr_csr_decl_fileset_groups $phy_root/../../altera_xcvr_generic 1
  
  common_fileset_group_plain ./ $phy_root/../sv/ {
    sv_xcvr_emsip_adapter.sv
    sv_xcvr_pipe_native.sv
  } {S5}

    # add files for Arria V
  av_xcvr_native_decl_fileset_groups $phy_root/../../altera_xcvr_generic

  common_fileset_group_plain ./ $phy_root/../../altera_xcvr_generic/av/ {
    av_xcvr_data_adapter.sv
  } {A5}
  common_fileset_group_plain ./ $phy_root/../av/ {
    av_xcvr_pipe_native.sv
  } {A5}
}

proc pipe_decl_fileset_groups_sv_xcvr_pipe_nr { phy_root } {

  pipe_decl_fileset_groups_sv_xcvr_pipe_native $phy_root
    
  common_fileset_group_plain ./ $phy_root/../sv/ {
    sv_xcvr_pipe_nr.sv
  } {S5}

  # add files for Arria V
  common_fileset_group_plain ./ $phy_root/../av/ {
    av_xcvr_pipe_nr.sv
  } {A5}
}

proc pipe_decl_fileset_groups_top { phy_root } {

  pipe_decl_fileset_groups_sv_xcvr_pipe_nr $phy_root

  # Reset controller
  ::altera_xcvr_reset_control::fileset::declare_files "$phy_root/../alt_xcvr/altera_xcvr_reset_control"    

  common_fileset_group_plain ./ $phy_root/../xcvr_generic/ {
    altera_xcvr_pipe.sv
  } {ALL_HDL}

}
# +-----------------------------------
# | parameters
# | 
proc common_add_parameters_for_native_phy { } {
  #---------------------------
  # device_family
  #---------------------------
  add_parameter device_family STRING
  set_parameter_property device_family SYSTEM_INFO {DEVICE_FAMILY}
  set_parameter_property device_family SYSTEM_INFO_TYPE DEVICE_FAMILY
  set_parameter_property device_family DISPLAY_NAME "Device family"
  set_parameter_property device_family DISPLAY_HINT "Device family"
  set_parameter_property device_family ENABLED false
  set_parameter_property device_family HDL_PARAMETER true
  add_display_item "General Options" device_family PARAMETER
    
  #---------------------------
  # device_family
  #---------------------------
  # add_parameter device_family STRING
  # set_parameter_property device_family DEFAULT_VALUE "Stratix V"
  # set_parameter_property device_family HDL_PARAMETER true 
  # set_parameter_property device_family NEW_INSTANCE_VALUE "Arria V"
  # set_parameter_property device_family DERIVED true 
  # set_parameter_property device_family VISIBLE false
    
  #---------------------------
  # lanes
  #---------------------------
  add_parameter lanes INTEGER 1
  set_parameter_property lanes DEFAULT_VALUE 1
  set_parameter_property lanes DISPLAY_NAME "Number of lanes"
  set_parameter_property lanes ALLOWED_RANGES {1 2 4 8}
  set_parameter_property lanes DESCRIPTION "Total number of PCIe lanes"
  set_parameter_property lanes HDL_PARAMETER true
  add_display_item "General Options" lanes PARAMETER
  #add_parameter starting_channel_number INTEGER 0
  #set_parameter_property starting_channel_number DEFAULT_VALUE 0
  #set_parameter_property starting_channel_number DISPLAY_NAME "Starting channel number"
  #set_parameter_property starting_channel_number HDL_PARAMETER true
    
  #---------------------------
  # protocol_version
  #---------------------------
  add_parameter protocol_version STRING "Gen 1"
  set_parameter_property protocol_version DEFAULT_VALUE "Gen 1"
  set_parameter_property protocol_version DISPLAY_NAME "Protocol version"
  set_parameter_property protocol_version ALLOWED_RANGES {"Gen 1" "Gen 2" "Gen 3"}
  set_parameter_property protocol_version DESCRIPTION "PCIe protocol version.\rGen1 implements PCI Express Base Specification 1.1. \rGen2 implements PCI Express Base Specification 2.0. \rGen3 implements PCI Express Base Specification 3.0."
  set_parameter_property protocol_version HDL_PARAMETER true
  add_display_item "General Options" protocol_version PARAMETER
    
  #---------------------------
  # data_rate 
  #---------------------------
  add_parameter data_rate STRING "2500 Mbps"
  set_parameter_property data_rate DERIVED true
  set_parameter_property data_rate VISIBLE true
  set_parameter_property data_rate DEFAULT_VALUE "2500 Mbps"
  set_parameter_property data_rate DISPLAY_NAME "Data rate"
  set_parameter_property data_rate DESCRIPTION "Data rate for the Protocol Version chosen. \rGen1 = 2500 Mbps, Gen2 = 5000 Mbps"
  set_parameter_property data_rate HDL_PARAMETER false
  add_display_item "General Options" data_rate PARAMETER
  
  #---------------------------
  #  Gen 1/2 base_data_rate 
  #---------------------------
  add_parameter base_data_rate STRING "2500 Mbps"
  set_parameter_property base_data_rate DEFAULT_VALUE "2500 Mbps"
  set_parameter_property base_data_rate HDL_PARAMETER true
  set_parameter_property base_data_rate DERIVED true
  set_parameter_property base_data_rate VISIBLE false
  
  # adding base_data_rate GUI parameter - GUI param is symbolic only
  add_parameter gui_gen12_base_data_rate STRING "2500 Mbps"
  set_parameter_property gui_gen12_base_data_rate DEFAULT_VALUE "2500 Mbps"
  set_parameter_property gui_gen12_base_data_rate DISPLAY_NAME "Gen1 and Gen2 base data rate"
  set_parameter_property gui_gen12_base_data_rate ALLOWED_RANGES {"2500 Mbps" "5000 Mbps" "10000 Mbps"}
  set_parameter_property gui_gen12_base_data_rate HDL_PARAMETER false
  set_parameter_property gui_gen12_base_data_rate UNITS None
  set_parameter_property gui_gen12_base_data_rate DESCRIPTION "Specifies the base data rate for the TX PLL. Channels that require TX PLL merging must share the same base data rate."
  add_display_item "General Options" gui_gen12_base_data_rate parameter
  
  #---------------------------
  # Gen3 base data rate
  #---------------------------
  # adding gen3_base_data_rate GUI parameter - GUI param is symbolic only
  add_parameter gui_gen3_base_data_rate STRING "8000 Mbps"
  set_parameter_property gui_gen3_base_data_rate DISPLAY_NAME "Gen3 base data rate"
  set_parameter_property gui_gen3_base_data_rate HDL_PARAMETER false
  set_parameter_property gui_gen3_base_data_rate VISIBLE true
  set_parameter_property gui_gen3_base_data_rate DERIVED true
  set_parameter_property gui_gen3_base_data_rate DESCRIPTION "Specifies the base data rate for the Gen 3 TX PLL. Channels that require TX PLL merging must share the same base data rate."
  add_display_item "General Options" gui_gen3_base_data_rate parameter
  
  #---------------------------
  # gen12_pll_type
  #---------------------------
  add_parameter pll_type STRING 
  set_parameter_property pll_type VISIBLE false
  set_parameter_property pll_type DEFAULT_VALUE "AUTO"
  set_parameter_property pll_type HDL_PARAMETER true
  set_parameter_property pll_type ENABLED true
  set_parameter_property pll_type DERIVED true
  
  # adding pll_type GUI parameter - GUI param is symbolic only
  add_parameter gui_gen12_pll_type STRING "CMU"
  set_parameter_property gui_gen12_pll_type ALLOWED_RANGES {"CMU" "ATX"}
  set_parameter_property gui_gen12_pll_type DISPLAY_NAME "Gen1 and Gen2 PLL type"
  set_parameter_property gui_gen12_pll_type UNITS None
  set_parameter_property gui_gen12_pll_type ENABLED true
  set_parameter_property gui_gen12_pll_type VISIBLE true
  set_parameter_property gui_gen12_pll_type DISPLAY_HINT ""
  set_parameter_property gui_gen12_pll_type HDL_PARAMETER false
  set_parameter_property gui_gen12_pll_type DESCRIPTION "Specifies the PLL type for Gen1 and Gen2 speeds"
  add_display_item "General Options" gui_gen12_pll_type parameter
  
  #---------------------------
  # gen3_pll_type
  #---------------------------
  # adding pll_type GUI parameter - GUI param is symbolic only
  add_parameter gui_gen3_pll_type STRING "ATX"
  set_parameter_property gui_gen3_pll_type DISPLAY_NAME "Gen3 PLL type"
  set_parameter_property gui_gen3_pll_type UNITS None
  set_parameter_property gui_gen3_pll_type VISIBLE true
  set_parameter_property gui_gen3_pll_type DERIVED true
  set_parameter_property gui_gen3_pll_type DISPLAY_HINT ""
  set_parameter_property gui_gen3_pll_type HDL_PARAMETER false
  set_parameter_property gui_gen3_pll_type DESCRIPTION "Specifies the PLL type for Gen 3 speeds"
  set_parameter_property gui_gen3_pll_type ALLOWED_RANGES {"ATX"}
  add_display_item "General Options" gui_gen3_pll_type parameter
  
  #---------------------------
  # pll_refclk_freq
  #---------------------------
  add_parameter pll_refclk_freq STRING "100 MHz"
  set_parameter_property pll_refclk_freq DEFAULT_VALUE "100 MHz"
  set_parameter_property pll_refclk_freq VISIBLE false
  set_parameter_property pll_refclk_freq DERIVED true
  set_parameter_property pll_refclk_freq HDL_PARAMETER true
  
  # adding pll_refclk_freq GUI parameter - GUI param is symbolic only
  add_parameter gui_pll_refclk_freq STRING "100 MHz"
  set_parameter_property gui_pll_refclk_freq DEFAULT_VALUE "100 MHz"
  set_parameter_property gui_pll_refclk_freq DISPLAY_NAME "PLL reference clock frequency"
  set_parameter_property gui_pll_refclk_freq ALLOWED_RANGES {"100 MHz" "125 MHz"}
  set_parameter_property gui_pll_refclk_freq UNITS None
  set_parameter_property gui_pll_refclk_freq DESCRIPTION "Input reference clock frequency for the PHY PLL"
  set_parameter_property gui_pll_refclk_freq HDL_PARAMETER false
  add_display_item "General Options" gui_pll_refclk_freq PARAMETER
  
  #---------------------------
  # deser_factor
  #---------------------------
  add_parameter gui_deser_factor STRING "8"
  set_parameter_property gui_deser_factor DISPLAY_NAME "FPGA transceiver width"
  set_parameter_property gui_deser_factor DESCRIPTION "Width of the interface between the PHY MAC and the PHY (PIPE)"
  set_parameter_property gui_deser_factor HDL_PARAMETER false 
  add_display_item "General Options" gui_deser_factor PARAMETER
  
  add_parameter deser_factor INTEGER 8
  set_parameter_property deser_factor VISIBLE false
  set_parameter_property deser_factor DEFAULT_VALUE 8
  set_parameter_property deser_factor DERIVED true
  set_parameter_property deser_factor HDL_PARAMETER true

  #----------------------------------
  # bypass_g3pcs_scrambler_descrambler  
  #---------------------------------- 
  add_parameter bypass_g3pcs_scrambler_descrambler INTEGER 1
  set_parameter_property bypass_g3pcs_scrambler_descrambler DISPLAY_NAME "Bypass Gen3 PCS Scrambler/Descrambler"
  set_parameter_property bypass_g3pcs_scrambler_descrambler DISPLAY_HINT BOOLEAN
  set_parameter_property bypass_g3pcs_scrambler_descrambler DESCRIPTION "When enabled the Gen3 PCS scrambler/descrambler is bypassed. If you are implementing the scrambler/descrambler in the PHY MAC layer, enable this checkbox"
  set_parameter_property bypass_g3pcs_scrambler_descrambler HDL_PARAMETER true
  add_display_item "Custom Options" bypass_g3pcs_scrambler_descrambler PARAMETER
  
  #----------------------------------
  # bypass_g3_dcbal  
  #---------------------------------- 
  add_parameter bypass_g3pcs_dcbal INTEGER 1
  set_parameter_property bypass_g3pcs_dcbal DISPLAY_NAME "Bypass Gen3 PCS DC balance circuit"
  set_parameter_property bypass_g3pcs_dcbal DISPLAY_HINT BOOLEAN
  set_parameter_property bypass_g3pcs_dcbal DESCRIPTION "When enabled the Gen3 PCS DC balance circuit is bypassed. If you are implementing DC balancing in the PHY MAC layer, enable this checkbox"
  set_parameter_property bypass_g3pcs_dcbal HDL_PARAMETER true
  add_display_item "Custom Options" bypass_g3pcs_dcbal PARAMETER
  
  #----------------------------------
  # gui_enable_run_length
  #----------------------------------
  # GUI-only enabling parameter must be paired with GUI-only run length parameter
  add_parameter gui_enable_run_length boolean 1
  set_parameter_property gui_enable_run_length DEFAULT_VALUE 1
  set_parameter_property gui_enable_run_length VISIBLE false
  set_parameter_property gui_enable_run_length DISPLAY_NAME "Enable run length violation checking"
  set_parameter_property gui_enable_run_length UNITS None
  set_parameter_property gui_enable_run_length DISPLAY_HINT ""
  set_parameter_property gui_enable_run_length HDL_PARAMETER false
  
  set rlv_enable_range ""
  set rlv_full_range ""
  for {set i 1} {$i <= 32} {incr i} {
    lappend rlv_enable_range [expr $i*5]
  }
  set rlv_full_range "0 $rlv_enable_range"
  
  #----------------------------------
  # gui_pipe_rlv_checking_length
  #----------------------------------
  #GUI-only RLV checking length parameter, used to calculate value for pipe_run_length_violation_checking
  add_parameter gui_pipe_rlv_checking_length integer 160
  set_parameter_property gui_pipe_rlv_checking_length DEFAULT_VALUE 160
  set_parameter_property gui_pipe_rlv_checking_length ALLOWED_RANGES $rlv_enable_range
  set_parameter_property gui_pipe_rlv_checking_length DISPLAY_NAME "Run length"
  set_parameter_property gui_pipe_rlv_checking_length UNITS None
  set_parameter_property gui_pipe_rlv_checking_length DISPLAY_HINT "RLV checking run length"
  set_parameter_property gui_pipe_rlv_checking_length DESCRIPTION "Specifies the maximum legal number of consecutive 0s or 1s at Gen1/2 speeds"
  set_parameter_property gui_pipe_rlv_checking_length HDL_PARAMETER false
  add_display_item "General Options" gui_pipe_rlv_checking_length PARAMETER
  
  #------------------------------------
  # pipe_run_length_violation_checking
  #------------------------------------
  add_parameter pipe_run_length_violation_checking integer 0
  set_parameter_property pipe_run_length_violation_checking DEFAULT_VALUE 0
  #set_parameter_property pipe_run_length_violation_checking ALLOWED_RANGES $rlv_full_range
  set_parameter_property pipe_run_length_violation_checking DISPLAY_NAME "Run length violation checking"
  set_parameter_property pipe_run_length_violation_checking UNITS None
  set_parameter_property pipe_run_length_violation_checking DISPLAY_HINT "0 means disabled"
  set_parameter_property pipe_run_length_violation_checking HDL_PARAMETER true
  #If derived from GUI-only parameters, mark DERIVED property and set value in validation
  set_parameter_property pipe_run_length_violation_checking DERIVED true
  set_parameter_property pipe_run_length_violation_checking VISIBLE false
  
  #----------------------------------
  # pipe_low_latency_syncronous_mode
  #----------------------------------
  add_parameter pipe_low_latency_syncronous_mode INTEGER 0
  set_parameter_property pipe_low_latency_syncronous_mode DEFAULT_VALUE 0
  set_parameter_property pipe_low_latency_syncronous_mode DISPLAY_NAME "PIPE low latency synchronous mode"
  set_parameter_property pipe_low_latency_syncronous_mode DISPLAY_HINT BOOLEAN
  set_parameter_property pipe_low_latency_syncronous_mode DESCRIPTION "When enabled the rate match FIFO operates in low latency mode."
  set_parameter_property pipe_low_latency_syncronous_mode HDL_PARAMETER true
  add_display_item "General Options" pipe_low_latency_syncronous_mode PARAMETER

  #------------------------------------
  # pipe_elec_idle_infer_enable
  #------------------------------------
  add_parameter pipe_elec_idle_infer_enable string false 
  set_parameter_property pipe_elec_idle_infer_enable DEFAULT_VALUE false
  set_parameter_property pipe_elec_idle_infer_enable DISPLAY_NAME "Enable electrical idle inferencing"
  set_parameter_property pipe_elec_idle_infer_enable ALLOWED_RANGES {"true" "false"}
  set_parameter_property pipe_elec_idle_infer_enable DESCRIPTION "Enables electrical idle inference instead of using analog circuitry to detect a device at the other end of the link. If you are implementing this functionality in the PHY MAC layer, set this to false"
  set_parameter_property pipe_elec_idle_infer_enable HDL_PARAMETER true
  add_display_item "General Options" pipe_elec_idle_infer_enable PARAMETER
  set_parameter_property pipe_elec_idle_infer_enable VISIBLE true
  
}

proc common_add_extra_parameters_for_native_phy { } {
  add_parameter hip_enable STRING "true"
  set_parameter_property hip_enable DEFAULT_VALUE "false"
  set_parameter_property hip_enable ALLOWED_RANGES {"true" "false"}
  set_parameter_property hip_enable DISPLAY_NAME "Enable HIP"
  set_parameter_property hip_enable HDL_PARAMETER true
  add_display_item "General Options" hip_enable PARAMETER
}

# +-----------------------------------
# | parameter validation
# | 
proc common_parameter_validation { } {

  set device_family [get_parameter_value device_family]
  # Workaround to allow legacy cores which did not have the device_family parameter to still generate properly 
  # Stratix V is chosen because it was the only option at the time
  if { ![::alt_xcvr::utils::device::has_s5_style_hssi $device_family] && ![::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
    set device_family "Stratix V"
  }
  set gen [get_parameter_value protocol_version]

  if { [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
    set_parameter_property protocol_version ALLOWED_RANGES {"Gen 1" "Gen 2"}
  }

  # +-----------------------------------
  # RLV checking GUI option checked?
  # +-----------------------------------
  set sup_run_length [get_parameter_value gui_enable_run_length]
  set_parameter_property gui_pipe_rlv_checking_length ENABLED $sup_run_length

  # calc derived value for pipe_run_length_violation_checking parameter based on GUI options
  if {$sup_run_length == "true"} {
    set_parameter_value pipe_run_length_violation_checking [get_parameter_value gui_pipe_rlv_checking_length]
  } else {
    set_parameter_value pipe_run_length_violation_checking 0
  }
  
  # +-----------------------------------
  # gui_deser_factor/deser_factor
  # +-----------------------------------
  if {$gen == "Gen 1"} {
    set result [list 8 16]
  } elseif {$gen == "Gen 2"} {
    set result [list 16]
  } elseif {$gen == "Gen 3"} {
    set result [list 32]
  }
  common_map_allowed_range gui_deser_factor $result
  
  # get deser-factor 'real' value from symbolic mapping
  set deser_factor [common_get_mapped_allowed_range_value gui_deser_factor]
  set_parameter_value deser_factor $deser_factor
  
  # +-----------------------------------
  # data_rate (GUI only) 
  # +-----------------------------------
  if {$gen == "Gen 1"} {
    set dr "2500 Mbps"
  } elseif {$gen == "Gen 2"} {
    set dr "5000 Mbps"
  } elseif {$gen == "Gen 3"} {
    set dr "5000 Mbps"  
  }
  
  if {$gen == "Gen 3"} { 
    set_parameter_value data_rate "8000 Mbps" 
  } else { 
    set_parameter_value data_rate $dr
  }
  
  set data_rate_int [ ::alt_xcvr::utils::common::get_data_rate_in_mbps $dr ]
  
  # +-----------------------------------
  # pll_type 
  # +-----------------------------------
  set pll_type [validate_pll_type $device_family]
  set_parameter_value pll_type $pll_type
  
  if {$gen == "Gen 3"} {
    set_parameter_property gui_gen12_pll_type ALLOWED_RANGES {"CMU"}
  }
  
  validate_gen3 $device_family
  
  # +-----------------------------------
  # base_data_rate 
  # +-----------------------------------
  set base_data_rate_list [::alt_xcvr::utils::rbc::get_valid_base_data_rates $device_family $dr $pll_type]
  if { [llength $base_data_rate_list] == 0 } {
    set base_data_rate_list {"N/A"}
   #send_message error "Data rate chosen is not supported or is incompatible with selected PLL type"
  }
  
  if {$gen == "Gen 3"} { 
    set gen12_base_dr {5000 Mhz,8000 Mhz} 
    set_parameter_value base_data_rate $gen12_base_dr
    set_parameter_property gui_gen12_base_data_rate ENABLED false 
  } else {
    ::alt_xcvr::utils::common::map_allowed_range gui_gen12_base_data_rate $base_data_rate_list
    set base_data_rate_str [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_gen12_base_data_rate]
    set_parameter_value base_data_rate $base_data_rate_str
    set_parameter_property gui_gen12_base_data_rate ENABLED true 
  } 

  # +-----------------------------------
  # pll_refclk_freq 
  # +-----------------------------------
  # The get_valid_refclks function returns a list of all valid refclk frequencies. But, PIPE only supports 100 MHz and 125 MHz. 
  # Until there is a common TCL function that takes in the list from get_valid_refclks function and also a list of valid frequencies
  # supported to return the intersection of the 2 lists, hardcode the refclk values for PCIe as we know the frequencies that work.
  #if {$base_data_rate_str != "N/A" && $base_data_rate_str != "N.A"} {
  #  # May return "N/A"
  #  set result [::alt_xcvr::utils::rbc::get_valid_refclks $device_family $base_data_rate_str $pll_type]
  #} else {
  #  set result "N/A"
  #}
  #::alt_xcvr::utils::common::map_allowed_range gui_pll_refclk_freq $result
  #set user_pll_refclk_freq [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_pll_refclk_freq]
  #set_parameter_value pll_refclk_freq $user_pll_refclk_freq
  
  # 100MHz is not supported for Gen1 rate when ATX PLL is used with base_data_rate=data_rate=2500 Mbps
  if {$gen == "Gen 1" && $pll_type == "ATX" && $base_data_rate_str == "2500 Mbps" } {
    set refclk_freq [list "125 MHz"]
  } else {
    set refclk_freq [list "100 MHz" "125 MHz"]
  }
  common_map_allowed_range gui_pll_refclk_freq $refclk_freq
  # get deser-factor 'real' value from symbolic mapping
  set pll_refclk_freq [common_get_mapped_allowed_range_value gui_pll_refclk_freq]
  set_parameter_value pll_refclk_freq $pll_refclk_freq
}

# Validate reconfig parameters for PHY IP in non-HIP mode
proc validate_reconfiguration_parameters { } {
  #|----------------
  #| Reconfiguration
  #|----------------
  set device_family [get_parameter_value device_family]
  # Workaround to allow legacy cores which did not have the device_family parameter to still generate properly 
  # Stratix V is chosen because it was the only option at the time
  if { ![::alt_xcvr::utils::device::has_s5_style_hssi $device_family] && ![::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
    set device_family "Stratix V"
  }

  # number of reconfig interfaces
  set gen [get_parameter_value protocol_version]
  set lanes [get_parameter_value lanes]
  
  # for Gen1 and Gen 1 (x1,x4,x8), number of Tx PLLs used = 1
  if { $gen == "Gen 1" || $gen == "Gen 2"} {
    set tx_plls 1
  } elseif { $gen == "Gen 3" } { 
    set tx_plls 2
  }

  set reconfig_interfaces [common_get_reconfig_interface_count $device_family $lanes $tx_plls]
    
  # display width info message to user
  common_display_reconfig_interface_message $device_family $lanes $tx_plls
}

# validate_pll_type

proc validate_pll_type { device_family } {
  ::alt_xcvr::utils::common::map_allowed_range gui_gen12_pll_type [::alt_xcvr::utils::device::get_hssi_pll_types $device_family] 
  return [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_gen12_pll_type]
}

# validate_gen3
proc validate_gen3 { device_family } {
  set lanes [get_parameter_value lanes]
  set gen [get_parameter_value protocol_version]

  if {$gen == "Gen 3"} {
    set_parameter_property data_rate ENABLED true 
    set_parameter_property data_rate VISIBLE true 
    set_parameter_property gui_gen12_pll_type ENABLED false 
    set_parameter_property gui_gen12_pll_type VISIBLE true 
    set_parameter_property gui_gen3_pll_type ENABLED true 
    set_parameter_property gui_gen3_pll_type VISIBLE true 
    set_parameter_property gui_gen12_base_data_rate ENABLED true 
    set_parameter_property gui_gen12_base_data_rate VISIBLE false
    set_parameter_property gui_gen3_base_data_rate ENABLED true 
    set_parameter_property gui_gen3_base_data_rate VISIBLE false 
    set_parameter_property gui_pll_refclk_freq ENABLED true 
    set_parameter_property gui_pll_refclk_freq VISIBLE true 
    set_parameter_property bypass_g3pcs_scrambler_descrambler ENABLED true
    set_parameter_property bypass_g3pcs_scrambler_descrambler VISIBLE false
    set_parameter_property bypass_g3pcs_dcbal ENABLED true
    set_parameter_property bypass_g3pcs_dcbal VISIBLE false
    set_parameter_property gui_deser_factor ENABLED false
    set_parameter_property gui_deser_factor VISIBLE true
    set_parameter_property gui_pipe_rlv_checking_length ENABLED true
    set_parameter_property gui_pipe_rlv_checking_length VISIBLE true
    set_parameter_property pipe_elec_idle_infer_enable ENABLED true
    set_parameter_property pipe_elec_idle_infer_enable VISIBLE false
    set_parameter_property pipe_low_latency_syncronous_mode ENABLED true
    set_parameter_property pipe_low_latency_syncronous_mode VISIBLE true
    } elseif { $gen == "Gen 1" || $gen == "Gen 2"} {
    set_parameter_property data_rate ENABLED true 
    set_parameter_property data_rate VISIBLE true 
    set_parameter_property gui_gen12_pll_type ENABLED true 
    set_parameter_property gui_gen12_pll_type VISIBLE true 
    set_parameter_property gui_gen3_pll_type ENABLED false 
    set_parameter_property gui_gen3_pll_type VISIBLE false 
    set_parameter_property gui_gen12_base_data_rate ENABLED true 
    set_parameter_property gui_gen12_base_data_rate VISIBLE true
    set_parameter_property gui_gen3_base_data_rate ENABLED false 
    set_parameter_property gui_gen3_base_data_rate VISIBLE false
    set_parameter_property gui_pll_refclk_freq ENABLED true 
    set_parameter_property gui_pll_refclk_freq VISIBLE true 
    set_parameter_property bypass_g3pcs_scrambler_descrambler ENABLED false
    set_parameter_property bypass_g3pcs_scrambler_descrambler VISIBLE false
    set_parameter_property bypass_g3pcs_dcbal ENABLED false
    set_parameter_property bypass_g3pcs_dcbal VISIBLE false
    set_parameter_property gui_deser_factor ENABLED true
    set_parameter_property gui_deser_factor VISIBLE true
    set_parameter_property gui_pipe_rlv_checking_length ENABLED true
    set_parameter_property gui_pipe_rlv_checking_length VISIBLE true
    set_parameter_property pipe_elec_idle_infer_enable ENABLED true
    set_parameter_property pipe_elec_idle_infer_enable VISIBLE false
    set_parameter_property pipe_low_latency_syncronous_mode ENABLED true
    set_parameter_property pipe_low_latency_syncronous_mode VISIBLE true
    }
#  if {$gen == "Gen 3"} {
#    set_parameter_property gui_gen3_pll_type ENABLED true 
#    set_parameter_property gui_gen3_pll_type VISIBLE true 
#    set_parameter_property gui_gen3_base_data_rate ENABLED true 
#    set_parameter_property gui_gen3_base_data_rate VISIBLE true 
#    set_parameter_property bypass_g3pcs_scrambler_descrambler ENABLED true
#    set_parameter_property bypass_g3pcs_scrambler_descrambler VISIBLE true
#    set_parameter_property bypass_g3pcs_dcbal ENABLED true
#    set_parameter_property bypass_g3pcs_dcbal VISIBLE true
#  } else {
#    set_parameter_property gui_gen3_pll_type ENABLED false 
#    set_parameter_property gui_gen3_pll_type VISIBLE false 
#    set_parameter_property gui_gen3_base_data_rate ENABLED false 
#    set_parameter_property gui_gen3_base_data_rate VISIBLE false
#    set_parameter_property bypass_g3pcs_scrambler_descrambler ENABLED false
#    set_parameter_property bypass_g3pcs_scrambler_descrambler VISIBLE false
#    set_parameter_property bypass_g3pcs_dcbal ENABLED false
#    set_parameter_property bypass_g3pcs_dcbal VISIBLE false
#  }

}

# +-----------------------------------
# | interfaces and ports common to all PIPE PHY components
# | 
proc common_clock_interfaces { } {
  global common_composed_mode
    common_add_clock    pll_ref_clk    input
    common_add_clock    pipe_pclk      output
    common_add_clock    fixedclk       input
    
    if {$common_composed_mode == 0} {
        # define pipe_pclk frequency
        # Gen1,  8-bit data => 250 MHz
        # Gen1, 16-bit data => 125 MHz
        # Gen2, 16-bit data => 250 MHz
        # Gen3, 32-bit data => 250 MHz
      set gen [get_parameter_value protocol_version]

      set dwidth [get_parameter_value deser_factor]
      set pclk 250
      if {$gen == "Gen 1" && $dwidth == 16} {
        set pclk 125
      }
      set_interface_property pipe_pclk clockRateKnown true
      set_interface_property pipe_pclk clockRate "${pclk}000000"
    }
}

proc common_clock_interfaces_composed { } {
  global common_composed_mode

    add_instance fixedclk clock_source
    add_interface fixedclk clock end
    set_interface_property fixedclk export_of fixedclk.clk_in
    add_connection fixedclk.clk/xcvr.fixedclk

    add_instance pll_ref_clk clock_source
    add_interface pll_ref_clk clock end
    set_interface_property pll_ref_clk export_of pll_ref_clk.clk_in
    add_connection pll_ref_clk.clk/xcvr.pll_ref_clk

    add_interface pipe_pclk clock start
    set_interface_property pipe_pclk export_of xcvr.pipe_pclk

}

# +-----------------------------------
# | cal_blk_clk is only needed for native and top-HDL
# | 
proc common_cal_blk_clk_interface { } {

    common_add_clock    cal_blk_clk        input
    set_port_property cal_blk_clk TERMINATION true
    set_port_property cal_blk_clk TERMINATION_VALUE 0
}

# +-----------------------------------
# | native PHY ports
# | 
proc common_pipe_interface_ports {shared} {
  # PIPE Gen2-only ports: pipe_rate, pipe_txdeemph, pipe_txmargin
  set gen [get_parameter_value protocol_version]

  #parameter values needed for port widths:
  set deser_factor [get_parameter_value deser_factor]
  set lanes [get_parameter_value lanes]

  # shared Gen 2/3 PIPE inputs
  if {$shared==1} {
    common_add_pipe_stream pipe_rate input 2 true
  } else {
    common_add_pipe_stream pipe_rate input [expr $lanes*2] true
  }
  if {$gen == "Gen 1"} {
    set_port_property pipe_rate TERMINATION true
    set_port_property pipe_rate TERMINATION_VALUE 0
  }

    #streams for PIPE inputs:
  common_add_pipe_stream pipe_txdata input [expr $lanes*$deser_factor ] true
  common_add_pipe_stream pipe_txdatak input [expr ($lanes*$deser_factor)/8 ] true
  common_add_pipe_stream pipe_txcompliance input $lanes  true
  common_add_pipe_stream pipe_txelecidle input $lanes  true
  common_add_pipe_stream pipe_rxpolarity input $lanes  true
  common_add_pipe_stream pipe_txdetectrx_loopback input $lanes true
  common_add_pipe_stream pipe_powerdown input [expr $lanes*2] true
  common_add_pipe_stream pipe_txswing input $lanes true
  common_add_pipe_stream rx_eidleinfersel input [expr $lanes*3] true
  common_add_pipe_stream pipe_txdeemph input $lanes true
  common_add_pipe_stream pipe_txmargin input [expr $lanes*3] true
  common_add_pipe_stream pipe_g3_txdeemph input [expr $lanes*18] true 
  common_add_pipe_stream pipe_rxpresethint input [expr $lanes*3] true

  if {$gen == "Gen 1"} { ;# Gen 2/3 only
    set_port_property pipe_txdeemph TERMINATION true
    set_port_property pipe_txdeemph TERMINATION_VALUE 0
    set_port_property pipe_g3_txdeemph TERMINATION true
    set_port_property pipe_g3_txdeemph TERMINATION_VALUE 0
    set_port_property pipe_rxpresethint TERMINATION true
    set_port_property pipe_rxpresethint TERMINATION_VALUE 0
  } elseif {$gen == "Gen 2"} {
    set_port_property pipe_g3_txdeemph TERMINATION true
    set_port_property pipe_g3_txdeemph TERMINATION_VALUE 0
    set_port_property pipe_rxpresethint TERMINATION true
    set_port_property pipe_rxpresethint TERMINATION_VALUE 0
  } elseif {$gen == "Gen 3"} {
    set_port_property pipe_txdeemph TERMINATION true
    set_port_property pipe_txdeemph TERMINATION_VALUE 0
  }

    #streams for PIPE outputs:
  common_add_pipe_stream pipe_rxdata output [expr $lanes*$deser_factor ] true
  common_add_pipe_stream pipe_rxdatak output [expr ($lanes*$deser_factor)/8 ] true
  common_add_pipe_stream pipe_rxvalid output $lanes  true
  common_add_pipe_stream pipe_rxelecidle output $lanes  true
  common_add_pipe_stream pipe_rxstatus output [expr $lanes*3 ] true
  common_add_pipe_stream pipe_phystatus output $lanes true
  common_add_pipe_stream rx_syncstatus output [expr ($lanes*$deser_factor)/8 ] true

  common_add_pipe_stream pipe_tx_data_valid input $lanes true 
  common_add_pipe_stream pipe_rx_data_valid output $lanes true 
  common_add_pipe_stream pipe_tx_blk_start input $lanes true 
  common_add_pipe_stream pipe_rx_blk_start output $lanes true 
  common_add_pipe_stream pipe_tx_sync_hdr input  [expr $lanes*2 ] true 
  common_add_pipe_stream pipe_rx_sync_hdr output [expr $lanes*2 ] true 
    
  if {$gen == "Gen 1" || $gen == "Gen 2"} { ;#Gen 3 only
    set_port_property pipe_rx_data_valid TERMINATION true 
    set_port_property pipe_rx_data_valid TERMINATION_VALUE 0 
    set_port_property pipe_rx_blk_start TERMINATION true  
    set_port_property pipe_rx_blk_start TERMINATION_VALUE 0  
    set_port_property pipe_rx_sync_hdr TERMINATION true  
    set_port_property pipe_rx_sync_hdr TERMINATION_VALUE 0  
    set_port_property pipe_tx_data_valid TERMINATION true 
    set_port_property pipe_tx_data_valid TERMINATION_VALUE 0 
    set_port_property pipe_tx_blk_start TERMINATION true  
    set_port_property pipe_tx_blk_start TERMINATION_VALUE 0  
    set_port_property pipe_tx_sync_hdr TERMINATION true  
    set_port_property pipe_tx_sync_hdr TERMINATION_VALUE 0
  }

  # status conduits

  common_add_tagged_conduit pll_locked output 1 {TxAll}
  common_add_tagged_conduit_bus rx_is_lockedtoref output $lanes {RxMoreStatus}
  common_add_tagged_conduit_bus rx_is_lockedtodata output $lanes {RxMoreStatus}
  common_add_tagged_conduit_bus rx_signaldetect output $lanes {RxMoreStatus}
  
  #serial I/O pin conduits
  common_add_tagged_conduit_bus tx_serial_data output $lanes {TxAll}
  common_add_tagged_conduit_bus rx_serial_data input $lanes {RxAll}
}
# +-----------------------------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_tagged_conduit { port_name port_dir width tags } {

  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name conduit $in_out($port_dir)
  set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
  #set_interface_property $port_name ENABLED $used
  common_add_interface_port $port_name $port_name export $port_dir $width $tags
  if {$port_dir == "input"} {
    set_port_property $port_name TERMINATION_VALUE 0
  }
}

proc common_add_tagged_conduit_bus { port_name port_dir width tags } {
  common_add_tagged_conduit $port_name $port_dir $width $tags 
  set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}

# +-----------------------------------
# | native PHY conduit ports
# | 
proc common_add_dynamic_reconfig_conduits { } {
  set device_family [get_parameter_value device_family]
  # Workaround to allow legacy cores which did not have the device_family parameter to still generate properly 
  # Stratix V is chosen because it was the only option at the time
  if { ![::alt_xcvr::utils::device::has_s5_style_hssi $device_family] && ![::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
    set device_family "Stratix V"
  }

  # number of reconfig interfaces
  set gen [get_parameter_value protocol_version]
  set lanes [get_parameter_value lanes]

  # for Gen1 and Gen 1 (x1,x4,x8), number of Tx PLLs used = 1
  if { $gen == "Gen 1" || $gen == "Gen 2" } {
    set tx_plls 1
  } elseif { $gen == "Gen 3"} {
    set tx_plls 2
 }
    
  set reconfig_interfaces [common_get_reconfig_interface_count $device_family $lanes $tx_plls]

  #conduits for native reconfig bundles:
  common_add_tagged_conduit_bus reconfig_to_xcvr input [common_get_reconfig_to_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg}
  common_add_tagged_conduit_bus reconfig_from_xcvr output [common_get_reconfig_from_xcvr_total_width $device_family $reconfig_interfaces] {XcvrRcfg}
}

# +-----------------------------------
# | Management interface ports
# | 
# | - Needed for layers above native PHY layer
# | 
proc common_mgmt_interface { addr_width {readLatency 1} } {
  global common_composed_mode
  
  # +-----------------------------------
  # | soft logic status conduits
  # | 
  common_add_tagged_conduit tx_ready output 1 {TxAll}
  common_add_tagged_conduit rx_ready output 1 {RxAll}
   
  # +-----------------------------------
  # | connection point mgmt_clk
  # | 
  common_add_clock  phy_mgmt_clk  input
  add_interface phy_mgmt_clk_reset reset end
  if {$common_composed_mode == 0} {
    add_interface_port phy_mgmt_clk_reset phy_mgmt_clk_reset reset Input 1
    set_interface_property phy_mgmt_clk_reset ASSOCIATED_CLOCK phy_mgmt_clk
  } else {
    set_interface_property phy_mgmt_clk_reset export_of mgmt_clk.clk_in_reset
  }

  # +-----------------------------------
  # | connection point phy_mgmt
  # | 
  add_interface phy_mgmt avalon end
  if {$common_composed_mode == 0} {
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
    add_interface_port phy_mgmt phy_mgmt_waitrequest waitrequest Output 1
    add_interface_port phy_mgmt phy_mgmt_write write Input 1
    add_interface_port phy_mgmt phy_mgmt_writedata writedata Input 32
  }
}

# +-----------------------------------
# | top-PHY extra parameters
# | 
proc add_extra_parameters_for_top_phy { } {

  add_parameter mgmt_clk_in_hz LONG 150000000
  set_parameter_property mgmt_clk_in_hz SYSTEM_INFO {CLOCK_RATE phy_mgmt_clk}
  set_parameter_property mgmt_clk_in_hz VISIBLE false
  set_parameter_property mgmt_clk_in_hz HDL_PARAMETER false

  add_parameter mgmt_clk_in_mhz INTEGER 150 
  set_parameter_property mgmt_clk_in_mhz DERIVED true
  set_parameter_property mgmt_clk_in_mhz VISIBLE false
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

proc common_add_optional_conduit_bus { port_name port_dir width used } {
  common_add_optional_conduit $port_name $port_dir $width $used 
  set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}

# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, associated with pipe_pclk
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc common_add_pipe_stream { port_name port_dir width used } {

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
    set_interface_property $port_name ASSOCIATED_CLOCK pipe_pclk
    add_interface_port $port_name $port_name data $port_dir $width
    set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
  }
}


# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc common_add_clock { port_name port_dir } {

  global common_composed_mode
  array set in_out [list {output} {start} {input} {end} ]
  add_interface $port_name clock $in_out($port_dir)
  if {$common_composed_mode == 0} {
    set_interface_property $port_name ENABLED true
    add_interface_port $port_name $port_name clk $port_dir 1
  } else {
    # create clock source instance for composed mode
    add_instance $port_name clock_source
    set_interface_property $port_name export_of $port_name.clk_in
  }
    
}
