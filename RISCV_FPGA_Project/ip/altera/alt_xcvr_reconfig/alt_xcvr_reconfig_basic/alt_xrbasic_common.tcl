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



# +-------------------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc xrbasic_add_clock { port_name port_dir } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name clock $in_out($port_dir)
	set_interface_property $port_name ENABLED true
	add_interface_port $port_name $port_name clk $port_dir 1
}

# +-------------------------------------------
# | Add Reset interface and port of same name
# | Associate with reconfig_clk
# | 
# | $port_dir - can be 'input' or 'output'
proc xrbasic_add_reset { port_name port_dir } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name reset $in_out($port_dir)
	set_interface_property $port_name ENABLED true
	set_interface_property $port_name ASSOCIATED_CLOCK reconfig_clk
	add_interface_port $port_name $port_name reset $port_dir 1
}

# +-----------------------------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc xrbasic_add_tagged_conduit { port_name port_dir width tags } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name conduit $in_out($port_dir)
	set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
	#set_interface_property $port_name ENABLED $used
	common_add_interface_port $port_name $port_name export $port_dir $width $tags
	if {$port_dir == "input"} {
		set_port_property $port_name TERMINATION_VALUE 0
	}
}
proc xrbasic_add_tagged_conduit_bus { port_name port_dir width tags } {
	xrbasic_add_tagged_conduit $port_name $port_dir $width $tags 
	set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}


######################################
# +-----------------------------------
# | File set tagging
# +-----------------------------------
######################################

# +-----------------------------------
# | Declare all files, with appropriate implementation tags and tool-flow tags
# | 
proc xrbasic_decl_fileset_groups { phy_root } {

	# For missing vendor-encrypted files, choose to warn only once per vendor
	common_enable_summary_sim_support_warnings 1

	#
	# packages first
	#
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/" altera_xcvr_functions.sv {ALL_HDL}
	common_fileset_group_plain ./ "$phy_root/alt_xcvr_reconfig_basic/" alt_xcvr_reconfig_basic_h.sv {ALL_HDL}

	#
	# common to all families
	#
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/ctrl/" {
		alt_xcvr_arbiter.sv
		alt_xcvr_csr_selector.sv
	} {ALL_HDL}
	#alt_xcvr_csr_decl_fileset_groups "$phy_root/../altera_xcvr_generic/"

	#
	# Stratix V & derivatives
	#
	common_fileset_group_plain ./ "$phy_root/alt_xcvr_reconfig_basic/" {
		sv_xcvr_reconfig_basic.sv
		sv_xrbasic_l2p_addr.sv
		sv_xrbasic_l2p_ch.sv
		sv_xrbasic_lif.sv
		sv_xrbasic_lif_csr.sv
	} {S5}
	common_fileset_group_plain ./ "$phy_root/alt_xcvr_reconfig_basic/" {
		av_xcvr_reconfig_basic.sv
		av_xrbasic_l2p_addr.sv
		av_xrbasic_l2p_ch.sv
		av_xrbasic_lif.sv
		av_xrbasic_lif_csr.sv
	} {A5}
	common_fileset_group_plain ./ "$phy_root/../altera_xcvr_generic/sv/" {
		sv_reconfig_bundle_to_basic.sv
	} {S5}
}
