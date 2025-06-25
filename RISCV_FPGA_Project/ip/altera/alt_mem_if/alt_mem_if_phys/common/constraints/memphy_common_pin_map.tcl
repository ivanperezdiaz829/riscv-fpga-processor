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


#####################################################################
#
# THIS IS AN AUTO-GENERATED FILE!
# -------------------------------
# If you modify this files, all your changes will be lost if you
# regenerate the core!
#
# FILE DESCRIPTION
# ----------------
# This file contains the traversal routines that are used by both
# memphy_pin_assignments.tcl and memphy.sdc scripts. 
#
# These routines are only meant to support these two scripts. 
# Trying to using them in a different context can have unexpected 
# results.

set script_dir [file dirname [info script]]

source [file join $script_dir memphy_parameters.tcl]
load_package sdc_ext

proc memphy_find_all_pins { mystring } {
	set allpins [get_pins -compatibility_mode $mystring ]

	foreach_in_collection pin $allpins {
		set pinname [ get_pin_info -name $pin ]

		puts "$pinname"
	}
}


proc memphy_index_in_collection { col j } {
	set i 0
	foreach_in_collection path $col {
		if {$i == $j} {
			return $path
		}
		set i [expr $i + 1]
	}
	return ""
}


proc memphy_get_clock_to_pin_name_mapping {} {
	set result [list]
	set clocks_collection [get_clocks]
	foreach_in_collection clock $clocks_collection { 
		set clock_name [get_clock_info -name $clock] 
		set clock_target [get_clock_info -targets $clock]
		set first_index [memphy_index_in_collection $clock_target 0]
		set catch_exception [catch {get_pin_info -name $first_index} pin_name]
		if {$catch_exception == 0} {
			lappend result [list $clock_name $pin_name]
		}
	}
	return $result
}              


proc memphy_get_clock_name_from_pin_name { pin_name } {
	set table [memphy_get_clock_to_pin_name_mapping]
	foreach entry $table {
		if {[string compare [lindex [lindex [split $entry] 1] 0] $pin_name] == 0} {
			return [lindex $entry 0]
		}
	}
	return ""
}


