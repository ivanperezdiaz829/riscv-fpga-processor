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


proc memphy_sort_proc {a b} {
	set idxs [list 1 2 0]
	foreach i $idxs {
		set ai [lindex $a $i]
		set bi [lindex $b $i]
		if {$ai > $bi} {
			return 1
		} elseif { $ai < $bi } {
			return -1
		}
	}
	return 0
}

proc memphy_gcd {p q} {
	set p [expr {abs($p)}]
	set q [expr {abs($q)}]
	while {$q != 0} {
		set r [expr {$p % $q}]
		set p $q
		set q $r
	}
	return $p
}

proc memphy_traverse_atom_path {atom_id atom_oport_id path} {
	# Return list of {atom oterm_id} pairs by tracing the atom netlist starting from the given atom_id through the given path
	# Path consists of list of {atom_type fanin|fanout|end <port_type> <-optional>}
	set result [list]
	if {[llength $path] > 0} {
		set path_point [lindex $path 0]
		set atom_type [lindex $path_point 0]
		set next_direction [lindex $path_point 1]
		set port_type [lindex $path_point 2]
		set atom_optional [lindex $path_point 3]
		if {[get_atom_node_info -key type -node $atom_id] == $atom_type} {
			if {$next_direction == "end"} {
				if {[get_atom_port_info -key type -node $atom_id -port_id $atom_oport_id -type oport] == $port_type} {
					lappend result [list $atom_id $atom_oport_id]
				}
			} elseif {$next_direction == "atom"} {
				lappend result [list $atom_id]
			} elseif {$next_direction == "fanin"} {
				set atom_iport [get_atom_iport_by_type -node $atom_id -type $port_type]
				if {$atom_iport != -1} {
					set iport_fanin [get_atom_port_info -key fanin -node $atom_id -port_id $atom_iport -type iport]
					set source_atom [lindex $iport_fanin 0]
					set source_oterm [lindex $iport_fanin 1]
					set result [memphy_traverse_atom_path $source_atom $source_oterm [lrange $path 1 end]]
				} elseif {$atom_optional == "-optional"} {
					set result [memphy_traverse_atom_path $atom_id $atom_oport_id [lrange $path 1 end]]
				}
			} elseif {$next_direction == "fanout"} {
				set atom_oport [get_atom_oport_by_type -node $atom_id -type $port_type]
				if {$atom_oport != -1} {
					set oport_fanout [get_atom_port_info -key fanout -node $atom_id -port_id $atom_oport -type oport]
					foreach dest $oport_fanout {
						set dest_atom [lindex $dest 0]
						set dest_iterm [lindex $dest 1]
						set fanout_result_list [memphy_traverse_atom_path $dest_atom -1 [lrange $path 1 end]]
						foreach fanout_result $fanout_result_list {
							if {[lsearch $result $fanout_result] == -1} {
								lappend result $fanout_result
							}
						}
					}
				}
			} else {
				error "Unexpected path"
			}
		} elseif {$atom_optional == "-optional"} {
			set result [memphy_traverse_atom_path $atom_id $atom_oport_id [lrange $path 1 end]]
		}
	}
	return $result
}

# Get the fitter name of the PLL output driving the given pin
proc memphy_traverse_to_ddio_out_pll_clock {pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set result ""
	if {$pin != ""} {
		set pin_id [get_atom_node_by_name -name $pin]
`ifdef IPTCL_STRATIXV
		set pin_to_pll_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {DDIO_OUT fanin CLK -optional} {DDIO_OUT fanin CLKHI -optional} {CLK_PHASE_SELECT fanin CLKIN -optional} {LEVELING_DELAY_CHAIN fanin CLKIN -optional} {CLKBUF fanin INCLK -optional} {PLL_OUTPUT_COUNTER end DIVCLK}]
`else
		set pin_to_pll_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {DDIO_OUT fanin CLKHI -optional} {OUTPUT_PHASE_ALIGNMENT fanin CLK -optional} {CLKBUF fanin INCLK -optional} {PLL end CLK}]
`endif
		set pll_id_list [memphy_traverse_atom_path $pin_id -1 $pin_to_pll_path]
		if {[llength $pll_id_list] == 1} {
			set atom_oterm_pair [lindex $pll_id_list 0]
			set result [get_atom_port_info -key name -node [lindex $atom_oterm_pair 0] -port_id [lindex $atom_oterm_pair 1] -type oport]
		} else {
			lappend msg_list "Error: PLL clock not found for $pin"
		}
	}
	return $result
}

`ifdef IPTCL_STRATIXV
proc memphy_traverse_to_leveling_delay_chain {pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set result ""
	if {$pin != ""} {
		set pin_id [get_atom_node_by_name -name $pin]
`ifdef IPTCL_USE_2X_FF
		set pin_to_leveling_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {FF fanin CLK -optional} {CLK_PHASE_SELECT fanin CLKIN -optional} {LEVELING_DELAY_CHAIN end CLKOUT} ]
`else
		set pin_to_leveling_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {DDIO_OUT fanin CLK -optional} {FF fanin CLK -optional} {DDIO_OUT fanin CLKHI -optional} {CLK_PHASE_SELECT fanin CLKIN -optional} {LEVELING_DELAY_CHAIN end CLKOUT} ]
`endif		
		set leveling_id_list [memphy_traverse_atom_path $pin_id -1 $pin_to_leveling_path]
		if {[llength $leveling_id_list] == 1} {
			set atom_oterm_pair [lindex $leveling_id_list 0]
			set result [get_atom_port_info -key name -node [lindex $atom_oterm_pair 0] -port_id [lindex $atom_oterm_pair 1] -type oport]
		} else {
			lappend msg_list "Error: Leveling delay chain not found for $pin"
		}
	}
	return $result
}

proc memphy_traverse_to_clock_phase_select {pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set result ""
	if {$pin != ""} {
		set pin_id [get_atom_node_by_name -name $pin]
`ifdef IPTCL_USE_2X_FF
		set pin_to_leveling_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {FF fanin CLK -optional} {CLK_PHASE_SELECT fanin CLKOUT} ]
`else
		set pin_to_leveling_path [list {IO_PAD fanin PADIN} {IO_OBUF fanin I} {PSEUDO_DIFF_OUT fanin I -optional} {DELAY_CHAIN fanin DATAIN -optional} {DELAY_CHAIN fanin DATAIN -optional} {DDIO_OUT fanin CLK -optional} {FF fanin CLK -optional} {DDIO_OUT fanin CLKHI -optional} {CLK_PHASE_SELECT end CLKOUT}  ]
`endif
		set leveling_id_list [memphy_traverse_atom_path $pin_id -1 $pin_to_leveling_path]
		if {[llength $leveling_id_list] == 1} {
			set atom_oterm_pair [lindex $leveling_id_list 0]
			set result [get_atom_port_info -key name -node [lindex $atom_oterm_pair 0] -port_id [lindex $atom_oterm_pair 1] -type oport]
		} else {
			lappend msg_list "Error: Clock Phase Select not found for $pin"
		}
	}
	return $result
}

