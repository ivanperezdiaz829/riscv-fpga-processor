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
source ../../altera_xcvr_generic/sv/sv_xcvr_native_fileset.tcl
source ../../altera_xcvr_generic/av/av_xcvr_native_fileset.tcl
#source ../../altera_xcvr_generic/cv/cv_xcvr_native_fileset.tcl  # Do not need CV files
source ../../altera_xcvr_generic/ctrl/alt_xcvr_csr_fileset.tcl

if { [lsearch $auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control ] == -1 } {
  lappend auto_path $env(QUARTUS_ROOTDIR)/../ip/altera/alt_xcvr/altera_xcvr_reset_control
}
package require altera_xcvr_reset_control::fileset



######################################
# +-----------------------------------
# | File set tagging
# +-----------------------------------
######################################

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# | 
proc custom_decl_fileset_groups { phy_root reconfig_root } {


	# For missing vendor-encrypted files, choose to warn only once per vendor
	common_enable_summary_sim_support_warnings 1

	#
	# common to all families
	#
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/" altera_xcvr_functions.sv {ALL_HDL}
	common_fileset_group_plain ./ "$phy_root/xcvr_generic/" altera_xcvr_custom.sv {ALL_HDL}


	#
	# Stratix V & derivatives
	#
	common_fileset_group_plain ./ "$phy_root/sv/" {
		sv_xcvr_custom_nr.sv
		sv_xcvr_custom_native.sv
	} {S5}
	
	#
	# Arria V
	common_fileset_group_plain ./ "$phy_root/av/" {
		av_xcvr_custom_nr.sv
		av_xcvr_custom_native.sv
	} {A5 | C5 }
	
#	common_fileset_group_plain ./ "$phy_root/cv/" {
#		cv_xcvr_custom_nr.sv
#		cv_xcvr_custom_native.sv
#	} {C5}

	alt_xcvr_csr_decl_fileset_groups "$phy_root/../altera_xcvr_generic" 1
	sv_xcvr_native_decl_fileset_groups "$phy_root/../altera_xcvr_generic"
  av_xcvr_native_decl_fileset_groups "$phy_root/../altera_xcvr_generic"
#  cv_xcvr_native_decl_fileset_groups "$phy_root/../altera_xcvr_generic"
  
  # Reset controller
  ::altera_xcvr_reset_control::fileset::declare_files


	common_fileset_group ./ "$phy_root/sv/" OTHER custom_phy_assignments.qip {S5} {QIP}
# Removed modelsim_example_script.tcl per Fogbugz: 36614
	#common_fileset_group  ./ "$phy_root/sv/" OTHER modelsim_example_script.tcl {S5} {MENTOR}
	
	
	# Stratix IV & derivatives
	#
	common_fileset_group ./ "$phy_root/siv/" AUTOTYPE {
		siv_xcvr_custom_phy.sv
		siv_xcvr_generic_top.sv
		siv_xcvr_generic.sv
	} {S4} {PLAIN}	;#  MENTOR encryption is not enabled for these

	#
	# Reconfiguration block files
	#
	xreconf_decl_fileset_groups $reconfig_root

}

# +------------------------------------------
# | Define fileset by family for given tools
# | 
proc custom_add_fileset_for_tool {tool} {

	# S4-generation family?
	set device_family [get_parameter_value device_family]
	if { [::alt_xcvr::utils::device::has_s4_style_hssi $device_family] } {
		common_add_fileset_files {S4 ALL_HDL ALT_RESET_CTRL ALT_XCVR_CSR} $tool
	} elseif { [::alt_xcvr::utils::device::has_s5_style_hssi $device_family] } {
		# S5 and derivatives
		common_add_fileset_files {S5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool
	} elseif { [::alt_xcvr::utils::device::has_a5_style_hssi $device_family] } {
		# A5 and derivatives
		common_add_fileset_files {A5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool	
  } elseif { [::alt_xcvr::utils::device::has_c5_style_hssi $device_family] } {
		# A5 and derivatives
		common_add_fileset_files {A5 ALL_HDL ALTERA_XCVR_RESET_CONTROL ALT_XCVR_CSR} $tool
	} else {
		# Unknown family
		send_message error "Current device_family ($device_family) is not supported"
	}
}