proc memphy_get_clock_name_from_pin_name_vseries {pin_name suffix} {
	set name [memphy_get_clock_name_from_pin_name $pin_name]
	if {[string compare -nocase $name ""] == 0} {
		set pll_clock $pin_name
`ifdef IPTCL_HHP_HPS
		regsub {[^\|]+$} $pll_clock {} pll_clock
		set pll_clock "${pll_clock}pll_${suffix}"
`else
		regsub {~PLL_OUTPUT_COUNTER\|divclk$} $pll_clock "" pll_clock
		regsub {_phy$} $pll_clock "" pll_clock
		regsub {[0-9]+$} $pll_clock "" pll_clock
		set pll_clock "${pll_clock}_${suffix}"
`endif
	} else {
		set pll_clock $name
	}
	return $pll_clock
}


proc memphy_get_clock_name_from_pin_name_pre_vseries {pin_name suffix} {
	set name [memphy_get_clock_name_from_pin_name $pin_name]
	if {[string compare -nocase $name ""] == 0} {
		set pll_clock $pin_name
		regsub {upll_memphy\|auto_generated\|pll1\|clk\[[0-9]+\]$} $pll_clock "pll" pll_clock
		set pll_clock "${pll_clock}_${suffix}"
	} else {
		set pll_clock $name
	}
	return $pll_clock
}

proc memphy_get_or_add_clock_vseries_from_virtual_refclk {args} {
	array set opts { /
		-suffix "" /
		-target "" /
		-period "" /
		-phase 0 }

	array set opts $args
	
	set clock_name [memphy_get_clock_name_from_pin_name $opts(-target)]

	
	if {[string compare -nocase $clock_name ""] == 0} {
		set clock_name $opts(-target)
		set suffix $opts(-suffix)
		
		regsub {~PLL_OUTPUT_COUNTER\|divclk$} $clock_name "" clock_name
		regsub {_phy$} $clock_name "" clock_name
		regsub {[0-9]+$} $clock_name "" clock_name
		set clock_name "${clock_name}_${suffix}"
		set re [expr $opts(-period) * $opts(-phase)/360]
		set fe [expr $opts(-period) * $opts(-phase)/360 + $opts(-period)/2]
		
		create_clock \
			-name $clock_name \
			-period $opts(-period) \
			-waveform [ list $re $fe ] \
			$opts(-target)
	}
	
	return $clock_name
}

proc memphy_get_or_add_clock_vseries {args} {
	array set opts { /
		-suffix "" /
		-target "" /
		-source "" /
		-multiply_by 1 /
		-divide_by 1 /
		-phase 0 }

	array set opts $args
	set target $opts(-target)

	set clock_name [memphy_get_clock_name_from_pin_name $opts(-target)]
	
	if {[string compare -nocase $clock_name ""] == 0} {
		set clock_name $opts(-target)
		set suffix $opts(-suffix)
		
		regsub {~PLL_OUTPUT_COUNTER\|divclk$} $clock_name "" clock_name
		regsub {_phy$} $clock_name "" clock_name
		regsub {[0-9]+$} $clock_name "" clock_name
		regsub -all {\\} $clock_name "" clock_name
		set clock_name "${clock_name}_${suffix}"
		set source_name "\{$opts(-source)\}"

		create_generated_clock \
			-name ${clock_name} \
			-source ${source_name} \
			-multiply_by $opts(-multiply_by) \
			-divide_by $opts(-divide_by) \
			-phase $opts(-phase) \
			$target
	}
	
	return $clock_name
}

proc memphy_get_or_add_clock_pre_vseries {args} {
	array set opts { /
		-suffix "" /
		-target "" /
		-source "" /
		-multiply_by 1 /
		-divide_by 1 /
		-phase 0 }

	array set opts $args
	
	set clock_name [memphy_get_clock_name_from_pin_name $opts(-target)]
	
	if {[string compare -nocase $clock_name ""] == 0} {
		set clock_name $opts(-target)
		set suffix $opts(-suffix)
		
		regsub {upll_memphy\|auto_generated\|pll1\|clk\[[0-9]+\]$} $clock_name "pll" clock_name
		set clock_name "${clock_name}_${suffix}"
		
		create_generated_clock \
			-name $clock_name \
			-source $opts(-source) \
			-multiply_by $opts(-multiply_by) \
			-divide_by $opts(-divide_by) \
			-phase $opts(-phase) \
			$opts(-target)
	}
	
	return $clock_name
}


proc memphy_get_source_clock_pin_name {node_name} {

	set nodename ""
	set nodes [get_nodes $node_name]
	memphy_traverse_fanin_up_to_depth [memphy_index_in_collection $nodes 0] memphy_is_node_type_pll_clk clock results_array 10
	if {[array size results_array] == 1} {
		set pin_id [lindex [array names results_array] 0]
		if {[string compare -nocase $pin_id ""] != 0} {
			set nodename [get_node_info -name $pin_id]
		}
	}
	return $nodename
}


proc memphy_find_all_keepers { mystring } {
	set allkeepers [get_keepers $mystring ]

	foreach_in_collection keeper $allkeepers {
		set keepername [ get_node_info -name $keeper ]

		puts "$keepername"
	}
}

proc memphy_round_3dp { x } {
	return [expr { round($x * 1000) / 1000.0  } ]
}

proc memphy_get_timequest_name {hier_name} {
	set sta_name ""
	for {set inst_start [string first ":" $hier_name]} {$inst_start != -1} {} {
		incr inst_start
		set inst_end [string first "|" $hier_name $inst_start]
		if {$inst_end == -1} {
			append sta_name [string range $hier_name $inst_start end]
			set inst_start -1
		} else {
			append sta_name [string range $hier_name $inst_start $inst_end]
			set inst_start [string first ":" $hier_name $inst_end]
		}
	}
	return $sta_name
}

proc memphy_are_entity_names_on { } {
	set entity_names_on 1


	return [set_project_mode -is_show_entity]	
}

proc memphy_get_core_instance_list {corename} {
	set full_instance_list [memphy_get_core_full_instance_list $corename]
	set instance_list [list]

	foreach inst $full_instance_list {
		set sta_name [memphy_get_timequest_name $inst]
		if {[lsearch $instance_list [escape_brackets $sta_name]] == -1} {
			lappend instance_list $sta_name
		}
	}
	return $instance_list
}

proc memphy_get_core_full_instance_list {corename} {
	set allkeepers [get_keepers * ]

	set_project_mode -always_show_entity_name on

	set instance_list [list]

	set inst_regexp {(^.*}
	append inst_regexp {:[A-Za-z0-9\.\\_\[\]\-\$():]+)\|}
	append inst_regexp ${corename}
	append inst_regexp {:[A-Za-z0-9\.\\_\[\]\-\$():]+\|}
	`ifdef IPTCL_HARD_PHY
	append inst_regexp "${corename}_acv_hard_memphy"
	`else
	append inst_regexp "${corename}_memphy"
	`endif
	append inst_regexp {:umemphy}

	foreach_in_collection keeper $allkeepers {
		set name [ get_node_info -name $keeper ]

		if {[regexp -- $inst_regexp $name -> hier_name] == 1} {
			if {[lsearch $instance_list [escape_brackets $hier_name]] == -1} {
				lappend instance_list $hier_name
			}
		}
	}

	set_project_mode -always_show_entity_name qsf

	if {[ llength $instance_list ] == 0} {
		post_message -type error "The auto-constraining script was not able to detect any instance for core < $corename >"
		post_message -type error "Verify the following:"
      post_message -type error " The core < $corename > is instantiated within another component (wrapper)"
		post_message -type error " The core is not the top-level of the project"
		post_message -type error " The memory interface pins are exported to the top-level of the project"
	}

	return $instance_list
}


proc memphy_traverse_fanin_up_to_depth { node_id match_command edge_type results_array_name depth} {
	upvar 1 $results_array_name results

	if {$depth < 0} {
		error "Internal error: Bad timing netlist search depth"
	}
	set fanin_edges [get_node_info -${edge_type}_edges $node_id]
	set number_of_fanin_edges [llength $fanin_edges]
	for {set i 0} {$i != $number_of_fanin_edges} {incr i} {
		set fanin_edge [lindex $fanin_edges $i]
		set fanin_id [get_edge_info -src $fanin_edge]
		if {$match_command == "" || [eval $match_command $fanin_id] != 0} {
			set results($fanin_id) 1
		} elseif {$depth == 0} {
		} else {
			memphy_traverse_fanin_up_to_depth $fanin_id $match_command $edge_type results [expr {$depth - 1}]
		}
	}
}
`ifdef IPTCL_FRACTIONAL_PLL
proc memphy_is_node_type_pll_inclk { node_id } {
	set cell_id [get_node_info -cell $node_id]
	
	if {$cell_id == ""} {
		set result 0
	} else {
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "FRACTIONAL_PLL"} {
			set node_name [get_node_info -name $node_id]
			set fanin_edges [get_node_info -clock_edges $node_id]
			if {([string match "*|refclkin" $node_name] || [string match "*|refclkin\\\[0\\\]" $node_name]) && [llength $fanin_edges] > 0} {
				set result 1
			} else {
				set result 0
			}
		} elseif {$atom_type == "HPS_SDRAM_PLL"} {
			set node_name [get_node_info -name $node_id]
			set fanin_edges [get_node_info -clock_edges $node_id]
			if {[string match "*|ref_clk" $node_name] && [llength $fanin_edges] > 0} {
				set result 1
			} else {
				set result 0
			}
		} elseif {$atom_type == "PLL"} {
			set node_name [get_node_info -name $node_id]
			set fanin_edges [get_node_info -clock_edges $node_id]
			if {([string match "*|refclk" $node_name] || [string match "*|refclk\\\[0\\\]" $node_name]) && [llength $fanin_edges] > 0} {
				set result 1
			} else {
				set result 0
			}
		} else {
			set result 0
		}
	}
	return $result
}
`else
proc memphy_is_node_type_pll_inclk { node_id } {
	set cell_id [get_node_info -cell $node_id]
	
	if {$cell_id == ""} {
		set result 0
	} else {
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "PLL"} {
			set node_name [get_node_info -name $node_id]
			set fanin_edges [get_node_info -clock_edges $node_id]
			if {([string match "*|inclk" $node_name] || [string match "*|inclk\\\[0\\\]" $node_name]) && [llength $fanin_edges] > 0} {
				set result 1
			} else {
				set result 0
			}
		} else {
			set result 0
		}
	}
	return $result
}
`endif

proc memphy_is_node_type_pin { node_id } {
	set node_type [get_node_info -type $node_id]
	if {$node_type == "port"} {
		set result 1
	} else {
		set result 0
	}
	return $result
}

proc memphy_get_input_clk_id { pll_output_node_id } {
	if {[memphy_is_node_type_pll_clk $pll_output_node_id]} {
		array set results_array [list]
`ifdef IPTCL_FRACTIONAL_PLL
		memphy_traverse_fanin_up_to_depth $pll_output_node_id memphy_is_node_type_pll_inclk clock results_array 2
