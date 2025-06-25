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
# This file contains the traversal routines that are used by
# alterapll.sdc scripts. 
#
# These routines are only meant to support the SDC. 
# Trying to using them in a different context can have unexpected 
# results.

set script_dir [file dirname [info script]]

source [file join $script_dir alterapll_parameters.tcl]

# ----------------------------------------------------------------
#
proc post_sdc_message {msg_type msg} {
#
# Description: Posts a message in TimeQuest, but not in Fitter
#              The SDC is read mutliple times during compilation, so we'll wait
#              until final TimeQuest timing analysis to display messages
#
# ----------------------------------------------------------------
	if { $::TimeQuestInfo(nameofexecutable) != "quartus_fit"} {
		post_message -type $msg_type $msg
	}
}

# ----------------------------------------------------------------
#
proc alterapll_are_entity_names_on { } {
#
# Description: Determines if the entity names option is on
#
# ----------------------------------------------------------------
	set entity_names_on 1
	return [set_project_mode -is_show_entity]	
}

# ----------------------------------------------------------------
#
proc alterapll_initialize_pll_db { pll_db_par } {
#
# Description: Gets the instances of this particular PLL IP and creates the pin
#              cache
#
# ----------------------------------------------------------------
	upvar $pll_db_par local_pll_db

	global ::GLOBAL_corename

	post_sdc_message info "Initializing PLL database for CORE $::GLOBAL_corename"
	set instance_list [alterapll_get_core_instance_list $::GLOBAL_corename]

	foreach instname $instance_list {
		post_sdc_message info "Finding port-to-pin mapping for CORE: $::GLOBAL_corename INSTANCE: $instname"

		alterapll_get_pll_pins $instname allpins

		set local_pll_db($instname) [ array get allpins ]
	}
}

# ----------------------------------------------------------------
#
proc alterapll_get_core_instance_list {corename} {
#
# Description: Converts node names from one style to another style
#
# ----------------------------------------------------------------
	set full_instance_list [alterapll_get_core_full_instance_list $corename]
	set instance_list [list]

	foreach inst $full_instance_list {
		if {[lsearch $instance_list [escape_brackets $inst]] == -1} {
			lappend instance_list $inst
		}
	}
	return $instance_list
}