`endif

proc memphy_traverse_to_dll {dqs_pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set dqs_pin_id [get_atom_node_by_name -name $dqs_pin]
	set dqs_to_dll_path [list {IO_PAD fanout PADOUT} {IO_IBUF fanout O} {DQS_DELAY_CHAIN fanin DELAYCTRLIN} {DLL end DELAYCTRLOUT}]
	set dll_id_list [memphy_traverse_atom_path $dqs_pin_id -1 $dqs_to_dll_path]
	set result ""
	if {[llength $dll_id_list] == 1} {
		set dll_atom_oterm_pair [lindex $dll_id_list 0]
		set result [get_atom_node_info -key name -node [lindex $dll_atom_oterm_pair 0]]
	} elseif {[llength $dll_id_list] > 1} {
		lappend msg_list "Error: Found more than 1 DLL"
	} else {
		lappend msg_list "Error: DLL not found"
	}
	return $result
}

proc memphy_check_hybrid_interface { inst pins_array_name mem_if_memtype } {
	upvar $pins_array_name pins

	foreach q_group $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}
	set all_dq_pins [ join [ join $q_groups ] ]
	set dm_pins $pins(dm_pins)

	set all_dq_dm_pins [ concat $all_dq_pins $dm_pins ]
	foreach dq_dm_pin $all_dq_dm_pins {
		set io_type [memphy_get_fitter_report_pin_io_type_info $dq_dm_pin]
		if {[string compare -nocase "Column I/O" $io_type] == 0} {
			set io_types("column") 1
		} elseif {[string compare -nocase "Row I/O" $io_type] == 0} {
			set io_types("row") 1
		} else {
			post_message -type warning "Could not determine IO type for pin $dq_dm_pin"
		}
	}

	if {[llength [array names io_types]] == 0} {
		post_message -type warning "Could not determine if memory interface $inst is implemented in hybrid mode. Assuming memory interface is implemented in non-hybrid mode"
		return 0
	} elseif {[llength [array names io_types]] == 1} {
		return 0
	} elseif {[llength [array names io_types]] == 2} {
		return 1
	} else {
		post_message -type error "Internal Error: Found IO types [array names io_types]"
		qexit -error
	}

}

proc memphy_verify_flexible_timing_assumptions { inst pins_array_name mem_if_memtype } {
	return 1
}

proc memphy_verify_high_performance_timing_assumptions { inst pins_array_name mem_if_memtype } {
	upvar $pins_array_name pins

	set num_errors 0
	load_package verify_ddr
	set ck_ckn_pairs [list]
	set failed_assumptions [list]
	if {[llength $pins(ck_pins)] > 0 && [llength $pins(ck_pins)] == [llength $pins(ckn_pins)]} {
		for {set ck_index 0} {$ck_index != [llength $pins(ck_pins)]} {incr ck_index} {
			lappend ck_ckn_pairs [list [lindex $pins(ck_pins) $ck_index] [lindex $pins(ckn_pins) $ck_index]]
		}
	} else {
		incr num_errors
		lappend failed_assumptions "Error: Could not locate same number of CK pins as CK# pins"
	}

	set read_pins_list [list]
	set write_pins_list [list]
	set read_clock_pairs [list]
	set write_clock_pairs [list]
	foreach { dqs } $pins(dqs_pins) { dqsn } $pins(dqsn_pins) { dq_list } $pins(q_groups) {
		lappend read_pins_list [list $dqs $dq_list]
		lappend read_clock_pairs [list $dqs $dqsn]
	}

	foreach { dqs } $pins(dqs_pins) { dqsn } $pins(dqsn_pins) { dm_list } $pins(dm_pins) { dq_list } $pins(q_groups) {
		lappend write_pins_list [list $dqs [concat $dq_list $dm_list]]
		lappend write_clock_pairs [list $dqs $dqsn]
	}

	set all_write_dqs_list $pins(dqs_pins)
	set all_d_list $pins(all_dq_pins)
	if {[llength $pins(q_groups)] == 0} {
		incr num_errors
		lappend failed_assumptions "Error: Could not locate DQS pins"
	}

	if {$num_errors == 0} {
		set msg_list [list]
		set dll_name [memphy_traverse_to_dll $dqs msg_list]
		set clk_to_write_d [memphy_traverse_to_ddio_out_pll_clock [lindex $all_d_list 0] msg_list]
		set clk_to_write_clock [memphy_traverse_to_ddio_out_pll_clock [lindex $all_write_dqs_list 0] msg_list]
		set clk_to_ck_ckn [memphy_traverse_to_ddio_out_pll_clock [lindex $pins(ck_pins) 0] msg_list]
		foreach msg $msg_list {
			set verify_assumptions_exception 1
			incr num_errors
			lappend failed_assumptions $msg
		}
		if {$num_errors == 0} {
			set verify_assumptions_exception 0
			set verify_assumptions_result {0}
			set verify_assumptions_exception [catch {verify_assumptions -uniphy -memory_type $mem_if_memtype \
				-read_pins_list $read_pins_list -write_pins_list $write_pins_list -ck_ckn_pairs $ck_ckn_pairs \
				-clk_to_write_d $clk_to_write_d -clk_to_write_clock $clk_to_write_clock -clk_to_ck_ckn $clk_to_ck_ckn \
				-dll $dll_name -read_clock_pairs $read_clock_pairs -write_clock_pairs $write_clock_pairs} verify_assumptions_result]
			if {$verify_assumptions_exception == 0} {
				incr num_errors [lindex $verify_assumptions_result 0]
				set failed_assumptions [concat $failed_assumptions [lrange $verify_assumptions_result 1 end]]
			}
		}
		if {$verify_assumptions_exception != 0} {
			lappend failed_assumptions "Error: MACRO timing assumptions could not be verified"
			incr num_errors
		}
	}

	if {$num_errors != 0} {
		for {set i 0} {$i != [llength $failed_assumptions]} {incr i} {
			set raw_msg [lindex $failed_assumptions $i]
			if {[regexp {^\W*(Info|Extra Info|Warning|Critical Warning|Error): (.*)$} $raw_msg -- msg_type msg]} {
				regsub " " $msg_type _ msg_type
				if {$msg_type == "Error"} {
					set msg_type "critical_warning"
				}
				post_message -type $msg_type $msg
			} else {
				post_message -type info $raw_msg
			}
		}
		post_message -type critical_warning "Read Capture and Write timing analyses may not be valid due to violated timing model assumptions"
	}

	return [expr $num_errors == 0]
}

# Return a tuple of the tCCS value for a given device
proc memphy_get_tccs { mem_if_memtype dqs_list period args} {
	global TimeQuestInfo
	array set options [list "-write_deskew" "none" "-dll_length" 0 "-config_period" 0 "-ddr3_discrete" 0]
	foreach {option value} $args {
		if {[array names options -exact "$option"] != ""} {
			set options($option) $value
		} else {
			error "ERROR: Unknown get_tccs option $option (with value $value; args are $args)"
		}
	}

	if {$mem_if_memtype == "ddr2"} {
		set options(-write_deskew) "none"
	}
	
	set speedgrade [ get_speedgrade_string ]
	if { ($mem_if_memtype == "ddr3") && ($speedgrade != "2") && ($options(-write_deskew) == "dynamic") } {
		set options(-write_deskew) "static"
	}
	
	if { ($mem_if_memtype == "ddr3") && ($options(-write_deskew) == "none") } {
		set options(-write_deskew) "static"
	}	

	set interface_type [memphy_get_io_interface_type $dqs_list]
	# The tCCS for a VHPAD interface is the same as a HPAD interface
	if {$interface_type == "VHPAD"} {
		set interface_type "HPAD"
	}
	set io_std [memphy_get_io_standard [lindex $dqs_list 0]]
  	set result [list 0 0]
	if {$interface_type != "" && $interface_type != "UNKNOWN" && $io_std != "" && $io_std != "UNKNOWN"} {
		package require ::quartus::ddr_timing_model

		set tccs_params [list IO $interface_type]
		if {($mem_if_memtype == "ddr3") && ($options(-ddr3_discrete) == 1)} {
			lappend tccs_params NONLEVELED
		} elseif {($mem_if_memtype == "ddr3") && ($options(-write_deskew) == "static")} {
			if {$options(-dll_length) == 12} {
				set options(-dll_length) 10
			}
			if {$options(-dll_length) != 0} {
				lappend tccs_params STATIC_DESKEW_$options(-dll_length)
			} else {
				# No DLL length dependency
				lappend tccs_params STATIC_DESKEW
			}
		} elseif {($mem_if_memtype == "ddr3") && ($options(-write_deskew) == "dynamic")} {
			lappend tccs_params DYNAMIC_DESKEW
		}
		if {$options(-ddr3_discrete) == 0 && $options(-write_deskew) != "none"} {
			set mode [memphy_get_deskew_freq_range $tccs_params $period]
			if {$mode == [list]} {
				post_message -type critical_warning "Memory interface with period $period and write $options(-write_deskew) deskew does not fall in a supported frequency range"
			} elseif {[lindex $mode 0] != [list]} {
				lappend tccs_params [lindex $mode 0]
				puts $tccs_params
			}
		}
		if {[catch {get_io_standard_node_delay -dst TCCS_LEAD -io_standard $io_std -parameters $tccs_params} tccs_lead] != 0 || $tccs_lead == "" || $tccs_lead == 0 || \
				[catch {get_io_standard_node_delay -dst TCCS_LAG -io_standard $io_std -parameters $tccs_params} tccs_lag] != 0 || $tccs_lag == "" || $tccs_lag == 0 } {
			set family $TimeQuestInfo(family)
			error "Missing $family timing model for tCCS of $io_std $tccs_params"
		} else {
			return [list $tccs_lead $tccs_lag]
		}
	}
}

# For static deskew, get the frequency range of the given configuration
# Return triplet {mode min_freq max_freq}
proc memphy_get_deskew_freq_range {timing_params period} {
	set mode [list]
	# freq_range list should be sorted from low to high
	if {[lindex $timing_params 2] == "STATIC_DESKEW_8" || [lindex $timing_params 2] == "STATIC_DESKEW_10"}  {
		# These modes have more than 2 freq ranges
		set range_list [list LOW HIGH]
	} else {
		# Just 1 freq range
		set range_list [list [list]]
	}
	set freq_mode [list]
	foreach freq_range $range_list {
		if {[catch {get_micro_node_delay -micro MIN -parameters [concat $timing_params $freq_range]} min_freq] != 0 || $min_freq == "" ||
			[catch {get_micro_node_delay -micro MAX -parameters [concat $timing_params $freq_range]} max_freq] != 0 || $max_freq == ""} {
			# Invalid mode
		} else {
			set max_freq_period [expr 1000.0 / $min_freq]
			set min_freq_period [expr 1000.0 / $max_freq]
			lappend freq_mode [list $freq_range $min_freq $max_freq]
			if {$period >= $min_freq_period && $period <= $max_freq_period} {
				set mode [lindex $freq_mode end]
				break
			}
		}
	}
	if {$mode == [list] && $freq_mode != [list]} {
		if {$period < $min_freq_period} {
			# Fastest mode
			set mode [lindex $freq_mode end]
		} else {
			# Slowest mode
			set mode [lindex $freq_mode 0]
		}
	}
	return $mode
}




# Return a tuple of setup,hold time for read capture
proc memphy_get_tsw { mem_if_memtype dqs_list period args} {
	global TimeQuestInfo
	array set options [list "-read_deskew" "none" "-dll_length" 0 "-config_period" 0 "-ddr3_discrete" 0]
	foreach {option value} $args {
		if {[array names options -exact "$option"] != ""} {
			set options($option) $value
		} else {
			error "ERROR: Unknown get_tsw option $option (with value $value; args are $args)"
		}
	}

	set interface_type [memphy_get_io_interface_type $dqs_list]
	if {$interface_type == "VHPAD"} {
		set interface_type "HPAD"
	}
	set io_std [memphy_get_io_standard [lindex $dqs_list 0]]

	if {$interface_type != "" && $interface_type != "UNKNOWN" && $io_std != "" && $io_std != "UNKNOWN"} {
		package require ::quartus::ddr_timing_model
		set family $TimeQuestInfo(family)
		set tsw_params [list IO $interface_type]
		if {$options(-ddr3_discrete) == 1} {
			lappend tsw_params NONLEVELED
		} elseif {$options(-read_deskew) == "static"} {
			if {$options(-dll_length) != 0} {
				lappend tsw_params STATIC_DESKEW_$options(-dll_length)
			} else {
				# No DLL length dependency
				lappend tsw_params STATIC_DESKEW
			}
		} elseif {$options(-read_deskew) == "dynamic"} {
			lappend tsw_params DYNAMIC_DESKEW
		}

		if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std -parameters $tsw_params} tsw_setup] != 0 || $tsw_setup == "" || $tsw_setup == 0 || \
				[catch {get_io_standard_node_delay -dst TH -io_standard $io_std -parameters $tsw_params} tsw_hold] != 0 || $tsw_hold == "" || $tsw_hold == 0 } {
			error "Missing $family timing model for tSW of $io_std $tsw_params"
		} else {
			# Derate tSW for DDR2 on VPAD in CIII Q240 parts
			# The tSW for HPADs and for other interface types on C8 devices
			# have a large guardband, so derating for them is not required
			if {[get_part_info -package -pin_count $TimeQuestInfo(part)] == "PQFP 240"} {
				if {[catch {get_io_standard_node_delay -dst TSU -io_standard $io_std -parameters [list IO $interface_type Q240_DERATING]} tsw_setup_derating] != 0 || $tsw_setup_derating == 0 || \
						[catch {get_io_standard_node_delay -dst TH -io_standard $io_std -parameters [list IO $interface_type Q240_DERATING]} tsw_hold_derating] != 0 || $tsw_hold_derating == 0} {
					set f "$io_std/$interface_type/$family"
					switch -glob $f {
						"SSTL_18*/VPAD/Cyclone III"  {
							set tsw_setup_derating 50
							set tsw_hold_derating 135
						}
						"SSTL_18*/VPAD/Cyclone IV E"  {
							set tsw_setup_derating 50
							set tsw_hold_derating 135
						}						
						default {
							set tsw_setup_derating 0
							set tsw_hold_derating 0
						}
					}
				}
				incr tsw_setup $tsw_setup_derating
				incr tsw_hold $tsw_hold_derating
			}
			return [list $tsw_setup $tsw_hold]
		}
	}
}

# ----------------------------------------------------------------
#
proc memphy_get_fitter_report_pin_info_from_report {target_pin info_type pin_report_id} {
#
# Description: Gets the report field for the given pin in the given report
#
# ----------------------------------------------------------------
	set pin_name_column [memphy_get_report_column $pin_report_id "Name"]
	set info_column [memphy_get_report_column $pin_report_id $info_type]
	set result ""

	if {$pin_name_column == 0 && 0} {
		set row_index [get_report_panel_row_index -id $pin_report_id $target_pin]
		if {$row_index != -1} {
			set row [get_report_panel_row -id $pin_report_id -row $row_index]
			set result [lindex $row $info_column]
		}
	} else {
		set report_rows [get_number_of_rows -id $pin_report_id]
		for {set row_index 1} {$row_index < $report_rows && $result == ""} {incr row_index} {
			set row [get_report_panel_row -id $pin_report_id -row $row_index]
			set pin [lindex $row $pin_name_column]
			if {$pin == $target_pin} {
				set result [lindex $row $info_column]
			}
		}
	}
	return $result
}

# ----------------------------------------------------------------
#
proc memphy_get_fitter_report_pin_info {target_pin info_type preferred_report_id {found_report_id_name ""}} {
#
# Description: Gets the report field for the given pin by searching through the
#              input, output and bidir pin reports
#
# ----------------------------------------------------------------
	if {$found_report_id_name != ""} {
		upvar 1 $found_report_id_name found_report_id
	}
	set found_report_id -1
	set result ""
	if {$preferred_report_id == -1} {
		set pin_report_list [list "Fitter||Resource Section||Bidir Pins" "Fitter||Resource Section||Input Pins" "Fitter||Resource Section||Output Pins"]
		for {set pin_report_index 0} {$pin_report_index != [llength $pin_report_list] && $result == ""} {incr pin_report_index} {
			set pin_report_id [get_report_panel_id [lindex $pin_report_list $pin_report_index]]
			if {$pin_report_id != -1} {
				set result [memphy_get_fitter_report_pin_info_from_report $target_pin $info_type $pin_report_id]
				if {$result != ""} {
					set found_report_id $pin_report_id
				}
			} else {
				post_message -type error "memphy_pin_map.tcl: Failed to find fitter report. If report timing is run after an ECO, the user must set_global_assignment -name ECO_REGENERATE_REPORT ON in memphy.qsf and in memphy_pin_assignment.tcl files and rerun ECO and STA"
			}
		}
	} else {
		set result [memphy_get_fitter_report_pin_info_from_report $target_pin $info_type $preferred_report_id]
		if {$result != ""} {
			set found_report_id $preferred_report_id
		}
	}
	return $result
}
# ----------------------------------------------------------------
#
proc memphy_get_fitter_report_pin_io_type_info {target_pin} {
#
# Description: Gets the type of IO, either column or row for
# a given pin. If none found then "" is returned.
#
# ----------------------------------------------------------------
`ifdef IPTCL_STRATIXV
	return "Column I/O"