`else
		memphy_traverse_fanin_up_to_depth $pll_output_node_id memphy_is_node_type_pll_inclk clock results_array 1
`endif
		if {[array size results_array] == 1} {
			# Found PLL inclk, now find the input pin
			set pll_inclk_id [lindex [array names results_array] 0]
`ifdef IPTCL_HHP_HPS
			set result [get_node_info -name $pll_inclk_id]
`else
			array unset results_array
			# If fed by a pin, it should be fed by a dedicated input pin,
			# and not a global clock network.  Limit the search depth to
			# prevent finding pins fed by global clock (only allow io_ibuf pins)
`ifdef IPTCL_FRACTIONAL_PLL
			memphy_traverse_fanin_up_to_depth $pll_inclk_id memphy_is_node_type_pin clock results_array 5
`else			
			memphy_traverse_fanin_up_to_depth $pll_inclk_id memphy_is_node_type_pin clock results_array 3
`endif
			if {[array size results_array] == 1} {
				# Fed by a dedicated input pin
				set pin_id [lindex [array names results_array] 0]
				set result $pin_id
			} else {
				memphy_traverse_fanin_up_to_depth $pll_inclk_id memphy_is_node_type_pll_clk clock pll_clk_results_array 1
				memphy_traverse_fanin_up_to_depth $pll_inclk_id memphy_is_node_type_pll_clk clock pll_clk_results_array2 2
				if {[array size pll_clk_results_array] == 1} {
					#  Fed by a neighboring PLL via cascade path.
					#  Should be okay as long as that PLL has its input clock
					#  fed by a dedicated input.  If there isn't, TimeQuest will give its own warning about undefined clocks.
					set source_pll_clk_id [lindex [array names pll_clk_results_array] 0]
					set source_pll_clk [get_node_info -name $source_pll_clk_id]
					set result [memphy_get_input_clk_id $source_pll_clk_id]
					if {$result != -1} {
						post_message -type info "Please ensure source clock is defined for PLL with output $source_pll_clk"
					} else {
						#  Fed from core
						post_message -type critical_warning "PLL clock $source_pll_clk not driven by a dedicated clock pin.  To ensure minimum jitter on memory interface clock outputs, the PLL clock source should be a dedicated PLL input clock pin. Timing analyses may not be valid."
					}
					
				} elseif {[array size pll_clk_results_array2] == 1} {
					#  Fed by a neighboring PLL via global clocks
					#  This is not ok
					set source_pll_clk_id [lindex [array names pll_clk_results_array2] 0]
					set source_pll_clk [get_node_info -name $source_pll_clk_id]
					post_message -type critical_warning "PLL clock [get_node_info -name $pll_output_node_id] not driven by a dedicated clock pin or neighboring PLL source.  To ensure minimum jitter on memory interface clock outputs, the PLL clock source should be a dedicated PLL input clock pin or an output of the neighboring PLL, and not go through a global clock network. Timing analyses may not be valid."
					set result [memphy_get_input_clk_id $source_pll_clk_id]
				
				} else {
					#  If you got here it's because there's a buffer between the PLL input and the PIN. Issue a warning
					#  but keep searching for the pin anyways, otherwise all the timing constraining scripts will
					#  crash
					post_message -type critical_warning "PLL clock [get_node_info -name $pll_output_node_id] not driven by a dedicated clock pin or neighboring PLL source.  To ensure minimum jitter on memory interface clock outputs, the PLL clock source should be a dedicated PLL input clock pin or an output of the neighboring PLL. Timing analyses may not be valid."
					memphy_traverse_fanin_up_to_depth $pll_inclk_id memphy_is_node_type_pin clock results_array 9
					if {[array size results_array] == 1} {
						set pin_id [lindex [array names results_array] 0]
						set result $pin_id
					} else {
						post_message -type critical_warning "Could not find PLL clock for [get_node_info -name $pll_output_node_id]"
						set result -1
					}
				}
			}
`endif // IPTCL_HHP_HPS
		} else {
			post_message -type critical_warning "Could not find PLL clock for [get_node_info -name $pll_output_node_id]"
			set result -1
		}
	} else {
		error "Internal error: memphy_get_input_clk_id only works on PLL output clocks"
	}
	return $result
}

