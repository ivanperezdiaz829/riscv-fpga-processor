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


# (C) 2001-2011 Altera Corporation. All rights reserved.
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


# Common files for PCIExpress PIPE components
#
# $Header: //acds/rel/13.1/ip/altera_pcie_pipe/av/av_xcvr_pipe_common.tcl#1 $

set common_composed_mode 0

# +-----------------------------------
# | initialize the exported interface data to an empty set
# |
# | Set composed mode, affects common_add* interface methods
# |
proc common_initialize { composed } {
	global common_composed_mode
	set common_composed_mode $composed
}




######################################
# +-----------------------------------
# | File set tagging
# +-----------------------------------
######################################

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# |
proc pipe_decl_fileset_groups_av_xcvr_pipe_native { phy_root } {

	av_xcvr_native_decl_fileset_groups $phy_root/../../altera_xcvr_generic
	alt_xcvr_csr_decl_fileset_groups $phy_root/../../altera_xcvr_generic

        common_fileset_group_plain ./ $phy_root/../av/ {
		av_xcvr_emsip_adapter.sv
		av_xcvr_pipe_native_hip.sv
	} {A5}

}

proc pipe_decl_fileset_groups_av_xcvr_pipe_nr { phy_root } {

	pipe_decl_fileset_groups_av_xcvr_pipe_native $phy_root
}

proc pipe_decl_fileset_groups_top { phy_root } {

	pipe_decl_fileset_groups_av_xcvr_pipe_nr $phy_root
}