`else
	set result ""
	set pin_report_id [get_report_panel_id "Fitter||Resource Section||All Package Pins"]
	if {$pin_report_id != -1} {
		set pin_name_column [memphy_get_report_column $pin_report_id "Pin Name/Usage"]
		set info_column [memphy_get_report_column $pin_report_id "I/O Type"]
		if {$pin_name_column == 0 && 0} {
			set row_index [get_report_panel_row_index -id $pin_report_id $target_pin]
			if {$row_index != -1} {
				set row [get_report_panel_row -id $pin_report_id -row $row_index]
				set result [lindex $row $info_column]
			}
		} else {
			set report_rows [get_number_of_rows -id $pin_report_id]
			for {set row_index 1} {$row_index < $report_rows && $result == ""} {incr row_index} {
				set row [get_report_panel_row -id $pin_report_id -row $row_index]
				set pin [lindex $row $pin_name_column]
				if {$pin == $target_pin} {
					set result [lindex $row $info_column]
				}
			}
		}
	} else {
		set pin_report_id [get_report_panel_id "Fitter||Resource Section||DQS Summary"]
		if {$pin_report_id != -1} {
		
			set report_rows [get_number_of_rows -id $pin_report_id]
			set pin_name_column [memphy_get_report_column $pin_report_id "Name"]
			set info_column [memphy_get_report_column $pin_report_id "I/O Edge"]
			
			for {set row_index 1} {$row_index < $report_rows && $result == ""} {incr row_index} {
				set row [get_report_panel_row -id $pin_report_id -row $row_index]
				set pin [lindex $row $pin_name_column]
				regsub -all {[ \r\t\n]+} $pin "" pin_no_whitespace
				if {$pin_no_whitespace == $target_pin} {
					set result [lindex $row $info_column]
				}
			}
			
			if {($result == "Bottom") || ($result == "Top")} {
				set result "Column I/O"
			} elseif {($result == "Left") || ($result == "Right")} {
				set result "Row I/O"
			}
		}
	}

	return $result
`endif
}
# ----------------------------------------------------------------
#
proc memphy_get_io_interface_type {pin_list} {
#
# Description: Gets the type of pin that the given pins are placed on
#              either (HPAD, VPAD, HYBRID, "", or UNKNOWN).
#              "" is returned if pin_list is empty
#              UNKNOWN is returned if an error was encountered
#              This function assumes the fitter has already completed and the
#              compiler report has been loaded.
#
# ----------------------------------------------------------------
	set preferred_report_id -1
	set interface_type ""
	foreach target_pin $pin_list {
		set io_bank [memphy_get_fitter_report_pin_info $target_pin "I/O Bank" $preferred_report_id preferred_report_id]
		if {[regexp -- {^([0-9]+)[A-Z]*} $io_bank -> io_bank_number]} {
			if {$io_bank_number == 1 || $io_bank_number == 2 || $io_bank_number == 5 || $io_bank_number == 6} {
				# Row I/O
				if {$interface_type == ""} {
					set interface_type "HPAD"
				} elseif {$interface_type == "VIO"} {
					set interface_type "HYBRID"
				}
			} elseif {$io_bank_number == 3 || $io_bank_number == 4 || $io_bank_number == 7 || $io_bank_number == 8} {
				if {$interface_type == ""} {
					set interface_type "VPAD"
				} elseif {$interface_type == "HIO"} {
					set interface_type "HYBRID"
				}
			} else {
				post_message -type critical_warning "Unknown I/O bank $io_bank for pin $target_pin"
				# Assume worst case performance (mixed HIO/VIO interface)
				set interface_type "HYBRID"
			}
		}
	}
	return $interface_type
}


# ----------------------------------------------------------------
#
proc memphy_get_report_column { report_id str} {
#
# Description: Gets the report column index with the given header string
#
# ----------------------------------------------------------------
	set target_col [get_report_panel_column_index -id $report_id $str]
	if {$target_col == -1} {
		error "Cannot find $str column"
	}
	return $target_col
}

proc memphy_traverse_to_dll_id {dqs_pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set dqs_pin_id [get_atom_node_by_name -name $dqs_pin]
	set dqs_to_dll_path [list {IO_PAD fanout PADOUT} {IO_IBUF fanout O} {DQS_DELAY_CHAIN fanin DELAYCTRLIN} {DLL end DELAYCTRLOUT}]
	set dll_id_list [memphy_traverse_atom_path $dqs_pin_id -1 $dqs_to_dll_path]
	set dll_id -1
	if {[llength $dll_id_list] == 1} {
		set dll_atom_oterm_pair [lindex $dll_id_list 0]
		set dll_id [lindex $dll_atom_oterm_pair 0]
	} elseif {[llength $dll_id_list] > 1} {
		lappend msg_list "Error: Found more than 1 DLL"
	} else {
		lappend msg_list "Error: DLL not found"
	}
	return $dll_id
}