`ifdef IPTCL_FRACTIONAL_PLL
proc memphy_is_node_type_pll_clk { node_id } {
	set cell_id [get_node_info -cell $node_id]
	
	if {$cell_id == ""} {
		set result 0
	} else {
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "PLL_OUTPUT_COUNTER"} {
			set node_name [get_node_info -name $node_id]
			if {[string match "*|pll*~PLL_OUTPUT_COUNTER*|divclk" $node_name]} {
				set result 1
			} else {
				set result 0
			}
		} elseif {$atom_type == "HPS_SDRAM_PLL"} {
			set node_name [get_node_info -name $node_id]
			if {[string match "*|*pll|*_clk" $node_name]} {
				set result 1
			} else {
				set result 0
			}
		} elseif {$atom_type == "PLL"} {
			set node_name [get_node_info -name $node_id]
			if {[string match "*|pll*|divclk" $node_name]} {
				set result 1
			} else {
				set result 0
			}
		} else {
			set result 0
		}
	}
	return $result
}
`else
proc memphy_is_node_type_pll_clk { node_id } {
	set cell_id [get_node_info -cell $node_id]
	
	if {$cell_id == ""} {
		set result 0
	} else {	
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "PLL"} {
			set node_name [get_node_info -name $node_id]
			if {[string match "*|clk\\\[*\\\]" $node_name]} {
				set result 1
			} else {
				set result 0
			}
		} else {
			set result 0
		}
	}
	return $result
}
`endif

proc memphy_get_pll_clock { dest_id_list node_type clock_id_name search_depth} {
	if {$clock_id_name != ""} {
		upvar 1 $clock_id_name clock_id
	}
	set clock_id -1

	array set clk_array [list]
	foreach node_id $dest_id_list {
		memphy_traverse_fanin_up_to_depth $node_id memphy_is_node_type_pll_clk clock clk_array $search_depth
	}
	if {[array size clk_array] == 1} {
		set clock_id [lindex [array names clk_array] 0]
		set clk [get_node_info -name $clock_id]
	} elseif {[array size clk_array] > 1} {
		puts "Found more than 1 clock driving the $node_type"
		set clk ""
	} else {
		set clk ""
	}

	return $clk
}

proc memphy_get_pll_clock_name { clock_id } {
	set clock_name [get_node_info -name $clock_id]

	return $clock_name
}

proc memphy_get_pll_clock_name_for_acf { clock_id pll_output_wire_name } {
	set clock_name [get_node_info -name $clock_id]
`ifdef IPTCL_FRACTIONAL_PLL
	regexp {(.*)\|pll\d+\~PLL_OUTPUT_COUNTER} $clock_name matched clock_name
	regexp {(.*)\|pll\d+_phy\~PLL_OUTPUT_COUNTER} $clock_name matched clock_name
	set clock_name "$clock_name|$pll_output_wire_name"
`else
	set lp0 [string last "|" $clock_name]
	set lp1 [string last "|" $clock_name [expr $lp0 - 1]]
	set clock_name [string replace $clock_name $lp1 $lp0 "|"]
`endif
	return $clock_name
}

