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


# +--------------------------------------------
# | Tcl library of Custom PHY common functions
# +--------------------------------------------
source ../../altera_xcvr_8g_custom/xcvr_generic/xcvr_custom_phy_hw_common.tcl
source ../../alt_xcvr/altera_xcvr_native_phy/av/tcl/fileset.tcl


######################################
# +-----------------------------------
# | File set tagging
# +-----------------------------------
######################################

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# | 
proc detlat_decl_fileset_groups { phy_root reconfig_root } {

	# For missing vendor-encrypted files, choose to warn only once per vendor
	common_enable_summary_sim_support_warnings 1

	#
	# common to all families
	#
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/" altera_xcvr_functions.sv {ALL_HDL}
	common_fileset_group_plain ./ "$phy_root/soft_pcs/" altera_xcvr_detlatency_top_phy.sv {ALL_HDL}

	#
	# Arria V soft PCS
	#
	common_fileset_group_plain ./ "$phy_root/soft_pcs/" {
		altera_xcvr_detlatency_top_phy_native.sv
		altera_xcvr_detlatency_top_pcs.sv
		altera_xcvr_detlatency_top_pcs_ch.sv
		altera_xcvr_detlatency_8b10bdec.sv
		altera_xcvr_detlatency_8b10benc.sv
		altera_xcvr_detlatency_wys_lut.v
		altera_xcvr_detlatency_expansion.sv
		altera_xcvr_detlatency_ph_calculator.sv
		altera_xcvr_detlatency_ph_dcfifo.sv
		altera_xcvr_detlatency_ph_measure_fifo.sv
		altera_xcvr_detlatency_reduction.sv
		altera_xcvr_detlatency_reset_control.sv
		altera_xcvr_detlatency_reset_filter.sv
		altera_xcvr_detlatency_rx_ctrl.sv
		altera_xcvr_detlatency_rx_dwidth_adapter.sv
		altera_xcvr_detlatency_ser_deser.sv
		altera_xcvr_detlatency_synchronizer.sv
		altera_xcvr_detlatency_tx_ctrl.sv
		altera_xcvr_detlatency_tx_dwidth_adapter.sv
		altera_xcvr_detlatency_txbitslip.sv
		altera_xcvr_detlatency_wa_dlsm.sv
		altera_xcvr_detlatency_wordalign.sv
		altera_xcvr_detlatency_xn_8b10bdec.sv
		altera_xcvr_detlatency_xn_8b10benc.sv
	} {ALL_HDL}

  # AV Core files
  set path [::alt_xcvr::utils::fileset::abs_to_rel_path [::alt_xcvr::utils::fileset::get_altera_xcvr_generic_path]]
  av_xcvr_native_decl_fileset_groups $path
  alt_xcvr_csr_decl_fileset_groups $path

  # Native phy
#	::altera_xcvr_native_av::fileset::declare_files
  # altera_xcvr_native_av files
#  set path [::alt_xcvr::utils::fileset::get_alt_xcvr_path]
#  set path "${path}/altera_xcvr_native_phy/av/"
#  set path [::alt_xcvr::utils::fileset::abs_to_rel_path $path]
#  ::alt_xcvr::utils::fileset::common_fileset_group_plain ./ $path {
#    altera_xcvr_native_av_functions_h.sv
#    altera_xcvr_native_av.sv
#    altera_xcvr_data_adapter_av.sv
#  } {altera_xcvr_native_av}

common_fileset_group_plain ./ "$phy_root/../alt_xcvr/altera_xcvr_native_phy/av/" {
   altera_xcvr_native_av_functions_h.sv
      altera_xcvr_native_av.sv
 } {A5 | C5}
 
  # Reset controller
  ::altera_xcvr_reset_control::fileset::declare_files "$phy_root/../alt_xcvr/altera_xcvr_reset_control"
  	
	# Reconfiguration block files
	xreconf_decl_fileset_groups $reconfig_root
}