proc memphy_traverse_to_dqs_delaychain_id {dqs_pin msg_list_name} {
	upvar 1 $msg_list_name msg_list
	set dqs_pin_id [get_atom_node_by_name -name $dqs_pin]
	set dqs_to_delaychain_path [list {IO_PAD fanout PADOUT} {IO_IBUF fanout O} {DQS_DELAY_CHAIN atom}]
	set delaychain_id_list [memphy_traverse_atom_path $dqs_pin_id -1 $dqs_to_delaychain_path]
	set delaychain_id -1
	if {[llength $delaychain_id_list] == 1} {
		set delaychain_atom_oterm_pair [lindex $delaychain_id_list 0]
		set delaychain_id [lindex $delaychain_atom_oterm_pair 0]
	} elseif {[llength $delaychain_id_list] > 1} {
		lappend msg_list "Error: Found more than 1 DQS delaychain"
	} else {
		lappend msg_list "Error: DQS delaychain not found"
	}
	return $delaychain_id
}

proc memphy_get_dqs_phase_setting { dqs_pins } {
	set dqs_phase_setting 0
	set dqs0 [lindex $dqs_pins 0]
	if {$dqs0 != ""} {
		set dqs_delay_chain_id [memphy_traverse_to_dqs_delaychain_id $dqs0 msg_list]
		if {$dqs_delay_chain_id != -1} {
`ifdef IPTCL_ACV_FAMILY
			set dqs_phase_setting 2
`else
`ifdef IPTCL_STRATIXV
			set dqs_phase_setting [get_atom_node_info -key INT_PHASE_SETTING -node $dqs_delay_chain_id]
`else
			set dqs_phase_setting [get_atom_node_info -key UINT_PHASE_SETTING -node $dqs_delay_chain_id]
`endif
`endif
		}
	}

	if {$dqs_phase_setting == 0} {
		set dqs_phase_setting 2
		post_message -type critical_warning "Unable to determine DQS delay chain phase setting.  Assuming default setting of $dqs_phase_setting"
	}

	return $dqs_phase_setting
}

proc memphy_get_dqs_phase { dqs_pins } {
`ifdef IPTCL_STRATIXV
	# Stratix V DLL Length is always 8
	set dll_length 8
`else
	set dqs0 [lindex $dqs_pins 0]
	set dll_length 0
	if {$dqs0 != ""} {
		set dll_id [memphy_traverse_to_dll_id $dqs0 msg_list]
		if {$dll_id != -1} {
`ifdef IPTCL_ACV_FAMILY
			set dll_length 8
`else
			set dll_length [get_atom_node_info -key UINT_DELAY_CHAIN_LENGTH -node $dll_id]
`endif
		}
	}
	if {$dll_length == 0} {
		set dll_length 8
		post_message -type critical_warning "Unable to determine DLL delay chain length.  Assuming default setting of $dll_length"
	}
`endif

	set dqs_phase_setting [ memphy_get_dqs_phase_setting $dqs_pins ]

	if { $dqs_phase_setting != $::GLOBAL_dqs_delay_chain_length } {
		post_message -type critical_warning "The DQS delay chain length set in the _parameter.tcl file doesn't match the queried value"
		post_message -type critical_warning "   Parameter value: $::GLOBAL_dqs_delay_chain_length"
		post_message -type critical_warning "   Queried value: $dqs_phase_setting"
		post_message -type critical_warning "The constraints applied by the SDC file may be inaccurate"
	}

	set dqs_phase [expr 360/$dll_length * $dqs_phase_setting]

	return $dqs_phase
}

proc memphy_get_dqs_period { dqs_pins } {
	set dqs_period -100
	set dqs0 [lindex $dqs_pins 0]
	if {$dqs0 != ""} {
		set dll_id [memphy_traverse_to_dll_id $dqs0 msg_list]
		if {$dll_id != -1} {
			set dqs_period_str [get_atom_node_info -key TIME_INPUT_FREQUENCY -node $dll_id]
			if {[regexp {(.*) ps} $dqs_period_str matched dqs_period_ps] == 1} {
				set dqs_period [expr $dqs_period_ps/1000.0]
			} elseif {[regexp {(.*) ps} $dqs_period_str matched dqs_period_ns] == 1} {
				set dqs_period $dqs_period_ns
			}
			
		}
	}

	if {$dqs_period < 0} {
		set dqs_period 0
		post_message -type critical_warning "Unable to determine DQS delay chain period.  Assuming default setting of $dqs_period"
	}

	return $dqs_period
}

proc memphy_get_operating_conditions_number {} {
	set cur_operating_condition [get_operating_conditions]
	set counter 0
	foreach_in_collection op [get_available_operating_conditions] {
		if {[string compare $cur_operating_condition $op] == 0} {
			return $counter
		}
		incr counter
	}
	return $counter
}


proc memphy_get_ddr_pins { instname allpins } {
	# We need to make a local copy of the allpins associative array
	upvar allpins pins

	global ::GLOBAL_dqs_group_size
	global ::GLOBAL_number_of_dqs_groups

	set synthesis_flow 0
	set sta_flow 0
	if { $::TimeQuestInfo(nameofexecutable) == "quartus_map" } {
		set synthesis_flow 1
	} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_sta" } {
		set sta_flow 1
	}
	
	set dqs_inst "altdq_dqs2_inst|"
	set dqs_pins [ list ]
	set dqsn_pins [ list ]
	set q_groups [ list ]
	set dqs_in_clocks [ list ]
	set dqs_out_clocks [ list ]
	set dqsn_out_clocks [ list ]
`ifdef IPTCL_MEM_LEVELING
	set leveling_pins [ list ]
 `ifdef IPTCL_STRATIXV
	set dq_xphase_cps_pins [ list ]
	set dqs_xphase_cps_pins [ list ] 
 `endif		
`endif
	for { set i 0 } { $i < $::GLOBAL_number_of_dqs_groups } { incr i } {
		set dqs_string ${instname}|p0|umemphy|uio_pads|dq_ddio\[$i\].ubidir_dq_dqs|${dqs_inst}obuf_os_0|o
`ifdef IPTCL_USE_2X_FF
		set dqs_2x_string ${instname}|p0|umemphy|uio_pads|dq_ddio\[$i\].ubidir_dq_dqs|altdq_dqs2_inst|dd_os
`endif
		set dqs_local_pins [ memphy_get_names_in_collection [ get_fanouts $dqs_string ] ]
		set dqsn_string ${instname}|p0|umemphy|uio_pads|dq_ddio\[$i\].ubidir_dq_dqs|${dqs_inst}obuf_os_bar_0|o
		set dqsn_local_pins [ memphy_get_names_in_collection [ get_fanouts $dqsn_string ] ]

`ifdef IPTCL_MEM_IF_DM_PINS_EN
		set dm_string ${instname}|p0|umemphy|uio_pads|dq_ddio\[$i\].ubidir_dq_dqs|${dqs_inst}extra_output_pad_gen\[0\].obuf_1|o
		set dm_local_pins [ memphy_get_names_in_collection [ get_fanouts $dm_string ] ]
`else
		set dm_local_pins [list]
`endif

		set dqs_in_clock(dqs_pin) [ lindex $dqs_local_pins 0 ]
		set dqs_in_clock(dqs_shifted_pin) "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_delay_chain|dqsbusout"
		set dqs_in_clock(div_name) "${instname}|div_clock_$i"
		set dqs_in_clock(div_pin) "${instname}|p0|umemphy|uread_datapath|read_capture_clk_div2[$i]"

		lappend dqs_in_clocks [ array get dqs_in_clock ]

		set dqs_out_clock(dst) [ lindex $dqs_local_pins 0 ]
		set dqs_out_clock(src) $dqs_string
`ifdef IPTCL_USE_2X_FF
		set dqs_out_clock(2X) $dqs_2x_string
`endif
		set dqs_out_clock(dm_pin) [ lindex $dm_local_pins 0 ]
		lappend dqs_out_clocks [ array get dqs_out_clock ]
		set dqsn_out_clock(dst) [ lindex $dqsn_local_pins 0 ]
		set dqsn_out_clock(src) $dqsn_string
`ifdef IPTCL_USE_2X_FF	
		set dqsn_out_clock(2X) $dqs_2x_string
`endif		
		set dqsn_out_clock(dm_pin) [ lindex $dm_local_pins 0 ]
		lappend dqsn_out_clocks [ array get dqsn_out_clock ]

`ifdef IPTCL_MEM_LEVELING
`ifdef IPTCL_STRATIXV
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_alignment_*|clk"
		lappend dq_xphase_cps_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dq_shift_select*|clkout"
		lappend dqs_xphase_cps_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_shift_select*|clkout"
`else
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_alignment|clk"
`endif
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_oe_alignment|clk"
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_oct_alignment|clk"
`ifdef IPTCL_STRATIXV
`ifdef IPTCL_MEM_IF_DM_PINS_EN
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}extra_output_pad_gen[0].data_alignment_*|clk"
`endif
`else
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_oe_bar_alignment|clk"
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}dqs_oct_bar_alignment|clk"
`ifdef IPTCL_MEM_IF_DM_PINS_EN
		lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}extra_output_pad_gen[0].data_alignment|clk"
`endif
`endif
`endif
		set q_group [ list ]
		for { set j 0 } { $j < $::GLOBAL_dqs_group_size } { incr j } { 
			set index [ expr $i * $::GLOBAL_dqs_group_size + $j ]
			set q_string ${instname}|p0|umemphy|uio_pads|dq_ddio\[$i\].ubidir_dq_dqs|${dqs_inst}pad_gen\[${j}\].data_out|o
			set tmp_q_pins [ memphy_get_names_in_collection [ get_fanouts $q_string ] ]
			
`ifdef IPTCL_MEM_LEVELING
`ifdef IPTCL_STRATIXV
			lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}output_path_gen[$j].data_alignment_*|clk"
			lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}output_path_gen[$j].oe_alignment|clk"
`else
			lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}output_path_gen[$j].data_alignment|clk"
			lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}output_path_gen[$j].oe_alignment|clk"
			lappend leveling_pins "${instname}|p0|umemphy|uio_pads|dq_ddio[$i].ubidir_dq_dqs|${dqs_inst}output_path_gen[$j].oct_alignment|clk"			
