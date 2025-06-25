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


# This package provides high level access to functions within the MIF feature block
# inside the alt_xcvr_reconfig Transceiver Reconfiguration Controller
package provide alt_xcvr::system_console::alt_xcvr_reconfig_mif 12.0

package require alt_xcvr::system_console::alt_xcvr_reconfig_if

namespace eval ::alt_xcvr::system_console::alt_xcvr_reconfig_if:: {
  # Import needed namespaces
  # This package extends the alt_xcvr_reconfig_if package
  # namespace import ::alt_xcvr::system_console::alt_xcvr_reconfig_if::*

  # Export methods
  namespace export \
    mif_physical_write \
    mif_physical_read \
    mif_logical_write \
    mif_logical_read \
    mif_protected_write \
    mif_protected_read \
    get_atx_tune_setting

  # MIF specific CSR register bit masks
  variable ADDR_RCFG_MIF_CSR_MODE_OFST    2
  variable ADDR_RCFG_MIF_CSR_MODE_MASK    0x000C
  # MIF direct write/read modes
  variable ADDR_RCFG_MIF_CSR_MODE_PROTECTED 1
  variable ADDR_RCFG_MIF_CSR_MODE_LOGICAL   2
  variable ADDR_RCFG_MIF_CSR_MODE_PHYSICAL  3

}


###
# Perform a DPRIO register write via the MIF reconfig block in physical mode.
# Physical mode bypasses any address offsetting.
#
# @param - logical_if - The interface index to write to on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
# @param - data - The value to write to the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_physical_write { logical_if address data } {
  variable ADDR_RCFG_MIF_CSR_MODE_PHYSICAL

  mif_generic_write $logical_if $address $data $ADDR_RCFG_MIF_CSR_MODE_PHYSICAL
}


###
# Perform a DPRIO register read via the MIF reconfig block in physical mode.
# Physical mode bypasses any address offsetting.
#
# @param - logical_if - The interface index to read from on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
#
# @return - The value of the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_physical_read { logical_if address } {
  variable ADDR_RCFG_MIF_CSR_MODE_PHYSICAL

  return [mif_generic_read $logical_if $address $ADDR_RCFG_MIF_CSR_MODE_PHYSICAL]
}


###
# Perform a DPRIO register write via the MIF reconfig block in logical mode.
# Logical mode includes address offsetting but bypasses DPRIO bit protection
#
# @param - logical_if - The interface index to write to on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
# @param - data - The value to write to the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_logical_write { logical_if address data } {
  variable ADDR_RCFG_MIF_CSR_MODE_PHYSICAL

  mif_generic_write $logical_if $address $data $ADDR_RCFG_MIF_CSR_MODE_LOGICAL
}


###
# Perform a DPRIO register read via the MIF reconfig block in logical mode.
# Logical mode includes address offsetting but bypasses DPRIO bit protection
#
# @param - logical_if - The interface index to read from on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
#
# @return - The value of the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_logical_read { logical_if address } {
  variable ADDR_RCFG_MIF_CSR_MODE_PHYSICAL

  return [mif_generic_read $logical_if $address $ADDR_RCFG_MIF_CSR_MODE_LOGICAL]
}


###
# Perform a DPRIO register write via the MIF reconfig block in protected mode.
# Protected mode includes address offsetting and DPRIO bit protection.
#
# @param - logical_if - The interface index to write to on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
# @param - data - The value to write to the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_protected_write { logical_if address data } {
  variable ADDR_RCFG_MIF_CSR_MODE_PHYSICAL

  mif_generic_write $logical_if $address $data $ADDR_RCFG_MIF_CSR_MODE_PROTECTED
}


###
# Perform a DPRIO register read via the MIF reconfig block in protected mode.
# Protected mode includes address offsetting and DPRIO bit protection.
#
# @param - logical_if - The interface index to read from on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
#
# @return - The value of the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_protected_read { logical_if address } {
  variable ADDR_RCFG_MIF_CSR_MODE_PHYSICAL

  return [mif_generic_read $logical_if $address $ADDR_RCFG_MIF_CSR_MODE_PROTECTED]
}