`ifdef IPTCL_FRACTIONAL_PLL
proc memphy_get_output_clock_id { ddio_output_pin_list pin_type msg_list_name {max_search_depth 20} } {
`else
proc memphy_get_output_clock_id { ddio_output_pin_list pin_type msg_list_name {max_search_depth 13} } {
`endif
	upvar 1 $msg_list_name msg_list
	set output_clock_id -1
	
	set output_id_list [list]
	set pin_collection [get_keepers -no_duplicates $ddio_output_pin_list]
	if {[get_collection_size $pin_collection] == [llength $ddio_output_pin_list]} {
		foreach_in_collection id $pin_collection {
			lappend output_id_list $id
		}
	} elseif {[get_collection_size $pin_collection] == 0} {
		lappend msg_list "warning" "Could not find any $pin_type pins"
	} else {
		lappend msg_list "warning" "Could not find all $pin_type pins"
	}
	memphy_get_pll_clock $output_id_list $pin_type output_clock_id $max_search_depth
	return $output_clock_id
}

proc memphy_get_output_clock_id2 { ddio_output_pin_list pin_type msg_list_name {max_search_depth 20} } {
	upvar 1 $msg_list_name msg_list
	set output_clock_id -1
	
	set output_id_list [list]
	set pin_collection [get_pins -no_duplicates $ddio_output_pin_list]
	if {[get_collection_size $pin_collection] == [llength $ddio_output_pin_list]} {
		foreach_in_collection id $pin_collection {
			lappend output_id_list $id
		}
	} elseif {[get_collection_size $pin_collection] == 0} {
		lappend msg_list "warning" "Could not find any $pin_type pins"
	} else {
		lappend msg_list "warning" "Could not find all $pin_type pins"
	}
	memphy_get_pll_clock $output_id_list $pin_type output_clock_id $max_search_depth
	return $output_clock_id
}

proc memphy_is_node_type_clkbuf { node_id } {
	set cell_id [get_node_info -cell $node_id]
	if {$cell_id == ""} {
		set result 0
	} else {
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "CLKBUF" || $atom_type == "PHY_CLKBUF"} {
			set result 1
		} else {
			set result 0
		}
	}
	return $result
}

proc memphy_get_clkbuf_clock { dest_id_list node_type clock_id_name search_depth} {
	if {$clock_id_name != ""} {
		upvar 1 $clock_id_name clock_id
	}
	set clock_id -1

	array set clk_array [list]
	foreach node_id $dest_id_list {
		memphy_traverse_fanin_up_to_depth $node_id memphy_is_node_type_clkbuf clock clk_array $search_depth
	}
	if {[array size clk_array] == 1} {
		set clock_id [lindex [array names clk_array] 0]
		set clk [get_node_info -name $clock_id]
	} elseif {[array size clk_array] > 1} {
		set clk ""
	} else {
		set clk ""
	}

	return $clk
}

`ifdef IPTCL_FRACTIONAL_PLL
proc memphy_get_output_clock_clkbuf_id { ddio_output_pin_list pin_type msg_list_name {max_search_depth 20} } {
`else
proc memphy_get_output_clock_clkbuf_id { ddio_output_pin_list pin_type msg_list_name {max_search_depth 13} } {
`endif
	upvar 1 $msg_list_name msg_list
	set output_clock_id -1
	
	set output_id_list [list]
	set pin_collection [get_keepers -no_duplicates $ddio_output_pin_list]
	if {[get_collection_size $pin_collection] == [llength $ddio_output_pin_list]} {
		foreach_in_collection id $pin_collection {
			lappend output_id_list $id
		}
	} elseif {[get_collection_size $pin_collection] == 0} {
		lappend msg_list "warning" "Could not find any $pin_type pins"
	} else {
		lappend msg_list "warning" "Could not find all $pin_type pins"
	}
	memphy_get_clkbuf_clock $output_id_list $pin_type output_clock_id $max_search_depth
	return $output_clock_id
}


proc memphy_is_node_type_clk_phase_select { node_id } {
	set cell_id [get_node_info -cell $node_id]
	if {$cell_id == ""} {
		set result 0
	} else {
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "CLK_PHASE_SELECT"} {
			set result 1
		} else {
			set result 0
		}
	}
	return $result
}

proc memphy_get_clk_phase_select_clock { dest_id_list node_type clock_id_name search_depth} {
	if {$clock_id_name != ""} {
		upvar 1 $clock_id_name clock_id
	}
	set clock_id -1

	array set clk_array [list]
	foreach node_id $dest_id_list {
		memphy_traverse_fanin_up_to_depth $node_id memphy_is_node_type_clk_phase_select clock clk_array $search_depth
	}
	if {[array size clk_array] == 1} {
		set clock_id [lindex [array names clk_array] 0]
		set clk [get_node_info -name $clock_id]
	} elseif {[array size clk_array] > 1} {
		set clk ""
	} else {
		set clk ""
	}

	return $clk
}

proc memphy_get_output_clock_clk_phase_select_id { ddio_output_pin_list pin_type msg_list_name {max_search_depth 20} } {
	upvar 1 $msg_list_name msg_list
	set output_clock_id -1
	
	set output_id_list [list]
	set pin_collection [get_keepers -no_duplicates $ddio_output_pin_list]
	if {[get_collection_size $pin_collection] == [llength $ddio_output_pin_list]} {
		foreach_in_collection id $pin_collection {
			lappend output_id_list $id
		}
	} elseif {[get_collection_size $pin_collection] == 0} {
		lappend msg_list "warning" "Could not find any $pin_type pins"
	} else {
		lappend msg_list "warning" "Could not find all $pin_type pins"
	}
	memphy_get_clk_phase_select_clock $output_id_list $pin_type output_clock_id $max_search_depth
	return $output_clock_id
}

