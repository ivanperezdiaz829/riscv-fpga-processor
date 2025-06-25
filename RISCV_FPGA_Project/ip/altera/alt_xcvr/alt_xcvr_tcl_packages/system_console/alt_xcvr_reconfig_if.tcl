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


package provide alt_xcvr::system_console::alt_xcvr_reconfig_if 12.0

namespace eval ::alt_xcvr::system_console::alt_xcvr_reconfig_if:: {
  # Export methods
  namespace export \
    set_master \
    use_default_master \
    get_lif_ofst \
    get_pif_ofst \
    get_csr_ofst \
    get_addr_ofst \
    get_data_ofst \
    get_rsvd1_ofst \
    get_rsvd2_ofst \
    get_rsvd3_ofst \
    reconfig_write \
    reconfig_read

  variable INDEX_XR_OFFSET  0
  variable INDEX_XR_ANALOG  1
  variable INDEX_XR_EYEMON  2
  variable INDEX_XR_DFE     3
  variable INDEX_XR_DIRECT  4
  variable INDEX_XR_ADCE    5
  variable INDEX_XR_LC      6
  variable INDEX_XR_MIF     7
  variable INDEX_XR_PLL     8
  variable INDEX_XR_DCD     9
  variable INDEX_XR_END     10

  variable ADDR_RCFG_LIF_OFST 0
  variable ADDR_RCFG_PIF_OFST 1
  variable ADDR_RCFG_CSR_OFST 2
  variable ADDR_RCFG_ADDR_OFST 3
  variable ADDR_RCFG_DATA_OFST 4
  variable ADDR_RCFG_RSVD1_OFST 5
  variable ADDR_RCFG_RSVD2_OFST 6
  variable ADDR_RCFG_RSVD3_OFST 7

  # Common CSR register bit masks
  variable ADDR_RCFG_COMMON_CSR_ERR_OFST  9
  variable ADDR_RCFG_COMMON_CSR_ERR_MASK  0x0200
  variable ADDR_RCFG_COMMON_CSR_BUSY_OFST 8
  variable ADDR_RCFG_COMMON_CSR_BUSY_MASK 0x0100
  variable ADDR_RCFG_COMMON_CSR_RD_OFST   1
  variable ADDR_RCFG_COMMON_CSR_RD_MASK   0x0002
  variable ADDR_RCFG_COMMON_CSR_WR_OFST   0
  variable ADDR_RCFG_COMMON_CSR_WR_MASK   0x0001

  variable master_path ""
}
# End namespace eval

###
# Retrieve the address offset of the LIF register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_lif_ofst { feature_index } {
  variable ADDR_RCFG_LIF_OFST
  return [expr {[expr {$feature_index * 8}] + $ADDR_RCFG_LIF_OFST}]
}

###
# Retrieve the address offset of the PIF register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_pif_ofst { feature_index } {
  variable ADDR_RCFG_PIF_OFST
  return [expr {[expr {$feature_index * 8}] + $ADDR_RCFG_PIF_OFST}]
}

###
# Retrieve the address offset of the CSR register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_csr_ofst { feature_index } {
  variable ADDR_RCFG_CSR_OFST
  return [expr {[expr $feature_index * 8] + $ADDR_RCFG_CSR_OFST}]
}

###
# Retrieve the address offset of the ADDR register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_addr_ofst { feature_index } {
  variable ADDR_RCFG_ADDR_OFST
  return [expr {[expr {$feature_index * 8}] + $ADDR_RCFG_ADDR_OFST}]
}

###
# Retrieve the address offset of the DATA register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_data_ofst { feature_index } {
  variable ADDR_RCFG_DATA_OFST
  return [expr {[expr {$feature_index * 8}] + $ADDR_RCFG_DATA_OFST}]
}

###
# Retrieve the address offset of the RSVD1 register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_rsvd1_ofst { feature_index } {
  variable ADDR_RCFG_RSVD1_OFST
  return [expr {[expr {$feature_index * 8}] + $ADDR_RCFG_RSVD1_OFST}]
}

###
# Retrieve the address offset of the RSVD2 register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_rsvd2_ofst { feature_index } {
  variable ADDR_RCFG_RSVD2_OFST
  return [expr {[expr {$feature_index * 8}] + $ADDR_RCFG_RSVD2_OFST}]
}

###
# Retrieve the address offset of the RSVD3 register for the specified feature
# block.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::get_rsvd3_ofst { feature_index } {
  variable ADDR_RCFG_RSVD2_OFST
  return [expr {[expr {$feature_index * 8}] + $ADDR_RCFG_RSVD3_OFST}]
}

###
# Set the path of the JTAG master to be used hereafter
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::set_master { path } {
  variable master_path
  set master_path $path
}


###
# Use the first detected JTAG master
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::use_default_master {} {
  variable master_path
  set master_path [ lindex [ get_service_paths master ] 0 ]
}

###
# Perform a single register write to the reconfig controller
#
# @param - address - The register address to write to.
# @param - data - The data to be written to the register.
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::reconfig_write { address data } {
  set address [expr {$address * 4}]
  write_32 $address $data
}

###
# Perform a single register read from the reconfig controller
#
# @param - address - The register address to read from.
#
# @return - The value of the register specified by "address"
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::reconfig_read { address } {
  set address [expr {$address * 4}]
  return [read_32 $address 1]
}


#****************************************************************************
#************************* Internal Functions *******************************

# Functions for accessing the jtag master
###
# Write a set of 32-bit (4 byte) values beginning at the address
# specified. The address must be on a 4-byte boundary
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::write_32 { address values } {
  variable master_path

  if { $master_path == "" } {
    puts "JTAG master path not specified! No write performed!"
  } else {
    master_write_32 $master_path $address $values
  }
}

###
# Read a set of 32-bit (4 byte) values beginning at the address
# specified. The address must be on a 4-byte boundary
proc ::alt_xcvr::system_console::alt_xcvr_reconfig_if::read_32 { address size } {
  variable master_path

  if { $master_path == "" } {
    puts "JTAG master path not specified! No read performed!"
    return 0
  } else {
    return [ master_read_32 $master_path $address $size ]
  }
}
#************************* Internal Functions *******************************
#****************************************************************************