###
# Read the current tuning values from the PLL's DPRIO space and return them in
# the "setting" format.
# 
# @return An encoded word where certain bits represent bit settings for registers
# 			within the PLL's DPRIO address space.
# 
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_atx_tune_setting { logical_if } {
	# Get VCO Select and VCO Gear select setting
	set temp [mif_physical_read $logical_if 0x299]
	set temp [expr {$temp & [expr {0x0008 | 0x0040}]}]
	# Get VREG1 Select setting
	set temp2 [mif_physical_read $logical_if 0x4F1]
	set temp2 [expr {$temp2 & 0x0E00}]
	set temp [expr {$temp | $temp2}]
	return $temp
}


#############################################################################
########################## Internal Functions ###############################

###
# Perform a DPRIO register write via the MIF reconfig block. Caller specifies the write mode.
#
# @param - logical_if - The interface index to write to on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
# @param - data - The value to write to the DPRIO register.
# @param - mode - The access mode (protected, logical, physical) when reading the register
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_generic_write { logical_if address data mode } {
  variable INDEX_XR_MIF
  variable ADDR_RCFG_COMMON_CSR_BUSY_MASK
  variable ADDR_RCFG_COMMON_CSR_WR_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_OFST

  set lcl_mode_mask [expr {[expr {$mode << $ADDR_RCFG_MIF_CSR_MODE_OFST}] & $ADDR_RCFG_MIF_CSR_MODE_MASK}]

  # wait for busy
  while { [reconfig_read [expr {[get_csr_ofst $INDEX_XR_MIF] & $ADDR_RCFG_COMMON_CSR_BUSY_MASK}]]} {}
  reconfig_write [get_lif_ofst $INDEX_XR_MIF] $logical_if
  reconfig_write [get_csr_ofst $INDEX_XR_MIF] $lcl_mode_mask
  reconfig_write [get_addr_ofst $INDEX_XR_MIF] $address
  reconfig_write [get_data_ofst $INDEX_XR_MIF] $data
  reconfig_write [get_csr_ofst $INDEX_XR_MIF] [expr {$lcl_mode_mask | $ADDR_RCFG_COMMON_CSR_WR_MASK}]
}


###
# Perform a DPRIO register read via the MIF reconfig block. Caller specifies the read mode
#
# @param - logical_if - The interface index to read from on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
# @param - mode - The access mode (protected, logical, physical) when reading the register
#
# @return - The value of the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::mif_generic_read { logical_if address mode } {
  variable INDEX_XR_MIF
  variable ADDR_RCFG_COMMON_CSR_BUSY_MASK
  variable ADDR_RCFG_COMMON_CSR_RD_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_OFST

  set lcl_mode_mask [expr {[expr {$mode << $ADDR_RCFG_MIF_CSR_MODE_OFST}] & $ADDR_RCFG_MIF_CSR_MODE_MASK}]
  # wait for busy
  while { [reconfig_read [expr {[get_csr_ofst $INDEX_XR_MIF] & $ADDR_RCFG_COMMON_CSR_BUSY_MASK}]]} {}
  reconfig_write [get_lif_ofst $INDEX_XR_MIF] $logical_if
  reconfig_write [get_csr_ofst $INDEX_XR_MIF] $lcl_mode_mask
  reconfig_write [get_addr_ofst $INDEX_XR_MIF] $address
  reconfig_write [get_csr_ofst $INDEX_XR_MIF] [expr {$lcl_mode_mask | $ADDR_RCFG_COMMON_CSR_RD_MASK}]
  while { [reconfig_read [expr {[get_csr_ofst $INDEX_XR_MIF] & $ADDR_RCFG_COMMON_CSR_BUSY_MASK}]]} {}
  return [reconfig_read [get_data_ofst $INDEX_XR_MIF]]
}
########################## Internal Functions ###############################
#############################################################################

