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


package provide alt_xcvr::utils::device 13.1

package require alt_xcvr::utils::common
package require alt_xcvr::utils::fileset

namespace eval ::alt_xcvr::utils::device:: {

  namespace export \
    get_c4gx_name \
    get_s4_name \
    get_a2gz_name \
    get_a2gx_name \
    get_hc4_name \
    get_s5_name \
    get_a5gz_name \
    get_a5_name \
    list_c4_style_hssi_families \
    list_c4_style_hssi_families \
    list_s4_style_hssi_families \
    list_s4_style_hssi10g_families \
    list_s4_style_hssi10g_families \
    list_s5_style_hssi_families \
    list_a5gz_style_hssi_families \
    list_a5_style_hssi_families \
    list_c5_style_hssi_families \
    has_c4_style_hssi \
    has_s4_style_hssi \
    has_s4_style_hssi10g \
    has_s5_style_hssi \
    has_a5gz_style_hssi \
    has_a5_style_hssi \
    has_c5_style_hssi \
    get_typical_device \
    get_device_speedgrades \
    get_device_family_max_channels \
    get_fpll_name \
    get_cmu_pll_name \
    get_atx_pll_name \
    get_hssi_pll_types \
    get_cgb_divider_values \
    get_reconfig_to_xcvr_width \
    get_reconfig_from_xcvr_width \
    get_reconfig_interface_count \
    get_reconfig_to_xcvr_total_width \
    get_reconfig_from_xcvr_total_width \
    convert_speed_grade \
    get_arria10_regmap
}

######################################
# +-----------------------------------
# | Device families
# +-----------------------------------
######################################

# +-----------------------------------
# | Define list of Cyclone IV GX-derived families
# |
proc ::alt_xcvr::utils::device::get_c4gx_name { } { return "Cyclone IV GX" }
proc ::alt_xcvr::utils::device::list_c4_style_hssi_families { } {
  return [list [get_c4gx_name]]
}

# +-----------------------------------
# | Test if given family has Cyclone IV GX-style HSSI features
# |
proc ::alt_xcvr::utils::device::has_c4_style_hssi { fam } {
  set fams [ list_c4_style_hssi_families ]
  set famPos [ lsearch -exact $fams $fam ]
  return [expr $famPos > -1 ]
}

# +-----------------------------------
# | Define list of Stratix IV-derived families
# | 
proc ::alt_xcvr::utils::device::get_s4_name    { } { return "Stratix IV" }
proc ::alt_xcvr::utils::device::get_a2gz_name  { } { return "Arria II GZ" }
proc ::alt_xcvr::utils::device::get_a2gx_name  { } { return "Arria II GX" }
proc ::alt_xcvr::utils::device::get_hc4_name   { } { return "HardCopy IV" }

proc ::alt_xcvr::utils::device::list_s4_style_hssi_families { } {
  #return {{Stratix IV} {Arria II GZ} {Arria II GX} {HardCopy IV}}
  return [ list [get_s4_name] [get_a2gz_name] [get_a2gx_name] [get_hc4_name] ]
}

# +-----------------------------------
# | Define list of Stratix IV-derived families that are 10G capable
# | 
proc ::alt_xcvr::utils::device::list_s4_style_hssi10g_families { } {
  return [ list [get_s4_name] ]
}

# +-----------------------------------
# | Test if given family has Stratix IV-style HSSI features
# | 
proc ::alt_xcvr::utils::device::has_s4_style_hssi { fam } {
  set fams [ list_s4_style_hssi_families ]
  set famPos [ lsearch -exact $fams $fam ]
  return [expr $famPos > -1 ]
}

# +-----------------------------------
# | Test if given family has Stratix IV-style HSSI features
# | 
proc ::alt_xcvr::utils::device::has_s4_style_hssi10g { fam } {
  set fams [ list_s4_style_hssi10g_families ]
  set famPos [ lsearch -exact $fams $fam ]
  return [expr $famPos > -1 ]
}

# +-----------------------------------
# | Define list of Stratix V-derived families
# | 
proc ::alt_xcvr::utils::device::get_s5_name { } { return "Stratix V" }
proc ::alt_xcvr::utils::device::get_a5gz_name { } { return "Arria V GZ" }

