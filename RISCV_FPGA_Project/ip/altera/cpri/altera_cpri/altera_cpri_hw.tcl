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


# | module altera_cpri wrapper
# |
#package require -exact sopc 11.0

package require -exact qsys 12.1

set_module_property NAME altera_cpri
set_module_property AUTHOR "Altera Corporation"
set_module_property VERSION 13.1
set_module_property INTERNAL true 
set_module_property GROUP "Interface Protocols/High Speed"
set_module_property DISPLAY_NAME "CPRI"
set_module_property DESCRIPTION "ALTERA CPRI"
#set_module_property LIBRARIES {ieee.std_logic_1164.all ieee.std_logic_arith.all ieee.std_logic_unsigned.all std.standard.all}
set_module_property DATASHEET_URL "http://www.altera.com/literature/ug/ug_cpri.pdf"
set_module_property EDITABLE false
set_module_property ANALYZE_HDL true
set_module_property HIDE_FROM_SOPC true
set_module_property ALLOW_GREYBOX_GENERATION true
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true

# Callback function
set_module_property VALIDATION_CALLBACK my_validation_callback
set_module_property COMPOSITION_CALLBACK my_compose_callback

# Source the commonon constant
source ./altera_cpri_common_constants.tcl

#################################################################################################
# Testbench
#################################################################################################
source ./altera_cpri_tb_gen.tcl

# +---------------------------------
# | Main
# |
# +-----------------------------------
# | parameters
# | 
add_parameter DEVICE integer 0
set_parameter_property DEVICE VISIBLE false
set_parameter_property DEVICE DERIVED true
set_parameter_property DEVICE IS_HDL_PARAMETER true 

add_parameter phy_linerate String ""
set_parameter_property phy_linerate VISIBLE false
set_parameter_property phy_linerate DERIVED true
set_parameter_property phy_linerate IS_HDL_PARAMETER false

add_parameter phy_pll_refclk_freq String ""
set_parameter_property phy_pll_refclk_freq VISIBLE false
set_parameter_property phy_pll_refclk_freq DERIVED true
set_parameter_property phy_pll_refclk_freq IS_HDL_PARAMETER false

add_parameter phy_device String ""
set_parameter_property phy_device VISIBLE false
set_parameter_property phy_device DERIVED true
set_parameter_property phy_device IS_HDL_PARAMETER false

add_parameter DEVICEFAMILY String ""
set_parameter_property DEVICEFAMILY VISIBLE false
set_parameter_property DEVICEFAMILY AFFECTS_GENERATION false
set_parameter_property DEVICEFAMILY IS_HDL_PARAMETER false
set_parameter_property DEVICEFAMILY SYSTEM_INFO DEVICE_FAMILY

add_parameter SYNC_MODE INTEGER 0 "This parameter specifies whether the CPRI MegaCore function is a Master or Slave port."
set_parameter_property SYNC_MODE DISPLAY_NAME "Operation mode " 
set_parameter_property SYNC_MODE UNITS None
set_parameter_property SYNC_MODE ALLOWED_RANGES {0:Master\ \(REC\ or\ RE\ Master\) 1:Slave\ \(RE\ Slave\)}
set_parameter_property SYNC_MODE DISPLAY_HINT ""
set_parameter_property SYNC_MODE AFFECTS_GENERATION true 
set_parameter_property SYNC_MODE IS_HDL_PARAMETER true
add_display_item "Physical Layer" SYNC_MODE parameter

add_parameter LINERATE INTEGER 614 "This parameter specifies the line rate on the CPRI link in Gigabaud"
set_parameter_property LINERATE DISPLAY_NAME "Line rate (Gbit/s) "
set_parameter_property LINERATE UNITS None
set_parameter_property LINERATE ALLOWED_RANGES {614:0.6144 0:1.2288 1:2.4576 2:3.0720 3:4.9152 4:6.1440 5:9.8304}
set_parameter_property LINERATE DISPLAY_HINT ""
set_parameter_property LINERATE AFFECTS_GENERATION true 
set_parameter_property LINERATE IS_HDL_PARAMETER true 
add_display_item "Physical Layer" LINERATE parameter

set ch [list]; for {set i 0} {$i < 381} {incr i} {  if {$i%4==0} { set ch [linsert $ch $i $i] } }

add_parameter S_CH_NUMBER_M INTEGER 0 "This parameter specifies the Starting Channel Number of Master Transceiver."
set_parameter_property S_CH_NUMBER_M DISPLAY_NAME "Master transceiver starting channel number"
set_parameter_property S_CH_NUMBER_M UNITS None
set_parameter_property S_CH_NUMBER_M ALLOWED_RANGES $ch
set_parameter_property S_CH_NUMBER_M DISPLAY_HINT ""
set_parameter_property S_CH_NUMBER_M AFFECTS_GENERATION true
set_parameter_property S_CH_NUMBER_M IS_HDL_PARAMETER true
add_display_item "Physical Layer" S_CH_NUMBER_M parameter

add_parameter S_CH_NUMBER_S_TX INTEGER 0 "This parameter specifies the Starting Channel Number of Slave Transmitter."
set_parameter_property S_CH_NUMBER_S_TX DISPLAY_NAME "Slave transmitter starting channel number" 
set_parameter_property S_CH_NUMBER_S_TX UNITS None
set_parameter_property S_CH_NUMBER_S_TX ALLOWED_RANGES $ch
set_parameter_property S_CH_NUMBER_S_TX DISPLAY_HINT ""
set_parameter_property S_CH_NUMBER_S_TX AFFECTS_GENERATION true
set_parameter_property S_CH_NUMBER_S_TX IS_HDL_PARAMETER true
add_display_item "Physical Layer" S_CH_NUMBER_S_TX parameter

add_parameter S_CH_NUMBER_S_RX INTEGER 4 "This parameter specifies the Starting Channel Number of Slave Receiver."
set_parameter_property S_CH_NUMBER_S_RX DISPLAY_NAME "Slave receiver starting channel number" 
set_parameter_property S_CH_NUMBER_S_RX UNITS None
set_parameter_property S_CH_NUMBER_S_RX ALLOWED_RANGES $ch
set_parameter_property S_CH_NUMBER_S_RX DISPLAY_HINT ""
set_parameter_property S_CH_NUMBER_S_RX AFFECTS_GENERATION true 
set_parameter_property S_CH_NUMBER_S_RX IS_HDL_PARAMETER true
add_display_item "Physical Layer" S_CH_NUMBER_S_RX parameter

add_parameter WIDTH_RX_BUF INTEGER 6 "This parameter specifies log2 of the depth of receiver elastic buffer."
set_parameter_property WIDTH_RX_BUF DISPLAY_NAME "Receiver FIFO depth (value shown is log2 of actual depth)" 
set_parameter_property WIDTH_RX_BUF UNITS None
set_parameter_property WIDTH_RX_BUF ALLOWED_RANGES {4:4 5:5 6:6 7:7 8:8}
set_parameter_property WIDTH_RX_BUF DISPLAY_HINT ""
set_parameter_property WIDTH_RX_BUF AFFECTS_GENERATION true 
set_parameter_property WIDTH_RX_BUF IS_HDL_PARAMETER true
add_display_item "Physical Layer" WIDTH_RX_BUF parameter

add_parameter XCVR_FREQ STRING 122.88 "This parameter specifies the frequency of the transceiver reference clock"
set_parameter_property XCVR_FREQ DISPLAY_NAME "Transceiver reference clock frequency "
set_parameter_property XCVR_FREQ UNITS Megahertz
set_parameter_property XCVR_FREQ ALLOWED_RANGES {30.72 61.44 76.8 122.88 153.6 245.76 307.2 491.52 614.4}
set_parameter_property XCVR_FREQ DISPLAY_HINT ""
set_parameter_property XCVR_FREQ AFFECTS_GENERATION true 
set_parameter_property XCVR_FREQ IS_HDL_PARAMETER true 
add_display_item "Physical Layer" XCVR_FREQ parameter

add_parameter AUTORATE integer 0 "This parameter specifies whether the auto-rate negotiation feature is turned on or not"
set_parameter_property AUTORATE DISPLAY_NAME "Enable auto-rate negotiation "
set_parameter_property AUTORATE DISPLAY_HINT boolean
set_parameter_property AUTORATE AFFECTS_GENERATION true
set_parameter_property AUTORATE IS_HDL_PARAMETER true
add_display_item "Physical Layer" AUTORATE parameter

add_parameter CAL_OFF integer 0
set_parameter_property CAL_OFF VISIBLE false
set_parameter_property CAL_OFF DERIVED true
set_parameter_property CAL_OFF IS_HDL_PARAMETER true

add_parameter CALOFF boolean 0 "This parameter specifies whether to include the automatic round-trip delay calibration logic or not"
set_parameter_property CALOFF DISPLAY_NAME "Include automatic round-trip delay calibration logic"
set_parameter_property CALOFF DISPLAY_HINT boolean
set_parameter_property CALOFF IS_HDL_PARAMETER false
add_display_item "Physical Layer" CALOFF parameter

add_parameter HDLC_OFF integer 0
set_parameter_property HDLC_OFF VISIBLE false
set_parameter_property HDLC_OFF DERIVED true
set_parameter_property HDLC_OFF IS_HDL_PARAMETER true

add_parameter HDLCOFF boolean 0 "This parameter specifies whether to include internal HDLC block or not"
set_parameter_property HDLCOFF DISPLAY_NAME "Include HDLC block "
set_parameter_property HDLCOFF DISPLAY_HINT boolean
set_parameter_property HDLCOFF IS_HDL_PARAMETER false
add_display_item "Data Link Layer" HDLCOFF parameter

add_parameter MAC_OFF integer 0
set_parameter_property MAC_OFF VISIBLE false
set_parameter_property MAC_OFF DERIVED true
set_parameter_property MAC_OFF IS_HDL_PARAMETER true

add_parameter MACOFF boolean 0 "This parameter specifies whether to include internal MAC block or not"
set_parameter_property MACOFF DISPLAY_NAME "Include MAC block "
set_parameter_property MACOFF DISPLAY_HINT boolean
set_parameter_property MACOFF IS_HDL_PARAMETER false
add_display_item "Data Link Layer" MACOFF parameter

add_parameter MAP_MODE INTEGER 4 "This parameter specifies the CPRI MegaCore function available mapping mode(s)."
set_parameter_property MAP_MODE DISPLAY_NAME "Mapping mode(s) " 
set_parameter_property MAP_MODE UNITS None
set_parameter_property MAP_MODE ALLOWED_RANGES {0:Basic 1:Advanced\ 1 2:Advanced\ 2 3:Advanced\ 3 4:All}
set_parameter_property MAP_MODE DISPLAY_HINT ""
set_parameter_property MAP_MODE AFFECTS_GENERATION true 
set_parameter_property MAP_MODE IS_HDL_PARAMETER true
add_display_item "Application Layer" MAP_MODE parameter