`endif
`endif

			lappend q_group $tmp_q_pins
		}

		if { [llength $dqs_local_pins] != 1} { post_sdc_message critical_warning "Could not find DQS pin number $i" } 
		if { [llength $dqsn_local_pins] != 1} { post_sdc_message critical_warning "Could not find DQSn pin number $i" } 
		if { [llength $q_group] != $::GLOBAL_dqs_group_size} { 
			post_sdc_message critical_warning "Could not find correct number of D pins for K pin $i. \
				Found [llength $q_group] pins. Expecting ${::GLOBAL_dqs_group_size}." 
		}

		lappend dqs_pins [ join $dqs_local_pins ]
		lappend dqsn_pins [ join $dqsn_local_pins ]
		lappend dm_pins [ join $dm_local_pins ]
		lappend q_groups [ join $q_group ]
	}

	set pins(dqs_pins) $dqs_pins
	set pins(dqsn_pins) $dqsn_pins
`ifdef IPTCL_MEM_IF_DM_PINS_EN
	set pins(dm_pins) $dm_pins
`else
	set pins(dm_pins) ""
`endif
	set pins(q_groups) $q_groups
	set pins(all_dq_pins) [ join [ join $q_groups ] ]
	set pins(dqs_in_clocks) $dqs_in_clocks
	set pins(dqs_out_clocks) $dqs_out_clocks
	set pins(dqsn_out_clocks) $dqsn_out_clocks

`ifdef IPTCL_MEM_LEVELING
	set pins(leveling_pins) [ join $leveling_pins ]
 `ifdef IPTCL_STRATIXV
	set pins(dq_xphase_cps_pins) [ join $dq_xphase_cps_pins ]
	set pins(dqs_xphase_cps_pins) [ join $dqs_xphase_cps_pins ]
 `endif	
`endif

	set pins(all_dq_dm_pins) [ concat $pins(all_dq_pins) $pins(dm_pins) ]

	# Other Outputs

	set pins(ck_pins) [ list ]
	set pins(ckn_pins) [ list ]
	set pins(add_pins) [ list ]
	set pins(cmd_pins) [ list ]

	set patterns [ list ]
	lappend patterns ck_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|clock_gen[*].uclk_generator|pseudo_diffa_0|o
	lappend patterns ckn_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|clock_gen[*].uclk_generator|pseudo_diffa_0|obar

	set addr_cmd_postfix "*fr_ddio_out|*ddio_o*"
	lappend patterns add_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|uaddress_pad|${addr_cmd_postfix}
	lappend patterns cmd_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|ucs_n_pad|${addr_cmd_postfix}
	lappend patterns cmd_pins ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|ucke_pad|${addr_cmd_postfix}

	foreach {pin_type pattern} $patterns { 
		set local_pins [ memphy_get_names_in_collection [ get_fanouts $pattern ] ]
		if {[llength $local_pins] == 0} {
			post_message -type critical_warning "Could not find pin of type $pin_type from pattern $pattern"
		} else {
			foreach pin [lsort -unique $local_pins] {
				lappend pins($pin_type) $pin
			}
		}
	}

	set pins(ac_pins) [ concat $pins(add_pins) $pins(cmd_pins) ]

`ifdef IPTCL_HARD_PHY
	set pins(afi_ck_pins) ${instname}|p0|umemphy|afi_clk_reg
`else
	`ifdef IPTCL_MAKE_FIFOS_IN_ALTDQDQS
	set pins(afi_ck_pins) ${instname}|s0|*sequencer_rw_mgr_inst|rw_mgr_inst|rw_mgr_core_inst|afi_rdata_valid_r
	`else
	set pins(afi_ck_pins) ${instname}|p0|umemphy|uread_datapath|afi_rdata_valid[0]
	`endif
`endif
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pins(afi_half_ck_pins) ${instname}|p0|umemphy|afi_half_clk_reg
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	`ifdef IPTCL_HARD_PHY
	set pins(avl_ck_pins) ${instname}|p0|umemphy|avl_clk_reg
	set pins(config_ck_pins) ${instname}|p0|umemphy|config_clk_reg
	`else
	set prefix [string map "| |*:" $instname]
	set pins(avl_ck_pins) *:${prefix}|*:s0|*:sequencer_rw_mgr_inst|*:rw_mgr_inst|cmd_done_avl
	set pins(config_ck_pins) ${instname}|s0|sequencer_scc_mgr_inst|scc_upd[0]
	`endif
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pins(p2c_read_ck_pins) ${instname}|p0|umemphy|uread_datapath|read_buffering[0].uread_read_fifo_hard|dataout[0]
	`ifdef IPTCL_FULL_RATE
	set pins(c2p_write_ck_pins) UNDEFINED_NODE_FOR_FR
	`else
	set pins(c2p_write_ck_pins) ${instname}|p0|umemphy|uio_pads|dq_ddio[0].ubidir_dq_dqs|altdq_dqs2_inst|output_path_gen[0].hr_to_fr_hi~DFFHI0
	`endif
`endif
`ifdef IPTCL_USE_2X_FF
	set pins(mem_ck_ddioout) ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|clock_gen[0].umem_ck_pad|auto_generated|ddio_outa[0]|dataout
	set pins(write_ck_ddioout) ${instname}|p0|umemphy|uio_pads|dq_ddio[0].ubidir_dq_dqs|altdq_dqs2_inst|output_path_gen[0].the_ddio_data|dataout
	set pins(ck_2x_reg) ${instname}|p0|umemphy|uio_pads|uaddr_cmd_pads|clock_gen[*].mem_ck_reg|q
`endif
	set pins(phase_transfer_pins) *:${prefix}|*:p0|*:umemphy|*:uio_pads|*:dq_ddio[*].ubidir_dq_dqs|*:altdq_dqs2_inst|*alignment*PHASE_TRANSFER_DFF
	set pins(dqs_enable_regs_pins) *:${prefix}|*:p0|*:umemphy|*:uio_pads|*:dq_ddio[*].ubidir_dq_dqs|*:altdq_dqs2_inst|dqs_enable_ctrl~DQSENABLEOUT_DFF

	#############
	# PLL STUFF #
	#############

	set pll_afi_clock "_UNDEFINED_PIN_"
	set pll_ck_clock "_UNDEFINED_PIN_"
`ifdef IPTCL_DUAL_WRITE_CLOCK
	set pll_dq_write_clock "_UNDEFINED_PIN_"
`endif
`ifdef IPTCL_USE_2X_FF
	set pll_2x_clock "_UNDEFINED_PIN_"
`endif
	set pll_write_clock "_UNDEFINED_PIN_"
	set pll_ac_clock "_UNDEFINED_PIN_"
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pll_afi_half_clock "_UNDEFINED_PIN_"
`endif
`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock "_UNDEFINED_PIN_"
	set pll_config_clock "_UNDEFINED_PIN_"
`endif
`ifdef IPTCL_QUARTER_RATE
	set pll_hr_clock "_UNDEFINED_PIN_"
`endif
`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pll_p2c_read_clock "_UNDEFINED_PIN_"
	set pll_c2p_write_clock "_UNDEFINED_PIN_"	
`endif
	set pll_ref_clock "_UNDEFINED_PIN_"
	set pll_ref_clock_input_buffer "_UNDEFINED_PIN_"

	set msg_list [ list ]

	# CLOCK OUTPUT PLL
`ifdef IPTCL_USE_2X_FF
	set pll_ck_clock_id [memphy_get_output_clock_id2 $pins(mem_ck_ddioout) "CK Output" msg_list]
`else	
	set pll_ck_clock_id [memphy_get_output_clock_id $pins(ck_pins) "CK Output" msg_list]
`endif	
	if {$pll_ck_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
`ifdef IPTCL_USE_2X_FF
		post_message -type critical_warning "dut_if0_p0_pin_map.tcl: Failed to find PLL clock for pins $pins(mem_ck_ddioout)"
`else
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(ck_pins)]"
`endif		
	} else {
		set pll_ck_clock [memphy_get_pll_clock_name $pll_ck_clock_id]
	}
	set pins(pll_ck_clock) $pll_ck_clock

`ifdef IPTCL_USE_2X_FF
	# 2X clock
	set pll_2x_clock_id [memphy_get_output_clock_id $pins(ck_pins) "CK Output" msg_list]
	if {$pll_2x_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "dut_if0_p0_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "dut_if0_p0_pin_map.tcl: Failed to find PLL clock for pins [join $pins(ck_pins)]"
	} else {
		set pll_2x_clock [memphy_get_pll_clock_name $pll_2x_clock_id]
	}
	set pins(pll_2x_clock) $pll_2x_clock
`endif

	# AFI CLOCK PLL
	set pll_afi_clock_id [memphy_get_output_clock_id $pins(afi_ck_pins) "AFI CK" msg_list]
	if {$pll_afi_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(afi_ck_pins)]"
	} else {
		set pll_afi_clock [memphy_get_pll_clock_name $pll_afi_clock_id]
	}
	set pins(pll_afi_clock) $pll_afi_clock

`ifdef IPTCL_DUAL_WRITE_CLOCK
	# DQ PLL
`ifdef IPTCL_USE_2X_FF
	set pll_dq_write_clock_id [memphy_get_output_clock_id2 $pins(write_ck_ddioout) "Write DQ CK" msg_list 20]
`else
	set pll_dq_write_clock_id [memphy_get_output_clock_id [ join [ join $pins(q_groups) ]] "Write DQ CK" msg_list 20]