proc ::alt_xcvr::utils::device::list_s5_style_hssi_families { } {
  return [ list [get_s5_name] [get_a5gz_name] ]
}

proc ::alt_xcvr::utils::device::list_a5gz_style_hssi_families { } {
  return [ list [get_a5gz_name] ]
}

# +-----------------------------------
# | Test if given family has Stratix V-style HSSI features
# | 
proc ::alt_xcvr::utils::device::has_s5_style_hssi { fam } {
  set fams [ list_s5_style_hssi_families ]
  set famPos [ lsearch -exact $fams $fam ]
  return [expr $famPos > -1 ]
}

proc ::alt_xcvr::utils::device::has_a5gz_style_hssi { fam } {
  set fams [ list_a5gz_style_hssi_families ]
  set famPos [ lsearch -exact $fams $fam ]
  return [expr $famPos > -1 ]
}

# +-----------------------------------
# | Define list of Arria V-derived families
# | 
proc ::alt_xcvr::utils::device::get_a5_name { } { return "Arria V" }

proc ::alt_xcvr::utils::device::list_a5_style_hssi_families { } {
  return [ list [get_a5_name] ]
}

# +-----------------------------------
# | Test if given family has Arria V-style HSSI features
# |

proc ::alt_xcvr::utils::device::has_a5_style_hssi { fam } {
  set fams [ list_a5_style_hssi_families ]
  set famPos [ lsearch -exact $fams $fam ]
  return [expr $famPos > -1 ]
}

# +-----------------------------------
# | Define list of Cylcone V-derived families
# | 
proc ::alt_xcvr::utils::device::list_c5_style_hssi_families { } {
        #return {"Cyclone V"}
        return [ list "Cyclone V" ]
}

# +-----------------------------------
# | Test if given family has Arria V-style HSSI features
# |

proc ::alt_xcvr::utils::device::has_c5_style_hssi { fam } {
  set fams [ list_c5_style_hssi_families ]
  set famPos [ lsearch -exact $fams $fam ]
  return [expr $famPos > -1 ]
}

##
# Get the part number of the typical devices for a given family
# for speedgrade argument values
proc ::alt_xcvr::utils::device::get_typical_device { device_family {speedgrade "default"} } {

  set device ""
        
  if [has_a5gz_style_hssi $device_family] {
    switch $speedgrade {
      "3_H2"  { set device "ARRIAVGZ_F2D_V2_H2F1517AC3" }
      "4_H3"  { set device "ARRIAVGZ_F2D_V2_H3F1517AC4" }
      default { set device "ARRIAVGZ_F2D_V2_H2F1517AC3" }
    }
  } elseif [has_s5_style_hssi $device_family] {
    switch $speedgrade {
      "1_H1"  { set device "5SGXEA7H1F35C1" }
      "1_H2"  { set device "5SGXEA7H2F35C1" }
      "1_H3"  { set device "5SGXEA7H2F35C1" }
      "2_H1"  { set device "5SGXEA7H1F35C2" }
      "2_H2"  { set device "5SGXEA7H2F35C2" }
      "2_H3"  { set device "5SGXEA7H3F35C2" }
      "3_H2"  { set device "5SGXEA7H2F35C3" }
      "3_H3"  { set device "5SGXEA7H3F35C3" }
      "4_H3"  { set device "5SGXEA7H4F35C3" }
      default { set device "5SGXEA7H1F35C2" }
    }
  } elseif [has_a5_style_hssi $device_family] {
	switch $speedgrade {
      "3_H3"  { set device "5AGTFD3H3F35I3" }
      "4_H4"  { set device "5AGXFB3H4F35C4" }
      "5_H3"  { set device "5AGTFD3H3F35I5" }
      "5_H4"  { set device "5AGXFB3H4F35I5" }
      "6_H6"  { set device "5AGXFB3H6F40C6" }
      default { set device "5AGXFB3H4F40C4" }
    }
  } elseif [has_c5_style_hssi $device_family] {
	switch $speedgrade {
      "6_H6"  { set device "5CGXFC7D6F31C6" }
      "7_H5"  { set device "5CGTFD9E5F35C7" }
      "7_H6"  { set device "5CGXFC9E6F35C7" }
      "8_H6"  { set device "5CSXFC6D6F31C8" }
      "8_H7"  { set device "5CGXFC9E7F35C8" }
	  default { set device "5CGTFD6F27C5ES" }
    }
  }
	
  return $device
}

