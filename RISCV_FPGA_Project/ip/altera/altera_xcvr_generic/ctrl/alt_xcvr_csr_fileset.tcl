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


#
# Common functions for transceiver csr blocks
#

proc alt_xcvr_csr_decl_fileset_groups { altera_xcvr_generic_root {separate_tags 0}} {

  set tag [list ALL_HDL]
  # Reset controller
  if {$separate_tags == 1} {
    set tag [list ALT_RESET_CTRL]
  }
  common_fileset_group_plain ./ "$altera_xcvr_generic_root/ctrl/" {
    alt_reset_ctrl_lego.sv
    alt_reset_ctrl_tgx_cdrauto.sv
    alt_xcvr_resync.sv
  } $tag

  # Control and Status Registers
  if {$separate_tags == 1} {
    set tag [list ALT_XCVR_CSR]
  }
  common_fileset_group_plain ./ "$altera_xcvr_generic_root/ctrl/" {
    alt_xcvr_resync.sv
    alt_xcvr_csr_common_h.sv
    alt_xcvr_csr_common.sv
    alt_xcvr_csr_pcs8g_h.sv
    alt_xcvr_csr_pcs8g.sv
    alt_xcvr_csr_selector.sv
    alt_xcvr_mgmt2dec.sv
    altera_wait_generate.v
  } $tag

  # Resync module
  common_fileset_group_plain ./ "$altera_xcvr_generic_root/ctrl/" {
    alt_xcvr_resync.sv
  } {ALL_HDL}

}
