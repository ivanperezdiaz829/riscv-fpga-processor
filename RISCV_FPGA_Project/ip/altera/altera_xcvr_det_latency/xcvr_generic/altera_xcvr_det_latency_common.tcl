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
	common_fileset_group_plain ./ "$phy_root/xcvr_generic/" altera_xcvr_det_latency.sv {ALL_HDL}

	#
	# Stratix V & derivatives
	#
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_8g_custom/sv/" {
		sv_xcvr_custom_nr.sv
		sv_xcvr_custom_native.sv
	} {S5}

	#
	# Arria V
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_8g_custom/av/" {
		av_xcvr_custom_nr.sv
		av_xcvr_custom_native.sv
	} {A5 | C5}

	alt_xcvr_csr_decl_fileset_groups "$phy_root/../altera_xcvr_generic" 1
	sv_xcvr_native_decl_fileset_groups "$phy_root/../altera_xcvr_generic"
  av_xcvr_native_decl_fileset_groups "$phy_root/../altera_xcvr_generic"

  # Reset controller
  ::altera_xcvr_reset_control::fileset::declare_files "$phy_root/../alt_xcvr/altera_xcvr_reset_control"

	#
	# Reconfiguration block files
	#
	xreconf_decl_fileset_groups $reconfig_root

}