proc ::alt_xcvr::utils::device::get_device_speedgrades { device_family } {

  set speedgrades [expr { [has_a5gz_style_hssi $device_family]? {fastest 3H2 4H3}
    : [has_s5_style_hssi $device_family] ? {fastest 1_H1 1_H2 1_H3 2_H1 2_H2 2_H3 3_H2 3_H3}
    : [has_a5_style_hssi $device_family] ? {fastest 3_H3 4_H4 5_H3 5_H4 6_H6} 
	: [has_c5_style_hssi $device_family] ? {fastest 6_H6 7_H5 7_H6 8_H6 8_H7} 
    : "fastest" }]
  
  return $speedgrades
}
##
# Get the maximum number of channels for a given device family
proc ::alt_xcvr::utils::device::get_device_family_max_channels { device_family } {
  set channels 0
  if [has_s5_style_hssi $device_family] {
    set channels 66
  } elseif [has_a5_style_hssi $device_family] {
    set channels 36
  } elseif [has_c5_style_hssi $device_family] {
		set channels 12
	}

  return $channels
}

#
proc ::alt_xcvr::utils::device::get_fpll_name { } {
  return "FPLL"
}

proc ::alt_xcvr::utils::device::get_cmu_pll_name { } {
  return "CMU"
}

proc ::alt_xcvr::utils::device::get_atx_pll_name { } {
  return "ATX"
}

##
# Get a list of supported HSSI transceiver PLLs for the given device family
proc ::alt_xcvr::utils::device::get_hssi_pll_types { device_family } {
  if [has_s5_style_hssi $device_family] {
    return [list [get_cmu_pll_name] [get_atx_pll_name]]
  }
  if [has_a5_style_hssi $device_family] {
    return [list [get_cmu_pll_name]]
  }
  if [has_c5_style_hssi $device_family] {
    return [list [get_cmu_pll_name]]
    # return {"FPLL"}
  }
  if [has_s4_style_hssi $device_family] {
    return [list [get_cmu_pll_name] [get_atx_pll_name]]
  }
}

proc ::alt_xcvr::utils::device::get_cgb_divider_values { device_family } {
  if [has_s5_style_hssi $device_family] {
    return {1 2 4 8}
  } elseif [has_a5_style_hssi $device_family] {
    return {1 2 4 8}
  } elseif [has_c5_style_hssi $device_family] {
    return {1 2 4 8}
  } else {
    return {1}
  }
}


# +---------------------------------------------------------------
# | Given a device family, return the reconfig_to_xcvr bundle width
# |
proc ::alt_xcvr::utils::device::get_reconfig_to_xcvr_width { fam } {
  set s4_style_width 4
  set s5_style_width 70

  if { [has_s4_style_hssi $fam] } {
    # Stratix IV style
    return $s4_style_width
  } elseif { [has_c4_style_hssi $fam] } {
    # Cyclone IV style
    return $s4_style_width
  } elseif { [has_s5_style_hssi $fam] | [has_a5_style_hssi $fam] | [has_c5_style_hssi $fam] } {
    # Stratix V style
    return $s5_style_width
  } else {
    # Invalid family - not sure what to do here.
    return 0;
  }
}


# +-----------------------------------------------------------------
# | Given a device family, return the reconfig_from_xcvr bundle width
proc ::alt_xcvr::utils::device::get_reconfig_from_xcvr_width { fam } {
  set s4_style_width 17
  set s5_style_width 46

  if { [has_s4_style_hssi $fam] } {
    # Stratix IV style
    return $s4_style_width
  } elseif { [has_c4_style_hssi $fam] } {
    # Cyclone IV style
    return $s4_style_width
  } elseif { [has_s5_style_hssi $fam] | [has_a5_style_hssi $fam] | [has_c5_style_hssi $fam] } {
    # Stratix V style
    return $s5_style_width
  } else {
    # Invalid family - not sure what to do here.
    return 0;
  }
}