# ----------------------------------------------------------------
#
proc alterapll_get_core_full_instance_list {corename} {
#
# Description: Finds the instances of the particular IP by searching through the cells
#
# ----------------------------------------------------------------

	set allcells [get_cells -compatibility_mode * ]

	set_project_mode -always_show_entity_name on

	set instance_list [list]

	set inst_regexp "^(.*$corename)\|altera_pll_i"

	foreach_in_collection cell $allcells {
		set atom_type [get_cell_info -atom_type $cell]
		if {$atom_type == "IOPLL"} {
			set name [ get_cell_info -name $cell ]
			if {[regexp -- $inst_regexp $name -> hier_name] == 1} {
				if {[lsearch $instance_list [escape_brackets $hier_name]] == -1} {
					lappend instance_list $hier_name
				}
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


# ----------------------------------------------------------------
#
proc alterapll_get_pll_pins { instname allpins } {
#
# Description: Stores the pins of interest for the instance of the IP
#
# ----------------------------------------------------------------

	# We need to make a local copy of the allpins associative array
	upvar allpins pins
	
	# Set the pattern for the output clocks
	set pll_out_clks_id [list]
	set pll_out_clks    [list]

	set pll_out_clk_pattern ${instname}|outclk[*]
	set pin_collection [get_pins -no_duplicates $pll_out_clk_pattern]
	if {[get_collection_size $pin_collection] ==  $::GLOBAL_num_pll_clock} {
		foreach_in_collection id $pin_collection {
			lappend pll_out_clks_id $id
			lappend pll_out_clks [get_node_info -name $id]	
		}
	} elseif {[get_collection_size $pin_collection] < $::GLOBAL_altera_pll_iopll_0002_num_pll_clock} {
		post_message -type "warning" "Could not find all output clk pins for $pll_out_clk_pattern"
	} else {
		post_message -type "warning" "Found more than output clock pin for $pll_out_clk_pattern"
	}

	set pins(pll_out_clks) [join $pll_out_clks] 
	
	# Set the pattern for the reference clock PLL input
	set pins(pll_ref_clk_in) ${instname}|refclk[*]
		
	# Get the node ID for the PLL input
	set pin_collection [get_pins -no_duplicates $pins(pll_ref_clk_in)]
	if {[get_collection_size $pin_collection] == 1} {
		foreach_in_collection id $pin_collection {
			lappend pll_ref_clk_in_id $id
		}
	} elseif {[get_collection_size $pin_collection] == 0} {
		post_message -type "warning" "Could not find any reference clk pins"
	} else {
		post_message -type "warning" "Found more than one reference clk pin"
	}	
	set pins(pll_ref_clk_in) [get_node_info -name $pll_ref_clk_in_id]

	# Now traverse to the source input of the reference clock input (old way)
	#set input_collection [get_fanins $pins(pll_ref_clk_in)]
	#if {[get_collection_size $input_collection] == 1} {
	#	foreach_in_collection id $input_collection {
	#		lappend ref_clk_in_id $id
	#	}
	#} elseif {[get_collection_size $input_collection] == 0} {
	#	post_message -type "warning" "Could not find any reference clk pins"
	#} else {
	#	post_message -type "warning" "Found more than one reference clk pin"
	#}	
	#set pins(ref_clk_in) [get_node_info -name $ref_clk_in_id]	

	# Now traverse to the source input of the reference clock input
	set pll_ref_clock_id [alterapll_get_input_clk_id [lindex $pll_out_clks_id 0]]
	if {$pll_ref_clock_id == -1} {
		post_message -type error "alterapll_pin_map.tcl: Failed to find PLL reference clock"
	} else {
		set pll_ref_clock [get_node_info -name $pll_ref_clock_id]
	}
	set pins(ref_clk_in) $pll_ref_clock

}

# ----------------------------------------------------------------
#
proc alterapll_get_input_clk_id { pll_output_node_id } {
#
# Description: Searches back from the output of the PLL to find the reference clock pin.
#              If the reference clock is fed by an input buffer, it finds that pin, otherwise
#              in cascading modes it will return the immediate reference clock input of the PLL.
#
# ----------------------------------------------------------------
	if {[alterapll_is_node_type_pll_clk $pll_output_node_id]} {
		array set results_array [list]
		alterapll_traverse_fanin_up_to_depth $pll_output_node_id alterapll_is_node_type_pll_inclk clock results_array 3
		if {[array size results_array] == 1} {
			# Found PLL inclk, now find the input pin
			set pll_inclk_id [lindex [array names results_array] 0]
			array unset results_array
			# If fed by a pin, it should be fed by a dedicated input pin,
			# and not a global clock network.  Limit the search depth to
			# prevent finding pins fed by global clock (only allow io_ibuf pins)
			alterapll_traverse_fanin_up_to_depth $pll_inclk_id alterapll_is_node_type_pin clock results_array 5
			if {[array size results_array] == 1} {
				# Fed by a dedicated input pin
				set pin_id [lindex [array names results_array] 0]
				set result $pin_id
			} else {
				alterapll_traverse_fanin_up_to_depth $pll_inclk_id alterapll_is_node_type_pll_clk clock pll_clk_results_array 2
				if {[array size pll_clk_results_array] == 1} {
					#  Fed by a neighbouring PLL via cascade path or global clock path
					set source_pll_clk_id [lindex [array names pll_clk_results_array] 0]
					set source_pll_clk [get_node_info -name $source_pll_clk_id]
					set result $source_pll_clk_id
				} else {
					#  If you got here it's because there's a buffer between the PLL input and the PIN. Issue a warning
					#  but keep searching for the pin anyways, otherwise all the timing constraining scripts will
					#  crash
					alterapll_traverse_fanin_up_to_depth $pll_inclk_id alterapll_is_node_type_pin clock results_array 9
					if {[array size results_array] == 1} {
						set pin_id [lindex [array names results_array] 0]
						set result $pin_id
					} else {
						post_message -type critical_warning "Could not find PLL clock for [get_node_info -name $pll_output_node_id]"
						set result -1
					}
				}
			}
		} else {
			post_message -type critical_warning "Could not find PLL clock for [get_node_info -name $pll_output_node_id]"
			set result -1
		}
	} else {
		post_message -type error "Internal error: alterapll_get_input_clk_id only works on PLL output clocks"
	}
	return $result
}

# ----------------------------------------------------------------
#
proc alterapll_is_node_type_pin { node_id } {
#
# Description: Determines if a node is a top-level port of the FPGA
#
# ----------------------------------------------------------------

	set node_type [get_node_info -type $node_id]
	if {$node_type == "port"} {
		set result 1
	} else {
		set result 0
	}
	return $result
}

# ----------------------------------------------------------------
#
proc alterapll_is_node_type_pll_clk { node_id } {
#
# Description: Determines if a node is an output of a PLL
#
# ----------------------------------------------------------------

	set cell_id [get_node_info -cell $node_id]
	
	if {$cell_id == ""} {
		set result 0
	} else {
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "IOPLL"} {
			set node_name [get_node_info -name $node_id]
			if {[string match "*iopll_inst\|outclk\\\[*\\\]" $node_name]} {
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

# ----------------------------------------------------------------
#
proc alterapll_is_node_type_pll_inclk { node_id } {
#
# Description: Determines if a node is an input of a PLL
#
# ----------------------------------------------------------------

	set cell_id [get_node_info -cell $node_id]
	
	if {$cell_id == ""} {
		set result 0
	} else {
		set atom_type [get_cell_info -atom_type $cell_id]
		if {$atom_type == "IOPLL"} {
			set node_name [get_node_info -name $node_id]
			set fanin_edges [get_node_info -clock_edges $node_id]
			if {([string match "*|refclk\\\[*\\\]" $node_name]) && [llength $fanin_edges] > 0} {
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

# ----------------------------------------------------------------
#
proc alterapll_traverse_fanin_up_to_depth { node_id match_command edge_type results_array_name depth} {
#
# Description: General traversal function up until a depth.  Use a function pointer to decide
#              ending conditions.
#
# ----------------------------------------------------------------

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
			alterapll_traverse_fanin_up_to_depth $fanin_id $match_command $edge_type results [expr {$depth - 1}]
		}
	}
}

# ----------------------------------------------------------------
#
proc alterapll_index_in_collection { col j } {
#
# Description: Returns a particular index in a collection.
#              Analagous to lindex for lists.
#
# ----------------------------------------------------------------

	set i 0
	foreach_in_collection path $col {
		if {$i == $j} {
			return $path
		}
		set i [expr $i + 1]
	}
	return ""
}

# ----------------------------------------------------------------
#
proc alterapll_get_pll_atom_parameters { pll_atoms  } {
#
# Description: Gets the PLL paramaters from the Quartus atom and not 
#              from the IP generated parameters.
#
# ----------------------------------------------------------------

	set pll_atom [alterapll_index_in_collection $pll_atoms 0]
	
	if {[get_atom_node_info -node $pll_atom -key  BOOL_IOPLL_M_CNT_BYPASS_EN] == 1} {
		set mcnt 1
	} else {
		set mcnt [expr [get_atom_node_info -node $pll_atom -key INT_IOPLL_M_CNT_HI_DIV] + [get_atom_node_info -node $pll_atom -key INT_IOPLL_M_CNT_LO_DIV]]
	}
	if {[get_atom_node_info -node $pll_atom -key  BOOL_IOPLL_N_CNT_BYPASS_EN] == 1} {
		set ncnt 1
	} else {
		set ncnt [expr [get_atom_node_info -node $pll_atom -key INT_IOPLL_N_CNT_HI_DIV] + [get_atom_node_info -node $pll_atom -key INT_IOPLL_N_CNT_LO_DIV]]
	}
	
	for { set i 0 } { $i < $::GLOBAL_num_pll_clock } { incr i } {
		set clk_prst [get_atom_node_info -node $pll_atom -key INT_IOPLL_C_CNT_${i}_PRST]
		set clk_ph_mux [get_atom_node_info -node $pll_atom -key INT_IOPLL_C_CNT_${i}_PH_MUX_PRST]

		set clk_duty_cycle [get_atom_node_info -node $pll_atom -key INT_DUTY_CYCLE_$i]
		if {[get_atom_node_info -node $pll_atom -key  BOOL_IOPLL_C_CNT_${i}_BYPASS_EN] == 1} {
			set ccnt 1
		} else {
			set ccnt [expr [get_atom_node_info -node $pll_atom -key INT_IOPLL_C_CNT_${i}_HI_DIV] + [get_atom_node_info -node $pll_atom -key INT_IOPLL_C_CNT_${i}_LO_DIV]]
		}
		
		set clk_mult $mcnt
		set clk_div [expr $ncnt*$ccnt]

		set clk_phase [expr 360 * ($clk_ph_mux  + 8*($clk_prst-1))/(8*$clk_div)]
	
		set ::GLOBAL_pll_mult(${i}) $clk_mult
		set ::GLOBAL_pll_div(${i}) $clk_div
		set ::GLOBAL_pll_phase(${i}) $clk_phase
		set ::GLOBAL_pll_dutycycle(${i}) $clk_duty_cycle
	}		
}