`endif	
	if {$pll_dq_write_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
`ifdef IPTCL_USE_2X_FF
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins $pins(write_ck_ddioout)"
`else
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [ join [ join $pins(q_groups) ]]"
`endif
	} else {
		set pll_dq_write_clock [memphy_get_pll_clock_name $pll_dq_write_clock_id]
	}
	set pins(pll_dq_write_clock) $pll_dq_write_clock
	
	# DQS PLL
`ifdef IPTCL_USE_2X_FF
	set pll_write_clock_id [memphy_get_output_clock_id2 $pins(write_ck_ddioout) "Write CK" msg_list 20]
`else
	set pll_write_clock_id [memphy_get_output_clock_id $pins(dqs_pins) "Write CK" msg_list 20]
`endif	
	if {$pll_write_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
`ifdef IPTCL_USE_2X_FF
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins $pins(write_ck_ddioout)"
`else
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins $pins(dqs_pins)"
`endif
	} else {
		set pll_write_clock [memphy_get_pll_clock_name $pll_write_clock_id]
	}
	set pins(pll_write_clock) $pll_write_clock	
`else	
	# DQ PLL
`ifdef IPTCL_STRATIXV
`ifdef IPTCL_USE_2X_FF
	set pll_write_clock_id [memphy_get_output_clock_id2 $pins(write_ck_ddioout) "Write CK" msg_list 20]
`else
	set pll_write_clock_id [memphy_get_output_clock_id [ join [ join $pins(q_groups) ]] "Write CK" msg_list 20]
`endif	
`else
	set pll_write_clock_id [memphy_get_output_clock_id [ join [ join $pins(q_groups) ]] "Write CK" msg_list]
`endif	
	if {$pll_write_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
`ifdef IPTCL_USE_2X_FF
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins $pins(write_ck_ddioout)"
`else
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [ join [ join $pins(q_groups) ]]"
`endif
	} else {
		set pll_write_clock [memphy_get_pll_clock_name $pll_write_clock_id]
	}
	set pins(pll_write_clock) $pll_write_clock
`endif

	# AC PLL
	set pll_ac_clock_id [memphy_get_output_clock_id $pins(add_pins) "Address/Command output" msg_list]
	if {$pll_ac_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(add_pins)]"
	} else {
		set pll_ac_clock [memphy_get_pll_clock_name $pll_ac_clock_id]
	}
	set pins(pll_ac_clock) $pll_ac_clock

`ifdef IPTCL_EXPORT_AFI_HALF_CLK
	set pll_afi_half_clock_id [memphy_get_output_clock_id $pins(afi_half_ck_pins) "AFI HALF CK" msg_list]
	if {$pll_afi_half_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(afi_half_ck_pins)]"
	} else {
		set pll_afi_half_clock [memphy_get_pll_clock_name $pll_afi_half_clock_id]
	}
	set pins(pll_afi_half_clock) $pll_afi_half_clock
`endif

`ifdef IPTCL_NIOS_SEQUENCER
	set pll_avl_clock_id [memphy_get_output_clock_id $pins(avl_ck_pins) "Avalon Bus CK" msg_list]
	if {$pll_avl_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(avl_ck_pins)]"
	} else {
		set pll_avl_clock [memphy_get_pll_clock_name $pll_avl_clock_id]
	}
	set pins(pll_avl_clock) $pll_avl_clock

	set pll_config_clock_id [memphy_get_output_clock_id $pins(config_ck_pins) "Config CK" msg_list]
	if {$pll_config_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(config_ck_pins)]"
	} else {
		set pll_config_clock [memphy_get_pll_clock_name $pll_config_clock_id]
	}
	set pins(pll_config_clock) $pll_config_clock
`endif

`ifdef IPTCL_CORE_PERIPHERY_DUAL_CLOCK
	set pll_p2c_read_clock_id [memphy_get_output_clock_id $pins(p2c_read_ck_pins) "P2C READ CK" msg_list]
	if {$pll_p2c_read_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(p2c_read_ck_pins)]"
	} else {
		set pll_p2c_read_clock [memphy_get_pll_clock_name $pll_p2c_read_clock_id]
	}
	set pins(pll_p2c_read_clock) $pll_p2c_read_clock
	
 `ifdef IPTCL_FULL_RATE
	set pins(pll_c2p_write_clock) NOT_APPLICABLE_FOR_FULL_RATE
 `else
	set pll_c2p_write_clock_id [memphy_get_output_clock_id $pins(c2p_write_ck_pins) "C2P WRITE CK" msg_list]
	if {$pll_c2p_write_clock_id == -1} {
		foreach {msg_type msg} $msg_list {
			post_message -type $msg_type "memphy_pin_map.tcl: $msg"
		}
		post_message -type critical_warning "memphy_pin_map.tcl: Failed to find PLL clock for pins [join $pins(c2p_write_ck_pins)]"
	} else {
		set pll_c2p_write_clock [memphy_get_pll_clock_name $pll_c2p_write_clock_id]
	}
	set pins(pll_c2p_write_clock) $pll_c2p_write_clock
 `endif
`endif	

	set pll_ref_clock_id [memphy_get_input_clk_id $pll_ck_clock_id]
	if {$pll_ref_clock_id == -1} {
		post_message -type error "memphy_pin_map.tcl: Failed to find PLL reference clock"
	} else {
		set pll_ref_clock [get_node_info -name $pll_ref_clock_id]
	}
	set pins(pll_ref_clock) $pll_ref_clock
	
	if {$synthesis_flow == 0} {
		if {$pll_ref_clock_id != -1} {
			set pll_ref_clock_id_fanout_edges [get_node_info -fanout_edges $pll_ref_clock_id]
			if {[llength $pll_ref_clock_id_fanout_edges] > 0} {
				for {set i 0} {$i < 1} {incr i} {
					set pll_ref_clock_input_buffer [get_node_info -name [get_edge_info -dst [get_node_info -fanout_edges [get_edge_info -dst [lindex $pll_ref_clock_id_fanout_edges $i]]]]]
				}
			} 
		}
	}
	set pins(pll_ref_clock_input_buffer) $pll_ref_clock_input_buffer		


	set entity_names_on [ memphy_are_entity_names_on ]

	# Instance name prefix
	
	set prefix [ string map "| |*:" $instname ]
	set prefix "*:$prefix"

	#####################
	# READ CAPTURE DDIO #
	#####################

	# Pending ALTDQ_DQS fix
	# Half rate: separate read and write ALTDQ_DQS
	# Full rate: bidirectional ALTDQ_DQS

	set read_capture_ddio_prefix [expr { $entity_names_on ? \
		"$prefix|*:p0|*:umemphy|*:uio_pads|*:dq_ddio\[*\].ubidir_dq_dqs|*:" : \
		"$instname|p0|umemphy|uio_pads|dq_ddio\[*\].ubidir_dq_dqs|" }]

`ifdef IPTCL_ACV_FAMILY
	set read_capture_ddio [list "${read_capture_ddio_prefix}${dqs_inst}*input_path_gen\[*\].capture_reg~DFFLO" \
								"${read_capture_ddio_prefix}${dqs_inst}*input_path_gen\[*\].aligned_input\[*\]"]
`else
`ifdef IPTCL_STRATIXV
	set read_capture_ddio [list "${read_capture_ddio_prefix}${dqs_inst}*input_path_gen\[*\].capture_reg*"]
`else
	set read_capture_ddio [list "${read_capture_ddio_prefix}${dqs_inst}*input_path_gen\[*\].capture_reg*" \
								"${read_capture_ddio_prefix}${dqs_inst}*read_data_out\[*\]"]
`endif								
`endif
	set pins(read_capture_ddio) $read_capture_ddio

	###################
	# RESET REGISTERS #
	###################

	# the output of this flop feeds the asynchronous clear pin of the reset registers and should be false pathed
    # since the deassertion of the reset is synchronous with the use of a reset pipeline
    # normal timing analysis will take care that 
	set afi_reset_reg $prefix|*:p0|*:umemphy|*:ureset|*:ureset_afi_clk|reset_reg[3]
	if { ! $entity_names_on } {
		set afi_reset_reg $instname|p0|umemphy|ureset|ureset_afi_clk|reset_reg[3]
	}
	set pins(afi_reset_reg) $afi_reset_reg

`ifdef IPTCL_NIOS_SEQUENCER
	set seq_reset_reg ${prefix}|*:s0|*
	if { ! $entity_names_on } {
		set seq_reset_reg ${instname}|s0|*
	}
`else
	set seq_reset_reg $prefix|*:p0|*:umemphy|*:usequencer|*
	if { ! $entity_names_on } {
		set seq_reset_reg $instname|p0|umemphy|usequencer|*
	}