proc post_sdc_message {msg_type msg} {
	if { $::TimeQuestInfo(nameofexecutable) != "quartus_fit"} {
		post_message -type $msg_type $msg
	}
}

proc memphy_get_names_in_collection { col } {
	set res [list]
	foreach_in_collection node $col {
		lappend res [ get_node_info -name $node ]
	}
	return $res
}

proc memphy_static_map_expand_list { FH listname pinname } {
	upvar $listname local_list

	puts $FH ""
	puts $FH "   # $pinname"
	puts $FH "   set pins($pinname) \[ list \]"
	foreach pin $local_list($pinname) {
		puts $FH "   lappend pins($pinname) $pin"
	}
}

proc memphy_static_map_expand_list_of_list { FH listname pinname } {
	upvar $listname local_list

	puts $FH ""
	puts $FH "   # $pinname"
	puts $FH "   set pins($pinname) \[ list \]"
	set count_groups 0
	foreach sublist $local_list($pinname) {
		puts $FH ""
		puts $FH "   # GROUP - ${count_groups}"
		puts $FH "   set group_${count_groups} \[ list \]"
		foreach pin $sublist {
			puts $FH "   lappend group_${count_groups} $pin"
		}
		puts $FH ""
		puts $FH "   lappend pins($pinname) \$group_${count_groups}"

		incr count_groups
	}
}

proc memphy_static_map_expand_string { FH stringname pinname } {
	upvar $stringname local_string

	puts $FH ""
	puts $FH "   # $pinname"
	puts $FH "   set pins($pinname) $local_string($pinname)"
}

proc memphy_format_3dp { x } {
	return [format %.3f $x]
}

proc memphy_get_colours { x y } {

	set fcolour [list "black"]
	if {$x < 0} {
		lappend fcolour "red"
	} else {
		lappend fcolour "blue"
	}
	if {$y < 0} {
		lappend fcolour "red"
	} else {
		lappend fcolour "blue"
	}
	
	return $fcolour
}

proc min { a b } {
	if { $a == "" } { 
		return $b
	} elseif { $a < $b } {
		return $a
	} else {
		return $b
	}
}

proc max { a b } {
	if { $a == "" } { 
		return $b
	} elseif { $a > $b } {
		return $a
	} else {
		return $b
	}
}

proc memphy_max_in_collection { col attribute } {
	set i 0
	set max 0
	foreach_in_collection path $col {
		if {$i == 0} {
			set max [get_path_info $path -${attribute}]
		} else {
			set temp [get_path_info $path -${attribute}]
			if {$temp > $max} {
				set max $temp
			} 
		}
		set i [expr $i + 1]
	}
	return $max
}

proc memphy_min_in_collection { col attribute } {
	set i 0
	set min 0
	foreach_in_collection path $col {
		if {$i == 0} {
			set min [get_path_info $path -${attribute}]
		} else {
			set temp [get_path_info $path -${attribute}]
			if {$temp < $min} {
				set min $temp
			} 
		}
		set i [expr $i + 1]
	}
	return $min
}

proc memphy_min_in_collection_to_name { col attribute name } {
	set i 0
	set min 0
	foreach_in_collection path $col {
		if {[get_node_info -name [get_path_info $path -to]] == $name} {
			if {$i == 0} {
				set min [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp < $min} {
					set min $temp
				} 
			}
			set i [expr $i + 1]		
		}
	}
	return $min
}

proc memphy_min_in_collection_from_name { col attribute name } {
	set i 0
	set min 0
	foreach_in_collection path $col {
		if {[get_node_info -name [get_path_info $path -from]] == $name} {
			if {$i == 0} {
				set min [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp < $min} {
					set min $temp
				} 
			}
			set i [expr $i + 1]			
		}
	}
	return $min
}

proc memphy_max_in_collection_to_name { col attribute name } {
	set i 0
	set max 0
	foreach_in_collection path $col {
		if {[get_node_info -name [get_path_info $path -to]] == $name} {
			if {$i == 0} {
				set max [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp > $max} {
					set max $temp
				} 
			}
			set i [expr $i + 1]					
		}
	}
	return $max
}

proc memphy_max_in_collection_from_name { col attribute name } {
	set i 0
	set max 0
	foreach_in_collection path $col {
		if {[get_node_info -name [get_path_info $path -from]] == $name} {
			if {$i == 0} {
				set max [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp > $max} {
					set max $temp
				} 
			}
			set i [expr $i + 1]
		}
	}
	return $max
}


proc memphy_min_in_collection_to_name2 { col attribute name } {
	set i 0
	set min 0
	foreach_in_collection path $col {
		if {[regexp $name [get_node_info -name [get_path_info $path -to]]]} {
			if {$i == 0} {
				set min [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp < $min} {
					set min $temp
				} 
			}
			set i [expr $i + 1]		
		}
	}
	return $min
}

proc memphy_min_in_collection_from_name2 { col attribute name } {
	set i 0
	set min 0
	foreach_in_collection path $col {
		if {[regexp $name [get_node_info -name [get_path_info $path -from]]]} {
			if {$i == 0} {
				set min [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp < $min} {
					set min $temp
				} 
			}
			set i [expr $i + 1]
		}
	}
	return $min
}

