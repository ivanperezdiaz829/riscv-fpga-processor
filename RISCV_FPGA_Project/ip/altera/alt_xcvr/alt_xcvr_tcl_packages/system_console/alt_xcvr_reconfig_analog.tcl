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
package provide alt_xcvr::system_console::alt_xcvr_reconfig_analog 12.0

package require alt_xcvr::system_console::alt_xcvr_reconfig_if

namespace eval ::alt_xcvr::system_console::alt_xcvr_reconfig_if:: {
  # Import needed namespaces
  # This package extends the alt_xcvr_reconfig_if package
  # namespace import ::alt_xcvr::system_console::alt_xcvr_reconfig_if::*

  # Export methods
  namespace export \
    analog_write \
    analog_read
}


###
# Perform a DPRIO register write to the analog reconfig block.
#
# @param - logical_if - The interface index to write to on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
# @param - data - The value to write to the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::analog_write { logical_if address data } {
  variable INDEX_XR_ANALOG
  variable ADDR_RCFG_COMMON_CSR_BUSY_MASK
  variable ADDR_RCFG_COMMON_CSR_WR_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_OFST

  # wait for busy
  while { [reconfig_read [expr {[get_csr_ofst $INDEX_XR_ANALOG] & $ADDR_RCFG_COMMON_CSR_BUSY_MASK}]]} {}
  reconfig_write [get_lif_ofst $INDEX_XR_ANALOG] $logical_if
  reconfig_write [get_addr_ofst $INDEX_XR_ANALOG] $address
  reconfig_write [get_data_ofst $INDEX_XR_ANALOG] $data
  reconfig_write [get_csr_ofst $INDEX_XR_ANALOG] $ADDR_RCFG_COMMON_CSR_WR_MASK
}


###
# Perform a DPRIO register read from the analog reconfig block.
#
# @param - logical_if - The interface index to read from on the reconfig controller.
# @param - address - The DPRIO address to access within the reconfig controller.
#
# @return - The value of the DPRIO register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::analog_read { logical_if address } {
  variable INDEX_XR_ANALOG
  variable ADDR_RCFG_COMMON_CSR_BUSY_MASK
  variable ADDR_RCFG_COMMON_CSR_RD_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_MASK
  variable ADDR_RCFG_MIF_CSR_MODE_OFST
  
  while { [reconfig_read [expr {[get_csr_ofst $INDEX_XR_ANALOG] & $ADDR_RCFG_COMMON_CSR_BUSY_MASK}]]} {}
  reconfig_write [get_lif_ofst $INDEX_XR_ANALOG] $logical_if
  reconfig_write [get_addr_ofst $INDEX_XR_ANALOG] $address
  reconfig_write [get_csr_ofst $INDEX_XR_ANALOG] $ADDR_RCFG_COMMON_CSR_RD_MASK
  while { [reconfig_read [expr {[get_csr_ofst $INDEX_XR_ANALOG] & $ADDR_RCFG_COMMON_CSR_BUSY_MASK}]]} {}
  return [reconfig_read [get_data_ofst $INDEX_XR_ANALOG]]
}

