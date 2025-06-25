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


# +---------------------------------------------------------------------------
# | Low Latency port function declarations
# | $Header: //acds/rel/13.1/ip/alt_pma/source/altera_xcvr_low_latency_phy/xcvr_low_latency_port_procs.tcl#1 $
# +---------------------------------------------------------------------------


# +-----------------------------------------------------
# | Add optional conduit interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc low_latency_add_tagged_conduit { port_name port_dir width tags {port_role "export"} } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name conduit $in_out($port_dir)
	set_interface_assignment $port_name "ui.blockdiagram.direction" $port_dir
	#set_interface_property $port_name ENABLED $used
	common_add_interface_port $port_name $port_name $port_role $port_dir $width $tags
	if {$port_dir == "input"} {
		set_port_property $port_name TERMINATION_VALUE 0
	}
}
proc low_latency_add_tagged_conduit_bus { port_name port_dir width tags {port_role "export"} } {
	low_latency_add_tagged_conduit $port_name $port_dir $width $tags $port_role 
	set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}
# +---------------------------------------------------------
# | Add dynamic conduit interface with optional termination
# | 
proc low_latency_add_dynamic_conduit_bus { port_name port_dir width terminated } {

	low_latency_add_tagged_conduit_bus $port_name $port_dir $width {NoTag} 

	# if this interface is terminated, do it here since it's dynamically generated
	if {$terminated} {
		set_port_property $port_name TERMINATION 1
	}
}


# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, associated with phy_mgmt_clk
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc low_latency_add_mgmt_clk_stream { port_name port_dir width used } {

	array set in_out [list {output} {start} {input} {end} ]
	# create interface details
	add_interface $port_name avalon_streaming $in_out($port_dir)
	set_interface_property $port_name dataBitsPerSymbol $width
	set_interface_property $port_name maxChannel 0
	set_interface_property $port_name readyLatency 0
	set_interface_property $port_name symbolsPerBeat 1
	set_interface_property $port_name ENABLED $used
	set_interface_property $port_name ASSOCIATED_CLOCK phy_mgmt_clk
	add_interface_port $port_name $port_name data $port_dir $width
	set_port_property $port_name VHDL_TYPE STD_LOGIC_VECTOR
}


# +-----------------------------------
# | Add Clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc low_latency_add_clock { port_name port_dir } {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name clock $in_out($port_dir)
	set_interface_property $port_name ENABLED true
	add_interface_port $port_name $port_name clk $port_dir 1
}


# +-----------------------------------
# | Add clock bus as a clock interface and port of same name
# | 
# | $port_dir - can be 'input' or 'output'
proc low_latency_add_tagged_clock_bus { port_name port_dir port_width tags} {

	array set in_out [list {output} {start} {input} {end} ]
	add_interface $port_name clock $in_out($port_dir)
	set_interface_property $port_name ENABLED true
	common_add_interface_port $port_name $port_name clk $port_dir $port_width $tags
}


# +-----------------------------------------------------------
# | Add clock bus as a split clock interface or a conduit bus
# | 
# | $port_dir - can be 'input' or 'output'
proc low_latency_add_dynamic_conduit_or_clock_bus { port_name port_dir port_width tags {split 0}} {

	array set in_out [list {output} {start} {input} {end} ]

	# even if split indicated, only split if not terminated
	set terminated [common_get_tagged_property_state $tags TERMINATION 0 ]

	if {$split && ! $terminated} {
		for {set i 0} {$i < $port_width} {incr i} {
			add_interface ${port_name}$i clock $in_out($port_dir)
			set_interface_property ${port_name}$i ENABLED true
			add_interface_port ${port_name}$i ${port_name}$i clk $port_dir 1
			set_port_property ${port_name}$i FRAGMENT_LIST ${port_name}@${i}
		}
	} else {
		low_latency_add_dynamic_conduit_bus $port_name $port_dir $port_width $terminated
	}
}


# +-----------------------------------
# | Add optional Avalon ST interface and port of same name, split into multiple streams
# | 
# | This function is intended to be called from an elaboration callback, so it does not
# | register ports with the common tagged port API
# | 
# | $port_dir - can be 'input' or 'output'
# | $used     - can be 'true' or 'false'
proc low_latency_add_split_stream { port_name port_dir width bits_per_symbol assoc_clock is_bonded fragments } {

	array set in_out [list {output} {start} {input} {end} ]
	set fragment_width [expr {$width / $fragments}]
	set num_symbols [expr {$fragment_width / $bits_per_symbol } ]

	for {set i 0} {$i < $fragments} {incr i} {
		# which clock index?
		if {$is_bonded} {
			set clock_index 0
		} else {
			set clock_index $i
		}
		add_interface ${port_name}$i avalon_streaming $in_out($port_dir)
		set_interface_property ${port_name}$i dataBitsPerSymbol $bits_per_symbol
		set_interface_property ${port_name}$i maxChannel 0
		set_interface_property ${port_name}$i readyLatency 0
		set_interface_property ${port_name}$i symbolsPerBeat $num_symbols
		set_interface_property ${port_name}$i ASSOCIATED_CLOCK $assoc_clock$clock_index

		add_interface_port ${port_name}$i ${port_name}$i data $port_dir $fragment_width
		set frag_base [expr {$i * $fragment_width}]
		set frag_top [expr {$i * $fragment_width + $fragment_width - 1}]
		
		for {set w 0} {$w < $fragment_width} {incr w} {
			lappend port_temp ${port_name}@[expr $frag_base + $w]
		}
			
		set port_flipped [lrange $port_temp $frag_base $frag_top]
		set_port_property ${port_name}$i FRAGMENT_LIST  $port_flipped
		set_port_property ${port_name}$i VHDL_TYPE STD_LOGIC_VECTOR
	}
}


# +----------------------------------------------------
# | Declare either native conduit bus or split streams
# | 
proc low_latency_add_dynamic_conduit_or_stream { port_name port_dir width bits_per_symbol tags split fragments assoc_clock is_bonded } {
	# if split indicated, only split if not terminated
	set terminated [common_get_tagged_property_state $tags TERMINATION 0 ]

	if {$split == 1 && $terminated == 0} {
		low_latency_add_split_stream $port_name $port_dir $width $bits_per_symbol $assoc_clock $is_bonded $fragments
	} else {
		low_latency_add_dynamic_conduit_bus $port_name $port_dir $width $terminated
	}
}