proc memphy_max_in_collection_to_name2 { col attribute name } {
	set i 0
	set max 0
	foreach_in_collection path $col {
		if {[regexp $name [get_node_info -name [get_path_info $path -to]]]} {
			if {$i == 0} {
				set max [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp > $max} {
					set max $temp
				} 
			}
			set i [expr $i + 1]				
		}
	}
	return $max
}

proc memphy_max_in_collection_from_name2 { col attribute name } {
	set i 0
	set max 0
	foreach_in_collection path $col {
		if {[regexp $name [get_node_info -name [get_path_info $path -from]]]} {
			if {$i == 0} {
				set max [get_path_info $path -${attribute}]
			} else {
				set temp [get_path_info $path -${attribute}]
				if {$temp > $max} {
					set max $temp
				} 
			}
			set i [expr $i + 1]
		}
	}
	return $max
}


proc memphy_get_max_clock_path_delay_through_clock_node {from through to} {
	set init 0
	set max_delay 0
	set paths [get_path -rise_from $through -rise_to $to]
	foreach_in_collection path1 $paths {
		set delay [get_path_info $path1 -arrival_time]
		set clock_node [get_node_info -name [get_path_info $path1 -from]]
				
		set paths2 [get_path -rise_from $from -rise_to $clock_node]
		foreach_in_collection path2 $paths2 {
			set total_delay [expr $delay + [get_path_info $path2 -arrival_time]]
			if {$init == 0 || $total_delay > $max_delay} {
				set init 1
				set max_delay $total_delay
			}
		}
	}
	return $max_delay
}

proc memphy_get_min_clock_path_delay_through_clock_node {from through to} {
	set init 0
	set min_delay 0
	set paths [get_path -rise_from $through -rise_to $to -min_path]
	foreach_in_collection path1 $paths {
		set delay [get_path_info $path1 -arrival_time]
		set clock_node [get_node_info -name [get_path_info $path1 -from]]

		set paths2 [get_path -rise_from $from -rise_to $clock_node -min_path]
		foreach_in_collection path2 $paths2 {
			set total_delay [expr $delay + [get_path_info $path2 -arrival_time]]
			if {$init == 0 || $total_delay < $min_delay} {
				set init 1
				set min_delay $total_delay
			}
		}
	}
	return $min_delay
}

proc memphy_get_model_corner {} {

	set operating_conditions [get_operating_conditions]
	set return_value [list]
	if {[regexp {^([0-9])_H([0-9])_([a-z]+)_([a-z0-9_\-]+)} $operating_conditions matched speedgrade transceiver model corner]} {

	} elseif {[regexp {^([A-Z0-9]+)_([a-z]+)_([a-z0-9_\-]+)} $operating_conditions matched speedgrade model corner]} {

	}
	regsub {\-} $corner "n" corner
	set return_value [list $model $corner]
	return $return_value
}

proc memphy_get_min_aiot_delay {pinname} {

	set atom_id [get_atom_node_by_name -name $pinname]
	set sin_pin [create_pin_object -atom $atom_id]
	set results [get_simulation_results -pin $sin_pin -aiot]
	
	set rise 0
	set fall 0
	foreach { key value } $results {
		if {$key == "Absolute Rise Delay to Far-end"} {
			set rise $value
		} elseif {$key == "Absolute Fall Delay to Far-end"} {
			set fall $value
		}
	}
	return [min $rise $fall]
}

proc memphy_get_rise_aiot_delay {pinname} {

	set atom_id [get_atom_node_by_name -name $pinname]
	set sin_pin [create_pin_object -atom $atom_id]
	set results [get_simulation_results -pin $sin_pin -aiot]
	
	set rise 0
	foreach { key value } $results {
            if {$key == "Absolute Rise Delay to Far-end"} {
               set rise $value
            }
	}
	return $rise
}

proc memphy_get_fall_aiot_delay {pinname} {

	set atom_id [get_atom_node_by_name -name $pinname]
	set sin_pin [create_pin_object -atom $atom_id]
	set results [get_simulation_results -pin $sin_pin -aiot]
	
	set fall 0
	foreach { key value } $results {
            if {$key == "Absolute Fall Delay to Far-end"} {
               set fall $value
            }
	}
	return $fall
}


proc memphy_get_aiot_attr {pinname attr} {

	set atom_id [get_atom_node_by_name -name $pinname]
	set sin_pin [create_pin_object -atom $atom_id]
	set results [get_simulation_results -pin $sin_pin -aiot]
	
	set value 0
	foreach { key value } $results {
		if {$key == $attr} {
			return $value
		} 
	}
	return $value
}

proc memphy_get_pll_phase_shift {output_counter_name} {
	load_package atoms
	read_atom_netlist
	set phase_shift ""
	
	# Remove possible "|divclk" at the end of the name
	regsub {\|divclk$} $output_counter_name "" output_counter_name

	# Get all PLL output counters
	set pll_output_counter_atoms [get_atom_nodes -type PLL_OUTPUT_COUNTER]
	
	# Go through the output counters and find the one that matches the above and return the phase
	foreach_in_collection atom $pll_output_counter_atoms { 
		set name [get_atom_node_info -key name -node $atom] 
		regsub {^[^\:]+\:} $name "" name
		regsub -all {\|[^\:]+\:} $name "|" name
		
		# If the name matches return the phase shift
		if {$name == $output_counter_name} {
			set phase_shift [get_atom_node_info -key TIME_PHASE_SHIFT -node $atom]
			regsub { ps} $phase_shift "" phase_shift
			break
		}
	}
	return $phase_shift
}