`endif
	set pins(seq_reset_reg) $seq_reset_reg

    # first flop of a synchronzier
    # sequencer issues multiple resets during calibration, reset is synced over from AFI to read capture clock domain
	set sync_reg $prefix|*:p0|*:umemphy|*:uread_datapath|read_buffering[*].seq_read_fifo_reset_sync
	if { ! $entity_names_on } {
		set sync_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].seq_read_fifo_reset_sync
	}
	set pins(sync_reg) $sync_reg


	###############################
	# DATA RESYNCHRONIZATION FIFO #
	###############################

	set fifo_wraddress_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_buffering[*].uread_read_fifo_hard|*WRITE_ADDRESS_DFF*
	if { ! $entity_names_on } {
		set fifo_wraddress_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].uread_read_fifo_hard|*WRITE_ADDRESS_DFF*
	}
	set pins(fifo_wraddress_reg) $fifo_wraddress_reg
	
	set fifo_rdaddress_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_buffering[*].uread_read_fifo_hard|*READ_ADDRESS_DFF*
	if { ! $entity_names_on } {
		set fifo_rdaddress_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].uread_read_fifo_hard|*READ_ADDRESS_DFF*
	}
	set pins(fifo_rdaddress_reg) $fifo_rdaddress_reg		
	
	set fifo_wrload_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_buffering[*].uread_read_fifo_hard|*WRITE_LOAD_DFF*
	if { ! $entity_names_on } {
		set fifo_wrload_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].uread_read_fifo_hard|*WRITE_LOAD_DFF*
	}
	set pins(fifo_wrload_reg) $fifo_wrload_reg
	
	set fifo_rdload_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_buffering[*].uread_read_fifo_hard|*READ_LOAD_DFF*
	if { ! $entity_names_on } {
		set fifo_rdload_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].uread_read_fifo_hard|*READ_LOAD_DFF*
	}
	set pins(fifo_rdload_reg) $fifo_rdload_reg
	
	set fifo_wrdata_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_buffering[*].uread_read_fifo_hard|*INPUT_DFF*
	if { ! $entity_names_on } {
		set fifo_wrdata_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].uread_read_fifo_hard|*INPUT_DFF*
	}
	set pins(fifo_wrdata_reg) $fifo_wrdata_reg

	set fifo_rddata_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_buffering[*].uread_read_fifo_hard|dataout[*]
	if { ! $entity_names_on } {
		set fifo_rddata_reg $instname|p0|umemphy|uread_datapath|read_buffering[*].uread_read_fifo_hard|dataout[*]
	}
	set pins(fifo_rddata_reg) $fifo_rddata_reg

	###############################
	# VALID PREDICTION FIFO       #
	###############################

	set valid_fifo_wrdata_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_valid_predict[*].uread_valid_fifo|data_stored[*][*]
	if { ! $entity_names_on } {
		set valid_fifo_wrdata_reg $instname|p0|umemphy|uread_datapath|read_valid_predict[*].uread_valid_fifo|data_stored[*][*]
	}
	set pins(valid_fifo_wrdata_reg) $valid_fifo_wrdata_reg

	set valid_fifo_rddata_reg $prefix|*:p0|*:umemphy|*:uread_datapath|*:read_valid_predict[*].uread_valid_fifo|rd_data[*]
	if { ! $entity_names_on } {
		set valid_fifo_rddata_reg $instname|p0|umemphy|uread_datapath|read_valid_predict[*].uread_valid_fifo|rd_data[*]
	}
	set pins(valid_fifo_rddata_reg) $valid_fifo_rddata_reg

`ifdef IPTCL_STRATIXV
`else
	###############################
	# DQS ENABLE CIRCUITRY        #
	###############################
	
	set dqs_enable_reg $prefix|*:p0|*:umemphy|*:uio_pads|*:dq_ddio[*].ubidir_dq_dqs|*:altdq_dqs2_inst|dqs_enable_block~DFFIN
	if { ! $entity_names_on } {
		set dqs_enable_reg $instname|p0|umemphy|uio_pads|dq_ddio[*].ubidir_dq_dqs|altdq_dqs2_inst|dqs_enable_block~DFFIN
	}
	set pins(dqs_enable_reg) $dqs_enable_reg

	set dqs_enable_ctrl_extend_reg $prefix|*:p0|*:umemphy|*:uio_pads|*:dq_ddio[*].ubidir_dq_dqs|*:altdq_dqs2_inst|enable_ctrl~DFFEXTENDDQSENABLE
	if { ! $entity_names_on } {
		set dqs_enable_ctrl_extend_reg $instname|p0|umemphy|uio_pads|dq_ddio[*].ubidir_dq_dqs|altdq_dqs2_inst|enable_ctrl~DFFEXTENDDQSENABLE
	}
	set pins(dqs_enable_ctrl_extend_reg) $dqs_enable_ctrl_extend_reg
	
	set dqs_enable_ctrl_reg $prefix|*:p0|*:umemphy|*:uio_pads|*:dq_ddio[*].ubidir_dq_dqs|*:altdq_dqs2_inst|enable_ctrl~DQS_ENABLE_OUT_DFF
	if { ! $entity_names_on } {
		set dqs_enable_ctrl_reg $instname|p0|umemphy|uio_pads|dq_ddio[*].ubidir_dq_dqs|altdq_dqs2_inst|enable_ctrl~DQS_ENABLE_OUT_DFF
	}
	set pins(dqs_enable_ctrl_reg) $dqs_enable_ctrl_reg		
`endif	
}

proc memphy_initialize_ddr_db { ddr_db_par } {
	upvar $ddr_db_par local_ddr_db

	global ::GLOBAL_corename

	post_sdc_message info "Initializing DDR database for CORE $::GLOBAL_corename"
	set instance_list [memphy_get_core_instance_list $::GLOBAL_corename]
	# set local_ddr_db(instance_list) $instance_list

	foreach instname $instance_list {
		post_sdc_message info "Finding port-to-pin mapping for CORE: $::GLOBAL_corename INSTANCE: $instname"

		memphy_get_ddr_pins $instname allpins

		memphy_verify_ddr_pins allpins

		set local_ddr_db($instname) [ array get allpins ]
	}
}

proc memphy_verify_ddr_pins { pins_par } {
	upvar $pins_par pins

	# Verify Q groups
	set current_q_group_size -1
	foreach q_group $pins(q_groups) {
		set group_size [ llength $q_group ]
		if { $group_size == 0 } {
			post_message -type critical_warning "Q group of size 0"
		}
		if { $current_q_group_size == -1 } {
			set current_q_group_size $group_size
		} else {
			if { $current_q_group_size != $group_size } {
				post_message -type critical_warning "Inconsistent Q group size across groups"
			}
		}
	}

`ifdef IPTCL_MEM_IF_DM_PINS_EN
	# Verify DM pins
	set counted_dm_pins [ llength $pins(dm_pins) ]
	if { $::GLOBAL_number_of_dm_pins != $counted_dm_pins } {
		post_message -type critical_warning "Unexpected number of detected DM pins: $counted_dm_pins"
		post_message -type critical_warning "   expected: $::GLOBAL_number_of_dm_pins"
	}
`endif
	# Verify Address/Command/BA pins
	if { [ llength $pins(add_pins) ] == 0 } {
		post_message -type critical_warning "Address pins of size 0"
	}
	if { [ llength $pins(cmd_pins) ] == 0 } {
		post_message -type critical_warning "Command pins of size 0"
	}
}

proc memphy_get_all_instances_div_names { ddr_db_par } {
	upvar $ddr_db_par local_ddr_db

	set div_names [ list ]
	set instnames [ array names local_ddr_db ]
	foreach instance $instnames {
		array set pins $local_ddr_db($instance)

		foreach { dqs_in_clock_struct } $pins(dqs_in_clocks) {
			array set dqs_in_clock $dqs_in_clock_struct
			lappend div_names $dqs_in_clock(div_name)
		}
	}

	return $div_names
}

proc memphy_get_all_instances_dqs_pins { ddr_db_par } {
	upvar $ddr_db_par local_ddr_db

	set dqs_pins [ list ]
	set instnames [ array names local_ddr_db ]
	foreach instance $instnames {
		array set pins $local_ddr_db($instance)

		foreach { dqs_pin } $pins(dqs_pins) {
			lappend dqs_pins ${dqs_pin}_IN
			lappend dqs_pins ${dqs_pin}_OUT
		}
		foreach { dqsn_pin } $pins(dqsn_pins) {
			lappend dqs_pins ${dqsn_pin}_OUT
		}
`ifdef IPTCL_STRATIXV
		foreach { ck_pin } $pins(ck_pins) {
			lappend dqs_pins $ck_pin
		}
`endif
	}

	return $dqs_pins
}