# +----------------------------------------------------------------
# | Get the number of reconfig interfaces given a device family and
# | other required parameters
# | fam - Device family
# | channels - Number of transceiver channels
# | tx_plls - Number of transmit plls (needed for Stratix V families)
proc ::alt_xcvr::utils::device::get_reconfig_interface_count { fam channels tx_plls } {
  set count 0
  if { [has_s4_style_hssi $fam] } {
    set count [expr {$channels / 4} ]
    if { [expr {$channels % 4}] != 0 } {
      set count [expr {$count + 1}]
    }
  } elseif { [has_s5_style_hssi $fam] | [has_a5_style_hssi $fam] | [has_c5_style_hssi $fam] } {
    set count [expr {$channels + $tx_plls}]
  }

  return $count
}

# +------------------------------------------------------------------
# | Get reconfig_to_xcvr total port width for specified device family
#
# | Returns 0 if the device_family argument is invalid, otherwise
# | it returns the width of the reconfig_to_xcvr port for that family
proc ::alt_xcvr::utils::device::get_reconfig_to_xcvr_total_width { fam reconfig_interfaces } {
  set count 0
  set width [get_reconfig_to_xcvr_width $fam]
  if { [has_s5_style_hssi $fam ] | [has_a5_style_hssi $fam] | [has_c5_style_hssi $fam] } {
    set count [expr {$reconfig_interfaces * $width}]
  } elseif { [has_s4_style_hssi $fam] } {
    set count $width
  }  elseif { [has_c4_style_hssi $fam] } {
    # Cyclone IV style
    set count $width
  } else {
    set count 0
  }
  return $count
}


# +------------------------------------------------------------------
# | Get reconfig_from_xcvr total port width for specified device family
#
# | Returns 0 if the device_family argument is invalid, otherwise
# | it returns the width of the reconfig_from_xcvr port for that family
proc ::alt_xcvr::utils::device::get_reconfig_from_xcvr_total_width { fam reconfig_interfaces } {
  set count 0
  set width [get_reconfig_from_xcvr_width $fam]
  if { [has_s5_style_hssi $fam ] | [has_a5_style_hssi $fam] | [has_c5_style_hssi $fam] } {
    set count [expr {$reconfig_interfaces * $width}]
  } elseif { [has_s4_style_hssi $fam] } {
    set count [expr {$reconfig_interfaces * $width}]
  } elseif { [has_c4_style_hssi $fam] } {
    set count [expr {$reconfig_interfaces * $width}]
  } else {
    set count 0
  }
  return $count
}

# +-----------------------------------
# | converting the given speedgrade representation to the corresponding value (-2, -3, -4)
# |
proc ::alt_xcvr::utils::device::convert_speed_grade { speed_grade } {
   set speed_grade_val 4

   if {[string compare -nocase $speed_grade 1_H2]==0 } {
      set speed_grade_val 2   
   } elseif { [string compare -nocase $speed_grade 1_H3]==0 } {
      set speed_grade_val 3   
   } elseif { [string compare -nocase $speed_grade 1_H4]==0 } {
      set speed_grade_val 4   
   } else {
      set speed_grade_val 4   
   }
   return $speed_grade_val    
}


###
# Returns a data structure (dictionary) containing the register map 
# for the specified blocks.
#
# @param blocks A list of the desired blocks "pma, pcs, fpll, or atx" the register map should contain
#
# @return A dictionary of the structure returned by the 
#         ::alt_xcvr_utils::common::parse_series10_style_register_map procedure.
#         Refer to that procedure for details
#         Returns -1 if an error occurs
proc ::alt_xcvr::utils::device::get_arria10_regmap { {blocks {pma pcs fpll atx}} } {
  set filenames [dict create]
  dict set filenames pma "PMA_Register_Map.csv"
  dict set filenames pcs "PCS_Register_Map.csv"
  dict set filenames fpll "FPLL_Register_Map.csv"
  dict set filenames atx "ATXPLL_Register_Map.csv"

  set data [dict create]

  foreach block $blocks {
    if {![dict exists $filenames $block]} {
      return -1
    } else {
      set filename "[::alt_xcvr::utils::fileset::get_alt_xcvr_path]/alt_xcvr_core/nf/doc/[dict get $filenames $block]"
      set retval [::alt_xcvr::utils::common::parse_series10_style_register_map $filename]
      if {$retval == -1} {
        return $retval
      } else {
        set data [dict merge $data $retval]
      }
    }
  }

  return $data
}