add_parameter N_MAP INTEGER 0 "This parameter specifices how many antenna/carrier interfaces are enabled"
set_parameter_property N_MAP DISPLAY_NAME "Number of antenna/carrier interfaces"
set_parameter_property N_MAP UNITS None
set_parameter_property N_MAP ALLOWED_RANGES {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
set_parameter_property N_MAP DISPLAY_HINT ""
set_parameter_property N_MAP AFFECTS_GENERATION true
set_parameter_property N_MAP IS_HDL_PARAMETER true
add_display_item "Application Layer" N_MAP parameter

add_parameter SYNC_MAP integer 0 "This parameter specifies whether the map synchronization with core clock feature is turned on or not"
set_parameter_property SYNC_MAP DISPLAY_NAME "Enable MAP interface synchronization with core clock "
set_parameter_property SYNC_MAP DISPLAY_HINT boolean
set_parameter_property SYNC_MAP AFFECTS_GENERATION true
set_parameter_property SYNC_MAP IS_HDL_PARAMETER true
add_display_item "Application Layer" SYNC_MAP parameter

add_parameter VSS_OFF integer 0
set_parameter_property VSS_OFF VISIBLE false
set_parameter_property VSS_OFF DERIVED true
set_parameter_property VSS_OFF IS_HDL_PARAMETER true

add_parameter VSSOFF boolean 0 "This parameter specifies whether the Vendor Specific Space (VSS) access is turned on or not"
set_parameter_property VSSOFF DISPLAY_NAME "Include Vendor Specific Space (VSS) access through CPU interface"
set_parameter_property VSSOFF DISPLAY_HINT boolean
set_parameter_property VSSOFF IS_HDL_PARAMETER false
add_display_item "Application Layer" VSSOFF parameter

add_parameter CODE_BASE integer 0 "This parameter specifies which code base to select"
set_parameter_property CODE_BASE DISPLAY_NAME "Code base number"
set_parameter_property CODE_BASE UNITS None
set_parameter_property CODE_BASE ALLOWED_RANGES {0 1 2 3}
set_parameter_property CODE_BASE DISPLAY_HINT boolean
set_parameter_property CODE_BASE AFFECTS_GENERATION true
set_parameter_property CODE_BASE IS_HDL_PARAMETER true
set_parameter_property CODE_BASE VISIBLE false
add_display_item "Application Layer" CODE_BASE parameter

# +--------------------------
# | Validation Callback
# |
proc my_validation_callback {} {
   # Retrive the HDL parameter from the user's input
   set device                 [get_parameter_value DEVICEFAMILY]
   set linerate               [get_parameter_value LINERATE]
   set mode                   [get_parameter_value SYNC_MODE]
   set map_mode               [get_parameter_value MAP_MODE]
   set n                      [get_parameter_value N_MAP]
   set mac___off              [get_parameter_value MACOFF]
   set hdlc___off             [get_parameter_value HDLCOFF]
   set vss___off              [get_parameter_value VSSOFF]
   set cal___off              [get_parameter_value CALOFF] 
   set autorate               [get_parameter_value AUTORATE] 

   # INFO:
   # Acceptable XCVR frequency range for Arria V and Stratix V.
   set freq0 {30.72 61.44 76.8 122.88 153.6 245.76 307.2 491.52 614.4}
   set freq1 {30.72 61.44 76.8 122.88 153.6 245.76 307.2 491.52 614.4}
   set freq2 {30.72 49.152 61.44 76.8 98.304 102.4 122.88 153.6 196.608 204.8 245.76 307.2 393.216 409.6 491.52 614.4}
   set freq3 {38.4 61.44 76.8 96.0 122.88 128.0 153.6 192.0 245.76 256.0 307.2 384.0 491.52 512.0 614.4}
   set freq4 {49.152 61.44 76.8 98.304 122.88 153.6 196.608 204.8 245.76 307.2 393.216 409.6 491.52 614.4}
   set freq5 {61.44 76.8 96.0 122.88 153.6 192.0 245.76 307.2 384.0 491.52 614.4}
   set freq6 {98.304 122.88 153.6 196.608 245.76 307.2 393.216 491.52 614.4} 
   # Acceptable XCVR frequency range for Cyclone V.
   set freq7 {61.44 76.8 122.88 153.6 245.76 307.2 491.52 614.4}
   set freq8 {49.152 61.44 76.8 98.304 102.4 122.88 153.6 196.608}
   set freq9 {61.44 76.8 96.0 122.88 128.0 153.6 192.0 245.76 256.0}

   # INFO:
   # Supported linerate for all the supported family
   set aii_siv_freq  {614:0.6144 0:1.2288 1:2.4576 2:3.0720 3:4.9152 4:6.1440}
   set civ_freq      {614:0.6144 0:1.2288 1:2.4576 2:3.0720}
   set av_sv_freq    {614:0.6144 0:1.2288 1:2.4576 2:3.0720 3:4.9152 4:6.1440 5:9.8304}
   set cv_freq       {614:0.6144 0:1.2288 1:2.4576 2:3.0720} 

   # Number of supported channels for different mapping mode
   set bas0_614   {0 1 2 3 4}
   set bas0_1228  {0 1 2 3 4 5 6 7 8}
   set bas0_2457  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
   set bas0_3072  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20}
   set bas0_4915  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
   set bas0_6144  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
   set bas0_9830  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
   set adv1_614   {0 1 2}
   set adv1_1228  {0 1 2 3 4}
   set adv1_2457  {0 1 2 3 4 5 6 7 8}
   set adv1_3072  {0 1 2 3 4 5 6 7 8 9 10}
   set adv1_4915  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
   set adv1_6144  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20}
   set adv1_9830  {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
   set adv23_614  {0 1 2 3 4}
   set adv23_1228 {0 1 2 3 4 5 6 7 8}
   set adv23_2457 {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
   set adv23_3072 {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20}
   set adv23_4915 {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
   set adv23_6144 {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}
   set adv23_9830 {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}

   if { $map_mode == 0 || $map_mode == 4 } {
	if { $linerate == 614 } {
		set_parameter_property N_MAP ALLOWED_RANGES $bas0_614
	} elseif { $linerate == 0 } {
		set_parameter_property N_MAP ALLOWED_RANGES $bas0_1228
	} elseif { $linerate == 1 } {
		set_parameter_property N_MAP ALLOWED_RANGES $bas0_2457
	} elseif { $linerate == 2 } {
		set_parameter_property N_MAP ALLOWED_RANGES $bas0_3072
	} elseif { $linerate == 3 } {
		set_parameter_property N_MAP ALLOWED_RANGES $bas0_4915
	} elseif { $linerate == 4 } {
		set_parameter_property N_MAP ALLOWED_RANGES $bas0_6144
	} elseif { $linerate == 5 } {
		set_parameter_property N_MAP ALLOWED_RANGES $bas0_9830
	}
   } elseif { $map_mode == 1} {
	if { $linerate == 614 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv1_614
	} elseif { $linerate == 0 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv1_1228
	} elseif { $linerate == 1 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv1_2457
	} elseif { $linerate == 2 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv1_3072
	} elseif { $linerate == 3 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv1_4915
	} elseif { $linerate == 4 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv1_6144
	} elseif { $linerate == 5 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv1_9830
	}
   } elseif { $map_mode == 2 || $map_mode == 3 } {
	if { $linerate == 614 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv23_614
	} elseif { $linerate == 0 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv23_1228
	} elseif { $linerate == 1 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv23_2457
	} elseif { $linerate == 2 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv23_3072
	} elseif { $linerate == 3 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv23_4915
	} elseif { $linerate == 4 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv23_6144
	} elseif { $linerate == 5 } {
		set_parameter_property N_MAP ALLOWED_RANGES $adv23_9830
	}
   }
   
   # Derived MAC_OFF parameter from mac___off  
   if {$mac___off == "false"} {
      set_parameter_value MAC_OFF 1
   } else {
      set_parameter_value MAC_OFF 0
   }
 
   # Derived HDLC_OFF parameter from hdlc___off  
   if {$hdlc___off == "false"} {
      set_parameter_value HDLC_OFF 1
   } else {
      set_parameter_value HDLC_OFF 0
	}

   # Derived VSS_OFF parameter from vss___off  
   if {$vss___off == "false"} {
      set_parameter_value VSS_OFF 1
   } else {
      set_parameter_value VSS_OFF 0
	}

   # Derived CAL_OFF parameter from cal___off  
   if {$cal___off == "false"} {
      set_parameter_value CAL_OFF 1
   } else {
      set_parameter_value CAL_OFF 0
	}

   # INFO:
   # XCVR channel number and XCVR Freq should hidden when device is Arria V & Stratix V
   if {$device == "Stratix V" || $device == "Cyclone V" || $device == "Arria V GZ" || $device == "Arria V"} {
      set_parameter_property S_CH_NUMBER_M         visible false
      set_parameter_property S_CH_NUMBER_S_TX      visible false
      set_parameter_property S_CH_NUMBER_S_RX      visible false
      set_parameter_property AUTORATE              enabled true 
   } else {
      set_parameter_property XCVR_FREQ             visible false
      if {$mode == "0"} then {
         set_parameter_property S_CH_NUMBER_M         enabled true
         set_parameter_property S_CH_NUMBER_S_TX      enabled false
         set_parameter_property S_CH_NUMBER_S_RX      enabled false
      } else {
         set_parameter_property S_CH_NUMBER_M         enabled false
         set_parameter_property S_CH_NUMBER_S_TX      enabled true
         set_parameter_property S_CH_NUMBER_S_RX      enabled true
      }
   }

# messsage on the AVGT/GX
if {$device == "Arria V"} {
   if {$autorate == 1} {  
      send_message info "$device GX only supports Line Rate = 0.6144, 1.2288, 2.4576, 3.072, 4.915 or 6.144 Gbps in Auto Rate Negotiation."
      send_message info "$device GT only supports Line Rate = 1.2288, 2.4576, 3.072, 4.915, 6.144 or 9.8304 Gbps in Auto Rate Negotiation." 
      if {$linerate == "5"} {
         send_message info "SOFT PCS is used."
      } else {
         send_message info "HARD PCS is used."
      }
   }
} 

	if { $n == "0" } {
      set_parameter_property SYNC_MAP ENABLED false
   } else {
      set_parameter_property SYNC_MAP ENABLED true
   } 

   # Derived the device from a String to a numerical type
   if { $device == "Stratix IV"} {
      set_parameter_value DEVICE 0
      set_parameter_value phy_device "Stratix IV"
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
   } elseif { $device == "Arria II GX"} {
		set_parameter_value DEVICE 1
      set_parameter_value phy_device "Arria II GX"
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
	} elseif { $device == "Arria II GZ"} {
		set_parameter_value DEVICE 2
      set_parameter_value phy_device "Arria II GZ"
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
	} elseif { $device == "HardCopy IV"} {
		set_parameter_value DEVICE 0
      set_parameter_value phy_device "HardCopy IV"
      set_parameter_property LINERATE ALLOWED_RANGES $aii_siv_freq
	} elseif { $device == "Cyclone IV GX"} { 
      set_parameter_value DEVICE 3 
      set_parameter_value phy_device "Cyclone IV GX"
      set_parameter_property LINERATE ALLOWED_RANGES $civ_freq
    } elseif { $device == "Stratix V"} {
      set_parameter_value DEVICE 4
      set_parameter_value phy_device "Stratix V"
      set_parameter_property LINERATE ALLOWED_RANGES $av_sv_freq
    } elseif { $device == "Arria V"} {
      set_parameter_value DEVICE 5
      set_parameter_value phy_device "Arria V"
      set_parameter_property LINERATE ALLOWED_RANGES $av_sv_freq
    } elseif { $device == "Cyclone V"} {
      set_parameter_value DEVICE 6
      set_parameter_value phy_device "Cyclone V"
      set_parameter_property LINERATE ALLOWED_RANGES $cv_freq
    } elseif { $device == "Arria V GZ"} {
      set_parameter_value DEVICE 7
      set_parameter_value phy_device "Arria V GZ"
      set_parameter_property LINERATE ALLOWED_RANGES $av_sv_freq
    } else {
		set_parameter_value DEVICE 8
      send_message error "Invalid device family selected."
   }

   # Derived the input xcvr_det_latency linerate & refclk_freq based on the CPRI linerate
   if {$device == "Stratix V" || $device == "Arria V" || $device == "Arria V GZ"} {
      if { $linerate == 614 } {
         set_parameter_value phy_linerate        "614.4 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq0
      } elseif { $linerate == 0} {
         set_parameter_value phy_linerate        "1228.8 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq1
      } elseif { $linerate == 1} {
         set_parameter_value phy_linerate        "2457.6 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq2
      } elseif { $linerate == 2} {
         set_parameter_value phy_linerate        "3072.0 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq3
      } elseif { $linerate == 3} {
         set_parameter_value phy_linerate        "4915.2 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq4
      } elseif { $linerate == 4} {
         set_parameter_value phy_linerate        "6144.0 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq5
      } elseif { $linerate == 5} {
         set_parameter_value phy_linerate        "9830.4 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq6
      } else {
         set_parameter_value phy_linerate        "614.0 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq0
      } 
   } else {
      # Cyclone V
      if { $linerate == 614 } {
         set_parameter_value phy_linerate        "614.4 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq7
      } elseif { $linerate == 0} {
         set_parameter_value phy_linerate        "1228.8 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq7
      } elseif { $linerate == 1} {
         set_parameter_value phy_linerate        "2457.6 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq8
      } elseif { $linerate == 2} {
         set_parameter_value phy_linerate        "3072.0 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq9
      } else {
         set_parameter_value phy_linerate        "614.4 Mbps"
         set_parameter_property XCVR_FREQ ALLOWED_RANGES $freq7
      }
   }
}

# +-------------------------
# | Composed callback
# |
proc my_compose_callback {} {
   my_call_altera_cpri_instance
   my_call_altera_cpri_connection
}

proc inst_duplex_xcvr {inst_xcvr phy phy_deser_factor phy_pcs_pma_width phy_linerate XCVR_FREQ pll_reconfig} {
  add_instance                 $inst_xcvr $phy 13.1
  # set_instance_parameter inst_xcvr device_family $phy_device
  set_instance_parameter $inst_xcvr operation_mode Duplex
  set_instance_parameter $inst_xcvr lanes 1
  set_instance_parameter $inst_xcvr gui_deser_factor $phy_deser_factor
  set_instance_parameter $inst_xcvr gui_pcs_pma_width $phy_pcs_pma_width
  set_instance_parameter $inst_xcvr data_rate $phy_linerate
  set_instance_parameter $inst_xcvr gui_base_data_rate $phy_linerate
  set_instance_parameter $inst_xcvr word_aligner_mode deterministic_latency
  set_instance_parameter $inst_xcvr run_length_violation_checking 40
  set_instance_parameter $inst_xcvr gui_use_wa_status 1
  set_instance_parameter $inst_xcvr gui_use_8b10b_status 1
  set_instance_parameter $inst_xcvr gui_use_status 1
  set_instance_parameter $inst_xcvr gui_pll_refclk_freq "$XCVR_FREQ MHz"
  set_instance_parameter $inst_xcvr gui_tx_bitslip_enable 1
  set_instance_parameter $inst_xcvr channel_interface 1
  set_instance_parameter $inst_xcvr gui_pll_reconfig_enable_pll_reconfig $pll_reconfig 
}

proc inst_rx_xcvr {inst_xcvr phy phy_deser_factor phy_pcs_pma_width phy_linerate XCVR_FREQ pll_reconfig} {
   add_instance                 $inst_xcvr $phy 13.1
   #set_instance_parameter inst_rx_xcvr device_family $phy_device
   set_instance_parameter $inst_xcvr operation_mode RX
   set_instance_parameter $inst_xcvr lanes 1
   set_instance_parameter $inst_xcvr gui_deser_factor $phy_deser_factor
   set_instance_parameter $inst_xcvr gui_pcs_pma_width $phy_pcs_pma_width
   set_instance_parameter $inst_xcvr data_rate $phy_linerate
   set_instance_parameter $inst_xcvr gui_base_data_rate $phy_linerate
   set_instance_parameter $inst_xcvr word_aligner_mode deterministic_latency
   set_instance_parameter $inst_xcvr run_length_violation_checking 40
   set_instance_parameter $inst_xcvr gui_use_wa_status 1
   set_instance_parameter $inst_xcvr gui_use_8b10b_status 1
   set_instance_parameter $inst_xcvr gui_use_status 1
   set_instance_parameter $inst_xcvr gui_pll_refclk_freq "$XCVR_FREQ MHz"
   set_instance_parameter $inst_xcvr channel_interface 1
   set_instance_parameter $inst_xcvr gui_pll_reconfig_enable_pll_reconfig $pll_reconfig
}

proc inst_tx_xcvr {inst_xcvr phy phy_deser_factor phy_pcs_pma_width phy_linerate XCVR_FREQ pll_reconfig } {
   add_instance                 $inst_xcvr $phy 13.1
   #set_instance_parameter inst_tx_xcvr device_family $phy_device
   set_instance_parameter $inst_xcvr operation_mode TX
   set_instance_parameter $inst_xcvr lanes 1
   set_instance_parameter $inst_xcvr gui_deser_factor $phy_deser_factor
   set_instance_parameter $inst_xcvr gui_pcs_pma_width $phy_pcs_pma_width
   set_instance_parameter $inst_xcvr data_rate $phy_linerate
   set_instance_parameter $inst_xcvr gui_base_data_rate $phy_linerate
   set_instance_parameter $inst_xcvr word_aligner_mode deterministic_latency
   set_instance_parameter $inst_xcvr run_length_violation_checking 40
   set_instance_parameter $inst_xcvr gui_tx_bitslip_enable 1
   set_instance_parameter $inst_xcvr gui_pll_refclk_freq "$XCVR_FREQ MHz"
   set_instance_parameter $inst_xcvr channel_interface 1
   set_instance_parameter $inst_xcvr gui_pll_reconfig_enable_pll_reconfig $pll_reconfig 
}

proc my_call_altera_cpri_instance {} {
# Retrive the HDL parameter from the user's input
   set device                 [get_parameter_value DEVICE]
   set sync_mode              [get_parameter_value SYNC_MODE]
   set mac__off               [get_parameter_value MACOFF]
   set hdlc__off              [get_parameter_value HDLCOFF]
   set vss__off               [get_parameter_value VSSOFF]
   set cal__off               [get_parameter_value CALOFF]
   set autorate               [get_parameter_value AUTORATE]
   set linerate               [get_parameter_value LINERATE]
   set S_CH_NUMBER_S_TX_value [get_parameter_value S_CH_NUMBER_S_TX]
   set S_CH_NUMBER_S_RX_value [get_parameter_value S_CH_NUMBER_S_RX]
   set S_CH_NUMBER_M          [get_parameter_value S_CH_NUMBER_M]
   set WIDTH_RX_BUF           [get_parameter_value WIDTH_RX_BUF]
   set map_mode               [get_parameter_value MAP_MODE]
   set N_MAP                  [get_parameter_value N_MAP]
   set SYNC_MAP               [get_parameter_value SYNC_MAP]
   set phy_linerate           [get_parameter_value phy_linerate]
   set phy_device             [get_parameter_value phy_device]    
   set XCVR_FREQ              [get_parameter_value XCVR_FREQ]
   set CODE_BASE              [get_parameter_value CODE_BASE]

   if {$sync_mode ==0} {
      if {$autorate == 1} { 
         if {$N_MAP ==0 && $mac__off == "true"} {
            if {$device < 3} {
               send_message info "tb_altera_cpri_autorate will be generated."
            } elseif {$device == 3 } {
               send_message info "tb_altera_cpri_c4gx_autorate will be generated."
            } elseif {$device == 5 && $linerate == 5} {
               send_message info "tb_altera_cpri_autorate_98G_phy will be generated." 
            } else {
               send_message info "tb_altera_cpri_autorate_phy will be generated."    
            }
         } else {
            send_message info "Autorate-negotiation customer testbench will only be generated if the number of antenna carrier is 0 and MAC block is enabled."
         }
      }
   } else {
      send_message info "No customer demo testbench will be generated if it is in slave mode."
   }



# +--------------------------------------------------------------------------------------------------------------
# |INFO: 1. adding altera_clock_bridge is only needed when you to export the clk/reset from the most top tcl file
# |      2. Separate clk and reset bridge to avoid the generation of the altera synchonizers. 

# clk and reset 
add_instance              clk_ex_delay                   altera_clock_bridge 13.1
add_instance              reset_ex_delay                 altera_reset_bridge 13.1

add_instance              cpu_clk                        altera_clock_bridge 13.1
add_instance              cpu_reset                      altera_reset_bridge 13.1

# clk source for mapping interface
   for {set i 0} {$i < 24} {incr i} {
      if {$i < $N_MAP} {
         if { $SYNC_MAP  == "0" } {
            add_instance              map${i}_tx_clk                  altera_clock_bridge 13.1
            add_instance              map${i}_tx_reset                altera_reset_bridge 13.1
            add_instance              map${i}_rx_clk                  altera_clock_bridge 13.1
            add_instance              map${i}_rx_reset                altera_reset_bridge 13.1 
         } 
      }
   }

# +-----------------------------
# | CPRI_INSTANCE instantiation
# |
add_instance                 inst_cpri altera_cpri_instance 13.1
set_instance_parameter inst_cpri SYNC_MODE $sync_mode
set_instance_parameter inst_cpri LINERATE $linerate
set_instance_parameter inst_cpri AUTORATE $autorate
set_instance_parameter inst_cpri S_CH_NUMBER_M $S_CH_NUMBER_M
set_instance_parameter inst_cpri S_CH_NUMBER_S_TX $S_CH_NUMBER_S_TX_value 
set_instance_parameter inst_cpri S_CH_NUMBER_S_RX $S_CH_NUMBER_S_RX_value
set_instance_parameter inst_cpri WIDTH_RX_BUF $WIDTH_RX_BUF
set_instance_parameter inst_cpri MACOFF $mac__off
set_instance_parameter inst_cpri HDLCOFF $hdlc__off
set_instance_parameter inst_cpri VSSOFF $vss__off
set_instance_parameter inst_cpri CALOFF $cal__off
set_instance_parameter inst_cpri MAP_MODE $map_mode
set_instance_parameter inst_cpri N_MAP $N_MAP
set_instance_parameter inst_cpri SYNC_MAP $SYNC_MAP
set_instance_parameter inst_cpri XCVR_FREQ $XCVR_FREQ
set_instance_parameter inst_cpri CODE_BASE $CODE_BASE

# +-------------------------------------------------------------------------------------
# CPRI with linerate  :
# equal to 614.4Mbps require phy_deser_factor to be 8 and phy_pcs_pma_width to be 10
# more than 614.4Mbps require phy_deser_factor to be 32 and phy_pcs_pma_width to be 20
if {$linerate == "614" } {
   set phy_deser_factor 8
   set phy_pcs_pma_width 10
} else {
   set phy_deser_factor 32
   set phy_pcs_pma_width 20
}

if {$autorate == 1} {
   set pll_reconfig 1
} else {
   set pll_reconfig 0
}

# +------------------------------------
# | XCVR_DET_LATENCY instantiation
# | Duplex mode - For CPRI master mode
# | RX/TX  mode - For CPRI slave  mode
if {$linerate == "5"} {
   if {$device == "5"} {
      if {$sync_mode == 0} {
         add_instance                 inst_xcvr altera_xcvr_dl_soft_pcs 13.1
         # set_instance_parameter inst_xcvr device_family $phy_device
         set_instance_parameter inst_xcvr operation_mode Duplex
         set_instance_parameter inst_xcvr lanes 1
         set_instance_parameter inst_xcvr gui_deser_factor 32
         set_instance_parameter inst_xcvr gui_pcs_pma_width 80
         set_instance_parameter inst_xcvr data_rate $phy_linerate
         set_instance_parameter inst_xcvr gui_base_data_rate $phy_linerate
         set_instance_parameter inst_xcvr word_aligner_mode deterministic_latency
         set_instance_parameter inst_xcvr gui_use_8b10b_status 1
         set_instance_parameter inst_xcvr gui_pll_refclk_freq "$XCVR_FREQ MHz"
         set_instance_parameter inst_xcvr gui_tx_bitslip_enable 1
         set_instance_parameter inst_xcvr gui_pll_reconfig_enable_pll_reconfig $pll_reconfig 
         set_instance_parameter inst_xcvr tx_fifo_depth 4 
         set_instance_parameter inst_xcvr rx_fifo_depth $WIDTH_RX_BUF
         set_instance_parameter inst_xcvr data_width_pma_size 7
         set_instance_parameter inst_xcvr ser_words_pma_size 4
         set_instance_parameter inst_xcvr cdr_reconfig $autorate
         # Notes: These interface is not used for AVGT 9.8G (enabled if necessary)
         #set_instance_parameter inst_xcvr run_length_violation_checking 40
         # Needed for rx_syncstatus port from soft PCS
         set_instance_parameter inst_xcvr gui_use_wa_status 1
         set_instance_parameter inst_xcvr gui_use_status 1
         #set_instance_parameter inst_xcvr channel_interface 1
         } else { 
         # RX
         add_instance                 inst_rx_xcvr altera_xcvr_dl_soft_pcs 13.1
         # set_instance_parameter inst_xcvr device_family $phy_device
         set_instance_parameter inst_rx_xcvr operation_mode RX
         set_instance_parameter inst_rx_xcvr lanes 1
         set_instance_parameter inst_rx_xcvr gui_deser_factor 32
         set_instance_parameter inst_rx_xcvr gui_pcs_pma_width 80
         set_instance_parameter inst_rx_xcvr data_rate $phy_linerate
         set_instance_parameter inst_rx_xcvr gui_base_data_rate $phy_linerate
         set_instance_parameter inst_rx_xcvr word_aligner_mode deterministic_latency
         set_instance_parameter inst_rx_xcvr gui_use_wa_status 1
         set_instance_parameter inst_rx_xcvr gui_use_8b10b_status 1
         set_instance_parameter inst_rx_xcvr gui_pll_refclk_freq "$XCVR_FREQ MHz"
         set_instance_parameter inst_rx_xcvr gui_pll_reconfig_enable_pll_reconfig $pll_reconfig 
         set_instance_parameter inst_rx_xcvr rx_fifo_depth $WIDTH_RX_BUF
         set_instance_parameter inst_rx_xcvr data_width_pma_size 7
         set_instance_parameter inst_rx_xcvr ser_words_pma_size 4
         set_instance_parameter inst_rx_xcvr cdr_reconfig $autorate
         # Notes: These interface is not used for AVGT 9.8G (enabled if necessary)
         #set_instance_parameter inst_rx_xcvr run_length_violation_checking 40
         set_instance_parameter inst_rx_xcvr gui_use_status 1
         #set_instance_parameter inst_rx_xcvr gui_tx_bitslip_enable 1
         #set_instance_parameter inst_rx_xcvr channel_interface 1

         #TX
         add_instance                 inst_tx_xcvr altera_xcvr_dl_soft_pcs 13.1
         # set_instance_parameter inst_xcvr device_family $phy_device
         set_instance_parameter inst_tx_xcvr operation_mode TX
         set_instance_parameter inst_tx_xcvr lanes 1
         set_instance_parameter inst_tx_xcvr gui_deser_factor 32
         set_instance_parameter inst_tx_xcvr gui_pcs_pma_width 80
         set_instance_parameter inst_tx_xcvr data_rate $phy_linerate
         set_instance_parameter inst_tx_xcvr gui_base_data_rate $phy_linerate
         set_instance_parameter inst_tx_xcvr word_aligner_mode deterministic_latency
         set_instance_parameter inst_tx_xcvr gui_pll_refclk_freq "$XCVR_FREQ MHz"
         set_instance_parameter inst_tx_xcvr gui_tx_bitslip_enable 1
         set_instance_parameter inst_tx_xcvr gui_pll_reconfig_enable_pll_reconfig $pll_reconfig 
         set_instance_parameter inst_tx_xcvr tx_fifo_depth 4
         set_instance_parameter inst_tx_xcvr data_width_pma_size 7
         set_instance_parameter inst_tx_xcvr ser_words_pma_size 4
         # Notes: These interface is not used for AVGT 9.8G (enabled if necessary)
         #set_instance_parameter inst_tx_xcvr run_length_violation_checking 40
         #set_instance_parameter inst_tx_xcvr gui_use_wa_status 1
         #set_instance_parameter inst_tx_xcvr gui_use_8b10b_status 1
         #set_instance_parameter inst_tx_xcvr gui_use_status 1
         #set_instance_parameter inst_tx_xcvr channel_interface 1
         #set_instance_parameter inst_tx_xcvr rx_fifo_depth $WIDTH_RX_BUF
         } 
   } else {
      if {$sync_mode == 0} {
         inst_duplex_xcvr inst_xcvr altera_xcvr_det_latency $phy_deser_factor $phy_pcs_pma_width $phy_linerate $XCVR_FREQ $pll_reconfig
      } else {
         inst_rx_xcvr inst_rx_xcvr altera_xcvr_det_latency $phy_deser_factor $phy_pcs_pma_width $phy_linerate $XCVR_FREQ $pll_reconfig
         inst_tx_xcvr inst_tx_xcvr altera_xcvr_det_latency $phy_deser_factor $phy_pcs_pma_width $phy_linerate $XCVR_FREQ $pll_reconfig     
      }
   }
} else {
   if {$device > 3} {
      if {$sync_mode == 0} {
         inst_duplex_xcvr inst_xcvr altera_xcvr_det_latency $phy_deser_factor $phy_pcs_pma_width $phy_linerate $XCVR_FREQ $pll_reconfig 
      } else { 
         inst_rx_xcvr inst_rx_xcvr altera_xcvr_det_latency $phy_deser_factor $phy_pcs_pma_width $phy_linerate $XCVR_FREQ $pll_reconfig
         inst_tx_xcvr inst_tx_xcvr altera_xcvr_det_latency $phy_deser_factor $phy_pcs_pma_width $phy_linerate $XCVR_FREQ $pll_reconfig 
      }
   }
}
}

proc my_call_altera_cpri_connection {} {
# Retrive the HDL parameter from the user's input
   set device                 [get_parameter_value DEVICE]
   set sync_mode              [get_parameter_value SYNC_MODE]
   set mac__off               [get_parameter_value MACOFF]
   set hdlc__off              [get_parameter_value HDLCOFF]
   set vss__off               [get_parameter_value VSSOFF] 
   set cal__off               [get_parameter_value CALOFF]   
   set autorate               [get_parameter_value AUTORATE]
   set linerate               [get_parameter_value LINERATE]
   set S_CH_NUMBER_S_TX_value [get_parameter_value S_CH_NUMBER_S_TX]
   set S_CH_NUMBER_S_RX_value [get_parameter_value S_CH_NUMBER_S_RX]
   set S_CH_NUMBER_M          [get_parameter_value S_CH_NUMBER_M]
   set N_MAP                  [get_parameter_value N_MAP]
   set SYNC_MAP               [get_parameter_value SYNC_MAP]

# +----------------------
# | clk_reset_ex_delay
# |
add_interface          clk_ex_delay                 clock         end
set_interface_property clk_ex_delay                 EXPORT_OF     clk_ex_delay.in_clk
set_interface_property clk_ex_delay                 PORT_NAME_MAP {clk_ex_delay in_clk}

add_interface          reset_ex_delay               reset         end
set_interface_property reset_ex_delay               EXPORT_OF     reset_ex_delay.in_reset
set_interface_property reset_ex_delay               PORT_NAME_MAP {reset_ex_delay in_reset}

add_connection         clk_ex_delay.out_clk         reset_ex_delay.clk
add_connection         clk_ex_delay.out_clk         inst_cpri.clk_reset_ex_delay 
add_connection         reset_ex_delay.out_reset     inst_cpri.clk_reset_ex_delay_reset

# +-----------------------------------
# | cpu_clk_reset
# |
add_interface          cpu_clk                      clock           end
set_interface_property cpu_clk                      EXPORT_OF       cpu_clk.in_clk
set_interface_property cpu_clk                      PORT_NAME_MAP   {cpu_clk in_clk}

add_interface          cpu_reset                    reset end
set_interface_property cpu_reset                    EXPORT_OF       cpu_reset.in_reset
set_interface_property cpu_reset                    PORT_NAME_MAP   {cpu_reset in_reset}

add_connection         cpu_clk.out_clk              cpu_reset.clk
add_connection         cpu_clk.out_clk              inst_cpri.cpu_clock_reset 
add_connection         cpu_reset.out_reset          inst_cpri.cpu_clock_reset_reset

# +-----------------------------------
# | cpu_interface
# |
add_interface          cpu                          avalon           end
set_interface_property cpu                          EXPORT_OF        inst_cpri.cpu_interface 

# +-----------------------------------
# | extended_rx_status
# |
add_interface          extended_rx_status           avalon_streaming start
set_interface_property extended_rx_status           EXPORT_OF        inst_cpri.rx_extended_status_data

# +-----------------------------------
# | cpri_clkout
# | 
add_interface          cpri_clkout                  clock            start
set_interface_property cpri_clkout                  EXPORT_OF        inst_cpri.cpri_clkout
set_interface_property cpri_clkout                  PORT_NAME_MAP    {cpri_clkout cpri_clkout}

# +-----------------------------------
# | Interrupts
# | 
#set interrupts {irq_cpri irq_eth_rx irq_eth_tx irq_hdlc_rx irq_hdlc_tx }
add_interface          cpu_irq                      conduit          start
set_interface_property cpu_irq	                    EXPORT_OF        inst_cpri.cpu_interrupt
set_interface_property cpu_irq                      PORT_NAME_MAP    {cpu_irq cpu_irq}

# +-----------------------------------
# | cpu_irq_vector
# | 
add_interface          cpu_irq_vector               avalon_streaming start
set_interface_property cpu_irq_vector               EXPORT_OF        inst_cpri.cpu_irq_vector  
set_interface_property cpu_irq_vector               PORT_NAME_MAP    {cpu_irq_vector cpu_irq_vector}

# +-----------------------------------
# rx_aux_status
# | 
add_interface          aux_rx_status_data           avalon_streaming start
set_interface_property aux_rx_status_data           EXPORT_OF        inst_cpri.rx_aux_status  
set_interface_property aux_rx_status_data           PORT_NAME_MAP    {aux_rx_status_data aux_rx_status_data}

# +-----------------------------------
# | tx_aux_status
# | 
add_interface          aux_tx_status_data           avalon_streaming start
set_interface_property aux_tx_status_data           EXPORT_OF        inst_cpri.tx_aux_status  
set_interface_property aux_tx_status_data           PORT_NAME_MAP    {aux_tx_status_data aux_tx_status_data}

# +-----------------------------------
# | tx_mask_data
# | 
add_interface          aux_tx_mask_data             avalon_streaming end
set_interface_property aux_tx_mask_data             EXPORT_OF        inst_cpri.tx_aux  
set_interface_property aux_tx_mask_data             PORT_NAME_MAP    {aux_tx_mask_data aux_tx_mask_data}

# +-----------------------------------
# gxb_refclk 
# | 

add_interface          gxb_refclk                   conduit          end
set_interface_property gxb_refclk                   EXPORT_OF        inst_cpri.gxb_refclk
set_interface_property gxb_refclk                   PORT_NAME_MAP    {gxb_refclk gxb_refclk}

# +-----------------------------------
# | gxb_pll_inclk 
# | 
add_interface          gxb_pll_inclk                conduit          end
set_interface_property gxb_pll_inclk                EXPORT_OF        inst_cpri.gxb_pll_inclk
set_interface_property gxb_pll_inclk                PORT_NAME_MAP    {gxb_pll_inclk gxb_pll_inclk}

# +-----------------------------------
# | pll_locked
# | 
add_interface          gxb_pll_locked               conduit          end
set_interface_property gxb_pll_locked               EXPORT_OF        inst_cpri.gxb_pll_locked
set_interface_property gxb_pll_locked               PORT_NAME_MAP    {gxb_pll_locked gxb_pll_locked}

# +-----------------------------------
# |rx_pll_locked
# | 
add_interface          gxb_rx_pll_locked            conduit          end
set_interface_property gxb_rx_pll_locked            EXPORT_OF        inst_cpri.gxb_rx_pll_locked 
set_interface_property gxb_rx_pll_locked            PORT_NAME_MAP    {gxb_rx_pll_locked gxb_rx_pll_locked}

# +-----------------------------------
# | rx_freqlocked
# | 
add_interface gxb_rx_freqlocked                     conduit          start
set_interface_property gxb_rx_freqlocked            EXPORT_OF        inst_cpri.gxb_rx_freqlocked
set_interface_property gxb_rx_freqlocked            PORT_NAME_MAP    {gxb_rx_freqlocked gxb_rx_freqlocked}

# +-----------------------------------
# | GXB connection point rx_errdetect
# | 
add_interface          gxb_rx_errdetect             conduit          start
set_interface_property gxb_rx_errdetect             EXPORT_OF        inst_cpri.gxb_rx_errdetect
set_interface_property gxb_rx_errdetect             PORT_NAME_MAP    {gxb_rx_errdetect gxb_rx_errdetect}

# +-----------------------------------
# | GXB connection point rx_disperr 
# | 
add_interface          gxb_rx_disperr               conduit          start
set_interface_property gxb_rx_disperr               EXPORT_OF        inst_cpri.gxb_rx_disperr
set_interface_property gxb_rx_disperr               PORT_NAME_MAP    {gxb_rx_disperr gxb_rx_disperr}

# +-----------------------------------
# | GXB connection point gxb_los 
# | 
add_interface          gxb_los                      conduit          end
set_interface_property gxb_los                      EXPORT_OF        inst_cpri.gxb_los
set_interface_property gxb_los                      PORT_NAME_MAP    {gxb_los gxb_los}

# +-----------------------------------
# | GXB connection point gxb_txdataout 
# |
add_interface          gxb_txdataout                conduit          start
set_interface_property gxb_txdataout                EXPORT_OF        inst_cpri.gxb_txdataout
set_interface_property gxb_txdataout                PORT_NAME_MAP    {gxb_txdataout gxb_txdataout}

# +-----------------------------------
# | GXB connection point gxb_rxdatain
# | 
add_interface          gxb_rxdatain                 conduit          end 
set_interface_property gxb_rxdatain                 EXPORT_OF        inst_cpri.gxb_rxdatain
set_interface_property gxb_rxdatain                 PORT_NAME_MAP    {gxb_rxdatain gxb_rxdatain}

# +-----------------------------------
# |GXB connection point reconfig_clk
# | 
add_interface          reconfig_clk                 conduit          end 
set_interface_property reconfig_clk                 EXPORT_OF        inst_cpri.reconfig_clk
set_interface_property reconfig_clk                 PORT_NAME_MAP    {reconfig_clk reconfig_clk}


# +-----------------------------------
# | connection point pll_clkout
# | 
add_interface          pll_clkout                   conduit          start
set_interface_property pll_clkout                   EXPORT_OF        inst_cpri.pll_clkout
set_interface_property pll_clkout                   PORT_NAME_MAP    {pll_clkout pll_clkout}

# +-----------------------------------
# | connection point reset
# | 
add_interface          reset                        conduit          end
set_interface_property reset                        EXPORT_OF        inst_cpri.reset
set_interface_property reset                        PORT_NAME_MAP    {reset reset}

# +-----------------------------------
# | connection point reset_done
# | 
add_interface          reset_done                   conduit          start
set_interface_property reset_done                   EXPORT_OF        inst_cpri.reset_done
set_interface_property reset_done                   PORT_NAME_MAP    {reset_done reset_done}

# +-----------------------------------
# | connection point config_reset
# | 
add_interface          config_reset                 conduit          end
set_interface_property config_reset                 EXPORT_OF        inst_cpri.config_reset
set_interface_property config_reset                 PORT_NAME_MAP    {config_reset config_reset}

# | connection point hw_reset_assert
# | 
add_interface          hw_reset_assert              conduit          end
set_interface_property hw_reset_assert              EXPORT_OF        inst_cpri.hw_reset_assert
set_interface_property hw_reset_assert              PORT_NAME_MAP    {hw_reset_assert hw_reset_assert}

# +-----------------------------------
# | connection point hw_reset_req
# | 
add_interface          hw_reset_req                 conduit          start
set_interface_property hw_reset_req                 EXPORT_OF        inst_cpri.hw_reset_req
set_interface_property hw_reset_req                 PORT_NAME_MAP    {hw_reset_req	hw_reset_req}

# +-----------------------------------
# | connection point datarate_en
# | 
add_interface          datarate_en                  conduit          start
set_interface_property datarate_en                  EXPORT_OF        inst_cpri.datarate_en
set_interface_property datarate_en                  PORT_NAME_MAP    {datarate_en datarate_en}

# +-----------------------------------
# | connection point datarate_set
# | 
add_interface          datarate_set                 conduit          start
set_interface_property datarate_set                 EXPORT_OF        inst_cpri.datarate_set
set_interface_property datarate_set                 PORT_NAME_MAP    {datarate_set datarate_set}

for {set i 0} {$i < 24} {incr i} {
   if {$i < $N_MAP } {
      # TX & RX
      add_interface          map${i}_tx        avalon_streaming end
      add_interface          map${i}_tx_status avalon_streaming start
      add_interface          map${i}_rx        avalon_streaming start
      add_interface          map${i}_rx_status avalon_streaming start
      
      set_interface_property map${i}_rx        EXPORT_OF inst_cpri.map${i}_rx 
      set_interface_property map${i}_rx_status EXPORT_OF inst_cpri.map${i}_rx_status
      set_interface_property map${i}_tx        EXPORT_OF inst_cpri.map${i}_tx
      set_interface_property map${i}_tx_status EXPORT_OF inst_cpri.map${i}_tx_status
      
      if { $SYNC_MAP  == "1" } {
         add_interface          map${i}_rx_start  avalon_streaming start
         set_interface_property map${i}_rx_start  EXPORT_OF inst_cpri.map${i}_rx_start
         set_interface_property map${i}_rx_start  PORT_NAME_MAP "map${i}_rx_start map${i}_rx_start"
      } else {
         add_interface          map${i}_tx_clk    clock end
         add_interface          map${i}_tx_reset  reset end
         add_interface          map${i}_tx_resync avalon_streaming end
         
         add_interface          map${i}_rx_clk    clock end
         add_interface          map${i}_rx_reset  reset end
         add_interface          map${i}_rx_resync avalon_streaming end 
         
         set_interface_property map${i}_tx_clk    EXPORT_OF map${i}_tx_clk.in_clk
         set_interface_property map${i}_tx_clk    PORT_NAME_MAP "map${i}_tx_clk in_clk"
         set_interface_property map${i}_tx_reset  EXPORT_OF map${i}_tx_reset.in_reset
         set_interface_property map${i}_tx_reset  PORT_NAME_MAP "map${i}_tx_reset in_reset"
         set_interface_property map${i}_tx_resync EXPORT_OF inst_cpri.map${i}_tx_resync
         set_interface_property map${i}_tx_resync PORT_NAME_MAP "map${i}_tx_resync map${i}_tx_resync"
         
         add_connection         map${i}_tx_clk.out_clk map${i}_tx_reset.clk
         add_connection         map${i}_tx_clk.out_clk inst_cpri.map${i}_tx_clk
         add_connection         map${i}_tx_reset.out_reset inst_cpri.map${i}_tx_clk_reset     
        
         set_interface_property map${i}_rx_clk    EXPORT_OF map${i}_rx_clk.in_clk
         set_interface_property map${i}_rx_clk    PORT_NAME_MAP "map${i}_rx_clk in_clk"
         set_interface_property map${i}_rx_reset  EXPORT_OF map${i}_rx_reset.in_reset
         set_interface_property map${i}_rx_reset  PORT_NAME_MAP "map${i}_rx_reset in_reset"
         set_interface_property map${i}_rx_resync EXPORT_OF inst_cpri.map${i}_rx_resync
         set_interface_property map${i}_rx_resync PORT_NAME_MAP "map${i}_rx_resync map${i}_rx_resync"

         add_connection         map${i}_rx_clk.out_clk map${i}_rx_reset.clk
         add_connection         map${i}_rx_clk.out_clk inst_cpri.map${i}_rx_clk
         add_connection         map${i}_rx_reset.out_reset inst_cpri.map${i}_rx_clk_reset
      }
   }
}

# +-----------------------------------
# | MII Interface
# | 

if {$mac__off == "false"} {
   add_interface          cpri_mii_txclk      conduit       start
   add_interface          cpri_mii_txrd       conduit       start
   add_interface          cpri_mii_rxclk      conduit       start
   add_interface          cpri_mii_rxwr       conduit       start
   add_interface          cpri_mii_rxdv       conduit       start
   add_interface          cpri_mii_rxer       conduit       start
   add_interface          cpri_mii_rxd        conduit       start
   add_interface          cpri_mii_txen       conduit       end
   add_interface          cpri_mii_txer       conduit       end
   add_interface          cpri_mii_txd        conduit       end

   set_interface_property cpri_mii_txclk      EXPORT_OF     inst_cpri.cpri_mii_txclk
   set_interface_property cpri_mii_txrd       EXPORT_OF     inst_cpri.cpri_mii_txrd
   set_interface_property cpri_mii_rxclk      EXPORT_OF     inst_cpri.cpri_mii_rxclk
   set_interface_property cpri_mii_rxwr       EXPORT_OF     inst_cpri.cpri_mii_rxwr
   set_interface_property cpri_mii_rxdv       EXPORT_OF     inst_cpri.cpri_mii_rxdv
   set_interface_property cpri_mii_rxer       EXPORT_OF     inst_cpri.cpri_mii_rxer
   set_interface_property cpri_mii_rxd        EXPORT_OF     inst_cpri.cpri_mii_rxd
   set_interface_property cpri_mii_txen       EXPORT_OF     inst_cpri.cpri_mii_txen
   set_interface_property cpri_mii_txer       EXPORT_OF     inst_cpri.cpri_mii_txer
   set_interface_property cpri_mii_txd        EXPORT_OF     inst_cpri.cpri_mii_txd

   set_interface_property cpri_mii_txclk      PORT_NAME_MAP {cpri_mii_txclk cpri_mii_txclk}
   set_interface_property cpri_mii_txrd       PORT_NAME_MAP {cpri_mii_txrd cpri_mii_txrd}
   set_interface_property cpri_mii_rxclk      PORT_NAME_MAP {cpri_mii_rxclk cpri_mii_rxclk}  
   set_interface_property cpri_mii_rxwr       PORT_NAME_MAP {cpri_mii_rxwr cpri_mii_rxwr} 
   set_interface_property cpri_mii_rxdv       PORT_NAME_MAP {cpri_mii_rxdv cpri_mii_rxdv}
   set_interface_property cpri_mii_rxer       PORT_NAME_MAP {cpri_mii_rxer cpri_mii_rxer} 
   set_interface_property cpri_mii_rxd        PORT_NAME_MAP {cpri_mii_rxd cpri_mii_rxd} 
   set_interface_property cpri_mii_txen       PORT_NAME_MAP {cpri_mii_txen cpri_mii_txen} 
   set_interface_property cpri_mii_txer       PORT_NAME_MAP {cpri_mii_txer cpri_mii_txer}
   set_interface_property cpri_mii_txd        PORT_NAME_MAP {cpri_mii_txd cpri_mii_txd}
}

# +-----------------------------------
# | Reconfig Interface
# | 
if {$device < 4} {
   if { $sync_mode == "0" } {
      # Master - REC
      add_interface          reconfig_togxb_m     conduit       end
      add_interface          reconfig_fromgxb_m   conduit       start
      
      set_interface_property reconfig_togxb_m     EXPORT_OF     inst_cpri.reconfig_togxb_m
      set_interface_property reconfig_fromgxb_m   EXPORT_OF     inst_cpri.reconfig_fromgxb_m

      set_interface_property reconfig_togxb_m     PORT_NAME_MAP {reconfig_togxb_m reconfig_togxb_m}
      set_interface_property reconfig_fromgxb_m   PORT_NAME_MAP {reconfig_fromgxb_m reconfig_fromgxb_m}
   } else {
      # Slave - RE 
      add_interface          reconfig_togxb_s_tx   conduit       end 
      add_interface          reconfig_togxb_s_rx   conduit       end 
      add_interface          reconfig_fromgxb_s_rx conduit       start
      add_interface          reconfig_fromgxb_s_tx conduit       start 

      set_interface_property reconfig_togxb_s_tx   EXPORT_OF     inst_cpri.reconfig_togxb_s_tx
      set_interface_property reconfig_togxb_s_rx   EXPORT_OF     inst_cpri.reconfig_togxb_s_rx
      set_interface_property reconfig_fromgxb_s_rx EXPORT_OF     inst_cpri.reconfig_fromgxb_s_rx 
      set_interface_property reconfig_fromgxb_s_tx EXPORT_OF     inst_cpri.reconfig_fromgxb_s_tx

      set_interface_property reconfig_togxb_s_tx   PORT_NAME_MAP {reconfig_togxb_s_tx reconfig_togxb_s_tx}
      set_interface_property reconfig_togxb_s_rx   PORT_NAME_MAP {reconfig_togxb_s_rx reconfig_togxb_s_rx}
      set_interface_property reconfig_fromgxb_s_rx PORT_NAME_MAP {reconfig_fromgxb_s_rx reconfig_fromgxb_s_rx}
      set_interface_property reconfig_fromgxb_s_tx PORT_NAME_MAP {reconfig_fromgxb_s_tx reconfig_fromgxb_s_tx}
   } 
}

if {$device == 3 && $autorate== 1} {
   add_interface          pll_areset             conduit       end  
   add_interface          pll_configupdate       conduit       end 
   add_interface          pll_scanclk            conduit       end
   add_interface          pll_scanclkena         conduit       end  
   add_interface          pll_scandata           conduit       end 
   add_interface          pll_reconfig_done      conduit       start 
   add_interface          pll_scandataout        conduit       start 
      
   set_interface_property pll_areset             EXPORT_OF     inst_cpri.pll_areset 
   set_interface_property pll_configupdate       EXPORT_OF     inst_cpri.pll_configupdate 
   set_interface_property pll_scanclk            EXPORT_OF     inst_cpri.pll_scanclk 
   set_interface_property pll_scanclkena         EXPORT_OF     inst_cpri.pll_scanclkena 
   set_interface_property pll_scandata           EXPORT_OF     inst_cpri.pll_scandata 
   set_interface_property pll_reconfig_done      EXPORT_OF     inst_cpri.pll_reconfig_done
   set_interface_property pll_scandataout        EXPORT_OF     inst_cpri.pll_scandataout

   set_interface_property pll_areset             PORT_NAME_MAP {pll_areset pll_areset}
   set_interface_property pll_configupdate       PORT_NAME_MAP {pll_configupdate pll_configupdate}
   set_interface_property pll_scanclk            PORT_NAME_MAP {pll_scanclk pll_scanclk} 
   set_interface_property pll_scanclkena         PORT_NAME_MAP {pll_scanclkena pll_scanclkena} 
   set_interface_property pll_scandata           PORT_NAME_MAP {pll_scandata pll_scandata}
   set_interface_property pll_reconfig_done      PORT_NAME_MAP {pll_reconfig_done pll_reconfig_done}
   set_interface_property pll_scandataout        PORT_NAME_MAP {pll_scandataout pll_scandataout}		  
} 

if {$linerate ==  "5"} {
   if {$device == "5"} {
# +-----------------------------------    
# | usr_clk and usr_pma_clk (AV GT)
# |

      add_interface      usr_clk                      clock end
      add_interface      usr_pma_clk                  clock end

      set_interface_property usr_clk            EXPORT_OF inst_cpri.usr_clk
      set_interface_property usr_pma_clk        EXPORT_OF inst_cpri.usr_pma_clk

      set_interface_property usr_clk             PORT_NAME_MAP {usr_clk usr_clk}
      set_interface_property usr_pma_clk         PORT_NAME_MAP {usr_pma_clk usr_pma_clk}
      
      if {$sync_mode == 0} {
         add_interface          reconfig_from_xcvr  conduit       end
         add_interface          reconfig_to_xcvr    conduit       start
      
         set_interface_property reconfig_from_xcvr  EXPORT_OF     inst_xcvr.reconfig_from_xcvr 
         set_interface_property reconfig_to_xcvr    EXPORT_OF     inst_xcvr.reconfig_to_xcvr
         set_interface_property reconfig_from_xcvr  PORT_NAME_MAP {reconfig_from_xcvr reconfig_from_xcvr}
         set_interface_property reconfig_to_xcvr    PORT_NAME_MAP {reconfig_to_xcvr reconfig_to_xcvr} 

         add_connection inst_cpri.xcvr_usr_clk/inst_xcvr.usr_clk 
         add_connection inst_cpri.xcvr_usr_pma_clk/inst_xcvr.usr_pma_clk  

         add_connection inst_cpri.xcvr_mgmt_clk/inst_xcvr.phy_mgmt_clk
         add_connection inst_cpri.xcvr_mgmt_clk_reset/inst_xcvr.phy_mgmt_clk_reset
         add_connection inst_cpri.xcvr_mgmt_interface/inst_xcvr.phy_mgmt
         add_connection inst_cpri.xcvr_pll_ref_clk/inst_xcvr.pll_ref_clk
         add_connection inst_cpri.xcvr_rx_serial_data/inst_xcvr.rx_serial_data
         add_connection inst_cpri.xcvr_tx_parallel_data/inst_xcvr.tx_parallel_data 
         add_connection inst_cpri.xcvr_tx_bitslipboundaryselect/inst_xcvr.tx_bitslipboundaryselect
         add_connection inst_cpri.xcvr_rx_is_lockedtodata/inst_xcvr.rx_is_lockedtodata
         add_connection inst_cpri.xcvr_rx_is_lockedtoref/inst_xcvr.rx_is_lockedtoref  
         add_connection inst_cpri.xcvr_cdr_ref_clk/inst_xcvr.cdr_ref_clk
         add_connection inst_cpri.xcvr_fifo_calc_clk/inst_xcvr.fifo_calc_clk
         add_connection inst_cpri.xcvr_tx_fifocalreset/inst_xcvr.tx_fifocalreset
         add_connection inst_cpri.xcvr_rx_fifocalreset/inst_xcvr.rx_fifocalreset
         add_connection inst_cpri.xcvr_tx_datak/inst_xcvr.tx_datak
         add_connection inst_cpri.xcvr_tx_fifo_sample_size/inst_xcvr.tx_fifo_sample_size
         add_connection inst_cpri.xcvr_rx_fifo_sample_size/inst_xcvr.rx_fifo_sample_size
         add_connection inst_cpri.xcvr_tx_fiforeset/inst_xcvr.tx_fiforeset
         add_connection inst_cpri.xcvr_rx_fiforeset/inst_xcvr.rx_fiforeset
         add_connection inst_cpri.xcvr_tx_data_width_pma/inst_xcvr.data_width_pma
         add_connection inst_xcvr.pll_locked/inst_cpri.xcvr_pll_locked
         add_connection inst_xcvr.tx_ready/inst_cpri.xcvr_tx_ready
         add_connection inst_xcvr.tx_serial_data/inst_cpri.xcvr_tx_serial_data
         add_connection inst_xcvr.rx_ready/inst_cpri.xcvr_rx_ready
         add_connection inst_xcvr.rx_parallel_data/inst_cpri.xcvr_rx_parallel_data
         add_connection inst_xcvr.rx_bitslipboundaryselectout/inst_cpri.xcvr_rx_bitslipboundaryselectout 
         add_connection inst_xcvr.rx_clkout/inst_cpri.xcvr_rx_clkout           
         add_connection inst_xcvr.rx_datak/inst_cpri.xcvr_rx_datak            
         add_connection inst_xcvr.rx_disperr/inst_cpri.xcvr_rx_disperr          
         add_connection inst_xcvr.rx_errdetect/inst_cpri.xcvr_rx_errdetect        
         add_connection inst_xcvr.rx_syncstatus/inst_cpri.xcvr_rx_syncstatus
         add_connection inst_xcvr.tx_phase_measure_acc/inst_cpri.xcvr_tx_phase_measure_acc
         add_connection inst_xcvr.rx_phase_measure_acc/inst_cpri.xcvr_rx_phase_measure_acc
         add_connection inst_xcvr.tx_fifo_latency/inst_cpri.xcvr_tx_fifo_latency
         add_connection inst_xcvr.rx_fifo_latency/inst_cpri.xcvr_rx_fifo_latency 
         add_connection inst_xcvr.tx_ph_acc_valid/inst_cpri.xcvr_tx_ph_acc_valid     
         add_connection inst_xcvr.rx_ph_acc_valid/inst_cpri.xcvr_rx_ph_acc_valid     
         add_connection inst_xcvr.tx_wr_full/inst_cpri.xcvr_tx_wr_full          
         add_connection inst_xcvr.rx_wr_full/inst_cpri.xcvr_rx_wr_full          
         add_connection inst_xcvr.tx_rd_empty/inst_cpri.xcvr_tx_rd_empty         
         add_connection inst_xcvr.rx_rd_empty/inst_cpri.xcvr_rx_rd_empty       
      } else {
         add_interface          reconfig_from_xcvr_s_tx conduit       end
         add_interface          reconfig_to_xcvr_s_tx   conduit       start
         
         set_interface_property reconfig_from_xcvr_s_tx EXPORT_OF     inst_tx_xcvr.reconfig_from_xcvr 
         set_interface_property reconfig_to_xcvr_s_tx   EXPORT_OF     inst_tx_xcvr.reconfig_to_xcvr    
         set_interface_property reconfig_from_xcvr_s_tx PORT_NAME_MAP {reconfig_from_xcvr_s_tx reconfig_from_xcvr}
         set_interface_property reconfig_to_xcvr_s_tx   PORT_NAME_MAP {reconfig_to_xcvr_s_tx reconfig_to_xcvr} 
	  
         add_interface          reconfig_from_xcvr_s_rx conduit        end
         add_interface          reconfig_to_xcvr_s_rx   conduit        start

         set_interface_property reconfig_from_xcvr_s_rx EXPORT_OF      inst_rx_xcvr.reconfig_from_xcvr 
         set_interface_property reconfig_to_xcvr_s_rx   EXPORT_OF      inst_rx_xcvr.reconfig_to_xcvr 
         set_interface_property reconfig_from_xcvr_s_rx PORT_NAME_MAP  {reconfig_from_xcvr_s_rx reconfig_from_xcvr}
         set_interface_property reconfig_to_xcvr_s_rx   PORT_NAME_MAP  {reconfig_to_xcvr_s_rx reconfig_to_xcvr}

         # RX clock
         add_connection inst_cpri.xcvr_mgmt_clk/inst_rx_xcvr.phy_mgmt_clk
         add_connection inst_cpri.xcvr_mgmt_clk_reset/inst_rx_xcvr.phy_mgmt_clk_reset
         add_connection inst_cpri.xcvr_mgmt_interface/inst_rx_xcvr.phy_mgmt
         set_connection_parameter_value inst_cpri.xcvr_mgmt_interface/inst_rx_xcvr.phy_mgmt baseAddress "0x0000"
         
         #RX connection Out put to input
         # Notes:
         # 1. error port is not used
         # 2. running disperr is not used
         add_connection inst_cpri.xcvr_pll_ref_clk/inst_rx_xcvr.pll_ref_clk
         add_connection inst_cpri.xcvr_rx_serial_data/inst_rx_xcvr.rx_serial_data 
         add_connection inst_cpri.xcvr_cdr_ref_clk/inst_rx_xcvr.cdr_ref_clk
         add_connection inst_cpri.xcvr_usr_pma_clk/inst_rx_xcvr.usr_pma_clk 
         add_connection inst_cpri.xcvr_usr_clk/inst_rx_xcvr.usr_clk 
         add_connection inst_cpri.xcvr_fifo_calc_clk/inst_rx_xcvr.fifo_calc_clk
         add_connection inst_cpri.xcvr_rx_fiforeset/inst_rx_xcvr.rx_fiforeset
         add_connection inst_cpri.xcvr_rx_fifocalreset/inst_rx_xcvr.rx_fifocalreset
         add_connection inst_cpri.xcvr_rx_fifo_sample_size/inst_rx_xcvr.rx_fifo_sample_size
         add_connection inst_cpri.xcvr_rx_data_width_pma/inst_rx_xcvr.data_width_pma
         add_connection inst_cpri.xcvr_rx_is_lockedtodata/inst_rx_xcvr.rx_is_lockedtodata
         add_connection inst_cpri.xcvr_rx_is_lockedtoref/inst_rx_xcvr.rx_is_lockedtoref
         add_connection inst_rx_xcvr.rx_ready/inst_cpri.xcvr_rx_ready
         add_connection inst_rx_xcvr.rx_disperr/inst_cpri.xcvr_rx_disperr 
         add_connection inst_rx_xcvr.rx_errdetect/inst_cpri.xcvr_rx_errdetect   
         add_connection inst_rx_xcvr.rx_bitslipboundaryselectout/inst_cpri.xcvr_rx_bitslipboundaryselectout  
         add_connection inst_rx_xcvr.rx_syncstatus/inst_cpri.xcvr_rx_syncstatus
         add_connection inst_rx_xcvr.rx_ph_acc_valid/inst_cpri.xcvr_rx_ph_acc_valid 
         add_connection inst_rx_xcvr.rx_wr_full/inst_cpri.xcvr_rx_wr_full
         add_connection inst_rx_xcvr.rx_rd_empty/inst_cpri.xcvr_rx_rd_empty
         add_connection inst_rx_xcvr.rx_phase_measure_acc/inst_cpri.xcvr_rx_phase_measure_acc 
         add_connection inst_rx_xcvr.rx_fifo_latency/inst_cpri.xcvr_rx_fifo_latency 
         add_connection inst_rx_xcvr.rx_clkout/inst_cpri.xcvr_rx_clkout
         add_connection inst_rx_xcvr.rx_parallel_data/inst_cpri.xcvr_rx_parallel_data 
         add_connection inst_rx_xcvr.rx_datak/inst_cpri.xcvr_rx_datak 

         #TX clock
         add_connection inst_cpri.xcvr_mgmt_clk/inst_tx_xcvr.phy_mgmt_clk
         add_connection inst_cpri.xcvr_mgmt_clk_reset/inst_tx_xcvr.phy_mgmt_clk_reset
         add_connection inst_cpri.xcvr_mgmt_interface/inst_tx_xcvr.phy_mgmt
         set_connection_parameter_value inst_cpri.xcvr_mgmt_interface/inst_tx_xcvr.phy_mgmt baseAddress "0x0800"   
         
         # TX connection
         # Notes : 
         # 1. error port is not used
         # 2. txclkout is not used   
         add_connection inst_cpri.xcvr_pll_ref_clk/inst_tx_xcvr.pll_ref_clk  
         add_connection inst_cpri.xcvr_tx_bitslipboundaryselect/inst_tx_xcvr.tx_bitslipboundaryselect
         add_connection inst_cpri.xcvr_cdr_ref_clk/inst_tx_xcvr.cdr_ref_clk
         add_connection inst_cpri.xcvr_usr_pma_clk/inst_tx_xcvr.usr_pma_clk 
         add_connection inst_cpri.xcvr_usr_clk/inst_tx_xcvr.usr_clk
         add_connection inst_cpri.xcvr_fifo_calc_clk/inst_tx_xcvr.fifo_calc_clk 
         add_connection inst_cpri.xcvr_tx_fiforeset/inst_tx_xcvr.tx_fiforeset  
         add_connection inst_cpri.xcvr_tx_fifocalreset/inst_tx_xcvr.tx_fifocalreset   
         add_connection inst_cpri.xcvr_tx_fifo_sample_size/inst_tx_xcvr.tx_fifo_sample_size 
         add_connection inst_cpri.xcvr_tx_data_width_pma/inst_tx_xcvr.data_width_pma
         add_connection inst_cpri.xcvr_tx_parallel_data/inst_tx_xcvr.tx_parallel_data
         add_connection inst_cpri.xcvr_tx_datak/inst_tx_xcvr.tx_datak 
         add_connection inst_tx_xcvr.tx_ready/inst_cpri.xcvr_tx_ready
         add_connection inst_tx_xcvr.tx_serial_data/inst_cpri.xcvr_tx_serial_data
         add_connection inst_tx_xcvr.pll_locked/inst_cpri.xcvr_pll_locked
         add_connection inst_tx_xcvr.tx_ph_acc_valid/inst_cpri.xcvr_tx_ph_acc_valid 
         add_connection inst_tx_xcvr.tx_wr_full/inst_cpri.xcvr_tx_wr_full
         add_connection inst_tx_xcvr.tx_rd_empty/inst_cpri.xcvr_tx_rd_empty
         add_connection inst_tx_xcvr.tx_phase_measure_acc/inst_cpri.xcvr_tx_phase_measure_acc 
         add_connection inst_tx_xcvr.tx_fifo_latency/inst_cpri.xcvr_tx_fifo_latency
                            
     }
   } else {
      # SV 9.8G
      if {$sync_mode == 0} { 
         add_interface          reconfig_from_xcvr  conduit       end
         add_interface          reconfig_to_xcvr    conduit       start
      
         set_interface_property reconfig_from_xcvr  EXPORT_OF     inst_xcvr.reconfig_from_xcvr 
         set_interface_property reconfig_to_xcvr    EXPORT_OF     inst_xcvr.reconfig_to_xcvr
         set_interface_property reconfig_from_xcvr  PORT_NAME_MAP {reconfig_from_xcvr reconfig_from_xcvr}
         set_interface_property reconfig_to_xcvr    PORT_NAME_MAP {reconfig_to_xcvr reconfig_to_xcvr} 

         add_connection inst_cpri.phy_mgmt_clk/inst_xcvr.phy_mgmt_clk
         add_connection inst_cpri.phy_mgmt_clk_reset/inst_xcvr.phy_mgmt_clk_reset
         add_connection inst_cpri.phy_mgmt_interface/inst_xcvr.phy_mgmt
         add_connection inst_cpri.phy_pll_ref_clk/inst_xcvr.pll_ref_clk
         add_connection inst_cpri.phy_rx_serial_data/inst_xcvr.rx_serial_data
         add_connection inst_cpri.phy_tx_parallel_data/inst_xcvr.tx_parallel_data 
         add_connection inst_cpri.phy_rx_is_lockedtodata/inst_xcvr.rx_is_lockedtodata
         add_connection inst_cpri.phy_rx_is_lockedtoref/inst_xcvr.rx_is_lockedtoref
         add_connection inst_cpri.phy_tx_bitslipboundaryselect/inst_xcvr.tx_bitslipboundaryselect

         add_connection inst_xcvr.pll_locked/inst_cpri.phy_pll_locked
         add_connection inst_xcvr.tx_ready/inst_cpri.phy_tx_ready
         add_connection inst_xcvr.tx_serial_data/inst_cpri.phy_tx_serial_data
         add_connection inst_xcvr.tx_clkout/inst_cpri.phy_tx_clkout
         add_connection inst_xcvr.rx_ready/inst_cpri.phy_rx_ready
         add_connection inst_xcvr.rx_clkout/inst_cpri.phy_rx_clkout
         add_connection inst_xcvr.rx_parallel_data/inst_cpri.phy_rx_parallel_data
         add_connection inst_xcvr.rx_bitslipboundaryselectout/inst_cpri.phy_rx_bitslipboundaryselectout
      } else {          
         add_interface          reconfig_from_xcvr_s_tx conduit       end
         add_interface          reconfig_to_xcvr_s_tx   conduit       start
         
         set_interface_property reconfig_from_xcvr_s_tx EXPORT_OF     inst_tx_xcvr.reconfig_from_xcvr 
         set_interface_property reconfig_to_xcvr_s_tx   EXPORT_OF     inst_tx_xcvr.reconfig_to_xcvr    
         set_interface_property reconfig_from_xcvr_s_tx PORT_NAME_MAP {reconfig_from_xcvr_s_tx reconfig_from_xcvr}
         set_interface_property reconfig_to_xcvr_s_tx   PORT_NAME_MAP {reconfig_to_xcvr_s_tx reconfig_to_xcvr} 
	  
         add_interface          reconfig_from_xcvr_s_rx conduit        end
         add_interface          reconfig_to_xcvr_s_rx   conduit        start
         set_interface_property reconfig_from_xcvr_s_rx EXPORT_OF      inst_rx_xcvr.reconfig_from_xcvr 
         set_interface_property reconfig_to_xcvr_s_rx   EXPORT_OF      inst_rx_xcvr.reconfig_to_xcvr 
         set_interface_property reconfig_from_xcvr_s_rx PORT_NAME_MAP  {reconfig_from_xcvr_s_rx reconfig_from_xcvr}
         set_interface_property reconfig_to_xcvr_s_rx   PORT_NAME_MAP  {reconfig_to_xcvr_s_rx reconfig_to_xcvr}

         # RX clock
         add_connection inst_cpri.phy_mgmt_clk/inst_rx_xcvr.phy_mgmt_clk
         add_connection inst_cpri.phy_mgmt_clk_reset/inst_rx_xcvr.phy_mgmt_clk_reset
         add_connection inst_cpri.phy_mgmt_interface/inst_rx_xcvr.phy_mgmt
         set_connection_parameter_value inst_cpri.phy_mgmt_interface/inst_rx_xcvr.phy_mgmt baseAddress "0x0000"
         
         #RX connection
         add_connection inst_rx_xcvr.rx_ready/inst_cpri.phy_rx_ready
         add_connection inst_rx_xcvr.rx_clkout/inst_cpri.phy_rx_clkout
         add_connection inst_rx_xcvr.rx_parallel_data/inst_cpri.phy_rx_parallel_data
         add_connection inst_rx_xcvr.rx_is_lockedtodata/inst_cpri.phy_rx_is_lockedtodata
         add_connection inst_rx_xcvr.rx_is_lockedtoref/inst_cpri.phy_rx_is_lockedtoref
         add_connection inst_cpri.phy_pll_ref_clk/inst_rx_xcvr.pll_ref_clk
         add_connection inst_cpri.phy_rx_serial_data/inst_rx_xcvr.rx_serial_data
         add_connection inst_cpri.phy_rx_bitslipboundaryselectout/inst_rx_xcvr.rx_bitslipboundaryselectout 

         #TX clock
         add_connection inst_cpri.phy_mgmt_clk/inst_tx_xcvr.phy_mgmt_clk
         add_connection inst_cpri.phy_mgmt_clk_reset/inst_tx_xcvr.phy_mgmt_clk_reset
         add_connection inst_cpri.phy_mgmt_interface/inst_tx_xcvr.phy_mgmt
         set_connection_parameter_value inst_cpri.phy_mgmt_interface/inst_tx_xcvr.phy_mgmt baseAddress "0x0800"   
         
         # TX connection
         add_connection inst_tx_xcvr.tx_ready/inst_cpri.phy_tx_ready
         add_connection inst_tx_xcvr.tx_serial_data/inst_cpri.phy_tx_serial_data
         add_connection inst_tx_xcvr.pll_locked/inst_cpri.phy_pll_locked
         add_connection inst_tx_xcvr.tx_clkout/inst_cpri.phy_tx_clkout   
         add_connection inst_cpri.phy_pll_inclk/inst_tx_xcvr.pll_ref_clk      
         add_connection inst_cpri.phy_tx_parallel_data/inst_tx_xcvr.tx_parallel_data
         add_connection inst_cpri.phy_tx_bitslipboundaryselect/inst_tx_xcvr.tx_bitslipboundaryselect
      }
   } 
} else {
#other linerate
if {$device > 3} {
   if {$sync_mode == 0} { 
      add_interface          reconfig_from_xcvr  conduit       end
      add_interface          reconfig_to_xcvr    conduit       start
      set_interface_property reconfig_from_xcvr  EXPORT_OF     inst_xcvr.reconfig_from_xcvr 
      set_interface_property reconfig_to_xcvr    EXPORT_OF     inst_xcvr.reconfig_to_xcvr 
      set_interface_property reconfig_from_xcvr  PORT_NAME_MAP {reconfig_from_xcvr reconfig_from_xcvr}
      set_interface_property reconfig_to_xcvr    PORT_NAME_MAP {reconfig_to_xcvr reconfig_to_xcvr} 

      add_connection inst_cpri.phy_mgmt_clk/inst_xcvr.phy_mgmt_clk
      add_connection inst_cpri.phy_mgmt_clk_reset/inst_xcvr.phy_mgmt_clk_reset
      add_connection inst_cpri.phy_mgmt_interface/inst_xcvr.phy_mgmt
      add_connection inst_cpri.phy_pll_ref_clk/inst_xcvr.pll_ref_clk
      add_connection inst_cpri.phy_rx_serial_data/inst_xcvr.rx_serial_data
      add_connection inst_cpri.phy_tx_parallel_data/inst_xcvr.tx_parallel_data
      add_connection inst_cpri.phy_rx_is_lockedtodata/inst_xcvr.rx_is_lockedtodata
      add_connection inst_cpri.phy_rx_is_lockedtoref/inst_xcvr.rx_is_lockedtoref
      add_connection inst_cpri.phy_tx_bitslipboundaryselect/inst_xcvr.tx_bitslipboundaryselect

      add_connection inst_xcvr.pll_locked/inst_cpri.phy_pll_locked
      add_connection inst_xcvr.tx_ready/inst_cpri.phy_tx_ready
      add_connection inst_xcvr.tx_serial_data/inst_cpri.phy_tx_serial_data
      add_connection inst_xcvr.tx_clkout/inst_cpri.phy_tx_clkout
      add_connection inst_xcvr.rx_ready/inst_cpri.phy_rx_ready
      add_connection inst_xcvr.rx_clkout/inst_cpri.phy_rx_clkout
      add_connection inst_xcvr.rx_parallel_data/inst_cpri.phy_rx_parallel_data
      add_connection inst_xcvr.rx_bitslipboundaryselectout/inst_cpri.phy_rx_bitslipboundaryselectout
   } else {          
      add_interface          reconfig_from_xcvr_s_tx conduit       end
      add_interface          reconfig_to_xcvr_s_tx   conduit       start
      set_interface_property reconfig_from_xcvr_s_tx EXPORT_OF     inst_tx_xcvr.reconfig_from_xcvr 
      set_interface_property reconfig_to_xcvr_s_tx   EXPORT_OF     inst_tx_xcvr.reconfig_to_xcvr    
      set_interface_property reconfig_from_xcvr_s_tx PORT_NAME_MAP {reconfig_from_xcvr_s_tx reconfig_from_xcvr}
      set_interface_property reconfig_to_xcvr_s_tx   PORT_NAME_MAP {reconfig_to_xcvr_s_tx reconfig_to_xcvr} 
	  
      add_interface          reconfig_from_xcvr_s_rx conduit        end
      add_interface          reconfig_to_xcvr_s_rx   conduit        start
      set_interface_property reconfig_from_xcvr_s_rx EXPORT_OF      inst_rx_xcvr.reconfig_from_xcvr 
      set_interface_property reconfig_to_xcvr_s_rx   EXPORT_OF      inst_rx_xcvr.reconfig_to_xcvr 
      set_interface_property reconfig_from_xcvr_s_rx PORT_NAME_MAP  {reconfig_from_xcvr_s_rx reconfig_from_xcvr}
      set_interface_property reconfig_to_xcvr_s_rx   PORT_NAME_MAP  {reconfig_to_xcvr_s_rx reconfig_to_xcvr}

      # RX clock
      add_connection inst_cpri.phy_mgmt_clk/inst_rx_xcvr.phy_mgmt_clk
      add_connection inst_cpri.phy_mgmt_clk_reset/inst_rx_xcvr.phy_mgmt_clk_reset
      add_connection inst_cpri.phy_mgmt_interface/inst_rx_xcvr.phy_mgmt
      set_connection_parameter_value inst_cpri.phy_mgmt_interface/inst_rx_xcvr.phy_mgmt baseAddress "0x0000"
      #RX connection
      add_connection inst_rx_xcvr.rx_ready/inst_cpri.phy_rx_ready
      add_connection inst_rx_xcvr.rx_clkout/inst_cpri.phy_rx_clkout
      add_connection inst_rx_xcvr.rx_parallel_data/inst_cpri.phy_rx_parallel_data
      add_connection inst_rx_xcvr.rx_is_lockedtodata/inst_cpri.phy_rx_is_lockedtodata
      add_connection inst_rx_xcvr.rx_is_lockedtoref/inst_cpri.phy_rx_is_lockedtoref
      add_connection inst_cpri.phy_pll_ref_clk/inst_rx_xcvr.pll_ref_clk
      add_connection inst_cpri.phy_rx_serial_data/inst_rx_xcvr.rx_serial_data
      add_connection inst_cpri.phy_rx_bitslipboundaryselectout/inst_rx_xcvr.rx_bitslipboundaryselectout 

      #TX clock
      add_connection inst_cpri.phy_mgmt_clk/inst_tx_xcvr.phy_mgmt_clk
      add_connection inst_cpri.phy_mgmt_clk_reset/inst_tx_xcvr.phy_mgmt_clk_reset
      add_connection inst_cpri.phy_mgmt_interface/inst_tx_xcvr.phy_mgmt
      set_connection_parameter_value inst_cpri.phy_mgmt_interface/inst_tx_xcvr.phy_mgmt baseAddress "0x0800"   
      # TX connection
      add_connection inst_tx_xcvr.tx_ready/inst_cpri.phy_tx_ready
      add_connection inst_tx_xcvr.tx_serial_data/inst_cpri.phy_tx_serial_data
      add_connection inst_tx_xcvr.pll_locked/inst_cpri.phy_pll_locked
      add_connection inst_tx_xcvr.tx_clkout/inst_cpri.phy_tx_clkout   
      add_connection inst_cpri.phy_pll_inclk/inst_tx_xcvr.pll_ref_clk      
      add_connection inst_cpri.phy_tx_parallel_data/inst_tx_xcvr.tx_parallel_data
      add_connection inst_cpri.phy_tx_bitslipboundaryselect/inst_tx_xcvr.tx_bitslipboundaryselect
   }
} else {
# +-----------------------------------
# GXB connection point reconfig_busy
# |    
   add_interface          reconfig_busy           conduit       end 
   set_interface_property reconfig_busy           EXPORT_OF     inst_cpri.reconfig_busy
   set_interface_property reconfig_busy           PORT_NAME_MAP {reconfig_busy reconfig_busy}

# +-----------------------------------
# | GXB connection point reconfig_write
# | 
   add_interface          reconfig_write          conduit       end 
   set_interface_property reconfig_write          EXPORT_OF     inst_cpri.reconfig_write
   set_interface_property reconfig_write          PORT_NAME_MAP {reconfig_write reconfig_write}

# +-----------------------------------
# | GXB connection point reconfig_done
# | 
   add_interface          reconfig_done           conduit       end 
   set_interface_property reconfig_done           EXPORT_OF     inst_cpri.reconfig_done
   set_interface_property reconfig_done           PORT_NAME_MAP {reconfig_done reconfig_done}

   add_interface          gxb_cal_blk_clk         conduit       end
   set_interface_property gxb_cal_blk_clk         EXPORT_OF     inst_cpri.gxb_cal_blk_clk 
   set_interface_property gxb_cal_blk_clk         PORT_NAME_MAP {gxb_cal_blk_clk gxb_cal_blk_clk}

   add_interface          gxb_powerdown           conduit       end
   set_interface_property gxb_powerdown           EXPORT_OF     inst_cpri.gxb_powerdown
   set_interface_property gxb_powerdown           PORT_NAME_MAP {gxb_powerdown gxb_powerdown}
   }
}
}