proc memphy_dump_all_pins { ddr_db_par } {
	upvar $ddr_db_par local_ddr_db

	set instnames [ array names local_ddr_db ]

	set filename "${::GLOBAL_corename}_all_pins.txt"
	if [ catch { open $filename w 0777 } FH ] {
		post_message -type error "Can't open file < $filename > for writing"
	}

	post_message -type info "Dumping reference pin-map file: $filename"

	set script_name [ info script ]
	puts $FH "# PIN MAP for core < $::GLOBAL_corename >"
	puts $FH "#"
	puts $FH "# Generated by ${::GLOBAL_corename}_pin_assignments.tcl"
	puts $FH "#"
	puts $FH "# This file is for reference only and is not used by Quartus II"
	puts $FH "#"
	puts $FH ""

	foreach instance $instnames {
		array set pins $local_ddr_db($instance)

		puts $FH "INSTANCE: $instance"
		puts $FH "DQS: $pins(dqs_pins)"
		puts $FH "DQSn: $pins(dqsn_pins)"
		puts $FH "DQ: $pins(q_groups)"

		puts $FH "DM $pins(dm_pins)"

		puts $FH "CK: $pins(ck_pins)"
		puts $FH "CKn: $pins(ckn_pins)"

		puts $FH "ADD: $pins(add_pins)"
		puts $FH "CMD: $pins(cmd_pins)"

		puts $FH "REF CLK: $pins(pll_ref_clock)"
		puts $FH "PLL AFI: $pins(pll_afi_clock)"
		puts $FH "PLL CK: $pins(pll_ck_clock)"
`ifdef IPTCL_DUAL_WRITE_CLOCK
		puts $FH "PLL DQ WRITE: $pins(pll_dq_write_clock)"
`endif
`ifdef IPTCL_USE_2X_FF
		puts $FH "PLL 2X: $pins(pll_2x_clock)"
`endif
		puts $FH "PLL WRITE: $pins(pll_write_clock)"
		puts $FH "PLL AC: $pins(pll_ac_clock)"
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
		puts $FH "PLL AFI HALF: $pins(pll_afi_half_clock)"
`endif
`ifdef IPTCL_NIOS_SEQUENCER
		puts $FH "PLL AVL: $pins(pll_avl_clock)"
		puts $FH "PLL CONFIG: $pins(pll_config_clock)"
`endif

		set i 0
		foreach dqs_in_clock_struct $pins(dqs_in_clocks) {
			array set dqs_in_clock $dqs_in_clock_struct
			puts $FH "DQS_IN_CLOCK DQS_PIN ($i): $dqs_in_clock(dqs_pin)"
			puts $FH "DQS_IN_CLOCK DQS_SHIFTED_PIN ($i): $dqs_in_clock(dqs_shifted_pin)"
			puts $FH "DQS_IN_CLOCK DIV_NAME ($i): $dqs_in_clock(div_name)"
			puts $FH "DQS_IN_CLOCK DIV_PIN ($i): $dqs_in_clock(div_pin)"

			incr i
		}

		set i 0
		foreach dqs_out_clock_struct $pins(dqs_out_clocks) {
			array set dqs_out_clock $dqs_out_clock_struct
			puts $FH "DQS_OUT_CLOCK SRC ($i): $dqs_out_clock(src)"
			puts $FH "DQS_OUT_CLOCK DST ($i): $dqs_out_clock(dst)"
			puts $FH "DQS_OUT_CLOCK DM ($i): $dqs_out_clock(dm_pin)"
`ifdef IPTCL_USE_2X_FF
			puts $FH "DQS_OUT_CLOCK 2X ($i): $dqs_out_clock(2X)"
`endif			

			incr i
		}

		set i 0
		foreach dqsn_out_clock_struct $pins(dqsn_out_clocks) {
			array set dqsn_out_clock $dqsn_out_clock_struct
			puts $FH "DQSN_OUT_CLOCK SRC ($i): $dqsn_out_clock(src)"
			puts $FH "DQSN_OUT_CLOCK DST ($i): $dqsn_out_clock(dst)"
			puts $FH "DQSN_OUT_CLOCK DM ($i): $dqsn_out_clock(dm_pin)"
`ifdef IPTCL_USE_2X_FF
			puts $FH "DQSN_OUT_CLOCK 2X ($i): $dqsn_out_clock(2X)"
`endif
			

			incr i
		}

`ifdef IPTCL_MEM_LEVELING
		puts $FH "LEVELING PINS: $pins(leveling_pins)"
 `ifdef IPTCL_STRATIXV
		puts $FH "DQ XPHASE CPS PINS: $pins(dq_xphase_cps_pins)"
		puts $FH "DQS XPHASE CPS PINS: $pins(dqs_xphase_cps_pins)"
 `endif		
`endif

		puts $FH "READ CAPTURE DDIO: $pins(read_capture_ddio)"
		puts $FH "AFI RESET REGISTERS: $pins(afi_reset_reg)"
		puts $FH "SEQ  RESET REGISTERS: $pins(seq_reset_reg)"
		puts $FH "SYNCHRONIZERS: $pins(sync_reg)"
		puts $FH "SYNCHRONIZATION FIFO WRITE ADDRESS REGISTERS: $pins(fifo_wraddress_reg)"
		puts $FH "SYNCHRONIZATION FIFO WRITE REGISTERS: $pins(fifo_wrdata_reg)"
		puts $FH "SYNCHRONIZATION FIFO READ REGISTERS: $pins(fifo_rddata_reg)"
		puts $FH "VALID PREDICTION FIFO WRITE REGISTERS: $pins(valid_fifo_wrdata_reg)"
		puts $FH "VALID PREDICTION FIFO READ REGISTERS: $pins(valid_fifo_rddata_reg)"

		puts $FH ""
		puts $FH "#"
		puts $FH "# END OF INSTANCE: $instance"
		puts $FH ""
	}

	close $FH
}
proc memphy_dump_static_pin_map { ddr_db_par filename } {
	upvar $ddr_db_par local_ddr_db

	set instnames [ array names local_ddr_db ]

	if [ catch { open $filename w 0777 } FH ] {
		post_message -type error "Can't open file < $filename > for writing"
	}

	post_message -type info "Dumping static pin-map file: $filename"

	puts $FH "# AUTO-GENERATED static pin map for core < $::GLOBAL_corename >"
	puts $FH ""
	puts $FH "proc ${::GLOBAL_corename}_initialize_static_ddr_db { ddr_db_par } {"
	puts $FH "   upvar \$ddr_db_par local_ddr_db"
	puts $FH ""

	foreach instname $instnames {
		array set pins $local_ddr_db($instname)

		puts $FH "   # Pin Mapping for instance: $instname"

		memphy_static_map_expand_list $FH pins dqs_pins
		memphy_static_map_expand_list $FH pins dqsn_pins

		memphy_static_map_expand_list_of_list $FH pins q_groups

		puts $FH ""
		puts $FH "   set pins(all_dq_pins) \[ join \[ join \$pins(q_groups) \] \]"

		memphy_static_map_expand_list $FH pins dm_pins

		memphy_static_map_expand_list $FH pins ck_pins
		memphy_static_map_expand_list $FH pins ckn_pins

		memphy_static_map_expand_list $FH pins add_pins
		memphy_static_map_expand_list $FH pins cmd_pins

		puts $FH ""
		puts $FH "   set pins(ac_pins) \[ concat \$pins(add_pins) \$pins(cmd_pins) \]"

		memphy_static_map_expand_string $FH pins pll_ref_clock
		memphy_static_map_expand_string $FH pins pll_afi_clock
		memphy_static_map_expand_string $FH pins pll_ck_clock
`ifdef IPTCL_DUAL_WRITE_CLOCK
		memphy_static_map_expand_string $FH pins pll_dq_write_clock
`endif		
		memphy_static_map_expand_string $FH pins pll_write_clock
		memphy_static_map_expand_string $FH pins pll_ac_clock
`ifdef IPTCL_EXPORT_AFI_HALF_CLK
		memphy_static_map_expand_string $FH pins pll_afi_half_clock
`endif
`ifdef IPTCL_NIOS_SEQUENCER
		memphy_static_map_expand_string $FH pins pll_avl_clock
		memphy_static_map_expand_string $FH pins pll_config_clock
`endif

		puts $FH ""
		puts $FH "   set dqs_in_clocks \[ list \]"
		set i 0
		foreach dqs_in_clock_struct $pins(dqs_in_clocks) {
			array set dqs_in_clock $dqs_in_clock_struct
			puts $FH "   # DIV Clock ($i)"
			puts $FH "   set dqs_in_clock(dqs_pin) $dqs_in_clock(dqs_pin)"
			puts $FH "   set dqs_in_clock(dqs_shifted_pin) $dqs_in_clock(dqs_shifted_pin)"
			puts $FH "   set dqs_in_clock(div_name) $dqs_in_clock(div_name)"
			puts $FH "   set dqs_in_clock(div_pin) $dqs_in_clock(div_pin)"

			puts $FH "   lappend dqs_in_clocks \[ array get dqs_in_clock \]"

			incr i
		}
		puts $FH "   set pins(dqs_in_clocks) \$dqs_in_clocks"


		puts $FH ""
		puts $FH "   set dqs_out_clocks \[ list \]"
		set i 0
		foreach dqs_out_clock_struct $pins(dqs_out_clocks) {
			array set dqs_out_clock $dqs_out_clock_struct
			puts $FH "   # DQS OUT Clock ($i)"
			puts $FH "   set dqs_out_clock(src) $dqs_out_clock(src)"
			puts $FH "   set dqs_out_clock(dst) $dqs_out_clock(dst)"
			puts $FH "   set dqs_out_clock(dm_pin) $dqs_out_clock(dm_pin)"
`ifdef IPTCL_USE_2X_FF
			puts $FH "   set dqs_out_clock(2X) $dqs_out_clock(2X)"
`endif
			puts $FH "   lappend dqs_out_clocks \[ array get dqs_out_clock \]"

			incr i
		}
		puts $FH "   set pins(dqs_out_clocks) \$dqs_out_clocks"

		puts $FH ""
		puts $FH "   set dqsn_out_clocks \[ list \]"
		set i 0
		foreach dqsn_out_clock_struct $pins(dqsn_out_clocks) {
			array set dqsn_out_clock $dqsn_out_clock_struct
			puts $FH "   # DQSN OUT Clock ($i)"
			puts $FH "   set dqsn_out_clock(src) $dqsn_out_clock(src)"
			puts $FH "   set dqsn_out_clock(dst) $dqsn_out_clock(dst)"
			puts $FH "   set dqsn_out_clock(dm_pin) $dqsn_out_clock(dm_pin)"
`ifdef IPTCL_USE_2X_FF
			puts $FH "   set dqsn_out_clock(2X) $dqsn_out_clock(2X)"
`endif
			puts $FH "   lappend dqsn_out_clocks \[ array get dqsn_out_clock \]"

			incr i
		}
		puts $FH "   set pins(dqsn_out_clocks) \$dqsn_out_clocks"

`ifdef IPTCL_MEM_LEVELING
		memphy_static_map_expand_list $FH pins leveling_pins
`endif

		memphy_static_map_expand_string $FH pins read_capture_ddio
		memphy_static_map_expand_string $FH pins afi_reset_reg
		memphy_static_map_expand_string $FH pins seq_reset_reg
		memphy_static_map_expand_string $FH pins sync_reg
		memphy_static_map_expand_string $FH pins fifo_wraddress_reg 
		memphy_static_map_expand_string $FH pins fifo_wrdata_reg 
		memphy_static_map_expand_string $FH pins fifo_rddata_reg
		memphy_static_map_expand_string $FH pins valid_fifo_wrdata_reg 
		memphy_static_map_expand_string $FH pins valid_fifo_rddata_reg

		puts $FH ""
		puts $FH "   set local_ddr_db($instname) \[ array get pins \]"
	}

	puts $FH "}"

	close $FH
}