# ----------------------------------------------------------------
#
proc memphy_get_io_standard {target_pin} {
#
# Description: Gets the I/O standard of the given memory interface pin
#              This function assumes the fitter has already completed and the
#              compiler report has been loaded.
#
# ----------------------------------------------------------------
	# Look through the pin report
	set io_std [memphy_get_fitter_report_pin_info $target_pin "I/O Standard" -1]
	if {$io_std == ""} {
		return "UNKNOWN"
	}
	set result ""
	switch -exact -- $io_std {
		"SSTL-2 Class I" {set result "SSTL_2_I"}
		"Differential 2.5-V SSTL Class I" {set result "DIFF_SSTL_2_I"}
		"SSTL-2 Class II" {set result "SSTL_2_II"}
		"Differential 2.5-V SSTL Class II" {set result "DIFF_SSTL_2_II"}
		"SSTL-18 Class I" {set result "SSTL_18_I"}
		"Differential 1.8-V SSTL Class I" {set result "DIFF_SSTL_18_I"}
		"SSTL-18 Class II" {set result "SSTL_18_II"}
		"Differential 1.8-V SSTL Class II" {set result "DIFF_SSTL_18_II"}
		"SSTL-15 Class I" {set result "SSTL_15_I"}
		"Differential 1.5-V SSTL Class I" {set result "DIFF_SSTL_15_I"}
		"SSTL-15 Class II" {set result "SSTL_15_II"}
		"Differential 1.5-V SSTL Class II" {set result "DIFF_SSTL_15_II"}
		"1.8-V HSTL Class I" {set result "HSTL_18_I"}
		"Differential 1.8-V HSTL Class I" {set result "DIFF_HSTL_18_I"}
		"1.8-V HSTL Class II" {set result "HSTL_18_II"}
		"Differential 1.8-V HSTL Class II" {set result "DIFF_HSTL_18_II"}
		"1.5-V HSTL Class I" {set result "HSTL_I"}
		"Differential 1.5-V HSTL Class I" {set result "DIFF_HSTL"}
		"1.5-V HSTL Class II" {set result "HSTL_II"}
		"Differential 1.5-V HSTL Class II" {set result "DIFF_HSTL_II"}
		"1.2-V HSTL Class I" {set result "SSTL_125"}
		"Differential 1.2-V HSTL Class I" {set result "DIFF_SSTL_125"}
		"1.2-V HSTL Class II" {set result "SSTL_125"}
		"Differential 1.2-V HSTL Class II" {set result "DIFF_SSTL_125"}
		"SSTL-15" {set result "SSTL_15"}
		"Differential 1.5-V SSTL" {set result "DIFF_SSTL_15"}
		"SSTL-135" {set result "SSTL_135"}
		"Differential 1.35-V SSTL" {set result "DIFF_SSTL_135"}
		"SSTL-125" {set result "SSTL_125"}
		"Differential 1.25-V SSTL" {set result "DIFF_SSTL_125"}
		"SSTL-12" {set result "DIFF_SSTL_125"}
		"Differential 1.2-V HSUL" {set result "DIFF_HSUL_12"}
		default {
			post_message -type error "Found unsupported Memory I/O standard $io_std on pin $target_pin"
			set result "UNKNOWN"
		}
	}
	return $result
}

# Routine to find the termination pins
proc memphy_get_rzq_pins { instname all_rzq_pins } {
	upvar $all_rzq_pins rzqpins
	load_package atoms
	read_atom_netlist
	set rzq_pins [ list ]
	set entity_names_on [ memphy_are_entity_names_on ]
	
	# Get all termination atoms, to which rzqpin should be attached
	set_project_mode -always_show_entity_name off
	set instance ${instname}*
	set atoms [get_atom_nodes -type TERMINATION -matching [escape_brackets $instance] ]
	post_message -type info "Number of Termination Atoms are [get_collection_size $atoms]"
	foreach_in_collection term_atom $atoms { 
		set rzq_pin ""
		set atom $term_atom
		set term_atom_name [get_atom_node_info -key name -node $term_atom] 
		post_message -type info "Found Termination Atom $term_atom_name"
		set type [get_atom_node_info -key type -node $term_atom] 
		
		# Check until you traverse to an IO_PAD for the RZQ Pin
		while { ![regexp IO_PAD $type ] } { 
			set name [get_atom_node_info -key name -node $atom] 
			set iterms [get_atom_iports -node $atom]
			set iterm_size [llength $iterms]
			# Check for Multiple Inputs
			if { $iterm_size > 1 } {
				post_message -type error " Multiple inputs to a node:$name attached to a  Termination_Atom:$term_atom_name "
				break
			
			}
			
			foreach iterm $iterms { 
				set fanin	[get_atom_port_info -node $atom -type iport -port_id $iterm -key fanin]
				set atom [lindex $fanin 0]
				set type [get_atom_node_info -key type -node $atom]
				set rzq_pin [get_atom_node_info -key name -node $atom]
			}		
		}
			
		lappend rzq_pins [ join $rzq_pin ]
	}

	set_project_mode -always_show_entity_name qsf
	set rzqpins $rzq_pins
}
