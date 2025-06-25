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
# | $Header: //acds/rel/13.1/ip/alt_pma/source/altera_xcvr_low_latency_phy/xcvr_low_latency_files.tcl#1 $
# +--------------------------------------------


######################################
# +-----------------------------------
# | File set tagging
# +-----------------------------------
######################################

source ../../../altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl
source ../../../altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# | 
proc low_latency_decl_fileset_groups { phy_root } {

	# For missing vendor-encrypted files, choose to warn only once per vendor
	common_enable_summary_sim_support_warnings 1

	#
	# common to all families
	#
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/" {
		altera_xcvr_functions.sv
	} {ALL_HDL}
	common_fileset_group_plain ./ "$phy_root/source/altera_xcvr_low_latency_phy/" {
		altera_xcvr_low_latency_phy.sv
	} {ALL_HDL}
	common_fileset_group_plain ./ "$phy_root/source/channel_controller/" {
		alt_pma_ch_controller_tgx.v
		tgx_ch_reset_ctrl.sv
	} {S4}
	common_fileset_group_plain ./ "$phy_root/source/alt_pma_controller/" {
		alt_pma_controller_tgx.v
	} {ALL_HDL}
	#
	# Common CSR blocks
	alt_xcvr_csr_decl_fileset_groups $phy_root/../altera_xcvr_generic/ 1

  # Reset controller
  ::altera_xcvr_reset_control::fileset::declare_files

	#
	# Stratix V & derivatives
	#
    common_fileset_group_plain ./ "$phy_root/source/stratixv/" {
	  sv_xcvr_low_latency_phy_nr.sv
	} {S5 S5_ATT}
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_10g_custom/" {
		sv_xcvr_10g_custom_native.sv
	} {S5}
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_8g_custom/sv/" {
		sv_xcvr_custom_native.sv
	} {S5}
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_att_custom/sv/" {
		sv_xcvr_att_custom_native.sv
	} {S5_ATT}
	#
	# sv_xcvr_native and all sub-modules
	sv_xcvr_native_decl_fileset_groups $phy_root/../altera_xcvr_generic/
	
	#
	# Stratix IV & derivatives
	#
	common_fileset_group_plain ./ "$phy_root/source/alt_pma/" {
		alt_pma_functions.sv
	} {S4}
	
	common_fileset_group_plain ./ "$phy_root/source/stratixiv/" {
		siv_xcvr_low_latency_phy_nr.sv
	} {S4}

	#
	# Reconfiguration block files
	#
	xreconf_decl_fileset_groups $phy_root/../alt_xcvr_reconfig
}

# +------------------------------------------
# | Define fileset by family for given tools
# | 
proc low_latency_add_fileset_for_tool {tool} {

    # set data_path_type  [get_parameter_value gui_data_path_type]
    set data_path_type  [get_datapath_mapped_hdl [::alt_xcvr::utils::common::get_mapped_allowed_range_value gui_data_path_type]]

	# S4-generation family?
	set device_family [get_parameter_value device_family]
	if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
		common_add_fileset_files {S4 ALL_HDL ALT_RESET_CTRL ALT_XCVR_CSR} $tool
	} elseif { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] && $data_path_type == "ATT"} {
		# S5 and derivatives
        common_add_fileset_files {S5_ATT ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool
        #common_add_fileset_files {S5 S5_ATT ALL_HDL} $tool
     } elseif { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
        common_add_fileset_files {S5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool
	} else {
		# Unknown family
		send_message error "Current device_family ($device_family) is not supported"
	}
}

